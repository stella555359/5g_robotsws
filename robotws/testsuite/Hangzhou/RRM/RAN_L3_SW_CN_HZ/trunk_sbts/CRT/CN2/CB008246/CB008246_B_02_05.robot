*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    team-Beam    owner-lin.g.wang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008246    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}     ${True}
${ue1_id}    1
${ue2_id}    2
${cell_id}    1
${pdu1_id}    1
${pdu2_id}    2
${nwslice_id}    1
${gw1_id}    1
${gw2_id}    2
${step1_tag}    step1
${step2_tag}    step2
${step3_tag}    step3
${TC05_tag}    CB008246_B05
${TC02_tag}    CB008246_B02
${ue_nr_capabilities_UL}
...    SEPARATOR=
...    E5A01000014F5E0302C0020840009041B38987C284804D8141FF9863CA160704C060188A0300A63000A0F88DAC
...    31B47498A823F96524CA0D00416C9824060C78C7FE618F28581C0E1E026761D86761D802001800000000388C00
...    000000841808DC9A14000000000120040041F00E41000000A41000002A41000004A494000069805C0DBC8DADD2
...    00A0800004B29202000032CA480800014B29202000072CA4A0800024B292120000AA5949004D038BA471742A26
...    9544576205801E0068040200000000000801002100
@{OnlineParam_for_TC05_Step1}
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=0
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=0
@{OnlineParam_for_TC05_Step2}
...    MRBTS-1/NRBTS-1/NRCELL-1:actLAForHiReliab=false
@{OnlineParam_for_TC05_Step3}
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=0
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=0

@{PARAMS_IN_SCF}
...    @{pdschHrLaConfig}
...    @{puschHrLaConfig}
...    @{LaForHR_Enable}
...    @{5qi6_related_modification}
...    @{delete useless parameters}
...    @{NRPDSCHHRLA}
...    @{NRPUSCHHRLA}
...    @{NRPDCCHHRLA}
...    @{bwp_pdcch}
@{pdschHrLaConfig}
...    MRBTS-1/NRBTS-1/NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    MRBTS-1/NRBTS-1/NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=15
...    MRBTS-1/NRBTS-1/NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-15
...    MRBTS-1/NRBTS-1/NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=2
...    MRBTS-1/NRBTS-1/NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-5
...    MRBTS-1/NRBTS-1/NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3
@{puschHrLaConfig}
...    MRBTS-1/NRBTS-1/NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-5
...    MRBTS-1/NRBTS-1/NRCELL-1:puschHrLaConfig:ullaDeltaSinrMaxHR=15
...    MRBTS-1/NRBTS-1/NRCELL-1:puschHrLaConfig:ullaDeltaSinrMinHR=-30
...    MRBTS-1/NRBTS-1/NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=2
...    MRBTS-1/NRBTS-1/NRCELL-1:puschHrLaConfig:ullaIniMcsHR=0
...    MRBTS-1/NRBTS-1/NRCELL-1:puschHrLaConfig:ullaSinrOffsetHR=2
@{LaForHR_Enable}
...    MRBTS-1/NRBTS-1/NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:actCceSplit=false
...    MRBTS-1/NRBTS-1/NRCELL-1:cellDepType=SA
@{delete useless parameters}
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac
@{NRPDSCHHRLA}
...    MRBTS-1/NRBTS-1/NRPDSCHHRLA-1:nrPdschHRLaId=1
...    MRBTS-1/NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10
@{NRPUSCHHRLA}
...    MRBTS-1/NRBTS-1/NRPUSCHHRLA-1:nrPuschHRLaId=1
...    MRBTS-1/NRBTS-1/NRPUSCHHRLA-1:ullaBlerTargetHR=10
@{NRPDCCHHRLA}
...    MRBTS-1/NRBTS-1/NRPDCCHHRLA-1:nrPdcchHRLaId=1
@{bwp_pdcch}
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:alSelection=dynamic
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:alSelection=dynamic
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=159
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl16HR=159
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=159
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelHRSet:cqiDciCssAl8HR=159
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureActTimerHR=50
...    NRBTS-1/BWP_PROFILE-4/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=50
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelHRSet:pCqiErasureActTimerHR=50
...    NRBTS-1/BWP_PROFILE-33/PDCCH-1:dynamicAggregationLevelSet:pCqiErasureActTimer=50
@{5qi6_related_modification}
...    MRBTS-1/NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-11:nrPdcchHRLaDN=MRBTS-1/NRBTS-1/NRPDCCHHRLA-1

