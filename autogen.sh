#!/bin/sh
# $Id$
# $Source$
#
# Run this script to generate aclocal.m4, config.h.in, 
# Makefile.in's, and ./configure...
# 
# To specify extra flags to aclocal (include dirs for example),
# set ACLOCAL_FLAGS
#

DIE=0

# minimum required versions of autoconf/automake:
ACMAJOR=2
ACMINOR=52

AMMAJOR=1
AMMINOR=4
AMPATCH=4

(autoconf --version 2>&1 | \
 perl -n0e "(/(\d+)\.(\d+)/ && \$1>=$ACMAJOR && \$2>=$ACMINOR) || exit 1") || {
   echo
   echo "Error: You must have \`autoconf' version $ACMAJOR.$ACMINOR or greater"
   echo "installed to run $0. Get the latest version from"
   echo "ftp://ftp.gnu.org/pub/gnu/autoconf/"
   echo
   NO_AUTOCONF=yes
   DIE=1
}

amtest="
if (/(\d+)\.(\d+)((-p|\.)(\d+))*/) { 
	exit 1 if (\$1 < $AMMAJOR || \$2 < $AMMINOR); 
	exit 0 if (\$2 > $AMMINOR); 
	exit 1 if (\$5 < $AMPATCH); 
}"

(automake --version 2>&1 | perl -n0e "$amtest" ) || {
   echo
   echo "Error: You must have \`automake' version $AMMAJOR.$AMMINOR-p$AMPATCH or greater"
   echo "installed to run $0. Get the latest version from"
   echo "ftp://ftp.gnu.org/pub/gnu/automake/"
   echo
   NO_AUTOCONF=yes
   DIE=1
}


test -n "$NO_AUTOMAKE" || (aclocal --version) < /dev/null > /dev/null 2>&1 || {
   echo
   echo "Error: \`aclocal' appears to be missing. The installed version of"
   echo "\`automake' may be too old. Get the most recent version from"
   echo "ftp://ftp.gnu.org/pub/gnu/automake/"
   NO_ACLOCAL=yes
   DIE=1
}

if test $DIE -eq 1; then
   exit 1
fi

echo "running aclocal $ACLOCAL_FLAGS ... "
aclocal $ACLOCAL_FLAGS
echo "running autoheader ... "
autoheader
echo "running automake --add-missing ... "
automake --copy --add-missing 
echo "running autoconf ... "
autoconf
if [ -e config.status ]; then
 echo "removing stale config.status."
rm -f config.status 
fi
if [ -e config.log    ]; then
  echo "removing old config.log."
rm -f config.log
fi
echo "now run ./configure to configure pdsh for your environment."