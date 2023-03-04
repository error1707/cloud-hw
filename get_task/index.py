import json
import os
import ydb

driver = ydb.Driver(
    endpoint=os.getenv("YDB_ENDPOINT"), database=os.getenv("YDB_DATABASE")
)
driver.wait(fail_fast=True, timeout=5)
pool = ydb.SessionPool(driver)


def get_task(task_id):
    def operation(session):
        query = """
                DECLARE $task_id AS Uint64;
                SELECT * FROM tasks WHERE id = $task_id;
                """
        prepared_query = session.prepare(query)
        res = session.transaction().execute(
            prepared_query,
            {"$task_id": int(task_id)},
            commit_tx=True,
            settings=ydb.BaseRequestSettings().with_timeout(3).with_operation_timeout(2),
        )
        for row in res[0].rows:
            return {
                "task_id": str(row.id),
                "model": row.model.decode('utf-8'),
                "status": row.status.decode('utf-8'),
                "result": row.result.decode('utf-8') if row.result else row.result
            }
        return {}

    return pool.retry_operation_sync(operation)


def main(event, context):
    task_id = event['pathParams']['task_id']
    task: dict = get_task(task_id)
    if not task:
        return {
            "statusCode": 404,
            "body": "Task not found",
        }
    return {
        "statusCode": 200,
        "body": json.dumps(task),
    }
