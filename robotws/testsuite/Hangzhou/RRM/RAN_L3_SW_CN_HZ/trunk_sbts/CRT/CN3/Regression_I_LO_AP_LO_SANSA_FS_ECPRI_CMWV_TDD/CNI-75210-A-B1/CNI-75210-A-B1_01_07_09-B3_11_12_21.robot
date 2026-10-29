*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    team-DevHZ5_SG2    owner-keyun.ma   release-SBTS22R3
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/2cells_ecpri_2N77_AEQU_AEQK
${NREARFCN634000}    633216
${NREARFCN653780}    653856
${AP_BIP_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
@{PARAMS_IN_SCF}
...    NRBTS:actExtN77Support=true
...    NRCELL:cbraPreamblesPerSsb=n60
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=false
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS:cipherPrefL:nea3_128=0
...    @{PARAMS_TO_ENABLE_SA_RSRP}
...    @{HO_PARAMS}
...    @{NRREL_PARAMS}
...    @{NRADJNRCELL}
...    @{NRADJGNB}
...    @{enable_meas}
@{PARAMS_TO_ENABLE_SA_RSRP}
...    NRBTS-1:actIntraFreqHoSA=true

...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.122
@{HO_PARAMS}
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1/NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRBTS-1/NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRBTS-1/NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1/NRHOIF-1:freqBandIndicatorNR=77
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRBTS-1/NRCELL-1/NRHOIF-1:ssbFrequency=653856
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=70
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=100
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=25
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrq=70
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrq=100
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-1:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=${EMPTY}

...    NRBTS-1/NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRBTS-1/NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasEnabled=none
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasEnabled=rsrpCombined
...    NRBTS-1/NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRBTS-1/NRCELL-1/NRHOIF-2:freqBandIndicatorNR=77
...    NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRBTS-1/NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRBTS-1/NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRBTS-1/NRCELL-1/NRHOIF-2:ssBurstSetPeriod=10
...    NRBTS-1/NRCELL-1/NRHOIF-2:ssbFrequency=652416
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=0
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=50
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=70
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms40
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrpVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms160
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=25
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3HysteresisSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3OffsetSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5HysteresisSsbRsrq=0
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5Threshold1SsbRsrq=50
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5Threshold2SsbRsrq=70
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrq=ms40
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5Threshold1SsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5TimeToTriggerSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5HysteresisSsbRsrqVoNr=${EMPTY}
...    NRBTS-1/NRCELL-1/NRHOIF-2:a5MeasSsbRsrq:a5Threshold2SsbRsrqVoNr=${EMPTY}

@{enable_meas}
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a3MeasEnabled=rsrpAndRsrq
...    NRCELL:a5MeasEnabled=rsrpCombined
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms40
...    NRCELL:a3MeasSsbRsrq:a3HysteresisSsbRsrq=1
...    NRCELL:a3MeasSsbRsrq:a3OffsetSsbRsrq=10
...    NRCELL:measGapSelectionSA=favourUeThroughput

@{NRREL_PARAMS}
...    NRBTS-1/NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRBTS-1/NRCELL-1/NRREL-10:gNbId=35
...    NRBTS-1/NRCELL-1/NRREL-10:gNbIdLength=22
...    NRBTS-1/NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRBTS-1/NRCELL-1/NRREL-10:lcrId=1
...    NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRBTS-1/NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=652416
...    NRADJNRCELL-1:ssbFrequency=652416
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
@{NRADJGNB}
...    NRBTS-1/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS-1/NRADJGNB-1:gNbIdLength=22
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS-1/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS-1/NRADJGNB-1:gNodeBId=35
...    NRBTS-1/NRADJGNB-1:xnLinkRef=1
${nr_capability_with_extendband}    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C0
...    0103278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582
...    028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C3906
...    1C00103278FAA8000028000000841C4C0000000020260781038040440180F613003000281C1401C0C026007000683E0000000000000E54D
...    000100000965950034AAA84801C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${nr_capability_without_extendband}    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C00
...    103278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13758202
...    8680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C0
...    0103278FAA8000028000000841C4C000000002026078003804044F613003000281C1401C0C026007000683E0000000000000E54D00010000
...    0965950034AAA84801C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
@{NSA_INTRAGNB_INTERFREQ_HO}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRCELL-1:cbraPreamblesPerSsb=n64
...    NRCELL-2:cbraPreamblesPerSsb=n64
...    delete:NRCELL-1/NRHOIF-1
...    delete:NRCELL-1/NRREL-10
...    NRBTS-1:actInterMeNBMobility=true
...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-1:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL-1:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=2
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=2
...    NRCELL-1:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL-1:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-2:a1MeashoEnabled=rsrp
...    NRCELL-2:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-2:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-2:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a1MeashoSsbRsrq:a1HysteresishoSsbRsrq=0
...    NRCELL-2:a1MeashoSsbRsrq:a1ThresholdhoSsbRsrq=31
...    NRCELL-2:a1MeashoSsbRsrq:a1TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-2:a2MeashoEnabled=rsrp
...    NRCELL-2:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=2
...    NRCELL-2:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-2:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-2:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=2
...    NRCELL-2:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL-2:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-2:ssbFrequency=${NREARFCN653780}
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3OffsetSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrpAndRsrq
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-2/NRHOIF-1:ssbFrequency=${NREARFCN634000}
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrpVoNr=${EMPTY}
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrpVoNr=${EMPTY}
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrpVoNr=${EMPTY}
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3HysteresisSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3OffsetSsbRsrq=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrq:a3TimeToTriggerSsbRsrq=ms64
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{CB007516_non_CA_aware}
...    NRBTS-1:drbInactivityTimerSA=10
...    NRBTS-1:srbInactivityTimerSA=10
...    NRBTS-1:actIdleMMSteering=true
...    NRBTS-1:actMobilityProfile=false
...    NRBTS-1/NRCELL-1:cellReselectionSubPriority=oDot8
...    NRBTS-1/NRCELL-1:idleMMServCelResWeight=32
...    NRBTS-1/NRCELL-1:idleMMSteeringAlgo=non CA aware
...    NRBTS-1/NRCELL-1:idleMMSteeringPercentageOfUes=100
...    NRBTS-1/NRCELL-1:idleMMSteeringWRREnabled=false
...    NRBTS-1/NRCELL-1:t320=min5
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS-1/NRCELL-2:cellReselectionSubPriority=oDot8
...    NRBTS-1/NRCELL-2:idleMMServCelResWeight=32
...    NRBTS-1/NRCELL-2:idleMMSteeringAlgo=non CA aware
...    NRBTS-1/NRCELL-2:idleMMSteeringPercentageOfUes=100
...    NRBTS-1/NRCELL-2:idleMMSteeringWRREnabled=false
...    NRBTS-1/NRCELL-2:t320=min5
...    @{CB008696_disable}
...    @{idle_mode_config}
@{CB008696_disable}
...    NRBTS:actIdlMMEnDcSteering=false
@{idle_mode_config}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionPriority=7
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionSubPriority=oDot8
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:dlCarrierFreq=631776
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:idleMMNrCelResWeight=100
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionPriority=5
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionSubPriority=oDot2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:dlCarrierFreq=651552
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:freqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:idleMMNrCelResWeight=70
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:qOffsetFreq=-20dB
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:qRxLevMin=-60
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:tReselectionNr=1
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXHighP=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXHighQ=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXLowP=22
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXLowQ=22
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=1700
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionPriority=3
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionSubPriority=oDot2
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeight=25
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeightEnDc=25
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:carrierFreq=2500
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:cellReselectionPriority=4
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:cellReselectionSubPriority=oDot4
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:idleMMEutraCelResWeight=50
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:idleMMEutraCelResWeightEnDc=50
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:pMaxEutra=23
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-2:qQualMin=-34
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:allowedMeasBw=mbw100
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:carrierFreq=3100
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:cellReselectionPriority=5
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:cellReselectionSubPriority=oDot6
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:idleMMEutraCelResWeight=60
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:idleMMEutraCelResWeightEnDc=60
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:pMaxEutra=23
...    NRBTS/NRSYSINFO_PROFILE-1/NRLIM-3:qQualMin=-34
...    MRBTS-1/NRBTS-1/NRCELL-2:nrSysInfoProfileDN=MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1
...    MRBTS-1/NRBTS-1/NRCELL-2:nrMultibandInfoProfileDN=MRBTS-1/NRBTS-1/NRMULTIBANDINFO_PROFILE-1
@{CB008696}
...    NRBTS-1:drbInactivityTimerSA=10
...    NRBTS-1:srbInactivityTimerSA=10
...    NRBTS:actIdlMMEnDcSteering=true
...    NRBTS:integrityProtPrefL:nia0=0
...    NRCELL:a3MeasEnabled=none
...    NRCELL:a4ReportTimerEnDc=6000
...    NRCELL:a5MeasEnabled=none
...    NRCELL:idleMMEnDcSteeringPercentageOfUes=100
...    NRCELL-1:idleMMEnDcSteeringSsbFrequency=631776
...    NRCELL-2:idleMMEnDcSteeringSsbFrequency=651552
...    NRCELL:idleMMEnDcSteeringWRREnabled=false
...    NRCELL:t320EnDc=min10
...    NRCELL/NRHOIF-1:a3MeasEnabled=none
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringEnabled=rsrp
...    NRCELL/NRHOIF-1:a5MeasEnabled=none
...    NRCELL/NRHOIF-1:ssbFrequency=631776
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4HysteresisEnDcSteeringSsbRsrp=12
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4ThresholdEnDcSteeringSsbRsrp=2
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms40
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringSsbRsrq:a4TimeToTriggerEnDcSteeringSsbRsrq=ms40
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringSsbRsrq:a4HysteresisEnDcSteeringSsbRsrq=12
...    NRCELL/NRHOIF-1:a4MeasEnDcSteeringSsbRsrq:a4ThresholdEnDcSteeringSsbRsrq=2
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=77
...    NRCELL/NRHOIF-2:a3MeasEnabled=none
...    NRCELL/NRHOIF-2:a4MeasEnDcSteeringEnabled=rsrp
...    NRCELL/NRHOIF-2:a5MeasEnabled=none
...    NRCELL/NRHOIF-2:freqBandIndicatorNR=77
...    NRCELL/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL/NRHOIF-2:ssbFrequency=651552
...    NRCELL/NRHOIF-2:a4MeasEnDcSteeringSsbRsrp:a4HysteresisEnDcSteeringSsbRsrp=12
...    NRCELL/NRHOIF-2:a4MeasEnDcSteeringSsbRsrp:a4ThresholdEnDcSteeringSsbRsrp=2
...    NRCELL/NRHOIF-2:a4MeasEnDcSteeringSsbRsrp:a4TimeToTriggerEnDcSteeringSsbRsrp=ms40
...    @{idle_mode_config}
...    @{5GC000708_false}
@{5GC000708}
...    NRBTS-1:actRedirect=true
@{5GC000708_false}
...    NRBTS-1:actRedirect=false
@{REDRT_ONLY_DoD_Freq}
...    @{5GC000708}
...    NRBTS-1:actIdleMMSteering=false
...    @{CB008696_disable}
...    NRBTS-1:srb3SupportEnabled=false
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=false
...    NRBTS-1:drbInactivityTimerSA=600
...    NRBTS-1:srbInactivityTimerSA=600
...    NRBTS/NRCELL-1:a5MeasEnabled=none
...    NRBTS/NRCELL-1:a2MeasRedirectEnabled=rsrp
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=47
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS/NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    NRBTS/NRCELL-1/NRREDRT-1:redirFreqNr=630000
...    NRBTS/NRCELL-1/NRREDRT-1:redirRat=nr
...    NRBTS/NRCELL-1/NRREDRT-1:redirPrio=1
...    delete:NRCELL-1/NRHOIF-1
...    delete:NRCELL-1/NRHOIF-2
...    delete:NRCELL-1/NRHOIF-3
...    delete:NRCELL-1/NRREL-10
...    delete:NRCELL-1/NRREL-1
@{REDRT_DoD_Freq_High_Band_Freq}
...    NRBTS-1:actRedirect=true
...    NRBTS/NRCELL-1:a5MeasEnabled=none
...    NRBTS/NRCELL-1:a2MeasRedirectEnabled=rsrp
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=47
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrq:a2HysteresisRedirectSsbRsrq=0
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrq:a2ThresholdRedirectSsbRsrq=31
...    NRBTS/NRCELL-1:a2MeasRedirectSsbRsrq:a2TimeToTriggerRedirectSsbRsrq=ms480
...    NRBTS/NRCELL-1/NRREDRT-1:redirSsbScs=30 KHz
...    NRBTS/NRCELL-1/NRREDRT-1:redirFreqNr=630000
...    NRBTS/NRCELL-1/NRREDRT-1:redirRat=nr
...    NRBTS/NRCELL-1/NRREDRT-1:redirPrio=4
...    NRBTS/NRCELL-1/NRREDRT-2:redirSsbScs=30 KHz
...    NRBTS/NRCELL-1/NRREDRT-2:redirFreqNr=655000
...    NRBTS/NRCELL-1/NRREDRT-2:redirRat=nr
...    NRBTS/NRCELL-1/NRREDRT-2:redirPrio=5
@{PM_Counters_Redirect}
...    NRCELL-1:NRRCC:${NRRCC_RRC_RELEASE_REDIR_NR}=3
...    NRCELL-1:NRRCC:${NRRCC_RRC_RELEASE_REDIR_LTE}=0
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_REL_REQ_SENT}=3
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_REL_CMD_RECD}=3
...    NRCELL-1:NNGCC:${NNGCC_UE_CTXT_REL_CMP_SENT}=3
${NRRCC_RRC_RELEASE_REDIR_NR}    M55124C01501
${NRRCC_RRC_RELEASE_REDIR_LTE}    M55124C01502
${NNGCC_UE_CTXT_REL_REQ_SENT}    M55125C01001
${NNGCC_UE_CTXT_REL_CMD_RECD}    M55125C00501
${NNGCC_UE_CTXT_REL_CMP_SENT}    M55125C00502
${PM_SPEED_UP_FLAG}    ${True}
${nr_capability_with_extendband_for_case21}
...    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C00103278F
...    AB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C240
...    3D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C00103278FAA80000280000
...    00841C4C0000000020260781038040440180F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA84801C002C0
...    00000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${nr_capability_without_extendband_for_case21}
...    SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C00103278F
...    AB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C240
...    3D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C00103278FAA80000280000
...    00841C4C000000002026078003804044F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA84801C002C00000
...    0100200462C4C0004080C1014181C202C4044484C648494989CA1280
${ue_eutra_nr_capabilities}        SEPARATOR=
...    01080C0464A00C0801820071300038000000000364A008081010701C00000006C0801830032500E800000000006100100802010040300200
...    6004008000402000100808010020
${ue_eutra_capabilities}        SEPARATOR=
...    DE1809D9408206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00
...    000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00
...    000001BFBFFEC800801C364000000017BA000000080952A0E2740400003840000210002C20000108008400010C0002200004500008C0001
...    1C0002400004900009400012C0002600004D0000A0000144000290000530000A80001540002B0000570000B00001640002D00005B0000BA
...    0001780003680007F001D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000
...    000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000A080000079D00000000000000000000000
...    0000000000000000000000000000000000001011C42129A061CFFFFFFFFFFFFFFFA020A8001802297000020000104B1A0109823200F0000
...    00600000020
@{PM_Counters_idlemode}
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}=1
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_LTE}=0
...    NRCELL-2:${NRRCC_RRC_RELEASE_SENT}=1
...    NRCELL-2:${NRRCC_RRC_RELEASE_IMM_NR}=1
...    NRCELL-2:${NRRCC_RRC_RELEASE_IMM_LTE}=0
${NRRCC_RRC_RELEASE_SENT}    M55124C00001
${NRRCC_RRC_RELEASE_IMM_NR}    M55124C05501
${NRRCC_RRC_RELEASE_IMM_LTE}    M55124C05502

