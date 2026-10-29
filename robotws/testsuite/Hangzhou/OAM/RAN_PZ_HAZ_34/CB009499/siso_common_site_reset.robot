*** Settings ***
Documentation
...    Author: ruiyu.han@nokia-sbell.com
...    to define SG07 COMMON SISO reset without hwf

Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/oam_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009499/Resource/resource.py

Suite Setup   Siso Common Suite Setup
Suite Teardown   Siso Common Suite Teardown

*** Test Cases ***
siso_common_site_reset_with_hwf
    [Timeout]  48h
    [Setup]    Case Setup:siso_common_site_reset_with_hwf
    FOR   ${index}    IN RANGE    ${100}
        Log To Console   //TODO: COAM Reset Site index：${index} time
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['site_reset']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}    RU Log Operation Setup in Siso Common
        Wait Until Keyword Succeeds    2m   30s   COAM Login
        Single time Site Reset
        COAM Logout
    END
    [Teardown]   Case Teardown:siso_common_site_reset_with_hwf


*** Keywords ***
Case Setup:siso_common_site_reset_with_hwf
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     log to console      //TODO: Case Setup:siso_common_site_reset_with_hwf
     Recovery At Case Setup if Fault Occurs
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]    COAM Logout

Case Teardown:siso_common_site_reset_with_hwf
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     run keyword if  ${rulog_exist}    run keywords
     ...   run keyword if test failed    RU Log Operation Teardown if keyword failed
     ...   AND    run keyword if test passed    RU Log Operation Teardown if keyword passed
     Siso Common Save Logs
     run keyword if test failed    sleep    10min
     run keyword if test failed    run keyword and ignore error    Catch Snapshot COAM
     [Teardown]    COAM Logout

Single time Site Reset
     Start Syslog Collection
     ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
     Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
     Set Test Variable   ${CASE_PROCESS_START}
     COAM Reset Site
     run keyword if  ${rulog_exist}
     ...   run keyword and ignore error   wait until keyword succeeds    15min    1min   Enable LMI RU at ControlPC
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown




