" ZFVimCmdMenu.vim - vim script to make a menu in cmd line
" Author:  ZSaberLv0 <http://zsaber.com/>

" ============================================================
" config
if !exists('g:ZFVimCmdMenu_confirmKeys')
    let g:ZFVimCmdMenu_confirmKeys='o'
endif

if !exists('g:ZFVimCmdMenu_appendKeyHint')
    let g:ZFVimCmdMenu_appendKeyHint=0
endif
if !exists('g:ZFVimCmdMenu_appendKeyHintLeftText')
    let g:ZFVimCmdMenu_appendKeyHintLeftText='('
endif
if !exists('g:ZFVimCmdMenu_appendKeyHintRightText')
    let g:ZFVimCmdMenu_appendKeyHintRightText=') '
endif

if !exists('g:ZFVimCmdMenu_headerText')
    let g:ZFVimCmdMenu_headerText='choose by j/k, confirm by press key or <enter>'
    if len(g:ZFVimCmdMenu_confirmKeys) > 0
        for i in range(len(g:ZFVimCmdMenu_confirmKeys))
            let g:ZFVimCmdMenu_headerText .= '/' . g:ZFVimCmdMenu_confirmKeys[i]
        endfor
    endif
endif

if !exists('g:ZFVimCmdMenu_footerText')
    let g:ZFVimCmdMenu_footerText=''
endif

if !exists('g:ZFVimCmdMenu_indentText')
    let g:ZFVimCmdMenu_indentText='  '
endif

if !exists('g:ZFVimCmdMenu_markText')
    let g:ZFVimCmdMenu_markText='> '
endif

if !exists('g:ZFVimCmdMenu_cancelText')
    let g:ZFVimCmdMenu_cancelText='canceled'
endif

if !exists('g:ZFVimCmdMenu_noNameItemKeyList') || 1
    let g:ZFVimCmdMenu_noNameItemKeyList='abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
    if len(g:ZFVimCmdMenu_confirmKeys) > 0
        let g:ZFVimCmdMenu_noNameItemKeyList=substitute(
                    \ g:ZFVimCmdMenu_noNameItemKeyList,
                    \ '\C[' . g:ZFVimCmdMenu_confirmKeys . ']',
                    \ '', 'g')
    endif
endif


" ============================================================
let g:ZFVimCmdMenu_itemList = []
let g:ZFVimCmdMenu_itemIndex = 0
let s:noNameItemIndex = 0

function! ZF_VimCmdMenuAdd(key, text, callback, ...)
    let key = a:key

    if len(key) == 0
        let t = s:noNameItemIndex % len(g:ZFVimCmdMenu_noNameItemKeyList)
        let key = g:ZFVimCmdMenu_noNameItemKeyList[t]
        let s:noNameItemIndex += 1
    endif

    let item = {
                \     'key' : key,
                \     'text' : a:text,
                \     'callback' : a:callback,
                \ }
    for i in range(a:0)
        execute 'let t = a:' . (i + 1)
        let item['callbackParam' . i] = t
    endfor
    for i in range(a:0, 7)
        let item['callbackParam' . i] = ''
    endfor
    call add(g:ZFVimCmdMenu_itemList, item)
endfunction

function! ZF_VimCmdMenuShow()
    let processing = 1
    while processing != 0
        let processing = s:process()
    endwhile
endfunction

function! s:updateState()
    redraw!

    if len(g:ZFVimCmdMenu_headerText) > 0
        echo g:ZFVimCmdMenu_headerText
    endif

    let i = 0
    for item in g:ZFVimCmdMenu_itemList
        let text = ''

        if i == g:ZFVimCmdMenu_itemIndex
            let text .= g:ZFVimCmdMenu_markText
        else
            let text .= g:ZFVimCmdMenu_indentText
        endif

        if g:ZFVimCmdMenu_appendKeyHint
            let text .= g:ZFVimCmdMenu_appendKeyHintLeftText
            let text .= item.key
            let text .= g:ZFVimCmdMenu_appendKeyHintRightText
        endif

        let text .= item.text

        echo text
        let i += 1
    endfor

    echo g:ZFVimCmdMenu_footerText
endfunction

function! s:process()
    call s:updateState()
    let cmd=getchar()

    if cmd == char2nr("j")
        if g:ZFVimCmdMenu_itemIndex + 1 < len(g:ZFVimCmdMenu_itemList)
            let g:ZFVimCmdMenu_itemIndex += 1
        else
            let g:ZFVimCmdMenu_itemIndex = 0
        endif
        return 1
    elseif cmd == char2nr("k")
        if g:ZFVimCmdMenu_itemIndex > 0
            let g:ZFVimCmdMenu_itemIndex -= 1
        else
            let g:ZFVimCmdMenu_itemIndex = len(g:ZFVimCmdMenu_itemList) - 1
        endif
        return 1
    endif

    let processResult = s:processConfirm(cmd)
    if processResult == 1
        return 0
    endif

    let processResult = s:processItem(cmd)
    if processResult == 1
        return 0
    elseif processResult == 2
        return 1
    endif

    redraw!
    if len(g:ZFVimCmdMenu_cancelText) > 0
        echo g:ZFVimCmdMenu_cancelText
    endif
    return 0
endfunction

function! s:processConfirm(cmd)
    let confirm = 0
    if a:cmd == 13
        let confirm = 1
    elseif len(g:ZFVimCmdMenu_confirmKeys) > 0
        for i in range(len(g:ZFVimCmdMenu_confirmKeys))
            if a:cmd == char2nr(g:ZFVimCmdMenu_confirmKeys[i])
                let confirm = 1
                break
            endif
        endfor
    endif

    if confirm == 1
        call s:itemSelected(g:ZFVimCmdMenu_itemIndex)
        return 1
    else
        return 0
    endif
endfunction

function! s:processItem(cmd)
    let checked = s:findItem(a:cmd)
    if len(checked) == 1
        redraw!
        call s:itemSelected(checked[0])
        return 1
    elseif len(checked) > 1
        for i in range(len(checked))
            if g:ZFVimCmdMenu_itemIndex == checked[i]
                if i + 1 < len(checked)
                    let g:ZFVimCmdMenu_itemIndex = checked[i + 1]
                else
                    let g:ZFVimCmdMenu_itemIndex = checked[0]
                endif
                return 2
            endif
        endfor
        let g:ZFVimCmdMenu_itemIndex = checked[0]
        return 2
    else
        return 0
    endif
endfunction

function! s:findItem(cmd)
    let ret = []
    let i = 0
    for item in g:ZFVimCmdMenu_itemList
        if a:cmd == char2nr(item.key)
            call add(ret, i)
        endif
        let i += 1
    endfor
    return ret
endfunction

function! s:itemSelected(index)
    let item = g:ZFVimCmdMenu_itemList[a:index]
    let g:ZFVimCmdMenu_itemList = []
    let g:ZFVimCmdMenu_itemIndex = 0
    let s:noNameItemIndex = 0
    let t = ''
    for i in range(8)
        let param = item['callbackParam' . i]
        if len(param) == 0
            break
        endif
        if len(t) > 0
            let t .= ','
        endif
        let t .= '"' . param . '"'
    endfor
    execute 'call ' . item.callback . '(' . t . ')'
endfunction

