import csv
import re
import math
import logging
import json
import warnings
import string
import traceback

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.config.scf import scf
from taf.analyzer.pdml import PdmlReader
from taf.ul.ettf.logger import custom_logger
from taf.ul.ettf.logger import log as ettf_log
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analyzer_framework import pandas_gate
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.dtx import get_dtx_stats
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.mumimo import get_mumimo_stats, \
    generate_rank_stats, generate_subcellId_stats
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.ue_cell_identification import identify_cells_and_ues
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.check_nack import\
    filter_valid_events_and_check_acknack_retx
from testsuite.Paris.RRM.ET.CB009836.resources.python.tools import get_specified_column_from_csv_file, \
    get_feature_paramters_from_scf
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.helper_functions import normalize_sfn_values
from testsuite.Paris.RRM.ET.CB009836.resources.python.l1l2_pcap_analyzer_framework.pcap_dataframe\
    import normalized_convert_pcap_to_df, write_df_to_pickle
from testsuite.Paris.RRM.ET.CB009836.resources.python.l1l2_pcap_analysis.trs import check_trs
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.check_CB009836 import\
    filter_valid_events_and_check_CB009836_A_1, filter_valid_events_and_check_CB009836_A_2, \
    filter_valid_events_and_check_DlPrbAssign, filter_valid_events_has_zab_privilege

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]


logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()
logger = custom_logger(name='CB009836-lib', filename='test_execution_CB009836.log', disable_html_logging=True)
logger_extract_syslog = custom_logger(name='CB009836-lib', filename='test_execution_CB009836_extract_syslog.log',
                                      disable_html_logging=True)


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console(
            "  %s: exception happened (see log.html)" % functionNameStr)


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def extract_ESTATUS5G_NOTOK_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ESTATUS5G_NOTOK.(.*)", syslogextract)
    print(err)
    return err


def extract_GnbOamCellUpdateFailed_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.GnbOamCellUpdateFailed.(.*)", syslogextract)
    print(err)
    return err


def extract_AASYSINFO_FS_OVERLOAD_IND_MSG_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    AASYSINFO_FS_OVERLOAD_IND_MSG
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.AASYSINFO_FS_OVERLOAD_IND_MSG.(.*)", syslogextract)
    print(err)
    return err


def extract_IncorrectCellParameterSettingAI_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    Raising fault IncorrectCellParameterSettingAI
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.Raising fault IncorrectCellParameterSettingAI.(.*)", syslogextract)
    print(err)
    return err


def extract_BearerErrorIndication_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    Raising fault IncorrectCellParameterSettingAI
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.Sending BearerErrorIndication due to MaxRlcRetransmission exceeded.(.*)", syslogextract)
    print(err)
    return err


def extract_ERR_uplane_L2_PS_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ERR/.uplane/L2-PS
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ERR/\.uplane/L2-PS.(.*)", syslogextract)
    print(err)
    return err


def extract_ERR_L2_PS_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ERR/L2-PS
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ERR/L2-PS.(.*)", syslogextract)
    print(err)
    return err


def extract_resource_Allocation_Failed_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ERR/L2-PS
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.resource allocation failed.(.*)", syslogextract)
    print(err)
    return err


def extract_L2_PS_CellSetupLogger_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    INF/.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.INF/\.uplane/L2-PS/src/sgnl/psCell/CellSetupLogger\.cpp:.(.*)", syslogextract)
    print(err)
    return err


def extract_INF_L2_PS_CellSetupLogger_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.INF/L2-PS/src/sgnl/psCell/CellSetupLogger\.cpp:.(.*)", syslogextract)
    print(err)
    return err


def get_last_item(input_string, starting_item):
    starting_string = '{"' + starting_item + '":'
    start_idx = input_string.find(starting_string)

    while start_idx != -1:
        end_idx = find_matching_brace(input_string, start_idx)
        if end_idx == -1:
            break

        json_str = input_string[start_idx:end_idx + 1]
        start_idx = input_string.find(starting_string, end_idx + 1)

    # print(json_str)
    last_item = find_last_occurrence('\"(.*?)\":', json_str)
    return last_item


def find_matching_brace(s, start):
    count = 1
    for i in range(start + 1, len(s)):
        if s[i] == '{':
            count += 1
        elif s[i] == '}':
            count -= 1
            if count == 0:
                return i
    return -1


def find_last_occurrence(pattern, input_string):
    matches = re.findall(pattern, input_string)
    if matches:
        return matches[-1]
    else:
        return None


def extract_CSIRS_pattern_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    INF/L2-PS/src/sgnl/psCell/CellSetupLogger.cpp:
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.CSIRS].(.*)", syslogextract)
    print(err)
    return err


def is_string_empty_or_none(my_string):
    return my_string is None or len(my_string) == 0


@log_begin_end_func_name
@ettf_log('extract_csirsPoolingGroupId_from_syslog...', 'extract_csirsPoolingGroupId_from_syslog finished', logger)
def extract_csirsPoolingGroupId_from_syslog(syslogextract: str, csirsgroups=None,
                                            file='l2ps-cellsetup-syslog'):
    if not isinstance(syslogextract, str) or\
            (isinstance(syslogextract, str) and is_string_empty_or_none(syslogextract)):
        raise TypeError("[extract_csirsPoolingGroupId_from_syslog] syslogextract should be a string.")
    if csirsgroups is not None and not isinstance(csirsgroups, list):
        raise TypeError("[extract_csirsPoolingGroupId_from_syslog] csirsgroups should be a list or None.")
    if csirsgroups is None:
        datedConsole(f"[extract_csirsPoolingGroupId_from_syslog] csirsgroups is None. Create Empty List")
        csirsgroups = []
    print(csirsgroups)
    print(type(csirsgroups))
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    # syslogextract_flt2 = re.sub('^(.*CellSetupReq_t: )', "", syslogextract_flt)
    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    try:
        pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
        # pattern = r'\{\"nrCellGrpId\":.*?\"actDlSchLowBufferOpt\":.*?\}'
    except (TypeError, IndexError):
        pattern = r'\{\"nrCellGrpId\":.*?\"actDlSchLowBufferOpt\":.*?\}'
        pass
    matches = re.findall(pattern, syslogextract_flt)
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        try:
            data = json.loads(msg)
        except Exception as e:
            text = "[extract_csirsPoolingGroupId_from_syslog]"
            text = text + " json.loads(msg) err. Let's just ignore all exceptions, like this one: {}"
            datedConsole(text.format(str(e)))
            continue
        csirsgroup_per_cell = {'cell': data['nrCellIdentity'],
                               'csirsPoolingGroupId': data['bbPoolingInfoCell']['csirsPoolingGroupId'],
                               'lcrId': data['lcrId']}
        msg = "[extract_csirsPoolingGroupId_from_syslog][CellId=%s] =====> msg_begin_loop"
        logger.info(msg % data['nrCellIdentity'])
        cell_found = False
        for csirsgroup in csirsgroups:
            msg = "[extract_csirsPoolingGroupId_from_syslog] =====> csirsgroup_begin_loop with %s"
            logger.info(msg % csirsgroup)
            # current_id = csirsgroup['cell']
            current_id = csirsgroup.get('cell', None)  # improve robustness
            if current_id == data['nrCellIdentity']:
                csirsgroup['csirsPoolingGroupId'] = data['bbPoolingInfoCell']['csirsPoolingGroupId']
                msg = "[extract_csirsPoolingGroupId_from_syslog] =====> update csirsgroup with %s"
                logger.info(msg % csirsgroup['csirsPoolingGroupId'])
                cell_found = True
        if not cell_found:
            if csirsgroup_per_cell not in csirsgroups:
                msg = "[extract_csirsPoolingGroupId_from_syslog] "
                msg = msg + "=====> append in csirsgroup because csirsgroup_per_cell not present (with %s)"
                logger.info(msg % csirsgroup_per_cell)
                csirsgroups.append(csirsgroup_per_cell)
        if not csirsgroups:
            if csirsgroup_per_cell not in csirsgroups:
                msg = "[extract_csirsPoolingGroupId_from_syslog] "
                msg = msg + "=====> First append in csirsgroup because csirsgroup_per_cell not present (with %s)"
                logger.info(msg % csirsgroup_per_cell)
                csirsgroups.append(csirsgroup_per_cell)
        filename = file + '-cell-' + str(data['nrCellIdentity']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
    msg = "=====> csirsgroups is %s"
    logger.info(msg % csirsgroups)
    sorted_csirs = sorted(csirsgroups, key=lambda p: p['cell'])
    return sorted_csirs


@log_begin_end_func_name
def check_all_cell_csirspool_present(csirsgroups, list_nrCellIdentity):
    cell_found = False
    cellnotfoundlist = []
    for cellidentity in list_nrCellIdentity:
        cell_found = False
        for csirsgroup in csirsgroups:
            # msg_console = '=====> item csirsgroup'
            # datedConsole(getHeaderLine(msg_console, csirsgroup))
            try:
                if csirsgroup['cell'] == int(cellidentity):
                    cell_found = True
                    # msg_console = '=====> cell found '
                    # datedConsole(getHeaderLine(msg_console, cellidentity))
            except Exception as e:
                datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
                pass
        if not cell_found:
            cellnotfoundlist.append(cellidentity)
    return cellnotfoundlist


@log_begin_end_func_name
def check_all_cell_in_cellcsirs_present(cellcsirs, list_nrCellIdentity):
    cell_found = False
    cellnotfoundlist = []
    for cellidentity in list_nrCellIdentity:
        cell_found = False
        for cell in cellcsirs:
            # msg_console = '=====> item csirsgroup'
            # datedConsole(getHeaderLine(msg_console, csirsgroup))
            try:
                if cell['cellId'] == int(cellidentity):
                    cell_found = True
                    # msg_console = '=====> cell found '
                    # datedConsole(getHeaderLine(msg_console, cellidentity))
            except Exception as e:
                datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
                pass
        if not cell_found:
            cellnotfoundlist.append(cellidentity)
    return cellnotfoundlist


@log_begin_end_func_name
@ettf_log('extract_csirsPoolingGroupId_from_syslog_v1...',
          'extract_csirsPoolingGroupId_from_syslog_v1 finished', logger)
def extract_csirsPoolingGroupId_from_syslog_v1(syslogextract, file='l2ps-cellsetup-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    # syslogextract_flt2 = re.sub('^(.*CellSetupReq_t: )', "", syslogextract_flt)
    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))
    # pattern = r'\{\"nrCellGrpId\":.*?\"slotAggregationConfig\":.*?\}'
    pattern = r'\{\"nrCellGrpId\":.*?\"actDlSchLowBufferOpt\":.*?\}'

    matches = re.findall(pattern, syslogextract_flt)
    csirsgroups = []
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        data = json.loads(msg)
        csirsgroup_per_cell = {'cell': data['nrCellIdentity'],
                               'csirsPoolingGroupId': data['bbPoolingInfoCell']['csirsPoolingGroupId']}
        if csirsgroup_per_cell not in csirsgroups:
            csirsgroups.append(csirsgroup_per_cell)
        filename = file + '-cell-' + str(data['nrCellIdentity']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
    sorted_csirs = sorted(csirsgroups, key=lambda p: p['cell'])
    return sorted_csirs


@log_begin_end_func_name
@ettf_log('extract_cellcsirs_from_syslog...', 'extract_cellcsirs_from_syslog finished', logger)
def extract_cellcsirs_from_syslog(syslogextract, csirsgroups, cellcsirs=None,
                                  file='l2ps-cellsetupresp-syslog-', debug=False):
    if cellcsirs is None:
        cellcsirs = []
    if type(debug) is bool:
        _debug = debug
    else:
        if debug == 'True':
            _debug = True
        else:
            _debug = False
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    index_cellcsirs = 0
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        if _debug:
            msg_console = '=====> msg_begin_loop'
            datedConsole(getHeaderLine(msg_console, data['nrCellIdentity']))
        msg = "[extract_cellcsirs_from_syslog][CellId=%s] =====> msg_begin_loop"
        logger.info(msg % data['nrCellIdentity'])
        filename = file + '-cellcsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        f_cellcsirs_per_cell = open(filename, 'w')
        csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
        try:
            cellcsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                                  'resource_set': data['cellCsiRsTimeDomainAllocation']['resourceSet']}
            # msg_console = '=====> [extract_cellcsirs_from_syslog] cellcsirs_per_cell'
            # datedConsole(getHeaderLine(msg_console, cellcsirs_per_cell))
            json.dump(cellcsirs_per_cell, f_cellcsirs_per_cell, indent=4)
            if _debug:
                msg_console = '=====> extract_cellcsirs_from_syslog : csirsgroup'
                datedConsole(getHeaderLine(msg_console, csirsgroup[0]))
                msg_console = '=====> extract_cellcsirs_from_syslog begin loop : cellcsirs'
                datedConsole(getHeaderLine(msg_console, cellcsirs))
            msg = "[extract_cellcsirs_from_syslog] =====> extract_cellcsirs_from_syslog : csirsgroup=%s"
            logger.info(msg % csirsgroup[0])
            msg = "[extract_cellcsirs_from_syslog] =====> extract_cellcsirs_from_syslog begin loop : cellcsirs=%s"
            logger.info(msg % cellcsirs)
            # add here if csirsPoolingGroupId already present in cellcsirs
            # => remove it before add new csirsPoolingGroupId
            for cellcsirs_item in cellcsirs:
                if _debug:
                    msg_console = '=====> extract_cellcsirs_from_syslog : cellcsirs_elt_loop'
                    datedConsole(getHeaderLine(msg_console, cellcsirs_item))
                    msg_console = '=====> extract_cellcsirs_from_syslog : len cellcsirs'
                    datedConsole(getHeaderLine(msg_console, len(cellcsirs)))
                msg = "[extract_cellcsirs_from_syslog] =====> extract_cellcsirs_from_syslog : cellcsirs_elt_loop=%s"
                logger.info(msg % cellcsirs_item)
                msg = "[extract_cellcsirs_from_syslog] =====> extract_cellcsirs_from_syslog : len cellcsirs=%s"
                logger.info(msg % len(cellcsirs))
                if cellcsirs_item['csirsPoolingGroupId'] == csirsgroup[0]:
                    if _debug:
                        msg_console = '=====> extract_cellcsirs_from_syslog: remove csirsgroup'
                        datedConsole(getHeaderLine(msg_console, cellcsirs_item['csirsPoolingGroupId']))
                    msg = "[extract_cellcsirs_from_syslog] extract_cellcsirs_from_syslog: remove csirsgroup=%s"
                    logger.info(msg % cellcsirs_item['csirsPoolingGroupId'])
                    cellcsirs = list(filter(lambda i: i['csirsPoolingGroupId'] != csirsgroup[0], cellcsirs))
                index_cellcsirs = index_cellcsirs + 1
            if cellcsirs_per_cell not in cellcsirs:
                if _debug:
                    msg_console = '=====> extract_cellcsirs_from_syslog: add csirsgroup'
                    datedConsole(getHeaderLine(msg_console, cellcsirs_per_cell))
                msg = "[extract_cellcsirs_from_syslog] =====> extract_cellcsirs_from_syslog: add csirsgroup=%s"
                logger.info(msg % cellcsirs_per_cell)
                cellcsirs.append(cellcsirs_per_cell)
        except (TypeError, IndexError):
            filename = file + '-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
            with open(filename, 'w') as f:
                json.dump(data, f, indent=4)
            continue
        filename = file + '-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
    slot_offsets = cellcsirs
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    # msg_console = '=====> [extract_cellcsirs_from_syslog] sorted_slots'
    # datedConsole(getHeaderLine(msg_console, sorted_slots))
    msg = "[extract_cellcsirs_from_syslog] =====> sorted_slots=%s"
    logger.info(msg % sorted_slots)
    # sorted_slots_2 = sorted(sorted_slots.items(), key=lambda x: len(x[1]))
    # msg_console = '=====> [extract_cellcsirs_from_syslog] sorted_slots_2'
    # datedConsole(getHeaderLine(msg_console, sorted_slots_2))
    return sorted_slots


@log_begin_end_func_name
@ettf_log('extract_cellcsirs_from_syslog_cell...', 'extract_cellcsirs_from_syslog_cell finished', logger)
def extract_cellcsirs_from_syslog_cell(syslogextract, csirsgroups, cellcsirs=None,
                                       file='l2ps-cellsetupresp-syslog-'):
    if cellcsirs is None:
        cellcsirs = []

    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'messageResult'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print('last item: ' + last_item)
    # pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    for msg in matches:
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        # print(data)
        msg = "[extract_cellcsirs_from_syslog_cell][CellId=%s] process with nrCellIdentity=%s"
        logger.info(msg % (data['nrCellIdentity'], data['nrCellIdentity']))
        filename = file + '-cellcsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        f_cellcsirs_per_cell = open(filename, 'w')
        try:
            cellCsiRsConfig = {'cellId': data['nrCellIdentity'],
                               'resource_set': data['cellCsiRsTimeDomainAllocation']['resourceSet']}
            try:
                for i in range(len(cellCsiRsConfig['resource_set'])):
                    cellCsiRsConfig['resource_set'][i].pop('csiImResSlotOffset')
            except (TypeError, IndexError):
                pass
            json.dump(cellCsiRsConfig, f_cellcsirs_per_cell, indent=4)
            for cellcsirs_item in cellcsirs:
                if cellcsirs_item['cellId'] == data['nrCellIdentity']:
                    msg = "[extract_cellcsirs_from_syslog_cell] remove nrCellIdentity=%s"
                    logger.info(msg % cellcsirs_item['cellId'])
                    cellcsirs = list(filter(lambda i: i['cellId'] != data['nrCellIdentity'], cellcsirs))
            msg = "[extract_cellcsirs_from_syslog_cell] add nrCellIdentity=%s"
            logger.info(msg % data['nrCellIdentity'])
            cellcsirs.append(cellCsiRsConfig)

        except (TypeError, IndexError):
            pass
        filename = file + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
    slot_offsets = cellcsirs
    cellCsiRsConfig_Sorted = sorted(slot_offsets, key=lambda p: p['cellId'])
    msg = "[extract_cellcsirs_from_syslog_cell] =====> cellCsiRsConfig_Sorted=%s"
    logger.info(msg % cellCsiRsConfig_Sorted)
    return cellCsiRsConfig_Sorted


def extract_cellcsirs_from_syslog_v1(syslogextract, csirsgroups, file='l2ps-cellsetupresp-syslog-'):

    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        filename = file + '-cellcsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        f_cellcsirs_per_cell = open(filename, 'w')
        csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
        cellcsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                              'resource_set': data['cellCsiRsTimeDomainAllocation']['resourceSet']}
        # msg_console = '=====> [extract_cellcsirs_from_syslog] cellcsirs_per_cell'
        # datedConsole(getHeaderLine(msg_console, cellcsirs_per_cell))
        json.dump(cellcsirs_per_cell, f_cellcsirs_per_cell, indent=4)
        if cellcsirs_per_cell not in slot_offsets:
            slot_offsets.append(cellcsirs_per_cell)
        filename = file + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    # msg_console = '=====> [extract_cellcsirs_from_syslog] sorted_slots'
    # datedConsole(getHeaderLine(msg_console, sorted_slots))
    # sorted_slots_2 = sorted(sorted_slots.items(), key=lambda x: len(x[1]))
    # msg_console = '=====> [extract_cellcsirs_from_syslog] sorted_slots_2'
    # datedConsole(getHeaderLine(msg_console, sorted_slots_2))
    return sorted_slots


