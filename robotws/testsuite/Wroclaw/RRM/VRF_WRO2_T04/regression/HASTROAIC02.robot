*** Settings ***
Documentation
...   Test cases run on CloudRan TL8681

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB012669/CB012669.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB006733/CB006733.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T04/CLOUD/CB013438/CB013438_TC_06.robot
Resource        ./regression_keywords.robot
Library        ./python_functions.py
Library     OperatingSystem
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cloud/DcapLogs.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/attenuators.py

Suite Setup     Run Keywords
...    Initialise Attenuator


Test Setup      Run Keywords
...    Set TESTNAME without spaces
...    Start Syslog On Vdu
...    Start Syslog On Vcu


Test Teardown   Run Keywords
...    Clear cache
...    Stop Syslog On Vdu And Collect Snapshot
...    Stop Syslog On Vcu And Collect Snapshot

Test Timeout    30h


*** Test Cases ***
CB012669-Feature_activation_with_DL_2CC_CA
    [Tags]    SCF_DEFAULT
    CB012669-Feature_activation_with_DL_2CC_CA

CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry
    [Tags]    SCF_6733
    CB006733_A_B4_TC04 Deactivation of A4 measurements for SCell Addition after A4 supervision timer expiry

CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO
    [Tags]    SCF_6733
    CB006733_B_B1_TC11 A4 measurements for FR1 CA SCell Addition are not configured after intra-gNB HO

TC06_CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_with_RAT1_and_parameter_Reinit_Prohibit_Timer_on_cloud
    [Tags]    SCF_13438
    TC06_CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_with_RAT1_and_parameter_Reinit_Prohibit_Timer_on_cloud
