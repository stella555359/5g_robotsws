import zipfile
import collections
import fnmatch
import os
import lzma
import shutil


def read_snapshot_file_list(snapshot_file):
    """Open the snapshot and read the 'snapshot_file_list.txt' and
    returns its content.

    :param str snapshot_file: The path to the snapshot file.
    """
    try:
        snapshot_zipped = zipfile.ZipFile(snapshot_file)
    except zipfile.BadZipFile:
        raise AssertionError("Collected Log is not a zip file!")
    else:
        if 'snapshot_file_list.txt' in snapshot_zipped.namelist():
            return snapshot_zipped.open('snapshot_file_list.txt').read()
        else:
            raise AssertionError("No snapshot_file_list.txt found in file!")


def get_snapshot_index(snapshot_file):
    """Reads the content of 'snapshot_file_list.txt' within the snapshot
    and translates it to a dictionary structure, which represents a zip file
    as keys and a list of containing files as value.

    :param str snapshot_file: The path to the snapshot file
    """
    file_list_content = read_snapshot_file_list(snapshot_file)

    current_key = ''
    snapshot_index = collections.defaultdict(list)
    for line in file_list_content.decode().split('\n'):
        if not line.startswith('    '):
            current_key = line.strip().strip(':')
        else:
            snapshot_index[current_key].append(line.strip())

    return snapshot_index


def find_zip_for_file(snapshot, filename):
    """Checks the content of snapshot file for the given filename glob pattern
    and return all matching filenames

    :param str snapshot: The path to the snapshot file
    :param str filename: The glob pattern of the file to search for in snapshot
    """
    matching_zip_files = []
    for zip_file, zip_content in get_snapshot_index(snapshot).items():
        matching_files = fnmatch.filter(zip_content, filename)
        if matching_files:
            matching_zip_files.append(zip_file)
    return matching_zip_files


def extract_raw_alarm_history(snapshot):
    """
    Find the ZIP File for "RawAlarmHistory" in the snapshot, extract it and
    save its content to a textfile.
    The path to the textfile will be returned.
    The resulting textfile is extracted right next to the snapshot file.

    :param str snapshot: The path to the snapshot file
    :returns: The path to the textfile containing the RawAlarmHistory
    """
    containing_zip_file = find_zip_for_file(snapshot, "*RawAlarmHistory*")

    containing_zip_file = containing_zip_file[0]

    target_dir = os.path.dirname(snapshot)

    extracted = None
    # unpack containing zip
    try:
        snapshot_zipped = zipfile.ZipFile(snapshot)
    except zipfile.BadZipFile:
        raise AssertionError("Collected Log is not a zip file!")
    else:
        extracted = snapshot_zipped.extract(containing_zip_file, path=target_dir)

    if extracted:
        try:
            extracted_zipped = zipfile.ZipFile(extracted)
        except zipfile.BadZipFile:
            raise AssertionError("Collected Log is not a zip file!")
        else:
            all_members = extracted_zipped.namelist()
            matching_files = fnmatch.filter(all_members, "*RawAlarmHistory*")
            raw_alarm_xz = extracted_zipped.extract(matching_files[0], path=target_dir)

            raw_alarm_file = save_content_of_raw_alarm_xz(raw_alarm_xz)
            return raw_alarm_file


def save_content_of_raw_alarm_xz(raw_alarm_xz):
    target = raw_alarm_xz.rstrip(".xz")
    with lzma.open(raw_alarm_xz, "rb") as f_in, open(target, "wb") as f_out:
        shutil.copyfileobj(f_in, f_out)
    return target
