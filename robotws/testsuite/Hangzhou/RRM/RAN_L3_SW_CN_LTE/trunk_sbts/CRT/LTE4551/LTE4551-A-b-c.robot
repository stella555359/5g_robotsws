*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CRT    team-DevHZ5_SG3
...               CLOUD_R4LAPO_CUS    release-xL18SP    owner-menghuan.fang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_A_b}
@{PARAMS_FOR_CATM}
...    LNCEL/LNCEL_FDD-0:actCatM=true
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_FDD-0:catMProfId=1
...    LNCEL/SIB-0:siWindowLen=40ms
...    LNCEL/SIB-0:threshServingLowQR9=0
...    LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL:inactivityTimerQci5Sign=150
...    LNCEL:qci1ProtectionTimer=100
...    LNBTS-1:qciTab5:schedulType=SIGNALLING
...    LNBTS-1:qciTab5:lcgid=0
...    LNBTS-1:actMultBearers=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1:actRrcConnNoActivity=true
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNBTS-1/LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNBTS-1/LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNBTS-1/LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNBTS-1/LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNBTS-1/LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNBTS-1/LNCEL-2/IAFIM-1:intrFrBCList:startIntraPci=120
...    LNBTS-1/LNCEL-2/IAFIM-1:intrFrNCList:physCellIdNcl=0
...    LNBTS-1/LNCEL-2/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...    LNBTS-1/LNCEL-2:inactivityTimerQci5Sign=150
...    LNBTS-1/LNCEL-2:iniMcsUl=4
...    LNBTS-1/LNCEL-2:mbrSelector=ueCapability
...    LNBTS-1/LNCEL-2:harqMaxMsg3=3
...    LNBTS-1/LNCEL-2:phyCellId=2
...    LNBTS-1/LNCEL-2:caPoolId=1
...    LNBTS-1/LNCEL-2:dlTargetBler=100
...    LNBTS-1/LNCEL-2:assignedVoLteQualProfile=1
...    LNBTS-1/LNCEL-2:eIcicMaxNumPartners=10
...    LNBTS-1/LNCEL-2:prsBandwidth=6 PRB
...    LNBTS-1/LNCEL-2/SLMEAS-0:hysThreshold2Sidelink=4
...    LNBTS-1/LNCEL-2/SLMEAS-0:threshold2Sidelink=21
...    LNBTS-1/LNCEL-2/SLMEAS-0:a2TimeToTriggerActSL=480ms
...    LNBTS-1/LNCEL-2/IRFIM-1:dlCarFrqEut=21000
...    LNBTS-1/LNCEL-2/IRFIM-1:intFrBCList:startInterPci=0
...    LNBTS-1/LNCEL-3/IRFIM-1:dlCarFrqEut=21000
...    LNBTS-1/LNCEL-3/IRFIM-1:intFrBCList:startInterPci=0
...    LNBTS-1/LNCEL-3/IAFIM-1:intrFrBCList:startIntraPci=120
...    LNBTS-1/LNCEL-3/IAFIM-1:intrFrNCList:physCellIdNcl=0
...    LNBTS-1/LNCEL-3/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:dlCarFrqEut=1500
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:eutCelResPrio=7
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:idleLBEutCelResWeightCatM=1
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interFrqThrH=10
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interFrqThrL=6
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interPresAntP=false
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interTResEut=1
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interTResEutCeCatM=1
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:mbmsNeighCellConfigInterF=00
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:measBdw=6mbw
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:pMaxInterF=-30
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:qOffFrq=0 dB
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:qQualMinInterF=-34
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:qQualMinInterFCeCatM=-3
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:qRxLevMinInterF=-130
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:qRxLevMinInterFCeCatM=-136
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:intFrBCList:rangeInterPci=n4
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:intFrBCList:startInterPci=0
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:intFrNCList:physCellIdNcl=503
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:intFrNCList:qOffCell=-24 dB
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interFrqQThrR9:interFrqQThrHighR9=0
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:interFrqQThrR9:interFrqQThrLowR9=0
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:tResEutSF:eutResTiFHM=0.5
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:tResEutSF:eutResTiFMM=0.5
...    LNBTS-1/LNCEL/CATMCEL-0:cellReSelPrioCatM=7
@{PARAMS_FOR_A_b}
...    delete:LNBTS-1/LNCEL-1/CATMCEL-0.acbPlmnNumStepsCatM
...    delete:LNBTS-1/LNCEL/CATMCEL-0.eabProfileIdCatM
...    LNCEL:inactivityTimer=75
...    LNBTS-1/CATMPR-1:inactivityTimerCatM=60
...    LNBTS-1/CATMPR-1:cpInactivityTimerCatM=30
...    LNBTS-1/CATMPR-1:raPreGrCSizeCatM=7
...    LNBTS-1/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=70
...    LNBTS-1/LNCEL-1:tac=33
...    LNBTS-1/LNCEL-2:tac=34
${UE_EUTRA_CAPABILITIES_CATM}    D61FF000800055555D55001000804510021200055C041900    # CATM FGI3,7,20 set as 1,enable ROHC
${UE_EUTRA_CAPABILITIES_WideBand}
...    SEPARATOR=
...    858001F0008206102860E2048A163069022489942A58B983268D9C3A94727D00003FFFFFFFE03E008864298E84A96C6C1C242C344C539F0103
...    050F1117191B1D1E
@{delta_para_A_b_1_initial}
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB4
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNBTS-1/LNCEL-1/IRFIM-1:dlCarFrqEut=21000
...    LNBTS-1/LNCEL-1/IRFIM-1:intFrBCList:startInterPci=0
...    LNBTS-1/LNCEL-1/IAFIM-1:intrFrBCList:startIntraPci=120
...    LNBTS-1/LNCEL-1/IAFIM-1:intrFrNCList:physCellIdNcl=0
...    LNBTS-1/LNCEL-1/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...    LNBTS-1/LNCEL-1/CATMCEL-0:cellReSelPrioCatM=${sib3br_cellReSelPrioCatM}
...    LNBTS-1/LNCEL-1/CATMCEL-0:threshSrvLowCatM=${sib3br_threshSrvLowCatM}
...    LNBTS-1/LNCEL-1/CATMCEL-0:threshServingLowQR9CatM=${sib3br_threshServingLowQR9CatM}
...    LNBTS-1/LNCEL-1/CATMCEL-0:sNonIntraSearchV920CatM:sNonIntraSearchPR9CatM=${sib3br_sNonIntraSearchPR9CatM}
...    LNBTS-1/LNCEL-1/CATMCEL-0:sNonIntraSearchV920CatM:sNonIntraSearchQR9CatM=${sib3br_sNonIntraSearchQR9CatM}
...    LNBTS-1/LNCEL-1/CATMCEL-0:sNonIntrsearchCatM=${sib3br_sNonIntrsearchCatM}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:nCellChgHigh=${sib3_3br_nCellChgHigh}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:nCellChgMed=${sib3_3br_nCellChgMed}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:qHystSfHigh=${sib3_3br_qHystSfHigh} dB
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:qHystSfMed=${sib3_3br_qHystSfMed} dB
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:tEvaluation=${sib3_3br_tEvaluation}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:tHystNormal=${sib3_3br_tHystNormal}
...    LNBTS-1/LNCEL-1/SIB-0:celResTiF:celResTiFHM=${sib3_3br_celResTiFHM}
...    LNBTS-1/LNCEL-1/SIB-0:celResTiF:celResTiFMM=${sib3_3br_celResTiFMM}
@{delta_para_A_b_1_step3}
...    LNBTS-1/LNCEL-1/CATMCEL-0:cellReSelPrioCatM=${${sib3br_cellReSelPrioCatM}-1}
...    LNBTS-1/LNCEL-1/CATMCEL-0:threshSrvLowCatM=${${sib3br_threshSrvLowCatM}+4}
...    LNBTS-1/LNCEL-1/CATMCEL-0:threshServingLowQR9CatM=${${sib3br_threshServingLowQR9CatM}+2}
...    LNBTS-1/LNCEL-1/CATMCEL-0:sNonIntraSearchV920CatM:sNonIntraSearchPR9CatM=${${sib3br_sNonIntraSearchPR9CatM}+2}
...    LNBTS-1/LNCEL-1/CATMCEL-0:sNonIntraSearchV920CatM:sNonIntraSearchQR9CatM=${${sib3br_sNonIntraSearchQR9CatM}+2}
...    LNBTS-1/LNCEL-1/CATMCEL-0:sNonIntrsearchCatM=${${sib3br_sNonIntrsearchCatM}+8}
@{delta_para_A_b_1_step4}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:nCellChgHigh=${${sib3_3br_nCellChgHigh}+2}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:nCellChgMed=${${sib3_3br_nCellChgMed}+2}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:qHystSfHigh=${${sib3_3br_qHystSfHigh}+2} dB
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:qHystSfMed=${${sib3_3br_qHystSfMed}+2} dB
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:tEvaluation=${sib3_3br_tEvaluation.replace("30s", "180s")}
...    LNBTS-1/LNCEL-1/SIB-0:spStResPars:tHystNormal=${sib3_3br_tHystNormal.replace("30s", "180s")}
...    LNBTS-1/LNCEL-1/SIB-0:celResTiF:celResTiFHM=${sib3_3br_celResTiFHM.replace("0.25", "0.5")}
...    LNBTS-1/LNCEL-1/SIB-0:celResTiF:celResTiFMM=${sib3_3br_celResTiFMM.replace("0.25", "1")}
@{delta_para_A_c_1_initial}
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB4
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNBTS-1/LNCEL-1/IRFIM-1:dlCarFrqEut=21000
...    LNBTS-1/LNCEL-1/IRFIM-1:intFrBCList:startInterPci=0
...    LNBTS-1/LNCEL-1/IAFIM-1:intrFrBCList:startIntraPci=120
...    LNBTS-1/LNCEL-1/IAFIM-1:intrFrNCList:physCellIdNcl=0
...    LNBTS-1/LNCEL-1/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...    LNBTS-1/LNCEL/CATMCEL-0:cellReSelPrioCatM=7
@{delta_para_A_c_1_step3}
...    LNBTS-1/CATMPR-1:sib5PeriodicityCatM=640ms
@{delta_para_A_c_1_step4}
...    LNBTS-1/LNCEL-1/CATMCEL-0/CATMIRFIM-1:measBdw=15mbw
${sib3br_cellReSelPrioCatM}    7
${sib3br_threshSrvLowCatM}    0
${sib3br_threshServingLowQR9CatM}    2
${sib3br_sNonIntraSearchPR9CatM}    2
${sib3br_sNonIntraSearchQR9CatM}    4
${sib3br_sNonIntrsearchCatM}    2
${sib3_3br_nCellChgHigh}    8
${sib3_3br_nCellChgMed}    8
${sib3_3br_qHystSfHigh}    -4
${sib3_3br_qHystSfMed}    -4
${sib3_3br_tEvaluation}    30s
${sib3_3br_tHystNormal}    30s
${sib3_3br_celResTiFHM}    0.25
${sib3_3br_celResTiFMM}    0.25
${waiting_sibs_timeout}    5s

