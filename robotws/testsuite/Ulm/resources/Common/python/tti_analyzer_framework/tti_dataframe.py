import json
import logging
import os
import pathlib
import re
import ast
from datetime import datetime
from datetime import timedelta

import pandas as pd
import testsuite.Ulm.resources.Common.python.tti_analyzer_framework.tti_extractor as tti_extractor

COMMON_COL_LIST = ['timeStamp']


def create_dataframe_report(df):
    report = ''
    try:
        start_time = df['timeStamp'].min()
        end_time = df['timeStamp'].max()
        duration = max(df['timeStamp']) - min(df['timeStamp'])
        report += ('TTI trace overview:\n')
        report += (f' Start:    {start_time}\n')
        report += (f' End:      {end_time}\n')
        report += (f' Duration: {duration}\n')
    except ValueError as error:
        logging.error(error)
        logging.error("Dataframe might be empty or some problem with timeStamp generation")
        logging.error(df.info())
    # cells
    cell_list = list(df['physCellId'].unique())
    for cell in cell_list:
        cell_filtred_df = df.query(f'physCellId == {cell}')
        report += (f' cell {cell} with {cell_filtred_df. shape[0]} events\n')
    # get number of events for each rnti
    rnti_list = list(df['rnti'].unique())
    for rnti in rnti_list:
        rnti_filtred_df = df.query(f'rnti == {rnti}')
        report += (f' rnti {rnti} with {rnti_filtred_df. shape[0]} events\n')
    # list of events present in frame
    event_list = list(set(df.columns.str.split('.', n=1).str.get(0)))
    report += (' Events present in dataframe:\n')
    for event in event_list:
        report += (f'   {event}\n')
    return report


