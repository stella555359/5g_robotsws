*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    owner-lena.zhuo
...    CLOUD_5G_I_BLLL_AP_LOO    CRT    CB005935
...    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}
${GNB_BIP_FLAG}    ${True}
${TTITRACE_FLAG}    ${True}
${SNAPSHOT_FLAG}    pass:False,fail:True
${EMIL_FLAG}    ${True}
${SOS_REPORT_FLAG}    pass:False,fail:True
${BTS_STARTUP_RETRY}    0

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRBTS:actHighestEstNrTputBcSel=true
...    NRCELL-12:gscnOrSsPbchArfcn=1587
...    NRCELL-12:type0CoresetConfigurationIndex=2
...    NRCELL-12/NRCELL_FDD-1:chBwDl=5MHz
...    NRCELL-12/NRCELL_FDD-1:chBwUl=5MHz
...    NRCELL-12/NRCELL_FDD-1:nrarfcnUl=135100
...    NRCELL-13/NRCELL_FDD-1:chBwUl=10MHz
...    NRCELL-14:gscnOrSsPbchArfcn=4864
...    NRCELL-14/NRCELL_FDD-1:chBwDl=5MHz
...    NRCELL-14/NRCELL_FDD-1:chBwUl=5MHz
...    NRBTS/NRDU-1:fr1UlCaPreferred=dataRatePreferred
...    NRCELL:pMaxNROwnCell=22
...    NRCELL:actK1Opt=intra-gNB
...    NRBTS/BWP_PROFILE-4/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=84
...    @{CA_related}
...    @{GBR_related}

@{CA_related}
...    NRBTS:actBcsCheck=disabled
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL-11:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-11:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-12:a1MeasSCellAddEnabled=rsrp
...    NRCELL-12:a2MeasSCellRelEnabled=rsrp
...    NRCELL-12:actK1Opt=intra-gNB
...    NRCELL-13:actK1Opt=intra-gNB
...    NRCELL-14:actK1Opt=intra-gNB
...    NRCELL-12:increaseK1ULCA=K1 increased by 1 slot
...    NRCELL-12:timingAdvanceOffset=n0
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90
...    NRCELL-12:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=40ms
...    NRCELL-13:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-13:a2MeasSCellRelEnabled=rsrp
...    NRCELL-14:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-14:a2MeasSCellRelEnabled=rsrp
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=200
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=200
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:actInterNumerologyCa=true
...    NRBTS/NRDU-1:dlToUlContributionRatio=80
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CAlist}
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-1-And-1-1
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:coresetId=0|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceId=5|dciFormat=formats0-0-And-1-0
...    NRBTS/BWP_PROFILE-2/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:searchSpaceDedicated:searchSpaceType=Type3|dciFormat=formats0-0-And-1-0
...    @{NRREL}
...    @{NRHOIF}
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:maxNumScellsDlFr1=5
${CAlist}    ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Sa_WithUl,ca_Fdd_Fdd,ca_Fdd_Fdd_Sa_WithUl,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,
...    ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa


@{NRREL}
...    NRCELL-12/NRREL-13:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-12/NRREL-13:gNbId=1
...    NRCELL-12/NRREL-13:lcrId=13
...    NRCELL-12/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-13:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-14:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-12/NRREL-14:gNbId=1
...    NRCELL-12/NRREL-14:lcrId=14
...    NRCELL-12/NRREL-14:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-14:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-14:gnbPlmn:mncLength=3

@{NRHOIF}
...    NRCELL-12/NRHOIF-13:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-13:cellDepType=SA
...    NRCELL-12/NRHOIF-13:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-13:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-13:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-13:ssbFrequency=427970
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrp:a4ThresholdNrDcSsbRsrp=43
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrp:a4TimeToTriggerNrDcSsbRsrp=ms100
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrq:a4ThresholdNrDcSsbRsrq=49
...    NRCELL-12/NRHOIF-13:a4MeasNrDcSsbRsrq:a4TimeToTriggerNrDcSsbRsrq=ms100
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=34
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms40
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4ThresholdSCellAddSsbRsrq=49
...    NRCELL-12/NRHOIF-13:a4MeasSCellAddSsbRsrq:a4TimeToTriggerSCellAddSsbRsrq=ms40
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-13:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-12/NRHOIF-14:a1BasedPCellSwitchEnabled=true
...    NRCELL-12/NRHOIF-14:cellDepType=SA
...    NRCELL-12/NRHOIF-14:deriveSsbIndexFromCell=true
...    NRCELL-12/NRHOIF-14:freqBandIndicatorNR=25
...    NRCELL-12/NRHOIF-14:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-14:ssbFrequency=388850
...    NRCELL-12/NRHOIF-14:a4MeasNrDcSsbRsrp:a4HysteresisNrDcSsbRsrp=0
...    NRCELL-12/NRHOIF-14:a4MeasNrDcSsbRsrp:a4ThresholdNrDcSsbRsrp=43
...    NRCELL-12/NRHOIF-14:a4MeasNrDcSsbRsrp:a4TimeToTriggerNrDcSsbRsrp=ms100
...    NRCELL-12/NRHOIF-14:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-12/NRHOIF-14:a4MeasNrDcSsbRsrq:a4ThresholdNrDcSsbRsrq=49
...    NRCELL-12/NRHOIF-14:a4MeasNrDcSsbRsrq:a4TimeToTriggerNrDcSsbRsrq=ms100
...    NRCELL-12/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4HysteresisSCellAddSsbRsrp=0
...    NRCELL-12/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4ThresholdSCellAddSsbRsrp=34
...    NRCELL-12/NRHOIF-14:a4MeasSCellAddSsbRsrp:a4TimeToTriggerSCellAddSsbRsrp=ms40
...    NRCELL-12/NRHOIF-14:a4MeasSCellAddSsbRsrq:a4HysteresisSCellAddSsbRsrq=0
...    NRCELL-12/NRHOIF-14:a4MeasSCellAddSsbRsrq:a4ThresholdSCellAddSsbRsrq=49
...    NRCELL-12/NRHOIF-14:a4MeasSCellAddSsbRsrq:a4TimeToTriggerSCellAddSsbRsrq=ms40
...    NRCELL-12/NRHOIF-14:a4MeasSsbRsrp:a4HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-14:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0