*** Test Cases ***
LTE4551-A-b_ET_01_01_Non-essential SIB3-BR modification
    [Tags]
    Preparation for cases    ${delta_para_A_b_1_initial}
    Wideband UE attach and start T-put     ue_id=1
    CAT-M UE attach and start T-put     ue_id=2
    Online commissioning via SEM to modify non-essential parameters in CATMCEL    wide_band_ue=1    CATM_UE=2
    Online commissioning via SEM to modify non-essential parameters in MOC SIB    wide_band_ue=1    CATM_UE=2

LTE4551-A-c_ET_01_01_Essential SIB5-BR modification when modify sib5PeriodicityCatM
    [Tags]
    Preparation for cases    ${delta_para_A_c_1_initial}
    Wideband UE attach and start T-put     ue_id=3
    CAT-M UE attach and start T-put     ue_id=4
    Online commissioning to modify sib5PeriodicityCatM    wide_band_ue=3    CATM_UE=4
    Online commissioning to modify measBdw for SIB5    wide_band_ue=3    CATM_UE=4

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=200
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=100    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Preparation for cases
    [Arguments]    ${delta_params}=${empty}
    Delta Commission Parameters    ${delta_params}
    Cells Should Be OnAir
    Block and Unblock cell

Block and Unblock cell
    Block Cell1
    Unblock Cell1
	sleep    ${waiting_sibs_timeout}

