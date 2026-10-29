*** Settings ***
Documentation
...    author: lishuo.geng
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Release All UEs And Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_BOO_AP_LOO
...    team-CN3ET    owner-taotao.hu    owner-lishuo.geng    release-SBTS23R3    CB009169    CRT
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${SYSCOM_FLAG}    True
${GNB_CONFIG}    fddtdd_sansa_cmwv/6cells_2T4F
@{PARAMS_IN_IPHY_XML}  fddFrequencyRange=FR1_WB
@{PARAMS_IN_SWCONFIG}
...    @{rdULCaEnablerPhase}
...    @{rdUseOptimizedDpaAlgo}
...    @{rd9169Enable}
@{rdULCaEnablerPhase}
...    0x580591=0
@{rd9169Enable}
...    0x580692=1
@{rdUseOptimizedDpaAlgo}
...    0x58056B=1
@{PARAMS_IN_SCF}
...    @{CB009169}
...    @{CA}
...    @{NRREL}
...    @{gscn_Arfcn}
...    @{VONR}
...    @{CDRX}
...    @{NRHOIF}
...    @{mobility}
...    @{swap}
...    NRBTS:actPucchF3BasedTaGrantsRed=false

${Cell_2_TDD_PCI}    51
${Cell_3_TDD_PCI}    52
${Cell_12_FDD_PCI}    61
${Cell_11_FDD_PCI}    60
${Cell_13_FDD_PCI}    62
${Cell_14_FDD_PCI}    63
${cell_13_ssbFrequency}    430830
${cell_2_ssbFrequency}    636576
${cell_1_ssbFrequency}    518430
${cell_12_ssbFrequency}    126990
${cell_14_ssbFrequency}    126990

#the following parameters are used in pdm check
${TDD_PRB_for_80M}    217
${FDD_PRB_for_10M}    52
${FDD_PRB_for_20M}    106
${FDD_PRB_for_30M}    160
${TDD_PRB_for_60M}    162
${Cell_1_TDD_PCI}    50

# GNB configuration
#TDD cell-1: band41 Chbw=60M PCI=50 (16385)
#TDD cell-2: band78 chbw=80M PCI=51 (16386)

#FDD cell-11: band66 CHbw=20M PCI=60 (16395)
#FDD cell-13: band66 CHbw=30M PCI=62 (16397)
#FDD cell-12: band71 CHbw=10M PCI=61 (16396)
#FDD cell-14: band71 CHbw=10M PCI=63 (16398)


${carrierAggregationSupportList}    SEPARATOR=
...    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fdd,ca_Fr1Tdd_Any_Sa,
...    ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl

@{CB009169}

...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL:maxNumScellsDlFr1=3
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch

@{gscn_Arfcn}
...    NRCELL-1:nrarfcn=518598
...    NRCELL-1:gscnOrSsPbchArfcn=6480
...    NRCELL-1:chBw=60MHz
...    NRCELL-2:nrarfcn=636666
...    NRCELL-2:gscnOrSsPbchArfcn=7880
...    NRCELL-2:chBw=80MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-12/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-12:gscnOrSsPbchArfcn=1587
# for 10HZ FDD chbw, need to remove BWP coresetDedicated
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-0-And-1-0|searchSpaceId=7
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=UE-Specific|searchSpaceId=8
...    MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:dciFormat=formats0-1-And-1-1|searchSpaceId=8
...    delete:MRBTS-1/NRBTS-1/BWP_PROFILE-6/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated

...    NRCELL-14/NRCELL_FDD-1:nrarfcnDl=126900
...    NRCELL-14/NRCELL_FDD-1:nrarfcnUl=136100
...    NRCELL-14/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=1587
...    NRCELL-11/NRCELL_FDD-1:nrarfcnDl=424000
...    NRCELL-11/NRCELL_FDD-1:nrarfcnUl=344000
...    NRCELL-11/NRCELL_FDD-1:chBwDl=20MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=20MHz
...    NRCELL-11:gscnOrSsPbchArfcn=5297
...    NRCELL-11:pMax=400
...    NRCELL-13/NRCELL_FDD-1:nrarfcnDl=430920
...    NRCELL-13/NRCELL_FDD-1:nrarfcnUl=350920
...    NRCELL-13/NRCELL_FDD-1:chBwDl=30MHz
...    NRCELL-13/NRCELL_FDD-1:chBwUl=30MHz
...    NRCELL-13:gscnOrSsPbchArfcn=5385
...    NRCELL-13:pMax=400
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
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=11
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-2:gNbId=1
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=12
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:sCellPrio=1

...    NRCELL-1/NRREL-3:gNbId=1
...    NRCELL-1/NRREL-3:gNbIdLength=22
...    NRCELL-1/NRREL-3:lcrId=13
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-1/NRREL-5:gNbId=1
...    NRCELL-1/NRREL-5:gNbIdLength=22
...    NRCELL-1/NRREL-5:lcrId=2
...    NRCELL-1/NRREL-5:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-5:gnbPlmn:mncLength=3

...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-2:gNbId=1
...    NRCELL-2/NRREL-2:gNbIdLength=22
...    NRCELL-2/NRREL-2:lcrId=12
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-3:gNbId=1
...    NRCELL-2/NRREL-3:gNbIdLength=22
...    NRCELL-2/NRREL-3:lcrId=13
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellOperationalMode=dlAndUl
...    NRCELL-2/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-5:gNbId=1
...    NRCELL-2/NRREL-5:gNbIdLength=22
...    NRCELL-2/NRREL-5:lcrId=1
...    NRCELL-2/NRREL-5:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-5:sCellOperationalMode=dlOnly
...    NRCELL-2/NRREL-5:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-5:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-5:gnbPlmn:mncLength=3

@{VONR}
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actNonVoNRGbrService=true
...    NRBTS/NRDRB-15:discardTimer=100ms
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-6:lcgid=0
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB_PDCP-3:maxCidAllowed=${EMPTY}
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50
...    NRBTS/NRDRB_RLC_UM-1:rlcUMDrbSNLength=rlcUm12bitSN
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms50
...    NRBTS/NRDRB-16:discardTimer=100ms
...    NRBTS/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=16
...    NRBTS/NRDRB-16:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-16:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nrPdschHRLaDN=${EMPTY}
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_5QI-7:fiveqiValueList=2
...    NRBTS/NRDRB_5QI-7:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=3
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-9:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-9:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_5QI-10:fiveqiValueList=128
...    NRBTS/NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16

@{CDRX}
...    NRCELL:actCDrx=false
...    NRCELL:actCDrxVoNR=false
...    NRBTS/NRDRX-0:drxInactivityTimer=80ms
...    NRBTS/NRDRX-0:drxLongCycle=160ms
...    NRBTS/NRDRX-0:drxOnDurationTimer=10ms
...    NRBTS/NRDRX-0:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-0:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-1:drxInactivityTimer=10ms
...    NRBTS/NRDRX-1:drxLongCycle=40ms
...    NRBTS/NRDRX-1:drxOnDurationTimer=6ms
...    NRBTS/NRDRX-1:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-1:drxRetransTimerUl=0slot

@{NRHOIF}
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=${cell_2_ssbFrequency}
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-2:ssbFrequency=126990
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-1/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-3:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-3:ssbFrequency=${cell_13_ssbFrequency}
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-2/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-2/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=${cell_1_ssbFrequency}
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-2/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

@{mobility}
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
...    NRCELL:a1MeashoEnabled=rsrp
...    NRCELL:a2MeashoEnabled=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=65
...    NRCELL:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480
...    NRCELL:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=0
...    NRCELL:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=65
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
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    delete:XNLINK-1:xnTnlId
...    delete:XNLINK-2:xnTnlId
...    NRADJGNB-2:administrativeState=Unlocked
...    NRADJGNB-2:gNbIdLength=22
...    NRADJGNB-2:gNodeBId=36
...    NRADJGNB-2:xnLinkRef=1
...    NRADJGNB-2:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-2:gnbPlmn:mnc=489|mncLength=3
...    NRADJGNB-1:xnLinkRef=2
...    NRADJNRCELL-1:cellDepType=SA+NSA
...    NRADJNRCELL-1:fiveGsTac=788
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=126990
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3
...    NRCELL/NRREL-6:cellIndividualSsbRsrpOffset=0dB
...    NRCELL/NRREL-6:cellIndividualSsbRsrqOffset=0dB
...    NRCELL/NRREL-6:gNbId=36
...    NRCELL/NRREL-6:gNbIdLength=22
...    NRCELL/NRREL-6:lcrId=1
...    NRCELL/NRREL-6:removeNotAllowed=false
...    NRCELL/NRREL-6:gnbPlmn:mcc=311|mncLength=3
...    NRCELL/NRREL-6:gnbPlmn:mnc=489|mncLength=3
...    delete:NRCELL/NRREL-6:sCellAdditionMethod

@{swap}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRCELL-12:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-12:reportAmountA6MeasSCellSwap=infinity
...    NRCELL-12:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-12:thresholdSCellSwapSourceRsrp=66
...    NRCELL-12:thresholdSCellSwapSourceRsrq=67
...    NRCELL-12:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=6|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-12:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=6|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL-14:a6MeasSCellSwapEnabled=rsrp
...    NRCELL-14:reportAmountA6MeasSCellSwap=r4
...    NRCELL-14:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL-14:thresholdSCellSwapSourceRsrp=66
...    NRCELL-14:thresholdSCellSwapSourceRsrq=67
...    NRCELL-14:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL-14:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480

@{enable_blind_CA}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-5:sCellAdditionMethod=blind

@{enable_DRX_and_A1_based_CA}
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1

@{A1_based_CA_and_actHoOptimizationCa}
...    NRBTS:actHoOptimizationCa=true
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1

@{A1_based_scell_addition_and_TDD_threshold_large_than_FDD}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-13:maxNumOfSCellAlloc=250

@{A1_based_scell_addition_and_FDD_threshold_large_than_TDD}
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=50
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-13:maxNumOfSCellAlloc=1

@{maxNumOfSCellAlloc_to_2_for_cell_13}
...    NRCELL-13:maxNumOfSCellAlloc=2

@{reestablish_SA_enable_and_A1}
...    NRBTS-1:rrcReestabTypeSA=sameGNB
...    NRBTS-1:tWaitingRlRecoverSA=4000ms
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRBTS/NRDU-1:carrierAggregationSupportList=${carrierAggregationSupportList}
...    delete:NRREL-5
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=50
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60

@{blind_CA_maxNumOfSCellAlloc_1}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-1/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12:maxNumOfSCellAlloc=1

@{restore_NRREL_5_And_maxNumOfSCellAlloc}
...    NRCELL-12:maxNumOfSCellAlloc=20
...    @{NRREL}

${a1ThresholdSCellAddSsbRsrpFDD}    50

@{enable_Full_power_mode}
...    NRCELL:actFullPwrMode=true

