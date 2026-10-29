*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               owner-zhiwen.bu    owner-kang.xiang    release-SBTS20A    team-SG4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    LNBTS-1:actAdvScellMeas=true
...    LNBTS-1:actBbPooling=true
...    LNBTS-1:actCompChecks=true
...    LNBTS-1:actDLCAggr=true
...    LNBTS-1:actFlexScellSelect=true
...    LNCEL:actQci1eVTT=false
...    LNCEL:actModulationSchemeDl=64QAM
...    LNBTS-1:actLTES1Ho=false
...    LNBTS-1:actMultGbrBearers=false
...    LNBTS-1:actNonGbrServiceDiff=false
...    LNBTS-1:actRedirect=disabled
...    LNBTS-1:actS1Flex=disabled
...    LNBTS-1:pwrFallbackCa=true
...    LNBTS-1:sCellActivationCyclePeriod=0.1s
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1:sCellDeactivationTimereNB=rf128
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-2:scellPrio=1
...    LNCEL-1/CAREL-3:lcrId=4
...    LNCEL-1/CAREL-3:lnBtsId=1
...    LNCEL-1/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-3:scellPrio=1
...    LNCEL-1/CAREL-4:lcrId=5
...    LNCEL-1/CAREL-4:lnBtsId=1
...    LNCEL-1/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-4:scellPrio=1
...    LNCEL-1/CAREL-5:lcrId=6
...    LNCEL-1/CAREL-5:lnBtsId=1
...    LNCEL-1/CAREL-5:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-1/CAREL-5:pcellSwapAllowed=allowed
...    LNCEL-1/CAREL-5:scellPrio=1
...    MRBTS-1/LNBTS-1:actMFBI=false
...    MRBTS-1/LNBTS-1:actFlexCaMgmt=false
...    LNBTS-1:actIfHo=enabled
...    LNCEL:actCaArchEnhImp=off
...    LNCEL:actScellConfigForHiDemand=false
...    LNBTS-1/LNCEL:maxNumScells=3
...    LNCEL/LNCEL_TDD-0:uciOnlyMaxCodeRate=26
...    LNBTS-1:actERabModify=false
...    LNBTS-1:actPcellSwap=false
...    LNBTS-1:dlCaPreferred=DLonly
...    LNBTS-1/CADPR-0:enableFreqPrioSwap=disabled
...    LNBTS-1/CADPR-0:maxNumScellSwaps=0
...    LNBTS-1/CADPR-0:maxNumMimoLayerTdd=12
...    LNBTS-1/LNBTS_TDD-0:actConvVoice=true
...    LNBTS-1/LNBTS_TDD-0:dlOlqcDeltaCqiMax=30
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=100
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=50
...    LNCEL-1:actModulationSchemeUL=16QAMHighMCS
...    LNCEL-1/LNCEL_TDD-0:activatedMimoTM=TM4
...    LNCEL-1/LNCEL_TDD-0:dlMimoMode=Closed Loop MIMO (4x2)
...    LNCEL-1/CAPR-1:earfcnDL=${fre4}
...    LNCEL-1/CAPR-1:enableFreqPrioSwap=enabled
...    delete:LNCEL/LNCEL_TDD-0:csiRsConfigInfo
...    LNCEL/LNCEL_TDD-0:bfWeightAgingCoeff=1
...    LNBTS-1:bbPoolMinResource=50
...    LNBTS-1:tS1RelPrepL=500
...    LNBTS-1:tS1RelPrepU=2000
...    LNBTS-1:tX2RelocPrep=500
...    LNBTS-1/CADPR-0:scellPdcchOlLa=enabledPcellBased
...    LNCEL-1:harqMaxMsg3=5
...    LNCEL-1:harqMaxTrDl=5
...    LNCEL-1:harqMaxTrSignalingDl=5
...    LNCEL-1:harqMaxTrUlTtiBundling=8
...    LNCEL-1:harqMaxTrVoLteDl=5
...    LNCEL-1:iniMcsDl=20
...    LNCEL-1:iniMcsUl=10
...    LNCEL-1:iniPrbsUl=30
...    LNCEL-1:maxCrRa4Dl=39
...    LNCEL-1:maxGbrTrafficLimit=80
...    LNCEL-1:maxNbrTrafficLimit=90
...    delete:LNCEL/CAPR
...    LNCEL-1/LNCEL_TDD-0:addNumDrbRadioReasHo=90
...    LNCEL-1/LNCEL_TDD-0:addNumDrbTimeCriticalHo=135
...    LNCEL-1/LNCEL_TDD-0:maxNumQci1Drb=36
...    LNCEL-1/LNCEL_TDD-0:maxNumUeDl=10
...    LNCEL-1/LNCEL_TDD-0:maxNumUeDlDwPTS=6
...    LNCEL-1/LNCEL_TDD-0:maxNumUeUl=12
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUeDc=50
...    LNCEL-1/LNCEL_TDD-0:pdcchFactorForDLReTxPdcBlk=0.6
...    LNCEL-1/LNCEL_TDD-0:pdcchLoadLevel=0
...    LNCEL-1/LNCEL_TDD-0:pdcchLoadPsdOffset=0
...    LNCEL-1/LNCEL_TDD-0:pdcchUtilThForDlReTx=0.9
...    LNCEL-1/LNCEL_TDD-0:prachCS=1
...    LNCEL-1/LNCEL_TDD-0:prachConfIndex=3
...    LNCEL-1/LNCEL_TDD-0:prachFreqOff=2
...    LNCEL-3:tac=33
...    LNCEL-1:caPoolId=1
...    LNCEL-2:caPoolId=1
...    LNCEL-3:caPoolId=1
...    LNCEL-4:caPoolId=1
...    LNCEL-5:caPoolId=1
...    LNCEL-6:caPoolId=1
...    LNBTS-1/LNCEL-1/LNCEL_TDD-0:earfcn=${fre1}
...    LNBTS-1/LNCEL-2/LNCEL_TDD-0:earfcn=${fre2}
...    LNBTS-1/LNCEL-3/LNCEL_TDD-0:earfcn=${fre3}
...    LNBTS-1/LNCEL-4/LNCEL_TDD-0:earfcn=${fre4}
...    LNBTS-1/LNCEL-5/LNCEL_TDD-0:earfcn=${fre5}
...    LNBTS-1/LNCEL-6/LNCEL_TDD-0:earfcn=${fre6}
...    LNCEL-4/CAREL-1:lcrId=1
...    LNCEL-4/CAREL-1:lnBtsId=1
...    LNCEL-4/CAREL-1:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-4/CAREL-1:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-1:scellPrio=1
...    LNCEL-4/CAREL-2:lcrId=2
...    LNCEL-4/CAREL-2:lnBtsId=1
...    LNCEL-4/CAREL-2:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-4/CAREL-2:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-2:scellPrio=1
...    LNCEL-4/CAREL-3:lcrId=3
...    LNCEL-4/CAREL-3:lnBtsId=1
...    LNCEL-4/CAREL-3:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-4/CAREL-3:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-3:scellPrio=1
...    LNCEL-4/CAREL-4:lcrId=5
...    LNCEL-4/CAREL-4:lnBtsId=1
...    LNCEL-4/CAREL-4:maxNumOfSuppMimoLayer=2-layer
...    LNCEL-4/CAREL-4:pcellSwapAllowed=allowed
...    LNCEL-4/CAREL-4:scellPrio=5
...    LNCEL-4:scellFastSchedulingSelect=normal
...    LNCEL-4:dlCaMinPcellCqi=0
...    LNCEL-4:ulCaMinPcellSinr=0
...    LNCEL-4:actScellConfigForHiDemand=false
...    delete:LNBTS-1/LNADJ*
...    delete:LNCEL:iFLBLoadThresholds
...    delete:LNCEL:intraFreqLbLoadThresholds
...    LNCEL:loadSettings:nomNumPrbNonGbr=0.01
...    LNCEL:loadSettings:targetLoadGbrDl=50
...    LNCEL:loadSettings:targetLoadNonGbrDl=75
...    LNCEL:loadSettings:targetLoadPdcch=90
...    LNCEL:loadSettings:ulCacIgnore=false
...    delete:LNCEL:moPrMappingList
...    delete:LNBTS-1/MODPR-0
...    delete:LNBTS-1/MOPR-0
...    @{Eliminate_relation_error}

