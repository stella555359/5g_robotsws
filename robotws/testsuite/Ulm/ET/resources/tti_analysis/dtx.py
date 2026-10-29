import logging

from datetime import datetime
from datetime import timedelta

import pandas as pd

from testsuite.Ulm.ET.resources.tti_analysis.helper_functions import display_df_as_html

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


""" Functions to be used """


@log_begin_end_func_name
def check_rlf_status(df, event='dlHarqRxDataArray', status='DETECTED', present=True):
    """ This function check if RLF is detected/recovered using event.radioLinkFailureStatus

        :param df: Pandas dataframe with the following columns:
                   [[ timeStamp, sfn, slot, ul/dl HarqRxDataArray/PucchReceiveRespPsData ]]
        :param event: event that contains .dtx and .pucchFormat e.g ul/dlHarqRxDataArray, ul/dlPucchReceiveRespPsData
        :param status: check RLF if DETECTED or RECOVERY
    """
    rlf_event = "{}.radioLinkFailureStatus".format(event)

    if len(df[df[rlf_event] == status]) > 0 and present:
        rbi.log("Radio link failure status is {}".format(status))
        display_df_as_html(df[df[rlf_event] == status])
    elif len(df[df[rlf_event] == status]) > 0 and not present:
        rbi.fail("Radio link failure status should NOT be {}".format(status))
    elif len(df[df[rlf_event] == status]) == 0 and not present:
        rbi.log("Radio link failure status is not {}".format(status))
    else:
        rbi.fail("Radio link failure status is NOT {}".format(status))


@log_begin_end_func_name
def calculate_highest_number_of_continuous_dtx(df, event='dlHarqRxDataArray'):
    """ This function calculates and returns the highest number of continuous HARQ/CSI DTX

        :param df: Pandas dataframe with the following columns:
                   [[ timeStamp, sfn, slot, ul/dl HarqRxDataArray/PucchReceiveRespPsData ]]
        :param event: event that contains .dtx and .pucchFormat e.g ul/dlHarqRxDataArray, ul/dlPucchReceiveRespPsData

        :returns: highest number of continuous harq/csi dtx
        :rtype: int

        Sample output:
        (Aside from returning a interger, the function also displays the following table)
            timeStamp                     sfn   slot                csiSrReportData.dtx     csiSrReportData.pucchFormat
        1257 2022-08-18 15:56:25.367314  304.0  14.0                          DTX                                   3.0
        1279 2022-08-18 15:56:25.527314  320.0  14.0                          DTX                                   3.0
        1300 2022-08-18 15:56:25.687314  336.0  14.0                          DTX                                   3.0
        1320 2022-08-18 15:56:25.847314  352.0  14.0                          DTX                                   3.0
        1341 2022-08-18 15:56:26.007314  368.0  14.0                          DTX                                   3.0
        1378 2022-08-18 15:56:26.327314  400.0  14.0                          DTX                                   3.0
        1416 2022-08-18 15:56:26.647314  432.0  14.0                          DTX                                   3.0
        The number of consecutive DTX is 7 for the duration of 0:00:01.280000
    """

    # Filter needed columns
    tti_df = df[['timeStamp', 'sfn', 'slot', '{}.dtx'.format(event), '{}.pucchFormat'.format(event)]]

    # Remove rows with empty DTX and filter only those with PUCCH FORMAT 0,1 and FROM PUSCH for HarqRxDataArray
    # and pucchFormat 2,3 for csiSrReportData
    if event == 'dlHarqRxDataArray':
        event_format_1 = 'FORMAT_0'
        event_format_2 = 'FORMAT_1'
    else:
        event_format_1 = 'FORMAT_2'
        event_format_2 = 'FORMAT_3'

    tti_df = tti_df[(tti_df['{}.pucchFormat'.format(event)] == event_format_1)
                    | (tti_df['{}.pucchFormat'.format(event)] == event_format_2)
                    | (tti_df['{}.pucchFormat'.format(event)] == 'FROM_PUSCH')].dropna(subset=['{}.dtx'.format(event)])

    rbi.log("-------------------------  Filtered Dataframe from {} --------------------------".format(event), "TRACE")
    rbi.log(tti_df, "TRACE")

    highest_number = 0
    highest_group = None
    # Count the continuous number of DTX
    # .shift() compares DTX against its shifted version below (returns true if value is same)
    # .cumsum() counts the cummulative sum to get the number of groups
    for instance_num, grouped_row in tti_df.groupby([(tti_df['{}.dtx'.format(event)] !=
                                                    tti_df['{}.dtx'.format(event)].shift()).cumsum()]):
        # If group values are DTX and is more than 1 instance (random DTX that are not intentionally set)
        if (grouped_row['{}.dtx'.format(event)].max() == 'DTX') & (grouped_row.shape[0] > 1):
            # Save the group's number of DTX if higher than the stored highest_number
            if grouped_row.shape[0] > highest_number:
                highest_number = grouped_row.shape[0]
                highest_group = grouped_row

            # Add more info such as timestamp of the group and the duration
            duration = (grouped_row.timeStamp.max() - grouped_row.timeStamp.min()).to_pytimedelta()
            rbi.log("[{}-{}] Number of consecutive DTX is {} for the duration of {}"
                    .format(grouped_row.timeStamp.min(), grouped_row.timeStamp.max(),
                            grouped_row.shape[0], duration), "INFO")

    if highest_group is None:
        rbi.log("No consecutive DTX found! Check tti trace .csv for more info!")
    else:
        display_df_as_html(df=highest_group, log_level='INFO')

    return highest_number


