*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Damian Rzeczkowski
...              :contact: damian.rzeczkowski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     taf/ul/ettf/main.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
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
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_egate
Library      ta5g_pm_counters
Library      DateTime
Variables    CB006733_messaging_filters.py
Variables    logging_policy.py
Library      ./verify_ta_messaging/CB006733.py

Suite Setup    Run Keywords    Remove And Replace File    new_file=${new_file}    target_path=${target_path}
...            AND             Backup And Modify Swconfig File    parameters_list=@{SWCONFIG_FLAGS_LIST}
...            AND             Log to console    Full scfc commissioning with iphy.xml upload
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_basic.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Wait For Next Full Pm Interval

Suite Teardown    Stop Default Processes And Gather Logs And Compress Logs


*** Variables ***
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    FULL_POLICY
${rd_WA_skip_freq_validation}=        0x600036=0
@{SWCONFIG_FLAGS_LIST}=        ${rd_WA_skip_freq_validation}
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_basic.cfg
${scfc}=              CB006733-B_B7.xml
${GNB_ID}=            2
${PCELL_ID}=          4  #Cell 4
${SOURCE_PHY_CELL_ID}=    54
${TARGET_CELL_ID}=    4
${UE_ID}=             4
${PDU_4}=             4
${GW_ID_4}=           4
${COUNTER_ID}=    M55118C00030
${COUNTER_NAME}=    A4_MEASUR_ACT_SCELL_ADD_SA
${LOCAL_MOID}=    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-4
${supervision_timer_fr1} =    9
${new_file}=          ${CURDIR}/config/packet_iphy.lua
${target_path}=       /home/ute/.local/lib/wireshark/plugins/packet_iphy.lua

*** Test Cases ***
CB006733-B_B7_RRC_Reestablishment_to_the_same_serving_cell__FR1_CA_SCell_Addition_A4_measurements_are_activated_on_UE_after_procedure_finishes
    Attach UE And Verify Establishing PDU Session With subsequent A2 Measurement Trigger    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_4}    gw_id=${GW_ID_4}    supervision_timer=${supervision_timer_fr1}

    Verify A2 measurement configuration during ICS    ue_id=${UE_ID}
    Verify that UEContextModificationRequest_3 of 5 contains measConfig with A4 and A2 configuration for gNB2
    Verify that UEContextModificationResponse_3 of 5 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration 2 of 3 contains A4 configuration
    Verify if UE4 RRCReconfiguration 3 of 3 contains A2 deconfiguration and A1 A3 A5 configuration after A2 trigger
    Verify if UE4 Measurement Report is expected A2 measurement

    Perform RRC Reestablishment to the same serving cell
    ...    ue_id=${UE_ID}    gnb_id=${GNB_ID}    source_phy_cell_id=${SOURCE_PHY_CELL_ID}    target_cell_id=${TARGET_CELL_ID}

    #Verification of RRC Reconfiguration message during RRC Reestablishment procedure
    Verify if UE4 RRCReconfiguration 1 of 2 contains A2 Measurement Restored and A4 Measurements are not activated
    #Verification of RRC Reconfiguration message after RRC Reestablishment procedure
    Verify if UE4 RRCReconfiguration 2 of 2 contains Measurement Gap recovery and coverage based measurements recovered

    Trigger A1 Measurement And Wait for A4 Measurement Reactivation After A4 Retry Timer Expiration    ue_id=${UE_ID}    gnb_id=${GNB_ID}

    Verify if UE4 Measurement Report is expected A1 measurement B_B7
    Verify that UEContextModificationRequest_1 of 6 contains measConfig with A2 configuration only for gNB2 B_B7
    Verify that UEContextModificationResponse_1 of 6 contains measGapConfig release for gNB2
    Verify if UE4 RRCReconfiguration 1 of 3 contains A2 configuration and A1 A3 A5 deconfiguration after A1 trigger B_B7
    Verify that UEContextModificationRequest_3 of 6 contains measConfig with A4 and 2nd A2 configuration for gNB2 B_B7
    Verify that UEContextModificationResponse_3 of 6 contains measGapConfig for gNB2
    Verify if UE4 RRCReconfiguration 2 of 3 contains 2nd A4 configuration B_B7
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_4}
    Verify Pm Counters 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}
    ...    local_moid=${LOCAL_MOID}    condition=2

    [Teardown]    Add Scout Data Info To Testcase


*** Keywords ***
Attach UE And Verify Establishing PDU Session With subsequent A2 Measurement Trigger
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}    ${pdu_id}    ${gw_id}    ${supervision_timer}
    Create SA Aliases    ue_id=${ue_id}    gNB_id=${gnb_id}
    Set Expected Message Flow for UE Attach and A2 Measurement Trigger    ue_id=${ue_id}    gnb_id=${gnb_id}

    ${UE_register_timestamp} =    Get Current Date
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Start Low DL non-GBR Data Traffic    ue_id=${ue_id}   pdu_id=${pdu_id}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=0    expected_throughput=0.1Mbps
    Trigger A2 Measurement    ue_id=${ue_id}     meas_id=1    srsrp_nr=20    timeout=60
    ${after_A2_meas_timestamp} =    Get Current Date

    Verify If A2 Message Trigger Took Place Before Supervision Timer Expiration    ue_register_timestamp=${UE_register_timestamp}
    ...    after_A2_meas_timestamp=${after_A2_meas_timestamp}    supervision_timer=${supervision_timer}

    Verify Message Flow Expectations for UE Attach and A2 Measurement Trigger    ue_id=${ue_id}

Set Expected Message Flow for UE Attach and A2 Measurement Trigger
    [Arguments]    ${ue_id}    ${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Set 5 expected UE Context Modification messages for A2 A4 handling for UE4 and gNB2
    Set 3 expected RRC Reconfiguration Request and Complete messages for UE4
    Set 9 expected DLRRCMessageTransfer messages for gNB2
    Set 11 expected ULRRCMessageTransfer messages for gNB2
    Set expected Measurement Report messages for for UE4
    Expect Configuration Of A2 Measurement Messages Flow    ue_id=${ue_id}
    Expect Configuration Of A4 For SCell Addition Messages Flow    ue_id=${ue_id}

Verify Message Flow Expectations for UE Attach and A2 Measurement Trigger
    [Arguments]    ${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Verify 5 UE Context Modification messages for A2 A4 handling for UE4 and gNB2 occured
    Verify that all 3 RRC Reconfiguration Request and Complete messages occured for UE4
    Verify that all 9 DLRRCMessageTransfer messages occured for gNB2
    Verify that all 11 ULRRCMessageTransfer messages occured for gNB2
    Verify that Measurement Report messages occured for UE4
    Check If Configuration Of A2 Measurement Messages Flow Occured    ue_id=${ue_id}
    Check If Configuration Of A4 For SCell Addition Messages Flow Occured    ue_id=${ue_id}

Remove And Replace File
    [Arguments]    ${new_file}    ${target_path}
    Log  \n==== Replace file to solve the problem with dissecting nr-rrc packets with ute-wireshark 4.4.7 ====  console=True
    # Ensure the new file exists
    File Should Exist    ${new_file}

    # Remove the target file if it exists
    Run Keyword And Ignore Error    Remove File    ${target_path}

    # Copy the new file to the target location
    Copy File    ${new_file}    ${target_path}
