import math
import logging
import sys
import os
import traceback

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.config.scf import scf
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate, tti_dataframe
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.dtx import get_dtx_stats
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.prb import (
    get_prb_stats, get_event_and_filter,
    prepare_dataframe_for_analysis_dl, prepare_dataframe_for_analysis_ul,
    get_prb_per_slot_stats
)
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.mumimo import get_mumimo_stats, \
    generate_rank_stats, generate_subcellId_stats
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.ue_cell_identification import (  # noqa: E501
    identify_cells_and_ues
)
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.check_nack import\
    filter_valid_events_and_check_acknack_retx
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html, \
    display_df_as_table

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


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        traceback.print_exc()
        rbi.log_to_console(
            "  %s: exception happened (see log.html)" % functionNameStr)


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        if "--dryrun" not in sys.argv:
            logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        if "--dryrun" not in sys.argv:
            logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def log_begin_end_func_name_version1(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


def is_string_empty_or_none(my_string):
    return my_string is None or len(my_string) == 0


def get_sfn_column(row_from_list):
    sfn_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            sfn_column = i
            break
    return sfn_column


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
    # BuiltIn().log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
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


def load_dataframe(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


def get_dtx_statistics_physCellId_ul(filename=None, w_display_table=False):
    path_to_ttitrace_pkl = filename or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='ul')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        output = None
    return output


def get_dtx_statistics_rnti_ul(filename=None, w_display_table=False):
    path_to_ttitrace_pkl = filename or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='rnti', direction='ul')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        output = None
    return output


def get_dtx_statistics_lcrId_ul(filename=None, w_display_table=False):
    path_to_ttitrace_pkl = filename or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='lcrId', direction='ul')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        output = None
    return output


def get_dtx_statistics_physCellId_dl(filename=None, w_display_table=False):
    path_to_ttitrace_pkl = filename or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='dl')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        output = None
    return output


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_dl(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='dl')
        display_df_as_html(combined_mumimo_stats)
        if w_display_table:
            display_df_as_table(output)
        logging.info("combined_mumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_dl", e)
        combined_mumimo_stats = None
        mumimo_stats = None
    return combined_mumimo_stats, mumimo_stats


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_ul(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='ul')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output)
        logging.info("combined_ulmumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_ul", e)
    return combined_mumimo_stats, mumimo_stats


def get_cells_and_ues_physCellId(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = identify_cells_and_ues(df)
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_cells_and_ues_physCellId", e)
        output = None
    return output


@log_begin_end_func_name
def get_rank_statistics_rnti_dl(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='dl')
        display_df_as_html(combined_rank_stats)
        if w_display_table:
            display_df_as_table(output)
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_dl", e)
        combined_rank_stats = None
        rank_stats = None
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_rank_statistics_rnti_ul(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='ul')
        display_df_as_html(combined_rank_stats)
        if w_display_table:
            display_df_as_table(output)
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_ul", e)
        combined_rank_stats = None
        rank_stats = None
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_dl(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='dl')
        display_df_as_html(combined_subcell_stats)
        if w_display_table:
            display_df_as_table(output)
        logging.info("combined_dl_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_dl", e)
        combined_subcell_stats = None
        subcell_stats = None
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_ul(path_to_ttitrace_pkl=None, w_display_table=False):
    path_to_ttitrace_pkl = path_to_ttitrace_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    df.set_index(['timeStamp', 'sfn', 'slot', 'rnti'], inplace=True)
    df_stat = df.copy()
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['NbrPrbPerSlot'] = df_stat.groupby(level=[0, 1])['ulFdSchedData.numOfPrb'].sum()
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df_stat, by='physCellId', direction='ul')
        display_df_as_html(combined_subcell_stats)
        if w_display_table:
            display_df_as_table(output)
        logging.info("combined_ul_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_ul", e)
        combined_subcell_stats = None
        subcell_stats = None
    return combined_subcell_stats, subcell_stats


def move_column_to_end(df, column_name):
    if column_name in df.columns:
        column_to_move = df.pop(column_name)
        df[column_name] = column_to_move
    return df


