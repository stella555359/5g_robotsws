"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

import os
from robot.api import logger
from ute_syslog import ute_syslog
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb import (
    collect_scf_file, collect_gnb_snapshot
)
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import (
    copy_files_from_ap, copy_files_from_gnb
)
SYSLOG_ALIAS = 'basic_syslog'


def start_collecting_basic_logs(log_dir, syslog_alias=SYSLOG_ALIAS):
    """
    Start collecting logs for the duration of the test case
    :param log_dir: Path to directory where logs will be stored.
    :param syslog_alias:
    :return:
    """
    try:
        syslog_instance = ute_syslog()
        syslog_instance.start_syslog(
            log_dir=log_dir,
            log_name='syslog.log',
            ip='192.168.255.126',
            alias=syslog_alias
        )
    except Exception as err:
        logger.warn("Collecting syslog failed to start.")
        logger.info(err)


def stop_collecting_basic_logs(log_dir, syslog_alias=SYSLOG_ALIAS, collect_basic_logs=True):
    """
    Stop collecting logs and gather more basic logs.

    :param log_dir: (str) Path to directory where logs will be stored.
    :param syslog_alias: (str)
    :param collect_basic_logs: (bool)
    :return:
    """
    try:
        syslog_instance = ute_syslog()
        syslog_instance.collect_syslog_results(destination=log_dir, alias=syslog_alias)
    except Exception as err:
        logger.warn("Collecting syslog failed.")
        logger.info(err)
    if collect_basic_logs:
        collect_logs(log_dir=log_dir)


def collect_logs(log_dir):
    """
    Gather basic logs: swconfig, iphy, scf, snapshot.

    :param log_dir: (str) Path to directory where logs will be stored.
    :return:
    """
    try:
        copy_files_from_ap(files='/rom/simmode/iphy.xml', local_path=os.path.join(log_dir, 'iphy.xml'))
        copy_files_from_gnb(files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_gnb.txt'))
        copy_files_from_ap(files='/rom/swconfig.txt', local_path=os.path.join(log_dir, 'swconfig_ap.txt'))
        collect_scf_file(final_path=os.path.join(log_dir, 'scf.xml'))
        collect_gnb_snapshot(output_filepath=os.path.join(log_dir, 'snapshot.zip'))
    except Exception as err:
        logger.warn("Logs collection failed.")
        logger.info(err)
