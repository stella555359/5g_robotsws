*** Settings ***
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-DevHZ5_SG1    owner-taotao.hu    release-5G23R2    CB006137    AP_REG
Resource    ../../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    true
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_4T2F
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1
@{PARAMS_IN_SCF}
...    @{CB006137}
...    @{CA}
...    @{NRREL}
...    @{Mobillity}
...    @{gscn_Arfcn}
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=4
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated
${Cell1_TDD_PCI}    50
${Cell2_TDD_PCI}    51
${Cell3_TDD_PCI}    52
${Cell4_TDD_PCI}    53
${Cell11_FDD_PCI}    60

${Cell1_ssbFrequency}    632736
${Cell3_ssbFrequency}    508110
${Cell12_ssbFrequency}    126750

${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
@{CB006137}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=100
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-1:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-2:ulTReassembly=ms15
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n39936
...    NRCELL:weightForSCellSelection=50
...    NRCELL:actK1Opt=intra-gNB

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=633000
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:nrarfcn=633000
...    NRCELL-2:gscnOrSsPbchArfcn=7840
...    NRCELL-2:chBw=80MHz
...    NRCELL-3:chBw=60MHz
...    NRCELL-4:chBw=60MHz
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1584
...    NRCELL-12:type0CoresetConfigurationIndex=0

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
@{NRREL}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:sCellPrio=1
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:sCellPrio=2

...    NRCELL-12/NRREL-5:gNbId=1
...    NRCELL-12/NRREL-5:gNbIdLength=22
...    NRCELL-12/NRREL-5:lcrId=11
...    NRCELL-12/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-1:ssbFrequency=508110
...    NRCELL-12/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL-12/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-12/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-12/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-2:freqBandIndicatorNR=78
...    NRCELL-12/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-12/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-12/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-12/NRHOIF-2:ssbFrequency=632736
...    NRCELL-12/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-12/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-12/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
@{Mobillity}
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRPMRNL-1:miNrMobilityReport=5min
...    NRBTS:actInterFreqHoSA=true
...    NRBTS:actInterFreqInterGnbMobilityNSA=true
...    NRBTS:actInterFreqIntraGnbMobilityNSA=true
...    NRBTS:actInterMeNBMobility=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:actIntraMeNBMobility=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea3_128=8
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=34
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=${EMPTY}
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerHoSsbRsrpVoNr=${EMPTY}

...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-1:reportAmountA6MeasSCellSwap=infinity    #infinity
...    NRCELL-1:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-1:thresholdSCellSwapSourceRsrp=66
...    NRCELL-1:thresholdSCellSwapSourceRsrq=67
...    NRCELL-1:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-1:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480

...    NRCELL-2:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-2:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-2:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-2:thresholdSCellSwapSourceRsrp=66
...    NRCELL-2:thresholdSCellSwapSourceRsrq=67
...    NRCELL-2:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-2:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480


...    NRCELL-3:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-3:reportAmountA6MeasSCellSwap=r4
...    NRCELL-3:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-3:thresholdSCellSwapSourceRsrp=66
...    NRCELL-3:thresholdSCellSwapSourceRsrq=67
...    NRCELL-3:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-3:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480


...    NRCELL-4:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-4:reportAmountA6MeasSCellSwap=r4
...    NRCELL-4:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-4:thresholdSCellSwapSourceRsrp=66
...    NRCELL-4:thresholdSCellSwapSourceRsrq=67
...    NRCELL-4:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-4:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480

@{config_p0uepush_PHRconfig}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS:srbInactivityTimerSA=600
...    NRCELL-12:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-1:ulPowerControlCommon:p0UePusch=-6
...    NRCELL-2:ulPowerControlCommon:p0UePusch=-6
...    NRCELL-3:ulPowerControlCommon:p0UePusch=-6
...    NRCELL-4:ulPowerControlCommon:p0UePusch=-6
...    NRBTS:phrConfig:dlPathlossChg=1dB
...    NRBTS:phrConfig:tPeriodicPhr=10sf
...    NRBTS:phrConfig:tProhibitPhr=10sf

@{online_change_PHR}
...    NRBTS:phrConfig:dlPathlossChg=3dB
...    NRBTS:phrConfig:tPeriodicPhr=20sf
...    NRBTS:phrConfig:tProhibitPhr=50sf

@{config_pmaxNROwncell}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-3:pMaxNROwnCell=20
...    NRCELL-12:pMaxNROwnCell=20

${normal_report_A2}    6s

${N71DLUL_N41DLUL_N71DLUL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D
...    6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F1048
...    0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A41203
...    0B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FF8007003FF0004C0003815C7C46D608C21A08107CA090155B
...    262AC2873E238F180000000000000000000003C04FFF800003FFE00000260001C00178B850001C46000E230000010B010200E02
...    34028809B01043D001C020800140467A09801E00140E0A00E0601280380030120020301F0480100000000800001004000000020
...    0000401000004008000030040000200200001401000802008020000180100000E00800400000010000100080000900400001802
...    0000280100001600800409024010000180672A6B2A6B052B052B066B056B296B266B016B036B012B022B07681A0800004B29202
...    000032CA480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480
...    800054B29202000172CA480800064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549A
...    2A83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100220100200404030060100C018402
...    004008080600C02018030404030060100C018402004008080600C02018000804030060100C018040300618080600C0201803008
...    0100402004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N71DLUL_N41DLUL_N78DLUL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6
...    C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480C
...    AD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B6
...    4C55110E7C471E238F40CFB027C639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262A
...    C2873E238F180000000000000000000003C04FFF800003FFE00000260001C00178B850001C46000E268000010B010200E0234028
...    809B01043D001C021000140467A09801E00140E0A00E0601280380030120020301F0480100000000800001004000000020000040
...    1000004008000030040000200200001401000802008020000180100000E008004000000100001000800009004000018020000280
...    100001600800409024010000180672A6B2A6B052B052B066B056B296B266B016B036B012B022B07681A0800004B29202000032CA
...    480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29
...    202000172CA480800064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A93455018AA051549A2A83C50901
...    78095028140A05028140A05028140A05028140A05028140018202018030080100220100200404030060100200440200400808060
...    0C02018030404030060100C018402004008080600C02018000804030060100C018040300618080600C0201803008010040200401
...    0D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680

${N71DLUL_N41DL_N71DL_N78DLUL_PC2a}    SEPARATOR=
...    E1A2538057E01A0104001EF406AC0007865002C04220000800180102418F4047B003C1326439F22D7A0ABD825E819F604F81E3C4
...    71E1001018093170019C3D09003120D0098040623807D46C28C0D608C21A0810748260516CAA2A121CFA067D813E31CF9863CA16
...    0703878021000003080A09050138002F800E000BE000910C1B28000280000005200602A8F88DAC1184341020F104C092D9545414
...    39F40CF8C73E618F28581C0E1E00420000061014120A027F0000001FC000000120180A400C0551B137582308682041D2098145B2
...    A8A84873E819F604F8C73E618F28581C0E1E008400000C2028241404E000B60038002D800240301480180AA3E20EB04610D04083
...    C413024B65515050E7D033E31CF9863CA16070387801080000184050482809FD0000007F4000000484603040290030002B1F1340
...    0388C0818280308C00073907005011A014404D0F401100C68138365AF1C0050119E825407C006000E0000020280301804A00C000
...    C07C0600400000002000004010000040080040000001000802008020010000200400001807CA9AC0CBCA5AC08A01820000003602
...    08000080D8002000040000008000180000007A55574AA2A81455038A1281D806A07028140E05038001A108400268031000000804
...    0000020100000080400000200048804008010100400004010001008010020200C000080200000100800420200400808050001010
...    0C00404010001018010050020080C0380380200806008004038001008010040200C0000802008301002008040280401002000040
...    28000808060040200802040401004010040000B1701406014A2020066300

${N71DLUL_N41DL_N71DL_N78DLUL_PC2b}    SEPARATOR=
...    E1A2538057E01A0104001EF406AC0007865002C04220000800180102418F4047B003C1326439F22D7A0ABD825E819F604F81E3C4
...    71E1001018093170019C3D09003120D0098040623807D46C28C0D608C21A0810748260516CAA2A121CFA067D813E31CF9863CA16
...    0703878021000003080A090500B8002F800E000BE000910C1B28000280000005200602A8F88DAC1184341020F104C092D9545414
...    39F40CF8C73E618F28581C0E1E00420000061014120A027F0000001FC000000120180A400C0551B137582308682041D2098145B2
...    A8A84873E819F604F8C73E618F28581C0E1E008400000C2028241402E000B60038002D800240301480180AA3E20EB04610D04083
...    C413024B65515050E7D033E31CF9863CA16070387801080000184050482809FD0000007F4000000484603040290030002B1F1340
...    0388C0818280308C00073907005011A014404D0F401100C68138365AF1C0050119E825407C006000E0000020280301804A00C000
...    C07C0600400000002000004010000040080040000001000802008020010000200400001807CA9AC0CBCA5AC08A01820000003602
...    08000080D8002000040000008000180000007A55574AA2A81455038A1281D806A07028140E05038001A108400268031000000804
...    0000020100000080400000200048804008010100400004010001008010020200C000080200000100800420200400808050001010
...    0C00404010001018010050020080C0380380200806008004038001008010040200C0000802008301002008040280401002000040
...    28000808060040200802040401004010040000B1701406014A2020066300
*** Test Cases ***
CB006137-SR-C-B6_ET_01_01_UE UL power shared by PCell and Scell in FDD-TDD FR1 UL CA when scell addition and scell release
    [Documentation]
    ...    GNB configuration
    ...    cell-1: band78 CHBW=80M NRARFCN=633000 PCI=50 icrid=1 scellprio=1
    ...    cell-2: band78 CHBW=80M NRARFCN=633000 PCI=51 icrid=2 scellprio=2
    ...    cell-3: band41 CHBW=60M NRARFCN=508020 PCI=52 icrid=3 scellprio=1
    ...    cell-4: band41 CHBW=60M NRARFCN=508020 PCI=53 icrid=4 scellprio=2
    ...    cell-11: band71 CHBW=10M PCI=60 icrid=11
    ...    cell-12: band71 CHBW=20M PCI=61 icrid=12
    ...    for TDD cell-1 and cell-2 large(80M)
    ...    step1: register UE-1 to FDD cell-12 and do UL scell addiotn and check p0, pHR-config and timerReassembly
    ...           p0: set based on NIDD for Pcell
    ...           multiplePHR: true
    ...           timerReassembly: based on NIDD ulTReassemblyIBCA
    ...    step2: UE-1 report A6 for UL scell swap and check p0, pHR-config and timerReassembly
    ...           p0: absent
    ...           multiplePHR: absent
    ...           timerReassembly: absent
    ...    step3: UE-1 report A2 for UL scell release and check p0, pHR-config and timerReassembly
    ...           p0: 0
    ...           multiplePHR: false
    ...           timerReassembly: based on NIDD ulTReassembly
    ...    step4: UE-2 register and trigger UL scell addition after PHR configuration online modification, check PHR config
    ...           PHR-config setting from UE context
    ...    step6: register UE-2 to FDD cell-12 and do FDD DL only scell addiotn and check p0, pHR-config and timerReassembly
    ...           p0: absent
    ...           multiplePHR: absent
    ...           timerReassembly: absent
    ...    step7: UE-3 report A2 trigger DL only scell cahnge to DL&UL scell change and check p0, pHR-config and timerReassembly
    ...           p0: set based on NIDD for Pcell
    ...           multiplePHR: true
    ...           timerReassembly: based on NIDD ulTReassemblyIBCA
    ...           PHR-config setting from UE context
    ...    step8: UE-3 report A2 for UL scell release and check p0, pHR-config and timerReassembly
    ...           p0: 0
    ...           multiplePHR: false
    ...           timerReassembly: based on NIDD ulTReassembly
    [Tags]    QC_xxxxxx    252501    TC01
    delta commission parameters    ${config_p0uepush_PHRconfig}
    UE-1 do UL scell addiiton swap and release
    UE-2 do UL scell addition after PHR online modification
    UE-3 do UL scell change and release
    check rrc log    ${CURDIR}${/}A2A_case01${/}a2a_01.ini
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_01.ini    wait_string=UEContextModificationResponse::22
    Release UEs    ue_type=all

CB006137-SR-C-B6_ET_04_01_verify UE UL scell addition with power class 2a and 2b
    [Documentation]
    ...    Verify scell can be addition successfully when UE with power classs 2a or 2b
    ...    UE-1: N71a*-N41a-N71a-N78a*,
    ...    UE-1: UE supports power class 2 for the FDD-TDD band combination, and UE support power class 3 for FDD band and TDD band
    ...    UE-2: N71a*-N41a*-N71a-N78a,
    ...    UE-2: UE supports power class 2 for the FDD-TDD band combination, and UE support power class 3 for FDD band and power class 2
    ...    for TDD band
    [Tags]    QC_xxxxxx    252498    TC04
    delta commission parameters    ${config_pmaxNROwncell}
    Attach UE to FDD cell-12 with PC2a and trigger UL scell addition
    Attach UE to FDD cell-12 with PC2b and trigger UL scell addition
    check rrc log    ${CURDIR}${/}A2A_case04${/}a2a_01.ini
    Release UEs    ue_type=all

*** Keywords ***
Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

UE-1 do UL scell addiiton swap and release
    Start rrc log    UE_1
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=1    ue_capa=${N71DLUL_N41DLUL_N78DLUL}
    Trigger Scell Addition Via A1 and 2TDD scell added    ue_id=1
    Trigger UL scell swap from TDD cell-1 to cell-2    ue_id=1    scell_id=1    scell_phy_id=${Cell2_TDD_PCI}
    Scell A2 report to trigger Scell Release     ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=3
    Get rrc log

UE-2 do UL scell addition after PHR online modification
    Start rrc log    UE_2
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=2    ue_capa=${N71DLUL_N41DLUL_N78DLUL}
    delta commission parameters    ${online_change_PHR}
    Trigger Scell Addition Via A1 and 2TDD scell added    ue_id=2
    Get rrc log

UE-3 do UL scell change and release
    Start rrc log    UE_3
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=3    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
    Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added    ue_id=3
    Trigger Scell Change to TDD DL and UL scell    ue_id=3
    Trigger UL scell swap from TDD cell-3 to cell-4    ue_id=3    scell_id=2    scell_phy_id=${Cell4_TDD_PCI}
    Scell A2 report to trigger Scell Release     ue_id=3    carrierfreq=${Cell3_ssbFrequency}    scell_id=1
    Get rrc log

Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Trigger Scell Addition Via A1 and 2TDD scell added
    [Arguments]    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell3_TDD_PCI}, scellIdx:2
    Should Contain    ${ret1}    pcid:${Cell1_TDD_PCI}, scellIdx:1

Trigger Scell Addition Via A1 and 3 scell added
    [Arguments]    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell3_TDD_PCI}, scellIdx:2
    Should Contain    ${ret1}    pcid:${Cell1_TDD_PCI}, scellIdx:1
    Should Contain    ${ret1}    pcid:${Cell11_FDD_PCI}, scellIdx:3