@{p0_and_alpha_config}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:gNbId=1
...    NRCELL-1/NRREL-4:gNbIdLength=22
...    NRCELL-1/NRREL-4:lcrId=14
...    NRCELL-1/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-4:sCellOperationalMode=dlAndUl
...    NRCELL-1/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-4:sCellPrio=2
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-1:ulPowerControlCommon:alpha=al0
...    NRCELL-2:ulPowerControlCommon:alpha=al0
...    NRCELL-12:ulPowerControlCommon:alpha=al04
...    NRCELL-14:ulPowerControlCommon:alpha=al05
...    NRCELL-11:ulPowerControlCommon:alpha=al06
...    NRCELL-13:ulPowerControlCommon:alpha=al07
...    NRCELL-1:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-2:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-11:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-12:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-13:ulPowerControlCommon:p0UePusch=-3
...    NRCELL-14:ulPowerControlCommon:p0UePusch=-3

${N78DLUL_N66DLUL_N41DLUL}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808F18E7CC31E50B
...    0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878327FE9FFB79F11803DEF5B868
...    3228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878313FE4FF891001B2800028000000542E2080070A000389A000020260200E014404D808301183D003403100D8E7C30140467F00000026007C005638280381F8
...    4800E06000C001F010E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046525E5456065652560A500C1800000180006000050600018000201800060
...    000C060000372982F95415C160AE530509008802783C1E0F078000202020040080802000101002000040100208080300602004000404018000100200400201002040402
...    80301004000202014000080200410500A00E00C01C0280305002006010024010021008050060200400808010023500E0004080C0E364A4E49E0501805200

