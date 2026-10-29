from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_hostname


ATTENUATORS = {
    "7_16_UTE5GHASTROMUTANT1": {
        "SECTOR_1": {"ports": [1, 2, 3, 4, 9, 10, 11, 12, 17, 18, 19, 20], "attenuation": '0'},
        "SECTOR_2": {"ports": [5, 6, 7, 8, 13, 14, 15, 16, 21, 22, 23, 24], "attenuation": '0'},
        "AHFII_1": {"ports": [1, 2, 3, 4], "attenuation": '0'},
        "AHFII_2": {"ports": [5, 6, 7, 8], "attenuation": '0'},
        "AEHC_1": {"ports": [9, 10, 11, 12], "attenuation": '0'},
        "AEHC_2": {"ports": [13, 14, 15, 16], "attenuation": '0'},
        "AHLOB_1": {"ports": [17, 18, 19, 20], "attenuation": '0'},
        "AHLOB_2": {"ports": [21, 22, 23, 24], "attenuation": '0'}
    },
    "7_16_UTE5GHASTROMUTANT2": {
        "SECTOR_1": {"ports": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "attenuation": '0', "att_id": 1},
        "SECTOR_2": {"ports": [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], "attenuation": '0', "att_id": 1},
        "AHFIG_1": {"ports": [1, 2, 3, 4], "attenuation": '0', "att_id": 1},
        "AEHC_1": {"ports": [5, 6, 7, 8], "attenuation": '0', "att_id": 1},
        "AHLOA_1": {"ports": [9, 10, 11, 12], "attenuation": '0', "att_id": 1},
        "AHFIG_2": {"ports": [13, 14, 15, 16], "attenuation": '0', "att_id": 1},
        "AEHC_2": {"ports": [17, 18, 19, 20], "attenuation": '0', "att_id": 1},
        "AHLOA_2": {"ports": [21, 22, 23, 24], "attenuation": '0', "att_id": 1},
        "AZHL": {"ports": [1, 2, 3, 4], "attenuation": '90', "att_id": 2},
        "AHFII": {"ports": [5, 6, 7, 8], "attenuation": '90', "att_id": 2}
    },
    "7_16_UTE5GHASTROTL23": {
        "NRCELL_2": {"ports": {'S1': [5], 'S2': [6]}, "attenuation": '90', "att_id": 1},
        "NRCELL_3": {"ports": [11, 12], "attenuation": '90', "att_id": 1},
        "NRCELL_15": {"ports": {'S1': [5], 'S2': [6]}, "attenuation": '90', "att_id": 1},
        "NRCELL_16": {"ports": [11, 12], "attenuation": '90', "att_id": 1},
        "NRCELL_1_1": {"ports": [3, 4, 9, 10], "attenuation": '0', "att_id": 1},
        "NRCELL_1_4": {"ports": [5, 6, 11, 12], "attenuation": '90', "att_id": 2},
        "NRCELL_1_5": {"ports": [9, 10], "attenuation": '90', "att_id": 2},
        "LNCELL_1": {"ports": [3, 4], "attenuation": '90', "att_id": 2},
        "NRCELL_2_106": {"ports": [1, 2, 7, 8], "attenuation": '90', "att_id": 1},
        "NRCELL_6": {"ports": {'S1': [1, 2], 'S2': [3, 4], 'S3': [7, 8]}, "attenuation": '90', "att_id": 2},
    },
    "7_16_UTE5GHASTROTL26": {
        "NRCELL_100": {"ports": [1, 2, 3, 4], "attenuation": '0'},
        "NRCELL_101": {"ports": [5, 6, 7, 8], "attenuation": '0'},
        "NRCELL_103": {"ports": [13, 14, 15, 16], "attenuation": '20'},
        "NRCELL_104": {"ports": [13, 14, 15, 16], "attenuation": '20'},
        "NRCELL_105": {"ports": [9, 10, 11, 12], "attenuation": '10'},
        "NRCELL_106": {"ports": [21, 22, 23, 24], "attenuation": '5'},
    },
    "7_16_UTE5GHASTROTL74": {
        'NRCELL_57': {'ports': [9, 10, 11, 12], 'attenuation': '0'},
        'NRCELL_58': {'ports': [21, 22, 23, 24], 'attenuation': '0'},
        'NRCELL_67': {'ports': [1, 2, 3, 4], 'attenuation': '0'},
        'NRCELL_68': {'ports': [5, 6, 7, 8], 'attenuation': '0'}
    },
    "7_16_UTE5GHASTROTL76": {
        "NRCELL_1": {"ports": [11, 12], "attenuation": '0'},
        "NRCELL_2": {"ports": [7, 8], "attenuation": '0'},
        "NRCELL_3": {"ports": [9, 10], "attenuation": '0'},
        "NRCELL_5": {"ports": [1, 2, 3, 4], "attenuation": '0'},
        "NRCELL_6": {"ports": [5, 6], "attenuation": '0'},
        "NRCELL_7": {"ports": [5, 6], "attenuation": '0'}
    },
    "7_16_UTE5GHASTROTL77": {
        "NRCELL_100": {"ports": [1, 2, 3, 4], "attenuation": '90', "att_id": 1},
        "NRCELL_200": {"ports": [5, 6, 7, 8], "attenuation": '90', "att_id": 1},
        "NRCELL_300": {"ports": [17, 18, 19, 20], "attenuation": '90', "att_id": 1},
        "NRCELL_400": {"ports": [21, 22, 23, 24], "attenuation": '90', "att_id": 1},
        "NRCELL_500": {"ports": [9, 10, 11, 12], "attenuation": '90', "att_id": 1},
        "NRCELL_600": {"ports": [13, 14, 15, 16], "attenuation": '90', "att_id": 1},
        "NRCELL_58": {"ports": [1, 2, 3, 4], "attenuation": '90', "att_id": 2},
        "NRCELL_67": {"ports": [5, 6, 7, 8], "attenuation": '90', "att_id": 2}
    },
    "7_16_UTE5GHASTROAIC01": {
        "NRCELL_8": {"ports": [5, 6, 7, 8], "attenuation": '0'},
        "NRCELL_10": {"ports": [1, 2, 3, 4], "attenuation": '0'},
        "NRCELL_11": {"ports": [3, 4], "attenuation": '0'},
        "NRCELL_20": {"ports": [5, 6], "attenuation": '0'},
        "NRCELL_21": {"ports": [5, 6], "attenuation": '0'},
        "NRCELL_22": {"ports": [7, 8], "attenuation": '0'},
        "NRCELL_30": {"ports": [13, 14, 15, 16], "attenuation": '127'},
        "NRCELL_31": {"ports": [13, 14, 15, 16], "attenuation": '127'},
        "NRCELL_40": {"ports": [17, 18, 19, 20], "attenuation": '127'},
        "NRCELL_41": {"ports": [17, 18, 19, 20], "attenuation": '127'},
    },
    "7_16_UTE5GHASTROAIC02": {
        "NRCELL_8": {"ports": [1, 2, 3, 4], "attenuation": '10'},
        "NRCELL_10": {"ports": [5, 6, 7, 8], "attenuation": '15'},
        "NRCELL_11": {"ports": [7, 8], "attenuation": '20'},
        "NRCELL_20": {"ports": [1, 3], "attenuation": '0'},
        "NRCELL_21": {"ports": [1, 3], "attenuation": '0'},
        "NRCELL_22": {"ports": [2, 4], "attenuation": '0'},
        "NRCELL_30": {"ports": [9, 10, 11, 12], "attenuation": '127'},
        "NRCELL_31": {"ports": [9, 10, 11, 12], "attenuation": '127'},
        "NRCELL_40": {"ports": [13, 14, 15, 16], "attenuation": '127'},
        "NRCELL_41": {"ports": [13, 14, 15, 16], "attenuation": '127'},
    }

}


def extract_cell_id(name):
    if '_1_' in name:
        return int(name.split('_1_')[1])
    else:
        return int(name.split('_')[1])


def is_local_cell(name):
    return '_1_' in name or name.count('_') == 1


def is_nr_cell(name):
    return 'NRCELL' in name


ATTENUATOR = {}
try:
    ATTENUATOR = ATTENUATORS[get_hostname()]
except KeyError:
    logger.info("Hostname {} does not exist in ATTENUATORS dictionary!".format(get_hostname()))
    ATTENUATOR = {
        "NRCELL_1": {"ports": [], "attenuation": ''},
        "NRCELL_2": {"ports": [], "attenuation": ''},
        "NRCELL_3": {"ports": [], "attenuation": ''}
    }


def get_attenuator_nr_cells():
    return [extract_cell_id(key) for key in ATTENUATOR.keys() if is_local_cell(key) and is_nr_cell(key)]
