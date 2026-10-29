"""
:copyright: Nokia Networks
:author: Anna Bien
:maintainer:  Anna Bien
:team: I_5G_SW_MMW_PLKRK_04
:email: anna.bien@nokia.com
"""

import os
import subprocess as sp

from traceback import format_exc
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from ute_syslog import ute_syslog
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    collect_scf_file, collect_gnb_snapshot
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    copy_files_from_ap, copy_files_from_gnb
)
SYSLOG_ALIAS = 'syslog'


def start_collecting_basic_logs(log_dir=None, syslog_alias=SYSLOG_ALIAS, raise_exception=False):
    """
    Start collecting logs for the duration of the test case
    :param log_dir: Path to directory where logs will be stored.
    :param syslog_alias:
    :param raise_exception: (bool) Determine if function should be able to raise an exception
    :return: Absolute path to syslog file
    """
    syslog_filename = syslog_alias + '.log'
    log_dir = log_dir if log_dir is not None else _get_test_logs_dir()
    try:
        syslog_instance = ute_syslog()
        syslog_instance.start_syslog(
            log_dir=log_dir,
            log_name=syslog_filename,
            ip='192.168.255.126',
            alias=syslog_alias
        )
        assert os.path.exists(os.path.join(log_dir, syslog_filename))
    except AssertionError:
        logger.info(format_exc())
        if raise_exception:
            raise RuntimeError("Collecting {} has failed to start.".format(syslog_filename))
        logger.warn("Collecting {} has failed to start.".format(syslog_filename))
    return os.path.join(log_dir, syslog_filename)


def stop_collecting_basic_logs(log_dir=None, syslog_alias=SYSLOG_ALIAS, collect_basic_logs=True,
                               raise_exception=False):
    """
    Stop collecting logs and gather more basic logs.

    :param log_dir: (str) Path to directory where logs will be stored.
    :param syslog_alias: (str)
    :param collect_basic_logs: (bool)
    :param raise_exception: (bool) Determine if function should be able to raise an exception
    :return:
    """
    syslog_filename = syslog_alias + '.log'
    log_dir = log_dir if log_dir is not None else _get_test_logs_dir()
    try:
        syslog_instance = ute_syslog()
        syslog_instance.collect_syslog_results(destination=log_dir, alias=syslog_alias)
        kill_syslog_process(syslog_filename)
    except Exception:
        logger.info(format_exc())
        if raise_exception:
            raise RuntimeError("Collecting syslog has failed.")
        logger.warn("Collecting syslog has failed.")
    if collect_basic_logs:
        collect_logs(log_dir=log_dir)


def collect_logs(log_dir=None, raise_exception=False):
    """
    Gather basic logs: swconfig, iphy, scf, snapshot.

    :param log_dir: (str) Path to directory where logs will be stored.
    :param raise_exception: (bool) Determine if function should be able to raise an exception
    :return:
    """
    log_dir = log_dir if log_dir is not None else _get_test_logs_dir()
    try:
        copy_files_from_ap(files='/rom/simmode/iphy.xml', local_path=os.path.join(log_dir, 'iphy.xml'))
        copy_files_from_gnb(files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_gnb.txt'))
        copy_files_from_ap(files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_ap.txt'))
        collect_scf_file(final_path=os.path.join(log_dir, 'scf.xml'))
        collect_gnb_snapshot(output_filepath=os.path.join(log_dir, 'snapshot.zip'))
    except Exception:
        logger.info(format_exc())
        if raise_exception:
            raise RuntimeError("Logs collection has failed.")
        logger.warn("Logs collection has failed.")


def _get_test_logs_dir():
    """
    Returns absolute path to test logs dir.
    """
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    test_name = BuiltIn().get_variable_value("${TEST_NAME}")
    return os.path.join(output_dir, test_name)


def kill_syslog_process(syslog_filename):
    """
    Kill syslog process based on filename.
    """
    try:
        pid = sp.check_output(['pgrep', '-f', syslog_filename]).decode('ascii')
        if '\n' in pid:
            for num in pid.strip().split('\n'):
                sp.call(['kill', '-9', num])
        else:
            sp.call(['kill', '-9', pid.strip()])
        logger.info('Killed syslog process ({}) with pid {}'.format(syslog_filename, pid.strip().replace('\n', ',')))
    except sp.CalledProcessError:
        logger.info('Syslog process already stopped')


def get_default_syslog_alias():
    return SYSLOG_ALIAS
