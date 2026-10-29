*** Settings ***
Documentation
...    author: lishuo.geng
Suite Setup       Start BTS With Specified Config Files
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Release All UEs And Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_FDD    CLOUD_5G_I_BOO_AP_LOO
...    team-CN3ET    owner-taotao.hu    owner-lishuo.geng    release-SBTS23R3    CB009169    CRT    AP_REG
Resource    ../../../../../resources/DevHZ5_resource.robot


*** Variables ***
#${SYSCOM_FLAG}    True
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

${Cell_1_TDD_PCI}    50
${Cell_2_TDD_PCI}    51
${Cell_11_FDD_PCI}    60
${Cell_12_FDD_PCI}    61
${Cell_13_FDD_PCI}    62
${Cell_14_FDD_PCI}    63
${cell_13_ssbFrequency}    430830
${cell_11_ssbFrequency}    423850
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
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:lcrId=2
...    NRCELL-13/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:lcrId=11
...    NRCELL-13/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-13/NRREL-4:gNbId=1
...    NRCELL-13/NRREL-4:gNbIdLength=22
...    NRCELL-13/NRREL-4:lcrId=12
...    NRCELL-13/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-13/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-13/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-4:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3

...    NRCELL-11/NRREL-4:gNbId=1
...    NRCELL-11/NRREL-4:gNbIdLength=22
...    NRCELL-11/NRREL-4:lcrId=13
...    NRCELL-11/NRREL-4:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-4:gnbPlmn:mncLength=3

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
#...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
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
#...    NRBTS/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nrPdschHRLaDN=${EMPTY}
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:cellAggrLevel=Not FR1 CA eligible
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
...    NRCELL-13/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-1:ssbFrequency=${cell_2_ssbFrequency}
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-13/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-2:ssbFrequency=${cell_1_ssbFrequency}
...    NRCELL-13/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-3:ssbFrequency=${cell_12_ssbFrequency}
...    NRCELL-13/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-13/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-13/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-13/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-13/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-13/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-13/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-13/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-13/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-13/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-13/NRHOIF-4:ssbFrequency=${cell_11_ssbFrequency}
...    NRCELL-13/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-13/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-13/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-13/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=${cell_2_ssbFrequency}
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-1:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-2:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-2:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-2:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-2:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-2:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-2:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-2:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-2:ssbFrequency=${cell_1_ssbFrequency}
...    NRCELL-11/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-3:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-3:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-3:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-3:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-3:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-3:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-3:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-3:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-3:ssbFrequency=${cell_12_ssbFrequency}
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-3:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-3:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

...    NRCELL-11/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-11/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-11/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-11/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-11/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-4:ssbFrequency=${cell_13_ssbFrequency}
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-11/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-11/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-11/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

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

#...    NRCELL-1/NRHOIF-2:a1BasedPCellSwitchEnabled=true
#...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchEnabled=true
#...    NRCELL-1/NRHOIF-2:a2BasedPCellSwitchPriority=1
#...    NRCELL-1/NRHOIF-2:a3MeasEnabled=rsrp
#...    NRCELL-1/NRHOIF-2:cellDepType=SA+NSA
#...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=71
#...    NRCELL-1/NRHOIF-2:ifhoSsbScs=15KHz
#...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf5
#...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf20
#...    NRCELL-1/NRHOIF-2:ssBurstSetPeriod=20
#...    NRCELL-1/NRHOIF-2:ssbFrequency=126990
#...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrp=60
#...    NRCELL-1/NRHOIF-2:thresholdPCellSwitchTargetRsrq=20
#...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
#...    NRCELL-1/NRHOIF-2:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

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

...    NRCELL-1/NRHOIF-4:a1BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-4:a2BasedPCellSwitchEnabled=true
...    NRCELL-1/NRHOIF-4:a2BasedPCellSwitchPriority=1
...    NRCELL-1/NRHOIF-4:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-4:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-4:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-4:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-4:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-4:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-4:ssbFrequency=${cell_11_ssbFrequency}
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrp=60
...    NRCELL-1/NRHOIF-4:thresholdPCellSwitchTargetRsrq=20
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1/NRHOIF-4:a3MeasSsbRsrp:a3OffsetSsbRsrp=5

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
...    NRCELL-2/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-2/NRREL-5:sCellAdditionMethod=blind

