import logging
import math

from datetime import datetime
from datetime import timedelta

from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.helper_functions import display_df_as_html
from testsuite.Paris.resources.SWENG.python.TtiTrace import pandas_gate
from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis import numpi as numpy

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
def filter_valid_events_and_check_CB009836_A_1(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for 9836 Check and
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
    isValidWhatIsProposed = 'dlFdSchedData.isValidWhatIsProposed'
    dlMetricIndData_gbrPrbDemand_event = 'dlMetricIndData.metricIndData.gbrPrbDemand'
    dlMetricIndData_nonGbrPrbDemand_event = 'dlMetricIndData.metricIndData.nonGbrPrbDemand'

    dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl = 'dlAllocatedPooledResourcesData.allocStreamPrbNonGbrDl'
    dlFdSchedData_rrmBufferedDataDlTotal_event = 'dlFdSchedData.rrmBufferedDataDlTotal'
    dlFlowControlData_scheduledBytes_event = 'dlFlowControlData.scheduledBytes'
    dlFlowControlData_ethAvg_event = 'dlFlowControlData.ethAvg'
    dlFlowControlData_ethScaled_event = 'dlFlowControlData.ethScaled'

    filtered_df = (
        df.loc[((df[isValidWhatIsProposed] != 0) & (df['rnti'] != 65535)),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                numAllocCellPrbDl_event, hasZabPrivilege_event,
                dlAllocatedPooledResourcesData_activeDlSubcellsList,
                dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
                dlFdSchedData_numOfPrb_event,
                dlMetricIndData_gbrPrbDemand_event,
                dlMetricIndData_nonGbrPrbDemand_event,
                dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl,
                dlFdSchedData_rrmBufferedDataDlTotal_event,
                dlFlowControlData_scheduledBytes_event,
                dlFlowControlData_ethAvg_event,
                dlFlowControlData_ethScaled_event]]).dropna(
        subset=[
            numAllocCellPrbDl_event,
            hasZabPrivilege_event,
            dlAllocatedPooledResourcesData_activeDlSubcellsList,
            dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
            dlFdSchedData_numOfPrb_event,
            dlMetricIndData_gbrPrbDemand_event,
            dlMetricIndData_nonGbrPrbDemand_event,
            dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl,
            dlFdSchedData_rrmBufferedDataDlTotal_event,
            dlFlowControlData_scheduledBytes_event,
            dlFlowControlData_ethAvg_event,
            dlFlowControlData_ethScaled_event
        ], how='all').reset_index(drop=True)

    rows = \
        filtered_df[(filtered_df['physCellId'] == 50) &
                    (filtered_df[dlAllocatedPooledResourcesData_activeDlSubcellsList].notnull())].index
    rbi.log(
        'dlAllocatedPooledResourcesData.activeDlSubcellsList Cell50 Columns used: {} Number of rows: {}'.format(
            rows, len(rows)),
        'INFO')
    data_activeDlSubcellsList_cell50 =\
        filtered_df.loc[rows, dlAllocatedPooledResourcesData_activeDlSubcellsList]
    rbi.log(data_activeDlSubcellsList_cell50, 'INFO')

    rows =\
        filtered_df[(filtered_df['physCellId'] == 51) &
                    (filtered_df[dlAllocatedPooledResourcesData_activeDlSubcellsList].notnull())].index
    rbi.log(
        'dlAllocatedPooledResourcesData.activeDlSubcellsList Cell51 Columns used: {} Number of rows: {}'.format(
            rows, len(rows)),
        'INFO')
    data_activeDlSubcellsList_cell51 =\
        filtered_df.loc[rows, dlAllocatedPooledResourcesData_activeDlSubcellsList]
    rbi.log(data_activeDlSubcellsList_cell51, 'INFO')

    rows = \
        filtered_df[(filtered_df['physCellId'] == 52) &
                    (filtered_df[dlAllocatedPooledResourcesData_activeDlSubcellsList].notnull())].index
    rbi.log(
        'dlAllocatedPooledResourcesData.activeDlSubcellsList Cell52 Columns used: {} Number of rows: {}'.format(
            rows, len(rows)), 'INFO')
    data_activeDlSubcellsList_cell52 =\
        filtered_df.loc[rows, dlAllocatedPooledResourcesData_activeDlSubcellsList]
    rbi.log(data_activeDlSubcellsList_cell52, 'INFO')

    rows = \
        filtered_df[(filtered_df['physCellId'] == 53) &
                    (filtered_df[dlAllocatedPooledResourcesData_activeDlSubcellsList].notnull())].index
    rbi.log(
        'dlAllocatedPooledResourcesData.activeDlSubcellsList Cell53 Columns used: {} Number of rows: {}'.format(
            rows, len(rows)), 'INFO')
    data_activeDlSubcellsList_cell53 =\
        filtered_df.loc[rows, dlAllocatedPooledResourcesData_activeDlSubcellsList]
    rbi.log(data_activeDlSubcellsList_cell53, 'INFO')

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    msg = 'filter_valid_events_and_check_CB009836: activeDlSubcellsList'
    datedConsole(getHeaderLine(msg + ' cell50', data_activeDlSubcellsList_cell50))
    datedConsole(getHeaderLine(msg + ' cell51', data_activeDlSubcellsList_cell51))
    datedConsole(getHeaderLine(msg + ' cell52', data_activeDlSubcellsList_cell52))
    datedConsole(getHeaderLine(msg + ' cell53', data_activeDlSubcellsList_cell53))

    return [target_pkl_path, data_activeDlSubcellsList_cell50,
            data_activeDlSubcellsList_cell51, data_activeDlSubcellsList_cell52]


