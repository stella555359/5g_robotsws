*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env And Start TCE
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Set UE Location And Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    team-L3CN1_SG14
...    owner-alex.2.wang    release-SBTS22R4    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    fddtdd_sansa_cmwv/6cells_4T2F

@{PARAMS_IN_SCF}
...    @{TCE}
...    @{CellTrace_PCMD_Enable}
...    @{HO}
...    @{CA}
...    @{A2SgnbRelease}
@{TCE}
...    MRBTS/MNL-1/TCEADM-1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIdentifier=1
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tceIpAddress=${TCE_IP}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tcePortNumber=${TCE_PORT}
...    MRBTS/MNL-1/TCEADM-1/TCE-1:tlsEnabled=false
...    NRBTS/NRCTRLTS-1
@{CellTrace_PCMD_Enable}
...    @{NRMTRACECU}
...    @{CellTrace_Enable}
...    @{traceAll}
...    @{PCMD_Enable}
...    @{1UE_infinityreport}
@{NRMTRACECU}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:cellMaxActiveUEsTraced=100
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrTceIdentifier=1
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:scope=allResources
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mcc=311
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mnc=489
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:mncLength=3
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:nrRanTraceReference:traceId=1
@{CellTrace_Enable}
...    NRBTS:actMDTTraceReport=true
...    NRBTS:actCellTraceReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actCellTraceReportingCU=true
@{PCMD_Enable}
...    NRBTS:actPCMDReport=true
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:actPCMDReporting=true
@{traceAll}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNRRRCSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceX2Setting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceNGAPSetting=all
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:traceXNSetting=all
@{1UE_infinityreport}
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:jobType=ImmediateMDTAndTrace
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:mdtMeasType=periodic
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportAmount=infinity
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTUEMeas:reportInterval=ms5120
...    NRBTS/NRCTRLTS-1/NRMTRACECU-1:immedMDTControl:cellMaxActiveMDTUEsTraced=1
@{HO}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=false
...    NRBTS:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:srb3SupportEnabled=true
...    NRBTS:actConflictConfiguration=true
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=40
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoEnabled=rsrq
...    NRCELL:a2MeashoSsbRsrq:a2HysteresishoSsbRsrq=0
...    NRCELL:a2MeashoSsbRsrq:a2ThresholdhoSsbRsrq=31
...    NRCELL:a2MeashoSsbRsrq:a2TimeToTriggerhoSsbRsrq=ms480
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=10
...    NRCELL-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms0
...    NRCELL-1:measGapSelection=favourUeThroughput
...    NRCELL-1:measGapSelectionSA=favourUeThroughput
...    NRCELL-1:absThreshSsbRsrpConsolidation=1
...    NRCELL-1:sMeasConfigSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=30
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-1:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=30
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=0ms
...    NRCELL-11:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=5
...    NRCELL-11:measGapSelection=favourUeThroughput
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:sCellPrio=1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:lcrId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-10:sCellPrio=1
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=125050
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=30
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ssbFrequency=632736
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=30
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=30
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=30
${CA_support_list}    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Nsa
@{CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=2CCDL_2CCUL
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=blind
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRDU-1:actInterNumerologyCa=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=30
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=40ms
...    NRCELL:a1MeasPCellSwitchEnabled=rsrq
...    NRCELL:a1MeasPCellSwitchSsbRsrq:a1HysteresisPCellSwitchSsbRsrq=0
...    NRCELL:a1MeasPCellSwitchSsbRsrq:a1ThresholdPCellSwitchSsbRsrq=40
...    NRCELL:a1MeasPCellSwitchSsbRsrq:a1TimeToTriggerPCellSwitchSsbRsrq=40ms
@{A2SgnbRelease}
...    NRBTS:actA2SgnbRelease=true
...    NRCELL:a2MeasReleaseEnabled=rsrp
...    NRCELL:a2MeasReleaseSsbRsrp:a2HysteresisReleaseSsbRsrp=0
...    NRCELL:a2MeasReleaseSsbRsrp:a2ThresholdReleaseSsbRsrp=34
...    NRCELL:a2MeasReleaseSsbRsrp:a2TimeToTriggerReleaseSsbRsrp=ms480

${Comon_NR_UE}    SEPARATOR=
...    e9a09000575f5a13160003c2a002c1262e003387a0e026c830e7cc31e50b03826010188e01f71b0a303582308682041d207036b64c558d0e7c471e819f604f8c48e3c873ea39f
...    30c7942c0e070f05c00ffc0070005f0003c000e0541b107582308682041e207032b64c55890e7d813e238f1891c790e7d473e618f28581c0e1e13fb000000fec00000078001c0
...    aa3626eb04610d04083a40e0616c98aa221cf88e3c471e819f604f8c73e618f28581c0e1e0b801ff800e007fe00078001c0a836236b04610d04083c40e0656c98ab121cf88e3d
...    813e31238f21cfa8e7cc31e50b0381c3c24f013c00f0003800830713400000822070a000000823071180000002307104000000200e0234028809b01042d02b024089b1cf81022
...    6c73e04089b1cf810226c73e000090418c631e8260078005038280381804a00e000c0480080c07c120040000000200000401000000008000010040000100200000c0100000800
...    8000050040020080200800006004000038020010000000400004002000024010000060080000a004000058020010240900400006019ca9aca9ac14ac0cac19ac15aca5ac99ac0
...    5ac0dac04ac08ac1da0682000012ca4a080000cb29282000052ca48080001cb29202000092ca48080002cb292020000d2ca48080003cb29202000112ca48080004cb292020001
...    52ca48080005cb29282000192ca480800018b292019a55574aaaa9545d2a8aa0b154162a83455298aa4d154062a8145526aaa0f142405e02540a05028140a05028140a0502814
...    0a05028140a05000100080600c0010020046a87c0004080c10181c282c30344044484c5060646c70747c8494989ca0a4a8b4bd05060b40

${Comon_MRDC_UE}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881785818070A0000000580817898180710400388C0000042C04
...    0BC6C0C0388C001C41000E208000020B0102F130300E2680070A000001858081009011A014003808301343D016A0F1274489B1CF871274489B1CF871274489B1CF870A744D8E7
...    C3893A24498E7D1A7448912639F449D1224C73E0340E318C6318C18041000040202004010080600C2000080404008010100C01860001008080600C02018030080600C20000804
...    04008020100200800000000

${None_SINR_NR_UE}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88E3D033EC09F1891C790E7D473E61
...    8F28581C0E1E0B801FF800E000BE000280381506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD8000000500702A8D89
...    BAC1184341020E9008C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC000500702A0D88DAC1184341020F1008CAD931562439F11C7B027C6247
...    1E439F51CF9863CA16070387849E027800A00E0020C1C4D0000020881C2800000208C1C4600000008C1C410000000803808D00A2026C04105456048113639F02044D8E7C08113
...    639F02044D8E7C0001208318C63D02C03C00281C0C0381002A0380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401000
...    802008020000180100000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B016B036B012B0
...    22B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B292020001
...    72CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A93455018AA051549AAA83C501178095028140A05028140A05028140A05028140A050281
...    40004002018030004008011AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F414182D

${None_SRB3_MRDC_UE}    SEPARATOR=
...    A11FF83BC4C0C03850001C46000000162205E260601C4D000E230000000B1102F130300E26800710400000058881785818070A0000000580817898180710400388C0000042C04
...    0BC6C0C0388C001C41000E208000020B0102F130300E2680070A000001858081009011A014003808301341D16A0F1274489B1CF871274489B1CF871274489B1CF870A744D8E7C
...    3893A24498E7D1A7448912639F449D1224C73E0340E318C6318C00041000040202004010080600C2000080404008010100C01860001008080600C02018030080600C200008040
...    40080201002008000000000

*** Test Cases ***
CB008196-ET-B002_Periodic Measurements configuration on sgNB Addition for MeNB initiated inter-MeNB handover with Inter-Frequency PSCell change
    [Documentation]
    ...    This case is to Verify None SINR UE51 UE52 can be traced when MeNB initiated HO with PSCell change:
    ...    internal count cellActivePeriodicUETraced increment when incoming HO.
    ...    internal count cellActivePeriodicUETraced decrement when outcoming HO.
    ...    candidate cell hex value: 0907A1E821E0 is for Cell11 with pci=60 and ssbFrequency=125050
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE51 with None SINR Capa Attach And Initial Endc on Cell1
    ...         b. UE51 trigger Inter MeNB HO from eNB1 Cell1 to eNB11 Cell1, SCG change from Cell1 to Cell11
    ...         c. NSA UE52 with None SINR Capa Attach And Initial Endc on Cell1
    ...         d. NSA UE41 with SINR Capa Attach And Initial Endc on Cell11
    ...    3. Expected Results:
    ...         Step a: UE51 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step b: UE51 Inter MeNB HO Success, Endc on gNB Cell11, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    ...         Step c: UE52 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step d: UE41 not set PeriodicUeMeas config due to Cell11 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_194780
    None SINR UE Attach And Initial Endc With PeriodicUeMeas    ue_id=51
    None SINR UE Trigger Inter MeNB HO with SCG Change With PeriodicUeMeas    ue_id=51
    None SINR UE Attach And Initial Endc With PeriodicUeMeas    ue_id=52
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=41    target_cells=11
    Release Ues    ue_type=all

CB008196-ET-B004_Periodic Measurements configuration on SgNB initiated Inter-Frequency intra-DU PSCell change With and without SRB3
    [Documentation]
    ...    This case is to Verify SRB3 UE41 and None SRB3 UE55/56 can be traced when SgNB initiated HO with PSCell change:
    ...    internal count cellActivePeriodicUETraced increment when incoming HO.
    ...    internal count cellActivePeriodicUETraced decrement when outcoming HO.
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 with SRB3 Capa Attach And Initial Endc on Cell1
    ...         b. UE41 trigger HO from Cell1 to Cell11
    ...         c. NSA UE55 with None SRB3 Capa Attach And Initial Endc on Cell1
    ...         d. UE55 trigger HO from Cell1 to Cell11
    ...         e. UE41 detach
    ...         f. NSA UE56 with None SRB3 Capa Attach And Initial Endc on Cell1
    ...         g. UE56 trigger HO from Cell1 to Cell11
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step b: UE41 HO Success, UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    ...         Step c: UE55 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step d: UE55 HO Success
    ...                 UE55 not set PeriodicUeMeas config due to Cell11 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step e: UE41 detach success, Cell11 internal count cellActivePeriodicUETraced decrement to 0
    ...         Step f: UE56 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step g: UE56 HO Success, UE56 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    [Tags]    QC_193142
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Trigger Inter Frequency HO with Measurement Report A3 With PeriodicUeMeas    ue_id=41
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=55
    NSA UE Trigger Inter Frequency HO with Measurement Report A3 Without PeriodicUeMeas    ue_id=55
    NSA UE Detach    ue_id=41
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=56
    NSA UE Trigger Inter Frequency HO with Measurement Report A3 With PeriodicUeMeas    ue_id=56
    Release UEs    ue_type=all

CB008196-ET-B005_Periodic Measurements configuration on MeNB initiated Inter-Frequency intra-DU PSCell change With and without SRB3
    [Documentation]
    ...    This case is to Verify SRB3 UE41/42 and None SRB3 UE55 can be traced when MeNB initiated HO with PSCell change:
    ...    internal count cellActivePeriodicUETraced increment when incoming HO.
    ...    internal count cellActivePeriodicUETraced decrement when outcoming HO.
    ...    candidate cell hex value: 0907A1E821E0 is for Cell11 with pci=60 and ssbFrequency=125050
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 with SRB3 Capa Attach And Initial Endc on Cell1
    ...         b. UE41 trigger Intra MeNB HO from eNB Cell1 to eNB Cell2, SCG change from Cell1 to Cell11
    ...         c. NSA UE42 with SRB3 Capa Attach And Initial Endc on Cell1
    ...         d. UE42 trigger HO from Cell1 to Cell11
    ...         e. UE41 detach
    ...         f. NSA UE55 with None SRB3 Capa Attach And Initial Endc on Cell1
    ...         g. UE55 trigger Intra MeNB HO from eNB Cell1 to eNB Cell11, SCG change from Cell1 to Cell11
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step b: UE41 Inter MeNB HO Success, Endc on gNB Cell11, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    ...         Step c: UE42 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step d: UE42 HO Success, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 UE42 not set PeriodicUeMeas config due to Cell11 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step e: UE41 detach Success, Cell11 internal count cellActivePeriodicUETraced decrement to 0
    ...         Step f: UE55 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step g: UE55 Inter MeNB HO Success, Endc on gNB Cell11, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    [Tags]    QC_193140
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Trigger Intra MeNB HO with SCG Change With PeriodicUeMeas
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=42
    NSA UE Trigger Inter Frequency HO With Measurement Report A3 Without PeriodicUeMeas    ue_id=42
    NSA UE Detach
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=55
    NSA UE Trigger Intra MeNB HO with SCG Change With PeriodicUeMeas    ue_id=55
    Release UEs    ue_type=all

CB008196-ET-B008_Periodic Measurements configuration on SgNB initiated PSCell change for meas-based CA
    [Documentation]
    ...    This case is to Verify SRB3 UE41 can be traced when MeNB initiated HO with PSCell Switch:
    ...    internal count cellActivePeriodicUETraced increment when PSCell switch in.
    ...    internal count cellActivePeriodicUETraced decrement when PSCell switch out.
    ...    CA setup successfully and no impact on UE report
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 Attach And Initial Endc on Cell1, UE41 trigger CA Setup, add SCELL Cell11
    ...         b. UE41 trigger PSCell Switch, PSCELL Switch to Cell11
    ...         c. UE41 add SCELL Cell1
    ...         d. NSA UE42 Attach And Initial Endc on Cell1, UE42 trigger CA Setup, add SCELL Cell11
    ...         e. UE42 trigger PSCell Switch, PSCELL Switch to Cell11
    ...         f. UE41 trgger SCELL release
    ...         g. NSA UE43 Attach And Initial Endc on Cell11
    ...         h. UE41 release SCELL Cell1
    ...         i. NSA UE44 Attach And Initial Endc on Cell11
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...                 UE41 CA Setup Success, SCELL Cell11 addition Success, Cell1 and Cell11 internal count cellActivePeriodicUETraced no change
    ...         Step b: PSCELL Switch to Cell11, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    ...         Step c: UE41 SCELL Cell11 addition Success, Cell1 and Cell11 internal count cellActivePeriodicUETraced no change
    ...         Step d: UE42 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...                 UE42 CA Setup Success, SCELL Cell11 addition Success, Cell1 and Cell11 internal count cellActivePeriodicUETraced no change
    ...         Step e: PSCELL Switch to Cell11, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 UE42 not set PeriodicUeMeas config due to Cell11 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step f: UE41 SCELL Cell11 release Success, Cell1 and Cell11 internal count cellActivePeriodicUETraced no change
    ...         Step g: UE43 not set PeriodicUeMeas config due to Cell11 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    ...         Step h: UE41 detach Success, Cell11 internal count cellActivePeriodicUETraced decrement to 0
    ...         Step i: UE44 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    [Tags]    QC_194783
    NSA UE Attach And Initial Endc With PeriodicUeMeas And Setup CA    ue_id=41
    PSCell Switch Via A2 Measurement With PeriodicUeMeas
    CA Setup Via A1 Measurement    cellfreq=125050    srsrp_nr=120
    NSA UE Attach And Initial Endc With PeriodicUeMeas And Setup CA    ue_id=42
    PSCell Switch Via A2 Measurement Without PeriodicUeMeas    ue_id=42
    CA Release Via A2 Measurement    ue_id=41
    NSA UE Attach And Initial Endc Without PeriodicUeMeas    ue_id=43    target_cells=11
    NSA UE Detach    ue_id=41
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=44    target_cells=11    cellfreq=125050
    Release UEs    ue_type=all

CB008196-ET-B013_Handling on call release for MeNB or SgNB initiated
    [Documentation]
    ...    This case is to Verify internal count cellActivePeriodicUETraced decrement when MeNB or SgNB initiated call release
    ...    [Configuration]: NRMTRACECU-1:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced=1
    ...    2.Test Case Steps:
    ...         a. NSA UE41 Attach And Initial Endc on Cell1
    ...         b. UE41 trigger HO from Cell1 to Cell11
    ...         c. UE41 trigger A2 based sgNB release
    ...         d. NSA UE42 Attach And Initial Endc on Cell1
    ...         e. UE42 trigger HO from Cell1 to Cell11
    ...         f. NSA UE43 Attach And Initial Endc on Cell1
    ...         g. UE43 trigger HO from Cell1 to Cell11
    ...    3. Expected Results:
    ...         Step a: UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step b: UE41 HO Success, UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    ...         Step c: UE41 detach success, Cell11 internal count cellActivePeriodicUETraced decrement to 0
    ...         Step d: UE42 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step e: UE41 HO Success, UE41 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced decrement to 0
    ...                 Cell11 internal count cellActivePeriodicUETraced increment to 1
    ...         Step f: UE43 set PeriodicUeMeas config, Cell1 internal count cellActivePeriodicUETraced increment to 1
    ...         Step g: UE43 HO Success
    ...                 UE43 not set PeriodicUeMeas config due to Cell11 internal count cellActivePeriodicUETraced reached cellMaxPeriodicUEsTraced
    [Tags]    QC_198926
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=41
    NSA UE Trigger Inter Frequency HO with Measurement Report A3 With PeriodicUeMeas    ue_id=41
    NSA UE Trigger A2 Based SgNB Release
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=42
    NSA UE Trigger Inter Frequency HO With Measurement Report A3 With PeriodicUeMeas    ue_id=42
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=43
    NSA UE Trigger Inter Frequency HO With Measurement Report A3 Without PeriodicUeMeas    ue_id=43
    Release ues    ue_type=all
    Check Wireshark Log    ${CURDIR}/a2a_B013/a2a.ini

*** Keywords ***
Common Suite Setup And Setup Airphone Env And Start TCE
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}
    Perform Steps After Onair

