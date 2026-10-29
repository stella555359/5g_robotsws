*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-CN1ET
...    owner-lena.zhuo    release-SBTS24R3    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_Xn_GNB1}
...    @{PARAMS_FOR_NBR_GNB1}
...    @{PARAMS_FOR_ransharing_GNB1}
...    @{PARAMS_FOR_HO_GNB1}
...    @{PARAMS_FOR_VONR_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_Xn_GNB2}
...    @{PARAMS_FOR_NBR_GNB2}
...    @{PARAMS_FOR_ransharing_GNB2}
...    @{PARAMS_FOR_HO_GNB2}
...    @{PARAMS_FOR_VONR_GNB2}

@{PARAMS_FOR_Xn_GNB1}
...    NRBTS-1/NRADJGNB-1:gNodeBId=2
...    NRBTS-1/NRADJGNB-1:xnLinkRef=1
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJGNB-1:weightForIgnbCaSelection=${EMPTY}
...    NRBTS-1/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS-1/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS-1/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS-1/NRADJNRCELL-13:gNbId=2
...    NRBTS-1/NRADJNRCELL-13:lcrId=13
...    NRBTS-1/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS-1/NRADJNRCELL-13:physCellId=62
...    NRBTS-1/NRADJNRCELL-13:ssbFrequency=368430
...    NRBTS-1/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS-1/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS-1/NRADJNRCELL-14:freqBandIndicatorNR=71
...    NRBTS-1/NRADJNRCELL-14:gNbId=2
...    NRBTS-1/NRADJNRCELL-14:lcrId=14
...    NRBTS-1/NRADJNRCELL-14:nrarfcn=126900
...    NRBTS-1/NRADJNRCELL-14:physCellId=63
...    NRBTS-1/NRADJNRCELL-14:ssbFrequency=126750
...    NRBTS-1/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS-1/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS-1/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.3
...    NRBTS-1:actIncXn=true

@{PARAMS_FOR_Xn_GNB2}
...    NRBTS-2/NRADJGNB-1:gNodeBId=1
...    NRBTS-2/NRADJGNB-1:xnLinkRef=1
...    NRBTS-2/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS-2/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS-2/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS-2/NRADJGNB-1:weightForIgnbCaSelection=${EMPTY}
...    NRBTS-2/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS-2/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS-2/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS-2/NRADJNRCELL-11:gNbId=1
...    NRBTS-2/NRADJNRCELL-11:lcrId=11
...    NRBTS-2/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS-2/NRADJNRCELL-11:physCellId=60
...    NRBTS-2/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS-2/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS-2/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS-2/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS-2/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS-2/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS-2/NRADJNRCELL-12:freqBandIndicatorNR=28
...    NRBTS-2/NRADJNRCELL-12:gNbId=1
...    NRBTS-2/NRADJNRCELL-12:lcrId=12
...    NRBTS-2/NRADJNRCELL-12:nrarfcn=156000
...    NRBTS-2/NRADJNRCELL-12:physCellId=61
...    NRBTS-2/NRADJNRCELL-12:ssbFrequency=156030
...    NRBTS-2/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS-2/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS-2/NRADJNRCELL-12:gnbPlmn:mncLength=3
...    NRBTS-2/XNLINK-1:cPlaneIpAddr=10.0.1.2
...    NRBTS-2:actIncXn=true

@{PARAMS_FOR_HO_GNB1}
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actIntraFreqHoSA=true
...    @{PARAMS_FOR_NRHOIF_GNB1}
...    @{PARAMS_FOR_NRREL_GNB1}
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms100
...    NRCELL-11:a1MeashoEnabledSA=rsrp
...    NRCELL-11:a2MeashoEnabledSA=rsrp
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:absThreshSsbRsrpConsolidation=0
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:measGapSelectionSA=favourUeThroughput

@{PARAMS_FOR_HO_GNB2}
...    NRBTS-2:actIntraFreqHoSA=true
...    NRBTS-2:actInterFreqHoSA=true
...    NRCELL-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms128
...    NRCELL-13:a3MeasEnabled=rsrp
...    NRCELL-13:absThreshSsbRsrpConsolidation=0
...    NRCELL-13:sMeasConfigSsbRsrp=0
...    NRCELL-13:a1MeashoEnabledSA=rsrp
...    NRCELL-13:a2MeashoEnabledSA=rsrp
...    NRCELL-13:measGapSelectionSA=favourUeThroughput
...    NRCELL-14:a1MeashoEnabledSA=rsrp
...    NRCELL-14:a2MeashoEnabledSA=rsrp
...    NRCELL-14:measGapSelectionSA=favourUeThroughput
...    NRBTS-2/NRPMRNL-1:miNrRelReportCu=5min
...    @{PARAMS_FOR_NRHOIF_GNB2}
...    @{PARAMS_FOR_NRREL_GNB2}


@{PARAMS_FOR_NRREL_GNB1}
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-12:gNbId=1
...    NRCELL-11/NRREL-12:lcrId=12
...    NRCELL-11/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-11:gNbId=1
...    NRCELL-12/NRREL-11:lcrId=11
...    NRCELL-12/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:gNbId=2
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-13:gNbId=2
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3

@{PARAMS_FOR_NRREL_GNB2}
...    NRCELL-13/NRREL-11:gNbId=1
...    NRCELL-13/NRREL-11:lcrId=11
...    NRCELL-13/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-14:gNbId=2
...    NRCELL-13/NRREL-14:lcrId=14
...    NRCELL-13/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-12:gNbId=1
...    NRCELL-13/NRREL-12:lcrId=12
...    NRCELL-13/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-13:gNbId=2
...    NRCELL-14/NRREL-13:lcrId=13
...    NRCELL-14/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-12:gNbId=1
...    NRCELL-14/NRREL-12:lcrId=12
...    NRCELL-14/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-12:gnbPlmn:mncLength=3

