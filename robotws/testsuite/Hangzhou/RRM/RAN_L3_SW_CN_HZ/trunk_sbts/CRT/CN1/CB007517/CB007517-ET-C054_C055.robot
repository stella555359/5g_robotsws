*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Jazz_SGT&A    owner-chunjian.yang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:actConflictConfiguration=true
...    NRBTS-1:actIncXn=true
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1/NRCELL:actCDrx=true
...    @{NRADJNRCELL}
...    @{meas_Config_cell1}
...    @{meas_Config_cell2}
...    @{meas_Config_cell12}
...    @{meas_Config_cell13}

@{NRADJNRCELL}
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:freqBandIndicatorNR=71
...    NRADJNRCELL-1:fiveGsTac=0
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=127230
...    NRADJNRCELL-1:physCellId=382
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3

@{meas_Config_cell1}
...    NRBTS-1:actHigherPrioFreqHo=SA
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min

...    NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=8000
...    NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=5

...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:cellDepType=SA+NSA
...    NRCELL-1:gscnOrSsPbchArfcn=6549
...    NRCELL-1:nrarfcn=524310
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=1
...    NRCELL-1:a5MeasEnabled=rsrp
...    NRCELL-1:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0

...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20

...    NRCELL-1/NRHOIF-2:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1/NRHOIF-2:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssbFrequency=127230
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20

...    NRCELL-1/NRHOIF-3:a5MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:a5MeasSsbRsrp:a5HysteresisSsbRsrp=10
...    NRCELL-1/NRHOIF-3:a5MeasSsbRsrp:a5Threshold1SsbRsrp=30
...    NRCELL-1/NRHOIF-3:a5MeasSsbRsrp:a5Threshold2SsbRsrp=55
...    NRCELL-1/NRHOIF-3:a5MeasSsbRsrp:a5TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20

...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=36
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-1/NRREL-10:lcrId=1
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3

@{meas_Config_cell2}
...    NRCELL-2:a1MeashoEnabledSA=rsrp
...    NRCELL-2:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-2:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL-2:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL-2:a2MeashoEnabledSA=rsrp
...    NRCELL-2:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL-2:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-2:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160
...    NRCELL-2:absThreshSsbRsrpConsolidation=1
...    NRCELL-2:sMeasConfigSsbRsrp=1
...    NRCELL-2:a3MeasEnabled=rsrp
...    NRCELL-2:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80

...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms80
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-1:ssbFrequency=126750
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20

...    NRCELL-2/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-2/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-2/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-2/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-2:freqBandIndicatorNR=257
...    NRCELL-2/NRHOIF-2:ifhoSsbScs=120 KHz
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcDuration=sf1
...    NRCELL-2/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-2/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-2/NRHOIF-2:ssbFrequency=2071675
...    NRCELL-2/NRHOIF-2:ssBurstSetPeriod=20

...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=1
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-2/NRREL-10:lcrId=12
...    NRCELL-2/NRREL-10:removeNotAllowed=false
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3

@{meas_Config_cell12}
...    NRCELL-12:a1MeashoEnabledSA=rsrp
...    NRCELL-12:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-12:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL-12:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL-12:a2MeashoEnabledSA=rsrp
...    NRCELL-12:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL-12:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-12:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160

...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=120 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssbFrequency=2071675
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20

...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3

@{meas_Config_cell13}
...    NRCELL-13:a1MeashoEnabledSA=rsrp
...    NRCELL-13:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL-13:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=39
...    NRCELL-13:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms128
...    NRCELL-13:a2MeashoEnabledSA=rsrp
...    NRCELL-13:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=1
...    NRCELL-13:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL-13:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms160

...    NRCELL-13/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-13/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-13/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-13/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-13/NRHOIF-1:ssbFrequency=127230
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20

...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=36
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:handoverAllowedSA=allowed
...    NRCELL-13/NRREL-10:lcrId=1
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3

