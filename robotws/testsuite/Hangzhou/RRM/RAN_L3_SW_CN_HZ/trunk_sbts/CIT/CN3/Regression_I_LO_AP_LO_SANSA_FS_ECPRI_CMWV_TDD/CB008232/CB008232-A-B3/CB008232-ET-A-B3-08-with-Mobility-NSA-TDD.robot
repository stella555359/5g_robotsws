*** Settings ***
Documentation
...    author: kang.xiang
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CIT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG4    owner-kang.xiang    release-SBTS23R1
Resource    ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{5GC000786}
...    @{CB006112-A}
...    @{5GC000704}
...    @{CB006112-C}
...    @{5GC000707_InterRAT}
...    @{5GC000784}
...    @{CB008700}
...    @{5GC002145}
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
...    NRBTS:actInactDetNSAUe=true
...    NRBTS:nsaInactivityTimer=600
...    NRBTS:srbInactivityTimerSA=600

@{5GC000786}
...    NRCELL:actVoNR=true
...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-2:fiveqiValueList=6
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-5:fiveqiValueList=9
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-6:fiveqiValueList=7
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
#...    NRDRB-3:queuingDelayDiscarding=Disabled
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
#...    NRDRB-4:queuingDelayDiscarding=Disabled
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
#...    NRCELL-1/NRHOIF-1:chBw=20MHz
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
...    NRHOIR-1:earfcnValue=39750
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
...    NRADJECELL-1:earfcnValue=39750
...    NRADJECELL-1:lcrId=1
...    NRADJECELL-1:physCellId=12
...    NRADJECELL-1:eUtraMultibandInfoList=41
...    NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3
...    NRADJECELL-1:enbPlmn:mcc=311|mncLength=3
...    NRADJECELL-1:enbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...    NRCELL-1/NRRELE-1:eNodeBId=25
...    NRCELL-1/NRRELE-1:eutranCellExcluded=false
...    NRCELL-1/NRRELE-1:lcrId=1
...    NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3
${ue_nr_capabilities}    SEPARATOR=
...    E1A03FA0474E7AEFFFFFAFC2200782E0203C127BE7FFFFF800F00C6FBE00050370101F8E0155DF0A3FE2F08762F82087F540A083D951D2206
...    24FAC41E420F081425BE7E57771DF001DDC77C000CC005000742AEF851FF17843B17C1043FAA05041ECA8E9103127D620F2107840A12DF3F3
...    3BB8EF800EEE3BE000660028003A1577C4DFF8BC21D8BE0821FD502820F65474881893EB1079083C205096F9F95DFC7FC0077F1FF00033001
...    4001D00650389A000000C40A83C4D000C2680004C40AC1C4D080004620540E268400033102B070A0200021881507850001828000298810090
...    0A2026C04605000C2508206811B649F0214285B24F810236C93E04085B24F810276C93E042853B649F000160C318C631BFFFE000138036002
...    800301C1401C0C4270070007000603E0488200000041000002208004000004100080000882001004001040020080220800402008410008040
...    188200100C021040020180601B072F2A2B072F2A28060800004B2CA82000032CB2A0800014B2CA02000072CB2801A83D5D2AAAA0F174AA283
...    839804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0
...    700001400600400C010020808020040200801001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A028
...    01041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000361781C06000601A
${ue_eutra_nr_capabilities}    SEPARATOR=
...    C10060B71B03004040CA00389A0000000FD00000000081B8981002060E2680000103F400000000206E360400818103071340000101FA00000
...    00010370B0200E8080000303F400000000206E26040081838040000100FD0000000008100800803004809B000804180004020001008000402
...    020080108000201000080404008011800040200010080004020200400840002010100200440001008000402020040080
${ue_eutra_capabilities}    SEPARATOR=
...    DD9FF43081A808081705C177E0DF99ACA100220401052A000050665F3FC1BB134BC32022F7E0DD89AB230421841086104218210C108208030
...    4218018018200C100608430030022104002D1F5518502038410041460821610401051820A30410B0820082841051820838410041420820610
...    40105902E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82E0B82
...    E0B82E0B82E0B82E0B82EFC5000019B210F0F0F1708FE2E43C3C3C3C3C3C3C3C3C3C3887878787000045F830000081010440668003E71E000
...    20406080C0E162636383A83F7FC4B5A60190BFCDEA000600DB24000080000412E780C000048080C2609A143C037FC00000A00000061000880004
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
@{5GC002145}
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL-2:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRBTS/TRACKINGAREA-200:fiveGsTac=0
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-201:fiveGsTac=1
...    NRBTS/TRACKINGAREA-201:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-201:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/SNSSAI-2:sd=13714342
@{CB008379}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actGBRAdmissionControl=GBRService
@{5GC000772}
...    NRCELL-1:actCDrx=true
...    NRBTS/NRDRX-0:drxInactivityTimer=200ms
...    NRCELL-2:actCDrx=true
@{ngho}
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
@{5GC000749}
...    NRBTS:actNormVCFallback=false
...    NRBTS:actRedirect=false
...    NRCELL-1:voiceFBMode=disabled
...    NRCELL/NRREDRT-1:redirFreqEutra=39750
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
...    NRBTS/NRMORED-2:redirFreqEutra=39750
...    NRBTS/NRMORED-2:redirRat=eutra
...    NRBTS/NRMORED-2:redirPrio=2
...    NRBTS/NRMOPR_SA-1:nrMoRedDNList=MRBTS-1/NRBTS-1/NRMORED-1,MRBTS-1/NRBTS-1/NRMORED-2
@{5GC001468}
...    NRBTS:actEmergencyFallback=true
...    NRCELL:emergencyFBMode=redirection
...    NRCELL/NRREDRT-1:redirFreqEutra=39750
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
...    NRCELL-1:maxNumOfRrcSA=3
...    NRCELL-1:maxNumOfUsersPerNRCell=4
...    NRCELL-1:maxNumOfNrDcSnUsers=4
...    NRCELL-1:maxNumOfCaUsersNRCell=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRCELL-1:maxNumOfUsersPerCell=2
...    NRCELL-1:maxNumOfNonGBRBearersSA=6
...    NRCELL-1:maxNumOfGBRBearersSA=20
...    NRCELL-1:maxGBRTrafficLimit=50
...    NRCELL-1:addGbrTrafficHo=0
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=10
...    NRBTS/NRCELLGRP-0:maxNumOfNonGBRBearersCGRPSA=30
...    NRCELL-2:allowEmergencyReservForTempUse=false
...    NRCELL-2:numOfRadioResReservForTempUse=30
...    NRCELL-2:preferNsaPreemption=false
...    NRCELL-2:numOfRadioResReservForEmergency=2
...    NRCELL-2:maxNumOfRrcSA=2
...    NRCELL-2:maxNumOfUsersPerNRCell=2
...    NRCELL-2:maxNumOfNrDcSnUsers=2
...    NRCELL-2:maxNumOfCaUsersNRCell=2
...    NRCELL-2:maxNumOfSCellAlloc=2
...    NRCELL-2:maxNumOfUsersPerCell=2
...    NRCELL-2:maxNumOfNonGBRBearersSA=550
...    NRCELL-2:maxNumOfGBRBearersSA=10
...    NRBTS/NRCELLGRP-1:maxNumOfRrcCGRPSA=10
...    NRCELL-3:allowEmergencyReservForTempUse=false
...    NRCELL-3:numOfRadioResReservForTempUse=30
...    NRCELL-3:preferNsaPreemption=false
...    NRCELL-3:numOfRadioResReservForEmergency=2
...    NRCELL-3:maxNumOfRrcSA=2
...    NRCELL-3:maxNumOfUsersPerNRCell=2
...    NRCELL-3:maxNumOfNrDcSnUsers=2
...    NRCELL-3:maxNumOfCaUsersNRCell=2
...    NRCELL-3:maxNumOfSCellAlloc=2
...    NRCELL-3:maxNumOfUsersPerCell=2
...    NRCELL-3:maxNumOfNonGBRBearersSA=550
...    NRCELL-3:maxNumOfGBRBearersSA=10
...    NRBTS/NRCELLGRP-2:maxNumOfRrcCGRPSA=10
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
@{CB008232_A_B3_8}
...    NRBTS:applyPriorityAccess=HPA
...    NRCELL:maxNumOfRrcSA=10
...    NRCELL:maxNumOfUsersPerNRCell=10
...    NRCELL:maxNumOfNrDcSnUsers=10
...    NRBTS/NRCELLGRP-0:maxNumOfRrcCGRPSA=10
...    NRBTS/NRDU-1:maxNumOfRrcConUEsPerDU=10
...    NRCELL:numOfRadioResReservForPa=2
...    NRCELL:numOfRadioResReservForTempUse=1
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForPa=0
...    NRCELL:allowEmergencyReservForTempUse=false
...    NRCELL:maxNumOfNonGBRBearersSA=5
...    NRCELL:maxNumOfGBRBearersSA=20
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMin=6
...    NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelHpaMax=9
...    delete:NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMin
...    delete:NRBTS/NRPRIOACC_PROFILE-1:arpPrioLevelMpsMax
...    NRBTS:actUserPreemption=false
...    NRBTS:actDrbPreemption=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:preferNsaPreemption=false
...    NRCELL-1:actEmergencyCall=true
...    NRCELL:arpPrioEmergencyCall=2
...    NRBTS:actConnRrcPooling=false

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
@{Counters_A_B3_8}
...    NRCELL-1:${NG_FLOW_SETUP_ATT_HPA}=14
...    NRCELL-1:${NG_FLOW_SETUP_ATT_MPS}=0
...    NRCELL-1:${NG_FLOW_SETUP_SUCC_HPA}=11
...    NRCELL-1:${NG_FLOW_SETUP_SUCC_MPS}=0
...    NRDU-1:${NRRCD_RRC_STPSUCC_MCS}=0
...    NRDU-1:${NRRCD_RRC_STPSUCC_MPS}=0