@{VONR_related}
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actVoNR=true
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-12:rlcMode=RLC_UM
...    NRBTS/NRDRB-12:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:discardTimer=500ms
...    NRBTS/NRDRB-15:discardTimerUl=infinity
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:maxDataRateGbrDl=10000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=10000
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-15:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-15:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB-16:discardTimer=500ms
...    NRBTS/NRDRB-16:discardTimerUl=infinity
...    NRBTS/NRDRB-16:dlFlowControlAlgo=none
...    NRBTS/NRDRB-16:l2OHFactorDl=16
...    NRBTS/NRDRB-16:l2OHFactorUl=16
...    NRBTS/NRDRB-16:maxDataRateGbrDl=10000
...    NRBTS/NRDRB-16:maxDataRateGbrUl=10000
...    NRBTS/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-3
...    NRBTS/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-16:resType=GBR
...    NRBTS/NRDRB-16:rlcMode=RLC_UM
...    NRBTS/NRDRB-16:schedulWeight=1
...    NRBTS/NRDRB-16:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-16:nrDrbRlcAmDN=${EMPTY}
...    NRBTS/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS/NRDRB_5QI-10:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-10:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB_5QI-11:fiveqiValueList=4
...    NRBTS/NRDRB_5QI-11:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS/NRDRB_MAC-3:lcgid=0
...    NRBTS/NRDRB_MAC-3:schedulBSD=${EMPTY}
...    NRBTS/NRDRB_MAC-4:lcgid=4
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:schedulBSD=100ms
...    NRBTS/NRDRB_PDCP-3:cuFlowControlProfId=1
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms50

@{GBR_related}
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRCELL:actNonVoNRGbrService=true
...    @{VONR_related}

@{OnlineParamChange_AA03}
...    NRBTS/NRDU-1:fr1UlCaPreferred=ulCaPreferred

@{recovery_AA03}
...    NRBTS/NRDU-1:fr1UlCaPreferred=dataRatePreferred

@{OnlineParamChange_AC01}
...    NRCELL-12/NRREL-1:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:lcrId=2

@{recovery_AC01}
...    delete:NRCELL-12/NRREL-1

@{pass_with_lch-ToScellRestriction}
...    allowedServingCells
...    QoS Routing Table

@{allowedServing}
...    allowedServingCells

@{OnlineParamChange_AB02}
...    NRCELL-2:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL-2:a2MeasSCellRelEnabled=rsrp
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-2:increasePUSCHPrepTimeULCA=true
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=110|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRBTS/NRDU-1:dlToUlContributionRatio=50
...    NRCELL-12/NRREL-2:actA4ToA1BasedSCellFallbackNsa=false
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlAndUl
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-2:weightForSCellSelection=1
...    NRCELL-13:weightForSCellSelection=100
...    NRCELL-14:weightForSCellSelection=100
...    NRBTS/NRDU-1:fr1UlCaPreferred=dataRatePreferred
...    MRBTS-1/MNL-1/AMGR-1/LUAC-1:webEMSessionLogoutTimer=7200

@{recovery_AB02}
...    delete:NRCELL:timingAdvanceOffset=n25600
...    NRCELL-2:increasePUSCHPrepTimeULCA=false
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRBTS/NRDU-1:dlToUlContributionRatio=80
...    delete:NRCELL-12/NRREL-2
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRBTS/NRDU-1:fr1UlCaPreferred=dataRatePreferred

@{AB02_scell_1_pass}
...    pcid:61, scellIdx:0] configure_0_1
...    pcid:61, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:2] configure_1_1
...    pcid:63, scellIdx:3] configure_1_1

@{AB02_scell_1_fail}
...    pcid:62, scellIdx:2] configure_0_1
...    pcid:63, scellIdx:3] configure_0_1

@{AB02_scell_2_pass}
...    pcid:61, scellIdx:0] configure_0_1
...    pcid:61, scellIdx:0] configure_1_1
...    pcid:62, scellIdx:2] configure_0_1
...    pcid:62, scellIdx:2] configure_1_1
...    pcid:63, scellIdx:3] configure_1_1