def get_prb_statistics_physCellId_dl(filename_pkl=None, w_display_table=False, base_location=None, filename=None,
                                     both=False):
    path_to_ttitrace_pkl = filename_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    df_dl = df.copy()
    df.set_index(['timeStamp', 'sfn', 'slot', 'rnti'], inplace=True)
    df_stat = df.copy()
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['NbrPrbPerSlot'] = df_stat.groupby(level=[0, 1])['dlFdSchedData.numOfPrb'].sum()
    if base_location is not None and filename is not None:
        df_dl.set_index(['timeStamp', 'sfn', 'slot', 'rnti'], drop=False, inplace=True)
        df_dl = df_dl[~df_dl.index.duplicated(keep='first')]
        df_dl['NbrPrbPerSlot'] = df_dl.groupby(level=[0, 1])['dlFdSchedData.numOfPrb'].sum()
        filter = ['timeStamp', 'sfn', 'slot']
        event_under_consideration, filter_event = get_event_and_filter(direction='dl', grouped_by='physCellId')
        filter += filter_event
        filtered_df = prepare_dataframe_for_analysis_dl(df_dl)
        filtered_df = filtered_df[filter].dropna()
        move_column_to_end(filtered_df, 'NbrPrbPerSlot')
        filename_csv = 'dl_dataframe_prb_for_manual_analysis.csv'
        tti_dataframe.save_df_to_csv(filtered_df, csv_file_name=filename_csv, folder_path=base_location)
    try:
        output, combined_prb_stats = get_prb_stats(df_stat, by='physCellId', direction='dl')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output, base_location=base_location, filename=filename, both=both)
        logging.info("output = %s" % output)
        output_prb_per_slot, combined_prb_per_slot_stats = get_prb_per_slot_stats(df_stat, by='physCellId',
                                                                                  direction='dl')
        display_df_as_html(output_prb_per_slot)
        if w_display_table:
            display_df_as_table(output_prb_per_slot, base_location=base_location, filename=filename, both=both)
        logging.info("output_prb_per_slot = %s" % output_prb_per_slot)
    except Exception as e:
        logException("get_prb_statistics_physCellId_dl", e)
        output = None
        combined_prb_stats = {
            'avg': 0,
            'median': 0,
            'sum': 0,
            'count': 0,
            'ul_ratio_max_or_dl_max_prb': 0
        }
    return output, combined_prb_stats


def get_prb_statistics_physCellId_ul(filename_pkl=None, w_display_table=False, base_location=None, filename=None,
                                     both=False):
    path_to_ttitrace_pkl = filename_pkl or rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    df_ul = df.copy()
    df.set_index(['timeStamp', 'sfn', 'slot', 'rnti'], inplace=True)
    df_stat = df.copy()
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['NbrPrbPerSlot'] = df_stat.groupby(level=[0, 1])['ulFdSchedData.numOfPrb'].sum()
    if base_location is not None and filename is not None:
        df_ul.set_index(['timeStamp', 'sfn', 'slot', 'rnti'], drop=False, inplace=True)
        df_ul = df_ul[~df_ul.index.duplicated(keep='first')]
        df_ul['NbrPrbPerSlot'] = df_ul.groupby(level=[0, 1])['ulFdSchedData.numOfPrb'].sum()
        filter = ['timeStamp', 'sfn', 'slot']
        event_under_consideration, filter_event = get_event_and_filter(direction='ul', grouped_by='physCellId')
        filter += filter_event
        filtered_df = prepare_dataframe_for_analysis_ul(df_ul)
        # df_filtered = filtered_df[filtered_df["ulFdSchedData.priorityIndex"] == "DRBTRAFFIC"]
        filtered_df = filtered_df[filter].dropna()
        move_column_to_end(filtered_df, 'NbrPrbPerSlot')
        filename_csv = 'ul_dataframe_prb_for_manual_analysis.csv'
        tti_dataframe.save_df_to_csv(filtered_df, csv_file_name=filename_csv, folder_path=base_location)
    try:
        # df_stat = df_stat[df_stat["ulFdSchedData.priorityIndex"] == "DRBTRAFFIC"]
        output, combined_prb_stats = get_prb_stats(df_stat, by='physCellId', direction='ul')
        display_df_as_html(output)
        if w_display_table:
            display_df_as_table(output, base_location=base_location, filename=filename, both=both)
        logging.info("output = %s" % output)
        output_prb_per_slot, combined_prb_per_slot_stats = get_prb_per_slot_stats(df_stat, by='physCellId',
                                                                                  direction='ul')
        display_df_as_html(output_prb_per_slot)
        if w_display_table:
            display_df_as_table(output_prb_per_slot, base_location=base_location, filename=filename, both=both)
        logging.info("output_prb_per_slot = %s" % output_prb_per_slot)
    except Exception as e:
        logException("get_prb_statistics_physCellId_ul", e)
        output = None
        combined_prb_stats = {
            'avg': 0,
            'median': 0,
            'sum': 0,
            'count': 0,
            'ul_ratio_max_or_dl_max_prb': 0
        }
    return output, combined_prb_stats


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
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


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
def verify_TTITraces_for_acknack_retx(path_to_pickle):
    filter_valid_events_and_check_acknack_retx(path_to_pickle=path_to_pickle)


