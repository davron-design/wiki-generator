# Knowledge Base — Vault Conventions

## Vault Structure
- /raw — source material, clipped articles, research (the input zone)
- /wiki — LLM-compiled knowledge base (see Wiki System below)
- /output — query results and generated reports

## Wiki System
You are the librarian of the wiki/ folder. You write and maintain everything in it.

### Structure
- wiki/_master-index.md is the entry point — a `| Topic | Description |` table, one row per topic, with descriptions rich enough to navigate by.
- Each topic gets its own subfolder with its own _index.md — a `| Article | Description |` table (or multiple tables grouped under `##` section headings once the topic exceeds ~5 articles).
- Index rows use the piped wiki-link form (`[[topic-slug/_index|topic-slug]]`, `[[article-slug]]`) so links are clean and resolvable.

### Querying
When answering questions against the knowledge base:
1. Read wiki/_master-index.md first to find the right topic
2. Read that topic's _index.md to find relevant articles
3. Read the specific articles
4. Synthesize the answer
5. If the wiki doesn't offer any knowledge, don't make anything up and be sure to mention it

### Compiling
When the user says "compile" or drops new material in raw/, use the `raw-compile` skill. Compile is **additive** — it writes new articles and never rewrites existing ones. When new material contradicts or supersedes an article already in the wiki, compile leaves the article untouched and logs the conflict to `wiki/_pending-reconciliation.md` for the audit to resolve.

### Auditing
When the user says "audit" or "lint", use the `audit-wiki` skill. Auditing is a **periodic** reconciliation pass, not a step you run after every compile — compile is cheap and additive, audit is where deferred conflicts get resolved. Ingest freely, then audit when the reconciliation queue grows past ~10 open entries, after roughly 10 new sources, or whenever a source significantly supersedes an existing topic. Batching ingest and then auditing in bursts is the intended rhythm; auditing after every single compile just generates noise. When the audit resolves a conflict it records the resolution in its report (under "Resolved Reconciliations") and deletes the cleared row from the queue — so `_pending-reconciliation.md` only ever holds open debt, and the audit deletes the file once the last row clears.

## Conventions
- Always use [[wiki links]] when referencing other notes
- File names: lowercase with hyphens (e.g., ai-agent-overview.md)
- Keep articles concise — bullet points over paragraphs
- Indexes (`_master-index.md` and every topic `_index.md`) are markdown tables, not bullet lists — group large topic indexes into `##` sections
- Always include a ## Key Takeaways section in wiki articles
