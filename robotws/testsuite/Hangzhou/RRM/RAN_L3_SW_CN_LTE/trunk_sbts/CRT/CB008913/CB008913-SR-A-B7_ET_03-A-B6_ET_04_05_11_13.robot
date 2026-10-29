*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CLOUD_R4LAPO_CUS
...                 release-SBTS24R1    team-CN3ET    owner-zijing.wu
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
...    LNBTS:reportTimerIFSBA4=3000ms

@{PARAMS_IN_SCF}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCPR}
...    @{CA}
...    @{LTE4549}
...    @{NRDCDPR}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{CB008913}
...    @{HO_para}
...    @{X2_MOCs}

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

${flte1}    1400    #band3
${flte2}    1600    #band3
${flte3}    2870    #band7
${flte4}    3100    #band7

${fnr1}    188512    # nr band 8
${fnr2}    650048    # nr band 77
${fnr3}    2079200    # nr band 257

@{delta_for_caseB703}    #wuzijing
...    @{LTE4193}
...    LNCEL-1:actEndcHoPrefLay=true
...    LNCEL-3:actEndcHoPrefLay=false
...    LNCEL-1:actNrCovEndcHo=disabled
...    LNBTS:numB1CyclesWoEndc=1
...    LNBTS/MODPR-0:timeBlockEndcHoAtHoFromTrg=31
...    LNBTS/MOPR-1:timeBlockEndcHoAtHoFromTrg=31
...    delete:LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1
...    delete:LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=${flte1}
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte3}
...    delete:LNCEL-3/LNRELGNBCELL-3
...    delete:LNCEL-3/LNRELGNBCELL-1
...    delete:LNCEL-1/LNRELGNBCELL-2
...    LNBTS:blockEndcHoRetryAtHoFromTrg=both
...    LNCEL:iFEndcHoRetryTimer=30
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNCEL-3:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=3
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=3
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=2
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:ulCaMinPcellSinrQci1=0

@{delta_for_B613}    #wuzijing
...    @{LTE4193}
...    LNCEL:actEndcHoPrefLay=false
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-3:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS:numB1CyclesWoEndc=1
...    LNBTS/MODPR-0:timeBlockEndcHoAtHoFromTrg=160
...    LNBTS/MOPR-1:timeBlockEndcHoAtHoFromTrg=160
...    delete:LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1
...    delete:LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte1}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte3}
...    delete:LNCEL-1/LNRELGNBCELL-3
...    delete:LNCEL-1/LNRELGNBCELL-1
...    delete:LNCEL-3/LNRELGNBCELL-2
...    LNBTS:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNCEL:iFEndcHoRetryTimer=30
...    LNBTS:blockNrEndcHoAtHoFromTrg=EN-DC NR-coverage HO
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=3
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=3
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNCEL-3/CAREL-1:lnBtsId=1
...    LNCEL-3/CAREL-1:lcrId=2
...    LNCEL-3/CAREL-1:maxNumOfSuppMimoLayer=4-layer
...    LNCEL-3:ulCaMinPcellSinr=0
...    LNCEL-3:ulCaMinPcellSinrQci1=0

@{delta_for_B611}    #wuzijing
...    delete:LNCEL-3/LNREL-388
...    @{enable_LTE5003}
...    @{EUTRA_LB}
...    @{EUTRA_LE}
...    LNBTS:numB1CyclesWoEndc=2
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNCEL-3:actNrCovEndcHo=disabled
...    LNBTS:blockNrEndcHoAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MODPR-0:timeBlockEndcHoAtHoFromTrg=0
...    LNBTS/MOPR-1:timeBlockEndcHoAtHoFromTrg=0
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only
...    LNCEL:actInterFreqLB=false    #flag for LB
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=8
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=257
...    delete:LNBTS/CAGENB-0/CAIMLBP-1
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1

@{delta_for_B611_2}
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=allow LB and LE
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=allow LB and LE

@{delta_for_B65}
...    @{EUTRA_LB}
...    @{UTRA_LB}
...    LNCEL:actInterFreqLB=false    #flag for LB
...    @{enable_LTE5003}
...    LNBTS:numB1CyclesWoEndc=2
...    LNCEL-1:actEndcHoPrefLay=false    #CB007163
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=allow LB and LE
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=allow LB and LE
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
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte4}
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1NrMeasPurpose=EN-DC and EN-DC steering
...    LNCEL-3:actNrCovEndcHo=disabled
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1

@{delta_for_case_B6_04}
...    @{enable_LTE5003}
...    @{EUTRA_LB}
...    LNCEL:actInterFreqLB=true    #flag for LB
...    LNCEL-1/CAPR-1:earfcnDL=2870
...    LNCEL-1/CAREL-1:lcrId=3
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=allow LB retry
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=allow LB retry
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=${flte3}
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=77
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-1:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-2:nrcellConfigL:band=8
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${flte3}
...    LNCEL-3:actNrCovEndcHo=disabled
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased|lcrId=1


