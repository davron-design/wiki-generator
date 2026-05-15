---
name: raw-compile
description: Compile new source material from raw/ into the wiki/ knowledge base. Use when the user says "compile", drops new files into raw/, or asks to ingest research into the wiki. Reads each raw file, classifies it by topic, writes concise wiki articles with [[wiki links]], updates indexes, and archives compiled sources into a dated _complied folder.
---

# Raw → Wiki Compile

You are the librarian of the `wiki/` folder. This skill ingests new source material from `raw/` and turns it into well-linked wiki articles.

## When to invoke
- User says "compile" or "compile raw"
- New files have appeared in `raw/` and the user asks you to ingest them
- User asks you to add research/clipped articles to the knowledge base

## Before compiling, ask yourself
- **Topic fit**: Does this material extend an existing topic, or is it genuinely new ground? Defaulting to "new topic folder" fragments the wiki; defaulting to "existing folder" buries unrelated content under the wrong heading.
- **Article granularity**: Is this one article or several? A long raw file with three distinct sub-topics is three articles with cross-links, not one mega-article.
- **Cross-link surface**: What existing articles will reference this new one? If the answer is "none", the topic placement is probably wrong — reconsider before writing.

## Procedure

For each file currently in `raw/` (skip any `_<date>-complied/` archive folders; recurse into topic subfolders like `raw/<topic>/` if the user has pre-bucketed material):

1. **Read the raw file.** Extract the key claims, definitions, and any named entities.
2. **Classify the topic.** Read `wiki/_master-index.md` to see existing topic folders. Either:
   - Place the article inside an existing topic folder, or
   - Create a new topic folder (with its own `_index.md`) if no existing topic fits.
   - If the raw file genuinely spans multiple topics, create an article in **each** topic folder and cross-link them with `[[wiki links]]`.
3. **Write the wiki article** at `wiki/<topic>/<article-slug>.md`:
   - Filename: lowercase, hyphenated (e.g., `ai-agent-overview.md`).
   - Bullet points over paragraphs — keep it concise.
   - Use `[[wiki links]]` whenever you mention another concept that has (or should have) its own article.
   - **Always** include a `## Key Takeaways` section.
4. **Update the topic's `_index.md`** with a one-line entry pointing to the new article. If the topic folder is new, create `_index.md` first.
5. **Update `wiki/_master-index.md`** if you created a new topic or if the master index's description for that topic is now stale.
6. **Archive the source.** Once all raw files for this run are compiled, create `raw/_<YYYY-MM-DD>-complied/` (use today's date) and move every raw file you just compiled into it. Files that pre-existed inside an older `_*-complied/` folder stay where they are.

## Output to the user

After compiling, report:
- Which topics received articles (new vs. existing)
- Any new topic folders created
- The name of the dated archive folder
- Anything ambiguous you had to make a judgment call on (so the user can correct course)

## Anti-patterns

- **NEVER drop articles into `wiki/` root.** Every article belongs to a topic folder — `_master-index.md` is the only navigation entry point that lives at the root.
- **NEVER skip `[[wiki links]]` for cross-references.** Broken graphs are silent failures — the article reads correctly but the knowledge base loses its connective tissue.
- **NEVER move a raw file into `_<date>-complied/` until its article is written AND the topic index is updated.** Partial archives sever the source-to-article provenance trail.
- **NEVER overwrite an existing wiki article during compile.** If new raw material conflicts with or supersedes an existing article, flag it for the user. Updating existing content is an audit-time decision (run `audit-wiki`), not an ingest-time one.
- **NEVER skip the `## Key Takeaways` section.** It is the article's TL;DR — queries depend on it.

## Conventions reminder
- `[[wiki links]]` for every cross-reference — a link to an article that doesn't exist yet is fine; it flags a future write.
- Lowercase-hyphenated filenames.
- Bullets, not paragraphs.
- Every article ends with `## Key Takeaways`.
