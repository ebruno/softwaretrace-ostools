# OS independant Makefile.
include common.mk

SHELL := /bin/bash

LIB_LINUX_BASH = lib/linux/bash
LIB_REDHAT_BASH = lib/redhat/bash
LIB_DEBIAN_BASH = lib/debian/bash

BUILD_DIR      = build
CLEAN_DIRS     =
CLEAN_FILES    = .lint .sanity sanity sanity_spec
DISTCLEAN_DIRS =

SHELLCHECK = $(shell which shellcheck)

SHELLCHECK_OUTPUT_FORMAT = tty

SHELLSPEC_OUTPUT_FORMAT = t
SHELLSPEC_REPORT_FORMAT = j

SHELLSPEC = $(shell which shellspec)

SHELLSPEC_LOAD_PATH =


.PHONY: sanity_all clean distclean lint lint_all

all: lint

lint_all:
	@$(foreach item, $(LIB_LINUX_BASH), make SHELLCHECK_OUTPUT_FORMAT=$(SHELLCHECK_OUTPUT_FORMAT) -C ${item} lint_all;)
lint:
	@$(foreach item, $(LIB_LINUX_BASH), make SHELLCHECK_OUTPUT_FORMAT=$(SHELLCHECK_OUTPUT_FORMAT) -C ${item} .lint;)

sanity_all:
	 @$(SHELL) $(SHELLSPEC) -f $(SHELLSPEC_OUTPUT_FORMAT) -o $(SHELLSPEC_REPORT_FORMAT)

sanity: $(wildcard lib/*/bash/*.sh)
	@final_sanity=0; \
	for item in $?; do \
	tmpname="`basename "$${item}"`"; \
	tmpname="$${tmpname/.sh/}"; \
	SPEC_PATH="**/$${tmpname}_spec.sh"; \
	$(SHELLSPEC) -f $(SHELLSPEC_OUTPUT_FORMAT) -P "$${SPEC_PATH}"; \
	if [ $$? -ne 0 ]; then \
	   final_sanity=1; \
	fi; \
	done; \
	if [ $$final_sanity -eq 0 ]; then \
	  touch sanity; \
	fi;

sanity_spec: $(wildcard spec/lib/*/bash/*.sh)
	@final_sanity=0; \
	for item in $?; do \
	tmpname="`basename "$${item}"`"; \
	tmpname="$${tmpname/.sh/}"; \
	SPEC_PATH="**/$${tmpname}.sh"; \
	$(SHELLSPEC) -f $(SHELLSPEC_OUTPUT_FORMAT) -P "$${SPEC_PATH}"; \
	if [ $$? -ne 0 ]; then \
	   final_sanity=1; \
	fi; \
	done; \
	if [ $$final_sanity -eq 0 ]; then \
	  touch sanity_spec; \
	fi;


clean:
	@$(foreach item, $(CLEAN_DIRS), $(RM) -r ${item})
	@$(foreach item, $(CLEAN_FILES), $(RM) ${item})
	@find . -name '*~' -prune -exec rm -r -f {} \;
	@find . -name '#*#' -prune -exec rm -r -f {} \;
	@find . -name '*.pyc' -prune -exec rm -r -f {} \;
	@find . -name '__pycache__' -prune -exec rm -r -f {} \;

distclean: clean
	@$(foreach item, $(DISTCLEAN_DIRS), $(RM) -r ${item})
