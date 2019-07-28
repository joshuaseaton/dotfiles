" This script enables the auto-population of license headers in new files.

" To enable a new type of header, add it here under a LICENSE file pattern
" that uniquely defines the associated project.
let s:headers_by_pattern = {
    \"/The Fuchsia Authors/" : join([
        \"// Copyright " . strftime("%Y") . " The Fuchsia Authors. All rights reserved.",
        \"// Use of this source code is governed by a BSD-style license that can",
        \"// found in the LICENSE file.",
        \], "\n"),
    \"/The LUCI Authors/": join([
        \"// Copyright " . strftime("%Y") . " The LUCI Authors. All rights reserved.",
        \"// Use of this source code is governed under the Apache License, Version 2.0",
        \"// that can be found in the LICENSE file.",
        \], "\n"),
\}

" Returns the absolute path to a license file found within a parent directory,
" and the empty string otherwise.
function! s:FindParentLicense()
  let l:license_file = findfile("LICENSE", ".;")
  if empty(l:license_file)
    let l:license_file = findfile("LICENSE.md", ".;")
  endif
  if empty(l:license_file)
    return ""
  endif
  return join([getcwd(), license_file], "/")
endfunction

" Returns whether a patten has a match in a given file.
function! s:PatternInFile(pattern, file)
  execute "silent! vimgrep " . a:pattern . "j " . a:file
  return len(getqflist()) > 0
endfunction

" Returns the associated license header if there is one, else the empty
" string.
function! s:GetLicenseHeader()
  let l:license = s:FindParentLicense()
  if empty(l:license)
    return ""
  endif
  for entry in items(s:headers_by_pattern)
    let l:pattern = entry[0]
    let l:hdr = entry[1]
    if s:PatternInFile(l:pattern, l:license)
      return l:hdr
    endif
  endfor
  return ""
endfunction

autocmd BufNewFile * execute "call io#InsertText(s:GetLicenseHeader())"
" Replace any auto-inserted `//`s with `#`s for shell, python and gn files.
autocmd BufNewFile *.sh,*.py,*.gn,*.gni silent! execute "%s/\\/\\//#/g"

