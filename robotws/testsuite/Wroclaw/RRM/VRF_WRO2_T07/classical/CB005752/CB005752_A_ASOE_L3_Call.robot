*** Settings ***
Documentation
...   author: Patryk Mielcarek
...   contact: patryk.mielcarek@nokia.com
...   This is the TESTSUITE file for ASOE L3 Call

#Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP
#...           PY36
#...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASOE_2xAHEH
#...           SBTS00__WITH__CLOUD_5G_CLASSICAL_SA_ANDROID_ASOE_2xAHEH

Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Resource         ./resources/keywords.robot

Suite Setup      Run Keywords
...              testline_preparation.prepare_testline            AND
...              initialise_attenuator

Test Setup       start_btslog_on_local_machine

Test Teardown    Run Keywords
...              Run keyword if test failed    AdminUtils.collect_snapshot        AND
...              stop_and_collect_btslog

Suite Teardown   testline_preparation.sleep_well_tl


*** Test Cases ***
# ASOE_preparation CRT
#    [Tags]   CRT
#     Set Network Mode   1   NR_only

# ASOE_preparation
#     [Tags]   CIT
#    Set Network Mode   1   NR_only

[1][1.0] CB005752_A__Commisioning
    [Tags]   CRT
    [Setup]
    [1][1.0] CB005752_A__Commisioning
    [Teardown]

[1][1.0] CB005752_A__ASOE_Recommisioning
    [Tags]   CRT
    [1][1.0] CB005752_A__ASOE Recommisioning

[1][1.0] CB005752_A__DL UL MAX TPUT
    [Tags]   CIT
    [1][1.0] CB005752_A__DL_UL_Tput

[1][1.0] CB005752_A__TPUT_Robustness
    [Tags]   CRT
    [1][1.0] CB005752_A__TPUT_Robustness
