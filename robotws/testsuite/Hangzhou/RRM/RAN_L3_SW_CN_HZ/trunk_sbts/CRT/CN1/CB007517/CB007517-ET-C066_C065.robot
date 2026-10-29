*** Settings ***
Documentation    Suite description
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Beam    owner-kexin.bao
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    @{meas_Config}
...    @{mobility_profile_config}
...    @{GAP_Conf_sf10}

@{GAP_Conf_sf10}
...    NRCELL:ifhoSsbSmtcOffset=8
...    NRCELL:gapOffset=8
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf10

@{meas_Config}
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min

...    NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000
...    NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=1000
...    NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=65
...    NRCELL:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=6000
...    NRCELL:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=6000
...    NRCELL:a4PeriodicMeasControlNSA:a4MeasMaxNumber=3
...    NRCELL:a4PeriodicMeasControlNSA:a4RetryTimer=20

...    NRCELL:measGapSelection=favourUeThroughput
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:cellDepType=SA+NSA
...    NRCELL/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1
...    NRCELL/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL/NRHOIF-1:freqBandIndicatorNR=257
...    NRCELL/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-1:ssbFrequency=2075419
...    NRCELL/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-2:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-2:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-2:a4PriorityForHigherPrioFreqHo=2
...    NRCELL/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL/NRHOIF-2:freqBandIndicatorNR=257
...    NRCELL/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-2:ssbFrequency=2071387
...    NRCELL/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL/NRHOIF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-3:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-3:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-3:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL/NRHOIF-3:freqBandIndicatorNR=41
...    NRCELL/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-3:ssbFrequency=518910
...    NRCELL/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL/NRHOIF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-4:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-4:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-4:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-4:a4PriorityForHigherPrioFreqHo=4
...    NRCELL/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL/NRHOIF-4:freqBandIndicatorNR=78
...    NRCELL/NRHOIF-4:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-4:ssbFrequency=636768
...    NRCELL/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL/NRHOIF-5:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL/NRHOIF-5:a4MeasSsbRsrq:a4ThresholdSsbRsrq=20
...    NRCELL/NRHOIF-5:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL/NRHOIF-5:cellDepType=SA+NSA
...    NRCELL/NRHOIF-5:freqBandIndicatorNR=41
...    NRCELL/NRHOIF-5:ifhoSsbScs=30 KHz
...    NRCELL/NRHOIF-5:ifhoSsbSmtcDuration=sf2
...    NRCELL/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL/NRHOIF-5:ssbFrequency=518890
...    NRCELL/NRHOIF-5:ssBurstSetPeriod=20

@{mobility_profile_config}
...    NRBTS-1:actMobilityProfile=true
...    NRBTS-1:actRanSharing=true
...    delete:MRBTS-1/NRBTS-1/NRCELL:trackingAreaDN
...    delete:MRBTS-1/NRBTS-1/NRCELL:configuredEpsTac
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    MRBTS-1/NRBTS-1/NRCELL/NRPLMNSET_SA-1:trackingAreaDN=MRBTS-1/NRBTS-1/TRACKINGAREA-200
...    NRCELL/NRPLMNSET_NSA-1
...    NRCELL/NRPLMNSET_NSA-1:configuredEpsTac=200
...    NRCELL/NRPLMNSET_NSA-1:nrPlmnDNList=MRBTS-1/NRBTS-1/NRPLMN-1
...    NRCELL:nrDefMoPrNsaDN=MRBTS-1/NRBTS-1/NRMOPR_NSA-1

...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=1
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:freqBandIndicatorNR=41
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:ssbFrequency=518910
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-2:a4PriorityForHigherPrioFreqHo=2
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-2:freqBandIndicatorNR=257
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-2:ssbFrequency=2075419
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-3:a4MeasHigherPrioFreqEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-3:a4PriorityForHigherPrioFreqHo=3
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-3:freqBandIndicatorNR=78
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-3:ssbFrequency=636768
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:a4PriorityForHigherPrioFreqHo=4
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:freqBandIndicatorNR=41
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:ssbFrequency=518890
...    MRBTS-1/NRBTS-1/NRMOPR_SA-1:nrMeasCfgIfDNList=${NRMEASCFG_IF_4Nodes}
...    NRBTS-1/NRMOPR_SA-1:a1MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-1:a2MeasRedirectEnabled=none
...    NRBTS-1/NRMOPR_SA-1:a2MeashoEnabledSA=rsrp
...    NRBTS-1/NRMOPR_SA-1:emergencyCallFails=disabled
...    NRBTS-1/NRMOPR_SA-1:emergencyFBMode=disabled
...    NRBTS-1/NRMOPR_SA-1:voiceFBMode=disabled

