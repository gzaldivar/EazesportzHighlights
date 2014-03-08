#!/bin/sh

#  PosterScript.command
#  EazesportzHighlights
#
#  Created by Gilbert Zaldivar on 3/6/14.
#  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.

echo "*********************************"
echo "Encoding started"
echo "*********************************"

/opt/local/bin/ffmpeg -i "#{1}" -r 1 -t 1 -f image2 -y "#{2}"

echo "*********************************"
echo "Encoding completed"
echo "*********************************"
