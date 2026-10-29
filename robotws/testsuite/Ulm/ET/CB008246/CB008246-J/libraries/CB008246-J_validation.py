# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd66 for CB008246-J Feature
# Team: 'SqdGp66'
# Email: 'I_MN_RAN_L2_SW_ULM_SQD_66@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import glob
import operator
import os

# ET or Feature Specific Libraries:
import numpy as np
import pandas as pd

from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html
from testsuite.Ulm.ET.resources.SQD68.pmc_analysis import (verify_pm_counters,
                                                           prepare_for_pm_counter_testing,
                                                           finalise_pm_counter_testing)
from testsuite.Ulm.ET.CB008246.libraries.ttitrace_analysis import (visualization,
                                                                   plot_df_with_scatter,
                                                                   get_directory)
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name

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
def check_bearer_addition_and_deletion_with_laMode_switching(path_to_pickle, direction,
                                                             isDftsOfdm_B22_scenario=False):
    """ This function checks the (dl/ul)LaSwitchBetweenHrAndBr event when 256QAM in enabled.
        Once first HR DRB is added, then BR->HR switch will be checked. Similarly when last HR DRB
        is removed, then HR->BR switch will be checked.

        :param path_to_pickle: Path of input pickle file
        :param direction: ul/dl
    """
    visualization()
    df = pd.read_pickle(path_to_pickle)
    prefix_dir = 'd' if direction == 'dl' else 'u'

    la_mode_event = '{}LaSwitchBetweenHrAndBr.laMode'.format(direction)
    la_switch_event = '{}LaSwitchBetweenHrAndBr.event'.format(direction)
    pxsch_ratio_event = '{}LaSwitchBetweenHrAndBr.p{}schMetric.ratio'.format(
        direction, prefix_dir)
    pdcch_ratio_event = '{}LaSwitchBetweenHrAndBr.pdcchMetric.ratio'.format(
        direction)

    df = df[['timeStamp', 'rnti', 'sfn', 'slot', la_switch_event,
             la_mode_event, pxsch_ratio_event, pdcch_ratio_event]].dropna(subset=[la_switch_event])

    for rnti, df_group in df.groupby('rnti'):
        rbi.log("Printing all {}LaSwitchBetweenHrAndBr.event for rnti {}".format(
            direction, rnti), 'INFO')
        display_df_as_html(df_group)

        if (isDftsOfdm_B22_scenario and direction == "ul"):
            check_HR_DRB_addition(df_group, la_switch_event, '{}FIRSTHRDRBSETUP'.format(direction.upper()),
                                  la_mode_event, 'BASICRELIABILITY', rnti, isDftsOfdm_B22_scenario)
        else:
            check_HR_DRB_addition(df_group, la_switch_event, '{}MCSTABLERECONFAFTERFIRSTHRDRBSETUP'.format(
                direction.upper()), la_mode_event, 'HIGHRELIABILITY', rnti, isDftsOfdm_B22_scenario)

        rbi.log(
            "<p style='color:DodgerBlue;'><b>Step 2: HR DRB deletion </b></p>", 'HTML')
        hr_to_br_switch_df = df[df[la_switch_event] ==
                                '{}LASTHRDRBRELEASED'.format(direction.upper())]

        if len(hr_to_br_switch_df) == 0:
            rbi.fail(
                "No HR DRB deletion detected for rnti {}.".format(rnti), 'ERROR')
        else:
            rbi.log(
                "HR DRB deletion detected for rnti {}. Switch to BR should happen!!\
                Checking TTI trace for BASICRELIABILITY".format(rnti))
            if (hr_to_br_switch_df[la_mode_event].iloc[0] == 'BASICRELIABILITY'):
                rbi.log(
                    "Switch from HR to BR occurred on HR DRB deletion for rnti {}!".format(rnti))
            else:
                rbi.fail(
                    "Switch from HR to BR did not occurr on HR DRB deletion for rnti {}!".format(rnti), 'ERROR')


