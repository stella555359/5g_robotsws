import json
import logging
import pip
import re
import tti_extractor
from datetime import datetime
from datetime import timedelta
import pandas_gate

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()

pd = None
common_col_list = ['timeStamp']

# column names taken from event header
# since they are common to all events, event name removed and values combined
new_col_list = []


def import_pandas():
    global pd
    pd = pandas_gate.install_and_import_pandas()


def _load_json(json_filename, events_list):
    json_file = open(json_filename)
    ttidata = json.load(json_file)

    if events_list:
        events_list.append('utcTimestampData')
        ttidata = pd.DataFrame.from_dict(ttidata, orient='columns')
        ttidata = ttidata[ttidata.events.astype(str).str.contains('|'.join(events_list))]

    tti_df_normalized = pd.json_normalize(ttidata['events'])
    return tti_df_normalized


def _update_common_col_lists_with_header_elements(df):
    global common_col_list
    global new_col_list
    for colname in df.columns:
        if 'eventHeader' in colname:
            new_col_list.append(colname.split('.')[-1])
    # drop repeated elements
    new_col_list = list(set(new_col_list))
    common_col_list = common_col_list + new_col_list


def _combine_eventheader_columns(df):
    _update_common_col_lists_with_header_elements(df)
    df.columns = df.columns.str.replace('.body', '', regex=False)
    df.columns = df.columns.str.replace('.eventHeader', '', regex=False)
    for new_col in new_col_list:
        regex_pat = r'.*\.' + re.escape(new_col) + r'$'
        df.columns = df.columns.str.replace(
            regex_pat,
            new_col.upper(),
            regex=True)
        df[new_col] = df[[new_col.upper()]].agg("max", axis="columns")
        df.drop(columns=[new_col.upper()], inplace=True)
    return df


