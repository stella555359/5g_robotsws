*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the gNB behaviour for preventing Emergency call into
...             RRC_INACTIVE state suspend- Inactivity based (Emergency condition with multiple Emergency ARP values).
...             UE with Emergency call(5QI-5) will be released to RRC_IDLE state.
Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables  ***
${cmd1}    amf_ue_ics_param id=1 ue=1 core_network_assistance_info=on ue_identity_index_value=1
${cmd2}    ue_specific_drx=64 periodic_registration_update_timer=5:1min plmn_id=311:489 tac_id=200
${TOPOLOGY}     CLOUD_5G_O_E_AP_LOO


*** Test Cases ***
[1][1.0] CB007292_B_15_Verify_gNB_preventing_Emergency_call_with_multiple_Emergency_ARP_values_into_RRC_INACTIVE_state_suspend_Inactivity based
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