@{disable_LE}
...    LNCEL-1:actAmle=false    #LTE1841

@{disable_LB_UTRA}
...    LNBTS/LNBTS_FDD-0:actUtranLoadBal=false    #flag for LB: B1

@{disable_LB}
...    LNCEL:actInterFreqLB=false    #flag for LB

@{EUTRA_LB}
...    LNBTS/LNBTS_FDD-0:actDedFreqListsLB=inter-frequency
...    LNBTS/MODPR-0:freqLayListDedLteLB=${flte1},${flte2},${flte3},${flte4}
...    LNBTS/MOPR-1:freqLayListDedLteLB=${flte1},${flte2},${flte3},${flte4}
...    LNBTS:qciTab6:schedulWeight=100
...    LNCEL:iFLBA4ActLim=5
...    LNCEL:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadGBRDL=1
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=1
...    LNCEL:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL:iFLBLoadThresholds:iFLBRetryTimer=10    #10/2=5s
...    LNCEL:iFLBLoadThresholds:maxNumAmleNeigh=2
...    LNCEL:loadSettings:cellCapClass=1
...    LNCEL:loadSettings:mlbEicicOperMode=allUes
...    LNCEL:loadSettings:nomNumPrbNonGbr=10
...    LNCEL:loadSettings:targetLoadGbrDl=1
...    LNCEL:loadSettings:targetLoadNonGbrDl=1
...    LNCEL:loadSettings:targetLoadPdcch=1
...    LNCEL:loadSettings:ulCacIgnore=false
...    LNCEL:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL:loadSettings:ulStaticCac=0
...    LNCEL:intraFreqLbLoadThresholds:hysteresisLoadDlGbr=0
...    LNCEL:intraFreqLbLoadThresholds:hysteresisLoadDlNonGbr=0
...    LNCEL:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL:actServRlqInterFreqLB=false

@{EUTRA_LE}
...    LNCEL-1/LNREL-2:amleAllowed=true
...    LNCEL-1:actAmle=true    #LTE1841
...    LNCEL-1:amleMaxNumHo=10
...    LNCEL-1/AMLEPR-0:amlePrId=0
...    LNCEL-1/AMLEPR-0:cacHeadroom=0
...    LNCEL-1/AMLEPR-0:deltaCac=1
...    LNCEL-1/AMLEPR-0:maxCacThreshold=100
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=${flte3}
...    LNCEL-1/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${flte2}
...    LNCEL-1/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpIFLBFilter=-140
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=${flte3}
...    LNCEL-1/LNHOIF-2:thresholdRsrqIFLBFilter=-120
...    LNCEL-1/LNHOIF-3:thresholdRsrpIFLBFilter=-140
...    LNCEL-1/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-1/LNHOIF-3:thresholdRsrqIFLBFilter=-120
...    LNCEL-3/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-3/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-3/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:ecgiLcrId=1
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:removeAllowed=false
...    LNCEL-3/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-3/LNREL-2:amleAllowed=true
...    LNCEL-3:actAmle=true    #LTE1841
...    LNCEL-3:amleMaxNumHo=10
...    LNCEL-3/AMLEPR-0:amlePrId=0
...    LNCEL-3/AMLEPR-0:cacHeadroom=0
...    LNCEL-3/AMLEPR-0:deltaCac=1
...    LNCEL-3/AMLEPR-0:maxCacThreshold=100
...    LNCEL-3/AMLEPR-0:targetCarrierFreq=${flte1}
...    LNCEL-3/LNHOIF-1:thresholdRsrpIFLBFilter=-140
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=${flte2}
...    LNCEL-3/LNHOIF-1:thresholdRsrqIFLBFilter=-120
...    LNCEL-3/LNHOIF-2:thresholdRsrpIFLBFilter=-140
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=${flte1}
...    LNCEL-3/LNHOIF-2:thresholdRsrqIFLBFilter=-120
...    LNCEL-3/LNHOIF-3:thresholdRsrpIFLBFilter=-140
...    LNCEL-3/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-3/LNHOIF-3:thresholdRsrqIFLBFilter=-120

