*** Settings ***
Documentation
...    author:  baijie.zhu@nokia-sbell.com
...    contact: baijie.zhu@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env   scf=SCF1_CB013355.xml
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS26R1    tl-7_5_UTE5G402T2451
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
@{PARAMS_IN_SWCONFIG}
...    0x00113=1     #BBC debug flag FEAT_DBG_BTSOM_BBC
...    275=1         #BBC debug flag FEAT_DBG_BTSOM_BBC
...    0x19011E=1    #BBC debug flag FEAT_DBG_BTSOM_BBC
...    0x2f0000=1    #BBC debug flag FEAT_DBG_BTSOM_BBC

*** Test Cases ***
CB013355_SR_C_D_Verify the eCPRI counter works in the newly introduced Nokia proprietary 7-2e Split Front-haul solution with 64TRX RRU
    [Documentation]
    ...    The test scenario is intended to verify This user scenario:
    ...    the eCPRI counters below works in the newly introduced Nokia proprietary
    ...    7-2e Split Front-haul solution with 64TRX RRU
    ...    Counters:
    ...    M55318C00023    ECPRI_CP_MSG_RU_RCV_ON_TIME
    ...    M55318C00024    ECPRI_CP_MSG_RU_RCV_TOO_EARLY
    ...    M55318C00025    ECPRI_CP_MSG_RU_RCV_TOO_LATE
    ...    M55604C00007    RU_RX_ON_TIME_C
    ...    M55604C00008    RU_RX_EARLY_C
    ...    M55604C00009    RU_RX_LATE_C
    ...    Case steps:
    ...    1.Check RU counters when interval 5min.
    ...    2.Check RU counters when lock cell.
    ...    3.Check RU counters when unlock cell.
    ...    4.Check counters after updating the interval to 15min.
    Check Ecpri Ru Counters After Full Commission
    Check Ecpri Ru Counters When Cell Locked
    Check Ecpri Ru Counters When Cell Unlocked Again
    Update Report Interval
    Check Ecpri Ru Counters In 15mins
    [Teardown]    detach UEs and collect logs

*** Keywords ***
detach UEs and collect logs
    Stop UL And DL traffic    ue_id=1
    Stop UL And DL traffic    ue_id=2
    Detach UE    ue_id=1
    Detach UE    ue_id=2
    Common Test Teardown And Stop Capture Logs

Adjust PA and SA Call
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=44   value=40
    log to console    step1: preprae UEs 1 and 2
    Prepare UEs    ue_ids=1,2
    log to console    step2: attach UE1 and establish the PDU sessions
    attach UE    ue_id=1    apn=dxdata1
    log to console    step3: DL and UL traffic
    Start UL And DL traffic    ue_id=1    send_traffic_dl=10M    send_traffic_ul=10M     apn_address=dxdata1
    log to console    step4: attach UE2 and establish the PDU sessions
    attach UE    ue_id=2    apn=dxdata1
    log to console    step5: DL and UL traffic
    Start UL And DL traffic    ue_id=2    send_traffic_dl=10M    send_traffic_ul=10M    apn_address=dxdata1    iperf_port=47991

Check Ecpri Ru Counters After Full Commission
    Adjust PA and SA Call
    Clear Counter Files    wait=${True}
    Check Counters    ${CELL_COUNTER}

Check Ecpri Ru Counters In 15mins
    sleep    300s
    Clear Counter Files    wait=${True}
    sleep    900s
    Check Counters    ${CELL_COUNTER_15min}

Lock Cell44
    Delta Commission Parameters  NRCELL-44:administrativeState=Locked
    Cells Should Be OnAir    cell_id=11
    Cells Should Be OnAir    cell_id=301

Unlock Cell44
    Delta Commission Parameters  NRCELL-44:administrativeState=Unlocked
    Cells Should Be OnAir    cell_id=44

Update Report Interval
    Delta Commission Parameters    NRPMRNL-1:miNrEcpriUpFCp=15min
    Delta Commission Parameters    PMMNL-1:miRxWindowStats=15min
    Delta Commission Parameters    PMMNL-1:miOranRuTxStats=15min

Check Ecpri Ru Counters When Cell Locked
    Lock Cell44
    Clear Counter Files    wait=${True}
    Check Counters    ${CELL_COUNTER_WHEN_LOCK}

Check Ecpri Ru Counters When Cell Unlocked Again
    Unlock Cell44
    Clear Counter Files    wait=${True}
    Check Counters    ${CELL_COUNTER}
