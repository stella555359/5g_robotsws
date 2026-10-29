*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1    owner-pei.han    release-5G21A
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...  @{5GC000786}
...  @{CB006112-A}
...  @{5GC000704}
...  @{CB006112-C}
...  @{5GC000707_InterRAT}
@{5GC000786}
...  NRCELL-1:actVoNR=true

...  NRDRB_5QI-1:fiveqiValueList=5
...  NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-2:fiveqiValueList=6
...  NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB_5QI-3:fiveqiValueList=1
...  NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...  NRDRB_5QI-5:fiveqiValueList=9
...  NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...  NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...  NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-2:dlFlowControlAlgo=none
...  NRDRB-2:rlcMode=RLC_UM
...  NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...  NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...  NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...  NRDRB-3:resType=GBR
...  NRDRB-3:rlcMode=RLC_UM
...  NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...  NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...  NRDRB_MAC-3:lcgid=4
...  NRDRB-3:dscp=46
...  NRDRB-2:discardTimer=infinity
...  NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...  NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
@{CB006112-A}
...  NRCELL-1:actEnhancedVoNR=true
...  NRBTS:tRLFindForDUVoNR=2000ms
...  NRCELL-1:n310VoNR=n20
...  NRCELL-1:t310VoNR=4000ms
...  NRDRB-3:discardTimer=150ms
...  NRDRB-3:dlFlowControlAlgo=none
...  NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN
@{CB006112-C}
...  NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...  NRCELL-1:maxNumOfGBRBearersSA=10
...  NRCELL-1:maxGBRTrafficLimit=50
...  NRCELL-1:addNumOfGBRBearers=0
...  NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...  NRBTS:actInterFreqHoSA=true
...  NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...  NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...  NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...  NRCELL-1/NRHOIF-1:cellDepType=SA
...  NRCELL-1/NRHOIF-1:chBw=20MHz
...  NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...  NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...  NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...  NRCELL-1/NRHOIF-1:scs=15 KHz
...  NRCELL-1/NRHOIF-1:ssbFrequency=126530
...  XNLINK-1:cPlaneIpAddr=10.0.1.124
...  NRADJGNB-1:administrativeState=Unlocked
...  NRADJGNB-1:gNbIdLength=22
...  NRADJGNB-1:gNodeBId=35
...  NRADJGNB-1:xnLinkRef=1
...  NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...  NRADJNRCELL-2:cellDepType=SA
...  NRADJNRCELL-2:fiveGsTac=788
...  NRADJNRCELL-2:gNbId=35
...  NRADJNRCELL-2:gNbIdLength=22
...  NRADJNRCELL-2:lcrId=1
...  NRADJNRCELL-2:nrarfcn=126530
...  NRADJNRCELL-2:physCellId=49
...  NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-1:gNbId=35
...  NRCELL-1/NRREL-1:gNbIdLength=22
...  NRCELL-1/NRREL-1:lcrId=1
...  NRCELL-1/NRREL-1:removeNotAllowed=false
...  NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3
@{5GC000704}

