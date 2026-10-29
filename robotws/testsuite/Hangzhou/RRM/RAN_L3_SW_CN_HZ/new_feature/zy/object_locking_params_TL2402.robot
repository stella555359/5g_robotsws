*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        tl-7_5_UTE5G402T2402
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
${EMIL_FLAG}  False

*** Test Cases ***
online change object locking parameters_cb010332_flag
    log to console    online change NRCELL-1:actHPPosMethodOptList=UL-TDOA
    delta commission parameters     NRCELL-1:actHPPosMethodOptList=UL-TDOA
    BBMOD RRU Should Not Restart
    cells should be onair

    log to console    online change NRCELL-1:actHPPosMethodOptList=disabled
    delta commission parameters     NRCELL-1:actHPPosMethodOptList=disabled
    BBMOD RRU Should Not Restart
    cells should be onair

*** Keywords ***
BBMOD RRU Should Not Restart_once
    setup_infomodel    alias=zy
    connect infomodel    alias=zy
    @{objects}    Create List    BBMOD_R-1    BBMOD_R-2
    ...                          RMOD_R-1    RMOD_R-2    RMOD_R-3    RMOD_R-4
    FOR    ${object}    IN    @{objects}
        ${im_obj}    get_infomodel_object    //${object}    alias=zy
        run keyword and continue on failure    should be equal    ${im_obj.operationalState}    enabled
        run keyword and continue on failure    should be equal    ${im_obj.proceduralStatus}    configured
        run keyword and continue on failure    should be equal     ${im_obj.availabilityStatus}    ${None}
    END
    [Teardown]    run keywords    disconnect_infomodel    alias=zy    AND
    ...           teardown_infomodel    alias=zy

BBMOD RRU Should Not Restart
    FOR    ${i}    IN RANGE    10
        Sleep    20
        BBMOD RRU Should Not Restart_once
    END










