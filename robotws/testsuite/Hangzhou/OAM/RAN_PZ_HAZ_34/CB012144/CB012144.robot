*** Settings ***
Documentation
    ...    Author: ruiyu.han@nokia-sbell.com
    ...    to define CB012144 cases
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB012144/Resource/CB012144_common.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/siso_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/RU.robot

Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}

Suite Setup  Run Keywords    CI_interface.Common Case Setup   AND  robot_common_operations.Common Suite Setup
Suite Teardown   robot_common_operations.Common Suite Teardown

*** Variables ***
@{ALL_TEST_STATUS}
${RMOD_FLAG}    ${True}

*** Test Cases ***
[1]SMOD_BBMOD_RMOD_POST_data_verify_in_snapshot
    [Timeout]   5h
    [Setup]    Case Setup for CB012144
    Pass Execution If    '${MRBTS_ID}' in @{TESTLINE_ingore}
    ...    message=Test skipped because ${MRBTS_ID} is in TESTLINE_ingore_list
    Pass Execution If    ${productcode_str.count('Y')}>0 or ${productcode_str.count('X')}>0
    ...    message=Test skipped because ${MRBTS_ID} have unofficial board!
    ###step1: get the reset start time
    ${SITERESET_START}   DateTime.Get Current Date   result_format=epoch
    ###step2: do 4 times site reset
    run keyword if   "${tl.gnbs[0].global_bts_id}" in ${RULOG_TL}     RU Log Operation Setup in Siso Common
    FOR   ${i}   IN RANGE    ${4}
        ${fault_status}    run keyword and return status
        ...    Wait Until Keyword Succeeds   5m   1m   Fault With Alarm Should Be Present    FaultID=4420    AlarmID=7115
        run keyword if  ${fault_status}   run keywords
        ...   wait until keyword succeeds   30m   1m
        ...   Fault With Alarm Should Not Be Present    FaultID=4420    AlarmID=7115
        ...   AND   sleep   10min
        COAM Reset Site
        Wait Until Keyword Succeeds   20m   30s   wait cell onair and enable LMI at same time
    END
    ###step3: get snapshot
    ${snapshot_path}     Catch Snapshot COAM    filename=smod_bbmod_blackbox
    ###step4: get the reset stop time
    ${SITERESET_STOP}   DateTime.Get Current Date   result_format=epoch
    ###step5: verify BB post in snapshot
    Verify Snapshot has SMOD BBMOD POST    path=${snapshot_path}
    ...                                    smod_name_postion=${smod_name_postion}
    ...                                    bbmod_name_postion=${bbmod_name_postion}
    ###step6: verify BB post timestamp correct
    Run Keyword And Continue On Failure    Verify SMOD BBMOD POST is in Reset timeRange
    ...                                             smodbbmod_blackbox_list=${smodbbmod_blackbox_list}
    ...                                             L1_blackbox_list=${L1_blackbox_list}
    ...                                             snapshot_path=${snapshot_path}
    ...                                             start_time=${SITERESET_START}
    ...                                             stop_time=${SITERESET_STOP}
    ###step7: verify RMOD post in snapshot
    run keyword if  ${RMOD_FLAG}   Verify RMOD POST is in Reset timeRange when controlled reset
    ...                                             start_time=${SITERESET_START}
    ...                                             stop_time=${SITERESET_STOP}
    [Teardown]    Case Teardown for CB012144


*** Keywords ***
wait cell onair and enable LMI at same time
    run keyword if   "${tl.gnbs[0].global_bts_id}" in ${RULOG_TL}     run keyword and ignore error    Enable LMI RU at ControlPC
    COAM Check all cells should be onair


