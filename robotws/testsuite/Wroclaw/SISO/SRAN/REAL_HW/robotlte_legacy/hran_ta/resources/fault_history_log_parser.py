"""
:created on: 06.10.2021
:modified on: 30.05.2022

:copyright: Nokia Networks
:author: Mateusz Kawka
:Maintainers: Mateusz Kawka
:contact: mateusz.kawka@nokia.com
"""

import re


def assert_active_fault_in_history(txt_file, fault_id, severity):
    """
            Assert Active Fault In History

            | **Author:** mateusz.kawka@nokia.com
            | **Maintainer:** mateusz.kawka@nokia.com

            | **Full description:**
            | Check if given fault_id is Active in fault_history_log.txt
            | Optionally, severity can be checked

            +------------------+------+-------------------------------------------------------------------------+
            | Input Parameters | Man. | Description                                                             |
            +==================+======+=========================================================================+
            | txt_file         | Yes  | path to fault_history_log.txt                                           |
            +------------------+------+-------------------------------------------------------------------------+
            | fault_id         | Yes  | faultId to assert                                                       |
            +------------------+------+-------------------------------------------------------------------------+
            | severity         | Yes  | critical/major/minor                                                    |
            +------------------+------+-------------------------------------------------------------------------+

            | **Return value:**
            | True if fault exists, False if not
            """

    severity = severity.lower()
    active_faults = []
    with open(txt_file, 'r') as f:
        lines = f.readlines()
        copy = False
        for line in lines:
            line = re.sub('\\s+', ' ', line)
            if ' Active' in line:
                copy = True
                continue
            elif ' InActive' in line:
                copy = False
                continue
            elif copy:
                if 'EFaultId' in line:
                    active_faults.append(line)
    f.close()

    if active_faults:
        for fault in active_faults:
            print(fault)
    else:
        print("Active faults list is empty !")

    status_list = []
    for fault_line in active_faults:
        _fault_id = _get_fault_id_from_line(fault_line)
        _severity = _get_severity_from_line(fault_line)
        if int(fault_id) == _fault_id and severity == _severity:
            status_list.append(True)
        else:
            status_list.append(False)

    isTrueIn = True in status_list

    print(isTrueIn)
    return isTrueIn


def assert_inactive_fault_in_history(txt_file, fault_id, severity):
    """
            Assert Inactive Fault In History

            | **Author:** mateusz.kawka@nokia.com
            | **Maintainer:** mateusz.kawka@nokia.com

            | **Full description:**
            | Check if given fault_id is Inactive in fault_history_log.txt
            | Optionally, severity can be checked

            +------------------+------+-------------------------------------------------------------------------+
            | Input Parameters | Man. | Description                                                             |
            +==================+======+=========================================================================+
            | txt_file         | Yes  | path to fault_history_log.txt                                           |
            +------------------+------+-------------------------------------------------------------------------+
            | fault_id         | Yes  | faultId to assert                                                       |
            +------------------+------+-------------------------------------------------------------------------+
            | severity         | Yes  | critical/major/minor                                                    |
            +------------------+------+-------------------------------------------------------------------------+

            | **Return value:**
            | True if fault exists, False if not
            """

    severity = severity.lower()
    inactive_faults = []

    with open(txt_file, 'r') as f:
        lines = f.readlines()
        copy = False
        for line in lines:
            line = re.sub('\\s+', ' ', line)
            if 'InActive' in line:
                copy = True
                continue
            elif 'events' in line:
                copy = False
                continue
            elif copy:
                if 'EFaultId' in line:
                    inactive_faults.append(line)
    f.close()

    if inactive_faults:
        for fault in inactive_faults:
            print(fault)
    else:
        print("Inactive faults list is empty !")

    status_list = []
    for fault_line in inactive_faults:
        _fault_id = _get_fault_id_from_line(fault_line)
        _severity = _get_severity_from_line(fault_line)
        if int(fault_id) == _fault_id and severity == _severity:
            status_list.append(True)
        else:
            status_list.append(False)

    isTrueIn = True in status_list

    print(isTrueIn)
    # assert isTrueIn is True

    return isTrueIn


def assert_fault_event_in_history(txt_file, fault_id, severity, state):
    """
        Assert Fault Event In History

        | **Author:** mateusz.kawka@nokia.com
        | **Maintainer:** mateusz.kawka@nokia.com

        | **Full description:**
        | Check if given fault_id and event type is in fault_history_log.txt
        | Event types are : active and cleared
        | Optionally, severity can be checked

        +------------------+------+-------------------------------------------------------------------------+
        | Input Parameters | Man. | Description                                                             |
        +==================+======+=========================================================================+
        | txt_file         | Yes  | path to fault_history_log.txt                                           |
        +------------------+------+-------------------------------------------------------------------------+
        | fault_id         | Yes  | faultId to assert                                                       |
        +------------------+------+-------------------------------------------------------------------------+
        | event            | Yes  | active/cleared                                                          |
        +------------------+------+-------------------------------------------------------------------------+
        | severity         | Yes  | critical/major/minor                                                    |
        +------------------+------+-------------------------------------------------------------------------+

        | **Return value:**
        | True if fault exists, False if not
    """

    fault_events = []
    severity = severity.lower()
    state = state.lower()
    with open(txt_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            line = re.sub('\\s+', ' ', line)
            if 'active' in line or 'cleared' in line:
                fault_events.append(line)

    f.close()

    if fault_events:
        for fault in fault_events:
            print(fault)
    else:
        print("Fault events list is empty!")

    status_list = []
    for fault_line in fault_events:
        _fault_id = _get_fault_id_from_line(fault_line)
        _severity = _get_severity_from_line(fault_line)
        _state = _get_state_from_line(fault_line)
        if int(fault_id) == _fault_id and severity == _severity and _state == state:
            status_list.append(True)
        else:
            status_list.append(False)

    isTrueIn = True in status_list

    print(isTrueIn)
    return isTrueIn


def _get_fault_id_from_line(line):
    info_list = line.split()
    fault_id = info_list[2]
    fault_id = int(fault_id[1:-1])

    return fault_id


def _get_severity_from_line(line):
    info_list = line.split()
    severity = info_list[4]

    return severity


def _get_state_from_line(line):
    info_list = line.split()
    state = info_list[5]

    return state

# assert_inactive_fault_in_history('Fault_history', fault_id='1340', severity='critical')
# assert_active_fault_in_history('Fault_history', fault_id='1340', severity='critical')
# assert_fault_event_in_history('Fault_history', fault_id='1340',
#                              severity='critical', state='cleared')
