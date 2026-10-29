from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Liu  Xu'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xu.2.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_bts_id = str(tl.gnbs[0].global_bts_id)
_bts2_id = str(tl.gnbs[1].global_bts_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_gnb2_id = str(tl.gnbs[1].instance_id)
_lte2_id = str(tl.enbs[0].global_bts_id)
_enb2_id = str(tl.enbs[0].instance_id)
_lte2_MRBTSname = 'MRBTS-' + _lte2_id
_LNBTSname_2 = _lte2_MRBTSname + '/LNBTS-' + _enb2_id
_MRBTSname = 'MRBTS-' + _bts_id
_MRBTS2name = 'MRBTS-' + _bts2_id
_NRBTSnames = 'NRBTS-' + _gnb_id
_NRBTS2names = 'NRBTS-' + _gnb2_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTS2name = _MRBTS2name + '/NRBTS-' + _gnb2_id
_LNBTSname = _MRBTSname + '/LNBTS-' + _gnb_id
_LNBTS2name = _MRBTS2name + '/LNBTS-' + _gnb2_id

_NRCELL101 = _NRBTSname + '/NRCELL-101'
_NRCELL102 = _NRBTSname + '/NRCELL-102'
_NRCELL103 = _NRBTSname + '/NRCELL-103'
_NRCELL107 = _NRBTSname + '/NRCELL-107'
_NRCELL108 = _NRBTSname + '/NRCELL-108'
_NRCELL109 = _NRBTSname + '/NRCELL-109'
_NRCELL190 = _NRBTSname + '/NRCELL-190'
_NRCELL191 = _NRBTSname + '/NRCELL-191'
_NRCELL121 = _NRBTSname + '/NRCELL-121'
_NRCELL122 = _NRBTSname + '/NRCELL-122'
_NRCELL123 = _NRBTSname + '/NRCELL-123'
_NRCELL131 = _NRBTSname + '/NRCELL-131'

_NRCELL1 = _NRBTSname + '/NRCELL-1'
_NRCELL2 = _NRBTSname + '/NRCELL-2'
_NRCELL3 = _NRBTSname + '/NRCELL-3'
_NRCELL11 = _NRBTSname + '/NRCELL-11'
_NRCELL12 = _NRBTSname + '/NRCELL-12'
_NRCELL13 = _NRBTSname + '/NRCELL-13'
_NRCELL4 = _NRBTSname + '/NRCELL-4'
_NRCELL21 = _NRBTSname + '/NRCELL-21'
_NRCELL22 = _NRBTSname + '/NRCELL-22'
_NRCELL23 = _NRBTSname + '/NRCELL-23'
_NRCELL24 = _NRBTSname + '/NRCELL-24'
_NRCELL41 = _NRBTSname + '/NRCELL-41'
_NRCELL42 = _NRBTSname + '/NRCELL-42'
_NRCELL43 = _NRBTSname + '/NRCELL-43'
_NRCELL44 = _NRBTSname + '/NRCELL-44'
_NRCELL61 = _NRBTSname + '/NRCELL-61'
_NRCELL62 = _NRBTSname + '/NRCELL-62'
_NRCELL63 = _NRBTSname + '/NRCELL-63'
_NRCELL64 = _NRBTSname + '/NRCELL-64'
_NRCELL301 = _NRBTSname + '/NRCELL-301'
_NRCELL302 = _NRBTSname + '/NRCELL-302'
_NRCELL303 = _NRBTSname + '/NRCELL-303'
_NRCELL304 = _NRBTSname + '/NRCELL-304'
_NRCELL311 = _NRBTSname + '/NRCELL-311'
_NRCELL312 = _NRBTSname + '/NRCELL-312'
_NRCELL313 = _NRBTSname + '/NRCELL-313'
_NRCELL314 = _NRBTSname + '/NRCELL-314'
_NRCELL361 = _NRBTSname + '/NRCELL-361'
_NRCELL362 = _NRBTSname + '/NRCELL-362'
_NRCELL363 = _NRBTSname + '/NRCELL-363'
_LNCEL11 = _LNBTSname + '/LNCEL-11'
_LNCEL12 = _LNBTSname + '/LNCEL-12'
_LNCEL13 = _LNBTSname + '/LNCEL-13'
_LNCEL21 = _LNBTSname + '/LNCEL-21'
_LNCEL22 = _LNBTSname + '/LNCEL-22'
_LNCEL23 = _LNBTSname + '/LNCEL-23'
_LNCEL31 = _LNBTSname + '/LNCEL-31'
_LNCEL32 = _LNBTSname + '/LNCEL-32'
_LNCEL33 = _LNBTSname + '/LNCEL-33'
_LNCEL61 = _LNBTSname + '/LNCEL-61'
_LNCEL62 = _LNBTSname + '/LNCEL-62'
_LNCEL63 = _LNBTSname + '/LNCEL-63'
_LNCEL201 = _LNBTSname + '/LNCEL-201'
_LNCEL202 = _LNBTSname + '/LNCEL-202'
_LNCEL203 = _LNBTSname + '/LNCEL-203'

_LNCEL01 = _LNBTSname_2 + '/LNCEL-1'
_LNCEL02 = _LNBTSname_2 + '/LNCEL-2'
_LNCEL03 = _LNBTSname_2 + '/LNCEL-3'
_LNCEL04 = _LNBTSname_2 + '/LNCEL-4'
_LNCEL11 = _LNBTSname_2 + '/LNCEL-11'
_LNCEL12 = _LNBTSname_2 + '/LNCEL-12'
_LNCEL13 = _LNBTSname_2 + '/LNCEL-13'
_LNCEL14 = _LNBTSname_2 + '/LNCEL-14'
_LNCEL21 = _LNBTSname_2 + '/LNCEL-21'
_LNCEL22 = _LNBTSname_2 + '/LNCEL-22'
_LNCEL23 = _LNBTSname_2 + '/LNCEL-23'
_LNCEL24 = _LNBTSname_2 + '/LNCEL-24'
_LNCEL31 = _LNBTSname_2 + '/LNCEL-31'
_LNCEL32 = _LNBTSname_2 + '/LNCEL-32'
_LNCEL33 = _LNBTSname_2 + '/LNCEL-33'
_LNCEL34 = _LNBTSname_2 + '/LNCEL-34'
_LNCEL61 = _LNBTSname_2 + '/LNCEL-61'
_LNCEL62 = _LNBTSname_2 + '/LNCEL-62'
_LNCEL63 = _LNBTSname_2 + '/LNCEL-63'
_LNCEL64 = _LNBTSname_2 + '/LNCEL-64'
_LNCEL201 = _LNBTSname_2 + '/LNCEL-201'
_LNCEL202 = _LNBTSname_2 + '/LNCEL-202'
_LNCEL203 = _LNBTSname_2 + '/LNCEL-203'
_LNCEL204 = _LNBTSname_2 + '/LNCEL-204'

_GNB2_CELL1 = _NRBTS2name + '/NRCELL-1'
_ENB_LNCEL211 = _LNBTS2name + '/LNCEL-211'
_ENB_LNCEL211_SIB0 = _ENB_LNCEL211 + '/SIB-0'
_RMOD1 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-1'
_RMOD2 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-2'
_RMOD3 = _MRBTSname + '/EQM-1/APEQM-1/RMOD-3'
year = time.localtime().tm_year
month = time.localtime().tm_mon
day = time.localtime().tm_mday
date = datetime.date(datetime(year=year, month=month, day=day))
index = datetime.date(datetime(year=year, month=month, day=day)).weekday()
weekday = date.strftime("%a")
now = datetime.now()
hour = now.hour
minutes = now.minute

_SERVEDAMF_1 = _NRBTSname + 'SERVEDAMF-1'

PARAMETERS_TO_ONLINE_MODIFY_8232 = [
    {'dist_name': _NRBTSname, 'parameter': 'applyPriorityAccess', 'value': 'HPA+MPS'},
    {'dist_name': _NRCELL21, 'parameter': 'actPriorityAccess', 'value': 'true'},
    {'dist_name': _NRCELL21, 'parameter': 'numOfRadioResReservForPa', 'value': '1'},
    {'dist_name': _NRCELL21, 'parameter': 'maxNumOfRrcSA', 'value': '0'},
    {'dist_name': _NRBTSname + '/SERVEDAMF-2', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_ONLINE_MODIFY_8232_Restore = [
    {'dist_name': _NRCELL21, 'parameter': 'numOfRadioResReservForPa', 'value': '0'},
    {'dist_name': _NRCELL21, 'parameter': 'maxNumOfRrcSA', 'value': '275'},
    {'dist_name': _NRBTSname + '/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRBTSname + '/SERVEDAMF-2', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_ONLINE_MODIFY_EPS_FALLBACK = [
    {'dist_name': _NRCELL301, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL302, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL303, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL311, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL312, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL313, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL21, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL22, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL23, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL24, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL41, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL42, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL43, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL44, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL1, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL2, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL3, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL4, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRCELL303, 'parameter': 'actGBRAdmissionControl', 'value': 'EnhancedVoNR'},
    {'dist_name': _NRCELL303, 'parameter': 'actNonVoNRGbrService', 'value': 'false'},
    {'dist_name': _NRCELL303, 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': _NRCELL303, 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': _NRCELL303, 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'}
]

PARAMETERS_TO_ONLINE_MODIFY_EPS_FALLBACK_RESTORE = [
    {'dist_name': _NRCELL301, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL302, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL303, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL311, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL312, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL313, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL21, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL22, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL23, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL24, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL41, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL42, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL43, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL44, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL1, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL2, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL3, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL4, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRCELL303, 'parameter': 'actGBRAdmissionControl', 'value': 'GBRService'},
    {'dist_name': _NRCELL303, 'parameter': 'actNonVoNRGbrService', 'value': 'true'},
    {'dist_name': _NRCELL303, 'parameter': 'maxNumOfGBRBearersSA', 'value': '384'},
    {'dist_name': _NRCELL303, 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '3000'},
    {'dist_name': _NRCELL303, 'parameter': 'numOfRadioResReservForEmergency', 'value': '10'},
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '30'}
]

PARAMETERS_TO_ONLINE_DELETE_EPS_FALLBACK = [
    {'dist_name': _NRCELL303, 'parameter': 'gbrCongDetectionRac'}
]

PARAMETERS_TO_ONLINE_DELETE_EPS_FALLBACK_RESTORE = [
    {'dist_name': _NRCELL303, 'parameter': 'gbrCongDetectionRac', 'value': 'false'}
]

PARAMETERS_TO_ONLINE_MODIFY_1354 = [
    {'dist_name': _NRBTSname + '/NRDRB-4', 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _NRBTSname + '/NRDRB-4', 'parameter': 'dlDataSplitMode', 'value': 'dlOverF1UX2U'},
    {'dist_name': _NRBTSname + '/NRDRB_PDCP-1', 'parameter': 'pdcpDelayThreshRetxMode',
     'value': 'delayThresh1and2Enabled'},
    {'dist_name': _NRBTSname + '/NRPMRNL-1', 'parameter': 'miNrF1UB1Interface', 'value': '5min'},
    {'dist_name': _NRBTSname + '/NRPMRNL-1', 'parameter': 'miNrX2UB1Interface', 'value': '5min'},
    {'dist_name': _NRBTSname + '/NRPMRNL-1', 'parameter': 'miNrPDCP2Report', 'value': '5min'},
    {'dist_name': _NRBTSname + '/NRPMRNL-1', 'parameter': 'miNrHighRlcReport', 'value': '5min'}

]

PARAMETERS_TO_ONLINE_ADD_1354 = [
    {'dist_name': _NRBTSname + '/NRDRB-4', 'parameter': 'reTxPrioritizationType', 'value': 'retxPrioSameLink'},
    {'dist_name': _NRBTSname + '/NRDRB_PDCP-1', 'parameter': 'pdcpDelayThresh1TrigType',
     'value': 'transmittedPdcpSnTrig'},
    {'dist_name': _NRBTSname + '/NRDRB_PDCP-1', 'parameter': 'pdcpMaxNumRetxPdu', 'value': '500'},
    {'dist_name': _NRBTSname + '/NRDRB_PDCP-1', 'parameter': 'pdcpPduRetxDelayThresh1', 'value': 'ms60'},
    {'dist_name': _NRBTSname + '/NRDRB_PDCP-1', 'parameter': 'pdcpPduRetxDelayThresh2', 'value': 'ms40'},
    {'dist_name': _NRBTSname + '/NRDRB_PDCP-1', 'parameter': 'pdcpRetxPduSendMaxDelay', 'value': 'ms60'}
]

counter_id_1354 = [
    'M55355C06007', 'M55355C07007', 'M55354C04007', 'M55354C05007', 'M55355C08007', 'M55355C09007', 'M55354C06007',
    'M55354C07007'
]

counter_id_1354_Threshold1 = [
    'M55320C21001', 'M55320C21002', 'M55320C21003', 'M55320C21004', 'M55320C21005', 'M55320C21006', 'M55320C21007',
    'M55320C21008', 'M55320C21009'
]

counter_id_1354_Threshold2 = [
    'M55320C22001', 'M55320C22002', 'M55320C22003', 'M55320C22004', 'M55320C22005', 'M55320C22006', 'M55320C22007',
    'M55320C22008', 'M55320C22009'
]

counter_dic_path_1354 = [
    'BTS/BTS/' + _NRBTSnames + '/F1UB1', 'BTS/BTS/' + _NRBTSnames + '/F1UB1', 'BTS/BTS/' + _NRBTSnames + '/X2UB1',
    'BTS/BTS/' + _NRBTSnames + '/X2UB1', 'BTS/BTS/' + _NRBTSnames + '/X2UB1', 'BTS/BTS/' + _NRBTSnames + '/X2UB1',
    'BTS/BTS/' + _NRBTSnames + '/F1UB1', 'BTS/BTS/' + _NRBTSnames + '/F1UB1'
]

counter_dic_path_1354_Threshold1 = [
    'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2',
    'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2',
    'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2'
]

counter_dic_path_1354_Threshold2 = [
    'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2',
    'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2',
    'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2', 'BTS/BTS/' + _NRBTSnames + '/PDCP2'
]

# PARAMETERS_TO_ONLINE_MODIFY_PowerSave = [
#     dict(new_value='false', dist_name=_NRBTSname,
#          filter_param='Activate load-based PS control logic enhancement',
#          abbr='actLbpsCtrlLogicEnh'),
#     dict(new_value='false', dist_name=_NRBTSname,
#          filter_param='Activate NR load-based power saving',
#          abbr='actNrLBPowerSaving'),
#     dict(new_value='false', dist_name=_NRBTSname,
#          filter_param='Activate NR load-based reduced TX power saving',
#          abbr='actNrLBRTXPowerSaving'),
#     dict(new_value='false', dist_name=_NRBTSname,
#          filter_param='Activate NR load-based mMIMO TX power saving',
#          abbr='actNrLBmMimoRTXPowerSaving')
# ]

PARAMETERS_TO_ONLINE_MODIFY_PowerSave = [
    {'dist_name': _NRBTSname, 'parameter': 'actLbpsCtrlLogicEnh', 'value': 'false'},
    {'dist_name': _NRBTSname, 'parameter': 'actNrLBPowerSaving', 'value': 'false'},
    {'dist_name': _NRBTSname, 'parameter': 'actNrLBRTXPowerSaving', 'value': 'false'},
    {'dist_name': _NRBTSname, 'parameter': 'actNrLBmMimoRTXPowerSaving', 'value': 'false'},
]

PARAMETERS_TO_ONLINE_MODIFY_PowerSave_Restore = [
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate load-based PS control logic enhancement',
         abbr='actLbpsCtrlLogicEnh'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate NR load-based power saving',
         abbr='actNrLBPowerSaving'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate NR load-based reduced TX power saving',
         abbr='actNrLBRTXPowerSaving'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate NR load-based mMIMO TX power saving',
         abbr='actNrLBmMimoRTXPowerSaving')
]

PARAMETERS_TO_ONLINE_MODIFY_3CC_36311 = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL24, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL44, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL4, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
]

PARAMETERS_TO_ONLINE_MODIFY_Unlock_all_cell = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL24, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL44, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL4, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

Modify_Para_Online_close_slice = [
    {'dist_name': _NRBTSname, 'parameter': 'actSliceNumExt', 'value': 'false'},
]

Modify_Para_Online_Locked_357 = [
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL12, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL13, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL362, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL363, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _LNCEL11, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL12, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL13, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL21, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL22, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL23, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL31, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL32, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL33, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL61, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL62, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL63, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL301, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL311, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL361, 'parameter': 'cellBarred', 'value': 'barred'}
]

Modify_Para_Online_Bar_357 = [
    {'dist_name': _NRCELL1, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL2, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL13, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL23, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL41, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL42, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL43, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL301, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL302, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL311, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL312, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL313, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL361, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL362, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL363, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _LNCEL11, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL31, 'parameter': 'administrativeState', 'value': 'locked'}
]

Modify_Para_Online_Bar_TDD_357 = [
    {'dist_name': _NRCELL1, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL2, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL13, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL23, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL41, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL42, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL43, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL301, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL302, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL311, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL312, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL313, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL361, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL362, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL363, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _LNCEL11, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL31, 'parameter': 'administrativeState', 'value': 'locked'}
]

Modify_Para_Online_Locked_TDD_357 = [
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL12, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL13, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL362, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL363, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _LNCEL11, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL12, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL13, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL21, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL22, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL23, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL31, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL32, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL33, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL61, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL62, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL63, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL301, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL311, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL361, 'parameter': 'cellBarred', 'value': 'barred'}
]

