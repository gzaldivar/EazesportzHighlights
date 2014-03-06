#!/bin/sh

#  HighlightScript.command
#  Eazesportz Broadcast Console
#
#  Created by Gilbert Zaldivar on 3/4/14.
#  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.

echo "************************************"
echo "Creating a clip"
echo "************************************"

/opt/local/bin/ffmpeg -re -i "${1}" -ss 00:00:00.0 -t 00:00:45.0 -c:v copy -acodec aac -strict experimental -ac 2 -ab 64k "${2}"