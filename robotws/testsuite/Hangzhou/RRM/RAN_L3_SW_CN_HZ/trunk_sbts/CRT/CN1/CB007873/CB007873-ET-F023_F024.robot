*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-L3CN3_SG2    owner-Song.xiuli    release-5G22R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}    @{Common_Config}    @{CELL12_Config}    @{CELL14_Config}    @{cell1_Config}
@{Common_Config}
...    NRBTS:actConflictConfiguration=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:srb3SupportEnabled=false
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Nsa
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:configuredEpsTac=200
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{cell1_Config}
...    NRCELL-1:chBw=60MHz
...    NRCELL-1:nrarfcn=518580
...    NRCELL-1:freqBandIndicatorNR=41
...    NRCELL-1:gscnOrSsPbchArfcn=6486

...    NRCELL-1:a1MeashoEnabled=rsrp
...    NRCELL-1:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-1:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-1:a2MeashoEnabled=rsrp
...    NRCELL-1:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-1:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-1:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:scs=15 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-1/NRHOIF-1:ssbFrequency=126970
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{CELL12_Config}
...    NRCELL-12/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=134980
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=127180
...    NRCELL-12:freqBandIndicatorNR=71
...    NRCELL-12:gscnOrSsPbchArfcn=1586

...    NRCELL-12:rsrpThresholdSSB=11
...    NRCELL-12:absThreshSsbRsrpConsolidation=1
...    NRCELL-12:absThreshSsbRsrqConsolidation=1
...    NRCELL-12:filterCoeffSsbRsrp=fc4
...    NRCELL-12:sMeasConfigSsbRsrp=1
...    NRCELL-12:actCDrx=true
...    NRCELL-12:cbraPreamblesPerSsb=n60

...    NRCELL-12:a1MeashoEnabled=rsrp
...    NRCELL-12:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-12:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-12:a2MeashoEnabled=rsrp
...    NRCELL-12:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-12:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-12:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-12:a3MeasEnabled=rsrp
...    NRCELL-12:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=14
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed

...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:scs=15 KHz
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:ssbFrequency=126750
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:a5MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-2:scs=30 KHz
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-2:ssbFrequency=518910
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-12/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{CELL14_Config}
...    NRCELL-14/NRCELL_FDD-1:chBwDl=15MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=15MHz
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14:freqBandIndicatorNR=71
...    NRCELL-14:gscnOrSsPbchArfcn=1584

...    NRCELL-14:a1MeashoEnabled=rsrp
...    NRCELL-14:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-14:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-14:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-14:a2MeashoEnabled=rsrp
...    NRCELL-14:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-14:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-14:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-14:a3MeasEnabled=rsrp
...    NRCELL-14:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-14:a3MeasSsbRsrp:a3OffsetSsbRsrp=0
...    NRCELL-14:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0

...    NRCELL-14/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=1
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed

...    NRCELL-14/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-2:gNbId=1
...    NRCELL-14/NRREL-2:gNbIdLength=22
...    NRCELL-14/NRREL-2:lcrId=12
...    NRCELL-14/NRREL-2:removeNotAllowed=false
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-2:handoverAllowedSA=allowed

...    NRCELL-14/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:a5MeasEnabled=rsrp
...    NRCELL-14/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-14/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-14/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-14/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-14/NRHOIF-1:scs=15 KHz
...    NRCELL-14/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-14/NRHOIF-1:ssbFrequency=126970
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-14/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-14/NRHOIF-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

@{PM_Counters_Check_F023}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=4
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=4
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=3
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=3
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_ATT}=1
...    NRCELL-14:${RRC_RECONF_1_SCELL_DL_SUCC}=1
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-14:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_REQ}=1
...    NRCELL-14:${SGNB_SCELL_1_ADMISSION_SUCC}=1
...    NRCELL-14:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_REQ}=2
...    NRCELL-14:${SGNB_DU_NSA_ADMISSION_SUCC}=2
...    NRCELL-14:${UE_PSCELL_1_CONF_SCELL_DL}>0

@{PM_Counters_Check_F024}
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_ATT}=2
...    NRCELL-12:${RRC_RECONF_1_SCELL_DL_SUCC}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_DU_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_REQ}=2
...    NRCELL-12:${SGNB_SCELL_1_ADMISSION_SUCC}=2
...    NRCELL-12:${SGNB_SCELL_ADMISSION_UNSUCC}=0
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_REQ}=4
...    NRCELL-12:${SGNB_DU_NSA_ADMISSION_SUCC}=4
...    NRCELL-12:${UE_PSCELL_1_CONF_SCELL_DL}>0
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_REQ}=2
...    NRCELL-1:${SGNB_DU_SCELL_ADMISSION_SUCC}=2
...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL}>0

${RRC_RECONF_1_SCELL_DL_ATT}    M55118C02000
${RRC_RECONF_1_SCELL_DL_SUCC}    M55118C03000
${SGNB_DU_SCELL_1_ADMISSION_REQ}    M55115C00008
${SGNB_DU_SCELL_1_ADMISSION_SUCC}    M55115C00015
${SGNB_SCELL_1_ADMISSION_REQ}    M55114C00021
${SGNB_SCELL_1_ADMISSION_SUCC}    M55114C00028
${SGNB_SCELL_ADMISSION_UNSUCC}    M55114C00035
${SGNB_DU_NSA_ADMISSION_REQ}    M55115C00002
${SGNB_DU_NSA_ADMISSION_SUCC}    M55115C00003
${UE_PSCELL_1_CONF_SCELL_DL}    M55118C04000
${SGNB_DU_SCELL_ADMISSION_REQ}    M55115C00006
${SGNB_DU_SCELL_ADMISSION_SUCC}    M55115C00007
${UE_SCELL_1_CONF_SCELL_DL}    M55118C05000

${carrierfreq_phycell61}    126970
${carrierfreq_phycell63}    126750
${carrierfreq_phycell50}    518910
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_2T4F

${UE92_NR_Capa}
...    SEPARATOR=
...    E1A01000075F5A1302000201404824C5800260D40426C030E7CC31E50B03826010188E00D41B11B582308
...    682041F2804496C98AA0A1CF88E3C639F30C7942C0E070F027F0000001FC0000000300E0541B0A3582308000007800087AD800000000000000
...    00000000000000F55555553FFFFFFFE0601800100208C00000C0468050060680604ED8E7C3F40A00E07010180C01501800180F822008000000
...    0400000802000008010000060080000400400002C12801018064E0940000C9C1280301806018064E0940100C0300C9C1280501806018060180
...    64E0940200C0300C0300C9C12807018060180601806018064C0100000E00800008004000048020000280100001605B2A6F2A6B032B066B036B
...    056B748C99ACA5AC8DAC04AC08A0782000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020080C034B29282
...    0000D2CA4A080003CB292020080E03CB29202000112CA48080004CB29202000152CA48080005CB29202000192CA48080006CB29201AA55574A
...    AAA81C55068BA55154162ABB515D88A551549A2A94C55238AA031540A2808B40468140A05028140A05028140A05028140A0502814000000100
...    600C200

${UE92_eutra_nr_Capa}
...    SEPARATOR=
...    A112C108160601C460000004440B0320E2300000122205818070A00000111102C0C8385000000C8801003808D00A08018
...    40002010100600C2000200808030061000080404010020800080202008010

*** Test Cases ***
CB007873-5G-ET-F023_Verify_NSA_A3_rsrp_CA_UE_in_FDD_and_non_CA_UE_in_FDD_interfreq_intragNB_HO_successful_with_SRB3_to_FDD
    [Documentation]    This case will test A3 rsrp inter-Freq, IntragNB HO from
    ...    CA UE-91 and non-CA 92 to FDD with perUE measurement gap
    [Tags]    QC_89199    F023
    ...    Case steps:
    ...    1.UE-91 support CA(F+T pcell:cell12 scell:cell1) and UE-92 not support CA
    ...    2.both of UE-91 and UE-92 attached. UE-91 CA Setup successfully
    ...    3.Trigger A2 measurement report(pcell:cell12) for the both UE
    ...    4.Trigger A3 measurement report HO from CA (F+T) to FDD(cell14) for the both UE
    ...    5.Trigger A2/A3 to handover from FDD(cell14) to CA(F+T pcell:cell12 scell:cell1) for the both UE,check traffic

    Clear Counter files    False
    Ue Attach To gNB and Initial ENDC
    Trigger Intra gNB Inter Cell Inter Freq HO UE91 from CA to FDD UE92 from FDD to FDD
    Trigger Intra gNB Inter Cell Inter Freq HO UE91 from FDD to CA UE92 from FDD to FDD
    Check Counters    ${PM_Counters_Check_F023}
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_F023${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::4

CB007873-5G-ET-F024_Verify_NSA_A3_rsrp_CA_UE_in_FDD_and_non_CA_UE_in_FDD_interfreq_intragNB_HO_successful_with_SRB3_to_TDD
    [Documentation]    This case will test A3 rsrp inter-Freq, IntragNB HO from
    ...    CA UE-91 and non-CA 92 to TDD with perUE measurement gap
    [Tags]    QC_89200    F024
    ...    Case steps:
    ...    1.UE-91 support CA(F+T pcell:cell12 scell:cell1) and UE-92 not support CA
    ...    2.both of UE-91 and UE-92 attached. UE-92 CA Setup successfully
    ...    3.Trigger A2 measurement report for the both UE
    ...    4.Trigger A3 measurement report to trigger HO from CA (F+T) to TDD for the both UE
    ...    5.Trigger A2/A3 to handover from TDD to CA(FDD+TDD) for the both UE, check traffic

    Clear Counter files    True
    Ue Attach To gNB and Initial ENDC
    Trigger Intra gNB Inter Cell Inter Freq HO UE91 from CA to TDD UE92 from FDD to TDD
    Trigger Intra gNB Inter Cell Inter Freq HO UE91 from TDD to CA UE92 from TDD to FDD
    Check Counters    ${PM_Counters_Check_F024}
    Release Ues    ue_type=all
    check wireshark log    ${CURDIR}${/}a2a_F024${/}a2a_wireshark.ini    wait_string=UEContextReleaseComplete::4

*** Keywords ***
Common Suite Setup And Setup Airphone Env
  Common Suite Setup
  Setup Airphone Env    tl_type=${TL_TYPE_PATH}

Modify Cfg
    ${V2}    catenate
    ...    ue_param id=91 ue_nr_capabilities=${SA_Capa_perUE_Full_1} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${V3}    catenate
    ...    ue_param id=92 ue_nr_capabilities=${NON_CA_SA_Capa_perUE} dual_conn=eutra_nr
    ...    ue_eutra_nr_capabilities=${Capa_LTE}
    ${UE92_para}    catenate
    ...  ue_param id=92 ue_nr_capabilities=${UE92_NR_Capa} dual_conn=eutra_nr ue_eutra_nr_capabilities=${UE92_eutra_nr_Capa}
    Update Cfg    ${V2}
    Update Cfg    ${V3}
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200
    Update Cfg    ${UE92_para}


Ue Attach To gNB and Initial ENDC
    UE attach gNB cell12
    Initial ENDC
    Send And Verify Throuput

UE attach gNB cell12
    CA UE attach to gNB cell12
    non-CA UE attach to gNB cell12

Initial ENDC
    CA UE Initial ENDC    ue_id=91    target_cells=12
    non-CA UE Initial ENDC    ue_id=92    target_cells=12

CA UE Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity

non-CA UE Initial ENDC
    [Arguments]    ${ue_id}=1    ${target_cells}=1
    Execute Egate Command
    ...    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${target_cells} bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity

CA UE attach to gNB cell12
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

non-CA UE attach to gNB cell12
    [Arguments]    ${ue_id}=92
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE

Send And Verify Throuput
    CA UE send And Verify Throuput    ue_id=91
    non-CA UE send And Verify Throuput    ue_id=92

CA UE send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=100    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UDP UL
    CA UE Verify Throuput    ue_id=91

non-CA UE send And Verify Throuput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=dl mbps=10    UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} id=2 dir=ul mbps=10    UDP UL
    non-CA UE Verify Throuput    ue_id=92