${UE_Capa_Support_n257_PerFR}    SEPARATOR=
...    E9A09000575F5A13160003C1A00B0498B800CE1E82813641873E618F28581C130080C47013B8D85181AC118434
...    1020E90186D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE0005800702
...    A0D883AC1184341020F1018656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000
...    000B000E0551B137582308682041D2030C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF0
...    01C00FFC000B000E0541B11B582308682041E2030CAD931562439F11C7B027C62471E439F51CF9863CA1607038
...    784FFF800003FFE0000016001C0A816806F1C610D00151E7E281845ED98AA9001E3C0087104184540A3F7F204B
...    EF0A800C0083C3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A0003882
...    0000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C
...    41000E140000040B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E2080071
...    0400001058158B89A001C41000E230000020B02B170A000388C001C46000004160562E26800711800385000001
...    02C0AC3C46000E230000030B0210740000003804808D00A2026C04182000E98A10851226C73E1C28913639F0E1
...    4489B1CF870A244D8E7C3851226C73E1C4891226C73E1C28103639F022408103639F022408103639F022408103
...    639F022408103639F022408103639F022408103639F022408103639F0214081B1CF810206C30E0003220318C63
...    18C6318C6318C603D04C00F000F07050070300740380030120020301F048010000000080000100400000002000
...    00401000004008000030040000200200001401000802008020000180100000E008004000000100001000800009
...    004000060020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012
...    B022B95A0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA4
...    8080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800060B292019A55574
...    AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAB2C50505E02540A05028140A05028140A050281
...    40A05028140A05000708080600C02004008404008020100C018402004008080600C02018030404030060100C01
...    8402004008080600C02004008804030060100C0180403006080801004020040100040780E1AA1F000102030406
...    070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D0

${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${F633216}    633216
${F523950}    523950

*** Test Cases ***
CB007517-ET-C54_A4_deconfigured_after_A2_then_Intra-DU_HO_with_A3_then_A4_deconfigured
    [Documentation]
    ...    1. This user scenario porpuse is to check A4 deconfigured for non-first circulation after receiving
    ...    inter-freq A2 MR and keep deconfigured then receiving A3 MR inter-freq intra-DU HO succeed at last.
    ...    2. Configuration configuration on BTS CA was not enabled mobility profile is enabled
    ...    NRHOIF with A4 measurement configuration on cell 2 and cell 12
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 2. Throughput is ok.
    ...         b. check first cycle A4 configure and deconfigure then wait second A4 a4SupervisionTimer
    ...         c. send A2 MR during second A4 a4SupervisionTimer,A1/A3 has been configured,A2/A4 was deconfigured.
    ...            Allocate perFR1 MG. DRX has been released.
    ...         d. send a A3 MR of cell2, inter-freq intra-DU HO succeed:HO from cell2 to cell12.and DRX has been setup
    ...         e. check A4 measurement configuration on cell 12 for 3 times
    ...         f. UE deregister is successfully
    [Tags]    QC_196624    C054    chunjian.yang
    UE Attach To Target Cell    cell_id=2
    Send And Verify Throuput
    Trigger A2 During Second A4Fr2SupervisionTimer
    Trigger InterFreA3 Ho    carrierfreq=126750    phycell_id=61
    Wait for a4measure circle and Verify Throuput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C054${/}a2a.ini    wait_string=UEContextRelease::12

CB007517-ET-C55_A4_deconfigured_after_A2_then_iner-gNB_XN_HO_with_A5_then_A4_deconfigured
    [Documentation]
    ...    1. This user scenario porpuse is to check A4 deconfigured for non-first circulation after receiving
    ...    inter-freq A2 MR and keep deconfigured then receiving A5 MR inter-freq inter-gNB Xn HO succeed at last.
    ...    2. Configuration configuration on BTS CA was not enabled mobility profile is enabled
    ...       NRHOIF with A4 measurement configuration on cell 1
    ...    3. Test Case Steps:
    ...         a. UE registers successfully and PDU session is setup successfully on cell 1. Throughput is ok.
    ...         b. check first cycle A4 configure and deconfigure then wait second A4 a4SupervisionTimer
    ...         c. send A2 MR during second A4 a4SupervisionTimer,A1/A5 has been configured,A2/A4 was deconfigured.
    ...            Allocate perFR1 MG. DRX has been released.
    ...         d. send a A5 MR, inter-freq inter-DU HO succeed:HO from cell1 to simgNB cell.
    ...         e. send A5 to trigger Xn Ho back from simgNB to real gNB cell 13
    ...         f. trigger A4 HO to sim gNB cell382
    ...         h. UE deregister is successfully
    [Tags]    QC_196625    C055    chunjian.yang
    UE Attach To Target Cell    cell_id=1
    Send And Verify Throuput
    Trigger A2 at Second A4Fr2SupervisionTimer
    Trigger InterFreA5 Ho sim gNB Cell382    carrierfreq=127230    phycell_id=382
    Trigger A5 Ho back to real gNB Cell13
    Trigger A4 Ho to sim gNB Cell382    carrierfreq=127230    phycell_id=382
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C055${/}a2a.ini    wait_string=UEContextRelease::10

*** Keywords ***
Modify Cfg
    Update Cfg    gnb_endc_param id=4 use_nr_ran_cont=true
    Update Cfg    gnb_endc_param id=4 scg_dl_dist_percent=0
    Update Cfg    gnb_endc_param id=4 enable_dud_poll_bit=0
    Update Cfg    gnb_param id=4 xn_listening_socket=on send_xn_setup=true
    ${set_gnb4}    catenate    set_cell id=1 gnb=4 pci=127:1 tac=200 nrci=0x01 tdd_cell=off proxy=10.0.2.90:9999
    ...    nr_arfcn=127420:136620 gscn=1592 mandatory_for_activation=off
    Update Cfg    ${set_gnb4}

Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}
    Execute Egate Command    gnb_xn_setup_param id=4 reset
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Execute Egate Command    gnb_xn_link_up gnb=4 target=2    GNB-4: XnAP Link with GNB-2
    Update UE capa    ${UE_Capa_Support_n257_PerFR}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Verify Throuput
    [Arguments]    ${Tput_dl}=62    ${Tput_ul}=9    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=10
    Verify Throuput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger A2 During Second A4Fr2SupervisionTimer
    sleep    5s    reason=wait Second A4Fr2SupervisionTimer 5s
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${m633216}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F633216}    event_type=A2
    ${ret}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m633216} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=eventId eventA3
    Should Contain    ${ret}    gapFR1

