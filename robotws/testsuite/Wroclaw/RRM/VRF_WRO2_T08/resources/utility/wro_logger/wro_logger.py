import logging
import sys

from .abstract_logger import AbstractLogger


class WroLogger(AbstractLogger):
    def __init__(self, name='wro_logger'):
        self._logger = logging.getLogger(name)
        self._console_logger = logging.getLogger(f'console_{name}')
        self.log_file_handler = logging.FileHandler('wro_logger.log')
        self.stdout_handler = logging.StreamHandler(stream=sys.stdout)
        self.stderr_handler = logging.StreamHandler(stream=sys.stderr)
        self.default_formatter = logging.Formatter('%(asctime)s - %(levelname)s: %(message)s')
        self.stdout_handler.setFormatter(self.default_formatter)
        self.stderr_handler.setFormatter(self.default_formatter)
        self.log_file_handler.setFormatter(self.default_formatter)
        self._logger.addHandler(self.log_file_handler)

    def console(self, msg, newline=True, to_stderr=False):
        stream = self.stdout_handler if to_stderr is False else self.stderr_handler
        self._console_logger.addHandler(stream)
        self._console_logger.info(msg)
        self._console_logger.removeHandler(stream)

    def write(self, msg, level, html=False):
        self._logger.log(level=self._lookup_level(level), msg=msg)

    def set_logging_level(self, level):
        if isinstance(level, int):
            self._logger.setLevel(level)
            self._console_logger.setLevel(level)
        elif isinstance(level, str):
            level = self._lookup_level(level)
            self._logger.setLevel(level)
            self._console_logger.setLevel(level)
        else:
            raise TypeError(f"log level should be of type int or str,  not {type(level)}")

    def enable_console_repeater(self):
        self._logger.addHandler(self.stdout_handler)
