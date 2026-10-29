from robot.api import logger


ATTENUATORS = {
    "tl1928": [
        {
            "dist_name": 'MRBTS-1928/NRBTS-37403/NRCELL-1',
            "ports": [11, 12],
            "id": 52
        },
        {
            "dist_name": 'MRBTS-1928/NRBTS-37403/NRCELL-2',
            "ports": [1, 2],
            "id": 53
        },

    ],
}

ATTENUATOR_CELLS = []

try:
    ATTENUATOR_CELLS = ATTENUATORS["tl1928"]
except KeyError:
    logger.warn("TL does not exist in ATTENUATORS dictionary!")
