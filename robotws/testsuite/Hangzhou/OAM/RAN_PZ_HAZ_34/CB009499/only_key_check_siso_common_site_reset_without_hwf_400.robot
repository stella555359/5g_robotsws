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
siso_common_site_reset_without_hwf
    [Timeout]  72h
    [Setup]    Case Setup:siso_common_site_reset_without_hwf
    FOR   ${index}    IN RANGE    ${400}
        Log To Console   //TODO: COAM Reset Site index：${index} time
        Wait Until Keyword Succeeds    2m   30s   COAM Login
        Single time Site Reset
        COAM Logout
    END
    [Teardown]   Case Teardown:siso_common_site_reset_without_hwf


*** Keywords ***
Case Setup:siso_common_site_reset_without_hwf
    Wait Until Keyword Succeeds    2m   30s   COAM Login
     Recovery At Case Setup if Fault Occurs
     Add HWF Flag at swconfig
     COAM Reset Site
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]    COAM Logout

Case Teardown:siso_common_site_reset_without_hwf
    Wait Until Keyword Succeeds    2m   30s   COAM Login
     Siso Common Save Logs
     run keyword if test failed    sleep    10min
     run keyword if test failed    run keyword and ignore error    Catch Snapshot COAM
     Remove HWF Flag at swconfig
     COAM Reset Site
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]    COAM Logout

Single time Site Reset
     Recovery At Case Setup if Fault Occurs
     Start Syslog Collection
     ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
     Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
     Set Test Variable   ${CASE_PROCESS_START}
     COAM Reset Site
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]     Siso Common Each Time Teardown     keycheck=${True}




