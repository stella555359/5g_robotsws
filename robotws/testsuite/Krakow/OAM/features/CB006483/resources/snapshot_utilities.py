import datetime
import os
import re
import time
import zipfile
from contextlib import contextmanager

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

tl = BuiltIn().get_variable_value("${tl}")


class SnapshotNotUploadedOnServer(Exception):
    pass


class NotImplementedServer(Exception):
    pass


@contextmanager
def connect_to_remote_snapshot_destination(hostname, username, password):
    ssh_connection = ssh()
    ssh_connection.connect_to(hostname=hostname, username=username, password=password)
    try:
        yield ssh_connection
    except Exception as err:
        logger.console(err)
    finally:
        ssh_connection.disconnect()


def get_snapshot_details(result, snap_regex):
    logger.debug('Regex to find: {}'.format(snap_regex))
    snapshots_list = re.findall(snap_regex, result)
    logger.debug('List of snapshot {}'.format(snapshots_list))
    return snapshots_list


def get_testline_name():
    address = tl.test_pc.default_ssh_connection_details.addr
    tl_name = address.split('.')[0].replace('-', '_')
    logger.info(tl_name)
    return tl_name


def get_list_of_snapshots_from_remote_server(snap_location, snap_regex, host, username, password):
    if not snap_regex:
        tl_name = get_testline_name()
        mrbts_id = tl.gnbs[0].instance_id
        snap_regex = r"Snapshot_MRBTS-{}_{}_SBTS.*".format(mrbts_id, tl_name)
    with connect_to_remote_snapshot_destination(hostname=host, username=username, password=password) as connection:
        result = connection.execute("ls -ltr {}".format(snap_location))
        snap_list = get_snapshot_details(result, snap_regex)
        return snap_list


def wait_for_snapshot_on_remote_server(timestamp, path, server, host, username, password, snap_regex=None, timeout=60,
                                       raise_exception=True):
    logger.console(f'Waiting for Snapshot on {server} {host}...')
    start_time = time.time()
    while time.time() < start_time + float(timeout):
        snap_list = get_list_of_snapshots_from_remote_server(path, snap_regex, host, username, password)
        if snap_list:
            for snap in snap_list:
                snap_time = snap.split('.')[0].split('_')[-1].replace('-', '')
                if snap_time >= timestamp:
                    if server == "LSS":
                        snapshot_path = path + "/" + snap.strip() + "/" + "snapshotHistory.txt"
                        if is_remote_dir_contain_file(snapshot_path, host, username, password, timeout=30):
                            logger.console('Snapshot found. Location: {}'.
                                           format(os.path.join(path, snap_list[-1])))
                            return
                    elif server == "NetAct":
                        logger.console('Snapshot found. Location: {}'.format(os.path.join(path, snap_list[-1])))
                        return True
                    else:
                        raise NotImplementedServer
        time.sleep(10)
    if raise_exception:
        raise SnapshotNotUploadedOnServer("Timeout waiting for Snapshot on {}.".format(server))
    else:
        return False


def wait_until_snapshot_starts_upload_on_LSS(timestamp, path, host, username, password, snap_regex=None, timeout=60):
    logger.console('Waiting until snapshot starts upload on LSS...')
    start_time = time.time()
    while time.time() < start_time + float(timeout):
        snap_list = get_list_of_snapshots_from_remote_server(path, snap_regex, host, username, password)
        if snap_list:
            for snap in snap_list:
                snap_time = snap.split('.')[0].split('_')[-1].replace('-', '')
                if snap_time >= timestamp:
                    logger.console('Snapshot upload to LSS has been started to location: {}'.
                                   format(os.path.join(path, snap_list[-1])))
                    return
        time.sleep(5)
    raise SnapshotNotUploadedOnServer("Timeout waiting for starting upload Snapshot on LSS")


def is_remote_dir_contain_file(path, host, username, password, timeout):
    with connect_to_remote_snapshot_destination(hostname=host, username=username, password=password) as connection:
        return connection.file_exists(remote_path=path, timeout=timeout)