@log_begin_end_func_name
def filter_valid_events_and_check_CB009836_A_2(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for 9836 Check and
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
    dlAllocatedPooledResourcesData_hasZabPrivilege_event = 'dlAllocatedPooledResourcesData.hasZabPrivilege'
    # dlInterL1SubpoolReconfData_l1PoolId_event = 'dlInterL1SubpoolReconfData.l1PoolId'
    # dlInterL1SubpoolReconfData_l1SubPools_event = 'dlInterL1SubpoolReconfData.l1SubPools'

    filtered_df = (
        df.loc[(df['rnti'] != 65535),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                dlAllocatedPooledResourcesData_numAllocCellPrbDl_event,
                dlAllocatedPooledResourcesData_hasZabPrivilege_event,
                dlAllocatedPooledResourcesData_activeDlSubcellsList,
                dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
                dlMetricIndData_gbrPrbDemand_event,
                dlMetricIndData_nonGbrPrbDemand_event,
                dlMetricIndData_rrmAvgSpectralEffSlot_event,
                dlMetricIndData_avgLoadNonGbr_event,
                dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl]]).dropna(
        subset=[
            dlAllocatedPooledResourcesData_numAllocCellPrbDl_event,
            dlAllocatedPooledResourcesData_hasZabPrivilege_event,
            dlAllocatedPooledResourcesData_activeDlSubcellsList,
            dlAllocatedPooledResourcesData_activeDlSubcellCountARM,
            dlMetricIndData_gbrPrbDemand_event,
            dlMetricIndData_nonGbrPrbDemand_event,
            dlMetricIndData_rrmAvgSpectralEffSlot_event,
            dlMetricIndData_avgLoadNonGbr_event,
            dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl
        ], how='all').reset_index(drop=True)

    filtered_df.rename(columns={
        'sfn': 'sfn',
        'slot': 'Slot',
        'subcellid': 'SubcellID',
        dlAllocatedPooledResourcesData_numAllocCellPrbDl_event: 'numAllocCellPrbDl',
        dlAllocatedPooledResourcesData_hasZabPrivilege_event: 'hasZab',
        dlAllocatedPooledResourcesData_activeDlSubcellsList: 'activeDlSubcellsList',
        dlAllocatedPooledResourcesData_activeDlSubcellCountARM: 'activeDlSubcellCountARM',
        dlMetricIndData_gbrPrbDemand_event: 'gbrPrbDemand',
        dlMetricIndData_nonGbrPrbDemand_event: 'nonGbrPrbDemand',
        dlMetricIndData_rrmAvgSpectralEffSlot_event: 'rrmAvgSpectralEffSlot',
        dlMetricIndData_avgLoadNonGbr_event: 'avgLoadNonGbr',
        dlAllocatedPooledResourcesData_allocStreamPrbNonGbrDl: 'allocStreamPrbNonGbrDl'
    }, inplace=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path


def get_start_symbol_and_length_from_sliv(sliv):
    """
    Function where SLIV value get interpreted to start symbol and length.
    https://www.sharetechnote.com/html/5G/5G_SLIV.html
    :param sliv: SLIV value in TTI
    :return: PDSCH start symbol, length
    """
    if not sliv:
        return 'na', 'na'
    length = sliv // 14 + 1
    start_symbol = sliv - (14 * (length - 1))
    if start_symbol < 14 and 0 < length < 14 - start_symbol:
        return start_symbol, length
    length = 15 - sliv // 14
    start_symbol = (14 * (15 - length)) + 13 - sliv
    return start_symbol, length


def get_start_symbol_from_sliv(sliv):
    """
    Function where SLIV value get interpreted to start symbol and length.
    https://www.sharetechnote.com/html/5G/5G_SLIV.html
    :param sliv: SLIV value in TTI
    :return: PDSCH start symbol, length
    """
    start_symbol, length = get_start_symbol_and_length_from_sliv(sliv)
    # print('start_symbol=' + str(start_symbol))
    # print('length=' + str(length))
    return start_symbol


def get_length_from_sliv(sliv):
    """
    Function where SLIV value get interpreted to start symbol and length.
    https://www.sharetechnote.com/html/5G/5G_SLIV.html
    :param sliv: SLIV value in TTI
    :return: PDSCH start symbol, length
    """
    start_symbol, length = get_start_symbol_and_length_from_sliv(sliv)
    return length


@log_begin_end_func_name
def get_local_directory(path):
    path_tmp = path.split("/")
    path = "/".join(path_tmp[:-1])
    return path


@log_begin_end_func_name
def filter_valid_events_and_check_DlPrbAssign(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for 9836 Check and
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
    dlFdSchedData_subcellId_event = 'dlFdSchedData.subcellId'
    dlFdSchedData_startPrb_event = 'dlFdSchedData.startPrb'
    dlFdSchedData_numOfPrb_event = 'dlFdSchedData.numOfPrb'
    dlFdSchedData_SLIV_event = 'dlFdSchedData.SLIV'
    dlFdSchedData_searchSpaceType_event = 'dlFdSchedData.searchSpaceType'
    dlFdSchedData_searchSpaceId_event = 'dlFdSchedData.searchSpaceId'
    dlFdSchedData_dciFormat_event = 'dlFdSchedData.dciFormat'
    dlFdSchedData_aggregationLevel_event = 'dlFdSchedData.aggregationLevel'
    csiRsSchedData_subcellId_event = 'csiRsSchedData.subcellId'
    csiRsSchedData_startSymbol_event = 'csiRsSchedData.startSymbol'
    csiRsSchedData_startPrb_event = 'csiRsSchedData.startPrb'
    csiRsSchedData_numOfPrb_event = 'csiRsSchedData.numOfPrb'
    numAllocCellPrbDl_event = 'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    hasZabPrivilege_event = 'dlAllocatedPooledResourcesData.hasZabPrivilege'

    filtered_df = (
        df.loc[(df['rnti'] != 65535),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                dlFdSchedData_subcellId_event,
                dlFdSchedData_startPrb_event,
                dlFdSchedData_numOfPrb_event,
                dlFdSchedData_SLIV_event,
                dlFdSchedData_searchSpaceType_event,
                dlFdSchedData_searchSpaceId_event,
                dlFdSchedData_dciFormat_event,
                dlFdSchedData_aggregationLevel_event,
                csiRsSchedData_subcellId_event,
                csiRsSchedData_startSymbol_event,
                csiRsSchedData_startPrb_event,
                csiRsSchedData_numOfPrb_event,
                numAllocCellPrbDl_event,
                hasZabPrivilege_event]]).dropna(
        subset=[
            dlFdSchedData_subcellId_event,
            dlFdSchedData_startPrb_event,
            dlFdSchedData_numOfPrb_event,
            dlFdSchedData_SLIV_event,
            dlFdSchedData_searchSpaceType_event,
            dlFdSchedData_searchSpaceId_event,
            dlFdSchedData_dciFormat_event,
            dlFdSchedData_aggregationLevel_event,
            csiRsSchedData_subcellId_event,
            csiRsSchedData_startSymbol_event,
            csiRsSchedData_startPrb_event,
            csiRsSchedData_numOfPrb_event,
            numAllocCellPrbDl_event,
            hasZabPrivilege_event
        ], how='all').reset_index(drop=True)

    filtered_df.rename(columns={
        'sfn': 'sfn',
        'slot': 'Slot',
        'subcellid': 'SubcellID',
        dlFdSchedData_startPrb_event: 'startPrb',
        dlFdSchedData_numOfPrb_event: 'numOfPrb',
        dlFdSchedData_SLIV_event: 'SLIV',
        dlFdSchedData_searchSpaceType_event: 'searchSpaceType',
        dlFdSchedData_searchSpaceId_event: 'searchSpaceId',
        dlFdSchedData_dciFormat_event: 'dciFormat',
        dlFdSchedData_aggregationLevel_event: 'aggregationLevel',
        csiRsSchedData_subcellId_event: 'csiRs_subcell',
        csiRsSchedData_startSymbol_event: 'csiRs_startSymb',
        csiRsSchedData_startPrb_event: 'csiRs_startPrb',
        csiRsSchedData_numOfPrb_event: 'csiRs_numOdPrb',
        numAllocCellPrbDl_event: 'numAllocCellPrbDl',
        hasZabPrivilege_event: 'hasZab'
    }, inplace=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)
    filtered_df.to_csv(str("%s/%s.csv" % (get_local_directory(path_to_pickle),
                                          'dl_dataframe_manual_analysis_DlPrbAssign_filtered')), sep=';')

    # sliv = list((filtered_df['SLIV'].dropna()))
    sliv = list((filtered_df['SLIV']))
    # print(sliv)
    # SLIV = (S,L) see https://www.sharetechnote.com/html/5G/5G_SLIV.html
    filtered_df['S'] = [get_start_symbol_from_sliv(ele) for ele in sliv]
    col_S = filtered_df['S']
    filtered_df.insert(filtered_df.columns.get_loc('SLIV'), 'S_SLIV', col_S)
    filtered_df['L'] = [get_length_from_sliv(ele) for ele in sliv]
    col_L = filtered_df['L']
    filtered_df.insert(filtered_df.columns.get_loc('SLIV'), 'L_SLIV', col_L)
    filtered_df.eval('NbSymb = S_SLIV + L_SLIV', inplace=True)
    rbi.log(filtered_df)

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path


@log_begin_end_func_name
def filter_valid_events_has_zab_privilege(path_to_pickle, target_pkl_path):
    """ This function filters needed rows for 9836 Check and
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
    nrCellIdentity_event = 'dlAllocatedPooledResourcesData.nrCellIdentity'
    allocStreamPrbNonGbrDl_event = 'dlAllocatedPooledResourcesData.allocStreamPrbNonGbrDl'
    numAllocCellPrbDl_event = 'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    hasZabPrivilege_event = 'dlAllocatedPooledResourcesData.hasZabPrivilege'

    filtered_df = (
        df.loc[(df['rnti'] != 65535),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                nrCellIdentity_event,
                allocStreamPrbNonGbrDl_event,
                numAllocCellPrbDl_event,
                hasZabPrivilege_event]]).dropna(
        subset=[
            nrCellIdentity_event,
            allocStreamPrbNonGbrDl_event,
            numAllocCellPrbDl_event,
            hasZabPrivilege_event
        ], how='all').reset_index(drop=True)

    filtered_df.rename(columns={
        'sfn': 'sfn',
        'slot': 'Slot',
        'physCellId': 'physCellId',
        nrCellIdentity_event: 'nrCellIdentity',
        allocStreamPrbNonGbrDl_event: 'allocStreamPrbNonGbrDl',
        numAllocCellPrbDl_event: 'numAllocCellPrbDl',
        hasZabPrivilege_event: 'hasZab'
    }, inplace=True)

    rbi.log('DF successfully filtered!', 'INFO')
    rbi.log(filtered_df)
    filtered_df.to_csv(str("%s/%s.csv" % (get_local_directory(path_to_pickle),
                                          'dl_dataframe_manual_analysis_ZAB_filtered')), sep=';')

    # Save back to pickle
    filtered_df.to_pickle(target_pkl_path)

    return target_pkl_path
