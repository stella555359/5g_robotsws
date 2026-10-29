"""
Helper Functions

Helper functions for TEAL that are used across the template.

"""

import logging


def update_dictionary_and_log_on_missing_value(dict_to_update: dict, new_dict: dict) -> dict:
    """Updates the first dictionary wit the second and warns in case there are Keys missing.

    Args:
        dict_to_update (dict): dict that should be updated.
        Should have at least all keys as 'new_dict'
        new_dict (dict): the dict that will be used to update the first.

    Returns:
        dict: updated dict that has all the keys of the first dict, with the values updated
              according to 'new_dict'
    """
    for key, value in dict_to_update.items():
        if key not in new_dict.keys():
            logging.info('%s is not set by user, using default of %s', key, value)
        else:
            dict_to_update[key] = new_dict[key]
    return dict_to_update


def to_bool(input_value) -> bool:
    """Turns a String Boolean value into a python boolean. Does detect illegal values.

    Args:
        string_input (str, bool): input that should be turned into bool

    Returns:
        bool: the input value as bool or NoneType in case of illegal input.
    """
    if isinstance(input_value, str):
        if input_value.lower() == "false":
            return False
        if input_value.lower() == "true":
            return True
        logging.error('Wrong Boolean string Value in json file: %s, '
                      'allowed values are: "True", "False", True, False',
                      input_value)
        return False
    if isinstance(input_value, bool):
        return input_value
    return False


def unpack_list_of_lists(nested_list: list) -> list:
    """unpacks a list of list, for example: [[1, 2, 3], [4, 5, 6], [7, 8, 9]] to

    Args:
        nested_list (list): a nested list.

    Returns:
        list: the nested list in flattened form.
    """
    return [item for sublist in nested_list for item in sublist]


if __name__ == '__main__':
    assert to_bool('True')
    assert to_bool('true')
    assert to_bool(True)
    assert not to_bool('False')
    assert not to_bool('false')
    assert not to_bool(False)
    assert not to_bool('y')
