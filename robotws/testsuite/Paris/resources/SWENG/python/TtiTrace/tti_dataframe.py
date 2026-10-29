import json
import os
import re
from functools import wraps
from datetime import datetime
from datetime import timedelta
from enum import Enum
import pandas_gate
import tti_extractor

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

pd = None
np = None
common_col_list = ['timeStamp']

# column names taken from event header
# since they are common to all events, event name removed and values combined
new_col_list = []


class Mode(Enum):
    UNIQUE_FILE = 'unique_file'
    Multiple_FILE = 'another_mode'


def import_pandas():
    global pd
    global np
    pd, np = pandas_gate.install_and_import_pandas()
    return pd, np


def handle_none_args(func):
    """ Decorator to handle None values in arguments.
    Useful to handle values from Robot Framework that are passed as strings.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        args = tuple(None if isinstance(arg, str) and arg == 'None' else arg for arg in args)
        kwargs = {k: None if isinstance(v, str) and v == 'None' else v for k, v in kwargs.items()}
        return func(*args, **kwargs)
    return wrapper


def _load_json(json_filename, events_list):
    json_file = open(json_filename)
    ttidata = json.load(json_file, strict=False)

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
    # if slot_duration_us != df['utcTimestampData.slotDurationUs'].min():
    #     raise RuntimeError('inconsistent slotDurationUS value')
    MAX_SFN = 1023
    SFN_INTERVAL_US = 10000
    max_slot = (SFN_INTERVAL_US / slot_duration_us) - 1

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

    # combine sfn and slot and convert to microseconds unit
    df['sfn_slot'] = ((df['sfn'] * (max_slot + 1)) +
                      df['slot']) * slot_duration_us

    # calculate differences between adjacent events based on sfn + slot
    df['sfn_slot_diff'] = df['sfn_slot'].diff()

    df.iloc[0, df.columns.get_loc('sfn_slot_diff')] = 0

    # fix the places where the SFN wraps around
    df['sfn_slot_diff'] = df['sfn_slot_diff'] % (
        (MAX_SFN + 1) * (max_slot + 1) * slot_duration_us)

    # calculate the accumulated difference between
    # events and convert it to datetime format
    df['accum_diff'] = df['sfn_slot_diff'].cumsum()
    df['accum_diff'] = df['accum_diff'].apply(
        lambda x: timedelta(microseconds=x) if pd.notnull(x) else x)

    # calculate difference between first known timestamp and first event on the trace
    accum_diff_first_timestamp = df[(df['utcTimestampData.utcTimestamp.years'].notnull())]['accum_diff'].iloc[0]
    first_timestamp_value = df[(df['utcTimestampData.utcTimestamp.years'].notnull())]['timeStamp'].iloc[0]
    timestamp_first_event = first_timestamp_value - accum_diff_first_timestamp

    # add found value to all the trace
    df['timeStamp'] = df['accum_diff'] + timestamp_first_event

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
    # Define the order of columns
    col_order_list = ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId']
    columns_order = col_order_list + [col for col in raw_df.columns if col not in col_order_list]
    # Reorder the columns
    beautified_df = raw_df[columns_order]
    return beautified_df


def save_df_to_csv(df, csv_file_name="tti_analysis_uldl.csv", folder_path=""):
    df.to_csv(folder_path + csv_file_name, index=False)


@handle_none_args
def load_tti_trace_as_pandas_dataframe(json_filename, events_list=[]):
    global pd
    import_pandas()
    df = _load_json(json_filename, events_list)
    df = _combine_eventheader_columns(df)
    df = _calculate_timestamps(df)
    df = normalize_nested_arrays(df)
    df = _beautify_df(df)
    return df


def convert_tti_trace_to_df(tti_pcap_file, events_list=[], num_of_events=None, mode=Mode.UNIQUE_FILE):
    tti_json_file = tti_pcap_file.replace("pcap", "json")
    if num_of_events is not None:
        num_of_events = int(num_of_events)
    if os.path.exists("/opt/tti-dec/tti-dec-bin/"):
        if mode == Mode.UNIQUE_FILE:
            tti_extractor.decode_events_using_event_decoder(tti_pcap_file, events_list, num_of_events)
        elif mode == Mode.Multiple_FILE:
            tti_extractor.decode_events_using_multi_decoder(tti_pcap_file, events_list, num_of_events)
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
    # Find nested arrays and put them in the nested cols list
    nested_cols_list = [col_name for col_name in df.columns if any(
        x in col_name for x in ["nestedArray", "ueRecords"])]
    if not nested_cols_list:
        return df
    new_df_list = []
    for col_name in nested_cols_list:
        event_name, nested_field_name = col_name.split('.')
        event_common_col_list = get_event_specific_common_cols(df, event_name, nested_field_name)
        df_col_filt = df[df[col_name].notnull()]
        dataframe_list = nested_array_column_to_list(df_col_filt, col_name, event_common_col_list)
        temp_df = pd.DataFrame(dataframe_list)
        temp_df.columns = [x if x in (common_col_list + event_common_col_list)
                           else '.'.join([event_name, x]) for x in temp_df.columns]
        new_df_list.append(temp_df)
    new_df = pd.concat(new_df_list, axis=0, ignore_index=True)
    complete_df = pd.concat([df, new_df], axis=0, ignore_index=True)
    complete_df = complete_df.drop(complete_df[complete_df[nested_cols_list].notnull().any(axis=1)].index)
    complete_df = complete_df.drop(columns=nested_cols_list)
    complete_df = complete_df.sort_values(by=['timeStamp'], ascending=True)
    return complete_df


def write_df_to_pickle(df, target_path):
    target_path = target_path.replace("pcap", "pkl")
    df.to_pickle(target_path)
