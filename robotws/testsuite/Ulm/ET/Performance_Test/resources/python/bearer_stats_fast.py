import logging
import ute_wtssim
import re
from time import perf_counter
from datetime import datetime
from functools import cache

import pandas as pd


def setup_egate_connection():
    egate_object = ute_wtssim.ute_wtssim()
    egate_object.setup_egate(egate_port=10000, alias="python_egate", save_egate=True)
    return egate_object


def register_all_ues(egate_object):
    for ue_id in range(1, 101):
        register_successful = False
        print(f'running register for ue {ue_id}')
        while not register_successful:
            try:
                register_ue(egate_object, ue_id)
                register_successful = True
            except ute_wtssim.exception.NoRegexpMatch:
                print(f'register failed for ue {ue_id}')


def ue_pdu_session_setup_for_all_ues(egate_object):
    print('pdu_session_setup:\n')
    for ue_id in range(1, 101):
        print(f"session setup for ue {ue_id}")
        register_successful = False
        while not register_successful:
            try:
                setup_pdu_session(egate_object, ue_id)
                register_successful = True
            except ute_wtssim.exception.NoRegexpMatch:
                print(f'pdu setup failed for ue {ue_id}')
                deregister_ue(egate_object, ue_id)
                register_ue(egate_object, ue_id)


def deregister_all_ues(egate_object):
    for ue_id in range(1, 101):
        deregister_successful = False
        while not deregister_successful:
            try:
                deregister_ue(egate_object, ue_id)
                deregister_successful = True
            except ute_wtssim.exception.NoRegexpMatch:
                print(f'deregister ue failed for {ue_id}')


def start_traffic_on_all_ues(egate_object):
    for ue_id in range(1, 101):
        traffic_start_successful = False
        while not traffic_start_successful:
            try:
                start_traffic_on_ue(egate_object, ue_id)
                traffic_start_successful = True
            except ute_wtssim.exception.NoRegexpMatch:
                print(f'start traffic failed {ue_id}')


def stop_traffic_on_all_ues(egate_object):
    for ue_id in range(1, 101):
        traffic_stop_successful = False
        while not traffic_stop_successful:
            try:
                stop_traffic_for_ue(egate_object, ue_id)
                traffic_stop_successful = True
            except ute_wtssim.exception.NoRegexpMatch:
                print(f'traffic stop failed for {ue_id}')


def deregister_ue(egate_object, ue_id):
    egate_object.execute_egate_command_and_wait_for_data(
        alias='python_egate',
        cmd=f"ue_deregister id={ue_id} ue_deregister_type=switch_off",
        pass_regexp="detached")


def register_ue(egate_object, ue_id):
    egate_object.execute_egate_command_and_wait_for_data(
        alias='python_egate',
        cmd=f"ue_register id={ue_id} nwslice=1",
        pass_regexp="Registered state.")


def setup_pdu_session(egate_object, ue_id):
    egate_object.execute_egate_command_and_wait_for_data(
        alias='python_egate',
        cmd=f'ue_pdu_session_setup pdu=1 ue={ue_id} nwslice=1 gw=1',
        pass_regexp=f'Initial Context Setup Successful'
    )


def start_traffic_on_ue(egate_object, ue_id):
    egate_object.execute_egate_command_and_wait_for_data(
        alias='python_egate',
        cmd=f'trf_data_start ue={ue_id} pdu=1 qfi=1 trf_id=2 dir=dl mbps=20',
        pass_regexp="TRF"
    )


def stop_traffic_for_ue(egate_object, ue_id):
    egate_object.execute_egate_command_and_wait_for_data(
        alias='python_egate',
        cmd=f'trf_data_stop ue={ue_id} dir=bi trf_id=1',
        pass_regexp='BI Traffic was stopped||Stopping .* traffic'
    )


