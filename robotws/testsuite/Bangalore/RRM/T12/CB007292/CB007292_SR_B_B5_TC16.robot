*** Settings ***
Documentation   :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             :Feature  :The purpose of this test case is to verify the the gNB behaviour for
...             Online modification Emergency calls extensions parameters.
Resource    resources/Keywords/CB007292_KW.robot
Suite Setup        Updated Suite Setup
Suite Teardown     Common Suite Teardown


*** Variables ***
${TOPOLOGY}     CLOUD_5G_I_LO_AP_LO


*** Test Cases ***
[1][1.0] CB007292_B_16_Verify_gNB_behaviour_for_Online_modification_of_Emergency_calls_extensions_parameters
    [setup]     Prepare for CB007292_B_B5_TC16
    [tags]        QCD_MN_RAN      QCP_RAN_VRF   QC_28342
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
         Send Delta Commissioning      ${CURDIR}/config/scf/Delta_B_B5_disbale.json
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
        Send Delta Commissioning      ${CURDIR}/config/scf/Delta_B_B5_enable.json
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
