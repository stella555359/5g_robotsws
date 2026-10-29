import os
from robot.api import logger
from robot.api.deco import keyword
from taf.sbts.oam.coam.admin import admin
import time
from taf.ul.alarms_watchdog import Alarm


@keyword(name="Update BTS Software")
def update_bts_software(connection, path_to_sw, bts_ip, force_reset, timeout=1800):
    """
    Perform software update.

    :param connection: AdminConnection object or if used, string name alias.
    :type connection:  AdminConnection or str
    :param path: Path to software package
    :type path: str
    :param bts_ip: BTS IP
    :type bts_ip: str
    :param force_reset: Execute reset if it's not executed after SW update
    :type force_reset: str (True/False)
    :param timeout: Time to wait for sw update procedure update result.
    :param timeout:  int
    """
    adm = admin()
    logger.console("\n[robot] Starting BTS SW update")
    status = adm.update_software(sw_package=path_to_sw, connection=connection, timeout=timeout)
    if status != "Software update has been completed":
        logger.console("[robot] SW update failed")
        return "Fail"
    logger.console("[robot] SW update completed. Waiting BTS reset")
    if ping_until_unavailable(bts_ip):
        logger.console("[robot] BTS reset detected")
        logger.console("[robot] Waiting 5 minutes before continue...")
        time.sleep(300)
    else:
        logger.console("[robot] BTS reset not detected")
        if (force_reset == "True"):
            logger.console("[robot] Force reset parameter is True. Executing BTS reset")
            result = adm.reset_site(connection=connection, wait_for_reconnection=True)
            logger.console("[robot] BTS reset completed. Status: {}".format(result))
        else:
            logger.console("[robot] Force reset parameter is False. BTS reset not executed")
    return status


@keyword(name="Get Allowed Alarms From File")
def get_allowed_alarms_from_file(filename):
    content = []
    with open(filename) as f:
        content = f.read().splitlines()
    alarms = []
    for a in content:
        alarms.append(Alarm(fault_name=a))
    return alarms


@keyword(name="Ping Until Unavailable")
def ping_until_unavailable(host_ip="192.168.255.129", max_number_of_tries=60):
    """
    Ping host and find and message in output.
    :param host_ip: host ip adress
    :param max_number_of_tries: maximum number of ping tries
    :return: True when host doesn't reply to ping
    """
    current_try = 0
    max_number_of_tries = int(max_number_of_tries)
    command = 'ping {} -c 1 > /dev/null 2>&1'.format(host_ip)
    while current_try < max_number_of_tries:
        output = os.system(command)
        if output != 0:
            return True
        else:
            current_try += 1
            time.sleep(5)
            if current_try == max_number_of_tries:
                return False
