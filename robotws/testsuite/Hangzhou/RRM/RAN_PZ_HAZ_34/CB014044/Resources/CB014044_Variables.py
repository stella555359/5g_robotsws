from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-' + _global_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id
_NRCELLname = _NRBTSname + '/NRCELL-1'
_NRCELL2name = _NRBTSname + '/NRCELL-2'
_NRCELL3name = _NRBTSname + '/NRCELL-3'
_NRCELL4name = _NRBTSname + '/NRCELL-4'
_NRCELL250name = _NRBTSname + '/NRCELL-250'
_NRCELL251name = _NRBTSname + '/NRCELL-251'
_NRCELL660name = _NRBTSname + '/NRCELL-660'
_NRCELL661name = _NRBTSname + '/NRCELL-661'
_NRCELL710name = _NRBTSname + '/NRCELL-710'
_NRCELL711name = _NRBTSname + '/NRCELL-711'
_NRCELL36501name = _NRBTSname + '/NRCELL-36501'
_NRCELL36502name = _NRBTSname + '/NRCELL-36502'
_NRPLMNSET_NSA250name_1 = _NRCELL250name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA251name_1 = _NRCELL251name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA660name_1 = _NRCELL660name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA661name_1 = _NRCELL661name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA710name_1 = _NRCELL710name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA711name_1 = _NRCELL711name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA36501name_1 = _NRCELL36501name + '/NRPLMNSET_NSA-1'
_NRPLMNSET_NSA36502name_1 = _NRCELL36502name + '/NRPLMNSET_NSA-1'
_NRBTSDUname = _NRBTSname + '/NRDU-9999'
_NRBTSDU1name = _NRBTSname + '/NRDU-1'
_NRDRBname_11 = _NRBTSname + '/NRDRB-11'
_NRDRBname_12 = _NRBTSname + '/NRDRB-12'
_NRDRBname_13 = _NRBTSname + '/NRDRB-13'
_NRDRBname_14 = _NRBTSname + '/NRDRB-14'
_NRPMRNL_1 = _NRBTSname + '/NRPMRNL-1'
_NRRESOURCEGROUP_PROFILE_1 = _NRBTSname + '/NRRESOURCEGROUP_PROFILE-1'
_NRULMUMIMO_0 = _NRCELLname + '/NRULMUMIMO-0'
_NRULMUMIMO_36501_0 = _NRCELL36501name + '/NRULMUMIMO-0'
_NRULMUMIMO_36502_0 = _NRCELL36502name + '/NRULMUMIMO-0'
_NRULMUMIMO_0_2 = _NRCELL2name + '/NRULMUMIMO-0'
_NRULMUMIMO_0_3 = _NRCELL3name + '/NRULMUMIMO-0'
_NRULMUMIMO_0_4 = _NRCELL4name + '/NRULMUMIMO-0'

NRCELL_1 = _NRBTSname + '/NRCELL-1'
NRCELL_2 = _NRBTSname + '/NRCELL-2'
NRCELL_3 = _NRBTSname + '/NRCELL-3'
NRCELL_4 = _NRBTSname + '/NRCELL-4'
NRCELL_36501 = _NRBTSname + '/NRCELL-36501'
NRCELL_36502 = _NRBTSname + '/NRCELL-36502'

cells_K_B001 = [NRCELL_36501, NRCELL_36502]
cells_K_B002 = [NRCELL_3, NRCELL_4]
cells_KU_B002 = [NRCELL_3, NRCELL_4]

cells_states_disabled = ['disabled', 'disabled']
cells_states_enabled = ['enabled', 'enabled']
cells_states_enabled_disabled = ['enabled', 'disabled']

usecols_name = ['DistName', 'EntryName', 'TimeStamp', 'Value']

# set_wts_configuration_file_command = 'cfg_sim file=wts_config_CB014044_case003AVHA.lua'
# set_wts_configuration_file_command = 'cfg_sim file=basic.cfg'
set_wts_configuration_file_command = 'cfg_sim file=basic.lua'
set_wts_configuration_file_command_D_B011 = 'cfg_sim file=wts-slice_config_CB014044_case003AVHA.lua'
set_x2_link_up_command = 'enb_x2_link_up enb=1 target=2'
ba_b1_001_atttach_commands = [f'ue_register id={i}' for i in range(1, 9)]
ue_id = [i for i in range(1, 9)]
qos_flow = [j for j in range(1, 5) for k in range(2)]
ba_b1_001_pdu_commands_1_8 = [f'set_pdu_param ue={i} pdu=1 default_qos_flow={j} trf_type=internal' for i, j in
                              zip(ue_id, qos_flow)]
ba_b1_001_slice_commands_1_8 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(1, 9)]
ba_b1_001_traffic_commands_1_8 = [f'trf_data_start ue={i} pdu=1 qfi=1 trf_id=1 dir=dl mbps=175' for i in range(1, 9)]
ba_b1_001_stop_traffic_commands_1_8 = [f'trf_data_stop ue={i} pdu=1 qfi=1' for i in range(1, 9)]
ba_b1_001_release_pdu_commands_1_8 = [f'ue_pdu_session_release ue={i} pdu=1' for i in range(1, 9)]
ba_b1_001_detach_commands = [f'ue_deregister id={i} ue_deregister_type=switch_off by=ue' for i in range(1, 9)]

