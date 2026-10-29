from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

MODIFY_INVALID_MCS_VIA_WEBUI = [
    dict(
        new_value='-1',
        dist_name='NRCELL-1',
        abbr='ullaIniMcs',
        filter_param='Initial MCS for UL Transmission'),
    dict(
        new_value='30',
        dist_name='NRCELL-1',
        abbr='dllaIniMcs',
        filter_param='Initial MCS for DL Transmission')
]

# Modify value for 5GC001541_017
MODIFY_VALUE_ABOVE_AWHHD_REQUIRED_RANGE_VIA_API_017 = [
    dict(
        value='535000',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

MODIFY_VALUE_BELOW_AWHHD_REQUIRED_RANGE_VIA_API_017 = [
    dict(
        value='503000',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

MODIFY_VALUE_WITHIN_AWHHD_REQUIRED_RANGE_VIA_API_017 = [
    dict(
        value='518598',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

# Modify value for 5GC001541_019,[30-43]
MODIFY_VALUE_ABOVE_AWHHD_REQUIRED_RANGE_VIA_API_019 = [
    dict(
        value='460',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='pMax')
]

MODIFY_VALUE_BELOW_AWHHD_REQUIRED_RANGE_VIA_API_019 = [
    dict(
        value='280',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='pMax')
]

MODIFY_VALUE_WITHIN_AWHHD_REQUIRED_RANGE_VIA_API_019 = [
    dict(
        value='360',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='pMax')
]

MODIFY_NRARFCN_WITH_AWHHD_BAND_N41_EDGE_MIN_VALUE_VIA_API = [
    dict(
        value='513000',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

MODIFY_NRARFCN_WITH_AWHHD_BAND_N41_EDGE_MAX_VALUE_VIA_API = [
    dict(
        value='525000',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='nrarfcn')
]

# Modiy value for 5GC001541 ALD
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

ALD_MOS_PARAMS_TO_ADD = [
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1',
        class_name='com.nokia.srbts.eqm:ALD',
        version='EQM19A_1904_002'),
    dict(
        dist_name='MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/ALD-1/RETU-1',
        class_name='com.nokia.srbts.eqm:RETU',
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
        value='replace_productCode',
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='productCode'),
    dict(
        value='replace_serialNumber',
        dist_name='EQM-1/APEQM-1/ALD-1',
        p_name='serialNumber'),
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
        value='1',
        dist_name='EQM-1/APEQM-1/ALD-1/RETU-1',
        p_name='subunitNumber')
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
        elements=['MRBTS-' + str(tl.gnbs[0].instance_id) + '/EQM-1/APEQM-1/RMOD-1/ANTL-1'])
]

# Modify value for 5GC001783_041
SCF_MODIFY_VALUE_CASE_041 = [
    dict(
        value='22',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='22',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='100MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw'),
]

# Modify value for 5GC001783_047
SCF_MODIFY_VALUE_CASE_047 = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='100MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw'),
]

# Modify value for 5GC001783_048
SCF_MODIFY_VALUE_CASE_048 = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='100MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw'),
]


# Modify value for 5GC001783_051
SCF_MODIFY_VALUE_CASE_051 = [
    dict(
        value='11',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='11',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='60MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='4DL2UL',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='nrCellType'),
]


# Modify value for 5GC001783_052
SCF_MODIFY_VALUE_CASE_052 = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='60MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw'),
]