def _calculate_timestamps(df):
    slot_duration_us = df['utcTimestampData.slotDurationUs'].max()
    if slot_duration_us != df['utcTimestampData.slotDurationUs'].min():
        raise RuntimeError('inconsistent slotDurationUS value')
    MAX_SFN = 1023
    SFN_INTERVAL_US = 10000
    max_slot = (SFN_INTERVAL_US / slot_duration_us) - 1

    rbi.log('Instrum0_1: {}'.format(df[df['utcTimestampData.utcTimestamp.years'].notnull()]),
            'INFO')

    rbi.log('Instrum0_2: {}'.format(df['utcTimestampData.utcTimestamp.years']),
            'INFO')

    # create python datetime timestamp in utcTimestampData event from
    # event fields
    df.loc[df['utcTimestampData.utcTimestamp.years'].notnull(), 'timeStamp'] = \
        df.loc[df['utcTimestampData.utcTimestamp.years'].notnull()].apply(
            lambda x: datetime(
                int(x['utcTimestampData.utcTimestamp.years']),
                int(x['utcTimestampData.utcTimestamp.months']),
                int(x['utcTimestampData.utcTimestamp.days']),
                int(x['utcTimestampData.utcTimestamp.hours']),
                int(x['utcTimestampData.utcTimestamp.minutes']),
                int(x['utcTimestampData.utcTimestamp.seconds']),
                int(x['utcTimestampData.utcTimestamp.microSeconds'])),
            axis=1)
    # 04/14/2023 : old version => rnti=0 is now present in utcTimestampData events
    # => filter for rnti null to select the utcTimestampData events dont work anymore !!!
    # df.loc[df['rnti'].isnull(), 'timeStamp'] = \
    #     df.loc[df['rnti'].isnull()].apply(
    #         lambda x: datetime(
    #             int(x['utcTimestampData.utcTimestamp.years']),
    #             int(x['utcTimestampData.utcTimestamp.months']),
    #             int(x['utcTimestampData.utcTimestamp.days']),
    #             int(x['utcTimestampData.utcTimestamp.hours']),
    #             int(x['utcTimestampData.utcTimestamp.minutes']),
    #             int(x['utcTimestampData.utcTimestamp.seconds']),
    #             int(x['utcTimestampData.utcTimestamp.microSeconds'])),
    #                 axis = 1)

    # combine sfn and slot and convert to microseconds unit
    df['sfn_slot'] = ((df['sfn'] * (max_slot + 1)) +
                      df['slot']) * slot_duration_us

    rbi.log('Instrum1: {}'.format(df['sfn_slot']),
            'INFO')
    # calculate differences between adjacent events based on sfn + slot
    df['sfn_slot_diff'] = df['sfn_slot'].diff()

    rbi.log('Instrum2: {}'.format(df['sfn_slot_diff']),
            'INFO')

    df.iloc[0, df.columns.get_loc('sfn_slot_diff')] = 0

    # fix the places where the SFN wraps around
    df['sfn_slot_diff'] = df['sfn_slot_diff'] % (
        (MAX_SFN + 1) * (max_slot + 1) * slot_duration_us)

    rbi.log('Instrum3: {}'.format(df['sfn_slot_diff']),
            'INFO')

    # calculate the accumulated difference between
    # events and convert it to datetime format
    df['accum_diff'] = df['sfn_slot_diff'].cumsum()
    df['accum_diff'] = df['accum_diff'].apply(
        lambda x: timedelta(microseconds=x) if pd.notnull(x) else x)

    rbi.log('Instrum4: {}'.format(df['accum_diff']),
            'INFO')

    rbi.log('Instrum5: {}'.format(df.rnti.astype(int)),
            'INFO')

    rbi.log('Instrum6: {}'.format(df[(df.rnti.astype(int) == 0)]), 'INFO')

    rbi.log('Instrum7: {}'.format(df),
            'INFO')

    # calculate difference between first known timestamp and first
    # event on the trace
    # note: filter for rnti null selects the utcTimestampData events
    # 04/14/2023 : old version => rnti=0 is now present in utcTimestampData events
    # => filter for rnti null to select the utcTimestampData events dont work anymore !!!
    # accum_diff_first_timestamp = df[df.rnti.isnull()]['accum_diff'].iloc[0]
    # accum_diff_first_timestamp = df[(df.rnti.astype(int) == 0)]['accum_diff'].iloc[0]
    accum_diff_first_timestamp = df[(df['utcTimestampData.utcTimestamp.years'].notnull())]['accum_diff'].iloc[0]
    # first_timestamp_value = df[df.rnti.isnull()]['timeStamp'].iloc[0]
    # first_timestamp_value = df[(df.rnti.astype(int) == 0)]['timeStamp'].iloc[0]
    first_timestamp_value = df[(df['utcTimestampData.utcTimestamp.years'].notnull())]['timeStamp'].iloc[0]
    timestamp_first_event = first_timestamp_value - accum_diff_first_timestamp

    # add found value to all the trace
    df['timeStamp'] = df['accum_diff'] + timestamp_first_event
    # df['timeStamp'] = int(0)

    # remover helper columns
    columns_to_delete_list = [
        'sfn_slot',
        'sfn_slot_diff',
        'accum_diff']
    df.drop(columns=columns_to_delete_list, inplace=True)
    df.drop(df[~df['utcTimestampData.utcTimestamp.years'].isnull()].index, inplace=True)
    df.drop(list(df.filter(regex='utcTimestampData')), axis=1, inplace=True)
    return df


def _beautify_df(raw_df):
    # Add timestamp, sfn, slot, etc in front of the table
    popped_df = pd.concat([raw_df.pop(x) for x in ['timeStamp',
                                                   'sfn',
                                                   'slot',
                                                   'rnti',
                                                   'lcrId',
                                                   'physCellId']], axis=1)
    beautified_df = pd.concat([popped_df, raw_df], axis=1)
    return beautified_df


def save_df_to_csv(df, csv_file_name="tti_analysis_uldl.csv", folder_path=""):
    df.to_csv(folder_path + csv_file_name, index=False)


def load_tti_trace_as_pandas_dataframe(json_filename, events_list=[]):
    global pd
    import_pandas()
    df = _load_json(json_filename, events_list)
    df = _combine_eventheader_columns(df)
    df = _calculate_timestamps(df)
    df = normalize_nested_arrays(df)
    df = _beautify_df(df)
    return df


