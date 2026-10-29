# -*- coding: utf-8 -*-
"""
Author: caoge
Contacts: ge.cao@nokia-sbell.com
Description: this script is used to analyze cell trace logs
"""
import re
import os.path
from taf.sw.dcap.rd import rd
from robot.api import logger
import logging
import json
import ast
from log_metadata import *
from common_utils import run_local_command, extract_files_from_zip_file
from common_log_analysis import check_rules_from_csv_file


rd = rd()


def check_cell_trace_logs(log_path, analysis_dict=None, filter_cell_trace=None, convert_type="csv"):
    """
    *Usage:*
        - Keyword
        - Filter the content from cell trace logs based on specific conditions and save it to JSON or CSV files.
    *Contact:*
        - ge.cao@nokia-sbell.com
    """
    log_directory = get_log_directory(log_path)
    file_paths = extract_files_from_zip_file(log_path, log_directory, postfix='.lcbin')
    print(f"file_paths is {file_paths}")
    output_file = decode_emil_to_save_as_file(emil_files=file_paths, convert_type=convert_type,
                                              filter_emil=filter_cell_trace)
    return output_file


def save_utf_data_to_json_file(decoded_content: str, filename: str) -> None:
    try:
        if isinstance(decoded_content, str):
            decoded_content = ast.literal_eval(decoded_content)
        with open(filename, "w", encoding="utf-8") as json_file:
            json.dump(decoded_content, json_file, indent=4)
    except Exception as e:
        logger.error(f"Failed to convert decoded content: {filename}: {e}")


def decode_emil_to_save_as_file(emil_files, convert_type="json", utf_ip="127.0.0.1", port="9443", connection="dcap_con",
                                filter_emil=None):
    output_files = []
    res = rd.connect_to(utf_ip, port=port, username=None, password=None, rd_version='dcapv3', secure=True,
                        alias=connection, timeout=60)
    for file in emil_files:
        logger.info(f"emil decoding {file}")
        file_directory, file_initial_name = os.path.split(file)
        if convert_type == "json":
            output_files = convert_decoded_file_to_json(file_directory, output_files, file, connection,
                                                        filter_emil=filter_emil)
        elif convert_type == "csv":
            output_files = convert_decoded_file_to_csv(file_directory, file, output_files, connection,
                                                       filter_emil=filter_emil)
    return output_files


def convert_decoded_file_to_json(file_directory, output_files, file, connection, filter_emil=None):
    try:
        upload_result = rd.upload_encoded_file(file_name=file, connection=connection)
        content = rd.get_decoded_file_contents_in_json(session_id=upload_result['session_id'],
                                                       data_source_id=upload_result['source_ids'][0],
                                                       connection=connection,
                                                       tree='n',
                                                       timeout=300,
                                                       filter=filter_emil)
        file_name = f"{(upload_result['file_names'][0]).split('_')[1]}_{upload_result['session_id']}"
        output_files.append(f"{file_directory}/{file_name}.json")
        save_utf_data_to_json_file(decoded_content=content, filename=os.path.join(file_directory, file_name + '.json'))
    except Exception as e:
        logger.error(f"failed to get decoded contents: {upload_result['session_id']}: {e}")
    finally:
        rd.delete_session_data(upload_result['session_id'], connection=connection)
    return output_files


def convert_decoded_file_to_csv(file_directory, file_name, output_files, connection="dcap_con", what="source",
                                filter_emil=None):
    upload_result = rd.upload_encoded_file(file_name=file_name, connection=connection)
    assert upload_result['operation_status'].lower() == 'success', 'Upload encoded file operation is not success'
    emil_data = rd.get_decoded_file_contents_in_csv(session_id=upload_result['session_id'],
                                                    data_source_id=upload_result['source_ids'][0],
                                                    what=what,
                                                    connection=connection,
                                                    timeout=300,
                                                    filter=filter_emil)
    file_name = f"{(upload_result['file_names'][0]).split('_')[1]}_{upload_result['session_id']}"
    output_files.append(f"{file_directory}/{file_name}.csv")
    with open(os.path.join(file_directory, file_name + '.csv'), 'w') as f:
        f.write(emil_data)
    rd.delete_session_data(session_id=upload_result['session_id'], connection=connection)
    assert len(output_files) > 0, 'There is no output file generated'
    return output_files
