import time
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations


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