# actFlowCtrlEnh need set to true in ABIN, ABIO, ABIP/ABIQ
# also actFlowCtrlEnh need set to same value in all Pcell and Scell.
@{Eliminate_relation_error}
...    LNCEL:actFlowCtrlEnh=true
...    LNBTS-1:actAmbrModCaTrigger=false
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51

${Flag_for_debug_sibs}    0x370052
@{PARAMS_IN_SWCONFIG}
...    ${Flag_for_debug_sibs}=0
#For can't received sibs message

${band}           41
${A-q_uecapbility}    41:e:a|41:d:a|41:c:a|41:a:a
${A-r_uecapbility}    41:a:a+41:a+41:c|41:a:a+41:a+41:a|41:a:a+41:a
${A-s_uecapbility}    41:e:a|41:d:a|41:c:a|41:a:a
${A-u_TM4_uecapbility}    41:c:c+41:c|41:c:c+41:a|41:c:c
${A-x_uecapbility}    41:e:a|41:d:a|41:c:a|41:a:a+41:a|41:c:a+41:a|41:d:a|41:c:a|41:a:a+41:a|41:c:a+41:a

@{Parameter_for_A-q1}
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actPcellSwap=true
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNBTS-1/CADPR-0:enableFreqPrioSwap=enabled
...    LNBTS-1/CADPR-0:maxNumScellSwaps=3
...    LNBTS-1/LNCEL:dlCaCqiWindow=50
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=50
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=20
...    LNBTS-1/LNCEL-1/CAPR-1:a3Offset=-6
...    LNBTS-1/LNCEL-1/CAPR-1:a3TimeToTrigger=ms320
...    LNBTS-1/LNCEL-1/CAPR-1:a3TriggerQuantity=RSRP
...    LNBTS-1/LNCEL-1/CAPR-1:a6Offset=6
...    LNBTS-1/LNCEL-1/CAPR-1:a6ReportInterval=640ms
...    LNBTS-1/LNCEL-1/CAPR-1:a6TimeToTrigger=320ms
...    LNBTS-1/LNCEL-1/CAPR-1:earfcnDL=${fre4}
...    LNBTS-1/LNCEL-1/CAPR-1:enableA3Event=true
...    LNBTS-1/LNCEL-1/CAPR-1:enableA6Event=true
...    LNBTS-1/LNCEL-1/CAPR-1:enableFreqPrioSwap=enabled
...    LNBTS-1/LNCEL-1/CAPR-1:hysA3Offset=2
...    LNBTS-1/LNCEL-1/CAPR-1:hysA6Offset=0
...    LNBTS-1/LNCEL-1/CAPR-1:maxNumScellSwaps=0
...    LNBTS-1/LNCEL-1/CAPR-1:sFreqPrio=1
...    LNBTS-1/LNCEL-1/CAPR-1:scellMeasThreshRsrp=-110
...    LNBTS-1/LNCEL-1/CAPR-1:scellMeasThreshRsrq=-120
...    LNCEL-1:dlCaMinPcellCqi=0
...    LNCEL-1:maxNumScells=3
...    LNCEL-1:loadSettings:cellCapClass=100
...    LNCEL-1:pcellSwapConfig:enableVoLteUePcellSwap=AllUes
...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=40
...    LNCEL-1:pcellSwapConfig:pFreqPrio=5
...    LNCEL-1:pcellSwapConfig:pcellSwapMaxHoRate=5
...    LNCEL-1:pcellSwapConfig:puschLoadHysteresis=10
...    LNCEL-1:pcellSwapConfig:puschLoadIndexThr=0.1
...    LNCEL-1:pcellSwapConfig:scellChQualThreshold=8
...    LNCEL-1:pcellSwapConfig:scellStateForPcellSwap=activated
...    LNCEL-1:pcellSwapConfig:ulSinrLowThreshold=12
...    LNCEL-4:pcellSwapConfig:enableVoLteUePcellSwap=AllUes
...    LNCEL-4:pcellSwapConfig:numCaUeThreshold=40
...    LNCEL-4:pcellSwapConfig:pFreqPrio=1
...    LNCEL-4:pcellSwapConfig:pcellSwapMaxHoRate=5
...    LNCEL-4:pcellSwapConfig:puschLoadHysteresis=10
...    LNCEL-4:pcellSwapConfig:puschLoadIndexThr=0.1
...    LNCEL-4:pcellSwapConfig:scellChQualThreshold=8
...    LNCEL-4:pcellSwapConfig:scellStateForPcellSwap=activated
...    LNCEL-4:pcellSwapConfig:ulSinrLowThreshold=12
...    LNCEL:actQci1eVTT=false
...    delete:LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff
...    LNCEL:actDrx=false
...    LNBTS-1:actULCAggr=false

