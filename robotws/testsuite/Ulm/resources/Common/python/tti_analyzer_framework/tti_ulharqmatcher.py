import logging

import numpy as np
import pandas as pd


def ulharq_matcher(ul_df):
    # select data that will be merged and that will need to be used for matching to the correct rows
    df_to_merge = ul_df.loc[:, ul_df.columns.str.startswith(('timeStamp',
                                                             'hfnTickCount',
                                                             'sfn',
                                                             'slot',
                                                             'rnti',
                                                             'lcrId',
                                                             'physCellId',
                                                             'ulHarqRxData.'))]

    # rename the timestamp in the ulHarqRxData event so we know later how much it was shifted
    df_to_merge = df_to_merge.rename(columns={'timeStamp': 'timeStamp_shift'})

    # remove all empty columns from ulHarqRxData
    columns_to_drop_nan = df_to_merge.columns[df_to_merge.columns.str.startswith('ulHarqRxData.')]
    df_to_merge = df_to_merge.dropna(subset=columns_to_drop_nan)

    # ulHarqProcessIndex from both events must be matched, so we create a copy to use for matching
    df_to_merge['ulFdSchedData.ulHarqProcessIndex'] = df_to_merge['ulHarqRxData.ulHarqProcessIndex']

    # sfn and slot of the ulFdSchedData event is in the ulHarqRxData. We also use it for matching
    df_to_merge = df_to_merge.rename(columns={'sfn': 'ulFdSchedData.sfnForProcessing'})
    df_to_merge = df_to_merge.rename(columns={'slot': 'ulFdSchedData.slotForProcessing'})

    # merge both dataframes
    df_to_merge = ul_df.merge(
                      df_to_merge,
                      how='left',
                      on=['ulFdSchedData.sfnForProcessing',
                          'ulFdSchedData.slotForProcessing',
                          'rnti',
                          'lcrId',
                          'physCellId',
                          'ulFdSchedData.ulHarqProcessIndex',
                          'hfnTickCount'],
                      suffixes=('_original', '')
                  )

    # check if all matches done
    nr_ulHarqRxData_events = df_to_merge['ulHarqRxData.ulHarqProcessIndex'].count()
    nr_ulFdSchedData_events = df_to_merge['ulFdSchedData.ulHarqProcessIndex'].count()
    if nr_ulHarqRxData_events != nr_ulFdSchedData_events:
        logging.warning('ulHarq matcher: FAILED TO MATCH ALL EVENTS!')
        missed_events = nr_ulFdSchedData_events - nr_ulHarqRxData_events
        logging.warning('missed events: %d out of %d total events' %
                        (missed_events, nr_ulFdSchedData_events))

    # calculating time difference between the matched columns. Just for debugging info
    df_to_merge['timestamp_diff_harq'] = df_to_merge['timeStamp_shift'] - df_to_merge['timeStamp']
    if df_to_merge['timestamp_diff_harq'].min() != df_to_merge['timestamp_diff_harq'].max():
        logging.warning("ulharqmatcher: Time difference between ulFdSchedData "
                        "and ulHarqRxData inconsistent over the log. Possible Error during UL HARQ matching")
        logging.warning(df_to_merge['timestamp_diff_harq'].min())
        logging.warning(df_to_merge['timestamp_diff_harq'].max())

    # return the matched frames dropping the duplicated columns created on the matching process
    return df_to_merge.loc[:, ~df_to_merge.columns.str.endswith('_original')]


def _ulFdSchedData_ulLaDeltaSinr_matcher_per_cell_using_mcs(ul_df):
    """
    Columns from the original ulLaDeltaSinr are removed. After the ulFdSchedData and
    ulLaDeltaSinr will have same timestamp/SFN and slot.
    For the match the used mcs reported in both events is used
    For the match to be successful all the ulFdSchedData events must have a corresponding
    ulLaDeltaSinr event

    :param ul_df: uplink tti trace dataframe
    :return: the dataframe with ulFdSchedData and corresponding ulLaDeltaSinr in same row
    """
    nr_events2match = check_preconditions4LaDeltaSinr_matcher(ul_df)
    # select ulLaDeltaSinr rows
    df_ulLaDeltaSinr = ul_df.loc[:, ul_df.columns.str.startswith(('timeStamp',
                                                                  'hfnTickCount',
                                                                  'sfn',
                                                                  'slot',
                                                                  'rnti',
                                                                  'lcrId',
                                                                  'physCellId',
                                                                  'ulLaDeltaSinr.'))]

    # rename the timestamp in the ulLaDeltaSinr event so we know later how much it was shifted
    df_ulLaDeltaSinr = df_ulLaDeltaSinr.rename(columns={'timeStamp': 'timeStamp_shift'})

    # remove all empty columns from ulLaDeltaSinr
    columns_to_drop_nan = df_ulLaDeltaSinr.columns[df_ulLaDeltaSinr.columns.str.startswith('ulLaDeltaSinr.')]
    df_ulLaDeltaSinr = df_ulLaDeltaSinr.dropna(subset=columns_to_drop_nan)

    # drop the events not needed for match
    df_ulLaDeltaSinr = df_ulLaDeltaSinr.drop(['hfnTickCount', 'sfn', 'slot'], axis=1)

    # calculate the accumulated MCS for both dataframes
    # to avoid problems with mcs 0 we create a new column MCSplus1 and use that for the accumulated mcs
    df_ulLaDeltaSinr['MCSplus1'] = df_ulLaDeltaSinr['ulLaDeltaSinr.ulUsedMcs'] + 1
    ul_df['MCSplus1'] = ul_df['ulFdSchedData.rrmUlUsedMcs'] + 1
    df_ulLaDeltaSinr['accum_mcs'] = df_ulLaDeltaSinr['MCSplus1'].cumsum()
    ul_df['accum_mcs'] = ul_df['MCSplus1'].cumsum()
    # We duplicate the ulLaDeltaSinr.ulUsedMcs but with the name ulFdSchedData.rrmUlUsedMcs as we are
    # going to use that also for the match
    df_ulLaDeltaSinr['ulFdSchedData.rrmUlUsedMcs'] = df_ulLaDeltaSinr['ulLaDeltaSinr.ulUsedMcs']

    # make the match
    df_ulLaDeltaSinr = ul_df.merge(
                          df_ulLaDeltaSinr,
                          how='left',
                          on=['accum_mcs',
                              'ulFdSchedData.rrmUlUsedMcs',
                              'rnti',
                              'lcrId',
                              'physCellId'],
                          suffixes=('_original', '')
                          )

    # verify ulFdSchedData.rrmUlUsedMcs matches ulLaDeltaSinr.ulUsedMcs
    if not (df_ulLaDeltaSinr['ulFdSchedData.rrmUlUsedMcs'].equals(df_ulLaDeltaSinr['ulLaDeltaSinr.ulUsedMcs'])):
        logging.error('Failed to match. ulFdSchedData.rrmUlUsedMcs not equal to ulLaDeltaSinr.ulUsedMcs')

    check_if_LaDeltaSinr_match_successful(df_ulLaDeltaSinr, nr_events2match)
    # drop duplicated rows
    return df_ulLaDeltaSinr.loc[:, ~df_ulLaDeltaSinr.columns.str.endswith('_original')]


