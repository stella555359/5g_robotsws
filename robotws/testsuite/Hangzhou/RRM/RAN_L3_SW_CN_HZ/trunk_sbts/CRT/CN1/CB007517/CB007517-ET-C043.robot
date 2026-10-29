*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Rock_SGT&A    owner-christine.chen
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB007517-C    release-5G22R4
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    NRBTS-1:timerRRCGuard=6000
...    NRBTS-1:tWaitingRlRecover=4000ms
...    @{HO_Config}
...    @{EutraCGI_Config}
...    @{A4_Config}
...    @{NRHOIF_Config}
...    @{NRREL_Config}

@{FAULTS_EXCLUDED_CHECKING}    7307

@{HO_Config}
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actInterFreqHoSA=true
...    NRBTS-1:actInterFreqInterGnbMobilityNSA=true
...    NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS-1:actHigherPrioFreqHo=SA+NSA
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=15min
...    NRBTS-1/NRCELL-1:actCDrx=true

@{EutraCGI_Config}
...    NRBTS-1:actSaUeBasedAnrEutra=true
...    NRBTS-1:actInterRatHoSA=true
...    NRBTS-1/NRCELL-1:drxProfileNrAnr:drxControl=any
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresholdSelectorEutra=RSRP
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresRsrpEutraNbCell=-120
...    MRBTS-1/NRBTS-1/NRANRPRE-1:anrThresRsrqEutraNbCell=-19
...    MRBTS-1/NRBTS-1/NRANRPRE-1:consecRecheckForEutraNbRemoval=5
...    MRBTS-1/NRBTS-1/NRANRPRE-1:idleTimeForEutraNbRemoval=72
...    MRBTS-1/NRBTS-1/NRANRPRE-1:maxNumAnrNrrelePerCell=50
...    MRBTS-1/NRBTS-1/NRHOIR-1:allowedMeasBandwidth=mbw50
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2MeashoEnabled=rsrp
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2Threshold1hoRsrp=35
...    MRBTS-1/NRBTS-1/NRHOIR-1:b2Threshold1hoRsrq=50
...    MRBTS-1/NRBTS-1/NRHOIR-1:earfcnValue=2000
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2HysteresishoRsrp=0
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2Threshold2hoRsrp=20
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrp:b2TimeToTriggerhoRsrp=ms64
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2HysteresishoRsrq=0
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2Threshold2hoRsrq=2
...    MRBTS-1/NRBTS-1/NRHOIR-1:eutraB2MeashoRsrq:b2TimeToTriggerhoRsrq=ms80
...    MRBTS-1/NRBTS-1/NRHOIR-1:presenceAntennaPort1=false
...    MRBTS-1/NRBTS-1/NRHOIR-1:reportAmount=r8
...    MRBTS-1/NRBTS-1/NRHOIR-1:reportInterval=ms240
...    MRBTS-1/NRBTS-1/NRHOIR-1:widebandRsrqMeas=true
...    MRBTS-1/NRBTS-1/NRCELL-1:nrhoirDNList=MRBTS-1/NRBTS-1/NRHOIR-1
...    MRBTS-1/NRBTS-1/NRCELL-1:a1MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRCELL-1:a2MeashoEnabledSA=rsrp
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoEutraNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:actAutoNrNbRemoval=false
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThres=3
...    MRBTS-1/NRBTS-1/NRANR-1:consecHoFailThresEutra=3

@{A4_Config}
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4MeasMaxNumber=8
...    NRBTS-1/NRCELL:a4PeriodicMeasControlNSA:a4RetryTimer=10
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr1SupervisionTimer=8000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4Fr2SupervisionTimer=10000
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4MeasMaxNumber=8
...    NRBTS-1/NRCELL:a4PeriodicMeasControlSA:a4RetryTimer=8

@{NRHOIF_Config}
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-1/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-1:a4PriorityForHigherPrioFreqHo=2
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=126750
...    NRCELL-1/NRHOIF-2:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-2:a4PriorityForHigherPrioFreqHo=4
...    NRCELL-1/NRHOIF-3:cellDepType=SA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-3:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=633216
...    NRCELL-1/NRHOIF-3:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4ThresholdSsbRsrp=45
...    NRCELL-1/NRHOIF-3:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-3:a4PriorityForHigherPrioFreqHo=3
...    NRCELL-1/NRHOIF-4:cellDepType=SA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-4:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=427970
...    NRCELL-1/NRHOIF-4:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-4:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-4:a4PriorityForHigherPrioFreqHo=1
...    NRCELL-1/NRHOIF-5:cellDepType=SA
...    NRCELL-1/NRHOIF-5:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-5:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-5:ifhoSsbSmtcPeriodicity=sf5
...    NRCELL-1/NRHOIF-5:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-5:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-5:ssbFrequency=2079163
...    NRCELL-1/NRHOIF-5:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-5:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-5:a4PriorityForHigherPrioFreqHo=5
...    NRCELL-1/NRHOIF-6:cellDepType=SA
...    NRCELL-1/NRHOIF-6:freqBandIndicatorNR=257
...    NRCELL-1/NRHOIF-6:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-6:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-6:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-6:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-6:ssbFrequency=2071675
...    NRCELL-1/NRHOIF-6:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4ThresholdSsbRsrp=15
...    NRCELL-1/NRHOIF-6:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-1/NRHOIF-6:a4PriorityForHigherPrioFreqHo=6
...    NRCELL-1/NRHOIF-7:cellDepType=SA
...    NRCELL-1/NRHOIF-7:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-7:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcDuration=sf2
...    NRCELL-1/NRHOIF-7:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-7:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1/NRHOIF-7:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-7:ssbFrequency=513150
...    NRCELL-1/NRHOIF-7:a4MeasHigherPrioFreqEnabled=none
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4ThresholdSsbRsrp=20
...    NRCELL-1/NRHOIF-7:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms0
...    NRCELL-1/NRHOIF-7:a4PriorityForHigherPrioFreqHo=7
...    NRCELL-12/NRHOIF-1:cellDepType=SA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf2
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=518910
...    NRCELL-12/NRHOIF-1:a4MeasHigherPrioFreqEnabled=rsrp
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4ThresholdSsbRsrp=34
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrp:a4TimeToTriggerSsbRsrp=ms40
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4ThresholdSsbRsrq=49
...    NRCELL-12/NRHOIF-1:a4MeasSsbRsrq:a4TimeToTriggerSsbRsrq=ms40
...    NRCELL-12/NRHOIF-1:a4PriorityForHigherPrioFreqHo=1

@{NRREL_Config}
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRREL-1:lcrId=12
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=1
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:removeNotAllowed=false
...    NRCELL-1/NRREL-10:lcrId=11
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-10:lcrId=1
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:lcrId=14
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:removeNotAllowed=false
...    NRCELL-1/NRREL-2:lcrId=2
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-3:removeNotAllowed=false
...    NRCELL-1/NRREL-3:lcrId=13

${SA_Capa_CGI_HO}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A
...    1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604
...    F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB
...    027C639F30C7942C0E070F05C00FFC007003FF0004C000381506C46D608C21A0810788240656C98AB121CF88E3D813E31238F21CFA8E7CC3
...    1E50B0381C3C27FFC00001FFF00000130000E007BC3C4D000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A
...    00038820000042C0AC3C4D000E230000010B02B17118003882001C4100000A160561E14000713400003058158B89A001C41000E140000040
...    B02B1713400388C001C46000004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B89A001C41000E230000020B
...    02B170A000388C001C46000004160562E2680071180038500000102C0AC3C46000E230000030B0200E0234028809B01043D02EC1F0A244D8
...    E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E0
...    44810206C73E044810206C73E044810206C73E044810206C73E0428103639F0005C3C6318C6318C6318C63187A09C01F001600180E0A00E0
...    601280380030120020301F048010000000080000100400000002000004010000040080000300400002002000014010008020080200001801
...    00000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B
...    016B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA
...    480800044B29202000132CA480800054B29202000172CA4A0800064B29202000062CA480669555D2AAAA55174AA2A82C55058AA0D154A62A
...    93455018AA051549AAA83C5090178095028140A05028140A05028140A05028140A0502814001820201803008010021010020080403006100
...    80100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820200401008010043543E000204
...    06080C0E1216181A2022242628303236383A3E424A4C4E5052545A5E828305A ue_eutra_capabilities=1E000030010312000000


${ue_id}    81
${pdu_id}    1
${gw_id}    1
${nwslice}    1
${BTS_STARTUP_RETRY}    2

