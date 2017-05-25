" ZFVimCmdMenu.vim - vim script to make a menu in cmd line
" Author:  ZSaberLv0 <http://zsaber.com/>

" ============================================================
" config
let g:ZFVimCmdMenuSettingDefault={
            \     'confirmKeys' : 'o',
            \     'appendKeyHint' : 0,
            \     'appendKeyHintL' : '(',
            \     'appendKeyHintR' : ') ',
            \     'footerText' : '',
            \     'indentText' : '  ',
            \     'markText' : '> ',
            \     'cancelText' : 'canceled',
            \ }
let g:ZFVimCmdMenuSettingDefault['headerText']='choose by j/k, confirm by press key or <enter>'
if len(g:ZFVimCmdMenuSettingDefault['confirmKeys']) > 0
    for i in range(len(g:ZFVimCmdMenuSettingDefault['confirmKeys']))
        let g:ZFVimCmdMenuSettingDefault['headerText'] .= '/' . g:ZFVimCmdMenuSettingDefault['confirmKeys'][i]
    endfor
endif

let g:ZFVimCmdMenuSettingDefault['defaultKeyList']='abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
if len(g:ZFVimCmdMenuSettingDefault['confirmKeys']) > 0
    let g:ZFVimCmdMenuSettingDefault['defaultKeyList']=substitute(
                \ g:ZFVimCmdMenuSettingDefault['defaultKeyList'],
                \ '\C[' . g:ZFVimCmdMenuSettingDefault['confirmKeys'] . ']',
                \ '', 'g')
endif


" ============================================================
let g:ZFVimCmdMenu_itemList = []
let g:ZFVimCmdMenu_itemIndex = 0
let s:noNameItemIndex = 0

function! ZF_VimCmdMenuSettingSave()
    if exists('g:ZFVimCmdMenuSetting')
        let s:settingSaved = deepcopy(g:ZFVimCmdMenuSetting, 1)
    endif
endfunction
function! ZF_VimCmdMenuSettingRestore()
    if exists('s:settingSaved')
        let g:ZFVimCmdMenuSetting = deepcopy(s:settingSaved, 1)
        unlet s:settingSaved
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
        let t = s:noNameItemIndex % len(s:setting['defaultKeyList'])
        let key = s:setting['defaultKeyList'][t]
        let s:noNameItemIndex += 1
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

function! ZF_VimCmdMenuShow()
    call s:updateSetting()
    let processing = 1
    let s:choosedItem = {}
    while processing != 0
        let processing = s:process()
    endwhile
    return s:choosedItem
endfunction

function! s:updateState()
    redraw!

    if len(s:setting['headerText']) > 0
        echo s:setting['headerText']
    endif

    let i = 0
    for item in g:ZFVimCmdMenu_itemList
        let text = ''

        if i == g:ZFVimCmdMenu_itemIndex
            let text .= s:setting['markText']
        else
            let text .= s:setting['indentText']
        endif

        if item.showKeyHint == 1 || (item.showKeyHint == -1 && s:setting['appendKeyHint'])
            let text .= s:setting['appendKeyHintL']
            let text .= item.key
            let text .= s:setting['appendKeyHintR']
        endif

        let text .= item.text

        echo text
        let i += 1
    endfor

    echo s:setting['footerText']
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
    if len(s:setting['cancelText']) > 0
        echo s:setting['cancelText']
    endif
    return 0
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
    let s:choosedItem = item

    let g:ZFVimCmdMenu_itemList = []
    let g:ZFVimCmdMenu_itemIndex = 0
    let s:noNameItemIndex = 0
    unlet s:setting

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
    let choosed = ZF_VimCmdMenuShow()
    echo 'choosed:'
    echo choosed
endif

