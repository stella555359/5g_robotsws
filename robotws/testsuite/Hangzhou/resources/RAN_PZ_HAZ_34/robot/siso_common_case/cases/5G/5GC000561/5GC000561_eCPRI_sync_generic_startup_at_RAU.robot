*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/gnb_sync.robot
*** Variables ***

*** Keywords ***
5GC000561_eCPRI_sync_generic_startup_at_RAU
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify RAU synchronization startup for eLLF interface
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 22.10.2020 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    selenium login and disable screen lock
    Sync Startup is verified
    ${origin_value}    Change NCPRI PM Interval    interval=5min
    connect to common unit master
    Sync data is verified after startup   origin_interval=${origin_value}    change_interval=5min
    Sync status reported to O&M is verified
    Change NCPRI PM Interval    interval=${origin_value}
    [Teardown]  run keywords  csn.Disconnect  connection=ASIK Master    AND    selenium logout and close browser
