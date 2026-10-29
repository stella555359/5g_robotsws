*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
#RAD PARAMETERS OF GNB
#enabledNewCeFrameworkFlagInDu
#0x8000A6=0
#0 ? false ; 1 ? true ? check
#rdTriggerEcpri72eInterfaceSplit
#0x580964=1
#rdSuUeReceiverSize
#0x580935=16
&{GNB_RAD_PARAM}      0x8000A6=0
...                               0x580964=1
...                               0x580935=16
${Log_Path}                        /home/ute/logs
${CFG_CB010708_GNB_SCF}            ${CURDIR}/../../config/gnb/CFG_CB010708_GNB_SCF.xml
${CFG_CB010708_AP_IPHY}            ${CURDIR}/../../config/ap/CB008235_A_IPHY.xml
${CFG_CB010708_WTS_CFG}            ${CURDIR}/../../config//wts/CB008235_A.cfg
${CFG_CB01708_WTS_RANK1_CFG}       ${CURDIR}/../../config//wts/CB008235_A_RANK1.cfg
${CFG_BSR}                         ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${CM_UL_BEAM_POS_PROFILE_1}        ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=0,20 zenith=0,0 power=-300,-300
${CM_UL_BEAM_POS_PROFILE_2}        ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=32,57 zenith=-32,-32 power=-250,-250
${CM_UL_BEAM_POS_PROFILE_3}        ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=32,57 zenith=-32,-32 power=-250,-250
${CM_UL_BEAM_PROFILE_1_ACT}        ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=1 action=activate
${CM_UL_BEAM_PROFILE_2_ACT}        ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=2 action=activate
${VAL_UL_SUBCELLTYPE_C8_4}         ulSubcellType:SUBCELLTYPE_C8_4
${VAL_UE2_DEREG_REL}               AMF-1: UE CONTEXT RELEASE COMPLETE
${CM_UE_1_STATS}                   ue_stats_nr id=1 type=pusch
${CM_UE_2_STATS}                   ue_stats_nr id=2 type=pusch
${CM_UE_3_STATS}                   ue_stats_nr id=3 type=pusch
${CM_UE_4_STATS}                   ue_stats_nr id=4 type=pusch
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_1_UL_DATA_trf_id_2}        trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=2
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE_2_REGISTER}                ue_register id=2
${CM_UE_2_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE_2_UL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_2_UL_DATA_trf_id_2}        trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=150 trf_id=2
${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off
${CM_UE3_DTYPE_INTERNAL}           set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE_3_REGISTER}                ue_register id=3
${CM_UE_3_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${CM_UE_3_UL_DATA}                 trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_3_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off
${CM_UE4_DTYPE_INTERNAL}           set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE_4_REGISTER}                ue_register id=3
${CM_UE_4_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${CM_UE_4_UL_DATA}                 trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_4_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off
