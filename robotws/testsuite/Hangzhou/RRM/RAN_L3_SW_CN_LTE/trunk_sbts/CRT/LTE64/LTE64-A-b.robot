*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS
...               DevHZ5_SG4    owner-yin.zhang
Resource          ../../../resources/DevHZ5_resource.robot


*** Variables ***
${SOS_REPORT_FLAG}    pass:False,fail:False
@{PARAMS_IN_SCF}
...  @{PARAMS_Feature_Related_Switch}
...  @{PARAMS_Measurement_Thresholds}
...  @{PARAMS_IRAT_WCDMA_Neighbor1}
...  @{PARAMS_IRAT_WCDMA_Neighbor2}
...  @{PARAMS_IRAT_GSM_Neighbor1}
...  @{PARAMS_IRAT_GSM_Neighbor2}
...  @{PARAMS_IFHO_Neighbor1}
...  @{PARAMS_IFHO_Neighbor2}

@{PARAMS_Feature_Related_Switch}
...  LNBTS-1:actIfHo=enabled
...  LNBTS-1:actRedirect=enabled
...  LNBTS-1:actHOtoWcdma=true
...  LNBTS-1:actHOtoHrpd=false
...  LNBTS-1:actHoFromUtran=true
...  LNBTS-1:acteNACCtoGSM=true
...  LNBTS-1:actMultBearers=true
...  LNBTS-1:actImmHRPD=true
...  LNBTS-1:actServBasedMobThr=true
...  LNBTS-1/LNBTS_TDD-0:actSrvccToWcdma=true
...  LNBTS-1/LNBTS_TDD-0:actSrvccToGsm=true
...  LNBTS-1/LNBTS_TDD-0:actConvVoice=true
...  LNBTS-1/LNBTS_TDD-0:act1xSrvcc=false
...  LNBTS-1/LNBTS_TDD-0:preventPsHOtoWcdma=None
...  LNCEL-1:a2RedirectQci1=enabled
...  LNCEL-1:enableBetterCellHo=true
...  LNCEL-1:enableCovHo=true
...  LNCEL-1:inactivityTimer=600
...  delete:LNCEL-1:qci1ProtectionTimer
...  LNCEL-1/LNCEL_TDD-0:earfcn=38000
...  delete:MOPR.*
...  delete:MODPR.*
...  delete:LNCEL:moPrMappingList

@{PARAMS_Measurement_Thresholds}
...  LNCEL-1:threshold2aQci1=70
...  LNCEL-1:threshold2a=65
...  LNCEL-1:threshold2InterFreqQci1=55
...  LNCEL-1:threshold2InterFreq=50
...  LNCEL-1:threshold2WcdmaQci1=45
...  LNCEL-1:threshold2Wcdma=45
...  LNCEL-1:threshold2GERANQci1=60
...  LNCEL-1:threshold2GERAN=55
...  LNCEL-1:threshold4=19
...  LNCEL-1:a3Offset=6
...  LNCEL-1:threshold3=30
...  LNCEL-1:threshold3a=31
...  LNCEL-1:hysThreshold2a=0
...  LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=10
...  LNCEL-1:rsrqMobilityParams:threshold2aRsrq=16
...  LNCEL-1:rsrqMobilityParams:hysThreshold2MobRsrq=0
...  LNCEL-1:rsrqRedirectParams:hysThreshold4Rsrq=0
...  LNCEL-1:rsrqRedirectParams:threshold4Rsrq=-38
...  LNCEL-1:threshold2aHpue=70

