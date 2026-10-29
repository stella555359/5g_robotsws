*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    team-CN1ET    owner-zora.wang
...    CLOUD_5G_I_BOO_AP_LOO    CRT    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{NRCELL_12_NRREL}
...    @{PARAMS_FOR_9059}
...    @{8311_enable}
...    @{PARAMS_FOR_CA}
...    @{5qi71_related_modification}
...    @{FDD_DLMIMO}

@{PARAMS_FOR_9059}
...    NRBTS-1/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1/NRDRB-18:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1/NRDRB-19:cellAggrLevel=Not FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA


@{FDD_DLMIMO}
...    NRCELL:actGbrRacTdEnhResourcePriority=true
...    NRCELL:actGBRAdmissionControl=off
...    NRDU-1:flexibleCAMode=NumberCellAmount
...    NRBTS:actSlowPrbPooling=true
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRCELL-11:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-13:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL-14:dlMimoMode=2x2 Closed Loop Spatial Multiplexing
...    NRCELL:fPdcchMonOccsnPo=2
...    NRCELL-1:maxNumOfCaUsersNRCell=60
...    NRCELL-1:maxNumOfUsersPerNRCell=90
...    NRCELL-1:msg1FrequencyStart=1
...    NRCELL-2:maxNumOfCaUsersNRCell=60
...    NRCELL-2:maxNumOfUsersPerNRCell=90
...    NRCELL-2:msg1FrequencyStart=1
...    NRCELL-3:maxNumOfCaUsersNRCell=120
...    NRCELL-3:maxNumOfUsersPerNRCell=190
...    NRCELL-3:msg1FrequencyStart=10
...    NRCELL-11:maxNumOfUsersPerNRCell=160
...    NRCELL-11:maxNumOfCaUsersNRCell=160
...    NRCELL-12:maxNumOfUsersPerNRCell=160
...    NRCELL-12:maxNumOfCaUsersNRCell=160
...    NRCELL-13:maxNumOfUsersPerNRCell=160
...    NRCELL-13:maxNumOfCaUsersNRCell=160
...    NRCELL-14:maxNumOfUsersPerNRCell=160
...    NRCELL-14:maxNumOfCaUsersNRCell=160
...    NRCELL:maxNumOfSCellAlloc=90
...    NRCELL:maxNumOfUsersPerCell=90
...    NRCELL:maxNumOfRrcSA=90
...    NRCELL:maxNumOfNrDcSnUsers=90

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actVoNR=true
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL:sCellDeactivationTimerGNB=ms1280
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10

...    NRBTS:actOverheatingAssistance=true
...    NRBTS:timerOverheatIndProhibit=0s
...    NRBTS:timerPostOverheating=10
...    NRBTS:sCellDeactivationBadRlqCount=1
...    NRBTS:actSCellReleaseBadSCellRlq=enabled_Fr1
...    NRBTS:sCellExcludelistTimerFr1=20
...    NRBTS:caBackoffTimerUeOh=20
...    NRCELL:dllaDeltaCqiMin=-150

...    NRCELL:sCellGoodChannelQualityThreshold=8
...    NRCELL:sCellBadChannelQualityThreshold=4
...    NRCELL:sCellChannelEstimationPeriod=2000

@{NRCELL_12_NRREL}
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:nrDcAllowed=false
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-12/NRREL-2:lcrId=2
...    NRCELL-12/NRREL-2:nrDcAllowed=false
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3

@{5qi71_related_modification}
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRBTS/NRDRB-18:actDddsReduction=false
...    NRBTS/NRDRB-18:actDlTxResumeOnPdcpStatRep=false
...    NRBTS/NRDRB-18:actLostPduFastRetx=false
...    NRBTS/NRDRB-18:discardTimer=50ms
...    NRBTS/NRDRB-18:dlAllowMinDelayLinkXxCalib=false
...    NRBTS/NRDRB-18:dlFlowControlAlgo=3gppFlowControl
...    NRBTS/NRDRB-18:dscp=0
...    NRBTS/NRDRB-18:durationThresDiscardDl=40
...    NRBTS/NRDRB-18:durationThresDiscardUl=20
...    NRBTS/NRDRB-18:endMarkerTimer=2000
...    NRBTS/NRDRB-18:l2OHFactorDl=16
...    NRBTS/NRDRB-18:l2OHFactorUl=35
...    NRBTS/NRDRB-18:maxDataRateGbrDl=30720
...    NRBTS/NRDRB-18:maxDataRateGbrUl=30720
...    NRBTS/NRDRB-18:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-18:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-18:maxTransferDelayGbr=20
...    NRBTS/NRDRB-18:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS/NRDRB-18:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS/NRDRB-18:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-4
...    NRBTS/NRDRB-18:numSduDiscard=1
...    NRBTS/NRDRB-18:queuingDelaySduDiscardThreshold=750
...    NRBTS/NRDRB-18:resType=GBR
...    NRBTS/NRDRB-18:rlcMode=RLC_AM
...    NRBTS/NRDRB-18:schedulWeight=1
...    NRBTS/NRDRB-18:sduDiscardIntervalTmr=500
...    NRBTS/NRDRB-18:volThresDiscardDl=8000
...    NRBTS/NRDRB-18:volThresDiscardUl=800
...    NRBTS/NRDRB-18:nsaDrbParam:actPrioritizeX2AfterInactivity=true
...    NRBTS/NRDRB-18:nsaDrbParam:actX2DuplicateTxNSA3x=false
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitBufferBuildUpThresholdPrioritizeX2=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitGainThreshold=5
...    NRBTS/NRDRB-18:nsaDrbParam:dlDataSplitMode=dlOverF1UX2U
...    NRBTS/NRDRB-18:nsaDrbParam:dlNumOfCongOrGainDdds=2
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForPrioritizeX2=300
...    NRBTS/NRDRB-18:nsaDrbParam:inactivityThresholdForRestartPrioritizeX2=100
...    NRBTS/NRDRB-18:nsaDrbParam:inactPeriodX2PdcpDuplication=300
...    NRBTS/NRDRB-18:nsaDrbParam:initialDLTrafficRouting=initDLoverX2U
...    NRBTS/NRDRB-18:nsaDrbParam:nsa3xBearerAllowed=true
...    NRBTS/NRDRB-18:nsaDrbParam:prioritizeX2Period=500
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataPath=ulOverNr
...    NRBTS/NRDRB-18:nsaDrbParam:ulDataSplitThreshold=infinity
...    delete:NRBTS/NRDRB-18.nsaDrbParam-1.dlPreferredPath
...    delete:NRBTS/NRDRB-18:nrPdschHRLaDN
...    NRBTS/NRDRB_5QI-8:fiveqiValueList=71
...    NRBTS/NRDRB_5QI-8:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-18
...    NRBTS/NRDRB_MAC-5:delayTarget=50
...    NRBTS/NRDRB_MAC-5:lcgid=5
...    NRBTS/NRDRB_MAC-5:prioritisedBitRate=16kBps
...    NRBTS/NRDRB_MAC-5:schedulBSD=5ms
...    NRBTS/NRDRB_MAC-5:schedulPrio=7
...    NRBTS/NRDRB_PDCP-4:cuFlowControlProfId=1
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_PDCP-4:pdcpBufDiscardThreshold=20000
...    NRBTS/NRDRB_PDCP-4:pdcpDelayThreshRetxMode=disabled
...    NRBTS/NRDRB_PDCP-4:tReorderingDl=ms8
...    NRBTS/NRDRB_PDCP-4:tReorderingUl=ms8
...    NRBTS/NRDRB_PDCP-4:xxFlowControlProfForCuIdx=1
...    NRBTS/NRDRB_RLC_AM-4:dlMaxRetxThreshold=t16
...    NRBTS/NRDRB_RLC_AM-4:dlPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:dlPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:dlTPollRetr=ms100
...    NRBTS/NRDRB_RLC_AM-4:dlTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:dlTReassemblyIBCA=30
...    NRBTS/NRDRB_RLC_AM-4:duFlowControlProfId=1
...    NRBTS/NRDRB_RLC_AM-4:ulMaxRetxThreshold=t32
...    NRBTS/NRDRB_RLC_AM-4:ulPollByte=kB500
...    NRBTS/NRDRB_RLC_AM-4:ulPollPDU=p64
...    NRBTS/NRDRB_RLC_AM-4:ulTPollRetr=ms45
...    NRBTS/NRDRB_RLC_AM-4:ulTProhib=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassembly=ms15
...    NRBTS/NRDRB_RLC_AM-4:ulTReassemblyIBCA=${EMPTY}

@{scell_release_due_to_traffic_reduce}
...    SCellIndex 1 deactivated successfully at airphone
...    SCellIndex 2 deactivated successfully at airphone
...    pcid:61, scellIdx:0
...    rrcReconfigurationComplete

@{scell_release_due_to_overheat}
...    SCellIndex 1 deactivated successfully
...    SCellIndex 2 deactivated successfully
...    overheatingAssistanceConfig release : NULL
...    sCellToReleaseList.*\{.*1.*\}\.
...    sCellToReleaseList.*\{.*2.*\}\.

@{PM_Counters_BA13}
...    NRCELL-12:${DL_RRC_FSCELL_REL_ATT_SA}=3
...    NRCELL-12:${DL_RRC_FSCELL_REL_SUC_SA}=3
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=3
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

@{PM_Counters_BA16}
...    NRCELL-12:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-12:${DL_RRC_FSCELL_REL_SUC_SA}=1
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=2
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=2
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

@{PM_Counters_BA17}
...    NRCELL-12:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-12:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=1
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.

${SA_Capa_3T3F}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E7C4
...    71E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C471E312
...    38F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A067D813E31CF9863C
...    A1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040E1E027FFC00001FF
...    F000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010B02B0F13000388C
...    0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0AC5C4C000E23000711800001058158B
...    850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5C28000E23000711800001058158B898001
...    C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E1617593850001C28000E20800710400389800001
...    C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E2080000A0B0102F07118000050580817838980000242C040803
...    808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1C
...    F811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C09502040810206CB5E1C881020
...    4081B2D78722040810206CB5E1C089B1CF870206C00004081B000010206C0000001F1618C6318C6318C6318C6318C6318DE82E003C00281C1401C
...    0C02500700060240040603E0900200000001000002008000000040000080200000801000006008000040040000280200100401004000030020000
...    1C010008000000200002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D60
...    25604560ED0341000009652404000065949410000296525040000E594901000049652404000165949010000696524040001E59490100008965240
...    4000265949010000A96524040002E5949410000C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555
...    078A160178095028140A05028140A05028140A05028140A050281400282020180300801002101002008040300610080100202018030080600C101
...    00C018040300610080100202018030080100220100C01804030060100C018202004010080100440100200404008010100C0180403006010020048
...    02004008080600C02018030080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828705A0

@{OnlineParam_BA16}    #sets NRDRB-4 cellAggrLevel to FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA incompatible

@{OnlineParam_BA1617_recover}    #sets NRDRB-4 cellAggrLevel to FR1 CA incompatible
...    NRBTS-1/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based

@{OnlineParam_9059_disable}
...    NRBTS-1:actDrbProfileForCellAggrLevel=disabled

@{OnlineParam_BA17}
...    NRBTS-1:actMeasBasedSCellAdditionSa=disabled
...    NRBTS-1:actDrbProfileForCellAggrLevel=disabled
...    NRBTS-1/NRDRB-14:cellAggrLevel=Not FR1 CA eligible

@{OnlineParam_9059_enable}
...    NRBTS-1:actDrbProfileForCellAggrLevel=FR1_SA

@{5QI6_9_check}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:9
...    QoS Routing Table

@{5QI8_add}
...    Added QosFlow with QFI:3 fiveQI:8
...    QoS Routing Table

@{5QI6_8_check}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{5QI7_add_BA17}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{5QI8_add_BA17}
...    Added QosFlow with QFI:2 fiveQI:8
...    QoS Routing Table

@{5QI8_del_BA17}
...    Deleting QosFlow with QFI:2 5QI:8
...    QoS Routing Table

@{5QI7_9_BA17}
...    Deleting QosFlow with QFI:1 5QI:7
...    Adding QosFlow with QFI:2 5QI:9
...    QoS Routing Table

*** Test Cases ***
CB009059-ET-BA16_On-line_parameter_modification_blind_SCell_Addition_Method_with_buffer_based_activated
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:UE is attached to the PCell and DL buffer monitoring for SCell Addition
    ...    is activated for the UE at the gNB-DU. If CB009059 is deactivated, or if an NRDRB instance is changed such that CA.is no longer allowed,
    ...    the change does not take effect on this UE unless the DRB is released and reestablished.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81 3CC PCELL(cell-12) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...    a.The UE attaches to Cell-12,and PDU session with non-GBR DRB-1 and DRB-4.online sets NRDRB-4 cellAggrLevel to FR1 CA incompatible.
    ...     Sufficient DL data to exceed the PCell throughput is initiated for DRB-1 and DRB-4. Non-GBR data transfer is on the PCell and SCell.
    ...     UE is in 3CC DL CA,DL data for DRB-1 and DRB-4 is split to the PCell and SCell(s).UE PDU Session Resource Modification procedure to
    ...     add DRB-3,expect result: DRB-3 add successfully,scell released trigger.
    ...    b.online sets NRDRB-4 cellAggrLevel to FR1 CA eligible.UE2 attaches to Cell-12 and PDU session with non-GBR DRB-1 and DRB-4. online
    ...    sets actDrbProfileForCellAggrLevel disabled.PDU Session Resource Modification procedure to establish DRB-3 at the UE2,gNB configures
    ...    UE with CA. DL data for DRB-1,DRB-3 and DRB-4 is split to the PCell and SCell(s).
    [Tags]    QC_344360    BA16    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files
    UE PDU Session Setup with multiple Qosflow    pass_regexp=${5QI6_9_check}
    OnlineParamChange    ${OnlineParam_BA16}
    UE1 traffic check and add DRB3
    OnlineParamChange    ${OnlineParam_BA1617_recover}
    UE PDU Session Setup with multiple Qosflow    ue_id=82    pass_regexp=${5QI6_9_check}
    OnlineParamChange    ${OnlineParam_9059_disable}
    UE2 add DRB3 and check traffic
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_BA16${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    pm_counters_expression=${PM_Counters_BA16}
    [Teardown]    case recover BA1617

CB009059-ET-BA17_On-line_feature_activation_blind_SCell_Addition_Method_with_buffer-based_activated
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:UE is attached to the PCell and DL buffer monitoring for SCell Addition
    ...    is activated at the UE with feature deactivated.If CB009059 is activated while the UE is connected to the cell,the change does not take
    ...    effect on this UE unless the DRB is released and reestablished or a new DRB is established.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 1:Not FR1 CA eligible
    ...          UE81 3CC PCELL(cell-12) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...    a.online sets actDrbProfileForCellAggrLevel disabled.The UE attaches to Cell-12,and PDU session with non-GBR DRB-1 and DRB-3.
    ...     UE2 attaches to Cell-12,and PDU session with non-GBR DRB-2.
    ...    b.online sets actDrbProfileForCellAggrLevel enabled.UE1 PDU Session Resource Modification procedure to release DRB-3 at the UE.UE1 PDU
    ...    Session Resource Modification procedure to setup DRB-3.DL data of DRB-1 is sent to the UE1.Data rate is sufficient to exceed the PCell
    ...    throughput.gNB don't configures UE with CA.
    ...    c.UE2 PDU release DRB-2 and establish DRB-4 for the UE,Data rate is sufficient to exceed the PCell throughput.gNB don't configures CA.
     [Tags]    QC_46731    BA17    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)    AP_REG
    OnlineParamChange    ${OnlineParam_BA17}
    clear counter files
    UE PDU Session Setup with multiple Qosflow    qos_id=3    pass_regexp=${5QI6_8_check}
    SA UE Attach    ue_id=82    qos_id=2    pass_regexp=${5QI7_add_BA17}
    OnlineParamChange    ${OnlineParam_9059_enable}
    UE1 delete DRB3 then add DRB3 And Check Traffic
    UE2 release DRB2 then add DRB4 And Check Traffic
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}A2A_BA17${/}a2a.ini    wait_string=UEContextReleaseComplete::6
    Check Counters    pm_counters_expression=${PM_Counters_BA17}
    [Teardown]    case recover BA1617

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
    Update Cfg    ue_param id=82 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    ue_nr_capabilities id=81 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=7
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=71 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1