${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808F18E7CC31E50B
...    0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878327FE9FFB79F11803DEF5B868
...    3228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878313FE4FF891001B2800028000000942E2080070A000388C0000202602A0F0A000389A000000260200E014404D808301183D004405100D8E7C3040001C08630
...    7F00000026007C005638280381F84800E06000C001F010E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046525E5456065652560A500C180000018
...    0006000050600018000201800060000C060000372982F95415C160AE530509008802783C1E0F07800020202004008080100210100200004010020808030060200400040
...    401800010020040020100204040280301004000202014000080200410500A00E00C01C0280305002006010024010021008050060200400808050063500E0004080C0E36
...    4A4E49E0501805200

${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N66DLUL}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808F18E7CC31E50B
...    0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878327FE9FFB79F11803DEF5B868
...    3228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878313FE4FF891001B2800028000000942E2080070A00038820000202602A0F0A000389A000000260200E014404D808301183D004405100D8E7C3040001C08630
...    7F00000026007C005638280381F84800E06000C001F010E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046525E5456065652560A500C180000018
...    0006000050600018000201800060000C060000372982F95415C160AE530509008802783C1E0F07800020202004008080100210100200004010020808030060200400040
...    401800010020040020100204040280301004000202014000080200410500A00E00C01C0280305002006010024010021008050060200400808050063500E0004080C0E36
...    4A4E49E0501805200

${ue_nr_capabilities_VONR_supported_lch-ToSCellRestriction_supported}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E
...    808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16
...    0703878327FE9FFB79F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A0C8
...    A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000541E2080070A00000404C0401C028809B0
...    10602307A006806106C73E1802808CFE0000004C00F800AC70500703F09001C0C0018003E021CB400001C01CB400005C01CB400009C01CB40000DC0
...    1CB400011C0008CA0BCA8AC0CACA4AC14A018300000030000C0000A0C000300004030000C000180C00006E5105F2A82B82C15CA60A12011004F0783
...    C1E0F0000404040080101004000202004000080200410100600C0400800080803000020040080040200408080500602008000404028000100400820
...    A01401C018038050060A00400C0200480200410100A00C04008011A80700020406071B252724F0280C02900

${ue_nr_capabilities_VONR_supported_nosupport_lch-ToSCellRestriction}    SEPARATOR=
...    F9A0700047D0FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E
...    808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA16
...    0703878327FE9FFB79F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A0C8
...    A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000541E2080070A00000404C0401C028809B0
...    10602307A006806106C73E1802808CFE0000004C00F800AC70500703F09001C0C0018003E021CB400001C01CB400005C01CB400009C01CB40000DC0
...    1CB400011C0008CA0BCA8AC0CACA4AC14A018300000030000C0000A0C000300004030000C000180C00006E5105F2A82B82C15CA60A12011004F0783
...    C1E0F0000404040080101004000202004000080200410100600C0400800080803000020040080040200408080500602008000404028000100400820
...    A01401C018038050060A00400C0200480200410100A00C04008011A80700020406071B252724F0280C02900
${ue_nr_capabilities_reestabliment}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C160145B25AA05813E439F
...    40478C73E618F28581C0E1E0A4FF93FE284003650000500000379C10403DEF5B8683228107000003AE0B00A2D92D502C09F21CFA023C639F30C7942
...    C0E070F066F3823007BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E1A0C8A041C00000EB8
...    2C028B64B540B027C873E808F18E7CC31E50B0381C3C149FF27FC508006CA0000A000000950785000184D000004815870500713400000848150788C
...    0018280001048150708C070A000001848100385000001141E230006134000A120561C2301C4D00000C120541E2300071340000384C0561E2300070A
...    00000404C0401C028809B010602308A0194130A74ED8E7C3853A76C73E1C29D3B639F0E14E9DB1CF870276C73E1C29D3B639F0E14E9DB1CF870A74E
...    D8E7C3841B1CF8603C246318C06318C7F00000026007C005638280381F84800E06000C001F010E5A00000E00E5A00002E00E5A00004E00E5A00006E
...    00E5A00008E00046505E54560656525606500C1800000180006000050600018000201800060000C060000372882F95415C0E0AE530509008802783C
...    1E0F0780002020200400808020001010020000401002080803006020040004040180001002004002010020404028030100400020201400008020041
...    0500A00E00C01C02803050020060100240100208080500602004008D40380010203038D9293927814060148

${N78DLUL_N66DLUL_N41DLUL_support_full_power}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C
...    873E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF
...    9863CA160703878327FE9FFB79F11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C280
...    0F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878313FE4FF891001B2800028000000942E2080070A000389
...    A00002026028070A00000004C00700A2026C041808C1E802A028806C73E1C036000000E043183F80000013003E002B1C1401C0FC24007030006
...    000F80872D0000070072D0000170072D0000270072D0000370072D00004700023292F2A2B032B292B0528070C00000030000C0000A0C0043000
...    0400C0003000000300201B94C17CAA0AE0B057298284A044013C1E0F0783C0008A00C0000010000000000000010000000400100010020102020
...    04000080200410100600C0400800080803000020040080040200408080500602008000404028000100400820A01401C018038050060A00400C0
...    200480200420100A00C0400801010020046A01C000810181C6C949C93C0A0300A400

${N41DLUL_N78DLUL_N66DLUL_N71DLUL}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C
...    873E808F18E7CC31E50B0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF
...    9863CA160703878327FE9FFB79C11803DEF5B8683228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0DDE7C2800F7BD6E
...    1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878293FE4FF891001B2800028000000543E1400061340E2080071180
...    0000048100700A2026C041808C1E8026018D3A74E9DB1CF8600A0233F80000013003E002B1C1401C0FC24007030006000F80872D0000070072D
...    0000170072D0000270072D0000370072D00004700023282F2A2B032B292B0528060C000000C000300002830000C000100C0003000060300001B
...    94417CAA0AE070570582848044013C1E0F0783C0001030100200404010000100A010040180308080100002008010404018030100200020200C0
...    000801002001008010202014018080200010100A000040100208280500700600E014018280100300801200801040402803010020046A01C0008
...    10181C6C949C93C0A0300A40

@{PM_Counters_Check_Case5}
...    NRCELL-1:${SUM_SA_UE_FULL_PWR_FR1}>2
${SUM_SA_UE_FULL_PWR_FR1}    M55114C01501

*** Test Cases ***
CB009169-SR-BA-B3_ET_08_01_Intra gNB intra DU HO with UL CA
    [Documentation]
    ...    precondition:
    ...    UE_capabilit:N41A*-N78A*-N66A*
    ...    dlToUlContributionRatio=50, actHoOptimizationCa=true
    ...    scell addition A1 threshold: a1ThresholdSCellAddSsbRsrpFDD=50, a1ThresholdSCellAddSsbRsrpTDD=60
    ...    step1: register UE1 to TDD cell-1 and setup PDU and A1 based scell addition with RSRP120
    ...           scell-1: TDD cell-2 as DLonly scell
    ...           scell-2: FDD cell-13 as DL&UL scell
    ...    step2: UE-1 report A3 trigger inter_frequency HO from TDD cell-1 to TDD cell-2 and optimization CA
    ...           scell-1: TDD cell-1 as DLonly scell
    ...           scell-2: FDD cell-13 as DL&UL scell
    ...    step3: UE-1 report A3 trigger inter_frequency HO from TDD cell-2 to TDD cell-1 and no optimization CA
    ...           due to RSRP(40) for TDD cell-1 from A3 report is low than A1 scelladdiont threshold(50 and 60
    ...    step4: report A1 trigger scell addition with RSRP120
    ...           scell-1: TDD cell-2 as DLonly scell
    ...           scell-2: FDD cell-13 as DL&UL scell
    ...    step5: online change sCellAdditionMethod from covBasedA1 to blind
    ...    step6: register UE2 to TDD cell-1 and setup PDU and blind scell addition
    ...           scell-1: TDD cell-2 as DLonly scell
    ...           scell-2: FDD cell-11 as DL&UL scell
    ...    step7: UE-2 report A3 trigger inter_frequency HO from TDD cell-1 to TDD cell-2 and blind CA
    ...           scell-1: TDD cell-1 as DLonly scell
    ...           scell-2: FDD cell-11 as DL&UL scell
    [Tags]    owner-taotao.hu    CA_LABEL-TTF(60MHz_TDD_n41+80MHz_TDD_n78+30MHz_FDD_n66)
    Online Change And Wait Cell Onair     ${A1_based_CA_and_actHoOptimizationCa}
    UE ICS to TDD cell-1 and trigger scell addition by A1
    A3 report trigger Intra-gNB intra-Freq HO from TDD cell-1 to TDD cell-2 and Optimization CA
    A3 report trigger Intra-gNB intra-Freq HO from TDD cell-2 to TDD cell-1 and no CA
    A1 trigger TDD cell-1 as DL and FDD cell-13 as DLUL scells addition by RSRP 120    log_id=2
    Online Change And Wait Cell Onair     ${enable_blind_CA}
    Ue with specified capabilitiy Register And ICS with Scell Addtion with blind    ue_id=2    ue_capa=${N78DLUL_N66DLUL_N41DLUL}
    A3 report trigger Intra-gNB intra-Freq HO from TDD cell-1 to TDD cell-2 and blind CA
    check rrc log    ${CURDIR}${/}A2A_case08${/}a2a_01.ini

*** Keywords ***
Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=4 5qi=2
    Update Cfg    set_qosflow id=5 5qi=3
    Update Cfg    set_qosflow id=6 5qi=4
    Update Cfg    set_qosflow id=7 5qi=71
    Update Cfg    set_qosflow id=8 5qi=128 qos_flow_type=gbr mfbr_dl=250 mfbr_ul=250 gfbr_dl=120 gfbr_ul=120
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 qos_flows=8,7,6,5,4,3,2,1 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=1-30 amf=1
    Update Cfg    ue_nr_capabilities id=1-30 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on ims_voice_3gpp=on nia=null+zuc nea=null+zuc
    ${Update_Cfg_4}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 ng=10.0.1.123 gnb_id=0x24:22 daemon=10.0.2.1:22222
    ...    xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    Update Cfg    ${Update_Cfg_4}
    Update Cfg    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=136100:126900 gscn=1587
    Update Cfg    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    Update Cfg    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    FOR    ${SA_id}    IN RANGE    1    31
        Update Cfg    set_pdu_gateway id=${SA_id} ue_nat_ip=72.23.0.${SA_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    END

Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Ue with specified capabilitiy Register And Pdu Session Setup At FDD cell-13
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=13
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Ue with specified capabilitiy Register And Pdu Session Setup At FDD cell-11
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Ue with specified capabilitiy Register And Pdu Session Setup At TDD cell-2
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=2
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Send A1 report to trigger Scell Addition with RSRP120
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=rrcReconfigurationComplete

A1 trigger TDD cell-1 as DL and FDD cell-13 as DLUL scells addition by RSRP 120
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:2
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Start BTS With Specified Config Files
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB_CONFIG}

Online Change And Wait Cell Onair
    [Arguments]    ${parameters}
    delta commission parameters    ${parameters}
    Cells Should Be Onair

Release All UEs And Common Test Teardown And Stop Capture Logs
    Release Ues    ue_type=all
    Common Test Teardown And Stop Capture Logs

Ue with specified capabilitiy Register And ICS with Scell Addtion with blind
    [Arguments]    ${ue_id}    ${ue_capa}
    Start rrc log    scell_addition_UE${ue_id}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=scellIdx:1
    Get rrc log

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=5    ${qfi}=2    ${qosflows}=2
    ${expect_output}    Create List
    ...    QoS Routing Table
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=${expect_output}
    [Return]    ${ret1}

UE PDU Session Modify to Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=1    ${qfi}=3    ${qosflows}=3
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    Removed FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_del=${qosflows} by=amf
    ...    pass_regexp=${expect_output}

UE PDU Session Modify to Add and Del
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=2    ${qfi}=4    ${qosflows}=4
    ${ret1}    UE PDU Session Modify to Add    ${ue_id}    ${pdu}    ${fiveQi}    ${qfi}    ${qosflows}
    UE PDU Session Modify to Del    ${ue_id}    ${pdu}    ${fiveQi}    ${qfi}    ${qosflows}
    [Return]    ${ret1}

Scell A2 report to trigger Scell Release
    [Arguments]    ${ue_id}=31    ${carrierfreq}=${Cell2_ssbFrequency}    ${scell_id}=2
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    pass_regexp=${expect_output}
    [Return]    ${ret1}

A2 report for pcell to trigger inter freqency A3
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${cell_1_ssbFrequency}    ${phycell_id}=50
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_MG}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${phycell_id} event=A2
    ...    srsrp_nr=5 srsrq_nr=40
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    eventA1
    ...    eventA3
    ...    measGapConfig
    Execute Egate Command    ${A2_MG}    pass_regexp=${expect_output}

Intra-gNB intra-F HO from TDD cell-1 to TDD cell-2 and Optimization Scell Addition with RSRP 70
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${cell_2_ssbFrequency}    ${Target_phycell_id}=51
    Start RRC Log     Intra_gNB_HO_OptimizationCa_UE${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Intra_gNB_HO_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=120 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=70 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    scellIdx:2
    Get RRC Log

Intra-gNB intra-F HO from TDD cell-1 to TDD cell-2 and blind Scell Addition with RSRP 40
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${cell_2_ssbFrequency}    ${Target_phycell_id}=51
    Start RRC Log     Intra_gNB_HO_blind_CA_UE${ue_id}
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Intra_gNB_HO_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=120 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=40 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    scellIdx:2
    Get RRC Log

Intra-gNB intra-Freq HO with A3 from TDD cell-2 to TDD cell-1 and no scell addition with RSRP 40
    [Arguments]    ${ue_id}=1    ${carrierfreq}=${cell_1_ssbFrequency}    ${Target_phycell_id}=50
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A3
    ${Intra_gNB_HO_OptimizationCa}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=120 srsrq_nr=30
    ...    phycell_id=${Target_phycell_id} nrsrp_nr=40 nrsrq_nr=30
    ${ret1}=    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    fail_regexp=sCellIndex 1
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed

Send A1 report to trigger FDD Scell Addition with RSRP large than FDD threshold
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    FDD_scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    scellIdx:1
    ...    scellIdx:2
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    TDD_scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=55 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report and no scell change trigger with RSRP 120
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    fail_regexp=scellIdx:3

Send A1 report to trigger FDD scell change to TDD with RSRP large than TDD threhold
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_change_to_TDD_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Send A1 report to trigger TDD scell change to FDD with RSRP large than FDD threhold
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_change_to_FDD_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

UE ICS to TDD cell-1 and TDD scell addition by A1
    [Arguments]    ${ue_id}=1
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=${ue_id}
    ...    ue_capa=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N66DLUL}
    Send A1 report to trigger TDD Scell Addition with RSRP large than TDD threshold    ue_id=${ue_id}

UE-2 ICS to FDD cell-11 and no scell change triggered by RSRP 120 for UE-1
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD cell-11    ue_id=2    ue_capa=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL}
    Send A1 report and no scell change trigger with RSRP 120    ue_id=1

