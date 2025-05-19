#!/bin/bash
update_file_line() {
  local file="$1"
  local line="$2"
  local new_content="$3"

  [ ! -f "$file" ] && { echo "Error:file '$file' no exist." >&2; return 1; }

  local current_lines=$(wc -l < "$file")
  if (( current_lines < line )); then
    for (( i=current_lines+1; i<=line; i++ )); do
      echo "" >> "$file"
    done
  fi

  local escaped_content
  escaped_content=$(sed 's/[\/&$]/\\&/g; s/\\$/$$/g' <<< "$new_content")

  if sed --version &>/dev/null; then
    # GNU sed（Linux）
    sed -i "${line}s/^.*$/${escaped_content}/" "$file"
  else
    # BSD sed（macOS）
    sed -i "" "${line}s/^.*$/${escaped_content}/" "$file"
  fi
}