Trigger Scell Change to TDD DL and UL scell
    [Arguments]    ${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell3_TDD_PCI}, scellIdx:2
    Should Contain    ${ret1}    multiplePHR TRUE
    Should Contain    ${ret1}    p0 -3

Trigger UL scell swap from TDD cell-1 to cell-2
    [Arguments]    ${ue_id}    ${scell_id}    ${scell_phy_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell1_ssbFrequency}    event_type=A6
    ${V_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=11 srsrq_nr=11 scell=${scell_id} 
    ...    scell_rsrp=20 scell_rsrq=20 phycell_id=${scell_phy_id} nrsrp_nr=63 nrsrq_nr=20
    ${ret1}=    Execute Egate Command    ${V_1}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell2_TDD_PCI}, scellIdx:3
    Should Not Contain    ${ret1}    multiplePHR
    Should Not Contain    ${ret1}    p0 -3

Trigger UL scell swap from TDD cell-3 to cell-4
    [Arguments]    ${ue_id}    ${scell_id}    ${scell_phy_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell3_ssbFrequency}    event_type=A6
    ${V_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=11 srsrq_nr=11 scell=${scell_id} 
    ...    scell_rsrp=20 scell_rsrq=20 phycell_id=${scell_phy_id} nrsrp_nr=63 nrsrq_nr=20
    ${ret1}=    Execute Egate Command    ${V_1}    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell4_TDD_PCI}, scellIdx:1

Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added
    [Arguments]    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell11_FDD_PCI}, scellIdx:1
    Should Not Contain    ${ret1}    multiplePHR
    Should Not Contain    ${ret1}    p0 -3

Scell A2 report to trigger Scell Release
    [Arguments]    ${ue_id}    ${carrierfreq}    ${scell_id}
    sleep    ${normal_report_A2}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    rrcReconfigurationComplete
    Should Contain    ${ret1}    sCellToReleaseList
    Should Contain    ${ret1}    multiplePHR FALSE
    Should Contain    ${ret1}    p0 0

Attach UE to FDD cell-12 with PC2a and trigger UL scell addition
    Start rrc log    UE_1
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=1    ue_capa=${N71DLUL_N41DL_N71DL_N78DLUL_PC2a}
    Trigger Scell Addition Via A1 and 3 scell added    ue_id=1
    Get rrc log

Attach UE to FDD cell-12 with PC2b and trigger UL scell addition
    Start rrc log    UE_2
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=2    ue_capa=${N71DLUL_N41DL_N71DL_N78DLUL_PC2b}
    Trigger Scell Addition Via A1 and 3 scell added    ue_id=2
    Get rrc log