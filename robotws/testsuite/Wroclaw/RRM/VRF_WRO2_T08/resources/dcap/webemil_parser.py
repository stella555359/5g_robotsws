import ast
import json
import os
from typing import List, Dict, Any

from robot.api import logger
from taf.sw.dcap.rd.interface import rd

_rd = rd()


def decode_emil_and_save_as_json(folder_path: str, utf_ip: str, port: str) -> List[str]:
    """
    Decodes EMIL files in a specified folder and saves the decoded content as JSON files.
    :param folder_path: Path to the folder containing `.5gm` files.
    :type folder_path: str
    :param utf_ip: IP address of the server to connect for decoding.
    :type utf_ip: str
    :param port: Port number of the server to connect for decoding.
    :type port: str

    :return: A list of paths to decoded files.
    :rtype: List

    Example usage:

    .. code-block:: python

        decode_emil_and_save_as_json(
            folder_path="/path/to/folder",
            utf_ip="192.168.1.100",
            port="9443"
        )
    """
    emil_files = [file for file in os.listdir(folder_path) if file.endswith(('.5gm', 'lcbin'))]
    output_files = []
    _rd.connect_to(str(utf_ip), str(port), username=None, password=None, rd_version='dcapv3', secure=True,
                   timeout=60)
    for file in emil_files:
        try:
            logger.info(f"Webemil decoding {file}")
            file_name = os.path.join(folder_path, file)
            upload_result = _rd.upload_encoded_file(file_name=file_name)
            content = _rd.get_decoded_file_contents_in_json(session_id=upload_result['session_id'],
                                                            data_source_id=upload_result['source_ids'][0],
                                                            tree='n',
                                                            timeout=300)
            file_name = f"{(upload_result['file_names'][0]).split('_')[1]}_{upload_result['session_id']}"
            output_files.append(f"{folder_path}/{file_name}.json")
            save_utf_data_to_json(decoded_content=content, filename=os.path.join(folder_path, file_name + '.json'))
        except Exception as e:
            logger.error(f"failed to get decoded contents: {upload_result['session_id']}: {e}")
        finally:
            _rd.delete_session_data(upload_result['session_id'])
    return output_files


def save_utf_data_to_json(decoded_content: str, filename: str) -> None:
    """
    Saves UTF-8 encoded data to a JSON file.
    :param: decoded_content: A string containing the UTF-8 encoded data to be saved.
    :type decoded_content: str
    :param: filename: The name of the file where the JSON data will be saved.
    :type filename: str

    :return: None
    """
    try:
        if isinstance(decoded_content, str):
            decoded_content = ast.literal_eval(decoded_content)
        with open(filename, "w", encoding="utf-8") as json_file:
            json.dump(decoded_content, json_file, indent=4)
    except Exception as e:
        logger.error(f"Failed to convert decoded content: {filename}: {e}")


def parse_msg_list_from_json_file(file_path: str) -> List[Dict[str, Any]]:
    """
    Parses a JSON file and returns a list of message rows.

    :param file_path: The path to the JSON file to be parsed.
    :type file_path: str
    :return: A list of dictionaries, each representing a row of message data.
    :rtype: List

    Example usage:

    .. code-block:: python

        file_path = "/path/to/emil_data.json"
        messages = return_msg_list_from_json_file(file_path)
    """
    with open(file_path, 'r') as f:
        json_parsed = json.load(f)
    return json_parsed['emil_data']['rows']


def return_merged_jsons_as_msg_list(file_dir: str) -> List[Dict[str, Any]]:
    """
    Parses all JSON files under a directory and returns a list of message rows.

    :param file_dir: The path to the directory JSON files to be parsed.
    :type file_path: str
    :return: A list of dictionaries, each representing a row of message data.
    :rtype: List

    Example usage:

    .. code-block:: python

        file_path = "/path/to/"
        messages = return_merged_jsons_as_msg_list(file_path)
    """
    files = sorted([file for file in os.listdir(file_dir) if file.endswith('.json')])
    msg_list = []
    for file in files:
        with open(os.path.join(file_dir, file), 'r') as f:
            for msg in json.load(f)['emil_data']['rows']:
                msg_list.append(msg)
    return msg_list
