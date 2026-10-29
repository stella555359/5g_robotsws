*** Settings ***
Force Tags    CONFIGURED    CRT    RAN_5G_TDD
    ...    	CLOUD_5G_I_MP_AP_LO    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_GMC

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../5GC000705/5GC000705_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_tshark
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      taf.ul.ettf.setups
Variables    ta5g_global_var


Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_5GC000705_1AEQE_1c.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             Start Vm Ethernet Interfaces
...            AND             Reach Onair   lua_cfg=${CURDIR}/config/egate_1c_1Ue.lua

Suite Teardown    Run Keywords   Stop Vm Ethernet Interfaces
...               AND            Stop Default Processes And Gather Logs And Compress Logs


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
${NG_FLOW_STP_ATT_INC_HO}=    M55125C09013
${NG_FLOW_STP_SUC_INC_HO}=    M55125C09014
${NG_FLOW_CONNECTED_SESSION_TIM}=     M55125C09516
@{counters_list_successful_scenario}=    ${NG_FLOW_STP_ATT_INC_HO}    ${NG_FLOW_STP_SUC_INC_HO}    ${NG_FLOW_CONNECTED_SESSION_TIM}

*** Test Cases ***
CB008806-5G-B_Successful_inter-gNB_NG_based_handover_with_UE_release__Extending_HO_flow_with_PM_counters_from_CB008200_CB007564
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
    Deregister Ue    ue_id=1
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify That Appropriate Counters Incremented Correctly
    ...    counters_list=@{counters_list_successful_scenario}    pm_counter_path=${pm_counter_file}

    [Teardown]    Add Scout Data Info To Testcase
