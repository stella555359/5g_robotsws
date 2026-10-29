import os
from ast import literal_eval
import json
import collections


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
