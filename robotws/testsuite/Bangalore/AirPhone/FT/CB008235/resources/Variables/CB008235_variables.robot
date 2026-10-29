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
${CFG_CB008235_A_TC_03_NSA_GNB_SCF}      ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_03_NSA_GNB_SCF.xml
${CFG_CB008235_A_TC_05_AVQC_GNB_SCF}     ${CURDIR}/../../config/gnb/CFG_CB008235_A_TC_05_16DL8UL_AVQC_GNB_SCF.xml
${CFG_CB008235_E_TC_01_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_E_TC_01_16DL8UL_GNB_SCF.xml
${CFG_CB008235_C_TC_01_GNB_SCF}          ${CURDIR}/../../config/gnb/CFG_CB008235_C_TC_01_16DL8UL_16UE_GNB_SCF.xml

${CFG_CB008235_A_TC_01_IPHY}             ${CURDIR}/../../config/ap/CB008235_A_IPHY_TC01.xml
${CFG_CB008235_A_TC_05_AVQC_IPHY}        ${CURDIR}/../../config/ap/CB008235_A_IPHY_TC05_AVQC.xml
${CFG_CB008235_C_TC_01_IPHY}             ${CURDIR}/../../config/ap/CB008235_C_IPHY_TC01_2CELL_AVQL.xml

${CFG_CB008235_A_TC_01_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_01.cfg
${CFG_CB008235_A_TC_03_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_03.cfg
${CFG_CB008235_A_TC_03_NSA_WTS}          ${CURDIR}/../../config/wts/CB008235_A_TC_03_NSA.cfg
${CFG_CB008235_A_TC_04_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC04.cfg
${CFG_CB008235_E_TC_01_WTS}              ${CURDIR}/../../config/wts/CB008235_E_TC01.cfg
${CFG_CB008235_C_TC_01_WTS}              ${CURDIR}/../../config/wts/CB008235_C_TC_01.cfg


${CFG_CB008235_A_TC_04_2R2_4R1_WTS}      ${CURDIR}/../../config/wts/CB008235_A_TC04_4R2_2R1.cfg
${CFG_CB008235_A_TC_06_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_06.cfg
${CFG_CB008235_A_TC_07_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC_07.cfg
${CFG_CB008235_A_TC_07B_WTS}             ${CURDIR}/../../config/wts/CB008235_A_TC_07B.cfg
${CFG_CB008235_A_TC_04_10R1UEWTS}        ${CURDIR}/../../config/wts/CB008235_A_TC04_10R1UE.cfg
${CFG_CB008235_A_TC_08_NSA_WTS}          ${CURDIR}/../../config/wts/CB008235_A_TC_08_NSA.cfg
${CFG_CB008235_A_TC_05_NSA_AVQC_WTS}     ${CURDIR}/../../config/wts/CB008235_A_TC_08_NSA_AVQC.cfg
${CFG_CB008235_D_TC_04_WTS}              ${CURDIR}/../../config/wts/CB008235_A_TC04_10R1UE.cfg

${CFG_CB008235_D_TC_01B_SANSA_WTS}          ${CURDIR}/../../config/wts/CB008235_D_TC_01B_SANSA.cfg
${CFG_CB008235_D_TC_03_GNB_SCF}             ${CURDIR}/../../config/gnb/CFG_CB008235_D_TC_03_GNB_SCF.xml
${CFG_CB008235_D_TC_01A_GNB_SCF}           ${CURDIR}/../../config/gnb/CFG_CB008235_D_TC_01A_FDM_DMRS_GNB_SCF.xml
${CFG_CB008235_D_TC_01B_GNB_SCF_DELTA}    CFG_CB008235_D_TC_01B_GNB_SCF_DELTA.json
${CFG_CB008235_D_TC_02_GNB_SCF}           ${CURDIR}/../../config/gnb/CFG_CB008235_D_TC_02_ADAP_RETX.xml



${CM_UL_SINR_PROFILE_11}                 ul_sinr_testmode_nr profile_id=11 pusch_tx_power=-394 pathloss=28
${CM_UL_SINR_ACT_1}                      ue_testmode_set_nr id=1-16 testmode=ul_sinr action=activate profile_id=11

${CM_UL_BEAM_POS_PROFILE_1}              ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,-70 zenith=-40,-40 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_2}              ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-53,-53 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_3}              ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-35,-35 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_4}              ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=-18,-18 zenith=-10,-10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_5}              ul_ue_beam_pos_nr profile_id=5 num_beam_paths=2 azimuth=0,0 zenith=0,0 power=-250,-250

${CM_UL_BEAM_PROFILE_1_ACT}              ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${CM_UL_BEAM_PROFILE_2_ACT}              ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate
${CM_UL_BEAM_PROFILE_3_ACT}              ue_testmode_set_nr id=3 testmode=ue_ul_beam_position profile_id=3 action=activate
${CM_UL_BEAM_PROFILE_4_ACT}              ue_testmode_set_nr id=4 testmode=ue_ul_beam_position profile_id=4 action=activate
${CM_UL_BEAM_PROFILE_5_ACT}              ue_testmode_set_nr id=5 testmode=ue_ul_beam_position profile_id=4 action=activate
${CM_UL_BEAM_PROFILE_6_ACT}              ue_testmode_set_nr id=6 testmode=ue_ul_beam_position profile_id=4 action=activate

${CM_UL_BEAM_POS_PROFILE_TC_04_1}        ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,-70 zenith=-40,-40 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_2}        ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-53,-53 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_3}        ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-35,-35 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_4}        ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=-18,-18 zenith=-10,-10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_5}        ul_ue_beam_pos_nr profile_id=5 num_beam_paths=2 azimuth=0,0 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_6}        ul_ue_beam_pos_nr profile_id=6 num_beam_paths=2 azimuth=35,35 zenith=20,20 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_7}        ul_ue_beam_pos_nr profile_id=7 num_beam_paths=2 azimuth=18,18 zenith=10,10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_8}        ul_ue_beam_pos_nr profile_id=8 num_beam_paths=2 azimuth=53,53 zenith=30,30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_9}        ul_ue_beam_pos_nr profile_id=9 num_beam_paths=2 azimuth=-70,-70 zenith=-40,-40 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_10}        ul_ue_beam_pos_nr profile_id=10 num_beam_paths=2 azimuth=-53,-53 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_11}        ul_ue_beam_pos_nr profile_id=11 num_beam_paths=2 azimuth=-35,-35 zenith=-30,-30 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_12}        ul_ue_beam_pos_nr profile_id=12 num_beam_paths=2 azimuth=-18,-18 zenith=-10,-10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_13}        ul_ue_beam_pos_nr profile_id=13 num_beam_paths=2 azimuth=0,0 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_14}        ul_ue_beam_pos_nr profile_id=14 num_beam_paths=2 azimuth=35,35 zenith=20,20 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_15}        ul_ue_beam_pos_nr profile_id=15 num_beam_paths=2 azimuth=18,18 zenith=10,10 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_04_16}        ul_ue_beam_pos_nr profile_id=16 num_beam_paths=2 azimuth=53,5b3 zenith=30,30 power=-250,-250



