*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
Resource          resources/Keywords/CB007292_KW.robot
Suite Setup         Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables ***
${feature}       eCallOverIMS-Support true
${TOPOLOGY}      CLOUD_5G_I_MP_AP_LO
${eventA5}       A5
${phycell_id}    51
${cmd1}    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1
${cmd2}    ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
${radioNetwork}    ngap.radioNetwork
${ims}      ims-voice-eps-fallback-or-rat-fallback-triggered
${freq}     eutraFrequency 1350


*** Test Cases ***
[1][1.0] CB007292_A_1_Verify_gNB_broadcast_SIB1_message_with_IE_eCallOverIMS_Support_as_True_on_the_cell_when_actECallOverIMS_is_enabled_for_cell
    [Tags]     QCD_MN_RAN      QCP_RAN_VRF   QC_28335
    [Documentation]    The purpose of this test case is to verify gNB broadcast SIB1 message with
    ...      IE "eCallOverIMS-Support" as "True" on the cell when /NRBTS/NRCELL/actECallOverIMS
    ...      is enabled for cell.
    [Setup]    Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND      GNB Delta Commission      ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3.json
    sleep    60s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_A_B1_TC1_B2_TC3.cfg
    Read WTS Output Until Pattern Matches    ${feature}    ${Timeout_SA}
    [Teardown]      Run Keywords   GNB Delta Commission      ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3_disable.json
    ...     AND     sleep    60s
    ...     AND     Wait Coam Site to be Ready


[1][1.0] CB007292_A_3_Verify_gNB_is_not_broadcasting_the_IE_eCallOverIMS_Support_in_SIB1_when_actECallOverIMS_is_set_from_True_to_False_in_runtime
    [Documentation]     The purpose of this test case is to verify
    ...             1.When /NRBTS/NRCELL/actECallOverIMS is "true", gNB is broadcast SIB1 message with
    ...             IE "eCallOverIMS-Support" as "True" on the cell.
    ...             2.When /NRBTS/NRCELL/actECallOverIMS is set from "true" to "false" in runtime,
    ...             gNB is not broadasting the IE "eCallOverIMS-Support " in SIB1.
    [Setup]    Run Keywords     Link SCOUT SCF to Configuration ID for Reporting
    ...     AND       GNB Delta Commission      ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3.json
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28336
    sleep    60s
    Wait Coam Site to be Ready
    Start UTE WTS     basic_setup_A_B1_TC1_B2_TC3.cfg
    Read WTS Output Until Pattern Matches    ${feature}    ${Timeout_SA}
    sleep    10s
    GNB Delta Commission      ${CURDIR}/config/scf/Delta_A_B1_TC1_B2_TC3_disable.json
    ${output}    Run Keyword And Expect Error    *read timed out.*    Read WTS Output Until Pattern Matches    ${feature}    ${Timeout_SA}
    Should Match Regexp    ${output}    .*read timed out.*
    [Teardown]    Run Keywords    RAT Block Unblock
    ...     Wait Coam Site to be Ready


