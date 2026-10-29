*** Settings ***
Suite Setup       Common Suite Setup And Setup CUS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_4G    RAN_4G_FDD    CRT    CLOUD_R4A_CUS    team-DevHZ5_SG1
...               owner-feng.2.chen    release-SBTS22R4
Resource          ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_VENDOR}
...    LNBTS:reportTimerEndcA5=5000ms

@{PARAMS_IN_SCF}
...    @{x2link}
...    @{LTE4088}
...    @{LTE4193}
...    @{NRDCDPR_CONFIG}
...    @{PARAMS_FOR_CELL_CONFIG}
...    @{add_moPrMapList}
...    @{HO_para}
...    @{CB007163}
...    @{7747_config}

${f1}    1600    #f1 (band3) & nrband257
${f2}    38000    #f2 (band38)& nrband7
${f3}    1700    #f3 (band3) & nrband8
${f4}    900     #f4 (band2) & nrband40 ->not supported

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
...    LNBTS:actLteNrDualConnectivity=true
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

@{7747_config}
...    LNBTS-1:actNrFreqFilterForEnDc=true
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
...    MODPR-0:allowEnDc=all_freq_layers
...    MOPR-1:allowEnDc=all_freq_layers
...    MOPR-3:allowEnDc=all_freq_layers
...    MOPR-2:allowEnDc=all_freq_layers
...    MOPR-1:freqLayListEnDc:carrierFreqNrCell=${F1}|carrierFreqNrCell=${F1}
...    MODPR-0:freqLayListEnDc:carrierFreqNrCell=${F4}|carrierFreqNrCell=${F4}

@{add_moPrMapList}
...    LNBTS-1:actSelMobPrf=true
...    LNBTS-1/MODPR-0:autoAdapt=false
...    LNBTS-1:moProfileSelect=spid
...    LNCEL-1:moPrMappingList:spid=2|moPrId=1
...    LNCEL-1:moPrMappingList:spidLast=100|moPrId=1
...    LNCEL-1:moPrMappingList:mcc=262|moPrId=1
...    LNCEL-1:moPrMappingList:mnc=3|moPrId=1
...    LNCEL-1:moPrMappingList:mncLength=2|moPrId=1

${ue_nr_capabilities}    0000000001010040000060000038000400040160401C06000000
${ue_eutra_nr_capabilities}    SEPARATOR=
...    010810036040080819280701800000006C08010102020E0380000000D81003060061401D0000000001B01004020804385000000000180004
...    020001008000402020040080

${ue_eutra_capabilities}    SEPARATOR=
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

@{precondition_for_case6}
...    LNBTS:actDynTrigLteNrDualConnectivity=false    #LTE4193 disable
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f2}
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking

@{precondition_for_case1}
...    LNBTS:actDynTrigLteNrDualConnectivity=false    #LTE4193 disable
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking

@{precondition_for_case2}
...    LNBTS:actLteNrDualConnectivity=true    #LTE4088 enabled
...    LNBTS:actDynTrigLteNrDualConnectivity=false    #LTE4193 enabled
...    LNBTS:actEndcHo=enabled    #(LTE5150)
...    LNBTS:actUeCapEndcHo=true    #(CB006607)
...    LNCEL:actEndcHoPrefLay=true    #(CB007163)
...    LNBTS/MODPR-0:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MOPR-1:configUeCapEndcHoRetry=priorityAboveLoadBasedHo
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=true|freqLayer=${f1}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f2}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f2}
...    LNBTS/MODPR-0:freqLayEndcHoList:preference=false|freqLayer=${f3}
...    LNBTS/MOPR-1:freqLayEndcHoList:preference=false|freqLayer=${f3}
...    LNBTS:blockEndcHoRetryAtHoFromTrg=both
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
${a5_retry_f1f2}    measIdToAddModList contains (measId eq 3,measId eq 5)
${a5_remove_f1f2}    measIdToRemoveList contains (3,5)
${a5_activatef1_query}
...    measObjectToAddModList contains (
...    carrierFreq eq 1600
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
${a5_retry_1f}    measIdToAddModList contains (measId eq 3)
${a5_remove_1f}    measIdToRemoveList contains (3)
${a5_ENDC_activate}    eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))
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
${a5f1f2f3_retry}    measIdToAddModList contains (measId eq 3,measId eq 5,measId eq 6)
${a5f1f2f3_remove}    measIdToRemoveList contains (3,5,6)
${a5_ENDC_activate}    eventA5 contains (a5-Threshold1 contains (threshold-RSRP eq 97))
*** Test Cases ***
CB007163_A-B9_ET_01_01_Retry timer blocked for ENDC-HO upon reestablishment or incoming HO from CB007163 target list
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    CB007163 target: f1
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
    ...    step1: UE1 ICS to serving cell and A5 activation and retry, UE2 X2 Ho from target cell f1, A5 retry is not blocked
    ...    UE3 reestablish from target cell f1, A5 retry is not blocked
    ...    step2: change LNBTS:blockEndcHoRetryAtHoFromTrg=ENDC HO to preferred layer
    ...    step3: UE5 X2 Ho from target cell f1, A5 activate and retry is blocked, UE6 reestablish from target cell f1, no A5
    ...    step4: change LNBTS:blockEndcHoRetryAtHoFromTrg=both
    ...    step5: UE8 X2 Ho from target cell f1, A5 activate and retry is blocked, UE9 reestablish from target cell f1, no A5
    ...    step6: change LNBTS:blockEndcHoRetryAtHoFromTrg=MR-DC based HO, only block 6607
    ...    step7: UE11 X2 Ho from target cell f1, A5 retry is not blocked, UE12 reestablish from target cell f1, A5 retry is not blocked
    [Tags]    QC_01
    OnlineParamChange    ${precondition_for_case1}
    UE enter cell via ICS or HO or reestablish and check A5 retry not blocked
    Retry timer is blocked when blockEndcHoRetryAtHoFromTrg is both or ENDC HO to preferred layer
    Retry timer is not blocked when blockEndcHoRetryAtHoFromTrg is MR-DC based HO

CB007163_A-B9_ET_02_01_Retry timer not blocked upon reestablishment or incoming HO from ENDC-HO non target list
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    CB007163 target: f1
    ...    CB006607 target: f1, f2, f3
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    LNBTS:blockEndcHoRetryAtHoFromTrg=both
    ...    step1: UE1 ICS to serving cell and A5 activation and retry, UE2 X2 Ho from target cell f2, A5 retry is not blocked
    ...    UE3 reestablish from target cell f3, A5 retry is not blocked
    ...    step2: delete gNB cell to make serving cell not anchor layer
    ...    step3: UE4 ICS to serving cell and A5 activation and retry, UE5 X2 Ho from target cell f4, A5 retry is not blocked
    ...    UE6 reestablish from target cell f3, A5 retry is blocked
    ...    step4: add gnb_cell
    ...    step5: UE7 ICS to serving cell and A5 activation and retry, UE8 X2 Ho from target cell f1, A5 retry is blocked
    ...    UE9 reestablish from target cell f2, A5 retry is not blocked
    [Tags]    QC_02
    OnlineParamChange    ${precondition_for_case2}
    Retry timer is not blocked when reestablishment or incoming HO from ENDC-HO non target list for 7163
    Make serving cell from anchor layer to non-anchor by disable GNB cell
    Retry timer is not blocked when reestablishment or incoming HO from ENDC-HO non target list for 6607
    Make serving cell from non-anchor layer to anchor by enable GNB cell
    Retry timer not blocked for ICS Including TA Message Check
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 Including TA Message Check
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure Including TA Message Check