def optimize_dypes(df):
    common_byte = ['slot', 'physCellId', 'lcrId', 'emCoreId']
    common_ushort = ['sfn']
    category = ['csiSrReportData.dtx',
                'csiSrReportData.pucchFormat',
                'csiSrReportData.reportType',
                'csiSrReportData.sr',
                'csiSrReportData.ulChannel',
                'csiSrReportData.csiOnPuschMeas.csiPart1CrcCheck',
                'csiSrReportData.csiOnPuschMeas.csiPart2CrcCheck',
                'csiSrReportData.isReportSaved',
                'laIniDelta.event',
                'laIniDelta.id',
                'laTimer.event',
                'laTimer.id',
                'ulBsrRxData.bsrFormat',
                'ulFdSchedData.adaptRetxStatus',
                'ulFdSchedData.isScalingDone',
                'ulFdSchedData.isValidWhatIsProposed',
                'ulFdSchedData.isRequiringMorePower',
                'ulFdSchedData.isInPowerSplitMode',
                'ulFdSchedData.isDefaultMcsProposed',
                'ulFdSchedData.isValidWhatIsProposed',
                'ulFdSchedData.dciFormat',
                'ulFdSchedData.aperCsiPriority',
                'ulFdSchedData.numOfLayers',
                'ulFdSchedData.mcsTable',
                'ulFdSchedData.ptrsFlagUlProposedMcs',
                'ulFdSchedData.ulMimoMode',
                'ulFdSchedData.ueType',
                'ulFdSchedData.ulMuGroupStatus',
                'ulFdSchedData.ulMuStatus',
                'ulFdSchedData.ulProGrantType',
                'ulLaDeltaSinr.isDeltaSinrCalculated',
                'ulLaPhr.isRrmPhrScaledCalculated',
                'ulLaPhr.isVPhr',
                'ulHarqRxData.crcResult',
                'ulHarqRxData.dtx',
                'ulLoadControlData.measurementInfo.loadType',
                'ulPduDemuxData.isTcpTraffic',
                'ulPduDemuxData.isUlCcchData',
                'ulLaAverageSinr.rrmInstSinrRank',
                'ulLaDeltaSinr.crcFb',
                'ulLaDeltaSinr.targetBlerType',
                'ulPreSchedData.csListEvent',
                'ulPucchReceiveRespPsData.dtx',
                'ulTdSchedSubcellData.muStatus',
                'dlFdSchedData.adaptRetxStatus',
                'csiSrReportData.radioLinkFailureStatus',
                'dlFdSchedData.adaptRetxStatus',
                'dlFdSchedData.beamType',
                'dlFdSchedData.dciFormat',
                'dlFdSchedData.ackNack',
                'dlFdSchedData.speculativeDtxAckDtx',
                'dlFdSchedData.mcsTable',
                'dlFdSchedData.muStatus',
                'dlFdSchedData.numOfLayers',
                'dlFdSchedData.ptrsFlagDlProposedMcs',
                'dlFdSchedData.ueType',
                'dlFdSchedData.laMode',
                'dlFdSchedData.isDefaultMcsProposed',
                'dlFdSchedData.isRetxDownGradeNewTx',
                'dlFlowControlData.reportType',
                'dlFdSchedData.isScalingDone',
                'dlFdSchedData.isValidWhatIsProposed',
                'dlHarqRxDataArray.speculativeDtxAckDtx',
                'dlHarqRxDataArray.radioLinkFailureStatus',
                'dlHarqRxDataArray.pucchFormat',
                'dlHarqRxDataArray.dtx',
                'dlHarqRxDataArray.ackNack',
                'dlLaAverageCqi.rank',
                'dlLaDeltaCqiArray.harqFb',
                'dlLaDeltaCqiArray.isDeltaCqiCalculated',
                'dlLoadControlData.measurementInfo.loadType',
                'dlPagingOrSibSchedData.dciFormat',
                'dlPagingOrSibSchedData.numOfLayers',
                'dlPreSchedData.csListEvent',
                'dlTdSchedSubcellData.muStatus',
                'dlBeamData.isBeamRecovery',
                'dlBeamData.isUeReported',
                ]
    logging.debug('Before dtypes optimization:')
    logging.debug(df.info())
    for col in df.columns:
        if col in common_byte:
            df[col] = df[col].astype('byte')
        elif col in common_ushort:
            df[col] = df[col].astype('ushort')
        elif col in category:
            try:
                df[col] = df[col].astype('category')
            except Exception as err:
                logging.debug(err)
                logging.debug('column cannot be converted: %s', col)
        elif 'float64' in str(df[col].dtype):
            df[col] = df[col].astype('float32')
    logging.debug('After dtypes optimization:')
    logging.debug(df.info())
    return df


def _load_legacy_json_trace(json_filename, events_list, optimize_dtypes=False):
    json_file = open(json_filename)
    ttidata = json.load(json_file)

    if events_list:
        events_list.append('utcTimestampData')
        ttidata = pd.DataFrame.from_dict(ttidata, orient='columns')
        ttidata = ttidata[ttidata.events.astype(str).str.contains('|'.join(events_list))]

    events_data = ttidata['events']
    if isinstance(events_data, pd.Series):
        events_data = events_data.tolist()
    tti_df_normalized = pd.json_normalize(events_data)
    if optimize_dtypes:
        tti_df_normalized = optimize_dypes(tti_df_normalized)
    return tti_df_normalized


def _update_common_col_lists_with_header_elements(df):
    global COMMON_COL_LIST
    new_col_set = {colname.split('.')[-1] for colname in df.columns if 'eventHeader' in colname}
    COMMON_COL_LIST = COMMON_COL_LIST + list(new_col_set)
    return list(new_col_set)


def _combine_eventheader_columns(df):
    new_col_list = _update_common_col_lists_with_header_elements(df)
    df.columns = df.columns.str.replace('.body', '', regex=False)
    df.columns = df.columns.str.replace('.eventHeader', '', regex=False)
    return _collapse_columns_by_suffix(df, new_col_list)


def _combine_eventheader_columns_l2lo(df):
    df.columns = df.columns.str.replace('.body', '', regex=False)
    df.columns = df.columns.str.replace('.header', '', regex=False)
    df.columns = df.columns.str.replace('.identifier', '', regex=False)
    return _collapse_columns_by_suffix(df, ["sfn", "slot", "rnti", "physCellId", "lcId"])


def _collapse_columns_by_suffix(df, suffixes):
    """
    Collapse all columns matching ``.*.<suffix>`` into one column per suffix.
    This avoids repeated insert/drop operations that heavily fragment DataFrames.
    """
    collapsed_columns = {}
    columns_to_drop = []

    for suffix in suffixes:
        regex_pat = re.compile(r'.*\.' + re.escape(suffix) + r'$')
        matched_cols = [col_name for col_name in df.columns if regex_pat.match(col_name)]
        if not matched_cols:
            continue
        collapsed_columns[suffix] = df[matched_cols].max(axis=1)
        columns_to_drop.extend(matched_cols)

    if columns_to_drop:
        df = df.drop(columns=list(dict.fromkeys(columns_to_drop)))

    if collapsed_columns:
        collapsed_df = pd.DataFrame(collapsed_columns, index=df.index)
        df = pd.concat([df, collapsed_df], axis=1)

    return df


def _is_slot_duration_consistent(df):
    slot_duration_col = 'utcTimestampData.slotDurationUs'
    if slot_duration_col not in df.columns:
        return False
    return df[slot_duration_col].max() == df[slot_duration_col].min()


def _derive_timestamp_from_utc_timestamp_column(df):
    """
    Build the `timeStamp` column from `utcTimeStamp` when utcTimestampData fields
    are not available in the decoded input.
    """
    if 'utcTimeStamp' not in df.columns:
        return df

    raw_timestamp = df['utcTimeStamp']
    df['timeStamp'] = pd.to_datetime(raw_timestamp)
    nblocks = getattr(getattr(df, "_mgr", None), "nblocks", 0)
    if isinstance(nblocks, int) and nblocks > 128:
        # Defragment once before adding new columns to avoid repetitive warnings
        # and expensive block operations on highly fragmented frames.
        df = df.copy()
    return df


def _calculate_timestamps(df):
    """
    Calculates the timestamp for each event using the utcTimestampData event
    as reference. The only event with the utc timestamp information is the
    utcTimestampData event. Using one of these events and the sfn/slot in all the
    other events, we calculate a timestamp for each row of the dataframe, since
    the slot duration is also present in that same event (utcTimestampData.slotDurationUs)
    After this function is called a new column is added to the dataframe
    called timeStamp which contains the calculated time stamp.

    :param df: tti trace dataframe
    :return: the dataframe with new column called timeStamp
    """
    slot_duration_us = df['utcTimestampData.slotDurationUs'].max()
    if slot_duration_us != df['utcTimestampData.slotDurationUs'].min():
        raise RuntimeError('inconsistent slotDurationUS value')
    MAX_SFN = 1023
    SFN_INTERVAL_US = 10000
    max_slot = (SFN_INTERVAL_US / slot_duration_us) - 1

    # using hfn, sfn, slot make sure events are in sequence
    df['hfn_sfn_slot'] = ((df['hfnTickCount'] * (MAX_SFN + 1) * (max_slot + 1)) +
                          (df['sfn'] * (max_slot + 1)) +
                          df['slot'])
    df = df.sort_values(by=['hfn_sfn_slot', 'rnti'])

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

    # calculate difference between first known timestamp and first
    # event on the trace
    # note: filter for rnti null selects the utcTimestampData events
    accum_diff_first_timestamp = df[df['utcTimestampData.utcTimestamp.years'].notnull()]['accum_diff'].iloc[0]
    first_timestamp_value = df[df['utcTimestampData.utcTimestamp.years'].notnull()]['timeStamp'].iloc[0]
    timestamp_first_event = first_timestamp_value - accum_diff_first_timestamp

    # add found value to all the trace
    df['timeStamp'] = df['accum_diff'] + timestamp_first_event

    # remover helper columns
    columns_to_delete_list = [
        'sfn_slot',
        'sfn_slot_diff',
        'accum_diff']
    df.drop(columns=columns_to_delete_list, inplace=True)
    utc_ref_mask = df['utcTimestampData.utcTimestamp.years'].notnull()
    utc_cols = list(df.filter(regex='utcTimestampData'))
    df.drop(columns=utc_cols, inplace=True)
    df.drop(df[utc_ref_mask].index, inplace=True)
    return df


def _split_cells_calculate_timestamps(df):
    df_list = []
    logging.debug('Inconsistent slot duration. Calculating timestamps for each cell separately')
    # get cells in trace
    cell_list = list(df['lcrId'].unique())
    logging.debug('Cells in trace (lcrId): %s ', str(cell_list))
    # for each cell calculate timestamps and add to list
    for cell in cell_list:
        logging.debug('Calculating timestamp for cell: %s', str(cell))
        df_list.append(_calculate_timestamps(df.query(f'lcrId == {cell}').copy()))
    # concatenate df from each cell and order according to timestamp
    df = pd.concat(df_list)
    df.sort_values(by=['timeStamp', 'rnti'], inplace=True)
    return df


def merge_rows_common_header(df):
    """
    Merges rows with same header information in same row. Enables much better
    data analysis. To be able to use this procedure we assume that there are
    NO 2 events occouring in same timestamp (sfn, slot) with same rnti, cellid
    and lcrId. If that happens we need to add here some IE(information element)
    that can be used to create a unique combination with the rest of the header IEs
    This happens with the dlLaDeltaCqiArray and dlHarqRxDataArray, so below you can see
    how the dlHarqProcessIndex is added for these 2 events for the merge operation.
    If this happens in the future with more events, similar procedure needs to be
    implemented.

    :param df: tti trace dataframe
    :return: the dataframe with rows with same header information merged in same row
    """
    header_cols = ['timeStamp', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId']
    # Since some dl events have nested events inside we need to add extra information elements
    # to  avoid loosing events
    events_same_header_unique_ie = ['dlLaDeltaCqiArray.dlHarqProcessIndex',
                                    'dlHarqRxDataArray.dlHarqProcessIndex',
                                    'ulLaSwitchBetweenHrAndBr.event']
    # we only add these elements if they exist in the dataframe
    for information_element in events_same_header_unique_ie:
        if information_element in df.columns:
            header_cols.append(information_element)
    return df.groupby(header_cols, dropna=False).aggregate("first").reset_index()


def _beautify_df(raw_df):
    # Add timestamp, hfn, sfn, slot, etc in front of the table
    columns_to_remove = ['timeStamp', 'hfnTickCount', 'sfn', 'slot', 'rnti', 'lcrId', 'physCellId']
    concat_df = raw_df[columns_to_remove]
    raw_df.drop(columns_to_remove, axis=1, inplace=True)
    raw_df = pd.concat([concat_df, raw_df], axis=1)
    return raw_df


def save_df_to_csv(df, csv_file_name="tti_analysis_uldl.csv", folder_path=""):
    df.to_csv(folder_path + csv_file_name, index=False)


def _build_event_kind_regex(events_list):
    if not events_list:
        return None
    required_events = set(events_list)
    required_events.add('utcTimestampData')
    regex_pattern = '|'.join(re.escape(event_name) for event_name in sorted(required_events))
    return re.compile(regex_pattern)


def _stream_event_filtered_csv_chunks(csv_file, events_regex=None, chunksize=50000):
    for chunk_df in pd.read_csv(csv_file, chunksize=chunksize, low_memory=False):
        if events_regex is not None and 'kind' in chunk_df.columns:
            event_mask = chunk_df['kind'].astype(str).str.contains(events_regex, na=False)
            chunk_df = chunk_df[event_mask]
        if not chunk_df.empty:
            yield chunk_df


def _post_process_loaded_tti_df(df, optimize_dtypes=False):
    df = _combine_eventheader_columns(df)
    if 'utcTimestampData.slotDurationUs' in df.columns and _is_slot_duration_consistent(df):
        df = _calculate_timestamps(df)
    elif 'utcTimestampData.slotDurationUs' in df.columns:
        df = _split_cells_calculate_timestamps(df)
    else:
        df = _derive_timestamp_from_utc_timestamp_column(df)
        timestamp_error = (
            "Unable to derive 'timeStamp'. Expected either "
            "'utcTimestampData.slotDurationUs' or a usable 'utcTimeStamp' column."
        )
        if 'timeStamp' not in df.columns or not bool(df['timeStamp'].notna().any()):
            raise ValueError(timestamp_error)
    df = normalize_nested_arrays(df)
    df = merge_rows_common_header(df)
    df = _beautify_df(df)
    if optimize_dtypes:
        df = optimize_dypes(df)
    return df


def load_tti_trace_as_pandas_dataframe(parquet_csv_directory, events_list=[], optimize_dtypes=False):
    """
    Load TTI trace from parquet-derived CSV files into a pandas DataFrame.

    Expects a directory containing *_parqCsv_*.csv files (decoder output from
    pcap-to-parquet-to-CSV conversion, e.g. via convert_pcap_to_parquetCsv).
    Example File name: ttitrace_streaming_000_pcap_parqCsv_dl_000.csv

    :param parquet_csv_directory: path to directory containing *_parqCsv_*.csv files
    :param events_list: list of event kind names to filter (empty = all events)
    :param optimize_dtypes: if True, reduce memory usage via dtype optimization
    :return: DataFrame with normalized TTI trace and derived timeStamp column
    """
    df_list = []
    events_regex = _build_event_kind_regex(events_list)

    base_dir = pathlib.Path(parquet_csv_directory)
    csv_files = sorted(base_dir.glob("*_parqCsv_*.csv"))

    logging.debug("parquetCsv input directory: %s", base_dir)
    logging.debug("parquetCsv csv_files_count=%s", len(csv_files))

    for csv_file in csv_files:
        for chunk_df in _stream_event_filtered_csv_chunks(str(csv_file), events_regex=events_regex):
            df_list.append(chunk_df)
    if not df_list:
        raise ValueError(
            f"No usable CSV rows found under '{parquet_csv_directory}'. "
            "Ensure decoder output path/options are correct and event filters match available kinds."
        )

    df: pd.DataFrame = pd.concat(df_list, axis=0, ignore_index=True)
    return _post_process_loaded_tti_df(df, optimize_dtypes=optimize_dtypes)


def load_tti_trace_from_parquet(parquet_directory, events_list=[], optimize_dtypes=False):
    """
    Load TTI trace from parquet files into a pandas DataFrame.

    Expects a directory containing ``*.parquet`` files (decoder output from
    convert_pcap_to_parquet).
    """
    df_list = []
    events_regex = _build_event_kind_regex(events_list)
    base_dir = pathlib.Path(parquet_directory)
    parquet_files = sorted(base_dir.glob("*.parquet"))
    if not parquet_files:
        parquet_files = sorted(base_dir.rglob("*.parquet"))

    for parquet_file in parquet_files:
        parquet_df = pd.read_parquet(parquet_file)
        if events_regex is not None and 'kind' in parquet_df.columns:
            event_mask = parquet_df['kind'].astype(str).str.contains(events_regex, na=False)
            parquet_df = parquet_df[event_mask]
        if not parquet_df.empty:
            df_list.append(parquet_df)

    if not df_list:
        raise ValueError(
            f"No usable parquet rows found under '{parquet_directory}'. "
            "Ensure decoder output path/options are correct and event filters match available kinds."
        )

    df: pd.DataFrame = pd.concat(df_list, axis=0, ignore_index=True)
    return _post_process_loaded_tti_df(df, optimize_dtypes=optimize_dtypes)


def load_tti_l2lo_trace_as_pandas_dataframe(tti_json_file, events_list=[], optimize_dtypes=False):
    df = _load_legacy_json_trace(tti_json_file, events_list, optimize_dtypes)
    df = _combine_eventheader_columns_l2lo(df)
    if optimize_dtypes:
        df = optimize_dypes(df)
    return df


def convert_tti_trace_to_df(tti_pcap_file, events_list=[], optimize_dtypes=False,
                            filter_json_flag=True, eventdecoder_stdout_path='',
                            filter_events=None, decode_format='parquet'):
    """
    Converts TTI trace in pcap format to pandas dataframe. In this conversion the events
    are converted into a pandas dataframe. Also events with same timestamp are merged into same row

    :param tti_pcap_file: tti trace pcap filename including path
    :param events_list: list with tti events to be used in filter
    :param optimize_dtypes: use this when dataframe is too big
    :param filter_json_flag: legacy flag name kept for backward compatibility
    :param eventdecoder_stdout_path: std_output.log filename including path
    :param filter_events: True to filter requested events during decode
    :param decode_format: twdecoder output format ('parquetCsv' or 'parquet')
    :return: the dataframe with timestamps
    """
    filter_requested_events = (
        bool(events_list) and
        (bool(filter_events) if filter_events is not None else bool(filter_json_flag))
    )
    if decode_format == 'parquet':
        tti_trace_directory = tti_extractor.convert_pcap_to_parquet(
            tti_pcap_file,
            events_list,
            filter_parquet_flag=filter_requested_events,
            stdout_path=eventdecoder_stdout_path or "",
        )
        logging.debug(tti_trace_directory)
        return load_tti_trace_from_parquet(tti_trace_directory, events_list, optimize_dtypes)
    if decode_format == 'parquetCsv':
        tti_trace_directory = tti_extractor.convert_pcap_to_parquetCsv(
            tti_pcap_file,
            events_list,
            filter_parquet_flag=bool(filter_events) and bool(events_list),
            stdout_path=eventdecoder_stdout_path or "",
        )
        logging.debug(tti_trace_directory)
        return load_tti_trace_as_pandas_dataframe(tti_trace_directory, events_list, optimize_dtypes)
    raise ValueError("decode_format must be 'parquetCsv' or 'parquet'")


def convert_tti_l2lo_trace_to_df(tti_pcap_file, events_list=[], optimize_dtypes=False,
                                 max_num_events_json=200000, filter_json_flag=False,
                                 eventdecoder_stdout_path=''):
    """
    Converts l2lo TTI trace in pcap format to pandas dataframe. In this conversion the l2lo events
    are converted into a pandas dataframe.

    :param tti_pcap_file: tti trace with l2lo component pcap filename including path
    :param events_list: list with tti events to be used in filter
    :param optimize_dtypes: use this when dataframe is too big
    :param max_num_events_json: tti trace dataframe
    :param filter_json_flag: True to filter when converting from pcap to intermediate json
    :param eventdecoder_stdout_path: std_output.log filename including path
    :return: the l2lo dataframe
    """
    # convention used is that l2lo file has same name as tti_pcap_file, replacing '.pcap' by '_Lo.json'
    l2lo_filename = tti_pcap_file.replace('.pcap', '_Lo.json')
    # if l2lo json does not exist means the tti trace was not
    # converted previously (e.g. for l2lps) and needs to be converted
    if not os.path.isfile(l2lo_filename):
        tti_extractor.convert_pcap_to_json(tti_pcap_file,
                                           events_list,
                                           filter_json_flag=filter_json_flag,
                                           eventdecoder_options=f'--split {max_num_events_json}',
                                           eventdecoder_stdout_path=eventdecoder_stdout_path)

    if not os.path.isfile(l2lo_filename):
        logging.error(str(l2lo_filename) + ' not found!')
    df = load_tti_l2lo_trace_as_pandas_dataframe(l2lo_filename, events_list, optimize_dtypes)
    df.columns = df.columns.str.replace('.body', '', regex=False)
    df.columns = df.columns.str.replace('.header', '', regex=False)
    df.columns = df.columns.str.replace('.identifier', '', regex=False)
    return df


def _parse_nested_array_value(val):
    """Parse nested array value to list of dicts; returns [] for invalid/empty."""
    if val is None or (isinstance(val, float) and pd.isna(val)):
        return []
    if isinstance(val, str):
        try:
            val = ast.literal_eval(val)
        except (ValueError, SyntaxError):
            return []
    if isinstance(val, dict):
        return [val]
    if isinstance(val, (list, tuple)):
        return [x for x in val if isinstance(x, dict)]
    return []


def nested_array_column_to_list(df, nested_array_colname, event_common_col_list):
    common_columns = COMMON_COL_LIST + event_common_col_list
    dataframe_list = []
    selected_columns = [nested_array_colname] + [col for col in common_columns if col in df.columns]
    for row in df[selected_columns].to_dict('records'):
        for nested_dict in _parse_nested_array_value(row.get(nested_array_colname)):
            out = dict(nested_dict)
            for col in common_columns:
                if col not in out:
                    out[col] = row.get(col)
            dataframe_list.append(out)

    return dataframe_list


def get_event_specific_common_cols(df, event_name, nested_field):
    return [col_name for col_name in df.columns if event_name in col_name and nested_field not in col_name]


def _rename_parquet_flattened_nested_columns(df):
    """
    Parquet decoder outputs flattened nestedArray as scalars per row with names like
    event.nestedArray[i].field. Rename to event.field so data is preserved and
    normalize_nested_arrays won't incorrectly drop these rows (it expects list/dict).
    """
    rename_map = {}
    for col_name in df.columns:
        if '.nestedArray[i].' in col_name:
            new_name = col_name.replace('.nestedArray[i].', '.')
            rename_map[col_name] = new_name
        elif '[i]' in col_name:
            new_name = col_name.replace('[i]', '')
            rename_map[col_name] = new_name
    if rename_map:
        df = df.rename(columns=rename_map)
    return df


def normalize_nested_arrays(df):
    df = _rename_parquet_flattened_nested_columns(df)
    # find nested arrays and put them in the nested cols list
    nested_cols = ["nestedArray", "ueRecords"]
    nested_cols_list = [
        col_name for col_name in df.columns
        if len(col_name.split('.')) == 2 and col_name.split('.')[1] in nested_cols
    ]

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
        temp_df.columns = [x if x in (COMMON_COL_LIST + event_common_col_list)
                           else '.'.join([event_name, x]) for x in temp_df.columns]
        # store the dataframes into list to be joined later
        new_df_list.append(temp_df)

    # keep only rows that do not contain nested arrays, then append expanded rows
    base_df = df[df[nested_cols_list].isnull().all(axis=1)].drop(columns=nested_cols_list)
    new_df = pd.concat(new_df_list, axis=0, ignore_index=True)
    complete_df = pd.concat([base_df, new_df], axis=0, ignore_index=True)

    # sort by timeStamp with hierarchical fallback for ties
    timing_cols = ['hfnTickCount', 'sfn', 'slot']
    sort_cols = ['timeStamp'] + [col for col in timing_cols if col in complete_df.columns]
    complete_df = complete_df.sort_values(by=sort_cols, ascending=True)

    return complete_df


def _unnest_scheduledBearers(scheduledBearers):
    """
    This function helps to  unnest the dlFdScheData.scheduledBearers column.
    This funcion receives as argument the contents of a singe cell of the
    dlFdScheData.scheduledBearers column. Look the documentation of
    unnest_dlFdSchedData_scheduledBearers for further details.

    :param scheduledBearers: content of the cell of the column dlFdSchedData.scheduledBearers
    :return: dictionary which keys are the new column names
    """
    event = "dlFdSchedData."
    # remove invalid lcIds and turn strings into dictionary
    clean_dict_list = [k for k in ast.literal_eval(str(scheduledBearers)) if k['lcId'] != 255]
    # rename dictionary keys according to lcId and discard keys not relevant
    relevant_keys = ['scheduledBytesPerBearer', 'remainingBytesPerBearerInFdEoBuffer', 'rlcStatusPduLength']
    new_dict = {}
    for clean_dict in clean_dict_list:
        lcId = clean_dict['lcId']
        for key, val in clean_dict.items():
            if key in relevant_keys:
                new_dict[event + key + f'[{lcId}]'] = val
    return new_dict


def unnest_dlFdSchedData_scheduledBearers(df):
    """
    This function unnests the dlFdScheData.scheduledBearers column.
    The contents of this column are a list of dictionaries as the example below
        {'lcId': 1,
         'bsrSlot': 0,
         'bsrSfn': 439,
         'scheduledBytesPerBearer': 388,
         'remainingBytesPerBearerInFdEoBuffer': 0,
         'rlcStatusPduLength': 0}
    The format of the cell is originally a string. So it must be first converted
    to the correct data structure. List of dictionaries.
    Only the keys scheduledBytesPerBearer, remainingBytesPerBearerInFdEoBuffer and
    rlcStatusPduLength will be expanded into own columns.
    Since there are many of these dictionaries, each new column name will have in
    the end the lcId inside square brackets e.g. scheduledBytesPerBearer[1]
    Because of that, lcId must be unique.
    Dictionaries with lcId 255 are considered invalid and discarded

    :param df: tti trace dataframe
    :return: the complete dataframe with unnested dlFdSchedData scheduledBearers
    """
    # select only dlFdSchedData events
    local_df = df[df['dlFdSchedData.scheduledBearers'].notna()]

    # select columns dlFdSchedData.scheduledBearers, timestamp, physCellId, rnti, lcrd
    local_df = local_df[['dlFdSchedData.scheduledBearers', 'dlFdSchedData.dlHarqProcessIndex',
                         'timeStamp', 'rnti', 'lcrId', 'physCellId']]

    # Create a list to store the unnested data
    unnested_data = []

    # Iterate over the rows of the DataFrame
    for _, row in local_df.iterrows():
        # Unnest the scheduledBearers column
        unnested_dict = _unnest_scheduledBearers(row['dlFdSchedData.scheduledBearers'])
        # Create a new dictionary with the unnested data and other relevant columns
        new_row = {
            'timeStamp': row['timeStamp'],
            'rnti': row['rnti'],
            'lcrId': row['lcrId'],
            'physCellId': row['physCellId'],
            'dlFdSchedData.dlHarqProcessIndex': row['dlFdSchedData.dlHarqProcessIndex'],
            **unnested_dict
        }
        # Append the new row to the list
        unnested_data.append(new_row)

    # Create a new DataFrame from the unnested data
    unnested_df = pd.DataFrame(unnested_data)

    # Merge the unnested DataFrame with the original DataFrame
    return df.merge(unnested_df, on=['timeStamp', 'rnti', 'lcrId', 'physCellId', 'dlFdSchedData.dlHarqProcessIndex'],
                    how='outer')


def write_df_to_pickle(df, target_path):
    target_path = os.path.splitext(target_path)[0] + ".pkl"
    df.to_pickle(target_path)


if __name__ == "__main__":
    df = load_tti_trace_as_pandas_dataframe('./traces', events_list=[])
    save_df_to_csv(df)
    print(df)
