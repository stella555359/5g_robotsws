*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-7_5_UTE5G402T2402
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_qualcomm_ue.robot

*** Variables ***
${EMIL_FLAG}    False
@{NRCELL_ID1}    ${39354369}
${ALL_CELLS_EXCEPT_CELL2}    1,3,4,5,6

*** Test Cases ***
CB010332-A-B5_ST_01_01_Single UE UL throughput performance with pSRS with AWHQN
#    Block NRCell2
#    adjust_pa_all_ports_max_value
#    adjust pa for cell    cell_id=1
#
#    log to console    step1: check throughput when CB010332 disable
#    delta commission parameters and wait cells onair    ${DISABLE_10332_IN_ALL_CELLS}
#    ...                                                 cell_ids=${ALL_CELLS_EXCEPT_CELL2}
#    Prepare and attach UE
#    Start UL And DL traffic    send_traffic_ul=100M    send_traffic_dl=500M
#    Collect And Check Tput    cells=${NRCELL_ID1}
#    ...                       ul_target_tp=70
#    ...                       dl_target_tp=400
#    Stop UL And DL traffic
#    Detach UE

#    log to console    step2: enable CB010332 and throughput should have no impact
#    delta commission parameters and wait cells onair    ${ENABLE_10332_IN_CELL1}
#    ...                                                 cell_ids=${ALL_CELLS_EXCEPT_CELL2}
#    Prepare and attach UE
#    Start UL And DL traffic    send_traffic_ul=100M    send_traffic_dl=500M
#    Collect And Check Tput    cells=${NRCELL_ID1}
#    ...                       ul_target_tp=70
#    ...                       dl_target_tp=400
#    [Teardown]    Run Keywords    Stop UL And DL traffic
#    ...                           Detach UE
#    ...                           Common Test Teardown And Stop Capture Logs
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