@log_begin_end_func_name
def check_HR_DRB_addition(df_group, la_switch_event, la_switch_event_value, la_mode_event, la_mode_event_value, rnti,
                          isDftsOfdm_B22_scenario):
    rbi.log("<p style='color:DodgerBlue;'><b>Step 1: HR DRB addition </b></p>", 'HTML')
    hr_drb_addition_df = df_group[df_group[la_switch_event]
                                  == la_switch_event_value]

    if len(hr_drb_addition_df) == 0:
        rbi.fail(
            "No HR DRB addition with event {} detected for rnti {}.".format(la_switch_event_value, rnti), 'ERROR')
    else:
        rbi.log(
            "HR DRB addition detected for rnti {}. \
                Checking laMode {} corresponding to event {}. isDftsOfdm_B22_scenario: {}".format(
                rnti, la_mode_event_value, la_switch_event_value, isDftsOfdm_B22_scenario))
        if (hr_drb_addition_df[la_mode_event].iloc[0] == la_mode_event_value):
            rbi.log(
                "HR DRB addition with correct laMode is detected for rnti {}. TC PASS!".format(rnti))
        else:
            rbi.fail(
                "HR DRB addition with correct laMode is not detected for rnti {}. TC FAIL!!".format(rnti), 'ERROR')


@log_begin_end_func_name
def check_mcsTable_laMode_and_DftsOfdm_switching_in_different_phases(path_to_pickle,
                                                                     direction,
                                                                     outage_threshold=50,
                                                                     recover_threshold=60,
                                                                     isDftsOfdm_B21_scenario=False,
                                                                     isDftsOfdm_B22_scenario=False):
    visualization()
    mcsTable_event = '{}FdSchedData.mcsTable'.format(direction)
    dciFormat_event = '{}FdSchedData.dciFormat'.format(direction)
    laMode_event = '{}FdSchedData.laMode'.format(direction)
    laswitch_event = '{}LaSwitchBetweenHrAndBr.event'.format(direction)
    prefix_dir = 'd' if direction == 'dl' else 'u'
    pxschMetric_ratio_event = '{}LaSwitchBetweenHrAndBr.p{}schMetric.ratio'.format(
        direction, prefix_dir)
    pdcch_ratio_event = '{}LaSwitchBetweenHrAndBr.pdcchMetric.ratio'.format(
        direction)
    puschTPstate_event = 'ulFdSchedData.puschTPstate'
    tpHystCounter_event = 'ulFdSchedData.tpHystCounter'

    df = pd.read_pickle(path_to_pickle)
    if (direction == "ul"):
        df = df[['timeStamp', 'rnti', 'sfn', 'slot', mcsTable_event, laMode_event, dciFormat_event,
                 puschTPstate_event, tpHystCounter_event, laswitch_event, pxschMetric_ratio_event, pdcch_ratio_event]]
    else:
        df = df[['timeStamp', 'rnti', 'sfn', 'slot', mcsTable_event, laMode_event, dciFormat_event,
                 laswitch_event, pxschMetric_ratio_event, pdcch_ratio_event]]

    verdict = True
    for rnti, df_group in df.groupby('rnti'):
        if (isDftsOfdm_B22_scenario and direction == "ul"):
            start_index, end_index = check_mcsTable_for_B22_scenario(
                rnti, direction, df_group, laswitch_event, mcsTable_event, laMode_event, puschTPstate_event,
                tpHystCounter_event, pxschMetric_ratio_event, recover_threshold)
        else:
            start_index, end_index = check_mcsTable_during_fallback_from_HR_to_BR(
                rnti, direction, df_group, laswitch_event, mcsTable_event, puschTPstate_event,
                tpHystCounter_event, pxschMetric_ratio_event, pdcch_ratio_event, outage_threshold,
                recover_threshold, isDftsOfdm_B21_scenario)

        if start_index != 0 and end_index != 0:
            rbi.log("Previous number of rows: {}".format(len(df_group)))
            df_group = df_group.drop(
                range(start_index, end_index+1), errors='ignore')
            rbi.log(
                "Dropping rows between start_index and end_index.")
            rbi.log("Updated number of rows: {}".format(len(df_group)))

        br_filtered_df,  hr_filtered_df =\
            get_hr_and_br_filtered_df(df_group.dropna(
                subset=[mcsTable_event]), direction, rnti)

        rbi.log("Updated number of rows: {}".format(len(br_filtered_df)))
        if (len(br_filtered_df) == 0 or len(hr_filtered_df) == 0):
            verdict = False
            continue

        # Data Frame for BR
        check_mcsTable_in_br_mode_with_no_hr_drb(
            br_filtered_df, mcsTable_event, rnti)

        # Data Frame for HR
        check_mcsTable_in_hr_mode(hr_filtered_df, mcsTable_event, rnti)
        if (direction == "ul"):
            check_tpHyst_counter_with_zero(
                hr_filtered_df, tpHystCounter_event, rnti)

    if (not verdict):
        rbi.fail(
            "There is an error with FORCE dciFormat", 'ERROR')


