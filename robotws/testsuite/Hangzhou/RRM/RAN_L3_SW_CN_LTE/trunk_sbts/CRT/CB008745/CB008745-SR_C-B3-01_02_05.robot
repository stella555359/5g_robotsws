*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG1    owner-zijing.wu    owner-kexin.zhou    release-SBTS23R2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PS_RTX_LOW_LOAD}
...    @{PS_FOR_7X24}
...    PSGRP-1:lbpsCSONCtlEnabled=false
...    LNCEL-1/SIB-0:ulpcIniPrePwr=-106 dBm
...    @{Load_Threshold}
...    @{CELL1_CELL2_CELL3_IN_PSGRP}
...    @{CB008745}
...    @{4pipe}

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

@{Load_Threshold}
...    PSGRP-1:lbpsLastCellSOEnabled=false
...    PSGRP-1:lbpsLastCellMinLoad=3
...    PSGRP-1:lbpsLastCellRTXMinLoad=3
...    PSGRP-1:lbpsMinLoad=3
...    PSGRP-1:lbpsRTXMinLoad=3
...    PSGRP-1:lbpsMaxLoad=6
...    PSGRP-1:lbpsRTXMaxLoad=6

@{4pipe}
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=10
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulCacIgnore=false

@{CB008745}
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS:actLBPowerSaving=false
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actOnlineTXSwitch=false
...    PSGRP-1:lbpsLoadCalcMethod=Max(G_N_combined, P)
...    PSGRP-1:lbpsMonWinForCellSOn=${MonWinForCellSOn}
...    PSGRP-1:lbpsMonWinForCellSOff=${MonWinForCellSOff}
...    PSGRP-1:lbpsMonWinForRtxSOn=${MonWinForRtxSOn}
...    PSGRP-1:lbpsMonWinForRtxSOff=${MonWinForRtxSOff}
...    PSGRP-1:lbpsSOnTrRule=SlidingAverageMethod
...    PSGRP-1:lbpsSOffTrRule=SlidingAverageMethod

@{CELL1_CELL2_CELL3_IN_PSGRP}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2


${MonWinForCellSOn}    80
${MonWinForCellSOff}    350
${MonWinForRtxSOn}    350
${MonWinForRtxSOff}    200
${MonWinForRtxSOff_default}    300

@{recover}
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS:actLBPowerSaving=false
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actOnlineTXSwitch=false

@{C-B3_01_01}
...    LNBTS:actLBRTXPowerSaving=true
...    LNBTS:actOnlineTXSwitch=true
...    PSGRP-1:lbpsLastCellSOEnabled=false
...    PSGRP-1:lbpsLastCellMinLoad=3
...    PSGRP-1:lbpsLastCellRTXMinLoad=3
...    PSGRP-1:lbpsMinLoad=3
...    PSGRP-1:lbpsRTXMinLoad=3
...    PSGRP-1:lbpsMaxLoad=30
...    PSGRP-1:lbpsRTXMaxLoad=30

@{C-B3_01_02}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    PSGRP-1:lbpsLastCellSOEnabled=true

${MonWinForRtxSOn_02_01}    80
${MonWinForRtxSOff_02_01}    90

@{C-B3_02_01}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS:actLBRTXPowerSaving=true
...    LNBTS:actOnlineTXSwitch=true
...    PSGRP-1:lbpsMonWinForRtxSOn=${MonWinForRtxSOn_02_01}
...    PSGRP-1:lbpsMonWinForRtxSOff=${MonWinForRtxSOff_02_01}

${MonWinForRtxSOn_02_02}    240
${MonWinForRtxSOff_02_02}    240

@{C-B3_02_02}
...    PSGRP-1:lbpsLoadCalcMethod=Max(G, W, P)
...    PSGRP-1:lbpsSOnTrRule=MinValueMethod
...    PSGRP-1:lbpsSOffTrRule=MaxValueMethod
...    PSGRP-1:lbpsLastCellSOEnabled=true
...    PSGRP-1:lbpsMonWinForRtxSOff=${MonWinForRtxSOff_02_02}
...    PSGRP-1:lbpsMonWinForRtxSOn=${MonWinForRtxSOn_02_02}

