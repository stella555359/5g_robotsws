import socket
from robot.api import logger


def get_hostname():
    hostname = socket.gethostname()
    hostname = hostname.replace('-', '_')
    return hostname


ATTENUATORS = {
    "test_2": [
        {
            "dist_name": 'MRBTS-1910/NRBTS-10957/NRCELL-1',
            "ports": [7, 8],
            "id": 208
        },
        {
            "dist_name": 'MRBTS-1910/NRBTS-10957/NRCELL-2',
            "ports": [1, 2],
            "id": 179519490
        },

    ],
}

ATTENUATOR_CELLS = []

host = get_hostname()
try:
    ATTENUATOR_CELLS = ATTENUATORS[host]
except KeyError:
    logger.warn("Your hostname {} does not exist in ATTENUATORS dictionary!", host)
