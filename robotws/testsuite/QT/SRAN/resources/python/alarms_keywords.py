import re
from robot.libraries.BuiltIn import BuiltIn
from robot.running import EXECUTION_CONTEXTS
from datetime import datetime
from datetime import timedelta


def assemble_msg_alarm(alarm_dict, fault_id, fault_name):
    msg_alarm = "Alarm {}: {}".format(
        alarm_dict[fault_id], alarm_dict[fault_name])
    if 'appear_time' in alarm_dict.keys():
        appear_time = alarm_dict['appear_time']
        print(type(appear_time))
        msg_alarm += " was raised at {}".format(appear_time)
    if 'cleared_time' in alarm_dict.keys():
        cleared_time = alarm_dict['cleared_time']
        msg_alarm += " and it was cleared at {}".format(cleared_time)
    if 'additional_info' in alarm_dict.keys() and 'supplAlarmInfo' in alarm_dict['additional_info']:
        additional_info = alarm_dict['additional_info'].split('affected_cells=')[0]
        additional_info = additional_info.split(
            'faulty_cells=')[0].split('=')[1].strip()
        if len(additional_info) > 1:
            msg_alarm += ", alarm's additional info is {}".format(additional_info)
    if alarm_dict[fault_id] == '4590':
        for key, value in alarm_dict['fault_signature'].items():
            msg_alarm += "\n  {}: {}".format(key, value)
    return msg_alarm


def check_fault_4681_is_valid(alarm):
    if EXECUTION_CONTEXTS.top:
        allowed_4681 = BuiltIn().get_variable_value('@{allowed_4681}')
        alarm4681_subid_desc = BuiltIn().get_variable_value('&{4681_subid_desc}')
    result = True
    alarm4681_summary = "Failed diagnostic check points with NOK results: "
    alarm_4681_details_list = []
    if alarm:
        if 'supplAlarmInfo' in alarm.keys():
            alarm_supplAlarmInfo = alarm['supplAlarmInfo']
        elif 'additional_info' in alarm.keys():
            alarm_supplAlarmInfo = alarm['additional_info']
        print("alarm supplAlarmInfo is {}".format(alarm_supplAlarmInfo))
        if 'sanity check' in alarm_supplAlarmInfo:
            result = alarm_supplAlarmInfo.endswith(':{4}')
        else:
            checkpointID = alarm_supplAlarmInfo.split('.')[0].split(':')[1]
            checkpointID_list = [item.strip()
                                 for item in checkpointID.split(',')]
            print("searched checkpoint is {}".format(checkpointID_list))
            for num in checkpointID_list:
                if num in alarm4681_subid_desc.keys():
                    alarm4681_details = alarm4681_subid_desc[num]
                else:
                    alarm4681_details = "No desciption for Fault4681 subid {}!!!".format(num)
                if num not in allowed_4681:
                    result = False
                    alarm_4681_details_list.append("{} - {}".format(num, alarm4681_details))
            if not result:
                alarm4681_summary += ', '.join(alarm_4681_details_list)
                print('alarm 4681 summary is {}'.format(alarm4681_summary))
                if EXECUTION_CONTEXTS.top:
                    BuiltIn().set_suite_variable(
                        "${4681_summary}", alarm4681_summary)
    else:
        return False
    return result


def get_fault_time_for_cloud(alarm_dict, fault_id, time_key):
    """
    Retrieves the fault time for a specific fault ID from the alarm dictionary.

    This function searches the provided alarm dictionary for the specified fault ID
    and returns the corresponding time value associated with the given time key.

    Args:
        alarm_dict (dict): The dictionary containing alarm information.
        fault_id (str): The fault ID to search for in the alarm dictionary.
        time_key (str): The key to retrieve the time value for the specified fault ID.
                        options: appear_time, cleared_time, last_updated_time

    Returns:
        str: The time value associated with the specified fault ID and time key.
        None: If the fault ID or time key is not found in the alarm dictionary.
    """
    # Iterate over each dictionary in the list
    for alarm in alarm_dict:
        # Check if the fault_id is target fault_id and time_key is a key in the
        # dictionary
        if 'fault_id' in alarm.keys() and alarm['fault_id'] == fault_id and time_key in alarm.keys():
            # If so, print a message stating that Fault was cleared at the
            # time specified by time_key
            print('Fault {} cleared at {}'.format(fault_id, alarm[time_key]))
            # Return the time_key value
            return alarm[time_key]
    # If no dictionary was found where the fault_id is target fault_id and time_key
    # is a key, print a message stating this
    print('Fault {} not found or no cleared_time found!'.format(fault_id))
    # Return None, indicating that no suitable dictionary was found
    return None


