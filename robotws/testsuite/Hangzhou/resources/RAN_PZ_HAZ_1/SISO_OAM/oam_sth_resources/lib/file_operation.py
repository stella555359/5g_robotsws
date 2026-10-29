import os
from ast import literal_eval
import json
import collections


def get_alarm_time_per_fault_id(all_alarms, fault_id):
    """
    get alarm time per fault id
    | Input Paramaters | Man. | Description |
    | all_alarms       | Yes  | The return value of get_active_alarms in ute_admin |
    | fault_id      | Yes  | The fault id for the alarm which you want to get time from |

    | Return Value | The value of time |
    """
    for each_alarm in all_alarms:
        cur_id = each_alarm['faultId']
        if int(cur_id) == int(fault_id):
            return each_alarm['btsObservationTime']

    return None


def check_alarm_exist(all_alarms, check_info):
    """
    check the specified alarm exist
    | Input Paramaters | Man. | Description |
    | all_alarms       | Yes  | The return value of get_active_alarms in ute_admin, it's a list |
    | check_info  | Yes  | info to check the alarm, it should be a list |

    Example
    | check alarm exist | ${all_alarms} | ["faultId=6203", "severity=Major"] |
    """

    if not _check_alarm_exist_or_not(all_alarms, check_info):
        raise Exception("Alarm Not Exist! Check alarm exist failed.")

    return True


def _check_alarm_exist_or_not(all_alarms, kwargs):
    faultId = None
    severity = None
    distName = None
    number = None
    time = None
    details = None
    eventType = None
    notifier = None

    check_para = {}

    for ai in kwargs:
        para_list = ai.split("=")
        check_para[para_list[0]] = para_list[1]

    if "time" in check_para:
        check_para["btsObservationTime"] = check_para["time"]
        del check_para["time"]

    alarm_exist = False
    for each_alarm in all_alarms:
        check_flag = True
        for apara in check_para:
            if str(each_alarm[apara]).strip() != str(check_para[apara]).strip():
                check_flag = False
        if check_flag:
            alarm_exist = True
            break

    return alarm_exist


def check_alarm_not_exist(all_alarms, check_info):
    """
    check the specified alarm not exist
    | Input Paramaters | Man. | Description |
    | all_alarms       | Yes  | The return value of get_active_alarms in ute_admin, it's a list |
    | check_info  | Yes  | info to check the alarm, it should be a list |

    Example
    | check alarm not exist | ${all_alarms} | ["faultId=6203", "severity=Major"] |
    """

    if len(all_alarms) == 0:
        return True

    ret = _check_alarm_exist_or_not(all_alarms, check_info)

    if ret:
        raise Exception("Alarm Exist. Check alarm not exist failed.")

    return True


def update_json_file(target_json_file, dist_operation, dist_name, parameter_operation='update', **kwargs):
    """Setup Admin API.

        :param string target_json_file: json file to be updated or created
        :param integer dist_operation: operation for distName, update|delete|create
        :param string dist_name: distName
        :param string parameter_operation: update or delete
        :param kwargs: parameter=value

        examples:
        | update_json_file | D:\\Admin\\create_json\\abc.json | update | LNBTS-1 | update |
         anrThresRSRPNbCell=500 | actS1OlHandling=False |
    """

    if os.path.exists(target_json_file):
        with open(target_json_file) as json_file:
            if os.stat(target_json_file).st_size == 0:
                delta_file_data = []
                pass
            else:
                delta_file_data = json.load(json_file)

    dist_dict = {}
    para_list = []
    dist_dict['distName'] = dist_name
    dist_dict['operation'] = dist_operation
    if len(kwargs) > 0:
        for parameter in kwargs:
            para_dict = {}
            para_dict["parameterName"] = parameter
            para_dict["operation"] = parameter_operation
            para_value = str(kwargs[parameter])
            if isinstance(para_value, bytes) or isinstance(para_value, str):
                if para_value.startswith('{') and para_value.endswith('}'):
                    para_value = [literal_eval(para_value)]
                elif para_value.startswith('[') and para_value.endswith(']'):
                    para_value = literal_eval(para_value)
            para_dict["value"] = para_value
            para_list.append(para_dict)
    dist_dict['parameters'] = para_list
    delta_file_data += [dist_dict]
    delta_file_obj = _convert_unicode_to_string(delta_file_data)

    with open(target_json_file, 'w') as json_file:
        json_file.write(json.dumps(delta_file_obj, indent=4, sort_keys=True))


def _convert_unicode_to_string(data):
    if isinstance(data, str):
        return str(data)
    elif isinstance(data, collections.abc.Mapping):
        return dict(map(_convert_unicode_to_string, data.items()))
    elif isinstance(data, collections.abc.Iterable):
        return list(map(_convert_unicode_to_string, data))
    else:
        return data


if __name__ == '__main__':
    pass