def compare_number_of_ulFdSchedData_ulLaDeltaSinr_events(ul_df):
    # number of ulFdSchedData events same as ulLaDeltaSinr events
    ulFdSchedData_nr = ul_df['ulFdSchedData.rrmUlUsedMcs'].count()
    ulLaDeltaSinr_nr = ul_df['ulLaDeltaSinr.ulUsedMcs'].count()
    logging.debug(f'    ulFdSchedData events: {ulFdSchedData_nr}')
    logging.debug(f'    ulLaDeltaSinr events: {ulLaDeltaSinr_nr}')
    if ulFdSchedData_nr != ulLaDeltaSinr_nr:
        logging.warning('  Number of ulFdSchedData events is not the same as ulLaDeltaSinr')
    return ulFdSchedData_nr


def check_preconditions4LaDeltaSinr_matcher(ul_df):
    # check for most important columns for the match (IEs) are in the dataframe
    if not (('ulFdSchedData.rrmUlUsedMcs' in ul_df.columns) and ('ulLaDeltaSinr.ulUsedMcs' in ul_df.columns)):
        logging.error('  Not all columns required are present. Merging will fail')
    logging.debug('  Checking number of events before match:')
    ulFdSchedData_nr = compare_number_of_ulFdSchedData_ulLaDeltaSinr_events(ul_df)
    return ulFdSchedData_nr


def check_if_LaDeltaSinr_match_successful(ul_df, number_events_before_match):
    # verification of integrity
    # check if number of ul data events in the end  is same as before match
    logging.debug('  Checking number of events after match:')
    ulFdSchedData_nr = compare_number_of_ulFdSchedData_ulLaDeltaSinr_events(ul_df)
    if number_events_before_match != ulFdSchedData_nr:
        logging.warning('  Number of ulFdSchedData after the merge is different.'
                        'Possible failure! Check logs manually')
    # check max, min and avg timedifference between matched events
    ul_df['timediff'] = ul_df['timeStamp_shift'] - ul_df['timeStamp']
    max_time = ul_df['timediff'].max()
    min_time = ul_df['timediff'].min()
    avg_time = ul_df['timediff'].mean()
    logging.debug(f'  Max time difference between ulFdSchedData and ulLaDeltaSinr {max_time}')
    logging.debug(f'  Min time difference between ulFdSchedData and ulLaDeltaSinr {min_time}')
    logging.debug(f'  Avg time difference between ulFdSchedData and ulLaDeltaSinr {avg_time}')


def ulFdSchedData_ulLaDeltaSinr_matcher(ul_df):
    """
    Matches ulFdSchedData with corresponding ulLaDeltaSinr in same row.
    Columns from the original ulLaDeltaSinr are removed. After the ulFdSchedData and
    ulLaDeltaSinr will have same timestamp/SFN and slot

    :param ul_df: uplink tti trace dataframe
    :return: the dataframe with ulFdSchedData and corresponding ulLaDeltaSinr in same row
    """
    logging.debug('Start: Matching ulFdSchedData and ulLaDeltaSinr')
    df_list = []
    # filter by cell Id
    cell_list = list(ul_df['physCellId'].unique())
    for cell in cell_list:
        logging.debug(' Matching ulFdSchedData and ulLaDeltaSinr for cell: ' + str(cell))
        df_list.append(
            _ulFdSchedData_ulLaDeltaSinr_matcher_per_cell_using_mcs(ul_df.query(f'physCellId == {cell}').copy())
        )
    # concatenate ul_df from each cell and order according to timestamp
    logging.debug(' Joining back dataframes for all cells')
    ul_df = pd.concat(df_list)
    ul_df.sort_values(by=['timeStamp', 'rnti'], inplace=True)
    logging.debug('End: Matching ulFdSchedData and ulLaDeltaSinr finished')
    return ul_df
