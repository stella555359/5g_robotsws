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
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4A_CUS
...               team-DevHZ5_CN3ET    owner-han.pei    owner-kexin.zhou    release-SBTS23R2
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PS_FOR_7X24}
...    @{CLOSE_CGI_COMP_SCF}
...    PSGRP-1:lbpsCSONCtlEnabled=false
...    LNCEL-1/SIB-0:ulpcIniPrePwr=-106 dBm
...    @{CB008800}
...    @{Load_Threshold}
...    @{CELL1_CELL2_CELL3_IN_PSGRP1}
...    @{LTE1103}
...    @{LTE1203}
...    @{CB008745}
...    @{dlMimoMode}
...    @{Others}
...    MRBTS/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1:actGnssOutputLnaPowerSupply=true

@{CLOSE_CGI_COMP_SCF}
...    LNBTS/LNBTS_TDD-0:dlOlqcDeltaCqiMax=0
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

@{dlMimoMode}
...    LNCEL/LNCEL_TDD-0:actTmSwitch=true
...    LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=beamforming
...    LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=nonBeamforming
...    LNCEL/LNCEL_TDD-0:dlMimoMode=Dynamic Open Loop MIMO
...    LNCEL/LNCEL_TDD-0:bfWeightAgingCoeff=1

@{CELL1_CELL2_CELL3_IN_PSGRP1}
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsCellSOOrder=2|lnCelId=2
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=1
...    PSGRP-1:lbpsCellList:lbpsUseExtConfig=false|lnCelId=2

@{CB008800}
...    LNBTS:actExtCellSOMethod=false
@{LTE1103}
...    LNBTS:actLBPowerSaving=true
@{LTE1203}
...    LNBTS:actLBRTXPowerSaving=true
...    LNBTS:actOnlineTXSwitch=true
@{CB008745}
...    LNBTS:actLbpsCtrlLogicEnh=false
...    LNBTS/PSGRP-1:lbpsLoadCalcMethod=Max(G, W, P)
...    LNBTS/PSGRP-1:lbpsMonWinForCellSOff=${lbpsMonWinForCellSOff}
...    LNBTS/PSGRP-1:lbpsMonWinForCellSOn=${lbpsMonWinForCellSOn}
...    LNBTS/PSGRP-1:lbpsMonWinForRtxSOff=${lbpsMonWinForRtxSOff}
...    LNBTS/PSGRP-1:lbpsMonWinForRtxSOn=${lbpsMonWinForRtxSOn}
...    LNBTS/PSGRP-1:lbpsSOffTrRule=MaxValueMethod
...    LNBTS/PSGRP-1:lbpsSOnTrRule=MinValueMethod
...    LNBTS/PSGRP-1:lbpsPdcchLoadOffset=2
...    LNBTS/PSGRP-1:lbpsRTXMaxLoad=99

${lbpsMonWinForCellSOn}    90
${lbpsMonWinForRtxSOn}    30
${lbpsMonWinForCellSOff}    300
${lbpsMonWinForRtxSOff}    30

@{Load_Threshold}
...    PSGRP-1:lbpsLastCellSOEnabled=true
...    PSGRP-1:lbpsLastCellMinLoad=2
...    PSGRP-1:lbpsLastCellRTXMinLoad=2
...    PSGRP-1:lbpsMinLoad=3
#lbpsRTXMinLoad change from 2 to 0 to fix robustness
...    PSGRP-1:lbpsRTXMinLoad=0
...    PSGRP-1:lbpsMaxLoad=5
...    PSGRP-1:lbpsRTXMaxLoad=3

@{Others}
...    LNCEL:actModulationSchemeDl=64QAM
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=1
...    LNCEL:mbrSelector=ueCapability

@{C-B1_01}
...    LNBTS:actLBPowerSaving=false
...    LNBTS:actLbpsCtrlLogicEnh=true
...    LNBTS/PSGRP-1:lbpsRTXMaxLoad=3

${UE_R11}
...    SEPARATOR=
...    DD9800195F8083817FCFFEBE8848022190A742A08329D2A4B8FC4FF0000000001025E0A025F80000001602004B43EAA306040740002401D00
...    00980740002000839BFFFB01600007EC40C0580000470EC000000E000260803E656980641FCDEA000600DA0

@{PARAMS_IN_SWCONFIG}
...    ${TEnbcRadLowLoadSwitchOffDelay}=60    #avoid ENB startup too long lead cell into switchoff
${TEnbcRadLowLoadSwitchOffDelay}    0x110016

*** Test Cases ***

CB008745-SR-C-B1_ET_01_01_Cells with 8TX will start to enter and exit ReducedES after lbpsMonWinForRtxSOff and lbpsMonWinForRtxSOn
    [Tags]
    CUS UE attach to eNB1    ue_id=1    cell_id=1
    CUS UE attach to eNB1    ue_id=2    cell_id=2
    Delta Commission Parameters    ${C-B1_01}
    Cell1 Keep In notEnergySaving State
    Cell2 Keep In notEnergySaving State
    Wait cells enter into ES and check status
    UEs generate load to make cell1 exit ES

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_TDD_8PIPEs
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on

CUS UE attach to eNB1
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${cell_id}=1    ${UE_EUTRA_CAP}=${UE_R11}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id} ue_eutra_capabilities=${UE_EUTRA_CAP}
    Execute Uex Command    ${V_1}

Wait cells enter into ES and check status
    Sleep    ${${lbpsMonWinForRtxSOff}+10}s
    Cell1 Keep In SwitchingOffRtx or reducedEnergySaving State
    Sleep    ${${lbpsMonWinForRtxSOff}+10}s
    Cell2 Keep In SwitchingOffRtx or reducedEnergySaving State

Cell${number} Keep In SwitchingOffRtx or reducedEnergySaving State
    Energy Saving State Should Be    ${number}    switchingOffRTX|SwitchingOffRtx|reducedEnergySaving

UEs generate load to make cell1 exit ES
    UEs generate load    1    mbps=100
    UEs generate load    2    mbps=100
    Sleep    ${${lbpsMonWinForRtxSOn}+20}s
    Cell2 Keep In notEnergySaving State
    Cell1 Keep In notEnergySaving State

UEs generate load
    [Arguments]    ${ue_id}=1    ${mbps}=150
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp Mbps=${mbps} trf_id=1 stats=true

Get Throughput
    [Arguments]    ${ue_id}=1
    Execute Uex Command    get_trf_data_stats ue=${ue_id}