${NG_FLOW_SETUP_ATT_HPA}    M55125C12501
${NG_FLOW_SETUP_ATT_MPS}    M55125C12502
${NG_FLOW_SETUP_SUCC_HPA}    M55125C12503
${NG_FLOW_SETUP_SUCC_MPS}    M55125C12504
${NRRCD_RRC_STPSUCC_MCS}    M55127C03002
${NRRCD_RRC_STPSUCC_MPS}    M55127C03003

######## Mobility Paramter ########
${carrierfreq1}    636576
${carrierfreq2}    646656

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
#...    NRCELL-3:actCDrx=true
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

@{sgnb_modification_parameter_for_ue34}
...    NRCELL-1:maxNumOfSCellAlloc=3
...    NRCELL-1:maxNumOfUsersPerCell=3

@{cbra_non_srb3}
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRBTS:srb3SupportEnabled=false

@{params_to_enable_nsa_ho}

...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true

@{Mobility_Counters_Check}
...    NRCELL-1:${INTRA_DU_HO_ATT_NSA_MNB}=1
...    NRCELL-1:${INTRA_FR_PSCEL_CH_ATTEMPT}=1
...    NRCELL-1:${INTRA_FR_PSCEL_CH_MIN_DURAT}>0
...    NRCELL-1:${INTRA_FR_PSCEL_CH_MAX_DURAT}>0
...    NRCELL-1:${INTRA_FR_PSCEL_CH_TOT_DURAT}>0
...    NRCELL-1:${INTRA_DU_HO_MAX_DURAT_MNB}>0
...    NRCELL-2:${INTRA_DU_HO_ATT_NSA_MNB}=1
...    NRCELL-2:${INTRA_FR_PSCEL_CH_ATTEMPT}=1
...    NRCELL-2:${INTRA_FR_PSCEL_CH_MIN_DURAT}>0
...    NRCELL-2:${INTRA_FR_PSCEL_CH_MAX_DURAT}>0
...    NRCELL-2:${INTRA_FR_PSCEL_CH_TOT_DURAT}>0
...    NRCELL-2:${INTRA_DU_HO_MAX_DURAT_MNB}>0
...    NRCELL-3:${IF_INTRA_DU_HO_ATT_NSA_MNB}=2
...    NRCELL-3:${IF_INTRA_DU_HO_MIN_DURAT_MNB}>0
...    NRCELL-3:${IF_INTRA_DU_HO_MAX_DURAT_MNB}>0

