#!/bin/bash

VM_IP='62.84.125.237'

ssh vvsushkov@${VM_IP} 'sudo ufw allow 32400'
ssh vvsushkov@${VM_IP} 'sudo docker run \
                          -d \
                          --name plex \
                          --network=host \
                          -e TZ="Europe/Moscow" \
                          -v ~/plex:/config \
                          -v ~/plex:/transcode \
                          -v ~/plex:/data \
                          plexinc/pms-docker'
