# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


Variables_CFAM = {
    'AZQG': {
        'Uint_name': 'AZQG',
        'unitType_expect': '<unitType>AZ</unitType>',
        'variant_expect': '<variant>QG</variant>',
        'ProductCode_expect': '<p Name="Visible.Product.Code">474994A</p>',
        'SuppTech_expect': '<list Name="Supported.Technology"><p>5G</p></list>',
        'NRFreqBand_expect': '<list Name="NR.Frequency.Band"><p>78</p><p>78</p></list>',
        'LinkType_expect': '<p Name="Type">CPRI</p>'
    }
}
MR_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_NAME + '/NRCELLGRP-0'
MR_MNL_MNL_NET_PMMNL = 'MRBTS-' + \
    str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/PMMNL-1'
MR_MNL_MNL_SYNC_CLOCK_1 = 'MRBTS-' + \
    str(tl.gnbs[0].global_bts_id) + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1'
RSL_1 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/EQM-1/APEQM-1/RMOD-1/RSL-1'
ANTL_1 = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/EQM-1/APEQM-1/RMOD-1/ANTL-1'
LOGLINK_1 = 'MRBTS-' + \
    str(tl.gnbs[0].global_bts_id) + 'MRBTS-2071/EQM-1/HWTOP-1/LOGLINK-1'

LOGLINK_2 = 'MRBTS-' + \
    str(tl.gnbs[0].global_bts_id) + 'MRBTS-2071/EQM-1/HWTOP-1/LOGLINK-2'

PARA_2SubSector = [
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='actExternalAntennaBF',
        new_value='false'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='numOfSubSectors',
        new_value='2sub-sectors'),
    dict(
        operate='update',
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        new_value='2 beams'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='4x4 or 4x2 Open Loop Spatial Multiplexing'),
    dict(
        operate='update',
        dist_name=MR_NR_CELL_NAME,
        p_name='basicBeamSet',
        new_value='beamSet_2SS')
]

SCF_MODIFY_VALUE_ANTL1 = [
    dict(
        value='AUTO',
        dist_name='EQM-1/APEQM-1/RMOD-1/ANTL-1',
        p_name='dcVoltage'),
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/ANTL-1',
        p_name='hdlcCommunicationAllowed')
]

ATTENUATION_VALUE_nonBF_4D4U_1234 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port8': 127,
    'atten_value_of_port9': 127,
    'atten_value_of_port10': 127,
    'atten_value_of_port11': 127
}


def Spliting_rate_1358(text):
    d = text.split('.')[0]
    return d


ATTENUATION_VALUE_BF_1234 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
    'atten_value_of_port4': 0,
    'atten_value_of_port5': 0,
    'atten_value_of_port6': 0,
    'atten_value_of_port7': 0
}

ALD_MOS_PARAMS_TO_ADD_1 = [
    dict(
        dist_name='MRBTS-' +
        str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        class_name='com.nokia.srbts.eqm:ALD',
        version='EQM23R4_2311_100'),
    dict(
        dist_name='MRBTS-' +
        str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1/RETU-1',
        class_name='com.nokia.srbts.eqm:RETU',
        version='EQM23R4_2311_100'),
    dict(
        dist_name='MRBTS-' +
        str(tl.gnbs[0].instance_id) + '/EQM-1/HWTOP-1/LOGLINK-1',
        class_name='com.nokia.srbts.eqm:LOGLINK',
        version='EQM23R4_2311_100')
]

ALD_MOS_PARAMS_TO_ADD_2 = [
    dict(
        dist_name='MRBTS-' +
        str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-2',
        class_name='com.nokia.srbts.eqm:ALD',
        version='EQM23R4_2311_100'),
    dict(
        dist_name='MRBTS-' +
        str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-2/RETU-1',
        class_name='com.nokia.srbts.eqm:RETU',
        version='EQM23R4_2311_100'),
    dict(
        dist_name='MRBTS-' +
        str(tl.gnbs[0].instance_id) + '/EQM-1/HWTOP-1/LOGLINK-2',
        class_name='com.nokia.srbts.eqm:LOGLINK',
        version='EQM23R4_2311_100')
]
ALD_LIST_ELEMENTS_PARAMS_TO_ADD_1 = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antlDNList',
        elements=['MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-1'])
]

ALD_LIST_ELEMENTS_PARAMS_TO_ADD_2 = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-2/RETU-1',
        list_name='antlDNList',
        elements=['MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-2'])
]


ALD_LIST_NAME_PARAMS_TO_ADD_1 = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antlDNList')
]

ALD_LIST_NAME_PARAMS_TO_ADD_2 = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-2/RETU-1',
        list_name='antlDNList')
]

ALD_LIST_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antBandList',
        elements=dict(antBeamwidth='33', antFreqBand='1', antOperGain='240'))
]

ALD_ELEMENTS_PARAMS_TO_ADD_1 = [
    dict(
        value='MRBTS-' + str(tl.gnbs[0].instance_id) +
        '/EQM-1/APEQM-1/RMOD-1/ANTL-1',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='firstEndpointDN'),
    dict(
        value='true',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='linkModeConfiguration'),
    dict(
        value='true',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='linkModeDC'),
    dict(
        value='false',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='linkModeData'),
    dict(
        value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='secondEndpointDN'),
    dict(
        value='AISG 2.0',
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='controlProtocol'),
    dict(
        value='1',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='subunitNumber')
]

ALD_ELEMENTS_PARAMS_TO_ADD_2 = [
    dict(
        value='MRBTS-' + str(tl.gnbs[0].instance_id) +
        '/EQM-1/APEQM-1/RMOD-1/RSL-1',
        dist_name='EQM-1/HWTOP-1/LOGLINK-2',
        p_name='firstEndpointDN'),
    dict(
        value='true',
        dist_name='EQM-1/HWTOP-1/LOGLINK-2',
        p_name='linkModeConfiguration'),
    dict(
        value='true',
        dist_name='EQM-1/HWTOP-1/LOGLINK-2',
        p_name='linkModeDC'),
    dict(
        value='false',
        dist_name='EQM-1/HWTOP-1/LOGLINK-2',
        p_name='linkModeData'),
    dict(
        value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-2',
        dist_name='EQM-1/HWTOP-1/LOGLINK-2',
        p_name='secondEndpointDN'),
    dict(
        value='AISG 2.0',
        dist_name='EQM-1/APEQM-1/ALD-2',
        p_name='controlProtocol'),
    dict(
        value='1',
        dist_name='EQM-1/APEQM-1/ALD-2/RETU-1',
        p_name='subunitNumber')
]

SCF_MODIFY_VALUE_ALD = [
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/RSL-1',
        p_name='dcVoltageEnabled'),
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/RSL-1',
        p_name='hdlcCommunicationAllowed')
]

PARAMS_TO_MODIFY_SCF = []
