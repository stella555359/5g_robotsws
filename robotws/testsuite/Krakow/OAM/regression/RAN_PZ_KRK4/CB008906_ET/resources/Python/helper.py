# -*- coding: utf-8 -*-
"""
Generic function or parameters for other modules.

:copyright: Nokia Networks
:author: SHI Kun
:contact: I_NJ_SC_SYSTEM_VERF_GMS
:maintainer: I_NJ_SC_SYSTEM_VERF@internal.nsn.com
"""
import datetime
import gzip
import lzma
import os
import re
import shutil
import sys
import logging
import logging.config
import tarfile
import zipfile

from moler.connection_observer import ConnectionObserver
from moler.util.moler_test import MolerTest
import moler.config as moler_config
from pathlib import Path
from selenium.webdriver.remote.remote_connection import LOGGER
from selenium.webdriver.firefox.extension_connection import LOGGER as firefox_logger
from easyprocess import log as easyprocess_logger
from urllib3.connectionpool import log as urllib3_logger

# CONST
TDD = 'tdd'
FDD = 'fdd'
MASTER = 'master'
SLAVE = 'slave'
OPER_SSH = 'SSH'
OPER_PAM = 'PAM'
IF_TYPE_WEBEM = 'WebEM'
SSH_LOGIN = 'SSH Login'
SSH_LOGOUT = 'SSH Logout'
SUCCESS = 'Success'
ADDIT_TEXT_PREFIX = 'Node-Type=sHUB Node-ID=101D SSH-Sessions={}'
FAILED = 'Failed'
START = 'start'
STOP = 'stop'
ALL = 'All'
GNB = 'GNB'
ENB = 'ENB'
APHA = 'apha'
APHG = 'aphg'
NR = 'nr'
RAT_5G = '5g'
RAT_4G = '4g'
LTE = 'lte'
ONAIR = 'OnAir'
ALL_ENABLED = 'ALL_ENABLED'
ALL_FAILED = 'ALL_FAILED'
NO_CELLS = 'NO_CELLS'
ENABLED = 'enabled'
BTS = 'BTS'
NRBTS = 'NRBTS'
LNBTS = 'LNBTS'
SHUB_DES_DIST = {
    NR: NRBTS,  # which will distinguish the sHUB used for NR. Like "NRBTS-215" in the sHUB description
    LTE: LNBTS  # which will distinguish the sHUB used for LNBTS. Like "LNBTS-100215" in the sHUB description
}
BTS_TYPES = {
    NR: NRBTS,
    LTE: LNBTS
}
CELL_TYPES = {
    NR: 'NRCELL',
    LTE: 'LNCEL'
}

CPRI_ADDRESS = {
    APHG: (
        '0xa1110024',
        '0xa1111024',
        '0xa1112024',
        '0xa1113024',
    ),
    APHA: (
        '0xa010c024',
        '0xa010d024',
        '0xa010e024',
        '0xa010f024',
    )
}

BAND_CLASS = {
    'AWHHIQB': {
        78: 'ARHQF',
        4: 'ARIC',
        66: 'ARIC',
        7: 'ARHC'
    },
    'AHENB': {
        3: 'AREC',
        40: 'ARNB'
    },
    'AHGEA': {
        1: 'ARGA',
        3: 'AREB'
    }
}

PORTS_OF_SHUB = {
    APHG: 12,
    APHA: 12
}

# login
SHUB_LOGIN_USER = 'toor4nsn'
SHUB_LOGIN_PASSWORD = 'oZPS0POrRieRtu'

# SOAP message
SOAP_BEGIN = '<SOAP-ENV:Envelope'
SOAP_END = '</SOAP-ENV:Envelope>'
SKIP_LOW_LAYER_SIZE = 40
MRI = 'moduleReadyInd'
MRA = 'moduleReadyAck'

# used in XPATH to search object
# Tab
TAB_HARDWARE = 'Hardware'
TAB_CELLS = 'Cells'
# - operation
RESET = 'reset'
BLOCK = 'block'
UNBLOCK = 'unblock'
WRONG_PASSWORD = 'wrong_password'
NORMAL_LOGIN = 'normal_login'
NORMAL_LOGOUT = 'normal_logout'
TWO_INSTANCES = 'two_instances'
ACCOUNT_DISABLED = 'account_disabled'
# - state name
STATE_NAME_OPER = 'Operational State'
STATE_ENABLE = 'enabled'
STATE_DISABLE = 'disabled'
STATE_NAME_HW = 'Hardware State'
STATE_RESETTING = 'resetting'
STATE_WORKING = 'working'

# cell
CELL_GREEN = 'Green'
CELL_YELLOW = 'Yellow'
CELL_RED = 'Red'

# - object
GROUP_SHUB = 'sHUBs'
GROUP_PRRH = 'pRRHs'
HUB_MOD = 'HUBMOD'
ANT_MOD = 'ANTMOD'
UNIT_MAPPING = {
    GROUP_SHUB: HUB_MOD,
    GROUP_PRRH: ANT_MOD
}

TRANS_TEXT = "translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"
XPATH_TPL_STATE_VALUE = "//div[@id='topologyDetailsContainer']//span[{}".format(TRANS_TEXT)
XPATH_TPL_STATE_VALUE += "='{}' and contains(@class,'detail-title')]//..//span[contains(@class,'detail-text')]"
XPATH_TL_GROUP_HEADER = "//div[@class='topology-view-columns-container']//div[contains(@class,'group-header')]//" \
                        "span[text()='{}']"
XPATH_DIV_EMPTY_PANEL = "//div[@id='topologyDetailsContainer']//div[contains(@class,'empty-panel')]"

CELL_MO_PATTERN = 'MRBTS-{mrbts_id}/{bts_type}-{target_bts_id}/{cell_type}-{cell_id}'

# file in snapshot
ASICTRL = 'asictrl'
RMOD = 'rmod'
RFSW_LINUX = 'rfsw_linux'
ZIP_FILE_IN_SNAPSHOT = '*.zip'
SOAP_XML_GZ_PATTERN = '*.xml.gz'
RMOD_SNAPSHOT_PATTERN = '*_UnitOAM_SOAP_Log.zip'
ASICTRL_ALL_SOAP_PATTERN = '*_AsiCtrl_all.soap.xz'
RFSW_LINUX_PATTERN = '*_linux_logs.tar'
FILE_PATTERNS = {
    ASICTRL: ASICTRL_ALL_SOAP_PATTERN,
    RMOD: RMOD_SNAPSHOT_PATTERN,
    RFSW_LINUX: RFSW_LINUX_PATTERN
}
RMOD_SNAPSHOT_KEYWORD = '_UnitOAM_SOAP_Log.zip'
ASICTRL_ALL_SOAP_KEYWORD = '_AsiCtrl_all.soap.xz'
RFSW_LINUX_LOG_KEYWORD = '_linux_logs.tar'
FILE_KEYWORDS = {
    ASICTRL: ASICTRL_ALL_SOAP_KEYWORD,
    RMOD: RMOD_SNAPSHOT_KEYWORD,
    RFSW_LINUX: RFSW_LINUX_LOG_KEYWORD,
}
ATL_XMLNS = r'{http://www.nokia.com}'
ATL_TAG_LOG = r'{}log'.format(ATL_XMLNS)

# Some tips for prevalidation fail
PREVALIDATE_FAIL_CAUSE = """
  - 'actAsiDistMimo' in COAM SCF should be 'false' for LTE Cell.
"""


def log1(msg):
    log4case(msg, 1)


def log2(msg):
    log4case(msg, 2)


def log3(msg):
    log4case(msg, 3)


def log4case(msg, log_hierarchy):
    msg_with_head = "{}".format(msg)
    MolerTest.info(msg_with_head)
    test_log(msg_with_head, log_hierarchy)


def test_log(msg, log_hierarchy=1, msg_prefix='>'):
    """
    Print formatted logs on the console so that user can know test progress clearly.

    :param msg: str, to be output on the console with timestamp
    :param log_hierarchy: int, to determine how to display log, e.g,
            ...
            [ 2019-09-03 20:12:34 ] > some message
            [ 2019-09-03 20:12:35 ] >> other message
            ...
    :param msg_prefix: str, work as indicator of log hierarchy. Default is '>'.
    :return: None
    """
    msg_time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    sys.__stdout__.write('[{}] {} {}\n'.format(msg_time, msg_prefix * int(log_hierarchy), msg))
    sys.__stdout__.flush()


def change_log_settings(test_log_path, log_level=logging.ERROR):
    # set test log path for Moler log
    # Moler log path will read os.environ['LOG_DIR']
    # EMSSim log path will read os.environ['EMSSIM_LOG_DIR']
    if test_log_path:
        moler_log_path = os.path.join(test_log_path, 'moler')
        moler_config.reconfigure_logging_path(logging_path=moler_log_path)
    else:
        moler_log_path = os.environ['LOG_DIR']

    # clean default log path of emssim
    emssim_default_log_path = Path('/var/log/emssim')
    for item in emssim_default_log_path.iterdir():
        if item.is_file():
            os.remove(emssim_default_log_path / item)
        else:
            shutil.rmtree(emssim_default_log_path / item)

    MolerTest.info('New moler log path: {}'.format(moler_log_path))

    # change log level to ignore redundant trace
    LOGGER.setLevel(log_level)
    firefox_logger.setLevel(log_level)
    easyprocess_logger.setLevel(log_level)
    urllib3_logger.setLevel(log_level)
    logging.getLogger('AdminApiLogger').setLevel(log_level)
    # clear old exceptions raised by Moler
    remove_old_exceptions()


