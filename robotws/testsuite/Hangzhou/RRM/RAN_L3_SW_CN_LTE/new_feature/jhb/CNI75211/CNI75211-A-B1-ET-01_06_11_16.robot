*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO    team-SG4
...               release-SBTS22R3    owner-huabao.jiang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${NRARFCN634000}    633216     #extended DOD band77
${NRARFCN657700}    656736     #band77 high
${NRARFCN713334}    712608     #band79
@{PARAMS_IN_SCF}
...    LNBTS-1:actExtN77Support=true
...    LNBTS-1:actTransmittedBelowGap=false
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{LTE4088}
...    @{LTE4193}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{neibour_releationship}
...    @{neighbor_relationship_with_gnb}
...    @{relation_error_fixed}
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS-1:actRedirect=disabled
...    LNBTS-1:actCsfbPsHoToUtra=false
...    LNBTS-1:act1xCsfb=false
...    LNBTS-1:actDualRx1xCsfb=false
@{relation_error_fixed}
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNBTS-1:actEndcSpidFwd=false
...    LNBTS-1:tS1eRABModInd=2000
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS-1:actMultBearers=true
...    LNCEL:tac=33
...    LNBTS-1:mcc=262
...    LNBTS-1:mnc=3
...    LNBTS-1:mncLength=2
@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19600
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1800
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19800
@{NRDCDPR}
...    LNBTS-1/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS-1/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS-1/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS-1/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=90
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN634000}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${NRARFCN657700}
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS-1/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS-1/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
@{LTE4088}
...    LNBTS-1:actLteNrDualConnectivity=true
...    LNBTS-1:tLteNrDualConnectPrep=5000
...    LNBTS-1:qciTab6:nrPdcpProfIdx=1001
...    LNBTS-1:qciTab6:lteNrDualConnectSupport=EN-DC
...    LNBTS-1:pdcpProf1001:pdcpProfileId=1001
...    LNBTS-1:pdcpProf1001:snSizeDl=18bit
...    LNBTS-1:pdcpProf1001:snSizeUl=18bit
...    LNBTS-1:pdcpProf1001:statusRepReq=0
...    LNBTS-1:pdcpProf1001:tDiscard=300ms
@{LTE4193}
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
@{LTE4549}
...    LNBTS-1:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS-1:enableBwCombCheck=false
...    LNBTS-1/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS-1/NRDCDPR-0:allowedBcSelectMethod=no preference
@{neibour_releationship}
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw15
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-2:ecgiPlmnId:mnc=03
...    LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=02
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw15
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=03
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=02
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-3/LNHOIF-1:measurementBandwidth=mbw15
...    LNCEL-3/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-1:ecgiLcrId=1
...    LNCEL-3/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-1:ecgiPlmnId:mnc=03
...    LNCEL-3/LNREL-1:ecgiPlmnId:mncLength=02
@{neighbor_relationship_with_gnb}
...    LNBTS-1/LNADJGNB-1:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNBTS-1/LNADJGNB-2:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNBTS-1/LNADJGNB-3:administrativeState=unlocked
...    LNBTS-1/LNADJGNB-3:cPlaneIpAddr=10.0.1.10
...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=148739
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL-1:actScellConfigForHiDemand=true
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=200
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL:maxNumScells=3
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:caPoolId=1
...    LNCEL-1:dlScellConfigLevel=20
...    LNCEL-1/CAPR-1:earfcnDL=1500
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=16
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actModulationSchemeDl=64QAM
@{actsib24}
...    LNBTS-1:actSIB24=true
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=77|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNCEL-1/SIB-0:threshServingLowQR9=1
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNBTS-1/LNCEL-2/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS-1/LNCEL-2/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    LNCEL-2/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=77|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-2/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNCEL-2/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNCEL-2/SIB-0:threshServingLowQR9=1
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
@{CB007172}
...    LNCEL-1:actReturnTo5GSA=at end of non-emerg RRC connection
...    LNBTS-1:actIdleLBNrAware=false
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    LNBTS-1:actDynTrigLteNrDualConnectivity=true
...    MODPR-0:autoAdapt=false
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1:imsEmerPlmnConfig:emerSessLimServ=false|emerSessArpPrioLev=1
...    LNBTS-1/LNBTS_FDD-0:actIMSEmerSessR9=true
...    LNBTS-1/MODPR-0/MODRED-0:redirRAT=nr
...    LNBTS-1/MODPR-0/MODRED-0:redirectPrio=1
...    delete:LNBTS-1/MODPR-0/MODRED-0:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-0:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-0:redirNrCarFrq:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/MODPR-0/MODRED-0:redirNrCarFrq:carrierFreqNrCell=${NRARFCN634000}
...    LNBTS-1/MODPR-0/MODRED-1:redirRAT=nr
...    LNBTS-1/MODPR-0/MODRED-1:redirectPrio=5
...    delete:LNBTS-1/MODPR-0/MODRED-1:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-1:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/MODPR-0/MODRED-1:redirNrCarFrq:carrierFreqNrCell=${NRARFCN657700}
...    LNBTS-1/MODPR-0/MODRED-2:redirRAT=nr
...    LNBTS-1/MODPR-0/MODRED-2:redirectPrio=3
...    delete:LNBTS-1/MODPR-0/MODRED-2:csFallBPrio
...    delete:LNBTS-1/MODPR-0/MODRED-2:emerCallPrio
...    LNBTS-1/MODPR-0/MODRED-2:redirNrCarFrq:ssbSubcarrierSpacing=30kHz
...    LNBTS-1/MODPR-0/MODRED-2:redirNrCarFrq:carrierFreqNrCell=${NRARFCN713334}
...    LNCEL-1/REDRT-1:redirRat=nr
...    LNCEL-1/REDRT-1:redirNrCarFrq:ssbSubcarrierSpacing=30kHz
...    LNCEL-1/REDRT-1:redirNrCarFrq:carrierFreqNrCell=${NRARFCN634000}
...    delete:LNCEL-1/REDRT-1:csFallBPrio
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=1|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=15KHz|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=77|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
@{LTE5104}
...    LNBTS-1:actSIB24=true
...    delete:MODRED
...    LNCEL-1:actReturnTo5GSA=disabled
...    LNBTS-1:actIdleLBNrAware=true
...    LNBTS-1:actIdleLBEnDcAware=false
...    LNBTS-1:actIdleLB=true
...    LNBTS-1:actSelMobPrf=true
...    MODPR-0:autoAdaptIMLB=false
...    MODPR-0:autoAdapt=false
...    MODPR-0:targetSelMethod=SIB_based
...    LNCEL-1/SIB-0:threshServingLowQR9=1
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinOffsetR9=1
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-3
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessagePeriodicity=640ms|siMessageSibType=SIB24
...    LNBTS-1/LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB24
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB5
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB6
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB7
...    LNCEL-1/SIB-0:sibSchedulingList:siMessageRepetition=1|siMessageSibType=SIB8
...    LNCEL-1:idleLBPercentageOfUes=100
...    LNCEL:idleLBCapThresh=100
...    LNCEL-1:t320=180min
...    LNCEL-1:idleLBCelResWeight=20
...    LNCEL-1/SIB-0:cellReSelPrio=5
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResPref=higher than EnDc FR2|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResPrio=6|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResWeight=100|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=77|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=30KHz|dlCarFrqNr=${NRARFCN634000}
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResPref=higher than EnDc FR2|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResPrio=6|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResWeight=100|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=77|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=30KHz|dlCarFrqNr=${NRARFCN657700}
...    LNCEL-1/NRFIM-1:nrCarFrqL:deriveSsbIndexNr=false|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResPref=higher than EnDc FR2|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResPrio=6|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:idleLBNrCelResWeight=100|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrHigh=0|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrMultiBandInfo1=79|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqQThrLow=0|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrH=10|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:nrFrqThrL=6|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinNr=-130|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:qRxLevMinSulNr=-50|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcDurationNr=1sf|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcOffsetNr=0|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbMtcPeriodicityNr=10sf|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:nrCarFrqL:ssbScsNr=30KHz|dlCarFrqNr=${NRARFCN713334}
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFHM=0.5
...    LNCEL-1/NRFIM-1:tResNrSF:nrResTiFMM=0.75
...    LNCEL-1/IRFIM-1:dlCarFrqEut=1700
...    LNCEL-1/IRFIM-1:eutCelResPrio=5
...    LNCEL-1/GFIM-1/GNFL-1:bandInd=gsm1800
...    LNCEL-1/GFIM-1/GNFL-1:gCelResPrio=3
...    LNCEL-1/GFIM-1/GNFL-1:gerArfcnVal=532
...    LNCEL-1/GFIM-1/GNFL-1:gerFrqThrH=2
...    LNCEL-1/GFIM-1/GNFL-1:gerFrqThrL=4
...    LNCEL-1/GFIM-1/GNFL-1:idleLBGeranCelResWeight=20
...    LNCEL-1/GFIM-1:tResGer=5
...    LNCEL-1/GFIM-1/GNFL-1:nccperm=0
...    LNCEL-1/GFIM-1/GNFL-1:qRxLevMinGer=-115
...    LNCEL-1/UFFIM-1:utrFddCarFrqL:dlCarFrqUtra=10600
...    LNCEL-1/UFFIM-1:utrFddCarFrqL:uCelResPrio=4
...    MODPR-0:idleLBPercentageOfUes=100
...    MODPR-0/MODIMP-1:dlCarFrqEutL:dlCarFrqEut=1700
...    MODPR-0/MODIMP-1:dlCarFrqEutL:idleLBEutCelResWeight=20
...    MODPR-0/MODIMP-1:geranCarFrqBd:geranBandInd=gsm1800
...    MODPR-0/MODIMP-1:geranCarFrqIdleModeL=532
...    MODPR-0/MODIMP-1:geranCarFrqBd:idleLBGeranCelResWeight=5
...    MODPR-0/MODIMP-1:utrFddCarFrqL:utrFddCarFrq=10600
...    MODPR-0/MODIMP-1:utrFddCarFrqL:idleLBUtraFddCelResWeight=5
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResPref=higher than EnDc FR2|dlCarFrqNr=${NRARFCN634000}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResPrio=6|dlCarFrqNr=${NRARFCN634000}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResWeight=100|dlCarFrqNr=${NRARFCN634000}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResPref=higher than EnDc FR2|dlCarFrqNr=${NRARFCN657700}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResPrio=6|dlCarFrqNr=${NRARFCN657700}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResWeight=100|dlCarFrqNr=${NRARFCN657700}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResPref=higher than EnDc FR2|dlCarFrqNr=${NRARFCN713334}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResPrio=6|dlCarFrqNr=${NRARFCN713334}
...    MODPR-0/MODIMP-1:nrCarFrqL:idleLBNrCelResWeight=100|dlCarFrqNr=${NRARFCN713334}
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
${ue_eutra_capabilities}
...    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00
...    000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC80
...    0801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C00011C0002400004900009400012C00
...    02600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA0001780003680007F001D3A00000001D0000000
...    0E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074
...    00000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A000
...    00001D00000000A080000079D000000000000000000000000000000000000000000000000000000000001011C421298061CFFFFFFFFFFFFFFFA15000300
...    452E000040000209634020184C135E000000C000000480001048204400008100A
${ue_cap_redir_extendn77}
...    SEPARATOR=
...    C59FF030030804081705C177E0D98808C0000480012001008A200424000AA0004008A480001000008240C0000860030084C138
...    0041022000040805
${ue_cap_redir_without_extendn77}
...    SEPARATOR=
...    C59FF030030804081705C177E0D98808C0000480012001008A200424000AA0004008A480001000008240C0000860030084C1380041022000040804
${TM9_ue_cap_redir_extendn77}
...    SEPARATOR=
...    D5BFF004094182200102008021FF9A313D1000029504303F1100307080000680003CA0000210000E8000080E80100C18200802003EBE400002C81006094C0
...    30032AA820102004524000080000458020081800010C006010982709A8204400008100A
${extendband77}
...    multiBandInfoList-r15 contains (77) and
...    ns-PmaxListNR-r15 contains (additionalSpectrumEmissionNR-r15 eq 1)
${veriy_n77_exist}
...    idleModeMobilityControlInfo contains (freqPriorityListEUTRA contains (carrierFreq eq 1700)) and
...    carrierFreqs contains (startingARFCN eq 532) and
...    freqPriorityListUTRA-FDD contains (carrierFreq eq 10600) and
...    freqPriorityListNR-r15 contains (
...    carrierFreq-r15 eq 656736,
...    carrierFreq-r15 eq 633216,
...    carrierFreq-r15 eq 712608)
${veriy_n77_notexist}
...    idleModeMobilityControlInfo contains (freqPriorityListEUTRA contains (carrierFreq eq 1700)) and
...    carrierFreqs contains (startingARFCN eq 532) and
...    freqPriorityListUTRA-FDD contains (carrierFreq eq 10600) and
...    freqPriorityListNR-r15 contains (
...    carrierFreq-r15 eq 656736,
...    carrierFreq-r15 eq 712608)
${veriy_n77}
...    freqPriorityListNR-r15 contains (carrierFreq-r15 eq 633216)


*** Test Cases ***
CNI75211-A-B1-ET-01-16_verify SIB24 when CNI75211 enabled and UE support DoD band
    [Documentation]    This case verifies sib24 have IE: additionspecturmemisson info when CNI75211 enabled ,AdditionalSpectrumEmission
    ...    for DoD frequency in SIB24 should be included regardless UE support DoD band or not as this is SIB and we just need to verify
    ...    that the correct value is in SIB24.
    [Tags]    QC_168508
    delta commission parameters    ${actsib24}
    cells should be onair
    Check SIB24 With additionalSpectrumEmissionNRr15
    Check SIB24 Without additionalSpectrumEmissionNRr15

CNI75211-A-B1-ET-01-06_Blind Redirection to NR frequency of DOD band at end of RRC connection when CNI75211 enabled
    [Documentation]    This case verifies when ue capability support Extended n77 (3450-3550MHz) and CNI75211 enabled,
    ...    ue can redirrect to 5G n77(NR frequency is in range of 3450 to 3550MHz) band after rrc connection release
    [Tags]    QC_168518
    delta commission parameters    ${CB007172}
    cells should be onair
    Attach UE With SA NR    1    ${ue_cap_redir_extendn77}
    Add Normal QCI1 Bearer    1
    Release Normal QCI1 Bearer    1
    Trigger S1 Reset for UE then Check RRC Connection Release with redirect    1    633216
    Attach UE With SA NR    2    ${ue_cap_redir_without_extendn77}
    Add Normal QCI1 Bearer    2
    Release Normal QCI1 Bearer    2
    Trigger S1 Reset for UE then Check RRC Connection Release with redirect    2    712608

