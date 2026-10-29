*** Settings ***
Resource    ./Resource/Common.robot
Variables   ./Config/A_AA_BB_CC.py

Suite Setup         CB010820 Common Suite Setup
Suite Teardown      CB010820 Common Suite Teardown


*** Variables ***


*** Test Cases ***
CB010820_A_AA_BB_CC_General_SiSo_Case
    [Setup]   robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    CB010820 Common Suite Setup After Scout Connection
    # Run Keyword And Continue On Failure   Test_Case_Manual_SiSo_CM_Recommissioning
    # Run Keyword And Continue On Failure   Test_Case_General_SiSo_Commissioning_BTS_Template_Commissioning
    # Run Keyword And Continue On Failure   Test_Case_General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    Run Keyword And Continue On Failure   Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    # Run Keyword And Continue On Failure   Test_Case_General_SiSo_Online_Sector_Addition_Deletion
    # Run Keyword And Continue On Failure   Test_Case_Manual_SiSo_SM_RF_Module_lock_unlock
    # Run Keyword And Continue On Failure   Test_Case_Manual_SiSo_Common_BBMOD_Reset
    # Run Keyword And Continue On Failure   Test_Case_Manual_SiSo_SM_BTS_Site_Reset
    # Run Keyword And Continue On Failure   Test_Case_Manual_SiSo_SM_BTS_Site_Reset_with_HWF
    # Run Keyword And Continue On Failure   Test_Case_OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call

    # Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    # List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
    [Teardown]   robot_common_operations.Common Case Teardown


*** Keywords ***

