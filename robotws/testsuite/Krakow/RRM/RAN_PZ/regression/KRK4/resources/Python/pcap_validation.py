import json
import os

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.file_management import (
    load_json_file,
)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import (
    logger_console,
    logger_console_info,
)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.slice_scheduling.validate_functions import (
    check_msg_with_values_in_frame,
)
from itertools import product


class CustomException(Exception):
    def __init__(self, errors=None, expected_value=None, message=None, *args):
        if message is None:
            message = type(self).__name__
        if expected_value is not None and errors is not None:
            message = f"Inccorect value in {message} Error Value: {errors} Expected value: {expected_value} "
        elif errors is not None:
            message = f"Inccorect value in {message} Error Value: {errors}"
        elif expected_value is not None:
            message = f"Inccorect value in  {message} Expected value: {expected_value}"

        self.message = message
        self.errors = errors
        self.expected_value = expected_value
        super().__init__(self.message)


class GeneralFrameValueError(CustomException):
    def __init__(self, *args, **kwargs):
        self.args, self.kwargs = args, kwargs
        super().__init__(*self.args, **self.kwargs)


class NotFoundUniqueFiledInFrame(Exception):
    pass


class VisibleMessageError(Exception):
    pass


class PathMessageNotExist(Exception):
    pass


class DeepSearchError(Exception):
    pass


def read_json_file(json_file_path):
    """
    Reads a JSON file and returns its contents as a dictionary.

    Args:
        json_file_path (str): The path to the JSON file.

    Returns:
        dict: The contents of the JSON file as a dictionary.
    """
    with open(json_file_path) as file:
        file_contents = file.read()
    json_file = json.loads(file_contents)
    logger_console_info("Load JSON file")
    return json_file


def save_json_to_file(json_dict, output_file):
    """
    Save a JSON dictionary to a file.

    Args:
        json_dict (dict): The JSON dictionary to be saved.
        output_file (str): The name of the output file.

    Returns:
        str: The path of the saved file.
    """
    output = f"/home/ute/logs/{output_file}"
    json_object = json.dumps(json_dict)
    with open(output, "w") as outfile:
        outfile.write(json_object)
    return output


def convert_pcap_to_json_using_tshark(
    pcap_path, message_filter=None, output_dir=None, output_filename=None
):
    """
    Converts a pcap file to a JSON file using tshark.

    Args:
        pcap_path (str): The path to the pcap file.
        message_filter (str, optional): The filter to apply to the pcap file. Defaults to None.
        output_dir (str, optional): The directory to save the output JSON file. Defaults to None.
        output_filename (str, optional): The name of the output JSON file. Defaults to None.

    Returns:
        str: The path to the converted JSON file.
    """
    file_name = os.path.basename(pcap_path)
    dir_name = os.path.dirname(pcap_path)
    if output_dir is None:
        output_dir = dir_name
    if output_filename is None:
        file_name = file_name.replace("pcap", "json")
    else:
        if output_filename.endswith(".json"):
            file_name = output_filename
        else:
            file_name = output_filename + ".json"
    output_path = os.path.join(output_dir, file_name)
    if not message_filter:
        os.system(
            f'tshark -r "{pcap_path}" -T json --no-duplicate > {output_path}'
        )
    else:
        command = f'tshark -Y "{message_filter}" -r {pcap_path} -T json --no-duplicate > {output_path}'
        logger_console_info(command)
        os.system(command)
    logger_console_info(
        f".pcap file was converted to .json file to path: {output_path}"
    )
    return output_path


def check_that_list_not_include_dict(lst):
    """
    Checks if a list does not include any dictionaries.

    Args:
        lst (list): The list to be checked.

    Returns:
        bool: True if the list does not include any dictionaries, False otherwise.
    """
    return not any([isinstance(item, dict) for item in lst])