@{A1_based_CA_and_actHoOptimizationCa}
...    NRBTS:actHoOptimizationCa=true
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-5:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-4:sCellAdditionMethod=covBasedA1


${N78DLUL_N66DLUL_N41DLUL}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC32001A0349CF9A44F3E0048018807C07C0203F1C03EF3E26807BDEB70D0645020E0000075C12028B64B540B027C873E808F18E7CC31E50B
...    0381C3C149FF27FC48800D940001400000DE7C4100F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA160703878327FE9FFB79F11803DEF5B868
...    3228107000003AE090145B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FFDE7C2800F7BD6E1A0C8A041C00000EB8240516C96A81604F90E7D011E31CF9863CA
...    160703878313FE4FF891001B2800028000000542E2080070A000389A000020260200E014404D808301183D003403100D8E7C30140467F00000026007C005638280381F8
...    4800E06000C001F010E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00046525E5456065652560A500C1800000180006000050600018000201800060
...    000C060000372982F95415C160AE530509008802783C1E0F078000202020040080802000101002000040100208080300602004000404018000100200400201002040402
...    80301004000202014000080200410500A00E00C01C0280305002006010024010021008050060200400808010023500E0004080C0E364A4E49E0501805200

${N41DLUL_N78DLUL_N66DLUL_N66DLUL_N71DLUL}    SEPARATOR=
...    F9A0700047D4FFA17DF8E6BC2A003406939F3489E7C007006201F01F0080FC7013BCF89A01EF7ADC341914083800001D703814
...    5B25AA05813E439F40478C73E618F28581C0E1E0A4FF93FE1C401B280002800001BCF88201EF7ADC341914083800001D703814
...    5B25AA05813E439F40478C73E618F28581C0E1E0C9FFA7FEDE704600F7BD6E1A0C8A041C00000EB81C0A2D92D502C09F21CFA0
...    23C639F30C7942C0E070F06EF3E14007BDEB70D0645020E0000075C0E0516C96A81604F90E7D011E31CF9863CA160703878293
...    FE4FF871006CA0000A000006F3E20807BDEB70D0645020E0000075C0E0516C96A81604F90E7D011E31CF9863CA160703878327
...    FE9FF80A89C28000E26800710400388C001C410000001204024028809B010602340410B4054032274E9D3A76C73E180140467F
...    00000026007C005638280381F84800E06000C001F014E5A00000E00E5A00002E00E5A00004E00E5A00006E00E5A00008E00E5A
...    0000AE00056505E5256025652560A560650101800000180006000050600018000201800060000C0600018000400000011CA20B
...    E530570182B82C15C0E0A12011004F0783C1E0F000041004008010100400804028040100600C04030050808030000200801040
...    4018030100200020200C0000801002001008010202014018080200010100A000040100208280500700600E0140182801003008
...    01200801040402803010020046A01C000810181C6C949C93C0A0300A40
@{PM_Counters_Check_Case5}
...    NRCELL-1:${SUM_SA_UE_FULL_PWR_FR1}>2
${SUM_SA_UE_FULL_PWR_FR1}    M55114C01501

@{PcellChangeTo_Cell-13_expect}
...    Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.13 performed
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:60, scellIdx:3
...    pcid:62, scellIdx:0

@{ScellChangeTo_TDD_Cell_expect}
...    pcid:50, scellIdx:1
...    pcid:51, scellIdx:2
...    pcid:62, scellIdx:0
...    rrcReconfigurationComplete

@{PcellChangeTo_Cell-1_expect}
...    Intra-eNB handover from EXT_ENB-2.13 to EXT_ENB-2.1 performed
...    pcid:62, scellIdx:3
...    pcid:60, scellIdx:2
...    pcid:50, scellIdx:0
...    pcid:51, scellIdx:1

