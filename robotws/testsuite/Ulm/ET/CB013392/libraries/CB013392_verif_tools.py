import logging
import os
import json
import re
import importlib

import numpy as np
import pandas as pd

# TAF & UTE Libraries:
from taf.config.scf import scf

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.tti_analysis.dtx import get_dtx_stats
from testsuite.Ulm.ET.CB013392.libraries.CB013392_tools import log_exception


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Verification Functions
# ====================================================================================================[120 characters]

@log_begin_end_func_name
def prepare_meas_profile_result_df(result_df, us_id='b1'):
    try:
        # construct empty result dataframe
        if us_id == 'b1':
            meas_type = ['handover', 'handover', 'handover']
            event = ['a2', 'a3', 'a5']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'timetotrigger'],  # a3 measurements
                         ['hysteresis', 'threshold2', 'threshold', 'timetotrigger']]  # a5 measurements
        elif us_id == 'a_b5':
            # only for a check in the middle of the test procedure, i.e. after SCell addition
            meas_type = ['handover', 'handover']
            event = ['a3', 'a5']
            meas_name = [['hysteresis', 'timetotrigger'],  # a3 measurements
                         ['hysteresis', 'threshold2', 'threshold', 'timetotrigger']]  # a5 measurements
        elif us_id == 'c_b1':
            meas_type = ['handover', 'release', 'handover', 'handover']
            event = ['a2', 'a2', 'a3', 'a5']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'timetotrigger'],  # a3 measurements
                         ['hysteresis', 'threshold2', 'threshold', 'timetotrigger']]  # a5 measurements
        elif us_id == 'c_b8':
            meas_type = ['handover', 'handover']
            event = ['a2', 'a1']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'threshold', 'timetotrigger']]  # a1 measurements
        elif us_id == 'c_b10':
            meas_type = ['handover']
            event = ['a4']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger']]  # a4 measurements
        elif us_id == 'c_b7':
            meas_type = ['release', 'handover', 'handover']
            event = ['a2', 'a3', 'a5']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'timetotrigger'],  # a3 measurements
                         ['hysteresis', 'threshold2', 'threshold', 'timetotrigger']]  # a5 measurements
        else:
            meas_type = ['handover', 'redirect', 'handover', 'handover']
            event = ['a2', 'a2', 'a3', 'a5']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'timetotrigger'],  # a3 measurements
                         ['hysteresis', 'threshold2', 'threshold', 'timetotrigger']]  # a5 measurements

        for x in range(len(event)):
            result_df = pd.concat([result_df, pd.DataFrame(index=pd.MultiIndex.from_product([[meas_type[x]],
                                                                                             [event[x]],
                                                                                             meas_name[x]]),
                                                           columns=['actual_value', 'expected_value'])])
        result_df.index.names = ['meas_type', 'event', 'meas_name']

    except Exception as e:
        log_exception("prepare_meas_profile_result_df", e)
    return result_df


