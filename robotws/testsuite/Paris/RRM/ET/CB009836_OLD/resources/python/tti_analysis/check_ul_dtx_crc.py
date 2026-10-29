import logging

from datetime import datetime
from datetime import timedelta

from testsuite.Paris.resources.SWENG.python.TtiTrace import pandas_gate

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
pd = None


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


""" Functions to be used """


@log_begin_end_func_name
def get_directory(path):
    path_tmp = path.split("/")
    path = "/".join(path_tmp[:-1])
    return path


@log_begin_end_func_name
def check_crc_in_df(path_to_pickle, by='physCellId', column_name='ulHarqRxData.crcResult'):
    """ This function checks if there are CRC in DF
        Test will fail if CRC is present

        :param path_to_pickle: Path of input pickle file
        :param column_name: column name to check for CRC e.g ulHarqRxData.crcResult

    """
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', column_name]]

    # Validation Threshold: Percentage of NACKs and DTX to accept
    threshold = 0.1
    # to remove later !!!
    # threshold = 2.0
    # threshold = 10.0
    # threshold = 99.0

    # Check CRC in dataframe
    is_crc_present = any(x in df[column_name].values for x in ('NOK', 'KO'))
    rbi.log("Is CRC Failed present: {}".format(is_crc_present))
    crc_dtx_df = df.loc[df[column_name] != 'OK'].dropna(subset=[column_name])

    # Get percentage of CRC failed
    percentage = 100 * len(crc_dtx_df) / len(df[column_name])
    rbi.log("Percentage of CRC Failed: {} Threshold accepted: {}".format(percentage, threshold))

    global filtered_df_crc
    filtered_df_crc = df[[by, column_name]].dropna()
    rbi.log('filtered_df_crc: {}'.format(filtered_df_crc))

    global crc_stats
    crc_stats = filtered_df_crc.value_counts().reset_index()
    # crc_stats = crc_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    global total_events_grouped
    total_events_grouped = filtered_df_crc.groupby(by).size()
    """Add new columns to df"""
    crc_stats['Total Count'] = crc_stats[by].map(total_events_grouped)
    crc_stats['Percentage'] = (crc_stats['count'] / crc_stats['Total Count']) * 100
    """Combine stats"""
    global combined_crc_stats
    combined_crc_stats = crc_stats.pivot(index=by, columns=column_name, values=['count', 'Percentage'])
    combined_crc_stats.fillna(0, inplace=True)
    rbi.log('crc_stats: {}'.format(combined_crc_stats))

    if is_crc_present:
        rbi.log("Showing first 10 failing rows...")
        if percentage > threshold:
            rbi.log('Percentage ({}) did not reach threshold criteria ({}). Failing test case..'
                    .format(percentage, threshold))
            msg = '[ERR] CRC Failed present on {} rows. Percentage ({}) did not reach threshold criteria ({})'
            rbi.fail(msg.format(len(crc_dtx_df), percentage, threshold))
        else:
            rbi.log("CRC Failed present but threshold reached.. Passing test case")

    return combined_crc_stats


@log_begin_end_func_name
def check_reTx_in_df(path_to_pickle, by='physCellId', column_name='ulFdSchedData.txNumber'):
    """ This function checks if there are reTx in DF
        Test will fail if ReTx is present

        :param path_to_pickle: Path of input pickle file
        :param column_name: column name to check for txNumber e.g dlFdSchedData.txNumber

    """
    global reTx_df
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', column_name]]

    # Validation Threshold: Percentage of NACKs and DTX to accept
    threshold = 0.1

    # Check RETX in dataframe
    is_retx_present = 2 in df[column_name].values
    print("Is Retransmission present: {}".format(is_retx_present))
    reTx_df = df.loc[df[column_name] != 1].dropna(subset=[column_name])

    # Get percentage of ReTx
    percentage = 100 * len(reTx_df) / len(df[column_name])
    # percentage = 100 * len(df[df[column_name] == 2]) / len(df[column_name])
    rbi.log("Percentage of ReTx: {} Threshold accepted: {}".format(percentage, threshold))

    global filtered_df
    filtered_df = df[[by, column_name]].dropna()
    rbi.log('filtered_df: {}'.format(filtered_df))

    global retx_stats
    retx_stats = filtered_df.value_counts().reset_index()
    # retx_stats = retx_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    global total_events_grouped
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    retx_stats['Total Count'] = retx_stats[by].map(total_events_grouped)
    retx_stats['Percentage'] = (retx_stats['count'] / retx_stats['Total Count']) * 100
    """Combine stats"""
    global combined_retx_stats
    combined_retx_stats = retx_stats.pivot(index=by, columns=column_name, values=['count', 'Percentage'])
    combined_retx_stats.fillna(0, inplace=True)
    rbi.log('ReTx_stats: {}'.format(combined_retx_stats))

    if is_retx_present:
        rbi.log("Showing first 10 failing rows...")
        if percentage > threshold:
            rbi.log('Percentage ({}) did not reach threshold criteria ({}). Failing test case..'
                    .format(percentage, threshold))
            rbi.fail('[ERR] ReTx present on {} rows. Percentage ({}) did not reach threshold criteria ({})'.format(len(
                reTx_df), percentage, threshold))
        else:
            rbi.log("ReTx present but threshold reached.. Passing test case")

    return combined_retx_stats


