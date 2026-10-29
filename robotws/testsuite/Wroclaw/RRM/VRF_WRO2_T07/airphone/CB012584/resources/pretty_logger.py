from robot.api import logger
from termcolor import colored
from datetime import datetime


class PrettyLogger:
    def log(self, message, color='white', on_color=None, attrs=None, level='INFO'):
        """
        Logs a colorful message in Robot Framework logs and console, with a timestamp.

        Args:
            message (str): The message to log.
            color (str): The text color (e.g., 'red', 'green', 'blue').
            on_color (str): The background color (e.g., 'on_red', 'on_green').
            attrs (list): Text attributes (e.g., ['bold', 'underline']).
            level (str): The log level ('INFO', 'WARN', 'ERROR', etc.).
        """
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        full_message = f"[{timestamp}] {message}"
        pretty_message = colored(full_message, color, on_color, attrs)

        if level.upper() == 'INFO':
            logger.info(pretty_message, also_console=True)
        elif level.upper() == 'WARN':
            logger.warn(pretty_message, also_console=True)
        elif level.upper() == 'ERROR':
            logger.error(pretty_message, also_console=True)
        else:
            logger.debug(pretty_message, also_console=True)
