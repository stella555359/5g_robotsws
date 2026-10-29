*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Lukasz Jagielski-Szczypik
...              :contact: lukasz.jagielski_-_szczypik@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     ../5GC000705/5GC000705_keywords.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ./verify_ta_messaging/verify_UEContextModification.robot
Resource     ta_messaging/flow.robot
Resource     Keywords_CB006733.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library      ta5g_enb
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_ue_mobility
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Variables    ta5g_global_var
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_basic.xml
...            AND             With Gnb Configuration    commissioning=${SCFC}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             Start Default Logging
...            AND             Check Radios Availability
...            AND             With Simulated Network Interface    name=eth3:GNB3_NG_ADDR    ip=10.0.1.3/24
...            AND             With Simulated Network Interface    name=eth3:GNB3_XN_ADDR    ip=10.0.1.4/24
...            AND             With Simulated Network Interface    name=eth3:AMF_NG    ip=10.0.1.1/24
...            AND             Reach Onair    lua_cfg=${CURDIR}/config/wts_6733_BB10.cfg
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${rd_WA_skip_freq_validation}=        0x600036=0
@{SWCONFIG_FLAGS_LIST}=        ${rd_WA_skip_freq_validation}
${SCFC}=              scf_CB006733_BB10_A4.xml
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
${SOURCE_CELL_ID}=              1
${TARGET_CELL_ID}=              4
${TARGET_PHYSICAL_CELL_ID}=     54
${SOURCE_PHYSICAL_CELL_ID}=     58
${MEASUREMENT_ID}=              7
${PDU_ID}=                      3
${MEASUREMENT_NRSRP}=           100
${MEASUREMENT_SRSRP}=           19
${GW_ID}=                       3
${NWSLICE_ID}=                  1
${PARAMS1}=
    ...    id=${UE_ID} if_contains=any action=reestablish gnb=${TARGET_GNB_ID} cell=${TARGET_CELL_ID} crnti=source cause=handoverFailure nth=1
${PARAMS2}=
    ...    id=${UE_ID} gnb=${TARGET_GNB_ID} reestab_info=${UE_ID}:valid include_security_config=on sec_config_nea=nea0 sec_config_nia=nia2
${REESTABLISHMENT_CAUSE}=    "handoverFailure"
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB006733-B_B10_RRC_Re-est_HO_Activate_A4_measurements_for_FR1_CA_SCell_Addition_after_successful_RRC_Re-establishment_during_NG_HO
    Send sibs to simulted Gnb and set internal traffic     gnb_id=${SOURCE_GNB_ID}    pdu_id=${PDU_ID}    ue_id=${UE_ID}
    Change UE Location to simulated Gnb      ue_id=${UE_ID}    cell_id=${SOURCE_CELL_ID}    gnb_id=${SOURCE_GNB_ID}
    Set ciphering and integrity protection algorithm    source_gnb_id=${SOURCE_GNB_ID}
    Register UE To source gNB    ue_id=${UE_ID}    target_gnb_id=${TARGET_GNB_ID}    pdu_id=${PDU_ID}    gw_id=${GW_ID}    nwslice_id=${NWSLICE_ID}
    Start Low DL non-GBR Data Traffic   ue_id=${UE_ID}   pdu_id=${PDU_ID}
    Prepare Ue for Ng inter-Gnb HO with reestablishment   params1=${PARAMS1}    params2=${PARAMS2}
    Trigger NGAP with reestablishment Handover  ue_id=${UE_ID}    phycell_id=${TARGET_PHYSICAL_CELL_ID}    meas_id=${MEASUREMENT_ID}
    ...     nrsrp_nr=${MEASUREMENT_NRSRP}     srsrp_nr=${MEASUREMENT_SRSRP}    gnb_id=${TARGET_GNB_ID}
    Verify NGAP: HANDOVER REQUEST Message Includes Handover Type Set To Intra5GS And dl-fwd-proposed IE Present
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT SETUP REQUEST}
    Verify Tcpdump Log    ${E1AP: BEARER CONTEXT SETUP RESPONSE}
    Verify Tcpdump Log    ${F1AP: UE CONTEXT SETUP REQUEST/RRC Reconfiguration}
    Verify Tcpdump Log    ${F1AP: UE CONTEXT SETUP RESPONSE}
    Verify NGAP: HANDOVER REQUEST ACKNOWLEDGE Message Includes Mandatory Elements For PDU Session Admitted And Structures For DL Data Forwarding
    Verify Ngap Messages    ${NGAP: DOWNLINK RAN STATUS TRANSFER}
    Verify E1AP BEARER CONTEXT MODIFICATION REQUEST Message Includes PDCP DL COUNT And F1 DL GTP Tunnel Endpoint Information
    Verify bearer context modification response messages in Tcpdump Log    ${E1AP: BEARER CONTEXT MODIFICATION RESPONSE}
    Verify RRC Reestablishment Request Message Content   ue_id=${UE_ID}  source_phy_cell_id=${SOURCE_PHYSICAL_CELL_ID}
    ...     reest_cause=${REESTABLISHMENT_CAUSE}
    Verify That Target gNB Sent NGAP HANDOVER NOTIFY To AMF To Confirm That Handover Was Successful
    Verify if UE4 RRCReconfiguration 1 of 2 contains A2,3,5 without A4 events during reestablishment HO via Ng
    Verify that UEContextModificationRequest_1 of 6 contains measConfig with A2,3,5 events during Ng HO for gNB2
    Verify that UEContextModificationRequest_4 of 6 contains measConfig with A2,3,4,5 events after Ng HO for gNB2
    Verify that UEContextModificationResponse_4 of 6 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration 2 of 2 contains A4 configuration after Inter-gNB with reestablishment HO via Ng
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_M55118C00030}
    ...   counter_name=${COUNTER_A4_MEASUR_ACT_SCELL_ADD_SA}    local_moid=${LOCAL_MOID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_ID}

    [Teardown]    Add Scout Data Info To Testcase


*** Keywords ***
Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
