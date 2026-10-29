*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    owner-menghuan.fang,annie.nie    release-SBTS19B    team-CN3ET
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS:actIdleLB=false
...    LNCEL-1:idleLBPercentageOfUes=100
...    LNCEL-1:t320=180min
...    LNBTS:moProfileSelect=spid
...    LNBTS:actIdleLBTM9aware=true
...    LNBTS:actIdleLBCaAware=false
...    LNBTS:actIdleLBCaAwareAdv=false
...    @{LTE4945}
...    @{RELATION_ERRORS}
@{RELATION_ERRORS}
...    LNCEL-2:loadSettings:cellCapClass=100
...    LNCEL-2:loadSettings:ulStaticCac=100
...    LNCEL-3:loadSettings:cellCapClass=100
...    LNCEL-3:loadSettings:ulStaticCac=100
@{LTE4945}
...    LNCEL-1:targetSelMethod=SIB_based
...    LNCEL-2:targetSelMethod=SIB_based
...    LNCEL-3:targetSelMethod=SIB_based
...    LNCEL-1:cellResourceSharingMode=DLonly
...    LNCEL-1:idleLBCapThreshUeTM9=100
...    LNCEL-2:idleLBCapThreshUeTM9=100
...    LNCEL-3:idleLBCapThreshUeTM9=100
...    delete:LNCEL-1:idleLBCelResWeight
...    delete:LNCEL-1:idleLBCelResWeightTM9
...    LNBTS:cellResourceSharingType=spidBased
...    LNBTS/CRGPR-1:spidGroupList:spid=1|groupId=0
...    LNBTS/CRGPR-1:spidGroupList:spidLast=2|groupId=0
...    LNBTS/CRGPR-1:spidGroupList:spid=3|groupId=1
...    LNBTS/CRGPR-1:spidGroupList:spidLast=4|groupId=1
...    delete:LNBTS/CRGPR-1:plmnGroupList
...    LNCEL-1:idleLBPercUeTM9=100
...    LNCEL-1/SIB-0:cellReSelPrio=1
...    LNCEL-1/SIB-0:cellReSelSubPrio=oDot2
...    LNCEL-1:idleLBCellReSelPrioTM9=12
...    LNBTS/MODPR-0:idleLBPercUeTM9=100
...    LNBTS/MODPR-0:targetSelMethod=SIB_based
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrioTM9=20
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:dlCarFrqEut=1700
...    LNBTS/MOPR-1:idleLBPercUeTM9=100
...    LNBTS/MOPR-1:targetSelMethod=dedicated
...    LNBTS/MOPR-1/MOIMP-1:dlCarFrqEutL:idleLBEutCelResPrioTM9=30
...    LNBTS/MOPR-1/MOIMP-1:dlCarFrqEutL:dlCarFrqEut=1800
...    delete:LNCEL-1/IRFIM-1:idleLBEutCelResWeightTM9
...    LNCEL-1/IRFIM-1:idleLBEutCelResWeight=100
...    LNCEL-1/IRFIM-1:idleLBEutCelResPrioTM9=25
...    LNCEL-1/IRFIM-1:eutCelResPrio=6
...    LNCEL-1/IRFIM-1:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-1:minRsrpIMLB=-120
...    LNCEL-1/IRFIM-1:minDeltaRsrpIMLB=0
...    LNCEL-1/IRFIM-1:dlCarFrqEut=1450
...    LNCEL-1/IRFIM-2:idleLBEutCelResWeightTM9=100
...    delete:LNCEL-1/IRFIM-2:idleLBEutCelResWeight
...    LNCEL-1/IRFIM-2:idleLBEutCelResPrioTM9=25
...    LNCEL-1/IRFIM-2:eutCelResPrio=1
...    LNCEL-1/IRFIM-2:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-2:minRsrpIMLB=-120
...    LNCEL-1/IRFIM-2:minDeltaRsrpIMLB=0
...    LNCEL-1/IRFIM-2:dlCarFrqEut=1500
...    delete:LNCEL-1/IRFIM-3:idleLBEutCelResWeightTM9
...    delete:LNCEL-1/IRFIM-3:idleLBEutCelResWeight
...    LNCEL-1/IRFIM-3:idleLBEutCelResPrioTM9=25
...    LNCEL-1/IRFIM-3:eutCelResPrio=6
...    LNCEL-1/IRFIM-3:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-3:minRsrpIMLB=-120
...    LNCEL-1/IRFIM-3:minDeltaRsrpIMLB=0
...    LNCEL-1/IRFIM-3:dlCarFrqEut=1550
...    delete:LNCEL-1/IRFIM-4:idleLBEutCelResWeightTM9
...    delete:LNCEL-1/IRFIM-4:idleLBEutCelResWeight
...    LNCEL-1/IRFIM-4:idleLBEutCelResPrioTM9=25
...    LNCEL-1/IRFIM-4:eutCelResPrio=6
...    LNCEL-1/IRFIM-4:enableA4IMLB=enabled
...    LNCEL-1/IRFIM-4:minRsrpIMLB=-120
...    LNCEL-1/IRFIM-4:minDeltaRsrpIMLB=0
...    LNCEL-1/IRFIM-4:dlCarFrqEut=1600
...    LNCEL-1/GFIM-1/GNFL-1:idleLBGeranCelResPrio=4
...    LNCEL-1/GFIM-1/GNFL-1:gCelResPrio=3
...    LNCEL-1/GFIM-1/GNFL-1:idleLBGeranCelResWeight=20
...    delete:LNCEL-1/CDFIM-1:rttNCList
...    delete:LNCEL-1/CDFIM-1:tResRtt
...    delete:LNCEL-1/CDFIM-1:hrpdNCList
...    delete:LNCEL-1/CDFIM-1:hrpdBdClList
...    delete:LNCEL-1/CDFIM-1:tResHrpd
...    delete:LNCEL-1/CDFIM-1:rttBdClList
...    LNBTS/MODPR-0:autoAdaptIMLB=false
...    LNCEL-1/GFIM-1/GNFL-1:gerArfcnVal=512
...    LNCEL-1/GFIM-1/GNFL-1:bandInd=gsm1800
...    delete:LNCEL-1/UFFIM-1:utrFddCarFrqL:idleLBUtranFddCelResPrio
...    LNBTS:actSelMobPrf=true
${ue_eutra_capabilities}
...    SEPARATOR=
...    D5BFF004094182248102008021FF9A313C1014A82181F8800183840000340001E500001080007400004074008060C100401001F5F200001640
...    80304A601801955410001000
@{MODPR}
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeightTM9=100|dlCarFrqEut=1450
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrio=4|dlCarFrqEut=1450
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrioTM9=4|dlCarFrqEut=1450
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeight=1|dlCarFrqEut=1450
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeightTM9=100|dlCarFrqEut=1500
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrio=4|dlCarFrqEut=1500
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrioTM9=4|dlCarFrqEut=1500
...    LNBTS/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeight=1|dlCarFrqEut=1500
...    LNBTS/MODPR-0/MODIMP-1:geranCarFrqBd:geranBandInd=gsm1800
...    LNBTS/MODPR-0/MODIMP-1:geranCarFrqBd:idleLBGeranCelResPrio=5
...    LNBTS/MODPR-0/MODIMP-1:geranCarFrqIdleModeL=512
...    LNBTS/MODPR-0:idleLBPercUeTM9=100
...    LNBTS/MODPR-0:targetSelMethod=SIB_based
...    LNBTS/MODPR-0:autoAdaptIMLB=false
...    LNCEL-1:inactivityTimer=10
...    LNBTS:actMeasBasedIMLB=false
...    LNCEL-1/IRFIM-1:dlCarFrqEut=1450
...    LNCEL-1/IRFIM-1:eutCelResPrio=2
...    LNCEL-1/IRFIM-1:idleLBEutCelResWeight=100
...    LNCEL-1/IRFIM-2:eutCelResPrio=1
...    delete:LNCEL-1/IRFIM-2:idleLBEutCelResWeight
...    LNCEL-1/IRFIM-2:idleLBEutCelResWeightTM9=100
...    LNCEL-1/IRFIM-2:dlCarFrqEut=1500
...    LNBTS/MODPR-0:idleLBPercentageOfUes=100
${RRC_CONN_REL_IMMCI_TM9}    M8008C42
@{Modify_Geran_Priority}
...    LNCEL-1/GFIM-1/GNFL-1:gCelResPrio=0
@{PM_Counters_for_01_02}
...    LNCEL-1:${RRC_CONN_REL_IMMCI_TM9}=2
${UE_NOT_SUPPORT_TM9}
...    SEPARATOR=
...    D5BFF0060941822049190408020087FE68C4F04052A08607C200060E100000D00007940000420001D0000101D00201830401004004590200C1
...    298060065550400040
@{delete_MODPR_TM9_weight}
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeightTM9=100|dlCarFrqEut=1450
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrio=4|dlCarFrqEut=1450
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrioTM9=4|dlCarFrqEut=1450
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeight=1|dlCarFrqEut=1450
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeightTM9=${EMPTY}|dlCarFrqEut=1500
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrio=4|dlCarFrqEut=1500
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResPrioTM9=4|dlCarFrqEut=1500
...    LNBTS-1/MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeight=1|dlCarFrqEut=1500
${IMMCI_With_EUTRA_Freq}
...    idleModeMobilityControlInfo contains (
...    freqPriorityListEUTRA contains (
...    (carrierFreq eq 1450 and cellReselectionPriority eq 7),
...    (carrierFreq eq 1500 and cellReselectionPriority eq 0)))
${IMMCI_With_GERAN_Freq}
...    idleModeMobilityControlInfo contains (
...    freqPriorityListEUTRA contains (
...    (carrierFreq eq 1450 and cellReselectionPriority eq 7),
...    (carrierFreq eq 1500 and cellReselectionPriority eq 0))
...    and
...    freqPriorityListGERAN contains
...    (carrierFreqs contains (startingARFCN eq 512)
...    and cellReselectionPriority eq 2))
${No_GERAN_Freq}
...    freqPriorityListGERAN contains (carrierFreqs contains (startingARFCN eq 512))
${PM_COUNTER_INTERVAL}    1min
*** Test Cases ***
LTE4945-A-e_01_02_M8008C42 imcrement for IMMCI due to load independent mode and target selection method is SIB based with MODPR
    [Tags]
    Start RTPM Counter
    Online Commission for 01_02
    UE not supported TM9 attach to the cell
    UE with TM9 Cap attach to the cell1
    Online modify Geran priority and Geran frequency will not in IMMCI
    Check RTPM Counters    ${PM_Counters_for_01_02}

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env
    Create Alias
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 protocol=rrc on

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Online Commission for 01_02
    Delta Commission Parameters    ${MODPR}
    Delta Commission Parameters    ${delete_MODPR_TM9_weight}
    Cells Should Be OnAir

UE not supported TM9 attach to the cell
    expect message flow
    ...    UE_2:RRC_RRCConnectionRelease (${IMMCI_With_EUTRA_Freq})
    ...    alias=no_GERAN_IMMCI    overall_timeout=20
    execute uex command    ue_attach id=2 ue_eutra_capabilities=${UE_NOT_SUPPORT_TM9} cell=1
    execute uex command    ue_detach id=2
    flow occurred as expected    alias=no_GERAN_IMMCI

UE with TM9 Cap attach to the cell1
    expect message flow
    ...    UE_1:RRC_RRCConnectionRelease (${IMMCI_With_GERAN_Freq})
    ...    alias=with_geran_freq    overall_timeout=20
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    execute uex command    ue_detach id=1
    flow occurred as expected    alias=with_geran_freq

Online modify Geran priority and Geran frequency will not in IMMCI
    Delta Commission Parameters    ${Modify_Geran_Priority}
    expect message flow
    ...    MME_1:S1AP_UEContextReleaseRequest (radioNetwork eq "user-inactivity")
    ...    UE_1:RRC_RRCConnectionRelease (${IMMCI_With_EUTRA_Freq})
    ...    alias=inter_freq    overall_timeout=20
    expect message will not occur
    ...    UE_1:RRC_RRCConnectionRelease (${No_GERAN_Freq})
    ...    alias=no_GERAN_freq    overall_timeout=20
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${ue_eutra_capabilities} cell=1
    Wait 10s For Inactivity Release
    flow occurred as expected    alias=inter_freq
    flow not occurred for message    alias=no_GERAN_freq

Wait 10s For Inactivity Release
    [Arguments]    ${time}=10s
    sleep    ${time}