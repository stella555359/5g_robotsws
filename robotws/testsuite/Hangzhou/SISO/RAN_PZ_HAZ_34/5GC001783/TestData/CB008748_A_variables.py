from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


# frame_structure_list_80MHz = ['1116_0ms_GP2_A7']

PRODUCT_CODE = 'TRAE-TDGA12v01'
SERIAL_NUMBER = '012ASU17011231783'


UL_THROUGHPUT = '200M'
DL_THROUGHPUT = '500M'

DURATION = '6000'

UL_EXPECT_30M = '90'
DL_EXPECT_30M = '180'

ALD_MOS_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        class_name='com.nokia.srbts.eqm:ALD',
        version='EQM22R2_2112_100'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1/RAEU-1',
        class_name='com.nokia.srbts.eqm:RAEU',
        version='EQM22R2_2112_100'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/HWTOP-1/LOGLINK-1',
        class_name='com.nokia.srbts.eqm:LOGLINK',
        version='EQM22R2_2112_100')
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
