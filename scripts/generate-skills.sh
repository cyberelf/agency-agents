#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"

SOURCE_DIRS=(
  academic
  design
  engineering
  game-development
  marketing
  paid-media
  sales
  product
  project-management
  testing
  support
  spatial-computing
  specialized
)

info() {
  printf '[OK] %s\n' "$*"
}

yaml_quote() {
  local value="$1"
  value=${value//\'/\'\'}
  printf "'%s'" "$value"
}

title_case() {
  echo "$1" | tr '-' ' ' | awk '{
    for (i = 1; i <= NF; i++) {
      $i = toupper(substr($i, 1, 1)) substr($i, 2)
    }
    print
  }'
}

get_field() {
  local field="$1" file="$2"
  awk -v f="$field" '
    /^---$/ { fm++; next }
    fm == 1 && $0 ~ "^" f ": " { sub("^" f ": ", ""); print; exit }
  ' "$file"
}

get_body() {
  awk 'BEGIN{fm=0} /^---$/{fm++; next} fm>=2{print}' "$1"
}

drop_first_h1() {
  awk '
    BEGIN { dropped = 0; started = 0 }
    {
      if (!started && $0 ~ /^[[:space:]]*$/) {
        next
      }
      if (!dropped && $0 ~ /^#[[:space:]]+/) {
        dropped = 1
        started = 1
        next
      }
      started = 1
      print
    }
  '
}

replace_terms_for_strategy() {
  sed \
    -e 's/Agents Orchestrator/Strategy Team Orchestrator/g' \
    -e 's/Agent Coordination Matrix/Team Coordination Matrix/g' \
    -e 's/agent coordination/team coordination/g' \
    -e 's/Agent roster/Team skill roster/g' \
    -e 's/Agent Roster/Team Skill Roster/g' \
    -e 's/agents/teams/g' \
    -e 's/Agents/Teams/g' \
    -e 's/agent/team/g' \
    -e 's/Agent/Team/g'
}

team_description() {
  case "$1" in
    academic)
      printf '%s\n' 'research, analysis, and worldbuilding across anthropology, geography, history, narrative, and psychology'
      ;;
    design)
      printf '%s\n' 'brand, UI, UX, visual storytelling, and creative direction'
      ;;
    engineering)
      printf '%s\n' 'software delivery across frontend, backend, data, AI, infrastructure, security, and platform engineering'
      ;;
    game-development)
      printf '%s\n' 'game systems, level design, narrative, technical art, and audio production'
      ;;
    marketing)
      printf '%s\n' 'growth, content, social, regional platform marketing, and audience development'
      ;;
    paid-media)
      printf '%s\n' 'campaign strategy, auditing, creative, measurement, and media buying'
      ;;
    sales)
      printf '%s\n' 'pipeline generation, discovery, deal strategy, proposals, pre-sales, and coaching'
      ;;
    product)
      printf '%s\n' 'discovery, prioritization, product leadership, research, and behavior design'
      ;;
    project-management)
      printf '%s\n' 'program coordination, operations, planning, experimentation, and delivery governance'
      ;;
    testing)
      printf '%s\n' 'quality assurance, evidence collection, release readiness, and test result analysis'
      ;;
    support)
      printf '%s\n' 'customer support operations and response quality'
      ;;
    spatial-computing)
      printf '%s\n' 'XR, spatial UI, immersive development, visionOS, and specialized spatial platforms'
      ;;
    specialized)
      printf '%s\n' 'cross-domain specialist workflows that do not fit a single delivery team'
      ;;
    strategy)
      printf '%s\n' 'multi-team orchestration across discovery, strategy, build, QA, launch, and operations'
      ;;
    *)
      printf '%s\n' 'related specialist capabilities from this folder'
      ;;
  esac
}

write_specialist_reference() {
  local source_file="$1"
  local target_file="$2"
  local division="$3"
  local name description emoji vibe body

  name="$(get_field "name" "$source_file")"
  description="$(get_field "description" "$source_file")"
  emoji="$(get_field "emoji" "$source_file")"
  vibe="$(get_field "vibe" "$source_file")"
  body="$(get_body "$source_file" | drop_first_h1)"

  mkdir -p "$(dirname "$target_file")"

  cat > "$target_file" <<EOF
# $name

Use this reference when the task needs this specialist perspective inside the $division team.
EOF

  if [[ -n "$emoji" ]]; then
    printf -- '- Emoji: %s\n' "$emoji" >> "$target_file"
  fi

  if [[ -n "$vibe" ]]; then
    printf -- '- Vibe: %s\n' "$vibe" >> "$target_file"
  fi

  cat >> "$target_file" <<EOF
- Description: $description

## Detailed Guidance

$body
EOF
}

