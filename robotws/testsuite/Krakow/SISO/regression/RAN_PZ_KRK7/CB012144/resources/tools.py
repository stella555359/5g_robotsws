import re
import os
import lzma
import zipfile
import blackbox_file_pattern
import bbox5_file_pattern
import bbox5_file_pattern_trunk
from blackbox_files_exceptions import IncorrectFileContetnException
from typing import NoReturn
from robot.api import logger
from datetime import datetime


def _find_file_in_snap_file_list(extracted_zip_dir: str, file_name: str) -> str:
    with open(os.path.join(extracted_zip_dir, 'snapshot_file_list.txt')) as snap_file_list:
        lines = snap_file_list.readlines()
        for line in lines:
            if re.search(r"^BTS.+\.zip:$", line):
                directory = line.replace('\n', '')
                directory = directory.replace(':', '')
            if re.search(file_name, line):
                log_file = line.replace(" ", "")
                log_file = log_file.replace("\n", "")
                return os.path.join(extracted_zip_dir, directory), log_file


def extract_zip_file(zip_path: str) -> str:
    output_dir = zip_path.replace(".zip", "")
    if os.path.isdir(output_dir):
        logger.debug(f"Path {output_dir} already exists.")
    else:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(output_dir)
    return output_dir


def extract_xz_file(xz_path: str) -> str:
    output_file = xz_path.replace(".xz", ".txt")
    if os.path.isfile(output_file):
        logger.debug(f"Path {output_file} already exists.")
    else:
        with lzma.open(xz_path) as f, open(output_file, 'wb') as fout:
            file_content = f.read()
            fout.write(file_content)
    return output_file


def get_and_ectract_xz_file_from_snap(snap_path: str, file_name: str) -> str:
    extracted_snap_dir = extract_zip_file(snap_path)
    zip_dir, target_file = _find_file_in_snap_file_list(extracted_snap_dir, file_name)
    extracted_file_dir = extract_zip_file(zip_dir)
    snap_file_path = os.path.join(extracted_file_dir, target_file)
    if snap_file_path.endswith(".xz"):
        extracted_xz_file_path = extract_xz_file(snap_file_path)
        return extracted_xz_file_path
    elif snap_file_path.endswith(".zip"):
        extracted_zip_dir_path = extract_zip_file(snap_file_path)
        extracted_dir = os.listdir(extracted_zip_dir_path)
        target_file = [f for f in extracted_dir if re.search(file_name, f)]
        if len(target_file) == 0:
            raise FileNotFoundError(f"\nFile {file_name} not found.")
        elif len(target_file) == 1:
            return os.path.join(extracted_zip_dir_path, target_file[0])
    else:
        raise FileNotFoundError("\nOnly .xz files")


def check_blackbox_post_result_A_file_content(file_path: str,
                                              site_module: str,
                                              start_time: str,
                                              end_time: str) -> NoReturn:
    file_pattern = []
    if not file_path.endswith(".txt"):
        raise FileNotFoundError(f"\nIncorrect file extensions {file_path}. Should be .txt")
    if site_module.upper() == "SMOD":
        file_pattern = blackbox_file_pattern.smod_post_pattern
    elif site_module.upper() == "BBMOD":
        file_pattern = blackbox_file_pattern.bbmod_post_pattern
    else:
        raise ValueError(f"\nIncorrect site module: {site_module}. Choose BBMOD or SMOD")
    with open(file_path) as blackbox_file:
        blackbox_result = blackbox_file.readlines()[1:]
        for result, pattern in zip(blackbox_result, file_pattern):
            if not re.search(pattern, result):
                raise IncorrectFileContetnException(f"\nIncorrect file contetn: {file_path}\n{pattern} != {result}")
        result_no = 3
        timestamp_list = _get_timestamp_by_regex(blackbox_result, result_no)
        check_resets_dates(start_time, end_time, timestamp_list)


def check_blackbox_reset_file_content(file_path: str, site_module: str, start_time: str, end_time: str) -> NoReturn:
    file_pattern = []
    if not file_path.endswith(".txt"):
        raise FileNotFoundError(f"\nIncorrect file extensions {file_path}. Should be .txt")
    if site_module.upper() == "SMOD":
        file_pattern = blackbox_file_pattern.smod_reset_pattern
    elif site_module.upper() == "BBMOD":
        file_pattern = blackbox_file_pattern.bbmod_reset_pattern
    else:
        raise ValueError(f"\nIncorrect site module: {site_module}. Choose BBMOD or SMOD")
    with open(file_path) as blackbox_file:
        blackbox_result = blackbox_file.readlines()[-4:]
        for (result, pattern) in zip(blackbox_result, file_pattern):
            if not re.search(pattern, result):
                raise IncorrectFileContetnException(f"\nIncorrect file contetn: {file_path}\n{pattern} != {result}")
        result_no = 4
        timestamp_list = _get_timestamp_by_regex(blackbox_result, result_no)
        check_resets_dates(start_time, end_time, timestamp_list)