Release UE-2 and scel1 change to FDD with RSRP 120 for UE-1
    Release Ues    ue_type=sa    ue_id=2
    Send A1 report to trigger TDD scell change to FDD with RSRP large than FDD threhold    ue_id=1

UE-4 ICS to TDD cell-2 and no scell change triggered by RSRP 120 for UE-3
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD cell-2    ue_id=4    ue_capa=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL}
    Send A1 report and no scell change trigger with RSRP 120    ue_id=3

UE ICS to TDD cell-1 and FDD scells addition by A1
    [Arguments]    ${ue_id}=1
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=${ue_id}
    ...    ue_capa=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL}
    Send A1 report to trigger FDD Scell Addition with RSRP large than FDD threshold    ue_id=${ue_id}

ICS UE-3 to FDD cell-13 and no scell change to TDD by RSRP 120 for UE-1
    Ue with specified capabilitiy Register And Pdu Session Setup At FDD cell-13    ue_id=3    ue_capa=${N41DLUL_N78DL_and_N41DLUL_N66DLUL_N71DLUL}
    Send A1 report to trigger FDD scell change to TDD with RSRP large than TDD threhold    ue_id=1

Release scell-3 for UE-1 and scell change to TDD by RSRP 120 for UE-2
    Scell A2 report to trigger Scell Release    ue_id=1    carrierfreq=${cell_2_ssbFrequency}    scell_id=3
    Send A1 report to trigger FDD scell change to TDD with RSRP large than TDD threhold    ue_id=2

