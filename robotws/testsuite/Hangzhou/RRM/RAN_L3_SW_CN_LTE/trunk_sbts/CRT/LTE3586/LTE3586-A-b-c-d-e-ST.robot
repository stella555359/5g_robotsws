*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_TDD    CRT    CLOUD_R4LAPO_CUS
...               release-TL17SP    DevHZ5FT2    owner-junli.chang
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${SOS_REPORT_FLAG}    pass:False,fail:False
@{PARAMS_IN_SCF}
...    @{Related_Feature_Switch}
...    @{LTE_IF_Neighbor_Param}
...    @{WCDMA_Neighbor_Param}
...    @{GERAN_Neighbor_Param}

@{Related_Feature_Switch}
...    LNBTS-1:actMultBearers=true
...    LNBTS-1/LNBTS_TDD-0:actConvVoice=true
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1:actHOtoWcdma=true
...    LNBTS-1:actHoFromUtran=true
...    LNBTS-1:actRedirect=enabled
...    LNBTS-1:acteNACCtoGSM=true
...    LNBTS-1/LNBTS_TDD-0:actSrvccToWcdma=true
...    LNBTS-1/LNBTS_TDD-0:actSrvccToGsm=true
...    LNBTS-1:actServBasedMobThr=true
...    LNBTS-1:actImmHRPD=true
...    LNBTS-1:pwrFallbackCa=true
...    LNBTS-1:actDLCAggr=false
...    LNBTS-1/LNBTS_TDD-0:preventPsHOtoWcdma=None
...    LNCEL:a2RedirectQci1=enabled
...    LNCEL:ulsMinTbs=104
...    LNCEL:ulsMinRbPerUe=3
...    LNCEL:actUePowerBasedMobThr=true
...    LNCEL:rsrqRedirectParams:threshold4Rsrq=-38
...    LNCEL:cellTechnology=TDD
...    LNCEL:a3Offset=2
...    LNCEL:threshold3=65
...    LNCEL:threshold3a=66
...    delete:MODPR.*
...    delete:MOPR.*
...    delete:LNCEL-1:moPrMappingList
...    delete:LNCEL-2:moPrMappingList
...    delete:LNCEL-3:moPrMappingList

@{LTE_IF_Neighbor_Param}
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.3
...    LNBTS-1/LNADJ-1:adjEnbId=11
...    LNBTS-1/LNADJ-1/LNADJL-1:ecgiLcrId=11
...    LNBTS-1/LNADJ-1/LNADJL-1:phyCellId=11
...    LNBTS-1/LNADJ-1/LNADJL-1:fDlEarfcn=40940
...    LNBTS-1/LNADJ-1/LNADJL-1:tac=666
...    LNBTS-1/LNADJ-2:cPlaneIpAddr=10.0.1.4
...    LNBTS-1/LNADJ-2:adjEnbId=22
...    LNBTS-1/LNADJ-2/LNADJL-1:ecgiLcrId=22
...    LNBTS-1/LNADJ-2/LNADJL-1:phyCellId=22
...    LNBTS-1/LNADJ-2/LNADJL-1:fDlEarfcn=41138
...    LNBTS-1/LNADJ-2/LNADJL-1:tac=666
...    LNBTS-1/LNADJ-3:cPlaneIpAddr=1.0.1.3
...    LNBTS-1/LNADJ-3:adjEnbId=74566
...    LNBTS-1/LNADJ-3/LNADJL-1:ecgiLcrId=103
...    LNBTS-1/LNADJ-3/LNADJL-1:phyCellId=9
...    LNBTS-1/LNADJ-3/LNADJL-1:fDlEarfcn=40940
...    LNBTS-1/LNADJ-3/LNADJL-1:tac=321
...    LNBTS-1/LNADJ-4:cPlaneIpAddr=1.0.1.4
...    LNBTS-1/LNADJ-4:adjEnbId=74567
...    LNBTS-1/LNADJ-4/LNADJL-1:ecgiLcrId=103
...    LNBTS-1/LNADJ-4/LNADJL-1:phyCellId=12
...    LNBTS-1/LNADJ-4/LNADJL-1:fDlEarfcn=41138
...    LNBTS-1/LNADJ-4/LNADJL-1:tac=321
...    LNCEL-1/LNREL-3:ecgiLcrId=103
...    LNCEL-1/LNREL-3:ecgiAdjEnbId=74567
...    LNCEL-1/LNREL-3:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-3:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-3:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-4:handoverAllowed=allowed
...    LNCEL-1/LNREL-4:ecgiLcrId=103
...    LNCEL-1/LNREL-4:ecgiAdjEnbId=74566
...    LNCEL-1/LNREL-4:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-4:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-4:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNREL-1:ecgiLcrId=2
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40940
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=41138
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
...    LNCEL-2/LNCEL_TDD-0:earfcn=40940
...    LNCEL-3/LNCEL_TDD-0:earfcn=41138