SA UE Attach
    [Arguments]    ${ue_id}=81    ${cell_id}=12    ${qos_id}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret}    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=${pass_regexp}
    should not contain    ${ret}    sCellIndex 1

Sent Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=10 trf_id=1    pass_regexp=Started Uplink

Check Traffic
    [Arguments]     ${ue_id}=81    ${cell_num}=2    ${dl}=300    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ${ue_id}    ${str_index}    pdsch
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

Verify Throughput pcell
    [Arguments]     ${ue_id}=81    ${dl}=60    ${ul}=8
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${ul_throuput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    ${dl_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch    fail_regexp=CellIndex-
    Should Be True    ${dl_tput}/1000 > ${dl}
    Should Be True    ${ul_throuput}/1000 > ${ul}

SCell release timer for data inactivity exceeded
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}    pass_regexp=${scell_release_due_to_traffic_reduce}
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    ${cmd}    Catenate    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch
    Wait Until Keyword Succeeds    5 min    2s    Execute Egate Command    ${cmd}    fail_regexp=CellIndex-

UE1 attach cell12 and scell release due to no traffic
    SA UE Attach
    Sent Throughput
    Wait Until Keyword Succeeds    30s    5s    Check Traffic
    SCell release timer for data inactivity exceeded
    Release Ues    ue_type=all

SCell release timer for UE Overheating
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    ue_assistance_send_nr ue_id=${ue_id} forOverheating=yes reducedCCsDL=0    pass_regexp=${scell_release_due_to_overheat}

ADD QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=4    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

UE2 attach cell12 and scell release due to Overheat
    SA UE Attach
    Sent Throughput
    Wait Until Keyword Succeeds    30s    5s    Check Traffic
    SCell release timer for UE Overheating
    ADD QOS in same pdu
    Wait Until Keyword Succeeds    40s    5s    Check Traffic
    Release Ues    ue_type=all

Trigger scell bad RLQ for scell
    [Arguments]    ${scell_id}=2    ${ue_id}=81
    Trigger scell bad RLQ       scell_id=${scell_id}    ue_id=${ue_id}
    ${cmd}    Catenate    ue_stats_nr id=${ue_id} scell=1-11 type=pdsch
    Wait Until Keyword Succeeds    3 min    2s    Execute Egate Command    ${cmd}    fail_regexp=CellIndex-
    Recover scell bad RLQ

Trigger scell bad RLQ
    [Arguments]    ${scell_id}=2    ${ue_id}=81
    FOR    ${index}    IN RANGE    1    ${scell_id}+1
         ${str_index}    Convert To String    ${index}
         Execute Egate Command    bler_testmode_nr profile_id=${str_index} target_mcs=0 num_dl_pkts=10000
         ${cmd}    Catenate    ue_testmode_set_nr id=${ue_id} scell=${str_index} testmode=bler action=activate profile_id=${str_index}
         Execute Egate Command    ${cmd}    pass_regexp=SCellIndex ${str_index} deactivated successfully at airphone
    END

Recover scell bad RLQ
    [Arguments]    ${scell_id}=2    ${ue_id}=81
    FOR    ${index}    IN RANGE    1    ${scell_id}+1
         ${str_index}    Convert To String    ${index}
         Execute Egate Command    ue_testmode_set_nr id=${ue_id} scell=${str_index} testmode=bler action=deactivate profile_id=${str_index}
         Execute Egate Command    bler_testmode_nr delete=true profile_id=${str_index}
    END

UE3 attach cell12 and scell release due to BadRlq
    SA UE Attach
    Sent Throughput
    Wait Until Keyword Succeeds    30s    5s    Check Traffic
    Trigger scell bad RLQ for scell
    sleep    25s    #sleep for sCellExcludelistTimerFr1 timer to prevent Cell-1 Cell-2.DL buffer monitoring send, but no CA add trigger.
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell
    ADD QOS in same pdu
    Wait Until Keyword Succeeds    30s    5s    Check Traffic

case recover BA13
    Recover scell bad RLQ
    Common Test Teardown And Stop Capture Logs

case recover BA1617
    OnlineParamChange    ${OnlineParam_BA1617_recover}
    Common Test Teardown And Stop Capture Logs

UE PDU Session Setup with multiple Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=12    ${qos_id}=4    ${qos_id_default}=1    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_id_default} default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${pass_regexp}
    Execute Egate Command    smf_param id=1 reset

Stop traffic
    [Arguments]    ${ue_id}=81    ${pdu}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu}    pass_regexp=Stopped Downlink Internal traffic on Ue:${ue_id}

Check Traffic for different DRB
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${cell_num}=2    ${dl}=300
    Sent Throughput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    Wait Until Keyword Succeeds    40s    5s    Check Traffic    ue_id=${ue_id}    cell_num=${cell_num}    dl=${dl}
    Stop traffic    ue_id=${ue_id}    pdu=${pdu_id}

UE1 traffic check and add DRB3
    Check Traffic for different DRB    qfi_id=1
    Check Traffic for different DRB    qfi_id=2
    Sent Throughput    ue_id=81    pdu_id=1    qfi_id=1
    Sent Throughput    ue_id=81    pdu_id=1    qfi_id=2
    ADD QOS in same pdu    qos_id=3    pass_regexp=${5QI8_add}
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell

UE2 add DRB3 and check traffic
    ADD QOS in same pdu    ue_id=82    qos_id=3    pass_regexp=${5QI8_add}
    Check Traffic for different DRB    ue_id=82    qfi_id=1
    Check Traffic for different DRB    ue_id=82    qfi_id=2
    Check Traffic for different DRB    ue_id=82    qfi_id=3

Delete QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=3    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

UE1 delete DRB3 then add DRB3 And Check Traffic
    Delete QOS in same pdu    qos_id=3    pass_regexp=${5QI8_del_BA17}
    sleep    2s
    ADD QOS in same pdu    qos_id=3    pass_regexp=${5QI8_add_BA17}
    Sent Throughput
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell

UE2 release DRB2 then add DRB4 And Check Traffic
    [Arguments]    ${ue_id}=82    ${pdu_id}=1    ${qos_id_add}=4    ${qos_id_del}=2    ${pass_regexp}=${5QI7_9_BA17}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id_del} qosflows_to_add=${qos_id_add} by=amf
    ...    pass_regexp=${pass_regexp}
    Sent Throughput    ue_id=${ue_id}    qfi_id=2
    Wait Until Keyword Succeeds    40s    5s    Verify Throughput pcell    ue_id=${ue_id}    dl=30
