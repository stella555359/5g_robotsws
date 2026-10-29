"""
:copyright: Nokia Networks
:author: Jacek Bohdanowicz
:maintainer:  Jacek Bohdanowicz
:contact: jacek.bohdanowicz@nokia.com
"""

import re
import collections
import time
from ta5g_admin_operations import ta_admin_interface
from robot.api import logger
from robot.errors import ExecutionFailed


def replace_string_incrementally(string: str, search_for: str, replace_with: str):
    """
        Replaces :search_for: in the given :string: with :replace_with: containing `$`
        changing it to index number each time :search_for: is found.
    """
    count = len(re.findall(re.escape(search_for), string))
    for i in range(count):
        replace_inc = replace_with.replace('$', str(i))
        string = string.replace(search_for, replace_inc, 1)
    return string


def find_nodes_matching_regexp(obj, pattern: str):
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


def remove_nodes_matching_regexp(obj, pattern: str):
    """
        Removes nodes in the given :obj: whose keys match regexp :pattern:
    """
    if isinstance(obj, dict):
        keys_to_remove = [key for key in obj if re.search(pattern, key) is not None]
        for key in keys_to_remove:
            del obj[key]
        for key in obj:
            remove_nodes_matching_regexp(obj[key], pattern)
    elif isinstance(obj, list):
        for element in obj:
            remove_nodes_matching_regexp(element, pattern)
    return obj


def find_node_matching_regexp(obj, pattern: str):
    """
            Searches for first node in the given :obj: whose key match regexp :pattern:
            :return: Tuple with key and node
    """
    pattern = re.compile(pattern)
    queue = collections.deque([obj])
    while queue:
        obj = queue.popleft()
        if isinstance(obj, dict):
            for key in obj:
                match = pattern.search(key)
                if match is not None:
                    return key, obj[key]
                else:
                    queue.append(obj[key])
        elif isinstance(obj, list):
            queue.extend(obj)


def flatten_obj(obj, separator: str = '.', list_item: str = 'Item[$]') -> dict:
    """
        Flattens object :obj: to single-level dictionary where keys are separated by :separator: string
        and list elements are converted to keys using :list_item: pattern.
        Single-level dictionaries are useful for matching their keys with regexp.
        :return: Single-level dictionary
    """
    return _flatten_obj(obj, separator, list_item, [], {})


def _flatten_obj(obj, separator: str, list_item: str, string: list, result: dict) -> dict:
    """
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


def check_all_cells_are_disabled_lack_x2_links(field, expected_state, n_of_cells):
    list_alarms = []
    cell_status_list = []
    fault_name_regx = r'^Cell problem due to associated X2 links.* E1 link unavailability'
    cells_info = None
    alarms_info = None
    with ta_admin_interface.admin_interface() as ta5g_admin_client:
        conn_alias = ta5g_admin_client.connect_to()
        cells_info = conn_alias.get_cells_info()
        alarms_info = conn_alias.get_active_alarms()
    for cell in cells_info:
        actual = cell["status"][field].lower()
        logger.console('\t Cell {} status: {}'.format(cell['globalCellId'], actual))
        if actual == expected_state:
            cell_status_list.append(actual)
    for alarm in alarms_info:
        if re.match(fault_name_regx, alarm["faultName"]):
            list_alarms.append(alarm["alarmId"])
    logger.console(list_alarms)
    logger.console(cell_status_list)
    logger.console(len(cell_status_list))
    logger.console(len(list_alarms))
    check = len(cell_status_list) != n_of_cells and len(list_alarms) != n_of_cells
    logger.console(check)

    if len(cell_status_list) != n_of_cells or len(list_alarms) != n_of_cells:
        logger.console("\n Assertation RAISED")
        raise AssertionError(f"\t required fault was not raised yet for all cells")


def wait_for_cells_to_be_disabled(field="operationalState", expected_state="disabled", n_of_cells=4, timeout=180):
    logger.console("Waiting {} seconds for all cells to be disabled.".format(timeout))
    timeout = int(timeout)
    error = None
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            logger.console("Executing function")
            check_all_cells_are_disabled_lack_x2_links(field=field, expected_state=expected_state,
                                                       n_of_cells=n_of_cells)
            logger.console("Finished execution can start onair now")
            break
        except Exception as err:
            error = err
            time.sleep(1)
            continue
    else:
        raise error