Perform Steps After Onair
    Start TCE    ${TCE_PORT}
    Set eNB X2 link And Allow Endc On

Set eNB X2 link And Allow Endc On
    Execute Egate Command    enb_x2_link_up enb=1 target=3    is up
    Execute Egate Command    enb_x2_link_up enb=11 target=2    is up
    Execute Egate Command    enb_cell_param enb=1 id=1 allow_endc=on
    Execute Egate Command    enb_cell_param enb=1 id=2 allow_endc=on
    Execute Egate Command    enb_cell_param enb=11 id=1 allow_endc=on

Set UE Location And Common Test Teardown And Stop Capture Logs
    Set UE Location
    Common Test Teardown And Stop Capture Logs

Modify Cfg
    ${eNB1_Cell2_sim_configuration}    catenate
    ...    set_cell id=2 enb=1 eci=0x1234602 pci=4:0 tac=222 proxy=10.0.2.1:12220|10.0.2.1:8890 earfcn=2000:20000 mapped_earfcn=4200:22200
    ...    mandatory_for_activation=off
    Update Cfg    ${eNB1_Cell2_sim_configuration}
    ${eNB11_sim_configuration}    catenate
    ...    set_enb id=11 plmn=311:489 s1=10.0.1.126 enb_id_macro=0x12347 daemon=10.0.2.1:22222 x2=10.0.1.14 x2u=10.0.1.137 type=simulated x2_peers=1
    Update Cfg    ${eNB11_sim_configuration}
    Update Cfg    enb_param id=11 drb_id_begin=3 endc_capable_qci=all
    ${eNB11_Cell1_sim_configuration}    catenate
    ...    set_cell id=1 enb=11 eci=0x1234701 pci=7:2 tac=222 proxy=10.0.2.1:8887 earfcn=2000:20000 tdd_cell=on mandatory_for_activation=off
    Update Cfg    ${eNB11_Cell1_sim_configuration}
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=1:7
    Update Cfg    ue_param id=51 ue_nr_capabilities=${None_SINR_NR_UE} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Comon_MRDC_UE}
    Update Cfg    ue_param id=52 ue_nr_capabilities=${None_SINR_NR_UE} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Comon_MRDC_UE}
    Update Cfg    ue_param id=55 ue_nr_capabilities=${Comon_NR_UE} dual_conn=eutra_nr ue_eutra_nr_capabilities=${None_SRB3_MRDC_UE}
    Update Cfg    ue_param id=56 ue_nr_capabilities=${Comon_NR_UE} dual_conn=eutra_nr ue_eutra_nr_capabilities=${None_SRB3_MRDC_UE}

Set UE Location
    Execute Egate Command    ue_change_location id=41 enb=1 cell=1
    Execute Egate Command    ue_change_location id=42 enb=1 cell=1
    Execute Egate Command    ue_change_location id=51 enb=1 cell=1
    Execute Egate Command    ue_change_location id=55 enb=1 cell=1

NSA UE Attach And Initial Endc With PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2    ${cellfreq}=632736
    Execute Egate Command    ue_attach id=${ue_id} profile=1    pass_regexp=UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Contain    ${ret1}    reportType periodical
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

None SINR UE Attach And Initial Endc With PeriodicUeMeas
    [Arguments]    ${ue_id}=51    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2    ${cellfreq}=632736
    Execute Egate Command    ue_attach id=${ue_id} profile=1    pass_regexp=UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Contain    ${ret1}    reportType periodical
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 srs_result=0:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Attach And Initial Endc Without PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${target_gnb}=2    ${target_cells}=1    ${bearer_id}=2
    Execute Egate Command    ue_attach id=${ue_id} profile=1    pass_regexp=UE IS ACTIVE
    ${cmd}     Catenate    ue_dc_enb_start ue=${ue_id} target_gnb=${target_gnb} target_cells=${target_cells} bearer=${bearer_id} type=split_scg
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity    timeout=20s
    Should Not Contain    ${ret1}    reportType periodical
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

