#!/bin/bash
#

TS=$(date +'%Y%m%d%H%M%S')
#WORKDIR=$(mktemp --directory --tmpdir update-world.$TS.XXXXXXXXXX)

echo "=== $TS ===" >> "/var/log/pkg-update.log"
echo "=== $TS ===" >> "/var/log/pkg-update.err"

emerge --sync >> "/var/log/pkg-update.log"
if [ $? -ne 0 ]; then
 echo "Cannot sync portage tree" >> "/var/log/pkg-update.err"
 exit 1
fi

emerge --verbose --newuse --deep --update @world >> "/var/log/pkg-update.log"
if [ $? -ne 0 ]; then
 echo "Cannot update world" >> "/var/log/pkg-update.err"
 exit 2
fi

if [ -f "/etc/pkglist" ]; then
  for PACKAGE in $(cat /etc/pkglist); do
    emerge --verbose --newuse --deep --update --buildpkgonly $PACKAGE >> "/var/log/pkg-update.log"
    if [ $? -ne 0 ]; then
      echo "Cannot update package $PACKAGE by /etc/pkglist" >> "/var/log/pkg-update.err"
      exit 2
    fi
  done
fi

emerge @preserved-rebuild >> "/var/log/pkg-update.log"
if [ $? -ne 0 ]; then
 echo "Cannot preserved-rebuild" >> "/var/log/pkg-update.err"
 exit 3
fi

echo -1 | etc-update
