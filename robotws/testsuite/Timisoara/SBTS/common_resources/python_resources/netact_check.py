from ims_parser import get_ims_events, EventNotFound
from prettytable import PrettyTable
import logging

"""
File to keep nms operation.
"""


class NetactDisconnectError(Exception):
    def __init__(self, message="NMS Error"):
        self.message = message

    def __str__(self):
        return self.message


def check_nms_state_during_test_execution(ims_paths, number_of_expected_disconnections=0, allow_to_fail=False):
    """
    Keyword will check if NMS connection was broken during test execution.
    Will check each NE3SADAPT event for interrupted downlinkState and uplinkState.
    Keyword will fail if one of those parameters has other state than UnsecureConnected.
    Keyword will also fail if no NE3SADAPT events are found in any of the IMS files.
    Parameters:
        ims_paths - list of paths to IMS files
        number_of_expected_disconnections - how many disconnection should be visible in ims
        allow_to_fail - if False - test will fail
                      - if True - will only log errors, without failing the keyword
    """
    ne3sdata_pattern = ".*NE3SADAPT-.$"
    fail_events = []
    total_ne3sadapt_events = 0
    for path in ims_paths:
        try:
            events = get_ims_events(ims_path=path, dist_name_pattern=ne3sdata_pattern)
        except EventNotFound:
            logging.log(level=logging.DEBUG,
                        msg='No NE3SADAPT events in IMS file {}, skipping'.format(path))
            continue
        total_ne3sadapt_events += len(events)
        for event in events:
            state_info = event.get('value').get('nmsStateInfo')
            logging.log(level=logging.DEBUG,
                        msg='Event for file {}: {}'.format(path, state_info))
            state_list = []
            ignore_state_list = ['Initializing', 'UnsecureConnected']
            if state_info['downlinkState'] not in ignore_state_list:
                state_list.append({'downlinkState': state_info['downlinkState']})
            if state_info['uplinkState'] not in ignore_state_list:
                state_list.append({'uplinkState': state_info['uplinkState']})
            if state_list:
                fail_events.append({'timestamp': event['timestamp'].strftime("%m/%d %H:%M:%S.%f"),
                                    'state_list': state_list})
    if not total_ne3sadapt_events:
        msg = ('No NE3SADAPT events found in any IMS files (pattern {}). '
               'Checked paths: {}'.format(ne3sdata_pattern, ims_paths))
        if not allow_to_fail:
            raise NetactDisconnectError(msg)
        logging.log(level=logging.WARN, msg=msg)
        return
    if number_of_expected_disconnections:
        logging.log(level=logging.DEBUG,
                    msg='Number of allowed disconnections set to {}'.format(number_of_expected_disconnections))
    table = PrettyTable()
    table.field_names = ['Timestamp', 'State']
    for error in fail_events:
        table.add_row([error['timestamp'], error['state_list']])
    if fail_events and len(fail_events) != number_of_expected_disconnections and not allow_to_fail:
        raise NetactDisconnectError('NMS disconnected during test at:\n {}'.format(table))
    elif fail_events and len(fail_events) != number_of_expected_disconnections and allow_to_fail:
        logging.log(level=logging.WARN,
                    msg='NMS disconnected at:\n {}'.format(table))
