*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
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
...    @{UL_CA}
...    @{CB007332}
...    @{Disable_CRL31168}

${SGNB_ADD_PREP_ATT_DL_BUFF}    LNCEL-1:M8080C164
${SGNB_ADD_COMPL_SUCC_DL_BUFF}    LNCEL-1:M8080C165
${SGNB_ADD_PREP_ATT_UL_BUFF}    LNCEL-1:M8080C166
${SGNB_ADD_COMPL_SUCC_UL_BUFF}    LNCEL-1:M8080C167

@{SGNB_ADD_PREP_DL_0_SGNB_ADD_SUCC_DL_0_SGNB_ADD_PREP_UL_2_SGNB_ADD_SUCC_UL_2}
...      ${SGNB_ADD_PREP_ATT_DL_BUFF}=0
...      ${SGNB_ADD_COMPL_SUCC_DL_BUFF}=0
...      ${SGNB_ADD_PREP_ATT_UL_BUFF}=2
...      ${SGNB_ADD_COMPL_SUCC_UL_BUFF}=2

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL/LNCEL_FDD-0:ulChBw=10 MHz
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

@{UL_CA}
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS:actULCAggr=false
...    LNBTS:actULCaForEnDc=disabled    #enable LTE5711
...    LNBTS:actUlTraffDrivUlCa=false    #enable LTE4050
...    LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=1
...    LNCEL:ulScellConfigLevel=20
...    LNBTS:dlCaPreferred=DLandUL
...    LNBTS:enableBwCombCheck=false

@{enable_UL_CA_and_UL_CA_before_UL_ENDC}
...    LNBTS:actULCAggr=UL_CA_with_smartSched
...    LNBTS:actULCaForEnDc=nonConcurrentULCaAndEnDc    #enable LTE5711
...    LNBTS:actUlTraffDrivUlCa=true    #enable LTE4050
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=200    #CB007332
...    LNCEL-1:ulEnDcConfigLevel=50
...    LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=1    #LTE4050
...    LNCEL:ulScellConfigLevel=1

@{disable_UL_CA}
...    LNBTS:actULCAggr=false
...    LNBTS:actULCaForEnDc=disabled    #enable LTE5711
...    LNBTS:actUlTraffDrivUlCa=false    #enable LTE4050

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
...    LNCEL/LNRELGNBCELL-2:nrCellId=115970    # SSBfrequency=188512 for GNB-7 cell-2
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
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=188512
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=8
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=188512
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=8
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
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true

@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

@{Disable_CRL31168}
...    LNBTS/NRMEASDPR-0:mrWaitTimer=${EMPTY}    #ms
...    LNBTS/NRMEASPR-0:mrWaitTimer=${EMPTY}    #ms

@{CB007332}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1
...    LNCEL-1:ulEnDcConfigLevel=10

@{fast_UL_endc_and_enable_CRL31168}
...    LNBTS/CAGENB-0:maxDlCaConfigForUlCa=max_3CC_DL_CA
...    LNBTS:actULCAggr=false
...    LNBTS:actULCaForEnDc=disabled    #enable LTE5711
...    LNBTS:actUlTraffDrivUlCa=false    #enable LTE4050
...    LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=1
...    LNCEL:ulScellConfigLevel=1
...    LNBTS:dlCaPreferred=DLandUL
...    LNBTS:enableBwCombCheck=false
...    @{CRL31168}

@{CRL31168}
...    LNBTS/NRMEASDPR-0:mrWaitTimer=2000    #ms
...    LNBTS/NRMEASPR-0:mrWaitTimer=2000    #ms

${ue_nr_capabilities}    00000000010100200000600000380802C080380C000000
${ue_eutra_nr_capabilities}    01080404604008081010701800380E00000000200004020001008000402020040080801002

${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E80000000740000000
...    3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000
...    00007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D
...    00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A0E2080400003
...    84000061000000E10000084003A7400000003A00000001D00000000E800000007400000003A00000001D00000000E80000
...    0007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0
...    0000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    03A0000000141000000F3A00000000000000000000000000000000000000000000000000000000000202388425300C39FF
...    FFFFFFFFFFFFF42A0006008A5C000080000412C68020300EF0000006000000240000840030040601C0

@{CA}
...    LNBTS:actDLCAggr=true
...    LNBTS:actAdvScellMeas=true
...    LNBTS:enableBwCombCheck=true
...    LNBTS:actFlexScellSelect=true
...    LNCEL:actScellConfigForHiDemand=true
...    LNBTS/LNBTS_FDD-0:numTxWithHighNonGbr=10
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

@{X2shouldup_gnb7}
...      LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '507000:531000', 
...    tdd_cell: yes, suggested_band: 7}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '179500:188500', 
...    tdd_cell: yes, suggested_band: 8}

