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

#%m shrc_pp
compile+=out/shrc/%out%
out/shrc/%out%: shrc/%in% | out/shrc
	cd shrc && $(MWGPP) %in%
#%end
#%m shrc_ppd
compile+=out/shrc/%out%
out/shrc/%out%: out/shrc/%ref% | out/shrc
	touch $@
#%end
#%m shrc_pp0
compile+=out/shrc/%out%
out/shrc/%out%: shrc/%in% | out/shrc
	$(MWGPP) shrc/%in% > out/shrc/%out%
#%end

#%m install
install+=$(MWGDIR)/%d%
$(MWGDIR)/%d%: %s%
	cp -pr $< $@
#%end

#%x shrc_pp .r|%in%|bashrc_common.pp|  	       .r|%out%|bashrc_common.sh|
#%x shrc_ppd.r|%ref%|bashrc_common.sh| 	       .r|%out%|zshrc_common.sh|
#%x install .r|%s%|out/shrc/bashrc_common.sh|  .r|%d%|share/mshex/shrc/bashrc_common.sh|
#%x install .r|%s%|out/shrc/zshrc_common.sh|   .r|%d%|share/mshex/shrc/zshrc_common.sh|

#%x shrc_pp .r|%in%|bashrc_interactive.pp|     .r|%out%|bashrc_interactive|
#%x shrc_ppd.r|%ref%|bashrc_interactive|       .r|%out%|zshrc_interactive|
#%x install .r|%s%|out/shrc/zshrc_interactive| .r|%d%|share/mshex/shrc/zshrc_interactive|
#%x install .r|%s%|out/shrc/bashrc_interactive|.r|%d%|share/mshex/shrc/bashrc_interactive|

#%x install.r|%s%|shrc/bashrc|       .r|%d%|bashrc|
#%x install.r|%s%|shrc/bashrc.cygwin|.r|%d%|bashrc.cygwin|
#%x install.r|%s%|shrc/bash_tools|   .r|%d%|share/mshex/shrc/bash_tools|
#%x install.r|%s%|shrc/dict.sh|	     .r|%d%|share/mshex/shrc/dict.sh|
#%x install.r|%s%|shrc/term.sh|	     .r|%d%|share/mshex/shrc/term.sh|
#%x install.r|%s%|shrc/menu.sh|	     .r|%d%|share/mshex/shrc/menu.sh|
#%x install.r|%s%|shrc/path.sh|	     .r|%d%|share/mshex/shrc/path.sh|
#%x install.r|%s%|shrc/less.sh|	     .r|%d%|share/mshex/shrc/less.sh|

# 以下は互換性の為
#%x shrc_pp0 .r|%in%|libmwg_src.pp|.r|%out%|libmwg_src.sh|

#------------------------------------------------------------------------------
# directory bin

#%m bin_file (
install+=$(MWGDIR)/bin/%file%
$(MWGDIR)/bin/%file%: bin/%file%
	./make-install_script.sh copy -s $< $@
#%)
#%m bin_pp
compile+=out/bin/%file%
install+=$(MWGDIR)/bin/%file%
$(MWGDIR)/bin/%file%: out/bin/%file%
	./make-install_script.sh copy -s $< $@
out/bin/%file%: bin/%file% | out/bin
	$(MWGPP) $< > $@ && chmod +x $@
#%end

#%x bin_file.r|%file%|modmod|
#%x bin_file.r|%file%|makepp|
#%x bin_file.r|%file%|mwgbk|
#%x bin_file.r|%file%|msync|
#%x bin_pp.r|%file%|remove|
#%x bin_pp.r|%file%|mshex|
#%x bin_file.r|%file%|move|
#%x bin_file.r|%file%|src|
#%x bin_file.r|%file%|findsrc|
#%x bin_file.r|%file%|grc|
#%x bin_file.r|%file%|cz|
#%x bin_file.r|%file%|czless|
#%x bin_file.r|%file%|pass|
#%x bin_file.r|%file%|passgen|
#%x bin_file.r|%file%|ren|
#%x bin_file.r|%file%|ifold|
#%x bin_file.r|%file%|refact|
#%x bin_file.r|%file%|tarc|

#------------------------------------------------------------------------------
# directory source-highlight

ifneq ($(shell which source-highlight 2>/dev/null),)

srchilite_dir := $(MWGDIR)/share/mshex/source-highlight
install += $(srchilite_dir)
$(srchilite_dir):
	./make-install_script.sh initialize-source-highlight $@

#%m srchilite_file
install += $(srchilite_dir)/%file%
$(srchilite_dir)/%file%: source-highlight/%file% | $(srchilite_dir)
	test -d $(srchilite_dir) && ./make-install_script.sh copy $< $@
#%end
#%x srchilite_file.r|%file%|bash_simple_expansion.lang|
#%x srchilite_file.r|%file%|esc256-light_background.outlang|
#%x srchilite_file.r|%file%|my.style|
#%x srchilite_file.r|%file%|sh.lang|
#%x srchilite_file.r|%file%|x86.lang|

endif

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	./update.sh

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~ --exclude=./mshex/.git --exclude=./mshex/shrc/out