CA UE Verify Throuput
    [Arguments]    ${ue_id}=91    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>0
    ${scell9_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=9    type=pdsch    rate_type=ave
    Should Be True    ${scell9_tput}/1000>0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>90

Verify Throuput on TDD cell
    [Arguments]    ${ue_id}=92    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${scell8_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=8    type=pdsch    rate_type=ave
    Should Be True    ${scell8_tput}/1000>0
    ${ul_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    dc_cell_group=all    rate_type=ave
    Should Be True    ${ul_throuput}/1000>8
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>0

non-CA UE Verify Throuput
    [Arguments]    ${ue_id}=92    ${sleep_time}=15s
    sleep    ${sleep_time}
    ${dl_throuput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=scg    rate_type=ave
    Should Be True    ${dl_throuput}/1000>5

Trigger Intra gNB Inter Cell Inter Freq HO UE91 from CA to FDD UE92 from FDD to FDD
    Trigger MeNB coordinate Measurement Gap Setup
    Trigger A2 measurement report    ${carrierfreq_phycell61}
    Trigger MeNB coordinate Measurement Gap off
    Trigger A3 Measurement Report to gNB2 cell14

Trigger Intra gNB Inter Cell Inter Freq HO UE91 from FDD to CA UE92 from FDD to FDD
    Trigger MeNB coordinate Measurement Gap Setup
    Trigger A2 measurement report    ${carrierfreq_phycell63}
    Trigger MeNB coordinate Measurement Gap off
    Trigger A3 Measurement Report back to gNB2 cell12

Trigger MeNB coordinate Measurement Gap Setup
    Trigger CA UE Measurement Gap Setup    ue_id=91
    Trigger non-CA UE Measurement Gap Setup    ue_id=92

Trigger CA UE Measurement Gap Setup
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered

Trigger non-CA UE Measurement Gap Setup
    [Arguments]    ${ue_id}=92
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered

Trigger A2 measurement report
    [Arguments]    ${carrierfreq}
    Trigger CA UE measurement report    ${carrierfreq}
    Trigger non-CA UE measurement report    ${carrierfreq}

Trigger CA UE measurement report
    [Arguments]    ${carrierfreq}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=91    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    SgNBModificationConfirm

Trigger non-CA UE measurement report
    [Arguments]    ${carrierfreq}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=92    carrierfreq=${carrierfreq}    event_type=A2
    Execute Egate Command
    ...    ue_measurement_send_nr id=92 meas_id=${meas_id} event=A2 srsrp_nr=30 srsrq_nr=30
    ...    SgNBModificationConfirm

Trigger MeNB coordinate Measurement Gap off
    Trigger CA UE Measurement Gap off    ue_id=91
    Trigger non-CA UE Measurement Gap off    ue_id=92

Trigger CA UE Measurement Gap off
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off

Trigger non-CA UE Measurement Gap off
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off

Trigger A3 Measurement Report to gNB2 cell14
    Trigger CA UE A3 Measurement Report to gNB2 cell14    ue_id=91
    Trigger non-CA UE A3 Measurement Report to gNB2 cell14    ue_id=92

Trigger CA UE A3 Measurement Report to gNB2 cell14
    [Arguments]    ${ue_id}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_phycell63}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=63 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    CA UE Verify Throuput

Trigger non-CA UE A3 Measurement Report to gNB2 cell14
    [Arguments]    ${ue_id}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_phycell63}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=92 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=63 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    non-CA UE Verify Throuput

Trigger A3 Measurement Report back to gNB2 cell12
    Trigger CA UE A3 Measurement Report to gNB2 cell12    ue_id=91
    Trigger non-CA UE A3 Measurement Report to gNB2 cell12    ue_id=92

Trigger CA UE A3 Measurement Report to gNB2 cell12
    [Arguments]    ${ue_id}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_phycell61}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    CA UE Verify Throuput

Trigger non-CA UE A3 Measurement Report to gNB2 cell12
    [Arguments]    ${ue_id}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_phycell61}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=92 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=61 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    non-CA UE Verify Throuput

Trigger Intra gNB Inter Cell Inter Freq HO UE91 from CA to TDD UE92 from FDD to TDD
    Trigger MeNB coordinate Measurement Gap Setup
    Trigger A2 measurement report    ${carrierfreq_phycell61}
    Trigger MeNB coordinate Measurement Gap off
    Trigger A3 Measurement Report to gNB2 cell1

Trigger Intra gNB Inter Cell Inter Freq HO UE91 from TDD to CA UE92 from TDD to FDD
    Trigger MeNB coordinate Measurement Gap Setup
    Trigger A2 measurement report    ${carrierfreq_phycell50}
    Trigger MeNB coordinate Measurement Gap off
    Trigger A3 Measurement Report back to gNB2 cell12

Trigger A3 Measurement Report to gNB2 cell1
    Trigger CA UE A3 Measurement Report to gNB2 cell1    ue_id=91
    Trigger non-CA UE A3 Measurement Report to gNB2 cell1    ue_id=92

Trigger CA UE A3 Measurement Report to gNB2 cell1
    [Arguments]    ${ue_id}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_phycell50}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=91 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    Verify Throuput on TDD cell    ue_id=91

Trigger non-CA UE A3 Measurement Report to gNB2 cell1
    [Arguments]    ${ue_id}=1
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq_phycell50}    event_type=A3
    ${V3}    catenate
    ...    ue_measurement_send_nr id=92 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=50 nrsrp_nr=60 nrsrq_nr=60
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    Execute Egate Command    ${V3}    SgNBModificationConfirm
    Verify Throuput on TDD cell    ue_id=92
