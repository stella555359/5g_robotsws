from moler.util.moler_test import MolerTest
import re

HO_SUCCEEDED_MSG = '.*Inter gNB handover completed with status Completed'
HO_FAILED_MSG = '.*Inter gNB handover completed with status Failed'


def _file_reader(filename):
    with open(filename, 'r') as f:
        for line in f:
            yield line


def confirm_handover_succeeded(syslog_path):
    ho_pattern = re.compile(HO_SUCCEEDED_MSG)
    for line in _file_reader(syslog_path):
        if ho_pattern.match(line):
            MolerTest.info('hoSucceeded pattern found in syslog: "{}"'.format(line))
            return
    raise ValueError('Handover procedure failed. Not found required pattern: "{}" in syslog:'
                     ' "{}"'.format(ho_pattern, syslog_path))


def confirm_handover_failed(syslog_path):
    ho_pattern = re.compile(HO_FAILED_MSG)
    for line in _file_reader(syslog_path):
        if ho_pattern.match(line):
            MolerTest.info('hoFailed pattern found in syslog: "{}"'.format(line))
            return
    raise ValueError('Not found required pattern: "{}" in syslog: "{}"'.format(ho_pattern, syslog_path))
