"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""

import re
import logging
import datetime
from dateutil import parser


ITEM_TYPE = ("Item type", "CommonList")
ITEM_ID = ("Item id", "IPSecStatus")
ENTRIES_PER_FIRST_ENTRY = 3
ENTRIES_PER_LAST_ENTRY = 3
STATUS_PATTERN = re.compile(r"activationStatus: (\w+),")
SECURED_PATTERN = re.compile(r"isSecured: (\w+),")


def validate_ipsec_status(blackbox, kwargs) -> (bool, dict):
    """
    Accepted validation parameters:
    ipsec_expected_activationStatus
    ipsec_expected_isSecured
    ipsec_expected_ports
    ipsec_timestamp_before_change
    """
    elements_found = []
    for blackbox_item in blackbox:
        if blackbox_item.get(ITEM_TYPE[0]) == ITEM_TYPE[1]:
            if blackbox_item.get(ITEM_ID[0]) == ITEM_ID[1]:
                logging.info(f"Found {ITEM_ID[1]} entry:\n{blackbox_item}")
                validation_status = {
                    "initial_entries_validated": None,
                    "initial_entries_count_validated": None,
                    "last_entries_validated": None,
                    "last_entries_count_validated": None,
                    "activation_validated": None,
                    "secured_validated": None,
                    "port_validated": None,
                    "timestamp_validated": None,
                }

                initial_entries_validated, initial_entries_count_validated = _validate_initial_entries(
                    blackbox_item=blackbox_item
                )
                validation_status["initial_entries_validated"] = initial_entries_validated
                validation_status["initial_entries_count_validated"] = initial_entries_count_validated

                last_entries_validated, last_entries_count_validated = _validate_last_entries(
                    blackbox_item=blackbox_item
                )
                validation_status["last_entries_validated"] = last_entries_validated
                validation_status["last_entries_count_validated"] = last_entries_count_validated

                activation_validated, secured_validated, port_validated = _validate_ipsec_and_secured_status(
                    blackbox_item=blackbox_item, kwargs=kwargs
                )
                validation_status["activation_validated"] = activation_validated
                validation_status["secured_validated"] = secured_validated
                validation_status["port_validated"] = port_validated

                timestamp_validated = _validate_ipsec_timestamp(
                    blackbox_item=blackbox_item, kwargs=kwargs
                )
                validation_status["timestamp_validated"] = timestamp_validated
                elements_found.append(validation_status)
                logging.info(f"Validation status for:\n{blackbox_item}")
                logging.info(validation_status)

    if not elements_found:
        logging.error(f"No IPSecStatus section found")
        return False, {}
    for element in elements_found:
        if False in element.values():
            return False, {}
        if (element["activation_validated"] and element["secured_validated"]) is None:
            return False, {}
    return True, {}


def _validate_initial_entries(blackbox_item: dict[str: any]) -> (bool, bool):
    initial_entries_validated = False
    initial_entries_count_validated = False
    number_of_initial_entries = blackbox_item.get("Max initial entries")
    if not number_of_initial_entries:
        logging.error(f"Blackbox item did not contain correct number for 'Max initial entries':"
                      f" {blackbox_item}")
    if int(number_of_initial_entries) == 10 or int(number_of_initial_entries) == 0:
        initial_entries_validated = True
    else:
        logging.error(f"Blackbox item did not contain correct number with initial entries:"
                      f" {blackbox_item}")
    initial_entries = blackbox_item.get(f"First {number_of_initial_entries} entries", [])
    if not initial_entries:
        logging.error(f"Blackbox item did not contain correct list with initial entries:"
                      f" {blackbox_item}")
    initial_entry_count = len(initial_entries)
    if (initial_entry_count == ENTRIES_PER_FIRST_ENTRY * 10
            or initial_entry_count == ENTRIES_PER_FIRST_ENTRY * 0):
        initial_entries_count_validated = True
    else:
        logging.error(f"Blackbox item did not contain correct number of initial entries:"
                      f" {blackbox_item}")
    return initial_entries_validated, initial_entries_count_validated