def is_fault4675_allowed(fault4675, fault23_cleared_time):
    '''
    This function checks if the time difference between the cleared times of
    fault4675 and fault23 is less than 3 minutes.
    If the difference is less than 3 minutes, it returns True, otherwise it returns False.
    If 'cleared_time' does not exist in fault4675, it also returns False.
    '''
    # Check if 'cleared_time' exists in fault4675
    if 'cleared_time' in fault4675.keys():
        # Get the cleared time of fault4675
        fault4675_cleared_time = fault4675['cleared_time']
        print('Fault 4675 cleared_time at {}'.format(fault23_cleared_time))

        # Check if fault23_cleared_time exists
        if fault23_cleared_time:
            return is_cloud_alarm_expected_by_compare_time(
                fault23_cleared_time,
                fault4675_cleared_time,
                180
            )
    # If 'cleared_time' does not exist in fault4675, return False
    return False


def is_cloud_alarm_expected_by_compare_time(start_time, end_time, expected_time_differ_seconds):
    if start_time and end_time:
        start_time = start_time[:26] + \
            start_time[-6:]
        end_time = end_time[:26] + \
            end_time[-6:]

        # Convert the strings to datetime objects
        start_time = datetime.fromisoformat(
            start_time.replace("Z", "+00:00"))
        end_time = datetime.fromisoformat(
            end_time.replace("Z", "+00:00"))

        # Calculate the difference between the two times
        time_difference = end_time - start_time
        print(
            'Time difference between fault23 and fault4675 is {}'.format(time_difference))

        # Check if the difference is less than 3 minutes
        if time_difference < timedelta(seconds=int(expected_time_differ_seconds)):
            return True
        else:
            return False
    return False


def remove_active_alarms_occurs_before_test(alarms_before_dict, alarms_after_dict):
    """
    Remove alarms from the 'alarms_after_dict' that are present in the 'alarms_before_dict'.

    This function compares the alarms in the 'alarms_before' dictionary with those in the
    'alarms_after' dictionary.
    If an alarm with the same 'fault_id' and 'appear_time' is found in both dictionaries,
    it is removed from the 'alarms_after' list.

    Args:
        alarms_before_dict (dict): Dictionary containing alarms before the test.
        alarms_after_dict (dict): Dictionary containing alarms after the test.

    Returns:
        dict: The 'alarms_after_dict' with alarms that were present in 'alarms_before_dict' removed.
    """
    if isinstance(alarms_before_dict, dict):
        alarms_before = alarms_before_dict.get('alarms', [])
        alarms_after = alarms_after_dict.get('alarms', [])
        alarms_after = [
            alarm_after for alarm_after in alarms_after
            if not any(
                alarm_before["fault_id"] == alarm_after["fault_id"] and
                alarm_before["appear_time"] == alarm_after["appear_time"]
                for alarm_before in alarms_before
            )
        ]
        alarms_after_dict['alarms'] = alarms_after
    else:
        print("Invalid input. Expected a dictionary.")
    return alarms_after_dict


def remove_historic_alarms_occurs_before_test(alarms_before_dict, alarms_after_dict):
    """
    Remove alarms from alarms_after_dict if their 'uuid' exists in alarms_before_dict.

    Args:
        alarms_before_dict (dict): Dictionary containing alarms before the test.
        alarms_after_dict (dict): Dictionary containing alarms after the test.

    Returns:
        dict: Updated alarms_after_dict with alarms removed if their 'uuid' exists in alarms_before_dict.
    """
    if isinstance(alarms_before_dict, dict) and isinstance(alarms_after_dict, dict):
        # Extract the list of UUIDs from dict1
        uuids_exists_before_test = {
            alarm.get('uuid') for alarm in alarms_before_dict.get('alarms', [])
        }

        # Filter out alarms in alarms_after_dict whose UUID exists in alarms_before_dict
        alarms_after_dict['alarms'] = [
            alarm for alarm in alarms_after_dict.get('alarms', [])
            if alarm.get('uuid') not in uuids_exists_before_test
        ]
    else:
        print("Invalid input. Both inputs must be dictionaries.")
    return alarms_after_dict


def remove_8000_alarm_from_cu_active_alarms(cu_alarms_dict):
    """
    Remove the alarm with fault_id '8000' from the 'cu_alarms_dict' and decrement 'total' if removed.

    Args:
        cu_alarms_dict (dict): Dictionary containing CU alarms.

    Returns:
        dict: The updated 'cu_alarms_dict' with the alarm removed if it was present.
    """
    if isinstance(cu_alarms_dict, dict):
        cu_alarms = cu_alarms_dict.get('alarms', [])
        original_count = len(cu_alarms)
        cu_alarms = [
            alarm for alarm in cu_alarms
            if alarm.get('fault_id') != '8000'
        ]
        removed_count = original_count - len(cu_alarms)
        cu_alarms_dict['alarms'] = cu_alarms
        if removed_count > 0 and 'total' in cu_alarms_dict:
            cu_alarms_dict['total'] = max(0, cu_alarms_dict['total'] - removed_count)
    else:
        print("Invalid input. Expected a dictionary.")
    return cu_alarms_dict


