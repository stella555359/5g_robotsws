from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELL_1 = _NRBTSname+'/NRCELL-1'
_NRCELL_2 = _NRBTSname+'/NRCELL-2'
_NRCELL_FDD_1 = _NRCELL_1+'/NRCELL_FDD-1'
_NRHOIF_1 = _NRCELL_2+'/NRHOIF-1'
_NRREL_0 = _NRCELL_2+'/NRREL-0'

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
    dict(new_value='1949', dist_name=_NRCELL_1,
         filter_param='Global synchronization channel number', abbr='gscn'),
    dict(new_value='156100', dist_name=_NRCELL_FDD_1,
         filter_param='NR Absolute radio frequency channel number in downlink', abbr='nrarfcnDl'),
    dict(new_value='none', dist_name=_NRHOIF_1,
         filter_param='a3 Measurement Configuration Enabled', abbr='a3MeasEnabled'),
    dict(new_value='rsrp', dist_name=_NRHOIF_1,
         filter_param='a5 Measurement Configuration Enabled', abbr='a5MeasEnabled'),
    dict(new_value='156010', dist_name=_NRHOIF_1,
         filter_param='SSB Frequency', abbr='ssbFrequency'),
    dict(new_value='156100', dist_name=_NRREL_0,
         filter_param='NR Absolute radio frequency channel number of related neighbor cell', abbr='nrarfcn'),
]

PARAMS_TO_MODIFY_786_D03 = [
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate inter-frequency handover for the Standalone mode', abbr='actInterFreqHoSA'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate intra-frequency handover for the Standalone mode', abbr='actIntraFreqHoSA'),
]