@{PARAMS_IRAT_WCDMA_Neighbor1}
...  LNADJW-1:uTargetScFdd=11
...  LNADJW-1:uTargetCid=11
...  LNADJW-1:uTargetFreq=10650
...  LNADJW-1:uTargetLac=11
...  LNADJW-1:uTargetRncId=11
...  LNADJW-1:uTargetRac=11
...  LNADJW-1:srvccHoInd=PSandCS
...  LNADJW-1:primaryPlmnId:mcc=262
...  LNADJW-1:primaryPlmnId:mnc=3
...  LNADJW-1:primaryPlmnId:mncLength=2
...  LNCEL-1/LNHOW-1:reportIntervalUtra=480ms
...  LNCEL-1/LNHOW-1:maxNumCsfbTargets=16
...  LNCEL-1/LNHOW-1:hysB1ThresholdCSFBUtra=0
...  LNCEL-1/LNHOW-1:hysB2ThresholdUtra=4
...  LNCEL-1/LNHOW-1:b2Threshold1Utra=24
...  LNCEL-1/LNHOW-1:b2TimeToTriggerUtraMeas=320ms
...  LNCEL-1/LNHOW-1:b1TimeToTriggerCSFBUtraMeas=256ms
...  LNCEL-1/LNHOW-1:utraCarrierFreq=10650
...  LNCEL-1/LNHOW-1:offsetFreqUtra=0
...  LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraEcn0=12
...  LNCEL-1/LNHOW-1:b1ThresholdCSFBUtraRscp=5
...  LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0=21
...  LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=11
...  LNCEL-1/LNHOW-1:b2Threshold1UtraQci1=${EMPTY}
...  LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0Qci1=${EMPTY}
...  LNCEL-1/LNHOW-1:b2Threshold2UtraRscpQci1=${EMPTY}
...  LNCEL-1/LNRELW-1:csfbPsHoAllowed=forbidden
#...  LNCEL-1/LNRELW-1:utranLbAllowed=true varidation error, must set to false
...  LNCEL-1/LNRELW-1:utranLbAllowed=false
...  LNCEL-1/LNRELW-1:nrControl=automatic
...  LNCEL-1/LNRELW-1:psHoAllowed=allowed
...  LNCEL-1/LNRELW-1:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-1:removeAllowed=true
...  LNCEL-1/LNRELW-1:srvccAllowed=allowed
...  LNCEL-1/LNRELW-1:uTargetCid=11
...  LNCEL-1/LNRELW-1:uTargetRncId=11
...  LNCEL-1/LNRELW-1:plmnId:mcc=262
...  LNCEL-1/LNRELW-1:plmnId:mnc=3
...  LNCEL-1/LNRELW-1:plmnId:mncLength=2

@{PARAMS_IRAT_WCDMA_Neighbor2}
...  LNADJW-2:uTargetScFdd=12
...  LNADJW-2:uTargetCid=12
...  LNADJW-2:uTargetFreq=10700
...  LNADJW-2:uTargetLac=12
...  LNADJW-2:uTargetRncId=12
...  LNADJW-2:uTargetRac=12
...  LNADJW-2:srvccHoInd=PSandCS
...  LNADJW-2:primaryPlmnId:mcc=262
...  LNADJW-2:primaryPlmnId:mnc=3
...  LNADJW-2:primaryPlmnId:mncLength=2
...  LNCEL-1/LNHOW-2:reportIntervalUtra=480ms
...  LNCEL-1/LNHOW-2:maxNumCsfbTargets=16
...  LNCEL-1/LNHOW-2:hysB1ThresholdCSFBUtra=0
...  LNCEL-1/LNHOW-2:hysB2ThresholdUtra=4
...  LNCEL-1/LNHOW-2:b2Threshold1Utra=23
...  LNCEL-1/LNHOW-2:b2TimeToTriggerUtraMeas=320ms
...  LNCEL-1/LNHOW-2:b1TimeToTriggerCSFBUtraMeas=256ms
...  LNCEL-1/LNHOW-2:utraCarrierFreq=10700
...  LNCEL-1/LNHOW-2:offsetFreqUtra=0
...  LNCEL-1/LNHOW-2:b1ThresholdCSFBUtraEcn0=12
...  LNCEL-1/LNHOW-2:b1ThresholdCSFBUtraRscp=5
...  LNCEL-1/LNHOW-2:b2Threshold2UtraEcn0=19
...  LNCEL-1/LNHOW-2:b2Threshold2UtraRscp=10
...  LNCEL-1/LNHOW-2:b2Threshold1UtraQci1=30
...  LNCEL-1/LNHOW-2:b2Threshold2UtraEcn0Qci1=20
...  LNCEL-1/LNHOW-2:b2Threshold2UtraRscpQci1=15
...  LNCEL-1/LNRELW-2:csfbPsHoAllowed=forbidden
#...  LNCEL-1/LNRELW-2:utranLbAllowed=true varidation error, must set to false
...  LNCEL-1/LNRELW-2:utranLbAllowed=false
...  LNCEL-1/LNRELW-2:nrControl=automatic
...  LNCEL-1/LNRELW-2:psHoAllowed=allowed
...  LNCEL-1/LNRELW-2:redirWithSysInfoAllowed=allowed
...  LNCEL-1/LNRELW-2:removeAllowed=true
...  LNCEL-1/LNRELW-2:srvccAllowed=allowed
...  LNCEL-1/LNRELW-2:uTargetCid=12
...  LNCEL-1/LNRELW-2:uTargetRncId=12
...  LNCEL-1/LNRELW-2:plmnId:mcc=262
...  LNCEL-1/LNRELW-2:plmnId:mnc=3
...  LNCEL-1/LNRELW-2:plmnId:mncLength=2

