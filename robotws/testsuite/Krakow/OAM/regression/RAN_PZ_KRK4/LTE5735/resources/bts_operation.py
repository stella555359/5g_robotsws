import time
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def perform_site_reset(sleep_after_site_reset=30):
    log_info_to_console('Site Reset', log_hierarchy=2)
    bts = GnbDuOperations()
    bts.reset_bts()
    time.sleep(sleep_after_site_reset)


def perform_prrh_block_unblock():
    asir = GnbAsirHubOperations()
    log_info_to_console('pRRh Block', log_hierarchy=2)
    asir.block_antenna()
    time.sleep(60)  # Wait until block finished
    log_info_to_console('pRRh Unblock', log_hierarchy=2)
    asir.unblock_antenna()
    time.sleep(60)  # Wait until unblock finished


def perform_hub_reset():
    asir = GnbAsirHubOperations()
    log_info_to_console('Hub Reset', log_hierarchy=2)
    asir.reset_hub()


def perform_reset_asir_configuration(sleep_after_configuration_reset=120):
    asir = GnbAsirHubOperations()
    log_info_to_console('Reset ASiR Configuration', log_hierarchy=2)
    asir.reset_configuration()
    time.sleep(sleep_after_configuration_reset)


def perform_prrh_reset():
    asir = GnbAsirHubOperations()
    log_info_to_console('pRRh Reset', log_hierarchy=2)
    asir.reset_antenna(timeout=360)
