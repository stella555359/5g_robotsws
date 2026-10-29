*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Keerthi.Chittoor
                 ...              :contact      : keerthichittoor@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB009849 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,12.05.2025,keerthi.chittoor@nokia.com

*** Variables ***
${Log_Path}                              /home/ute/logs
${CB009849_A2_TC_01_GNB_SCF}          9849_A2_SCF.xml
${CB009849_A2_TC_01_IPHY}             ${CURDIR}/../../config/ap/CB009849_iphy.xml
${CB009849_A2_TC_01_WTS}              ${CURDIR}/../../config/wts/CB009849_A2_wts.cfg
${CB009849_D_iphy}                    ${CURDIR}/../../config/ap/CB009849_D_iphy.xml
${CB009849_D_wts.cfg}                 ${CURDIR}/../../config/wts/CB009849_D_wts.cfg
${CB009849_D_SCF}                     9849_D_scf.xml

${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA_START}           trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=5 trf_id=1
${CM_UE_1_DL_DATA_START}           trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=5 trf_id=1
${CM_UE_1_UL_DATA_STOP}            trf_data_stop ue=1 pdu=1 qfi=1 dir=ul trf_id=1
${CM_UE_1_DL_DATA_STOP}            trf_data_stop ue=1 pdu=1 qfi=1 dir=dl trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE_1_UL_BEARER_STATS}         bearer_stats ue=1 pdu=1 qfi=1 dir=ul
${CM_UE_1_DL_BEARER_STATS}         bearer_stats ue=1 pdu=1 qfi=1 dir=dl
${CM_UE_1_PDU_Mod_5QI5}            ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=2 by=amf
${CM_UE_1_PDU_Mod_5QI1}            ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=3 by=amf
${CM_UE_1_PDU_Rel_5QI5}            ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=2
${CM_UE_1_PDU_Rel_5QI1}            ue_pdu_session_modify ue=1 pdu=1 qosflows_to_del=3

${CM_UE_1_UL_SINR_TARGET_PUSCH}         ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-30
${CM_UE_1_UL_SINR_PATHLOSS}             ul_sinr_testmode_nr profile_id=2 pathloss=135
${CM_UE_1_UL_SINR_ACT_1}                ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
${CM_UE_1_UL_SINR_ACT_2}                ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=2

${CM_UE_1_REV_UL_SINR_TARGET_PUSCH}     ul_sinr_testmode_nr profile_id=3 sinr_target_pusch=10
${CM_UE_1_REV_UL_SINR_PATHLOSS}         ul_sinr_testmode_nr profile_id=4 pathloss=28
${CM_UE_1_UL_SINR_ACT_3}                ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=3
${CM_UE_1_UL_SINR_ACT_4}                ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=4

${VAL_UE1_UL_Data}                      UE 1: UDP UL TRF:
${VAL_UE1_DL_Data}                      UE 1: UDP DL TRF:
${VAL_UE1_UL_STATS}                     UE 1, pdu 1, qfi 1: UL
${VAL_UE1_DL_STATS}                     UE 1, pdu 1, qfi 1: DL
${VAL_UE1_RRC_RECON_COM}                rrcReconfigurationComplete
${VAL_UE1_TP_ENABLED}                   transformPrecoder enabled
${VAL_UE1_TP_DISABLED}                  transformPrecoder disabled
${VAL_UE1_PDU_Mod_5QI5}                 Added QosFlow with QFI:2 fiveQI:5
${VAL_UE1_PDU_Mod_5QI1}                 Added QosFlow with QFI:3 fiveQI:1
${VAL_UE1_VONRDRX}                      drx-Config setup