Modify_Para_Online_Locked_36311 = [
    {'dist_name': _NRBTSname + '/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL24, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL44, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL4, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
]

Modify_Para_Online_TFF_36311 = [
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'barred'},
]

Modify_Para_Online_Locked_HO = [
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL12, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL13, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL362, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL363, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _LNCEL11, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL12, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL13, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL21, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL22, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL23, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL31, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL32, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL33, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL61, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL62, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _LNCEL63, 'parameter': 'administrativeState', 'value': 'locked'},
    {'dist_name': _NRCELL1, 'parameter': 'actBadUplinkRadioRedirect', 'value': 'disabled'},
    {'dist_name': _NRCELL2, 'parameter': 'actBadUplinkRadioRedirect', 'value': 'disabled'},
    {'dist_name': _NRCELL1, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL2, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL1, 'parameter': 'cbraPreamblesPerSsb', 'value': 'n64'},
    {'dist_name': _NRCELL2, 'parameter': 'cbraPreamblesPerSsb', 'value': 'n56'},
]

Delete_Para_Online_8UE = [
    {'dist_name': _NRBTSname + '/SNSSAI-1', 'parameter': 'trsProfileDN'},
    {'dist_name': _NRBTSname + '/SNSSAI-2000', 'parameter': 'trsProfileDN'},
]

