"""Fail watcher client module."""

import os
import json
import socket
import logging
import logging.config
from urllib import request
from pathlib import Path
from robot.api import logger as robot_logger
from robot.libraries.BuiltIn import BuiltIn


__version__ = "1.0.1"


ACCEPTED_LOG_LEVELS = [logging.NOTSET,
                       logging.DEBUG,
                       logging.INFO,
                       logging.WARNING,
                       logging.WARN,
                       logging.ERROR,
                       logging.CRITICAL]


def set_logger(logger_name):
    """ Configure logger """

    logger = logging.getLogger(logger_name)
    output_dir_path = Path(BuiltIn().get_variable_value("${OUTPUT DIR}"))
    handler = logging.FileHandler(output_dir_path / 'fail_watcher_sdk.log', mode="w")
    raw_log_level = BuiltIn().get_variable_value("${LOG LEVEL}")
    log_level = unify_log_level(raw_log_level)
    handler.setLevel(log_level)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(name)s - %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.propagate = False
    return logger


def unify_log_level(log_level):
    """ Unifies log levels """

    if log_level not in ACCEPTED_LOG_LEVELS:
        return logging.DEBUG
    return log_level


logger = set_logger(__name__)


def ignore_exception(func):
    """Ignores All exception in decorated function."""

    def inner(*args, **kwargs):
        try:
            result = func(*args, **kwargs)
        except Exception as error:
            robot_logger.warn("Failed test wasn't reported to a fail watcher service. "
                              "Check fail_watcher_sdk.log in output directory.")
            logger.exception(error)
            result = None
        return result

    return inner


class fail_watcher_sdk:
    """Listener to catch and report failed tests."""

    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.hostname = self.get_domain_name()
        self.url = f'http://RAN-Pz-KRK-FAIL-WATCHER.p01.ska-lab.nsn-rdnet.net/data_receiver'
        self.events = []
        self.last_log = None
        self.last_trace = None
        self.no_proxy = '127.0.0.1,localhost'
        os.environ["no_proxy"] = self.no_proxy

    def initialize_fail_watcher(self, url, no_proxy='127.0.0.1,localhost'):
        """Defines url of fail watcher service."""

        self.url = f'{url}/data_receiver'
        self.no_proxy = no_proxy
        os.environ["no_proxy"] = self.no_proxy

    def log_message(self, message):
        """Callback executed after each logged message."""

        self.last_log = message

    def end_keyword(self, name, attrs):
        if attrs['status'] == 'FAIL' and self.last_trace is None:
            self.last_trace = self.last_log.get('message')

    def end_test(self, name, attrs):
        """Callback executed after each test end. It caches information about all failed tests."""

        if attrs.get('status') == 'FAIL':
            logger.info('Test "%s" failed', name)
            event = {
                'hostname': self.hostname,
                'test_name': name,
                'message': attrs.get('message'),
                'traceback_info': self.last_trace,
                'timestamp': self.last_log.get('timestamp')
            }
            logger.debug("Failed test data: %s", event)
            self.events.append(event)
        else:
            logger.info('Test "%s" passed', name)

        self.last_trace = None

    def close(self):
        """Callback executed after suite end. It sends information about failed tests to a server"""

        if len(self.events) > 0:
            self._send_data()

    @ignore_exception
    def _send_data(self):
        """Makes POST request"""

        data = json.dumps(self.events).encode('utf-8')
        req = request.Request(self.url, data=data)  # this will make the method "POST"
        req.add_header('Content-Type', 'application/json; charset=utf-8')
        with request.urlopen(req, data=data) as f:
            resp = json.loads(f.read().decode('utf-8'))
            logger.info('Response status: %s', f.status)
            if f.status == 201:
                for failed_test in resp:
                    logger.info('Failed test with id: %i reported successfully', failed_test.get("event_id"))
            logger.debug('Response body: %s', resp)

    @staticmethod
    @ignore_exception
    def get_domain_name():
        """Gets an ip address which is not a loopback ip address"""

        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        dn = socket.gethostbyaddr(ip)[0]
        return dn


__all__ = ["fail_watcher_sdk"]
