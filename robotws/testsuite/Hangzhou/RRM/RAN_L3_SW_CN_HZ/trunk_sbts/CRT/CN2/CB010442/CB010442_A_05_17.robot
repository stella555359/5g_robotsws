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
...    NRCELL-1:cellDepType=NSA
...    delete:NRCELL-1:trackingAreaDN
...    delete:NRCELL-1:ranAC

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
...    NRPGRP-10:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-10:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed
...    NRBTS/NRPGRP-1:lbpsCSONCtlEnabled=true
...    NRBTS/NRPGRP-1:lbpsLastCellMinLoad=1
...    NRBTS/NRPGRP-1:lbpsLastCellRTXMinLoad=1
...    NRBTS/NRPGRP-1:lbpsLastCellSOEnabled=true
...    NRBTS/NRPGRP-1:lbpsMaxLoad=2
...    NRBTS/NRPGRP-1:lbpsMinLoad=1
...    NRBTS/NRPGRP-1:lbpsMonWinForCellSOff=120
...    NRBTS/NRPGRP-1:lbpsMonWinForCellSOn=60
...    NRBTS/NRPGRP-1:lbpsPdcchLoadOffset=4
...    NRBTS/NRPGRP-1:lbpsRTXCellCapOffset=80
...    NRBTS/NRPGRP-1:lbpsRTXMaxLoad=2
...    NRBTS/NRPGRP-1:lbpsRTXMinLoad=1
...    NRBTS/NRPGRP-1:lbpsRTXSOffTime=300
...    NRBTS/NRPGRP-1:lbpsRTXSOnTime=120
...    NRBTS/NRPGRP-1:lbpsSOMethod=cell switch off
...    NRBTS/NRPGRP-1:lbpsCellList:lbpsCellSOOrder=50|nrCellId=2
...    NRPGRP-1:lbpsPeriodList:lbpsDuration=50|lbpsDayOfWeek=Wed
...    NRPGRP-1:lbpsPeriodList:lbpsStartTimeHour=8|lbpsDayOfWeek=Wed
...    NRPGRP-1:lbpsPeriodList:lbpsStartTimeMinute=20|lbpsDayOfWeek=Wed

@{CB008745}
...    NRBTS:actLbpsCtrlLogicEnh=true
...    NRBTS/NRPGRP-10:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-10:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-10:lbpsSOffTrRule=MaxValueMethod
...    NRBTS/NRPGRP-1:lbpsLoadCalcMethod=Max(G, C, P)
...    NRBTS/NRPGRP-1:lbpsSOnTrRule=MinValueMethod
...    NRBTS/NRPGRP-1:lbpsSOffTrRule=MaxValueMethod

@{NRPMRNL}
...    NRPMRNL-1:miNrF1UU=5min
...    NRPMRNL-1:miNrX2CC=5min
...    NRPMRNL-1:miNrX2CB=5min
...    NRPMRNL-1:miNrCellAvailability=5min

@{counter_suc}
...    ${ENDC_CELL_ACT_REQ_X2}=1
...    ${ENDC_CELL_ACT_ACC_X2}=1
...    ${NR_CELL_ACT_MENB_REQ}=1
...    ${NR_CELL_ACT_MENB_SUC}=1

@{counter_8951}
...    ${X2_ENDC_CELL_SWITCH_ON_SENT}=1

${ENDC_CELL_ACT_REQ_X2}    M55112C00020
${ENDC_CELL_ACT_ACC_X2}    M55112C00021
${NR_CELL_ACT_MENB_REQ}    M55113C00011
${NR_CELL_ACT_MENB_SUC}    M55113C00012
${X2_ENDC_CELL_SWITCH_ON_SENT}    M55110C00035

${Update_Cfg_1}    set_enb id=11 plmn=250:255 s1=10.0.1.138 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.127 x2u=10.0.1.137
...    type=simulated x2_peers=none
${Update_Cfg_2}    set_enb id=1 plmn=250:255 s1=10.0.1.121 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.12 x2u=10.0.1.136
...    type=simulated x2_peers=none