def deep_search_key(data, target_key, current_path=[], is_last_key=False):
    """
    Recursively searches for a target key in a nested dictionary or list.

    Args:
        data (dict or list): The nested dictionary or list to search in.
        target_key (any): The key to search for.
        current_path (list, optional): The current path in the nested structure. Defaults to an empty list.
        is_last_key (bool, optional): Indicates if the target key is the last key in the path. Defaults to False.

    Returns:
        dict: A dictionary containing the paths and corresponding values where the target key was found.
    """
    results = {}
    if isinstance(data, dict):
        for key, value in data.items():
            new_path = current_path + [key]
            if key == target_key:
                results[tuple(new_path)] = value
            else:
                results.update(deep_search_key(value, target_key, new_path))
    elif isinstance(data, list):
        if (
            is_last_key
            and isinstance(target_key, int)
            and check_that_list_not_include_dict(data)
        ):
            new_path = current_path + [target_key]
            results[tuple(new_path)] = data[target_key]
        else:
            for index, item in enumerate(data):
                new_path = current_path + [index]
                results.update(deep_search_key(item, target_key, new_path))
    return results


def check_is_last_key(list_of_key, index):
    """
    Check if the given index is the last index in the list.

    Args:
        list_of_key (list): The list of keys.
        index (int): The index to check.

    Returns:
        bool: True if the index is the last index in the list, False otherwise.
    """
    if len(list_of_key) - 1 != index:
        return False
    return True


def convert_to_direct_path(temporary_key):
    """
    Convert to direct path by removing the first element from each tuple in the given list.
    For some case's we have additional path like 0, this is appear when we find one of field, and saved our dict result
    we must saved to the list, so when we try iterate we, must get list value from 0.
    This method solve this problem and create proper path to our field.
    Args:
        temporary_key (list): A list of tuples.

    Returns:
        list: A new list with the first element removed from each tuple.
    """
    other_list = []
    for item in temporary_key:
        item = list(item)
        other_list.append(tuple(item[1::]))

    return other_list


def get_inside_message(part_frame, next_unique_field, return_field=True):
    """
    Retrieves the inside message from a given part_frame based on the next_unique_field.

    Args:
        part_frame (list or dict): The part_frame containing the message.
        next_unique_field (list): The list of fields to navigate through to reach the inside message.
        return_field (bool, optional): Specifies whether to return the field along with the inside message.
                                       Defaults to True.

    Returns:
        tuple: A tuple containing the inside message, the keys traversed to reach the inside message,
               and the direct path to the inside message.

    Raises:
        ValueError: If the searching method is too deep and an indirect keyword is required.

    """

    def check_if_dirrect_path(temporary_frame):
        if isinstance(temporary_frame, list) and len(temporary_frame) == 1 and isinstance(temporary_frame[0], dict):
            return True
        return False

    temporary_frame = part_frame
    temporary_keys = list()
    temporary_direct_path = list()
    for index, field in enumerate(next_unique_field):
        is_last_key = check_is_last_key(next_unique_field, index)
        direct_path = check_if_dirrect_path(temporary_frame)
        items = deep_search_key(temporary_frame, field, is_last_key=is_last_key)
        temporary_frame, temporary_key = list(items.values()), list(items.keys())
        temporary_keys.append(temporary_key)
        if direct_path:
            temp_direct_path = convert_to_direct_path(temporary_key)
            temporary_direct_path.append(temp_direct_path)
        else:
            temporary_direct_path.append(temporary_key)
        if len(temporary_frame) == 1 and return_field:
            temporary_frame = temporary_frame[0]
    return temporary_frame, temporary_keys, temporary_direct_path


def __print_status_of_correct_and_error_message(success: dict, failed: dict, percent_correct_key: str):
    """
    This function logs the status of messages that were successfully processed and those that failed.

    Parameters:
    success (dict): A dictionary containing the keys of successfully processed messages and their corresponding values.
    failed (dict): A dictionary containing the keys of messages that failed to process and their corresponding values.
    percent_correct_key (str): The key in the success and failed dictionaries
    that corresponds to the percentage of correctly processed messages.

    The function logs the key and the percentage of correct messages
    for each key in both the success and failed dictionaries.
    If the percent_correct_key is not provided, it logs the key and the number of occurrences instead.
    If there are any failed messages, the function raises a ValueError.

    Raises:
    ValueError: If there are any failed messages.
    """
    success_keys = list(success.keys())
    failed_keys = list(failed.keys())
    if percent_correct_key:
        for key in success_keys:
            logger_console_info(
                f"Success for key: {key}, \
                                Percent of correct message: {success[key][percent_correct_key]}%"
            )
        for key in failed_keys:
            logger_console_info(
                f"Failed for key: {key}, \
                                Percent of correct message: {failed[key][percent_correct_key]}%"
            )
    else:
        for key in success_keys:
            logger_console_info(
                f"Success for key: {key}, Number of occurence: {success[key]}"
            )
        for key in failed_keys:
            logger_console_info(
                f"Failed for key: {key}, Number of occurence: {failed[key]}"
            )
    if len(failed) > 0:
        raise ValueError