@{Parameter_for_A-r}
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=1
...    LNBTS-1:actAdvStepwiseScellAdd=off
...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=1
...    LNBTS-1:actPcellSwap=false
...    LNBTS-1/LNCEL-5/LNCEL_TDD-0:earfcn=${fre6}
...    LNBTS-1:actULCAggr=false
@{Parameter_for_A-r_recover}
...    LNBTS-1/LNCEL-5/LNCEL_TDD-0:earfcn=${fre5}
@{Parameter_for_A-s}
...    LNBTS-1/CADPR-0:enableFreqPrioSwap=disabled
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS-1/LNCEL:dlCaCqiWindow=50
...    LNBTS-1/LNCEL:ulCaMinPcellSinr=0
...    LNBTS-1/LNCEL:ulCaSinrWindow=50
...    LNBTS-1:actPcellSwap=false
...    LNBTS-1:actULCAggr=false
@{Parameter_for_A-u}
...    LNBTS-1/CADPR-0:enableFreqPrioSwap=disabled
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNBTS-1/LNCEL:dlCaCqiWindow=50
...    LNBTS-1/LNCEL:ulCaMinPcellSinr=0
...    LNBTS-1/LNCEL:ulCaSinrWindow=50
...    LNBTS-1:actPcellSwap=false
...    LNBTS-1:actULCAggr=UL_CA_with_smartSched
...    LNBTS-1:actUlTraffDrivUlCa=false
...    LNBTS-1/CAGENB-0:maxDlCaConfigForUlCa=max_5CC_DL_CA
@{Parameter_for_A-x1}
...    LNCEL-6/LNCEL_TDD-0:earfcn=${fre6}
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=50
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=100
...    LNCEL-1:maxNumScells=3
...    LNBTS-1:actPcellSwap=false
...    LNBTS-1:actULCAggr=false
@{Parameter_for_A-x3}
...    LNCEL-6/LNCEL_TDD-0:earfcn=${fre6}
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=50
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=100
...    LNCEL-1:maxNumScells=3
...    LNBTS-1:actPcellSwap=false
...    LNBTS-1:actULCAggr=false

#A-q2 and A-x2 not use but keep for future debuging.
#@{Parameter_for_A-q2}
#...    LNCEL-1:pcellSwapConfig:enableVoLteUePcellSwap=AllUes
#...    LNCEL-1:pcellSwapConfig:numCaUeThreshold=40
#...    LNCEL-1:pcellSwapConfig:pFreqPrio=1
#...    LNCEL-1:pcellSwapConfig:pcellSwapMaxHoRate=5
#...    LNCEL-1:pcellSwapConfig:puschLoadHysteresis=10
#...    LNCEL-1:pcellSwapConfig:puschLoadIndexThr=0.01
#...    LNCEL-1:pcellSwapConfig:scellChQualThreshold=8
#...    LNCEL-1:pcellSwapConfig:scellStateForPcellSwap=activated
#...    LNCEL-1:pcellSwapConfig:ulSinrLowThreshold=12
#...    MRBTS-1/LNBTS-1:actMFBI=false
#...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=1
#...    LNBTS-1:actAdvStepwiseScellAdd=off
#...    LNBTS-1:sCellActivationMethod=nonGBRBufferBasedStepWise
#...    LNBTS-1:actULCAggr=false
#...    LNBTS-1:actIfHo=enabled
#...    LNBTS-1:actPcellSwap=true
#...    LNBTS-1/CADPR-0:enableFreqPrioSwap=enabled
#...    LNBTS-1/CADPR-0:maxNumScellSwaps=3
#...    LNBTS-1/LNCEL:dlCaCqiWindow=50
#...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=50
#...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=20
#...    LNBTS-1/LNCEL-1/CAPR-1:a3Offset=-6
#...    LNBTS-1/LNCEL-1/CAPR-1:a3TimeToTrigger=ms320
#...    LNBTS-1/LNCEL-1/CAPR-1:a3TriggerQuantity=RSRP
#...    LNBTS-1/LNCEL-1/CAPR-1:a6Offset=6
#...    LNBTS-1/LNCEL-1/CAPR-1:a6ReportInterval=640ms
#...    LNBTS-1/LNCEL-1/CAPR-1:a6TimeToTrigger=320ms
#...    LNBTS-1/LNCEL-1/CAPR-1:earfcnDL=${fre4}
#...    LNBTS-1/LNCEL-1/CAPR-1:enableA3Event=true
#...    LNBTS-1/LNCEL-1/CAPR-1:enableA6Event=true
#...    LNBTS-1/LNCEL-1/CAPR-1:enableFreqPrioSwap=enabled
#...    LNBTS-1/LNCEL-1/CAPR-1:hysA3Offset=2
#...    LNBTS-1/LNCEL-1/CAPR-1:hysA6Offset=0
#...    LNBTS-1/LNCEL-1/CAPR-1:maxNumScellSwaps=0
#...    LNBTS-1/LNCEL-1/CAPR-1:sFreqPrio=1
#...    LNBTS-1/LNCEL-1/CAPR-1:scellMeasThreshRsrp=-110
#...    LNBTS-1/LNCEL-1/CAPR-1:scellMeasThreshRsrq=-120
#...    LNCEL-1:dlCaMinPcellCqi=0
#...    LNCEL-1:maxNumScells=3
#...    LNCEL-1:loadSettings:cellCapClass=100
#...    LNCEL-4:pcellSwapConfig:enableVoLteUePcellSwap=AllUes
#...    LNCEL-4:pcellSwapConfig:numCaUeThreshold=40
#...    LNCEL-4:pcellSwapConfig:pFreqPrio=1
#...    LNCEL-4:pcellSwapConfig:pcellSwapMaxHoRate=5
#...    LNCEL-4:pcellSwapConfig:puschLoadHysteresis=10
#...    LNCEL-4:pcellSwapConfig:puschLoadIndexThr=0.1
#...    LNCEL-4:pcellSwapConfig:scellChQualThreshold=8
#...    LNCEL-4:pcellSwapConfig:scellStateForPcellSwap=activated
#...    LNCEL-4:pcellSwapConfig:ulSinrLowThreshold=12
#...    LNCEL:actQci1eVTT=false
#...    delete:LNCEL/LNCEL_TDD-0:fourLayerMimoAvSpectralEff
#...    LNCEL:actDrx=false
#@{Parameter_for_A-x2}
#...    LNCEL-6/LNCEL_TDD-0:earfcn=${fre6}
#...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe3c=24
#...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=0
#...    LNCEL-1/LNCEL_TDD-0:maxNumCaConfUe=100
#...    LNCEL-1:maxNumScells=3
#...    LNBTS-1:actPcellSwap=false
#...    LNBTS-1:actULCAggr=false

