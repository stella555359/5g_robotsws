def check_fault_in_alarm_list(alarm_list, fault_id_expected):
    for alarm in alarm_list:
        fault_id_present = alarm['faultId']
        if str(fault_id_present) == str(fault_id_expected):
            return True
    return False


def get_critical_alarms_list(alarm_list):
    """
       Returns the alarm list which have severity as critical
       :param alarm_list: Active alarms list present in the system.
       :return: List of alarms that have severity as Critical
       contact : gopalakrishnan.n@nokia.com
       """
    critical_alarm_list = [alarm['faultId'] for alarm in alarm_list
                           if alarm['severity'] == 'Critical']
    return critical_alarm_list


def get_new_alarms_raised(original_alarm_list, new_alarm_list):
    """
    Returns the alarm list where alarms from second argument not
    present in
    alarm_list
    :param original_alarm_list: Alarm list which is base ideally
    the alarm
    list before the test
    :param new_alarm_list: Alarm list which needs to be compared
    ideally the
    alarm list got at the end of a test
    :return: List of alarms that not present in alarm_list
    contact : gopalakrishnan.n@nokia.com
    """
    if not (new_alarm_list):
        return []
    if not (original_alarm_list) and new_alarm_list:
        return new_alarm_list
    if original_alarm_list == new_alarm_list:
        return []
    alarms_raised = list(set(new_alarm_list).
                         difference(set(original_alarm_list)))
    return alarms_raised