def prepare_dict_with_message_name(list_of_message: list):
    """
    Prepares a dictionary with message names as keys and empty lists as values.

    Args:
        list_of_message (list): A list of message names.

    Returns:
        dict: A dictionary with message names as keys and empty lists as values.
    """
    error_dict = dict()
    length_ = len(list_of_message)
    for message in list_of_message:
        error_dict.update({message: []})
    return error_dict


def validate_occurance_in_messages(errors, number_of_all_message, minimum_occurance=1):
    """
    Validates the occurrence of errors in a set of messages.

    Args:
        errors (dict): A dictionary containing the errors and their occurrences.
        number_of_all_message (int): The total number of messages.
        minimum_occurance (int, optional): The minimum required occurrence for an error. Defaults to 1.

    Raises:
        ValueError: If any error occurs less than the minimum required occurrence.

    Returns:
        None
    """
    errors_keys = list(errors.keys())
    success = {}
    failed = {}
    for key in errors_keys:
        number_of_error = errors[key]
        number_of_error_length = len(number_of_error)
        occurence = number_of_all_message - number_of_error_length
        if occurence >= minimum_occurance:
            success.update({key: occurence})
        else:
            failed.update({key: occurence})
    __print_status_of_correct_and_error_message(success, failed, None)


def validate_percent_of_error(errors, number_of_all_message, percent=80):
    """
    Validates the percent of error messages based on the total number of messages.

    Args:
        errors (dict): A dictionary containing error messages as values and their corresponding keys.
        number_of_all_message (int): The total number of messages.
        percent (int, optional): The minimum required percentage of correct messages. Defaults to 80.

    Returns:
        None

    Prints:
        The status of correct and error messages, along with their respective percentages.

    Example:
        errors = {
            '("nr_l1ul_l2ps_uldata_pucchreceivereq_t", "3gpp.sfn")': ["IncorrectVallue", "ValueNotInrange"],
            '("nr_l1ul_l2ps_uldata_pucchreceivereq_t", "UlData_pucchReceiveReqSubcell_t.sfnForProcessing")':
            ["IncorrectVallue", "IncorrectVallue", "IncorrectVallue"],
            ...
        }
        number_of_all_message = 1000
        percent = 80

        validate_percent_of_error(errors, number_of_all_message, percent)

    This will validate the percent of error messages in the given dictionary
    and print the status of correct and error messages.
    """
    success = {}
    failed = {}
    errors_keys = list(errors.keys())
    PERCENT_OF_CORRECT_MESSAGE = "PERCENT_OF_CORRECT_MESSAGE"
    ERROR_MESSAGES = "ERROR_MESSAGES"
    for key in errors_keys:
        number_of_error = errors[key]
        number_of_error_length = len(number_of_error)
        percent_of_correct_message = (
            (number_of_all_message - number_of_error_length) / number_of_all_message
        ) * 100
        if percent < percent_of_correct_message:
            success.update(
                {
                    key: {
                        PERCENT_OF_CORRECT_MESSAGE: percent_of_correct_message,
                        ERROR_MESSAGES: number_of_error,
                    }
                }
            )
        else:
            failed.update(
                {
                    key: {
                        PERCENT_OF_CORRECT_MESSAGE: percent_of_correct_message,
                        ERROR_MESSAGES: number_of_error,
                    }
                }
            )
    __print_status_of_correct_and_error_message(success, failed, PERCENT_OF_CORRECT_MESSAGE)


