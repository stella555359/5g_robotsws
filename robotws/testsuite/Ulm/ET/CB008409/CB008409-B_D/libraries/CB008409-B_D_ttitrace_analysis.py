# ====================================================================================================[120 characters]
# This is a Python file, which helps to implement TTITraces Analysis used in CB008409 feature
# Team: 'VRF Ulm VT6'
# Email: 'I_MN_RAN_RD_VRF_ULM_VT6@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

# ET or Feature Specific Libraries:

from testsuite.Ulm.resources.Common.python.common_tools import python_log
from testsuite.Ulm.resources.Common.python.tti_analyzer_framework.tti_dataframe import \
    unnest_dlFdSchedData_scheduledBearers
from testsuite.Ulm.ET.L2.libraries.tools import get_directory
from testsuite.Ulm.ET.L2.libraries.logger import logging
import numpy as np
import pandas as pd

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

@python_log
def verify_maxNumberOfPRBperSlot(path_to_pickle, cellTechnology_NRCELL, chBW_NRCELL, nbrOfBlankedPRBsDL_NRCELL,
                                 bwpChBwPowerSaving_NRCELL):
    """This function checks if the calculated maximum number of PRB per slot is below available_PRBperSlot

        Suggested pkl file: pkl file with event dlFdSchedData present

        :param path_to_pickle: Path of input pickle file
        :param cellTechnology_NRCELL: scf parameter for cell technology (e.g. TDD or FDD)
        :param chBW_NRCELL: scf parameter for channel bandwidth
        :param nbrOfBlankedPRBsDL_NRCELL: scf parameter for nbrOfBlankedPRBsDL
        :param bwpChBwPowerSaving_NRCELL: scf parameter for power saving channel bandwidth
    """
    df = pd.read_pickle(path_to_pickle)
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.mcsTable',
        'dlFdSchedData.numOfLayers', 'dlFdSchedData.SLIV', 'dlFdSchedData.tbSize',
        'dlFdSchedData.rrmDlUsedMcs', 'dlFdSchedData.dciFormat', 'dlFdSchedData.startPrb',
        'dlFdSchedData.numOfPrb', 'dlFdSchedData.numPrbForPowerBoost',
        'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.numOfNonVoNRGbrPrb', 'dlFdSchedData.ackNack',
        'dlFdSchedData.dlHarqProcessIndex', 'dlFdSchedData.suPdschTbTransmitPower', 'dlFdSchedData.txNumber',
        'dlFdSchedData.redundancyVersion', 'dlFdSchedData.PRBCandRetx', 'dlFdSchedData.PRBMinRetx',
        'dlFdSchedData.PRBMaxCodeRateRetx', 'dlFdSchedData.adaptRetxStatus', 'dlFdSchedData.effectiveCodeRate',
        'dlFdSchedData.cellBwpId', 'dlFdSchedData.ueBwpId', 'dlFdSchedData.rat0Bitmap',
        'dlFdSchedAdditionalData.streamConfig.streamIndex1', 'dlFdSchedAdditionalData.streamConfig.streamIndex2',
        'dlPagingOrSibSchedData.numOfPrb'
    ]]

    df = get_available_prb_values_per_slot(df, cellTechnology_NRCELL, chBW_NRCELL, nbrOfBlankedPRBsDL_NRCELL,
                                           bwpChBwPowerSaving_NRCELL)

    df = calculate_number_PRB_per_slot(df)
    df = df.dropna(subset=['dlFdSchedData.numOfPrb'])
    df = df[df['occupied_PDSCH_PRBperSLot'] > df['available_PRBperSlot']]

    if not df.empty:
        display_df_as_html(df)
        df.to_csv(str("%s/numberPRBperSlot.csv" % get_directory(path_to_pickle)))
        cleanup([df])
        rbi.fail('Fail: max. allowed PRB in 1 slot exceeded for TDD and or FDD; check numberPRBperSlot.csv')


