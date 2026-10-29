*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    team-Beam    owner-tao.2.cui
...    CLOUD_5G_I_BOO_AP_LOO_SANSA_FS_ECPRI_CMWV_FDD+TDD    CRT    CB008120    release-SBTS23R1
...    STATE_CONFIGURED
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${ap_snssai_1}    0x01:0xD143A5
${ap_snssai_2}    0x01:0xD143A6
${ap_snssai_3}    0x03:0xD143A7
${ap_snssai_4}    0x04:0xFFFFFF
${ap_snssai_5}    0x00:0xD143A6
${ap_snssai_6}    0x42:0xFFFFFF
${ap_snssai_9}    0x63:0xD143A6
${ap_snssai_10}    0x7F:0xFFFFFF
${tc_nwslice_id_1}    9
${tc_nwslice_id_2}    10
${gnb3_snssai_1}    ${ap_snssai_9}
${gnb3_snssai_2}    ${ap_snssai_10}
${gbr_2}    72
${gbr_4}    76
${non_gbr_6}    6
${non_gbr_8}    8
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/L1B/6cells_4T2F
${snssaiDNList}    SEPARATOR=
...    MRBTS-1/NRBTS-1/SNSSAI-1,MRBTS-1/NRBTS-1/SNSSAI-2,MRBTS-1/NRBTS-1/SNSSAI-3,MRBTS-1/NRBTS-1/SNSSAI-4,
...    MRBTS-1/NRBTS-1/SNSSAI-5,MRBTS-1/NRBTS-1/SNSSAI-6,MRBTS-1/NRBTS-1/SNSSAI-7,MRBTS-1/NRBTS-1/SNSSAI-8,
...    MRBTS-1/NRBTS-1/SNSSAI-9,MRBTS-1/NRBTS-1/SNSSAI-10
@{PARAMS_IN_SCF}
...    @{Gnb_GBR}
...    @{CB008379}
...    @{CB008120}
...    @{5GC000704}
...    @{CB006112-C}
...    @{5GC000707_InterRAT}
...    @{ngho}
...    @{5GC000711}
...    @{VONR}
...    @{Intra_gNB_Intra_Freq_HO}
...    @{1094}
...    @{1095}
...    @{5GC002145}
...    @{NSA_Inter_Intra_MeNB_HO}
...    @{CA}
@{Gnb_GBR}

...    NRDRB_5QI-1:fiveqiValueList=5
...    NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-5
...    NRDRB_5QI-2:fiveqiValueList=${non_gbr_6}
...    NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-6
...    NRDRB_5QI-6:fiveqiValueList=7
...    NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...    NRDRB_5QI-4:fiveqiValueList=${non_gbr_8}
...    NRDRB_5QI-4:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-8
...    NRDRB_5QI-5:fiveqiValueList=129
...    NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-9
...    NRDRB_5QI-7:fiveqiValueList=3
...    NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRDRB_5QI-8:fiveqiValueList=${gbr_2}
...    NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB_5QI-9:fiveqiValueList=${gbr_4}
...    NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    NRDRB_5QI-10:fiveqiValueList=4
...    NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...    NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-2:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-2:rlcMode=RLC_AM
...    NRDRB-2:discardTimer=infinity
...    NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-3:resType=GBR
...    NRDRB-3:rlcMode=RLC_AM
...    NRDRB-3:maxDataRateGbrDl=30720
...    NRDRB-3:maxDataRateGbrUl=30720
...    NRDRB-3:l2OHFactorDl=16
...    NRDRB-3:l2OHFactorUl=35
...    NRDRB-3:discardTimer=50ms
...    NRDRB-3:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-3:maxRlcQueueingDelayGbr=20
...    NRDRB-3:maxTransferDelayGbr=20
...    NRDRB-3:queuingDelayDiscarding=Disabled
...    NRDRB-3:dscp=46
...    NRDRB-5:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRDRB-5:resType=nonGBR_Signaling
...    NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-10:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-10:resType=GBR
...    NRDRB-10:rlcMode=RLC_UM
...    NRDRB-10:maxDataRateGbrDl=30720
...    NRDRB-10:maxDataRateGbrUl=30720
...    NRDRB-10:l2OHFactorDl=16
...    NRDRB-10:l2OHFactorUl=35
...    NRDRB-10:discardTimer=50ms
...    NRDRB-10:dlFlowControlAlgo=none
...    NRDRB-10:maxRlcQueueingDelayGbr=20
...    NRDRB-10:maxTransferDelayGbr=20
...    NRDRB-10:queuingDelayDiscarding=Disabled
...    NRDRB-11:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRDRB-11:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-11:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-11:resType=GBR
...    NRDRB-11:rlcMode=RLC_AM
...    NRDRB-11:maxDataRateGbrDl=30720
...    NRDRB-11:maxDataRateGbrUl=30720
...    NRDRB-11:l2OHFactorDl=16
...    NRDRB-11:l2OHFactorUl=35
...    NRDRB-11:discardTimer=50ms
...    NRDRB-11:dlFlowControlAlgo=3gppFlowControl
...    NRDRB-11:maxRlcQueueingDelayGbr=20
...    NRDRB-11:maxTransferDelayGbr=20
...    NRDRB-11:queuingDelayDiscarding=Disabled
...    NRDRB_MAC-3:lcgid=5
...    NRDRB_MAC-3:delayTarget=50
...    NRDRB_MAC-3:schedulBSD=20ms
...    NRDRB_MAC-5:lcgid=0
...    NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRDRB_MAC-5:schedulPrio=12
...    NRDRB_MAC-5:schedulBSD=${EMPTY}
...    NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{CB008379}
...    NRCELL-1:actNonVoNRGbrService=true
...    NRCELL-2:actNonVoNRGbrService=true
...    NRCELL-1:actGBRAdmissionControl=GBRService
...    NRCELL-2:actGBRAdmissionControl=GBRService
@{CB008120}
...    NRBTS:actAdditionalSliceSupport=true
...    NRBTS/SNSSAI-2:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-2:sst=1
...    NRBTS/SNSSAI-2:sd=13714342
...    NRBTS/SNSSAI-2:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-2:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-3:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-3:sst=3
...    NRBTS/SNSSAI-3:sd=13714343
...    NRBTS/SNSSAI-3:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-3:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-4:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-4:sst=4
...    NRBTS/SNSSAI-4:sd=${EMPTY}
...    NRBTS/SNSSAI-4:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-4:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-5:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-5:sst=0
...    NRBTS/SNSSAI-5:sd=13714342
...    NRBTS/SNSSAI-5:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-5:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-6:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-6:sst=66
...    NRBTS/SNSSAI-6:sd=${EMPTY}
...    NRBTS/SNSSAI-6:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-6:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-7:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-7:sst=77
...    NRBTS/SNSSAI-7:sd=13714342
...    NRBTS/SNSSAI-7:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-7:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-8:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-8:sst=88
...    NRBTS/SNSSAI-8:sd=${EMPTY}
...    NRBTS/SNSSAI-8:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-8:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-9:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-9:sst=99
...    NRBTS/SNSSAI-9:sd=13714342
...    NRBTS/SNSSAI-9:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-9:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/SNSSAI-10:drbInactivityTimerSA=100
...    NRBTS/SNSSAI-10:sst=127
...    NRBTS/SNSSAI-10:sd=${EMPTY}
...    NRBTS/SNSSAI-10:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRBTS/SNSSAI-10:ngUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9
...    NRBTS/TRACKINGAREA-200:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10