@{PARAMS_IRAT_GSM_Neighbor1}
...  LNADJG-1:arfcnValueGeran=513
...  LNADJG-1:bandIndicatorGeran=dcs1800
...  LNADJG-1:basestationColourCode=0
...  LNADJG-1:gTargetCi=0
...  LNADJG-1:dtm=false
...  LNADJG-1:gTargetLac=0
...  LNADJG-1:mcc=262
...  LNADJG-1:mnc=3
...  LNADJG-1:mncLength=2
...  LNADJG-1:networkColourCode=0
...  LNADJG-1:networkControlOrder=NC0
...  LNADJG-1:gTargetRac=0
...  LNADJG-1:systemInfoType=none
...  LNCEL-1/LNHOG-1:bandIndicatorGERAN=dcs1800
...  LNCEL-1/LNHOG-1:reportIntervalGERAN=480ms
...  LNCEL-1/LNHOG-1:nccperm=0
...  LNCEL-1/LNHOG-1:hysB2ThresholdGERAN=4
...  LNCEL-1/LNHOG-1:b2Threshold2RssiGERAN=16
...  LNCEL-1/LNHOG-1:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-1/LNHOG-1:b2Threshold1GERANQci1=${EMPTY}
...  LNCEL-1/LNHOG-1:b2Threshold1GERAN=21
...  LNCEL-1/LNHOG-1:b2Threshold2RssiGERANQci1=${EMPTY}
...  LNCEL-1/LNHOG-1:arfcnValueListGERAN=513
...  LNCEL-1/LNRELG-1:ci=0
...  LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-1:lac=0
...  LNCEL-1/LNRELG-1:nrControl=automatic
...  LNCEL-1/LNRELG-1:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELG-1:srvccAllowed=allowed
...  LNCEL-1/LNRELG-1:plmnId:mcc=262
...  LNCEL-1/LNRELG-1:plmnId:mnc=3
...  LNCEL-1/LNRELG-1:plmnId:mncLength=2

@{PARAMS_IRAT_GSM_Neighbor2}
...  LNADJG-2:arfcnValueGeran=514
...  LNADJG-2:bandIndicatorGeran=dcs1800
...  LNADJG-2:basestationColourCode=0
...  LNADJG-2:gTargetCi=1
...  LNADJG-2:dtm=false
...  LNADJG-2:gTargetLac=1
...  LNADJG-2:mcc=262
...  LNADJG-2:mnc=3
...  LNADJG-2:mncLength=2
...  LNADJG-2:networkColourCode=0
...  LNADJG-2:networkControlOrder=NC0
...  LNADJG-2:gTargetRac=1
...  LNADJG-2:systemInfoType=none
...  LNCEL-1/LNHOG-2:bandIndicatorGERAN=dcs1800
...  LNCEL-1/LNHOG-2:reportIntervalGERAN=480ms
...  LNCEL-1/LNHOG-2:nccperm=0
...  LNCEL-1/LNHOG-2:hysB2ThresholdGERAN=4
...  LNCEL-1/LNHOG-2:b2Threshold2RssiGERAN=15
...  LNCEL-1/LNHOG-2:b2TimeToTriggerGERANMeas=512ms
...  LNCEL-1/LNHOG-2:b2Threshold1GERANQci1=30
...  LNCEL-1/LNHOG-2:b2Threshold1GERAN=20
...  LNCEL-1/LNHOG-2:b2Threshold2RssiGERANQci1=10
...  LNCEL-1/LNHOG-2:arfcnValueListGERAN=514
...  LNCEL-1/LNRELG-2:ci=1
...  LNCEL-1/LNRELG-2:eNACCAllowed=allowed
...  LNCEL-1/LNRELG-2:lac=1
...  LNCEL-1/LNRELG-2:nrControl=automatic
...  LNCEL-1/LNRELG-2:redirWithSysInfoAllowed=forbidden
...  LNCEL-1/LNRELG-2:srvccAllowed=allowed
...  LNCEL-1/LNRELG-2:plmnId:mcc=262
...  LNCEL-1/LNRELG-2:plmnId:mnc=3
...  LNCEL-1/LNRELG-2:plmnId:mncLength=2

