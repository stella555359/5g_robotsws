*** Settings ***
Documentation
...          Option 1: Load_quantity = Max{GBR, weight-based non-GBR, PDCCH}load
...          Option 2: Load_quantity = Max{GBR + PRB-usage-based nonGBR, PDCCH}load
...          Option 1: switch_on_rule = min 10s load in monitoring time > max_thr
...          Option 2: switch_on_rule = Load(Average volume in switch on monitoring time) > max_thr
...          Option 1: switch_off_rule =(Max 10s load in switch on monitoring time <= min_thr) AND
...          (LoadAftSwOff(latest 10s volume) <= max_thr)
...          Option 2: switch_off_rule =LoadAftSwOff(Average volume in switch_off_load_window) <= min_thr
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               team-SG1    owner-pei.han    owner-kexin.zhou    release-SBTS23R2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PS_FOR_7X24}
...    PSGRP-1:lbpsCSONCtlEnabled=false
...    LNCEL-1/SIB-0:ulpcIniPrePwr=-106 dBm
...    @{CB008800}
...    @{Load_Threshold}
...    @{CELL1_CELL2_CELL3_IN_PSGRP1}
...    @{LTE1103}
...    @{LTE1203}
...    @{CB008745}
...    @{Others}

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

@{CELL1_CELL2_CELL3_IN_PSGRP1}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=2
@{Load_Threshold}
...    PSGRP-1:lbpsLastCellSOEnabled=false
...    PSGRP-1:lbpsLastCellMinLoad=2
...    PSGRP-1:lbpsLastCellRTXMinLoad=2
...    PSGRP-1:lbpsMinLoad=3
...    PSGRP-1:lbpsRTXMinLoad=3
...    PSGRP-1:lbpsMaxLoad=5
...    PSGRP-1:lbpsRTXMaxLoad=5
@{Others}
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=1
...    LNCEL:mbrSelector=ueCapability
@{CB008800}
...    LNBTS:actExtCellSOMethod=false
@{LTE1103}
...    LNBTS:actLBPowerSaving=false
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:nomNumPrbNonGbr=1
@{LTE1203}
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actOnlineTXSwitch=false
@{CB008745}
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS/PSGRP-1:lbpsLoadCalcMethod=Max(G, W, P)
...    LNBTS/PSGRP-1:lbpsMonWinForCellSOff=${lbpsMonWinForCellSOff}
...    LNBTS/PSGRP-1:lbpsMonWinForCellSOn=${lbpsMonWinForCellSOn}
...    LNBTS/PSGRP-1:lbpsMonWinForRtxSOff=${lbpsMonWinForRtxSOff}
...    LNBTS/PSGRP-1:lbpsMonWinForRtxSOn=${lbpsMonWinForRtxSOn}
...    LNBTS/PSGRP-1:lbpsSOffTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsSOnTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsPdcchLoadOffset=4

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


@{A-B2_01}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS:actLBPowerSaving=true
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actOnlineTXSwitch=false
...    LNBTS/PSGRP-1:lbpsLoadCalcMethod=Max(G, W, P)
...    LNBTS/PSGRP-1:lbpsSOffTrRule=MaxValueMethod
...    LNBTS/PSGRP-1:lbpsSOnTrRule=MinValueMethod
...    LNBTS/PSGRP-1:lbpsPdcchLoadOffset=0
...    PSGRP-1:lbpsMinLoad=3
...    PSGRP-1:lbpsMaxLoad=8
...    PSGRP-1:lbpsLastCellMinLoad=0

@{A-B3_02}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS:actLBPowerSaving=true
...    LNBTS:actLBRTXPowerSaving=false
...    LNBTS:actOnlineTXSwitch=false
...    LNBTS/PSGRP-1:lbpsLoadCalcMethod=Max(G_N_combined, P)
...    LNBTS/PSGRP-1:lbpsSOffTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsSOnTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsPdcchLoadOffset=0
...    PSGRP-1:lbpsMinLoad=21
...    PSGRP-1:lbpsMaxLoad=25
...    PSGRP-1:lbpsLastCellMinLoad=0

@{C-B2_02}
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS:actLBPowerSaving=false
...    LNBTS:actLBRTXPowerSaving=true
...    LNBTS:actOnlineTXSwitch=true
...    LNBTS/PSGRP-1:lbpsLoadCalcMethod=Max(G, W, P)
...    LNBTS/PSGRP-1:lbpsSOffTrRule=SlidingAverageMethod
...    LNBTS/PSGRP-1:lbpsSOnTrRule=MinValueMethod
...    LNBTS/PSGRP-1:lbpsPdcchLoadOffset=3
...    PSGRP-1:lbpsRTXMinLoad=3
...    PSGRP-1:lbpsRTXMaxLoad=5
...    PSGRP-1:lbpsLastCellRTXMinLoad=2

