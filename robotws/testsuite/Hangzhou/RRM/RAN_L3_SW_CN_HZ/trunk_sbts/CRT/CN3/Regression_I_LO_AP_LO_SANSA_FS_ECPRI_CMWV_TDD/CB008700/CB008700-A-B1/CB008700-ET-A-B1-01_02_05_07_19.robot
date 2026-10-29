*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-zijing.wu    release-SBTS00
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...      @{5GC000786}
...      @{CB006112-A}
...      @{5GC000704}
...      @{CB006112-C}
...      @{5GC000707_InterRAT}
...      @{5GC000784}
...      @{CB008700}

@{5GC000786}
...      NRCELL-1:actVoNR=true
...      NRDRB_5QI-1:fiveqiValueList=5
...      NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...      NRDRB_5QI-2:fiveqiValueList=6
...      NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...      NRDRB_5QI-3:fiveqiValueList=1
...      NRDRB_5QI-3:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...      NRDRB_5QI-5:fiveqiValueList=9
...      NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...      NRDRB_5QI-6:fiveqiValueList=7
...      NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-2
...      NRDRB_5QI-7:fiveqiValueList=3
...      NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...      NRDRB_5QI-8:fiveqiValueList=4
...      NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...      NRDRB_5QI-9:fiveqiValueList=128
...      NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-3
...      NRDRB-2:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...      NRDRB-2:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...      NRDRB-2:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...      NRDRB-2:dlFlowControlAlgo=none
...      NRDRB-2:rlcMode=RLC_UM
...      NRDRB-3:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...      NRDRB-3:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...      NRDRB-3:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...      NRDRB-3:resType=GBR
...      NRDRB-3:rlcMode=RLC_UM
...      NRDRB-3:maxDataRateGbrDl=1000
...      NRDRB-3:maxDataRateGbrUl=1000
...      NRDRB-3:l2OHFactorDl=16
...      NRDRB-3:l2OHFactorUl=35
...      NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...      NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
#...      NRDRB-3:queuingDelayDiscarding=Disabled
...      NRDRB_MAC-3:lcgid=4
...      NRDRB_MAC-3:delayTarget=50
...      NRDRB-3:dscp=46
...      NRDRB-2:discardTimer=infinity
...      NRDRB_PDCP-1:pdcpBufDiscardEnabled=false
...      NRDRB_PDCP-2:pdcpBufDiscardEnabled=false

@{CB006112-A}
...      NRCELL-1:actEnhancedVoNR=true
...      NRBTS:tRLFindForDUVoNR=2000ms
...      NRCELL-1:n310VoNR=n20
...      NRCELL-1:t310VoNR=4000ms
...      NRDRB-3:discardTimer=150ms
...      NRDRB-3:dlFlowControlAlgo=none
...      NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm6bitSN