@{PARAMS_IFHO_Neighbor1}
...  LNADJ-1:cPlaneIpAddrCtrl=oamControlled
...  LNADJ-1:rlfBasedRCRsupported=false
...  LNADJ-1:cPlaneIpAddr=1.1.1.1
...  LNADJ-1:adjEnbId=1001
...  LNADJ-1:plmnId:mcc=262
...  LNADJ-1:plmnId:mnc=3
...  LNADJ-1:plmnId:mncLength=2
...  LNADJ-1/LNADJL-1:fDlEarfcn=37960
...  LNADJ-1/LNADJL-1:ecgiLcrId=11
...  LNADJ-1/LNADJL-1:phyCellId=11
...  LNADJ-1/LNADJL-1:tac=666
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mcc=262
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mnc=3
...  LNADJ-1/LNADJL-1:bcPlmnIdList:mncLength=2
...  LNCEL-1/LNHOIF-1:eutraCarrierInfo=37960
...  LNCEL-1/LNHOIF-1:threshold3InterFreq=25
...  LNCEL-1/LNHOIF-1:threshold3aInterFreq=27
...  LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=4
...  LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1=${EMPTY}
...  LNCEL-1/LNHOIF-1:threshold3InterFreqQci1=${EMPTY}
...  LNCEL-1/LNHOIF-1:threshold3aInterFreqQci1=${EMPTY}
...  LNCEL-1/LNREL-1:ecgiLcrId=11
...  LNCEL-1/LNREL-1:cellIndOffNeigh=1dB
...  LNCEL-1/LNREL-1:ecgiAdjEnbId=1001
...  LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...  LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...  LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2

@{PARAMS_IFHO_Neighbor2}
...  LNADJ-2:cPlaneIpAddrCtrl=oamControlled
...  LNADJ-2:rlfBasedRCRsupported=false
...  LNADJ-2:cPlaneIpAddr=2.2.2.2
...  LNADJ-2:adjEnbId=1002
...  LNADJ-2:plmnId:mcc=262
...  LNADJ-2:plmnId:mnc=3
...  LNADJ-2:plmnId:mncLength=2
...  LNADJ-2/LNADJL-2:fDlEarfcn=37980
...  LNADJ-2/LNADJL-2:ecgiLcrId=21
...  LNADJ-2/LNADJL-2:phyCellId=21
...  LNADJ-2/LNADJL-2:tac=666
...  LNADJ-2/LNADJL-2:bcPlmnIdList:mcc=262
...  LNADJ-2/LNADJL-2:bcPlmnIdList:mnc=3
...  LNADJ-2/LNADJL-2:bcPlmnIdList:mncLength=2
...  LNCEL-1/LNHOIF-2:eutraCarrierInfo=37980
...  LNCEL-1/LNHOIF-2:threshold3InterFreq=24
...  LNCEL-1/LNHOIF-2:threshold3aInterFreq=26
...  LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreq=6
...  LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqQci1=8
...  LNCEL-1/LNHOIF-2:threshold3InterFreqQci1=20
...  LNCEL-1/LNHOIF-2:threshold3aInterFreqQci1=30
...  LNCEL-1/LNREL-2:ecgiLcrId=21
...  LNCEL-1/LNREL-2:cellIndOffNeigh=1dB
...  LNCEL-1/LNREL-2:ecgiAdjEnbId=1002
...  LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...  LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...  LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2

@{Online_Commission_List_For_01_05}
...  LNCEL-1:threshold2InterFreqQci1=55
...  LNCEL-1:threshold2InterFreq=60
...  LNCEL-1:threshold2WcdmaQci1=50
...  LNCEL-1:threshold2Wcdma=50
...  LNCEL-1:threshold2GERANQci1=45
...  LNCEL-1:threshold2GERAN=45
...  LNCEL-1:a2RedirectQci1=disabled
...  LNBTS-1:actServBasedMobThr=false

${ue_eutra_cap}    C59FF43032E78D040E07FFFFFFFFF8100E6040100000004C1000

${UE_ATTACH_RRC}
...    measConfig contains (
...      measObjectToAddModList contains (
...        measObjectId eq 1 and measObjectEUTRA contains (carrierFreq eq 38000)
...      )and
...      reportConfigToAddModList contains (
...        reportConfigId eq 1 and eventA3 contains (a3-Offset eq 6),
...        reportConfigId eq 2 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 30) and
...          a5-Threshold2 contains (threshold-RSRP eq 31)),
...        reportConfigId eq 3 and eventA2 contains (a2-Threshold contains (threshold-RSRP eq 60)),
...        reportConfigId eq 4 and eventA2 contains (a2-Threshold contains (threshold-RSRQ eq 10))
...      )and
...      measIdToAddModList contains (
...        (measId eq 1 and measObjectId eq 1 and reportConfigId eq 1),
...        (measId eq 2 and measObjectId eq 1 and reportConfigId eq 2),
...        (measId eq 7 and measObjectId eq 1 and reportConfigId eq 3),
...        (measId eq 12 and measObjectId eq 1 and reportConfigId eq 4)
...      )
...    )

${IFA2_MSG1}
...    measConfig contains (
...      measObjectToAddModList contains (
...        (measObjectId eq 2 and measObjectEUTRA contains (carrierFreq eq 37960)),
...        (measObjectId eq 3 and measObjectEUTRA contains (carrierFreq eq 37980)),
...        (measObjectId eq 4 and measObjectUTRA contains (carrierFreq eq 10650)),
...        (measObjectId eq 5 and measObjectUTRA contains (carrierFreq eq 10700)),
...        (measObjectId eq 6 and measObjectGERAN contains (startingARFCN eq 513)),
...        (measObjectId eq 7 and measObjectGERAN contains (startingARFCN eq 514))
...      )and
...      reportConfigToAddModList contains (
...        reportConfigId eq 5 and eventA1 contains (a1-Threshold contains (threshold-RSRP eq 65)),
...        reportConfigId eq 6 and eventA3 contains (a3-Offset eq 4),
...        reportConfigId eq 7 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 25) and
...          a5-Threshold2 contains (threshold-RSRP eq 27)),
...        reportConfigId eq 8 and eventA3 contains (a3-Offset eq 6),
...        reportConfigId eq 9 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 24) and
...          a5-Threshold2 contains (threshold-RSRP eq 26)),
...        reportConfigId eq 10 and eventB2 contains (b2-Threshold1 contains (threshold-RSRP eq 24) and
...          b2-Threshold2 contains (utra-RSCP eq 11)),
...        reportConfigId eq 11 and eventB2 contains (b2-Threshold1 contains (threshold-RSRP eq 23) and
...          b2-Threshold2 contains (utra-RSCP eq 10)),
...        reportConfigId eq 12 and eventB2 contains (b2-Threshold1 contains (threshold-RSRP eq 21) and
...          b2-Threshold2 contains (b2-Threshold2GERAN eq 16)),
...        reportConfigId eq 13 and eventB2 contains (b2-Threshold1 contains (threshold-RSRP eq 20) and
...          b2-Threshold2 contains (b2-Threshold2GERAN eq 15))
...      )and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 1 and reportConfigId eq 5),
...        (measId eq 14 and measObjectId eq 2 and reportConfigId eq 6),
...        (measId eq 15 and measObjectId eq 2 and reportConfigId eq 7),
...        (measId eq 16 and measObjectId eq 3 and reportConfigId eq 8),
...        (measId eq 17 and measObjectId eq 3 and reportConfigId eq 9),
...        (measId eq 18 and measObjectId eq 4 and reportConfigId eq 10),
...        (measId eq 19 and measObjectId eq 5 and reportConfigId eq 11),
...        (measId eq 20 and measObjectId eq 6 and reportConfigId eq 12),
...        (measId eq 21 and measObjectId eq 7 and reportConfigId eq 13)
...      )
...    )