${lbpsMonWinForCellSOn}    60
${lbpsMonWinForRtxSOn}    70
${lbpsMonWinForCellSOff}    80
${lbpsMonWinForRtxSOff}    90

${SWITCH_TIMEOUT_ES}    1 min 30 s

${ue_eutra_capabilities}
...    SEPARATOR=
...    DD9800195F8083817FCFFEBE8848022190A742A08329D2A4B8FC4FF0000000001025E0A025F80000001602004B43EAA306040728002401D00
...    009807400020008381602C0000FD88180B000008E1D8000001C0004C1007CCAD300483F9A

*** Test Cases ***
CB008745-SR-A-B2_ET_01_01_Cells will start to enter and exit ES when lbpsMonWinForCellSOff and lbpsMonWinForCellSOn are expired
    [Tags]
    Delta Commission Parameters    ${A-B2_01}
    Cell2 Keep In notEnergySaving State
    Cell1 Keep In notEnergySaving State
    Wait cells enter into ES and check status
    CUS UE attach to eNB1    cell_id=2
    UEs generate load
    Wait cells exit ES
    Release All UEs

CB008745-SR-A-B3_ET_01_02_Enbc will use new load quantity for Pgload calculation and new switch off and on rule
    [Tags]
    Delta Commission Parameters    ${A-B3_02}
    Block and Unblock Cells and UE Attach    mbps=30
    Check Cell1 status
    UEs change load    mbps=15
    Wait cells enter into ES and check status
    UEs change load    mbps=20
    Wait cells exit ES
    Release All UEs

CB008745-SR-C-B2_ET_01_02_Enbc will use legacy load quantity for Pgload calculation and switch off and on rule are different
    [Tags]
    Delta Commission Parameters    ${C-B2_02}
    Block and Unblock Cells and UE Attach
    Check Cell1 status    sleep_time=${lbpsMonWinForRtxSOff}
    UEs change load    mbps=1
    Wait cells enter into rES and check status
    UEs change load    mbps=100
    Wait cells exit rES and check status
    Release All UEs

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on


CUS UE attach to eNB1
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1    ${UE_EUTRA_CAP}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${UE_EUTRA_CAP}
    Execute Uex Command    ${V_1}

Cell${number} Keep In notEnergySaving State
    Energy Saving State Should Be    ${number}    notEnergySaving

Cell${number} Enter Into energySaving State
    Wait Until Keyword Succeeds    ${SWITCH_TIMEOUT_ES}    10 s    Energy Saving State Should Be    ${number}    energySaving

Cell${number} Keep In SwitchingOffRtx or reducedEnergySaving State
    Energy Saving State Should Be    ${number}    switchingOffRTX|SwitchingOffRtx|reducedEnergySaving

Energy Saving State Should Be
    [Arguments]    ${lcr}    ${psm_exp}
    ${value}    get_scf_parameter_value    LNCEL-${lcr}:energySavingState
    Should Match Regexp    ${value}    ${psm_exp}

Wait cells enter into ES and check status
    Sleep    ${lbpsMonWinForCellSOff}s
    Cell1 Enter Into energySaving State
    Sleep    ${lbpsMonWinForCellSOff}s
    Cell2 Keep In notEnergySaving State

UEs generate load
    [Arguments]    ${ue_id}=1    ${mbps}=150
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=${mbps} trf_id=1 stats=true

UEs change load
    [Arguments]    ${ue_id}=1    ${mbps}=150
    Execute Uex Command    trf_data_stop ue=1
    Get Throughput
    Execute Uex Command    trf_data_start ue=1 dir=dl protocol=udp Mbps=${mbps} trf_id=1 stats=true

Wait cells exit ES
    Sleep    ${${lbpsMonWinForCellSOn}+10}s
    Cell2 Keep In notEnergySaving State
    Cell1 Keep In notEnergySaving State

Block and Unblock Cells and UE Attach
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=2    ${mbps}=150
    Block Cell1
    CUS UE attach to eNB1    ${ue_id}    ${enb_id}    ${cell_id}
    UEs generate load    ${ue_id}    ${mbps}
    Unblock Cell1

Check Cell1 status
    [Arguments]    ${sleep_time}=${lbpsMonWinForCellSOff}
    Sleep    ${${sleep_time}+10}s
    Get Throughput
    Cell1 Keep In notEnergySaving State

Get Throughput
    [Arguments]    ${ue_id}=1
    Execute Uex Command    get_trf_data_stats ue=${ue_id}

Wait cells enter into rES and check status
    Sleep    ${${lbpsMonWinForRtxSOff}+10}s
    Cell1 Keep In SwitchingOffRtx or reducedEnergySaving State
    Sleep    ${${lbpsMonWinForRtxSOff}+10}s
    Cell2 Keep In notEnergySaving State

Wait cells exit rES and check status
    Sleep    ${${lbpsMonWinForRtxSOn}+15}s
    Cell2 Keep In notEnergySaving State
    Cell1 Keep In notEnergySaving State