import logging

from datetime import datetime
from datetime import timedelta

from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.CB009836.resources.python.tti_analysis.helper_functions import display_df_as_html

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
def get_mumimo_stats(df, by='rnti', direction=None, return_dtx_df=False, event_under_consideration=None):
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
        return (generate_mumimo_stats(df, by, direction, event_under_consideration),
                get_event_entries_with_mumimo(df, by, direction, event_under_consideration))
    else:
        return generate_mumimo_stats(df, by, direction, event_under_consideration)


@log_begin_end_func_name
def get_event_entries_with_mumimo(df, by='rnti', direction=None, event_under_consideration=None):
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
    filtered_df = filtered_df[filtered_df[event_under_consideration] == 'MUPAIR'].dropna()
    return filtered_df


"""Private Functions"""


@log_begin_end_func_name
def get_event_and_filter(direction=None, grouped_by="rnti", event_under_consideration=None):
    filter = [grouped_by]
    filter_ul = 'ulFdSchedData.ulMuStatus'
    filter_dl = 'dlFdSchedData.muStatus'
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
def get_event_and_filter_rank(direction=None, grouped_by="rnti", event_under_consideration=None):
    filter = [grouped_by]
    filter_ul = 'ulFdSchedData.numOfLayers'
    filter_dl = 'dlFdSchedData.numOfLayers'
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
def get_event_and_filter_subcellId(direction=None, grouped_by="rnti", event_under_consideration=None):
    filter = [grouped_by]
    filter_ul = 'ulFdSchedData.subcellId'
    filter_dl = 'dlFdSchedData.subcellId'
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
def generate_mumimo_stats(df, by='rnti', direction=None, event_under_consideration=None, w_criteria=False):
    event_under_consideration, filter = get_event_and_filter(direction, by, event_under_consideration)
    filtered_df = df[filter].dropna()
    print('filtered_df: {}'.format(filtered_df))

    # Validation Threshold: Percentage of MUPAIRED to accept
    threshold = 0.1

    # Check MUPAIRED in dataframe
    is_MUPAIRED_present = any(x in filtered_df[event_under_consideration].values for x in ('MUPAIRED_NO_TAPERING'))
    rbi.log("Is MUPAIRED_NO_TAPERING present: {}".format(is_MUPAIRED_present))
    MUPAIRED_df = filtered_df.loc[df[event_under_consideration] == 'MUPAIRED_NO_TAPERING'].dropna(
        subset=[event_under_consideration])

    # Get percentage of MUPAIRED
    percentage_MUPAIRED = 100 * len(MUPAIRED_df) / len(df[event_under_consideration])
    rbi.log("Percentage of percentage_MUPAIRED: {} Threshold accepted: {}".format(percentage_MUPAIRED, threshold))

    """Extract mumimo stats based on filter"""
    mumimo_stats = filtered_df.value_counts().reset_index()
    # mumimo_stats = mumimo_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    mumimo_stats['Total Count'] = mumimo_stats[by].map(total_events_grouped)
    mumimo_stats['Percentage'] = (mumimo_stats['count'] / mumimo_stats['Total Count']) * 100
    """Combine stats"""
    combined_mumimo_stats = mumimo_stats.pivot(index=by, columns=event_under_consideration,
                                               values=['count', 'Percentage'])
    combined_mumimo_stats.fillna(0, inplace=True)
    print('mumimo_stats: {}'.format(mumimo_stats))

    if is_MUPAIRED_present and w_criteria:
        rbi.log("Showing first 10 failing rows...")
        if percentage_MUPAIRED < threshold:
            rbi.log('Percentage ({}) did not reach threshold criteria ({}). Failing test case..'
                    .format(percentage_MUPAIRED, threshold))
            msg = '[ERR] generate_mumimo_stats: mumimo_stats'
            datedConsole(getHeaderLine(msg, mumimo_stats))
            msg = '[ERR] MUPAIRED present on {} rows. Percentage ({}) did not reach threshold criteria ({})'
            rbi.fail(msg.format(len(MUPAIRED_df), percentage_MUPAIRED, threshold))
        else:
            rbi.log("MUPAIRED present but threshold reached.. Passing test case")

    return combined_mumimo_stats, mumimo_stats


@log_begin_end_func_name
def generate_rank_stats(df, by='rnti', direction=None, event_under_consideration=None):
    event_under_consideration, filter = get_event_and_filter_rank(direction, by, event_under_consideration)
    filtered_df = df[filter].dropna()
    print('filtered_df: {}'.format(filtered_df))
    """Extract rank stats based on filter"""
    rank_stats = filtered_df.value_counts().reset_index()
    # rank_stats = rank_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    rank_stats['Total Count'] = rank_stats[by].map(total_events_grouped)
    rank_stats['Percentage'] = (rank_stats['count'] / rank_stats['Total Count']) * 100
    """Combine stats"""
    combined_rank_stats = rank_stats.pivot(index=by, columns=event_under_consideration, values=['count', 'Percentage'])
    combined_rank_stats.fillna(0, inplace=True)
    print('rank_stats: {}'.format(rank_stats))
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def generate_subcellId_stats(df, by='rnti', direction=None, event_under_consideration=None):
    event_under_consideration, filter = get_event_and_filter_subcellId(direction, by, event_under_consideration)
    filtered_df = df[filter].dropna()
    print('filtered_df: {}'.format(filtered_df))
    """Extract subcellId stats based on filter"""
    subcellId_stats = filtered_df.value_counts().reset_index()
    # subcellId_stats = subcellId_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    subcellId_stats['Total Count'] = subcellId_stats[by].map(total_events_grouped)
    subcellId_stats['Percentage'] = (subcellId_stats['count'] / subcellId_stats['Total Count']) * 100
    """Combine stats"""
    combined_subcellId_stats = subcellId_stats.pivot(index=by, columns=event_under_consideration,
                                                     values=['count', 'Percentage'])
    combined_subcellId_stats.fillna(0, inplace=True)
    print('subcellId_stats: {}'.format(subcellId_stats))
    return combined_subcellId_stats, subcellId_stats
