from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_xnap_gnb1 = str(tl.gnbs[0].dus[0].f1_c_ip_addr)
_xnap_gnb3 = str(tl.gnbs[2].dus[0].f1_c_ip_addr)
_xnap_gnb4 = str(tl.gnbs[3].dus[0].f1_c_ip_addr)

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSnames2 = 'NRBTS-'+_gnb_id
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
_NRREL111 = _NRCELL11+'/NRREL-1'
_NRREL112 = _NRCELL11+'/NRREL-2'
_NRREL113 = _NRCELL11+'/NRREL-3'
_NRREL121 = _NRCELL12+'/NRREL-1'
_NRREL122 = _NRCELL12+'/NRREL-2'
_NRPLMN_11 = _NRBTSname + '/NRPLMN-1'
_NRPLMN_12 = _NRBTSname + '/NRPLMN-2'
_SNSSAI_12 = _NRBTSname + '/SNSSAI-2'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL221 = _NRBTSname2+'/NRCELL-21'
_NRREL211 = _NRCELL21+'/NRREL-1'
_NRREL221 = _NRCELL22+'/NRREL-1'

_NRCELL31 = _NRBTSname3+'/NRCELL-1'
_NRCELL311 = _NRBTSname3+'/NRCELL-11'
_NRCELL32 = _NRBTSname3+'/NRCELL-2'
_NRCELL33 = _NRBTSname3+'/NRCELL-3'
_NRCELL331 = _NRBTSname3+'/NRCELL-31'
_NRCELL34 = _NRBTSname3+'/NRCELL-4'
_NRCELL341 = _NRBTSname3+'/NRCELL-41'
_NRREL311 = _NRCELL31+'/NRREL-1'
_NRREL321 = _NRCELL32+'/NRREL-1'
_NRREL322 = _NRCELL32+'/NRREL-2'
_NRREL331 = _NRCELL33+'/NRREL-1'
_NRREL332 = _NRCELL33+'/NRREL-2'
_NRREL3311 = _NRCELL331+'/NRREL-1'

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL42 = _NRBTSname4+'/NRCELL-2'
_NRCELL421 = _NRBTSname4+'/NRCELL-21'
_NRCELL43 = _NRBTSname4+'/NRCELL-3'
_NRCELL431 = _NRBTSname4+'/NRCELL-31'
_NRREL411 = _NRCELL41+'/NRREL-1'
_NRREL412 = _NRCELL41+'/NRREL-2'
_NRPLMN_41 = _NRBTSname4 + '/NRPLMN-1'
_NRPLMN_42 = _NRBTSname4 + '/NRPLMN-2'
_SNSSAI_42 = _NRBTSname4 + '/SNSSAI-2'

_XNLINK113 = _NRBTSname + '/XNLINK-13'
_XNLINK114 = _NRBTSname + '/XNLINK-14'
_NRADJGNB113 = _NRBTSname + '/NRADJGNB-13'
_NRADJGNB114 = _NRBTSname + '/NRADJGNB-14'
_NRADJNRCELL131 = _NRBTSname + '/NRADJNRCELL-31'
_NRADJNRCELL132 = _NRBTSname + '/NRADJNRCELL-32'
_NRADJNRCELL133 = _NRBTSname + '/NRADJNRCELL-33'
_NRADJNRCELL1311 = _NRBTSname + '/NRADJNRCELL-311'
_NRADJNRCELL1331 = _NRBTSname + '/NRADJNRCELL-331'
_NRADJNRCELL141 = _NRBTSname + '/NRADJNRCELL-41'
_NRADJNRCELL142 = _NRBTSname + '/NRADJNRCELL-42'
_NRADJNRCELL143 = _NRBTSname + '/NRADJNRCELL-43'
_NRADJNRCELL1421 = _NRBTSname + '/NRADJNRCELL-421'
_NRADJNRCELL1431 = _NRBTSname + '/NRADJNRCELL-431'
_XPIFREMOTE12 = _MRBTSname + '/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2'
_XPIFREMOTE13 = _MRBTSname + '/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3'

_XNLINK311 = _NRBTSname3 + '/XNLINK-11'
_NRADJGNB311 = _NRBTSname3 + '/NRADJGNB-11'
_XPIFREMOTE31 = _MRBTSname3 + '/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1'

_XNLINK411 = _NRBTSname4 + '/XNLINK-11'
_NRADJGNB411 = _NRBTSname4 + '/NRADJGNB-11'
_XPIFREMOTE41 = _MRBTSname4 + '/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-1'


