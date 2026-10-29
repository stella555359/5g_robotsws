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
        '7_7_UTE5GCLOUDT4SK144': {
            'scout_hostname': '7_7_UTE5GCLOUDT4SK144',
            'SBTS00': {'qc_upgrade': 105389, 'qc_site_reset': 105388},
            'SBTS25R2': {'qc_upgrade': 149349, 'qc_site_reset': 149348},
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