${MonWinForCellSOn_05_01}    180
${MonWinForCellSOff_05_01}    180
${MonWinForRtxSOn_05_01}    60
${MonWinForRtxSOff_05_01}    60

@{C-B3_05_01}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS:actLBPowerSaving=true
...    LNBTS:actLBRTXPowerSaving=true
...    LNBTS:actOnlineTXSwitch=true
...    PSGRP-1:lbpsLastCellSOEnabled=true
...    LNBTS:actExtCellSOMethod=true
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=true|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=3
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=3|lnCelId=3
...    PSGRP-1:lbpsLastCellMinLoad=3
...    PSGRP-1:lbpsLastCellRTXMinLoad=3
...    PSGRP-1:lbpsMinLoad=3
...    PSGRP-1:lbpsRTXMinLoad=3
...    PSGRP-1:lbpsMaxLoad=6
...    PSGRP-1:lbpsRTXMaxLoad=6
...    PSGRP-1:lbpsLoadCalcMethod=Max(G_N_combined, P)
...    PSGRP-1:lbpsMonWinForCellSOn=${MonWinForCellSOn_05_01}
...    PSGRP-1:lbpsMonWinForCellSOff=${MonWinForCellSOff_05_01}
...    PSGRP-1:lbpsMonWinForRtxSOn=${MonWinForRtxSOn_05_01}
...    PSGRP-1:lbpsMonWinForRtxSOff=${MonWinForRtxSOff_05_01}
...    PSGRP-1:lbpsSOnTrRule=MinValueMethod
...    PSGRP-1:lbpsSOffTrRule=MaxValueMethod

@{PARAMS_IN_EMIL}
...    0x436C
...    0x460F
...    0x45D1
...    0x4610
...    0x4387
...    0x269B
...    0x269C
...    0x4360
...    0x4361
...    0x43A5
...    0x2113
...    0x2114
...    0x4393
...    0x2100
...    0x210E
...    0x210F
...    0x2110
...    0x2693

@{PARAMS_IN_VENDOR}
...    LNBTS:mimoClCqiComp=0
...    LNBTS:mimoOlCqiComp=0

${SWITCH_TIMEOUT_ES}    1 min 30 s

${UE_R11}
...    SEPARATOR=
...    DD9800195F8083817FCFFEBE8848022190A742A08329D2A4B8FC4FF0000000001025E0A025F80000001602004B43EAA306040728002401D00
...    009807400020008381602C0000FD88180B000008E1D8000001C0004C1007CCAD300483F9A

*** Test Cases ***
CB008745-SR-C-B3_ET_01_01_Enbc should apply new parameters setting when online enabled actLbpsCtrlLogicEnh and cell is 4TX
    [Tags]
    Delta Commission Parameters    ${C-B3_01_01}
    Cell1 Keep In notEnergySaving State
    Cell2 Keep In notEnergySaving State
    Wait cells enter into reduceES and check states
    Cells Should Be OnAir
    Attach UEs to cell2
    UEs generate load to make cells exit reduceES
    Delta Commission Parameters    ${recover}
    Release All UEs

CB008745-SR-C-B3_ET_01_02_Enbc should support online modify new parameters when cell is 4TX with only LTE1203 enabled
    [Tags]
    Delta Commission Parameters    ${C-B3_02_01}
    Cell1 Keep In notEnergySaving State
    Cell2 Keep In notEnergySaving State
    Online change conf and wait cells enter into reduceES and check states
    Attach UEs to cell2
    UEs generate load to make cells exit reduceES    ontime=${MonWinForRtxSOn_02_02}
    Delta Commission Parameters    ${recover}
    Release All UEs

