" ZFVimCmdMenu.vim - vim script to make a menu in cmd line
" Author:  ZSaberLv0 <http://zsaber.com/>

let g:ZFVimCmdMenu_loaded=1

" ============================================================
" config
let g:ZFVimCmdMenuSettingDefault={
            \     'escGoBack' : 1,
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
if !empty(g:ZFVimCmdMenuSettingDefault['confirmKeys']) || !empty(g:ZFVimCmdMenuSettingDefault['escKeys'])
    let g:ZFVimCmdMenuSettingDefault['defaultKeyList']=substitute(
                \ g:ZFVimCmdMenuSettingDefault['defaultKeyList'],
                \ '\C[' . g:ZFVimCmdMenuSettingDefault['confirmKeys'] . g:ZFVimCmdMenuSettingDefault['escKeys'] . ']',
                \ '', 'g')
endif


" ============================================================
" {
"     'itemType' : 'normal/subMenu/keep',
"     'showKeyHint' : '-1/0/1',
"     'key' : 'any letter',
"     'text' : 'any string',
"     'command' : 'vim command to call',
"     'callback' : 'vim function to call',
"     'callbackParam0 ~ callbackParam7' : 'params passed to callback',
" }
let g:ZFVimCmdMenu_curItemList = []
let g:ZFVimCmdMenu_curItemIndex = 0
let g:ZFVimCmdMenu_curSetting = {}

let s:state = []
let s:choosedItem = {}

function! ZF_VimCmdMenuAdd(item)
    let item = {
                \     'itemType' : 'normal',
                \     'showKeyHint' : -1,
                \     'key' : '',
                \     'text' : '',
                \     'command' : '',
                \     'callback' : '',
                \     'callbackParam0' : '',
                \     'callbackParam1' : '',
                \     'callbackParam2' : '',
                \     'callbackParam3' : '',
                \     'callbackParam4' : '',
                \     'callbackParam5' : '',
                \     'callbackParam6' : '',
                \     'callbackParam7' : '',
                \ }
    call extend(item, a:item, 'force')
    call add(g:ZFVimCmdMenu_curItemList, item)
endfunction

function! ZF_VimCmdMenuShow(...)
    if !exists('s:cmdheightSaved')
        let s:cmdheightSaved = &cmdheight
    endif

    let ret = {}
    while 1
        if empty(g:ZFVimCmdMenu_curItemList)
            break
        endif

        let g:ZFVimCmdMenu_curSetting = deepcopy(g:ZFVimCmdMenuSettingDefault, 1)
        if a:0 > 0
            call extend(g:ZFVimCmdMenu_curSetting, a:1, 'force')
        endif

        let defaultKeyIndex = 0
        for item in g:ZFVimCmdMenu_curItemList
            if empty(item.key)
                let item.key = g:ZFVimCmdMenu_curSetting['defaultKeyList'][defaultKeyIndex]
                let defaultKeyIndex += 1
            endif
        endfor

        let choosedItem = s:process()
        let s:choosedItem = choosedItem
        if empty(choosedItem)
            continue
        endif

        if choosedItem.itemType == 'subMenu'
            call s:statePush()

            let g:ZFVimCmdMenu_curItemList = []
            let g:ZFVimCmdMenu_curItemIndex = 0
            let g:ZFVimCmdMenu_curSetting = {}
            call s:itemProcess(choosedItem)
            continue
        elseif choosedItem.itemType == 'keep'
            call s:itemProcess(choosedItem)
            continue
        else " normal or default
            call s:statePopAll()
            call s:itemProcess(choosedItem)
            let ret = choosedItem
            break
        endif
    endwhile

    if empty(g:ZFVimCmdMenu_curItemList) && exists('s:cmdheightSaved')
        let &cmdheight = s:cmdheightSaved
        unlet s:cmdheightSaved
    endif
    return ret
endfunction

function! s:statePush()
    call add(s:state, {
                \     'curItemList' : g:ZFVimCmdMenu_curItemList,
                \     'curItemIndex' : g:ZFVimCmdMenu_curItemIndex,
                \     'curSetting' : g:ZFVimCmdMenu_curSetting,
                \ })
endfunction
function! s:statePop()
    if !empty(s:state)
        let state = remove(s:state, len(s:state) - 1)
        let g:ZFVimCmdMenu_curItemList = state['curItemList']
        let g:ZFVimCmdMenu_curItemIndex = state['curItemIndex']
        let g:ZFVimCmdMenu_curSetting = state['curSetting']
    else
        call s:statePopAll()
    endif
endfunction
function! s:statePopAll()
    let g:ZFVimCmdMenu_curItemList = []
    let g:ZFVimCmdMenu_curItemIndex = 0
    let g:ZFVimCmdMenu_curSetting = {}

    let s:state = []
endfunction

function! s:updateUI()
    let content = []
    if !empty(g:ZFVimCmdMenu_curSetting['headerText'])
        call add(content, g:ZFVimCmdMenu_curSetting['headerText'])
        call add(content, ' ')
    endif

    let i = 0
    for item in g:ZFVimCmdMenu_curItemList
        let text = ''

        if i == g:ZFVimCmdMenu_curItemIndex
            let text .= g:ZFVimCmdMenu_curSetting['markText']
        else
            let text .= g:ZFVimCmdMenu_curSetting['indentText']
        endif

        if item.showKeyHint == 1 || (item.showKeyHint == -1 && g:ZFVimCmdMenu_curSetting['showKeyHint'])
            let text .= g:ZFVimCmdMenu_curSetting['showKeyHintL']
            let text .= item.key
            let text .= g:ZFVimCmdMenu_curSetting['showKeyHintR']
        endif

        let text .= item.text

        call add(content, text)
        let i += 1
    endfor

    if !empty(g:ZFVimCmdMenu_curSetting['footerText'])
        call add(content, ' ')
        call add(content, g:ZFVimCmdMenu_curSetting['footerText'])
    endif

    if !empty(g:ZFVimCmdMenu_curSetting['hintText'])
        call add(content, ' ')
        call add(content, g:ZFVimCmdMenu_curSetting['hintText'])
    endif

    let &cmdheight = len(content)
    redraw!
    echo join(content, "\n")
endfunction

" return processed item or empty dict if cancel
function! s:process()
    while 1
        call s:updateUI()
        try
            let cmd=getchar()
        catch
            let cmd=char2nr("\<esc>")
        endtry

        if cmd == char2nr("j")
            if g:ZFVimCmdMenu_curItemIndex + 1 < len(g:ZFVimCmdMenu_curItemList)
                let g:ZFVimCmdMenu_curItemIndex += 1
            else
                let g:ZFVimCmdMenu_curItemIndex = 0
            endif
            continue
        elseif cmd == char2nr("k")
            if g:ZFVimCmdMenu_curItemIndex > 0
                let g:ZFVimCmdMenu_curItemIndex -= 1
            else
                let g:ZFVimCmdMenu_curItemIndex = len(g:ZFVimCmdMenu_curItemList) - 1
            endif
            continue
        endif

        if s:processEsc(cmd)
            return {}
        endif

        if s:processConfirm(cmd)
            return s:choosedItem
        endif

        let processResult = s:processItem(cmd)
        if processResult == 0
            if g:ZFVimCmdMenu_curSetting['hideWhenNoMatch']
                redraw!
                if !empty(g:ZFVimCmdMenu_curSetting['cancelText'])
                    echo g:ZFVimCmdMenu_curSetting['cancelText']
                endif
                return {}
            else
                continue
            endif
        elseif processResult == 1
            return s:choosedItem
        elseif processResult == 2
            continue
        endif
    endwhile
endfunction

function! s:processEsc(cmd)
    let esc = 0
    if a:cmd == char2nr("\<esc>")
        let esc = 1
    elseif !empty(g:ZFVimCmdMenu_curSetting['escKeys'])
        for i in range(len(g:ZFVimCmdMenu_curSetting['escKeys']))
            if a:cmd == char2nr(g:ZFVimCmdMenu_curSetting['escKeys'][i])
                let esc = 1
                break
            endif
        endfor
    endif

    if esc == 1
        redraw!
        let cancelText = ''
        if !empty(g:ZFVimCmdMenu_curSetting['cancelText'])
            let cancelText = g:ZFVimCmdMenu_curSetting['cancelText']
        endif
        if g:ZFVimCmdMenu_curSetting['escGoBack']
            call s:statePop()
            if empty(g:ZFVimCmdMenu_curItemList)
                if !empty(cancelText)
                    echo cancelText
                endif
            endif
        else
            call s:statePopAll()
            if !empty(cancelText)
                echo cancelText
            endif
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
    elseif !empty(g:ZFVimCmdMenu_curSetting['confirmKeys'])
        for i in range(len(g:ZFVimCmdMenu_curSetting['confirmKeys']))
            if a:cmd == char2nr(g:ZFVimCmdMenu_curSetting['confirmKeys'][i])
                let confirm = 1
                break
            endif
        endfor
    endif

    if confirm == 1
        let s:choosedItem = s:itemSelected(g:ZFVimCmdMenu_curItemIndex)
        return 1
    else
        return 0
    endif
endfunction

" 0: no item matched
" 1: 1 item match, set s:choosedItem
" 2: more than 1 item match, continue loop to select them
function! s:processItem(cmd)
    let checked = []
    let i = 0
    for item in g:ZFVimCmdMenu_curItemList
        if a:cmd == char2nr(item.key)
            call add(checked, i)
        endif
        let i += 1
    endfor

    if len(checked) == 0
        return 0
    elseif len(checked) == 1
        let g:ZFVimCmdMenu_curItemIndex = checked[0]
        let s:choosedItem = s:itemSelected(checked[0])
        return 1
    elseif len(checked) > 1
        for i in range(len(checked))
            if g:ZFVimCmdMenu_curItemIndex == checked[i]
                if i + 1 < len(checked)
                    let g:ZFVimCmdMenu_curItemIndex = checked[i + 1]
                else
                    let g:ZFVimCmdMenu_curItemIndex = checked[0]
                endif
                return 2
            endif
        endfor
        let g:ZFVimCmdMenu_curItemIndex = checked[0]
        return 2
    else
        return 0
    endif
endfunction

function! s:itemSelected(index)
    return deepcopy(g:ZFVimCmdMenu_curItemList[a:index], 1)
endfunction

function! s:itemProcess(item)
    redraw!
    let item = a:item

    if !empty(item.command)
        execute item.command
    endif

    if !empty(item.callback)
        let t = ''
        for i in range(8)
            let param = item['callbackParam' . i]
            if empty(param)
                break
            endif
            if !empty(t)
                let t .= ','
            endif
            let t .= '"' . param . '"'
        endfor
        execute 'call ' . item.callback . '(' . t . ')'
    endif
endfunction

if 0
    function! ZF_VimCmdMenuTest()
        " define callback function
        function! MyCallback(...)
            echo 'function called with ' . a:0 . ' param:'
            for i in range(a:0)
                execute 'let t=a:' . (i + 1)
                echo t
            endfor
        endfunction
        function! MySubMenu()
            call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'sub menu item'})
            call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'sub menu item'})
            call ZF_VimCmdMenuAdd({'itemType':'subMenu', 'showKeyHint':1, 'text':'next sub menu', 'command':'call MySubMenu()'})
            call ZF_VimCmdMenuShow({'headerText':'select your sub menu choice:'})
        endfunction

        " add menu item
        call ZF_VimCmdMenuAdd({'key':'s', 'text':'(s)how sth', 'callback':'MyCallback', 'callbackParam0':'myParam0', 'callbackParam1':'myParam1'})
        call ZF_VimCmdMenuAdd({'key':'x', 'text':'e(x)ecute sth', 'command':'call MyCallback("test")'})
        call ZF_VimCmdMenuAdd({'key':'x', 'text':'e(x)ecute sth2', 'command':'call MyCallback("test")'})
        call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'loop', 'command':'call MyCallback("")'})
        call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'loop', 'command':'call MyCallback("")'})
        call ZF_VimCmdMenuAdd({'showKeyHint':1, 'text':'loop', 'command':'call MyCallback("")'})
        call ZF_VimCmdMenuAdd({'itemType':'subMenu', 'showKeyHint':1, 'text':'sub menu >', 'command':'call MySubMenu()'})

        " finally, show the menu
        let choosed = ZF_VimCmdMenuShow({'headerText':'select your choice:'})
        echo 'choosed:'
        echo choosed
    endfunction
    nnoremap zzz :call ZF_VimCmdMenuTest()<cr>
endif