@python_log
def verify_powerBoost_for_ReTX(path_to_pickle, maxPrbsIncludingPowerBoostPrbs_NRCELL, numTxThreshForPowerBoost_NRCELL,
                               cellTechnology_NRCELL, chBW_NRCELL, actDlPowerBoost_NRCELL, nbrOfBlankedPRBsDL_NRCELL,
                               actAdaptiveReTxResMcs_NRCELL, bwpChBwPowerSaving_NRCELL):
    """This function checks if only eligible reTX are power boosted

        Suggested pkl file: pkl file with event dlFdSchedData present

        :param path_to_pickle: Path of input pickle file
        :param maxPrbsIncludingPowerBoostPrbs_NRCELL: scf parameter for maximum number of allowed PRB for powerBoosting
        :param numTxThreshForPowerBoost_NRCELL: scf parameter threshold to power boost reTx
        :param cellTechnology_NRCELL: scf parameter for cell technology (e.g. TDD or FDD)
        :param chBW_NRCELL: scf parameter for channel bandwidth
        :param actDlPowerBoost_NRCELL: scf parameter for CB008409 feature activation flag
        :param bwpChBwPowerSaving_NRCELL: scf parameter for power saving channel bandwidth
    """

    # Rnd default values
    rd64QamMcsThreshForPowerBoostEligibility = 9
    rd256QamMcsThreshForPowerBoostEligibility = 4
    rdLowSeMcsThreshForPowerBoostEligibility = 14
    # Note eligible MCS for power boost are only MCS with QPSK modulation (modulation order = 2), if change in Rnd
    # default values these parameters have to be changed according to the used modulation order in the rnd mcs values
    reserved64QamMcsForPowerBoostEligibility = 29
    reserved256QamMcsForPowerBoostEligibility = 28
    reservedLowSeQamMcsForPowerBoostEligibility = 29

    df = pd.read_pickle(path_to_pickle)
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.mcsTable',
        'dlFdSchedData.numOfLayers', 'dlFdSchedData.SLIV', 'dlFdSchedData.tbSize',
        'dlFdSchedData.rrmDlUsedMcs', 'dlFdSchedData.dciFormat', 'dlFdSchedData.startPrb',
        'dlFdSchedData.numOfPrb', 'dlFdSchedData.numPrbForPowerBoost',
        'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.numOfNonVoNRGbrPrb', 'dlFdSchedData.ackNack',
        'dlFdSchedData.dlHarqProcessIndex', 'dlFdSchedData.suPdschTbTransmitPower', 'dlFdSchedData.txNumber',
        'dlFdSchedData.redundancyVersion', 'dlFdSchedData.PRBCandRetx', 'dlFdSchedData.PRBMinRetx',
        'dlFdSchedData.PRBMaxCodeRateRetx', 'dlFdSchedData.adaptRetxStatus', 'dlFdSchedData.effectiveCodeRate',
        'dlFdSchedData.cellBwpId', 'dlFdSchedData.ueBwpId', 'dlFdSchedData.rat0Bitmap',
        'dlFdSchedData.scheduledBearers', 'dlAllocatedPooledResourcesData.numAllocCellPrbDl',
        'dlFdSchedAdditionalData.streamConfig.streamIndex1', 'dlFdSchedAdditionalData.streamConfig.streamIndex2',
        'dlPagingOrSibSchedData.numOfPrb'
    ]]

    if (df[df['dlFdSchedData.numPrbForPowerBoost'] > 0]).empty:
        rbi.fail("No transmission power boosted, event dlFdSchedData.numPrbForPowerBoost=0")

    df = get_available_prb_values_per_slot(df, cellTechnology_NRCELL, chBW_NRCELL, nbrOfBlankedPRBsDL_NRCELL,
                                           bwpChBwPowerSaving_NRCELL)

    # Calculate number of PRB per slot with power boost PRBs
    df = calculate_number_PRB_per_slot(df)

    # Calculate number of PRB per slot without power boost PRBs, used in baseband pooling
    df = calculate_number_AllocCellPRBperSLot(df)

    # Remove all blanks based on event dlFdSchedData
    df = df.dropna(subset=['dlFdSchedData.numOfPrb'])

    # Calculate powerBoost
    df['powerBoostLinear'] = df['totalPRBperTX'] / df['dlFdSchedData.numOfPrb']
    # Here the logarithm calculation is with 100 instead of 10 multiplied,
    # because this makes comparison to tti event
    # 'dlFdSchedData.suPdschTbTransmitPower' easier as there is an offset factor of 10 included
    df['powerBoostdB'] = 100 * np.log10(df['powerBoostLinear'])

    # Convert to binary, for debugging purposes
    df['rat0Bitmap_binary'] = df['dlFdSchedData.rat0Bitmap'].map(lambda x: format(int(x), '020b'))

    # Calculate power Boost
    df = calculate_power_diff(df)

    # unnest event dlFdSchedData.scheduledBearers
    df = unnest_dlFdSchedData_scheduledBearers(df)
    df = df.drop(columns=['dlFdSchedData.scheduledBearers'])

    # Copy value of 1st transmission to retx in scheduledBytes to bearer event
    df = copyBytesPerBearer(df)

    # Define the mapping
    mcs_threshold_map = {
        'QAM256': rd256QamMcsThreshForPowerBoostEligibility,
        'QAM64': rd64QamMcsThreshForPowerBoostEligibility,
        'QAM64LowSE': rdLowSeMcsThreshForPowerBoostEligibility
    }

    # Use map to apply the mapping
    df['rdXQamMcsThreshForPowerBoostElig'] = df['dlFdSchedData.mcsTable'].map(mcs_threshold_map)

    # Define the mapping
    mcs_threshold_map = {
        'QAM256': reserved256QamMcsForPowerBoostEligibility,
        'QAM64': reserved64QamMcsForPowerBoostEligibility,
        'QAM64LowSE': reservedLowSeQamMcsForPowerBoostEligibility
    }

    # Use map to apply the mapping
    df['reservedXQamMCSForPowerBoostElig'] = df['dlFdSchedData.mcsTable'].map(mcs_threshold_map)

    # Handle unsupported MCS tables
    if df['rdXQamMcsThreshForPowerBoostElig'].isnull().any() or df['reservedXQamMCSForPowerBoostElig'].isnull().any():
        rbi.fail('Not supported MCS table, check dlFdSchedData.mcsTable')

    # For debugging purposes
    df.to_csv(str("%s/Debug_filtered.csv" % get_directory(path_to_pickle)), index=False)

    # Remove transient phase
    df = df[~df['dlFdSchedData.dciFormat'].str.contains('MSG')]

    # Remove all 1st transmissions as they are not needed for further checking
    df = df[df['dlFdSchedData.txNumber'] != 1]

    df_non_ReTX_power = pd.DataFrame()
    df_ReTx_non_power = pd.DataFrame()
    df_power_non_adapRetx = pd.DataFrame()

    for lcrId, df_lcrId in df.groupby('lcrId'):
        rbi.log("Verify on cell: {}".format(lcrId))

        if actDlPowerBoost_NRCELL[int(lcrId - 1)] == 'disabled':
            rbi.log("CB008409-B feature activation flag disabled (actDlPowerBoost=disabled) on cell {}".format(lcrId),
                    'WARN')
            continue
        else:
            if (df_lcrId[df_lcrId['dlFdSchedData.numPrbForPowerBoost'] > 0]).empty:
                rbi.fail("No transmission power boosted, event dlFdSchedData.numPrbForPowerBoost = 0, "
                         "actDlPowerBoost != disabled on cell {}".format(lcrId))

        if df_lcrId.empty:
            rbi.log('Dataframe empty after filtering for cell {}'.format(lcrId))
            continue

        # Get single values per cell from cell array
        maxPrbsIncludingPowerBoostPrbs = maxPrbsIncludingPowerBoostPrbs_NRCELL[int(lcrId) - 1]
        numTxThreshForPowerBoost = numTxThreshForPowerBoost_NRCELL[int(lcrId) - 1]
        actDlPowerBoost = actDlPowerBoost_NRCELL[int(lcrId) - 1]

        df_temp = Get_non_eligible_ReTX_powerBoosted(df_lcrId, actDlPowerBoost, maxPrbsIncludingPowerBoostPrbs,
                                                     numTxThreshForPowerBoost)
        df_non_ReTX_power = pd.concat([df_non_ReTX_power, df_temp])

        df_temp = Get_eligible_ReTX_not_powerBoosted(df_lcrId, actDlPowerBoost, maxPrbsIncludingPowerBoostPrbs,
                                                     numTxThreshForPowerBoost)

        if not df_temp.empty:
            display_df_as_html(df_temp)
            rbi.log("Removing all values, where the powerBoostdB calculation is so minimal, "
                    "that it is 0 after rounding on gNB site")
            df_temp = df_temp[~((df_temp['powerBoostdB'] > 0) & (df_temp['powerBoostdB'] < 0.5) &
                                (df_temp['suPdschTbTransmitPower_diff'] == 0))]

        df_ReTx_non_power = pd.concat([df_ReTx_non_power, df_temp])

        # Start check adaptiveRetx is not applied due to PowerBoost
        if actAdaptiveReTxResMcs_NRCELL[int(lcrId - 1)] == 'false':
            rbi.log("actAdaptiveReTxResMcs is disabled on cell {}, skip the AdaptiveReTx validation".format(lcrId),
                    'WARN')
            continue
        else:
            rbi.log("actAdaptiveReTxResMcs is enable on cell {}, check AdaptiveReTx validation".format(lcrId))
            df_lcrId = df_lcrId[df_lcrId['dlFdSchedData.adaptRetxStatus'] == 'NOTAPPLYDUETOPOWERBOOST']
            df_temp = Get_NonAdaptiveRetx_DueTo_PowerBoost(df_lcrId, actDlPowerBoost)
            df_power_non_adapRetx = pd.concat([df_power_non_adapRetx, df_temp])

    if not df_non_ReTX_power.empty and (not df_ReTx_non_power.empty):
        df_non_ReTX_power.to_csv(str("%s/non_ReTX_power.csv" % get_directory(path_to_pickle)))
        display_df_as_html(df_non_ReTX_power)
        rbi.log('Fail: Transmissions are power boosted which should not be power boosted; check non_ReTX_power.csv',
                'ERROR')
        df_ReTx_non_power.to_csv(str("%s/ReTx_non_power.csv" % get_directory(path_to_pickle)))
        display_df_as_html(df_ReTx_non_power)
        cleanup([df, df_non_ReTX_power, df_ReTx_non_power, df_lcrId])
        rbi.log('Fail: Transmissions are not power boosted which should be power boosted; check ReTx_non_power.csv',
                'ERROR')
        rbi.fail('Fail: Transmissions are power boosted which should not be power boosted, check non_ReTX_power.csv '
                 'AND Transmissions are not power boosted which should be power boosted, check ReTx_non_power.csv')

    if not df_non_ReTX_power.empty:
        df_non_ReTX_power.to_csv(str("%s/non_ReTX_power.csv" % get_directory(path_to_pickle)))
        display_df_as_html(df_non_ReTX_power)
        cleanup([df, df_non_ReTX_power, df_lcrId])
        rbi.fail('Fail: Transmissions are power boosted which should not be power boosted, check non_ReTX_power.csv')

    if not df_ReTx_non_power.empty:
        df_ReTx_non_power.to_csv(str("%s/ReTx_non_power.csv" % get_directory(path_to_pickle)))
        display_df_as_html(df_ReTx_non_power)
        cleanup([df, df_ReTx_non_power, df_lcrId])
        rbi.fail('Fail: Transmissions are power not boosted which should be power boosted; check ReTx_non_power.csv')

    if not df_power_non_adapRetx.empty:
        df_power_non_adapRetx.to_csv(str("%s/Power_non_adapRetx.csv" % get_directory(path_to_pickle)))
        display_df_as_html(df_power_non_adapRetx)
        cleanup([df, df_power_non_adapRetx, df_temp, df_lcrId])
        rbi.fail('Fail: when adaptRetxStatus is NOTAPPLYDUETOPOWERBOOST, ResevedMCS should not be used and MCS should '
                 'always under rdXQamMcsThreshForPowerBoostElig, and VoNR/SRB should be scheduled; '
                 'check Power_non_adapRetx.csv')


@python_log
def Get_non_eligible_ReTX_powerBoosted(df, actDlPowerBoost, maxPrbsIncludingPowerBoostPrbs, numTxThreshForPowerBoost):
    """This function gives only non-eligible ReTx which are power boosted

        :param df: input dataframe
        :param actDlPowerBoost: scf feature activation flag
        :param maxPrbsIncludingPowerBoostPrbs: maximum number of allowed PRB for powerBoosting
        :param numTxThreshForPowerBoost: scf parameter threshold to power boost reTx
    """
    if actDlPowerBoost == 'dlVoNRPowerBoost':
        specific_conditions = \
            (df['dlFdSchedData.numOfVoNrPrb'] == 0)
    elif actDlPowerBoost == 'dlSrbPowerBoost':
        specific_conditions = \
            ((df['scheduledBytesPerBearer[1]'] == 0) &
             (df['scheduledBytesPerBearer[2]'] == 0))
    elif actDlPowerBoost == 'dlVoNRAndSrbPowerBoost':
        specific_conditions = \
            ((df['scheduledBytesPerBearer[1]'] == 0) &
             (df['scheduledBytesPerBearer[2]'] == 0) &
             (df['dlFdSchedData.numOfVoNrPrb'] == 0))
    # disbaled case (actDlPowerBoost==disabled)
    else:
        return df[df['suPdschTbTransmitPower_diff'] > 0]

    df = df[(df['suPdschTbTransmitPower_diff'] > 0) &
            (((df['dlFdSchedData.rrmDlUsedMcs'] > df['rdXQamMcsThreshForPowerBoostElig']) &
              (df['dlFdSchedData.rrmDlUsedMcs'] != df['reservedXQamMCSForPowerBoostElig'])) |
             (df['dlFdSchedData.numOfPrb'] >= maxPrbsIncludingPowerBoostPrbs) |
             (df['dlFdSchedData.numPrbForPowerBoost'] == 0) |
             (df['totalPRBperTX'] > maxPrbsIncludingPowerBoostPrbs) |
             (df['dlFdSchedData.txNumber'] <= numTxThreshForPowerBoost) |
             (df['occupied_PDSCH_PRBperSLot'] > df['available_PRBperSlot']) |
             (df['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB'] > df['numAllocCellPrbDl']) |
             specific_conditions
             )]
    return df