Trigger InterFreA3 Ho
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=81 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A3
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.12 performed

Wait for a4measure circle and Verify Throuput
    sleep    35s    reason=wait for a4measure circle 35s
    Verify Throuput

Trigger A2 at Second A4Fr2SupervisionTimer
    sleep    5s    reason=wait Second A4Fr2SupervisionTimer 5s
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${m523950}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${F523950}    event_type=A2
    ${ret}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${m523950} event=A2 srsrp_nr=20 srsrq_nr=20
    ...    pass_regexp=eventId eventA5
    Should Contain    ${ret}    gapFR1

Trigger InterFreA5 Ho sim gNB Cell382
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=81 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A5
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=60 nrsrq_nr=60
    ...    pass_regexp=Inter-eNB handover from EXT_ENB-2.1 to ENB-4.1 performed

Trigger A5 Ho back to real gNB Cell13
    Set MeasurementGap and Initial A2 Event in simulator    carrierfreq=127450
    Initial InterFreA5 Ho back    carrierfreq=427970    phycell_id=62

Set MeasurementGap and Initial A2 Event in simulator
    [Arguments]    ${carrierfreq}
    Execute Egate Command    ue_enb_param id=81 measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A2
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ...    pass_regexp=NR RRC Reconfiguration procedure completed successfully

Initial InterFreA5 Ho back
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Execute Egate Command    ue_enb_param id=81 measurement_gap=off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A5
    ${cmd}    catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A5 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=60 nrsrq_nr=60 rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command    ${cmd}
    ...    Inter-eNB handover from ENB-4.1 to EXT_ENB-2.13 performed

Trigger A4 Ho to sim gNB Cell382
    [Arguments]    ${carrierfreq}    ${phycell_id}
    Sleep    7s    #wait for first retrytimer and supervisiontimer timeout
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=81    carrierfreq=${carrierfreq}    event_type=A4
    ${cmd}    catenate    ue_measurement_send_nr id=81 meas_id=${meas_id} event=A4 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id}
    ...    nrsrp_nr=80 nrsrq_nr=80
    ${ret1}=     Execute Egate Command    ${cmd}
    ...    Inter-eNB handover from EXT_ENB-2.13 to ENB-4.1 performed
