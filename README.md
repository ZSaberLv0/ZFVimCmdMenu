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
    let choosed = ZF_VimCmdMenuShow()
    echo 'choosed:'
    echo choosed
    ```

1. you may save the above code to file then `:source` it to see the demo,
    which should looks like this:

    ```
    choose by j/k, confirm by press key or <enter>
    > (s)how sth
      e(x)ecute sth
      e(x)ecute sth2
      (a) loop
      (b) loop
      (b) loop
    ```

    the behavior should be same as [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)'s menu item

1. params in `ZF_VimCmdMenuAdd(key, text, command [, callback, callbackParam0, callbackParam1, ...])`

    * `showKeyHint` : whether to append key hint before menu item
        * `-1` : not specified, accorrding to `g:ZFVimCmdMenu_appendKeyHint`
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
* `ZF_VimCmdMenuShow()`
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

* `let g:ZFVimCmdMenuSetting['appendKeyHint']=0`

    when on, menu key hint would be printed before each menu item

    ```
    on              off
    (a) item0       item0
    (b) item1       item1
    (c) item2       item2
    ```

* `let g:ZFVimCmdMenuSetting['appendKeyHintL']='('`
* `let g:ZFVimCmdMenuSetting['appendKeyHintR']=') '`
* `let g:ZFVimCmdMenuSetting['headerText']='choose by j/k, confirm by press key or <enter>'`
* `let g:ZFVimCmdMenuSetting['footerText']=''`
* `let g:ZFVimCmdMenuSetting['indentText']='  '`
* `let g:ZFVimCmdMenuSetting['markText']='> '`
* `let g:ZFVimCmdMenuSetting['cancelText']='canceled'`
* `let g:ZFVimCmdMenuSetting['defaultKeyList']='abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'`

    if key not specified during `ZF_VimCmdMenuAdd()`,
    we will generate one for you

