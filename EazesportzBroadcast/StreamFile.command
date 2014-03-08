#!/bin/sh

#  StreamFile.command
#  Eazesportz Broadcast Console
#
#  Created by Gilbert Zaldivar on 2/22/14.
#  Copyright (c) 2014 Gilbert Zaldivar. All rights reserved.

echo "************************************"
echo "Streaming started from a file"
echo "************************************"

/opt/local/bin/ffmpeg -re -threads 0 -i "${1}" -c:v libx264 -b:v 1200k -acodec aac -strict experimental -ac 2 -ab 96k -r 29 -g 100 -vprofile baseline -level 30 -map 0 -segment_format mpgets -maxrate 10000000 -bufsize 10000000 -hls_wrap 5 -hls_time 10 "${2}"