${INTRA_DU_HO_ATT_NSA_MNB}    M55120C01001
${INTRA_FR_PSCEL_CH_ATTEMPT}    M55120C00001
${INTRA_DU_HO_MAX_DURAT_MNB}    M55120C01011
${INTRA_FR_PSCEL_CH_MIN_DURAT}    M55120C00005
${INTRA_FR_PSCEL_CH_MAX_DURAT}    M55120C00006
${INTRA_FR_PSCEL_CH_TOT_DURAT}    M55120C00007
${IF_INTRA_DU_HO_ATT_NSA_MNB}    M55151C00001
${IF_INTRA_DU_HO_MIN_DURAT_MNB}    M55151C00009
${IF_INTRA_DU_HO_MAX_DURAT_MNB}    M55151C00011

@{PM_Counters_Check}    @{Counters_A_B3_8}    @{Mobility_Counters_Check}
@{dldata_oveF1U}
...    NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverF1U
...    NRDRB-6:nsaDrbParam:initialDLTrafficRouting=initDLoverF1U
...    delete:NRDRB-6:nsaDrbParam:dlPreferredPath
@{dldata_oveX2U}
...    NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverX2U
...    NRDRB-6:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    delete:NRDRB-6:nsaDrbParam:dlPreferredPath
@{dldata_oveF1X2U_dlf1}
...    NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRDRB-6:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRDRB-6:nsaDrbParam:dlPreferredPath=F1-U
@{dldata_oveF1X2U_dlx2}
...    NRDRB-6:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRDRB-6:nsaDrbParam:initialDLTrafficRouting=initDLoverF1U
...    NRDRB-6:nsaDrbParam:dlPreferredPath=X2-U
*** Test Cases ***
5GSW-CP-Mobility_NSA_TDD_cmWave_with_CB008232-SR-A-B3_ET_08_01_DRB preemption at PDU session setup with maxNumOfNonGBRBearersSA resource reached
    [Documentation]
    ...    This case will include feature 5GC000572, 5GC001095, 5GC002199, CB008698, CB008232
    ...    verify Classical NSA TDD cmWave - intra+inter frequency intra-gNB HO with A3+A5 RSRP CBRA without SRB3.
    ...    5GSW-CP-Mobility_Classical_NSA_TDD_cmWave_intra_inter_freq_intra_inter_gNB_HO_with_A3_A5_RSRP_non_SRB3_is_successful
    ...    CB008232-SR-A-B3_ET_08_01_DRB preemption at PDU session setup with maxNumOfNonGBRBearersSA resource reached
    [Tags]    AP_REG    P3_REG
    OnlineParamChange    ${CB008232_A_B3_8}
    Set UE Parameters Before Register
    Clean Up AMF Param To Startup
    Clear Counter Files    wait=${False}
    Register HighPriorityAccess UE1 And UE2 With 5QI8-7 5QI8-9
    Ue31-34 Attach To Sim-eNB Then Setup ENDC And Send Traffic
    UE35 Attached And ENDC Setup Pvi
    Register HighPriorityAccess UE4 With 4PDU
    Trigger 4UE HO With Intra And Inter Freq A3 A5 Each Other With Traffic
    Check Counters    ${PM_Counters_Check}
    Release Ues    ue_type=all

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
    ${V_2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${V_2}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=3000
    ${V_3}    catenate
    ...    set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 daemon=10.0.2.1:22222 gnb_id=0x19:28 nssai=0x01:0xD143A5
    ...    x2_peers=none xn=10.0.1.126 amf=1
    Update Cfg    ${V_3}
    ${V_4}    catenate
    ...    set_cell id=1 gnb=4 pci=4:0 earfcn=39750:39750 tac=200 proxy=10.0.2.93:9999 nrci=0x1 tdd_cell=on bw=20MHz
    ...    technology=lte mandatory_for_activation=off
    Update Cfg    ${V_4}
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false
    Update Cfg    ue_param id=1-9 ue_nr_capabilities=${ue_nr_capabilities} ue_eutra_capabilities=${ue_eutra_capabilities}
    ${V_5}    catenate
    ...    ue_param id=31-35 ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    ...    ue_eutra_capabilities=${ue_eutra_capabilities}
    Update Cfg    ${V_5}

Set UE Parameters Before Register
    set UE history info    ue_id=1    history_id=1
    set UE history info    ue_id=2    history_id=1
    set UE history info    ue_id=3    history_id=1
    set UE history info    ue_id=4    history_id=1
    set UE history info    ue_id=5    history_id=1
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=GNB-3: XnAP Link with GNB-2
    Execute Egate Command    set_pdu_param ue=1-9 pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=1-9 pdu=2 trf_type=internal
    Execute Egate Command    ue_change_location id=1-9 enb=2 cell=1
set UE history info
    [Arguments]    ${ue_id}=1    ${history_id}=1
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...    ue_history_information_list_add_ngran id=${history_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command    ue_history_information_list id=${history_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=${history_id}

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${pass_regexp}=UE now in NG RM Regist    ${output_1}=1
    @{pass_regexp_expect}    Create List    ${pass_regexp}    ${output_1}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=${pass_regexp_expect}

UE Attach To ENB
    [Arguments]    ${ue_id}=35
    Execute Egate Command    ue_attach id=${ue_id}    pass_regexp=UE IS ACTIVE

Clean Up AMF Param To Startup
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_ue_pdu_setup_param id=1 reset
    Execute Egate Command    amf_ue_ics_param id=1 reset

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

UE PDU Session setup with multi QoS
    [Arguments]    ${add_QoS}=8    ${pdu}=1    ${ue_id}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=1    ${output}=1    ${output_1}=1
    ...    ${output_2}=crash
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${add_QoS}
    @{expect}    Create List    ${pass_regexp}
    ...    ${output_1}
    ...    ${output}
    @{expect2}    Create List    ${output_2}
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=${expect}    fail_regexp=${expect2}

UE Register with PA
    [Arguments]    ${ue_id}=1    ${estab_cause}=highPriorityAccess    ${pass_regexp}=UE now in NG RM Regist    ${output}=detached    ${output_1}=1
    ...    ${output_2}=1
    @{pass_regexp_expect}    Create List    ${pass_regexp}    ${output_1}    ${output_2}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${estab_cause}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    pass_regexp=${pass_regexp_expect}
    Execute egate command    ue_disp    fail_regexp=${output}

UE35 Attached And ENDC Setup Pvi
    UE Attach To ENB    ue_id=35
    Execute Egate Command    bearer_mod ue=35 id=2 priority=9 preemption=on vulnerability=on    pass_regexp=has been modified
    Execute Egate Command    enb_ue_dc_start ue=35 target_gnb=2 target_cells=1 bearer=2 type=split_scg    pass_regexp=reported successful RA

Register HighPriorityAccess UE1 And UE2 With 5QI8-7 5QI8-9
    Execute Egate Command    qosflow_modify default=on qos_flow=8 priority=8 pci=may_trigger_pre_emption pvi=pre_emptable
    UE Register with PA    ue_id=1    estab_cause=highPriorityAccess    output_1=establishmentCause highPriorityAccess
    ...    output_2=RRCEstablishmentCause : highPriorityAccess
    UE PDU Session setup with multi QoS    add_QoS=7    pdu=1    ue_id=1    nwslice=1    gw=1    pass_regexp=QoS Routing Table    output_2=IS IDLE
    UE Register with PA    ue_id=2    estab_cause=highPriorityAccess    output_1=establishmentCause highPriorityAccess
    ...    output_2=RRCEstablishmentCause : highPriorityAccess
    UE PDU Session setup with multi QoS    add_QoS=9    pdu=1    ue_id=2    nwslice=1    gw=2    pass_regexp=QoS Routing Table    output_2=IS IDLE

Register HighPriorityAccess UE4 With 4PDU
    Execute Egate Command    amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute Egate Command    ue_nr_rrc_setup_param id=4 establishment_cause=highPriorityAccess
    UE Register To GNB    ue_id=4
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    UE PDU Session setup with multi QoS    add_QoS=6    pdu=1    ue_id=4    nwslice=1    gw=4    pass_regexp=UE1: IS IDLE
    ...    output=release-due-to-pre-emption    output_1=QoS Routing Table    output_2=UE2: IS IDLE
    UE PDU Session setup with multi QoS    add_QoS=6,9    pdu=2    ue_id=4    nwslice=1    gw=5    pass_regexp=QoS Routing Table    output_2=IS IDLE
    UE PDU Session setup with multi QoS    add_QoS=6,9    pdu=3    ue_id=4    nwslice=1    gw=6    pass_regexp=radio-resources-not-available
    ...    output_2=IS IDLE
    UE PDU Session setup with multi QoS    add_QoS=6    pdu=4    ue_id=4    nwslice=1    gw=7    pass_regexp=QoS Routing Table    output_2=IS IDLE

Ue31-34 Attach To Sim-eNB Then Setup ENDC And Send Traffic
    Set X2 Gnb Link Up
    UE31-34 Attach To Sim-eNB And Establish EN-DC
    Send And Verify Throughput

Set X2 Gnb Link Up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

UE31-34 Attach To Sim-eNB And Establish EN-DC
    OnlineParamChange    ${dldata_oveF1U}
    Execute Egate Command    ue_attach id=31    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=31 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s
    OnlineParamChange  ${dldata_oveX2U}
    Execute Egate Command    ue_change_location id=32 enb=1 cell=2
    Execute Egate Command    ue_attach id=32    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=32 target_gnb=2 target_cells=2 bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s
    OnlineParamChange  ${dldata_oveF1X2U_dlf1}
    Execute Egate Command    ue_attach id=33    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=33 target_gnb=2 target_cells=3 bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s
    OnlineParamChange  ${dldata_oveF1X2U_dlx2}
    Execute Egate Command    ue_attach id=34    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=34 target_gnb=2 target_cells=3 bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s

Send And Verify Throughput
    Execute Egate Command    data_trf_start ue=31 id=2 dir=dl mbps=5 trf_id=1    UE 31: UDP DL
    Execute Egate Command    data_trf_start ue=31 id=2 dir=ul mbps=5 trf_id=2    UE 31: UDP UL
    Execute Egate Command    data_trf_start ue=32 id=2 dir=dl mbps=5 trf_id=1    UE 32: UDP DL
    Execute Egate Command    data_trf_start ue=32 id=2 dir=ul mbps=5 trf_id=2    UE 32: UDP UL
    Execute Egate Command    data_trf_start ue=33 id=2 dir=dl mbps=5 trf_id=1    UE 33: UDP DL
    Execute Egate Command    data_trf_start ue=33 id=2 dir=ul mbps=5 trf_id=2    UE 33: UDP UL
    Execute Egate Command    data_trf_start ue=34 id=2 dir=dl mbps=5 trf_id=1    UE 34: UDP DL
    Execute Egate Command    data_trf_start ue=34 id=2 dir=ul mbps=5 trf_id=2    UE 34: UDP UL
    Verify Throughput

Verify Throughput
    [Arguments]    ${sleep_time}=2s
    sleep    ${sleep_time}
    ${ul_Throughput_ue31}    Ap Get NSA Throughput    ue_id=31    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput_ue31}/1000>4.6
    ${dl_Throughput_ue31}    Ap Get NSA Throughput    ue_id=31    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_Throughput_ue31}/1000>4.6
    ${ul_Throughput_ue32}    Ap Get NSA Throughput    ue_id=32    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput_ue32}/1000>4.6
    ${dl_Throughput_ue32}    Ap Get NSA Throughput    ue_id=32    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${dl_Throughput_ue32}/1000>4.6
    ${ul_Throughput_ue33}    Ap Get NSA Throughput    ue_id=33    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput_ue33}/1000>4.6
    ${dl_Throughput_ue33}    Ap Get NSA Throughput    ue_id=33    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_Throughput_ue33}/1000>4.6
    ${ul_Throughput_ue34}    Ap Get NSA Throughput    ue_id=34    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput_ue34}/1000>4.6
    ${ul_Throughput_ue34}    Ap Get NSA Throughput    ue_id=34    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_Throughput_ue34}/1000>4.6

