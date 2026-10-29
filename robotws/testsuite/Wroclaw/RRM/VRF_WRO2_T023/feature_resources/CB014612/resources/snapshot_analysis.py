import zipfile
import tarfile
import lzma
import gzip
import re
import io
import os
from datetime import datetime, timezone
from robot.api import logger


def get_ul_gain_correction(snapshot_path, mrbts_id, rmod_sn, min_epoch, destination_dir):
    """
        This function gets values of UL gain correction from snapshot,
        checks if all values are the same and returns the first value
        of UL gain correction if they are and None if the values are different.
        :param snapshot_path: Absolute path to snapshot file.
        :param mrbts_id: MRBTS ID.
        :param rmod_sn: Serial number of SMOD for which user wants to check UL gain correction.
        :param min_epoch: Minimum timestamp in epoch. Values from lines
               with timestamp lower than min_epoch will not be included.
        :param destination_dir: Absolute path to directory in which logs will be extracted.
        :return: First element of list if all values are the same or None
                 if there are different values among UL gain correction.
    """
    bts_part, runtime_file = get_bts_part_and_runtime_from_snapshot_file_list(snapshot_path, mrbts_id, rmod_sn)
    extract_files_from_nested_archives(snapshot_path, bts_part, runtime_file, destination_dir)
    ul_gain_correction_list = create_list_of_ul_gain_corrections(destination_dir, min_epoch)
    logger.debug(f'UL gain correction list: {ul_gain_correction_list}')
    logger.console(f'UL gain correction list: {ul_gain_correction_list}')
    values_are_different = has_different_value(ul_gain_correction_list)
    logger.debug(f'There is a different value in the list: {values_are_different}')
    if not values_are_different:
        return ul_gain_correction_list[0]
    else:
        return None


def get_bts_part_and_runtime_from_snapshot_file_list(snapshot_path, mrbts_id, rmod_sn):
    """
        This function extracts 'snapshot_file_list.txt' from snapshot and gets values
        of UL gain correction from it.
        :param snapshot_path: Absolute path to snapshot file.
        :param mrbts_id: MRBTS ID.
        :param rmod_sn: Serial number of SMOD for which user wants to check UL gain correction.
        :return: A tuple containing name of BTS_part .zip file containing RMOD L1 runtime file
                 and the name of the RMOD L1 runtime file
    """
    with zipfile.ZipFile(snapshot_path) as zf:
        # Read snapshot_file_list.txt
        with zf.open('snapshot_file_list.txt') as f:
            snapshot_file_list = f.read().decode(errors='ignore')
        bts_part, runtime_file = find_bts_part_and_runtime(snapshot_file_list, mrbts_id, rmod_sn)
        logger.debug(f'BTS_part name:{bts_part}\nRMOD runtime archive name: {runtime_file}')
        if not bts_part or not runtime_file:
            raise FileNotFoundError('Could not find required files in snapshot_file_list.txt')
    return bts_part, runtime_file


def find_bts_part_and_runtime(snapshot_file_list, mrbts_id, rmod_sn):
    """
        This function gets values of UL gain correction from snapshot.
        :param snapshot_file_list: Contents of the 'snapshot_file_list.txt' file.
        :param mrbts_id: MRBTS ID.
        :param rmod_sn: Serial number of SMOD for which user wants to check UL gain correction.
        :return: A tuple containing name of BTS_part .zip file containing RMOD L1 runtime file
                 and the name of the RMOD L1 runtime file. If the runtime file is not under a BTS_part zip,
                 'no parent' is returned as the first element of the tuple.
    """
    logger.debug('Looking for BTS_part and RMOD L1 runtime archive full names.')
    bts_part = None
    runtime_file = None
    logger.debug(r'Regexp for BTS part: ^BTS_part\d+\.zip:$')
    part_pattern = re.compile(r'^BTS_part\d+\.zip:$')
    logger.debug(rf'Regexp for RMOD L1 runtime archive: BTS{mrbts_id}_{rmod_sn}_RMOD_L_.+?_l1-runtime\.tar\.gz')
    runtime_pattern = re.compile(
        rf'BTS{mrbts_id}_{rmod_sn}_RMOD_L_.+?_l1-runtime\.tar\.gz'
    )
    current_part = None
    for line in snapshot_file_list.splitlines():
        stripped_line = line.rstrip()  # Only remove trailing whitespace
        if part_pattern.match(stripped_line):
            current_part = stripped_line[:-1]
            logger.debug(f'Printing current name: {current_part}')
        elif runtime_pattern.search(stripped_line):
            # Only match if the line does not start with whitespace (top-level file)
            if line.lstrip() == line:
                runtime_file = runtime_pattern.search(stripped_line).group(0)
                bts_part = 'no parent'
                logger.debug(f'Printing current name of runtime file: {runtime_file}')
                break
            else:
                runtime_file = runtime_pattern.search(stripped_line).group(0)
                bts_part = current_part
                logger.debug(f'Printing current name of runtime file: {runtime_file}')
                break
    return bts_part, runtime_file


