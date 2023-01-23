import csv
import json
import os
import ssl
from collections import defaultdict
from datetime import datetime
from io import StringIO

from aiohttp.client import ClientSession
from aiohttp.client_exceptions import ClientError
from fastapi import FastAPI, Request, Response
from fastapi_utils.tasks import repeat_every


CH_HOST = os.getenv('LOGBROKER_CH_HOST', 'localhost')
CH_USER = os.getenv('LOGBROKER_CH_USER')
CH_PASSWORD = os.getenv('LOGBROKER_CH_PASSWORD')
CH_PORT = int(os.getenv('LOGBROKER_CH_PORT', 8123))
CH_DATABASE = os.getenv('LOGBROKER_CH_DATABASE', 'default')
CH_CERT_PATH = os.getenv('LOGBROKER_CH_CERT_PATH')


os.makedirs('logs', exist_ok=False)


async def execute_query(query, data=None):
    url = f'http://{CH_HOST}:{CH_PORT}/'
    params = {
        'database': CH_DATABASE,
        'query': query.strip()
    }
    headers = {}
    if CH_USER is not None:
        headers['X-ClickHouse-User'] = CH_USER
        if CH_PASSWORD is not None:
            headers['X-ClickHouse-Key'] = CH_PASSWORD
    ssl_context = ssl.create_default_context(cafile=CH_CERT_PATH) if CH_CERT_PATH is not None else None

    async with ClientSession() as session:
        async with session.post(url, params=params, data=data, headers=headers, ssl=ssl_context) as resp:
            await resp.read()
            try:
                resp.raise_for_status()
                return resp, None
            except ClientError as e:
                return resp, {'error': str(e)}


def get_current_log_file_name():
    return f"{datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}.log"


app = FastAPI()


@app.on_event("startup")
@repeat_every(seconds=1)
async def flush_to_ch():
    csv_data = defaultdict(list)
    json_data = defaultdict(list)
    files_to_delete = []
    current_log_file_name = get_current_log_file_name()
    for log_file_name in os.listdir("logs"):
        if log_file_name != current_log_file_name:
            files_to_delete.append(log_file_name)
            with open(f"logs/{log_file_name}", 'r') as f:
                for line in f:
                    log_entry = json.loads(line)
                    table_name = log_entry['table_name']
                    rows = log_entry['rows']
                    if log_entry.get('format') == 'list':
                        csv_data[table_name].extend(rows)
                    elif log_entry.get('format') == 'json':
                        json_data[table_name].extend(rows)
    errors = []
    for table_name, rows in csv_data.items():
        res = await send_csv(table_name, rows)
        if res != '':
            errors.append(res)
    for table_name, rows in json_data.items():
        res = await send_json_each_row(table_name, rows)
        if res != '':
            errors.append(res)
    if not errors:
        for file_to_delete in files_to_delete:
            os.remove(f"logs/{file_to_delete}")
    else:
        print("errors on sending to ch:", *errors)


async def query_wrapper(query, data=None):
    res, err = await execute_query(query, data)
    if err is not None:
        return err
    return await res.text()


@app.on_event("shutdown")
def shutdown_event():
    flush_to_ch()


@app.get('/show_create_table')
async def show_create_table(table_name: str):
    resp = await query_wrapper(f'SHOW CREATE TABLE "{table_name}";')
    if isinstance(resp, str):
        return Response(content=resp.replace('\\n', '\n'), media_type='text/plain; charset=utf-8')
    return resp


async def send_csv(table_name, rows):
    data = StringIO()
    cwr = csv.writer(data, quoting=csv.QUOTE_ALL)
    cwr.writerows(rows)
    data.seek(0)
    return await query_wrapper(f'INSERT INTO \"{table_name}\" FORMAT CSV', data)


async def send_json_each_row(table_name, rows):
    data = StringIO()
    for row in rows:
        assert isinstance(row, dict)
        data.write(json.dumps(row))
        data.write('\n')
    data.seek(0)
    return await query_wrapper(f'INSERT INTO \"{table_name}\" FORMAT JSONEachRow', data)


@app.post('/write_log')
async def write_log(request: Request):
    body = await request.json()
    res = []
    with open(f"logs/{get_current_log_file_name()}", "a+") as f:
        for log_entry in body:
            if log_entry.get('format') in ['list', 'json']:
                f.write(f"{json.dumps(log_entry)}\n")
                res.append("")
            else:
                res.append({'error': f'unknown format {log_entry.get("format")}, you must use list or json'})
    return res


# if log_entry.get('format') == 'list':
#     res.append(await send_csv(table_name, rows))
# elif log_entry.get('format') == 'json':
#     res.append(await send_json_each_row(table_name, rows))


@app.get('/healthcheck')
async def healthcheck():
    return Response(content='Ok', media_type='text/plain')
