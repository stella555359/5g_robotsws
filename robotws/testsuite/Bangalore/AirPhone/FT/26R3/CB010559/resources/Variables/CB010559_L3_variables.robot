*** Settings ***
Documentation    :copyright       : Nokia
                 ...              :author       : Vadivelan Manickavasagam
                 ...              :contact      : vadivlean.manickavasagam@nokia.com
                 ...              :Description  : This file contains
                 ...                              Variables related to CB008235 only
                 ...              :history change, <date>,<who>,<what and how>
                 ...              :Drafted,11.01.2025,vadivelan.manickavasagam@nokia.com


*** Variables ***

${XnAP_gNB3_Link}                  GNB-3: XnAP Link with GNB-2
${XnAP_gNB4_Link}                  GNB-4: XnAP Link with GNB-2
${Retrieve_context_req}            GNB-1: Message:xnap::RetrieveUEContextRequest sent to GNB-2
${Recv_rtriv_UE_cntxt_req}         GNB-2: Received RetrieveUEContextRequest

${CFG_GNB_SCF_DELTA_JSON}          ${CURDIR}/../../config/gnb/Configuration_PortChanage_UTE5GCLASSICAL1733_20250818_0925.xml
${CB010559_CFG_GNB_SCF_DELTA_JSON}              CB010559_TC01_gnB_SCF_Check.xml
${CB010559_CFG_GNB_SCF_1}          ${CURDIR}/../../config/gnb/CB010559_TC01_gnB_SCF_Check.xml
${CB010559_CFG_GNB_SCF_2}          ${CURDIR}/../../config/gnb/CB010559_TC02_gnB_SCF_Check.xml
${SCF_10559_2RAN_1REAL}            ${CURDIR}/../../config/gnb/scf_10559_2ran_1real.xml
${IPHY_10559_2RAN_1REAL}           ${CURDIR}/../../config/ap/iphy_10559_2ran_1real.xml
${CFG_10559_2RAN_1REAL}            ${CURDIR}/../../config/wts/basic_call_bm45_10559_2ran_1real.cfg
${CFG_AP_IPHY}                     ${CURDIR}/../../config/ap/iphy_portchange_basiccall_bm45.xml
${CB010559_CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/CB010559_call_bm45_10559.cfg
${CB010559_CFG_AP_IPHY}             ${CURDIR}/../../config/ap/CB011059_AP_TC01_iphy.xml
${CFG_WTS_CFG}                     ${CURDIR}/../../config/wts/basic_call_Chandra_bm45_10559.cfg
${CFG_AP_StoR_IPHY}                ${CURDIR}/../../config/ap/iphy_10559_StoR.xml
${CFG_WTS_StoR_CFG}                ${CURDIR}/../../config/wts/basic_call_bm45_10559_ran_to_real.cfg

${CB010559_CFG_AP_IPHY_TC02}             ${CURDIR}/../../config/ap/CB011059_AP_TC02_iphy.xml
${CFG_WTS_CFG_TC02}                     ${CURDIR}/../../config/wts/CB010559_10559_ran_to_real.cfg

${Log_Path}                        /home/ute/logs
${X2_Link}                         enb_x2_link_up enb=1 target=3
${X2_Link_StoR}                    enb_x2_link_up enb=2 target=3
${Xn_on_check}                     trace enb=1 protocol=xn on

${Xn_Link1}                        gnb_ue_rrc_reestablish_param ue=1 gnb_id=3 action=trigger_xnap_retrieve_ue_context_req
${Xn_Link2}                        gnb_ue_rrc_reestablish_param ue=1 gnb_id=4 action=trigger_xnap_retrieve_ue_context_req

${Retrieve_UE1-5_Context_Req}         gnb_ue_rrc_reestablish_param ue=1 gnb_id=1 action=trigger_xnap_retrieve_ue_context_req
${Retreive_UE1-5_Context_Req_Param}   gnb_ue_retrieve_ue_context_req_param ue_id=1 gnb_id=1 pci=18:0 crnti=1011010000010011
...       short_mac_i=10101 new_ng_ran_cell_id=311:389|1
${CM_UE1-5_DTYPE_INTERNAL}           set_pdu_param ue=1 pdu=1 trf_type=internal
${CM_UE_1-5_REGISTER}                ue_register id=1
${CM_UE_1-5_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CM_UE_1-5_UL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_1-5_DL_DATA}                 trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=50 trf_id=1
${UE1-5_RRC_Restablish_with_Ransim}         ue_rrc_reestablish id=1 gnb=1 cell=1

${Retrieve_UE6-10_Context_Req}         gnb_ue_rrc_reestablish_param ue=6-10 gnb_id=1 action=trigger_xnap_retrieve_ue_context_req
${Retreive_UE6-10_Context_Req_Param}   gnb_ue_retrieve_ue_context_req_param ue_id=6-10 gnb_id=1 pci=18:0 crnti=1011010000010011
...           short_mac_i=10101 new_ng_ran_cell_id=311:389|1
${CM_UE6-10_DTYPE_INTERNAL}           set_pdu_param ue=6-10 pdu=1 trf_type=internal
${CM_UE_6-10_REGISTER}                ue_register id=6-10
${CM_UE_6-10_PDU_SESSION}             ue_pdu_session_setup pdu=1 ue=6-10 nwslice=1 gw=1
${CM_UE_6-10_UL_DATA}                 trf_data_start ue=6-10 pdu=1 qfi=1 dir=ul mbps=50 trf_id=1
${CM_UE_6-10_DL_DATA}                 trf_data_start ue=6-10 pdu=1 qfi=1 dir=dl mbps=50 trf_id=1
${UE6-10_RRC_Restablish_with_Ransim}    ue_rrc_reestablish id=6-10 gnb=1 cell=1

${UE_Retrieve}                     gnb_ue_retrieve_ue_context_resp_param gnb_id=2 ue_id=1
${RRC_Reestablish}                 ue_rrc_reestablish id=1 gnb=1 cell=1
${RRC_Reestablish_gnb3}            ue_rrc_reestablish id=1 gnb=3 cell=1


${CM_UE_1_DEREG}                   ue_deregister id=1 ue_deregister_type=switch_off

#CB010559 TC02

${CB010559_Trace_xn_check}                 trace enb=2 protocol=xn on
${CB010559_gNB_Param_check}                gnb_param id=2 srb1_rlc_sn_field_size=size_12
${CB010559_barrer_ul}                      bearer_stats ue=1 pdu=1 qfi=1 dir=ul
${CB010559_barrer_dl}                      bearer_stats ue=1 pdu=1 qfi=1 dir=dl
${CB010559_RRC_REESTABLISH}                ue_rrc_reestablish id=1 gnb=1 cell=1
${CB010559_SET_PDU_INTERNAL}               set_pdu_param ue=1 pdu=1 trf_type=internal
${CB010559_UE_REGISTER}                    ue_register id=1
${CB010559_UE_PDU_SESSION}                 ue_pdu_session_setup pdu=1 ue=1 nwslice=1 gw=1
${CB010559_UE_SUMMARY}                     ue_summary
${CB010559_UE_RETRIEVE_UE}                 gnb_ue_retrieve_ue_context_resp_param gnb_id=2 ue_id=1
${CB010559_TC02_TRF_UL}                    trf_data_start pdu=1 dir=ul mbps=1  ue=1 trf_id=1
${CB010559_TC02_TRF_DL}                    trf_data_start pdu=1 dir=dl mbps=1  ue=1 trf_id=2

##CB010559 Validation prints

${CB010559_rrcReestablishmentRequest}               rrcReestablishmentRequest :
${CB010559_RetrieveUEContextRequest_check}          Message:xnap::RetrieveUEContextRequest sent to GNB-2
${CB010559_RetrieveUEContextResponse_check}          GNB-1: Received RetrieveUEContextResponse
${CB010559_C1_rrcReestablishmentComplete_check}               rrcReestablishmentComplete
${CB010559_C1_rrcReconfiguration_check}                       rrcReconfiguration
${CB010559_CTRL_ADD_MOD_RB_check}                    GNB-1: CTRL_ADD_MOD_RB received for UeId 1, LCID 4, RBID 4
${CB010559_XnUAddressIndication_check}               GNB-1: UE1: XnUAddressIndication Message Sent to Target
${CB010559_PATH_SWITCH_REQUEST_Check}                GNB-1: UE1: PATH_SWITCH_REQUEST Sent
${CB010559_PATH_SWITCH_REQUEST_ACK_Check}            GNB-1: UE1: PATH_SWITCH_REQUEST_ACK Received
${CB010559_UEContextRelease_Check}                   GNB-1: Message:xnap::UEContextRelease sent
${CB010559_rrcReconfigurationComplete_Check}         message c1 : rrcReconfigurationComplete :

#CB010559 TC02 validation check

${CB010559_TC02_RRC_Reestablishment}                 RRC Reestablishment sucessfully completed
${CB010559_TC02_PATH_SWITCH_REQUEST_Check}           PATH SWITCH REQUEST
${CB010559_TC02_rrcReconfiguration}                  message c1 : rrcReconfigurationComplete :
${CB010559_TC02_RetriveUE}                           GNB-2: Message:xnap::RetrieveUEContextResponse sent to GNB-1


${FILTER_B005}                     uldata_puschreceiverespps || uldata_puschreceivereq
${BIP_CSV_NAME}                    BIP_L1L2_filter_SCN1.csv
${MCSHARK_PLUGIN}                  /home/ute/wireshark/plugins
${tashark_version}                 4.2
${BSR_FILE_AVQL}                   ${CURDIR}/../../config/gnb/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip
${BSR_FILE_AVQL_PASS}              /home/ute/Desktop/12_01_worked_CB011059/BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002.zip

