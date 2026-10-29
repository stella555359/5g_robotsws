*** Settings ***
Documentation
    ...    Author: casbo.xing@nokia-sbell.com
    ...    to define SG07 COMMON SISO Cased

#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
#Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
#Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/COAM.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource      Resource/9826_fallback_common.robot




Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown


*** Test Cases ***
CB009826_A_SISO_CIT
    [Setup]  Case Setup: CB009826_SISO_CIT
    run keyword and continue on failure   CB009826_siso_3_common_site_reset_without_hwf
    [Teardown]  Case Teardown: CB009826_SISO_CIT


*** Keywords ***
CB009826_siso_3_common_site_reset_without_hwf
   [Timeout]  24h
   Case Setup:siso_common_site_reset_without_hwf
   FOR   ${index}    IN RANGE    ${10}
       Log To Console   //TODO: COAM Reset Site index：${index} time
       Single Site Reset
   END
   [Teardown]   Run keywords
    ...   Run Keyword If   "${KEYWORD_STATUS}"=="FAIL"    Save Logs If Case Failed
    ...   AND   Case Teardown:siso_common_site_reset_without_hwf


Case Setup:siso_common_site_reset_without_hwf
    Add HWF Flag at swconfig
    Run Keyword And Ignore Error   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    Run Keyword And Ignore Error    COAM Logout

Case Teardown:siso_common_site_reset_without_hwf
#    Siso Common Save Logs
#    run keyword if test failed    sleep    10min
#    run keyword if test failed    run keyword and ignore error    Catch Snapshot COAM
    Remove HWF Flag at swconfig
    Run Keyword And Ignore Error   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    Run Keyword And Ignore Error    COAM Logout

Single Site Reset
    Start Syslog Collection
    ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
    Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
    Set Test Variable   ${CASE_PROCESS_START}
    Run Keyword And Ignore Error   COAM Login
    COAM Reset Site
    Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
    [Teardown]     Run Keywords    Siso Common Each Time Teardown
    ...   AND   Run Keyword And Ignore Error   COAM Logout

Case Setup: CB009826_SISO_CIT
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    AlarmWatchdog.add_allow_alarms    fault_id=6261

Case Teardown: CB009826_SISO_CIT
    Run Keyword If Test Failed   Run Keyword And Ignore Error   Save Logs If Case Failed
    robot_common_operations.Common Case Teardown
