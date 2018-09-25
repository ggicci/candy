#!/usr/bin/env bash
# This script will be sourced when you call "tmux" command.


array::contains() {
  local list=$1[@]
  local elem=$2

  for i in "${!list}"; do
    if [[ "$i" == "${elem}" ]]; then
      return 0  # found
    fi
  done
  return 1 # not found
}


search_and_change_directory() {
  local session_name="$1"

  if [[ ${session_name} == "notset" ]]; then return; fi

  # it's slow
  # local search_dirs=$(find "${HOME}/workspace/src" -type d -maxdepth 3 -not -path '*/\.*')
  local search_dirs=(
    "${HOME}/workspace/src/github.com/ggicci/${session_name}"
    "${HOME}/workspace/src/gitlab.com/ggicci/${session_name}"
    "${HOME}/workspace/src/ggicci.me/${session_name}"
    # "${HOME}/workspace/src/gitlab.alibaba-inc.com/alicdn/${session_name}"
    # "${HOME}/workspace/src/gitlab.alibaba-inc.com/mingjie.tmj/${session_name}"
    "${HOME}/workspace/src/gitlab.com/thunderdb/${session_name}"
    "${HOME}/workspace/src/github.com/covenantsql/${session_name}"
  )

  for project_dir in ${search_dirs[@]}; do
    if [[ -d "${project_dir}" ]]; then
      cd "${project_dir}"
      break
    fi
  done
}


set_project_dir_as_gopath() {
  local session_name="$1"

  if [[ ${session_name} == "notset" ]]; then return; fi

  local local_gopath_projects=(
    "mammon"
    "skyeye"
    "kunlunpool"
  )
  if array::contains local_gopath_projects "${session_name}"; then
    export GOPATH="$(PWD)"
    export PATH="${GOPATH}/bin:${PATH}"
  fi
}


detect_and_activate_python_virtualenv() {
  if [[ -e ".vscode/settings.json" ]]; then
    local virtualenv_dir="$(grep "python.pythonPath" ".vscode/settings.json" | awk -F'[":]' '{print $5}')"
    virtualenv_dir=${virtualenv_dir%%/bin/python}
    if [[ -e "${virtualenv_dir}/bin/activate" ]]; then
      source "${virtualenv_dir}/bin/activate"
    fi
  fi
}


main() {
  local session_name="${1:-notset}"

  search_and_change_directory "${session_name}"
  # set_project_dir_as_gopath "${session_name}"
  detect_and_activate_python_virtualenv
}


main "$@"
