from robot.libraries.BuiltIn import BuiltIn
import time
import json
import yaml
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_LNBTSname = _MRBTSname+'/LNBTS-'+_gnb_id

_RMOD1 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-1'
_RMOD2 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-2'
_RMOD3 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-3'
year = time.localtime().tm_year
month = time.localtime().tm_mon
day = time.localtime().tm_mday
date = datetime.date(datetime(year=year, month=month, day=day))
index = datetime.date(datetime(year=year, month=month, day=day)).weekday()
weekday = date.strftime("%a")

Modify_Para_Online_AVHA_DSM = [
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Mon', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Wed', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Thu', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Fri', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Sat', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Sun', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended')
        ],
         dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Mon', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Wed', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Thu', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Fri', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Sat', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Sun', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended')
    ],
        dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsDayOfWeek='Tue', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Mon', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Wed', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Thu', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Fri', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='notSuspended'),
        dict(lbpsDayOfWeek='Sat', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended'),
        dict(lbpsDayOfWeek='Sun', lbpsDuration='60',
             lbpsStartTimeHour='8', lbpsStartTimeMinute='0', lbpsSuspended='suspended')
    ],
        dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='301'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='311'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='21'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='1'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='2'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='2'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='2'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='2'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='2'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='2'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='302'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='312'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='22'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='2'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsCellPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='3'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Mon', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Tue', lbpsCellDuration='60', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Wed', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Thu', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Fri', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='303'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='313'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='23'),
        dict(lbpsCellDayOfWeek='Sat', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='0', lbpsCellStartTimeMinute='0', nrCellId='3'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsCellPeriodList'),
]


def Auto_Modify_DSM_Value(Modify_Para_Online_AVHA=Modify_Para_Online_AVHA_DSM, duration=45):
    now = datetime.now()
    hour = now.hour
    minutes = now.minute
    for value in Modify_Para_Online_AVHA:
        if value['parameter'] == 'lbpsPeriodList':
            for index in range(len(value['value'])):
                if value['value'][index]['lbpsDayOfWeek'] == weekday:
                    value['value'][index]['lbpsStartTimeHour'] = str(hour)
                    value['value'][index]['lbpsStartTimeMinute'] = str(minutes)
                    value['value'][index]['lbpsDuration'] = duration
                    value['value'][index]['lbpsSuspended'] = 'notSuspended'
                    break  # Exit the inner loop
            else:
                continue
        if value['parameter'] == 'lbpsCellPeriodList':
            for index in range(len(value['value'])):
                if value['value'][index]['lbpsCellDayOfWeek'] == weekday:
                    value['value'][index]['lbpsCellStartTimeHour'] = str(hour)
                    value['value'][index]['lbpsCellStartTimeMinute'] = str(minutes)
                    value['value'][index]['lbpsCellDuration'] = duration
                    # break  # Exit the inner loop
            else:
                continue
    return Modify_Para_Online_AVHA


def get_used_info(file, index=0):
    with open(file, 'r') as f:
        json_data = json.load(f)
    VONR_times_FDD = json_data[index].get('VONR_times_FDD')
    VONR_times_TDD = json_data[index].get('VONR_times_TDD')
    HO_times_with_VONR = json_data[index].get('HO_times_with_VONR')
    return VONR_times_FDD, VONR_times_TDD, HO_times_with_VONR


def get_info_from_yaml(file_path):
    with open(file_path, "r") as f:
        test_info = yaml.safe_load(f)
    return test_info
