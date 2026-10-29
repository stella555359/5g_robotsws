import json
import copy
import re
import collections
import logging
import os


logger = logging.getLogger()


def load_json_file(filename):
    """This is a small helper function to load test data from a JSON file for first analysis of the
    implementation of the analysis algorithm.

    :param str filename: The full plath to the json file to load
    """
    with open(filename) as json_file:
        return json.load(json_file)


def verify_extended_json_message_sequence_in_collection(recorded_data,
                                                        name_field,
                                                        reference_sequence,
                                                        strict_fields_check):
    """This verification algoritm expectes a reference sequence in the form of nested lists.
    The messages itself are defined in the following structure:

    .. code:: robotframework

        ${du_ca_released}     create dictionary
        ...    record_name=caConfigurationRecord
        ...    releasedSCells=1
        ...    releasedSCells.*Item 0.*DuSCellReleaseItem.*cellId=1
        ...    releasedSCells.*Item 0.*DuSCellReleaseItem.*cellId.*nrcgi.*plmn_Identity=13:41:98
        ...    releasedSCells.*Item 0.*DuSCellReleaseItem.*cellId.*nrcgi.*cellIdentity=00:00:04:00:30

    With the message defined in that structure you now need to define message sets. The algorithm
    will check for the correct order of the message set. But the messages given inside of a message
    set are allowed to vary in their order.

    .. code:: robotframework

        ${msg_set1}   Create List    ${du_scell_setup}
        ${msg_set2}   Create List    ${du_ca_released}   ${du_scell_release}

    Now you need to define the reference sequence by

    .. code:: robotframework

        ${reference_sequence}   Create List    ${msg_set1}    ${msg_set2}


    The call of the verification Keyword is then done like:

    .. code:: robotframework

        Verify PCMD Records Sequence in Collection   ${msg_set1}  ${msg_set2}   strict_fields_check=yes

    """
    reference_messages = [{'msg': msg, 'ref_index': (i_msg_set, i_msg)}
                          for i_msg_set, msg_set in enumerate(reference_sequence)
                          for i_msg, msg in enumerate(msg_set)]

    # filter recorded data for record name
    record_name = _get_record_name_from_references(reference_messages)
    filtered_data = _filter_recorded_data_by_record_name(recorded_data, record_name)

    strict_fields_check = strict_fields_check.lower() == 'yes'

    for message_index, message in enumerate([x['msg'] for x in reference_messages]):
        fits = _find_message_in_recorded_data(message, filtered_data, strict_fields_check)
        if fits is not None:
            reference_messages[message_index]['found_position'] = fits

    not_found_messages = [msg for msg in reference_messages if 'found_position' not in msg]
    for msg in not_found_messages:
        logger.error("Reference message not found: " + str(msg))
    assert len(not_found_messages) == 0, "Some Reference messages hav not been found!"

    # check that there is no gap in the found positions
    positions = [msg['found_position'] for msg in reference_messages]
    positions.sort()
    logging.info("positions = %s" % positions)
    has_no_gaps = all(positions[i] + 1 == positions[i + 1] for i in range(len(positions) - 1))
    logging.info("has_no_gaps = %s" % has_no_gaps)
    if has_no_gaps:
        logging.info("There are additional messages during the found sequence!")

    # create a sublist for validation
    ordered_validation_list = [(msg['found_position'], msg['ref_index']) for msg in reference_messages]

    # sort the sublist by recorded occurance
    sorted_list = sorted(ordered_validation_list, key=lambda x: x[0])
    in_order = True

    for i in range(len(sorted_list) - 1):
        if sorted_list[i][1][0] > sorted_list[i + 1][1][0]:
            in_order = False

    assert in_order, "The messages are not in the expected order!"


def _get_record_name_from_references(reference_messages):
    """The reference message contain as one field the record name.
    This function gets the record name of all reference message. For this implementation
    it is asserted, that all reference messages have the same record name.

    :param list reference_message: A list of all reference messages
    :returns: The record_name of the messages.
    """
    record_names = {msg['msg']['record_name'] for msg in reference_messages}
    assert len(record_names) == 1, "The record_name should be the same in all reference messages!"
    return list(record_names)[0]


def _filter_recorded_data_by_record_name(recorded_data, record_name):
    """Filters the recorded data by the given record_name. The recorded data is supposed to be a
    list of dictionaries. The dictionaries have one "root" dictionary with one key and the value
    being the nested data structure. This keyword filters for all messages/dictionaries, where the
    record_name is part of the uppermost key.

    :param list recorded_data: The json structure (list of dictionaries) containing the recorded data.
    :param str record_name: The record data to filter for.
    """

    recorded_data_filtered = [msg for msg in recorded_data if record_name in list(msg.keys())[0]]
    return recorded_data_filtered


def _find_message_in_recorded_data(message, recorded_data, strict_fields_check):
    """This function traverses all messages contained in the recorded_data and checks, if the given
    (reference) message is fitting to one item in the recorded_data structure. If the message is found,
    the position of the message in the recorded_data is returned.

    :param message: The reference message to be searched for in the recorded_data
    :param recorded_data: The structur holding all recorded messages to analyse
    """
    for message_index, recorded_message in enumerate(recorded_data):
        record_key = list(recorded_message.keys())[0]
        if message['record_name'] in record_key:
            # a message of same "container type" found

            # check by fields for the correct message
            fits = _is_fitting_to_expected_message(recorded_message, message, strict_fields_check)
            if fits:
                return message_index


def _is_fitting_to_expected_message(recorded_message, reference_message, strict_fields_check=False):
    """This function analyses one message from the recorded data structure and checks,
    if the message corresponds to the searched reference_message. The function will return
    boolean True, if the message fits, and boolean False, if it does not fit.

    :param dict recorded_message: One message (dictionary) of the recorded data structure
    :param list reference_message: The reference message containing regexp and values
    """
    flat_data = _flatten_obj(recorded_message, ".", "Item[$]", [], {})
    msg_copy = copy.deepcopy(flat_data)

    matching = False

    for field in reference_message:
        ret = _find_nodes_matching_regexp(flat_data, field + "$")
        if not ret:
            continue

        ret_key, ret_value = list(ret[0].items())[0]

        reference_value = str(reference_message[field])
        if (reference_value == str(ret_value) or reference_value == '\\d+' or reference_value == '.*'):
            matching = True
        else:
            return False
        flat_data.pop(ret_key)

    if strict_fields_check:
        matching = len(flat_data) == 0

    return matching


def _flatten_obj(obj, separator: str, list_item: str, string: list, result: dict) -> dict:
    """This function flattens the dictionary structure from a recorded message.
    The nested dictionary will be resolved into a dot notated list for each defined value.

        Internal function for :flatten_obj:
    """
    if isinstance(obj, dict):
        for key in obj:
            newstring = string[:]
            newstring.append(key)
            _flatten_obj(obj[key], separator, list_item, newstring, result)
    elif isinstance(obj, list):
        for i in range(len(obj)):
            newstring = string[:]
            newstring.append(list_item.replace('$', str(i)))
            _flatten_obj(obj[i], separator, list_item, newstring, result)
    else:
        result[separator.join(string)] = str(obj)
    return result


def _find_nodes_matching_regexp(obj, pattern: str):
    """
        Searches for nodes inside object whose key name matches provided regexp pattern.

        :author: Jacek Bohdanowicz
        :param obj: Object containing lists and dictionaries (example: JSON object)
        :param pattern: Regexp pattern to look for
    """
    result = []
    pattern = re.compile(pattern)
    queue = collections.deque([obj])
    while queue:
        obj = queue.popleft()
        if isinstance(obj, dict):
            for key in obj:
                match = pattern.search(key)
                if match is not None:
                    result.append({key: obj[key]})
                else:
                    queue.append(obj[key])
        elif isinstance(obj, list):
            queue.extend(obj)
    return result
