*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS18    team-DevHZ5_SG4    owner-rebecca.zhong
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  LNCEL:actModulationSchemeDl=256QAM
...  LNCEL:actDl256QamChQualEst=true
...  LNCEL:iniDl256QamChQualEst=240s
...  LNCEL:perDl256QamChQualEst=240s
...  LNCEL:dl256QamReactChQualThr=24
...  LNCEL:dl256QamDeactChQualThr=15
@{iniDl256QamChQualEst_minimum}
...  LNCEL:iniDl256QamChQualEst=1s
@{perDl256QamChQualEst_minimum}
...  LNCEL:perDl256QamChQualEst=1s
@{iniDl256QamChQualEst_maximum}
...  LNCEL:iniDl256QamChQualEst=240s
@{perDl256QamChQualEst_maximum}
...  LNCEL:perDl256QamChQualEst=240s
@{iniDl256QamChQualEst_middle}
...  LNCEL:iniDl256QamChQualEst=30s
@{perDl256QamChQualEst_middle}
...  LNCEL:perDl256QamChQualEst=5s
@{Param_A_b_001}
...  @{iniDl256QamChQualEst_minimum}
...  @{perDl256QamChQualEst_minimum}
@{Param_A_b_002}
...  @{iniDl256QamChQualEst_maximum}
...  @{perDl256QamChQualEst_minimum}
@{Param_A_b_005}
...  @{iniDl256QamChQualEst_maximum}
...  @{perDl256QamChQualEst_middle}
@{Param_A_b_007_1}
...  LNCEL:actDl256QamChQualEst=false
@{Param_A_b_007_2}
...  LNCEL:actDl256QamChQualEst=true
...  @{iniDl256QamChQualEst_middle}
...  @{perDl256QamChQualEst_middle}
@{Param_A_c_001}
...  @{iniDl256QamChQualEst_minimum}
...  @{perDl256QamChQualEst_minimum}
${MIN_VALUE_OF_INITIAL_TIMER}    1
${MID_VALUE_OF_INITIAL_TIMER}    30
${MAX_VALUE_OF_INITIAL_TIMER}    240
${MIN_VALUE_OF_PERIOD_TIMER}    1
${MID_VALUE_OF_PERIOD_TIMER}    5
${MAX_VALUE_OF_PERIOD_TIMER}    240
@{SWCONFIG_FLAGS}
...  0x1e0146=0x80000008
${DWGRADE_256QAM_ATT}    M8007C20
${DWGRADE_256QAM_SUCC}    M8007C21
${UPGRADE_256QAM_ATT}    M8007C22
${UPGRADE_256QAM_SUCC}    M8007C23
${UPGRADE_256QAM_ATT_cell1_and_cell2}    M8007C22
${UPGRADE_256QAM_SUCC_cell1_and_cell2}    M8007C23
${UE_ACTIVE_TIME_256QAM}    M8007C24
${ue_eutra_capabilities}  SEPARATOR=
...  D1B8048308427D10C180300600C1BFBFFEC800801C1E40000000152A56E2030108000240000670000D000060C0180300605040000028A23069
...  300407FF6A
@{rtpm_counters_A_b_001}
...  ${DWGRADE_256QAM_ATT} =1
...  ${DWGRADE_256QAM_SUCC} =1
...  ${UPGRADE_256QAM_ATT}=1
...  ${UPGRADE_256QAM_SUCC}= 1
...  ${UE_ACTIVE_TIME_256QAM}>0
@{rtpm_counters_A_b_002}
...  ${DWGRADE_256QAM_ATT} =1
...  ${DWGRADE_256QAM_SUCC} =1
...  ${UPGRADE_256QAM_ATT}=1
...  ${UPGRADE_256QAM_SUCC}= 1
...  ${UE_ACTIVE_TIME_256QAM}>0
@{rtpm_counters_A_b_005}
...  ${DWGRADE_256QAM_ATT} =4
...  ${DWGRADE_256QAM_SUCC} =4
...  ${UPGRADE_256QAM_ATT}=4
...  ${UPGRADE_256QAM_SUCC}= 4
...  ${UE_ACTIVE_TIME_256QAM}>0
@{rtpm_counters_A_b_007}
...  ${DWGRADE_256QAM_ATT} =0
...  ${DWGRADE_256QAM_SUCC} =0
...  ${UPGRADE_256QAM_ATT}=1
...  ${UPGRADE_256QAM_SUCC}= 1
...  ${UE_ACTIVE_TIME_256QAM}>0
@{rtpm_counters_A_c_001}
...  ${DWGRADE_256QAM_ATT} =0
...  ${DWGRADE_256QAM_SUCC} =0
...  ${UE_ACTIVE_TIME_256QAM}>0
...  ${UPGRADE_256QAM_ATT_cell1_and_cell2}=3
...  ${UPGRADE_256QAM_SUCC_cell1_and_cell2}= 3
#UPGRADE_256QAM_ATT/SUCC_cell1_and_cell2=3(cell1:2 \ cell2:1)

*** Test Cases ***
LTE4064-A-b_002_ICS_for_256QAM_Capable_UE_when_Feature_Activated_with_Max_Initial_Timer_and_Min_Period_Timer
    [Tags]    QC_26915
    OnlineParamChange    ${Param_A_b_002}
    Start Rtpm Counter    002
    UE attach Configured With_Legacy_actDl256QamChQualEst_enabled    ue_id=1    ue_eutra_capabilities=${ue_eutra_capabilities}
    Trigger Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires    ue_id=1    bearer_id=5    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}
    Trigger Downgraded To Legacy When perDl256QamChQualEst Timer Expires Under Bad Channel Quality  ue_id=1
    ...  time_duration=${MIN_VALUE_OF_PERIOD_TIMER}
    release all ues
    Check Rtpm Counters    ${rtpm_counters_A_b_002}

