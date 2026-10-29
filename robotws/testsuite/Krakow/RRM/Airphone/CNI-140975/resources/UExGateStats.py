from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import time


class UExGateStats(object):
    def __init__(self):
        self.ta_uexgate = BuiltIn().get_library_instance('ta_uexgate')

    def wait_till_cell_reaches_tput(self, cell, expected_tput, dir, timeout=300):
        start_time = time.time()
        passed = None
        while start_time + timeout > time.time():
            stats = self.ta_uexgate.get_cell_stats(id=cell, type='{}_rlc'.format(dir), unit='Mbps')
            if stats['DRB']['cur'] >= float(expected_tput):
                passed = True
                break
            else:
                time.sleep(1)
        logger.console(stats)
        if passed is not True:
            raise Exception('Timeout')
