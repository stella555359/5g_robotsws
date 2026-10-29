*** Settings ***
Documentation
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    owner-ying.5.chen    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP_P1
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{SNSSAI_TRACKINGAREA_PLMN}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_Cell1_A3_CBRA_RSRP_A1_A2_A5}
...    @{PARAMS_FOR_Cell2_A1_A2_A5_RSPR_CFRA_A3}
...    @{PARAMS_FOR_neighbourhood}
...    @{PARAMS_FOR_XN}
...    @{PARAMS_FOR_MultiFrequencyBand}
...    @{8281_enable}
...    NRCELL:bestCellWaitTimer=200
...    NRBTS:actMeasurementStrategy=cellQuality
@{PARAMS_IN_SWCONFIG}    0x600036=0

@{8281_enable}
...    NRCELL:actUlNrEcIdPosMethod=true
...    NRBTS:timerRRCGuard=2000
...    NRBTS:nrEcidMeasSupervisionTimer=2100

@{8281_disable}
...    NRCELL:actUlNrEcIdPosMethod=false

@{SNSSAI_TRACKINGAREA_PLMN}
...    SNSSAI-1:sst=1
...    SNSSAI-1:sd=13714341
...    SNSSAI-1:nrPlmnDNList=${NRPLMNDNLIST}
...    SNSSAI-2:sst=1
...    SNSSAI-2:sd=13714342
...    SNSSAI-2:nrPlmnDNList=${NRPLMNDNLIST}
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRPLMN-1:mcc=311
...    NRPLMN-1:mnc=489
...    NRPLMN-1:mncLength=3
${NRPLMNDNLIST}    MRBTS-1/NRBTS-1/NRPLMN-1


@{PARAMS_FOR_SECURITY}
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=3
...    NRBTS-1:cipherPrefL:nea2_128=6
...    NRBTS-1:cipherPrefL:nea3_128=9
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=3
...    NRBTS-1:integrityProtPrefL:nia2_128=6
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:actUplaneIntegrityProtection=SA

@{PARAMS_FOR_OTHERS}
...    NRBTS:drbInactivityTimerSA=60
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

@{PARAMS_FOR_Cell1_A3_CBRA_RSRP_A1_A2_A5}
...    MRBTS-1/NRBTS-1/NRCELL-1:nrarfcn=633364
...    MRBTS-1/NRBTS-1/NRCELL-1:gscnOrSsPbchArfcn=7845
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRBTS-1/NRCELL-1:cbraPreamblesPerSsb=n64      #CBRA
...    NRBTS-1/NRCELL-1:rsrpThresholdSSB=15
...    MRBTS-1/NRBTS-1/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrF1CD=5min
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRANS=5min

@{PARAMS_FOR_MultiFrequencyBand}
...    MRBTS-1/NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=true
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1:multiFreqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRCELL-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRSACU=15min
...    MRBTS-1/NRBTS-1/NRCELL-1:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    delete:MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1:nrMultibandInfoList

@{PARAMS_FOR_neighbourhood}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-1:lcrId=2
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=633408
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf3
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ssbFrequency=646656
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    MRBTS-1/NRBTS-1/NRCELL-1/NRHOIF-2:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbId=35
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:lcrId=1
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-2:nrarfcn=633372
...    MRBTS-1/NRBTS-1/NRCELL-2:gscnOrSsPbchArfcn=7847
...    MRBTS-1/NRBTS-1/NRCELL-2:actCDrx=false
...    MRBTS-1/NRBTS-1/NRCELL-2:gapOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-2:mgta=ms0dot5
...    MRBTS-1/NRBTS-1/NRCELL-2:reportIntervalSA=ms120
...    MRBTS-1/NRBTS-1/NRCELL-2:reportOnLeave=false
...    MRBTS-1/NRBTS-1/NRCELL-2:reportAmountSA=r4
...    MRBTS-1/NRBTS-1/NRCELL-2:ifhoSsbSmtcOffset=8
...    MRBTS-1/NRBTS-1/NRCELL-2:cbraPreamblesPerSsb=n60      #CFRA
...    NRBTS-1/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS-1/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:cellDepType=SA
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:ssbFrequency=633216
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:nrConnectModeProfileDN=MRBTS-1/NRBTS-1/NRCONNECTMODE_PROFILE-0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-2/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    NRBTS/NRCELL-2/NRREL-2:gNbId=35
...    NRBTS/NRCELL-2/NRREL-2:gNbIdLength=24
...    NRBTS/NRCELL-2/NRREL-2:lcrId=1
...    NRBTS/NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRBTS/NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRBTS/NRCELL-2/NRREL-2:gnbPlmn:mncLength=3

