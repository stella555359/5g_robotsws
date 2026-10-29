*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    team-Beam    owner-chunlan.yang
...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    CB008246    release-SBTS23R3
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}     ${True}
${ue1_id}    1
${ue2_id}    2
${ue3_id}    3
${ue4_id}    4
${ue_id}     5
${cell_id}    1
${pdu_id}    1
${nwslice_id}    1
${gw_id}    1
${TC_tag}    CB008246_E03
${stepini_tag}    stepini
${step1_tag}    step1
${step2_tag}    step2
${step3_tag}    step3
${OnlineParam_for_03_Step1}
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=50
@{OnlineParam_for_03_Step2}
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=10
@{OnlineParam_for_03_Step3}
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=90
${ue_nr_capabilities_UL}
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
...    @{bwp_pdcch}

@{pdschHrLaConfig}
...    NRCELL-1:pdschHrLaConfig:dllaCqiOffsetHR=0
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMaxHR=15
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiMinHR=-15
...    NRCELL-1:pdschHrLaConfig:dllaDeltaCqiStepdownHR=2
...    NRCELL-1:pdschHrLaConfig:dllaIniDeltaCqiHR=-5
...    NRCELL-1:pdschHrLaConfig:dllaIniMcsHR=3

@{puschHrLaConfig}
...    NRCELL-1:puschHrLaConfig:iniDeltaSinrHR=-5
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMaxHR=15
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrMinHR=-30
...    NRCELL-1:puschHrLaConfig:ullaDeltaSinrStepdownHR=2
...    NRCELL-1:puschHrLaConfig:ullaIniMcsHR=0
...    NRCELL-1:puschHrLaConfig:ullaSinrOffsetHR=2

@{LaForHR_Enable}
...    NRCELL-1:actLAForHiReliab=true
...    NRCELL-1:actCceSplit=false
...    NRCELL-1:cellDepType=SA

@{delete useless parameters}
...    delete:NRCELL-1:configuredEpsTac

@{NRPDSCHHRLA}
...    NRBTS/NRPDSCHHRLA-1:nrPdschHRLaId=1
...    NRBTS/NRPDSCHHRLA-2:nrPdschHRLaId=2
...    NRBTS/NRPDSCHHRLA-1:dlHRBlerOutageMcsThresh64qam=3
...    NRBTS/NRPDSCHHRLA-2:dlHRBlerOutageMcsThresh64qam=3

@{NRPUSCHHRLA}
...    NRBTS/NRPUSCHHRLA-1:nrPuschHRLaId=1
...    NRBTS/NRPUSCHHRLA-2:nrPuschHRLaId=2
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverTbsThresh=1200
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPeriod=10
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-1:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutageTbsThresh=808
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverTbsThresh=1200
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePeriod=20
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPeriod=10
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerOutagePercentage=50
...    NRBTS/NRPUSCHHRLA-2:ulHRBlerRecoverPercentage=60
...    NRBTS/NRPUSCHHRLA-1:scalFactorForHRGbrUl=110
...    NRBTS/NRPUSCHHRLA-2:scalFactorForHRGbrUl=110

@{bwp_pdcch}
...    NRBTS/BWP_PROFILE-5/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-54/PDCCH-1:alSelection=static
...    NRBTS/BWP_PROFILE-5/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dciDedicatedAggregationLevelHR=AL4
...    NRBTS/BWP_PROFILE-54/PDCCH-1:dynamicAggregationLevelHRSet:aggregationLevelListHR=AL1_AL2_AL4_AL8

@{5qi_related_modification}
...    NRBTS/NRDRB-11:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-1
...    NRBTS/NRDRB-11:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-1
...    NRBTS/NRDRB-12:nrPdschHRLaDN=MRBTS-1/NRBTS-1/NRPDSCHHRLA-2
...    NRBTS/NRDRB-12:nrPuschHRLaDN=MRBTS-1/NRBTS-1/NRPUSCHHRLA-2

