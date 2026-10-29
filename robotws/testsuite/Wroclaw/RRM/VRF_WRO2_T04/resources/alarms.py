import time
from robot.api import logger
from taf.gnb.oam.coam.admin import admin as taf_admin


def wait_for_fault(fault, timeout=300, interval=10):
    admin = taf_admin()
    admin.connect_to()

    end = time.time() + float(timeout)
    is_ok = False
    try:
        while not is_ok and not (end < time.time()):
            logger.info("Waiting for fault {}...".format(fault), also_console=True)
            time.sleep(interval)
            alarms = admin.get_active_alarms()
            is_ok = _check_alarm_presence(fault, alarms)
            if is_ok:
                return
        assert is_ok, "Fault {} is still not visible!".format(fault)
    finally:
        admin.teardown()


def wait_for_fault_clear(fault, timeout=300, interval=10):
    admin = taf_admin()
    admin.connect_to()

    end = time.time() + float(timeout)
    is_ok = False
    try:
        while not is_ok and not (end < time.time()):
            logger.info("Waiting for fault {} clear ...".format(fault), also_console=True)
            time.sleep(interval)
            alarms = admin.get_active_alarms()
            is_ok = not _check_alarm_presence(fault, alarms)
            if is_ok:
                return
        assert is_ok, "Fault {} is still visible!".format(fault)
    finally:
        admin.teardown()


def _check_alarm_presence(fault, alarms):
    return int(fault) in [int(alarm.get('faultId')) for alarm in alarms]
