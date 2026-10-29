*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the gNB behaviour for the
...                        successful initiation of the Emergency voice call for a UE in RRC_IDLE state.
...                        Selected cell allows Normal Service access (Not Limited Service Mode).
Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables ***
${TOPOLOGY}     CLOUD_5G_O_E_AP_LOO


*** Test Cases ***
[1][1.0] CB007292_B_4_Verify_Successful_initiation_of_Emergency_voice_call_RRCSetup_and_Context_Setup_with_5QI_5_ARP_2_and_PDU_Modify_with_5QI_1_ARP_1
    [Setup]      Prepare For CB007292 B1 TC04
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