...    NRCELL:nrDefMoPrSaDN=MRBTS-1/NRBTS-1/NRMOPR_SA-1
...    NRBTS-1/NRMOPR_NSA-1
...    NRBTS-1/NRMOPR_NSA-1:a3MeasEnabled=none

...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=4
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=33
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=4
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=53
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=2
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms80
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=2
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms80

${NRMEASCFG_IF_4Nodes}    SEPARATOR=
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1,MRBTS-1/NRBTS-1/NRMEASCFG_IF-2,MRBTS-1/NRBTS-1/NRMEASCFG_IF-3,
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4

${UE_Capa_Support_n257_n41_n78}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623809DC6C28C0D608C21
...    A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000
...    E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD8000007F6
...    00000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C170
...    03FF001C00FFC00110001C0A836236B04610D04083C412032B64C55890E7C471EC09F1891C790E7D473E618F28
...    581C0E1E13FFE00000FFF80000088000E0540B40378E3086800A8F3F1424045ED98AA9001E3C0087104184540A
...    3F7F204BEF108001801078789A001C4100000216020541E14000711800000858158788C001C41000006160561E
...    14000710400000858158789A001C46000002160562E2300071040038820000142C0AC3C28000E268000060B02B
...    17134003882001C28000008160562E26800711800388C0000082C0AC5C28000E20800711800001058158B85000
...    1C41000E208000020B02B17134003882001C46000004160562E14000711800388C0000082C0AC5C4D000E23000
...    70A000002058158788C001C46000006160420E80000007009011A014404D808304003506284214489B1CF870A2
...    44D8E7C3851226C73E1C28913639F0E14489B1CF871224489B1CF870A040D8E7C08902040D8E7C08902040D8E7
...    C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C08902040D8E7C0850206C73E04081B0C38000
...    C880C6318C6318C6318C63180F413003C002C1C1401C0C02500700060240040603E09002000000010000020080
...    000000400000802000008010000060080000400400002802001004010040000300200001C01000800000020000
...    20010000120080000C0040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD60
...    2D606D6025604572B40D04000025949410000196525040000A5949010000396524040001259490100005965240
...    40001A594901000079652404000225949010000996524040002A5949010000B9652504000325949010000C1652
...    40334AAAE955552A8BA55154162A82C55068AA531549A2A80C55028AA4D55658A1202F012A05028140A0502814
...    0A05028140A05028140A0502800384040300601002004202004010080600C20100200404030060100C01820201
...    8030080600C201002004040300601002004402018030080600C02018030404008020100200800203C070D50F80
...    00810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C168

@{OnlineParam_prepare_for_C066_UE2}
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=45
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=1

@{OnlineParam_prepare_for_C066_UE3}
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=1000
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=1

@{OnlineParam_for_C065}
...    NRBTS-1:actMobilityProfile=false
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=64
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=10000

@{OnlineParam_NRCELL_A4configuration_UE1}
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=66
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=9000
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=55
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms320

@{OnlineParam_NRCELL_A4configuration_UE2}
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=47
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=2000
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=1
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=65
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms320

@{OnlineParam_NRCELL_A4configuration_UE3}
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=3
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=8
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=4000
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=2
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=55
...    NRCELL-11/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms320

@{OnlineParam_NRHOIF_A4configuration}
...    NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-11/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrq

@{OnlineParam_prepare_C065_UE2}
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=45
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=6000
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
...    NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL-11/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled =rsrp

@{OnlineParam_prepare_C065_UE3}
...    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=5
...    NRCELL-11:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=1000
...    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=1
...    NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL-11/NRHOIF-5:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled =rsrp

${ue_id}    81
${cell_id}    11
${pdu_id}    1

*** Test Cases ***
CB007517-ET-C066_online_parameter_change_with_mobility_profile_case2
    [Documentation]
    ...    1. This user scenario porpuse is to check the gNB behaviour on UE context can be the same
    ...    when a4MeasMaxNumber and a4MeasHigherPrioFreq are modified.
    ...    2. Configuration
    ...    configuration on BTS
    ...    CA was not enabled
    ...    mobility profile is enabled
    ...    NRHOIF configuration on cell 11
    ...    UE will be in 3 different states:
    ...    UE1:inter-frequency A4 measurements are configured and a4SupervisionTimer is running
    ...    UE2:inter-frequency A4 measurements are configured and later deconfigured on expiry of
    ...    a4SupervisionTimer,a4RetryTimer is running
    ...    UE3:inter-frequency A4 measurements has been configured and later unconfigured 'a4MeasMaxNumber' times
    ...    3. Test Case Steps:
    ...    a. for UE1, a4MeasMaxNumber=0 is modified online, A4 configuration and de-configuration circle will be infinite.
    ...    b. for UE1, delete NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled, A4 measurement configuration should
    ...    contain other NRMEASCFG_IF.
    ...    c. for UE1, NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=3 is modified online, then measids are
    ...    not in the same order.
    ...    d. for UE2, a4MeasMaxNumber=0 is modified online, A4 configuration and de-configuration circle will be infinite.
    ...    e. for UE2, delete NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled, A4 measurement configuration should
    ...    contain other NRMEASCFG_IF.
    ...    f. for UE2, NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=3 is modified online, then measids are not
    ...    in the same order.
    ...    g. for UE3, a4MeasMaxNumber=0 is modified online, no impact on UE.
    ...    h. for UE3, delete NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled, no impact on UE.
    ...    i. for UE3, NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=3 is modified online, no impact on UE.
    [Tags]    QC_191460    owner-kexin.bao    C066
	stop capture wireshark log
    Update UE capa    ${UE_Capa_Support_n257_n41_n78}
    Online Modification With Mobility Profile for UE1
    Online Modification With Mobility Profile for UE2
    Online Modification With Mobility Profile for UE3

CB007517-ET-C065_online_parameter_change_wo_mobility_profile_case1
    [Documentation]
    ...    1. This user scenario porpuse is to check the gNB behaviour on UE context can be the same
    ...    when a4MeasMaxNumber and a4MeasHigherPrioFreq are modified.
    ...    2. Configuration
    ...    configuration on BTS
    ...    CA was not enabled
    ...    mobility profile is disabled
    ...    NRHOIF configuration on cell 11
    ...    UE will be in 3 different states:
    ...    UE1:inter-frequency A4 measurements are configured and a4SupervisionTimer is running
    ...    UE2:inter-frequency A4 measurements are configured and later deconfigured on expiry of
    ...    a4SupervisionTimer,a4RetryTimer is running
    ...    UE3:inter-frequency A4 measurements has been configured and later unconfigured 'a4MeasMaxNumber' times
    ...    3. Test Case Steps:
    ...    a. for UE1, a4MeasMaxNumber, a4RetryTimer,a4SupervisionTimer, one of NRHOIF.a4HysteresisSsbRsrp, a4ThresholdSsbRsrp,
    ...    a4TimeToTriggerSsbRsrp are modified online, check modification is effective.
    ...    b. for UE1, NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=2, A4 measurement configuration should
    ...    contain modified NRHOIF, and measids are not in the same order.
    ...    c. for UE1, NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=none is modified online, then measment configuration
    ...    should exclude the modified NRHOIF.
    ...    d. for UE2, a4MeasMaxNumber, a4RetryTimer,a4SupervisionTimer, one of NRHOIF.a4HysteresisSsbRsrp, a4ThresholdSsbRsrp,
    ...    a4TimeToTriggerSsbRsrp are modified online, check modification is effective.
    ...    e. for UE2, NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=2, A4 measurement configuration should
    ...    contain modified NRHOIF, and measids are not in the same order.
    ...    f. for UE2, NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=none is modified online, then measment configuration
    ...    should exclude the modified NRHOIF.
    ...    g. for UE3, a4MeasMaxNumber, a4RetryTimer,a4SupervisionTimer, one of NRHOIF.a4HysteresisSsbRsrp, a4ThresholdSsbRsrp,
    ...    a4TimeToTriggerSsbRsrp are modified online, check modification is effective.
    ...    h. for UE3, NRCELL-11/NRHOIF-5:a4PriorityForHigherPrioFreqHo=2, A4 measurement configuration should
    ...    contain modified NRHOIF, and measids are not in the same order.
    ...    i. for UE3, NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=none is modified online, then measment configuration
    ...    should exclude the modified NRHOIF.
    [Tags]    QC_191459    owner-kexin.bao    C065
    OnlineParamChange    ${OnlineParam_for_C065}
	stop capture wireshark log
    Online Modification Wo Mobility Profile for UE1
    Online Modification Wo Mobility Profile for UE2
    Online Modification Wo Mobility Profile for UE3

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${nwslice}    ${gw_id}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Verify Throuput
    [Arguments]    ${Tput_dl}=60    ${Tput_ul}=9    ${sleep_time}=10s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    [Arguments]    ${send_dl}=70    ${send_ul}=10    ${sleep_time}=5s
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${send_dl}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${send_ul}
    Verify Throuput    ${send_dl}*0.5-3    ${send_ul}*0.5    5s

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