@{WCDMA_Neighbor_Param}
...    LNBTS-1/LNADJW-1:uTargetFreq=10638
...    LNBTS-1/LNADJW-1:uTargetScFdd=12
...    LNBTS-1/LNADJW-1:srvccHoInd=PSandCS
...    LNBTS-1/LNADJW-1:uTargetCid=12
...    LNBTS-1/LNADJW-1:uTargetLac=12
...    LNBTS-1/LNADJW-1:uTargetRncId=12
...    LNBTS-1/LNADJW-1:uTargetRac=12
...    LNBTS-1/LNADJW-1:primaryPlmnId:mcc=262
...    LNBTS-1/LNADJW-1:primaryPlmnId:mnc=3
...    LNBTS-1/LNADJW-1:primaryPlmnId:mncLength=2
...    LNCEL-1/LNHOW-1:utraCarrierFreq=10638
...    LNCEL-1/LNHOW-1:b2Threshold1Utra=24
...    LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0=20
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscp=11
...    LNCEL-1/LNRELW-1:psHoAllowed=allowed
...    LNCEL-1/LNRELW-1:srvccAllowed=allowed
...    LNCEL-1/LNRELW-1:uTargetCid=12
...    LNCEL-1/LNRELW-1:uTargetRncId=12
...    LNCEL-1/LNRELW-1:plmnId:mcc=262
...    LNCEL-1/LNRELW-1:plmnId:mnc=3
...    LNCEL-1/LNRELW-1:plmnId:mncLength=2

@{GERAN_Neighbor_Param}
...    LNBTS-1/LNADJG-1:arfcnValueGeran=512
...    LNBTS-1/LNADJG-1:bandIndicatorGeran=dcs1800
...    LNBTS-1/LNADJG-1:basestationColourCode=0
...    LNBTS-1/LNADJG-1:gTargetCi=0
...    LNBTS-1/LNADJG-1:dtm=false
...    LNBTS-1/LNADJG-1:gTargetLac=0
...    LNBTS-1/LNADJG-1:mcc=262
...    LNBTS-1/LNADJG-1:mnc=3
...    LNBTS-1/LNADJG-1:mncLength=2
...    LNBTS-1/LNADJG-1:networkColourCode=0
...    LNBTS-1/LNADJG-1:networkControlOrder=NC0
...    LNCEL-1/LNHOG-1:b2Threshold1GERAN=21
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERAN=16
...    LNCEL-1/LNHOG-1:b2Threshold1GERANQci1=22
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERANQci1=17
...    LNCEL-1/LNHOG-1:arfcnValueListGERAN=512
...    LNCEL-1/LNHOG-1:bandIndicatorGERAN=dcs1800
...    LNCEL-1/LNRELG-1:eNACCAllowed=allowed
...    LNCEL-1/LNRELG-1:srvccAllowed=allowed
...    LNCEL-1/LNRELG-1:ci=0
...    LNCEL-1/LNRELG-1:lac=0
...    LNCEL-1/LNRELG-1:plmnId:mcc=262
...    LNCEL-1/LNRELG-1:plmnId:mnc=3
...    LNCEL-1/LNRELG-1:plmnId:mncLength=2