...  NRBTS:actConflictConfiguration=true
...  NRBTS:actIntraFreqHoSA=true
...  NRPMRNL-1:miNrRelReportCu=5min
...  NRCELL-1:a3MeasEnabled=rsrp
...  NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:filterCoeffSsbRsrp=fc4
...  NRCELL-1:absThreshSsbRsrpConsolidation=80
...  NRCELL-1:sMeasConfigSsbRsrp=20
...  NRBTS:actIncXn=true
...  XNLINK-2:cPlaneIpAddr=10.0.1.122
...  NRADJGNB-2:administrativeState=Unlocked
...  NRADJGNB-2:gNbIdLength=22
...  NRADJGNB-2:gNodeBId=36
...  NRADJGNB-2:xnLinkRef=2
...  NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...  NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...  NRADJNRCELL-1:cellDepType=SA
...  NRADJNRCELL-1:fiveGsTac=788
...  NRADJNRCELL-1:gNbId=36
...  NRADJNRCELL-1:gNbIdLength=22
...  NRADJNRCELL-1:lcrId=1
...  NRADJNRCELL-1:nrarfcn=126290
...  NRADJNRCELL-1:physCellId=48
...  NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...  NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...  delete:NRADJNRCELL-1:freqBandIndicatorNR
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...  NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...  NRCELL-1/NRREL-10:gNbId=36
...  NRCELL-1/NRREL-10:gNbIdLength=22
...  NRCELL-1/NRREL-10:lcrId=1
...  NRCELL-1/NRREL-10:removeNotAllowed=false
...  NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3
@{5GC000707_InterRAT}
...  NRBTS:actInterRatHoSA=true
...  NRCELL-1:measGapSelectionSA=favourUeThroughput
...  NRHOIR-1:allowedMeasBandwidth=mbw50
...  NRHOIR-1:b2MeashoEnabled=rsrpAndRsrq
...  NRHOIR-1:b2Threshold1hoRsrp=35
...  NRHOIR-1:b2Threshold1hoRsrpVoNr=45
...  NRHOIR-1:b2Threshold1hoRsrq=50
...  NRHOIR-1:b2Threshold1hoRsrqVoNr=55
...  NRHOIR-1:earfcnValue=39750
...  NRHOIR-1:eutraFreqQOffsetRange=0dB
...  NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...  NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...  NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...  NRADJECELL-1:eNodeBId=38
...  NRADJECELL-1:ePSTrackingAreaCode=788
...  NRADJECELL-1:earfcnValue=39750
...  NRADJECELL-1:lcrId=1
...  NRADJECELL-1:physCellId=51
...  NRADJECELL-1:eUtraMultibandInfoList=41
...  NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3
...  NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3
...  NRADJECELL-1:enbPlmn:mcc=311|mncLength=3
...  NRADJECELL-1:enbPlmn:mnc=489|mncLength=3
...  NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...  NRCELL-1/NRRELE-1:eNodeBId=38
...  NRCELL-1/NRRELE-1:eutranCellExcluded=false
...  NRCELL-1/NRRELE-1:lcrId=1
...  NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...  NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3
${ue_nr_capabilities}
...  SEPARATOR=
...  E1A01000074E5A031E0003832001E0930640004342400C4034026010188E00D41B0A3582308682041F28240596C98AA1E04F90E7D033E238F18
...  E7CC31E50B0381C3C17F0000001FC000000130000E0551B11B582328682041C00003282403D6C10281070EF1C39061C00103278F8BF8000000F
...  E0000000980007000820E2300000000385000000000CC460026140001E001602012808C3FD5555413003000281C1401C0C026007000603E0100
...  2000000010000020080000200B9537953581940204000025949410000196525040000A5949002D2AABA555540E284802C00AC160B0000001006
...  00C6AC4C0004080C1014181C202C4044484C648494989CA12986B4
${V_1}
...  SEPARATOR=
...  E1A01000074E5A031E0003832001E0930640004342400C4034026010188E00D41B0A3582308682041F28240596C98AA1E04F90E7D033E238F18
...  E7CC31E50B0381C3C17F0000001FC000000130000E0551B11B582328682041C00003282403D6C10281070EF1C39061C00103278F8BF8000000F
...  E0000000980007000820E2300000000385000000000CC460026140001E001602012808C3FD5555413003000281C1401C0C026007000603E0100
...  2000000010000020080000200B9537953581940204000025949410000196525040000A5949002D2AABA555540E284802C00AC160B0000001006
...  00C6AC4C0004080C1014181C202C4044484C648494989CA12986B4

*** Test Cases ***
CB006112-ET-C-10_TDD RRC Reconfiguration with VoNr specific thresholds for for triggering handover measurement
    [Tags]
    UE Register To GNB
    UE PDU Session Setup    qos_flow_change=3    fiveQi=9
    UE PDU Session Modify to Add    qosflows_to_add=1    fiveQi=5
    UE PDU Session Setup with Multi Qosflow    gw=2    pdu=2
    UE PDU Session Modify Multi QosFlow
    UE Deregister From GNB
    Check RRC Log    ${CURDIR}${/}a2a_CB006112-ET-C-10${/}a2a.ini

CB006112-ET-C-11_GNB will remove voice specific measurement thresholds when Voice call release
    [Tags]
    UE Register To GNB
    UE PDU Session Setup
    A2 measurement report
    UE PDU Session Modify to Add
    UE PDU Session Modify to Del
    UE Deregister From GNB
    Check RRC Log    ${CURDIR}${/}a2a_CB006112-ET-C-11${/}a2a.ini

CB006112-ET-C-12_TDD Trigger A2 and A1 Measurement Report with voice specific measurement thresholds
    [Tags]
    UE Register To GNB
    UE PDU Session Setup with Multi Qosflow
    A2 measurement report
    A1 measurement report    meas_id=5
    UE PDU Session Modify to Del
    UE Deregister From GNB
    Check RRC Log    ${CURDIR}${/}a2a_CB006112-ET-C-12${/}a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fdd_sansa_cmwv/2cells    match_string=GNB-3: XnAP Link with GNB-2

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=9
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 qos_flows=3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-5 amf=1
    Update Cfg    ue_nr_capabilities id=1-5 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg    ue_param id=1-5 nr_usage_setting=voice_centric ue_nr_capabilities=${V_1}
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${V_2}  catenate  set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...  xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${V_2}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=135760:126380 gscn=1579
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
    ${V_3}  catenate  set_gnb id=4 type=simulated plmn=311:489 ng=10.0.1.125 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...  xn=10.0.1.124 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${V_3}
    Update Cfg    set_cell id=1 gnb=4 pci=16:1 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999 nr_arfcn=135760:126380 gscn=1582
    Update Cfg    gnb_param id=4 xn_listening_socket=1 send_xn_setup=false

UE Register To GNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}    UE now in NG RM Registered

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${gw}=1    ${fiveQi}=5    ${qos_flow_change}=1
    Start RRC Log    PDU_Session_Setup
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow_change} ue=${ue_id}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 1
    Execute Egate Command    qosflow_modify default=on qos_flow=1 ue=${ue_id}
    Get RRC Log

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qosflows_to_add}=2
    Start RRC Log    PDU_Session_Modify_to_Add
    ${ret1}=  Execute Egate Command  ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf
    ...  pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 2
    Get RRC Log

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Start RRC Log    PDU_Session_Modify_to_Del
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf    rrcReconfigurationComplete
    Should Contain    ${ret1}    Removed FiveQi:Qfi mapping fiveQi 1 qfi 2
    Get RRC Log

UE Deregister From GNB
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Qosflow_modify
    [Arguments]    ${qos_flow}=1    ${ue_id}=1
    Execute Egate Command    qosflow_modify default=on qos_flow=${qos_flow} ue=${ue_id}

UE PDU Session Setup with Multi Qosflow
    [Arguments]    ${additional_qosflows_to_activate}=2    ${fiveQi_1}=5    ${fiveQi_2}=1    ${ue_id}=1    ${gw}=1    ${pdu}=1
    Start RRC Log    PDU_Session_Setup_with_Multi_Qosflow
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${additional_qosflows_to_activate}
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    Execute Egate Command    smf_param id=1 reset
    Get RRC Log

UE PDU Session Modify Multi QosFlow
    [Arguments]    ${ue_id}=1    ${pdu_1}=1    ${fiveQi}=5    ${qosflows_to_del}=1    ${pdu_2}=2    ${qosflows_to_modify}=2
    Start RRC Log    PDU_Session_Modify_Multi_QosFlow
    Execute Egate Command    qosflow_modify qos_flow=2 priority=1
    ${V_4}  catenate  ue_pdu_session_modify ue=${ue_id} pdu=${pdu_1} qosflows_to_del=${qosflows_to_del} pdu=${pdu_2}
    ...  qosflows_to_modify=${qosflows_to_modify}  by=amf
    #    ${ret1}=    Execute Egate Command    ${V_4}    pass_regexp=QosFlow modification failed for QFI:2
    ${ret1}=    Execute Egate Command    ${V_4}    pass_regexp=handled successfully
    Should Contain    ${ret1}    PduId 1 Removed FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 2
    Should Not Contain    ${ret1}    measIdToRemoveList
    Should Not Contain    ${ret1}    measIdToAddModList
    Execute Egate Command    qosflow_modify qos_flow=2 priority=15
    Get RRC Log

A2 measurement report
    [Arguments]    ${ue_id}=1    ${meas_id}=1
    Start RRC Log    A2_Measurement_Report
    ${ret1}=  Execute Egate Command  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=50 event=A2 srsrp_nr=50 srsrq_nr=30
    ...  rrcReconfigurationComplete
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    gapUE setup
    Get RRC Log

A1 measurement report
    [Arguments]    ${ue_id}=1    ${meas_id}=3
    Start RRC Log    A1_Measurement_Report
    ${ret1}=  Execute Egate Command  ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=30
    ...  rrcReconfigurationComplete
    Should Contain    ${ret1}    gapUE release : NULL
    Get RRC Log
