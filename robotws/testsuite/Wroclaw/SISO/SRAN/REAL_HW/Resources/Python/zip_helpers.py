"""
:modified: 29.10.2024
"""
import re
import zipfile
import gzip
from robot.api import logger
from robot.api.deco import keyword

ROBOT_AUTO_KEYWORDS = False


@keyword('Get Regex Match Nested Archives In BTS Snapshot')
def get_regex_match_nested_archives_in_bts_snapshot(zip_path, regex_pattern):
    """
    Extracts and matches nested archive names in a BTS snapshot zip file based on a regex pattern.

    Args:
        zip_path (str): The path to the BTS snapshot zip file.
        regex_pattern (str): The regex pattern to match archive names.

    Returns:
        dict: A dictionary where keys are parent archive names and values are lists of matching nested archive names.

    Raises:
        FileNotFoundError: If 'snapshot_file_list.txt' is not found in the zip file.

    Author: mateusz.kawka@nokia.com
    Maintainer: mateusz.kawka@nokia.com
    """
    with zipfile.ZipFile(zip_path, 'r') as zip_file:
        if 'snapshot_file_list.txt' not in zip_file.namelist():
            raise FileNotFoundError('snapshot_file_list.txt not found in the archive.')
        else:
            logger.info('snapshot_file_list.txt found in the archive.')

        with zip_file.open('snapshot_file_list.txt') as file:
            lines = file.read().decode('utf-8').splitlines()

    result = {}
    current_parent = None

    for line in lines:
        if line.startswith('    '):
            archive_name = line.strip()
            if re.search(regex_pattern, archive_name):
                if current_parent not in result:
                    result[current_parent] = []
                result[current_parent].append(archive_name)
        else:
            current_parent = line.strip().rstrip(':')
            if re.search(regex_pattern, current_parent):
                if current_parent not in result:
                    result[current_parent] = []

    logger.info(f'Found matching archives: {result}')
    return result


@keyword('Parse Snapshot File List From Zip')
def parse_snapshot_file_list_from_zip(zip_path):
    """
    Extracts the list of expected files from 'snapshot_file_list.txt' inside the given zip archive.

    Args:
        zip_path (str): Path to the zip file.

    Returns:
        list: List of expected file paths as listed in snapshot_file_list.txt.
    """
    with zipfile.ZipFile(zip_path, 'r') as zip_file:
        if 'snapshot_file_list.txt' not in zip_file.namelist():
            raise FileNotFoundError('snapshot_file_list.txt not found in the archive.')
        with zip_file.open('snapshot_file_list.txt') as file:
            lines = file.read().decode('utf-8').splitlines()
    expected_files = []
    for line in lines:
        line = line.strip()
        if line and not line.endswith(':'):
            expected_files.append(line)
    logger.info(f"Expected files from snapshot_file_list.txt: {expected_files}")
    return expected_files


@keyword('All Expected Files Present In Zip Recursive')
def all_expected_files_present_in_zip_recursive(zip_path, expected_files):
    """
    Checks if all expected files are present in the zip archive (recursively), including inside nested zip files.

    Args:
        zip_path (str): Path to the zip file.
        expected_files (list): List of expected file names.

    Returns:
        list: List of missing files (empty if all are present).
    """
    import os
    import io
    found_files = set()

    def scan_zip(zf):
        for name in zf.namelist():
            if name.endswith('.zip'):
                # Read the nested zip file into memory and scan it
                with zf.open(name) as nested_zip_file:
                    nested_bytes = nested_zip_file.read()
                    with zipfile.ZipFile(io.BytesIO(nested_bytes)) as nested_zf:
                        scan_zip(nested_zf)
            else:
                found_files.add(os.path.basename(name))

    with zipfile.ZipFile(zip_path, 'r') as zip_file:
        scan_zip(zip_file)

    missing = [f for f in expected_files if os.path.basename(f) not in found_files]
    if missing:
        logger.warn(f"Missing files in zip (recursive): {missing}")
    else:
        logger.info("All expected files are present in the zip archive (recursive).")
    return missing


@keyword('Search Gz File For Regex')
def search_gz_file_for_regex(file_path, regex_pattern):
    """
    Searches a .gz file for lines matching a given regular expression.

    Args:
            file_path (str): The path to the .gz file.
            regex_pattern (str): The regular expression pattern to search for.

        Returns:
            list: A list of lines from the .gz file that match the regex pattern.

    Author: przemyslaw.kempa@nokia.com
    Maintainer: przemyslaw.kempa@nokia.com
    """
    matching_lines = []
    try:
        with gzip.open(file_path, 'rt', encoding='utf-8') as f:
            for line in f:
                if re.search(regex_pattern, line):
                    matching_lines.append(line.strip())
    except FileNotFoundError:
        raise FileNotFoundError(f"The file '{file_path}' was not found.")
    except Exception as e:
        raise Exception(f"An error occurred while processing the .gz file: {e}")
    return matching_lines