@{PARAMS_FOR_NRHOIF_GNB1}
...    NRCELL-11/NRHOIF-12:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-12:deriveSsbIndexFromCell=true
...    NRCELL-11/NRHOIF-12:freqBandIndicatorNR=28
...    NRCELL-11/NRHOIF-12:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-11/NRHOIF-12:ssbFrequency=156030
...    NRCELL-11/NRHOIF-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-11/NRHOIF-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12/NRHOIF-11:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-11:cellDepType=SA
...    NRCELL-12/NRHOIF-11:chBw=10MHz
...    NRCELL-12/NRHOIF-11:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-11:freqBandIndicatorNR=3
...    NRCELL-12/NRHOIF-11:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-11:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-11:ssbFrequency=368430
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-14:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-14:cellDepType=SA
...    NRCELL-12/NRHOIF-14:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-14:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-14:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-14:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-14:ssbFrequency=126750
...    NRCELL-12/NRHOIF-14:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-14:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-14:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-13:cellDepType=SA
...    NRCELL-12/NRHOIF-13:chBw=10MHz
...    NRCELL-12/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-13:freqBandIndicatorNR=3
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-12/NRHOIF-13:ssbFrequency=368430
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0


@{PARAMS_FOR_NRHOIF_GNB2}
...    NRCELL-14/NRHOIF-12:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-12:deriveSsbIndexFromCell=true
...    NRCELL-14/NRHOIF-12:freqBandIndicatorNR=28
...    NRCELL-14/NRHOIF-12:ifhoSsbSmtcDuration=sf1
...    NRCELL-14/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-14/NRHOIF-12:ssbFrequency=156030
...    NRCELL-14/NRHOIF-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-14/NRHOIF-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-14/NRHOIF-13:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-13:cellDepType=SA
...    NRCELL-14/NRHOIF-13:chBw=10MHz
...    NRCELL-14/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-14/NRHOIF-13:freqBandIndicatorNR=3
...    NRCELL-14/NRHOIF-13:ifhoSsbSmtcDuration=sf1
...    NRCELL-14/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-14/NRHOIF-13:ssbFrequency=368430
...    NRCELL-14/NRHOIF-13:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-14/NRHOIF-13:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-14/NRHOIF-13:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-14:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-14:cellDepType=SA
...    NRCELL-13/NRHOIF-14:deriveSsbIndexFromCell=true
...    NRCELL-13/NRHOIF-14:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-14:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-14:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-13/NRHOIF-14:ssbFrequency=126750
...    NRCELL-13/NRHOIF-14:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-14:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-13/NRHOIF-14:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-13/NRHOIF-12:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-12:deriveSsbIndexFromCell=true
...    NRCELL-13/NRHOIF-12:freqBandIndicatorNR=28
...    NRCELL-13/NRHOIF-12:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-12:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-13/NRHOIF-12:ssbFrequency=156030
...    NRCELL-13/NRHOIF-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-13/NRHOIF-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-13/NRHOIF-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320

@{PARAMS_FOR_ransharing_GNB1}
...    NRBTS-1:actRanSharing=true
...    NRBTS-1:actNgcFlexSaMode=true
...    NRBTS-1/NRPLMN-2:mnc=402
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-2:ngUplane=${EMPTY}
...    NRBTS-1/TRACKINGAREA-0:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL:trackingAreaDN=${EMPTY}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-0
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2

@{PARAMS_FOR_ransharing_GNB2}
...    NRBTS-2:actRanSharing=true
...    NRBTS-2:actNgcFlexSaMode=true
...    NRBTS-2/NRPLMN-2:mnc=402
...    NRBTS-2/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS-2/SNSSAI-2:sd=13714342
...    NRBTS-2/SNSSAI-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2
...    NRBTS-2/SNSSAI-2:ngUplane=${EMPTY}
...    NRBTS-2/TRACKINGAREA-0:snssaiList:snssaiDN=MRBTS-2/NRBTS-2/SNSSAI-2
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL:trackingAreaDN=${EMPTY}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-2/NRBTS-2/TRACKINGAREA-0
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-2/NRBTS-2/NRPLMN-2

@{PARAMS_FOR_VONR_GNB1}
...    NRCELL:actVoNR=true

@{PARAMS_FOR_VONR_GNB2}
...    NRCELL:actVoNR=true

@{PARAMS_FOR_NBR_GNB1}
...    NRBTS-1:actNonGbrServiceDiff=true
...    NRCELL-12:actNbrForNonGbrBearers=true
...    NRCELL-12:congWeightAlg=priorityLevel
...    NRCELL-12:maxNbrTrafficLimit=30
...    NRCELL-12:maxPrbsPerNbrUe=30
...    NRCELL-12:maxNumOfNbrBearers=10
...    NRBTS-1/NRDRB-12:priorityLevel=17            #5qi-7
...    NRBTS-1/NRDRB-13:priorityLevel=18            #5qi-8
...    NRBTS-1/NRDRB-10:priorityLevel=5            #5qi-5
...    NRBTS-1/NRDRB-14:priorityLevel=19            #5qi-9
...    NRBTS-1/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS-1/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS-1/NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1            #5qi-6
...    NRBTS-1/NRDRB_MAC-2:nbrDl=500            #5qi-7
...    NRBTS-1/NRDRB_MAC-2:nbrUl=100
...    NRBTS-1/NRDRB_MAC-2:schedulBSD=1000ms
...    NRCELL-12:congDetectPeriod=ms100
...    NRCELL-12:nbrPdcchCongHandlingDl=false
...    NRCELL-12:nbrPdcchCongHandlingUl=false
...    NRCELL-12:nbrPdschCongHandling=true
...    NRCELL-12:nbrPuschCongHandling=true
...    NRBTS-1/NRDRB_MAC-5:nbrDl=${EMPTY}            #5qi-8
...    NRBTS-1/NRDRB_MAC-5:nbrUl=10
...    NRBTS-1/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS-1/NRDRB_MAC-5:lcgid=1
...    NRBTS-1/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS-1/NRDRB_MAC-5:schedulPrio=12
...    NRBTS-1/NRDRB_MAC-4:schedulBSD=50ms

@{PARAMS_FOR_NBR_GNB2}
...    NRBTS-2:actNonGbrServiceDiff=true
...    NRCELL-13:actNbrForNonGbrBearers=true
...    NRCELL-13:congWeightAlg=arpPrioPerVul
...    NRCELL-13:maxNbrTrafficLimit=90
...    NRCELL-13:maxPrbsPerNbrUe=10
...    NRCELL-13:congDetectPeriod=ms100
...    NRCELL-13:nbrPdcchCongHandlingDl=true
...    NRCELL-13:nbrPdcchCongHandlingUl=true
...    NRCELL-13:nbrPdschCongHandling=true
...    NRCELL-13:nbrPuschCongHandling=true
...    NRCELL-13:maxNumOfNbrBearers=10
...    NRCELL-14:maxNumOfNbrBearers=10
...    NRCELL-14:actNbrForNonGbrBearers=true
...    NRCELL-14:maxPrbsPerNbrUe=10
...    NRCELL-14:nbrPdcchCongHandlingDl=false
...    NRCELL-14:nbrPdcchCongHandlingUl=false
...    NRCELL-14:nbrPdschCongHandling=false
...    NRCELL-14:nbrPuschCongHandling=false
...    NRBTS-2/NRDRB-11:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-1            #5qi-6
...    NRBTS-2/NRDRB-14:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-1            #5qi-9
...    NRBTS-2/NRDRB-12:priorityLevel=100            #5qi-7
...    NRBTS-2/NRDRB-13:priorityLevel=80            #5qi-8
...    NRBTS-2/NRDRB_MAC-2:nbrDl=50
...    NRBTS-2/NRDRB_MAC-2:nbrUl=${EMPTY}
...    NRBTS-2/NRDRB_MAC-2:schedulBSD=50ms

#SA UE capability to support N3/N28/N71, compare with golden, add n71 support
${SA_Capa}    SEPARATOR=
...    E9A09000575F5A13560003C4A8002C00A0000040301262E003387A16009B20C39F30C7942C0E0980C0311C04EE3603606B04610D04083A41E006D6C98AB
...    1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE000C80000E0541B00B582308682041E20F0032B64C55890E7D813E238F18
...    91C790E7D473E618F28581C0E1E13FB000000FEC000000C80000E0551B11B582308682041E20F0030B64C55110E7C471E238F40CFB027C639F30C7942C0
...    E070F05FFF000007FFC00000640000702A0D837AC1184341020F10780195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC0
...    0000640000702A8D89BAC1184340000080780185B24CA88873E238F20C7A067D813E01CF9863CA1607038782F55555553D555555432000038024B0F1300
...    038980000002C0AC5C4C000E26000713000000858158B80400184C0309800020B02B1F008003036061300C260000C2C0AC5C02000C010181B0002058158
...    F8040018060303606134000A160562E01000706C00388C0000182C0AC3C02000C260001C2C0AC3C02000C01000202C0AC3C1B000C0D800242C0AC3C0200
...    0C03000282C0AC3C06000C0D8002C2C0AC5C02000C030181B00060581587836001C4C00001A160562E2600061300C01000382C0AC7C4C000C2601802030
...    36000F0B02B171300030040606C0020160563E2680060080C030181B00088581009006E00340468005013465001D212851226C73E1C4891226C73E1C489
...    1226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C389
...    12244D8E7C3851226C73E1C4891226C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D06C003C00281C14
...    01C0C02500700060240040603E09002000000010008000000200000C0100000200800002004000018020000100100000A008004010040100000C0080000
...    700400200000008000080040000480200000C010000140080000B004002048120080000C0339535953582958195833582B594B7933780B581B580958115
...    83B40D040000259494100001965260400006594901000039652404000125949010000596526040001A59490100007965240400022594901000099652404
...    0002A5949010000B96525040003259490100003165240334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D5541E286802F012A05028
...    140A05028140A05028140A05028140A05028008840400801010020044020040080801002020040088040300501002004040080118080600A02018028080
...    1002020040088040400501010014040580B18080600C02018028080600C02004008804030050100C014040300508080600A02004008404030050100C014
...    202018030080600C10100C018040300508080600A02018028804030050100C018040300508080600C020040088040080101002004040300518080100202
...    004008080600A02018028804008010100C018040300618080100202018028080600C02018028D50F8000810182030385058606880889098A0C0C8D8E0E8
...    F909293139414951697A0A0C168


@{PM_Counters_GNB1}
...    NRCELL-11:${SA_DU_DRB_NBR_DL}=0
...    NRCELL-11:${SA_DU_DRB_NBR_UL}=0
...    NRCELL-12:${SA_DU_DRB_NBR_DL}>0
...    NRCELL-12:${SA_DU_DRB_NBR_UL}>0
...    NRCELL-11:${SA_DU_DRB_NBR_REQ}=0
...    NRCELL-11:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=0
...    NRCELL-12:${SA_DU_DRB_NBR_REQ}=8
...    NRCELL-12:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=8
...    NRCELL-11:${SA_DRB_NBR_DENOM}>0
...    NRCELL-12:${SA_DRB_NBR_DENOM}>0