# 60 UE
ue_change_cell = [f'ue_change_location id={i} enb=2 cell=1' for i in range(1, 61)]

ue_id_60 = [i for i in range(1, 61)]
pdu_id_60 = [j for j in range(1, 61) for p in range(10)]

at_commands = [f'ue_register id={i}' for i in range(1, 61)]
pdu_commands_1_20_K_B002 = [f'set_pdu_param ue={i} pdu=1 default_qos_flow=1 trf_type=internal' for i in range(1, 21)]
pdu_commands_21_40_K_B002 = [f'set_pdu_param ue={i} pdu=1 default_qos_flow=2 trf_type=internal' for i in range(21, 41)]
pdu_commands_41_60_K_B002 = [f'set_pdu_param ue={i} pdu=1 default_qos_flow=3 trf_type=internal' for i in range(41, 61)]
pdu_commands_K_B002 = [pdu_commands_1_20_K_B002, pdu_commands_21_40_K_B002, pdu_commands_41_60_K_B002]
slice_commands_1_60 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(1, 61)]
slice_commands_1_10 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(1, 11)]
slice_commands_10_20 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(11, 21)]
slice_commands_20_30 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(21, 31)]
slice_commands_30_40 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(31, 41)]
slice_commands_40_50 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(41, 51)]
slice_commands_50_60 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(51, 61)]
slice_commands_K_B002 = [slice_commands_1_10, slice_commands_10_20, slice_commands_20_30, slice_commands_30_40,
                         slice_commands_40_50, slice_commands_50_60]

traffic_commands_ul_1_5 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul trf_id=1 protocol=udp  mbps=20' for i in
                           range(1, 6)]
traffic_commands_ul_6_10 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul trf_id=1 protocol=udp  mbps=10' for i in
                            range(6, 11)]
traffic_commands_ul_11_20 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul trf_id=1 protocol=udp  mbps=1' for i in
                             range(11, 21)]
traffic_commands_ul_21_30 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul period_ms=1000 burst=1 size=42' for i in
                             range(21, 31)]
traffic_commands_ul_31_40 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul period_ms=300 burst=10 size=1024' for i in
                             range(31, 41)]
traffic_commands_ul_41_50 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul period_ms=100 burst=20 size=1372' for i in
                             range(41, 51)]
traffic_commands_ul_51_60 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=ul period_ms=200 burst=30 size=1000' for i in
                             range(51, 61)]
traffic_commands_ul_K_B002 = [traffic_commands_ul_1_5, traffic_commands_ul_6_10, traffic_commands_ul_11_20,
                              traffic_commands_ul_21_30, traffic_commands_ul_31_40, traffic_commands_ul_41_50,
                              traffic_commands_ul_51_60]

traffic_commands_dl_1_60 = [f'trf_data_start ue={i} pdu=1 qfi=1 trf_id=1 protocol=udp dir=dl mbps=2' for i in
                            range(1, 61)]
traffic_commands_dl_K_B002 = [traffic_commands_dl_1_60]

pdu_commands_1_10 = [f'set_pdu_param ue={i} pdu=1 default_qos_flow=1 trf_type=internal' for i in range(1, 11)]
pdu_commands_11_20 = [f'set_pdu_param ue={i} pdu=2 default_qos_flow=1 trf_type=internal' for i in range(11, 21)]
pdu_commands_21_30 = [f'set_pdu_param ue={i} pdu=3 default_qos_flow=2 trf_type=internal' for i in range(21, 31)]
pdu_commands_31_40 = [f'set_pdu_param ue={i} pdu=4 default_qos_flow=2 trf_type=internal' for i in range(31, 41)]
pdu_commands_41_50 = [f'set_pdu_param ue={i} pdu=5 default_qos_flow=3 trf_type=internal' for i in range(41, 51)]
pdu_commands_51_60 = [f'set_pdu_param ue={i} pdu=6 default_qos_flow=3 trf_type=internal' for i in range(51, 61)]
pdu_commands_Bb_B004 = [pdu_commands_1_10, pdu_commands_11_20, pdu_commands_21_30, pdu_commands_31_40,
                        pdu_commands_41_50, pdu_commands_51_60]

pdu_commands_D_B011 = [pdu_commands_1_10, pdu_commands_11_20, pdu_commands_21_30, pdu_commands_31_40,
                       pdu_commands_41_50, pdu_commands_51_60]

slice_commands_60 = [f'ue_pdu_session_setup pdu={j} ue={i} nwslice=1' for i, j in zip(ue_id_60, pdu_id_60)]
slice_commands_1_10 = [f'ue_pdu_session_setup pdu=1 ue={i} nwslice=1' for i in range(1, 11)]
slice_commands_11_20 = [f'ue_pdu_session_setup pdu=2 ue={i} nwslice=1' for i in range(11, 21)]
slice_commands_21_30 = [f'ue_pdu_session_setup pdu=3 ue={i} nwslice=1' for i in range(21, 31)]
slice_2_commands_21_30 = [f'ue_pdu_session_setup pdu=3 ue={i} nwslice=2' for i in range(21, 31)]
slice_commands_31_40 = [f'ue_pdu_session_setup pdu=4 ue={i} nwslice=1' for i in range(31, 41)]
slice_commands_41_50 = [f'ue_pdu_session_setup pdu=5 ue={i} nwslice=1' for i in range(41, 51)]
slice_commands_51_60 = [f'ue_pdu_session_setup pdu=6 ue={i} nwslice=1' for i in range(51, 61)]

