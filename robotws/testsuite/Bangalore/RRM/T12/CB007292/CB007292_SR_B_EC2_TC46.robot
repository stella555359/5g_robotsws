*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the gNB behaviour for the unsuccessful
...             initiation of the Emergency voice call for UE in idle state.
Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables  ***
${radioNetwork}    ngap.radioNetwork
${fail_msg}    Deleted Unsuccessful QosFlow QFI:2
${TOPOLOGY}     CLOUD_5G_I_LO_AP_LO


*** Test Cases ***
[1][1.0] CB007292_B_46_Verify_Unsuccessful_setup_of_Emergency_voice_call_5QI_1_AC_failure_with_Radio_Resources_Not_Available
    [Setup]    Prepare for CB007292_B_EC2_TC46
    [tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28341
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
    Modify PDU session should fail    ${UE1}    ${fail_msg}
    ${pcap_file_path}    Stop pcap collection in gNB 7292    ${modified_pdu_add}    ${Log_Path}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C01004   1     NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C04001   1     NRRCC_RRC_STPSUCC_EMERGENCY
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
