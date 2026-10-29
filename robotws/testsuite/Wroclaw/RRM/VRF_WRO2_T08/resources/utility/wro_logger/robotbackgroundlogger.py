import threading
import time

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

from .abstract_logger import AbstractLogger

__version__ = '1.2'


class BackgroundLogger(AbstractLogger):
    """A logger which can be used from multiple threads.

    The messages from main thread will go to robot logging api (or Python
    logging if Robot is not running). Messages from other threads are saved
    to memory and can be later logged with ``log_background_messages()``.
    This will also remove the messages from memory.

    Example::

        from robotbackgroundlogger import BackgroundLogger
        logger = BackgroundLogger()

    After that logger can be used mostly like ``robot.api.logger`::

        logger.debug('Hello, world!')
        logger.info('<b>HTML</b> example', html=True)
    """
    LOGGING_THREADS = logger.librarylogger.LOGGING_THREADS

    def __init__(self):
        self.lock = threading.RLock()
        self._messages = {}

    def console(self, msg, newline=True, stream='stdout'):
        logger.console(msg, newline, stream)

    def write(self, msg, level, html=False):
        with self.lock:
            thread = threading.currentThread().getName()
            if thread in self.LOGGING_THREADS:
                logger.write(msg, level, html)
            else:
                message = BackgroundMessage(msg, level, html)
                self._messages.setdefault(thread, []).append(message)

    def log_background_messages(self, name=None):
        """Forwards messages logged on background to Robot Framework log.

        By default forwards all messages logged by all threads, but can be
        limited to a certain thread by passing thread's name as an argument.
        Logged messages are removed from the message storage.

        This method must be called from the main thread.
        """
        thread = threading.currentThread().getName()
        if thread not in self.LOGGING_THREADS:
            raise RuntimeError(
                "Logging background messages is only allowed from the main "
                "thread. Current thread name: %s" % thread)
        with self.lock:
            if name:
                self._log_messages_by_thread(name)
            else:
                self._log_all_messages()

    def _log_messages_by_thread(self, name):
        for message in self._messages.pop(name, []):
            print(message.format())

    def _log_all_messages(self):
        for thread in list(self._messages):
            # Only way to get custom timestamps currently is with print
            print("*HTML* <b>Messages by '%s'</b>" % thread)
            for message in self._messages.pop(thread):
                print(message.format())

    def reset_background_messages(self, name=None):
        with self.lock:
            if name:
                self._messages.pop(name)
            else:
                self._messages.clear()

    def set_logging_level(self, level):
        if isinstance(level, str):
            if level not in self.level_lookup_table:
                raise KeyError(f'Supported log level strings are: {list(AbstractLogger.level_lookup_table.keys())}')
            BuiltIn().set_log_level(level)
        elif isinstance(level, int):
            level = self._reverse_lookup_level(level)
            BuiltIn().set_log_level(level)
        else:
            raise TypeError(f"log level should be of type int or str,  not {type(level)}")


class BackgroundMessage(object):
    def __init__(self, message, level='INFO', html=False):
        self.message = message
        self.level = level.upper()
        self.html = html
        self.timestamp = time.time() * 1000

    def format(self):
        # Can support HTML logging only with INFO level.
        html = self.html and self.level == 'INFO'
        level = self.level if not html else 'HTML'
        return "*%s:%d* %s" % (level, round(self.timestamp), self.message)
