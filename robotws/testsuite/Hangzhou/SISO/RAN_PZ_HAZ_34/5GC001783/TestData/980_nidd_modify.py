from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')
MR_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
RMOD_NAME = MR_NAME + '/EQM-1/APEQM-1/RMOD-1/RSL-1'

PRODUCT_CODE = 'TRAE-TDGA12V01'
SERIAL_NUMBER = '012ASU01909190002'

if program == '19A':
    PRODUCT_CODE = 'TRAE-TDGA12V01'
    SERIAL_NUMBER = '012ASU01909190001'
elif program == '19B':
    PRODUCT_CODE = 'TRAE-TDGA12v01'
    SERIAL_NUMBER = '012ASU17011231803'
elif program == 'master':
    PRODUCT_CODE = 'TRAE-TDGA12V01'
    SERIAL_NUMBER = '012ASU01909190002'

# this parameters are used for scf modify and directly commission
MODIFY_SCF_980_BASE = [
    dict(
        value='true',
        dist_name=RMOD_NAME,
        p_name='dcVoltageEnabled'),
    dict(
        value='true',
        dist_name=RMOD_NAME,
        p_name='hdlcCommunicationAllowed'),
]

ALD_MOS_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        class_name='com.nokia.srbts.eqm:ALD',
        version='EQM19A_1904_002'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1/RAEU-1',
        class_name='com.nokia.srbts.eqm:RAEU',
        version='EQM19A_1904_002'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/HWTOP-1/LOGLINK-1',
        class_name='com.nokia.srbts.eqm:LOGLINK',
        version='EQM19A_1904_002')
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
        value=PRODUCT_CODE,
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='productCode'),
    dict(
        value=SERIAL_NUMBER,
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='serialNumber'),
    dict(
        value='1',
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        p_name='subunitNumber')
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
        elements=dict(antBeamwidth='33', antFreqBand='1', antOperGain='240'))
]

ALD_LIST_ELEMENTS_PARAMS_TO_ADD = [
    dict(
        dist_name='EQM-1/APEQM-1/ALD-1/RAEU-1',
        list_name='antlDNList',
        elements=['MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'])
]