slice_commands_Bb_B004 = [slice_commands_1_10, slice_commands_11_20, slice_commands_21_30, slice_commands_31_40,
                          slice_commands_41_50, slice_commands_51_60]
slice_commands_D_B011 = [slice_commands_1_10, slice_commands_11_20, slice_2_commands_21_30, slice_commands_31_40,
                         slice_commands_41_50, slice_commands_51_60]

traffic_commands_1_10 = [f'trf_data_start ue={i} pdu=1 qfi=1 trf_id=1 dir=dl mbps=50' for i in range(1, 11)]
traffic_commands_11_20 = [f'trf_data_start ue={i} pdu=2 qfi=1 dir=dl period_ms=1000 burst=1 size=42' for i in
                          range(11, 21)]
traffic_commands_21_30 = [f'trf_data_start ue={i} pdu=3 qfi=1 dir=dl mbps=5' for i in range(21, 31)]
traffic_commands_31_40 = [f'trf_data_start ue={i} pdu=4 qfi=1 dir=dl period_ms=10 burst=20 size=1372' for i in
                          range(31, 41)]
traffic_commands_41_50 = [f'trf_data_start ue={i} pdu=5 qfi=1 dir=dl period_ms=1000 burst=1 size=42' for i in
                          range(41, 51)]
traffic_commands_51_60 = [f'trf_data_start ue={i} pdu=6 qfi=1 dir=dl period_ms=1000 burst=1 size=42' for i in
                          range(51, 61)]
traffic_commands_Bb_B004 = [traffic_commands_1_10, traffic_commands_11_20, traffic_commands_21_30,
                            traffic_commands_31_40, traffic_commands_41_50, traffic_commands_51_60]
traffic_commands_1_5_D_B011 = [f'trf_data_start ue={i} pdu=1 qfi=1 trf_id=1 dir=dl mbps=50' for i in range(1, 6)]
traffic_commands_6_8_D_B011 = [f'trf_data_start ue={i} pdu=1 qfi=1 trf_id=1 dir=dl mbps=5' for i in range(6, 9)]
traffic_commands_9_10_D_B011 = [f'trf_data_start ue={i} pdu=1 qfi=1 dir=dl period_ms=1000 burst=1 size=42' for i in
                                range(9, 11)]
traffic_commands_11_15_D_B011 = [f'trf_data_start ue={i} pdu=2 qfi=1 dir=dl period_ms=10 burst=20 size=1372' for i in
                                 range(11, 16)]
traffic_commands_16_20_D_B011 = [f'trf_data_start ue={i} pdu=2 qfi=1 dir=dl period_ms=20 burst=10 size=1000' for i in
                                 range(16, 21)]
traffic_commands_21_25_D_B011 = [f'trf_data_start ue={i} pdu=3 qfi=1 trf_id=1 dir=dl mbps=50' for i in range(21, 26)]
traffic_commands_26_28_D_B011 = [f'trf_data_start ue={i} pdu=3 qfi=1 trf_id=1 dir=dl mbps=5' for i in range(26, 29)]
traffic_commands_29_30_D_B011 = [f'trf_data_start ue={i} pdu=3 qfi=1 dir=dl period_ms=1000 burst=1 size=42' for i in
                                 range(29, 31)]
traffic_commands_31_35_D_B011 = [f'trf_data_start ue={i} pdu=4 qfi=1 dir=dl period_ms=10 burst=20 size=1372' for i in
                                 range(31, 36)]
traffic_commands_36_40_D_B011 = [f'trf_data_start ue={i} pdu=4 qfi=1 dir=dl period_ms=20 burst=10 size=1000' for i in
                                 range(36, 41)]
traffic_commands_41_45_D_B011 = [f'trf_data_start ue={i} pdu=5 qfi=1 trf_id=1 dir=dl mbps=50' for i in range(41, 46)]
traffic_commands_46_48_D_B011 = [f'trf_data_start ue={i} pdu=5 qfi=1 trf_id=1 dir=dl mbps=5' for i in range(46, 49)]
traffic_commands_49_50_D_B011 = [f'trf_data_start ue={i} pdu=5 qfi=1 dir=dl period_ms=1000 burst=1 size=42' for i in
                                 range(49, 51)]
traffic_commands_51_55_D_B011 = [f'trf_data_start ue={i} pdu=6 qfi=1 dir=dl period_ms=10 burst=20 size=1372' for i in
                                 range(51, 56)]
traffic_commands_56_60_D_B011 = [f'trf_data_start ue={i} pdu=6 qfi=1 dir=dl period_ms=20 burst=10 size=1000' for i in
                                 range(56, 61)]
traffic_commands_D_B011 = [traffic_commands_1_5_D_B011, traffic_commands_6_8_D_B011, traffic_commands_9_10_D_B011,
                           traffic_commands_11_15_D_B011, traffic_commands_16_20_D_B011, traffic_commands_21_25_D_B011,
                           traffic_commands_26_28_D_B011, traffic_commands_29_30_D_B011, traffic_commands_31_35_D_B011,
                           traffic_commands_36_40_D_B011, traffic_commands_41_45_D_B011, traffic_commands_46_48_D_B011,
                           traffic_commands_49_50_D_B011, traffic_commands_51_55_D_B011, traffic_commands_56_60_D_B011]

stop_traffic_commands_1_10 = [f'trf_data_stop ue={i} pdu=1 qfi=1' for i in range(1, 11)]
stop_traffic_commands_11_20 = [f'trf_data_stop ue={i} pdu=2 qfi=1' for i in range(11, 21)]
stop_traffic_commands_21_30 = [f'trf_data_stop ue={i} pdu=3 qfi=1' for i in range(21, 31)]
stop_traffic_commands_31_40 = [f'trf_data_stop ue={i} pdu=4 qfi=1' for i in range(31, 41)]
stop_traffic_commands_41_50 = [f'trf_data_stop ue={i} pdu=5 qfi=1' for i in range(41, 51)]
stop_traffic_commands_51_60 = [f'trf_data_stop ue={i} pdu=6 qfi=1' for i in range(51, 61)]

release_pdu_commands_1_10 = [f'ue_pdu_session_release ue={i} pdu=1' for i in range(1, 11)]
release_pdu_commands_11_20 = [f'ue_pdu_session_release ue={i} pdu=2' for i in range(11, 21)]
release_pdu_commands_21_30 = [f'ue_pdu_session_release ue={i} pdu=3' for i in range(21, 31)]
release_pdu_commands_31_40 = [f'ue_pdu_session_release ue={i} pdu=4' for i in range(31, 41)]
release_pdu_commands_41_50 = [f'ue_pdu_session_release ue={i} pdu=5' for i in range(41, 51)]
release_pdu_commands_51_60 = [f'ue_pdu_session_release ue={i} pdu=6' for i in range(51, 61)]
release_pdu_commands_Bb_B004 = [release_pdu_commands_1_10, release_pdu_commands_11_20, release_pdu_commands_21_30,
                                release_pdu_commands_31_40, release_pdu_commands_41_50, release_pdu_commands_51_60]

detach_commands = [f'ue_deregister id={i} ue_deregister_type=switch_off by=ue' for i in range(1, 61)]
# 60 UE


PARAM_14044_delete_gnb1_Ba_B1_001_01 = [
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_gnb1_Ba_B1_001_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='30', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='25', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
]

PARAM_14044_gnb1_Ba_B1_001_02 = [
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
]

