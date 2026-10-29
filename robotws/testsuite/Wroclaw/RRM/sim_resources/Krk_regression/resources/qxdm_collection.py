"""

Set of PROPSIM Keywords used for setting IN/OUT ports and reading current values.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import time
import logging
from taf.rfrl.utilities.robot.general import set_robot_test_variable, get_builtin_instance, get_builtin_value


def start_collecting_qxdm_logs(duration=6, python_path=None):
    qlc = get_builtin_instance('QxdmLogsCollector')
    qlc.kill_qxdm_process()
    qlc.clear_log_directory()
    qlc.collect_qxdm_hdf_log(duration=duration, python_path=python_path)


def convert_qxdm_log_to_txt():
    qlc = get_builtin_instance('QxdmLogsCollector')
    qlc.convert_hdf_log_to_txt()


def download_qxdm_logs(log_dir=None):
    qlc = get_builtin_instance('QxdmLogsCollector')
    qlc.download_qxdm_logs(download_dir=log_dir)


def extend_qxdm_and_qcat_license(interval=20 * 60, max_tries=3):
    lr_timestamp = get_builtin_value('licence_reservation_timestamp', None)
    if lr_timestamp:
        reservation_duration = int(time.time() - lr_timestamp)
        if reservation_duration < interval:
            logging.debug("License reservation timestamp is {}".format(lr_timestamp))
            logging.debug("License will be extended for {} seconds".format(interval - reservation_duration))
            logging.info("Skipping reservation")
            return

    qlc = get_builtin_instance('QxdmLogsCollector')
    qlc.kill_qxdm_process()
    qlc.kill_qcat_process()
    qlc.kill_quts_process()

    attempt = 0
    while attempt <= max_tries:
        attempt = attempt + 1
        try:
            lkk = get_builtin_instance('LicenseKeeperKeywords')
            lkk.connect_to_license_keeper_client(login=get_builtin_value('lkc_login'),
                                                 password=get_builtin_value('lkc_password'),
                                                 lkc_path=get_builtin_value('lkc_path'))
            lkk.get_qxdm_and_qcat_licence()
            logging.info("Successfully got licence")
            set_robot_test_variable('licence_reservation_timestamp', time.time())
            break
        except Exception as e:
            msg = "Cannot get QXDM licence: {}".format(repr(e))
            logging.warning(msg)
