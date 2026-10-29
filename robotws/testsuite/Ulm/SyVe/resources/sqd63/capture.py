import io
from sys import argv


class capture(object):
    if "--dryrun" not in argv:
        ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
        ROBOT_LISTENER_API_VERSION = 3

    def __init__(self):
        if "--dryrun" not in argv:
            self.buffer = io.BytesIO()
            self.ROBOT_LIBRARY_LISTENER = self

    def reset_capture(self):
        self.buffer = io.BytesIO()

    def get_capture(self):
        return self.buffer.getvalue().decode()

    def _log_message(self, message):
        if message.level != "TRACE":
            self.buffer.write(message.message.encode() + b"\n")