@{AB02_scell_2_fail}
...    pcid:63, scellIdx:3] configure_0_1

@{AA03_no_ulscell}
...    pcid:62, scellIdx:1] configure_0_1

@{AA03_ulscell}
...    pcid:62, scellIdx:1] configure_0_1
...    pcid:62, scellIdx:1] configure_1_1
...    pcid:61, scellIdx:0] configure_1_1
...    pcid:61, scellIdx:0] configure_0_1

#3CC: n71A-n25A-n66A, BC1#3FS;
#2CC: n71A-n66A, BC2#2FS;
${FF_ULCA_Support_AA03_UE2}    SEPARATOR=
...     FFA0F200475F7A6B5F83820960006800B8002002024107CC020248170031FFF800140F80C0301C04A87E146FCC0D0A82296595103C017BFF30
...     39036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE31400028015B
...     300078003300078000150FC41DF981A150452CB2A207802F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7
...     FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F005EFFCC0E40DBFFE
...     DFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8C50000A0056CC001E000
...     CC001E0000541F0637E606854114B2CA881E00BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7
...     FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82296595103C016BFF3039036FFFB7FFDBFFE
...     DFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FF77FFDBFFEDFFF6FFFB7FFDBFFEA3004DFE7FEDFE7FE31400028015B300078003300078000004
...     A1713400388C001C4100000256FE0000000283C41000E230000022B7E0000000001404D80310118650003202813F03FD7B7027E07FAF6C0E04
...     3183F7FFFFE1B800F800F000C0705807800703F09801E001806BB82C02C00380D770580580070200100000008004000000DE02C88000001644
...     000002B22000002591000001AC8800001164400000AA02B006F2A6B032B006B002B0368084F000029659427800054B2CA1200004A596549000
...     0352CB284800022965940114822E95455019AA013540E68042010020040400801010020044060080140100203008012010020180300500C008
...     20600C02C018050300A0120140205A0940

#3CC: n71A-n78A-n66A, BC1#2FS;
#2CC: n71A-n66A, BC2#2FS;
${FF_ULCA_Support_AA03_UE1}    SEPARATOR=
...     FFA0F200475F7A6B5F83820960006800B8002002024107CC020248170031FFF800140F80C0301C04A87E146FCC0D0A82296595103C017BFF30
...     39036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE31400028015B
...     300078003300078000150FC41DF981A150452CB2A207802F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7
...     FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F005EFFCC0E40DBFFE
...     DFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8C50000A0056CC001E000
...     CC001E0000541F0637E606854114B2CA881E00BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7
...     FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82296595103C016BFF3039036FFFB7FFDBFFE
...     DFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FF77FFDBFFEDFFF6FFFB7FFDBFFEA3004DFE7FEDFE7FE31400028015B300078003300078000004
...     A1713400388C001C4100000256FE0000000285C18000E2080071180000115BF0000000000A026C018808C328001901409F81FEBDB813F03FD7
...     B6070218C1FBFFFFF0DC007C00780060382C03C00381F84C00F000C035DC16016001C06BB82C02C00381000800000040020000006F01644000
...     000B220000015910000012C8800000D644000008B2200000550158037953581958035801581B40327800014B2CA13C0002A5965090000252CB
...     28480001A9659400D4822E95455018AA01140210080100202004008080100220300400A00801018050090080100C0180380600620500200601
...     400C028010500600E01801C0180305008012014024028040B41280

#4CC: n71A-N66A-N25A-N78A, not support lch-ToScellRestriction
#golden
${FF_ULCA_Support_AC01_UE1}    SEPARATOR=
...    FFA0F200475F7A6B5F83820A600034005DC01001012083E60101240B8018FFFC000A07C060180E02543F0A37E606854114B2CA8822005EFFCC0
...    E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8D500005002B66
...    000F00066000F00002A1F883BF30342A08A59654411002F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FF
...    DBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC6A800028015B300078003300078000150FC4DDF981A150452CB2A2088017BFF3039036FFFB7F
...    FDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE3540001400AD98003C001980
...    03C0000A83E0C6FCC0D0A82296595104400BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDB
...    FFEDFFF6FFFA8C026FF3FF6FF3FF1AA0000A0056CC001E000CC001E0000541F11B7E606854114B2CA8822005AFFCC0E40DBFFEDFFF6FFFB7FFD
...    BFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFDDFFF6FFFB7FFDBFFEDFFF6FFFA8C0137F9FFB7F9FF8D500005002B66000F00066000F000000D45E26
...    8007134003850001C41000E2080071180000015BF0000000020713400000FF0000000145E0C0007104003882001C46000E2680071340000115B
...    F0000000000A00C404D808C368001280E04FC0FF5EDC09F81FEBDB813F03FD7B6003818C63FDFFFFF87E001F001E00180E0B00F000E07E13003
...    C00300D7705805800701AEE0B00B000E0400200000010008000001BC01910000002C8800000540160CDE54D00C9E000052CB284F0000A965942
...    4000094B2CA9200006A59654035068BA55154AAEA835D008A02008010080200402008010080100202004008080100200100400CA02004008080
...    1002020040080801002020080100802004168250

