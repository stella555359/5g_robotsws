import logging

from datetime import datetime
from datetime import timedelta

from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html

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
def get_prb_stats(df, by='rnti', direction=None, return_prb_df=False, event_under_consideration=None):
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
    if return_prb_df:
        return (generate_prb_stats(df, by, direction, event_under_consideration),
                get_event_entries_with_prb(df, by, direction, event_under_consideration))
    else:
        return generate_prb_stats(df, by, direction, event_under_consideration)


def prepare_dataframe_for_analysis_dl(df):
    # df = df[["timeStamp",
    #          "dlFdSchedData.numOfPrb"]]

    df = df.rename(columns={
        "dlFdSchedData.numOfPrb": "numOfPrb"})

    return df


def prepare_dataframe_for_analysis_ul(df):
    # df = df[["timeStamp",
    #          "ulFdSchedData.numOfPrb"]]

    df = df.rename(columns={
        "ulFdSchedData.numOfPrb": "numOfPrb",
        "ulFdSchedData.priorityIndex": "priorityIndex",
        "ulFdSchedData.isValidWhatIsProposed": "isValidWhatIsProposed",
        "ulFdSchedData.rrmMaxNumPrbUl": "rrmMaxNumPrbUl"})

    return df


@log_begin_end_func_name
def get_event_entries_with_prb(df, by='rnti', direction=None, event_under_consideration=None):
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
    if direction == 'ul':
        filtered_df = prepare_dataframe_for_analysis_ul(df)
    else:
        filtered_df = prepare_dataframe_for_analysis_dl(df)
    filtered_df = filtered_df[filter].dropna()
    filtered_df = filtered_df[event_under_consideration].dropna()

    return filtered_df


"""Private Functions"""


@log_begin_end_func_name
def get_event_and_filter(direction=None, grouped_by="rnti", event_under_consideration=None):
    filter = [grouped_by]
    # filter_ul = 'ulFdSchedData.numOfPrb'
    # filter_dl = 'dlFdSchedData.numOfPrb'
    filter_ul = 'NbrPrbPerSlot'
    filter_dl = 'NbrPrbPerSlot'
    # filter_ul = 'numOfPrb'
    # filter_dl = 'numOfPrb'
    if not event_under_consideration and direction == 'ul':
        filter.append(filter_ul)
        filter.append('rrmMaxNumPrbUl')
        filter.append('numOfPrb')
        event_under_consideration = filter_ul
    elif not event_under_consideration and direction == 'dl':
        filter.append(filter_dl)
        filter.append('numOfPrb')
        event_under_consideration = filter_dl
    elif event_under_consideration:
        filter.append(event_under_consideration)
    elif not direction and not event_under_consideration:
        logging.error("Invalid parameters -> Use a valid value for either param: "
                      "direction or param: event_under_consideration")

    return event_under_consideration, filter


@log_begin_end_func_name
def generate_prb_stats(df, by='rnti', direction=None, event_under_consideration=None):
    event_under_consideration, filter = get_event_and_filter(direction, by, event_under_consideration)
    if direction == 'ul':
        # Prepare DataFrame for Uplink (UL) analysis
        filtered_df = prepare_dataframe_for_analysis_ul(df)
        # filtered_df_2 is used to use valid value of rrmMaxNumPrbUl
        filtered_df_2 = filtered_df[filtered_df["isValidWhatIsProposed"] != 0]
        if "priorityIndex" in filtered_df_2.columns:
            # for 25R3 branch, seems 20 means "DRBTRAFFIC"
            # Filter for priorityIndex values containing "DRBTRAFFIC" for release > 25R3
            # This specific filter is applied to select valid values for rrmMaxNumPrbUl in UL context.
            # Condition 1: Check if the string representation of 'priorityIndex' contains "DRBTRAFFIC"
            # .astype(str) converts all values (including integers and None/NaN) to strings.
            # Condition 2: Check if the value is exactly 20 (handles both integer 20 and string '20')
            filtered_df_2 =\
                filtered_df_2[filtered_df_2["priorityIndex"].astype(str).str.contains("DRBTRAFFIC", na=False) |
                              (filtered_df_2["priorityIndex"] == 20) | (filtered_df_2["priorityIndex"] == '20')]
    else:
        filtered_df = prepare_dataframe_for_analysis_dl(df)
    filtered_df = filtered_df[filter].dropna()
    print('filtered_df: {}'.format(filtered_df.head(10)))
    filtered_avg_df = filtered_df.astype(int)
    avg = filtered_avg_df['NbrPrbPerSlot'].mean().astype(int)
    print('avg: {}'.format(avg))
    median = filtered_avg_df['NbrPrbPerSlot'].median().astype(int)
    print('median: {}'.format(median))
    sum_prb = filtered_avg_df['numOfPrb'].sum().astype(int)
    print('sum_prb: {}'.format(sum_prb))
    count = len(filtered_avg_df)
    print('count: {}'.format(count))

    if direction == 'ul':
        filtered_df_2 = filtered_df_2[filter].dropna()
        filtered_avg_df_2 = filtered_df_2.astype(int)
        max_index = filtered_avg_df_2['NbrPrbPerSlot'].idxmax()
        max_prb = filtered_avg_df_2.at[max_index, 'NbrPrbPerSlot']
    else:
        # filtered_avg_df_2 = filtered_df.astype(int)
        max_index = filtered_avg_df['NbrPrbPerSlot'].idxmax()
        max_prb = filtered_avg_df.at[max_index, 'NbrPrbPerSlot']
    if direction == 'ul':
        rrmMaxNumPrbUl = filtered_avg_df_2.at[max_index, 'rrmMaxNumPrbUl']
        # Calculate the ratio
        ul_ratio_max_or_dl_max_prb = round((max_prb / rrmMaxNumPrbUl) * 100)
    else:
        rrm_max_prb = filtered_avg_df.at[max_index, 'NbrPrbPerSlot']
        ul_ratio_max_or_dl_max_prb = rrm_max_prb

    """Extract prb stats based on filter"""
    if direction == 'ul':
        filtered_df = filtered_df.drop(columns=['rrmMaxNumPrbUl'], axis=1)
        filtered_df = filtered_df.drop(columns=['NbrPrbPerSlot'], axis=1)
        event_under_consideration = 'numOfPrb'
    else:
        filtered_df = filtered_df.drop(columns=['NbrPrbPerSlot'], axis=1)
        event_under_consideration = 'numOfPrb'
    prb_stats = filtered_df.value_counts().reset_index()
    # prb_stats = prb_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    prb_stats['Total Count'] = prb_stats[by].map(total_events_grouped)
    prb_stats['Percentage'] = (prb_stats['count'] / prb_stats['Total Count']) * 100
    """Combine stats"""
    combined_prb_stats = prb_stats.pivot(index=by, columns=[event_under_consideration],
                                         values=['count', 'Percentage'])
    combined_prb_stats.fillna(0, inplace=True)
    print('prb_stats: {}'.format(prb_stats))
    # Combine the statistics into a dictionary
    combined_prb_stats_results = {
        'avg': avg,
        'median': median,
        'sum': sum_prb,
        'count': count,
        'ul_ratio_max_or_dl_max_prb': ul_ratio_max_or_dl_max_prb
    }
    return combined_prb_stats, combined_prb_stats_results


