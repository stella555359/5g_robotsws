import logging

import numpy as np
import pandas as pd

MAX_SFN = 1023


def generate_absTimeId(df):
    df['slot'] = pd.to_numeric(df['slot'], errors='coerce')
    df['sfn'] = pd.to_numeric(df['sfn'], errors='coerce')
    valid = df['slot'].notna() & df['sfn'].notna()
    if df.empty or not valid.any():
        df['sfn_slot'] = np.nan
        df['sfn_slot_diff'] = np.nan
        df['absTimeId'] = np.nan
        return df

    max_slot = int(df.loc[valid, 'slot'].max())
    # combine sfn and slot
    df['sfn_slot'] = (df['sfn'] * (max_slot + 1)) + df['slot']

    # calculate differences between adjacent events based on sfn + slot
    df['sfn_slot_diff'] = df['sfn_slot'].diff()
    df.iloc[0, df.columns.get_loc('sfn_slot_diff')] = 0

    # fix the places where the SFN wraps around
    df['sfn_slot_diff'] = df['sfn_slot_diff'] % (
        (MAX_SFN + 1) * (max_slot + 1))

    # calculate the accumulated difference between
    # events and convert it to datetime format
    df['absTimeId'] = df['sfn_slot_diff'].cumsum()
    return df


def generate_absTimeId_separately_for_each_cell(df):
    '''
    It is important to calculate this for each cell if you have
    in TTI trace cells with different number of slots
    '''
    df['absTimeId'] = np.nan
    cell_list = list(df['physCellId'].unique())
    for cell in cell_list:
        filterd_df = df.query(f'physCellId == {cell}').copy()
        filterd_df = generate_absTimeId(filterd_df)
        df.loc[filterd_df.index] = filterd_df
    return df


def dlharq_matcher(dl_df):
    """
    Matches dlFdSchedData with the harq response present in the dlHarqRxDataArray event
    according to the dlHarqProcessIndex and K1 which informs how many slots ahead the
    dlHarqRxDataArray will come after the dlFdSchedData event.
    New columns are added to the data frame: 'dlFdSchedData.ackNack', 'dlFdSchedData.speculativeDtxAckDtx'
    The content of these new columns is copied from ie with same name in the matched dlHarqProcessIndex event

    :param dl_df: tti downlink dataframe
    :return: the dataframe with with new rows
    """
    dl_df = generate_absTimeId_separately_for_each_cell(dl_df)
    common_columns = ["absTimeId", "sfn", "slot", "rnti", "lcrId"]

    fd_sched_cols = common_columns + ["dlFdSchedData.subcellId",
                                      "dlFdSchedData.dlHarqProcessIndex",
                                      "dlFdSchedData.K1"]

    harq_rx_cols = common_columns + ["dlHarqRxDataArray.harqSubcellId",
                                     "dlHarqRxDataArray.dlHarqProcessIndex",
                                     "dlHarqRxDataArray.ackNack",
                                     "dlHarqRxDataArray.speculativeDtxAckDtx"]

    harq_df = dl_df[['absTimeId',
                     'lcrId',
                     'rnti',
                     'dlFdSchedData.K1',
                     'dlFdSchedData.subcellId',
                     'dlHarqRxDataArray.harqSubcellId',
                     'dlFdSchedData.dlHarqProcessIndex',
                     'dlHarqRxDataArray.dlHarqProcessIndex',
                     'dlHarqRxDataArray.ackNack',
                     'dlHarqRxDataArray.speculativeDtxAckDtx']].copy()

    # generate time for where each dlFdSchedData event will find its harq response and put it in harq_time
    harq_df['harq_time'] = harq_df['absTimeId'] + harq_df['dlFdSchedData.K1']

    # create dataframe only with dlFdSchedData event relevant columns
    dlfdsched_table = harq_df[['absTimeId',
                               'lcrId',
                               'rnti',
                               'dlFdSchedData.K1',
                               'dlFdSchedData.dlHarqProcessIndex',
                               'dlFdSchedData.subcellId',
                               'harq_time']].copy()

    # keep the original index in the dlFdSchedData dataframe for later merge back to original frame
    dlfdsched_table['temp_index'] = dlfdsched_table.index

    # create dataframe only with dlHarqRxDataArray event relevant columns wich will be matched against dfFdSchedData
    harq_table = harq_df[['absTimeId',
                          'lcrId',
                          'rnti',
                          'dlHarqRxDataArray.harqSubcellId',
                          'dlHarqRxDataArray.dlHarqProcessIndex',
                          'dlHarqRxDataArray.ackNack',
                          'dlHarqRxDataArray.speculativeDtxAckDtx']].copy()

    # new columns/IE that will be added to the dlFdSchedData taken from dlHarqRxDataArray
    harq_table.rename(
        columns={
            'dlHarqRxDataArray.ackNack': 'dlFdSchedData.ackNack',
            'dlHarqRxDataArray.speculativeDtxAckDtx': 'dlFdSchedData.speculativeDtxAckDtx'},
        inplace=True
    )

    # merge dataframes based on time/K1, rnti lcrId, dlHarqProcessIndex, subcellId
    result_df = dlfdsched_table.merge(
        harq_table,
        left_on=['rnti',
                 'lcrId',
                 'harq_time',
                 'dlFdSchedData.dlHarqProcessIndex',
                 'dlFdSchedData.subcellId'],
        right_on=['rnti',
                  'lcrId',
                  'absTimeId',
                  'dlHarqRxDataArray.dlHarqProcessIndex',
                  'dlHarqRxDataArray.harqSubcellId']
    )

    # Set index back to the original dataframe, which we stored previously in temp_index
    result_df.set_index('temp_index', inplace=True)

    # return the dataframe with the 2 new columns/IE joined according to the index
    return (dl_df.join(result_df[['dlFdSchedData.ackNack', 'dlFdSchedData.speculativeDtxAckDtx']])
            .reset_index(drop=True))


