from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang qingqing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qingqing.zhang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL3name = _NRBTSname + '/NRCELL-3'


_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_NRTAC = _NRBTSname2+'/TRACKINGAREA-210'
_SERVEDAMF = _NRBTSname+'/SERVEDAMF-1'
_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PARAMETERS_TO_UPDATE_784_GNB1_test = [
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='true', dist_name=_NRCELLname, parameter='actTargetBlerVoNR'),
    dict(value='2', dist_name=_NRCELLname, parameter='dllaTargetBlerVoNR'),
    dict(value='2', dist_name=_NRCELLname, parameter='ullaTargetBlerVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='nullFallback'),
    dict(value='10.110.209.8', dist_name=_SERVEDAMF, parameter='amfIPAddress'),
]

PARAMETERS_TO_recover_784_GNB1_test = [
    dict(value='true', dist_name=_NRCELLname, parameter='actTargetBlerVoNR'),
    dict(value='10.70.255.6', dist_name=_SERVEDAMF, parameter='amfIPAddress'),
]
PARAMETERS_TO_UPDATE_784_GNB1 = [
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='1', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='true', dist_name=_NRCELLname, parameter='emergencyCallLimServ'),
    dict(value='true', dist_name=_NRCELL3name, parameter='emergencyCallLimServ'),
    dict(value='true', dist_name=_NRBTSname, parameter='nullFallback'),
]

PARAMETERS_TO_recover_784_GNB1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='emergencyCallLimServ'),
    dict(value='false', dist_name=_NRCELL3name, parameter='emergencyCallLimServ'),
]


PARAMETERS_TO_administrativeState = [
    {'dist_name': '_MRBTSname/_NRBTSname/SNSSAI-1', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_C1 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'true'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '2'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '2'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='1', nia1_128='3', nia2_128='4', nia3_128='2')],
         dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_EMER_RESOURCE = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_C3 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'true'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '2'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '2'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='1', nia1_128='3', nia2_128='4', nia3_128='2')],
         dist_name=_NRBTSname, parameter='integrityProtPrefL')
]


PARAMETERS_TO_UPDATE_C7 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'true'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNGCC', 'value': '5min'},
    dict(value=[dict(nea0='1', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='1', nia1_128='2', nia2_128='3', nia3_128='5')],
         dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_C9 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'true'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    dict(value=[dict(nea0='1', nea1_128='0', nea2_128='3', nea3_128='9')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='1', nia1_128='2', nia2_128='3', nia3_128='9')],
         dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_C11 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'true'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    dict(value=[dict(nea0='1', nea1_128='2', nea2_128='7', nea3_128='3')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='1', nia1_128='2', nia2_128='7', nia3_128='3')],
         dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_emergencyCallLimServ_false = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'false'}
]

PARAMETERS_TO_shutdownNoXnTrafficTmr_23 = [
    {'dist_name': '_MRBTSname/_NRBTSname', 'parameter': 'shutdownNoXnTrafficTmr', 'value': '23'}
]

PARAMETERS_TO_shutdownNoXnTrafficTmr_default = [
    {'dist_name': '_MRBTSname/_NRBTSname', 'parameter': 'shutdownNoXnTrafficTmr', 'value': '24'}
]

PARAMETERS_TO_UPDATE_D1 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'false'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    dict(value=[dict(nea0='1', nea1_128='2', nea2_128='7', nea3_128='3')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='2', nia2_128='7', nia3_128='3')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_D13 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_D13_target = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions')
]


PARAMETERS_TO_UPDATE_D14 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallLimServ', 'value': 'false'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_MRBTSname/_NRBTSname', 'parameter': 'rrcReestabTypeSA', 'value': 'viaRRCSetup'},
    dict(value=[dict(nea0='1', nea1_128='2', nea2_128='7', nea3_128='9')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='2', nia2_128='7', nia3_128='9')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_8700_A_22_0 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRPMRNL-1/NRPMQAP-1', 'parameter': 'nrPmqapId', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRPMRNL-1/NRPMQAP-1', 'parameter': 'cfgProfType', 'value': 'SA'}
]

PARAMETERS_TO_UPDATE_8700_A_22_1 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'actARPBasedAC', 'value': 'on'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '1'}
]

PARAMETERS_TO_UPDATE_8700_A_22_2 = [
    {'dist_name': _NRBTSname2, 'parameter': 'actIntraFreqHoSA', 'value': 'false'},
    {'dist_name': _NRBTSname2, 'parameter': 'actInterFreqHoSA', 'value': 'false'},
    {'dist_name': '_NRBTSname2/NRPMRNL-1', 'parameter': 'miNrRelReportCu', 'value': 'disabled'}
]

PARAMETERS_TO_RECOVER_8700_A_22 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '384'}
]

PARAMETERS_TO_RECOVER_8700_A_22_1 = [
    {'dist_name': _NRBTSname2, 'parameter': 'actIntraFreqHoSA', 'value': 'true'},
    {'dist_name': _NRBTSname2, 'parameter': 'actInterFreqHoSA', 'value': 'false'},
    {'dist_name': '_NRBTSname2/NRPMRNL-1', 'parameter': 'miNrRelReportCu', 'value': '5min'}
]

PARAMETERS_TO_UPDATE_8700_B12_Trunk = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-2', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_8700_B12_GNB2 = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_8700_B12_GNB1 = [
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1/NRREL-256', 'parameter': 'handoverAllowedSA', 'value': 'allowed'},
]