CB007163_A-B9_ET_06_01_Retry timer blocked for ENDC-HO upon reestablishment or incoming HO from CB006607 target list
    [Documentation]
    ...    precondition: f1=1600 (band3,FDD), f2=38000 (band38, Tdd), f3=1700(band3, FDD),f4=900 (band2, FDD)
    ...    CB006607 target: f1 f2
    ...    LNBTS:actEndcHo=enabled (LTE5150)
    ...    LNBTS:actUeCapEndcHo=true (CB006607)
    ...    LNCEL:actEndcHoPrefLay=true (CB007163)
    ...    LNBTS:actLteNrDualConnectivity=true (LTE4088 enabled)
    ...    LNBTS-1:blockEndcHoRetryAtHoFromTrg=no blocking
    ...    step1: delete gNB cell to make serving cell not anchor layer
    ...    step2: UE1 ICS to serving cell and A5 activation and retry, UE2 X2 Ho from target cell f1, A5 retry is not blocked
    ...    UE3 reestablish from target cell f2, A5 retry is not blocked
    ...    step3: change LNBTS:blockEndcHoRetryAtHoFromTrg=both
    ...    step4: UE4 ICS to serving cell and A5 activation and retry, UE5 X2 Ho from target cell f1, A5 retry is blocked
    ...    UE3 reestablish from target cell f2, A5 retry is blocked
    ...    step5: change LNBTS:blockEndcHoRetryAtHoFromTrg=MR-DC based HO
    ...    step6: UE7 ICS to serving cell and A5 activation and retry, UE8 X2 Ho from target cell f1, A5 retry is blocked
    ...    UE9 reestablish from target cell f2, A5 retry is blocked
    ...    step7: change LNBTS:blockEndcHoRetryAtHoFromTrg=ENDC HO to preferred layer
    ...    step8: UE10 ICS to serving cell and A5 activation and retry, UE11 X2 Ho from target cell f1, A5 retry is not blocked
    ...    UE12 reestablish from target cell f2, A5 retry is not blocked
    [Tags]    QC_03
    OnlineParamChange    ${precondition_for_case6}
    Make serving cell from anchor layer to non-anchor by disable GNB cell
    Retry timer is not blocked for CB006607 when UE enter cell via ICS or reestablishment or Ho
    Retry timer is blocked when UE reestablishment or Ho from CB006607 target list with blockEndcHoRetryAtHoFromTrg setting
    OnlineParamChange    LNBTS:blockEndcHoRetryAtHoFromTrg=ENDC HO to preferred layer
    Retry timer not blocked for ICS blockEndcHoRetryAtHoFromTrg Equal ENDC
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 blockEndcHoRetryAtHoFromTrg Equal ENDC
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure blockEndcHoRetryAtHoFromTrg Equal ENDC
    [teardown]    Local Test Teardown And Recover Env For Case

*** Keywords ***
Common Suite Setup And Setup CUS Env
    Common Suite Setup
    Setup CUS Env    tl_type=3CELLs_FDD
    execute egate command    trace_sim on mme=1 protocol=s1
    Set ue parameters before attach
    execute egate command    ue_mme_param id=1-10 spid=20
    FOR    ${ue_id}    IN RANGE    1    21
        Create UE Alias    UE_${ue_id}    ue_id=${ue_id}    id_type=cus
    END
    Create Enb Alias    ENB_1    enb_id=1    id_type=wts
    Create Enb Alias    ENB_2    enb_id=2    id_type=wts
    Create MME Alias    alias=MME_1    mme_id=1    id_type=wts

Modify Yaml
    ${GNB7_CELL1}    catenate    - {id: 31, technology: nr , tac: 33, pci: '0:1', nrci: '0x0000501', nr_arfcn: '507000:531000'}
    ${GNB7_CELL2}    catenate    - {id: 32, technology: nr , tac: 33, pci: '0:2', nrci: '0x0000502', nr_arfcn: '500000:524000'}
    # update UE capability
    FOR    ${ue_set_id}     IN RANGE    1    31
        ${ue_capablity_set}  catenate
        ...    UEs/UE_sets/${ue_set_id}    capability: ${ue_eutra_capabilities}
        ...    capability_nr: ${ue_nr_capabilities}    capability_mrdc: ${ue_eutra_nr_capabilities}
        Update Yaml    ${ue_capablity_set}
    END
    # modify UE4 bearer
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
    # add sim enb2
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
        execute uex command    ue_param id=${ue_id} dual_conn=eutra_nr pdcp_sn_extension=18bit
        execute uex command    ue_param id=${ue_id} nr_supported_bands=7,8,40,257
    END
    execute egate command
    ...    gnb_endc_param id=3 include_reestablish_pdcp=on selected_band_combination_nr=1:1 use_nr_ran_cont=true scg_dl_dist_percent=0

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Attach UE
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    ...    ${ue_eutra_nr_capabilities}=${ue_eutra_nr_capabilities}    ${ue_eutra_capabilities}=${ue_eutra_capabilities}
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V_1}

Retry timer not blocked for ICS Including TA Message Check
    expect message flow
    ...    UE_7:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_7:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_7:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue7_flow    overall_timeout=60
    Retry timer not blocked for ICS    ue_id=7    enb_id=1    cell_id=1
    flow occurred as expected    alias=ue7_flow

Retry timer not blocked for ICS
    [Arguments]    ${ue_id}    ${enb_id}=1    ${cell_id}=1
    ${V_1}    catenate
    ...    ue_attach id=${ue_id} enb=${enb_id} cell=${cell_id}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${ue_nr_capabilities}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    execute uex command    ${V_1}
    Wait A5 retry timer twice
    Detach UE    ue_id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2
    [Arguments]    ${ue_id}=3
    execute uex command    ue_ho id=${ue_id} enb=1 cell=1

Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail
    [Arguments]    ${ue_id}=1
    execute uex command
    ...    ue_rrc_reconf_param id=${ue_id} if_contains=mobilityControlInfo action=reestablish cause=handoverFailure cell=1 nth=1
    execute uex command and expect error   ue_ho id=${ue_id} enb=1 cell=1    sErrTransactionInProgress

Detach UE
    [Arguments]    ${ue_id}
    Execute Uex Command    ue_detach id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS
    [Arguments]    ${ue_id}=1    ${cell_id}=1
    Attach UE    ue_id=${ue_id}    enb_id=2    cell_id=${cell_id}
    Trigger Inter-Enb X2 handover from SimeNB2    ue_id=${ue_id}
    Wait A5 retry timer twice
    Detach UE    ue_id=${ue_id}

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 Including TA Message Check
    Expect Message Will Not Occur
    ...    UE_8:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue8_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=8    cell_id=23
    Flow Not Occurred For Message    alias=ue8_flow

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS
    [Arguments]    ${ue_id}=3    ${cell_id}=1
    Attach UE    ue_id=${ue_id}     enb_id=2     cell_id=${cell_id}     ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO fail    ue_id=${ue_id}
    Wait A5 retry timer twice
    sleep    10s   #source cell in CB007163 target list，need to retry for activate a5
    Detach UE    ue_id=${ue_id}

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure Including TA Message Check
    expect message flow
    ...    UE_9:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_9:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_9:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue9_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=9    cell_id=21
    flow occurred as expected    alias=ue9_flow

Make serving cell from anchor layer to non-anchor by disable GNB cell
    [Arguments]    ${cell_id}=32    ${gNB_id}=3
    ${command}     catenate    gnb_cell_param    id=${cell_id}    gnb=${gNB_id}    status=disabled
    ${command1}    catenate    endc_conf_update    id=${gNB_id}    target=1    served_nr_cells_to_delete=${cell_id}
    execute egate command    ${command}
    execute egate command    ${command1}
    Object Should Exist    ${NRcell_unava}

