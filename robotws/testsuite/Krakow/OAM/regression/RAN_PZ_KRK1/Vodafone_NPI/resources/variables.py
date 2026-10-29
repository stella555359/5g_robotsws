from re import compile
from taf.ul.alarms_watchdog import Alarm


_re_reason = compile(r'The\s+CPRI\s+synchronization\s+is\s+lost\s+on\s+cable\s+between\s+system\s+module\/extension\s+'
                     r'baseband\s+module(\/fronthaul\s+switch\s+module)?\s+and\s+radio\s+module.*')


custom_allowed_alarms_node_1 = [
    Alarm(fault_id='1815', fault_name='Not able to synchronize baseband bus', severity='Minor', reason=_re_reason),
    Alarm(fault_id='1815', fault_name='Not able to synchronize baseband bus', severity='Major', reason=_re_reason),
    Alarm(fault_id='2403', fault_name='Configuration mismatch between BSC and BTS', severity='Minor'),
    Alarm(fault_id='2412', fault_name='OMU signaling connection failure in Abis interface',
          severity='Minor'),
    Alarm(
        fault_id='7116', fault_name='No connection to unit',
        severity='Critical', reason='RU connection was lost in runtime'),
    Alarm(
        fault_id='6134', fault_name='EN DSS De-activated on partner side', severity='Minor'),
    Alarm(
        fault_id='6353', fault_name='SIB5 information incomplete', severity='Warning')
]


custom_allowed_alarms_node_2 = [
    Alarm(fault_id='1815', fault_name='Not able to synchronize baseband bus', severity='Minor', reason=_re_reason),
    Alarm(fault_id='1815', fault_name='Not able to synchronize baseband bus', severity='Major', reason=_re_reason),
    Alarm(fault_id='2403', fault_name='Configuration mismatch between BSC and BTS', severity='Minor', ),
    Alarm(fault_id='2412', fault_name='OMU signaling connection failure in Abis interface',
          severity='Minor'),
    Alarm(
        fault_id='7116', fault_name='No connection to unit',
        severity='Critical', reason='RU connection was lost in runtime'),
    Alarm(
        fault_id='6353', fault_name='SIB5 information incomplete', severity='Warning')
]


cdrt_iterations = {
    'SW Upgrade+Rollback with L3 call check': 1,
    'SW Upgrade+Rollback': 2,
    'SW Activation Reset': 10,
    'Site Reset': 10,
    'RU Reset': 20,
    'BB Reset': 10,
    'Delta Commissioning with Site Reset': 1,
    'Delta Commissioning with RAT reset': 1,
    'Delta Commissioning with online parameter change': 1,
    'Cell lock/unlock': 3,
    'Cell block/unblock': 3
}