write_team_skill() {
  local division="$1"
  local skill_dir="$SKILLS_ROOT/$division"
  local title team_scope skill_description route_lines count file base name member_description

  title="$(title_case "$division")"
  team_scope="$(team_description "$division")"
  skill_description="Coordinate the $title team. Use this skill when the request belongs to $team_scope."

  mkdir -p "$skill_dir/references"

  route_lines=''
  count=0

  while IFS= read -r file; do
    base="$(basename "$file")"
    name="$(get_field "name" "$file")"
    member_description="$(get_field "description" "$file")"

    write_specialist_reference "$file" "$skill_dir/references/$base" "$division"

    route_lines+="- [${name}](./references/${base}) — ${member_description}"$'\n'
    count=$((count + 1))
  done < <(find "$REPO_ROOT/$division" -maxdepth 1 -type f -name '*.md' | sort)

  {
    cat <<EOF
---
name: $division
description: $(yaml_quote "$skill_description")
---

# $title Team

Use this skill when the request belongs to this team's capability area and you need the right specialist reference from that team.

## When to Use
- Use when the work belongs to this team's shared capability area: $team_scope.
- Use when the request should stay within one team skill instead of exploding into many single-specialist skills.
- Use when you need one or more adjacent references from this team to complete the work.

## Team Routes
EOF
    printf '%s' "$route_lines"
    cat <<EOF

## Procedure
1. Clarify the objective, constraints, audience, environment, and deliverable.
2. Pick the most relevant team reference from the list above.
3. Read only the reference files needed for the task under ./references/.
4. Combine multiple references only when the request genuinely spans adjacent specialties in this team.
5. Produce the requested output and call out tradeoffs, risks, and follow-up work when relevant.

## Notes
- Specialist references available: $count
EOF
  } > "$skill_dir/SKILL.md"
}

write_skill_groups_reference() {
  local target="$1"
  local division file name

  {
    printf '# Team Skills\n\n'
    printf 'Use these team skills when coordinating work across the skill catalog.\n\n'

    for division in "${SOURCE_DIRS[@]}"; do
      printf '## %s\n' "$(title_case "$division")"
      printf -- '- Team skill folder: `%s`\n' "$division"
      printf -- '- Capability area: %s\n' "$(team_description "$division")"
      printf -- '- Specialist references:\n'

      while IFS= read -r file; do
        name="$(get_field "name" "$file")"
        printf '  - %s\n' "$name"
      done < <(find "$REPO_ROOT/$division" -maxdepth 1 -type f -name '*.md' | sort)

      printf '\n'
    done
  } > "$target"
}

write_strategy_reference() {
  local source_file="$1"
  local target_file="$2"
  local title="$3"
  local body

  body="$(cat "$source_file" | replace_terms_for_strategy)"

  mkdir -p "$(dirname "$target_file")"

  cat > "$target_file" <<EOF
# $title

Use this reference when the strategy skill needs this playbook, runbook, or coordination document.

## Guidance

$body
EOF
}

