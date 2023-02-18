from flask import Flask, render_template, request, make_response
from prometheus_flask_exporter import PrometheusMetrics
import tempfile
import os

from style_transfer import process_image

app = Flask(__name__)
app.config['MAX_CONTENT_LENGTH'] = 20 * 1024 * 1024
ALLOWED_MODELS = ['feathers', 'mosaic', 'the_scream']

metrics = PrometheusMetrics(app)


@app.route('/', methods=['GET', 'POST'])
def apply_model():
    if request.method == 'POST':
        if 'model' not in request.form:
            return 'no model selected', 400
        model = request.form['model']
        if model not in ALLOWED_MODELS:
            return 'incorrect model', 400

        if 'image' not in request.files:
            return 'no image', 400
        image = request.files['image']
        if image.filename == '':
            return 'no image selected', 400
        with tempfile.NamedTemporaryFile() as input_file:
            image.save(input_file.name)
            with tempfile.NamedTemporaryFile(suffix='.jpg') as output_file:
                model_path = os.path.join(app.root_path, 'models', model + '.t7')
                process_image(input_file.name, model_path, output_file.name)
                response = make_response(output_file.read())
        response.headers.set('Content-Type', 'image/jpeg')
        return response

    return render_template('upload.html')
