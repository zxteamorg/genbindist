#!/bin/bash
#

TS=$(date +'%Y%m%d%H%M%S')

WORKDIR=$(mktemp --directory --tmpdir update-world.$TS.XXXXXXXXXX)


emerge --sync > "$WORKDIR/phase1-sync-portage.log"
if [ $? -ne 0 ]; then
 echo "Cannot sync portage tree" >&2
 exit 1
fi

emerge --pretend --verbose --newuse --deep --update @world > "$WORKDIR/phase2-update-world.log" 
if [ $? -ne 0 ]; then
 echo "Cannot update world" >&2
 exit 2
fi

emerge @preserved-rebuild > "$WORKDIR/phase3-preserved-rebuild.log"
if [ $? -ne 0 ]; then
 echo "Cannot preserved-rebuild" >&2
 exit 3
fi

echo -1 | etc-update

