*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...                 release-SBTS24R1    team-CN3ET    owner-taotao.hu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}    LNBTS:reportTimerEndcA5=5000ms
@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCPR}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{Disable_CRL31168}
...    @{ENDC_HO}
...    @{CB008218}
...    @{CB008913}
...    @{HO_para}
...    @{X2_MOCs}

${flte1}    1400    #band3
${flte2}    1600    #band3
${flte3}    2870    #band7
${flte4}    3100    #band7

${fnr1}    188512    #nr band 8
${fnr2}    650048    #nr band 77
${fnr3}    2079200    #nr band 257

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400    #band3
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600    #band3
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=2870    #band7
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=20870
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=3100    #band7
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=21100
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

@{ENDC_HO}
...    LNBTS:actEndcHo=enabled    #LTE5150
...    LNBTS:actUeCapEndcHo=true    #CB006607
...    LNCEL:actEndcHoPrefLay=false    #CB007163
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${flte2}
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=${flte3}
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-1/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=${flte1}
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    @{freqLayEndcHoList_for_MOPR}
...    @{freqLayEndcHoList_for_MODPR}
...    @{add_moPrMapList}

@{CB008913}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS:blockNrEndcHoAtHoFromTrg=no blocking
...    LNBTS:numB1CyclesWoEndc=2
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only

@{freqLayEndcHoList_for_MODPR}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte4}

@{freqLayEndcHoList_for_MOPR}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}

@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1

@{X2_MOCs}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.41    #gNB_id=7
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969    # SSBfrequency=188512 for GNB-7 cell-1
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=115970    # SSBfrequency=650048 for GNB-7 cell-2
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2

...    LNCEL/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-3:nrCellId=115971    # SSBfrequency=2079200 for GNB-7 cell-3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2

@{NRDCPR}
...    LNBTS/NRMEASPR-0:cellList=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:quantityConfigId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:carrierFreqNrCell=${fnr1}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=${fnr2}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:carrierFreqNrCell=${fnr3}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:ssbSubcarrierSpacing=30kHz

@{NRDCDPR}
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${fnr1}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=8
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:nrCarPrio=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${fnr2}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=30kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${fnr3}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrq=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=30kHz

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
...    LNCEL/CAPR-1:earfcnDL=1600
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
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
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

@{CB008218}
...    LNCEL-1:actPeriodicB1NRMeas=enhanced
...    LNBTS/NRMEASDPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASDPR-0:retryTimerB1NR=30    #s
...    LNBTS/NRMEASPR-0:retryTimerB1NR=30    #s

@{HO_para}
...    LNBTS-1:actIfHo=enabled
...    LNBTS/MOPR-1:freqLayListLte=${flte1},${flte2},${flte3},${flte4}
...    LNBTS/MODPR-0:freqLayListLte=${flte1},${flte2},${flte3},${flte4}

@{enabled_LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased

${disable_8909}    LNCEL-1:actServBasedHoQciX=false

@{CB008909}
...    LNCEL-1:actServBasedHoQciX=true
...    LNBTS:reportTimerSBHoQciXA5=5000ms
...    LNBTS:qciTab2:servBasedHoAllowed=forbidden
...    LNBTS:qciTab3:servBasedHoAllowed=forbidden
...    LNBTS:qciTab4:servBasedHoAllowed=forbidden
...    LNBTS:qciTab5:servBasedHoAllowed=forbidden
...    LNBTS:qciTab6:servBasedHoAllowed=forbidden
...    LNBTS:qciTab7:servBasedHoAllowed=forbidden
...    LNBTS:qciTab8:servBasedHoAllowed=allowed
...    LNBTS:qciTab9:servBasedHoAllowed=forbidden
...    LNBTS:qciTab65:servBasedHoAllowed=forbidden
...    LNBTS:qciTab66:servBasedHoAllowed=forbidden
...    LNBTS:qciTab67:servBasedHoAllowed=forbidden
...    LNBTS:qciTab69:servBasedHoAllowed=forbidden
...    LNBTS:qciTab70:servBasedHoAllowed=forbidden
...    LNBTS:qciTabOperator:servBasedHoAllowed=forbidden
...    LNCEL-1/LNHOIF-1:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-1:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-2:thresholdRsrqSBHoQciXFilter=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpSBHoQciXFilter=-98
...    LNCEL-1/LNHOIF-3:thresholdRsrqSBHoQciXFilter=-120
...    LNBTS/MOPR-1:freqLayListServBasedHoQciX=${flte2}
...    LNBTS/MODPR-0:freqLayListServBasedHoQciX=${flte2}

@{delta_for_B3_case6}
...    @{CB008909}
...    @{enabled_LTE4193}
...    LNBTS:numB1CyclesWoEndc=2
...    LNBTS:actEndcHo=enabled    #LTE5150
...    LNBTS:actUeCapEndcHo=true    #CB006607
...    LNCEL-1:actEndcHoPrefLay=false    #CB007163
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=allow LB retry
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=allow LB retry
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    delete:LNBTS/CAGENB-0/CAIMLBP-1
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering

@{delta_for_case_B3_07}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS:numB1CyclesWoEndc=1
...    LNBTS:blockNrEndcHoAtHoFromTrg=EN-DC NR-coverage HO
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=8

...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=${flte4}
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-2:nrcellConfigL:band=77

...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte4}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte3}
...    @{1942}

@{1942}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/LNBTS_FDD-0:actDedVoLteInterFreqHo=true
...    LNBTS-1/LNBTS_FDD-0:actConvVoice=true
...    LNBTS-1/MOPR-1:freqLayListDedVoLteHo=${flte3}

${ue_eutra_capabilities}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001
...    D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000
...    001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00
...    000001D00000001BFBFFEDA00E00886429CC20070D9000000005EE800000020254A8389D0100000E10000084000B0800004200210000
...    43000088000114000230000470000900001240002500004B000098000134000280000510000A400014C0002A0000550000AC00015C00
...    02C0000590000B400016C0002E80005E0000DA0001FC0074E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A
...    00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074000000
...    0282000001E740000000000000000000000000000000000000000000000000000000000040471084A681873FFFFFFFFFFFFFFE8082A0
...    006008A5C000080000412C68062600E8004EF0000006000000240000860030080601D00000

${ue_nr_capabilities}    00000000010100400004C0000038000400040160401C06000000
${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}    0108080260C01C07000E260000000098100701C003A000000000010000402020040080801002
${ue_eutra_nr_capabilities_b7+n8_b7+n77}    0108040260C01C07000E2600000000040001008080100202004008

@{X2shouldup_gnb7}
...      LNBTS-1/LNADJGNB-1:x2ToGnbLinkStatus=available

${gnb7_cell1}    SEPARATOR=
...    {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '179500:188500', 
...    suggested_band: 8}

${gnb7_cell2}    SEPARATOR=
...    {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x502', nr_arfcn: '650000:650000', 
...    suggested_band: 77}

${gnb7_cell3}    SEPARATOR=
...    {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x503', nr_arfcn: '2079166:2079166', 
...    suggested_band: 257}

${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19
    ...    )
    ...    and measObjectToAddModList contains (
    ...    carrierFreq-r15 eq ${fnr1},
    ...    carrierFreq-r15 eq ${fnr2},
    ...    carrierFreq-r15 eq ${fnr3}
    ...    )
    ...    and reportConfigToAddModList contains (
    ...    eventB1-NR-r15 contains (
    ...    reportOnLeave-r15 eq "TRUE"
    ...    ))

${ENDC_A5_for_Flte3}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq ${flte3})
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97) 
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)
    ...    and measIdToRemoveList contains (17, 18, 19)

${ENDC_A5_for_Flte4}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq ${flte4})


${qcix_A5_for_Flte2}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1600)
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97) 
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)
    ...    and drb-ToAddModList contains ((
    ...    eps-BearerIdentity eq 6) 
    ...    and (drb-Identity eq 5))

${ENDC_A5_for_Flte3_wo_reportconfig}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq ${flte3})
    ...    and measIdToAddModList contains (
    ...    measId eq 3)
    ...    and measIdToRemoveList contains (17, 18, 19)

${Bearer_delete_and_B1_reactivation}    SEPARATOR=
    ...    drb-ToReleaseList contains (5) 
    ...    and measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19)

${B1_deactive_for_all}    measIdToRemoveList contains (17, 18, 19)

*** Test Cases ***
CB008913-SR-A-B3_ET_06_01_ENDC-HO A5 not started upon NR in-coverage trigger with CB008909
    [Tags]    TC36    Hu Taotao
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased (LTE4193)
    ...    CB008909 enabled and LNBTS:qciTab8:servBasedHoAllowed=allowed
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and activation B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: UE-1 report B1 at NR frequency Fnr2
    ...    Step3: add QCI-8 bearer for UE
    ...    check: bearer add successfully and QCIx A5 activated for frequency flte2
    ...    Step4: wait B1 supervision timer expired
    ...    check: B1 deactive and no ENDC A5 activated when QCIX A5 activated
    ...    step5: release QCI-8 bearer and B1 reactivated
    ...    step6: UE-1 report B1 at NR frequency Fnr2
    ...    step7: B1 supervision expired and endc A5 activation for flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B3_case6}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    QCIX A5 activated with QCI-8 bearer addition and no endc A5 activated
    ServBasedHoAllowed QCI-8 bearer delete and ENDC A5 configured with valid B1 report
    [Teardown]    case teardown and recover env    ue_id=1    delta_params=${disable_8909}