@log_begin_end_func_name
@ettf_log('extract_uecsirs_from_syslog...', 'extract_uecsirs_from_syslog finished', logger)
def extract_uecsirs_from_syslog(syslogextract, csirsgroups,
                                uecsirs=None, file='l2ps-cellsetupresp-syslog', debug=False):
    if uecsirs is None:
        uecsirs = []
    if type(debug) is bool:
        _debug = debug
    else:
        if debug == 'True':
            _debug = True
        else:
            _debug = False
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    index_uecsirs = 0
    for msg in matches:
        print('data')
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        print(data)
        if _debug:
            msg_console = '=====> msg_begin_loop'
            datedConsole(getHeaderLine(msg_console, data['nrCellIdentity']))
        msg = "[extract_uecsirs_from_syslog][CellId=%s] =====> msg_begin_loop"
        logger.info(msg % data['nrCellIdentity'])
        filename = file + '-uecsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        f_uecsirs_per_cell = open(filename, 'w')
        csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
        try:
            uecsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                                'uecsirs': data['availablePucchAndCsiRsResources']}
        except (TypeError, IndexError):
            continue
        json.dump(uecsirs_per_cell, f_uecsirs_per_cell, indent=4)
        if _debug:
            msg_console = '=====> extract_uecsirs_from_syslog : csirsgroup'
            datedConsole(getHeaderLine(msg_console, csirsgroup[0]))
            msg_console = '=====> extract_uecsirs_from_syslog begin loop : uecsirs'
            datedConsole(getHeaderLine(msg_console, uecsirs))
        msg = "[extract_uecsirs_from_syslog] =====> csirsgroup=%s"
        logger.info(msg % csirsgroup[0])
        msg = "[extract_uecsirs_from_syslog] =====> begin loop : uecsirs=%s"
        logger.info(msg % uecsirs)
        # if csirsPoolingGroupId already present in cellcsirs => remove it before add new csirsPoolingGroupId
        for uecsirs_item in uecsirs:
            if _debug:
                msg_console = '=====> extract_uecsirs_from_syslog : cellcsirs_elt_loop'
                datedConsole(getHeaderLine(msg_console, uecsirs_item))
                msg_console = '=====> extract_uecsirs_from_syslog : len uecsirs'
                datedConsole(getHeaderLine(msg_console, len(uecsirs)))
            msg = "[extract_uecsirs_from_syslog] =====> uecsirs_elt_loop=%s"
            logger.info(msg % uecsirs_item)
            msg = "[extract_uecsirs_from_syslog] =====> len uecsirs=%s"
            logger.info(msg % len(uecsirs))
            if uecsirs_item['csirsPoolingGroupId'] == csirsgroup[0]:
                if _debug:
                    msg_console = '=====> extract_uecsirs_from_syslog: remove csirsgroup'
                    datedConsole(getHeaderLine(msg_console, uecsirs_item['csirsPoolingGroupId']))
                msg = "[extract_uecsirs_from_syslog] remove csirsgroup=%s"
                logger.info(msg % uecsirs_item['csirsPoolingGroupId'])
                uecsirs = list(filter(lambda i: i['csirsPoolingGroupId'] != csirsgroup[0], uecsirs))
            index_uecsirs = index_uecsirs + 1
        if uecsirs_per_cell not in uecsirs:
            if _debug:
                msg_console = '=====> extract_uecsirs_from_syslog: add csirsgroup in uecsirs'
                datedConsole(getHeaderLine(msg_console, uecsirs_per_cell))
            msg = "[extract_uecsirs_from_syslog] =====> add csirsgroup=%s in uecsirs"
            logger.info(msg % uecsirs_per_cell)
            uecsirs.append(uecsirs_per_cell)
    slot_offsets = uecsirs
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    msg = "[extract_uecsirs_from_syslog] =====> sorted_slots=%s"
    logger.info(msg % sorted_slots)
    return sorted_slots


@log_begin_end_func_name
def extract_uecsirs_from_syslog_v1(syslogextract, csirsgroups, file='l2ps-cellsetupresp-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    pattern = r'\{\"messageResult\":\{.*?diagnosticInformation.*?\}'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    index = 0
    for msg in matches:
        print('data')
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        print(data)
        filename = file + '-uecsirs_per_cell-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        index = index + 1
        f_uecsirs_per_cell = open(filename, 'w')
        csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
        uecsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                            'uecsirs': data['availablePucchAndCsiRsResources']}
        json.dump(uecsirs_per_cell, f_uecsirs_per_cell, indent=4)
        if uecsirs_per_cell not in slot_offsets:
            slot_offsets.append(uecsirs_per_cell)
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])

    return sorted_slots


@log_begin_end_func_name
@ettf_log('extract_nrCellGrpId_from_syslog...', 'extract_nrCellGrpId_from_syslog finished', logger)
def extract_nrCellGrpId_from_syslog(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # pattern = r'\{\"nrCellGrpId\":.*?\"slotAggregationConfig\":.*?\}'
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    nrCellGrps = []
    for msg in matches:
        # data = json.loads(msg)
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        nrCellGrp_per_cell = {'cell': data['nrCellIdentity'],
                              'nrCellGrpId': data['nrCellGrpId']}
        if nrCellGrp_per_cell not in nrCellGrps:
            nrCellGrps.append(nrCellGrp_per_cell)

    sorted_nrCellGrps = sorted(nrCellGrps, key=lambda p: p['cell'])

    return sorted_nrCellGrps


@log_begin_end_func_name
def extract_trscsirs_from_syslog(syslogextract, csirsgroups, nrCellGroups, trscsirs=None,
                                 file='l2ps-CellGroupSetupReq-syslog'):
    if trscsirs is None:
        trscsirs = []
    # syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    syslogextract_flt = re.sub(r"\n.*?0xd373 ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    # pattern = r'{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?}'
    # pattern = r'{\"' + starting_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        # print('data')
        # data = json.loads(msg)
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        # print(data)
        filename = file + '-cellGrpId-' + str(data['nrCellGrpId']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        try:
            nrCellId = [sub['cell'] for sub in nrCellGroups if sub['nrCellGrpId'] == data['nrCellGrpId']][0]
            csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == nrCellId]
            trscsirs_per_cellgrp = {'csirsPoolingGroupId': csirsgroup[0],
                                    'csirsTrackingResourceSet': data['csirsTrackingResourceSet']}
            # add here if csirsPoolingGroupId already present in trscsirs
            # => remove it before add new csirsPoolingGroupId
            for trscsirs_item in trscsirs:
                msg = "[extract_trscsirs_from_syslog] =====> trscsirs_elt_loop=%s"
                logger.info(msg % trscsirs_item)
                msg = "[extract_trscsirs_from_syslog] =====> len trscsirs=%s"
                logger.info(msg % len(trscsirs))
                if trscsirs_item['csirsPoolingGroupId'] == csirsgroup[0]:
                    msg = "[extract_trscsirs_from_syslog]: remove csirsgroup=%s from trscsirs"
                    logger.info(msg % trscsirs_item['csirsPoolingGroupId'])
                    trscsirs = list(filter(lambda i: i['csirsPoolingGroupId'] != csirsgroup[0], trscsirs))
            if trscsirs_per_cellgrp not in trscsirs:
                msg = "[extract_trscsirs_from_syslog] =====> : add csirsgroup=%s in trscsirs"
                logger.info(msg % trscsirs_per_cellgrp)
                trscsirs.append(trscsirs_per_cellgrp)
        except IndexError:
            pass
    slot_offsets = trscsirs
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    msg = "[extract_trscsirs_from_syslog] =====> sorted_slots=%s"
    logger.info(msg % sorted_slots)

    return sorted_slots


@log_begin_end_func_name
def extract_trscsirs_from_syslog_v3(syslogextract, csirsgroups, nrCellGroups, trscsirs=None,
                                    file='l2ps-CellGroupSetupReq-syslog'):
    if trscsirs is None:
        trscsirs = []
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        # print('data')
        # data = json.loads(msg)
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        # print(data)
        filename = file + '-cellGrpId-' + str(data['nrCellGrpId']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        try:
            nrCellId = [sub['cell'] for sub in nrCellGroups if sub['nrCellGrpId'] == data['nrCellGrpId']][0]
            csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == nrCellId]
            trscsirs_per_cellgrp = {'csirsPoolingGroupId': csirsgroup[0],
                                    'numberOfTransmittedSsBlocks': data['numberOfTransmittedSsBlocks'],
                                    'csirsTrackingResourceSet': data['csirsTrackingResourceSet']}
            # add here if csirsPoolingGroupId already present in trscsirs
            # => remove it before add new csirsPoolingGroupId
            for trscsirs_item in trscsirs:
                msg = "[extract_trscsirs_from_syslog] =====> trscsirs_elt_loop=%s"
                logger.info(msg % trscsirs_item)
                msg = "[extract_trscsirs_from_syslog] =====> len trscsirs=%s"
                logger.info(msg % len(trscsirs))
                if trscsirs_item['csirsPoolingGroupId'] == csirsgroup[0]:
                    msg = "[extract_trscsirs_from_syslog]: remove csirsgroup=%s from trscsirs"
                    logger.info(msg % trscsirs_item['csirsPoolingGroupId'])
                    trscsirs = list(filter(lambda i: i['csirsPoolingGroupId'] != csirsgroup[0], trscsirs))
            if trscsirs_per_cellgrp not in trscsirs:
                msg = "[extract_trscsirs_from_syslog] =====> : add csirsgroup=%s in trscsirs"
                logger.info(msg % trscsirs_per_cellgrp)
                trscsirs.append(trscsirs_per_cellgrp)
        except IndexError:
            pass
    slot_offsets = trscsirs
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    msg = "[extract_trscsirs_from_syslog] =====> sorted_slots=%s"
    logger.info(msg % sorted_slots)

    return sorted_slots


@log_begin_end_func_name
def extract_trscsirs_with_ssb(trscsirs=None, csirsgroups=None, lcrId=3, numberOfTransmittedSsBlocks='SSBLOCKS_4'):
    if trscsirs is None:
        trscsirs = []
    try:
        csirsgroup_cell = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['lcrId'] == int(lcrId)]
        trscsirs_cell_grp = [sub for sub in trscsirs if sub['csirsPoolingGroupId'] == csirsgroup_cell[0]]
        trscsirs_cell = [sub for sub in trscsirs_cell_grp
                         if sub['numberOfTransmittedSsBlocks'] == numberOfTransmittedSsBlocks]
        trscsirs_per_cellgrp = {'csirsPoolingGroupId': trscsirs_cell[0]['csirsPoolingGroupId'],
                                'csirsTrackingResourceSet': trscsirs_cell[0]['csirsTrackingResourceSet']}
    except Exception as e:
        details = traceback.format_exc()
        rbi.log_to_console("debug: Failure in extract_trscsirs_with_ssb. traceback = %s" % details)
        rbi.log("debug: Failure in extract_trscsirs_with_ssb. traceback = %s" % details)
        logException("extract_trscsirs_with_ssb", e)
    slot_offsets = trscsirs_per_cellgrp
    # sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    msg = "[extract_trscsirs_with_ssb] =====> sorted_slots=%s"
    logger.info(msg % trscsirs_per_cellgrp)
    return trscsirs_per_cellgrp


@log_begin_end_func_name
def extract_trscsirs_with_ssb_bis(trscsirs=None, lcrId=1, csirsgroups=None, numberOfTransmittedSsBlocks='SSBLOCKS_4'):
    if trscsirs is None:
        trscsirs = []
    csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['lcrId'] == lcrId]
    trscsirs_cell = [sub for sub in trscsirs if sub['numberOfTransmittedSsBlocks'] == numberOfTransmittedSsBlocks]
    for trscsirs_item in trscsirs:
        try:
            trscsirs_per_cellgrp = {'csirsPoolingGroupId': csirsgroup[0],
                                    'numberOfTransmittedSsBlocks': data['numberOfTransmittedSsBlocks'],
                                    'csirsTrackingResourceSet': data['csirsTrackingResourceSet']}
            # add here if csirsPoolingGroupId already present in trscsirs
            # => remove it before add new csirsPoolingGroupId
            for trscsirs_item in trscsirs:
                msg = "[extract_trscsirs_from_syslog] =====> trscsirs_elt_loop=%s"
                logger.info(msg % trscsirs_item)
                msg = "[extract_trscsirs_from_syslog] =====> len trscsirs=%s"
                logger.info(msg % len(trscsirs))
                if trscsirs_item['csirsPoolingGroupId'] == csirsgroup[0]:
                    msg = "[extract_trscsirs_from_syslog]: remove csirsgroup=%s from trscsirs"
                    logger.info(msg % trscsirs_item['csirsPoolingGroupId'])
                    trscsirs = list(filter(lambda i: i['csirsPoolingGroupId'] != csirsgroup[0], trscsirs))
                if trscsirs_per_cellgrp not in trscsirs:
                    msg = "[extract_trscsirs_from_syslog] =====> : add csirsgroup=%s in trscsirs"
                    logger.info(msg % trscsirs_per_cellgrp)
                    trscsirs.append(trscsirs_per_cellgrp)
        except IndexError:
            pass
    slot_offsets = trscsirs
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    msg = "[extract_trscsirs_from_syslog] =====> sorted_slots=%s"
    logger.info(msg % sorted_slots)

    return sorted_slots


@log_begin_end_func_name
def extract_trscsirs_from_syslog_v2(syslogextract, csirsgroups, nrCellGroups, file='l2ps-CellGroupSetupReq-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        # print('data')
        # data = json.loads(msg)
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        # print(data)
        filename = file + '-cellGrpId-' + str(data['nrCellGrpId']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        try:
            nrCellId = [sub['cell'] for sub in nrCellGroups if sub['nrCellGrpId'] == data['nrCellGrpId']][0]
            csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == nrCellId]
            trscsirs_per_cellgrp = {'csirsPoolingGroupId': csirsgroup[0],
                                    'csirsTrackingResourceSet': data['csirsTrackingResourceSet']}
            if trscsirs_per_cellgrp not in slot_offsets:
                slot_offsets.append(trscsirs_per_cellgrp)
        except IndexError:
            pass
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])

    return sorted_slots


