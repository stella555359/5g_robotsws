*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com
*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}           scf_basic_call.xml
${CB006649_SCF_TC01_Before}         CB006649_Scf_gNB_Before_activation.xml
${CB006649_SCF_TC01_After}          CB006649_Scf_gNB_After.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_basic_call.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_auto.cfg
${CB006649_CFG_AP_IPHY}               ${CURDIR}/../../config/ap/CB006649_iphy_basic.xml
${CB006649_CFG_WTS_CFG}                ${CURDIR}/../../config/wts/CB006649_A_WTS_CFG.cfg
${CB009527_GNB_DELTA_JSON}             ${CURDIR}/../../config/gnb/CB009527_D_gNB_SCF_basic.xml
${CB009527_E_GNB_DELTA_JSON}            ${CURDIR}/../../config/gnb/CB009527_E3_gNB_SCF.xml
${CB009527_E1_GNB_DELTA_JSON}            ${CURDIR}/../../config/gnb/CB009527_E1_gNB_SCF.xml
${CB009527_E7_GNB_DELTA_JSON}          ${CURDIR}/../../config/gnb/CB009527_E7_gNB_SCF.xml
${CB009527_E1_TEST_GNB_DELTA_JSON}            ${CURDIR}/../../config/gnb/CB09527_E1_Test.xml
${FILTER_B003}                       dldata_pdschsendreql1sw
${CB009527_AP_IPHY}                  ${CURDIR}/../../config/ap/CB009527_D_iphy.xml
${CB009527_AP_E7_IPHY}               ${CURDIR}/../../config/ap/CB009527_E7_iphy.xml
${CB009527_CFG_WTS}                  ${CURDIR}/../../config/wts/CB009527_D_CFG_WTS.cfg
${CB009527_CFG_E7_WTS}               ${CURDIR}/../../config/wts/CB009527_E7_CFG_WTS.cfg
${16_UE_CB009527_CFG_E3_WTS}                ${CURDIR}/../../config/wts/16_UE_EIRP_CB009527_E_WTS.cfg
${BSR_FILE_CB009527_AVQL}             ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${CB009527_CAE_SCELLMODLIST}          sCellToAddModList
${CB009527_RESOURCETOADDMODLIST}      usage antennaSwitching
${CB009527_SCELLID}                   sCellIndex 1
&{COUNTER_CHECKS}        M55324C00701=EIRP_SLIDING_SEGMENT_1       M55324C00000=EIRP_SAMPLES
${LOCAL_MOID}          MRBTS-1/NRBTS-1/NRCELL-1
&{DATA_DICT}       M55309C12001=MAC_DTCH_CELL_THP_DL_MAX       M55309C12002=MAC_DTCH_CELL_THP_UL_MAX
${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE3_DTYPE_INTERNAL}       set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE4_DTYPE_INTERNAL}           set_pdu_param ue=4 pdu=1 trf_type=internal
${CM_UE5_DTYPE_INTERNAL}           set_pdu_param ue=5 pdu=1 trf_type=internal
${CM_UE6_DTYPE_INTERNAL}           set_pdu_param ue=6 pdu=1 trf_type=internal
${CM_UE7_DTYPE_INTERNAL}           set_pdu_param ue=7 pdu=1 trf_type=internal
${CM_UE8_DTYPE_INTERNAL}           set_pdu_param ue=8 pdu=1 trf_type=internal
${CM_UE9_DTYPE_INTERNAL}           set_pdu_param ue=9 pdu=1 trf_type=internal
${CM_UE10_DTYPE_INTERNAL}          set_pdu_param ue=10 pdu=1 trf_type=internal
${CM_UE11_DTYPE_INTERNAL}          set_pdu_param ue=11 pdu=1 trf_type=internal
${CM_UE12_DTYPE_INTERNAL}          set_pdu_param ue=12 pdu=1 trf_type=internal
${CM_UE13_DTYPE_INTERNAL}          set_pdu_param ue=13 pdu=1 trf_type=internal
${CM_UE14_DTYPE_INTERNAL}          set_pdu_param ue=14 pdu=1 trf_type=internal
${CM_UE15_DTYPE_INTERNAL}          set_pdu_param ue=15 pdu=1 trf_type=internal
${CM_UE16_DTYPE_INTERNAL}          set_pdu_param ue=16 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}          ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_2_REGISTER}                ue_register id=2
${CM_UE_2_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE_2_UL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_3_REGISTER}                ue_register id=3
${CM_UE_3_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${CM_UE_3_UL_DATA}                 trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_4_REGISTER}                ue_register id=4
${CM_UE_4_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=4 nwslice=1 gw=1
${CM_UE_4_UL_DATA}                 trf_data_start ue=4 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_5_REGISTER}                ue_register id=5
${CM_UE_5_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=5 nwslice=1 gw=1
${CM_UE_5_UL_DATA}                 trf_data_start ue=5 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_6_REGISTER}                ue_register id=6
${CM_UE_6_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=6 nwslice=1 gw=1
${CM_UE_6_UL_DATA}                 trf_data_start ue=6 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_7_REGISTER}                ue_register id=7
${CM_UE_7_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=7 nwslice=1 gw=1
${CM_UE_7_UL_DATA}                 trf_data_start ue=7 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_8_REGISTER}                ue_register id=8
${CM_UE_8_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=8 nwslice=1 gw=1
${CM_UE_8_UL_DATA}                 trf_data_start ue=8 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_9_REGISTER}                ue_register id=9
${CM_UE_9_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=9 nwslice=1 gw=1
${CM_UE_10_UL_DATA}                 trf_data_start ue=10 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_10_REGISTER}                ue_register id=10
${CM_UE_10_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=10 nwslice=1 gw=1
${CM_UE_11_REGISTER}                ue_register id=11
${CM_UE_11_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=11 nwslice=1 gw=1
${CM_UE_11_UL_DATA}                 trf_data_start ue=11 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_12_REGISTER}                ue_register id=12
${CM_UE_12_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=12 nwslice=1 gw=1
${CM_UE_12_UL_DATA}                 trf_data_start ue=12 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_13_REGISTER}                ue_register id=13
${CM_UE_13_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=13 nwslice=1 gw=1
${CM_UE_13_UL_DATA}                 trf_data_start ue=13 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_14_REGISTER}                ue_register id=14
${CM_UE_14_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=14 nwslice=1 gw=1
${CM_UE_14_UL_DATA}                 trf_data_start ue=14 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_15_REGISTER}                ue_register id=15
${CM_UE_15_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=15 nwslice=1 gw=1
${CM_UE_15_UL_DATA}                 trf_data_start ue=15 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_16_REGISTER}                ue_register id=16
${CM_UE_16_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=16 nwslice=1 gw=1
${CM_UE_16_UL_DATA}                 trf_data_start ue=16 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off
${CM_UE_3_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off
${CM_UE_4_DEREG}                   ue_deregister id=4 ue_deregister_type=switch_off
${CM_UE_5_DEREG}                   ue_deregister id=5 ue_deregister_type=switch_off
${CM_UE_6_DEREG}                   ue_deregister id=6 ue_deregister_type=switch_off
${CM_UE_7_DEREG}                   ue_deregister id=7 ue_deregister_type=switch_off
${CM_UE_8_DEREG}                   ue_deregister id=8 ue_deregister_type=switch_off
${CM_UE_9_DEREG}                   ue_deregister id=9 ue_deregister_type=switch_off
${CM_UE_10_DEREG}                   ue_deregister id=10 ue_deregister_type=switch_off
${CM_UE_11_DEREG}                   ue_deregister id=11 ue_deregister_type=switch_off
${CM_UE_12_DEREG}                   ue_deregister id=12 ue_deregister_type=switch_off
${CM_UE_13_DEREG}                   ue_deregister id=13 ue_deregister_type=switch_off
${CM_UE_14_DEREG}                   ue_deregister id=14 ue_deregister_type=switch_off
${CM_UE_15_DEREG}                   ue_deregister id=15 ue_deregister_type=switch_off
${CM_UE_16_DEREG}                   ue_deregister id=16 ue_deregister_type=switch_off
${CM_UE_1_UL_TRF1_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=25 trf_id=1
${CM_UE_1_UL_TRF2_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=2
${CM_UE_1_UL_TRF3_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=3
${CM_UE_1_UL_TRF4_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=4
${CM_UE_1_UL_TRF5_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=5
${CM_UE_1_UL_TRF6_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=6
${CM_UE_1_UL_TRF7_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=7
${CM_UE_1_UL_TRF8_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=8
${CM_UE_1_UL_TRF9_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=9
${CM_UE_1_UL_TRF10_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=10
${CM_UE_1_UL_TRF11_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=11
${CM_UE_1_DL_TRF1_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
${CM_UE_1_DL_TRF2_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
${CM_UE_1_DL_TRF3_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
${CM_UE_1_DL_TRF4_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=4
${CM_UE_1_DL_TRF5_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=5
${CM_UE_1_DL_TRF6_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=6
${CM_UE_1_DL_TRF7_DATA}            trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=7
${CM_UE_2_DL_TRF1_DATA}            trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
${CM_UE_2_DL_TRF2_DATA}            trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
${CM_UE_2_DL_TRF3_DATA}            trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
${CM_UE_2_UL_TRF1_DATA}            trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=25 trf_id=1
${CM_UE_3_DL_TRF1_DATA}            trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
${CM_UE_3_DL_TRF2_DATA}            trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
${CM_UE_3_DL_TRF3_DATA}            trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
${CM_UE_3_UL_TRF1_DATA}            trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=25 trf_id=1
${CM_UE_4_DL_TRF1_DATA}            trf_data_start ue=4 pdu=1 qfi=1 dir=dl mbps=175 trf_id=1
${CM_UE_4_DL_TRF2_DATA}            trf_data_start ue=4 pdu=1 qfi=1 dir=dl mbps=175 trf_id=2
${CM_UE_4_DL_TRF3_DATA}            trf_data_start ue=4 pdu=1 qfi=1 dir=dl mbps=175 trf_id=3
${CM_UE_4_UL_TRF1_DATA}            trf_data_start ue=4 pdu=1 qfi=1 dir=ul mbps=175 trf_id=1
${CM_UE_5_DL_TRF3_DATA}            trf_data_start ue=5 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_5_UL_TRF1_DATA}            trf_data_start ue=5 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_6_DL_TRF3_DATA}            trf_data_start ue=6 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_6_UL_TRF1_DATA}            trf_data_start ue=6 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_7_DL_TRF3_DATA}            trf_data_start ue=7 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_7_UL_TRF1_DATA}            trf_data_start ue=7 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_8_DL_TRF3_DATA}            trf_data_start ue=8 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_8_UL_TRF1_DATA}            trf_data_start ue=8 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_9_DL_TRF3_DATA}            trf_data_start ue=9 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_9_UL_TRF1_DATA}            trf_data_start ue=9 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_10_DL_TRF3_DATA}            trf_data_start ue=10 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_10_UL_TRF1_DATA}            trf_data_start ue=10 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_11_DL_TRF3_DATA}            trf_data_start ue=11 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_11_UL_TRF1_DATA}            trf_data_start ue=11 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_12_DL_TRF3_DATA}            trf_data_start ue=12 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_12_UL_TRF1_DATA}            trf_data_start ue=12 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_13_DL_TRF3_DATA}            trf_data_start ue=13 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_13_UL_TRF1_DATA}            trf_data_start ue=13 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_14_DL_TRF3_DATA}            trf_data_start ue=14 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_14_UL_TRF1_DATA}            trf_data_start ue=14 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_15_DL_TRF3_DATA}            trf_data_start ue=15 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_15_UL_TRF1_DATA}            trf_data_start ue=15 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_16_DL_TRF3_DATA}            trf_data_start ue=16 pdu=1 qfi=1 dir=dl mbps=100 trf_id=3
${CM_UE_16_UL_TRF1_DATA}            trf_data_start ue=16 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CB009527_D_UE1_CMD1}      ul_ue_beam_pos_nr profile_id=1 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE1_CMD2}             ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=1
${CB009527_D_UE1_CMD3}             csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE1_CMD4}             ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1
${CB009527_D_UE1_CMD5}             csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE1_CMD6}             ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1
${CB009527_D_UE2_CMD1}      ul_ue_beam_pos_nr profile_id=2 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE2_CMD2}             ue_testmode_set_nr id=2 testmode=ue_ul_beam_position action=activate profile_id=2
${CB009527_D_UE2_CMD3}             csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE2_CMD4}             ue_testmode_set_nr id=2 testmode=csi_override action=activate profile_id=2
${CB009527_D_UE2_CMD5}             csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE2_CMD6}             ue_testmode_set_nr id=2 testmode=csi_override action=activate profile_id=2
${CM_UE_2_STATS}                   ue_stats_nr id=2  type=pusch,pdsch
${CB009527_D_UE3_CMD1}       ul_ue_beam_pos_nr profile_id=3 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE3_CMD2}             ue_testmode_set_nr id=3 testmode=ue_ul_beam_position action=activate profile_id=3
${CB009527_D_UE3_CMD3}             csi_override_testmode_nr profile_id=3 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE3_CMD4}             ue_testmode_set_nr id=3 testmode=csi_override action=activate profile_id=1
${CB009527_D_UE3_CMD5}             csi_override_testmode_nr profile_id=3 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE3_CMD6}             ue_testmode_set_nr id=3 testmode=csi_override action=activate profile_id=3
${CM_UE_3_STATS}                   ue_stats_nr id=3  type=pusch,pdsch
${CB009527_D_UE4_CMD1}      ul_ue_beam_pos_nr profile_id=4 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE4_CMD2}             ue_testmode_set_nr id=4 testmode=ue_ul_beam_position action=activate profile_id=4
${CB009527_D_UE4_CMD3}             csi_override_testmode_nr profile_id=4 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE4_CMD4}             ue_testmode_set_nr id=4 testmode=csi_override action=activate profile_id=4
${CB009527_D_UE4_CMD5}             csi_override_testmode_nr profile_id=4 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE4_CMD6}             ue_testmode_set_nr id=4 testmode=csi_override action=activate profile_id=4
${CB009527_D_UE5_CMD1}             ul_ue_beam_pos_nr profile_id=5 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE5_CMD2}             ue_testmode_set_nr id=5 testmode=ue_ul_beam_position action=activate profile_id=5
${CB009527_D_UE5_CMD3}             csi_override_testmode_nr profile_id=3 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE5_CMD4}             ue_testmode_set_nr id=5 testmode=csi_override action=activate profile_id=5
${CB009527_D_UE5_CMD5}             csi_override_testmode_nr profile_id=5 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE5_CMD6}             ue_testmode_set_nr id=5 testmode=csi_override action=activate profile_id=5
${CM_UE_5_STATS}                   ue_stats_nr id=5  type=pusch,pdsch
${CB009527_D_UE6_CMD1}             ul_ue_beam_pos_nr profile_id=6 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE6_CMD2}             ue_testmode_set_nr id=6 testmode=ue_ul_beam_position action=activate profile_id=6
${CB009527_D_UE6_CMD3}             csi_override_testmode_nr profile_id=6 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE6_CMD4}             ue_testmode_set_nr id=6 testmode=csi_override action=activate profile_id=6
${CB009527_D_UE6_CMD5}             csi_override_testmode_nr profile_id=6 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE6_CMD6}             ue_testmode_set_nr id=6 testmode=csi_override action=activate profile_id=6
${CB009527_D_UE7_CMD1}             ul_ue_beam_pos_nr profile_id=7 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                            interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE7_CMD2}             ue_testmode_set_nr id=7 testmode=ue_ul_beam_position action=activate profile_id=7
${CB009527_D_UE7_CMD3}             csi_override_testmode_nr profile_id=7 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE7_CMD4}             ue_testmode_set_nr id=7 testmode=csi_override action=activate profile_id=7
${CB009527_D_UE7_CMD5}             csi_override_testmode_nr profile_id=7 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE7_CMD6}             ue_testmode_set_nr id=7 testmode=csi_override action=activate profile_id=7
${CM_UE_7_STATS}                   ue_stats_nr id=7  type=pusch,pdsch
${CB009527_D_UE8_CMD1}             ul_ue_beam_pos_nr profile_id=8 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                           interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE8_CMD2}             ue_testmode_set_nr id=8 testmode=ue_ul_beam_position action=activate profile_id=8
${CB009527_D_UE8_CMD3}             csi_override_testmode_nr profile_id=8 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE8_CMD4}             ue_testmode_set_nr id=8 testmode=csi_override action=activate profile_id=8
${CB009527_D_UE8_CMD5}             csi_override_testmode_nr profile_id=8 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE8_CMD6}             ue_testmode_set_nr id=8 testmode=csi_override action=activate profile_id=8
${CM_UE_8_STATS}                   ue_stats_nr id=8  type=pusch,pdsch
${CB009527_D_UE9_CMD2}             ue_testmode_set_nr id=9 testmode=ue_ul_beam_position action=activate profile_id=9
${CB009527_D_UE9_CMD3}             csi_override_testmode_nr profile_id=9 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE9_CMD4}             ue_testmode_set_nr id=9 testmode=csi_override action=activate profile_id=9
${CB009527_D_UE9_CMD5}             csi_override_testmode_nr profile_id=9 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE9_CMD6}             ue_testmode_set_nr id=9 testmode=csi_override action=activate profile_id=9
${CM_UE_9_STATS}                   ue_stats_nr id=9  type=pusch,pdsch
${CB009527_D_UE10_CMD1}             ul_ue_beam_pos_nr profile_id=9 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                           interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE10_CMD2}             ue_testmode_set_nr id=10 testmode=ue_ul_beam_position action=activate profile_id=10
${CB009527_D_UE10_CMD3}             csi_override_testmode_nr profile_id=10 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE10_CMD4}             ue_testmode_set_nr id=10 testmode=csi_override action=activate profile_id=10
${CB009527_D_UE10_CMD5}             csi_override_testmode_nr profile_id=10 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE10_CMD6}             ue_testmode_set_nr id=10 testmode=csi_override action=activate profile_id=10
${CM_UE_11_STATS}                   ue_stats_nr id=11  type=pusch,pdsch
${CB009527_D_UE11_CMD1}             ul_ue_beam_pos_nr profile_id=11 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                           interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE11_CMD2}             ue_testmode_set_nr id=11 testmode=ue_ul_beam_position action=activate profile_id=11
${CB009527_D_UE11_CMD3}             csi_override_testmode_nr profile_id=11 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE11_CMD4}             ue_testmode_set_nr id=11 testmode=csi_override action=activate profile_id=11
${CB009527_D_UE11_CMD5}             csi_override_testmode_nr profile_id=11 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE11_CMD6}             ue_testmode_set_nr id=11 testmode=csi_override action=activate profile_id=11
${CM_UE_12_STATS}                   ue_stats_nr id=12  type=pusch,pdsch
${CB009527_D_UE12_CMD1}             ul_ue_beam_pos_nr profile_id=12 num_subband_info=2 mode=0 correlation=1,1 num_interfered_bf_subband=10,5
    ...                           interfered_srs_subband=15,10 srs_transmit_power_per_port=-550,-550
