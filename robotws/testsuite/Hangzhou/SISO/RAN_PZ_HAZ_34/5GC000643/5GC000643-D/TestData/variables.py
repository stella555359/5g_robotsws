from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_E2E_system_setup_with_data_transfer
Exp_Len = '100m'
frame_structure_list_20MHz = ['1116_3ms_GP1_A5']
frame_structure_list_40MHz = ['1208_GP1_A1']
frame_structure_list_60MHz = ['1070_GP1_B3']
frame_structure_list_80MHz = ['1070_GP1_A3']
frame_structure_list_100MHz = ['1116_0ms_GP1_A8']

# General_Peak_with_Given_Frame_Structure
band_list_1116_0ms_GP2_A7 = [40]
band_list_1116_0ms_GP2_A8 = [100]

rate_for_stream = {
    '20B': 'peak',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

rate_for_stream_min = {
    '20B': '0.8',
    '21A': '0.8',
    'SBTS21B': '0.8',
    'SBTS22R1': '0.8',
    'master': '0.8'
}

# Modiy value for 5GC001541 ALD
DICT_ALD_INFO = {
    "PRODUCT_CODE": "TRAE-TDGA12V01",
    "SERIAL_NUMBER": "012ASU19122500003",
    "VENDOR_CODE": "TY",
    "SW_VERSION": "TDGA02V01-1.0.7",
    "HW_VERSION": "2.0.0"
}

ALD_MOS_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        class_name='com.nokia.srbts.eqm:ALD'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1/RAEU-1',
        class_name='com.nokia.srbts.eqm:RAEU'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/HWTOP-1/LOGLINK-1',
        class_name='com.nokia.srbts.eqm:LOGLINK'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/RSL-1',
        class_name='com.nokia.srbts.eqm:RSL')
]

ALD_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/RSL-1',
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
        value=DICT_ALD_INFO['PRODUCT_CODE'],
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='productCode'),
    dict(
        value=DICT_ALD_INFO['SERIAL_NUMBER'],
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='serialNumber'),
    dict(
        value='1',
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        p_name='subunitNumber'),
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/RSL-1',
        p_name='dcVoltageEnabled'),
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/RSL-1',
        p_name='hdlcCommunicationAllowed')
]

ALD_LIST_NAME_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        list_name='antBandList'),
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        list_name='antlDNList')
]

ALD_LIST_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        list_name='antBandList',
        elements=dict(antBeamwidth='33', antFreqBand='1', antOperGain='24'))
]

ALD_LIST_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        list_name='antlDNList',
        elements=['MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'])
]

# 5GC000399_eCPRI_FREERUN_state_handling
TOP_DOMAIN_NUMBER_MODIFY = [
    dict(dist_name='MRBTS-{mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
         list_name=None,
         filter_param='ToP domain number',
         p_name='topDomainNumber',
         value='43')
]
