*** Settings ***
Suite Setup    Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...    owner-jun.3.ye    owner-yin.zhang    release-SBTS20A    team-DEVHZ5_SG6
Resource    ../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    4
${CUS_LOG_LEVEL}    ERROR
${CUS_SYSLOG_MODE}    ERROR
@{PARAMS_IN_SCF}
...    @{CA}
...    @{ENDC_X2_link}
...    @{LTE4088}
...    @{LTE4193}
...    @{FIX_RELATION_ERROR}

@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:actFlexCaMgmt=false
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL:actFlowCtrlEnh=false
...    LNCEL:maxNumScells=2
...    LNBTS-1:sCellDeactivationTimereNB=rf128
...    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=2
...    LNCEL-2/CAREL-1:lcrId=3
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer

@{ENDC_X2_link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-3:nrCellId=115971
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
...    LNBTS/LNADJGNB-2:administrativeState=unlocked
...    LNBTS/LNADJGNB-2:cPlaneIpAddr=10.0.1.12
...    LNBTS/LNADJGNB-2:adjGnbId=8
...    LNBTS/LNADJGNB-2:adjGnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-2:nrCellId=132354
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=10000
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNCEL/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNCEL/LNCEL_TDD-0:measGapPattern=gap0
@{FIX_RELATION_ERROR}
...    LNBTS:actAmbrModCaTrigger=false
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:actFlexScellSelect=true
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNBTS:nrRestrictionOverride=disabled
...    LNBTS:tS1eRABModInd=2000
...    LNCEL:actCaArchEnhImp=off
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL:eTputFilterConfig=51
...    LNCEL:eTputInitMcs=20
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750
...    LNCEL-2:actScellConfigForHiDemand=true
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:dlScellConfigLevel=20
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-2:ulCaMinPcellSinrQci1=0
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40148
...    LNBTS/NRDCDPR-0:tPeriodicPhr=200sf

@{NRDCDPR_BAND78}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
@{NRDCDPR_BAND78_636666}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN636666}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
@{NRDCDPR_BAND41_524100}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:carrierFreqNrCell=${NRARFCN524100}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:freqBandIndicatorNrL:freqBandIndicatorNr=41
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-0:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
@{LTE4575}
...    LNBTS:actCAggrLteNrDualConnectivity=blind_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
@{LTE5515}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
@{LTE4530}
...    LNBTS:actSnChangeSnInit=true
@{Closed_Loop_MIMO_4x4}
...    LNCEL/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x4)
...    LNCEL/LNCEL_TDD-0:activatedMimoTM=TM9
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsPwrOffset=0
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsResourceConf=rsc0
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:csiRsSubfrConf=14
...    LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=30
...    LNCEL/LNCEL_TDD-0:srsDlMimoModeDepConf:srsBandwidth=3hbw|beamformingType=nonBeamforming
...    LNCEL/LNCEL_TDD-0:csiRepSubmode=submode1
...    LNCEL/LNCEL_TDD-0:csiRsConfigInfo:numOfCsiRsAntennaPorts=4
@{handover}
...    LNBTS-1:actHoWoSnChg=intraEnbHoEnabled
...    LNBTS-1:actIfHo=enabled
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=39948
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1:threshold2InterFreq=65
...    LNCEL-1:threshold1=90
...    LNBTS-1/MODPR-0:autoAdapt=true
@{dlSectorBFWeight}
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:dlSectorBFWeightProfName=customized profile 1
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp0=100
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp1=50
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp2=100
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:modulusOfWeighforAntGrp3=50
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp0=0
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp1=180
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp2=0
...    LNBTS-1/LNBTS_TDD-0:dlSectorBFWeightCusProf:phaseOfWeighforAntGrp3=180
...    LNCEL/LNCEL_TDD-0:dlSectorBFWeightProfName=customized profile 1
@{MFBI}
...    LNBTS:actMFBI=true
...    LNBTS:caIntraCellHoMode=moreDLCACapacity
...    LNBTS/MFBIPR-0:addFreqBandInd=41
...    LNBTS/MFBIPR-0:addSpectrEmissReq=2
...    LNBTS/MFBIPR-0:eutraCarrierFreq=37850
...    LNBTS/MFBIPR-0:freqBandIndPrio=broadcasted
...    LNBTS:selectScellMappedBand=false

@{delta_for_case_Db_03_01}
...    @{NRDCDPR_BAND78}
...    @{LTE4575}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:actCaArchEnhImp=off
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:enableBwCombCheck=true
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNBTS-1:actFlexScellSelect=true
...    LNBTS-1:actA3ScellSelect=false
...    LNBTS-1:sCellActivationMethod=blind
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS:multScellReleaseTimer=5
...    LNBTS:sCellDeactivationTimereNB=rf128
...    LNCEL-3:scellGoodChQualThr=25
...    LNCEL-3:scellBadChQualThr=20
...    LNCEL-1/LNCEL_TDD-0:earfcn=39750
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40148
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAPR-1:earfcnDL=39948
...    LNCEL-1/CAPR-1:enableA3Event=true
...    LNCEL-1/CAPR-1:enableA6Event=true
...    LNCEL-1/CAPR-1:sFreqPrio=1
...    LNCEL-1/CAPR-1:scellMeasThreshRsrq=-120
...    LNCEL-1/CAPR-1:scellMeasThreshRsrp=-95
...    LNCEL-1/CAPR-2:earfcnDL=40148
...    LNCEL-1/CAPR-2:enableA3Event=true
...    LNCEL-1/CAPR-2:enableA6Event=true
...    LNCEL-1/CAPR-2:sFreqPrio=2
...    LNCEL-1/CAPR-2:scellMeasThreshRsrq=-120
...    LNCEL-1/CAPR-2:scellMeasThreshRsrp=-95
...    LNCEL-1/CAREL-1:pcellSwapAllowed=forbidden
...    LNCEL-1/CAREL-2:pcellSwapAllowed=forbidden
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=1
@{active LTE2276}
...    LNBTS-1:actA3ScellSelect=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=10
@{recovery_for_case_Db}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNBTS:multScellReleaseTimer=0
...    LNCEL-3:scellGoodChQualThr=8
...    LNCEL-3:scellBadChQualThr=6
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1:actA3ScellSelect=false
...    LNBTS-1:actFlexScellSelect=false
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNCEL-1/CAPR-1:earfcnDL=1
...    LNCEL-1/CAPR-1:scellMeasThreshRsrp=-110
...    delete:LNCEL-1/CAPR-2
@{delta_for_case_Fa_03_02}
...    @{LTE4530}
...    @{LTE5515}
...    @{NRDCDPR_BAND78_636666}
...    @{LTE4549}
...    LNBTS-1:enableNonCompBcsChkEnDc=false
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:actCaArchEnhImp=off
...    LNBTS:qciTab6:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab8:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNCEL:maxNumScells=3
...    LNBTS:enableBwCombCheck=false
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=20
...    LNCEL-2/LNCEL_TDD-0:chBw=15 MHz
...    LNCEL-3/LNCEL_TDD-0:chBw=10 MHz
...    LNCEL-1/LNCEL_TDD-0:earfcn=39777
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40068
...    LNCEL-1/CAREL-2:scellPrio=1
# fix relation error
...    LNCEL-3/LNCEL_TDD-0:maxNumActUE=300
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference

@{recovery_for_case_Fa}
...    LNCEL-1/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-2/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled|nrPdcpProfIdx=1001
...    delete:enableNonCompBcsChkEnDc
@{delta_for_case_Cc_04_01}
...    @{LTE4549}
...    @{NRDCDPR_BAND78}
...    @{LTE4530}
...    @{Closed_Loop_MIMO_4x4}
...    @{handover}
...    @{dlSectorBFWeight}
...    @{MFBI}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:enableBwComSetChkEnDc=false
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers with min CCs
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNCEL-1/LNCEL_TDD-0:earfcn=39752
...    LNCEL-2/LNCEL_TDD-0:earfcn=39950
...    LNCEL-3/LNCEL_TDD-0:earfcn=40148
...    delete:enableNonCompBcsChkEnDc
...    LNCEL:maxNumScells=2
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=3070
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1:threshold2InterFreq=65
...    LNCEL-1:threshold1=90
...    LNCEL-2:threshold1=90
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=39752
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-2:threshold2InterFreq=65
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    delete:LNCEL-2/CAREL-1
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=1
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=7
...    LNCEL/LNCEL_TDD-0:csiRepSubmode=submode1
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
@{delta_for_case_Cc_01_powerOffset_0}
...    @{LTE4549}
...    @{NRDCDPR_BAND78}
...    @{LTE4530}
...    @{Closed_Loop_MIMO_4x4}
...    @{handover}
...    @{dlSectorBFWeight}
...    @{MFBI}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:enableBwComSetChkEnDc=false
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=max MIMO layers with min CCs
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNCEL-1/LNCEL_TDD-0:earfcn=39752
...    LNCEL-2/LNCEL_TDD-0:earfcn=39950
...    LNCEL-3/LNCEL_TDD-0:earfcn=40148
...    delete:LNBTS:enableNonCompBcsChkEnDc
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    delete:LNCEL-2/CAREL-1
...    LNCEL:maxNumScells=2
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=3070
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1:threshold2InterFreq=65
...    LNCEL-1:threshold1=90
...    LNCEL-2:threshold1=90
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=39752
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-1:measQuantInterFreq=rsrp
...    LNCEL-2:threshold2InterFreq=65
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNCEL/LNCEL_TDD-0:csiRepSubmode=submode1
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
@{delta_for_case_Cc_01_powerOffset_non0}
...    LNBTS-1/NRDCDPR-0:enDCpMaxEUTRApowerOffset=5
...    LNBTS-1/NRDCDPR-0:enDCpMaxNRpowerOffset=2
@{delta_for_case_A-f_01_01_cell3_10M}
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40082
...    LNCEL-3/LNCEL_TDD-0:chBw=10 MHz
...    @{LTE4530}
...    @{handover}
...    @{dlSectorBFWeight}
...    LNBTS:actMFBI=false
...    @{NRDCDPR_BAND41_524100}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
...    LNBTS:caIntraCellHoMode=disabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL:threshold2InterFreq=52
...    LNBTS-1:enableNonCompBcsChkEnDc=false
...    delete:LNCEL/LNCEL_TDD-0:csiRsConfigInfo
...    LNCEL:maxNumScells=2
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=20
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNBTS-1:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-2:ulCaMinPcellSinrQci1=0
...    LNCEL-3/LNCEL_TDD-0:maxNumActUE=350
...    LNCEL/LNCEL_TDD-0:activatedMimoTM=TM4
...    LNCEL-1/CAREL-1:lcrId=0
...    LNCEL-1/CAREL-1:lnBtsId=0
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=1
...    LNCEL-2/CAREL-1:lcrId=3
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
@{delta_for_case_A-f_04_01_cell3_20M}
...    @{LTE4530}
...    @{handover}
...    @{dlSectorBFWeight}
...    LNBTS:actMFBI=false
...    @{NRDCDPR_BAND41_524100}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS:actEnhFlexCaWithEnDc=true
...    LNBTS:enableBwComSetChkEnDc=true
...    LNBTS:caIntraCellHoMode=disabled
...    LNBTS:qciTab6:lteNrDualConnectSupport=disabled
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNCEL:threshold2InterFreq=52
...    LNBTS-1:enableNonCompBcsChkEnDc=false
...    delete:LNCEL/LNCEL_TDD-0:csiRsConfigInfo
...    LNCEL:maxNumScells=2
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=20
...    LNBTS-1:actAdvStepwiseScellAdd=buffer-based
...    LNCEL-1/LNCEL_TDD-0:earfcn=38000
...    LNCEL-2/LNCEL_TDD-0:earfcn=39948
...    LNCEL-3/LNCEL_TDD-0:earfcn=40146
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNBTS-1:actFlexCaMgmt=false
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL-2:scellFastSchedulingSelect=normal
...    LNCEL-2:dlCaMinPcellCqi=0
...    LNCEL-2:dlCaMinPcellCqiQci1=0
...    LNCEL-2:ulCaMinPcellSinr=0
...    LNCEL-2:ulCaMinPcellSinrQci1=0
...    LNCEL-3/LNCEL_TDD-0:maxNumActUE=350
...    LNCEL/LNCEL_TDD-0:activatedMimoTM=TM4
...    LNCEL-1/CAREL-1:lcrId=0
...    LNCEL-1/CAREL-1:lnBtsId=0
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-2/CAREL-1:lcrId=3
...    LNCEL-2/CAREL-1:lnBtsId=1
...    LNCEL-2/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff=1
...    LNCEL:actModulationSchemeDl=256QAM
...    LNCEL:actLdPdcch=true
...    LNCEL/LNCEL_TDD-0:maxNrSymPdcch=3
...    LNCEL:adaptPdcchDwellTime=0
...    LNCEL:mbrSelector=ueCapability
...    LNCEL:actDl256QamChQualEst=false
...    LNBTS:pdcpProf2:snSize=15bit
...    LNBTS:rlcProf7:tReord=15ms
${ue_nr_capabilities_D}    40000000000003100002000001800009800004D0
${ue_eutra_nr_capabilities_D}
...    C11220400994002280E268000000059400713400000802C940389A0000040265044CA001A68000000440001008000402020040084000201010020040
${ue_eutra_capabilities_D}
...    SEPARATOR=
...    DDB80502A1FBF050819FFF840CFFFC2067FFDFF3FFAFA21000886429D104194E9525C7EA5F8000000000812F0901831DF00000002CF400C00A
...    0843003082104200430821042080308010C2084108010C1086084304218210C1086084304218210C1086084304218210C10860843003003003
...    0030025A1F551840F01D00008207F8002081FE000800F400020B404103A0001242E80004968082D01002E80004868082D0104268093D000082
...    D0100268093D000080D0104268091D000082D01042E80004168082D01002E80004068082D01041E800051680820B4051E80004107A004135A0
...    2483D00009AD012416809BD0020920B404DE80004907A004135A02083D00009AD010416809BD0000820F400824B404907A000125A02483D002
...    092D01041E800049680820B4049E80004103A0001540E80005103A0041340E80004D03A004124F42067FFE1033FFF0819FFF840CFFFC2063FF
...    E1033FFF0A19FFF840CFFFC2067FFE1033FFF0819FFF840CFFFC2067FFE1033FFF0819FFF840CFFFC2067FFE1033FFF0819FFF840CFFFC2067
...    FFE1033FFF0819FFF840CFFFC2067FFE1033FFF0819FFF840CFFFC2067FFE1733FFF0B99FFF6CEC0000FD881B3B000008F9D800007843C7E00
...    00008FF9E000101010604000200200200200200200200100401004010040100401004010040100400000000003E08024007CE00A2BCD0200A4
...    2FF34A5DE2807C0021000CD24000080014432E28081409A80206823C2800010410C10000020410030410410010410010000810410800000810
...    000A320200020001100000
${ue_nr_capabilities_F}
...    CF00000001C8F5C0302800001939980000CCC02000014000013400009C020070003080000280510136027131000000300C0020000002C00000001000000000020040
${ue_eutra_capabilities_F_3CC}
...    SEPARATOR=
...    DDB80501A128285CCFFFC2E67FFE1733FFEFF9FFD7D10800443214E8820CA74A92E3F52FC00000000040978480C18EF8000000167A00600504
...    21801841082100218410821040184008610420840086084304218210C1086084304218210C1086084304218210C10860843042180180180180
...    18012D0FAA8C20700E80004D0394001041E8000416808207400C2685D00008AD0105A02005D000090D0105A02084D0127A000105A02004D012
...    7A000101A02084D0123A000105A02085D000082D0105A02005D000080D0105A02083D0000A2D01041680A3D0000820F400826B404907A00013
...    5A02482D0137A00412416809BD0000920F400826B404107A000135A02082D0137A0001041E801049680920F400024B404907A004125A02083D
...    000092D0104168093D0000820740002A81D0000A20740082681D0020927A1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E6
...    7FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2
...    E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFB67600007EC40D9D8000047CEC00003C21E3F00000047FCF0000808083
...    02000100100100100100100100080200802008020080200802008020080200000000001F04012003E700515E681005217F9A52EF1403E00108
...    00669200004000A219734040A04D40103411E14000102082182000004082006082082002082002000102082100000102000146404000400022
...    000108080040
${ue_eutra_capabilities_F_2CC}
...    SEPARATOR=
...    DDB80501A128285CCFFFC2E67FFE1733FFEFF9FFD7D10800443214E8820CA74A92E3F52FC00000000040978480C18EF8000000167A00600504
...    21801841082100218410821040184008610420840086084304218210C1086084304218210C1086084304218210C10860843042180180180180
...    18012D0FAA8C20700E8000490394001041E800041680820740082485D00008AD0105A02005D000090D0105A02084D0127A000105A02004D012
...    7A000101A02084D0123A000105A02085D000082D0105A02005D000080D0105A02083D0000A2D01041680A3D0000820F400824B404907A00012
...    5A02482D0127A004124168093D0000920F400824B404107A000125A02082D0127A0001041E801049680920F400024B404907A004125A02083D
...    000092D0104168093D0000820740002A81D0000A20740082481D0020927A1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E6
...    7FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2
...    E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFB67600007EC40D9D8000047CEC00003C21E3F00000047FCF0000808083
...    02000100100100100100100100080200802008020080200802008020080200000000001F04012003E700515E681005217F9A52EF1403E00108
...    00669200004000A219734040A04D40103411E14000102082182000004082006082082002082002000102082100000102000146404000400022
...    000108080040
${ue_eutra_nr_capabilities_F_3CC}
...    SEPARATOR=
...    C10060F70B2832E1400000003F8000000080010150FC00000005C2CA0CB8500000040FE0000000200040543F0000000130B2830E2680000203
...    F80000000066165065C4D00000607F000000000CC4CA08912871340000201FC00000000330B2832E2700000503F8000000006E165041C4E000
...    00C07F00000001000202A0080305100A2026C04E01820004010080100210002008040200208000802020040080080201801002200008040002
...    01010020044040401002010204000020001801003004008604020080201020300006000100400030000C008018010020
${ue_eutra_nr_capabilities_F_2CC}
...    SEPARATOR=
...    C10060F70B2832E1400000003F8000000080010150FC00000005C2CA0CB8500000040FE0000000200040543F0000000130B2820E2680000203
...    F80000000066165045C4D00000607F000000000CC4CA08912871340000201FC00000000330B2822E2700000503F8000000006E165041C4E000
...    00C07F00000001000202A0080305100A2026C04E01820004010080100210002008040200208000802020040080080201801002200008040002
...    01010020044040401002010204000020001801003004008604020080201020300006000100400030000C008018010020
${ue_eutra_nr_capabilities_F_1CC}
...    SEPARATOR=
...    C10060F70B2832E1400000003F8000000080010150FC00000005C2CA0CB8500000040FE0000000200040543F0000000130B2800E2680000203
...    F80000000066165065C4D00000607F000000000CC4CA08912871340000201FC00000000330B2832E2700000503F8000000006E165041C4E000
...    00C07F00000001000202A0080305100A2026C04E01820004010080100210002008040200208000802020040080080201801002200008040002
...    01010020044040401002010204000020001801003004008604020080201020300006000100400030000C008018010020
${ue_nr_capabilities_C}
...    SEPARATOR=
...    E1000000014F7E0302000001404807060E220C000609B00839F21078004120188000502C4DD010CA1A044083A0C30260220B6480A01000C039
...    F2107800412070701101E407E26F02409000000048000010240000100280300C0300C03600A0080401004600A00C0401004011802801010046
...    00A00004600A0040300D80280000D809CA9BCA1BCA8ADC23748020200000830C0080000A0C3002000044104208000190410820000841042026
...    954CD2898AE54576A2BB10
${ue_eutra_capabilities_C}
...    SEPARATOR=
...    DDB80502A1FBF050B99FFF85CCFFFC2E67FFDFF3FFAFA21000886429D104194E9525C7EA5F8000000000812F0901831DF00000002CF400C00A
...    0843003082104200430821042080308010C2084108010C1086084304218210C1086084304218210C1086084304218210C10860843003003003
...    0030025A1F551840101D01004107A020082D01002E80004168082D0100F42E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CC
...    FFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85
...    CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF6CEC0000FD881B3B000008F9D800007843C7E0000008FF9E0001010106
...    04000200200200200200200200100401004010040100401004010040100400000000003E08024007CE00A2BCD0200A42FF34A5DE2807C00210
...    00CD24000080014432E28081409A80206823C1400000020010010010800010800000D08020002000110000
${ue_eutra_nr_capabilities_C_1}
...    SEPARATOR=
...    0118180165001C4D00000050B2800E800000012028994102280E2680000220285940074000000190146CA0011402280E268000042028994112
...    280E26800005200703283829D3849D3A7093A74E1274E9C24E9D3849D3A70D3A74E9C028400020101002004200020080801002200018040006
...    01010020044000400800100202004008C000A010002804000A01010020044000600800180202004008
# 1 SPS 2 3 4 5 6 DPS
${ue_eutra_nr_capabilities_C_2}
...    SEPARATOR=
...    0118188165001C4D0000004050B2800E800000012028994102280E2680000220285940074000000190146CA0011402280E2680000420289941
...    12280E26800005200703283829D3849D3A7093A74E1274E9C24E9D3849D3A70D3A74E9C0284000201010020042000200808010022000180400
...    0601010020044000400800100202004008C000A010002804000A01010020044000600800180202004008
# all DPS 6 1 DPS PC2
${ue_eutra_nr_capabilities_C_3}
...    SEPARATOR=
...    0118188165001C4D0000000050B2800E800000010028994102280E2680000200285940074000000180146CA0011402280E2680000400209941
...    12280E26800005000703283829D3849D3A7093A74E1274E9C24E9D3849D3A70D3A74E9C0284000201010020042000200808010022000180400
...    0601010020044000400800100202004008C000A010002804000A01010020044000600800180202004008
${ue_eutra_nr_capabilities_A}
...    SEPARATOR=
...    C10060F60B2800E1400000003F8000000082010150FA0000000584CA00114070A00000081FC0000000400080A07D00000002C2650008A0B850
...    0000080FE0000000208040543E8000000170B2820E1400000303F8000000082010150FA0000000582C94038500000100FE000000000BE80000
...    00131328204505C2800000A07F00000001F40000000B8D940022804501C2800000C07F00000001000202A1F400000000040A012C0280182000
...    100808010022000080400020101002004400010080004020200400840004010100200420001008080100220000804000201010020046000100
...    8000402000100808010020
${ue_eutra_capabilities_A}
...    SEPARATOR=
...    DDB80501A128285CCFFFC2E67FFE1733FFEFF9FFD7D10800443214E8820CA74A92E3F52FC00000000040978480C18EF8000000167A00600504
...    21801841082100218410821040184008610420840086084304218210C1086084304218210C1086084304218210C10860843042180180180180
...    18012D0FAA8C200C0E50842081D01084107A021082D01040E8084249E85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FF
...    F85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFF0B99
...    FFF85CCFFFC2E67FFE1733FFF0B99FFF85CCFFFC2E67FFE1733FFED9D80001FB103676000011F3B00000F0878FC0000011FF3C000202020C08
...    000400400400400400400400200802008020080200802008020080200800000000007C1004800F9C014579A0401485FE694BBC500F80042001
...    9A48000100028865CD010281350040D04785000020821820000040820060820820020820020001020821000001020001464040004000220001
...    08080040
${ue_nr_capabilities_A}    CE00000001C8F5C0302800001939980000CC00100001400000989880000018060010000001
#temporary workaround for LTE4193-B for supporting MeasTimingConf in X2SetupReponse for gNB
${LTE4193B_SUPPORTING_MeasTimingConf}    0x00130060
@{PARAMS_IN_SWCONFIG}
...    ${LTE4193B_SUPPORTING_MeasTimingConf} = 1

