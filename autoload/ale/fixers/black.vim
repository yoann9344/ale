" Author: w0rp <devw0rp@gmail.com>
" Description: Fixing Python files with black.
"
call ale#Set('python_black_executable', 'black')
call ale#Set('python_black_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_black_options', '')
call ale#Set('python_black_use_config', 0)
call ale#Set('python_black_auto_pipenv', 0)
call ale#Set('python_black_auto_poetry', 0)
call ale#Set('python_black_change_directory', 1)

function! ale#fixers#black#GetExecutable(buffer) abort
    if (ale#Var(a:buffer, 'python_auto_pipenv') || ale#Var(a:buffer, 'python_black_auto_pipenv'))
    \ && ale#python#PipenvPresent(a:buffer)
        return 'pipenv'
    endif

    if (ale#Var(a:buffer, 'python_auto_poetry') || ale#Var(a:buffer, 'python_black_auto_poetry'))
    \ && ale#python#PoetryPresent(a:buffer)
        return 'poetry'
    endif

    return ale#python#FindExecutable(a:buffer, 'python_black', ['black'])
endfunction

function! s:add_options(buffer, cmd) abort
    let l:options = ale#Var(a:buffer, 'python_black_options')

    if !empty(l:options)
        call add(a:cmd, l:options)
    endif
endfunction

function! s:add_config(cmd, config) abort
    if !empty(a:config)
        call add(a:cmd, '--config ' . ale#Escape(a:config))
    endif
endfunction

function! ale#fixers#black#Fix(buffer) abort
    let l:executable = ale#fixers#black#GetExecutable(a:buffer)
    let l:cmd = [ale#Escape(l:executable)]

    if l:executable =~? 'pipenv\|poetry$'
        call extend(l:cmd, ['run', 'black'])
    endif

    let l:use_config = ale#Var(a:buffer, 'python_black_use_config')
    let l:config = ale#path#FindNearestFile(a:buffer, 'pyproject.toml')

    if l:use_config == 1 && !empty(l:config)
        call s:add_options(a:buffer, l:cmd)
        call s:add_config(l:cmd, l:config)
    elseif l:use_config == 2 && !empty(l:config)
        call s:add_config(l:cmd, l:config)
    else
        call s:add_options(a:buffer, l:cmd)
    endif


    if expand('#' . a:buffer . ':e') is? 'pyi'
        call add(l:cmd, '--pyi')
    endif

    call add(l:cmd, '-')

    let l:result = {'command': join(l:cmd, ' ')}

    if ale#Var(a:buffer, 'python_black_change_directory')
        let l:result.cwd = '%s:h'
    endif

    " echo l:result

    return l:result
endfunction