*** Test Cases ***
CB008246_B_02_FR1_SA_FDD_schedule_1UE_Adaptation_for_High_Reliability_DRB_via_PDU_NO_Online_NIDD_Reconfiguration_In_UL
    [Documentation]
    ...    1. This user scenario is to validate if PDCCH schedule for UL Transport Blocks can be correctly decoded by UE.
    ...    2. Configuration
    ...    a.SA,FDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE support HR LA.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_6 is setup with HR.
    ...    b.UE detach.
    [Tags]    QC_278710    owner-lin.g.wang
    UE Attach via pdu    ${ue1_id}    ${cell_id}    ${pdu1_id}    ${nwslice_id}    ${gw1_id}
    UE Deregister From gNB    ${ue1_id}
    Rrc Should Contain    uplinkBWP-ToAddModList    mcs-Table qam64LowSE
    check wireshark log    ${CURDIR}${/}a2a_${TC02_tag}${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_B_05_FR1_SA_FDD_UL_Link_Adaptation_for_High_Reliability_DRB_Online_Modify_NIDD_Param_dynamicAggregationLevelHRSet
    [Documentation]
    ...    1. This user scenario is to validate online Reconfiguration of NRBTS/BWP_PROFILE/PDCCH/dynamicAggregationLevelHRSet.
    ...    2. Configuration
    ...    a.SA,FDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true.
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE Support HR LA.
    ...    e.UE1 has established single non-GBR HR DRB for PDSCH, PUSCH and PDCCH.
    ...    3. Test Case Steps:
    ...    Step1:
    ...    a.NRBTS/BWP_PROFILE/PDCCH/dciDedicatedAggregationLevelHRSet.cqiDciCssAl16HR is modified.
    ...    b.UE1 should schedual the DRB with updated NRBTS/BWP_PROFILE/PDCCH/dciDedicatedAggregationLevelHRSet.cqiDciCssAl16HR.
    ...    step2:
    ...    a.NRBTS/NRCELL.actLAForHiReliab is modified as False.
    ...    b.UE1 still schedualing 5QI6 via Link Adaptation High Reliability PDCCH update parameter in Step 1.
    ...    Initial Context Setup procedure for 5QI6 is triggered for UE2, Basic Reliability DRB is established.
    ...    step3:
    ...    a.NRBTS/BWP_PROFILE/PDCCH/dciDedicatedAggregationLevelHRSet.cqiDciCssAl8HR is modified.
    ...    b.UE1 should schedual the DRB with updated NRBTS/BWP_PROFILE/PDCCH/dciDedicatedAggregationLevelHRSet.cqiDciCssAl8HR.
    ...    UE2 still schedualing via Basic Reliability DRB per legacy.
    [Tags]    QC_278787    owner-lin.g.wang
    OnlineParamChange with TC05 step1    ${ue1_id}    ${cell_id}    ${pdu1_id}    ${nwslice_id}    ${gw1_id}
    ...    ${OnlineParam_for_TC05_Step1}    ${step1_tag}
    OnlineParamChange with TC05 step2    ${ue2_id}    ${cell_id}    ${pdu2_id}    ${nwslice_id}    ${gw2_id}
    ...    ${OnlineParam_for_TC05_Step2}    ${step2_tag}
    OnlineParamChange with TC05 step3    ${OnlineParam_for_TC05_Step3}    ${step3_tag}
    UE Deregister From gNB    ${ue1_id}
    UE Deregister From gNB    ${ue2_id}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_capabilities_UL}
    Delete Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_qosflow id=1 5qi=6 default=on

UE Attach via pdu
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    QoS Routing Table
    Execute Egate Command    amf_param id=1 send_ics_registration=off

Check logs
    [Arguments]    ${step_tag}
    check wireshark log    ${CURDIR}${/}a2a_${TC05_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineParamChange with TC05 step1
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}    ${OnlineParam}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    UE Attach via pdu    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Rrc Should Contain    uplinkBWP-ToAddModList    mcs-Table qam64LowSE
    OnlineParamChange    ${OnlineParam}
    Check logs    ${step_tag}

OnlineParamChange with TC05 step2
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}    ${OnlineParam}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    OnlineParamChange    ${OnlineParam}
    UE Attach via pdu    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    check wireshark log    ${CURDIR}${/}a2a_${TC05_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineParamChange with TC05 step3
    [Arguments]    ${OnlineParam}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    OnlineParamChange    ${OnlineParam}
    check wireshark log    ${CURDIR}${/}a2a_${TC05_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached
