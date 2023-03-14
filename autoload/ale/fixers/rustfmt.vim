" Author: Kelly Fox <kelly@bumfuddled.com>
" Description: Integration of rustfmt with ALE.

call ale#Set('rust_rustfmt_executable', 'rustfmt')
call ale#Set('rust_rustfmt_options', '')

function! ale#fixers#rustfmt#Fix(buffer) abort
    let l:executable = ale#Var(a:buffer, 'rust_rustfmt_executable')
    let l:options = ale#Var(a:buffer, 'rust_rustfmt_options')
    let l:config = ale#path#FindNearestFile(a:buffer, 'rustfmt.toml')

    if !empty(l:config)
        let l:options = l:options . ' --config-path ' . ale#Escape(l:config)
    endif

    " echo ale#Escape(l:executable) . (empty(l:options) ? '' : ' ' . l:options)
    return {
    \   'command': ale#Escape(l:executable)
    \       . (empty(l:options) ? '' : ' ' . l:options),
    \}
endfunction
