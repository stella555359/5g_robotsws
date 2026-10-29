*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_FCC_CUS
...               team-VRF_HAZ3_T08    owner-huabao.jiang    release-SBTS23R1
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    @{CLOSE_CGI_COMP_VENDOR}

${HIGH_LOAD_SWITCHON_trigger}    0x00110017
${LOW_LOAD_SWITCHOFF_trigger}    0x00110016

@{PARAMS_IN_SWCONFIG}
...    0x00110017=6
...    0x00110016=12
...    @{FAULT_SIMULATION_REQUEST_scenario}

@{FAULT_SIMULATION_REQUEST_scenario}
...    0x450027=1

@{PARAMS_IN_SCF}
...    PSGRP-1:lbpsLastCellSOEnabled=true
...    @{PS_RTX_LOW_LOAD}
...    @{PS_FOR_7X24}
...    @{CLOSE_CGI_COMP_SCF}
...    LNCELL-1/LNCEL_TDD-0:actTmSwitch=true
...    PSGRP-1:lbpsCSONCtlEnabled=false
...    LNCEL-1/SIB-0:ulpcIniPrePwr=-106 dBm
...    @{CB008800}
...    @{Load_Threshold}
...    @{CELL1_CELL2_CELL3_IN_PSGRP1}
...    @{lbpcellperiodlist_FOR_3cells}
...    LNBTS:actOnlineTXSwitch=true

@{CLOSE_CGI_COMP_VENDOR}
...    LNBTS:mimoClCqiComp=0
...    LNBTS:mimoOlCqiComp=0

@{CLOSE_CGI_COMP_SCF}
...    LNBTS-1/LNBTS_TDD-0:dlOlqcDeltaCqiMax=0
...    LNCEL/LNCEL_TDD-0:mimoBfCqidlComp=0

@{PS_FOR_7X24}
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sun
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Mon
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Tue
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Wed
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Thu
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Fri
...    PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sat
...    PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sat
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sat
...    PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sat

@{PS_RTX_LOW_LOAD}
...    PSGRP-1:lbpsLastCellRTXMinLoad=100
...    PSGRP-1:lbpsRTXMaxLoad=100
...    PSGRP-1:lbpsRTXMinLoad=100

@{lbpcellperiodlist_FOR_3cells}
...    PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=1440|lbpsCellDayOfWeek=Sun&&lnCelId=1
...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeHour=0|lbpsCellDayOfWeek=Sun&&lnCelId=1
...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeMinute=0|lbpsCellDayOfWeek=Sun&&lnCelId=1
...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Tx Paths Switch Off|lbpsCellDayOfWeek=Sun&&lnCelId=1
...    PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=1440|lbpsCellDayOfWeek=Sun&&lnCelId=2
...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeHour=0|lbpsCellDayOfWeek=Sun&&lnCelId=2
...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeMinute=0|lbpsCellDayOfWeek=Sun&&lnCelId=2
...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lbpsCellDayOfWeek=Sun&&lnCelId=2
...    PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=1440|lbpsCellDayOfWeek=Sun&&lnCelId=3
...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeHour=0|lbpsCellDayOfWeek=Sun&&lnCelId=3
...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeMinute=0|lbpsCellDayOfWeek=Sun&&lnCelId=3
...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lbpsCellDayOfWeek=Sun&&lnCelId=3

@{CELL1_CELL2_CELL3_IN_PSGRP1}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=3|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=3

@{CB008800}
...    LNBTS:actExtCellSOMethod=true
...    LNBTS:actLBPowerSaving=true
...    LNBTS:actLBRTXPowerSaving=true

@{Load_Threshold}
...    PSGRP-1:lbpsLastCellSOEnabled=true
...    PSGRP-1:lbpsLastCellMinLoad=5
...    PSGRP-1:lbpsLastCellRTXMinLoad=5
...    PSGRP-1:lbpsMinLoad=8
...    PSGRP-1:lbpsRTXMinLoad=8
...    PSGRP-1:lbpsMaxLoad=10
...    PSGRP-1:lbpsRTXMaxLoad=10

@{A-B3_01}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=3|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=3

@{A-B3_05}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=100|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=100|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=3

@{A-B3_07}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=3|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=3

@{A-B4_03}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=3|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=3

@{A-B4_03_02}
...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lnCelId=1
...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lnCelId=2
...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lnCelId=3

@{A-B4_03_01}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=4|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=3|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=3

${UE_R11}
...    SEPARATOR=
...    DD9800195F8083817FCFFEBE8848022190A742A08329D2A4B8FC4FF0000000001025E0A025F80000001602004B43EAA306040728002401D00
...    009807400020008381602C0000FD88180B000008E1D8000001C0004C1007CCAD300483F9A

