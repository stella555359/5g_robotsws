import json
from robot.api import logger


def turn_dictionary_of_lists_inside_out(dictionary):
    """
    :param dictionary: dict of lists, example: {1:['a', 'b', 'c'],  2:['a'], 3:['c', 'd']}
    :return: dict of lists, example:           {'a':[1, 2], 'b':[1], 'c':[1, 3], 'd':[3]}
    """
    output_dict = {}
    for key, value_list in dictionary.items():
        assert isinstance(value_list, list)
        for value in value_list:
            output_dict.setdefault(value, []).append(key)
    return output_dict


def create_list_from_elements_appearing_in_two_lists(list1, list2):
    list_intersection = list(set(list1) & set(list2))
    return list_intersection


def merge_dictionaries(dict1, dict2):
    merged = dict1.copy()
    merged.update(dict2)
    return merged


def get_parameter_value_in_json_file(json_file, key, present_key=None, present_value=None):
    value = None
    with open(json_file, 'r+') as f:
        data = json.load(f)
        value = get_parameter_value_in_json(data, key, present_key, present_value)
        logger.info(value)
        f.seek(0)
        json.dump(data, f, indent=4)
        f.truncate()
    logger.info(value)
    return value


def get_parameter_values_in_json_file(json_file, key, present_key=None, present_value=None):
    values = None
    with open(json_file, 'r+') as f:
        data = json.load(f)
        values = get_parameter_values_in_json(data, key, present_key, present_value)
        logger.info(values)
        f.seek(0)
        json.dump(data, f, indent=4)
        f.truncate()
    logger.info(values)
    return values


def change_value_in_json_file(json_file, key, value, present_key=None, present_value=None):
    value = int(value)
    with open(json_file, 'r+') as f:
        data = json.load(f)
        change_value_in_json(data, key, value, present_key, present_value)
        f.seek(0)
        json.dump(data, f, indent=4)
        f.truncate()


def get_parameter_value_in_json(data, key, present_key=None, present_value=None):
    """
    :param data: a json type loaded data
    :param key: key to find in the nested data
    :param present_key: a key-value pair that additionally must be present on the same tree level where the key is found
    :param present_value: key-value pair that additionally must be present on the same tree level where the key is found
    :return: the function returns value of given key (first found) on any tree level
    """
    additional_condition = True
    if isinstance(data, dict):
        if present_key:
            additional_condition = False
            if present_key in data.keys():
                additional_condition = data[present_key] == present_value
        for k, v in data.items():
            if k == key and additional_condition:
                logger.info('Found ' + key + ' parameter inside the following dict:')
                logger.info(json.dumps(data, indent=4, sort_keys=True))
                return v
            elif isinstance(v, dict) or isinstance(v, list):
                value = get_parameter_value_in_json(v, key, present_key, present_value)
                if value is not None:
                    return value
    elif isinstance(data, list):
        for subtree in data:
            value = get_parameter_value_in_json(subtree, key, present_key, present_value)
            if value is not None:
                return value


def get_parameter_values_in_json(data, key, present_key=None, present_value=None):
    """
    :param data: a json type loaded data
    :param key: key to find in the nested data
    :param present_key: a key-value pair that additionally must be present on the same tree level where the key is found
    :param present_value: key-value pair that additionally must be present on the same tree level where the key is found
    :return: the function returns value list of given key (all found) on any tree level
    """
    values = []
    additional_condition = True
    if isinstance(data, dict):
        if present_key:
            additional_condition = False
            if present_key in data.keys():
                additional_condition = data[present_key] == present_value
        for k, v in data.items():
            if k == key and additional_condition:
                logger.info('Found ' + key + ' parameter inside the following dict:')
                logger.info(json.dumps(data, indent=4, sort_keys=True))
                values.append(v)
            elif isinstance(v, dict) or isinstance(v, list):
                nested_values = get_parameter_values_in_json(v, key, present_key, present_value)
                values = values + nested_values
    elif isinstance(data, list):
        for subtree in data:
            nested_values = get_parameter_values_in_json(subtree, key, present_key, present_value)
            values = values + nested_values
    return values


def change_value_in_json(data, key, value, present_key=None, present_value=None):
    """
    :param data: a json type loaded data
    :param key: key to find in the nested data
    :param value: a value to replace under the given key
    :param present_key: a key-value pair that additionally must be present on the same tree level where the key is found
    :param present_value: key-value pair that additionally must be present on the same tree level where the key is found
    :return: the function does not return anything; the resulting edits of the input data should be visible outside
    of this function.
    """
    additional_condition = True
    if isinstance(data, dict):
        if present_key:
            additional_condition = False
            if present_key in data.keys():
                additional_condition = data[present_key] == present_value
        for k, v in data.items():
            if k == key and additional_condition:
                logger.info('Found ' + key + ' parameter inside the following dict:')
                logger.info(json.dumps(data, indent=4, sort_keys=True))
                logger.debug('Replacing {} with {}'.format(v, value))
                data[k] = value
            elif isinstance(v, dict) or isinstance(v, list):
                change_value_in_json(v, key, value, present_key, present_value)
    elif isinstance(data, list):
        for subtree in data:
            change_value_in_json(subtree, key, value, present_key, present_value)
