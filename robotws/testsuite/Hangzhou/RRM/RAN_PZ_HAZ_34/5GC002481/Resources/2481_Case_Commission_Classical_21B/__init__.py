from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Jack Zeng'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jack.zeng@nokia-sbell.com'

_gnb_id0 = str(tl.gnbs[0].instance_id)
_gnb_id = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

LNADJGNB_2_TO_Delete = 'MRBTS-'+_gnb_id+'/NRBTS-'+_gnb_id+'/+NRADJGNB-1'
XNLINKGNB_2_TO_Delete = 'MRBTS-'+_gnb_id+'/NRBTS-'+_gnb_id+'/+XNLINK-1'
LNADJGNB_1_TO_Delete = 'MRBTS-'+_gnb_id0+'/NRBTS-'+_gnb_id0+'/+NRADJGNB-1'
XNLINKGNB_1_TO_Delete = 'MRBTS-'+_gnb_id0+'/NRBTS-'+_gnb_id0+'/+XNLINK-1'

PARAMS_TO_MODIFY_786_A011 = [
    dict(
        value=[dict(nea0='4', nea1_128='3', nea2_128='0', nea3_128='0')],
        dist_name='NRBTS-${tl.gnbs[0].instance_id}',
        parameter='cipherPrefL')
]

PARAMS_TO_MODIFY_786_A012 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1', p_name='actCDrx'),
    dict(value='rsrp', dist_name='NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1', p_name='a2MeasRedirectEnabled'),
]

PARAMS_TO_MODIFY_786_A027 = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1', p_name='actVoNR'),
]

PARAMS_TO_MODIFY_786_A027_2 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[0].instance_id}/NRCELL-1', p_name='actVoNR'),
]

PARAMS_TO_MODIFY_786_D07 = [
    dict(new_value='1945', dist_name='MRBTS-3442/NRBTS-3442/NRCELL-2',
         filter_param='Global synchronization channel number', abbr='gscn'),
    dict(new_value='155600', dist_name='MRBTS-3442/NRBTS-3442/NRCELL-2/NRCELL_FDD-1',
         filter_param='NR Absolute radio frequency channel number in downlink', abbr='nrarfcnDl'),
    dict(new_value='none', dist_name='MRBTS-3442/NRBTS-3442/NRCELL-1/NRHOIF-1',
         filter_param='a3 Measurement Configuration Enabled', abbr='a3MeasEnabled'),
    dict(new_value='rsrp', dist_name='MRBTS-3442/NRBTS-3442/NRCELL-1/NRHOIF-1',
         filter_param='a5 Measurement Configuration Enabled', abbr='a5MeasEnabled'),
    dict(new_value='rsrp', dist_name='MRBTS-3442/NRBTS-3442/NRCELL-1/NRHOIF-1',
         filter_param='a5 Measurement Configuration Enabled', abbr='a5MeasEnabled'),
    dict(new_value='155570', dist_name='MRBTS-3442/NRBTS-3442/NRCELL-1/NRHOIF-1',
         filter_param='SSB Frequency', abbr='ssbFrequency'),
]

LNADJGNB_1_OBJ_TO_DELETE = [dict(dist_name=LNADJGNB_1_TO_Delete), dict(dist_name=XNLINKGNB_1_TO_Delete)]
LNADJGNB_2_OBJ_TO_DELETE = [dict(dist_name=LNADJGNB_2_TO_Delete), dict(dist_name=XNLINKGNB_2_TO_Delete)]
