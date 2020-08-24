# -*- mode: makefile-gmake; -*-

# ※Makefile 記述時の注意:
#   -C だと $(PWD) は設定されないので $(CURDIR) を用いる。
#   参考: [[とあるエンジニアの備忘log: make の -C オプションについて>http://masahir0y.blogspot.jp/2012/06/make-c.html]]

PREFIX := $(MWGDIR)
MWGDIR := $(PREFIX)
MWGPP := gawk -f $(CURDIR)/ext/mwg_pp.awk
MKCMD := ./make_command.sh

all: compile
.PHONY: all install dist compile

define install/mkdir
install += $1
$1:
	mkdir -p $$@
endef

$(eval $(call install/mkdir,$(MWGDIR)))
$(eval $(call install/mkdir,$(MWGDIR)/bin))
$(eval $(call install/mkdir,$(MWGDIR)/share/mshex/shrc))
$(eval $(call install/mkdir,$(MWGDIR)/share/mshex/libexec))

#------------------------------------------------------------------------------
# directory shrc

out/shrc out/bin:
	mkdir -p $@

define install/copy
  install += $(MWGDIR)/$2
  $(MWGDIR)/$2: $1
	cp -pr $$< $$@
endef

define install/shrc/copy
  $$(eval $$(call shrc/$1,share/mshex/shrc/$1))
endef

define install/shrc/generate-bash-zsh
  compile += out/shrc/bashrc_$1.sh
  compile += out/shrc/zshrc_$1.sh
  out/shrc/bashrc_$1.sh: shrc/bashrc_$1.pp | out/shrc
	cd shrc && $(MWGPP) bashrc_$1.pp
  out/shrc/zshrc_$1.sh: out/shrc/bashrc_$1.sh | out/shrc
	touch $$@
  $$(eval $$(call install/copy,out/shrc/bashrc_$1.sh,share/mshex/shrc/bashrc_$1.sh))
  $$(eval $$(call install/copy,out/shrc/zshrc_$1.sh,share/mshex/shrc/zshrc_$1.sh))
endef

define compile/mwgpp
  compile += out/shrc/$2
  out/shrc/$2: shrc/$1 | out/shrc
	$(MWGPP) $$< > $$@
endef

$(eval $(call install/shrc/generate-bash-zsh,common))
$(eval $(call install/shrc/generate-bash-zsh,interactive))

$(eval $(call install/shrc/copy,bashrc_cygwin.sh))
$(eval $(call install/shrc/copy,cdhist.sh))
$(eval $(call install/shrc/copy,dict.sh))
$(eval $(call install/shrc/copy,term.sh))
$(eval $(call install/shrc/copy,menu.sh))
$(eval $(call install/shrc/copy,path.sh))
$(eval $(call install/shrc/copy,less.sh))

# 以下は互換性の為
$(eval $(call compile/mwgpp,libmwg_src.pp,libmwg_src.sh))
$(eval $(call install/copy,shrc/bashrc,bashrc))
$(eval $(call install/copy,shrc/bashrc.cygwin,bashrc.cygwin))

#------------------------------------------------------------------------------
# directory bin

define install/bin/copy
  install += $(MWGDIR)/bin/$1
  $(MWGDIR)/bin/$1: bin/$1
	$(MKCMD) copy -s $$< $$@
endef
define install/bin/mwgpp
  compile += out/bin/$1
  install += $(MWGDIR)/bin/$1
  out/bin/$1: bin/$1 | out/bin
	$(MWGPP) $$< > $$@ && chmod +x $$@
  $(MWGDIR)/bin/$1: out/bin/$1
	$(MKCMD) copy -s $$< $$@
endef

$(eval $(call install/bin/copy,modmod))
$(eval $(call install/bin/copy,makepp))
$(eval $(call install/bin/copy,mwgbk))
$(eval $(call install/bin/mwgpp,msync))
$(eval $(call install/bin/mwgpp,remove))
$(eval $(call install/bin/mwgpp,mshex))
$(eval $(call install/bin/copy,move))
$(eval $(call install/bin/copy,src))
$(eval $(call install/bin/copy,findsrc))
$(eval $(call install/bin/copy,grc))
$(eval $(call install/bin/copy,cz))
$(eval $(call install/bin/copy,czless))
$(eval $(call install/bin/copy,pass))
$(eval $(call install/bin/copy,passgen))
$(eval $(call install/bin/mwgpp,ren))
$(eval $(call install/bin/copy,ifold))
$(eval $(call install/bin/copy,refact))
$(eval $(call install/bin/copy,tarc))
$(eval $(call install/bin/copy,hist-uniq))
$(eval $(call install/bin/copy,iostat.sh))
$(eval $(call install/bin/copy,reset-directory-mtime))

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
	$(MKCMD) initialize-source-highlight $@

define install/source-highlight/copy
install += $(srchilite_dir)/$1
$(srchilite_dir)/$1: source-highlight/$1 | $(srchilite_dir)
	test -d $(srchilite_dir) && $(MKCMD) copy $$< $$@
endef
$(eval $(call install/source-highlight/copy,bash_simple_expansion.lang))
$(eval $(call install/source-highlight/copy,esc256-light_background.outlang))
$(eval $(call install/source-highlight/copy,my.style))
$(eval $(call install/source-highlight/copy,sh.lang))
$(eval $(call install/source-highlight/copy,x86.lang))

endif

#------------------------------------------------------------------------------

compile: $(compile)
install: pre_install $(install)
pre_install:
	$(MKCMD) update

dist:
	cd .. && tar cavf mshex.`date +%Y%m%d`.tar.xz ./mshex --exclude=*/backup --exclude=*~ --exclude=./mshex/.git --exclude=./mshex/shrc/out