Delete_Para_Online_Recovery_8UE = [
    {'dist_name': _NRBTSname, 'parameter': 'actSliceNumExt', 'value': 'true'},
    {'dist_name': _NRBTSname + '/SNSSAI-1', 'parameter': 'trsProfileDN', 'value': _NRBTSname + '/NRTRS_PROFILE-1'},
    {'dist_name': _NRBTSname + '/SNSSAI-2000', 'parameter': 'trsProfileDN', 'value': _NRBTSname + '/NRTRS_PROFILE-1'},
]

Modify_Para_Online_Locked_Unlock_357 = [
    {'dist_name': _NRCELL121, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL101, 'parameter': 'administrativeState', 'value': 'Locked'},
]

Modify_Para_Online_Locked_Unlock_36311 = [
    {'dist_name': _NRCELL121, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL103, 'parameter': 'administrativeState', 'value': 'Locked'},
]

Modify_Para_Online_UnLocked_357 = [
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL12, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL13, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL362, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL363, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _LNCEL11, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL12, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL13, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL21, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL22, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL23, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL31, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL32, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL33, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL61, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL62, 'parameter': 'administrativeState', 'value': 'unlocked'},
    {'dist_name': _LNCEL63, 'parameter': 'administrativeState', 'value': 'unlocked'},
]