${CM_UL_BEAM_POS_PROFILE_TC_08_11_AVQC}      ul_ue_beam_pos_nr profile_id=11 num_beam_paths=2 azimuth=0,0 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_12_AVQC}      ul_ue_beam_pos_nr profile_id=12 num_beam_paths=2 azimuth=-14,-14 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_13_AVQC}      ul_ue_beam_pos_nr profile_id=13 num_beam_paths=2 azimuth=-30,-30 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_14_AVQC}      ul_ue_beam_pos_nr profile_id=14 num_beam_paths=2 azimuth=-48,-48 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_15_AVQC}      ul_ue_beam_pos_nr profile_id=15 num_beam_paths=2 azimuth=-60,-60 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_16_AVQC}      ul_ue_beam_pos_nr profile_id=16 num_beam_paths=2 azimuth=48,48 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_17_AVQC}      ul_ue_beam_pos_nr profile_id=17 num_beam_paths=2 azimuth=30,30 zenith=0,0 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_TC_08_18_AVQC}      ul_ue_beam_pos_nr profile_id=18 num_beam_paths=2 azimuth=14,14 zenith=0,0 power=-250,-250


${CM_UL_BEAM_PROFILE_TC_08_11_AVQC_ACT}      ue_testmode_set_nr id=11 testmode=ue_ul_beam_position profile_id=11 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_12_AVQC_ACT}      ue_testmode_set_nr id=12 testmode=ue_ul_beam_position profile_id=12 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_13_AVQC_ACT}      ue_testmode_set_nr id=13 testmode=ue_ul_beam_position profile_id=13 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_14_AVQC_ACT}      ue_testmode_set_nr id=14 testmode=ue_ul_beam_position profile_id=14 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_15_AVQC_ACT}      ue_testmode_set_nr id=15 testmode=ue_ul_beam_position profile_id=15 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_16_AVQC_ACT}      ue_testmode_set_nr id=16 testmode=ue_ul_beam_position profile_id=16 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_17_AVQC_ACT}      ue_testmode_set_nr id=17 testmode=ue_ul_beam_position profile_id=17 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_18_AVQC_ACT}      ue_testmode_set_nr id=18 testmode=ue_ul_beam_position profile_id=18 scell=8 action=activate

