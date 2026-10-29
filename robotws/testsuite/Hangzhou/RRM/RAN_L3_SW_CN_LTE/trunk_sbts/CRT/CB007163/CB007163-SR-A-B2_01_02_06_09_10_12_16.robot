*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4LAPO_CUS    team-DevHZ5_SG1
...               owner-feng.2.chen    release-SBTS22R4
Resource          ../../../resources/DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}  2
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms
...    LNBTS:reportTimerIFSBA4=3000ms

@{PARAMS_IN_SCF}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCDPR_CONFIG}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{add_moPrMapList}
...    @{HO_para}
...    @{CB007163}
...    @{UTRA_LB}
...    @{EUTRA_LE}
...    @{EUTRA_LB}

${f1}    1600    #f1 (band3) & nrband257
${f2}    38000    #f2 (band38)& nrband7
${f3}    1700    #f3 (band3) & nrband8
${f4}    900     #f4 (band2) & nrband40 ->not supported
${f0}    1400

@{CB007163}
...    LNBTS:actEndcHo=enabled
...    LNBTS:actUeCapEndcHo=false
...    LNCEL:actEndcHoPrefLay=false
...    LNCEL-1:iFEndcHoRetryTimer=10
...    LNCEL-2:iFEndcHoRetryTimer=10
...    LNCEL-3:iFEndcHoRetryTimer=10
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-2:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-3:configUeCapEndcHoRetry=noRetries
...    LNBTS/CAGENB-0/CAIMLBP-0:pcellConfig:earfcnDL=1700
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-0/IMLBNR-0:nrcellConfigL:band=257
...    LNBTS/CAGENB-0/CAIMLBP-1:pcellConfig:earfcnDL=38000
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-1/IMLBNR-0:nrcellConfigL:band=7
...    LNBTS/CAGENB-0/CAIMLBP-2:pcellConfig:earfcnDL=900
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-2/IMLBNR-0:nrcellConfigL:band=40
...    LNBTS/CAGENB-0/CAIMLBP-3:pcellConfig:earfcnDL=1600
...    LNBTS/CAGENB-0/CAIMLBP-3/IMLBNR-0:nrcellConfigL:b1NrRequired=false
...    LNBTS/CAGENB-0/CAIMLBP-3/IMLBNR-0:nrcellConfigL:band=8
...    LNCEL-1/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-1/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-1:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-1:eutraCarrierInfo=1600
...    LNCEL-2/LNHOIF-1:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-2/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    LNCEL/LNHOIF-3:thresholdRsrpEndcFilt=-98
...    LNCEL/LNHOIF-3:eutraCarrierInfo=900
...    LNCEL/LNHOIF-3:thresholdRsrqEndcFilt=-120
...    LNCEL/LNHOIF-4:thresholdRsrpEndcFilt=-98
...    LNCEL/LNHOIF-4:eutraCarrierInfo=1700
...    LNCEL/LNHOIF-4:thresholdRsrqEndcFilt=-120
...    LNCEL-1/LNHOIF-5:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-5:eutraCarrierInfo=1500
...    LNCEL-1/LNHOIF-5:thresholdRsrqEndcFilt=-120
...    LNCEL-2/LNHOIF-6:thresholdRsrpEndcFilt=-98
...    LNCEL-2/LNHOIF-6:eutraCarrierInfo=1400
...    LNCEL-2/LNHOIF-6:thresholdRsrqEndcFilt=-120
...    @{freqLayEndcHoList_for_MOPR}
...    @{freqLayEndcHoList_for_MODPR}

@{freqLayEndcHoList_for_MODPR}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f4}

@{freqLayEndcHoList_for_MOPR}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f4}

@{freqLayEndcHoList_for_MODPR_all_true}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f4}

@{HO_para}
...    LNBTS-1:actIfHo=enabled
...    LNBTS-1/LNADJ-1:adjEnbId=2
...    LNBTS-1/LNADJ-1:cPlaneIpAddr=10.0.1.3
...    LNCEL-1/LNREL-1:removeAllowed=false
...    LNCEL-1/LNREL-1:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-1:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-1:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-1:ecgiAdjEnbId=2
...    LNCEL-1/LNREL-1:ecgiLcrId=21
...    LNCEL-1/LNREL-1:handoverAllowed=allowed
...    LNCEL-1/LNHOIF-1:eutraCarrierInfo=1500
...    LNBTS/MODPR-0:freqLayListLte=1500,1400,1700,1600,38000,900
...    LNBTS/MOPR-1:freqLayListLte=1500,1400,1700,1600,38000,900

@{PARAMS_FOR_CELL_CONFIG}
...    LNCEL-1/LNCEL_FDD-0:earfcnDL=1400
...    LNCEL-1/LNCEL_FDD-0:earfcnUL=19400
...    LNCEL-2/LNCEL_FDD-0:earfcnDL=1500
...    LNCEL-2/LNCEL_FDD-0:earfcnUL=19500
...    LNCEL-3/LNCEL_FDD-0:earfcnDL=1600
...    LNCEL-3/LNCEL_FDD-0:earfcnUL=19600

@{x2link}
...    LNBTS/LNADJGNB-1:adjGnbId=7
...    LNBTS/LNADJGNB-1:adjGnbIdLength=22
...    LNBTS/LNADJGNB-1:administrativeState=unlocked
...    LNBTS/LNADJGNB-1:cPlaneIpAddr=10.0.1.11
...    LNCEL/LNRELGNBCELL-1:gnbIdLength=22
...    LNCEL/LNRELGNBCELL-1:lteNrDualConnectAllowed=allowed
...    LNCEL/LNRELGNBCELL-1:nrCellId=115970
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mcc=262
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mnc=3
...    LNCEL/LNRELGNBCELL-1:nrCgiPlmnId:mncLength=2

@{NRcell_unava}
...    LNBTS-1/LNCEL-1/LNRELGNBCELL-1:nrStatus=unavailable

@{LTE4088}
...    LNBTS:actTransmittedBelowGap=false
...    LNBTS:actLteNrDualConnectivity=false
...    LNBTS:tS1eRABModInd=2000
...    LNBTS:nrRestrictionOverride=disabled
...    LNCEL:defaultLnRelGnbCellId=1
...    LNBTS:actEndcSpidFwd=false
...    LNBTS:endcSchedWeightBoostDl=2
...    LNBTS:endcSchedWeightBoostUl=2
...    LNCEL:eTputInitMcs=20
...    LNCEL:eTputFilterConfig=51
...    LNBTS:tLteNrDualConnectPrep=5000
...    LNBTS:qciTab8:lteNrDualConnectSupport=EN-DC|nrPdcpProfIdx=1001

${nrF1}    531040
${nrF2}    524032

@{LTE4193}
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:method=coverageBased
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:enDCpMaxEUTRApowerOffset=0
...    LNBTS/NRDCDPR-0:enDCpMaxNRpowerOffset=0
...    LNBTS/NRDCDPR-0:tPeriodicPhr=10sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=0sf
...    LNBTS:actDynTrigLteNrDualConnectivity=false
...    LNCEL/LNCEL_FDD-0:actAutoPucchAlloc=true

@{NRDCDPR_CONFIG}
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=0
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrp=fc4|quantityConfigId=1
...    LNBTS/NRMEASDPR-0:nrQuantityConfig:filterCoefficientRsrq=fc4|quantityConfigId=1
...    LNBTS/NRDCDPR-0:dlPathlossChg=3 db
...    LNBTS/NRDCDPR-0:tPeriodicPhr=1000sf
...    LNBTS/NRDCDPR-0:tProhibitPhr=1000sf
...    LNBTS/NRDCDPR-0:dynTriggerLteNrDcConfList:lcrId=-1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:carrierFreqNrCell=${nrF1}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:nrCarPrio=3
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-1:quantityConfigId=1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1ThresholdNrRsrp=90
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrp=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TimeToTriggerRsrq=256ms
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:b1TriggerQuantity=RSRP
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:carrierFreqNrCell=${nrF2}
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:freqBandIndicatorNrL:freqBandIndicatorNr=7
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrp=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:hysB1ThresholdRsrq=4
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:nrCarPrio=6
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbDuration=sf1
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbOffset=0
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbPeriodicity=sf5-r15
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:ssbSubcarrierSpacing=15kHz
...    LNBTS/NRDCDPR-0/ENDCDMEASCONF-2:quantityConfigId=1

