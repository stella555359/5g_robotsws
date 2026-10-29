*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_FDD    RAN_4G    RAN_4G_FDD    CIT
...               CLOUD_R4LAPO_CUS    release-xL18SP    owner-menghuan.fang    owner-yin.zhang    DEVHZ5_FT3
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{PARAMS_FOR_CATM}
...  @{PARAMS_FOR_A_b}
@{PARAMS_FOR_CATM}
...  LNCEL/LNCEL_FDD-0:actCatM=true
...  LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...  LNCEL/LNCEL_FDD-0:catMProfId=1
...  LNCEL/SIB-0:siWindowLen=40ms
...  LNCEL/SIB-0:threshServingLowQR9=0
...  LNCEL/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...  LNCEL/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...  LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...  LNCEL/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...  LNCEL:inactivityTimerQci5Sign=150
...  LNCEL:qci1ProtectionTimer=100
...  LNBTS:qciTab5:schedulType=SIGNALLING
...  LNBTS:qciTab5:lcgid=0
...  LNBTS:actMultBearers=true
...  LNBTS/LNBTS_FDD-0:actConvVoice=true
...  LNBTS:actRrcConnNoActivity=true
...  LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...  LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...  LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...  LNCEL-2/IAFIM-1:intrFrBCList:startIntraPci=120
...  LNCEL-2/IAFIM-1:intrFrNCList:physCellIdNcl=0
...  LNCEL-2/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...  LNCEL-2:inactivityTimerQci5Sign=150
...  LNCEL-2:iniMcsUl=4
...  LNCEL-2:mbrSelector=ueCapability
...  LNCEL-2:harqMaxMsg3=3
...  LNCEL-2:phyCellId=2
...  LNCEL-2:caPoolId=1
...  LNCEL-2:dlTargetBler=100
...  LNCEL-2:assignedVoLteQualProfile=1
...  LNCEL-2:eIcicMaxNumPartners=10
...  LNCEL-2:prsBandwidth=6 PRB
...  LNCEL-2/SLMEAS-0:hysThreshold2Sidelink=4
...  LNCEL-2/SLMEAS-0:threshold2Sidelink=21
...  LNCEL-2/SLMEAS-0:a2TimeToTriggerActSL=480ms
...  LNCEL-2/IRFIM-1:dlCarFrqEut=21000
...  LNCEL-2/IRFIM-1:intFrBCList:startInterPci=0
...  LNCEL-3/IRFIM-1:dlCarFrqEut=21000
...  LNCEL-3/IRFIM-1:intFrBCList:startInterPci=0
...  LNCEL-3/IAFIM-1:intrFrBCList:startIntraPci=120
...  LNCEL-3/IAFIM-1:intrFrNCList:physCellIdNcl=0
...  LNCEL-3/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:dlCarFrqEut=1500
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:interFrqThrH=10
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:interFrqThrL=6
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:interPresAntP=false
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:interTResEut=1
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:interTResEutCeCatM=1
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:mbmsNeighCellConfigInterF=00
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:measBdw=6mbw
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:qOffFrq=0 dB
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:qRxLevMinInterF=-130
...  LNCEL-1/CATMCEL-0/CATMIRFIM-1:qRxLevMinInterFCeCatM=-136
@{PARAMS_FOR_A_b}
...  LNCEL:inactivityTimer=75
...  LNBTS/CATMPR-1:inactivityTimerCatM=60
...  LNBTS/CATMPR-1:cpInactivityTimerCatM=30
...  LNBTS/CATMPR-1:raPreGrCSizeCatM=7
...  LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=70
...  LNCEL/CATMCEL-0:cellReSelPrioCatM=7
...  LNCEL-1:tac=33
...  LNCEL-2:tac=34
${UE_EUTRA_CAPABILITIES_CATM}    D61FF000800055555D55001000804510021200055C041900    # CATM FGI3,7,20 set as 1,enable ROHC
${UE_EUTRA_CAPABILITIES_WideBand}
...  SEPARATOR=
...  858001F0008206102860E2048A163069022489942A58B983268D9C3A94727D00003FFFFFFFE03E008864298E84A96C6C1C242C344C539F0103
...  050F1117191B1D1E
@{delta_para_A_b_3_initial}
...  LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB4
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB4
...  LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB5
...  LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...  LNCEL-1/IRFIM-1:dlCarFrqEut=21000
...  LNCEL-1/IRFIM-1:intFrBCList:startInterPci=0
...  LNCEL-1/IAFIM-1:intrFrBCList:startIntraPci=120
...  LNCEL-1/IAFIM-1:intrFrNCList:physCellIdNcl=0
...  LNCEL-1/IAFIM-1:intrFrNCList:qOffsetCell=0 dB
...  LNCEL-1/CATMCEL-0:cellReSelPrioCatM=${sib3br_cellReSelPrioCatM}
...  LNCEL-1/CATMCEL-0:threshSrvLowCatM=${sib3br_threshSrvLowCatM}
...  LNCEL-1/CATMCEL-0:threshServingLowQR9CatM=${sib3br_threshServingLowQR9CatM}
...  LNCEL-1/CATMCEL-0:sNonIntraSearchV920CatM:sNonIntraSearchPR9CatM=${sib3br_sNonIntraSearchPR9CatM}
...  LNCEL-1/CATMCEL-0:sNonIntraSearchV920CatM:sNonIntraSearchQR9CatM=${sib3br_sNonIntraSearchQR9CatM}
...  LNCEL-1/CATMCEL-0:sNonIntrsearchCatM=${sib3br_sNonIntrsearchCatM}
...  LNCEL-1/SIB-0:spStResPars:nCellChgHigh=${sib3_3br_nCellChgHigh}
...  LNCEL-1/SIB-0:spStResPars:nCellChgMed=${sib3_3br_nCellChgMed}
...  LNCEL-1/SIB-0:spStResPars:qHystSfHigh=${sib3_3br_qHystSfHigh}
...  LNCEL-1/SIB-0:spStResPars:qHystSfMed=${sib3_3br_qHystSfMed}
...  LNCEL-1/SIB-0:spStResPars:tEvaluation=${sib3_3br_tEvaluation}
...  LNCEL-1/SIB-0:spStResPars:tHystNormal=${sib3_3br_tHystNormal}
...  LNCEL-1/SIB-0:celResTiF:celResTiFHM=${sib3_3br_celResTiFHM}
...  LNCEL-1/SIB-0:celResTiF:celResTiFMM=${sib3_3br_celResTiFMM}
@{delta_para_A_b_3_step3}
...  LNCEL-1/CATMCEL-0/CATMIRFIM-2:dlCarFrqEut=1550
@{delta_para_A_b_3_step4}
...  delete:LNCEL-1/CATMCEL-0/CATMIRFIM-1
...  LNCEL-1/CATMCEL-0:cellReSelPrioCatM=5
@{delta_para_A_b_3_step5}
...  LNCEL-1/IRFIM-2:dlCarFrqEut=21050
${sib3br_cellReSelPrioCatM}    7
${sib3br_threshSrvLowCatM}    0
${sib3br_threshServingLowQR9CatM}    2
${sib3br_sNonIntraSearchPR9CatM}    2
${sib3br_sNonIntraSearchQR9CatM}    4
${sib3br_sNonIntrsearchCatM}    2
${sib3_3br_nCellChgHigh}    8
${sib3_3br_nCellChgMed}    8
${sib3_3br_qHystSfHigh}    -4 dB
${sib3_3br_qHystSfMed}    -4 dB
${sib3_3br_tEvaluation}    30s
${sib3_3br_tHystNormal}    30s
${sib3_3br_celResTiFHM}    0.25
${sib3_3br_celResTiFMM}    0.25