Modify_Para_Online_UnLocked_36311 = [
    {'dist_name': _NRBTSname + '/SERVEDAMF-1', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL24, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL44, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL4, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL3, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

Modify_Para_Online_Locked_A002 = [
    {'dist_name': _NRCELL190, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL101, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL131, 'parameter': 'administrativeState', 'value': 'Locked'},
]

Modify_Para_Online_Unlocked_A002 = [
    {'dist_name': _NRCELL190, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL101, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL131, 'parameter': 'administrativeState', 'value': 'Unlocked'},
]

Modify_Para_Online_AVHA_DSM = [
    {'dist_name': _NRBTSname, 'parameter': 'actNrLBPowerSaving', 'value': 'true'},
    {'dist_name': _RMOD1, 'parameter': 'energySavingMode', 'value': 'DEEPSLEEP'},
    {'dist_name': _RMOD2, 'parameter': 'energySavingMode', 'value': 'DEEPSLEEP'},
    {'dist_name': _RMOD3, 'parameter': 'energySavingMode', 'value': 'DEEPSLEEP'},
    dict(value=[dict(lbpsStartTimeHour=hour, lbpsStartTimeMinute=minutes)],
         dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsPeriodList'),
    dict(value=[dict(lbpsStartTimeHour=hour, lbpsStartTimeMinute=minutes)],
         dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList'),
    dict(value=[dict(lbpsStartTimeHour=hour, lbpsStartTimeMinute=minutes)],
         dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsPeriodList'),
    dict(value=[
        dict(lbpsCellStartTimeHour=hour, lbpsCellStartTimeMinute=minutes),
        dict(lbpsCellStartTimeHour=hour, lbpsCellStartTimeMinute=minutes)],
        dist_name=_NRBTSname + '/NRPGRP-0', parameter='lbpsCellPeriodList'),
    dict(value=[
        dict(lbpsCellStartTimeHour=hour, lbpsCellStartTimeMinute=minutes),
        dict(lbpsCellStartTimeHour=hour, lbpsCellStartTimeMinute=minutes)],
        dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsCellPeriodList'),
    dict(value=[
        dict(lbpsCellStartTimeHour=hour, lbpsCellStartTimeMinute=minutes),
        dict(lbpsCellStartTimeHour=hour, lbpsCellStartTimeMinute=minutes)],
        dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsCellPeriodList'),
]

Modify_Para_Online_AVHA_DSM_Recovey = [
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

LIST_TO_ADD_AVHA = [
    dict(
        dist_name=_NRBTSname + '/NRPGRP-0',
        list_name='lbpsPeriodList',
        elements=dict(
            lbpsDayOfWeek=weekday,
            lbpsDuration='45',
            lbpsStartTimeHour='0',
            lbpsStartTimeMinute='0',
            lbpsSuspended='notSuspended')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-1',
        list_name='lbpsPeriodList',
        elements=dict(
            lbpsDayOfWeek=weekday,
            lbpsDuration='45',
            lbpsStartTimeHour='0',
            lbpsStartTimeMinute='0',
            lbpsSuspended='notSuspended')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-2',
        list_name='lbpsPeriodList',
        elements=dict(
            lbpsDayOfWeek=weekday,
            lbpsDuration='45',
            lbpsStartTimeHour='0',
            lbpsStartTimeMinute='0',
            lbpsSuspended='notSuspended')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-0',
        list_name='lbpsCellPeriodList',
        elements=dict(
            lbpsCellDayOfWeek=weekday,
            lbpsCellDuration='45',
            lbpsCellSOMethod='mixed switch off',
            lbpsCellStartTimeHour='0',
            lbpsCellStartTimeMinute='0',
            nrCellId='301')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-0',
        list_name='lbpsCellPeriodList',
        elements=dict(
            lbpsCellDayOfWeek=weekday,
            lbpsCellDuration='45',
            lbpsCellSOMethod='mixed switch off',
            lbpsCellStartTimeHour='0',
            lbpsCellStartTimeMinute='0',
            nrCellId='311')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-1',
        list_name='lbpsCellPeriodList',
        elements=dict(
            lbpsCellDayOfWeek=weekday,
            lbpsCellDuration='45',
            lbpsCellSOMethod='mixed switch off',
            lbpsCellStartTimeHour='0',
            lbpsCellStartTimeMinute='0',
            nrCellId='302')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-1',
        list_name='lbpsCellPeriodList',
        elements=dict(
            lbpsCellDayOfWeek=weekday,
            lbpsCellDuration='45',
            lbpsCellSOMethod='mixed switch off',
            lbpsCellStartTimeHour='0',
            lbpsCellStartTimeMinute='0',
            nrCellId='312')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-2',
        list_name='lbpsCellPeriodList',
        elements=dict(
            lbpsCellDayOfWeek=weekday,
            lbpsCellDuration='45',
            lbpsCellSOMethod='mixed switch off',
            lbpsCellStartTimeHour='0',
            lbpsCellStartTimeMinute='0',
            nrCellId='303')),
    dict(
        dist_name=_NRBTSname + '/NRPGRP-2',
        list_name='lbpsCellPeriodList',
        elements=dict(
            lbpsCellDayOfWeek=weekday,
            lbpsCellDuration='45',
            lbpsCellSOMethod='mixed switch off',
            lbpsCellStartTimeHour='0',
            lbpsCellStartTimeMinute='0',
            nrCellId='313')),
]

PARAMS_TO_delete_AVHA = [
    dict(dist_name=_NRBTSname + '/NRPGRP-0', list_name='lbpsPeriodList'),
    dict(dist_name=_NRBTSname + '/NRPGRP-1', list_name='lbpsPeriodList'),
    dict(dist_name=_NRBTSname + '/NRPGRP-2', list_name='lbpsPeriodList'),
    dict(dist_name=_NRBTSname + '/NRPGRP-0', list_name='lbpsCellPeriodList'),
    dict(dist_name=_NRBTSname + '/NRPGRP-1', list_name='lbpsCellPeriodList'),
    dict(dist_name=_NRBTSname + '/NRPGRP-2', list_name='lbpsCellPeriodList'),
]

PARAMETERS_TO_ONLINE_MODIFY_A001_FDD_Lock_other_Cell = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL24, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL44, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL4, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

PARAMETERS_TO_ONLINE_MODIFY_A001_TDD_Lock_other_Cell = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL302, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL312, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL313, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL22, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL23, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL24, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL41, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL42, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL44, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL1, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL2, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL4, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

Modify_Para_Online_Locked_bler = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Locked'},
]

Modify_Para_Online_unlocked_bler = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL361, 'parameter': 'weightForSCellSelection', 'value': '100'},
]

Modify_Para_Online_with_scellweight = [
    {'dist_name': _NRCELL301, 'parameter': 'weightForSCellSelection', 'value': '5'},
    {'dist_name': _NRCELL361, 'parameter': 'weightForSCellSelection', 'value': '10'},
]

Modify_Para_Online_unlocked_all4CC = [
    {'dist_name': _NRCELL301, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL361, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL21, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL3, 'parameter': 'administrativeState', 'value': 'Unlocked'},
]

Modify_Para_Online_AVHA_DSM_Modified_1 = [
    {'dist_name': _NRBTSname, 'parameter': 'actNrLBPowerSaving', 'value': 'true'},
    {'dist_name': _RMOD1, 'parameter': 'energySavingMode', 'value': 'DEEPSLEEP'},
    {'dist_name': _RMOD2, 'parameter': 'energySavingMode', 'value': 'DEEPSLEEP'},
    {'dist_name': _RMOD3, 'parameter': 'energySavingMode', 'value': 'DEEPSLEEP'},
]

Modify_Para_Online_amf_Locked_HO = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Locked'},
]

Modify_Para_Online_recover_amf_Unlocked_HO = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Unlocked'},
]

recover_NRCELL21_notBarred = [
    {'dist_name': _NRCELL21, 'parameter': 'cellBarred', 'value': 'notBarred'},
]
recover_NRCELL303_notBarred = [
    {'dist_name': _NRCELL303, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

recover_GNB2CELL1_notBarred = [
    {'dist_name': _GNB2_CELL1, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

recover_GNB2CELL1_Barred = [
    {'dist_name': _GNB2_CELL1, 'parameter': 'cellBarred', 'value': 'barred'},
]

recover_ENB_LNCEL211_notBarred = [
    {'dist_name': _ENB_LNCEL211_SIB0, 'parameter': 'cellBarred', 'value': 'notBarred'},
]

recover_ENB_LNCEL211_Barred = [
    {'dist_name': _ENB_LNCEL211_SIB0, 'parameter': 'cellBarred', 'value': 'barred'},
]

PARAMETERS_LTE_CELL_LOCKED = [
    {
        "distName": _LNCEL01,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL02,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL03,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL04,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL21,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL22,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL23,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL24,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL31,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL32,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL33,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL34,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL61,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL62,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL63,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL64,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL201,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL202,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL203,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    },
    {
        "distName": _LNCEL204,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "locked"
            }
        ]
    }
]

PARAMETERS_LTE_CELL_UNLOCKED = [
    {
        "distName": _LNCEL01,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL02,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL03,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL04,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL21,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL22,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL23,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL24,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL31,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL32,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL33,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL34,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL61,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL62,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL63,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL64,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL201,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL202,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL203,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    },
    {
        "distName": _LNCEL204,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "unlocked"
            }
        ]
    }
]

PARAMETERS_LTE_BARRED = [
    {
        "distName": _ENB_LNCEL211_SIB0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "operation": "update",
                "value": "barred"
            }
        ]
    }
]

PARAMETERS_LTE_UNBARRED_NR_BARRED = [
    {
        "distName": _ENB_LNCEL211_SIB0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "operation": "update",
                "value": "notBarred"
            }
        ]
    },
    {
        "distName": _GNB2_CELL1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "operation": "update",
                "value": "barred"
            }
        ]
    }
]

PARAMETERS_RECOVER_LTE_UNBARRED_NR_UNBARRED = [
    {
        "distName": _ENB_LNCEL211_SIB0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "operation": "update",
                "value": "notBarred"
            }
        ]
    },
    {
        "distName": _GNB2_CELL1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "cellBarred",
                "operation": "update",
                "value": "notBarred"
            }
        ]
    }
]

PARAMETERS_EPSFB = [
    {
        "distName": _NRCELL301,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL311,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL302,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL312,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL303,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actGBRAdmissionControl",
                "operation": "update",
                "value": "EnhancedVoNR"
            },
            {
                "parameterName": "actNonVoNRGbrService",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "maxNumOfGBRBearersSA",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "maxNumOfNonGBRBearersSA",
                "operation": "update",
                "value": "10"
            },
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            },
            {
                "parameterName": "gbrCongDetectionRac",
                "operation": "delete",
                "value": "false"
            },
        ]
    },
    {
        "distName": _NRCELL313,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL21,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL41,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL22,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL42,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL23,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL43,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL24,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL44,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL2,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL3,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRCELL4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    },
    {
        "distName": _NRBTSname + '/NRDU-1',
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfDrbsReservForEmergency",
                "operation": "update",
                "value": "0"
            }
        ]
    }
]

