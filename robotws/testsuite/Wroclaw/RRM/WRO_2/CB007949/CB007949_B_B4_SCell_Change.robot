*** Settings ***
Force Tags    CRT    RAN_5G     SBTS00    CLOUD_5G_I_LPQ_AP_LOO

Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    ../keywords/tshark_verifying.robot
Resource    CB007949_keywords.robot
Library      ta5g_delta
Library     ta5g_pm_counters

Suite Setup        Run Keywords
...                Enable C-Plane Debug Logs       with_reboot=${false}
...    AND         Update And Put Iphy Xml         input_filepath=${iphy_xml}
...    AND         With Gnb Configuration          commissioning=${scfc}
...    AND         Start Default Logging           output_dirpath=${OUTPUT_DIR}
...    AND         With Simulator Configuration    config=${CURDIR}/config/egate_custom_config.cfg
...    AND         Stop Default Logging

Test Setup      Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}

*** Variables ***
${iphy_xml}=    ${CURDIR}/config/iphy_3FDD_3TDD_bw_100_50_60.xml
${scfc}=        scfc_7949_B_B4c_TFF_to_TTT.xml
${ue_id}=       1
${pdu_id}=      1
${gw_id}=       1

*** Test Cases ***
CB007949_B_B4c_Successful_SCell_Change_With_TDD_PCel_from_TFF_To_Homogenous_3CC_TDD_Using_Legacy_CB002329_CB006138
    [Setup]     Start Default Logging    output_dirpath=${OUTPUT_DIR}/${TEST_NAME}
    Wait For Next Full Pm Interval
    Register UE With PDU Session Setup    ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Send A1 Measurement And Verify TFF Is Configured    ue_id=${ue_id}    a1_meas_id=1    a1_rsrp=75
    ${scell_change}=    Send A1 Measurement With Capture    ue_id=${ue_id}    a1_meas_id=4    a1_rsrp=85
    Set Test Variable    ${scell_change}
    Verify Successful 3CC SCell Change    packet_filter=${SCELL_CHANGE_TFF_TTT}
    Verify MaxPayloadSize Value    value=${MAX_PAYLOAD_SIZE_VALUE_TTT}
    Verify Measurement Configuration    packet_filter=${MEAS_CONFIG_TFF_TTT}
    Verify PM Counters Updated
    [Teardown]     Run Keywords      Deregister Ue    ue_id=${ue_id}
        ...               AND        Stop Default Logging

*** Keywords ***

Send A1 Measurement And Verify TFF Is Configured
    [Arguments]   ${ue_id}    ${a1_meas_id}    ${a1_rsrp}
    Perform Action And Wait For Given Tshark Message Number
    ...    alias=${DEFAULT_UU_TSHARK_ALIAS}
    ...    packet_filter=(nr-rrc.sCellToAddModList == 2) && (nr-rrc.physCellId == 50) && (nr-rrc.physCellId == 54)
    ...    action=Send A1 Measurement    ue_id=${ue_id}    a1_meas_id=${a1_meas_id}    a1_rsrp=${a1_rsrp}
    ...    packet_number=1

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