def validate_percent_of_error_in_two_messages(
    secound_errors,
    number_of_all_message,
    number_of_message_include_secound_message,
    percent,
):
    correct_of_first_message = (
        number_of_message_include_secound_message / number_of_all_message
    )

    success = {}
    failed = {}
    errors_keys = list(secound_errors.keys())
    PERCENT_OF_CORRECT_MESSAGE = "PERCENT_OF_CORRECT_MESSAGE"
    ERROR_MESSAGES = "ERROR_MESSAGES"
    for key in errors_keys:
        number_of_error = secound_errors[key]
        number_of_error_length = len(number_of_error)
        if number_of_message_include_secound_message == 0:
            percent_of_correct_message_secound = 0
        else:
            percent_of_correct_message_secound = (
                (
                    (number_of_message_include_secound_message - number_of_error_length)
                    / number_of_message_include_secound_message
                )
                * 100
                * correct_of_first_message
            )
        if percent < percent_of_correct_message_secound:
            success.update(
                {
                    key: {
                        PERCENT_OF_CORRECT_MESSAGE: percent_of_correct_message_secound,
                        ERROR_MESSAGES: number_of_error,
                    }
                }
            )
        else:
            failed.update(
                {
                    key: {
                        PERCENT_OF_CORRECT_MESSAGE: percent_of_correct_message_secound,
                        ERROR_MESSAGES: number_of_error,
                    }
                }
            )
    __print_status_of_correct_and_error_message(success, failed, PERCENT_OF_CORRECT_MESSAGE)


def get_message_value_from_frame(
    frame, unique_field, list_of_next_unique_field, expected_field_occurance=1
):
    """
    Retrieves the value of a message from a frame based on the provided unique field and list of next unique fields.

    Args:
        frame (dict): The frame to search for the message value.
        unique_field (str): The unique field to identify the message.
        list_of_next_unique_field (list): The list of next unique fields to navigate inside the message.
        expected_field_occurance (int, optional): The expected number of occurrences of the unique field. Defaults to 1.

    Returns:
        list: A list of message values found for each next unique field.

    Raises:
        DeepSearchError: If there are too many occurrences of the unique field in the frame.

    """
    frame_part = deep_search_key(frame, unique_field)
    number_of_keys = list(frame_part.keys())
    # path in dict never be the same, if we have list, dickt key will be diffrent due to position of list
    if len(number_of_keys) > expected_field_occurance:
        raise DeepSearchError("To many occurance")
        # Finding keyword is too deep. Find more than one this keyword,in diffrent path, add less deep keyword

    temporary_frame = list(frame_part.values()).copy()
    result_list = list()
    for next_unique_field in list_of_next_unique_field:
        result, _, _ = get_inside_message(temporary_frame, next_unique_field)
        result_list.append(result)
    return result_list


def generate_combinations(input_list):
    """
    Generate all combinations of tuples from sublists.

    Args:
        input_list (list): A list of sublists.

    Returns:
        list: A list of tuples representing all combinations of elements from the sublists.
    """
    # Generate all combinations of tuples from sublists
    result = list(product(*input_list))
    # Flatten the result to a single list of tuples
    flattened_result = [tuple(item for sublist in combination for item in sublist) for combination in result]
    return flattened_result


def get_message_path_from_frame(
    frame, unique_field, list_of_next_unique_field, expected_field_occurance=1
):
    frame_part = deep_search_key(frame, unique_field)
    number_of_keys = list(frame_part.keys())
    # path in dict never be the same, if we have list, dickt key will be diffrent due to position of list
    if len(number_of_keys) > expected_field_occurance or len(number_of_keys) < 1:
        raise DeepSearchError("To many occurance")
        # Finding keyword is too deep. Find more than one this keyword,in diffrent path, add less deep keyword

    list_of_next_unique_field_path = list()
    list_of_next_unique_field_path_direct = list()
    temporary_frame = list(frame_part.values()).copy()
    temporary_frame = temporary_frame[0]
    for next_unique_field in list_of_next_unique_field:
        try:
            _, key, key_direct = get_inside_message(temporary_frame, next_unique_field, return_field=False)

            paths = generate_combinations(key)
            full_path = [number_of_keys[0] + path for path in paths]
            list_of_next_unique_field_path.append(full_path)

            paths_direct = generate_combinations(key_direct)
            full_path_direct = [number_of_keys[0] + path for path in paths_direct]
            list_of_next_unique_field_path_direct.append(full_path_direct)

        except DeepSearchError as e:
            raise PathMessageNotExist(e)
    return list_of_next_unique_field_path, list_of_next_unique_field_path_direct


