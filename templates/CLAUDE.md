# Knowledge Base — Vault Conventions

## Vault Structure
- /raw — source material, clipped articles, research (the input zone)
- /wiki — LLM-compiled knowledge base (see Wiki System below)
- /output — query results and generated reports

## Wiki System
You are the librarian of the wiki/ folder. You write and maintain everything in it.

### Structure
- wiki/_master-index.md is the entry point — lists every topic with a one-line description.
- Each topic gets its own subfolder with its own _index.md listing all articles.

### Querying
When answering questions against the knowledge base:
1. Read wiki/_master-index.md first to find the right topic
2. Read that topic's _index.md to find relevant articles
3. Read the specific articles
4. Synthesize the answer
5. If the wiki doesn't offer any knowledge, don't make anything up and be sure to mention it

### Compiling
When the user says "compile" or drops new material in raw/, use the `raw-compile` skill.

### Auditing
When the user says "audit" or "lint", use the `audit-wiki` skill.

## Conventions
- Always use [[wiki links]] when referencing other notes
- File names: lowercase with hyphens (e.g., ai-agent-overview.md)
- Keep articles concise — bullet points over paragraphs
- Always include a ## Key Takeaways section in wiki articles
