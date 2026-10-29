*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_LO_AP_LO    team-VRF3_SG8    owner-yinhu.yang
...    release-SBTS25R1    CRT
Resource          ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000786}
...    @{CB006112-A}
...    @{5GC000704}
...    @{CB006112-C}
...    @{5GC000707_InterRAT}
...    @{5GC000784}
...    @{CB008700}
...    @{CB008379}
...    @{5GC000772}
...    @{5GC000749}
...    @{5GC000710}
...    @{ngho}
...    @{5GC001468}
...    @{5GC000711}
...    @{CB008698}
...    @{CB008232}
...    @{PMQAP}
...    @{params_to_enable_nsa_ho}
...    @{enable_meas_intrafreq}
...    @{enable_meas_interfreq}
...    @{nrrel_intra_freq_intra_gnb}
...    @{nrrel_inter_freq_intra_gnb}
...    @{cbra_non_srb3}
...    @{3cell_freq}
...    @{CB008195}
...    @{fix_relation_error}
...    @{PLMN}
...    @{CB008225}
...    @{RANsharing}

@{CB008225}
...    NRBTS:actRrcInactState=intra-gNB
...    NRBTS:act3gppBL23R1=true
...    NRCELL:ranAC=0
...    NRBTS:drbRrcInactInactivityTimerSA=200
...    NRBTS:maxUeRrcInactTime=60
...    NRBTS:drbInactivityTimerSA=600
...    NRBTS:rrcInactIMMSteeringEnabled=false
...    NRBTS:rrcInactLocationReportEnabled=false
...    NRBTS:rrcInactPreferredStateEnabled=true
...    NRBTS:actRrcReleasePreference=true
...    NRBTS:outOfConnectedPreference=inactive
...    NRBTS:timerReleasePreferenceProhibit=s3
...    NRBTS:tRanPagingGuard=4
...    NRBTS:t380=60min
...    NRBTS:actPaging=true
...    NRBTS:ranPagingCycle=v32
...    NRBTS:activityNotificationLevelSA=ue

@{RANsharing}
...    NRBTS:actNgcFlexSaMode=true
...    NRBTS:actRanSharing=true
...    NRBTS:actRanSharingEnh=disabled
...    NRBTS:actTrsSepaSARanSharing=true
...    NRBTS:ngCplane:ngTnlId=1
...    NRBTS:ngUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS:xnCplane:xnTnlId=1
...    NRBTS:xnUplane:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL:configuredEpsTac=${EMPTY}
...    NRCELL:ranAC=${EMPTY}
...    NRCELL:trackingAreaDN=${EMPTY}
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=222
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL/NRPLMNSET_SA-1:ranAC=0
...    NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_SA-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRCELL/NRPLMNSET_SA-2:ranAC=0
...    NRCELL/NRPLMNSET_SA-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-300
...    NRBTS/NRPLMN-2:mnc=500
...    NRBTS/SERVEDAMF-1:ngTnlId=1
...    NRBTS/XNLINK-1:xnTnlId=1
...    NRBTS/XNLINK-10:xnTnlId=1
...    @{SNSSAI}
...    @{TRACKINGAREA}

@{PLMN}
...    MRBTS-1/NRBTS-1/NRPLMN-1:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-1:mnc=489
...    MRBTS-1/NRBTS-1/NRPLMN-1:mncLength=3
...    MRBTS-1/NRBTS-1/NRPLMN-2:mcc=311
...    MRBTS-1/NRBTS-1/NRPLMN-2:mnc=500
...    MRBTS-1/NRBTS-1/NRPLMN-2:mncLength=3

@{SNSSAI}
...    NRBTS-1/SNSSAI-1:sst=1
...    NRBTS-1/SNSSAI-1:sd=13714341
...    NRBTS-1/SNSSAI-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-2:sst=1
...    NRBTS-1/SNSSAI-2:sd=13714342
...    NRBTS-1/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/SNSSAI-3:sst=1
...    NRBTS-1/SNSSAI-3:sd=13714343
...    NRBTS-1/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1,MRBTS-1/NRBTS-1/NRPLMN-2

@{TRACKINGAREA}
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-1|snssaiDN=SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-2|snssaiDN=SNSSAI-2
...    TRACKINGAREA-200:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3
...    TRACKINGAREA-300:snssaiList:snssaiDN=SNSSAI-3|snssaiDN=SNSSAI-3

@{5GC000786}
...    NRCELL:actVoNR=true
...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-2:fiveqiValueList=5
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-5:fiveqiValueList=5
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-6:fiveqiValueList=5
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-7:fiveqiValueList=3
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB_5QI-8:fiveqiValueList=4
...    NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB_5QI-9:fiveqiValueList=128
...    NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB_5QI-10:fiveqiValueList=2
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-4
...    NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-2:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-2:resType=nonGBR_Signaling
...    NRDRB-2:rlcMode=RLC_AM
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_UM
...    NRDRB-3:maxDataRateGbrDl=1000
...    NRDRB-3:maxDataRateGbrUl=1000
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:dscp=46
...    NRDRB-4:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-4:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-4:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-4:resType=GBR
...    NRDRB-4:rlcMode=RLC_UM
...    NRDRB-4:maxDataRateGbrDl=1000
...    NRDRB-4:maxDataRateGbrUl=1000
...    NRDRB-4:l2OHFactorDl=16
...    NRDRB-4:l2OHFactorUl=35
...    NRDRB-4:dscp=46
...    NRDRB-4:discardTimer=150ms
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-3:delayTarget=50
...    NRDRB_MAC-4:lcgid=5
...    NRDRB_MAC-4:delayTarget=50
...    NRDRB-2:discardTimer=infinity
...    NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB_MAC-5:lcgid=0

