#!/bin/bash
OWNER=${OWNER:-jenkins}
su - $OWNER -c 'for PROF in dfl min max ; do eval $(use-bknix $PROF) ; bknix update ; done'