*** Test Cases ***
CB009169-SR-BA-B3_ET_08_01_Intra gNB intra DU HO with UL CA
    [Documentation]
    ...    precondition:
    ...    ${cell_1_ssbFrequency}    518430  TDD  band41 PCI:50  60M  PCELL  30khz   (16385)
    ...    ${cell_2_ssbFrequency}    636576  TDD  band78 PCI:51  80M   30khz  (16386)
    ...    ${cell_11_ssbFrequency}   423850  FDD  band66 PCI:60  20M   scell   15khz (16395)
    ...    ${cell_12_ssbFrequency}   126990  FDD  band71 PCI:61  30M    15khz (16396)
    ...    ${cell_13_ssbFrequency}   430830  FDD  band66 PCI:62  10M   scell  15khz  (16397)
    ...    ${cell_14_ssbFrequency}   126990  FDD  band71 PCI:63  10M   15khz    (16398)
    ...    CELL1: TDD PCI=50 band41 PCELL NRREL-1:CELL11,blind_dlAndUl; NRREL-2:CELL12;NRREL-3:CELL13;NRREL-5:CELL2-DlOnly;NRREL-6:GNB36 CELL-1
    ...    NRHOIF-1:CELL2-636576; NRHOIF-2:CELL14-126990; NRHOIF-3:CELL13-430830
    ...    CELL2: TDD PCI=51 band78 NRREL-1:CELL11;NRREL-2:CELL12;NRREL-3:CELL13;NRREL-5:CELL1-DlOnly;NRREL-6:GNB36CELL-1 NRHOIF-1:CELL1-518430
    ...    CELL11: FDD PCI=60 band66 NRREL-6:CELL1
    ...    CELL12: FDD PCI=61 band71 NRREL-6:CELL1
    ...    CELL13: FDD PCI=62 band66 NRREL-6:CELL1
    ...    CELL14: FDD PCI=63 band71 NRREL-6:CELL1
    ...    UE_capabilit:N41A*-N78A*-N66A*
    ...    dlToUlContributionRatio=50, actHoOptimizationCa=true
    ...    scell addition A1 threshold: a1ThresholdSCellAddSsbRsrpFDD=50, a1ThresholdSCellAddSsbRsrpTDD=60
    ...    step1: register UE1 to FDD cell-11 and setup PDU and A1 based scell addition with RSRP120
    ...           scell-1: TDD cell-1 as DLonly scell
    ...           scell-2: TDD cell-2 as DLonly scell
    ...           scell-3: FDD cell-3 as DL&UL scell
    ...    step2: A1 Pcell Change To F13,CA_F13_T1T2F11
    ...    step3: A2 Trigger Scell Stepwise Release All TDD SCell, left CA_F13_F11
    ...    step4. A1 Scell Change From F11 To TDD Cell,CA_F13_T1T2
    ...    step5. A1 Pcell Change From FDD Cell-13 To TDD Cell-1,CA_T1_T2F11F13
    ...    step6: UE-1 report A3 trigger inter_frequency HO from TDD cell-1 to TDD cell-2 and optimization CA
    ...           scell-1: TDD cell-1 as DLonly scell
    ...           scell-2: FDD cell-11 as DL&UL scell
    ...           scell-3: FDD cell-13 as DL&UL scell
    ...    step7: UE-1 report A3 trigger inter_frequency HO from TDD cell-2 to TDD cell-1 and no optimization CA
    ...           due to RSRP(40) for TDD cell-1 from A3 report is low than A1 scelladdiont threshold(50 and 60
    ...    step8: report A1 trigger scell addition with RSRP120
    ...           scell-1: TDD cell-2 as DLonly scell
    ...           scell-2: FDD cell-11 as DL&UL scell
    ...           scell-3: FDD cell-13 as DL&UL scell
    ...    step9: online change sCellAdditionMethod from covBasedA1 to blind
    ...    step10: register UE2 to TDD cell-1 and setup PDU and blind scell addition
    ...           scell-1: TDD cell-2 as DLonly scell
    ...           scell-2: FDD cell-13 as DL&UL scell
    ...    step11: UE-2 report A3 trigger inter_frequency HO from TDD cell-1 to TDD cell-2 and blind CA
    ...           scell-1: TDD cell-1 as DLonly scell
    ...           scell-2: FDD cell-13 as DL&UL scell
    [Tags]    owner-taotao.hu    CA_LABEL-TTF(60MHz_TDD_n41+80MHz_TDD_n78+30MHz_FDD_n66)
    Online Change And Wait Cell Onair     ${A1_based_CA_and_actHoOptimizationCa}
    UE ICS to FDD cell-11 and trigger scell addition by A1
    Trigger PCell change From FDD Cell-11 to FDD Cell-13    ue_id=1    cellfreq=${cell_13_ssbFrequency}
    ...    pass_regexp=${PcellChangeTo_Cell-13_expect}
    Trigger Scell Stepwise Release All TDD SCell
    Trigger Scell Change From FDD Cell-11 To TDD Cell    scell_index=3    cellfreq=${cell_13_ssbFrequency}
    ...    pass_regexp=${ScellChangeTo_TDD_Cell_expect}
    Trigger Pcell Change From FDD Cell-13 To TDD Cell-1    scell_index=1    cellfreq=${cell_1_ssbFrequency}
    ...    pass_regexp=${PcellChangeTo_Cell-1_expect}
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

Send And Verify Throughput
    [Arguments]    ${ue_id}=1
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=2 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=3 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=4 mbps=150    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=6 mbps=10    UE ${ue_id}: UDP UL
    Verify Throughput

Verify Throughput When 3 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=4
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch

Verify Throughput When 2 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=3
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch

Throughput Check
    [Arguments]    ${ue_id}=1    ${pdu}=1    ${qfi}=1    ${Tput_dl}=10    ${Tput_ul}=1    ${sleep_time}=15s    ${CC_num}=4
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${ret0}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    pass_regexp=Average
    ${alldl_tput}    set variable    0
    FOR    ${id}    IN RANGE    0    ${CC_num}
        ${id}=    convert to string    ${id}
        ${cell_tput}    Scell Throughput Check    ${ue_id}    ${id}
        ${alldl_tput}    Evaluate    ${alldl_tput}+${cell_tput}
    END
    Should Be True    ${alldl_tput}/1000 > ${Tput_dl}

Scell Throughput Check
    [Arguments]    ${ue_id}=1    ${scell_id}=0
    [Return]    ${scell_tput}
    ${scell_tput}    Ap Get Throuput On Specific Scell     ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    #Should Be True    ${scell_tput}/1000 > 0

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=40    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Trigger Scell Stepwise Release All TDD SCell
    Trigger Scell Stepwise Release    scell_index=1    cellfreq=${cell_1_ssbFrequency}
    Trigger Scell Stepwise Release    scell_index=2    cellfreq=${cell_2_ssbFrequency}

Trigger Scell Change From FDD Cell-11 To TDD Cell
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${ret}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 scell=${scell_index} srsrp_nr=120 srsrq_nr=120
    ...    pass_regexp=${pass_regexp}
    Verify Throughput When 2 Scells    ue_id=${ue_id}    Tput_dl=540

Trigger Pcell Change From FDD Cell-13 To TDD Cell-1
    [Arguments]    ${scell_index}    ${cellfreq}    ${pass_regexp}=None    ${ue_id}=1    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} event=A1 meas_id=${measid} srsrp_nr=11 srsrq_nr=11 scell=${scell_index}
    ...    scell_rsrp=127 scell_rsrq=127
    ${ret5}=    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}
    Verify Throughput When 3 Scells    ue_id=1    Tput_dl=540
    Get RRC log