@{OnlineChangeList_A-e}
#zkx add for case robustness
...    LNBTS-1:caUlIntraBandAmpr=enabled
...    LNBTS-1:pwrFallbackCa=false
...    LNBTS-1:sCellDeactivationTimereNB=rf8
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNCEL-1/CAPR-1:earfcnDL=40940
...    LNCEL-1/CAPR-2:earfcnDL=41138
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:scellPrio=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:cellSrPeriod=40ms
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nCqiRb=8
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=2
...    LNBTS-1:multScellReleaseTimer=100
...    LNCEL-1/CAPR-0:maxNumScellSwaps=2
...    LNCEL-1/CAPR-1:maxNumScellSwaps=2
...    LNCEL-1/CAPR-2:maxNumScellSwaps=2
...    LNBTS-1/CADPR-0:maxNumScellSwaps=2
...    LNCEL-1:maxNumScells=2
...    LNBTS-1:sCellDeactivationTimereNB=rf8
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNCEL-1:threshold2GERANQci1=40
...    LNCEL-1:threshold2WcdmaQci1=45
...    LNCEL-1/LNHOIF-2:rsrqA5InterFreqMobilityParams:threshold3RsrqInterFreq=-29
...    LNCEL-1/LNHOIF-2:rsrqA5InterFreqMobilityParams:threshold3aRsrqInterFreq=-24
...    LNCEL-2:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-2:rsrqMobilityParams:threshold2aRsrq=16
...    LNCEL-3:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-3:rsrqMobilityParams:threshold2aRsrq=16
...    LNBTS-1:enableCombRsrpRsrq=false
...    LNBTS-1:actDLCAggr=false
...    LNBTS-1:actULCAggr=false
...    LNBTS-1:actAdvScellMeas=false
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqHpue=2
...    LNCEL-1/LNHOIF-1:threshold3InterFreqHpue=26
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqHpue=28
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1=4
...    LNCEL-1/LNHOIF-1:threshold3InterFreqQci1=25
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqQci1=27
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1/LNHOIF-1:threshold3InterFreq=24
...    LNCEL-1/LNHOIF-1:threshold3aInterFreq=26
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqHpue=${EMPTY}
...    LNCEL-1/LNHOIF-2:threshold3InterFreqHpue=${EMPTY}
...    LNCEL-1/LNHOIF-2:threshold3aInterFreqHpue=${EMPTY}
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqQci1=10
...    LNCEL-1/LNHOIF-2:threshold3InterFreqQci1=22
...    LNCEL-1/LNHOIF-2:threshold3aInterFreqQci1=24
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreq=12
...    LNCEL-1/LNHOIF-2:threshold3InterFreq=21
...    LNCEL-1/LNHOIF-2:threshold3aInterFreq=23
...    LNCEL-1/LNHOIF-1:interPresAntP=false
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:interPresAntP=false
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=40742
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqHpue=4
...    LNCEL-2/LNHOIF-1:threshold3InterFreqHpue=25
...    LNCEL-2/LNHOIF-1:threshold3aInterFreqHpue=27
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqQci1=6
...    LNCEL-2/LNHOIF-1:threshold3InterFreqQci1=24
...    LNCEL-2/LNHOIF-1:threshold3aInterFreqQci1=26
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreq=8
...    LNCEL-2/LNHOIF-1:threshold3InterFreq=23
...    LNCEL-2/LNHOIF-1:threshold3aInterFreq=25
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=41138
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqHpue=10
...    LNCEL-2/LNHOIF-2:threshold3InterFreqHpue=22
...    LNCEL-2/LNHOIF-2:threshold3aInterFreqHpue=24
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqQci1=12
...    LNCEL-2/LNHOIF-2:threshold3InterFreqQci1=21
...    LNCEL-2/LNHOIF-2:threshold3aInterFreqQci1=22
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreq=14
...    LNCEL-2/LNHOIF-2:threshold3InterFreq=30
...    LNCEL-2/LNHOIF-2:threshold3aInterFreq=23
...    LNCEL-2/LNHOIF-1:interPresAntP=false
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-2:interPresAntP=false
...    LNCEL-2/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-2/LNREL-1:handoverAllowed=allowed
...    LNCEL-1:rsrqRedirectParams:threshold4Rsrq=-34
...    LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-1:rsrqMobilityParams:threshold2aRsrq=34
...    LNBTS-1:multScellReleaseTimer=5
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
...    LNCEL-2/LNCEL_TDD-0:earfcn=40940
...    LNCEL-3/LNCEL_TDD-0:earfcn=41138
...    LNCEL-1:threshold2a=65
...    LNCEL-1:threshold2InterFreq=60
...    LNCEL-1:threshold2aQci1=64
...    LNCEL-1:threshold2InterFreqQci1=59
...    LNCEL-1:threshold2aHpue=55
...    LNCEL:threshold2InterFreqHpue=50
...    LNCEL-1:threshold2Wcdma=45
...    LNCEL-1:threshold2GERAN=40
...    LNCEL-1:threshold4=19
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1:enableCovHo=true
...    LNBTS-1/LNBTS_TDD-0:actInterFreqServiceBasedHo=true
...    LNBTS-1/MODPR-0:freqLayListServiceBasedHo=40940
...    LNCEL-1/LNREL-1:handoverAllowed=onlyS1
...    LNBTS-1/MODPR-0:freqLayListLte=40940,41138
...    LNCEL-1/LNHOW-1:b2Threshold1UtraQci1=25
...    LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0Qci1=22
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscpQci1=12
...    LNCEL-1/LNHOG-1:b2Threshold1GERANQci1=22
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERANQci1=17
...    LNCEL-1:actUePowerBasedMobThr=true

