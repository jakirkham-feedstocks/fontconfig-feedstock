#!/bin/bash


if [[ $(uname) == 'Darwin' ]];
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH

    #############################################################
    # Workaround for `libuuid` bug in 2.13.0.                   #
    # Drop on subsequent `fontconfig` release.                  #
    #                                                           #
    # ref: https://bugs.freedesktop.org/show_bug.cgi?id=105366  #
    #############################################################
    export UUID_CFLAGS=" "
    export UUID_LIBS=" "
    export PKGCONFIG_REQUIRES_PRIVATELY="${PKGCONFIG_REQUIRES_PRIVATELY} uuid"
elif [[ $(uname) == 'Linux' ]];
then
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

sed -i.orig s:'@PREFIX@':"${PREFIX}":g src/fccfg.c

chmod +x configure

./configure --prefix "${PREFIX}" \
	    --enable-libxml2 \
	    --enable-static \
	    --disable-docs \
      --with-add-fonts=${PREFIX}/fonts

make -j${CPU_COUNT}
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make install

# Remove computed cache with local fonts
rm -Rf "${PREFIX}/var/cache/fontconfig"

# Leave cache directory, in case it's needed
mkdir -p "${PREFIX}/var/cache/fontconfig"
touch "${PREFIX}/var/cache/fontconfig/.leave"