*** Test Cases ***
CB008246_E_01_FR1_SA_TDD_Switch between BR and HR LA in UL for non-GBR DRB with static PDCCH LA
    [Documentation]
    ...    1. This user scenario is to validate the functionality of non-GBR DRB switch between
    ...    high reliability (HR) LA and basic reliability (BR) LA in UL due to change in radio conditions
    ...    2. Configuration
    ...    a.SA,FDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE support HR LA.
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_6 is setup with HR.
    ...    b. Send And Verify Throuput
    ...    c.UE detach.
    [Tags]    QC_284937    owner-chunlan.yang
    UE Attach Via PDU    ${ue1_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Send And Verify Throuput    ue_id=${ue1_id}    pdu_id=${pdu_id}    qfi_id=1    send_dl=20    send_ul=20    sleep_time=20s
    UE Deregister From gNB    ${ue1_id}
    check wireshark log    ${CURDIR}${/}a2a_CB008246_E01${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008246_E_03_FR1_SA_TDD_online_Modification_new_NIDD_parameters_with_static_in_NRPUSCHHRLA
    [Documentation]
    ...    1. This user scenario is to To validate no impact on existed UE when profile changed
    ...    2. Configuration
    ...    a.SA,TDD
    ...    b.Configured HR LA: NRBTS/NRCELL.actLAForHiReliab=true
    ...    c.default drb 5QI_6 is associated with NRPUSCHHRLA.
    ...    d.UE support HR LA.
    ...    3. Test Case Steps:
    ...    A.UE1 attach and set up PDU session.5QI_6 is setup with HR.
    ...    Step1:
    ...    a.NRBTS/NRPUSCHHRLA-1. ulHRBlerRecoverPeriod modified.
    ...    b.UE1 should schedual the DRB with old value of NRBTS/NRPUSCHHRLA-1. ulHRBlerRecoverPeriod
    ...    Initial Context Setup procedure for 5QI6 is triggered for UE2, High Reliability DRB is setup
    ...    finally and schedualed with updated NRBTS/NRPUSCHHRLA-1. ulHRBlerRecoverPeriod
    ...    Step2:
    ...    a.NRBTS/NRPUSCHHRLA-1. ulHRBlerOutagePeriod modified.
    ...    b.UE1 and UE2 should schedual the DRB with old value of NRBTS/NRPUSCHHRLA-1. ulHRBlerOutagePeriod
    ...    Initial Context Setup procedure for 5QI6 is triggered for UE3, High Reliability DRB is setup finally
    ...    and schedualed with updated NRBTS/NRPUSCHHRLA-1. ulHRBlerOutagePeriod
    ...    Step3:
    ...    a.NRBTS/NRPUSCHHRLA-1. ulHRBlerOutagePercentage modified.
    ...    b.UE1, UE2 and UE3 should schedual the DRB with old value of NRBTS/NRPUSCHHRLA-1. ulHRBlerOutagePercentage
    ...    Initial Context Setup procedure for 5QI6 is triggered for UE4, High Reliability DRB is
    ...    setup finally and schedualed with updated NRBTS/NRPUSCHHRLA-1. ulHRBlerOutagePercentage
    ...    C.UE detach.
    [Tags]    QC_300441    owner-chunlan.yang
    OnlineParamChange for TC03 ini    ${ue1_id}    ${pdu_id}    ${gw_id}    ${stepini_tag}
    OnlineParamChange for TC03 step1    ${ue2_id}    ${pdu_id}    ${gw_id}    ${OnlineParam_for_03_Step1}    ${step1_tag}
    OnlineParamChange for TC03 step2    ${ue3_id}    ${pdu_id}    ${gw_id}    ${OnlineParam_for_03_Step2}    ${step2_tag}
    OnlineParamChange for TC03 step3    ${ue4_id}    ${pdu_id}    ${gw_id}    ${OnlineParam_for_03_Step3}    ${step3_tag}
    UE Deregister From gNB    ${ue1_id}
    UE Deregister From gNB    ${ue2_id}
    UE Deregister From gNB    ${ue3_id}
    UE Deregister From gNB    ${ue4_id}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri

Modify Cfg
    Update Cfg    ue_param id=1 ue_nr_capabilities=${ue_nr_capabilities_UL}
    Update Cfg    ue_param id=2 ue_nr_capabilities=${ue_nr_capabilities_UL}
    Update Cfg    ue_param id=3 ue_nr_capabilities=${ue_nr_capabilities_UL}
    Update Cfg    ue_param id=4 ue_nr_capabilities=${ue_nr_capabilities_UL}
    Delete Cfg    set_qosflow id=1 5qi=8 default=on
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

UE Attach Via ICS
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=1 enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=1    QoS Routing Table

UE Attach Via PDU
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    QoS Routing Table

OnlineParamChange for TC03 ini
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    UE Attach Via ICS    ${ue1_id}    ${pdu_id}    ${gw_id}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1    send_dl=20    send_ul=20    sleep_time=20s
    check wireshark log    ${CURDIR}${/}a2a_${TC_tag}${/}a2a.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineParamChange for TC03 step1
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${OnlineParam}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    OnlineParamChange    ${OnlineParam}
    UE Attach Via ICS    ${ue2_id}    ${pdu_id}    ${gw_id}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1    send_dl=20    send_ul=20    sleep_time=20s
    check wireshark log    ${CURDIR}${/}a2a_${TC_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineParamChange for TC03 step2
   [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${OnlineParam}    ${step_tag}
   Start To Capture Wireshark Log    ${step_tag}
   OnlineParamChange    ${OnlineParam}
   UE Attach Via ICS    ${ue3_id}    ${pdu_id}    ${gw_id}
   Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1    send_dl=20    send_ul=20    sleep_time=20s
   check wireshark log    ${CURDIR}${/}a2a_${TC_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

OnlineParamChange for TC03 step3
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}    ${OnlineParam}    ${step_tag}
    Start To Capture Wireshark Log    ${step_tag}
    OnlineParamChange    ${OnlineParam}
    UE Attach Via ICS    ${ue4_id}    ${pdu_id}    ${gw_id}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1    send_dl=20    send_ul=20    sleep_time=20s
    check wireshark log    ${CURDIR}${/}a2a_${TC_tag}${/}a2a_${step_tag}.ini    name=${step_tag}    wait_string=UEContextReleaseComplete::0

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${sleep_time}=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${pdu_id}    ${qfi_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached
