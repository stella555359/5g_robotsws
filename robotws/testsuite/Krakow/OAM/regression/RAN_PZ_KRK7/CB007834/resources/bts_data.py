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
        '7_7_TSPY039_1': {
            'scout_hostname': '7_7_TSPY039',
            'scout_hostname_lte': '7_7_TSPY039_040',
            'SBTS00': {'qc_upgrade': 231213, 'qc_upgrade_lte': 231214,
                       'qc_activation_reset': 231194, 'qc_activation_reset_lte': 231193,
                       'qc_site_reset': 231195,  'qc_site_reset_lte': 231189},
            'SBTS26R2': {'qc_upgrade': 298603, 'qc_upgrade_lte': 298617,
                         'qc_activation_reset': 298616, 'qc_activation_reset_lte': 298618,
                         'qc_site_reset': 298614,  'qc_site_reset_lte': 298626},
            'SBTS26R1': {'qc_upgrade': 254596, 'qc_upgrade_lte': 254606,
                         'qc_activation_reset': 254604, 'qc_activation_reset_lte': 254595,
                         'qc_site_reset': 254603,  'qc_site_reset_lte': 254614},
            'SBTS25R3': {'qc_upgrade': 207955, 'qc_upgrade_lte': 207963,
                         'qc_site_reset': 220581,  'qc_site_reset_lte': 230220},
        },
        '7_7_TSPY039_2': {
            'scout_hostname': '7_7_TSPY039_040',
            'SBTS00': {'qc_upgrade': 231214, 'qc_activation_reset_lte': 231193, 'qc_site_reset_lte': 231189},
            'SBTS26R2': {'qc_upgrade': 298617, 'qc_activation_reset': 298618, 'qc_site_reset': 298626},
            'SBTS26R1': {'qc_upgrade': 254606, 'qc_activation_reset': 254595, 'qc_site_reset': 254614},
        },
        '7_7_T01SK105_1': {
            'scout_hostname': '7_7_T01SK105',
            'scout_hostname_lte': 'T01SK105_104',
            'SBTS00': {'qc_upgrade': 231213, 'qc_upgrade_lte': 231214,
                       'qc_activation_reset': 231194, 'qc_activation_reset_lte': 231193,
                       'qc_site_reset': 231195,  'qc_site_reset_lte': 231189},
            'SBTS26R2': {'qc_upgrade': 298603, 'qc_upgrade_lte': 298617,
                         'qc_activation_reset': 298616, 'qc_activation_reset_lte': 298618,
                         'qc_site_reset': 298614,  'qc_site_reset_lte': 298626},
            'SBTS26R1': {'qc_upgrade': 254596, 'qc_upgrade_lte': 254606,
                         'qc_activation_reset': 254604, 'qc_activation_reset_lte': 254595,
                         'qc_site_reset': 254603,  'qc_site_reset_lte': 254614},
            'SBTS25R3': {'qc_upgrade': 207955, 'qc_upgrade_lte': 207963,
                         'qc_site_reset': 220581,  'qc_site_reset_lte': 230220},
        },
        '7_7_T01SK105_2': {
            'scout_hostname': 'T01SK105_104',
            'SBTS00': {'qc_upgrade': 231214, 'qc_activation_reset': 231193, 'qc_site_reset': 231189},
            'SBTS26R2': {'qc_upgrade': 298617, 'qc_activation_reset': 298618, 'qc_site_reset': 298626},
            'SBTS26R1': {'qc_upgrade': 254606, 'qc_activation_reset': 254595, 'qc_site_reset': 254614},
        },
        '7_7_T01SK106_1': {
            'scout_hostname': '7_7_T01SK106',
            'scout_hostname_lte': 'T01SK106_111',
            'SBTS00': {'qc_upgrade': 231213, 'qc_upgrade_lte': 231214,
                       'qc_activation_reset': 231194, 'qc_activation_reset_lte': 231193,
                       'qc_site_reset': 231195,  'qc_site_reset_lte': 231189},
            'SBTS26R2': {'qc_upgrade': 298603, 'qc_upgrade_lte': 298617,
                         'qc_activation_reset': 298616, 'qc_activation_reset_lte': 298618,
                         'qc_site_reset': 298614,  'qc_site_reset_lte': 298626},
            'SBTS26R1': {'qc_upgrade': 254596, 'qc_upgrade_lte': 254606,
                         'qc_activation_reset': 254604, 'qc_activation_reset_lte': 254595,
                         'qc_site_reset': 254603,  'qc_site_reset_lte': 254614},
            'SBTS25R3': {'qc_upgrade': 207955, 'qc_upgrade_lte': 207963,
                         'qc_site_reset': 220581,  'qc_site_reset_lte': 230220},
        },
        '7_7_T01SK106_2': {
            'scout_hostname': 'T01SK106_111',
            'SBTS00': {'qc_upgrade': 231214, 'qc_activation_reset': 231193, 'qc_site_reset': 231189},
            'SBTS26R2': {'qc_upgrade': 298617, 'qc_activation_reset': 298618, 'qc_site_reset': 298626},
            'SBTS26R1': {'qc_upgrade': 254606, 'qc_activation_reset': 254595, 'qc_site_reset': 254614},
        },
        '7_7_UTE5GCLOUDT1SK114': {
            'scout_hostname': '7_7_UTE5GCLOUDT1SK114',
            'SBTS00': {'qc_upgrade': 231213, 'qc_activation_reset': 231194, 'qc_site_reset': 231195},
            'SBTS26R2': {'qc_upgrade': 298603, 'qc_activation_reset': 298616, 'qc_site_reset': 298614},
            'SBTS26R1': {'qc_upgrade': 254596, 'qc_activation_reset': 254604, 'qc_site_reset': 254603},
        },
        '7_7_UTE5GCLOUDT1SK113': {
            'scout_hostname': '7_7_UTE5GCLOUDT1SK114_113',
            'SBTS00': {'qc_upgrade': 231214, 'qc_activation_reset': 231193, 'qc_site_reset': 231189},
            'SBTS26R2': {'qc_upgrade': 298617, 'qc_activation_reset': 298618, 'qc_site_reset': 298626},
            'SBTS26R1': {'qc_upgrade': 254606, 'qc_activation_reset': 254595, 'qc_site_reset': 254614},
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


def get_scout_bts_name_lte():
    try:
        scout_data = get_bts_data()
        return scout_data['scout_hostname_lte']
    except Exception as e:
        logger.debug("Failed to retrieve LTE scout BTS name.")
        raise


def get_qc_ids(bts_build):
    try:
        release = SbtsSwVersion(bts_build).release
        scout_data = get_bts_data()
        return scout_data[release]
    except Exception as e:
        logger.debug("Failed to retrieve QC IDs.")
        raise