#LTE4064-A-g_001_SCell_Swap_for_256QAM_Capable_UE_when_Feature_Activated_with_Min_Initial_Timer_and_Min_Period_Timer
#    [Tags]    QC_26906
#    Start Rtpm Counter
#    UE Attach To Cell3
#    Start DL Data
#    Report A6 Event To Trigger Scell Swap From Cell1 To Cell2
#    Check Logs With Change Of Modulation Scheme    check_rrc=${check_rrc_LTE4064-A-g}    check_pm=${pm_counters_LTE4064-A-g}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Lua
    Set Ue In Lua    ue_id=1    rohc=16    sec_key=0102030405060708090A0B0C0D0E1001    imsi=666:652:405001001    cell=1    category=12
    ...    release=15    eea=null    eia=null    dl_256QAM_supported=on
    Set Ue In Lua    ue_id=2    rohc=16    sec_key=0102030405060708090A0B0C0D0E1002    imsi=666:652:405001002    cell=1    category=12
    ...    release=15    eea=null    eia=null    dl_256QAM_supported=on
    Set Ue In Lua    ue_id=3    rohc=16    sec_key=0102030405060708090A0B0C0D0E1002    imsi=666:652:405001003    cell=1    category=12
    ...    release=15    eea=null    eia=null    dl_256QAM_supported=on
    Set Ue In Lua    ue_id=4    rohc=16    sec_key=0102030405060708090A0B0C0D0E1002    imsi=666:652:405001004    cell=1    category=12
    ...    release=15    eea=null    eia=null    dl_256QAM_supported=on
    Set Ue In Lua    ue_id=5    rohc=16    sec_key=0102030405060708090A0B0C0D0E1002    imsi=666:652:405001005    cell=1    category=12
    ...    release=15    eea=null    eia=null    dl_256QAM_supported=on

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE attach Configured With_Legacy_actDl256QamChQualEst_enabled
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}=${empty}    ${cell_id}=1
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=attach_enb2_wo_256qam_flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} release=15 category=12 category_dl=14 dl_256QAM_supported=on
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Not Occurred For Message    alias=attach_enb2_wo_256qam_flow

Trigger Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires
    [Arguments]    ${ue_id}    ${time_duration}    ${bearer_id}=5    ${throughput}=17500    ${seconds}=3000
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=upgrade_256qam_flow    overall_timeout=${${time_duration}+60}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=${bearer_id} dir=dl protocol=udp kbps=${throughput}
    Flow Occurred As Expected    alias=upgrade_256qam_flow


Trigger Downgraded To Legacy When perDl256QamChQualEst Timer Expires Under Bad Channel Quality
    [Arguments]    ${ue_id}    ${time_duration}
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=downgrade_legacy_flow    overall_timeout=${${time_duration}+1}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=0:0:0 sb=1-13:0:0:0 cell=current disable_cqi_reporting=false
    Flow Not Occurred For Message    alias=downgrade_legacy_flow




UE attach Configured With 256QAM_actDl256QamChQualEst_disabled
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}=${empty}    ${cell_id}=1
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=attach_256qam_flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} release=15 category=12 category_dl=14 dl_256QAM_supported=on
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Flow Occurred As Expected    alias=attach_256qam_flow
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false






UE upgrade To 256QAM When perDl256QamChQualEst Timer Expires Under Good Channel Quality
    [Arguments]    ${ue_id}    ${time_duration}
    Iphy Execute Ue Command Without Kargs  ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    ...  pass_regexp=altCQI-Table-r12 allSubframes  timeout=${${time_duration}+1}

UE intra-eNB handover with Legacy and upgrade to 256QAM
    [Arguments]    ${ue_id}    ${time_duration}    ${TARGET_CELL_ID}
    ${ret}  Iphy Execute Ue Command Without Kargs  ue_ho id=${ue_id} enb=1 cell=${TARGET_CELL_ID}
    ...  pass_regexp=Intra-eNB handover from EXT_ENB-1.* to EXT_ENB-1.* performed
    Should Not Contain    ${ret}    altCQI-Table-r12
    Iphy Execute Ue Command Without Kargs  ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    ...  pass_regexp=altCQI-Table-r12 allSubframes  timeout=${${time_duration}+1}

Trigger Upgraded To 256QAM and Downgrade to legacy 4 times
    [Arguments]    ${ue_id}
    Trigger Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires  ue_id=${ue_id}  bearer_id=1  time_duration=${MAX_VALUE_OF_INITIAL_TIMER}
    Trigger Downgraded To Legacy When perDl256QamChQualEst Timer Expires Under Bad Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_PERIOD_TIMER}
    UE upgrade To 256QAM When perDl256QamChQualEst Timer Expires Under Good Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_INITIAL_TIMER}
    Trigger Downgraded To Legacy When perDl256QamChQualEst Timer Expires Under Bad Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_PERIOD_TIMER}
    UE upgrade To 256QAM When perDl256QamChQualEst Timer Expires Under Good Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_INITIAL_TIMER}
    Trigger Downgraded To Legacy When perDl256QamChQualEst Timer Expires Under Bad Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_PERIOD_TIMER}
    UE upgrade To 256QAM When perDl256QamChQualEst Timer Expires Under Good Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_INITIAL_TIMER}
    Trigger Downgraded To Legacy When perDl256QamChQualEst Timer Expires Under Bad Channel Quality  ue_id=${ue_id}
    ...  time_duration=${MID_VALUE_OF_PERIOD_TIMER}
