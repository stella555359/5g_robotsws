from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSnames2 = 'NRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_gnb3_id = str(tl.gnbs[2].instance_id)
_MRBTSname3 = 'MRBTS-'+_gnb3_id
_NRBTSnames3 = 'NRBTS-'+_gnb3_id
_NRBTSname3 = _MRBTSname3+'/NRBTS-'+_gnb3_id

_gnb4_id = str(tl.gnbs[3].instance_id)
_MRBTSname4 = 'MRBTS-'+_gnb4_id
_NRBTSnames4 = 'NRBTS-'+_gnb4_id
_NRBTSname4 = _MRBTSname4+'/NRBTS-'+_gnb4_id

_NRCELL11 = _NRBTSname+'/NRCELL-1'
_NRCELL12 = _NRBTSname+'/NRCELL-2'
_NRCELL13 = _NRBTSname+'/NRCELL-3'
_NRCELL111 = _NRBTSname+'/NRCELL-11'
_NRCELL131 = _NRBTSname+'/NRCELL-31'

_NRREL1211 = _NRCELL12+'/NRREL-11'
_NRREL1231 = _NRCELL12+'/NRREL-31'
_NRREL1232 = _NRCELL12+'/NRREL-32'
_NRREL1241 = _NRCELL12+'/NRREL-41'
_NRREL1242 = _NRCELL12+'/NRREL-42'

_NRREL131 = _NRCELL13+'/NRREL-1'
_NRREL132 = _NRCELL13+'/NRREL-2'
_NRREL133 = _NRCELL13+'/NRREL-3'
_NRREL134 = _NRCELL13+'/NRREL-4'
_NRREL135 = _NRCELL13+'/NRREL-5'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL221 = _NRBTSname2+'/NRCELL-21'

_NRCELL31 = _NRBTSname3+'/NRCELL-1'
_NRCELL311 = _NRBTSname3+'/NRCELL-11'
_NRCELL32 = _NRBTSname3+'/NRCELL-2'
_NRCELL33 = _NRBTSname3+'/NRCELL-3'
_NRCELL331 = _NRBTSname3+'/NRCELL-31'

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL42 = _NRBTSname4+'/NRCELL-2'
_NRCELL43 = _NRBTSname4+'/NRCELL-3'
_NRCELL431 = _NRBTSname4+'/NRCELL-31'

MOS_ADD_GNB1_DB001 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL131, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL132, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL133, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_DB001 = [
    dict(value='0dB', dist_name=_NRREL131, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL131, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL131, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL131, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL131, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL131, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL131, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL131, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL131, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL131, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL131, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL131, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL131, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL132, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL132, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL132, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL132, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL132, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL132, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL132, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL132, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL132, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL132, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL132, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL132, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL132, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL133, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL133, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL133, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL133, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL133, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL133, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL133, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL133, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL133, p_name='nrDcAllowed'),
    dict(value='3', dist_name=_NRREL133, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL133, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL133, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL133, p_name='sCellOperationalMode'),

    dict(value='notBarred', dist_name=_NRCELL13, p_name='cellBarred'),
    dict(value='10', dist_name=_NRBTSname, p_name='weightForIgnbCaSelection'),
    dict(value='10', dist_name=_NRBTSname + '/NRADJGNB-13', p_name='weightForIgnbCaSelection'),
    dict(value='25', dist_name=_NRCELL12, p_name='weightForSCellSelection')
]

LIST_TO_ADD_GNB1_DB001 = [
    dict(
        dist_name=_NRREL131,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL132,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL133,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

PARAMETERS_TO_MODIFY_GNB3_DB001 = [
    dict(value='50', dist_name=_NRCELL32, p_name='weightForSCellSelection')
]

PARAMETERS_TO_MODIFY_GNB4_DB001 = [
    dict(value='50', dist_name=_NRCELL431, p_name='weightForSCellSelection')
]

MOS_ADD_GNB1_DB004 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL131, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL132, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL133, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL134, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL135, version="NRBTSCL22R4_2210_100"),
]

PARAMETERS_TO_MODIFY_GNB1_DB004 = [
    dict(value='0dB', dist_name=_NRREL131, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL131, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL131, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL131, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL131, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL131, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL131, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL131, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL131, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL131, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL131, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL131, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL131, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL132, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL132, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL132, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL132, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL132, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL132, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL132, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL132, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL132, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL132, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL132, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL132, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL132, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL133, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL133, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL133, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL133, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL133, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL133, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL133, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL133, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL133, p_name='nrDcAllowed'),
    dict(value='3', dist_name=_NRREL133, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL133, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL133, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL133, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL134, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL134, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL134, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL134, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL134, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL134, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL134, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL134, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL134, p_name='nrDcAllowed'),
    dict(value='4', dist_name=_NRREL134, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL134, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL134, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL134, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL135, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL135, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL135, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL135, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL135, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL135, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL135, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL135, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL135, p_name='nrDcAllowed'),
    dict(value='5', dist_name=_NRREL135, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL135, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL135, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL135, p_name='sCellOperationalMode'),

    dict(value='notBarred', dist_name=_NRCELL13, p_name='cellBarred'),
    dict(value='1', dist_name=_NRBTSname + '/NRADJGNB-13', p_name='weightForIgnbCaSelection'),
    dict(value='1', dist_name=_NRBTSname + '/NRADJGNB-14', p_name='weightForIgnbCaSelection'),
    dict(value='424200', dist_name=_NRBTSname + '/NRADJNRCELL-31', p_name='nrarfcn'),
    dict(value='66', dist_name=_NRBTSname + '/NRADJNRCELL-31', p_name='freqBandIndicatorNR'),
]

