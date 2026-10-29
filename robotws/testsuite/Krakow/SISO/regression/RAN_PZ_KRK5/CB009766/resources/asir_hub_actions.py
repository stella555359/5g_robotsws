import time
from taf.ul.sc.gnb.oam.rest.common_oam import CommonOAM
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations


def action_with_asir_hub(action, gnb_oam_ip, mrbts_id, nrbts_id):
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
