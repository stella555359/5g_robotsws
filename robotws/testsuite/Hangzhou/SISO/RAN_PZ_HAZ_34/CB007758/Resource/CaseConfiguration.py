from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# General_SiSo_E2E_system_setup_with_data_transfer
# Exp_Len = '100m'
# frame_structure_list_20MHz = ['1116_3ms_GP1_A5']
# frame_structure_list_40MHz = ['1208_GP1_A1']
# frame_structure_list_60MHz = ['1070_GP1_B3']
# frame_structure_list_80MHz = ['1070_GP1_A3']
# frame_structure_list_100MHz = ['1116_0ms_GP1_A8']

# General_Peak_with_Given_Frame_Structure
# band_list_1116_0ms_GP2_A7 = [40]
# band_list_1116_0ms_GP2_A8 = [100]

# rate_for_stream = {
#     '19B': 'peak',
#     '20A': 'peak',
#     '20B': 'peak',
#     'master': '0.8'
# }

# define the default RU index and cell id for all cases, if some special cases
# need to use different ru index or cell id, please change by case
default_ru_index = '1'
default_cell_id = '1'

# # Modify value for ALD devices information
DICT_ALD_INFO = {
    "PRODUCT_CODE": "ATM3",
    "SERIAL_NUMBER": "0000CN10184761297",
    "VENDOR_CODE": "AN",
    "SW_VERSION": "2.0.20",
    "HW_VERSION": "2.0"
}

# MO for ALD cases
ALD_MOS_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        class_name='com.nokia.srbts.eqm:ALD',
        version='EQM21B_2105_002'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1/RETU-1',
        class_name='com.nokia.srbts.eqm:RETU',
        version='EQM21B_2105_002'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/RSL-1',
        class_name='com.nokia.srbts.eqm:RSL',
        version='EQM21B_2105_002'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/HWTOP-1/LOGLINK-1',
        class_name='com.nokia.srbts.eqm:LOGLINK',
        version='EQM21B_2105_002')
]
ALD_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        value='30',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='angle'),
    dict(
        value='80',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='maxAngle'),
    dict(
        value='0',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='mechanicalAngle'),
    dict(
        value='0',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='minAngle'),
    dict(
        value='AISG 2.0',
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='controlProtocol'),
    dict(
        value='ATM3',
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='productCode'),
    dict(
        value=DICT_ALD_INFO['SERIAL_NUMBER'],
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='serialNumber'),
    dict(
        value='1',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='subunitNumber'),
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/RSL-1',
        p_name='dcVoltageEnabled'),
    dict(
        value='true',
        dist_name='EQM-1/APEQM-1/RMOD-1/RSL-1',
        p_name='hdlcCommunicationAllowed'),
    dict(
        value='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/RSL-1',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='firstEndpointDN'),
    dict(
        value='false',
        dist_name='EQM-1/HWTOP-1/LOGLINK-1',
        p_name='linkModeConfiguration'),
    dict(
        value='false',
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
]
ALD_LIST_NAME_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antBandList'),
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antlDNList')
]
ALD_LIST_ITEMS_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antBandList',
        elements=dict(antBeamwidth='33', antFreqBand='1', antOperGain='240'))
]
ALD_LIST_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        list_name='antlDNList',
        elements=['external'])
]

# 5GC000399_eCPRI_FREERUN_state_handling
TOP_DOMAIN_NUMBER_MODIFY = [
    dict(dist_name='MRBTS-{mrbtsID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1',
         list_name=None,
         filter_param='ToP domain number',
         p_name='topDomainNumber',
         value='43')
]

# Below are the default value for test cases, basically, if the testline topology is the same,
# these input no need to update, But if the testline topology is different,
# you need to check case input for detail and update it from TLDalta.py to
# Cover it, e.g. TC34, ald_type: the default ald_type is RETU,
# but if the ALD type is RAEU in your testline, you need to
# Update this case input from TLDalta.py with the same parameter name
TCCB005845_TC11 = {
    "ru_index": default_ru_index,
}
TCCB005845_TC14 = {
    "ru_index": default_ru_index,
}
TCCB005845_TC16 = {
    "with_call": "False",
    "with_peak": "False",
}
TCCB005845_TC17 = {
    "with_call": "True",
}
TCCB005845_TC18 = {
    "addition_deletion_cell": "1",
    "addition_deletion_cellgrp": "0",
}
TCCB005845_TC19 = {
    "cell_id": default_cell_id,
}
TCCB005845_TC20 = {
    "ru_index": default_ru_index,
}
TCCB005845_TC21 = {
    "ru_index": default_ru_index,
}
TCCB005845_TC22 = {
    "ru_index": default_ru_index,
    "Tdanger_target": "30.0",
}
TCCB005845_TC23 = {
    "cell_id": default_cell_id,
}
TCCB005845_TC24 = {
    "band": "n77",
    "ru_index": default_ru_index,
    "cell_id": default_cell_id,
}
TCCB005845_TC28 = {
    "max_loop": "1",
}
TCCB005845_TC34 = {
    "ald_type": "RETU",
}
TCCB005845_TC35 = {
    "ald_type": "RETU",
}
TCCB005845_TC37 = {
    "ru_index": default_ru_index,
}
TCCB005845_TC39 = {
    "ue_index": "0",
}
TCCB005845_TC47 = {
    "frame_structure": "0",
    "ru_index": default_ru_index,
    "cell_id": default_cell_id,
    "ue_num_each_call": "1",
    "random_access": "False",
}
TCCB005845_TC48 = {
    "cell_band_frame_structure_list": "0",
    "cell_id": default_cell_id,
    "ue_num_each_call": "1",
    "random_access": "False",
}
TCCB005845_TC53 = [
    {"class_name": "com.nokia.srbts.mnl:SYNC", "parameter": "actEcpriMasterClock"},
    {"class_name": "com.nokia.srbts.mnl:CLOCK", "parameter": "syncMaster"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterDomainNumber"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterSyncMessageRate"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterAnnounceMessageRate"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterEthMulticastAddress"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterStandardProfile"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterSsmEnabled"},
    {"class_name": "com.nokia.srbts.mnl:ECPRIMASTER", "parameter": "eCpriMasterSsmType"},
    {"class_name": "com.nokia.srbts.mnl:TOP", "parameter": "topDomainNumber"},
    {"class_name": "com.nokia.srbts.mnl:TOPP", "parameter": "topStandardProfile"},
    {"class_name": "com.nokia.srbts.mnl:SYNC", "parameter": "profileType"},
]
TCCB005845_TC55 = {
    "ru_index": default_ru_index,
    "Tdanger_target": "30.0",
}
TCCB005845_TC62 = {
    "times": "2",
}
TCCB005845_TC56 = {
    "ALDBinFilePath": "/home/ute/ALD_fw.bin",
}
TCCB005845_TC57 = {
    "retu_index": "1",
}
TCCB005845_TC58 = {
    "retu_index": "1",
}
TCCB005845_TC59 = {
    "retu_index": "1",
}