${nr_capability_with_extendband}  SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A3582028680965944C2403D6C10101070EF1C39061C00103278F
...    AB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B137582028680965944C240
...    3D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C10101070EF1C39061C00103278FAA80000280000
...    00841C4C0000000020260781038040440180F613003000281C1401C0C026007000683E0000000000000E54D000100000965950034AAA84801C002C0
...    00000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${nr_capability_without_extendband}  SEPARATOR=
...    E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01951B0A358202868096
...    5944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B133582028680965944C2403D6C10101070EF1C39061C00103278FAB800
...    27800E0009E00151B137582028680965944C2403D6C10101070EF1C39061C00103278FAB80027800E0009E00151B13B582028680965944C2403D6C1
...    0101070EF1C39061C00103278FAA8000028000000841C4C000000002026078003804044F613003000281C1401C0C026007000683E0000000000000E
...    54D000100000965950034AAA84801C002C000000100200462C4C0004080C1014181C202C4044484C648494989CA1280
${ue_eutra_nr_capabilities}  SEPARATOR=
...    BD1BA053058180713000000018062B000060400C1001830030300E260000010300C160801C4C000006060182C0C0389A00000C0C030581007130000
...    010180245E28061000100804008012B8008020100402008040100802010040200804010080201004020080401008020100802010040200804000000
...    20100402000000000002010000000000000000201004020080401008000000402008040000000000040200000000000000004020080401008020100
...    40200000010080201004020000000000000000402000000000000000000000804E00101004020040400808000000202004040000000000020200000
...    00000000000201008020080401008020100402008040100802010040200804010080201004040100801010000000404008080000002020000000000
...    01010000000000008080201002020040400000010100202000000000001010020200000000000101000000000000000010138008040100802010000
...    00080401008000000402000000000002010000000000010080201004020000001008020100000008040000000000040200000000000200804010080
...    20100402008040100802010040200804010080201004020080402008040100800000040200804000000201000000080400000020100000000000100
...    800000000000804E0010100202004040080801010000000404008080101000000000000808000000202004040080801010020200000008080101002
...    02000000000001010000000404008080101002020040400000010100202004040000000000020200000008040100802010040200804010080201004
...    0200804010080201004020080401008020100402008040200B800804008080000002020040400000000000000004040000000000000000000010080
...    10100000004040080800000000000000008080000000000000000000020100202000000080801010000000000000000101000000000000000000000
...    402004040000001010020200404000000000002020000000808010100000000000000001010000000404E200400C0080180100300200600400C0080
...    180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801
...    00300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C008018010030
...    0200600400C0080180100300200600400C00801801003002006004008400020101002004200020080801002
${ue_eutra4_nr77_capabilities}  SEPARATOR=
...    BD1BA053058180713000000018062B000060400C1001830030300E260000010300C160801C4C000006060
...    182C0C0389A00000C0C030581007130000010180245E28061000080404008012B800802010040200804010080201004020080401008020100402008
...    04010080201008020100402008040000002010040200000000000201000000000000000020100402008040100800000040200804000000000004020
...    000000000000000402008040100802010040200000010080201004020000000000000000402000000000000000000000804E0010100402004040080
...    80000002020040400000000000202000000000000000020100802008040100802010040200804010080201004020080401008020100404010080101
...    00000004040080800000020200000000000101000000000000808020100202004040000001010020200000000000101002020000000000010100000
...    00000000000101380080401008020100000008040100800000040200000000000201000000000001008020100402000000100802010000000804000
...    00000000402000000000002008040100802010040200804010080201004020080401008020100402008040200804010080000004020080400000020
...    1000000080400000020100000000000100800000000000804E001010020200404008080101000000040400808010100000000000080800000020200
...    40400808010100202000000080801010020200000000000101000000040400808010100202004040000001010020200404000000000002020000000
...    80401008020100402008040100802010040200804010080201004020080401008020100402008040200B80080400808000000202004040000000000
...    00000040400000000000000000000100801010000000404008080000000000000000808000000000000000000002010020200000008080101000000
...    0000000000101000000000000000000000402004040000001010020200404000000000002020000000808010100000000000000001010000000404E
...    200400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003002006004
...    00C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0080180100300200600400C0
...    080180100300200600400C0080180100300200600400C0080180100300200600400C00801801003002006004008400020101002004200020080801002

