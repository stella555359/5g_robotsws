*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the gNB behaviour for the unsuccessful initiation of
...             the Emergency voice call for UE in idle state.
Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables  ***
${radioNetwork}    ngap.radioNetwork
${ims}             ims-voice-eps-fallback-or-rat-fallback-triggered
${freq}            eutraFrequency 1350
${TOPOLOGY}        CLOUD_5G_O_E_AP_LOO


*** Test Cases ***
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