@{CB006112-C}
...      NRCELL-1:actGBRAdmissionControl=EnhancedVoNR
...      NRCELL-1:maxNumOfGBRBearersSA=10
...      NRCELL-1:maxGBRTrafficLimit=50
...      NRCELL-1:addNumOfGBRBearers=0
...      NRCELL-1:actVoNrMobilityThresholds=VoNrMobilityThresholds
...      NRBTS:actInterFreqHoSA=true
...      NRCELL-1:a2MeashoEnabledSA=rsrpAndRsrq
...      NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=6|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=50|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=60|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=0|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresisHoSsbRsrqVoNr=6|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdHoSsbRsrqVoNr=30|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480|a2TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a1MeashoEnabledSA=rsrpAndRsrq
...      NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=6|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=70|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresisHoSsbRsrqVoNr=6|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=30|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdHoSsbRsrqVoNr=40|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480|a1TimeToTriggerHoSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=2|a3TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480|a3TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0|a3TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=3|a3TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=2|a3TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms480|a3TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrpAndRsrq
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=2|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=40|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=50|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=60|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms480|a5TimeToTriggerSsbRsrpVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=2|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=10|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=30|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms480|a5TimeToTriggerSsbRsrqVoNr=ms256
...      NRCELL-1/NRHOIF-1:cellDepType=SA
...      NRCELL-1/NRHOIF-1:chBw=20MHz
...      NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...      NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...      NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...      NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf5
...      NRCELL-1/NRHOIF-1:scs=15 KHz
...      NRCELL-1/NRHOIF-1:ssbFrequency=126530
...      XNLINK-1:cPlaneIpAddr=10.0.1.124
...      NRADJGNB-1:administrativeState=Unlocked
...      NRADJGNB-1:gNbIdLength=22
...      NRADJGNB-1:gNodeBId=35
...      NRADJGNB-1:xnLinkRef=1
...      NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...      NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...      NRADJNRCELL-2:cellDepType=SA
...      NRADJNRCELL-2:fiveGsTac=788
...      NRADJNRCELL-2:gNbId=35
...      NRADJNRCELL-2:gNbIdLength=22
...      NRADJNRCELL-2:lcrId=1
...      NRADJNRCELL-2:nrarfcn=126530
...      NRADJNRCELL-2:physCellId=49
...      NRADJNRCELL-2:gnbPlmn:mcc=311|mncLength=3
...      NRADJNRCELL-2:gnbPlmn:mnc=489|mncLength=3
...      NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...      NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...      NRCELL-1/NRREL-1:gNbId=35
...      NRCELL-1/NRREL-1:gNbIdLength=22
...      NRCELL-1/NRREL-1:lcrId=1
...      NRCELL-1/NRREL-1:removeNotAllowed=false
...      NRCELL-1/NRREL-1:gnbPlmn:mcc=311|mncLength=3
...      NRCELL-1/NRREL-1:gnbPlmn:mnc=489|mncLength=3

@{5GC000704}
...      NRBTS:actConflictConfiguration=true
...      NRBTS:actIntraFreqHoSA=true
...      NRPMRNL-1:miNrRelReportCu=5min
...      NRCELL-1:a3MeasEnabled=rsrp
...      NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...      NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...      NRCELL-1:filterCoeffSsbRsrp=fc4
...      NRCELL-1:absThreshSsbRsrpConsolidation=80
...      NRCELL-1:sMeasConfigSsbRsrp=20
...      NRBTS:actIncXn=true
...      XNLINK-10:cPlaneIpAddr=10.0.1.122
...      NRADJGNB-10:administrativeState=Unlocked
...      NRADJGNB-10:gNbIdLength=22
...      NRADJGNB-10:gNodeBId=36
...      NRADJGNB-10:xnLinkRef=10
...      NRADJGNB-10:gnbPlmn:mcc=311|mncLength=3
...      NRADJGNB-10:gnbPlmn:mnc=489|mncLength=3
...      NRADJNRCELL-1:cellDepType=SA
...      NRADJNRCELL-1:fiveGsTac=788
...      NRADJNRCELL-1:gNbId=36
...      NRADJNRCELL-1:gNbIdLength=22
...      NRADJNRCELL-1:lcrId=1
...      NRADJNRCELL-1:nrarfcn=636576
...      NRADJNRCELL-1:physCellId=48
...      NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...      NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...      delete:NRADJNRCELL-1:freqBandIndicatorNR
...      NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...      NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...      NRCELL-1/NRREL-10:gNbId=36
...      NRCELL-1/NRREL-10:gNbIdLength=22
...      NRCELL-1/NRREL-10:lcrId=1
...      NRCELL-1/NRREL-10:removeNotAllowed=false
...      NRCELL-1/NRREL-10:gnbPlmn:mcc=311|mncLength=3
...      NRCELL-1/NRREL-10:gnbPlmn:mnc=489|mncLength=3

