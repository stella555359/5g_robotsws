from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang qingqing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qingqing.zhang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname_1 = 'NRBTS-'+_gnb_id

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_NRTAC = _NRBTSname2+'/TRACKINGAREA-0'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PARAMETERS_TO_administrativeState = [
    {'dist_name': '_MRBTSname/_NRBTSname/SNSSAI-1', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_PlmnHO = [
    {'dist_name': '_MRBTSname/_NRBTSname/NRCELL-1', 'parameter': 'pduHoSliceRelease', 'value': 'true'},
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_PlmnHO_target = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-2', 'parameter': 'pduHoSliceRelease', 'value': 'true'},
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname2+'/NRCELL-2', parameter='emergencyCallRestrictions')
]

PARAMETERS_TO_UPDATE_pduHoSliceRelease_false = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-1', 'parameter': 'pduHoSliceRelease', 'value': 'false'}
]

PARAMETERS_TO_UPDATE_pduHoSliceRelease_true = [
    {'dist_name': '_MRBTSname2/_NRBTSname2/NRCELL-1', 'parameter': 'pduHoSliceRelease', 'value': 'true'}
]

PARAMETERS_TO_UPDATE_slice255 = [
    dict(dist_name=_NRTAC, parameter='snssaiDNList', value=_NRBTSname2 + '/SNSSAI-2')
]

PARAMETERS_TO_UPDATE_A07 = [
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-1', parameter='emergencyCallRestrictions'),
    dict(value=[dict(emergencyCallPlmnHoAllowed='true', emergencyCallMrListIgnore='true')],
         dist_name=_NRBTSname+'/NRCELL-2', parameter='emergencyCallRestrictions'),
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRPLMNSET_SA-1',
     'parameter': 'trackingAreaDN', 'value': _NRBTSname+'/TRACKINGAREA-20000'}
]

PARAMETERS_TO_UPDATE_slice_SNSSAI1 = [
    dict(value=[_NRBTSname2 + '/SNSSAI-1'], dist_name=_NRTAC, parameter='snssaiDNList')
]

PARAMETERS_TO_UPDATE_slice_SNSSAI3 = [
    dict(value=[_NRBTSname2 + '/SNSSAI-1', _NRBTSname2 + '/SNSSAI-2', _NRBTSname2 + '/SNSSAI-3'],
         dist_name=_NRTAC, parameter='snssaiDNList')
]

counter_id_slice128 = [
    'M55149C02001', 'M55149C02002'
]