LIST_TO_ADD_GNB1_DB004 = [
    dict(
        dist_name=_NRREL131,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL132,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL133,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL134,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL135,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

PARAMETERS_TO_MODIFY_GNB3_DB004 = [
    dict(value='50', dist_name=_NRCELL31, p_name='weightForSCellSelection'),
    dict(value='50', dist_name=_NRCELL32, p_name='weightForSCellSelection'),
    dict(value='25', dist_name=_NRCELL311, p_name='weightForSCellSelection'),
    dict(value='66', dist_name=_NRCELL31, p_name='freqBandIndicatorNR'),
    dict(value='424200', dist_name=_NRCELL31 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='344100', dist_name=_NRCELL31 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
]

PARAMETERS_TO_DELETE_GNB3_DB004 = [
    dict(dist_name=_NRCELL31, p_name='nrConnectModeProfileDN'),
    dict(dist_name=_NRCELL31, p_name='nrMultibandInfoProfileDN')
]

PARAMETERS_TO_MODIFY_GNB4_DB004 = [
    dict(value='30MHz', dist_name=_NRCELL431, p_name='chBw'),
    dict(value='50', dist_name=_NRCELL43, p_name='weightForSCellSelection'),
    dict(value='50', dist_name=_NRCELL431, p_name='weightForSCellSelection')
]

PARAMETERS_TO_DELETE_GNB4_DB004 = [
    dict(dist_name=_NRCELL431, list_name='cellBwpList')
]

LIST_TO_ADD_GNB4_DB004 = [
    dict(
        dist_name=_NRCELL431,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_NRBTSname4 + '/BWP_PROFILE-7',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL431,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_NRBTSname4 + '/BWP_PROFILE-78',
            cellBwpId='1')
    )
]

MOS_ADD_GNB1_DC001 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1211, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1231, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1232, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1241, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1242, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_DC001 = [
    dict(value='0dB', dist_name=_NRREL1211, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1211, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL1211, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL1211, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1211, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1211, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1211, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL1211, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1211, p_name='nrDcAllowed'),
    dict(value='11', dist_name=_NRREL1211, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1211, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1211, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1211, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL1231, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1231, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL1231, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1231, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1231, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1231, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1231, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL1231, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1231, p_name='nrDcAllowed'),
    dict(value='31', dist_name=_NRREL1231, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1231, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1231, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1231, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL1232, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1232, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL1232, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1232, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1232, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1232, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1232, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL1232, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1232, p_name='nrDcAllowed'),
    dict(value='32', dist_name=_NRREL1232, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1232, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1232, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1232, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL1241, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1241, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL1241, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1241, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1241, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1241, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1241, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL1241, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1241, p_name='nrDcAllowed'),
    dict(value='41', dist_name=_NRREL1241, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1241, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1241, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1241, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL1242, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1242, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL1242, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1242, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1242, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1242, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1242, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL1242, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1242, p_name='nrDcAllowed'),
    dict(value='42', dist_name=_NRREL1242, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1242, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1242, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1242, p_name='sCellOperationalMode'),

    dict(value='notBarred', dist_name=_NRCELL12, p_name='cellBarred')
]

LIST_TO_ADD_GNB1_DC001 = [
    dict(
        dist_name=_NRREL1211,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1231,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1232,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1241,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1242,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

PARAMETERS_TO_MODIFY_GNB3_DC001 = [
    dict(value='20MHz', dist_name=_NRCELL33, p_name='chBw'),
    dict(value='50', dist_name=_NRCELL311, p_name='weightForSCellSelection'),
    dict(value='30', dist_name=_NRCELL33, p_name='weightForSCellSelection')
]

PARAMETERS_TO_DELETE_GNB3_DC001 = [
    dict(dist_name=_NRCELL33, list_name='cellBwpList')
]

LIST_TO_ADD_GNB3_DC001 = [
    dict(
        dist_name=_NRCELL33,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname3 + '/BWP_PROFILE-7',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL33,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname3 + '/BWP_PROFILE-70',
            cellBwpId='1')
    )
]

PARAMETERS_TO_MODIFY_GNB4_DC001 = [
    dict(value='50', dist_name=_NRCELL42, p_name='weightForSCellSelection'),
    dict(value='40', dist_name=_NRCELL43, p_name='weightForSCellSelection')
]
