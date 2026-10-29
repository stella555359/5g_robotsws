*** Settings ***
Suite Setup       Common Suite Setup And Setup 2CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_2MAPO_2CUS    team-DevHZ5_SG4
...               owner-rebecca.zhong    release-L18A
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{enable_256QAM_enb1}
...    @{LNADJ_relate_enb1}
@{PARAMS_IN_SCF_ENB2}
...    @{enable_256QAM_enb2}
...    @{LNADJ_relate_enb2}
@{enable_256QAM_enb1}
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actDl256QamChQualEst=true
...    LNCEL:iniDl256QamChQualEst=240s
...    LNCEL:perDl256QamChQualEst=240s
...    LNCEL:dl256QamReactChQualThr=24
...    LNCEL:dl256QamDeactChQualThr=15
@{enable_256QAM_enb2}
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actDl256QamChQualEst=true
...    LNCEL:iniDl256QamChQualEst=240s
...    LNCEL:perDl256QamChQualEst=240s
...    LNCEL:dl256QamReactChQualThr=24
...    LNCEL:dl256QamDeactChQualThr=15
${MAX_VALUE_OF_INITIAL_TIMER}    240
@{LNADJ_relate_enb1}
...    LNBTS-1/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-1/LNADJ-1:adjEnbId=2
...    LNBTS-1/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS-1/LNADJ-1/LNADJL-1:fDlEarfcn=1400
...    LNBTS-1/LNADJ-1/LNADJL-1:phyCellId=51
...    LNBTS-1/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-1/LNCEL-1/LNREL:handoverAllowed=onlyS1
@{LNADJ_relate_enb2}
...    LNBTS-2/LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...    LNBTS-2/LNADJ-1:cPlaneIpAddr=10.0.1.2
...    LNBTS-2/LNADJ-1:adjEnbId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:ecgiLcrId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:fDlEarfcn=1400
...    LNBTS-2/LNADJ-1/LNADJL-1:phyCellId=1
...    LNBTS-2/LNADJ-1/LNADJL-1:tac=33
...    LNBTS-2/LNCEL-1/LNREL-1:handoverAllowed=allowed
@{SWCONFIG_FLAGS}
...    0x1e0146=0x80000008
@{PARAMS_IN_SWCONFIG_TARGET}
...    0x1e0146=0x80000008
${ue_eutra_capabilities}    SEPARATOR=
...    D1B8048308427D10C180300600C1BFBFFEC800801C1E40000000152A56E2030108000240000670000D000060C0180300605040000028A23069
...    300407FF6A
${DWGRADE_256QAM_ATT}    M8007C20
${DWGRADE_256QAM_SUCC}    M8007C21
${UPGRADE_256QAM_ATT}    M8007C22
${UPGRADE_256QAM_SUCC}    M8007C23
${UPGRADE_256QAM_ATT_cell1_and_cell2}    M8007C22
${UPGRADE_256QAM_SUCC_cell1_and_cell2}    M8007C23
@{rtpm_counters_A_c_006_enb1}
...    ${DWGRADE_256QAM_ATT} =0
...    ${DWGRADE_256QAM_SUCC} =0
...    ${UPGRADE_256QAM_ATT_cell1_and_cell2}=5
...    ${UPGRADE_256QAM_SUCC_cell1_and_cell2}= 5
#UPGRADE_256QAM_ATT/SUCC_cell1_and_cell2=5(cell1:4 \ cell2:1)
@{rtpm_counters_A_c_006_enb2}
...    ${DWGRADE_256QAM_ATT} =0
...    ${DWGRADE_256QAM_SUCC} =0
...    ${UPGRADE_256QAM_ATT}=1
...    ${UPGRADE_256QAM_SUCC}= 1

*** Test Cases ***
LTE4064-A-c_006_Multi_Kinds_HO_Combination_for_256QAM_Capable_UE_when_Feature_Activated_with_Mid_Initial_Timer_and_Mid_Period_Timer
    [Tags]
    clear counter files    ${False}
    clear counter files enb2
    UE attach Configured With_Legacy_actDl256QamChQualEst_enabled    ue_id=2    ue_eutra_capabilities=${ue_eutra_capabilities}    cell_id=51
    Trigger Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires    ue_id=2    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}    bearer_id=5
    UE X2HO to ENB1 with With_Legacy_actDl256QamChQualEst_enabled    ue_id=2    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}    TARGET_ENB_ID=1
    ...    TARGET_CELL_ID=1
    UE Configured With Legacy And Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires With intra-eNB Handover    ue_id=3
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}    bearer_id=5    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}    TARGET_CELL_ID=2
    UE Configured With Legacy And Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires With Intra-cell Handover    ue_id=4
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}    bearer_id=5    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}
    Check Counters    ${rtpm_counters_A_c_006_enb1}
    check counters enb2    ${rtpm_counters_A_c_006_enb2}

