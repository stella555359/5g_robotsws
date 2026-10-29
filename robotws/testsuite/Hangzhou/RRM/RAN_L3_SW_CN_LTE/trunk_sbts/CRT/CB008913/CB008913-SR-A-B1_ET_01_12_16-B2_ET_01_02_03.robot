*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS    CRT    
...               release-SBTS24R1    team-CN3ET    owner-taotao.hu
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

@{enable_LTE5003}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased

@{enabled_LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased

@{delta_for_B1_case1}
...    @{enabled_LTE4193}
...    LNBTS:numB1CyclesWoEndc=2
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    delete:LNBTS/CAGENB-0/CAIMLBP-1
...    delete:LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0
...    delete:LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering

@{delta_for_B1_case12}
...    @{enabled_LTE4193}
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
...    delete:LNBTS/CAGENB-0/CAIMLBP-1
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries

@{delta_for_B1_case16}
...    @{enable_LTE5003}
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=${flte4}
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo

@{delta_for_B2_case1}
...    @{enable_LTE5003}
...    LNBTS-1:actSelMobPrf=false
...    LNBTS:numB1CyclesWoEndc=2
...    LNCEL:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=8
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

@{delta_for_B2_case2}
...    LNCEL:actEndcHoPrefLay=true    #CB007163
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO    #CB008913
...    LNCEL-2:actNrCovEndcHo=disabled
...    LNCEL-3:actNrCovEndcHo=disabled
...    LNCEL-4:actNrCovEndcHo=disabled
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-3:defaultLnRelGnbCellId=0
...    LNCEL-4:defaultLnRelGnbCellId=1
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    delete:LNBTS/CAGENB-0/CAIMLBP-1
...    @{HO_para}
...    LNBTS/MODPR-0:freqLayListLte=${flte1},${flte2},${flte3},${flte4}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased    #CB007332
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased
...    LNBTS/LNBTS_FDD-0:numRxWithHighNonGbrEnDc=1
...    LNCEL-1:ulEnDcConfigLevel=10

@{delta_for_B2_case3}    #wuzijing
...    @{enable_LTE5003}
...    LNCEL:actEndcHoPrefLay=false
...    LNBTS:qciTab8:nrPdcpProfIdx=1001
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC
...    LNBTS:qciTab6:nrPdcpProfIdx=${EMPTY}
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS:numB1CyclesWoEndc=1
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    delete:LNCEL-3/LNRELGNBCELL-1
...    delete:LNCEL-3/LNRELGNBCELL-2
...    LNCEL:iFEndcHoRetryTimer=30
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=8
...    delete:LNBTS/CAGENB-0/CAIMLBP-1

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

${B1_reactive_for_Fnr1_Fnr2_Fnr3}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19)

${B1_deactive_for_all}    measIdToRemoveList contains (17, 18, 19)

${HO_successful}    SEPARATOR=
    ...    mobilityControlInfo contains ( 
    ...    targetPhysCellId eq 3
    ...    and carrierFreq contains ( 
    ...    dl-CarrierFreq eq ${flte3}))

${B1_deactive_and_A5_active}    SEPARATOR=
    ...    measIdToRemoveList contains (17, 18, 19)
    ...    and measIdToAddModList contains (measId eq 3)

*** Test Cases ***
CB008913-SR-A-B1_ET_01_01_When serving cell is anchor by coverage based ENDC trigger ENDC-HO A5
    [Tags]    hu.taotao
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    UE MRDC capability: {B3+N8,B3+N257,B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased (LTE4193)
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and activation B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: UE-1 report B1 at NR frequency Fnr2
    ...    Step3: wait B1 supervision timer expired
    ...    check: B1 deactive and no ENDC A5 activated
    ...    Step4: wait B1 retrytimer expired
    ...    check: B1 reactivated at Fnr1, FNr2, Fnr3
    ...    Step5: UE-1 report B1 at NR frequency Fnr2
    ...    step6: wait B1 supervision timer expired
    ...    check: B1 deactive and ENDC A5 activated at flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B1_case1}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1
    Report valid B1 report for special NRFCN    narfcn=${fnr2}    pci=2
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation
    Wait retryTimerB1NR expired and check B1 reactivation
    Report valid B1 report for special NRFCN    narfcn=${fnr2}    pci=2
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=1
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3}
    [Teardown]    case_teardown_with_UE_detach    ue_id=1