@log_begin_end_func_name
def get_dtx_stats(df, by='rnti', direction=None, return_dtx_df=False, event_under_consideration=None):
    """
    Inputs:
    df : Pandas Dataframe, please make sure the dataframe has the following columns
         'timeStamp', 'sfn', 'slot', lcrId, rnti and the column containing DTX discriminator for the event of choice
         e.g. ulHarqRxData.dtx, dlHarqRxDataArray.dtx
    direction: "ul / dl" -> to be used while calcuating HARQ stats from ulHarqRxData.dtx, dlHarqRxDataArray.dtx
                respectively
    by: mentions the desired parameter based on which the statistics are sorted. for e.g. rnti / lcrId / physCellId
    return_dtx_df: default: False
                   returns the dtx stats in the format of a dataframe shown below

                   when set to True
                   returns a tuple where the first element is the stats in the format of a dataframe shown below
                   the second element is a dataframe containing all the entires where DTX was detected
    event_under_consideration: Calculate DTX stats on events that are not HARQ related for e.g. csiSrReportData.dtx

    Sample output:
    UL DTX Stats sorted by lcrId
    ---------------------------------------------------
                            Count Percentage
    ulHarqRxData.dtx  NON_DTX    NON_DTX
    lcrId
    1.0               31473.0      100.0
    2.0                 302.0      100.0
    3.0                 302.0      100.0

    DL DTX Stats sorted by lcrId
    ---------------------------------------------------
                            Count Percentage
    dlHarqRxDataArray.dtx NON_DTX    NON_DTX
    lcrId
    1.0                    6487.0      100.0
    2.0                       3.0      100.0
    3.0                       2.0      100.0

    UL DTX Stats sorted by RNTI
    ---------------------------------------------------
                    Count         Percentage
    ulHarqRxData.dtx    DTX NON_DTX        DTX     NON_DTX
    rnti
    24077.0           640.0  1066.0  37.514654   62.485346
    25917.0           638.0  1057.0  37.640118   62.359882
    27757.0           631.0  1074.0  37.008798   62.991202
    55925.0             0.0     1.0   0.000000  100.000000
    57765.0             0.0     1.0   0.000000  100.000000
    59605.0             0.0     1.0   0.000000  100.000000
    ---------------------------------------------------
    CSI Reports DTX Stats sorted by RNTI
                            Count         Percentage
    csiSrReportData.dtx   DTX NON_DTX        DTX     NON_DTX
    rnti
    24077.0               0.0    11.0   0.000000  100.000000
    25917.0               0.0    19.0   0.000000  100.000000
    27757.0               1.0    26.0   3.703704   96.296296
    """
    if return_dtx_df:
        return (generate_dtx_stats(df, by, direction, event_under_consideration),
                get_event_entries_with_dtx(df, by, direction, event_under_consideration))
    else:
        return generate_dtx_stats(df, by, direction, event_under_consideration)


