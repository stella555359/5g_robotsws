from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Hu Yifan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yifan.hu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_global_bts_id = str(tl.gnbs[0].global_bts_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_gnb2_id = str(tl.gnbs[0].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_enb_id = str(tl.enbs[0].instance_id)
_MRBTSname_enb = 'MRBTS-'+_enb_id
_NRBTSname_enb = _MRBTSname_enb+'/LNBTS-'+_enb_id

BTSnameEnb = [_NRBTSname_enb]


PARAMETERS_TO_UPDATE_B05 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions'),
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-2', parameter='emergencyCallRestrictions'),
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRPLMNSET_SA-1',
     'parameter': 'trackingAreaDN', 'value': _NRBTSname+'/TRACKINGAREA-20000'}
]

PARAMETERS_TO_UPDATE_COUNTER = [
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/PMCADM-1', 'parameter': 'reportingIntervalPm', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNGCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrMobilityReportCu', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNREMO', 'value': '5min'}
]

counter_id_HO = [
    'M55147C00501', 'M55147C00503', 'M55147C00504'
]

counter_dic_path_HO = [
    'BTS/CELLS/NRCELL-1/NMOCU', 'BTS/CELLS/NRCELL-1/NMOCU', 'BTS/CELLS/NRCELL-1/NMOCU'
]

counter_dic_path_05_service = [
    'BTS/CELLS/NRCELL-1/NMOCU', 'BTS/CELLS/NRCELL-1/NMOCU', 'BTS/CELLS/NRCELL-1/NMOCU'
]

counter_dic_path_05_target = [
    'BTS/CELLS/NRCELL-2/NMOCU', 'BTS/CELLS/NRCELL-2/NMOCU', 'BTS/CELLS/NRCELL-2/NMOCU'
]

PARAMETERS_TO_UPDATE_B06 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_B06_target = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname2+'/NRCELL-1', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_784off = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'false'}
]

PARAMETERS_TO_UPDATE_784on = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'}
]

PARAMETERS_TO_UPDATE_B17 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='false', emergencyCallMrListIgnore='false')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions'),
    dict(value=[dict(emergencyCallPlmnHoAllowed='false', emergencyCallMrListIgnore='false')],
         dist_name=_NRBTSname+'/NRCELL-2', parameter='emergencyCallRestrictions'),
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'trackingAreaDN', 'value': '_NRBTSname/TRACKINGAREA-210'}
]

PARAMETERS_TO_UPDATE_B17_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'trackingAreaDN', 'value': '_NRBTSname/TRACKINGAREA-220'}
 ]

PARAMETERS_TO_UPDATE_B18 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='false', emergencyCallMrListIgnore='false')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_B18_target = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='false', emergencyCallMrListIgnore='false')],
         dist_name=_NRBTSname2+'/NRCELL-1', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_B15 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions'),
    {'dist_name': '_NRBTSname', 'parameter': 'actInterRatHoSA', 'value': 'true'},
    {'dist_name': _NRBTSname+'/NRADJECELL-5000', 'parameter': 'ePSTrackingAreaCode', 'value': '20201'},
]

counter_id_interRAT = [
    'M55144C00501', 'M55144C00502', 'M55144C00503'
]

counter_dic_path_interRAT_376 = [
    'BTS/'+_NRBTSname+'/NRCELL-1/MCC-460/MNC-02/ECI-7937/MCC-460/MNC-02/NREMO',
    'BTS/'+_NRBTSname+'/NRCELL-1/MCC-460/MNC-02/ECI-7937/MCC-460/MNC-02/NREMO',
    'BTS/'+_NRBTSname+'/NRCELL-1/MCC-460/MNC-02/ECI-7937/MCC-460/MNC-02/NREMO'
]

counter_dic_path_interRAT_377 = [
    'BTS/CELLS/NRCELL-1/MCC-310_MNC-260/ECI-9656577/MCC-310_MNC-260/NREMO',
    'BTS/CELLS/NRCELL-1/MCC-310_MNC-260/ECI-9656577/MCC-310_MNC-260/NREMO',
    'BTS/CELLS/NRCELL-1/MCC-310_MNC-260/ECI-9656577/MCC-310_MNC-260/NREMO'
]

counter_dic_path_interRAT_388 = [
    'BTS/CELLS/NRCELL-1/MCC-262_MNC-03/ECI-9938177/MCC-262_MNC-03/NREMO',
    'BTS/CELLS/NRCELL-1/MCC-262_MNC-03/ECI-9938177/MCC-262_MNC-03/NREMO',
    'BTS/CELLS/NRCELL-1/MCC-262_MNC-03/ECI-9938177/MCC-262_MNC-03/NREMO'
]
