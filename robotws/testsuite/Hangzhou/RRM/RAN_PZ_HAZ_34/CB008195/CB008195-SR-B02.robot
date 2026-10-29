*** Settings ***
Documentation
...    author: Zhou Lingyan
...    contact: lingyan.zhou@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-7_5_UTE5G402T2500
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot



*** Variables ***
${EMIL_FLAG}    False

*** Test Cases ***
CB008195_SR_B_02_Verify Sucessful SA GBR DRB admission static cell limits check with maxNumOfGBRBearersSA and maxGBRTrafficLimit during ICS SA
    [Documentation]
    ...    Description:
    ...    The purpose of this test case is to verify gNB behavior with Slice Aware Admission Control enabled when PDU session
    ...    setup with GBR bearers is requested and all resources required for PDU session, DRB(s) and SDAP can be allocated
    ...    within Resource Group dedicated pool.  executed for each statically configured GBR <threshold> listed below:
    ...    NRCELL.maxNumOfGBRBearersSA
    ...    NRCELL.maxGBRTrafficLimit
    ...    Requirement Coverage:
    ...    5G_RAN_USR_RRM_23997
    ...    CB008195-B#B1: SA GBR DRB admission static cell limits check- success
    ...    Precondition:
    ...    gNB/cell supports SA mode (NRBTS.gNBCuType, NRCELL.cellDepType)
    ...    NRCELL21: NRRESOURCEGROUP-1.racParams.minQuota=10, maxGBRTrafficLimit=30
    ...    At least two cells configured.
    ...    gNB is up and work normal.
    ...    Configuration:
    ...    Test Steps:
    ...    Step 1: SA UE2 attach to CELL21 and setup 2 pdu sessions with 5QI5 and 5QI7.
    ...    Step 2: clear counters files
    ...    Step 3: Add 5QI 1 for UE2 via Dial VoNR service.
    ...    Step 4: SA UE1 attach to CELL21 and setup 1 PDU with 5QI7 and 5QI4.

    ...    Expected result:
    ...    Step 1: UE2 attach success using ResourceGroupId-1 GBR bears in dedicated pool with PLMN-1
    ...    Step 3: UE2 VoNR call successful.
    ...    Step 4: UE1 attach success using ResourceGroupId-1 GBR bears in common pool and GBRTraffic in dedicated pool.
    ...            Counters M55910C00008, M55910C00012, M55910C00021, M55910C00022 should be pegged. others couner as except
    [Tags]    B02    QC_106503
    OnlineParamChange    ${OnlineParamChange_extendinactivitytimer}
    Lock NRCELLs
    adjust_pa_all_ports_max_value
    adjust_pa_for_cell    cell_id=21    value=20
    Prepare UEs    ue_ids=1,2,3,4
    Clear Counter Files    wait=${True}
    attach UE    ue_id=2    apn=dxdata1
    Make VONR call    ue_id=2
    attach UE    ue_id=1
    Start UL And DL traffic    ue_id=1    send_traffic_ul=1M    send_traffic_dl=1M    send_duration=120
    Check Counters    ${CELL_COUNTER}

    log    all test steps finished    console=True
    [Teardown]    Run Keywords    Stop UL And DL traffic
#    ...                           UnLock NRCELLs
    ...                           Detach all UEs
    ...                           Common Test Teardown And Stop Capture Logs


*** Keywords ***
UnLock NRCELLs
    ${delta}    create list    NRCELL-301:administrativeState=Unlocked    NRCELL-311:administrativeState=Unlocked
    Delta Commission Parameters  ${delta}
    Cells Should Be OnAir

Lock NRCELLs
    ${delta}    create list    NRCELL-301:administrativeState=Locked    NRCELL-311:administrativeState=Locked
    Delta Commission Parameters  ${delta}
    Cells Should Be OnAir    cell_id=21

Detach all UEs
   log to console    detach all UEs
    FOR    ${ue}    IN RANGE    1     3
	    Detach UE    ue_id=${ue}
    END


OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