#4CC: n71A-N66A-N25A-N78A, support lch-ToScellRestriction
${FF_ULCA_Support_AC01_UE2}    SEPARATOR=
...    FFA0F20047C5F7A6B5F83820960006800BB802002024107CC020248170031FFF800140F80C0301C04A87E146FCC0D0A82296595103C017BFF30
...    39036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE31400028015B3
...    00078003300078000150FC41DF981A150452CB2A207802F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FF
...    DBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F005EFFCC0E40DBFFEDFF
...    F6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8C50000A0056CC001E000CC00
...    1E0000541F0637E606854114B2CA881E00BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBF
...    FEDFFF6FFFA8C026FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82296595103C016BFF3039036FFFB7FFDBFFEDFFF6F
...    FFB7FFDBFFE7FFFA7FFDF1F9F87FC7FF77FFDBFFEDFFF6FFFB7FFDBFFEA3004DFE7FEDFE7FE31400028015B300078003300078000006A2F1340
...    0389A001C28000E20800710400388C000000ADF8000000010389A000007F80000000A2F060003882001C41000E23000713400389A000008ADF8
...    00000000050062026C046194001280E04FC0FF5EDC09F81FEBDB813F03FD7B6003818C63FDFFFFF86E003E003C00301C1601E001C0FC2600780
...    0601AEE0B00B000E035DC16016001C0800400000020010000003780322000000591000000A802C19BCA9A0193C0000A596509E000152CB28480
...    001296595240000D4B2CA806A0D174AA2A955D506BA011404010020100400804010020100200404008010100200400200801940400801010020
...    040400801010020040401002010040082D04A0

${FF_ULCA_Support_AB02_UE1}    SEPARATOR=
...    FFA0F200475F7A6B5F83820960006800B8002002024107CC020248170031FFF800140F80C0301C04A87E146FCC0D0A82296595103C017BFF3039
...    036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE31400028015B3000
...    78003300078000150FC41DF981A150452CB2A207802F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFF
...    EDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC6280005002B66000F00066000F00002A1F89BBF30342A08A5965440F005EFFCC0E40DBFFEDFFF6FFF
...    B7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF8C50000A0056CC001E000CC001E0000
...    541F0637E606854114B2CA881E00BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6
...    FFFA8C026FF3FF6FF3FF18A0001400AD98003C00198003C0000A83E236FCC0D0A82296595103C016BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDB
...    FFE7FFFA7FFDF1F9F87FC7FF77FFDBFFEDFFF6FFFB7FFDBFFEA3004DFE7FEDFE7FE31400028015B300078003300078000004A1F13400388C001C
...    41000E0C0000012B7F0000000141E2680071180000115BF0000000000A026C018808C328001901409F81FEBDB813F03FD7B6070218C1FBFFFFF0
...    DC007C00780060382C03C00381F84C00F000C035DC16016001C06BB82C02C00381000800000040020000006F02B440000008E880000055910000
...    012E8800000D1910000022E880000151D1000003012200000709100000406880000244910000050014CA8BCA8AC0CAC01AC00AC0CAC00AC00ACA
...    8AC00AC01A0353C0000296594A78000452CB28480001296595240000D4B2CA1200008A5965290000504B2CA120000C2596500652A8AA03154066
...    A804D5039AA01154AA2804201002004040080101002004606008004008010300801201C030180300100C0080C0400080700C10300401E0240001
...    80A0090160102D04A0