@{CB006112-A}
...    NRCELL:actEnhancedVoNR=true
...    NRBTS:tRLFindForDUVoNR=2000ms
...    NRCELL:n310VoNR=n20
...    NRCELL:t310VoNR=4000ms
...    NRDRB-3:discardTimer=150ms
...    NRDRB-3:dlFlowControlAlgo=none
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN

@{CB006112-C}
...    NRCELL:actGBRAdmissionControl=EnhancedVoNR
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxGBRTrafficLimit=50
...    NRCELL:addNumOfGBRBearers=0
...    NRCELL:actVoNrMobilityThresholds=VoNrMobilityThresholds
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:chBw=20MHz
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=126530
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31|a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34|a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRCELL:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31|a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=39
...    NRCELL:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=36|a1TimeToTriggerhoSsbRsrq=ms480

@{5GC000704}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=80
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:absThreshSsbRsrpConsolidation=80
...    NRCELL-2:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    XNLINK-1:cPlaneIpAddr=10.0.1.124
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    XNLINK-10:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:gNodeBId=35
...    NRADJGNB-10:xnLinkRef=10
...    NRADJGNB-10:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-10:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=636666
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-1:freqBandIndicatorNR
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=35
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3

@{5GC000707_InterRAT}
...    NRBTS:actInterRatHoSA=true
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRHOIR-1:allowedMeasBandwidth=mbw50
...    NRHOIR-1:b2MeashoEnabled=rsrpAndRsrq
...    NRHOIR-1:b2Threshold1hoRsrp=35
...    NRHOIR-1:b2Threshold1hoRsrpVoNr=45
...    NRHOIR-1:b2Threshold1hoRsrq=50
...    NRHOIR-1:b2Threshold1hoRsrqVoNr=55
...    NRHOIR-1:earfcnValue=39750    # earfcnValue=39750 band 41
...    NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...    NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRADJECELL-1:eNodeBId=25
...    NRADJECELL-1:ePSTrackingAreaCode=222
...    NRADJECELL-1:earfcnValue=39750    # earfcnValue=39750 band 41
...    NRADJECELL-1:lcrId=1
...    NRADJECELL-1:physCellId=12    # pci=4:0 phycell_id=12
...    NRADJECELL-1:eUtraMultibandInfoList=41    # earfcnValue=39750 band 41
...    NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3
...    NRADJECELL-1:enbPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:enbPlmn:mnc=489|mncLength=3

...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=25    #74566 enb_id_macro=0x12346
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3