def check_if_snapshot_is_not_on_lss(timestamp, snap_location, host, username, password, timeout):
    try:
        wait_for_snapshot_on_remote_server(timestamp, snap_location, "LSS", host, username, password, timeout=timeout)
    except SnapshotNotUploadedOnServer:
        time.sleep(5)
    else:
        raise Exception("Snapshot uploaded on LSS")


def check_if_snapshot_is_not_on_netact(timestamp, snap_location, host, username, password, timeout, raise_exception):
    try:
        wait_for_snapshot_on_remote_server(timestamp, snap_location, "NetAct", host, username, password,
                                           timeout=timeout, raise_exception=raise_exception)
    except SnapshotNotUploadedOnServer:
        time.sleep(5)
    else:
        raise Exception("Snapshot uploaded on NetAct")


def create_directories_on_lss(directories, parent_dir, user, group):
    with connect_to_remote_snapshot_destination(hostname=tl.test_pcs[1].default_ssh_connection_details.addr,
                                                username=tl.test_pcs[1].default_ssh_connection_details.username,
                                                password=tl.test_pcs[1].default_ssh_connection_details.password) \
            as connection:
        full_path = os.path.join(parent_dir, user, directories)
        logger.info('Directories {} was created.'.format(full_path))
        connection.execute('mkdir -p {}'.format(full_path))
        home_path = os.path.join(parent_dir, user)
        connection.execute('sudo chmod -R 777 {}'.format(home_path))
        connection.execute('sudo chown -R {}:{} {}'.format(user, group, home_path))


def delete_directories_on_lss(directories, parent_dir, user):
    with connect_to_remote_snapshot_destination(hostname=tl.test_pcs[1].default_ssh_connection_details.addr,
                                                username=tl.test_pcs[1].default_ssh_connection_details.username,
                                                password=tl.test_pcs[1].default_ssh_connection_details.password) \
            as connection:
        first_dir = directories.split('/')[0]
        full_path = os.path.join(parent_dir, user, first_dir)
        logger.info('Delete {}.'.format(full_path))
        connection.execute('sudo rm -rf {}'.format(full_path))


def change_interface_state_on_lss(interface, state, host, username, password):
    with connect_to_remote_snapshot_destination(hostname=host, username=username, password=password) as connection:
        connection.execute('sudo ip link set dev {} {}'.format(interface, state))
        if state == "up":
            time.sleep(1)
            connection.execute('sudo systemctl restart networking.service')


def unpack_all_file_from_zip(path_to_zip_file, path_to_unzip):
    """
    Unpack specific file from given zip archive.
    :param string path_to_zip_file: Path to zip archive.
    :param string path_to_unzip: Path where file will be unpacked.
    :return: string: Full path to unzipped file.

    """
    if os.path.isfile(path_to_zip_file):
        with zipfile.ZipFile(path_to_zip_file, 'r') as zip_file:
            zip_file.extractall(path_to_unzip)
    else:
        raise Exception("The given zip file doesn't exist. Please check the path: {}".format(path_to_zip_file))


def get_snapshot_file_organization(file_folder):
    """
    Get files structure of given snapshot
    :param file_folder: path to snapshot directory
    :return: tree file structure of snapshot
    """
    import re
    snapshot_file = os.path.join(file_folder, "snapshot_file_list.txt")
    file_tree = {}
    with open(snapshot_file, "r") as snapshot_files:
        file_structure = snapshot_files.read().split("\n\n")
        for file in file_structure:
            if file.count(".zip") > 0:
                zip_info = re.split(":.*\n", file)
                file_tree[zip_info[0]] = []
                file_list = zip_info[1].splitlines()
                for file_name in file_list:
                    file_tree[zip_info[0]].append(file_name.strip())
            else:
                file_tree[file] = None
    return file_tree


def get_file_from_snapshot_by_key(key_name, snapshot_structure):
    """
    Check if snapshot contains given file
    :param key_name: file name
    :param snapshot_structure: output returned by get_snapshot_file_organization function
    :return: file directory and file
    """
    for key, value in snapshot_structure.items():
        if key.count(".zip") > 0:
            for name in value:
                if name.count(key_name) > 0:
                    return key, name
        else:
            if key.count(key_name) > 0:
                return file_folder, key
