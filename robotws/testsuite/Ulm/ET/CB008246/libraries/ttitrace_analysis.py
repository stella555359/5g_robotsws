# ====================================================================================================[120 characters]
# This is a Python file, which helps to implement TTITraces Analysis used in CB008246 Sub-features
# Team: 'SqdGp66' and 'SqdGp68'
# Email: 'I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com' or 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import warnings
import math

# ET or Feature Specific Libraries:
import numpy as np
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html, normalize_sfn_values

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]

rbi = BuiltIn()


# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]
# Important: Keywords' input parameter should be "path_to_pickle" and not "data_frame" if possible

@log_begin_end_func_name
def get_expected_dl_pmc_values_4tx(path_to_pickle, cell):
    """ This function computes for the expected values of Rank Related DL PM Counters based on Collected TTI Traces
        Suggested pkl file: pkl file with dlharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param cell: cell to analyze

        :returns pmc_values_dict: a dictionary of Rank Related DL PMC Values
    """
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.ackNack',
             'dlFdSchedData.numOfLayers', 'dlFdSchedData.txNumber', 'dlFdSchedData.rrmDlUsedMcs',
             'dlFdSchedData.mcsTable', 'dlFdSchedData.cqiDerivedMcs', 'dlFdSchedData.cqiAlSelection']]
    df = normalize_sfn_values(df)
    df.to_csv(str("%s/manual_analysis_get_expected_dl_pmc_values_4tx.csv" % get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    remove_nack_df = df[df['dlFdSchedData.ackNack'] == 'ACK']
    succ_pdsch_tx_r1_count = remove_nack_df.loc[(remove_nack_df['dlFdSchedData.numOfLayers'] == 'RANK1') &
                                                (remove_nack_df['dlFdSchedData.txNumber'] == 1)].shape[0]
    succ_pdsch_tx_r2_count = remove_nack_df.loc[(remove_nack_df['dlFdSchedData.numOfLayers'] == 'RANK2') &
                                                (remove_nack_df['dlFdSchedData.txNumber'] == 1)].shape[0]
    succ_pdsch_tx_r3_count = remove_nack_df.loc[(remove_nack_df['dlFdSchedData.numOfLayers'] == 'RANK3') &
                                                (remove_nack_df['dlFdSchedData.txNumber'] == 1)].shape[0]
    succ_pdsch_tx_r4_count = remove_nack_df.loc[(remove_nack_df['dlFdSchedData.numOfLayers'] == 'RANK4') &
                                                (remove_nack_df['dlFdSchedData.txNumber'] == 1)].shape[0]
    pmc_values_dict = {'succ_pdsch_r1_count': succ_pdsch_tx_r1_count,
                       'succ_pdsch_r2_count': succ_pdsch_tx_r2_count,
                       'succ_pdsch_r3_count': succ_pdsch_tx_r3_count,
                       'succ_pdsch_r4_count': succ_pdsch_tx_r4_count}
    # ------------------------------------------------------------------------------------------------[120 characters]
    return pmc_values_dict


def get_expected_legacy_mcs_pmc_values(path_to_pickle, dir, subfeature, cell):
    """ This function computes for the expected values of MCS Related Legacy PM Counters based on Collected TTI Traces
        Suggested pkl file: pkl file with dlharqmatcher / ulharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param dir: Specifies direction. Use "dl" for downlink and "ul" for uplink
        :param subfeature: subfeature being tested (A, C, D, or E)
        :param cell: cell to analyze

        :returns mcs_pmc_dict: a dictionary for MCS Related Legacy PM Counters
    """
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
    numOfLayers = '{}FdSchedData.numOfLayers'.format(dir)
    puschTPstate = 'ulFdSchedData.puschTPstate'
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable,
                 usedMcs, numOfLayers]].dropna(subset=[mcsTable])
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable,
                 puschTPstate, usedMcs, numOfLayers]].dropna(subset=[mcsTable])
    df = normalize_sfn_values(df)
    df.to_csv(str("%s/manual_analysis_get_expected_{}_legacy_mcs_pmc_values.csv".format(dir) %
                  get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    used_mcs_0_to_31_df = df[df[usedMcs] < 32]
    qam64_df = used_mcs_0_to_31_df[used_mcs_0_to_31_df[mcsTable] == 'QAM64']

    mcs_pmc_dict = {}
    if dir == 'dl':
        for x in range(0, 32):
            count_tx1 = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                     (qam64_df[txNumber] == 1)].shape[0]
            count_tx2 = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                     (qam64_df[txNumber] == 2)].shape[0]
            count_ack = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                     (qam64_df[ackNack] == 'ACK')].shape[0]
            if x < 29:
                mcs_pmc_dict['M55300C000{:02d}'.format(x)] = str(count_tx1)
                mcs_pmc_dict['M55300C010{:02d}'.format(x)] = str(count_tx1-count_tx2)
                mcs_pmc_dict['M55300C020{:02d}'.format(x)] = str(count_ack)
                mcs_pmc_dict['M55300C030{:02d}'.format(x)] = str(count_ack-count_tx1)

            count_r1 = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                    (qam64_df[numOfLayers] == 'RANK1')].shape[0]
            count_r2 = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                    (qam64_df[numOfLayers] == 'RANK2')].shape[0]
            count_r3 = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                    (qam64_df[numOfLayers] == 'RANK3')].shape[0]
            count_r4 = qam64_df.loc[(qam64_df[usedMcs] == x) &
                                    (qam64_df[numOfLayers] == 'RANK4')].shape[0]
            mcs_pmc_dict['M55301C000{:02d}'.format(x)] = str(count_r1)
            mcs_pmc_dict['M55301C010{:02d}'.format(x)] = str(count_r2)
            mcs_pmc_dict['M55301C020{:02d}'.format(x)] = str(count_r3)
            mcs_pmc_dict['M55301C030{:02d}'.format(x)] = str(count_r4)
    else:
        qam64_cp_ofdm_df = qam64_df[qam64_df[puschTPstate] != 'ENABLED']
        qam64_dfts_ofdm_df = qam64_df[qam64_df[puschTPstate] == 'ENABLED']
        for x in range(0, 32):
            count_cp_ofdm_tx1 = qam64_cp_ofdm_df.loc[(qam64_cp_ofdm_df[usedMcs] == x) &
                                                     (qam64_cp_ofdm_df[txNumber] == 1)].shape[0]
            count_cp_ofdm_succ_ini = qam64_cp_ofdm_df.loc[(qam64_cp_ofdm_df[usedMcs] == x) &
                                                          (qam64_cp_ofdm_df[crcResult] == 'OK') &
                                                          (qam64_cp_ofdm_df[txNumber] == 1)].shape[0]
            count_dfts_ofdm_tx1 = qam64_dfts_ofdm_df.loc[(qam64_dfts_ofdm_df[usedMcs] == x) &
                                                         (qam64_dfts_ofdm_df[txNumber] == 1)].shape[0]
            count_dfts_ofdm_succ_ini = qam64_dfts_ofdm_df.loc[(qam64_dfts_ofdm_df[usedMcs] == x) &
                                                              (qam64_dfts_ofdm_df[crcResult] == 'OK') &
                                                              (qam64_dfts_ofdm_df[txNumber] == 1)].shape[0]
            count_cp_ofdm_tx2 = qam64_cp_ofdm_df.loc[(qam64_cp_ofdm_df[usedMcs] == x) &
                                                     (qam64_cp_ofdm_df[txNumber] == 2)].shape[0]
            count_dfts_ofdm_tx2 = qam64_dfts_ofdm_df.loc[(qam64_dfts_ofdm_df[usedMcs] == x) &
                                                         (qam64_dfts_ofdm_df[txNumber] == 2)].shape[0]

            count_cp_ofdm_unsucc_tx = qam64_cp_ofdm_df.loc[(qam64_cp_ofdm_df[usedMcs] == x) &
                                                           (qam64_cp_ofdm_df[crcResult] == 'NOK') &
                                                           (qam64_cp_ofdm_df[txNumber] == 5)].shape[0]
            count_succ_any = count_cp_ofdm_tx1 - count_cp_ofdm_unsucc_tx
            if x < 29:
                mcs_pmc_dict['M55302C000{:02d}'.format(x)] = str(count_cp_ofdm_tx1)
                mcs_pmc_dict['M55302C040{:02d}'.format(x)] = str(count_cp_ofdm_succ_ini)
            if x < 28:
                mcs_pmc_dict['M55302C060{:02d}'.format(x)] = str(count_dfts_ofdm_tx1)
                mcs_pmc_dict['M55302C080{:02d}'.format(x)] = str(count_dfts_ofdm_succ_ini)
            mcs_pmc_dict['M55302C030{:02d}'.format(x)] = str(count_cp_ofdm_unsucc_tx)
            mcs_pmc_dict['M55302C050{:02d}'.format(x)] = str(count_succ_any)
    # -------------------------------------------------------------------------------------------------[120 characters]
    return mcs_pmc_dict


