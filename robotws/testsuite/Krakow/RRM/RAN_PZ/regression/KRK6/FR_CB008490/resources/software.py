"""
Software functions for CB008490 test suite

:copyright:     Nokia Networks
:author:        Piotr Brzezicki
:maintainer:    Piotr Brzezicki
:contact:       piotr.brzezicki@nokia.com
:team:          VRF_KRK_T06
"""
import logging
from typing import List, Dict, Tuple

from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.csv4all.resources.utilities.utilities import get_source_sw, get_target_sw
from taf.rfrl.utilities.logger import custom_logger as logger
from taf.rfrl.utilities.robot.decorators import log_as_robot_keyword
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.robot.parallel_runner import run_parallel_in_robot

from testsuite.Krakow.resources.UUF.get_uuf_builds import get_target_build

from .common import Misc
from .suite_specific import wait_for_btses_to_be_onair
from .variables.common import NUM_BTS_DEVICES


class Software:

    @log_as_robot_keyword
    def get_source_and_target_sw_from_artifacts_if_not_defined(self) -> Tuple[str, str]:
        """
        Retrieves source and target SW versions from artifacts if they are not already defined.

        :return: Tuple containing (source_sw, target_sw).
        """
        source_sw = get_builtin_value('SOURCE_SW')
        target_sw = get_builtin_value('TARGET_SW')
        source_sw = get_source_sw() if Misc.is_not_defined(source_sw) else source_sw
        target_sw = get_target_sw() if Misc.is_not_defined(target_sw) else target_sw
        return source_sw, target_sw

    @log_as_robot_keyword
    def set_sw_to_all_nodes(self, nodes: List[dict], source_sw: str, target_sw: str) -> None:
        """
        Assigns source and target software versions to all nodes in the provided list.

        :param nodes: List of node dictionaries to update.
        :param source_sw: Source software version string.
        :param target_sw: Target software version string.
        :return: None
        """
        for node in nodes:
            node['source_sw'] = source_sw
            node['target_sw'] = target_sw

    @log_as_robot_keyword
    def set_src_and_tgt_sw_to_nodes(self, nodes: List[Dict], sw_type: str) -> None:
        """
        Assigns software versions to nodes based on the specified type ('source' or 'target').

        :param nodes: List of node dictionaries to update.
        :param sw_type: Type of software version to assign ('source' or 'target').
        :return: None
        """
        src_sw = ""
        tgt_sw = ""
        if sw_type == 'cm_artifacts':
            src_sw, tgt_sw = self.get_source_and_target_sw_from_artifacts_if_not_defined()
        elif sw_type == 'target_sw':
            tgt_sw = str(get_target_build())
            src_sw = tgt_sw
        self.set_sw_to_all_nodes(nodes, src_sw, tgt_sw)

    @log_as_robot_keyword
    def upgrade_btses_sw_in_parallel(self, sw_version: str) -> None:
        """
        Upgrade SW on 2 BTSes in parallel
        :param sw_version: expected sw_version
        :return: None
        """
        sw_path = self.download_sw(sw_version)
        sw_update = GnbSwUpdate()
        list_of_functions = [{
            'function': sw_update.update_software,
            'function_kwargs': {'sw_package_dir': sw_path,
                                'timeout': 3600,
                                'bts_id': 0},
            'device_name': 'GNB0'
        },
            {
                'function': sw_update.update_software,
                'function_kwargs': {'sw_package_dir': sw_path,
                                    'timeout': 3600,
                                    'bts_id': 1},
                'device_name': 'GNB1'
            }]
        logger.log_info_to_console('Upgrading BTSes SW in parallel')
        run_parallel_in_robot(list_of_functions)

        wait_for_btses_to_be_onair()
        logger.log_banner_to_console('BTSes SW Upgrade Complete')

    @log_as_robot_keyword
    def upgrade_btses_sw_in_sequence(self, sw_version: str) -> None:
        """
        Upgrade SW on 2 BTSes in sequence
        :param sw_version: expected sw_version
        :return: None
        """
        sw_path = self.download_sw(sw_version)
        sw_update = GnbSwUpdate()
        for bts_id in range(NUM_BTS_DEVICES):
            logger.log_info_to_console(f'Upgrading bts_id={bts_id}')
            sw_update.update_software(sw_package_dir=sw_path, timeout=3600, bts_id=bts_id)

        self.wait_for_btses_will_have_active_sw_version(sw_version)
        wait_for_btses_to_be_onair()
        logger.log_banner_to_console('BTSes SW Upgrade Complete')

    @log_as_robot_keyword
    def download_sw(self, sw_version: str) -> str:
        """
        Downloads SBTS SW package and returns path to the package
        :param sw_version: desired package sw_version
        :return: path to package
        """
        dl_path = '/home/ute/.ute-ca/cache/bts'
        logging.debug(f'Downloading {sw_version} to {dl_path}')
        sw_path = GnbSwUpdate().download_sw_package(sw_version, dl_path)
        return sw_path

    @log_as_robot_keyword
    def check_active_sw_and_rollback_if_found_on_passive_partition(self, sw_version: str) -> None:
        """
        Check active and passive SW version on BTS and rollback if found on passive
        :param sw_version: expected sw_version
        """
        du_oper = GnbDuOperations()
        rollback = False
        for bts_id in range(NUM_BTS_DEVICES):
            if du_oper.check_bts_sw_version(sw_version=sw_version, partition='active', bts_id=bts_id):
                logger.log_info_to_console(f'bts_id={bts_id} active SW is {sw_version}')
                continue

            logger.log_info_to_console(f'Checking bts_id={bts_id} if passive partition has {sw_version}')
            if du_oper.check_bts_sw_version(sw_version=sw_version, partition='passive', bts_id=bts_id):
                logger.log_info_to_console(f'Starting SW rollback on bts_id={bts_id}')
                du_oper.rollback_software(bts_id=bts_id)
                rollback = True
            else:
                raise Exception(f'bts_id={bts_id} does not have {sw_version} on active nor passive partition')

        if rollback:
            self.wait_for_btses_will_have_active_sw_version(sw_version)
        wait_for_btses_to_be_onair()

    @log_as_robot_keyword
    def wait_for_btses_will_have_active_sw_version(self, sw_version: str,
                                                   interval: int = 30,
                                                   timeout: int = 300) -> None:
        """
        Wait until given sw_version is active on all BTSes
        :param sw_version: expected sw_version
        :param interval: interval between checks
        :param timeout: timeout for operation
        :return: None
        """
        for bts_id in range(NUM_BTS_DEVICES):
            GnbDuOperations().wait_until_sw_activated(sw_version=sw_version, bts_id=bts_id, interval=interval,
                                                      timeout=timeout)
            logger.log_info_to_console(f'bts_id={bts_id} active SW is {sw_version}')
