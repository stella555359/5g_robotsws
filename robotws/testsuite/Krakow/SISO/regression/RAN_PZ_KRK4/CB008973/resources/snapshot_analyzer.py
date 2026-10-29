import re
import datetime
import logging
import zipfile
from io import BytesIO
try:
    import lzma
except ImportError:
    from backports import lzma

from taf.rfrl.bts.devices.exceptions import FileNotFound


def find_mandatory_rfsw_logs_in_snapshot(directory, mandatory_logs):
    """
    Search for RFSW files in snapshot
    :param directory: path to directory with snapshot
    :return: None
    """
    file_list = find_mandatory_files_in_snapshot(directory)
    if mandatory_logs is None:
        mandatory_log_list = ["journal", "hlapi", "runtime", "startup", "ps", "fault_history", "RP1OM"]
    else:
        mandatory_log_list = mandatory_logs
    for mandatory_log in mandatory_log_list:
        regex_file_list = re.compile(r'BTS.*RMOD_.*{}'.format(mandatory_log))
        if not list(filter(regex_file_list.match, file_list)):
            raise FileNotFound("Mandatory RFSW file containing name {} "
                               "not found in snapshot".format(mandatory_log))


def find_mandatory_files_in_snapshot(directory, return_extended_info=False):
    """
    Search for RMOD files in snapshot
    :param directory: path to directory with snapshot
    :param return_extended_info: True if dictionary of snapshot file names as keys and their size as value is needed
    :return:
    file_list: list: List of files of snapshot file names
    file_dict: dictionary: Dictionary of snapshot file names as keys and their size as value
    """
    bts_part_files = _get_bts_zip_files_list(directory)

    file_list, file_dict = _get_files_from_zipfile_objects(bts_part_files)
    file_list.extend(_get_rmod_zip_files_list(directory))
    if return_extended_info:
        with zipfile.ZipFile(directory, "r") as snapshot:
            for name in snapshot.namelist():
                file_dict.update({name: snapshot.getinfo(name).compress_size})
                file_list.append(name)
    regex = re.compile(r'BTS.*RMOD_.*_UnitOAM_SOAP_Log\.zip')
    if not list(filter(regex.match, file_list)):
        raise FileNotFound("Snapshot doesn't contain demanded files - UnitOAM_SOAP")
    regex_files = re.compile(r'BTS.*RMOD_.*\.zip')
    if not list(filter(regex_files.match, file_list)):
        raise FileNotFound("Snapshot doesn't contain demanded RMOD files")
    if return_extended_info:
        return file_list, file_dict
    else:
        return file_list


def get_latest_gnb_swupdate_time_from_snapshot(directory):
    """
    Get latest gNB software update time from SWDL file included in Snapshot.
    :param directory: path to Snapshot file.
    :return: latest swupdate time in datetime format, time in seconds passed since last swupdate.
    """
    bts_part_files = _get_bts_zip_files_list(directory)
    swdl_zipfile = _get_specific_snapshot_file(bts_part_files, "SWDLreport")
    with lzma.open(swdl_zipfile) as swdl_file:
        for line in swdl_file:
            if "Finished Activation" in line:
                swupdate_time = datetime.datetime.strptime(line[0:16], '%Y-%m-%dT%H:%M')
    current_time = datetime.datetime.now()
    time_since_last_swupdate = (current_time - swupdate_time).total_seconds()
    logging.info("Latest software update time:{}".format(swupdate_time))
    logging.info("Time since last software update:{}".format(time_since_last_swupdate))
    return swupdate_time, time_since_last_swupdate


def _get_bts_zip_files_list(directory):
    """
    Makes a list of objects from zip file
    :param directory: path to directory with snapshot
    :return: bts_part_files: object list taken from zip file
    """
    bts_part_files = []
    with zipfile.ZipFile(directory, "r") as snapshot:
        for name in snapshot.namelist():
            if re.search(r'BTS(?:\d+(_\d+)?)?_part(?:_)?\d+\.zip', name) is not None:
                snapshot_file = BytesIO(snapshot.read(name))
                bts_part_files.append(snapshot_file)
    if not bts_part_files:
        raise FileNotFound("The snapshot doesn't contain BTS logs.")
    return bts_part_files


def _get_rmod_zip_files_list(directory):
    """
        Makes a list of rmod objects from zip file
        :param directory: path to directory with snapshot
        :return: rmod_part_files: object list taken from zip file
        """
    rmod_part_files = []
    with zipfile.ZipFile(directory, "r") as snapshot:
        for name in snapshot.namelist():
            if re.search(r'BTS_[A-Z]{2}\d{9}_RMOD_L_\d{1}_\w+\.(zip|tar)', name) is not None:
                rmod_part_files.append(name)
    if not rmod_part_files:
        raise FileNotFound("The snapshot doesn't contain RMOD logs.")
    return rmod_part_files


def _get_files_from_zipfile_objects(zipfile_list):
    """
    Get list of all files from given zipfile objects.
    :param zipfile_list: list: List of zipfile objects.
    :return:
    file_list: list: List of all files which are included in zipfile objects archives.
    file_dict: dictionary: Dictionary of all files where keys are names of files and values are the sizes..
    """
    file_dict = {}
    for i in zipfile_list:
        with zipfile.ZipFile(i) as snapshot_bts:
            for name in snapshot_bts.namelist():
                file_dict.update({name: snapshot_bts.getinfo(name).compress_size})
    file_list = list(file_dict.keys())
    return file_list, file_dict


def _get_specific_snapshot_file(zipfile_list, filename_part):
    """
    Search for specific file zipped in Snapshot file.
    :param zipfile_list: list: List of zipfile objects.
    :param filename_part: string with wanted file from Snapshot.
    :return: BytesIO: wanted file object from Snapshot
    """
    for snapshot_file in zipfile_list:
        with zipfile.ZipFile(snapshot_file) as snapshot_part:
            for name in snapshot_part.namelist():
                if filename_part in name:
                    wanted_file = BytesIO(snapshot_part.read(name))
                    logging.info("File: {} found in Snapshot!".format(name))
                    return wanted_file
    raise FileNotFound("The snapshot does not contain the file with '{}' in name!".format(filename_part))
