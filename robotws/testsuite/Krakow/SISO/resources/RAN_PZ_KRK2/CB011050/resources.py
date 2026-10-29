"""
author: Maciej Russek, maciej.russek@nokia.com
maintainer: Maciej Russek, maciej.russek@nokia.com
description: Python helper methods
"""

import random
import taf.rfrl.utilities.logger.custom_logger as logger
import time
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.ul.sc.gnb.oam.rest.common_oam import CommonOAM
from robot.libraries.BuiltIn import BuiltIn


gnb_oam_ip = BuiltIn().get_variable_value('${tl.gnbs[0].cu.oam_http_connection_details.addr}')
mrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')
nrbts_id = BuiltIn().get_variable_value('${tl.gnbs[0].global_bts_id}')


def get_random_cell_ids(all_cell_ids, target_number_of_cells):
    random_cells = random.sample(all_cell_ids, int(target_number_of_cells))
    return random_cells


def action_with_prrhs(action, prrh_id=None):
    gnb_asir = GnbAsirHubOperations()
    if prrh_id is None:
        all_antennas_ids = gnb_asir.get_all_antenna_ids()
    else:
        all_antennas_ids = [int(prrh_id)]
    if action == 'Block':
        for antennas_id in all_antennas_ids:
            gnb_asir.block_antenna(ant_id=antennas_id)
            logger.log_info_to_console('Block pRRH_id: {}'.format(antennas_id))
        gnb_asir.verify_antennas_are_blocked(ant_ids=all_antennas_ids)
        logger.log_info_to_console('All antennas are blocked.')
    elif action == 'Unblock':
        for antennas_id in all_antennas_ids:
            gnb_asir.unblock_antenna(ant_id=antennas_id)
            logger.log_info_to_console('Unblock pRRH_id: {}'.format(antennas_id))
        gnb_asir.verify_all_antennas_are_enabled()
        logger.log_info_to_console('All pRRHs are unblocked')
    elif action == 'Reset':
        for antennas_id in all_antennas_ids:
            logger.log_info_to_console('Reset pRRH_id: {}'.format(antennas_id))
            gnb_asir.reset_antenna(ant_id=antennas_id)
            time.sleep(60)
            last_cleared_alarm = gnb_asir.get_historical_asir_webem_alarms()[-1]
            if not (last_cleared_alarm['fault_id'] == 4480
                    and last_cleared_alarm['source_object'] == 'ASI-1/ASI_R-1/ANTMOD_R-{}'.format(antennas_id)):
                raise Exception('Last cleared fault id alarm is not 4480')
            logger.log_info_to_console('pRRH_id: {} was restarted'.format(antennas_id))


def action_with_asir_hub(action):
    gnb_asir = GnbAsirHubOperations()
    all_hub_ids = gnb_asir.get_all_hub_ids()
    if action == 'Reset':
        for hub_id in all_hub_ids:
            logger.log_info_to_console('Reset hub{}'.format(hub_id))
            gnb_asir.reset_hub(hub_id=hub_id, timeout=360)
            time.sleep(180)
            logger.log_info_to_console('Hub{} was restarted'.format(hub_id))
    elif action == 'Lock':
        expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'blocked',
                             'hardwareState': 'working', 'softwareState': 'configured',
                             'activeStatusLEDColor': 'Yellow',
                             'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
        oam = CommonOAM(oam_ip=gnb_oam_ip, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
        for hub_id in all_hub_ids:
            logger.log_info_to_console('Locking hub{}'.format(hub_id))
            oam.lock_hub(hub_id=hub_id)
        gnb_asir.verify_hubmod_status(hub_ids=[eval(i) for i in all_hub_ids], expected_statuses=expected_statuses)
    elif action == 'Unlock':
        expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                             'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
                             'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
        oam = CommonOAM(oam_ip=gnb_oam_ip, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
        for hub_id in all_hub_ids:
            logger.log_info_to_console('Unlocking hub{}'.format(hub_id))
            oam.unlock_hub(hub_id=hub_id)
        gnb_asir.verify_hubmod_status(hub_ids=[eval(i) for i in all_hub_ids], expected_statuses=expected_statuses)