@{UTRA_LB}
...    LNCEL:actAmle=false
...    LNCEL-1:actInterFreqLB=false    #flag for LB disable LB A4
...    LNBTS/LNBTS_FDD-0:actDedFreqListsLB=all
...    LNBTS:actHOtoWcdma=true
...    LNBTS/LNBTS_FDD-0:actUtranLoadBal=true    #flag for LB: B1
...    LNBTS/MODPR-0:freqLayListPsHoWcdma=1300
...    LNBTS/MOPR-1:freqLayListPsHoWcdma=1300
...    LNBTS/MODPR-0:freqLayListDedWcdmaLB=1300
...    LNBTS/MOPR-1:freqLayListDedWcdmaLB=1300
...    LNBTS/LNBTS_FDD-0:preventPsHOtoWcdma=None
...    LNCEL-1:filterCoefficientCpichRscp=fc4
...    LNCEL-1:filterCoefficientCpichEcn0=fc4
...    LNCEL-1:measQuantityUtra=cpichRSCP
...    LNCEL-1/LNCEL_FDD-0:utranLbLoadThresholds:highLoadGbrDl=2
...    LNCEL-1/LNCEL_FDD-0:utranLbLoadThresholds:highLoadNonGbrDl=2
...    LNCEL-1/LNCEL_FDD-0:utranLbLoadThresholds:highLoadPdcch=2
...    LNCEL-2:filterCoefficientCpichRscp=fc4
...    LNCEL-2:filterCoefficientCpichEcn0=fc4
...    LNCEL-2:measQuantityUtra=cpichRSCP
...    LNCEL-2/LNCEL_FDD-0:utranLbLoadThresholds:highLoadGbrDl=2
...    LNCEL-2/LNCEL_FDD-0:utranLbLoadThresholds:highLoadNonGbrDl=2
...    LNCEL-2/LNCEL_FDD-0:utranLbLoadThresholds:highLoadPdcch=2
...    LNCEL-3:filterCoefficientCpichRscp=fc4
...    LNCEL-3:filterCoefficientCpichEcn0=fc4
...    LNCEL-3:measQuantityUtra=cpichRSCP
...    LNCEL-3/LNCEL_FDD-0:utranLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-3/LNCEL_FDD-0:utranLbLoadThresholds:highLoadNonGbrDl=85
...    LNCEL-3/LNCEL_FDD-0:utranLbLoadThresholds:highLoadPdcch=95
...    LNCEL-4:filterCoefficientCpichRscp=fc4
...    LNCEL-4:filterCoefficientCpichEcn0=fc4
...    LNCEL-4:measQuantityUtra=cpichRSCP
...    LNCEL-4/LNCEL_FDD-0:utranLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-4/LNCEL_FDD-0:utranLbLoadThresholds:highLoadNonGbrDl=85
...    LNCEL-4/LNCEL_FDD-0:utranLbLoadThresholds:highLoadPdcch=95
...    LNBTS/LNADJW-1:uTargetRncId=1
...    LNBTS/LNADJW-1:uTargetCid=1
...    LNBTS/LNADJW-1:uTargetFreq=1300
...    LNBTS/LNADJW-1:uTargetScFdd=41
...    LNCEL-1/LNHOW-1:utraCarrierFreq=1300
...    LNCEL-1/LNRELW-1:uTargetRncId=1
...    LNCEL-1/LNRELW-1:uTargetCid=1
...    LNCEL-1/LNRELW-1:psHoAllowed=allowed
...    LNCEL-1/LNRELW-1:utranLbAllowed=true
...    LNBTS/MODPR-0:allowLBHoToUtran=true
...    LNBTS/MOPR-1:allowLBHoToUtran=true

@{CB008913}
...    LNCEL-1:actNrCovEndcHo=ENDC NR-coverage HO
...    LNBTS:blockNrEndcHoAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=EndcHo only
...    LNBTS:numB1CyclesWoEndc=2
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
...    LNCEL-3/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=${flte1}
...    LNCEL-3/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=${flte2}
...    LNCEL-3/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-3/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL-3/LNHOIF-3:eutraCarrierInfo=${flte4}
...    LNCEL-3/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    @{freqLayEndcHoList_for_MOPR}
...    @{freqLayEndcHoList_for_MODPR}
...    @{add_moPrMapList}
...    @{CB008218}

@{freqLayEndcHoList_for_MODPR}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${flte3}

@{freqLayEndcHoList_for_MOPR}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${flte3}

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
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:quantityConfigId=0
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-0:ssbSubcarrierSpacing=15kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:carrierFreqNrCell=650048
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=77
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:nrCarPrio=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbOffset=2
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCPR-0/ENDCMEASCONF-1:ssbSubcarrierSpacing=30kHz

...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:carrierFreqNrCell=2079200
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=257
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:nrCarPrio=3
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrp=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:hysB1ThresholdRsrq=8
...    LNBTS/NRDCPR-0/ENDCMEASCONF-2:quantityConfigId=1
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=650048
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
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=2079200
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
...    LNCEL-1/CAREL-1:lcrId=3
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
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageBased
@{LTE4549}
...    LNBTS:actCAggrLteNrDualConnectivity=enhanced_CA_LTE_NR
...    LNBTS:enableBwCombCheck=true
...    LNBTS/NRDCDPR-0:cAggrLteNrDcCellList=-1
...    LNBTS/NRDCDPR-0:allowedBcSelectMethod=no preference