[1][1.0] CB007292_B_4_Verify_Successful_initiation_of_Emergency_voice_call_RRCSetup_and_Context_Setup_with_5QI_5_ARP_2_and_PDU_Modify_with_5QI_1_ARP_1
    [Documentation]    The purpose of this test case is to verify the gNB behaviour for the
    ...           successful initiation of the Emergency voice call for a UE in RRC_IDLE state.
    ...           Selected cell allows Normal Service access (Not Limited Service Mode).
    [Setup]  Prepare for CB007292_B1_TC04
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF  QC_28337
    Wait For Next Full Pm Interval
    Verify SIB for gnb 3
    Change UE location    ${UE1}   ${ENB3}  ${CELL1}
    Verify UE registration and pdu setup    ${UE1}
    wtsrunner.ue_im_entry    id=${UE1}     by=ue
    sleep    10s
    Change UE location    ${UE1}   ${ENB2}   ${CELL1}
    Establish Emergency RRCConnection     ${UE1}
    Validate TCP Traffic     ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI1}
    Start pcap collection in gNB CU      name=modified_pdu_add
    Modify PDU session for UE to add    ${UE1}
    ${pcap_file_path}    Stop pcap collection in gNB 7292    ${modified_pdu_add}    ${Log_Path}
    Verify QFI from PCAP     ${pcap_file_path}    ${pdu_5qi}    ${arp}
    Validate Traffic with RTP    ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI2}
    log to console    \n Deleting QFI 2
    Start pcap collection in gNB CU     name=modified_pdu_delete
    Modify PDU session for UE to delete    ${UE1}
    ${pcap_file_path}    Stop pcap collection in gNB 7292   ${modified_pdu_delete}     ${Log_Path}
    Verify Qos deleted from PCAP     ${pcap_file_path}     ${qosflowdel}     ${qos}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C01004   1     NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C04001   1     NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05501   1     NNGCC_UE_CTXT_STP_REQ_EC_RECD
    ...     M55125C05502    1    NNGCC_UE_CTXT_STP_RESP_EC_SENT
    ...     M55125C05509    2    NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     M55125C05505    0    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    0    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB007292_B1_TC04


[1][1.0] CB007292_B_8_Verify_Successful_Emergency_voice_call_Intra-gNB_Intra_DU_Handover_with_multiple_Emergency_ARP_values
    [Documentation]    This user scenario describes the gNB behaviour for the successful
    ...          Emergency call Intra-gNB Intra-DU Handover with multiple Emergency ARP values.
    [Setup]     Prepare for CB007292_B_B2_TC08
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28338
    Verify SIB for gnb 3
    Change UE location    ${UE1}   ${ENB3}   ${CELL1}
    Verify UE registration and pdu setup    ${UE1}
    wtsrunner.ue_im_entry    id=${UE1}     by=ue
    sleep    10s
    Change UE location    ${UE1}   ${ENB2}   ${CELL1}
    Wait For Next Full Pm Interval
    Establish Emergency RRCConnection     ${UE1}
    Validate TCP Traffic     ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI1}
    Start pcap collection in gNB CU     name=modified_pdu_add
    Modify PDU session for UE to add    ${UE1}
    ${pcap_file_path}    Stop pcap collection in gNB 7292     ${modified_pdu_add}    ${Log_Path}
    Verify QFI from PCAP     ${pcap_file_path}    ${pdu_5qi}    ${arp}
    Validate Traffic with RTP    ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI2}
    ${measId}    Display Measurement Configuration for UE    ${UE1}    ${eventA5}
    Trigger A5 Measurement      ${UE1}    ${measId}    ${phycell_id}
    Displays bearer statistics      ${UE1}    ${QFI1}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C01004   1     NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C04001   1     NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05501   1     NNGCC_UE_CTXT_STP_REQ_EC_RECD
    ...     M55125C05502    1    NNGCC_UE_CTXT_STP_RESP_EC_SENT
    ...     M55125C05509    1    NNGCC_PDUSESMODREQ_EC_RECDs
    ...     M55125C05510    1    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     M55125C05505    0    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    0    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55147C00504    1    HO_PREP_EMERGENCY_SENT
    ...     M55147C00501    1    ATT_HO_EMERGENCY
    ...     M55147C00503    1    SUCC_HO_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    [Teardown]     Teardown for CB007292_B_B2_TC08