PARAMETERS_RECOVER_EPSFB = [
    {
        "distName": _NRCELL301,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL311,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL302,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL312,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL303,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            },
            {
                "parameterName": "actGBRAdmissionControl",
                "operation": "update",
                "value": "GBRService"
            },
            {
                "parameterName": "actNonVoNRGbrService",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "maxNumOfGBRBearersSA",
                "operation": "update",
                "value": "384"
            },
            {
                "parameterName": "maxNumOfNonGBRBearersSA",
                "operation": "update",
                "value": "3000"
            },
            {
                "parameterName": "gbrCongDetectionRac",
                "operation": "update",
                "value": "false"
            },
        ]
    },
    {
        "distName": _NRCELL313,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL21,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL41,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL22,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL42,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL23,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL43,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL24,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL44,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL2,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL3,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRCELL4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfRadioResReservForEmergency",
                "operation": "update",
                "value": "10"
            }
        ]
    },
    {
        "distName": _NRBTSname + '/NRDU-1',
        "operation": "update",
        "parameters": [
            {
                "parameterName": "numOfDrbsReservForEmergency",
                "operation": "update",
                "value": "30"
            }
        ]
    }
]

JSON_PATH = '/opt/workspace/CRT/Master/Case_Logs/'
PY_PATH = '/opt/workspace/SCF/'
GNBS_INDEX = [0, 1]
NR_PORTS = [1, 2, 3, 4]
LTE_PORTS = [5, 6, 7, 8]
NR_VALUES = [20] * 4
LTE_VALUES = [20] * 4
G1_UE_INDEX = [1, 2, 3, 4]
ALL_UE_INDEX = [1, 2, 3, 4, 5, 6, 7]
MTU_ALL_UE_INDEX = [2, 3, 4, 5, 6, 7, 8]
ALL_UES_APN = ['dxstatic8', 'dxstatic8', 'dxstatic8', 'dxstatic8',
               'wap1.nokia.com', 'wap1.nokia.com', 'wap1.nokia.com']
ALL_UES_SPECIAL_APN = ['dxstatic8', 'dxstatic8', 'dxstatic8', 'dxstatic8',
                       'wap1nokiacom', 'wap1nokiacom', 'wap1nokiacom']
DL_THROUGHPUT = ['1M', '1M', '1M', '1M', '550M', '550M', '550M']
DL_EXPECT_THROUGHPUT = ['1', '1', '1', '1', '550', '550', '550']
UL_THROUGHPUT = ['1M', '1M', '1M', '1M', '40M', '40M', '40M']
UL_EXPECT_THROUGHPUT = ['1', '1', '1', '1', '40', '40', '40']
