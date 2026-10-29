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
${ue3_id}    3
${cell_id}    1
${pdu1_id}    1
${pdu2_id}    2
${pdu3_id}    3
${nwslice_id}    1
${gw1_id}    1
${gw2_id}    2
${gw3_id}    3
${step1_tag}    step1
${step2_tag}    step2
${TC03_log_tag}    CB008246_C03
${TC09_log_tag}    CB008246_C09
${OnlineParam_for_TC09_Step1}
...    MRBTS-1/NRBTS-1/NRPUSCHHRLA-1:ullaBlerTargetHR=4

@{OnlineParam_for_TC09_Step2}
...    delete:MRBTS-1/NRBTS-1/NRDRB-11:nrPuschHRLaDN
...    delete:MRBTS-1/NRBTS-1/NRDRB-11:nrPdschHRLaDN

${ue_nr_capabilities_FULL}
...    SEPARATOR=
...    E5A00000074E5A031E00038420007824C1900010F09003102D00980C0301C032A36146B04050D012CB28986801EB608080838778E1
...    C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C
...    002A3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007A
...    D8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C0260070006
...    828000000000240080083E0000000000000E54D000100000965950034AAA85800E001600000008010023162600020406080A0C0E10
...    162022242632424A4C4E5094

@{PARAMS_IN_SCF}
...    @{pdschHrLaConfig}
...    @{puschHrLaConfig}
...    @{LaForHR_Enable}
...    @{5qi_related_modification}
...    @{delete useless parameters}
...    @{NRPDSCHHRLA}
...    @{NRPUSCHHRLA}

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
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1:alSelection=static
...    MRBTS-1/NRBTS-1/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4

@{delete useless parameters}
...    delete:MRBTS-1/NRBTS-1/NRCELL-1:configuredEpsTac

@{NRPDSCHHRLA}
...    MRBTS-1/NRBTS-1/NRPDSCHHRLA-1:nrPdschHRLaId=1
...    MRBTS-1/NRBTS-1/NRPDSCHHRLA-1:dllaBlerTargetHR=10

@{NRPUSCHHRLA}
...    MRBTS-1/NRBTS-1/NRPUSCHHRLA-1:nrPuschHRLaId=1
...    MRBTS-1/NRBTS-1/NRPUSCHHRLA-1:ullaBlerTargetHR=10

@{5qi_related_modification}
...    MRBTS-1/NRBTS-1/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-13:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    MRBTS-1/NRBTS-1/NRDRB-13:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=600
*** Test Cases ***
CB008246_C_01_FR1_SA_TDD_UL_Link_Adaptation_for_High_Reliability_DRB_Active_Cell_up
    [Documentation]
    ...    1. This user scenario is to validate the successful TDD Cell Setup on gNB configured with enabled CB008246.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE not support HR LA.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_6 is setup without HR.
    ...    b.UE detach.
    [Tags]    QC_277620    owner-lin.g.wang
    UE Attach via pdu with TC01    ${ue1_id}    ${cell_id}
    UE Deregister From gNB    ${ue1_id}

CB008246_C_03_FR1_SA_TDD_schedule_1UE_Adaptation_for_High_Reliability_DRB_via_UL_PDU_NO_NIDD_PM
    [Documentation]
    ...    1. This user scenario is to validate the gNB behaviour for the successful setup of
    ...    one non-GBR QoS Flow with 5QI 6/7/8/9 for high reliability (HR) in UL and data transmission in UL TDD.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE support HR LA.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_6 is setup with HR.
    ...    b.UE detach.
    [Tags]    QC_278709    owner-lin.g.wang
    Update UE capa    ue_id=${ue1_id}    SA_Capa_perUE_Full=${ue_nr_capabilities_FULL}
    UE Attach via pdu with TC03    ${ue1_id}    ${cell_id}    ${pdu1_id}    ${nwslice_id}    ${gw1_id}
    UE Deregister From gNB    ${ue1_id}
    check wireshark log    ${CURDIR}${/}a2a_${TC03_log_tag}${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_C_09_FR1_SA_TDD_UL_Link_Adaptation_for_High_Reliability_DRB_Online_Change_NRPUSCHHRLA_via_UL_ICS_NO_NIDD_PM
    [Documentation]
    ...    1. This user scenario is to validate no impact on existed UE when profile changed or removed.
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE support HR LA.
    ...    3. Test Case Steps:
    ...    Step 1:
    ...    a. UE1 has established single non-GBR HR DRB(5QI6).
    ...    b. NRBTS/NRPUSCHHRLA-1.ullaBlerTargetHR modified.
    ...    c. initial Context Setup procedure for 5QI6 is triggered for UE2, High Reliability DRB is setup
    ...       finally and schedualed with updated NRBTS/NRPUSCHHRLA-1.ullaBlerTargetHR
    ...    Step 2:
    ...    a. NRBTS/NRDRB-X.nrPuschHRLaDN = NRPUSCHHRLA-1 is removed.
    ...    b. Initial Context Setup procedure for 5QI6 is triggered for UE3, Basic Reliability DRB is setup finally
    [Tags]    QC_278789    owner-lin.g.wang
    Update UE capa    ue_id=${ue1_id}    SA_Capa_perUE_Full=${ue_nr_capabilities_FULL}
    Update UE capa    ue_id=${ue2_id}    SA_Capa_perUE_Full=${ue_nr_capabilities_FULL}
    Update UE capa    ue_id=${ue3_id}    SA_Capa_perUE_Full=${ue_nr_capabilities_FULL}
    Trigger UE1 Attach With TC09    ${ue1_id}    ${cell_id}    ${pdu1_id}    ${nwslice_id}    ${gw1_id}
    OnlineChange with TC09 step1    ${OnlineParam_for_TC09_Step1}    ${ue1_id}    ${ue2_id}    ${pdu1_id}
    ...    ${pdu2_id}    ${gw1_id}    ${gw2_id}    ${TC09_log_tag}    ${step1_tag}
    OnlineChange with TC09 step2    ${OnlineParam_for_TC09_Step2}    ${ue3_id}    ${pdu3_id}    ${gw3_id}
    ...    ${TC09_log_tag}    ${step2_tag}
    UE Deregister From gNB    ${ue1_id}
    UE Deregister From gNB    ${ue2_id}
    UE Deregister From gNB    ${ue3_id}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Delete Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

OnlineChange with TC09 step1
    [Arguments]    ${OnlineParam}    ${ue1_id}    ${ue2_id}    ${pdu1_id}    ${pdu2_id}
    ...    ${gw1_id}    ${gw2_id}    ${TC_log_tag}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    OnlineParamChange    ${OnlineParam_for_TC09_Step1}
    Trigger UE1 5QI6 setup via ICS With TC09    ${ue1_id}    1    ${pdu1_id}    1    ${gw1_id}
    Rrc Should Contain    uplinkBWP-ToAddModList    mcs-Table qam64LowSE
    Trigger UE2 5QI6 setup via ICS With TC09    ${ue2_id}    1    ${pdu2_id}    1    ${gw2_id}
    check wireshark log    ${CURDIR}${/}a2a_${TC_log_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineChange with TC09 step2
    [Arguments]    ${OnlineParam}    ${ue_id}    ${pdu_id}    ${gw_id}    ${TC_log_tag}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    OnlineParamChange    ${OnlineParam}
    Trigger UE3 5QI6 setup via ICS With TC09    ${ue_id}    1    ${pdu_id}    1    ${gw_id}    QoS Routing Table
    check wireshark log    ${CURDIR}${/}a2a_${TC_log_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

UE Attach via pdu with TC01
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register

UE Attach via pdu with TC03
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    QoS Routing Table
    Execute Egate Command    amf_param id=1 send_ics_registration=off

Trigger UE1 Attach With TC09
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register

Trigger UE1 5QI6 setup via ICS With TC09
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    QoS Routing Table

Trigger UE2 5QI6 setup via ICS With TC09
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    QoS Routing Table

Trigger UE3 5QI6 setup via ICS With TC09
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}    ${pass_regexp}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