@log_begin_end_func_name
def get_prb_per_slot_stats(df, by='rnti', direction=None, event_under_consideration=None):
    event_under_consideration, filter = get_event_and_filter(direction, by, event_under_consideration)
    if direction == 'ul':
        filtered_df = prepare_dataframe_for_analysis_ul(df)
        # Prepare DataFrame for Uplink (UL) analysis
        # filtered_df_2 is used to use valid value of rrmMaxNumPrbUl
        filtered_df_2 = filtered_df[filtered_df["isValidWhatIsProposed"] != 0]
        if "priorityIndex" in filtered_df_2.columns:
            # for 25R3 branch, seems 20 means "DRBTRAFFIC"
            # Filter for priorityIndex values containing "DRBTRAFFIC" for release > 25R3
            # This specific filter is applied to select valid values for rrmMaxNumPrbUl in UL context.
            # Condition 1: Check if the string representation of 'priorityIndex' contains "DRBTRAFFIC"
            # .astype(str) converts all values (including integers and None/NaN) to strings.
            # Condition 2: Check if the value is exactly 20 (handles both integer 20 and string '20')
            filtered_df_2 =\
                filtered_df_2[filtered_df_2["priorityIndex"].astype(str).str.contains("DRBTRAFFIC", na=False) |
                              (filtered_df_2["priorityIndex"] == 20) | (filtered_df_2["priorityIndex"] == '20')]
    else:
        filtered_df = prepare_dataframe_for_analysis_dl(df)
    filtered_df = filtered_df[filter].dropna()
    print('filtered_df: {}'.format(filtered_df.head(10)))
    filtered_avg_df = filtered_df.astype(int)
    avg = filtered_avg_df['NbrPrbPerSlot'].mean().astype(int)
    print('avg: {}'.format(avg))
    median = filtered_avg_df['NbrPrbPerSlot'].median().astype(int)
    print('median: {}'.format(median))
    sum_prb = filtered_avg_df['numOfPrb'].sum().astype(int)
    print('sum_prb: {}'.format(sum_prb))
    count = len(filtered_avg_df)
    print('count: {}'.format(count))

    # max_index = filtered_avg_df['NbrPrbPerSlot'].idxmax()
    # max_prb = filtered_avg_df.at[max_index, 'NbrPrbPerSlot']
    if direction == 'ul':
        filtered_df_2 = filtered_df_2[filter].dropna()
        filtered_avg_df_2 = filtered_df_2.astype(int)
        max_index = filtered_avg_df_2['NbrPrbPerSlot'].idxmax()
        max_prb = filtered_avg_df_2.at[max_index, 'NbrPrbPerSlot']
    else:
        max_index = filtered_avg_df['NbrPrbPerSlot'].idxmax()
        max_prb = filtered_avg_df.at[max_index, 'NbrPrbPerSlot']

    if direction == 'ul':
        rrmMaxNumPrbUl = filtered_avg_df.at[max_index, 'rrmMaxNumPrbUl']
        # Calculate the ratio
        ul_ratio_max_or_dl_max_prb = round((max_prb / rrmMaxNumPrbUl) * 100)
    else:
        rrm_max_prb = filtered_avg_df.at[max_index, 'NbrPrbPerSlot']
        ul_ratio_max_or_dl_max_prb = rrm_max_prb

    """Extract prb stats based on filter"""
    if direction == 'ul':
        filtered_df = filtered_df.drop(columns=['rrmMaxNumPrbUl'], axis=1)
        filtered_df = filtered_df.drop(columns=['numOfPrb'], axis=1)
        event_under_consideration = 'NbrPrbPerSlot'
    else:
        filtered_df = filtered_df.drop(columns=['numOfPrb'], axis=1)
        event_under_consideration = 'NbrPrbPerSlot'
    prb_stats = filtered_df.value_counts().reset_index()
    # prb_stats = prb_stats.rename(columns={0: 'Count'})
    """Identify total events per defined group in trace"""
    total_events_grouped = filtered_df.groupby(by).size()
    """Add new columns to df"""
    prb_stats['Total Count'] = prb_stats[by].map(total_events_grouped)
    prb_stats['Percentage'] = (prb_stats['count'] / prb_stats['Total Count']) * 100
    """Combine stats"""
    combined_prb_stats = prb_stats.pivot(index=by, columns=[event_under_consideration],
                                         values=['count', 'Percentage'])
    combined_prb_stats.fillna(0, inplace=True)
    print('prb_stats: {}'.format(prb_stats))
    # Combine the statistics into a dictionary
    combined_prb_stats_results = {
        'avg': avg,
        'median': median,
        'sum': sum_prb,
        'count': count,
        'ul_ratio_max_or_dl_max_prb': ul_ratio_max_or_dl_max_prb
    }
    return combined_prb_stats, combined_prb_stats_results


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
