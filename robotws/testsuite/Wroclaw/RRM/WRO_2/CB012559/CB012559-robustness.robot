*** Settings ***
Force Tags    CRT    RAN_5G    SBTS00

Documentation    :copyright: Nokia
...              :authors: Lukasz Klimowicz
...              :contact: lukasz.klimowicz@nokia.com


Resource     taf/rfrl/common_resources/robot/libraries_instances.robot
Resource     testsuite/Wroclaw/RRM/WRO_2/resources/testing_env.robot
Resource     ../keywords/messaging.robot
Resource     ../keywords/traffic.robot
Resource     ../keywords/L3_Call.robot
Resource    ../keywords/tshark_verifying.robot
Resource     CB012559_keywords.robot
Library      ta5g_tshark
Library      ta_messaging
Library      taf.ul.ettf.setups
Library      ta5g_testline_management
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_pm_counters
Library      DateTime
Variables    logging_policy.py
Library      multi_UE_handling.py
Library      ta5g_enb

*** Variables ***
${KEEP_ALIVE}=       ${True}
${LOGS_COMPRESSION}=    ${True}
${LOGGING_POLICY}=    NO_LOGS
${BASIC_SETUP}=       ${CURDIR}/config/wts_12559_multi_ue.cfg
${IPHY_SETUP}=        ${CURDIR}/config/iphy_xml_12559.xml

${PCELL_ID}=          1  #Cell 1
${GNB_ID}=            2
${PHYSCELL_ID}=       51  #Cell 1
${PDU_1}=             1
${GW_ID_1}=           1
${number_of_simulated_ues} =    30

${scfc}=              full_scfc_CB012559_multiUE.xml
@{physcellids_list}=     53    54    52    55


*** Test Cases ***
CB012559_Robustness_Multi_UE_A2_mobility_trigger
    [Setup]    Run Keywords        Log to console    Full scfc commissioning with iphy.xml upload
    ...            AND             Configure simulated interfaces
    ...            AND             Update And Put Iphy Xml    input_filepath=${IPHY_SETUP}
    ...            AND             With Gnb Configuration    commissioning=${scfc}
    ...            AND             Wait For Testline Icmp Echo Replies And Ssh Services
    ...            AND             Wait For Action To Complete    time_sleep=240    sleep_message=Stabilization after configuration
    ...            AND             With Simulator Configuration    config=${BASIC_SETUP}
    ...            AND             Release Multiple UEs Without Confirmation    number_of_ues=${number_of_simulated_ues}

    Write Marker To Egate Console Log
    Wait For Action To Complete    time_sleep=5    sleep_message=Preparation for test launch
    Attach Multiple Ues Via Telnet    number_of_ues=${number_of_simulated_ues}    enb_id=${GNB_ID}    cell_id=${PCELL_ID}    gw_id=${GW_ID_1}
    Wait For Action To Complete    time_sleep=4    sleep_message=Stabilization after multiple UEs registration and PDU setup
    Send A2 Measurement For Multiple Ues Via Telnet    number_of_ues=${number_of_simulated_ues}    meas_id=1
    Wait For Action To Complete    time_sleep=5    sleep_message=Stabilization after multiple UEs measurement trigger

    Display UEs For Post Test Verification
    Flush Egate Logs
    Verify If All UEs Have 5CC CA Activated    number_of_ues=${number_of_simulated_ues}    physcellids=${physcellids_list}
    Verify If Measurement Triggers For All UEs Fullfilled Timeslot    expected_timeslot=1
    Verify If Multi UEs Are Still Active After Test    number_of_ues=${number_of_simulated_ues}

*** Keywords ***

Configure simulated interfaces
    Set Simulated Interface    name=eth4:UEC2    ip=10.0.2.2
    Set Simulated Interface    name=eth4:UEC3    ip=10.0.2.3

Write Marker To Egate Console Log
    Execute Egate Command    cmd=### marker_for_file_parsing

Wait For Action To Complete
    [Arguments]     ${time_sleep}    ${sleep_message}
    Sleep    ${time_sleep}
    Log to console    Waiting ${time_sleep}s : ${sleep_message}

Display UEs For Post Test Verification
    Execute Egate Command    cmd=ue_disp format=long
    Sleep    2

Flush Egate Logs
    Execute Egate Command    cmd=set_log_sim flush
    Sleep    2

Verify If All UEs Have 5CC CA Activated
    [Arguments]     ${number_of_ues}    ${physcellids}
    ${5CC_activated_for_all_UEs} =	Check 5CC Activation For MultiUE    number_of_ues=${number_of_ues}    physcellids=${physcellids}
    Run Keyword If    ${5CC_activated_for_all_UEs}==False    Fail    \nNot all UEs have 5CC established
    Run Keyword If    ${5CC_activated_for_all_UEs}==True    Log to console    \nAll ${number_of_simulated_ues} UEs have 5CC established

Verify If Measurement Triggers For All UEs Fullfilled Timeslot
    [Arguments]     ${expected_timeslot}
    ${timeframe_for_A2_triggers}    ${exceede_timeslot}=    Get Measurement Reports And Check If Exceeded Limit
     ...    timeslot=${expected_timeslot}
    Log to console    \nConsumed ${timeframe_for_A2_triggers} seconds for A2 measurements trigger
    Run Keyword If    ${exceede_timeslot}==True    Fail    \nExceeded timeslot for measurements trigger
    Run Keyword If    ${exceede_timeslot}==False    Log to console    \nTimeslot for measurement trigger was not exceeded

Verify If Multi UEs Are Still Active After Test
    [Arguments]     ${number_of_ues}
    ${all_ues_active}=        Check If MultiUE Still Active After Test    number_of_ues=${number_of_ues}
    Run Keyword If    ${all_ues_active}==False    Fail    \nDetected that some UE is not ACTIVE
    Run Keyword If    ${all_ues_active}==True    Log to console    \nAll UEs ACTIVE after test
