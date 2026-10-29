import time
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification


def wait_for_alarms_activation(alarms, activation_times):
    gnb_alarms = GnbAlarmVerification()
    for idx in range(len(alarms)):
        gnb_alarms.wait_for_alarm_activation(fault_id=alarms[idx], awaiting_time=activation_times[idx])


def wait_after_links_lock(waiting_time=30):
    time.sleep(waiting_time)


def wait_after_attenuation_change(waiting_time=30):
    time.sleep(waiting_time)