@{PM_Counters_GNB2}
...    NRCELL-13:${SA_DU_DRB_NBR_DL}>0
...    NRCELL-13:${SA_DU_DRB_NBR_UL}=0
...    NRCELL-14:${SA_DU_DRB_NBR_DL}>0
...    NRCELL-14:${SA_DU_DRB_NBR_UL}=0
...    NRCELL-13:${SA_DU_DRB_NBR_REQ}=9
...    NRCELL-13:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=9
...    NRCELL-14:${SA_DU_DRB_NBR_REQ}=7
...    NRCELL-14:${SA_DU_DRB_NBR_ADMIT_WITH_NBR}=7
...    NRCELL-13:${SA_DRB_NBR_DENOM}>0
...    NRCELL-14:${SA_DRB_NBR_DENOM}>0

${SA_DU_DRB_NBR_DL}    M55139C03509    #This counter provides the number of non-GBR bearers with configured
#nominal bit rate (NBR) successfully admitted with applying NBR during the radio admission control for SA users.
${SA_DU_DRB_NBR_UL}    M55139C03510    #This counter provides the accumulated number of NBR-configured non-GBR bearers in UL for SA users.
${SA_DU_DRB_NBR_REQ}    M55139C03506    #This counter provides the number of non-GBR bearers with configured nominal bit rate (NBR)
#admission requests for SA users.
${SA_DU_DRB_NBR_ADMIT_WITH_NBR}    M55139C03507    #This counter provides the number of non-GBR bearers with configured
#nominal bit rate (NBR) successfully admitted with applying NBR during the radio admission control for SA users.
${SA_DRB_NBR_DENOM}    M55139C03511    #This counter indicates the number of samples taken to NBR-configured bearer counters for SA.

*** Test Cases ***
CB008227-ET-C007_C009_C011_kindsHO_with_NBR_SA
    [Documentation]
    ...    1. The purpose of this test case is to check gNB behaviour needed to configure DRX for
    ...       UE capable to setup UL Grant Type 2 for activated cell.
    ...    2. Configuration
    ...        a.SA+NSA,FDD
    ...        b1.gnb1 cell-11, actNbrForNonGbrBearers=false, band N3
    ...        b2.gnb1 cell-12, actNbrForNonGbrBearers=true, congWeightAlg=priorityLevel, band N28
    ...        b3.gnb2 cell-13, actNbrForNonGbrBearers=true, congWeightAlg=arpPrioPerVul, band N3
    ...        b4.gnb2 cell-14, actNbrForNonGbrBearers=true, congWeightAlg=omit, band N71
    ...        c1.5qi-6:
    ...            c1.1. NBR disabled both on gnb1 and gnb2
    ...        c2.5qi-7:
    ...            c2.1.gnb1: UL(500)+DL(100) NBR enabled, priorityLevel=17, schedulBSD=1000ms
    ...            c2.2.gnb2: DL(50) NBR enabled, priorityLevel=100, schedulBSD=50ms
    ...        c3.5qi-8:
    ...            c3.1.gnb1: UL(10) NBR enabled, priorityLevel=18, schedulBSD=5ms
    ...            c3.2.gnb2: DL(50) NBR enabled, priorityLevel=100, schedulBSD=50ms
    ...        c4.5qi-9:
    ...            c4.1.gnb1: UL(10) NBR enabled, priorityLevel=19, schedulBSD=5ms
    ...            c4.2.gnb2: NBR disabled
    ...        c5.5qi-5:
    ...            c5.1. NBR disabled both on gnb1 and gnb2
    ...        c6.5qi-1:
    ...            c6.1. NBR disabled both on gnb1 and gnb2
    ...    3. Test Case Steps:
    ...        3.1.UE attach to NRCELL-11 and set up PDU1 DRB1 5QI_6/DRB2 5QI_7/PDU2 DRB1 5QI_7 without NBR configured.
    ...        3.2.start UL/DL traffic in each DRB and verify.
    ...        3.3.trigger Xn HO to cell-13, then intra-cell HO on cell-13, 
    ...          then add PDU2 DRB2 5QI_6 without NBR, PDU3 DRB1 5QI_7 with NBR configured,
    ...        3.4.trigger Xn HO back to cell-11 then back to cell-13, del PDU1, verify traffic.
    ...        3.5.trigger intra-DU HO to cell-14, then add PDU3 DRB2 5QI_6 without NBR, PDU4 DRB1 5QI_7 with NBR configured,
    ...          del PDU2, start and verify traffic.
    ...        3.6.trigger intra-DU HO back to cell-13 then back to cell-14, verify traffic.
    ...        3.7.trigger Xn HO to cell-12, then intra-cell HO on cell-12,
    ...          add PDU4 DRB2 5QI_6 without NBR, PDU4 DRB3 5QI_8 with NBR configured simultanously,
    ...          add PDU5 DRB1 5QI_5(nonGBR_Signalling) without NBR configured, PDU5 DRB2 5QI_1 without NBR, seperately
    ...          del PDU3, start and verify traffic.
    ...        3.8.trigger Xn HO back to cell-14 then back to cell-12 both with intra-cell HO, verify traffic.
    ...        3.9.trigger intra-DU HO to cell-11, del PDU5, start and verify traffic.
    ...        3.10.trigger intra-DU HO back to cell-12, verify traffic.
    ...        3.11.add PDU4 DRB4 5QI_9 with NBR, del PDU4 DRB2/3 simultanously.
    ...        3.12.trigger Xn HO to cell-13, start and verify traffic.
    ...        3.13.deregister UE.
    ...    4. Expected Results:
    ...        4.1.UE attach successfully, all 3 DRBs is without NBR on gnb1 cell11.
    ...        4.2.all UL/DL traffic no loss.
    ...        4.3.both Xn HO and intra-cell HO succeed, 2 NBR DRBs setup, 1 non-NBR DRB setup after HO on gnb2 cell13,
    ...            PDU2 DRB2 5QI_6 setup without NBR, PDU3 DRB1 5QI_7 setup with NBR, no traffic loss.
    ...        4.4.1st Xn HO succeed, 5 non-NBR DRBs setup on gnb1 cell11,
    ...            2nd Xn HO succeed, 3 NBR DRBs, 2 non-NBR DRBs setup on gnb2 cell13,
    ...            PDU1 delete successfully.
    ...            remaining 2 NBR DRBs, 1 non-NBR DRB on gnb2 cell13, no traffic loss.
    ...        4.5.intra-DU HO succeed, 2 NBR DRBs, 1 non-NBR DRB setup correctly after HO on gnb2 cell14,
    ...            PDU3 DRB2 5QI_6 setup without NBR, PDU4 DRB1 5QI_7 setup with NBR, PDU2 delete successfully.
    ...            remaining 2 NBR DRBs, 1 non-NBR DRB on gnb2 cell14, no traffic loss.
    ...        4.6.1st intra-DU HO succeed, 2 NBR DRBs setup on gnb2 cell13, no traffic loss.
    ...            2nd intra-DU HO succeed, 2 NBR DRBs setup on gnb2 cell14, no traffic loss.
    ...        4.7.both Xn HO and intra-cell HO succeed, 2 NBR DRBs, 1 non-NBR DRB setup correctly after HO on gnb1 cell12,
    ...            NBR DRB setup correctly during PDU modify/addition/release, no traffic loss.
    ...            remaining 2 NBR DRBs, 2 non-NBR DRBs, 1 GBR DRBs on gnb1 cell12, no traffic loss.
    ...        4.8.1st Xn HO and intra-cell HO succeed, 2 NBR DRBs, 2 non-NBR DRBs, 1 GBR DRBs setup correctly after HO on gnb2 cell14.
    ...            2nd Xn HO and intra-cell HO succeed, 2 NBR DRBs, 2 non-NBR DRBs, 1 GBR DRBs setup correctly after HO on gnb1 cell12.
    ...        4.9.intra-DU HO succeed, 4 non-NBR DRBs, 1 GBR DRBs setup correctly after HO on gnb1 cell11,
    ...            PDU5 release succeed.
    ...            remaining 3 non-NBR DRBs on gnb1 cell11.
    ...        4.10.intra-DU HO succeed, 2 NBR DRBs, 1 non-NBR DRB setup correctly after HO on gnb1 cell12, no traffic loss.
    ...        4.11.PDU4 DRB4 5QI_9 setup with NBR, PDU4 DRB2/3 delete successfully.
    ...             remaining 2 NBR DRBs on gnb1 cell12.
    ...        4.12.Xn HO succeed, 1 NBR DRB, 1 non-NBR DRB setup correctly after HO on gnb2 cell13, no traffic loss.
    ...        4.13.deregister succeed.
    [Tags]    QC_323230    C007
    Clear Counter Files for 2GNB
    UE Trigger Normal Call With 2 PDU
    UE Send Throughput On 2 PDU
    HO between cell-11 and cell-13
    HO between cell-13 and cell-14
    HO between cell-14 and cell-12
    HO between cell-12 and cell-11
    HO between cell-13 and cell-12
    UE Deregister From gNB
    Check WireShark Log    ${CURDIR}${/}A2A_C007${/}a2a.ini    wait_string=UEContextRelease::30
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_C007${/}a2a_gnb2.ini    wait_string=UEContextRelease::36
    Compare counter
    Check Counters    pm_counters_expression=${PM_Counters_GNB1}
    Check Counters GNB2    pm_counters_expression=${PM_Counters_GNB2}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fdd_sansa_cmwv/FS/4cells_gnb1_2F_gnb2_2F    ue_count=2

