include ../../../common.mk

SHELLCHECK_OUTPUT_FORMAT = tty

SHELLCHECK = $(shell which shellcheck)

CLEAN_DIRS  =
CLEAN_FILES = .lint

.PHONY: sanity_all clean distclean

all: .lint
	@echo "run lint tests";

lint_all:
	@$(SHELLCHECK) -f $(SHELLCHECK_OUTPUT_FORMAT) -x -s bash swtr_*.sh;

.lint: $(wildcard *.sh)
	@$(SHELLCHECK) -f $(SHELLCHECK_OUTPUT_FORMAT) -x -s bash $?; \
	if [ $$? -eq 0 ]; then \
	   touch .lint; \
	fi;


all: .lint
	@echo "run lint tests";

lint_all:
	@$(SHELLCHECK) -f $(SHELLCHECK_OUTPUT_FORMAT) -x -s bash swtr_*.sh;

.lint: $(wildcard *.sh)
	@$(SHELLCHECK) -f $(SHELLCHECK_OUTPUT_FORMAT) -x -s bash $?; \
	if [ $$? -eq 0 ]; then \
	   touch .lint; \
	fi;

clean:
	@$(foreach item, $(CLEAN_DIRS), $(RM) -r ${item})
	@$(foreach item, $(CLEAN_FILES), $(RM) ${item})
	@find . -name '*~' -prune -exec rm -r -f {} \;
	@find . -name '#*#' -prune -exec rm -r -f {} \;

distclean: clean
	@$(foreach item, $(DISTCLEAN_DIRS), $(RM) -r ${item})
