#!/bin/bash


if [[ $(uname) == 'Darwin' ]];
then
    #############################################################
    # Workaround for `libuuid` bug in 2.13.0.                   #
    # Drop on subsequent `fontconfig` release.                  #
    #                                                           #
    # ref: https://bugs.freedesktop.org/show_bug.cgi?id=105366  #
    #############################################################
    export UUID_CFLAGS=" "
    export UUID_LIBS=" "
fi

sed -i.orig s:'@PREFIX@':"${PREFIX}":g src/fccfg.c

chmod +x configure

./configure --prefix "${PREFIX}" \
	    --enable-libxml2 \
	    --enable-static \
	    --disable-docs \
      --with-add-fonts=${PREFIX}/fonts

make -j${CPU_COUNT}
make check
make install

# Remove computed cache with local fonts
rm -Rf "${PREFIX}/var/cache/fontconfig"

# Leave cache directory, in case it's needed
mkdir -p "${PREFIX}/var/cache/fontconfig"
touch "${PREFIX}/var/cache/fontconfig/.leave"

if [[ $(uname) == 'Darwin' ]];
then
    #############################################################
    # Workaround for `libuuid` bug in 2.13.0.                   #
    # Drop on subsequent `fontconfig` release.                  #
    #                                                           #
    # ref: https://bugs.freedesktop.org/show_bug.cgi?id=105366  #
    #############################################################
    sed -i '' "s/uuid//g" "${PREFIX}/lib/pkgconfig/fontconfig.pc"
fi
