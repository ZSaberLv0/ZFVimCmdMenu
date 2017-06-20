" ZFVimCmdMenu.vim - vim script to make a menu in cmd line
" Author:  ZSaberLv0 <http://zsaber.com/>

let g:ZFVimCmdMenu_loaded=1

" ============================================================
" config
let g:ZFVimCmdMenuSettingDefault={
            \     'confirmKeys' : 'o',
            \     'escKeys' : 'q ',
            \     'hideWhenNoMatch' : 0,
            \     'showKeyHint' : 0,
            \     'showKeyHintL' : '(',
            \     'showKeyHintR' : ') ',
            \     'hintText' : '(choose by j/k, confirm by shortcut or <enter> or o, cancel by <esc> or q or <space>)',
            \     'headerText' : '',
            \     'footerText' : '',
            \     'indentText' : '    ',
            \     'markText' : '  > ',
            \     'cancelText' : 'canceled',
            \ }

let g:ZFVimCmdMenuSettingDefault['defaultKeyList']='abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
if len(g:ZFVimCmdMenuSettingDefault['confirmKeys']) > 0 || len(g:ZFVimCmdMenuSettingDefault['escKeys']) > 0
    let g:ZFVimCmdMenuSettingDefault['defaultKeyList']=substitute(
                \ g:ZFVimCmdMenuSettingDefault['defaultKeyList'],
                \ '\C[' . g:ZFVimCmdMenuSettingDefault['confirmKeys'] . g:ZFVimCmdMenuSettingDefault['escKeys'] . ']',
                \ '', 'g')
endif


" ============================================================
let g:ZFVimCmdMenu_itemList = []
let g:ZFVimCmdMenu_itemIndex = 0
let s:settingSaved = []

function! ZF_VimCmdMenuSettingSave()
    if exists('g:ZFVimCmdMenuSetting')
        call add(s:settingSaved, deepcopy(g:ZFVimCmdMenuSetting, 1))
    endif
endfunction
function! ZF_VimCmdMenuSettingRestore()
    if exists('s:settingSaved') && len(s:settingSaved) > 0
        let g:ZFVimCmdMenuSetting = remove(s:settingSaved, -1)
    endif
endfunction

function! s:updateSetting()
    if !exists('s:setting')
        let s:setting = deepcopy(g:ZFVimCmdMenuSettingDefault, 1)
        if exists('g:ZFVimCmdMenuSetting')
            call extend(s:setting, g:ZFVimCmdMenuSetting, 'force')
        endif
    endif
endfunction

function! ZF_VimCmdMenuAdd(showKeyHint, key, text, command, ...)
    call s:updateSetting()
    let key = a:key

    if len(key) == 0
        let t = len(g:ZFVimCmdMenu_itemList) % len(s:setting['defaultKeyList'])
        let key = s:setting['defaultKeyList'][t]
    endif

    let item = {
                \     'showKeyHint' : a:showKeyHint,
                \     'key' : key,
                \     'text' : a:text,
                \     'command' : a:command,
                \ }
    if a:0 > 0
        let item['callback'] = a:1
    else
        let item['callback'] = ''
    endif
    if a:0 > 1
        for i in range(2, a:0)
            execute 'let t = a:' . i
            let item['callbackParam' . (i - 2)] = t
        endfor
    endif
    for i in range(a:0 - 1, 7)
        let item['callbackParam' . i] = ''
    endfor

    call add(g:ZFVimCmdMenu_itemList, item)
endfunction

function! ZF_VimCmdMenuShow(...)
    call s:updateSetting()

    if a:0 > 0
        let s:setting['headerText'] = a:1
        if a:0 > 1
            let s:setting['footerText'] = a:2
        endif
    endif

    let processing = 1
    let s:choosedItem = {}
    while processing != 0
        let processing = s:process()
    endwhile

    let g:ZFVimCmdMenu_itemList = []
    let g:ZFVimCmdMenu_itemIndex = 0
    unlet s:setting

    call ZF_VimCmdMenuSettingRestore()

    call s:itemProcess()
    return s:choosedItem
endfunction

function! s:updateState()
    redraw!

    if len(s:setting['headerText']) > 0
        echo s:setting['headerText']
        echo ' '
    endif

    let i = 0
    for item in g:ZFVimCmdMenu_itemList
        let text = ''

        if i == g:ZFVimCmdMenu_itemIndex
            let text .= s:setting['markText']
        else
            let text .= s:setting['indentText']
        endif

        if item.showKeyHint == 1 || (item.showKeyHint == -1 && s:setting['showKeyHint'])
            let text .= s:setting['showKeyHintL']
            let text .= item.key
            let text .= s:setting['showKeyHintR']
        endif

        let text .= item.text

        echo text
        let i += 1
    endfor

    if len(s:setting['footerText']) > 0
        echo ' '
        echo s:setting['footerText']
    endif

    if len(s:setting['hintText']) > 0
        echo ' '
        echo s:setting['hintText']
    endif
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

    let processResult = s:processEsc(cmd)
    if processResult == 1
        return 0
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

    if s:setting['hideWhenNoMatch']
        redraw!
        if len(s:setting['cancelText']) > 0
            echo s:setting['cancelText']
        endif
        return 0
    else
        return 1
    endif
endfunction

function! s:processEsc(cmd)
    let esc = 0
    if a:cmd == 27
        let esc = 1
    elseif len(s:setting['escKeys']) > 0
        for i in range(len(s:setting['escKeys']))
            if a:cmd == char2nr(s:setting['escKeys'][i])
                let esc = 1
                break
            endif
        endfor
    endif

    if esc == 1
        redraw!
        if len(s:setting['cancelText']) > 0
            echo s:setting['cancelText']
        endif
        return 1
    else
        return 0
    endif
endfunction

function! s:processConfirm(cmd)
    let confirm = 0
    if a:cmd == 13
        let confirm = 1
    elseif len(s:setting['confirmKeys']) > 0
        for i in range(len(s:setting['confirmKeys']))
            if a:cmd == char2nr(s:setting['confirmKeys'][i])
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
    let s:choosedItem = deepcopy(g:ZFVimCmdMenu_itemList[a:index], 1)
endfunction

function! s:itemProcess()
    if len(s:choosedItem) <= 0
        return
    endif
    redraw!
    let item = deepcopy(s:choosedItem, 1)

    if len(item.command) > 0
        execute item.command
    endif

    if len(item.callback) > 0
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
    endif
endfunction

if 0
    " define callback function
    function! MyCallback(...)
        echo 'function called with ' . a:0 . ' param:'
        for i in range(a:0)
            execute 'let t=a:' . (i + 1)
            echo t
        endfor
    endfunction

    " add menu item
    call ZF_VimCmdMenuAdd(-1, 's', '(s)how sth', '', 'MyCallback', 'myParam0', 'myParam1')
    call ZF_VimCmdMenuAdd(-1, 'x', 'e(x)ecute sth', 'call MyCallback("test")')
    call ZF_VimCmdMenuAdd(-1, 'x', 'e(x)ecute sth2', 'call MyCallback("test")')
    call ZF_VimCmdMenuAdd(1, '', 'loop', 'call MyCallback("")')
    call ZF_VimCmdMenuAdd(1, '', 'loop', 'call MyCallback("")')
    call ZF_VimCmdMenuAdd(1, '', 'loop', 'call MyCallback("")')

    " finally, show the menu
    let choosed = ZF_VimCmdMenuShow('select your choice:')
    echo 'choosed:'
    echo choosed
endif