def validate_output_path_include_searching_message(messages_paths_list, list_of_next_unique_field):
    all_type_message_exist = list()
    for index, field in enumerate(list_of_next_unique_field):
        field = list(field)     # convert tuple to set to easiet search
        message_paths = messages_paths_list[index]   # list of all path to one message which we find
        all_one_type_message_included_all_field = list()
        if len(message_paths) == 0:
            all_one_type_message_included_all_field.append(False)
        else:
            for message_path in message_paths:
                message_path = list(message_path)
                all_filed_in_message = list()
                for item in field:
                    if item in message_path:
                        all_filed_in_message.append(True)
                    else:
                        all_filed_in_message.append(False)
                all_one_type_message_included_all_field.append(all(all_filed_in_message))
        all_type_message_exist.append(all(all_one_type_message_included_all_field))
    return all_type_message_exist


def get_path_for_single_packet(packet, keys):
    unique_field = keys[0]
    list_of_next_unique_field = keys[1:]
    result_list_path, result_list_path_direct = get_message_path_from_frame(
        packet, unique_field, list_of_next_unique_field, expected_field_occurance=1
    )
    return result_list_path, result_list_path_direct


def get_value_by_path_for_single_packet_single_path(packet, path: tuple):
    result = packet
    for item in path:
        try:
            result = result[item]
        except KeyError:
            raise PathMessageNotExist(f"Path: {path} is not correct, First valid key: {item}")
    return result


def ensure_that_message_exist(
    packets=[],
    keys=[],
    only_one_message=True,
    expected_field_occurance=1,
    percent=80,
    log=True
):
    if isinstance(packets, dict):
        packets = [packets]
    unique_field = keys[0]
    list_of_next_unique_field = keys[1:]
    correct_dict = prepare_dict_with_message_name(list_of_next_unique_field)
    error_dict = prepare_dict_with_message_name(list_of_next_unique_field)
    for packet in packets:
        result_list, a = get_message_path_from_frame(
            packet, unique_field, list_of_next_unique_field, expected_field_occurance
        )
        message_exist = validate_output_path_include_searching_message(result_list, list_of_next_unique_field)
        for i, result in enumerate(message_exist):
            if result:
                correct_dict[list_of_next_unique_field[i]].append("Correct")
            else:
                error_dict[list_of_next_unique_field[i]].append("ERROR")

    if only_one_message:
        dict_keys = list(correct_dict.keys())
        for dict_key in dict_keys:
            if len(correct_dict[dict_key]) == 0:
                raise PathMessageNotExist(f"Incorrect message: {dict_key}")
            if log:
                logger_console_info(
                    f"Number of correct message: {dict_key} is: {len(correct_dict[dict_key])}"
                )
            return True
    else:
        validate_percent_of_error(error_dict, len(packets), percent)


def __check_the_basic_frame_value_is_correct(packet, check_frame_general_structure):
    messages_keys = check_frame_general_structure["messages"]
    expected_values = check_frame_general_structure["expected_values"]
    unique_field = messages_keys[0]
    list_of_next_unique_field = messages_keys[1:]
    result_list = get_message_value_from_frame(packet, unique_field, list_of_next_unique_field)
    # Here we check that general structure of frame is correct is something is wrong we must raise error,
    # So, we not need calcualte eroor, This value should be set (list_of_next_unique_field=None, errors=None)
    handle_result(result_list=result_list, expected_values=expected_values, errors=None, list_of_next_unique_field=None)


def check_dffrent_type_of_message_has_correct_value(
    packets=[],
    keys=[],
    expected_values=[],
    expected_field_occurance=1,
    check_frame_general_structure=None,
    percent=60,
):
    errors = prepare_dict_with_message_name([x for x in range(len(expected_values))])
    for packet in packets:
        key_of_occurence = []
        for index, message_key in enumerate(keys):
            try:
                exist_result = ensure_that_message_exist(packet, keys=message_key, log=False)
                if exist_result:
                    key_of_occurence.append(index)
            except (PathMessageNotExist, DeepSearchError):
                continue
        if len(key_of_occurence) != 1:
            raise NotFoundUniqueFiledInFrame('Unexpected event, we find, more than one message or not find any message')

        unique_field = keys[key_of_occurence[0]][0]
        list_of_next_unique_field = keys[key_of_occurence[0]][1:]

        if check_frame_general_structure:
            try:
                __check_the_basic_frame_value_is_correct(packet, check_frame_general_structure)
            except GeneralFrameValueError as e:
                errors = increment_error_for_each_keyword(errors, list_of_next_unique_field, str(e))
                continue

        result_list = get_message_value_from_frame(
            packet, unique_field, list_of_next_unique_field, expected_field_occurance
        )
        errors = handle_result(
            result_list=result_list, expected_values=expected_values, errors=errors, list_of_next_unique_field=None)
    validate_percent_of_error(errors, len(packets), percent)