@log_begin_end_func_name
def extract_trscsirs_from_syslog_v1(syslogextract, csirsgroups, file='l2ps-CellGroupSetupReq-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # msg_console = '=====> syslogextract_flt'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt))
    pattern = r'\{\"nrCellGrpId\":.*?fr2HighNumberOfUEsConfig\":.*?\}'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        print('data')
        try:
            data = json.loads(msg)
        except Exception as e:
            datedConsole("Let's just ignore all exceptions, like this one: {}".format(str(e)))
            continue
        print(data)
        filename = file + '-cellGrpId-' + str(data['nrCellGrpId']) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
        # nrCellId = [sub['cell'] for sub in nrCellGroups if sub['nrCellGrpId'] == data['nrCellGrpId']][0]
        # csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == nrCellId]
        # trscsirs_per_cellgrp = {'csirsPoolingGroupId': csirsgroup[0],
        #                         'csirsTrackingResourceSet': data['csirsTrackingResourceSet']}
        # if trscsirs_per_cellgrp not in slot_offsets:
        #    slot_offsets.append(trscsirs_per_cellgrp)
    # sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])
    # return sorted_slots


def extract_session_from_egateconsole(egateconsoleextract):
    """
    Analyzing this kind of trace:
    [session
    :param egateconsoleextract:
    :return:  cmd
    """
    # cmd = re.findall(r"*.[session .(\d*).].(.*)", egateconsoleextract)
    cmd = re.findall(r"]:.(.*)", egateconsoleextract)
    print(cmd)
    return cmd


def extract_SlotTypeSelectorBase_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    # SlotType = re.findall(r"(\d*).*Slot: (\d*).*Type: (.*)", syslogextract)
    # SlotType = re.findall(r"(\d*).*Slot=(\d*).*Type= (.*)", syslogextract)
    SlotType = re.findall(r"(\d*).*Slot=(\d*).*Type=(.*)", syslogextract)
    if SlotType:
        timestamp, slot, slot_type = SlotType[0]
        print(f"Timestamp: {timestamp}")
        print(f"Slot: {slot}")
        print(f"Type: {slot_type}")
    else:
        print("No matches found.")
    print(SlotType)
    return SlotType


def extract_BBRM_ERR_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    1540190-EQ_L2PS_BBRM ERR/L2-PS/src/bbrm/subCellsPooling/PrbCapacityChecker.cpp[161]
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.BBRM ERR.(.*)", syslogextract)
    print(err)
    return err


def extract_ESTATUS5G_NOTOK_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ESTATUS5G_NOTOK.(.*)", syslogextract)
    print(err)
    return err


def extract_GnbOamCellUpdateFailed_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.GnbOamCellUpdateFailed.(.*)", syslogextract)
    print(err)
    return err


def extract_AASYSINFO_FS_OVERLOAD_IND_MSG_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    AASYSINFO_FS_OVERLOAD_IND_MSG
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.AASYSINFO_FS_OVERLOAD_IND_MSG.(.*)", syslogextract)
    print(err)
    return err


def extract_BBRM_conf_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.PRB pooling buffer.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_2_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.Bbrm conf: bbPoolInfo present.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_3_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.Bbrm conf DL.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_4_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.Bbrm conf UL.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_DL_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.(DOWNLINK).(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_UL_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.(UPLINK).(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_totalStreamPrbs_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    Created 3 CsiRsPoolingGroup(s) with totalStreamPrbs:2184 in l1PoolId:10
    :param syslogextract:
    :return: totalStreamPrbs_l1PoolId_0, totalStreamPrbs_l1PoolId_10, cellmappingtocsirspoolinggroup
    """
    # cid2sp = re.findall(r"CsiRsPoolingGroup.*totalStreamPrbs:(\d*).*l1PoolId:(\d?)", syslogextract)
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    cid2sp = re.findall(r"CsiRsPoolingGroup.*totalStreamPrbs:(\d*).*l1PoolId:(\d*)", syslogextract_flt)
    print(cid2sp)
    totalStreamPrbs_l1PoolId_0 = []
    totalStreamPrbs_l1PoolId_10 = []
    for element in cid2sp:
        print(element)
        if int(element[1]) == 9:
            totalStreamPrbs_l1PoolId_0.append(int(element[0]))
        if int(element[1]) == 12:
            totalStreamPrbs_l1PoolId_10.append(int(element[0]))
    # 8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385
    # with streamPrbDemand:1092 to CsiRsPoolingGroup 0 (allocatedStreamPrbs:1092) in l1PoolId:10\n
    # 8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385
    # with streamPrbDemand:1092 to CsiRsPoolingGroup 0 (allocatedStreamPrbs:1092) in l1PoolId:10\n
    #
    cellmappingtocsirspoolinggroup =\
        re.findall(
            r"added NrCellIdentity:(\d*).*streamPrbDemand:(\d*).*CsiRsPoolingGroup (\d*)"
            r".*allocatedStreamPrbs:(\d*).*l1PoolId:(\d*)",
            syslogextract)
    print(cellmappingtocsirspoolinggroup)
    return [totalStreamPrbs_l1PoolId_0, totalStreamPrbs_l1PoolId_10, cellmappingtocsirspoolinggroup]


def extract_l1sp_from_syslog_OLD(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    cid2sp = re.findall(r"SCellMappingReq.*ulSubcellId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract_flt)
    print(cid2sp)
    # ulSubcellId
    sp0 = [0, 1, 2, 4]
    # sp0 = [0, 1, 2, 4, 5, 6, 7, 8, 9]
    # ulsubpoolid => 2 ulsubpool
    sp1 = []
    for element in cid2sp:
        print(element)
        if int(element[1]) == 1:
            sp1.append(int(element[0]))
            sp0.remove(int(element[0]))

    return [sp0, sp1]


def extract_bbPoolInfos_from_syslog(syslogextract, file='l2ps-AddressDistributionReq-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    print('flt : {}'.format(syslogextract_flt))
    starting_item = 'loCtrlAddress'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print("last_item: {}".format(last_item))
    try:
        pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?\}{3,}'
    except (TypeError, IndexError):
        pass
    # pattern = r'AddressDistributionReq_t:.*?(\{.*?\}\}\}\})'
    # pattern = r'\{\"l1Pools\":\[.*?\}\}\}'
    # matches = re.findall(pattern, syslogextract_flt)

    # matches = re.search(pattern, syslogextract_flt)
    matches = re.findall(pattern, syslogextract_flt)
    print('matches: {}'.format(matches))
    index = 0
    for msg in matches:
        data = json.loads(msg)
        print(data)
        index = index + 1
        filename = file + '_' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4)

    dlSubcellDeactForARMAllowed = re.findall(r"dlSubcellDeactForARMAllowed\":\s*(.*?),", syslogextract_flt)
    actExplicitCsirsPoolSolution = re.findall(r"actExplicitCsirsPoolSolution\":\s*(.*?),", syslogextract_flt)
    actTddCsirsAllocOptimization = re.findall(r"actTddCsirsAllocOptimization\":\s*(.*?),", syslogextract_flt)

    pooling_info = {'actExplicitCsirsPoolSolution': actExplicitCsirsPoolSolution,
                    'actTddCsirsAllocOptimization': actTddCsirsAllocOptimization,
                    'dlSubcellDeactForARMAllowed': dlSubcellDeactForARMAllowed}

    print(pooling_info)
    msg = "pooling_info={}"
    datedConsole(msg.format(pooling_info))
    return pooling_info


def extract_bbPoolInfos_from_syslog_v1(syslogextract, file='l2ps-AddressDistributionReq-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    print('flt : {}'.format(syslogextract_flt))
    starting_item = 'loCtrlAddress'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print("last_item: {}".format(last_item))
    try:
        pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?\}{3,}'
    except (TypeError, IndexError):
        pass
    # pattern = r'AddressDistributionReq_t:.*?(\{.*?\}\}\}\})'
    # pattern = r'\{\"l1Pools\":\[.*?\}\}\}'
    # matches = re.findall(pattern, syslogextract_flt)

    matches = re.search(pattern, syslogextract_flt)
    print('matches: {}'.format(matches))
    data = json.loads(matches[0])
    print(data)
    filename = file + '.json'
    with open(filename, 'w') as f:
        json.dump(data, f, indent=4)

    dlSubcellDeactForARMAllowed = re.findall(r"dlSubcellDeactForARMAllowed\":\s*(.*?),", syslogextract_flt)
    actExplicitCsirsPoolSolution = re.findall(r"actExplicitCsirsPoolSolution\":\s*(.*?),", syslogextract_flt)
    actTddCsirsAllocOptimization = re.findall(r"actTddCsirsAllocOptimization\":\s*(.*?),", syslogextract_flt)

    pooling_info = {'actExplicitCsirsPoolSolution': actExplicitCsirsPoolSolution,
                    'actTddCsirsAllocOptimization': actTddCsirsAllocOptimization,
                    'dlSubcellDeactForARMAllowed': dlSubcellDeactForARMAllowed}

    print(pooling_info)
    msg = "pooling_info={}"
    datedConsole(msg.format(pooling_info))
    return pooling_info


def extract_ull1sp_from_syslog(syslogextract, l1sp_e=None, file='l2ps-SCellMappingReq-syslog'):
    if l1sp_e is None:
        l1sp_e = []
    return extract_l1sp_from_syslog(syslogextract, 'ul', l1sp_e, file=file)


def extract_dll1sp_from_syslog(syslogextract, l1sp_e=None, file='l2ps-SCellMappingReq-syslog'):
    if l1sp_e is None:
        l1sp_e = []
    return extract_l1sp_from_syslog(syslogextract, 'dl', l1sp_e, file=file)


@ettf_log('extract_l1sp_from_syslog...', 'extract_l1sp_from_syslog finished', logger)
def extract_l1sp_from_syslog(syslogextract, direction, l1sp_e=None, file='l2ps-cellmapping-syslog'):
    if l1sp_e is None:
        l1sp_e = []
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # syslogextract_flt2 = re.sub('^(.*SCellMappingReq: )', "", syslogextract_flt)
    syslogextract_flt2 = re.sub('^(.*CellMappingReq: )', "", syslogextract_flt)
    # pattern = r'\{\"CellMappingList\":.*?\"cellIndex\":.*?\}\]\}'
    pattern = r'\{\"nrCellIdentity\":.*?\"csirsPoolingGroupId\":.*?\}'

    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))
    logger_extract_syslog.info("begin extract_l1sp_from_syslog processing...")
    matches = re.findall(pattern, syslogextract_flt2)
    l1sp = []
    sp0 = []
    sp1 = []
    sp2 = []
    sp3 = []
    l1sp_2 = []
    sp0_2 = []
    sp1_2 = []
    sp2_2 = []
    sp3_2 = []
    index = 0
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        data = json.loads(msg)
        print(data)
        # msg_console = '=====> data'
        # datedConsole(getHeaderLine(msg_console, data))
        index = index + 1
        # msg_console = '=====> SubcellList'
        # datedConsole(getHeaderLine(msg_console, data[direction + 'SubcellList']))
        msg = "[extract_l1sp_from_syslog][CellId=%s][%s] =====> process with CellId %s"
        logger_extract_syslog.info(msg % (direction, data['nrCellIdentity'], data['nrCellIdentity']))
        for item in data[direction + 'SubcellList']:
            # msg_console = '=====> ' + direction + ' l1SubpoolId'
            # datedConsole(getHeaderLine(msg_console, item['l1SubpoolId']))
            msg = "[extract_l1sp_from_syslog][CellId=%s][%s] From item => %sSubcellId=%s l1PoolId=%s l1SubpoolId=%s"
            logger_extract_syslog.info(msg % (data['nrCellIdentity'], direction, direction,
                                              item[direction + 'SubcellId'],
                                              item['l1PoolId'], item['l1SubpoolId']))
            l1sp_per_cell = [data['nrCellIdentity'],
                             item['l1SubpoolId'],
                             item['l1PoolId']]
            if l1sp_per_cell not in l1sp:
                l1sp.append(l1sp_per_cell)
                msg = "[extract_l1sp_from_syslog][CellId=%s][%s] =====> append %s in l1sp"
                logger_extract_syslog.info(msg % (data['nrCellIdentity'], direction, l1sp_per_cell))
            name = direction + 'SubcellId'
            subcellid_per_l1sp = [item[name],
                                  item['l1SubpoolId'],
                                  item['l1PoolId']]
            if subcellid_per_l1sp not in l1sp_2:
                l1sp_2.append(subcellid_per_l1sp)
                msg = "[extract_l1sp_from_syslog][CellId=%s][%s] =====> append %s in l1sp2"
                logger_extract_syslog.info(msg % (data['nrCellIdentity'], direction, subcellid_per_l1sp))
            # msg_console = '=====> l1sp'
            # datedConsole(getHeaderLine(msg_console, l1sp))
        filename = file + '-' + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
    filename = file + '-' + direction + '-cellmapping' + '.json'
    if direction == 'dl':
        rbi.set_test_variable("${FileNameDLCellMapping}", filename)
    else:
        rbi.set_test_variable("${FileNameULCellMapping}", filename)
    with open(filename, 'w') as f:
        json.dump(l1sp, f, indent=4)
    if l1sp:
        mincellidentity = min([int(x[0]) for x in l1sp])
    else:
        mincellidentity = 0
    for element in l1sp:
        print(element)
        if int(element[2]) == 9:
            if int(element[1]) == 0:
                sp0.append(int(element[0]) - mincellidentity)
            elif int(element[1]) == 1:
                sp1.append(int(element[0]) - mincellidentity)
            else:
                sp0.append(int(element[0]) - mincellidentity)
        elif int(element[2]) == 12:
            if int(element[1]) == 2:
                sp2.append(int(element[0]) - mincellidentity)
            elif int(element[1]) == 3:
                sp3.append(int(element[0]) - mincellidentity)
            else:
                sp2.append(int(element[0]) - mincellidentity)
    for element in l1sp_2:
        print(element)
        if int(element[2]) == 9:
            if int(element[1]) == 0:
                sp0_2.append(int(element[0]))
            elif int(element[1]) == 1:
                sp1_2.append(int(element[0]))
            else:
                sp0_2.append(int(element[0]))
        elif int(element[2]) == 12:
            if int(element[1]) == 2:
                sp2_2.append(int(element[0]))
            elif int(element[1]) == 3:
                sp3_2.append(int(element[0]))
            else:
                sp2_2.append(int(element[0]))
    logger_extract_syslog.info("End Of extract_l1sp_from_syslog processing...")
    msg = "[extract_l1sp_from_syslog] =====> sp0 %s sp1 %s sp2 %s sp3 %s"
    logger_extract_syslog.info(msg % (sp0, sp1, sp2, sp3))
    msg = "[extract_l1sp_from_syslog] =====> sp0_2 %s sp1_2 %s sp2_2 %s sp3_2 %s"
    logger_extract_syslog.info(msg % (sp0_2, sp1_2, sp2_2, sp3_2))
    return [sorted(sp0), sorted(sp1), sorted(sp2), sorted(sp3),
            sorted(sp0_2), sorted(sp1_2), sorted(sp2_2), sorted(sp3_2)]


def extract_l1sp_from_syslog_sol1(syslogextract, direction, file='l2ps-cellmapping-syslog'):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    syslogextract_flt2 = re.sub('^(.*SCellMappingReq: )', "", syslogextract_flt)
    # pattern = r'\{\"CellMappingList\":.*?\"cellIndex\":.*?\}\]\}'
    pattern = r'\{\"nrCellIdentity\":.*?\"csirsPoolingGroupId\":.*?\}'

    # msg_console = '=====> syslogextract_flt2'
    # datedConsole(getHeaderLine(msg_console, syslogextract_flt2))

    matches = re.findall(pattern, syslogextract_flt2)
    l1sp = []
    sp0 = []
    sp1 = []
    sp2 = []
    sp3 = []
    index = 0
    for msg in matches:
        # msg_console = '=====> msg'
        # datedConsole(getHeaderLine(msg_console, msg))
        data = json.loads(msg)
        print(data)
        # msg_console = '=====> data'
        # datedConsole(getHeaderLine(msg_console, data))
        index = index + 1
        # msg_console = '=====> SubcellList'
        # datedConsole(getHeaderLine(msg_console, data[direction + 'SubcellList']))
        for item in data[direction + 'SubcellList']:
            # msg_console = '=====> ' + direction + ' l1SubpoolId'
            # datedConsole(getHeaderLine(msg_console, item['l1SubpoolId']))
            l1sp_per_cell = [data['nrCellIdentity'],
                             item['l1SubpoolId']]
            # msg_console = '=====> l1sp'
            # datedConsole(getHeaderLine(msg_console, l1sp))
            if l1sp_per_cell not in l1sp:
                l1sp.append(l1sp_per_cell)
        filename = file + str(data['nrCellIdentity']) + '-' + str(index) + '.json'
        with open(filename, 'w') as f:
            json.dump(data, f, indent=4, separators=(". ", " = "))
    filename = file + '-' + direction + '-cellmapping-' + '.json'
    with open(filename, 'w') as f:
        json.dump(l1sp, f, indent=4)
    if l1sp:
        mincellidentity = min([int(x[0]) for x in l1sp])
    else:
        mincellidentity = 0
    # to improve later !!!! => append into sp0,sp1... based on l1poolId = 10 or 13 and l1SubpoolId
    for element in l1sp:
        print(element)
        if int(element[1]) == 0:
            sp0.append(int(element[0]) - mincellidentity)
        elif int(element[1]) == 1:
            sp1.append(int(element[0]) - mincellidentity)
        elif int(element[1]) == 2:
            sp2.append(int(element[0]) - mincellidentity)
        elif int(element[1]) == 3:
            sp3.append(int(element[0]) - mincellidentity)
    return [sorted(sp0), sorted(sp1), sorted(sp2), sorted(sp3)]


def extract_ull1sp_from_syslog_9890_C(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*ulSubcellId\":(\d*).*l1PoolId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # dlSubcellId
    # sp0_poolId10 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    sp0_poolId10 = []
    sp0_poolId13 = []
    sp1_poolId10 = []
    sp1_poolId13 = []
    # dlsubpoolid => 2 dlsubpool
    for element in cid2sp:
        print(element)
        if int(element[2]) == 1 and int(element[1]) == 13:
            sp1_poolId13.append(int(element[0]))
        if int(element[2]) == 1 and int(element[1]) == 10:
            sp1_poolId10.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 13:
            sp0_poolId13.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 10:
            sp0_poolId10.append(int(element[0]))
    return [sp0_poolId10, sp0_poolId13, sp1_poolId10, sp1_poolId13]


def extract_dll1sp_from_syslog_OLD(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*dlSubcellId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # dlSubcellId
    sp0 = [0, 1, 2, 3, 4, 5]
    # sp0 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    # dlsubpoolid => 2 dlsubpool
    sp1 = []
    for element in cid2sp:
        print(element)
        if int(element[1]) == 1:
            sp1.append(int(element[0]))
            sp0.remove(int(element[0]))

    return [sp0, sp1]


def extract_dll1sp_from_syslog_9890_C(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*dlSubcellId\":(\d*).*l1PoolId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # dlSubcellId
    # sp0_poolId10 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    sp0_poolId10 = []
    sp0_poolId13 = []
    sp1_poolId10 = []
    sp1_poolId13 = []
    # dlsubpoolid => 2 dlsubpool
    for element in cid2sp:
        print(element)
        if int(element[2]) == 1 and int(element[1]) == 13:
            sp1_poolId13.append(int(element[0]))
        if int(element[2]) == 1 and int(element[1]) == 10:
            sp1_poolId10.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 13:
            sp0_poolId13.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 10:
            sp0_poolId10.append(int(element[0]))
    return [sp0_poolId10, sp0_poolId13, sp1_poolId10, sp1_poolId13]


def extract_dll1sp_from_COAM(cellinfo, sp):
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)','
    #                                                    ' 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    # sp = []
    for element in cellinfo:
        print(element)
        cid2sp = re.findall(r"Subcell-(\d*) \(DL\)", element)
        print(cid2sp)
        if cid2sp:
            sp.append(int(cid2sp[0]))
            sp.sort()
    return sp


def extract_ull1sp_from_COAM(cellinfo, sp):
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)','
    #                                                    ' 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    # sp = []
    for element in cellinfo:
        print(element)
        cid2sp = re.findall(r"Subcell-(\d*) \(UL\)", element)
        print(cid2sp)
        if cid2sp:
            sp.append(int(cid2sp[0]))
            sp.sort()
    return sp


def get_sfn_column(row_from_list):
    sfn_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            sfn_column = i
            break
    return sfn_column


def read_and_parse_tti_data(path_to_tti, num_of_events=1000):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.DictReader(csv_file)
        csv_reader = list(csv_dict)
        # print("dic: {}".format(csv_dict))
        # print("list: {}".format(csv_reader))
        line_count = 0
        tti_dict = list()
        ttifilter = ['dlMetricIndData: hfnTickCount', 'dlTdSchedSubcellData: hfnTickCount',
                     'dlAllocatedPooledResourcesData: hfnTickCount',
                     'dlDtxOptimData: hfnTickCount', 'dlFdSchedData: hfnTickCount']
        if num_of_events is not None:
            num_of_events = int(num_of_events)
        for row in csv_reader:
            # print("line: {}.".format(line_count), "Content: {}".format(row))
            # print("line: {}.".format(line_count), "Content: {}".format(row[None][0]))
            # if row[None][0] == 'ulMetricIndData: sfn' or row[None][0] == 'ulTdSchedSubcellData: sfn':
            if row[None][0] in ttifilter:
                # if row[None][0] == 'dlMetricIndData: hfnTickCount'\
                # or row[None][0] == 'dlTdSchedSubcellData: hfnTickCount'\
                #       or row[None][0] == 'dlAllocatedPooledResourcesData: hfnTickCount'\
                #       or row[None][0] == 'dlDtxOptimData: hfnTickCount'\
                #       or row[None][0] == 'dlFdSchedData: hfnTickCount':
                new_row = dict()
                # new_row.update({'Event': row[None][0][:-5]})
                new_row.update({'Event': row[None][0][:-14]})
                print("Content1: {}".format(row[None]))
                print("Content new_row: {}".format(new_row))
                col_sfn = get_sfn_column(row[None])
                col_sfn = col_sfn + 1
                print("col_sfn: {}".format(col_sfn))
                print("sfn: {}".format(row[None][col_sfn]))
                # new_row.update({'sfn': row[None][col_sfn]})
                for index_dic in range(1, col_sfn):
                    if index_dic + col_sfn < len(row[None]):
                        print(index_dic, row[None][index_dic], row[None][index_dic + col_sfn - 1])
                        # BEWARE that 2 columns can have the same name (case of largeBwpPrbs in dlDtxOptimData)
                        if row[None][index_dic] in new_row:
                            continue
                        new_row.update({row[None][index_dic]: row[None][index_dic + col_sfn - 1]})
                    else:
                        break
                tti_dict.append(new_row)
                print("line: {}.".format(line_count), "Content new_row: {}".format(new_row))
            line_count += 1
            if line_count > num_of_events:
                break

    return tti_dict


def read_and_parse_tti_data_ul(path_to_tti, num_of_events=1000):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.DictReader(csv_file)
        csv_reader = list(csv_dict)
        # print("dic: {}".format(csv_dict))
        # print("list: {}".format(csv_reader))
        line_count = 0
        tti_dict = list()
        ttifilter = ['ulMetricIndData: hfnTickCount', 'ulTdSchedSubcellData: hfnTickCount',
                     'ulAllocatedPooledResourcesData: hfnTickCount']
        if num_of_events is not None:
            num_of_events = int(num_of_events)
        for row in csv_reader:
            print("line: {}.".format(line_count), "Content: {}".format(row))
            if row[None][0] in ttifilter:
                # if row[None][0] == 'ulMetricIndData: hfnTickCount'\
                # or row[None][0] == 'ulTdSchedSubcellData: hfnTickCount'\
                # or row[None][0] == 'ulAllocatedPooledResourcesData: hfnTickCount':
                new_row = dict()
                # new_row.update({'Event': row[None][0][1:-5]})
                new_row.update({'Event': row[None][0][:-14]})
                print(row[None])
                col_sfn = get_sfn_column(row[None])
                col_sfn = col_sfn + 1
                print(col_sfn)
                # new_row.update({'sfn': row[None][col_sfn]})
                for index_dic in range(1, col_sfn):
                    if index_dic + col_sfn < len(row[None]):
                        print(index_dic, row[None][index_dic], row[None][index_dic + col_sfn - 1])
                        # BEWARE that 2 columns can have the same name (case of largeBwpPrbs in dlDtxOptimData)
                        # if row[None][index_dic] in new_row:
                        #     continue
                        new_row.update({row[None][index_dic]: row[None][index_dic + col_sfn - 1]})
                    else:
                        break
                tti_dict.append(new_row)
                print("line: {}.".format(line_count), "Content new_row: {}".format(new_row))
            line_count += 1
            if line_count > num_of_events:
                break

    return tti_dict


def get_ulprb_demand(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'], filter(lambda d: d['Event'] == 'ulMetricIndData' and int(d['sfn']) < 1012,
                                                   tti_dic)))[0]
    print('get_ulprb_demand first: {}'.format(firstsfn))
    prbdemand = []
    prbdemand_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        gbrPrbDemand_key = 'gbrPrbDemand'
        nonGbrPrbDemand_key = 'nonGbrPrbDemand'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        gbrPrbDemand = []
        nonGbrPrbDemand = []
        for lcrId in range(1, 4):
            gbrPrbDemand_i = [int(i) for i in
                              list(map(lambda d: d[gbrPrbDemand_key],
                                       filter(lambda d: d['Event'] == 'ulMetricIndData',
                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                     filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            nonGbrPrbDemand_i = [int(i) for i in
                                 list(map(lambda d: d[nonGbrPrbDemand_key],
                                          filter(lambda d: d['Event'] == 'ulMetricIndData',
                                                 filter(lambda d: d['sfn'] == sfntocheck,
                                                        filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            if not gbrPrbDemand_i:
                gbrPrbDemand.append(0)
            else:
                gbrPrbDemand.append(gbrPrbDemand_i[0])
            if not nonGbrPrbDemand_i:
                nonGbrPrbDemand.append(0)
            else:
                nonGbrPrbDemand.append(nonGbrPrbDemand_i[0])
            prbdemand_several_sfn.append(
                {'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
        prbdemand.append({'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return prbdemand, prbdemand_several_sfn


def get_dlprb_demand(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'], filter(lambda d: d['Event'] == 'dlMetricIndData'
                    and int(d['sfn']) < 1012, tti_dic)))[0]
    print('get_dlprb_demand first: {}'.format(firstsfn))
    prbdemand = []
    prbdemand_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        gbrPrbDemand_key = 'gbrPrbDemand'
        nonGbrPrbDemand_key = 'nonGbrPrbDemand'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        gbrPrbDemand = []
        nonGbrPrbDemand = []
        for lcrId in range(1, 7):
            gbrPrbDemand_i = [int(i) for i in
                              list(map(lambda d: d[gbrPrbDemand_key],
                                       filter(lambda d: d['Event'] == 'dlMetricIndData',
                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                     filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            nonGbrPrbDemand_i = [int(i) for i in
                                 list(map(lambda d: d[nonGbrPrbDemand_key],
                                          filter(lambda d: d['Event'] == 'dlMetricIndData',
                                                 filter(lambda d: d['sfn'] == sfntocheck,
                                                        filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            if not gbrPrbDemand_i:
                gbrPrbDemand.append(0)
            else:
                gbrPrbDemand.append(gbrPrbDemand_i[0])
            if not nonGbrPrbDemand_i:
                nonGbrPrbDemand.append(0)
            else:
                nonGbrPrbDemand.append(nonGbrPrbDemand_i[0])
            prbdemand_several_sfn.append(
                {'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
        prbdemand.append({'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return prbdemand, prbdemand_several_sfn


def get_dlprb_alloc_bbrm(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'],
                        filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData' and int(d['sfn']) < 1012,
                               tti_dic)))[0]
    print('first: {}'.format(firstsfn))
    numAllocCellPrbDlBBRM = []
    numAllocCellPrbDlBBRM_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        numAllocCellPrbDl_key = 'numAllocCellPrbDl'
        hasZabPrivilege_key = 'hasZabPrivilege'
        activeDlSubcellsPList_key = 'activeDlSubcellsList_[0]'
        activeDlSubcellsSList_key1 = 'activeDlSubcellsList_[1]'
        activeDlSubcellsSList_key2 = 'activeDlSubcellsList_[2]'
        activeDlSubcellsSList_key3 = 'activeDlSubcellsList_[3]'
        activeDlSubcellsSList_key4 = 'activeDlSubcellsList_[4]'
        activeDlSubcellsSList_key5 = 'activeDlSubcellsList_[5]'
        activeDlSubcellsSList_key6 = 'activeDlSubcellsList_[6]'
        activeDlSubcellsSList_key7 = 'activeDlSubcellsList_[7]'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        numAllocCellPrbDl = []
        hasZabPrivilege = []
        activeDlSubcellsPrimaryList = []
        activeDlSubcellsSecondaryList = []
        for lcrId in range(1, 4):
            numAllocCellPrbDl_i = [int(i) for i in
                                   list(map(lambda d: d[numAllocCellPrbDl_key],
                                            filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                   filter(lambda d: d['sfn'] == sfntocheck,
                                                          filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            hasZabPrivilege_i = [int(i) for i in
                                 list(map(lambda d: d[hasZabPrivilege_key],
                                          filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                 filter(lambda d: d['sfn'] == sfntocheck,
                                                        filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeDlSubcellsPList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsPList_key],
                                                filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                       filter(lambda d: d['sfn'] == sfntocheck,
                                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key1],
                                                filter(lambda d: d[activeDlSubcellsSList_key1] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not numAllocCellPrbDl_i:
                numAllocCellPrbDl.append(0)
            else:
                numAllocCellPrbDl.append(numAllocCellPrbDl_i[0])
            if not hasZabPrivilege_i:
                hasZabPrivilege.append(0)
            else:
                hasZabPrivilege.append(hasZabPrivilege_i[0])
            if not activeDlSubcellsPList_i:
                activeDlSubcellsPrimaryList.append(0)
            else:
                activeDlSubcellsPrimaryList.append(activeDlSubcellsPList_i[0])
            if not activeDlSubcellsSList_i:
                activeDlSubcellsSecondaryList.append(0)
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key2],
                                                filter(lambda d: d[activeDlSubcellsSList_key2] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeDlSubcellsSList_i:
                # activeDlSubcellsSecondaryList.append(0)
                print('no activeDlSubcellsS to add in activeDlSubcellsSList_i')
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key3],
                                                filter(lambda d: d[activeDlSubcellsSList_key3] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeDlSubcellsSList_i:
                # activeDlSubcellsSecondaryList.append(0)
                print('no activeDlSubcellsS to add in activeDlSubcellsSList_i')
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key4],
                                                filter(lambda d: d[activeDlSubcellsSList_key4] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeDlSubcellsSList_i:
                # activeDlSubcellsSecondaryList.append(0)
                print('no activeDlSubcellsS to add in activeDlSubcellsSList_i')
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            numAllocCellPrbDlBBRM_several_sfn.append(
                {'sfn': sfntocheck, 'numAllocCellPrbDl': numAllocCellPrbDl, 'hasZabPrivilege': hasZabPrivilege,
                 'activeDlSubcellsPList': activeDlSubcellsPrimaryList,
                 'activeDlSubcellsSList': activeDlSubcellsSecondaryList})
        numAllocCellPrbDlBBRM.append({'sfn': sfntocheck,
                                      'numAllocCellPrbDl': numAllocCellPrbDl, 'hasZabPrivilege': hasZabPrivilege,
                                      'activeDlSubcellsPList': activeDlSubcellsPrimaryList,
                                      'activeDlSubcellsSList': activeDlSubcellsSecondaryList})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return numAllocCellPrbDlBBRM, numAllocCellPrbDlBBRM_several_sfn


def get_ulprb_alloc_bbrm(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'],
                        filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData' and int(d['sfn']) < 1012,
                               tti_dic)))[0]
    print('first: {}'.format(firstsfn))
    numAllocCellPrbUlBBRM = []
    numAllocCellPrbUlBBRM_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        numAllocCellPrbUl_key = 'numAllocCellPrbUl'
        bbrmUsableCellPrbForUlGbrLoadReport_key = 'bbrmUsableCellPrbForUlGbrLoadReport'
        activeUlSubcellCount_key = 'activeUlSubcellCount'
        activeUlSubcellsPList_key = 'activeUlSubcellsList_[0]'
        activeUlSubcellsSList_key1 = 'activeUlSubcellsList_[1]'
        activeUlSubcellsSList_key2 = 'activeUlSubcellsList_[2]'
        activeUlSubcellsSList_key3 = 'activeUlSubcellsList_[3]'
        activeUlSubcellsSList_key4 = 'activeUlSubcellsList_[4]'
        activeUlSubcellsSList_key5 = 'activeUlSubcellsList_[5]'
        activeUlSubcellsSList_key6 = 'activeUlSubcellsList_[6]'
        activeUlSubcellsSList_key7 = 'activeUlSubcellsList_[7]'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        numAllocCellPrbUl = []
        activeUlSubcellCount = []
        activeUlSubcellsPrimaryList = []
        activeUlSubcellsSecondaryList = []
        for lcrId in range(1, 4):
            numAllocCellPrbUl_i = [int(i) for i in
                                   list(map(lambda d: d[numAllocCellPrbUl_key],
                                            filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                   filter(lambda d: d['sfn'] == sfntocheck,
                                                          filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeUlSubcellCount_i = [int(i) for i in
                                      list(map(lambda d: d[activeUlSubcellCount_key],
                                               filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                      filter(lambda d: d['sfn'] == sfntocheck,
                                                             filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeUlSubcellsPList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsPList_key],
                                                filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                       filter(lambda d: d['sfn'] == sfntocheck,
                                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key1],
                                                filter(lambda d: d[activeUlSubcellsSList_key1] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not numAllocCellPrbUl_i:
                numAllocCellPrbUl.append(0)
            else:
                numAllocCellPrbUl.append(numAllocCellPrbUl_i[0])
            if not activeUlSubcellCount_i:
                activeUlSubcellCount.append(0)
            else:
                activeUlSubcellCount.append(activeUlSubcellCount_i[0])
            if not activeUlSubcellsPList_i:
                activeUlSubcellsPrimaryList.append(0)
            else:
                activeUlSubcellsPrimaryList.append(activeUlSubcellsPList_i[0])
            if not activeUlSubcellsSList_i:
                activeUlSubcellsSecondaryList.append(0)
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key2],
                                                filter(lambda d: d[activeUlSubcellsSList_key2] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeUlSubcellsSList_i:
                # activeUlSubcellsSecondaryList.append(0)
                print('no activeUlSubcellsS to add in activeUlSubcellsSList_i')
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key3],
                                                filter(lambda d: d[activeUlSubcellsSList_key3] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeUlSubcellsSList_i:
                # activeUlSubcellsSecondaryList.append(0)
                print('no activeUlSubcellsS to add in activeUlSubcellsSList_i')
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key4],
                                                filter(lambda d: d[activeUlSubcellsSList_key4] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeUlSubcellsSList_i:
                # activeUlSubcellsSecondaryList.append(0)
                print('no activeUlSubcellsS to add in activeUlSubcellsSList_i')
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            numAllocCellPrbUlBBRM_several_sfn.append(
                {'sfn': sfntocheck, 'numAllocCellPrbUl': numAllocCellPrbUl,
                 'activeUlSubcellCount': activeUlSubcellCount,
                 'activeUlSubcellsPList': activeUlSubcellsPrimaryList,
                 'activeUlSubcellsSList': activeUlSubcellsSecondaryList})
        numAllocCellPrbUlBBRM.append({'sfn': sfntocheck,
                                      'numAllocCellPrbUl': numAllocCellPrbUl,
                                      'activeUlSubcellCount': activeUlSubcellCount,
                                      'activeUlSubcellsPList': activeUlSubcellsPrimaryList,
                                      'activeUlSubcellsSList': activeUlSubcellsSecondaryList})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return numAllocCellPrbUlBBRM, numAllocCellPrbUlBBRM_several_sfn


def get_numAllocCellPrbUl(tti_dic, sfntocheck):
    numAllocCellPrbUl_key = 'numAllocCellPrbUl'

    numAllocCellPrbUl = []
    for lcrId in range(1, 4):
        filteredprbs = list(map(lambda d: d[numAllocCellPrbUl_key],
                                filter(lambda d: d['Event'] == 'ulTdSchedSubcellData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        numAllocCellPrbUl.append(int(max(filteredprbs) if filteredprbs else 0))
    return {'sfn': sfntocheck, 'numAllocCellPrbUl': numAllocCellPrbUl}


def get_numAllocCellPrbDl(tti_dic, sfntocheck):
    numAllocCellPrbDl_key = 'numAllocCellPrbDl'

    numAllocCellPrbDl = []
    for lcrId in range(1, 4):
        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlTdSchedSubcellData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
    return {'sfn': sfntocheck, 'numAllocCellPrbDl': numAllocCellPrbDl}


def get_numOfPrb_dlFdSchedData(tti_dic, sfntocheck, num_of_events=10):
    numAllocCellPrbDl_key = 'numOfPrb'
    numOfPrbCellPrbDl = []
    numAllocCellPrbDldlFdSchedData = []
    line_count = 0
    for lcrId in range(1, 4):
        filteredprbs_i = [int(i) for i in
                          list(map(lambda d: d[numAllocCellPrbDl_key],
                                   filter(lambda d: d['Event'] == 'dlFdSchedData',
                                          filter(lambda d: d['sfn'] == sfntocheck,
                                                 filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]

        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlFdSchedData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        if not filteredprbs_i:
            numOfPrbCellPrbDl.append(0)
        else:
            numOfPrbCellPrbDl.append(filteredprbs_i[1])
        line_count += 1
        if line_count > num_of_events:
            break
        # numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
        # numAllocCellPrbDl.append(int(filteredprbs[1]) if filteredprbs else 0)
    numAllocCellPrbDldlFdSchedData.append({'sfn': sfntocheck, 'numAllocCellPrbDl': numOfPrbCellPrbDl})
    return numAllocCellPrbDldlFdSchedData


def getValue(scfObj, pName, distName):
    outString = ""
    logging.info("getValue(): pName = %s" % pName)
    logging.info("getValue(): outString = %s" % outString)
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("getValue(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("getValue", e)
    return outString


def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = getValue(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


def verify_SCF_Paramaters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB009915 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # scfFilePath = BuiltIn().run_keyword(
    #    "CB009915-C-Keywords.Get Testcase Log Directory") + "/SCF.xml"
    # BuiltIn().ettf_log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_bts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id)
    mr_nr_cell_cell1 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-1'
    mr_nr_cell_cell2 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-2'
    try:
        expected_scf_list = [{'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell2}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


def verify_SCF_Paramaters_TC_w_PSBWP():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB009915 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # scfFilePath = BuiltIn().run_keyword(
    #    "CB009915-C-Keywords.Get Testcase Log Directory") + "/SCF.xml"
    # BuiltIn().ettf_log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_bts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id)
    mr_nr_cell_cell1 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-1'
    mr_nr_cell_cell2 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-2'
    name = 'actInitialBWPFlexibility'
    try:
        expected_scf_list = [{'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': name, 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': 'actPowerSavingBWP', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actPowerSavingBWP', 'value': 'false', 'dist_name': mr_nr_cell_cell2}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


def verify_SCF_Paramaters_TC_w_PSBWP_2_Cells():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB009915 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # scfFilePath = BuiltIn().run_keyword(
    #    "CB009915-C-Keywords.Get Testcase Log Directory") + "/SCF.xml"
    # BuiltIn().ettf_log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_bts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id)
    mr_nr_cell_cell1 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-1'
    mr_nr_cell_cell2 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-2'
    name = 'actInitialBWPFlexibility'
    try:
        expected_scf_list = [{'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actLongPucchResourceOpt', 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': name, 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actPRBBlanking', 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': name, 'value': 'true', 'dist_name': mr_nr_cell_cell2},
                             {'p_name': 'actPowerSavingBWP', 'value': 'true', 'dist_name': mr_nr_cell_cell1},
                             {'p_name': 'actPowerSavingBWP', 'value': 'true', 'dist_name': mr_nr_cell_cell2}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


def is_CB010544_activated_for_Cell1():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - return of CB010544 feature activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_cell_name_cell1 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-1'
    name = 'actInitialBWPFlexibility'
    try:
        expected_scf_list = [{'p_name': name, 'value': 'true', 'dist_name': mr_nr_cell_name_cell1}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("is_CB010544_activated_for_Cell1", e)
    return is_SCF_correct


def load_dataframe(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


def get_dtx_statistics_physCellId_ul(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def get_dtx_statistics_rnti_ul(filename):
    is_TTITrace_correct = False
    isPassed = True
    output = ""
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='rnti', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        isPassed = False
    return output


def get_dtx_statistics_lcrId_ul(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='lcrId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def get_dtx_statistics_physCellId_dl(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='dl')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='dl')
        logging.info("combined_mumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_dl", e)
    return combined_mumimo_stats, mumimo_stats


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='ul')
        logging.info("combined_ulmumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_ul", e)
    return combined_mumimo_stats, mumimo_stats


def get_cells_and_ues_physCellId(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = identify_cells_and_ues(df)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_cells_and_ues_physCellId", e)
    return output


@log_begin_end_func_name
def get_rank_statistics_rnti_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='dl')
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_dl", e)
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_rank_statistics_rnti_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='ul')
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_ul", e)
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='dl')
        logging.info("combined_dl_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_dl", e)
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='ul')
        logging.info("combined_ul_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_ul", e)
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_directory(path):
    path_tmp = path.split("/")
    path = "/".join(path_tmp[:-1])
    return path


@log_begin_end_func_name
def filter_dataframe_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulTdSchedSubcellData.subcellId',
                               'ulTdSchedSubcellData.numAllocCellPrbUl', 'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlTdSchedSubcellData.subcellId',
                               'dlTdSchedSubcellData.numAllocCellPrbDl', 'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_mumimo_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlFdSchedData.subcellId',
                               'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers',
                               'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_mumimo_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulFdSchedData.subcellId',
                               'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers',
                               'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def drop_head_tail_entries(df, num=1000):
    """Function drops num entries from the beginning and the end of the dataframe to compensate for the
    abnormalities seen in trace during start and stop of traffic"""
    df = df[num:-num]
    return df


@log_begin_end_func_name
def prepare_df_to_compute_mumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def filter_dataframe_csirs_dl(df):
    if 'csiRsSchedData.csiRsTraceType' in df.columns:
        required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'csiRsSchedData.subcellId',
                                   'csiRsSchedData.csiRsTraceType', 'csiRsSchedData.startSymbol',
                                   'csiRsSchedData.startPrb', 'csiRsSchedData.numOfPrb',
                                   'csiRsSchedData.csiRsConfig', 'lcrId']
    else:
        required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'csiRsSchedData.subcellId',
                                   'csiRsSchedData.startSymbol', 'csiRsSchedData.startPrb', 'csiRsSchedData.numOfPrb',
                                   'csiRsSchedData.csiRsConfig', 'lcrId']
    df = df[required_discriminators].copy()
    if 'csiRsSchedData.csiRsTraceType' in df.columns:
        df = df[df['csiRsSchedData.csiRsTraceType'] == 'CELLCSIRS']
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    # logging.info("=====> filter_dataframe_csirs_dl=%s" % df)
    return df


@log_begin_end_func_name
def run_csirs_analysis_dl(path_to_pickle,
                          exclude_samples_for_analysis=1000,
                          physCellId=50,
                          slot=16,
                          list_start_symb=(2, 3, 6, 7),
                          name='dl_dataframe_for_manual_analysis_csirs'):
    """Check csirs"""
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_csirs_dl(df)
    normalized_df = normalize_sfn_values(df)
    logging.info("run_csirs_analysis_dl[%s]: length of df = %s" % (physCellId, len(normalized_df)))
    len_df = len(normalized_df)
    if len_df > 3*exclude_samples_for_analysis:
        df = drop_head_tail_entries(normalized_df, num=exclude_samples_for_analysis)
    normalized_df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')

    df_cell1 = normalized_df[normalized_df['physCellId'] == physCellId]

    # calculated csirs period
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # path_to_scf_xml = '/home/ute/csamson/TRACES/SCF.xml'
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    cellId = int(physCellId) - 50 + 1
    mr_nr_cell_name_cell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/' + 'NRCELL-' + str(cellId)
    # mr_nr_cell_name_cell = 'MRBTS-1/NRBTS-1/NRCELL-' + str(cellId)
    periodicCsiAcquisition_params_list = ['csiReportPeriodicity', 'csirsNumberWithinReportPeriod_Set1', 'csirsPower',
                                          'maxCsirsNumber', 'scramblingIdStep']
    periodicCsiAcquisition = get_feature_paramters_from_scf(path_to_scf_xml,
                                                            periodicCsiAcquisition_params_list,
                                                            mr_nr_cell_name_cell,
                                                            'periodicCsiAcquisition')
    csiRsPeriod = periodicCsiAcquisition['csiReportPeriodicity']
    csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod).group())
    csirsNbWithinReportPeriod_Set1_ = periodicCsiAcquisition['csirsNumberWithinReportPeriod_Set1']
    # Calcul du CSI-RS resource periodicity
    # 5G_CP_ARC_ALG_2571 and 5G_CP_ARC_ALG_4854
    if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1_) - 1)) > 40:
        csiRsPeriodicity = int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1_) - 1))
    else:
        csiRsPeriodicity = 40
    df_cell1 = normalized_df.where(normalized_df['physCellId'] == physCellId).dropna()
    df_cell1['deltaSFN'] = df_cell1['normalized_sfn'].diff(-1).dropna()
    diff_sfn = list((df_cell1['deltaSFN'].dropna().unique()))
    diff_sfn_abs = [abs(ele) for ele in diff_sfn]
    diff_sfn_abs_no_zero = [value for value in diff_sfn_abs if value != 0]
    period_csirs_ms_cell1 = [element * 20 for element in diff_sfn_abs_no_zero]
    df_cell1.to_csv(str("%s/%s_physCellId_%s.csv" % (get_directory(path_to_pickle), name, physCellId)), sep=';')
    msg = 'physCellId'
    datedConsole(getHeaderLine(msg, physCellId))
    msg = 'nidd csiReportPeriodicity'
    datedConsole(getHeaderLine(msg, csiRsPeriod))
    msg = 'nidd csirsNbWithinReportPeriod_Set1'
    datedConsole(getHeaderLine(msg, csirsNbWithinReportPeriod_Set1_))
    msg = 'calculted period_csirs_ms_cell'
    datedConsole(getHeaderLine(msg, csiRsPeriodicity))
    msg = 'period_csirs_ms_cell calculated from TtiTrace'
    datedConsole(getHeaderLine(msg, period_csirs_ms_cell1))
    msg = 'expected csirs slot'
    datedConsole(getHeaderLine(msg, slot))
    msg = 'expected csirs list start symb'
    datedConsole(getHeaderLine(msg, list_start_symb))

    threshold_err = 0.0
    threshold_ok = 100.0
    # check for physCellId
    df_physCellId_ToCheck = df.where(df['physCellId'] == physCellId).dropna()
    rbi.log('df_physCellId: {}'.format(df_physCellId_ToCheck))
    df_nb_correct_slot = df_physCellId_ToCheck.where(df['slot'] == slot).dropna().value_counts().reset_index()
    df_total_slot = df_physCellId_ToCheck.value_counts().reset_index()
    rbi.log("df_nb_correct_slot present: {}".format(df_nb_correct_slot['count']))
    rbi.log("df_total_slot present: {}".format(df_total_slot['count']))
    df_incorrect_slot = df_physCellId_ToCheck.loc[df_physCellId_ToCheck['slot'] != slot].dropna(subset=['slot'])
    rbi.log('df_incorrect_slot: {}'.format(df_incorrect_slot))
    # Get percentage of correct slot
    percentage = 100 * len(df_nb_correct_slot) / len(df_total_slot)
    rbi.log("physCellId: {} Percentage of Correct Slot: {} Threshold accepted: {}".format(
                 physCellId, percentage, threshold_ok))
    correct_slot_percentage = (percentage == threshold_ok)
    # Get percentage of incorrect slot
    percentage = 100 * len(df_incorrect_slot) / len(df_total_slot)
    rbi.log("physCellId: {} Percentage of Incorrect Slot: {} Threshold accepted: {}".format(
                 physCellId, percentage, threshold_err))
    is_correct_startSymb_present = all(x in df_physCellId_ToCheck['csiRsSchedData.startSymbol'].values
                                       for x in list_start_symb)
    rbi.log("physCellId: {} Is Correct startSymb present: {}".format(physCellId, is_correct_startSymb_present))
    return all((correct_slot_percentage, is_correct_startSymb_present))


@log_begin_end_func_name
def run_csirs_stat_analysis_dl(path_to_pickle,
                               exclude_samples_for_analysis=1000):
    """Check csirs Stats"""
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_csirs_dl(df)
    logging.info("run_csirs_stat_analysis_dl: length of df = %s" % len(df))
    len_df = len(df)
    if len_df > 3*exclude_samples_for_analysis:
        df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)

    global filtered_df_slot
    filtered_df_slot = df[['physCellId', 'slot']].dropna()
    rbi.log('filtered_df_slot: {}'.format(filtered_df_slot))

    global slot_stats
    slot_stats = filtered_df_slot.value_counts().reset_index()
    """Identify total events per defined group in trace"""
    # grouped by physCellId
    global total_events_grouped
    total_events_grouped = filtered_df_slot.groupby('physCellId').size()
    """Add new columns to df"""
    slot_stats['Total Count'] = slot_stats['physCellId'].map(total_events_grouped)
    slot_stats['Percentage'] = (slot_stats['count'] / slot_stats['Total Count']) * 100
    """Combine stats"""
    global combined_slots_stats
    combined_slots_stats = slot_stats.pivot(index='physCellId', columns='slot', values=['count', 'Percentage'])
    combined_slots_stats.fillna(0, inplace=True)
    rbi.log('combined_slots_stats: {}'.format(combined_slots_stats))

    global filtered_df_start_symbol
    filtered_df_start_symbol = df[['physCellId', 'csiRsSchedData.startSymbol']].dropna()
    rbi.log('filtered_df_start_symbol: {}'.format(filtered_df_start_symbol))

    global start_symbol_stats
    start_symbol_stats = filtered_df_start_symbol.value_counts().reset_index()
    """Identify total events per defined group in trace"""
    # grouped by physCellId
    global total_events_grouped_df_start_symbol
    total_events_grouped_df_start_symbol = filtered_df_start_symbol.groupby('physCellId').size()
    # rbi.log('total_events_grouped_df_start_symbol: {}'.format(total_events_grouped_df_start_symbol))
    """Add new columns to df"""
    start_symbol_stats['Total Count'] = start_symbol_stats['physCellId'].map(total_events_grouped_df_start_symbol)
    rbi.log('start_symbol_stats: {}'.format(start_symbol_stats))
    start_symbol_stats['Percentage'] = (start_symbol_stats['count'] / start_symbol_stats['Total Count']) * 100
    """Combine stats"""
    global combined_start_symbol_stats
    combined_start_symbol_stats = start_symbol_stats.pivot(index='physCellId',
                                                           columns='csiRsSchedData.startSymbol',
                                                           values=['count'])
    combined_start_symbol_stats.fillna(0, inplace=True)
    rbi.log('combined_start_symbol_stats: {}'.format(combined_start_symbol_stats))
    combined_start_symbol_stats_Percentage = start_symbol_stats.pivot(index='physCellId',
                                                                      columns='csiRsSchedData.startSymbol',
                                                                      values=['Percentage'])
    combined_start_symbol_stats_Percentage.fillna(0, inplace=True)
    rbi.log('combined_start_symbol_stats_Percentage: {}'.format(combined_start_symbol_stats_Percentage))
    return combined_slots_stats, combined_start_symbol_stats_Percentage


@log_begin_end_func_name
def filter_dataframe_csirs_pcap_dl(df):
    required_discriminators = ['sfn', 'Slot', 'SubcellID',
                               'StartSymbol', 'TRSInfo', 'normalized_sfn']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    # logging.info("=====> filter_dataframe_csirs_pcap_dl=%s" % df)
    return df


@log_begin_end_func_name
def run_csirs_stat_analysis_pcap_dl(path_to_pickle,
                                    exclude_samples_for_analysis=1000):
    """Check csirs Stats"""
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_csirs_pcap_dl(df)
    logging.info("run_csirs_stat_analysis_pcap_dl: length of df = %s" % len(df))
    len_df = len(df)
    if len_df > 3*exclude_samples_for_analysis:
        df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)

    global filtered_df_slot
    filtered_df_slot = df[['SubcellID', 'Slot']].dropna()
    rbi.log('filtered_df_slot: {}'.format(filtered_df_slot))

    global slot_stats
    slot_stats = filtered_df_slot.value_counts().reset_index()
    """Identify total events per defined group in trace"""
    # grouped by physCellId
    global total_events_grouped
    total_events_grouped = filtered_df_slot.groupby('SubcellID').size()
    """Add new columns to df"""
    slot_stats['Total Count'] = slot_stats['SubcellID'].map(total_events_grouped)
    slot_stats['Percentage'] = (slot_stats['count'] / slot_stats['Total Count']) * 100
    """Combine stats"""
    global combined_slots_stats
    combined_slots_stats = slot_stats.pivot(index='SubcellID', columns='Slot', values=['count', 'Percentage'])
    combined_slots_stats.fillna(0, inplace=True)
    rbi.log('combined_slots_stats: {}'.format(combined_slots_stats))

    global filtered_df_start_symbol
    filtered_df_start_symbol = df[['SubcellID', 'StartSymbol']].dropna()
    rbi.log('filtered_df_start_symbol: {}'.format(filtered_df_start_symbol))

    global start_symbol_stats
    start_symbol_stats = filtered_df_start_symbol.value_counts().reset_index()
    """Identify total events per defined group in trace"""
    # grouped by physCellId
    global total_events_grouped_df_start_symbol
    total_events_grouped_df_start_symbol = filtered_df_start_symbol.groupby('SubcellID').size()
    # rbi.log('total_events_grouped_df_start_symbol: {}'.format(total_events_grouped_df_start_symbol))
    """Add new columns to df"""
    start_symbol_stats['Total Count'] = start_symbol_stats['SubcellID'].map(total_events_grouped_df_start_symbol)
    rbi.log('start_symbol_stats: {}'.format(start_symbol_stats))
    start_symbol_stats['Percentage'] = (start_symbol_stats['count'] / start_symbol_stats['Total Count']) * 100
    """Combine stats"""
    global combined_start_symbol_stats
    combined_start_symbol_stats = start_symbol_stats.pivot(index='SubcellID',
                                                           columns='StartSymbol',
                                                           values=['count'])
    combined_start_symbol_stats.fillna(0, inplace=True)
    rbi.log('combined_start_symbol_stats: {}'.format(combined_start_symbol_stats))
    combined_start_symbol_stats_Percentage = start_symbol_stats.pivot(index='SubcellID',
                                                                      columns='StartSymbol',
                                                                      values=['Percentage'])
    combined_start_symbol_stats_Percentage.fillna(0, inplace=True)
    rbi.log('combined_start_symbol_stats_Percentage: {}'.format(combined_start_symbol_stats_Percentage))
    return combined_slots_stats, combined_start_symbol_stats_Percentage


@log_begin_end_func_name
def filter_dataframe_prbblanking_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlFdSchedData.subcellId',
                               'dlFdSchedData.startPrb', 'dlFdSchedData.numOfPrb', 'dlFdSchedData.rat0Bitmap',
                               'dlFdSchedData.ueBwpId', 'dlFdSchedData.cellBwpId', 'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    # logging.info("=====> filter_dataframe_prbblanking_dl=%s" % df)
    return df


def return_only_rbgsize_pdsch(chBW=273, ConfigType=1):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    return rbgsize


def cal_num_of_pdsch(chBW, ConfigType, nbrOfBlankedPRBsHighEdgeDL=0, nbrOfBlankedPRBsLowEdgeDL=0, w_debug=0):
    config_1 = {2: [1, 36], 4: [37, 72], 8: [73, 144], 16: [145, 275]}
    config_2 = {4: [1, 36], 8: [37, 72], 16: [73, 275]}
    # chBW_int = int(chBW)
    # ConfigType_int = int(ConfigType)
    rbgsize = 0
    if ConfigType == 1:
        for key in config_1:
            if config_1[key][0] <= chBW <= config_1[key][1]:
                rbgsize = key
    elif ConfigType == 2:
        for key in config_2:
            if config_2[key][0] <= chBW <= config_2[key][1]:
                rbgsize = key
    rat0bitmap = [rbgsize for i in range(chBW//rbgsize)]
    rat0bitmap.append(chBW % rbgsize)
    rat0bitmap_full = rat0bitmap
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsHighEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsHighEdgeDL))
    msg = 'cal_num_of_pdsch: nbrOfBlankedPRBsLowEdgeDL'
    if w_debug:
        datedConsole(getHeaderLine(msg, nbrOfBlankedPRBsLowEdgeDL))
    msg = 'cal_num_of_pdsch: rat0bitmap'
    if w_debug:
        datedConsole(getHeaderLine(msg, rat0bitmap_full))
    if nbrOfBlankedPRBsHighEdgeDL != 0 or nbrOfBlankedPRBsLowEdgeDL != 0:
        x = 0
        y = 0
        if w_debug:
            datedConsole(getHeaderLine('Instrum1 '+msg, rat0bitmap[-1]))
        res = nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1]
        if w_debug:
            datedConsole(getHeaderLine('Instrum1.1 ' + msg, (res, nbrOfBlankedPRBsHighEdgeDL, rat0bitmap[-1])))
        # if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] <= 0:
        if nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] == 0:
            rat0bitmap = rat0bitmap[:-1]
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        elif nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1] < 0:
            if w_debug:
                datedConsole(getHeaderLine('Instrum2 ' + msg, rat0bitmap))
        else:
            y = math.ceil((nbrOfBlankedPRBsHighEdgeDL - rat0bitmap[-1])/rbgsize)
            if w_debug:
                datedConsole(getHeaderLine('Instrum3.0 ' + msg, y))
            rat0bitmap = rat0bitmap[:-1-y]
            if w_debug:
                datedConsole(getHeaderLine('Instrum3 ' + msg, rat0bitmap))
        x = math.ceil(nbrOfBlankedPRBsLowEdgeDL/rbgsize)
        rat0bitmap = rat0bitmap[x:]
        if rat0bitmap[-1] == rbgsize:
            usablepdsch = len(rat0bitmap) * rbgsize
        else:
            usablepdsch = len(rat0bitmap[:-1]) * rbgsize + rat0bitmap[-1]
    else:
        usablepdsch = chBW
    msg = '=====> Full rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap_full))
    msg = '=====> Full NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap_full)))
    msg = '=====> Usable rat0bitmap'
    datedConsole(getHeaderLine(msg, rat0bitmap))
    msg = '=====> Usable NbrRBG'
    datedConsole(getHeaderLine(msg, len(rat0bitmap)))
    msg = '=====> Usable PRB PDSCH'
    datedConsole(getHeaderLine(msg, usablepdsch))
    return chBW, rat0bitmap_full, usablepdsch, rat0bitmap


@log_begin_end_func_name
def verify_BwPId_rnti_FromTtiTraces(filecsv_dl,
                                    filecsv_ul,
                                    rnti_ueid_1_cell=0,
                                    bwpid_ue_rnti_1='1',
                                    rnti_ueid_2_cell=0,
                                    bwpid_ue_rnti_2='1'):
    # -------------------------------------------------------------------------------------------------[120 characters]
    Check_dl = False
    Check_ul = False
    path_to_csvtrace_dl = filecsv_dl
    path_to_csvtrace_ul = filecsv_ul
    rntiBwp = {
        rnti_ueid_1_cell: bwpid_ue_rnti_1,
        rnti_ueid_2_cell: bwpid_ue_rnti_2
    }
    logging.info("rntiBwp = %s" % (rntiBwp))
    try:
        logging.basicConfig(level=logging.DEBUG)
        Check_dl = check_rnti_bwpid(csv_file=path_to_csvtrace_dl, rnti=rntiBwp)
        logging.info("Check for DL rntiBwp = %s" % (Check_dl))
        text = "verify_BwPId_rnti_FromTtiTraces: Check_dl = %s"
        logging.info(text % Check_dl)
        msg = 'verify_BwPId_rnti_FromTtiTraces: DL Check'
        datedConsole(getHeaderLine(msg, Check_dl))
        Check_ul = check_rnti_bwpid(csv_file=path_to_csvtrace_ul, rnti=rntiBwp, pattern='ulFdSchedData.cellBwpId')
        logging.info("Check for UL rntiBwp = %s" % (Check_ul))
        text = "verify_BwPId_rnti_FromTtiTraces: Check_ul = %s"
        logging.info(text % Check_ul)
        msg = 'verify_BwPId_rnti_FromTtiTraces: UL Check'
        datedConsole(getHeaderLine(msg, Check_ul))
    except Exception as e:
        logException("verify_BwPId_rnti_FromTtiTraces", e)
    rbi.set_test_variable("${TestResult}", str(Check_dl and Check_ul))
    rbi.should_be_true(Check_dl and Check_ul)


@log_begin_end_func_name
def verify_TTITraces_for_acknack_retx(path_to_pickle):
    filter_valid_events_and_check_acknack_retx(path_to_pickle=path_to_pickle)


@log_begin_end_func_name
def extract_l1subpool_cell_relation(filename):
    phycell_ul_subcell = {}
    l1_subcell_pool_lcr_id = {}
    logging.info("extract_l1subpool_cell_relation: pdml file = %s" % (filename))
    with open(filename, "rb") as file_obj:
        print("Extracting data from Cell Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "icom_5g" in root:
                phycell_id = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                        "itf_l2_ps_cell_CellSetupReq_t.physCellId")
                lcr_id = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                    "itf_l2_ps_cell_CellSetupReq_t.lcrId")
                ulsubcell_pool_id = root.xpath(
                    "icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//itf_l2_ps_ulsubcell//*")
                if len(phycell_id) != 0:
                    phycell_id = int(phycell_id[0].show)
                    lcr_id = int(lcr_id[0].show)
                    for item in ulsubcell_pool_id:
                        if "l1SubPoolId" in str(item.showname):
                            l1_pool_id = item.show
                            phycell_ul_subcell[phycell_id] = int(l1_pool_id)
                            if l1_subcell_pool_lcr_id.get(int(l1_pool_id)) is not None:
                                l1_subcell_pool_lcr_id[int(
                                    l1_pool_id)].append(lcr_id)
                            else:
                                l1_subcell_pool_lcr_id[int(l1_pool_id)] = [
                                    lcr_id]
                            break
    return l1_subcell_pool_lcr_id, phycell_ul_subcell


@log_begin_end_func_name
def display_dynamic_pusch(filecsv):
    # -------------------------------------------------------------------------------------------------[120 characters]
    path_to_csvtrace = filecsv
    try:
        logging.basicConfig(level=logging.DEBUG)
        physcellid = get_specified_column_from_csv_file(path_to_csvtrace, 'itf_l2_ps_cell_CellSetupReq_t.physCellId')
        # text = "display_dynamic_pusch: physcellid = %s"
        # logging.info(text % physcellid)
        subcellid = get_specified_column_from_csv_file(path_to_csvtrace, '3gpp.subcellid')
        cellbwpid = get_specified_column_from_csv_file(path_to_csvtrace, 'itf_l2_ps_cell_Bwp.cellBwpId')
        bwpType = get_specified_column_from_csv_file(path_to_csvtrace, 'itf_l2_ps_cell_Bwp.bwpType')
        bandwidth = get_specified_column_from_csv_file(path_to_csvtrace, 'itf_l2_ps_cell_BwpDefinitionUl.bandwidth')
        long_pucch_start_pusch_prb = \
            get_specified_column_from_csv_file(path_to_csvtrace,
                                               'itf_l2_ps_cell_BwpDefinitionUl.longPucchStartPuschPrb_item')
        long_pucch_num_pusch_prb = \
            get_specified_column_from_csv_file(path_to_csvtrace,
                                               'itf_l2_ps_cell_BwpDefinitionUl.longPucchNumPuschPrb_item')
        long_pucch_start_dyn_pusch_prb = \
            get_specified_column_from_csv_file(path_to_csvtrace,
                                               'itf_l2_ps_cell_BwpDefinitionUl.longPucchStartDynPuschPrb_item')
        long_pucch_num_dyn_pusch_prb = \
            get_specified_column_from_csv_file(path_to_csvtrace,
                                               'itf_l2_ps_cell_BwpDefinitionUl.longPucchNumDynPuschPrb_item')
        datedConsole(getHeaderLine('physcellid', physcellid))
        datedConsole(getHeaderLine('subcellid', subcellid))
        datedConsole(getHeaderLine('cellbwpid', cellbwpid))
        datedConsole(getHeaderLine('bwpType', bwpType))
        datedConsole(getHeaderLine('bandwidth', bandwidth))
        datedConsole(getHeaderLine('long_pucch_start_pusch_prb', long_pucch_start_pusch_prb))
        datedConsole(getHeaderLine('long_pucch_num_pusch_prb', long_pucch_num_pusch_prb))
        datedConsole(getHeaderLine('long_pucch_num_pusch_prb', long_pucch_start_dyn_pusch_prb))
        datedConsole(getHeaderLine('long_pucch_num_pusch_prb', long_pucch_num_dyn_pusch_prb))
    except Exception as e:
        logException("display_dynamic_pusch", e)
    return long_pucch_start_dyn_pusch_prb, long_pucch_num_dyn_pusch_prb


@log_begin_end_func_name
def verify_CellSetup_SysCom_Pdml_Traces():
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SysCom_correct = False
    path_to_syscom_pdml = rbi.get_variable_value("${path_to_syscom_pdml}")
    logging.info("pdml file = %s" % (path_to_syscom_pdml))
    expected_phycell_ul_subcell = {50: 0, 51: 1, 52: 0}
    expected_l1_subcell_pool_lcr_id = {0: [1, 3], 1: [2]}
    try:
        l1_subcell_pool_lcr_id, phycell_ul_subcell = extract_l1subpool_cell_relation(path_to_syscom_pdml)
        is_SysCom_correct = ((expected_phycell_ul_subcell == phycell_ul_subcell) and
                             (expected_l1_subcell_pool_lcr_id == l1_subcell_pool_lcr_id))
        logging.info("phycell_ul_subcell = %s" % (phycell_ul_subcell))
        logging.info("l1_subcell_pool_lcr_id = %s" % (l1_subcell_pool_lcr_id))
    except Exception as e:
        logException("verify_CellSetup_SysCom_Pdml_Traces", e)
    rbi.should_be_true(is_SysCom_correct)


@log_begin_end_func_name
def check_total_pooled_prbs(path_to_pickle,
                            list_of_pooled_subcells=[0, 2],
                            exclude_samples_for_analysis=1000,
                            list_of_non_pooled_subcells=[1],
                            expected_total_prbs=352,
                            expected_compliance_percentage=95,
                            name='dl_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_prb_allocation(df,
                                                                      list_of_pooled_subcells,
                                                                      list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("check_total_pooled_prbs: total_dl_prb_allocation_pooled_cells = %s"
                 % total_prb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


def check_total_pooled_prbsstreamcapa(path_to_pickle,
                                      list_of_pooled_subcells=[0, 2],
                                      exclude_samples_for_analysis=1000,
                                      list_of_non_pooled_subcells=[1],
                                      expected_total_prbsstream=1200,
                                      expected_compliance_percentage=95,
                                      name='dl_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_prb_allocation(df,
                                                                      list_of_pooled_subcells,
                                                                      list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_streamprb_allocation_pooled_cells = df_stat['StreamPrbCapa'].value_counts()
    logging.info("check_total_pooled_streamprbs: total_streamprb_allocation_pooled_cells = %s"
                 % total_streamprb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period, averaged_total_prb_pooled = validate_averaged_total_prbsstream_allocated(
        total_streamprb_allocation_pooled_cells.to_dict(), expected_total_prbsstream, expected_compliance_percentage,
        list_of_pooled_subcells)
    return all([result_total_prb_in_pooling_period]), averaged_total_prb_pooled


@log_begin_end_func_name
def check_total_pooled_ul_prbs(path_to_pickle,
                               list_of_pooled_subcells=[0, 2],
                               exclude_samples_for_analysis=1000,
                               list_of_non_pooled_subcells=[1],
                               expected_total_prbs=352,
                               expected_compliance_percentage=95,
                               name='ul_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_ul_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("check_total_pooled_prbs: total_ul_prb_allocation_pooled_cells = %s"
                 % total_prb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


def check_total_pooled_ulprbsstreamcapa(path_to_pickle,
                                        list_of_pooled_subcells=[0, 2],
                                        exclude_samples_for_analysis=1000,
                                        list_of_non_pooled_subcells=[1],
                                        expected_total_prbsstream=1200,
                                        expected_compliance_percentage=95,
                                        name='ul_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_ul_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_streamprb_allocation_pooled_cells = df_stat['StreamPrbCapa'].value_counts()
    logging.info("check_total_pooled_streamprbs: total_ul_streamprb_allocation_pooled_cells = %s"
                 % total_streamprb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period, averaged_total_prb_pooled = validate_averaged_total_prbsstream_allocated(
        total_streamprb_allocation_pooled_cells.to_dict(), expected_total_prbsstream, expected_compliance_percentage,
        list_of_pooled_subcells)
    return all([result_total_prb_in_pooling_period]), averaged_total_prb_pooled


@log_begin_end_func_name
def prepare_df_to_compute_average_prb_allocation(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def weighted_average(distribution, weights):
    return int(round(sum([distribution[i]*weights[i] for i in range(len(distribution))])/sum(weights), 2))


@log_begin_end_func_name
def validate_averaged_total_prbs_allocated(result, expected_total_prbs=352, expected_compliance_percentage=95):
    """Generates verdict to ensure the total prbs allocated per subcell matches the expected total prbs"""
    logging.info("result = %s" % result)
    logging.info("expected_total_prbs = %s" % expected_total_prbs)
    tolerance = int(expected_total_prbs * (100 - expected_compliance_percentage) / 100)
    defined_range_expected_total_prbs = list(range(expected_total_prbs - tolerance, expected_total_prbs + tolerance))
    logging.info("defined_range_expected_total_prbs = %s" % defined_range_expected_total_prbs)
    noise = int(len(result)/3) + 1
    logging.info("noise = %s and len(result) = %s" % (noise, len(result)))
    if len(result) > 2:
        averaged_total_prb_pooled = weighted_average(list(result.keys())[:noise], list(result.values())[:noise])
    else:
        averaged_total_prb_pooled = weighted_average(list(result.keys()), list(result.values()))
    logging.info("averaged_total_prb_pooled = %s" % averaged_total_prb_pooled)
    if averaged_total_prb_pooled in defined_range_expected_total_prbs:
        logging.info("Total [DL/UL] PRBs in pooled subcells matches expected total prbs")
        return True
    else:
        logging.error("Total [DL/UL] PRBs (%s) in pooled subcells does not match expected total prbs (%s)"
                      % (result, defined_range_expected_total_prbs))
        return False
    return averaged_total_prb_pooled


@log_begin_end_func_name
def validate_averaged_total_prbsstream_allocated(result, expected_total_prbs=352, expected_compliance_percentage=95,
                                                 list_of_pooled_subcells=[0, 2]):
    """Generates verdict to ensure the total prbs allocated per subcell matches the expected total prbs"""
    resultTest = False
    logging.info("result = %s" % result)
    logging.info("expected_total_prbsstream = %s" % expected_total_prbs)
    tolerance = int(expected_total_prbs * (100 - expected_compliance_percentage) / 100)
    defined_range_expected_total_prbs = list(range(expected_total_prbs - tolerance, expected_total_prbs + tolerance))
    logging.info("defined_range_expected_total_prbsstream = %s" % defined_range_expected_total_prbs)
    noise = int(len(result)/3) + 1
    logging.info("noise = %s and len(result) = %s" % (noise, len(result)))
    if len(result) > 2:
        averaged_total_prb_pooled = weighted_average(list(result.keys())[:noise], list(result.values())[:noise])
    else:
        averaged_total_prb_pooled = weighted_average(list(result.keys()), list(result.values()))
    # averaged_total_prb_pooled = weighted_average(list(result.keys())[:noise], list(result.values())[:noise])
    logging.info("averaged_total_dl_prbstream_pooled = %s" % averaged_total_prb_pooled)
    if averaged_total_prb_pooled in defined_range_expected_total_prbs:
        logging.info("Total [DL/UL] PRBs Stream in pooled subcells matches expected total prbs")
        resultTest = True
    else:
        logging.error(
            "Total [DL/UL] PRBs Stream (%s) in pooled subcells does not match expected total prbs (%s) for SubPool (%s}"
            % (result, defined_range_expected_total_prbs, list_of_pooled_subcells))
        resultTest = False
    return resultTest, averaged_total_prb_pooled


@log_begin_end_func_name
def prepare_df_to_compute_average_ul_prb_allocation(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['ulTdSchedSubcellData.numAllocCellPrbUl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_average_dl_prb_allocation(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_statistics(df_pooled_subcells):
    df_stat = pd.DataFrame()
    df_stat = df_pooled_subcells.copy()
    df_stat.dropna(subset=['AveragePRBAllocationPerSubcell'], inplace=True)
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['TotalPooledPRB'] = df_stat.groupby(level=[0, 1])['AveragePRBAllocationPerSubcell'].sum()
    df_stat['StreamPrbCapa'] = (df_stat.groupby(level=[0, 1])['AveragePRBAllocationPerSubcell'].sum())*4
    if True in df_stat.index.get_level_values(0).duplicated(keep=False):
        df_stat = df_stat[df_stat.index.get_level_values(0).duplicated(keep=False)]
    logging.info(df_stat.to_string())
    return df_stat


@log_begin_end_func_name
def run_load_based_prb_pooling_analysis_7113(path_to_pickle,
                                             subcell_expecting_higher_prb_allocation,
                                             list_of_pooled_subcells=[0, 2],
                                             exclude_samples_for_analysis=1000,
                                             list_of_non_pooled_subcells=[1],
                                             expected_total_prbs=352,
                                             expected_compliance_percentage=90):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_ul_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/ul_dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("CB007113 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def run_load_based_prb_pooling_analysis_8940(path_to_pickle,
                                             subcell_expecting_higher_prb_allocation,
                                             list_of_pooled_subcells=[0, 2],
                                             exclude_samples_for_analysis=1000,
                                             list_of_non_pooled_subcells=[1],
                                             expected_total_prbs=352,
                                             expected_compliance_percentage=90):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_dl_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/dl_dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("CB008940 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def prepare_df_to_compute_mumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells.to_string())
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells.to_string())
    return df_pooled_subcells


@log_begin_end_func_name
def run_mumimo_load_based_prb_pooling_analysis_dl(path_to_pickle,
                                                  list_of_pooled_subcells=[0, 2],
                                                  list_of_non_pooled_subcells=[1],
                                                  exclude_samples_for_analysis=1000,
                                                  expected_total_prbs=352,
                                                  expected_compliance_percentage=90,
                                                  name='dl_dataframe_for_manual_analysis_mumimo_spool1'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_mumimo_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_mumimo_info(df,
                                                           list_of_pooled_subcells,
                                                           list_of_non_pooled_subcells)
    # df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    # df_pooled_subcells.to_csv(str("%s/dl_dataframe_for_manual_analysis_mumimo.csv" % get_directory(path_to_pickle)),
    #                           sep=';')
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    # total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    # logging.info("CB008940 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def run_ulmumimo_load_based_prb_pooling_analysis_ul(path_to_pickle,
                                                    list_of_pooled_subcells=[0, 2],
                                                    list_of_non_pooled_subcells=[1],
                                                    exclude_samples_for_analysis=1000,
                                                    expected_total_prbs=352,
                                                    expected_compliance_percentage=90,
                                                    name='ul_dataframe_for_manual_analysis_ulmumimo_spool1'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_mumimo_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_ulmumimo_info(df,
                                                             list_of_pooled_subcells,
                                                             list_of_non_pooled_subcells)
    # df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    # df_pooled_subcells.to_csv(str("%s/dl_dataframe_for_manual_analysis_mumimo.csv" % get_directory(path_to_pickle)),
    #                           sep=';')
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    # total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    # logging.info("CB008940 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def prepare_df_to_compute_average_stream_prb(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    df_subcells = df
    logging.info(df_subcells.to_string())
    df_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlTdSchedSubcellData.subcellId'], inplace=True)
    df_subcells['AveragePRBAllocationPerSubcell'] = None
    df_subcells['AveragePRBAllocationPerSubcell'] = \
        df_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_subcells.to_string())
    return df_subcells


@log_begin_end_func_name
def check_total_stream_prbs(path_to_pickle,
                            list_of_pooled_subcells=[0, 2],
                            exclude_samples_for_analysis=1000,
                            list_of_non_pooled_subcells=[1],
                            expected_total_prbs=352,
                            expected_compliance_percentage=95,
                            name='dl_dataframe_for_manual_analysis_all_subcells'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_stream_prb(df,
                                                                  list_of_pooled_subcells,
                                                                  list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("check_total_pooled_prbs: total_dl_prb_allocation_pooled_cells = %s"
                 % total_prb_allocation_pooled_cells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


@log_begin_end_func_name
def verify_TTITraces_for_7113(expected_total_prbs=352):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    # ull1spcells[1]= [[0, 2, 4], [1]]
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_7113 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_7113 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        excluded_samples = 1000
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl, excluded_samples)
        run_load_based_prb_pooling_analysis_7113(path_to_ttitrace_pkl,
                                                 subcell_expecting_higher_prb_allocation=0,
                                                 # list_of_pooled_subcells=[0, 2],   => 8 X 4 DL MIMO case
                                                 # list_of_pooled_subcells=[0, 1, 4],  => 8 X 8 DL MIMO case
                                                 list_of_pooled_subcells=list_of_pooled_subcells,
                                                 # list_of_non_pooled_subcells=[1],  => 8 X 4 DL MIMO case
                                                 # list_of_non_pooled_subcells=[2],    => 8 X 8 DL MIMO case
                                                 list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                 exclude_samples_for_analysis=excluded_samples,
                                                 expected_total_prbs=int(expected_total_prbs))
        # logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_7113", e)
    # rbi.should_be_true(is_TTITrace_correct)


def verify_TTITraces_for_8940(expected_total_prbs=352):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    # dll1spcells[1]=[[0,2,4][1]]
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_8940 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_8940 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        excluded_samples = 1000
        run_load_based_prb_pooling_analysis_8940(path_to_ttitrace_pkl,
                                                 subcell_expecting_higher_prb_allocation=0,
                                                 # list_of_pooled_subcells=[0, 1, 4, 5],  => 8 X 8 DL MIMO case
                                                 # list_of_pooled_subcells=[0, 2],    => 8 X 4 DL MIMO case
                                                 list_of_pooled_subcells=list_of_pooled_subcells,
                                                 # list_of_non_pooled_subcells=[2, 3],  => 8 X 8 DL MIMO case
                                                 # list_of_non_pooled_subcells=[1],  => 8 X 4 DL MIMO case
                                                 list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                 exclude_samples_for_analysis=excluded_samples,
                                                 expected_total_prbs=int(expected_total_prbs))
        # logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_8940", e)


@log_begin_end_func_name
def verify_TTITraces_for_CB008940_C1(expected_avg_total_prbs_spool1=546, expected_avg_total_prbs_spool2=78,
                                     expected_avg_total_prbsstream_spool1=2100,
                                     expected_avg_total_prbsstream_spool2=310):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_CB008940_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_CB008940_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        logging.basicConfig(level=logging.DEBUG)
        # expected_total_prbs = expected_avg_total_prbs_spool1  # <-- Subpool1
        # bypass acceptance criteria on prbs for spool1, keep only acceptance criteria on prbstream
        # is_TTITrace_correct_p1 = check_total_pooled_prbs(path_to_ttitrace_pkl,
        #                                                  list_of_pooled_subcells=list_of_pooled_subcells,
        #                                                  list_of_non_pooled_subcells=list_of_non_pooled_subcells,
        #                                                  exclude_samples_for_analysis=1000,
        #                                                  expected_total_prbs=expected_total_prbs,
        #                                                  expected_compliance_percentage=95,
        #                                                  name='dl_dataframe_for_manual_analysis_spool1')
        # logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # expected_total_prbs = 64  # <-- Subpool2 / TC 8940-L MicroDtx
        expected_total_prbs = expected_avg_total_prbs_spool2  # <-- Subpool2
        # bypass acceptance criteria on prbs for spool2, keep only acceptance criteria on prbstream
        # is_TTITrace_correct_p2 = check_total_pooled_prbs(path_to_ttitrace_pkl,
        #                                                  list_of_pooled_subcells=list_of_non_pooled_subcells,
        #                                                  list_of_non_pooled_subcells=list_of_pooled_subcells,
        #                                                  exclude_samples_for_analysis=1000,
        #                                                  expected_total_prbs=expected_total_prbs,
        #                                                  expected_compliance_percentage=70,
        #                                                  name='dl_dataframe_for_manual_analysis_spool2')
        # logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool1  # <-- Subpool1
        is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=95,
                                              name='dl_dataframe_for_manual_analysis_spool1')
        print("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
        print("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB008940_C1: averaged_total_dl_prbstream_pooled spool1'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))
        # expected_total_prbsstream = 240  # <-- Subpool2 / TC 8940-L MicroDtx / wo GBR
        expected_total_prbsstream = expected_avg_total_prbsstream_spool2  # <-- Subpool2
        is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_non_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=70,
                                              name='dl_dataframe_for_manual_analysis_spool2')
        print("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
        print("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB008940_C1: averaged_total_dl_prbstream_pooled spool2'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))
    except Exception as e:
        logException("verify_TTITraces_for_CB008940_C1", e)
    #  keep only acceptance criteria on prbstream
    rbi.should_be_true(is_TTITrace_correct_p3 and is_TTITrace_correct_p4)
    # rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
    #                   is_TTITrace_correct_p3 and is_TTITrace_correct_p4)


@log_begin_end_func_name
def verify_TTITraces_for_CB008940_C2(expected_avg_total_prbsstream_spool1=2100,
                                     expected_avg_total_prbsstream_spool2=300,
                                     min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    resultTest = False
    sum = 0
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_CB008940_C2 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_CB008940_C2 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        # expected_total_prbs = int(expected_avg_total_prbsstream_spool1 / 4)
        # is_TTITrace_correct_p0 = check_total_stream_prbs(path_to_ttitrace_pkl,
        #                                                  list_of_pooled_subcells=list_of_pooled_subcells,
        #                                                  list_of_non_pooled_subcells=list_of_non_pooled_subcells,
        #                                                  exclude_samples_for_analysis=1000,
        #                                                  expected_total_prbs=expected_total_prbs,
        #                                                  expected_compliance_percentage=70,
        #                                                  name='dl_dataframe_for_manual_analysis_all_subcells')
        # logging.info("verify_TTITraces_for_CB008940_C2: is_TTITrace_correct_p0 = %s" % (is_TTITrace_correct_p0))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool1  # <-- Subpool1
        # expected_total_prbsstream = 2100  # <-- Subpool1
        is_TTITrace_correct_p1, averaged_total_prbstream_pooled_spool1 = \
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=95,
                                              name='dl_dataframe_for_manual_analysis_spool1')
        print("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        print("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
        msg = 'verify_TTITraces_for_CB008940_C2: averaged_total_prbstream_spool1'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool1))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool2  # <-- Subpool1
        # expected_total_prbsstream = 310  # <-- Subpool1
        is_TTITrace_correct_p2, averaged_total_prbstream_pooled_spool2 = \
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_non_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=70,
                                              name='dl_dataframe_for_manual_analysis_spool2')
        print("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        print("averaged_total_prbstream_spool2 = %s" % (averaged_total_prbstream_pooled_spool2))
        msg = 'verify_TTITraces_for_CB008940_C2: averaged_total_prbstream_spool2'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool2))
        resultTest = False
        sum = averaged_total_prbstream_pooled_spool1 + averaged_total_prbstream_pooled_spool2
        if (sum >= min_total_prbstream and sum <= max_total_prbstream):
            resultTest = True
        else:
            resultTest = False
        print("verify_TTITraces_for_CB008940_C2: averaged_total_prbstream resultTest = %s" % (resultTest))
        msg = 'verify_TTITraces_for_CB008940_C2: Check averaged_total_prbstream resultTest: '
        datedConsole(getHeaderLine(msg, resultTest))
    except Exception as e:
        logException("verify_TTITraces_for_CB008940_C2", e)
    # rbi.should_be_true(resultTest)
    if not resultTest:
        current_time = rbi.get_time()
        log = "%s verify_TTITraces_for_CB008940_C2 NOK"
        log = log + " sum_prbstream = %s min_total_prbstream = %s max_total_prbstream = %s"
        rbi.log(log % (current_time, sum, min_total_prbstream, max_total_prbstream), level="WARN", console="yes")
        print(log % (current_time, sum, min_total_prbstream, max_total_prbstream))


@log_begin_end_func_name
def verify_TTITraces_for_MUMIMO_C1(expected_avg_total_prbsstream_spool1=2100,
                                   expected_avg_total_prbsstream_spool2=300,
                                   min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_MUMIMO_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_MUMIMO_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = int(expected_avg_total_prbsstream_spool1 / 4)    # <-- Subpool1
        is_TTITrace_correct_p0 =\
            run_mumimo_load_based_prb_pooling_analysis_dl(path_to_ttitrace_pkl,
                                                          list_of_pooled_subcells=list_of_pooled_subcells,
                                                          list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                          exclude_samples_for_analysis=1000,
                                                          expected_total_prbs=expected_total_prbs,
                                                          expected_compliance_percentage=95,
                                                          name='dl_dataframe_for_manual_analysis_mumimo_spool1')
        logging.info("verify_TTITraces_for_MUMIMO_C1: is_TTITrace_correct_p0 = %s" % (is_TTITrace_correct_p0))
        expected_total_prbs = int(expected_avg_total_prbsstream_spool2 / 4)    # <-- Subpool2
        is_TTITrace_correct_p1 = \
            run_mumimo_load_based_prb_pooling_analysis_dl(path_to_ttitrace_pkl,
                                                          list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                          list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                          exclude_samples_for_analysis=1000,
                                                          expected_total_prbs=expected_total_prbs,
                                                          expected_compliance_percentage=70,
                                                          name='dl_dataframe_for_manual_analysis_mumimo_spool2')
        logging.info("verify_TTITraces_for_MUMIMO_C1: is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # logging.info("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
        # msg = 'verify_TTITraces_for_MUMIMO_C1: averaged_total_prbstream_spool1'
        # datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool1))
    except Exception as e:
        logException("verify_TTITraces_for_MUMIMO_C1", e)
    # rbi.should_be_true(resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_ULMUMIMO_C1(expected_avg_total_prbsstream_spool1=2100,
                                     expected_avg_total_prbsstream_spool2=300,
                                     min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_ULMUMIMO_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_ULMUMIMO_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = int(expected_avg_total_prbsstream_spool1 / 4)    # <-- Subpool1
        is_TTITrace_correct_p0 =\
            run_ulmumimo_load_based_prb_pooling_analysis_ul(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=95,
                                                            name='ul_dataframe_for_manual_analysis_ulmumimo_spool1')
        logging.info("verify_TTITraces_for_MUMIMO_C1: is_TTITrace_correct_p0 = %s" % (is_TTITrace_correct_p0))
        expected_total_prbs = int(expected_avg_total_prbsstream_spool2 / 4)    # <-- Subpool2
        is_TTITrace_correct_p1 = \
            run_ulmumimo_load_based_prb_pooling_analysis_ul(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=70,
                                                            name='ul_dataframe_for_manual_analysis_ulmumimo_spool2')
        logging.info("verify_TTITraces_for_ULMUMIMO_C1: is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # logging.info("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
        # msg = 'verify_TTITraces_for_ULMUMIMO_C1: averaged_total_prbstream_spool1'
        # datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool1))
    except Exception as e:
        logException("verify_TTITraces_for_ULMUMIMO_C1", e)
    # rbi.should_be_true(resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_CB007113_C1(min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 205 <-- big Subpool1
    #   cell1 gets 205 <-- small Subpool2
    #   cell2 gets 205 <-- big Subpool1
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 69
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_CB007113_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_CB007113_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = 546  # <-- big Subpool1
        is_TTITrace_correct_p1 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=95,
                                                            name='ul_dataframe_for_manual_analysis_spool1')
        logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        expected_total_prbs = 273  # <-- small Subpool2
        is_TTITrace_correct_p2 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=70,
                                                            name='ul_dataframe_for_manual_analysis_spool2')
        logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        expected_total_prbsstream = 2184  # <-- big Subpool1
        is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=95,
                                                name='ul_dataframe_for_manual_analysis_spool1')
        logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
        logging.info("averaged_total_ul_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool1', averaged_total_prbstream_pooled))
        averaged_total_prbstream_pooled_spool1 = averaged_total_prbstream_pooled
        expected_total_prbsstream = 1092  # <-- small Subpool2
        is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=70,
                                                name='ul_dataframe_for_manual_analysis_spool2')
        logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool2', averaged_total_prbstream_pooled))
        averaged_total_prbstream_pooled_spool2 = averaged_total_prbstream_pooled
        sum = averaged_total_prbstream_pooled_spool1 + averaged_total_prbstream_pooled_spool2
        if (sum >= min_total_prbstream and sum <= max_total_prbstream):
            resultTest = True
        else:
            resultTest = False
        logging.info("verify_TTITraces_for_CB007113_C1: averaged_total_prbstream resultTest = %s" % (resultTest))
        msg = 'verify_TTITraces_for_CB007113_C1: Check averaged_total_prbstream resultTest: '
        datedConsole(getHeaderLine(msg, resultTest))
    except Exception as e:
        logException("verify_TTITraces_for_CB007113_C1", e)
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                       is_TTITrace_correct_p3 and is_TTITrace_correct_p4 and resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_CB009836_A_1(path_to_pickle,
                                      name='dl_df_for_manual_analysis_all_subcells_CB009836_A1'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB009836_A1.pkl'
    filter_valid_events_and_check_CB009836_A_1(path_to_pickle=path_to_ttitrace_pkl,
                                               target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB009836_A_2(path_to_pickle,
                                      name='dl_df_for_manual_analysis_all_subcells_CB009836_A2'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB009836_A2.pkl'
    filter_valid_events_and_check_CB009836_A_2(path_to_pickle=path_to_ttitrace_pkl,
                                               target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_Dl_PrbAssign(path_to_pickle,
                                      name='dl_df_for_manual_analysis_all_subcells_DlPrbAssign'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_DlPrbAssign.pkl'
    filter_valid_events_and_check_DlPrbAssign(path_to_pickle=path_to_ttitrace_pkl,
                                              target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_B_C1(path_to_pickle,
                                       name='ul_df_for_manual_analysis_all_subcells_CB009890_B'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB009890_B.pkl'
    filter_valid_events_and_check_CB009890_UL(path_to_pickle=path_to_ttitrace_pkl,
                                              target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_B_C2(path_to_pickle, maxNumUlSubcellL1Pool=6, maxNumUlSubcellL1Sp=4):
    path_to_ttitrace_pkl = path_to_pickle
    check_CB009890_UL(path_to_pickle=path_to_ttitrace_pkl, maxNumUlSubcellL1Pool=maxNumUlSubcellL1Pool,
                      maxNumUlSubcellL1Sp=maxNumUlSubcellL1Sp)


@log_begin_end_func_name
def get_csirs_resources_value(csirsgroups, cellcsirs_slotoffset, cellid=16385, cellnidd='NRCELL-1'):
    # csirsGroups is a dict
    # get csirsPoolingGroupId from CellId and csirsGroups
    # (slotOffset % 20) and startingSymbolIndex,startingSymbolIndex+1
    # get NRCELL-1:periodicCsiAcquisition:maxCsirsNumber to determine RS1, RS2 or RS3 !!!
    global rs_found
    rs_found = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_cell_name_cell = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/' + cellnidd
    logging.info("get_csirs_resources_value: mr_nr_cell_name_cell = %s" % (mr_nr_cell_name_cell))
    logging.info("get_csirs_resources_value: csirsgroups = %s" % (csirsgroups))
    periodicCsiAcquisition_params_list = ['csiReportPeriodicity', 'csirsNumberWithinReportPeriod_Set1', 'csirsPower',
                                          'maxCsirsNumber', 'scramblingIdStep']
    periodicCsiAcquisition = get_feature_paramters_from_scf(path_to_scf_xml,
                                                            periodicCsiAcquisition_params_list,
                                                            mr_nr_cell_name_cell,
                                                            'periodicCsiAcquisition')
    maxCsirsNumber = periodicCsiAcquisition['maxCsirsNumber']
    logging.info("get_csirs_resources_value: periodicCsiAcquisition = %s" % periodicCsiAcquisition)
    logging.info("get_csirs_resources_value: maxCsirsNumber = %s" % maxCsirsNumber)
    csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == cellid][0]
    logging.info("get_csirs_resources_value: csirsgroup = %s" % (csirsgroup))
    # resourceset = \
    #     [sub['resource_set'] for sub in cellcsirs_slotoffset if sub['csirsPoolingGroupId'] == csirsgroup]
    # when using createCellCsiRs_9836_v3
    resourceset = \
        [sub['resource_set'] for sub in cellcsirs_slotoffset if sub['cellId'] == cellid]
    logging.info("get_csirs_resources_value: resourceset = %s" % resourceset)
    # logging.info("get_csirs_resources_value: type resourceset = %s" % (type(resourceset)))
    for sub in resourceset:
        logging.info("get_csirs_resources_value: sub = %s" % sub)
        # logging.info("get_csirs_resources_value: type sub = %s" % (type(sub)))
        for resourceset_elt in sub:
            logging.info("get_csirs_resources_value: sub = %s" % resourceset_elt)
            # logging.info("get_csirs_resources_value: type sub = %s" % (type(resourceset_elt)))
            logging.info("get_csirs_resources_value: len sub = %s" % (len(resourceset_elt['res'])))
            if len(resourceset_elt['res']) == 4:
                # case resource Set 4
                resourceset_0 = resourceset_elt['res'][0]
                resourceset_slotOffset = resourceset_0['slotOffset']
                resourceset_startingSymbolIndex = resourceset_0['startingSymbolIndex']
                logging.info("get_csirs_resources_value: resourceset_slotOffset = %s" % resourceset_slotOffset)
                resourceset_2 = resourceset_elt['res'][2]
                resourceset_slotOffset = resourceset_2['slotOffset']
                resourceset_startingSymbolIndex_2 = resourceset_2['startingSymbolIndex']
                text = "get_csirs_resources_value: resourceset_startingSymbolIndex = %s"
                logging.info(text % resourceset_startingSymbolIndex)
                text = "get_csirs_resources_value: resourceset_startingSymbolIndex_2 = %s"
                logging.info(text % resourceset_startingSymbolIndex_2)
                startingSymbolIndex = resourceset_startingSymbolIndex
                startingSymbolIndex_1 = startingSymbolIndex + 1
                startingSymbolIndex_2 = resourceset_startingSymbolIndex_2
                startingSymbolIndex_3 = startingSymbolIndex_2 + 1
                list_start_symb = list((startingSymbolIndex, startingSymbolIndex_1,
                                        startingSymbolIndex_2, startingSymbolIndex_3))
                logging.info("get_csirs_resources_value: break maxCsirsNumber == %s" % maxCsirsNumber)
                maxCsirsNumber_i = int(maxCsirsNumber)
                if maxCsirsNumber_i == 4:
                    logging.info("get_csirs_resources_value: break with maxCsirsNumber == 4")
                    rs_found = True
                    break
            elif len(resourceset_elt['res']) == 2:
                # case resource Set 2
                resourceset_0 = resourceset_elt['res'][0]
                resourceset_slotOffset = resourceset_0['slotOffset']
                resourceset_startingSymbolIndex = resourceset_0['startingSymbolIndex']
                logging.info("get_csirs_resources_value: resourceset_slotOffset = %s" % resourceset_slotOffset)
                resourceset_2 = resourceset_elt['res'][1]
                resourceset_slotOffset = resourceset_2['slotOffset']
                resourceset_startingSymbolIndex_2 = resourceset_2['startingSymbolIndex']
                text = "get_csirs_resources_value: resourceset_startingSymbolIndex = %s"
                logging.info(text % resourceset_startingSymbolIndex)
                text = "verify_TTITraces_for_csirs: resourceset_startingSymbolIndex_2 = %s"
                logging.info(text % resourceset_startingSymbolIndex_2)
                startingSymbolIndex = resourceset_startingSymbolIndex
                startingSymbolIndex_1 = startingSymbolIndex + 1
                list_start_symb = list((startingSymbolIndex, startingSymbolIndex_1))
                logging.info("get_csirs_resources_value: break maxCsirsNumber == %s" % maxCsirsNumber)
                maxCsirsNumber_i = int(maxCsirsNumber)
                if maxCsirsNumber_i == 2:
                    logging.info("get_csirs_resources_value: break with maxCsirsNumber == 2")
                    rs_found = True
                    break
            elif len(resourceset_elt['res']) == 1:
                # case resource Set 1
                resourceset_0 = resourceset_elt['res'][0]
                resourceset_slotOffset = resourceset_0['slotOffset']
                resourceset_startingSymbolIndex = resourceset_0['startingSymbolIndex']
                text = "get_csirs_resources_value: resourceset_slotOffset = %s"
                logging.info(text % resourceset_slotOffset)
                text = "get_csirs_resources_value: resourceset_startingSymbolIndex = %s"
                logging.info(text % resourceset_startingSymbolIndex)
                startingSymbolIndex = resourceset_startingSymbolIndex
                startingSymbolIndex_1 = startingSymbolIndex + 1
                list_start_symb = list((startingSymbolIndex, startingSymbolIndex_1))
                logging.info("get_csirs_resources_value: break maxCsirsNumber == %s" % maxCsirsNumber)
                maxCsirsNumber_i = int(maxCsirsNumber)
                if maxCsirsNumber_i == 1:
                    logging.info("get_csirs_resources_value: break with maxCsirsNumber == 1")
                    rs_found = True
                    break
        if rs_found:
            logging.info("get_csirs_resources_value: second break")
            break
    resourceset_slotOffset = resourceset_slotOffset % 20
    text = "get_csirs_resources_value: Input resourceset_slotOffset = %s"
    logging.info(text % resourceset_slotOffset)
    text = "get_csirs_resources_value: Input list_start_symb = %s"
    logging.info(text % list_start_symb)
    return resourceset_slotOffset, list_start_symb


@log_begin_end_func_name
def verify_TTITraces_for_csirs_6cells():
    """path_to_ttitrace_pkl, sorted_csirsGroups, sorted_cellcsirs_slotoffset"""
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    is_TTITrace_correct_p5 = False
    is_TTITrace_correct_p6 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    csirsgroups = rbi.get_variable_value("${sorted_csirsGroups}")
    logging.info("verify_TTITraces_for_csirs_6cells: csirsgroups = %s" % csirsgroups)
    cellcsirs_slotoffset = rbi.get_variable_value("${sorted_cellcsirs_slotoffset}")
    msg = "verify_TTITraces_for_csirs_6cells csirsgroups={}"
    datedConsole(msg.format(csirsgroups))
    try:
        excluded_samples = 1000
        # CellId = 50, RS3
        nrCellId = 50
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16385,
                                                                            cellnidd='NRCELL-1')
        is_TTITrace_correct_p1 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p1 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p1))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p1={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p1))
        # cellId = 51 , RS1
        nrCellId = 51
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16386,
                                                                            cellnidd='NRCELL-2')
        is_TTITrace_correct_p2 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p2 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p2))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p2={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p2))
        # cellId = 52 , RS1
        nrCellId = 52
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16387,
                                                                            cellnidd='NRCELL-3')
        is_TTITrace_correct_p3 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p3 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p3))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p3={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p3))
        # cellId = 53 , RS3
        nrCellId = 53
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16388,
                                                                            cellnidd='NRCELL-4')
        is_TTITrace_correct_p4 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p4 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p4))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p4={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p4))
        # cellId = 54 , RS3
        nrCellId = 54
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16389,
                                                                            cellnidd='NRCELL-5')
        is_TTITrace_correct_p5 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p5 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p5))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p5={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p5))
        # cellId = 55 , RS3
        nrCellId = 55
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16390,
                                                                            cellnidd='NRCELL-6')
        is_TTITrace_correct_p6 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p6 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p6))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p6={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p6))
        combined_slots_stats, \
            combined_start_symbol_stats_Percentage = run_csirs_stat_analysis_dl(path_to_pickle=path_to_ttitrace_pkl)
        msg = 'combined_slots_stats'
        datedConsole(getHeaderLine(msg, combined_slots_stats))
        msg = 'combined_start_symbol_stats_Percentage'
        datedConsole(getHeaderLine(msg, combined_start_symbol_stats_Percentage))
    except Exception as e:
        details = traceback.format_exc()
        rbi.log_to_console("debug: Failure in verify_TTITraces_for_csirs_6cells. traceback = %s" % details)
        rbi.log("debug: Failure in verify_TTITraces_for_csirs_6cells. traceback = %s" % details)
        logException("verify_TTITraces_for_csirs_6cells", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                                               is_TTITrace_correct_p3 and is_TTITrace_correct_p4 and
                                               is_TTITrace_correct_p5 and is_TTITrace_correct_p6))
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                       is_TTITrace_correct_p3 and is_TTITrace_correct_p4 and
                       is_TTITrace_correct_p5 and is_TTITrace_correct_p6)


@log_begin_end_func_name
def verify_TTITraces_for_csirs_4cells():
    """path_to_ttitrace_pkl, sorted_csirsGroups, sorted_cellcsirs_slotoffset"""
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    csirsgroups = rbi.get_variable_value("${sorted_csirsGroups}")
    cellcsirs_slotoffset = rbi.get_variable_value("${sorted_cellcsirs_slotoffset}")
    msg = "verify_TTITraces_for_csirs_4cells csirsgroups={}"
    datedConsole(msg.format(csirsgroups))
    try:
        excluded_samples = 1000
        # CellId = 50, RS3
        nrCellId = 50
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16385,
                                                                            cellnidd='NRCELL-1')
        is_TTITrace_correct_p1 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p1 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p1))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p1={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p1))
        # cellId = 51 , RS1
        nrCellId = 51
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16386,
                                                                            cellnidd='NRCELL-2')
        is_TTITrace_correct_p2 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p2 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p2))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p2={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p2))
        # cellId = 52 , RS1
        nrCellId = 52
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16387,
                                                                            cellnidd='NRCELL-3')
        is_TTITrace_correct_p3 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p3 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p3))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p3={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p3))
        # cellId = 53 , RS3
        nrCellId = 53
        resourceset_slotOffset, list_start_symb = get_csirs_resources_value(csirsgroups=csirsgroups,
                                                                            cellcsirs_slotoffset=cellcsirs_slotoffset,
                                                                            cellid=16388,
                                                                            cellnidd='NRCELL-4')
        is_TTITrace_correct_p4 = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                                       physCellId=nrCellId,
                                                       slot=resourceset_slotOffset,
                                                       list_start_symb=list_start_symb)
        logging.info("verify_TTITraces_for_csirs[nrCellId=%s]: is_TTITrace_correct_p4 = %s" % (nrCellId,
                                                                                               is_TTITrace_correct_p4))
        msg = "verify_TTITraces_for_csirs[nrCellId={}]: is_TTITrace_correct_p4={}"
        datedConsole(msg.format(nrCellId, is_TTITrace_correct_p4))
        combined_slots_stats, \
            combined_start_symbol_stats_Percentage = run_csirs_stat_analysis_dl(path_to_pickle=path_to_ttitrace_pkl)
        msg = 'combined_slots_stats'
        datedConsole(getHeaderLine(msg, combined_slots_stats))
        msg = 'combined_start_symbol_stats_Percentage'
        datedConsole(getHeaderLine(msg, combined_start_symbol_stats_Percentage))
    except Exception as e:
        details = traceback.format_exc()
        rbi.log_to_console("debug: Failure in verify_TTITraces_for_csirs_4cells. traceback = %s" % details)
        rbi.log("debug: Failure in verify_TTITraces_for_csirs_4cells. traceback = %s" % details)
        logException("verify_TTITraces_for_csirs_4cells", e)
    rbi.set_test_variable("${TestResult}", str(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                                               is_TTITrace_correct_p3 and is_TTITrace_correct_p4))
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                       is_TTITrace_correct_p3 and is_TTITrace_correct_p4)


def get_csirsPoolingGroupId(cell=16385, csirsgroups=None):
    """
    Retrieves the csirsPoolingGroupId associated with a specific cell.

    Args:
        cell (int): The cell ID for which to retrieve the csirsPoolingGroupId. Default is 16385.
        sorted_csirsGroups (list[dict]): A list of dictionaries representing groups with keys 'cell',
            'csirsPoolingGroupId', and 'lcrId'.
    Raises:
        ValueError: If the provided cell value is not a positive integer.
    Returns:
        set: A set containing the unique csirsPoolingGroupId values associated with the specified cell.

    Example:
        sorted_csirsGroups = [
            {'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
            {'cell': 16386, 'csirsPoolingGroupId': 1, 'lcrId': 2},
            # ... other dictionaries ...
        ]
        csirs_ids = get_csirsPoolingGroupId(cell=16385, sorted_csirsGroups=sorted_csirsGroups)
        print(csirs_ids)  # Output: {0}

    Note:
        - The function filters the dictionaries in sorted_csirsGroups based on the provided cell value.
        - It returns a set of unique csirsPoolingGroupId values.
    """
    if not isinstance(cell, int) or cell < 0:
        raise ValueError("Cell ID must be a positive integer.")

    if not csirsgroups:
        print("Warning: Empty list of sorted_csirsGroups provided.")

    # msg = "get_csirsPoolingGroupId [csirsgroups={}]"
    # datedConsole(msg.format(csirsgroups))

    for item in csirsgroups:
        # msg = "get_csirsPoolingGroupId[nrCellId={}]: csirsPoolingGroupId={}"
        # datedConsole(msg.format(item['cell'], item['csirsPoolingGroupId']))
        if isinstance(item['cell'], str):
            cell_int = int(item['cell'])
        else:
            cell_int = item['cell']
        if cell_int == cell:
            csirsPoolingGroupId = item['csirsPoolingGroupId']
            break
    # csirsPoolingGroupId = set([a['csirsPoolingGroupId'] for a in csirsgroups if a['cell'] == cell])
    # msg = "csirsPoolingGroupId={}"
    # datedConsole(msg.format(csirsPoolingGroupId))
    return csirsPoolingGroupId


@log_begin_end_func_name
def verify_trs_and_csirs(normalized_df, physCellId=50, subcellId=0,
                         list_slot_trs=None, list_slot_csirs=None, folder_path=None):
    """
    Verifies TRS and CSIRs.

    Args:
        normalized_df (pandas.DataFrame): A DataFrame containing normalized data.
        physCellId (int, optional): Physical cell ID. Default is 50.
        subcellId (int, optional): Subcell ID. Default is 0.
        list_slot_trs (list, optional): List of TRS slots to verify. Default is None.
        list_slot_csirs (list, optional): List of CSIRs slots to verify. Default is None.
        folder_path (str, optional): Path to the folder containing .trs files. Default is None.

    Returns:
        bool: True if verification is successful, False otherwise.
    """
    is_TTITrace_correct_p1 = False
    try:
        trscsirs = []
        trscsirs_per_cellId = []

        for slot_trs in list_slot_trs:
            trscsirs = check_trs(normalized_df=normalized_df, physCellId=physCellId, subcellid=subcellId,
                                 trsinfo=1, slot=slot_trs, folder_path=folder_path, trscsirs=trscsirs)
        # msg = 'trscsirs subcellid=' + str(subcellId)
        # datedConsole(getHeaderLine(msg, trscsirs))
        logging.info("verify_trs_and_csirs[nrCellId=%s]: trscsirs = %s" % (physCellId, trscsirs))
        msg = "verify_trs_and_csirs[nrCellId={}]: trscsirs={}"
        datedConsole(msg.format(physCellId, trscsirs))
        trscsirs_per_cellId_elt = {'PhyCellId': physCellId, 'trscsirs': trscsirs}
        trscsirs_per_cellId.append(trscsirs_per_cellId_elt)
        # df_cell_trs = normalized_df.where(normalized_df['TRSInfo'].astype(int) == 1).dropna()
        # path_to_ttitrace_pkl = write_df_to_pickle(df_cell_trs, target_path='/tmp/normalized_df.pkl')
        # combined_slots_stats, combined_start_symbol_stats_Percentage = \
        #     run_csirs_stat_analysis_pcap_dl(path_to_pickle=path_to_ttitrace_pkl)
        # msg = 'combined_slots_stats'
        # datedConsole(getHeaderLine(msg, combined_slots_stats))
        # msg = 'combined_start_symbol_stats_Percentage'
        # datedConsole(getHeaderLine(msg, combined_start_symbol_stats_Percentage))
    except Exception as e:
        logException("verify_trs_and_csirs", e)
    return trscsirs_per_cellId_elt


def verify_trs_stat_analysis_pcap_dl(normalized_df):
    """
    Verifies TRS and CSIRs slot and StartSymbol statistical analysis.

    Args:
        normalized_df (pandas.DataFrame): A DataFrame containing normalized data.
            Expected columns: ['TRSInfo', 'SubcellID', 'Slot', 'StartSymbol']
    Returns:
        bool: True if statistical analysis passes, False otherwise.
    """
    is_TTITrace_correct_p1 = False
    try:
        # Input validation
        # if not isinstance(normalized_df, pd.DataFrame):
        #     raise ValueError("Input must be a pandas DataFrame.")

        required_columns = ['TRSInfo', 'SubcellID', 'Slot', 'StartSymbol']
        missing_columns = set(required_columns) - set(normalized_df.columns)
        if missing_columns:
            raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")

        df_cell_trs = normalized_df.where(normalized_df['TRSInfo'].astype(int) == 1).dropna()
        path_to_ttitrace_pkl = write_df_to_pickle(df_cell_trs, target_path='/tmp/normalized_df.pkl')
        combined_slots_stats, combined_start_symbol_stats_Percentage = \
            run_csirs_stat_analysis_pcap_dl(path_to_pickle=path_to_ttitrace_pkl)
        msg = 'combined_slots_stats'
        datedConsole(getHeaderLine(msg, combined_slots_stats))
        msg = 'combined_start_symbol_stats_Percentage'
        datedConsole(getHeaderLine(msg, combined_start_symbol_stats_Percentage))
        # If all checks pass, return True
        return True
    except Exception as e:
        logException("Error in verify_trs_stat_analysis_pcap_dl:", e)
        return False
    return is_TTITrace_correct_p1


@log_begin_end_func_name
def check_trs_periodicity(periodicity=80, trscsirs_cells=None):
    """
        Verifies the periodicity of TRS.

        Args:
            periodicity (int, optional): Expected periodicity value. Default is 80.
            trscsirs_cells (list or None, optional): List of TRS cells to verify. Default is None.

        Returns:
            bool: True if the periodicity is within an acceptable range, False otherwise.
    """
    # Validate input parameters
    if not isinstance(periodicity, int) or periodicity <= 0:
        raise ValueError("Periodicity must be a positive integer.")

    if trscsirs_cells is not None and not isinstance(trscsirs_cells, list):
        raise TypeError("trscsirs_cells must be a list or None.")

    res = set()
    is_PCAPTrace_correct_p = True
    for trscsirs_cell in trscsirs_cells:
        for trscsirs_elt in trscsirs_cell['trscsirs']:
            # rbi.log(trscsirs_elt, 'INFO')
            if periodicity not in trscsirs_elt['period']:
                res.update(trscsirs_elt['period'])
    if res:
        is_PCAPTrace_correct_p = False  # set is not empty
    rbi.set_test_variable("${TestResult}", str(is_PCAPTrace_correct_p))
    rbi.should_be_true(is_PCAPTrace_correct_p)
    return is_PCAPTrace_correct_p


@log_begin_end_func_name
def run_zab_stat_analysis_dl(path_to_pickle,
                             exclude_samples_for_analysis=1000):
    """Check zab Stats"""
    df = load_dataframe(path_to_pickle=path_to_pickle)
    logging.info("run_zab_stat_analysis_dl: length of df = %s" % len(df))
    len_df = len(df)
    if len_df > 3*exclude_samples_for_analysis:
        df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)

    global filtered_df_slot
    filtered_df_slot = df[['physCellId', 'hasZab']].dropna()
    rbi.log('filtered_df_slot: {}'.format(filtered_df_slot))

    global zab_stats
    zab_stats = filtered_df_slot.value_counts().reset_index()
    """Identify total events per defined group in trace"""
    # grouped by physCellId
    global total_events_grouped
    total_events_grouped = filtered_df_slot.groupby('physCellId').size()
    """Add new columns to df"""
    zab_stats['Total Count'] = zab_stats['physCellId'].map(total_events_grouped)
    zab_stats['Percentage'] = (zab_stats['count'] / zab_stats['Total Count']) * 100
    """Combine stats"""
    global combined_zab_stats
    combined_zab_stats = zab_stats.pivot(index='physCellId', columns='hasZab', values=['count', 'Percentage'])
    combined_zab_stats.fillna(0, inplace=True)
    rbi.log('combined_zab_stats: {}'.format(combined_zab_stats))

    combined_zab_stats_Percentage = zab_stats.pivot(index='physCellId',
                                                    columns='hasZab',
                                                    values=['Percentage'])
    combined_zab_stats_Percentage.fillna(0, inplace=True)
    rbi.log('combined_zab_stats_Percentage: {}'.format(combined_zab_stats_Percentage))

    return combined_zab_stats, combined_zab_stats_Percentage


@log_begin_end_func_name
def verify_TTITraces_for_Zab_Privilege(path_to_pickle,
                                       name='dl_df_for_manual_analysis_all_cells_ZAB',
                                       physCellId=50,
                                       threshold_ok=100,
                                       threshold_err=0):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_ZAB.pkl'
    filter_valid_events_has_zab_privilege(path_to_pickle=path_to_ttitrace_pkl,
                                          target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')

    # df check / post-processing...
    try:
        required_columns = ['physCellId', 'hasZab']
        missing_columns = set(required_columns) - set(df.columns)
        if missing_columns:
            raise ValueError(f"Missing required columns: {', '.join(missing_columns)}")

        df_cell_zab = df.where(df['physCellId'].astype(int) == physCellId).dropna()
        df_ToCheck = df_cell_zab
        path_to_ttitrace_pkl = write_df_to_pickle(df_cell_zab, target_path='/tmp/df_cell_zab.pkl')
        combined_zab_stats, combined_zab_stats_Percentage = \
            run_zab_stat_analysis_dl(path_to_pickle=path_to_filtered_ttitrace_pkl)
        msg = 'combined_zab_stats'
        datedConsole(getHeaderLine(msg, combined_zab_stats))
        # msg = 'combined_zab_stats_Percentage'
        # datedConsole(getHeaderLine(msg, combined_zab_stats_Percentage))
        # If all checks pass, return True
        df_nb_correct_zab = \
            df_ToCheck.where(df_ToCheck['hasZab'].astype(int) == 1).dropna().value_counts().reset_index()
        df_total_zab = df_ToCheck.value_counts().reset_index()
        rbi.log("df_nb_correct_zab present: {}".format(df_nb_correct_zab['count']))
        rbi.log("df_total_zab present: {}".format(df_total_zab['count']))
        df_incorrect_zab = \
            df_ToCheck.loc[df_ToCheck['hasZab'].astype(int) != 1].dropna(subset=['hasZab'])
        rbi.log('df_incorrect_zab: {}'.format(df_incorrect_zab))
        # Get percentage of correct zab
        percentage = 100 * len(df_nb_correct_zab) / len(df_total_zab)
        rbi.log("physCellId: {} Percentage of Correct Zab: {} Threshold accepted: {}".format(
                     physCellId, percentage, threshold_ok))
        correct_zab_percentage = (percentage == threshold_ok)
        # Get percentage of incorrect zab
        percentage = 100 * len(df_incorrect_zab) / len(df_total_zab)
        rbi.log("physCellId: {} Percentage of Incorrect Zab: {} Threshold accepted: {}".format(
                     physCellId, percentage, threshold_err))

        incorrect_zab_percentage = (percentage == threshold_err)
        return all((correct_zab_percentage, incorrect_zab_percentage))
    except Exception as e:
        details = traceback.format_exc()
        rbi.log_to_console("debug: Failure in verify_TTITraces_for_Zab_Privilege. traceback = %s" % details)
        rbi.log("debug: Failure in verify_TTITraces_for_Zab_Privilege. traceback = %s" % details)
        logException("Error in verify_TTITraces_for_Zab_Privilege:", e)
        return all((False, False))


def check_CB009890(path_to_pickle, maxNumDlSubcellL1Pool=6, maxNumDlSubcellL1Sp=4):

    global pd
    global verdict
    verdict = False
    pd = pandas_gate.install_and_import_pandas()
    global tti_df
    tti_df = pd.read_pickle(path_to_pickle)

    df_cell1 = tti_df[tti_df['physCellId'] == 50]
    df_cell2 = tti_df[tti_df['physCellId'] == 51]
    df_cell3 = tti_df[tti_df['physCellId'] == 52]
    direction = 'dl'
    direction_2 = 'Dl'

    # rbi.log(df_cell1, 'INFO')
    # rbi.log(df_cell2, 'INFO')

    tti_df_activeDlSubcellsList_cell1_bis = df_cell1.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    tti_df_activeDlSubcellsList_cell2_bis = df_cell2.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    tti_df_activeDlSubcellsList_cell3_bis = df_cell3.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])

    rbi.log(tti_df_activeDlSubcellsList_cell1_bis, 'INFO')
    rbi.log(tti_df_activeDlSubcellsList_cell2_bis, 'INFO')
    rbi.log(tti_df_activeDlSubcellsList_cell3_bis, 'INFO')

    global tti_df_activeDlSubcellsList_cell1
    tti_df_activeDlSubcellsList_cell1 = df_cell1.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell1_serie
    tti_df_activeDlSubcellsList_cell1_serie = \
        tti_df_activeDlSubcellsList_cell1['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell1_serie, 'INFO')
    global tti_df_activeDlSubcellsList_cell2
    tti_df_activeDlSubcellsList_cell2 = df_cell2.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                                     dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell2_serie
    tti_df_activeDlSubcellsList_cell2_serie = \
        tti_df_activeDlSubcellsList_cell2['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell2_serie, 'INFO')

    global tti_df_activeDlSubcellsList_cell3
    tti_df_activeDlSubcellsList_cell3 = df_cell3.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell3_serie
    tti_df_activeDlSubcellsList_cell3_serie = \
        tti_df_activeDlSubcellsList_cell3['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')

    len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell1_serie: {}'.format(
                 len_tti_df_activeDlSubcellsList_cell1_serie), 'INFO')
    len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell2_serie: {}'.format(
                 len_tti_df_activeDlSubcellsList_cell2_serie), 'INFO')
    len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell3_serie: {}'.format(
                 len_tti_df_activeDlSubcellsList_cell3_serie), 'INFO')

    if len_tti_df_activeDlSubcellsList_cell1_serie > len_tti_df_activeDlSubcellsList_cell2_serie:
        df_compare_serie_cell1_cell2 = \
            tti_df_activeDlSubcellsList_cell1_serie.index.difference(tti_df_activeDlSubcellsList_cell2_serie.index)
        rbi.log(df_compare_serie_cell1_cell2, 'INFO')
        df_compare_serie_cell2_cell1 = \
            tti_df_activeDlSubcellsList_cell2_serie.index.difference(tti_df_activeDlSubcellsList_cell1_serie.index)
        rbi.log(df_compare_serie_cell2_cell1, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell1_cell2[0] - tolerance) < \
                df_compare_serie_cell2_cell1[0] < (df_compare_serie_cell1_cell2[0] + tolerance):
            tti_df_activeDlSubcellsList_cell1_serie = tti_df_activeDlSubcellsList_cell1_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell1_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell1_serie = tti_df_activeDlSubcellsList_cell1_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell1_serie)]
        len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell1_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell1_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell1_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell1_serie > len_tti_df_activeDlSubcellsList_cell3_serie:
        df_compare_serie_cell1_cell3 = \
            tti_df_activeDlSubcellsList_cell1_serie.index.difference(tti_df_activeDlSubcellsList_cell3_serie.index)
        rbi.log(df_compare_serie_cell1_cell3, 'INFO')
        df_compare_serie_cell3_cell1 = \
            tti_df_activeDlSubcellsList_cell3_serie.index.difference(tti_df_activeDlSubcellsList_cell1_serie.index)
        rbi.log(df_compare_serie_cell1_cell3, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell1_cell3[0] - tolerance) < \
                df_compare_serie_cell3_cell1[0] < (df_compare_serie_cell1_cell3[0] + tolerance):
            tti_df_activeDlSubcellsList_cell1_serie = tti_df_activeDlSubcellsList_cell1_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell1_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell1_serie = tti_df_activeDlSubcellsList_cell1_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell1_serie)]
        len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell1_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell1_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell1_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell2_serie > len_tti_df_activeDlSubcellsList_cell1_serie:
        df_compare_serie_cell2_cell1 = \
            tti_df_activeDlSubcellsList_cell2_serie.index.difference(tti_df_activeDlSubcellsList_cell1_serie.index)
        rbi.log(df_compare_serie_cell2_cell1, 'INFO')
        df_compare_serie_cell1_cell2 = \
            tti_df_activeDlSubcellsList_cell1_serie.index.difference(tti_df_activeDlSubcellsList_cell2_serie.index)
        rbi.log(df_compare_serie_cell1_cell2, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell1_cell2[0] - tolerance) < \
                df_compare_serie_cell2_cell1[0] < (df_compare_serie_cell1_cell2[0] + tolerance):
            tti_df_activeDlSubcellsList_cell2_serie = tti_df_activeDlSubcellsList_cell2_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell2_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell2_serie = tti_df_activeDlSubcellsList_cell2_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell2_serie)]
        len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell2_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell2_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell2_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell2_serie > len_tti_df_activeDlSubcellsList_cell3_serie:
        df_compare_serie_cell2_cell3 = \
            tti_df_activeDlSubcellsList_cell2_serie.index.difference(tti_df_activeDlSubcellsList_cell3_serie.index)
        rbi.log(df_compare_serie_cell2_cell3, 'INFO')
        df_compare_serie_cell3_cell2 = \
            tti_df_activeDlSubcellsList_cell3_serie.index.difference(tti_df_activeDlSubcellsList_cell2_serie.index)
        rbi.log(df_compare_serie_cell3_cell2, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell3_cell2[0] - tolerance) < \
                df_compare_serie_cell2_cell3[0] < (df_compare_serie_cell3_cell2[0] + tolerance):
            tti_df_activeDlSubcellsList_cell2_serie = tti_df_activeDlSubcellsList_cell2_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell2_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell2_serie = tti_df_activeDlSubcellsList_cell2_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell2_serie)]
        len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell2_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell2_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell2_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell3_serie > len_tti_df_activeDlSubcellsList_cell1_serie:
        df_compare_serie_cell3_cell1 = \
            tti_df_activeDlSubcellsList_cell3_serie.index.difference(tti_df_activeDlSubcellsList_cell1_serie.index)
        rbi.log(df_compare_serie_cell3_cell1, 'INFO')
        df_compare_serie_cell1_cell3 = \
            tti_df_activeDlSubcellsList_cell1_serie.index.difference(tti_df_activeDlSubcellsList_cell3_serie.index)
        rbi.log(df_compare_serie_cell1_cell3, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell1_cell3[0] - tolerance) < \
                df_compare_serie_cell3_cell1[0] < (df_compare_serie_cell1_cell3[0] + tolerance):
            tti_df_activeDlSubcellsList_cell3_serie = tti_df_activeDlSubcellsList_cell3_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell3_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell3_serie = tti_df_activeDlSubcellsList_cell3_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell3_serie)]
        len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell3_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell3_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell3_serie > len_tti_df_activeDlSubcellsList_cell2_serie:
        df_compare_serie_cell3_cell2 = \
            tti_df_activeDlSubcellsList_cell3_serie.index.difference(tti_df_activeDlSubcellsList_cell2_serie.index)
        rbi.log(df_compare_serie_cell3_cell2, 'INFO')
        df_compare_serie_cell2_cell3 = \
            tti_df_activeDlSubcellsList_cell2_serie.index.difference(tti_df_activeDlSubcellsList_cell3_serie.index)
        rbi.log(df_compare_serie_cell2_cell3, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell2_cell3[0] - tolerance) < \
                df_compare_serie_cell3_cell2[0] < (df_compare_serie_cell2_cell3[0] + tolerance):
            tti_df_activeDlSubcellsList_cell3_serie = tti_df_activeDlSubcellsList_cell3_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell3_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell3_serie = tti_df_activeDlSubcellsList_cell3_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell3_serie)]
        len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell3_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell3_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')
    index = 0
    for k in (list(tti_df_activeDlSubcellsList_cell1_serie)):
        # rbi.log('index {} '.format(index), 'INFO')
        # rbi.log('k {} '.format(k), 'INFO')
        len_tti_df_activeDlSubcellsList_cell1_index = len(k)
        # rbi.log('{} with len {}'.format(k,len_tti_df_activeDlSubcellsList_cell1_index), 'INFO')
        len_tti_df_activeDlSubcellsList_cell2_index = len((list(tti_df_activeDlSubcellsList_cell2_serie))[index])
        len_tti_df_activeDlSubcellsList_cell3_index = len((list(tti_df_activeDlSubcellsList_cell3_serie))[index])
        # rbi.log('len cell2 {} and len cell3 {}'.format(len_tti_df_activeDlSubcellsList_cell2_index,
        #                                                len_tti_df_activeDlSubcellsList_cell3_index),
        #         'INFO')
        sumAllDlSubCell = len_tti_df_activeDlSubcellsList_cell1_index + len_tti_df_activeDlSubcellsList_cell2_index
        sumAllDlSubCell = sumAllDlSubCell + len_tti_df_activeDlSubcellsList_cell3_index
        sumAllDlSubCell_spool0 = len_tti_df_activeDlSubcellsList_cell1_index
        sumAllDlSubCell_spool0 = sumAllDlSubCell_spool0 + len_tti_df_activeDlSubcellsList_cell3_index
        sumAllDlSubCell_spool1 = len_tti_df_activeDlSubcellsList_cell2_index
        # rbi.log('sumAllDlSubCell for {} is {}'.format(index, sumAllDlSubCell), 'INFO')
        verdict = (sumAllDlSubCell == int(maxNumDlSubcellL1Pool))
        verdict_spool0 = (sumAllDlSubCell_spool0 <= int(maxNumDlSubcellL1Sp))
        verdict_spool1 = (sumAllDlSubCell_spool1 <= int(maxNumDlSubcellL1Sp))
        if not verdict:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB009890 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB009890 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB009890 verdict_spool1_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool1))
            rbi.log('verdict_sumAllDlSubCell is failed for index {} with sumAllDlSubCell = {}'.format(
                         index, sumAllDlSubCell), 'INFO')
            rbi.fail('[ERR] verdict is failed on {} rows [maxNumDlSubcellL1Pool={}]'.format(
                     index, maxNumDlSubcellL1Pool))
            # break
        if not verdict_spool0:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB009890 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB009890 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB009890 verdict_spool1_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool1))
            rbi.log('check_CB009890: verdict_spool1 is {}'.format(verdict_spool1), 'INFO')
            rbi.should_be_true(verdict)
            rbi.should_be_true(verdict_spool0)
            rbi.should_be_true(verdict_spool1)
            msg = 'verdict_spool0 is failed for index {} with sumAllDlSubCell spool0 = {}'
            rbi.log(msg.format(index, sumAllDlSubCell_spool0), 'INFO')
            rbi.fail('[ERR] verdict is failed on {} rows [maxNumDlSubcellL1Pool={}]'.format(index,
                                                                                            maxNumDlSubcellL1Pool))
            # break
        if not verdict_spool1:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB009890 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB009890 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB009890 verdict_spool1_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool1))
            rbi.log('check_CB009890: verdict_spool1 is {}'.format(verdict_spool1), 'INFO')
            rbi.should_be_true(verdict)
            rbi.should_be_true(verdict_spool0)
            rbi.should_be_true(verdict_spool1)
            msg = 'verdict_spool1 is failed for index {} with sumAllDlSubCell spool1= {}'
            rbi.log(msg.format(index, sumAllDlSubCell_spool1), 'INFO')
            rbi.fail('[ERR] verdict is failed on {} rows [maxNumDlSubcellL1Pool={}]'.format(index,
                                                                                            maxNumDlSubcellL1Pool))
            # break
        if not verdict or not verdict_spool0 or not verdict_spool1:
            break
        index = index + 1

    msg = 'maxNumDlSubcellL1Pool'
    datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
    msg = 'check CB009890 Verdict_maxNumDlSubcellL1Pool'
    datedConsole(getHeaderLine(msg, verdict))
    rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
    msg = 'maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
    msg = 'check CB009890 verdict_spool0_maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, verdict_spool0))
    rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
    msg = 'check CB009890 verdict_spool1_maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, verdict_spool1))
    rbi.log('check_CB009890: verdict_spool1 is {}'.format(verdict_spool1), 'INFO')
    rbi.should_be_true(verdict)
    rbi.should_be_true(verdict_spool0)
    rbi.should_be_true(verdict_spool1)


def main_test_csirs_check():
    path_to_ttitrace_pkl = "/home/ute/csamson/TRACES/ttitrace_streaming.pkl"
    # TRS slot ?
    # CellId = 50, RS3
    res = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                physCellId=50,
                                slot=1,
                                list_start_symb=(10, 11, 12, 13))
    # cellId = 51 , RS1
    res = run_csirs_analysis_dl(path_to_pickle=path_to_ttitrace_pkl,
                                physCellId=51,
                                slot=1,
                                list_start_symb=(10, 11))


def main_test_csirs_stat_analyis():
    path_to_ttitrace_pkl = "/home/ute/csamson/TRACES/normalized_df.pkl"
    combined_slots_stats, \
        combined_start_symbol_stats_Percentage = run_csirs_stat_analysis_pcap_dl(path_to_pickle=path_to_ttitrace_pkl)
    msg = 'combined_slots_stats'
    datedConsole(getHeaderLine(msg, combined_slots_stats))
    msg = 'combined_start_symbol_stats_Percentage'
    datedConsole(getHeaderLine(msg, combined_start_symbol_stats_Percentage))


def main_test_other():
    csirsgroups = [{'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
                   {'cell': 16388, 'csirsPoolingGroupId': 2, 'lcrId': 4}]
    csirsPoolingGroupId = get_csirsPoolingGroupId(cell=16385, csirsgroups=csirsgroups)

    file = '/home/ute/csamson/TRACES/SYSLOG_2.LOG'
    output = ''
    csirsgroups = [{'cell': 16386, 'csirsPoolingGroupId': 2, 'lcrId': 2},
                   {'cell': 16387, 'csirsPoolingGroupId': 0, 'lcrId': 3},
                   {'cell': 16388, 'csirsPoolingGroupId': 2, 'lcrId': 4},
                   {'cell': 16389, 'csirsPoolingGroupId': 1, 'lcrId': 5},
                   {'cell': 16390, 'csirsPoolingGroupId': 1, 'lcrId': 6}]
    csirsgroups_ = [{'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
                    {'cell': 16386, 'csirsPoolingGroupId': 2, 'lcrId': 2},
                    {'cell': 16387, 'csirsPoolingGroupId': 1, 'lcrId': 3},
                    {'cell': 16389, 'csirsPoolingGroupId': 1, 'lcrId': 5},
                    {'cell': 16390, 'csirsPoolingGroupId': 0, 'lcrId': 6}]
    csirsgroups = [{'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
                   {'cell': 16386, 'csirsPoolingGroupId': 1, 'lcrId': 2},
                   {'cell': 16387, 'csirsPoolingGroupId': 2, 'lcrId': 3},
                   {'cell': 16389, 'csirsPoolingGroupId': 1, 'lcrId': 5},
                   {'cell': 16390, 'csirsPoolingGroupId': 0, 'lcrId': 6}]

    nrCellGroups = [{'cell': 16385, 'nrCellGrpId': 0},
                    {'cell': 16386, 'nrCellGrpId': 1},
                    {'cell': 16387, 'nrCellGrpId': 2},
                    {'cell': 16388, 'nrCellGrpId': 3},
                    {'cell': 16389, 'nrCellGrpId': 4},
                    {'cell': 16390, 'nrCellGrpId': 5}]
    csirsgroups = [{'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
                   {'cell': 16386, 'csirsPoolingGroupId': 1, 'lcrId': 2}]

    list_nrCellIdentity = ['16385', '16386', '16387', '16388']
    # check_all_cell_csirspool_present(csirsgroups, list_nrCellIdentity)
    # sorted_csirs = extract_csirsPoolingGroupId_from_syslog(output, csirsgroups)
    # logger.info("sorted_csirs=%s", sorted_csirs)
    # extract_trscsirs_from_syslog(output, csirsgroups, nrCellGroups)
    # extract_cellcsirs_from_syslog(output, csirsgroups, cellcsirs=None)
    # extract_dll1sp_from_syslog(output)

    # path_to_ttitrace_pkl = "/home/ute/csamson/TRACES/CB009890/ttitrace_streaming_CB009890_B.pkl"
    # res = check_CB009890(path_to_pickle=path_to_ttitrace_pkl, maxNumDlSubcellL1Pool=4, maxNumDlSubcellL1Sp=3)


def test_extract_trscsirs():
    extract_trscsirs_from_syslog(syslogextract, csirsgroups=None, nrCellGroups=None)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    # main_test_csirs_check()
    test_extract_trscsirs()