@{OnlineChangeList_ST_01}
#zkx add for case robustness
...    LNCEL-1:threshold2GERANQci1=40
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNCEL-1/CAPR-1:earfcnDL=40940
...    LNCEL-1/CAPR-2:earfcnDL=41138
...    LNCEL-1/CAREL-1:lnBtsId=1
...    LNCEL-1/CAREL-1:lcrId=2
...    LNCEL-1/CAREL-1:scellPrio=1
...    LNCEL-1/CAREL-2:lnBtsId=1
...    LNCEL-1/CAREL-2:lcrId=3
...    LNCEL-1/CAREL-2:scellPrio=1
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:cellSrPeriod=40ms
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nCqiRb=8
...    LNCEL-1/LNCEL_TDD-0/MPUCCH_TDD-0:nPucchF3Prbs=2
...    LNBTS-1:multScellReleaseTimer=100
...    LNCEL-1/CAPR-0:maxNumScellSwaps=2
...    LNCEL-1/CAPR-1:maxNumScellSwaps=2
...    LNCEL-1/CAPR-2:maxNumScellSwaps=2
...    LNBTS-1/CADPR-0:maxNumScellSwaps=2
...    LNCEL-1:maxNumScells=2
...    LNBTS-1:sCellDeactivationTimereNB=rf8
...    LNBTS-1:multScellReleaseTimer=5
...    LNBTS-1/LNBTS_TDD-0:numTxWithHighNonGbr=100
...    LNCEL-1:threshold2GERANQci1=40
...    LNCEL-1:threshold2WcdmaQci1=45
...    LNCEL-1/LNHOIF-2:rsrqA5InterFreqMobilityParams:threshold3RsrqInterFreq=-29
...    LNCEL-1/LNHOIF-2:rsrqA5InterFreqMobilityParams:threshold3aRsrqInterFreq=-24
...    LNCEL-1/LNHOW-1:b2Threshold1UtraQci1=25
...    LNCEL-1/LNHOW-1:b2Threshold2UtraEcn0Qci1=22
...    LNCEL-1/LNHOW-1:b2Threshold2UtraRscpQci1=12
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=40742
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=41138
...    LNCEL-2/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-2/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-3:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-3:rsrqMobilityParams:threshold2aRsrq=16
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNBTS-1:pwrFallbackCa=true
...    LNCEL-1:actUePowerBasedMobThr=false
...    LNCEL-2:actUePowerBasedMobThr=true
...    LNCEL-3:actUePowerBasedMobThr=true
...    LNBTS-1:caUlIntraBandAmpr=disabled
...    LNBTS-1/LNBTS_TDD-0:actInterFreqServiceBasedHo=false
...    LNBTS-1:enableCombRsrpRsrq=false
...    LNBTS-1:actDLCAggr=false
...    LNBTS-1:actULCAggr=false
...    LNBTS-1:actAdvScellMeas=false
...    LNCEL:rsrqRedirectParams:threshold4Rsrq=-34
...    delete:MODPR.*
...    delete:MOPR.*
...    delete:LNCEL-1:moPrMappingList
...    delete:LNCEL-2:moPrMappingList
...    delete:LNCEL-3:moPrMappingList
...    LNCEL-1:rsrqMobilityParams:threshold2MobRsrq=10
...    LNCEL-1:rsrqMobilityParams:threshold2aRsrq=28
...    LNCEL-2:rsrqMobilityParams:threshold2MobRsrq=12
...    LNCEL-2:rsrqMobilityParams:threshold2aRsrq=28
...    LNCEL-1:threshold4=19
...    LNCEL-2:threshold4=18
...    LNCEL-1:enableBetterCellHo=true
...    LNCEL-1:enableCovHo=true
...    LNCEL-2:enableBetterCellHo=true
...    LNCEL-2:enableCovHo=true
...    LNCEL-1:a3Offset=2
...    LNCEL-2:a3Offset=4
...    LNCEL-3:a3Offset=2
...    LNCEL-1:threshold3=65
...    LNCEL-2:threshold3=66
...    LNCEL-3:threshold3=65
...    LNCEL-1:threshold3a=66
...    LNCEL-2:threshold3a=67
...    LNCEL-3:threshold3a=66
...    LNCEL-1:threshold2a=55
...    LNCEL-1:threshold2InterFreq=50
...    LNCEL-1:threshold2aQci1=64
...    LNCEL-1:threshold2InterFreqQci1=59
...    LNCEL-1:threshold2aHpue=75
...    LNCEL-1:threshold2InterFreqHpue=60
...    LNCEL-1:threshold2Wcdma=45
...    LNCEL-1:threshold2GERAN=40
...    LNCEL-2:threshold2aQci1=63
...    LNCEL-2:threshold2InterFreqQci1=58
...    LNCEL-2:threshold2aHpue=55
...    LNCEL-2:threshold2InterFreqHpue=50
...    LNCEL-2:threshold2a=65
...    LNCEL-2:threshold2InterFreq=60
...    LNCEL-2:threshold2Wcdma=45
...    LNCEL-2:threshold2WcdmaQci1=44
...    LNCEL-2:threshold2GERAN=40
...    LNCEL-2:threshold2GERANQci1=39
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqHpue=4
...    LNCEL-2/LNHOIF-1:threshold3InterFreqHpue=25
...    LNCEL-2/LNHOIF-1:threshold3aInterFreqHpue=27
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreqQci1=6
...    LNCEL-2/LNHOIF-1:threshold3InterFreqQci1=24
...    LNCEL-2/LNHOIF-1:threshold3aInterFreqQci1=26
...    LNCEL-2/LNHOIF-1:a3OffsetRsrpInterFreq=8
...    LNCEL-2/LNHOIF-1:threshold3InterFreq=23
...    LNCEL-2/LNHOIF-1:threshold3aInterFreq=25
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqHpue=10
...    LNCEL-2/LNHOIF-2:threshold3InterFreqHpue=22
...    LNCEL-2/LNHOIF-2:threshold3aInterFreqHpue=24
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreqQci1=12
...    LNCEL-2/LNHOIF-2:threshold3InterFreqQci1=21
...    LNCEL-2/LNHOIF-2:threshold3aInterFreqQci1=22
...    LNCEL-2/LNHOIF-2:a3OffsetRsrpInterFreq=14
...    LNCEL-2/LNHOIF-2:threshold3InterFreq=30
...    LNCEL-2/LNHOIF-2:threshold3aInterFreq=23
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=40940
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqHpue=2
...    LNCEL-1/LNHOIF-1:threshold3InterFreqHpue=26
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqHpue=28
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreqQci1=4
...    LNCEL-1/LNHOIF-1:threshold3InterFreqQci1=25
...    LNCEL-1/LNHOIF-1:threshold3aInterFreqQci1=27
...    LNCEL-1/LNHOIF-1:a3OffsetRsrpInterFreq=6
...    LNCEL-1/LNHOIF-1:threshold3InterFreq=24
...    LNCEL-1/LNHOIF-1:threshold3aInterFreq=26
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=41138
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqHpue=8
...    LNCEL-1/LNHOIF-2:threshold3InterFreqHpue=23
...    LNCEL-1/LNHOIF-2:threshold3aInterFreqHpue=25
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreqQci1=10
...    LNCEL-1/LNHOIF-2:threshold3InterFreqQci1=22
...    LNCEL-1/LNHOIF-2:threshold3aInterFreqQci1=24
...    LNCEL-1/LNHOIF-2:a3OffsetRsrpInterFreq=12
...    LNCEL-1/LNHOIF-2:threshold3InterFreq=21
...    LNCEL-1/LNHOIF-2:threshold3aInterFreq=23
...    LNCEL-1/LNHOIF-1:interPresAntP=false
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:interPresAntP=false
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-1:interPresAntP=false
...    LNCEL-1/LNHOIF-1:measurementBandwidth=mbw100
...    LNCEL-1/LNHOIF-2:interPresAntP=false
...    LNCEL-1/LNHOIF-2:measurementBandwidth=mbw100
...    LNCEL-1/LNCEL_TDD-0:earfcn=40742
...    LNCEL-2/LNCEL_TDD-0:earfcn=40940
...    LNCEL-3/LNCEL_TDD-0:earfcn=41138
...    LNCEL-2/LNHOW-1:utraCarrierFreq=10638
...    LNCEL-2/LNHOW-1:b2Threshold1Utra=23
...    LNCEL-2/LNHOW-1:b2Threshold2UtraEcn0=18
...    LNCEL-2/LNHOW-1:b2Threshold2UtraRscp=10
...    LNCEL-2/LNHOW-1:b2Threshold1UtraQci1=24
...    LNCEL-2/LNHOW-1:b2Threshold2UtraEcn0Qci1=20
...    LNCEL-2/LNHOW-1:b2Threshold2UtraRscpQci1=11
...    LNCEL-2/LNRELW-1:psHoAllowed=allowed
...    LNCEL-2/LNRELW-1:srvccAllowed=allowed
...    LNCEL-2/LNRELW-1:uTargetCid=12
...    LNCEL-2/LNRELW-1:uTargetRncId=12
...    LNCEL-2/LNRELW-1:plmnId:mcc=262
...    LNCEL-2/LNRELW-1:plmnId:mnc=3
...    LNCEL-2/LNRELW-1:plmnId:mncLength=2
...    LNCEL-1/LNHOG-1:b2Threshold1GERANQci1=22
...    LNCEL-1/LNHOG-1:b2Threshold2RssiGERANQci1=17
...    LNCEL-2/LNHOG-1:b2Threshold1GERAN=20
...    LNCEL-2/LNHOG-1:b2Threshold2RssiGERAN=15
...    LNCEL-2/LNHOG-1:b2Threshold1GERANQci1=21
...    LNCEL-2/LNHOG-1:b2Threshold2RssiGERANQci1=16
...    LNCEL-2/LNHOG-1:arfcnValueListGERAN=512
...    LNCEL-2/LNHOG-1:bandIndicatorGERAN=dcs1800
...    LNCEL-2/LNRELG-1:eNACCAllowed=allowed
...    LNCEL-2/LNRELG-1:srvccAllowed=allowed
...    LNCEL-2/LNRELG-1:ci=0
...    LNCEL-2/LNRELG-1:lac=0
...    LNCEL-2/LNRELG-1:plmnId:mcc=262
...    LNCEL-2/LNRELG-1:plmnId:mnc=3
...    LNCEL-2/LNRELG-1:plmnId:mncLength=2

@{OnlineChangeList_actUePowerBasedMobThr}
...    LNCEL-1:actUePowerBasedMobThr=true

@{PM_COUTERS_A_e}
...    LNCEL-1:M8021C44=3
...    LNCEL-1:M8021C45=3
...    LNCEL-1:M8051C134<220

@{PM_counters_ST_01}
...    LNCEL-1:M8021C44=1
...    LNCEL-1:M8021C45=1
...    LNCEL-1:M8051C134<110

${HPUE_eutra_capabilities}
...    SEPARATOR=
...    D59FF41034410381FFFFFFFFFE000040100000004C5003514201D0000181D0000103D00000340001E800001A0040F400004D000D
...    5F200001440084800154000808807740

#LTE3586_ST_01_01 MSG_FLOW
${UE5_capab_info}
...    UE-EUTRA-Capability contains (
...      supportedBandListEUTRA contains (
...        bandEUTRA eq 1,
...        bandEUTRA eq 41
...      )and
...      supportedBandListEUTRA-v1320 contains (
...        ue-PowerClass-N-r13 eq "class2",
...        ue-PowerClass-N-r13 eq "class2"
...      )
...    )

${attach_msg_rrcConnRec}
...    measConfig contains (
...      measObjectToAddModList contains (measObjectEUTRA contains (carrierFreq eq 40742))and
...      reportConfigToAddModList contains (
...        eventA3 contains (a3-Offset eq 2),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 65)and
...                      a5-Threshold2 contains (threshold-RSRP eq 66)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 19)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 50)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRQ eq 10)))and
...      measIdToAddModList contains (
...       (measId eq 1 and measObjectId eq 1 and reportConfigId eq 1),
...       (measId eq 2 and measObjectId eq 1 and reportConfigId eq 2),
...       (measId eq 4 and measObjectId eq 1 and reportConfigId eq 3),
...       (measId eq 7 and measObjectId eq 1 and reportConfigId eq 4),
...       (measId eq 12 and measObjectId eq 1 and reportConfigId eq 5))
...    )

${trigger_A2_event}
...    measConfig contains (
...      measObjectToAddModList contains (
...        measObjectEUTRA contains (carrierFreq eq 40940),
...        measObjectEUTRA contains (carrierFreq eq 41138)
...      )and
...      reportConfigToAddModList contains (
...        eventA1 contains (a1-Threshold contains (threshold-RSRP eq 55)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 45)),
...        eventA3 contains (a3-Offset eq 6),
...        eventA5 contains (
...          a5-Threshold1 contains (threshold-RSRP eq 24)and
...          a5-Threshold2 contains (threshold-RSRP eq 26)
...        ),
...        eventA3 contains (a3-Offset eq 12),
...        eventA5 contains (
...          a5-Threshold1 contains (threshold-RSRP eq 21)and
...          a5-Threshold2 contains (threshold-RSRP eq 23)
...        )
...      )and
...      measIdToRemoveList contains (7)and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 1 and reportConfigId eq 6),
...        (measId eq 6 and measObjectId eq 1 and reportConfigId eq 7),
...        (measId eq 14 and measObjectId eq 2 and reportConfigId eq 8),
...        (measId eq 15 and measObjectId eq 2 and reportConfigId eq 9),
...        (measId eq 16 and measObjectId eq 3 and reportConfigId eq 10),
...        (measId eq 17 and measObjectId eq 3 and reportConfigId eq 11)
...      )
...    )

${trigger_A1_event}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 60))
...      )and
...      measIdToRemoveList contains (
...        5,
...        6,
...        15,
...        17,
...        14,
...        16
...      )and
...      measIdToAddModList contains (
...        measId eq 7 and measObjectId eq 1 and reportConfigId eq 12
...      )
...    )

${trigger_A2_event_2}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        eventA1 contains (a1-Threshold contains (threshold-RSRP eq 75)),
...        eventA3 contains (a3-Offset eq 2),
...        eventA5 contains (
...          a5-Threshold1 contains (threshold-RSRP eq 26)and
...          a5-Threshold2 contains (threshold-RSRP eq 28)
...        ),
...        eventA3 contains (a3-Offset eq 8),
...        eventA5 contains (
...          a5-Threshold1 contains (threshold-RSRP eq 23)and
...          a5-Threshold2 contains (threshold-RSRP eq 25)
...        )
...      )and
...      measIdToRemoveList contains (7)and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 1 and reportConfigId eq 13),
...        (measId eq 6 and measObjectId eq 1 and reportConfigId eq 7),
...        (measId eq 14 and measObjectId eq 2 and reportConfigId eq 14),
...        (measId eq 15 and measObjectId eq 2 and reportConfigId eq 15),
...        (measId eq 16 and measObjectId eq 3 and reportConfigId eq 16),
...        (measId eq 17 and measObjectId eq 3 and reportConfigId eq 17)
...      )
...    )

${trigger_A2_event_3}
...    measConfig contains (
...      measObjectToAddModList contains (measObjectEUTRA contains (carrierFreq eq 40742))  and
...      reportConfigToAddModList contains (
...        eventA3 contains (a3-Offset eq 4),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 25)and
...                          a5-Threshold2 contains (threshold-RSRP eq 27)),
...        eventA3 contains (a3-Offset eq 10),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 22)and
...                          a5-Threshold2 contains (threshold-RSRP eq 24))
...      )and
...      measIdToAddModList contains (
...      (measId eq 5 and measObjectId eq 2 and reportConfigId eq 6),
...      (measId eq 6 and measObjectId eq 2 and reportConfigId eq 7),
...      (measId eq 14 and measObjectId eq 1 and reportConfigId eq 22),
...      (measId eq 15 and measObjectId eq 1 and reportConfigId eq 23),
...      (measId eq 16 and measObjectId eq 3 and reportConfigId eq 24),
...      (measId eq 17 and measObjectId eq 3 and reportConfigId eq 25))
...    )


${trigger_A3_event}
...    measConfig contains (
...      measObjectToAddModList contains (measObjectEUTRA contains (carrierFreq eq 40940))  and
...      reportConfigToAddModList contains (
...        eventA3 contains (a3-Offset eq 4),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 66) and
...                      a5-Threshold2 contains (threshold-RSRP eq 67)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 18)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRQ eq 12))
...      ) and
...      measIdToAddModList contains (
...        (measId eq 1 and measObjectId eq 2 and reportConfigId eq 18),
...        (measId eq 2 and measObjectId eq 2 and reportConfigId eq 19),
...        (measId eq 4 and measObjectId eq 2 and reportConfigId eq 20),
...        (measId eq 7 and measObjectId eq 2 and reportConfigId eq 4),
...        (measId eq 12 and measObjectId eq 2 and reportConfigId eq 21))
...    )

${trigger_QCI1_event}
...    measConfig contains (
...      reportConfigToAddModList contains (
...        eventA1 contains (a1-Threshold contains (threshold-RSRP eq 63)),
...        eventA2 contains (a2-Threshold contains (threshold-RSRP eq 44)),
...        eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 21)and
...                          a5-Threshold2 contains (threshold-RSRP eq 22))
...      )and
...      measIdToRemoveList contains (5,6,14,15,16,17)and
...      measIdToAddModList contains (
...        (measId eq 5 and measObjectId eq 2 and reportConfigId eq 26),
...        (measId eq 6 and measObjectId eq 2 and reportConfigId eq 27),
...        (measId eq 14 and measObjectId eq 1 and reportConfigId eq 8),
...        (measId eq 15 and measObjectId eq 1 and reportConfigId eq 9),
...        (measId eq 16 and measObjectId eq 3 and reportConfigId eq 10),
...        (measId eq 17 and measObjectId eq 3 and reportConfigId eq 28))
...    )


*** Test Cases ***
#LTE3586-A-e_ET_01_03_Counter check with inter eNB S1 A3 or A5 hadnover_4 UEs
#    [Tags]
#    Precondition Setting    Online_param=${OnlineChangeList_A-e}
#    Start Rtpm Counter
#    IPHY UE ATTACH TO ENB1    ue_id_start=7    ue_id_stop=10    ue_eutra_capabilities=${HPUE_eutra_capabilities}
#    #High Power 4UEs attach in eNB1cell1 without QCI1
#    One UE setup QCI1 and trigger Service Based handover to eNB2 cell1    ue_id=7
#    Other 3 UEs send A2-RSRP mobility event measurement report with RSRP -92 to Enb
#    UE A3 handover from eNB1 cell1 to eNB2 cell1    ue_id=8
#    UE A5 handover from eNB1 cell1 to eNB2 cell1    ue_id=9
#    UE A5 handover from eNB1 cell1 to eNB3 cell1    ue_id=10
#    Check RRC log    ${CURDIR}${/}A-e_ET_01_03${/}LTE3586-A-e_ET_01_03.ini
#    Check Rtpm Counters    ${PM_COUTERS_A_e}

LTE3586_ST_01_01_HPUE with A2 RSRP received then LTE3586 feature activation then intra eNB HO to target cell with A2 RSRP received then QCI1 setup
    [Tags]
    Precondition Setting    Online_param=${OnlineChangeList_ST_01}
    UE Attach To ENB1 Cell1    ue_id=5  ue_eutra_capabilities=${HPUE_eutra_capabilities}
    #Step1, High Power UE1 attach in eNB1 cell1 without QCI1
    UE send A2-RSRP between threshold2a and threshold2InterFreq    ue_id=5
    UE send A2-RSRP between threshold2InterFreq and threshold2Wcdma    ue_id=5
    OnlineParamChange    Online_Param=${OnlineChangeList_actUePowerBasedMobThr}
    UE Report A1 Event MR    ue_id=5
    UE Report A2 Event MR    ue_id=5    RrcMsg=${trigger_A2_event_2}    srsrp=58
    UE A3 Handover From ENB1 Cell1 To ENB1 Cell2    ue_id=5
    UE Report A2 Event MR    ue_id=5    RrcMsg=${trigger_A2_event_3}    srsrp=47
    #    ...    Step2, UE1 send A2-RSRP mobility event measurement report with RSRP=-82 to eNB
    UE setup QCI1 and detach    ue_id=5
    Check Rtpm Counters    ${PM_counters_ST_01}

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs
    Create UE Alias for multi UEs
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create Enb Alias    ENB_3    enb_id=3    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
    Enable debug flag for IPHY

