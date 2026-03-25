# The Agency Skills

This directory is the project-scoped skill catalog for The Agency.

## Structure
- One team skill per top-level capability area
- Folder names align with the published skill catalog
- `SKILL.md` is the entrypoint the coding agent discovers and loads on demand
- `references/` contains the specialist guides and supporting documents for that team

## Notes
- Team skills route to specialist guidance inside each team instead of creating one skill per agent
- `strategy` is the admin/orchestration skill for multi-team work
- Reference filenames preserve stable specialist entry names within each skill

## Suggested Usage
- Load a team skill like `engineering`, `design`, or `marketing` when the request belongs to that folder's capability set
- Load `strategy` when a request spans multiple team skills, phases, or handoffs