${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC001031BEF80DC0407E1805577C287F8BC21D8BE0821FD557771DF001DDC77C00028
...    0A055DF0A1FE2F08762F82087F559DDC77C007771DF0000A0281577C4D7F8BC21D8BE0821FD5577F1FF001DFC7FC000280A003281C4D000000
...    620541E2680061340002620560E268400023102A07134200019881583850100010C40A83C28000C1400014C4080480510136023028007FFFF0
...    000380D800A070101C0C40E03800381F0244100000020800001104002000002080040000441000802000820010040110400201004208004020
...    0C410008060108200100C0300D83979515839795140304000025965410000196595040000A596501000039659400D41EAE95555078BA551404
...    E6013E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C01E6FC0701C0
...    0005001801003004008202008010080200400700600601000C0280280600400700600E01001C0280480600800700E00602000C0480280A0041
...    0700200600400C010028020040E004004010008010010040006AC1C081C8494989CA00DDC0000000D85AD0

${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B03004040CA00389A0000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA00000
...    00010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402
...    020080108000201000080404008011800040200010080004020200400840002010100200440001008000402020040080

${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF43081A808081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780E000048080C2609A14006F00DFF00000280000018400220001

@{5GC000784}
...    NRCELL-1:arpPrioEmergencyCall=2
...    NRCELL-1:actEmergencyCall=true
...    NRCELL-1:emergencyCallFails=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...    NRBTS:timerXnDataFwdGuard=2000
...    NRCELL-2:arpPrioEmergencyCall=2
...    NRCELL-2:actEmergencyCall=true
...    NRCELL-2:emergencyCallFails=true
...    NRCELL-2:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...    NRCELL-2:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true

@{CB008700}
...    NRCELL-1:actARPBasedAC=off
...    NRCELL-2:actARPBasedAC=off

@{CB008379}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actGBRAdmissionControl=GBRService

@{5GC000772}
...    NRCELL-1:actCDrx=true
...    NRCELL-2:actCDrx=true

@{ngho}
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:suppCnPartialAdNgHo=false
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000

@{5GC000749}
...    NRBTS:actNormVCFallback=false
...    NRBTS:actRedirect=false
...    NRCELL-1:voiceFBMode=disabled
...    NRCELL/NRREDRT-1:redirFreqEutra=39750    # earfcnValue=39750 band 41
...    NRCELL/NRREDRT-1:redirRat=eutra
...    NRCELL/NRREDRT-1:redirPrio=5
...    delete:NRCELL/NRREDRT-2:redirSsbScs
...    NRCELL/NRREDRT-2:redirRat=nr
...    NRCELL/NRREDRT-2:redirSsbScs=30 KHz
...    NRCELL/NRREDRT-2:redirFreqNr=636666
...    NRCELL/NRREDRT-2:redirPrio=4
@{5GC000710}
#    actMobilityProfile deactivate for using cell level parameter in current test case.
...    NRBTS:actMobilityProfile=false
...    NRBTS:actSPID=true
...    NRBTS/NRMOPR_NSA-1:a2MeashoEnabled=none
...    NRBTS/NRMOPR_NSA-1:a3MeasEnabled=none
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1
...    NRBTS/NRMORED-1:redirFreqNr=636666
...    NRBTS/NRMORED-1:redirRat=nr
...    NRBTS/NRMORED-1:redirPrio=3
...    NRBTS/NRMORED-2:redirFreqEutra=39750    # earfcnValue=39750 band 41
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1,MRBTS-1/NRBTS-1/NRMORED-2

@{5GC001468}
...    NRBTS:actEmergencyFallback=true
...    NRCELL:emergencyFBMode=redirection
...    NRCELL/NRREDRT-1:redirFreqEutra=39750    # earfcnValue=39750 band 41
...    NRCELL/NRREDRT-1:redirRat=eutra
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    delete:NRCELL/NRREDRT-1:redirFreqNr

@{5GC000711}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:nonContentRachAcFullConfigHo=false
...    NRBTS:tNgRelocExecDeltL=5000

@{CB008698}
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL-1:allowEmergencyReservForTempUse=false
...    NRCELL-1:numOfRadioResReservForTempUse=0
...    NRCELL-1:preferNsaPreemption=false
...    NRCELL-1:numOfRadioResReservForEmergency=0
...    NRCELL-1:maxNumOfNonGBRBearersSA=6
...    NRCELL-1:maxNumOfGBRBearersSA=20
...    NRCELL-1:maxGBRTrafficLimit=50
...    NRCELL-1:addGbrTrafficHo=0
...    NRCELL-2:allowEmergencyReservForTempUse=false
...    NRCELL-2:numOfRadioResReservForTempUse=30
...    NRCELL-2:preferNsaPreemption=false
...    NRCELL-2:numOfRadioResReservForEmergency=2
...    NRCELL-2:maxNumOfNonGBRBearersSA=550
...    NRCELL-2:maxNumOfGBRBearersSA=10
...    NRCELL-3:allowEmergencyReservForTempUse=false
...    NRCELL-3:numOfRadioResReservForTempUse=30
...    NRCELL-3:preferNsaPreemption=false
...    NRCELL-3:numOfRadioResReservForEmergency=2
...    NRCELL-3:maxNumOfNonGBRBearersSA=550
...    NRCELL-3:maxNumOfGBRBearersSA=10
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=10
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=120
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:timerRejectWait=5
...    NRBTS/NRCELLGRP-0:addNumOfRrcCGRPSAHo=0
...    NRBTS/NRCELLGRP-1:addNumOfRrcCGRPSAHo=0
...    NRBTS/NRCELLGRP-2:addNumOfRrcCGRPSAHo=0

@{CB008232}
...    NRCELL-1:actPriorityAccess=true
...    NRBTS:applyPriorityAccess=HPA+MPS
...    NRBTS/NRPRIOACC_PROFILE-1:nrPlmnIdx=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=5
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=1
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax=9
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin=7
...    NRCELL-1:numOfRadioResReservForPa=4
...    NRBTS/NRDU-1:numOfDrbsReservForPa=0
...    NRCELL-1:tPageCorrInt=3000
...    NRCELL-1:raPrioritizationForAI=MPS
...    NRCELL-1:powerRampingStepHighPriorityCbra=dB4
...    NRCELL-1:powerRampingStep=dB2
...    NRCELL-1:pagingPrioLevelPaMax=1
...    NRCELL-1:pagingPrioLevelPaMin=1

@{PMQAP}
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS:actIpThpt=true
...    NRPMRNL-1:miNrNGCC=15min
...    NRPMRNL-1:miNrHighRlcCellNrpmqap=15min
...    NRPMRNL-1:miNrNgInterfaceNrpmqap=15min
...    NRPMRNL-1:miNrNsaAcCuNrpmqap=15min
...    NRPMRNL-1:miNrPdcpCellNrpmqap=15min
...    NRPMRNL-1:miNrSaCuNrpmqap=15min
...    NRPMRNL-1:miNrUeStatNrpmqap=15min
...    NRPMRNL-1:miNrX2ccNrpmqap=15min
...    NRPMRNL-1/NRPMQAP-1:cfgProfType=both
...    NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRPMRNL-1/NRPMQAP-1:cfgArpRange=1-15
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341

@{fix_relation_error}
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-1:redirPrioBadUlRadio=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREDRT-2:redirPrioBadUlRadio=2
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-1:redirPrioBadUlRadio=1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRREDRT-2:redirPrioBadUlRadio=2
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-1:redirPrioBadUlRadio=1
...    MRBTS-1/NRBTS-1/NRCELL-3/NRREDRT-2:redirPrioBadUlRadio=2
...    MRBTS-1/NRBTS-1/NRDRB-3:queuingDelayDiscarding=Disabled
...    MRBTS-1/NRBTS-1/NRDRX-1:drxLongCycle=40ms
...    MRBTS-1/NRBTS-1/NRDRB-3:cellAggrLevel=Not FR1 CA eligible
...    MRBTS-1/NRBTS-1/NRDRB-4:cellAggrLevel=Not FR1 CA eligible
...    MRBTS-1/NRBTS-1/NRDRB_5QI-1:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRDRB_5QI-2:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    MRBTS-1/NRBTS-1/NRDRB_5QI-6:nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRDRB_5QI-1:snssaiList:snssaiDN=SNSSAI-1

######## Mobility Paramter ########
${carrierfreq_sim_gnb3_cell1}    636576    # gscn=7880
${carrierfreq_real_gnb2_cell1}    636666    # gscn=7880
${carrierfreq_EUTRAN}    39750    # 39750    # gscn=7985    # earfcnValue=39750 band 41

@{3cell_freq}
...    NRCELL-1:freqBandIndicatorNR=78
...    NRCELL-1:gscnOrSsPbchArfcn=7880
...    NRCELL-1:nrarfcn=636666
...    NRCELL-2:freqBandIndicatorNR=78
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:nrarfcn=636666
...    NRCELL-3:freqBandIndicatorNR=78
...    NRCELL-3:gscnOrSsPbchArfcn=7985
...    NRCELL-3:nrarfcn=646666

@{enable_meas_intrafreq}
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:rsrpThresholdSSB=11
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=9
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:rsrpThresholdSSB=11
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:filterCoeffSsbRsrp=fc4
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-1:a5MeasEnabled=rsrp
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=74
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=84
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-2:a5MeasEnabled=rsrp
...    NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=75
...    NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=85
...    NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{enable_meas_interfreq}
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=1
...    NRCELL-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=76
...    NRCELL-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=86
...    NRCELL-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=8
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

...    NRCELL-3/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=11
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=30
...    NRCELL-3/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:ssbFrequency=636576
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-3/NRHOIF-1:scs=15 KHz
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:a3MeasEnabled=rsrp

@{nrrel_inter_freq_intra_gnb}
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:lcrId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:removeNotAllowed=false

...    NRCELL-3/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-2:gNbId=1
...    NRCELL-3/NRREL-2:lcrId=2
...    NRCELL-3/NRREL-2:gNbIdLength=22
...    NRCELL-3/NRREL-2:removeNotAllowed=false

@{nrrel_intra_freq_intra_gnb}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{cbra_non_srb3}
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRBTS:srb3SupportEnabled=false

@{params_to_enable_nsa_ho}
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true

@{CB008195}
...    MRBTS-1/NRBTS-1:actRrcInactState=intra-gNB
...    MRBTS-1/NRBTS-1:act3gppBL23R1=true
...    MRBTS-1/NRBTS-1:rrcReestabTypeSA=sameGNB
...    MRBTS-1/NRBTS-1:drbRrcInactInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:drbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:srbInactivityTimerSA=90
...    MRBTS-1/NRBTS-1:maxUeRrcInactTime=90
...    MRBTS-1/NRBTS-1:gNbCuType=SA+NSA
...    NRBTS-1/NRCELL-1:cellDepType=SA+NSA
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrCellUtilPerNrg=5min
...    MRBTS-1/NRBTS-1:actSliceAwareAdmissionCtrl=true    # feature flag
...    MRBTS-1/NRBTS-1:actDrbPreemption=false
...    MRBTS-1/NRBTS-1:actUserPreemption=false
...    MRBTS-1/NRBTS-1:actConnRrcPooling=true
...    MRBTS-1/NRBTS-1:actScheUePooling=true

...    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:nrCellList=1
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:addNumOfNonGBRBearersCGRPSAHo=0    # default 0
...    MRBTS-1/NRBTS-1/NRCELLGRP-0:addNumOfRrcCGRPSAHo=0              # default 0

...    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfRrcCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:nrCellList=2
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:maxNumOfNonGBRBearersCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:addNumOfNonGBRBearersCGRPSAHo=1    # default 0
...    MRBTS-1/NRBTS-1/NRCELLGRP-1:addNumOfRrcCGRPSAHo=0              # default 0

...    MRBTS-1/NRBTS-1/NRCELLGRP-2:maxNumOfRrcCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-2:nrCellList=3
...    MRBTS-1/NRBTS-1/NRCELLGRP-2:maxNumOfNonGBRBearersCGRPSA=13
...    MRBTS-1/NRBTS-1/NRCELLGRP-2:addNumOfNonGBRBearersCGRPSAHo=0    # default 0
...    MRBTS-1/NRBTS-1/NRCELLGRP-2:addNumOfRrcCGRPSAHo=0              # default 0

...    MRBTS-1/NRBTS-1/NRDU-1:maxNumOfRrcConUEsPerDU=2448
...    MRBTS-1/NRBTS-1/NRDU-1:refNrCellGroup=0,1,2

...    NRBTS-1/NRCELL-1:sliceAwareAdmissionCtrlEnabled=true    # feature flag
...    NRBTS-1/NRCELL-2:sliceAwareAdmissionCtrlEnabled=true    # feature flag
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=20
...    NRBTS-1/NRCELL-2:maxNumOfRrcSA=20
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerNRCell=275
...    NRBTS-1/NRCELL-2:maxNumOfUsersPerNRCell=275
...    NRBTS-1/NRCELL-1:actPriorityAccess=false
...    NRBTS-1/NRCELL-2:actPriorityAccess=false
...    NRBTS-1/NRCELL-1:actEmergencyCall=false
...    NRBTS-1/NRCELL-2:actEmergencyCall=false
...    NRBTS-1/NRCELL-1:maxNumOfNonGBRBearersSA=550
...    NRBTS-1/NRCELL-2:maxNumOfNonGBRBearersSA=550
...    NRBTS-1/NRCELL-1:maxNumOfCaUsersNRCell=13
...    NRBTS-1/NRCELL-2:maxNumOfCaUsersNRCell=13
...    NRBTS-1/NRCELL-1:maxNumOfSCellAlloc=13
...    NRBTS-1/NRCELL-2:maxNumOfSCellAlloc=13
...    NRBTS-1/NRCELL-1:maxNumOfUsersPerCell=13
...    NRBTS-1/NRCELL-2:maxNumOfUsersPerCell=13
...    NRBTS-1/NRCELL-1:maxNumOfNrDcSnUsers=13
...    NRBTS-1/NRCELL-2:maxNumOfNrDcSnUsers=13
...    NRBTS-1/NRCELL-1:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1
...    NRBTS-1/NRCELL-2:nrResourceGroupProfileRacDN=NRBTS-1/NRRESOURCEGROUP_PROFILE-1

...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgNsaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:defaultRgSaList:nrResourceGroupId=1|nrPlmnDN=MRBTS-1/NRBTS-1/NRPLMN-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1:nrResourceGroupProfileId=1
...    @{Limit_UEs_In_SNSSAI-1}
...    @{Limit_UEs_In_SNSSAI-2}
...    @{Limit_UEs_In_SNSSAI-3}
...    NRBTS:rgMinQuotaReservationLevel=cell_and_multicell_level
...    NRBTS/NRRESOURCEGROUP_PROFILE-1:bypassRgLimits=0

# maxNumOfRrcCGRPSA=13, maxNumOfRrcSA=20
@{Limit_UEs_In_SNSSAI-1}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:nrResourceList:resourceDN=SNSSAI-1|resourceDN=SNSSAI-1
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:maxQuota=50    # 50% 20 = 10, max 10 UEs, common pool
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-1:racParams:minQuota=30    # 30% 20 = 6, min 6 UEs, dedicate pool

@{Limit_UEs_In_SNSSAI-2}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:nrResourceList:resourceDN=SNSSAI-2|resourceDN=SNSSAI-2
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:maxQuota=35    # 35% 20 = 7, max 7 UEs, common pool
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-2:racParams:minQuota=17    # 17% 20 = 3.4, min 3 UEs, dedicate pool

@{Limit_UEs_In_SNSSAI-3}
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:nrResourceList:resourceDN=SNSSAI-3|resourceDN=SNSSAI-3
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:maxQuota=30    # 30% 20 = 6, max 6 UEs, common pool
...    NRBTS-1/NRRESOURCEGROUP_PROFILE-1/NRRESOURCEGROUP-3:racParams:minQuota=12    # 12% 20 = 2.4, min 2 UEs, dedicate pool

@{FAULTS_EXCLUDED_CHECKING}
...    7307

# The number of non-GBR DRB radio admission requests for SA user, per PLMN, per slice (M55149C00002)
${SA_NGBR_DRB_REQ_SLICE}    M55149C00002
${AVG_NUM_UE_NOM_NRG}    M55910C00005    # Numerator for the average number of UEs per resource group
${DNOM_SAMPLES_NRG}    M55910C00006
${AVE_NUM_NGBR_NOM_NRG}    M55910C00007
${PEAK_NUM_UE_NRG}    M55910C00010
${PEAK_NUM_NGBR_NRG}    M55910C00011
${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}    M55910C00015
# Number of UE RAC requests rejected due to reaching max quota for the UE contexts in resource group
${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}    M55910C00016
${NUM_ADM_REQ_NGBR_NRG}    M55910C00017
${NUM_ADM_SUC_NGBR_NRG}    M55910C00018
${NUM_ADM_REQ_UE_NRG}    M55910C00023
${NUM_ADM_SUC_UE_NRG}    M55910C00024

@{PM_Counters_Check_03_01}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_REQ_SLICE}=10    # SLICE1 Register 10 UEs
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_REQ_SLICE}=7    # SLICE2 Register 7 UEs
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714343:${SA_NGBR_DRB_REQ_SLICE}=6    # SLICE3 Register 6 UEs
#below were moved from RD counter file to PM
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>500    # 580.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>100    # 151.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>50    # 72.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>=300
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=300
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>=300
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>500    # 579.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>100    # 151.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>50    # 71.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=8    # SLICE1 8UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=5    # SLICE2 5UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=4    # SLICE3 4UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=8    # SLICE1 8UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=5    # SLICE2 5UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=4    # SLICE3 4UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=12    # SLICE1 12UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=9    # SLICE2 9UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=8    # SLICE3 8UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=10    # SLICE1 10UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=7    # SLICE1 7UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=6    # SLICE1 6UEs successful
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=12    # Register 10 + Reestablish 2
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=9    # Register 7 + Reestablish 2
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=8    # Register 6 + Reestablish 2
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=10    # Register 9 + Reestablish 1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=7    # Register 6 + Reestablish 1
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=6    # Register 5 + Reestablish 1

@{PM_Counters_Check_30_01}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_REQ_SLICE}=9    # SLICE1 Register 9 UEs
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_REQ_SLICE}=6    # SLICE2 Register 6 UEs
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714343:${SA_NGBR_DRB_REQ_SLICE}=5    # SLICE3 Register 5 UEs
#below were moved from RD counter file to PM
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${AVG_NUM_UE_NOM_NRG}>500    # 580.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${AVG_NUM_UE_NOM_NRG}>100    # 151.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${AVG_NUM_UE_NOM_NRG}>0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${DNOM_SAMPLES_NRG}>=600
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${DNOM_SAMPLES_NRG}>=600
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${DNOM_SAMPLES_NRG}>=600
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${AVE_NUM_NGBR_NOM_NRG}>500    # 579.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${AVE_NUM_NGBR_NOM_NRG}>100    # 151.0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${AVE_NUM_NGBR_NOM_NRG}>0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${PEAK_NUM_UE_NRG}=8    # SLICE1 8UEs
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${PEAK_NUM_UE_NRG}=5    # SLICE2 5UEs
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${PEAK_NUM_UE_NRG}=4    # SLICE3 4UEs
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${PEAK_NUM_NGBR_NRG}=8
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${PEAK_NUM_NGBR_NRG}=5
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${PEAK_NUM_NGBR_NRG}=4
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${RAC_REJ_DUE_DRB_MAX_QUOTA_NRG}=0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${RAC_REJ_DUE_UE_MAX_QUOTA_NRG}=0
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_REQ_NGBR_NRG}=18
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_REQ_NGBR_NRG}=12
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_REQ_NGBR_NRG}=10
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_SUC_NGBR_NRG}=17
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_SUC_NGBR_NRG}=11
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_SUC_NGBR_NRG}=9
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_REQ_UE_NRG}=18
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_REQ_UE_NRG}=12
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_REQ_UE_NRG}=10
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-1:${NUM_ADM_SUC_UE_NRG}=17
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-2:${NUM_ADM_SUC_UE_NRG}=11
...    PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/NRRESOURCEGROUP-3:${NUM_ADM_SUC_UE_NRG}=9

