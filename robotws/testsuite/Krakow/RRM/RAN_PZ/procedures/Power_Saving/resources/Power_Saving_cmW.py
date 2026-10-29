"""
Specific keywords for feature 5GC0002481-ABCV

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

import logging
import time
import re
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.utilities.tl_config import get_global_bts_id, get_bts_instance_id


gnb_counter = GnbPmCounter()
gnb_bbu = GnbBbu()
gnb_cell = GnbCell()


def lock_or_block_cell(bts_id=0, cell_id=1, du_id=0):
    """
    Lock or block cell, depending on release
    :param bts_id:  ID of gNB/eNB, default 0
    :param cell_id: id of the cell to be locked/blocked
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :return: None
     """
    sw_version = gnb_bbu.get_bts_sw_version()
    if sw_version.startswith('21A'):
        gnb_cell.lock_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
    else:
        gnb_cell.block_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)


def unlock_or_unblock_cell(bts_id=0, cell_id=1, du_id=0):
    """
    Unlock or unblock cell, depending on release
    :param bts_id:  ID of gNB/eNB, default 0
    :param cell_id: id of the cell to be unlocked/unblocked
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :return: None
    """
    sw_version = gnb_bbu.get_bts_sw_version()
    if sw_version.startswith('21A'):
        gnb_cell.unlock_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
    else:
        gnb_cell.unblock_cell(bts_id=bts_id, cell_id=cell_id, du_id=du_id)


def wait_for_measurement(interval, measurements):
    """
    Wait for several intervals PM counters
    :param interval: Interval for PM counters
    :param measurements: Numbers of intervals, to wait one more intervals then specified
    :return: None
    """
    result = re.search(r'^(?P<INTERVAL>\d+)', str(interval))
    interval_minutes_value = int(result.group('INTERVAL'))
    interval_seconds_value = interval_minutes_value * 60
    for measurement in range(int(measurements)):
        logging.debug('Waiting for PM interval of {} min to pass'.format(interval_minutes_value))
        time.sleep(interval_seconds_value)
    time.sleep(60)
    logging.debug('Waiting for refreshing the measurements')


def verify_pm_counter(counter_id, target, cell_id):
    """
    Verify if given pm counter has desired value for the right cell
    :param cell_id:    cell_id
    :param counter_id:  ID of the PM counter
    :param target:  desired value of a PM counter
    :return:    None
    """
    counter = gnb_counter.get_counter(counter_id)
    timestamp = counter["BTS"]["CELLS"]["NRCELL-{}".format(cell_id)]['NCAV'][counter_id].keys()
    max_timestamp = max(timestamp, key=int)
    timestamp.remove(max_timestamp)
    second_to_last_timestamp = max(timestamp, key=int)
    logging.info('Counter value: {}'.format(counter.values()))
    second_counter = counter["BTS"]["CELLS"]["NRCELL-{}".format(cell_id)]['NCAV'][counter_id][second_to_last_timestamp]
    counter = counter["BTS"]["CELLS"]["NRCELL-{}".format(cell_id)]['NCAV'][counter_id][max_timestamp]
    counter = int(counter)
    second_counter = int(second_counter)
    if counter == int(target) or second_counter == int(target):
        logging.info("Counter value correct")
    else:
        raise Exception('Bad value counter {}, expected: {}, value: {}'.format(
            counter_id, target, counter))