${CM_UL_BEAM_PROFILE_TC_04_1_ACT}        ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${CM_UL_BEAM_PROFILE_TC_04_2_ACT}        ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate
${CM_UL_BEAM_PROFILE_TC_04_3_ACT}        ue_testmode_set_nr id=3 testmode=ue_ul_beam_position profile_id=3 action=activate
${CM_UL_BEAM_PROFILE_TC_04_4_ACT}        ue_testmode_set_nr id=4 testmode=ue_ul_beam_position profile_id=4 action=activate
${CM_UL_BEAM_PROFILE_TC_04_5_ACT}        ue_testmode_set_nr id=5 testmode=ue_ul_beam_position profile_id=5 action=activate
${CM_UL_BEAM_PROFILE_TC_04_6_ACT}        ue_testmode_set_nr id=6 testmode=ue_ul_beam_position profile_id=6 action=activate
${CM_UL_BEAM_PROFILE_TC_04_7_ACT}        ue_testmode_set_nr id=7 testmode=ue_ul_beam_position profile_id=7 action=activate
${CM_UL_BEAM_PROFILE_TC_04_8_ACT}        ue_testmode_set_nr id=8 testmode=ue_ul_beam_position profile_id=8 action=activate
${CM_UL_BEAM_PROFILE_TC_04_9_ACT}        ue_testmode_set_nr id=9 testmode=ue_ul_beam_position profile_id=9 action=activate
${CM_UL_BEAM_PROFILE_TC_04_10_ACT}       ue_testmode_set_nr id=10 testmode=ue_ul_beam_position profile_id=10 action=activate
${CM_UL_BEAM_PROFILE_TC_04_11_ACT}       ue_testmode_set_nr id=11 testmode=ue_ul_beam_position profile_id=11 action=activate
${CM_UL_BEAM_PROFILE_TC_04_12_ACT}       ue_testmode_set_nr id=12 testmode=ue_ul_beam_position profile_id=12 action=activate
${CM_UL_BEAM_PROFILE_TC_04_13_ACT}       ue_testmode_set_nr id=13 testmode=ue_ul_beam_position profile_id=13 action=activate
${CM_UL_BEAM_PROFILE_TC_04_14_ACT}       ue_testmode_set_nr id=14 testmode=ue_ul_beam_position profile_id=14 action=activate
${CM_UL_BEAM_PROFILE_TC_04_15_ACT}       ue_testmode_set_nr id=15 testmode=ue_ul_beam_position profile_id=15 action=activate
${CM_UL_BEAM_PROFILE_TC_04_16_ACT}       ue_testmode_set_nr id=16 testmode=ue_ul_beam_position profile_id=16 action=activate


${CM_UL_BEAM_PROFILE_TC_08_11_ACT}       ue_testmode_set_nr id=11 testmode=ue_ul_beam_position profile_id=1 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_12_ACT}       ue_testmode_set_nr id=12 testmode=ue_ul_beam_position profile_id=2 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_13_ACT}       ue_testmode_set_nr id=13 testmode=ue_ul_beam_position profile_id=3 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_14_ACT}       ue_testmode_set_nr id=14 testmode=ue_ul_beam_position profile_id=4 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_15_ACT}       ue_testmode_set_nr id=15 testmode=ue_ul_beam_position profile_id=5 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_16_ACT}       ue_testmode_set_nr id=16 testmode=ue_ul_beam_position profile_id=6 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_17_ACT}       ue_testmode_set_nr id=17 testmode=ue_ul_beam_position profile_id=7 scell=8 action=activate
${CM_UL_BEAM_PROFILE_TC_08_18_ACT}       ue_testmode_set_nr id=18 testmode=ue_ul_beam_position profile_id=8 scell=8 action=activate

${VAL_UL_SUBCELLTYPE_C8_8}         type:SUBCELLTYPE_C8_8
${VAL_UL_SUBCELLTYPE_C16_8}        ulSubcellType SW_L1_COMMON_SUBCELLTYPE_C16_8
${VAL_UE2_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE
${VAL_SIB1}                        SystemInformationBlockType1-NR updated
${VAL_REG}                         Received REGISTRATION COMPLETE
${VAL_PDU_SESSION}                 Initial Context Setup Successful
${VAL_UE1_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE

${VAL_UE1_REG_COMPLETE}            AMF UE NGAP ID 1, UE now in NG RM Registered state
${VAL_UE2_REG_COMPLETE}            AMF UE NGAP ID 2, UE now in NG RM Registered state
${VAL_UE3_REG_COMPLETE}            AMF UE NGAP ID 3, UE now in NG RM Registered state
${VAL_UE4_REG_COMPLETE}            AMF UE NGAP ID 4, UE now in NG RM Registered state
${VAL_UE5_REG_COMPLETE}            AMF UE NGAP ID 5, UE now in NG RM Registered state
${VAL_UE6_REG_COMPLETE}            AMF UE NGAP ID 6, UE now in NG RM Registered state
${VAL_UE7_REG_COMPLETE}            AMF UE NGAP ID 7, UE now in NG RM Registered state
${VAL_UE8_REG_COMPLETE}            AMF UE NGAP ID 8, UE now in NG RM Registered state
${VAL_UE9_REG_COMPLETE}            AMF UE NGAP ID 9, UE now in NG RM Registered state
${VAL_UE10_REG_COMPLETE}           AMF UE NGAP ID 10, UE now in NG RM Registered state

${VAL_UE1_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 1
${VAL_UE2_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 2
${VAL_UE3_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 3
${VAL_UE4_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 4
${VAL_UE5_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 5
${VAL_UE6_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 6
${VAL_UE7_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 7
${VAL_UE8_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 8
${VAL_UE9_PDU_SESSION}             Initial Context Setup Successful for UE with AMF UE ID 9
${VAL_UE10_PDU_SESSION}            Initial Context Setup Successful for UE with AMF UE ID 10


${CM_UE_1_STATS}                   ue_stats_nr id=1 type=pusch
${CM_UE_2_STATS}                   ue_stats_nr id=2 type=pusch
${CM_UE_3_STATS}                   ue_stats_nr id=3 type=pusch
${CM_UE_4_STATS}                   ue_stats_nr id=4 type=pusch
${CM_UE_5_STATS}                   ue_stats_nr id=5 type=pusch
${CM_UE_6_STATS}                   ue_stats_nr id=6 type=pusch
${CM_UE_7_STATS}                   ue_stats_nr id=7 type=pusch
${CM_UE_8_STATS}                   ue_stats_nr id=8 type=pusch
${CM_UE_9_STATS}                   ue_stats_nr id=9 type=pusch
${CM_UE_10_STATS}                  ue_stats_nr id=10 type=pusch
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
${CM_UE9_DTYPE_INTERNAL}           set_pdu_param ue=9 pdu=1 trf_type=internal
${CM_UE_9_REGISTER}                ue_register id=9
${CM_UE_9_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=9 nwslice=1 gw=1
${CM_UE_9_UL_DATA}                 trf_data_start ue=9 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_9_DEREG}                   ue_deregister id=9 ue_deregister_type=switch_off
${CM_UE10_DTYPE_INTERNAL}           set_pdu_param ue=10 pdu=1 trf_type=internal
${CM_UE_10_REGISTER}                ue_register id=10
${CM_UE_10_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=10 nwslice=1 gw=1
${CM_UE_10_UL_DATA}                 trf_data_start ue=10 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_10_DEREG}                   ue_deregister id=10 ue_deregister_type=switch_off
${CM_UE11_DTYPE_INTERNAL}           set_pdu_param ue=11 pdu=1 trf_type=internal
${CM_UE_11_REGISTER}                ue_register id=11
${CM_UE_11_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=11 nwslice=1 gw=1
${CM_UE_11_UL_DATA}                 trf_data_start ue=11 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_11_DEREG}                   ue_deregister id=11 ue_deregister_type=switch_off
${CM_UE12_DTYPE_INTERNAL}           set_pdu_param ue=12 pdu=1 trf_type=internal
${CM_UE_12_REGISTER}                ue_register id=12
${CM_UE_12_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=12 nwslice=1 gw=1
${CM_UE_12_UL_DATA}                 trf_data_start ue=12 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_12_DEREG}                   ue_deregister id=12 ue_deregister_type=switch_off
${CM_UE13_DTYPE_INTERNAL}           set_pdu_param ue=13 pdu=1 trf_type=internal
${CM_UE_13_REGISTER}                ue_register id=13
${CM_UE_13_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=13 nwslice=1 gw=1
${CM_UE_13_UL_DATA}                 trf_data_start ue=13 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_13_DEREG}                   ue_deregister id=13 ue_deregister_type=switch_off
${CM_UE14_DTYPE_INTERNAL}           set_pdu_param ue=14 pdu=1 trf_type=internal
${CM_UE_14_REGISTER}                ue_register id=14
${CM_UE_14_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=14 nwslice=1 gw=1
${CM_UE_14_UL_DATA}                 trf_data_start ue=14 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_14_DEREG}                   ue_deregister id=14 ue_deregister_type=switch_off
${CM_UE15_DTYPE_INTERNAL}           set_pdu_param ue=15 pdu=1 trf_type=internal
${CM_UE_15_REGISTER}                ue_register id=15
${CM_UE_15_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=15 nwslice=1 gw=1
${CM_UE_15_UL_DATA}                 trf_data_start ue=15 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_15_DEREG}                   ue_deregister id=15 ue_deregister_type=switch_off
${CM_UE16_DTYPE_INTERNAL}           set_pdu_param ue=16 pdu=1 trf_type=internal
${CM_UE_16_REGISTER}                ue_register id=16
${CM_UE_16_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=16 nwslice=1 gw=1
${CM_UE_16_UL_DATA}                 trf_data_start ue=16 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_16_DEREG}                   ue_deregister id=16 ue_deregister_type=switch_off

${CM_R2_UE_1_UL_DATA}              trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=100 trf_id=1
${CM_R2_UE_2_UL_DATA}              trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=100 trf_id=2
${CM_R2_UE_3_UL_DATA}              trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=100 trf_id=3
${CM_R2_UE_4_UL_DATA}              trf_data_start ue=4 pdu=1 qfi=1 dir=ul mbps=100 trf_id=4
${CM_R2_UE_5_UL_DATA}              trf_data_start ue=5 pdu=1 qfi=1 dir=ul mbps=100 trf_id=5
${CM_R2_UE_6_UL_DATA}              trf_data_start ue=6 pdu=1 qfi=1 dir=ul mbps=100 trf_id=6

${CM_NSA_X2LINK}                   enb_x2_link_up enb=1 target=2
${CM_NSA_SET_ENDC}                 enb_endc_param id=1 serving_cell_index_range_scg=5:31

${CM_NSA_UE_11_ATTACH}             ue_attach id=11
${CM_NSA_UE_11_TRIGGER_ENDC}       ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_11_DL_DATA}            trf_data_start ue=11 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_11_UL_DATA}            trf_data_start ue=11 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_11_DETTACH}            ue_detach id=11 ue_detach_type=automatic

${CM_NSA_UE_12_ATTACH}             ue_attach id=12
${CM_NSA_UE_12_TRIGGER_ENDC}       ue_dc_enb_start ue=12 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_12_DL_DATA}            trf_data_start ue=12 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_12_UL_DATA}            trf_data_start ue=12 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_12_DETTACH}            ue_detach id=12 ue_detach_type=automatic

${CM_NSA_UE_13_ATTACH}             ue_attach id=13
${CM_NSA_UE_13_TRIGGER_ENDC}       ue_dc_enb_start ue=13 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_13_DL_DATA}            trf_data_start ue=13 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_13_UL_DATA}            trf_data_start ue=13 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_13_DETTACH}            ue_detach id=13 ue_detach_type=automatic

${CM_NSA_UE_14_ATTACH}             ue_attach id=14
${CM_NSA_UE_14_TRIGGER_ENDC}       ue_dc_enb_start ue=14 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_14_DL_DATA}            trf_data_start ue=14 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_14_UL_DATA}            trf_data_start ue=14 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_14_DETTACH}            ue_detach id=14 ue_detach_type=automatic


