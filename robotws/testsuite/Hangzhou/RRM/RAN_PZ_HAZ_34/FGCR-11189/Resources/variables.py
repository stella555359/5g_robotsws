from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Liu Jia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb1_id = str(tl.gnbs[0].instance_id)
_MRBTS1_name = 'MRBTS-'+_gnb1_id
_NRBTS1_name = _MRBTS1_name+'/NRBTS-'+_gnb1_id
_NRCELL1_name = _NRBTS1_name+'/NRCELL-1'
_NRCELL2_name = _NRBTS1_name+'/NRCELL-2'
_NRBTS1_SERVEDAMF = _NRBTS1_name+'/SERVEDAMF-1'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTS2_name = 'MRBTS-'+_gnb2_id
_NRBTS2_name = _MRBTS2_name+'/NRBTS-'+_gnb2_id
_GNB2_AMF = _NRBTS2_name+'/SERVEDAMF-1'
_NRBTS2_ID = 'NRBTS-'+_gnb2_id
_NRBTS2_DRB_1 = _NRBTS2_name+'/NRDRB-1'
_NRBTS2_DRB_2 = _NRBTS2_name+'/NRDRB-2'
_NRBTS2_DRB_3 = _NRBTS2_name+'/NRDRB-3'
_NRBTS2_DRB_4 = _NRBTS2_name+'/NRDRB-4'

PATH_TO_SCF = ''

PARAM_B1_007 = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actCDrx'),
    dict(
        value=[dict(drxOnDurationTimer='80ms')],
        dist_name=_NRCELL2_name,
        parameter='drxProfile1'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actCDrx')
]

PARAM_B1_006 = [
    dict(
        value='false',
        dist_name=_NRCELL1_name,
        parameter='actCDrx'),
    dict(
        value='false',
        dist_name=_NRCELL2_name,
        parameter='actCDrx')
]

PARAM_B2_004 = [
    dict(
        value='true',
        dist_name=_NRCELL2_name,
        parameter='actCDrx'),
    dict(
        value=[dict(drxOnDurationTimer='10ms')],
        dist_name=_NRCELL2_name,
        parameter='drxProfile1'),
    dict(
        value='longPucch',
        dist_name=_NRCELL1_name,
        parameter='pucchModeSelect'),
    dict(
        value='true',
        dist_name=_NRCELL1_name,
        parameter='actCDrx')
]

LOCK_GNB1_CELL2 = [
    dict(
        value='Locked',
        dist_name=_NRCELL2_name,
        parameter='administrativeState')
]

UNLOCK_GNB1_CELL2 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL2_name,
        parameter='administrativeState')
]

LOCK_GNB1_CELL1 = [
    dict(
        value='Locked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState')
]

UNLOCK_GNB1_CELL1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELL1_name,
        parameter='administrativeState')
]

Barred_GNB1_CELL1 = [
    dict(
        value='barred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred')
]

Barred_GNB1_CELL2 = [
    dict(
        value='barred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred')
]

unBarred_GNB1_CELL1 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL1_name,
        parameter='cellBarred')
]

unBarred_GNB1_CELL2 = [
    dict(
        value='notBarred',
        dist_name=_NRCELL2_name,
        parameter='cellBarred')
]

LOCK_GNB1_AMF = [
    dict(
        value='Locked',
        dist_name=_NRBTS1_SERVEDAMF,
        parameter='administrativeState')
]

UNLOCK_GNB1_AMF = [
    dict(
        value='Unlocked',
        dist_name=_NRBTS1_SERVEDAMF,
        parameter='administrativeState')
]

LOCK_GNB2_AMF = [
    dict(value='Locked', dist_name=_GNB2_AMF, parameter='administrativeState'),
]

UNLOCK_GNB2_AMF = [
    dict(value='Unlocked', dist_name=_GNB2_AMF, parameter='administrativeState'),
]

MODIFY_LIST_EDA = [
    dict(dist_name=_NRBTS2_DRB_4, list_name='nsaDrbParam',
         elements=[dict(p_name='ulDataSplitThreshold', value='b102400', index=0)]),
]

counter_id_C01 = [
    'M55112C04001', 'M55112C04002', 'M55112C03501', 'M55112C03502'
]

counter_dic_path_C01 = [
    'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC'
]

counter_dic_path_C01_trunk = [
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC'
]
counter_id_C011 = [
    'M55112C03001', 'M55112C00002'
]

counter_id_C012 = [
    'M55112C04002'
]

counter_dic_path_C011_trunk = [
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC'
]

counter_dic_path_C012_trunk = [
    'BTS/' + _NRBTS2_name + '/NRCELL-1/NX2CC',
]

counter_dic_path_C011 = [
    'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC'
]

counter_dic_path_C012 = [
    'BTS/CELLS/NRCELL-1/NX2CC'
]