*** Test Cases ***
CB008195-A-EC4_ET_03_01_Counters for SA UE context admission dynamic cell limits check
    [Documentation]
    ...    MRBTS-1/NRBTS-1/NRCELLGRP-0:maxNumOfRrcCGRPSA=13
    ...    MRBTS-1/NRBTS-1/NRCELLGRP-0:nrCellList=1
    ...    Slice1: minQuota=30 * maxNumOfRrcSA=20, Dedicated pool 6UEs, common pool 13-11=2
    ...    Slice2: minQuota=17 * maxNumOfRrcSA=20, Dedicated pool 3UEs, common pool 13-11=2
    ...    Slice3: minQuota=12 * maxNumOfRrcSA=20, Dedicated pool 2UEs, common pool 13-11=2
    ...    1. Register 9 UEs With PDU1 In SNSSAI-1 Expected 8 Of Them Succeeded And 1 Failed
    ...    2. Register 6 UEs With PDU1 In SNSSAI-2 Expected 5 Of Them Succeeded And 1 Failed
    ...    3. Register 5 UEs With PDU1 In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed
    [Tags]
    Clear Counter files
    Register 9 UEs With PDU1 In SNSSAI-1 Expected 8 Of Them Succeeded And 1 Failed    cell_id=1
    Register 6 UEs With PDU1 In SNSSAI-2 Expected 5 Of Them Succeeded And 1 Failed    cell_id=1
    Register 5 UEs With PDU1 In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed    cell_id=1
    Release UEs    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters_Check_03_01}

