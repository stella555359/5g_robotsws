"""
:author: Klaudia Horyn Dawid Dabrowski Mateusz Potoniec
:contact: dawid.dabrowski@nokia.com mateusz.potoniec@nokia.com
:maintainer: dawid.dabrowski@nokia.com mateusz.potoniec@nokia.com
"""

import json

from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.utilities.logger import custom_logger as logger

from frmon_operator import FrmonOperator


def turn_on_cb012667_feature(bts_id=0, du_id=0, ru_id=0, ru_bts_id=None):
    """
    Enable feature CB012667 on RU.

    Enables the CB012667 feature, resets the radio unit, waits for it to come online,
    and verifies all cells are on air.

    :param ru_id: ID of the RU
    :param bts_id: ID of the BTS
    :param du_id: ID of the DU
    """
    ru_bts_id = int(ru_bts_id) if ru_bts_id is not None else int(ru_id)
    logger.log_info_to_console(f"Enabling CB012667 feature on RU{ru_id}, RU BTS ID: {ru_bts_id}")
    frmon_operator = FrmonOperator()
    frmon_operator.turn_on_feature(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
    _reset_ru_and_wait_until_online(bts_id=bts_id, du_id=du_id, ru_id=ru_bts_id)
    logger.log_info_to_console(f"CB012667 feature enabled on RU{ru_id}, RU BTS ID: {ru_bts_id}")


def turn_off_cb012667_feature(bts_id=0, du_id=0, ru_id=0, ru_bts_id=None):
    """
    Disable feature CB012667 on RU.

    Disables the CB012667 feature, resets the radio unit, waits for it to come online,
    and verifies all cells are on air.

    :param ru_id: ID of the RU
    :param bts_id: ID of the BTS
    :param du_id: ID of the DU
    """
    ru_bts_id = int(ru_bts_id) if ru_bts_id is not None else int(ru_id)
    logger.log_info_to_console(f"Disabling CB012667 feature on RU{ru_id}, RU BTS ID: {ru_bts_id}")
    frmon_operator = FrmonOperator()
    frmon_operator.turn_off_feature(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
    _reset_ru_and_wait_until_online(bts_id=bts_id, du_id=du_id, ru_id=ru_bts_id)
    logger.log_info_to_console(f"CB012667 feature disabled on RU{ru_id}, RU BTS ID: {ru_bts_id}")


def _reset_ru_and_wait_until_online(bts_id=0, du_id=0, ru_id=0):
    """
    Reset RU and wait until it is online.

    :param ru_id: ID of the RU
    :param bts_id: ID of the BTS
    :param du_id: ID of the DU
    """
    ru_operator = GnbRuOperations()
    cell_operator = GnbCellOperations()
    logger.log_info_to_console("Reset RU and wait until it is online")
    ru_operator.reset_radio_unit(radio_unit_id=ru_id, bts_id=bts_id, du_id=du_id)
    ru_operator.wait_for_radio_unit_to_be_online(ru_id=ru_id, bts_id=bts_id, du_id=du_id)
    cell_operator.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id)


def get_avg_kpi_value_from_json_file(json_file, kpi):
    """
    Get average KPI value from JSON file.

    Reads a JSON file containing KPI results and extracts the average value
    for the specified KPI.

    :param json_file: Path to the JSON file containing KPI results
    :param kpi: Name of the KPI to extract (e.g., "kpi1a", "kpi51a")
    :return: Average value of the specified KPI
    """
    with open(json_file, 'r') as file:
        json_data = file.read()
    data = json.loads(json_data)
    kpi_avg = data[kpi]['avg']
    return kpi_avg
