*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT
...    owner-ying.5.chen    team-SG2    release-5G20B    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${UE1_Capabilities}    SEPARATOR=
...    E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C0010327
...    8FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B1375820286809659
...    44C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FAA80
...    00028000000841C4D00000000202682807008089FEAAAAA058060005038180703005807000683E0000000000000E54D000100000965950034A
...    AA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B40

${UE2_Capabilities}    SEPARATOR=
...    E1A01000074E5A031E000380A03C1260C8000878180C4034026010180E01951B0A3582028680965944C043D6C10101070EF1C39061C001032
...    78FAB80027800E0009E00151B133582028680965944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13758202868096
...    5944C043D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C043D6C10101070EF1C39061C00103278FA
...    A8000028000001041C4D0000000070A000000001809B00A014058080440230FF5555502C03000281C040703005807000683E0000000000000
...    E54D000100000965950034AAA8081C002C00000010020046AC4C0004080C1014181C202C4044484C648494989CA12986B4

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_5QI9}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_5QI2}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_FOR_A5}
...    @{PARAMS_FOR_A1}
...    @{PARAMS_FOR_A2}
...    @{PAPAMS_FOR_XN}
...    @{PAPAMS_FOR_IntraRAT}

@{PARAMS_FOR_5QI9}
...    NRBTS/NRDRB_5QI-5:fiveqiValueList=9
...    NRBTS/NRDRB_5QI-5:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-14
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-14:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-14:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-14:resType=nonGBR
...    NRBTS/NRDRB-14:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-2:lcgid=2
...    NRBTS/NRDRB_MAC-2:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-2:duFlowControlProfId=1

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulPrio=4

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=true
...    NRCELL-2:actVoNR=true
...    NRBTS:actNormVCFallback=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=46
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB_PDCP-3:tReorderingDl=ms300
...    NRBTS/NRDRB_PDCP-3:tReorderingUl=ms300
...    NRBTS/NRDRB_PDCP-3:pdcpBufDiscardEnabled=false

@{PARAMS_FOR_5QI2}
...    NRBTS/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-16:dscp=46
...    NRBTS/NRDRB-16:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:numSduDiscard=1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-16:resType=nonGBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    MNRBTS/NRDRB-16:schedulWeight=24
...    NRBTS/NRDRB-16:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=128
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-4:schedulPrio=4

@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=1
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=9
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9

@{PARAMS_FOR_OTHERS}


...    NRBTS:drbInactivityTimerSA=60
...    MRBTS-1/NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

@{PARAMS_FOR_A3}
...    NRBTS/NRCELL-1:a3MeasEnabled=rsrq
...    NRBTS/NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL-1:absThreshSsbRsrqConsolidation=1
...    NRBTS/NRCELL-1:sMeasConfigSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=2
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS/NRCELL-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRBTS/NRCELL-2:actVoNR=true
...    NRBTS/NRCELL-2:a3MeasEnabled=rsrq
...    NRBTS/NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRBTS/NRCELL-2:absThreshSsbRsrqConsolidation=1
...    NRBTS/NRCELL-2:sMeasConfigSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRBTS/NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRBTS/NRCELL-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-2:measGapSelectionSA=favourUeThroughput

@{PARAMS_FOR_A5}
...    NRBTS/NRCELL-1:a5MeasEnabled=rsrq
...    NRBTS/NRCELL-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS/NRCELL-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=11
...    NRBTS/NRCELL-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    NRBTS/NRCELL-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-1/NRREL-1:gNbId=1
...    NRBTS/NRCELL-1/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-1:lcrId=2
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRBTS/NRCELL-1/NRREL-2:gNbId=35
...    NRBTS/NRCELL-1/NRREL-2:gNbIdLength=22
...    NRBTS/NRCELL-1/NRREL-2:lcrId=1
...    NRBTS/NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRBTS/NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRBTS/NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRBTS/NRCELL-2:a5MeasEnabled=rsrq
...    NRBTS/NRCELL-2:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS/NRCELL-2:a5MeasSsbRsrq:a5Threshold1SsbRsrq=11
...    NRBTS/NRCELL-2:a5MeasSsbRsrq:a5Threshold2SsbRsrq=20
...    NRBTS/NRCELL-2:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRBTS/NRCELL-2/NRREL-1:gNbId=1
...    NRBTS/NRCELL-2/NRREL-1:gNbIdLength=22
...    NRBTS/NRCELL-2/NRREL-1:lcrId=1
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRBTS/NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{PARAMS_FOR_A1}
...    NRBTS/NRCELL-1:a1MeashoEnabledSA=rsrqCombined
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-1:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-1:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-1:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480
...    NRBTS/NRCELL-2:a1MeashoEnabledSA=rsrqCombined
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRBTS/NRCELL-2:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-2:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms480