def check_bbox5_file_content(file_path: str, start_time: str, end_time: str, branch: str) -> NoReturn:
    if file_path.endswith("BBOX5"):
        with open(file_path) as bbox5_file:
            if branch == "SBTS25R2":
                bbox5_pattern = bbox5_file_pattern
            else:
                bbox5_pattern = bbox5_file_pattern_trunk
            bbox5_result = bbox5_file.readlines()
            post_results, resets_results = _get_needed_parts_of_bbox5_file(bbox5_result, branch)
            for (result, pattern) in zip(post_results, bbox5_pattern.rmod_post_pattern):
                if not re.search(pattern, result):
                    raise IncorrectFileContetnException(f"\nIncorrect file contetn: {file_path}\n{pattern} != {result}")
            for (result, pattern) in zip(resets_results, bbox5_pattern.rmod_reset_pattern):
                if not re.search(pattern, result):
                    raise IncorrectFileContetnException(f"\nIncorrect file contetn: {file_path}\n{pattern} != {result}")
            post_result_no = 3
            _check_if_last_write_of_post_result_is_correct(post_results)
            timestamp_list = _get_timestamp_by_regex(post_results[5:], post_result_no)
            check_resets_dates(start_time, end_time, timestamp_list)
            reset_result_no = 4
            timestamp_list = _get_timestamp_by_regex(resets_results[2:], reset_result_no)
            check_resets_dates(start_time, end_time, timestamp_list)
    else:
        raise ValueError(f"\nIncorrect file {file_path}. Should be BBOX5")


def _get_needed_parts_of_bbox5_file(bbox5_file_contetn_list: list, branch: str) -> tuple:
    if branch == "SBTS25R2":
        post_prints_no = 12
        resets_prints_no = 18
    else:
        post_prints_no = 16
        resets_prints_no = 22
    post_results = []
    resets_results = []
    for idx, line in enumerate(bbox5_file_contetn_list):
        if line == "Item type: POST_results\n":
            post_results = bbox5_file_contetn_list[idx:idx+post_prints_no]
        elif line == "Item type: resets\n":
            resets_results = bbox5_file_contetn_list[idx:idx+resets_prints_no]
            break
    if not post_results:
        raise IncorrectFileContetnException(f"\nCan't find POST results in BBOX5 file")
    elif not resets_results:
        raise IncorrectFileContetnException(f"\nCan't find reset results in BBOX5 file")
    return post_results, resets_results


def _get_timestamp_by_regex(file_contetn: list, result_no: int) -> list:
    timestamp_regex = r"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}"
    file_contetn = ' '.join(file_contetn)
    timestamp_list = re.findall(timestamp_regex, file_contetn)
    if len(timestamp_list) == result_no:
        return timestamp_list
    else:
        raise IncorrectFileContetnException(f"Expected results mismatch: {timestamp_list}")


def get_current_date() -> NoReturn:
    return datetime.now()


def check_resets_dates(start_time: datetime, end_time: datetime, resets_dates_list: list) -> NoReturn:
    timestamp_list = [datetime.strptime(date_str, "%Y-%m-%dT%H:%M:%S") for date_str in resets_dates_list]
    if False not in list(map(lambda i: i[0] < i[1], zip(timestamp_list[1:], timestamp_list))):
        timestamp_list.reverse()
    timestamp_list.insert(0, datetime.strptime(start_time, "%Y-%m-%d %H:%M:%S.%f"))
    timestamp_list.append(datetime.strptime(end_time, "%Y-%m-%d %H:%M:%S.%f"))
    if False in list(map(lambda i: i[0] > i[1], zip(timestamp_list[1:], timestamp_list))):
        raise IncorrectFileContetnException(f"\nIncorrect time in list of reset's time:{timestamp_list}")


def _check_if_last_write_of_post_result_is_correct(post_results: list) -> NoReturn:
    timestamp_list = _get_timestamp_by_regex(post_results, 4)
    if timestamp_list[0] != timestamp_list[1]:
        raise IncorrectFileContetnException("Incorrect last write of post result")
