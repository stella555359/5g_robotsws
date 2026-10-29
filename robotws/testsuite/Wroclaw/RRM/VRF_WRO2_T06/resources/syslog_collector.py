import os
import traceback
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ute_syslog import ute_syslog
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.transport.ssh import ssh
from contextlib import contextmanager

syslog_instance = ute_syslog()
tl_cfg = get_builtin_value(param_name="tl")
vm2_address = tl_cfg.test_pcs[1].default_ssh_connection_details.addr
vm_username = tl_cfg.test_pcs[0].default_ssh_connection_details.username
vm_password = tl_cfg.test_pcs[0].default_ssh_connection_details.password


def start_collecting_syslog_from_gnbs(log_dir=None, virt_env='/home/ute/test_repo'):
    """
    Collect syslogs for both gNBs.
    Syslog files are stored on gNB's corresponding VMs in location specified by 'log_dir'.

    :param log_dir: (str)
    :param virt_env: (str) Path to virtual python environment directory
    """

    def start_syslog(unit, host_ip):
        """
        Start syslog for single unit.

        :param unit: (str) 'gnb1' or 'gnb2'
        :param host_ip: (str) VM IP address
        """

        logger.info(f'Starting syslog_{unit}')
        try:
            syslog_instance.start_syslog(
                log_dir=log_dir,
                log_name=f'syslog_{unit}.log',
                host_ip=host_ip,
                virtualenv_dir=virt_env,
                alias=f'syslog_{unit}'
            )
        except Exception:
            logger.info(traceback.format_exc())
            logger.warn(f'Collecting syslog_{unit} has failed to start.')

    log_dir = log_dir if log_dir else _get_log_dir()
    try:
        assert os.path.exists(virt_env), f'Virt_env directory: {virt_env} does not exist!'
    except AssertionError as exception:
        logger.warn(exception)
    start_syslog(unit='gnb1', host_ip='127.0.0.1')
    start_syslog(unit='gnb2', host_ip=vm2_address)


def stop_collecting_syslog_and_download_files(log_dir=None):
    """
    Stop collecting syslog for both gNBs and copy files.

    :param log_dir: (str) path (on VM1) where syslog from gNB2 will be copied to
    """

    log_dir = log_dir if log_dir is not None else _get_log_dir()
    try:
        syslog_instance.stop_syslog(alias='syslog_gnb1')
    except Exception:
        logger.info(traceback.format_exc())
        logger.warn('Collecting syslog_gnb1.log has failed.')
    try:
        syslog_instance.stop_syslog(alias='syslog_gnb2')
    except Exception:
        logger.info(traceback.format_exc())
        logger.warn('Collecting syslog_gnb2.log has failed.')
    try:
        download_files_from(
            ip_addr=vm2_address, username=vm_username, password=vm_password,
            files=os.path.join(log_dir, 'syslog_gnb2.log'), local_path=os.path.join(log_dir, 'syslog_gnb2.log')
        )
    except IOError:
        logger.warn('Could not download syslog_gnb2.log file.')

    _validate_if_log_files_exist(filenames=['syslog_gnb1.log', 'syslog_gnb2.log'])


def _get_log_dir():
    """
    Get default directory for storing logs.
    """

    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    try:
        return os.path.join(output_dir, BuiltIn().get_variable_value("${TEST_NAME}"))
    except TypeError:
        logger.info('Logs collected in suite logs dir.')
        return os.path.join(output_dir, BuiltIn().get_variable_value("${SUITE_NAME}"))


def _validate_if_log_files_exist(filenames, log_dir=None):
    """
    Check if path to log exist on local VM.

    :param filenames: (list or str)
    :param log_dir: (str)
    """

    log_dir = log_dir if log_dir is not None else _get_log_dir()
    if not isinstance(filenames, list):
        filenames = [filenames]
    for filename in filenames:
        assert os.path.exists(os.path.join(log_dir, filename)), \
            f'File: {os.path.join(log_dir, filename)} does not exist!'
        logger.info(f'File: {os.path.join(log_dir, filename)} exists')


@contextmanager
def ssh_session(ip_addr, username, password):
    """
    It yields ssh connection and finally closes it.

    :param ip_addr: remote ip address
    :param username: remote's username
    :param password: password to remote
    :return connection: an established ssh connection to remote
    """
    connection = ssh()
    connection.connect_to(hostname=ip_addr, username=username, password=password)
    try:
        yield connection
    finally:
        connection.disconnect()


def download_files_from(ip_addr, username, password, files, local_path):
    """
    It dwonloads files from remote to the remote path

    :param ip_addr: remote ip address
    :param username: remote's username
    :param password: password to remote
    :param files: a list of paths on remote to files which should be copied
    :param local_path: a path to which files should be copied
    :return: nothing
    """
    with ssh_session(ip_addr, username, password) as connection:
        connection.download_file(remote_path=files, local_path=local_path)