Make serving cell from non-anchor layer to anchor by enable GNB cell
    [Arguments]    ${cell_id}=32    ${gNB_id}=3
    ${command}     catenate    gnb_cell_param    id=${cell_id}    gnb=${gNB_id}    status=enabled
    ${command1}    catenate    endc_conf_update    id=${gNB_id}    target=1    served_nr_cells_to_add=${cell_id}
    execute egate command    ${command}
    execute egate command    ${command1}

Local Test Teardown And Recover Env For Case
    Make serving cell from non-anchor layer to anchor by enable GNB cell
    Common Test Teardown And Stop Capture Logs

UE enter cell via ICS or HO or reestablish and check A5 retry not blocked
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ics_flow    overall_timeout=30
    Retry timer not blocked for ICS    ue_id=1    enb_id=1    cell_id=1
    flow occurred as expected    alias=ics_flow
    expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ho_flow    overall_timeout=30
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=2    cell_id=23
    flow occurred as expected    alias=ho_flow
    expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=rre_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=3    cell_id=23
    flow occurred as expected    alias=rre_flow

Retry timer is blocked when blockEndcHoRetryAtHoFromTrg is both or ENDC HO to preferred layer
    OnlineParamChange    LNBTS:blockEndcHoRetryAtHoFromTrg=ENDC HO to preferred layer
    expect message will not occur
    ...    UE_5:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue5_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=5    cell_id=23
    flow not occurred for message  alias=ue5_flow
    expect message will not occur
    ...    UE_6:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue6_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=6    cell_id=23
    flow not occurred for message  alias=ue6_flow
    OnlineParamChange    LNBTS:blockEndcHoRetryAtHoFromTrg=both
    expect message will not occur
    ...    UE_8:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue8_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=8    cell_id=23
    flow not occurred for message  alias=ue8_flow
    expect message will not occur
    ...    UE_9:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue9_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=9    cell_id=23
    flow not occurred for message    alias=ue9_flow

Retry timer is not blocked when blockEndcHoRetryAtHoFromTrg is MR-DC based HO
    OnlineParamChange    LNBTS:blockEndcHoRetryAtHoFromTrg=MR-DC based HO
    expect message flow
    ...    UE_11:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_11:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_11:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue11_flow    overall_timeout=30
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=11    cell_id=23
    flow occurred as expected    alias=ue11_flow
    expect message flow
    ...    UE_12:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_12:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_12:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue12_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=12    cell_id=23
    flow occurred as expected    alias=ue12_flow

Retry timer is not blocked for CB006607 when UE enter cell via ICS or reestablishment or Ho
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue1_flow    overall_timeout=60
    Retry timer not blocked for ICS    ue_id=1    enb_id=1    cell_id=1
    flow occurred as expected    alias=ue1_flow
    expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue2_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=2    cell_id=23
    flow occurred as expected    alias=ue2_flow
    expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue3_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=3    cell_id=22
    flow occurred as expected    alias=ue3_flow

Retry timer is blocked when UE reestablishment or Ho from CB006607 target list with blockEndcHoRetryAtHoFromTrg setting
    OnlineParamChange    LNBTS:blockEndcHoRetryAtHoFromTrg=both
    expect message flow
    ...    UE_4:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_4:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_4:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue4_flow    overall_timeout=60
    Retry timer not blocked for ICS    ue_id=4    enb_id=1    cell_id=1
    flow occurred as expected    alias=ue4_flow
    Expect Message Will Not Occur
    ...    UE_5:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue5_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=5    cell_id=23
    Flow Not Occurred For Message    alias=ue5_flow
    Expect Message Will Not Occur
    ...    UE_6:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue6_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=6    cell_id=22
    Flow Not Occurred For Message    alias=ue6_flow
    OnlineParamChange    LNBTS:blockEndcHoRetryAtHoFromTrg=MR-DC based HO
    expect message flow
    ...    UE_7:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_7:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_7:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue7_flow    overall_timeout=60
    Retry timer not blocked for ICS    ue_id=7    enb_id=1    cell_id=1
    flow occurred as expected    alias=ue7_flow
    Expect Message Will Not Occur
    ...    UE_8:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue8_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=8    cell_id=23
    Flow Not Occurred For Message    alias=ue8_flow
    Expect Message Will Not Occur
    ...    UE_9:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue9_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=9    cell_id=22
    Flow Not Occurred For Message    alias=ue9_flow

