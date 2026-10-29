*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...                 release-SBTS21B    owner-annie.nie    team-DevHZ5_SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{LEGACY_ACB}
...    @{PARAMS_FOR_CATM}
...    @{CB007206}
...    @{RRC_ACB_TRIGGER}
...    @{RACH_ACB_TRIGGER}
...    @{SIB_0}
...    @{ACBPRMinMax}
...    @{ACBPRStatic}
@{LEGACY_ACB}
...    LNBTS:actCplaneOvlHandling=true
...    LNBTS:actAutoAcBarring=true
...    LNCEL-1:inactivityTimer=1000
...    LNCEL-1/CATMCEL-0:acbPlmnNumStepsCatM=${EMPTY}
...    LNCEL:acbPrimaryPlmnProfileId=${EMPTY}
@{SIB_0}
...    LNCEL-1/SIB-0:acbProfileId=0
...    LNCEL/SIB-0:acbNumSteps=2
...    LNCEL/SIB-0:acbUpdateTimer=30
...    LNCEL-1/SIB-0:acbECTimer=1
...    LNCEL-1/SIB-0:acbSkipTimer=1
...    LNCEL-1/SIB-0:siWindowLen=20ms
...    LNCEL-1/SIB-0:autoAcBarringStartTimer=30
@{ACBPRMinMax}
...    LNBTS/ACBPR-0:acBarSigAutoMin:barTime=4s
...    LNBTS/ACBPR-0:acBarSigAutoMin:probFac=95%
...    LNBTS/ACBPR-0:acBarSigAutoMax:barTime=512s
...    LNBTS/ACBPR-0:acBarSigAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarOcAutoMin:barTime=4s
...    LNBTS/ACBPR-0:acBarOcAutoMin:probFac=95%
...    LNBTS/ACBPR-0:acBarOcAutoMax:barTime=512s
...    LNBTS/ACBPR-0:acBarOcAutoMax:probFac=0%
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMin:barTime=4s
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMin:probFac=95%
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:barTime=512s
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarOcAutoMin:barTime=4s
...    LNBTS/ACBPR-1:acBarOcAutoMin:probFac=95%
...    LNBTS/ACBPR-1:acBarOcAutoMax:barTime=512s
...    LNBTS/ACBPR-1:acBarOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMin:barTime=4s
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMin:probFac=95%
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:barTime=512s
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcAutoMax:probFac=0%
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMin=${empty}
...    LNBTS/ACBPR-1:acBarMMTelVideoOcAutoMax=${empty}
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMin=${empty}
...    LNBTS/ACBPR-1:acBarCsfbOcAutoMax=${empty}
...    LNBTS/ACBPR-1:acBarSigAutoMin=${empty}
...    LNBTS/ACBPR-1:acBarSigAutoMax=${empty}
@{ACBPRStatic}
...    LNBTS/ACBPR-0:acBarSigStatic:barTime=8s
...    LNBTS/ACBPR-0:acBarSigStatic:probFac=95%
...    LNBTS/ACBPR-0:acBarOcStatic:barTime=8s
...    LNBTS/ACBPR-0:acBarOcStatic:probFac=95%
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcStatic:barTime=8s
...    LNBTS/ACBPR-0:acBarMMTelVoiceOcStatic:probFac=95%
...    LNBTS/ACBPR-0:eCallAcBarredAuto=barred
...    LNBTS/ACBPR-0:acBarSkipForMMTELVideo=false
...    LNBTS/ACBPR-0:acBarSkipForMMTELVoice=true
...    LNBTS/ACBPR-0:acBarSkipForSMS=true
...    LNBTS/ACBPR-1:acBarSigStatic=${empty}
...    LNBTS/ACBPR-1:acBarOcStatic:barTime=8s
...    LNBTS/ACBPR-1:acBarOcStatic:probFac=95%
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcStatic:barTime=8s
...    LNBTS/ACBPR-1:acBarMMTelVoiceOcStatic:probFac=95%
...    LNBTS/ACBPR-1:acBarMMTelVideoOcStatic=${empty}
...    LNBTS/ACBPR-1:acBarCsfbOcStatic=${empty}
...    LNBTS/ACBPR-1:eCallAcBarredAuto=barred
...    LNBTS/ACBPR-1:acBarSkipForMMTELVideo=false
...    LNBTS/ACBPR-1:acBarSkipForMMTELVoice=true
...    LNBTS/ACBPR-1:acBarSkipForSMS=true
@{RRC_ACB_TRIGGER}
...    LNBTS:actAcBarringRrcConn=CellOnly
...    LNBTS:actAcBarringCFR=false
...    LNCEL-1/LNCEL_FDD-0:maxNumActUE=195
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:maxNumRrc=200
...    LNCEL-1/SIB-0:primPlmnCellres=Not Reserved
...    LNCEL-1/SIB-0:primPlmnCellresAcbMax=not reserved
...    LNCEL/SIB-0:acbNumRrcConnCellStart=10
...    LNCEL/SIB-0:acbNumRrcConnCellStop=3
...    LNCEL/SIB-0:acbRrcConnCellStartTimer=32
...    LNCEL/SIB-0:acbRrcConnCellStopTimer=30
@{RACH_ACB_TRIGGER}
...    LNBTS:actAcBarringRrcReq=false
...    LNCEL/SIB-0:acbImmediateMax=false
...    LNCEL/SIB-0:acbNumRrcReqStart=2
...    LNCEL/SIB-0:acbNumRrcReqStop=1
...    LNCEL/SIB-0:acbRrcReqFactor=0.25
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUeDc=10
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe3c=10
...    LNCEL-1/LNCEL_FDD-0:maxNumCaConfUe=10
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:minNumRrcNoDrb=260
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/CATMCEL-0:acbRrcPagSIMCatM=false
...    LNCEL-1/CATMCEL-0:actAcBarringCatM=false
...    LNCEL-1/CATMCEL-0:acbNumStepsCatM=2
...    LNBTS/CATMPR-0:dataInactivityTimerCatM=180s
...    LNBTS/CATMPR-0:inactivityTimerCatM=150
...    LNBTS/CATMPR-0:qci1dataInactivityTimerCatM=180s
...    LNBTS/CATMPR-0:siWindowLenCatM=160ms
...    LNBTS/CATMPR-0:catMVoLTETab:qci1ProtectionTimerCatM=160
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/CATMCEL-0:actEDrxIdleCatM=false
...    LNCEL-1/CATMCEL-0:acbProfileIdCatM=0
@{CB007206}
...    LNCEL-1/CATMCEL-0:actEabCatM=None
...    LNCEL-1/CATMCEL-0:eabNumRrcConnAutoCatM:cellStartThrCatM=8
...    LNCEL-1/CATMCEL-0:eabNumRrcConnAutoCatM:cellStopThrCatM=4
...    LNCEL-1/CATMCEL-0:eabNumRrcConnAutoCatM:cellStopTimerCatM=25
...    LNCEL-1/CATMCEL-0:eabNumRrcConnAutoCatM:cellStartTimerCatM=30
...    LNBTS/CATMPR-0:maxNumRrcCatM=50
...    LNBTS/CATMPR-0:sib14PeriodicityCatM=1280ms
...    LNBTS/EABPR-0:eabAuto:category=C
...    LNBTS/EABPR-0:eabAuto:bitmap=128
...    LNBTS/EABPR-0:eabStatic:category=B
...    LNBTS/EABPR-0:eabStatic:bitmap=16
...    LNCEL-1/CATMCEL-0:eabCpOvlSuppCatM=false
...    LNCEL-1/CATMCEL-0:eabProfileIdCatM=0
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessagePeriodicity=640ms
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageSibType=SIB14|siMessagePeriodicity=80ms
@{CB007206_06}
...    LNCEL-1/CATMCEL-0:actEabCatM=CellOnly
...    LNCEL-1/CATMCEL-0:acbRrcPagSIMCatM=false
...    LNBTS/EABPR-0:eabAuto:category=B
...    LNBTS/EABPR-0:eabAuto:bitmap=32
...    LNBTS/EABPR-0:eabStatic:category=C
...    LNBTS/EABPR-0:eabStatic:bitmap=256
...    LNCEL-1/CATMCEL-0:actAcBarringCatM=false
...    LNCEL-1/CATMCEL-0:actEDrxIdleCatM=false
...    LNBTS:actAcBarringRrcConn=None
${CellStartTimerCatM}    30
${CellStopTimerCatM}    25
${CATM_UE_CAPABILITIES}    D61FF000800055555D55001000804510021200055C041900
${DI_eab}         systemInfoModification=0 etws-Indication=0 cmas-Indication=0 eab-ParamModification=1 systemInfoModification-eDRX=0
@{PM_COUNTERS_06}
...    LNCEL-1:${IN_TR_AUTO_EAB_RRC_CELL_LTEM}=1
...    LNCEL-1:${OUT_TR_AUTO_EAB_LTEM}=1
...    LNCEL-1:${DURATION_AUTO_EAB_RRCCELL_LTEM}>25
...    LNCEL-1:${DURATION_AUTO_EAB_TOTAL_LTEM}>25
${IN_TR_AUTO_EAB_RRC_CELL_LTEM}    M8100C73
${OUT_TR_AUTO_EAB_LTEM}    M8100C74
${DURATION_AUTO_EAB_RRCCELL_LTEM}    M8100C76
${DURATION_AUTO_EAB_TOTAL_LTEM}    M8100C77
${sib14}    schedulingInfoList contains (si-Periodicity eq "rf128" and sib-MappingInfo contains ("sibType14-v1130"))
${static_eab}
...    eab-Param-r11 contains (eab-Category-r11 eq 'c' and eab-BarringBitmap-r11 eq '0b0000000010')
${active_eab}
...    eab-Param-r11 contains (eab-Category-r11 eq 'b' and eab-BarringBitmap-r11 eq '0b0000010000')
*** Test Cases ***
CB007206-SR-A-f-g_ET_06_01_Start and Stop CAT-M Auto EAB by RRC_EAB Events
    [Tags]
    Start Rtpm Counter
    OnlineParamChange    ${CB007206_06}     #eab_static
    Attach UE to trigger RRC_EAB No Change   #eab_static
    Attach 2CatM UEs To Trigger RRC_EAB_Active      #RRC_EAB Active
    RRC_EAB keeps Active    #eab_active_no_change
    Detach 2CatM UEs And Wait StopTimer expires    #RRC_EAB_INACTIVE
    check rtpm counters    ${PM_COUNTERS_06}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    create alias
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace_sim uec=1 protocol=rrc on

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create UE Alias    UE_4    ue_id=4    id_type=cus
    Create UE Alias    UE_5    ue_id=5    id_type=cus
    Create UE Alias    UE_6    ue_id=6    id_type=cus
    Create UE Alias    UE_7    ue_id=7    id_type=cus
    Create UE Alias    UE_8    ue_id=8    id_type=cus
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

OnlineParamChange
    [Arguments]    ${Online_Param}    ${bar_State}=state_Online
    expect message flow
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (${sib14})
    ...    CELL_1:RRC_SystemInformationBlockType14-BR-r13 (${static_eab})
    ...    alias=delta_eab_static    overall_timeout=60
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair
    flow occurred as expected    alias=delta_eab_static

Attach UE to trigger RRC_EAB No Change
    [Arguments]    ${bar_state}=eab_nochange
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    alias=2ue_attach    overall_timeout=20
    execute uex command    ue_attach id=1-4 cell=1 ue_eutra_capabilities=${CATM_UE_CAPABILITIES}
    execute uex command    ue_detach id=1-2
    flow occurred as expected    alias=2ue_attach

Attach 2CatM UEs To Trigger RRC_EAB_Active
    [Arguments]    ${bar_state}=eab_active
    expect message flow
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    MME_1:S1AP_InitialContextSetupResponse
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (${sib14})
    ...    CELL_1:RRC_SystemInformationBlockType14-BR-r13 (${active_eab})
    ...    alias=eab_active    overall_timeout=35
    execute uex command    ue_attach id=5-6 cell=1 ue_eutra_capabilities=${CATM_UE_CAPABILITIES}
    flow occurred as expected    alias=eab_active

RRC_EAB keeps Active
    [Arguments]    ${bar_state}=eab_active1
    expect message will not occur
    ...    CELL_1:RRC_SystemInformationBlockType14-BR-r13 (${static_eab})
    ...    alias=eab_active_no_change    overall_timeout=25
    execute uex command    ue_detach id=3-5
    execute uex command    ue_attach id=7-8 cell=1 ue_eutra_capabilities=${CATM_UE_CAPABILITIES}
    flow not occurred for message    alias=eab_active_no_change

Detach 2CatM UEs And Wait StopTimer expires
    [Arguments]    ${bar_state}=eab_inactive
    expect message flow
    ...    UE_6:RRC_RRCConnectionRelease
    ...    UE_7:RRC_RRCConnectionRelease
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (${sib14})
    ...    CELL_1:RRC_SystemInformationBlockType14-BR-r13 (${static_eab})
    ...    alias=change_eab_static    overall_timeout=30
    execute uex command    ue_detach id=6-7
    flow occurred as expected    alias=change_eab_static