UE ICS to TDD cell-1 and trigger scell addition by A1
    [Arguments]    ${ue_id}=1
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=${ue_id}    ue_capa=${N78DLUL_N66DLUL_N41DLUL}
    A1 trigger TDD cell-1 as DL and FDD cell-13 as DLUL scells addition by RSRP 120    ue_id=${ue_id}

A3 report trigger Intra-gNB intra-Freq HO from TDD cell-1 to TDD cell-2 and Optimization CA
    A2 report for pcell to trigger inter freqency A3
    Intra-gNB intra-F HO from TDD cell-1 to TDD cell-2 and Optimization Scell Addition with RSRP 70

A3 report trigger Intra-gNB intra-Freq HO from TDD cell-2 to TDD cell-1 and no CA
    A2 report for pcell to trigger inter freqency A3    carrierfreq=${cell_2_ssbFrequency}    phycell_id=51
    Intra-gNB intra-Freq HO with A3 from TDD cell-2 to TDD cell-1 and no scell addition with RSRP 40

A3 report trigger Intra-gNB intra-Freq HO from TDD cell-1 to TDD cell-2 and blind CA
    A2 report for pcell to trigger inter freqency A3    ue_id=2
    Intra-gNB intra-F HO from TDD cell-1 to TDD cell-2 and blind Scell Addition with RSRP 40    ue_id=2

UE-1 ICS to TDD cell-1 and FDD DLandUL scell addition by A1
    Start rrc log    DRX_config_for_UL_scell_addition_without_5QI-1
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=1
    ...    ue_capa=${ue_nr_capabilities_VONR_supported_lch-ToSCellRestriction_supported}
    Send A1 report to trigger Scell Addition with RSRP120    ue_id=1
    Get RRC log

DRX Profile2 configured after 5QI-1 call setup
    Start rrc log    DRX_config_after_5QI1_setup
    UE PDU Session Modify to Add    qosflows=2    fiveQi=5    qfi=2
    UE PDU Session Modify to Add    qosflows=3    fiveQi=1    qfi=3
    Get RRC log

DRX Profile1 reconfigured after 5QI-1 call release
    [Arguments]    ${ue_id}=1
    Start rrc log    DRX_config_after_5QI1_release_UE${ue_id}
    UE PDU Session Modify to Del    qosflows=3    fiveQi=1    qfi=3    ue_id=${ue_id}
    Get RRC log

DRX Profile1 not changed after DLandUL scell release
    [Arguments]    ${ue_id}=1
    Start rrc log    DRX_config_after_UL_scell_release_UE${ue_id}
    ${ret1}    Scell A2 report to trigger Scell Release    ue_id=${ue_id}    carrierfreq=${cell_13_ssbFrequency}    scell_id=1
    Should Not Contain    ${ret1}    drx-Config
    Get RRC log

UE-2 ICS to TDD cell-1 and 5QI-1 call setup
    Start rrc log    DRX_config_after_5QI1_setup_without_UL_scell
    Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1    ue_id=2
    ...    ue_capa=${ue_nr_capabilities_VONR_supported_lch-ToSCellRestriction_supported}
    UE PDU Session Modify to Add    qosflows=2    fiveQi=5    qfi=2    ue_id=2
    UE PDU Session Modify to Add    qosflows=3    fiveQi=1    qfi=3    ue_id=2
    Get RRC log

DRX profile2 not changed after DLandUL scell addition
    Start rrc log    DRX_config_after_UL_scell_addition
    Send A1 report to trigger Scell Addition with RSRP120    ue_id=2
    Get RRC log

Ue with specified capabilitiy Register And Pdu Session Setup And No CA At TDD Cell
    [Arguments]    ${ue_id}    ${ue_capa}    ${cell_id}=1
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${expect_output}    Create List
    ...    QoS Routing Table
    ...    a1-Threshold rsrp : ${a1ThresholdSCellAddSsbRsrpFDD}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${expect_output}


Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=scellIdx:1
    [Return]    ${ret}

UE-1 with lch-ToSCellRestriction capabilitiy Register And ICS with Scell Addtion And Check RRC Wireshark Log
    Start rrc log    scell_addition_UE1
    Start To Capture Wireshark Log    scell_addition_UE1
    Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1 And Check allowedServingCells In RRC    ue_id=1
    ...    ue_capa=${ue_nr_capabilities_VONR_supported_lch-ToSCellRestriction_supported}
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_ue1_01.ini    wait_string=UEContextModificationResponse::10
    ...    name=scell_addition_UE1
    Check rrc log    ${CURDIR}${/}A2A_case01${/}a2a_ue1_01.ini

Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1 And Check allowedServingCells In RRC
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${expect_output}    Create List
    ...    scellIdx:1
    ...    allowedServingCells
    ...    uplinkConfigCommon
    ...    physCellId ${Cell_13_FDD_PCI}
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${expect_output}

Add Non GBR QoS Flow And Check RRC Wireshark Log For UE-1
    Start rrc log    non_GBR_5QI5_UE1
    Start To Capture Wireshark Log    non_GBR_5QI5_UE1
    ${ret1}    UE PDU Session Modify to Add    ue_id=1    qosflows=2    fiveQi=5    qfi=2
    Should Not Contain    ${ret1}    allowedServingCells
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_ue1_02.ini    wait_string=UEContextModificationResponse::4
    ...    name=non_GBR_5QI5_UE1
    Get Rrc Log

Add GBR QoS Flow And Check RRC Wireshark Log For UE-1
    Start rrc log    GBR_UE1
    Start To Capture Wireshark Log    GBR_UE1
    UE PDU Session Modify to Add And Check allowedServingCells    ue_id=1    qosflows=3    fiveQi=1    qfi=3
    Multi PDU Modify And Delete For UE-1
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_ue1_03.ini    wait_string=UEContextModificationResponse::36    name=GBR_UE1
    Check rrc log    ${CURDIR}${/}A2A_case01${/}a2a_ue1_03.ini

UE PDU Session Modify to Add And Check allowedServingCells
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=2    ${qfi}=4    ${qosflows}=4
    ${expect_output}    Create List
    ...    QoS Routing Table
    ...    allowedServingCells
    ...    Created FiveQi:Qfi mapping fiveQi ${fiveQi} qfi ${qfi}
    Execute Egate Command
    ...    ue_pdu_session_modify ue=${ue_id} pdu=${pdu} qosflows_to_add=${qosflows} by=amf
    ...    pass_regexp=${expect_output}

Multi PDU Modify And Delete For UE-1
    UE PDU Session Modify to Add and Del And Check allowedServingCells    ue_id=1    qosflows=4    fiveQi=2    qfi=4
    UE PDU Session Modify to Add and Del And Check allowedServingCells    ue_id=1    qosflows=5    fiveQi=3    qfi=4
    UE PDU Session Modify to Add and Del And Check allowedServingCells    ue_id=1    qosflows=7    fiveQi=71    qfi=4
    UE PDU Session Modify to Add and Del And Check allowedServingCells    ue_id=1    qosflows=8    fiveQi=128    qfi=4

UE PDU Session Modify to Add and Del And Check allowedServingCells
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${fiveQi}=2    ${qfi}=4    ${qosflows}=4
    UE PDU Session Modify to Add And Check allowedServingCells    ${ue_id}    ${pdu}    ${fiveQi}    ${qfi}    ${qosflows}
    UE PDU Session Modify to Del    ${ue_id}    ${pdu}    ${fiveQi}    ${qfi}    ${qosflows}

UE-2 with No lch-ToSCellRestriction capabilitiy Register And ICS with Scell Addtion And Check RRC Wireshark Log
    Start rrc log    scell_addition_UE2
    Start To Capture Wireshark Log    scell_addition_UE2
    Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1 And Check No allowedServingCells In RRC    ue_id=2
    ...    ue_capa=${ue_nr_capabilities_VONR_supported_nosupport_lch-ToSCellRestriction}
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_ue2_01.ini    wait_string=UEContextModificationResponse::10
    ...    name=scell_addition_UE2
    Get rrc log

Ue with specified capabilitiy Register And ICS with Scell Addtion At TDD Cell-1 And Check No allowedServingCells In RRC
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${expect_output}    Create List
    ...    scellIdx:1
    ...    uplinkConfigCommon
    ...    physCellId ${Cell_11_FDD_PCI}
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${expect_output}
    Should Not Contain    ${ret}    allowedServingCells

Add Non GBR QoS Flow And Check RRC Wireshark Log For UE-2
    Start rrc log    non_GBR_5QI5_UE2
    Start To Capture Wireshark Log    non_GBR_5QI5_UE2
    ${ret1}    UE PDU Session Modify to Add    ue_id=2    qosflows=2    fiveQi=5    qfi=2
    Should Not Contain    ${ret1}    allowedServingCells
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_ue2_02.ini    wait_string=UEContextModificationResponse::4
    ...    name=non_GBR_5QI5_UE2
    Get Rrc Log

Add GBR QoS Flow And Check RRC Wireshark Log For UE-2
    Start rrc log    GBR_UE2
    Start To Capture Wireshark Log    GBR_UE2
    ${ret1}    UE PDU Session Modify to Add    ue_id=2    qosflows=3    fiveQi=1    qfi=3
    Should Not Contain    ${ret1}    allowedServingCells
    Multi PDU Modify And Delete For UE-2
    Check Wireshark Log    ${CURDIR}${/}A2A_case01${/}a2a_ue2_03.ini    wait_string=UEContextModificationResponse::36    name=GBR_UE2
    Get rrc log

Multi PDU Modify And Delete For UE-2
    ${ret1}    UE PDU Session Modify to Add and Del    ue_id=2    qosflows=4    fiveQi=2    qfi=4
    Should Not Contain    ${ret1}    allowedServingCells
    ${ret1}    UE PDU Session Modify to Add and Del    ue_id=2    qosflows=5    fiveQi=3    qfi=4
    Should Not Contain    ${ret1}    allowedServingCells
    ${ret1}    UE PDU Session Modify to Add and Del    ue_id=2    qosflows=7    fiveQi=71    qfi=4
    Should Not Contain    ${ret1}    allowedServingCells
    ${ret1}    UE PDU Session Modify to Add and Del    ue_id=2    qosflows=8    fiveQi=128    qfi=4
    Should Not Contain    ${ret1}    allowedServingCells

Trigger Scell Addition Via A1 for FDD scell addition
    [Arguments]    ${ue_id}=1    ${scell_pcid}=${Cell_13_FDD_PCI}    ${carrierfreq}=${Cell_1_ssbFrequency}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    uplinkConfigCommon
    ...    pcid:${scell_pcid}, scellIdx:1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=65 ssinr_nr=59 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Should Not Contain    ${ret1}    allowedServingCells

UE Reestablish To Cell
    [Arguments]    ${ue_id}    ${cell_id}
    ${ret}    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}    rrcReconfigurationComplete

UE Reestablish To Cell And Trigger Scell Addition Via A1 for FDD scell addition
    [Arguments]    ${ue_id}=1    ${cell_id}=2    ${scell_pcid}=${Cell12_FDD_PCI}    ${carrierfreq}=${Cell_1_ssbFrequency}
    UE Reestablish To Cell And Check a1 Threshold Config    ${ue_id}    ${cell_id}
    Trigger Scell Addition Via A1 for FDD scell addition    ue_id=${ue_id}    scell_pcid=${scell_pcid}
    ...    carrierfreq=${carrierfreq}

UE Reestablish To Cell And Check a1 Threshold Config
    [Arguments]    ${ue_id}=1    ${cell_id}=2
    ${expect_output}    Create List
    ...    a1-Threshold rsrp : ${a1ThresholdSCellAddSsbRsrpFDD}
    ...    rrcReconfigurationComplete
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=${cell_id}    pass_regexp=${expect_output}

UE Reestablish To Cell1 And Check No Scell Addition With Blind After Reestablish
    UE Reestablish To Cell    ue_id=2    cell_id=1
    UE ICS And Add One Scell WIth Cell12    ue_id=3    ue_capa=${ue_nr_capabilities_reestabliment}

UE ICS And Add One Scell WIth Cell12
    [Arguments]    ${ue_id}    ${ue_capa}
    Start rrc log    scell_addition_UE${ue_id}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${expect_output}    Create List
    ...    scellIdx:1
    ...    physCellId ${Cell_12_FDD_PCI}
    ...    uplinkConfigCommon
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${expect_output}

Release All UEs And Restore NRREL And Common Teardown for Case10
    Online Change And Wait Cell Onair    ${restore_NRREL_5_And_maxNumOfSCellAlloc}
    Release All UEs And Common Test Teardown And Stop Capture Logs

UE Register And Pdu Session Setup At TDD Cell-1 And Check FullPower In RRC
    [Arguments]    ${ue_id}=1    ${ue_capa}=${N78DLUL_N66DLUL_N41DLUL_support_full_power}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${output_expect}    Create List
    ...    QoS Routing Table
    ...    ul-FullPowerTransmission-r16 fullpower
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=${output_expect}

Scell Addition With Cell13 DLandUL And Cell2 DL And Check No FullPower In RRC
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${output_expect}    Create List
    ...    scellIdx:1
    ...    scellIdx:2
    ...    rrcReconfigurationComplete
    ...    uplinkConfigCommon
    ${ret}    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${output_expect}
    Should Not Contain    ${ret}    fullpower

Scell Release For Scell And Check No FullPower In RRC
    [Arguments]    ${carrierfreq}=${cell_2_ssbFrequency}    ${scell_id}=1    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    ${expect_output}
    Should Not Contain    ${ret1}    fullpower

Scell Release For Scell And Check FullPower In RRC
    [Arguments]    ${carrierfreq}=${cell_13_ssbFrequency}    ${scell_id}=2    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ...    ul-FullPowerTransmission-r16 fullpower
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    Execute Egate Command    ${A2_Scell_Release}    ${expect_output}

Send A1 report to trigger Scell Addition with RSRP120 and check CA and alpha
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}
    Start rrc log    scell_add_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_12_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    ...    frequencyInfoUL:::1
    ...    alpha alpha04:::1
    ...    p0 0:::1
    ${ret1}=    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=70 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}
    Get RRC log

Trigger UL scell swap from FDD cell-12 to cell-14 for 4CC and check P0 and alpha
    [Arguments]    ${ue_id}    ${scell_id}    ${scell_phy_id}
    Start rrc log    scell_swap_UE${ue_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_12_ssbFrequency}    event_type=A6
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_14_FDD_PCI}, scellIdx:4
    ...    frequencyInfoUL
    ...    alpha alpha05:::1
    ...    p0 0:::1
    ...    sCellToReleaseList
    ${V_1}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A6 srsrp_nr=11 srsrq_nr=11 scell=${scell_id}
    ...    scell_rsrp=20 scell_rsrq=20 phycell_id=${scell_phy_id} nrsrp_nr=63 nrsrq_nr=20
    ${ret1}=    Execute Egate Command    ${V_1}    pass_regexp=${expect_output}
    Get RRC log

Scell A2 report to trigger UL scell release and check P0 and alpha not changed
    [Arguments]    ${ue_id}=31    ${carrierfreq}=${Cell2_ssbFrequency}    ${scell_id}=2
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A2
    ${A2_Scell_Release}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} scell=${scell_id} scell_rsrp=20 scell_rsrq=0 event=A2
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    sCellToReleaseList
    ${ret1}=    Execute Egate Command    ${A2_Scell_Release}    ${expect_output}
    Should not Contain    ${ret1}    P0-PUSCH-AlphaSe