@{CB008218}
...    LNCEL:actPeriodicB1NRMeas=enhanced
...    LNBTS/NRMEASDPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASPR-0:supervisionTimerB1NR=10    #s
...    LNBTS/NRMEASDPR-0:retryTimerB1NR=30    #s
...    LNBTS/NRMEASPR-0:retryTimerB1NR=30    #s

@{HO_para}
#...    LNBTS-1:actHoWoSnChg=intraEnbAndX2HoEnabled
#...    LNBTS-1/MODPR-0:autoAdapt=true
...    LNBTS-1:actIfHo=enabled              
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-2/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-2/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-2/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:removeAllowed=false
...    LNCEL-2/LNREL-2:cellIndOffNeigh=0dB
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=${flte1}
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw50
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNBTS/MOPR-1:freqLayListLte=${flte1},${flte2},${flte3},${flte4}

@{enable_LTE5003}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased
...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased

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
${ue_eutra_nr_capabilities_b3+n77_b7+n8_b7+n257}    0108080260C01C07000E800000000058100713000000802200008040400801010020042000100808010020
${ue_eutra_nr_capabilities_b7+n77_b3+n8_b3+n257}    0108080260401C07000E800000000058300713000000802200008040400801010020042000100808010020
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
    ...    carrierFreq eq 2870)
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97) 
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToAddModList contains (
    ...    measId eq 3)
    ...    and measIdToRemoveList contains (17, 18, 19)

${B1_reactive}    SEPARATOR=
    ...    measIdToAddModList contains (
    ...    measId eq 17,
    ...    measId eq 18,
    ...    measId eq 19)

${B1_deactive_A5ofFlte1_active}    SEPARATOR=
    ...    measObjectToAddModList contains (carrierFreq eq 1400)
    ...    and measIdToRemoveList contains (17,18,19)
    ...    and measIdToAddModList contains (measId eq 3)

${B1_deactive_and_A5_active}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 1400)
    ...    and reportConfigToAddModList contains (
    ...    a5-Threshold1 contains (
    ...    threshold-RSRP eq 97)
    ...    and a5-Threshold2 contains (
    ...    threshold-RSRP eq 0))
    ...    and measIdToRemoveList contains (
    ...    17,
    ...    18,
    ...    19)
    ...    and measIdToAddModList contains ((
    ...    measId eq 3)
    ...    and (
    ...    measObjectId eq 5)
    ...    and (
    ...    reportConfigId eq 6))

${ENDC_A5_Flte3_active}    SEPARATOR=
    ...    measObjectToAddModList contains (
    ...    carrierFreq eq 2870)
    ...    and measIdToAddModList contains ((
    ...    measId eq 3)
    ...    and (
    ...    measObjectId eq 1)
    ...    and (
    ...    reportConfigId eq 6))

${HO_succ_tocell1}    SEPARATOR=
    ...    mobilityControlInfo contains (
    ...    targetPhysCellId eq 1
    ...    and carrierFreq contains (
    ...    dl-CarrierFreq eq ${flte1}))

${HO_succ_tocell3}    SEPARATOR=
    ...    mobilityControlInfo contains (
    ...    targetPhysCellId eq 3
    ...    and carrierFreq contains (
    ...    dl-CarrierFreq eq ${flte3}))

${A4_active_query}    SEPARATOR=
    ...    eventA4 contains (
    ...    a4-Threshold contains (
    ...    threshold-RSRP eq 0))
    ...    and (measIdToAddModListExt-r12 contains (
    ...    measId-v1250 eq 64 and measObjectId-r12 eq 5))

${B1_deactive_for_all}    measIdToRemoveList contains (17, 18, 19)

${LB_B1_activation}    SEPARATOR=
    ...    measObjectToAddModList contains ((measObjectId eq 5) 
    ...    and (carrierFreq eq 1300)) 
    ...    and (cellsToAddModListUTRA-FDD contains (
    ...    cellIndex eq 1 
    ...    and physCellId eq 41))
    ...    and measIdToAddModList contains (
    ...    (measId eq 3) 
    ...    and (measObjectId eq 5) 
    ...    and (reportConfigId eq 6))
    ...    and reportConfigToAddModList contains ((
    ...    reportConfigId eq 6) 
    ...    and eventB1 is present)
	
${ENDC_A5_active_after_A4_deactive}    SEPARATOR=
    ...    measIdToAddModList contains ((
    ...    measId eq 3)
    ...    and (
    ...    measObjectId eq 6)
    ...    and (
    ...    reportConfigId eq 7))
	