@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1

${ue_nr_cap}    0000000001010040000060000038000400040160401C06000000
${ue_eutra_nr_cap}    SEPARATOR=
...    010810036040080819280701800000006C08010102020E0380000000D81003060061401D0000000001B01004020804385000000000180004
...    020001008000402020040080

${ue_eutra_cap}    SEPARATOR=
...    DE1809D0008206102860E2048A163069022489942A58B983268D9D4AB5F9D3A00000001D00000000E800000007400000003A00000001D000
...    00000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D0000
...    0000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000
...    001BFBFFEDA00E00886429CC20070D9000000005EE800000020254A8389D0100000E10000084000B08000042002100004300008800011400
...    0230000470000900001240002500004B000098000134000280000510000A400014C0002A0000550000AC00015C0002C0000590000B400016
...    C0002E80005E0000DA0001FC0074E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007
...    400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E8000000074
...    00000003A00000001D00000000E800000007400000003A00000001D00000000E80000000740000000282000001E740000000000000000000
...    000000000000000000000000000000000000000040471084A681873FFFFFFFFFFFFFFE8082A0006008A5C000080000412C68060300E8004E
...    F0000006000000240000860030080601D00000

@{precondition_for_case12}
...    LNBTS/MODPR-0:freqLayListDedLteLB=1600
...    LNBTS/MOPR-1:freqLayListDedLteLB=1600
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    @{freqLayEndcHoList_for_MODPR_all_true}
...    @{freqLayEndcHoList_for_MOPR}
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    delete:LNCEL-1/LNREL-388
...    delete:LNCEL-1/LNREL-387
...    delete:LNCEL-1/LNREL-386
...    delete:LNCEL-1/LNREL-385s

@{enable_AMLE}
...    LNCEL-1:actInterFreqLB=false
...    LNCEL-1:actAmle=true
...    LNCEL-1/LNREL-2:removeAllowed=false
...    LNCEL-1/LNREL-2:ecgiPlmnId:mncLength=2
...    LNCEL-1/LNREL-2:ecgiPlmnId:mcc=262
...    LNCEL-1/LNREL-2:ecgiPlmnId:mnc=3
...    LNCEL-1/LNREL-2:ecgiAdjEnbId=1
...    LNCEL-1/LNREL-2:ecgiLcrId=3
...    LNCEL-1/LNREL-2:handoverAllowed=allowed
...    LNCEL-1/LNREL-2:amleAllowed=true

@{delta_case12}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f2}

@{precondition_for_case16}
...    LNBTS/MODPR-0:freqLayListDedLteLB=1600
...    LNBTS/MOPR-1:freqLayListDedLteLB=1600
...    LNBTS/MODPR-0:freqLayListPsHoWcdma=1300
...    LNBTS/MOPR-1:freqLayListPsHoWcdma=1300
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}
...    @{enable_UtraLB}

@{EUTRA_LE}
...    LNCEL:actAmle=true
...    LNCEL:actAmleServCellFilter=false
...    LNCEL-1/AMLEPR-0:cacHeadroom=0
...    LNCEL-1/AMLEPR-0:deltaCac=50
...    LNCEL-1/AMLEPR-0:maxCacThreshold=100
...    LNCEL-1/AMLEPR-0:targetCarrierFreq=1600
...    LNCEL-2/AMLEPR-0:cacHeadroom=100
...    LNCEL-2/AMLEPR-0:deltaCac=20
...    LNCEL-2/AMLEPR-0:maxCacThreshold=0
...    LNCEL-2/AMLEPR-0:targetCarrierFreq=1400
...    LNCEL-3/AMLEPR-0:cacHeadroom=100
...    LNCEL-3/AMLEPR-0:deltaCac=20
...    LNCEL-3/AMLEPR-0:maxCacThreshold=0
...    LNCEL-3/AMLEPR-0:targetCarrierFreq=1400

@{EUTRA_LB}
...    LNBTS/LNBTS_FDD-0:actDedFreqListsLB=inter-frequency
...    LNBTS:qciTab8:schedulWeight=100
...    LNCEL-1:actInterFreqLB=false
...    LNCEL-1:actLBSpidUeSel=false
...    LNCEL-1:cellResourceSharingMode=none
...    LNCEL-1:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadGBRDL=1
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=1
...    LNCEL-1:iFLBLoadThresholds:iFLBHighLoadPdcch=1
...    LNCEL-1:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-1:iFLBLoadThresholds:maxNumAmleNeigh=2
...    LNCEL-1:loadSettings:cellCapClass=1
...    LNCEL-1:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-1:loadSettings:nomNumPrbNonGbr=10
...    LNCEL-1:loadSettings:targetLoadGbrDl=1
...    LNCEL-1:loadSettings:targetLoadNonGbrDl=1
...    LNCEL-1:loadSettings:targetLoadPdcch=1
...    LNCEL-1:loadSettings:ulCacIgnore=false
...    LNCEL-1:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-1:loadSettings:ulStaticCac=0
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadDlGbr=0
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadDlNonGbr=0
...    LNCEL-1:intraFreqLbLoadThresholds:hysteresisLoadPdcch=0
...    LNCEL-2:cellResourceSharingMode=none
...    LNCEL-2:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=85
...    LNCEL-2:iFLBLoadThresholds:iFLBHighLoadPdcch=95
...    LNCEL-2:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-2:iFLBLoadThresholds:maxNumAmleNeigh=1
...    LNCEL-2:loadSettings:cellCapClass=1
...    LNCEL-2:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-2:loadSettings:nomNumPrbNonGbr=1
...    LNCEL-2:loadSettings:targetLoadGbrDl=50
...    LNCEL-2:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-2:loadSettings:targetLoadPdcch=90
...    LNCEL-2:loadSettings:ulCacIgnore=false
...    LNCEL-2:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-2:loadSettings:ulStaticCac=0
...    LNCEL-3:cellResourceSharingMode=none
...    LNCEL-3:iFLBLoadThresholds:iFLBBearCheckTimer=0
...    LNCEL-3:iFLBLoadThresholds:iFLBHighLoadGBRDL=60
...    LNCEL-3:iFLBLoadThresholds:iFLBHighLoadNonGBRDL=85
...    LNCEL-3:iFLBLoadThresholds:iFLBHighLoadPdcch=95
...    LNCEL-3:iFLBLoadThresholds:iFLBRetryTimer=10
...    LNCEL-3:iFLBLoadThresholds:maxNumAmleNeigh=1
...    LNCEL-3:loadSettings:cellCapClass=1
...    LNCEL-3:loadSettings:mlbEicicOperMode=allUes
...    LNCEL-3:loadSettings:nomNumPrbNonGbr=1
...    LNCEL-3:loadSettings:targetLoadGbrDl=50
...    LNCEL-3:loadSettings:targetLoadNonGbrDl=75
...    LNCEL-3:loadSettings:targetLoadPdcch=90
...    LNCEL-3:loadSettings:ulCacIgnore=false
...    LNCEL-3:loadSettings:ulCacSelection=ulReflectDlCac
...    LNCEL-3:loadSettings:ulStaticCac=0
...    LNCEL:actServRlqInterFreqLB=false
...    LNCEL:iFLBA4ActLim=5
...    LNCEL/LNCEL_FDD-0:maxNrSymPdcch=3