[1][1.0] CB007292_B_15_Verify_gNB_preventing_Emergency_call_with_multiple_Emergency_ARP_values_into_RRC_INACTIVE_state_suspend_Inactivity based
    [Documentation]     The purpose of this test case is to verify the gNB behaviour for preventing Emergency call into
    ...   RRC_INACTIVE state suspend- Inactivity based (Emergency condition with multiple Emergency ARP values).
    ...   UE with Emergency call(5QI-5) will be released to RRC_IDLE state.
    [Setup]     Prepare for CB007292_B_B4_TC15
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28343
    Wait For Next Full Pm Interval
    ${result}    Catenate  ${cmd1}    ${cmd2}
    Run     ${result}
    Log to Console     \n Verifying SIBs from RAN SIM
    Verify SIB for gnb 3
    Change UE location    ${UE1}   ${ENB3}   ${CELL1}
    Verify UE registration and pdu setup    ${UE1}
    wtsrunner.ue_im_entry    id=${UE1}     by=ue
    sleep    10s
    Change UE location    ${UE1}   ${ENB2}   ${CELL1}
    Establish Emergency RRCConnection     ${UE1}
    Validate TCP Traffic     ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI1}
    Start pcap collection in gNB CU     name=modified_pdu_add
    Modify PDU session for UE to add    ${UE1}
    ${pcap_file_path}    Stop pcap collection in gNB 7292   ${modified_pdu_add}     ${Log_Path}
    Verify QFI from PCAP     ${pcap_file_path}    ${pdu_5qi}    ${arp}
    Validate Traffic with RTP    ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI2}
    Start pcap collection in gNB CU     name=modified_pdu_delete
    Modify PDU session for UE to delete    ${UE1}
    ${pcap_file_path}    Stop pcap collection in gNB 7292  ${modified_pdu_delete}     ${Log_Path}
    Verify Qos deleted from PCAP     ${pcap_file_path}     ${qosflowdel}     ${qos}
    stop TCP Traffic     ${UE1}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C01004   1     NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C04001   1     NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05501   1     NNGCC_UE_CTXT_STP_REQ_EC_RECD
    ...     M55125C05502    1    NNGCC_UE_CTXT_STP_RESP_EC_SENT
    ...     M55125C05509    2    NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     M55125C00503    1    NNGCC_UE_CTXT_REL_REQ_INACTIVE
    ...     M55125C00501    1    NNGCC_UE_CTXT_REL_CMD_RECD
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    [Teardown]    Teardown for CB007292_B_B4_TC15


[1][1.0] CB007292_B_44_Verify_Unsuccessful_setup_of_Emergency_voice_call_5QI_1_AC_failure_with_EPS_fallback_redirection_RRC_release_with_redirect
    [Setup]     Prepare for CB007292_B_EC1_TC44
    [Tags]   QC_28340     QCD_MN_RAN      QCP_RAN_VRF
    Verify SIB for gnb 3
    Wait For Next Full Pm Interval
    Change UE location    ${UE1}   ${ENB3}  ${CELL1}
    Verify UE registration and pdu setup    ${UE1}
    wtsrunner.ue_im_entry    id=${UE1}     by=ue
    sleep    10s
    Change UE location    ${UE1}   ${ENB2}   ${CELL1}
    Establish Emergency RRCConnection     ${UE1}
    wtsrunner.sim_log_set
    Validate TCP Traffic     ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI1}
    Start pcap collection in gNB CU      name=modified_pdu_add
    Modify PDU session should fail    ${UE1}    ${freq}
    ${pcap_file_path}    Stop pcap collection in gNB 7292    ${modified_pdu_add}    ${Log_Path}
    ${pdml_file}    Convert PCAP to PDML     ${pcap_file_path}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C01004    1     NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C04001    1     NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05501    1     NNGCC_UE_CTXT_STP_REQ_EC_RECD
    ...     M55125C05502    1     NNGCC_UE_CTXT_STP_RESP_EC_SENT
    ...     M55125C05509    1     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55124C04002    1    NR_RRC_RELEASE_REDIR_EC_LTE
    ...     M55124C03501    0    NR_RRC_RELEASE_REDIR_EF_LTE
    ...     M55124C02501    0    NR_RRC_RELEASE_REDIR_VFB_LTE
    ...     M55125C05511    1    NNGCC_PDUSESMOD_FAIL_EC_SENT
    ...     M55125C05510    0    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     M55125C05505    0    NNGCC_PDU_SES_STP_REQ_EC_RECD
    ...     M55125C05506    0    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
    [Teardown]   Teardown for CB007292_B_EC1_TC44