@{PARAMS_FOR_Cell2_A1_A2_A5_RSPR_CFRA_A3}
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=30
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=40
...    MRBTS-1/NRBTS-1/NRCELL-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms64
...    MRBTS-1/NRBTS-1/NRCELL-2:measGapSelectionSA=favourUeThroughput
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    MRBTS-1/NRBTS-1/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms64

@{PARAMS_FOR_XN}

...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    MRBTS-1/NRBTS-1/XNLINK-1:cPlaneIpAddr=10.0.1.124
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbId=35
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:lcrId=1
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:nrarfcn=633364
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:ssbFrequency=633216
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:physCellId=381
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRADJNRCELL-1:fiveGsTac=0
...    MRBTS-1/NRBTS-1/NRADJGNB-3:administrativeState=Unlocked
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNodeBId=35
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gNbIdLength=24
...    MRBTS-1/NRBTS-1/NRADJGNB-3:xnLinkRef=1
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mcc=311
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mnc=489
...    MRBTS-1/NRBTS-1/NRADJGNB-3:gnbPlmn:mncLength=3

@{reconfigurationWithSync_list}
...    reconfigurationWithSync
...    spCellConfigCommon
...    physCellId 50
...    downlinkConfigCommon
...    uplinkConfigCommon
...    newUE-Identity *
...    t304 ms2000
...    Intra-cell handover

@{A2_HO_successful_list}
...    measurementReport
...    measConfig
...    eventId eventA1
...    eventId eventA3
...    eventId eventA5
...    rcReconfigurationComplete

@{A5_HO_successful_list_CFRA}
...    eventId eventA2
...    CFRA
...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2

@{A5_HO_successful_list_CBRA}
...    eventId eventA2
...    CBRA
...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1

@{inter_gnb_inter_freq_SimCell_A2_HO_successful_list}
#...    gapOffset 8
...    mgl ms6
...    mgrp ms80
...    mgta ms0dot5
...    eventId eventA3

@{inter_gnb_inter_freq_SimCell_A3_HO_successful_list}
...    eventId eventA3
...    Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed
...    reconfigurationWithSync with physCellId 381 is present in masterCellGroup
...    CBRA

@{inter_gnb_inter_freq_RealCell_A3_HO_successful_list}
...    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.2 performed
...    CFRA
...    gapUE release : NULL