${A1_MSG1}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        reportConfigId eq 14 and eventA2 contains (a2-Threshold contains (threshold-RSRP eq 55))
...      )and
...      measIdToRemoveList contains (5,18,19,20,21,15,17,14,16)and
...      measIdToAddModList contains (
...        (measId eq 12 and measObjectId eq 1 and reportConfigId eq 4),
...        (measId eq 7 and measObjectId eq 1 and reportConfigId eq 14)
...      )
...    )

${IFA2_MSG2}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        reportConfigId eq 15 and eventA1 contains (a1-Threshold contains (threshold-RSRP eq 70)),
...        reportConfigId eq 16 and eventA3 contains (a3-Offset eq 8),
...        reportConfigId eq 17 and eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 20) and
...          a5-Threshold2 contains (threshold-RSRP eq 30)),
...        reportConfigId eq 18 and eventB2 contains (b2-Threshold1 contains (threshold-RSRP eq 30) and
...          b2-Threshold2 contains (utra-RSCP eq 15)),
...        reportConfigId eq 19 and eventB2 contains (b2-Threshold1 contains (threshold-RSRP eq 30) and
...          b2-Threshold2 contains (b2-Threshold2GERAN eq 10))
...      )and
...      measIdToRemoveList contains (12,7)and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 1 and reportConfigId eq 15),
...        (measId eq 14 and measObjectId eq 2 and reportConfigId eq 6),
...        (measId eq 15 and measObjectId eq 2 and reportConfigId eq 7),
...        (measId eq 16 and measObjectId eq 3 and reportConfigId eq 16),
...        (measId eq 17 and measObjectId eq 3 and reportConfigId eq 17),
...        (measId eq 18 and measObjectId eq 4 and reportConfigId eq 10),
...        (measId eq 19 and measObjectId eq 5 and reportConfigId eq 18),
...        (measId eq 20 and measObjectId eq 6 and reportConfigId eq 12),
...        (measId eq 21 and measObjectId eq 7 and reportConfigId eq 19)
...      )
...    )

${A1_MSG2}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        reportConfigId eq 20 and eventA2 contains (a2-Threshold contains (threshold-RSRP eq 19))
...      )and
...      measIdToRemoveList contains (5,18,19,20,21,15,17,14,16)and
...      measIdToAddModList contains (
...        (measId eq 12 and measObjectId eq 1 and reportConfigId eq 4),
...        (measId eq 7 and measObjectId eq 1 and reportConfigId eq 14),
...        (measId eq 4 and measObjectId eq 1 and reportConfigId eq 20)
...      )
...    )

${IFA2_MSG3}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        reportConfigId eq 21 and eventA2 contains (a2-Threshold contains (threshold-RSRQ eq 2))
...      )and
...      measIdToRemoveList contains (12,7)and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 1 and reportConfigId eq 15),
...        (measId eq 12 and measObjectId eq 1 and reportConfigId eq 21),
...        (measId eq 14 and measObjectId eq 2 and reportConfigId eq 6),
...        (measId eq 15 and measObjectId eq 2 and reportConfigId eq 7),
...        (measId eq 16 and measObjectId eq 3 and reportConfigId eq 16),
...        (measId eq 17 and measObjectId eq 3 and reportConfigId eq 17),
...        (measId eq 18 and measObjectId eq 4 and reportConfigId eq 10),
...        (measId eq 19 and measObjectId eq 5 and reportConfigId eq 18),
...        (measId eq 20 and measObjectId eq 6 and reportConfigId eq 12),
...        (measId eq 21 and measObjectId eq 7 and reportConfigId eq 19)
...      )
...    )

*** Test Cases ***
LTE64-A-b_01_05 VoLTE mobility thresholds reconfiguration Initial Context Setup with QCI1 bearer feature online change
    [Tags]
    Set Parameters For A-b_01_05
    CUS UE Attach To ENB
    Report IF A2 with threshold2GERANQci1>RSRP    IFA2_MSG=${IFA2_MSG1}
    Online Change actServBasedMobThr to true
    Report A1 with RSRP>threshold2aQci1           A1_MSG=${A1_MSG1}
    Report IF A2 with threshold2GERANQci1>RSRP    IFA2_MSG=${IFA2_MSG2}
    Online Change a2RedirectQci1 to enabled
    Report A1 with RSRP>threshold2aQci1           A1_MSG=${A1_MSG2}
    Report IF A2 with threshold2GERANQci1>RSRP    IFA2_MSG=${IFA2_MSG3}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Alias    UE_1    ue_id=1    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Execute Uex Command    ue_param id=1 csfb_rat=utran_geran voice_domain_preference=lte_preferred

Set Parameters For A-b_01_05
    [Documentation]    LNCEL-1:threshold2InterFreqQci1=55
    ...    LNCEL-1:threshold2InterFreq=60
    ...    LNCEL-1:threshold2WcdmaQci1=50
    ...    LNCEL-1:threshold2Wcdma=50
    ...    LNCEL-1:threshold2GERANQci1=45
    ...    LNCEL-1:threshold2GERAN=45
    ...    LNCEL-1:a2RedirectQci1=disabled
    ...    LNBTS-1:actServBasedMobThr=false
    Delta Commission Parameters And Wait Cells Onair    ${Online_Commission_List_For_01_05}

Modify Yaml
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 8, default: on, pdn: 1}
    ...     - {qci: 1, gbr_ul: 256, gbr_dl: 256, mbr_ul: 256, mbr_dl: 256, preprovisioned: on, filter: 1, precedence: 1}
    Update Yaml    UEs/UE_sets/1    bearer: bearer_set_2

CUS UE Attach To ENB
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${UE_ATTACH_RRC})
    ...    alias=ue_attach_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=${ue_id} ue_eutra_capabilities=${ue_eutra_cap} cell=1
    Flow Occurred As Expected    alias=ue_attach_flow

Report IF A2 with threshold2GERANQci1>RSRP
    [Arguments]    ${ue_id}=1    ${IFA2_MSG}=${IFA2_MSG1}
    [Documentation]    LNCEL-1:threshold2InterFreq=60
    ...    LNCEL-1:threshold2InterFreqQci1=55
    ...    LNCEL-1:threshold2WcdmaQci1=50
    ...    LNCEL-1:threshold2Wcdma=50
    ...    LNCEL-1:threshold2GERANQci1=45
    ...    LNCEL-1:threshold2GERAN=45
    ${srsrp}    Set Variable    42
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${IFA2_MSG})
    ...    alias=IF_A2    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=${srsrp} srsrq=33 meas_id_blacklist=4,12 amount=1
    Flow Occurred As Expected    alias=IF_A2

Online Change actServBasedMobThr to true
    Delta Commission Parameters And Wait Cells Onair    LNBTS-1:actServBasedMobThr=true

Report A1 with RSRP>threshold2aQci1
    [Arguments]    ${ue_id}=1    ${A1_MSG}=${A1_MSG1}
    [Documentation]    LNCEL-1:threshold2aQci1=70
    ...    LNCEL-1:threshold2a=65
    ...    LNCEL-1:threshold2InterFreqQci1=55
    ...    LNCEL-1:threshold2InterFreq=50
    ...    LNCEL-1:threshold2WcdmaQci1=45
    ...    LNCEL-1:threshold2Wcdma=45
    ...    LNCEL-1:threshold2GERANQci1=60
    ...    LNCEL-1:threshold2GERAN=55
    ...    LNCEL-1:threshold4=19
    ${srsrp}    Set Variable    73
     Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${A1_MSG})
    ...    alias=A1MSG    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A1 srsrp=${srsrp} srsrq=33 amount=1
    Flow Occurred As Expected    alias=A1MSG

Online Change a2RedirectQci1 to enabled
    Delta Commission Parameters And Wait Cells Onair    LNCEL-1:a2RedirectQci1=enabled
    sleep    5s    #make CUS send command more stable