PARAM_14044_recover_gnb1_Ba_B1_001_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='40', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_delete_gnb1_Bb_004_01 = [
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_gnb1_Bb_004_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_gnb1_Bb_004_02 = [
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
]

PARAM_14044_gnb1_Bb_004_03 = [
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
]

PARAM_14044_gnb1_Bb_004_04 = [
    dict(value='UL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
]

PARAM_14044_recover_gnb1_Bb_004_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='16', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cellsEnh', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_delete_gnb1_D_B009_01 = [
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_gnb1_D_B009_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='16', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_gnb1_D_B009_02 = [
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_D_B009_03 = [
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
]

PARAM_14044_recover_gnb1_D_B009_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='1', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
    dict(value='false', dist_name=_NRCELLname, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_delete_gnb1_D_B011_01 = [
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_gnb1_D_B011_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='16', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_gnb1_D_B011_02 = [
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='DL_UL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
]

PARAM_14044_gnb1_D_B011_03 = [
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
]

PARAM_14044_recover_gnb1_D_B011_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='16', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='40', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cellsEnh', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_gnb1_E_B1_001_01 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL2name, parameter='lteNrDssMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELLname, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL2name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL2name, parameter='dlDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELLname, parameter='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL2name, parameter='prachSequenceType'),
    dict(value='15', dist_name=_NRULMUMIMO_0, parameter='ulMuMimoCorrThd2'),
    dict(value='15', dist_name=_NRULMUMIMO_0_2, parameter='ulMuMimoCorrThd2'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='4', dist_name=_NRCELL2name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='true', dist_name=_NRCELLname, parameter='actPfMetricReinitSchedUes'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_E_B1_001_02 = [
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
]

PARAM_14044_gnb1_E_B1_001_03 = [
    dict(value='DL', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
]

PARAM_14044_gnb1_E_B1_001_04 = [
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
]

PARAM_14044_recover_delete_gnb1_E_B1_001_01 = [
    dict(dist_name=_NRULMUMIMO_0, parameter='ulMuMimoCorrThd2'),
    dict(dist_name=_NRULMUMIMO_0_2, parameter='ulMuMimoCorrThd2'),
]

PARAM_14044_recover_gnb1_E_B1_001_01 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='1', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdHighBufUePrio'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL2name, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELLname, parameter='actHighSpeedCell'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actHighSpeedCell'),
    dict(value='Two additional DMRS', dist_name=_NRCELLname, parameter='ulDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL2name, parameter='ulDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELLname, parameter='dlDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL2name, parameter='dlDMRSAdditionalPosition'),
    dict(value='RestrictedTypeB', dist_name=_NRCELLname, parameter='prachSequenceType'),
    dict(value='RestrictedTypeB', dist_name=_NRCELL2name, parameter='prachSequenceType'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='4', dist_name=_NRCELL2name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlSrsBm'),
    dict(value='false', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='false', dist_name=_NRCELLname, parameter='actPfMetricReinitSchedUes'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_delete_gnb1_G_B3_003_01 = [
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
]

PARAM_14044_gnb1_G_B3_003_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='16', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_recover_gnb1_G_B3_003_01 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileDN'),
    dict(value=_NRRESOURCEGROUP_PROFILE_1, dist_name=_NRCELLname, parameter='nrResourceGroupProfileUlDN'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='16', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='40', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='40', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cellsEnh', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
]

PARAM_14044_gnb1_K_B001_01 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL2name, parameter='lteNrDssMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELLname, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL2name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL2name, parameter='dlDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELLname, parameter='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL2name, parameter='prachSequenceType'),
    dict(value='15', dist_name=_NRULMUMIMO_0, parameter='ulMuMimoCorrThd2'),
    dict(value='15', dist_name=_NRULMUMIMO_0_2, parameter='ulMuMimoCorrThd2'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='true', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='4', dist_name=_NRCELL2name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='true', dist_name=_NRCELLname, parameter='actPfMetricReinitSchedUes'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_K_B001_02 = [
    dict(value='DL', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELL2name, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='DL', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='DL', dist_name=_NRCELL2name, parameter='actTdHighBufUePrio'),
    dict(value='DL', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='DL', dist_name=_NRCELL2name, parameter='actFdAlgoEnh'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlSchLowBufferOpt'),
]

PARAM_14044_gnb1_K_B001_03 = [
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actFdAlgoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlSchLowBufferOpt'),
]

PARAM_14044_recover_delete_gnb1_K_B001_01 = [
    dict(dist_name=_NRULMUMIMO_36501_0, parameter='ulMuMimoCorrThd2'),
    dict(dist_name=_NRULMUMIMO_36502_0, parameter='ulMuMimoCorrThd2'),
]

PARAM_14044_recover_gnb1_K_B001_01 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='1', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELLname, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdHighBufUePrio'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELLname, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL2name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELLname, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL2name, parameter='lteNrDssMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELLname, parameter='actHighSpeedCell'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actHighSpeedCell'),
    dict(value='Two additional DMRS', dist_name=_NRCELLname, parameter='ulDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL2name, parameter='ulDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELLname, parameter='dlDMRSAdditionalPosition'),
    dict(value='Two additional DMRS', dist_name=_NRCELL2name, parameter='dlDMRSAdditionalPosition'),
    dict(value='RestrictedTypeB', dist_name=_NRCELLname, parameter='prachSequenceType'),
    dict(value='RestrictedTypeB', dist_name=_NRCELL2name, parameter='prachSequenceType'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='20', dist_name=_NRCELLname, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELLname, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL2name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELLname, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELLname, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='4', dist_name=_NRCELL2name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDUname, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDUname, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlSrsBm'),
    dict(value='false', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='false', dist_name=_NRCELLname, parameter='actPfMetricReinitSchedUes'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_K_B002_01 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL4name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELL3name, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL4name, parameter='lteNrDssMode'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='dlDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL3name, parameter='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL4name, parameter='prachSequenceType'),
    dict(value='15', dist_name=_NRULMUMIMO_0_3, parameter='ulMuMimoCorrThd2'),
    dict(value='15', dist_name=_NRULMUMIMO_0_4, parameter='ulMuMimoCorrThd2'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='true', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='20', dist_name=_NRCELL3name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL3name, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELL3name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='4', dist_name=_NRCELL4name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput2'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrDlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqOne'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDU1name, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDU1name, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actPfMetricReinitSchedUes'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_K_B002_02 = [
    dict(value='DL', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='DL', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='DL', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='DL', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='DL', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='DL', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='DL', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
]

PARAM_14044_gnb1_K_B002_03 = [
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
]

PARAM_14044_recover_gnb1_K_B002_01 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='40', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='7', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='4', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL4name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELL3name, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL4name, parameter='lteNrDssMode'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='dlDMRSAdditionalPosition'),
    dict(value='Unrestricted', dist_name=_NRCELL3name, parameter='prachSequenceType'),
    dict(value='Unrestricted', dist_name=_NRCELL4name, parameter='prachSequenceType'),
    dict(value='5', dist_name=_NRULMUMIMO_0_3, parameter='ulMuMimoCorrThd2'),
    dict(value='5', dist_name=_NRULMUMIMO_0_4, parameter='ulMuMimoCorrThd2'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='20', dist_name=_NRCELL3name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL3name, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='16', dist_name=_NRCELL3name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='16', dist_name=_NRCELL4name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput2'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrDlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqOne'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDU1name, parameter='flexibleCAMode'),
    dict(value='max144cells', dist_name=_NRBTSDU1name, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actPfMetricReinitSchedUes'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_KU_B002_01 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='20', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='5', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='1', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL4name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELL3name, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL4name, parameter='lteNrDssMode'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='dlDMRSAdditionalPosition'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL3name, parameter='prachSequenceType'),
    dict(value='RestrictedTypeA', dist_name=_NRCELL4name, parameter='prachSequenceType'),
    dict(value='15', dist_name=_NRULMUMIMO_0_3, parameter='ulMuMimoCorrThd2'),
    dict(value='15', dist_name=_NRULMUMIMO_0_4, parameter='ulMuMimoCorrThd2'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='true', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='20', dist_name=_NRCELL3name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL3name, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='4', dist_name=_NRCELL3name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='4', dist_name=_NRCELL4name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput2'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrDlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqOne'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='false', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDU1name, parameter='flexibleCAMode'),
    dict(value='max72cells', dist_name=_NRBTSDU1name, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actPfMetricReinitSchedUes'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actPfMetricReinitSchedUes'),
]

PARAM_14044_gnb1_KU_B002_02 = [
    dict(value='DL_UL', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='DL_UL', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='DL_UL', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='DL_UL', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='DL_UL', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='DL_UL', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='DL_UL', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='DL_UL', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
]

PARAM_14044_gnb1_KU_B002_03 = [
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
]

PARAM_14044_recover_gnb1_KU_B002_01 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actHighSliceWeightFactor'),
    dict(value='40', dist_name=_NRDRBname_11, parameter='schedulWeight'),
    dict(value='10', dist_name=_NRDRBname_12, parameter='schedulWeight'),
    dict(value='7', dist_name=_NRDRBname_13, parameter='schedulWeight'),
    dict(value='4', dist_name=_NRDRBname_14, parameter='schedulWeight'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actRat1Alloc'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actDlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actUlSchLowBufferOpt'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actUlSchLowBufferOpt'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdHighBufUePrio'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdHighBufUePrio'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPooling'),
    dict(value='longPucch', dist_name=_NRCELL3name, parameter='pucchModeSelect'),
    dict(value='longPucch', dist_name=_NRCELL4name, parameter='pucchModeSelect'),
    dict(value='none', dist_name=_NRCELL3name, parameter='lteNrDssMode'),
    dict(value='none', dist_name=_NRCELL4name, parameter='lteNrDssMode'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlMuMimo'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actHighSpeedCell'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actHighSpeedCell'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='ulDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL3name, parameter='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=_NRCELL4name, parameter='dlDMRSAdditionalPosition'),
    dict(value='Unrestricted', dist_name=_NRCELL3name, parameter='prachSequenceType'),
    dict(value='Unrestricted', dist_name=_NRCELL4name, parameter='prachSequenceType'),
    dict(value='5', dist_name=_NRULMUMIMO_0_3, parameter='ulMuMimoCorrThd2'),
    dict(value='5', dist_name=_NRULMUMIMO_0_4, parameter='ulMuMimoCorrThd2'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareSchedulerUlAndEnh'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSliceAwareScheduler'),
    dict(value='false', dist_name=_NRBTSname, parameter='actPlmnAwareScheduler'),
    dict(value='20', dist_name=_NRCELL3name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='dlHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL3name, parameter='ulHighBufPrioUeRatio'),
    dict(value='20', dist_name=_NRCELL4name, parameter='ulHighBufPrioUeRatio'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actBestNList'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actFdAlgoEnh'),
    dict(value='disabled', dist_name=_NRCELL3name, parameter='actTdPfMetricOpt'),
    dict(value='disabled', dist_name=_NRCELL4name, parameter='actTdPfMetricOpt'),
    dict(value='16', dist_name=_NRCELL3name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='16', dist_name=_NRCELL4name, parameter='maxNumPdschAllocationPerSlot'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilization'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrCellUtilPerNrg'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacPduTput2'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrDlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrMacSduReport'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqLowSEMCS'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlHarqOne'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDynamicTargetShareCalcForRg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actSlowPrbPoolingFddFr1Enh'),
    dict(value='false', dist_name=_NRBTSname, parameter='actAutoPrachConfigIndexFddEnh'),
    dict(value='NumberCellAmount', dist_name=_NRBTSDU1name, parameter='flexibleCAMode'),
    dict(value='max144cells', dist_name=_NRBTSDU1name, parameter='crntiAllocationOption'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRCELL4name, parameter='actUlSrsBm'),
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='false', dist_name=_NRCELL3name, parameter='actPfMetricReinitSchedUes'),
    dict(value='false', dist_name=_NRCELL4name, parameter='actPfMetricReinitSchedUes'),
]

PARAMETERS_JSON_FILE_14044_gnb1_K_B001_01 = 'PARAMETERS_JSON_FILE_14044_gnb1_K_B001_01.json'
PARAMETERS_JSON_FILE_14044_gnb1_K_B001_02 = 'PARAMETERS_JSON_FILE_14044_gnb1_K_B001_02.json'
PARAMETERS_JSON_FILE_14044_gnb1_K_B001_03 = 'PARAMETERS_JSON_FILE_14044_gnb1_K_B001_03.json'
PARAMETERS_JSON_FILE_14044_recover_gnb1_K_B001_01 = 'PARAMETERS_JSON_FILE_14044_recover_gnb1_K_B001_01.json'

PARAMETERS_14044_gnb1_K_B001_01 = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actHighSliceWeightFactor",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareSchedulerUlAndEnh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPlmnAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actDynamicTargetShareCalcForRg",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPoolingFddFr1Enh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actAutoPrachConfigIndexFddEnh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actConnRrcPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actScheUePooling",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL36501name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeA"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            }
        ]
    },
    {
        "distName": _NRCELL36502name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "Locked"
            },
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeA"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            }
        ]
    },
    {
        "distName": _NRBTSDUname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "flexibleCAMode",
                "operation": "update",
                "value": "NumberCellAmount"
            },
            {
                "parameterName": "crntiAllocationOption",
                "operation": "update",
                "value": "max72cells"
            },
        ]
    },
    {
        "distName": _NRPMRNL_1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrDlHarq1024Tbl",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrDlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilization",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacSduReport",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilPerNrg",
                "operation": "update",
                "value": "5min"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_36501_0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_36502_0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRDRBname_11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "20"
            },
        ]
    },
    {
        "distName": _NRDRBname_12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "10"
            },
        ]
    },
    {
        "distName": _NRDRBname_13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRDRBname_14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
]

PARAMETERS_14044_gnb1_K_B001_02 = [
    {
        "distName": _NRCELL36501name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='DL', actBestNList='DL', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL36502name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='DL', actBestNList='DL', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
]

PARAMETERS_14044_gnb1_K_B001_03 = [
    {
        "distName": _NRCELL36501name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL36502name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
]

PARAMETERS_14044_recover_gnb1_K_B001_01 = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actHighSliceWeightFactor",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareSchedulerUlAndEnh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPlmnAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actDynamicTargetShareCalcForRg",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPoolingFddFr1Enh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actAutoPrachConfigIndexFddEnh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actConnRrcPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actScheUePooling",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL36501name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "Two additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "Two additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeB"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "7"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL36502name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "operation": "update",
                "value": "Unlocked"
            },
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "Two additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "Two additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeB"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "7"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRBTSDUname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "flexibleCAMode",
                "operation": "update",
                "value": "NumberCellAmount"
            },
            {
                "parameterName": "crntiAllocationOption",
                "operation": "update",
                "value": "max72cellsEnh"
            },
        ]
    },
    {
        "distName": _NRPMRNL_1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrCellUtilization",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilPerNrg",
                "operation": "update",
                "value": "5min"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_36501_0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "delete",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_36502_0,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "delete",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRDRBname_11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
    {
        "distName": _NRDRBname_12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
    {
        "distName": _NRDRBname_13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
    {
        "distName": _NRDRBname_14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
]

PARAMETERS_JSON_FILE_14044_gnb1_K_B002_01 = 'PARAMETERS_JSON_FILE_14044_gnb1_K_B002_01.json'
PARAMETERS_JSON_FILE_14044_gnb1_K_B002_02 = 'PARAMETERS_JSON_FILE_14044_gnb1_K_B002_02.json'
PARAMETERS_JSON_FILE_14044_gnb1_K_B002_03 = 'PARAMETERS_JSON_FILE_14044_gnb1_K_B002_03.json'
PARAMETERS_JSON_FILE_14044_recover_gnb1_K_B002_01 = 'PARAMETERS_JSON_FILE_14044_recover_gnb1_K_B002_01.json'

PARAMETERS_14044_gnb1_K_B002_01 = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actHighSliceWeightFactor",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareSchedulerUlAndEnh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPlmnAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actDynamicTargetShareCalcForRg",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPoolingFddFr1Enh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actAutoPrachConfigIndexFddEnh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actConnRrcPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actScheUePooling",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeA"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeA"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRBTSDU1name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "flexibleCAMode",
                "operation": "update",
                "value": "NumberCellAmount"
            },
            {
                "parameterName": "crntiAllocationOption",
                "operation": "update",
                "value": "max72cells"
            },
        ]
    },
    {
        "distName": _NRPMRNL_1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrCellUtilization",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilPerNrg",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput2",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrDlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacSduReport",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqOne",
                "operation": "update",
                "value": "5min"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_3,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRDRBname_11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "20"
            },
        ]
    },
    {
        "distName": _NRDRBname_12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "10"
            },
        ]
    },
    {
        "distName": _NRDRBname_13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRDRBname_14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
]