#CB008195-A-EC4_ET_30_01_SA UE admission dynamic cell limits check failure during incoming inter-RAT handover
#    [Documentation]
#    ...    CB008195-A#EC4: Admission for incoming HO - failure
#    ...    Procedure
#    ...    1 gNB-CU-CP receives XnAP:HandoverRequest form source gNB
#    ...    2 Admission control fails at gNB-DU as maximum quota in RG selected for UE is reached and gNB-DU sends to
#    ...      NB-CU-CP F1AP: UEContextSetupFailure with CauseGroup set to 'Radio Network Layer' and RadioNetworkLayerCause
#    ...      set to 'no-radio-resources-available'.
#    ...    3 gNB-CU-CP sends XnAP:HandoverPreparationFailure to source gNB as per legacy
#    [Tags]
#    Clear Counter files
#    9 UEs incoming inter-RAT HO To real_gNB2 With PDU1 In SNSSAI-1 Expected 8 Of Then Succeeded And 1 Failed
#    6 UEs incoming inter-RAT HO To real_gNB2 With PDU1 In SNSSAI-2 Expected 5 Of Then Succeeded And 1 Failed
#    5 UEs incoming inter-RAT HO To real_gNB2 With PDU1 In SNSSAI-3 Expected 4 Of Then Succeeded And 1 Failed
#    Release UEs    ue_type=all
#    Check Counters    pm_counters_expression=${PM_Counters_Check_30_01}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri
    Execute Egate Command    trace_sim protocol=xn uec=1 amf=1 enb=3 on

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1 priority=1 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=2 5qi=2 priority=2 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=3 5qi=3 priority=3 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=4 5qi=4 priority=4 pci=shall_not_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosflow id=5 5qi=5 priority=5 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=6 5qi=6 priority=6 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7 pci=shall_not_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=8 5qi=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    Update Cfg    set_qosflow id=9 5qi=9 priority=9 pci=may_trigger_pre_emption pvi=not_pre_emptable
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A6 default=off ue=all amf=1
    Update Cfg    set_nwslice id=3 qos_flows=9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A7 default=off ue=all amf=1
    Update Cfg    ue_nr_capabilities id=1-9 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    ue_param id=1-9 nr_usage_setting=voice_centric ue_nr_capabilities=${ue_nr_capabilities}
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    ue_param id=1-9 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    ${V_5}    catenate
    ...    ue_param id=31-35 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Update Cfg    ${V_5}
    Setup Sim Gnb
    Setup Sim inter RAT Enb

Setup Sim Gnb
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6,0x01:0xD143A7 amf=1
    Update Cfg    ${V_2}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=3000

Setup Sim inter RAT Enb
    ${V_3}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 daemon=10.0.2.1:22222 gnb_id=0x19:28 nssai=0x01:0xD143A5    # 0x19 eNodeBId=25
    ...    x2_peers=none xn=10.0.1.126 amf=1
    Update Cfg    ${V_3}
    ${V_4}    catenate
    ...    set_cell id=1 gnb=4 pci=4:0 earfcn=39750:39750 tac=200 proxy=10.0.2.93:9999 nrci=0x19 tdd_cell=on bw=20MHz    # pci=4:0 phycell_id=12
    ...    technology=lte mandatory_for_activation=off
    Update Cfg    ${V_4}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false sib1_period=3000

Sa Ue Attach To Real GNB with pdu1 slice
    [Arguments]    ${ue_id}=1    ${cell_id}=1    ${nwslice_id}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}    # enb=, local identifier for eNodeB
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=${nwslice_id} gw=1    ${pass_regexp}

9 UEs incoming inter-RAT HO To real_gNB2 With PDU1 In SNSSAI-1 Expected 8 Of Then Succeeded And 1 Failed
    Register 9 UEs to real-GNB then HO to sim-LTE successful
    8 UEs HO Back from sim-LTE to real-GNB successful
    9th UE HO Back from sim_LTE To real_GNB Fail Due to limit
    Release Ues    ue_id=4,5,6,7,8,9