@{PM_Counters}
...    NRCELL-12:${RRC_RECONF_ADD1ULSCELL_ATT_SA}=0
...    NRCELL-12:${RRC_RECONF_ADD1ULSCELL_SUCC_SA}=0
...    NRCELL-12:${UE_PCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-13:${UE_SCELL_1_CONF_SCELL_UL_SA}>1
...    NRCELL-14:${UE_SCELL_1_CONF_SCELL_UL_SA}=0
...    NRCELL-12:${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}>=1
${RRC_RECONF_ADD1ULSCELL_ATT_SA}    M55118C10001
${RRC_RECONF_ADD1ULSCELL_SUCC_SA}    M55118C10002
${UE_PCELL_1_CONF_SCELL_UL_SA}    M55118C10005
${UE_SCELL_1_CONF_SCELL_UL_SA}    M55118C10006
${MAX_UE_PCELL_1_CONF_SCEL_UL_SA}    M55156C10007

${pdu_id}    1
${gw_id}    1
${nwslice}    1

*** Test Cases ***
CB005935-ET-AA03_81817_asymmetric chbw scell selection
    [Documentation]
    ...    1. This user scenario is to check UL CA can work normally when CNI-81817 is enabled and FDD SCell supports asymmetric
    ...       channel BW between DL and UL and UE works normal.
    ...    2. Configuration
    ...         a. cell13 is n66 with asymmetric chbw (DL 20MHz, UL 10MHz), cell12 is n71 with 5MHz chbw, cell14 is n25 with 5MHz chbw.
    ...         b. cell13 and cell14 is configured as scell for cell12 with coverbased scell addtion method.
    ...         c. actHighestEstNrTputBcSel is enabled.
    ...    3. Test Case Steps:
    ...         a. UE81 registers successfully and PDU session is setup successfully on cell 12, Start traffic and check traffic,
    ...            trigger scell addition A1 MR.
    ...         b. UE82 registers successfully and PDU session is setup successfully on cell 12, Start traffic and check traffic,
    ...            trigger scell addition A1 MR.
    ...         c. online modify fr1UlCaPreferred=ulCaPreferred.
    ...            Deregister UE82, then UE82 registers again successfully and PDU session is setup successfully on cell 12,
    ...            Start traffic and check traffic, trigger scell addition A1 MR.
    ...     4. Expect result:
    ...          a. UE81 registers successfully,
    ...             gNB configures UE81 with 3F DL 3CCs(n25 + asymmetric chbw n66 as DL scell) + UL 2CCs(asymmetric chbw n66
    ...             as UL scell) CA. CU send BC1 3FS to DU. DU select BC1 FS2 for CA.
    ...             DL and UL data can transferred on both Pcell and UL Scell.
    ...          b. UE82 registers successfully,
    ...             gNB configures UE82 with with 2F DL 2CCs(asymmetric chbw n66 as DL scell) CA.
    ...             CU send BC1 2FS & BC2 2FS to DU. DU select BC1 FS1 for CA.
    ...             DL data can transferred on both Pcell and scell, UL data can only be transferred on Pcell.
    ...          c. After online change, UE82 registers successfully again,
    ...             gNB configures UE82 with with 2F DL 2CCs(asymmetric chbw n66 as DL scell) + UL 2CCs(asymmetric chbw n66
    ...             as UL scell) CA. CU send BC1 2FS & BC2 2FS to DU. DU select BC2 FS1 for CA.
    ...             DL and UL data can transferred on both Pcell and UL Scell.
    [Tags]    QC_46933    AA003
    Update UE capa    ${FF_ULCA_Support_AA03_UE1}    81
    Update UE capa    ${FF_ULCA_Support_AA03_UE2}    82
    Execute Cmd On Pc    sudo sysctl -w net.sctp.rto_min=100
    UE attach and scell add 3CC    81
    UE attach and scell add 2CC    ue_id=82    check_scell=false    fail=${AA03_no_ulscell}
    OnlineParamChange    ${OnlineParamChange_AA03}
    UE Deregister From gNB    82
    UE attach and scell add 2CC    ue_id=82    check_scell=true    pass=${AA03_ulscell}
    Release Ues    ue_type=all
    OnlineParamChange    ${recovery_AA03}
    check wireshark log    ${CURDIR}${/}A2A_AA03${/}a2a.ini    wait_string=UEContextReleaseComplete::12

CB005935-ET-AC01_Data scheduling IWK with lch-ToSCellRestrisction
    [Documentation]
    ...    1. This user scenario is to check  the NR call setup with FDD - FDD FR1 UL Carrier aggregation for the UE supporting
    ...       lch-ToSCellRestriction capability and for the UE not supporting lch-ToSCellRestriction capability.
    ...       PCell is FDD carrier and single SCell is also FDD.
    ...    2. Configuration
    ...         a. cell13 is n66 with asymmetric chbw (DL 20MHz, UL 10MHz), cell12 is n71 with 5MHz chbw, cell14 is n25 with 5MHz chbw.
    ...         b. cell13(n66), cell14(n25), cell1(n78), cell2(n78), cell12(n66) is configured as scell for cell12 with coverbased
    ...            scell addtion method, bufferedBased scell activation method.
    ...    3. Test Case Steps:
    ...         a. UE81 registers successfully and PDU1 session with 5QI5/1/2 is setup successfully on cell 12, Start little traffic,
    ...            trigger scell addition A1 MR.
    ...         b. add PDU2 with 5QI6 on UE81, start enough UL/DL data on PDU2.
    ...         c. release PDU1 on UE81.
    ...         d. UE82 registers successfully and PDU1 session with 5QI5/1/2 is setup successfully on cell 12, Start little traffic,
    ...            trigger scell addition A1 MR.
    ...         e. add PDU2 with 5QI6 on UE82, start enough UL/DL data on PDU2.
    ...         f. release PDU1 on UE82.
    ...         g. release all UEs.
    ...     4. Expect result:
    ...          a. UE81 registers successfully,
    ...             gNB configures UE81 with 3F1T DL 4CCs + UL 2CCs(asymmetric chbw n66 as UL scell) CA.
    ...             DL and UL data can transferred on Pcell, all scell not activated due to not enough buffer level.
    ...          b. All scells activated, data transfer as below:
    ...             data transmission on SRB:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      No	      Yes
    ...             data transmission on 5QI-1/5QI-2:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      No	      No
    ...             data transmission on 5QI-6/5QI-5:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      Yes	      No
    ...          c. PDU1 release successfully, data transfer as below:
    ...             data transmission on SRB:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      No	      Yes
    ...             data transmission on 5QI-6:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      Yes	      Yes
    ...          d. UE82 registers successfully,
    ...             gNB configures UE81 with 3F1T DL 4CCs + UL 2CCs(asymmetric chbw n66 as UL scell) CA.
    ...             DL and UL data can transferred on Pcell, all scell not activated due to not enough buffer level.
    ...             DL data can transferred on both Pcell and scell, UL data can only be transferred on Pcell.
    ...          e. All scells activated, data transfer as below:
    ...             data transmission on SRB:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      No	      No
    ...             data transmission on 5QI-1/5QI-2:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      No	      No
    ...             data transmission on 5QI-6/5QI-5:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      Yes	      Yes
    ...          f. PDU1 release successfully, data transfer as below:
    ...             data transmission on SRB:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      No	      No
    ...             data transmission on 5QI-6:
    ...             Pcell-DL	Pcell-UL	Scell-DL	Scell-UL
    ...             Yes	          Yes	      Yes	      Yes
    ...          g. release all UEs successfully.
    [Tags]    QC_358530    AC001
    Update UE capa    ${FF_ULCA_Support_AC01_UE1}    81
    Update UE capa    ${FF_ULCA_Support_AC01_UE2}    82
    OnlineParamChange    ${OnlineParamChange_AC01}
    Execute Cmd On Pc    sudo sysctl -w net.sctp.rto_min=100
    UE attach and scell add 4CC without lch-ToScellRestriction    ue_id=81
    Release Ues    ue_type=all
    UE attach and scell add 4CC with lch-ToScellRestriction    ue_id=82
    Release Ues    ue_type=all
    OnlineParamChange    ${recovery_AC01}

CB005935-ET-AB02_scell change from T to F with 81817 enable
    [Documentation]
    ...    1. The purpose of this test case is to check the A1 based SCell change (F+T -> F+F+F) with FR1 FDD Cell as PCell,
    ...       the TDD SCell and FDD SCell all have uplink configuration.
    ...    2. configuration
    ...          CA  Cell ID     PCID  nrCellIdentity    NRREL   Duplex     Band       BW   weight    arfcn     gscn OperationalMode
    ...       pcell  cell-12       61           16396      NaN      FDD      N71       5M      NaN   126990     1587             NaN
    ...         F+T   cell-2       51           16386  NRREL-2      TDD      N78      40M        1   633216     7845         dlAndUl
    ...       F+F+F  cell-13       62           16397 NRREL-13      FDD      N66  20M+10M      100   427970     5350         dlAndUl
    ...       F+F+F  cell-14       63           16398 NRREL-14      FDD      N25       5M      100   389090     4864         dlAndUl
    ...    3. Test Case Steps
    ...       a. Attach UE-1 to Cell-1 and make SA call, trigger A1 scell Addition MR
    ...       b. trigger A1 scell change MR
    ...       c. Release UE-1, attach UE-1 again to Cell-1 and make SA call, trigger A1 scell Addition MR
    ...       d. online change NRDU.fr1UlCaPreferred to 1, trigger A1 scell change MR
    ...     4. Expect result
    ...        a. FR1 FDD-TDD 2CC with DL and UL CA is configured, cell-2 are selected as SCell with BC#2 FS#1
    ...        b. F+T 2CC CA change to 3F CA, cell-13/14(n66,n25) selected as DL only scell with BC#2 FS#1,
    ...           No impact on data, counter pegged cottectly
    ...        c. UE release successfully, for UE-1 attach again,
    ...           FR1 FDD-TDD 2CC with DL and UL CA is configured, cell-2 are selected as SCell with BC#2, FS#1
    ...        d. F+T 2CC CA change to 3F CA, cell-14(n25) selected as DL only scell, cell-13(n66) selected as DL+UL scell with BC#2 FS#1,
    ...           No impact on data, counter pegged cottectly
    [Tags]    QC_349609    AB002
    Clear Counter Files
    OnlineParamChange    ${OnlineParamChange_AB02}
    Update UE capa    ${FF_ULCA_Support_AB02_UE1}    81
    Execute Cmd On Pc    sudo sysctl -w net.sctp.rto_min=100
    UE attach and scell add 2CC AB02    ue_id=81    check_scell=false
    UE trigger A1 MR to scell change    ue_id=81    pass_regexp=${AB02_scell_1_pass}    fail_regexp=${AB02_scell_1_fail}    check_scell=false
    Release Ues    ue_type=all
    UE attach and scell add 2CC AB02    ue_id=81    check_scell=false
    OnlineParamChange    ${OnlineParamChange_AA03}
    UE trigger A1 MR to scell change    ue_id=81    pass_regexp=${AB02_scell_2_pass}    fail_regexp=${AB02_scell_2_fail}
    ...    check_scell=true    scell_id=2
    Release Ues    ue_type=all
    Check Counters    pm_counters_expression=${PM_Counters}
    OnlineParamChange    ${recovery_AB02}
    Check Wireshark Log    ${CURDIR}${/}a2a_AB02${/}a2a.ini    wait_string=UEContextReleaseComplete::8

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F_n78_n78_n71_n66_n66_n25

Modify Cfg
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosflow id=4 5qi=7
    Update Cfg    set_qosflow id=5 5qi=8
    Update Cfg    set_qosflow id=6 5qi=4
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_qosrule id=3 proto=tcp qos_flow=4
    Update Cfg    set_qosrule id=4 proto=tcp qos_flow=5
    Update Cfg    set_qosrule id=5 proto=udp qos_flow=6
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all qos_flows=1,2,3,4,5,6 qos_rules=1,2,3,4,5 amf=1
    Update Cfg    set_pdu_gateway id=2 ue_nat_ip=72.23.1.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=3 ue_nat_ip=72.23.2.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=4 ue_nat_ip=72.23.3.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Update Cfg    set_pdu_gateway id=5 ue_nat_ip=72.23.4.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
    Delete Cfg    debug_log level=2
    Update Cfg    debug_log level=0
    Update Cfg    sim_debug_log level=4 mme=1
    Update Cfg    sim_debug_log level=4 pgw=1
    Update Cfg    sim_debug_log level=0 uec=1
    Update Cfg    sim_param_set TTI=3

UE trigger A1 MR to scell change
    [Arguments]    ${ue_id}=1    ${carrierfreq}=126990    ${pass_regexp}=none    ${fail_regexp}=none    ${check_scell}=false    ${scell_id}=1
    ${meas_id}    get_nr_meas_id_for_specific_type_and_frequency    ue_id=${ue_id}    carrierfreq=${carrierfreq}    event_type=A1
    Execute Egate Command    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=120 srsrq_nr=103
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Verify Throughput on Pscell and Scell 3CC AB02    ue_id=${ue_id}    check_scell=${check_scell}    scell_id=${scell_id}

UE attach and scell add 3CC
    [Arguments]    ${ue_id}=81
    UE Attach To Target Cell    cell_id=12    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}    dl_tp=40    ul_tp=10    pdu_id=1
    Trigger MR    event_type=A1    carrierfreq=126990    srsrp_nr=100    srsrq_nr=50    ue_id=${ue_id}
    Verify Throughput on Pscell and Scell 3CC    ue_id=${ue_id}

