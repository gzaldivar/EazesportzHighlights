#!/bin/sh

#  TranscodeClip.command
#  Eazesportz Broadcast Console
#
#  Created by Gilbert Zaldivar on 2/18/14.
#  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.

echo "*********************************"
echo "Encoding started"
echo "*********************************"


"${4}" -i "${1}" -c copy "${3}"

echo "*********************************"
echo "Encoding completed"
echo "*********************************"
