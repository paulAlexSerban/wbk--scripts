#!/bin/bash
# Source from ~/.bashrc or ~/.zshrc. Do not execute.
# Switches Git identity / SSH / GPG from ~/.git_profiles.json by path or via `gprofile`.

GIT_CONFIG_JSON="${GIT_CONFIG_JSON:-$HOME/.git_profiles.json}"

set_git_profile() {
  local key=$1

  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is not installed. Install with 'brew install jq' or 'sudo apt install jq'."
    return 1
  fi

  if [ ! -f "$GIT_CONFIG_JSON" ]; then
    echo "Error: config not found at $GIT_CONFIG_JSON"
    return 1
  fi

  if [ -z "$key" ]; then
    echo "Usage: gprofile <profile>"
    return 1
  fi

  local exists
  exists=$(jq -r --arg key "$key" 'has($key)' "$GIT_CONFIG_JSON")
  if [ "$exists" != "true" ]; then
    echo "Profile '$key' not found in $GIT_CONFIG_JSON"
    return 1
  fi

  local name email ssh_key gpg_key expanded_key
  name=$(jq -r --arg key "$key" '.[$key].name // empty' "$GIT_CONFIG_JSON")
  email=$(jq -r --arg key "$key" '.[$key].email // empty' "$GIT_CONFIG_JSON")
  ssh_key=$(jq -r --arg key "$key" '.[$key].ssh_key // empty' "$GIT_CONFIG_JSON")
  gpg_key=$(jq -r --arg key "$key" '.[$key].gpg_key // empty' "$GIT_CONFIG_JSON")

  git config --global user.name "$name"
  git config --global user.email "$email"

  if [ -n "$gpg_key" ] && [ "$gpg_key" != "null" ]; then
    git config --global user.signingkey "$gpg_key"
  fi

  if [ -n "$ssh_key" ] && [ "$ssh_key" != "null" ]; then
    expanded_key="${ssh_key/#\~/$HOME}"
    ssh-add -D >/dev/null 2>&1
    ssh-add "$expanded_key" >/dev/null 2>&1
  fi

  echo "Active GitHub profile: $key ($email)"
}

# Match profile.path as a path segment (avoids "personal" matching "personal-projects").
_path_matches_profile() {
  local current_dir=$1
  local path_pattern=$2
  local normalized="${current_dir}/"

  [[ "$normalized" == *"/${path_pattern}/"* ]] || [[ "$normalized" == "${path_pattern}/"* ]] || [[ "$current_dir" == "$path_pattern" ]]
}

check_git_profile_by_path() {
  local current_dir profile target_email path_pattern

  if [ ! -f "$GIT_CONFIG_JSON" ] || ! command -v jq >/dev/null 2>&1; then
    return 0
  fi

  current_dir=$(pwd)

  while IFS= read -r profile; do
    [ -z "$profile" ] || [ "$profile" = "null" ] && continue
    path_pattern=$(jq -r --arg key "$profile" '.[$key].path // empty' "$GIT_CONFIG_JSON")
    [ -z "$path_pattern" ] && continue

    if _path_matches_profile "$current_dir" "$path_pattern"; then
      target_email=$(jq -r --arg key "$profile" '.[$key].email // empty' "$GIT_CONFIG_JSON")
      if [[ "$(git config --global user.email 2>/dev/null)" != "$target_email" ]]; then
        set_git_profile "$profile"
      fi
      return 0
    fi
  done < <(jq -r 'to_entries[] | select(.value | type == "object" and (.path | type == "string")) | .key' "$GIT_CONFIG_JSON")
}

alias gprofile=set_git_profile

if [ -n "$BASH_VERSION" ]; then
  if [[ ":${PROMPT_COMMAND}:" != *":check_git_profile_by_path:"* ]]; then
    PROMPT_COMMAND="check_git_profile_by_path${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  fi
elif [ -n "$ZSH_VERSION" ]; then
  if ! (( ${chpwd_functions[(Ie)check_git_profile_by_path]} )); then
    chpwd_functions+=(check_git_profile_by_path)
  fi
  check_git_profile_by_path
fi
