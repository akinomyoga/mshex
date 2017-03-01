# -*- mode: makefile-gmake; -*-

# ※Makefile 記述時の注意:
#   -C だと $(PWD) は設定されないので $(CURDIR) を用いる。
#   参考: [[とあるエンジニアの備忘log: make の -C オプションについて>http://masahir0y.blogspot.jp/2012/06/make-c.html]]

MWGDIR:=$(HOME)/.mwg
MWGPP:=$(CURDIR)/ext/mwg_pp.awk

all: compile
.PHONY: all install dist compile

Makefile: Makefile.pp
	$(MWGPP) $< > $@

install+=$(MWGDIR)
$(MWGDIR):
	mkdir -p $@
install+=$(MWGDIR)/bin
$(MWGDIR)/bin:
	mkdir -p $@
install+=$(MWGDIR)/share/mshex/shrc
$(MWGDIR)/share/mshex/shrc:
	mkdir -p $@

#------------------------------------------------------------------------------
# directory shrc

out/shrc out/bin:
	mkdir -p $@



compile+=out/shrc/bashrc
out/shrc/bashrc: shrc/bashrc.pp | out/shrc
	cd shrc && $(MWGPP) bashrc.pp
compile+=out/shrc/zshrc
out/shrc/zshrc: out/shrc/bashrc | out/shrc
	touch $@
install+=$(MWGDIR)/bashrc
$(MWGDIR)/bashrc: out/shrc/bashrc
	cp -p $< $@
install+=$(MWGDIR)/zshrc
$(MWGDIR)/zshrc: out/shrc/zshrc
	cp -p $< $@

compile+=out/shrc/bashrc_interactive
out/shrc/bashrc_interactive: shrc/bashrc_interactive.pp | out/shrc
	cd shrc && $(MWGPP) bashrc_interactive.pp
compile+=out/shrc/zshrc_interactive
out/shrc/zshrc_interactive: out/shrc/bashrc_interactive | out/shrc
	touch $@
install+=$(MWGDIR)/share/mshex/shrc/zshrc_interactive
$(MWGDIR)/share/mshex/shrc/zshrc_interactive: out/shrc/zshrc_interactive
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/bashrc_interactive
$(MWGDIR)/share/mshex/shrc/bashrc_interactive: out/shrc/bashrc_interactive
	cp -p $< $@

install+=$(MWGDIR)/bashrc.cygwin
$(MWGDIR)/bashrc.cygwin: shrc/bashrc.cygwin
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/bash_tools
$(MWGDIR)/share/mshex/shrc/bash_tools: shrc/bash_tools
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/dict.sh
$(MWGDIR)/share/mshex/shrc/dict.sh: shrc/dict.sh
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/term.sh
$(MWGDIR)/share/mshex/shrc/term.sh: shrc/term.sh
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/menu.sh
$(MWGDIR)/share/mshex/shrc/menu.sh: shrc/menu.sh
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/path.sh
$(MWGDIR)/share/mshex/shrc/path.sh: shrc/path.sh
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/x86.lang
$(MWGDIR)/share/mshex/shrc/x86.lang: shrc/x86.lang
	cp -p $< $@

# 以下は互換性の為
compile+=out/shrc/libmwg_src.sh
out/shrc/libmwg_src.sh: shrc/libmwg_src.pp | out/shrc
	$(MWGPP) shrc/libmwg_src.pp > out/shrc/libmwg_src.sh

#------------------------------------------------------------------------------
# directory bin


install+=$(MWGDIR)/bin/modmod
$(MWGDIR)/bin/modmod: bin/modmod
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/makepp
$(MWGDIR)/bin/makepp: bin/makepp
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/mwgbk
$(MWGDIR)/bin/mwgbk: bin/mwgbk
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/msync
$(MWGDIR)/bin/msync: bin/msync
	$(SHELL) make-install_script.sh $< $@
compile+=out/bin/remove
install+=$(MWGDIR)/bin/remove
$(MWGDIR)/bin/remove: out/bin/remove
	$(SHELL) make-install_script.sh $< $@
out/bin/remove: bin/remove | out/bin
	$(MWGPP) $< > $@ && chmod +x $@
install+=$(MWGDIR)/bin/move
$(MWGDIR)/bin/move: bin/move
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/src
$(MWGDIR)/bin/src: bin/src
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/findsrc
$(MWGDIR)/bin/findsrc: bin/findsrc
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/grc
$(MWGDIR)/bin/grc: bin/grc
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/cz
$(MWGDIR)/bin/cz: bin/cz
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/czless
$(MWGDIR)/bin/czless: bin/czless
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/ren
$(MWGDIR)/bin/ren: bin/ren
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/ifold
$(MWGDIR)/bin/ifold: bin/ifold
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/refact
$(MWGDIR)/bin/refact: bin/refact
	$(SHELL) make-install_script.sh $< $@

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	$(SHELL) update.sh

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~ --exclude=./mshex/.git --exclude=./mshex/shrc/out
