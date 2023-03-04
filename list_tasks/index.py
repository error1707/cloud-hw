import json
import os
import ydb

driver = ydb.Driver(
    endpoint=os.getenv("YDB_ENDPOINT"), database=os.getenv("YDB_DATABASE")
)
driver.wait(fail_fast=True, timeout=5)
pool = ydb.SessionPool(driver)


def list_tasks():
    def operation(session):
        res = session.transaction(ydb.OnlineReadOnly()).execute(
            """
            SELECT * FROM tasks;
            """,
            commit_tx=True,
            settings=ydb.BaseRequestSettings().with_timeout(3).with_operation_timeout(2),
        )
        tasks = []
        for result_set in res:
            for row in result_set.rows:
                tasks.append({
                    "task_id": str(row.id),
                    "model": row.model.decode('utf-8'),
                    "status": row.status.decode('utf-8'),
                    "result": row.result.decode('utf-8') if row.result else row.result
                })
        return tasks

    return pool.retry_operation_sync(operation)


def main(event, context):
    tasks = list_tasks()
    return {
        "statusCode": 200,
        "body": json.dumps(tasks),
    }
