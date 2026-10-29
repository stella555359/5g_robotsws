*** Settings ***
Documentation
...  Test Suite Author: Krzysztof Brykman
...  Test Suite Owner:  Krzysztof Brykman
...  Team: T07


Resource          ../../../test_resources/BS-RF/SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.robot
Resource          ../../../test_resources/BS-RF/SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G.robot
Resource          ../../../test_resources/SWM/SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.robot
Resource          ../../../test_resources/SWM/SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_RU_Diagnostic_check_Memory_uasge.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.robot

*** Variables ***
${HW_LOCATION_CODE}    Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_init_results/execution/configs/topology_configs/node_1/10_16_UTESRANSISO134_DEFAULT.xml
${COLLECT_SNAPSHOT_FLAG}    failed_verdict
${TESTLINE_NAME}    10_16_UTESRANSISO134
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***
[TMO][1.0] Automated_SiSo_TEST_Radio_unit_snapshot_collection_and SM_Radio_unit_remote_during_fail_safe_mode
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    AH242203822    #AHFLOB
    ...    AND    SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.TC Setup
    ...    AND    Set Library Search Order    SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
    [Timeout]    14400
    TC__SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
    [Teardown]     SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.TC Teardown

[TMO][2.0] Automated_SiSo_FM_RU_Diagnostic_check_Memory_usage
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    AH242203822    #AHLOB
    ...    AND    SiSo_FM_RU_Diagnostic_check_Memory_uasge.TC Setup
    ...    AND    Set Library Search Order    SiSo_FM_RU_Diagnostic_check_Memory_uasge
    [Timeout]    14400
    TC__SiSo_FM_RU_Diagnostic_check_Memory_uasge
    [Teardown]     SiSo_FM_RU_Diagnostic_check_Memory_uasge.TC Teardown

[TMO][2.0] Automated_SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    K9245001205    #AHFII
    ...    AND    SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing.TC Setup
    ...    AND    Set Library Search Order    SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing
    [Timeout]    14400
    TC__SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing
    [Teardown]     SiSo_FM_RU_Diagnostic_check_NOK_scenario_RU_Temperature_sensor_missing.TC Teardown

[TMO][1.0] Automated_SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    AH242203822   #${ORIGINAL_CRC32} = e8d57409 AHLOB
    ...    AND    SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.TC Setup
    ...    AND    Set Library Search Order    SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
    [Timeout]    14400
    TC__SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
    [Teardown]     SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.TC Teardown

[TMO][1.0] Automated_SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    AH242300461
    ...    AND    Set Test Variable    ${USER_RAT_TO_LAUNCH}  4G
    ...    AND    SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Setup
    ...    AND    Set Library Search Order  SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Timeout]    14400
    TC__SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Teardown]  SiSo_TEST_TDS_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Teardown

[TMO][1.0] Automated_SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    K9245001205
    ...    AND    Set Test Variable    ${USER_RAT_TO_LAUNCH}  4G
    ...    AND    SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Setup
    ...    AND    Set Library Search Order  SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Timeout]    14400
    TC__SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
    [Teardown]  SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Teardown

[TMO][1.0] Automated_SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
   [Setup]    Run Keywords  Set Test Variable  ${COMMISSIONING_PATH}
   ...    AND    Set Test Variable    ${RMOD_SN}    K9245001230
   ...    AND    SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.TC Setup
   ...    AND    Set Library Search Order    SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
   [Timeout]    14400
   TC__SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode
   [Teardown]    Run Keywords    SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.TC Teardown