CB008913-SR-A-B1_ET_12_01_When SgNB takeback NR in-coverage ENDC-HO A5 is triggered
    [Tags]    gen.lishuo
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL/IMLBNR.nrcellConfigL.band=Flte3/8&77&257 and Flte4/8&257
    ...    UE MRDC capability: {B3+N8,B3+N257,B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased (LTE4193)
    ...    Case steps:
    ...    Step1: UE-2 ICS to Cell-1 and activation B1;
    ...    check: UE-2 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: UE-2 report B1 at NR frequency Fnr2
    ...    Step3: wait retryTimerB1NR expire, B1 reactivated
    ...    Step4: UE-2 report B1 at NR frequency Fnr1
    ...    check: ENDC setup successfully,B1 de-activated for UE-2
    ...    Step5: make ENDC takeback due to 5G inactivityTimer timeout
    ...    check: ENDC takeback successfully,UE-2 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step6: UE-2 report B1 at NR frequency Fnr2
    ...    step7: wait B1 supervision timer expired, no ENDC A5 activition
    ...    Step8: wait retryTimerB1NR expire, B1 reactivated
    ...    Step9: UE-2 report B1 at NR frequency Fnr2
    ...    step10: after supervisionTimerB1NR expire, ENDC A5 activated at flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B1_case12}
    UE attach to cell and check B1 activation    ue_id=2    cell_id=1
    Report valid B1 report for special NRFCN    ue_id=2    narfcn=${fnr2}    pci=2
    Wait retryTimerB1NR expired and check B1 reactivation    ue_id=2
    Check ENDC setup successfully with valid B1 report    ue_id=2
    ENDC takeback due to 5G inactivityTimer expeired    ue_id=2
    Report valid B1 report for special NRFCN    ue_id=2    narfcn=${fnr2}    pci=2
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=2
    Wait retryTimerB1NR expired and check B1 reactivation    ue_id=2
    Report valid B1 report for special NRFCN    ue_id=2    narfcn=${fnr2}    pci=2
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=2
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3}
    [Teardown]    case_teardown_with_UE_detach    ue_id=2

CB008913-SR-A-B1_ET_16_01_NR in-coverage ENDC-HO A5 list update due to report on leave with RRE UE
    [Tags]    wu.zijing
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL/IMLBNR.nrcellConfigL.band=Flte3/8&77&257 and Flte4/8&257
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased (LTE5003)
    ...    Case steps:
    ...    Step1: UE-3 reestablishment to serving cell-1
    ...    check: UE-3 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: start DL traffic for UE-3;
    ...    check: Wait retryTimerB1NR expired and check B1 reactivation
    ...    Step3: UE-3 report B1 for Fnr1,Fnr2,follow up with report B1 for Fnr1 without PCI
    ...    check: B1 deactive and ENDC A5 activated at flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B1_case16}
    UE attach to cell    ue_id=3    cell_id=2    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    UE reestablish to cell and check B1 activation    ue_id=3    cell_id=1
    Start DL traffic and check B1 reactivation    ue_id=3
    Report B1 for Fnr1Fnr2 and follow up with report B1 for Fnr1 without PCI and expected ENDC A5 activated    ue_id=3
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3}
    [Teardown]    case_teardown_with_UE_detach    ue_id=3

