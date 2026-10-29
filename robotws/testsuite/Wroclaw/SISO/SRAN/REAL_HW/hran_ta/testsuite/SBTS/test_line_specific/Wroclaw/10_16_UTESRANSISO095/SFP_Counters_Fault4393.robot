*** Settings ***
Documentation
...    Test Suite Author: Marta Bak
...    Test Suite Owner: marta.bak@nokia.com
...    Team: T03

Library           XML  use_lxml=True

Resource          ../../../test_resources/BS-RF/SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band.robot
Resource          ../../../test_resources/BS-RF/SiSo_PM_SMOD_SFP_Temperature_Counters.robot


*** Variables ***
${HW_LOCATION_CODE}       Wroclaw
${TESTLINE_NAME}          10_16_UTESRANSISO095
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${COMMISSIONING_PATH}
...    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO095_DEFAULT.xml

${POST_ALARMS_IGNORED_PATTERN}  1300
${ADDITIONAL_IGNORED_ALARMS}  1300

*** Test Cases ***
[MRBTS-1419][1.0] Automated_SiSo_FM_NR_Fault4393_Configuration_and_RU_mismatch_for_Reduced_Guard_Band
    [Setup]    Run Keywords
    ...    Set Test Variable    ${CELLS}   1
    ...    AND    SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band.TC Setup
    ...    AND    Set Library Search Order    SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band
    [Timeout]    14400
    TC__SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band
    [Teardown]     SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band.TC Teardown

[MRBTS-1419][1.0] SiSo_PM_SMOD_SFP_Temperature_Counters
    [Setup]    Run Keywords
    ...    SiSo_PM_SMOD_SFP_Temperature_Counters.TC Setup
    ...    AND    Set Library Search Order    SiSo_PM_SMOD_SFP_Temperature_Counters
    [Timeout]    14400
    TC__SiSo_PM_SMOD_SFP_Temperature_Counters
    [Teardown]     SiSo_PM_SMOD_SFP_Temperature_Counters.TC Teardown
