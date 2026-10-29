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

*** Variables ***
${times}    10
${upgrade_package_path}     /home/ute/SBTS00_ENB_9999_260325_000015_release_BTSSM_downloadable_A54.zip

*** Test Cases ***
siso_common_site_upgrade
    [Timeout]  12h
    [Setup]    Case Setup:siso_common_site_upgrade
    FOR   ${index}    IN RANGE    ${times}
        Log To Console   //TODO: COAM Reset Site index：${index} time
        ${rulog_exist}    Get Variable Value    ${RULOG_TL['${tl.gnbs[0].global_bts_id}']['site_reset_withouthwf']}    ${False}
        set test variable    ${rulog_exist}
        run keyword if  ${rulog_exist}        RU Log Operation Setup in Siso Common
        Wait Until Keyword Succeeds    2m   30s   COAM Login
        Single time upgrade
        COAM Logout
    END
    [Teardown]   Case Teardown:siso_common_site_upgrade


*** Keywords ***
Case Setup:siso_common_site_upgrade
     Wait Until Keyword Succeeds    2m   30s   COAM Login
    ${fault_status}    run keyword and return status
    ...    Wait Until Keyword Succeeds   30m   1m   Fault With Alarm Should Be Present    FaultID=4420    AlarmID=7115
    run keyword if  ${fault_status}   wait until keyword succeeds   30m   1m
    ...   Fault With Alarm Should Not Be Present    FaultID=4420    AlarmID=7115
    run keyword if  ${fault_status}   sleep   5min
    #  Recovery At Case Setup if Fault Occurs
    #  Add HWF Flag at swconfig
    #  COAM Reset Site
     Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]    COAM Logout

Case Teardown:siso_common_site_upgrade
     Wait Until Keyword Succeeds    2m   30s   COAM Login
     Siso Common Save Logs
     run keyword if test failed    sleep    10min
     run keyword if test failed    run keyword and ignore error    Catch Snapshot COAM
    #  COAM Reset Site
    #  Wait Until Keyword Succeeds   20m   1m   COAM Check all cells should be onair
     [Teardown]    COAM Logout

Single time upgrade
     Start Syslog Collection
     ${CASE_PROCESS_START}   DateTime.Get Current Date   result_format=epoch
     Log To Console   CASE_PROCESS_START: ${CASE_PROCESS_START}
     Set Test Variable   ${CASE_PROCESS_START}
     COAM Update    file_path=${upgrade_package_path}   activate=yes
     Wait Until Keyword Succeeds   30m   1m   COAM Check all cells should be onair
    ${fault_status}    run keyword and return status
    ...    Wait Until Keyword Succeeds   5m   1m   Fault With Alarm Should Be Present    FaultID=4420    AlarmID=7115
     run keyword if  ${fault_status}   wait until keyword succeeds   30m   1m
    ...   Fault With Alarm Should Not Be Present    FaultID=4420    AlarmID=7115
     run keyword if  ${fault_status}     sleep   5min
    COAM Rollback
    Wait Until Keyword Succeeds   30m   1m   COAM Check all cells should be onair
    ${fault_status}    run keyword and return status
    ...    Wait Until Keyword Succeeds   30m   1m   Fault With Alarm Should Be Present    FaultID=4420    AlarmID=7115
     run keyword if  ${fault_status}   wait until keyword succeeds   30m   1m
    ...   Fault With Alarm Should Not Be Present    FaultID=4420    AlarmID=7115
    run keyword if  ${fault_status}     sleep   5min
     [Teardown]     Siso Common Each Time Teardown

COAM Update
    [Arguments]   ${file_path}    ${hostip}=192.168.255.129   ${activate}=yes    ${connection}=COAM
    Log To Console   Start Software Updating...
    ${should_activate}   Set Variable If   '${activate}'=='yes'   ${True}
    ...   '${activate}'=='no'   ${False}
    coam.update_software   sw_package=${file_path}   should_activate=${True}   timeout=${5400}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${True}
    Log To Console   Reset finished!
    Log To Console   COAM SWM Update Done!

COAM Rollback
    [Arguments]    ${hostip}=192.168.255.129     ${connection}=COAM
    Log To Console   Start Software Rollback...
    coam.rollback_software   timeout=${7200}   connection=${connection}
    Log To Console   Software Update Finished, Waiting For Resetting...
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${hostip}  exp_status=${True}
    Log To Console   Reset finished!
    Log To Console   COAM SWM Rollback Done!
