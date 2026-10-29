from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'YAYUN.ZHANG'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yayun.zhang@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2_name = _NRBTSname+'/NRCELL-2'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'
_NRDRB4name = _NRBTSname+'/NRDRB-4'
_NRDRB5name = _NRBTSname+'/NRDRB-5'
PATH_TO_SCF = ''
_AMF2GNB1 = _NRBTSname+'/SERVEDAMF-2'

Lock_gnb1_AMF2 = [
    dict(value='Locked', dist_name=_AMF2GNB1, parameter='administrativeState'),
    dict(value='barred', dist_name=_NRCELL2_name, parameter='cellBarred'),
]

Unlock_gnb1_AMF2 = [
    dict(value='Unlocked', dist_name=_AMF2GNB1, parameter='administrativeState'),
    dict(value='notBarred', dist_name=_NRCELL2_name, parameter='cellBarred'),
]

counter_id_C01 = [
    'M55112C04001', 'M55112C04002', 'M55112C03501', 'M55112C03502'
]

counter_dic_path_C01 = [
    'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC'
]

counter_dic_path_C01_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC'
]

counter_id_C011 = [
    'M55112C03001', 'M55112C00002'
]

counter_id_C012 = [
    'M55112C04002'
]

counter_dic_path_C011 = [
    'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC'
]

counter_dic_path_C011_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC'
]

counter_dic_path_C012_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NX2CC'
]

counter_dic_path_C012 = [
    'BTS/CELLS/NRCELL-1/NX2CC'
]

AMOUNT_OF_CELLS = 1
