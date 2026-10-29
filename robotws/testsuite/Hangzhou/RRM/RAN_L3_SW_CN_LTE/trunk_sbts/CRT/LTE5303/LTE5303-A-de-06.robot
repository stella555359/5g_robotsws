*** Settings ***
Suite Setup       Setup CUS Env And Common Suite Setup
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               release-SRAN19B    team-DEVHZ5_SG2    owner-shelly.song
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CATM}
...    @{PARAMS_FOR_LTE5303}
...    @{CatM_Threshold}
...    @{PARAMS_FOR_CATM_Volte}
...    @{PARAMS_FOR_CATM_emerg}
...    @{PARAMS_FOR_Neighbor}
...    @{PARAMS_FOR_Cell}
...    @{Legacy_Threshold}
@{PARAMS_FOR_CATM}
...    LNCEL-1/LNCEL_FDD-0:actCatM=true
...    LNCEL-2/LNCEL_FDD-0:actCatM=true
...    LNCEL-3/LNCEL_FDD-0:actCatM=true
...    LNCEL-1/CATMCEL-0:numCELevelCatM=2
...    LNCEL-2/CATMCEL-0:numCELevelCatM=2
...    LNCEL-3/CATMCEL-0:numCELevelCatM=2
...    LNCEL-1/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-1/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-1/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-2/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-2/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-2/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-3/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-3/CATMCEL-0:actIntraFreqHoCatM=true
...    LNCEL-3/CATMCEL-0:actRLFbasedRCRCatM=true
...    LNCEL-1/LNCEL_FDD-0:catMProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMProfId=1
...    LNBTS/CATMPR-1:raPreGrCSizeCatM=2
...    LNBTS/CATMPR-1:catMCELevel1:raPreGrCSizeCatM=2
...    LNBTS/CATMPR-1:cpInactivityTimerCatM=60
...    LNBTS/CATMPR-1:srbInactivityTimerCatM=60
...    LNBTS/CATMPR-1:inactivityTimerCatM=170
...    LNCEL-1/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-2/LNCEL_FDD-0:catMBProfId=1
...    LNCEL-3/LNCEL_FDD-0:catMBProfId=1
...    LNBTS/CATMBPR-1:catMCELevel2:raPreGrCSizeCatM=2
...    LNBTS/CATMBPR-1:catMCELevel3:raPreGrCSizeCatM=2
...    LNBTS/CATMBPR-1:defaultPagCeModeBCatM=n16
...    LNCEL-1:dlsDciCch=DCI format 1A
...    LNCEL-2:dlsDciCch=DCI format 1A
...    LNCEL-3:dlsDciCch=DCI format 1A
...    LNCEL-1/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-1/CATMCEL-0:prachRsrpThr1CatM=-110
...    LNCEL-1/CATMCEL-0:prachRsrpThr2CatM=-120
...    LNCEL-2/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-2/CATMCEL-0:prachRsrpThr1CatM=-110
...    LNCEL-2/CATMCEL-0:prachRsrpThr2CatM=-120
...    LNCEL-3/CATMCEL-0:prachRsrpThrCatM=-100
...    LNCEL-3/CATMCEL-0:prachRsrpThr1CatM=-110
...    LNCEL-3/CATMCEL-0:prachRsrpThr2CatM=-120
@{PARAMS_FOR_LTE5303}
...    LNCEL-1/CATMCEL-0:actQci1CatMSpecMeas=false
...    LNCEL-2/CATMCEL-0:actQci1CatMSpecMeas=false
...    LNCEL-3/CATMCEL-0:actQci1CatMSpecMeas=false
...    LNCEL-1/CATMCEL-0:threshold2aQci1CatM=44
...    LNCEL-2/CATMCEL-0:threshold2aQci1CatM=44
...    LNCEL-3/CATMCEL-0:threshold2aQci1CatM=44
...    LNCEL-1/CATMCEL-0:hysThreshold2aQci1CatM=0
...    LNCEL-2/CATMCEL-0:hysThreshold2aQci1CatM=0
...    LNCEL-3/CATMCEL-0:hysThreshold2aQci1CatM=0
...    LNCEL-1/CATMCEL-0:threshold2Qci1CatM=42
...    LNCEL-2/CATMCEL-0:threshold2Qci1CatM=42
...    LNCEL-3/CATMCEL-0:threshold2Qci1CatM=42
...    LNCEL-1/CATMCEL-0:hysThreshold2Qci1CatM=0
...    LNCEL-2/CATMCEL-0:hysThreshold2Qci1CatM=0
...    LNCEL-3/CATMCEL-0:hysThreshold2Qci1CatM=0
...    LNCEL-1/CATMCEL-0:a3OffsetQci1CatM=3
...    LNCEL-2/CATMCEL-0:a3OffsetQci1CatM=3
...    LNCEL-3/CATMCEL-0:a3OffsetQci1CatM=3
...    LNCEL-1/CATMCEL-0:hysA3OffsetQci1CatM=0
...    LNCEL-2/CATMCEL-0:hysA3OffsetQci1CatM=0
...    LNCEL-3/CATMCEL-0:hysA3OffsetQci1CatM=0
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1CatM=3
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqQci1CatM=3
...    LNCEL-3/LNHOIF-1:a3OffsetRsrpInterFreqQci1CatM=3
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreqQci1CatM=0
...    LNCEL-2/LNHOIF-1:hysA3OffsetRsrpInterFreqQci1CatM=0
...    LNCEL-3/LNHOIF-1:hysA3OffsetRsrpInterFreqQci1CatM=0
@{CatM_Threshold}
...    LNCEL-1/CATMCEL-0:actCatMSpecMeas=true
...    LNCEL-2/CATMCEL-0:actCatMSpecMeas=true
...    LNCEL-3/CATMCEL-0:actCatMSpecMeas=true
...    LNCEL-1/CATMCEL-0:threshold2aCatM=44
...    LNCEL-2/CATMCEL-0:threshold2aCatM=44
...    LNCEL-3/CATMCEL-0:threshold2aCatM=44
...    LNCEL-1/CATMCEL-0:hysThreshold2aCatM=0
...    LNCEL-2/CATMCEL-0:hysThreshold2aCatM=0
...    LNCEL-3/CATMCEL-0:hysThreshold2aCatM=0
...    LNCEL-1/CATMCEL-0:a1TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:a1TimeToTriggerCatM=480ms
...    LNCEL-3/CATMCEL-0:a1TimeToTriggerCatM=480ms
...    LNCEL-1/CATMCEL-0:threshold2CatM=42
...    LNCEL-2/CATMCEL-0:threshold2CatM=42
...    LNCEL-3/CATMCEL-0:threshold2CatM=42
...    LNCEL-1/CATMCEL-0:hysThreshold2CatM=0
...    LNCEL-2/CATMCEL-0:hysThreshold2CatM=0
...    LNCEL-3/CATMCEL-0:hysThreshold2CatM=0
...    LNCEL-1/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-3/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-1/CATMCEL-0:a3OffsetCatM=3
...    LNCEL-2/CATMCEL-0:a3OffsetCatM=3
...    LNCEL-3/CATMCEL-0:a3OffsetCatM=3
...    LNCEL-1/CATMCEL-0:hysA3OffsetCatM=0
...    LNCEL-2/CATMCEL-0:hysA3OffsetCatM=0
...    LNCEL-3/CATMCEL-0:hysA3OffsetCatM=0
...    LNCEL-1/CATMCEL-0:a3TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:a3TimeToTriggerCatM=480ms
...    LNCEL-3/CATMCEL-0:a3TimeToTriggerCatM=480ms
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqCatM=3
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqCatM=3
...    LNCEL-3/LNHOIF-1:a3OffsetRsrpInterFreqCatM=3
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=0
...    LNCEL-2/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=0
...    LNCEL-3/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=0
...    LNCEL-1/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-2/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-3/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=480ms
@{PARAMS_FOR_CATM_Volte}
...    LNCEL-1/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-2/CATMCEL-0:actConvVoiceCatM=true
...    LNCEL-3/CATMCEL-0:actConvVoiceCatM=true
...    LNBTS/CATMPR-1:qciForVoLTECatM=255
...    LNBTS/CATMPR-1:catMVoLTETab:dlMaxHarqTxQci1CatM=4
...    LNBTS/CATMPR-1:catMVoLTETab:maxGbrDlQci1CatM=80
...    LNBTS/CATMPR-1:catMVoLTETab:maxGbrUlQci1CatM=80
...    LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci1CatM=infinity
...    LNBTS/CATMPR-1:catMVoLTETab:tDiscardPdcpQci5CatM=300ms
...    LNBTS/CATMPR-1:catMVoLTETab:qci1ProtectionTimerCatM=180
@{PARAMS_FOR_CATM_emerg}
...    LNBTS:imsEmerPlmnConfig:emerSessArpPrioLev=1
...    LNCEL-1/CATMCEL-0:actIMSEmerSessCatM=true
...    LNBTS/LNBTS_FDD-0:actIMSEmerSessR9=true
@{PARAMS_FOR_Neighbor}
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${inter_carrierFreq}
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=${inter_carrierFreq}
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=${intra_carrierFreq}
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiLcrId=2
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-3:handoverAllowed=allowed
...    LNCEL-1/LNREL-3:ecgiLcrId=3
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-2:handoverAllowed=allowed
...    LNCEL-2/LNREL-2:ecgiLcrId=1
...    LNCEL-2/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-2/LNREL-3:handoverAllowed=allowed
...    LNCEL-2/LNREL-3:ecgiLcrId=3
...    LNCEL-2/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-2:handoverAllowed=allowed
...    LNCEL-3/LNREL-2:ecgiLcrId=1
...    LNCEL-3/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-3/LNREL-3:handoverAllowed=allowed
...    LNCEL-3/LNREL-3:ecgiLcrId=2
...    LNCEL-3/LNREL-3:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-388:handoverAllowed=allowed
...    LNCEL-1/LNREL-388:ecgiLcrId=9
...    LNCEL-1/LNREL-388:ecgiAdjEnbId=74566
...    LNBTS/LNADJ-255:rlfBasedRCRsupported=true
...    LNCEL-1/LNREL-388:removeAllowed=false
@{PARAMS_FOR_Cell}
...    LNBTS:actRLFbasedRCR=true
...    LNBTS:actIfHo=enabled
...    LNBTS:rlfBasedRCRdefault=true
...    LNCEL-1/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-2/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-3/LNCEL_FDD-0:actAutoPucchAlloc=true
...    LNCEL-1/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=${intra_carrierFreq}
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=${intra_carrierFreq}
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-3/LNCEL_FDD-0:dlChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:ulChBw=10 MHz
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=${inter_carrierFreq}
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-1/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-2/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-3/LNCEL_FDD-0/APUCCH_FDD-0:selectPrachRegion=InnerLowerEdge
...    LNCEL-1/SIB-0:siWindowLen=40ms
...    LNCEL-2/SIB-0:siWindowLen=40ms
...    LNCEL-3/SIB-0:siWindowLen=40ms
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL-1/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL-2/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerM=2
...    LNCEL-3/LNCEL_FDD-0/MPUCCH_FDD-0:riPerOffset=0
...    LNCEL-1:t301Guard=100
...    LNCEL-2:t301Guard=100
...    LNCEL-3:t301Guard=100
...    LNCEL-1/SIB-0:threshServingLowQR9=0
...    LNCEL-1/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-2/SIB-0:threshServingLowQR9=0
...    LNCEL-2/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    LNCEL-3/SIB-0:threshServingLowQR9=0
...    LNCEL-3/SIB-0:cellSelectionInfoV920:qQualMinR9=-34|qQualMinOffsetR9=1
...    delete:LNBTS/PSGRP-1
@{Legacy_Threshold}
...    LNCEL-1:threshold1=75
...    LNCEL-1:threshold2InterFreq=40
...    LNCEL-1:threshold2a=67
...    LNCEL-1:threshold2aQci1=68
...    LNCEL-1:hysThreshold2InterFreq=0
...    LNCEL-1:cellResourceGroupPrId=1
...    LNCEL-1:inactivityTimerPubSafety=1000
...    LNCEL-1:iFServiceBasedHoRetryTimer=60
...    LNCEL-1:threshold2GERANQci1=25
...    LNCEL-1:threshold2InterFreqQci1=35
...    LNCEL-1:threshold2InterFreqHpue=40
...    LNCEL-1:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-1:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL-1:iniMcsUl=4
...    LNCEL-2:threshold1=75
...    LNCEL-2:threshold2InterFreq=40
...    LNCEL-2:threshold2a=67
...    LNCEL-2:threshold2aQci1=66
...    LNCEL-2:hysThreshold2InterFreq=0
...    LNCEL-2:cellResourceGroupPrId=1
...    LNCEL-2:inactivityTimerPubSafety=1000
...    LNCEL-2:iFServiceBasedHoRetryTimer=60
...    LNCEL-2:threshold2GERANQci1=25
...    LNCEL-2:threshold2InterFreqQci1=35
...    LNCEL-2:threshold2InterFreqHpue=40
...    LNCEL-2:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-2:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL-2:iniMcsUl=4
...    LNCEL-3:threshold1=75
...    LNCEL-3:threshold2InterFreq=40
...    LNCEL-3:threshold2a=67
...    LNCEL-3:threshold2aQci1=69
...    LNCEL-3:hysThreshold2InterFreq=0
...    LNCEL-3:cellResourceGroupPrId=1
...    LNCEL-3:inactivityTimerPubSafety=1000
...    LNCEL-3:iFServiceBasedHoRetryTimer=60
...    LNCEL-3:threshold2GERANQci1=25
...    LNCEL-3:threshold2InterFreqQci1=35
...    LNCEL-3:threshold2InterFreqHpue=40
...    LNCEL-3:a2TimeToTriggerActWcdmaMeas=0ms
...    LNCEL-3:a2TimeToTriggerActInterFreqMeas=100ms
...    LNCEL-3:iniMcsUl=4
@{delta_para_case_569}
...    LNCEL-1/CATMCEL-0:threshold2aCatM=${threshold2aCatM}
...    LNCEL-2/CATMCEL-0:threshold2aCatM=67
...    LNCEL-3/CATMCEL-0:threshold2aCatM=72
...    LNCEL-1/CATMCEL-0:hysThreshold2aCatM=1
...    LNCEL-2/CATMCEL-0:hysThreshold2aCatM=2
...    LNCEL-3/CATMCEL-0:hysThreshold2aCatM=3
...    LNCEL-1/CATMCEL-0:a1TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:a1TimeToTriggerCatM=480ms
...    LNCEL-3/CATMCEL-0:a1TimeToTriggerCatM=480ms
...    LNCEL-1/CATMCEL-0:threshold2CatM=${threshold2CatM}
...    LNCEL-2/CATMCEL-0:threshold2CatM=54
...    LNCEL-3/CATMCEL-0:threshold2CatM=52
...    LNCEL-1/CATMCEL-0:hysThreshold2CatM=1
...    LNCEL-2/CATMCEL-0:hysThreshold2CatM=2
...    LNCEL-3/CATMCEL-0:hysThreshold2CatM=3
...    LNCEL-1/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-3/CATMCEL-0:a2TimeToTriggerCatM=480ms
...    LNCEL-1/CATMCEL-0:a3OffsetCatM=1
...    LNCEL-2/CATMCEL-0:a3OffsetCatM=2
...    LNCEL-3/CATMCEL-0:a3OffsetCatM=3
...    LNCEL-1/CATMCEL-0:hysA3OffsetCatM=1
...    LNCEL-2/CATMCEL-0:hysA3OffsetCatM=2
...    LNCEL-3/CATMCEL-0:hysA3OffsetCatM=3
...    LNCEL-1/CATMCEL-0:a3TimeToTriggerCatM=480ms
...    LNCEL-2/CATMCEL-0:a3TimeToTriggerCatM=480ms
...    LNCEL-3/CATMCEL-0:a3TimeToTriggerCatM=480ms
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqCatM=4
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqCatM=5
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqCatM=6
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqCatM=7
...    LNCEL-3/LNHOIF-1:a3OffsetRsrpInterFreqCatM=8
...    LNCEL-3/LNHOIF-2:a3OffsetRsrpInterFreqCatM=9
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=1
...    LNCEL-1/LNHOIF-2:hysA3OffsetRsrpInterFreqCatM=2
...    LNCEL-2/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=3
...    LNCEL-2/LNHOIF-2:hysA3OffsetRsrpInterFreqCatM=4
...    LNCEL-3/LNHOIF-1:hysA3OffsetRsrpInterFreqCatM=5
...    LNCEL-3/LNHOIF-2:hysA3OffsetRsrpInterFreqCatM=6
...    LNCEL-1/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-1/LNHOIF-2:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-2/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-2/LNHOIF-2:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-3/LNHOIF-1:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-3/LNHOIF-2:a3TimeToTriggerRsrpInterFreqCatM=480ms
...    LNCEL-1/CATMCEL-0:actQci1CatMSpecMeas=true
...    LNCEL-2/CATMCEL-0:actQci1CatMSpecMeas=true
...    LNCEL-3/CATMCEL-0:actQci1CatMSpecMeas=false
...    LNCEL-1/CATMCEL-0:threshold2aQci1CatM=${threshold2aQci1CatM}
...    LNCEL-2/CATMCEL-0:threshold2aQci1CatM=73
...    LNCEL-1/CATMCEL-0:hysThreshold2aQci1CatM=1
...    LNCEL-2/CATMCEL-0:hysThreshold2aQci1CatM=2
...    LNCEL-1/CATMCEL-0:threshold2Qci1CatM=${threshold2Qci1CatM}
...    LNCEL-2/CATMCEL-0:threshold2Qci1CatM=57
...    LNCEL-1/CATMCEL-0:hysThreshold2Qci1CatM=1
...    LNCEL-2/CATMCEL-0:hysThreshold2Qci1CatM=2
...    LNCEL-1/CATMCEL-0:a3OffsetQci1CatM=1
...    LNCEL-2/CATMCEL-0:a3OffsetQci1CatM=2
...    LNCEL-1/CATMCEL-0:hysA3OffsetQci1CatM=1
...    LNCEL-2/CATMCEL-0:hysA3OffsetQci1CatM=2
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1CatM=3
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqQci1CatM=4
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqQci1CatM=5
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqQci1CatM=6
...    LNCEL-1/LNHOIF-1:hysA3OffsetRsrpInterFreqQci1CatM=1
...    LNCEL-1/LNHOIF-2:hysA3OffsetRsrpInterFreqQci1CatM=2
...    LNCEL-2/LNHOIF-1:hysA3OffsetRsrpInterFreqQci1CatM=3
...    LNCEL-2/LNHOIF-2:hysA3OffsetRsrpInterFreqQci1CatM=4
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=${inter_carrierFreq}
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=${inter_carrierFreq_2}
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=${inter_carrierFreq}
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=${inter_carrierFreq_2}
...    LNCEL-3/LNHOIF-1:eutraCarrierInfo=${intra_carrierFreq}
...    LNCEL-3/LNHOIF-2:eutraCarrierInfo=${inter_carrierFreq_2}
...    LNCEL-1/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-2/CATMCEL-0:actInterFreqHoCatM=enabled
...    LNCEL-3/CATMCEL-0:actInterFreqHoCatM=enabled
${threshold2Qci1CatM}    55
${threshold2CatM}    60
${intra_carrierFreq}    1400
${inter_carrierFreq}    1500
${inter_carrierFreq_2}    1550
${threshold2aQci1CatM}    72
${threshold2aCatM}    68
${UE_EUTRA_CAPABILITIES_CATM}    DA28030300082100C1F83F07E0FFFC3062FF282008800886400C08216A7008047480003184000AEC04390A6A03AA14908000000100
# CATM FGI3,7,20 set as 1,enable ROHC

*** Test Cases ***
LTE5303-A-de_ET_06_01_QCI1_Specific_Measurement_Thresholds_for_Activating_A1A2A3_during_QCI1_Bearer_Setup_and_Release_for_UE_with_Gap
    [Tags]    CDRT    owner-xu.wang
    Configure Parameters    ${delta_para_case_569}
    Attach CatM UE with IntrafreqGap and QCI1 bearer setup
    CatM UE Report A2 to trigger rrcConnectionReconfiguration
    Release QCI1 bearer to trigger rrcConnectionReconfiguration
    CatM UE Report A1 to trigger rrcConnectionReconfiguration
    CatM UE Report A2 to trigger rrcConnectionReconfiguration without QCI1
    Setup QCI1 bearer for CatM UE

*** Keywords ***
Setup CUS Env And Common Suite Setup
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Execute Egate Command    trace_sim on mme=1 enb=1 uec=1 protocol=x2,s1,rrc on
    Execute Egate Command    mme_timer T_S1APInitialContextSetup=6000
    Create UE Alias    alias=UE_1    ue_id=1    id_type=cus
    Create MME Alias    MME_1    mme_id=1    id_type=wts

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1, trf_type: external}
    ...      - {qci: 1, preprovisioned: on, gbr_ul: 25, gbr_dl: 25, mbr_ul: 25, mbr_dl: 25, pdn: 1, priority: 1, filter: 1, precedence: 1}
    ...      - {qci: 5, preprovisioned: on, pdn: 1, filter: 5, precedence: 5}

    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2

Configure Parameters
    [Arguments]    ${delta_para}
    Delta Commission Parameters    ${delta_para}
    Cells Should Be OnAir

Attach CatM UE with IntrafreqGap and QCI1 bearer setup
    ${ICS}    catenate
    ...    E-RABToBeSetupListCtxtSUReq contains ( qCI eq 8, qCI eq 1, qCI eq 5 )
    ...    and
    ...    length(E-RABToBeSetupListCtxtSUReq) eq 3
    ${A2_QCI1}    catenate
    ...    measConfig contains (
    ...    measObjectToAddModList contains (measObjectId eq 1 and carrierFreq eq ${intra_carrierFreq})
    ...    and
    ...    reportConfigToAddModList contains (reportConfigId eq 1 and reportConfigEUTRA contains (
    ...    eventA2 contains (a2-Threshold contains (threshold-RSRP eq ${threshold2Qci1CatM})) and hysteresis eq 1))
    ...    and
    ...    measIdToAddModList contains (measId eq 7 and measObjectId eq 1 and reportConfigId eq 1)
    ...    )
    Expect Message Flow
    ...    MME_1:S1AP_InitialContextSetupRequest (${ICS})
    ...    alias=ICS    overall_timeout=20
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A2_QCI1})
    ...    alias=A2_QCI1    overall_timeout=20
    execute uex command    ue_attach id=1 ue_eutra_capabilities=${UE_EUTRA_CAPABILITIES_CATM} enb=1 cell=1
    Flow Occurred As Expected    alias=ICS
    Flow Occurred As Expected    alias=A2_QCI1

