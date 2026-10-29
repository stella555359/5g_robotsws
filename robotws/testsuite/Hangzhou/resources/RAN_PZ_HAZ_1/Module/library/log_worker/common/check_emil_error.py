# -*- coding: utf-8 -*-
"""
Author: caoge
Contacts: ge.cao@nokia-sbell.com
Description: this script is used to analyze emil logs
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


def check_emil_error_logs(log_path, analysis_dict=None,
                          product_type=None, **kwargs):
    """
    *Usage:*
        - Keyword
        - Filter the content from emil logs based on specific conditions and save it to JSON or CSV files.
    *Contact:*
        - ge.cao@nokia-sbell.com
    """
    input_error_list = kwargs.get('input_error_list')
    expect_status = kwargs.get('expect_status')
    if input_error_list is None:
        raise ValueError("Missing required parameter: input_error_list")
    if product_type is None:
        log_metadata = load_log_metadata(log_path)
        product_type = log_metadata['product_type']
    log_directory = get_log_directory(log_path)
    if product_type in ['gnb', 'vdu', 'vcu'] and log_path.endswith('.zip'):
        file_paths = extract_files_from_zip_file(log_path, log_directory, postfix='.5gm')
        print(f"file_paths is {file_paths}")
        output_file = decode_emil_to_save_as_file(emil_files=file_paths)
    elif product_type in ['enb'] and log_path.endswith('.zip'):
        file_paths = extract_files_from_zip_file(log_path, log_directory, postfix='.emil')
        print(f"file_paths is {file_paths}")
        output_file = decode_emil_to_save_as_file(emil_files=file_paths)
    with open(output_file[0], 'r', encoding="utf-8") as file:
        content = json.load(file)
    real_error_list = content["emil_data"]["summary"]["values"]
    status = check_element_in_lists(input_error_list, real_error_list)
    if status == expect_status:
        return content
    else:
        raise AssertionError(content)


def check_element_in_lists(input_list, real_list):
    for element in input_list:
        if element in real_list:
            return True
    return False


def save_utf_data_to_json_file(decoded_content: str, filename: str) -> None:
    try:
        if isinstance(decoded_content, str):
            decoded_content = ast.literal_eval(decoded_content)
        with open(filename, "w", encoding="utf-8") as json_file:
            json.dump(decoded_content, json_file, indent=4)
    except Exception as e:
        logger.error(f"Failed to convert decoded content: {filename}: {e}")


def decode_emil_to_save_as_file(emil_files, utf_ip="127.0.0.1", port="9443", connection="dcap_con"
                                ):
    output_files = []
    res = rd.connect_to(utf_ip, port=port, username=None, password=None, rd_version='dcapv3', secure=True,
                        alias=connection, timeout=60)
    file_directory, file_initial_name = os.path.split(emil_files[0])
    output_files = convert_decoded_file_to_json(file_directory, output_files, emil_files, connection)
    return output_files


def convert_decoded_file_to_json(file_directory, output_files, files, connection):
    try:
        upload_result = rd.upload_encoded_file(file_name=files, connection=connection)
        content = rd.get_decoded_file_contents_in_json(session_id=upload_result['session_id'],
                                                       # data_source_id=upload_result['source_ids'][0],
                                                       data_source_id=upload_result['grid_ids'][0],
                                                       what='calls',
                                                       connection=connection,
                                                       timeout=300,
                                                       column="Errors")
        file_name = f"{(upload_result['file_names'][0]).split('_')[1]}_{upload_result['session_id']}"
        output_files.append(f"{file_directory}/{file_name}.json")
        save_utf_data_to_json_file(decoded_content=content, filename=os.path.join(file_directory, file_name + '.json'))
    except Exception as e:
        logger.error(f"failed to get decoded contents: {upload_result['session_id']}: {e}")
    finally:
        rd.delete_session_data(upload_result['session_id'], connection=connection)
    return output_files
