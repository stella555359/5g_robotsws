"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""

import logging
import copy


ITEM_TYPE = ("Item type", "CommonList")
ITEM_ID = ("Item id", "PowerSequencer_FW_versions")
MAX_LAST_ENTRIES = "Max last entries"
MAX_INITIAL_ENTRIES = "Max initial entries"
ENTRIES_PER_LAST_ENTRY = 3
ENTRIES_PER_FIRST_ENTRY = 3


def validate_power_sequencer_first_and_last_entries(blackbox, kwargs) -> (bool, dict):
    elements_found = []
    elements = {
        "last_entries_unique": False,
        "last_entries_count": False,
        "initial_entries_unique": False,
        "initial_entries_count": False
    }
    for blackbox_item in blackbox:
        if blackbox_item.get(ITEM_TYPE[0]) == ITEM_TYPE[1]:
            if blackbox_item.get(ITEM_ID[0]) == ITEM_ID[1]:
                temp_item = copy.deepcopy(elements)
                for key, value in blackbox_item.items():
                    if key.startswith("Last"):
                        if len(value) % ENTRIES_PER_LAST_ENTRY == 0:
                            temp_item["last_entries_count"] = True
                        timestamps = []
                        for entry in value:
                            if "timestamp" in entry:
                                timestamps.append(entry.split(": ")[1])
                        timestamps_set = set(timestamps)
                        if timestamps and len(timestamps_set) == len(timestamps):
                            temp_item["last_entries_unique"] = True

                    if key.startswith("First"):
                        if len(value) % ENTRIES_PER_FIRST_ENTRY == 0:
                            temp_item["initial_entries_count"] = True
                        timestamps = []
                        for entry in value:
                            if "timestamp" in entry:
                                timestamps.append(entry.split(": ")[1])
                        timestamps_set = set(timestamps)
                        if timestamps and len(timestamps_set) == len(timestamps):
                            temp_item["initial_entries_unique"] = True
                if False in temp_item.values():
                    logging.error(f"Blackbox item did not match all criteria {temp_item} for item: {blackbox_item}")
                elements_found.append(temp_item)
    if not elements_found:
        logging.error(f"No PowerSequencer_FW_versions section found")
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
    return True, {}


def validate_power_sequencer_fields(blackbox: list[dict], kwargs) -> (bool, dict):
    elements_found = []
    elements = {
        "item_found": False,
        "item_type_match": False,
        "item_id_match": False,
        "max_initial_entries_match": False,
        "max_last_entries_match": False,
    }
    for blackbox_item in blackbox:
        if blackbox_item.get(ITEM_TYPE[0]) == ITEM_TYPE[1]:
            if blackbox_item.get(ITEM_ID[0]) == ITEM_ID[1]:
                temp_item = copy.deepcopy(elements)
                temp_item["item_found"] = True
                temp_item["item_type_match"] = True
                temp_item["item_id_match"] = True
                try:
                    max_initial_entries = int(blackbox_item.get(MAX_INITIAL_ENTRIES))
                    temp_item["max_initial_entries_match"] = True
                except Exception as e:
                    logging.error(f"Failed converting {MAX_INITIAL_ENTRIES} to number")

                try:
                    max_last_entries = int(blackbox_item.get(MAX_LAST_ENTRIES))
                    temp_item["max_last_entries_match"] = True
                except Exception as e:
                    logging.error(f"Failed converting {MAX_LAST_ENTRIES} to number")
                if False in temp_item.values():
                    logging.error(f"Blackbox item did not match all criteria {temp_item} for item: {blackbox_item}")
                elements_found.append(temp_item)
    if not elements_found:
        logging.error(f"No PowerSequencer_FW_versions section found")
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
    return True, {}


def get_power_sequencer_fields(blackbox: list[dict], kwargs) -> (bool, dict | list):
    elements_found = []
    for blackbox_item in blackbox:
        if blackbox_item.get(ITEM_TYPE[0]) == ITEM_TYPE[1]:
            if blackbox_item.get(ITEM_ID[0]) == ITEM_ID[1]:
                elements = {
                    "First 1 entries": blackbox_item.get("First 1 entries"),
                    "Last 5 entries": blackbox_item.get("Last 5 entries"),
                }
                elements_found.append(elements)
    if not elements_found:
        logging.error(f"No PowerSequencer_FW_versions section found")
        return False, {}
    if len(elements_found) == 1:
        return True, elements_found[0]
    return True, elements_found
