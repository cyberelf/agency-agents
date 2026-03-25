# GitHub Copilot Integration

The Agency now ships as a GitHub Copilot-compatible skill catalog in `skills/`.
Each skill includes a `SKILL.md` entrypoint plus `references/` for the specialist material it can route across.

## Install

```bash
# Copy all project-scoped skills into a personal GitHub Copilot skills directory
cp -r skills/* ~/.copilot/skills/

# Or install the broader tool integrations maintained by this repo
./scripts/convert.sh
./scripts/install.sh --tool copilot
```

## Activate a Skill

In any GitHub Copilot session, reference a skill by name:

```
Use the engineering skill to route this full-stack implementation request.
```

```
Use the testing skill to verify this feature is production-ready.
```

## Skill Directory

Project-scoped skills live in `skills/`. See the [main README](../../README.md)
for the full catalog and migration notes.
