# Wiki Generator — Beginner's Guide

A simple, step-by-step guide to setting up your own AI-powered knowledge base using the `wiki-generator` skill.

No terminal. No coding. Just the Claude Code desktop app.

---

## What You'll Need

- The **Claude Code desktop app** installed
- About **10 minutes**

---

## Step 1: Create a Folder for Your Wiki

Pick a spot on your computer where you'd like your wiki to live (for example, your Desktop).

1. Create a new folder there.
2. Name it whatever you want — e.g. `My Wiki`, `Gardening Notes`, `Work Knowledge Base`.

That folder is the **home** of your wiki. Everything will live inside it.

---

## Step 2: Open the Folder in Claude Code

1. Launch the **Claude Code desktop app**.
2. Open the folder you just created.

<img width="401" height="162" alt="Screenshot 2026-05-27 at 15 09 01" src="https://github.com/user-attachments/assets/fffbde41-beec-4647-9b3d-734fa5ead6c9" />

You should now see an empty project with a chat box ready to go.

---

## Step 3: Install the Wiki Generator Skill

Copy and paste the following prompt into Claude Code and send it:

> Please download the repo at **https://github.com/davron-design/wiki-generator** and install it as a **project-scoped skill** in this folder. Put the skill files under `.claude/skills/wiki-generator/` so the skill only applies to this project. Once it's installed, list the skills so I can confirm it's ready to use.


#### If Claude asks for permission, just **Always Allow**. 
<img width="824" height="222" alt="Screenshot 2026-05-27 at 15 18 46" src="https://github.com/user-attachments/assets/b41f5cd3-b481-45fb-8d38-4ec73f8349e5" />


Claude will:
- Fetch the skill files from the repo
- Place them in the right spot inside your folder
- Confirm the skill is installed

You only need to do this once per wiki.

---

## Step 4: Build Your Wiki Project

Now that the skill is installed, scaffold your wiki.

1. In Claude Code, type:
   ```
   /wiki-generator
   ```
2. Claude will create three folders for you:
   - **`raw/`** — where you drop source material (articles, notes, research)
   - **`wiki/`** — where the polished knowledge base lives
   - **`output/`** — where reports and query results show up

It will also install three companion skills (`raw-compile`, `audit-wiki` and `update-wiki`) automatically.

---

## Step 5: Add Material to `raw/`

This is where you feed your wiki.

1. Open the `raw/` folder.
2. Drop in any material you want included. For example:
   - Articles you've saved (`.md` or `.txt` files)
   - Notes you've written
   - Research clippings, transcripts, PDFs (as text)
3. Add as many files as you want. Don't worry about organizing them — that's Claude's job.

---

## Step 6: Compile the Raw Material

Now tell Claude to read your raw files and turn them into a clean wiki.

1. In Claude Code, simply say:
   ```
   compile
   ```
2. Claude will:
   - Read every file in `raw/`
   - Group the material by topic
   - Write clean wiki articles into `wiki/`
   - Link articles together with `[[wiki links]]`
   - Move the compiled raw files into an archive folder so you know what's been processed

Sit back — this part is automatic.

---

## Step 7: Audit Your Wiki

Once your wiki is built, check it for gaps or inconsistencies.

1. In Claude Code, say:
   ```
   audit
   ```
2. Claude will scan the wiki and produce a **numbered audit report** in `output/_audits/`. The report points out:
   - Missing cross-links between related articles
   - Topics that feel thin and could use more material
   - Inconsistencies between articles
3. The audit is **report-only** by default — it won't change anything until you say so.

---

## Step 8: Keep Your Wiki Up to Date

The compile and audit rules improve over time. Your wiki holds its own copy of them, so it
stays on whatever version it was built with until you refresh it.

1. In Claude Code, say:
   ```
   update
   ```
2. Claude will check the version your wiki is running against the latest published one, show
   you what changed since then, and ask before writing anything.
3. It only ever rewrites four files: `CLAUDE.md` and the three skills. Your articles, your raw
   sources, and your audit reports are never touched.
4. Restart Claude Code afterwards. Skills are read when a session starts, so the new rules
   apply from the next session on.

Run this whenever you want, or when someone tells you the rules changed. If your wiki is
already current, `update` says so and stops.

### If `update` doesn't do anything

Wikis built before this feature existed have no `update-wiki` skill to run. Paste this into
Claude Code from inside your wiki folder, once:

> Download `templates/update-wiki.SKILL.md` from
> https://github.com/davron-design/wiki-generator and save it as
> `.claude/skills/update-wiki/SKILL.md` in this folder. Then tell me to restart the session
> and say `update`.

After that one paste, the skill keeps itself current along with everything else.

---

## What's Next?

- **Add more material** — keep dropping files into `raw/` and saying `compile` whenever you want to grow the wiki.
- **Ask questions** — once your wiki has content, you can ask Claude things like "What does the wiki say about X?" and it'll pull answers from your knowledge base.
- **Re-audit periodically** — as your wiki grows, running `audit` keeps it healthy.
- **Update now and then** by saying `update`, which pulls the latest compile and audit rules into your wiki.

---

## Quick Reference

| Action | What to type |
|---|---|
| Set up a new wiki | `/wiki-generator` |
| Compile new material | `compile` |
| Audit the wiki | `audit` |
| Update the wiki's rules | `update` |
| Ask the wiki a question | Just ask in plain English |

---

That's the whole workflow. Drop stuff in `raw/`, compile, and your wiki grows itself.