UE attach and scell add 2CC
    [Arguments]    ${ue_id}=81    ${check_scell}=false    ${pass}=none    ${fail}=none
    UE Attach To Target Cell    cell_id=12    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}    dl_tp=17    ul_tp=7
    Trigger MR    event_type=A1    carrierfreq=126990    srsrp_nr=100    srsrq_nr=50    ue_id=${ue_id}    pass=${pass}    fail=${fail}
    Verify Throughput on Pscell and Scell 2CC    ue_id=${ue_id}    check_scell=${check_scell}

UE attach and scell add 2CC AB02
    [Arguments]    ${ue_id}=81    ${check_scell}=false
    UE Attach To Target Cell    cell_id=12    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}    dl_tp=150    ul_tp=100
    Trigger MR    event_type=A1    carrierfreq=126990    srsrp_nr=100    srsrq_nr=50    ue_id=${ue_id}
    Verify Throughput on Pscell and Scell 2CC AB02    ue_id=${ue_id}    check_scell=${check_scell}

UE attach and scell add 4CC without lch-ToScellRestriction
    [Arguments]    ${ue_id}=81    ${failed_scell}='No response from proxy'
    UE Attach To Target Cell with VINR call without lch-ToScellRestriction    cell_id=12    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}    dl_tp=1    ul_tp=1
    Trigger MR no addition    event_type=A1    carrierfreq=126990    srsrp_nr=100    srsrq_nr=50    ue_id=${ue_id}
    PDU3 verify without lch-ToScellRestriction    ue_id=${ue_id}
    PDU1_2 release without lch-ToScellRestriction    ue_id=${ue_id}

