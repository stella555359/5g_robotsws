*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    4G_TDD    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...                 release-SBTS23R4    team-CN3ET    owner-taotao.hu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCPR}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{CB007332}
...    @{Disable_CRL31168}
...    @{HO_para}

${SGNB_ADD_PREP_ATT_DL_BUFF}    LNCEL-1:M8080C164
${SGNB_ADD_COMPL_SUCC_DL_BUFF}    LNCEL-1:M8080C165
${SGNB_ADD_PREP_ATT_UL_BUFF}    LNCEL-1:M8080C166
${SGNB_ADD_COMPL_SUCC_UL_BUFF}    LNCEL-1:M8080C167

@{SGNB_ADD_PREP_DL_0_SGNB_ADD_SUCC_DL_0_SGNB_ADD_PREP_UL_4_SGNB_ADD_SUCC_UL_4}
...      ${SGNB_ADD_PREP_ATT_DL_BUFF}=0
...      ${SGNB_ADD_COMPL_SUCC_DL_BUFF}=0
...      ${SGNB_ADD_PREP_ATT_UL_BUFF}=4
...      ${SGNB_ADD_COMPL_SUCC_UL_BUFF}=4

@{SGNB_ADD_PREP_DL_3_SGNB_ADD_SUCC_DL_3_SGNB_ADD_PREP_UL_2_SGNB_ADD_SUCC_UL_2}
...      ${SGNB_ADD_PREP_ATT_DL_BUFF}=3
...      ${SGNB_ADD_COMPL_SUCC_DL_BUFF}=3
...      ${SGNB_ADD_PREP_ATT_UL_BUFF}=2
...      ${SGNB_ADD_COMPL_SUCC_UL_BUFF}=2

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=38100
...    LNCEL-3/LNCEL_TDD-0:earfcn=38000
...    LNCEL/LNCEL_TDD-0:chBw=10 MHz
...    LNCEL/LNCEL_TDD-0:maxNumActUE=300
...    LNCEL/LNCEL_TDD-0:measGapPattern=gap0
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    LNCEL:actFlowCtrlEnh=true
...    delete:LNBTS/CTRLTS-1
...    delete:LNBTS/CTRLTS-1/LTRACE-1
...    delete:LNBTS/CTRLTS-1/MTRACE-1
...    delete:LNCEL-1/MBSFNCEL-0

@{X2_MOCs}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.41    #gNB_id=7
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969    # SSBfrequency=531040 for GNB-7 cell-1
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=115970    # SSBfrequency=2036672 for GNB-7 cell-2
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2

@{NRDCPR}
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=531040
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=2036672
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=15kHz

@{NRDCDPR}
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=531040
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=2
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=2036672
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=258
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1

@{HO_para}
...    LNBTS-1:actHoWoSnChg=intraEnbAndX2HoEnabled
...    LNBTS-1:actSnChangeSnInit=true
...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNBTS-1:actIfHo=enabled              
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38100
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw50
...    LNCEL-2/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:removeAllowed=false
...    LNCEL-2/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-2/LNHOIF-2:measurementBandwidth=mbw50

@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNBTS:qciTab6:nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS:pdcpProf1001:pdcpProfileId=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms

@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_TDD-0:actAutoPucchAlloc=true

@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

@{CB007332}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/LNBTS_TDD-0:numRxWithHighNonGbrEnDc=1
...    LNCEL-1:ulEnDcConfigLevel=10

@{Disable_CRL31168}
...    LNBTS/NRMEASDPR-0:mrWaitTimer=${EMPTY}    #ms
...    LNBTS/NRMEASPR-0:mrWaitTimer=${EMPTY}    #ms

@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL:actScellConfigForHiDemand=true
...    LNBTS/LNBTS_TDD-0:numTxWithHighNonGbr=10
...    LNBTS:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL:maxNumScells=3
...    LNCEL-2:maxNumScells=3
...    LNCEL-3:maxNumScells=3
...    LNCEL:actCaArchEnhImp=off
...    LNCEL-2:actCaArchEnhImp=off
...    LNCEL-3:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL:dlScellConfigLevel=10
...    LNCEL/CAPR-1:earfcnDL=1500
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS:actFlexCaMgmt=true
...    LNCEL:scellFastSchedulingSelect=normal
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-3:scellFastSchedulingSelect=normal
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-3:dlCaMinPcellCqiQci1=0
...    LNCEL-3:dlCaMinPcellCqi=0