PARAMETERS_14044_gnb1_K_B002_02 = [
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='DL', actBestNList='DL', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "DL"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='DL', actBestNList='DL', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
]

PARAMETERS_14044_gnb1_K_B002_03 = [
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
]

PARAMETERS_14044_recover_gnb1_K_B002_01 = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actHighSliceWeightFactor",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareSchedulerUlAndEnh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPlmnAwareScheduler",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actDynamicTargetShareCalcForRg",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPoolingFddFr1Enh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actAutoPrachConfigIndexFddEnh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actConnRrcPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actScheUePooling",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "Unrestricted"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "16"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "Unrestricted"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "16"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRBTSDU1name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "flexibleCAMode",
                "operation": "update",
                "value": "NumberCellAmount"
            },
            {
                "parameterName": "crntiAllocationOption",
                "operation": "update",
                "value": "max144cells"
            },
        ]
    },
    {
        "distName": _NRPMRNL_1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrCellUtilization",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilPerNrg",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput2",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrDlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacSduReport",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqOne",
                "operation": "update",
                "value": "5min"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_3,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRDRBname_11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "40"
            },
        ]
    },
    {
        "distName": _NRDRBname_12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "10"
            },
        ]
    },
    {
        "distName": _NRDRBname_13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "7"
            },
        ]
    },
    {
        "distName": _NRDRBname_14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "4"
            },
        ]
    },
]

PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_01 = 'PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_01.json'
PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_02 = 'PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_02.json'
PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_03 = 'PARAMETERS_JSON_FILE_14044_gnb1_KU_B002_03.json'
PARAMETERS_JSON_FILE_14044_recover_gnb1_KU_B002_01 = 'PARAMETERS_JSON_FILE_14044_recover_gnb1_KU_B002_01.json'

PARAMETERS_14044_gnb1_KU_B002_01 = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actHighSliceWeightFactor",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareSchedulerUlAndEnh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPlmnAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actDynamicTargetShareCalcForRg",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPoolingFddFr1Enh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actAutoPrachConfigIndexFddEnh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actConnRrcPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actScheUePooling",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeA"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "RestrictedTypeA"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "4"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRBTSDU1name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "flexibleCAMode",
                "operation": "update",
                "value": "NumberCellAmount"
            },
            {
                "parameterName": "crntiAllocationOption",
                "operation": "update",
                "value": "max72cells"
            },
        ]
    },
    {
        "distName": _NRPMRNL_1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrCellUtilization",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilPerNrg",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput2",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrDlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacSduReport",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqOne",
                "operation": "update",
                "value": "5min"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_3,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "15"
            },
        ]
    },
    {
        "distName": _NRDRBname_11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "20"
            },
        ]
    },
    {
        "distName": _NRDRBname_12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "10"
            },
        ]
    },
    {
        "distName": _NRDRBname_13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRDRBname_14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "1"
            },
        ]
    },
]