*** Test Cases ***
CB007517-ET-C043_HO_not_executed_and_A4_deconfigured_after_receiving_Inter-freq_A4_MR_and_then_IRAT_EUTRACGI_Report_configured
    [Documentation]
    ...    1. This user scenario describes when low priority A4 MR is trigger and IRAT EUTRACGI Report is trigger before
    ...    SupervisionTimer timeout, then A4 HO is not executed and A4 is deconfigured, IRAT EUTRACGI HO successful.
    ...    2. Configuration
    ...        a.configuration on cell 1
    ...            ANR inter-RAT feature is activation
    ...            5GUE supports the band of the inter-frequency configured for A4 measurements
    ...            NRHOIF and NRREL for cell 1, present for cell 11,cell 12, a4PriorityForHigherPrioFreqHo are 1,2
    ...            NRHOIF and NRREL for cell 12, present for cell 1,a4PriorityForHigherPrioFreqHo are 1
    ...            scell is configed for cell1 NRREL2
    ...            Measurement: A4
    ...            DRX: enable
    ...    3. Test Case Steps:
    ...        a. UE registers successfully and PDU session is setup successfully on cell 1.
    ...        b. Trigger A4 MG and meas_id = 3, within first SupervisionTimer (a4RetryTimer = 8s)
    ...        c. Trigger A2 MG and meas_id = 1 to trigger report onleave within first SupervisionTimer
    ...        d. Trigger B2 MG and meas_id = 5 to trigger IRAT EUTRACGI HO
    ...        e. HO is excuted successful.
    ...        f. UE deregister should be successfully.
    ...    4. Expect result:
    ...         a. PDU session is setup successfully, drx setup, and start retry timer
    ...         b. A4 meas(2,3,) is configured, gapUE setup, drx release after retry timer timeout
    ...         c. A4 is deconfigured, A1 and B2 are configured
    ...         d. reportCGI is configured,
    ...         e. HO is excuted successful.
    ...         g. UE deregister is successfully
    [Tags]    QC_196052    owner-christine.chen    C043
    UE Attach To Target Cell    cell_id=1
    Send And Verify Throuput
    Trigger A4 HO
    Trigger B2 HO
    Verify Throuput
    UE Deregister From gNB    ue_id=${ue_id}
    Check Wireshark Log    ${CURDIR}${/}a2a_CB007517C043${/}a2a.ini    wait_string=UEContextReleaseComplete::1


*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

UE Attach To Target Cell
    [Arguments]    ${cell_id}
    Update UE capa    ${SA_Capa_CGI_HO}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}    QoS Routing Table

Trigger A4 HO
    [Arguments]
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A4 phycell_id=61 nrsrp_nr=60
    ...    measResultNeighCells measResultListNR
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=20 srsrq_nr=20
    ...    rrcReconfigurationComplete
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}
Trigger B2 HO
    [Arguments]
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=6 event=B2 srsrp_nr=20 srsrq_nr=20 phycell_id=30 nrsrp_nr=30 nrsrq_nr=30
    ...    Successful handover from EXT_ENB-2.1 to ENB-3.1
    Execute Egate Command    ue_disp
    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}

Verify Throuput
    [Arguments]    ${Tput_dl}=8    ${Tput_ul}=5    ${sleep_time}=7s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Send And Verify Throuput
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=20
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=20
    Verify Throuput

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

Modify Cfg
    ${C_1}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.138 daemon=10.0.2.1:22222 gnb_id=0x74321:28 nssai=0x01:0xD143A5
    ${C_2}    catenate
    ...    set_cell id=1 gnb=3 pci=10:0 eci=0x7432101 earfcn=2000:20000 mapped_earfcn=4200:22200 tac=200 proxy=10.0.2.92:12219 nrci=0x01
    ...    tdd_cell=off bw=20MHz technology=lte mandatory_for_activation=off
    Update Cfg    ${C_1}
    Update Cfg    ${C_2}
    Update Cfg    gnb_cell_param id=1 gnb=3 enable_drx_profile_for_anr=on
    Update Cfg    gnb_param id=3 xn_listening_socket=off sib1_period=20000
    Update Cfg    mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200
    Update Cfg    set_mme id=1 ip=10.0.2.1:22222 s1=10.0.1.131:36412 supported_rat=lte,nblte pool=1:1