@log_begin_end_func_name
def check_mcsTable_in_br_mode_with_no_hr_drb(br_filtered_df, mcsTable_event, rnti):
    qam256_df_counts = pd.concat([br_filtered_df[mcsTable_event].value_counts(),
                                  br_filtered_df[mcsTable_event].value_counts(
        normalize=True)
        .mul(100).round(1).astype(str)], axis=1, keys=('count', 'percentage (%)'))
    rbi.log("qam256_df_counts in laMode BR:")
    display_df_as_html(qam256_df_counts)

    # The DataFrame for BR can have all different laMode Values.'QAM256','QAM64LOWSE','NA'. In this dataframe
    # only QAM256 is expected, so adding all the counts for  different values and a threshold of 3 is allowed so
    # 2 is subtracted from the value and QAM256 is checked for the remaining values inside the dataframe.
    total_number_of_entries = qam256_df_counts['count'].sum()
    rbi.log("Total number of entries in the dataframe: {}".format(
        total_number_of_entries))
    # Check if the dataframe has only QAM256 Value after subtracting the threshold allowed.
    # Here the threshold allowed is fixed to 3
    if int(qam256_df_counts.loc['QAM256', 'count']) >= (total_number_of_entries - 3):
        rbi.log(
            "Values in BR mode reached the threshold allowed in QAM256 mcsTable for rnti  {}.".format(rnti))
    else:
        display_df_as_html(
            br_filtered_df[br_filtered_df[mcsTable_event] != 'QAM256'].head(50))
        rbi.fail("Values in BR mode did not reach the threshold allowed in QAM256 mcsTable for rnti {}.".format(
            rnti), 'ERROR')


@log_begin_end_func_name
def check_mcsTable_in_hr_mode(hr_filtered_df, mcsTable_event, rnti):
    qam64lowse_df_counts = pd.concat([hr_filtered_df[mcsTable_event].value_counts(),
                                      hr_filtered_df[mcsTable_event].value_counts(
        normalize=True)
        .mul(100).round(1).astype(str)], axis=1, keys=('count', 'percentage (%)'))

    rbi.log("qam64lowse_df_counts in laMode HR:")
    display_df_as_html(qam64lowse_df_counts)

    all_values_in_hr_are_equal_to_QAM64LOWSE = (
        hr_filtered_df[mcsTable_event] == 'QAM64LOWSE').all()
    if all_values_in_hr_are_equal_to_QAM64LOWSE:
        rbi.log(
            "All values in HR mode are equal to QAM64LOWSE mcsTable for rnti {}.".format(rnti))
    else:
        rbi.fail(
            "Not All values in HR mode are equal to QAM64LOWSE mcsTable for rnti {}".format(rnti), 'ERROR')


@log_begin_end_func_name
def check_tpHyst_counter_with_zero(df, tpHystCounter_event, rnti):
    are_all_values_equal_to_zero_for_tpHyst_counter = (
        df[tpHystCounter_event] == 0).all()
    if are_all_values_equal_to_zero_for_tpHyst_counter:
        rbi.log(
            "All values for tpHystCounter are equal to zero for rnti {}.".format(rnti))
    else:
        rbi.fail(
            "Not All values for tpHystCounter are equal to zero for rnti {}".format(rnti), 'ERROR')


@log_begin_end_func_name
def check_tpHyst_counter_with_non_zero(df, tpHystCounter_event, rnti):
    are_all_values_less_than_100 = (df[tpHystCounter_event] < 100).all()
    if not are_all_values_less_than_100:
        rbi.fail(
            "Not All values for tpHystCounter are less than 100 for rnti {}".format(rnti), 'ERROR')

    df_with_tpHystCounter_between_1_and_99 = df[(
        df[tpHystCounter_event] >= 1) & (df[tpHystCounter_event] <= 99)]
    if df_with_tpHystCounter_between_1_and_99.empty:
        rbi.fail(
            "No value of tpHystCounter found between 1 to 99 for rnti {}".format(rnti), 'ERROR')


@log_begin_end_func_name
def check_mcsTable_during_fallback_from_HR_to_BR(
        rnti, direction, df, laswitch_event, mcsTable_event, puschTPstate_event, tpHystCounter_event,
        pxschMetric_ratio_event, pdcch_ratio_event, outage_threshold, recover_threshold, isDftsOfdm_B21_scenario):
    """
    This function checks the value of mcstable for Basic Reliability in Lamode,when the outage period
    timer event is executed in fall back from HR to BR. The function is finds both event
    for all rnti and creates a df only for downlink. The dataframe is checked for BR in DL for QAM64LOWSE.
    The event occured only when the ratio of pdschMtric value is greater than equal to 50.
    """
    rbi.log("Analysing RNTI {}".format(rnti))
    outage_df = df[(df[laswitch_event] == '{}HRBLEROUTAGEPERIODTIMER'.format(direction.upper())) |
                   (df[laswitch_event] == '{}PDCCHHRBLEROUTAGEPERIODTIMER'.format(direction.upper()))]
    outage_df = outage_df[(outage_df[pxschMetric_ratio_event] >= int(outage_threshold)) |
                          (outage_df[pdcch_ratio_event] >= int(outage_threshold))]
    recover_df = df[df[laswitch_event] ==
                    '{}HRBLERRECOVERPERIODTIMER'.format(direction.upper())]
    recover_df = recover_df[recover_df[pxschMetric_ratio_event] >= int(
        recover_threshold)]

    rbi.log("outage_df:")
    display_df_as_html(outage_df)
    rbi.log("recover_df:")
    display_df_as_html(recover_df)

    if len(outage_df) == 0:
        rbi.log("No Fallback Event occured for rnti {}".format(rnti))
        display_df_as_html(df.dropna(subset=[laswitch_event]))
        return 0, 0

    if len(recover_df) == 0:
        rbi.log("No Recover Event occured for rnti {}".format(rnti))
        display_df_as_html(df.dropna(subset=[laswitch_event]))
        return 0, 0

    # get the indices for further data processing
    start_index = outage_df.index[0]
    end_index = recover_df.last_valid_index()
    rbi.log("Start index: {}  End Index: {}".format(start_index, end_index))

    df_between_outage_and_recover_events = df.loc[start_index:end_index].dropna(
        subset=[mcsTable_event])
    rbi.log("df_between_outage_and_recover_events:")
    display_df_as_html(df_between_outage_and_recover_events.head(10))

    if (isDftsOfdm_B21_scenario and direction == "ul"):
        validate_mcsTables_between_outage_and_recover_events_in_DftsOfdm_scenario(
            df_between_outage_and_recover_events, puschTPstate_event, mcsTable_event, rnti)
        check_tpHyst_counter_with_non_zero(
            df_between_outage_and_recover_events, tpHystCounter_event, rnti)
    else:
        validate_mcsTables_between_outage_and_recover_events_in_256QAM_only_scenario(
            df_between_outage_and_recover_events, mcsTable_event, start_index, end_index)

    return start_index, end_index


@log_begin_end_func_name
def check_mcsTable_for_B22_scenario(
        rnti, direction, df, laswitch_event, mcsTable_event, laMode_event, puschTPstate_event,
        tpHystCounter_event, pxschMetric_ratio_event, recover_threshold):
    """
        This function checks the value of mcstable according to B22 scenario
    """

    rbi.log("Analysing RNTI {} with B22 scenario".format(rnti))
    df_with_TP_enabled = df[df[puschTPstate_event] == 'TRANSIENTPHASEOFF2ON']
    df_with_TP_disabled = df[df[puschTPstate_event] == 'TRANSIENTPHASEON2OFF']

    recover_df = df[df[laswitch_event] ==
                    '{}HRBLERRECOVERPERIODTIMER'.format(direction.upper())]
    recover_df = recover_df[recover_df[pxschMetric_ratio_event] >= int(
        recover_threshold)]

    rbi.log("df_with_TP_enabled:")
    display_df_as_html(df_with_TP_enabled)
    rbi.log("df_with_TP_disabled:")
    display_df_as_html(df_with_TP_disabled)
    rbi.log("recover_df:")
    display_df_as_html(recover_df)

    if len(df_with_TP_enabled) == 0:
        rbi.fail("puschTPState has no TRANSIENTPHASEOFF2ON in DFTsOFDM B22 scenario for rnti {}.".format(
            rnti), 'ERROR')

    if len(df[df[puschTPstate_event] == 'ENABLED']) == 0:
        rbi.fail("puschTPState is not equal to ENABLED in DFTsOFDM B22 scenario for rnti {}.".format(
            rnti), 'ERROR')

    if len(df_with_TP_disabled) == 0:
        rbi.fail("puschTPState has no TRANSIENTPHASEON2OFF in DFTsOFDM B22 scenario for rnti {}.".format(
            rnti), 'ERROR')

    if len(recover_df) == 0:
        rbi.fail("No Recover Event occured in DFTsOFDM B22 scenario for rnti {}".format(
            rnti), 'ERROR')

    # get the indices for further data processing
    start_index = df_with_TP_enabled.index[0]
    TP_disable_index = df_with_TP_disabled.last_valid_index()
    end_index = recover_df.last_valid_index()
    rbi.log("Start index: {}  TP_disable_index: {}  End Index: {}".format(
        start_index, TP_disable_index, end_index))

    df_between_tp_enabed_and_recover_events = df.loc[start_index:end_index].dropna(
        subset=[laMode_event])
    are_all_values_between_tp_enabed_and_recover_events_equal_to_BR_laMode = (
        df_between_tp_enabed_and_recover_events[laMode_event] == 'BASICRELIABILITY').all()

    if are_all_values_between_tp_enabed_and_recover_events_equal_to_BR_laMode:
        rbi.log(
            "All values between TP enabed and recover events are equal to BR laMode for rnti {}.".format(rnti))
    else:
        display_df_as_html(
            df_between_tp_enabed_and_recover_events.head(10))
        rbi.fail(
            "Not All values between TP enabed and recover events are equal to BR laMode for rnti {}".format(
                rnti),
            'ERROR')

    df_between_tp_enabed_and_tp_disabled_events = df.loc[start_index:TP_disable_index].dropna(
        subset=[mcsTable_event])
    are_all_values_between_tp_enabed_and_tp_disabled_events_equal_to_QAM64 = (
        df_between_tp_enabed_and_tp_disabled_events[mcsTable_event] == 'QAM64').all()

    if are_all_values_between_tp_enabed_and_tp_disabled_events_equal_to_QAM64:
        rbi.log(
            "All values between TP enabed and TP disabled events are equal to QAM64 mcsTable for rnti {}."
            .format(rnti))
    else:
        display_df_as_html(df_between_tp_enabed_and_tp_disabled_events)
        rbi.fail(
            "Not All values between TP enabed and TP disabled events are equal to QAM64 mcsTable for rnti {}"
            .format(rnti),
            'ERROR')
    check_tpHyst_counter_with_non_zero(
        df_between_tp_enabed_and_tp_disabled_events, tpHystCounter_event, rnti)

    df_between_tp_disabled_and_recover_events = df.loc[TP_disable_index+1:end_index].dropna(
        subset=[mcsTable_event])
    are_all_values_between_tp_disabled_and_recover_events_equal_to_QAM64LOWSE = (
        df_between_tp_disabled_and_recover_events[mcsTable_event] == 'QAM64LOWSE').all()

    if are_all_values_between_tp_disabled_and_recover_events_equal_to_QAM64LOWSE:
        rbi.log(
            "All values between TP disabled and recover events are equal to QAM64LOWSE mcsTable for rnti {}."
            .format(rnti))
    else:
        display_df_as_html(df_between_tp_disabled_and_recover_events)
        rbi.fail(
            "Not All values between TP disabled and recover events are equal to QAM64LOWSE mcsTable for rnti {}"
            .format(rnti),
            'ERROR')
        check_tpHyst_counter_with_zero(
            df_between_tp_disabled_and_recover_events, tpHystCounter_event, rnti)

    return start_index, end_index