def open_archive(data, name):
    """
        This function opens different types of archivee files and returns
        the corresponding file object and archive type.
        Handled archive types: .zip, tar.gz, .tgz, .xz, , .tar, .gz.
        :param data: Bytes-like object containing the archive data.
        :param name: Name of the archive file (used to determine the archive type).
        :return:  Tuple of (archive file object, archive type as string).
         Returns (None, None) if the type is unsupported.
    """
    if name.endswith('.zip'):
        return zipfile.ZipFile(io.BytesIO(data)), 'zip'
    elif name.endswith('.tar.gz') or name.endswith('.tgz'):
        return tarfile.open(fileobj=io.BytesIO(data), mode='r:gz'), 'tar'
    elif name.endswith('.txz') or name.endswith('.xz'):
        lzf = lzma.open(io.BytesIO(data))
        return tarfile.open(fileobj=io.BytesIO(lzf.read()), mode='r:'), 'tar'
    elif name.endswith('.tar'):
        return tarfile.open(fileobj=io.BytesIO(data), mode='r:'), 'tar'
    elif name.endswith('.gz'):
        return gzip.open(io.BytesIO(data)), 'gz'
    else:
        return None, None


def extract_files_from_nested_archives(snapshot_path, first_zip_name, l1_runtime_name, extract_path):
    """
        This procedure extracts files for RMOD's L1 runtime.
        :param snapshot_path: Absolute path to snapshot file.
        :param first_zip_name: Name of the first .zip archie inside of snapshot file, or 'no parent' if not present.
        :param l1_runtime_name: Name of L1 runtime .tar.gz file with RMOD logs.
        :param extract_path: Absolute path where L1 runtime logs for RMOD will be extracted.
        :return:
    """
    os.makedirs(extract_path, exist_ok=True)
    logger.debug('Opening snapshot.')
    # Open snapshot
    with open(snapshot_path, 'rb') as f:
        data = f.read()
    zf, _ = open_archive(data, snapshot_path)
    logger.debug('Snapshot opened.')
    # Open the L1 runtime file, either directly or via first_zip_name.
    # In other words open first archive inside of snapshot.
    if first_zip_name == 'no parent':
        with zf as zf1:
            with zf1.open(l1_runtime_name) as f3:
                data3 = f3.read()
    else:
        with zf as zf1:
            with zf1.open(first_zip_name) as f2:
                data2 = f2.read()
        zf2, _ = open_archive(data2, first_zip_name)
        logger.debug('First .zip opened.')
        # Open RMOD's L1 runtime file inside the first zip
        with zf2 as zf2:
            with zf2.open(l1_runtime_name) as f3:
                data3 = f3.read()
    tf, _ = open_archive(data3, l1_runtime_name)
    logger.debug('RMOD\'s L1 runtime .tar.gz archive opened.')
    # Find the full name of the .txz file and open it (from the L1 runtime archive)
    with tf as tf1:
        # Find the only .txz file
        txz_member = next(m for m in tf1.getmembers() if m.name.endswith('.txz'))
        with tf1.extractfile(txz_member) as txz_file:
            txz_data = txz_file.read()
    logger.debug(f'Name of .txz file:{txz_member.name}')
    txz_tar, _ = open_archive(txz_data, txz_member.name)
    logger.debug('.txz archive opened.')
    # Extract all .gz, .txt, .log files from the .txz archive to the target directory
    with txz_tar as tf2:
        log_prefix = 'var/log/'
        for m in tf2.getmembers():
            logger.debug(f'Path of file being extracted:{m}')
            # Check if the member is a file, starts with 'var/log/', and ends with .gz, .txt, or .log
            if m.isfile() and m.name.startswith(log_prefix) and (
                    m.name.endswith('.gz') or m.name.endswith('.txt') or m.name.endswith('.log')
            ):
                if m.name.endswith('.gz'):
                    rel_path = m.name[len(log_prefix):-3]  # Remove 'var/log/' and '.gz'
                else:
                    rel_path = m.name[len(log_prefix):]  # Remove 'var/log/' only
                logger.debug(f'Relative path:{rel_path}')
                file_path = os.path.join(extract_path, rel_path)
                os.makedirs(os.path.dirname(file_path), exist_ok=True)
                logger.debug(f'Destination path for file being extracted:{file_path}')
                # Extract and decompress the .gz file, then write it to the output path
                with tf2.extractfile(m) as in_file, open(file_path, 'wb') as out_f:
                    if m.name.endswith('.gz'):
                        with gzip.open(in_file) as gz_file:
                            out_f.write(gz_file.read())
                    else:
                        out_f.write(in_file.read())
    logger.debug('All files extracted.')


def create_list_of_ul_gain_corrections(directory_path, min_epoch):
    """
        This function returns a list of all UL gain correction values
        from lines with a timestamp greater than min_epoch.
        The files are being checked in alphabetic order. Only files
        with 'runtime' in the name are being checked.
        Regular expression used for filtering file contents:
        r'Ul gain correction of.*?is\\s*(-?\\d+(?:\\.\\d+)?)\\b'.
        :param directory_path: Absolute path to where RMOD's L1 runtime logs were extracted.
        :param min_epoch: Minimum timestamp in epoch. Values from lines
               with timestamp lower than min_epoch will not be included.
        :return: List of all UL gain correction values (as strings).
    """
    logger.debug('Creating list of UL gain corrections.')
    results = []
    ul_gain_correction_pattern = re.compile(r'Ul gain correction of.*?is\s*(-?\d+(?:\.\d+)?)\b')
    timestamp_pattern = re.compile(r'^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+Z)')
    # Sort the files alphabetically and check if they contain 'runtime' in name.
    for file_name in sorted(os.listdir(directory_path)):
        logger.debug(f'File name:{file_name}')
        if 'runtime' not in file_name:
            continue
        file_path = os.path.join(directory_path, file_name)
        logger.debug(f'File path:{file_path}')
        # If file is empty it is skipped
        if os.path.getsize(file_path) == 0:
            logger.debug(f'Size of file is equal to 0.')
            continue
        # Open the file and search for regexp
        with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                match = ul_gain_correction_pattern.search(line)
                _conditional_print_for_debugging(False, f'File:{file_path}\nLine:{line}')
                if not match:
                    continue
                _conditional_print_for_debugging(True, f'File:{file_path}\nLine:{line}')
                _conditional_print_for_debugging(False, f'Match value:{match}')
                ts_match = timestamp_pattern.match(line)

                if not ts_match:
                    continue
                # Parse timestamp to epoch
                try:
                    dt = datetime.strptime(ts_match.group(1), "%Y-%m-%dT%H:%M:%S.%fZ").replace(tzinfo=timezone.utc)
                except ValueError:
                    continue
                # Skip current line if timestamp is lower or equal to min_epoch
                line_epoch = float(dt.timestamp())
                min_epoch = float(min_epoch)
                if line_epoch <= min_epoch:
                    _conditional_print_for_debugging(False,
                                                     f'Time: {ts_match.group(1)}\n'
                                                     f'Line epoch:{line_epoch}\nMin epoch:{min_epoch}')
                    continue
                _conditional_print_for_debugging(False,
                                                 f'Time: {ts_match.group(1)}\n'
                                                 f'Line epoch:{line_epoch}\nMin epoch:{min_epoch}')
                # Add value of UL gain correction to list
                results.append(match.group(1))
    return results


def has_different_value(ul_gain_correction_list):
    """
        This function returns boolean value informing whether the list
        passed by the user has different values. It returns True if the list
        contains different values and False if the list contains only one unique value for all elements.
        :param ul_gain_correction_list: List containing UL gain correction values.
        :return: Boolean value informing whether the list
                 passed by the user has different values.It returns True if the list
                 contains different values and False if the list contains only one
                 unique value for all elements.
    """
    return len(set(ul_gain_correction_list)) > 1


def _conditional_print_for_debugging(condition, text):
    if condition:
        logger.console(text)
        logger.debug(text)