CB008913-SR-A-B2_ET_01_01_ENDC-HO A5 report and NR coverage-based EN-DC handover to anchor layer
    [Tags]    sun.chengmao
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased (LTE5003)
    ...    Case steps:
    ...    Step1: UE-4 ICS to Cell-1 and activation B1;
    ...    check: UE-4 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: wait B1 supervision timer expired
    ...    check: B1 deactive and no ENDC A5 activated
    ...    Step3: wait B1 retrytimer expired
    ...    check: B1 reactivated at Fnr1, FNr2, Fnr3
    ...    Step4: UE-4 report B1 at NR frequency Fnr2
    ...    step5: wait B1 supervision timer expired
    ...    check: B1 deactive and ENDC A5 activated at flte3
    ...    step6: UE-4 report A5 at flte3
    ...    check: UE-4 report A5 at flte3 and ENDC HO to cell3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B2_case1}
    UE attach to cell and check B1 activation    ue_id=4    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=4
    Wait retryTimerB1NR expired and check B1 reactivation    ue_id=4
    Report valid B1 report for special NRFCN    ue_id=4    narfcn=${fnr2}    pci=2
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=4
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3}
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=4
    [Teardown]    case_teardown_with_UE_detach    ue_id=4

CB008913-SR-A-B2_ET_02_01_ENDC-HO A5 report and NR coverage-based EN-DC handover to anchor layer with UL buffer based ENDC trigger
    [Tags]    zheng.qi
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL/IMLBNR.nrcellConfigL.band=Flte3/8&77&257
    ...    UE MRDC capability: {B3+N8,B3+N257,B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndDlUlBufferBased (CB007332)
    ...    Case steps:
    ...    Step1: UE-5 ICS to Cell-1;
    ...    check: UE-5 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: UE-5 start UL traffic
    ...    Step3: wait supervisionTimerB1NR, no B1 report
    ...    check: B1 deactivated
    ...    Step4: wait retryTimerB1NR expire
    ...    check: B1 reactivated with Fnr1, Fnr2, Fnr3
    ...    Step5: UE-5 report B1 with NR frequency Fnr2 pci2
    ...    Step6: wait supervisionTimerB1NR expire(UE-5 is out of coverage)
    ...    check: B1 deactive and ENDC A5 activated with flte3
    ...    Step7: UE-5 report A5 with flte3 pci3
    ...    check: UE-5 handover to Cell-3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B2_case2}
    UE attach to cell and check B1 activation    ue_id=5    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    Start traffic for UE for ul    ue_id=5
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation    ue_id=5
    Wait retryTimerB1NR expired and check B1 reactivation    ue_id=5
    Report valid B1 report for special NRFCN    ue_id=5    narfcn=${fnr2}    pci=2
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=5
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5_for_Flte3}
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=5
    [Teardown]    case_teardown_with_UE_detach    ue_id=5

CB008913-SR-A-B2_ET_03_01_ENDC-HO A5 MR ongoing and UE from CB008913 UE change to not enable CB008913 UE
    [Tags]    wu.zijing
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=1
    ...    freqLayEndcHoList.freqLayer={flte1, flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL/IMLBNR.nrcellConfigL.band=Flte3/8&77&257
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
    ...    Case steps:
    ...    Step1: UE-6 ICS to Cell-1 and add ENDC eligible bearer;
    ...    check: UE-6 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: UE-6 only report Fnr2 at B1-NR measure
    ...    check: ltecell1 deactive the B1-measure and active A5
    ...    Step3: ENDC eligible bearer is released from UE-6
    ...    Step4: wait for iFEndcHoRetryTimer expire,ltecell1 activates A5 about Flte3
    ...    Step5: UE-6 report A5 with flte3 pci3
    ...    check: UE-6 handover to Cell-3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B2_case3}
    UE attach to cell and add ENDC eligible bearer and check B1 activation    ue_id=6    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    UE report B1 and expect B1_deactive and A5_active    ue_id=6
    UE relese bear    ue_id=6    qci=8
    Wait iFEndcHoRetryTimer expired and check A5 reactivation    ue_id=6
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=6
    [Teardown]    case_teardown_with_UE_detach    ue_id=6


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

case_teardown_with_UE_detach
    [Arguments]    ${ue_id}
    UE detach    ue_id=${ue_id}
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

Wait retryTimerB1NR expired and check B1 reactivation
    [Arguments]    ${ue_id}=1    ${timerout}=32    ${B1_reactive}=${B1_reactive_for_Fnr1_Fnr2_Fnr3}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_reactive})
    ...    alias=B1_reactive    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=B1_reactive

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