*** Test Cases ***
LTE4551-A-b_ET_01_03_Non-essential SIB3-BR and SIB5-BR modification
    [Tags]
    Preparation for A-b-01-03
    Wideband UE attach and start T-put
    CAT-M UE attach and start T-put
    Online commissioning to add a second MOC CATMIRFIM
    Online commissioning to remove one new MOC CATMIRFIM
    Online commissioning to add a second MOC IRFIM

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus

Preparation for A-b-01-03
    Delta Commission Parameters    ${delta_para_A_b_3_initial}
    # check SIB3/4/5
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
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 (interFreqCarrierFreqList contains (dl-CarrierFreq eq 1500))
    ...    alias=sib5br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib5br_flow

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

Get SIB5-BR Flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 as sib5_br
    ...    alias=sib5_br_flow_old  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_br_flow_old

Check No SIB5-BR update
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 as sib5_br
    ...    alias=sib5_br_flow_new  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_br_flow_new
    ${sib5_br_old}    Get Message    sib5_br_flow_old    sib5_br
    ${sib5_br_new}    Get Message    sib5_br_flow_new    sib5_br
    message should be same    ${sib5_br_old}    ${sib5_br_new}

Online commissioning to add a second MOC CATMIRFIM
    Get SIB5 Flow
    Delta Commission Parameters    LNCEL-1/CATMCEL-0/CATMIRFIM-2:dlCarFrqEut=1550
    # check SIB5-BR add one more item 1550 (old 1500)
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 (dl-CarrierFreq contains (1500, 1550)) as sib5_br
    ...    alias=sib5br_flow    overall_timeout=10
    Flow Occurred As Expected  alias=sib5br_flow
    verify that message fulfills query
    ...  (
    ...      interFreqCarrierFreqList contains (
    ...           (dl-CarrierFreq eq 1550) and
    ...           (q-RxLevMin eq -65) and
    ...           (t-ReselectionEUTRA eq 1) and
    ...           (p-Max eq -30) and
    ...           t-ReselectionEUTRA-SF contains ((sf-Medium eq 'oDot5') and (sf-High eq 'oDot5')) and
    ...           (threshX-High eq 5) and
    ...           (threshX-Low eq 3) and
    ...           (allowedMeasBandwidth eq 'mbw6') and
    ...           (presenceAntennaPort1 eq 'FALSE') and
    ...           (cellReselectionPriority eq 7) and
    ...           (neighCellConfig eq '0b00') and
    ...           interFreqNeighCellList contains ((physCellId eq 503) and (q-OffsetCell eq 'dB-24')) and
    ...           interFreqExcludedCellList contains ((start eq 0) and (range eq 'n4')) and
    ...           (q-QualMin-r9 eq -34) and
    ...           threshX-Q-r9 contains ((threshX-HighQ-r9 eq 0) and (threshX-LowQ-r9 eq 0))
    ...           )
    ...  )
    ...  message_alias=sib5_br
    ...  flow_alias=sib5br_flow
    Check No SIB5 update
    Both Wideband UE And CatM UE Are Still Active

