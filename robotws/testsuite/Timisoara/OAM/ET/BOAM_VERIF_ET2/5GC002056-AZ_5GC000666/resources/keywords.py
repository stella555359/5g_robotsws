import csv
# import urllib2
import tarfile
import os
from robot.api import logger


def get_list_of_mandatory_files(documentation_path):
    with open(documentation_path, 'r') as rf:
        reader = csv.reader(rf, delimiter='!')
        mandatory_files = []
        for row in reader:
            split_row = row[0].split(';')
            try:
                if split_row[6] == '1' and 'ASIB' in split_row[0] and 'FSMr5' in split_row[3]:
                    mandatory_files.append(split_row[2])
            except IndexError:
                pass
        logger.info("List of mandatory files:\n {}".format(mandatory_files))
        if mandatory_files:
            if '/ram/ptp/*' in mandatory_files:
                mandatory_files.remove('/ram/ptp/*')
            return mandatory_files
        else:
            raise Exception("No mandatory files found")


# def download_from_artifactory(stream, file_name, output_path):
#     url = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/" + \
#           stream + '/' + file_name
#     fetch_file = urllib2.urlopen(url)
#     with open(output_path + file_name, 'wb') as output:
#         output.write(fetch_file.read())


def unpack_documentation(documentation_path, extract_path='.'):
    tar = tarfile.open(documentation_path, 'r')
    for item in tar:
        tar.extract(item, extract_path)
        if item.name.find(".tgz") != -1 or item.name.find(".tar") != -1:
            try:
                unpack_documentation(item.name, "./" + item.name[:item.name.rfind('/')])
            except IndexError:
                continue


def list_all_snapshot_files(snapshot_directory_path):
    snapshot_files = []
    for root, directories, files in os.walk(snapshot_directory_path):
        for f in files:
            snapshot_files.append(f[14:])
    logger.info("List of snapshot files:\n {}".format(snapshot_files))
    if snapshot_files:
        return snapshot_files
    else:
        raise Exception("Snapshot files not found")


def assert_all_snapshot_mandatory_files_exist(mandatory_files, snapshot_files):
    missing_files = []
    for mandatory_f in mandatory_files:
        if mandatory_f not in snapshot_files:
            missing_files.append(mandatory_f)
    logger.info("Snapshot is missing:\n {}".format(missing_files))
    if len(missing_files) > 0:
        raise Exception("Not all mandatory files are in snapshot")


def strip_software_version(software_version):
    software_version_split = software_version.split("_")
    if software_version_split[-3] == "0009":
        return "9." + software_version_split[-2].lstrip('0') + '.' + software_version_split[-1].lstrip('0')
    elif software_version_split[-2] == "000800":
        return "0." + software_version_split[-2].lstrip('0') + '.' + software_version_split[-1].lstrip('0')
    elif software_version_split[0] == "5G19B":
        return "7." + software_version_split[-2].lstrip('0') + '.' + software_version_split[-1].lstrip('0')
    if software_version_split[-3] == "0010":
        return "10." + software_version_split[-2].lstrip('0') + '.' + software_version_split[-1].lstrip('0')
    else:
        raise Exception("Please add new stream")