@{PM_Counters_F-a_03-02}
...    LNCEL-1/MCC-262/MNC-03:${CA_SCELL_DECONFIG_PR_ATT_SCG}=1
...    LNCEL-1/MCC-262/MNC-03:${CA_SCELL_DECONFIG_PR_SUCC_SCG}=1
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_ATT}=4
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_SUCC}=4
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_ATT_SCG}=3
...    LNCEL-1/MCC-262/MNC-03:${DL_CA_SCELL_DECONFIG_SUCC_SCG}=3
# Downlink CA Deconfiguration Attemps
${DL_CA_SCELL_DECONFIG_ATT}    M8011C213
${DL_CA_SCELL_DECONFIG_SUCC}    M8011C214
# The number of attempts for Carrier Aggregation SCell full releases due to SCG split bearer activation
${DL_CA_SCELL_DECONFIG_ATT_SCG}    M8011C292
${DL_CA_SCELL_DECONFIG_SUCC_SCG}    M8011C293
# Number of attempts for Carrier Aggregation SCell partial releases due to EN-DC setup
${CA_SCELL_DECONFIG_PR_ATT_SCG}    M8080C93
${CA_SCELL_DECONFIG_PR_SUCC_SCG}    M8080C94
@{PARAMS_IN_EMIL}    -n mac -e 0x26EB    #PS_CA_USER_RECONFIGURATION_REQ_MSG from L2 to MACPS