${CM_NSA_UE_15_ATTACH}             ue_attach id=15
${CM_NSA_UE_15_TRIGGER_ENDC}       ue_dc_enb_start ue=15 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_15_DL_DATA}            trf_data_start ue=15 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_15_UL_DATA}            trf_data_start ue=15 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_15_DETTACH}            ue_detach id=15 ue_detach_type=automatic

${CM_NSA_UE_16_ATTACH}             ue_attach id=16
${CM_NSA_UE_16_TRIGGER_ENDC}       ue_dc_enb_start ue=16 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_16_DL_DATA}            trf_data_start ue=16 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_16_UL_DATA}            trf_data_start ue=16 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_16_DETTACH}            ue_detach id=16 ue_detach_type=automatic

${CM_NSA_UE_17_ATTACH}             ue_attach id=17
${CM_NSA_UE_17_TRIGGER_ENDC}       ue_dc_enb_start ue=17 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_17_DL_DATA}            trf_data_start ue=17 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_17_UL_DATA}            trf_data_start ue=17 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_17_DETTACH}            ue_detach id=17 ue_detach_type=automatic

${CM_NSA_UE_18_ATTACH}             ue_attach id=18
${CM_NSA_UE_18_TRIGGER_ENDC}       ue_dc_enb_start ue=18 target_gnb=2 target_cells=1 bearer=2 type=split_scg
${CM_NSA_UE_18_DL_DATA}            trf_data_start ue=18 id=2 dir=dl trf_id=2 mbps=20
${CM_NSA_UE_18_UL_DATA}            trf_data_start ue=18 id=2 dir=ul trf_id=1 mbps=100
${CM_NSA_UE_18_DETTACH}            ue_detach id=18 ue_detach_type=automatic

