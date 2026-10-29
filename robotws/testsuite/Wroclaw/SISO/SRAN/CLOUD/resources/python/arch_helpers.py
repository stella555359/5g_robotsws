"""
:modified: 20.2.2026
"""
import re
import io
import os
import zipfile
import tarfile
from robot.api import logger
from robot.api.deco import keyword

ROBOT_AUTO_KEYWORDS = False


@keyword('Get Regex Match Nested Archives In Cloud Snapshot')
def get_regex_match_nested_archives_in_cloud_snapshot(zip_path, regex_pattern):
    """
    Extracts and matches nested archive names in a Cloud snapshot zip file based on a regex pattern.

    Args:
        zip_path (str): The path to the Cloud snapshot zip file.
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


@keyword('Search Regex In Nested Cloud Archives')
def search_regex_in_nested_cloud_archives(main_arch_path, nested_arch_path, r_pattern, encoding="utf-8"):
    """
    Searches for lines matching a regex pattern inside a text file stored in nested archives.
    Function was created mainly to be used in Cloud snapshots, to search for R&D faults
    but can be used in any scenario with similar archive structure.

    The function expects the following archive structure:
    - `main_arch_path` is a ZIP archive.
    - `nested_arch_path` points to two nested archives separated by `/`:
      first a ZIP file, then a TGZ file.
    - Files without an extension inside the TGZ are read and scanned line by line.

    Args:
        main_arch_path (str): The path to the main ZIP archive.
        nested_arch_path (str): The path to nested archives inside the main ZIP,
            in the format `inner_zip_path/inner_tgz_path`.
        r_pattern (str): The regex pattern used to match lines in extracted files.
        encoding (str, optional): The text encoding used to decode extracted files.
            Defaults to "utf-8".

    Returns:
        list[str]: A list of lines that match the regex pattern.

    Raises:
        KeyError: If any nested archive path does not exist in its parent ZIP archive.
        zipfile.BadZipFile: If a ZIP archive is invalid or corrupted.
        tarfile.ReadError: If the TGZ archive cannot be read.
        UnicodeDecodeError: If extracted file content cannot be decoded using the selected encoding.
        re.error: If the provided regex pattern is invalid.

    Author: daniel.bartkowiak@nokia.com
    Maintainer: daniel.bartkowiak@nokia.com
    """
    nested_files = nested_arch_path.split("/")
    regex = re.compile(r_pattern)

    # Open the main ZIP file
    current_data = None

    with zipfile.ZipFile(main_arch_path) as z:
        current_data = z.read(nested_files[0])

    # Open the nested ZIP from memory
    with zipfile.ZipFile(io.BytesIO(current_data)) as z:
        current_data = z.read(nested_files[1])

    # Open the TGZ from memory
    with tarfile.open(fileobj=io.BytesIO(current_data), mode="r:gz") as tar:
        regex_matches = []

        for member in tar.getmembers():
            if member.isfile() and "." not in os.path.basename(member.name):
                f = tar.extractfile(member)
                if not f:
                    continue

                content = f.read().decode(encoding)
                logger.info(f"{member.name} contains:\n{content}")

                for line in content.splitlines():
                    if regex.search(line):
                        logger.info(f"Match in {member.name}: {line.strip()}")
                        regex_matches.append(f"{member.name} {line.strip()}")

        return regex_matches
