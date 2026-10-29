*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}          config_2ssb_scf.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_2ssb.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_2ssb.cfg
${CFG_CB0012192_WTS_CFG_12192_TC02}             ${CURDIR}/../../config/wts/basic_setup_12192_4RACH.cfg
${CFG_AP_IPHY_4ssb}                     ${CURDIR}/../../config/ap/iphy_4ssb.xml
${CFG_GNB_SCF_DELTA_JSON_4ssb}        4ssb_scf.xml
${Log_Path}                        /home/ute/logs
${CM_UL_BEAM_POS_PROFILE_1}        beam_control_testmode_nr profile_id=1
...     ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
${CM_UL_BEAM_POS_PROFILE_2}        beam_control_testmode_nr profile_id=3
...     ueBeamIndexInitial=0,1,2,3,4,5 ssbeam_bestbeam=0 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
${CM_UL_BEAM_POS_PROFILE_3}        beam_control_testmode_nr profile_id=5
...     ueBeamIndexInitial=1,0,2,3,4,5 ssbeam_bestbeam=1 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125
${CM_UL_BEAM_POS_PROFILE_4}        beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=1,0,2,3,4,5
...     ssbeam_bestbeam=1 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120
${CM_UL_BEAM_PROFILE_1_ACT}        ue_testmode_set_nr id=1 testmode=beam_control action=activate
...     profile_id=1 beamaction=attach
${CM_UL_BEAM_PROFILE_2_ACT}        ue_testmode_set_nr id=3 testmode=beam_control action=activate
...     profile_id=3 beamaction=attach
${CM_UL_BEAM_PROFILE_3_ACT}        ue_testmode_set_nr id=5 testmode=beam_control action=activate
...     profile_id=5 beamaction=attach
${CM_UL_BEAM_PROFILE_4_ACT}        ue_testmode_set_nr id=7 testmode=beam_control action=activate
...     profile_id=7 beamaction=attach
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=150 trf_id=1
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off

