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
    sSec = dt.now().second
    if (
         (str(sMin) == '3' and sSec > 30) or
         str(sMin) == '4' or
         (str(sMin) == '13' and sSec > 30) or
         str(sMin) == '14' or
         (str(sMin) == '23' and sSec > 30) or
         str(sMin) == '24' or
         (str(sMin) == '33' and sSec > 30) or
         str(sMin) == '34' or
         (str(sMin) == '43' and sSec > 30) or
         str(sMin) == '44' or
         (str(sMin) == '53' and sSec > 30) or
         str(sMin) == '54' or
         (str(sMin) == '8' and sSec > 30) or
         str(sMin) == '9' or
         (str(sMin) == '18' and sSec > 30) or
         str(sMin) == '29' or
         (str(sMin) == '28' and sSec > 30) or
         str(sMin) == '39' or
         (str(sMin) == '38' and sSec > 30) or
         str(sMin) == '49' or
         (str(sMin) == '48' and sSec > 30) or
         str(sMin) == '59' or
         (str(sMin) == '58' and sSec > 30)
    ):
        return True, sMin, sSec
    else:
        return False, sMin, sSec