CB008913-SR-A-B3_ET_07_01_CB008913 target list is filtered by VOLTE dedicated frequency layer list
    [Tags]    TC307
    [Documentation]    CB008913 derives the target carrier list for NR coverage-based ENDC-HO from CB006607 target list,
    ...    i.e. reusing interaction with LTE1942. With LTE1942 enabled and QCI1 present in UE bearer set,
    ...    the NR coverage-based ENDC-HO target list comprise of anchor carriers, from intersection of freqLayEndcHoList
    ...    and freqLayListDedVoLteHo, which "EN-DC NR coverage" is confirmed by earlier completed B1-NR measurements.
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=1
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"&"flte4"
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LTE1942 enabled and LNBTS-1/MOPR-1:freqLayListDedVoLteHo=${flte3} 
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and activation B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: add QCI-1 bearer for UE
    ...    Step3: UE-1 report B1 and wait B1 supervision timer expired
    ...    check: ENDC A5 activated for flte3 and no ENDC A5 activated for flte4, since flte4 is filtered by LTE1942 list
    Delta Commission Parameters    ${delta_for_case_B3_07}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}    
    Add QCI-1 bearer for UE
    Report valid B1 report for special NRFCN    ue_id=1    narfcn=${fnr1}    pci=1
    wait B1 supervision timer expired and expected ENDC A5 for Flte3 activated and no ENDC A5 for Flte4

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Creat alias
    Set UE parameters for ENDC capability
    Config gnb

Creat alias
    Create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Create MME alias    MME_1    mme_id=1    id_type=wts

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_mme_param id=1-10 spid=2
    Execute Uex Command    ue_param id=1-20 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=77,8,257

Config gnb
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=2:1

Perform Steps After Onair
    X2 link should be available

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
    ...          - ${gnb7_cell3}

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${mrdc_capa} 
    ...      ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}

case_setup_with_delta_commission
    [Arguments]    ${delta_params}
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${delta_params}

case teardown and recover env
    [Arguments]    ${ue_id}    ${delta_params}
    UE detach    ue_id=${ue_id}
    Delta Commission Parameters    ${delta_params}
    Common Test Teardown And Stop Capture Logs

Report valid B1 report for special NRFCN
    [Arguments]    ${ue_id}=1    ${narfcn}=531040    ${pci}=2
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${narfcn} srsrp=79 phycell_id=${pci} nrsrp=58 event=B1_NR

UE attach to cell and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}    mrdc_capa=${mrdc_capa}
    Flow Occurred As Expected    alias=B1_activation

wait B1 supervision timer expired and expected ENDC A5 activated
    [Arguments]    ${ue_id}    ${ENDC_A5_active_and_B1_deactive}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_active_and_B1_deactive})
    ...    alias=ENDC_A5_activate    overall_timeout=20
    Flow Occurred As Expected    alias=ENDC_A5_activate


Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation
    [Arguments]    ${ue_id}=1    ${timerout}=20    ${B1_deactive}=${B1_deactive_for_all}    ${endc_A5_activate}=${ENDC_A5_for_Flte3}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive})
    ...    alias=B1_deactive    overall_timeout=${timerout}
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${endc_A5_activate})
    ...    alias=NO_ENDC_A5    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=B1_deactive
    Flow Not Occurred For message    alias=NO_ENDC_A5

Add specific QCIx for UE
    [Arguments]    ${ue_id}=1    ${qci}=8
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${qcix_A5_for_Flte2})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_addition    overall_timeout=20
    Execute Uex Command    bearer_add ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=Bearer_addition

Release specific bearer for UE and B1 reactivation
    [Arguments]    ${ue_id}=1    ${qci}=8
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${Bearer_delete_and_B1_reactivation})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=Bearer_delete    overall_timeout=20
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}
    Flow Occurred As Expected    alias=Bearer_delete

QCIX A5 activated with QCI-8 bearer addition and no endc A5 activated
    Report valid B1 report for special NRFCN    ue_id=1    narfcn=${fnr2}    pci=2
    Add specific QCIx for UE    ue_id=1    qci=8
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=1

ServBasedHoAllowed QCI-8 bearer delete and ENDC A5 configured with valid B1 report
    Release specific bearer for UE and B1 reactivation    ue_id=1    qci=8
    Report valid B1 report for special NRFCN    ue_id=1    narfcn=${fnr2}    pci=2
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=1
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3_wo_reportconfig}
	
Add QCI-1 bearer for UE
    [Arguments]    ${ue_id}=1
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
	
wait B1 supervision timer expired and expected ENDC A5 for Flte3 activated and no ENDC A5 for Flte4
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_for_Flte3})
    ...    alias=ENDC_A5_activate_flte3    overall_timeout=20	
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_for_Flte4})
    ...    alias=no_ENDC_A5_trigger_flte4    overall_timeout=20
    Flow Occurred As Expected    alias=ENDC_A5_activate_flte3
    Flow Not Occurred For message    alias=no_ENDC_A5_trigger_flte4