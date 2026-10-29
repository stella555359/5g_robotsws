"""

Set of KW convert files to other formats

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
"""

import os
import re
import time
from moler.device import DeviceFactory
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python.bts.common.log import GnbLog
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python import utilities


def start_collecting_logs_during_attach():
    """
    Start collecting logs before attach
    """
    # GnbLog().start_collecting_tti_trace()
    GnbLog().start_bip_trace_log_capturing(timeout=40)


def stop_collecting_logs_after_attach():
    """
    Stop collecting logs after attach finished.
    """
    # GnbLog().stop_collecting_tti_trace()
    GnbLog().stop_bip_trace_log_capturing()


def download_logs_from_gnb(sub_dir='data_transfer', clear_source_dir=True):
    """
    Download logs from gNB to ${LOG_PATH} directory on local VM.
    :param sub_dir:
    :param clear_source_dir: clear source dir if exists
    """
    log_path = utilities.set_test_case_log_path()
    download_dir = os.path.join(log_path, sub_dir)
    if clear_source_dir and os.path.exists(download_dir):
        unix = DeviceFactory.get_device('UnixLocal')
        rm = unix.get_cmd(cmd_name="rm",
                          cmd_params={
                              "file":
                                  os.path.join(re.escape(download_dir), '*'),
                              "options": '-rf'})
        rm()
    GnbLog().download_bip_logs(download_dir=download_dir)
    # GnbLog().convert_tti_traces_to_csv()
    # GnbLog().download_tti_trace_csv_logs(download_dir=download_dir)


def collect_logs_during_data_transfer(direction='DL'):
    """
    Collect logs during data transfer.
    :param direction: DL or UL
    """
    _start_collecting_logs_during_data_transfer(direction=direction)
    time.sleep(4)
    _stop_collecting_logs_during_data_transfer()


def _start_collecting_logs_during_data_transfer(direction):
    mirroring_script_params = {}
    # GnbLog().start_collecting_tti_trace()
    GnbLog().start_bip_trace_log_capturing(
        mirroring_script_params=mirroring_script_params)


def _stop_collecting_logs_during_data_transfer():
    # GnbLog().stop_collecting_tti_trace()
    GnbLog().stop_bip_trace_log_capturing()


class BipFilterGenerator(object):
    bip_filters = {
        'PuschReceiveReq': {'value': r'ether[0x18:2]==0x249',
                            'direction': 'UL'},
        'PuschReceiveRespLo': {'value': r'ether[0x18:2]==0x23a',
                               'direction': 'UL'},
        'PdschSendReq': {'value': r'ether[0x18:2]==0x130', 'direction': 'DL'},
        'PdschPayloadTbSendReq': {'value': r'ether[0x18:2]==0x108',
                                  'direction': 'DL'},
        'PucchReceiveReq': {'value': r'ether[0x18:2]==0x24c',
                            'direction': 'DL'},
        'PucchReceiveRespHarqD': {'value': r'ether[0x18:2]==0x24d',
                                  'direction': 'DL'},
        'PdcchSendReq': {'value': r'ether[0x18:2]==0x133',
                         'direction': 'BOTH'},
    }

    @staticmethod
    def get_filters(direction):
        filters = []
        if direction == 'BOTH':
            filters = [record['value'] for record in
                       BipFilterGenerator.bip_filters.values()]
        else:
            for record in BipFilterGenerator.bip_filters.values():
                if record['direction'] in ['BOTH', direction]:
                    filters.append(record['value'])

        return " || ".join(filters)