CB008745-SR-C-B3_ET_01_05_Enbc should support online modify new parameters when CB008800 is enabled
    [Tags]
    Check currently time and modify parameters under lbpsCelPeriodList in three cells
    Cell1 Keep In notEnergySaving State
    Cell2 Keep In notEnergySaving State
    Cell3 Keep In notEnergySaving State
    Wait cells enter into different state and check
    Release All UEs

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on

CUS UE attach to eNB1
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1    ${UE_EUTRA_CAP}=${UE_R11}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${UE_EUTRA_CAP}
    Execute Uex Command    ${V_1}

Cell${number} Keep In notEnergySaving State
    Energy Saving State Should Be    ${number}    notEnergySaving

Cell${number} Enter Into energySaving State
    Wait Until Keyword Succeeds    ${SWITCH_TIMEOUT_ES}    10 s    Energy Saving State Should Be    ${number}    energySaving

Cell${number} Keep In reducedEnergySaving State
    Energy Saving State Should Be    ${number}    reducedEnergySaving

Energy Saving State Should Be
    [Arguments]    ${lcr}    ${psm_exp}
    ${value}    get_scf_parameter_value    LNCEL-${lcr}:energySavingState
    Should Match Regexp    ${value}    ${psm_exp}

Wait cells enter into reduceES and check states
    sleep    ${MonWinForRtxSOff_default}s
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Keep In notEnergySaving State
    Delta Commission Parameters    ${C-B3_01_02}
    sleep    ${MonWinForRtxSOff}s
    Cell2 Enter Into reducedEnergySaving State
    Cell1 Keep In reducedEnergySaving State

Attach UEs to cell2
    CUS UE attach to eNB1    ue_id=1..4    cell_id=2    UE_EUTRA_CAP=${UE_R11}

UEs generate load
    [Arguments]    ${ue_id}=1    ${mbps}=150
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=${mbps} trf_id=1 stats=true

UEs generate load to make cells exit reduceES
    [Arguments]    ${ontime}=${MonWinForRtxSOn}
    UEs generate load    ue_id=1
    UEs generate load    ue_id=2
    UEs generate load    ue_id=3
    UEs generate load    ue_id=4
    Sleep    ${ontime}s
    Cell1 Enter Into notEnergySaving State
    Cell2 Enter Into notEnergySaving State

Online change conf and wait cells enter into reduceES and check states
    sleep    ${MonWinForRtxSOff_02_01}s
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Keep In notEnergySaving State
    Delta Commission Parameters    ${C-B3_02_02}
    sleep    ${MonWinForRtxSOff_02_01}s
    Cell2 Keep In notEnergySaving State
    sleep    ${${MonWinForRtxSOff_02_02}-${MonWinForRtxSOff_02_01}}s
    Cell1 Keep In reducedEnergySaving State
    Cell2 Enter Into reducedEnergySaving State

Check currently time and modify parameters under lbpsCelPeriodList in three cells
    [Arguments]    ${Duration}=30
    ${date}    execute command on enb     date
    ${day_of_week}    set variable    ${date.split()[0]}
    ${hour}    set variable    ${date.split()[3].split(":")[0]}
    ${minute}    set variable    ${date.split()[3].split(":")[1]}
    @{Online_Param}    create list
    ...    @{C-B3_05_01}
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

Wait cells enter into different state and check
    sleep    ${${MonWinForRtxSOff_05_01}+5}s
    Cell1 Enter Into reducedEnergySaving State
    Cell2 Keep In notEnergySaving State
    sleep    ${${MonWinForCellSOff_05_01}+70}s
    Cell2 Enter Into energySaving State
    Cell3 Keep In notEnergySaving State
    sleep    ${${MonWinForRtxSOff_05_01}+5}s
    Cell3 Enter Into reducedEnergySaving State
    Cell1 Keep In reducedEnergySaving State
    Cell2 Keep In EnergySaving State
