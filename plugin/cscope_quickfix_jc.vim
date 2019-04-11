" File: cscope_quickfix_jc.vim (jc is "jump control")
" Author: Xiongwei Song (sxwjean@gmail.com)
" Version: 1.0
" Last Modified: Apr. 11, 2019
" Description: vim script for redirecting cscope output to quickfix.

if !exists("cs_auto_openqf")
    let cs_auto_openqf = 1
endif

if !exists("cs_auto_jump")
    let cs_auto_jump = 1
endif

" ExeCscope()
" Run the cscope command using the supplied option and pattern.
function! s:ExeCscope(...)
    let usage = "Usage: Cscope {type} {pattern} [{file}]."
    let usage = usage . " {type} is [sgdctefi01234678]."
    if !exists("a:1") || !exists("a:2")
        echohl WarningMsg | echomsg usage | echohl None
        return
    endif

    let cs_opt = a:1
    let pattern = a:2
    let last_a = a:000
    let auto_open = g:cs_auto_openqf
    let auto_jump = g:cs_auto_jump
    let cs_opts = {0: 's', 1: 'g', 2: 'd', 3: 'c', 4: 't', 6: 'e', 7: 'f', 8: 'i'}
    let cs_opts_2 = {'s': 0, 'g': 1, 'd': 2, 'c': 3, 't': 4, 'e': 6, 'f': 7, 'i': 8}

    " Create the cscope command.
    if cs_opt == '6' || cs_opt == 'e'
        let i = 1
        let cmd = "cscope -L -6 " . "'"
        while i < a:0
            let cmd= cmd . last_a[i]
            if i < a:0-1
                let cmd = cmd . " "
            endif
            let i = i+1
        endwhile
        let cmd = cmd . "'"
    elseif has_key(cs_opts, cs_opt)
        let cmd = "cscope -L -" . cs_opt . " " . pattern 
    elseif has_key(cs_opts_2, cs_opt)
        let cmd = "cscope -L -" . cs_opts_2[cs_opt] . " " . pattern 
    else
        echo "option is incorrect"
    	return
    endif

    " Run the cscope command.
    if exists("a:3")
        "let cmd = cmd . " " . a:3
    endif
    let cs_output = system(cmd)

    if cs_output == ""
        echohl WarningMsg | 
        \ echomsg "Error: Pattern " . pattern . " not found" | 
        \ echohl None
        return
    endif

    if &modified && !&autowrite 
        let auto_jump = 0
    endif

    " Create dictionary, add the dictionary to list, the set the list to quickfix.
    let list_dic = []
    let list_sub = []
    let cs_output = split(cs_output, '\n')

    for f in cs_output 
        let list_sub = matchlist(f, '^\([^ ]*\)\s\(.*\)\s\([0-9]\+\)\s\(.*\)$', 0)
        if len(list_sub) == 0
            echo "The list_sub doesn't have item\n"
            return
        endif
        let dict = {'filename':list_sub[1], 'lnum':list_sub[3], 'text':list_sub[4]}
        call add(list_dic, dict)
    endfor
    call setqflist(list_dic)

    " Open the quickfix window.
    if auto_open == 1
        botright copen
    endif

    " If need, jump to the first error.
    if auto_jump == 1
        cc 1
    endif
endfunction

" Define the set of Cscope commands
if !exists(":Cscope")
    command! -nargs=+ Cscope call s:ExeCscope(<f-args>)
endif

nmap <C-\>s :Cscope s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>g :Cscope g <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>d :Cscope d <C-R>=expand("<cword>")<CR> <C-R>=expand("%")<CR><CR>
nmap <C-\>c :Cscope c <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>t :Cscope t <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>e :Cscope e <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>f :Cscope f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-\>i :Cscope i ^<C-R>=expand("<cfile>")<CR>$<CR>

nmap <C-_>s :Cscope s <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>g :Cscope g <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>d :Cscope d <C-R>=expand("<cword>")<CR> <C-R>=expand("%")<CR><CR>
nmap <C-_>c :Cscope c <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>t :Cscope t <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>e :Cscope e <C-R>=expand("<cword>")<CR><CR>
nmap <C-_>f :Cscope f <C-R>=expand("<cfile>")<CR><CR>
nmap <C-_>i :Cscope i ^<C-R>=expand("<cfile>")<CR>$<CR>

" vim:set ts=4 sw=4 filetype=vim:
