*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT_no_cloud    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-beam    owner-QIANQIAN.GUO    CRT    release-SBTS23R4
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fddtdd_sansa_cmwv/3cells_1T2F

@{PARAMS_IN_SCF}
...    @{NSA_CONF}
...    @{PowerSaving}
...    @{NRPMRNL}
...    @{CB008745}

@{NSA_CONF}
...    NRBTS:gNbCuType=NSA
...    NRBTS:actSACallProcessingDU=false
...    NRCELL:cellDepType=NSA
...    NRBTS:nsaCellActivationAlarmTimer=300
...    NRBTS/NRDRB_PDCP-2:xxFlowControlProfForCuIdx=1
...    delete:NRCELL:trackingAreaDN
...    delete:NRBTS-2/TRACKINGAREA-200:snssaiList:snssaiDN
...    delete:NRBTS-2/SNSSAI-1:ngUplane
...    delete:NRBTS-2/NRSYSINFO_PROFILE-1/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-2/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-3/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-4/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-11/NRLIM-1
...    delete:NRBTS-2/NRSYSINFO_PROFILE-12/NRLIM-1
...    delete:NRCELL:ranAC

@{PowerSaving}
...    NRBTS:actNrLBPowerSaving=true
...    NRBTS:actCoordinated4g5gPowerSaving=cellDeactAndReact
...    NRBTS/NRPGRP-10:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-10:lbpsLastCellMinLoad=1
...    NRBTS/NRPGRP-10:lbpsLastCellRTXMinLoad=1
...    NRBTS/NRPGRP-10:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-10:lbpsMaxLoad=2
...    NRBTS/NRPGRP-10:lbpsMinLoad=1
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOff=120
...    NRBTS/NRPGRP-10:lbpsMonWinForCellSOn=60
...    NRBTS/NRPGRP-10:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-10:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-10:lbpsRTXMaxLoad=2
...    NRBTS/NRPGRP-10:lbpsRTXMinLoad=1
...    NRBTS/NRPGRP-10:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-10:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-10:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=50|nrCellId=1
...    NRBTS/NRPGRP-10:lbpsCellList:lbpsCellSOOrder=100|nrCellId=3
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed

@{CB008745}
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod

@{NRPMRNL}
...    NRPMRNL-1:miNrF1UU=5min
...    NRPMRNL-1:miNrX2CC=5min
...    NRPMRNL-1:miNrX2CB=5min
...    NRPMRNL-1:miNrCellAvailability=5min

@{not_into_PS}
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed

@{counter_A02_09}
...    ${ENDC_CELL_ACT_REQ_X2}=1
...    ${ENDC_CELL_ACT_ACC_X2}=1
...    ${NR_CELL_ACT_MENB_REQ}=1
...    ${NR_CELL_ACT_MENB_SUC}=1
...    ${ENDC_CELL_ACT_REJ_X2}=1

@{counter_A14}
...    ${X2_ENDC_CELL_SWITCH_ON_SENT}=1
...    ${ENDC_CELL_ACT_REQ_X2}=1
...    ${ENDC_CELL_ACT_ACC_X2}=1
...    ${NR_CELL_ACT_MENB_REQ}=1
...    ${NR_CELL_ACT_MENB_SUC}=1

${ENDC_CELL_ACT_REJ_X2}    M55110C00037
${ENDC_CELL_ACT_REQ_X2}    M55112C00020
${ENDC_CELL_ACT_ACC_X2}    M55112C00021
${NR_CELL_ACT_MENB_REQ}    M55113C00011
${NR_CELL_ACT_MENB_SUC}    M55113C00012
${X2_ENDC_CELL_SWITCH_ON_SENT}    M55110C00035

*** Test Cases ***
CB010442_A_ET_02_NSA_Switch_On_cell_in_energysaving_SUC_or_gNB_unknown_NR_Cell_Failure
    [Documentation]
    ...    1. This user scenario describes the gNB behavior, having a single X2 link, when the MeNB requests
    ...    to switch on one NSA NR cell in energysaving state or cell is gNB unknown.
    ...    2. Configuration
    ...    CB010442 Coordinated 4G-5G power saving part 2, 5G is activated.
    ...    3. Test Case Steps:
    ...    a.trigger cell1 into energysaving state.
    ...    b.activate cell1 by MeNB
    ...    c.check cell1 status changed to notEnergySaving
    ...    d.add traffic on cell1
    ...    e.check counters
    [Tags]    QC_303744    owner-qianqian.guo
    Clear Counter files
    Check currently time and modify parameters under lbpsPeriodList    NRPGRP_id=NRPGRP-10
    Cell States Check    cell_id=3    cell_state=energySaving
    Activate unknown cell    cell_id=4
    Activate cell in energySaving and check states    cell_id=3    cell_state=notEnergySaving
    UE Attach To Target Cell    ue_id=11    cell_id=3
    Send And Verify Nsa Throuput    ue_id=11    bearer_id=2    sleep_time=10s
    NSA UE Detach From GNB    ue_id=11
    OnlineParamChange    ${not_into_PS}
    Check Counters    ${counter_A02_09}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB010442-A_02_09${/}a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::4

CB010442_A_ET_09_NSA_Switch_On_cell_in_energysaving_SUC_or_gNB_unknown_NR_Cell_Failure
    [Tags]    QC_304437    owner-qianqian.guo
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

CB010442_A_ET_14_NSA_Switch_On_cell_in_energysaving_not_corresponding_order_SUC
    [Documentation]
    ...    1. This user scenario describes the gNB behavior, having a single X2 link, when the MeNB requests
    ...    to switch on one NSA NR cell not corresponding to the order of the NR cell to be activated in the power saving group.
    ...    2. Configuration
    ...    CB010442 Coordinated 4G-5G power saving part 2, 5G is activated.
    ...    cell1 and cell3 in same NRPGRP with diff order.
    ...    3. Test Case Steps:
    ...    a.trigger cell1 and cell3 into energysaving state.
    ...    b.activate cell1 by MeNB
    ...    c.check cell1 and cell3 status changed to notEnergySaving
    ...    d.add traffic on cell3
    ...    e.check counters
    [Tags]    QC_305436    owner-qianqian.guo
    Check currently time and modify parameters under lbpsPeriodList    NRPGRP_id=NRPGRP-10
    Cell States Check    cell_id=1    cell_state=energySaving
    Cell States Check    cell_id=3    cell_state=energySaving
    Clear Counter files
    Activate cell in energySaving and check states    cell_id=1    cell_state=notEnergySaving
    Cell States Check    cell_id=3    cell_state=notEnergySaving
    Check Alarm 7333 Raised
    OnlineParamChange    ${not_into_PS}
    Check Counters    ${counter_A14}
    UE Attach To Target Cell    ue_id=11    cell_id=3
    Send And Verify Nsa Throuput    ue_id=11    bearer_id=2    sleep_time=10s
    NSA UE Detach From GNB    ue_id=11
    Check Wireshark Log    ${CURDIR}${/}a2a_CB010442-A_14${/}a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Activate unknown cell
    [Arguments]    ${cell_id}
    Execute Egate Command    endc_cell_act_req id=1 target_gnb_id=2 nrci=311:489|${cell_id}    pass_regexp=cell-not-available

Activate cell in energySaving and check states
    [Arguments]    ${cell_id}    ${cell_state}
    Execute Egate Command    endc_cell_act_req id=1 target_gnb_id=2 nrci=311:489|${cell_id}    pass_regexp=value ActivationID :
    Cell States Check    cell_id=${cell_id}    cell_state=${cell_state}

Check currently time and modify parameters under lbpsPeriodList
    [Arguments]    ${NRPGRP_id}
    ${date}    execute command on enb     date
    ${day_of_week}    set variable    ${date.split()[0]}
    ${hour}    set variable    ${date.split()[3].split(":")[0]}
    ${minute}    set variable    ${date.split()[3].split(":")[1]}
    @{modify_lbpsPeriodList}    create list
    ...    ${NRPGRP_id}:lbpsPeriodList:lbpsStartTimeHour=${hour}|lbpsDayOfWeek=${day_of_week}
    ...    ${NRPGRP_id}:lbpsPeriodList:lbpsStartTimeMinute=${minute}|lbpsDayOfWeek=${day_of_week}
    ...    ${NRPGRP_id}:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=${day_of_week}
    ...    ${NRPGRP_id}:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=${day_of_week}
    Delta Commission Parameters    ${modify_lbpsPeriodList}

Cell States Check
    [Arguments]    ${cell_id}=1    ${cell_state}=energySaving    ${timeout}=600
    Object Should Exist    NRCELL-${cell_id}:energySavingState=${cell_state}    timeout=${timeout}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Check Alarm 7333 Raised
    ${fault7333}    create list    fault_id=7333
    fm fault should be raised    ${fault7333}

UE Attach To Target Cell
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA

Send And Verify Nsa Throuput
    [Arguments]    ${ue_id}=11    ${bearer_id}=2    ${sleep_time}=10s
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=dl mbps=10    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=${bearer_id} dir=ul mbps=10    UE ${ue_id}: UDP UL
    Verify Throuput    ${ue_id}    ${bearer_id}    ${sleep_time}

Verify Throuput
    [Arguments]    ${ue_id}=1    ${bearer_id}=2    ${sleep_time}=10a
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=dl    dc_cell_group=all    rate_type=ave
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=${bearer_id}    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_throughput}/1000>9
    Should Be True    ${ul_throughput}/1000>9

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=11
    Execute Egate Command    ue_detach id=${ue_id}    detached