CNI75211-A-B1-ET-01-11_AwareIdleModeLoadBalancing with n77
    [Documentation]    This case verifies ue support SA aware IMLB to 5G n77 band NR frequency from range 3450 to 3550Mhz when CNI75211
    ...    enabled and ue support n77 Band and field extendedBand-n77-r16 in its UE Capabilities, meanwhile enabled IDLB functionality
    [Tags]    QC_168513
    delta commission parameters    ${LTE5104}
    cells should be onair
    Attach UE With SA NR    1    ${ue_cap_redir_extendn77}
    DOD Ue detach and check idlemodemobilitycontrolinfo    1
    Attach UE With SA NR    2    ${ue_cap_redir_without_extendn77}
    Non DOD Ue detach and check idlemodemobilitycontrolinfo    2
    Attach UE With SA NR    3    ${TM9_ue_cap_redir_extendn77}
    DOD Ue detach and check idlemodemobilitycontrolinfo    3

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Set UE parameters for ENDC capability
    Create CELL alias    alias=CELL_1    cell_id=1    cell_type=cus
    Create CELL alias    alias=CELL_2    cell_id=2    cell_type=cus
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '634000:634000',
    ...    tdd_cell: yes, gscn: 7845, suggested_band: 77}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...         ${GNB7_CELL1}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr, tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, gscn: 8090, suggested_band: 77}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...      gnb_id: '0x00008'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.12
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB8_CELL1}
    ${GNB9_CELL1}    catenate    - {id: 91, technology: nr, tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '657700:657700',
    ...    tdd_cell: yes, gscn: 7880, suggested_band: 78}
    Add Yaml    BASE_STATIONS
    ...    - id: 9
    ...      gnb_id: '0x00009'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.10
    ...      x2_peers: none
    ...      cells:
    ...         ${GNB9_CELL1}
    Update Yaml    UEs/UE_sets/1    capability: ${ue_eutra_capabilities}
    Update Yaml    UEs/UE_sets/2    capability: ${ue_eutra_capabilities}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 5, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 8, default: on, pdn: 2}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 2}
    ...     - {qci: 5, pdn: 2}
    Update Yaml    UEs/UE_sets/1     bearer: bearer_set_2
    Update Yaml    UEs/UE_sets/2     bearer: bearer_set_2

