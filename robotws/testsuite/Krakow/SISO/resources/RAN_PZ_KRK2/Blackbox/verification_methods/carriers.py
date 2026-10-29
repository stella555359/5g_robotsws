"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""

import logging
import datetime
from dateutil import parser


ITEM_TYPE = ("Item type", "carriers")
ITEM_ID_RX = ("Item id", "RX")
ITEM_ID_TX = ("Item id", "TX")
NUMBER_OF_CARRIERS = 4
ENTRIES_PER_CARRIER = 8


def validate_rx_carrier_status(blackbox, kwargs) -> (bool, [{str: str}]):
    return _validate_carrier(blackbox=blackbox, carrier="RX", kwargs=kwargs)


def validate_tx_carrier_status(blackbox, kwargs) -> (bool, [{str: str}]):
    return _validate_carrier(blackbox=blackbox, carrier="TX", kwargs=kwargs)


def _validate_carrier(blackbox, carrier, kwargs) -> (bool, [{str: str}]):
    elements_found = []
    extracted_data = []
    if carrier == "RX":
        carrier_item_id = ITEM_ID_RX[0]
        carrier_item_value = ITEM_ID_RX[1]
    elif carrier == "TX":
        carrier_item_id = ITEM_ID_TX[0]
        carrier_item_value = ITEM_ID_TX[1]
    else:
        logging.error(f"Unknown given carrier type to validate: {carrier}")
        return False, extracted_data
    for blackbox_item in blackbox:
        if blackbox_item.get(ITEM_TYPE[0]) == ITEM_TYPE[1]:
            if blackbox_item.get(carrier_item_id) == carrier_item_value:
                logging.info(f"Found {carrier_item_value} entry:\n{blackbox_item}")
                validation_status, carriers_data = _validate_carrier_status(blackbox_item=blackbox_item,
                                                                            kwargs=kwargs)
                if validation_status:
                    elements_found.append(validation_status)
                    logging.info(f"Blackbox validation status {validation_status} for item: {blackbox_item}")
                if carriers_data:
                    extracted_data.append(carriers_data)
    if len(extracted_data) == 1:
        extracted_data = extracted_data[0]
    if not elements_found:
        logging.error(f"No carriers section found")
        return False, extracted_data
    for element in elements_found:
        if False in element.values():
            return False, extracted_data
    return True, extracted_data


def _validate_carrier_status(blackbox_item: {str: str}, kwargs) -> (bool, [{str: str}]):
    validation_status = {
        "timestamp_validated": None,
        "carrier_number_validated": None,
        "carrier_entries_number_validated": None,
        "carrier_data_extracted": None,
    }

    timestamp_validated = _validate_timestamp(blackbox_item=blackbox_item, kwargs=kwargs)
    validation_status["timestamp_validated"] = timestamp_validated

    carrier_data_extracted, carriers_data = _get_carrier_data(blackbox_item=blackbox_item)
    validation_status["carrier_data_extracted"] = carrier_data_extracted
    validation_status["carrier_number_validated"] = carrier_data_extracted
    validation_status["carrier_entries_number_validated"] = carrier_data_extracted
    return validation_status, carriers_data


def _validate_timestamp(blackbox_item: dict[str: any], kwargs) -> bool:
    timestamp_validated = False

    initial_timestamp = kwargs.get("carriers_timestamp_before_change")
    if not initial_timestamp:
        timestamp_validated = None
        logging.info(f"'carriers_timestamp_before_change' was not provided, skipping full timestamp validation")

    extracted_timestamp = blackbox_item.get(f"Last write", "")
    if not extracted_timestamp:
        logging.error(f"Blackbox item did not contain correct entry with timestamp: {blackbox_item}")
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


def _get_carrier_data(blackbox_item: dict[str: any]) -> (bool, [{str: str}]):
    carriers = []
    for carrier in range(NUMBER_OF_CARRIERS):
        carriers.append(
            {
                "name": blackbox_item.get(f"Carrier[{carrier}] name", ""),
                "type": blackbox_item.get(f"Carrier[{carrier}] type", ""),
                "antenna": blackbox_item.get(f"Carrier[{carrier}] antenna", ""),
                "frequency": blackbox_item.get(f"Carrier[{carrier}] frequency", ""),
                "bandwidth": blackbox_item.get(f"Carrier[{carrier}] bandwidth", ""),
                "power": blackbox_item.get(f"Carrier[{carrier}] power", ""),
                "hoppingMode": blackbox_item.get(f"Carrier[{carrier}] power", ""),
                "channelType": blackbox_item.get(f"Carrier[{carrier}] channelType", ""),
            }
        )
    logging.debug(f"Carrier data found: {carriers}")
    if not carriers:
        logging.error(f"Failed to extract carrier data from {blackbox_item}")
        return False, carriers
    for element in carriers:
        if "" in element.values():
            logging.error(f"Failed to extract all carrier data from {blackbox_item}")
            return False, carriers
    return True, carriers