@{PARAMS_FOR_A2}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS/NRCELL-1:a2MeashoEnabledSA=rsrqCombined
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-1:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480
...    NRBTS/NRCELL-2:a2MeashoEnabledSA=rsrqCombined
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRBTS/NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=31
...    NRBTS/NRCELL-2:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms480

@{PAPAMS_FOR_XN}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIncXn=true
...    NRBTS/NRADJGNB-3:administrativeState=Unlocked
...    NRBTS/NRADJGNB-3:gNodeBId=35
...    NRBTS/NRADJGNB-3:gNbIdLength=22
...    NRBTS/NRADJGNB-3:xnLinkRef=3
...    NRBTS/NRADJGNB-3:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-3:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-3:gnbPlmn:mncLength=3
...    NRBTS/XNLINK-3:cPlaneIpAddr=10.0.1.124
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:gNbId=35
...    NRBTS/NRADJNRCELL-1:nrarfcn=636666
...    NRBTS/NRADJNRCELL-1:physCellId=381
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22

@{PAPAMS_FOR_IntraRAT}
...    NRBTS:actInterRatHoSA=true
...    NRBTS:actMFBIEutra=true
...    NRBTS:excludedEutranCellPeriod=10
...    NRBTS:excludedEutranCellThreshold=5
...    NRBTS:excludedEutranCellTimeWindow=10
...    NRBTS/NRCELL-2:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    NRBTS/NRCELL-2/NRRELE-1:cellIndividualOffset=0dB
...    NRBTS/NRCELL-2/NRRELE-1:eNodeBId=18
...    NRBTS/NRCELL-2/NRRELE-1:eutranCellExcluded=false
...    NRBTS/NRCELL-2/NRRELE-1:lcrId=1
...    NRBTS/NRCELL-2/NRRELE-1:ecgiPlmn:mcc=311
...    NRBTS/NRCELL-2/NRRELE-1:ecgiPlmn:mnc=489
...    NRBTS/NRCELL-2/NRRELE-1:ecgiPlmn:mncLength=3
...    NRBTS/NRHOIR-1:allowedMeasBandwidth=mbw50
...    NRBTS/NRHOIR-1:b2MeashoEnabled=rsrq
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrp=35
...    NRBTS/NRHOIR-1:b2Threshold1hoRsrq=50
...    NRBTS/NRHOIR-1:earfcnValue=1400
...    NRBTS/NRHOIR-1:eutraFreqQOffsetRange=0dB
...    NRBTS/NRHOIR-1:presenceAntennaPort1=false
...    NRBTS/NRHOIR-1:reportAmount=r8
...    NRBTS/NRHOIR-1:reportInterval=ms240
...    NRBTS/NRHOIR-1:widebandRsrqMeas=true
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=18
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms480
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    NRBTS/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms480
...    NRBTS/NRADJECELL-1:eNodeBId=18
...    NRBTS/NRADJECELL-1:ePSTrackingAreaCode=100
...    NRBTS/NRADJECELL-1:earfcnValue=1400
...    NRBTS/NRADJECELL-1:lcrId=1
...    NRBTS/NRADJECELL-1:physCellId=11
...    NRBTS/NRADJECELL-1:eUtraMultibandInfoList=3
...    NRBTS/NRADJECELL-1:ecgiPlmn:mcc=311
...    NRBTS/NRADJECELL-1:ecgiPlmn:mnc=489
...    NRBTS/NRADJECELL-1:ecgiPlmn:mncLength=3
...    NRBTS/NRADJECELL-1:enbPlmn:mcc=311
...    NRBTS/NRADJECELL-1:enbPlmn:mnc=489
...    NRBTS/NRADJECELL-1:enbPlmn:mncLength=3

