import json

import ydb
import boto3
from PIL import Image
import os

driver = ydb.Driver(
    endpoint=os.getenv("YDB_ENDPOINT"), database=os.getenv("YDB_DATABASE")
)
driver.wait(fail_fast=True, timeout=5)
pool = ydb.SessionPool(driver)

session = boto3.session.Session(
    region_name='ru-central1',
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY"),
    aws_secret_access_key=os.getenv("AWS_SECRET_KEY"),
)
s3 = session.client(
    service_name='s3',
    endpoint_url='https://storage.yandexcloud.net',
)
sqs = session.client(
    service_name='sqs',
    endpoint_url='https://message-queue.api.cloud.yandex.net',
)


def update_status(task_id, status):
    def operation(session):
        query = """
        DECLARE $task_id AS Uint64;
        DECLARE $status AS String;
    
        UPDATE tasks SET status = $status WHERE id = $task_id;
        """
        prepared_query = session.prepare(query)
        session.transaction().execute(
            prepared_query,
            {
                "$task_id": int(task_id),
                "$status": status.encode("utf-8")
            },
            commit_tx=True,
            settings=ydb.BaseRequestSettings().with_timeout(3).with_operation_timeout(2),
        )

    pool.retry_operation_sync(operation)


def main(event, context):
    input_data: str = event["messages"][0]["details"]["object_id"]
    input_split = input_data.split("-")
    if len(input_split) != 2:
        return {'statusCode': 400}

    task_id, model = input_split
    print(f'[INFO] Validating task {task_id} with model {model}')

    s3.download_file('vvsushkov.uploads', input_data, '/tmp/input.jpg')

    v_image = Image.open('/tmp/input.jpg')
    try:
        v_image.verify()
    except Exception:
        update_status(task_id, "FAILED")
        return {'statusCode': 422}

    update_status(task_id, "PROCESSING")
    print(f'[INFO] Task {task_id} with model {model} valid. Sending...')
    sqs.send_message(QueueUrl=os.getenv("QUEUE_URL"), MessageBody=json.dumps({"task_id": task_id, "model": model}))
    print(f'[INFO] Task {task_id} with model {model} sent.')

    return {'statusCode': 200}