@python_log
def Get_eligible_ReTX_not_powerBoosted(df, actDlPowerBoost, maxPrbsIncludingPowerBoostPrbs, numTxThreshForPowerBoost):
    """This function gives eligible ReTx which are not power boosted

        :param df: input dataframe
        :param actDlPowerBoost: scf feature activation flag
        :param maxPrbsIncludingPowerBoostPrbs: maximum number of allowed PRB for powerBoosting
        :param numTxThreshForPowerBoost: scf parameter threshold to power boost reTx
    """
    common_conditions = \
        ((df['suPdschTbTransmitPower_diff'] == 0) &
         ((df['dlFdSchedData.rrmDlUsedMcs'] <= df['rdXQamMcsThreshForPowerBoostElig']) |
          (df['dlFdSchedData.rrmDlUsedMcs'] == df['reservedXQamMCSForPowerBoostElig'])) &
         (df['dlFdSchedData.numOfPrb'] < maxPrbsIncludingPowerBoostPrbs) &
         (df['dlFdSchedData.numPrbForPowerBoost'] > 0) &
         (df['totalPRBperTX'] <= maxPrbsIncludingPowerBoostPrbs) &
         (df['dlFdSchedData.txNumber'] > numTxThreshForPowerBoost) &
         (df['occupied_PDSCH_PRBperSLot'] <= df['available_PRBperSlot']) &
         (df['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB'] <= df['numAllocCellPrbDl']))

    if actDlPowerBoost == 'dlVoNRPowerBoost':
        specific_conditions = df['dlFdSchedData.numOfVoNrPrb'] > 0
        return df[common_conditions & specific_conditions]
    elif actDlPowerBoost == 'dlSrbPowerBoost':
        specific_conditions = \
            ((df['scheduledBytesPerBearer[1]'] > 0) |
             (df['scheduledBytesPerBearer[2]'] > 0))
        return df[common_conditions & specific_conditions]
    elif actDlPowerBoost == 'dlVoNRAndSrbPowerBoost':
        specific_conditions = \
            ((df['scheduledBytesPerBearer[1]'] > 0) |
             (df['scheduledBytesPerBearer[2]'] > 0) |
             (df['dlFdSchedData.numOfVoNrPrb'] > 0))
        return df[common_conditions & specific_conditions]
    # disbaled case (actDlPowerBoost==disabled)
    else:
        rbi.log("CB008409-B feature activation flag disabled (actDlPowerBoost=disabled")


@python_log
def Get_NonAdaptiveRetx_DueTo_PowerBoost(df, actDlPowerBoost):
    """This function gives eligible ReTx which power boost function blocks the AdaptiveRetx

        :param df: input dataframe
        :param actDlPowerBoost: scf feature activation flag
    """

    common_conditions = (df['dlFdSchedData.rrmDlUsedMcs'] > df['rdXQamMcsThreshForPowerBoostElig'])

    if actDlPowerBoost == 'dlVoNRPowerBoost':
        specific_conditions = df['dlFdSchedData.numOfVoNrPrb'] == 0
        return df[common_conditions & specific_conditions]
    elif actDlPowerBoost == 'dlSrbPowerBoost':
        specific_conditions = \
            ((df['scheduledBytesPerBearer[1]'] == 0) &
             (df['scheduledBytesPerBearer[2]'] == 0))
        return df[common_conditions & specific_conditions]
    elif actDlPowerBoost == 'dlVoNRAndSrbPowerBoost':
        specific_conditions = \
            ((df['scheduledBytesPerBearer[1]'] == 0) &
             (df['scheduledBytesPerBearer[2]'] == 0) &
             (df['dlFdSchedData.numOfVoNrPrb'] == 0))
        return df[common_conditions & specific_conditions]
    else:
        rbi.log("AdaptiveReTx validation pass in this cell")


@python_log
def calculate_number_PRB_per_slot(df):
    """This function calculates the number of PRB per slot

        :param df: input dataframe
    """
    df = normalize_sfn_values(df)

    # Separate power saving BWP part (cellBwpId == 2) and non-power saving
    df_power_saving = df[df['dlFdSchedData.cellBwpId'] == 2]
    df_non_power_saving = df[df['dlFdSchedData.cellBwpId'] != 2]

    # Calculate PRB for power saving BWP part
    df_power_saving = calculate_number_PRB_per_sLot_without_power_boost_PRB(df_power_saving)
    df_power_saving['occupied_PDSCH_PRBperSLot'] = df_power_saving['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB']

    df_non_power_saving['totalPRBperTX'] = (df_non_power_saving['dlFdSchedData.numOfPrb'] +
                                            df_non_power_saving['dlFdSchedData.numPrbForPowerBoost'])

    # Calculate PRB for non-power saving BWP parts
    # Group by relevant columns
    grouped = df_non_power_saving.groupby(['lcrId', 'normalized_sfn', 'slot',
                                           'dlFdSchedAdditionalData.streamConfig.streamIndex1',
                                           'dlFdSchedAdditionalData.streamConfig.streamIndex2'])

    # Calculate cumulative sum of PRB per slot
    df_non_power_saving['occupied_PDSCH_PRB_per_slot_with_powerboost_PRB'] = grouped['totalPRBperTX'].cumsum()

    # Get the maximum cumulative sum within each group
    df_non_power_saving['occupied_PDSCH_PRB_per_slot_with_powerboost_PRB'] = \
        grouped['occupied_PDSCH_PRB_per_slot_with_powerboost_PRB'].transform('max')

    df_non_power_saving['occupied_PDSCH_PRBperSLot'] = \
        df_non_power_saving['occupied_PDSCH_PRB_per_slot_with_powerboost_PRB']

    # Concatenate the results
    df_PRB = pd.concat([df_power_saving, df_non_power_saving])

    cleanup([df, df_power_saving, df_non_power_saving])

    return df_PRB


@python_log
def calculate_power_diff(df):
    """This function calculates the power difference used for boosting reTX.

    Credits: Alexandre Cunha, Nokia GPT (https://gpt.nokia.com/)

    Args:
        df: Input dataframe.

    Returns:
        A sorted dataframe with the calculated power difference.
    """

    # Group by rnti, lcrId, and dlHarqProcessIndex
    grouped = df.groupby(['rnti', 'lcrId', 'dlFdSchedData.dlHarqProcessIndex'])

    # Calculate power difference for each group
    def calculate_group_diff(group):
        # Directly apply ffill to the relevant column within the group
        group['suPdschTbTransmitPower_tx1'] = group['dlFdSchedData.suPdschTbTransmitPower'].where(
            group['dlFdSchedData.txNumber'] == 1, np.nan).ffill()
        group['suPdschTbTransmitPower_diff'] = (group['dlFdSchedData.suPdschTbTransmitPower'] -
                                                group['suPdschTbTransmitPower_tx1'])
        return group

    complete_df = grouped.apply(calculate_group_diff).reset_index(drop=True)

    cleanup([df])

    # Sort by timestamp and rnti
    return complete_df.sort_values(by=['timeStamp', 'rnti'])


@python_log
def copyBytesPerBearer(df):
    """This function copies the value in scheduledBytesPerBearer of the 1st Tx to the ReTX of the 1st in the
    scheduledBytesPerBearer event. Note_ only those events which are relevant for this feature are copied!

    Credits: Alexandre Cunha, Nokia GPT (https://gpt.nokia.com/)

        :param df: input dataframe
    """

    # Group by rnti, lcrId, and dlHarqProcessIndex
    grouped = df.groupby(['lcrId', 'rnti', 'dlFdSchedData.dlHarqProcessIndex'])

    # Copy bytes for bearer, for each group
    def copy_bytes_per_bearer(group):
        # Directly apply ffill to the relevant column within the group
        group['scheduledBytesPerBearer[1]'] = group['dlFdSchedData.scheduledBytesPerBearer[1]'].where(
            group['dlFdSchedData.txNumber'] == 1, np.nan).ffill()
        group['scheduledBytesPerBearer[2]'] = group['dlFdSchedData.scheduledBytesPerBearer[2]'].where(
            group['dlFdSchedData.txNumber'] == 1, np.nan).ffill()
        return group

    complete_df = grouped.apply(copy_bytes_per_bearer).reset_index(drop=True)

    cleanup([df])

    # Sort by timestamp and rnti
    return complete_df.sort_values(by=['timeStamp', 'rnti'])


@python_log
def get_available_prb_values_per_slot(df, cellTechnology_NRCELL, chBW_NRCELL, nbrOfBlankedPRBsDL_NRCELL,
                                      bwpChBwPowerSaving_NRCELL):
    """ This function returns the desired prb values from the list present on the specification according
        to the duplex, technology and bandwidth used.

        Sample row:
        Duplex	System BW(MHz)	Transmission BW(PRB)
          FDD	    20	               106


        : return float variable of max_prb_from_cell_bw

    """
    # Create a DataFrame for PRB lookup
    df_PRB_chBW = pd.DataFrame({'Duplex': ['FDD', 'FDD', 'FDD', 'FDD', 'FDD', 'TDD', 'TDD', 'TDD', 'TDD', 'TDD',
                                           'TDD', 'TDD', 'TDD', 'TDD'],
                                'System BW(MHz)': [5, 10, 15, 20, 40, 20, 30, 40, 50, 60, 70, 80, 90, 100],
                                'Transmission BW(PRB)': [25, 52, 79, 106, 216, 51, 78, 106, 133, 162, 189, 217,
                                                         245, 273]})

    # Create a new DataFrame to store results
    df_PRB = pd.DataFrame()

    # Group by lcrId and cellBwpId
    for lcrId, df_lcrId in df.groupby('lcrId'):
        for cellBwpId, df_cellBwpId in df_lcrId.groupby('dlFdSchedData.cellBwpId'):
            rbi.log(f"Get max available PRB's on cell: {lcrId} and cellBwpId: {cellBwpId}")

            # Get cell technology and bandwidth based on cellBwpId
            cellTechnology = cellTechnology_NRCELL[int(lcrId) - 1]
            chBW = bwpChBwPowerSaving_NRCELL[int(lcrId) - 1] if cellBwpId == 2 else chBW_NRCELL[int(lcrId) - 1]
            nbrOfBlankedPRBsDL = nbrOfBlankedPRBsDL_NRCELL[int(lcrId) - 1]

            # Lookup max PRB from cell bandwidth
            max_prb_from_cell_bw = (df_PRB_chBW.loc[
                (df_PRB_chBW['System BW(MHz)'] == chBW) &
                (df_PRB_chBW['Duplex'] == cellTechnology)]['Transmission BW(PRB)'].iloc[0])

            # Normalize SFN values and calculate SSB/SIB PRBs
            df_cellBwpId = normalize_sfn_values(df_cellBwpId)
            df_cellBwpId = calculate_SSB_and_SIB_PRBs(df_cellBwpId)

            # Calculate available PRB per slot
            df_cellBwpId['nbrOfBlankedPRBsDL'] = nbrOfBlankedPRBsDL
            df_cellBwpId['max_prb_from_cell_bw'] = max_prb_from_cell_bw
            df_cellBwpId['available_PRBperSlot'] = (df_cellBwpId['max_prb_from_cell_bw'] -
                                                    df_cellBwpId['nbrOfBlankedPRBsDL'] - df_cellBwpId['SSB_PRBs'] -
                                                    df_cellBwpId['SIB_PRBs'])

            # Concatenate results
            df_PRB = pd.concat([df_PRB, df_cellBwpId])

    cleanup([df, df_lcrId, df_cellBwpId])

    return df_PRB


@python_log
def get_expected_pmc_values(path_to_pickle, cell):
    """ This function computes for the expected values of Rank Related DL PM Counters based on Collected TTI Traces
        Suggested pkl file: pkl file with dlharqmatcher WITHOUT High reliability filters

        :param path_to_pickle: Path of input pickle file
        :param cell: cell to analyze

        :returns pmc_values_dict: a dictionary of Rank Related DL PMC Values
    """
    # ------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    df = df[['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.numPrbForPowerBoost']]
    df = df.dropna()
    df.to_csv(str("%s/manual_analysis_get_expected_pmc_values.csv" % get_directory(path_to_pickle)), index=False)
    mcs_pmc_dict = {}
    df = df[(df['lcrId'] == cell)]
    mcs_pmc_dict['M55308C10014'] = int((df['dlFdSchedData.numPrbForPowerBoost']).sum())

    cleanup([df])

    return mcs_pmc_dict


@python_log
def verify_if_values_changed_after_online_modification(path_to_pickle, min_numPrbForPowerBoost=8):
    """ This function checks if numPrbForPowerBoost and txNumber change after NIDD Online Modify
        :param path_to_pickle: Path of input pickle file
        :param min_numPrbForPowerBoost:is used to check if numPrbForPowerBoost after NIDD powerBoostScalingFactor change
           As 5G_UP_ALG_25407 explained:
           numPrbForPowerBoost = (initialTx)numOfPrb * powerBoostScalingFactor-(initialTx)numOfPrb
                               = (initialTx)numOfPrb * (powerBoostScalingFactor - 1)
           (initialTx)numOfPrb = N * RBG Size (in FDD 15MHZ BW 79PRBs--> RBG Size = 8PRBs <38.214 - Table 5.1.2.2.1-1>)
                                 N = 1, 2, 3, ..
           for powerBoostScalingFactor Default 2. Range [1.1, 2.0] 0.1.
           so when powerBoostScalingFactor=2, min_numPrbForPowerBoost = (1*8) * (2-1) = 8 PRBs (N=1)
           as powerBoostScalingFactor can only change to a smaller value, then the new_numPrbForPowerBoost after NIDD
           change will less than min_numPrbForPowerBoost.
    """

    df = pd.read_pickle(path_to_pickle)
    df = df[[
        'timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'dlFdSchedData.mcsTable', 'dlFdSchedData.rrmDlUsedMcs',
        'dlFdSchedData.dciFormat', 'dlFdSchedData.numOfPrb', 'dlFdSchedData.numPrbForPowerBoost',
        'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.ackNack', 'dlFdSchedData.dlHarqProcessIndex',
        'dlFdSchedData.suPdschTbTransmitPower', 'dlFdSchedData.txNumber'
    ]]

    df = df.dropna(subset=['dlFdSchedData.txNumber'])
    df_key_tti_events = df.copy(deep=True)
    df_key_tti_events.columns = [
        'timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'mcsTable', 'rrmDlUsedMcs', 'dciFormat',
        'numOfPrb', 'numPrbForPowerBoost', 'numOfVoNrPrb', 'ackNack',
        'dlHarqProcessIndex', 'suPdschTbTransmitPower', 'txNumber'
    ]
    if not df_key_tti_events.empty:
        df_key_tti_events.to_csv(str("%s/powerboost_related_tti_events.csv" % get_directory(path_to_pickle)))

    if (df[df['dlFdSchedData.numPrbForPowerBoost'] > 0]).empty:
        raise Exception("No transmission power boosted, event dlFdSchedData.numPrbForPowerBoost = 0")

    df = df[(df['dlFdSchedData.numPrbForPowerBoost'] != 0)]

    if len(df[df['dlFdSchedData.numPrbForPowerBoost'] < min_numPrbForPowerBoost]) == 0:
        rbi.log("Number of occurences of values under column numPrbForPowerBoost less than 8 is 0", 'ERROR')
        rbi.fail("powerBoostScalingFactor wasn't changed to smaller value compare to NIDD default value 2.. failing TC")
    else:
        rbi.log("powerBoostScalingFactor is changed, check if numTxThreshForPowerBoost is changed")

    # Getting the first row with event modified value
    first_row_modify = df[df['dlFdSchedData.numPrbForPowerBoost'] < min_numPrbForPowerBoost].index[0]
    df_after_modification = df.loc[first_row_modify:, :]
    df_before_modification = df.loc[:first_row_modify, :]

    frequent_value_before_modification = df_before_modification['dlFdSchedData.txNumber'].value_counts()
    # numTxThreshForPowerBoost default value is 2, then expected retx number is bigger than 2
    if frequent_value_before_modification.item:
        frequent_txnum_before_modification = dict(frequent_value_before_modification).keys()
        expected_txnum_before_modification = [3, 4, 5, 6]
        diff_before_modification = set(frequent_txnum_before_modification) - set(expected_txnum_before_modification)
        if diff_before_modification:
            display_df_as_html(df_before_modification)
            rbi.log("Check if is NIDD numTxThreshForPowerBoost default changed!", 'WARN')
        else:
            rbi.log("Verify expected retx number before online modification pass")
    else:
        rbi.log("Check powerboost_related_tti_events.csv to analyze result", 'WARN')

    frequent_value_after_modification = df_after_modification['dlFdSchedData.txNumber'].value_counts()
    # Change numTxThreshForPowerBoost value to 4, then expected retx number is bigger than 4
    if frequent_value_after_modification.item:
        frequent_txnum_after_modification = dict(frequent_value_after_modification).keys()
        expected_txnum_after_modification = [5, 6]
        diff_after_modification = set(frequent_txnum_after_modification) - set(expected_txnum_after_modification)
        if diff_after_modification:
            display_df_as_html(df_after_modification)
            rbi.fail("Check powerboost_related_tti_events.csv to analyze result. Test case fail")
        else:
            rbi.log("Online modification works! Passing test case")
    else:
        rbi.log("Check powerboost_related_tti_events.csv to analyze result", 'WARN')


