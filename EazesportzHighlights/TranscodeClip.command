#!/bin/sh

#  TranscodeClip.command
#  Eazesportz Broadcast Console
#
#  Created by Gilbert Zaldivar on 2/18/14.
#  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.

echo "*********************************"
echo "Encoding started"
echo "*********************************"


"${4}" -threads 4 -y -i "${1}" -i_qfactor 0.71 -qcomp 0.6 -qmin 10 -qmax 63 -qdiff 4 -trellis 0 -vcodec libx264 -s 852x480 -b:v 1111k -b:a 56k -ar 22050 -strict -2 -profile:v baseline -level 30 "${3}"

echo "*********************************"
echo "Encoding completed"
echo "*********************************"