6 UEs incoming inter-RAT HO To real_gNB2 With PDU1 In SNSSAI-2 Expected 5 Of Then Succeeded And 1 Failed
    Register 6 UEs to real-GNB then HO to sim-LTE successful
    5 UEs HO Back from sim-LTE to real-GNB successful
    6th UE HO Back from sim_LTE To real_GNB Fail Due to limit
    Release Ues    ue_id=5,6,7,8,9

5 UEs incoming inter-RAT HO To real_gNB2 With PDU1 In SNSSAI-3 Expected 4 Of Then Succeeded And 1 Failed
    Register 5 UEs to real-GNB then HO to sim-LTE successful
    4 UEs HO Back from sim-LTE to real-GNB successful
    5th UE HO Back from sim_LTE To real_GNB Fail Due to limit
    Release Ues    ue_id=5,6,7,8,9

Register 9 UEs With PDU1 In SNSSAI-1 Expected 8 Of Them Succeeded And 1 Failed
    [Arguments]    ${cell_id}=1
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=1    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=2    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=3    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=4    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=5    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=6    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=7    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Simulator UE RLF And Trigger RRC-Reestablish    ue_id=7    state=ACTIVE    regexp=ACTIVE
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=8    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Simulator UE RLF And Trigger RRC-Reestablish    ue_id=8    state=IDLE    regexp=IDLE
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=1    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=7,8,9,10

Register 9 UEs to real-GNB then HO to sim-LTE successful
    Log to console    \r
    Log to console with time prefix    step: === real_gNB2_nrBtsId_1 cell-1 Band N78 physCellId_50 ===
    Log to console with time prefix    step: === sim_LTE_eNB1_eNbId_74566 cell-1 Band N78 physCellId_11 ===
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=1    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=2    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=3    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=4    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=5    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=6    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=7    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=8    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Multi UE HO from real_GNB To sim_LTE    start_ue_id=1    end_ue_id=8
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=9    cell_id=1    nwslice_id=1    pass_regexp=QoS Routing Table
    Multi UE HO from real_GNB To sim_LTE    start_ue_id=9    end_ue_id=9

Register 6 UEs With PDU1 In SNSSAI-2 Expected 5 Of Them Succeeded And 1 Failed
    [Arguments]    ${cell_id}=1
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=7    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=8    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Simulator UE RLF And Trigger RRC-Reestablish    ue_id=10    state=ACTIVE    regexp=ACTIVE
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Simulator UE RLF And Trigger RRC-Reestablish    ue_id=11    state=IDLE    regexp=IDLE
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=12    cell_id=${cell_id}    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=13    cell_id=${cell_id}    nwslice_id=2    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11,12,13

Register 6 UEs to real-GNB then HO to sim-LTE successful
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=4    cell_id=1    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=5    cell_id=1    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=6    cell_id=1    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=7    cell_id=1    nwslice_id=2    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=8    cell_id=1    nwslice_id=2    pass_regexp=QoS Routing Table
    Multi UE HO from real_GNB To sim_LTE    start_ue_id=4    end_ue_id=8
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=9    cell_id=1    nwslice_id=2    pass_regexp=QoS Routing Table
    Multi UE HO from real_GNB To sim_LTE    start_ue_id=9    end_ue_id=9