CatM UE Report A2 to trigger rrcConnectionReconfiguration
    ${A1_A3_QCI1}    catenate
    ...    measConfig contains (
    ...    measObjectToAddModList contains
    ...    ((measObjectId eq 2 and carrierFreq eq ${inter_carrierFreq}),(measObjectId eq 3 and carrierFreq eq ${inter_carrierFreq_2}))
    ...    and
    ...    reportConfigToAddModList contains (
    ...    (reportConfigId eq 2 and reportConfigEUTRA contains
    ...    ((eventA1 contains ((a1-Threshold contains
    ...    (threshold-RSRP eq ${threshold2aQci1CatM}))) and hysteresis eq 1 and timeToTrigger eq 'ms480'))),
    ...    (reportConfigId eq 3 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 1))),
    ...    (reportConfigId eq 4 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 3))),
    ...    (reportConfigId eq 5 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 4))))
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 2),
    ...    (measId eq 1 and measObjectId eq 1 and reportConfigId eq 3),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 4),
    ...    (measId eq 15 and measObjectId eq 3 and reportConfigId eq 5))
    ...    )
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A1_A3_QCI1})
    ...    alias=A1_A3_QCI1    overall_timeout=20
    execute uex command    ue_measurement_send id=1 event=A2 srsrp=52
    Flow Occurred As Expected    alias=A1_A3_QCI1

Release QCI1 bearer to trigger rrcConnectionReconfiguration
    ${A1_A3}    catenate
    ...    measConfig contains (
    ...    reportConfigToAddModList contains (
    ...    (reportConfigId eq 6 and reportConfigEUTRA contains
    ...    ((eventA1 contains ((a1-Threshold contains (threshold-RSRP eq ${threshold2aCatM}))) and hysteresis eq 1 and timeToTrigger eq 'ms480'))),
    ...    (reportConfigId eq 7 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 4))),
    ...    (reportConfigId eq 8 and reportConfigEUTRA contains (eventA3 contains (a3-Offset eq 5))))
    ...    and
    ...    measIdToRemoveList contains (5,1,14,15)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 6),
    ...    (measId eq 1 and measObjectId eq 1 and reportConfigId eq 3),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 7),
    ...    (measId eq 15 and measObjectId eq 3 and reportConfigId eq 8))
    ...    )
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A1_A3})
    ...    alias=A1_A3    overall_timeout=20
    execute uex command    bearer_del ue=1 qci=1
    Flow Occurred As Expected    alias=A1_A3

CatM UE Report A1 to trigger rrcConnectionReconfiguration
    ${A2}    catenate
    ...    measConfig contains (
    ...    reportConfigToAddModList contains (reportConfigId eq 9 and reportConfigEUTRA contains (
    ...    eventA2 contains (a2-Threshold contains (threshold-RSRP eq ${threshold2CatM})) and hysteresis eq 1 and timeToTrigger eq 'ms480'))
    ...    and
    ...    measIdToRemoveList contains (5,1,14,15)
    ...    and
    ...    measIdToAddModList contains (measId eq 7 and measObjectId eq 1 and reportConfigId eq 9)
    ...    )
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A2})
    ...    alias=A2    overall_timeout=20
    execute uex command    ue_measurement_send id=1 event=A1 srsrp=70
    Flow Occurred As Expected    alias=A2

CatM UE Report A2 to trigger rrcConnectionReconfiguration without QCI1
    ${A1_A3}    catenate
    ...    measConfig contains (
    ...    measIdToRemoveList contains (7)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 6),
    ...    (measId eq 1 and measObjectId eq 1 and reportConfigId eq 3),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 7),
    ...    (measId eq 15 and measObjectId eq 3 and reportConfigId eq 8))
    ...    )
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A1_A3})
    ...    alias=A1_A3    overall_timeout=20
    execute uex command    ue_measurement_send id=1 event=A2 srsrp=53
    Flow Occurred As Expected    alias=A1_A3

Setup QCI1 bearer for CatM UE
    ${A1_A3_QCI1}    catenate
    ...    measConfig contains (
    ...    measIdToRemoveList contains (5,1,14,15)
    ...    and
    ...    measIdToAddModList contains (
    ...    (measId eq 5 and measObjectId eq 1 and reportConfigId eq 2),
    ...    (measId eq 1 and measObjectId eq 1 and reportConfigId eq 3),
    ...    (measId eq 14 and measObjectId eq 2 and reportConfigId eq 4),
    ...    (measId eq 15 and measObjectId eq 3 and reportConfigId eq 5))
    ...    )
    Expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration (${A1_A3_QCI1})
    ...    alias=A1_A3_QCI1    overall_timeout=20
    execute uex command    bearer_add ue=1 qci=1 mbr_dl=25 mbr_ul=25 gbr_dl=25 gbr_ul=25
    Flow Occurred As Expected    alias=A1_A3_QCI1

