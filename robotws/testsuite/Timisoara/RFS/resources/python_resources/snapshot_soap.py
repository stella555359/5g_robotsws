from taf.ul.verify_snapshot.interface import verify_snapshot
from dateutil import parser
import datetime
import zipfile
import gzip
import tarfile
import re
import shutil
import os
import io

import logging

DEFAULT_FILE_NAME_REGEX = r".*SOAP.*(TraceCFG|Log).*[.]xml[.]gz"
DEFAULT_TIMESTAMP_REGEX = r"(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[.]{0,1}\d{0,3}Z)"
logging.basicConfig(level=logging.INFO)


def extract_file_from_zip_by_path(outer_zip_path, virtual_path, output_path):
    """
    Used
    Extracts a file from a nested ZIP archive using a full file path:
    'inner1.zip/inner2.zip/file.txt'
    """

    path_parts = virtual_path.split('/')
    current_zip_data = open(outer_zip_path, 'rb').read()
    current_tar_data = ""
    carry = ''
    # logging.debug("==============================================================================")
    # logging.debug(f"================ New File Analysis: {virtual_path} ==========================")
    # logging.debug("==============================================================================")
    for i, part in enumerate(path_parts):
        # logging.debug("============================")
        # if current_zip_data:
        #     logging.debug("========== Opening current Data as ZIP =============")
        # if current_tar_data:
        #     logging.debug("========== Opening current Data as TAR =============")
        # logging.debug(f"***  Found part = {part}  carry = {carry}")
        # logging.debug("============================")
        part = os.path.join(carry, part) if carry else part
        is_last = (i == len(path_parts) - 1)
        is_prev_to_last = (i == len(path_parts) - 2)

        if current_zip_data:
            cm = zipfile.ZipFile(io.BytesIO(current_zip_data), 'r')
            filelist = cm.namelist()
            cm_open = cm.open
        elif current_tar_data:
            cm = tarfile.open(fileobj=io.BytesIO(current_tar_data), mode='r')
            filelist = cm.getmembers()
            cm_open = cm
        # logging.debug(f"*** Archive filelist: {filelist}")
        with cm:
            if any([part+'/' in str(item) for item in filelist]):
                carry = part
                # logging.debug(f"*** Set carry to: {carry}")
                continue
            else:
                carry = ''
            if not [part for item in filelist if part in str(item)]:
                # logging.debug(f"*** '{part}' not found at level {i}")
                return False

            if current_zip_data:
                cm_open = cm.open(part)
            elif current_tar_data:
                # logging.debug(f"*** Searching file in tar: {part}")
                tar_item = [x for x in cm.getmembers() if part in str(x)]
                cm_open = cm.extractfile(tar_item[0])

            with cm_open as f:
                if is_last:
                    with open(output_path, 'wb') as out_file:
                        out_file.write(f.read())
                    # logging.debug(f"*** Extracted '{virtual_path}' to '{output_path}'")
                    return True
                else:
                    current_data = f.read()

                if part.endswith('.zip'):
                    current_zip_data = current_data
                    current_tar_data = ""
                elif part.endswith('.tar'):
                    current_tar_data = current_data
                    current_zip_data = ""
                else:
                    # logging.debug(f"Expected zip or tar file at '{part}', but got regular file.")
                    return False
                # logging.debug("----------------------------------------")
    return False


def get_file_path_from_snapshot(file_name_regex=None, file_path_regex=None, snapshot_path=None):
    # used
    file_matches = {}

    try:
        all_files = verify_snapshot.get_data_from_snapshot(snapshot_path)
        # logging.debug(all_files)
        for file in all_files:
            match_path_dict = {}
            if file_name_regex:
                match_file_name = re.search(file_name_regex, file)
            else:
                match_file_name = True

            if file_path_regex and match_file_name:
                match_file_path_in_name = re.search(file_path_regex, file)
            else:
                match_file_path_in_name = False

            for index, file_path in enumerate(all_files[file][::2]):
                logging.debug(file_path)
                if match_file_name:
                    if file_path_regex:
                        match_file_path = re.search(file_path_regex, file_path)
                    else:
                        match_file_path = True

                    dict_key = f"{file}_{index}"
                    if match_file_path or match_file_path_in_name:
                        match_path_dict.update({dict_key: file_path})
                        # logging.debug("=======================================================")
                        # logging.debug(file)
                        # logging.debug(f"Match path dict update: {dict_key}: {file_path}")
                        # logging.debug("=======================================================")

            file_matches.update(match_path_dict)

    except FileNotFoundError:
        logging.debug(f"Error: File '{snapshot_path}' not found.")
        logging.warning(f"Broken File '{snapshot_path}' not found.")
    except Exception as e:
        logging.debug(f"An error occurred: {e}")
    return file_matches


def unpack_archive(input_file_path, output_file_path=None, file_type="gz"):
    if output_file_path is None:
        output_file_path = os.path.splitext(input_file_path)[0]
    logging.debug(f"Unpacked output file {output_file_path}")
    if file_type == "gz":
        try:
            with gzip.open(input_file_path, 'rb') as f_in:
                with open(output_file_path, 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
                    logging.debug(f"Unpacked file: {output_file_path}")
        except FileNotFoundError:
            logging.debug(f"Error: File '{input_file_path}' not found.")
            logging.warning(f"Broken File '{input_file_path}' not found.")


def search_in_file(file_path, soap_regex, timestamp_regex):
    """
    Searches for matches in a text file based on a given regex pattern.

    :param file_path: Path to the text file
    :param regex_pattern: Regular expression pattern to search for
    :return: List of matching lines
    """
    matches = []
    try:
        with open(file_path, 'r') as file:
            content = file.read()
            date_list = list(filter(None, re.split(timestamp_regex, content)))
            for item in date_list:
                match = re.search(soap_regex, item)
                if match:
                    matches.append((date_list.index(item) // 2, date_list[date_list.index(item) - 1], match.groups()))
    except FileNotFoundError:
        logging.debug(f"Error: File '{file_path}' not found.")
        logging.warning(f"Broken File '{file_path}' not found.")
    except Exception as e:
        logging.debug(f"An error occurred: {e}")
    return matches


def check_soap(snapshot_path="",
               file_name_regex="",
               file_path_regex="",
               timestamp_regex="",
               soap_profile_regex=""):

    result = get_file_path_from_snapshot(file_name_regex=file_name_regex, file_path_regex=file_path_regex,
                                         snapshot_path=snapshot_path)

    # logging.debug(f"Files found: {result}")
    snapshot_folder = os.path.dirname(snapshot_path)
    match_timestamp_list = []

    for find_file in result:
        logging.debug(f"Found file: {find_file}")
        logging.debug(f"Path: {result[find_file]}")

        find_file_path = os.path.join(snapshot_folder, find_file)

        extract_file_from_zip_by_path(
            outer_zip_path=snapshot_path,
            virtual_path=result[find_file],
            output_path=find_file_path)

        unpack_archive(input_file_path=find_file_path, file_type="gz")
        unpacked_archive_path = os.path.join(snapshot_folder, os.path.splitext(find_file)[0])

        logging.debug(f"Search in File:{unpacked_archive_path}")
        results = search_in_file(unpacked_archive_path, soap_profile_regex, timestamp_regex)
        logging.debug(results)
        if results:
            logging.debug("Matches found:")
            for line_number, str_timestamp, groups in results:
                logging.debug(f"\nLine {line_number}")
                timestamp = parser.parse(str_timestamp)
                timestamp_utc = timestamp.replace(tzinfo=datetime.timezone.utc)
                match_timestamp_list.append(timestamp_utc)
                # logging.debug(f"Found timestamp: {str_timestamp}")
                logging.debug(f"UTC timestamp: {timestamp_utc}")
        else:
            logging.debug("No matches found.")
    return match_timestamp_list


def check_climate_profiling_soap_log(snapshot_path="",
                                     new_value="",
                                     prev_value="",
                                     rmod_sn="",
                                     start_time=None,
                                     end_time=None,
                                     file_name_regex=None,
                                     timestamp_regex=None,
                                     soap_profile_regex=None,
                                     ):
    # list of matched timestamp only, empty list if no match in start time, end_time
    # KW should log as TRACE matched soap files.
    # Cleanup SOAP files after parsing.
    path = os.path.split(snapshot_path)
    if ".zip" not in path[-1]:
        raise NameError('snapshot_path does not contain file name (.zip)')

    start_time = parser.parse(start_time) if start_time else datetime.datetime.min
    start_time = start_time.replace(tzinfo=datetime.timezone.utc)
    end_time = parser.parse(end_time) if end_time else datetime.datetime.now(tz=datetime.timezone.utc)
    end_time = end_time.replace(tzinfo=datetime.timezone.utc)
    file_path_regex = f"{rmod_sn}_RMOD"
    file_name_regex = file_name_regex or DEFAULT_FILE_NAME_REGEX
    soap_profile_regex = soap_profile_regex or \
        rf"\bdistName=\"temperatureControl\".*profile.*<newValue>({new_value})<\/newValue><prevValue>({prev_value})\b"
    timestamp_regex = timestamp_regex or DEFAULT_TIMESTAMP_REGEX
    logging.debug(f"Timestamp regex: {timestamp_regex}")
    logging.debug(f"Soap profile regex: {soap_profile_regex}")

    found_timestamps = \
        check_soap(snapshot_path=snapshot_path,
                   file_name_regex=file_name_regex,
                   file_path_regex=file_path_regex,
                   timestamp_regex=timestamp_regex,
                   soap_profile_regex=soap_profile_regex)

    logging.debug(f"Timestamps found:{found_timestamps}")

    logging.debug(f"Timestamps valid (>={start_time}, <={end_time}):")
    needed_timestamps = [str(time_stamp) for time_stamp in found_timestamps
                         if start_time <= time_stamp <= end_time]
    logging.debug(f"{needed_timestamps}")

    return needed_timestamps
