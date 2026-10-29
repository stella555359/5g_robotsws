import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations


def actions_with_ru(action):
    ru = GnbRuOperations()
    if action == "Reset":
        logger.log_info_to_console(f"Resseting All RUs via WebEm")
        ru.reset_all_radio_unit(timeout=240)
    elif action == "Lock":
        logger.log_info_to_console(f"Locking All RUs via WebEm")
        ru.lock_all_radio_unit()
    elif action == "Unlock":
        logger.log_info_to_console(f"Unlocking All RUs via WebEm")
        ru.unlock_all_radio_unit()
    else:
        logger.log_warn_to_console(f"Action: {action} not supported by this KW. Please contact with KW autor.")