@python_log
def verify_values_changed_after_online_modification(path_to_pickle):
    """ This function checks if numPrbForPowerBoost and txNumber change after NIDD Online Modify
    For this we are trying to detect the change as in following example, we are trying to detect, when powerBoostlinear
    changes from >1.1 to < 1.2 when dlFdSchedData.txNumber >= 5

    dlFdSchedData.txNumber          powerBoostLinear
        2	                            2
        3	                            2
        4   	                        2
        5	                            2
        5	                            1.166666667    -> Trying to detect this change here
        5	                            1.166666667
        5	                            1.105263158
        5	                            1.166666667
        5	                            1.166666667

    """

    df = pd.read_pickle(path_to_pickle)

    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.numOfPrb',
        'dlFdSchedData.numPrbForPowerBoost', 'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.numOfNonVoNRGbrPrb',
        'dlFdSchedData.txNumber', 'dlFdSchedData.rrmDlUsedMcs', 'dlFdSchedData.ackNack',
        'dlFdSchedData.suPdschTbTransmitPower', 'dlFdSchedData.dlHarqProcessIndex', 'dlFdSchedData.cellBwpId',
        'dlFdSchedAdditionalData.streamConfig.streamIndex1', 'dlFdSchedAdditionalData.streamConfig.streamIndex2'
    ]]

    if (df[df['dlFdSchedData.numPrbForPowerBoost'] > 0]).empty:
        raise Exception("No transmission power boosted, event dlFdSchedData.numPrbForPowerBoost=0")

    # Calculate number of PRB per slot with power boost PRBs
    df = calculate_number_PRB_per_slot(df)

    # Remove all blanks based on event dlFdSchedData
    df = df.dropna(subset=['dlFdSchedData.numOfPrb'])

    # Calculate powerBoost
    df['powerBoostLinear'] = df['totalPRBperTX'] / df['dlFdSchedData.numOfPrb']
    # Here the logarithm calculation is with 100 instead of 10 multiplied,
    # because this makes comparison to tti event
    # 'dlFdSchedData.suPdschTbTransmitPower' easier as there is an offset factor of 10 included
    df['powerBoostdB'] = 100 * np.log10(df['powerBoostLinear'])

    df.to_csv(str("%s/Online_Modify.csv" % get_directory(path_to_pickle)))

    df = df[df['dlFdSchedData.numPrbForPowerBoost'] != 0]

    # Detect the change where dlFdSchedData.txNumber=5 and powerBoostLinear changes from >= 1.2 to < 1.2
    # (df['dlFdSchedData.txNumber'] >= 5)       # ensures we only check rows where dlFdSchedData.txNumber is 5 or more.
    # df['powerBoostLinear'] < 1.2) &           # ensures we detect rows where powerBoostLinear is smaller then 1.2 as
    # we are setting 1.1 as powerboost factor in online modify
    # df['powerBoostLinear'].shift(1) >= 1.2)   # checks if the previous value of powerBoostLinear was bigger then 1.2

    df['OnlineModifyChange'] = (
            (df['dlFdSchedData.txNumber'] >= 5) &
            (df['powerBoostLinear'] < 1.2) &
            (df['powerBoostLinear'].shift(1) >= 1.2))

    # Find the index where the change occurs
    change_index = df[df['OnlineModifyChange']].index

    if not change_index.empty:
        # Split the DataFrame to after and before online modify, but only keep the dataframe after online modify
        # Get the first occurrence of the change
        split_index = change_index[0]
        print("split_index:", split_index)
        # Rows after the change of online modify
        df_after_change = df.iloc[df.index >= split_index]
    else:
        raise Exception('No online modify changed detected')

    # check if all values after online modifiy has been changed, powerBoostLinear should not exceed the value of 1.2 and
    # reTX below 5 should not be powerboosted
    df_after_change = df_after_change[((df_after_change['powerBoostLinear'] >= 1.2) | (
                (df_after_change['dlFdSchedData.txNumber'] < 5) & (
                    df_after_change['dlFdSchedData.numPrbForPowerBoost'] > 0)))]
    if not df_after_change.empty:
        display_df_as_html(df_after_change)
        raise Exception('Not all values are changed to new online modify value')


@python_log
def verify_RBG_randomization(path_to_pickle, actPowerSavingBWP_NRCELL, actRat1Alloc_NRCELL):
    """ This functions checks if the RGB are allocated in a random order to minimize cell interference

    :param path_to_pickle: Path of input pickle file
    :param actPowerSavingBWP_NRCELL: scf parameter for BWP Power Saving (5GC000937) feature activation flag
    :param actRat1Alloc_NRCELL: scf parameter for Rat1 Allocation feacture activation flag
    """

    if 'false' not in actRat1Alloc_NRCELL:
        return

    df = pd.read_pickle(path_to_pickle)
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.mcsTable',
        'dlFdSchedData.numOfLayers', 'dlFdSchedData.SLIV', 'dlFdSchedData.tbSize',
        'dlFdSchedData.rrmDlUsedMcs', 'dlFdSchedData.dciFormat', 'dlFdSchedData.startPrb',
        'dlFdSchedData.numOfPrb', 'dlFdSchedData.numPrbForPowerBoost',
        'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.numOfNonVoNRGbrPrb', 'dlFdSchedData.ackNack',
        'dlFdSchedData.dlHarqProcessIndex', 'dlFdSchedData.suPdschTbTransmitPower', 'dlFdSchedData.txNumber',
        'dlFdSchedData.redundancyVersion', 'dlFdSchedData.PRBCandRetx', 'dlFdSchedData.PRBMinRetx',
        'dlFdSchedData.PRBMaxCodeRateRetx', 'dlFdSchedData.adaptRetxStatus', 'dlFdSchedData.effectiveCodeRate',
        'dlFdSchedData.cellBwpId', 'dlFdSchedData.ueBwpId', 'dlFdSchedData.rat0Bitmap'
    ]]

    df = df.dropna()
    df['sfn_diff'] = df['sfn'].diff()
    df['slot_diff'] = df['slot'].diff()

    # Convert to binary, for debugging purposes, the '1' in the rat0Bitmap_binaray should be distributed
    df['rat0Bitmap_binary'] = df['dlFdSchedData.rat0Bitmap'].apply(lambda x: format(int(x), '020b'))
    # Add one column about the length of bitmap, BWP_PS BW is smaller, so the length of bitmap is smaller as well
    df['rat0Bitmap_length'] = df['rat0Bitmap_binary'].apply(lambda x: len(str(x)))

    # check if BwpPs Switch happening and if PRB resources allocation correct and mapped with cellBwpId
    for lcrId, df_lcrId in df.groupby('lcrId'):
        if actRat1Alloc_NRCELL[int(lcrId - 1)] == 'true':
            continue
        if actPowerSavingBWP_NRCELL[int(lcrId - 1)] == 'false':
            rbi.log("BwpPs switch not enabled on cell {}, check if PRB allocated in the whole BW pass".format(lcrId))
            if df_lcrId['rat0Bitmap_length'].any() > 18:
                cleanup([df, df_lcrId])
                rbi.fail("PRB allocated over the whole BW, check powerboost_related_tti_events.csv")
            continue
            df_lcrId['sfn_diff'] = df_lcrId['sfn'].diff()
            df_lcrId['slot_diff'] = df_lcrId['slot'].diff()
            df_lcrId['dlFdSchedData.rat0Bitmap_diff'] = df_lcrId['dlFdSchedData.rat0Bitmap'].diff()
            df_lcrId['dlFdSchedData.startPrb_diff'] = df_lcrId['dlFdSchedData.startPrb'].diff()

            df_diff = (df_lcrId['sfn_diff'] == 0) & (df_lcrId['slot_diff'] == 0) & \
                      ((df_lcrId['dlFdSchedData.rat0Bitmap_diff'] == 0) |
                       (df_lcrId['dlFdSchedData.startPrb_diff'] == 0))
            # save faulty row and previous row for comparison
            df_diff_shift = df_lcrId[df_diff | df_diff.shift(-1)]

            if not df_diff_shift.empty:
                df_diff_shift.to_csv(str("%s/B2_randomization.csv" % get_directory(path_to_pickle)))
                df.to_csv(str("%s/B2_debug_randomization.csv" % get_directory(path_to_pickle)), index=False)
                display_df_as_html(df_diff_shift)
                cleanup([df_diff_shift, df_diff])
                rbi.fail('Fail: Randomization not applied, check B2_randomization.csv, '
                         'startPrb or rat0Bitmap should be different, '
                         'for overall tti trace see file: B2_debug_randomization.csv')
        else:
            rbi.log("BwpPs switch enabled on cell {}, check if PRB allocated according to cellBwpId".format(lcrId))
            for cellBwpId, df_cellBwpId in df_lcrId.groupby('dlFdSchedData.cellBwpId'):
                if cellBwpId == 2:
                    if df_cellBwpId.empty:
                        cleanup([df, df_lcrId])
                        rbi.fail("UEs did not be scheduled to PS BWP on cell {}, "
                                 "please check powerboost_related_tti_events.csv".format(lcrId))
                    elif df_cellBwpId['rat0Bitmap_length'].any() > 14:
                        cleanup([df, df_lcrId, df_cellBwpId])
                        rbi.fail("PRB allocated over the BwpPs BW on cell {}, "
                                 "check powerboost_related_tti_events.csv".format(lcrId))

                    df_cellBwpId['sfn_diff'] = df_cellBwpId['sfn'].diff()
                    df_cellBwpId['slot_diff'] = df_cellBwpId['slot'].diff()
                    df_cellBwpId['dlFdSchedData.rat0Bitmap_diff'] = df_cellBwpId['dlFdSchedData.rat0Bitmap'].diff()
                    df_cellBwpId['dlFdSchedData.startPrb_diff'] = df_cellBwpId['dlFdSchedData.startPrb'].diff()

                    df_diff = (df_cellBwpId['sfn_diff'] == 0) & (df_cellBwpId['slot_diff'] == 0) & \
                              ((df_cellBwpId['dlFdSchedData.rat0Bitmap_diff'] == 0) |
                               (df_cellBwpId['dlFdSchedData.startPrb_diff'] == 0))

                    # save faulty row and previous row for comparison
                    df_diff_shift = df_cellBwpId[df_diff | df_diff.shift(-1)]

                    if not df_diff_shift.empty:
                        df_diff_shift.to_csv(str("%s/B2_randomization.csv" % get_directory(path_to_pickle)))
                        df.to_csv(str("%s/B2_debug_randomization.csv" % get_directory(path_to_pickle)), index=False)
                        display_df_as_html(df_diff_shift)
                        cleanup([df, df_lcrId, df_cellBwpId, df_diff_shift, df_diff])
                        rbi.fail('Fail: Randomization not applied, check B2_randomization.csv, '
                                 'startPrb or rat0Bitmap should be different, '
                                 'for overall tti trace see file: B2_debug_randomization.csv')

                elif cellBwpId == 1:
                    if df_cellBwpId.empty:
                        cleanup([df, df_lcrId])
                        rbi.fail("UEs did not be scheduled to full BW on cell {}, "
                                 "please check powerboost_related_tti_events.csv".format(lcrId))
                    elif df_cellBwpId['rat0Bitmap_length'].any() > 18:
                        cleanup([df, df_lcrId, df_cellBwpId])
                        rbi.fail("PRB allocated over the whole BW on cell {}, "
                                 "check powerboost_related_tti_events.csv".format(lcrId))

                    df_cellBwpId['sfn_diff'] = df_cellBwpId['sfn'].diff()
                    df_cellBwpId['slot_diff'] = df_cellBwpId['slot'].diff()
                    df_cellBwpId['dlFdSchedData.rat0Bitmap_diff'] = df_cellBwpId['dlFdSchedData.rat0Bitmap'].diff()
                    df_cellBwpId['dlFdSchedData.startPrb_diff'] = df_cellBwpId['dlFdSchedData.startPrb'].diff()

                    df_diff = (df_cellBwpId['sfn_diff'] == 0) & (df_cellBwpId['slot_diff'] == 0) & \
                              ((df_cellBwpId['dlFdSchedData.rat0Bitmap_diff'] == 0) |
                               (df_cellBwpId['dlFdSchedData.startPrb_diff'] == 0))
                    # save faulty row and previous row for comparison
                    df_diff_shift = df_cellBwpId[df_diff | df_diff.shift(-1)]

                    if not df_diff_shift.empty:
                        df_diff_shift.to_csv(str("%s/B2_randomization.csv" % get_directory(path_to_pickle)))
                        df.to_csv(str("%s/B2_debug_randomization.csv" % get_directory(path_to_pickle)), index=False)
                        display_df_as_html(df_diff_shift)
                        cleanup([df, df_lcrId, df_cellBwpId, df_diff_shift, df_diff])
                        rbi.fail('Fail: Randomization not applied, check B2_randomization.csv, '
                                 'startPrb or rat0Bitmap should be different, '
                                 'for overall tti trace see file: B2_debug_randomization.csv')
    cleanup([df, df_lcrId])