Wideband UE attach and start T-put
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_WideBand} enb=1 cell=${cell_id}
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=5 kbps=20 dir=dl protocol=udp trf_id=1

CAT-M UE attach and start T-put
    [Arguments]    ${ue_id}=2    ${cell_id}=1
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=${cell_id}
    Execute Uex Command    trf_data_start ue=${ue_id} bearer=5 kbps=20 dir=dl protocol=udp trf_id=1

Get SIB3 Flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3 as sib3
    ...    alias=sib3_flow_old  overall_timeout=10
    Flow Occurred As Expected    alias=sib3_flow_old

Check No SIB3 update
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3 as sib3
    ...    alias=sib3_flow_new  overall_timeout=10
    Flow Occurred As Expected    alias=sib3_flow_new
    ${sib3_old}    Get Message    sib3_flow_old    sib3
    ${sib3_new}    Get Message    sib3_flow_new    sib3
    message should be same    ${sib3_old}    ${sib3_new}

Online commissioning via SEM to modify non-essential parameters in CATMCEL
    [Arguments]    ${wide_band_ue}=1    ${CATM_UE}=2
    Get SIB3 Flow
    Expect Message Will Not Occur
    ...    UE_GROUP_${wide_band_ue}:RRC_RRCConnectionRelease
    ...    alias=normal_ue_no_release_flow    overall_timeout=40
    Expect Message Will Not Occur
    ...    UE_GROUP_${CATM_UE}:RRC_RRCConnectionRelease
    ...    alias=CATM_ue_no_release_flow    overall_timeout=40
    Delta Commission Parameters    ${delta_para_A_b_1_step3}
    sleep    ${waiting_sibs_timeout}
    Flow Not Occurred For Message    alias=normal_ue_no_release_flow
    Flow Not Occurred For Message    alias=CATM_ue_no_release_flow
    Check No SIB3 update


