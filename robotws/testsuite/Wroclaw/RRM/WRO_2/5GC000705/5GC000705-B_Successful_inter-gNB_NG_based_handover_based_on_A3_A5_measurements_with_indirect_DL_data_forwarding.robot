*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G_TDD
    ...    CLOUD_5G_I_LO_AP_LO    VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     5GC000705_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      taf.ul.ettf.setups
Library      ta5g_pm_counters
Variables    ta5g_global_var

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_5GC000705_1AEQE_1c.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             With Simulated Network Interface    name=eth3:GNB3_XN_ADDR    ip=10.0.1.4/24
...            AND             With Simulated Network Interface    name=eth3:AMF_NG    ip=10.0.1.1/24
...            AND             With Simulator Configuration   config=${CURDIR}/config/egate_1c_1Ue.lua

Suite Teardown    Stop Default Logging


*** Variables ***
${scfc}=              full_scfc_5G000705_successful_scenario_lo_ap_lo.xml
${NGAP: HANDOVER REQUEST}=    ((ngap.HandoverRequest_element)&&(ngap.HandoverType == intra5gs)&&(ngap.dLForwarding == dl-forwarding-proposed))
${E1AP: BEARER CONTEXT SETUP REQUEST}=    e1ap.BearerContextSetupRequest_element
${E1AP: BEARER CONTEXT SETUP RESPONSE}=    e1ap.BearerContextSetupResponse_element
${F1AP: UE CONTEXT SETUP REQUEST/RRC Reconfiguration}=    (f1ap.UEContextSetupRequest_element)&&(nr-rrc.RRCReconfiguration_element)
${F1AP: UE CONTEXT SETUP RESPONSE}=    (f1ap.UEContextSetupResponse_element)&&(nr-rrc.physCellId == 50)
${NGAP: HANDOVER REQUEST ACKNOWLEDGE}=
...    ((ngap.HandoverRequestAcknowledge_element) && (ngap.pDUSessionID == 1)) && (ngap.dataForwardingAccepted == data-forwarding-accepted)
${NGAP: DOWNLINK RAN STATUS TRANSFER}=    ngap.DownlinkRANStatusTransfer_element
${RRC Reconfiguration Complete}=    nr-rrc.rrcReconfigurationComplete_element
${E1AP: BEARER CONTEXT MODIFICATION REQUEST}=    e1ap.BearerContextModificationRequest_element
${E1AP: BEARER CONTEXT MODIFICATION RESPONSE}=    e1ap.BearerContextModificationResponse_element
${NGAP: HANDOVER NOTIFY}=    ngap.HandoverNotify_element
${NG_HO_RES_ALC_ATT_TRG}=    M55125C07503
${NG_HO_RES_ALC_SUCC_TRG}=    M55125C07504
${NG_HO_EXEC_NOTIFY_TRG}=    M55125C07520
@{counters_list_successful_scenario}=    ${NG_HO_RES_ALC_ATT_TRG}    ${NG_HO_RES_ALC_SUCC_TRG}    ${NG_HO_EXEC_NOTIFY_TRG}

*** Test Cases ***
5GC000705-B_Successful_inter-gNB_NG_based_handover_based_on_A3_A5_measurements_with_indirect_DL_data_forwarding
    Get Next Unpacked Full Pm Counters File
    Set Internal Traffic Type To UE
    Change Simulation UE Location
    Register UE To Simulation gNB
    Start Data Traffic
    Perform NGAP Handover
    Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT SETUP REQUEST}
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT SETUP RESPONSE}
    Verify Tcpdump Log    ${F1AP: UE CONTEXT SETUP REQUEST/RRC Reconfiguration}
    Verify Tcpdump Log    ${F1AP: UE CONTEXT SETUP RESPONSE}
    Verify NGAP: HANDOVER REQUEST ACKNOWLEDGE Message Includes Mandatory Elements For PDU Session Admitted And Structures For DL Data Forwarding
    Verify Ngap Messages    ${NGAP: DOWNLINK RAN STATUS TRANSFER}
    Verify E1AP BEARER CONTEXT MODIFICATION REQUEST Message Includes PDCP DL COUNT And F1 DL GTP Tunnel Endpoint Information
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT MODIFICATION RESPONSE}
    Verify Tcpdump Log    ${RRC Reconfiguration Complete}
    Verify That Target gNB Sent NGAP HANDOVER NOTIFY To AMF To Confirm That Handover Was Successful
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify That Appropriate Counters Incremented Correctly
    ...    counters_list=@{counters_list_successful_scenario}    pm_counter_path=${pm_counter_file}
