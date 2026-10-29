from robot.api import logger
from robot import result


class CustomListener:
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        self.suppressed_library_name = 'ta5g_commissioning'

    def log_message(self, message):
        if self.suppressed_library_name in message.message or 'Generating' in message.message or 'Activating' \
                in message.message or 'Validating' in message.message:
            return
        logger.console(message.message)
