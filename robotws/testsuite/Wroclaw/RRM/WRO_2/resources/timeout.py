import signal
import errno
import os
from robot.api import logger
import time


class TimeoutException(Exception):
    def __init__(self, message):
        self.message = message


def raise_timeout_exception(error_message):
    raise TimeoutException(error_message)


def default_timeout_error(error_message=os.strerror(errno.ETIME)):
    return lambda signum, frame: raise_timeout_exception(error_message)


class Timeout(object):
    def __init__(self, timeout=10, timer_name=None, timeout_handler=default_timeout_error()):
        assert timeout > 0, 'Timeout value should be greater than 0'
        self.timer_name = timer_name or self._default_timer_name()
        self.timeout = timeout
        self.timeout_handler = timeout_handler

    def __enter__(self):
        self._start_timer()

    def __exit__(self, *args, **kwargs):
        self._stop_timer()

    def __call__(self, func):

        def _wrapper(*args, **kwargs):
            try:
                self._start_timer()
                result = func(*args, **kwargs)
            finally:
                self._stop_timer()
            return result

        return _wrapper

    @staticmethod
    def _default_timer_name():
        return 'T_{:.0f}'.format(time.time())

    def _start_timer(self):
        logger.debug('Start timer {}'.format(self.timer_name))
        signal.signal(signal.SIGALRM, self.timeout_handler)
        signal.alarm(self.timeout)

    def _stop_timer(self):
        signal.alarm(0)
        logger.debug('Stop timer {}'.format(self.timer_name))