@{DELTA_PARAS}
...    MRBTS-1/NRBTS-1/NRCELL-2:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-2:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1:actInterRatHoSADlDataForward=true
#${AP_BIP_FLAG}    ${True}
#${GNB_BIP_FLAG}    ${True}
${UTE_WIRESHARK_FLAG}    True
*** Test Cases ***
5GC000786-ET-D001_Verify VoNR_5QI5_5QI1_Successful Intra-frequency Intra-DU Intra-gNB handover based on A3 measurements when a3MeasEnabled_rsrq
    [Tags]    QC_61509    D001 D006 D019 D017
    [Documentation]
    ...    1.Purpose
    ...      D001 is VoNR call intra-freq intra-gNB HO successful
    ...      D006 is Video call intra-freq inter-gNB HO successful
    ...      D009 is Video call Setup and modify QOSflow successful
    ...      D017 is Video call interRAT HO fail by B2,cause by UE capacity
    ...    2. Test Case Steps:
    ...         A. UE1 HO from cell1 to cell2, from cell2 to cell1 through A3 event
    ...         B. UE2 HO from cell1 to sim cell1, from sim cell1 to cell1 through A5 event
    ...         C. UE3 setup video call and modify 5QI1 and 5QI2 Qosflow
    ...         D. UE5 interRAT HO fail
    VoNR call tirgger Intra-Freq Intra-GNB HO by A3
    Video call tirgger Intra-Freq Inter-GNB HO by A5
    Video call GBR QOS information modification
    Video call trigger InterRat HO fail by B2
    Release UEs    ue_type=all

5GC000786-ET-D018_Verify VoNR_5QI5_5QI1_Successful_InterRAT_HO_based_on_B2_Measurements
    [Tags]    QC_61512   D018
    [Documentation]
    ...    1.Purpose
    ...      D018 is Video call interRAT HO successful by B2.
    ...      PR586910:Data forwarding shall not be allowed for 5QI-1/2
    ...    2. Test Case Steps:
    ...         A. Enable indirect function
    ...         B. UE6 interRat HO successful
    ...         C. Check handoverRequired message will sent out with E-RAB information and gtp-u information doesn't contains 5qi-1/2
    Delta Commission Parameters    ${DELTA_PARAS}
    Enable indirect data forwarding function
    Trigger UE6 VoNR call and traffic
    Trigger UE 5QI2 Setup Successfully    6
    Trigger UE6 B2 Measurement Report
    Wait Until Keyword Succeeds    10 min    30 sec   Check Ute WireShark information
    Release UEs    ue_type=all


*** Keywords ***
Common Suite Setup And Setup Airphone Env
   Common Suite Setup
   Setup Airphone Env    tl_type=tdd_sansa_cmwv/FS/2cells_ecpri    match_string=GNB-3: XnAP Link with GNB-2

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc ims_voice_3gpp=on indirect_data_forwarding=on
    #UE configuration
    ${set_ue1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue1_param}    catenate
    ...    ue_param id=1
    ...    ue_nr_capabilities=${UE1_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue1}
    Update Cfg    ${ue1_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    ${set_ue2}    catenate
    ...    set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1
    ${ue2_param}    catenate
    ...    ue_param id=2
    ...    ue_nr_capabilities=${UE2_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue2}
    Update Cfg    ${ue2_param}
    ${set_ue3}    catenate
    ...    set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1
    ${ue3_param}    catenate
    ...    ue_param id=3
    ...    ue_nr_capabilities=${UE2_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue3}
    Update Cfg    ${ue3_param}
    ${set_ue4}    catenate
    ...    set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1
    ${ue4_param}    catenate
    ...    ue_param id=4
    ...    ue_nr_capabilities=${UE2_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue4}
    Update Cfg    ${ue4_param}
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3
    #interRAT UE
    ${set_ue5}    catenate
    ...    set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=2
    ${ue5_param}    catenate
    ...    ue_param id=5
    ...    ue_nr_capabilities=${UE1_Capabilities} nr_usage_setting=voice_centric
    Update Cfg    ${set_ue5}
    Update Cfg    ${ue5_param}
    Update Cfg    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    ${set_ue6}    catenate
    ...    set_ue simulated id=6 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645405 mode=nr enb=2 cell=2
    ${ue6_param}    catenate
    ...    ue_param id=6
    ...    ue_nr_capabilities=${UE2_Capabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue6}
    Update Cfg    ${ue6_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=2 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=3 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=4 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=5 voice_over_nr=on:on:off
    Update Cfg    ue_nr_capabilities id=6 voice_over_nr=on:on:off
    #5QI configuration
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosflow id=3 5qi=2
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_qosrule id=3 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1-6 amf=1-6 qos_flows=1,2,3,4 qos_rules=1,2,3
    #Xn
    ${gnb3_info}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none xn=10.0.1.124
    ...    nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${gnb3_info}
    Update Cfg    set_cell id=1 gnb=3 pci=127:0 tac=0 nrci=0x01 tdd_cell=on proxy=10.0.2.90:9999 nr_arfcn=636666:636666 gscn=7880
    Update Cfg    gnb_param id=3 xn_listening_socket=on
    Update Cfg    set_cell id=2 gnb=3 pci=127:1 tac=0 nrci=0x02 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=636666:636666 gscn=7880

    ${gnb6_info}    catenate
    ...    set_gnb id=6 type=simulated plmn=311:489 ng=10.0.1.130 daemon=10.0.2.1:22222 gnb_id=0x12:28 nssai=0x01:0xD143A5 x2_peers=none
    ${ENBCELL1_info}    catenate
    ...    set_cell id=1 gnb=6 pci=3:2 nrci=0x1 tac=100 proxy=10.0.2.96:12218 earfcn=1400:19400 technology=lte tdd_cell=on
    ...    mandatory_for_activation=off
    Update Cfg    gnb_param id=6 xn_listening_socket=off
    Update Cfg    ${gnb6_info}
    Update Cfg    ${ENBCELL1_info}

Trigger UE MO VoNR Call With PDU
    [Arguments]    ${ue}=1
    execute egate command    ue_register id=${ue}    UE now in NG RM Registered
    ${out}    execute egate command    ue_pdu_session_setup ue=${ue} pdu=1 gw=${ue} nwslice=1    QoS Routing Table
    should contain    ${out}    Setup QosFlow with QFI:1 5QI:5

Trigger UE 5QI1 Setup Successfully
    [Arguments]    ${ue}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_add=2 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:2 5QI:1

Trigger UE 5QI2 Setup Successfully
    [Arguments]    ${ue}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_add=3 by=amf    QoS Routing Table
    should contain    ${out}    rrcReconfiguration
    should contain    ${out}    Added QosFlow with QFI:3 5QI:2

Trigger UE Video call Setup Successfully with 5QI1 and 5QI2
    [Arguments]    ${ue}=1
    ${out}    execute egate command    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_add=2,3 by=amf    QoS Routing Table
    should contain    ${out}    Added QosFlow with QFI:3 fiveQI:2
    should contain    ${out}    Added QosFlow with QFI:2 fiveQI:1

Trigger UE 5QI Modification Successfully
    [Arguments]    ${ue}=1    ${id}=1
    execute_egate_command    qosflow_modify qos_flow=${id} mfbr_dl=128 mfbr_ul=128 gfbr_dl=64 gfbr_ul=64
    ${cmd}    catenate    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_modify=${id} by=amf
    ${ret1}=    execute_egate_command    ${cmd}    handled successfully    timeout=20s

Trigger UE 5QI1 and 5QI2 Modification Successfully
    [Arguments]    ${ue}=1
    execute_egate_command    qosflow_modify qos_flow=2 mfbr_dl=256 mfbr_ul=256 gfbr_dl=32 gfbr_ul=32
    execute_egate_command    qosflow_modify qos_flow=3 mfbr_dl=256 mfbr_ul=256 gfbr_dl=32 gfbr_ul=32
    ${cmd}    catenate    ue_pdu_session_modify ue=${ue} pdu=1 qosflows_to_modify=2,3 by=amf
    ${ret1}=    execute_egate_command    ${cmd}    handled successfully    timeout=20s

UE Tirgger Intra-Freq Intra-GNB HO back and forth
    [Arguments]    ${ue}=1
    BuiltIn.Log    UE${ue} Tirgger Intra-Frequency Intra-DU HO To Cell...    console=${True}
    Sleep    2s    #Wait pre-RrcReconfigurationComplete sent out
    ${measid_1}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A3
    ${intra_freq_intra_DU_1}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_1} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_intra_DU_1}    pass_regexp=Intra-eNB handover
    ${measid_2}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A3
    ${intra_freq_intra_DU_2}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${measid_2} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_intra_DU_2}    pass_regexp=Intra-eNB handover

Add UE History Information List With Sim Gnb Cell
    [Arguments]    ${ue}=2
    BuiltIn.Log    Add UE History Information List With Sim Gnb Cell...    console=${True}
    execute egate command    ue_history_information_list id=1 action=reset
    execute egate command
    ...    ue_history_information_list_add_ngran id=${ue} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    execute egate command
    ...    ue_history_information_list_add_ngran id=${ue} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
    execute egate command
    ...    ue_history_information_list_add_ngran id=${ue} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=99
    execute egate command    ue_history_information_list id=${ue} action=commit
    execute egate command    ue_enb_param id=${ue} ue_history_list=1

UE HO from real gNB to sim gNB trigger by eventID
    [Arguments]    ${ue}=1    ${event}=A5
    BuiltIn.Log    UE${ue} HO from real gNB to sim gNB$ trigger by ${event}...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=${event}
    ${intra_freq_intra_A5}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${mea_id} event=${event} srsrp_nr=25 srsrq_nr=10 phycell_id=381 nrsrp_nr=85 nrsrq_nr=50
    execute egate command    ${intra_freq_intra_A5}    pass_regexp=Inter-eNB handover

UE HO from sim gNB to real gNB trigger by eventID
    [Arguments]    ${ue}=1    ${event}=A5
    BuiltIn.Log    UE${ue} HO from sim gNB to real gNB trigger by ${event}...    console=${True}
    ${mea_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=${event}
    ${intra_freq_intra_A5}    catenate
    ...    ue_measurement_send_nr id=${ue} meas_id=${mea_id} event=${event} srsrp_nr=15 srsrq_nr=10 phycell_id=50 nrsrp_nr=85 nrsrq_nr=50
    execute egate command    ${intra_freq_intra_A5}    pass_regexp=Inter-eNB handover

Trigger UE A2 Measurement Report
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE${ue} A2 Measurement Report
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A2
    ${A2_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A2 srsrp_nr=7 srsrq_nr=7 srs_result=0:7:7:0
    ...    phycell_id=50 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    execute_egate_command    ${A2_Event}    rrcReconfiguration    timeout=20s
    Should Contain    ${ret1}    eventId eventB2
    Should Contain    ${ret1}    eventId eventA1
    Should Contain    ${ret1}    gapUE setup

Trigger UE A1 Measurement Report
    [Arguments]    ${ue}=1
    BuiltIn.Log    Trigger UE${ue} A1 Measurement Report
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue}    carrierfreq=636576    event_type=A1
    ${A1_Event}    catenate    ue_measurement_send_nr id=${ue} meas_id=${measid} event=A1 srsrp_nr=80 srsrq_nr=80
    ...    srs_result=0:30:30:0 phycell_id=50
    ${ret1}=    execute_egate_command    ${A1_Event}    rrcReconfiguration    timeout=20s
    Should Contain    ${ret1}    eventId eventA2
    Should Contain    ${ret1}    gapUE release : NULL

Trigger UE6 B2 Measurement Report
    Trigger UE A2 Measurement Report    6
    Check Traffic 5QI5 and 5QI1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=6    carrierfreq=1400    event_type=B2    carrierfreq_rat=EUTRAN
    ${B2_Event}    catenate    ue_measurement_send_nr id=6 meas_id=${measid} event=B2 srsrp_nr=11 srsrq_nr=11 srs_result=0:11:11:0
    ...    phycell_id=11 nrsrp_nr=30 nrsrq_nr=30 rs_type=ssb index=0 nrs_result=30:30:0
    ${ret1}=    execute_egate_command    ${B2_Event}    pass_regexp=Successful handover from EXT_ENB-2.2 to ENB-6.1
    sleep    15s  # wait the traffic normal
    Check Traffic 5QI5 and 5QI1

VoNR call tirgger Intra-Freq Intra-GNB HO by A3
    Trigger UE MO VoNR Call With PDU    1
    Trigger UE 5QI1 Setup Successfully    1
    UE Tirgger Intra-Freq Intra-GNB HO back and forth    1

Video call tirgger Intra-Freq Inter-GNB HO by A5
    Add UE History Information List With Sim Gnb Cell    2
    Trigger UE MO VoNR Call With PDU    2
    Trigger UE 5QI1 Setup Successfully    2
    Trigger UE 5QI2 Setup Successfully    2
    UE HO from real gNB to sim gNB trigger by eventID    2    A5
    UE HO from sim gNB to real gNB trigger by eventID    2    A5

Video call GBR QOS information modification
    Trigger UE MO VoNR Call With PDU    3
    Trigger UE Video call Setup Successfully with 5QI1 and 5QI2    3
    Trigger UE 5QI Modification Successfully    3    2
    Trigger UE 5QI Modification Successfully    3    3
    Trigger UE 5QI1 and 5QI2 Modification Successfully    3

Video call trigger InterRat HO fail by B2
    Trigger UE MO VoNR Call With PDU    5
    Trigger UE 5QI1 Setup Successfully    5
    Trigger UE 5QI2 Setup Successfully    5
    Trigger UE A2 Measurement Report    5
    Trigger UE A1 Measurement Report    5
    Trigger UE A2 Measurement Report    5

Trigger UE6 VoNR call and traffic
    Trigger UE MO VoNR Call With PDU    6
    Trigger UE 5QI1 Setup Successfully    6
    Trigger 5QI5 and 5QI1 traffic

Enable indirect data forwarding function
    execute egate command    amf_timer T_Local=4000
    execute egate command    amf_timer T_NotifyProcessing=2500
    execute egate command    upf_param id=1 end_markers_delay=1000
    execute egate command    set_pdu_param ue=6 pdu=1 trf_type=internal

Trigger 5QI5 and 5QI1 traffic
#5QI5
    execute egate command     trf_data_start ue=6 pdu=1 qfi=1 dir=dl trf_id=1 protocol=tcp seconds=600
    sleep    3s
    execute egate command     qfi_stats ue=6 pdu=1 qfi=1 dir=dl    pass_regexp=Parameter
    execute egate command     trf_data_start ue=6 pdu=1 qfi=1 dir=ul trf_id=2 protocol=tcp seconds=600
    sleep    3s
    execute egate command     qfi_stats ue=6 pdu=1 qfi=1 dir=ul    pass_regexp=Parameter
#5QI1
    execute egate command     trf_data_start ue=6 pdu=1 qfi=2 dir=dl trf_id=1 rtp_codec=amr_wb_18_25 seconds=600
    sleep    3s
    execute egate command     qfi_stats ue=6 pdu=1 qfi=2 dir=dl    pass_regexp=Parameter
    execute egate command     trf_data_start ue=6 pdu=1 qfi=2 dir=ul trf_id=2 rtp_codec=amr_wb_18_25 seconds=600
    sleep    3s
    execute egate command     qfi_stats ue=6 pdu=1 qfi=2 dir=ul    pass_regexp=Parameter

Check Traffic 5QI5 and 5QI1
#5QI5
    execute egate command     qfi_stats ue=6 pdu=1 qfi=1 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=6 pdu=1 qfi=1 dir=ul    pass_regexp=Parameter
    sleep    5s
#5QI1
    execute egate command     qfi_stats ue=6 pdu=1 qfi=2 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=6 pdu=1 qfi=2 dir=ul    pass_regexp=Parameter
    sleep    5s
#5QI5
    execute egate command     qfi_stats ue=6 pdu=1 qfi=1 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=6 pdu=1 qfi=1 dir=ul    pass_regexp=Parameter
    sleep    5s
#5QI1
    execute egate command     qfi_stats ue=6 pdu=1 qfi=2 dir=dl    pass_regexp=Parameter
    execute egate command     qfi_stats ue=6 pdu=1 qfi=2 dir=ul    pass_regexp=Parameter
    sleep    5s

Check Ute WireShark information
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}ute_wireshark_eth3.pcap    ngap.procedureCode==12 && s1ap.e_RAB_ID == 0
    should be equal As Numbers    ${number}    1
    sleep    5s
    ${gtp_param} =    Catenate    gtp.message == 0xfe && gtp.ext_hdr.pdu_ses_con.qos_flow_id == 1
    ${number}=    Get Wireshark Message Count    ${SAVE LOG DIRECTORY}${/}ute_wireshark_eth3.pcap    ${gtp_param}
    BuiltIn.Log    ${number}
    should be equal As Numbers    ${number}    1