@log_begin_end_func_name
def get_expected_mcs_new_pmc_values(path_to_pickle, dir, cell, max_dl_harq_tx=5, max_ul_harq_tx=5):
    """ This function computes for the expected values of MCS Related New PM Counters based on Collected TTI Traces
        Suggested pkl file: pkl file with dlharqmatcher / ulharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param dir: Specifies direction. Use "dl" for downlink and "ul" for uplink=
        :param cell: cell to analyze
        :param max_dl_harq_tx: maximum dl retransmission configured in SCF
        :param max_ul_harq_tx: masimum ul retransmission configured in SCF=

        :returns mcs_pmc_dict: a dictionary for the following PM Counters:
        DL:
        M55366C01000-28   PDSCH_INITX_LOWSE_MCS_00-28
        M55366C02000-28   PDSCH_SUCC_INI_LOWSE_MCS_00-28
        M55366C03000-28   PDSCH_SUCC_ANY_LOWSE_MCS_00-31
        M55366C04000-28   PDSCH_UNSUCC_LOWSE_MCS_00-31
        M55368C00000-28   PDSCH_RANK1_LOWSE_MCS_00-31
        M55368C01000-28   PDSCH_RANK2_LOWSE_MCS_00-31
        M55368C02000-28   PDSCH_RANK3_LOWSE_MCS_00-31
        M55368C03000-28   PDSCH_RANK4_LOWSE_MCS_00-31
        M55366C05000-28   PDSCH_INI_VOL_LOWSE_MCS_00-28
        M55366C06000-31   PDSCH_INIRE_VOL_LOWSE_MCS_00-31

        UL:
        M55367C01000-28   PUSCH_CP_INI_LOWSE_MCS_00-28
        M55367C02000-28   PUSCH_CP_SUCC_INI_LOWSE_MCS_00-28
        M55367C03000-28   PUSCH_CP_SUCC_ANY_LOWSE_MCS_00-31
        M55367C04000-28   PUSCH_CP_UNSUCC_LOWSE_MCS_00-31
        M55368C04000-28   PUSCH_CP_RANK1_LOWSE_MCS_00-31
        M55368C05000-28   PUSCH_CP_RANK2_LOWSE_MCS_00-31
        M55367C05000-28   PUSCH_CP_INI_VOL_LOWSE_MCS_00-28
        M55367C06000-31   PUSCH_CP_INRE_VOL_LOWSE_MCS_00-31
    """
    # ------------------------------------------------------------------------------------------------[120 characters]
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    usedMcs = '{}FdSchedData.rrm{}UsedMcs'.format(dir, dir.capitalize())
    numOfLayers = '{}FdSchedData.numOfLayers'.format(dir)
    tbSize = '{}FdSchedData.tbSize'.format(dir)
    puschTPstate = 'ulFdSchedData.puschTPstate'
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable, usedMcs,
                 numOfLayers, tbSize]].dropna(subset=[mcsTable])
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable, usedMcs,
                 numOfLayers, tbSize, puschTPstate]].dropna(subset=[mcsTable])
    df = normalize_sfn_values(df)
    df.to_csv(str("%s/manual_analysis_get_expected_{}_new_mcs_pmc_values.csv".format(dir) %
                  get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    used_mcs_0_to_28_df = df[df[usedMcs] < 29]
    lowse_df = used_mcs_0_to_28_df[used_mcs_0_to_28_df[mcsTable] == 'QAM64LOWSE']

    mcs_pmc_dict = {}
    mcs_pmc_dict_description = {}
    if dir == 'dl':
        for x in range(0, 29):
            count_initx = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                       (lowse_df[txNumber] == 1)].shape[0]
            count_succ_initx = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                            (lowse_df[txNumber] == 1) &
                                            (lowse_df[ackNack] == 'ACK')].shape[0]
            count_unsucc = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                        (lowse_df[txNumber] == int(max_dl_harq_tx)) &
                                        (lowse_df[ackNack] == 'NACK')].shape[0]
            count_succ_any = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                          (lowse_df[ackNack] == 'ACK')].shape[0]
            mcs_pmc_dict['M55366C010{:02d}'.format(x)] = str(count_initx)
            mcs_pmc_dict_description['M55366C010{:02d}'.format(x)] = (
                f'PDSCH_INITX_LOWSE_MCS_{x:02} ; '
                f'PDSCH initial transmissions with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55366C020{:02d}'.format(x)] = str(count_succ_initx)
            mcs_pmc_dict_description['M55366C020{:02d}'.format(x)] = (
                f'PDSCH_SUCC_INI_LOWSE_MCS_{x:02} ; '
                f'Successful PDSCH transmissions by initial transmission with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55366C030{:02d}'.format(x)] = str(count_succ_any)
            mcs_pmc_dict_description['M55366C030{:02d}'.format(x)] = (
                f'PDSCH_SUCC_ANY_LOWSE_MCS_{x:02} ; '
                f'Successful PDSCH transmissions by any transmission with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55366C040{:02d}'.format(x)] = str(count_unsucc)
            mcs_pmc_dict_description['M55366C040{:02d}'.format(x)] = (
                f'PDSCH_UNSUCC_LOWSE_MCS_{x:02} ; '
                f'Unsuccessful PDSCH transmissions by last HARQ reTx with LowSE MCS table using MCS {x:02}')

            count_r1 = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                    (lowse_df[numOfLayers] == 'RANK1')].shape[0]
            count_r2 = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                    (lowse_df[numOfLayers] == 'RANK2')].shape[0]
            count_r3 = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                    (lowse_df[numOfLayers] == 'RANK3')].shape[0]
            count_r4 = lowse_df.loc[(lowse_df[usedMcs] == x) &
                                    (lowse_df[numOfLayers] == 'RANK4')].shape[0]
            mcs_pmc_dict['M55368C000{:02d}'.format(x)] = str(count_r1)
            mcs_pmc_dict_description['M55368C000{:02d}'.format(x)] = (
                f'PDSCH_RANK1_LOWSE_MCS_{x:02} ; '
                f'PDSCH transmissions in Rank1 with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55368C010{:02d}'.format(x)] = str(count_r2)
            mcs_pmc_dict_description['M55368C010{:02d}'.format(x)] = (
                f'PDSCH_RANK2_LOWSE_MCS_{x:02} ; '
                f'PDSCH transmissions in Rank2 with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55368C020{:02d}'.format(x)] = str(count_r3)
            mcs_pmc_dict_description['M55368C020{:02d}'.format(x)] = (
                f'PDSCH_RANK3_LOWSE_MCS_{x:02} ; '
                f'PDSCH transmissions in Rank3 with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55368C030{:02d}'.format(x)] = str(count_r4)
            mcs_pmc_dict_description['M55368C030{:02d}'.format(x)] = (
                f'PDSCH_RANK4_LOWSE_MCS_{x:02} ; '
                f'PDSCH transmissions in Rank4 with LowSE MCS table using MCS {x:02}')

            tbSize_ini_mcs_x_df = lowse_df[(lowse_df[usedMcs] == x) & (lowse_df[txNumber] == 1)]
            sum_tbSize_ini_mcs_x = tbSize_ini_mcs_x_df[tbSize].sum()
            tbSize_mcs_x_df = lowse_df[(lowse_df[usedMcs] == x)]
            sum_tbSize_mcs_x = tbSize_mcs_x_df[tbSize].sum()
            mcs_pmc_dict['M55366C050{:02d}'.format(x)] = str(int(sum_tbSize_ini_mcs_x / 8))
            mcs_pmc_dict_description['M55366C050{:02d}'.format(x)] = (
                f'PDSCH_INI_VOL_LOWSE_MCS_{x:02} ; '
                f'Initial transmission volume on PDSCH with LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55366C060{:02d}'.format(x)] = str(int(sum_tbSize_mcs_x / 8))
            mcs_pmc_dict_description['M55366C060{:02d}'.format(x)] = (
                f'PDSCH_INIRE_VOL_LOWSE_MCS_{x:02} ; '
                f'Initial and retransmission volume on PDSCH with LowSE MCS table using MCS {x:02}')

    else:
        lowse_cp_ofdm_df = lowse_df[lowse_df[puschTPstate] != 'ENABLED']
        for x in range(0, 29):
            count_tx1 = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                             (lowse_cp_ofdm_df[txNumber] == 1)].shape[0]
            count_tx2 = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                             (lowse_cp_ofdm_df[txNumber] == 2)].shape[0]
            count_succ_tx1 = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                                  (lowse_cp_ofdm_df[crcResult] == 'OK') &
                                                  (lowse_cp_ofdm_df[txNumber] == 1)].shape[0]
            count_unsucc = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                                (lowse_cp_ofdm_df[crcResult] == 'NOK') &
                                                (lowse_cp_ofdm_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_succ_any = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                                  (lowse_cp_ofdm_df[crcResult] == 'OK')].shape[0]
            mcs_pmc_dict['M55367C010{:02d}'.format(x)] = str(count_tx1)
            mcs_pmc_dict_description['M55367C010{:02d}'.format(x)] = (
                f'PUSCH_CP_INI_LOWSE_MCS_{x:02} ; '
                f'PUSCH initial transmissions with CP-OFDM and LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55367C020{:02d}'.format(x)] = str(count_succ_tx1)
            mcs_pmc_dict_description['M55367C020{:02d}'.format(x)] = (
                f'PUSCH_CP_SUCC_INI_LOWSE_MCS_{x:02} ; '
                f'Successful PUSCH transmissions by initial transmission with CP-OFDM and LowSE MCS table using MCS '
                f'{x:02}')
            mcs_pmc_dict['M55367C030{:02d}'.format(x)] = str(count_succ_any)
            mcs_pmc_dict_description['M55367C030{:02d}'.format(x)] = (
                f'PUSCH_CP_SUCC_ANY_LOWSE_MCS_{x:02} ; '
                f'Successful PUSCH transmissions by any transmission with CP-OFDM and LowSE MCS table using MCS '
                f'{x:02}')
            mcs_pmc_dict['M55367C040{:02d}'.format(x)] = str(count_unsucc)
            mcs_pmc_dict_description['M55367C040{:02d}'.format(x)] = (
                f'PUSCH_CP_UNSUCC_LOWSE_MCS_{x:02} ; '
                f'Unsuccessful PUSCH transmissions by last HARQ reTx with CP-OFDM and LowSE MCS table using MCS '
                f'{x:02}')

            count_r1 = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                            (lowse_cp_ofdm_df[numOfLayers] == 'RANK1')].shape[0]
            count_r2 = lowse_cp_ofdm_df.loc[(lowse_cp_ofdm_df[usedMcs] == x) &
                                            (lowse_cp_ofdm_df[numOfLayers] == 'RANK2')].shape[0]
            mcs_pmc_dict['M55368C040{:02d}'.format(x)] = str(count_r1)
            mcs_pmc_dict_description['M55368C040{:02d}'.format(x)] = (
                f'PUSCH_CP_RANK1_LOWSE_MCS_{x:02} ; '
                f'PUSCH transmissions in Rank1 with CP-OFDM and LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55368C050{:02d}'.format(x)] = str(count_r2)
            mcs_pmc_dict_description['M55368C050{:02d}'.format(x)] = (
                f'PUSCH_CP_RANK2_LOWSE_MCS_{x:02} ; '
                f'PUSCH transmissions in Rank2 with CP-OFDM and LowSE MCS table using MCS {x:02}')

            tbSize_ini_mcs_x_df = lowse_cp_ofdm_df[(lowse_cp_ofdm_df[usedMcs] == x) & (lowse_cp_ofdm_df[txNumber] == 1)]
            sum_tbSize_ini_mcs_x = tbSize_ini_mcs_x_df[tbSize].sum()
            tbSize_mcs_x_df = lowse_cp_ofdm_df[(lowse_cp_ofdm_df[usedMcs] == x)]
            sum_tbSize_mcs_x = tbSize_mcs_x_df[tbSize].sum()
            mcs_pmc_dict['M55367C050{:02d}'.format(x)] = str(int(sum_tbSize_ini_mcs_x / 8))
            mcs_pmc_dict_description['M55367C050{:02d}'.format(x)] = (
                f'PUSCH_CP_INI_VOL_LOWSE_MCS_{x:02} ; '
                f'Initial transmission volume on PUSCH with CP-OFDM and LowSE MCS table using MCS {x:02}')
            mcs_pmc_dict['M55367C060{:02d}'.format(x)] = str(int(sum_tbSize_mcs_x / 8))
            mcs_pmc_dict_description['M55367C060{:02d}'.format(x)] = (
                f'PUSCH_CP_INRE_VOL_LOWSE_MCS_{x:02} ; '
                f'Initial and retransmission volume on PUSCH with CP-OFDM and LowSE MCS table using MCS 00 {x:02}')
    # -------------------------------------------------------------------------------------------------[120 characters]
    return mcs_pmc_dict, mcs_pmc_dict_description