Trigger Scell Stepwise Release
    [Arguments]    ${scell_index}    ${cellfreq}    ${ue_id}=1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A2
    ${ret3}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A2 scell=${scell_index} scell_rsrp=34
    ...    pass_regexp=rrcReconfigurationComplete
    ${ret1}=    Remove String    ${ret3}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToReleaseList{${scell_index}}

Ue with specified capabilitiy Registe And Pdu Session Setup At FDD Cell11
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Ue with specified capabilitiy Register And Pdu Session Setup At TDD Cell-1
    [Arguments]    ${ue_id}    ${ue_capa}
    Execute Egate Command    ue_location_change id=${ue_id} enb=2 cell=1
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_capa}    pass_regexp=UE now in NG RM Registere
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=${ue_id} nwslice=1    pass_regexp=QoS Routing Table

Trigger PCell change to CELL1
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_regexp}=None
    Start RRC Log     pcell_change_F11_to_T1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${A1_Pcell_change_F_To_T}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=11 srsrq_nr=11 scell=1
    ...    scell_rsrp=121 scell_rsrq=121
    ${ret}=    Execute Egate Command    ${A1_Pcell_change_F_To_T}    pass_regexp=${pass_regexp}
    Verify Throughput When 3 Scells    ue_id=1   Tput_dl=540

