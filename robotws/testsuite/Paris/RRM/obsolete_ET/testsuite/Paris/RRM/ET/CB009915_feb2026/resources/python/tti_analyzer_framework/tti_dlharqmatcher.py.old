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


def fetch_dlHarqRxDataArray_acknack(harq_rx_data_df,
                                    absTimeId,
                                    K1,
                                    lcrId,
                                    rnti,
                                    subcellId,
                                    dlHarqProcessIndex):

    filter_str = ('absTimeId == %d & '
                  'lcrId == %d & '
                  'rnti == %d & '
                  '`dlHarqRxDataArray.harqSubcellId` == %d & '
                  '`dlHarqRxDataArray.dlHarqProcessIndex` == %d')
    ackNack = harq_rx_data_df.query(
        filter_str %
        (absTimeId +
         K1,
         lcrId,
         rnti,
         subcellId,
         dlHarqProcessIndex))[
        [
            'dlHarqRxDataArray.ackNack',
            'dlHarqRxDataArray.speculativeDtxAckDtx']]
    if len(ackNack) > 1:
        logging.error("more than 1 acks found for same dlFdSchedData at absTimeId:%d" % absTimeId)
    if len(ackNack) != 0:
        return {
            'dlFdSchedData.ackNack': ackNack['dlHarqRxDataArray.ackNack'].iloc[0],
            'dlFdSchedData.speculativeDtxAckDtx': ackNack['dlHarqRxDataArray.speculativeDtxAckDtx'].iloc[0]}
    return {'dlFdSchedData.ackNack': '',
            'dlFdSchedData.speculativeDtxAckDtx': ''}


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

    # filter just the relevant events to speed up the process
    harq_rx_data = dl_df.loc[dl_df.filter(
        regex="dlHarqRxDataArray").dropna().index, harq_rx_cols]
    fd_sched_data = dl_df.loc[dl_df.filter(
        regex="dlFdSchedData").dropna().index, fd_sched_cols]

    fd_sched_data = fd_sched_data.merge(
        (fd_sched_data.apply(lambda row: fetch_dlHarqRxDataArray_acknack
                             (
                                 harq_rx_data,
                                 row['absTimeId'],
                                 row['dlFdSchedData.K1'],
                                 row['lcrId'],
                                 row['rnti'],
                                 row['dlFdSchedData.subcellId'],
                                 row['dlFdSchedData.dlHarqProcessIndex']
                             ),
                             axis=1, result_type='expand')),
        left_index=True, right_index=True)
    return dl_df.join(
        fd_sched_data[['dlFdSchedData.ackNack', 'dlFdSchedData.speculativeDtxAckDtx']])
