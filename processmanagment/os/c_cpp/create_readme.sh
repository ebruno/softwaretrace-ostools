#!/bin/bash
FILE_LIST="mainpage.md building_and_packaging.md"

if [ -f README.md ]; then
    rm -r -f README.md;
fi;
for item in ${FILE_LIST}
do
    cat ${item} >> README.md
done;