@log_begin_end_func_name
def get_expected_new_pmc_values(path_to_pickle, dir, subfeature, cell, max_dl_harq_tx=5, max_ul_harq_tx=5,
                                targetBlerPrf1=0.01, targetBlerPrf2=0.009, sw_build='SBTS00'):
    """ This function computes for the expected values of new DL PM Counters based on Collected TTI Traces.
        Suggested pkl file: pkl file with dlharqmatcher / ulharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param dir: Specifies direction. Use "dl" for downlink and "ul" for uplink
        :param subfeature: subfeature being tested (A, C, D, or E)
        :param cell: cell to analyze
        :param max_dl_harq_tx: maximum dl retransmission configured in SCF
        :param max_ul_harq_tx: masimum ul retransmission configured in SCF
        :param targetBlerPrf1: configured targetBler for LA profile 1
        :param targetBlerPrf2: configured targerBler for LA profile 2

        :returns new_pmc_dict: a dictionary for the following PM Counters:

        M55366C00001-4    (A) PDSCH init tx with LowSE MCS table using LA BLER Target from NRPDSCHHRLA PRFL1 and 2
        M55367C00001-4    (C) PUSCH init tx with LowSE MCS table using LA BLER Target from NRPUSCHHRLA PRFL1 and 2
        M55366C00005      (D) PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1
        M55366C00006      (D) PDSCH_UNSUCC_LOWSE_HRD_PRFL1
        M55366C00007      (D) PDSCH_SUCC_ANY_LOWSE_HRD_PRFL2
        M55366C00008      (D) PDSCH_UNSUCC_LOWSE_HRD_PRFL2
        M55366C00009      (D) PDSCH_INITX_LOWSE_BR
        M55366C00010      (D) PDSCH_SUCC_INI_LOWSE_BR
        M55366C00011      (D) PDSCH_SUCC_ANY_LOWSE_BR
        M55366C00012      (D) PDSCH_UNSUCC_LOWSE_BR
        M55367C00005      (E) PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1
        M55367C00006      (E) PUSCH_UNSUCC_LOWSE_HRD_PRFL1
        M55367C00007      (E) PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2
        M55367C00008      (E) PUSCH_UNSUCC_LOWSE_HRD_PRFL2
        M55367C00009      (E) PUSCH_INITX_LOWSE_BR
        M55367C00010      (E) PUSCH_SUCC_INI_LOWSE_BR
        M55367C00011      (E) PUSCH_SUCC_ANY_LOWSE_BR
        M55367C00012      (E) PUSCH_UNSUCC_LOWSE_BR
    """
    logging.info("path_to_pickle = %s" % path_to_pickle)
    logging.info("dir = %s" % dir)
    logging.info("subfeature = %s" % subfeature)
    logging.info("cell = %s" % cell)
    logging.info("max_dl_harq_tx = %s" % max_dl_harq_tx)
    logging.info("max_ul_harq_tx = %s" % max_ul_harq_tx)
    logging.info("targetBlerPrf1 = %s" % targetBlerPrf1)
    logging.info("targetBlerPrf2 = %s" % targetBlerPrf2)
    logging.info("sw_build = %s" % sw_build)
    # ------------------------------------------------------------------------------------------------[120 characters]
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    laMode = '{}FdSchedData.laMode'.format(dir)
    if dir == 'ul':
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
        targetBlerPrf1 = targetBlerPrf1 * 1000
    else:
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    puschTPstate = 'ulFdSchedData.puschTPstate'
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable,
                 laMode, targetBLER]].dropna(subset=[mcsTable])
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable,
                 puschTPstate, laMode, targetBLER]].dropna(subset=[mcsTable])
    df = normalize_sfn_values(df)
    # Normalize string columns to uppercase (TTI trace data may use camelCase)
    for col in [mcsTable, laMode]:
        series = df[col].astype(str).str.upper()
        df[col] = series.where(series != 'NAN', other=np.nan)
    if dir == 'dl':
        series = df[ackNack].astype(str).str.upper()
        df[ackNack] = series.where(series != 'NAN', other=np.nan)
    else:
        series = df[crcResult].astype(str).str.upper()
        df[crcResult] = series.where(series != 'NAN', other=np.nan)
    df.to_csv(str("%s/manual_analysis_get_expected_{}_new_pmc_values.csv".format(dir) %
                  get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # Round targetBLER to avoid float32 vs float64 precision mismatch
    df[targetBLER] = df[targetBLER].round(7)
    # ------------------------------------------------------------------------------------------------[120 characters]
    qam64lowse_br_df = df[(df[mcsTable] == 'QAM64LOWSE') & (df[laMode] == 'BASICRELIABILITY')]
    qam64lowse_hr_df = df[(df[mcsTable] == 'QAM64LOWSE') & (df[laMode] == 'HIGHRELIABILITY')]
    qam64_br_df = df[(df[mcsTable] == 'QAM64') & (df[laMode] == 'BASICRELIABILITY')]
    qam64_hr_df = df[(df[mcsTable] == 'QAM64') & (df[laMode] == 'HIGHRELIABILITY')]

    if subfeature == 'G' or subfeature == 'I':
        prfl1_df = qam64_hr_df[qam64_hr_df[targetBLER] == targetBlerPrf1]
        prfl2_df = qam64_hr_df[qam64_hr_df[targetBLER] == targetBlerPrf2]
    else:
        prfl1_df = qam64lowse_hr_df[qam64lowse_hr_df[targetBLER] == targetBlerPrf1]
        prfl2_df = qam64lowse_hr_df[qam64lowse_hr_df[targetBLER] == targetBlerPrf2]

    count_initx_prfl1 = prfl1_df.loc[prfl1_df[txNumber] == 1].shape[0]
    count_initx_prfl2 = prfl2_df.loc[prfl2_df[txNumber] == 1].shape[0]

    new_pmc_dict = {}

    if dir == 'dl':
        count_tx2_prfl1 = prfl1_df.loc[prfl1_df[txNumber] == 2].shape[0]
        count_succ_initx_prfl1 = count_initx_prfl1 - count_tx2_prfl1
        count_tx2_prfl2 = prfl2_df.loc[prfl2_df[txNumber] == 2].shape[0]
        count_succ_initx_prfl2 = count_initx_prfl2 - count_tx2_prfl2
        new_pmc_dict['M55366C00001'] = str(count_initx_prfl1)
        new_pmc_dict['M55366C00002'] = str(count_succ_initx_prfl1)
        new_pmc_dict['M55366C00003'] = str(count_initx_prfl2)
        new_pmc_dict['M55366C00004'] = str(count_succ_initx_prfl2)
        if subfeature == 'D' or subfeature == 'G':
            count_unsucc_prfl1 = prfl1_df.loc[(prfl1_df[txNumber] == int(max_dl_harq_tx)) &
                                              (prfl1_df[ackNack] == 'NACK')].shape[0]
            count_unsucc_prfl2 = prfl2_df.loc[(prfl2_df[txNumber] == int(max_dl_harq_tx)) &
                                              (prfl2_df[ackNack] == 'NACK')].shape[0]
            count_succ_any_prfl1 = count_initx_prfl1 - count_unsucc_prfl1
            count_succ_any_prfl2 = count_initx_prfl2 - count_unsucc_prfl2
            if subfeature == 'G':
                count_initx_br = qam64_br_df.loc[qam64_br_df[txNumber] == 1].shape[0]
                count_tx2_br = qam64_br_df.loc[qam64_br_df[txNumber] == 2].shape[0]
                count_succ_initx_br = count_initx_br - count_tx2_br
                count_unsucc_br = qam64_br_df.loc[(qam64_br_df[txNumber] == int(max_dl_harq_tx)) &
                                                  (qam64_br_df[ackNack] == 'NACK')].shape[0]
            else:
                count_initx_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 1].shape[0]
                count_tx2_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 2].shape[0]
                count_succ_initx_br = count_initx_br - count_tx2_br
                count_unsucc_br = qam64lowse_br_df.loc[(qam64lowse_br_df[txNumber] == int(max_dl_harq_tx)) &
                                                       (qam64lowse_br_df[ackNack] == 'NACK')].shape[0]
            count_succ_any_br = count_initx_br - count_unsucc_br
            new_pmc_dict['M55366C00005'] = str(count_succ_any_prfl1)
            new_pmc_dict['M55366C00006'] = str(count_unsucc_prfl1)
            new_pmc_dict['M55366C00007'] = str(count_succ_any_prfl2)
            new_pmc_dict['M55366C00008'] = str(count_unsucc_prfl2)
            new_pmc_dict['M55366C00009'] = str(count_initx_br)
            new_pmc_dict['M55366C00010'] = str(count_succ_initx_br)
            new_pmc_dict['M55366C00011'] = str(count_succ_any_br)
            new_pmc_dict['M55366C00012'] = str(count_unsucc_br)
    else:
        count_succ_initx_prfl1 = prfl1_df.loc[(prfl1_df[txNumber] == 1) &
                                              (prfl1_df[crcResult] == 'OK')].shape[0]
        count_succ_initx_prfl2 = prfl2_df.loc[(prfl2_df[txNumber] == 1) &
                                              (prfl2_df[crcResult] == 'OK')].shape[0]
        new_pmc_dict['M55367C00001'] = str(count_initx_prfl1)
        new_pmc_dict['M55367C00002'] = str(count_succ_initx_prfl1)
        new_pmc_dict['M55367C00003'] = str(count_initx_prfl2)
        new_pmc_dict['M55367C00004'] = str(count_succ_initx_prfl2)
        if subfeature == 'E' or subfeature == 'I':
            count_unsucc_prfl1 = prfl1_df.loc[(prfl1_df[crcResult] == 'NOK') &
                                              (prfl1_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_unsucc_prfl2 = prfl2_df.loc[(prfl2_df[crcResult] == 'NOK') &
                                              (prfl2_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_succ_any_prfl1 = prfl1_df.loc[(prfl1_df[crcResult] == 'OK')].shape[0]
            count_succ_any_prfl2 = prfl2_df.loc[(prfl2_df[crcResult] == 'OK')].shape[0]
            if subfeature == 'I':
                count_initx_br = qam64_br_df.loc[qam64_br_df[txNumber] == 1].shape[0]
                count_tx2_br = qam64_br_df.loc[qam64_br_df[txNumber] == 2].shape[0]
                count_unsucc_br = qam64_br_df.loc[(qam64_br_df[crcResult] == 'NOK') &
                                                  (qam64_br_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            else:
                count_initx_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 1].shape[0]
                count_tx2_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 2].shape[0]
                count_unsucc_br = qam64lowse_br_df.loc[(qam64lowse_br_df[crcResult] == 'NOK') &
                                                       (qam64lowse_br_df[txNumber] == int(max_ul_harq_tx))].shape[0]

            count_succ_initx_br = count_initx_br - count_tx2_br
            count_succ_any_br = count_initx_br - count_unsucc_br
            new_pmc_dict['M55367C00005'] = str(count_succ_any_prfl1)
            new_pmc_dict['M55367C00006'] = str(count_unsucc_prfl1)
            new_pmc_dict['M55367C00007'] = str(count_succ_any_prfl2)
            new_pmc_dict['M55367C00008'] = str(count_unsucc_prfl2)
            new_pmc_dict['M55367C00009'] = str(count_initx_br)
            new_pmc_dict['M55367C00010'] = str(count_succ_initx_br)
            new_pmc_dict['M55367C00011'] = str(count_succ_any_br)
            new_pmc_dict['M55367C00012'] = str(count_unsucc_br)

    # -------------------------------------------------------------------------------------------------[120 characters]
    return new_pmc_dict


@log_begin_end_func_name
def get_expected_lowse_pmc_values(path_to_pickle, dir, subfeature, cell, max_dl_harq_tx=5, max_ul_harq_tx=5,
                                  targetBlerPrf1=0.01, targetBlerPrf2=0.009, sw_build='SBTS00'):
    """ This function computes for the expected values of new DL PM Counters based on Collected TTI Traces.
        Suggested pkl file: pkl file with dlharqmatcher / ulharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param dir: Specifies direction. Use "dl" for downlink and "ul" for uplink
        :param subfeature: subfeature being tested (A, C, D, or E)
        :param cell: cell to analyze
        :param max_dl_harq_tx: maximum dl retransmission configured in SCF
        :param max_ul_harq_tx: masimum ul retransmission configured in SCF
        :param targetBlerPrf1: configured targetBler for LA profile 1
        :param targetBlerPrf2: configured targerBler for LA profile 2

        :returns new_pmc_dict: a dictionary for the following PM Counters:

        M55366C00001-4    (A) PDSCH init tx with LowSE MCS table using LA BLER Target from NRPDSCHHRLA PRFL1 and 2
        M55367C00001-4    (C) PUSCH init tx with LowSE MCS table using LA BLER Target from NRPUSCHHRLA PRFL1 and 2
        M55366C00005      (D) PDSCH_SUCC_ANY_LOWSE_HRD_PRFL1
        M55366C00006      (D) PDSCH_UNSUCC_LOWSE_HRD_PRFL1
        M55366C00007      (D) PDSCH_SUCC_ANY_LOWSE_HRD_PRFL2
        M55366C00008      (D) PDSCH_UNSUCC_LOWSE_HRD_PRFL2
        M55366C00009      (D) PDSCH_INITX_LOWSE_BR
        M55366C00010      (D) PDSCH_SUCC_INI_LOWSE_BR
        M55366C00011      (D) PDSCH_SUCC_ANY_LOWSE_BR
        M55366C00012      (D) PDSCH_UNSUCC_LOWSE_BR
        M55367C00005      (E) PUSCH_SUCC_ANY_LOWSE_HRD_PRFL1
        M55367C00006      (E) PUSCH_UNSUCC_LOWSE_HRD_PRFL1
        M55367C00007      (E) PUSCH_SUCC_ANY_LOWSE_HRD_PRFL2
        M55367C00008      (E) PUSCH_UNSUCC_LOWSE_HRD_PRFL2
        M55367C00009      (E) PUSCH_INITX_LOWSE_BR
        M55367C00010      (E) PUSCH_SUCC_INI_LOWSE_BR
        M55367C00011      (E) PUSCH_SUCC_ANY_LOWSE_BR
        M55367C00012      (E) PUSCH_UNSUCC_LOWSE_BR
    """
    logging.info("path_to_pickle = %s" % path_to_pickle)
    logging.info("dir = %s" % dir)
    logging.info("subfeature = %s" % subfeature)
    logging.info("cell = %s" % cell)
    logging.info("max_dl_harq_tx = %s" % max_dl_harq_tx)
    logging.info("max_ul_harq_tx = %s" % max_ul_harq_tx)
    logging.info("targetBlerPrf1 = %s" % targetBlerPrf1)
    logging.info("targetBlerPrf2 = %s" % targetBlerPrf2)
    logging.info("sw_build = %s" % sw_build)
    # ------------------------------------------------------------------------------------------------[120 characters]
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    laMode = '{}FdSchedData.laMode'.format(dir)
    if dir == 'ul':
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    else:
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable,
                 laMode, targetBLER]].dropna(subset=[mcsTable])
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable,
                 laMode, targetBLER]].dropna(subset=[mcsTable])
    df = normalize_sfn_values(df)
    df.to_csv(str("%s/manual_analysis_get_expected_{}_new_pmc_values.csv".format(dir) %
                  get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    qam64lowse_br_df = df[(df[mcsTable] == 'QAM64LOWSE') & (df[laMode] == 'BASICRELIABILITY')]
    qam64lowse_hr_df = df[(df[mcsTable] == 'QAM64LOWSE') & (df[laMode] == 'HIGHRELIABILITY')]

    if subfeature == 'G' or subfeature == 'I':
        prfl1_df = qam64lowse_hr_df[qam64lowse_hr_df[targetBLER] == targetBlerPrf1]
        prfl2_df = qam64lowse_hr_df[qam64lowse_hr_df[targetBLER] == targetBlerPrf2]

    count_initx_prfl1 = prfl1_df.loc[prfl1_df[txNumber] == 1].shape[0]
    count_initx_prfl2 = prfl2_df.loc[prfl2_df[txNumber] == 1].shape[0]

    new_pmc_dict = {}

    if dir == 'dl':
        count_tx2_prfl1 = prfl1_df.loc[prfl1_df[txNumber] == 2].shape[0]
        count_succ_initx_prfl1 = count_initx_prfl1 - count_tx2_prfl1
        count_tx2_prfl2 = prfl2_df.loc[prfl2_df[txNumber] == 2].shape[0]
        count_succ_initx_prfl2 = count_initx_prfl2 - count_tx2_prfl2
        new_pmc_dict['M55366C00001'] = str(count_initx_prfl1)
        new_pmc_dict['M55366C00002'] = str(count_succ_initx_prfl1)
        new_pmc_dict['M55366C00003'] = str(count_initx_prfl2)
        new_pmc_dict['M55366C00004'] = str(count_succ_initx_prfl2)
        if subfeature == 'D' or subfeature == 'G':
            count_unsucc_prfl1 = prfl1_df.loc[(prfl1_df[txNumber] == int(max_dl_harq_tx)) &
                                              (prfl1_df[ackNack] == 'NACK')].shape[0]
            count_unsucc_prfl2 = prfl2_df.loc[(prfl2_df[txNumber] == int(max_dl_harq_tx)) &
                                              (prfl2_df[ackNack] == 'NACK')].shape[0]
            count_succ_any_prfl1 = count_initx_prfl1 - count_unsucc_prfl1
            count_succ_any_prfl2 = count_initx_prfl2 - count_unsucc_prfl2
            count_initx_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 1].shape[0]
            count_tx2_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 2].shape[0]
            count_succ_initx_br = count_initx_br - count_tx2_br
            count_unsucc_br = qam64lowse_br_df.loc[(qam64lowse_br_df[txNumber] == int(max_dl_harq_tx)) &
                                                   (qam64lowse_br_df[ackNack] == 'NACK')].shape[0]
            count_succ_any_br = count_initx_br - count_unsucc_br
            new_pmc_dict['M55366C00005'] = str(count_succ_any_prfl1)
            new_pmc_dict['M55366C00006'] = str(count_unsucc_prfl1)
            new_pmc_dict['M55366C00007'] = str(count_succ_any_prfl2)
            new_pmc_dict['M55366C00008'] = str(count_unsucc_prfl2)
            new_pmc_dict['M55366C00009'] = str(count_initx_br)
            new_pmc_dict['M55366C00010'] = str(count_succ_initx_br)
            new_pmc_dict['M55366C00011'] = str(count_succ_any_br)
            new_pmc_dict['M55366C00012'] = str(count_unsucc_br)
    else:
        count_succ_initx_prfl1 = prfl1_df.loc[(prfl1_df[txNumber] == 1) &
                                              (prfl1_df[crcResult] == 'OK')].shape[0]
        count_succ_initx_prfl2 = prfl2_df.loc[(prfl2_df[txNumber] == 1) &
                                              (prfl2_df[crcResult] == 'OK')].shape[0]
        new_pmc_dict['M55367C00001'] = str(count_initx_prfl1)
        new_pmc_dict['M55367C00002'] = str(count_succ_initx_prfl1)
        new_pmc_dict['M55367C00003'] = str(count_initx_prfl2)
        new_pmc_dict['M55367C00004'] = str(count_succ_initx_prfl2)
        if subfeature == 'E' or subfeature == 'I':
            count_unsucc_prfl1 = prfl1_df.loc[(prfl1_df[crcResult] == 'NOK') &
                                              (prfl1_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_unsucc_prfl2 = prfl2_df.loc[(prfl2_df[crcResult] == 'NOK') &
                                              (prfl2_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_succ_any_prfl1 = prfl1_df.loc[(prfl1_df[crcResult] == 'OK')].shape[0]
            count_succ_any_prfl2 = prfl2_df.loc[(prfl2_df[crcResult] == 'OK')].shape[0]
            count_initx_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 1].shape[0]
            count_tx2_br = qam64lowse_br_df.loc[qam64lowse_br_df[txNumber] == 2].shape[0]
            count_unsucc_br = qam64lowse_br_df.loc[(qam64lowse_br_df[crcResult] == 'NOK') &
                                                   (qam64lowse_br_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_succ_initx_br = count_initx_br - count_tx2_br
            count_succ_any_br = count_initx_br - count_unsucc_br
            new_pmc_dict['M55367C00005'] = str(count_succ_any_prfl1)
            new_pmc_dict['M55367C00006'] = str(count_unsucc_prfl1)
            new_pmc_dict['M55367C00007'] = str(count_succ_any_prfl2)
            new_pmc_dict['M55367C00008'] = str(count_unsucc_prfl2)
            new_pmc_dict['M55367C00009'] = str(count_initx_br)
            new_pmc_dict['M55367C00010'] = str(count_succ_initx_br)
            new_pmc_dict['M55367C00011'] = str(count_succ_any_br)
            new_pmc_dict['M55367C00012'] = str(count_unsucc_br)

    # -------------------------------------------------------------------------------------------------[120 characters]
    return new_pmc_dict


@log_begin_end_func_name
def get_expected_64qam_pmc_values(path_to_pickle, dir, subfeature, cell, max_dl_harq_tx=5, max_ul_harq_tx=5,
                                  targetBlerPrf1=0.01, targetBlerPrf2=0.009, sw_build='SBTS00'):
    """ This function computes for the expected values of new DL PM Counters based on Collected TTI Traces.
        Suggested pkl file: pkl file with dlharqmatcher / ulharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param dir: Specifies direction. Use "dl" for downlink and "ul" for uplink
        :param subfeature: subfeature being tested (A, C, D, or E)
        :param cell: cell to analyze
        :param max_dl_harq_tx: maximum dl retransmission configured in SCF
        :param max_ul_harq_tx: masimum ul retransmission configured in SCF
        :param targetBlerPrf1: configured targetBler for LA profile 1
        :param targetBlerPrf2: configured targerBler for LA profile 2

        :returns new_pmc_dict: a dictionary for the following PM Counters:

        M55300C00029-30   (K4) PDSCH init tx with 64QAM MCS table using LA BLER Target from NRPDSCHHRLA PRFL1
        M55302C00029-30   (K4) PUSCH init tx with 64QAM MCS table using LA BLER Target from NRPUSCHHRLA PRFL1
        M55300C00037      (K4) PDSCH_SUCC_ANY_64TBL_HRD_PRFL1
        M55300C00038      (K4) PDSCH_UNSUCC_64TBL_HRD_PRFL1
        M55300C00033      (K4) PDSCH_INITX_64TBL_BR
        M55300C00034      (K4) PDSCH_SUCC_INI_64TBL_BR
        M55300C00035      (K4) PDSCH_SUCC_ANY_64TBL_BR
        M55300C00036      (K4) PDSCH_UNSUCC_64TBL_BR
        M55302C00037      (K4) PUSCH_SUCC_ANY_64TBL_HRD_PRFL1
        M55302C00038      (K4) PUSCH_UNSUCC_LOWSE_HRD_PRFL1
        M55302C00033      (K4) PUSCH_INITX_LOWSE_BR
        M55302C00034      (K4) PUSCH_SUCC_INI_LOWSE_BR
        M55302C00035      (K4) PUSCH_SUCC_ANY_LOWSE_BR
        M55302C00036      (K4) PUSCH_UNSUCC_LOWSE_BR
    """
    logging.info("path_to_pickle = %s" % path_to_pickle)
    logging.info("dir = %s" % dir)
    logging.info("subfeature = %s" % subfeature)
    logging.info("cell = %s" % cell)
    logging.info("max_dl_harq_tx = %s" % max_dl_harq_tx)
    logging.info("max_ul_harq_tx = %s" % max_ul_harq_tx)
    logging.info("targetBlerPrf1 = %s" % targetBlerPrf1)
    logging.info("targetBlerPrf2 = %s" % targetBlerPrf2)
    logging.info("sw_build = %s" % sw_build)
    # ------------------------------------------------------------------------------------------------[120 characters]
    ackNack = 'dlFdSchedData.ackNack'
    crcResult = 'ulHarqRxData.crcResult'
    txNumber = '{}FdSchedData.txNumber'.format(dir)
    mcsTable = '{}FdSchedData.mcsTable'.format(dir)
    laMode = '{}FdSchedData.laMode'.format(dir)
    if dir == 'ul':
        targetBLER = 'ulFdSchedAdditionalData.targetBLER'
    else:
        targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    if dir == 'dl':
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', ackNack, txNumber, mcsTable,
                 laMode, targetBLER]].dropna(subset=[mcsTable])
    else:
        df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', crcResult, txNumber, mcsTable,
                 laMode, targetBLER]].dropna(subset=[mcsTable])
    df = normalize_sfn_values(df)
    df.to_csv(str("%s/manual_analysis_get_expected_{}_new_pmc_values.csv".format(dir) %
                  get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    qam64_br_df = df[(df[mcsTable] == 'QAM64') & (df[laMode] == 'BASICRELIABILITY')]
    qam64_hr_df = df[(df[mcsTable] == 'QAM64') & (df[laMode] == 'HIGHRELIABILITY')]

    if subfeature == 'G' or subfeature == 'I':
        prfl1_df = qam64_hr_df[qam64_hr_df[targetBLER] == targetBlerPrf1]
        prfl2_df = qam64_hr_df[qam64_hr_df[targetBLER] == targetBlerPrf2]

    count_initx_prfl1 = prfl1_df.loc[prfl1_df[txNumber] == 1].shape[0]

    new_pmc_dict = {}

    if dir == 'dl':
        count_tx2_prfl1 = prfl1_df.loc[prfl1_df[txNumber] == 2].shape[0]
        count_succ_initx_prfl1 = count_initx_prfl1 - count_tx2_prfl1
        new_pmc_dict['M55300C00029'] = str(count_initx_prfl1)
        new_pmc_dict['M55300C00030'] = str(count_succ_initx_prfl1)
        if subfeature == 'D' or subfeature == 'G':
            count_unsucc_prfl1 = prfl1_df.loc[(prfl1_df[txNumber] == int(max_dl_harq_tx)) &
                                              (prfl1_df[ackNack] == 'NACK')].shape[0]
            count_succ_any_prfl1 = count_initx_prfl1 - count_unsucc_prfl1
            count_initx_br = qam64_br_df.loc[qam64_br_df[txNumber] == 1].shape[0]
            count_tx2_br = qam64_br_df.loc[qam64_br_df[txNumber] == 2].shape[0]
            count_succ_initx_br = count_initx_br - count_tx2_br
            count_unsucc_br = qam64_br_df.loc[(qam64_br_df[txNumber] == int(max_dl_harq_tx)) &
                                              (qam64_br_df[ackNack] == 'NACK')].shape[0]
            count_succ_any_br = count_initx_br - count_unsucc_br
            new_pmc_dict['M55300C00037'] = str(count_succ_any_prfl1)
            new_pmc_dict['M55300C00038'] = str(count_unsucc_prfl1)
            new_pmc_dict['M55300C00033'] = str(count_initx_br)
            new_pmc_dict['M55300C00034'] = str(count_succ_initx_br)
            new_pmc_dict['M55300C00035'] = str(count_succ_any_br)
            new_pmc_dict['M55300C00036'] = str(count_unsucc_br)
    else:
        count_succ_initx_prfl1 = prfl1_df.loc[(prfl1_df[txNumber] == 1) &
                                              (prfl1_df[crcResult] == 'OK')].shape[0]
        count_succ_initx_prfl2 = prfl2_df.loc[(prfl2_df[txNumber] == 1) &
                                              (prfl2_df[crcResult] == 'OK')].shape[0]
        new_pmc_dict['M55302C00029'] = str(count_initx_prfl1)
        new_pmc_dict['M55302C00030'] = str(count_succ_initx_prfl1)
        if subfeature == 'E' or subfeature == 'I':
            count_unsucc_prfl1 = prfl1_df.loc[(prfl1_df[crcResult] == 'NOK') &
                                              (prfl1_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_succ_any_prfl1 = prfl1_df.loc[(prfl1_df[crcResult] == 'OK')].shape[0]
            count_initx_br = qam64_br_df.loc[qam64_br_df[txNumber] == 1].shape[0]
            count_tx2_br = qam64_br_df.loc[qam64_br_df[txNumber] == 2].shape[0]
            count_unsucc_br = qam64_br_df.loc[(qam64_br_df[crcResult] == 'NOK') &
                                              (qam64_br_df[txNumber] == int(max_ul_harq_tx))].shape[0]
            count_succ_initx_br = count_initx_br - count_tx2_br
            count_succ_any_br = count_initx_br - count_unsucc_br
            new_pmc_dict['M55302C00037'] = str(count_succ_any_prfl1)
            new_pmc_dict['M55302C00038'] = str(count_unsucc_prfl1)
            new_pmc_dict['M55302C00033'] = str(count_initx_br)
            new_pmc_dict['M55302C00034'] = str(count_succ_initx_br)
            new_pmc_dict['M55302C00035'] = str(count_succ_any_br)
            new_pmc_dict['M55302C00036'] = str(count_unsucc_br)

    # -------------------------------------------------------------------------------------------------[120 characters]
    return new_pmc_dict


@log_begin_end_func_name
def get_expected_pusch_rank_pmi(path_to_pickle, cell):
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
             'ulFdSchedData.puschTPstate', 'ulFdSchedData.PMI', 'ulFdSchedData.numOfLayers']]
    df.to_csv(str("%s/manual_analysis_get_expected_pusch_rank_pmi.csv" % get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]

    # Remove all rows with puschTpState ==  'DISABLED' i.e. with DFT-s-OFDM enable
    df = df[df['ulFdSchedData.puschTPstate'] == 'DISABLED']

    # Remove all invalid values of ulFdSchedData.PMI, requirement see below, copy as a hole string
    # https://dn-prod.ext.net.nokia.com/rm/web#action=com.ibm.rdm.web.pages.showArtifactPage&artifactURI=https%3A%2F%2F
    # dn-prod.ext.net.nokia.com%2Frm%2Fresources%2FBI_L8IXQGfGEfCk8v_SG2h2xg&vvc.configuration=https%3A%2F%2Fdn-prod.ex
    # t.net.nokia.com%2Frm%2Fcm%2Fstream%2F_UBmNVp5EEe2A-5U7tzedRA
    df = df[df['ulFdSchedData.PMI'] != 6]
    # ------------------------------------------------------------------------------------------------[120 characters]
    pusch_cp_2tx_df = (df.loc[(df['ulFdSchedData.PMI'] != 255)]).dropna(subset=['ulFdSchedData.PMI'])
    pusch_cp_2tx_rank1 = pusch_cp_2tx_df.loc[(pusch_cp_2tx_df['ulFdSchedData.numOfLayers']) == 'RANK1'].shape[0]
    pusch_cp_2tx_rank2 = pusch_cp_2tx_df.loc[(pusch_cp_2tx_df['ulFdSchedData.numOfLayers']) == 'RANK2'].shape[0]

    pusch_rank1 = df[df['ulFdSchedData.numOfLayers'] == 'RANK1']
    pusch_rank2 = df[df['ulFdSchedData.numOfLayers'] == 'RANK2']
    pusch_rank1_pmi0 = pusch_rank1.loc[(pusch_rank1['ulFdSchedData.PMI']) == 0].shape[0]
    pusch_rank1_pmi1 = pusch_rank1.loc[(pusch_rank1['ulFdSchedData.PMI']) == 1].shape[0]
    pusch_rank1_pmi2 = pusch_rank1.loc[(pusch_rank1['ulFdSchedData.PMI']) == 2].shape[0]
    pusch_rank1_pmi3 = pusch_rank1.loc[(pusch_rank1['ulFdSchedData.PMI']) == 3].shape[0]
    pusch_rank1_pmi4 = pusch_rank1.loc[(pusch_rank1['ulFdSchedData.PMI']) == 4].shape[0]
    pusch_rank1_pmi5 = pusch_rank1.loc[(pusch_rank1['ulFdSchedData.PMI']) == 5].shape[0]
    pusch_rank2_pmi0 = pusch_rank2.loc[(pusch_rank2['ulFdSchedData.PMI']) == 0].shape[0]
    pusch_rank2_pmi1 = pusch_rank2.loc[(pusch_rank2['ulFdSchedData.PMI']) == 1].shape[0]
    pusch_rank2_pmi2 = pusch_rank2.loc[(pusch_rank2['ulFdSchedData.PMI']) == 2].shape[0]
    pmc_values_dict = {'M55303C04001': pusch_cp_2tx_rank1,
                       'M55303C04002': pusch_cp_2tx_rank2,
                       'M55303C02000': pusch_rank1_pmi0,
                       'M55303C02001': pusch_rank1_pmi1,
                       'M55303C02002': pusch_rank1_pmi2,
                       'M55303C02003': pusch_rank1_pmi3,
                       'M55303C02004': pusch_rank1_pmi4,
                       'M55303C02005': pusch_rank1_pmi5,
                       'M55303C03000': pusch_rank2_pmi0,
                       'M55303C03001': pusch_rank2_pmi1,
                       'M55303C03002': pusch_rank2_pmi2}
    # ------------------------------------------------------------------------------------------------[120 characters]
    return pmc_values_dict


@log_begin_end_func_name
def get_expected_pdsch_rank_pmi(path_to_pickle, cell):
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
             'dlFdSchedData.PMI', 'dlFdSchedData.numOfLayers']]
    df.to_csv(str("%s/manual_analysis_get_expected_pdsch_rank_pmi.csv" % get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    pdsch_rank1 = df[df['dlFdSchedData.numOfLayers'] == 'RANK1']
    pdsch_rank2 = df[df['dlFdSchedData.numOfLayers'] == 'RANK2']
    pdsch_rank1_pmi0 = pdsch_rank1.loc[(pdsch_rank1['dlFdSchedData.PMI']) == 0].shape[0]
    pdsch_rank1_pmi1 = pdsch_rank1.loc[(pdsch_rank1['dlFdSchedData.PMI']) == 1].shape[0]
    pdsch_rank1_pmi2 = pdsch_rank1.loc[(pdsch_rank1['dlFdSchedData.PMI']) == 2].shape[0]
    pdsch_rank1_pmi3 = pdsch_rank1.loc[(pdsch_rank1['dlFdSchedData.PMI']) == 3].shape[0]
    pdsch_rank2_pmi0 = pdsch_rank2.loc[(pdsch_rank2['dlFdSchedData.PMI']) == 0].shape[0]
    pdsch_rank2_pmi1 = pdsch_rank2.loc[(pdsch_rank2['dlFdSchedData.PMI']) == 1].shape[0]
    pdsch_rank2_pmi2 = pdsch_rank2.loc[(pdsch_rank2['dlFdSchedData.PMI']) == 2].shape[0]
    pmc_values_dict = {'pdsch_rank1_pmi0': pdsch_rank1_pmi0,
                       'pdsch_rank1_pmi1': pdsch_rank1_pmi1,
                       'pdsch_rank1_pmi2': pdsch_rank1_pmi2,
                       'pdsch_rank1_pmi3': pdsch_rank1_pmi3,
                       'pdsch_rank2_pmi0': pdsch_rank2_pmi0,
                       'pdsch_rank2_pmi1': pdsch_rank2_pmi1,
                       'pdsch_rank2_pmi2': pdsch_rank2_pmi2}
    # ------------------------------------------------------------------------------------------------[120 characters]
    return pmc_values_dict


@log_begin_end_func_name
def get_expected_pdsch_various(path_to_pickle, cell):
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
             'dlFdSchedData.tbSize', 'dlFdSchedData.numOfPrb']]
    df.to_csv(str("%s/manual_analysis_get_expected_pdsch_various.csv" % get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # ------------------------------------------------------------------------------------------------[120 characters]
    pdsch_data_slots = df.loc[df['dlFdSchedData.tbSize'].notnull()].shape[0]
    pdsch_prbs_used = int(df['dlFdSchedData.numOfPrb'].sum())
    pmc_values_dict = {'pdsch_data_slots': pdsch_data_slots,
                       'pdsch_prbs_used': pdsch_prbs_used,
                       'null': 0}
    # ------------------------------------------------------------------------------------------------[120 characters]
    return pmc_values_dict


@log_begin_end_func_name
def get_expected_pdsch_hrla(path_to_pickle, cell, prf1_bler, prf2_bler, sw_build='SBTS00'):
    logging.info("path_to_pickle = %s" % path_to_pickle)
    logging.info("cell = %s" % cell)
    logging.info("prf1_bler = %s" % prf1_bler)
    logging.info("prf2_bler = %s" % prf2_bler)
    logging.info("sw_build = %s" % sw_build)
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    targetBLER = 'dlFdSchedAdditionalData.targetBLER'
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
             'dlFdSchedData.mcsTable',
             targetBLER,
             'dlFdSchedData.txNumber',
             'dlFdSchedData.laMode']]
    df.to_csv(str("%s/manual_analysis_get_expected_pdsch_hrla.csv" % get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # Normalize string columns to uppercase (TTI trace data may use camelCase)
    for col in ['dlFdSchedData.mcsTable', 'dlFdSchedData.laMode']:
        series = df[col].astype(str).str.upper()
        df[col] = series.where(series != 'NAN', other=np.nan)
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = df[df['dlFdSchedData.mcsTable'] == 'QAM64LOWSE']
    pdsch_HRLA = df[df['dlFdSchedData.laMode'] == 'HIGHRELIABILITY']
    pdsch_HRLA_PRF1 = pdsch_HRLA[pdsch_HRLA[targetBLER] == prf1_bler]
    pdsch_HRLA_PRF2 = pdsch_HRLA[pdsch_HRLA[targetBLER] == prf2_bler]
    logging.info("pdsch_HRLA_PRF1 = \n%s" % pdsch_HRLA_PRF1)
    logging.info("pdsch_HRLA_PRF2 = \n%s" % pdsch_HRLA_PRF2)
    pdsch_HRLA_PRF1_tx1 = pdsch_HRLA_PRF1.loc[(pdsch_HRLA_PRF1['dlFdSchedData.txNumber']) == 1].shape[0]
    pdsch_HRLA_PRF1_tx2 = pdsch_HRLA_PRF1.loc[(pdsch_HRLA_PRF1['dlFdSchedData.txNumber']) == 2].shape[0]
    pdsch_HRLA_PRF2_tx1 = pdsch_HRLA_PRF2.loc[(pdsch_HRLA_PRF2['dlFdSchedData.txNumber']) == 1].shape[0]
    pdsch_HRLA_PRF2_tx2 = pdsch_HRLA_PRF2.loc[(pdsch_HRLA_PRF2['dlFdSchedData.txNumber']) == 2].shape[0]
    pmc_values_dict = {'pdsch_HRLA_PRF1_Init': pdsch_HRLA_PRF1_tx1,
                       'pdsch_HRLA_PRF1_Succ': pdsch_HRLA_PRF1_tx1 - pdsch_HRLA_PRF1_tx2,
                       'pdsch_HRLA_PRF2_Init': pdsch_HRLA_PRF2_tx1,
                       'pdsch_HRLA_PRF2_Succ': pdsch_HRLA_PRF2_tx1 - pdsch_HRLA_PRF2_tx2}
    # ------------------------------------------------------------------------------------------------[120 characters]
    return pmc_values_dict


@log_begin_end_func_name
def get_expected_pusch_hrla(path_to_pickle, cell, prf1_bler, prf2_bler):
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
             'ulFdSchedData.mcsTable',
             'ulFdSchedAdditionalData.targetBLER',
             'ulFdSchedData.txNumber',
             'ulFdSchedData.laMode']]
    df.to_csv(str("%s/manual_analysis_get_expected_pdsch_hrla.csv" % get_directory(path_to_pickle)))
    df = df[df['lcrId'] == int(cell)]
    # Normalize string columns to uppercase (TTI trace data may use camelCase)
    for col in ['ulFdSchedData.mcsTable', 'ulFdSchedData.laMode']:
        series = df[col].astype(str).str.upper()
        df[col] = series.where(series != 'NAN', other=np.nan)
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = df[df['ulFdSchedData.mcsTable'] == 'QAM64LOWSE']
    pusch_HRLA = df[df['ulFdSchedData.laMode'] == 'HIGHRELIABILITY']
    pusch_HRLA_PRF1 = pusch_HRLA[pusch_HRLA['ulFdSchedAdditionalData.targetBLER'] == prf1_bler]
    pusch_HRLA_PRF2 = pusch_HRLA[pusch_HRLA['ulFdSchedAdditionalData.targetBLER'] == prf2_bler]
    logging.info("pusch_HRLA_PRF1 = \n%s" % pusch_HRLA_PRF1)
    logging.info("pusch_HRLA_PRF2 = \n%s" % pusch_HRLA_PRF2)
    pusch_HRLA_PRF1_tx1 = pusch_HRLA_PRF1.loc[(pusch_HRLA_PRF1['ulFdSchedData.txNumber']) == 1].shape[0]
    pusch_HRLA_PRF1_tx2 = pusch_HRLA_PRF1.loc[(pusch_HRLA_PRF1['ulFdSchedData.txNumber']) == 2].shape[0]
    pusch_HRLA_PRF2_tx1 = pusch_HRLA_PRF2.loc[(pusch_HRLA_PRF2['ulFdSchedData.txNumber']) == 1].shape[0]
    pusch_HRLA_PRF2_tx2 = pusch_HRLA_PRF2.loc[(pusch_HRLA_PRF2['ulFdSchedData.txNumber']) == 2].shape[0]
    pmc_values_dict = {'pusch_HRLA_PRF1_Init': pusch_HRLA_PRF1_tx1,
                       'pusch_HRLA_PRF1_Succ': pusch_HRLA_PRF1_tx1 - pusch_HRLA_PRF1_tx2,
                       'pusch_HRLA_PRF2_Init': pusch_HRLA_PRF2_tx1,
                       'pusch_HRLA_PRF2_Succ': pusch_HRLA_PRF2_tx1 - pusch_HRLA_PRF2_tx2}
    # ------------------------------------------------------------------------------------------------[120 characters]
    return pmc_values_dict


@log_begin_end_func_name
def check_correlation_of_mcs_and_cqi_events(path_to_pickle):
    """ This function calculates if mcs and cqi event has an acceptable correlation value

        Suggested pkl file: pkl file with dlharq matcher with High reliability filters

        :param path_to_pickle: Path of input pickle file

    """
    visualization()
    df = pd.read_pickle(path_to_pickle)

    # Correlation Threshold: Adjust this to lower value if you want to have less strict validation
    # (e.g 0.9 is strict, while 0.8 is considered relaxed, lower than that would be too relaxed)
    threshold = 0.80

    # Filter needed events
    mcs_event = 'dlFdSchedData.rrmDlProposedMcs'
    cqi_event = get_correct_cqi_event()
    df_filtered = df.loc[(df[mcs_event] != 255) & (df[cqi_event] != 255)]

    rnti_group = {}
    for rnti, df_group in df_filtered.groupby('rnti'):
        rbi.log("Evaluating RNTI: {} Correlation threshold: {}".format(rnti, threshold), 'INFO')
        first_row = df_group.loc[df_group[mcs_event] < 2].index[0]

        # Fill up na rows to compare the two events using 1 row then correlate them
        corr_df = df_group[[mcs_event, cqi_event]].loc[first_row:, :].ffill().corr(method='pearson', numeric_only=True)
        display_df_as_html(corr_df)

        correlation_passed = True if corr_df.at[mcs_event, cqi_event] >= threshold else False
        rnti_group[rnti] = correlation_passed

    plot_df_with_scatter(df_filtered, mcs_event, get_directory(path_to_pickle),
                         'full', 'timeStamp', 'mcs_vs_cqi', 'rnti', cqi_event)

    for rnti, correlation_passed in rnti_group.items():
        if not correlation_passed:
            rbi.log("Check if correlation between MCS and CQI. Check fail! Results: {} FAIL"
                    .format(rnti), 'ERROR')
            rbi.log("Check the graph mcs_vs_cqi to understand why correlation is low.", 'TRACE')
            rbi.log("Outliers tends to lessen the correlation.", 'TRACE')
            rbi.fail("Check the graph mcs_vs_cqi to understand why correlation is low. Test case fail")


@log_begin_end_func_name
def verify_if_values_changed_after_online_modification(path_to_pickle, subfeature,
                                                       mcs_event='dlFdSchedData.rrmDlProposedMcs',
                                                       event_modified='dlLaAverageCqi.rrmCqiOffset', value=3):
    """ This function checks if mcs change after offset changes

        Suggested pkl file: pkl file with dlharq matcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param mcs_event: mcs event to crosscheck
        :param event_modified: event modified on SCF
        :param value: value changed on the event
    """
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', mcs_event, event_modified]]
    df = df.loc[(df[mcs_event] != 255)]

    # Plot offset vs MCS graph
    plot_df_with_scatter(df, event_modified, get_directory(path_to_pickle),
                         'online_modification', 'timeStamp', 'offset_vs_mcs', 'rnti', mcs_event)

    rbi.log("Check if online modification is successful. Showing value counts of {}:".format(event_modified), 'INFO')
    rbi.log(df[event_modified].value_counts())

    if len(df[df[event_modified] == value]) == 0:
        rbi.log("Number of occurences of value {} is {}".format(value, len(df[df[event_modified] == value])), 'ERROR')
        rbi.fail("{} wasn't changed to max value.. failing TC".format(event_modified))
    else:
        rbi.log("{} with value {} found.. check if {} was changed".format(event_modified, value, mcs_event))

    # Getting the first row with event_modified value
    first_row_modify = df[df[event_modified] == value].index[0]
    df_after_modification = df.loc[first_row_modify:, :].dropna(subset=[mcs_event])
    df_before_modification = df.loc[:first_row_modify, :].dropna(subset=[mcs_event])

    if subfeature == 'A':
        # Get percentage of dllaIniMcsHR (MCS3) on the df after online modification
        frequent_value = df_after_modification[mcs_event].value_counts().idxmax()
        rbi.log("Dominant MCS value after online modification: {}".format(frequent_value))

        if (df_before_modification[mcs_event].mean() > df_after_modification[mcs_event].mean()) and frequent_value == 3:
            rbi.log("Online modification works! Passing test case")
        else:
            rbi.log("[DEBUG VALUES] MCS mean before modification: {}".format(df_before_modification[mcs_event].mean()))
            rbi.log("[DEBUG VALUES] MCS mean after modification: {}".format(df_after_modification[mcs_event].mean()))
            rbi.log("Last 20 rows of {}:".format(mcs_event), 'INFO')
            display_df_as_html(df.dropna(subset=[mcs_event]).tail(20))
            plot_df_with_scatter(df_after_modification, mcs_event, get_directory(path_to_pickle), 'online_modification',
                                 'timeStamp', 'debug_offset_vs_mcs')

            rbi.log(
                "Dominant MCS after online modification isn't dllaIniMcsHR(MCS3) or there is no change on proposedMCS"
                .format(event_modified), 'ERROR')
            rbi.log("TC checks if values of {} after the modification is mostly dllaIniMcsHR(MCS3)".format(mcs_event))
            rbi.log(
                "and that mean of {} before modification is higher than the mean after modification".format(mcs_event))
            rbi.fail("Check offset_vs_mcs.html to analyze result. Test case fail")

    if subfeature == 'C':
        if (df_before_modification[mcs_event].mean() > df_after_modification[mcs_event].mean()):
            rbi.log("Online modification works! Passing test case")
        else:
            rbi.log("[DEBUG VALUES] MCS mean before modification: {}".format(df_before_modification[mcs_event].mean()))
            rbi.log("[DEBUG VALUES] MCS mean after modification: {}".format(df_after_modification[mcs_event].mean()))
            rbi.log("Last 20 rows of {}:".format(mcs_event), 'INFO')
            display_df_as_html(df.dropna(subset=[mcs_event]).tail(20))
            plot_df_with_scatter(df_after_modification, mcs_event, get_directory(path_to_pickle), 'online_modification',
                                 'timeStamp', 'debug_offset_vs_mcs')
            rbi.log(
                "the mean of {} before modification isn't higher than the mean after modification".format(mcs_event))
            rbi.fail("Check offset_vs_mcs.html to analyze result. Test case fail")


@log_begin_end_func_name
def check_correlation_of_mcs_and_pathloss(path_to_pickle):
    """ This function calculates if mcs and pathloss event has a negative correlation value

        Suggested pkl file: pkl file with with High reliability filters

        :param path_to_pickle: Path of input pickle file

    """
    visualization()
    df = pd.read_pickle(path_to_pickle)

    # Correlation Threshold: We want an inverted graph so correlation must be 0 or less
    threshold = 0

    # Filter needed events
    mcs_event = 'ulFdSchedData.rrmUlProposedMcs'
    pathloss = 'ulLaPhr.ulPathloss'
    df_filtered = df.loc[(df[mcs_event] != 255)]

    rnti_group = {}
    for rnti, df_group in df_filtered.groupby('rnti'):
        rbi.log("Evaluating RNTI: {} Correlation threshold: {}".format(rnti, threshold), 'INFO')
        first_row = df_group.loc[df_group[mcs_event] < 2].index[0]

        corr_df = df_group[[mcs_event, pathloss]].loc[first_row:, :].ffill().corr(method='pearson', numeric_only=True)
        display_df_as_html(corr_df)

        correlation_passed = True if corr_df.at[mcs_event, pathloss] <= threshold else False
        rnti_group[rnti] = correlation_passed

    plot_df_with_scatter(df_filtered, mcs_event, get_directory(path_to_pickle),
                         'full', 'timeStamp', 'mcs_vs_pathloss', 'rnti', pathloss)

    for rnti, correlation_passed in rnti_group.items():
        if not correlation_passed:
            rbi.log("Check if correlation between MCS and Pathloss. Check fail! Results: {} FAIL"
                    .format(rnti), 'ERROR')
            rbi.fail("Check the graph mcs_vs_pathloss to understand why correlation is high. Test case fail")


@log_begin_end_func_name
def verify_distribution_table_of(column_name, path_to_pickle, plot=None, validate=None, need_return=False):
    """ This function counts the number of occurence and percentage
        of the given event per rnti

        Suggested pkl file: pkl file with dlharq matcher WITHOUT High reliability filters
        The function also allows generation of graph and validation of certain value and threshold

        :param column_name: event name
        :param path_to_pickle: Path of input pickle file
        :param plot: use "Scatter" to generate a scatter graph of column_name against timeStamp
        :param validate: dictionary of values and threshold you want to validate

        :returns df: dataframe of distributed table
    """
    df = pd.read_pickle(path_to_pickle)
    visualization()
    counted_df = (df.groupby(['rnti', column_name]).size().reset_index(name='Count').set_index(['rnti', column_name])
                  .assign(Percentage=lambda x: (x['Count']) * 100 / (x.groupby(['rnti'])['Count'].transform('sum'))))

    display_df_as_html(counted_df)

    # Option to plot the graph
    if plot == 'Scatter':
        # Drop column where event (column_name) is empty e.g by default, plot will filter BR and HR
        # using dlFdscheddata.lamode but if column_name is in a different row then graph will filter empty values
        fil_df = df.dropna(subset=[column_name]).dropna(how='all', axis=1)
        plot_df_with_scatter(fil_df, column_name, get_directory(path_to_pickle), 'distribution_table', 'timeStamp')
    elif plot == 'Bar':
        plot_df_with_bar(counted_df.reset_index(), column_name, "Count", get_directory(path_to_pickle))

    # Option to validate
    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        rbi.log("Values and percentage and threshold required:")
        val_df = pd.DataFrame.from_dict(validate)
        display_df_as_html(val_df)

        rbi.log("Checking if percentage meets validation thresholds..")
        val_df['Threshold'] = val_df['Threshold'].astype('float64')

        reset_df = counted_df.reset_index()
        reset_df[column_name] = reset_df[column_name].astype('object')

        crossed_df = pd.merge(reset_df, val_df, left_on=column_name, right_on='Value')
        crossed_df = crossed_df.drop(columns=['Count', 'Value'])
        crossed_df['Verdict'] = np.where(crossed_df['Percentage'] < crossed_df['Threshold'], 'Passed', 'Failed')
        if len(crossed_df) == 0:
            rbi.log("Values indicated on validation not found on the dataframe. Passing test case..")
        else:
            display_df_as_html(crossed_df)
            if len(crossed_df[crossed_df['Verdict'] == 'Failed']) == 0:
                rbi.log("Percentage within threshold! Passing test case!")
            else:
                rbi.log("Percentage did not reach required threshold for {}".format(column_name), 'ERROR')
                rbi.fail("Failing test case!")

    if need_return:
        return counted_df


@log_begin_end_func_name
def plot_event_according_to_lamode(path_to_pickle, column_name, direction='dl'):
    """ Provides graph of event according to LaMode

        :param path_to_pickle: Path of input pickle file
        :param  column_name: event that you want to describe
    """
    df = pd.read_pickle(path_to_pickle)
    laMode_event = '{}FdSchedData.laMode'.format(direction.lower())
    visualization()
    counted_df = (df.groupby([laMode_event, 'rnti', column_name]).size().reset_index(name='Count')
                  .set_index([laMode_event, 'rnti', column_name])
                  .assign(Percentage=lambda x: (x['Count']) * 100 /
                  (x.groupby([laMode_event, 'rnti'])['Count'].transform('sum'))))

    display_df_as_html(counted_df)
    plot_df_with_bar(counted_df.reset_index(), column_name, "Count", get_directory(path_to_pickle))


@log_begin_end_func_name
def check_min_max_doesnt_exceed(path_to_pickle, column_name):
    """ Provides different statistical analysis for a series
        such as mean, max, min, count etc.

        Then it checks if min and max doesn't exceed the threshold

        Suggested pkl file: pkl file WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param  column_name: event that you want to describe

    """
    visualization()
    max_threshold = 15
    min_threshold = -15
    rbi.log("Checking if max and min doesn't exceed defined thresholds..")
    rbi.log('MAX threshold: {} MIN threshold: {}'.format(max_threshold, min_threshold))

    df = pd.read_pickle(path_to_pickle)
    display_df_as_html(pd.DataFrame(df[column_name].describe()))

    if (df[column_name].describe()['max'] > max_threshold) or (df[column_name].describe()['min'] < min_threshold):
        rbi.log("Max or min did not reach required threshold for {}".format(column_name), 'ERROR')
        rbi.fail("Failing test case!")
    else:
        rbi.log('Threshold reached. Test case passing!')


@log_begin_end_func_name
def check_target_bler_is_less_than_percentage(path_to_pickle, xlaBlerTarget_hr_internal_value=10,
                                              xlaBlerTarget_br_internal_value=10, direction='ul',
                                              tolerance_br=2, tolerance_hr=0.1, sw_build='SBTS00'):
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
    logging.info("sw_build = %s" % sw_build)
    # ------------------------------------------------------------------------------------------------[120 characters]
    visualization()

    df = pd.read_pickle(path_to_pickle)

    if direction == 'ul':
        targetBLER_event = 'ulFdSchedAdditionalData.targetBLER'
        xlaBlerTarget_hr_division_factor = 1
    else:
        targetBLER_event = 'dlFdSchedAdditionalData.targetBLER'
        xlaBlerTarget_hr_division_factor = 1000

    xlaBlerTarget_br_GUI_value = (xlaBlerTarget_br_internal_value / 100)
    xlaBlerTarget_hr_GUI_value = (xlaBlerTarget_hr_internal_value / xlaBlerTarget_hr_division_factor)

    laMode_event = '{}FdSchedData.laMode'.format(direction)
    txNumber_event = '{}FdSchedData.txNumber'.format(direction)

    df = df[['timeStamp', 'rnti', 'sfn', 'slot', laMode_event,
             txNumber_event, targetBLER_event]].dropna(subset=[laMode_event])
    hr_filtered_df = df[(df[laMode_event] == 'HIGHRELIABILITY')]
    br_filtered_df = df[(df[laMode_event] == 'BASICRELIABILITY')]

    # Check if all values in the column are equal to the given value
    is_targe_bler_in_hr_equal_to_configured_value = (
        hr_filtered_df[targetBLER_event] == xlaBlerTarget_hr_GUI_value).all()
    if not is_targe_bler_in_hr_equal_to_configured_value:
        display_df_as_html(hr_filtered_df)
        rbi.fail("target BLER in L2-PS for {} is not equal to the configured \
                 GUI value {}".format('HIGHRELIABILITY', xlaBlerTarget_hr_GUI_value), 'ERROR')

    check_target_bler_is_less_than_percentage_with_df(br_filtered_df, txNumber_event,
                                                      'BASICRELIABILITY', tolerance_br,
                                                      xlaBlerTarget_br_GUI_value * 100)
    check_target_bler_is_less_than_percentage_with_df(hr_filtered_df, txNumber_event,
                                                      'HIGHRELIABILITY', tolerance_hr,
                                                      xlaBlerTarget_hr_GUI_value * 100)


@log_begin_end_func_name
def check_target_bler_is_less_than_percentage_with_df(filtered_df, txNumber_event, laMode_event_value, tolerance,
                                                      threshold=1):
    # Calculate value counts and percentage for txNumber in BR/HR modes seprately
    counted_df = (filtered_df
                  .groupby(['rnti', txNumber_event])
                  .size()
                  .reset_index(name='Count')
                  .set_index(['rnti', txNumber_event])
                  .assign(Percentage=lambda x: (x['Count']) * 100 / (x.groupby(['rnti'])['Count'].transform('sum')))
                  .reset_index())
    display_df_as_html(counted_df)

    rnti_group = {}
    for rnti, df_group in counted_df.groupby('rnti'):
        percentage_2_values = df_group[df_group[txNumber_event] == 2][[
            "Percentage"]].values
        percentage_1_values = df_group[df_group[txNumber_event] == 1][[
            "Percentage"]].values

        if len(percentage_2_values) == 0:
            target_bler_reached = True
            rbi.log("There is no txNumber=2 transmission i.e BLER is 0%.\
                    Setting BLER check pass for rnti {} and {}".format(rnti, laMode_event_value))
            break

        target_bler = 100 * (percentage_2_values / percentage_1_values)
        rbi.log("Checking if Computed target BLER({}) on RNTI {} with {} mode is less than \
                threshold:({}%)+tolerance({}%)".format(target_bler, rnti, laMode_event_value, threshold, tolerance))

        target_bler_reached = True if target_bler <= (
            threshold + tolerance) else False
        rnti_group[rnti] = target_bler_reached

    for rnti, correlation_passed in rnti_group.items():
        if target_bler_reached:
            rbi.log("target bler on RNTI {} is less than {} with {} mode. Check PASSED".format(
                rnti, (threshold + tolerance), laMode_event_value))
        else:
            rbi.fail("target bler on RNTI {} is not less than {} with {} mode".format(
                rnti, (threshold + tolerance), laMode_event_value), 'ERROR')


@log_begin_end_func_name
def compare_proposed_vs_used_mcs(path_to_pickle):
    """ This function generates chart that shows used vs proposed mcs

        Suggested pkl file: pkl file with dlharq matcher WITHOUT High reliability filters
        :param path_to_pickle: Path of input pickle file
    """
    df = pd.read_pickle(path_to_pickle)

    proposed_mcs_event = 'dlFdSchedData.rrmDlProposedMcs'
    used_mcs_event = 'dlFdSchedData.rrmDlUsedMcs'
    filtered_df = df.loc[(df[proposed_mcs_event] != 255)]

    # Graph Proposed vs Used MCS
    plot_df_with_scatter(df=filtered_df, yaxis_column=proposed_mcs_event,
                         base_location=get_directory(path_to_pickle), postfix="", xaxis_column="timeStamp",
                         title="Proposed vs Used MCS", group_by='rnti', second_yaxis_col=used_mcs_event)

    # Check correlation
    corr_df = filtered_df[[proposed_mcs_event, used_mcs_event]].corr(method='pearson', numeric_only=True)
    display_df_as_html(corr_df)


@log_begin_end_func_name
def check_aggregation_level(path_to_pickle, direction, la_mode, aggregation_level):
    """ This function checks if PDCCH/PUCCH follows the laMode switch

        :param path_to_pickle: Path of input pickle file
        :param direction: ul/dl
        :param la_mode: BASICRELIABILITY or HIGHRELIABILITY
        :param aggregation_level: Value to check (depends on SCF value)

    """
    visualization()

    if type(aggregation_level) is not int:
        aggregation_level = [int(x) for x in aggregation_level]

    la_mode_event = '{}FdSchedData.laMode'.format(direction)
    aggregation_level_event = '{}FdSchedData.aggregationLevel'.format(direction)
    dciFormat = '{}FdSchedData.dciFormat'.format(direction)

    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', la_mode_event, aggregation_level_event, dciFormat]]

    rbi.log("Filter the laMode fields")
    filtered_df = df[(df[la_mode_event] == la_mode) & (df[dciFormat] == 'DL_11')]

    rbi.log("Check if all rows matches the aggregation level")
    if type(aggregation_level) is int:
        unmatched_df = filtered_df[filtered_df[aggregation_level_event] != aggregation_level]
    else:
        unmatched_df = filtered_df[~filtered_df[aggregation_level_event].isin(aggregation_level)]

    if len(unmatched_df) == 0:
        rbi.log("Function pass!")
    else:
        rbi.log("PDCCH switch did not occur when PXSCH fallback to {} mode".format(la_mode), 'ERROR')
        display_df_as_html(unmatched_df.head(10))
        rbi.fail("Failing function check_aggregation_level")


@log_begin_end_func_name
def check_switch_between_hr_and_br_event(path_to_pickle, direction='dl', outage_threshold=50, recover_threshold=60,
                                         validate_outage=True, validate_recover=True, is_subfeature_H_enabled=False):
    """ This function checks the (dl/ul)LaSwitchBetweenHrAndBr event

        Once (dl/ul)LaSwitchBetweenHrAndBr.pxschMetric.ratio >= outage_threshold or
        (dl/ul)LaSwitchBetweenHrAndBr.pdcchMetric.ratio >= outage_threshold, then switch will be checked

        :param path_to_pickle: Path of input pickle file
        :param direction: ul/dl
        :param outage_threshold: threshold percentage for PDSCH, PUSCH and PDCCH to check for outage
        :param recover_threshold: threshold percentage for PDSCH, PUSCH and PDCCH to check for recovery

    """
    visualization()
    plot_graph_hr_vs_br(path_to_pickle, direction)

    rbi.log("Direction: {} Outage Threshold: {} Recover Threshold: {} ".format(
        direction, outage_threshold, recover_threshold))

    df = pd.read_pickle(path_to_pickle)
    prefix_dir = 'd' if direction == 'dl' else 'u'
    la_mode_event = '{}LaSwitchBetweenHrAndBr.laMode'.format(direction)
    la_switch_event = '{}LaSwitchBetweenHrAndBr.event'.format(direction)
    pxsch_ratio_event = '{}LaSwitchBetweenHrAndBr.p{}schMetric.ratio'.format(
        direction, prefix_dir)
    pxsch_nbSamples_event = '{}LaSwitchBetweenHrAndBr.p{}schMetric.nbSamples'.format(
        direction, prefix_dir)
    pxsch_nbSamplesThreshold_event = '{}LaSwitchBetweenHrAndBr.p{}schMetric.nbSamplesThreshold'.format(
        direction, prefix_dir)
    pdcch_ratio_event = '{}LaSwitchBetweenHrAndBr.pdcchMetric.ratio'.format(
        direction)

    df = df[['timeStamp', 'rnti', 'sfn', 'slot', la_mode_event, la_switch_event,
             pxsch_nbSamples_event, pxsch_nbSamplesThreshold_event, pxsch_ratio_event,
             pdcch_ratio_event]].dropna(subset=[la_switch_event])

    for rnti, df_group in df.groupby('rnti'):
        rbi.log("Printing all {}LaSwitchBetweenHrAndBr.event for rnti {}".format(
            direction, rnti), 'INFO')
        display_df_as_html(df_group)

        if (validate_outage):
            rbi.log(
                "<p style='color:DodgerBlue;'><b>Step 1: Switch to BR </b></p>", 'HTML')
            outage_df = \
                df_group[(df_group[la_switch_event] == '{}HRBLEROUTAGEPERIODTIMER'.format(direction.upper())) |
                         (df_group[la_switch_event] == '{}PDCCHHRBLEROUTAGEPERIODTIMER'.format(direction.upper()))]
            outage_df = outage_df[(outage_df[pxsch_ratio_event] >= int(outage_threshold)) |
                                  (outage_df[pdcch_ratio_event] >= int(outage_threshold))]
            display_df_as_html(outage_df)

            if len(outage_df) == 0:
                rbi.log(
                    "No row reached the required threshold for outage switch to BR for rnti {}.".format(rnti))
                rbi.fail("Failing function check_switch_between_hr_and_br_event for rnti {}".format(
                    rnti), 'ERROR')
            else:
                rbi.log(
                    "Thresholds detected. Switch to BR should happen!! Checking TTI trace for BASICRELIABILITY")
                if (outage_df[la_mode_event].iloc[0] == 'BASICRELIABILITY'):
                    rbi.log("HR fallback to BR occurred for rnti {}!".format(rnti))
                else:
                    rbi.log("HR fallback to BR did not occur for rnti {}!".format(
                        rnti), 'ERROR')
                    rbi.fail("Failing function check_switch_between_hr_and_br_event for rnti {}.".format(
                        rnti), 'ERROR')

        if (validate_recover):
            rbi.log(
                "<p style='color:DodgerBlue;'><b>Step 2: Switch to HR </b></p>", 'HTML')
            recover_df = df_group[df_group[la_switch_event] ==
                                  '{}HRBLERRECOVERPERIODTIMER'.format(direction.upper())]
            if (is_subfeature_H_enabled):
                recover_df = recover_df[(recover_df[pxsch_ratio_event] >= int(recover_threshold)) &
                                        (recover_df[pdcch_ratio_event] >= int(recover_threshold))]
            else:
                recover_df = recover_df[recover_df[pxsch_ratio_event] >= int(recover_threshold)]
            display_df_as_html(recover_df)

            if len(recover_df) == 0:
                rbi.log(
                    "No row reached the required threshold for recover switch to HR for rnti {}.".format(rnti))
                rbi.fail("Failing function check_switch_between_hr_and_br_event for rnti {}.".format(
                    rnti), 'ERROR')
            else:
                rbi.log(
                    "Thresholds detected. Switch to HR should happen!! Checking TTI trace for HIGHRELIABILITY")
                if (recover_df[la_mode_event].iloc[0] == 'HIGHRELIABILITY'):
                    rbi.log("BR recovery to HR occurred for rnti {}!".format(rnti))
                else:
                    rbi.log("BR recovery to HR did not occur for rnti {}!".format(
                        rnti), 'ERROR')
                    rbi.fail("Failing function check_switch_between_hr_and_br_event for rnti {}.".format(
                        rnti), 'ERROR')


@log_begin_end_func_name
def plot_graph_hr_vs_br(path_to_pickle, direction):
    df = pd.read_pickle(path_to_pickle)
    mcs_event = '{}FdSchedData.rrm{}ProposedMcs'.format(
        direction, direction.capitalize())

    df = df.loc[(df[mcs_event] != 255)]
    if (direction == 'dl'):
        df = df.loc[(df["csiSrReportData.csiReport.cqi"] != 255)]
        plot_df_with_scatter(df=df, yaxis_column=mcs_event, base_location=get_directory(path_to_pickle),
                             postfix="", xaxis_column="timeStamp", title='{}_br_vs_hr'.format(direction),
                             group_by='rnti', second_yaxis_col="dlLaDeltaCqiArray.rrmDeltaCqi",
                             third_yaxis_col="csiSrReportData.csiReport.cqi",
                             fourth_yaxis_col="csiSrReportData.csiReport.ri")
    else:
        plot_df_with_scatter(df=df, yaxis_column=mcs_event, base_location=get_directory(path_to_pickle),
                             postfix="", xaxis_column="timeStamp", title='{}_br_vs_hr'.format(direction),
                             group_by='rnti', second_yaxis_col='ulLaPhr.ulPathloss')


@log_begin_end_func_name
def plot_two_dfs(x_series, y_series, base_location, title=""):
    """ This function generates .html plot with two different dataframes
    """
    try:
        import plotly.graph_objects as go
        from plotly.subplots import make_subplots
        fig = go.Figure()

        fig.add_trace(go.Scatter(x=x_series, y=y_series, mode='markers', marker=dict(size=3)))

        fig.update_layout(title=title, xaxis_title='timeStamp')
        file_name = "/" + title.replace(" ", "_") + (".html")
        fig.write_html(base_location+file_name, auto_open=False)
    except ModuleNotFoundError:
        logging.warning("plotly is not installed therefore plot will not be saved, please install plotly using "
                        "the command: pip install plotly")


# ====================================================================================================[120 characters]
#   Private Functions
# ====================================================================================================[120 characters]


def get_directory(path_to_pickle):
    return os.path.dirname(path_to_pickle)


def visualization():
    pd.set_option('display.max_columns', None)
    pd.set_option('display.expand_frame_repr', False)


@log_begin_end_func_name
def plot_df_with_scatter(df, yaxis_column, base_location, postfix="",
                         xaxis_column="normalized_sfn", title="", group_by='rnti',
                         second_yaxis_col=None, third_yaxis_col=None, fourth_yaxis_col=None):
    """ This function generates .html plot using yaxis_column and xaxis_column columns.
        It is recomended to use 'normalized_sfn' for xaxis_column.
    """
    try:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", category=FutureWarning)
            import plotly.graph_objects as go
            from plotly.subplots import make_subplots
            fig = go.Figure()
            fig = make_subplots(rows=math.ceil(
                len(df[group_by].unique())/2), cols=2, subplot_titles=(df[group_by].unique()))

            for i, grouped_by_value in enumerate(df[group_by].unique()):
                grouped_df = df[df[group_by] == grouped_by_value]
                row_number_of_subplot = math.floor(i / 2) + 1
                col_number_of_subplot = (i % 2) + 1
                logging.info("row_number_of_subplot = {} col_number_of_subplot = {}".format(
                    row_number_of_subplot, col_number_of_subplot))
                # Filter all rows with xaxis_column
                filtered_df = grouped_df.dropna(subset=[xaxis_column])
                dir = 'dl' if 'dlFdSchedData.laMode' in df.columns else 'ul'

                # Check if lamode still present
                if not df.columns.isin(['dlFdSchedData.laMode', 'ulFdSchedData.laMode']).any() or \
                        len(filtered_df['{}FdSchedData.laMode'.format(dir)]) == 0:
                    add_trace_to_plot(group_by, grouped_df, xaxis_column, yaxis_column, grouped_by_value,
                                      fig, go, row_number_of_subplot, col_number_of_subplot)
                else:
                    lamode_br_df = grouped_df[grouped_df['{}FdSchedData.laMode'.format(
                        dir)] == 'BASICRELIABILITY']
                    fig.add_trace(go.Scatter(x=lamode_br_df[xaxis_column], y=lamode_br_df[yaxis_column],
                                             mode='markers', marker=dict(size=3),
                                             name='{}_BR_{}'.format(yaxis_column, grouped_by_value)),
                                  row=row_number_of_subplot, col=col_number_of_subplot)
                    lamode_hr_df = grouped_df[grouped_df['{}FdSchedData.laMode'.format(
                        dir)] == 'HIGHRELIABILITY']
                    fig.add_trace(go.Scatter(x=lamode_hr_df[xaxis_column], y=lamode_hr_df[yaxis_column],
                                             mode='markers', marker=dict(size=3),
                                             name='{}_HR_{}'.format(yaxis_column, grouped_by_value)),
                                  row=row_number_of_subplot, col=col_number_of_subplot)

                if second_yaxis_col is not None:
                    add_trace_to_plot(group_by, grouped_df, xaxis_column, second_yaxis_col, grouped_by_value, fig, go,
                                      row_number_of_subplot, col_number_of_subplot)

                if third_yaxis_col is not None:
                    add_trace_to_plot(group_by, grouped_df, xaxis_column, third_yaxis_col, grouped_by_value, fig, go,
                                      row_number_of_subplot, col_number_of_subplot)

                if fourth_yaxis_col is not None:
                    add_trace_to_plot(group_by, grouped_df, xaxis_column, fourth_yaxis_col, grouped_by_value, fig, go,
                                      row_number_of_subplot, col_number_of_subplot)

            fig.update_layout(title=title, xaxis_title=xaxis_column,
                              yaxis_title=yaxis_column, width=None, height=None)
            if not title:
                title = yaxis_column.replace(".", "_")
            file_name = "/" + \
                title.replace(" ", "_") + ("_%s.html" %
                                           postfix if postfix else ".html")
            fig.write_html(base_location+file_name, auto_open=False)
    except ModuleNotFoundError:
        logging.warning("plotly is not installed therefore plot will not be saved, please install plotly using "
                        "the command: pip install plotly")


@log_begin_end_func_name
def add_trace_to_plot(group_by, grouped_df, xaxis_column, yaxis_column, grouped_by_value, fig, go,
                      row_number_of_subplot, col_number_of_subplot):
    """
        This function add a new trace to the existing suplot at location:
        row_number_of_subplot x col_number_of_subplot. In case of group by "rnti", further
        traces per PCELL and SCELLs are added.

        :param group_by: The parameter name based on which subplots are created
        :param grouped_by_value: The value of "group_by" parameter for which subplot trace is being added
        :param grouped_df: dataframe with rows filtered by "grouped_by_value"
        :param xaxis_column: xaxis parameter name
        :param yaxis_column: yaxis parameter name
        :param fig: figure object from plotly lib
        :param go: graph object from plotly lib
        :row_number_of_subplot: location of subplot in the figure on x-axis
        :col_number_of_subplot: location of subplot in the figure on y-axis
    """
    if group_by == 'rnti' and grouped_df.columns.isin(['lcrId']).any():
        for lcrIdIndex, lcrId in enumerate(grouped_df['lcrId'].unique()):
            grouped_per_lcrId_df = grouped_df[grouped_df['lcrId'] == lcrId]
            fig.add_trace(go.Scatter(x=grouped_per_lcrId_df[xaxis_column],
                                     y=grouped_per_lcrId_df[yaxis_column],
                                     mode='markers', marker=dict(size=3),
                                     name='{}_{}_{}_{}_{}'.format(
                yaxis_column, group_by, grouped_by_value, 'lcrId', lcrId)),
                row=row_number_of_subplot, col=col_number_of_subplot)
    else:
        fig.add_trace(go.Scatter(x=grouped_df[xaxis_column], y=grouped_df[yaxis_column],
                                 mode='markers', marker=dict(size=3),
                                 name='{}_{}_{}'.format(yaxis_column, group_by, grouped_by_value)),
                      row=row_number_of_subplot, col=col_number_of_subplot)


@log_begin_end_func_name
def plot_df_with_bar(df, xaxis_column="timeStamp", yaxis_column="", base_location="", postfix="bar_graph",
                     title="", group_by='rnti'):
    """ This function generates bar graph .html plot using yaxis_column and xaxis_column columns.
        It is recomended to use the df generated by verify_distribution_table_of function
    """
    try:
        import plotly.graph_objects as go
        from plotly.subplots import make_subplots
        fig = go.Figure()
        fig = make_subplots(rows=1, cols=len(df[group_by].unique()), subplot_titles=(df[group_by].unique()))
        for index, grouped in enumerate(df[group_by].unique()):
            grouped_df = df[df[group_by] == grouped]
            if df.columns.isin(['dlFdSchedData.laMode', 'ulFdSchedData.laMode']).any():
                dir = 'dl' if 'dlFdSchedData.laMode' in df.columns else 'ul'
                lamode_br_df = grouped_df[grouped_df['{}FdSchedData.laMode'.format(dir)] == 'BASICRELIABILITY']
                fig.add_trace(go.Bar(x=lamode_br_df[xaxis_column], y=lamode_br_df[yaxis_column],
                                     name='{}_{}_{}_BR'.format(xaxis_column, group_by, grouped)), row=1, col=index+1)

                lamode_hr_df = grouped_df[grouped_df['{}FdSchedData.laMode'.format(dir)] == 'HIGHRELIABILITY']
                fig.add_trace(go.Bar(x=lamode_hr_df[xaxis_column], y=lamode_hr_df[yaxis_column],
                                     name='{}_{}_{}_HR'.format(xaxis_column, group_by, grouped)), row=1, col=index+1)
            else:
                fig.add_trace(go.Bar(x=df[xaxis_column], y=grouped_df[yaxis_column],
                                     name='{}_{}_{}'.format(xaxis_column, group_by, grouped)), row=1, col=index+1)
        fig.update_layout(title=title, xaxis_title=xaxis_column, yaxis_title=yaxis_column)
        if not title:
            title = xaxis_column.replace(".", "_")
        file_name = "/" + title.replace(" ", "_") + ("_%s.html" % postfix if postfix else ".html")
        fig.write_html(base_location+file_name, auto_open=False)
    except ModuleNotFoundError:
        logging.warning("plotly is not installed therefore plot will not be saved, please install plotly using "
                        "the command: pip install plotly")


@log_begin_end_func_name
def get_correct_cqi_event():
    """ This function gets the CQI event depending on test tags
    """
    olla_cqi_event = 'dlLaDeltaCqiArray.rrmDeltaCqi'
    illa_cqi_event = 'csiSrReportData.csiReport.cqi'
    # CQI events depends whether the test tags contains OLLA or ILLA
    # Therefore, OLLA and ILLA tags are important to be added per TC
    test_tags = rbi.get_variable_value("@{TEST TAGS}")
    cqi_event = illa_cqi_event if 'ILLA' in test_tags else olla_cqi_event
    rbi.log('Using {}'.format(cqi_event))
    return cqi_event


@log_begin_end_func_name
def plot_correlation_events(path_to_pickle, event1, event2, title):
    """ This function generates chart that shows mutiple correlation events

        Suggested pkl file: pkl file with dlharq matcher WITHOUT High reliability filters
        :param path_to_pickle: Path of input pickle file
    """
    df = pd.read_pickle(path_to_pickle)

    filtered_df = df.dropna(subset=[event1])

    # Graph Proposed vs Used MCS
    plot_df_with_scatter(df=filtered_df, yaxis_column=event1,
                         base_location=get_directory(path_to_pickle), postfix="", xaxis_column="timeStamp",
                         title=title, group_by='rnti', second_yaxis_col=event2)

    # Check correlation
    corr_df = filtered_df[[event1, event2]].corr(method='pearson', numeric_only=True)
    display_df_as_html(corr_df)


def plot_muti_correlation_events(path_to_pickle, event1, event2, event3, event4, title):
    """ This function generates chart that shows mutiple correlation events

        Suggested pkl file: pkl file with dlharq matcher WITHOUT High reliability filters
        :param path_to_pickle: Path of input pickle file
    """
    df = pd.read_pickle(path_to_pickle)

    filtered_df = df.dropna(subset=[event1])

    # Graph Proposed vs Used MCS
    plot_df_with_scatter(df=filtered_df, yaxis_column=event1,
                         base_location=get_directory(path_to_pickle), postfix="", xaxis_column="timeStamp",
                         title=title, group_by='rnti', second_yaxis_col=event2,
                         third_yaxis_col=event3,
                         fourth_yaxis_col=event4)
