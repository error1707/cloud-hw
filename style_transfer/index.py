import json
import time
import os

import ydb
import boto3
import cv2 as cv

driver = ydb.Driver(
    endpoint=os.getenv("YDB_ENDPOINT"), database=os.getenv("YDB_DATABASE")
)
driver.wait(fail_fast=True, timeout=5)
pool = ydb.SessionPool(driver)

session = boto3.session.Session()
s3 = session.client(
    service_name='s3',
    endpoint_url='https://storage.yandexcloud.net',
    region_name='ru-central1',
    aws_access_key_id=os.getenv("AWS_ACCESS_KEY"),
    aws_secret_access_key=os.getenv("AWS_SECRET_KEY"),
)


def update_status_and_result(task_id, status, result):
    def operation(session):
        query = """
        DECLARE $task_id AS Uint64;
        DECLARE $status AS String;
        DECLARE $result AS String;

        UPDATE tasks SET status = $status, result = $result WHERE id = $task_id;
        """
        prepared_query = session.prepare(query)
        session.transaction().execute(
            prepared_query,
            {
                "$task_id": int(task_id),
                "$status": status.encode("utf-8"),
                "$result": result.encode("utf-8"),
            },
            commit_tx=True,
            settings=ydb.BaseRequestSettings().with_timeout(3).with_operation_timeout(2),
        )

    pool.retry_operation_sync(operation)


def predict(net, img, h, w):
    blob = cv.dnn.blobFromImage(img, 1.0, (w, h),
                                (103.939, 116.779, 123.680), swapRB=False, crop=False)

    print('[INFO] Setting the input to the model')
    net.setInput(blob)

    print('[INFO] Starting Inference!')
    start = time.time()
    out = net.forward()
    end = time.time()
    print('[INFO] Inference Completed successfully!')

    # Reshape the output tensor and add back in the mean subtraction, and
    # then swap the channel ordering
    out = out.reshape((3, out.shape[2], out.shape[3]))
    out[0] += 103.939
    out[1] += 116.779
    out[2] += 123.680
    out /= 255.0
    out = out.transpose(1, 2, 0)

    # Printing the inference time
    print('[INFO] The model ran in {:.4f} seconds'.format(end - start))

    return out


# Source for this function:
# https://github.com/jrosebr1/imutils/blob/4635e73e75965c6fef09347bead510f81142cf2e/imutils/convenience.py#L65
def resize_img(img, width=None, height=None, inter=cv.INTER_AREA):
    dim = None
    h, w = img.shape[:2]

    if width is None and height is None:
        return img
    elif width is None:
        r = height / float(h)
        dim = (int(w * r), height)
    elif height is None:
        r = width / float(w)
        dim = (width, int(h * r))

    resized = cv.resize(img, dim, interpolation=inter)
    return resized


def process_image(image, model, output):
    net = cv.dnn.readNetFromTorch(model)
    img = cv.imread(image)
    img = resize_img(img, width=600)
    h, w = img.shape[:2]
    out = predict(net, img, h, w)
    out = cv.convertScaleAbs(out, alpha=255.0)
    cv.imwrite(output, out)


def main(event, context):
    input_data = json.loads(event['messages'][0]['details']['message']['body'])

    object_path = f"{input_data['task_id']}-{input_data['model']}"

    s3.download_file('vvsushkov.models', input_data["model"], '/tmp/model.t7',
                     Callback=lambda x: print(f'[INFO] Downloaded model: {x} bytes'))
    s3.download_file('vvsushkov.uploads', object_path, '/tmp/pic.jpg',
                     Callback=lambda x: print(f'[INFO] Downloaded input: {x} bytes'))

    process_image('/tmp/pic.jpg', '/tmp/model.t7', '/tmp/res.jpg')

    s3.upload_file('/tmp/res.jpg', 'vvsushkov.results', object_path,
                   Callback=lambda x: print(f'[INFO] Uploaded res: {x} bytes'))

    update_status_and_result(input_data['task_id'], "DONE", f"https://storage.yandexcloud.net/vvsushkov.results/{object_path}")

    return {"statusCode": 200}