@{5GC000707_InterRAT}
...      NRBTS:actInterRatHoSA=true
...      NRCELL-1:measGapSelectionSA=favourUeThroughput
...      NRHOIR-1:allowedMeasBandwidth=mbw50
...      NRHOIR-1:b2MeashoEnabled=rsrpAndRsrq
...      NRHOIR-1:b2Threshold1hoRsrp=35
...      NRHOIR-1:b2Threshold1hoRsrpVoNr=45
...      NRHOIR-1:b2Threshold1hoRsrq=50
...      NRHOIR-1:b2Threshold1hoRsrqVoNr=55
...      NRHOIR-1:earfcnValue=39750
...      NRHOIR-1:eutraFreqQOffsetRange=0dB
...      NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0|b2TimeToTriggerhoRsrpVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrpVoNr=4|b2TimeToTriggerhoRsrpVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18|b2TimeToTriggerhoRsrpVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrpVoNr=28|b2TimeToTriggerhoRsrpVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480|b2TimeToTriggerhoRsrpVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0|b2TimeToTriggerhoRsrqVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrqVoNr=4|b2TimeToTriggerhoRsrqVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2|b2TimeToTriggerhoRsrqVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrqVoNr=10|b2TimeToTriggerhoRsrqVoNr=ms512
...      NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480|b2TimeToTriggerhoRsrqVoNr=ms512
...      NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...      NRADJECELL-1:eNodeBId=38
...      NRADJECELL-1:ePSTrackingAreaCode=788
...      NRADJECELL-1:earfcnValue=39750
...      NRADJECELL-1:lcrId=1
...      NRADJECELL-1:physCellId=51
...      NRADJECELL-1:eUtraMultibandInfoList=41
...      NRADJECELL-1:ecgiPlmn:mcc=311|mncLength=3
...      NRADJECELL-1:ecgiPlmn:mnc=489|mncLength=3
...      NRADJECELL-1:enbPlmn:mcc=311|mncLength=3
...      NRADJECELL-1:enbPlmn:mnc=489|mncLength=3
...      NRCELL-1/NRRELE-1:cellIndividualOffset=0dB
...      NRCELL-1/NRRELE-1:eNodeBId=38
...      NRCELL-1/NRRELE-1:eutranCellExcluded=false
...      NRCELL-1/NRRELE-1:lcrId=1
...      NRCELL-1/NRRELE-1:ecgiPlmn:mcc=311|mncLength=3
...      NRCELL-1/NRRELE-1:ecgiPlmn:mnc=489|mncLength=3

${ue_nr_capabilities}    SEPARATOR=
#...      E1A01000074E5A031E000380A03C1260C8000868180C4034026010188E00D41B0A3582308682041F2804596C98AA1E04F90E7D033E238F18E
#...      7CC31E50B0381C3C17F0000001FC0000000500702A8D89BAC1194341020E0000194021EB608140838778E1C830E0008193C7C5FC0000007F0
#...      0000001401C00208389A00000000E140000000033134009850000280B0100940461FEAAAAA058060005038180703005807000603E01002000
#...      000010000020080000200B9537953581940204000025949410000196525040000A5949002D2AABA555540E28082C00AC160B000000100600C
#...      6AC4C0004080C1014181C202C4044484C648494989CA12986B40
...    E1A01000074E5A031E000383A000F04983200021A12006201A0130080C47006A0D851AC1184341020F941A00B2D931543C09F21CFA067C471E31
...    CF9863CA1607038782FE0000003F80000002E0000702A8D89BAC1194341020E00001941A007AD8205020E1DE38720C38002064F1F17F0000001F
...    C0000001700003800410713400000001C2800000000662680130A000150001602012808C3FD5555417001800140E0A00E06013003800301F0080
...    10000000080000100400001005CA9BCA9ACA8A0102000012CA4A080000CB29282000052CA480169555D2AAAA55142C00B002B0582C0000004018
...    031AB130001020304050607080B101112131921252627284A61AD0

${ue_nr_capabilities_19}    SEPARATOR=
#...      E1A01000074E5A031E000380A03C1260C8000868180C4034026010188E00D41B0A3582308682041F2804596C98AA1E04F90E7D033E238F18E
#...      7CC31E50B0381C3C17F0000001FC0000000500702A8D89BAC1194341020E0000194021EB608140838778E1C830E0008193C7C5FC0000007F0
#...      0000001401C00208389A00000000E140000000033134009850000280B0100940461FEAAAAA058060005038180703005807000603E01002000
#...      000010000020080000200B9537953581940204000025949410000196525040000A5949002D2AABA555540E28082C00AC160B000000100600C
#...      6AC4C0004080C1014181C202C4044484C648494989CA12986900
#...    E1A01000074E5A031E000380A03C1260C8000868180C4034026010188E00D41B0A3582308682041F2804596C98AA1E04F90E7D033E238F18E7CC
#...    31E50B0381C3C17F0000001FC0000000500702A8D89BAC1194341020E0000194021EB608140838778E1C830E0008193C7C5FC0000007F0000000
#...    1401C00208389A00000000E140000000033134009850000280B0100940461FEAAAAA058060005038180703005807000603E01002000000010000
#...    020080000200B9537953581940204000025949410000196525040000A5949002D2AABA555540E28082C00AC160B000000100600C6AC4C0004080
#...    C1014181C202C4044484C648494989CA12986900
...      E1A00000074E5A031E000380A03C1260C80008780818806804C020301C032A36146B04050D012CB2898087AD8202020E1DE38720C38002064F
...      1F57001FF001C007FC002A36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F57001FF001C007FC002A3626EB04050D012CB2
...      898087AD8202020E1DE38720C38002064F1F57001FF001C007FC002A36276B04050D012CB2898087AD8202020E1DE38720C38002064F1F5500
...      0005000000108389A00000000404D0301C020227B058060005038080E0600B00E000D07C0000000000001CA9A0002000012CB2A00695550103
...      800580000002004008D58980008101820283038405880889098C90929313942530D200

${V_1}    SEPARATOR=
...      E1A01000074E5A031E0003832001E0930640004342400C4034026010188E00D41B0A3582308682041F28240596C98AA1E04F90E7D033E238F18
...      E7CC31E50B0381C3C17F0000001FC000000130000E0551B11B582328682041C00003282403D6C10281070EF1C39061C00103278F8BF8000000F
...      E0000000980007000820E2300000000385000000000CC460026140001E001602012808C3FD5555413003000281C1401C0C026007000603E0100
...      2000000010000020080000200B9537953581940204000025949410000196525040000A5949002D2AABA555540E284802C00AC160B0000001006
...      00C6AC4C0004080C1014181C202C4044484C648494989CA12986B4

@{5GC000784}
...      NRCELL-1:arpPrioEmergencyCall=2
...      NRCELL-1:actEmergencyCall=true
...      NRCELL-1:emergencyCallRestrictions:emergencyCallMrListIgnore=true
...      NRCELL-1:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=true
...      NRBTS:timerXnDataFwdGuard=2000

@{Counters_Check_ET_02}
...      NRCELL-1:${NNGCC_PDUSESMODRSP_FAIL_SENT}=1
...      NRCELL-1:${NNGCC_PDUSESMOD_FAIL_EC_SENT}=0

${NNGCC_PDUSESMODRSP_FAIL_SENT}      M55125C03503
${NNGCC_PDUSESMOD_FAIL_EC_SENT}      M55125C05511

@{Counters_Check_ET_07_1}
...      NRCELL-1:${NNGCC_PDUSESMODRSP_FAIL_SENT}=0
...      NRCELL-1:${NNGCC_PDUSESMOD_FAIL_EC_SENT}=0

@{Counters_Check_ET_07_2}
...      NRCELL-1:${NNGCC_PDUSESMODRSP_FAIL_SENT}=1
...      NRCELL-1:${NNGCC_PDUSESMOD_FAIL_EC_SENT}=1

