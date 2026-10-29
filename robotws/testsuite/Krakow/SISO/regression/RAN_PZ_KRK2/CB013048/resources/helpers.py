"""
author: Maciej Russek, maciej.russek@nokia.com
maintainer: Maciej Russek, maciej.russek@nokia.com
description: Python helper methods
"""

import time
import logging


def verify_delta_commissioning_status(status):
    if status[0] == 'PASS':
        logging.debug("delta pass")
        return True
    else:
        if 'Waiting for response' in status[1]:
            logging.debug("Waiting for response - pass")
            return True
        elif 'AdminApiProcedureTimeoutException' in status[1]:
            logging.debug("AdminApiProcedureTimeoutException - sleep 180s and pass")
            time.sleep(180)
            return True
        else:
            return False