*** Test Cases ***
CNI-75210-A-B1_09_01_Verify_Classical_SA_TDD_cmWave_interfreq_intergNB_HO_with_A5_rsrpCombined_CFRA_is_successful_with_n77_3450-3550MHz
    [Tags]    networkmode=SA    responsible_tester-keyun.ma
    Ue Register And Pdu Session Setup
    Send And Verify Throughput for SA call
    Ue Ho To target gNB Cell-1
    Ue Ho Back from target gNB Cell-1
    Release Ues    ue_type=all

CNI-75210-A-B1_07_01_Verify_Classical_NSA_TDD_cmWave_interfreq_intragNB_HO_with_A3_rsrpAndRsrq_SRB3_is_successful_with_n77_3450-3550MHz
    [Tags]    responsible_tester-huabao.jiang
    Configured NSA INTRAGNB INTERFREQ HO
    UE Attach and establish EN-DC    31    2
    report A2 and configured NSA A3A5    31    1    retvalue=eventA3
    report inter A3 A5 and trigger cell2 handover to cell1    31    3    A3
    report A2 and configured NSA A3A5    31    1    retvalue=eventA3
    report inter A3 A5 and trigger cell1 handover to cell2    31    3    A3
    NON DOD UE Attach and establish EN-DC    32    2    ${nr_capability_without_extendband}
    check wireshark log    ${CURDIR}${/}a2a_case07${/}a2a.ini
    Release Ues    ue_type=all


