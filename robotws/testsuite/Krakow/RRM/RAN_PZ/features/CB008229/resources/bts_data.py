import re
import subprocess
from robot.api import logger
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


def get_hostname():
    try:
        full_hostname = subprocess.getoutput("hostname")
        match = re.search(r"\d+\-\d+\-.*\d+", full_hostname)
        if match:
            hostname = match[0].replace("-", "_").rstrip()
            logger.debug(f"Host name: {hostname}")
            return hostname
        else:
            logger.error("Hostname does not match expected pattern.")
            raise ValueError("Invalid hostname format.")
    except Exception as e:
        logger.debug("Failed to retrieve hostname.")
        raise


def get_bts_data():
    testline_name = get_hostname()
    test_data = {
        '7_7_T01PY077': {
            'scout_hostname': '7_7_T01PY077',
            'SBTS00': {'qc_upgrade': 242544, 'qc_upgrade_l3_call': 277509, 'qc_site_reset': 242550,
                       'qc_lock_unlock': 242545, 'qc_delta_com_site_reset': 242549, 'qc_ru_power_reset': 277508,
                       'qc_delta_com_online': 242548, 'qc_delta_com_RAT_reset': 242547, 'qc_RU_reset': 242546},
            'SBTS25R2': {'qc_upgrade': 186793, 'qc_upgrade_l3_call': 12345, 'qc_site_reset': 229022,
                         'qc_lock_unlock': 186792, 'qc_delta_com_site_reset': 186789, 'qc_ru_power_reset': 12346,
                         'qc_delta_com_online': 186788, 'qc_delta_com_RAT_reset': 186787, 'qc_RU_reset': 186791},
            'SBTS26R1': {'qc_upgrade': 313180, 'qc_upgrade_l3_call': 313179, 'qc_site_reset': 313181,
                         'qc_lock_unlock': 313186, 'qc_delta_com_site_reset': 313183, 'qc_ru_power_reset': 313178,
                         'qc_delta_com_online': 313185, 'qc_delta_com_RAT_reset': 313184, 'qc_RU_reset': 313182},
        }
    }

    return test_data[testline_name]


def get_scout_bts_name():
    try:
        scout_data = get_bts_data()
        return scout_data['scout_hostname']
    except Exception as e:
        logger.debug("Failed to retrieve scout BTS name.")
        raise


def get_qc_ids(bts_build):
    try:
        release = SbtsSwVersion(bts_build).release
        scout_data = get_bts_data()
        return scout_data[release]
    except Exception as e:
        logger.debug("Failed to retrieve scout BTS name.")
        raise


def get_release(bts_build):
    try:
        release = SbtsSwVersion(bts_build).release
        return release
    except Exception as e:
        logger.debug("Failed to retrieve release.")
        raise
