*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00    CLOUD_5G_I_BOO_AP_LOO    VARIANT_SANSA_FS_ECPRI_CMWV_FDD+TDD

Documentation   :copyright: Nokia
...             :contact: dominik.chalupczynski@nokia.com, marta.klukas@nokia.com

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    ../keywords/L3_Call.robot
Resource    CB007949_keywords.robot
Resource    ../keywords/logging.robot
Resource    ../keywords/messaging.robot
Resource    ../keywords/keywords.robot
Library     ta5g_testline_management
Library     ta5g_cell_operations
Library     ta5g_enb
Library     ta5g_pm_counters
Library     taf.ul.ettf.logging
Library     taf.ul.ettf.retry_context
Library     taf.ul.ettf.setups
Library     ta_messaging
Library     ../resources/messaging.py
Library     ../../resources/scout_report.py

Variables    CB007949_messaging_filters.py
Variables    ../resources/custom_policy.py

Suite Setup        Enable C-Plane Debug Logs    with_reboot=${false}

Test Teardown      Run Keywords
...                Deregister Ue    ue_id=all
...    AND         Add Scout Scf Id To Test Data

*** Variables ***
${LOGGING_POLICY}=          BASIC_POLICY
${cfg_B_B4c}=               ${CURDIR}/config/egate_custom_config.cfg
${IPHY_B_B4c}=              ${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
${SCFC_B_B4c}=              scfc_7949_B_B4c_TTT_to_TF.xml
${cfg_D_B1a}=               ${CURDIR}/config/egate_custom_config.cfg
${IPHY_D_B1a}=              ${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
${SCFC_D_B1a}=              scfc_7949_D_B1a.xml

*** Test Cases ***
CB007949_B_B4c_Successful_SCell_Change_With_TDD_PCell_From_Homogenous_3CC_TDD_to_TF_Using_Legacy_CB002329_CB006138_Since_23R2
    [Setup]       Run Keyword
    ...           Prepare Test Setup For One Real Gnb And Enable Tshark Verification    B_B4c
    Wait For Next Full Pm Interval
    Register UE With PDU Session Setup    ue_id=1    pdu_id=1   gw_id=1
    Send A1 Measurement And Verify TTT Is Configured    ue_id=1    a1_meas_id=1    a1_rsrp=75
    ${scell_change}=    Send A1 Measurement With Capture    ue_id=1    a1_meas_id=4    a1_rsrp=85
    Set Test Variable    ${scell_change}
    Verify Successful 3CC SCell Change    packet_filter=${SCELL_CHANGE_TTT_TF}
    Verify MaxPayloadSize Value    value=${MAX_PAYLOAD_SIZE_VALUE_TF_SINCE_23R2}
    Verify Measurement Configuration    packet_filter=${MEAS_CONFIG_TTT_TF}
    Verify PM Counters Updated

CB007949_D_B1a_Successful_TDD_3CC_SCells_Addition_Or_Change_With_dlMimoMode_70_And_Two_TDD_SCells_In_Same_Band_And_PCell_In_Another_Band_TC1
    [Setup]       Run Keywords
    ...           Reset WTS
    ...    AND    Wait For Testline Icmp Echo Replies And Ssh Services
    ...    AND    Prepare Test Setup For One Real Gnb And Enable Tshark Verification    D_B1a
    Attach UE And Establish PDU Session    ue_id=4    cell_id=4    enb_id=2    gw_id=4
    ...    pdu_session_setup_timeout=20
    Create SA Aliases    ue_id=4    gNB_id=2
    Verify A1 Configuration and CSI-RS and ACSI Allocation For PCell
    Send A1 Measurement For SCell Addition And Verify CSI-RS And ACSI Allocation
    Send A2 Measurement For SCell Release And Verify CSI-RS And ACSI     a2_meas_id=2    a2_rsrp=10    scell_id=1

*** Keywords ***
#B_B4
Send A1 Measurement And Verify TTT Is Configured
    [Arguments]   ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=(nr-rrc.sCellToAddModList == 2) && (nr-rrc.physCellId == 53) && (nr-rrc.physCellId == 55)
    ...    action=Send A1 Measurement    ue_id=${ue_id}    a1_meas_id=${a1_meas_id}    a1_rsrp=${a1_rsrp}
    ...    packet_number=1

Verify Successful 3CC SCell Change
   [Arguments]   ${packet_filter}    ${message_to_check}=${scell_change}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${packet_filter}

Verify Measurement Configuration
   [Arguments]    ${packet_filter}    ${message_to_check}=${scell_change}
    Verify Tshark For Single Message
    ...   alias=${message_to_check}
    ...   packet_filter= ${packet_filter}

Verify PM Counters Updated
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55118C06506
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    filepath=${pm_counter_file}
    Verify If Latest PM Counter Has Exact Value
        ...    counter_id=M55118C06507
        ...    value=1
        ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-3
        ...    filepath=${pm_counter_file}

#D_B1
Verify A1 Configuration and CSI-RS and ACSI Allocation For PCell
    Verify 1 Of Messages With ${F1AP_A1_CONFIGURATION} In Tcpdump Log
    Verify 2 Of Messages With ${CSI_RS_AND_ACSI_ALLOC_PCELL} In Tcpdump Log

Send A1 Measurement For SCell Addition And Verify CSI-RS And ACSI Allocation
    Expect SCell Addition messages flow    ue_id=4
    Execute Egate Command And Wait For Data
    ...     cmd=ue_measurement_send_nr id\=4 meas_id\=1 event\=A1 srsrp_nr\=110
    ...     pass_regexp=message c1 : rrcReconfigurationComplete
    Check if SCell Addition messages flow occured    ue_id=4
    Verify 1 Of Messages With ${A1_A2_MEASUREMENTS_RECONFIGURATION} In Tcpdump Log
    Verify SCells Addition
    Verify 3 Of Messages With ${CSI_RS_ALLOCATION_FOR_SCELLS} In Tcpdump Log
    Verify CSI-RS And ACSI In PCell

Send A2 Measurement For SCell Release And Verify CSI-RS And ACSI
    [Arguments]    ${a2_meas_id}    ${a2_rsrp}    ${scell_id}
    Execute Egate Command And Wait For Data
    ...     cmd=ue_measurement_send_nr id\=4 meas_id\=${a2_meas_id} event\=A2 srsrp_nr\=${a2_rsrp} scell\=${scell_id}
    ...     pass_regexp=message c1 : rrcReconfigurationComplete
    Verify 1 Of Messages With ${SCELL_1_RELEASE_A2_MEASUREMENT_DECONFIGURATION} In Tcpdump Log
    Verify 1 Of Messages With ${CSI_RS_AND_ACSI_REMAIN_PCELL} In Tcpdump Log

Verify SCells Addition
    Clear Egate Buffer From Logs
    Verify Egate Content    expected_pattern=SCellIndex 1 activated successfully at airphone
    Verify Egate Content    expected_pattern=SCellIndex 2 activated successfully at airphone
    Verify 1 Of Messages With ${SCELL_ADDITION_TTT} In Tcpdump Log

Verify CSI-RS And ACSI In PCell
    Verify That Message Fulfills Query
    ...  ${csi_rs_and_aCSI_for_PCell_in_RRC_RECONFIGURATION}
    ...  message_alias=RRCReconfiguration
    ...  flow_alias=SCellAddition_UE4