@python_log
def verify_maxNumberOfPRBPerSlotNotExceedingdlAllocatedPooledResourcesDatanumAllocCellPrbDl(path_to_pickle):
    """This function checks if the maximum number of allocated pooled PRB resources per slot is below
    'dlAllocatedPooledResourcesData.numAllocCellPrbDl'

        Suggested pkl file: pkl file with event dlFdSchedData present

        :param path_to_pickle: Path of input pickle file

    """
    df = pd.read_pickle(path_to_pickle)
    df = df[[
        'timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'dlFdSchedData.numOfPrb',
        'dlAllocatedPooledResourcesData.numAllocCellPrbDl', 'dlFdSchedAdditionalData.streamConfig.streamIndex1',
        'dlFdSchedAdditionalData.streamConfig.streamIndex2', 'dlPagingOrSibSchedData.numOfPrb'
    ]]

    df = calculate_number_AllocCellPRBperSLot(df)
    df = df.dropna(subset=['dlFdSchedData.numOfPrb'])

    df = df[df['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB'] > df['numAllocCellPrbDl']]

    if not df.empty:
        display_df_as_html(df)
        df.to_csv(str("%s/AllocatednumberPRBperSlot.csv" % get_directory(path_to_pickle)))
        cleanup([df])
        rbi.fail('Fail: max. allowed PRB in 1 slot exceeded for TDD and or FDD; check AllocatednumberPRBperSlot.csv')


@python_log
def calculate_number_AllocCellPRBperSLot(df):
    """This function calculates the number of PRB per slot without power boosted PRB

        :param df: input dataframe
    """
    df['numAllocCellPrbDl'] = df['dlAllocatedPooledResourcesData.numAllocCellPrbDl']
    df['numAllocCellPrbDl'] = df.groupby('lcrId')['numAllocCellPrbDl'].transform('ffill')
    df = normalize_sfn_values(df)
    df = calculate_SSB_and_SIB_PRBs(df)
    df['numAllocCellPrbDl'] = df['numAllocCellPrbDl'] - df['SSB_PRBs'] - df['SIB_PRBs']
    df = calculate_number_PRB_per_sLot_without_power_boost_PRB(df)
    df = df.drop(columns=['dlAllocatedPooledResourcesData.numAllocCellPrbDl'])
    return df


@python_log
def calculate_number_PRB_per_sLot_without_power_boost_PRB(df):
    """This function calculates the number of PRB per slot without power boosted PRB

        :param df: input dataframe
    """
    # Group by relevant columns
    grouped = df.groupby(['lcrId', 'normalized_sfn', 'slot', 'dlFdSchedAdditionalData.streamConfig.streamIndex1',
                         'dlFdSchedAdditionalData.streamConfig.streamIndex2'])

    # Calculate cumulative sum of PRB per slot
    df['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB'] = grouped['dlFdSchedData.numOfPrb'].cumsum()

    # Get the maximum cumulative sum within each group
    df['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB'] = \
        grouped['occupied_PDSCH_PRB_per_slot_without_powerboost_PRB'].transform('max')

    return df


@python_log
def calculate_SSB_and_SIB_PRBs(df):
    """This function calculates the number of PRB reserved for SSB and SIB transmissions

        :param df: input dataframe with normalized sfn values (call 'normalize_sfn_values' before this function)
    """
    # Copy the SIB PRBs to other rows with same sfn and slot
    df['SIB_PRBs'] = df.groupby(['lcrId', 'normalized_sfn', 'slot'])['dlPagingOrSibSchedData.numOfPrb'].transform('max')
    df['SIB_PRBs'] = df['SIB_PRBs'].fillna(0)

    # SSB's are every even sfn with slot number 0, upload scf on http://5gtables.eecloud.dynamic.nsn-net.net/ to
    # see position of SSB slots
    df['SSB_PRBs'] = np.where((df['sfn'] % 2 == 0) & (df['slot'] == 0), 20, 0)

    return df