Register 5 UEs With PDU1 In SNSSAI-3 Expected 4 Of Them Succeeded And 1 Failed
    [Arguments]    ${cell_id}=1
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=9    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=10    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=11    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Simulator UE RLF And Trigger RRC-Reestablish    ue_id=11    state=ACTIVE    regexp=ACTIVE
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=12    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Simulator UE RLF And Trigger RRC-Reestablish    ue_id=12    state=IDLE    regexp=IDLE
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=13    cell_id=${cell_id}    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=14    cell_id=${cell_id}    nwslice_id=3    pass_regexp=RAN radio resources not available
    Release Ues    ue_id=9,10,11,12,13,14

8 UEs HO Back from sim-LTE to real-GNB successful
    Multi UE HO from sim_LTE To real_GNB    start_ue_id=1    end_ue_id=8

5 UEs HO Back from sim-LTE to real-GNB successful
    Multi UE HO from sim_LTE To real_GNB    start_ue_id=4    end_ue_id=8

4 UEs HO Back from sim-LTE to real-GNB successful
    Multi UE HO from sim_LTE To real_GNB    start_ue_id=5    end_ue_id=8

Multi UE HO from real_GNB To sim_LTE
    [Arguments]    ${start_ue_id}=1    ${end_ue_id}=2
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        One UE HO from real_GNB To sim_LTE    ${ue_id}
    END
    Execute Egate Command    enb_disp
    Execute Egate Command    ue_disp

Multi UE HO from sim_LTE To real_GNB
    [Arguments]    ${start_ue_id}=1    ${end_ue_id}=2
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${end_ue_id}+1
        One UE HO from sim_LTE To real_GNB    ${ue_id}
    END
    Execute Egate Command    enb_disp
    Execute Egate Command    ue_disp

One UE HO from real_GNB To sim_LTE
    [Arguments]    ${ue_id}=1
    Send A2 To Trigger B2    ue_id=${ue_id}    carrierfreq=${carrierfreq_sim_gnb3_cell1}
    Trigger B2 MR to HO to LTE    ue_id=${ue_id}

One UE HO from sim_LTE To real_GNB
    [Arguments]    ${ue_id}=1
    #sleep    5s    # wait ue out Handovering State
    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    ${ret}=    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret}    UEC-1: UE${ue_id}: Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed

9th UE HO Back from sim_LTE To real_GNB Fail Due to limit
    UE HO Back from sim_LTE To real_GNB Fail Due to limit    ue_id=9

6th UE HO Back from sim_LTE To real_GNB Fail Due to limit
    UE HO Back from sim_LTE To real_GNB Fail Due to limit    ue_id=9

5th UE HO Back from sim_LTE To real_GNB Fail Due to limit
    UE HO Back from sim_LTE To real_GNB Fail Due to limit    ue_id=9

UE HO Back from sim_LTE To real_GNB Fail Due to limit
    [Arguments]    ${ue_id}=9
    #sleep    5s    # wait ue out Handovering State
    ${cmd}    Catenate    gnb_trigger_inter_rat_handover_to_5g ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
    ${ret}=    Execute Egate Command    ${cmd}    pass_regexp=GNB-4: UE${ue_id}: Received Handover Preparation Failure
    Should Contain    ${ret}    radioNetwork : radio-resources-not-available

Send A2 to Trigger B2
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${carrierfreq_sim_gnb3_cell1}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7    ReconfigurationComplete

Trigger B2 MR to HO to LTE
    [Arguments]    ${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}
    ...    carrierfreq=${carrierfreq_EUTRAN}    event_type=B2    carrierfreq_rat=EUTRAN
    ${meas_para}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=B2 srsrp_nr=11
    ...    srsrq_nr=11 phycell_id=12 nrsrp_nr=90 nrsrq_nr=25    # pci=4:0 phycell_id=12
    ${ret}=    Execute Egate Command    ${meas_para}    pass_regexp=UeContextReleaseComplete
    Should Contain    ${ret}    UE${ue_id}: Successful handover from EXT_ENB-2.1 to ENB-4.1
    Should Contain    ${ret}    UE${ue_id}: IRAT Handover from NR to EUTRA completed

Register 5 UEs to real-GNB then HO to sim-LTE successful
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=5    cell_id=1    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=6    cell_id=1    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=7    cell_id=1    nwslice_id=3    pass_regexp=QoS Routing Table
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=8    cell_id=1    nwslice_id=3    pass_regexp=QoS Routing Table
    Multi UE HO from real_GNB To sim_LTE    start_ue_id=5    end_ue_id=8
    Sa Ue Attach To Real GNB with pdu1 slice    ue_id=9    cell_id=1    nwslice_id=3    pass_regexp=QoS Routing Table
    Multi UE HO from real_GNB To sim_LTE    start_ue_id=9    end_ue_id=9

Simulator UE RLF And Trigger RRC-Reestablish
    [Arguments]    ${ue_id}=1    ${state}=ACTIVE    ${regexp}=ACTIVE
    Execute Egate Command    ue_testmode_set id=${ue_id} testmode=rlf action=activate profile_index=1
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=mo-Signalling    # emergency
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1
    ...    UE${ue_id}: NR RRC Reestablishment sucessfully completed    timeout=20s    sleep_time=5
    Execute Egate Command    ue_disp id=${ue_id} state=${state}    pass_regexp=${regexp}    timeout=20s