@{disable_CB007332}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1

@{enable_CB007332}
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased

${ue_nr_capabilities}    00000000010100200000600008080802C080380C000000
${ue_eutra_nr_capabilities}    0108040464A0089411287018003A0200000000200004020001008000402020040080801002
${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B98326929D3CB5F9D3A00000001D00000000E80000000740000000
...    3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000
...    00007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D
...    00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E2080400003
...    CA000072800000E10000084003A7400000003A00000001D00000000E800000007400000003A00000001D00000000E80000
...    0007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0
...    0000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    03A0000000141000000F3A00000000000000000000000000000000000000000000000000000000000202388425300C39FF
...    FFFFFFFFFFFFF42A0006008A5C000080000412C680203202F0000006000000240000840030040601C0

@{X2shouldup_gnb7}
...      LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '507000:531000', 
...    tdd_cell: yes, suggested_band: 7}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '2036667:2036667', 
...    tdd_cell: yes, suggested_band: 258}

${B1_activate_query}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq 531040,
    ...    carrierFreq-r15 eq 2036672
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${bear_setup_S1}    SEPARATOR=
    ...    E-RABToBeSetupItemBearerSUReq contains ((
    ...    e-RAB-ID eq 6) 
    ...    and e-RABlevelQoSParameters contains (
    ...    qCI eq 8))

${bear_setup_RRC}    SEPARATOR=
    ...    drb-ToAddModList contains ((
    ...    eps-BearerIdentity eq 6) 
    ...    and (drb-Identity eq 5))

${Intra_enb_inter_cell_ho}    SEPARATOR=
    ...    mobilityControlInfo contains (
    ...    targetPhysCellId eq 1 and (
    ...    carrierFreq contains (
    ...    dl-CarrierFreq eq 38000)))

*** Test Cases ***
CB007332-SR-A-B1_ET_01_01_UL data buffer based EN-DC setup without UL CA setup before
    [Tags]
    [Documentation]
    ...    precondition:
    ...    CB007332 configuration:
    ...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
    ...      LNBTS/LNBTS_TDD-0:numRxWithHighNonGbrEnDc=1, LNCEL-1:ulEnDcConfigLevel=10
    ...    Case step:
    ...    Step1: UE-1 ICS to Cell-1 and report valid B1, then start UL traffic over ENDC bearer(qci-6);
    ...    check: ENDC established successfully
    ...    Step2: UE-2 ICS to Cell-1 and report valid B1, then start UL traffic over ENDC bearer(qci-8);
    ...    check: ENDC established successfully
    ...    Step3: UE-2 endc tackback and report valid B1 again, then start UL traffic over ENDC bearer(qci-8);
    ...    check: ENDC established successfully again
    ...    Step4: UE-3 ICS to Cell-2 and intra enb inter cell ho to cell-1, report valid B1 again,
    ...           then report with B1 without neighber info due to report on leave, start UL traffic over qci-6;
    ...    check: No ENDC triggerred
    ...    Step5: UE-3 Report valid B1 again and start UL traffic over ENDC bearer(qci-6);
    ...    check: ENDC established successfully
    Delta Commission Parameters    ${enable_CB007332}
    Clear Counter files
    UE1 setup ENDC with non-GBR buffer over endc bearer
    UE2 setup ENDC with non-GBR buffer over non-endc bearer
    ENDC takeback due to 5G inactivityTimer expeired    ue_id=2
    UE setup ENDC with new recieved valid B1 report    ue_id=2    qci=8
    UE3 Ho to cell-1 and ENDC not triggered without stored valid B1 report
    UE setup ENDC with new recieved valid B1 report    ue_id=3    qci=6
    Check Counters    ${SGNB_ADD_PREP_DL_0_SGNB_ADD_SUCC_DL_0_SGNB_ADD_PREP_UL_4_SGNB_ADD_SUCC_UL_4}
    [Teardown]    case01_teardown

