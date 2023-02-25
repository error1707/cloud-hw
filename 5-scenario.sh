#!/bin/zsh

PGCLUSTER_ID=$(yc managed-postgresql cluster list --format json | jq '.[0]."id"' -r)
yc managed-postgresql cluster update $PGCLUSTER_ID --resource-preset s2.medium