UE attach and scell add 4CC with lch-ToScellRestriction
    [Arguments]    ${ue_id}=81    ${failed_scell}='No response from proxy'
    UE Attach To Target Cell with VINR call with lch-ToScellRestriction    cell_id=12    ue_id=${ue_id}
    Send Throughput    ue_id=${ue_id}    dl_tp=1    ul_tp=1
    Trigger MR no addition    event_type=A1    carrierfreq=126990    srsrp_nr=100    srsrq_nr=50    ue_id=${ue_id}
    PDU3 verify with lch-ToScellRestriction    ue_id=${ue_id}
    PDU1_2 release with lch-ToScellRestriction    ue_id=${ue_id}

PDU3 verify without lch-ToScellRestriction
    [Arguments]    ${ue_id}=81
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=3 gw=3 nwslice=1    pass_regexp=QoS Routing Table    fail_regexp=${allowedServing}
    Send Throughput    ue_id=${ue_id}    dl_tp=40    ul_tp=10    pdu_id=3
    Verify Throughput scell no UL    ue_id=${ue_id}    pdu=3

PDU3 verify with lch-ToScellRestriction
    [Arguments]    ${ue_id}=82
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=3 gw=3 nwslice=1    pass_regexp=QoS Routing Table    fail_regexp=${allowedServing}
    Send Throughput    ue_id=${ue_id}    dl_tp=40    ul_tp=10    pdu_id=3
    Verify Throughput scell has UL    ue_id=${ue_id}    pdu=3

PDU1_2 release without lch-ToScellRestriction
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=ue    Successfully released PDU
    Verify Throughput scell no UL    ue_id=${ue_id}    pdu=3
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=ue    Successfully released PDU
    Verify Throughput scell has UL    ue_id=${ue_id}    pdu=3

PDU1_2 release with lch-ToScellRestriction
    [Arguments]    ${ue_id}=82
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1 by=ue    Successfully released PDU
    Verify Throughput scell has UL    ue_id=${ue_id}    pdu=3
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=2 by=ue    Successfully released PDU
    Verify Throughput scell has UL    ue_id=${ue_id}    pdu=3

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Update UE capa
    [Arguments]    ${SA_Capa_perUE_Full}=none    ${ue_id}=81
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa_perUE_Full}
    Execute Egate Command    ${cmd}

