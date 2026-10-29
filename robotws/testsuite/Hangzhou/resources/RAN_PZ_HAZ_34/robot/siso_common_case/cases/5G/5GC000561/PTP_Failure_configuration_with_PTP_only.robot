*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
*** Variables ***

*** Keywords ***
PTP_Failure_configuration_with_PTP_only
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The input PTP signal is lost on the selected Primary Sync Slave Port or becomes unusable (N-1)
    ...     raise any time early.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.09.2021 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    Selenium Login And Disable Screen Lock
    ${origin_params}    Set ptp only to true
    @{clock_class_list}    create list    7
    ${old_clock_class_list}    Modify Accepted clock class list    acceptedClockClass=${clock_class_list}
    log to console  \n Wait For Fault 16 Present
    Wait For Expect Fault Present    faultId=${16}    timeout=300
    log to console  \n Wait For Fault 4298 Present
    Wait For Expect Fault Present    faultId=${4298}    timeout=300
    @{old_clock_class_list}    convert to list    ${old_clock_class_list}
    Modify Accepted clock class list    acceptedClockClass=${old_clock_class_list}
    log to console  \n Wait For Fault 16 Disappear
    Wait For Expect Fault To Disappear    faultId=${16}    timeout=1200
    log to console  \n Wait For Fault 4298 Disappear
    Wait For Expect Fault To Disappear    faultId=${4298}    timeout=1200
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Check Sync State and Slave State    sync_state=Locked    slave_state=Locked
    [Teardown]    Run keywords    Modify Parameters On Webem    modify_params=${origin_params}
    ...    AND    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ...    AND    Selenium Logout And Close Browser
