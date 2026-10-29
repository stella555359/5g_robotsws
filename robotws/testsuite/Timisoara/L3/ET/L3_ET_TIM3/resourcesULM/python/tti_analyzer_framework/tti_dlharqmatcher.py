import logging

pd = None
np = None

MAX_SFN = 1023


def generate_absTimeId(df):
    max_slot = df['slot'].max()
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


def dlharq_matcher(dl_df):

    dl_df = generate_absTimeId(dl_df)
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
    return dl_df.join(result_df[['dlFdSchedData.ackNack', 'dlFdSchedData.speculativeDtxAckDtx']])
