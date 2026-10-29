*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SBTS20C    owner-yu.1.zhou    team-DEVHZ5_SG3
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_CATM_Volte_LTE4056}
...    @{PARAMS_FOR_LTE5550}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=10
...    LNBTS-1/CATMPR-1:cpInactivityTimerCatM=10
...    LNBTS-1/CATMPR-1:t310CatM=2000ms
...    LNBTS-1/CATMPR-1:t311CatM=3000ms
...    LNBTS-1/CATMPR-1:tL2AckRrcRelCatM=1600
...    LNBTS-1:actMultBearers=true
...    delete:MRBTS-1/LNBTS-1/LNCEL-1/CATMCEL-0:acbPlmnNumStepsCatM
@{PARAMS_FOR_CATM_Volte_LTE4056}
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNBTS-1/CATMPR-1:maxNumQci1DrbCatM=10
...    LNBTS-1/CATMPR-1:qciForVoLTECatM=255
...    LNBTS-1/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=4
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=40
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS-1/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
...    LNBTS-1/CATMPR-1:catMVoLTETab:ulMaxHarqTxQci1CatM=1
...    LNBTS-1:qciTab5:lcgid=0|schedulType=SIGNALLING
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
@{PARAMS_FOR_LTE5550}
...    LNCEL-1/CATMCEL-0:actUeDataInactivityCatM=true
...    LNBTS-1/CATMPR-1:dataInactivityTimerCatM=${dataInactivityTimerCatM}s
...    LNBTS-1/CATMPR-1:qci1dataInactivityTimerCatM=${qci1dataInactivityTimerCatM}s
...    LNCEL-1/CATMCEL-0:immediateS1ReleaseCatM=false
${UE_EUTRA_CAPABILITIES_CATM_UDIT}    D628030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA1491800000000C00
${dataInactivityTimerCatM}    40
${qci1dataInactivityTimerCatM}    60

*** Test Cases ***
LTE5550-A-b_ET_01_01_Normal or VOLTE UDIT configured when ICS without or with VOLTE QCI and UE capability support UDIT
    [Tags]    owner-xu.wang    CDRT
    CatM UE1 attach to eNB with one default non-GBR bearer and UE capability support UDIT
    Do data transfer for more than UDIT timer before inactivityTimerCatM expire    ue_id=1    UDIT_timer_value=${dataInactivityTimerCatM}
    CatM UE2 attach to enb1 cell1 with VOLTE call and UE capability support UDIT
    Do data transfer for more than UDIT timer before inactivityTimerCatM expire    ue_id=2    UDIT_timer_value=${qci1dataInactivityTimerCatM}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus
    Create UE Alias    alias=UE_2    ue_id=2    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 9, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1, preprovisioned: on, filter: 1, precedence: 1, priority: 1}
    ...      - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...      - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...      - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...      - {qci: 5, pdn: 1, preprovisioned: on, filter: 5, precedence: 5}
    ...      - {qci: 6, pdn: 1}
    ...      - {qci: 7, pdn: 1}
    ...      - {qci: 8, pdn: 1}
    ...      - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...      - {qci: 6, pdn: 2}
    ...      - {qci: 7, pdn: 2}
    ...      - {qci: 9, pdn: 2}

    Update Yaml    UEs/UE_sets/2    bearer: bearer_set_2

CatM UE1 attach to eNB with one default non-GBR bearer and UE capability support UDIT
    Expect Message Flow
    ...    UE_1:RRC_RRCConnectionRequest
    ...    UE_1:RRC_RRCConnectionSetup (ce-Mode-r13 contains ( setup eq 'ce-ModeA'))
    ...    MME_1:S1AP_InitialContextSetupRequest (E-RABToBeSetupListCtxtSUReq contains (qCI eq 8) and length(E-RABToBeSetupListCtxtSUReq) eq 1)
    ...    MME_1:S1AP_UECapabilityInfoIndication ( dataInactMon-r14 eq "supported" )
    ...    UE_1:RRC_RRCConnectionReconfiguration (dataInactivityTimerConfig-r14 contains (dataInactivityTimer-r14 eq 's40'))
    ...    alias=UE_1    overall_timeout=20
    Execute Uex Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM_UDIT} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_1

CatM UE2 attach to enb1 cell1 with VOLTE call and UE capability support UDIT
    ${QCI_9_1_5}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains ( qCI eq 9, qCI eq 1, qCI eq 5 )
    ...    and
    ...    length(E-RABToBeSetupListCtxtSUReq) eq 3
    Expect Message Flow
    ...    UE_2:RRC_RRCConnectionRequest
    ...    UE_2:RRC_RRCConnectionSetup (ce-Mode-r13 contains ( setup eq 'ce-ModeA'))
    ...    MME_1:S1AP_InitialContextSetupRequest(${QCI_9_1_5})
    ...    MME_1:S1AP_UECapabilityInfoIndication( dataInactMon-r14 eq "supported" )
    ...    UE_2:RRC_RRCConnectionReconfiguration(dataInactivityTimerConfig-r14 contains (dataInactivityTimer-r14 eq 's60'))
    ...    alias=UE_2    overall_timeout=20
    Execute Uex Command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM_UDIT} enb=1 cell=1
    Flow Occurred As Expected    alias=UE_2

Do data transfer for more than UDIT timer before inactivityTimerCatM expire
    [Documentation]    more than 2 times dataInactivityTimerCatM/qci1dataInactivityTimerCatM to make sure UDIT not take effect
    [Arguments]    ${ue_id}=1    ${UDIT_timer_value}=40
    Data transfer to keep UE active    ue_id=${ue_id}
    sleep    ${${UDIT_timer_value}+${UDIT_timer_value}+5}
    ${ue_info}    execute uex command    get_ue_info id=${ue_id}
    should be equal    ${ue_info["state"]}    ACTIVE

Data transfer to keep UE active
    [Arguments]    ${ue_id}=1
    execute uex command    trf_data_start ue=${ue_id} dir=dl protocol=udp kbps=90 trf_id=1
