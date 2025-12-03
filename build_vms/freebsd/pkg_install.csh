#!/bin/tcsh
echo "[INFO] Starting Package install"
pkg install -y ca_root_nss cairo curl doxygen git glib gmp mscgen
pkg install -y cmake cmake-core cmake-doc cmake-man
pkg install -y gnutls graphite2 graphviz libnghttp2 libpsl libssh2 python31
#foreach package ()
#    if ( { pkg info -qe $package } ) then
#	echo "***** $package is installed, skipping"
#    else
#	pkg install -y $package
#    endif
#end
