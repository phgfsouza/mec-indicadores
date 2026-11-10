# AGENTS.md

This file gives working instructions to coding agents operating in this repository.

## Purpose

This repository is for generating statistics and a descriptive report for a consulting job with the Ministry of Education.

## Repository map

- Main code lives in `code/`

- The pipeline entry point is `code/master.R`; shared functions live in `code/helpers/`

- Raw input data lives in `data/raw/`

- Cleaned data lives in `data/clean/`

- Documentation lives in `docs/`

- Logs live in `logs/`

- Indicator CSV files and diagnostic spreadsheets live in `results/`

- Spreadsheets with final results live in `produtos/planilhas/`

- The descriptive report, its template and filters live in `produtos/relatorio-1/`

- Report figures, plotting data and saved plot objects live in `produtos/relatorio-1/figuras/`


## General Working Rules

- Prefer small, reversible changes.
- Read the relevant files before editing them.
- Do not delete or overwrite raw data files in `data/raw/`.
- Do not rename files or move directories unless the task explicitly requires it.
- Keep changes focused on the user request; avoid unrelated cleanup.
- Preserve the existing project structure unless there is a strong reason to change it.
- Always read the Markdown files in `docs/`. 

## Code Style

- Follow existing project style and patterns.
- Prefer consistency with nearby code over generic best practices.
- Keep functions small unless there is a clear reason not to.
- Prefer clear, simple R code using tidyverse syntax over clever compact code.
- Use descriptive variable names.
- Add brief comments only when the logic is not obvious.
- All comments should be in Portuguese.
- Avoid introducing new dependencies unless necessary.

## Data Safety

- Treat files in `data/raw/` as immutable source data.
- Write derived data, exports, logs, and temporary artifacts outside `data/raw/`.
- If a task could modify source data, stop and ask first.
- Be careful with large files and avoid unnecessary copies.

## Scripts And Execution

- Prefer updating existing scripts in `code/` before creating new ones.
- If adding a new script, use a descriptive numeric prefix only if that matches the project pattern.
- Assume scripts may be run manually on Windows with PowerShell.
- Use relative paths within the repository when practical.
- Run `code/master.R` from the repository root; individual stages require their upstream inputs to exist.
- Keep script instructions consistent with actual inputs, outputs, filters and export behavior.

## Validation

- After making code changes, run the smallest reasonable validation step.
- If full validation is expensive, do a targeted check and note what was not verified.
- Do not claim a script ran successfully unless it was actually executed.

## Git And Change Safety

- Never discard or revert user changes unless explicitly asked.
- Avoid destructive commands.
- Keep commits focused if asked to prepare commits.

## Communication

- Briefly explain what changed, why it changed, and how it was checked.
- Flag assumptions clearly.
- If repository conventions are unclear, prefer the existing files over inventing new patterns.
