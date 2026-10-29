from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname_1 = _MRBTSname+'/NRBTS-1'
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'
_NRDRB4name = _NRBTSname+'/NRDRB-4'
_NRDRB5name = _NRBTSname+'/NRDRB-5'
_NRCELLname_1 = _NRBTSname_1+'/NRCELL-1'
_NRREDRTname_1 = _NRCELLname_1+'/NRREDRT-0'
_NRDRB4name_1 = _NRBTSname_1+'/NRDRB-4'
_NRDRB5name_1 = _NRBTSname_1+'/NRDRB-5'
PATH_TO_SCF = ''

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_AMF1GNB2 = _NRBTSname2+'/SERVEDAMF-1'
_NRBTS2_ID = 'NRBTS-'+_gnb2_id

Lock_gnb2_AMF1 = [
    dict(value='Locked', dist_name=_AMF1GNB2, parameter='administrativeState'),
]

Unlock_gnb2_AMF1 = [
    dict(value='Unlocked', dist_name=_AMF1GNB2, parameter='administrativeState'),
]

counter_id_C01 = [
    'M55112C04001', 'M55112C04002', 'M55112C03501', 'M55112C03502'
]

counter_dic_path_C01 = [
    'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC', 'BTS/CELLS/NRCELL-1/NX2CC'
]

counter_dic_path_C01_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC'
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
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC',
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC'
]

counter_dic_path_C012_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-1/NX2CC'
]

counter_dic_path_C012 = [
    'BTS/CELLS/NRCELL-1/NX2CC'
]

PARAM_574_A_000 = [
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate inter MeNB mobility', abbr='actInterMeNBMobility')
]

PARAM_574_A_000_1 = [
    dict(new_value='false', dist_name=_NRBTSname_1,
         filter_param='Activate inter MeNB mobility', abbr='actInterMeNBMobility')
]

PARAM_574_A_001 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate inter MeNB mobility', abbr='actInterMeNBMobility')
]

PARAM_574_A_001_1 = [
    dict(new_value='true', dist_name=_NRBTSname_1,
         filter_param='Activate inter MeNB mobility', abbr='actInterMeNBMobility')
]

PARAM_574_A_007 = [
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate inter MeNB mobility', abbr='actInterMeNBMobility'),
    dict(new_value='10', dist_name=_NRDRB4name,
         filter_param='DL Data split gain threshold', abbr='dlDataSplitGainThreshold'),
    dict(new_value='dlOverF1UX2U', dist_name=_NRDRB4name,
         filter_param='DL Data Split Mode', abbr='dlDataSplitMode'),
    dict(new_value='ulOverLteNr_PrimaryPathOverNr', dist_name=_NRDRB4name,
         filter_param='UL data path', abbr='ulDataPath'),
    dict(new_value='b200', dist_name=_NRDRB4name,
         filter_param='UL data split threshold', abbr='ulDataSplitThreshold'),
    dict(new_value='10', dist_name=_NRDRB5name,
         filter_param='DL Data split gain threshold', abbr='dlDataSplitGainThreshold'),
    dict(new_value='dlOverF1UX2U', dist_name=_NRDRB5name,
         filter_param='DL Data Split Mode', abbr='dlDataSplitMode'),
    dict(new_value='ulOverLteNr_PrimaryPathOverNr', dist_name=_NRDRB5name,
         filter_param='UL data path', abbr='ulDataPath'),
    dict(new_value='b200', dist_name=_NRDRB5name,
         filter_param='UL data split threshold', abbr='ulDataSplitThreshold')
]

PARAM_574_A_007_1 = [
    dict(new_value='true', dist_name=_NRBTSname_1,
         filter_param='Activate inter MeNB mobility', abbr='actInterMeNBMobility'),
    dict(new_value='10', dist_name=_NRDRB4name_1,
         filter_param='DL Data split gain threshold', abbr='dlDataSplitGainThreshold'),
    dict(new_value='dlOverF1UX2U', dist_name=_NRDRB4name_1,
         filter_param='DL Data Split Mode', abbr='dlDataSplitMode'),
    dict(new_value='ulOverLteNr_PrimaryPathOverNr', dist_name=_NRDRB4name_1,
         filter_param='UL data path', abbr='ulDataPath'),
    dict(new_value='b200', dist_name=_NRDRB4name_1,
         filter_param='UL data split threshold', abbr='ulDataSplitThreshold'),
    dict(new_value='10', dist_name=_NRDRB5name_1,
         filter_param='DL Data split gain threshold', abbr='dlDataSplitGainThreshold'),
    dict(new_value='dlOverF1UX2U', dist_name=_NRDRB5name_1,
         filter_param='DL Data Split Mode', abbr='dlDataSplitMode'),
    dict(new_value='ulOverLteNr_PrimaryPathOverNr', dist_name=_NRDRB5name_1,
         filter_param='UL data path', abbr='ulDataPath'),
    dict(new_value='b200', dist_name=_NRDRB5name_1,
         filter_param='UL data split threshold', abbr='ulDataSplitThreshold')
]

AMOUNT_OF_CELLS = 1
