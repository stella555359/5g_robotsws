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

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library     ../Library/utils.py
Resource    COAM.robot
Resource    LogCollection.robot

Variables   ../Config/common_vars.py


*** Variables ***
@{ALL_TEST_STATUS}


*** Keywords ***
CB012784 Common Suite Setup
    Log To Console   CB012784 Common Suite Setup
    robot_common_operations.Common Suite Setup
    # Perform Golden SCF Commission
    Wait Until Keyword Succeeds   3x   30s   COAM commissioning if not onair
    COAM Login
    COAM Update PM Enable Parameters
    Run Keyword And Ignore Error   COAM Logout
    Sleep   30m
    COAM Login
    Wait Until Keyword Succeeds   5m   1m   COAM Check PM Counter List   counter_ids=${CHECK_COUNTER_LIST}
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


CB012784 Common Suite Teardown
    Log To Console   CB012784 Common Suite Teardown
    ${SUITE_TEARDOWN_DIR}   Set Variable   ${OUTPUT_DIR}/Suite_Teardown
    Run Keyword And Ignore Error   OperatingSystem.Create Directory   ${SUITE_TEARDOWN_DIR}
    Set Suite Variable   ${SUITE_TEARDOWN_DIR}
    # Perform Golden SCF Commission
    robot_common_operations.Common Suite Teardown


CB012784 Common Case Setup
    Log To Console   CB012784 Common Case Setup
    # Run Keyword And Ignore Error   Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
    robot_common_operations.Common Case Setup
    FOR   ${fault_id}   IN RANGE   ${4569}   ${4589}
        AlarmWatchdog.add_allow_alarms    fault_id=${fault_id}
    END
    ${fail_log_dir}   Set Variable   ${OUTPUT_DIR}/${TEST_NAME}
    ${fail_log_dir_not_exist}   Run Keyword And Return Status   Directory Should Not Exist   ${fail_log_dir}
    Run Keyword If   ${fail_log_dir_not_exist}   OperatingSystem.Create Directory   ${fail_log_dir}
    Set Test Variable   ${FAIL_LOG_DIR}
    Run Keyword And Ignore Error   CB012784 Start Syslog Process
    COAM Login


CB012784 Common Case Teardown
    Log To Console   CB012784 Common Case Teardown
    Run Keyword If   "${TEST_STATUS}"=="FAIL"   Run Keyword And Ignore Error   COAM Remove Trigger Formula Parameters
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   CB012784 Stop Syslog Process
    Run Keyword And Ignore Error   CB012784 Catch All Logs
    robot_common_operations.Common Case Teardown
    CI_interface.Common Case Teardown


Perform Golden SCF Commission
    ${TL_total}   Get Length   ${tl.gnbs}
    FOR   ${gNB}   IN RANGE   0   ${TL_total}
        CI_commssion.common commissioning   gnb_index=${gNB}
        Run Keyword And Continue On Failure   Check Golden SCF Validation Error   gNB=${gNB}
    END

