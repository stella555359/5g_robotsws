from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_id
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
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='700'),
        dict(lbpsCellDayOfWeek='Sun', lbpsCellDuration='345', lbpsCellSOMethod='mixed switch off',
             lbpsCellStartTimeHour='8', lbpsCellStartTimeMinute='0', nrCellId='701'),
    ],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
]


def Auto_Modify_DSM_Value(Modify_Para_Online_AVHA=Modify_Para_Online_AVHA_DSM, duration=45):
    now = datetime.now()
    hour = now.hour
    minutes = now.minute
    for value in Modify_Para_Online_AVHA:
        if value['parameter'] == 'lbpsPeriodList':
            for index in range(len(value['value'])):
                value['value'][index]['lbpsDayOfWeek'] = weekday
                value['value'][index]['lbpsStartTimeHour'] = str(hour)
                value['value'][index]['lbpsStartTimeMinute'] = str(minutes)
                value['value'][index]['lbpsDuration'] = duration
                value['value'][index]['lbpsSuspended'] = 'notSuspended'
                break  # Exit the inner loop
            else:
                continue
        if value['parameter'] == 'lbpsCellPeriodList':
            for index in range(len(value['value'])):
                value['value'][index]['lbpsCellDayOfWeek'] = weekday
                value['value'][index]['lbpsCellStartTimeHour'] = str(hour)
                value['value'][index]['lbpsCellStartTimeMinute'] = str(minutes)
                value['value'][index]['lbpsCellDuration'] = duration
                # break  # Exit the inner loop
            else:
                continue
    return Modify_Para_Online_AVHA