Modify Cfg
    Update Cfg Param    set_gnb id=2 xn=10.0.1.2
    Update Cfg Param    set_gnb id=3 xn=10.0.1.3
    Update Cfg Param    amf_param id=1 ims_voice_3gpp=on
    Update Cfg Param    ue_param id=1 ue_nr_capabilities=${SA_Capa} nr_usage_setting=voice_centric
    Update Cfg    set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489,311:402
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosflow id=5 5qi=8
    Update Cfg    set_qosflow id=6 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=tcp qos_flow=4
    Update Cfg    set_qosrule id=4 proto=tcp qos_flow=5
    Update Cfg    set_qosrule id=5 proto=tcp qos_flow=6
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 amf_region_id=1 plmn_list=311:489
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 ue=all qos_flows=1,2,3,4 qos_rules=1,2,3 amf_region_id=1 plmn_list=311:402
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1

Config MRL
    Execute Egate Command    amf_mobility_restriction_list_param id=1 equiv_plmn=311:402 sa_plmn=311:489 allowed_tacs=0,200
    Execute Egate Command    amf_mobility_restriction_list_param id=1
    Execute Egate Command    amf_ue_ics_param id=1 ue=1 mobility_restriction_list_id=1

UE Trigger Normal Call With 2 PDU
    Execute Egate Command    ue_change_location id=1 enb=2 cell=11
    Config MRL
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    PDU1 setup with 2DRBs
    Execute Egate Command    qosflow_modify qos_flow=4 default=on priority=7
    Execute Egate Command    set_pdu_param ue=1 pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 gw=1 nwslice=2    pass_regexp=Setup QosFlow with QFI:1 5QI:7
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr

PDU1 setup with 2DRBs
    Execute Egate Command    qosflow_modify qos_flow=1 default=on priority=15
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=Setup QosFlow with QFI:1 5QI:6
    Execute Egate Command    qosflow_modify qos_flow=4 priority=9
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_add=4 by=amf    pass_regexp=Added QosFlow with QFI:2 5QI:7

UE Send Throughput On 2 PDU
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=2 qfi=1 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Execute Egate Command    trf_data_start ue=1 pdu=2 qfi=1 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    sleep    10s    #sleep for stable traffic
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=1    pdu2=2

Verify Traffic 2PDU
    [Arguments]    ${Tput_ul}=5    ${sleep_time}=15s    ${pdu1}=1    ${pdu2}=2
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch    pass_regexp=NR PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    pass_regexp=NR PDSCH Throughput
    sleep    ${sleep_time}    sleep for Tput stable
    UL data for 2PDU    Tput_ul=${Tput_ul}    pdu1=${pdu1}    pdu2=${pdu2}
    DL data for 2PDU    Tput_ul=${Tput_ul}    pdu1=${pdu1}    pdu2=${pdu2}

UL data for 2PDU
    [Arguments]    ${Tput_ul}=5    ${pdu1}=1    ${pdu2}=2
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=1    direction=ul    rate_type=ave
    ${ul_2}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=2    direction=ul    rate_type=ave
    ${ul_3}    Ap Get SA Throughput    ue_id=1    pdu=${pdu2}    qfi=1    direction=ul    rate_type=ave
    Should Be True    (${ul_1}+${ul_2}+${ul_3})>${Tput_ul}/1000*0.9

DL data for 2PDU
    [Arguments]    ${Tput_ul}=5    ${pdu1}=1    ${pdu2}=2
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=1    direction=dl    rate_type=ave
    ${dl_2}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=2    direction=dl    rate_type=ave
    ${dl_3}    Ap Get SA Throughput    ue_id=1    pdu=${pdu2}    qfi=1    direction=dl    rate_type=ave
    Should Be True    (${dl_1}+${dl_2}+${dl_3})>${Tput_ul}/1000*0.9

Traffic send and verify 3PDU
    [Arguments]    ${Tput_ul}=5    ${sleep_time}=5s    ${pdu1}=2    ${pdu2}=3    ${pdu3}=1
    Execute Egate Command    trf_data_start ue=1 pdu=${pdu1} qfi=2 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=${pdu2} qfi=1 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=${pdu1} qfi=2 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Execute Egate Command    trf_data_start ue=1 pdu=${pdu2} qfi=1 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    sleep    10s    #sleep for stable traffic
    Verify Traffic 3PDU    Tput_ul=${Tput_ul}    sleep_time=${sleep_time}    pdu1=${pdu1}    pdu2=${pdu2}    pdu3=${pdu3}

Verify Traffic 3PDU
    [Arguments]    ${Tput_ul}=5    ${sleep_time}=15s    ${pdu1}=2    ${pdu2}=3    ${pdu3}=1
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch    pass_regexp=NR PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    pass_regexp=NR PDSCH Throughput
    sleep    ${sleep_time}    sleep for Tput stable
    UL data for 3PDU    Tput_ul=${Tput_ul}    pdu1=${pdu1}    pdu2=${pdu2}    pdu3=${pdu3}
    DL data for 3PDU    Tput_ul=${Tput_ul}    pdu1=${pdu1}    pdu2=${pdu2}    pdu3=${pdu3}

UL data for 3PDU
    [Arguments]    ${Tput_ul}=5    ${pdu1}=2    ${pdu2}=3    ${pdu3}=1
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=${pdu3}    qfi=1    direction=ul    rate_type=ave
    ${ul_2}    Ap Get SA Throughput    ue_id=1    pdu=${pdu3}    qfi=2    direction=ul    rate_type=ave
    ${ul_3}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=1    direction=ul    rate_type=ave
    ${ul_4}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=2    direction=ul    rate_type=ave
    ${ul_5}    Ap Get SA Throughput    ue_id=1    pdu=${pdu2}    qfi=1    direction=ul    rate_type=ave
    Should Be True    (${ul_1}+${ul_2}+${ul_3}+${ul_4}+${ul_5})>${Tput_ul}/1000*0.9

DL data for 3PDU
    [Arguments]    ${Tput_ul}=5    ${pdu1}=2    ${pdu2}=3    ${pdu3}=1
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=${pdu3}    qfi=1    direction=dl    rate_type=ave
    ${dl_2}    Ap Get SA Throughput    ue_id=1    pdu=${pdu3}    qfi=2    direction=dl    rate_type=ave
    ${dl_3}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=1    direction=dl    rate_type=ave
    ${dl_4}    Ap Get SA Throughput    ue_id=1    pdu=${pdu1}    qfi=2    direction=dl    rate_type=ave
    ${dl_5}    Ap Get SA Throughput    ue_id=1    pdu=${pdu2}    qfi=1    direction=dl    rate_type=ave
    Should Be True    (${dl_1}+${dl_2}+${dl_3}+${dl_4}+${dl_5})>${Tput_ul}/1000*0.9

Add DRB
    [Arguments]    ${pdu1}=4    ${pdu2}=1    ${qosflow}=6    ${slice}=1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=${pdu1} qosflows_to_add=${qosflow} by=amf    pass_regexp=QoS Routing Table
    Execute Egate Command    set_pdu_param ue=1 pdu=${pdu2} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=${pdu2} gw=1 nwslice=${slice}    pass_regexp=setup/reestablishment complete