*** Test Cases ***
CB008913-SR-A-B7_ET_03_01_Disabling of legacy ENDC-HO A5 retry not applicable for the UE
    [Tags]    owner-wu zijing
    [Documentation]
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-3 and activate B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: repeat B1 activation and deactivation, UE-1 report Fnr1 at 2nd B1-NR measurementment cycle
    ...    check: ltecell3 activates A5 about Flte1
    ...    Step3: UE-1 report A5 about Flte1 with PCI mapping to ltecell1
    ...    check: UE-1 HO to ltecell1 with cause value resource optimisation handover,is CB007163 UE now.
    ...    Step4: repeat B1 activation and deactivation and wait for iFEndcHoRetryTimer expiry
    ...    check: ltecell1 active A5-measurementment for Flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_caseB703}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=3    mrdc_capa=${ue_eutra_nr_capabilities_b7+n77_b3+n8_b3+n257}
    Wait retryTimerB1NR expired
    Check B1 deactive and A5 active with valid B1 report    ue_id=1    nrfcn=${fnr1}    pci=1
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=1    earfcn=${flte1}    pci=1    HO_cuss=${HO_succ_tocell1}
    Wait retryTimerB1NR expired
    Check A5 for Flte3 active    ue_id=1
    [Teardown]    case_teardown_with_UE_detach_and_recover_LNRELGNBCELL    ue_id=1

CB008913-SR-A-B6_ET_13_01_ENDC-HO A5 activation after handover from target layer with blocking removed due to timeBlockEndcHoAtHoFromTrg expired
    [Tags]    owner-wu zijing
    [Documentation]
    ...    Case name: CB008913-SR-A-B6_ET_13_01_ENDC-HO A5 activation at NR in-coverage trigger after handover from
    ...    target layer with NR in-coverage blocking removed due to timeBlockEndcHoAtHoFromTrg expired
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and activate B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: repeat B1 activation and deactivation, UE-1 report Fnr3 at 2nd B1-NR measurementment cycle
    ...    check: ltecell1 activates A5 about Flte3
    ...    Step3: UE-1 report A5 about Flte3 with PCI mapping to ltecell3
    ...    check: UE-1 HO to ltecell3
    ...    Step4: repeat B1 activation and deactivation and wait for timeBlockEndcHoAtHoFromTrg expiry
    ...    check: ltecell3 active A5-measurementment for Flte1
    [Setup]    case_setup_with_delta_commission    ${delta_for_B613}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b3+n77_b7+n8_b7+n257}
    Wait retryTimerB1NR expired
    Check A5 active for Flte3 with valid B1 report    ue_id=1    nrfcn=${fnr3}    pci=3
    Report valid ENDC_HO A5 for special EARFCN and check HO successful    ue_id=1    earfcn=${flte3}    pci=3    HO_cuss=${HO_succ_tocell3}
    Check B1 deactive and A5 not active    ue_id=1
    repeat B1 activation and deactivation and wait for timeBlockEndcHoAtHoFromTrg expiry
    check A5 for Flte1 active and B1 deactive with valid B1 report    ue_id=1    nrfcn=${fnr2}    pci=2
    [Teardown]    case_teardown_with_UE_detach_and_recover_LNRELGNBCELL    ue_id=1

CB008913-SR-A-B6_ET_11_01_Blocking of ENDC-HO A5 activation upon NR in-coverage trigger interaction with LE-HO serving cell1
    [Tags]    owner-wu zijing
    [Documentation]
    ...    Case name: CB008913-SR-A-B6_ET_11_01_Blocking of ENDC-HO A5 activation upon NR in-coverage trigger interaction
    ...    with LE-HO serving cell1 load from not in active to LE
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 with ENDC eligible bearer and QCI1 bearer
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: UE-1 report B1-measure at Fnr2
    ...    check: ltecell1 deactive the B1-measure,activates A5 about Flte3, not active A4
    ...    Step3: ltecell1 change to active iF-LE state
    ...    check: ltecell1 does activate A4-measure for Flte3,deactive the B1-measure,does not activates A5 about Flte1
    [Setup]    case_setup_with_delta_commission    ${delta_for_B611}
    UE attach to cell and add QCI1 bearer and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    A5 does active and A4 does not active with traffic and valid B1 report    ue_id=1
    Change to active iF-LE state and wait retryTimerB1NR expired
    A4 does active and A5 be blocked with valid B1 report    ue_id=1
    [Teardown]    case_teardown_with_UE_detach and recover env    ue_id=1    delta=${disable_LE}

