*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
    ...    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation    :copyright: Nokia
...              :authors: Blanka Gozdek, Lukasz Klimowicz, Sebastian Sliwakowski
...              :contact: blanka.gozdek@nokia.com, lukasz.klimowicz@nokia.com, sebastian.sliwakowski@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     CB008053_keywords.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Library      ta_messaging
Library      taf.ul.ettf.retry_context
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_pm_counters
Variables    CB008053_messaging_filters.py
Variables    logging_policy.py

*** Variables ***
${REBOOT}=    ${True}
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY
${BASIC_SETUP}=       ${CURDIR}/config/basic_setup.cfg
${UE_CAPABILITY_FILE}=       /home/ute/test_repository/testsuite/Wroclaw/RRM/WRO_2/CB008053/config/ue_capabilities_8053_D.cfg
${GNB_ID}=    2
${TDD_PCELL_ID}=    4
${UE_TDD_PCELL_1}=     4
${PDU_TDD_PCELL_1}=    4
${UE_TDD_PCELL_2}=     40
${UE_TDD_PCELL_3}=     41
${Trigger_CA_Meas_ID}=    1
${scfc}=              CB008053-D-B1a.xml
${FULL_SCFC}=     CB008053-D-B2b.xml
${FDD_PCELL_ID}=     1
${UE_FDD_PCELL_1}=     1
${UE_FDD_PCELL_2}=     10
${PDU_FDD_PCELL_1}=     1

*** Test Cases ***

CB008053-D_B1a_Simultaneous_Rx_Tx_Inter_Band_CA_transmission_handling_-_TDD_PCell
    [Setup]    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_CB008053.xml
    ...        AND    With Gnb Configuration    commissioning=${scfc}
    ...        AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...        AND    Start Default Logging
    ...        AND    With Simulator Configuration    config=${BASIC_SETUP}
    ...        AND    Create gNB Alias
    ...        AND    Wait For Next Full Pm Interval

    Configure UE1 UE2 UE3 capabilities    ue_capability_file=${UE_CAPABILITY_FILE}

    #####    UE1
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_TDD_PCELL_1}
    ...    cell_id=${TDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_1}
    Trigger A1 Based CA    ue_id=${UE_TDD_PCELL_1}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 4CC TTTF A1 Based SCell Addition For Ue1    ue_id=${UE_TDD_PCELL_1}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_TDD_PCELL_1}    pdu_id=${PDU_TDD_PCELL_1}    num_of_scells=3
    Release UE    ue_id=${UE_TDD_PCELL_1}    pdu_id=${PDU_TDD_PCELL_1}

    #####    UE2
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_TDD_PCELL_2}
    ...    cell_id=${TDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_2}
    Trigger A1 Based CA    ue_id=${UE_TDD_PCELL_2}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 4CC TTFF A1 Based SCell Addition For Ue2    ue_id=${UE_TDD_PCELL_2}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_TDD_PCELL_2}    pdu_id=${PDU_TDD_PCELL_1}    num_of_scells=3
    Release UE    ue_id=${UE_TDD_PCELL_2}    pdu_id=${PDU_TDD_PCELL_1}

    #####    UE3
    Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification    ue_id=${UE_TDD_PCELL_3}
    ...    cell_id=${TDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_TDD_PCELL_1}    gw_id=${UE_TDD_PCELL_3}
    Trigger A1 Based CA    ue_id=${UE_TDD_PCELL_3}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 2CC TT A1 Based SCell Addition For Ue3    ue_id=${UE_TDD_PCELL_3}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_TDD_PCELL_3}    pdu_id=${PDU_TDD_PCELL_1}    num_of_scells=1
    Release UE    ue_id=${UE_TDD_PCELL_3}    pdu_id=${PDU_TDD_PCELL_1}

    Verify 4CC And 2CC CA Counters    pcell_id=${TDD_PCELL_ID}    scell_id_ue3=5

