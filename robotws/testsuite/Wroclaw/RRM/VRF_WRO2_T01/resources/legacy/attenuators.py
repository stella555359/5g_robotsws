from robot.api import logger
import socket


ATTENUATORS = {
    "7_16_UTE5GSA5": {
        "NRCELL_10": {"ports": [13, 14, 15, 16], "attenuation": '90', "att_id": 1},
        "NRCELL_20": {"ports": [5, 6, 7, 8], "attenuation": '90', "att_id": 1},
        "NRCELL_30": {"ports": [9, 10, 11, 12], "attenuation": '90', "att_id": 1},
        "NRCELL_40": {"ports": [1, 2, 3, 4], "attenuation": '90', "att_id": 1},
        "NRCELL_50": {"ports": [13, 14, 15, 16], "attenuation": '90', "att_id": 2},
        "NRCELL_60": {"ports": [17, 18, 19, 20], "attenuation": '90', "att_id": 2},
        "NRCELL_71": {"ports": [1, 2, 3, 4], "attenuation": '90', "att_id": 2},
        "NRCELL_81": {"ports": [5, 6, 7, 8], "attenuation": '90', "att_id": 2},
        "NRCELL_91": {"ports": [9, 10, 11, 12], "attenuation": '90', "att_id": 2}
    }
}


def get_hostname():
    hostname = socket.gethostname()
    hostname = hostname.replace('-', '_')
    return hostname


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
