# source-role-sheet-pack

Shareable Pi skill pack for sourcing a role into a recruiter-friendly Google Sheet.

## What’s included

- `skills/source-role-sheet/SKILL.md`
- `agents/recruiting-researcher.md`
- `agents/candidate-enricher.md`
- `agents/workspace-executor.md`
- `install.sh`
- `.env.example`

## What this skill does

The `source-role-sheet` skill helps turn a recruiting request into a spreadsheet artifact by:

1. building a sourcing brief
2. generating prospect batches
3. resolving public LinkedIn profile URLs
4. optionally enriching verified LinkedIn URLs with Gumloop
5. creating or updating a Google Sheet

## Requirements

For someone using Pi for the first time, they will need:

- Pi installed
- access to the skill and agent files from this repo
- Google Workspace auth configured so Pi / `gws` can read and write Sheets
- Perplexity tool access for LinkedIn URL lookup and verification
- optional Gumloop credentials for deep LinkedIn enrichment

Optional Gumloop environment variables:

- `GUMLOOP_API_KEY`
- `GUMLOOP_USER_ID`
- `GUMLOOP_SAVED_ITEM_ID`

## Install

Clone the repo and run:

```bash
git clone <YOUR-REPO-URL>
cd source-role-sheet-pack
./install.sh
```

This installs the files into:

- `~/.pi/agent/skills/source-role-sheet/SKILL.md`
- `~/.pi/agent/agents/recruiting-researcher.md`
- `~/.pi/agent/agents/candidate-enricher.md`
- `~/.pi/agent/agents/workspace-executor.md`

## Usage

After installation, ask Pi naturally, for example:

- `Source a batch of 20 senior backend engineers in Toronto into a new Google Sheet`
- `Create a prospect sheet for staff data engineers in North America`
- `Enrich this existing prospect sheet with verified LinkedIn URLs`

If skill commands are enabled, users can also invoke:

```bash
/skill:source-role-sheet
```

If needed, enable skill commands in Pi settings:

```json
{
  "enableSkillCommands": true
}
```

## Notes

- Deep LinkedIn enrichment is intentionally opt-in.
- The skill is designed to prefer public-source-only evidence by default.
- The skill depends on the three bundled custom agents, so share them together.

## Updating

Pull the latest repo changes and rerun:

```bash
./install.sh
```

## Repo structure

```text
source-role-sheet-pack/
├── README.md
├── install.sh
├── .env.example
├── agents/
│   ├── recruiting-researcher.md
│   ├── candidate-enricher.md
│   └── workspace-executor.md
└── skills/
    └── source-role-sheet/
        └── SKILL.md
```