PARAMETERS_14044_gnb1_KU_B002_02 = [
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "DL_UL"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "DL_UL"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "DL_UL"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='DL_UL', actBestNList='DL_UL', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "DL_UL"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "DL_UL"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "DL_UL"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='DL_UL', actBestNList='DL_UL', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
]

PARAMETERS_14044_gnb1_KU_B002_03 = [
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
]

PARAMETERS_14044_recover_gnb1_KU_B002_01 = [
    {
        "distName": _NRBTSname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actHighSliceWeightFactor",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareSchedulerUlAndEnh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSliceAwareScheduler",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actPlmnAwareScheduler",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actDynamicTargetShareCalcForRg",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actSlowPrbPoolingFddFr1Enh",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actAutoPrachConfigIndexFddEnh",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "actConnRrcPooling",
                "value": "true",
                "operation": "update"
            },
            {
                "parameterName": "actScheUePooling",
                "value": "true",
                "operation": "update"
            },
        ]
    },
    {
        "distName": _NRCELL3name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "Unrestricted"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "16"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRCELL4name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actRat1Alloc",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actDlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actUlSchLowBufferOpt",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "actTdHighBufUePrio",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "pucchModeSelect",
                "operation": "update",
                "value": "longPucch"
            },
            {
                "parameterName": "lteNrDssMode",
                "operation": "update",
                "value": "none"
            },
            {
                "parameterName": "actDlMuMimoEnh",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlMuMimo",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actHighSpeedCell",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "ulDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "dlDMRSAdditionalPosition",
                "operation": "update",
                "value": "One additional DMRS"
            },
            {
                "parameterName": "prachSequenceType",
                "operation": "update",
                "value": "Unrestricted"
            },
            {
                "parameterName": "dlHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "ulHighBufPrioUeRatio",
                "operation": "update",
                "value": "20"
            },
            {
                "parameterName": "actFdAlgoEnh",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "actTdPfMetricOpt",
                "operation": "update",
                "value": "disabled"
            },
            {
                "parameterName": "maxNumPdschAllocationPerSlot",
                "operation": "update",
                "value": "16"
            },
            {
                "parameterName": "actDlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actUlSrsBm",
                "operation": "update",
                "value": "true"
            },
            {
                "parameterName": "actPfMetricReinitSchedUes",
                "operation": "update",
                "value": "false"
            },
            {
                "parameterName": "bestNK",
                "operation": "update",
                "value": [
                    dict(actBestKList='disabled', actBestNList='disabled', dlBestKListRatio='20',
                         dlBestNListRatio='20', ulBestKListRatio='20', ulBestNListRatio='20')
                ]
            },
        ]
    },
    {
        "distName": _NRBTSDU1name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "flexibleCAMode",
                "operation": "update",
                "value": "NumberCellAmount"
            },
            {
                "parameterName": "crntiAllocationOption",
                "operation": "update",
                "value": "max144cells"
            },
        ]
    },
    {
        "distName": _NRPMRNL_1,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "miNrCellUtilization",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrCellUtilPerNrg",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacPduTput2",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrDlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrMacSduReport",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqLowSEMCS",
                "operation": "update",
                "value": "5min"
            },
            {
                "parameterName": "miNrUlHarqOne",
                "operation": "update",
                "value": "5min"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_3,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRULMUMIMO_0_4,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "ulMuMimoCorrThd2",
                "operation": "update",
                "value": "5"
            },
        ]
    },
    {
        "distName": _NRDRBname_11,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "40"
            },
        ]
    },
    {
        "distName": _NRDRBname_12,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "10"
            },
        ]
    },
    {
        "distName": _NRDRBname_13,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "7"
            },
        ]
    },
    {
        "distName": _NRDRBname_14,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "schedulWeight",
                "operation": "update",
                "value": "4"
            },
        ]
    },
]
