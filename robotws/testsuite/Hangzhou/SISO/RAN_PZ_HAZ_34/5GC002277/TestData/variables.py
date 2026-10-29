from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# Modiy value for 5GC001541 ALD
DICT_ALD_INFO = {
    "PRODUCT_CODE": "TRAE-TDGA12V01",
    "SERIAL_NUMBER": "012ASU19122500001",
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
