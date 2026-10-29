*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Library     BuiltIn
Library     String
Library     Process
Library     DateTime
Library     XML    True
Library     Collections
Library     OperatingSystem
Library     taf.transport.ssh   WITH NAME   csn
Library     taf.analyzer.pcap   WITH NAME   wireshark
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Library     taf.ul.oam_kpi_calculations   WITH NAME   oam_kpi
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library     taf.collectors.btslog   WITH NAME   btslog
Library     taf.collectors.core   WITH NAME   core

Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py

Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/L3_Call.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot

Resource    COAM.robot
Resource    Cell_Addition_Deletion.robot
Resource    Cell_Recommissioning.robot
Resource    MultiCC_L3Call.robot
Resource    LogCollection.robot

Variables   ../Library/common_vars.py



Resource    ../ResourceCase/Manual_SiSo_CM_Recommissioning.robot
Resource    ../ResourceCase/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ../ResourceCase/General_SiSo_Auto_Cell_lock_and_unlock_with_L3call.robot
Resource    ../ResourceCase/General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing.robot
Resource    ../ResourceCase/General_SiSo_Online_Sector_Addition_Deletion.robot
Resource    ../ResourceCase/Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    ../ResourceCase/Manual_SiSo_Common_BBMOD_Reset.robot
Resource    ../ResourceCase/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ../ResourceCase/Manual_SiSo_SM_BTS_Site_Reset_with_HWF.robot
Resource    ../ResourceCase/OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call.robot



*** Variables ***
@{ALL_TEST_STATUS}


*** Keywords ***
CB010820 Common Suite Setup
    Log To Console   CB010820 Common Suite Setup
    robot_common_operations.Common Suite Setup
    Perform Golden SCF Commission


CB010820 Common Suite Setup After Scout Connection
    # Create SUITE_SETUP_DIR
    ${SUITE_SETUP_DIR}   Set Variable   ${OUTPUT_DIR}/Suite_Setup
    Run Keyword And Ignore Error   OperatingSystem.Create Directory   ${SUITE_SETUP_DIR}
    Set Suite Variable   ${SUITE_SETUP_DIR}

    Run Keyword If   len(${SUITE_SETUP_CELL_ADDITION})!=0
    ...   Cell List Addition Common Keyword   cell_id_list=${SUITE_SETUP_CELL_ADDITION}
    ...   scf_local_dir=${SUITE_SETUP_DIR}   scf_file_name=SuiteSetup_Cell_Addition_BACK.xml
    Run Keyword If   len(${SUITE_SETUP_CELL_DELETION})!=0
    ...   Cell List Deletion Common Keyword   cell_id_list=${SUITE_SETUP_CELL_DELETION}
    ...   scf_local_dir=${SUITE_SETUP_DIR}   scf_file_name=SuiteSetup_Cell_Deletion_BACK.xml

    Cell Recommissioning Common Keyword
    ...   parameter_config_list=${SUITE_SETUP_CELL_RECOMMISSIONING}
    ...   scf_local_dir=${SUITE_SETUP_DIR}   scf_file_name=SuiteSetup_CellRecommissioning_Back.xml
    ...   delta_id=SuiteSetup   connection=SuiteSetup


CB010820 Common Suite Teardown
    Log To Console   CB010820 Common Suite Teardown

    # Create SUITE_TEARDOWN_DIR
    ${SUITE_TEARDOWN_DIR}   Set Variable   ${OUTPUT_DIR}/Suite_Teardown
    Run Keyword And Ignore Error   OperatingSystem.Create Directory   ${SUITE_TEARDOWN_DIR}
    Set Suite Variable   ${SUITE_TEARDOWN_DIR}

    Perform Golden SCF Commission

    robot_common_operations.Common Suite Teardown


CB010820 Common Case Setup
    Log To Console   CB010820 Common Case Setup
    # Run Keyword And Ignore Error   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    # robot_common_operations.Common Case Setup

    ${fail_log_dir}   Set Variable   ${OUTPUT_DIR}/${DEFINE_TEST_NAME}
    ${fail_log_dir_not_exist}   Run Keyword And Return Status   Directory Should Not Exist   ${fail_log_dir}
    Run Keyword If   ${fail_log_dir_not_exist}   OperatingSystem.Create Directory   ${fail_log_dir}
    Set Test Variable   ${FAIL_LOG_DIR}

    ${L3CALL_CELL_LIST}   Get Variable Value   ${L3_CALL_CELL_ID_LIST_CONFIGURATION["${DEFINE_TEST_NAME}"]}   @{EMPTY}
    Set Test Variable   ${L3CALL_CELL_LIST}
    Log To Console   L3CALL_CELL_LIST: ${L3CALL_CELL_LIST}

    Run Keyword And Ignore Error   CB010820 Start Syslog Process


CB010820 Common Case Teardown
    Log To Console   CB010820 Common Case Teardown

    Run Keyword And Ignore Error   CB010820 Stop Syslog Process

    Run Keyword And Ignore Error   CB010820 Catch All Logs

    # robot_common_operations.Common Case Teardown

10820 Common Case Setup
    robot_common_operations.Common Case Setup

10820 Common Case Teardown
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown
