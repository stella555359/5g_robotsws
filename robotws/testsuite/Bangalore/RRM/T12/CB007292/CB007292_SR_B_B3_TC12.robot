*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the gNB behaviour
...                        for the successful Emergency voice call intra-gNB RRC re-establishment
...                        with multiple Emergency ARP values.

Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables ***
${TOPOLOGY}     CLOUD_5G_I_LO_AP_LO


*** Test Cases ***
[1][1.0] CB007292_B_12_Verify_Successful_Emergency_voice_call_intra_gNB_RRC_re_establishment_with_multiple_Emergency_ARP_values
    [setup]     Prepare for CB007292_B_B3_TC12
    [tags]    QCD_MN_RAN      QCP_RAN_VRF    QC_28339
    Wait For Next Full Pm Interval
    Verify SIB for gnb 3
    Change UE location    ${UE1}   ${ENB3}   ${CELL1}
    Verify UE registration and pdu setup    ${UE1}
    wtsrunner.ue_im_entry    id=${UE1}     by=ue
    sleep    10s
    Change UE location    ${UE1}   ${ENB2}   ${CELL1}
    Establish Emergency RRCConnection     ${UE1}
    Validate TCP Traffic     ${UE1}
    Displays bearer statistics      ${UE1}    ${QFI1}
    Modify PDU session for UE to add    ${UE1}
    Validate Traffic with RTP    ${UE1}
    ue_rrc_reestablish    id=1   gnb=2    cell=1    cause=otherFailure
    read wts output until pattern matches     rrcReestablishmentComplete     30
    sleep    10s
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55124C01004   1     NRRCC_RRC_STPREQ_EMERGENCY
    ...     M55124C04001   1     NRRCC_RRC_STPSUCC_EMERGENCY
    ...     M55125C05501   1     NNGCC_UE_CTXT_STP_REQ_EC_RECD
    ...     M55125C05502    1    NNGCC_UE_CTXT_STP_RESP_EC_SENT
    ...     M55125C05509    1   NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    1    NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     M55125C05506    0    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55124C01024    0    NRRCC_RRC_STPREJ_EMERGENCY
    ...     M55124C00512    1    REESTAB_ACC_OTHER_FAIL
    ...     M55124C00505    1    RRC_REESTAB_OTHER_FAILURE
    ...     M55124C00516    1    REESTAB_RRCRECONFIG_SUCC
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55127C00004    1    NRRCD_RRC_STPREQ_EMERGENCY
    ...     M55127C00503    1    RRC_REESTAB_OTHER_FAILURE_DU
    ...     M55127C00512    1    REESTAB_ACC_OTHER_FAIL_DU
    ...     local_moid=MRBTS-1/NRBTS-1/NRDU-1
    ...     file_path=${pm_counter_file}