None SINR UE Trigger Inter MeNB HO with SCG Change With PeriodicUeMeas
    [Arguments]    ${ue_id}=51    ${scg_cell}=0907A1E821E0    ${targetcellfreq}=125050
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${scg_cell}
    ${cmd}     Catenate    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=11 cell=1
    Execute Egate Command    ${cmd}    pass_regexp=Inter-eNB handover from .*ENB-1.1 to ENB-11.1 performed
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetcellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 srs_result=0:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Detach
    [Arguments]    ${ue_id}=41
    ${cmd}     Catenate    enb_ue_dc_release ue=${ue_id} bearer=2 by=enb cause=MISC_CauseMisc_unspecified
    Execute Egate Command    ${cmd}    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Execute Egate Command    ue_detach id=${ue_id}    pass_regexp=UE IS OFF

Set MeasurementGap On And Initial Measurement Report A2
    [Arguments]    ${ue_id}=41    ${cellfreq}=632736
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRQ 31
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=7 srsrq_nr=7
    ${ret1}=    Execute Egate Command    ${cmd}    pass_regexp=Sending SgNB Modification Confirm
    Should Contain    ${ret1}    measGapConfig setup
    Should Not Contain    ${ret1}    reportType periodical
    [Teardown]    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off

NSA UE Trigger A2 Based SgNB Release
    [Arguments]    ${ue_id}=41    ${cellfreq}=125050
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRP 34
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=11 srsrq_nr=11
    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity

NSA UE Trigger Inter Frequency HO With Measurement Report A3 With PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${phycell_id}=60    ${targetcellfreq}=125050
    Set MeasurementGap On And Initial Measurement Report A2    ue_id=${ue_id}
    ${A3_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetcellfreq}    event_type=A3
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=30 srsrq_nr=40 phycell_id=${phycell_id}
    ...    nrsrp_nr=50 nrsrq_nr=50
    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetcellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Trigger Inter Frequency HO With Measurement Report A3 Without PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${phycell_id}=60    ${targetcellfreq}=125050
    Set MeasurementGap On And Initial Measurement Report A2    ue_id=${ue_id}
    ${A3_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetcellfreq}    event_type=A3
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${A3_meas_id} event=A3 srsrp_nr=30 srsrq_nr=40 phycell_id=${phycell_id}
    ...    nrsrp_nr=50 nrsrq_nr=50
    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    ${ret1}=    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr    pass_regexp=NR MEASUREMENT IDENTITIES
    Should Not Contain    ${ret1}    NR\ \ \ Periodical
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

NSA UE Trigger Intra MeNB HO with SCG Change With PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${scg_cell}=0907A1E821E0    ${targetcellfreq}=125050
    Execute Egate Command    ue_enb_endc_param id=${ue_id} candidate_cells_mn_hex_for_menb_ho=${scg_cell}
    Execute Egate Command    ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetcellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

CA Setup Via A1 Measurement
    [Arguments]    ${ue_id}=41    ${cellfreq}=632736    ${srsrp_nr}=90
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrq_nr=60 srsrp_nr=${srsrp_nr}
    Execute Egate Command    ${cmd}    pass_regexp=SCellIndex .* activated successfully at airphone
    Trigger UE Send One Periodic MR    ue_id=${ue_id}    cellfreq=${cellfreq}

NSA UE Attach And Initial Endc With PeriodicUeMeas And Setup CA
    [Arguments]    ${ue_id}=41
    NSA UE Attach And Initial Endc With PeriodicUeMeas    ue_id=${ue_id}
    CA Setup Via A1 Measurement    ue_id=${ue_id}

CA Release Via A2 Measurement
    [Arguments]    ${ue_id}=41    ${cellfreq}=632736
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRP 30
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=0 srsrq_nr=0 scell=2 scell_rsrp=20 scell_rsrq=35
    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity

PSCell Switch Via A2 Measurement With PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${cellfreq}=632736    ${targetcellfreq}=125050
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRP 30
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11 scell=2
    ...    scell_rsrp=100 scell_rsrq=45
    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${targetcellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

PSCell Switch Via A2 Measurement Without PeriodicUeMeas
    [Arguments]    ${ue_id}=41    ${cellfreq}=632736    ${targetcellfreq}=125050
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ...    threshold=RSRP 30
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} event=A2 meas_id=${meas_id} srsrp_nr=11 srsrq_nr=11 scell=2
    ...    scell_rsrp=100 scell_rsrq=45
    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB .* cell .*\\) reported successful RA
    ${ret1}=    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr    pass_regexp=NR MEASUREMENT IDENTITIES
    Should Not Contain    ${ret1}    NR\ \ \ Periodical
    Traffic Should Be Ok    ue_id=${ue_id}    type=NSA

