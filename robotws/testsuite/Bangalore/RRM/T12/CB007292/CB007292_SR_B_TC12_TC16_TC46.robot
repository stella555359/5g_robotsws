*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the gNB behaviour
...                        for the successful Emergency voice call intra-gNB RRC re-establishment
...                        with multiple Emergency ARP values.

Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables ***
${TOPOLOGY}        CLOUD_5G_O_E_AP_LOO
${radioNetwork}    ngap.radioNetwork
${fail_msg}        Deleted Unsuccessful QosFlow QFI:2


*** Test Cases ***
[1][1.0] CB007292_B_12_Verify_Successful_Emergency_voice_call_intra_gNB_RRC_re_establishment_with_multiple_Emergency_ARP_values
    [Setup]     Prepare for CB007292_B_B3_TC12
    [Tags]    QCD_MN_RAN      QCP_RAN_VRF    QC_28339
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
    [Teardown]   Teardown for CB007292_B_B3_TC12

[1][1.0] CB007292_B_16_Verify_gNB_behaviour_for_Online_modification_of_Emergency_calls_extensions_parameters
    [Setup]     Prepare for CB007292_B_B5_TC16
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28342
    Verify SIB for gnb 3
    log to console    \n For UE 1
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

    Log to console     \n Disabling feature
         GNB Delta Commission      ${CURDIR}/config/scf/Delta_B_B5_disbale.json
         Set priority for Qosflows    ${QFI1}    8
         Set priority for Qosflows    ${QFI2}    8
         Set priority for Qosflows    ${QFI3}    8

    Log to console    \n For UE 2

        Change UE location    ${UE2}   ${ENB3}  ${CELL1}
        Verify UE registration and pdu setup   ${UE2}  ${Pdu_session_ID2}    ${GW2}
        wtsrunner.ue_im_entry    id=${UE2}     by=ue
        sleep    10s
        Change UE location    ${UE2}   ${ENB2}   ${CELL1}
        Establish Emergency RRCConnection     ${UE2}
        Validate TCP Traffic     ${UE2}    ${Pdu_session_ID2}
        Displays bearer statistics      ${UE2}    ${QFI1}    ${Pdu_session_ID2}
        Verify if traffic is running    ${UE2}    ${QFI1}    ${Pdu_session_ID2}
        Start pcap collection in gNB CU      name=modified_pdu_add_UE2
        Modify PDU session for UE to add    ${UE2}    ${Pdu_session_ID2}
        ${pcap_file_path}    Stop pcap collection in gNB 7292      name=modified_pdu_add_UE2    Log_Path=${Log_Path}
        ${arq}    Get Fields from Pcap     ${pcap_file_path}        ${pdu2_5qi}      ${arp}
        should be equal    ${arq}    8
        Validate Traffic with RTP    ${UE2}    ${Pdu_session_ID2}
        Verify if traffic is running    ${UE2}    ${QFI2}    ${Pdu_session_ID2}
        Modify PDU session for UE to add    ${UE2}    ${Pdu_session_ID2}    ${QFI3}    ${pdu_unsuccessful}

    log to console    \nVerify if UE 1 data is running
    Verify if traffic is running    ${UE1}    ${QFI1}    ${Pdu_session_ID}
    Verify if traffic is running    ${UE1}    ${QFI2}    ${Pdu_session_ID}

    Log to console     \n Enabling Feature
        GNB Delta Commission      ${CURDIR}/config/scf/Delta_B_B5_enable.json
        Set priority for Qosflows     ${QFI1}    2
        Set priority for Qosflows     ${QFI2}    1

    Log to console     \n For UE 3
        Change UE location    ${UE3}   ${ENB3}  ${CELL1}
        Verify UE registration and pdu setup    ${UE3}    ${Pdu_session_ID3}    ${GW3}
        wtsrunner.ue_im_entry    id=${UE3}     by=ue
        sleep    10s
        Change UE location    ${UE3}   ${ENB2}   ${CELL1}
        Establish Emergency RRCConnection     ${UE3}
        Validate TCP Traffic     ${UE3}    ${Pdu_session_ID3}
        Displays bearer statistics      ${UE3}    ${QFI1}    ${Pdu_session_ID3}
        Modify PDU session for UE to add    ${UE3}    ${Pdu_session_ID3}
        Validate Traffic with RTP    ${UE3}    ${Pdu_session_ID3}
        Displays bearer statistics      ${UE3}    ${QFI2}    ${Pdu_session_ID3}
        [Teardown]    Teardown for CB007292_B_B5_TC16


[1][1.0] CB007292_B_46_Verify_Unsuccessful_setup_of_Emergency_voice_call_5QI_1_AC_failure_with_Radio_Resources_Not_Available
    [Setup]    Prepare for CB007292_B_EC2_TC46
    [Tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28341
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
    [Teardown]    TearDown for CB007292_B_EC2_TC46
