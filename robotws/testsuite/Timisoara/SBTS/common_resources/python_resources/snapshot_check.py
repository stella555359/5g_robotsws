import logging
import lzma
import re
import tarfile
import xml.etree.ElementTree as ET
from io import TextIOWrapper
from os import path
from zipfile import BadZipFile, ZipFile

import helper_functions

"""
A collection of utilities for inspecting and extracting data from software snapshots,
which are often packaged as nested archives (e.g., zip-in-zip, tar-in-zip).

This module provides functions to:
- Recursively find files within nested archives by a filename pattern.
- Search for content within files (including compressed ones) inside archives using regular expressions.
- Extract specific parameter values from XML files located deep within an archive structure.
- Filter files based on timestamps embedded in their names.

The primary functions are designed to work with file streams, avoiding the need to fully
extract archives to disk, making them efficient for large and complex snapshots.
"""


def get_files_from_snapshot_by_name_pattern(archive_path, name_pattern):
    """
    This function traverses through nested archives to find all
    files whose base name matches the provided regex.

    :param archive_path: Path to the top-level archive file (e.g. a snapshot zip).
    :param name_pattern: Regex pattern to match against the filename.
    :return: A list of full, resolved paths to all matching files.
    """
    if not path.exists(archive_path):
        raise FileNotFoundError(f"Archive path not found: '{archive_path}'")
    if not name_pattern:
        raise Exception("Name pattern cannot be empty in get_files_from_snapshot_by_name_pattern")

    archive_extensions = ('.zip', '.tar', '.tar.gz', '.tgz', '.tar.bz2', '.tbz2', '.tar.xz')
    found_paths = []
    compiled_pattern = re.compile(name_pattern)
    # Use a set of full internal paths to avoid processing the same archive infinitely
    processed_archives = set()

    def _search_recursively(fileobj, current_path_prefix):
        if current_path_prefix in processed_archives:
            return

        container_name = path.basename(current_path_prefix)
        is_archive = container_name.endswith(archive_extensions)
        if is_archive:
            processed_archives.add(current_path_prefix)

        # Rewind stream if possible, as it may have been read by a previous check
        if fileobj.seekable():
            fileobj.seek(0)

        if container_name.endswith('.zip'):
            try:
                with ZipFile(fileobj, 'r') as archive:
                    for member_info in archive.infolist():
                        if member_info.is_dir():
                            continue
                        member_path = f"{current_path_prefix}/{member_info.filename}"
                        if compiled_pattern.search(path.basename(member_info.filename)):
                            logging.info(f"Found matching file: '{member_path}' for pattern '{name_pattern}'.")
                            found_paths.append(member_path)
                        if member_info.filename.endswith(archive_extensions):
                            with archive.open(member_info) as nested_file:
                                _search_recursively(nested_file, member_path)
            # if the file is corrupted or not a valid zip file, it stops processing that file and moves on
            except (BadZipFile, KeyError):
                return
        elif is_archive:  # Tar handling
            try:
                with tarfile.open(fileobj=fileobj, mode='r:') as archive:
                    for member_info in archive.getmembers():
                        if not member_info.isfile():
                            continue
                        member_path = f"{current_path_prefix}/{member_info.name}"
                        if compiled_pattern.search(path.basename(member_info.name)):
                            logging.info(f"Found matching file: '{member_path}' for pattern '{name_pattern}'.")
                            found_paths.append(member_path)
                        if member_info.name.endswith(archive_extensions):
                            nested_file = archive.extractfile(member_info)
                            if nested_file:
                                with nested_file:
                                    _search_recursively(nested_file, member_path)
            except (tarfile.ReadError, KeyError):
                return

    # Start the recursive search
    normalized_archive_path = archive_path.replace(path.sep, '/')
    try:
        with open(normalized_archive_path, 'rb') as f:
            _search_recursively(f, normalized_archive_path)
    except IOError as e:
        logging.error(f"Error reading base file '{archive_path}': {e}")
        return []

    if not found_paths:
        raise FileNotFoundError(f"Info: No files matching pattern '{name_pattern}' were found in {archive_path}")
    return found_paths


