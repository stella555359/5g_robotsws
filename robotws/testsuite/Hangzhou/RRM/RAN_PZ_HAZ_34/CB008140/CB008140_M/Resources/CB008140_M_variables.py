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

_NRREL11 = _NRCELL11+'/NRREL-1'
_NRREL12 = _NRCELL12+'/NRREL-1'
_NRREL122 = _NRCELL12+'/NRREL-2'
_NRREL112 = _NRCELL11+'/NRREL-2'
_NRREL113 = _NRCELL11+'/NRREL-3'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL221 = _NRBTSname2+'/NRCELL-21'
_NRCELL211 = _NRBTSname2+'/NRCELL-11'
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

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL421 = _NRBTSname4+'/NRCELL-21'

PARAMETERS_TO_ONLINE_MODIFY_GNB1_DSS = [
    dict(value='Locked', dist_name=_NRCELL111, parameter='administrativeState'),
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value='DSS_Phase_3', dist_name=_NRCELL12, parameter='lteNrDssMode'),
    dict(value='15', dist_name=_NRCELL12, parameter='type0SearchSpaceConfigurationIndex'),
    dict(value='true', dist_name=_NRCELL12+'/NRDSSLTE-1', parameter='actLteNrDssFastAlloc'),
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='100', minNrDssRatio='5')],
         dist_name=_NRCELL12+'/NRDSSLTE-1', parameter='lteNrDssDlRatio'),
    dict(value=[dict(bwpDN=_NRBTSname + '/BWP_PROFILE-131', cellBwpId='0'),
                dict(bwpDN=_NRBTSname + '/BWP_PROFILE-222', cellBwpId='1')],
         dist_name=_NRCELL12, parameter='cellBwpList'),
    dict(value=_NRBTSname + '/NRSYSINFO_PROFILE-22', dist_name=_NRCELL12, parameter='nrSysInfoProfileDN')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_DSS = [
    dict(value='Locked', dist_name=_NRCELL421, parameter='administrativeState'),
    dict(value='DSS_Phase_3', dist_name=_NRCELL41, parameter='lteNrDssMode'),
    dict(value='15', dist_name=_NRCELL41, parameter='type0SearchSpaceConfigurationIndex'),
    dict(value='true', dist_name=_NRCELL41+'/NRDSSLTE-1', parameter='actLteNrDssFastAlloc'),
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='100', minNrDssRatio='5')],
         dist_name=_NRCELL41+'/NRDSSLTE-1', parameter='lteNrDssDlRatio'),
    dict(value=[dict(bwpDN=_NRBTSname4 + '/BWP_PROFILE-139', cellBwpId='0'),
                dict(bwpDN=_NRBTSname4 + '/BWP_PROFILE-152', cellBwpId='1')],
         dist_name=_NRCELL41, parameter='cellBwpList'),
    dict(value=_NRBTSname4 + '/NRSYSINFO_PROFILE-2', dist_name=_NRCELL12, parameter='nrSysInfoProfileDN')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_DSS = [
    dict(value='Locked', dist_name=_NRCELL21, parameter='administrativeState'),
    dict(value='425000', dist_name=_NRCELL211 + '/NRCELL_FDD-1', parameter='nrarfcnDl'),
    dict(value='345000', dist_name=_NRCELL211 + '/NRCELL_FDD-1', parameter='nrarfcnUl'),
    dict(value='DSS_Phase_3', dist_name=_NRCELL211, parameter='lteNrDssMode'),
    dict(value='15', dist_name=_NRCELL211, parameter='type0SearchSpaceConfigurationIndex'),
    dict(value='true', dist_name=_NRCELL211+'/NRDSSLTE-1', parameter='actLteNrDssFastAlloc'),
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='100', minNrDssRatio='5')],
         dist_name=_NRCELL211+'/NRDSSLTE-1', parameter='lteNrDssDlRatio'),
    dict(value=[dict(bwpDN=_NRBTSname2 + '/BWP_PROFILE-139', cellBwpId='0'),
                dict(bwpDN=_NRBTSname2 + '/BWP_PROFILE-152', cellBwpId='1')],
         dist_name=_NRCELL211, parameter='cellBwpList'),
    dict(value=_NRBTSname2 + '/NRSYSINFO_PROFILE-2', dist_name=_NRCELL211, parameter='nrSysInfoProfileDN')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1 = [
    dict(value='425000', dist_name=_NRBTSname + '/NRADJNRCELL-211', parameter='nrarfcn'),
]

PARAMETERS_TO_ADD_MO_GNB1_MB005_2gnb = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL122, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL122, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, parameter='handoverAllowedSA'),
    dict(value='31', dist_name=_NRREL122, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL122, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL122, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL122, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL122, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL122, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL122, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL122, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL122, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_MO_GNB1_MB005 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL122, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL122, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, parameter='handoverAllowedSA'),
    dict(value='31', dist_name=_NRREL122, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL122, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL122, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL122, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL122, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL122, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL122, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL122, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL122, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_MO_GNB1_MB010 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_DELETE_GNB1_MB005 = [
    {'dist_name': _NRREL12},
    {'dist_name': _NRREL122}
]

PARAMETERS_TO_DELETE_GNB1_MB010 = [
    {'dist_name': _NRREL12}
]

PARAMETERS_TO_ADD_MO_GNB1_MA001 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_MA001 = [
    dict(value='notBarred', dist_name=_NRCELL11, parameter='cellBarred')
]
