*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***
${CFG_GNB_SCF_DELTA_JSON}          scf_basic_call.xml
#${CFG_GNB_SCF}                     ${CURDIR}/../../config/gnb/scf_basic_call.xml
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_basic_call.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_setup.cfg
${Log_Path}                        /home/ute/logs
${CM_UE1_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE2_DTYPE_INTERNAL}           set_pdu_param ue=2 pdu=1 trf_type=internal
${CM_UE3_DTYPE_INTERNAL}           set_pdu_param ue=3 pdu=1 trf_type=internal
${CM_UE_1_REGISTER}                ue_register id=1
${CM_UE_1_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1

${CM_UE_1_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_1_DL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_2_UL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_2_DL_DATA}                 trf_data_start ue=2 pdu=1 qfi=1 dir=dl mbps=10 trf_id=1
${CM_UE_3_UL_DATA}                 trf_data_start ue=3 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1
${CM_UE_3_DL_DATA}                 trf_data_start ue=3 pdu=1 qfi=1 dir=dl mbps=10 trf_id=1
${UE1_DRB_drop_1st_time}           dlrlcdrop_testmode_nr profile_id=1 lcid=4 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE2_DRB_drop_1st_time}           dlrlcdrop_testmode_nr profile_id=2 lcid=4 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE3_DRB_drop_1st_time}           dlrlcdrop_testmode_nr profile_id=3 lcid=4 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE1_DRB_drop_2nd_time}           dlrlcdrop_testmode_nr profile_id=4 lcid=4 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE2_DRB_drop_2nd_time}           dlrlcdrop_testmode_nr profile_id=5 lcid=4 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE3_DRB_drop_2nd_time}           dlrlcdrop_testmode_nr profile_id=6 lcid=4 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE1_SRB2_drop_1st_time}           dlrlcdrop_testmode_nr profile_id=1 lcid=2 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE2_SRB2_drop_1st_time}           dlrlcdrop_testmode_nr profile_id=2 lcid=2 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE3_SRB2_drop_1st_time}           dlrlcdrop_testmode_nr profile_id=3 lcid=2 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE1_SRB2_drop_2nd_time}           dlrlcdrop_testmode_nr profile_id=4 lcid=2 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE2_SRB2_drop_2nd_time}           dlrlcdrop_testmode_nr profile_id=5 lcid=2 num_of_times_to_drop=32 sn=0xFFFFFFFF
${UE3_SRB2_drop_2nd_time}           dlrlcdrop_testmode_nr profile_id=6 lcid=2 num_of_times_to_drop=32 sn=0xFFFFFFFF

${UE1_DRB_drop_1st_time_activate}  ue_testmode_set_nr id=1 profile_id=1 testmode=dlrlcdrop action=activate
${UE1_DRB_drop_2nd_time_activate}  ue_testmode_set_nr id=1 profile_id=4 testmode=dlrlcdrop action=activate
${UE2_DRB_drop_1st_time_activate}  ue_testmode_set_nr id=2 profile_id=2 testmode=dlrlcdrop action=activate
${UE2_DRB_drop_2nd_time_activate}  ue_testmode_set_nr id=2 profile_id=5 testmode=dlrlcdrop action=activate
${UE3_DRB_drop_1st_time_activate}  ue_testmode_set_nr id=3 profile_id=3 testmode=dlrlcdrop action=activate
${UE3_DRB_drop_2nd_time_activate}  ue_testmode_set_nr id=3 profile_id=6 testmode=dlrlcdrop action=activate
${UE1_SRB2_drop_1st_time_activate}  ue_testmode_set_nr id=1 profile_id=1 testmode=dlrlcdrop action=activate
${UE1_SRB2_drop_2nd_time_activate}  ue_testmode_set_nr id=1 profile_id=4 testmode=dlrlcdrop action=activate
${UE2_SRB2_drop_1st_time_activate}  ue_testmode_set_nr id=2 profile_id=2 testmode=dlrlcdrop action=activate
${UE2_SRB2_drop_2nd_time_activate}  ue_testmode_set_nr id=2 profile_id=5 testmode=dlrlcdrop action=activate
${UE3_SRB2_drop_1st_time_activate}  ue_testmode_set_nr id=3 profile_id=3 testmode=dlrlcdrop action=activate
${UE3_SRB2_drop_2nd_time_activate}  ue_testmode_set_nr id=3 profile_id=6 testmode=dlrlcdrop action=activate
${UE1_SRB2_message_send_1st_time}   ue_send_dl_nas_transport id=1 nas_pdu_type=configuration_update_command
${UE1_SRB2_message_send_2nd_time}   ue_send_dl_nas_transport id=1 nas_pdu_type=configuration_update_command
${UE2_SRB2_message_send_1st_time}   ue_send_dl_nas_transport id=2 nas_pdu_type=configuration_update_command
${UE2_SRB2_message_send_2nd_time}   ue_send_dl_nas_transport id=2 nas_pdu_type=configuration_update_command
${UE3_SRB2_message_send_1st_time}   ue_send_dl_nas_transport id=3 nas_pdu_type=configuration_update_command
${UE3_SRB2_message_send_2nd_time}   ue_send_dl_nas_transport id=3 nas_pdu_type=configuration_update_command


${QOS_modify_7}                    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=7 by=amf
${QOS_modify_8}                    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=8 by=amf
${QOS_modify_9}                    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=9 by=amf
${EMR_CALL}                        ue_regiter id=2 type=emergency
${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off
${CM_UE_2_DEREG}                   ue_deregister id=2 ue_deregister_type=switch_off
${CM_UE_3_DEREG}                   ue_deregister id=3 ue_deregister_type=switch_off

${CM_UE2_RRC_SETUP_HPA}            ue_nr_rrc_setup_param id=2 establishment_cause=highPriorityAccess
${CM_UE3_RRC_SETUP_EMR}            ue_nr_rrc_setup_param id=3 establishment_cause=emergency
${CM_UE2_REGISTER}                 ue_register id=2
${CM_UE3_REGISTER}                 ue_register id=3
${CM_UE2_PDU_SESSION}              ue_pdu_session_setup pdu=1 ue=2 nwslice=1 gw=1
${CM_UE3_PDU_SESSION}              ue_pdu_session_setup pdu=1 ue=3 nwslice=1 gw=1
${VAL_UE2_DEREG_REL}               UE2: detached
${VAL_UE3_DEREG_REL}               UE3: detached
${UE1_intra_cell_HO}               UE1: Intra-cell handover (key refresh) performed
${UE2_intra_cell_HO}               UE2: Intra-cell handover (key refresh) performed
${UE3_intra_cell_HO}               UE3: Intra-cell handover (key refresh) performed

${Inter_gNB_HO}                    ue_measurement_send_nr id=1 meas_id=1 event=A3 srsrp_nr=30  phycell_id=54 nrsrp_nr=60
${RRC_setup_req_HPA}               establishmentCause highPriorityAccess
${RRC_setup_req_EMR}               establishmentCause emergency
${SR_UL_resource}                  schedulingRequestResourceToAddModList
${XN_HO_success}                   XN Handover Successfully completed at Target
${QOS_flow_setup}                  Setup QosFlow with QFI
${FILTER_B005}                     uldata_puschreceiverespps || uldata_puschreceivereq
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv
${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2