@{otherrelation}
...      NRCELL-1:gscnOrSsPbchArfcn=7880

@{CB008700}
...      NRCELL-1:actARPBasedAC=on
...      NRCELL-1:maxNumOfNonGBRBearersSA=5
...      NRCELL-1:maxNumOfGBRBearersSA=1

@{CB008700_19}
...      NRCELL-1:actARPBasedAC=on
...      NRCELL-1:maxNumOfNonGBRBearersSA=6
...      NRCELL-1:maxNumOfGBRBearersSA=1

*** Test Cases ***
CB008700-5G-A_5_ET_ICS with one PDU session with ARP based admission control including Invalid QoS Flow Identifier
    [Tags]
    Set UE Parameters Before Register
    Additional qosflows to activate    id=1    addition_qosflow=2,3
    UE Register To GNB      ue_id=1
    UE PDU Session setup    pdu=1    ue_id=1    nwslice=1    gw=1    pass_regexp=QoS Routing Table    output_1=Setup QosFlow with QFI:3
    Additional qosflows to activate    id=1    addition_qosflow=2,3,4
    UE Register To GNB      ue_id=2
    Execute Egate Command    amf_ue_ics_param id=1 action=multiple_qfi_error pdu=1
    UE PDU Session setup    pdu=1    ue_id=2    nwslice=1    gw=2    pass_regexp=Initial Context Setup Successful for UE
    ...    output_1=qosFlowIdentifier = 1 cause = RAN multiple qos flow ID instances    output_2=cause radioNetwork : not-supported-5QI-value
    Execute Egate Command    amf_ue_ics_param id=1 reset
    Deregister more than one UE    ue_id_1=1    ue_id_2=2
    Check Wireshark Log    ${CURDIR}${/}A2A_A-B1-05${/}a2a.ini

*** Keywords ***
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Reference UE
    [Arguments]    ${amf_id}=1    ${addition_qosflow}=2    ${ue_id}=1    ${pdu}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=1    ${output_1}=1
    Set UE Parameters Before Register
    Additional qosflows to activate    id=${amf_id}    addition_qosflow=${addition_qosflow}
    UE Register To GNB      ue_id=${ue_id}
    UE PDU Session setup    pdu=${pdu}    ue_id=${ue_id}    nwslice=${nwslice}    gw=${gw}    pass_regexp=${pass_regexp}    output_1=${output_1}

UE PDU Session setup
    [Arguments]    ${pdu}=1    ${ue_id}=1    ${nwslice}=1    ${gw}=1    ${pass_regexp}=1    ${output_1}=1    ${output_2}=1
    Start RRC Log    UE_PDU_SESSION_SETUP
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=${nwslice} gw=${gw}
    ...    pass_regexp=${pass_regexp}
    Should Contain    ${ret1}    ${output_1}
    Should Contain    ${ret1}    ${output_2}
    Get RRC Log

Additional qosflows to activate
    [Arguments]    ${id}=1    ${addition_qosflow}=1
    Execute Egate Command      smf_param id=${id} reset
    Execute Egate Command      smf_param id=${id} additional_qosflows_to_activate=${addition_qosflow}

Deregister more than one UE
    [Arguments]    ${ue_id_1}=1    ${ue_id_2}=2
    UE Deregister From GNB    ue_id=${ue_id_1}
    UE Deregister From GNB    ue_id=${ue_id_2}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri
    Execute Egate Command    trace_sim protocol=xn uec=1 amf=1 enb=3 on

Modify Cfg
    Update Cfg      set_qosflow id=1 5qi=7 default=on priority=7
    Update Cfg      set_qosflow id=3 5qi=9 priority=9
    Update Cfg      set_qosflow id=2 5qi=8 priority=8
    Update Cfg      set_qosflow id=4 5qi=3 priority=3
    Update Cfg      set_qosflow id=5 5qi=2 priority=3
    Update Cfg      set_qosflow id=6 5qi=1 priority=2
    Update Cfg      set_qosflow id=7 5qi=5 priority=2
    Update Cfg      set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg      set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg      set_nwslice id=1 qos_flows=3,2,1,4,5,6,7 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-5 amf=1
    Update Cfg      ue_nr_capabilities id=1-5 voice_over_nr=on:on:off
    Update Cfg      amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    Update Cfg      ue_param id=1-5 nr_usage_setting=voice_centric ue_nr_capabilities=${V_1}
    Update Cfg      set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg      set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg      set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    ${V_2}      catenate
    ...      set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222 x2_peers=none
    ...      xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg      ${V_2}
    Update Cfg      set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg      gnb_param id=3 xn_listening_socket=1 send_xn_setup=false

Set UE Parameters Before Register
    Execute Egate Command
    ...      ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...      ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command      ue_history_information_list id=1 action=commit
    Execute Egate Command      ue_enb_param id=1 ue_history_list=1
    Execute Egate Command      gnb_param id=3 xn_listening_socket=1 send_xn_setup=true measEvent=A3
    Execute Egate Command      gnb_xn_link_up gnb=3 target=2    GNB-3: XnAP Link with GNB-2
    Execute Egate Command      set_pdu_param ue=1,2 pdu=1 trf_type=internal
    Execute Egate Command      set_pdu_param ue=1,2 pdu=2 trf_type=internal
    Execute Egate Command
    ...      ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command
    ...      ue_history_information_list_add_ngran id=2 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    Execute Egate Command      ue_history_information_list id=2 action=commit
    Execute Egate Command      ue_enb_param id=2 ue_history_list=2
    Execute Egate Command      ue_change_location id=1 enb=2 cell=1

change UE location to GNB2 cell1
    Execute Egate Command      ue_change_location id=1 enb=2 cell=1

UE Register To GNB
    [Arguments]    ${ue_id}=1    ${ue_capabilities}=${ue_nr_capabilities}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capabilities}
    ...    UE now in NG RM Registe

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qosflows_to_add}=2
    Start RRC Log    PDU_Session_Modify_to_Add
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows_to_add} by=amf
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi 2
    Get RRC Log

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1
    Start RRC Log    PDU_Session_Modify_to_Del
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=2 by=amf
    ...    rrcReconfigurationComplete
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
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=${pdu} ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi_1} qfi 1
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${fiveQi_2} qfi 2
    Execute Egate Command    smf_param id=1 reset
    Get RRC Log

A2 measurement report
    [Arguments]    ${ue_id}=1    ${meas_id}=1
    Start RRC Log    A2_Measurement_Report
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=50 event=A2 srsrp_nr=50 srsrq_nr=30
    ...    rrcReconfigurationComplete
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    gapUE setup
    Get RRC Log

A1 measurement report
    [Arguments]    ${ue_id}=1    ${meas_id}=3
    Start RRC Log    A1_Measurement_Report
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=30
    ...    rrcReconfigurationComplete
    Should Contain    ${ret1}    gapUE release : NULL
    Get RRC Log

UE PDU Session Modify single QosFlow
    [Arguments]    ${ue_id}=1    ${pdu_1}=1    ${fiveQi}=5    ${qosflows_to_modify}=1    ${priority}=2
    Start RRC Log    PDU_Session_Modify_Single_QosFlow
    Execute Egate Command    qosflow_modify qos_flow=${qosflows_to_modify} priority=${priority}
    ${V_4}    catenate
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_1} qosflows_to_modify=${qosflows_to_modify}    by=amf
    ${ret1}=    Execute Egate Command    ${V_4}    pass_regexp=QosFlow modification failed for QFI:1
    Should Contain    ${ret1}    invalid-qos-combination
     sleep    5
    Get RRC Log