${CM_NSA_UE_11_STATS}              bearer_stats ue=11 id=2 dir=ul
${CM_NSA_UE_12_STATS}              bearer_stats ue=12 id=2 dir=ul
${CM_NSA_UE_13_STATS}              bearer_stats ue=13 id=2 dir=ul
${CM_NSA_UE_14_STATS}              bearer_stats ue=14 id=2 dir=ul
${CM_NSA_UE_15_STATS}              bearer_stats ue=15 id=2 dir=ul
${CM_NSA_UE_16_STATS}              bearer_stats ue=16 id=2 dir=ul
${CM_NSA_UE_17_STATS}              bearer_stats ue=17 id=2 dir=ul
${CM_NSA_UE_18_STATS}              bearer_stats ue=18 id=2 dir=ul

${CM_NOISE_PUSCH_PROFILE_1}                 ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-500
${CM_SINR_TARGET_PUSCH_PROFILE_20}          ul_sinr_testmode_nr profile_id=20 sinr_target_pusch=-350 sinr_target_pucch=-350 sinr_target_preamble=300
${CM_NOISE_PUSCH_CELL1_PROFILE_1_ACT}             cell_testmode_set_nr gnb=2 cell_id=1 testmode=ul_cell_noise profile_id=1 action=activate
${CM_SINR_TARGET_PUSCH_UE11_PROFILE_20_ACT}       ue_testmode_set id=11 profile_index=20 testmode=ul_sinr action=activate

@{CB008235_D_TC_02_PM_LIST}      ${PUSCH_CP_INIRE_VOL_64TBL_MCS30}      ${PUSCH_CP_INIRE_VOL_64TBL_MCS31}

&{PUSCH_CP_INIRE_VOL_64TBL_MCS30}    counter_id=M55304C04030      counter_value=0     condition=GREATER     LOCAL_MOID=MRBTS-1/NRBTS-1/NRCELL-1
&{PUSCH_CP_INIRE_VOL_64TBL_MCS31}    counter_id=M55304C04031      counter_value=0      condition=GREATER     LOCAL_MOID=MRBTS-1/NRBTS-1/NRCELL-1

${VAL_NSA_REG}                             UE performed Registration type INITIAL_REGISTRATION
${VAL_DUAL_CON}                            Successfully reconfigured dual connectivity
${VAL_NSA_DETTACH}                         SgNBReleaseRequestAcknowledge

${VAL_UE_11_NSA_REG}                       UE11: === UE IS ACTIVE (eNB=1, TAI:311:489:222, Open Cell, SGW=1, Attach type: EPS_ATTACH)
${VAL_UE_11_DUAL_CON}                      UE11: Proxy (eNB 2 cell 1) reported successful RA

${VAL_2_UL_DMRS}                           maxLength len2
${VAL_ADDITIONAL_UL_DMRS_POS}              dmrs-AdditionalPosition pos1
${VAL_PUSCHTYPEA_1}                        dmrs-UplinkForPUSCH-MappingTypeA setup
${VAL_PUSCHTYPEA_2}                        mappingType typeA
