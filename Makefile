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
install+=$(MWGDIR)/share/mshex/libexec
$(MWGDIR)/share/mshex/libexec:
	mkdir -p $@

#------------------------------------------------------------------------------
# directory shrc

out/shrc out/bin:
	mkdir -p $@



compile+=out/shrc/bashrc_common.sh
out/shrc/bashrc_common.sh: shrc/bashrc_common.pp | out/shrc
	cd shrc && $(MWGPP) bashrc_common.pp
compile+=out/shrc/zshrc_common.sh
out/shrc/zshrc_common.sh: out/shrc/bashrc_common.sh | out/shrc
	touch $@
install+=$(MWGDIR)/share/mshex/shrc/bashrc_common.sh
$(MWGDIR)/share/mshex/shrc/bashrc_common.sh: out/shrc/bashrc_common.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/zshrc_common.sh
$(MWGDIR)/share/mshex/shrc/zshrc_common.sh: out/shrc/zshrc_common.sh
	cp -pr $< $@

compile+=out/shrc/bashrc_interactive.sh
out/shrc/bashrc_interactive.sh: shrc/bashrc_interactive.pp | out/shrc
	cd shrc && $(MWGPP) bashrc_interactive.pp
compile+=out/shrc/zshrc_interactive.sh
out/shrc/zshrc_interactive.sh: out/shrc/bashrc_interactive.sh | out/shrc
	touch $@
install+=$(MWGDIR)/share/mshex/shrc/zshrc_interactive.sh
$(MWGDIR)/share/mshex/shrc/zshrc_interactive.sh: out/shrc/zshrc_interactive.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/bashrc_interactive.sh
$(MWGDIR)/share/mshex/shrc/bashrc_interactive.sh: out/shrc/bashrc_interactive.sh
	cp -pr $< $@

install+=$(MWGDIR)/share/mshex/shrc/bashrc_cygwin.sh
$(MWGDIR)/share/mshex/shrc/bashrc_cygwin.sh: shrc/bashrc_cygwin.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/cdhist.sh
$(MWGDIR)/share/mshex/shrc/cdhist.sh: shrc/cdhist.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/dict.sh
$(MWGDIR)/share/mshex/shrc/dict.sh: shrc/dict.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/term.sh
$(MWGDIR)/share/mshex/shrc/term.sh: shrc/term.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/menu.sh
$(MWGDIR)/share/mshex/shrc/menu.sh: shrc/menu.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/path.sh
$(MWGDIR)/share/mshex/shrc/path.sh: shrc/path.sh
	cp -pr $< $@
install+=$(MWGDIR)/share/mshex/shrc/less.sh
$(MWGDIR)/share/mshex/shrc/less.sh: shrc/less.sh
	cp -pr $< $@

# 以下は互換性の為
compile+=out/shrc/libmwg_src.sh
out/shrc/libmwg_src.sh: shrc/libmwg_src.pp | out/shrc
	$(MWGPP) shrc/libmwg_src.pp > out/shrc/libmwg_src.sh
install+=$(MWGDIR)/bashrc
$(MWGDIR)/bashrc: shrc/bashrc
	cp -pr $< $@
install+=$(MWGDIR)/bashrc.cygwin
$(MWGDIR)/bashrc.cygwin: shrc/bashrc.cygwin
	cp -pr $< $@

#------------------------------------------------------------------------------
# directory bin


install+=$(MWGDIR)/bin/modmod
$(MWGDIR)/bin/modmod: bin/modmod
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/makepp
$(MWGDIR)/bin/makepp: bin/makepp
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/mwgbk
$(MWGDIR)/bin/mwgbk: bin/mwgbk
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/msync
$(MWGDIR)/bin/msync: bin/msync
	./make-install_script.sh copy -s $< $@
compile+=out/bin/remove
install+=$(MWGDIR)/bin/remove
$(MWGDIR)/bin/remove: out/bin/remove
	./make-install_script.sh copy -s $< $@
