# -*- mode: makefile-gmake; -*-

MWGDIR:=$(HOME)/.mwg
MWGPP:=$(PWD)/ext/mwg_pp.awk

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

#%m shrc_pp (
compile+=shrc/%out%
shrc/%out%: shrc/%in%
	cd shrc && $(MWGPP) %in%
#%)
#%m shrc_ppd (
compile+=shrc/%out%
shrc/%out%: shrc/%ref%
	touch $@
#%)
#%m shrc_pp0 (
compile+=shrc/%out%
shrc/%out%: shrc/%in%
	cd shrc && $(MWGPP) %in% > %out%
#%)

#%m install (
install+=$(MWGDIR)/%d%
$(MWGDIR)/%d%: %s%
	cp -p $< $@
#%)

compile+=shrc/out
shrc/out:
	mkdir -p $@

#%x shrc_pp .r|%in%|bashrc.pp|.r|%out%|out/bashrc|
#%x shrc_ppd.r|%ref%|out/bashrc|  .r|%out%|out/zshrc|
#%x install.r|%s%|shrc/out/bashrc|  .r|%d%|bashrc|
#%x install.r|%s%|shrc/out/zshrc|   .r|%d%|zshrc|

#%x shrc_pp .r|%in%|bashrc_interactive.pp|.r|%out%|out/bashrc_interactive|
#%x shrc_ppd.r|%ref%|out/bashrc_interactive|  .r|%out%|out/zshrc_interactive|
#%x install.r|%s%|shrc/out/zshrc_interactive|   .r|%d%|share/mshex/shrc/zshrc_interactive|
#%x install.r|%s%|shrc/out/bashrc_interactive|  .r|%d%|share/mshex/shrc/bashrc_interactive|

#%x install.r|%s%|shrc/bashrc.cygwin|.r|%d%|bashrc.cygwin|
#%x install.r|%s%|shrc/bash_tools|.r|%d%|share/mshex/shrc/bash_tools|
#%x install.r|%s%|shrc/dict.sh|.r|%d%|share/mshex/shrc/dict.sh|
#%x install.r|%s%|shrc/term.sh|.r|%d%|share/mshex/shrc/term.sh|
#%x install.r|%s%|shrc/menu.sh|.r|%d%|share/mshex/shrc/menu.sh|
#%x install.r|%s%|shrc/path.sh|.r|%d%|share/mshex/shrc/path.sh|

# 以下は互換性の為
#%x shrc_pp0 .r|%in%|libmwg_src.pp|.r|%out%|out/libmwg_src.sh|

#------------------------------------------------------------------------------
# directory bin

#%m bin_file (
install+=$(MWGDIR)/bin/%file%
$(MWGDIR)/bin/%file%: bin/%file%
	$(SHELL) make-install_script.sh $< $@
#%)
#%x bin_file.r|%file%|modmod|
#%x bin_file.r|%file%|makepp|
#%x bin_file.r|%file%|mwgbk|
#%x bin_file.r|%file%|msync|
#%x bin_file.r|%file%|rm_i|
#%x bin_file.r|%file%|~mv|
#%x bin_file.r|%file%|findsrc|
#%x bin_file.r|%file%|grc|
#%x bin_file.r|%file%|cz|
#%x bin_file.r|%file%|czless|
#%x bin_file.r|%file%|ren|
#%x bin_file.r|%file%|ifold|
#%x bin_file.r|%file%|refact|

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	$(SHELL) update.sh

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~ --exclude=./mshex/.git --exclude=./mshex/shrc/out
