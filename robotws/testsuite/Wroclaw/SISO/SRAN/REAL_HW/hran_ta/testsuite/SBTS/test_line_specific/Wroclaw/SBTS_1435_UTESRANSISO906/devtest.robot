*** Settings ***
Documentation
...  Test Suite Author: Lukasz Wystup
...  Test Suite Owner:  Lukasz Wystup

Force Tags  QCD_MN_SRAN    QCP_SRAN_SBTS    CRT    	CLOUD_SRAN_NLWG_1ASIL_1ABIA_1ABIO_1ASIL_2ABIA_1AHEB_2FXEE_1FXJB_DEV    SBTS00

Resource          ../../../test_resources/BS-RF/SiSo_FM_RU_Diagnostic_check_Memory_uasge.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.robot
Resource          ../../../test_resources/BS-RF/SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.robot
Resource          ../../../test_resources/SWM/SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.robot
Resource          ../../../test_resources/BS-RF/SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_FID_4698_SFP_transceiver_temperature_too_high_on_RU.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_Temperature_Fault_1936_1938.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_Temperature_Fault_1937.robot
Resource          ../../../test_resources/BS-RF/SiSo_FM_Temperature_Fault_1927_1936_1938.robot

*** Variables ***

${HW_LOCATION_CODE}      Wroclaw
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO906/node1/SBTS00/CONF_ASIB_ABIO_3AHIB.xml
${TESTLINE_NAME}  10_16_UTESRANSISO906
${COLLECT_SNAPSHOT_FLAG}  Never
${ENABLE_TRUCK_ROLL_FLAG}    ${False}

*** Test Cases ***
#[AHEGA][1.0] Automated__SiSo_FM_Fault_4698_SFP_transceiver_temperature_too_high_on_RU
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${RMOD_SN}    EA174410379
#    ...    AND    Set Test Variable    ${COMMISSIONING_PATH}
#    ...    AND    SiSo_FM_FID_4698_SFP_transceiver_temperature_too_high_on_RU.TC Setup
#    ...    AND    Set Library Search Order    SiSo_FM_FID_4698_SFP_transceiver_temperature_too_high_on_RU
#    [Timeout]    14400
#    TC__SiSo_FM_FID_4698_SFP_transceiver_temperature_too_high_on_RU
#    [Teardown]     SiSo_FM_FID_4698_SFP_transceiver_temperature_too_high_on_RU.TC Teardown

[1]Automated__SiSo_FM_Temperature_Fault_1927_1936_1938
    [Setup]   Run Keywords    Set Test Variable   ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable    ${RMOD_SN}    EA174410379
    ...    AND    SiSo_FM_Temperature_Fault_1927_1936_1938.TC Setup
    ...    AND    Set Library Search Order    SiSo_FM_Temperature_Fault_1927_1936_1938
    [Timeout]   14400
    TC__SiSo_FM_Temperature_Fault_1927_1936_1938
    [Teardown]   SiSo_FM_Temperature_Fault_1927_1936_1938.TC Teardown

#[1][1.0] Automated__SiSo_FM_Temperature_Fault_1937
#    [Setup]   Run Keywords    Set Test Variable   ${COMMISSIONING_PATH}
#    ...    AND    Set Test Variable    ${RMOD_SN}    EA174410379
#    ...    AND    SiSo_FM_Temperature_Fault_1937.TC Setup
#    ...    AND    Set Library Search Order    SiSo_FM_Temperature_Fault_1937
#    [Timeout]   14400
#    TC__SiSo_FM_Temperature_Fault_1937
#    [Teardown]   SiSo_FM_Temperature_Fault_1937.TC Teardown

#[MRBTS-1435]Automated_SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${CELLS}   1,2
#    ...    AND    Set Test Variable    ${SISO_L3_CALL}    False
#    ...    AND    Set Test Variable    ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO051/ta_ue_config.yaml
#    ...    AND    SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.TC Setup
#    ...    AND    Set Library Search Order    SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
#    [Timeout]    14400
#    TC__SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band
#    [Teardown]     SiSo_TEST_NR_Activation_Reconfiguration_in_WebEM_for_Reduced_Guard_Band.TC Teardown

#[1]Automated_SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${RMOD_SN}    EA174410379
#    ...    AND    SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.TC Setup
#    ...    AND    Set Library Search Order    SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
#    [Timeout]    14400
#    TC__SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
#    [Teardown]     SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.TC Teardown

#[1]Automated_SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${RMOD_SN}  EA174410379
#    ...    AND    SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.TC Setup
#    ...    AND    Set Library Search Order    SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
#    [Timeout]    14400
#    TC__SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
#    [Teardown]     SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.TC Teardown

#[MRBTS-1435]Automated_SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${CELLS}   1,2
#    ...    AND    SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band.TC Setup
#    ...    AND    Set Library Search Order    SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band
#    [Timeout]    14400
#    TC__SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band
#    [Teardown]     SiSo_FM_NR_Fault4393_Configuration_and_RF_Module_mismatch_for_Reduced_Guard_Band.TC Teardown

#[1]Automated_SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${RMOD_SN}    EA174410248
#    ...    AND    Set Test Variable    ${USER_RAT_TO_LAUNCH}  4G
#    ...    AND    SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Setup
#    ...    AND    Set Library Search Order  SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
#    [Timeout]    14400
#    TC__SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G
#    [Teardown]  SiSo_TEST_online_RF_Sniffing_RF_Scanning_3G_4G_5G.TC Teardown

#[1]Automated_SiSo_FM_RU_Diagnostic_check_Memory_uasge
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${RMOD_SN}  EA174410248
#    ...    AND    SiSo_FM_RU_Diagnostic_check_Memory_uasge.TC Setup
#    ...    AND    Set Library Search Order    SiSo_FM_RU_Diagnostic_check_Memory_uasge
#    [Timeout]    14400
#    TC__SiSo_FM_RU_Diagnostic_check_Memory_uasge
#    [Teardown]     SiSo_FM_RU_Diagnostic_check_Memory_uasge.TC Teardown

#[1]Automated_SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
#    [Setup]    Run Keywords
#    ...    Set Test Variable    ${RMOD_SN}  EA174410248
#    ...    AND    SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.TC Setup
#    ...    AND    Set Library Search Order    SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
#    [Timeout]    14400
#    TC__SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity
#    [Teardown]     SiSo_FM_RU_Diagnostic_check_NOK_scenario_NVM_integrity.TC Teardown