@{UTRA_LB}
...    LNBTS:actHOtoWcdma=false
...    LNBTS/LNBTS_FDD-0:actUtranLoadBal=false
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
...    LNCEL-2/LNCEL_FDD-0:utranLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-2/LNCEL_FDD-0:utranLbLoadThresholds:highLoadNonGbrDl=85
...    LNCEL-2/LNCEL_FDD-0:utranLbLoadThresholds:highLoadPdcch=95
...    LNCEL-3:filterCoefficientCpichRscp=fc4
...    LNCEL-3:filterCoefficientCpichEcn0=fc4
...    LNCEL-3:measQuantityUtra=cpichRSCP
...    LNCEL-3/LNCEL_FDD-0:utranLbLoadThresholds:highLoadGbrDl=60
...    LNCEL-3/LNCEL_FDD-0:utranLbLoadThresholds:highLoadNonGbrDl=85
...    LNCEL-3/LNCEL_FDD-0:utranLbLoadThresholds:highLoadPdcch=95
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

@{enable_AMLE}
...    LNCEL-1:actInterFreqLB=false
...    LNCEL:actAmle=true

@{enable_UtraLB}
...    LNCEL-1:actInterFreqLB=true
...    LNCEL:actAmle=false
...    LNBTS:actHOtoWcdma=true
...    LNBTS/LNBTS_FDD-0:actUtranLoadBal=true

@{precondition_for_case1}
...    LNBTS:actDynTrigLteNrDualConnectivity=false    #LTE4193 disable
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=false    #(CB006607)
...    LNCEL:actEndcHoPrefLay=false    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=noRetries
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=noRetries
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

@{precondition_for_case2}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=false    #(CB007163)
...    @{freqLayEndcHoList_for_MODPR}
...    delete:LNCEL/LNRELGNBCELL-0

@{delta_for_case2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f4}

@{serving cell in ENDC list and delete LNHOIF}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=false    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f0}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f0}
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    delete:LNCEL-1/LNHOIF-4
...    delete:LNCEL-1/LNHOIF-2
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

@{serving cell not in ENDC list}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f3}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f4}

@{enable_6607_add_LNHOIF}
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL-1/LNHOIF-2:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-2:eutraCarrierInfo=38000
...    LNCEL-1/LNHOIF-2:thresholdRsrqEndcFilt=-120
...    @{freqLayEndcHoList_for_MOPR}

@{add_LNHOIF}
...    LNCEL-1/LNHOIF-4:thresholdRsrpEndcFilt=-98
...    LNCEL-1/LNHOIF-4:eutraCarrierInfo=1700
...    LNCEL-1/LNHOIF-4:thresholdRsrqEndcFilt=-120

@{serving cell in ENDC list}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f0}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f0}
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

@{precondition_for_case9}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=true    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
...    @{freqLayEndcHoList_for_MODPR}
...    @{freqLayEndcHoList_for_MOPR}

@{delta_for_case10}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}

${enable_7163}    LNCEL-1:actEndcHoPrefLay=true
${disable_7163}    LNCEL-1:actEndcHoPrefLay=false

${ENDC_HO_Preparation}    LNCEL-1:M8080C53
${ENDC_HO_Execution}    LNCEL-1:M8080C54
${ENDC_HO_successes}    LNCEL-1:M8080C55
${prefer_ENDC_HO_successes}    LNCEL-1:M8080C155
${prefer_ENDC_HO_Execution}    LNCEL-1:M8080C156
${PM_SPEED_UP_FLAG}    ${True}

@{ENDC_HO_counters}
...    ${ENDC_HO_Preparation}=1
...    ${ENDC_HO_Execution}=1
...    ${ENDC_HO_successes}=1
...    ${prefer_ENDC_HO_Execution}=1
...    ${prefer_ENDC_HO_successes}=1

#precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
${a5_activatef1f2f3_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 1600,
...    carrierFreq eq 38000,
...    carrierFreq eq 1700
...    )
...    and
...    measIdToAddModList contains (
...    measId eq 3,
...    measId eq 5,
...    measId eq 6
...    )
...    and
...    eventA5 contains (
...    a5-Threshold1 contains (threshold-RSRP eq 97) and
...    a5-Threshold2 contains (threshold-RSRP eq 0)
...    )
${a5_activatef1f2f4_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 1600,
...    carrierFreq eq 38000,
...    carrierFreq eq 900
...    )
...    and
...    measIdToAddModList contains (
...    measId eq 3,
...    measId eq 5,
...    measId eq 6
...    )
...    and
...    eventA5 contains (
...    a5-Threshold1 contains (threshold-RSRP eq 97) and
...    a5-Threshold2 contains (threshold-RSRP eq 0)
...    )
${a5_activatef2f3f4_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 1700,
...    carrierFreq eq 38000,
...    carrierFreq eq 900
...    )
...    and
...    measIdToAddModList contains (
...    measId eq 3,
...    measId eq 5,
...    measId eq 6
...    )
...    and
...    eventA5 contains (
...    a5-Threshold1 contains (threshold-RSRP eq 97) and
...    a5-Threshold2 contains (threshold-RSRP eq 0)
...    )
${a5_activatef1f2_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 38000,
...    carrierFreq eq 1600
...    )
...    and
...    measIdToAddModList contains (
...    measId eq 3,
...    measId eq 5
...    )
...    and
...    eventA5 contains (
...    a5-Threshold1 contains (threshold-RSRP eq 97) and
...    a5-Threshold2 contains (threshold-RSRP eq 0)
...    )
${a5_activatef2f3_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 38000,
...    carrierFreq eq 1700
...    )
...    and
...    measIdToAddModList contains (
...    measId eq 3,
...    measId eq 5
...    )
...    and
...    eventA5 contains (
...    a5-Threshold1 contains (threshold-RSRP eq 97) and
...    a5-Threshold2 contains (threshold-RSRP eq 0)
...    )
${a5_activatef2_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 38000
...    )
...    and
...    measIdToAddModList contains (
...    measId eq 3
...    )
...    and
...    eventA5 contains (
...    a5-Threshold1 contains (threshold-RSRP eq 97) and
...    a5-Threshold2 contains (threshold-RSRP eq 0)
...    )
${no_ENDC_A5_activate}    eventA5 contains (a5-Threshold1 contains (threshold-RSRP ne 97))
${ENDC_A5_activate}    eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))
${ho_cause_query}    HandoverRequest contains (radioNetwork eq 'resource-optimisation-handover')
${ho_to_1700}
...    mobilityControlInfo contains ( targetPhysCellId eq 9 and carrierFreq contains (dl-CarrierFreq eq 1700))
${a5_retry}    measIdToAddModList contains (measId eq 3,measId eq 5)
${a5_remove}    measIdToRemoveList contains (3,5)
${a4_activate}    a4-Threshold contains ( threshold-RSRP eq 0) and s-Measure eq 0 and measId-v1250 eq 64
${a4_1600_activate}    measIdToAddModListExt-r12 contains ( measId-v1250 eq 64) and
...    a4-Threshold contains (threshold-RSRP eq 0)
${a4_remove}    measIdToRemoveListExt-r12 contains (64)
${a4_retry}    measIdToAddModListExt-r12 contains ( measId-v1250 eq 64 and measObjectId-r12 eq 2 and reportConfigId-r12 eq 6)
${LB_B1}    carrierFreq eq 1300 and b1-ThresholdUTRA contains (utra-RSCP eq -5) and (measId eq 3)

*** Test Cases ***
CB007163_A-B2_ET_01_01_EN-DC capability based handover to preferred layer when CB006607 disabled
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    MRDC capability:
    ...    f1 (band3) & nrband257
    ...    f2 (band38)& nrband7
    ...    f3 (band3) & nrband8
    ...    f4 (band2) & nrband40 ->not supported
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=false (CB006607)
    ...    LNCEL:actEndcHoPrefLay=false (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    step1: UE1 ICS to serving cell and no endc A5 activation for ENDC enabled, LTE5150 enabled, CB007163 diasbled
    ...    step2: UE2 X2 Ho to serving cell and no endc A5 activation for ENDC enabled, LTE5150 enabled, CB007163 diasbled
    ...    step3: UE3 reestablish to serving cell, no endc A5 activation for ENDC enabled, LTE5150 enabled,CB007163 diasbled
    ...    step4: enable CB007163 by setting actEndcHoPrefLay to true
    ...    step5: UE4 ICS to serving cell and endc A5 activation for prefer layer for ENDC enabled, CB007163 enabled
    ...    step6: UE5 X2 Ho to serving cell and endc A5 activation for prefer layer for ENDC enabled, CB007163 enabled
    ...    step7: UE6 reestablish to serving cell, endc A5 activation for prefer layer for ENDC enabled, CB007163 enabled
    ...    step8: Disable CB007163 by setting actEndcHoPrefLay to false
    ...    step9: UE7 ICS to serving cell and no endc A5 activation for ENDC enabled, LTE5150 enabled, CB007163 diasbled
    [Tags]
    OnlineParamChange    ${precondition_for_case1}
    UE enter cell via ICS or HO or reestablish and check no A5 activated
    OnlineParamChange    ${enable_7163}
    Attach UE and Perform ENDC HO    ue_id=4    enb_id=1    source_cell_id=1    target_cell_id=10
    UE Inter-Enb X2 handover and Perform ENDC HO    ue_id=5    cell_id=24
    UE Reestablish and Perform ENDC HO    ue_id=6    cell_id=24
    OnlineParamChange    ${disable_7163}
    Attach UE and No ENDC A5 Activate Then Detach    ue_id=7    enb_id=1    cell_id=1

CB007163_A-B2_ET_02_01_EN-DC capability based handover to preferred layer when CB006607 enabled
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    MRDC capability:
    ...    f1 (band3) & nrband257
    ...    f2 (band38)& nrband7
    ...    f3 (band3) & nrband8
    ...    f4 (band2) & nrband40 ->not supported
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=enabled (CB006607)
    ...    LNCEL:actEndcHoPrefLay=false (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    step1: UE11 ICS to serving cell, no endc A5 activation for ENDC enabled,CB006607 enabled,CB007163 diasbled
    ...    step2: UE12 X2 Ho to serving cell, no endc A5 activation for ENDC enabled,CB006607 enabled,CB007163 diasbled
    ...    step3: UE13 reestablish to serving cell,no endc A5 activation for ENDC enabled,CB006607 enabled,CB007163 diasbled
    ...    step4: enable CB007163 by setting actEndcHoPrefLay to true
    ...    step5: UE14 ICS to cell-2, no endc A5 activation for CB007163 enabled only for cell-1
    ...    step6: UE15 ICS to serving cell,endc A5 activation for prefer layer for ENDC enabled and CB007163 enabled
    ...    step7: UE16 X2 Ho to serving cell,endc A5 activation for prefer layer for ENDC enabled and CB007163 enabled
    ...    step8: UE17 reestablish to serving cell,endc A5 activation for prefer layer for ENDC enabled and CB007163 enabled
    ...    step9: online change MODPR-0 preference=false to true for f1 and preference=true to false for f3,
    ...    attach UE18 and check ENDC A5 activation for new prefer layer
    ...    step10: lock GNB-7 cell-2,attach UE19, ENDC A5 activation for CB006607 target list for serving cell is not anchor layer
    ...    step11: Disable CB007163 by setting actEndcHoPrefLay to false
    ...    step12: UE20 ICS to serving cell and check endc A5 activation for CB006607 target list
    [Tags]    RAN_4G    RAN_4G_FDD    CDRT
    OnlineParamChange    ${precondition_for_case2}
    UE enter cell via ICS or HO or reestablish and check no A5 activated when 7163 disable
    OnlineParamChange    ${enable_7163}
    Attach UE and No ENDC A5 Activate Then Detach    ue_id=14    enb_id=1    cell_id=2
    UE enter cell via ICS or HO or reestablish and perform ENDC HO when 7163 enable
    OnlineParamChange    ${delta_for_case2}
    Attach UE before and after delete gNB_cell On CUS
    OnlineParamChange    ${disable_7163}
    Attach UE and Detach UE20    ue_id=20    enb_id=1    cell_id=1
    [Teardown]    Local Test Teardown And Recover Env For Case

CB007163_A-B2_ET_06_01_EN-DC A5 is not activated if serving cell or source cell frequency is included in target for prefered ENDC-HO
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    MRDC capability:
    ...    f1 (band3) & nrband257
    ...    f2 (band38)& nrband7
    ...    f3 (band3) & nrband8
    ...    f4 (band2) & nrband40 ->not supported
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=false (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    delete LNHOIF-4 and LNHOIF-2 and serving cell frequency in CB007163 target list
    ...    step1: UE1 ICS to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step2: UE2 X2 Ho to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step3: UE3 reestablish to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step4: online change MOPR-1 serving cell not in CB007163 target list
    ...    step5: UE4 ICS to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step6: UE5 X2 Ho to serving cell,no endc A5 activation for source cell frequency in CB007163 target list
    ...    step7: UE6 reestablish to serving cell,no endc A5 activation for source cell frequency in CB007163 target list
    ...    step8: enable CB006607 and add LNHOIF-2
    ...    step9: UE7 ICS to serving cell,endc A5 activation for serving cell frequency not in CB007163 target list
    ...    step10: UE8 X2 Ho to serving cell,endc A5 activation for source cell frequency not in CB007163 target list
    ...    step11: UE9 reestablish to serving cell,no endc A5 activation for source cell frequency in CB007163 target list
    ...    step12: add LNHOIF-4
    ...    step13: UE16 ICS to serving cell,endc A5 activation for for serving cell frequency in CB007163 target list
    ...    step14: UE10 X2 Ho to serving cell,no endc A5 activation for source cell frequency in CB007163 target list
    ...    step15: UE11 reestablish to serving cell,no endc A5 activation for source cell frequency in CB007163 target list
    ...    step16: online change serving cell freq in CB007163 target list
    ...    step17: UE12 ICS to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step18: UE13 X2 Ho to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step19: UE14 reestablish to serving cell,no endc A5 activation for serving cell frequency in CB007163 target list
    ...    step20: lock GNB-7 cell-2,attach UE15, ENDC A5 activation for CB006607 target list for serving cell is not anchor layer
    [Tags]
    UE enter cell via attach or HO or reestablish and no ENDC A5 when serving cell in prefer freqLayEndcHoList
    OnlineParamChange    ${serving cell not in ENDC list}     #F0in MOPR-1 list, not in MODPR list,delete 38000 1700,6607 disable
    UE enter cell via ICS or HO or reestablish and check A5 activated or not
    UE attach HO and reestablish and check A5 activated after enable 6607
    OnlineParamChange    ${add_LNHOIF}    #add 1700
    UE enter cell via ICS or HO or reestablish and check A5 activated after add LNHOIF
    OnlineParamChange    ${serving cell in ENDC list}
    UE enter cell via ICS or HO or reestablish and check no A5 activated after serving cell into endc list
    Delete gNB_cell and attach UE to check A5 activated
    [Teardown]    Local Test Teardown And Recover Env For Case

CB007163_A-B2_ET_09_01_EN-DC A5 is not activated due to UE reestablishes to serving cell or HO source cell
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    MRDC capability:
    ...    f1 (band3) & nrband257
    ...    f2 (band38)& nrband7
    ...    f3 (band3) & nrband8
    ...    f4 (band2) & nrband40 ->not supported
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    step1: attach UE1 eNB-1 CELL-1,check ENDC A5 activation and retry not blocked
    ...    step2: attach UE2 eNB-1 CELL-1,check ENDC A5 activation, after reestabish on serving cell,
    ...    check ENDC A5 retry not blocked
    ...    step3: attach UE3 eNB-1 CELL-1, check ENDC A5 activation, after intra HO, check ENDC A5 retry not blocked
    ...    step4: attach UE5 eNB-1 CELL-1, check ENDC A5 activation, after reestabish to source cell during X2HO,
    ...    check ENDC A5 retry not blocked
    ...    step4: attach UE6 eNB-1 CELL-1, check ENDC A5 activation, after reestabish to source cell during S1HO,
    ...    check ENDC A5 retry not blocked
    [Tags]
    OnlineParamChange    ${precondition_for_case9}
    Attach UE and Detach    ue_id=1    enb_id=1    cell_id=1    a5_query=${a5_activatef1f2_query}
    Reestablish UE on serving CELL-1 without any ongoing handover and check A5 retry    ue_id=2
    Trigger UE reestablish back to source CELL-1 during intra ENB HO    ue_id=3
    Trigger UE reestablish back to source CELL-1 during x2 handover    ue_id=5
    Trigger UE reestablish back to source CELL-1 during S1 handover    ue_id=6

CB007163_A-B2_ET_10_01_EN-DC capability based handover to preferred layer when ENDC established
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    MRDC capability:
    ...    f1 (band3) & nrband257
    ...    f2 (band38)& nrband7
    ...    f3 (band3) & nrband8
    ...    f4 (band2) & nrband40 ->not supported
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    step1: UE25 ICS to eNB-1 CELL-1,ENDC setup, check ENDC A5 activation and retry
    ...    step2: UE26 X2 Ho to eNB-1 CELL-1,ENDC setup, check ENDC A5 activation and retry
    ...    step3: UE1 reestablish to eNB-1 CELL-1, ENDC setup, check ENDC A5 activation and retry
    ...    step4: online change MODPR-0: preference=true for f3 and MOPR-1: preference=true for f1
    ...    step5: send measurement report to f1 and ENDC A5 HO succeed
    [Tags]
    clear counter files
    OnlineParamChange    ${precondition_for_case9}
    Attach UE and setup ENDC    ue_id=25
    Trigger Inter-Enb X2 handover and setup ENDC    ue_id=26
    Trigger UE Reestablish and setup ENDC    ue_id=1
    OnlineParamChange    ${delta_for_case10}
    wait A5 activated for new freq    ue_id=25
    Perform ENDC HO and detach UE    meas_id_blacklist=5,6    ue_id=25    cell_id=9
    Check Counters    ${ENDC_HO_counters}

CB007163_A-B2_ET_12_01_EN-DC capability based handover to preferred layer interaction with AMLE
    [Tags]
    [Documentation]
    ...    LNCEL-1:actEndcHoPrefLay=true(CB007163 feature flag)
    ...    LNBTS.actUeCapEndcHo =enable(CB006607)
    ...    MRBTS/LNBTS:actEndcHo=enable (LTE5150)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    enable AMLE by setting LNCEL:actAmle=true
    ...    LNBTS/MOPR-1 and MODPR-0:configUeCapEndcHoRetry=priorityBelowLoadBasedHo
    ...    step1: UE1 ICS, ENDC A5 activated and retry, start traffic, AMLE A4 activated, A5 deactivated, stop traffic,
    ...    ENDC A5 activated and retry
    ...    step2: UE2 X2 HO to cell1, ENDC A5 activated and retry, start traffic, AMLE A4 activated, A5 deactivated, stop traffic,
    ...    ENDC A5 activated and retry
    ...    step3: UE3 reestablish to cell1, ENDC A5 activated and retry, start traffic, AMLE A4 activated, A5 deactivated, stop traffic,
    ...    ENDC A5 activated and retry
    ...    step4: online change MOPR-1: preference=false for f1 and preference=true for f2 no cross with AMLE
    ...    step5: UE1 ICS, ENDC A5 activated and retry, start traffic, no AMLE A4 activated
    OnlineParamChange    ${precondition_for_case12}
    OnlineParamChange    ${enable_AMLE}
    Attach UE and start traffic to check AMLE A4 trigered     ue_id=1
    UE Inter-Enb X2 handover and start traffic to check AMLE A4 trigered    ue_id=2
    UE Reestablish and start traffic to check AMLE A4 trigered    ue_id=3
    OnlineParamChange    ${delta_case12}
    Attach UE and start traffic to check AMLE A4 not trigered    ue_id=4

CB007163_A-B2_ET_16_01_EN-DC capability based handover to preferred layer interaction with LB B1
    [Tags]
    [Documentation]
    ...    LNCEL-1:actEndcHoPrefLay=true(CB007163 feature flag)
    ...    LNBTS.actUeCapEndcHo =enable(CB006607)
    ...    MRBTS/LNBTS:actEndcHo=enable (LTE5150)
    ...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    enable LBA4 and LBB1 by setting actHOtoWcdma=true and actUtranLoadBal=true
    ...    step1: UE11 ICS, ENDC A5 activated and retry, start traffic, LB A4 activated, LBA4 deactivated, LBB1 activated,
    ...    LBB1 deactivated, round robin, stop traffic, ENDC A5 activated and retry
    ...    step2: UE12 X2 HO to cell1, ENDC A5 activated and retry, start traffic, LB A4 activated, LBA4 deactivated, LBB1 activated,
    ...    LBB1 deactivated, round robin, stop traffic, ENDC A5 activated and retry
    ...    step3: UE13 reestablish to cell1, ENDC A5 activated and retry, start traffic, LB A4 activated, LBA4 deactivated, LBB1 activated,
    ...    LBB1 deactivated, round robin, configUeCapEndcHoRetry=priorityAboveLoadBasedHo, ENDC A5 activated and retry
    OnlineParamChange    ${precondition_for_case16}
    Attach UE and start traffic to check LB B1 trigered     ue_id=11
    UE Inter-Enb X2 handover and start traffic to check LB B1 trigered    ue_id=12
    UE Reestablish and start traffic to check LB B1 trigered    ue_id=13

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    Create Alias
    Set ue parameters before attach
    Execute Egate Command    trace_sim on mme=1 protocol=s1
    Execute Egate Command    ue_mme_param id=1-10 spid=20
    Execute Egate Command    enb_timer T_SN_STATUS_TRANSFER=5000ms
    Execute Egate Command    enb_timer T_DC_Overall=5000ms

Create Alias
    FOR    ${ue_id}    IN RANGE    1    21
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create UE Alias    UE_24    ue_id=24    id_type=cus
    Create UE Alias    UE_25    ue_id=25    id_type=cus
    Create UE Alias    UE_26    ue_id=26    id_type=cus
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts
Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 31, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}
    ${GNB7_CELL2}    catenate    - {id: 32, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '500000:524000'}
    FOR    ${ue_set_id}     IN RANGE    1    31
        Update Yaml    UEs/UE_sets/${ue_set_id}    capability: ${ue_eutra_cap}    capability_nr: ${ue_nr_cap}    capability_mrdc: ${ue_eutra_nr_cap}
    END
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_2:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    ...     - {qci: 1, gbr_ul: 31, gbr_dl: 31, mbr_ul: 31, mbr_dl: 31, preprovisioned: on, filter: 4, precedence: 4}
    Add Yaml    UEs/bearer_sets
    ...    bearer_set_3:
    ...     - {qci: 6, default: on, pdn: 1}
    ...     - {qci: 8, pdn: 1}
    FOR    ${ue_id}     IN RANGE    1    11
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_2
    END
        FOR    ${ue_id}     IN RANGE    11    21
        Update Yaml    UEs/UE_sets/${ue_id}     bearer: bearer_set_3
    END
    Add Yaml    BASE_STATIONS
    ...    - id: 2
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1: 10.0.1.3
    ...      x2: 10.0.1.3
    ...      cells:
    ...        - {id: 21, technology: lte, tac: 33, pci: '3:0', earfcn: '1700:19700', bw: 20}
    ...        - {id: 22, technology: lte, tdd_cell: yes, duplex_mode: TDD, tac: 33, pci: '3:1', earfcn: '38000:38000', bw: 20}
    ...        - {id: 23, technology: lte, tac: 33, pci: '3:2', earfcn: '1600:19600', bw: 20}
    ...        - {id: 24, technology: lte, tac: 33, pci: '4:0', earfcn: '1900:19900', bw: 20}
    ...        - {id: 25, technology: lte, tac: 33, pci: '4:1', earfcn: '8340:26340', bw: 20}
    Add Yaml    BASE_STATIONS
    ...    - id: 3
    ...      gnb_id: '0x00007'
    ...      type: simulated
    ...      plmn: '262:03'
    ...      s1u: 10.0.1.11
    ...      x2_peers: none
    ...      cells:
    ...        ${GNB7_CELL1}
    ...        ${GNB7_CELL2}

Set ue parameters before attach
    FOR    ${ue_id}    IN RANGE    1    30
        Execute Uex Command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        Execute Uex Command    ue_param id=${ue_id} nr_supported_bands=7,8,40,257
    END
    Execute Egate Command    gnb_endc_param id=3 include_reestablish_pdcp=on
    Execute Egate Command    gnb_endc_param id=3 selected_band_combination_nr=1:1
    Execute Egate Command    gnb_endc_param id=3 use_nr_ran_cont=true
    Execute Egate Command    gnb_endc_param id=3 scg_dl_dist_percent=0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Attach UE
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap} ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}