def remove_old_exceptions():
    """Do the following:

    * Call moler.connection_observer.ConnectionObserver.get_unraised_exceptions() to get old exceptions and print
      them, then
    * Set MolerTest._was_error as False and assign an empty list to MolerTest._list_of_errors to clear old
      exceptions
    """
    unraised_exceptions = ConnectionObserver.get_unraised_exceptions()
    if unraised_exceptions:
        MolerTest.info('Found unraised exceptions : {}')
    MolerTest._was_error = False
    MolerTest._list_of_errors = list()


def decompress_xz(xz_file, output_path=None):
    xz_file = Path(xz_file)
    if not output_path:
        output_path = xz_file.parent / xz_file.stem
    with lzma.open(xz_file, 'rb') as sf:
        with open(output_path, 'wb') as tf:
            shutil.copyfileobj(sf, tf)
    return output_path


def decompress_tar(tar_file, output_path=None):
    tar_file = Path(tar_file)
    if not output_path:
        output_path = tar_file.parent / tar_file.stem
    tar_file = tarfile.open(tar_file)
    names = tar_file.getnames()
    for name in names:
        tar_file.extract(name, output_path)
    tar_file.close()
    return output_path


def unzip_file(file_path, output_path=None):
    MolerTest.info('Start to unzip snapshot file: {}'.format(file_path))
    zip_file = None
    try:
        if not output_path:
            output_path = file_path.parent / 'extracted_{}'.format(file_path.stem)
        zip_file = zipfile.ZipFile(file_path)
        for item in zip_file.namelist():
            zip_file.extract(item, output_path)
    except Exception as e:
        MolerTest.error('Unzip {} fail!\n{}'.format(file_path, e), raise_exception=True)
    finally:
        if zip_file:
            zip_file.close()
    MolerTest.info('Unzip file output path: {}'.format(output_path))
    return output_path


def decompress_gz_file(file_path, output_path=None):
    file_path = Path(file_path)
    MolerTest.info('Start to extract gz file: {}'.format(file_path))
    gz_inst = None
    try:
        if not output_path:
            output_path = file_path.parent / file_path.stem
        gz_inst = gzip.GzipFile(file_path)
        open(output_path, 'wb+').write(gz_inst.read())
    except Exception as e:
        MolerTest.error('Extract {} fail!\n{}'.format(file_path, e), raise_exception=True)
    finally:
        if gz_inst:
            gz_inst.close()
    return output_path


def decompress_file(file_path, output_path=None):
    """
    Decompress file specified by file path.

    :param file_path:str, absolut path of file to be decompressed
    :param output_path: str, the path or the directory of decompressed file
    :return: str, the path or the directory of decompressed file
    """
    file_path = Path(file_path)
    MolerTest.info('Decompress file: {} into {}'.format(file_path, output_path))
    if file_path.suffix == '.zip':
        return unzip_file(file_path, output_path)
    if file_path.suffix == '.gz':
        return decompress_gz_file(file_path, output_path)
    if file_path.suffix == '.xz':
        return decompress_xz(file_path, output_path)
    if file_path.suffix == '.tar' or file_path.suffix == '.tgz':
        return decompress_tar(file_path, output_path)
    MolerTest.error('Not support the file type: {}'.format(file_path))


def get_file_in_snapshot_file(snapshot_extracted_path, file_type, output_path):
    """
    Search specified file from snapshot file, and extract then into output path

    :param snapshot_extracted_path: str, the path which snapshot files are extracted into
    :param file_type: str, search the file based on this type
    :param output_path: str, the path or the directory of decompressed file
    :return: None
    """
    MolerTest.info('To get file in snapshot path: {}, file type: {}, output path: {}'.format(
        snapshot_extracted_path, file_type, output_path))
    for zip_file in snapshot_extracted_path.glob(ZIP_FILE_IN_SNAPSHOT):
        zip_inst = None
        try:
            zip_inst = zipfile.ZipFile(zip_file)
            zip_file_namelist = zip_inst.namelist()
            for zip_item in zip_file_namelist:
                if FILE_KEYWORDS[file_type] in zip_item:
                    MolerTest.info('Found snapshot file {} in zip file: {}'.format(zip_item, zip_file))
                    tmp = decompress_file(zip_file)
                    for item in tmp.glob(FILE_PATTERNS[file_type]):
                        MolerTest.info(
                            'Found file : {}, move into {}'.format(item, output_path)
                        )
                        shutil.move(item.__str__(), output_path)
                    shutil.rmtree(tmp)
        except Exception as e:
            MolerTest.error('Search fail in {}!\n{}'.format(zip_file, e), raise_exception=True)
        finally:
            if zip_inst:
                zip_inst.close()