${B1_activate_query}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq 531040,
    ...    carrierFreq-r15 eq 188512
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${UL_scell_configuration}    SEPARATOR=
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 
    ...    and ul-Configuration-r10 contains (
    ...    ul-CarrierFreq-r10 eq 19500
    ...    ))

${B1_deactivate_and_UL_scell_release}    SEPARATOR=
    ...    measIdToRemoveList contains (
    ...    17,
    ...    18) 
    ...    and sCellToReleaseList-r10 contains (
    ...    1) 
    ...    and sCellToAddModList-r10 contains (
    ...    radioResourceConfigCommonSCell-r10 contains (
    ...    nonUL-Configuration-r10 is present)) 
    ...    and ul-CarrierFreq-r10 is not present

*** Test Cases ***
CB007332-SR-A-B2_ET_01_01_UL data buffer based EN-DC setup with UL CA setup before
    [Tags]    TC21    CA_LABEL-FF (10MHz_FDD_b3+ 10MHz_FDD_b3*)
    [Documentation]
    ...    precondition:
    ...    CB007332 configuration:
    ...      LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=200, LNCEL-1:ulEnDcConfigLevel=50
    ...    LTE4050 configuration
    ...      LNBTS-1/LNBTS_FDD-0:numRxWithHighNonGbr=1
    ...      LNCEL:ulScellConfigLevel=1
    ...    Case step:
    ...    Step1: UE-1 ICS to Cell-1 and report valid B1 with incorrect PCI, then start UL traffic till UL overflow indication for UL CA firstly;
    ...    check: UL scell addition successfully
    ...    Step2: UL traffic countinue and UL overflow indication for UL ENDC;
    ...    check: ENDC establish successfully and together with UL scell configuration release
    ...    Step3: UE-2 ICS to Cell-1 and report valid B1, and report B1 with reportonleave
    ...    then start UL traffic till UL overflow indication for UL CA firstly;
    ...    check: UL scell addition successfully
    ...    Step4: UL traffic countinue and UL overflow indication for UL ENDC;
    ...    check: no ENDC establish due to not valid B1
    ...    Step5: UE-2 report valid B1 again and start UL traffic till UL overflow indication for ENDC;
    ...    check: ENDC establish successfully and together with UL scell configuration release
    [Setup]    case21_setup
    Clear Counter files
    UE1 UL scell addition with UL buffer and UL ENDC setup together with UL scell release
    UE2 UL scell addition with Ul buffer and No UL endc setup due to no valid B1 report stored
    UE2 UL ENDC setup together with UL scell release with valid B1 report
    Check Counters    ${SGNB_ADD_PREP_DL_0_SGNB_ADD_SUCC_DL_0_SGNB_ADD_PREP_UL_2_SGNB_ADD_SUCC_UL_2}
    [Teardown]    case21_teardown

CB007332-SR-A-B3_ET_01_01_UL data buffer based EN-DC setup interworking with CRL31168
    [Documentation]
    ...    precondition:
    ...    CB007332 configuration:
    ...      LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1, LNCEL-1:ulEnDcConfigLevel=1
    ...    Case step:
    ...    Step1: UE-1 ICS to Cell-1 and report valid B1 with low priority
    ...    check: mrwaittimer start(only check in syslog "starting mrWaitTimer")
    ...    Step2: start UL traffic and UL overflow indication for UL ENDC;
    ...    check: ENDC establish successfully with gnb-7 cell-2 (low priority B1)
    ...    Step3: UE-2 ICS to Cell-1 and report valid B1 with low priority
    ...    check: mrwaittimer start(only check in syslog "starting mrWaitTimer")
    ...    Step4: UE-2 ICS to Cell-1 and report valid B1 with high priority and start UL traffic for UE-2
    ...    check: ENDC establish successfully with gnb-7 cell-1 (high priority B1)
    [Tags]    TC31
    Delta Commission Parameters    ${fast_UL_endc_and_enable_CRL31168}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1
    Report valid B1 report for special NRFCN    narfcn=188512    pci=2    ue_id=1
    Check UL buffer based ENDC setup successfully with low priority B1    ue_id=1
    UE attach to cell and check B1 activation    ue_id=2    cell_id=1
    Report valid B1 report for special NRFCN    narfcn=188512    pci=2    ue_id=2
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=2
    Check UL buffer based ENDC setup successfully with high priority B1    ue_id=2
    [Teardown]    case31_teardown
