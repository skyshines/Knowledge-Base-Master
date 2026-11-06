# `/kb setup` — Full Protocol

One-time interactive command that builds the entire `.kb/` knowledge base
for the host repository. Always scan first, present findings, get user
confirmation, then generate — never write silently.

---

## Pre-flight Checks

Before starting, verify:
- [ ] You are at the repository root (`.git/` exists here).
- [ ] `.kb/` does NOT already exist. If it does, tell the user to run `/kb refresh` instead.
- [ ] The user has SSH access to any dependent repos they plan to add.

---

## Phase 1 — Full Repository Scan

Run the detection scripts and collect all signals:

```bash
bash .agents/skills/kb-skill/scripts/detect-workflows.sh
bash .agents/skills/kb-skill/scripts/detect-deps.sh
```

The agent should ALSO independently scan the following locations:

### Entry Point Signals to Look For

| Signal Type | What to Look For | Examples |
|---|---|---|
| REST controllers | Class/file annotations or naming conventions | `@RestController`, `*Controller.*`, `router.get(`, `app.post(` |
| CLI commands | CLI framework registrations | `@Command`, `cobra.Command{}`, `click.command()`, `commander.command(` |
| Kafka consumers | Consumer annotations/config | `@KafkaListener`, `consumer.subscribe(`, `kafka.NewConsumer(` |
| gRPC handlers | Service implementations | `*ServiceServer`, `grpc.RegisterService` |
| Cron / schedulers | Scheduled job annotations | `@Scheduled`, `cron.AddFunc(`, `schedule(`, `celery.task` |
| Event handlers | Event subscription patterns | `@EventListener`, `on('event'`, `subscribe(` |
| GraphQL resolvers | Resolver registrations | `@Resolver`, `makeExecutableSchema` |

### Dependency Signals to Look For

Scan these files for external service dependencies:

| File | What to Extract |
|---|---|
| `pom.xml` | `<artifactId>` values under `<dependency>` |
| `go.mod` | Lines after `require (` |
| `package.json` | Keys under `"dependencies"` and `"devDependencies"` |
| `requirements.txt` / `Pipfile` | Package names |
| `build.gradle` | `implementation`, `api` declarations |
| Import statements | Cross-service client imports (e.g., `import payment.PaymentClient`) |

---

## Phase 2 — Present Findings to User

Present discovered workflows clearly. Example format:

```
I scanned your codebase and found the following potential workflow entry points:

WORKFLOWS / ENTRY POINTS DISCOVERED:
─────────────────────────────────────
 1. [REST]   POST /api/v1/assessment         → AssessmentController.java:42
 2. [REST]   POST /api/v1/features           → FeatureController.java:17
 3. [KAFKA]  Consumes: download.requested    → DownloadConsumer.java:28
 4. [CRON]   policySync() — every 6h        → PolicySyncJob.java:91
 5. [CLI]    install <package>               → InstallCommand.java:7
 6. [GRPC]   AssessmentService.RunCheck()   → AssessmentServiceImpl.java:55

DEPENDENCIES DETECTED:
──────────────────────
 A. payment-service      (via: pom.xml + PaymentClient.java import)
 B. notification-service (via: pom.xml)
 C. user-service         (via: UserServiceStub import)

─────────────────────────────────────
Do these look right? You can:
  • Say 'yes' or 'looks good' to confirm all
  • 'remove 3, 6' to exclude items
  • 'add: feature-rollback — triggered by DELETE /api/v1/features'
  • Give any other instructions (e.g., 'also check the gRPC handlers folder')

For dependencies, let me know:
  • Which ones need a cross-repo KB (I'll need their SSH clone URLs)
  • Any deps not in the list above
```

Wait for user response. Apply all edits before proceeding to Phase 3.

---

## Phase 3 — Workflow Name Mapping

For each confirmed entry point, determine the workflow name:
- If multiple entry points serve the same logical workflow, group them under one workflow folder.
- Ask the user if the auto-grouped names feel right.
- Workflow folder names must be: lowercase, hyphenated, no spaces (e.g., `policy-change`, `feature-update`).

```
Based on your confirmation, I'll create these workflow folders:

  workflows/assessment/        ← entry points: 1, 6
  workflows/feature-update/    ← entry point: 2
  workflows/download/          ← entry point: 3
  workflows/policy-change/     ← entry point: 4
  workflows/install/           ← entry point: 5

Does this grouping look right, or should I rename / re-group any?
```

---

## Phase 4 — Generate KB Structure

Once the user confirms workflow grouping:

### 4a. Create folder structure
Create the full `.kb/` tree (see [kb-structure-spec.md](./kb-structure-spec.md)).
Copy all relevant templates from `templates/` into the appropriate locations.

### 4b. Populate workflow files

For each workflow folder, fill in what the agent can determine from code:

**`flow.md`**
- Read the entry point file(s) and trace the execution path.
- Fill in the step-by-step breakdown table.
- Generate a mermaid flowchart if the flow is clear.
- Mark anything uncertain with `<!-- TODO: verify this step -->`.

**`entry-points.md`**
- Fill in confirmed entry points (HTTP method + path, Kafka topic + consumer group, etc.).

**`affected-components.md`**
- Scan imports and method calls from entry point files.
- List DB repositories accessed, Kafka producers called, external clients used.

**`edge-cases.md`**
- Leave mostly blank with `<!-- TODO: add known edge cases, error conditions, retry logic -->`.
- Fill in any `try/catch` blocks, error handlers, or retry annotations found in code.

### 4c. Populate helper files

**`helpers/db-tables/`**
- Scan for ORM entity definitions (`@Entity`, `type *struct`, Django models, Prisma schema).
- Create one `<table-name>.md` per entity using the template.
- Fill in columns, types, and any indexed fields found.

**`helpers/kafka/topics.md`**
- Collect all `@KafkaListener` topics (consumed) and `kafkaTemplate.send(` topic names (produced).
- Fill in the topics table.

**`helpers/apis/README.md`**
- Collect all REST endpoints from controllers/routers.
- Summarise in the overview table.

**`helpers/config/env-vars.md`**
- Scan for `System.getenv(`, `os.Getenv(`, `process.env.`, `os.environ[`.
- List all env vars found.

**`helpers/architecture/overview.md`**
- Ask the user: *"In 2–3 sentences, describe the architecture of this service."*
- Paste their answer + generate a mermaid component diagram from discovered components.

### 4d. Populate product files

Ask the user the following questions (collect all answers at once):

```
To fill in product/PRD.md and product/domain-glossary.md, please answer:

1. In one sentence: what does this service do, and who uses it?
2. What are the 2–3 most important user journeys?
3. List 5–10 domain-specific terms I should know (format: term = meaning).
4. What does this service explicitly NOT do? (non-goals — helps me avoid scope creep)
5. Any SLA targets or compliance requirements? (e.g., 99.9% uptime, GDPR, SOC2)
```

Fill `product/PRD.md`, `domain-glossary.md`, and `non-goals.md` from the answers.

### 4e. Populate deps config

For each dep the user selected in Phase 2, collect:

```
For each dependency you want in the KB, I need:
  • The SSH clone URL (git@gitlab.example.com:platform/<name>.git)
  • What we consume from it:
      - Which API endpoints? (or 'all')
      - Which Kafka topics?
      - Any proto/contract files?
  • How often does it change? (daily / weekly / monthly / frozen)
    → This sets the TTL for auto-staleness detection.
```

Generate `deps.config.yaml` from answers. Set `last_fetched: null` and `last_commit_hash: null`
(the first `/kb refresh` or first dep KB load will trigger sub-agent extraction).

### 4f. Generate KB_INDEX.md

Once all files are written, generate `KB_INDEX.md`:
- Scan all workflow folder names and their `entry-points.md` files for keywords.
- Scan all helper folder names.
- Build the keyword → file mapping tables.
- Include all dep entries in the cross-repo section.

---

## Phase 5 — Setup Summary

Print a completion summary:

```
✅ KB SETUP COMPLETE
────────────────────────────────────────────────
Workflows created:    5  (assessment, feature-update, download, policy-change, install)
Helper sections:      5  (db-tables, kafka, apis, config, architecture)
Dependencies staged:  3  (payment-service, notification-service, user-service)
                         → Run /kb refresh to trigger first dep KB extraction

KB_INDEX.md:          Generated with N keyword mappings

NEXT STEPS:
  1. Review the TODO markers in workflow files:
     grep -r "TODO" .kb/workflows/

  2. Review deps.config.yaml and confirm clone URLs are correct.

  3. Run /kb refresh to extract dep KBs (sub-agents will clone + extract).

  4. Commit .kb/ to version control:
     git add .kb/ && git commit -m "chore: initialise AI knowledge base"

  5. Add to your MR discipline:
     Run /kb refresh before raising MRs that change workflows or deps.
────────────────────────────────────────────────
```