UE Attach To Target Cell
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table

UE Attach To Target Cell with VINR call without lch-ToScellRestriction
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=2
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=QoS Routing Table    fail_regexp=${allowedServing}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table    fail_regexp=${allowedServing}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6 by=amf    QoS Routing Table
    Execute Egate Command    smf_param id=1 reset

UE Attach To Target Cell with VINR call with lch-ToScellRestriction
    [Arguments]    ${cell_id}    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify default=on qos_flow=2
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=3
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_with_lch-ToScellRestriction}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    qosflow_modify default=on qos_flow=1
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=2 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=2 gw=2 nwslice=1    pass_regexp=QoS Routing Table    fail_regexp=${allowedServing}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6 by=amf    pass_regexp=${pass_with_lch-ToScellRestriction}
    Execute Egate Command    smf_param id=1 reset

Send Throughput
    [Arguments]    ${ue_id}=81    ${dl_tp}=150    ${ul_tp}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=5    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=${dl_tp} trf_id=6    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_tp} trf_id=1    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_tp} trf_id=2    UE ${ue_id}: UDP UL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=${ul_tp} trf_id=3    UE ${ue_id}: UDP UL
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    sleep    5s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput

Verify Throughput on Pscell and Scell 3CC
    [Arguments]    ${ue_id}=81    ${pcell_dl}=50    ${scell1_dl}=140    ${scell2_dl}=65    ${ul}=3    ${ul_scell}=25
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}    # 50.3 Mbps
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell1_dl}    # 143.1 Mbps
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > ${scell2_dl}    # 67.8 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > ${ul}    # 3.9 Mbps
    ${scell1_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${scell1_ultput}/1000 > ${ul_scell}    # 27.7 Mbps

Verify Throughput on Pscell and Scell 2CC
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=70    ${ul}=1.5    ${check_scell}=flase
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}    # 24.8 Mbps/12.4 Mbps ?
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}    # 71.6 Mbps/71.5 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > ${ul}    # 1.9 Mbps/1.9 Mbps
    Run Keyword If  '${check_scell}'=='true'  Verify UL Throughput on Scell

Verify UL Throughput on Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=3    ${ul}=1    ${check_scell}=flase    ${scell_id}=1
    ${scell1_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pusch    rate_type=ave
    Should Be True    ${scell1_ultput}/1000 > ${ul}    # NA/16.1 Mbps  || # NA/23.0 Mbps

Verify Throughput scell no UL
    [Arguments]    ${ue_id}=81    ${Tput_dl}=200    ${ul}=10    ${pdu}=1    ${qfi}=1
    sleep    10s     #sleep for stable traffic
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    ${scell_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Not Match Regexp    ${scell_tputdl}    CellIndex-[0-5] *0 *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > 3
    ${scell2_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pusch    rate_type=ave
    Should Be True    ${scell2_ultput} == 0

Verify Throughput scell has UL
    [Arguments]    ${ue_id}=81    ${Tput_dl}=200    ${ul}=10    ${pdu}=1    ${qfi}=1
    sleep    10s     #sleep for stable traffic
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    ${scell_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    Should Not Match Regexp    ${scell_tputdl}    CellIndex-[0-3] *0 *0 *0 *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > 3
    ${scell2_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pusch    rate_type=ave
    Should Be True    ${scell2_ultput}/1000 > 25

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Trigger MR
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82    ${pass}=none    ${fail}=none
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass}    fail_regexp=${fail}

Trigger MR no addition
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=100    ${srsrq_nr}=100    ${ue_id}=82
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete    fail_regexp=SCellIndex 1 activated

Trigger MR A2
    [Arguments]    ${event_type}=A1    ${carrierfreq}=518910    ${srsrp_nr}=5    ${srsrq_nr}=5    ${ue_id}=82    ${scell}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr} scell=${scell}
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete

Verify Throughput on Pscell and Scell 3CC AB02
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=10    ${ul}=3    ${scell_id}=1    ${check_scell}=flase
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}    # 27.2 Mbps/13.6 Mbps
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}    # 143.1 Mbps/77.2 Mbps
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=3    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > ${scell_dl}    # 33.9 Mbps/18.3 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > ${ul}    # 3.9 Mbps/3.4 Mbps
    Run Keyword If  '${check_scell}'=='true'  Verify UL Throughput on Scell    scell_id=${scell_id}

Verify Throughput on Pscell and Scell 2CC AB02
    [Arguments]    ${ue_id}=81    ${pcell_dl}=10    ${scell_dl}=3    ${ul}=1    ${check_scell}=flase
    sleep    10s     #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pusch    PUSCH Throughput
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-5 type=pdsch    PDSCH Throughput
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}    # 50.3 Mbps/50.2 Mbps
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}    # 207.4 Mbps/210.1 Mbps
    ${scell0_ultput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_ultput}/1000 > ${ul}    # 3.9 Mbps/3.9 Mbps
    Run Keyword If  '${check_scell}'=='true'  Verify UL Throughput on Scell