CB007332-SR-A-B1_ET_05_01_UL data buffer based EN-DC setup after ENDC dynamic trigger Method online change
    [Tags]
    [Documentation]
    ...    precondition:
    ...    CB007332 disabled:
    ...      LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased (LTE5003 enabled)
    ...      LNBTS/LNBTS_TDD-0:numRxWithHighNonGbrEnDc=1, LNCEL-1:ulEnDcConfigLevel=10
    ...    Case step:
    ...    Step1: UE-1 ICS to Cell-1 and report valid B1;
    ...    check: UE-1 B1 activation successfully
    ...    Step2: Enable CB007332 by delta commission;
    ...    check: delta commission successfully
    ...    Step3: UE-1 report valid B1 again and start UL traffic ;
    ...    check: No ENDC triggerred due to no UL overflow indication due to online change after B1 activation not effect
    ...    Step4: start DL traffic for UE-1;
    ...    check: UE-1 ENDC established successfully by DL overflow indication
    ...    Step5: UE-2 ICS to Cell-1 and report valid B1, then start UL traffic;
    ...    check: UE-2 ENDC established succesfully by UL overflow indication
    ...    Step6: UE-3 ICS to Cell-1 and report valid B1, then start DL traffic;
    ...    check: UE-3 ENDC established succesfully by DL overflow indication
    ...    Step7: UE-4 ICS to Cell-1 and disable CB007332 to LTE5003 after B1 activation, start UL traffic for UE-4;
    ...    check: UE-4 ENDC established succesfully by UL overflow indication due to online change after B1 activation not effect
    ...    Step8: UE-5 ICS to Cell-1 and report valid B1, then start UL traffic;
    ...    check: No ENDC triggerred due to no UL overflow indication
    ...    Step8: start UL traffic for UE-5;
    ...    check: UE-5 ENDC established succesfully by DL overflow indication
    [Setup]    case05_setup
    UE-1 UL ENDC not triggerred but DL ENDC established successfully after CB007332 enabled after B1 activation
    UE-2 UL ENDC established successfully with CB007332 enabled
    UE-3 DL ENDC established successfully with CB007332 enabled
    UE-4 UL ENDC established successfully after CB007332 disabled after B1 activation
    UE-5 UL ENDC not triggerred but DL ENDC established successfully with CB007332 disabled
    Check Counters    ${SGNB_ADD_PREP_DL_3_SGNB_ADD_SUCC_DL_3_SGNB_ADD_PREP_UL_2_SGNB_ADD_SUCC_UL_2}
    [Teardown]    case05_teardown

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=5    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    gNB    enb_id=7    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Set UE parameters for ENDC capability
    Config gnb

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Uex Command    ue_param id=1,2 dual_conn=eutra_nr pdcp_sn_extension=18bit
    Execute Uex Command    ue_param id=1,2 nr_supported_bands=7,8

Config gnb
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1

Perform Steps After Onair
    Configure LNADJGNB and LNRELGNBCELL
    X2 link should be available

Configure LNADJGNB and LNRELGNBCELL
    Delta Commission Parameters    ${X2_MOCs}

X2 link should be available
    Object Should Exist    params=${X2shouldup_gnb7}    timeout=300

Modify Yaml
    Update Yaml    UEs/bearer_sets/bearer_set_1/1     qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7     qci: 8
    Add Yaml    BASE_STATIONS
    ...      - id: 7
    ...        gnb_id: '0x00007'
    ...        type: simulated
    ...        plmn: '262:03'
    ...        s1u: 10.0.1.41
    ...        x2_peers: 1
    ...        cells:
    ...          - ${gnb7_cell1}
    ...          - ${gnb7_cell2}

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} 
    ...      ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

Start traffic for UE
    [Arguments]    ${ue_id}=1    ${dir}=dl    ${qci}=6    ${duration}=10    ${trf_id}=1
    ${cmd}    catenate
    ...    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 
    ...    ue=${ue_id} protocol=udp qci=${qci} duration=${duration} duration_unit=seconds
    Execute Uex Command    ${cmd}

Stop traffic for UE
    [Arguments]    ${ue_id}=1    ${trf_id}=1    ${qci}=6
    Execute Uex Command    trf_data_stop trf_id=${trf_id} ue=${ue_id} qci=${qci}

Report valid B1 report for special NRFCN
    [Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=2
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR

Report B1 wihtout neighber Info
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_measurement_send id=${ue_id} srsrp=79 event=B1_NR

UE attach to cell and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}
    Flow Occurred As Expected    alias=B1_activation

Check no UL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1
    Expect message will not occur
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    alias=ENDC_trigger    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=2
    Flow Not Occurred For message    alias=ENDC_trigger
    Stop traffic for UE    ue_id=${ue_id}    trf_id=2

