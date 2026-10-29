#!/opt/ute/python/bin/python
import platform
import re
from builtins import str
import os
from robot.api import logger
import logging
import logging.config
import logging.handlers
import sys

LOGFILE_NAME = 'runner.txt'
TESTS_LIVE_OUTPUT = 'tests.txt'
SUMMARY_REGEXP = re.compile(r"((?:.*?\n){1,3}\d+\scritical.*(?:\n.*?){6})", re.MULTILINE)
LINE_TEMPLATE = "#" * 100
LOG_LINK = "http://logs.ute.nsn-rdnet.net/cloud/execution/{CM_EXECUTION_ID}/" \
           "execution_for_preparation_{CM_RESERVATION_ID}/test_results/{TEST_SUITE_NAME}/log.html"
RUNNER_LOG_LINK = "http://logs.ute.nsn-rdnet.net/cloud/execution/{CM_EXECUTION_ID}/" \
                  "execution_for_preparation_{CM_RESERVATION_ID}/test_results/{RUNNER_LOG_NAME}"
START_MARKER = '<robot>'
END_MARKER = '</robot>'
LOGGER_CONFIGURED = False
if platform.system() == 'Linux':
    LOGGER_DEFAULT_LOCATION = os.path.join(os.path.sep, 'home', 'ute')
else:
    LOGGER_DEFAULT_LOCATION = os.getcwd()

ROBOT_PRINTS = []


class StreamToLogger(object):
    """
    Fake file-like stream object that redirects writes to a logger instance.
    Fake merge
    """

    def __init__(self, logger):
        self.logger = logger
        self.linebuf = ''

    def write(self, buf):
        # if buf.rstrip():
        self.logger.debug('My buff: {}'.format(buf))


def get_logging_path():
    try:
        loc = os.environ['LOGGER_LOCATION']
    except Exception:
        loc = LOGGER_DEFAULT_LOCATION
    print('Log file location: {}'.format(loc))
    return loc


def set_logging_path(path):
    os.environ['LOGGER_LOCATION'] = path
    logile_path = os.path.join(get_logging_path(), LOGFILE_NAME)
    if os.path.exists(logile_path):
        os.remove(logile_path)


def configure_logger(file_log_level=logging.DEBUG):
    global LOGGER_CONFIGURED
    if LOGGER_CONFIGURED:
        disable_all_logging_loggers()
        return
    # Change root logger level from WARNING (default) to NOTSET in order for all messages to be delegated.
    logging.getLogger().setLevel(logging.NOTSET)
    log_filename = os.path.join(get_logging_path(), LOGFILE_NAME)
    testlog_filename = os.path.join(get_logging_path(), TESTS_LIVE_OUTPUT)
    try:
        os.remove(log_filename)
    except Exception as e:
        pass
    try:
        os.remove(testlog_filename)
    except Exception as e:
        pass

    # Add stdout handler, with level INFO
    console = logging.StreamHandler(sys.stdout)
    console.setLevel(logging.INFO)
    # formater = logging.Formatter('%(name)-13s: %(levelname)-8s %(message)s')
    # formater = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    formater = logging.Formatter('%(asctime)s - %(message)s')
    console.setFormatter(formater)
    logging.getLogger(LOGFILE_NAME).addHandler(console)

    # Add file rotating handler, with level DEBUG

    rotatingHandler = logging.handlers.RotatingFileHandler(filename=log_filename,
                                                           maxBytes=10*1000000, backupCount=5)
    rotatingHandler.setLevel(file_log_level)
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    rotatingHandler.setFormatter(formatter)

    testrotatingHandler = logging.handlers.RotatingFileHandler(filename=testlog_filename,
                                                               maxBytes=10 * 1000000, backupCount=5)
    testrotatingHandler.setLevel(file_log_level)
    formatter = logging.Formatter('%(asctime)s - %(message)s')
    testrotatingHandler.setFormatter(formatter)

    logging.getLogger(TESTS_LIVE_OUTPUT).addHandler(testrotatingHandler)
    logging.getLogger(LOGFILE_NAME).addHandler(rotatingHandler)
    disable_all_logging_loggers()
    LOGGER_CONFIGURED = True
    # log = logging.getLogger("app." + __name__)
    #
    # log.debug('Debug message, should only appear in the file.')
    # log.info('Info message, should appear in file and stdout.')
    # log.warning('Warning message, should appear in file and stdout.')
    # log.error('Error message, should appear in file and stdout.')


def disable_all_logging_loggers():
    for name, logger in logging.root.manager.loggerDict.items():
        # print(name)
        if name not in [LOGFILE_NAME, TESTS_LIVE_OUTPUT]:
            logger.disabled = True


def get_logger(name=LOGFILE_NAME):
    assert LOGGER_CONFIGURED, 'Please configure logger first'
    return logging.getLogger(name)


def print_to_robot(text):
    logger = logging.getLogger(LOGFILE_NAME)
    logger.info("{}{}{}".format(START_MARKER, text, END_MARKER))
    global ROBOT_PRINTS
    ROBOT_PRINTS.append(text)


def compose_log_link(suite_name):
    try:
        log_link = LOG_LINK.format(CM_EXECUTION_ID=os.environ['CM_EXECUTION_ID'],
                                   CM_RESERVATION_ID=os.environ['CM_RESERVATION_ID'],
                                   TEST_SUITE_NAME=suite_name)
        return log_link
    except KeyError:
        return None


def compose_link_to_runner_log():
    try:
        log_link = RUNNER_LOG_LINK.format(CM_EXECUTION_ID=os.environ['CM_EXECUTION_ID'],
                                          CM_RESERVATION_ID=os.environ['CM_RESERVATION_ID'],
                                          RUNNER_LOG_NAME=LOGFILE_NAME)
        return log_link
    except KeyError:
        return None


def find_report_hashes(text=None):
    run_hash = r'file_hash=(\w+)'
    hashes = []
    if text is None:
        for line in ROBOT_PRINTS:
            hashes.extend(re.findall(run_hash, line))
    else:
        hashes = re.findall(run_hash, text)
    logger.warn("HASHES: {}".format(",".join(hashes)), html=True)
    return hashes


def parse_run_log(log_file=None):
    log_file = os.path.join(get_logging_path(), LOGFILE_NAME)
    with open(log_file, 'r') as file:
        content = file.read()
        content = re.sub(SUMMARY_REGEXP, r'{}\1{}'.format(START_MARKER, END_MARKER), content)
        list_of_prints = re.findall('{}(.*?){}'.format(START_MARKER, END_MARKER), content, re.DOTALL)
        for print_line in list_of_prints:
            if 'log.html' in print_line:
                try:
                    suite_name = re.findall(r'\/([^\/]*?)\/log.html', print_line)[0]
                    log_link = LOG_LINK.format(CM_EXECUTION_ID=os.environ['CM_EXECUTION_ID'],
                                               CM_RESERVATION_ID=os.environ['CM_RESERVATION_ID'],
                                               TEST_SUITE_NAME=suite_name)
                    href_link = "<a href=\"{}\">{}</a>".format(log_link, log_link)
                    list_of_prints[list_of_prints.index(print_line)] += "\n"+href_link
                except Exception as e:
                    list_of_prints[list_of_prints.index(print_line)] +=\
                        "log link cannot be provided due to exception: {}".format(str(e))
        to_print = "\n".join(list_of_prints)
        logger.warn(to_print, html=True)
    find_report_hashes(to_print)


if __name__ == '__main__':
    parse_run_log(sys.argv[1])