CNI-75210-A-B1_01_01_Verify_Classical_SA_TDD_cmWave_Ue_Attach_Succeed_with_n77_3450-3550MHz_when_actMultiFrequencyBandIndicatorNRSupport_disable
    [Tags]    networkmode=SA    responsible_tester-keyun.ma
    Ue Register And Pdu Session Setup
    Send And Verify Throughput for SA call
    Lock Cell To Trigger SIB1_2_4   1
    Unlock Cell1 To Verify SIB1_2_4
    Lock Cell To Trigger SIB1_2_4   2
    Unlock Cell2 To Verify SIB1_2_4
    Release Ues    ue_type=all

CNI-75210-A-B3_12_01_A4 configuration with n77_3450-3550MHz during Idle mode Traffic Steering from NR SA to LTE ENDC
    [Tags]    responsible_tester-feng.2.chen
    [Documentation]
    ...    this case test without mobility profiles
    ...    UE1 released with EUTRA carrierFreq 2500, 1700, 3100; freqPriorityListNR carrierFreq 631776, 651552, 633216
    ...    UE2 released with EUTRA carrierFreq 2500, 1700, 3100; freqPriorityListNR carrierFreq 651552, 653856
    OnlineParamChange     ${CB008696}
    UE With extendedBandn77 Capability released with Eutra and DoD nr carrierFreq after receive A4 report
    UE Without extendedBandn77 Capability released with Eutra and without DoD nr carrierFreq after receive A4 report
    Check Logs With Au2anlysis    ${CURDIR}${/}a2a_case12${/}a2a_01.ini    p
    Release Ues    ue_type=all

