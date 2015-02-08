# -*- mode:makefile-gmake -*-

MWGDIR:=$(HOME)/.mwg

all: compile
.PHONY: all install dist compile

Makefile: Makefile.pp
	mwg_pp.awk $< > $@

#%m dir (
install+=%name%
%name%:
	mkdir -p $@
#%)
#%x dir.r|%name%|$(MWGDIR)|
#%x dir.r|%name%|$(MWGDIR)/bin|
#%x dir.r|%name%|$(MWGDIR)/share/mshex/shrc|
##%x dir.r|%name%|$(MWGDIR)/shrc.d|
##%x dir.r|%name%|$(MWGDIR)/shrc.d/tools|

#------------------------------------------------------------------------------
# directory shrc

#%m shrc_pp (
compile+=shrc/%out%
shrc/%out%: shrc/%in%
	cd shrc && mwg_pp.awk %in%
#%)
#%m shrc_ppd (
compile+=shrc/%out%
shrc/%out%: shrc/%ref%
	touch $@
#%)
#%m pp (
compile+=shrc/%out%
shrc/%out%: shrc/%in%
	cd shrc && mwg_pp.awk %in% > %out%
#%)

#%m install (
install+=$(MWGDIR)/%d%
$(MWGDIR)/%d%: %s%
	cp -p $< $@
#%)

#%x shrc_pp .r|%in%|bashrc.pp|.r|%out%|bashrc|
#%x shrc_ppd.r|%ref%|bashrc|  .r|%out%|zshrc|
#%x install.r|%s%|shrc/zshrc|   .r|%d%|zshrc|
#%x install.r|%s%|shrc/bashrc|  .r|%d%|bashrc|

#%x shrc_pp .r|%in%|bashrc_interactive.pp|.r|%out%|bashrc_interactive|
#%x shrc_ppd.r|%ref%|bashrc_interactive|  .r|%out%|zshrc_interactive|
#%x install.r|%s%|shrc/zshrc_interactive|   .r|%d%|share/mshex/shrc/zshrc_interactive|
#%x install.r|%s%|shrc/bashrc_interactive|  .r|%d%|share/mshex/shrc/bashrc_interactive|

#%x install.r|%s%|shrc/bashrc.cygwin|.r|%d%|bashrc.cygwin|
#%x install.r|%s%|shrc/bash_tools|.r|%d%|share/mshex/shrc/bash_tools|
#%x install.r|%s%|shrc/lib/dict.sh|.r|%d%|share/mshex/shrc/dict.sh|
#%x install.r|%s%|shrc/lib/term.sh|.r|%d%|share/mshex/shrc/term.sh|
#%x install.r|%s%|shrc/lib/menu.sh|.r|%d%|share/mshex/shrc/menu.sh|
#%x install.r|%s%|shrc/lib/path.sh|.r|%d%|share/mshex/shrc/path.sh|

# 以下は互換性の為
##%x install.r|%s%|shrc/tools/menu.bash_source|.r|%d%|share/mshex/shrc/menu.bash_source|
#%x pp .r|%in%|libmwg_src.pp|.r|%out%|libmwg_src.sh|


# # bashrc_interactive.3 [2013-05-28 14:20:30 廃止]
# #%x shrc_ppd.r|%ref%|bashrc_interactive|  .r|%out%|bashrc_interactive.3|
# #%x install.r|%s%|shrc/bashrc_interactive.3|.r|%d%|share/mshex/shrc/bashrc_interactive.3|

# # mwg_term [2013-05-28 13:18:45 廃止]
# #%x shrc_pp .r|%in%|mwg_term.pp|    .r|%out%|mwg_term.bash|
# #%x shrc_ppd.r|%ref%|mwg_term.bash| .r|%out%|mwg_term.bash3|
# #%x shrc_ppd.r|%ref%|mwg_term.bash| .r|%out%|mwg_term.zsh|
# #%x install.r|%s%|shrc/mwg_term.sh|  .r|%d%|share/mshex/shrc/mwg_term.sh|
# #%x install.r|%s%|shrc/mwg_term.bash|  .r|%d%|share/mshex/shrc/mwg_term.bash|
# #%x install.r|%s%|shrc/mwg_term.bash3| .r|%d%|share/mshex/shrc/mwg_term.bash3|
# # #%x install.r|%s%|shrc/mwg_term.zsh|   .r|%d%|share/mshex/shrc/mwg_term.zsh|

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
#%x bin_file.r|%file%|refact|

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	$(SHELL) update.sh

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~
