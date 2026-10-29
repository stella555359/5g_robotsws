*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00
...    CLOUD_5G_I_BOO_AP_LOO

Documentation    :copyright: Nokia
...              :authors: Łukasz Jagielski-Szczypik    Kamil Dąbkowski
...              :contact: lukasz.jagielski_-_szczypik@nokia.com    kamil.dabkowski@nokia.com

Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource     ../keywords/ue_measurements.robot
Resource     ../keywords/tshark_verifying.robot
Resource     ../CB005934/CB005934_keywords.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      taf.ul.ettf.retry_context
Library      ta5g_pm_counters
Library      ta5g_ue_measurements
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_egate
Library      ta5g_iphy
Variables    ta5g_global_var
Variables    ../CB005934/CB005934_messaging_filters.py
Library      ta5g_ue_mobility
Variables    logging_policy.py

Suite Setup    Run Keywords    Update And Put Iphy Xml    input_filepath=${CURDIR}/config/iphy_xml_6733_PMO_4.xml
...            AND             With Gnb Configuration    commissioning=${scfc}
...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
...            AND             With Simulator Configuration    config=${BASIC_SETUP}
...            AND             Create gNB Alias
...            AND             Wait For Next Full Pm Interval


*** Variables ***
${REBOOT}=    ${False}  # Switch to true to reboot before 1st test iteration, useful when running multiple tests on the same testline
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_TRAFFIC_LOGS_POLICY  # Can be set to FULL_POLICY_WITH_EMIL to capture Emil logs during retests
${BASIC_SETUP}=       ${CURDIR}/config/wts_6733_PMO_4.cfg
${scfc}=              scf_full_6733_PMO_4.xml
${GNB_ID}=            2
${PCELL_ID}=          1  #Cell 1
${PHYSCELL_ID}=       51  #Cell 1
${UE_ID}=             1
${PDU_1}=             1
${GW_ID_1}=           1
${COUNTER_ID}=        M55118C00033
${COUNTER_NAME}=      BLIND_SCELL_ADDED_SA
${LOCAL_MOID}=        PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1

*** Test Cases ***
CB006733-PMO_4_Counter_update_blind_SCell_addition_4CC_FDD_PCell_and_3_FDD_SCells

    Attach UE And Verify Establishing PDU Session With Blind SCell Addition    ue_id=${UE_ID}    cell_id=${PCELL_ID}
    ...    gnb_id=${GNB_ID}    pdu_id=${PDU_1}    gw_id=${GW_ID_1}
    Verify 4CC FFFF Blind SCell Addition Message Contents    ue_id=${UE_ID}
    Start Data Traffic
    Verify Traffic Is Scheduled On All Cells 4CC DL And UL On PCell
    Verify PMO#4 Pm Counter 6733    ue_id=${UE_ID}    counter_id=${COUNTER_ID}    counter_name=${COUNTER_NAME}    local_moid=${LOCAL_MOID}
    Release UE    ue_id=${UE_ID}    pdu_id=${PDU_1}

*** Keywords ***
Verify PMO#4 Pm Counter 6733
    [Arguments]    ${cell_id}    ${counter_id}    ${counter_name}    ${local_moid}    ${condition}=3
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...  ${counter_id}    ${condition}    ${counter_name}
    ...  local_moid=${local_moid}
    ...  file_path=${pm_counter_file}