@log_begin_end_func_name
def prepare_df_to_compute_mumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def check_target_bler_is_less_than_percentage(path_to_pickle, xlaBlerTarget_hr_internal_value=10,
                                              xlaBlerTarget_br_internal_value=10, direction='dl',
                                              tolerance_br=2, tolerance_hr=0.1, resultFile=None):
    """ Computer target bler using tx number and check if less than
        the threshold

        Suggested pkl file: pkl file WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param xlaBlerTarget_hr_internal_value: threshold for HR
        :param xlaBlerTarget_br_internal_value: threshold for BR
        :param direction: ul/dl
    """
    logging.info("path_to_pickle = %s" % path_to_pickle)
    logging.info("xlaBlerTarget_hr_internal_value = %s" % xlaBlerTarget_hr_internal_value)
    logging.info("xlaBlerTarget_br_internal_value = %s" % xlaBlerTarget_br_internal_value)
    logging.info("direction = %s" % direction)
    logging.info("tolerance_br = %s" % tolerance_br)
    logging.info("tolerance_hr = %s" % tolerance_hr)
    # ------------------------------------------------------------------------------------------------[120 characters]
    xlaBlerTarget_br_GUI_value = (xlaBlerTarget_br_internal_value / 100)
    xlaBlerTarget_hr_GUI_value = (xlaBlerTarget_hr_internal_value / 1000)

    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)

    laMode_event = '{}FdSchedData.laMode'.format(direction)
    txNumber_event = '{}FdSchedData.txNumber'.format(direction)

    df = df[['timeStamp', 'rnti', 'sfn', 'slot', laMode_event,
             txNumber_event]].dropna(subset=[laMode_event])

    hr_filtered_df = df[(df[laMode_event] == 'HIGHRELIABILITY')]
    br_filtered_df = df[(df[laMode_event] == 'BASICRELIABILITY')]

    check_target_bler_is_less_than_percentage_with_df(br_filtered_df, txNumber_event,
                                                      'BASICRELIABILITY', tolerance_br,
                                                      xlaBlerTarget_br_GUI_value * 100, direction,
                                                      resultFile)
    check_target_bler_is_less_than_percentage_with_df(hr_filtered_df, txNumber_event,
                                                      'HIGHRELIABILITY', tolerance_hr,
                                                      xlaBlerTarget_hr_GUI_value * 100, direction,
                                                      resultFile)