${SA_NGBR_DRB_REQ_SLICE}    M55149C00002    #CIT20
${SA_NGBR_DRB_SUCC_SLICE}    M55149C00003
${MEAS_PERIOD_NR_PDCP_SLICE}    M55328C00001
${PDCP_SDU_DATA_NUM_DL_SLICE}    M55328C00002
${PDCP_SDU_DATA_VOL_DL_SLICE}    M55328C00003
${PDCP_SDU_DATA_NUM_UL_SLICE}    M55328C00004
${PDCP_SDU_DATA_VOL_UL_SLICE}    M55328C00005
${SA_NGBR_DRB_CU_SUCC_SLICE}    M55149C00020
${NUMBER_OF_SA_SLICE_USERS}    M55149C00022
${NF1CC_UECTXT_STP_REQSENT}    M55113C01001
${NF1CC_UECTXT_STP_RESPRECD}    M55113C01002
${ATT_INTRA_CELL_HOS}    M55147C00003
${SUCC_INTRA_CELL_HOS}    M55147C00004
${NF1CD_UECTXT_STP_REQRECD}    M55117C01001
${SUCC_OG_INTER_GNB_HO_SA_PLMN}    M55145C00342
${SUCC_IC_INTER_GNB_HOP_SA_PLMN}    M55145C00361
${TOT_INTRA_FREQ_HO_DECISION_A3S}    M55147C00001
${NF1CD_UECTXT_REL_CMDRECD}    M55117C01009
${NF1CD_UECTXT_REL_CMPSENT}    M55117C01010
${ATT_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00550    #CIT023
${SUCC_IF_GNB_INTRA_DU_HO_SLICE}    M55149C00551
${ATT_IF_INTRA_DU_HO_SA_PLMN}    M55145C00321
${SUCC_IF_INTRA_DU_HO_SA_PLMN}    M55145C00322
${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}    M55145C00351    #CIT024
${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}    M55145C00352
${SUCC_IC_INTER_GNB_HO_SA_PLMN}    M55145C00362
${TOT_INTER_FREQ_HO_DECISION_A3}    M55147C00024
${ATT_IF_INTER_GNB_HO_SLICE}    M55149C00570
${SUCC_OG_IF_INTER_GNB_HO_SLICE}    M55149C00571
${NRRCC_MEAS_A2_REC}    M55124C02002
${NRPPA_MEASINIT_REQ_D}    M55125C00024
${NRPPA_MEASINIT_RESP_D}    M55125C00025
${NRPPA_MEASINIT_FAIL_NOTSUP_D}    M55125C00026

${LOOP}    3

@{PM_Counters_Check_CIT020_CIT23_CIT24_8281}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_REQ_SLICE}=3
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_REQ_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_SUCC_SLICE}=3
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_SUCC_SLICE}=1
...    last NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${MEAS_PERIOD_NR_PDCP_SLICE}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    last NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${MEAS_PERIOD_NR_PDCP_SLICE}=${60*${PM_COUNTER_INTERVAL[:-3]}}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_NUM_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_NUM_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_VOL_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_VOL_UL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_NUM_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_NUM_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${PDCP_SDU_DATA_VOL_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${PDCP_SDU_DATA_VOL_DL_SLICE}>0
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SA_NGBR_DRB_CU_SUCC_SLICE}=3
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${SA_NGBR_DRB_CU_SUCC_SLICE}=1
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${NUMBER_OF_SA_SLICE_USERS}=${3+2*${LOOP}}        #M55149C00022
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714342:${NUMBER_OF_SA_SLICE_USERS}=${1+${LOOP}}        #M55149C00022
...    ${NF1CC_UECTXT_STP_REQSENT}=${3+2*${LOOP}}     #M55113C01001
...    ${NF1CC_UECTXT_STP_RESPRECD}=${3+2*${LOOP}}      #M55113C01002
...    ${NF1CD_UECTXT_REL_CMDRECD}=${2*${LOOP}}       #M55117C01009
...    ${NF1CD_UECTXT_REL_CMPSENT}=${2*${LOOP}}       #M55117C01010
...    ${NF1CD_UECTXT_STP_REQRECD}=${3+2*${LOOP}}       #M55117C01001
...    ${SUCC_OG_INTER_GNB_HO_SA_PLMN}=${LOOP}
...    ${SUCC_IC_INTER_GNB_HOP_SA_PLMN}=${2*${LOOP}}     #M55145C00361
...    ${TOT_INTRA_FREQ_HO_DECISION_A3S}=${LOOP}
...    ${SUCC_INTRA_CELL_HOS}=${LOOP}
...    ${ATT_INTRA_CELL_HOS}=${LOOP}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${ATT_IF_GNB_INTRA_DU_HO_SLICE}=${2*${LOOP}}
...    NRBTS-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-13714341:${SUCC_IF_GNB_INTRA_DU_HO_SLICE}=${2*${LOOP}}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=${LOOP}
...    NRCELL-2/PLMN-PLMN/MCC-311/MNC-489:${ATT_IF_INTRA_DU_HO_SA_PLMN}=${LOOP}
...    NRCELL-1/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=${LOOP}
...    NRCELL-2/PLMN-PLMN/MCC-311/MNC-489:${SUCC_IF_INTRA_DU_HO_SA_PLMN}=${LOOP}
...    NRCELL-1:NRANS:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}==0    #0
...    NRCELL-1:NRANS:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}==0    #0
...    NRCELL-1:NRANS:${SUCC_IC_INTER_GNB_HO_SA_PLMN}==${LOOP}
...    NRCELL-1:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}==0     #0
...    NRCELL-2:NRANS:${ATT_OG_IF_INTER_GNB_HO_SA_PLMN}==${LOOP}    #0
...    NRCELL-2:NRANS:${SUCC_OG_IF_INTERGNB_HO_SA_PLMN}==${LOOP}    #0
...    NRCELL-2:NRANS:${SUCC_IC_INTER_GNB_HO_SA_PLMN}==${LOOP}
...    NRCELL-2:NMOCU:${TOT_INTER_FREQ_HO_DECISION_A3}==${LOOP}     #0
...    NRBTS-1:NSL:${ATT_IF_INTER_GNB_HO_SLICE}==${LOOP}
...    NRBTS-1:NSL:${SUCC_OG_IF_INTER_GNB_HO_SLICE}==${LOOP}
...    NRCELL-1:NRRCC:${NRRCC_MEAS_A2_REC}==${LOOP}
...    NRCELL-1:NNGCC:${NRPPA_MEASINIT_REQ_D}=8
...    NRCELL-1:NNGCC:${NRPPA_MEASINIT_RESP_D}=6
...    NRCELL-1:NNGCC:${NRPPA_MEASINIT_FAIL_NOTSUP_D}=2
...    NRCELL-2:NNGCC:${NRPPA_MEASINIT_REQ_D}=3
...    NRCELL-2:NNGCC:${NRPPA_MEASINIT_RESP_D}=2
...    NRCELL-2:NNGCC:${NRPPA_MEASINIT_FAIL_NOTSUP_D}=1