Online commissioning to remove one new MOC CATMIRFIM
    Get SIB5 Flow
    @{delta_params}    Create List
    ...  LNCEL-1/CATMCEL-0:cellReSelPrioCatM=5
    ...  delete:LNCEL-1/CATMCEL-0/CATMIRFIM-1
    Delta Commission Parameters    ${delta_params}
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType3-BR-r13 (cellReselectionServingFreqInfo contains (cellReselectionPriority eq 5))
    ...    alias=sib3br_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib3br_flow
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5-BR-r13 (dl-CarrierFreq eq 1550)
    ...    alias=sib5br_flow    overall_timeout=10
    Flow Occurred As Expected    alias=sib5br_flow
    Check No SIB5 update
    Both Wideband UE And CatM UE Are Still Active

Online commissioning to add a second MOC IRFIM
    Get SIB5-BR Flow
    Delta Commission Parameters    LNCEL-1/IRFIM-2:dlCarFrqEut=21050
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType5 (interFreqCarrierFreqList contains ((dl-CarrierFreq eq 21000), (dl-CarrierFreq eq 21050)))
    ...    alias=sib5_flow  overall_timeout=10
    Flow Occurred As Expected    alias=sib5_flow
    Both Wideband UE And CatM UE Are Still Active
    Check No SIB5-BR update

CAT-M UE attach and start T-put
    Execute UEx Command    ue_attach id=2 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} cell=1
    Execute UEx Command    trf_data_start ue=2 kbps=20 dir=dl protocol=udp
    sleep    5

Wideband UE attach and start T-put
    Execute UEx Command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_WideBand} cell=1
    Execute UEx Command    trf_data_start ue=1 kbps=20 dir=dl protocol=udp
    sleep    5

Both Wideband UE And CatM UE Are Still Active
    ${ue1_info}  Execute UEx Command  get_ue_info id=1
    should be equal  ${ue1_info["state"]}  ACTIVE
    ${ue2_info}  Execute UEx Command  get_ue_info id=2
    should be equal  ${ue2_info["state"]}  ACTIVE
