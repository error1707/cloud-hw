#!/bin/zsh

API_URL="https://d5d0deo42ihfdij6ic7k.apigw.yandexcloud.net"
RESP=$(curl -X POST "$API_URL/task?model=feathers")

UPLOAD_URL=$(echo $RESP | jq '."upload_url"' -r)
TASK_ID=$(echo $RESP | jq '."task_id"' -r)

FILE=terraform/example/lenna.jpeg
curl -X PUT -T $FILE $UPLOAD_URL

curl https://d5d0deo42ihfdij6ic7k.apigw.yandexcloud.net/task/$TASK_ID
echo
sleep 3
curl https://d5d0deo42ihfdij6ic7k.apigw.yandexcloud.net/task/$TASK_ID
echo
sleep 5
curl https://d5d0deo42ihfdij6ic7k.apigw.yandexcloud.net/task/$TASK_ID
echo
curl https://d5d0deo42ihfdij6ic7k.apigw.yandexcloud.net/task
