# ZFVimCmdMenu

vim script to make a menu in cmd line

if you like my work, [check here](https://github.com/ZSaberLv0?utf8=%E2%9C%93&tab=repositories&q=ZFVim) for a list of my vim plugins


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
    ```

1. you may save the above code to file then `:source` it to see the demo,
    which should looks like this:

    ```
    select your choice:

      > (s)how sth
        e(x)ecute sth
        e(x)ecute sth2
        (a) loop
        (b) loop
        (c) loop
        (d) sub menu >

    (choose by j/k, confirm by shortcut or <enter> or o, cancel by <esc> or q or <space>)
    ```

    the behavior should be same as [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)'s menu item

1. params in `ZF_VimCmdMenuAdd(item)`

    * `itemType` : the item's type
        * `normal` : normal item, close all parent menu when choosed
        * `subMenu` : sub menu item, close current menu only when choosed
        * `keep` : keep current menu when choosed
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

* `ZF_VimCmdMenuAdd(item)`
* `ZF_VimCmdMenuShow([setting])`

# settings

add this to your vimrc to change settings

```
let g:ZFVimCmdMenuSetting={}
let g:ZFVimCmdMenuSetting['xxx']=xxx
```

or, specify setting param to `ZF_VimCmdMenuShow` for local setting

all settings list:

* `let g:ZFVimCmdMenuSetting['escGoBack']=1`

    when pressed esc key, whether close all menu or go back to parent menu

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