*** Test Cases ***
CB013130_SR_A_B1_10_cells will switch on when online modify lbpsCellList and or lbpsCelPeriodList relatived parameters
    Set cells order    ${A-B4_03}
    Check currently time and modify parameters under lbpsCelPeriodList in three cells    Duration=60
    Wait Cell1 Cell3 Enter RES and Cell2 Enter ES then check status
    Online modify Cell1 method and check status
    Online modify Cell1 order and check status

CB013130_SR_A_B1_01_Cell apply switch off method according to lbpsCellSOMethod and lbpsUseExtConfig setting
    Set cells order    ${A-B3_01}
    Check currently time and modify parameters under lbpsCelPeriodList in three cells
    Wait Cell1 Enter RES And Cell2 Cell3 Enter ES and check status
    UEs attach to eNB1 with PS
    UEs generate load to make cell3 exit ES

CB013130_SR_A_B1_04_Cells with order=100 will be switch off together and on together
    Set cells order
    Check currently time and modify parameters under lbpsCelPeriodList in three cells    Duration=15
    Wait Cell1 Enter RES And Cell2 Cell3 Enter ES and check status
    Wait the cellperiod is expired and check the cells status

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=3
    Set Suite Variable    ${SMOD_ID}    0x2011

Modify Yaml
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on
	Update Yaml    LOGS/CUS   syslog_mode: DEBUG

Check currently time and modify parameters under lbpsCelPeriodList in three cells
    [Arguments]    ${Duration}=60
    ${date}    execute command on enb     date
    ${day_of_week}    set variable    ${date.split()[0]}
    ${hour}    set variable    ${date.split()[3].split(":")[0]}
    ${minute}    set variable    ${date.split()[3].split(":")[1]}
    @{Online_Param}    create list
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=${Duration}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=1
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeHour=${hour}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=1
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeMinute=${minute}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=1
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Tx Paths Switch Off|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=1
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=${Duration}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=2
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeHour=${hour}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=2
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeMinute=${minute}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=2
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=2
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellDuration=${Duration}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=3
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeHour=${hour}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=3
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellStartTimeMinute=${minute}|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=3
    ...    PSGRP-1:lbpsCelPeriodList:lbpsCellSOMethod=Cell Switch Off|lbpsCellDayOfWeek=${day_of_week}&&lnCelId=3
    Delta Commission Parameters    ${Online_Param}

Wait Cell1 Enter RES And Cell2 Cell3 Enter ES and check status
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into energySaving State
    Cell3 Enter Into energySaving State

Wait Cell1 Cell3 Enter RES and Cell2 Enter ES then check status
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Enter Into energySaving State
    Cell3 Enter Into reducedEnergySaving State

UEs attach to eNB1 with PS
    CUS UE attach to eNB1    ue_id=1,2    cell_id=1    UE_EUTRA_CAP=${UE_R11}

CUS UE attach to eNB1
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1    ${UE_EUTRA_CAP}=${UE_R11}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${UE_EUTRA_CAP}
    Execute Uex Command    ${V_1}

UEs generate load
    [Arguments]    ${ue_id}=1    ${mbps}=150
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=${mbps} trf_id=1 stats=true

UEs generate load to make cell3 exit ES
    UEs generate load    ue_id=1
    UEs generate load    ue_id=2
    Cell3 Enter Into notEnergySaving State

Set cells order
    [Arguments]    ${Online_Param}=${A-B3_05}
    Delta Commission Parameters    ${Online_Param}

Wait the cellperiod is expired and check the cells status
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State

Block cell and wait until notES
    Block Cell1
    Cell1 Enter Into notEnergySaving State

unblock cell and wait until ReducedES
    Unblock Cell1
    Cell1 Enter Into reducedEnergySaving State

Trigger Fault On Cell1 and check cells into notES
    Send Lom Fault Ind Msg    sender=0x10110240    receiver=0x10111202    fault_id=6257    state=1    severity=1    object_type=0
    ...    unit_id=1    timeout=20
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State

Cancel Fault On Cell1
    Send Lom Fault Ind Msg    sender=0x10110240    receiver=0x10111202    fault_id=6257    state=0    severity=2    object_type=0
    ...    unit_id=1    timeout=20

Online modify Cell1 method and check status
    Delta Commission Parameters    ${A-B4_03_02}
    Cell1 Enter Into energySaving State
    Cell2 Enter Into energySaving State
    Cell3 Enter Into reducedEnergySaving State

Online modify Cell1 order and check status
    Delta Commission Parameters    ${A-B4_03_01}
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State
    Cell3 Enter Into notEnergySaving State
