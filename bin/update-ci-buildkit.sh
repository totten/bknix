#!/bin/bash
OWNER=${OWNER:-bknix}
su - $OWNER -c 'for PROF in dfl min max ; do eval $(use-bknix $PROF) ; bknix update ; done'