${CB009527_D_UE12_CMD2}             ue_testmode_set_nr id=12 testmode=ue_ul_beam_position action=activate profile_id=12
${CB009527_D_UE12_CMD3}             csi_override_testmode_nr profile_id=12 cqi_mode=fixed cqi=4 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE12_CMD4}             ue_testmode_set_nr id=12 testmode=csi_override action=activate profile_id=12
${CB009527_D_UE12_CMD5}             csi_override_testmode_nr profile_id=12 cqi_mode=fixed cqi=15 ri_mode=fixed ri=3 pmi_mode=fixed pmi=1
${CB009527_D_UE12_CMD6}             ue_testmode_set_nr id=12 testmode=csi_override action=activate profile_id=12
${CM_UE_6_STATS}                   ue_stats_nr id=6  type=pusch,pdsch
${CM_UE_1_STATS}                   ue_stats_nr id=0-1  type=pusch,pdsch
${CM_UE_4_STATS}                   ue_stats_nr id=4  type=pusch,pdsch
${CM_UE_STATS}                     ue_stats_nr id=0-1  type=pusch,pdsch
${CFG_CB008235_A_TC_01_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_01_8DL8UL_GNB_SCF.xml
${CFG_CB008235_A_TC_02_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_02_16DL8UL_GNB_SCF.xml
${CFG_CB008235_A_TC_03_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_02_16DL8UL_GNB_SCF.xml
${CFG_CB008235_A_TC_01_IPHY}             ${CURDIR}/../../config/ap/CB008235_A_IPHY_TC01.xml
${CFG_CB008235_A_TC_01_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_01.cfg
${CFG_CB008235_A_TC_03_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_03.cfg
${CFG_CB008235_A_TC_04_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC04.cfg
${CFG_BSR_AVQL_2_H2_A60_60_P02}          ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${CM_UL_BEAM_POS_PROFILE_1}              ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-65,-65 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_2}              ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-45,-45 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_3}              ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-25,-25 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_4}              ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=25,25 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_PROFILE_1_ACT}              ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${CM_UL_BEAM_PROFILE_2_ACT}              ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate
${CM_UL_BEAM_PROFILE_3_ACT}              ue_testmode_set_nr id=3 testmode=ue_ul_beam_position profile_id=3 action=activate
${CM_UL_BEAM_PROFILE_4_ACT}              ue_testmode_set_nr id=4 testmode=ue_ul_beam_position profile_id=4 action=activate
${CM_UL_BEAM_POS_PROFILE_TC_04_1}        ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-65,-65 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_2}        ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-45,-45 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_3}        ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-25,-25 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_4}        ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=-5,-5 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_5}        ul_ue_beam_pos_nr profile_id=5 num_beam_paths=2 azimuth=15,15 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_6}        ul_ue_beam_pos_nr profile_id=6 num_beam_paths=2 azimuth=35,35 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_7}        ul_ue_beam_pos_nr profile_id=7 num_beam_paths=2 azimuth=55,55 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_8}        ul_ue_beam_pos_nr profile_id=8 num_beam_paths=2 azimuth=67,67 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_PROFILE_TC_04_1_ACT}        ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${CM_UL_BEAM_PROFILE_TC_04_2_ACT}        ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate
${CM_UL_BEAM_PROFILE_TC_04_3_ACT}        ue_testmode_set_nr id=3 testmode=ue_ul_beam_position profile_id=3 action=activate
${CM_UL_BEAM_PROFILE_TC_04_4_ACT}        ue_testmode_set_nr id=4 testmode=ue_ul_beam_position profile_id=4 action=activate
${CM_UL_BEAM_PROFILE_TC_04_5_ACT}        ue_testmode_set_nr id=5 testmode=ue_ul_beam_position profile_id=5 action=activate
${CM_UL_BEAM_PROFILE_TC_04_6_ACT}        ue_testmode_set_nr id=6 testmode=ue_ul_beam_position profile_id=6 action=activate
${CM_UL_BEAM_PROFILE_TC_04_7_ACT}        ue_testmode_set_nr id=7 testmode=ue_ul_beam_position profile_id=7 action=activate
${CM_UL_BEAM_PROFILE_TC_04_8_ACT}        ue_testmode_set_nr id=8 testmode=ue_ul_beam_position profile_id=8 action=activate
${VAL_UL_SUBCELLTYPE_C8_8}         type:SUBCELLTYPE_C8_8
${VAL_UL_SUBCELLTYPE_C16_8}        ulSubcellType SW_L1_COMMON_SUBCELLTYPE_C16_8
${VAL_UE2_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE
${VAL_SIB1}                        SystemInformationBlockType1-NR updated
${VAL_REG}                         Received REGISTRATION COMPLETE
${VAL_PDU_SESSION}                 Initial Context Setup Successful
${VAL_UE1_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE

