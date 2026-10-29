*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Local Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BOO_AP_LOO
...    team-DevHZ5_SG4    owner-zhiguo.li    RobType:Endu;TranRob_ECERDxxxxx    CRT
Resource    ../../../../resources/DevHZ5_resource.robot
Library  ./lib/reporting.py
Test Timeout    168 hours

*** Variables ***
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_4T2F
${SYSCOM_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
${UTE_WIRESHARK_FLAG}    ${False}
${EMIL_FLAG}    ${False}
${TTITRACE_FLAG}    ${True}
${REPORT_FAST}    ${True}
${REPORT_DEBUG}    ${False}
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
@{rdULCaEnablerPhase}
...    0x580591=0
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1
@{PARAMS_IN_SCF}
...    @{CB006137_F_T_ULCA}
...    @{freqBand_chBw}
...    @{Meas_Config}
...    @{BWP}
${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa
@{CB006137_F_T_ULCA}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actBcsCheck=disabled
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:dlToUlContributionRatio=100
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-1:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-2:ulTReassembly=ms15
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n39936
...    NRCELL:weightForSCellSelection=50
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:sCellDeactivationTimerGNB=ms1280
# ...    NRCELL:actFlexibleGapOffset=false
# ...    NRCELL:caHighPowerBc=disabled
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
@{freqBand_chBw}
...    NRCELL:maxNumPdschAllocationPerSlot=10
...    NRCELL:maxNumPuschAllocationPerSlot=10
...    NRCELL-1:nrarfcn=633000
...    NRCELL-1:gscnOrSsPbchArfcn=7840
...    NRCELL-1:chBw=80MHz
...    NRCELL-2:nrarfcn=633000
...    NRCELL-2:gscnOrSsPbchArfcn=7840
...    NRCELL-2:chBw=80MHz
...    NRCELL-3:chBw=60MHz
...    NRCELL-4:chBw=60MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1584
...    NRCELL-12:type0CoresetConfigurationIndex=0
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
@{Meas_Config}
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
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRBTS/NRPMRNL-1:miNrRelReportCu=5min
...    NRBTS/NRPMRNL-1:miNrMobilityReport=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms512
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=5
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
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRCELL-1:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-1:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-1:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-1:thresholdSCellSwapSourceRsrp=66
...    NRCELL-1:thresholdSCellSwapSourceRsrq=67
...    NRCELL-1:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-1:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL-2:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-2:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-2:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-2:thresholdSCellSwapSourceRsrp=66
...    NRCELL-2:thresholdSCellSwapSourceRsrq=67
...    NRCELL-2:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-2:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-3:increasePUSCHPrepTimeULCA=true
...    NRCELL-3:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-3:reportAmountA6MeasSCellSwap=r4
...    NRCELL-3:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-3:thresholdSCellSwapSourceRsrp=66
...    NRCELL-3:thresholdSCellSwapSourceRsrq=67
...    NRCELL-3:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-3:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-4:increasePUSCHPrepTimeULCA=true
...    NRCELL-4:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-4:reportAmountA6MeasSCellSwap=r4
...    NRCELL-4:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-4:thresholdSCellSwapSourceRsrp=66
...    NRCELL-4:thresholdSCellSwapSourceRsrq=67
...    NRCELL-4:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-4:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-1:sCellPrio=1
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:sCellPrio=2
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:lcrId=3
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-3:sCellPrio=1
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-4:sCellPrio=2
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-5:gNbId=1
...    NRCELL-12/NRREL-5:gNbIdLength=22
...    NRCELL-12/NRREL-5:lcrId=11
...    NRCELL-12/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-5:sCellOperationalMode=dlOnly
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
@{BWP}
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=5
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=4
...    MRBTS-1/NRBTS-1/BWP_PROFILE-14/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=4
@{config_p0uepush_PHRconfig}
...    NRBTS:phrConfig:dlPathlossChg=1dB
...    NRBTS:phrConfig:tPeriodicPhr=10sf
...    NRBTS:phrConfig:tProhibitPhr=10sf
...    NRBTS:srbInactivityTimerSA=600
...    NRBTS/NRDU-1:dlToUlContributionRatio=5    # 50
...    NRCELL-12:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-1:ulPowerControlCommon:p0UePusch=-6
...    NRCELL-2:ulPowerControlCommon:p0UePusch=-6
...    NRCELL-3:ulPowerControlCommon:p0UePusch=-6
...    NRCELL-4:ulPowerControlCommon:p0UePusch=-6
@{online_change_PHR}
...    NRBTS:phrConfig:dlPathlossChg=3dB
...    NRBTS:phrConfig:tPeriodicPhr=20sf
...    NRBTS:phrConfig:tProhibitPhr=50sf
@{config_pmaxNROwncell}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRCELL-1:pMaxNROwnCell=23
...    NRCELL-3:pMaxNROwnCell=20
...    NRCELL-12:pMaxNROwnCell=20
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlAndUl
${N71DLUL_N41DLUL_N71DLUL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00098000702A0D883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FF8007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F180000000000000000000003C0
...    4FFF800003FFE00000260001C00178B850001C46000E230000010B010200E0234028809B01043D001C020800140467A09801E00140E0A00E0
...    601280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010
...    0000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B052B066B056B296B266B01
...    6B036B012B022B07681A0800004B29202000032CA480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480
...    800044B29202000132CA480800054B29202000172CA480800064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A9345
...    5018AA051549A2A83C5090178095028140A05028140A05028140A05028140A05028140018202018030080100220100200404030060100C018
...    402004008080600C02018030404030060100C018402004008080600C02018000804030060100C018040300618080600C02018030080100402
...    004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680
${N71DLUL_N41DLUL_N78DLUL}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1C
...    F88E3D033EC09F1891C790E7D473E618F28581C0E1E0B801FF800E007FE00098000702A0D883AC1184341020F10480CAD931562439F604F88
...    E3C62471E439F51CF9863CA1607038784FEC000003FB000000260001C0AA3626EB04610D04083A412030B64C55110E7C471E238F40CFB027C
...    639F30C7942C0E070F05C00FFC007003FF0004C0003815C7C46D608C21A08107CA090155B262AC2873E238F180000000000000000000003C0
...    4FFF800003FFE00000260001C00178B850001C46000E268000010B010200E0234028809B01043D001C021000140467A09801E00140E0A00E0
...    601280380030120020301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018010
...    0000E008004000000100001000800009004000018020000280100001600800409024010000180672A6B2A6B052B052B066B056B296B266B01
...    6B036B012B022B07681A0800004B29202000032CA480800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480
...    800044B29202000132CA480800054B29202000172CA480800064B29202000062CA480669545D2A8AA55174AA2A82C55058AA0D154A62A9345
...    5018AA051549A2A83C5090178095028140A05028140A05028140A05028140A050281400182020180300801002201002004040300601002004
...    402004008080600C02018030404030060100C018402004008080600C02018000804030060100C018040300618080600C02018030080100402
...    004010D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A0C1680
${N71DLUL_N41DL_N71DL_N78DLUL_PC2a}    SEPARATOR=
...    E1A2538057E01A0104001EF406AC0007865002C04220000800180102418F4047B003C1326439F22D7A0ABD825E819F604F81E3C471E100101
...    8093170019C3D09003120D0098040623807D46C28C0D608C21A0810748260516CAA2A121CFA067D813E31CF9863CA16070387802100000308
...    0A09050138002F800E000BE000910C1B28000280000005200602A8F88DAC1184341020F104C092D954541439F40CF8C73E618F28581C0E1E0
...    0420000061014120A027F0000001FC000000120180A400C0551B137582308682041D2098145B2A8A84873E819F604F8C73E618F28581C0E1E
...    008400000C2028241404E000B60038002D800240301480180AA3E20EB04610D04083C413024B65515050E7D033E31CF9863CA160703878010
...    80000184050482809FD0000007F4000000484603040290030002B1F13400388C0818280308C00073907005011A014404D0F401100C6813836
...    5AF1C0050119E825407C006000E0000020280301804A00C000C07C06004000000020000040100000400800400000010008020080200100002
...    00400001807CA9AC0CBCA5AC08A0182000000360208000080D8002000040000008000180000007A55574AA2A81455038A1281D806A0702814
...    0E05038001A1084002680310000008040000020100000080400000200048804008010100400004010001008010020200C0000802000001008
...    004202004008080500010100C00404010001018010050020080C0380380200806008004038001008010040200C00008020083010020080402
...    8040100200004028000808060040200802040401004010040000B1701406014A2020066300
${N71DLUL_N41DL_N71DL_N78DLUL_PC2b}    SEPARATOR=
...    E1A2538057E01A0104001EF406AC0007865002C04220000800180102418F4047B003C1326439F22D7A0ABD825E819F604F81E3C471E100101
...    8093170019C3D09003120D0098040623807D46C28C0D608C21A0810748260516CAA2A121CFA067D813E31CF9863CA16070387802100000308
...    0A090500B8002F800E000BE000910C1B28000280000005200602A8F88DAC1184341020F104C092D954541439F40CF8C73E618F28581C0E1E0
...    0420000061014120A027F0000001FC000000120180A400C0551B137582308682041D2098145B2A8A84873E819F604F8C73E618F28581C0E1E
...    008400000C2028241402E000B60038002D800240301480180AA3E20EB04610D04083C413024B65515050E7D033E31CF9863CA160703878010
...    80000184050482809FD0000007F4000000484603040290030002B1F13400388C0818280308C00073907005011A014404D0F401100C6813836
...    5AF1C0050119E825407C006000E0000020280301804A00C000C07C06004000000020000040100000400800400000010008020080200100002
...    00400001807CA9AC0CBCA5AC08A0182000000360208000080D8002000040000008000180000007A55574AA2A81455038A1281D806A0702814
...    0E05038001A1084002680310000008040000020100000080400000200048804008010100400004010001008010020200C0000802000001008
...    004202004008080500010100C00404010001018010050020080C0380380200806008004038001008010040200C00008020083010020080402
...    8040100200004028000808060040200802040401004010040000B1701406014A2020066300
${normal_report_A2}    3s
${Cell1_TDD_PCI}    50
${Cell2_TDD_PCI}    51
${Cell3_TDD_PCI}    52
${Cell4_TDD_PCI}    53
${Cell11_FDD_PCI}    60
${Cell1_ssbFrequency}    632736
${Cell3_ssbFrequency}    508110
${Cell12_ssbFrequency}    126750
${Max_Ue_Num}    20
${Max_Retry_Num}    ${${1500//${Max_Ue_Num}}+1}
${Ue_Thp_Dl}    ${1000//${Max_Ue_Num}}
${Ue_Thp_Ul}    ${200//${Max_Ue_Num}}
${Traffic_Tolerance_Percentage_Dl}    0.5    # 0.2
${Traffic_Tolerance_Percentage_Ul}    0.5    # 0.2
${Small_Traffic_Tolerance_Percentage_Dl}    0.2
${Small_Traffic_Tolerance_Percentage_Ul}    0.2
${SingleUE_Traffic_Tolerance_Percentage_Dl}    0.3
${SingleUE_Traffic_Tolerance_Percentage_Ul}    0.35
${Traffic_Compensation_Dl}    ${100000//${Max_Ue_Num}}
${Traffic_Compensation_Ul}    -300    # ${50000//${Max_Ue_Num}} ?
${Tgt_Ue_Thp_Dl}    ${300000//${Max_Ue_Num}}
${Tgt_Ue_Thp_Ul}    ${60000//${Max_Ue_Num}}
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
${A2MEAS_REL1ULSCELL_ATT_SA}    M55118C10003
${A2MEAS_REL1ULSCELL_SUCC_SA}    M55118C10004
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
# ${MAX_UE_PCEL_1_CONF_SCEL_UL_SA}    M55118C10007
${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}    M55156C10007
@{PM_COUNTERS_SCELL_CHANGE}
...    NRCELL-12:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=0    # ${${Max_Ue_Num}*${Max_Retry_Num}} ?
...    NRCELL-12:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=0    # ${${Max_Ue_Num}*${Max_Retry_Num}} ?
...    NRCELL-12:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=${${Max_Ue_Num}*${Max_Retry_Num}}
...    NRCELL-12:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=${${Max_Ue_Num}*${Max_Retry_Num}}
...    NRCELL-12:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>${${${Max_Ue_Num}*${Max_Retry_Num}}*60}
...    NRCELL-3:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>${${${Max_Ue_Num}*${Max_Retry_Num}}*60}
# ...    last NRCELL-12:NCAC:${MAX_UE_PCEL_1_CONF_SCEL_UL_SA}>=${${Max_Ue_Num}//2}
@{PM_COUNTERS_SCELL_CHANGE_MULTI_UE}
...    NRCELL-12:NCAC:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=0
...    NRCELL-12:NCAC:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=0
...    NRCELL-12:NCAC:${A2MEAS_REL1ULSCELL_ATT_SA}=${${${Max_Ue_Num}*${Max_Retry_Num}}+1}
...    NRCELL-12:NCAC:${A2MEAS_REL1ULSCELL_SUCC_SA}=${${${Max_Ue_Num}*${Max_Retry_Num}}+1}
...    NRCELL-12:NCAC:${UE_PCELL_1_CONF_SCELL_UL_SA}>${${${${Max_Ue_Num}*${Max_Retry_Num}}*2}+60}
...    NRCELL-3:NCAC:${UE_SCELL_1_CONF_SCELL_UL_SA}>${${${${Max_Ue_Num}*${Max_Retry_Num}}*2}+60}
@{PM_COUNTERS_SCELL_CHANGE_MAX_ULCA_UE}
...    NRCELL-12:CUCM:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}=2

*** Test Cases ***
TranRob_ECERDxxxxx_CN3_01_Multi_UEs_FDD_TDD_ULCA_SCELL_CHANGE
    [Documentation]
    ...    GNB configuration
    ...    cell-1: band78 CHBW=80M NRARFCN=633000 PCI=50 icrid=1 scellprio=1
    ...    cell-2: band78 CHBW=80M NRARFCN=633000 PCI=51 icrid=2 scellprio=2
    ...    cell-3: band41 CHBW=60M NRARFCN=508020 PCI=52 icrid=3 scellprio=1
    ...    cell-4: band41 CHBW=60M NRARFCN=508020 PCI=53 icrid=4 scellprio=2
    ...    cell-11: band71 CHBW=10M PCI=60 icrid=11
    ...    cell-12: band71 CHBW=20M PCI=61 icrid=12
    ...    for TDD cell-1 and cell-2 large(80M)
    ...    step1: register UEs to FDD cell-12 and do FDD DL only scell addiotn and check p0, pHR-config and timerReassembly
    ...           p0: absent
    ...           multiplePHR: absent
    ...           timerReassembly: absent
    ...    step2: UEs report A1 to trigger DL only scell change to DL&UL scell and check p0, pHR-config and timerReassembly
    ...           p0: set based on NIDD for Pcell
    ...           multiplePHR: true
    ...           timerReassembly: based on NIDD ulTReassemblyIBCA
    ...           PHR-config setting from UE context
    ...    step3: UEs report A2 for UL scell release and check p0, pHR-config and timerReassembly
    ...           p0: 0
    ...           multiplePHR: false
    ...           timerReassembly: based on NIDD ulTReassembly
    [Tags]    QC_    TC01
    [Timeout]    48h
    Clear Counter Files
    Delta Commission Parameters And Wait Cells Onair    ${config_p0uepush_PHRconfig}
    # UE-1 do UL scell addition swap and release
    Multiple UEs do UL scell change and release
    Check Rrc Log    ${CURDIR}${/}a2a_01${/}a2a_01.ini
    Check Wireshark Log    ${CURDIR}${/}a2a_01${/}a2a_01.ini    name=Test_${Max_Retry_Num}
    ...    wait_string=UEContextReleaseComplete::${${Max_Ue_Num}*4}    # ${${${Max_Ue_Num}*${Max_Retry_Num}}*4}
    Check Counters    ${PM_COUNTERS_SCELL_CHANGE}

TranRob_ECERDxxxxx_CN3_02_Multi_UEs_FDD_TDD_ULCA_SCELL_CHANGE_WO_HIGH_TRAFFIC
    [Documentation]
    ...    Simplified version of TC01 to save disk space and shorten execution time
    [Tags]    TC02
    [Timeout]    48h
    Clear Counter Files
    Delta Commission Parameters And Wait Cells Onair    ${config_p0uepush_PHRconfig}
    Multiple UEs do UL scell change and release without high traffic
    Single UE do UL scell change and release with high traffic
    Check Rrc Log    ${CURDIR}${/}a2a_01${/}a2a_02.ini
    Check Wireshark Log  ${CURDIR}${/}a2a_01${/}a2a_02.ini    name=UE_${${Max_Ue_Num}+1}
    ...    wait_string=UEContextReleaseComplete::4    # ${${${${Max_Ue_Num}*${Max_Retry_Num}}+1}*4}
    Check Counters    ${PM_COUNTERS_SCELL_CHANGE_MULTI_UE}
    Two UEs do UL scell change and release then check max ULCA UE number

TranRob_ECERDxxxxx_CN3_03_Multi_UEs_FDD_TDD_ULCA_SCELL_SWAP
    [Documentation]
    ...    step1: register UEs to FDD cell-12 and do UL scell addiotn and check p0, pHR-config and timerReassembly
    ...           p0: set based on NIDD for Pcell
    ...           multiplePHR: true
    ...           timerReassembly: based on NIDD ulTReassemblyIBCA
    ...    step2: UEs report A6 for UL scell swap and check p0, pHR-config and timerReassembly
    ...           p0: absent
    ...           multiplePHR: absent
    ...           timerReassembly: absent
    ...    step3: UEs report A2 for UL scell release and check p0, pHR-config and timerReassembly
    ...           p0: 0
    ...           multiplePHR: false
    ...           timerReassembly: based on NIDD ulTReassembly
    [Tags]    QC_    TC03
    [Timeout]    48h
    Log To Console    ToDo

TranRob_ECERDxxxxx_CN3_04_Multi_UEs_FDD_TDD_ULCA_SCELL_SWAP_WO_HIGH_TRAFFIC
    [Documentation]
    ...    Simplified version of TC03 to save disk space and shorten execution time
    [Tags]    QC_    TC04
    [Timeout]    48h
    Log To Console    ToDo

TranRob_ECERDxxxxx_CN3_05_Multi_UEs_FDD_TDD_ULCA_SCELL_CHANGE_WO_HIGH_TRAFFIC_Interworking_With_Multi_BWP
    [Documentation]
    ...    Verify the interworking between TC02 and multiple BWP
    [Tags]    QC_    TC05
    [Timeout]    48h
    Log To Console    ToDo

TranRob_ECERDxxxxx_CN3_06_Multi_UEs_FDD_TDD_ULCA_SCELL_SWAP_WO_HIGH_TRAFFIC_Interworking_With_Multi_BWP
    [Documentation]
    ...    Verify the interworking between TC04 and multiple BWP
    [Tags]    QC_    TC06
    [Timeout]    48h
    Log To Console    ToDo

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}
    Execute Cmd On PC    sudo sysctl -w net.sctp.sack_timeout=10
    Execute Cmd On PC    sudo sysctl -w net.sctp.rto_min=200
    Execute Cmd On PC    sudo sysctl -w net.sctp.rto_initial=200
    Execute Cmd On PC    sudo sysctl -w net.sctp.rto_max=800
    Execute Cmd On PC    sudo cat /proc/sys/net/sctp/rto_min

Local Suite Teardown And Restore BTS Configuration Parameters
    Common Suite Teardown And Restore BTS Configuration Parameters
    reporting.Manual Report Portal    fast_mode=${REPORT_FAST}    rep_debug=${REPORT_DEBUG}

Modify Cfg
    # Update Cfg    set PEER_UPLANE_IP='10.0.2.99'
    ${set_uec}    Catenate
    ...    set_uec id=1 daemon=$SERVER_IP:$EDAEMON_PORT peer=$SERVER_IP:2152 peer_uplane=10.0.2.99:2152
    ...    retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=$UEC_ADDR/26 ctrl_conn_timeout=150000
    Update Cfg    ${set_uec}

Multiple UEs do UL scell change and release
    Stop Capture Wireshark Log    decode_flag=False
    FOR    ${retry_id}    IN RANGE    1    ${${Max_Retry_Num}+1}
        Start To Capture Wireshark Log    tag=Test_${retry_id}
        Start To Capture BTS UdpLogs    tag=Test_${retry_id}
        Start Rrc Log    Test_${retry_id}
        Start to Capture Gnb Ttitrace    tag=Test_${retry_id}    cell_id=all
        _Start To Capture UTE Wireshark    tag=Test_${retry_id}
        Bulk UEs Scell Addition and Change With Traffic    ${retry_id}
        _Stop Capture UTE Wireshark
        Run Keyword If    ${UTE_WIRESHARK_FLAG}    Remove File    ${TEST_LOG_DIR}${/}ute_wireshark_eth*.pcap
        Stop Capture Gnb Ttitrace    tag=Test_${retry_id}    decode_flag=False
        Remove Directory    ${TEST_LOG_DIR}${/}gnb_ttitrace_logs_Test_${retry_id}    recursive=True
        Get Rrc Log
        # Stop Capture BTS UdpLogs    tag=Test_${retry_id}
        Run Keyword Unless    '${retry_id}' == '${Max_Retry_Num}'
        ...    Stop Capture Wireshark Log    tag=Test_${retry_id}    decode_flag=False
    END
    [Teardown]    Collect Big Logs If Fail    tag=Test_${retry_id}

Multiple UEs do UL scell change and release without high traffic
    Stop Capture Wireshark Log    decode_flag=False
    FOR    ${retry_id}    IN RANGE    1    ${${Max_Retry_Num}+1}
        Start To Capture Wireshark Log    tag=Test_${retry_id}
        Start To Capture BTS UdpLogs    tag=Test_${retry_id}
        Start Rrc Log    Test_${retry_id}
        Start to Capture Gnb Ttitrace    tag=Test_${retry_id}    cell_id=all
        _Start To Capture UTE Wireshark    tag=Test_${retry_id}
        Bulk UEs Scell Addition and Change Without High Traffic    ${retry_id}
        _Stop Capture UTE Wireshark
        Run Keyword If    ${UTE_WIRESHARK_FLAG}    Remove File    ${TEST_LOG_DIR}${/}ute_wireshark_eth*.pcap
        Stop Capture Gnb Ttitrace    tag=Test_${retry_id}    decode_flag=False
        Remove Directory    ${TEST_LOG_DIR}${/}gnb_ttitrace_logs_Test_${retry_id}    recursive=True
        Get Rrc Log
        Stop Capture BTS UdpLogs    tag=Test_${retry_id}
        Remove File    ${TEST_LOG_DIR}${/}btslog_Test_${retry_id}.LOG
        Run Keyword If    '${retry_id}' == '${Max_Retry_Num}'    Stop Capture Wireshark Log    tag=Test_${retry_id}    decode_flag=True
        ...    ELSE    Stop Capture Wireshark Log    tag=Test_${retry_id}    decode_flag=False
    END
    [Teardown]    Collect Big Logs With Last If Fail    tag=Test_${retry_id}

Single UE do UL scell change and release with high traffic
    Start To Capture Wireshark Log    tag=UE_${${Max_Ue_Num}+1}
    Start To Capture BTS UdpLogs    tag=UE_${${Max_Ue_Num}+1}
    Start Rrc Log    Test_${${Max_Retry_Num}+1}
    Start to Capture Gnb Ttitrace    tag=UE_${${Max_Ue_Num}+1}    cell_id=all
    _Start To Capture UTE Wireshark    tag=UE_${${Max_Ue_Num}+1}
    Single UE Scell Addition and Change With High Traffic    ${${Max_Ue_Num}+1}
    _Stop Capture UTE Wireshark
    # Run Keyword If    ${UTE_WIRESHARK_FLAG}    Remove File    ${TEST_LOG_DIR}${/}ute_wireshark_eth*.pcap
    Stop Capture Gnb Ttitrace    tag=UE_${${Max_Ue_Num}+1}    decode_flag=False
    # Remove Directory    ${TEST_LOG_DIR}${/}gnb_ttitrace_logs_UE_${${Max_Ue_Num}+1}    recursive=True
    Get Rrc Log
    [Teardown]    Collect Big Logs If Fail    tag=UE_${${Max_Ue_Num}+1}

Bulk UEs Scell Addition and Change With Traffic
    [Arguments]    ${retry_id}
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${ue_id}    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
        Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added    ue_id=${ue_id}
        ${tgt_thp_dl}=    Set Variable If    ${Ue_Thp_Dl} > 150    150    ${Ue_Thp_Dl}
        ${tgt_thp_ul}=    Set Variable If    ${Ue_Thp_Ul} > 150    150    ${Ue_Thp_Ul}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${tgt_thp_dl} trf_id=1 protocol=tcp
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${tgt_thp_ul} trf_id=1 protocol=tcp
        Sleep    5s
    END
    Sleep    25s
    @{thp_list}=    Create List
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        ${dl_max_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=max
        ${dl_ave_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
        ${ul_max_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=max
        ${ul_ave_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
        Append To List    ${thp_list}    ${dl_max_init}    ${dl_ave_init}    ${ul_max_init}    ${ul_ave_init}
        ${print}=    Catenate    SEPARATOR=
        ...    \nRound-${retry_id} UE-${ue_id} Before Scell Change:\ndl_max = ${dl_max_init}\ndl_ave = ${dl_ave_init}\n
        ...    ul_max = ${ul_max_init}\nul_ave = ${ul_ave_init}
        Log To Console    ${print}
        Log    dl_max_init = ${dl_max_init} dl_ave_init = ${dl_ave_init} ul_max_init = ${ul_max_init} ul_ave_init = ${ul_ave_init}
        Sleep    2s
    END
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        Trigger Scell Change to TDD DL and UL scell    ue_id=${ue_id}
        Sleep    2s
    END
    Sleep    18s
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        @{ue_thp}=    Create List
        ...    ${thp_list[${${${ue_id}*4}-4}]}
        ...    ${thp_list[${${${ue_id}*4}-3}]}
        ...    ${thp_list[${${${ue_id}*4}-2}]}
        ...    ${thp_list[${${${ue_id}*4}-1}]}
        Check Continuous Throughput After Scell Change    ${ue_id}    ${retry_id}    ${ue_thp}
    END
    # Trigger UL scell swap from TDD cell-3 to cell-4    ue_id=3    scell_id=2    scell_phy_id=${Cell4_TDD_PCI}
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        Execute Egate Command    trf_data_stop ue=${ue_id}
        Sleep    2s
        Scell A2 report to trigger Scell Release     ue_id=${ue_id}    carrierfreq=${Cell3_ssbFrequency}    scell_id=2
    END
    Release UEs    ue_type=all

Bulk UEs Scell Addition and Change Without High Traffic
    [Arguments]    ${retry_id}
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${ue_id}    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
        Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added    ue_id=${ue_id}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=1 trf_id=1 protocol=tcp
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul kbps=100 trf_id=1 protocol=tcp
        Sleep    3s
    END
    @{thp_list}=    Create List
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        ${dl_max_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=max
        ${dl_ave_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
        ${ul_max_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=max
        ${ul_ave_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
        Append To List    ${thp_list}    ${dl_max_init}    ${dl_ave_init}    ${ul_max_init}    ${ul_ave_init}
        ${print}=    Catenate    SEPARATOR=
        ...    \nRound-${retry_id} UE-${ue_id} Before Scell Change:\ndl_max = ${dl_max_init}\ndl_ave = ${dl_ave_init}\n
        ...    ul_max = ${ul_max_init}\nul_ave = ${ul_ave_init}
        Log To Console    ${print}
        Log    dl_max_init = ${dl_max_init} dl_ave_init = ${dl_ave_init} ul_max_init = ${ul_max_init} ul_ave_init = ${ul_ave_init}
        Sleep    2s
    END
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        Trigger Scell Change to TDD DL and UL scell    ue_id=${ue_id}
        Sleep    2s
    END
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        @{ue_thp}=    Create List
        ...    ${thp_list[${${${ue_id}*4}-4}]}
        ...    ${thp_list[${${${ue_id}*4}-3}]}
        ...    ${thp_list[${${${ue_id}*4}-2}]}
        ...    ${thp_list[${${${ue_id}*4}-1}]}
        Check Throughput After Scell Change    ${ue_id}    ${retry_id}    ${ue_thp}
    END
    FOR    ${ue_id}    IN RANGE    1    ${${Max_Ue_Num}+1}
        Execute Egate Command    trf_data_stop ue=${ue_id}
        Sleep    2s
        Scell A2 report to trigger Scell Release     ue_id=${ue_id}    carrierfreq=${Cell3_ssbFrequency}    scell_id=2
    END
    Release UEs    ue_type=all

Single UE Scell Addition and Change With High Traffic
    [Arguments]    ${ue_id}    # ${retry_id}=${${Max_Retry_Num}+1}
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${ue_id}    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
    Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added    ue_id=${ue_id}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=1 protocol=tcp
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150 trf_id=2 protocol=tcp
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=30 trf_id=1 protocol=tcp
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=30 trf_id=2 protocol=tcp
    Sleep    30s
    @{thp_list}=    Create List
    ${dl_max_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=max
    ${dl_ave_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_max_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=max
    ${ul_ave_init}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Append To List    ${thp_list}    ${dl_max_init}    ${dl_ave_init}    ${ul_max_init}    ${ul_ave_init}
    ${print}=    Catenate    SEPARATOR=
    ...    \nFinal UE-${ue_id} Before Scell Change:\ndl_max = ${dl_max_init}\ndl_ave = ${dl_ave_init}\n
    ...    ul_max = ${ul_max_init}\nul_ave = ${ul_ave_init}
    Log To Console    ${print}
    Log    dl_max_init = ${dl_max_init} dl_ave_init = ${dl_ave_init} ul_max_init = ${ul_max_init} ul_ave_init = ${ul_ave_init}
    Sleep    2s
    Trigger Scell Change to TDD DL and UL scell    ue_id=${ue_id}
    Sleep    20s
    Check Single UE Continuous Throughput After Scell Change    ${ue_id}    ${thp_list}
    Execute Egate Command    trf_data_stop ue=${ue_id}
    Sleep    2s
    Scell A2 report to trigger Scell Release     ue_id=${ue_id}    carrierfreq=${Cell3_ssbFrequency}    scell_id=2
    Release UEs    ue_type=all

Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added
    [Arguments]    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell11_FDD_PCI}, scellIdx:1
    Should Not Contain    ${ret1}    multiplePHR
    Should Not Contain    ${ret1}    p0 -3

Trigger Scell Change to TDD DL and UL scell
    [Arguments]    ${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell3_TDD_PCI}, scellIdx:2
    Should Contain    ${ret1}    multiplePHR TRUE
    Should Contain    ${ret1}    p0 -3

Trigger Scell Addition to TDD DL and UL scell
    [Arguments]    ${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${Cell12_ssbFrequency}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete
    Should Contain    ${ret1}    pcid:${Cell3_TDD_PCI}, scellIdx:1
    Should Contain    ${ret1}    multiplePHR TRUE
    Should Contain    ${ret1}    p0 -3

Check Continuous Throughput After Scell Change
    [Arguments]    ${ue_id}    ${retry_id}    ${ue_thp}
    FOR    ${i}    IN RANGE    1    7
        Sleep    10s
        ${dl_max}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=max
        ${dl_ave}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
        ${ul_max}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=max
        ${ul_ave}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
        ${print}=    Catenate    SEPARATOR=
        ...    \nRound-${retry_id} UE-${ue_id} After Scell Change No.${i}:\ndl_max = ${dl_max}\ndl_ave = ${dl_ave}\n
        ...    ul_max = ${ul_max}\nul_ave = ${ul_ave}
        Log To Console    ${print}
        Log    dl_max = ${dl_max} dl_ave = ${dl_ave} ul_max = ${ul_max} ul_ave = ${ul_ave}
        ${format}=    Catenate
        ...    ${ue_thp[0]} + ${Traffic_Compensation_Dl} - ${dl_max} <
        ...    (${ue_thp[0]} + ${Traffic_Compensation_Dl}) * ${Traffic_Tolerance_Percentage_Dl}
        ${status}=    Evaluate    ${format}
        Should Be Equal As Strings    ${status}    True
        ${format}=    Catenate
        ...    ${ue_thp[1]} + ${Traffic_Compensation_Dl} - ${dl_ave} <
        ...    (${ue_thp[1]} + ${Traffic_Compensation_Dl}) * ${Traffic_Tolerance_Percentage_Dl}
        ${status}=    Evaluate     ${format}
        Should Be Equal As Strings    ${status}    True
        ${format}=    Catenate
        ...    ${ue_thp[2]} + ${Traffic_Compensation_Ul} - ${ul_max} <
        ...    (${ue_thp[2]} + ${Traffic_Compensation_Ul}) * ${Traffic_Tolerance_Percentage_Ul}
        ${status}=    Evaluate     ${format}
        Should Be Equal As Strings    ${status}    True
        ${format}=    Catenate
        ...    ${ue_thp[3]} + ${Traffic_Compensation_Ul} - ${ul_ave} <
        ...    (${ue_thp[3]} + ${Traffic_Compensation_Ul}) * ${Traffic_Tolerance_Percentage_Ul}
        ${status}=    Evaluate     ${format}
        Should Be Equal As Strings    ${status}    True
        ${status}=    Run Keyword And Return Status    Should Be True    ${dl_max} > ${${Tgt_Ue_Thp_Dl}*${1-${Traffic_Tolerance_Percentage_Dl}}}
        Run Keyword Unless    ${status}    Log    dl_max_thp is too low!    level=WARN    console=False
        ${status}=    Run Keyword And Return Status    Should Be True    ${dl_ave} > ${${Tgt_Ue_Thp_Dl}*${1-${Traffic_Tolerance_Percentage_Dl}}}
        Run Keyword Unless    ${status}    Log    dl_ave_thp is too low!    level=WARN    console=False
        ${status}=    Run Keyword And Return Status    Should Be True    ${ul_max} > ${${Tgt_Ue_Thp_Ul}*${1-${Traffic_Tolerance_Percentage_Ul}}}
        Run Keyword Unless    ${status}    Log    ul_max_thp is too low!    level=WARN    console=False
        ${status}=    Run Keyword And Return Status    Should Be True    ${ul_ave} > ${${Tgt_Ue_Thp_Ul}*${1-${Traffic_Tolerance_Percentage_Ul}}}
        Run Keyword Unless    ${status}    Log    ul_ave_thp is too low!    level=WARN    console=False
    END

Check Throughput After Scell Change
    [Arguments]    ${ue_id}    ${retry_id}    ${ue_thp}
    ${dl_max}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=max
    ${dl_ave}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_max}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=max
    ${ul_ave}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${print}=    Catenate    SEPARATOR=
    ...    \nRound-${retry_id} UE-${ue_id} After Scell Change:\ndl_max = ${dl_max}\ndl_ave = ${dl_ave}\n
    ...    ul_max = ${ul_max}\nul_ave = ${ul_ave}
    Log To Console    ${print}
    Log    dl_max = ${dl_max} dl_ave = ${dl_ave} ul_max = ${ul_max} ul_ave = ${ul_ave}
    ${format}=    Catenate
    ...    ${ue_thp[0]} - ${dl_max} < ${ue_thp[0]} * ${Small_Traffic_Tolerance_Percentage_Dl}
    ...    or ${dl_max} > ${1000*${1-${Small_Traffic_Tolerance_Percentage_Dl}}}
    ${status}=    Evaluate    ${format}
    Should Be Equal As Strings    ${status}    True
    ${format}=    Catenate
    ...    ${ue_thp[1]} - ${dl_ave} < ${ue_thp[1]} * ${Small_Traffic_Tolerance_Percentage_Dl}
    ...    or ${dl_ave} > ${1000*${1-${Small_Traffic_Tolerance_Percentage_Dl}}}
    ${status}=    Evaluate    ${format}
    Should Be Equal As Strings    ${status}    True
    ${format}=    Catenate
    ...    ${ue_thp[2]} - ${ul_max} < ${ue_thp[2]} * ${Small_Traffic_Tolerance_Percentage_Ul}
    ...    or ${ul_max} > ${100*${1-${Small_Traffic_Tolerance_Percentage_Ul}}}
    ${status}=    Evaluate    ${format}
    Should Be Equal As Strings    ${status}    True
    ${format}=    Catenate
    ...    ${ue_thp[3]} - ${ul_ave} < ${ue_thp[3]} * ${Small_Traffic_Tolerance_Percentage_Ul}
    ...    or ${ul_ave} > ${100*${1-${Small_Traffic_Tolerance_Percentage_Ul}}}
    ${status}=    Evaluate    ${format}
    Should Be Equal As Strings    ${status}    True
#    ${status}=    Run Keyword And Return Status    Should Be True    ${dl_max} > ${1000*${1-${Small_Traffic_Tolerance_Percentage_Dl}}}
#    Run Keyword Unless    ${status}    Log    dl_max_thp is too low!    level=WARN    console=False
#    ${status}=    Run Keyword And Return Status    Should Be True    ${dl_ave} > ${1000*${1-${Small_Traffic_Tolerance_Percentage_Dl}}}
#    Run Keyword Unless    ${status}    Log    dl_ave_thp is too low!    level=WARN    console=False
#    ${status}=    Run Keyword And Return Status    Should Be True    ${ul_max} > ${100*${1-${Small_Traffic_Tolerance_Percentage_Ul}}}
#    Run Keyword Unless    ${status}    Log    ul_max_thp is too low!    level=WARN    console=False
#    ${status}=    Run Keyword And Return Status    Should Be True    ${ul_ave} > ${100*${1-${Small_Traffic_Tolerance_Percentage_Ul}}}
#    Run Keyword Unless    ${status}    Log    ul_ave_thp is too low!    level=WARN    console=False

Check Single UE Continuous Throughput After Scell Change
    [Arguments]    ${ue_id}    ${ue_thp}    # ${retry_id}=${${Max_Retry_Num}+1}
    FOR    ${i}    IN RANGE    1    7
        Sleep    10s
        ${dl_max}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=max
        ${dl_ave}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
        ${ul_max}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=max
        ${ul_ave}=    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
        ${print}=    Catenate    SEPARATOR=
        ...    \nFinal UE-${ue_id} After Scell Change No.${i}:\ndl_max = ${dl_max}\ndl_ave = ${dl_ave}\n
        ...    ul_max = ${ul_max}\nul_ave = ${ul_ave}
        Log To Console    ${print}
        Log    dl_max = ${dl_max} dl_ave = ${dl_ave} ul_max = ${ul_max} ul_ave = ${ul_ave}
        ${format}=    Catenate
        ...    ${ue_thp[0]} + 100000 - ${dl_max} <
        ...    (${ue_thp[0]} + 100000) * ${SingleUE_Traffic_Tolerance_Percentage_Dl}
        ${status}=    Evaluate    ${format}
        Should Be Equal As Strings    ${status}    True
        ${format}=    Catenate
        ...    ${ue_thp[1]} + 100000 - ${dl_ave} <
        ...    (${ue_thp[1]} + 100000) * ${SingleUE_Traffic_Tolerance_Percentage_Dl}
        ${status}=    Evaluate     ${format}
        Should Be Equal As Strings    ${status}    True
        ${format}=    Catenate
        ...    ${ue_thp[2]} + 50000 - ${ul_max} <
        ...    (${ue_thp[2]} + 50000) * ${SingleUE_Traffic_Tolerance_Percentage_Ul}
        ${status}=    Evaluate     ${format}
        Should Be Equal As Strings    ${status}    True
        ${format}=    Catenate
        ...    ${ue_thp[3]} + 50000 - ${ul_ave} <
        ...    (${ue_thp[3]} + 50000) * ${SingleUE_Traffic_Tolerance_Percentage_Ul}
        ${status}=    Evaluate     ${format}
        Should Be Equal As Strings    ${status}    True
        ${status}=    Run Keyword And Return Status    Should Be True    ${dl_max} > ${300000*${1-${SingleUE_Traffic_Tolerance_Percentage_Dl}}}
        Run Keyword Unless    ${status}    Log    dl_max_thp is too low!    level=WARN    console=False
        ${status}=    Run Keyword And Return Status    Should Be True    ${dl_ave} > ${300000*${1-${SingleUE_Traffic_Tolerance_Percentage_Dl}}}
        Run Keyword Unless    ${status}    Log    dl_ave_thp is too low!    level=WARN    console=False
        ${status}=    Run Keyword And Return Status    Should Be True    ${ul_max} > ${60000*${1-${SingleUE_Traffic_Tolerance_Percentage_Ul}}}
        Run Keyword Unless    ${status}    Log    ul_max_thp is too low!    level=WARN    console=False
        ${status}=    Run Keyword And Return Status    Should Be True    ${ul_ave} > ${60000*${1-${SingleUE_Traffic_Tolerance_Percentage_Ul}}}
        Run Keyword Unless    ${status}    Log    ul_ave_thp is too low!    level=WARN    console=False
    END

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

Collect Big Logs If Fail
    [Arguments]    ${tag}
    _Stop Capture UTE Wireshark
    Run Keyword And Ignore Error    Stop Capture Gnb Ttitrace    tag=${tag}    decode_flag=False
    Run Keyword Unless    '${tag}' == 'Test_${Max_Retry_Num}' or '${tag}' == 'UE_${${Max_Ue_Num}+1}'
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Log    tag=${tag}    decode_flag=False

Collect Big Logs With Last If Fail
    [Arguments]    ${tag}
    _Stop Capture UTE Wireshark
    Run Keyword And Ignore Error    Stop Capture Gnb Ttitrace    tag=${tag}    decode_flag=False
    Run Keyword If    '${tag}' == 'Test_${Max_Retry_Num}'
    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Log    tag=${tag}    decode_flag=True
    ...    ELSE    Run Keyword And Ignore Error    Stop Capture Wireshark Log    tag=${tag}    decode_flag=False

Two UEs do UL scell change and release then check max ULCA UE number
    Run Keyword And Ignore Error    Collect EMIL from GNB DCAP
    Start To Capture Wireshark Log    tag=Test_${${Max_Retry_Num}+2}
    Start To Capture BTS UdpLogs    tag=Test_${${Max_Retry_Num}+2}
    Start Rrc Log    Test_${${Max_Retry_Num}+2}
    Clear Counter Files    # wait=False
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${${Max_Ue_Num}+2}    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${${Max_Ue_Num}+3}    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
    Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added    ue_id=${${Max_Ue_Num}+2}
    Trigger FDD DL Scell Addition Via A1 report less than a1ThresholdSCellAddSsbRsrpTDD and 1 FDD scell added    ue_id=${${Max_Ue_Num}+3}
    Trigger Scell Change to TDD DL and UL scell    ue_id=${${Max_Ue_Num}+2}
    Sleep    5s
    Trigger Scell Change to TDD DL and UL scell    ue_id=${${Max_Ue_Num}+3}
    Sleep    5s
    Scell A2 report to trigger Scell Release     ue_id=${${Max_Ue_Num}+2}    carrierfreq=${Cell3_ssbFrequency}    scell_id=2
    Sleep    5s
    Trigger Scell Addition to TDD DL and UL scell    ue_id=${${Max_Ue_Num}+2}
    Sleep    5s
    # Release UEs    ue_type=all    ue_id=${${Max_Ue_Num}+3}
    Execute Egate Command    ue_deregister id=${${Max_Ue_Num}+3} ue_deregister_type=switch_off    UE${${Max_Ue_Num}+3}: detached
    Sleep    5s
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=${${Max_Ue_Num}+3}    ue_capa=${N71DLUL_N41DLUL_N71DLUL}
    Trigger Scell Addition to TDD DL and UL scell    ue_id=${${Max_Ue_Num}+3}
    Sleep    5s
    Check Counters    ${PM_COUNTERS_SCELL_CHANGE_MAX_ULCA_UE}
    [Teardown]    Run Keyword And Ignore Error    Dcap Stop Trace

UE-1 do UL scell addition swap and release
    Start Rrc Log    UE_1
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=1    ue_capa=${N71DLUL_N41DLUL_N78DLUL}
    Trigger Scell Addition Via A1 and 2TDD scell added    ue_id=1
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1 protocol=tcp
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2 protocol=tcp
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=30 trf_id=1 protocol=tcp
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=30 trf_id=2 protocol=tcp
    sleep    60
    ${dl_max_init}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=max
    ${dl_ave_init}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_max_init}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=max
    ${ul_ave_init}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
    Log To Console    \nBefore Scell Swap:\ndl_max = ${dl_max_init}\ndl_ave = ${dl_ave_init}\nul_max = ${ul_max_init}\nul_ave = ${ul_ave_init}
    Log    dl_max_init = ${dl_max_init} dl_ave_init = ${dl_ave_init} ul_max_init = ${ul_max_init} ul_ave_init = ${ul_ave_init}
    Trigger UL scell swap from TDD cell-1 to cell-2    ue_id=1    scell_id=1    scell_phy_id=${Cell2_TDD_PCI}
    FOR    ${i}    IN RANGE    1    13
        sleep    10
        ${dl_max}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=max
        ${dl_ave}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=dl    rate_type=ave
        ${ul_max}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=max
        ${ul_ave}=    ap_get_sa_throughput    ue_id=1    pdu=1    qfi=1    direction=ul    rate_type=ave
        Log To Console    \nAfter Scell Swap No.${i}:\ndl_max = ${dl_max}\ndl_ave = ${dl_ave}\nul_max = ${ul_max}\nul_ave = ${ul_ave}
        Log    dl_max = ${dl_max} dl_ave = ${dl_ave} ul_max = ${ul_max} ul_ave = ${ul_ave}
        ${status}=    Evaluate    ${dl_max_init} - ${dl_max} < ${dl_max_init} * 0.1    # 30000
        Should Be Equal As Strings    ${status}    True
        ${status}=    Evaluate    ${dl_ave_init} - ${dl_ave} < ${dl_ave_init} * 0.1    # 30000
        Should Be Equal As Strings    ${status}    True
        ${status}=    Evaluate    ${ul_max_init} - ${ul_max} < ${ul_max_init} * 0.15    # 10000
        Should Be Equal As Strings    ${status}    True
        ${status}=    Evaluate    ${ul_ave_init} - ${ul_ave} < ${ul_ave_init} * 0.15    # 10000
        Should Be Equal As Strings    ${status}    True
        ${status}=    Run Keyword And Return Status    Should Be True    ${dl_max} > 270000
        Run Keyword Unless    ${status}    Log    dl_max_thp is too low!    level=WARN    console=True
        ${status}=    Run Keyword And Return Status    Should Be True    ${dl_ave} > 240000
        Run Keyword Unless    ${status}    Log    dl_ave_thp is too low!    level=WARN    console=True
        ${status}=    Run Keyword And Return Status    Should Be True    ${ul_max} > 50000
        Run Keyword Unless    ${status}    Log    ul_max_thp is too low!    level=WARN    console=True
        ${status}=    Run Keyword And Return Status    Should Be True    ${ul_ave} > 40000
        Run Keyword Unless    ${status}    Log    ul_ave_thp is too low!    level=WARN    console=True
    END
    Execute Egate Command    trf_data_stop ue=1
    Scell A2 report to trigger Scell Release     ue_id=1    carrierfreq=${Cell1_ssbFrequency}    scell_id=3
    Get rrc log

UE-2 do UL scell addition after PHR online modification
    Start rrc log    UE_2
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD Cell-12    ue_id=2    ue_capa=${N71DLUL_N41DLUL_N78DLUL}
    delta commission parameters    ${online_change_PHR}
    Trigger Scell Addition Via A1 and 2TDD scell added    ue_id=2
    Get rrc log

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
