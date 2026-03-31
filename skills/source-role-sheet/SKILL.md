---
name: source-role-sheet
description: Run an end-to-end recruiting sourcing workflow that turns a role brief into batched prospects, resolves public LinkedIn profile URLs, enriches verified profiles via Gumloop, and creates or updates a Google Sheet. Use when asked to source a role to a sheet, build a sourcing list, or enrich an existing prospect sheet.
---

# Source Role to Sheet

Turn a recruiting request into a recruiter-friendly spreadsheet artifact.

## When to use

Use this skill when the user wants any of the following:
- `/source-role <role>` style sourcing
- a Google Sheet of prospects
- candidate batches for a req or hiring need
- LinkedIn/public profile enrichment for sourced candidates
- enrichment of an existing prospect sheet using verified LinkedIn profile URLs
- repeatable sourcing operations that should leave behind an artifact

## Operating goals

1. Build a concise sourcing brief.
2. Generate a defensible set of public-source prospects.
3. Resolve LinkedIn profile URLs without hallucinating them.
4. Enrich verified LinkedIn profiles with Gumloop-derived profile data.
5. Write a clean artifact to Google Sheets.
6. Return the sheet URL, ranges written, counts, and verification gaps.

## Required setup assumptions

Before running this workflow, the environment should already have:
- Shopify Pi available via `devx pi`
- Google Workspace access in Pi for Sheets / Drive operations
- Perplexity access for public LinkedIn URL discovery and verification
- Gumloop configured for this pipeline:
  - `GUMLOOP_API_KEY`
  - `GUMLOOP_USER_ID`
  - `GUMLOOP_SAVED_ITEM_ID`

If Gumloop credentials are missing, stop and ask the user to finish setup before sourcing.

## Inputs to confirm

Confirm or infer these before execution:
- role / req / hiring need
- geography / remote constraints
- must-have backgrounds or domains
- adjacent titles that are acceptable
- excluded companies, titles, or names
- desired prospect count and batch size
- create a new sheet vs update an existing one
- whether the work must stay public-source-only
- whether LinkedIn URLs should be filled immediately
- if enriching an existing sheet, which rows or batches should be enriched
- whether team context materially changes the target profile and justifies a team brief

If the user does not specify:
- default to **public-source-only**
- default batch size to **20**
- default to creating a new sheet
- default to resolving LinkedIn URLs during the same run
- default to running Gumloop enrichment for rows with verified LinkedIn URLs during the same run

## Recommended agents

Use these agents deliberately:

1. `recruiting-researcher`
   - build the sourcing brief
   - generate candidate batches in the canonical schema
   - separate direct-fit and adjacent-fit prospects when useful

2. `candidate-enricher`
   - resolve LinkedIn profile URLs
   - add match confidence and short verification notes
   - prefer `NOT FOUND` or `Needs manual review` over weak guesses
   - only pass verified LinkedIn URLs into Gumloop-backed enrichment

3. `workspace-executor`
   - create or update the spreadsheet artifact
   - use Pi Google Workspace tools for straightforward Sheets / Drive work
   - use `gws` via `bash` for structural changes, create, multi-row writes, and verification

4. `team-brief-researcher`
   - use only when team context materially changes the target profile
   - keep the brief recruiter-safe and evidence-based

## Default artifact shape

### Spreadsheet title

For new spreadsheets, use:
- `<Role or Req Name> Sourcing - YYYY-MM-DD`

### Tabs

Create these tabs unless the user asks for something different:
- `Prospects`
- `Brief`

### Prospects columns

Use this default header row:

1. `Batch`
2. `Name`
3. `LinkedIn Profile`
4. `Current company`
5. `Likely current title`
6. `Public location`
7. `Why relevant`
8. `Confidence`
9. `Segment`
10. `Verification notes`
11. `First Name`
12. `Last Name`
13. `Job Title`
14. `Headline`
15. `About`
16. `City`
17. `State`
18. `Country`
19. `Work Experience`
20. `Education`

### Brief fields

Use a two-column key/value layout with rows for:
- `Role / req`
- `Objective`
- `Geography / constraints`
- `Target backgrounds`
- `Adjacent titles`
- `Target companies`
- `Disqualifiers / exclusions`
- `Batch plan`
- `Notes`
- `Generated at`

## Canonical row schema

Every prospect row should map cleanly to:
- `name`
- `linkedin_profile`
- `current_company`
- `likely_current_title`
- `public_location`
- `why_relevant`
- `confidence`
- `segment`
- `verification_notes`

Gumloop enrichment should map into:
- `first_name`
- `last_name`
- `job_title`
- `headline`
- `about`
- `city`
- `state`
- `country`
- `work_experience`
- `education`

## Workflow

### 1) Build the sourcing brief

Use `recruiting-researcher` to produce:
- role summary
- target backgrounds
- acceptable adjacent titles
- target companies or ecosystems
- direct-fit vs adjacent-fit sourcing angles
- disqualifiers / risky mismatches
- a first-pass batch plan

If team context materially changes the target profile, use `team-brief-researcher` to add:
- team mission
- major problem space
- collaborators / stakeholders
- sourcing angles shaped by the team context

Keep the brief concise and recruiter-safe.

### 2) Generate candidate batches

Ask `recruiting-researcher` for structured rows only when you are ready to write.

Guidance:
- batch prospects in groups of 20 unless the user asks otherwise
- label rows `Batch 1`, `Batch 2`, etc.
- include `Segment` values like `Direct fit`, `Adjacent fit`, `Stretch`, or another short recruiter-safe label
- keep `Why relevant` to one short sentence
- use confidence labels such as `High`, `Medium-High`, `Medium`, `Low`, `Needs verification`
- never present an invented URL or overstate certainty

### 3) Resolve LinkedIn profile URLs

Use `candidate-enricher` with `perplexity_search` for public profile lookup.

Preferred lookup pattern per candidate:
- exact name
- current company
- likely title
- geography if useful
- explicit instruction to return only a verified public LinkedIn URL or `NOT FOUND`

Good prompt shape:

> Find the best public LinkedIn profile URL for `<name>`, currently at `<company>`, likely title `<title>`, location `<location>` if known. Return the single best matching LinkedIn profile URL if it is publicly supported by the evidence. If the match is weak or ambiguous, return `NOT FOUND` and a short reason.

Rules:
- do not hallucinate LinkedIn URLs
- when evidence is ambiguous, use `NOT FOUND`
- use `Verification notes` for short match basis like `name+company+title`, `name+company`, or `needs manual review`
- only fill `LinkedIn Profile` when the match is at least reasonably supported
- Perplexity is acceptable for URL discovery/verification, but not for direct LinkedIn profile-content extraction

### 4) Enrich verified LinkedIn profiles via Gumloop

Run Gumloop enrichment for rows with verified `LinkedIn Profile` URLs.

Preconditions:
- the row has a verified `LinkedIn Profile` URL
- `GUMLOOP_API_KEY`, `GUMLOOP_USER_ID`, and `GUMLOOP_SAVED_ITEM_ID` are available
- the workflow uses the shared recruiter Gumloop pipeline

Critical distinction:
- use Perplexity or other web search only to **find/verify the LinkedIn URL**
- do **not** rely on Perplexity/perplexity_fetch to read LinkedIn profile page contents directly
- once the LinkedIn URL is verified, use the Gumloop enrichment flow as the source for profile fields

Recommended API pattern:
- start the Gumloop pipeline with a single input named `LinkedIn URL`
- pass the verified LinkedIn URL via `pipeline_inputs`
- use `GUMLOOP_API_KEY`, `GUMLOOP_USER_ID`, and `GUMLOOP_SAVED_ITEM_ID` from the environment
- poll the run until it reaches `DONE`
- read the returned outputs and map them into sheet columns
- if the run fails because `LinkedIn URL` is empty or invalid, mark the row for manual review rather than substituting web-search-derived profile content

Example webhook/API pattern:

```bash
curl -X POST "https://api.gumloop.com/api/v1/start_pipeline?api_key=$GUMLOOP_API_KEY&user_id=$GUMLOOP_USER_ID&saved_item_id=$GUMLOOP_SAVED_ITEM_ID" \
  -H 'Content-Type: application/json' \
  --data '{
    "pipeline_inputs": [
      {"input_name": "LinkedIn URL", "value": "https://www.linkedin.com/in/example"}
    ]
  }'

curl "https://api.gumloop.com/api/v1/get_pl_run?run_id=$RUN_ID&user_id=$GUMLOOP_USER_ID&api_key=$GUMLOOP_API_KEY"
```

Expected output fields from the current flow:
- `First Name`
- `Last Name`
- `Job Title`
- `Headline`
- `About`
- `City`
- `State`
- `Country`
- `Work Experience`
- `Education`

Execution guidance:
- enrich only rows that already have verified LinkedIn URLs
- preserve user-added columns whenever practical when updating an existing sheet
- if a Gumloop run fails for a row, leave the row in place and record a short note rather than blocking the entire batch
- keep first-run batch sizes small enough to verify easily

### 5) Create or update the spreadsheet

Use `workspace-executor`.

For Sheets operations:
- inspect metadata first for unfamiliar spreadsheets
- use Pi Google Workspace tools (`google_sheets`, `google_drive`) for simple reads, writes, and lookups
- use `gws` via `bash` for create, batch writes, structural changes, and larger updates
- if the wrapper is unclear or fails once, switch to `gws`

Preferred sequence:
1. create spreadsheet if needed
2. ensure `Prospects` and `Brief` tabs exist
3. write headers to `Prospects`
4. write brief rows to `Brief`
5. write prospect rows in one batch update when practical
6. write Gumloop enrichment values into the enrichment columns for rows that resolved successfully
7. verify by reading back the written range

### 6) Verify and report

After writing:
- read back the key written range(s)
- confirm row counts
- call out any `NOT FOUND` or manual-review rows
- call out any rows that failed Gumloop enrichment or were skipped due to missing LinkedIn URLs
- return the sheet URL / ID

## Google access model

Support both approaches:

### Standard employee path
- use Pi with Google Workspace tools enabled
- prefer this for straightforward Drive and Sheets operations

### CLI fallback path
- use `gws` via `bash`
- prefer this for spreadsheet creation, tab creation, batch writes, and structural operations

If both are available, use the simplest reliable path for the job.

## gws patterns

Use `gws` via `bash` when you need reliable Sheets execution.

### Inspect spreadsheet

```bash
gws sheets spreadsheets get --params '{
  "spreadsheetId": "SPREADSHEET_ID",
  "fields": "spreadsheetUrl,properties.title,sheets.properties"
}'
```

### Create spreadsheet

```bash
gws sheets spreadsheets create --json '{
  "properties": {"title": "ROLE Sourcing - YYYY-MM-DD"},
  "sheets": [
    {"properties": {"title": "Prospects"}},
    {"properties": {"title": "Brief"}}
  ]
}'
```

### Batch write values

```bash
gws sheets spreadsheets values batchUpdate --params '{
  "spreadsheetId": "SPREADSHEET_ID"
}' --json '{
  "valueInputOption": "USER_ENTERED",
  "data": [
    {"range": "'\''Prospects'\''!A1", "values": [["Batch", "Name", "LinkedIn Profile", "Current company", "Likely current title", "Public location", "Why relevant", "Confidence", "Segment", "Verification notes", "First Name", "Last Name", "Job Title", "Headline", "About", "City", "State", "Country", "Work Experience", "Education"]]},
    {"range": "'\''Brief'\''!A1", "values": [["Field", "Value"], ["Role / req", "..."]]}
  ]
}'
```

### Verify a write

```bash
gws sheets +read --spreadsheet "SPREADSHEET_ID" --range "'Prospects'!A1:T10"
```

## Output contract

Return all of the following:
- objective
- scope / constraints used
- sheet title
- spreadsheet ID and URL
- batches produced and total prospect count
- ranges written or updated
- rows with `NOT FOUND` or `Needs manual review`
- rows skipped or failed during Gumloop enrichment, if any
- concise next-step recommendations

## Guardrails

- This is research support, not a hiring decision.
- Prefer public-source-only evidence unless the user asks otherwise.
- Distinguish facts from inference.
- Do not invent candidate details or URLs.
- When the market is thin, separate direct-fit from adjacent-fit profiles.
- If the user asks for additional prospects, exclude already-listed names.
- If updating an existing sheet, preserve user-added columns unless explicitly asked to restructure them.
- Do not run Gumloop enrichment on weakly matched or unverified LinkedIn URLs.
- Do not fall back to direct LinkedIn page fetching via Perplexity/perplexity_fetch for profile-content extraction.
- If `GUMLOOP_API_KEY`, `GUMLOOP_USER_ID`, or `GUMLOOP_SAVED_ITEM_ID` are missing, stop and ask for the missing config rather than improvising.