Trigger 4UE HO With Intra And Inter Freq A3 A5 Each Other With Traffic
    [Documentation]    Ue34 will sgNB modification fail due to NRCELL-1:maxNumOfSCellAlloc=2 and NRCELL-1:maxNumOfUsersPerCell=2
    ...    then trigger sgNB modification again after online modification them to 3.
    ${meas_id1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=31    carrierfreq=${carrierfreq1}    event_type=A3
    ${meas_id2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=32    carrierfreq=${carrierfreq1}    event_type=A5
    ${meas_id3}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=33    carrierfreq=${carrierfreq2}    event_type=A2
    ${meas_id4}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=34    carrierfreq=${carrierfreq2}    event_type=A2
    ${meas_id5}=    Trigger Inter Freq A2 Event    ue_id=33    measid=${meas_id3}    meas_freq=${carrierfreq1}    event_type=A3
    ${meas_id6}=    Trigger Inter Freq A2 Event    ue_id=34    measid=${meas_id4}    meas_freq=${carrierfreq1}    event_type=A5
    Execute Egate Command
    ...    ue_measurement_send_nr id=31 meas_id=${meas_id1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Modification Confirm
    Execute Egate Command
    ...    ue_measurement_send_nr id=32 meas_id=${meas_id2} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Modification Confirm
    Execute Egate Command
    ...    ue_measurement_send_nr id=33 meas_id=${meas_id5} event=A3 srsrp_nr=12 srsrq_nr=12 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Modification Confirm
    Execute Egate Command
    ...    ue_measurement_send_nr id=34 meas_id=${meas_id6} event=A5 srsrp_nr=13 srsrq_nr=13 phycell_id=50 nrsrp_nr=80 nrsrq_nr=30
    ...    fail_regexp=Sending SgNB Modification Confirm
    OnlineParamChange    ${sgnb_modification_parameter_for_ue34}
    Execute Egate Command
    ...    ue_measurement_send_nr id=34 meas_id=${meas_id6} event=A5 srsrp_nr=13 srsrq_nr=13 phycell_id=50 nrsrp_nr=80 nrsrq_nr=30
    ...    pass_regexp=Sending SgNB Modification Confirm
    Verify Throughput

Trigger Inter Freq A2 Event
    [Arguments]    ${ue_id}    ${measid}    ${meas_freq}    ${event_type}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7    pass_regexp=Sending SgNB Modification Confirm
    ${meas_id_ret}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${meas_freq}    event_type=${event_type}
    [Return]    ${meas_id_ret}