CB008053-D_B2b_Simultaneous_Rx_Tx_Inter_Band_CA_Per_Band_Pair_transmission_handling_FDD_PCell
    [Setup]    Run Keywords    Find Scfc And Fix And Send Full Commissioning
    ...    scfc_filename=${FULL_SCFC}
    ...        AND
    ...     With Simulator Configuration    config=${BASIC_SETUP}
    ...        AND    Create gNB Alias
    ...        AND    Wait For Next Full Pm Interval

    Configure UE1 UE2 capabilities    ue_capability_file=${UE_CAPABILITY_FILE}
    #####    UE1
    Attach UE And Verify Establishing PDU Session with A1 Measurement Verification Db2b   ue_id=${UE_FDD_PCELL_1}
    ...    cell_id=${FDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_1}    gw_id=${UE_FDD_PCELL_1}
    Trigger A1 based CA    ue_id=${UE_FDD_PCELL_1}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 4CC FTTT A1 Based SCell Addition For UE1 Db2b    ue_id=${UE_FDD_PCELL_1}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_FDD_PCELL_1}    pdu_id=${PDU_FDD_PCELL_1}    num_of_scells=3
    Release UE    ue_id=${UE_FDD_PCELL_1}    pdu_id=${PDU_FDD_PCELL_1}

    #####    UE2
    Attach UE And Verify Establishing PDU Session with A1 Measurement Verification Db2b    ue_id=${UE_FDD_PCELL_2}
    ...    cell_id=${FDD_PCELL_ID}    gnb_id=${GNB_ID}    pdu_id=${PDU_FDD_PCELL_1}    gw_id=${UE_FDD_PCELL_2}
    Trigger A1 based CA    ue_id=${UE_FDD_PCELL_2}    gnb_id=${GNB_ID}    meas_id=${Trigger_CA_Meas_ID}
    Verify 3CC FFT A1 Based SCell Addition For UE2 Db2b    ue_id=${UE_FDD_PCELL_2}
    Verify Traffic Is Scheduled On All Cells    ue_id=${UE_FDD_PCELL_2}    pdu_id=${PDU_FDD_PCELL_1}    num_of_scells=2
    Release UE    ue_id=${UE_FDD_PCELL_2}    pdu_id=${PDU_FDD_PCELL_1}

    Verify 4CC And 3CC CA Counters    pcell_id=${FDD_PCELL_ID}    scell_id_2_ue2=2     scell_id_6_ue2=6

*** Keywords ***

Reboot Testline
    [Arguments]    ${reboot}=${True}
    Run Keyword If    ${reboot}    Trigger Site Reset
    Wait For Testline ICMP Echo Replies And SSH Services
    Set Suite Variable    $REBOOT    ${True}

Configure UE1 UE2 UE3 capabilities
    [Arguments]    ${ue_capability_file}
    Execute Egate Command    cmd=ue_param id=${UE_TDD_PCELL_1} ue_nr_capabilities=mobiletype1_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File
    Execute Egate Command    cmd=ue_param id=${UE_TDD_PCELL_2} ue_nr_capabilities=mobiletype2_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File
    Execute Egate Command    cmd=ue_param id=${UE_TDD_PCELL_3} ue_nr_capabilities=mobiletype3_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File

Configure UE1 UE2 capabilities
    [Arguments]    ${ue_capability_file}
    Execute Egate Command    cmd=ue_param id=${UE_FDD_PCELL_1} ue_nr_capabilities=Db2b_mobiletype1_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File
    ...    fail_regexp=Not Found In This File
    Execute Egate Command    cmd=ue_param id=${UE_FDD_PCELL_2} ue_nr_capabilities=Db2b_mobiletype2_nr_capability capability_file=${ue_capability_file}
    ...    fail_regexp=Unable to locate File
    ...    fail_regexp=Not Found In This File
Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1
    Log To Console	UE${ue_id} attach, establishing PDU session and A1 measurement setup verification.
    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred    ue_id=${ue_id}
    Verify A1 Measurement Configuration For PCell    ue_id=${ue_id}

