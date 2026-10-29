import os.path

from taf.hw.optical_switch import optical_switch
import taf.rfrl.utilities.logger.custom_logger as logger
from typing import Iterator, Optional
from taf.transport.ssh.connection import Connection
from contextlib import contextmanager
from taf.transport.ssh.session import SSHSession
from taf.transport.ssh import ssh
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.utilities.test_config import get_repository_path
import subprocess


gnb_du = None


def get_gnb_du_object():
    global gnb_du
    if gnb_du is None:
        gnb_du = GnbDuOperations()
    return gnb_du


def upload_swconfig_to_bts():
    sw_config_path = '{}/testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010687/local_resources/configs/swconfig.txt'\
        .format(get_repository_path())
    get_gnb_du_object().upload_swconfig(sw_config_path=sw_config_path)


def get_sw_version_and_download_t1_build(target_dir="/home/ute/UUF_SW", remove_after_update=False):
    artifactory_url =\
        "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/"
    sw_version = get_sw_version()
    sw_version_raw = sw_version.without_t_suffix.raw_with_release
    build_path = target_dir + "/" + sw_version_raw + "_release_BTSSM_downloadable_testpackage_T1_A54.zip"
    if not os.path.isfile(build_path):
        url = artifactory_url + sw_version.get_release() + "/" + sw_version_raw + "/" + \
              sw_version_raw + "_release_BTSSM_downloadable_testpackage_T1_A54.zip"
        logger.log_info_to_console(f"Downloading T1 sw build from link {url}")
        wget_cmd = ['wget', '-P', str(target_dir), url]
        logger.log_info_to_console('Downloading build package with command: {}'.format(' '.join(wget_cmd)))
        proc = subprocess.Popen(wget_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise Exception('Software package has not been downloaded.\n STDOUT: {}\n STDERR: {}\n RETURN_CODE: {}'.
                            format(out, err, proc.returncode))
    update_sw_version(
        target_dir=target_dir, sw_version=sw_version_raw + "_release_BTSSM_downloadable_testpackage_T1_A54.zip")
    if remove_after_update:
        remove_downloaded_build(build_path)


def get_sw_version():
    sw_version = get_gnb_du_object().get_bts_sw_version()
    return SwVersionFactory.create_sw_version(sw_version)


def get_sw_version_release_name():
    return get_sw_version().get_release()


def remove_downloaded_build(sw_path=None):
    if sw_path is not None:
        logger.log_info_to_console(f"Trying remove package {sw_path}")
        rm_cmd = ['rm', '-rf', str(sw_path)]
        proc = subprocess.Popen(rm_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise Exception('Software package has not been removed.\n STDOUT: {}\n STDERR: {}\n RETURN_CODE: {}'.
                            format(out, err, proc.returncode))
        logger.log_info_to_console("Removing successful")


def update_sw_version(target_dir="/home/ute/UUF_SW", sw_version=None):
    if sw_version is None:
        raise Exception("Cannot perform sw update with 'None' build")
    logger.log_info_to_console("Performing update software")
    gnb_sw_update = GnbSwUpdate()
    gnb_sw_update.update_software(target_dir + "/" + sw_version, timeout=3600)


def rollback_bts():
    sw_version = get_sw_version()
    if sw_version.has_t1_suffix or sw_version.has_t2_suffix:
        logger.log_info_to_console(f"Starting SW rollback", log_hierarchy=1)
        get_gnb_du_object().rollback_software()
    else:
        logger.log_info_to_console(f"Rollback is not needed", log_hierarchy=1)


def modify_all_links(number_of_sectors: int, output_port: int, addr: str = '10.255.10.143'):
    switch = optical_switch()
    switch.setup_optical_switch(optical_switch='Leoni', model='mol 6x(2x6)', addr=addr)
    for sector_number in range(number_of_sectors):
        switch.set_optical_switch_channels({sector_number+1: output_port})
        verify_modify_link_is_success(sector_number+1, output_port, switch, logging=False)
    logger.log_info_to_console(f"All sectors changed to default value", log_hierarchy=2)
    switch.teardown()


def modify_link(sector: int, output_port: int, addr: str = '10.255.10.143'):
    switch = optical_switch()
    switch.setup_optical_switch(optical_switch='Leoni', model='mol 6x(2x6)', addr=addr)
    logger.log_info_to_console(f"Setting sector {sector} to output port: {output_port}")
    switch.set_optical_switch_channels({sector: output_port})
    verify_modify_link_is_success(sector, output_port, switch)
    switch.teardown()


def verify_modify_link_is_success(sector: int, output_port: int, switch_obj: optical_switch, logging: bool = True):
    channels = switch_obj.get_optical_switch_channels()
    if channels[sector] != output_port:
        raise ValueError(f"Sector {sector} does not have correct output port. Expected output port: {output_port}, "
                         f"Current output port: {channels[sector]}")
    if logging is True:
        logger.log_info_to_console(f"Sector {sector} changed successfully to port {output_port}", log_hierarchy=2)
    return True


def get_all_active_alarms(alarms_to_verify):
    conn = GnbAlarmVerification()
    all_active_alarms = conn.get_all_active_alarms()
    for alarm in all_active_alarms:
        if alarms_to_verify["configObjectName"] in alarm["configObjectName"] and \
                alarm["faultId"] == alarms_to_verify["faultId"]:
            if alarms_to_verify["supplAlarmInfo"] not in alarm["supplAlarmInfo"]:
                raise ValueError("Alarm was raised with wrong supplAlarmInfo description.")
            else:
                return True
    raise ValueError(f"Cannot find alarm with fid {alarms_to_verify['faultId']}")


@contextmanager
def use_ssh_connection(
        hostname: str,
        username: str,
        password: str,
        proxy: Optional[Connection] = None,
        throw_exception: bool = False) -> Iterator[SSHSession]:
    ssh_connection = ssh()
    err = None
    if proxy is not None:
        ssh_connection.connect_to(hostname=hostname, username=username, password=password, proxy=proxy)
    else:
        ssh_connection.connect_to(hostname=hostname, username=username, password=password)
    try:
        yield ssh_connection
    except Exception as err:
        logger.log_info_to_console(err)
    finally:
        ssh_connection.disconnect()
        if throw_exception:
            raise err