@log_begin_end_func_name
def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = get_scf_value(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            log_exception("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


@log_begin_end_func_name
def verify_Tput(*args):
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    try:
        expected_tput_dict = {int(cell): {dir_1: int(tput_1), dir_2: int(tput_2)}
                              for cell, dir_1, tput_1, dir_2, tput_2 in (element.split(':') for element in args)}
        logging.info("expected_tput_dict = %s" % json.dumps(expected_tput_dict, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for cell in expected_tput_dict.keys():
                    reported_tput_dl = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_dl']))
                    expected_tput_dl = expected_tput_dict[cell]["dl"]
                    verdicts.append(int(abs(reported_tput_dl-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    reported_tput_ul = int(round(tput_dict['MRBTS-1/NRBTS-1/NRCELL-%s' % cell]['throughput_ul']))
                    expected_tput_ul = expected_tput_dict[cell]["ul"]
                    verdicts.append(int(abs(reported_tput_ul-expected_tput_ul)*100/expected_tput_ul) <= 5)
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        log_exception("verify_Tput", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_Tput_CA_2cells(tput_string, ca_mode):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # tput_string = "pcell:scell:dir1:tput1:dir2:tput2", e.g. "3:1:dl:500:ul:200"
    # ca_mode = "dlOnly" or "dlAndUl"
    # -------------------------------------------------------------------------------------------------[120 characters]
    scenario = rbi.get_variable_value("${scenario}")
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    is_tput_correct = False
    logging.info("tput_string = %s" % str(tput_string))
    logging.info("ca_mode = %s" % str(ca_mode))
    try:
        expected_tput_list = [{"pcell": pcell, "scell": scell, dir1: int(tput1), dir2: int(tput2)}
                              for pcell, scell, dir1, tput1, dir2, tput2 in [tput_string.split(':')]]
        logging.info("expected_tput_list = %s" % json.dumps(expected_tput_list, indent=4))
        logging.info("scenario = %s" % (scenario))
        logging.info("pm_counters_dir = %s" % (pm_counters_dir))
        file_path = pm_counters_dir + "/pmc_average_tp_per_scenario_per_cell.json"
        if os.path.isfile(file_path):
            logging.info("TPut .json file exists: %s" % file_path)
            with open(file_path, 'r') as f:
                tput_dict = json.load(f)[scenario]
                logging.info("tput_dict = %s" % json.dumps(tput_dict, indent=4))
                verdicts = []
                for ca_set in expected_tput_list:
                    dist_name_pcell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["pcell"]
                    dist_name_scell = "MRBTS-1/NRBTS-1/NRCELL-%s" % ca_set["scell"]
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_dl_pcell = int(round(tput_dict[dist_name_pcell]['throughput_dl']))
                    reported_tput_dl_scell = int(round(tput_dict[dist_name_scell]['throughput_dl']))
                    reported_tput_dl_both = reported_tput_dl_pcell + reported_tput_dl_scell
                    logging.info("reported_tput_dl_both = %s" % (reported_tput_dl_both))
                    expected_tput_dl = ca_set["dl"]
                    verdicts.append(int(abs(reported_tput_dl_both-expected_tput_dl)*100/expected_tput_dl) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    reported_tput_ul_pcell = int(round(tput_dict[dist_name_pcell]['throughput_ul']))
                    reported_tput_ul_scell = int(round(tput_dict[dist_name_scell]['throughput_ul']))
                    reported_tput_ul_both = reported_tput_ul_pcell + reported_tput_ul_scell
                    logging.info("reported_tput_ul_both = %s" % (reported_tput_ul_both))
                    expected_tput_ul = ca_set["ul"]
                    verdicts.append(int(abs(reported_tput_ul_both-expected_tput_ul)*100/expected_tput_ul) <= 5)
                    # ---------------------------------------------------------------------------------[120 characters]
                    verdicts.append(reported_tput_dl_scell > 0)  # <--- check that SCell TPut is NOT zero
                    # ---------------------------------------------------------------------------------[120 characters]
                    if ca_mode == "dlAndUl":
                        verdicts.append(reported_tput_ul_scell > 0)  # <--- check that SCell TPut is NOT zero
                logging.info("verdicts = %s" % verdicts)
            if verdicts:
                is_tput_correct = all(verdicts)
        else:
            logging.info("TPut .json file does NOT exists: %s" % file_path)
    except Exception as e:
        log_exception("verify_Tput_CA_2cells", e)
    rbi.should_be_true(is_tput_correct)


@log_begin_end_func_name
def verify_DTX_Statistics(direction='ul', lcrid_str=None):
    lcrid_list = []
    if lcrid_str:
        lcrid_list = [int(lcrid) for lcrid in lcrid_str.split(':')]
    is_DTX_ok = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = get_df_from_pkl(path_to_ttitrace_pkl, direction=direction)
    logging.info("df = \n%s" % (df))
    try:
        output_df = get_dtx_stats(df, by='lcrId', return_dtx_df=False, direction=direction)
        if (not output_df.empty) and (len(lcrid_list) > 0):
            output_df = output_df[output_df.index.astype(int).isin(lcrid_list)]
        logging.info("output_df = \n%s" % (output_df))
        average_nondtx_percentage = output_df[('Percentage', 'NON_DTX')].mean()
        logging.info("average_nondtx_percentage = %s" % average_nondtx_percentage)
        is_DTX_ok = not average_nondtx_percentage < 99.0
    except Exception as e:
        log_exception("verify_DTX_Statistics", e)
    rbi.should_be_true(is_DTX_ok)


@log_begin_end_func_name
def verify_a1_result(a1_meas_id, scell_phy_id, scell_tech='FDD'):
    # check the response of a1 for the following:
    #  1.  Scell is added
    #  2.  A1 measurement is deactivated
    path_to_a1_txt = rbi.get_variable_value("${PATH_TO_A1_FDD_SCELL_ADD_OUTPUT}")
    if scell_tech == 'TDD':
        path_to_a1_txt = rbi.get_variable_value("${PATH_TO_A1_TDD_SCELL_ADD_OUTPUT}")
    is_scell_added = False
    is_a1_deactivated = False
    try:
        with open(path_to_a1_txt) as read_from_file:
            a1_result = read_from_file.readlines()
        scell_addition_regex = re.compile(r'sCellToAddModList')
        a1_deactivation_regex = re.compile(r'measIdToRemoveList')
        for line_no, line in enumerate(a1_result):
            scell_event = re.search(scell_addition_regex, line)
            a1_deact_event = re.search(a1_deactivation_regex, line)
            if scell_event:
                is_scell_added = match_string(line_no, a1_result, f"physCellId {scell_phy_id}")
                logging.info("SCell added: %s" % is_scell_added)
            if a1_deact_event:
                is_a1_deactivated = match_string(line_no, a1_result, a1_meas_id)
                logging.info("A1 deactivated: %s" % is_a1_deactivated)
            if scell_event and is_a1_deactivated:
                break
    except Exception as e:
        log_exception("verify_a1_result", e)
    rbi.should_be_true(is_scell_added and is_a1_deactivated)


@log_begin_end_func_name
def get_df_from_pkl(path_to_pickle, direction):
    ackNack = 'dlHarqRxDataArray.ackNack' if direction == 'dl' else 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(direction)
    mcsTable = '{}FdSchedData.mcsTable'.format(direction)
    laMode = '{}FdSchedData.laMode'.format(direction)
    sw_build = rbi.get_variable_value("${sw_build}")
    logging.info("sw_build = %s" % sw_build)
    if direction == 'dl':
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    elif any(x in sw_build for x in ['SBTS25R3', 'SBTS26R1']):
        targetBLER = 'ulFdSchedData.targetBLER'
    else:
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(direction, direction.capitalize())
    proposedMcs = '{}FdSchedData.rrm{}ProposedMcs'.format(direction, direction.capitalize())
    dtx = 'dlHarqRxDataArray.dtx' if direction == 'dl' else 'ulHarqRxData.dtx'
    prb = '???' if direction == 'dl' else 'ulTdSchedSubcellData.numAllocCellPrbUl'
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    if direction == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, dtx,
                 laMode, targetBLER, usedMcs, proposedMcs]]
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, dtx,
                 laMode, targetBLER, usedMcs, proposedMcs, prb]]
    return df


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def fill_meas_profile_df(result_df, egate_log_path, expected_meas):
    try:
        meas_df = get_actual_meas_profile_from_meas_disp(egate_log_path)
        logging.info("meas_df: %s" % meas_df)
        # convert IAF 2 profile based measurements to dataframe -> expected value
        iaf_df = pd.DataFrame(expected_meas).rename(columns=str.lower).T._set_axis_name('event').rename(
            columns=str.lower).melt(ignore_index=False, var_name='meas_name', value_name='value').set_index(
            'meas_name', append=True)
        iaf_df = iaf_df.iloc[np.where(~iaf_df['value'].isna())].sort_index()
        for _, y in enumerate(result_df.index):
            actual_event_idx = meas_df.index.get_level_values('event').str.contains(y[1]) \
                             & meas_df.index.get_level_values('meas_name').str.contains(y[2])
            exp_event_idx = (iaf_df.index.get_level_values('event').str.contains(y[1])
                             & iaf_df.index.get_level_values('meas_name').str.contains(y[2]))
            if any(exp_event_idx):
                # get index from expected result(IAF-2 meas prof configuration)
                iaf_id = iaf_df.iloc[exp_event_idx].index[0]
                result_df.loc[(y[0], y[1], y[2]), 'expected_value'] = iaf_df.loc[iaf_id]['value']
                iaf_df.drop(iaf_id, inplace=True)
                if any(actual_event_idx):
                    # get index from actual result(RRC)
                    rrc_id = meas_df.iloc[actual_event_idx].index[0]
                    result_df.loc[(y[0], y[1], y[2]), 'actual_value'] = meas_df.loc[rrc_id]['value']
                    # drop the row once consolidated since (a5, threshold)
                    # returns two matches (threshold and threshold2)
                    meas_df.drop(rrc_id, inplace=True)
        result_df['verdict'] = result_df['actual_value'] == result_df['expected_value']
    except Exception as e:
        log_exception("fill_meas_profile_df", e)
    return result_df


@log_begin_end_func_name
def get_actual_meas_profile_from_meas_disp(egate_log_path):
    meas_df = pd.DataFrame()
    a1_meas_values = {}
    a2_meas_values = {}
    a3_meas_values = {}
    a4_meas_values = {}
    a5_meas_values = {}
    prev_line = None
    try:
        with open(egate_log_path, 'r', encoding='utf-8') as actual_results:
            results = actual_results.readlines()

        found_nr_report = False
        event_regex = re.compile(r'EventA\d:')
        rep_cfg_regex = re.compile(r'report configuration \s*(\d+):')
        meas_id_line_no = None
        pcell_rep_cfg_id_list = None

        for line_no, line in enumerate(results):
            if line.strip():  # skip empty lines

                # For -C#B1, there are EUTRAN measurement reports and this has to be skipped
                if "DETAILED INFO ABOUT NR REPORT CONFIGURATIONS:" in line:
                    found_nr_report = True

                if found_nr_report:
                    event = re.search(event_regex, line)
                    if event:
                        # add report config id as prefix -> needed to identify if meas event belong to PCell
                        rep_cfg_id = re.search(rep_cfg_regex, prev_line)
                        if "EventA1:" in line:
                            rep_cfg = "%02d" % int(rep_cfg_id.group(1))
                            a1_meas_values[f'{rep_cfg}_{line_no}_a1'] = get_a2_values(line)
                        elif "EventA2:" in line:
                            rep_cfg = "%02d" % int(rep_cfg_id.group(1))
                            a2_meas_values[f'{rep_cfg}_{line_no}_a2'] = get_a2_values(line)
                        elif "EventA3:" in line:
                            rep_cfg = "%02d" % int(rep_cfg_id.group(1))
                            a3_meas_values = {f'{rep_cfg}_{line_no}_a3': get_a3_values(line)}
                        elif "EventA4:" in line:
                            rep_cfg = "%02d" % int(rep_cfg_id.group(1))
                            a4_meas_values = {f'{rep_cfg}_{line_no}_a4': get_a4_values(line)}
                            print("\n a4_meas_values \n", a4_meas_values)
                        elif "EventA5:" in line:
                            rep_cfg = "%02d" % int(rep_cfg_id.group(1))
                            a5_meas_values = {f'{rep_cfg}_{line_no}_a5': get_a5_values(line)}
                        continue
                    # get the line number where the table with repconfig, meas and objid begins
                    elif "NR MEASUREMENT IDENTITIES" in line:
                        meas_id_line_no = line_no
                        break
                    prev_line = line

        if meas_id_line_no is not None and not a1_meas_values:
            # Get report config id that belongs to pcell (objectid = 1)
            pcell_rep_cfg_id_list = get_report_cfg_id_for_obj_id(results, meas_id_line_no)

        # filter a2, a3, a4 and a5 events that belong to PCell only
        if pcell_rep_cfg_id_list:
            a2_meas_values = dict(filter(lambda a2_key: any(pcell_rep_id == a2_key[0].split('_')[0]
                                                            for pcell_rep_id in pcell_rep_cfg_id_list),
                                         a2_meas_values.items()))
            a3_meas_values = dict(filter(lambda a3_key: any(pcell_rep_id == a3_key[0].split('_')[0]
                                                            for pcell_rep_id in pcell_rep_cfg_id_list),
                                         a3_meas_values.items()))
            a5_meas_values = dict(filter(lambda a5_key: any(pcell_rep_id == a5_key[0].split('_')[0]
                                                            for pcell_rep_id in pcell_rep_cfg_id_list),
                                         a5_meas_values.items()))

        if (a2_meas_values and a3_meas_values and a5_meas_values):
            if a4_meas_values:
                meas_df = (pd.concat([pd.DataFrame.from_dict(a2_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a3_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a4_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a5_meas_values, orient='index').melt(
                                        ignore_index=False)]).rename(
                    columns={'variable': 'meas_name'}).set_index('meas_name', append=True))
            elif a1_meas_values:
                meas_df = (pd.concat([pd.DataFrame.from_dict(a1_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a2_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a3_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a5_meas_values, orient='index').melt(
                                        ignore_index=False)]).rename(
                    columns={'variable': 'meas_name'}).set_index('meas_name', append=True))
            else:
                meas_df = (pd.concat([pd.DataFrame.from_dict(a2_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a3_meas_values, orient='index').melt(ignore_index=False),
                                     pd.DataFrame.from_dict(a5_meas_values, orient='index').melt(
                                        ignore_index=False)]).rename(
                    columns={'variable': 'meas_name'}).set_index('meas_name', append=True))
            meas_df.index = meas_df.index.set_names(['event', 'meas_name'])
            meas_df.sort_index(inplace=True)

    except Exception as e:
        log_exception("get_actual_meas_profile_from_meas_disp", e)
    return meas_df


@log_begin_end_func_name
def get_report_cfg_id_for_obj_id(results, meas_id_line_no, obj_id='1'):
    pcell_rep_cfg_id_list = list()
    # regex 3 numbers split by spaces
    # == = UE1 NR MEASUREMENT IDENTITIES:
    # == == == == == == == == == == == == == == == =
    # MeasId  ObjectId  ReportCfgId
    # -------------------------------
    # 7       3         7    --> obj id 3 belongs to scell
    # 8       1         8    --> obj id 1 belongs to pcell
    # 9       1         9    --> obj id 1 belongs to pcell
    # 10      1         10   --> obj id 1 belongs to pcell
    # 11      1         11   --> obj id 1 belongs to pcell
    # == == == == == == == == == == == == == == == =
    nr_meas_id_regex = re.compile(r'(\d*)\s*(\d*)\s*(\d*)')
    for line_no, line in enumerate(results[meas_id_line_no:-1]):
        if line.strip():
            rep_meas_relation_result = re.search(nr_meas_id_regex, line)
            if rep_meas_relation_result:
                if rep_meas_relation_result.group(2) == obj_id:  # check if object id is 1(belongs to pcell)
                    pcell_rep_cfg_id_list.append("%02d" % int(rep_meas_relation_result.group(3)))
    return pcell_rep_cfg_id_list


# ====================================================================================================[120 characters]
@log_begin_end_func_name
def get_a2_values(content):
    a2_values = {}
    hys_regex = re.compile(r'hysteresis: \d*')
    trigger_regex = re.compile(r'TimeToTrigger: \d*')
    threshold_regex = re.compile(r'Threshold: RSRP \d*')

    hys = re.search(hys_regex, content)
    trigger = re.search(trigger_regex, content)
    threshold = re.search(threshold_regex, content)

    a2_values.update({'hysteresis': hys.group().split(': ')[1]})
    a2_values.update({'timetotrigger': 'ms%s' % trigger.group().split(': ')[1]})
    a2_values.update({'threshold': threshold.group().split(': ')[1].split(' ')[1]})
    return a2_values


@log_begin_end_func_name
def get_a3_values(content):
    a3_values = {}
    hys_regex = re.compile(r'hysteresis: \d*')
    trigger_regex = re.compile(r'TimeToTrigger: \d*')

    hys = re.search(hys_regex, content)
    trigger = re.search(trigger_regex, content)

    a3_values.update({'hysteresis': hys.group().split(': ')[1]})
    a3_values.update({'timetotrigger': 'ms%s' % trigger.group().split(': ')[1]})
    return a3_values


@log_begin_end_func_name
def get_a4_values(content):
    a4_values = {}
    hys_regex = re.compile(r'hysteresis: \d*')
    trigger_regex = re.compile(r'TimeToTrigger: \d*')
    threshold_regex = re.compile(r'threshold=Threshold: RSRP \d*')

    hys = re.search(hys_regex, content)
    trigger = re.search(trigger_regex, content)
    threshold = re.search(threshold_regex, content)

    a4_values.update({'hysteresis': hys.group().split(': ')[1]})
    a4_values.update({'timetotrigger': 'ms%s' % trigger.group().split(': ')[1]})
    a4_values.update({'threshold': threshold.group().split(': ')[1].split(' ')[1]})
    return a4_values


@log_begin_end_func_name
def get_a5_values(content):
    a5_values = {}
    hys_regex = re.compile(r'hysteresis: \d*')
    trigger_regex = re.compile(r'TimeToTrigger: \d*')
    t1_regex = re.compile(r'threshold1=Threshold: RSRP \d*')
    t2_regex = re.compile(r'threshold2=Threshold: RSRP \d*')

    hys = re.search(hys_regex, content)
    trigger = re.search(trigger_regex, content)
    t1 = re.search(t1_regex, content)
    t2 = re.search(t2_regex, content)

    a5_values.update({'hysteresis': hys.group().split(': ')[1]})
    a5_values.update({'timetotrigger': 'ms%s' % trigger.group().split(': ')[1]})
    a5_values.update({'threshold': t1.group().split(': ')[1].split(' ')[1]})
    a5_values.update({'threshold2': t2.group().split(': ')[1].split(' ')[1]})
    return a5_values


def match_string(line_start, content, string_to_be_matched):
    message_lines = []
    for line_no, line in enumerate(content[line_start + 1:]):
        if line != '\n':
            message_lines.append(line.strip())
        if '}' in line:
            break
    matched_output = list(filter(lambda x: string_to_be_matched in x, message_lines[1:-1]))
    logging.info(matched_output)
    return any(matched_output)


def get_scf_value(scfObj, pName, distName):
    outString = ""
    logging.info("get_scf_value(): pName = %s" % (pName))
    logging.info("get_scf_value(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("get_scf_value(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        log_exception("get_scf_value", e)
    return outString
