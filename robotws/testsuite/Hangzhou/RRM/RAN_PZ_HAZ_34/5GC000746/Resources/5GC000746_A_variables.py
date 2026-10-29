import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)

PARAM_746_ENABLE_CMAS = [
    dict(
         abbr='actCMAS',
         dist_name=_NRBTSname,
         filter_param='Activate CMAS broadcasting',
         new_value='true')
]

PARAM_746_DISABLE_CMAS = [
    dict(
         abbr='actCMAS',
         dist_name=_NRBTSname,
         filter_param='Activate CMAS broadcasting',
         new_value='false')
]

PARAM_746_CMAS_PREPARE = [
    dict(
        value_name='nr_of_bits_g_node_b_id',
        dist_name=_NRBTSname,
        filter_param='gNB id length',
        p_name='gNbIdLength')
]

SCF_746_001 = [
    dict(
         value='false',
         dist_name=_NRBTSname,
         p_name='actCMAS')
]

COUNTERS_746 = [
    dict(
         counter_id='M55119C02001',
         full_path='BTS/' + _NRBTS_ID + '/NNGCB/NNGCB_WRWR_REQ_RECD'
         ),
    dict(
         counter_id='M55119C02002',
         full_path='BTS/' + _NRBTS_ID + '/NNGCB/NNGCB_WRWR_RESP_SENT'
         ),
    dict(
         counter_id='M55119C02003',
         full_path='BTS/' + _NRBTS_ID + '/NNGCB/NNGCB_PWS_FAIL_IND_SENT'
         ),
    dict(
         counter_id='M55119C02004',
         full_path='BTS/' + _NRBTS_ID + '/NNGCB/NNGCB_PWS_CAN_REQ_RECD'
         ),
    dict(
         counter_id='M55119C02005',
         full_path='BTS/' + _NRBTS_ID + '/NNGCB/NNGCB_PWS_CAN_RESP_SENT'
         )
]

PARAM_746_SIBPERIODICITY_1 = [
    dict(
         p_name='sibPeriodicity',
         dist_name=_NRBTSname + '/NRSYSINFO_PROFILE-1',
         filter_param='SIB periodicity'),
    dict(
         p_name='sibPeriodicity',
         dist_name=_NRBTSname + '/NRSYSINFO_PROFILE-2',
         filter_param='SIB periodicity')
]

PARAM_746_SIBPERIODICITY_cell1 = [
    dict(
         abbr='sibPeriodicity',
         dist_name=_NRBTSname + '/NRSYSINFO_PROFILE-1',
         filter_param='SIB periodicity',
         new_value='rf64')
]

PARAM_746_SIBPERIODICITY_cell2 = [
    dict(
         abbr='sibPeriodicity',
         dist_name=_NRBTSname + '/NRSYSINFO_PROFILE-2',
         filter_param='SIB periodicity',
         new_value='rf64')
]

PARAM_746_EMERGENCY_AREA_ID_LIST_1 = [
    dict(
         abbr=None,
         dist_name=_NRBTSname + '/NRCELL-1',
         filter_param='Emergency area ID list',
         new_value=1)
]

PARAM_746_EMERGENCY_AREA_ID_LIST_2 = [
    dict(
         abbr=None,
         dist_name=_NRBTSname + '/NRCELL-1',
         filter_param='Emergency area ID list',
         new_value=2)
]

PARAM_746_NRCELLIDENTITY = [
    dict(
         p_name='nrCellIdentity',
         dist_name=_NRBTSname + '/NRCELL-1',
         filter_param='NR Cell Identity'),
    dict(
         p_name='nrCellIdentity',
         dist_name=_NRBTSname + '/NRCELL-2',
         filter_param='NR Cell Identity')
]

PARAM_1936_HA_543 = [
    dict(
        abbr='nea0',
        dist_name=_NRBTSname,
        filter_param='Null ciphering algorithm',
        new_value='3'),
    dict(
        abbr='nea2_128',
        dist_name=_NRBTSname,
        filter_param='AES-based algorithm',
        new_value='0')
]
