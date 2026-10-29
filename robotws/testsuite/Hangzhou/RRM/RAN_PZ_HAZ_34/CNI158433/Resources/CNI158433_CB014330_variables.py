from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming & Zhang Yayun'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-' + _global_id
_MRBTSname2 = 'MRBTS-' + _gnb_id2
_MRBTSname_enb = 'MRBTS-' + _global_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb_id2
_LNBTSname = _MRBTSname_enb + '/LNBTS-' + _enb_id
_LTECELLname = _LNBTSname + '/LNCEL-4'
_LTECELL48040name = _LNBTSname + '/LNCEL-48040'
_LTECELL48041name = _LNBTSname + '/LNCEL-48041'
_LTECELL48042name = _LNBTSname + '/LNCEL-48042'
_LTECELL48043name = _LNBTSname + '/LNCEL-48043'
_LTECELL48044name = _LNBTSname + '/LNCEL-48044'
_LTECELL48045name = _LNBTSname + '/LNCEL-48045'
_LTECELL48046name = _LNBTSname + '/LNCEL-48046'
_LTECELL48047name = _LNBTSname + '/LNCEL-48047'
_LTECELL48048name = _LNBTSname + '/LNCEL-48048'
_LTECELL48049name = _LNBTSname + '/LNCEL-48049'
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRCELL3name = _NRBTSname + '/NRCELL-3'
_NRCELL4name = _NRBTSname + '/NRCELL-4'
_NRCELL21name = _NRBTSname + '/NRCELL-21'
_NRCELL400name = _NRBTSname + '/NRCELL-400'
_NRCELL410name = _NRBTSname + '/NRCELL-410'
_NRCELL544name = _NRBTSname + '/NRCELL-544'
_NRCELL545name = _NRBTSname + '/NRCELL-545'
_NRCELL644name = _NRBTSname + '/NRCELL-644'
_NRCELL645name = _NRBTSname + '/NRCELL-645'
_NRCELL700name = _NRBTSname + '/NRCELL-700'
_NRCELL701name = _NRBTSname + '/NRCELL-701'

NRCELL700name = _NRBTSname + '/NRCELL-700'

cells_CNI158433_CB014330 = [NRCELL700name]
cells_CNI158433_CB014330_status = ['enabled']

PARAMETERS_CNI158433_CB014330_PA_INITIAL_VALUE = [10, 10, 10, 10]

TRAFFIC_DL_PORT_01 = str(int(tl.ues[0].iperf_details.port) + 100)
TRAFFIC_DL_PORT_02 = str(int(tl.ues[0].iperf_details.port) + 200)
TRAFFIC_UL_PORT_01 = str(int(tl.ues[0].iperf_details.ssh_connection_details.port) + 100)
TRAFFIC_UL_PORT_02 = str(int(tl.ues[0].iperf_details.ssh_connection_details.port) + 200)

CNI158433_CB014330_ue_index = [0, 1]
CNI158433_CB014330_expected_tput_dl = '1'
CNI158433_CB014330_Send_Tput_DL_01 = '1000M'
CNI158433_CB014330_Send_Tput_DL_02 = '1000M'
CNI158433_CB014330_expected_tput_ul = '1'
CNI158433_CB014330_Send_Tput_UL_01 = '300M'
CNI158433_CB014330_Send_Tput_UL_02 = '300M'

PARAM_CNI158433_CB014330_gnb1_idle = [
    dict(value='10', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
]

PARAM_CNI158433_CB014330_gnb1_pagingDciAggregation = [
    dict(value='pagingDciAggregation', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
    dict(value='Locked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
]

PARAM_CNI158433_CB014330_gnb1_MCS0_SF2 = [
    dict(value='MCS0_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS1_SF2 = [
    dict(value='MCS1_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS2_SF2 = [
    dict(value='MCS2_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS0_SF1 = [
    dict(value='MCS0_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS3_SF2 = [
    dict(value='MCS3_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS4_SF2 = [
    dict(value='MCS4_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS1_SF1 = [
    dict(value='MCS1_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS5_SF2 = [
    dict(value='MCS5_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS2_SF1 = [
    dict(value='MCS2_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS6_SF2 = [
    dict(value='MCS6_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS0_SF0 = [
    dict(value='MCS0_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS3_SF1 = [
    dict(value='MCS3_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS7_SF2 = [
    dict(value='MCS7_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS8_SF2 = [
    dict(value='MCS8_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS4_SF1 = [
    dict(value='MCS4_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS1_SF0 = [
    dict(value='MCS1_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS9_SF2 = [
    dict(value='MCS9_SF2', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS5_SF1 = [
    dict(value='MCS5_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS2_SF0 = [
    dict(value='MCS2_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS6_SF1 = [
    dict(value='MCS6_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS3_SF0 = [
    dict(value='MCS3_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS7_SF1 = [
    dict(value='MCS7_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS8_SF1 = [
    dict(value='MCS8_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS4_SF0 = [
    dict(value='MCS4_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS9_SF1 = [
    dict(value='MCS9_SF1', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS5_SF0 = [
    dict(value='MCS5_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS6_SF0 = [
    dict(value='MCS6_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS7_SF0 = [
    dict(value='MCS7_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS8_SF0 = [
    dict(value='MCS8_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_MCS9_SF0 = [
    dict(value='MCS9_SF0', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
]

PARAM_CNI158433_CB014330_gnb1_RECOVER_pagingDciAggregation = [
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='pagingDciAggregation', dist_name=_NRCELL700name, parameter='pagingTargetRate'),
    dict(value='Unlocked', dist_name=_NRCELL701name, parameter='administrativeState'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
]
