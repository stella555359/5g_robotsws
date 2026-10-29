from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession


def get_rmod_serial_numbers(rmod_type):
    with AdminSession() as admin:
        return [r['serialNumber'] for r in admin.get_frm() if r['productName'] == rmod_type]


def verify_snapshot(rmod_type, snapshot_location):
    serial_numbers = get_rmod_serial_numbers(rmod_type)
    rmods = {}
    for serial in serial_numbers:
        logger.info(f"\n<< RMOD: {rmod_type}, SN: {serial} >>", also_console=True)

        with open(f'{snapshot_location}/snapshot_file_list.txt', 'r') as snapshot_file_list:
            snapshot_lines = snapshot_file_list.readlines()

        rmods[serial] = {
            "startup": False,
            "runtime": False,
            "pm_1_syslog": False,
            "pm_2_syslog": False
        }

        for line in snapshot_lines:
            if serial in line:
                if "startup.zip" in line:
                    logger.info(f"    startup: {line.strip()}")
                    rmods[serial]["startup"] = True
                if "runtime.zip" in line:
                    logger.info(f"    runtime: {line.strip()}")
                    rmods[serial]["runtime"] = True
                if "pm_1_syslog" in line or "pm1_flash_logs" in line:
                    logger.info(f"    pm_1_syslog: {line.strip()}")
                    rmods[serial]["pm_1_syslog"] = True
                if "pm_2_syslog" in line or "pm2_flash_logs" in line:
                    logger.info(f"    pm_2_syslog: {line.strip()}")
                    rmods[serial]["pm_2_syslog"] = True

        if not rmods[serial]["startup"]:
            logger.error(f"[MISSING] startup for RMOD: {rmod_type} {serial}")
        if not rmods[serial]["runtime"]:
            logger.error(f"[MISSING] runtime for RMOD: {rmod_type} {serial}")
        if not rmods[serial]["pm_1_syslog"]:
            logger.warn(f"[MISSING][OPTIONAL] pm_1_syslog for RMOD: {rmod_type} {serial}")
        if not rmods[serial]["pm_2_syslog"]:
            logger.warn(f"[MISSING][OPTIONAL] pm_2_syslog for RMOD: {rmod_type} {serial}")
    rmods_missing_startup_or_runtime = [{serial: rmods[serial]} for serial in serial_numbers
                                        if not (rmods[serial]["startup"] and rmods[serial]["runtime"])]
    assert not rmods_missing_startup_or_runtime, \
        f'Detected RMODs with missing startup or runtime: {rmods_missing_startup_or_runtime}'