Attach UE and No ENDC A5 Activate Then Detach
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1    ${a5_query}=${ENDC_A5_activate}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap} ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow not occurred for message    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and Detach
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1    ${a5_query}=${no_ENDC_A5_activate}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap} ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow occurred as expected    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE Without ENDCA5 activate and Detach
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1    ${a5_query}=${ENDC_A5_activate}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap} ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow not occurred for message    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and Detach 06_UE7
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1    ${no_ENDC_A5_activate}=${no_ENDC_A5_activate}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap} ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow occurred as expected    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and Detach UE19
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2f3_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap}    ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow occurred as expected    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and Detach UE20
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2f3_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap}    ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow occurred as expected    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE with A5 Activate On CUS and detach
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_flow    overall_timeout=30
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_cap}    ue_nr_capabilities=${ue_nr_cap}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_cap}
    Execute Uex Command    ${V_1}
    Wait A5 retry timer twice
    flow occurred as expected    alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Lock X2 Link Between SimeNB2 And eNB1
    Execute Egate Command    link_lock link=x2 at=enb:2 to=enb:1
    ...    ENB-2: X2AP Link with ENB-1.* is locked

UnLock X2 Link Between SimeNB2 And eNB1
    Execute Egate Command    link_unlock link=x2 at=enb:2 to=enb:1
    ...    ENB-2: X2AP Link with ENB-1.* is unlocked