def format_soap_packet_file(packet_file, output_file=None):
    pattern_hdr = r'(?P<TIMESTAMP>[\d:\.]+) IP (?P<SOURCE>[\d\.]+) > (?P<TARGET>[\d\.]+): UDP, length (?P<LENGTH>\d+)'
    results = []
    new_soap_msg = False
    line_no = 0
    with open(packet_file, 'r') as sf:
        for line in sf:
            line = line.strip()
            if len(line) <= SKIP_LOW_LAYER_SIZE:
                continue
            m = re.search(pattern_hdr, line)
            if m:
                length = int(m.group('LENGTH'))
                if length <= 12:
                    continue

                if not new_soap_msg:
                    new_soap_msg = True
                    results.append(
                        {
                            'timestamp': m.group('TIMESTAMP'),
                            'source': m.group('SOURCE'),
                            'target': m.group('TARGET'),
                            'length': length,
                            'payload': ''
                        })
                    continue
            if new_soap_msg:
                index = SKIP_LOW_LAYER_SIZE
                if SOAP_BEGIN in line:
                    index = line.find(SOAP_BEGIN)

                results[line_no]['payload'] += line[index:]
                if SOAP_END in line:
                    new_soap_msg = False
                    line_no += 1
    if output_file:
        with open(output_file, 'w') as tf:
            for result in results:
                tf.write('[{} {} {} {}] {}\n'.format(*result.values()))
    return results


def get_lte_band(earfcn):
    earfcn = int(earfcn)
    band = 0
    if 0 <= earfcn <= 599:
        band = 1
    elif 600 <= earfcn <= 1199:
        band = 2
    elif 1200 <= earfcn <= 1949:
        band = 3
    elif 1950 <= earfcn <= 2399:
        band = 4
    elif 2400 <= earfcn <= 2649:
        band = 5
    elif 2650 <= earfcn <= 2749:
        band = 6
    elif 2750 <= earfcn <= 3449:
        band = 7
    elif 3450 <= earfcn <= 3799:
        band = 8
    elif 3800 <= earfcn <= 4149:
        band = 9
    elif 4150 <= earfcn <= 4749:
        band = 10
    elif 4750 <= earfcn <= 4949:
        band = 11
    elif 5010 <= earfcn <= 5179:
        band = 12
    elif 5180 <= earfcn <= 5279:
        band = 13
    elif 5280 <= earfcn <= 5379:
        band = 14
    elif 5730 <= earfcn <= 5849:
        band = 17
    elif 5850 <= earfcn <= 5999:
        band = 18
    elif 6000 <= earfcn <= 619:
        band = 19
    elif 6150 <= earfcn <= 6449:
        band = 20
    elif 6450 <= earfcn <= 6599:
        band = 21
    elif 6600 <= earfcn <= 7399:
        band = 22
    elif 7700 <= earfcn <= 8039:
        band = 24
    elif 8040 <= earfcn <= 8689:
        band = 25
    elif 8690 <= earfcn <= 9039:
        band = 26
    elif 9040 <= earfcn <= 9209:
        band = 27
    elif 9210 <= earfcn <= 9659:
        band = 28
    elif 9660 <= earfcn <= 9769:
        band = 29
    elif 9770 <= earfcn <= 9869:
        band = 30
    elif 9870 <= earfcn <= 9919:
        band = 31
    elif 9920 <= earfcn <= 10359:
        band = 32
    elif 36000 <= earfcn <= 36199:
        band = 33
    elif 38650 <= earfcn <= 39649:
        band = 40
    elif 39650 <= earfcn <= 41589:
        band = 41
    elif 46790 <= earfcn <= 54539:
        band = 46
    elif 55240 <= earfcn <= 56739:
        band = 48
    elif 65536 <= earfcn <= 66435:
        band = 65
    elif 66436 <= earfcn <= 67335:
        band = 66
    elif 67336 <= earfcn <= 67535:
        band = 67
    return band