@log_begin_end_func_name
def check_target_bler_is_less_than_percentage_with_df(filtered_df, txNumber_event, laMode_event_value, tolerance,
                                                      threshold=1, direction='dl', resultFile=None):
    """
    1) Grouping and Counting:
    .groupby(['rnti', 'txNumber_event']): This groups the DataFrame by the columns rnti and txNumber_event.
    .size(): This counts the number of occurrences in each group.
    .reset_index(name='Count'): This resets the index of the DataFrame and names the count column as Count.
    2) Calculating Percentage:
    .assign(Percentage=lambda x: x['Count'] * 100 / x.groupby('rnti')['Count'].transform('sum'))
     This adds a new column Percentage to the DataFrame.
    The lambda function calculates the percentage of each count relative to the total count for each rnti group.
    Here’s a more detailed look at the process:

    Grouping: The DataFrame is grouped by rnti and txNumber_event, creating groups of rows that share the same values
     in these columns.
    Counting: The .size() function counts the number of rows in each group.
    Resetting Index: The .reset_index(name='Count') function converts the group counts into a DataFrame
     with a new column named Count.
    Calculating Percentages: The .assign() function adds a new column Percentage. The lambda function calculates
     the percentage of each count within its rnti group by dividing the count by the total count of the group and
      multiplying by 100.
    """
    counted_df = (
        filtered_df
        .groupby(['rnti', txNumber_event])
        .size()
        .reset_index(name='Count')
        .assign(Percentage=lambda x: x['Count'] * 100 / x.groupby('rnti')['Count'].transform('sum'))
    )
    if resultFile is not None and resultFile and resultFile.strip():
        # Check if the variable parameters (file) is provided
        file_result_param_exists = True
        # Check if the file is empty
        file_exists = os.path.exists(resultFile)
        is_empty = os.path.getsize(resultFile) == 0 if file_exists else True
    else:
        file_result_param_exists = False
        is_empty = True
    rnti_group = {}
    for rnti, df_group in counted_df.groupby('rnti'):
        percentage_2_values = df_group[df_group[txNumber_event] == 2]["Percentage"].values
        percentage_1_values = df_group[df_group[txNumber_event] == 1]["Percentage"].values

        if file_result_param_exists:
            with open(resultFile, 'a') as file:
                file.write(f"\n\t\t*****************************************\n")
                file.write(f"\n\t\tcheck_target_bler_is_less_than_percentage\n")
                file.write(f"\n\t\t*****************************************\n")

        if len(percentage_2_values) == 0:
            target_bler_reached = True
            rbi.log("There is no txNumber=2 transmission i.e {} BLER is 0%.\
                    Setting {} BLER check PASS for rnti {} and {}".format(direction,
                                                                          direction, rnti,
                                                                          laMode_event_value), "INFO")
            datedConsole("There is no txNumber=2 transmission i.e {} BLER is 0%."
                         " Setting {} BLER check PASS for rnti {} and {}".format(direction, direction,
                                                                                 rnti, laMode_event_value))
            if file_result_param_exists:
                with open(resultFile, 'a') as file:
                    text_file = "There is no txNumber=2 transmission i.e {} BLER is 0%."\
                                " Setting {} BLER check PASS for rnti {} and {}".format(direction, direction,
                                                                                        rnti, laMode_event_value)
                    file.write(f"\n\t\t{text_file}\n")
            continue

        bler = 100 * (percentage_2_values / percentage_1_values)
        text = "Checking if Computed target BLER({}) on RNTI {} with {} mode is less" \
               " than threshold:({}%)+tolerance({}%)"
        rbi.log(text.format(bler, rnti, laMode_event_value, threshold, tolerance), "INFO")
        datedConsole(text.format(bler, rnti, laMode_event_value, threshold, tolerance))
        if file_result_param_exists:
            with open(resultFile, 'a') as file:
                text_file = text.format(bler, rnti, laMode_event_value, threshold, tolerance)
                file.write(f"\n\t\t{text_file}\n")
        target_bler_reached = True if bler <= (threshold + tolerance) else False
        rnti_group[rnti] = target_bler_reached

    for rnti, correlation_passed in rnti_group.items():
        if target_bler_reached:
            text = "target bler on RNTI {} is less than {} with {} mode. Check PASSED"
            rbi.log(text.format(rnti, (threshold + tolerance), laMode_event_value), "INFO")
            datedConsole(text.format(rnti, (threshold + tolerance), laMode_event_value))
            # Conditionally append to the file
            if file_result_param_exists:
                with open(resultFile, 'a') as file:
                    text_file = text.format(rnti, (threshold + tolerance), laMode_event_value)
                    file.write(f"\n\t\t{text_file}\n")
        else:
            text = "target bler on RNTI {} is not less than {} with {} mode"
            datedConsole(text.format(rnti, (threshold + tolerance), laMode_event_value))
            rbi.fail(text.format(rnti, (threshold + tolerance), laMode_event_value), 'ERROR')
            # Conditionally append to the file
            if file_result_param_exists:
                with open(resultFile, 'a') as file:
                    text_file = text.format(rnti, (threshold + tolerance), laMode_event_value)
                    file.write(f"\n\t\t{text_file}\n")


