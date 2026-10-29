*** Settings ***
Suite Setup       Common Suite Setup and Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               team-CN3ET    owner-tinan.huang    release-SBTS22R1
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TTITRACE_FLAG}  ${True}
${CUS_PCAP_FLAG}  ${True}
${CUS_PCAP_OPTIONS}   -c 1 --sch --phy --l2 --payload 1
@{PARAMS_IN_SCF}
...    @{CA}
...    @{EARFCN_BW}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{autopucch}
...    @{LTE4575}
...    @{pcellswap}
...    @{LTE4804}
...    @{LTE4549}
...    @{otherrelation}
...    @{PM_UE_FLAG}
...    @{handover}
...    @{LTE4281andLTE5348}
...    @{CB006882}
...    @{CB006804}
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:actTransmittedBelowGap=false
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=40
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=true
@{CA}
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    MNL-1/MNLENT-1/SYNC-1:manualFrameTimingAdjustment=0
...    MNL-1/MNLENT-1/SYNC-1/TIME-1:offsetAfter=100
...    MNL-1/MNLENT-1/SYNC-1/TIME-1:offsetBefore=99
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    delete:LNCEL:caPoolId
...    LNCEL:maxNumScells=3
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.31
...    delete:LNBTS-1/LNADJ-255
...    LNCEL-1/CAREL-1:scellPrio=3
...    LNBTS-1:actFlexCaMgmt=true
...    LNCEL:actCaArchEnhImp=off
...    LNCEL-1:actScellConfigForHiDemand=false
...    LNCEL-3:actScellConfigForHiDemand=false
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-1/CADPR-0:maxNumMimoLayerFdd=12
...    LNCEL-7/CAREL-1:lcrId=1
...    LNCEL-7/CAREL-1:lnBtsId=1
...    LNCEL-7/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-1:pcellSwapAllowed=allowed
...    delete:LNCEL-7/CAREL-1:beamformingInScellAllowed
...    delete:LNCEL-7/CAREL-2:beamformingInScellAllowed
...    LNCEL:dlCaMinPcellCqi=0
...    LNCEL:dlCaMinPcellCqiQci1=0
...    LNCEL:ulCaMinPcellSinr=0
...    LNCEL:ulCaMinPcellSinrQci1=0
...    LNCEL:actScellConfigForHiDemand=false
...    LNCEL:scellFastSchedulingSelect=normal
...    LNBTS-1:sCellDeactivationTimereNB=rf128
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:pucchF3Support2CC=true
...    LNCEL-1/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...    LNCEL-1:maxNumScells=4
...    LNCEL-1/LNCEL_TDD-0:preferredPucchFormatFor2CC=PF3
...    LNCEL-1/LNCEL_TDD-0:maxNum2CCUeWithPF3=20
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUeCpaPf1bCS=0
@{EARFCN_BW}
...    LNCEL-1/LNCEL_TDD-0:earfcn=40452
...    LNCEL-2/LNCEL_TDD-0:earfcn=40822
...    LNCEL-3/LNCEL_TDD-0:earfcn=40596
...    LNCEL-4/LNCEL_FDD-0:earfcnDL=66600
...    LNCEL-4/LNCEL_FDD-0:earfcnUL=132136
...    LNCEL-5/LNCEL_FDD-0:earfcnDL=66800
...    LNCEL-5/LNCEL_FDD-0:earfcnUL=132336
...    LNCEL-6/LNCEL_FDD-0:earfcnDL=67000
...    LNCEL-6/LNCEL_FDD-0:earfcnUL=132536
...    LNCEL-7/LNCEL_FDD-0:earfcnDL=8150
...    LNCEL-7/LNCEL_FDD-0:earfcnUL=26150
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
#Cell1/3 contiguous, Cell2 is not used by case
@{x2link}
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL-1/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-1/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-2/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-2/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-2/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-2/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-3/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-1/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-1/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-1/LNRELGNBCELL-3:nrCellId=115971
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-1/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-3:gnbIdLength=22
...    LNCEL-3/LNRELGNBCELL-3:lteNrDualConnectAllowed=allowed
...    LNCEL-3/LNRELGNBCELL-3:nrCellId=115971
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mcc=262
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mnc=3
...    LNCEL-3/LNRELGNBCELL-3:nrCgiPlmnId:mncLength=2
@{LTE4088}
...    LNBTS:actLteNrDualConnectivity=true
...    LNBTS:tLteNrDualConnectPrep=8000
...    LNCEL-1:defaultLnRelGnbCellId=1
...    LNCEL-2:defaultLnRelGnbCellId=1
...    LNCEL-3:defaultLnRelGnbCellId=1
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001
...    LNBTS:pdcpProf1001:snSizeDl=18bit
...    LNBTS:pdcpProf1001:snSizeUl=18bit
...    LNBTS:pdcpProf1001:statusRepReq=0
...    LNBTS:pdcpProf1001:tDiscard=300ms
@{autopucch}
...    LNCEL-1/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_TDD-0:actAutoPucchAlloc=true
...    LNCEL-4/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-5/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-6/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-7/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-8/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-9/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL-1/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL-2/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeRrHo=10
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:aPucchAddAUeTcHo=15
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrc=10
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:actLbPucchReg=true
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:lbPucchRPrId=1
...    LNCEL-3/LNCEL_TDD-0/APUCCH_TDD-0:selectPrachRegion=None
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL-4/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL-5/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL-6/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL-7/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL-8/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeRrHo=10
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchAddAUeTcHo=15
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumEmergencySessions=10
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrc=10
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchMinNumRrcNoDrb=5
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:aPucchSrPeriodUpperLimit=20
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:actLbPucchReg=false
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:lbPucchRPrId=1
...    LNCEL-9/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=None
@{LTE4193}
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS/LBPUCCHRPR-1:countdownPucchCompr=60min
...    LNBTS/LBPUCCHRPR-1:countdownPucchExp=1min
...    LNBTS/LBPUCCHRPR-1:rrcConnectedLowerThresh=10
...    LNBTS/LBPUCCHRPR-1:rrcConnectedUpperThresh=80
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
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
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:quantityConfigId=0
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${NRARFCN531198}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=41
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=56
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${NRARFCN630000}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=78
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=15kHz
@{LTE4575}
...    LNBTS:actCAggrLteNrDualConnectivity=blind_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
${ue_nr_capabilities_01}    CE00000001C8F5C0302800001939980000CC002000014000013400004E4C4000000C03000800000080
#CA: 41A_41A/41C_41A
${ue_eutra_capabilities_01}
...    SEPARATOR=
...    DD9FF440830008A0102E0B82EFC1BF335942004408020A540000A0CCBE7F83762697864045EFC1BB135646084308210C20843042182104100
...    6084300300304018200C10860060044208005A3EAA30A0107A020082D01041E808024B4041640B82E0B82E0B82E0B82E0B82E0B82E0B82E0B
...    82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0BBF14000066C843C3C3C5C23
...    F8B90F0F0F0F0F0F0F0F0F0F0E21E1E1E1C000117E0C00002040411019A000F9C78000810182030385898D8E0EA0FDFF12D6980642FF37A80
...    018036C9000020000104B9E03000012020309826850F01DFF00006FF80104215294000000C2001100008
#CA: 41C
${ue_eutra_capabilities_02}
...    SEPARATOR=
...    DD9FF440830008A0102E0B82EFC1BF335942004408020A540000A0CCBE7F83762697864045EFC1BB135646084308210C20843042182104100
...    6084300300304018200C10860060044208005A3EAA30A0003A020092C81705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C
...    1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C177E280000CD945E2F178787878B847F1721E1E1E1E
...    1E1E1E1E1E1E1C43C3C3C3800022FC18000040808220334001F38F000102030406070B131B1C1D41FBFE25AD340C85FE6843A80018036C900
...    0020000104B9E03000012021389826850F01DFF00006FF80104215294000000C2001100008
#CA: 25A_41D
${ue_eutra_capabilities_03}
...    SEPARATOR=
...    DD9FF450830008A0C0205C1705DF837E66B2840088100414A8000141997CFF06EC4D2F0C808BDF837626AC8C1086104218410860843042082
...    00C1086006006080304018210C00C008841000B47D54614060EC040105A02683B010041680820EC040105A02483D0100416808AC81705C170
...    5C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1
...    705C177E280000CD908787878B847F1721E1E1E1E1E1E1E1E1E1E1C43C3C3C3800022FC18000040808220334001F390000102030406070B13
...    1B1C1D41FBFE2518AD300C85FE6F50003006D9200004000020973C0700002404061304D0A018780EFF800037FC01021042A52800000184002
...    20001
#CA: 25A_41D/25A_41C
${ue_eutra_capabilities_04}
...    SEPARATOR=
...    DD9FF450830008A0C0205C1705DF837E66B2840088100414A8000141997CFF06EC4D2F0C808BDF837626AC8C1086104218410860843042082
...    00C1086006006080304018210C00C008841000B47D54614060EC040105A02683B010041680820EC040105A02483B0100416808AC81705C170
...    5C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1705C1
...    705C177E280000CD945229148A43C3C5C23F8B90F0F0F0F0F0F0F0F0F0F0E21E1E1E1C000117E0C00002040411019A000F9C8000081018203
...    0385898D8E0EA0FDFF128C56980642FF37A80018036C9000020000104B9E038000120203098268500C3C077FC0001BFE00810821529400000
...    0C20011000080
#MRDC: DC_41A*_n78A*(both)/DC_n41CA*(both)
${ue_eutra_nr_capabilities_01}
...    SEPARATOR=
...    C10060570B2800E2680000003F400000008201015006E165041C2800000207E80000001040202A0080400401802404D805002040002010100
...    2004200020080801002300008040002010000804040080108000802020040088000201000080404008010
#MRDC: DC_41A*_n78A*(contiguous)/DC_n41CA*(contiguous)
${ue_eutra_nr_capabilities_02}
...    SEPARATOR=
...    C10060570B2800E2680000003F400000000206E165041C2800000207E8000000004080400401802404D805002040002010100200420002008
...    0801002300008040002010000804040080108000802020040088000201000080404008010
#MRDC: DC_41A*_n78A*(non-contiguous)/DC_n41CA*(non-contiguous)
${ue_eutra_nr_capabilities_03}
...    SEPARATOR=
...    C10060570B2800E2680000003F400000008201014006E165041C2800000207E8000000104020280080400401802404D805002040002010100
...    2004200020080801002300008040002010000804040080108000802020040088000201000080404008010
#MRDC: DC_41A*_n78A*(contiguous)/DC_n41CA*(contiguous)/DC_41C*_n40A*(contiguous)
${ue_eutra_nr_capabilities_04}
...    SEPARATOR=
...    C10060770B2820E2680000003F4000000002048165041C280000000440B2820E138000000200A00803004809B00A013808100010040400801
...    0800080202004008C0002010000804000201010020042000200808010022000080400020101002004
#MRDC: DC_41A*_n78A*(non-contiguous)/DC_n41CA*(non-contiguous)/DC_41C*_n40A*(non-contiguous)
${ue_eutra_nr_capabilities_05}
...    SEPARATOR=
...    C10060770B2820E2680000003F4000000082010140048165041C280000010402028040B2820E138000008201014000800813804809B00A004
...    0800080202004008400040101002004600010080004020001008080100210001004040080110000402000100808010020
#MRDC: DC_41A*_n78A*(both)/DC_n41CA*(both)/DC_41C*_n40A*(both)
${ue_eutra_nr_capabilities_06}
...    SEPARATOR=
...    C10060770B2820E2680000003F4000000082010150048165041C28000001040202A040B2820E138000008201015000800813804809B00A004
...    0800080202004008400040101002004600010080004020001008080100210001004040080110000402000100808010020
#MRDC: DC_(n)41CA_N78A*(contiguous)
${ue_eutra_nr_capabilities_07}
...    SEPARATOR=
...    C1006037132820E2680060A0000007E8000000004080400401802404D805002080004010100200404008010800080202004008C0002010000
...    8040002010100200420002008080100220000804000201010020040
#MRDC: DC_25A_(n)41DA*(contiguous)
${ue_eutra_nr_capabilities_08}
...    SEPARATOR=
...    C10060371318004507C2800000007E8000000004080500401802404D805006004100004020002008080100210001004040080118000402000
...    1008000402020040084000401010020044000100800040202004008
#MRDC: DC_(n)41DA_n78A*(non-contiguous)
${ue_eutra_nr_capabilities_09}
...    SEPARATOR=
...    C1006037132830C1401C4D00000007E8000000104020280080500401802404D80500600410000802020040080801002100010040400801180
...    004020001008000402020040084000401010020044000100800040202004008
#MRDC: DC_25A_(n)41CA_n41A* contiguous
${ue_eutra_nr_capabilities_010}
...    SEPARATOR=
...    C10060371B18004505828038500000000FD0000000008100A00803004809B00A00C0083000080400040101002004040080108000802020040
...    08C0002010000804000201010020042000200808010022000080400020101002004
#MRDC: 25A_41C_n41A_n41A* non-contiguous
${ue_eutra_nr_capabilities_011}
...    SEPARATOR=
...    C10060371B18004505828038500000000FD0000000208040500100A00803004809B00A00C0083000080400040101002004040080108000802
...    02004008C0002010000804000201010020042000200808010022000080400020101002004
#MRDC: 25A_41D_n41A* (contiguous)
${ue_eutra_nr_capabilities_012}
...    SEPARATOR=
...    C10060371318004507C2800000007E8000000004080500401802404D805006004100004020002008080100210001004040080118000402000
...    1008000402020040084000401010020044000100800040202004008
@{pcellswap}
...    LNBTS:actPcellSwap=true
...    LNBTS:actIfHo=enabled
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=5|puschLoadIndexThr=0.01
...    LNCEL:loadSettings:cellCapClass=100
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=100
...    LNCEL-2:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...    LNCEL-3:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
...    LNCEL-7:pcellSwapConfig:numCaUeThreshold=10|puschLoadIndexThr=10
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference
@{PARAMS_IN_EMIL}
...    0x269D
...    0x269B
@{LTE4804}
...    LNBTS:actRCREnDc=RCR-servingCell
@{otherrelation}
...    LNCEL:mbrSelector=ueCapability
...    LNBTS-1:endcSchedWeightBoostDl=2
...    LNBTS-1:endcSchedWeightBoostUl=2
...    LNBTS-1:nrRestrictionOverride=disabled
...    LNCEL-1:filterCoeff=fc5
...    LNCEL-2:filterCoeff=fc5
...    LNBTS-1:actEndcSpidFwd=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    delete:LNCEL-1/MBSFNCEL-0
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNCEL-1/LNCEL_TDD-0:measGapPattern=gap0
...    LNCEL-2/LNCEL_TDD-0:measGapPattern=gap0
...    LNCEL-3/LNCEL_TDD-0:measGapPattern=gap0
...    LNCEL-1/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...    LNCEL-2/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...    LNCEL-3/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...    LNCEL-1/LNCEL_TDD-0:tddFrameConf=1
...    LNCEL-2/LNCEL_TDD-0:tddFrameConf=1
...    LNCEL-3/LNCEL_TDD-0:tddFrameConf=1
@{PM_UE_FLAG}
...    LNBTS/PMRNL-1:mtUEQuantity=15min
@{handover}
...    LNCEL:enableBetterCellHo=true
...    LNCEL:enableCovHo=true
...    LNBTS:actLTES1Ho=true
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1400
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:removeAllowed=false
...    LNCEL-2/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=2
...    LNCEL-2/LNREL-3:ecgiLcrId=1
...    LNCEL-2/LNREL-3:removeAllowed=false
...    LNCEL-2/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
@{LTE4281andLTE5348}
...    LNBTS:actHoWoSnChg=intraEnbAndX2HoEnabled
@{CB006882}
...    LNBTS:actEndcAdjCarrierChk=eNBConfig_PCellAndSCellContiguity
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=526199|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=50 MHz|ssbFreqNrCell=524128
@{CB006804}
...    LNBTS:actEnDcDssCellsCoex=disabled
@{PARAMS_IN_EMIL}
...    0x21ab
...    0x21b4
@{cleanup}
...    delete:LNBTS/NRDCDPR-0:frequencyConfigNrList
...    LNBTS:actEndcAdjCarrierChk=disabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=1
@{modify_frequencyConfigNrList_01}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=509241|ssbFreqNrCell=524128
@{recover_env_for_case3}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=526199|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=50 MHz|ssbFreqNrCell=524128
...    LNCEL-1/LNCEL_TDD-0:earfcn=40452
...    LNCEL-2/LNCEL_TDD-0:earfcn=40822
...    LNCEL-3/LNCEL_TDD-0:earfcn=40596
...    LNCEL-1/LNCEL_TDD-0:chBw=10 MHz
...    LNCEL-2/LNCEL_TDD-0:chBw=10 MHz
@{delte_NRCell3_LNREGNBCELL}
...    delete:LNCEL-1/LNRELGNBCELL-3
...    delete:LNCEL-3/LNRELGNBCELL-3
@{change_earfcn_for_case10}
...    LNCEL-1/LNCEL_TDD-0:chBw=10 MHz
...    LNCEL-2/LNCEL_TDD-0:chBw=15 MHz
...    LNCEL-1/LNCEL_TDD-0:earfcn=40452
...    LNCEL-2/LNCEL_TDD-0:earfcn=40572
...    LNCEL-3/LNCEL_TDD-0:earfcn=40743
@{prepare_env_for_case10}
...    LNCEL-7/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-7/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-7/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-7/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-7/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-7/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-7/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-7/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-7/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL-7/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-7/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-7/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-7/CAREL-1:lcrId=1
...    LNCEL-7/CAREL-1:lnBtsId=1
...    LNCEL-7/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-7/CAREL-2:lcrId=3
...    LNCEL-7/CAREL-2:lnBtsId=1
...    LNCEL-7/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-7/CAREL-3:lcrId=2
...    LNCEL-7/CAREL-3:lnBtsId=1
...    LNCEL-7/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-7:maxNumScells=4
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=526239|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=100 MHz|ssbFreqNrCell=524128
@{modify_frequencyConfigNrList_05}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=529100|ssbFreqNrCell=524128
@{recover_env_for_case12}
...    LNCEL-2/LNCEL_TDD-0:chBw=10 MHz
...    delete:LNCEL-7/LNRELGNBCELL-1
...    delete:LNCEL-7/LNRELGNBCELL-2
...    delete:LNCEL-7/CAREL-1
...    delete:LNCEL-7/CAREL-2
...    delete:LNCEL-7/CAREL-3
@{change_earfcn_for_case15}
...    LNCEL-1/LNCEL_TDD-0:earfcn=40452
...    LNCEL-2/LNCEL_TDD-0:earfcn=40572
...    LNCEL-3/LNCEL_TDD-0:earfcn=40743
...    LNCEL-3/LNCEL_TDD-0:chBw=20 MHz
...    LNCEL-2/LNCEL_TDD-0:chBw=15 MHz
...    LNCEL-1/LNCEL_TDD-0:chBw=10 MHz
@{prepare_env_for_case15}
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNBTS-1/LNBTS_FDD-0:numTxWithHighNonGbr=0
...    LNCEL-7/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL-7/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL-7/LNRELGNBCELL-1:nrCellId=115969
...    LNCEL-7/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL-7/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL-7/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2
...    LNCEL-7/LNRELGNBCELL-2:gnbIdLength=22
...    LNCEL-7/LNRELGNBCELL-2:lteNrDualConnectAllowed=allowed
...    LNCEL-7/LNRELGNBCELL-2:nrCellId=115970
...    LNCEL-7/LNRELGNBCELL-2:nrCgiPlmnId:mcc=262
...    LNCEL-7/LNRELGNBCELL-2:nrCgiPlmnId:mnc=3
...    LNCEL-7/LNRELGNBCELL-2:nrCgiPlmnId:mncLength=2
...    LNCEL-7:defaultLnRelGnbCellId=1
...    LNCEL-7/CAREL-1:lcrId=1
...    LNCEL-7/CAREL-1:lnBtsId=1
...    LNCEL-7/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-7/CAREL-2:lcrId=3
...    LNCEL-7/CAREL-2:lnBtsId=1
...    LNCEL-7/CAREL-2:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-7/CAREL-3:lcrId=2
...    LNCEL-7/CAREL-3:lnBtsId=1
...    LNCEL-7/CAREL-3:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-7/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-7:maxNumScells=4
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=521241|ssbFreqNrCell=524128
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:chBwDlNrCell=50 MHz|ssbFreqNrCell=524128
@{modify_frequencyConfigNrList_07}
...    LNBTS/NRDCDPR-0:frequencyConfigNrList:carrierCenterFreqNr=524139|ssbFreqNrCell=524128
${PM_SPEED_UP_FLAG}    ${True}
${SCELL_REL_ATT_IA_BAND_ENDC}    M8080C150
@{pm_counters_case10}
...    LNCEL-7:${SCELL_REL_ATT_IA_BAND_ENDC}=2
@{pm_counters_case15}
...    LNCEL-7:${SCELL_REL_ATT_IA_BAND_ENDC}=1
${scell1setup}
...    sCellToAddModList-r10 contains (
...    sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 40822)
${scell2setup}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2 and
...    physCellId-r10 eq 3 and
...    dl-CarrierFreq-r10 eq 40596)
${ENDCsetupandScellRelease}
...    measIdToRemoveList contains (17,18) and
...    sCellToReleaseList-r10 contains (1) and
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2)
${sgnbaddition}
...    allowedBC-ListMRDC contains (bandCombinationIndex eq 1, bandCombinationIndex eq 2)
${sgnbadditionack}
...    selectedBandCombination contains (bandCombinationIndex eq 2 and requestedFeatureSets eq 1)
${sgnbaddition2}
...    allowedBC-ListMRDC contains (bandCombinationIndex eq 1)
${sgnbadditionack2}
...    selectedBandCombination contains (bandCombinationIndex eq 1)
${addscell_40743}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 3 and
...    dl-CarrierFreq-r10 eq 40743)
${addscell_40572}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 40572)
${addscell_40452}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 3 and
...    physCellId-r10 eq 1 and
...    dl-CarrierFreq-r10 eq 40452)
${blind3scell}
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 1 and
...    physCellId-r10 eq 3 and
...    dl-CarrierFreq-r10 eq 40743) and
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 2 and
...    physCellId-r10 eq 2 and
...    dl-CarrierFreq-r10 eq 40572) and
...    sCellToAddModList-r10 contains (sCellIndex-r10 eq 3 and
...    physCellId-r10 eq 1 and
...    dl-CarrierFreq-r10 eq 40452)
*** Test Cases ***
CB006882-SR-A-B2_ET_03_01_ENDC setup with centre freq not divisible by 100kHz or 30kHz or 15kHz with intra-band pcell scell and pscell
    [Tags]
    Set ue parameters before ENDC setup
    clean up to commition
    onlinechange    delta_para=${recover_env_for_case3}
    Cells Should Be onAir
    ENDC Band combination selector    bc_id=2
    First Sanity check bypassed and ENDC setup successful
    onlinechange    delta_para=${modify_frequencyConfigNrList_01}
    First Sanity check bypassed and ENDC setup successful

CB006882-SR-A-B2_ET_10_01_ENDC setup with scell full release due to two scell failed contiguity sanity check with pscell
    [Tags]
    Set ue parameters before ENDC setup
    clean up to commition
    onlinechange    delta_para=${change_earfcn_for_case10}
    onlinechange    delta_para=${prepare_env_for_case10}
    Cells Should Be onAir
    Clear Counter Files
    ENDC setup successful with scell full release and scell addition after ENDC release
    Check Counters    ${pm_counters_case10}

#CB006882-SR-A-B2_ET_15_01_ENDC setup with onestep CA and blind ENDC and scell partial or full release
#    [Tags]
#    Set ue parameters before ENDC setup
#    onlinechange    delta_para=${recover_env_for_case12}
#    clean up to commition
#    onlinechange    delta_para=${change_earfcn_for_case15}
#    onlinechange    delta_para=${prepare_env_for_case15}
#    Cells Should Be onAir
#    UE attached with Blind ENDC and Scell is released

*** Keywords ***
Common Suite Setup and Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=6CELLs_FDD_3CELLs_TDD_2B38_41_3B4_66_3B2_25
    execute egate command    proxy_log GEN=debug
    execute egate command    trace_sim on mme=1 protocol=s1
    execute egate command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Create Alias

Set ue parameters before ENDC setup
    execute uex command    ue_param id=1-3 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=41
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0 include_reestablish_pdcp=on
    execute egate command    gnb_endc_param id=7 selected_band_combination_nr=1:1
    execute uex command    ue_cqi_param id=1-3 scell=0-2 rank=4 ri_i1=18 cell=both
    execute egate command    ue_enb_param id=1-3 ue_config_release_r9=rel15
    execute egate command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    execute egate command    enb_timer T_DC_Overall=5000ms

Create Alias
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create UE Alias    UE_2    ue_id=2    id_type=cus
    Create UE Alias    UE_3    ue_id=3    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    GNB_7    enb_id=7    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 71, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '524100:524100',
    ...    tdd_cell: yes}
    ${GNB7_CELL2}    catenate    - {id: 72, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '531198:531198',
    ...    tdd_cell: yes}
    ${GNB7_CELL3}    catenate    - {id: 73, technology: nr , tac: 33, pci: '1:0', nrci: '0x0000503', nr_arfcn: '630000:630000',
    ...    tdd_cell: yes}
    Add Yaml    BASE_STATIONS
    ...    - id: 7
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...         ${GNB7_CELL1}
    ...         ${GNB7_CELL2}
    add yaml    EPC
    ...    UEC:
    ...    - id: 1
    ...    peer_uplane: '10.0.2.11:2152'
    ...    gtpu: off

Start DL Data to trigger CA with 2Scells
    [Arguments]    ${ue_id}=1
    execute uex command    trf_data_start ue=${ue_id} qci=8 Mbps=120 dir=dl protocol=udp

Send B1-NR to trigger ENDC setup with scell1 release
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${meas_id_blacklist}=18
    execute uex command    ue_measurement_send id=${ue_id} event=B1_NR meas_id_blacklist=${meas_id_blacklist} srsrp=79 phycell_id=${cell_id} nrsrp=58

Send B1-NR to trigger ENDC setup with scell full release
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${meas_id_blacklist}=18
    execute uex command    ue_measurement_send id=${ue_id} event=B1_NR meas_id_blacklist=${meas_id_blacklist} srsrp=79 phycell_id=${cell_id} nrsrp=58

onlinechange
    [Arguments]    ${delta_para}
    Delta Commission Parameters    ${delta_para}

UE attach to cell
    [Arguments]    ${ue_id}=1    ${eutra_cap_id}=1    ${nr_eutra_cap_id}=1    ${nr_cap_id}=1    ${cellid}=1
    ${attach_command_1}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities_0${nr_cap_id}}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_0${nr_eutra_cap_id}} ue_eutra_capabilities=${ue_eutra_capabilities_0${eutra_cap_id}}
    ...    enb=1 cell=${cellid}
    execute uex command    ${attach_command_1}

Start DL Data to trigger CA with 3Scells
    [Arguments]    ${ue_id}=1
#    execute uex command    trf_data_start ue=1 qci=8 Mbps=20 dir=dl protocol=udp trf_id=1
    execute uex command    trf_data_start ue=1 qci=8 Mbps=300 dir=dl protocol=udp trf_id=2

UE detach all
    [Arguments]    ${ue_num}=1
    execute uex command    ue_detach id=1..${ue_num}

UE detach
    [Arguments]    ${ue_id}
    execute uex command    ue_detach id=${ue_id}

ENDC Band combination selector
    [Arguments]    ${bc_id}=1
    execute egate command    gnb_endc_param id=7 use_nr_ran_cont=true scg_dl_dist_percent=0
    execute egate command    gnb_endc_param id=7 include_reestablish_pdcp=on selected_band_combination_nr=${bc_id}:1

clean up to commition
    Delta Commission Parameters    ${cleanup}
    Cells Should Be OnAir
    Delta Commission Parameters    ${CB006882}
    Cells Should Be OnAir
    execute egate command    enb_timer T_SgnbAdditionReqAckDelay=0
    ${remove_pscell}    catenate    gnb_endc_param id=7 serv_cell_index=disabled extra_fr_infos=0 fr_type_pattern=fixed scell_frequencies_sn_nr=none
    execute egate command    ${remove_pscell}

ENDC release with Scells addition
    [Arguments]    ${ue_id}=1
    execute egate command    enb_ue_dc_release ue=${ue_id} by=gnb cause=RN_cell_not_available

UE attach with blind ENDC and scells are full released
    [Arguments]    ${ue_id}=1    ${eutra_cap_id}=1    ${nr_eutra_cap_id}=1    ${nr_cap_id}=1
    ${attach_command_2}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities_0${nr_cap_id}}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_0${nr_eutra_cap_id}} ue_eutra_capabilities=${ue_eutra_capabilities_0${eutra_cap_id}}
    ...    enb=1 cell=7
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${blind3scell})
    ...    ENB_1:X2AP_SgNBAdditionRequest
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (1,2,3))
    ...    alias=blindendcsetupand3scellrelease    overall_timeout=30
    execute uex command    ${attach_command_2}
    flow occurred as expected    alias=blindendcsetupand3scellrelease


UE attach with blind ENDC and scell1 is released
    [Arguments]    ${ue_id}=1    ${eutra_cap_id}=1    ${nr_eutra_cap_id}=1    ${nr_cap_id}=1
    ${attach_command_3}    catenate    ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities_0${nr_cap_id}}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities_0${nr_eutra_cap_id}} ue_eutra_capabilities=${ue_eutra_capabilities_0${eutra_cap_id}}
    ...    enb=1 cell=7
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${blind3scell})
    ...    ENB_1:X2AP_SgNBAdditionReques
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (1,2,3))
    ...    alias=blindendcsetupand3scellrelease_2    overall_timeout=30
    execute uex command    ${attach_command_3}
    flow occurred as expected    alias=blindendcsetupand3scellrelease_2

First Sanity check bypassed and ENDC setup successful
    UE attach to cell    ue_id=1    eutra_cap_id=1    nr_eutra_cap_id=1
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell1setup})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${scell2setup})
    ...    alias=add2scell    overall_timeout=30
    Start DL Data to trigger CA with 2Scells
    flow occurred as expected    alias=add2scell
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${ENDCsetupandScellRelease})
    ...    alias=endcsetupandscell1release    overall_timeout=30
    Send B1-NR to trigger ENDC setup with scell1 release    ue_id=1    cell_id=1    meas_id_blacklist=18
    flow occurred as expected    alias=endcsetupandscell1release
    UE attach to cell    ue_id=2    eutra_cap_id=1    nr_eutra_cap_id=2
    expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration(${scell1setup})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${scell2setup})
    ...    alias=ue2add2scell    overall_timeout=30
    Start DL Data to trigger CA with 2Scells    ue_id=2
    flow occurred as expected    alias=ue2add2scell
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${ENDCsetupandScellRelease})
    ...    alias=ue2endcsetupandscell1release    overall_timeout=30
    Send B1-NR to trigger ENDC setup with scell1 release    ue_id=2    cell_id=1    meas_id_blacklist=18
    flow occurred as expected    alias=ue2endcsetupandscell1release
    UE attach to cell    ue_id=3    eutra_cap_id=1    nr_eutra_cap_id=3
    expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration(${scell1setup})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${scell2setup})
    ...    alias=ue3add2scell    overall_timeout=30
    Start DL Data to trigger CA with 2Scells    ue_id=3
    flow occurred as expected    alias=ue3add2scell
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${ENDCsetupandScellRelease})
    ...    alias=ue3endcsetupandscell1release    overall_timeout=30
    Send B1-NR to trigger ENDC setup with scell1 release    ue_id=3    cell_id=1    meas_id_blacklist=18
    flow occurred as expected    alias=ue3endcsetupandscell1release
    UE detach all    ue_num=3

ENDC setup successful with scell full release and scell addition after ENDC release
    UE attach to cell    ue_id=1    eutra_cap_id=3    nr_eutra_cap_id=8    cellid=7
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40743})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40572})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40452})
    ...    alias=add3scell    overall_timeout=30
    Start DL Data to trigger CA with 3Scells
    FLOW OCCURRED AS EXPECTED    alias=add3scell
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition2})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack2})
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (1,2,3))
    ...    alias=endcsetupand3scellrelease    overall_timeout=30
    Send B1-NR to trigger ENDC setup with scell full release
    flow occurred as expected    endcsetupand3scellrelease
    onlinechange    delta_para=${modify_frequencyConfigNrList_05}
    execute uex command    ue_detach id=1
    UE attach to cell    ue_id=1    eutra_cap_id=3    nr_eutra_cap_id=8    cellid=7
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40743})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40572})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40452})
    ...    alias=add3scell_2    overall_timeout=30
    Start DL Data to trigger CA with 3Scells
    FLOW OCCURRED AS EXPECTED    alias=add3scell_2
    expect message flow
    ...    ENB_1:X2AP_SgNBAdditionRequest(${sgnbaddition2})
    ...    GNB_7:X2AP_SgNBAdditionRequestAcknowledge(${sgnbadditionack2})
    ...    UE_1:RRC_RRCConnectionReconfiguration(sCellToReleaseList-r10 contains (1,2,3))
    ...    alias=endcsetupand3scellrelease_2    overall_timeout=30
    Send B1-NR to trigger ENDC setup with scell full release
    flow occurred as expected    endcsetupand3scellrelease_2
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${addscell_40452})
    ...    alias=add3scell_3afterendcrelease    overall_timeout=30
    ENDC release with Scells addition
    flow occurred as expected    alias=add3scell_3afterendcrelease
    UE detach    ue_id=1

UE attached with Blind ENDC and Scell is released
    Clear Counter Files
    UE attach with blind ENDC and scells are full released    ue_id=1    eutra_cap_id=4    nr_eutra_cap_id=12
    Check Counters    ${pm_counters_case15}
    onlinechange    delta_para=${modify_frequencyConfigNrList_07}
    Clear Counter Files
    execute uex command    ue_detach id=1
    UE attach with blind ENDC and scell1 is released    ue_id=1    eutra_cap_id=4    nr_eutra_cap_id=12
    Check Counters    ${pm_counters_case15}
