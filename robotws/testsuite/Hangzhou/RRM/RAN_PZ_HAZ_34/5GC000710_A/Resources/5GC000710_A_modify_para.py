# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].cu.global_bts_id)

MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id) + '/LNCEL-1'
MR_NR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id) + '/MNL-1/MNLENT-1/TRBLCADM-1'
MR_NR_BTS_NAME4 = 'MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
MR_NR_BTS_NAME5 = MR_NR_BTS_NAME + '/NRCELL-1/NRHOIF-1'
MR_NR_BTS_NAME6 = MR_NR_BTS_NAME + '/NRCELL-1/NRHOIF-2'
MR_NR_BTS_NAME16 = MR_NR_BTS_NAME + '/NRCELL-1/NRHOIF-3'
MR_NR_BTS_NAME23 = MR_NR_BTS_NAME + '/NRCELL-2/NRHOIF-1'
MR_NR_BTS_NAME24 = MR_NR_BTS_NAME + '/NRCELL-2/NRHOIF-2'
MR_NR_BTS_NAME18 = MR_NR_BTS_NAME + '/NRCELL-3/NRHOIF-1'
MR_NR_BTS_NAME19 = MR_NR_BTS_NAME + '/NRCELL-3/NRHOIF-2'
MR_NR_BTS_NAME7 = MR_NR_BTS_NAME + '/NRMEASCFG_IF-1'
MR_NR_BTS_NAME8 = MR_NR_BTS_NAME + '/NRMEASCFG_IF-2'
MR_NR_BTS_NAME12 = MR_NR_BTS_NAME + '/NRMEASCFG_IF-3'
MR_NR_BTS_NAME13 = MR_NR_BTS_NAME + '/NRMOPR_NSA-2'
MR_NR_BTS_NAME14 = MR_NR_BTS_NAME + '/NRCELL-2/NRHOIF-1'
MR_NR_BTS_NAME15 = MR_NR_BTS_NAME + '/NRMOPR_NSA-3'
MR_NR_BTS_NAME17 = MR_NR_BTS_NAME + '/NRMOPR_NSA-4'
MR_NR_BTS_NAME11 = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_BTS_NAME29 = MR_NR_BTS_NAME + '/NRMOPRMA_NSA-2'

MR_NR_BTS_NAME22 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-1'
MR_NR_BTS_NAME9 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-1/NRHOIF-1'
MR_NR_BTS_NAME10 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-1/NRHOIF-2'
MR_NR_BTS_NAME20 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-3/NRHOIF-1'
MR_NR_BTS_NAME21 = 'MRBTS-' + str(tl.gnbs[0].dus[1].instance_id) + '/NRBTS-1/NRCELL-3/NRHOIF-2'
MR_NR_BTS_NAME25 = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id) + '/NRBTS-1/NRCELL-2/NRHOIF-1'
MR_NR_BTS_NAME26 = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id) + '/NRBTS-1/NRCELL-2/NRHOIF-2'
MR_NR_BTS_NAME27 = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id) + '/NRBTS-1/NRCELL-2'
MR_NR_BTS_NAME28 = MR_NR_BTS_NAME + '/NRCELL-3/NRHOIF-2'

test_pc = str(tl.test_pc.default_ssh_connection_details.addr)
test_pc_recover = str(tl.gnbs[0].cu.f1m.v4)

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='defaultLnRelGnbCellId', value='0')]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc})]

PARAMS_TO_MODIFY_DomainNumber2 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc})]

PARAMS_TO_MODIFY_DomainNumber3 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc_recover})]

PARAMS_TO_MODIFY_DomainNumber6 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerIPaddress': test_pc_recover})]

PARAMS_TO_MODIFY_DomainNumber7 = [dict(
    dist_name=MR_NR_BTS_NAME2, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51000'})]

PARAMS_TO_MODIFY_DomainNumber8 = [dict(
    dist_name=MR_NR_BTS_NAME3, parameter='remoteSyslogConfig', value={'remoteSyslogServerPortNo': '51001'})]

PARAMS_TO_MODIFY_DomainNumber9 = [dict(dist_name=MR_NR_BTS_NAME4, parameter='actEndcSpidFwd', value='true')]

PARAMS_TO_MODIFY_DomainNumber10 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='defaultLnRelGnbCellId', value='1')]

CU_parameter_002_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2253979'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2256859'},
    MR_NR_BTS_NAME7: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2253979'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2256859'}
}

DU_002_parameter_1 = [dict(dist_name=MR_NR_BTS_NAME9, parameter='ssbFrequency', value='2253979')]
DU_002_parameter_2 = [dict(dist_name=MR_NR_BTS_NAME10, parameter='ssbFrequency', value='2256859')]

CU_parameter_008_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073115'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME7: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073115'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME: {'actSPID': 'false'}
}

CU_parameter_013_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME12: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME13: {'a2MeashoEnabled': 'rsrpCombined'}
}

CU_parameter_013_2 = {MR_NR_BTS_NAME8: {'a3MeasEnabled': 'none', 'a5MeasEnabled': 'rsrp'}}

