import time

from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.utilities.tl_config import get_radio_serial_number


def collect_radio_unit_log(success_regex=None, bts_id=0, du_id=0, ru_id=0, timeout=120):
    """
    Collect RU log.
    """
    device = GnbRuOperations().get_ru_device(bts_id=bts_id, du_id=du_id, ru_id=ru_id, detect_ru_host=True)
    ru_serial = get_radio_serial_number(bts_id=bts_id, du_id=du_id, ru_id=ru_id)
    date_time = time.strftime("%d%m%Y_%H%M%S", time.localtime())
    cmd_log = device.get_cmd(cmd_name='run_script',
                             cmd_params={
                                 "script_command": f"log -c full -a -z log_RU{ru_id}SN{ru_serial}_{date_time}.zip",
                                 "success_regex": success_regex})
    return cmd_log(timeout=timeout)


def collect_logs_from_multiple_radio_units(bts_id=0, du_id=0, timeout=120):
    collect_radio_unit_log(bts_id=bts_id, du_id=du_id, ru_id=6, timeout=timeout)
    # collect_radio_unit_log(bts_id=bts_id, du_id=du_id, ru_id=5, timeout=timeout)
