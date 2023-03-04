import json
import os
import ydb
import boto3

from botocore.client import Config

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
    config=Config(signature_version="s3v4")
)


def create_task(model):
    def operation(session):
        query = """
        DECLARE $model AS String;

        $new_id = (SELECT max_task_id + 1 FROM serial WHERE id = 0);
        UPDATE serial SET max_task_id = $new_id WHERE id = 0;

        INSERT INTO tasks (id, model, status) VALUES (COALESCE($new_id, 0), $model, 'NEW');

        SELECT $new_id AS id;
        """
        prepared_query = session.prepare(query)
        res = session.transaction().execute(
            prepared_query,
            {"$model": model.encode("utf-8")},
            commit_tx=True,
            settings=ydb.BaseRequestSettings().with_timeout(3).with_operation_timeout(2),
        )
        for row in res[0].rows:
            return row.id
        return -1

    return pool.retry_operation_sync(operation)


def main(event, context):
    model = event["queryStringParameters"]["model"]
    task_id = create_task(model)

    if task_id == -1:
        return {
            "statusCode": 500,
            "body": "Can't create task",
        }
    presigned_url = s3.generate_presigned_url(
        "put_object",
        Params={"Bucket": "vvsushkov.uploads", "Key": f"{task_id}-{model}"},
    )
    return {
        "statusCode": 200,
        "body": json.dumps({"upload_url": presigned_url, "task_id": task_id, "model": model}),
    }