*** Test Cases ***
5GSW-CP-CIT020_Verify_Classical_SA_TDD_cmWave_intra-cell_inter-gNB_HO_A3_RSRP_CFRA_is_successful_TestCase
    [Documentation]
    ...    1. The purpose of this test case is to setup vonr call and check inter-frequency Intra-DU handover successful
    ...    2. Test Case Steps:
    ...         cell1 frequency: 633364, cell2 frequency:633372, cell3 frequency:646666, sim cell frequency: 633364
    ...                     ssb: 633216              ssb:633408         ssb:646656         ssb: 633216
    ...                          CBRA                  CFRA                CBRA            CFRA
    ...           pdu1_nwslice1(sd:13714341=d143a5)
    ...           pdu2_nwslice2(sd:13714342=d143a6)
    ...      case step:
    ...         a. UE1 set pdu1 with slice1, UE1 set pdu2 with slice2, UE2 set pdu1 with slice1, UE3 set pdu1 with slice1
        ...         b. check 3 UE's ECID when 8281 is enable, check 3 UE's ECID when 8281 is disable and enable the 8281 again
    ...         c. UE1 will use CBRA trigger inter-gnb intra-freq HO, form cell1 HO to sim cell, and from sim cell HO to Cell1
    ...         d. UE2 will use CFRA trigger intra-gnb inter-freq HO, form cell1 HO to cell2(Cell2 cellQuality higher than cell3),
    ...            and from cell2 HO to Cell1
    ...         e. UE3 will use CFRA trigger inter-gnb inter-freq HO, form cell2 HO to sim cell, and from sim cell HO to Cell2
        ...         f. check 3 UE's ECID when 8281 is enable
    ...         g. check conuter
    ...      case result:
    ...         a. UE1 pdu1 and pdu2 setup successful, UE2 and UE3 setup successful.
        ...         b. ECID can be got when 8281 is enable, ECID cannot be got when 8281 is disable
    ...         c. UE1 trigger inter-gnb intra-freq HO successful and traffic is ok
    ...         d. UE2 trigger intra-gnb inter-freq HO successful and traffic is ok
    ...         e. UE3 CFRA trigger inter-gnb inter-freq HO successful and traffic is ok
        ...         f. ECID can be got when 8281 is enable
    ...         g. check conuter is right
    [Tags]    D012    QC_47241
     Clear Counter Files    wait=${False}
     Prepare UE History Information
     UE Attach and check traffic
         E-CID Measurement request for 3 UE while 8281-Enable
         E-CID Measurement request for 3 UE while 8281-Disable
         OnlineParamChange    ${8281_enable}
     Inter-gNB Intra-freq HO A3 RSRP CBRA with SA UE
     Intra-gNB inter-freq HO A5 RSRP CBRA with SA UE    ue_id=2
     Inter-gNB inter-freq HO A3 RSRP CFRA with SA UE    ue_id=3
         E-CID Measurement request for 3 UE while 8281-Enable
         #Check Wireshark Log     ${CURDIR}/a2a_CIT024/a2a.ini    name=CIT024    wait_string=E-CIDMeasurementInitiationResponse::4
     Check Counters    ${PM_Counters_Check_CIT020_CIT23_CIT24_8281}
     Stop Traffic
     Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/3cells_ecpri    match_string=GNB-3: XnAP Link with GNB-2

