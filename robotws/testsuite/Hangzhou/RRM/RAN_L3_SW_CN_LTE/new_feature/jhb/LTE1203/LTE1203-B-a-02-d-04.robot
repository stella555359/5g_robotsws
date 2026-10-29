*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               release-TL16    owner-Huabao.Jiang    team-DevHZ5_SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
#...  LNCEL-1:cqiAperEnable=false
#...  LNCEL-2:cqiAperEnable=false
#...  LNCEL-3:cqiAperEnable=false
...  LNBTS:actLBPowerSaving=false
...  LNBTS:actLBRTXPowerSaving=false
...  PSGRP-1:lbpsLastCellSOEnabled=true
...  PSGRP-1:lbpsCellList:lbpsCellSOOrder=1|lnCelId=1
...  @{PS_RTX_LOW_LOAD}
...  @{PS_FOR_7X24}
...  @{CLOSE_CGI_COMP_SCF}
...  LNCELL-1/LNCEL_TDD-0:actTmSwitch=true
...  PSGRP-1:lbpsCSONCtlEnabled=false
...  LNCEL-1/SIB-0:ulpcIniPrePwr=-106 dBm
@{PARAMS_IN_IPHY_XML}
...  GeneralSettings:EnergySavingFeature=yes
@{PARAMS_IN_VENDOR}
...  @{CLOSE_CGI_COMP_VENDOR}
${HIGH_LOAD_SWITCHON_trigger}    0x00110017
${LOW_LOAD_SWITCHOFF_trigger}    0x00110016
@{PARAMS_IN_SWCONFIG}
...  ${HIGH_LOAD_SWITCHON_trigger}=${HIGH_LOAD_SWITCHON_DELAY}
...  ${LOW_LOAD_SWITCHOFF_trigger}=${LOW_LOAD_SWITCHOFF_DELAY}
${HIGH_LOAD_SWITCHON_DELAY}    2min
@{CELL1_CELL2_IN_PSGRP1}
...  PSGRP-1:lbpsCellList:lbpsCellSOOrder=10|lnCelId=1
...  PSGRP-1:lbpsCellList:lbpsCellSOOrder=20|lnCelId=2
...  delete:PSGRP-1:lbpsCellList:lbpsCellSOOrder=100|lnCelId=3
@{pm_counters1}
...  LNCELL-1:LTE_Cell_Avail:${CHNG_TO_CELL_UNPLAN_UNAVAIL} = 0
...  LNCELL-1:LTE_Cell_Avail:${SAMPLES_CELL_RTX_PWR_SAVING}<10
...  LNCELL-1:LTE_Cell_Avail:${CHNG_TO_CELL_RTX_PWR_SAVING}=0
@{pm_counters2}
...  LNCELL-1:LTE_Cell_Avail:${CHNG_TO_CELL_UNPLAN_UNAVAIL} = 1
...  LNCELL-1:LTE_Cell_Avail:${SAMPLES_CELL_RTX_PWR_SAVING}>10
...  LNCELL-1:LTE_Cell_Avail:${CHNG_TO_CELL_RTX_PWR_SAVING}=1
${CHNG_TO_CELL_UNPLAN_UNAVAIL}    M8020C2
${SAMPLES_CELL_RTX_PWR_SAVING}    M8020C9
${CHNG_TO_CELL_RTX_PWR_SAVING}    M8020C10
${PM_SPEED_UP_FLAG}    ${True}
@{PS_RTX_LOW_LOAD}
...  PSGRP-1:lbpsLastCellRTXMinLoad=100
...  PSGRP-1:lbpsRTXMaxLoad=100
...  PSGRP-1:lbpsRTXMinLoad=100
@{PS_FOR_7X24}
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sun
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sun
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sun
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sun
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Mon
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Mon
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Mon
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Mon
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Tue
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Tue
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Tue
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Tue
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Wed
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Wed
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Wed
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Wed
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Thu
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Thu
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Thu
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Thu
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Fri
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Fri
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Fri
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Fri
...  PSGRP-1:lbpsPeriodList:lbpsSuspended=notSuspended|lbpsDayOfWeek=Sat
...  PSGRP-1:lbpsPeriodList:lbpsDuration=1440|lbpsDayOfWeek=Sat
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeHour=0|lbpsDayOfWeek=Sat
...  PSGRP-1:lbpsPeriodList:lbpsStartTimeMinute=0|lbpsDayOfWeek=Sat
@{CLOSE_CGI_COMP_SCF}
...  LNBTS/LNBTS_TDD-0:dlOlqcDeltaCqiMax=0
...  LNCEL/LNCEL_TDD-0:mimoBfCqidlComp=0
@{CLOSE_CGI_COMP_VENDOR}
...  LNBTS:mimoClCqiComp=0
...  LNBTS:mimoOlCqiComp=0
${UE_R11}
...  CD9FF4F9B2E7500010610102912464D0312040E07FFFFFFFFCA18800182008295020022A0060B3FFFFFFFE014FFFFFFFFC
${2tx}
...    transmissionMode-r10 eq 'tm4' and
...    codebookSubsetRestriction-r10 eq '0b111111'
${4tx}
...    transmissionMode-r10 eq 'tm4' and
...    codebookSubsetRestriction-r10 eq '0b0000000000000000000000000000000011111111111111111111111111111111'
${CUS_LOG_LEVEL}    ERROR
${CUS_SYSLOG_MODE}    DEBUG
${TTITRACE_FLAG}  ${True}
${CUS_PCAP_FLAG}  ${False}
${CUS_PCAP_OPTIONS}   -c 1 --phy --sch --l2