${CA_DL_CAP_UE_2CC_AVG}    M8051C121
${CA_DL_CAPAB_UE_3CC_AVG}    M8051C122
${CA_2SCELLS_CONFIG_UE_AVG}    M8051C124
${CA_DL_CAP_UE_4CC_MAX}    M8051C171
${CA_3SCELLS_CONF_UE_MAX}    M8051C172
${CA_DL_CAP_UE_4CC_AVG}    M8051C17
${CA_DL_3SCELLS_CONF_UE_AVG}    M8051C19
@{RTPM_Check_Counter}
...    LNCEL-4:LTE_UE_Quantity:${CA_DL_CAP_UE_2CC_AVG}<=200
...    LNCEL-4:LTE_UE_Quantity:${CA_DL_CAPAB_UE_3CC_AVG}<=200
...    LNCEL-4:LTE_UE_Quantity:${CA_2SCELLS_CONFIG_UE_AVG}<=700
...    LNCEL-4:LTE_UE_Quantity:${CA_DL_CAP_UE_4CC_MAX}=1
...    LNCEL-4:LTE_UE_Quantity:${CA_3SCELLS_CONF_UE_MAX}=1
...    LNCEL-4:LTE_UE_Quantity:${CA_DL_CAP_UE_4CC_AVG}<=200
...    LNCEL-1:LTE_UE_Quantity:${CA_DL_3SCELLS_CONF_UE_AVG}<=200

${PM_COUNTER_INTERVAL}    1min

${fre1}    40340
${fre2}    40538
${fre3}    40736
${fre4}    40934
${fre5}    40940
${fre6}    41138

${ue_eutra_capabilities_A-q-s}    D1B80480A00007F87EE5F00100383C800000002A54ADC506074000000740000607400004074000080C00000000FF800000514478CB40010040
${ue_eutra_capabilities_A-u}    D1B80480A00007F87EE5F00100383C800000002A54ADC5040F400804D00207A00402680001D00201020000003FE0000014511E32D0004010
${ue_eutra_capabilities_A-x1}    SEPARATOR=
...    D1B80480A00007F87EE5F00100383C800000002A54ADC5100740000807400006074000040F400000D00007A00002680001D000018
...    1D0000103D00000340001E800009A00020000000000000000000FF800000514478CB4001004
${ue_eutra_capabilities_A-r}    SEPARATOR=
...    D1B80480A00007F87EE5F00100383C800000002A54ADC50417400000D000680105D0000034001A0000F400000D000040000007FC0000028A23C65A000802

*** Test Cases ***
LTE2179-A-q_01_4CC_80MHz_Band41_TM4_CFG_4x2_64QAM_Stepwise_Addition_41E_and_PcellSwap_By_Frequency_Priority
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-q1}
    Start Rtpm Counter
    Trigger Pcell Swap and verify the Pcell Swap By Frequency Priority    ue_id=1
    Check Rtpm Counters    ${RTPM_Check_Counter}

LTE2179-A-s_4CC_80MHz_Locked_Pcell
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-s}
    Ue attach to Pcell And Scell Addition By Onestep    ue_id=3    ca_supported_bands=${A-s_uecapbility}
    Check Ue State After Lock Pcell
    [Teardown]    Common Test Teardown And Stop Capture Logs and recover

LTE2179-A-u_4CC_80MHz_Band41_TM4_CFG_4x2_64QAM_41C_41C_ULCA_Oneshot
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-u}
    Ue attach to Pcell And Scell Addition By Onestep 41C 41C UL    ue_id=4    ca_supported_bands=${A-u_TM4_uecapbility}
    Check ULCA State After Lock Scell    ue_id=4
    [Teardown]    Common Test Teardown And Stop Capture Logs with unblock cell6

LTE2179-A-x1 Bbpooling Maxnumcaconfue3c For 20UE
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-x1}
    Ue Attach To Pcell With Muilti Ues    initial_ue=11    ca_supported_bands=${A-x_uecapbility}    ue_stop_id=30

LTE2179-A-x3_Bbpooling_MaxNumCaconfUe3C For 51UE
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-x3}
    Ue Attach To Pcell With Muilti Ues    initial_ue=40    ca_supported_bands=${A-x_uecapbility}    ue_stop_id=89
    Ue Attach To Pcell With Ue_90 Only 2cc    ca_supported_bands=${A-x_uecapbility}

LTE2179-A-r_SUE_4CC_80MHz_Band41_TM4_CFG_4x2_64QAM_Scell_Swap
    [Documentation]    Check
    ...    n1PUCCH:packet_filter='(lte-rrc.n1PUCCH_AN_CS_r10 == 1)&&(lte-rrc.sCellToAddModList_r10==1 && lte-rrc.physCellId_r10==2)
    ...    ';
    ...    Check n3PUCCH:packet_filter='(lte-rrc.pucch_Format_r10==0)&&(lte-rrc.sCellToAddModList_r10==2 && lte-rrc.physCellId_r10==3)'
    [Tags]
    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-r}
    Ue attach to Pcell with ScellSwap    ue_id=5    ca_supported_bands=${A-r_uecapbility}
    [Teardown]    Run Keywords    CUS Detach Ue
    ...    AND    Delta Commission Parameters And Wait Cells Onair    ${Parameter_for_A-r_recover}
    ...    AND    Common Test Teardown And Stop Capture Logs


*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=6CELLs_TDD_B41_4PIPES    ue_count=100
    FOR    ${ue_id}    IN RANGE    1    91
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create MME Alias    MME_1    mme_id=1    id_type=wts
    Execute Egate Command    trace uec=1 mme=1 protocol=rrc on

Modify Yaml
    FOR    ${ue_index}    IN RANGE    1    91
        Update Yaml    UEs/UE_sets/${ue_index}    release: '12'    category: '12'    rohc: '16'    dl_256QAM_supported: 'on'
        ...    fgi_r10: '103,104,105,106,107,108,109,110,111'    fgi: '1,2,3,4,5,6,7,8,13,14,15,16,17,18,20,21,22,25,27,28,29,30,31'
        ...    eia: 'aes'    eea: 'aes'
    END
    Update Yaml    UEs/bearer_sets/bearer_set_1/1     mbr_dl: 256000

Trigger Pcell Swap and verify the Pcell Swap By Frequency Priority
    [Arguments]    ${ue_id}=1    ${ca_supported_bands}=${A-q_uecapbility}    ${supported_bands}=${band}
    ${DL_4cc_scell_addition_sCell1}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq ${fre2})
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    ${DL_4cc_scell_addition_sCell2}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq ${fre3})
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    ${DL_4cc_scell_addition_sCell3}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq ${fre4})
    ...    )
    ...    and length(sCellToAddModList-r10) eq 3
    ${DL_4cc_pcell_swap}    catenate
    ...    sCellToReleaseList-r10 contains ( 1,2,3 ) and
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq ${fre3}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq ${fre2}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 1 and dl-CarrierFreq-r10 eq ${fre1})
    ...    ) and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_sCell1} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_sCell2} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_sCell3} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_pcell_swap} )
    ...    alias=scell_addtion_release_with_pcell_swap_flow    overall_timeout=180

    Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${ca_supported_bands} supported_bands=${band}
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_A-q-s}
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp size=1458 Mbps=175
    Repeat Keyword    10    Get Ue Stats For Scell Addition And Pcell Swap    ue_id=1
    Flow Occurred As Expected    alias=scell_addtion_release_with_pcell_swap_flow

Get Ue Stats For Scell Addition And Pcell Swap
    [Arguments]    ${ue_id}=1
    Sleep    1s    sleep for wait traffic stable/scell addition/pcell swap
    Execute Uex Command    get_ue_summary
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0-7 unit=Mbps

Ue attach to Pcell And Scell Addition By Onestep
    [Arguments]    ${ue_id}=3    ${ca_supported_bands}=${EMPTY}
    ${DL_4cc_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq ${fre2}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq ${fre3}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq ${fre4})
    ...    ) and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition} )
    ...    alias=scell_addtion_4cc_flow    overall_timeout=60
    Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${ca_supported_bands} supported_bands=${band}
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_A-q-s}
    Flow Occurred As Expected    alias=scell_addtion_4cc_flow

Ue attach to Pcell And Scell Addition By Onestep 41C 41C UL
    [Arguments]    ${ue_id}=3    ${ca_supported_bands}=${EMPTY}
    ${DL_4cc_scell_addition_41c_41c_ul}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq ${fre2}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq ${fre5}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 6 and dl-CarrierFreq-r10 eq ${fre6})
    ...    ) and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_41c_41c_ul} )
    ...    alias=scell_addtion_4cc_41c_ul_flow    overall_timeout=60
    Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${ca_supported_bands} supported_bands=${band}
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_A-u}
    Flow Occurred As Expected    alias=scell_addtion_4cc_41c_ul_flow

Check Ue State After Lock Pcell
    [Documentation]    get ue summary for check if ue enter into idle state.
    Expect Message Flow
    ...    MME_1:S1AP_Reset (initiatingMessage contains (value contains (Reset contains (Cause contains (misc eq "om-intervention")))))
    ...    MME_1:S1AP_ResetAcknowledge (successfulOutcome contains ( value contains (ResetAcknowledge is present)))
    ...    alias=s1_reset_flow    overall_timeout=120
    Execute Uex Command    get_ue_summary
    Block Cell1
    Execute Uex Command    get_ue_summary
    Flow Occurred As Expected    alias=s1_reset_flow
    Execute Uex Command    get_ue_summary

Check ULCA State After Lock Scell
    [Documentation]    cus only support pdsch, so use type=pdsch in kw.
    [Arguments]    ${ue_id}=4
    ${4cc_to_3cc}    catenate
    ...    sCellToReleaseList-r10 contains ( 3 ) and
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1,
    ...    sCellIndex-r10 eq 2
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${4cc_to_3cc} )
    ...    alias=4cc_to_3cc_flow    overall_timeout=120
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0-7 unit=Mbps
    Execute Uex Command    get_cell_stats id=1 type=pdsch scell=all
    Block Cell6
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0-7 unit=Mbps
    Execute Uex Command    get_cell_stats id=1 type=pdsch scell=all
    Flow Occurred As Expected    alias=4cc_to_3cc_flow

Ue Attach To Pcell With Muilti Ues
    [Arguments]    ${initial_ue}    ${ue_stop_id}    ${ca_supported_bands}={EMPTY}
    ${no_scell_release_check}    catenate
    ...    sCellToReleaseList-r10 is present
    ${DL_4cc_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 2 and dl-CarrierFreq-r10 eq ${fre2}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq ${fre3}),
    ...    cellIdentification-r10 contains (physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq ${fre4})
    ...    ) and length(sCellToAddModList-r10) eq 3
    FOR    ${ue_id}    IN RANGE    ${initial_ue}    ${${ue_stop_id}+1}
        Expect Message Will Not Occur
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${no_scell_release_check} )
        ...    alias=no_scell_release_check_${ue_id}    overall_timeout=120
        Expect message flow
        ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition} )
        ...    alias=scell_addtion_4cc_multi_ue_${ue_id}_flow    overall_timeout=20
        Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${ca_supported_bands} supported_bands=${band}
        Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_A-x1}
        Flow Occurred As Expected    alias=scell_addtion_4cc_multi_ue_${ue_id}_flow
    END
    FOR    ${ue_id}    IN RANGE    ${initial_ue}    ${${ue_stop_id}+1}
        Flow Not Occurred For Message    alias=no_scell_release_check_${ue_id}
    END

Ue Attach To Pcell With Ue_90 Only 2cc
    [Arguments]    ${ca_supported_bands}={EMPTY}
    ${DL_only_2cc_scell_addition}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 6 and dl-CarrierFreq-r10 eq ${fre6})
    ...    ) and length(sCellToAddModList-r10) eq 1
    Expect message flow
    ...    UE_90:RRC_RRCConnectionReconfiguration ( ${DL_only_2cc_scell_addition} )
    ...    alias=scell_addtion_only_2cc_ue_90_flow    overall_timeout=20
    Execute Uex Command    ue_param id=90 ca_supported_bands=${ca_supported_bands} supported_bands=${band}
    Execute Uex Command    ue_attach id=90 cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_A-x1}
    Flow Occurred As Expected    alias=scell_addtion_only_2cc_ue_90_flow

Ue attach to Pcell with ScellSwap
    [Arguments]    ${ue_id}=5    ${ca_supported_bands}={EMPTY}
    Ue attach to Pcell And Scell Addition By Stepwise    ue_id=${ue_id}    ca_supported_bands=${ca_supported_bands}
    Trigger Scell Swap    ue_id=${ue_id}

Ue attach to Pcell And Scell Addition By Stepwise
    [Arguments]    ${ue_id}=5    ${ca_supported_bands}={EMPTY}
    ${DL_4cc_scell_addition_sCell1_stepwise}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 1 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 5 and dl-CarrierFreq-r10 eq 41138)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 1
    ${DL_4cc_scell_addition_sCell2_stepwise}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 2 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 4 and dl-CarrierFreq-r10 eq 40934)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 2
    ${DL_4cc_scell_addition_sCell3_stepwise}    catenate
    ...    sCellToAddModList-r10 contains (
    ...    sCellIndex-r10 eq 3 and
    ...    cellIdentification-r10 contains ( physCellId-r10 eq 3 and dl-CarrierFreq-r10 eq 40736)
    ...    )
    ...    and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_sCell1_stepwise} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_sCell2_stepwise} )
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${DL_4cc_scell_addition_sCell3_stepwise} )
    ...    alias=4cc_scell_addtion_stepwise_flow    overall_timeout=60
    Execute Uex Command    ue_param id=${ue_id} ca_supported_bands=${ca_supported_bands} supported_bands=${band}
    Execute Uex Command    ue_attach id=${ue_id} cell=1 ue_eutra_capabilities=${ue_eutra_capabilities_A-r}
    Execute Uex Command    trf_data_start ue=${ue_id} dir=dl protocol=udp size=1458 Mbps=175
    Sleep    5s    wait for eNB load to be High
    Execute Uex Command    get_ue_stats id=${ue_id} type=dl_mac scell=0-7 unit=Mbps
    Flow Occurred As Expected    alias=4cc_scell_addtion_stepwise_flow

Trigger Scell Swap
    [Arguments]    ${ue_id}=5
    ${scell_swap}    catenate
    ...    measConfig contains ( measIdToAddModList contains ( measId eq 3 ) ) and
    ...    sCellToReleaseList-r10 contains ( 1 ) and
    ...    sCellToAddModList-r10 contains (
    ...    cellIdentification-r10 contains (physCellId-r10 eq 6 and dl-CarrierFreq-r10 eq 41138),
    ...    sCellIndex-r10 eq 2,
    ...    sCellIndex-r10 eq 3
    ...    ) and length(sCellToAddModList-r10) eq 3
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration ( ${scell_swap} )
    ...    alias=scell_swap_flow    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A6 phycell_id=6 nrsrp=90 nrsrq=30 srsrp=97 srsrq=34
    Flow Occurred As Expected    alias=scell_swap_flow

Common Test Teardown And Stop Capture Logs and recover
    Unblock cell1
    Common Test Teardown And Stop Capture Logs

Common Test Teardown And Stop Capture Logs with unblock cell6
    Unblock cell6
    Common Test Teardown And Stop Capture Logs

CUS Detach Ue
    Execute Uex Command     ue_detach id=5
