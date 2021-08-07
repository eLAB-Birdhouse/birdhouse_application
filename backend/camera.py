import os
import time

from . import base_camera

DIRECTORY = os.path.dirname(os.path.abspath(__file__))


class Camera(base_camera.BaseCamera):
    """An emulated camera implementation that streams a repeated sequence of
    files 1.jpg, 2.jpg and 3.jpg at a rate of one frame per second."""
    images = [
        open(
            os.path.join(DIRECTORY, '{0}.jpg'.format(f)), 'rb',
        ).read() for f in ('1', '2', '3')
    ]

    @staticmethod
    def frames():
        while True:
            time.sleep(1)
            yield Camera.images[int(time.time()) % 3]