def test_target_bler():
    # path_to_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming.pkl'
    pd = pandas_gate.install_and_import_pandas()
    path_to_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming_dlFdSchedData.pkl'
    result_file = '/home/ute/csamson/TRACES/resultFile.log'
    check_target_bler_is_less_than_percentage(path_to_pickle, direction='dl', resultFile=result_file)
    path_to_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming_ulFdSchedData.pkl'
    check_target_bler_is_less_than_percentage(path_to_pickle, direction='ul', resultFile=result_file)


def other_tests():
    path_to_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming_dlFdSchedData.pkl'
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    display_df_as_table(df.head(10), base_location='/home/ute/csamson/TRACES', filename='displayDf.log', both=True)


def test_prb_statistics():
    # path_to_dl_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming_dlFdSchedData.pkl'
    # path_to_ul_pickle = '/home/ute/csamson/TRACES/ttitrace_streaming_ulFdSchedData.pkl'
    # path_to_dl_pickle = '/home/ute/csamson/TRACES/MUE/ttitrace_streaming_dlFdSchedData.pkl'
    # path_to_ul_pickle = '/home/ute/csamson/TRACES/MUE/ttitrace_streaming_ulFdSchedData.pkl'
    # path_to_dl_pickle = '/home/ute/csamson/TRACES/MUE2/ttitrace_streaming_dlFdSchedData.pkl'
    # path_to_ul_pickle = '/home/ute/csamson/TRACES/MUE2/ttitrace_streaming_ulFdSchedData.pkl'
    path_to_dl_pickle = '/home/ute/csamson/TRACE/crt/ttitrace_streaming_dlFdSchedData.pkl'
    path_to_ul_pickle = '/home/ute/csamson/TRACE/crt/ttitrace_streaming_ulFdSchedData.pkl'

    output, combined_prb_stats = get_prb_statistics_physCellId_dl(filename_pkl=path_to_dl_pickle,
                                                                  w_display_table=True,
                                                                  base_location='/home/ute/csamson/TRACE/crt',
                                                                  filename='dl_dataframe.csv')
    print("combined_prb_stats_percentage_dl = {}".format(output['Percentage']))
    print("avg = {}".format(combined_prb_stats['avg']))
    print("median = {}".format(combined_prb_stats['median']))
    print("sum = {}".format(combined_prb_stats['sum']))
    print("count = {}".format(combined_prb_stats['count']))
    print("max_prb = {}".format(combined_prb_stats['ul_ratio_max_or_dl_max_prb']))

    output, combined_prb_stats = get_prb_statistics_physCellId_ul(filename_pkl=path_to_ul_pickle,
                                                                  w_display_table=True,
                                                                  base_location='/home/ute/csamson/TRACE/crt',
                                                                  filename='ul_dataframe.csv')
    print("combined_prb_stats_percentage_ul = {}".format(output['Percentage']))
    print("avg = {}".format(combined_prb_stats['avg']))
    print("median = {}".format(combined_prb_stats['median']))
    print("sum = {}".format(combined_prb_stats['sum']))
    print("count = {}".format(combined_prb_stats['count']))
    print("ratio_max = {}".format(int(combined_prb_stats['ul_ratio_max_or_dl_max_prb'])))


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    # test_target_bler()
    test_prb_statistics()
