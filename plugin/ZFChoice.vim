
function! ZFChoice(title, hints)
    if exists('*ZF_VimCmdMenuShow')
        return ZFChoice_ZFVimCmdMenu(a:title, a:hints)
    else
        return ZFChoice_default(a:title, a:hints)
    endif
endfunction
function! ZFChoice_default(title, hints)
    let hint = []
    call add(hint, a:title)
    call add(hint, '')
    for i in range(len(a:hints))
        call add(hint, printf('  %2s: %s', i + 1, a:hints[i]))
    endfor
    call add(hint, '')
    let choice = inputlist(hint)
    redraw
    if choice >= 1 && choice < len(a:hints) + 1
        return choice - 1
    else
        return -1
    endif
endfunction
function! ZFChoice_ZFVimCmdMenu(title, hints)
    let index = 0
    for item in a:hints
        call ZF_VimCmdMenuAdd({
                    \   'showKeyHint' : 1,
                    \   'text' : item,
                    \   '_itemIndex' : index,
                    \ })
        let index += 1
    endfor
    let choice = ZF_VimCmdMenuShow({
                \   'headerText' : a:title,
                \ })
    redraw
    return get(choice, '_itemIndex', -1)
endfunction

