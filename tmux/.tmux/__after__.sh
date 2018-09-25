#!/usr/bin/env bash
# This script will be sourced when you call "tmux" command.


# $1: scope, one of system, global, local
# $2: config key
# $3: new config value
git::update_config() {
  local scope="${1:-notset}"
  local config_key="${2:-notset}"
  local value_new="${3:-notset}"

  local value_old="$(git config --${scope} ${config_key})"
  if [[ "${value_old}" != "${value_new}" ]]; then
    git config --${scope} ${config_key} "${value_new}"
    echo "git config (${scope}): reset ${config_key} from \"${value_old}\" to \"${value_new}\""
  fi
}


ensure_correct_git_user_config() {
  if [[ ! -d .git ]]; then
    return
  fi

  if [[ $(PWD) == *"gitlab.alibaba-inc.com"* ]]; then
    git::update_config "local" "user.name" "岩壹"
    git::update_config "local" "user.email" "mingjie.tmj@alibaba-inc.com"
  elif [[ $(PWD) == *"gitlab.com/thunderdb"* ]]; then
    git::update_config "local" "user.name" "Ggicci"
    git::update_config "local" "user.email" "mingjie.tang@covenantsql.io"
  else
    git::update_config "local" "user.name" "ggicci"
    git::update_config "local" "user.email" "ggicci.t@gmail.com"
  fi
}


main() {
  ensure_correct_git_user_config
}


main "$@"
