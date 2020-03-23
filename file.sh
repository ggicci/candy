# import "github.com/ggicci/candy/exec.sh"

# Content Section: a block of content in a file.
# Which is wrapped between content boundaries. For example:
# # ========
# # 
# # ========

# Replace a section of content in a file.
file::replace_content_section() {
  local filename="$1"
  local key="$2"
  local content="$3"

  
}
# Add a section of content to a file if not exists.
file::add_content_section() {
  local filename="$1"
  local key="$2"
  local content="$3"

  if [[ "$( grep "${key}" "${filename}" 2>/dev/null )" != "" ]]; then
    return 0
  fi

  sys::replace_content_section_in_a_file "$1" "$2" "$3"
}



main() {
  echo "file::main::hello"
}

main "$@"