*** Test Cases ***
CB010442_A_ET_05_NSA_NR_Cell_Switch_On_Succ_MultiX2Links
    [Documentation]
    ...    1. This user scenario describes the gNB behavior, having multiple X2 link, when the MeNB requests
    ...    to switch on one NSA NR cell in energysaving state.
    ...    2. Configuration
    ...    CB010442 Coordinated 4G-5G power saving part 2, 5G is activated.
    ...    two x2 links setup
    ...    3. Test Case Steps:
    ...    a.trigger cell1 into energysaving state.
    ...    b.activate cell1 by MeNB
    ...    c.check cell1 status changed to notEnergySaving
    ...    d.add traffic on cell1
    ...    e.check counters
    [Tags]    QC_304436    CDRT    owner-qianqian.guo
    Set WTS Parameters Before Attach
    Check currently time and modify parameters under lbpsPeriodList    NRPGRP_id=NRPGRP-10
    Cell States Check    cell_id=1    cell_state=energySaving
    Clear Counter files
    Activate cell in energySaving and check states    cell_id=1    cell_state=notEnergySaving
    UE Attach To Target Cell    ue_id=31    cell_id=1
    Send And Verify Nsa Throuput    ue_id=31    bearer_id=2    sleep_time=10s
    NSA UE Detach From GNB    ue_id=31
    Check Counters    ${counter_suc}
    Check Counters    ${counter_8951}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB010442-A_05${/}a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::2

CB010442_A_ET_17_SA_NSA_NR_Cell_Switch_On_Succ_MultiX2Links
    [Documentation]
    ...    1. This user scenario describes the gNB behavior, having multiple X2 link, when the MeNB requests
    ...    to switch on one SA+NSA NR cell in energysaving state.
    ...    2. Configuration
    ...    CB010442 Coordinated 4G-5G power saving part 2, 5G is activated.
    ...    two x2 links setup
    ...    cellDepType of cell2 is SA+NSA
    ...    3. Test Case Steps:
    ...    a.trigger cell2 into energysaving state.
    ...    b.activate cell2 by MeNB
    ...    c.check cell2 status changed to notEnergySaving
    ...    d.add traffic on cell2
    ...    e.check counters
    [Tags]    QC_305435    owner-qianqian.guo
    Check currently time and modify parameters under lbpsPeriodList    NRPGRP_id=NRPGRP-1
    Cell States Check    cell_id=2    cell_state=energySaving
    Clear Counter files
    Activate cell in energySaving and check states    cell_id=2    cell_state=notEnergySaving
    UE Attach To Target Cell    ue_id=31    cell_id=2
    Send And Verify Nsa Throuput    ue_id=31    bearer_id=2    sleep_time=10s
    NSA UE Detach From GNB    ue_id=31
    Check Counters    ${counter_suc}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB010442-A_17${/}a2a.ini    wait_string=GNBDUConfigurationUpdateAcknowledge::2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
    Execute Egate Command    sim_trace enb=11 protocol=x2 on

Modify Cfg
    Update Cfg    ${Update_Cfg_1}
    Update Cfg    ${Update_Cfg_2}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=9
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy=10.0.2.1:12219 earfcn=2000:20000 mapped_earfcn=4200:22200
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000 mandatory_for_activation=off

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

Set WTS Parameters Before Attach
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2
    Execute Egate Command    enb_x2_link_up enb=11 target=2    ENB-11: X2AP Link with GNB-2
    Execute Egate Command    enb_timer T_RRC_TRANSACTION=4s
    Execute Egate Command    trace enb=11 protocol=all on
    Execute Egate Command    trace enb=1 protocol=all on

NSA UE Detach From GNB
    [Arguments]    ${ue_id}=11
    Execute Egate Command    ue_detach id=${ue_id}    detached
