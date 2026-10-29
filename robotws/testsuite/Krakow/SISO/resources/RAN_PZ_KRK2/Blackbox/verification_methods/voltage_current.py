"""
:copyright: Nokia Networks
:author: Lukasz Wlosowicz
:contact: lukasz.wlosowicz@nokia.com
"""

import logging
import copy
import re
from datetime import datetime

REQUIRED_FIELDS_VOLTAGE = {'Item type', 'Item id', 'First write', 'Last write', 'First write ISTI', 'Last write ISTI',
                           'Ranges [V]', 'Values', 'Last days 90'}
REQUIRED_FIELDS_CURRENT = {'Item type', 'Item id', 'First write', 'Last write', 'First write ISTI', 'Last write ISTI',
                           'Ranges [A]', 'Values', 'Last days 90'}
DATE_FORMAT = "%Y-%m-%dT%H:%M:%S%z"


def validate_voltage_fields(blackbox, kwargs) -> (bool, dict):
    elements_found = []
    elements = {
        "required_fields_present": False,
        "equal_row_lengths": False,
        "last_90_days_row_always_lower_than_values_row": False
    }
    for blackbox_item in blackbox:
        if blackbox_item.get('Item type') == 'Voltage':
            temp_item = copy.deepcopy(elements)
            if set(blackbox_item.keys()) == REQUIRED_FIELDS_VOLTAGE:
                temp_item["required_fields_present"] = True

            ranges = re.split(r"\s+", blackbox_item.get('Ranges [V]').strip())
            values_str = re.split(r"\s+", blackbox_item.get('Values').strip())
            last_days_90_str = re.split(r"\s+", blackbox_item.get('Last days 90').strip())
            values = [int(v) for v in values_str]
            last_days_90 = [int(v) for v in last_days_90_str]
            if ranges and len(ranges) == len(values) and len(ranges) == len(last_days_90):
                temp_item["equal_row_lengths"] = True

            temp_item["last_90_days_row_always_lower_than_values_row"] = True
            for i in range(0, len(values)-1):
                if last_days_90[i] > values[i]:
                    temp_item["last_90_days_row_always_lower_than_values_row"] = False
                    logging.error(f"'Last days 90' row has more samples than 'Values' row on index: {i} (in column: "
                                  f"{ranges[i]} [V]). {last_days_90[i]} > {values[i]}")

            if False in temp_item.values():
                logging.error(f"Blackbox item did not match all criteria: {temp_item}, {blackbox_item}")
            elements_found.append(temp_item)
    if not elements_found:
        logging.error(f"No Voltage section found")
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
    return True, {}


def validate_current_fields(blackbox, kwargs) -> (bool, dict):
    elements_found = []
    elements = {
        "required_fields_present": False,
        "equal_row_lengths": False,
        "last_90_days_row_always_lower_than_values_row": False
    }
    for blackbox_item in blackbox:
        if blackbox_item.get('Item type') == 'Current':
            temp_item = copy.deepcopy(elements)
            if set(blackbox_item.keys()) == REQUIRED_FIELDS_CURRENT:
                temp_item["required_fields_present"] = True

            ranges = re.split(r"\s+", blackbox_item.get('Ranges [A]').strip())
            values_str = re.split(r"\s+", blackbox_item.get('Values').strip())
            last_days_90_str = re.split(r"\s+", blackbox_item.get('Last days 90').strip())
            values = [int(v) for v in values_str]
            last_days_90 = [int(v) for v in last_days_90_str]
            if ranges and len(ranges) == len(values) and len(ranges) == len(last_days_90):
                temp_item["equal_row_lengths"] = True

            temp_item["last_90_days_row_always_lower_than_values_row"] = True
            for i in range(0, len(values)-1):
                if last_days_90[i] > values[i]:
                    temp_item["last_90_days_row_always_lower_than_values_row"] = False
                    logging.error(f"'Last days 90' row has more samples than 'Values' row on index: {i} (in column: "
                                  f"{ranges[i]} [A]). {last_days_90[i]} > {values[i]}")

            if False in temp_item.values():
                logging.error(f"Blackbox item did not match all criteria: {temp_item}, {blackbox_item}")
            elements_found.append(temp_item)
    if not elements_found:
        logging.error(f"No Current section found")
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
    return True, {}


def validate_first_write_last_write_and_isti_for_voltage_and_current(blackbox: list[dict], kwargs) -> (bool, dict):
    elements_found = []
    elements = {
        "last_write_later_than_first_write": False,
        "last_write_isti_later_than_first_write_isti": False
    }
    for blackbox_item in blackbox:
        if blackbox_item.get('Item type') == 'Voltage' or blackbox_item.get('Item type') == 'Current':
            temp_item = copy.deepcopy(elements)
            first_write = blackbox_item.get('First write')
            first_write_dt = datetime.strptime(first_write, DATE_FORMAT)
            last_write = blackbox_item.get('Last write')
            last_write_dt = datetime.strptime(last_write, DATE_FORMAT)
            first_write_isti = float(blackbox_item.get('First write ISTI'))
            last_write_isti = float(blackbox_item.get('Last write ISTI'))
            if last_write_dt >= first_write_dt:
                temp_item["last_write_later_than_first_write"] = True
            if last_write_isti >= first_write_isti:
                temp_item["last_write_isti_later_than_first_write_isti"] = True

            if False in temp_item.values():
                logging.error(f"Blackbox item did not match all criteria: {temp_item}, {blackbox_item}")
            elements_found.append(temp_item)
    if not elements_found:
        logging.error(f"No Voltage nor Current section found")
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
    return True, {}


def get_voltage_histograms(blackbox: list[dict], kwargs) -> (bool, dict | list):
    elements_found = {}
    for blackbox_item in blackbox:
        if blackbox_item.get('Item type') == 'Voltage':
            item_id = blackbox_item.get('Item id')
            ranges = re.split(r"\s+", blackbox_item.get('Ranges [V]').strip())
            values_str = re.split(r"\s+", blackbox_item.get('Values').strip())
            last_days_90_str = re.split(r"\s+", blackbox_item.get('Last days 90').strip())
            values = [int(v) for v in values_str]
            last_days_90 = [int(v) for v in last_days_90_str]
            elements_found.update(
                {item_id: {"ranges": ranges,
                           "values": values,
                           "last_days_90": last_days_90}
                 }
            )
    if not elements_found:
        logging.error(f"No Voltage items found in blackbox")
        return False, {}
    else:
        return True, elements_found


def get_current_histograms(blackbox: list[dict], kwargs) -> (bool, dict | list):
    elements_found = {}
    for blackbox_item in blackbox:
        if blackbox_item.get('Item type') == 'Current':
            item_id = blackbox_item.get('Item id')
            ranges = re.split(r"\s+", blackbox_item.get('Ranges [A]').strip())
            values_str = re.split(r"\s+", blackbox_item.get('Values').strip())
            last_days_90_str = re.split(r"\s+", blackbox_item.get('Last days 90').strip())
            values = [int(v) for v in values_str]
            last_days_90 = [int(v) for v in last_days_90_str]
            elements_found.update(
                {item_id: {"ranges": ranges,
                           "values": values,
                           "last_days_90": last_days_90}
                 }
            )
    if not elements_found:
        logging.error(f"No Current items found in blackbox")
        return False, {}
    else:
        return True, elements_found
