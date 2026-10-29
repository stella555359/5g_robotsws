from taf.ul.alarms_watchdog import Alarm

_allowed_alarms_for_enb = [Alarm(fault_name='Service account root access is enabled'),
                           Alarm(fault_name='SSH enabled'),
                           Alarm(fault_name='No X2 link available'),
                           Alarm(fault_name='No X2 link available for a specific LTEENB'),
                           Alarm(fault_name='Ethernet port security is disabled'),
                           Alarm(fault_name='NTP Server 10.44.138.23 unavailable'),
                           Alarm(fault_name='NTP Server 10.42.129.251 unavailable'),
                           Alarm(fault_name='LMP access via port'),
                           Alarm(fault_name='LMP access via port 443'),
                           Alarm(fault_name='LMP access via port 3600'),
                           Alarm(fault_name='R&D Service Port enabled'),
                           Alarm(fault_name='Sanity Check Error'),
                           Alarm(fault_name='SAS Heartbeat Failure'),
                           Alarm(fault_name='SAS Spectrum Inquiry Failure'),
                           Alarm(fault_name='SAS Grant Suspension Failure'),
                           Alarm(fault_name='SAS Grant Termination Revocation Failure'),
                           Alarm(fault_name='SAS Server Communication Failure'),
                           Alarm(fault_name='Setup of X2 connectivity to gNB failed'),
                           Alarm(fault_name='PPS reference from backplane missing.'),
                           Alarm(fault_name='Reference clock missing in startup'),
                           Alarm(fault_name='BTS Reset Cause'),
                           Alarm(fault_name='Cell blocked'),
                           Alarm(fault_name='No connection to unit'),
                           Alarm(fault_name='User Account has Default Password'),
                           ]


def get_default_allowed_alarms_for_enb():
    """
    Gets default allowed alarms for eNB BTS.
    :return: list of default allowed alarms read from _allowed_alarms_for_enb variable in alarms.py.
    Each alarm is converted to Alarm object from taf.ul.alarms-watchdog library.
    :rtype: list(Alarm)
    """
    return _allowed_alarms_for_enb
