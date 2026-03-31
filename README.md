# pi-source-role-sheet

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub repo](https://img.shields.io/badge/GitHub-pi--source--role--sheet-181717?logo=github)](https://github.com/tbarnesShop/pi-source-role-sheet)

Shareable Pi skill pack for turning a recruiting request into a recruiter-friendly Google Sheet with verified LinkedIn URLs and Gumloop enrichment.

## Quick start

```bash
git clone https://github.com/tbarnesShop/pi-source-role-sheet.git
cd pi-source-role-sheet
./install.sh
```

Then complete Gumloop setup, export your Gumloop env vars, and run:

```bash
./scripts/check-setup.sh
```

Then launch Pi:

```bash
devx pi
```

## Day-one package goals

This repo is designed to be usable by recruiters on day one, without relying on the author's personal Pi setup.

That means the repo bundles:
- the main skill
- all default workflow agents used by the package
- Gumloop setup helpers
- install and preflight scripts

It also keeps the default workflow centered on:
- Shopify Pi via `devx pi`
- Google Workspace access
- Perplexity for LinkedIn URL lookup
- Gumloop for profile enrichment

## What’s included

- `skills/source-role-sheet/SKILL.md`
- `agents/recruiting-researcher.md`
- `agents/candidate-enricher.md`
- `agents/workspace-executor.md`
- `agents/team-brief-researcher.md`
- `install.sh`
- `.env.example`
- `scripts/parse-gumloop-webhook.sh`
- `scripts/check-setup.sh`

## Requirements

### Required

- Shopify Pi available via `devx pi`
- Google Workspace access for Sheets / Drive operations
- Perplexity access for public LinkedIn URL discovery and verification
- Gumloop configured for the recruiter enrichment pipeline
- Gumloop env vars exported in the shell before launching Pi:
  - `GUMLOOP_API_KEY`
  - `GUMLOOP_USER_ID`
  - `GUMLOOP_SAVED_ITEM_ID`

### Recommended

- `shop-pi-fy` installed in Pi
- `gws` CLI installed and authenticated as a reliable fallback for spreadsheet creation and batch writes

## Google Workspace: two supported access paths

This package supports both of these approaches.

### 1. Standard employee Pi setup

Use Pi with Google Workspace tools enabled, for example through your normal Pi extension bundle.

Best for:
- normal Sheets / Drive reads and writes
- common recruiter workflows
- users who already use Google tools in Pi

### 2. `gws` CLI fallback

Use `gws` through `bash`.

Best for:
- spreadsheet creation
- creating tabs
- large batch writes
- structural or more exact Sheets API operations
- cases where wrapper parameters are unclear or the wrapper fails once

### Recommendation

If you already have the standard Google Workspace Pi setup, that is enough for most runs.
If you also have `gws`, the package can use it as the more reliable fallback for heavier spreadsheet operations.

## Step-by-step install

### 1. Confirm Shopify Pi is available

```bash
devx pi --version
devx pi
```

### 2. Install the Pi extensions you need

A common internal setup is:

```bash
pi install https://github.com/shopify-playground/shop-pi-fy
```

This helps provide Google Workspace and Perplexity tooling in Pi.

### 3. Clone this repo and install the skill pack

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
- `~/.pi/agent/agents/team-brief-researcher.md`

### 4. Configure the required Gumloop pipeline

Copy this Gumloop pipeline template into your own Gumloop workspace:

- https://www.gumloop.com/pipeline?workbook_id=3Pku5WWmdYaZ4nHUxjntJP

In your copied pipeline:
1. find the webhook / start pipeline URL
2. copy that URL
3. run:

```bash
./scripts/parse-gumloop-webhook.sh 'https://api.gumloop.com/api/v1/start_pipeline?api_key=...&user_id=...&saved_item_id=...'
```

That prints the export commands for:
- `GUMLOOP_API_KEY`
- `GUMLOOP_USER_ID`
- `GUMLOOP_SAVED_ITEM_ID`

Run those exports in your shell before launching Pi.

You can also copy `.env.example` as a starting point.

### 5. Run the local preflight check

```bash
./scripts/check-setup.sh
```

This checks for:
- `devx pi`
- installed skill/agent files
- Gumloop env vars
- `shop-pi-fy` visibility in `pi list` when possible
- `gws` presence and a basic Google Drive auth check when available

### 6. Launch Pi

```bash
devx pi
```

If Pi was already running before installation or env-var setup, restart it first.

## Usage

After installation, ask Pi naturally, for example:

- `Source a batch of 20 senior backend engineers in Toronto into a new Google Sheet and enrich verified LinkedIn URLs with Gumloop`
- `Create a prospect sheet for staff data engineers in North America with Gumloop-enriched profiles`
- `Enrich this existing prospect sheet with verified LinkedIn URLs and Gumloop profile data`

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

## Security notes

- The Gumloop webhook URL contains credential-like query params. Treat it as sensitive.
- Do not commit real Gumloop credentials or webhook URLs to git.
- The workflow is research support, not a hiring decision.
- Public-source evidence is the default unless the recruiter supplies additional material.

## Updating

Pull the latest repo changes and rerun:

```bash
./install.sh
```

Then rerun:

```bash
./scripts/check-setup.sh
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
│   ├── workspace-executor.md
│   └── team-brief-researcher.md
├── scripts/
│   ├── check-setup.sh
│   └── parse-gumloop-webhook.sh
└── skills/
    └── source-role-sheet/
        └── SKILL.md
```
