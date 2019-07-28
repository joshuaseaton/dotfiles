" I/O-related helpers.

" Inserts the given text where the cursor is.
function! io#InsertText(text)
    " Temporaily disable format options while inserting to prevent
    " side-effects (e.g., auto-continuation of inserted comments resulting in
    " double-commenting)
    let l:opts = &formatoptions
    set formatoptions=""
    execute "normal! \<Esc>a" . a:text
    execute "set formatoptions=" . l:opts
endfunction