Check ENDC setup successfully with valid B1 report
    [Arguments]    ${ue_id}=1    ${pci}=1    ${nrfcn}=${fnr1}
    Expect message flow
    ...    gNB:X2AP_SgNBAdditionRequest
    ...    gNB:X2AP_SgNBAdditionRequestAcknowledge
    ...    gNB:X2AP_SgNBReconfigurationComplete
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18,19))
    ...    alias=ENDC_setup    overall_timeout=20
    Report valid B1 report for special NRFCN    narfcn=${nrfcn}    pci=${pci}    ue_id=${ue_id}
    Flow Occurred As Expected    alias=ENDC_setup
    
ENDC takeback due to 5G inactivityTimer expeired
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    gNB:X2AP_SgNBReleaseRequired
    ...    gNB:X2AP_SgNBReleaseConfirm
    ...    gNB:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (17,18,19))
    ...    alias=ENDC_takeback    overall_timeout=20
    Execute Egate Command    enb_ue_dc_release by=gnb cause=RN_user_inactivity ue=${ue_id}    UEContextRelease
    Flow Occurred As Expected    alias=ENDC_takeback

UE reestablish to cell and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=30
    Execute Uex Command    ue_rrc_reestablish id=${ue_id} enb=1 cell=${cell_id}
    Flow Occurred As Expected    alias=B1_activation

Start DL traffic and check B1 reactivation
    [Arguments]    ${ue_id}=1
    Execute Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=${ue_id} protocol=udp qci=6
    Wait retryTimerB1NR expired and check B1 reactivation    ue_id=${ue_id}

Report B1 for Fnr1Fnr2 and follow up with report B1 for Fnr1 without PCI and expected ENDC A5 activated
    [Arguments]    ${ue_id}=1    ${ENDC_A5_active_and_B1_deactive}=${ENDC_A5_for_Flte3}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_active_and_B1_deactive})
    ...    alias=A5_active    overall_timeout=32
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${fnr1} srsrp=79 phycell_id=1 nrsrp=58 event=B1_NR
    Execute Uex Command    ue_measurement_send id=${ue_id} narfcn=${fnr2} srsrp=79 phycell_id=2 nrsrp=58 event=B1_NR
    Execute Uex Command    ue_measurement_send id=${ue_id} meas_id_blacklist=18 srsrp=79 event=B1_NR
    Flow Occurred As Expected    alias=A5_active

Report valid ENDC_HO A5 for special EARFCN and check HO successful
    [Arguments]    ${ue_id}=1    ${earfcn}=${flte3}    ${pci}=3    ${timerout}=20
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${HO_successful})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=HO_successful    overall_timeout=${timerout}
    Execute Uex Command    ue_measurement_send id=${ue_id} earfcn=${earfcn} srsrp=79 phycell_id=${pci} nrsrp=58 nrsrq=26 event=A5
    Flow Occurred As Expected    alias=HO_successful

Start traffic for UE for ul
    [Arguments]    ${ue_id}=1    ${dir}=dl    ${qci}=6    ${duration}=60    ${trf_id}=1
    Execute Uex Command    trf_data_start ue=${ue_id} dir=ul protocol=udp Mbps=150 qci=${qci} duration=${duration} duration_unit=seconds

UE attach to cell and add ENDC eligible bearer and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${mrdc_capa}
    ...      ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    Execute Uex Command    ${V_1}
    Execute Uex Command    bearer_add ue=${ue_id} qci=8
    Flow Occurred As Expected    alias=B1_activation

UE report B1 and expect B1_deactive and A5_active
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive_and_A5_active})
    ...    alias=A5_activation    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr2}    pci=3
    Flow Occurred As Expected    alias=A5_activation

UE relese bear
    [Arguments]    ${ue_id}=1    ${qci}=8
    Execute Uex Command    bearer_del ue=${ue_id} qci=${qci}

Wait iFEndcHoRetryTimer expired and check A5 reactivation
    [Arguments]    ${ue_id}=1    ${timerout}=32    ${A5_reactive}=measIdToAddModList contains (measId eq 3)
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${A5_reactive})
    ...    alias=ENDC_A5_activate    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=ENDC_A5_activate