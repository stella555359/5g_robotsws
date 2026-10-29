import os
import signal
from robot.api import logger


def stop_tcpdump_log_collection(process):
    os.killpg(os.getpgid(process.pid), signal.SIGTERM)
    logger.console("tcpdump process: {} has been terminated".format(process))


def replace_spaces_in_prefix_name(input_string):
    output_string = input_string.replace(' ', '_')
    return output_string
