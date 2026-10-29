from taf.ul.alarms_watchdog import Alarm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

CUSTOM_ALARMS = []

DSS_ALARMS = [Alarm(fault_id='62003'), Alarm(fault_id='7307'), Alarm(fault_id='4122'),
              Alarm(fault_id='4125'), Alarm(fault_id='1898'), Alarm(fault_id='4123'), Alarm(fault_id='4124'),
              Alarm(fault_id='9'), Alarm(fault_id='8158'), Alarm(fault_id='8150'), Alarm(fault_id='7220'),
              Alarm(fault_id='7509'), Alarm(fault_id='4694'), Alarm(fault_id='4011'), Alarm(fault_id='1898'),
              Alarm(fault_id='2412'), Alarm(fault_id='4385'), Alarm(fault_id='6150'), Alarm(fault_id='6134'),
              Alarm(fault_id='7513'), Alarm(fault_id='6203')]

CUSTOM_ALARMS.extend(DSS_ALARMS)

SOURCE_SW = 'SBTS24R3_ENB_0000_000782_000012'
TARGET_SW = 'SBTS00_ENB_9999_241208_000008'

ues = ['REAL_UE_SA', 'REAL_UE']

try:
    INIT_HOSTNAME = tl.hostname
except BaseException:
    INIT_HOSTNAME = None