Create UE Alias for multi UEs
    FOR    ${ue_id}    IN RANGE    1    6
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END

Enable debug flag for IPHY
    Execute Egate Command    trace uec=1 protocol=rrc on
    Execute Egate Command    trace uec=1 protocol=nas on
    Execute Egate Command    trace mme=1 protocol=s1 on
    Execute Egate Command    trace enb=1 protocol=x2 on
    Execute Egate Command    tracefilter_sim protocol=rrc clear
    Execute Egate Command    trace enb=42 protocol=x2 on
    Execute Egate Command    trace enb=43 protocol=x2 on
    Execute Egate Command    proxy_log GEN=debug
    Execute Egate Command    proxy_log SCH=debug
    Execute Egate Command    proxy_log RLC_AM=debug
    Execute Egate Command    proxy_log RLC_UM=debug

Modify Yaml
    # add sim enb2
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '40940:40940', bw: 20}
    # add sim enb3
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.4
    ...      cells:
    ...        - {id: 31, technology: lte, tac: 33, pci: '4:0', earfcn: '41138:41138', bw: 20}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...      - {qci: 8, default: on, pdn: 1}
    ...      - {qci: 2, pdn: 1, gbr_ul: 144, gbr_dl: 144, mbr_ul: 144, mbr_dl: 144}
    ...      - {qci: 8, default: on, pdn: 2}
    ...      - {qci: 1, pdn: 2, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31}
    Update Yaml    UEs/UE_sets/5    bearer: bearer_set_2

Precondition Setting
    [Arguments]    ${Online_param}=${EMPTY}
    Delta Commission Parameters    ${Online_param}
    Cells Should Be OnAir
    Start Rtpm Counter

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE Attach To ENB1 Cell1
    [Arguments]    ${ue_id}=1    ${ue_eutra_capabilities}=None
    Expect Message Flow
    ...    MME_1:S1AP_UECapabilityInfoIndication (${UE5_capab_info})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${attach_msg_rrcConnRec})
    ...    alias=HPue_attach_flow    overall_timeout=30
    Execute Uex Command    ue_attach id=${UE_ID} ue_eutra_capabilities=${ue_eutra_capabilities}
    Flow Occurred As Expected    alias=HPue_attach_flow

UE send A2-RSRP between threshold2a and threshold2InterFreq
    [Arguments]    ${ue_id}=1
    Expect Message Will Not Occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration
    ...    alias=ue_send_A2_F    overall_timeout=20
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=55 srsrq=34 meas_id_blacklist=4,12
    Flow Not Occurred For Message    alias=ue_send_A2_F

UE send A2-RSRP between threshold2InterFreq and threshold2Wcdma
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${trigger_A2_event})
    ...    alias=ue_send_A2_S    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=47 srsrq=34 meas_id_blacklist=4,12
    Flow Occurred As Expected    alias=ue_send_A2_S

UE Report A1 Event MR
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${trigger_A1_event})
    ...    alias=ue_send_A1    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A1 srsrp=58 srsrq=34
    Flow Occurred As Expected    alias=ue_send_A1

UE Report A2 Event MR
    [Arguments]    ${ue_id}=1    ${RrcMsg}=${trigger_A2_event_2}    ${srsrp}=58
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${RrcMsg})
    ...    alias=ue_send_A2    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A2 srsrp=${srsrp} srsrq=34 meas_id_blacklist=4,12
    Flow Occurred As Expected    alias=ue_send_A2

UE A3 Handover From ENB1 Cell1 To ENB1 Cell2
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${trigger_A3_event})
    ...    alias=ue_send_A3    overall_timeout=30
    Execute Uex Command    ue_measurement_send id=${ue_id} event=A3 phycell_id=2 nrsrp=60 nrsrq=34
    Flow Occurred As Expected    alias=ue_send_A3


UE setup QCI1 and detach
    [Arguments]    ${ue_id}=1
    Expect Message Flow
    ...    MME_1:S1AP_E-RABSetupRequest (E-RABToBeSetupListBearerSUReq contains (e-RAB-ID eq 7 and qCI eq 1))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${trigger_QCI1_event})
    ...    MME_1:S1AP_E-RABSetupResponse (E-RABSetupListBearerSURes contains (e-RAB-ID eq 7))
    ...    alias=UE_setup_QCI1_bearer_successful    overall_timeout=30
    Execute Uex Command    ue_pdn_connect id=${ue_id} apn=nokia_2.net
    Execute Uex Command    bearer_add ue=${ue_id} qci=1 apn=nokia_2.net mbr_ul=31 mbr_dl=31 gbr_ul=31 gbr_dl=31
    Flow Occurred As Expected    alias=UE_setup_QCI1_bearer_successful
    Execute Uex Command    ue_detach id=${ue_id}