def handle_result(result_list, expected_values, errors, list_of_next_unique_field):
    """
    Handles the result list by comparing each result with its expected value and
    populates the errors dictionary with any message errors encountered.

    Args:
        result_list (list): A list of results to be compared.
        expected_values (list): A list of expected values corresponding to the results.
        errors (dict): A dictionary to store any message errors encountered.
        list_of_next_unique_field (list): A list of next unique fields.

    Returns:
        dict: The updated errors dictionary.

    Raises:
        GeneralFrameValueError: If a message error is encountered and the errors
            dictionary is empty.
    """
    for index, result in enumerate(result_list):
        message_error = check_msg_with_values_in_frame(
            result, expected_values[index]
        )
        if message_error:
            if errors:
                if list_of_next_unique_field:
                    errors[list_of_next_unique_field[index]].append(message_error)
                else:
                    errors[index].append(message_error)
            else:
                raise GeneralFrameValueError(errors=result, expected_value=expected_values[index])
    return errors


def check_percent_messages_has_given_value(
    packets=[],
    keys=[],
    expected_values=[],
    expected_field_occurance=1,
    check_frame_general_structure=None,
    percent=60,
):
    """
    Check if a certain percentage of messages in the given packets have the expected values for the specified keys.

    Args:
        packets (list): A list of packets to be checked.
        keys (list): A list of keys representing the fields to be checked in each packet.
        expected_values (list): A list of expected values for the specified keys.
        expected_field_occurance (int): The expected number of occurrences of the specified keys in each packet.
        check_frame_general_structure (bool): If True, check the general structure of each packet.
        percent (int): The minimum percentage of packets that should have the expected values.

    Returns:
        None

    Raises:
        GeneralFrameValueError: If the general frame value is incorrect.

    """
    unique_field = keys[0]
    list_of_next_unique_field = keys[1:]
    errors = prepare_dict_with_message_name(list_of_next_unique_field)
    for packet in packets:
        if check_frame_general_structure:
            try:
                __check_the_basic_frame_value_is_correct(packet, check_frame_general_structure)
            except GeneralFrameValueError as e:
                errors = increment_error_for_each_keyword(errors, list_of_next_unique_field, str(e))
                continue

        result_list = get_message_value_from_frame(
            packet, unique_field, list_of_next_unique_field, expected_field_occurance
        )
        errors = handle_result(result_list, expected_values, errors, list_of_next_unique_field)
    validate_percent_of_error(errors, len(packets), percent)


def increment_error_for_each_keyword(errors_dict, list_of_next_unique_field, message_error):
    """
    Increments the error count for each keyword in the given list of next unique fields.

    Parameters:
    - errors_dict (dict): A dictionary containing the error count for each keyword.
    - list_of_next_unique_field (list): A list of next unique fields.
    - message_error (str): The error message to append to each keyword in the errors_dict.

    Returns:
    - errors_dict (dict): The updated dictionary with incremented error count for each keyword.
    """
    for next_unique_field in list_of_next_unique_field:
        errors_dict[next_unique_field].append("ERROR")
    return errors_dict


