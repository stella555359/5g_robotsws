import logging
import math

from datetime import datetime
from datetime import timedelta

from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.helper_functions import display_df_as_html
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis import numpi as numpy

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
pd = None
np = None


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


""" Functions to be used """


@log_begin_end_func_name
def filter_valid_events_and_check_CB011028(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for MicroDtx Check and
        saves it into a new pickle to be used by other functions

        :param path_to_pickle: Path of input pickle file
        :param target_pkl_path: Path of new target pickle file

        :returns: target_pkl_path
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    pd.reset_option('^display.')

    # TTI Trace Events
    numAllocCellPrbDl_event = 'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    hasZabPrivilege_event = 'dlAllocatedPooledResourcesData.hasZabPrivilege'
    dlAllocatedPooledResourcesData_activeDlSubcellsList = 'dlAllocatedPooledResourcesData.activeDlSubcellsList'
    dlAllocatedPooledResourcesData_activeDlSubcellCountARM = 'dlAllocatedPooledResourcesData.activeDlSubcellCountARM'
    dlFdSchedData_numOfPrb_event = 'dlFdSchedData.numOfPrb'
    dlFdSchedData_cellBwpId_event = 'dlFdSchedData.cellBwpId'
    isValidWhatIsProposed = 'dlFdSchedData.isValidWhatIsProposed'
    dlMetricIndData_gbrPrbDemand_event = 'dlMetricIndData.metricIndData.gbrPrbDemand'
    dlMetricIndData_nonGbrPrbDemand_event = 'dlMetricIndData.metricIndData.nonGbrPrbDemand'
    dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl = 'dlAllocatedPooledResourcesData.allocStreamPrbNonGbrDl'
    dlFdSchedData_rrmBufferedDataDlTotal_event = 'dlFdSchedData.rrmBufferedDataDlTotal'

    filtered_df = (
        df.loc[((df[isValidWhatIsProposed] != 0) & (df['rnti'] != 65535)),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                numAllocCellPrbDl_event, hasZabPrivilege_event,
                dlAllocatedPooledResourcesData_activeDlSubcellsList,
                dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
                dlFdSchedData_numOfPrb_event,
                dlFdSchedData_cellBwpId_event,
                dlMetricIndData_gbrPrbDemand_event,
                dlMetricIndData_nonGbrPrbDemand_event,
                dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl,
                dlFdSchedData_rrmBufferedDataDlTotal_event]]).dropna(
        subset=[
            numAllocCellPrbDl_event,
            hasZabPrivilege_event,
            dlAllocatedPooledResourcesData_activeDlSubcellsList,
            dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
            dlFdSchedData_numOfPrb_event,
            dlFdSchedData_cellBwpId_event,
            dlMetricIndData_gbrPrbDemand_event,
            dlMetricIndData_nonGbrPrbDemand_event,
            dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl,
            dlFdSchedData_rrmBufferedDataDlTotal_event
        ], how='all').reset_index(drop=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path


@log_begin_end_func_name
def filter_valid_events_and_check_CB009890_A_2(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for MicroDtx Check and
        saves it into a new pickle to be used by other functions

        :param path_to_pickle: Path of input pickle file
        :param target_pkl_path: Path of new target pickle file

        :returns: target_pkl_path
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    pd.reset_option('^display.')

    # TTI Trace Events
    dlAllocatedPooledResourcesData_numAllocCellPrbDl_event = 'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    dlAllocatedPooledResourcesData_activeDlSubcellsList = 'dlAllocatedPooledResourcesData.activeDlSubcellsList'
    dlAllocatedPooledResourcesData_activeDlSubcellCountARM = 'dlAllocatedPooledResourcesData.activeDlSubcellCountARM'
    dlMetricIndData_gbrPrbDemand_event = 'dlMetricIndData.metricIndData.gbrPrbDemand'
    dlMetricIndData_nonGbrPrbDemand_event = 'dlMetricIndData.metricIndData.nonGbrPrbDemand'
    dlMetricIndData_rrmAvgSpectralEffSlot_event = 'dlMetricIndData.metricIndData.rrmAvgSpectralEffSlot'
    dlMetricIndData_avgLoadNonGbr_event = 'dlMetricIndData.metricIndData.avgLoadNonGbr'
    dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl = 'dlAllocatedPooledResourcesData.allocStreamPrbNonGbrDl'
    dlInterL1SubpoolReconfData_l1PoolId_event = 'dlInterL1SubpoolReconfData.l1PoolId'
    dlInterL1SubpoolReconfData_l1SubPools_event = 'dlInterL1SubpoolReconfData.l1SubPools'

    filtered_df = (
        df.loc[(df['rnti'] != 65535),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                dlAllocatedPooledResourcesData_numAllocCellPrbDl_event,
                dlAllocatedPooledResourcesData_activeDlSubcellsList,
                dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
                dlMetricIndData_gbrPrbDemand_event,
                dlMetricIndData_nonGbrPrbDemand_event,
                dlMetricIndData_rrmAvgSpectralEffSlot_event,
                dlMetricIndData_avgLoadNonGbr_event,
                dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl,
                dlInterL1SubpoolReconfData_l1PoolId_event,
                dlInterL1SubpoolReconfData_l1SubPools_event]]).dropna(
        subset=[
            dlAllocatedPooledResourcesData_numAllocCellPrbDl_event,
            dlAllocatedPooledResourcesData_activeDlSubcellsList,
            dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
            dlMetricIndData_gbrPrbDemand_event,
            dlMetricIndData_nonGbrPrbDemand_event,
            dlMetricIndData_rrmAvgSpectralEffSlot_event,
            dlMetricIndData_avgLoadNonGbr_event,
            dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl,
            dlInterL1SubpoolReconfData_l1PoolId_event,
            dlInterL1SubpoolReconfData_l1SubPools_event
        ], how='all').reset_index(drop=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path


@log_begin_end_func_name
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
    df_cell4 = tti_df[tti_df['physCellId'] == 53]
    # rbi.log(df_cell1, 'INFO')
    direction = 'dl'
    direction_2 = 'Dl'

    global tti_df_activeDlSubcellsList_cell1
    tti_df_activeDlSubcellsList_cell1 = df_cell1.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell1_serie
    tti_df_activeDlSubcellsList_cell1_serie =\
        tti_df_activeDlSubcellsList_cell1['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell1_serie, 'INFO')
    global tti_df_activeDlSubcellsList_cell2
    tti_df_activeDlSubcellsList_cell2 = df_cell2.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                                     dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell2_serie
    tti_df_activeDlSubcellsList_cell2_serie =\
        tti_df_activeDlSubcellsList_cell2['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell2_serie, 'INFO')

    global tti_df_activeDlSubcellsList_cell3
    tti_df_activeDlSubcellsList_cell3 = df_cell3.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell3_serie
    tti_df_activeDlSubcellsList_cell3_serie =\
        tti_df_activeDlSubcellsList_cell3['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')

    global tti_df_activeDlSubcellsList_cell4
    tti_df_activeDlSubcellsList_cell4 = df_cell4.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell4_serie
    tti_df_activeDlSubcellsList_cell4_serie = \
        tti_df_activeDlSubcellsList_cell4['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell4_serie, 'INFO')

    len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell1_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell1_serie),
            'INFO')
    len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell2_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell2_serie),
            'INFO')
    len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell3_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell3_serie),
            'INFO')
    len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell4_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell4_serie),
            'INFO')

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

    if len_tti_df_activeDlSubcellsList_cell1_serie > len_tti_df_activeDlSubcellsList_cell4_serie:
        df_compare_serie_cell1_cell4 = \
            tti_df_activeDlSubcellsList_cell1_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell1_cell4, 'INFO')
        df_compare_serie_cell4_cell1 = \
            tti_df_activeDlSubcellsList_cell4_serie.index.difference(tti_df_activeDlSubcellsList_cell1_serie.index)
        rbi.log(df_compare_serie_cell1_cell4, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell1_cell4[0] - tolerance) < \
                df_compare_serie_cell4_cell1[0] < (df_compare_serie_cell1_cell4[0] + tolerance):
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

    if len_tti_df_activeDlSubcellsList_cell2_serie > len_tti_df_activeDlSubcellsList_cell4_serie:
        df_compare_serie_cell2_cell4 = \
            tti_df_activeDlSubcellsList_cell2_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell2_cell4, 'INFO')
        df_compare_serie_cell4_cell2 = \
            tti_df_activeDlSubcellsList_cell4_serie.index.difference(tti_df_activeDlSubcellsList_cell2_serie.index)
        rbi.log(df_compare_serie_cell4_cell2, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell4_cell2[0] - tolerance) < \
                df_compare_serie_cell2_cell4[0] < (df_compare_serie_cell4_cell2[0] + tolerance):
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

    if len_tti_df_activeDlSubcellsList_cell3_serie > len_tti_df_activeDlSubcellsList_cell4_serie:
        df_compare_serie_cell3_cell4 = \
            tti_df_activeDlSubcellsList_cell3_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell3_cell4, 'INFO')
        df_compare_serie_cell4_cell3 = \
            tti_df_activeDlSubcellsList_cell4_serie.index.difference(tti_df_activeDlSubcellsList_cell3_serie.index)
        rbi.log(df_compare_serie_cell4_cell3, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell4_cell3[0] - tolerance) < \
                df_compare_serie_cell3_cell4[0] < (df_compare_serie_cell4_cell3[0] + tolerance):
            tti_df_activeDlSubcellsList_cell3_serie = tti_df_activeDlSubcellsList_cell3_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell3_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell3_serie = tti_df_activeDlSubcellsList_cell3_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell3_serie)]
        len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell3_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell3_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell4_serie > len_tti_df_activeDlSubcellsList_cell1_serie:
        df_compare_serie_cell4_cell1 = \
            tti_df_activeDlSubcellsList_cell4_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell4_cell1, 'INFO')
        df_compare_serie_cell1_cell4 = \
            tti_df_activeDlSubcellsList_cell1_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell1_cell4, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell1_cell4[0] - tolerance) < \
                df_compare_serie_cell4_cell1[0] < (df_compare_serie_cell1_cell4[0] + tolerance):
            tti_df_activeDlSubcellsList_cell4_serie = tti_df_activeDlSubcellsList_cell4_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell4_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell4_serie = tti_df_activeDlSubcellsList_cell4_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell4_serie)]
        len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell4_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell4_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell4_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell4_serie > len_tti_df_activeDlSubcellsList_cell2_serie:
        df_compare_serie_cell4_cell2 = \
            tti_df_activeDlSubcellsList_cell4_serie.index.difference(tti_df_activeDlSubcellsList_cell2_serie.index)
        rbi.log(df_compare_serie_cell4_cell2, 'INFO')
        df_compare_serie_cell2_cell4 = \
            tti_df_activeDlSubcellsList_cell2_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell2_cell4, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell2_cell4[0] - tolerance) < \
                df_compare_serie_cell4_cell2[0] < (df_compare_serie_cell2_cell4[0] + tolerance):
            tti_df_activeDlSubcellsList_cell4_serie = tti_df_activeDlSubcellsList_cell4_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell4_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell4_serie = tti_df_activeDlSubcellsList_cell4_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell4_serie)]
        len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell4_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell4_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell4_serie, 'INFO')

    if len_tti_df_activeDlSubcellsList_cell4_serie > len_tti_df_activeDlSubcellsList_cell3_serie:
        df_compare_serie_cell4_cell3 = \
            tti_df_activeDlSubcellsList_cell4_serie.index.difference(tti_df_activeDlSubcellsList_cell3_serie.index)
        rbi.log(df_compare_serie_cell4_cell3, 'INFO')
        df_compare_serie_cell3_cell4 = \
            tti_df_activeDlSubcellsList_cell3_serie.index.difference(tti_df_activeDlSubcellsList_cell4_serie.index)
        rbi.log(df_compare_serie_cell3_cell4, 'INFO')
        tolerance = 50
        if (df_compare_serie_cell3_cell4[0] - tolerance) < \
                df_compare_serie_cell4_cell3[0] < (df_compare_serie_cell3_cell4[0] + tolerance):
            tti_df_activeDlSubcellsList_cell4_serie = tti_df_activeDlSubcellsList_cell4_serie[
                                                      0:len(tti_df_activeDlSubcellsList_cell4_serie) - 1]
        else:
            tti_df_activeDlSubcellsList_cell4_serie = tti_df_activeDlSubcellsList_cell4_serie[
                                                      1:len(tti_df_activeDlSubcellsList_cell4_serie)]
        len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell4_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell4_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell4_serie, 'INFO')

    index = 0
    for k in (list(tti_df_activeDlSubcellsList_cell1_serie)):
        # rbi.log('index {} '.format(index), 'INFO')
        # rbi.log('k {} '.format(k), 'INFO')
        len_tti_df_activeDlSubcellsList_cell1_index = len(k)
        # rbi.log('{} with len {}'.format(k,len_tti_df_activeDlSubcellsList_cell1_index), 'INFO')
        len_tti_df_activeDlSubcellsList_cell2_index = len((list(tti_df_activeDlSubcellsList_cell2_serie))[index])
        len_tti_df_activeDlSubcellsList_cell3_index = len((list(tti_df_activeDlSubcellsList_cell3_serie))[index])
        len_tti_df_activeDlSubcellsList_cell4_index = len((list(tti_df_activeDlSubcellsList_cell4_serie))[index])
        # rbi.log('len cell2 {} and len cell3 {}'.format(len_tti_df_activeDlSubcellsList_cell2_index,
        #                                                len_tti_df_activeDlSubcellsList_cell3_index),
        #         'INFO')
        sumAllDlSubCell = len_tti_df_activeDlSubcellsList_cell1_index + len_tti_df_activeDlSubcellsList_cell2_index
        sumAllDlSubCell = sumAllDlSubCell + len_tti_df_activeDlSubcellsList_cell3_index
        sumAllDlSubCell = sumAllDlSubCell + len_tti_df_activeDlSubcellsList_cell4_index
        sumAllDlSubCell_spool0 = len_tti_df_activeDlSubcellsList_cell1_index
        sumAllDlSubCell_spool0 = sumAllDlSubCell_spool0 + len_tti_df_activeDlSubcellsList_cell3_index
        sumAllDlSubCell_spool1 = len_tti_df_activeDlSubcellsList_cell2_index
        sumAllDlSubCell_spool1 = sumAllDlSubCell_spool1 + len_tti_df_activeDlSubcellsList_cell4_index
        # rbi.log('sumAllDlSubCell for {} is {}'.format(index, sumAllDlSubCell), 'INFO')
        verdict = (sumAllDlSubCell == int(maxNumDlSubcellL1Pool))
        verdict_spool0 = (sumAllDlSubCell_spool0 <= int(maxNumDlSubcellL1Sp))
        verdict_spool1 = (sumAllDlSubCell_spool1 <= int(maxNumDlSubcellL1Sp))
        if not verdict:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool1))
            rbi.log('verdict_sumAllDlSubCell is failed for index {} with sumAllDlSubCell = {}'.format(index,
                                                                                                      sumAllDlSubCell),
                    'INFO')
            rbi.fail('[ERR] verdict is failed on {} rows [maxNumDlSubcellL1Pool={}]'.format(index,
                                                                                            maxNumDlSubcellL1Pool))
            # break
        if not verdict_spool0:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
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
            msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
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
    msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
    datedConsole(getHeaderLine(msg, verdict))
    rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
    msg = 'maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
    msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, verdict_spool0))
    rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
    msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, verdict_spool1))
    rbi.log('check_CB009890: verdict_spool1 is {}'.format(verdict_spool1), 'INFO')
    rbi.should_be_true(verdict)
    rbi.should_be_true(verdict_spool0)
    rbi.should_be_true(verdict_spool1)


