*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :This user scenario describes the gNB behaviour for the successful
...                        Emergency call Intra-gNB Intra-DU Handover with multiple Emergency ARP values
Resource    resources/Keywords/CB007292_KW.robot
Suite Setup       Suite Setup for 7292
Suite Teardown     Common Suite Teardown


*** Variables  ***
${eventA5}       A5
${phycell_id}    52
${TOPOLOGY}      CLOUD_5G_O_E_AP_LOO


*** Test Cases ***
[1][1.0] CB007292_B_8_Verify_Successful_Emergency_voice_call_Intra-gNB_Intra_DU_Handover_with_multiple_Emergency_ARP_values
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