def get_rdc_snapshot_rmods(rdc_fid_list, active_alarms):
    """
    Extracts RMOD identifiers from active alarm strings for given Fault IDs.

    This function searches through a list of active alarm strings and extracts all occurrences
    of RMOD identifiers (e.g., 'RMOD_R-2') that are associated with the specified Fault IDs.

    Args:
        rdc_fid_list (list of str): List of Fault IDs to search for in the alarm strings.
        active_alarms (list of str): List of alarm strings to be searched.

    Returns:
        list of str: List of RMOD identifiers (e.g., ['RMOD_R-2', 'RMOD_R-4']) found for the given Fault IDs.
    """
    rmod_list = []
    for fid in rdc_fid_list:
        for alarm in active_alarms:
            rdc_fid_match = re.findall(r'FaultId: {} .*RMOD_R-\d+'.format(fid), alarm)
            if rdc_fid_match:
                rmod = re.findall(r'RMOD_R-\d+', rdc_fid_match[0])
                if rmod and rmod[0] not in rmod_list:
                    rmod_list.extend(rmod)
    return rmod_list


def is_fault4590_allowed(alarm_dict, ccr_fallback):
    """
    Determines if fault 4590 is allowed based on the alarm dictionary and CCR fallback status.

    This function checks whether the CCR fallback is active and, if so, examines the 'fault_signature'
    information in the alarm dictionary to determine if the reset cause is 'WatchDog'. If both conditions
    are met, the function returns True, indicating that fault 4590 is allowed.

    Args:
        alarm_dict (dict): The alarm dictionary containing fault information, including 'fault_signature'.
        ccr_fallback (bool): The CCR fallback status. Should be True if CCR fallback is active.

    Returns:
        bool: True if fault 4590 is allowed
        (CCR fallback is active and reset cause is 'WatchDog'), False otherwise.

    Example:
        >>> alarm_dict = {...}
        >>> is_fault4590_allowed(alarm_dict, True)
        True
    """
    if not ccr_fallback:
        print("CCR fallback is not active. Fault 4590 is not allowed.")
        return False
    if 'cleared_time' not in alarm_dict.keys():
        print("Fault 4590 is still active. Not allowed.")
        return False
    resetCause = re.search(r'resetCause=(\w+)', alarm_dict.get('fault_signature').get('info'))
    if resetCause:
        print("Reset cause found:", resetCause.group(1))
        if resetCause.group(1) == 'WatchDog':
            BuiltIn().log_to_console(
                "Historical Fault 4590 with WatchDog reset reason is allowed if CCR fallback occurs. "
                "Details refer to PR847246 analysis.")
            return True
    return False


# Example usage:
if __name__ == '__main__':
    alarm_dict = {
        'additional_info': 'affected_cells=NR:none;',
        'affected_cells': {'impact_on_cells': [], 'impact_scope': 'none'},
        'alarm_id': 7115,
        'alarm_name': 'BASE STATION INFORMATION',
        'alarming_object': 'MRBTS-5018/EQM_R-1/APEQM_R-1/RMOD_R-1',
        'appear_time': '2025-08-19T13:37:38.328729335+02:00',
        'cleared_time': '2025-08-19T13:38:08.329310411+02:00',
        'degraded_cells': {'impact_on_cells': [], 'impact_scope': 'notAvailable'},
        'event_type_name': 'Quality of service',
        'fault_id': '4590',
        'fault_name': 'Fault signature for crash or failure',
        'fault_signature': {
            'category': 'UNKNOWN',
            'component': '1M213725506',
            'date': '2025-08-19T11:25:02Z',
            'extra_info': 'affected_cells=NR:none;',
            'info': 'resetCause=WatchDog(2),resetSignal=Unknown(16)',
            'load_name': 'vDUCNF26R1_0.300.31649',
            'minor': 'RFM_GPP',
            'reset_counter': 7417,
            'rfm_gpp': {
                'lastRunningSoftwareInfoName': 'SRM-rfsw-image-install-aeqb_0x29BCA24C.tar',
                'lastRunningSoftwareInfoVersion': '0x29BCA24C'
            },
            'scope': 'RFM'
        },
        'faulty_cells': {'impact_on_cells': [], 'impact_scope': 'notAvailable'},
        'last_updated_time': '2025-08-19T13:37:38.328729335+02:00',
        'probable_cause_name': 'Indeterminate',
        'severity': 'warning',
        'uuid': '96de7210-6d0b-406e-9310-6997f494ee72'
    }
    print(assemble_msg_alarm(alarm_dict, 'fault_id', 'fault_name'))
    print(is_fault4590_allowed(alarm_dict, True))
