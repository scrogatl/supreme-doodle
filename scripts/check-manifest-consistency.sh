#!/usr/bin/env bash
# Audits k8s/deployments/*.yaml on the CURRENT branch of this repo for two
# kinds of drift we've hit before:
#
#   1. Tag-to-branch mismatch: a manifest's image tag should be this repo's
#      current branch name IF the sibling service repo actually has a branch
#      by that name - and should NOT be this branch name otherwise. (Catches
#      things like a manifest on `otel` referencing a sibling repo that has
#      no `otel` branch at all.)
#
#   2. Command-vs-framework mismatch: if a manifest's `command:` invokes
#      `flask` or `fastapi`, the sibling repo's app.py *at the branch/tag
#      matching the manifest's image tag* should actually be that framework.
#      (Catches e.g. a manifest running `fastapi run` against an image tag
#      whose source is actually a Flask app.)
#
# Read-only: never checks out or modifies any branch, just reads file
# content at other refs via `git show <ref>:<path>`. Exit code is the number
# of findings (0 = clean).
#
# Usage: ./scripts/check-manifest-consistency.sh
set -uo pipefail

SUPREME_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$SUPREME_ROOT/.." && pwd)"
CURRENT_BRANCH="$(git -C "$SUPREME_ROOT" branch --show-current)"

echo "Checking k8s/deployments/*.yaml against current branch: $CURRENT_BRANCH"
echo ""

findings=0

# image name -> (sibling repo dir, path to app.py within it, framework it should be)
repo_for_image() {
  case "$1" in
    doodle-hello)      echo "gitops-doodle-hello hello/src/app.py" ;;
    doodle-world)      echo "gitops-doodle-world world/src/app.py" ;;
    doodle-frontend)   echo "gitops-doodle-frontend frontend/src/app.py" ;;
    doodle-world-ruby) echo "gitops-doodle-world-ruby" ;;   # Ruby, no flask/fastapi check
    doodle-weather)    echo "gitops-doodle-weather" ;;       # .NET, no flask/fastapi check
    doodle-loadgen)    echo "gitops-doodle-loadgen loadgen/app.py" ;;
    *) echo "" ;;
  esac
}

# Does $1 (a local repo dir) have a branch named $2, local or remote?
has_branch() {
  local repo_dir=$1 branch=$2
  git -C "$repo_dir" branch -a 2>/dev/null | sed 's/^[* ]*//; s#remotes/origin/##' | grep -qx "$branch"
}

for manifest in "$SUPREME_ROOT"/k8s/deployments/*.yaml; do
  [ -f "$manifest" ] || continue
  rel="${manifest#"$SUPREME_ROOT"/}"

  # Grab the first non-commented `image:` line's value.
  image_line="$(grep -E '^\s*image:' "$manifest" | grep -v '^\s*#' | head -1)"
  [ -z "$image_line" ] && continue

  image_full="$(echo "$image_line" | sed -E 's/^\s*image:\s*//' | tr -d '"'"'"'' )"
  image_name="$(echo "$image_full" | sed -E 's#.*/##; s/:.*//')"
  image_tag="$(echo "$image_full" | sed -E 's/^.*://')"

  read -r repo_dir_name app_path <<< "$(repo_for_image "$image_name")"
  if [ -z "$repo_dir_name" ]; then
    echo "SKIP  $rel: unrecognized image '$image_name'"
    continue
  fi

  repo_dir="$REPO_ROOT/$repo_dir_name"
  if [ ! -d "$repo_dir/.git" ]; then
    echo "SKIP  $rel: $repo_dir_name not cloned locally"
    continue
  fi

  # --- Check 1: tag-to-branch consistency ---
  sibling_has_current_branch=false
  if has_branch "$repo_dir" "$CURRENT_BRANCH"; then
    sibling_has_current_branch=true
  fi

  if $sibling_has_current_branch && [ "$image_tag" != "$CURRENT_BRANCH" ]; then
    echo "FAIL  $rel: $repo_dir_name has a '$CURRENT_BRANCH' branch, but image tag is ':$image_tag', not ':$CURRENT_BRANCH'"
    findings=$((findings + 1))
  elif ! $sibling_has_current_branch && [ "$image_tag" = "$CURRENT_BRANCH" ]; then
    echo "FAIL  $rel: image tag is ':$CURRENT_BRANCH', but $repo_dir_name has no '$CURRENT_BRANCH' branch upstream"
    findings=$((findings + 1))
  fi

  # --- Check 2: command-vs-framework consistency ---
  [ -z "$app_path" ] && continue  # non-Python service, nothing to check

  command_line="$(grep -E '^\s*command:' "$manifest" | head -1)"
  expected_framework=""
  if echo "$command_line" | grep -qi "fastapi"; then
    expected_framework="fastapi"
  elif echo "$command_line" | grep -qi "flask"; then
    expected_framework="flask"
  fi
  [ -z "$expected_framework" ] && continue

  app_content="$(git -C "$repo_dir" show "$image_tag:$app_path" 2>/dev/null)"
  if [ -z "$app_content" ]; then
    app_content="$(git -C "$repo_dir" show "origin/$image_tag:$app_path" 2>/dev/null)"
  fi
  if [ -z "$app_content" ]; then
    echo "SKIP  $rel: couldn't read $app_path at ref '$image_tag' in $repo_dir_name (not fetched locally?)"
    continue
  fi

  actual_framework=""
  if echo "$app_content" | grep -qE "from fastapi import|FastAPI\("; then
    actual_framework="fastapi"
  elif echo "$app_content" | grep -qE "from flask import"; then
    actual_framework="flask"
  fi

  if [ -n "$actual_framework" ] && [ "$actual_framework" != "$expected_framework" ]; then
    echo "FAIL  $rel: command runs '$expected_framework', but $repo_dir_name's $app_path at ':$image_tag' is actually $actual_framework"
    findings=$((findings + 1))
  fi
done

echo ""
if [ "$findings" -eq 0 ]; then
  echo "No inconsistencies found."
else
  echo "$findings inconsistenc$([ "$findings" -eq 1 ] && echo y || echo ies) found."
fi
exit "$findings"