def check_one_message_has_given_value(
    packets=[],
    keys=[],
    expected_values=[],
    expected_field_occurance=1,
    check_frame_general_structure=None,
):
    """
    Check if one message has the given value in the packets.

    Args:
        packets (list): List of packets to check.
        keys (list): List of keys representing the unique fields in the packets.
        expected_values (list): List of expected values for each unique field.
        expected_field_occurance (int, optional): Expected number of occurrences of the unique field. Defaults to 1.
        check_frame_general_structure (function, optional): Function to convert the packet to iCOM5G frame.
        Defaults to None.

    Returns:
        None
    """
    unique_field = keys[0]
    list_of_next_unique_field = keys[1:]
    occurance = prepare_dict_with_message_name(list_of_next_unique_field)
    for packet in packets:
        if check_frame_general_structure:
            try:
                __check_the_basic_frame_value_is_correct(packet, check_frame_general_structure)
            except GeneralFrameValueError as e:
                occurance = increment_error_for_each_keyword(occurance, list_of_next_unique_field, str(e))
                continue

        result_list = get_message_value_from_frame(
            packet, unique_field, list_of_next_unique_field, expected_field_occurance
        )
        occurance = handle_result(result_list, expected_values, occurance, list_of_next_unique_field)
    validate_occurance_in_messages(occurance, len(packets))


def check_percent_messages_has_given_value_in_consecutive_events(
    packets=[],
    first_keys=[],
    first_expected_values=[],
    second_keys=[],
    secound_expected_values=[],
    percent=80,
    expected_field_occurance=1,
    check_frame_general_structure=None,
):
    """
    Check if a certain percentage of messages in consecutive events have the given values.

    Args:
        packets (list): List of packets to be checked.
        first_keys (list): List of keys representing the unique field in the first message.
        first_expected_values (list): List of expected values for the first message.
        second_keys (list): List of keys representing the unique field in the second message.
        secound_expected_values (list): List of expected values for the second message.
        percent (int): The minimum percentage of messages that should have the given values.
        expected_field_occurance (int): The expected number of occurrences of the unique field in each message.
        check_frame_general_structure (bool): Flag indicating whether to check the general structure of the frame.

    Returns:
        None

    Raises:
        GeneralFrameValueError: If the general frame value is incorrect.

    """
    unique_field_first = first_keys[0]
    list_of_next_unique_field_first = first_keys[1:]
    unique_field_secound = second_keys[0]
    list_of_next_unique_field_secound = second_keys[1:]

    error_occurance_first = prepare_dict_with_message_name(
        list_of_next_unique_field_first
    )
    error_occurence_secound = prepare_dict_with_message_name(
        list_of_next_unique_field_secound
    )
    all_first_message_correct = 0
    for packet in packets:
        check_secound = True
        if check_frame_general_structure:
            try:
                __check_the_basic_frame_value_is_correct(packet, check_frame_general_structure)
            except GeneralFrameValueError as e:
                error_occurance_first = increment_error_for_each_keyword(error_occurance_first,
                                                                         list_of_next_unique_field_first, str(e))
                continue
        result_first_list = get_message_value_from_frame(
            packet,
            unique_field_first,
            list_of_next_unique_field_first,
            expected_field_occurance,
        )
        result_secound_list = get_message_value_from_frame(
            packet,
            unique_field_secound,
            list_of_next_unique_field_secound,
            expected_field_occurance,
        )

        # all paremetrs in first message must be return true if we want continue to secound parameters
        for index, result in enumerate(result_first_list):
            message_error = check_msg_with_values_in_frame(
                result, first_expected_values[index]
            )
            if message_error:
                error_occurance_first[list_of_next_unique_field_first[index]].append(
                    message_error
                )
                check_secound = False
        if check_secound:
            all_first_message_correct += 1
            for index, result in enumerate(result_secound_list):
                message_error = check_msg_with_values_in_frame(
                    result, secound_expected_values[index]
                )
                if message_error:
                    error_occurence_secound[
                        list_of_next_unique_field_secound[index]
                    ].append(message_error)

    validate_percent_of_error_in_two_messages(
        error_occurence_secound,
        len(packets),
        all_first_message_correct,
        percent=percent,
    )


def check_message_visible(packets, visible=True):
    """
    Check if the message is visible in the packets.

    Args:
        packets (list): A list of packets.
        visible (bool, optional): Flag indicating if the message should be visible.
        Defaults to True.

    Raises:
        ValueError: If the message is expected to be visible but no packets are found,
            or if the message is expected to be invisible but packets are found.
    """
    if visible and len(packets) == 0:
        raise VisibleMessageError("No packets found. Message is expected to be visible.")
    if not visible and len(packets) > 0:
        raise VisibleMessageError("Packets found. Message is expected to be invisible.")
