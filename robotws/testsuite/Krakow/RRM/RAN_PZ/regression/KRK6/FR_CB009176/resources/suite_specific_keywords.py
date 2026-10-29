import ast
import logging
import json
from lxml import etree

from robot.api import logger
from robot.api.deco import keyword

from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_suite_variable
from taf.sbts.oam.coam.admin import admin
from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException


class ResetSuccessException(Exception):
    pass


def convert_xml_pwroffdcporttimewin_to_python_object(xml_tree):
    """
    Converts XML tree of pwrOffDCPortTimeWin parameter to list of dictionaries.

    :param xml_tree: pwrOffDCPortTimeWin parameter in xml format
    :return: pwrOffDCPortTimeWin parameter in list of dictionaries format
    """

    items = []

    for item in xml_tree:
        item_as_dict = {field.get('name'): field.text for field in item}
        logging.debug(f'Structure {item_as_dict}')
        items.append(item_as_dict)

    return items


def update_pwroffdcporttimewin_list(items, new_item):
    """
    Updates pwrOffDCPortTimeWin collection of items by given new item.
    Each item in collection is identified by dav of week.
    If item already exists for given day it will be updated to.

    :param items: list of dictionaries with values of pwrOffDCPortTimeWin gNB parameter
    :param new_item:  item to add/update
    :return: modified pwrOffDCPortTimeWin list
    """

    current_item = next(filter(lambda i: i['dayOfWeek'] == new_item['dayOfWeek'], items), None)

    if current_item is not None:
        items.remove(current_item)

    items.append(new_item)

    return items


def get_nr_cell_id_in_hex(nr_cell_id):
    """
    The function dump nrcellid to hex format.
    :param nr_cell_id: cell's nrcellid in dec format
    :return: cell's nrcellid in hex format
    """
    return "{0:#0{1}x}".format(int(nr_cell_id), 11)


def convert_list_of_cells_ids_to_hex(nr_cell_ids):
    """
    The function converts list of cell ids to hex format.
    :param nr_cell_ids: list of cells ids in dec format
    :return: list of cells ids in hex format
    """
    return [get_nr_cell_id_in_hex(nr_cell_id) for nr_cell_id in nr_cell_ids]


def convert_list_of_cells_ids_to_str(nr_cell_ids):
    """
    The function converts list of cell ids to str format.
    :param nr_cell_ids: list of cells ids in dec format
    :return: list of cells ids in str format
    """
    return [str(nr_cell_id) for nr_cell_id in nr_cell_ids]


def find_all_scells_in_message(expected_scells, message):
    """
    Finds expected SCells in message list. Message is part of pcap text structure.
    :param expected_scells: Scellsc expected to find in given message
    :param message: Message includning scells
    :return bool: Return true if all scells are in the message
    """

    scells_as_str = map(str, expected_scells)
    scells_as_hex = map(get_nr_cell_id_in_hex, expected_scells)
    expected_scells = dict(zip(scells_as_str, scells_as_hex))
    return all(
        scell_id_as_str in str(message) or scell_id_as_hex in str(message)
        for scell_id_as_str, scell_id_as_hex in expected_scells.items()
    )


def find_item_in_message(expected_item, message):
    """
    Finds item in message.
    :param expected_item: Item expected to find in given message
    :param message: Message includning item
    :return bool: Return true if item is in message
    """

    return expected_item in str(message)


def find_items_in_message(expected_items, message):
    """
    Finds items in message.
    :param expected_items: Item expected to find in given message
    :param message: Message includning items
    :return bool: Return true if all items are included in message
    """

    return all(expected_item in str(message) for expected_item in expected_items)


def check_if_one_item_is_within_other_item(parent_item,  child_items, message):
    """
    Checks if items are included in other item
    :param parent_item: Item within other item should be included
    :param child_items: Items included in parent item
    :param message: Message includning items
    :return bool: Return true if all childs items ares included in parent items
    """

    parent_item_in_message = str(message.find(parent_item))
    return all(child_item in parent_item_in_message for child_item in child_items)


def check_if_item_has_proper_value(item, value, message):
    """
    Checks if item exists in message and have proper value
    :param item: Item to look for in message
    :param value: Value of looked item
    :param message: Message includning item
    :return bool: Return true if item exists and has proper value
    """

    message = str(message)
    index_of_item = message.find(item)
    item_and_value = message[index_of_item:].split(',')[0]
    return value in item_and_value.split(':')[1]


def count_appearances_in_message(item, appearances, message):
    """
    Checks apperances of item in message and return true if apperances are not less than given value
    :param item: Item to look for in message
    :param appearances: Number of apperances of item that need to be check in message
    :param message: Message includning item
    :return bool: Return true if item appears no less than given value in message
    """

    all_items_form_message = list(message.find(item))
    logging.info("All items of the message: {}".format(all_items_form_message))
    counter = 0
    for item in all_items_form_message:
        if "'val': '0'" in str(item):
            counter += 1
    logging.info("Item {} appeared {} times in {} message".format(item, counter, message))
    return counter >= int(appearances)


def find_cause_and_its_value(item, value, message):
    """
    Checks if item exists in message and have proper value
    :param item: Item to look for in message
    :param value: Value of looked item
    :param message: Message includning item
    :return bool: Return true if item exists and has proper value
    """

    item_in_message = str(message.find(item))
    return value in item_in_message


def check_messages_length(messages, expected_length):
    """
    Checks if table of messages have propper value
    :param messages: Table of message to check value
    :param expected_length: expected table length
    :return bool: Return true if expected lenght of table of messages in not less than given value
    """

    return len(list(messages)) >= int(expected_length)


def remove_unused_gnb_from_tl_robot_variable():
    """
    Removes second gNB from 'tl' variable that common keywords won't check its state since it is not used for tests
    :return: None
    """
    tl_var = get_builtin_value('tl')
    logging.info('Initial tl variable: {}'.format(tl_var))
    del tl_var.gnbs[1]
    logging.info('Modified tl variable: {}'.format(tl_var))
    set_robot_suite_variable('tl', tl_var)


def reset_and_expect_failure(dist_name: str) -> None:
    """
    Resets the unit and expects the reset operation to fail
    :param dist_name: Dist name of unit to reset
    :raise: ResetSuccessException
    :return: None
    """
    api = admin()
    connection = api.connect_to()
    try:
        connection.reset_unit(dist_name=dist_name, timeout=600)
    except AdminApiProcedureFailureException as e:
        logger.debug(f"Unit reset have failed, as expected. Exception {e}")
    else:
        logger.error("Unit reset have passed, and it was not expected.")
        raise ResetSuccessException