def get_first_file_matching_date_and_after_time(file_paths, reference_date_str, reference_time_str):
    """
    Finds the first file from a list of paths that has a specific date and is at or after a specific time.
    The timestamp is expected to be in 'YYYYMMDD.HHMMSS' format in the filename.

    :param file_paths: A list of file paths to search through.
    :param reference_date_str: The date the file's timestamp must match, in 'YYYYMMDD' format.
    :param reference_time_str: The time the file's timestamp must be greater than or equal to, in 'HHMMSS' format.
    :return: The path of the first matching file, or None if not found.
    """
    # This regex will find and capture date (YYYYMMDD) and time (HHMMSS) parts from the filename.
    timestamp_pattern = re.compile(r'(\d{8})\.(\d{6})')

    for file_path in file_paths:
        file_name = path.basename(file_path)
        match = timestamp_pattern.search(file_name)
        if match:
            file_date_str = match.group(1)
            file_time_str = match.group(2)
            if file_date_str == reference_date_str and file_time_str > reference_time_str:
                logging.info(f"Found first matching file: '{file_path}'")
                return file_path
    criteria = f"{reference_date_str}.{reference_time_str}"
    raise FileNotFoundError(f"No files with the specified date/time criteria({criteria}) "
                            f"were found in the provided list: {file_paths}")


def get_parameter_value_from_xml_in_archive(nested_xml_path, parameter_name):
    """
    Searches for a parameter in an XML file located within a nested archive.

    This function accesses a potentially compressed XML file inside a series of
    nested archives (e.g., zip, tar), parses it, and returns the text value
    of the first matching XML tag.

    Example:
    - nested_xml_path: '/path/to/snapshot.zip/data.tar.gz/config.xml.gz'
    - parameter_name: 'PARAMETER' (to find <PARAMETER>2</PARAMETER>)

    :param nested_xml_path: The full, slash-separated path to the target XML file,
                            including the archive path.
    :param parameter_name: The name of the XML tag to find (e.g., 'PARAMETER').
    :return: The text content of the las occurance of the parameter tag if found, otherwise None.
    """
    logging.info(f"Attempting to access XML file: {nested_xml_path}")
    try:
        with helper_functions.stream_file_in_nested_archive(nested_xml_path, decompress=True) as xml_stream:
            if xml_stream is None:
                logging.error(f"Error: Could not access or read content from '{nested_xml_path}'.")
                return None

            # Use ET.parse for stream-based parsing, which is more memory-efficient
            tree = ET.parse(xml_stream)
            root = tree.getroot()

            # Use .// to find the tag anywhere in the XML tree
            element = root.findall(f'.//{parameter_name}')[-1]

            if element is not None:
                value = element.text.strip() if element.text else ""
                logging.info(f"Success: Found parameter '{parameter_name}' with value: '{value}'")
                return value
            else:
                logging.warning(f"Info: Parameter '{parameter_name}' not found in '{nested_xml_path}'.")
                return None

    except ET.ParseError as e:
        logging.error(f"Error: Failed to parse XML from '{nested_xml_path}'. Details: {e}")
        return None
    except IndexError as e:
        logging.error(f'Parameter not found in xml file. Details:{e}')
        return None
    except Exception as e:
        logging.error(f"An unexpected error occurred while processing the XML: {e}")
        return None