def dlLaDeltaCqiArray_match_correct(df):
    '''
    Checks if the match is done correctly by checking for each cell/rnti
    if sfn is increasing continuously
    '''
    result = True
    cell_list = list(df['physCellId'].unique())
    rnti_list = list(df['rnti'].unique())
    # for each cell/rnti check
    for cell in cell_list:
        for rnti in rnti_list:
            filterd_df = df.query(f'(physCellId == {cell}) & (rnti == {rnti})')
            result = result & filterd_df.dlLaDeltaCqiArray_sfn.is_monotonic_increasing
    return result


def generate_unique_num(df):
    '''
    creates a new column called unique_num, that in combination with the dlHarqProcessIndex creates
    a unique value for each cell/rnti to be used in the match
    '''
    cell_list = list(df['physCellId'].unique())
    rnti_list = list(df['rnti'].unique())
    logging.debug('Cells in trace: ' + str(cell_list))
    logging.debug('Rntis in trace: ' + str(rnti_list))
    # for each cell calculate timestamps and add to list
    dlHarqProcessIndex_col = [col for col in df.columns if col.endswith('dlHarqProcessIndex')][0]
    logging.debug(dlHarqProcessIndex_col)
    df['unique_num'] = df[dlHarqProcessIndex_col]
    for cell in cell_list:
        for rnti in rnti_list:
            logging.debug('Calculating unique combination based on dlHarqProcessIndex for cell: ' +
                          str(cell) + ' rnti: ' + str(rnti))
            df_tmp = df.query(f'(physCellId == {cell}) & (rnti == {rnti})').copy()
            df_tmp['unique_num'] = df_tmp.groupby(dlHarqProcessIndex_col).cumcount()
            df.loc[df_tmp.index] = df_tmp
    return df


def dlLaDeltaCqiArray_matcher(dl_df):
    """
    Matches dlLaDeltaCqiArray event with dlFdSchedData event according to the dlHarqProcessIndex
    the timestamp is kept from the dlFdSchedData event

    :param dl_df: tti downlink dataframe
    :return: dataframe with just the 2 events with matched rows
    """

    # dlFdSchedData
    df_dlFdSchedData = dl_df.loc[:, dl_df.columns.str.startswith(
        ('dlFdSchedData', 'timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId')
    )].copy().dropna(subset=['dlFdSchedData.dlHarqProcessIndex'])
    try:
        # remove dlFdSchedData MSG2 because there is no corresponding dlLaDeltaCqiArray event
        df_dlFdSchedData.drop(
            df_dlFdSchedData[df_dlFdSchedData['dlFdSchedData.dciFormat'] == 'DL_10_MSG2'].index, inplace=True
        )
    except KeyError as error:
        logging.warning(error)
        logging.warning('KeyError: This can cause problems for correct dlharq_matcher')

    # dlLaDeltaCqiArray
    df_dlLaDeltaCqiArray = dl_df.loc[:, dl_df.columns.str.startswith(
        ('dlLaDeltaCqiArray', 'rnti', 'physCellId', 'sfn')
    )].copy().dropna(subset=['dlLaDeltaCqiArray.dlHarqProcessIndex'])
    # create a continuous increasing sfn in df_dlLaDeltaCqiArray for later check of correct match and drop sfn column
    df_dlLaDeltaCqiArray['dlLaDeltaCqiArray_sfn'] = (
        df_dlLaDeltaCqiArray['sfn'] + df_dlLaDeltaCqiArray['sfn'].diff().lt(0).cumsum() * 1024
    ).astype(int)
    df_dlLaDeltaCqiArray = df_dlLaDeltaCqiArray.loc[:, ~df_dlLaDeltaCqiArray.columns.str.startswith('sfn')]

    dlFdSchedData_ie = [i for i in df_dlFdSchedData.columns if 'dlFdSchedData' in i]

    # prepare for merging creating a helper column
    df_dlLaDeltaCqiArray = generate_unique_num(df_dlLaDeltaCqiArray)
    df_dlFdSchedData = generate_unique_num(df_dlFdSchedData)

    # Merge the dataframes on both the index ID and the unique_num to create a unique combination over the trace
    result_df = pd.merge(df_dlFdSchedData, df_dlLaDeltaCqiArray,
                         left_on=['dlFdSchedData.dlHarqProcessIndex', 'unique_num', 'rnti', 'physCellId'],
                         right_on=['dlLaDeltaCqiArray.dlHarqProcessIndex', 'unique_num', 'rnti', 'physCellId'])

    # Drop the unique number column and reset index
    result_df.drop(columns=['unique_num'], inplace=True)
    result_df.reset_index(drop=True, inplace=True)
    result_df.dropna(axis=0, how='all', subset=dlFdSchedData_ie, inplace=True)

    if not dlLaDeltaCqiArray_match_correct(result_df):
        logging.warning('dlLaDeltaCqiArray_matcher probably failed! inconsistency found in sfn of matched event')

    return result_df
