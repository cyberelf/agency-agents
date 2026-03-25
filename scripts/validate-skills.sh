#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"

errors=0
validated=0

info() {
  printf '[OK] %s\n' "$*"
}

fail() {
  printf '[ERR] %s\n' "$*" >&2
  errors=$((errors + 1))
}

get_field() {
  local field="$1" file="$2"
  awk -v f="$field" '
    /^---$/ { fm++; next }
    fm == 1 && $0 ~ "^" f ": " {
      sub("^" f ": ", "")
      print
      exit
    }
  ' "$file"
}

trim_quotes() {
  local value="$1"
  value="${value#\'}"
  value="${value%\'}"
  value="${value#\"}"
  value="${value%\"}"
  printf '%s\n' "$value"
}

validate_links() {
  local skill_dir="$1" skill_file="$2"
  local matches link target target_path

  matches=$(grep -oE '\[[^][]+\]\([^)]+\)' "$skill_file" || true)
  if [[ -z "$matches" ]]; then
    return
  fi

  while IFS= read -r link; do
    [[ -n "$link" ]] || continue
    target="$(printf '%s\n' "$link" | sed -E 's/^\[[^]]+\]\(([^)]+)\)$/\1/')"
    target="${target%%#*}"

    case "$target" in
      ''|'#'*|http://*|https://*|mailto:*|copilot-skill:*)
        continue
        ;;
    esac

    target_path="$skill_dir/$target"
    if [[ ! -e "$target_path" ]]; then
      fail "$(basename "$skill_dir") references missing path: $target"
    fi
  done <<< "$matches"
}

validate_skill() {
  local skill_dir="$1"
  local skill_name skill_file name description first_line fm_count

  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    fail "$skill_name is missing SKILL.md"
    return
  fi

  first_line="$(sed -n '1p' "$skill_file")"
  if [[ "$first_line" != '---' ]]; then
    fail "$skill_name SKILL.md does not start with YAML frontmatter"
  fi

  fm_count="$(grep -c '^---$' "$skill_file")"
  if (( fm_count < 2 )); then
    fail "$skill_name SKILL.md is missing a closing frontmatter delimiter"
  fi

  name="$(trim_quotes "$(get_field name "$skill_file")")"
  description="$(trim_quotes "$(get_field description "$skill_file")")"

  if [[ -z "$name" ]]; then
    fail "$skill_name SKILL.md is missing frontmatter name"
  elif [[ "$name" != "$skill_name" ]]; then
    fail "$skill_name folder does not match SKILL.md name '$name'"
  fi

  if [[ -z "$description" ]]; then
    fail "$skill_name SKILL.md is missing frontmatter description"
  fi

  if ! grep -q '^# ' "$skill_file"; then
    fail "$skill_name SKILL.md is missing a top-level heading"
  fi

  validate_links "$skill_dir" "$skill_file"

  validated=$((validated + 1))
}

main() {
  local skill_dir

  if [[ ! -d "$SKILLS_ROOT" ]]; then
    fail "Skills directory not found: $SKILLS_ROOT"
    exit 1
  fi

  while IFS= read -r skill_dir; do
    validate_skill "$skill_dir"
  done < <(find "$SKILLS_ROOT" -mindepth 1 -maxdepth 1 -type d | sort)

  if (( errors > 0 )); then
    printf '\n'
    fail "Skill validation failed: $errors issue(s) across $validated skill folder(s)"
    exit 1
  fi

  info "Validated $validated skill folder(s) in $SKILLS_ROOT"
}

main "$@"