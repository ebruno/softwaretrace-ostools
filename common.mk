OS_ID := $(shell uname)
ifeq ($(OS_ID),Darwin)
  ID = darwin
  VERSION_ID := $(shell sw_vers --productVersion)
else ifeq ($(OS_ID),Linux)
  ID_TMP = $(shell grep -E '^ID=.*' /etc/os-release)
  ID := $(subst ID=,,$(ID_TMP))
  VERSION_ID_TMP = $(shell grep -E '^VERSION_ID=.*' /etc/os-release)
  VERSION_ID := $(subst VERSION_ID=,,$(VERSION_ID_TMP))
else
  ID = unknown
  VERSION_ID = 0
  $(error OS is not supported: $(ID) $(VERSION_ID))
endif