Add multi DRB
    [Arguments]    ${pdu2}=1
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=4 qosflows_to_add=1,5 by=amf    pass_regexp=Received Uplink NAS Transport Message
    Execute Egate Command    qosflow_modify qos_flow=2 default=on priority=15
    Execute Egate Command    set_pdu_param ue=1 pdu=${pdu2} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=${pdu2} gw=1 nwslice=1    pass_regexp=setup/reestablishment complete
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=${pdu2} qosflows_to_add=3 by=amf    pass_regexp=Pdu Session Resource Modify Response
    Execute Egate Command    smf_param id=1 reset
    Traffic send and verify for multi DRB

Traffic send and verify for multi DRB
    [Arguments]    ${Tput_ul}=5    ${sleep_time}=5s
    Execute Egate Command    trf_data_start ue=1 pdu=4 qfi=2 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=4 qfi=3 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=4 qfi=2 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Execute Egate Command    trf_data_start ue=1 pdu=4 qfi=3 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=3    pdu2=4
    Verify Traffic multi DRB

Verify Traffic multi DRB
    [Arguments]    ${Tput_ul}=4    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch    pass_regexp=NR PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    pass_regexp=NR PDSCH Throughput
    sleep    ${sleep_time}    sleep for Tput stable
    UL data for multi DRB    Tput_ul=${Tput_ul}
    DL data for multi DRB    Tput_ul=${Tput_ul}

UL data for multi DRB
    [Arguments]    ${Tput_ul}=4
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=2    direction=ul    rate_type=ave
    ${ul_2}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=3    direction=ul    rate_type=ave
    ${ul_3}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${ul_4}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=2    direction=ul    rate_type=ave
    Should Be True    (${ul_1}+${ul_2}+${ul_3}+${ul_4})>${Tput_ul}/1000*0.9

DL data for multi DRB
    [Arguments]    ${Tput_ul}=4
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=2    direction=dl    rate_type=ave
    ${dl_2}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=3    direction=dl    rate_type=ave
    ${dl_3}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${dl_4}    Ap Get SA Throughput    ue_id=1    pdu=1    qfi=2    direction=dl    rate_type=ave
    Should Be True    (${dl_1}+${dl_2}+${dl_3}+${dl_4})>${Tput_ul}/1000*0.9

Verify Traffic with GBR
    Verify Traffic multi DRB
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=1    direction=ul    rate_type=ave
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=1    direction=dl    rate_type=ave
    Should Be True    ${ul_1}>1/1000*0.9
    Should Be True    ${dl_1}>1/1000*0.9

Verify Traffic for PDU4
    [Arguments]    ${Tput_ul}=3    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch    pass_regexp=NR PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    pass_regexp=NR PDSCH Throughput
    UL data for PDU4    Tput_ul=${Tput_ul}
    DL data for PDU4    Tput_ul=${Tput_ul}

UL data for PDU4
    [Arguments]    ${Tput_ul}=3
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=2    direction=ul    rate_type=ave
    ${ul_2}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=3    direction=ul    rate_type=ave
    ${ul_3}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=1    direction=ul    rate_type=ave
    Should Be True    (${ul_1}+${ul_2}+${ul_3})>${Tput_ul}/1000*0.9

DL data for PDU4
    [Arguments]    ${Tput_ul}=3
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=2    direction=dl    rate_type=ave
    ${dl_2}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=3    direction=dl    rate_type=ave
    ${dl_3}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=1    direction=dl    rate_type=ave
    Should Be True    (${dl_1}+${dl_2}+${dl_3})>${Tput_ul}/1000*0.9

Verify Traffic for PDU4_4DRB
    Verify Traffic for PDU4
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=4    direction=ul    rate_type=ave
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=4    direction=dl    rate_type=ave
    Should Be True    ${ul_1}>1/1000*0.9
    Should Be True    ${dl_1}>1/1000*0.9