A4MeasMaxNumber Modification
    [Arguments]    ${ue_state_id}    ${sleep_time}        ${carrierfreq}
    #Start To Capture Wireshark Log    C066_UE${ue_state_id}_1
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput
    OnlineParamChange    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=0
    Verify Throuput
    sleep    ${sleep_time}    reason=make sure that A4 configure and de-configure more than original 'a4MeasMaxNumber' rounds
    UE Deregister From gNB    ue_id=${ue_id}

Delete NRMEASCFG_IF a4MeasHigherPrioFreqEnabled
    [Arguments]    ${ue_state_id}    ${sleep_time}    ${carrierfreq}=2075419
    #Start To Capture Wireshark Log    C066_UE${ue_state_id}_2
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput
    OnlineParamChange    delete:MRBTS-1/NRBTS-1/NRMEASCFG_IF-4:a4MeasHigherPrioFreqEnabled
    Verify Throuput
	sleep    ${sleep_time}    reason=make sure that A4 configure and de-configure more than original 'a4MeasMaxNumber' rounds
    UE Deregister From gNB    ue_id=${ue_id}

NRMEASCFG_IF A4PriorityForHigherPrioFreqHo Modification
    [Arguments]    ${ue_state_id}    ${sleep_time}    ${carrierfreq}
    #Start To Capture Wireshark Log    C066_UE${ue_state_id}_3
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput
    OnlineParamChange    MRBTS-1/NRBTS-1/NRMEASCFG_IF-1:a4PriorityForHigherPrioFreqHo=3
    Verify Throuput
    sleep    ${sleep_time}    reason=make sure that A4 configure and de-configure more than original 'a4MeasMaxNumber' rounds	
    UE Deregister From gNB    ue_id=${ue_id}

Online Modification With Mobility Profile for UE1
    Start To Capture Wireshark Log    C066_UE1
    A4MeasMaxNumber Modification    ue_state_id=1    sleep_time=60    carrierfreq=518890
    Delete NRMEASCFG_IF A4MeasHigherPrioFreqEnabled    ue_state_id=1    sleep_time=30
    NRMEASCFG_IF A4PriorityForHigherPrioFreqHo Modification    ue_state_id=1    sleep_time=30    carrierfreq=2075419
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C066${/}a2a_ue1.ini    name=C066_UE1    wait_string=UEContextReleaseComplete::12

Online Modification With Mobility Profile for UE2
    OnlineParamChange    ${OnlineParam_prepare_for_C066_UE2}
    Start To Capture Wireshark Log    C066_UE2
    A4MeasMaxNumber Modification    ue_state_id=2    sleep_time=50    carrierfreq=518890
    OnlineParamChange    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
    Delete NRMEASCFG_IF A4MeasHigherPrioFreqEnabled    ue_state_id=2    sleep_time=45    carrierfreq=518910
    NRMEASCFG_IF A4PriorityForHigherPrioFreqHo Modification    ue_state_id=2    sleep_time=45    carrierfreq=518910
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C066${/}a2a_ue2.ini    name=C066_UE2    wait_string=UEContextReleaseComplete::12

Online Modification With Mobility Profile for UE3
    OnlineParamChange    ${OnlineParam_prepare_for_C066_UE3}
    Start To Capture Wireshark Log    C066_UE3
    A4MeasMaxNumber Modification    ue_state_id=3    sleep_time=30    carrierfreq=518890
    OnlineParamChange    NRBTS-1/NRCELL-11:a4PeriodicMeasControlSA:a4MeasMaxNumber=2
    Delete NRMEASCFG_IF A4MeasHigherPrioFreqEnabled    ue_state_id=3    sleep_time=30     carrierfreq=518910
    NRMEASCFG_IF A4PriorityForHigherPrioFreqHo Modification    ue_state_id=3    sleep_time=30    carrierfreq=518910
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C066${/}a2a_ue3.ini    name=C066_UE3    wait_string=UEContextReleaseComplete::12

Modify NRCELL A4configuration
    [Arguments]    ${online_param}    ${ue_state_id}    ${sleep_time}    ${carrierfreq}=2075419
    #Start To Capture Wireshark Log    C065_UE${ue_state_id}_1
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput
    OnlineParamChange    ${online_param}
    Verify Throuput
    sleep    ${sleep_time}    reason=make sure that A4 configure and de-configure more than original 'a4MeasMaxNumber' rounds
    UE Deregister From gNB    ue_id=${ue_id}

Modify NRHOIF A4configuration
    [Arguments]    ${ue_state_id}    ${sleep_time}    ${sleep_time_1}=20s        ${carrierfreq}=2075419
    #Start To Capture Wireshark Log    C065_UE${ue_state_id}_2
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput    send_dl=70    send_ul=10    sleep_time=${sleep_time_1}
    OnlineParamChange    ${OnlineParam_NRHOIF_A4configuration}
    Verify Throuput
    sleep    ${sleep_time}    reason=make sure 1 round time for A4 configure and deconfigurate
    UE Deregister From gNB    ue_id=${ue_id}

Modify NRMEASCFG_IF A4MeasHigherPrioFreqEnabled
    [Arguments]    ${ue_state_id}    ${sleep_time}    ${sleep_time_1}=20s    ${carrierfreq}=2075419
    #Start To Capture Wireshark Log    C065_UE${ue_state_id}_3
    UE Attach To Target Cell    cell_id=${cell_id}    nwslice=1    gw_id=1
    Send And Verify Throuput    send_dl=70    send_ul=10    sleep_time=${sleep_time_1}
    OnlineParamChange    NRCELL-11/NRHOIF-1:a4MeasHigherPrioFreqEnabled=none
    Verify Throuput
    sleep    ${sleep_time}    reason=make sure 1 round time for A4 configure and deconfigurate
    UE Deregister From gNB    ue_id=${ue_id}

Online Modification Wo Mobility Profile for UE1
    Start To Capture Wireshark Log    C065_UE1
    Modify NRCELL A4configuration    online_param=${OnlineParam_NRCELL_A4configuration_UE1}    ue_state_id=1    sleep_time=85
    OnlineParamChange    NRCELL-11:a4PeriodicMeasControlSA:a4RetryTimer=45
    Modify NRHOIF A4configuration    ue_state_id=1    sleep_time=70
    Modify NRMEASCFG_IF A4MeasHigherPrioFreqEnabled    ue_state_id=1    sleep_time=70
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C065${/}a2a_ue1.ini    name=C065_UE1    wait_string=UEContextReleaseComplete::12

Online Modification Wo Mobility Profile for UE2
    OnlineParamChange    ${OnlineParam_prepare_C065_UE2}
    Start To Capture Wireshark Log    C065_UE2
    Modify NRCELL A4configuration    online_param=${OnlineParam_NRCELL_A4configuration_UE2}    ue_state_id=2    sleep_time=50
    Modify NRHOIF A4configuration    ue_state_id=2    sleep_time=50
    Modify NRMEASCFG_IF A4MeasHigherPrioFreqEnabled    ue_state_id=2    sleep_time=50
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C065${/}a2a_ue2.ini    name=C065_UE2    wait_string=UEContextReleaseComplete::12

Online Modification Wo Mobility Profile for UE3
    OnlineParamChange    ${OnlineParam_prepare_C065_UE3}
    Start To Capture Wireshark Log    C065_UE3
    Modify NRCELL A4configuration    online_param=${OnlineParam_NRCELL_A4configuration_UE3}    ue_state_id=3    sleep_time=5    carrierfreq=518890
    Modify NRHOIF A4configuration    ue_state_id=3    sleep_time=10    sleep_time_1=50    carrierfreq=518890
    Modify NRMEASCFG_IF A4MeasHigherPrioFreqEnabled    ue_state_id=3    sleep_time=10    sleep_time_1=50    carrierfreq=518890
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C065${/}a2a_ue3.ini    name=C065_UE3    wait_string=UEContextReleaseComplete::12