def _validate_last_entries(blackbox_item: dict[str: any]) -> (bool, bool):
    last_entries_validated = False
    last_entries_count_validated = False
    number_of_last_entries = blackbox_item.get("Max last entries")
    if not number_of_last_entries:
        logging.error(f"Blackbox item did not contain correct number for 'Max last entries':"
                      f" {blackbox_item}")
    if int(number_of_last_entries) == 20 or int(number_of_last_entries) == 1:
        last_entries_validated = True
    else:
        logging.error(f"Blackbox item did not contain correct number with last entries:"
                      f" {blackbox_item}")
    last_entries = blackbox_item.get(f"Last {number_of_last_entries} entries", [])
    if not last_entries:
        logging.error(f"Blackbox item did not contain correct list with last entries:"
                      f" {blackbox_item}")
    last_entry_count = len(last_entries)
    if (last_entry_count == ENTRIES_PER_LAST_ENTRY * 20
            or last_entry_count == ENTRIES_PER_LAST_ENTRY * 1):
        last_entries_count_validated = True
    else:
        logging.error(f"Blackbox item did not contain correct number of last entries:"
                      f" {blackbox_item}")
    return last_entries_validated, last_entries_count_validated


def _validate_ipsec_and_secured_status(blackbox_item: dict[str: any], kwargs) -> (bool, bool, bool):
    activation_validated = False
    secured_validated = False
    port_validated = False
    number_of_last_entries = blackbox_item.get("Max last entries")
    last_entries = blackbox_item.get(f"Last {number_of_last_entries} entries", [])

    expected_activation_status = kwargs.get("ipsec_expected_activationStatus")
    expected_secured_status = kwargs.get("ipsec_expected_isSecured")
    if not expected_activation_status and not expected_secured_status:
        logging.error("No expected status given for 'ipsec_expected_activationStatus' or"
                      "'ipsec_expected_isSecured'. At least one needs to be provided.")

    ipsec_latest_entry = ""

    for entry in last_entries:
        if "[0] Entry" in entry:
            ipsec_latest_entry = entry
    if not ipsec_latest_entry:
        logging.error(f"Blackbox item did not contain correct entries: {blackbox_item}")
    if expected_activation_status:
        result = re.search(STATUS_PATTERN, ipsec_latest_entry)
        if result:
            status_found = result.group(1)
            if expected_activation_status == status_found:
                activation_validated = True
    else:
        activation_validated = None

    if expected_secured_status:
        result = re.search(SECURED_PATTERN, ipsec_latest_entry)
        if result:
            status_found = result.group(1)
            if expected_secured_status == status_found:
                secured_validated = True
    else:
        secured_validated = None

    expected_ports = kwargs.get("ipsec_expected_ports")
    if expected_ports:
        result = re.search(r"Entry: (" + expected_ports + r") activationStatus", ipsec_latest_entry)
        if result:
            status_found = result.group(1)
            if expected_ports == status_found:
                port_validated = True
    else:
        port_validated = None
        logging.info("'expected_ports' were not provided, skipping port validation")
    return activation_validated, secured_validated, port_validated


def _validate_ipsec_timestamp(blackbox_item: dict[str: any], kwargs) -> bool:
    timestamp_validated = False
    ipsec_latest_timestamp = ""

    initial_timestamp = kwargs.get("ipsec_timestamp_before_change")
    if not initial_timestamp:
        timestamp_validated = None
        logging.info(f"'ipsec_timestamp_before_change' was not provided, skipping full timestamp validation")

    number_of_last_entries = blackbox_item.get("Max last entries")
    last_entries = blackbox_item.get(f"Last {number_of_last_entries} entries", [])

    for entry in last_entries:
        if "[0] Received timestamp" in entry:
            ipsec_latest_timestamp = entry
    if not ipsec_latest_timestamp:
        logging.error(f"Blackbox item did not contain correct entries: {blackbox_item}")
    extracted_timestamp = ipsec_latest_timestamp.split(": ")[1]
    parsed_extracted_timestamp = parser.parse(extracted_timestamp)
    current_timestamp = datetime.datetime.now(datetime.timezone.utc)
    if initial_timestamp:
        if initial_timestamp < parsed_extracted_timestamp < current_timestamp:
            timestamp_validated = True
            logging.info(f"Extracted timestamp '{extracted_timestamp}' matches condition of: "
                         f"{initial_timestamp} < {extracted_timestamp} < {str(current_timestamp)}")
        else:
            logging.error(f"Extracted timestamp '{extracted_timestamp}' does not match condition of: "
                          f"{initial_timestamp} < {extracted_timestamp} < {str(current_timestamp)}")
    else:
        if parsed_extracted_timestamp < current_timestamp:
            timestamp_validated = True
            logging.info(f"Extracted timestamp '{extracted_timestamp}' matches condition of: "
                         f"{extracted_timestamp} < {str(current_timestamp)}")
        else:
            logging.error(f"Extracted timestamp '{extracted_timestamp}' does not match condition of: "
                          f"{extracted_timestamp} < {str(current_timestamp)}")
    return timestamp_validated
