#!/bin/tcsh
set fullpath=`realpath $0`;
set basedir="$fullpath:h";
doas cp ${basedir}/auto_master /etc;
doas cp -r ${basedir}/autofs.d /etc;