MOS_ADD_GNB1_L006 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL121, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB2_L006 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL211, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB4_L006 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL411, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL412, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB1_L011 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL111, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB1_L012 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL112, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB1_UPD010 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL112, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_L006 = [
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL111, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL121, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL121, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL121, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL121, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL121, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL121, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL121, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL121, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL121, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL121, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL121, p_name='sCellOperationalMode'),
    dict(value='rsrp', dist_name=_NRCELL12, p_name='a1MeasSCellAddEnabled'),
    dict(value='disabled', dist_name=_NRBTSname + '/NRDU-1', p_name='actInterGnbCa'),
    dict(value='true', dist_name=_NRBTSname, p_name='actMeasBasedSCellAddition'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),
    dict(value='100', dist_name=_NRCELL11, p_name='weightForSCellSelection')
]

PARAMETERS_TO_MODIFY_GNB2_L006 = [
    dict(value='0dB', dist_name=_NRREL211, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL211, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL211, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL211, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL211, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL211, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL211, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL211, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL211, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL211, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL211, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL211, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL211, p_name='sCellOperationalMode'),
    dict(value='DLOnly', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actInterGnbCa')
]

PARAMETERS_TO_MODIFY_GNB3_L006 = [
    dict(value='disabled', dist_name=_NRBTSname3 + '/NRDU-1', p_name='actInterGnbCa'),
    dict(value='100', dist_name=_NRCELL31, p_name='weightForSCellSelection')
]

PARAMETERS_TO_MODIFY_GNB4_L006 = [
    dict(value='0dB', dist_name=_NRREL411, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL411, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL411, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL411, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL411, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL411, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL411, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL411, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL411, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL411, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL411, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL411, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL411, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL412, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL412, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL412, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL412, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL412, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL412, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL412, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL412, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL412, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL412, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL412, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL412, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL412, p_name='sCellOperationalMode'),
    dict(value='DLOnly', dist_name=_NRBTSname4 + '/NRDU-1', p_name='actInterGnbCa'),
    dict(value='rsrp', dist_name=_NRCELL41, p_name='a1MeasSCellAddEnabled'),
    dict(value='true', dist_name=_NRBTSname4, p_name='actMeasBasedSCellAddition'),
    dict(value='1', dist_name=_NRBTSname4, p_name='weightForIgnbCaSelection'),
    dict(value='100', dist_name=_NRBTSname4 + '/NRADJGNB-11', p_name='weightForIgnbCaSelection'),
    dict(value='1', dist_name=_NRCELL42, p_name='weightForSCellSelection')
]

MO_TO_ONLINE_ADD_GNB1_L006 = [
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL122, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL122, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL122, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL122, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL122, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL122, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL122, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL122, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL122, parameter='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL122, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL122, parameter='gnbPlmn')
]

PARAMETERS_TO_MODIFY_GNB4_L006_LOCK = [
    dict(value='Locked', dist_name=_NRCELL43, parameter='administrativeState'),
]

PARAMETERS_TO_MODIFY_GNB4_L006_UNLOCK = [
    dict(value='Unlocked', dist_name=_NRCELL43, parameter='administrativeState'),
]

PARAMETERS_TO_MODIFY_GNB1_L006_NO_8140 = [
    dict(value='disabled', dist_name=_NRBTSname + '/NRDU-1', parameter='actInterGnbCa'),
]

PARAMETERS_TO_MODIFY_GNB4_L006_NO_8140 = [
    dict(value='disabled', dist_name=_NRBTSname4 + '/NRDU-1', parameter='actInterGnbCa'),
]

PARAMETERS_TO_MODIFY_GNB1_L006_8140 = [
    dict(value='DLOnly', dist_name=_NRBTSname + '/NRDU-1', parameter='actInterGnbCa'),
]

PARAMETERS_TO_MODIFY_GNB4_L006_8140 = [
    dict(value='DLOnly', dist_name=_NRBTSname4 + '/NRDU-1', parameter='actInterGnbCa'),
]

MO_TO_DELETE_GNB1_L006 = [
    dict(dist_name=_NRREL111),
    dict(dist_name=_NRREL121),
    dict(dist_name=_NRREL122),
]

PARAMETERS_TO_DELETE_GNB1_L008_NO_8140 = [
    dict(dist_name=_XNLINK113),
    dict(dist_name=_XNLINK114),
    dict(dist_name=_NRADJGNB113),
    dict(dist_name=_NRADJGNB114),
    dict(dist_name=_NRADJNRCELL131),
    dict(dist_name=_NRADJNRCELL132),
    dict(dist_name=_NRADJNRCELL133),
    dict(dist_name=_NRADJNRCELL1311),
    dict(dist_name=_NRADJNRCELL1331),
    dict(dist_name=_NRADJNRCELL141),
    dict(dist_name=_NRADJNRCELL142),
    dict(dist_name=_NRADJNRCELL143),
    dict(dist_name=_NRADJNRCELL1421),
    dict(dist_name=_NRADJNRCELL1431),
    dict(dist_name=_NRBTSname + '/NRDU-1', list_name='xgUplane'),
    dict(dist_name=_XPIFREMOTE12),
    dict(dist_name=_XPIFREMOTE13)
]

PARAMETERS_TO_MODIFY_GNB1_L008_NO_8140 = [
    dict(value='disabled', dist_name=_NRBTSname + '/NRDU-1', p_name='actInterGnbCa'),
]

PARAMETERS_TO_DELETE_GNB3_L008_NO_8140 = [
    dict(dist_name=_XNLINK311),
    dict(dist_name=_NRADJGNB311),
    dict(dist_name=_XPIFREMOTE31),
    dict(dist_name=_NRBTSname3 + '/NRDU-1', list_name='xgUplane')
]

PARAMETERS_TO_MODIFY_GNB3_L008_NO_8140 = [
    dict(value='disabled', dist_name=_NRBTSname3 + '/NRDU-1', p_name='actInterGnbCa'),
]

PARAMETERS_TO_DELETE_GNB4_L008_NO_8140 = [
    dict(dist_name=_XNLINK411),
    dict(dist_name=_NRADJGNB411),
    dict(dist_name=_XPIFREMOTE41),
    dict(dist_name=_NRBTSname4 + '/NRDU-1', list_name='xgUplane')
]

PARAMETERS_TO_MODIFY_GNB4_L008_NO_8140 = [
    dict(value='disabled', dist_name=_NRBTSname4 + '/NRDU-1', p_name='actInterGnbCa'),
]

MO_TO_ONLINE_ADD_GNB1_L008 = [
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL121, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL121, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL121, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL121, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL121, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL121, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL121, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL121, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL121, parameter='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL121, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL121, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_8140 = [
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'actInterGnbCa', 'value': 'DLOnly'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

LIST_TO_ADD_GNB1_L008_8140 = [
    dict(value=[dict(ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')],
         dist_name=_NRBTSname + '/NRDU-1',
         parameter='xgUplane')
]

MO_TO_ONLINE_ADD_GNB1_L008_8140 = [
    dict(value=_xnap_gnb3, dist_name=_XNLINK113, parameter='cPlaneIpAddr'),
    dict(value='oamControlled', dist_name=_XNLINK113, parameter='cPlaneIpAddrCtrl'),
    dict(value='13', dist_name=_XNLINK113, parameter='xnLinkId'),
    dict(value=_xnap_gnb4, dist_name=_XNLINK114, parameter='cPlaneIpAddr'),
    dict(value='oamControlled', dist_name=_XNLINK114, parameter='cPlaneIpAddrCtrl'),
    dict(value='14', dist_name=_XNLINK114, parameter='xnLinkId'),
    dict(value=_xnap_gnb3, dist_name=_XPIFREMOTE12, parameter='ipAddress'),
    dict(value='GNB', dist_name=_XPIFREMOTE12, parameter='remoteNeType'),
    dict(value='2', dist_name=_XPIFREMOTE12, parameter='xpIfRemoteId'),
    dict(value=_xnap_gnb4, dist_name=_XPIFREMOTE13, parameter='ipAddress'),
    dict(value='GNB', dist_name=_XPIFREMOTE13, parameter='remoteNeType'),
    dict(value='3', dist_name=_XPIFREMOTE13, parameter='xpIfRemoteId'),
    dict(value='Unlocked', dist_name=_NRADJGNB113, parameter='administrativeState'),
    dict(value='22', dist_name=_NRADJGNB113, parameter='gNbIdLength'),
    dict(value=_gnb3_id, dist_name=_NRADJGNB113, parameter='gNodeBId'),
    dict(value='oamControlled', dist_name=_NRADJGNB113, parameter='gNodeBIdCtrl'),
    dict(value='13', dist_name=_NRADJGNB113, parameter='nrAdjGnbId'),
    dict(value='1', dist_name=_NRADJGNB113, parameter='weightForIgnbCaSelection'),
    dict(value='13', dist_name=_NRADJGNB113, parameter='xnLinkRef'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJGNB113, parameter='gnbPlmn'),
    dict(value='Unlocked', dist_name=_NRADJGNB114, parameter='administrativeState'),
    dict(value='22', dist_name=_NRADJGNB114, parameter='gNbIdLength'),
    dict(value=_gnb4_id, dist_name=_NRADJGNB114, parameter='gNodeBId'),
    dict(value='oamControlled', dist_name=_NRADJGNB114, parameter='gNodeBIdCtrl'),
    dict(value='14', dist_name=_NRADJGNB114, parameter='nrAdjGnbId'),
    dict(value='1', dist_name=_NRADJGNB114, parameter='weightForIgnbCaSelection'),
    dict(value='14', dist_name=_NRADJGNB114, parameter='xnLinkRef'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJGNB114, parameter='gnbPlmn'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL1331, parameter='cellDepType'),
    dict(value='notReserved', dist_name=_NRADJNRCELL1331, parameter='cellReservedForOperatorUse'),
    dict(value='20200', dist_name=_NRADJNRCELL1331, parameter='fiveGsTac'),
    dict(value='41', dist_name=_NRADJNRCELL1331, parameter='freqBandIndicatorNR'),
    dict(value=_gnb3_id, dist_name=_NRADJNRCELL1331, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL1331, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL1331, parameter='gnbPlmn'),
    dict(value='31', dist_name=_NRADJNRCELL1331, parameter='lcrId'),
    dict(value='331', dist_name=_NRADJNRCELL1331, parameter='nrAdjNrCellId'),
    dict(value='509214', dist_name=_NRADJNRCELL1331, parameter='nrarfcn'),
    dict(value='635', dist_name=_NRADJNRCELL1331, parameter='physCellId'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL1311, parameter='cellDepType'),
    dict(value='notReserved', dist_name=_NRADJNRCELL1311, parameter='cellReservedForOperatorUse'),
    dict(value='20200', dist_name=_NRADJNRCELL1311, parameter='fiveGsTac'),
    dict(value='66', dist_name=_NRADJNRCELL1311, parameter='freqBandIndicatorNR'),
    dict(value=_gnb3_id, dist_name=_NRADJNRCELL1311, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL1311, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL1311, parameter='gnbPlmn'),
    dict(value='11', dist_name=_NRADJNRCELL1311, parameter='lcrId'),
    dict(value='311', dist_name=_NRADJNRCELL1311, parameter='nrAdjNrCellId'),
    dict(value='436000', dist_name=_NRADJNRCELL1311, parameter='nrarfcn'),
    dict(value='634', dist_name=_NRADJNRCELL1311, parameter='physCellId'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL133, parameter='cellDepType'),
    dict(value='notReserved', dist_name=_NRADJNRCELL133, parameter='cellReservedForOperatorUse'),
    dict(value='20200', dist_name=_NRADJNRCELL133, parameter='fiveGsTac'),
    dict(value='41', dist_name=_NRADJNRCELL133, parameter='freqBandIndicatorNR'),
    dict(value=_gnb3_id, dist_name=_NRADJNRCELL133, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL133, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL133, parameter='gnbPlmn'),
    dict(value='3', dist_name=_NRADJNRCELL133, parameter='lcrId'),
    dict(value='33', dist_name=_NRADJNRCELL133, parameter='nrAdjNrCellId'),
    dict(value='510000', dist_name=_NRADJNRCELL133, parameter='nrarfcn'),
    dict(value='633', dist_name=_NRADJNRCELL133, parameter='physCellId'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL141, parameter='cellDepType'),
    dict(value='notReserved', dist_name=_NRADJNRCELL141, parameter='cellReservedForOperatorUse'),
    dict(value='20200', dist_name=_NRADJNRCELL141, parameter='fiveGsTac'),
    dict(value='66', dist_name=_NRADJNRCELL141, parameter='freqBandIndicatorNR'),
    dict(value=_gnb4_id, dist_name=_NRADJNRCELL141, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL141, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL141, parameter='gnbPlmn'),
    dict(value='1', dist_name=_NRADJNRCELL141, parameter='lcrId'),
    dict(value='41', dist_name=_NRADJNRCELL141, parameter='nrAdjNrCellId'),
    dict(value='425000', dist_name=_NRADJNRCELL141, parameter='nrarfcn'),
    dict(value='641', dist_name=_NRADJNRCELL141, parameter='physCellId'),
    dict(value='0dB', dist_name=_NRREL111, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL111, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL111, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, parameter='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL111, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL111, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL111, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL111, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL111, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL121, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL121, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL121, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL121, parameter='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL121, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL121, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL121, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL121, parameter='removeNotAllowed'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL121, parameter='gnbPlmn')
]

MO_TO_ONLINE_ADD_GNB1_L008_8140_SBTS23R3_ENB_0000 = [
    dict(value=_xnap_gnb3, dist_name=_XNLINK113, parameter='cPlaneIpAddr'),
    dict(value='oamControlled', dist_name=_XNLINK113, parameter='cPlaneIpAddrCtrl'),
    dict(value='13', dist_name=_XNLINK113, parameter='xnLinkId'),
    dict(value=_xnap_gnb4, dist_name=_XNLINK114, parameter='cPlaneIpAddr'),
    dict(value='oamControlled', dist_name=_XNLINK114, parameter='cPlaneIpAddrCtrl'),
    dict(value='14', dist_name=_XNLINK114, parameter='xnLinkId'),
    dict(value=_xnap_gnb3, dist_name=_XPIFREMOTE12, parameter='ipAddress'),
    dict(value='GNB', dist_name=_XPIFREMOTE12, parameter='remoteNeType'),
    dict(value='2', dist_name=_XPIFREMOTE12, parameter='xpIfRemoteId'),
    dict(value=_xnap_gnb4, dist_name=_XPIFREMOTE13, parameter='ipAddress'),
    dict(value='GNB', dist_name=_XPIFREMOTE13, parameter='remoteNeType'),
    dict(value='3', dist_name=_XPIFREMOTE13, parameter='xpIfRemoteId'),
    dict(value='Unlocked', dist_name=_NRADJGNB113, parameter='administrativeState'),
    dict(value='22', dist_name=_NRADJGNB113, parameter='gNbIdLength'),
    dict(value=_gnb3_id, dist_name=_NRADJGNB113, parameter='gNodeBId'),
    dict(value='oamControlled', dist_name=_NRADJGNB113, parameter='gNodeBIdCtrl'),
    dict(value='13', dist_name=_NRADJGNB113, parameter='nrAdjGnbId'),
    dict(value='1', dist_name=_NRADJGNB113, parameter='weightForIgnbCaSelection'),
    dict(value='13', dist_name=_NRADJGNB113, parameter='xnLinkRef'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJGNB113, parameter='gnbPlmn'),
    dict(value='Unlocked', dist_name=_NRADJGNB114, parameter='administrativeState'),
    dict(value='22', dist_name=_NRADJGNB114, parameter='gNbIdLength'),
    dict(value=_gnb4_id, dist_name=_NRADJGNB114, parameter='gNodeBId'),
    dict(value='oamControlled', dist_name=_NRADJGNB114, parameter='gNodeBIdCtrl'),
    dict(value='14', dist_name=_NRADJGNB114, parameter='nrAdjGnbId'),
    dict(value='1', dist_name=_NRADJGNB114, parameter='weightForIgnbCaSelection'),
    dict(value='14', dist_name=_NRADJGNB114, parameter='xnLinkRef'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJGNB114, parameter='gnbPlmn'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL1331, parameter='cellDepType'),
    dict(value='20200', dist_name=_NRADJNRCELL1331, parameter='fiveGsTac'),
    dict(value='41', dist_name=_NRADJNRCELL1331, parameter='freqBandIndicatorNR'),
    dict(value=_gnb3_id, dist_name=_NRADJNRCELL1331, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL1331, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL1331, parameter='gnbPlmn'),
    dict(value='31', dist_name=_NRADJNRCELL1331, parameter='lcrId'),
    dict(value='331', dist_name=_NRADJNRCELL1331, parameter='nrAdjNrCellId'),
    dict(value='509214', dist_name=_NRADJNRCELL1331, parameter='nrarfcn'),
    dict(value='635', dist_name=_NRADJNRCELL1331, parameter='physCellId'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL1311, parameter='cellDepType'),
    dict(value='20200', dist_name=_NRADJNRCELL1311, parameter='fiveGsTac'),
    dict(value='66', dist_name=_NRADJNRCELL1311, parameter='freqBandIndicatorNR'),
    dict(value=_gnb3_id, dist_name=_NRADJNRCELL1311, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL1311, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL1311, parameter='gnbPlmn'),
    dict(value='11', dist_name=_NRADJNRCELL1311, parameter='lcrId'),
    dict(value='311', dist_name=_NRADJNRCELL1311, parameter='nrAdjNrCellId'),
    dict(value='436000', dist_name=_NRADJNRCELL1311, parameter='nrarfcn'),
    dict(value='634', dist_name=_NRADJNRCELL1311, parameter='physCellId'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL133, parameter='cellDepType'),
    dict(value='20200', dist_name=_NRADJNRCELL133, parameter='fiveGsTac'),
    dict(value='41', dist_name=_NRADJNRCELL133, parameter='freqBandIndicatorNR'),
    dict(value=_gnb3_id, dist_name=_NRADJNRCELL133, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL133, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL133, parameter='gnbPlmn'),
    dict(value='3', dist_name=_NRADJNRCELL133, parameter='lcrId'),
    dict(value='33', dist_name=_NRADJNRCELL133, parameter='nrAdjNrCellId'),
    dict(value='510000', dist_name=_NRADJNRCELL133, parameter='nrarfcn'),
    dict(value='633', dist_name=_NRADJNRCELL133, parameter='physCellId'),
    dict(value='SA+NSA', dist_name=_NRADJNRCELL141, parameter='cellDepType'),
    dict(value='20200', dist_name=_NRADJNRCELL141, parameter='fiveGsTac'),
    dict(value='66', dist_name=_NRADJNRCELL141, parameter='freqBandIndicatorNR'),
    dict(value=_gnb4_id, dist_name=_NRADJNRCELL141, parameter='gNbId'),
    dict(value='22', dist_name=_NRADJNRCELL141, parameter='gNbIdLength'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJNRCELL141, parameter='gnbPlmn'),
    dict(value='1', dist_name=_NRADJNRCELL141, parameter='lcrId'),
    dict(value='41', dist_name=_NRADJNRCELL141, parameter='nrAdjNrCellId'),
    dict(value='425000', dist_name=_NRADJNRCELL141, parameter='nrarfcn'),
    dict(value='641', dist_name=_NRADJNRCELL141, parameter='physCellId'),
    dict(value='0dB', dist_name=_NRREL111, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL111, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL111, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, parameter='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL111, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL111, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL111, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL111, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL111, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL121, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL121, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL121, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL121, parameter='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL121, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL121, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL121, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL121, parameter='removeNotAllowed'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL121, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_L008_8140 = [
    {'dist_name': _NRBTSname3 + '/NRDU-1', 'parameter': 'actInterGnbCa', 'value': 'DLOnly'}
]

LIST_TO_ADD_GNB3_L008_8140 = [
    dict(value=[dict(ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')],
         dist_name=_NRBTSname3 + '/NRDU-1',
         parameter='xgUplane')
]

MO_TO_ONLINE_ADD_GNB3_L008_8140 = [
    dict(value=_xnap_gnb1, dist_name=_XNLINK311, parameter='cPlaneIpAddr'),
    dict(value='oamControlled', dist_name=_XNLINK311, parameter='cPlaneIpAddrCtrl'),
    dict(value='11', dist_name=_XNLINK311, parameter='xnLinkId'),
    dict(value=_xnap_gnb1, dist_name=_XPIFREMOTE31, parameter='ipAddress'),
    dict(value='GNB', dist_name=_XPIFREMOTE31, parameter='remoteNeType'),
    dict(value='1', dist_name=_XPIFREMOTE31, parameter='xpIfRemoteId'),
    dict(value='Unlocked', dist_name=_NRADJGNB311, parameter='administrativeState'),
    dict(value='24', dist_name=_NRADJGNB311, parameter='gNbIdLength'),
    dict(value=_gnb_id, dist_name=_NRADJGNB311, parameter='gNodeBId'),
    dict(value='oamControlled', dist_name=_NRADJGNB311, parameter='gNodeBIdCtrl'),
    dict(value='11', dist_name=_NRADJGNB311, parameter='nrAdjGnbId'),
    dict(value='1', dist_name=_NRADJGNB311, parameter='weightForIgnbCaSelection'),
    dict(value='11', dist_name=_NRADJGNB311, parameter='xnLinkRef'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJGNB311, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L008_8140 = [
    {'dist_name': _NRBTSname4 + '/NRDU-1', 'parameter': 'actInterGnbCa', 'value': 'DLOnly'}
]

LIST_TO_ADD_GNB4_L008_8140 = [
    dict(value=[dict(ipV4AddressDN1=_MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')],
         dist_name=_NRBTSname4 + '/NRDU-1',
         parameter='xgUplane')
]

MO_TO_ONLINE_ADD_GNB4_L008_8140 = [
    dict(value=_xnap_gnb1, dist_name=_XNLINK411, parameter='cPlaneIpAddr'),
    dict(value='oamControlled', dist_name=_XNLINK411, parameter='cPlaneIpAddrCtrl'),
    dict(value='11', dist_name=_XNLINK411, parameter='xnLinkId'),
    dict(value=_xnap_gnb1, dist_name=_XPIFREMOTE41, parameter='ipAddress'),
    dict(value='GNB', dist_name=_XPIFREMOTE41, parameter='remoteNeType'),
    dict(value='1', dist_name=_XPIFREMOTE41, parameter='xpIfRemoteId'),
    dict(value='Unlocked', dist_name=_NRADJGNB411, parameter='administrativeState'),
    dict(value='24', dist_name=_NRADJGNB411, parameter='gNbIdLength'),
    dict(value=_gnb_id, dist_name=_NRADJGNB411, parameter='gNodeBId'),
    dict(value='oamControlled', dist_name=_NRADJGNB411, parameter='gNodeBIdCtrl'),
    dict(value='11', dist_name=_NRADJGNB411, parameter='nrAdjGnbId'),
    dict(value='1', dist_name=_NRADJGNB411, parameter='weightForIgnbCaSelection'),
    dict(value='11', dist_name=_NRADJGNB411, parameter='xnLinkRef'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRADJGNB411, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_1 = [
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_2 = [
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_3 = [
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'actInterGnbCa', 'value': 'DLOnly'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L006_4 = [
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'actInterGnbCa', 'value': 'disabled'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L006_1 = [
    {'dist_name': _NRCELL41, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008 = [
    dict(value='blind', dist_name=_NRREL121, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL121, parameter='sCellOperationalMode')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_1 = [
    {'dist_name': _NRREL111, 'parameter': 'lcrId', 'value': '31'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L008_2 = [
    {'dist_name': _NRREL111, 'parameter': 'gNbId', 'value': _gnb4_id},
    {'dist_name': _NRREL111, 'parameter': 'lcrId', 'value': '1'}
]

PARAMETERS_TO_MODIFY_GNB1_L011 = [
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL111, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),

    dict(value='Unlocked', dist_name=_SNSSAI_12, p_name='administrativeState'),
    dict(value='11259375', dist_name=_SNSSAI_12, p_name='sd'),
    dict(value='2', dist_name=_SNSSAI_12, p_name='snssaiId'),
    dict(value='1', dist_name=_SNSSAI_12, p_name='sst'),
]

PARAMETERS_TO_MODIFY_GNB4_L011 = [
    dict(value='Unlocked', dist_name=_SNSSAI_42, p_name='administrativeState'),
    dict(value='11259375', dist_name=_SNSSAI_42, p_name='sd'),
    dict(value='2', dist_name=_SNSSAI_42, p_name='snssaiId'),
    dict(value='1', dist_name=_SNSSAI_42, p_name='sst'),
]

PARAMETERS_TO_MODIFY_GNB1_L012 = [
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL111, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL111, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL112, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL112, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL112, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL112, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL112, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL112, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL112, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),
    dict(value='100', dist_name=_NRBTSname, p_name='weightForIgnbCaSelection'),
    dict(value='100', dist_name=_NRBTSname + '/NRADJGNB-14', p_name='weightForIgnbCaSelection')
]

PARAMETERS_TO_MODIFY_GNB1_UPD010 = [
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL111, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL111, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),
    dict(value='0dB', dist_name=_NRREL112, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL112, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL112, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL112, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL112, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL112, p_name='removeNotAllowed'),
    dict(value='true', dist_name=_NRBTSname, p_name='actConflictConfiguration'),
    dict(value='gnbControlled', dist_name=_NRBTSname + '/NRADJGNB-13', p_name='gNodeBIdCtrl')
]

PARAMETERS_TO_MODIFY_GNB3_UPD010 = [
    dict(value='oamControlled', dist_name=_NRBTSname3 + '/NRADJGNB-11', p_name='gNodeBIdCtrl')
]

LIST_TO_ADD_GNB1_L006 = [
    dict(
        dist_name=_NRREL111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL121,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL12,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='66',
            a1ThresholdSCellAddSsbRsrpTDD='66',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

LIST_TO_ADD_GNB2_L006 = [
    dict(
        dist_name=_NRREL211,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_ADD_GNB4_L006 = [
    dict(
        dist_name=_NRREL411,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL412,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL41,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='85',
            a1ThresholdSCellAddSsbRsrpTDD='85',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

LIST_TO_MODIFY_GNB1_L011 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB1_L011 = [
    dict(
        dist_name=_NRREL111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRBTSname + '/SNSSAI-2',
        list_name='nrPlmnDNList',
        elements=(_NRPLMN_11, _NRPLMN_12)
    )
]

LIST_TO_ADD_GNB1_UPD010 = [
    dict(
        dist_name=_NRREL111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL112,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_ADD_GNB4_L011 = [
    dict(
        dist_name=_NRBTSname4 + '/SNSSAI-2',
        list_name='nrPlmnDNList',
        elements=(_NRPLMN_41, _NRPLMN_42)
    )
]

LIST_TO_ADD_GNB1_L012 = [
    dict(
        dist_name=_NRREL111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL112,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_DELETE_GNB1_L011 = [
    dict(dist_name=_NRBTSname + '/SNSSAI-2', list_name='nrPlmnDNList')
]

LIST_TO_DELETE_GNB4_L011 = [
    dict(dist_name=_NRBTSname4 + '/SNSSAI-2', list_name='nrPlmnDNList')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L011 = [
    {'dist_name': _NRBTSname4 + '/SNSSAI-1', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L011_1 = [
    {'dist_name': _NRBTSname4 + '/SNSSAI-1', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012 = [
    {'dist_name': _NRBTSname, 'parameter': 'weightForIgnbCaSelection', 'value': '50'},
    {'dist_name': _NRBTSname + '/NRADJGNB-14', 'parameter': 'weightForIgnbCaSelection', 'value': '100'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012_1 = [
    {'dist_name': _NRBTSname, 'parameter': 'weightForIgnbCaSelection', 'value': '50'},
    {'dist_name': _NRBTSname + '/NRADJGNB-14', 'parameter': 'weightForIgnbCaSelection', 'value': '25'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L012_2 = [
    {'dist_name': _NRREL111, 'parameter': 'sCellAdditionMethod', 'value': 'covBasedA1'},
    {'dist_name': _NRREL112, 'parameter': 'sCellAdditionMethod', 'value': 'covBasedA1'},
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRBTSname, 'parameter': 'weightForIgnbCaSelection', 'value': '50'},
    {'dist_name': _NRBTSname + '/NRADJGNB-14', 'parameter': 'weightForIgnbCaSelection', 'value': '100'}
]

PARAMETERS_TO_ONLINE_ADD_GNB1_L012 = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '90',
                'a1ThresholdSCellAddSsbRsrpTDD': '90', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L012_2 = [
    {'dist_name': _NRCELL41, 'parameter': 'a2MeasSCellRelEnabled', 'value': 'rsrp'}
]

PARAMETERS_TO_ONLINE_ADD_GNB4_L012 = [
    {'dist_name': _NRCELL41, 'parameter': 'a2MeasSCellRelSsbRsrp',
     'value': [{'a2HysteresisSCellRelSsbRsrp': '0', 'a2ThresholdSCellRelSsbRsrp': '66',
                'a2TimeToTriggerSCellRelSsbRsrp': '2560ms'}]}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_L013 = [
    {'dist_name': _NRBTSname, 'parameter': 'weightForIgnbCaSelection', 'value': '100'},
    {'dist_name': _NRBTSname + '/NRADJGNB-14', 'parameter': 'weightForIgnbCaSelection', 'value': '100'},
    {'dist_name': _NRCELL12, 'parameter': 'weightForSCellSelection', 'value': '50'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L013 = [
    {'dist_name': _NRCELL41, 'parameter': 'weightForSCellSelection', 'value': '100'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_L013_1 = [
    {'dist_name': _NRCELL41, 'parameter': 'weightForSCellSelection', 'value': '10'}
]

Modify_Para_Online_UPD10_lock = [
    {'dist_name': _NRBTSname3 + '/NRADJGNB-11', 'parameter': 'administrativeState', 'value': 'Locked'}
]

Modify_Para_Online_UPD10_Unlock = [
    {'dist_name': _NRBTSname3 + '/NRADJGNB-11', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

Add_Para_Online_UPD10 = [
    dict(value='blind', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, parameter='sCellOperationalMode')
]

Modify_Para_Online_UPD10_Gnb1_lock = [
    dict(value='Locked', dist_name=_NRCELL111, parameter='administrativeState')
]

Modify_Para_Online_UPD10_Gnb1_Unlock = [
    dict(value='Unlocked', dist_name=_NRCELL111, parameter='administrativeState')
]

Modify_Para_Online_UPD10_Gnb3_lock = [
    dict(value='Locked', dist_name=_NRCELL31, parameter='administrativeState')
]

Modify_Para_Online_UPD10_Gnb3_Unlock = [
    dict(value='Unlocked', dist_name=_NRCELL31, parameter='administrativeState')
]
