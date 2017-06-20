# ZFVimCmdMenu

vim script to make a menu in cmd line

# how to use

1. use [Vundle](https://github.com/VundleVim/Vundle.vim) or any other plugin manager you like to install

    ```
    Plugin 'ZSaberLv0/ZFVimCmdMenu'
    ```

1. create your menu

    ```
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
    ```

1. you may save the above code to file then `:source` it to see the demo,
    which should looks like this:

    ```
    select your choice:

      > (s)how sth
        e(x)ecute sth
        e(x)ecute sth2
        (d) loop
        (e) loop
        (f) loop

    (choose by j/k, confirm by shortcut or <enter> or o, cancel by <esc> or q or <space>)
    ```

    the behavior should be same as [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)'s menu item

1. params in `ZF_VimCmdMenuAdd(showKeyHint, key, text, command [, callback, callbackParam0, callbackParam1, ...])`

    * `showKeyHint` : whether to append key hint before menu item
        * `-1` : not specified, accorrding to `g:ZFVimCmdMenuSetting['showKeyHint']`
        * `0` : don't show
        * `1` : show
    * `key` : the key to activate the menu item, e.g. `s`,
        when empty, a default one would be generated,
        accorrding to `g:ZFVimCmdMenu_noNameItemKeyList`
    * `text` : the text of the menu item, can be any string
    * `command` : vim command to `:execute` when menu item selected, do nothing if empty
    * `callback` : vim function name to `:execute` when menu item selected, do nothing if empty
    * `callbackParam0 ~ callbackParam7` : params passed to `callback`, passed as string


# functions

* `ZF_VimCmdMenuAdd(showKeyHint, key, text, command [, callback, callbackParam0, callbackParam1, ...])`
* `ZF_VimCmdMenuShow([headerText, footerText])`
* `ZF_VimCmdMenuSettingSave()`
* `ZF_VimCmdMenuSettingRestore()`

# settings

add this to your vimrc to change settings

```
let g:ZFVimCmdMenuSetting={}
let g:ZFVimCmdMenuSetting['xxx']=xxx
```

all settings list:

* `let g:ZFVimCmdMenuSetting['confirmKeys']='o'`

    when pressed any of these keys, current menu item would be executed

    ENTER would always used to confirm a selection

* `let g:ZFVimCmdMenuSetting['escKeys']='q '`

    when pressed any of these keys, cancel and close the menu

    ESC would always used to close the menu,
    any other key that not registered,
    would also used to close the menu

* `let g:ZFVimCmdMenuSetting['hideWhenNoMatch']=0`

    when pressed a key that doesn't match any item, whether to hide the menu

* `let g:ZFVimCmdMenuSetting['showKeyHint']=0`

    when on, menu key hint would be printed before each menu item

    ```
    on              off
    (a) item0       item0
    (b) item1       item1
    (c) item2       item2
    ```

* `let g:ZFVimCmdMenuSetting['showKeyHintL']='('`
* `let g:ZFVimCmdMenuSetting['showKeyHintR']=') '`
* `let g:ZFVimCmdMenuSetting['hintText']='(choose by j/k, confirm by shortcut or <enter> or o, cancel by <esc> or q or <space>)'`
* `let g:ZFVimCmdMenuSetting['headerText']=''`
* `let g:ZFVimCmdMenuSetting['footerText']=''`
* `let g:ZFVimCmdMenuSetting['indentText']='    '`
* `let g:ZFVimCmdMenuSetting['markText']='  > '`
* `let g:ZFVimCmdMenuSetting['cancelText']='canceled'`
* `let g:ZFVimCmdMenuSetting['defaultKeyList']='abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'`

    if key not specified during `ZF_VimCmdMenuAdd()`,
    we will generate one for you