@log_begin_end_func_name
def check_CB009890_version1(path_to_pickle, maxNumDlSubcellL1Pool=6, maxNumDlSubcellL1Sp=4):

    global pd
    global verdict
    verdict = False
    pd = pandas_gate.install_and_import_pandas()
    global tti_df
    tti_df = pd.read_pickle(path_to_pickle)

    df_cell1 = tti_df[tti_df['physCellId'] == 50]
    df_cell2 = tti_df[tti_df['physCellId'] == 51]
    df_cell3 = tti_df[tti_df['physCellId'] == 52]
    df_cell4 = tti_df[tti_df['physCellId'] == 53]
    # rbi.log(df_cell1, 'INFO')
    direction = 'dl'
    direction_2 = 'Dl'

    global tti_df_activeDlSubcellsList_cell1
    tti_df_activeDlSubcellsList_cell1 = df_cell1.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell1_serie
    tti_df_activeDlSubcellsList_cell1_serie =\
        tti_df_activeDlSubcellsList_cell1['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell1_serie, 'INFO')
    global tti_df_activeDlSubcellsList_cell2
    tti_df_activeDlSubcellsList_cell2 = df_cell2.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                                     dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell2_serie
    tti_df_activeDlSubcellsList_cell2_serie =\
        tti_df_activeDlSubcellsList_cell2['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell2_serie, 'INFO')

    global tti_df_activeDlSubcellsList_cell3
    tti_df_activeDlSubcellsList_cell3 = df_cell3.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell3_serie
    tti_df_activeDlSubcellsList_cell3_serie =\
        tti_df_activeDlSubcellsList_cell3['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')

    global tti_df_activeDlSubcellsList_cell4
    tti_df_activeDlSubcellsList_cell4 = df_cell4.dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction, dir_2=direction_2)])
    global tti_df_activeDlSubcellsList_cell4_serie
    tti_df_activeDlSubcellsList_cell4_serie = \
        tti_df_activeDlSubcellsList_cell4['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(
            dir=direction, dir_2=direction_2)]
    rbi.log(tti_df_activeDlSubcellsList_cell4_serie, 'INFO')

    # len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
    # rbi.log('len of tti_df_activeDlSubcellsList_cell3_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell1_serie),
    #         'INFO')
    # len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
    # rbi.log('len of tti_df_activeDlSubcellsList_cell3_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell2_serie),
    #         'INFO')
    # len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
    # rbi.log('len of tti_df_activeDlSubcellsList_cell3_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell3_serie),
    #         'INFO')
    # len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
    # rbi.log('len of tti_df_activeDlSubcellsList_cell4_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell4_serie),
    #         'INFO')

    len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell1_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell1_serie),
            'INFO')
    len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell2_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell2_serie),
            'INFO')
    len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell3_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell3_serie),
            'INFO')
    len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
    rbi.log('len of tti_df_activeDlSubcellsList_cell4_serie: {}'.format(len_tti_df_activeDlSubcellsList_cell4_serie),
            'INFO')

    if len_tti_df_activeDlSubcellsList_cell1_serie > len_tti_df_activeDlSubcellsList_cell2_serie or\
            len_tti_df_activeDlSubcellsList_cell1_serie > len_tti_df_activeDlSubcellsList_cell3_serie or\
            len_tti_df_activeDlSubcellsList_cell1_serie > len_tti_df_activeDlSubcellsList_cell4_serie:
        tti_df_activeDlSubcellsList_cell1_serie =\
            tti_df_activeDlSubcellsList_cell1_serie[1: len(list(tti_df_activeDlSubcellsList_cell1_serie))]
        len_tti_df_activeDlSubcellsList_cell1_serie = len(list(tti_df_activeDlSubcellsList_cell1_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell1_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell1_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell1_serie, 'INFO')
    if len_tti_df_activeDlSubcellsList_cell2_serie > len_tti_df_activeDlSubcellsList_cell1_serie or\
            len_tti_df_activeDlSubcellsList_cell2_serie > len_tti_df_activeDlSubcellsList_cell3_serie or\
            len_tti_df_activeDlSubcellsList_cell2_serie > len_tti_df_activeDlSubcellsList_cell4_serie:
        tti_df_activeDlSubcellsList_cell2_serie =\
             tti_df_activeDlSubcellsList_cell2_serie[1: len(list(tti_df_activeDlSubcellsList_cell2_serie))]
        len_tti_df_activeDlSubcellsList_cell2_serie = len(list(tti_df_activeDlSubcellsList_cell2_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell2_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell2_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell2_serie, 'INFO')
    if len_tti_df_activeDlSubcellsList_cell3_serie > len_tti_df_activeDlSubcellsList_cell1_serie or\
            len_tti_df_activeDlSubcellsList_cell3_serie > len_tti_df_activeDlSubcellsList_cell2_serie or\
            len_tti_df_activeDlSubcellsList_cell3_serie > len_tti_df_activeDlSubcellsList_cell4_serie:
        tti_df_activeDlSubcellsList_cell3_serie =\
             tti_df_activeDlSubcellsList_cell3_serie[1: len(list(tti_df_activeDlSubcellsList_cell3_serie))]
        len_tti_df_activeDlSubcellsList_cell3_serie = len(list(tti_df_activeDlSubcellsList_cell3_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell3_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell3_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell3_serie, 'INFO')
    if len_tti_df_activeDlSubcellsList_cell4_serie > len_tti_df_activeDlSubcellsList_cell1_serie or\
            len_tti_df_activeDlSubcellsList_cell4_serie > len_tti_df_activeDlSubcellsList_cell2_serie or\
            len_tti_df_activeDlSubcellsList_cell4_serie > len_tti_df_activeDlSubcellsList_cell3_serie:
        tti_df_activeDlSubcellsList_cell4_serie =\
             tti_df_activeDlSubcellsList_cell4_serie[1: len(list(tti_df_activeDlSubcellsList_cell4_serie))]
        len_tti_df_activeDlSubcellsList_cell4_serie = len(list(tti_df_activeDlSubcellsList_cell4_serie))
        text = 'len of tti_df_activeDlSubcellsList_cell4_serie updated: {}'
        rbi.log(text.format(len_tti_df_activeDlSubcellsList_cell4_serie), 'INFO')
        rbi.log(tti_df_activeDlSubcellsList_cell4_serie, 'INFO')

    index = 0
    for k in (list(tti_df_activeDlSubcellsList_cell1_serie)):
        # rbi.log('index {} '.format(index), 'INFO')
        # rbi.log('k {} '.format(k), 'INFO')
        len_tti_df_activeDlSubcellsList_cell1_index = len(k)
        # rbi.log('{} with len {}'.format(k,len_tti_df_activeDlSubcellsList_cell1_index), 'INFO')
        len_tti_df_activeDlSubcellsList_cell2_index = len((list(tti_df_activeDlSubcellsList_cell2_serie))[index])
        len_tti_df_activeDlSubcellsList_cell3_index = len((list(tti_df_activeDlSubcellsList_cell3_serie))[index])
        len_tti_df_activeDlSubcellsList_cell4_index = len((list(tti_df_activeDlSubcellsList_cell4_serie))[index])
        # rbi.log('len cell2 {} and len cell3 {}'.format(len_tti_df_activeDlSubcellsList_cell2_index,
        #                                                len_tti_df_activeDlSubcellsList_cell3_index),
        #         'INFO')
        sumAllDlSubCell = len_tti_df_activeDlSubcellsList_cell1_index + len_tti_df_activeDlSubcellsList_cell2_index
        sumAllDlSubCell = sumAllDlSubCell + len_tti_df_activeDlSubcellsList_cell3_index
        sumAllDlSubCell = sumAllDlSubCell + len_tti_df_activeDlSubcellsList_cell4_index
        sumAllDlSubCell_spool0 = len_tti_df_activeDlSubcellsList_cell1_index
        sumAllDlSubCell_spool0 = sumAllDlSubCell_spool0 + len_tti_df_activeDlSubcellsList_cell3_index
        sumAllDlSubCell_spool1 = len_tti_df_activeDlSubcellsList_cell2_index
        sumAllDlSubCell_spool1 = sumAllDlSubCell_spool1 + len_tti_df_activeDlSubcellsList_cell4_index
        # rbi.log('sumAllDlSubCell for {} is {}'.format(index, sumAllDlSubCell), 'INFO')
        verdict = (sumAllDlSubCell == int(maxNumDlSubcellL1Pool))
        verdict_spool0 = (sumAllDlSubCell_spool0 <= int(maxNumDlSubcellL1Sp))
        verdict_spool1 = (sumAllDlSubCell_spool1 <= int(maxNumDlSubcellL1Sp))
        if not verdict:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool1))
            rbi.log('verdict_sumAllDlSubCell is failed for index {} with sumAllDlSubCell = {}'.format(index,
                                                                                                      sumAllDlSubCell),
                    'INFO')
            rbi.fail('[ERR] verdict is failed on {} rows [maxNumDlSubcellL1Pool={}]'.format(index,
                                                                                            maxNumDlSubcellL1Pool))
            # break
        if not verdict_spool0:
            msg = 'maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Pool))
            msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
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
            msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
            datedConsole(getHeaderLine(msg, verdict))
            rbi.log('check_CB009890: verdict is {}'.format(verdict), 'INFO')
            msg = 'maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
            msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
            datedConsole(getHeaderLine(msg, verdict_spool0))
            rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
            msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
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
    msg = 'check CB011028 Verdict_maxNumDlSubcellL1Pool'
    datedConsole(getHeaderLine(msg, verdict))
    rbi.log('check_CB0110check_CB00989028: verdict is {}'.format(verdict), 'INFO')
    msg = 'maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, maxNumDlSubcellL1Sp))
    msg = 'check CB011028 verdict_spool0_maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, verdict_spool0))
    rbi.log('check_CB009890: verdict_spool0 is {}'.format(verdict_spool0), 'INFO')
    msg = 'check CB011028 verdict_spool1_maxNumDlSubcellL1Sp'
    datedConsole(getHeaderLine(msg, verdict_spool1))
    rbi.log('check_CB009890check_CB009890: verdict_spool1 is {}'.format(verdict_spool1), 'INFO')
    rbi.should_be_true(verdict)
    rbi.should_be_true(verdict_spool0)
    rbi.should_be_true(verdict_spool1)


@log_begin_end_func_name
def check_CB009890_OLD(path_to_pickle):

    global pd
    verdict1 = False
    verdict2 = False
    verdict3 = False
    pd = pandas_gate.install_and_import_pandas()
    tti_df = pd.read_pickle(path_to_pickle)

    df_cell1 = tti_df[tti_df['physCellId'] == 50]
    df_cell2 = tti_df[tti_df['physCellId'] == 51]
    df_cell3 = tti_df[tti_df['physCellId'] == 52]
    # rbi.log(df_cell1, 'INFO')
    direction = 'dl'
    direction_2 = 'Dl'

    tti_df_numAllocCellPrbDl_cell1 = df_cell1.drop_duplicates(
        subset=['dlAllocatedPooledResourcesData.numAllocCellPrbDl']).dropna(
        subset=['dlAllocatedPooledResourcesData.numAllocCellPrbDl'])
    rbi.log(
        'dlAllocatedPooledResourcesData.numAllocCellPrbDl Cell50 Columns used: {} Number of rows: {}'.format(
            tti_df_numAllocCellPrbDl_cell1, len(tti_df_numAllocCellPrbDl_cell1)), 'INFO')

    tti_df_activeDlSubcellsList_cell1 = df_cell1.drop_duplicates(
        subset=['dlAllocatedPooledResourcesData.activeDlSubcellsList']).dropna(
        subset=['dlAllocatedPooledResourcesData.activeDlSubcellsList'])
    tti_df_activeDlSubcellsList_cell2 = df_cell2.drop_duplicates(
        subset=['{dir}AllocatedPooledResourcesData.activeDlSubcellsList'.format(dir=direction)]).dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                                     dir_2=direction_2)])
    tti_df_activeDlSubcellsList_cell3 = df_cell3.drop_duplicates(
        subset=['{dir}AllocatedPooledResourcesData.activeDlSubcellsList'.format(dir=direction)]).dropna(
        subset=['{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                                     dir_2=direction_2)])

    data_activeDlSubcellsPrimaryList_cell50 = tti_df_activeDlSubcellsList_cell1[
        '{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                             dir_2=direction_2)].values
    data_activeDlSubcellsPrimaryList_cell51 = tti_df_activeDlSubcellsList_cell2[
        '{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                             dir_2=direction_2)].values
    data_activeDlSubcellsPrimaryList_cell52 = tti_df_activeDlSubcellsList_cell3[
        '{dir}AllocatedPooledResourcesData.active{dir_2}SubcellsList'.format(dir=direction,
                                                                             dir_2=direction_2)].values

    rbi.log('data_activeDlSubcellsPrimaryList_cell50: {}'.format(data_activeDlSubcellsPrimaryList_cell50[0][0]),
            'INFO')
    rbi.log('data_activeDlSubcellsSecondaryList_cell50: {}'.format(data_activeDlSubcellsPrimaryList_cell50[0][1]),
            'INFO')

    verdict1 = (len(data_activeDlSubcellsPrimaryList_cell50[0]) == 2)
    verdict2 = (len(data_activeDlSubcellsPrimaryList_cell51[0]) == 2)
    verdict3 = (len(data_activeDlSubcellsPrimaryList_cell52[0]) == 2)

    msg = 'check_CB009890: activeDlSubcellsList'
    datedConsole(getHeaderLine(msg + ' cell50 : Verdict = ', verdict1))
    datedConsole(getHeaderLine(msg + ' cell51 : Verdict = ', verdict2))
    datedConsole(getHeaderLine(msg + ' cell52 : Verdict = ', verdict3))
