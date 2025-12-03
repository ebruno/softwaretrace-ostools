#!/usr/bin/env bash

rm -r -f output-artifacts;
find . -name "*~" -exec rm -f {} \;
find . -name "#*#" -exec rm -f {} \;
rm -f CHECKSUM*;
rm -r -f assets;
rm -f freebsd.pkrvars.hcl;
rm -f packer_freebsd_sha*.txt;
