# ====================================================================================================[120 characters]
# This is a Python file, which helps to implement TTITraces Analysis used in Sub-features
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import os
import warnings
import math
from tabulate import tabulate
import re

# ET or Feature Specific Libraries:
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tools import log_begin_end_func_name, logException
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import (
    display_df_as_html, normalize_sfn_values, display_df_as_table, save_df_as_html)
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import (
    pandas_gate, tti_dataframe)

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]
logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'

rbi = BuiltIn()
pd = None
np = None


# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]
# Important: Keywords' input parameter should be "path_to_pickle" and not "data_frame" if possible


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


# keep to do corr between AL end cqi
@log_begin_end_func_name
def check_correlation_of_mcs_and_pathloss(path_to_pickle):
    """ This function calculates if mcs and pathloss event has a negative correlation value

        Suggested pkl file: pkl file with High reliability filters

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
    global pd
    pd = pandas_gate.install_and_import_pandas()

    df = pd.read_pickle(path_to_pickle)
    # drop fake ue
    df = df[df["rnti"] != 65521]
    visualization()
    counted_df = (df.groupby(['rnti', column_name]).size().reset_index(name='Count').set_index(['rnti', column_name])
                  .assign(Percentage=lambda x: (x['Count']) * 100 / (x.groupby(['rnti'])['Count'].transform('sum'))))

    display_df_as_html(counted_df)
    rbi.log("~" * 20 + " distribution_table_of: " + column_name + "  " + "~" * 20, 'TRACE', console=True)
    display_df_as_table(counted_df)

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
    xlaBlerTarget_br_GUI_value = (xlaBlerTarget_br_internal_value / 100)
    xlaBlerTarget_hr_GUI_value = (xlaBlerTarget_hr_internal_value / 1000)

    df = pd.read_pickle(path_to_pickle)

    if direction == 'ul':
        targetBLER_event = 'ulFdSchedData.targetBLER'
    elif sw_build == 'SBTS00':
        targetBLER_event = 'dlFdSchedAdditionalData.targetBLER'
    else:
        targetBLER_event = 'dlFdSchedData.targetBLER'

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
    # plot_graph_hr_vs_br(path_to_pickle, direction)

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
        It is recommended to use the df generated by verify_distribution_table_of function
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
def get_df_from_pkl(path_to_pickle):
    ul_raState = 'ulPreSchedData.raState'
    ul_callType = 'ulPreSchedData.callType'
    ul_ueAddCause = 'ulPreSchedData.ueAddCause'
    dl_raState = 'dlPreSchedData.raState'
    dl_callType = 'dlPreSchedData.callType'
    dl_ueAddCause = 'dlPreSchedData.ueAddCause'
    preambleType = 'preambleData.preambleType'
    preambleId = 'preambleData.preambleId'
    timeOcc = 'preambleData.timeOcc'
    freqOcc = 'preambleData.freqOcc'
    initialTa = 'preambleData.initialTa'
    peakMetric = 'preambleData.peakMetric'
    ssbIndex = 'preambleData.ssbIndex'
    # -------------------------------------------------------------------------------------------------[120 characters]
    df = pd.read_pickle(path_to_pickle)
    df = df[['rnti', 'lcrId', ul_raState, dl_raState, ul_callType, dl_callType, ul_ueAddCause, dl_ueAddCause,
             preambleType, preambleId, timeOcc, freqOcc, initialTa, peakMetric, ssbIndex]]
    return df


@log_begin_end_func_name
def verify_TTITraces_for_raState(cell='1', num_of_ues='10', ue_type='nsa', procedure_type='attach',
                                 validate=None, need_return=False, debug=False):
    is_raState_present = False
    if not debug:
        path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_rach_pkl}")
    else:
        path_to_ttitrace_pkl = FILE_PKL

    ul_raState = 'ulPreSchedData.raState'
    dl_raState = 'dlPreSchedData.raState'
    ul_callType = 'ulPreSchedData.callType'
    ul_ueAddCause = 'ulPreSchedData.ueAddCause'
    dl_callType = 'dlPreSchedData.callType'
    dl_ueAddCause = 'dlPreSchedData.ueAddCause'
    preambleType = 'preambleData.preambleType'
    preambleId = 'preambleData.preambleId'
    timeOcc = 'preambleData.timeOcc'
    freqOcc = 'preambleData.freqOcc'
    initialTa = 'preambleData.initialTa'
    peakMetric = 'preambleData.peakMetric'
    ssbIndex = 'preambleData.ssbIndex'
    rach_nsa_attach = ("CBRA-" +
                       "SCHEDULE_MSG2-CT_NONE-INITIALACCESS-" +
                       "AWAIT_MSG3-CT_NONE-INITIALACCESS-" +
                       "SCHEDULE_MSG3_NEW_TX-CT_NONE-INITIALACCESS-" +
                       "MSG3_SCHEDULED-CT_NONE-INITIALACCESS-" +
                       "AWAIT_SCHEDULE_CONTRES_TIMER_EXPIRY-CT_NSAINITIALACCESS-SGNBADDITION-" +
                       "AWAIT_PUSCH_ACK_NACK_FOR_CONT_RES-CT_NSAINITIALACCESS-SGNBADDITION")
    rach_sa_attach = (r"CBRA-" +
                      "SCHEDULE_MSG2-CT_NONE-INITIALACCESS-" +
                      "AWAIT_MSG3-CT_NONE-INITIALACCESS-" +
                      "SCHEDULE_MSG3_NEW_TX-CT_NONE-INITIALACCESS-" +
                      "MSG3_SCHEDULED-CT_NONE-INITIALACCESS-" +
                      "SCHEDULE_MSG4_WITH_DL_CCCH_DATA-CT_SAINITIALACCESS-INITIALACCESS-" +
                      "AWAIT_MSG4_WITH_DL_CCCH_DATA_ACK-CT_SAINITIALACCESS-INITIALACCESS-" +
                      ".*?MSG5-CT_SAINITIALACCESS-INITIALACCESS-" +  # <--- there is .*? !!!
                      "MSG5_SCHEDULED-CT_SAINITIALACCESS-INITIALACCESS")
    rach_sa_reest = (r"CBRA-" +
                     "SCHEDULE_MSG2-CT_NONE-INITIALACCESS-" +
                     "AWAIT_MSG3-CT_NONE-INITIALACCESS-" +
                     "SCHEDULE_MSG3_NEW_TX-CT_NONE-INITIALACCESS-" +
                     "MSG3_SCHEDULED-CT_NONE-INITIALACCESS-" +
                     "SCHEDULE_MSG4_WITHOUT_DL_CCCH_DATA-CT_SAINITIALACCESS-RRCREESTABLISHMENT-" +
                     "AWAIT_.*?DL_CCCH_DATA_ACK-CT_SAINITIALACCESS-RRCREESTABLISHMENT-" +  # <--- there is .*? !!!
                     "SCHEDULE_MSG5-CT_SAINITIALACCESS-RRCREESTABLISHMENT-" +
                     "MSG5_SCHEDULED-CT_SAINITIALACCESS-RRCREESTABLISHMENT")
    try:
        df = get_df_from_pkl(path_to_ttitrace_pkl)

        # Filter on given Cell only:
        df_filtered = df.loc[df['lcrId'] == int(cell)].copy()
        logging.info("df_filtered = \n%s" % (df_filtered))

        # Remove 'none' in both places:
        df_filtered =\
            df_filtered.dropna(
                subset=[ul_raState, dl_raState, preambleType,
                        preambleId, timeOcc, freqOcc, initialTa, peakMetric, ssbIndex],
                how='all').copy()
        logging.info("df_filtered = \n%s" % (df_filtered))

        # Remove 'ATTACHED' in any places:
        df_filtered = df_filtered[~((df_filtered[ul_raState] == 'ATTACHED') |
                                    (df_filtered[dl_raState] == 'ATTACHED'))]
        logging.info("df_filtered = \n%s" % (df_filtered))

        df_display = df_filtered[['rnti', 'lcrId', ul_raState, dl_raState, ul_callType, dl_callType, ul_ueAddCause,
                                  dl_ueAddCause, preambleType]]

        # Get the column names as a list
        headers = df_filtered.columns.tolist()
        # Create a dictionary to map old names to new names
        rename_dict = {}
        for header in headers:
            if "ulPreSchedData" in header:
                rename_dict[header] = header.replace("ulPreSchedData", "ul")  # Replace with your desired prefix
            if "dlPreSchedData" in header:
                rename_dict[header] = header.replace("dlPreSchedData", "dl")  # Replace with your desired prefix
            if "preambleData" in header:
                rename_dict[header] = header.replace("preambleData", "data")  # Replace with your desired prefix
        # Rename the columns using the dictionary
        df_filtered = df_filtered.rename(columns=rename_dict)
        # Get the column names as a list
        # headers = df_filtered.columns.tolist()
        # rach_procedures_list = df_filtered.values.tolist()
        df_display = df_display.rename(columns=rename_dict)
        headers = df_display.columns.tolist()
        rach_procedures_list_display = df_display.values.tolist()
        display_df_as_table(rach_procedures_list_display, headers=headers,
                            base_location=get_directory(path_to_ttitrace_pkl),
                            title='rach_procedures_list_Cell'+str(cell))
        save_df_as_html(df_filtered, get_directory(path_to_ttitrace_pkl), 'rach_procedures_list_Cell'+str(cell))
        tti_dataframe.save_df_to_csv(df_filtered, csv_file_name='rach_procedures_list_Cell'+str(cell)+'.csv',
                                     folder_path=get_directory(path_to_ttitrace_pkl))

        df_filtered = df_filtered.drop(['rnti', 'lcrId'], axis=1)  # axis=1 specifies that we're dropping a column
        logging.info("df_filtered = \n%s" % (df_filtered))
        rach_procedures_list = df_filtered.values.tolist()
        rach_procedures_list = [''.join(str(sublist)) for sublist in rach_procedures_list]
        rach_procedures_reported = ''.join(rach_procedures_list)
        rach_procedures_reported = rach_procedures_reported.replace('None', '').replace('[', '').replace(']', '')
        rach_procedures_reported = rach_procedures_reported.replace(',', '').replace(' ', '').replace('\'\'', '-')
        logging.info("rach_procedures_list = \n%s" % rach_procedures_reported)

        rach_procedures_expected = rach_nsa_attach if ue_type == "nsa" else rach_sa_attach
        logging.info("rach_procedures_expected = %s" % rach_procedures_expected)
        matches = re.findall(rach_procedures_expected, rach_procedures_reported)
        num_of_attached_ues_reported = len(matches)
        logging.info("num_of_attached_ues_reported = %s" % num_of_attached_ues_reported)
        is_raState_present = num_of_attached_ues_reported == int(num_of_ues)

        if "reest" in procedure_type and ue_type == "sa":
            rach_procedures_expected = rach_sa_reest
            logging.info("rach_procedures_expected = %s" % rach_procedures_expected)
            matches = re.findall(rach_procedures_expected, rach_procedures_reported)
            num_of_reest_ues_reported = len(matches)
            logging.info("num_of_reest_ues_reported = %s" % num_of_reest_ues_reported)
            is_raState_present = is_raState_present and (num_of_reest_ues_reported == int(num_of_ues))

        logging.info("is_raState_present = %s" % is_raState_present)
    except Exception as e:
        print(f"Error : {e}")
        logException("verify_TTITraces_for_raState with Exception", e)
    # Option to validate
    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        rbi.should_be_true(is_raState_present)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    pd = pandas_gate.install_and_import_pandas()

    global FILE_PKL, PATH_PKL
    FILE_PKL = '/home/ute/csamson/TRACES/ttitrace_streaming_rach_ul_dl.pkl'
    PATH_PKL = '/home/ute/csamson/TRACES'
    input_file_path = '/home/ute/csamson/TRACES/ttitrace_streaming.pcap'
    events_list = 'preambleData'

    # df = tti_dataframe.convert_tti_trace_to_df(input_file_path, events_list, filter_json_flag=True)
    df = tti_dataframe.load_tti_trace_as_pandas_dataframe(['/home/ute/csamson/TRACES/ttitrace_streaming_1_TEST.json'],
                                                          events_list=['utcTimeStampData',
                                                                       'preambleData'],
                                                          optimize_dtypes=False)
    print(df)
    tti_dataframe.save_df_to_csv(df, csv_file_name='PreambleRach.csv', folder_path='/home/ute/csamson/TRACES/')

    def highlight_row(row):
        if any(float(val) >= 1 for val in row if
               isinstance(val, (int, float, str)) and str(val).replace('.', '', 1).isdigit()):
            return ['background-color: yellow'] * len(row)
        return [''] * len(row)

    df = df.fillna('')
    df_style = df.style.set_properties(**{'border-left': '1px solid green',
                                          'border-top': '1px solid green',
                                          'color': 'black'})
    df_style.apply(highlight_row, axis=1)
    numeric_columns = df['preambleData.peakMetric']
    df_style = df_style.format({col: '{:.5e}'.format for col in numeric_columns})
    print(df_style.data)
    with open('/home/ute/csamson/TRACES/PreambleRach.html', 'w') as f:
        # df_style.data.to_html(f, na_rep='', float_format='{:.5e}'.format)
        df_style.data.to_html(f, na_rep='', )

    verify_TTITraces_for_raState(cell='1', debug=True)
