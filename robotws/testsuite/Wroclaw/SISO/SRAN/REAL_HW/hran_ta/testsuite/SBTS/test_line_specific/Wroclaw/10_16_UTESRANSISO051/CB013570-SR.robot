*** Settings ***
Documentation
...  Test Suite Author: Kamil Adamowski
...  Test Suite Owner: Kamil Adamowski
...  Team: T07

Resource          ../../../test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Data_Transfer.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_act_deact_in_WebEM__RP000951__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Embedded_Power_Meter_EEM_real_time_counters_during_RF_lock_unlock__RP000951__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated.robot
Resource          ../../../test_resources/2G_RRM/Automated_SiSo_CALL_GSM_Voice_Call.robot
Resource          ../../../test_resources/4G_RRM/Automated_SiSo_CALL_LTE_Data_Transfer.robot
Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3.robot
Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_BB_hopping__RP002611__Automated_L3.robot
Resource          ../../../test_resources/BS-RF/BS-RF__SBTS_GSM_RF_hopping__RP002611__Automated_L3.robot
Resource          ../../../test_resources/BS-RF/BS-RF__Start_Stop_LTE_Uplink_TestModels_A1-1__RP001548__Automated.robot
Resource          ../../../../../resources/ca_4G_RRM_carrier_aggregation.robot
Resource          ../../../test_resources/STATE/STATE__Site_reset.robot
Resource          ../../../test_resources/BS-SM/BS-SM__GSM_RAT_reset_from_ADMIN.robot
Resource          ../../../test_resources/SWM/SiSo_SWM_Radio_unit_software_update_during_fail_safe_mode.robot
Resource          ../../../test_resources/SWM/SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.robot


*** Variables ***
${HW_LOCATION_CODE}         Wroclaw
${COMMISSIONING_PATH}       /home/ute/testline_init_results/execution/configs/topology_configs/node_1/TMO.xml

${COLLECT_SNAPSHOT_FLAG}    Never
${TESTLINE_NAME}            10_16_UTESRANSISO051

${ENABLE_TRUCK_ROLL_FLAG}    ${False}
${CUSTOM_SWITCH_PERFORM_RESET_CONFIGURATION_IN_SETUP}=    ${False}
${ADDITIONAL_IGNORED_ALARMS}   4387,   6328,   7300
*** Test Cases ***


[CB013570-SR][3.0] Automated__BS-SM GSM RAT reset from ADMIN
    [Setup]    Run Keywords  Set Test Variable   ${COMMISSIONING_PATH}
    ...    AND    Set Test Variable   ${COMMISSIONING_PATH}
    ...    AND    BS-SM__GSM_RAT_reset_from_ADMIN.TC Setup
    ...    AND    Set Library Search Order    BS-SM__GSM_RAT_reset_from_ADMIN
    [Timeout]    14400
    TC__BS-SM__GSM_RAT_reset_from_ADMIN
    [Teardown]    Run Keywords    BS-SM__GSM_RAT_reset_from_ADMIN.TC Teardown

[CB013570-SR][1.0] BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated  #206=36ca2644
    [Setup]    Run Keywords    Set Test Variable    ${USER_DATA}    371
    ...    AND    Set Test Variable    ${CELLS_YAML_PATH}    /home/ute/testline_configuration/10_16_UTESRANSISO051/ta_ue_config.yaml
	...    AND    BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3.TC Setup
    ...    AND    Set Library Search Order    BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3
    ...    AND    Set Test Variable  @{VOICE}    False
    [Timeout]    14400
    TC__BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3
    [Teardown]  Run Keywords  BS-RF__SBTS_GSM_Antenna_hopping__RP002611__Automated_L3.TC Teardown
    ...    AND    Run Keyword If Test Failed  ca_4G_RRM_carrier_aggregation.Recovery Action

[TMO][1.0] Automated_SiSo_TEST_Radio_unit_snapshot_collection_and SM_Radio_unit_remote_during_fail_safe_mode
    [Setup]    Run Keywords
    ...    Set Test Variable    ${RMOD_SN}    BL2222N406Z
    ...    AND    SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.TC Setup
    ...    AND    Set Library Search Order    SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
    [Timeout]    14400
    TC__SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode
    [Teardown]     SiSo_TEST_Radio_unit_snapshot_collection_during_fail_safe_mode.TC Teardown