Online commissioning via SEM to modify non-essential parameters in MOC SIB
    [Arguments]    ${wide_band_ue}=1    ${CATM_UE}=2
    Expect Message Will Not Occur
    ...    UE_GROUP_${wide_band_ue}:RRC_RRCConnectionRelease
    ...    alias=normal_ue_no_release_flow    overall_timeout=40
    Expect Message Will Not Occur
    ...    UE_GROUP_${CATM_UE}:RRC_RRCConnectionRelease
    ...    alias=CATM_ue_no_release_flow    overall_timeout=40
    Delta Commission Parameters    ${delta_para_A_b_1_step4}
    Flow Not Occurred For Message    alias=normal_ue_no_release_flow
    Flow Not Occurred For Message    alias=CATM_ue_no_release_flow
	sleep    ${waiting_sibs_timeout}
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3 (cellReselectionServingFreqInfo contains (cellReselectionPriority eq 1))
    ...    alias=sib3_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib3_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType4 (intraFreqNeighCellList contains (q-OffsetCell is present))
    ...    alias=sib4_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib4_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5 (interFreqCarrierFreqList contains (dl-CarrierFreq eq 21000))
    ...    alias=sib5_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_flow
    # check SIB3-BR/4-BR/5-BR
    ${sib3BR}    catenate
    ...    cellReselectionServingFreqInfo contains ((cellReselectionPriority eq 6) and (s-NonIntraSearch is not present))
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3-BR-r13 (${sib3BR})
    ...    alias=sib3br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib3br_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType4-BR-r13 (intraFreqNeighCellList contains (q-OffsetCell is present))
    ...    alias=sib4br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib4br_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 (interFreqCarrierFreqList contains (dl-CarrierFreq eq 1500))
    ...    alias=sib5br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib5br_flow


Online commissioning to modify sib5PeriodicityCatM
    [Arguments]    ${wide_band_ue}=3    ${CATM_UE}=4
    Expect Message Flow
    ...    UE_GROUP_${CATM_UE}:RRC_RRCConnectionRelease
    ...    alias=ue_release_flow  overall_timeout=70
    Expect Message Will Not Occur
    ...    UE_GROUP_${wide_band_ue}:RRC_RRCConnectionRelease
    ...    alias=wide_band_ue_not_release_flow    overall_timeout=70
    Delta Commission Parameters    ${delta_para_A_c_1_step3}
    Flow Occurred As Expected    alias=ue_release_flow
    Flow Not Occurred For Message    alias=wide_band_ue_not_release_flow

Get SIB5 Flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5 as sib5
    ...    alias=sib5_flow_old  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_flow_old

Check No SIB5 update
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5 as sib5
    ...    alias=sib5_flow_new  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_flow_new
    ${sib5_old}    Get Message    sib5_flow_old    sib5
    ${sib5_new}    Get Message    sib5_flow_new    sib5
    message should be same    ${sib5_old}    ${sib5_new}

Online commissioning to modify measBdw for SIB5
    [Arguments]    ${wide_band_ue}=3    ${CATM_UE}=4
    Get SIB5 Flow
    Expect Message Will Not Occur
    ...    UE_GROUP_${wide_band_ue}:RRC_RRCConnectionRelease
    ...    alias=wide_band_ue_not_release_flow    overall_timeout=60
    Delta Commission Parameters    ${delta_para_A_c_1_step4}
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3 (cellReselectionServingFreqInfo contains (cellReselectionPriority eq 1))
    ...    alias=sib3_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib3_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType4 (intraFreqNeighCellList contains (q-OffsetCell is present))
    ...    alias=sib4_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib4_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5 (interFreqCarrierFreqList contains (dl-CarrierFreq eq 21000))
    ...    alias=sib5_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_flow
    # check SIB3-BR/4-BR/5-BR
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3-BR-r13 (cellReselectionServingFreqInfo contains (cellReselectionPriority eq 7))
    ...    alias=sib3br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib3br_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType4-BR-r13 (intraFreqNeighCellList contains (q-OffsetCell is present))
    ...    alias=sib4br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib4br_flow
    ${sib5BR}    catenate
    ...    (interFreqCarrierFreqList contains (dl-CarrierFreq eq 1500)) and (allowedMeasBandwidth eq "mbw15")
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 (${sib5BR})
    ...    alias=sib5br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib5br_flow
    ${sib1BR}    catenate
    ...    schedulingInfoList contains ((si-Periodicity eq "rf64"), (sib-MappingInfo contains ("sibType5")))
     Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType1-BR-r13 (${sib1BR})
    ...    alias=sib1br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib1br_flow
    Check No SIB5 update
    Flow Not Occurred For Message    alias=wide_band_ue_not_release_flow