Attach Ue And Verify Establishing PDU Session With A1 Measurement Verification Db2b
    [Arguments]    ${ue_id}    ${cell_id}    ${gnb_id}=2    ${pdu_id}=1    ${gw_id}=1
    Log To Console	UE${ue_id} attach, establishing PDU session and A1 measurement setup verification.
    Create UE Alias    alias=UE${ue_id}    ue_id=${ue_id}    id_type=wts_5g
    Expect UE Attach Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect PDU Messages Flow     ue_id=${ue_id}    gNB_id=${gnb_id}
    Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Attach UE And Establish PDU Session    ue_id=${ue_id}    cell_id=${cell_id}    enb_id=${gnb_id}    pdu_id=${pdu_id}    gw_id=${gw_id}
    Check If UE Attach Messages Flow Occurred     ue_id=${ue_id}
    Check If PDU Messages Flow Occurred     ue_id=${ue_id}
    Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred    ue_id=${ue_id}
    Verify A1 Measurement Configuration For PCell Db2b    ue_id=${ue_id}

Expect A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    ${T3410}=    Set Variable    15  # 3GPP TS 24.301
    ${margin}=    Set Variable    2  # if anything the fail should be in Attach UE And Establish PDU Session keyword,
                                     # not in message capturing/veryfing part
    ${timeout}=    Evaluate     ${T3410}*2+${margin}  # There are two T3410 timers in keyword Attach UE And Establish PDU Session
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_DLRRCMessageTransfer as DLRRCMessageTransfer
    ...    gNB${gNB_id}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer
    ...    UE${ue_id}:NR-RRC_RRCReconfiguration (measConfig is present) as RRCReconfiguration
    ...    UE${ue_id}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    gNB${gNB_id}:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...    alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}   overall_timeout=${timeout}

Check If A1 Measurement Configuration And DL UL RRCMessageTransfer Messages Flow Occurred
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}

Trigger A1 Based CA
    [Arguments]    ${ue_id}    ${gnb_id}    ${meas_id}
    Log To Console	Triggering A1 measurement for SCell addition from UE${ue_id}
    Expect A1 Based SCell Addition Messages Flow    ue_id=${ue_id}    gNB_id=${gnb_id}
    Trigger CA With A1 Measurement    UE_Id=${ue_id}    Meas_Id=${meas_id}
    Check A1 Based SCell Addition Messages Flow Occured    ue_id=${ue_id}

Expect A1 Based SCell Addition Messages Flow
    [Arguments]     ${ue_id}    ${gNB_id}=2
    Expect Message Flow
    ...    gNB${gNB_id}:F1AP_ULRRCMessageTransfer as ULRRCMessageTransfer_measurement
    ...    UE${UE_ID}:NR-RRC_MeasurementReport as measurementReport_A1
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (SCell-ToBeSetupMod-List is present) as UEContextModificationRequest
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (sCellToAddModList is present) as UEContextModificationResponse
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (RRCReconfigurationCompleteIndicator eq "true") as UEContextModificationRequest_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse as UEContextModificationResponse_2nd
    ...    gNB${gNB_id}:F1AP_UEContextModificationRequest (GNB-DUConfigurationQuery eq "true") as UEContextModificationRequest_3rd
    ...    gNB${gNB_id}:F1AP_UEContextModificationResponse (cellGroupConfig is present) as UEContextModificationResponse_3rd
    ...    UE${UE_ID}:NR-RRC_RRCReconfiguration (sCellToAddModList is present) as RRCReconfiguration
    ...    UE${UE_ID}:NR-RRC_RRCReconfigurationComplete as RRCReconfigurationComplete
    ...    alias=SCellAddition_UE${ue_id}   overall_timeout=60

Check A1 Based SCell Addition Messages Flow Occured
    [Arguments]     ${ue_id}
    Flow Occurred As Expected    alias=SCellAddition_UE${ue_id}

