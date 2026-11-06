# 🧠 Knowledge-Base-Master

> **Stop feeding your AI the entire codebase. Give it a brain instead.**

A portable agent skill that builds and maintains a structured knowledge base for any repository — so your AI coding assistant injects exactly the right context, every time, without crawling source files.

---

## The Problem

When AI coding assistants first became useful, they had a dirty secret.

Every time you asked them to do something — fix a bug, implement a feature, understand a workflow — they'd silently go off and **read everything**. Controllers, models, configs, tests, migrations. All of it. Just to figure out where to begin.

That's not intelligence. That's expensive noise.

Two specific problems kept coming up:

**Problem 1 — Token waste from blind exploration**
The AI spent the majority of its context window *orienting itself* before it could even start the actual task. By the time it was ready to help, half the context was gone.

**Problem 2 — Cross-repo blindness**
Modern services don't live in isolation. When your service depends on another team's Kafka topics, REST APIs, or database contracts — the AI had no structured way to get that information. It either asked you to paste it in manually, or it cloned the foreign repo inside your active session, burning even more tokens.

---

## The Solution

**Knowledge-Base-Master** is a structured, AI-native knowledge base system built as an agent skill.

Instead of letting the AI explore freely, you give it a **pre-built map** of your repository — organised into workflow folders, helper references, and cross-repo dependency extracts. The AI reads the index first, loads only what it needs, and gets to work.

```
Before KB-Master:   AI reads 40+ files → finds 3 relevant ones → starts task
After KB-Master:    AI reads KB_INDEX.md → loads 3 specific files → starts task
```

And for cross-repo dependencies — a cheap sub-agent clones the foreign repo, extracts only the relevant contracts, updates the KB, and terminates. Your main agent's context stays clean.

---

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                   Your Repository                        │
│                                                          │
│  .kb/                                                    │
│  ├── KB_INDEX.md          ← AI reads this FIRST          │
│  ├── workflows/           ← End-to-end flow maps         │
│  │   ├── assessment/                                     │
│  │   ├── feature-update/                                 │
│  │   └── ...                                             │
│  ├── helpers/             ← DB tables, Kafka, APIs       │
│  ├── deps/                ← Cross-repo KB extracts       │
│  │   ├── deps.config.yaml                                │
│  │   └── payment-service/                                │
│  └── product/             ← PRD, glossary, non-goals     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

**AI Agent Flow:**
1. Read `KB_INDEX.md` → map task keywords to specific files
2. Load **only** the matched files into context
3. If cross-repo info needed → check dep KB freshness → load or refresh
4. If nothing matches → fall back to source code exploration (the old way)

---

## Two Commands. That's It.

### `/kb setup` — Build the Knowledge Base

Run once when you first install the skill in a repo.

The AI will:
- Scan your entire codebase for entry points (REST controllers, Kafka consumers, CLI commands, cron jobs, gRPC handlers)
- Scan your package manager files for cross-service dependencies
- **Present everything it found to you for review**
- Wait for your confirmation, corrections, and additions
- Build the full `.kb/` structure based on your input
- Ask you a few product-level questions (domain glossary, PRD, non-goals)
- Generate `KB_INDEX.md` as the master routing map

**You are always in the loop before anything is written.**

---

### `/kb refresh` — Keep It Current

Run before raising an MR, or after merging from master.

The AI will:
- Diff the current codebase against the existing KB
- Show you what's changed: new entry points, modified DB tables, new env vars, removed Kafka topics
- Apply only the updates you confirm
- Check all cross-repo dependencies for staleness (TTL + commit-hash drift detection)
- Spawn cheap sub-agents to refresh stale dep KBs — without touching your main context
- Regenerate `KB_INDEX.md` to reflect all changes

---

## Cross-Repo Dependencies — The Sub-Agent Pattern

When a dependency's KB is stale or missing, the parent agent spawns a **lightweight sub-agent**:

```
Parent Agent
    │
    └─► Sub-Agent (cheap flash-lite model)
            │
            ├── git clone --depth 1 <dep-repo>
            ├── Extract: only the APIs / Kafka schemas / contracts you specified
            ├── Write .kb/deps/<service-name>/ markdown files
            ├── Update META.md (timestamp, commit hash, TTL)
            ├── rm -rf /tmp/<clone>
            ├── Report back to parent: "EXTRACTION COMPLETE"
            └── Terminate ✓
```

The parent agent never touches the clone. Its context stays clean.

**Freshness is controlled by two signals:**
- **TTL** — configurable per dependency (e.g., 5 days for active services, 30 days for stable ones)
- **Commit-hash drift** — `git ls-remote` check with no clone required; detects silent updates between TTL windows

---

## Installation

### Prerequisites
- Git with SSH agent configured
- An AI IDE that supports agent skills (e.g., Cursor, Antigravity, Windsurf)

### Install as a Git Submodule

```bash
# In your service repository
git submodule add git@github.com:your-org/Knowledge-Base-Master.git .agents/skills/Knowledge-Base-Master

git add .gitmodules .agents/
git commit -m "chore: add Knowledge-Base-Master agent skill"
```

### Team Members Joining Later

```bash
git submodule update --init --recursive
```

### Updating the Skill

```bash
cd .agents/skills/Knowledge-Base-Master
git pull origin main
cd ../../../
git add .agents/skills/Knowledge-Base-Master
git commit -m "chore: update Knowledge-Base-Master skill"
```

---

## Recommended Team Workflow

