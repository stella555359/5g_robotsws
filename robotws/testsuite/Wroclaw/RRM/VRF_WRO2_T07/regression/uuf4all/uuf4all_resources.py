from taf.ul.alarms_watchdog import Alarm

CUSTOM_ALARMS = [Alarm(fault_id='4681', fault_name='Sanity Check Error')]

DSS_ALARMS = [Alarm(fault_id='62003'), Alarm(fault_id='7509'), Alarm(fault_id='4011'), Alarm(fault_id='1898'),
              Alarm(fault_id='7107'), Alarm(fault_id='7523')]
CUSTOM_ALARMS.extend(DSS_ALARMS)

SOURCE_SW = 'SBTS24R3_ENB_0000_000782_000012'
TARGET_SW = 'SBTS00_ENB_9999_241208_000008'
