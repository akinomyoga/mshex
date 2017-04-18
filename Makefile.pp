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

#%m dir (
install+=%name%
%name%:
	mkdir -p $@
#%)
#%x dir.r|%name%|$(MWGDIR)|
#%x dir.r|%name%|$(MWGDIR)/bin|
#%x dir.r|%name%|$(MWGDIR)/share/mshex/shrc|

#------------------------------------------------------------------------------
# directory shrc

out/shrc out/bin:
	mkdir -p $@

#%m shrc_pp (
compile+=out/shrc/%out%
out/shrc/%out%: shrc/%in% | out/shrc
	cd shrc && $(MWGPP) %in%
#%)
#%m shrc_ppd (
compile+=out/shrc/%out%
out/shrc/%out%: out/shrc/%ref% | out/shrc
	touch $@
#%)
#%m shrc_pp0 (
compile+=out/shrc/%out%
out/shrc/%out%: shrc/%in% | out/shrc
	$(MWGPP) shrc/%in% > out/shrc/%out%
#%)

#%m install (
install+=$(MWGDIR)/%d%
$(MWGDIR)/%d%: %s%
	cp -p $< $@
#%)

#%x shrc_pp .r|%in%|bashrc.pp|.r|%out%|bashrc|
#%x shrc_ppd.r|%ref%|bashrc|  .r|%out%|zshrc|
#%x install.r|%s%|out/shrc/bashrc|  .r|%d%|bashrc|
#%x install.r|%s%|out/shrc/zshrc|   .r|%d%|zshrc|

#%x shrc_pp .r|%in%|bashrc_interactive.pp|.r|%out%|bashrc_interactive|
#%x shrc_ppd.r|%ref%|bashrc_interactive|  .r|%out%|zshrc_interactive|
#%x install.r|%s%|out/shrc/zshrc_interactive|   .r|%d%|share/mshex/shrc/zshrc_interactive|
#%x install.r|%s%|out/shrc/bashrc_interactive|  .r|%d%|share/mshex/shrc/bashrc_interactive|

#%x install.r|%s%|shrc/bashrc.cygwin|.r|%d%|bashrc.cygwin|
#%x install.r|%s%|shrc/bash_tools|.r|%d%|share/mshex/shrc/bash_tools|
#%x install.r|%s%|shrc/dict.sh|.r|%d%|share/mshex/shrc/dict.sh|
#%x install.r|%s%|shrc/term.sh|.r|%d%|share/mshex/shrc/term.sh|
#%x install.r|%s%|shrc/menu.sh|.r|%d%|share/mshex/shrc/menu.sh|
#%x install.r|%s%|shrc/path.sh|.r|%d%|share/mshex/shrc/path.sh|
#%x install.r|%s%|shrc/x86.lang|.r|%d%|share/mshex/shrc/x86.lang|

# 以下は互換性の為
#%x shrc_pp0 .r|%in%|libmwg_src.pp|.r|%out%|libmwg_src.sh|

#------------------------------------------------------------------------------
# directory bin

#%m bin_file (
install+=$(MWGDIR)/bin/%file%
$(MWGDIR)/bin/%file%: bin/%file%
	$(SHELL) make-install_script.sh $< $@
#%)
#%m bin_pp
compile+=out/bin/%file%
install+=$(MWGDIR)/bin/%file%
$(MWGDIR)/bin/%file%: out/bin/%file%
	$(SHELL) make-install_script.sh $< $@
out/bin/%file%: bin/%file% | out/bin
	$(MWGPP) $< > $@ && chmod +x $@
#%end

#%x bin_file.r|%file%|modmod|
#%x bin_file.r|%file%|makepp|
#%x bin_file.r|%file%|mwgbk|
#%x bin_file.r|%file%|msync|
#%x bin_pp.r|%file%|remove|
#%x bin_file.r|%file%|move|
#%x bin_file.r|%file%|src|
#%x bin_file.r|%file%|findsrc|
#%x bin_file.r|%file%|grc|
#%x bin_file.r|%file%|cz|
#%x bin_file.r|%file%|czless|
#%x bin_file.r|%file%|ren|
#%x bin_file.r|%file%|ifold|
#%x bin_file.r|%file%|refact|
#%x bin_file.r|%file%|tarc|

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	$(SHELL) update.sh

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~ --exclude=./mshex/.git --exclude=./mshex/shrc/out