write_strategy_skill() {
  local skill_dir="$SKILLS_ROOT/strategy"

  mkdir -p "$skill_dir/references"

  cat > "$skill_dir/SKILL.md" <<'EOF'
---
name: strategy
description: 'Coordinate multi-team delivery across discovery, strategy, build, QA, launch, and operations. Use this skill as the admin layer that orchestrates the team skills.'
---

# Strategy Team

Use this skill as the orchestration and administration layer for the team skills. Route the request to the right operating mode, runbook, playbook, and team combination.

## When to Use
- Use for work that spans multiple team skills or lifecycle phases.
- Use when sequencing, handoffs, quality gates, or escalation paths need explicit coordination.
- Use when the request is larger than any single team skill.

## Routing Logic
1. Start with [Quickstart](./references/QUICKSTART.md) to choose the operating mode.
2. Read [Core strategy](./references/nexus-strategy.md) for the full doctrine.
3. Use [Team skills](./references/skill-groups.md) to assemble the right team set.
4. Choose a scenario runbook when it matches the work:
   - [Startup MVP](./references/runbooks/scenario-startup-mvp.md)
   - [Enterprise feature](./references/runbooks/scenario-enterprise-feature.md)
   - [Marketing campaign](./references/runbooks/scenario-marketing-campaign.md)
   - [Incident response](./references/runbooks/scenario-incident-response.md)
5. Use the right phase playbook when running phase-by-phase:
   - [Phase 0 discovery](./references/playbooks/phase-0-discovery.md)
   - [Phase 1 strategy](./references/playbooks/phase-1-strategy.md)
   - [Phase 2 foundation](./references/playbooks/phase-2-foundation.md)
   - [Phase 3 build](./references/playbooks/phase-3-build.md)
   - [Phase 4 hardening](./references/playbooks/phase-4-hardening.md)
   - [Phase 5 launch](./references/playbooks/phase-5-launch.md)
   - [Phase 6 operate](./references/playbooks/phase-6-operate.md)
6. Use [Activation prompts](./references/coordination/agent-activation-prompts.md) and [Handoff templates](./references/coordination/handoff-templates.md) to coordinate work.

## Procedure
1. Define the desired outcome, scope, constraints, stakeholders, and quality bars.
2. Select the right operating mode, runbook, or phase playbook.
3. Choose the smallest sufficient set of team skills.
4. Coordinate execution, evidence-based handoffs, and retries when a gate fails.
5. Re-plan whenever priorities, risk, or dependencies change.
EOF

  write_strategy_reference "$REPO_ROOT/strategy/QUICKSTART.md" "$skill_dir/references/QUICKSTART.md" "Strategy Quickstart"
  write_strategy_reference "$REPO_ROOT/strategy/EXECUTIVE-BRIEF.md" "$skill_dir/references/EXECUTIVE-BRIEF.md" "Strategy Executive Brief"
  write_strategy_reference "$REPO_ROOT/strategy/nexus-strategy.md" "$skill_dir/references/nexus-strategy.md" "Strategy Core Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/coordination/agent-activation-prompts.md" "$skill_dir/references/coordination/agent-activation-prompts.md" "Coordination Activation Prompts"
  write_strategy_reference "$REPO_ROOT/strategy/coordination/handoff-templates.md" "$skill_dir/references/coordination/handoff-templates.md" "Coordination Handoff Templates"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-0-discovery.md" "$skill_dir/references/playbooks/phase-0-discovery.md" "Phase 0 Discovery Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-1-strategy.md" "$skill_dir/references/playbooks/phase-1-strategy.md" "Phase 1 Strategy Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-2-foundation.md" "$skill_dir/references/playbooks/phase-2-foundation.md" "Phase 2 Foundation Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-3-build.md" "$skill_dir/references/playbooks/phase-3-build.md" "Phase 3 Build Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-4-hardening.md" "$skill_dir/references/playbooks/phase-4-hardening.md" "Phase 4 Hardening Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-5-launch.md" "$skill_dir/references/playbooks/phase-5-launch.md" "Phase 5 Launch Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/playbooks/phase-6-operate.md" "$skill_dir/references/playbooks/phase-6-operate.md" "Phase 6 Operate Playbook"
  write_strategy_reference "$REPO_ROOT/strategy/runbooks/scenario-startup-mvp.md" "$skill_dir/references/runbooks/scenario-startup-mvp.md" "Startup MVP Runbook"
  write_strategy_reference "$REPO_ROOT/strategy/runbooks/scenario-enterprise-feature.md" "$skill_dir/references/runbooks/scenario-enterprise-feature.md" "Enterprise Feature Runbook"
  write_strategy_reference "$REPO_ROOT/strategy/runbooks/scenario-marketing-campaign.md" "$skill_dir/references/runbooks/scenario-marketing-campaign.md" "Marketing Campaign Runbook"
  write_strategy_reference "$REPO_ROOT/strategy/runbooks/scenario-incident-response.md" "$skill_dir/references/runbooks/scenario-incident-response.md" "Incident Response Runbook"
  write_skill_groups_reference "$skill_dir/references/skill-groups.md"
}

write_skills_readme() {
  cat > "$SKILLS_ROOT/README.md" <<'EOF'
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
EOF
}

main() {
  local division

  rm -rf "$SKILLS_ROOT"
  mkdir -p "$SKILLS_ROOT"

  for division in "${SOURCE_DIRS[@]}"; do
    write_team_skill "$division"
  done

  write_strategy_skill
  write_skills_readme

  info "Generated team skills in $SKILLS_ROOT"
}

main "$@"