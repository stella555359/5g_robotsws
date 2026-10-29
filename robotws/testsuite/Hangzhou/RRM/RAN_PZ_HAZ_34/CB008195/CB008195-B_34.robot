*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Detach ALl UEs And Capture logs
Force Tags        release-SBTS24R3    tl-7_5_UTE5G402T2500
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
${EMIL_FLAG}    False
${AT_LOCK_NRCELL21}    AT+QNWLOCK="common/5g",339,396970,15,25
${AT_LOCK_NRCELL22}    AT+QNWLOCK="common/5g",658,396970,15,25
${AT_UNLOCK_NRCELL}    AT+QNWLOCK="common/5g",0
${5QI4_PORT}    58004
@{FAULTS_EXCLUDED_CHECKING}    4741


*** Test Cases ***
CB008195_SR_B_34 Verify Unsucessful SA GBR DRB admission multiple-cell pooled resource check with maxNumOfDRBL2Pool
    [Documentation]
    ...        CB008195_SR_B_34 Verify Unsucessful SA GBR DRB admission multiple-cell pooled resource check with maxNumOfDRBL2Pool
    ...        during pdu session setup and succeed after online delete a cell and scaling factor not needed
    log to console    step0: verify delta commission
    #improved RAT reset, BBMOD will not reset
    delta commission parameters    MNL-1/MNLENT-1/FEATCADM-1:actL1ReconfigImprovement=true
    delta commission parameters    NRBTS:actAdaptiveSchedulerBudgetOlc=false
    cells should be onair
    #legacy RAT reset, BBMOD will reset
    ${delta}    create list    MNL-1/MNLENT-1/FEATCADM-1:actBbReconfigImprovement=false
    ...                        MNL-1/MNLENT-1/FEATCADM-1:actL1ReconfigImprovement=false
    delta commission parameters    ${delta}
    delta commission parameters    NRBTS:actAdaptiveSchedulerBudgetOlc=true
    cells should be onair
    # lock useless cells
    delta commission parameters    ${DELTA_LOCK_USELESS_CELLS}

    log to console    step0: prepare pa and UEs
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=21    value=0
    Prepare UEs    ue_ids=1,2,3,4

    log to console    step1: check NRCELL-21/22:rgRacMinQuotaLimitationInfo
    object should exist    NRCELL-21:rgRacMinQuotaLimitationInfo=[Scaling factor] = 0.750; [Multicell group type]: L2POOL;[Resource type]: GBR;
    object should exist    NRCELL-22:rgRacMinQuotaLimitationInfo=[Scaling factor] = 0.750; [Multicell group type]: L2POOL;[Resource type]: GBR;
    stop capture wireshark log

    log to console    step2: attach UE1&UE2 to CELL21(assigned to RG2) successfully
    start to capture wireshark log    1_ue1
    attach UE    ue_id=1
    stop capture wireshark log    1_ue1
    start to capture wireshark log    2_ue2
    attach UE    ue_id=2
    stop capture wireshark log    2_ue2

    log to console    step3: attach UE3 to CELL21(intend to RG2) failed due to GBR L2 Pool AC failure
    start to capture wireshark log    3_ue3_fail
    attach UE Should Fail    ue_id=3
    detach ue    ue_id=3
    stop capture wireshark log    3_ue3_fail

    log to console    step4: lock CELL22, check NRCELL-21/22:rgRacMinQuotaLimitationInfo should not exist
    Lock NRCell22
    object should not exist    NRCELL-21:rgRacMinQuotaLimitationInfo=*
    object should not exist    NRCELL-22:rgRacMinQuotaLimitationInfo=*

    log to console    step5: attach UE3 to CELL21(assigned to RG2) successfully,use sharing area GBR resource
    start to capture wireshark log    5_ue3_success
    attach UE    ue_id=3
    stop capture wireshark log    5_ue3_success

#    log to console    step6: start some traffic for exist ues
#    start to capture wireshark log    6_traffic
#    start ul and dl traffic    ue_id=1    send_traffic_ul=1M    send_traffic_dl=1M    iperf_port=${5QI4_PORT}
#    start ul and dl traffic    ue_id=2    send_traffic_ul=1M    send_traffic_dl=1M    iperf_port=${5QI4_PORT}
#    start ul and dl traffic    ue_id=3    send_traffic_ul=1M    send_traffic_dl=1M    iperf_port=${5QI4_PORT}
#    Collect And Check Tput    cells=21    ue_id=1    dl_target_tp=1M    ul_target_tp=1M
#    Collect And Check Tput    cells=21    ue_id=2    dl_target_tp=1M    ul_target_tp=1M
#    Collect And Check Tput    cells=21    ue_id=3    dl_target_tp=1M    ul_target_tp=1M
#    stop capture wireshark log    6_traffic

    log to console    step7: unlock CELL22, check NRCELL-21/22:rgRacMinQuotaLimitationInfo
    Unlock NRCell22
    object should exist    NRCELL-21:rgRacMinQuotaLimitationInfo=[Scaling factor] = 0.750; [Multicell group type]: L2POOL;[Resource type]: GBR;
    object should exist    NRCELL-22:rgRacMinQuotaLimitationInfo=[Scaling factor] = 0.750; [Multicell group type]: L2POOL;[Resource type]: GBR;

    log to console    step8: attach UE4 to CELL22(assigned to RG1) successfully and start traffic
    adjust_pa_for_cell    cell_id=22    value=0    # cell22 signal power should be larger than cell21, but not too much, to avoid UE reestablish
    run keyword and ignore error    attach UE to NRCELL22    ue_id=4

*** Keywords ***
attach UE to NRCELL22
    [Arguments]    ${ue_id}
    start to capture wireshark log    8_ue4
    Execute AT Command    ${AT_LOCK_NRCELL22}    ${ue_id}
    attach ue    ${ue_id}
    start ul and dl traffic    ue_id=${ue_id}    send_traffic_ul=1M    send_traffic_dl=1M    iperf_port=${5QI4_PORT}
    Collect And Check Tput    cells=22    ue_id=4    dl_target_tp=1M    ul_target_tp=1M
    stop capture wireshark log    8_ue4
    # spark unlock cell will cause re-register
    [Teardown]    run keyword and ignore error    Execute AT Command    ${AT_UNLOCK_NRCELL}    ${ue_id}

Detach ALl UEs And Capture logs
    Unlock NRCell22
    Stop UL And DL traffic    ue_id=1
    Stop UL And DL traffic    ue_id=2
    Stop UL And DL traffic    ue_id=3
    Stop UL And DL traffic    ue_id=4
    Detach UE    ue_id=1
    Detach UE    ue_id=2
    Detach UE    ue_id=3
    Detach UE    ue_id=4
    Common Test Teardown And Stop Capture Logs