out/bin/remove: bin/remove | out/bin
	$(MWGPP) $< > $@ && chmod +x $@
compile+=out/bin/mshex
install+=$(MWGDIR)/bin/mshex
$(MWGDIR)/bin/mshex: out/bin/mshex
	./make-install_script.sh copy -s $< $@
out/bin/mshex: bin/mshex | out/bin
	$(MWGPP) $< > $@ && chmod +x $@
install+=$(MWGDIR)/bin/move
$(MWGDIR)/bin/move: bin/move
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/src
$(MWGDIR)/bin/src: bin/src
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/findsrc
$(MWGDIR)/bin/findsrc: bin/findsrc
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/grc
$(MWGDIR)/bin/grc: bin/grc
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/cz
$(MWGDIR)/bin/cz: bin/cz
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/czless
$(MWGDIR)/bin/czless: bin/czless
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/pass
$(MWGDIR)/bin/pass: bin/pass
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/passgen
$(MWGDIR)/bin/passgen: bin/passgen
	./make-install_script.sh copy -s $< $@
compile+=out/bin/ren
install+=$(MWGDIR)/bin/ren
$(MWGDIR)/bin/ren: out/bin/ren
	./make-install_script.sh copy -s $< $@
out/bin/ren: bin/ren | out/bin
	$(MWGPP) $< > $@ && chmod +x $@
install+=$(MWGDIR)/bin/ifold
$(MWGDIR)/bin/ifold: bin/ifold
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/refact
$(MWGDIR)/bin/refact: bin/refact
	./make-install_script.sh copy -s $< $@
install+=$(MWGDIR)/bin/tarc
$(MWGDIR)/bin/tarc: bin/tarc
	./make-install_script.sh copy -s $< $@

#------------------------------------------------------------------------------
# directory libexec

install += $(MWGDIR)/share/mshex/libexec/ren-mv.exe
compile += out/libexec/ren-mv.exe
$(MWGDIR)/share/mshex/libexec/ren-mv.exe: out/libexec/ren-mv.exe
	cp $< $@
out/libexec/ren-mv.exe: src/ren-mv.c | out/libexec
	gcc -std=gnu99 -o $@ $<
out/libexec:
	mkdir -p $@

#------------------------------------------------------------------------------
# directory source-highlight

ifneq ($(shell which source-highlight 2>/dev/null),)

srchilite_dir := $(MWGDIR)/share/mshex/source-highlight
install += $(srchilite_dir)
$(srchilite_dir):
	./make-install_script.sh initialize-source-highlight $@

install += $(srchilite_dir)/bash_simple_expansion.lang
$(srchilite_dir)/bash_simple_expansion.lang: source-highlight/bash_simple_expansion.lang | $(srchilite_dir)
	test -d $(srchilite_dir) && ./make-install_script.sh copy $< $@
install += $(srchilite_dir)/esc256-light_background.outlang
$(srchilite_dir)/esc256-light_background.outlang: source-highlight/esc256-light_background.outlang | $(srchilite_dir)
	test -d $(srchilite_dir) && ./make-install_script.sh copy $< $@
install += $(srchilite_dir)/my.style
$(srchilite_dir)/my.style: source-highlight/my.style | $(srchilite_dir)
	test -d $(srchilite_dir) && ./make-install_script.sh copy $< $@
install += $(srchilite_dir)/sh.lang
$(srchilite_dir)/sh.lang: source-highlight/sh.lang | $(srchilite_dir)
	test -d $(srchilite_dir) && ./make-install_script.sh copy $< $@
install += $(srchilite_dir)/x86.lang
$(srchilite_dir)/x86.lang: source-highlight/x86.lang | $(srchilite_dir)
	test -d $(srchilite_dir) && ./make-install_script.sh copy $< $@

endif

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	./update.sh

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~ --exclude=./mshex/.git --exclude=./mshex/shrc/out
