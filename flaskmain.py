# git clone https://github.com/miguelgrinberg/flask-video-streaming.git
# cp -r flask-video-streaming/*.py .
# For nginx: sudo usermod -aG video pi
import os
import subprocess
from importlib import import_module

from flask import Flask, Response, render_template  # , url_for

# from flask_sqlalchemy import SQLAlchemy
#
# Import camera driver
detect_rpi_camera = subprocess.run(
    ['vcgencmd', 'get_camera'],
    stdout=subprocess.PIPE,
).stdout.decode('utf-8')

if detect_rpi_camera == 'supported=1 detected=1\n':
    os.environ['CAMERA'] = 'pi'

if os.environ.get('CAMERA'):
    Camera = import_module(
        'backend.camera_' + os.environ['CAMERA']
    ).Camera  # type: ignore
else:  # Use a fake camera
    from backend.camera import Camera  # type: ignore

app = Flask(__name__)
# app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///records.db'
# database = SQLAlchemy(app)

# class Todo(db.Model):
#     content = database.Column(database.Str)


@app.route("/")
def index():
    """Serve the index page."""
    return render_template('./index.htm')


@app.route("/settings")
def settings():
    """Serve the setting page."""
    return render_template('./settings.htm')


def gen(camera):
    """Video streaming generator function."""
    while True:
        frame = camera.get_frame()
        yield (
            b'--frame\r\nContent-Type: image/jpeg\r\n\r\n' + frame + b'\r\n'
        )


@app.route('/video')
def video_feed():
    """Video streaming route. Put this in the src attribute of an img tag."""
    return Response(
        gen(Camera()),
        mimetype='multipart/x-mixed-replace; boundary=frame',
    )

# @app.route("/forward/", methods=['POST'])
# def move_forward():
#     #Moving forward code
#     forward_message = "Moving Forward..."
#     return render_template('index.htm', forward_message=forward_message)
# fill {{forward_message}} fields


recording_state = False


@app.route('/button_recording')
def button_recording():
    global recording_state
    recording_state = not recording_state

    if recording_state:
        # Start recording job
        print('Start recording')
        return 'buttonRed'
    else:
        # Stop recording
        print('Stop recording')
        return 'button'


@app.route('/button_capture')
def button_capture():
    # Capture a picture
    print('Capture image')
    return ''


if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True)