Trigger UE Send One Periodic MR
    [Arguments]    ${ue_id}=41    ${cellfreq}=632736
    ${Periodical_meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}
    ...    event_type=Periodical
    Should Not Be Empty    ${Periodical_meas_id}
    ${cmd}     Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${Periodical_meas_id} report_type=periodical
    ...    srsrp_nr=${ue_id} srsrq_nr=30 ssinr_nr=30 srs_result=0:50:50:50 rs_type=ssb
    ...    phycell_id=51 nrsrp_nr=51 nrsrq_nr=50 nsinr_nr=50
    ...    phycell_id=52 nrsrp_nr=52 nrsrq_nr=50 nsinr_nr=50
    ...    index=0 nrs_result=1:2:3 index=1 nrs_result=4:5:6
    ...    scell=1 scell_rsrp=51 scell_rsrq=52 scell_sinr=53
    ...    scell_rs_index=1 scell_rs_result=11:12:13
    ...    scell_rs_index=2 scell_rs_result=21:22:23
    ...    scell_rs_index=3 scell_rs_result=31:32:33
    ...    scell=2 scell_rsrp=61 scell_rsrq=62 scell_sinr=63
    ...    scell_rs_index=1 scell_rs_result=41:42:43
    Execute Egate Command    ${cmd}    pass_regexp=For Periodic MeasId = .* MeasReportQuantity from RRC-reconfiguration
    Sleep    10s    #SleepTime>reportInterval, wait atleast one updated Periodic MR send out