Verify A1 Measurement For SCell Addition Removal
    [Arguments]     ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_report_removal_DB1a_PCell_TDD}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurement SCell Addition Trigger
    [Arguments]     ${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurementReport_in_UL_DCCH_Message_for_PCell_TDD_DB1a}
    ...  message_alias=measurementReport_A1
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurement SCell Addition Trigger Db2b
    [Arguments]     ${ue_id}
    Verify That Message Fulfills Query
    ...  ${measurementReport_in_UL_DCCH_Message_for_PCell_FDD_Db2b}
    ...  message_alias=measurementReport_A1
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC TTTF A1 Based SCell Addition For Ue1
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TTTF_DB1a_UE1_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_TTTF_DB1a_UE1_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC FTTT A1 Based SCell Addition For Ue1 Db2b
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger Db2b    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_DB2b_UE1_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_FTTT_DB2b_UE1_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_FTTT_DB2b_UE1_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_FTTT_DB2b_UE1_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 3CC FFT A1 Based SCell Addition For Ue2 Db2b
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger Db2b    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FFT_DB2b_UE2_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_3CC_FFT_DB2b_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_3CC_FFT_DB2b_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_3CC_FFT_DB2b_UE2_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 4CC TTFF A1 Based SCell Addition For Ue2
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_4CC_TTFF_DB1a_UE2_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_4CC_TTFF_DB1a_UE2_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify 2CC TT A1 Based SCell Addition For Ue3
    [Arguments]    ${ue_id}
    Verify A1 Measurement SCell Addition Trigger    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_REQ}
    ...  message_alias=UEContextModificationRequest
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${selected_SCells_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify A1 Measurement For SCell Addition Removal    ue_id=${ue_id}
    Verify That Message Fulfills Query
    ...  ${PUCCH_config_for_2CC_TT_DB1a_UE3_CA_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${CSI_meas_config_for_2CC_TT_DB1a_UE3_CA_BF_in_UE_CON_MOD_RESP}
    ...  message_alias=UEContextModificationResponse
    ...  flow_alias=SCellAddition_UE${ue_id}

Verify A1 Measurement Configuration For PCell
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_configuration_for_PCell_TDD_DB1a}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PDU_Session_ID_check_for_PCell_TDD_DB1a}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}

Verify A1 Measurement Configuration For PCell Db2b
    [Arguments]    ${ue_id}
    Verify That Message Fulfills Query
    ...  ${A1_measurement_configuration_for_PCell_FDD_Db2b}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}
    Verify That Message Fulfills Query
    ...  ${PDU_Session_ID_check_for_PCell_FDD_Db2b}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=DL_UL_RRCMessageTransfer_with_A1_UE${ue_id}

Start Large Data Traffic
    [Arguments]    ${ue_id}   ${pdu_id}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=2 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=3 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} trf_id=4 dir=dl mbps=150

Verify Traffic Is Scheduled On All Cells
    [Arguments]    ${ue_id}   ${pdu_id}   ${num_of_scells}
    Start Large Data Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    30s    Wait for traffic to stabilize
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=${num_of_scells}
    Verify That Throughput Is Reached On All SCells    ue_id=${ue_id}    num_of_scells=${num_of_scells}    expected_throughput=10Mbps
    Stop DL and UL traffic on PDU for UE    ue_id=${ue_id}    pdu_id=${pdu_id}

Verify 4CC And 2CC CA Counters
    [Arguments]    ${pcell_id}    ${scell_id_ue3}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C09501    >1    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    M55118C09502    2    RRC_RECONF_ADD3DLSCELL_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_id}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C05507    >1    UE_PCELL_1_CONF_SCELL_DL_SA
    ...    M55118C05506    1    RRC_RECONF_ADD1DLSCELL_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_id}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C05508    >1    UE_SCELL_1_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_id_ue3}
    ...    file_path=${pm_counter_file}

Verify 4CC And 3CC CA Counters
    [Arguments]    ${pcell_id}    ${scell_id_2_ue2}     ${scell_id_6_ue2}
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55118C09501    >1    UE_PCELL_3_CONF_SCELL_DL_SA
    ...    M55118C09502    1    RRC_RECONF_ADD3DLSCELL_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_id}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07003    1    RRC_RECONF_ADD2DLSCELL_SUCC_SA
    ...    M55118C07001    >1    UE_PCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${pcell_id}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07002    >1    UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_id_2_ue2}
    ...    file_path=${pm_counter_file}
    Verify Any Counters In File
    ...    M55118C07002    >1    UE_SCELL_2_CONF_SCELL_DL_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-${scell_id_6_ue2}
    ...    file_path=${pm_counter_file}

Release UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Release PDU session    ue_id=${ue_id}    pdu_id=${pdu_id}
    Deregister UE    ue_id=${ue_id}