Modify Cfg
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=1
    Update Cfg    set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 ue=1
    Update Cfg    set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
    Update Cfg    amf_param id=1 full_nas_auth=on nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    ${set_gnb2_cell1}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...     nr_arfcn=633364:633364 gscn=7845 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell1}
    ${set_gnb2_cell2}    catenate
    ...    set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=633372:633372 gscn=7847 mandatory_for_activation=off
    Update Cfg    ${set_gnb2_cell2}
     ${GNB2_CFG}    catenate    set_gnb id=2 type=external plmn=311:489 s1u=$GNB_S1U_ADDR
    ...    x2=$GNB_X2_ADDR:36422 ng=10.0.1.2 gnb_id=0x01:22 daemon=10.0.2.1:22222
    ...    xn=$GNB2_XN_ADDR x2_peers=none amf=1
    Update Cfg    ${GNB2_CFG}
    ${GNB3_CFG}    catenate    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:24
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124 nssai=0x1:0xd143a5,0x1:0xd143a6 amf=1
    Update Cfg    ${GNB3_CFG}
    Update Cfg    gnb_param id=3 xn_listening_socket=on send_xn_setup=false
    ${set_gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633364:633364
    ...    gscn=7845 mandatory_for_activation=off
    Update Cfg    ${set_gnb3_cell1}
    ${set_ue3}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=snow3g+zuc+aes nea=null+snow3g+zuc+aes
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 enb=2 cell=2 mode=nr
    Update Cfg    ${set_ue3}
    Update Cfg    set_lmf id=1 daemon=$SERVER_IP:$DAEMON_PORT nfId=abcdef01234567gh

UE Attach and check traffic
    UE Attach and check traffic by slice1    num=4    ue_id=1
    setup slices2 for PDU2 on UE1    ue_id=1    nwslice=2    pdu=2
    #Check Wireshark Log    ${CURDIR}/a2a_CIT020_2slice_CIT024_A2_measureGAP/a2a.ini    wait_string=UEContextModificationResponse::16

Inter-gNB Intra-freq HO A3 RSRP CBRA with SA UE
    Start To Capture Wireshark Log    Handover_2slice
    FOR    ${index}    IN RANGE    0    ${LOOP}
        Trigger inter-GNB intra-freq handover successful    ue_id=1    pdu1=1    pdu2=2
    END
    #Check Wireshark Log    ${CURDIR}/a2a_CIT020_HO_2slice/a2a.ini    name=Handover_2slice    wait_string=UEContextReleaseComplete::6

Prepare UE History Information
    Execute Egate Command    ue_change_location id=1-2 cell=1
    Execute Egate Command    ue_change_location id=3 cell=2
    Execute Egate Command    state_sim_disp
    Execute Egate Command    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3

UE Attach and check traffic by slice1
    [Arguments]    ${num}=3    ${ue_id}=1    ${pdu_id}=1    ${pass_regexp}=QoS Routing Table
    FOR    ${ue_id}    IN RANGE    ${ue_id}    ${num}
        Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
        Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
        Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1     pass_regexp=${pass_regexp}
        Send Throuput    ${ue_id}
        Verify Throughput    ${ue_id}
    END

setup slices2 for PDU2 on UE1
    [Arguments]    ${ue_id}=2    ${nwslice}=2    ${pdu}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu} nwslice=${nwslice} gw=2    pass_regexp=${pass_regexp}
    Send Throuput    ue_id=${ue_id}    pdu=${pdu}
    Verify Throughput    ue_id=${ue_id}    pdu=${pdu}

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=dl mbps=5 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu} qfi=1 dir=ul mbps=5 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${Tput_dl}=4    ${Tput_ul}=4    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger inter-GNB intra-freq handover successful
    [Arguments]    ${ue_id}=1    ${pdu1}=1    ${pdu2}=2
    Trigger UE from Cell1 to SIM Cell by A3
    Verify Throughput    ue_id=${ue_id}    pdu=${pdu1}
    Verify Throughput    ue_id=${ue_id}    pdu=${pdu2}
    Pre-conditions for UE HO back
    Trigger UE from SIM Cell to Cell1 by A3
    Verify Throughput    ue_id=${ue_id}    pdu=${pdu1}
    Verify Throughput    ue_id=${ue_id}    pdu=${pdu2}