*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD    ue_count=100
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
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

case21_setup
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${enable_UL_CA_and_UL_CA_before_UL_ENDC}

case21_teardown
    UE detach    ue_id=1-2
    Delta Commission Parameters    ${disable_UL_CA}
    Common Test Teardown And Stop Capture Logs

case31_teardown
    UE detach    ue_id=1-2
    Delta Commission Parameters    ${Disable_CRL31168}
    Common Test Teardown And Stop Capture Logs

Start traffic for UE
    [Arguments]    ${ue_id}=1    ${dir}=dl    ${qci}=6    ${duration}=10    ${trf_id}=1
    ${cmd}    catenate
    ...    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 
    ...    ue=${ue_id} protocol=udp qci=${qci} duration=${duration} duration_unit=seconds
    Execute Uex Command    ${cmd}

Stop traffic for UE
    [Arguments]    ${ue_id}=1    ${trf_id}=1
    Execute Uex Command    trf_data_stop trf_id=${trf_id} ue=${ue_id}

Report valid B1 report for special NRFCN
    [Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=2
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR

Report B1 wihtout neighber Info
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_measurement_send id=${ue_id} srsrp=79 event=B1_NR

UE attach to cell and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_query})
    ...    alias=B1_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}
    Flow Occurred As Expected    alias=B1_activation

Check buffer based UL scell addition successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UL_scell_configuration})
    ...    alias=UL_scell_addition    overall_timeout=20
    Expect message will not occur
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    alias=ENDC_trigger    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=10
    Flow Occurred As Expected    alias=UL_scell_addition
    Flow Not Occurred For message    alias=ENDC_trigger

Check UL buffer based ENDC setup successfully and UL scell release
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactivate_and_UL_scell_release})
    ...    alias=ENDC_setup    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=${trf_id}
    Flow Occurred As Expected    alias=ENDC_setup
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}

Check no UL buffer based ENDC setup successfully
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1
    Expect message will not occur
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    alias=ENDC_trigger    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=2
    Flow Not Occurred For message    alias=ENDC_trigger
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}

UE1 UL scell addition with UL buffer and UL ENDC setup together with UL scell release
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1
    Report valid B1 report for special NRFCN    narfcn=531040    pci=2    ue_id=1
    Check buffer based UL scell addition successfully    ue_id=1
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=1
    Check UL buffer based ENDC setup successfully and UL scell release    ue_id=1    trf_id=2

UE2 UL scell addition with Ul buffer and No UL endc setup due to no valid B1 report stored
    UE attach to cell and check B1 activation    ue_id=2    cell_id=1
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=2
    Report B1 wihtout neighber Info    ue_id=2
    Check buffer based UL scell addition successfully    ue_id=2
    Check no UL buffer based ENDC setup successfully    ue_id=2    trf_id=2

UE2 UL ENDC setup together with UL scell release with valid B1 report
    Report valid B1 report for special NRFCN    narfcn=531040    pci=1    ue_id=2
    Check UL buffer based ENDC setup successfully and UL scell release    ue_id=2    trf_id=3

Check UL buffer based ENDC setup successfully with low priority B1
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest (candidateCellInfoListMN contains (ssbFrequency eq 188512))
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18))
    ...    alias=ENDC_setup    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=${trf_id}    qci=${qci}
    Flow Occurred As Expected    alias=ENDC_setup
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}

Check UL buffer based ENDC setup successfully with high priority B1
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${trf_id}=1    ${qci}=6
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest (candidateCellInfoListMN contains (ssbFrequency eq 531040))
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18))
    ...    alias=ENDC_setup    overall_timeout=20
    Start traffic for UE    dir=ul    ue_id=${ue_id}    duration=20    trf_id=${trf_id}    qci=${qci}
    Flow Occurred As Expected    alias=ENDC_setup
    Stop traffic for UE    ue_id=${ue_id}    trf_id=${trf_id}