Trigger Inter-Enb X2 handover from SimeNB2
    [Arguments]    ${ue_id}=3    ${query}=${no_ENDC_A5_activate}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${query})
    ...    alias=ho_flow    overall_timeout=30
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    flow occurred as expected    alias=ho_flow

Trigger Inter-Enb X2 handover from SimeNB2 Without ENDCA5 Activate
    [Arguments]    ${ue_id}=3    ${query}=${ENDC_A5_activate}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${query})
    ...    alias=ho_flow    overall_timeout=30
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    flow not occurred for message    alias=ho_flow

Trigger Inter-Enb X2 handover from SimeNB2 06_UE8
    [Arguments]    ${ue_id}=3
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2_query})
    ...    alias=ho_flow    overall_timeout=30
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1
    flow occurred as expected    alias=ho_flow

Trigger Inter-Enb X2 handover from SimeNB2 When Enabled CB007136
    [Arguments]    ${ue_id}=3
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=1

Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail
    [Arguments]    ${ue_id}=1    ${a5_query}=${no_ENDC_A5_activate}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${no_ENDC_A5_activate})
    ...    alias=rre_flow    overall_timeout=30
    execute uex command and expect error    ue_ho id=${ue_id} enb=1 cell=1    sErrTransactionInProgress
    flow occurred as expected    alias=rre_flow

Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail And No ENDCA5 Activate
    [Arguments]    ${ue_id}=1    ${a5_query}=${ENDC_A5_activate}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${ENDC_A5_activate})
    ...    alias=rre_flow    overall_timeout=30
    execute uex command and expect error    ue_ho id=${ue_id} enb=1 cell=1    sErrTransactionInProgress
    flow not occurred for message    alias=rre_flow

Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail When Enable CB007136
    [Arguments]    ${ue_id}=1
    execute uex command and expect error    ue_ho id=${ue_id} enb=1 cell=1    sErrTransactionInProgress

Trigger UE reestablish on serving CELL-1 without any ongoing handover
    [Arguments]    ${ue_id}=1
    ${command}    catenate
    ...    ue_rrc_reestablish id=${ue_id} enb=1 cell=1 cause=otherFailure
    Execute Uex Command    ${command}

Trigger UE reestablish back to source CELL-1 during handover to CELL-3
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ho id=${ue_id} enb=1 cell=3 fail=src phase=reconfig_lost

Add ENDC bearer for UE
    [Arguments]    ${ue_id}=1
    execute uex command    bearer_add ue=${ue_id} qci=8 filter=1 precedence=2

Send A1 MR for UE
    [Arguments]    ${ue_id}=1    ${meas_id}=5
    execute uex command    ue_measurement_send id=${ue_id} event=A1 srsrp=96 srsrq=15

Reestablish UE on serving CELL-1 without any ongoing handover and check A5 retry
    [Arguments]    ${ue_id}=2
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_flow    overall_timeout=30
    Attach UE On CUS    ue_id=${ue_id}
    flow occurred as expected    alias=ics_flow
    Trigger UE reestablish on serving CELL-1 without any ongoing handover    ue_id=${ue_id}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=rre_flow    overall_timeout=5
    wait to less than ENDC A5 retry timer
    flow not occurred for message    alias=rre_flow
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=retry_flow    overall_timeout=30
    Wait A5 retry timer twice
    flow occurred as expected    alias=retry_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE reestablish back to source CELL-1 during x2 handover
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_flow    overall_timeout=30
    attach UE On CUS    ue_id=${ue_id}
    flow occurred as expected    alias=ics_flow
    UE reestablish during x2ho and no A5 for the first time    ue_id=${ue_id}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=retry_flow    overall_timeout=30
    Wait A5 retry timer twice
    flow occurred as expected    alias=retry_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE reestablish back to source CELL-1 during S1 handover
    [Arguments]    ${ue_id}=1
    Lock X2 Link Between SimeNB2 And eNB1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_flow    overall_timeout=30
    Attach UE On CUS    ue_id=${ue_id}
    flow occurred as expected    alias=ics_flow
    UE reestablish during s1ho and no A5 for the first time    ue_id=${ue_id}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=retry_flow    overall_timeout=30
    Wait A5 retry timer twice
    flow occurred as expected    alias=retry_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}
    UnLock X2 Link Between SimeNB2 And eNB1

wait to less than ENDC A5 retry timer
    sleep    5s    #ENDC A5 retry timer is 10s

Attach UE On CUS
    [Arguments]    ${ue_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    Wait A5 retry timer twice

Trigger UE reestablish back to source CELL-1 during intra ENB HO
    [Arguments]    ${ue_id}=3
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_flow    overall_timeout=30
    Attach UE On CUS    ue_id=${ue_id}
    flow occurred as expected    alias=ics_flow
    Trigger UE reestablish back to source CELL-1 during handover to CELL-3    ue_id=${ue_id}
    Send A1 MR for UE    ue_id=${ue_id}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=rre_flow    overall_timeout=5
    wait to less than ENDC A5 retry timer
    flow not occurred for message    alias=rre_flow
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=retry_flow    overall_timeout=30
    Wait A5 retry timer twice
    flow occurred as expected    alias=retry_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Wait A5 retry timer twice
    sleep    20s    ##ENDC A5 retry timer is 10s

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2    ue_id=${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS 06_UE13
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2 Without ENDCA5 Activate    ue_id=${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS 06_UE8
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2 06_UE8    ue_id=${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS 06_UE10
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2    ue_id=${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activatef2f3_query})
    ...    alias=ics_enable7163_flow    overall_timeout=30
    Trigger Inter-Enb X2 handover from SimeNB2 When Enabled CB007136    ue_id=${ue_id}
    flow occurred as expected    alias=ics_enable7163_flow

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 16
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2 When Enabled CB007136    ue_id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 12_UE2
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2 When Enabled CB007136    ue_id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 10_UE26
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2 When Enabled CB007136    ue_id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 For Case01
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2 When Enabled CB007136    ue_id=${ue_id}

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    execute uex command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=1 nth=1
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail When Enable CB007136    ue_id=${ue_id}

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure 02
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    execute uex command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=1 nth=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activatef2f3_query})
        ...    alias=rre_enable7163_flow    overall_timeout=30
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail When Enable CB007136    ue_id=${ue_id}
    flow occurred as expected    alias=rre_enable7163_flow

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Execute Uex Command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=1 nth=1
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail    ue_id=${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS No A5 Activate
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Execute Uex Command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=1 nth=1
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail And No ENDCA5 Activate    ue_id=${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Perform ENDC HO and detach UE
    [Arguments]    ${meas_id_blacklist}    ${ue_id}    ${cell_id}=10
    expect message flow
    ...    ENB_2:X2AP_HandoverRequestAcknowledge
    ...    alias=ho_sucess_flow    overall_timeout=30
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${cell_id} nrsrp=43 nrsrq=16 meas_id_blacklist=${meas_id_blacklist}
    flow occurred as expected    alias=ho_sucess_flow
    sleep    5s    # waiting for finishing HO
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Perform ENDC HO and detach UE 02
    [Arguments]    ${meas_id_blacklist}    ${ue_id}    ${cell_id}=10
    expect message flow
    ...    ENB_1:X2AP_HandoverRequest(${ho_cause_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${ho_to_1700})
    ...    alias=HO_enable7163_flow    overall_timeout=30
    Execute Uex Command
    ...    ue_measurement_send id=${ue_id} event=A5 srsrp=60 srsrq=15 phycell_id=${cell_id} nrsrp=43 nrsrq=16 meas_id_blacklist=${meas_id_blacklist}
    flow occurred as expected    alias=HO_enable7163_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Delete gnb_cell
    [Arguments]    ${cell_id}=32    ${gNB_id}=3
    ${command}     catenate    gnb_cell_param    id=${cell_id}    gnb=${gNB_id}    status=disabled
    ${command1}    catenate    endc_conf_update    id=${gNB_id}    target=1    served_nr_cells_to_delete=${cell_id}
    execute egate command    ${command}
    execute egate command    ${command1}
    Object Should Exist    ${NRcell_unava}

Add gnb_cell
    [Arguments]    ${cell_id}=32    ${gNB_id}=3
    ${command}     catenate    gnb_cell_param    id=${cell_id}    gnb=${gNB_id}    status=enabled
    ${command1}    catenate    endc_conf_update    id=${gNB_id}    target=1    served_nr_cells_to_add=${cell_id}
    execute egate command    ${command}
    execute egate command    ${command1}

UE reestablish during x2ho and no A5 for the first time
     [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ho id=${ue_id} enb=2 cell=23 fail=src phase=reconfig_lost
    Send A1 MR for UE    ue_id=${ue_id}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=x2ho_flow    overall_timeout=5
    wait to less than ENDC A5 retry timer
    flow not occurred for message    alias=x2ho_flow

UE reestablish during s1ho and no A5 for the first time
    [Arguments]    ${ue_id}=1
    Execute Uex Command    ue_ho id=${ue_id} enb=2 cell=23 fail=src phase=reconfig_lost
    Send A1 MR for UE    ue_id=${ue_id}
    expect message will not occur
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=s1ho_flow    overall_timeout=5
    wait to less than ENDC A5 retry timer
    flow not occurred for message    alias=s1ho_flow

Check ENDC setup for UE with valid B1
    [Arguments]    ${ue_id}=1    ${phycell_id}=2
    execute uex command    ue_measurement_send id=${ue_id} event=B1_NR phycell_id=${phycell_id} nrsrp=120 meas_id_blacklist=18

start traffic for UE
    [Arguments]    ${ue_id}
    execute uex command    trf_data_start dir=dl Mbps=150 ue=${ue_id} protocol=udp trf_id=1

stop traffic for UE
    [Arguments]    ${ue_id}
    execute uex command    trf_data_stop ue=${ue_id}

Attach UE and start traffic to check AMLE A4 trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    alias=ics_a5activate_flow    overall_timeout=30
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    flow occurred as expected    alias=ics_a5activate_flow
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=a5_retry_flow    overall_timeout=60
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer
    stop traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    flow occurred as expected     alias=a5_retry_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and start traffic to check AMLE A4 not trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToAddModList contains (measId eq 3))
    ...    alias=ics_flow    overall_timeout=60
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer
    stop traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    flow occurred as expected     alias=ics_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

wait a5 retry timer
    sleep    10s    #ENDC A5 retry timer is 10s

UE Inter-Enb X2 handover and start traffic to check AMLE A4 trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    ENB_2:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3,5,6))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToAddModList contains (measId eq 3,measId eq 5,measId eq 6))
    ...    alias=ho_activate_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 12_UE2    ue_id=${ue_id}    cell_id=24
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer
    stop traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    flow occurred as expected    alias=ho_activate_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

UE Reestablish and start traffic to check AMLE A4 trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    ENB_2:X2AP_HandoverRequest
    ...    ENB_1:X2AP_HandoverRequestAcknowledge
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef1f2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3,5,6))
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToAddModList contains (measId eq 3,measId eq 5,measId eq 6))
    ...    alias=rre_activate_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure    ue_id=${ue_id}    cell_id=24
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    stop traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    flow occurred as expected    alias=rre_activate_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and start traffic to check LB B1 trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_1600_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${LB_B1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3) and s-Measure eq 75) #remove lb_b1
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=ics_flow1    overall_timeout=60
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${LB_B1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3) and s-Measure eq 75) #remove lb_b1
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_1600_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=ics_flow2    overall_timeout=60
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer
    stop traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    Verify At Least One Flow Occurs As Expected    ics_flow1    ics_flow2
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

UE Inter-Enb X2 handover and start traffic to check LB B1 trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_1600_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${LB_B1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3) and s-Measure eq 75) #remove lb_b1
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=ho_flow1    overall_timeout=60
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${LB_B1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3) and s-Measure eq 75) #remove lb_b1
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_1600_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=ho_flow2    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 16    ue_id=${ue_id}    cell_id=24
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer
    stop traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    Verify At Least One Flow Occurs As Expected    ho_flow1    ho_flow2
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

