# pi-source-role-sheet

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub repo](https://img.shields.io/badge/GitHub-pi--source--role--sheet-181717?logo=github)](https://github.com/tbarnesShop/pi-source-role-sheet)

Shareable Pi skill pack for sourcing a role into a recruiter-friendly Google Sheet.

## Quick start

```bash
git clone https://github.com/tbarnesShop/pi-source-role-sheet.git
cd pi-source-role-sheet
./install.sh
```

Then restart Pi if it was already running and ask something like:

- `Source a batch of 20 senior backend engineers in Toronto into a new Google Sheet`
- `Create a prospect sheet for staff data engineers in North America`
- `Enrich this existing prospect sheet with verified LinkedIn URLs`

## Step-by-step install

### 1. Confirm Shopify Pi is available

This skill pack is designed to run with Shopify Pi via:

```bash
devx pi --version
devx pi
```

### 2. Install the Pi extensions you need

This skill relies on Google Workspace access for Sheets writes and Perplexity for public LinkedIn URL discovery.

A common internal setup is to install the shared Pi extension bundle:

```bash
pi install https://github.com/shopify-playground/shop-pi-fy
```

Then start Pi with:

```bash
devx pi
```

### 3. Clone this repo and install the skill pack

```bash
git clone https://github.com/tbarnesShop/pi-source-role-sheet.git
cd pi-source-role-sheet
./install.sh
```

This copies the skill and bundled agents into `~/.pi/agent/...`.

### 4. Authenticate the tools you plan to use

At minimum, make sure your Pi environment can access:

- Google Workspace / Sheets
- Perplexity

If Pi was already running before install, restart it with:

```bash
devx pi
```

### 5. Optional: set up Gumloop for deep LinkedIn enrichment

Only do this if you want deep LinkedIn enrichment. The default sourcing workflow does not require it.

Set up the Gumloop pipeline here:

- https://www.gumloop.com/pipeline?workbook_id=3Pku5WWmdYaZ4nHUxjntJP

Then export these environment variables before launching Pi:

```bash
export GUMLOOP_API_KEY=...
export GUMLOOP_USER_ID=...
export GUMLOOP_SAVED_ITEM_ID=...
```

You can copy `.env.example` as a starting point.

### 6. Test the install

Try one of these prompts in Pi:

- `Source a batch of 20 senior backend engineers in Toronto into a new Google Sheet`
- `Create a prospect sheet for staff data engineers in North America`
- `Enrich this existing prospect sheet with verified LinkedIn URLs`

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

Gumloop pipeline to configure for enrichment:

- https://www.gumloop.com/pipeline?workbook_id=3Pku5WWmdYaZ4nHUxjntJP

## Install

Clone the repo and run:

```bash
git clone https://github.com/tbarnesShop/pi-source-role-sheet.git
cd pi-source-role-sheet
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
pi-source-role-sheet/
├── README.md
├── LICENSE
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