Trigger PCell change From FDD Cell-11 to FDD Cell-13
    [Arguments]    ${ue_id}    ${cellfreq}    ${pass_regexp}=None
    Start RRC Log     pcell_change_F11_to_T1
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cellfreq}    event_type=A1
    ${A1_Pcell_change_F_To_F}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=11 srsrq_nr=11 scell=3
    ...    scell_rsrp=121 scell_rsrq=121
    ${ret}=    Execute Egate Command    ${A1_Pcell_change_F_To_F}    pass_regexp=${pass_regexp}
    Verify Throughput When 3 Scells    ue_id=${ue_id}    Tput_dl=540

Verify Throughput When 4 Scells
    [Arguments]    ${ue_id}=1    ${Tput_dl}=10    ${Tput_ul}=9    ${CC_num}=5
    Throughput Check    ue_id=${ue_id}    Tput_dl=${Tput_dl}    Tput_ul=${Tput_ul}    CC_num=${CC_num}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-8 type=pdsch    pass_regexp=CellIndex-3

A1 trigger FDD cell-11 as PCELL and FDD cell-13 as DLUL scells addition by RSRP 120
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_11_ssbFrequency}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:1
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:2
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${measid} event=A1 srsrp_nr=120 ssinr_nr=120 srsrq_nr=32
    ...    pass_regexp=${expect_output}

A1 trigger TDD cell-1 as DL and FDD cell-13 as DLUL scells addition by RSRP 120
    [Arguments]    ${ue_id}=1    ${cell_freq}=${cell_1_ssbFrequency}    ${log_id}=1
    Start rrc log    scell_addition_UE${ue_id}_${log_id}
    ${measid}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=${ue_id}    carrierfreq=${cell_freq}    event_type=A1
    ${expect_output}    Create List
    ...    rrcReconfigurationComplete
    ...    pcid:${Cell_13_FDD_PCI}, scellIdx:3
    ...    pcid:${Cell_11_FDD_PCI}, scellIdx:2
    ...    pcid:${Cell_1_TDD_PCI}, scellIdx:0
    ...    pcid:${Cell_2_TDD_PCI}, scellIdx:1
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
    ${ret1}=    Execute Egate Command    ${Intra_gNB_HO_OptimizationCa}    scellIdx:3
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

UE ICS to FDD cell-11 and trigger scell addition by A1
    [Arguments]    ${ue_id}=1
    Ue with specified capabilitiy Registe And Pdu Session Setup At FDD Cell11    ue_id=${ue_id}    ue_capa=${N41DLUL_N78DLUL_N66DLUL_N66DLUL_N71DLUL}
    Send And Verify Throughput
    A1 trigger FDD cell-11 as PCELL and FDD cell-13 as DLUL scells addition by RSRP 120   ue_id=${ue_id}

A3 report trigger Intra-gNB intra-Freq HO from TDD cell-1 to TDD cell-2 and Optimization CA
    A2 report for pcell to trigger inter freqency A3
    Intra-gNB intra-F HO from TDD cell-1 to TDD cell-2 and Optimization Scell Addition with RSRP 70

A3 report trigger Intra-gNB intra-Freq HO from TDD cell-2 to TDD cell-1 and no CA
    A2 report for pcell to trigger inter freqency A3    carrierfreq=${cell_2_ssbFrequency}    phycell_id=51
    Intra-gNB intra-Freq HO with A3 from TDD cell-2 to TDD cell-1 and no scell addition with RSRP 40

A3 report trigger Intra-gNB intra-Freq HO from TDD cell-1 to TDD cell-2 and blind CA
    A2 report for pcell to trigger inter freqency A3    ue_id=2
    Intra-gNB intra-F HO from TDD cell-1 to TDD cell-2 and blind Scell Addition with RSRP 40    ue_id=2