*** Keywords ***
Common Suite Setup And Setup 2CUS Env
    Common Suite Setup
    Setup 2CUS Env    tl_type=3CELLs_FDD    tl_type_enb2=3CELLs_FDD
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create Enb Alias    ENB_1    enb_id=10.0.1.2    id_type=real
    Create MME Alias    MME_1    mme_id=1    id_type=wts

UE attach Configured With_Legacy_actDl256QamChQualEst_enabled
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}=${empty}    ${cell_id}=21
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=attach_enb2_wo_256qam_flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} release=15 category=12 category_dl=14 dl_256QAM_supported=on
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} enb=2 cell=${cell_id}
    Flow Not Occurred For Message    alias=attach_enb2_wo_256qam_flow

Trigger Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires
    [Arguments]    ${ue_id}    ${time_duration}    ${bearer_id}=1    ${throughput}=17500    ${seconds}=3000
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=upgrade_256qam_flow    overall_timeout=${${time_duration}+60}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=${bearer_id} dir=dl protocol=udp kbps=${throughput}
    Flow Occurred As Expected    alias=upgrade_256qam_flow

UE X2HO to ENB1 with With_Legacy_actDl256QamChQualEst_enabled
    [Arguments]    ${ue_id}    ${time_duration}    ${TARGET_ENB_ID}    ${TARGET_CELL_ID}
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=ho_wo_256qam_flow    overall_timeout=20
    Expect Message Flow
    ...    ENB_1:X2AP_HandoverRequest (Cause contains (radioNetwork eq "handover-desirable-for-radio-reasons"))
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    alias=inter_eNB_HO_flow    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} enb=${TARGET_ENB_ID} cell=${TARGET_CELL_ID}
    Flow Occurred As Expected    alias=inter_eNB_HO_flow
    Flow Not Occurred For Message    alias=ho_wo_256qam_flow
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=ho_upgrade_256qam_flow    overall_timeout=${${time_duration}+50}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    Flow Occurred As Expected    alias=ho_upgrade_256qam_flow

UE Configured With Legacy And Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires With intra-eNB Handover
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}    ${bearer_id}    ${time_duration}    ${TARGET_CELL_ID}
    UE attach Configured With_Legacy_actDl256QamChQualEst_enabled and upgrade to 256QAM    ue_id=${ue_id}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}    bearer_id=${bearer_id}    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}
    Intra eNB handover and trigger upgrade To 256QAM
    ...    ue_id=${ue_id}    time_duration=${MAX_VALUE_OF_INITIAL_TIMER}    TARGET_CELL_ID=${TARGET_CELL_ID}

UE attach Configured With_Legacy_actDl256QamChQualEst_enabled and upgrade to 256QAM
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}    ${bearer_id}    ${time_duration}
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=attach_enb1_wo_256qam_flow    overall_timeout=20
    Execute Uex Command    ue_param id=${ue_id} release=15 category=12 category_dl=14 dl_256QAM_supported=on
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} enb=1 cell=1
    Flow Not Occurred For Message    alias=attach_enb1_wo_256qam_flow
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=upgrade_256qam_flow    overall_timeout=${${time_duration}+50}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=${bearer_id} dir=dl protocol=udp kbps=17500
    Flow Occurred As Expected    alias=upgrade_256qam_flow

Intra eNB handover and trigger upgrade To 256QAM
    [Arguments]    ${ue_id}    ${time_duration}    ${TARGET_CELL_ID}
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=intra_ho_wo_256qam_flow    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=${TARGET_CELL_ID}
    Flow Not Occurred For Message    alias=intra_ho_wo_256qam_flow
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=upgrade_256qam_flow    overall_timeout=${${time_duration}+50}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    Flow Occurred As Expected    alias=upgrade_256qam_flow


UE Configured With Legacy And Upgraded To 256QAM When iniDl256QamChQualEst Timer Expires With Intra-cell Handover
    [Arguments]    ${ue_id}    ${ue_eutra_capabilities}    ${bearer_id}    ${time_duration}
    UE attach Configured With_Legacy_actDl256QamChQualEst_enabled and upgrade to 256QAM    ue_id=${ue_id}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}    bearer_id=${bearer_id}    time_duration=${time_duration}
    Intra-cell handover and trigger upgrade To 256QAM    ue_id=${ue_id}    time_duration=${time_duration}

Intra-cell handover and trigger upgrade To 256QAM
    [Arguments]    ${ue_id}    ${time_duration}
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=intra_cell_ho_wo_256qam_flow    overall_timeout=20
    Execute Egate Command    ue_reauth id=${ue_id}    REAUTHENTICATION PROCEDURE IS COMPLETED
    Flow Not Occurred For Message    alias=intra_cell_ho_wo_256qam_flow
    Expect Message Flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (cqi-ReportConfigPCell-v1250 contains (altCQI-Table-r12 eq "allSubframes"))
    ...    alias=upgrade_256qam_flow    overall_timeout=${${time_duration}+50}
    Execute Uex Command    ue_cqi_param id=${ue_id} wb=15:15:15 sb=1-13:15:15:15 cell=current disable_cqi_reporting=false
    Flow Occurred As Expected    alias=upgrade_256qam_flow






