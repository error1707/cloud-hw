#!/bin/zsh

INSTANCE_GROUP_ID=cl12tad6kfqr86cv09md
INSTANCE_TO_DELETE=$(yc compute instance-group list-instances $INSTANCE_GROUP_ID --limit 1 --format json | jq '.[0]."instance_id"' -r)

yc compute instance delete $INSTANCE_TO_DELETE