CNI-75210-A-B3_13_01_Idle Mode Mobility steering to 5G n77_3450-3550MHz without CA and mobility profiles
    [Tags]    responsible_tester-feng.2.chen
    [Documentation]
    ...    UE1 released with EUTRA carrierFreq 3100, 2500, 1700; freqPriorityListNR carrierFreq 631776, 651552, 633216
    ...    UE2 released with EUTRA carrierFreq 3100, 2500, 1700; freqPriorityListNR carrierFreq 651552, 653856
    Clear Counter Files
    OnlineParamChange    ${CB007516_non_CA_aware}
    UE With extendedBandn77 Capability released with Eutra carrierFreq and DoD nr carrierFreq
    UE Without extendedBandn77 Capability released with Eutra carrierFreq and without DoD nr carrierFreq
    Check Logs With Au2anlysis    ${CURDIR}${/}a2a_case13${/}a2a_01.ini    p
    Check Counters    ${PM_Counters_idlemode}
    Release Ues    ue_type=all

CNI-75210-A-B3_21_01_Redirection to 5G n77 band based on A2 measurements
    [Tags]    responsible_tester-lola.ren
	Clear Counter files
	Set UEs With or Without extendedBandn77
	OnlineParamChange    ${REDRT_ONLY_DoD_Freq}
    UE With extendedBandn77 Capability is configured Redirect A2
	UE Without extendedBandn77 Capability is not configured Redirect A2
	OnlineParamChange    ${REDRT_DoD_Freq_High_Band_Freq}
	UE With extendedBandn77 Capability Redirect to Band 77 DoD Freq
	UE Without extendedBandn77 Capability Redirect to Band 77 High Band Freq
	Check Counters    ${PM_Counters_Redirect}
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
	#Debug Enter Into Egate

Lock Cell To Trigger SIB1_2_4
    [Arguments]    ${number}
    Delta Commission Parameters  NRCELL-${number}:administrativeState=Locked
    Cell Should Be Locked  ${number}

Unlock Cell1 To Verify SIB1_2_4
    Start RRC Log    Unlock_Cell_1
    Delta Commission Parameters  NRCELL-1:administrativeState=Unlocked
    Cell Should Be Unlocked  1
    Wait for rrc log print    #20220602 add
    Check RRC log    ${CURDIR}/a2a_case01/Unlock_Cell_1.ini

Unlock Cell2 To Verify SIB1_2_4
    Start RRC Log    Unlock_Cell_2
    Delta Commission Parameters  NRCELL-2:administrativeState=Unlocked
    Cell Should Be Unlocked  2
    Wait for rrc log print    #20220602 add
    Check RRC log    ${CURDIR}/a2a_case01/Unlock_Cell_2.ini

Ue Register And Pdu Session Setup
    [Arguments]    ${ue_id}=1
    Execute Egate Command    gnb_xn_link_up gnb=3 target=2    pass_regexp=GNB-3: XnAP Link with GNB-2
    Execute Egate Command    ue_history_information_list id=${ue_id} action=reset
    Execute Egate Command    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list_add_ngran id=${ue_id} cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=97
    Execute Egate Command    ue_history_information_list id=${ue_id} action=commit
    Execute Egate Command    ue_enb_param id=${ue_id} ue_history_list=1
    Execute Egate Command    ue_register id=${ue_id}    Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table

Send And Verify Throughput for SA call
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=5    UE 1: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=5 mbps=5    UE 1: UDP UL
    Verify Throughput for SA call    ${ue_id}

Verify Throughput for SA call
    [Arguments]    ${ue_id}=1    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>4.6
    Should Be True    ${ul_throughput}/1000>4.6

Ue Ho To target gNB Cell-1
    Start RRC Log    Ue_Ho_To_target_gNB_Cell_1
    Initial A2 Event
    Initial InterFreA5 Ho
    Verify Throughput for SA call
    Check RRC log    ${CURDIR}/a2a_case09/Ue_Ho_To_target_gNB_Cell_1.ini

Initial A2 Event
    [Arguments]    ${ueid}=1    ${cafreq}=633216
    ${mid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ueid}    carrierfreq=${cafreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ueid} meas_id=${mid} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=rrcReconfigurationComplete

Initial InterFreA5 Ho
    [Arguments]    ${ue_id}=1    ${cafreq}=652416    ${phyid}=381
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cafreq}    event_type=A5
    ${cmd1}    catenate    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A5 srsrp_nr=11 srsrq_nr=11
    ...     phycell_id=${phyid} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${cmd1}    pass_regexp=Inter-eNB handover

Ue Ho Back from target gNB Cell-1
    start to capture wireshark log    Ue_Ho_Back_from_target_gNB_Cell_1
    Initial A2 Event    cafreq=652416
    Initial InterFreA5 Ho    cafreq=633216    phyid=50
    Verify Throughput for SA call
    Check WireShark Log    ${CURDIR}/a2a_case09/Ue_Ho_Back_from_target_gNB_Cell_1.ini
    ...    name=Ue_Ho_Back_from_target_gNB_Cell_1    wait_string=PathSwitchRequestAcknowledge:4

Modify Cfg
    ${V1}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc
    ...    sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400
    ...    enb=2 cell=1 mode=nr
    Update Cfg    ${V1}
    ${V2}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x23:22 daemon=10.0.2.1:22222 x2_peers=none
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${V2}
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    ${V3}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.91:9999 nr_arfcn=650000:650000
    ...    gscn=8045 suggested_band=77 mandatory_for_activation=off
    Update Cfg    ${V3}
    ${V4}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.80:9999|10.0.2.80:8888
    ...    suggested_band=77 nr_arfcn=634000:634000 gscn=7845 mandatory_for_activation=off
    Update Cfg    ${V4}

Set xn gnb link up
    Execute Egate Command    enb_x2_link_up enb=1 target=2    ENB-1: X2AP Link with GNB-2

UE register and PUD session setup on specific cell
    [Arguments]    ${ue_id}=1    ${nr_capability}=${nr_capability_with_extendband}    ${cell_id}=1
    Execute Egate Command   ue_param id=${ue_id} ue_nr_capabilities=${nr_capability}
    Execute Egate Command   ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command   ue_register id=${ue_id}    Received REGISTRATION COMPLETE
    Execute Egate Command   ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    QoS Routing Table

report A2 and configured NSA A3A5
    [Arguments]    ${ue_id}=31    ${meas_id}=1    ${retvalue}=${EMPTY}
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:20 mgta=ms0 gap_purpose=perUE gap_trigger=gnb_triggered
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30     ${retvalue}

report inter A3 A5 and trigger cell1 handover to cell2
    [Arguments]    ${ue_id}=31    ${meas_id}=3    ${event}=A3
    ${V2}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V2}    UE31: Sending SgNB Modification Confirm

report inter A3 A5 and trigger cell2 handover to cell1
    [Arguments]    ${ue_id}=31    ${meas_id}=3    ${event}=A3
    ${V1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event}
    ...    srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command    ${V1}    UE31: Sending SgNB Modification Confirm

UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=1   ${ue_nr_capabilities}=${nr_capability_with_extendband}
    ${V3}    catenate
    ...    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra4_nr77_capabilities}
    Execute Egate Command    ${V3}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell 2\\) reported successful RA

NON DOD UE Attach and establish EN-DC
    [Arguments]    ${ue_id}=31    ${target_cell}=1   ${ue_nr_capabilities}=${nr_capability_with_extendband}
    ${V4}    catenate
    ...    ue_param id=${ue_id} ue_nr_capabilities=${ue_nr_capabilities}
    ...    dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra4_nr77_capabilities}
    Execute Egate Command    ${V4}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    ${ret}    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cell} bearer=2 type=split_scg
    ...    Proxy \\(eNB 2 cell 2\\) reported successful RA
    should not contain     ${ret}    eventId eventA2

Configured NSA INTRAGNB INTERFREQ HO
    Set xn gnb link up
    delta commission parameters    ${NSA_INTRAGNB_INTERFREQ_HO}
    Cells Should Be Onair    check_sib=${False}

send A4 report
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${phycell_id}=48
    ${command}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11
    ...    phycell_id=${phycell_id} nrsrp_nr=80 nrsrq_nr=80
    Execute Egate Command      ${command}    Ignoring Rrc Release in NAS-FIVEGS-SM-PDU-SESSION-ACTIVE-IDLE

UE register and PUD session setup for endc aware
    [Arguments]    ${ue_id}=1    ${nr_capability}=${nr_capability_with_extendband}    ${cell_id}=1
    ${command}    catenate
    ...    ue_param id=${ue_id} ue_eutra_capabilities=${ue_eutra_capabilities} ue_nr_capabilities=${nr_capability}
    ...    ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities}
    Execute Egate Command    ${command}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    QoS Routing Table