Retry timer is not blocked when reestablishment or incoming HO from ENDC-HO non target list for 7163
    expect message flow
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_1:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue1_flow    overall_timeout=60
    Retry timer not blocked for ICS    ue_id=1    enb_id=1    cell_id=1
    flow occurred as expected    alias=ue1_flow
    expect message flow
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_2:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue2_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=2    cell_id=21
    flow occurred as expected    alias=ue2_flow
    expect message flow
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_activatef1_query})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_remove_1f})
    ...    UE_3:RRC_RRCConnectionReconfiguration(${a5_retry_1f})
    ...    alias=ue3_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=3    cell_id=22
    flow occurred as expected    alias=ue3_flow

Retry timer is not blocked when reestablishment or incoming HO from ENDC-HO non target list for 6607
    expect message flow
    ...    UE_4:RRC_RRCConnectionReconfiguration(${a5_activatef1f2f3_query})
    ...    UE_4:RRC_RRCConnectionReconfiguration(${a5f1f2f3_remove})
    ...    UE_4:RRC_RRCConnectionReconfiguration(${a5f1f2f3_retry})
    ...    alias=ue4_flow  overall_timeout=60
    Retry timer not blocked for ICS    ue_id=4    enb_id=1    cell_id=1    #CB006607 1600 1700 38000 A5 activated
    flow occurred as expected    alias=ue4_flow
    expect message flow
    ...    UE_5:RRC_RRCConnectionReconfiguration(${a5_activatef1f2f3_query})
    ...    UE_5:RRC_RRCConnectionReconfiguration(${a5f1f2f3_remove})
    ...    UE_5:RRC_RRCConnectionReconfiguration(${a5f1f2f3_retry})
    ...    alias=ue5_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=5    cell_id=24
    flow occurred as expected    alias=ue5_flow
    expect message will not occur
    ...    UE_6:RRC_RRCConnectionReconfiguration(${a5_ENDC_activate})
    ...    alias=ue6_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=6    cell_id=21
    flow not occurred for message    alias=ue6_flow

Retry timer not blocked for ICS blockEndcHoRetryAtHoFromTrg Equal ENDC
    expect message flow
    ...    UE_10:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_10:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_10:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue10_flow    overall_timeout=60
    Retry timer not blocked for ICS    ue_id=10    enb_id=1    cell_id=1
    flow occurred as expected    alias=ue10_flow

Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 blockEndcHoRetryAtHoFromTrg Equal ENDC
    expect message flow
    ...    UE_11:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_11:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_11:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue11_flow    overall_timeout=60
    Trigger Inter-Enb X2 handover from SimeNB2 To ENB-1 CELL-1 On CUS    ue_id=11    cell_id=23
    flow occurred as expected    alias=ue11_flow

Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure blockEndcHoRetryAtHoFromTrg Equal ENDC
    expect message flow
    ...    UE_12:RRC_RRCConnectionReconfiguration(${a5_activatef1f2_query})
    ...    UE_12:RRC_RRCConnectionReconfiguration(${a5_remove_f1f2})
    ...    UE_12:RRC_RRCConnectionReconfiguration(${a5_retry_f1f2})
    ...    alias=ue12_flow    overall_timeout=60
    Trigger UE Reestablish to target ENB-1_CELL-1 due HO failure On CUS    ue_id=12    cell_id=22
    flow occurred as expected    alias=ue12_flow

Wait A5 retry timer twice
    sleep    20s    ##ENDC A5 retry timer is 10s