Check UL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18))
    ...    alias=ENDC_setup    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=${trf_id}    qci=${qci}
    Flow Occurred As Expected    alias=ENDC_setup
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}    qci=${qci}

Check DL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18))
    ...    alias=ENDC_setup    overall_timeout=20
    Start traffic for UE    dir=dl    ue_id=${ue_id}    duration=20    trf_id=${trf_id}    qci=${qci}
    Flow Occurred As Expected    alias=ENDC_setup
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}

Add Non-Gbr bearer for QCI8
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    MME_1:S1AP_E-RABModificationIndication (${bear_setup_S1})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${bear_setup_RRC})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_setup    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=8
    Flow Not Occurred For message    alias=Bearer_setup

UE1 setup ENDC with non-GBR buffer over endc bearer
    UE attach to cell and check B1 activation    ue_id=1
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=1
    Check UL buffer based ENDC setup successfully    ue_id=1

UE2 setup ENDC with non-GBR buffer over non-endc bearer
    UE attach to cell and check B1 activation    ue_id=2
    Add Non-Gbr bearer for QCI8    ue_id=2
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=2
    Check UL buffer based ENDC setup successfully    ue_id=2    qci=8

UE3 Ho to cell-1 and ENDC not triggered without stored valid B1 report
    UE attach to cell    ue_id=3    cell_id=2
    Make UE ho to enb1 cell1    ue_id=3
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=3
    Report B1 wihtout neighber Info    ue_id=3
    Check no UL buffer based ENDC setup successfully    ue_id=3

UE setup ENDC with new recieved valid B1 report
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18))
    ...    alias=ENDC_setup    overall_timeout=20
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=${ue_id}
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=${trf_id}    qci=${qci}
    Flow Occurred As Expected    alias=ENDC_setup
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}    qci=${qci}

case05_setup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${disable_CB007332}
    Clear Counter files

case05_teardown
    UE detach    ue_id=1-5
    Common Test Teardown And Stop Capture Logs

case01_teardown
    UE detach    ue_id=1-3
    Common Test Teardown And Stop Capture Logs

UE ICS and report valid B1 report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${narfcn}=531040
    UE attach to cell and check B1 activation    ue_id=${ue_id}    cell_id=1
    Report valid B1 report for special NRFCN    narfcn=${narfcn}    pci=${pci}    ue_id=${ue_id}

UE-1 UL ENDC not triggerred but DL ENDC established successfully after CB007332 enabled after B1 activation
    UE ICS and report valid B1 report    ue_id=1    pci=2    narfcn=2036672
    Delta Commission Parameters    ${enable_CB007332}
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=1
    Check no UL buffer based ENDC setup successfully    ue_id=1
    Check DL buffer based ENDC setup successfully    ue_id=1

UE-2 UL ENDC established successfully with CB007332 enabled
    UE ICS and report valid B1 report    ue_id=2    pci=1    narfcn=531040
    Check UL buffer based ENDC setup successfully    ue_id=2

UE-3 DL ENDC established successfully with CB007332 enabled
    UE ICS and report valid B1 report    ue_id=3    pci=1    narfcn=531040
    Check DL buffer based ENDC setup successfully    ue_id=3

UE-4 UL ENDC established successfully after CB007332 disabled after B1 activation
    UE attach to cell    ue_id=4    cell_id=1
    Delta Commission Parameters    ${disable_CB007332}
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=4
    Check UL buffer based ENDC setup successfully    ue_id=4

UE-5 UL ENDC not triggerred but DL ENDC established successfully with CB007332 disabled
    UE ICS and report valid B1 report    ue_id=5    pci=1    narfcn=531040
    Check no UL buffer based ENDC setup successfully    ue_id=5
    Check DL buffer based ENDC setup successfully    ue_id=5

ENDC takeback due to 5G inactivityTimer expeired
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    gNB:X2AP_SgNBReleaseRequired
    ...    gNB:X2AP_SgNBReleaseConfirm
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (17,18))
    ...    alias=ENDC_tackback    overall_timeout=20
     Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}
    Flow Occurred As Expected    alias=ENDC_tackback

Make UE ho to enb1 cell1
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Intra_enb_inter_cell_ho})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=Inter_cell_ho_and_b1_activation    overall_timeout=20
    Execute Uex Command    ue_ho id=${ue_id} cell=1 enb=1
    Flow Occurred As Expected    alias=Inter_cell_ho_and_b1_activation
