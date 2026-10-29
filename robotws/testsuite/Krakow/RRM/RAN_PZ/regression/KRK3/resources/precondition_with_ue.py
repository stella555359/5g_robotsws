import logging
import re

UL_MESSAGE_MARKER = 'L2_LO_UL_0 INF/L2Lo, UlCounterUpdate.cpp'
DL_MESSAGE_MARKER = 'L2_LO_TB_BUI0'
UL_MESSAGE_REGEX = r'^.*: (\d+) Bytes received.*$'
DL_MESSAGE_REGEX = r'^.*\[TBS\|MacCe\|StatusPdu\|DataPdu.* (?:\d+\|){3}(\d+)\].*$'
UL_CELL_ID_REGEX = r'^.* nrCellIdentity (\d+).*$'
DL_CELL_ID_REGEX = r'^.*nrCellId (\d+) .*$'


def get_active_cell_ids(logs):
    """
    Get ids of cells active scheduling tput. Base on L2 syslog
    :param logs: (str) L2 tput stats syslog
    :return: (tuple) Tuple of UL and DL list of nrcell ids
    """
    logs = logs.splitlines()
    ul_logs, dl_logs = _separate_ul_dl_log_messages(logs)

    ul_tput = _get_uplink_values(ul_logs)
    dl_tput = _get_downlink_values(dl_logs)
    ul_ids = _get_ul_ids(ul_logs)
    dl_ids = _get_dl_ids(dl_logs)

    ul_ids = [str(i) for i in set(_get_ids_with_traffic(ul_ids, ul_tput))]
    dl_ids = [str(i) for i in set(_get_ids_with_traffic(dl_ids, dl_tput))]

    return ul_ids, dl_ids


def _separate_ul_dl_log_messages(logs):
    """
    Split Uplink and Downlink messages from logs
    :param logs: (str) syslog
    :return: (tuple) Tuple with ul and dl messages list
    """
    ul_messages = []
    dl_messages = []
    for message in logs:
        if UL_MESSAGE_MARKER in message:
            ul_messages.append(message)
        elif DL_MESSAGE_MARKER in message:
            dl_messages.append(message)
    return ul_messages, dl_messages


def _get_uplink_values(uplink_logs):
    """
    Get values of uplink tput in bytes
    :param uplink_logs: (list) List of str with UL messages
    :return: (list) List with tput values [bytes]
    """
    return _get_values_out_of_logs(uplink_logs, UL_MESSAGE_REGEX)


def _get_downlink_values(downlink_logs):
    """
    Get values of downlink tput in bytes
    :param downlink_logs: (list) List of str with DL messages
    :return: (list) List with tput values [bytes]
    """
    return _get_values_out_of_logs(downlink_logs, DL_MESSAGE_REGEX)


def _get_ul_ids(ul_logs):
    """
    Get ul cell ids from logs
    :param ul_logs: (list) List of str with UL messages
    :return: (list) List with nrcell ids
    """
    return _get_values_out_of_logs(ul_logs, UL_CELL_ID_REGEX)


def _get_dl_ids(dl_logs):
    """
    Get dl cell ids from logs
    :param dl: (list) List of str with DL messages
    :return: (list) List with nrcell ids
    """
    return _get_values_out_of_logs(dl_logs, DL_CELL_ID_REGEX)


def _get_ids_with_traffic(cell_ids, tput_values):
    """
    Get cell ids with active traffic
    :param cell_ids: (list) List of cell ids from log
    :param tput_values: (list) List of tput values from log
    :return: (list) Cell ids with tput > 0
    """
    return [cell_ids[i] for i in range(len(cell_ids)) if tput_values[i] > 0]


def _get_values_out_of_logs(logs, regex):
    """
    Pefrom regex on logs
    :param logs: (list) List with messages
    :param regex: (str) regex to search
    :return: (list) values
    """
    values = []
    for message in logs:
        match = re.search(regex, message)
        if match is None:
            continue
        value = match.groups()[0]
        values.append(int(value))
    return values