CB008913-SR-A-B6_ET_05_01_Blocking of ENDC-HO A5 activation upon NR in-coverage trigger interaction with LB-UTRA-HO
    [Tags]    TC65    owner-Hu Taotao
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    LNBTS:numB1CyclesWoEndc=2
    ...    freqLayEndcHoList.freqLayer={flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased (LTE5003)
    ...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=allow LB and LE (NR coverage ENDC A5 has lower priority than LB and LE)
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and activation B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: Start traffic for UE and UE-1 report B1 at NR frequency Fnr2 and wait B1 supervision timer expired
    ...    check: B1 deactive and no ENDC A5 activated, and LB B1 activated for frequency 1300
    ...    Step3: Stop traffic for UE and wait B1 retrytimer expired then UE-1 report B1 at NR frequency Fnr2 and wait B1 supervision timer expired
    ...    check: B1 deactive and ENDC A5 activated at flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_B65}
    UE attach to cell and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    Start traffic make cell in active Utran-LB state and LB B1 configure and no ENDC A5 configure
    Stop traffic make cell leave LB state and ENDC A5 configure
    [Teardown]    case_teardown_with_UE_detach and recover env    ue_id=1    delta=${disable_LB_UTRA}

CB008913-SR-A-B6_ET_04_01_Blocking of ENDC-HO A5 activation upon NR in-coverage trigger interaction with LB-HO
    [Tags]    TC64    owner-Geng Lishuo
    [Documentation]
    ...    precondition:
    ...    CB008913 enabled and serving cell is endc non-anchor layer
    ...    freqLayEndcHoList.freqLayer={flte2, flte3, flte4}
    ...    CAGENB.CAIMLBP.IMLBNR.nrcellConfigL.band={8,77,257}
    ...    CAGENB.CAIMLBP.pcellConfig.earfcnDL="flte3"
    ...    UE MRDC capability: {B7+N8,B7+N77}
    ...    LNBTS/NRDCPR-0:dynTriggerLteNrDcConfList:method=coverageAndBufferBased (LTE5003)
    ...    LNBTS/MOPR-1:nrCovEndcHoRetryPrio=allow LB retry (NR coverage ENDC A5 has lower priority than LB)
    ...    Case steps:
    ...    Step1: UE-1 ICS to Cell-1 and activation B1;
    ...    check: UE-1 B1 activation with Fnr1, Fnr2, Fnr3 successfully
    ...    Step2: Start traffic for UE and UE-1 report B1 at NR frequency Fnr2 and wait B1 supervision timer expired
    ...    check: B1 deactive and no ENDC A5 activated, and LB A4 activated
    ...    Step3: Stop traffic for UE and wait B1 retrytimer expired then UE-1 report B1 at NR frequency Fnr2 and wait B1 supervision timer expired
    ...    check: A4 deactive and ENDC A5 activated at flte3
    [Setup]    case_setup_with_delta_commission    ${delta_for_case_B6_04}
    UE attach to cell and add QCI1 bearer and check B1 activation    ue_id=1    cell_id=1    mrdc_capa=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    Start traffic make cell in active LB state and LB A4 configure and no ENDC A5 configure
    Stop traffic make cell leave LB state and ENDC A5 configure    ENDC_A5=${ENDC_A5_active_after_A4_deactive}
    [Teardown]    case_teardown_with_UE_detach and recover env    ue_id=1    delta=${disable_LB}


*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=4CELLs_FDD_2Band3_2Band7    ue_count=100
    Create UE Group Aliases    UE_GROUP    start_ue_id=1    stop_ue_id=20    id_type=cus
    Create enb alias    ENB_1    enb_id=1    id_type=wts
    Create enb alias    alias=gNB    enb_id=7    id_type=wts
    Create MME alias    MME_1    mme_id=1    id_type=wts
    Set UE parameters for ENDC capability
    Config gnb

Set UE parameters for ENDC capability
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc,nr_rrc,s1,x2 on
    Execute Egate Command    trace_sim enb=2 protocol=x2,s1 on
    Execute Egate Command    ue_mme_param id=1-10 spid=2
    Execute Uex Command    ue_param id=1-20 dual_conn=eutra_nr pdcp_sn_extension=18bit nr_supported_bands=77,8,257

Config gnb
    Execute Egate Command    gnb_endc_param id=7 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=7 scg_dl_dist_percent=0
    Execute Egate Command    gnb_endc_param id=7 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=7 selected_band_combination_nr=1:1

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

case_setup_with_delta_commission
    [Arguments]    ${delta_params}
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${delta_params}
    cells should be onair

case_teardown_with_UE_detach and recover env
    [Arguments]    ${ue_id}    ${delta}
    UE detach    ue_id=${ue_id}
    Delta Commission Parameters    ${delta}
    Common Test Teardown And Stop Capture Logs

case_teardown_with_UE_detach_and_recover_LNRELGNBCELL
    [Arguments]    ${ue_id}
    UE detach    ue_id=${ue_id}
    Delta Commission Parameters    ${X2_MOCs}
    Common Test Teardown And Stop Capture Logs

UE attach to cell
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b3+n8_b3+n257_b7+n8_b7+n77}
    ${V_1}    catenate
    ...      ue_attach id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_nr_capabilities=${mrdc_capa}
    ...      ue_eutra_capabilities=${ue_eutra_capabilities} cell=${cell_id}
    ${ret1}=    Execute Uex Command    ${V_1}

UE detach
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_detach id=${ue_id}


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

UE attach to cell and add QCI1 bearer and check B1 activation
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${mrdc_capa}=${ue_eutra_nr_capabilities_b7+n8_b7+n77}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_activate_for_Fnr1_Fnr2_Fnr3_firstTime})
    ...    alias=B1_activation    overall_timeout=20
    UE attach to cell    ue_id=${ue_id}    cell_id=${cell_id}    mrdc_capa=${mrdc_capa}
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=B1_activation

Wait retryTimerB1NR expired
    [Arguments]    ${ue_id}=1    ${timerout}=32    ${B1_reactive}=${B1_reactive}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_reactive})
    ...    alias=B1_reactive    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=B1_reactive

Check B1 deactive and A5 active with valid B1 report
    [Arguments]    ${ue_id}=1    ${nrfcn}=${fnr1}    ${pci}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive_and_A5_active})
    ...    alias=A5_active    overall_timeout=32
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${nrfcn}    pci=${pci}
    Flow Occurred As Expected    alias=A5_active

Report valid ENDC_HO A5 for special EARFCN and check HO successful
    [Arguments]    ${ue_id}=1    ${earfcn}=${flte3}    ${pci}=3    ${timerout}=20    ${HO_cuss}=${HO_succ_tocell1}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${HO_cuss})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfigurationComplete
    ...    alias=HO_successful    overall_timeout=${timerout}
    Execute Uex Command    ue_measurement_send id=${ue_id} earfcn=${earfcn} srsrp=79 phycell_id=${pci} nrsrp=58 nrsrq=26 event=A5
    Flow Occurred As Expected    alias=HO_successful

Check A5 for Flte3 active
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_Flte3_active})
    ...    alias=A5_active    overall_timeout=35
    Flow Occurred As Expected    alias=A5_active

Check A5 active for Flte3 with valid B1 report
    [Arguments]    ${ue_id}=1    ${nrfcn}=${fnr3}    ${pci}=3
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_for_Flte3})
    ...    alias=A5_activation    overall_timeout=30
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${nrfcn}    pci=${pci}
    Flow Occurred As Expected    alias=A5_activation

Check B1 deactive and A5 not active
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18,19))
    ...    alias=B1_deactive    overall_timeout=30
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 1400))
    ...    alias=A5_active    overall_timeout=20
    Flow Occurred As Expected    alias=B1_deactive
    Flow Not Occurred For Message    alias=A5_active

check A5 block due to timeBlockEndcHoAtHoFromTrg
    [Arguments]    ${ue_id}=1    ${nrfcn}=${fnr2}    ${pci}=2
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17,18,19))
    ...    alias=B1_deactive    overall_timeout=30
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measObjectToAddModList contains (carrierFreq eq 1400))
    ...    alias=A5_active    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${nrfcn}    pci=${pci}
    Flow Occurred As Expected    alias=B1_deactive
    Flow Not Occurred For Message    alias=A5_active

check A5 for Flte1 active and B1 deactive with valid B1 report
    [Arguments]    ${ue_id}=1    ${nrfcn}=${fnr2}    ${pci}=2
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive_A5ofFlte1_active})
    ...    alias=B1_deactive_and_A5_active    overall_timeout=20
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${nrfcn}    pci=${pci}
    Flow Occurred As Expected    alias=B1_deactive_and_A5_active

repeat B1 activation and deactivation and wait for timeBlockEndcHoAtHoFromTrg expiry
    Wait retryTimerB1NR expired
    check A5 block due to timeBlockEndcHoAtHoFromTrg    ue_id=1    nrfcn=${fnr2}    pci=2
    Wait retryTimerB1NR expired
    check A5 block due to timeBlockEndcHoAtHoFromTrg    ue_id=1    nrfcn=${fnr2}    pci=2
    Wait retryTimerB1NR expired
    check A5 block due to timeBlockEndcHoAtHoFromTrg    ue_id=1    nrfcn=${fnr2}    pci=2
    Wait retryTimerB1NR expired
    check A5 block due to timeBlockEndcHoAtHoFromTrg    ue_id=1    nrfcn=${fnr2}    pci=2
    Wait retryTimerB1NR expired