def collect_bearer_stats(egate_object, ues, dir='dl', trf_id=2):
    bearer_stats_command = f'script file=bearer_stats.lua entry=collect_bearer_stats("{ues}","{dir}",{trf_id})'
    fail_regex = r'Warning: UE:\d+ qfi stats request will not be send to UPF'
    try:
        bearer_stats = egate_object.execute_egate_command_and_wait_for_data(bearer_stats_command,
                                                                            pass_regexp=r'bearer_stats collected',
                                                                            fail_regexp=fail_regex,
                                                                            alias='python_egate',
                                                                            return_output=True)
    except ute_wtssim.exception.NoRegexpMatch:
        bearer_stats = ''
        logging.error('bearer_stats command failed.')
    return bearer_stats


def extract_data_to_dataframe(incoming_data: str):
    data = [datetime.now().strftime('%d/%m/%Y %H:%M:%S:%s')]
    data.extend(get_decoded_lines(incoming_data.splitlines()))
    tables, timestamp = get_tables(data)
    df = pd.DataFrame()
    ue_infos = []
    for ue in range(0, len(tables)):
        ue_info, series = turn_table_into_series(tables[ue])
        try:
            df[ue_info] = series
            ue_infos.append(ue_info)
        except ValueError:
            with open('/tmp/bearer_stats.txt', 'w') as f:
                f.write(str(series))
            break
    h_columns = [(timestamp, ue_info) for ue_info in ue_infos]
    multi_columns = pd.MultiIndex.from_tuples(h_columns)
    df.columns = multi_columns
    return df


def get_decoded_lines(log_file):
    for line in log_file:
        if line:
            yield line.encode().decode('unicode_escape')
        else:
            continue


def get_tables(decoded_lines):
    pattern_info_line = re.compile(r'UE \d+')
    timestamp = decoded_lines[0]
    table_starts = []
    for index, line in enumerate(decoded_lines):
        if re.search(pattern_info_line, line):
            table_starts.append(index)
    tables = []
    for index, table_start in enumerate(table_starts):
        try:
            tables.append(decoded_lines[table_start:table_starts[index+1]])
        except IndexError:
            tables.append(decoded_lines[table_start:-3])
    return tables, timestamp


def turn_table_into_series(table):
    ue_info_pattern = re.compile(r'UE (\d+).*(DL|UL)')
    ue_info = 'UE_' + '_'.join(re.findall(ue_info_pattern, table[0])[0])
    line_splits = determine_line_split(table[2])  # use second line in logs as it is the header.
    data_labels = []
    values = []
    for line in table[1:]:
        if '-----' in line or '=====' in line:
            continue
        else:
            data_labels.append(line[line_splits[0]:line_splits[1]].strip())
            values.append(line[line_splits[1]:].strip())
    s = pd.Series(values, index=data_labels)
    return ue_info, s


@cache
def determine_line_split(line):
    columns = re.findall(r'\w+', line)
    line_split = []
    for column in columns:
        line_split.append(line.find(column))
    return line_split


def collect_stats_for_all_ues(ues, egate_object):
    full_data_set = []
    for ue_group in ues:
        data = collect_bearer_stats(egate_object, ue_group)
        full_data_set.append(data)
    df = extract_data_to_dataframe('\n'.join(full_data_set))
    return df


def concat_dataframes(dfs, pkl_path='/tmp/bearer_stats.pkl', csv_path=None):
    multi_time_df = pd.concat(dfs, axis=1)
    multi_time_df.to_pickle(pkl_path)
    if csv_path:
        multi_time_df.to_csv(csv_path)
    return pkl_path, csv_path


if __name__ == '__main__':
    egate = setup_egate_connection()
    register = True
    deregister = False
    bearer_stats = True
    if register:
        register_all_ues(egate)
        ue_pdu_session_setup_for_all_ues(egate)
        start_traffic_on_all_ues(egate)
    if deregister:
        deregister_all_ues(egate)

    if bearer_stats:
        with open('/tmp/bearer_stats.txt', 'w') as f:
            f.write('')
        ues = []
        ues.append('1-10')
        dfs = []
        # ues.append('51-100')
        dfs.append(collect_stats_for_all_ues(ues, egate))
        pkl_path = concat_dataframes(dfs)
        print(pkl_path)
        # multi_time_df.to_csv('/tmp/bearer_stats.csv')
        # multi_time_df.to_pickle('/tmp/bearer_stats.pkl')