Wait for inactivity timer expired
    sleep    12

Wait for rrc log print
    sleep    8

OnlineParamChange
    [Arguments]  ${Online_Param}
    Delta Commission Parameters  ${Online_Param}
    Cells Should Be Onair    check_sib=${False}

Set UEs With or Without extendedBandn77
    Execute Egate Command    ue_location_change id=1-4 enb=2 cell=1
    Execute Egate Command    ue_param id=1 ue_nr_capabilities=${nr_capability_with_extendband_for_case21}
    Execute Egate Command    ue_param id=2 ue_nr_capabilities=${nr_capability_without_extendband_for_case21}
	Execute Egate Command    ue_param id=3 ue_nr_capabilities=${nr_capability_with_extendband_for_case21}
    Execute Egate Command    ue_param id=4 ue_nr_capabilities=${nr_capability_without_extendband_for_case21}
	Execute Egate Command    ue_param id=5 ue_nr_capabilities=${nr_capability_with_extendband_for_case21}

UE With extendedBandn77 Capability is configured Redirect A2
    [Arguments]    ${ue_id}=1    ${meas_id}=1
    Execute Egate Command    ue_register id=${ue_id}    Received REGISTRATION COMPLETE
	${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=QoS Routing Table
	Should Contain    ${ret1}    a2-Threshold rsrp : 47    #a2ThresholdRedirectSsbRsrp=47
	${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11    rrcRelease
	Should Contain    ${ret1}    redirectedCarrierInfo nr
	Should Contain    ${ret1}    carrierFreq 630000

UE Without extendedBandn77 Capability is not configured Redirect A2
    [Arguments]    ${ue_id}=2
    Execute Egate Command    ue_register id=${ue_id}    Received REGISTRATION COMPLETE
	${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=2    pass_regexp=QoS Routing Table
	Should Not Contain    ${ret1}    a2-Threshold rsrp : 47    #a2ThresholdRedirectSsbRsrp=47

UE With extendedBandn77 Capability Redirect to Band 77 DoD Freq
    [Arguments]    ${ue_id}=3    ${meas_id}=1
    Execute Egate Command    ue_register id=${ue_id}    Received REGISTRATION COMPLETE
	Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=3    pass_regexp=QoS Routing Table
	${ret1}=   Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11    rrcRelease
	Should Contain    ${ret1}    redirectedCarrierInfo nr
	Should Contain    ${ret1}    carrierFreq 630000

UE Without extendedBandn77 Capability Redirect to Band 77 High Band Freq
    [Arguments]    ${ue_id}=4    ${meas_id}=1
    Execute Egate Command    ue_register id=${ue_id}    Received REGISTRATION COMPLETE
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=4    pass_regexp=QoS Routing Table
	${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11    rrcRelease
	Should Contain    ${ret1}    redirectedCarrierInfo nr
	Should Contain    ${ret1}    carrierFreq 655000
	Should Not Contain    ${ret1}    carrierFreq 630000

UE With extendedBandn77 Capability released with Eutra and DoD nr carrierFreq after receive A4 report
    [Arguments]    ${ue_id}=1
    Start RRC Log    log_UE${ue_id}
    UE register and PUD session setup for endc aware    ${ue_id}    ${nr_capability_with_extendband}    cell_id=1
    Wait for inactivity timer expired
    send A4 report    ue_id=${ue_id}    meas_id=1    phycell_id=48
    Get Rrc Log

UE Without extendedBandn77 Capability released with Eutra and without DoD nr carrierFreq after receive A4 report
    [Arguments]    ${ue_id}=2
    Start RRC Log    log_UE${ue_id}
    UE register and PUD session setup for endc aware    ${ue_id}    ${nr_capability_without_extendband}    cell_id=2
    Wait for inactivity timer expired
    send A4 report    ue_id=${ue_id}    meas_id=1    phycell_id=48
    Get Rrc Log

UE With extendedBandn77 Capability released with Eutra carrierFreq and DoD nr carrierFreq
    [Arguments]    ${ue_id}=1
    Start RRC Log    log_UE${ue_id}
    UE register and PUD session setup on specific cell    ${ue_id}    ${nr_capability_with_extendband}    cell_id=1
    Wait for inactivity timer expired
    Get Rrc Log

UE Without extendedBandn77 Capability released with Eutra carrierFreq and without DoD nr carrierFreq
    [Arguments]    ${ue_id}=3
    Start RRC Log    log_UE${ue_id}
    UE register and PUD session setup on specific cell    ${ue_id}    ${nr_capability_without_extendband}    cell_id=2
    Wait for inactivity timer expired
    Get Rrc Log
