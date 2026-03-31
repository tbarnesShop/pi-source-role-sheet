---
name: source-role-sheet
description: Run an end-to-end recruiting sourcing workflow that turns a role brief into batched prospects, resolves public LinkedIn profile URLs, optionally enriches verified profiles via Gumloop, and creates or updates a Google Sheet using gws when Sheets wrappers are unreliable. Use when asked to source a role to a sheet, build a sourcing list, enrich an existing prospect sheet, or run repeatable sourcing ops.
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
4. Optionally enrich verified LinkedIn profiles with Gumloop-derived profile data.
5. Write a clean artifact to Google Sheets.
6. Return the sheet URL, ranges written, counts, and verification gaps.

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
- whether to run deep LinkedIn enrichment on verified profile URLs
- if enriching, whether there is an existing Gumloop flow or API configuration to use
- if enriching an existing sheet, which rows or batches should be enriched

If the user does not specify:
- default to **public-source-only**
- default batch size to **20**
- default to creating a new sheet
- default to resolving LinkedIn URLs during the same run
- default deep LinkedIn enrichment to **off** unless the user asks for it, because it is slower and may consume Gumloop credits

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
   - use Perplexity or other web search only to discover or verify the public LinkedIn profile URL
   - do **not** use Perplexity/perplexity_fetch as the source of record for LinkedIn profile contents
   - when Gumloop enrichment is requested and configured, call the explicit Gumloop flow/API for rows with verified LinkedIn URLs and map the returned fields into sheet columns

3. `workspace-executor`
   - create or update the spreadsheet artifact
   - use `gws` via `bash` for structural changes, create, multi-row writes, and verification

Use `team-brief-researcher` or `shopify-researcher` only if team context materially changes the target profile.

## Default artifact shape

### Spreadsheet title

For new spreadsheets, use:
- `<Role or Req Name> Sourcing - YYYY-MM-DD`

### Tabs

Create these tabs unless the user asks for something different:
- `Prospects`
- `Brief`

### Prospects columns

Use this exact default header row:

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

If the user asks for deep LinkedIn enrichment, append these optional columns after the default header row rather than replacing it:

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

Translate this schema into the spreadsheet columns above.

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

### 3.5) Optional deep LinkedIn enrichment via Gumloop

Run this step only when the user asks for richer profile data or asks to enrich an existing sheet.

Preconditions:
- the row has a verified `LinkedIn Profile` URL
- a Gumloop flow/API path is available
- the user is okay with the added latency and credit usage
- prefer loading Gumloop credentials from environment variables:
  - `GUMLOOP_API_KEY`
  - `GUMLOOP_USER_ID`
  - `GUMLOOP_SAVED_ITEM_ID`

Critical distinction:
- use Perplexity or other web search only to **find/verify the LinkedIn URL**
- do **not** rely on Perplexity/perplexity_fetch to read LinkedIn profile page contents directly
- once the LinkedIn URL is verified, use the Gumloop enrichment flow as the source for profile fields

Recommended API pattern:
- start the Gumloop pipeline with a single input named `LinkedIn URL`
- pass the verified LinkedIn URL via `pipeline_inputs`
- use `GUMLOOP_API_KEY`, `GUMLOOP_USER_ID`, and `GUMLOOP_SAVED_ITEM_ID` from the environment when available
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
- when updating an existing sheet, append the enrichment columns after the current sourcing columns unless the user asks for a different layout
- preserve user-added columns whenever practical
- if a Gumloop run fails for a row, leave the row in place and record a short note rather than blocking the entire batch
- prefer batch sizes small enough to verify easily, especially on the first run

### 4) Create or update the spreadsheet

Use `workspace-executor`.

For Sheets operations:
- inspect metadata first for unfamiliar spreadsheets
- prefer `gws` via `bash` for create, batch writes, structural changes, and large updates
- use `google_sheets` directly only for simple reads/writes when the method shape is obvious
- if the wrapper is unclear or fails once, switch to `gws`

Preferred sequence:
1. create spreadsheet if needed
2. ensure `Prospects` and `Brief` tabs exist
3. write headers to `Prospects`
4. write brief rows to `Brief`
5. write prospect rows in one batch update when practical
6. if deep LinkedIn enrichment is requested, append the enrichment headers and write only the rows being enriched
7. verify by reading back the written range

### 5) Verify and report

After writing:
- read back the key written range(s)
- confirm row counts
- call out any `NOT FOUND` or manual-review rows
- if enrichment was run, call out any rows that failed Gumloop enrichment or were skipped due to missing LinkedIn URLs
- return the sheet URL / ID

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
    {"range": "'\''Prospects'\''!A1", "values": [["Batch", "Name", "LinkedIn Profile", "Current company", "Likely current title", "Public location", "Why relevant", "Confidence", "Segment", "Verification notes"]]},
    {"range": "'\''Brief'\''!A1", "values": [["Field", "Value"], ["Role / req", "..."]]}
  ]
}'
```

### Verify a write

```bash
gws sheets +read --spreadsheet "SPREADSHEET_ID" --range "'Prospects'!A1:J10"
```

## Output contract

Return all of the following:
- objective
- scope / constraints used
- sheet title
- spreadsheet ID and URL
- batches produced and total prospect count
- whether deep LinkedIn enrichment was run
- ranges written or updated
- rows with `NOT FOUND` or `Needs manual review`
- rows skipped or failed during enrichment, if any
- concise next-step recommendations

## Guardrails

- This is research support, not a hiring decision.
- Prefer public-source-only evidence unless the user asks otherwise.
- Distinguish facts from inference.
- Do not invent candidate details or URLs.
- When the market is thin, separate direct-fit from adjacent-fit profiles.
- If the user asks for additional prospects, exclude already-listed names.
- If updating an existing sheet, preserve user-added columns unless explicitly asked to restructure them.
- Deep LinkedIn enrichment should be opt-in by default because it may consume Gumloop credits and returns long-form text.
- Do not run Gumloop enrichment on weakly matched or unverified LinkedIn URLs.
- If Gumloop enrichment is the intended path, do not fall back to direct LinkedIn page fetching via Perplexity/perplexity_fetch; stop and ask for the Gumloop webhook/API details instead.
- If `GUMLOOP_API_KEY`, `GUMLOOP_USER_ID`, or `GUMLOOP_SAVED_ITEM_ID` are missing, stop and ask for the missing config rather than improvising.