UE Reestablish and start traffic to check LB B1 trigered
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${LB_B1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3) and s-Measure eq 75)
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_1600_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    alias=rre_flow1    overall_timeout=120
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_1600_activate})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a4_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${LB_B1})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToRemoveList contains (3) and s-Measure eq 75)
    ...    alias=rre_flow2    overall_timeout=120
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure    ue_id=${ue_id}    cell_id=24
    wait a5 retry timer
    start traffic for UE    ue_id=${ue_id}
    wait a5 retry timer twice
    Verify At Least One Flow Occurs As Expected    rre_flow1    rre_flow2
    onlineparamchange     LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    alias=a5retry_flow    overall_timeout=120
    wait a5 retry timer twice
    flow occurred as expected    alias=a5retry_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Attach UE and Perform ENDC HO
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${source_cell_id}=1    ${target_cell_id}=9
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activatef1f2f4_query})
    ...    alias=ics_enable7163_flow    overall_timeout=30
    Attach UE    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${source_cell_id}
    Perform ENDC HO and detach UE    meas_id_blacklist=3    ue_id=${ue_id}    cell_id=${target_cell_id}
    flow occurred as expected    alias=ics_enable7163_flow

Attach UE and Perform ENDC HO 02
    [Arguments]    ${ue_id}=1    ${enb_id}=1    ${source_cell_id}=1    ${target_cell_id}=9
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${ho_to_1700})
    ...    alias=ics_enable7163_flow    overall_timeout=30
    Attach UE    ue_id=${ue_id}    enb_id=${enb_id}    cell_id=${source_cell_id}
    Perform ENDC HO and detach UE    meas_id_blacklist=3    ue_id=${ue_id}    cell_id=${target_cell_id}
    flow occurred as expected    alias=ics_enable7163_flow

UE Inter-Enb X2 handover and Perform ENDC HO
     [Arguments]    ${ue_id}=1    ${cell_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activatef2f3f4_query})
    ...    alias=ho_enable7163_flow    overall_timeout=30
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 For Case01    ue_id=${ue_id}    cell_id=${cell_id}
    Perform ENDC HO and detach UE    meas_id_blacklist=5,6    ue_id=${ue_id}    cell_id=10
    flow occurred as expected    alias=ho_enable7163_flow

UE Reestablish and Perform ENDC HO
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${file}=A5_UE6
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration (${a5_activatef2f3f4_query})
    ...    alias=rre_enable7163_flow    overall_timeout=30
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure    ue_id=${ue_id}    cell_id=${cell_id}
    Perform ENDC HO and detach UE    meas_id_blacklist=5,6    ue_id=${ue_id}    cell_id=10
    flow occurred as expected    alias=rre_enable7163_flow

UE enter cell via ICS or HO or reestablish and check no A5 activated
    Attach UE and Detach    ue_id=1    enb_id=1    cell_id=1
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=2    cell_id=24
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=3    cell_id=24

UE enter cell via ICS or HO or reestablish and check no A5 activated when 7163 disable
    Attach UE and Detach    ue_id=11    enb_id=1    cell_id=1
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=12    cell_id=24
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=13    cell_id=24

UE enter cell via ICS or HO or reestablish and perform ENDC HO when 7163 enable
    Attach UE and perform ENDC HO 02    ue_id=15    enb_id=1    source_cell_id=1    target_cell_id=9
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1    ue_id=16    cell_id=24
    Perform ENDC HO and detach UE 02    meas_id_blacklist=3    ue_id=16    cell_id=9
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure 02    ue_id=17    cell_id=24
    ${ho_to_1700}    catenate
    ...    mobilityControlInfo contains ( targetPhysCellId eq 9 and carrierFreq contains (dl-CarrierFreq eq 1700))
    expect message flow
    ...    ENB_1:X2AP_HandoverRequest(${ho_cause_query})
    ...    UE_17:RRC_RRCConnectionReconfiguration (${ho_to_1700})
    ...    alias=HO_enable7163_flow    overall_timeout=30
    Perform ENDC HO and detach UE    meas_id_blacklist=3    ue_id=17    cell_id=9
    flow occurred as expected    alias=HO_enable7163_flow

Attach UE before and after delete gNB_cell On CUS
    Attach UE with A5 Activate On CUS and detach    ue_id=18    enb_id=1    cell_id=1
    Delete gnb_cell
    Attach UE and Detach UE19    ue_id=19    enb_id=1    cell_id=1

UE enter cell via ICS or HO or reestablish and check A5 activated or not
    Attach UE and Detach    ue_id=4    enb_id=1    cell_id=1
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=5    cell_id=21
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=6    cell_id=22

UE attach HO and reestablish and check A5 activated after enable 6607
    OnlineParamChange    ${enable_6607_add_LNHOIF}    #enbale 6607, add 38000, f0 not in MOPR-1 list
    Attach UE and Detach 06_UE7    ue_id=7    enb_id=1    cell_id=1
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=8    cell_id=21
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=9    cell_id=22

UE enter cell via ICS or HO or reestablish and check A5 activated after add LNHOIF
    Attach UE and Detach    ue_id=16    enb_id=1    cell_id=1    a5_query=${a5_activatef2f3_query}
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS 06_UE10    ue_id=10    cell_id=21
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=11    cell_id=22

UE enter cell via ICS or HO or reestablish and check no A5 activated after serving cell into endc list
    Attach UE Without ENDCA5 activate and Detach    ue_id=12    enb_id=1    cell_id=1
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS 06_UE13    ue_id=13    cell_id=24
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS No A5 Activate    ue_id=14    cell_id=24

UE enter cell via attach or HO or reestablish and no ENDC A5 when serving cell in prefer freqLayEndcHoList
    OnlineParamChange    ${serving cell in ENDC list and delete LNHOIF}     #F0 in list, delete 38000 1700, 6607 disable
    UE enter cell via ICS or HO or reestablish and check no A5 activated

Attach UE and setup ENDC
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    alias=ics_flow    overall_timeout=40
    Attach UE    ue_id=${ue_id}    enb_id=1    cell_id=1
    Check ENDC setup for UE with valid B1    ue_id=${ue_id}    phycell_id=2
    Wait A5 retry timer twice
    flow occurred as expected    alias=ics_flow

Trigger Inter-Enb X2 handover and setup ENDC
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    alias=ho_flow    overall_timeout=40
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 10_UE26    ue_id=${ue_id}    cell_id=24
    Check ENDC setup for UE with valid B1    ue_id=${ue_id}    phycell_id=2
    Wait A5 retry timer twice
    flow occurred as expected    alias=ho_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Trigger UE Reestablish and setup ENDC
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_activatef2f3_query})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_retry})
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(${a5_remove})
    ...    alias=rre_flow    overall_timeout=40
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure    ue_id=${ue_id}    cell_id=24
    Add ENDC bearer for UE    ue_id=${ue_id}
    Check ENDC setup for UE with valid B1    ue_id=${ue_id}    phycell_id=2
    Wait A5 retry timer twice
    flow occurred as expected    alias=rre_flow
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}

Delete gNB_cell and attach UE to check A5 activated
    [Arguments]    ${ue_id}=1
    Delete gnb_cell
    Attach UE and Detach    ue_id=${ue_id}    enb_id=1    cell_id=1    a5_query=${a5_activatef1f2f3_query}
    Add gnb_cell
    Wait A5 retry timer twice

Local Test Teardown And Recover Env For Case
    Add gnb_cell
    Common Test Teardown And Stop Capture Logs

wait A5 activated for new freq
    [Arguments]    ${ue_id}=1
    expect message flow
    ...    UE_${ue_id}:RRC_RRCConnectionReconfiguration(measIdToAddModList contains (measId eq 3))
    ...    alias=a5activate_flow    overall_timeout=20
    Execute Egate Command    set_log flush
    flow occurred as expected    alias=a5activate_flow

Detach UE
    [Arguments]    ${ue_id}
    [Teardown]    Execute Uex Command    ue_detach id=${ue_id}