Pre-conditions for UE HO back
    Execute Egate Command    ue_reauth id=1 nr_sec_cap=aes|aes
    Execute Egate Command    amf_path_switch_param id=1 include_ue_sec_cap=on
    Execute Egate Command    smf_param id=1 security_indication=path_switch:preferred:preferred max_data_rate=20mbps

Trigger UE from Cell1 to SIM Cell by A3
    [Arguments]    ${ue}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A3 srsrp_nr=11 phycell_id=381 nrsrp_nr=30
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1    timeout=20s
    Execute Egate Command    ue_disp state=ACTIVE    3.1

Trigger UE from SIM Cell to Cell1 by A3
    [Arguments]    ${ue}=1
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=633216    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50
     ...    nrsrp_nr=30 nrsrq_nr=30
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=${reconfigurationWithSync_list}
    Execute Egate Command    ue_disp state=ACTIVE    2.1

Intra-gNB inter-freq HO A5 RSRP CBRA with SA UE
    [Arguments]    ${ue_id}=2
    FOR    ${index}    IN RANGE    0    ${LOOP}
        Trigger UE from Cell1 to Cell2 by A2A5    ue_id=${ue_id}
        Verify Throughput    ue_id=${ue_id}
        Trigger UE from Cell2 to Cell1 by A2A5    ue_id=${ue_id}
        Verify Throughput    ue_id=${ue_id}
    END

Trigger UE from Cell1 to Cell2 by A2A5
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    Trigger UE A2A5 Measurement Report
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    execute_egate_command    ${A2_Event}    pass_regexp=${A2_HO_successful_list}
    should not contain    ${ret1}    eventIdeventA2
    ${measid2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=646656    event_type=A5
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A5
    ${A3_Event}    catenate    ue_schedule_measurement_send_nr id=${ue_id} action=SEND_IMMEDIATELY meas_id=${measid1} event=A5
     ...    srsrp_nr=10 srsrq_nr=10 phycell_id=51 nrsrp_nr=80 nrsrq_nr=81 meas_id=${measid2} event=A3 srsrp_nr=11 srsrq_nr=11
     ...    phycell_id=52 nrsrp_nr=30 nrsrq_nr=30
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=${A5_HO_successful_list_CFRA}
    should not contain    ${ret1}    CBRA

Trigger UE from Cell2 to Cell1 by A2A5
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    Trigger UE A2A5 Measurement Report
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    execute_egate_command    ${A2_Event}    pass_regexp=${A2_HO_successful_list}
    Should not Contain    ${ret1}    eventIdeventA2
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A5
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid1} event=A5 srsrp_nr=10 srsrq_nr=10 phycell_id=50
     ...    nrsrp_nr=60 nrsrq_nr=61
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=${A5_HO_successful_list_CBRA}
    should not contain    ${ret1}    CFRA

