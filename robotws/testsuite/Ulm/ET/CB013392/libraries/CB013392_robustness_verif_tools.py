import logging
import re

# TAF & UTE Libraries:
from taf.config.scf import scf

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.CB013392.libraries.CB013392_robustness_tools import log_exception


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

import numpy as np
import pandas as pd

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
def prepare_meas_profile_result_df(result_df, us_id):
    try:
        if us_id == 'SA':
            meas_type = ['handover', 'redirect', 'handover', 'handover']
            event = ['a2', 'a2', 'a3', 'a5']
            meas_name = [['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'threshold', 'timetotrigger'],  # a2 measurements
                         ['hysteresis', 'timetotrigger'],  # a3 measurements
                         ['hysteresis', 'threshold2', 'threshold', 'timetotrigger']]  # a5 measurements
        else:
            meas_type = ['handover', 'release', 'handover', 'handover']
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
        result_df = result_df.sort_index()

    except Exception as e:
        log_exception("prepare_meas_profile_result_df", e)
    return result_df


@log_begin_end_func_name
def verify_parameters_in_scf(verify_scf_list, scf_file_path):
    is_passed = True
    scf_obj = scf()
    for parameter in verify_scf_list:
        returned_value = 0
        try:
            scf_obj.load_scf(scf_file_path)
            returned_value = get_scf_value(scf_obj, parameter["p_name"], parameter["dist_name"])
            value_result = (returned_value == parameter["value"])
        except Exception as e:
            log_exception("verify_parameters_in_scf", e, silent=True)
            value_result = "SCF is NOT available"
            is_passed = False
        else:
            is_passed = (is_passed and value_result)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returned_value, value_result))
    return is_passed


def get_scf_value(scf_obj, p_name, dist_name):
    out_string = ""
    logging.info("get_scf_value(): p_name = %s" % (p_name))
    logging.info("get_scf_value(): out_string = %s" % (out_string))
    try:
        out_string = scf_obj.get_value_from_scf(p_name=p_name, dist_name=dist_name)
        out_string = "true" if out_string == "True" else out_string
        out_string = "false" if out_string == "False" else out_string
        logging.info("get_scf_value(): '%s' = '%s' (SCF)" % (p_name, out_string))
    except Exception as e:
        log_exception("get_scf_value", e)
    return out_string


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
    for _, line in enumerate(results[meas_id_line_no:-1]):
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