CU_parameter_008_2 = {MR_NR_BTS_NAME: {'actSPID': 'true'}}

CU_parameter_007_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2256859'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME14: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2256859'},
    MR_NR_BTS_NAME12: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2256859'},
    MR_NR_BTS_NAME7: {'a3MeasEnabled': 'rsrp', 'a5MeasEnabled': 'none'},
    MR_NR_BTS_NAME13: {'nrMeasCfgIfDNList': [MR_NR_BTS_NAME7, MR_NR_BTS_NAME8]},
    MR_NR_BTS_NAME15: {'nrMeasCfgIfDNList': [MR_NR_BTS_NAME12]}
}

CU_parameter_010_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME12: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME13: {'a2MeashoEnabled': 'rsrp', 'a1MeashoEnabled': 'rsrpCombined'},
    MR_NR_BTS_NAME7: {'a3MeasEnabled': 'rsrp', 'a5MeasEnabled': 'none'},
    MR_NR_BTS_NAME11: {'a2MeashoSsbRsrp': [{'a2ThresholdhoSsbRsrp': '80'}, {'a2HysteresishoSsbRsrp': '0'}],
                       'a1MeashoSsbRsrp': [{'a1ThresholdhoSsbRsrp': '106'}, {'a1HysteresishoSsbRsrp': '0'}]}
}

CU_parameter_001_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691',
                      'a3MeasEnabled': 'rsrp', 'a5MeasEnabled': 'none'},
    MR_NR_BTS_NAME12: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267',
                       'a3MeasEnabled': 'rsrp', 'a5MeasEnabled': 'none'},
    MR_NR_BTS_NAME18: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073115'},
    MR_NR_BTS_NAME19: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME7: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073115'},
    MR_NR_BTS_NAME11: {'a2MeashoSsbRsrp': [{'a2ThresholdhoSsbRsrp': '80'}, {'a2HysteresishoSsbRsrp': '0'}],
                       'a1MeashoSsbRsrp': [{'a1ThresholdhoSsbRsrp': '106'}, {'a1HysteresishoSsbRsrp': '0'}]}
}

CU_parameter_011_1 = {
    MR_NR_BTS_NAME23: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME24: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691',
                      'a3MeasEnabled': 'none', 'a5MeasEnabled': 'rsrp'},
    MR_NR_BTS_NAME12: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267',
                       'a3MeasEnabled': 'none', 'a5MeasEnabled': 'rsrp'},
    MR_NR_BTS_NAME18: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073115'},
    MR_NR_BTS_NAME19: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME7: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073115'},
    MR_NR_BTS_NAME11: {'a2MeashoSsbRsrp': [{'a2ThresholdhoSsbRsrp': '80'}, {'a2HysteresishoSsbRsrp': '0'}],
                       'a1MeashoSsbRsrp': [{'a1ThresholdhoSsbRsrp': '106'}, {'a1HysteresishoSsbRsrp': '0'}]}
}

CU_parameter_014_1 = {
    MR_NR_BTS_NAME5: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME6: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME8: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2073691'},
    MR_NR_BTS_NAME12: {'freqBandIndicatorNR': '257', 'ssbFrequency': '2074267'},
    MR_NR_BTS_NAME13: {'a2MeashoEnabled': 'rsrp'}
}

CU_parameter_014_2 = {
    MR_NR_BTS_NAME29: {'mobilityProfilePriority': '2'},
    MR_NR_BTS_NAME13: {'a1MeashoEnabled': 'rsrp'}
}

DU_008_parameter_1 = [dict(dist_name=MR_NR_BTS_NAME9, parameter='ssbFrequency', value='2073115')]
DU_008_parameter_2 = [dict(dist_name=MR_NR_BTS_NAME10, parameter='ssbFrequency', value='2073691')]

DU_013_parameter_1 = [dict(dist_name=MR_NR_BTS_NAME9, parameter='ssbFrequency', value='2073691')]
DU_013_parameter_2 = [dict(dist_name=MR_NR_BTS_NAME10, parameter='ssbFrequency', value='2074267')]
DU_013_parameter_3 = [dict(dist_name=MR_NR_BTS_NAME22, parameter='gapOffset', value='12')]

DU_007_parameter_1 = [dict(dist_name=MR_NR_BTS_NAME9, parameter='ssbFrequency', value='2256859')]

DU_001_parameter_1 = [dict(dist_name=MR_NR_BTS_NAME20, parameter='ssbFrequency', value='2073115')]
DU_001_parameter_2 = [dict(dist_name=MR_NR_BTS_NAME21, parameter='ssbFrequency', value='2074267')]

DU_011_parameter_1 = [dict(dist_name=MR_NR_BTS_NAME25, parameter='ssbFrequency', value='2073691')]
DU_011_parameter_2 = [dict(dist_name=MR_NR_BTS_NAME26, parameter='ssbFrequency', value='2074267')]
DU_011_parameter_3 = [dict(dist_name=MR_NR_BTS_NAME27, parameter='gapOffset', value='12')]

keywords_list1 = ['TRBLCADM_A-1']