@log_begin_end_func_name
def validate_mcsTables_between_outage_and_recover_events_in_DftsOfdm_scenario(
        df_between_outage_and_recover_events, puschTPstate_event, mcsTable_event, rnti):

    df_between_outage_and_recover_events_and_with_TP_enabled = \
        df_between_outage_and_recover_events[
            df_between_outage_and_recover_events[puschTPstate_event] == 'ENABLED']
    df_between_outage_and_recover_events_and_with_TP_disabled = \
        df_between_outage_and_recover_events[
            df_between_outage_and_recover_events[puschTPstate_event] == 'DISABLED']

    if len(df_between_outage_and_recover_events_and_with_TP_enabled) == 0:
        rbi.fail("puschTPState is not equal to ENABLED in DFTsOFDM scenario.", 'ERROR')

    are_all_values_in_fallback_with_TP_disabled_equal_to_QAM64LOWSE = (
        df_between_outage_and_recover_events_and_with_TP_disabled[mcsTable_event] == 'QAM64LOWSE').all()
    if are_all_values_in_fallback_with_TP_disabled_equal_to_QAM64LOWSE:
        rbi.log(
            "All values in Fallback with TP disabled are equal to QAM64LOWSE mcsTable for rnti {}.".format(rnti))
    else:
        rbi.fail(
            "Not All values in Fallback with TP disabled are equal to QAM64LOWSE mcsTable for rnti {}".format(
                rnti),
            'ERROR')

    are_all_values_in_fallback_with_TP_enabled_equal_to_QAM64 = (
        df_between_outage_and_recover_events_and_with_TP_enabled[mcsTable_event] == 'QAM64').all()
    if are_all_values_in_fallback_with_TP_enabled_equal_to_QAM64:
        rbi.log(
            "All values in Fallback with TP enabled are equal to QAM64 mcsTable for rnti {}.".format(rnti))
    else:
        rbi.fail(
            "Not All values in Fallback with TP enabled are equal to QAM64 mcsTable for rnti {}".format(
                rnti),
            'ERROR')


@log_begin_end_func_name
def validate_mcsTables_between_outage_and_recover_events_in_256QAM_only_scenario(
        df_between_outage_and_recover_events, mcsTable_event, start_index, end_index):
    unique_values = df_between_outage_and_recover_events[mcsTable_event].unique(
    )
    rbi.log("Unique values of xxFdSchedData.mcsTable: {}".format(unique_values))

    if ('QAM64LOWSE' in unique_values):
        rbi.log("The mcsTable  between indices {} and {} is holding the values {} "
                .format(start_index, end_index, unique_values))

    if len(unique_values) != 1:
        rbi.fail("There should only be one mcs table type between indices {} and {}".format(
            start_index, end_index), 'ERROR')


@log_begin_end_func_name
def get_hr_and_br_filtered_df(df_group, direction, rnti):
    laMode_event = '{}FdSchedData.laMode'.format(direction)
    dciFormat_event = '{}FdSchedData.dciFormat'.format(direction)

    br_filtered_df = df_group[(df_group[laMode_event] == 'BASICRELIABILITY')]
    hr_filtered_df = df_group[(df_group[laMode_event] == 'HIGHRELIABILITY')]

    dedicated_dciFormat_event_value = "DL_11" if direction == "dl" else "UL_01"
    force_dciFormat_event_value = "DL_10_FORCE" if direction == "dl" else "UL_00_FORCE"

    # Filter out the rows in the beginning where UE capability is unknown
    first_force_dciFormat_index_df = \
        br_filtered_df[br_filtered_df[dciFormat_event]
                       == force_dciFormat_event_value]
    if (len(first_force_dciFormat_index_df) == 0):
        rbi.log(
            "There is no FORCE dciFormat found in df for rnti {}!".format(rnti), 'ERROR')
        return pd.DataFrame(), pd.DataFrame()

    first_force_dciFormat_index = first_force_dciFormat_index_df.index[0]
    br_filtered_df = br_filtered_df.drop(
        br_filtered_df.index[br_filtered_df.index < first_force_dciFormat_index])

    # Filter out the rows with dedicated dciFormat values
    br_filtered_df = br_filtered_df[(
        br_filtered_df[dciFormat_event] == dedicated_dciFormat_event_value)]
    hr_filtered_df = hr_filtered_df[(
        hr_filtered_df[dciFormat_event] == dedicated_dciFormat_event_value)]
    return br_filtered_df, hr_filtered_df


@log_begin_end_func_name
def plot_graph_tp_switching(path_to_pickle):
    df = pd.read_pickle(path_to_pickle)
    tpState_event = 'ulFdSchedData.puschTPstate'
    tpHystCounter_event = 'ulFdSchedData.tpHystCounter'

    plot_df_with_scatter(df=df, yaxis_column=tpState_event, base_location=get_directory(path_to_pickle),
                         postfix="", xaxis_column="timeStamp", title='tranform_precoder_switching', group_by='rnti',
                         second_yaxis_col=tpHystCounter_event, third_yaxis_col='ulFdSchedData.rrmAvgSinrTpSwitch')
