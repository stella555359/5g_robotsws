import time
import json
from robot.api import logger
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as GnbRu
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import get_mrbts_id
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


def get_ru_ids(radio_type: str) -> list:
    """
    Get id of all RUs for specified type
    :param radio_type: defined radio type "rmod", "asirmod" or "all"
    :return: list of radio ids
    """
    all_ru_ids = GnbRu()._get_all_radio_ids()[radio_type.lower()]
    return all_ru_ids


def reset_radio_unit(radio_unit_id: str, timeout=600):
    """Reset desired radio unit.

    :param str radio_unit_id:
    """
    GnbRu().reset_radio_unit(radio_unit_id=radio_unit_id, timeout=timeout)


def wait_for_synchronization(duration: int):
    """
    Wait for system synchronization.

    :param duration: time to sleep
    """
    time.sleep(duration)


def get_site_reset_delta():
    """
    Create delta which parameter changing cause site reset
    :return: json
    """
    mrbts_id = get_mrbts_id()
    distname = f"MRBTS-{mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1"
    RESET_SITE_DELTA = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "holdOverModeUsed",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]
    return json.dumps(RESET_SITE_DELTA)


def get_online_parameters_delta(cell_id: str):
    """
    :param cell_id: cell id to set parameter for
    Create delta which parameter changing does not cause site reset
    :return:
    """
    mrbts_id = get_mrbts_id()
    distname = f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-{cell_id}"
    ONLINE_PARAMETERS = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actProactUlScheduling",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]
    return json.dumps(ONLINE_PARAMETERS)


def get_bts_data():
    return {
        'SBTS00': {'qc_upgrade': 41494},
        'SBTS24R3': {'qc_upgrade': 865182},
    }


def get_qc_ids(bts_build):
    try:
        release = SbtsSwVersion(bts_build).release
        date = get_bts_data()
        return date.get(release, {}).get("qc_upgrade", None)
    except Exception as e:
        logger.debug(f"Failed to retrieve BTS date: {e}")
        raise