Inter-gNB inter-freq HO A3 RSRP CFRA with SA UE
    [Arguments]    ${ue_id}=3
    Start To Capture Wireshark Log    CIT024
    FOR    ${index}    IN RANGE    0    ${LOOP}
        Trigger UE from Cell2 to Sim Cell by A2A3    ue_id=${ue_id}
        Verify Throughput    ue_id=${ue_id}
        Trigger UE from Sim Cell to Cell2 by A2A3    ue_id=${ue_id}
        Verify Throughput    ue_id=${ue_id}
    END
#    Check Wireshark Log     ${CURDIR}/a2a_CIT024/a2a.ini    name=CIT024    wait_string=PathSwitchRequestAcknowledge::12

Trigger UE from Cell2 to Sim Cell by A2A3
    [Arguments]    ${ue_id}=1
    BuiltIn.Log    Trigger UE A2A3 Measurement Report
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 srsrp_nr=11 srsrq_nr=11
    ${ret1}=    execute_egate_command    ${A2_Event}    pass_regexp=${inter_gnb_inter_freq_SimCell_A2_HO_successful_list}
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633216    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=381
     ...    nrsrp_nr=30 nrsrq_nr=30
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=${inter_gnb_inter_freq_SimCell_A3_HO_successful_list}

Trigger UE from Sim Cell to Cell2 by A2A3
    [Arguments]    ${ue_id}=1
    ${measid1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=633408    event_type=A3
    ${A3_Event}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51
     ...    nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=    execute_egate_command    ${A3_Event}    pass_regexp=${inter_gnb_inter_freq_RealCell_A3_HO_successful_list}

Stop Traffic
    Execute Egate Command    trf_data_stop ue=1-3    pass_regexp=Traffic was stopped

E-CID Measurement request for 3 UE while 8281-Enable
    trigger E-CID Measurement Initiation request    ue_id=1    meas_qty=Cell-ID    tid=1
        trigger E-CID Measurement Initiation request    ue_id=1    meas_qty=Cell-ID,SS-RSRP    tid=2
        trigger E-CID Measurement Initiation request    ue_id=2    meas_qty=SS-RSRQ    tid=1
        trigger E-CID Measurement Initiation request    ue_id=3    meas_qty=Cell-ID,Timing_Advance_Type_1    tid=1

E-CID Measurement request for 3 UE while 8281-Disable
    OnlineParamChange    ${8281_disable}
    trigger E-CID Measurement Initiation request    ue_id=1    pass_regexp=Received ECID Measurement Failure
        trigger E-CID Measurement Initiation request    ue_id=2    pass_regexp=Received ECID Measurement Failure
        trigger E-CID Measurement Initiation request    ue_id=3    pass_regexp=Received ECID Measurement Failure
    #Check Wireshark Log    ${CURDIR}/a2a_CIT020_2slice_CIT024_A2_measureGAP/a2a.ini    wait_string=E-CIDMeasurementInitiationRequest::7

trigger E-CID Measurement Initiation request
    [Arguments]    ${ue_id}=1    ${meas_qty}=SS-RSRP    ${tid}=1    ${pass_regexp}=Received ECID Measurement Response
    ${cmd}    Catenate    lmf_send_ecid_meas_req id=1 ue=${ue_id} nrppa_transaction_id=${tid} lmf_ue_measurement_id=${tid}
    ...    report_characteristics=OnDemand meas_qty=${meas_qty}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    sleep    1s    #Deregister takes a certain amount of time to guarantee

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir
