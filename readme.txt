===============================================================================
 mshex - my shell extensions
===============================================================================

  Copyright (c) 2010-2017 K. Murase, All rights reserved.

-------------------------------------------------------------------------------
  設定の仕方
-------------------------------------------------------------------------------

Run the following commands. The directory ~/.mwg will be created, and the
scripts and settings are copied into the directory.

    $ tar xvf mshex.20121001.tar.xz
    $ cd mshex
    $ make install

Edit your bashrc file to source the ~/.mwg/bashrc. To use the useful commands
contained in this package, please add ~/.mwg/bin to the PATH environment
variable.

    $ emacs ~/.bashrc

    # bashrc
    . ~/.mwg/bashrc &>/dev/null
    PATH="$HOME/bin:$HOME/.mwg/bin:$PATH"

-------------------------------------------------------------------------------
  機能の一覧 (簡易)
-------------------------------------------------------------------------------

~/.mwg/bin にインストールされるスクリプト

  コピー&実行

    crun executable   copy the executable to run
    crun program.cxx  compile the program.cxx to run

  ファイル暗号化

    cz file           encrypt the file
    cz file.cz        decrypt the file
    czless file.cz    view contents of the encrypted file

  ソースファイル

    findsrc           find source file names
    grc               grep patterns from the source files
    refact            replace tokens in the source files
    makepp            update Makefile from Makefile.pp

  ファイル操作

    mwgbk             create backup to file.20150101.ext
    ren               rename files with regex (ERE)
    remove            safe file removes backupped into ~/.recycle
    move              safe file moves
    modmod            modify cygwin permissions
    msync             backupped synchronization


source ~/.mwg/bashrc による設定

  ジョブ管理

    $ j       jobs
    $ f       fg %
    $ F       fg %-
    $ NUM     fg %NUM

    M-z       fg
    C-z       fg

  ディレクトリ移動

    $ c       cd -        前のディレクトリ
    $ C       cd ..       一つ上のディレクトリ

    M-c       ディレクトリ移動履歴を表示、カーソルキーで選択

  Devel

    m         make        Makefile のあるディレクトリまで遡って make を実行
    g ...     git "$@"
    g         git status
    g d[NUM]  git diff

  他

    $ h       history     最近の history 項目
    $ d       date; cal   現在の日時を表示
    $ w       (元々ある)

    他にも基本機能をいろいろ割り当て

  設定

    履歴・tty・checkwinsize・TRAPERR・LANGなど

source ~/.mwg/share/mshex/shrc/path.sh による関数

  PATH.canonicalize [-v VARNAME] [-F SEP]
  PATH.prepend      [-v VARNAME] [-F SEP] [-n] PATHS...
  PATH.append       [-v VARNAME] [-F SEP] [-n] PATHS...
  PATH.remove       [-v VARNAME] [-F SEP] PATHS...
  PATH.show         [VARNAME]
  -v VARNAME  変更する変数名。既定値 PATH
  -F SEP      パスの区切に使用する文字。既定値 :
  -n          存在しないパスは追加しない
