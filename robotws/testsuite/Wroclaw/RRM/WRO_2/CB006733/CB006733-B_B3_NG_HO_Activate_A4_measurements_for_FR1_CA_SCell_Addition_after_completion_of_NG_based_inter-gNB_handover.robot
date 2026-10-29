*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Lukasz Jagielski-Szczypik, Kamil Dabkowski
...              :contact: lukasz.jagielski_-_szczypik@nokia.com, kamil.dabkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../5GC000705/5GC000705_keywords.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      taf.ul.ettf.setups
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Variables    ta5g_global_var
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             With Simulated Network Interface    name=eth3:GNB3_XN_ADDR    ip=10.0.1.4/24
...            AND             With Simulated Network Interface    name=eth3:AMF_NG    ip=10.0.1.1/24
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts_6733_Ng_HO.cfg
...            AND             Wait For Next Full Pm Interval

*** Variables ***
${SCFC}=              scf_CB006733_BB3_A4.xml
${NGAP: HANDOVER REQUEST}=    ((ngap.HandoverRequest_element)&&(ngap.HandoverType == intra5gs)&&(ngap.dLForwarding == dl-forwarding-proposed))
${E1AP: BEARER CONTEXT SETUP REQUEST}=    e1ap.BearerContextSetupRequest_element
${E1AP: BEARER CONTEXT SETUP RESPONSE}=    e1ap.BearerContextSetupResponse_element
${F1AP: UE CONTEXT SETUP REQUEST/RRC Reconfiguration}=    (f1ap.UEContextSetupRequest_element)&&(nr-rrc.RRCReconfiguration_element)
${F1AP: UE CONTEXT SETUP RESPONSE}=    (f1ap.UEContextSetupResponse_element)&&(nr-rrc.physCellId == 54)
${NGAP: HANDOVER REQUEST ACKNOWLEDGE}=
...    ((ngap.HandoverRequestAcknowledge_element) && (ngap.pDUSessionID == 3)) && (ngap.dataForwardingAccepted == data-forwarding-accepted)
${NGAP: DOWNLINK RAN STATUS TRANSFER}=    ngap.DownlinkRANStatusTransfer_element
${E1AP: BEARER CONTEXT MODIFICATION REQUEST}=    e1ap.BearerContextModificationRequest_element
${E1AP: BEARER CONTEXT MODIFICATION RESPONSE}=    e1ap.BearerContextModificationResponse_element
${NGAP: HANDOVER NOTIFY}=    ngap.HandoverNotify_element
${COUNTER_M55118C00030}=             M55118C00030
${COUNTER_A4_MEASUR_ACT_SCELL_ADD_SA}=           A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=             PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${UE_ID}=                       4
${TARGET_GNB_ID}=               2
${SOURCE_GNB_ID}=               3
${SOURCE_CELL_ID}=              8
${TARGET_CELL_ID}=              4
${TARGET_PHYSICAL_CELL_ID}=     54
${MEASUREMENT_ID}=              13
${PDU_ID}=                      3
${MEASUREMENT_NRSRP}=           100
${MEASUREMENT_SRSRP}=           19
${GW_ID}=                       3
${NWSLICE_ID}=                  1

*** Test Cases ***
CB006733-B_B3_NG_HO_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_completion_of_NG_based_inter-gNB_handover
    Set Traffic Type To UE      gnb_id=${SOURCE_GNB_ID}    pdu_id=${PDU_ID}    ue_id=${UE_ID}
    Change UE Location to simulated Gnb      ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}    gnb_id=${SOURCE_GNB_ID}
    Register UE To source gNB    ue_id=${UE_ID}    target_gnb_id=${TARGET_GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}    nwslice_id=${NWSLICE_ID}
    Start Low DL non-GBR Data Traffic   ue_id=${UE_ID}   pdu_id=${PDU_ID}
    Trigger NGAP Handover   ue_id=${UE_ID}    phycell_id=${TARGET_PHYSICAL_CELL_ID}    meas_id=${MEASUREMENT_ID}
    ...     nrsrp_nr=${MEASUREMENT_NRSRP}     srsrp_nr=${MEASUREMENT_SRSRP}    gnb_id=${TARGET_GNB_ID}
    Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT SETUP REQUEST}
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT SETUP RESPONSE}
    Verify Tcpdump Log    ${F1AP: UE CONTEXT SETUP REQUEST/RRC Reconfiguration}
    Verify Tcpdump Log    ${F1AP: UE CONTEXT SETUP RESPONSE}
    Verify NGAP: HANDOVER REQUEST ACKNOWLEDGE Message Includes Mandatory Elements For PDU Session Admitted And Structures For DL Data Forwarding
    Verify Ngap Messages    ${NGAP: DOWNLINK RAN STATUS TRANSFER}
    Verify E1AP BEARER CONTEXT MODIFICATION REQUEST Message Includes PDCP DL COUNT And F1 DL GTP Tunnel Endpoint Information
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT MODIFICATION RESPONSE}
    Verify That Target gNB Sent NGAP HANDOVER NOTIFY To AMF To Confirm That Handover Was Successful
    Verify if UE4 RRCReconfiguration contains A4 configuration after Inter-gNB HO via Ng
    Verify that UEContextModificationRequest_2 of 3 contains measConfig with A4 event after Ng Inter-Gnb HO for gNB2
    Verify that UEContextModificationResponse_2 of 3 contains measGapConfig for gNB2
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_M55118C00030}
    ...   counter_name=${COUNTER_A4_MEASUR_ACT_SCELL_ADD_SA}    local_moid=${LOCAL_MOID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}