@log_begin_end_func_name
def check_dtx_in_df(path_to_pickle, by='physCellId', column_name='ulHarqRxData.dtx'):
    """ This function checks if there are DTX in DF
        Test will fail if DTX is present

        :param path_to_pickle: Path of input pickle file
        :param column_name: column name to check for DTX e.g ulHarqRxData.dtx

    """
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', column_name]]

    # Validation Threshold: Percentage of DTX to accept
    threshold = 0.1

    # Check DTX in dataframe
    is_dtx_present = any(x in df[column_name].values for x in ('DTX'))
    rbi.log("Is DTX present: {}".format(is_dtx_present))
    dtx_df = df.loc[df[column_name] != 'NON_DTX'].dropna(subset=[column_name])

    # Get percentage of NACK
    percentage = 100 * len(dtx_df) / len(df[column_name])
    rbi.log("Percentage of DTX: {} Threshold accepted: {}".format(percentage, threshold))

    global filtered_df_dtx
    filtered_df_dtx = df[[by, column_name]].dropna()
    rbi.log('filtered_df_dtx: {}'.format(filtered_df_dtx))

    global dtx_stats
    dtx_stats = filtered_df_dtx.value_counts().reset_index()
    # dtx_stats = dtx_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    global total_events_grouped
    total_events_grouped = filtered_df_dtx.groupby(by).size()
    """Add new columns to df"""
    dtx_stats['Total Count'] = dtx_stats[by].map(total_events_grouped)
    dtx_stats['Percentage'] = (dtx_stats['count'] / dtx_stats['Total Count']) * 100
    """Combine stats"""
    global combined_dtx_stats
    combined_dtx_stats = dtx_stats.pivot(index=by, columns=column_name, values=['count', 'Percentage'])
    combined_dtx_stats.fillna(0, inplace=True)
    rbi.log('dtx_stats: {}'.format(combined_dtx_stats))

    if is_dtx_present:
        rbi.log("Showing first 10 failing rows...")
        if percentage > threshold:
            rbi.log('Percentage ({}) did not reach threshold criteria ({}). Failing test case..'
                    .format(percentage, threshold))
            msg = '[ERR] DTX present on {} rows. Percentage ({}) did not reach threshold criteria ({})'
            rbi.fail(msg.format(len(dtx_df), percentage, threshold))
        else:
            rbi.log("DTX present but threshold reached.. Passing test case")

    return combined_dtx_stats


@log_begin_end_func_name
def filter_valid_events_and_check_ul_crc_dtx_retx(path_to_pickle):

    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    pd.reset_option('^display.')

    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_ul_crc_dtx_retx.pkl'

    # TTI Trace Events
    ulFdSchedData_numOfPrb_event = 'ulFdSchedData.numOfPrb'
    isValidWhatIsProposed = 'ulFdSchedData.isValidWhatIsProposed'
    ulHarqRxData_crc_event = 'ulHarqRxData.crcResult'
    ulFdSchedData_txNumber_event = 'ulFdSchedData.txNumber'
    ulHarqRxData_dtx_event = 'ulHarqRxData.dtx'

    filtered_df = (
        df.loc[((df[isValidWhatIsProposed] != 0) & (df['rnti'] != 65535)),
               ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
                ulFdSchedData_txNumber_event, ulFdSchedData_numOfPrb_event,
                ulHarqRxData_crc_event, ulHarqRxData_dtx_event]]).dropna(
        subset=[
            ulFdSchedData_txNumber_event,
            ulHarqRxData_crc_event,
            ulFdSchedData_numOfPrb_event,
            ulHarqRxData_dtx_event
        ], how='all').reset_index(drop=True)

    # Save back to pickle
    filtered_df.to_pickle(path_to_filtered_ttitrace_pkl)
    combined_crc_stats_physCellId = check_crc_in_df(path_to_filtered_ttitrace_pkl, by='physCellId',
                                                    column_name='ulHarqRxData.crcResult')
    combined_crc_stats_rnti = check_crc_in_df(path_to_filtered_ttitrace_pkl, by='rnti',
                                              column_name='ulHarqRxData.crcResult')
    combined_retx_stats_physCellId = check_reTx_in_df(path_to_filtered_ttitrace_pkl, by='physCellId',
                                                      column_name='ulFdSchedData.txNumber')
    combined_retx_stats_rnti = check_reTx_in_df(path_to_filtered_ttitrace_pkl, by='rnti',
                                                column_name='ulFdSchedData.txNumber')
    combined_dtx_stats_physCellId = check_dtx_in_df(path_to_filtered_ttitrace_pkl, by='physCellId',
                                                    column_name='ulHarqRxData.dtx')
    combined_dtx_stats_rnti = check_dtx_in_df(path_to_filtered_ttitrace_pkl, by='rnti',
                                              column_name='ulHarqRxData.dtx')

    return [combined_crc_stats_physCellId, combined_crc_stats_rnti,
            combined_retx_stats_physCellId, combined_retx_stats_rnti,
            combined_dtx_stats_physCellId, combined_dtx_stats_rnti]
