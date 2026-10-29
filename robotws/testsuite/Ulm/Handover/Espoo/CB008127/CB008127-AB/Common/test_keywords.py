import os
import signal
from datetime import datetime as dt


def kill_tshark_process(process):
    """
    Kills process
    :return:
    """
    os.killpg(os.getpgid(process.pid), signal.SIGTERM)


def need_to_wait_for_counter_interval():
    sMin = dt.now().minute
    if (
         str(sMin) == '4' or
         str(sMin) == '14' or
         str(sMin) == '24' or
         str(sMin) == '34' or
         str(sMin) == '44' or
         str(sMin) == '54' or
         str(sMin) == '9' or
         str(sMin) == '19' or
         str(sMin) == '29' or
         str(sMin) == '39' or
         str(sMin) == '49' or
         str(sMin) == '59'
    ):
        return True, sMin
    else:
        return False, sMin
