*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
${Log_Path}                              /home/ute/logs
${CFG_CB008235_A_TC_01_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_01_8DL8UL_GNB_SCF.xml
${CFG_CB008235_A_TC_02_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_02_16DL8UL_GNB_SCF.xml
${CFG_CB008235_A_TC_03_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_02_16DL8UL_GNB_SCF.xml
${CFG_CB008235_A_TC_01_IPHY}             ${CURDIR}/../../config/ap/CB008235_A_IPHY_TC01.xml
${CFG_CB008235_A_TC_01_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_01.cfg
${CFG_CB008235_A_TC_03_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_03.cfg
${CFG_CB008235_A_TC_04_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC04.cfg
${CFG_CB008235_A_TC_07_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_07.cfg
${CFG_CB008235_A_TC_07B_WTS}             ${CURDIR}/../../config/wts/CB008235_A_TC_07B.cfg


${CFG_BSR_AVQL_2_H2_A60_60_P02}          ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip

${CM_UL_SINR_PROFILE_11}                 ul_sinr_testmode_nr profile_id=11 pusch_tx_power=-394 pathloss=28
${CM_UL_SINR_ACT_1}                      ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_2}                      ue_testmode_set_nr id=2 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_3}                      ue_testmode_set_nr id=3 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_4}                      ue_testmode_set_nr id=4 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_5}                      ue_testmode_set_nr id=5 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_6}                      ue_testmode_set_nr id=6 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_7}                      ue_testmode_set_nr id=7 testmode=ul_sinr action=activate profile_id=11
${CM_UL_SINR_ACT_8}                      ue_testmode_set_nr id=8 testmode=ul_sinr action=activate profile_id=11
${CM_UL_BEAM_POS_PROFILE_1}              ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-65,-65 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_2}              ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-45,-45 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_3}              ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=0,0 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_4}              ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=25,25 zenith=-12,-12 power=-250,-250
${CM_UL_BEAM_PROFILE_1_ACT}              ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${CM_UL_BEAM_PROFILE_2_ACT}              ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate
${CM_UL_BEAM_PROFILE_3_ACT}              ue_testmode_set_nr id=3 testmode=ue_ul_beam_position profile_id=3 action=activate
${CM_UL_BEAM_PROFILE_4_ACT}              ue_testmode_set_nr id=4 testmode=ue_ul_beam_position profile_id=4 action=activate
${CM_UL_BEAM_POS_PROFILE_TC_04_1}        ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,-70 zenith=-40,-40 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_2}        ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-53,-53 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_3}        ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-35,-35 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_4}        ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=-18,-18 zenith=-10,-10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_5}        ul_ue_beam_pos_nr profile_id=5 num_beam_paths=2 azimuth=0,0 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_6}        ul_ue_beam_pos_nr profile_id=6 num_beam_paths=2 azimuth=35,35 zenith=20,20 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_7}        ul_ue_beam_pos_nr profile_id=7 num_beam_paths=2 azimuth=18,18 zenith=10,10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_8}        ul_ue_beam_pos_nr profile_id=8 num_beam_paths=2 azimuth=53,53 zenith=30,30 power=-250,-250
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
${CM_UE_1_STATS}                   ue_stats_nr id=1 type=pusch
${CM_UE_2_STATS}                   ue_stats_nr id=2 type=pusch
${CM_UE_3_STATS}                   ue_stats_nr id=3 type=pusch
${CM_UE_4_STATS}                   ue_stats_nr id=4 type=pusch
${CM_UE_5_STATS}                   ue_stats_nr id=5 type=pusch
${CM_UE_6_STATS}                   ue_stats_nr id=6 type=pusch
${CM_UE_7_STATS}                   ue_stats_nr id=7 type=pusch
${CM_UE_8_STATS}                   ue_stats_nr id=8 type=pusch
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE_2_REGISTER}                ue_register id=2
${CM_UE_2_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE_2_UL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off
${CM_UE3_DTYPE_INTERNAL}           set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE_3_REGISTER}                ue_register id=3
${CM_UE_3_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${CM_UE_3_UL_DATA}                 trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_3_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off
${CM_UE4_DTYPE_INTERNAL}           set_pdu_param ue=4 pdu=1 trf_type=internal
${CM_UE_4_REGISTER}                ue_register id=4
${CM_UE_4_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=4 nwslice=1 gw=1
${CM_UE_4_UL_DATA}                 trf_data_start ue=4 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_UE_4_DEREG}                   ue_deregister id=4 ue_deregister_type=switch_off
${CM_UE5_DTYPE_INTERNAL}           set_pdu_param ue=5 pdu=1 trf_type=internal
${CM_UE_5_REGISTER}                ue_register id=5
${CM_UE_5_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=5 nwslice=1 gw=1
${CM_UE_5_UL_DATA}                 trf_data_start ue=5 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_5_DEREG}                   ue_deregister id=5 ue_deregister_type=switch_off
${CM_UE6_DTYPE_INTERNAL}           set_pdu_param ue=6 pdu=1 trf_type=internal
${CM_UE_6_REGISTER}                ue_register id=6
${CM_UE_6_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=6 nwslice=1 gw=1
${CM_UE_6_UL_DATA}                 trf_data_start ue=6 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_6_DEREG}                   ue_deregister id=6 ue_deregister_type=switch_off
${CM_UE7_DTYPE_INTERNAL}           set_pdu_param ue=7 pdu=1 trf_type=internal
${CM_UE_7_REGISTER}                ue_register id=7
${CM_UE_7_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=7 nwslice=1 gw=1
${CM_UE_7_UL_DATA}                 trf_data_start ue=7 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_7_DEREG}                   ue_deregister id=7 ue_deregister_type=switch_off
${CM_UE8_DTYPE_INTERNAL}           set_pdu_param ue=8 pdu=1 trf_type=internal
${CM_UE_8_REGISTER}                ue_register id=8
${CM_UE_8_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=8 nwslice=1 gw=1
${CM_UE_8_UL_DATA}                 trf_data_start ue=8 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_8_DEREG}                   ue_deregister id=8 ue_deregister_type=switch_off
