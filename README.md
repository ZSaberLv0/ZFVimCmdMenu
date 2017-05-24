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
        echo a:0
        for i in range(a:0)
            execute 'let t=a:' . (i + 1)
            echo t
        endfor
    endfunction

    " add menu item
    call ZF_VimCmdMenuAdd('s', '(s)how sth', 'MyCallback', 'myParam0', 'myParam1')
    call ZF_VimCmdMenuAdd('x', 'e(x)ecute sth', 'MyCallback')

    " finally, show the menu
    call ZF_VimCmdMenuShow()
    ```

1. you may save the above code to file then `:source` it to see the demo,
    which should looks like this:

    ```
    choose by j/k, confirm by press key or <enter>
    > (s)how sth
      e(x)ecute sth
    ```

    the behavior should be same as [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)'s menu item

# settings

* `let g:ZFVimCmdMenu_confirmKeys='o'`

    when pressed any of these keys, current menu item would be executed

* `let g:ZFVimCmdMenu_appendKeyHint=0`

    when on, menu key hint would be printed before each menu item

    ```
    on              off
    (a) item0       item0
    (b) item1       item1
    (c) item2       item2
    ```

* `let g:ZFVimCmdMenu_appendKeyHintLeftText='('`
* `let g:ZFVimCmdMenu_appendKeyHintRightText=') '`
* `let g:ZFVimCmdMenu_headerText='choose by j/k, confirm by press key or <enter>'`
* `let g:ZFVimCmdMenu_footerText=''`
* `let g:ZFVimCmdMenu_indentText='  '`
* `let g:ZFVimCmdMenu_markText='> '`
* `let g:ZFVimCmdMenu_cancelText='canceled'`
* `let g:ZFVimCmdMenu_noNameItemKeyList='abcdefghilmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'`

    if key not specified during `ZF_VimCmdMenuAdd()`,
    we will generate one for you,
    accorrding to the order of `g:ZFVimCmdMenu_noNameItemKeyList`