@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=80
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
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
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=633000
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    XNLINK-2:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:gNodeBId=35
...    NRADJGNB-2:xnLinkRef=2
...    NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:fiveGsTac=788
...    NRADJNRCELL-2:gNbId=35
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=633000
...    NRADJNRCELL-2:physCellId=48
...    NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...    delete:NRADJNRCELL-2:freqBandIndicatorNR
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=36
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=1
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=35
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=1
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311|mncLength=3
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489|mncLength=3
@{CB006112-C}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...    NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
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
@{5GC002145}
...    NRBTS/TRACKINGAREA-788:fiveGsTac=788
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-1
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-2
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-3
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-4
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-5
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-6
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-7
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-8
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-9
...    NRBTS/TRACKINGAREA-788:snssaiList:snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10|snssaiDN=MRBTS-1/NRBTS-1/SNSSAI-10
@{ngho}
...    NRBTS:actIntraNrNgHo=sourceAndTarget
...    NRBTS:tNgRelocExecDeltN=3000
...    NRBTS:tNgRelocCancelN=2000
...    NRBTS:tNgRelocOverallN=2000
...    NRBTS:tNgRelocPrepN=2000
@{5GC000711}
...    NRBTS:actInterRatHoFromEutraToSA=true
...    NRBTS:nonContentRachAcFullConfigHo=false
...    NRBTS:tNgRelocExecDeltL=5000
@{VONR}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true