```
┌──────────────┐     ┌──────────────────────┐     ┌──────────────┐
│  New Repo    │────►│   /kb setup          │────►│  .kb/ built  │
│  Onboarding  │     │  (once, interactive) │     │  committed   │
└──────────────┘     └──────────────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────────────┐     ┌──────────────┐
│  Before MR   │────►│   /kb refresh        │────►│  KB updated  │
│  (ongoing)   │     │  (manual, explicit)  │     │  committed   │
└──────────────┘     └──────────────────────┘     └──────────────┘
```

**MR Discipline (Recommended):**
```
git checkout -b feat/my-feature
# ... make code changes ...
/kb refresh                          ← before raising MR
git add .kb/
git commit -m "chore: [kb] refresh before MR #42"
git push
```

---

## What Gets Detected Automatically

### Entry Point Scanner (`scripts/detect-workflows.sh`)

| Language / Framework | What's Detected |
|---|---|
| Java / Kotlin (Spring Boot) | `@GetMapping`, `@PostMapping`, `@KafkaListener`, `@Scheduled` |
| Go (Gin, Chi, Echo, Gorilla) | `router.GET()`, `router.POST()`, `cron.AddFunc()`, `grpc.RegisterService` |
| Python (FastAPI, Flask, Django) | `@app.get()`, `@router.post()`, `@app.route()`, `celery.task` |
| Node.js / TypeScript | `router.get()`, `app.post()`, `@Get()`, `@Post()` (NestJS) |

### Dependency Scanner (`scripts/detect-deps.sh`)

Scans: `pom.xml` · `build.gradle` · `go.mod` · `package.json` · `requirements.txt` · cross-service client imports

---

## Repository Structure

```
Knowledge-Base-Master/
│
├── SKILL.md                        ← Skill entrypoint (AI reads this)
│
├── references/                     ← Detailed protocols — loaded only when needed
│   ├── kb-setup.md                 ← Full /kb setup interactive protocol
│   ├── kb-refresh.md               ← Full /kb refresh protocol
│   ├── sub-agent-protocol.md       ← Sub-agent operating instructions
│   ├── freshness-strategy.md       ← TTL + hash-drift decision logic
│   └── kb-structure-spec.md        ← Canonical .kb/ folder specification
│
├── templates/                      ← Blank KB files, copied into host repos
│   ├── KB_INDEX.md                 ← Master keyword → file routing index
│   ├── deps.config.yaml            ← Dependency registry + TTL config
│   ├── workflow-flow.md
│   ├── workflow-entry-points.md
│   ├── workflow-affected-components.md
│   ├── workflow-edge-cases.md
│   ├── helper-db-table.md
│   ├── helper-kafka-topics.md
│   ├── helper-api-endpoint.md
│   ├── helper-env-vars.md
│   ├── helper-architecture.md
│   ├── product-PRD.md
│   ├── product-glossary.md
│   └── dep-META.md
│
└── scripts/                        ← Shell scripts (multi-language support)
    ├── detect-workflows.sh         ← Finds entry points across Java/Go/Python/Node
    ├── detect-deps.sh              ← Finds deps from package managers + imports
    └── check-freshness.sh          ← TTL + git ls-remote hash check per dep
```

---

## The `.kb/` Folder (Generated in Your Repo)

After `/kb setup` runs in your repo, it creates:

```
.kb/
├── KB_INDEX.md                     ← AI entry point — always read first
├── workflows/
│   └── <workflow-name>/
│       ├── README.md               ← What + why (product view)
│       ├── flow.md                 ← Step-by-step + mermaid diagram
│       ├── entry-points.md         ← All triggers
│       ├── affected-components.md  ← Blast radius
│       └── edge-cases.md           ← Errors, retries, gotchas
├── helpers/
│   ├── db-tables/                  ← One .md per DB table
│   ├── kafka/                      ← Topics produced + consumed
│   ├── apis/                       ← Endpoints this service exposes
│   ├── config/                     ← Env vars + feature flags
│   └── architecture/               ← Diagrams + data flow
├── deps/
│   ├── deps.config.yaml            ← Dep registry (you maintain this)
│   └── <dep-service>/              ← Sub-agent generated, per dep
│       ├── META.md
│       ├── apis/
│       ├── kafka/
│       └── contracts/
└── product/
    ├── PRD.md                      ← Condensed PRD for AI context
    ├── domain-glossary.md
    └── non-goals.md                ← Explicit scope limits for AI
```

**Everything in `.kb/` is committed to version control.** It travels with your code.

---

## Design Decisions

| Decision | Choice | Why |
|---|---|---|
| Auth for `git clone` | SSH agent | Developers already have access; zero extra config |
| Workflow discovery | Scan first, user confirms | AI proposes, human decides — no silent writes |
| Dep KB extraction | Cheap sub-agent (flash-lite) | Parent context stays clean; cheap model is sufficient |
| Refresh trigger | Manual `/kb refresh` | Intentional discipline > hidden background automation |
| Staleness detection | TTL + commit-hash drift | Catches both time-based and silent upstream changes |
| Hash check method | `git ls-remote` only | No clone needed just to decide if refresh is required |
| Skill packaging | Git submodule | Versioned, updatable, one install per repo |

---

## Contributing

To add support for a new language or framework:
1. Edit `scripts/detect-workflows.sh` — add grep patterns for the new entry point style
2. Edit `scripts/detect-deps.sh` — add parsing for the new package manager format
3. Test against a sample repo and open an MR

To add a new KB section type (e.g., GraphQL resolvers, Redis keys):
1. Add a template file under `templates/`
2. Update `templates/KB_INDEX.md` with the new helper keywords
3. Document the new section in `references/kb-structure-spec.md`

---

## License

MIT — use it, modify it, share it with every team that's tired of watching their AI read the entire codebase before answering a simple question.