*** Test Cases ***
LTE1203-B-a_01_02_EI_TX Path Switch-off with dlMimoMode is TM4 by 4 multiple 2 and enable actTmSwitch
    [Tags]    QC_26964
    Enable actLBRTXPowerSaving
    start to capture cus pcap
    Wait LowLoadSwitchOffDelay
    Cell1 Enter Into reducedEnergySaving State
    CUS UE attach to eNB1 with PS
    Disable actLBRTXPowerSaving
    CUS UE attach to eNB1 without PS

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
	execute egate command    trace_sim uec=1 protocol=rrc on
    execute egate command    trace_sim on mme=1 protocol=s1
    ${SMOD_ID}=    Set Variable If    '${RACK_POSITION}' == 'left'    0x1011    0x2011
    Set Suite Variable    ${SMOD_ID}
    Create UE Alias    UE_1    ue_id=1    id_type=cus

Modify Yaml
    Update Yaml    BASE_STATIONS/1/cus_config/1    energy_saving_feature: on
    Update Yaml    BASE_STATIONS/1/cus_config/1    sch_mmi_ue_debug: ON
#    update yaml    LOGS/CUS    syslog_mode: 1
#    update yaml    LOGS/CUS    log_level: ERROR
    add yaml    LOGS/CUS
    ...    sch_mmi_ue_debug: ON
    ...    logger:
    ...      proxy: 1
    ...      prach: 1
    ...      pucch: 1
    ...      pusch: 1
    ...      hpm: 1
    ...      l2_proxy: 1

Enable actLBRTXPowerSaving
    Delta Commission Parameters    LNBTS:actLBRTXPowerSaving\=true

Disable actLBRTXPowerSaving
    Delta Commission Parameters    LNBTS:actLBRTXPowerSaving\=false

CUS UE attach to eNB1
    [Arguments]    ${ue_id}=1   ${ue_eutra_capabilities}=${UE_R11}
    execute uex command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities}

CUS UE Detach
    [Arguments]    ${ue_id}=1
    execute uex command    ue_detach id=${ue_id}

CUS UE attach to eNB1 with PS
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${2tx})
    ...    alias=2tx    overall_timeout=30
	execute egate command    ue_mme_param id=1 power_saving_mode_enabled=on
    CUS UE attach to eNB1    ue_eutra_capabilities=${UE_R11}
    flow occurred as expected    alias=2tx
    CUS UE Detach

CUS UE attach to eNB1 without PS
    Cell1 Enter Into notEnergySaving State
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${4tx})
    ...    alias=4tx    overall_timeout=30
    CUS UE attach to eNB1    ue_eutra_capabilities=${UE_R11}
    flow occurred as expected    alias=4tx
    CUS UE Detach
	
Wait Cells To Restore NotES
    sleep    90s    #wait cells enter into NotES
	
Cell${number} Enter Into switchingOffRTX State
    ${cell_info}    Get Cell Info    ${number}
    ${SWITCH_TIMEOUT}    Set Variable If    ${cell_info["pipes_num"]}==8    ${SWITCHOFF_TIMEOUT_8PIPES}    ${SWITCHOFF_TIMEOUT_4PIPES_2PIPES}
    Wait Until Keyword Succeeds    ${SWITCH_TIMEOUT}    10 s    Energy Saving State Should Be    ${number}    switchingOffRTX
    ${active_pipes_exp}    Set Variable If    ${cell_info["pipes_num"]}==2    1    2