@log_begin_end_func_name
def get_event_entries_with_dtx(df, by='rnti', direction=None, event_under_consideration=None):
    """
    Inputs:
    df : Pandas Dataframe, please make sure the dataframe has the following columns
         'timeStamp', 'sfn', 'slot', lcrId, rnti and the column containing DTX discriminator for the event of choice
         e.g. ulHarqRxData.dtx, dlHarqRxDataArray.dtx
    direction: "ul / dl" -> to be used while calcuating HARQ stats from ulHarqRxData.dtx, dlHarqRxDataArray.dtx
                respectively
    by: mentions the desired parameter based on which the statistics are sorted. for e.g. rnti / lcrId / physCellId
    event_under_consideration: Returns a list of events where DTX is observed.
                               to be used when event is not HARQ related for e.g. csiSrReportData.dtx

    Returns a dataframe for a event where DTX is observed.
                            timeStamp    sfn  slot     rnti ulHarqRxData.dtx
    45   2022-08-01 11:47:31.174816  389.0   9.0  24077.0              DTX
    46   2022-08-01 11:47:31.179816  389.0  19.0  24077.0              DTX
    47   2022-08-01 11:47:31.184816  390.0   9.0  24077.0              DTX
    48   2022-08-01 11:47:31.189816  390.0  19.0  24077.0              DTX
    49   2022-08-01 11:47:31.194816  391.0   9.0  24077.0              DTX
    ...                         ...    ...   ...      ...              ...
    6759 2022-08-01 11:47:37.027316  974.0  14.0  27757.0              DTX
    6764 2022-08-01 11:47:37.032316  975.0   4.0  24077.0              DTX

    """
    filter = ['timeStamp', 'sfn', 'slot']
    event_under_consideration, filter_event = get_event_and_filter(direction, by, event_under_consideration)
    filter += filter_event
    filtered_df = df[filter].dropna()
    filtered_df = filtered_df[filtered_df[event_under_consideration] == 'DTX'].dropna()
    return filtered_df


"""Private Functions"""


@log_begin_end_func_name
def get_event_and_filter(direction=None, grouped_by="rnti", event_under_consideration=None):
    filter = [grouped_by]
    filter_ul = 'ulHarqRxData.dtx'
    filter_dl = 'dlHarqRxDataArray.dtx'
    if not event_under_consideration and direction == 'ul':
        filter.append(filter_ul)
        event_under_consideration = filter_ul
    elif not event_under_consideration and direction == 'dl':
        filter.append(filter_dl)
        event_under_consideration = filter_dl
    elif event_under_consideration:
        filter.append(event_under_consideration)
        event_under_consideration
    elif not direction and not event_under_consideration:
        logging.error("Invalid parameters -> Use a valid value for either param: "
                      "direction or param: event_under_consideration")

    return event_under_consideration, filter


@log_begin_end_func_name
def generate_dtx_stats(df, by='rnti', direction=None, event_under_consideration=None):
    event_under_consideration, filter = get_event_and_filter(direction, by, event_under_consideration)
    filtered_df = df[filter].dropna()
    """Extract dtx stats based on filter"""
    dtx_stats = filtered_df.value_counts().reset_index()
    """Identify total events per defined group in trace"""
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    dtx_stats['Total Count'] = dtx_stats[by].map(total_events_grouped)
    dtx_stats['Percentage'] = (dtx_stats['count'] / dtx_stats['Total Count']) * 100
    """Combine stats"""
    combined_dtx_stats = dtx_stats.pivot(index=by, columns=event_under_consideration, values=['count', 'Percentage'])
    combined_dtx_stats.fillna(0, inplace=True)
    return combined_dtx_stats
