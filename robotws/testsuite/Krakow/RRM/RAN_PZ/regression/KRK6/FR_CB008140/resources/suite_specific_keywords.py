import re
import logging
from taf.rfrl.utilities.robot.general import get_builtin_value


def get_apn_id_from_query(apn_data):
    """
    Gets an APN ID from the string returned by adb shell command
    content query --uri content://telephony/carriers --where "name='APN_NAME'"
    :param apn_data: Apn data get by adb shell by above query
    """
    search_result = re.search('_id=(.*), name=', apn_data)
    apn_id = search_result.group(1) if search_result is not None else None
    logging.info('APN id from content query is equal %s', apn_id)
    return apn_id


def find_all_scells(expected_scells, message):
    """
    Finds expected SCells in message list. Message is part of pcap text structure.
    :param expected_scells: Scellsc expected to find in given message
    :param message: Message includning scells
    :return bool: Return true if all scells are in the message
    """
    expected_scells = ["{0:#0{1}x}".format(int(nr_ci), 11) for nr_ci in expected_scells]
    return all(expected_scell in str(message) for expected_scell in expected_scells)


def check_if_cells_counters_were_incremented(counters, cells_ids, bts_id, release):
    """
       Checks if last value of selected counters increased
       :param counters: Dictionary which contains cells counters.
       :param cells_ids: Ids of cells to check counters on.
       :param bts_id:  Index of list containing all gNBs in test line configuration.
       :return:  True if all counters incremented otherwise false.
    """
    _tl = get_builtin_value(param_name="tl")
    bts_name = _tl.gnbs[int(bts_id)].global_bts_id
    legacy_branches = ['SBTS23R3', 'SBTS23R4', 'SBTS24R1']
    if release in legacy_branches:
        cells_counters = counters['BTS']['CELLS']
    else:
        cells_counters = counters['BTS']['MRBTS-{}'.format(bts_name)]['NRBTS-{}'.format(bts_name)]
    incrementation_statuses = list()
    for cell_id in cells_ids:
        cell_counters = cells_counters['NRCELL-{}'.format(cell_id)]
        for counter_type in cell_counters.values():
            for counter_id, counter_values in counter_type.items():
                is_incremented = check_if_single_cell_counters_was_incremented(counter_id, cell_id,
                                                                               list(counter_values.values()))
                incrementation_statuses.append(is_incremented)
    return all(incrementation_statuses)


def check_if_single_cell_counters_was_incremented(counter_id, cell_id, counter_values):
    """
          Checks if last value of selected counter increased
          :param counter_id: Id of counter
          :param cell_id: Ids of cell to check counter on.
          :param counter_values: List of counter values.
          :return:  True if counter incremented otherwise false.
    """
    if not counter_values:
        logging.error("Counter {} list is empty. "
                      "Given counter is not collected for cell.".format(counter_id, str(cell_id)))
    last_value = counter_values[-1]
    if last_value == 0:
        logging.error("Counter {} not incremented for cell {}".format(counter_id, str(cell_id)))
        return False
    logging.info("Counter {} incremented for cell {}".format(counter_id, str(cell_id)))
    return True


def is_counter_incremented(counter):
    """
    Checks if counter is incremented
    :param counter:  Dictionary contains selected counter
    :return: True if counter is incremented otherwise false
    """
    counter_values = _get_most_nested_values_of_dict(counter)
    last_value = counter_values[-1]
    return last_value != 0


def _get_most_nested_values_of_dict(dict_):
    """
    Gets list of last elements in dictionary
    :param dict_: Python dictionary object
    :return: List of last elements values in dictionary
    """
    result = []
    if isinstance(dict_, dict):
        for values in dict_.values():
            result.extend(_get_most_nested_values_of_dict(values))
    else:
        result.append(dict_)
    return result
