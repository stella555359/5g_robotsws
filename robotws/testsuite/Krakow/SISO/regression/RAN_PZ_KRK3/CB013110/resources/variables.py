from taf.ul.alarms_watchdog import Alarm

allowed_alarms = [
    Alarm(fault_id='4655', fault_name='Service account root access is enabled', severity='Minor'),
    Alarm(fault_id='61524', fault_name='SSH enabled', severity='Minor'),
    Alarm(fault_id='4654', fault_name='Ethernet port security is disabled', severity='Minor'),
    Alarm(fault_id='61652', fault_name='R&D Service Port enabled', severity='Minor'),
    Alarm(fault_id='61648', fault_name='LMP connectivity detected', severity='Minor'),
    Alarm(fault_id='61649', fault_name='LMP access via port 443', severity='Minor')
]

allowed_alarms_during_tl_preparation = ['61675', '4480 ', '4478', '4479', '61524', '61648', '61652',
                                        '4681', '61649', '4655', '4654', '4592']