DOD Ue detach and check idlemodemobilitycontrolinfo
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${veriy_n77_exist})
    ...    alias=rrc_release_flow${ue_id}    overall_timeout=10
    execute uex command    ue_detach id=${ue_id}
    flow occurred as expected    alias=rrc_release_flow${ue_id}

Check SIB24 With additionalSpectrumEmissionNRr15
    Expect Message Flow
    ...    CELL_1:RRC_SystemInformationBlockType24-r15(${extendband77})
    ...    alias=sib24_flow    overall_timeout=300
    block cell1
    unblock cell1
    Flow Occurred As Expected    alias=sib24_flow

Check SIB24 Without additionalSpectrumEmissionNRr15
    expect message will not occur
    ...    CELL_2:RRC_SystemInformationBlockType24-r15(${extendband77})
    ...    alias=sib24without_flow    overall_timeout=300
    block cell2
    unblock cell2
    flow not occurred for message    alias=sib24without_flow

Non DOD Ue detach and check idlemodemobilitycontrolinfo
    [Arguments]    ${ue_id}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${veriy_n77_notexist})
    ...    alias=rrc_release_flow${ue_id}    overall_timeout=10
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (${veriy_n77})
    ...    alias=non77_flow    overall_timeout=10
    execute uex command    ue_detach id=${ue_id}
    flow occurred as expected    alias=rrc_release_flow${ue_id}
    flow not occurred for message    alias=non77_flow

Trigger S1 Reset for UE then Check RRC Connection Release with redirect
    [Arguments]    ${ue_id}    ${nrfreq}
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionRelease (carrierFreq-r15 eq ${nrfreq})
    ...    alias=rrc_release_flow    overall_timeout=10
    execute egate command    ue_s1_reset id=${ue_id} by=mme enb=1 mme=1    ResetAck
    Flow Occurred As Expected    alias=rrc_release_flow

Release Normal QCI1 Bearer
    [Arguments]    ${ue_id}
    execute uex command    bearer_del ue=${ue_id} qci=1    #Bearer Deletion procedure

Attach UE With SA NR
    [Arguments]    ${ue_id}    ${ue_capa}
    execute uex command    ue_attach id=${ue_id} enb=1 cell=1 ue_eutra_capabilities=${ue_capa}

Add Normal QCI1 Bearer
    [Arguments]    ${ue_id}    ${apn}=nokia_2.net
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=${apn}    #UE${ue_id}: PDN connectivity procedure for PDN 2
    execute uex command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31 apn=${apn}    #Bearer Creation

Set UE parameters for ENDC capability
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    execute egate command    trace_sim enb=42 protocol=x2,s1 on
    execute uex command    ue_param id=1 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=77
    execute uex command    ue_param id=2 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=77
    execute egate command
    ...    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command
    ...    gnb_endc_param id=8 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command
    ...    gnb_endc_param id=9 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms T_DC_Overall=5000ms

Block Cell${number}
    ${lncel_id}    Get cell id by configuration id    LTE    ${number}
    Block_cell    ${lncel_id}
    Assert    LNCEL    ${lncel_id}    blockingState=Blocked
    Sleep    10s    #wait sib broadcast again

Unblock Cell${number}
    ${lncel_id}    Get cell id by configuration id    LTE    ${number}
    Unblock_cell    ${lncel_id}
    Assert    LNCEL    ${lncel_id}    blockingState=Unblocked
    Cells Should Be OnAir    cell_id=${number}