*** Test Cases ***
LTE5515-F-a_03-02 M8080C93 M8080C94 will not update due to Scell full release during SgNB addition and modification procedure
    [Tags]
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_Fa_03_02}
    Start Rtpm Counter
    Attach 3 UEs With Different Capabilities
    Start traffic To Trigger 3CC CA    ue=1
    Start traffic To Trigger 3CC CA    ue=2
    Start traffic To Trigger 2CC CA    ue=3
    Trigger ENDC And CA Changed From 3CC to 3CC    ue=1
    Trigger ENDC And CA Changed From 3CC to 2CC    ue=2
    Trigger ENDC And CA Changed From 2CC to 1CC    ue=3
    Trigger SgNB modification And All UEs Changed To 1CC
    Check Rtpm Counters    ${PM_Counters_F-a_03-02}
    Release All UEs
    [Teardown]    Local Test Teardown And Recover Env    ${recovery_for_case_Fa}

LTE5515-C-c_ET_04_01_DPS is chosen by gNB during the SgNB Modification TDD
    [Tags]
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_Cc_04_01}
    Part DPS configurated UE trigger ENDC with PC3 minus powerOffset    ue=5
    UE Handover From Cell2 To Cell1 And p-maxNR-FR1 26 p-MaxEUTRA 26     ue=5
    All DPS configurated UE trigger ENDC and no powerCoordination    ue=6
    UE Handover From Cell2 To Cell1 And p-maxNR-FR1 26 p-MaxEUTRA 26     ue=6
    Get Throughput    ue_id=5
    Check pgw sgw and enb stats
    Check Current Throughput    ue_id=6    target=100

LTE5515-C-c_ET_01_02_SPS configuration during the SgNB Modification procedure
    [Tags]
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_Cc_01_powerOffset_0}
    UE trigger ENDC and no powerCoordination    ue=7
    UE Handover From Cell2 To Cell1 And p-maxNR-FR1 26 p-MaxEUTRA 26     ue=7
    Delta Commission Parameters And Wait Cells Onair    ${delta_for_case_Cc_01_powerOffset_non0}
    UE setup ENDC with PC3 minus powerOffset    ue=8
    Get Throughput    ue_id=7
    Check pgw sgw and enb stats
    Check Current Throughput    ue_id=8    target=100
    UE Handover From Cell2 To Cell1 with PC3 minus powerOffset      ue=8
    Check Current Throughput    ue_id=8    target=100

LTE5515-A-f_ET_01_01_Bandwidth combination set checking for MeNB initiated SgNB modification by intra ENB HO
    [Tags]
    [Setup]    Delta Commission And Test Setup    ${delta_for_case_A-f_01_01_cell3_10M}
    UE attach to cell1 with Band 41 B1 Activated    ue=9
    Start traffic And No CA configured    ue=9
    UE Trigger B1 ENDC With Gnb8 Cell1 And No CA Configured    ue=9
    UE HO to Cell2 And No CA Configured    ue=9

LTE5515-A-f_ET_04_01_Scell addition due to MeNB initiated SgNB modification by intra ENB HO
    [Tags]
    [Setup]    Delta Commission And Test Setup     ${delta_for_case_A-f_04_01_cell3_20M}
    UE attach to cell1 with Band 41 B1 Activated    ue=10
    Start traffic And No CA configured    ue=10
    UE Trigger B1 ENDC With Gnb8 Cell1 And No CA Configured    ue=10
    UE HO to Cell2 And 2CC configurded    ue=10

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=10    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create Enb Alias    GNB_8    enb_id=8    id_type=wts
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Perform Steps After Onair
    @{lnadjgnb7}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.11    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}
    @{lnadjgnb8}    Create List    LNADJGNB:cPlaneIpAddr=10.0.1.12    LNADJGNB:x2ToGnbLinkStatus=available
    Object Should Exist    ${lnadjgnb7}

Modify Yaml
    # update UE1~UE3, qci6 as default QCI
    Update Yaml    UEs/bearer_sets/bearer_set_1/1    qci: 6
    Update Yaml    UEs/bearer_sets/bearer_set_1/7    qci: 8
    FOR    ${ue}    IN RANGE    1    4
     Update Yaml    UEs/UE_sets/${ue}    bearer: bearer_set_1    release: 15    nea: null    nia: null
    END
    # update UE4~UE10, qci8 as default QCI
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, pdn: 1}
    ...      - {qci: 2, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144, pdn: 1}
    ...      - {qci: 3, gbr_ul: 64, gbr_dl: 128, mbr_ul: 64, mbr_dl: 128, pdn: 1}
    ...      - {qci: 4, gbr_ul: 32, gbr_dl: 330, mbr_ul: 32, mbr_dl: 320, pdn: 1}
    ...      - {qci: 5, pdn: 1}
    ...      - {qci: 6, pdn: 1}
    ...      - {qci: 7, pdn: 1}
    ...      - {qci: 9, pdn: 1}
    ...      - {qci: 8, default: on, pdn: 2, trf_type: external}
    ...      - {qci: 6, pdn: 2}
    ...      - {qci: 7, pdn: 2}
    ...      - {qci: 9, pdn: 2}
    FOR    ${ue}    IN RANGE    4    11
     Update Yaml    UEs/UE_sets/${ue}     bearer: bearer_set_2    release: 15    nea: null    nia: null
    END
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x501', nr_arfcn: '630000:630000',
    ...    meas_timing_carrier_freq: ${NRARFCN630000}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    ${GNB7_CELL2}    catenate    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x503', nr_arfcn: '636666:636666',
    ...    meas_timing_carrier_freq: ${NRARFCN636666}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    ${GNB8_CELL1}    catenate    - {id: 81, technology: nr , tac: 33, pci: '1:0', nrci: '0x502', nr_arfcn: '524100:524100',
    ...    meas_timing_carrier_freq: ${NRARFCN524100}, ssb_subcarrier_spacing: kHz15,
    ...    ssb_mtc_periodicity_and_offset: 'sf5:1', ssb_mtc_duration: 'sf1'}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...    gnb_id: '0x00007'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.11
    ...    x2u: 10.0.1.13
    ...    x2_peers: none
    ...    cells:
    ...    ${GNB7_CELL1}
    ...    ${GNB7_CELL2}
    Add Yaml    BASE_STATIONS
    ...    - id: 8
    ...    gnb_id: '0x00008'
    ...    type: simulated
    ...    plmn: '262:03'
    ...    s1u: 10.0.1.12
    ...    x2_peers: none
    ...    cells:
    ...    ${GNB8_CELL1}

Delta Commission And Test Setup
    [Arguments]    ${delta_params}
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters And Wait Cells Onair    ${delta_params}
    # restart EMIL, enb ttitrace and cus pcap because they will be stopped if cells restarted
    Start To Capture Emil Log    ${PARAMS_IN_EMIL}
    start_to_capture_enb_ttitrace
    Start To Capture CUS PCAP
    Set ue parameters before attach

Local Test Teardown And Recover Env
    [Arguments]    ${param}
    Delta Commission Parameters And Wait Cells Onair    ${param}
    Common Test Teardown And Stop Capture Logs

Set ue parameters before attach
    Execute Uex Command    ue_param id=1-11 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=41,78
    Execute Uex Command    ue_cqi_param id=5-8 scell=0-1 rank=4 ri_i1=18
    Execute Uex Command    ue_cqi_param id=9-10 scell=0-2 rank=4 cell=both
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=8 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms T_DC_Overall=5000ms

UE attach to cell1 with Band 78 F2 B1 Activated
    [Arguments]    ${ue}    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}
    ${band78_f2_B1}    catenate
    ...    measObjectNR-r15 contains (carrierFreq-r15 eq ${NRARFCN636666})
    ...    and eventB1-NR-r15 is present
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${band78_f2_B1})
    ...    alias=attach_flow    overall_timeout=20
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    attach_flow

UE attach to cell1 with Band 41 B1 Activated
    [Arguments]    ${ue}    ${ue_nr_capabilities}=${ue_nr_capabilities_A}
    ...    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities_A}
    ...    ${ue_eutra_capabilities}=${ue_eutra_capabilities_A}
    ${band41_B1}    catenate
    ...    measObjectNR-r15 contains (carrierFreq-r15 eq ${NRARFCN524100})
    ...    and eventB1-NR-r15 is present
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${band41_B1})
    ...    alias=attach_flow    overall_timeout=20
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=1 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    attach_flow

Start traffic And No CA configured
    [Arguments]    ${ue}=1
    # no ca configured due to not support band38+band41 ca in ue capability
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (sCellIndex-r10 is present)
    ...    alias=ca_flow    overall_timeout=30
    Execute Uex Command    trf_data_start ue=${ue} Mbps=150 dir=dl protocol=udp
    Flow Not Occurred For Message    alias=ca_flow

UE Trigger B1 ENDC With Gnb8 Cell1 And No CA Configured
    [Arguments]    ${ue}=1
    ${DC_38A_n41A_BSC0}    Set Variable    5:1
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=${DC_38A_n41A_BSC0}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_8:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=b1_flow    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (sCellIndex-r10 is present)
    ...    alias=ca_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue} event=B1_NR phycell_id=3 nrsrp=70
    Flow Occurred As Expected    alias=b1_flow
    Flow Not Occurred For Message    alias=ca_flow

Report A2 To Activate IFa3
    [Arguments]    ${ue}
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (a3-Offset is present)
    ...    alias=interf_a3_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue} event=A2 srsrp=50
    Flow Occurred As Expected    alias=interf_a3_flow

UE HO to Cell2 And No CA Configured
    [Arguments]    ${ue}
    Report A2 To Activate IFa3    ${ue}
    ${DC_41C_N41A_BSC1}    Set Variable    4:1    # only support 20M+20M, no CA
    Expect Message Flow
    # in cell1 side
    ...    ENB_1:X2AP_SgNBModificationRequest (allowedBC-ListMRDC contains (bandCombinationIndex eq 4 and allowedFeatureSetsList contains (1)))
    ...    GNB_8:X2AP_SgNBModificationRequestAcknowledge (selectedBandCombination contains (bandCombinationIndex eq 4 and requestedFeatureSets eq 1))
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (targetPhysCellId eq 2)
    # in cell2 side
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    alias=ho_flow    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (sCellIndex-r10 is present)
    ...    alias=ca_flow    overall_timeout=30
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=${DC_41C_N41A_BSC1}
    Execute Uex Command    ue_measurement_send id=${ue} event=A3 phycell_id=2 nrsrp=90 nrsrq=34 srsrp=60
    Flow Occurred As Expected    alias=ho_flow
    Flow Not Occurred For Message    alias=ca_flow

UE HO to Cell2 And 2CC configurded
    [Arguments]    ${ue}
    Report A2 To Activate IFa3    ${ue}
    ${DC_41C_N41A_BSC1}    Set Variable    4:1    # support 20M+20M, 2cc
    ${2cc_cell2_cell3}    Set Variable    sCellIndex-r10 eq 1 and physCellId-r10 eq 3
    Expect Message Flow
    # in cell1 side
    ...    ENB_1:X2AP_SgNBModificationRequest (allowedBC-ListMRDC contains (bandCombinationIndex eq 4 and allowedFeatureSetsList contains (1)))
    ...    GNB_8:X2AP_SgNBModificationRequestAcknowledge (selectedBandCombination contains (bandCombinationIndex eq 4 and requestedFeatureSets eq 1))
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (targetPhysCellId eq 2)
    # in cell2 side
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${2cc_cell2_cell3})
    ...    alias=ho_flow    overall_timeout=20
    Execute Egate Command    gnb_endc_param id=8 selected_band_combination_nr=${DC_41C_N41A_BSC1}
    Execute Uex Command    ue_measurement_send id=${ue} event=A3 phycell_id=2 nrsrp=90 nrsrq=34 srsrp=60
    Flow Occurred As Expected    alias=ho_flow

Start Traffic and ENDC and Check PS
    [Arguments]    ${ue}    ${selected_bc}    ${pc_in_sgnbadd}    ${pc_in_rrcconf}
    Execute Uex Command    trf_data_start ue=${ue} Mbps=100 dir=dl protocol=udp trf_id=1
    Get Throughput    ${ue}
    Execute Uex Command    trf_data_start ue=${ue} Mbps=130 dir=dl protocol=udp trf_id=2
    Get Throughput    ${ue}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest (${pc_in_sgnbadd})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${pc_in_rrcconf})
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=b1_flow    overall_timeout=20
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${selected_bc}
    Execute Uex Command    ue_measurement_send id=${ue} event=B1_NR phycell_id=1 nrsrp=70
    Flow Occurred As Expected    alias=b1_flow

Part DPS configurated UE trigger ENDC with PC3 minus powerOffset
    [Arguments]    ${ue}
    UE attach to cell2 with Band 78 F1 B1 Activated    ${ue}    ${ue_nr_capabilities_C}    ${ue_eutra_nr_capabilities_C_1}
    ...    ${ue_eutra_capabilities_C}
    ${DC_41A_n78A_PC3}    Set Variable    1:1    # PC3, no dynamicPowerSharing
    ${pc_in_sgnbadd}    Set Variable    powerCoordination-FR1 contains (p-maxNR-FR1 eq 16 and p-maxEUTRA eq 22)
    ${pc_in_rrcconf}    Set Variable    sCellIndex-r10 is not present and p-MaxEUTRA-r15 eq 22
    Start Traffic and ENDC and Check PS    ${ue}    ${DC_41A_n78A_PC3}    ${pc_in_sgnbadd}    ${pc_in_rrcconf}

All DPS configurated UE trigger ENDC and no powerCoordination
    [Arguments]    ${ue}
    UE attach to cell2 with Band 78 F1 B1 Activated    ${ue}    ${ue_nr_capabilities_C}    ${ue_eutra_nr_capabilities_C_2}
    ...    ${ue_eutra_capabilities_C}
    ${selected_bc}    Set Variable    1:1
    ${pc_in_sgnbadd}    Set Variable    powerCoordination-FR1 is not present
    ${pc_in_rrcconf}    Set Variable    sCellIndex-r10 is not present and p-MaxEUTRA-r15 is not present
    Start Traffic and ENDC and Check PS    ${ue}    ${selected_bc}    ${pc_in_sgnbadd}    ${pc_in_rrcconf}

UE trigger ENDC and no powerCoordination
    [Arguments]    ${ue}
    UE attach to cell2 with Band 78 F1 B1 Activated    ${ue}    ${ue_nr_capabilities_C}    ${ue_eutra_nr_capabilities_C_3}
    ...    ${ue_eutra_capabilities_C}
    ${selected_bc}    Set Variable    1:1
    ${pc_in_sgnbadd}    Set Variable    powerCoordination-FR1 is not present
    ${pc_in_rrcconf}    Set Variable    sCellIndex-r10 is not present and p-MaxEUTRA-r15 is not present
    Start Traffic and ENDC and Check PS    ${ue}    ${selected_bc}    ${pc_in_sgnbadd}    ${pc_in_rrcconf}

UE setup ENDC with PC3 minus powerOffset
    [Arguments]    ${ue}
    UE attach to cell2 with Band 78 F1 B1 Activated    ${ue}    ${ue_nr_capabilities_C}    ${ue_eutra_nr_capabilities_C_3}
    ...    ${ue_eutra_capabilities_C}
    ${DC_41A_n78A_PC3}    Set Variable    1:1    # PC3 when lack of powerClass-v1530: pc2
    ${pc_in_sgnbadd}    Set Variable    powerCoordination-FR1 contains (p-maxNR-FR1 eq 21 and p-maxEUTRA eq 18)
    ${pc_in_rrcconf}    Set Variable    sCellIndex-r10 is not present and p-MaxEUTRA-r15 eq 18
    Start Traffic and ENDC and Check PS    ${ue}    ${DC_41A_n78A_PC3}    ${pc_in_sgnbadd}    ${pc_in_rrcconf}


UE Handover From Cell2 To Cell1 And p-maxNR-FR1 26 p-MaxEUTRA 26
    [Arguments]    ${ue}
    Report A2 To Activate IFa3    ${ue}
    ${2cc}    Set Variable    sCellIndex-r10 eq 1    # 2CC: cell1+cell2 or cell1+cell3
    Expect Message Flow
    # in cell2 side
    ...    ENB_1:X2AP_SgNBModificationRequest (powerCoordination-FR1 contains (p-maxNR-FR1 eq 26 and p-MaxEUTRA-r15 is not present))
    ...    GNB_7:X2AP_SgNBModificationRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (targetPhysCellId eq 1 and p-MaxEUTRA-r15 eq 26)
    # in cell1 side
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${2cc})
    ...    alias=ho_flow    overall_timeout=20
    ${DC_41C_41A_n78A}    Set Variable    6:1    # DPS for LTE5515-C-c_ET_04, SPS for LTE5515-C-c_ET_01
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${DC_41C_41A_n78A}
    Execute Uex Command    ue_measurement_send id=${ue} event=A3 phycell_id=1 nrsrp=95 nrsrq=34 srsrp=50
    Flow Occurred As Expected    alias=ho_flow

UE Handover From Cell2 To Cell1 with PC3 minus powerOffset
    [Arguments]    ${ue}
    Report A2 To Activate IFa3    ${ue}
    ${2cc}    Set Variable    sCellIndex-r10 eq 1    # 2CC: cell1+cell2 or cell1+cell3
    Expect Message Flow
    # in cell2 side
    ...    ENB_1:X2AP_SgNBModificationRequest (powerCoordination-FR1 contains (p-maxNR-FR1 eq 21 and p-maxEUTRA eq 18))
    ...    GNB_7:X2AP_SgNBModificationRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (targetPhysCellId eq 1 and p-MaxEUTRA-r15 eq 18)
    # in cell1 side
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${2cc})
    ...    alias=ho_flow    overall_timeout=20
    ${DC_41C_41A_n78A_PC3}    Set Variable    6:1
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${DC_41C_41A_n78A_PC3}
    Execute Uex Command    ue_measurement_send id=${ue} event=A3 phycell_id=1 nrsrp=95 nrsrq=34 srsrp=50
    Flow Occurred As Expected    alias=ho_flow

UE attach to cell2 with Band 78 F1 B1 Activated
    [Arguments]    ${ue}    ${ue_nr_capabilities}    ${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}
    ${band78_B1}    catenate
    ...    measObjectNR-r15 contains (carrierFreq-r15 eq ${NRARFCN630000})
    ...    and eventB1-NR-r15 is present
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${band78_B1})
    ...    alias=attach_flow    overall_timeout=20
    ${attach_cmd}    catenate
    ...    ue_attach id=${ue} cell=2 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Execute Uex Command    ${attach_cmd}
    Flow Occurred As Expected    attach_flow

Attach 3 UEs With Different Capabilities
    [Arguments]    ${ue1}=1    ${ue2}=2    ${ue3}=3
    UE attach to cell1 with Band 78 F2 B1 Activated    ${ue1}    ${ue_nr_capabilities_F}    ${ue_eutra_nr_capabilities_F_3CC}
    ...    ${ue_eutra_capabilities_F_3CC}
    UE attach to cell1 with Band 78 F2 B1 Activated    ${ue2}    ${ue_nr_capabilities_F}    ${ue_eutra_nr_capabilities_F_2CC}
    ...    ${ue_eutra_capabilities_F_3CC}
    UE attach to cell1 with Band 78 F2 B1 Activated    ${ue3}    ${ue_nr_capabilities_F}    ${ue_eutra_nr_capabilities_F_1CC}
    ...    ${ue_eutra_capabilities_F_2CC}

Start traffic To Trigger 3CC CA
    [Arguments]    ${ue}
    ${3cc}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2 and physCellId-r10 eq 3,
    ...    sCellIndex-r10 eq 1 and physCellId-r10 eq 2)
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${3cc})
    ...    alias=3cc_flow    overall_timeout=20
    Execute Uex Command    trf_data_start ue=${ue} Mbps=150 dir=dl protocol=udp
    Flow Occurred As Expected    alias=3cc_flow

Start traffic To Trigger 2CC CA
    [Arguments]    ${ue}
    ${2cc}    catenate
    ...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1 and physCellId-r10 eq 2)
    ...    and length(sCellToAddModList-r10) eq 1
    Expect Message Flow
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${2cc})
    ...    alias=2cc_flow    overall_timeout=20
    ${ret}    Execute Uex Command    trf_data_start ue=${ue} Mbps=150 dir=dl protocol=udp
    Flow Occurred As Expected    alias=2cc_flow

Trigger ENDC And CA changed
    [Arguments]    ${ue}    ${selected_bc}    ${ca_conf}
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${selected_bc}
    Expect Message Flow
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${ca_conf})
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBReconfigurationComplete
    ...    ENB_1:X2AP_SNStatusTransfer
    ...    MME_1:S1AP_E-RABModificationIndication
    ...    MME_1:S1AP_E-RABModificationConfirm
    ...    alias=b1_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue} event=B1_NR phycell_id=2 nrsrp=60
    Flow Occurred As Expected    alias=b1_flow

Trigger ENDC And CA Changed From 3CC to 3CC
    [Arguments]    ${ue}
    ${DC_41D_n78A_BCS0}    Set Variable    3:1    # 20M+15M+10M supported, 3cc configured
    ${3cc}    Catenate    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2, sCellIndex-r10 eq 1)
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_41D_n78A_BCS0}    ca_conf=${3cc}

Trigger ENDC And CA Changed From 3CC to 2CC
    [Arguments]    ${ue}
    ${DC_41C_n78A_BCS0}    Set Variable    3:1    # both 20M+15M and 20M+10M supported, select 20M+15M for 2cc
    ${3cc_to_2cc}    catenate
    ...    sCellToReleaseList-r10 contains (2)
    ...    and sCellToAddModList-r10 contains (sCellIndex-r10 eq 1)
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_41C_n78A_BCS0}    ca_conf=${3cc_to_2cc}

Trigger ENDC And CA Changed From 2CC to 1CC
    [Arguments]    ${ue}
    ${DC_41A_n78A}    Set Variable    3:1
    ${2cc_to_1cc}    Catenate    sCellToReleaseList-r10 contains (1) and sCellToAddModList-r10 is not present
    Trigger ENDC And CA changed    ue=${ue}    selected_bc=${DC_41A_n78A}    ca_conf=${2cc_to_1cc}

Trigger SgNB modification And CA changed
    [Arguments]    ${ue}    ${ca_conf}
    Expect Message Flow
    ...    GNB_7:X2AP_SgNBModificationRequired
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfiguration (${ca_conf})
    ...    UE_GROUP_${ue}:RRC_RRCConnectionReconfigurationComplete
    ...    ENB_1:X2AP_SgNBModificationConfirm
    ...    alias=dc_modify_flow    overall_timeout=20
    Execute Egate Command    enb_ue_dc_modify by=gnb ue=${ue} cause=RN_handover_desirable_for_radio_reasons
    ...    SgNBModificationRequired
    Flow Occurred As Expected    alias=dc_modify_flow

Trigger SgNB modification And All UEs Changed To 1CC
    [Arguments]    ${ue1}=1    ${ue2}=2    ${ue3}=3
    ${DC_41D_n41A_BSC0}    Set Variable    1:1    # only support 20M+20M+20M, all scell released
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=${DC_41D_n41A_BSC0}
    ${3cc_to_1cc}    Catenate    sCellToReleaseList-r10 contains (2, 1) and sCellToAddModList-r10 is not present
    ${2cc_to_1cc}    Catenate    sCellToReleaseList-r10 contains (1) and sCellToAddModList-r10 is not present
    ${still_1cc}    Catenate    sCellToReleaseList-r10 is not present and sCellToAddModList-r10 is not present
    Trigger SgNB modification And CA changed    ue=${ue1}    ca_conf=${3cc_to_1cc}
    Trigger SgNB modification And CA changed    ue=${ue2}    ca_conf=${2cc_to_1cc}
    Trigger SgNB modification And CA changed    ue=${ue3}    ca_conf=${still_1cc}