Verify Traffic for PDU4_2DRB
    [Arguments]    ${Tput_ul}=2    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch    pass_regexp=NR PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pdsch    pass_regexp=NR PDSCH Throughput
    ${ul_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=1    direction=ul    rate_type=ave
    ${ul_2}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=4    direction=ul    rate_type=ave
    Should Be True    (${ul_1}+${ul_2})>${Tput_ul}/1000*0.9
    ${dl_1}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=1    direction=dl    rate_type=ave
    ${dl_2}    Ap Get SA Throughput    ue_id=1    pdu=4    qfi=4    direction=dl    rate_type=ave
    Should Be True    (${dl_1}+${dl_2})>${Tput_ul}/1000*0.9

Release DRB
    [Arguments]    ${pdu1}=2
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=${pdu1} qosflows_to_del=1,5 by=amf    pass_regexp=Pdu Session Resource Modify Response

Release PDU
    [Arguments]    ${pdu1}=2
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=${pdu1} by=ue    pass_regexp=Successfully released

UE Deregister From gNB
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=UE1: detached    timeout=10s

Clear Counter Files for 2GNB
    Clear Counter Files    wait=${False}
    Clear Counter Files GNB2

HO between cell-11 and cell-13
    Intra freq HO A3 with intracell HO    carrierfreq=368430    phycell_id=62    sec_cap=aes|aes
    Verify Traffic 2PDU
    Add DRB    pdu1=2    pdu2=3    qosflow=1    slice=2
    Traffic send and verify 3PDU
    Intra freq HO A3    carrierfreq=368430    phycell_id=60
    Verify Traffic 3PDU
    Intra freq HO A3    carrierfreq=368430    phycell_id=62
    Verify Traffic 3PDU
    PDU Modify due to ARP change    priority=14
    Release PDU    pdu1=1
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=2    pdu2=3

HO between cell-13 and cell-14
    Inter freq HO    carrierfreq_A2=368430    carrierfreq_A3=126750    phycell_id=63
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=2    pdu2=3
    Add DRB    pdu1=3    pdu2=4    qosflow=1    slice=1
    Traffic send and verify 3PDU    pdu1=3    pdu2=4    pdu3=2
    Release PDU    pdu1=2
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=3    pdu2=4
    Inter freq HO    carrierfreq_A2=126750    carrierfreq_A3=368430    phycell_id=62
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=3    pdu2=4
    Inter freq HO    carrierfreq_A2=368430    carrierfreq_A3=126750    phycell_id=63
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=3    pdu2=4

HO between cell-14 and cell-12
    Inter freq HO with intraCell HO    carrierfreq_A2=126750    carrierfreq_A3=156030    phycell_id=61    sec_cap=snow3g|snow3g
    Verify Traffic 2PDU    Tput_ul=3    sleep_time=5s    pdu1=3    pdu2=4
    Add multi DRB    pdu2=1    #pdu3=2
    Release PDU    pdu1=3
    Inter freq HO with intraCell HO    carrierfreq_A2=156030    carrierfreq_A3=126750    phycell_id=63    sec_cap=zuc|zuc
    Verify Traffic with GBR
    Inter freq HO with intraCell HO    carrierfreq_A2=126750    carrierfreq_A3=156030    phycell_id=61    sec_cap=aes|aes
    Verify Traffic with GBR

HO between cell-12 and cell-11
    Inter freq HO    carrierfreq_A2=156030    carrierfreq_A3=368430    phycell_id=60
    Verify Traffic with GBR
    Release PDU    pdu1=1
    Verify Traffic for PDU4
    Inter freq HO    carrierfreq_A2=368430    carrierfreq_A3=156030    phycell_id=61
    Verify Traffic for PDU4

HO between cell-13 and cell-12
    Add PDU4 5QI9
    Verify Traffic for PDU4_4DRB
    Release DRB    pdu1=4
    Verify Traffic for PDU4_2DRB
    Inter freq HO with intraCell HO    carrierfreq_A2=156030    carrierfreq_A3=368430    phycell_id=62    sec_cap=snow3g|snow3g
    Verify Traffic for PDU4_2DRB

Add PDU4 5QI9
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=4 qosflows_to_add=6 by=amf    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=1 pdu=4 qfi=4 dir=ul mbps=1 trf_id=1    pass_regexp=UE 1: UDP UL
    Execute Egate Command    trf_data_start ue=1 pdu=4 qfi=4 dir=dl mbps=1 trf_id=1    pass_regexp=UE 1: UDP DL

Inter freq HO
    [Arguments]    ${carrierfreq_A2}=368430    ${carrierfreq_A3}=156030    ${phycell_id}=62
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq_A2}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11    
    ...    pass_regexp=rrcReconfigurationComplete
    Intra freq HO A3    carrierfreq=${carrierfreq_A3}    phycell_id=${phycell_id}

Inter freq HO with intraCell HO
    [Arguments]    ${carrierfreq_A2}=368430    ${carrierfreq_A3}=156030    ${phycell_id}=62    ${sec_cap}=aes|aes
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq_A2}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11    
    ...    pass_regexp=rrcReconfigurationComplete
    Intra freq HO A3 with intracell HO    carrierfreq=${carrierfreq_A3}    phycell_id=${phycell_id}    sec_cap=${sec_cap}

Intra freq HO A3 with intracell HO
    [Arguments]    ${carrierfreq}=368430    ${phycell_id}=62    ${sec_cap}=aes|aes
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    IntraCell HO    sec_cap=${sec_cap}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A3
    ${intra_freq_inter_gnb_A3}    catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${intra_freq_inter_gnb_A3}    pass_regexp=Intra-cell handover
    sleep    10s    #check HO done,UE is stable
    Execute Egate Command    ue_disp

IntraCell HO
    [Arguments]    ${sec_cap}=aes|aes
    Execute Egate Command    ue_reauth id=1 nr_sec_cap=${sec_cap}    pass_regexp=Reauthentication
    Execute Egate Command    amf_path_switch_param id=1 include_ue_sec_cap=on
    Execute Egate Command    smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=6mbps

Intra freq HO A3
    [Arguments]    ${carrierfreq}=368430    ${phycell_id}=62
    Execute Egate Command    ue_meas_cfg_disp id=1 meas_obj_type=nr
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=${carrierfreq}    event_type=A3
    ${intra_freq_inter_gnb_A3}    catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${intra_freq_inter_gnb_A3}    pass_regexp=handover
    sleep    10s    #check HO done,UE is stable
    Execute Egate Command    ue_disp

Compare counter
    ${DL_NBR_CELL12}    Get Counters Value    NRCELL-12:${SA_DU_DRB_NBR_DL}
    ${UL_NBR_CELL12}    Get Counters Value    NRCELL-12:${SA_DU_DRB_NBR_UL}
    Should Be True    ${UL_NBR_CELL12}>${DL_NBR_CELL12}
    ${DL_NBR_CELL13}    Get Counters Value Gnb2    NRCELL-13:${SA_DU_DRB_NBR_DL}
    ${UL_NBR_CELL13}    Get Counters Value Gnb2    NRCELL-13:${SA_DU_DRB_NBR_UL}
    Should Be True    ${DL_NBR_CELL13}>${UL_NBR_CELL13}
    ${DL_NBR_CELL14}    Get Counters Value Gnb2    NRCELL-14:${SA_DU_DRB_NBR_DL}
    ${UL_NBR_CELL14}    Get Counters Value Gnb2    NRCELL-14:${SA_DU_DRB_NBR_UL}
    Should Be True    ${DL_NBR_CELL14}>${UL_NBR_CELL14}

PDU Modify due to ARP change
    [Arguments]    ${priority}=14 
    Execute Egate Command    qosflow_modify qos_flow=4 priority=${priority}
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=1 qosflows_to_modify=4 by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response