PARAM_8700_recover_B_12_Trunk = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-2', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-2', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_MRBTSname/_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_recover_B_12_GNB1 = [
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8700_recover_B_12_GNB2 = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_B20 = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_B20_GNB2 = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_B20_UNLOCK = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_B20_GNB2_UNLOCK = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

_counter_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_counter_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_counter_path3 = 'BTS/CELLS/NRCELL-1/RSACU'
_counter_path4 = 'BTS/CELLS/NRCELL-2/RSACU'
_counter_path5 = 'BTS/CELLS/NRCELL-2/NNGCC'
_counter_path6 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'


# cases 8700_A_22####
NG_FLOW_SETUP_FAIL_RRNA = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C10501'}
NG_FLOW_SETUP_FAIL_RRNA_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C10502'}
NG_FLOW_SETUP_FAIL_RRNA_PMQAP = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55163C02000'}
SA_PART_ADMISSION_A22 = {'gnb_id': 1, 'dic_path': _counter_path3, 'counter_id': 'M55138C02001'}
NG_FLOW_SETUP_ATT_TOT = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C08501'}
NG_FLOW_SETUP_ATT_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09517'}
NG_FLOW_SETUP_ATT_TOT_PMQAP = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55163C00001'}
NG_FLOW_SETUP_SUCC = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C08502'}
NG_FLOW_SETUP_SUCC_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09518'}

# cases 8700_B_12 trunk####
NG_FLOW_REL_PART_HO_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C10505'}
NG_FLOW_REL_PART_HO_PMQAP = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55163C02001'}
SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _counter_path4, 'counter_id': 'M55138C02001'}
# 8700_B_12 cover 8200 and 7564 counter
# source cell1
NG_FLOW_REL_IANR_SUC_HO = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09015'}
NG_FLOW_REL_IANR_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path1, 'counter_id': 'M55125C09508'}
NG_FLOW_REL_IANR_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _counter_path2, 'counter_id': 'M55163C00515'}
# target cell2
NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _counter_path5, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _counter_path5, 'counter_id': 'M55125C09014'}
NG_FLOW_STP_ATT_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path5, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _counter_path5, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _counter_path6, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _counter_path6, 'counter_id': 'M55163C00514'}

# cases 8700_B_12 22R3####
counter_id_inter_gNB1 = [
    'M55125C10505', 'M55163C02001', 'M55125C09015', 'M55125C09508', 'M55163C00515'
]

counter_id_inter_gNB2 = [
    'M55138C02001', 'M55125C09013', 'M55125C09014', 'M55125C09524', 'M55125C09525', 'M55163C00513', 'M55163C00514'
]

counter_dic_path_inter_gNB1_Trunk = [
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NRPMQAP-1/NGCCQ'
]

counter_dic_path_inter_gNB1 = [
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
]

counter_dic_path_inter_gNB2_Trunk = [
    'BTS/'+_NRBTSname2+'/NRCELL-2/RSACU',
    'BTS/'+_NRBTSname2+'/NRCELL-2/NNGCC',
    'BTS/'+_NRBTSname2+'/NRCELL-2/NNGCC',
    'BTS/'+_NRBTSname2+'/NRCELL-2/NNGCC',
    'BTS/'+_NRBTSname2+'/NRCELL-2/NNGCC',
    'BTS/'+_NRBTSname2+'/NRCELL-2/NRPMQAP-1/NGCCQ',
    'BTS/'+_NRBTSname2+'/NRCELL-2/NRPMQAP-1/NGCCQ'
]

counter_dic_path_inter_gNB2 = [
    'BTS/CELLS/NRCELL-2/RSACU',
    'BTS/CELLS/NRCELL-2/NNGCC',
    'BTS/CELLS/NRCELL-2/NNGCC',
    'BTS/CELLS/NRCELL-2/NNGCC',
    'BTS/CELLS/NRCELL-2/NNGCC',
    'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
]

# cases 8700_A_22 22R3####
counter_id_A22_gNB1 = [
    'M55125C10501', 'M55125C10502', 'M55163C02000', 'M55138C02001', 'M55125C08501', 'M55125C09517',
    'M55163C00001', 'M55125C08502', 'M55125C09518'
]

counter_dic_path_A22_gNB1_Trunk = [
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/'+_NRBTSname+'/NRCELL-1/RSACU',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC',
    'BTS/'+_NRBTSname+'/NRCELL-1/NNGCC'
]

counter_dic_path_A22_gNB1 = [
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-1/RSACU',
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ',
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC'
]

ParamterToModify_GNB1_8700_A22 = [
    dict(value='false', dist_name=_NRBTSname, p_name='actNormVCFallback'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNormVCFallbackEnh'),
    dict(value='disabled', dist_name=_NRBTSname + '/NRCELL-1', p_name='voiceFBMode'),
    dict(value='deactivated', dist_name=_NRBTSname, p_name='rrcReestabTypeSA'),
    dict(value='false', dist_name=_NRBTSname, p_name='actInterGnbRREPreparedCell'),
]

LIST_TO_MODIFY_GNB1_8700_A22 = [
    dict(
        dist_name=_NRBTSname,
        list_name='actVoiceFallbackDuringHOPrep',
        elements=['disabled']),
]

ParameterToDelete_GNB1_8700_A22 = [
    dict(
        dist_name=_NRBTSname,
        list_name='actVoiceFallbackDuringHOPrep'),
]
