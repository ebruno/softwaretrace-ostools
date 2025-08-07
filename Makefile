# OS independant Makefile.
include common.mk

SHELL		:= /bin/bash

CLEAN_DIRS	=
CLEAN_FILES	=

DISTCLEAN_DIRS	=

SUBDIRS		= processmanagment \
		system_management

.PHONY: clean distclean

all:


clean:
	@$(foreach item, $(CLEAN_DIRS), $(RM) -r ${item})
	@$(foreach item, $(CLEAN_FILES), $(RM) ${item})
	@find . -name '*~' -prune -exec rm -r -f {} \;
	@find . -name '#*#' -prune -exec rm -r -f {} \;
	@find . -name '*.pyc' -prune -exec rm -r -f {} \;
	@find . -name '__pycache__' -prune -exec rm -r -f {} \;
	@$(foreach item, $(SUBDIRS), make -C ${item} clean;)
distclean: clean
	@$(foreach item, $(DISTCLEAN_DIRS), $(RM) -r ${item};)
	@$(foreach item, $(SUBDIRS), make -C ${item} distclean;)