@python_log
def Get_dynamic_RAT0_RAT1_pairing_slots(path_to_pickle, actDlDynSwitchAlloc_NRCELL):
    """This function gets the slots, where RAT0/RAT1 in 1 slot can be found, if slots are detected a csv file with name
    RAT0_RAT1_pairs.csv is generated

        Suggested pkl file: pkl file with event dlFdSchedData present

        :param path_to_pickle: Path of input pickle file
        :param actDlDynSwitchAlloc_NRCELL: scf feature activation flag array
    """

    df = pd.read_pickle(path_to_pickle)

    # Select relevant columns
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.startPrb',
        'dlFdSchedData.numPrbForPowerBoost', 'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.rat0Bitmap',
        'dlFdSchedData.numOfPrb'
    ]]

    # Drop rows with missing data
    df = df.dropna(subset=['dlFdSchedData.rat0Bitmap'])

    # Normalize SFN values
    df = normalize_sfn_values(df)

    # Convert rat0Bitmap to binary string
    df['rat0Bitmap_binary'] = df['dlFdSchedData.rat0Bitmap'].map(lambda x: format(int(x), '020b'))

    def _process_lcrId_group(group, actDlDynSwitchAlloc_NRCELL):
        """Helper function to process data for each lcrId group."""
        lcrId = group['lcrId'].iloc[0]
        if actDlDynSwitchAlloc_NRCELL[int(lcrId - 1)] == 'false':
            rbi.log(f"Dynamic switch not enabled on cell {lcrId}")
            return pd.DataFrame({'lcrId': [None]})  # Return empty DataFrame for no pairing
        else:
            # Calculate max and min rat0Bitmap for each (normalized_sfn, slot) combination
            group['rat0BitmapMax'] = group.groupby(['normalized_sfn', 'slot'])['dlFdSchedData.rat0Bitmap'].transform(
                'max')
            group['rat0BitmapMin'] = group.groupby(['normalized_sfn', 'slot'])['dlFdSchedData.rat0Bitmap'].transform(
                'min')

            # Filter for rows where rat0BitmapMax > 0 and rat0BitmapMin == 0
            group = group[(group['rat0BitmapMax'] > 0) & (group['rat0BitmapMin'] == 0)]

            if group.empty:
                rbi.log(f'No RAT0/RAT1 pairs in 1 slot detected on cell: {lcrId}')
                return pd.DataFrame({'lcrId': [None]})  # Return empty DataFrame for no pairing
            else:
                rbi.log(f'Dynamic RAT0/RAT1 switch detected on cell: {lcrId}')
                return group

    # Group by lcrId and apply filtering and aggregation
    df_RAT0_RAT1_pairs = df.groupby('lcrId').apply(
        lambda group: _process_lcrId_group(group, actDlDynSwitchAlloc_NRCELL)).reset_index(drop=True)

    # Filter for cells with no pairing
    no_RAT0RAT1_pairing_slots = df_RAT0_RAT1_pairs[df_RAT0_RAT1_pairs['lcrId'].isnull()].lcrId.tolist()

    # Report results
    if not df_RAT0_RAT1_pairs.empty:
        rbi.log('RAT0/RAT1 pairing slots detected, check DynamicSwitchingSlots.csv')
        df_RAT0_RAT1_pairs.to_csv(str("%s/RAT0_RAT1_pairs.csv" % get_directory(path_to_pickle)), index=False)

    if no_RAT0RAT1_pairing_slots:
        rbi.log('No RAT0/RAT1 pairs in 1 slot detected on cell: {}'.format(no_RAT0RAT1_pairing_slots))

    cleanup([df, df_RAT0_RAT1_pairs])


@python_log
def Verify_RAT0_RAT1_dynamic_switch(path_to_pickle, actDlDynSwitchAlloc_NRCELL):
    """This function verifies if dynamic RAT0/RAT1 switch is happening on cell level

    Suggested pkl file: pkl file with event dlFdSchedData present

    :param path_to_pickle: Path of input pickle file
    :param actDlDynSwitchAlloc_NRCELL: scf feature activation flag array
    """
    df = pd.read_pickle(path_to_pickle)
    df = df[['lcrId', 'dlFdSchedData.rat0Bitmap']].dropna(subset=['dlFdSchedData.rat0Bitmap'])

    # Check if there are any RAT0 or RAT1 entries
    has_RAT0 = (df['dlFdSchedData.rat0Bitmap'] > 0).any()
    has_RAT1 = (df['dlFdSchedData.rat0Bitmap'] == 0).any()

    if not has_RAT0 and not has_RAT1:
        rbi.fail('No RAT0/RAT1 dynamic switch detected')

    no_RAT0RAT1_switching_cells = []

    # Group by 'lcrId' and process each group
    for lcrId, df_lcrId in df.groupby('lcrId'):
        if actDlDynSwitchAlloc_NRCELL[int(lcrId) - 1] == 'false':
            rbi.log(f"Dynamic RAT0/RAT1 switch not enabled on cell {lcrId}")
            continue

        # Check for RAT0 and RAT1 entries within the group
        has_RAT0 = (df_lcrId['dlFdSchedData.rat0Bitmap'] > 0).any()
        has_RAT1 = (df_lcrId['dlFdSchedData.rat0Bitmap'] == 0).any()

        if not has_RAT0 and not has_RAT1:
            rbi.log(f'No RAT0/RAT1 dynamic switch detected on cell: {lcrId}')
            no_RAT0RAT1_switching_cells.append(lcrId)
        else:
            rbi.log(f'Dynamic RAT0/RAT1 switch detected on cell: {lcrId}')

    if no_RAT0RAT1_switching_cells:
        cleanup([df, df_lcrId])
        rbi.fail(f'No RAT0/RAT1 dynamic switch detected on cell: {no_RAT0RAT1_switching_cells}')


def Verify_if_only_RAT1_bitmap_is_present(path_to_pickle, actRat1Alloc_NRCELL):
    """This function verifies if only RAT1 bitmap is present in tti event dlFdSchedData.rat0Bitmap
    (dlFdSchedData.rat0Bitmap = 0)
    Important: RAT1 bitmap only is visible, if at the same time scf parameters actRat1Alloc = true and
    actDlDynSwitchAlloc = false

        Suggested pkl file: pkl file with event dlFdSchedData present

        :param path_to_pickle: Path of input pickle file
        :param actRat1Alloc_NRCELL: scf feature activation flag array
    """

    df = pd.read_pickle(path_to_pickle)
    df = df[['lcrId', 'dlFdSchedData.rat0Bitmap']].dropna(subset=['dlFdSchedData.rat0Bitmap'])

    if (df['dlFdSchedData.rat0Bitmap'] != 0).any():
        rbi.fail('Not only RAT1 bitmap detected')

    no_RAT1_only_cells = []

    for lcrId, df_lcrId in df.groupby('lcrId'):
        if actRat1Alloc_NRCELL[int(lcrId) - 1] == 'false':
            rbi.log(f"No RAT0 allocation enabled on cell {lcrId}")
            continue

        if (df_lcrId['dlFdSchedData.rat0Bitmap'] != 0).any():
            rbi.log(f'Not only RAT1 bitmap detected on cell: {lcrId}')
            no_RAT1_only_cells.append(lcrId)

    if no_RAT1_only_cells:
        cleanup([df, df_lcrId])
        rbi.fail(f'Not RAT1 bitmap only detected on cell: {no_RAT1_only_cells}, '
                 f'for only RAT1 enabling dlFdSchedData.rat0Bitmap should be zero')


def verify_dlAllocatedPooledResourcesDataNumAllocCellPrbDl_sfn_scheduling_interval_based_on_bbPoolEvalPeriod(
        path_to_pickle, cellTechnology_NRCELL):
    """This function checks, if tti event 'dlAllocatedPooledResourcesDataNumAllocCellPrbDl' is scheduled in sfn
    periodicity according to, what is defined in RnD vendor file for bbPoolEvalPeriod

        Suggested pkl file: pkl file with event dlAllocatedPooledResourcesData present

        :param path_to_pickle: Path of input pickle file
        :param cellTechnology_NRCELL: scf parameter for cellTechnology
    """
    df = pd.read_pickle(path_to_pickle)

    # Select relevant columns
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'emCoreId',
        'dlAllocatedPooledResourcesData.numAllocCellPrbDl', 'dlFdSchedData.numOfPrb'
    ]]

    # Get the rows when traffic will start and end
    df_dlfdsched = df.dropna(subset=['dlFdSchedData.numOfPrb'])
    startime_traffic = df_dlfdsched['timeStamp'].min()
    endtime_traffic = df_dlfdsched['timeStamp'].max()

    rbi.log(f'startime_traffic: {startime_traffic}, endtime_traffic: {endtime_traffic}')

    # Filter DataFrame for traffic period and drop rows with missing data
    df = df[(df['timeStamp'] >= startime_traffic) & (df['timeStamp'] <= endtime_traffic)]
    df = df.dropna(subset=['dlAllocatedPooledResourcesData.numAllocCellPrbDl'])

    # Calculate SFN difference and identify gaps
    df['sfn_diff'] = df.groupby('lcrId')['sfn'].diff()
    df['bbPoolEvalPeriod'] = df['lcrId'].apply(lambda lcrId: 5 if cellTechnology_NRCELL[int(lcrId) - 1] == 'TDD' else 4)
    df_sfn_gaps = df[df['sfn_diff'] > df['bbPoolEvalPeriod']]

    # Check for gaps and report results
    if not df_sfn_gaps.empty:
        display_df_as_html(df_sfn_gaps)
        df_sfn_gaps.to_csv(str("%s/GapSlotsForNumAllocCellPrbDl.csv" % get_directory(path_to_pickle)))
        cleanup([df, df_sfn_gaps, df_dlfdsched])
        rbi.fail('dlAllocatedPooledResourcesData.numAllocCellPrbDl scheduled in sfn > bbPoolEvalPeriod '
                 '(TDD: bbPoolEvalPeriod = 5, FDD: bbPoolEvalPeriod = 4) detected in some rows, check '
                 'GapSlotsForNumAllocCellPrbDl.csv')


@python_log
def verify_MuMimo_pairing(path_to_pickle):
    """This function checks, if MuMimo is working

        Suggested pkl file: pkl file with event dlFdSchedData present

        :param path_to_pickle: Path of input pickle file
    """

    df = pd.read_pickle(path_to_pickle)

    # Select relevant columns
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.numOfPrb',
        'dlFdSchedData.numPrbForPowerBoost', 'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.txNumber',
        'dlFdSchedData.muStatus', 'dlFdSchedAdditionalData.streamConfig.streamIndex1',
        'dlFdSchedAdditionalData.streamConfig.streamIndex2'
    ]]

    # Drop rows with missing data
    df = df.dropna(subset=['dlFdSchedData.numOfVoNrPrb'])

    # Filter for VoNR traffic
    df_VoNR = df[(df['dlFdSchedData.numOfVoNrPrb'] > 0) & (df['dlFdSchedData.muStatus'] != 'NOMUELIGIBLE_NOTNONGBR')]
    if not df_VoNR.empty:
        display_df_as_html(df_VoNR)
        df_VoNR.to_csv(str("%s/VoiceUEsPaired.csv" % get_directory(path_to_pickle)), index=False)
        cleanup([df, df_VoNR])
        rbi.fail('Wrong Mu status for voice bearer, check VoiceUEsPaired.csv')

    # Calculate Mu pairing statistics
    counted_df = (df.groupby(['lcrId', 'dlFdSchedData.muStatus'])
                  .size()
                  .reset_index(name='Count')
                  .set_index(['lcrId', 'dlFdSchedData.muStatus'])
                  .assign(Percentage=lambda x: (x['Count']) * 100 / (x.groupby(['lcrId'])['Count'].transform('sum')))
                  )
    display_df_as_html(counted_df)

    # Check for cells with insufficient Mu pairing
    Mu_pair_threshold = 0.25
    no_paired_UE_cells = []
    for lcrId, df_lcrId in df.groupby('lcrId'):
        df_non_VoNR_pairing = df_lcrId[(df_lcrId['dlFdSchedData.numOfVoNrPrb'] == 0) &
                                       (df_lcrId['dlFdSchedData.muStatus'] == 'MUPAIR')]
        Mu_paired_percentage = len(df_non_VoNR_pairing) / len(df_lcrId)
        if Mu_paired_percentage < Mu_pair_threshold:
            no_paired_UE_cells.append(lcrId)
            rbi.log(f"No pairing or not enough UE's are paired (dlFdSchedData.muStatus == 'MUPAIR'), number of paired "
                    f"UE's are {Mu_paired_percentage * 100:.2f}%, but threshold for paired UE's, which should be "
                    f"reached is {Mu_pair_threshold * 100}%, for cell: {lcrId}", 'ERROR')

    if no_paired_UE_cells:
        cleanup([df, df_VoNR, df_lcrId, df_non_VoNR_pairing, counted_df])
        rbi.fail(f"No pairing or not enough UE's are paired (dlFdSchedData.muStatus == 'MUPAIR'), min. number of paired"
                 f"UE's threshold: {Mu_pair_threshold * 100}%,  for cell: {no_paired_UE_cells}")


def get_key_tti_events(path_to_pickle):
    df = pd.read_pickle(path_to_pickle)
    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.mcsTable',
        'dlFdSchedData.numOfLayers', 'dlFdSchedData.SLIV', 'dlFdSchedData.tbSize',
        'dlFdSchedData.rrmDlUsedMcs', 'dlFdSchedData.dciFormat', 'dlFdSchedData.startPrb',
        'dlFdSchedData.numOfPrb', 'dlFdSchedData.numPrbForPowerBoost',
        'dlFdSchedData.numOfVoNrPrb', 'dlFdSchedData.numOfNonVoNRGbrPrb', 'dlFdSchedData.ackNack',
        'dlFdSchedData.dlHarqProcessIndex', 'dlFdSchedData.suPdschTbTransmitPower', 'dlFdSchedData.txNumber',
        'dlFdSchedData.redundancyVersion', 'dlFdSchedData.PRBCandRetx', 'dlFdSchedData.PRBMinRetx',
        'dlFdSchedData.PRBMaxCodeRateRetx', 'dlFdSchedData.adaptRetxStatus', 'dlFdSchedData.effectiveCodeRate',
        'dlFdSchedData.cellBwpId', 'dlFdSchedData.ueBwpId', 'dlFdSchedData.rat0Bitmap'

    ]]

    df = df.dropna(subset=['dlFdSchedData.txNumber'])

    # Convert to binary, for debugging purposes, the '1' in the rat0Bitmap_binaray should be distributed
    df['rat0Bitmap_binary'] = df['dlFdSchedData.rat0Bitmap'].apply(lambda x: format(int(x), '020b'))

    df_key_tti_events = df.copy(deep=True)
    df_key_tti_events.columns = [
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId',
        'mcsTable', 'numOfLayers', 'SLIV', 'tbSize',
        'rrmDlUsedMcs', 'dciFormat',
        'startPrb', 'numOfPrb', 'numPrbForPowerBoost', 'numOfVoNrPrb', 'numOfNonVoNRGbrPrb', 'ackNack',
        'dlHarqProcessIndex', 'suPdschTbTransmitPower', 'txNumber', 'redundancyVersion', 'PRBCandRetx',
        'PRBMinRetx', 'PRBMaxCodeRateRetx', 'adaptRetxStatus', 'effectiveCodeRate',
        'cellBwpId', 'ueBwpId', 'rat0Bitmap', 'rat0Bitmap_binary'

    ]
    if not df_key_tti_events.empty:
        df_key_tti_events.to_csv(str("%s/powerboost_related_tti_events.csv" % get_directory(path_to_pickle)))

    cleanup([df, df_key_tti_events])


@python_log
def cleanup(list):
    "Function to delete not anymore used dataframes and clean up memory, we need 2 delete commands to releas memory"
    for item in list:
        del item
    del list


@python_log
def verify_bbpoolingwindow(path_to_pickle):
    """This function checks if all PRB's in the baseband pooling window are utilized

        Suggested pkl file: pkl file with event dlAllocatedPooledResourcesData present

        :param path_to_pickle: Path of input pickle file
    """
    df = pd.read_pickle(path_to_pickle)

    df = normalize_sfn_values(df)

    df = df[[
        'timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId', 'normalized_sfn',
        'dlAllocatedPooledResourcesData.numAllocCellPrbDl'
    ]]

    df = df.dropna(subset=['dlAllocatedPooledResourcesData.numAllocCellPrbDl'])

    # Remove rows where the normalized_sfn has only 2 rows
    df = df.groupby('normalized_sfn').filter(lambda x: len(x) > 2)

    df['BBPoolCapacityWindow'] = (
        df.groupby('normalized_sfn')['dlAllocatedPooledResourcesData.numAllocCellPrbDl']
        .cumsum()
        .groupby(df['normalized_sfn'])
        .transform('max')
    )

    # 3 FDD cell in 1st SubPool,  interSubPooling OFF   rdAllowInterL1SpPoolingFdd  0x580758=0
    # lcrid1  pci 50  bw 40MHz     216 PRB         120 numAllocCellPrbDl
    # lcrid3  pci 52  bw 40Mhz     216 PRB         120 numAllocCellPrbDl
    # lcrid6  pci 55  bw 20Mhz     106 PRB         106 numAllocCellPrbDl
    #
    # in summary 346 PRBs bbSubPoolcapacity   (4*346=1384 streamPrb)
    #
    # From syslog
    # AddressDistributionUtils.cpp:280 Bbrm conf: bbPoolInfo present l1DlSubPoolList: [{"l1SubPoolId":0,
    # "slowPrbPoolingParameters":{"l1SpMaxNumStreamPrb":1384,"l1SpMaxNumLayerPrb":1384,"l1SpMaxNumStreamPrbWb":864,
    # "maxNumSubcellL1Sp":255}},{"l1SubPoolId":1,"slowPrbPoolingParameters":{"l1SpMaxNumStreamPrb":1384,
    # "l1SpMaxNumLayerPrb":1384,"l1SpMaxNumStreamPrbWb":864,"maxNumSubcellL1Sp":255}}]

    vendor_bbcapacity = 346  # Can be extracted, see above lines
    df = df[df['BBPoolCapacityWindow'] < vendor_bbcapacity]

    if not df.empty:
        df.to_csv(str("%s/BBPoolCapacityWindow.csv" % get_directory(path_to_pickle)))
        logging.warning(
            f'dlAllocatedPooledResourcesData.numAllocCellPrbDl window is below vendor bbcapacity of '
            f'{vendor_bbcapacity} PRBs, please check file BBPoolCapacityWindow.csv. '
            f'This issue is known and investigated in PR873132, CuDo is updated accordingly.'
        )