def convert_tti_trace_to_df(tti_pcap_file, events_list=[], num_of_events=None):
    tti_json_file = tti_pcap_file.replace("pcap", "json")
    if num_of_events is not None:
        num_of_events = int(num_of_events)
    tti_extractor.decode_events_using_event_decoder(tti_pcap_file, events_list, num_of_events)
    df = load_tti_trace_as_pandas_dataframe(tti_json_file, events_list)
    return df


def nested_array_column_to_list(df, nested_array_colname, event_common_col_list):
    dataframe_list = []
    # iterate over all the lines
    for index, row in df.iterrows():
        for nested_dict in row[nested_array_colname]:
            if nested_dict is not None:
                for common_col in (common_col_list + event_common_col_list):
                    # add to dictionary the keys from the common columns if non existing
                    try:
                        # check if key with common column exists. Take always the value
                        # in the nested array if the key is present there
                        nested_dict[common_col]
                    except KeyError:
                        # if does not, add it with the value from the event
                        nested_dict[common_col] = row[common_col]
                dataframe_list.append(nested_dict)
    return dataframe_list


def get_event_specific_common_cols(df, event_name, nested_field):
    event_common_col_list = []
    for col_name in df.columns:
        if event_name in col_name and not (nested_field in col_name):
            event_common_col_list.append(col_name)
    print(event_common_col_list)
    return event_common_col_list


def normalize_nested_arrays(df):
    # find nested arrays and put them in the nested cols list
    nested_cols_list = []
    nested_cols = ["nestedArray", "ueRecords"]
    for col_name in df.columns:
        if any(x in col_name for x in nested_cols):
            nested_cols_list.append(col_name)

    if not nested_cols_list:
        return df

    new_df_list = []
    # for each column with nested array found
    for col_name in nested_cols_list:
        event_name = col_name.split('.')[0]
        nested_field_name = col_name.split('.')[1]
        # get event specific common_cols
        event_common_col_list = get_event_specific_common_cols(df, event_name, nested_field_name)
        # filter dataframe for column with nested array contents
        df_col_filt = df[df[col_name].notnull()]
        # get everything inside the column with nested array and put it to list
        dataframe_list = nested_array_column_to_list(df_col_filt, col_name, event_common_col_list)
        # convert the list to dataframe
        temp_df = pd.DataFrame(dataframe_list)
        # add to name of columns (which are not common) the name of the event separated by '.'
        temp_df.columns = [x if x in (common_col_list + event_common_col_list)
                           else '.'.join([event_name, x]) for x in temp_df.columns]
        # store the dataframes into list to be joined later
        new_df_list.append(temp_df)

    # concat all new dataframes in the list of dataframes created from the nested arrays
    new_df = pd.concat(new_df_list, axis=0, ignore_index=True)

    # append new frame with all nested arrays contentes to original dataframe
    complete_df = pd.concat([df, new_df], axis=0, ignore_index=True)

    # remove .nestedArray
    for col_name in nested_cols_list:
        complete_df.drop(complete_df[~complete_df[col_name].isnull()].index, inplace=True)

    # delete columns with nested arrays
    complete_df.drop(columns=nested_cols_list, inplace=True)

    # sort everything according to timeStamp
    complete_df = complete_df.sort_values(by=['timeStamp'], ascending=True, inplace=False)

    return complete_df


def write_df_to_pickle(df, target_path):
    target_path = target_path.replace("pcap", "pkl")
    df.to_pickle(target_path)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    # df = load_tti_trace_as_pandas_dataframe('/home/ute/csamson/TRACES/Issue/ttitrace_streaming.json',
    #                                         events_list=['utcTimeStampData'])
    df = load_tti_trace_as_pandas_dataframe('/home/ute/csamson/TRACES/Issue/ttitrace_streaming.json',
                                            events_list=['utcTimeStampData',
                                                         'dlMetricIndData',
                                                         'dlAllocatedPooledResourcesData',
                                                         'dlFdSchedData'])
    save_df_to_csv(df, folder_path='/home/ute/csamson/TRACES/Issue')
    print(df)
