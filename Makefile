# -*- mode:makefile-gmake -*-

MWGDIR:=$(HOME)/.mwg
MWGPP:=ext/mwg_pp.awk

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



compile+=shrc/out
shrc/out:
	mkdir -p $@

compile+=shrc/out/bashrc
shrc/out/bashrc: shrc/bashrc.pp
	cd shrc && mwg_pp.awk bashrc.pp
compile+=shrc/out/zshrc
shrc/out/zshrc: shrc/out/bashrc
	touch $@
install+=$(MWGDIR)/bashrc
$(MWGDIR)/bashrc: shrc/out/bashrc
	cp -p $< $@
install+=$(MWGDIR)/zshrc
$(MWGDIR)/zshrc: shrc/out/zshrc
	cp -p $< $@

compile+=shrc/out/bashrc_interactive
shrc/out/bashrc_interactive: shrc/bashrc_interactive.pp
	cd shrc && mwg_pp.awk bashrc_interactive.pp
compile+=shrc/out/zshrc_interactive
shrc/out/zshrc_interactive: shrc/out/bashrc_interactive
	touch $@
install+=$(MWGDIR)/share/mshex/shrc/zshrc_interactive
$(MWGDIR)/share/mshex/shrc/zshrc_interactive: shrc/out/zshrc_interactive
	cp -p $< $@
install+=$(MWGDIR)/share/mshex/shrc/bashrc_interactive
$(MWGDIR)/share/mshex/shrc/bashrc_interactive: shrc/out/bashrc_interactive
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

# 以下は互換性の為
compile+=shrc/out/libmwg_src.sh
shrc/out/libmwg_src.sh: shrc/libmwg_src.pp
	cd shrc && $(MWGPP) libmwg_src.pp > out/libmwg_src.sh

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
install+=$(MWGDIR)/bin/rm_i
$(MWGDIR)/bin/rm_i: bin/rm_i
	$(SHELL) make-install_script.sh $< $@
install+=$(MWGDIR)/bin/~mv
$(MWGDIR)/bin/~mv: bin/~mv
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
