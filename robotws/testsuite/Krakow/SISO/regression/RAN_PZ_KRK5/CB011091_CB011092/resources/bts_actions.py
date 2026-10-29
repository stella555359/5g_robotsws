import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def action_with_bts(action):
    gnb_du = GnbDuOperations()
    if action == 'Block':
        logger.log_info_to_console("Performing action: Block gNB")
        gnb_du.block_bts()
        gnb_du.verify_bts_states(blocking_state="Blocked")
    elif action == 'Unblock':
        logger.log_info_to_console("Performing action: Unblock gNB")
        gnb_du.unblock_bts(timeout=600)
        gnb_du.verify_bts_states(blocking_state="Unblocked")
