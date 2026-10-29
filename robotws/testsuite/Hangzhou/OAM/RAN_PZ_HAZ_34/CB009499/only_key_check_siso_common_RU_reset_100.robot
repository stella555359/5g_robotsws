*** Settings ***
Documentation
...    Author: ruiyu.han@nokia-sbell.com
...    to define SG07 COMMON RU reset

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown


*** Variables ***
${retry_times}    100


*** Test Cases ***
siso_common_RU_reset
    [Timeout]  36h
    [Setup]    Case Setup:siso_common_RU_reset
    FOR   ${index}    IN RANGE    ${retry_times}
        log to console     //this is index：${index} time do ALL RUs reset...
        Wait Until Keyword Succeeds    2m   30s   COAM Login
        ALL RUs reset     keycheck=${True}
        COAM Logout
     END
     [Teardown]   Case Teardown:siso_common_RU_reset


*** Keywords ***
Case Setup:siso_common_RU_reset
     log to console     //TODO: Case Setup:siso_common_RU_reset
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

Case Teardown:siso_common_RU_reset
    Wait Until Keyword Succeeds    2m   30s   COAM Login
     run keyword if  '${tl.gnbs[0].global_bts_id}' in @{RULOG_TL}    run keywords
     ...   run keyword if test failed    RU Log Operation Teardown if keyword failed
     ...   AND    run keyword if test passed    RU Log Operation Teardown if keyword passed
     Siso Common Save Logs
     run keyword if test failed    sleep    10min
     run keyword if test failed    run keyword and ignore error    Catch Snapshot COAM
     Wait Until Keyword Succeeds   10m   30s   COAM Check all cells should be onair
     [Teardown]    Run Keyword And Ignore Error    COAM Logout

