from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Hu Yifan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yifan.hu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)

_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id


PARAMETERS_TO_UPDATE_A01_pre = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'},
    dict(value=[dict(nea1_128='9', nea2_128='3', nea3_128='3')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='3', nia3_128='3')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_A01_recover = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '550'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '600'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '600'},
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/PMCADM-1', 'parameter': 'reportingIntervalPm', 'value': '60min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNGCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRRCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '5min'},
    dict(value=[dict(nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_A01 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A03 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '3'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'},
    dict(value=[dict(nea1_128='3', nea2_128='9', nea3_128='3')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='9', nia3_128='3')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_A06 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '3'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '15'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '15'},
    dict(value=[dict(nea1_128='3', nea2_128='3', nea3_128='9')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='3', nia3_128='9')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_A11_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A11_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A11_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A11_restore = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '550'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
]

PARAMETERS_TO_UPDATE_A19_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '2'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A19_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '3'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '1'}
]

PARAMETERS_TO_UPDATE_A19_3 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '2'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A21_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '2'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '2'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A21_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A21_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'false'}
]

PARAMETERS_TO_UPDATE_A22_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '15'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '15'}
]

PARAMETERS_TO_UPDATE_A22_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '1'}
]

PARAMETERS_TO_UPDATE_A22_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'}
]

PARAMETERS_TO_UPDATE_A22_3 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'}
]

PARAMETERS_TO_UPDATE_COUNTER = [
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/PMCADM-1', 'parameter': 'reportingIntervalPm', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNGCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRRCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '5min'}
]

counter_id_A26_should_be_1 = [
    'M55124C04001', 'M55125C05501', 'M55125C05502', 'M55125C05513', 'M55125C05514'
]

counter_id_A26_not_zero = [
    'M55124C01004', 'M55124C01031', 'M55125C02501', 'M55125C02502', 'M55145C00220', 'M55145C00223', 'M55145C00502',
    'M55145C00501', 'M55138C01001', 'M55138C01002', 'M55125C02507', 'M55125C02508', 'M55125C05509', 'M55125C05510'
]

counter_dic_path_A26_should_be_1 = [
    'BTS/CELLS/NRCELL-1/NRRCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A26_not_zero = [
    'BTS/CELLS/NRCELL-1/NRRCC', 'BTS/CELLS/NRCELL-1/NRRCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/MCC-001_MNC-01/NRANS', 'BTS/CELLS/NRCELL-1/MCC-001_MNC-01/NRANS',
    'BTS/CELLS/NRCELL-1/MCC-001_MNC-01/NRANS', 'BTS/CELLS/NRCELL-1/MCC-001_MNC-01/NRANS', 'BTS/CELLS/NRCELL-1/RSACU',
    'BTS/CELLS/NRCELL-1/RSACU', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_id_A27_should_be_1 = [
    'M55125C05505', 'M55125C05506', 'M55125C05513', 'M55125C05514'
]

counter_id_A27_not_zero = [
    'M55125C02504', 'M55125C02505', 'M55149C01001'
]

counter_id_A27_not_zero_2 = [
    'M55125C05509', 'M55125C05510'
]

counter_dic_path_A27_should_be_1 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A27_348_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-3481/MCC-310_MNC-260/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A27_358_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-358/MCC-310_MNC-260/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A27_383_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-383/MCC-310_MNC-260/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A27_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/BTS/'+_NNRBTSname+'/MCC-310_MNC-260/SST-1_SD-13714341/NSL'
]

counter_dic_path_A27_not_zero_2 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A27_341_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-361/MCC-460_MNC-01/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A27_242_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-242/MCC-460_MNC-01/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

PARAMETERS_TO_UPDATE_A28 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'actNormVCFallback', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

counter_id_A28_should_be_1 = [
    'M55124C04002', 'M55125C05505', 'M55125C05507', 'M55125C05508'
]

counter_id_A28_not_zero = [
    'M55125C02504', 'M55125C02506'
]

counter_id_A28_0 = [
    'M55138C01002', 'M55125C02505'
]

counter_dic_path_A28_should_be_1 = [
    'BTS/CELLS/NRCELL-1/NRRCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A28_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

counter_dic_path_A28_0 = [
    'BTS/CELLS/NRCELL-1/RSACU', 'BTS/CELLS/NRCELL-1/NNGCC'
]

PARAMETERS_TO_UPDATE_A29_pre = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'actNormVCFallback', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A29 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

counter_id_A29_1 = [
    'M55125C05509', 'M55125C05511', 'M55125C05512', 'M55125C03501', 'M55125C03503', 'M55125C03504', 'M55138C01001',
    'M55124C04002', 'M55124C01502'
]

counter_id_A29_0 = [
    'M55138C01002'
]

counter_dic_path_A29_1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NNGCC', 'BTS/' + _NRBTSname + '/NRCELL-1/NNGCC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NNGCC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NNGCC', 'BTS/' + _NRBTSname + '/NRCELL-1/NNGCC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NNGCC',
    'BTS/' + _NRBTSname + '/NRCELL-1/RSACU',  'BTS/' + _NRBTSname + '/NRCELL-1/NRRCC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRCC'
]

counter_dic_path_A29_0 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/RSACU'
]