...    NRDRB_5QI-3:fiveqiValueList=1
...    NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-12
...    NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRDRB-12:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRDRB-12:resType=GBR
...    NRDRB-12:rlcMode=RLC_UM
...    NRDRB-12:maxDataRateGbrDl=30720
...    NRDRB-12:maxDataRateGbrUl=30720
...    NRDRB-12:l2OHFactorDl=16
...    NRDRB-12:l2OHFactorUl=35
...    NRDRB-12:queuingDelayDiscarding=Disabled
...    NRDRB-12:dscp=46
...    NRDRB-12:discardTimer=150ms
...    NRDRB-12:dlFlowControlAlgo=none
...    NRDRB-12:maxRlcQueueingDelayGbr=20
...    NRDRB-12:maxTransferDelayGbr=20
...    NRDRB_MAC-4:lcgid=4
...    NRDRB_MAC-4:delayTarget=50
...    NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
...    NRCELL-1:actEnhancedVoNR=true
...    NRCELL-2:actEnhancedVoNR=true
...    NRBTS:tRLFindForDUVoNR=2000ms
...    NRCELL-1:n310VoNR=n20
...    NRCELL-1:t310VoNR=4000ms
...    NRCELL-2:n310VoNR=n20
...    NRCELL-2:t310VoNR=4000ms
@{Intra_gNB_Intra_Freq_HO}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:timerXnDataFwdGuard=250
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-3:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-3:sMeasConfigSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrp:a3HysteresisSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    delete:MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1:sCellAdditionMethod
...    delete:MRBTS-1/NRBTS-1/NRCELL-3/NRREL-1:sCellOperationalMode
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:lcrId=4
...    NRCELL-3/NRREL-1:nrDcAllowed=false
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    MRBTS-1/NRBTS-1/NRCELL-4:a3MeasEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-4:sMeasConfigSsbRsrp=1
...    MRBTS-1/NRBTS-1/NRCELL-4:absThreshSsbRsrpConsolidation=1
...    MRBTS-1/NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3HysteresisSsbRsrp=10
...    MRBTS-1/NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    MRBTS-1/NRBTS-1/NRCELL-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:lcrId=3
...    delete:MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1:sCellAdditionMethod
...    delete:MRBTS-1/NRBTS-1/NRCELL-4/NRREL-1:sCellOperationalMode
@{1094}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRCELL-11:a3MeasEnabled=rsrp
...    NRCELL-11:a3MeasSsbRsrp:a3HysteresisSsbRsrp=20
...    NRCELL-11:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-11:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=20
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
@{1095}
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:tDCoverall=10000
...    NRBTS:timerX2UeProcGuard=15000
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=60
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=40
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=10
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRCELL-2:measGapSelection=favourUeThroughput
...    NRCELL-2:ifhoSsbSmtcOffset=0
...    NRBTS/NRADJNRCELL-3:cellDepType=NSA
...    NRBTS/NRADJNRCELL-3:gNbId=5
...    NRBTS/NRADJNRCELL-3:gNbIdLength=22
...    NRBTS/NRADJNRCELL-3:lcrId=1
...    NRBTS/NRADJNRCELL-3:nrarfcn=2071591
...    NRBTS/NRADJNRCELL-3:physCellId=384
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-3:gnbPlmn:mncLength=3
...    delete:NRBTS/NRADJNRCELL-3:freqBandIndicatorNR
...    NRCELL-2/NRHOIF-1:cellDepType=NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=261
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=2071387
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRREL-1:gNbId=5
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
@{NSA_Inter_Intra_MeNB_HO}
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraMeNBMobility=true
@{CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS/NRDU-1:actNonBfAndBfCa=true
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa
...    NRCELL-1:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=80
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=60
...    NRCELL-11:a1MeasPCellSwitchEnabled=none
...    NRCELL-11:a1MeasSCellAddEnabled=rsrp
...    NRCELL-11:a2MeasPCellSwitchEnabled=none
...    NRCELL-11:actK1Opt=intra-gNB
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=0ms
...    NRCELL-11:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=80
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=70
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL-11:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=60
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=10
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:deriveSsbIndexFromCell=true
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=80
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=60
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
@{OnlineParam}
...    NRCELL-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-788

*** Test Cases ***
CB008120_6_mix_bearer_Xn_HO_in_intra_registration_area_when_all_slices_consistent
    [Documentation]
    ...    The purpose of this test case is to verify Xn based handover
    ...    with Slice configured with standarized SST value from new range
    ...    Step1: ue register
    ...    Step2: Add QoS Flow
    ...    Step3: PDU Setup
    ...    Step4: Add QoS Flow
    ...    Step5: Xn Based Handover Out
    ...    Step6: Xn Based Handover In
    ...    Step7: Send and Verify Throughput
    [Tags]    QC_217660    owner-tao.2.cui
    onlineParamChange    @{OnlineParam}
    Inter-gNB Handover Prepare    ho_type=xn_based
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=${tc_nwslice_id_1}    gw_id=1
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=5
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=2
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=6
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=3    send_dl=10    send_ul=10    sleep_time=20s
    PDU Setup QoSFlow    ue_id=81    pdu_id=2    nwslice_id=${tc_nwslice_id_2}    gw_id=2
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=8
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=9
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=2    send_dl=10    send_ul=10    sleep_time=20s
    TC06 Inter-gNB Handover Out
    TC06 Inter-gNB Handover In
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=2    send_dl=10    send_ul=10    sleep_time=20s
    UE Deregister From gNB    ue_id=81

CB008120_9_mixGBR_bearer_NG_HO_when_all_slices_consistent
    [Documentation]
    ...    The purpose of this test case is to verify NG based handover
    ...    with Slice configured with standarized SST value from new range
    ...    The purpose of this test case is to verify Xn based handover
    ...    with Slice configured with standarized SST value from new range
    ...    Step1: ue register
    ...    Step2: Add QoS Flow
    ...    Step3: PDU Setup
    ...    Step4: Add QoS Flow
    ...    Step5: Ng Based Handover Out
    ...    Step6: Ng Based Handover In
    ...    Step7: Send and Verify Throughput
    [Tags]    QC_219007    owner-tao.2.cui
    Inter-gNB Handover Prepare    ho_type=ng_based
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=${tc_nwslice_id_1}    gw_id=1
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=5
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=4
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=6
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=3    send_dl=10    send_ul=10    sleep_time=20s
    PDU Setup QoSFlow    ue_id=81    pdu_id=2    nwslice_id=${tc_nwslice_id_2}    gw_id=2
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=8
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=9
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=2    send_dl=10    send_ul=10    sleep_time=20s
    TC09 Inter-gNB Handover Out
    TC09 Inter-gNB Handover In
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=2    send_dl=10    send_ul=10    sleep_time=20s
    UE Deregister From gNB    ue_id=81

CB008120_3_mix_bearer_PDU_Session_setup_with_mix_SD
    [Documentation]
    ...    The purpose of this test case is to verify creating Slice with
    ...    standarized SST value from new range successful
    ...    Step1: ue register
    ...    Step2: Add QoSFlow
    ...    Step3: PDU Setup
    ...    Step4: Add QoSFlow
    ...    Step5: Send and Verify Throughput
    [Tags]    QC_217626    owner-tao.2.cui
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=3    gw_id=1
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=5
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=1
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=6
    PDU Add QoSFlow    ue_id=81    pdu_id=1    qfi_id=8
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=2    send_dl=10    send_ul=10    sleep_time=20s
    PDU Setup QoSFlow    ue_id=81    pdu_id=2    nwslice_id=4    gw_id=2
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=8
    PDU Add QoSFlow    ue_id=81    pdu_id=2    qfi_id=9
    Send And Verify Throuput    ue_id=81    pdu_id=2    qfi_id=3    send_dl=10    send_ul=10    sleep_time=20s
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log    ${CURDIR}${/}a2a_03_06_09${/}a2a.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=1 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=2 5qi=${gbr_2} gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=${gbr_4} gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5
    Update Cfg    set_qosflow id=6 5qi=${non_gbr_6}
    Update Cfg    set_qosflow id=7 5qi=7 default=on priority=7
    Update Cfg    set_qosflow id=8 5qi=${non_gbr_8}
    Update Cfg    set_qosflow id=9 5qi=129
    Update Cfg    set_qosflow id=10 5qi=4 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_1} default=on ue=all amf=1
    Update Cfg    set_nwslice id=2 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_2} default=off ue=all amf=1
    Update Cfg    set_nwslice id=3 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_3} default=off ue=all amf=1
    Update Cfg    set_nwslice id=4 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_4} default=off ue=all amf=1
    Update Cfg    set_nwslice id=5 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_5} default=off ue=all amf=1
    Update Cfg    set_nwslice id=6 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_6} default=off ue=all amf=1
    Update Cfg    set_nwslice id=9 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_9} default=off ue=all amf=1
    Update Cfg    set_nwslice id=10 qos_flows=10,9,8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=${ap_snssai_10} default=off ue=all amf=1
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=6 ue_nat_ip=72.23.5.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=7 ue_nat_ip=72.23.6.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=8 ue_nat_ip=72.23.7.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=9 ue_nat_ip=72.23.8.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=10 ue_nat_ip=72.23.9.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=11 ue_nat_ip=72.23.10.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=12 ue_nat_ip=72.23.11.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=13 ue_nat_ip=72.23.12.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=14 ue_nat_ip=72.23.13.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=15 ue_nat_ip=72.23.14.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${gnb_3}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22
    ...    daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.122 nssai=${gnb3_snssai_1},${gnb3_snssai_2} amf=1
    Update Cfg    ${gnb_3}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false sib1_period=3000
    ${gnb3_cell1}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=633000:633000 gscn=7840
    Update Cfg    ${gnb3_cell1}
    ${gnb4_cell1}    catenate
    ...    set_cell id=1 gnb=4 pci=127:0 tac=788 nrci=0x01
    ...    tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=633000:633000 gscn=7840
    Update Cfg    ${gnb4_cell1}
    ${gnb_5}    catenate
    ...    set_gnb id=5 s1u=10.0.1.129 plmn=311:489 gnb_id=0x5 type=simulated
    ...    daemon=10.0.2.1:22222 x2=10.0.1.128:36422 x2_peers=none
    Update Cfg    ${gnb_5}
    Update Cfg    gnb_param id=5 x2_listening_socket=1 measEvent=A3
    Update Cfg    gnb_endc_param id=5 use_nr_ran_cont=true scg_dl_dist_percent=0 enable_dud_poll_bit=0
    ${gnb5_cell1}    catenate
    ...    set_cell id=1 gnb=5 tac=3 pci=128:0 proxy=10.0.2.1:12221|10.0.2.1:8891 nrci=0x1
    ...    nr_arfcn=2071591:2071591 tdd_cell=on gscn=22446 mandatory_for_activation=off
    Update Cfg    ${gnb5_cell1}
    ${gnb_6}    catenate
    ...    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.127 daemon=10.0.2.1:22222 gnb_id=0x19:28
    ...    nssai=0x01:0xD143A5 x2_peers=none xn=10.0.1.126 amf=1
    Update Cfg    ${gnb_6}
    Update Cfg    gnb_param id=6 xn_listening_socket=1 send_xn_setup=false
    ${gnb6_cell1}    catenate
    ...    set_cell id=1 gnb=6 pci=4:0 earfcn=39750:39750 tac=200 proxy=10.0.2.93:9999 nrci=0x1
    ...    tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off
    Update Cfg    ${gnb6_cell1}
    ${enb_11}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.140 enb_id_macro=0x12347
    ...    daemon=10.0.2.1:22222 x2=10.0.1.141 x2u=10.0.1.142 type=simulated x2_peers=none
    Update Cfg    ${enb_11}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    Update Cfg    enb_endc_param id=11 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    ${enb11_cell1}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:0 tac=222 proxy=10.0.2.1:12217|10.0.2.1:8887
    ...    earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off
    Update Cfg    ${enb11_cell1}

onlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

SA UE Attach
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}    Initial Context Setup Successful

PDU Setup QoSFlow
    [Arguments]    ${ue_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=${nwslice_id} gw=${gw_id}    Setup QosFlow with QFI

PDU Add QoSFlow
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qfi_id} by=amf    QoS Routing Table

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${sleep_time}=20s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=${send_ul}
    Verify Throuput    ${ue_id}    ${pdu_id}    ${qfi_id}    ${send_dl}*0.9    ${send_ul}*0.9    ${sleep_time}

Inter-gNB Handover Prepare
    [Arguments]    ${gnb}=3    ${ho_type}=xn_based
    Execute Egate Command    gnb_param id=3 sa_ho=xn_based

TC09 Inter-gNB Handover Out
    ${TC09_cmd_1}    catenate
    ...    ue_measurement_send_nr id=81 meas_id=3 event=A3 srsrp_nr=50 phycell_id=48
    ...    nrsrp_nr=90 nrsrq_nr=34
    Execute Egate Command     ${TC09_cmd_1}    PATH SWITCH REQUEST ACK

TC09 Inter-gNB Handover In
    ${TC09_cmd_2}    catenate
    ...    ue_measurement_send_nr id=81 meas_id=3 event=A3 srsrp_nr=50
    ...    phycell_id=50 nrsrp_nr=90 nrsrq_nr=34
    Execute Egate Command    ${TC09_cmd_2}    Received UE Radio Capability

TC06 Inter-gNB Handover Out
    ${TC06_CMD01}    catenate
    ...    ue_measurement_send_nr id=81 meas_id=3 event=A3 srsrp_nr=50
    ...    phycell_id=48 nrsrp_nr=90 nrsrq_nr=34
    Execute Egate Command    ${TC06_CMD01}    PATH_SWITCH_REQUEST_ACK Received

TC06 Inter-gNB Handover In
    ${TC06_CMD02}    catenate
    ...    ue_measurement_send_nr id=81 meas_id=3 event=A3 srsrp_nr=50
    ...    phycell_id=50 nrsrp_nr=90 nrsrq_nr=34
    Execute Egate Command    ${TC06_CMD02}    PATH SWITCH REQUEST ACK