A5 does active and A4 does not active with traffic and valid B1 report
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${A4_active_query})
    ...    alias=A4_active    overall_timeout=20
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measId eq 3))
    ...    alias=A5_active    overall_timeout=20
    Execute Uex Command    trf_data_start trf_id=1 dir=dl Mbps=150 ue=${ue_id} protocol=udp qci=6
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr2}    pci=2
    Flow Not Occurred For Message    alias=A4_active
    Flow Occurred As Expected    alias=A5_active

Change to active iF-LE state and wait retryTimerB1NR expired
    Delta Commission Parameters And Wait Cells Onair    ${delta_for_B611_2}
    Wait retryTimerB1NR expired

A4 does active and A5 be blocked with valid B1 report
    [Arguments]    ${ue_id}=1
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToRemoveList contains (17, 18, 19))
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${A4_active_query})
    ...    alias=B1_deactive_and_A4_active    overall_timeout=20
    Expect Message Will Not Occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (measIdToAddModList contains (measId eq 3))
    ...    alias=A5_active    overall_timeout=30
    Report valid B1 report for special NRFCN    ue_id=${ue_id}    narfcn=${fnr2}    pci=2
    Flow Occurred As Expected    alias=B1_deactive_and_A4_active
    Flow Not Occurred For Message    alias=A5_active

wait B1 supervision timer expired and expected ENDC A5 activated
    [Arguments]    ${ue_id}    ${ENDC_A5_active_and_B1_deactive}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${ENDC_A5_active_and_B1_deactive})
    ...    alias=ENDC_A5_activate    overall_timeout=20
    Flow Occurred As Expected    alias=ENDC_A5_activate

Start traffic for UE
    [Arguments]    ${ue_id}=1    ${dir}=dl    ${qci}=6    ${trf_id}=1
    Execute Uex Command    trf_data_start trf_id=${trf_id} dir=${dir} Mbps=150 ue=${ue_id} protocol=udp qci=${qci}

Stop traffic for UE
    [Arguments]    ${ue_id}=1    ${trf_id}=1
    Execute Uex Command    trf_data_stop trf_id=${trf_id} ue=${ue_id}

Wait retryTimerB1NR expired and check B1 reactivation
    [Arguments]    ${ue_id}=1    ${timerout}=32    ${B1_reactive}=${B1_reactive}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_reactive})
    ...    alias=B1_reactive    overall_timeout=${timerout}
    Flow Occurred As Expected    alias=B1_reactive

Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation and LB_B1 active
    [Arguments]    ${ue_id}=1    ${B1_deactive}=${B1_deactive_for_all}    ${endc_A5_activate}=${ENDC_A5_for_Flte3}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${LB_B1_activation})
    ...    alias=B1_deactive_and_LB_B1_active    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${endc_A5_activate})
    ...    alias=NO_ENDC_A5    overall_timeout=20
    Flow Occurred As Expected    alias=B1_deactive_and_LB_B1_active
    Flow Not Occurred For message    alias=NO_ENDC_A5

Start traffic make cell in active Utran-LB state and LB B1 configure and no ENDC A5 configure
    Start traffic for UE    ue_id=1    dir=dl    qci=6
    Report valid B1 report for special NRFCN    narfcn=${fnr2}    pci=2
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation and LB_B1 active

Stop traffic make cell leave LB state and ENDC A5 configure
    [Arguments]    ${ENDC_A5}=${ENDC_A5_for_Flte3}
    Stop traffic for UE    ue_id=1
    Wait retryTimerB1NR expired and check B1 reactivation
    Report valid B1 report for special NRFCN    narfcn=${fnr2}    pci=2
    wait B1 supervision timer expired and expected ENDC A5 activated    ue_id=1
    ...    ENDC_A5_active_and_B1_deactive=${ENDC_A5}
	
Start traffic make cell in active LB state and LB A4 configure and no ENDC A5 configure
    Start traffic for UE    ue_id=1    dir=dl    qci=6
    Report valid B1 report for special NRFCN    narfcn=${fnr2}    pci=2
    Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation and LB_A4 active

Wait B1 supervision timer expired and check B1 deactivated and no ENDC A5 activation and LB_A4 active
    [Arguments]    ${ue_id}=1    ${B1_deactive}=${B1_deactive_for_all}    ${endc_A5_activate}=${ENDC_A5_for_Flte3}
    Expect message flow
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${B1_deactive})
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${A4_active_query})
    ...    alias=B1_deactive_and_LB_A4_active    overall_timeout=20
    Expect message will not occur
    ...    UE_GROUP_${ue_id}:RRC_RRCConnectionReconfiguration (${endc_A5_activate})
    ...    alias=NO_ENDC_A5    overall_timeout=20
    Flow Occurred As Expected    alias=B1_deactive_and_LB_A4_active
    Flow Not Occurred For message    alias=NO_ENDC_A5