def find_all_lines_in_files_matching_pattern(file_paths, content_regex):
    """
    This function iterates through each provided file path, accesses its content
    (handling nested archives and decompression automatically), and collects
    all lines that match the pattern. For each match found, it also logs the
    source file path and the line to the console.

    :param file_paths: A list of full, slash-separated paths to files.
                       These paths can point inside nested archives.
    :param content_regex: The regex pattern to search for within the file content.
    :return: A dictionary where keys are file paths and values are lists of
             matching lines. Returns an empty dictionary if no match is
             found.
    """
    try:
        compiled_pattern = re.compile(content_regex)
    except re.error as e:
        logging.error(f"Error: Invalid regex pattern provided: '{content_regex}'. Details: {e}")
        return {}

    found_matches_dict = {}
    for file_path in file_paths:
        logging.info(f"Info: Searching in file: {file_path}")
        try:
            with helper_functions.stream_file_in_nested_archive(file_path, decompress=True) as file_stream:
                if file_stream is None:
                    continue

                current_file_matches = []
                # Wrap the byte stream for text-based, line-by-line reading
                with TextIOWrapper(file_stream, encoding='utf-8', errors='ignore') as text_file:
                    for line in text_file:
                        if compiled_pattern.search(line):
                            logging.info(f"Found match in '{file_path}': {line.strip()}")
                            current_file_matches.append(line)
        except Exception as e:
            logging.error(f"An unexpected error occurred while processing '{file_path}': {e}")
            continue
        if current_file_matches:
            found_matches_dict[file_path] = current_file_matches

    if not found_matches_dict:
        logging.info(f"Info: No lines matching the pattern '{content_regex}' were found in the provided files.")
    else:
        total_lines = sum(len(lines) for lines in found_matches_dict.values())
        logging.info(f"Success: Found {total_lines} matching line(s) across {len(found_matches_dict)} file(s).")
    return found_matches_dict


def check_snapshot_content(file_path, search_string):
    """
    Reads an lzma compressed file and finds lines containing a specific string.

    :param file_path: Path to the .xz file.
    :param search_string: The string to search for in each line.
    :return: A list of matching lines.
    """
    content = []
    with lzma.open(file_path, mode='rt', errors='ignore') as f:
        for line in f:
            if search_string in line:
                content.append(line)
    return content


def extract_snapshot_content(snapshot_file, content):
    """
    Extracts a specific content file from a nested snapshot archive.

    Note: This function has side-effects as it extracts files to disk.
    """
    extraction_path = snapshot_file[0:snapshot_file.rfind('/') + 1]
    zip_content = _check_snapshot_file_list(snapshot_file, content)
    with ZipFile(snapshot_file) as zip_snapshot:
        zip_snapshot.extract(zip_content, path=extraction_path)
    with ZipFile(path.join(extraction_path, zip_content)) as content_zip:
        file_content = content_zip.extract(content, path=extraction_path)
    if '.zip' in file_content:
        _additional_extraction_needed(file_content, extraction_path)


def _additional_extraction_needed(additional_zip, path_extraction):
    """
    Extracts all contents of a zip file to a specified path.

    :param additional_zip: The name of the zip file to extract.
    :param path_extraction: The directory to extract files into.
    """
    with ZipFile(path.join(path_extraction, additional_zip)) as content_zip:
        content_zip.extractall(path=path_extraction)


def _check_snapshot_file_list(snapshot, content):
    """
    Finds which inner zip contains a content file by reading snapshot_file_list.txt.

    Note: This function has a side-effect of extracting 'snapshot_file_list.txt'
    to the current working directory.

    :param snapshot: Path to the main snapshot zip file.
    :param content: The name of the content file to locate.
    :return: The name of the container zip file.
    """
    with ZipFile(snapshot) as zip_snapshot:
        zip_snapshot.extract('snapshot_file_list.txt')
    content_zip = _search_for_content('snapshot_file_list.txt', content)
    return content_zip.replace(':', '').strip()


def _search_for_content(snapshot_file_list, content):
    """
    Searches the snapshot_file_list.txt to find the container archive for a given file.

    :param snapshot_file_list: Path to the snapshot_file_list.txt.
    :param content: The name of the content file to locate within the list.
    :return: The name of the container archive, or None if not found.
    """
    with open(snapshot_file_list) as file_list:
        for row in file_list:
            if "    " not in row:
                flag = row
            if content in row:
                return flag
    return None
