*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    owner-zora.wang    owner-ha.zheng    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CA_NRREL}
...    @{PARAMS_FOR_9059}
...    @{PARAMS_FOR_CA}
...    @{8124_related_modification}
...    @{PARAMS_FOR_VoNR}

${CaSup}    ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Fdd_Sa_WithUl,ca_Fdd_Fr1Tdd_Sa_WithUl

@{PARAMS_FOR_9059}
...    NRBTS/NRDRB-10:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-11:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-12:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB-13:cellAggrLevel=FR1 CA incompatible
...    NRBTS/NRDRB-14:cellAggrLevel=FR1 CA eligible
...    NRBTS/NRDRB-15:cellAggrLevel=FR1 CA incompatible
...    NRBTS:actDrbProfileForCellAggrLevel=FR1_SA
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:rlcMode=RLC_UM

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false
...    NRULCLPC_PROFILE-1:nrUlClpcProfileId=1
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actNonVoNRGbrService=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRBTS:actDrbDrx=true
...    NRBTS/NRDRB-10:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRBTS/NRDRB-11:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-4
...    NRBTS/NRDRX-4:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-4:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-4:drxInactivityTimer=40ms
...    NRBTS/NRDRX-4:drxLongCycle=80ms
...    NRBTS/NRDRX-4:drxOnDurationTimer=60ms
...    NRBTS/NRDRX-4:drxPriority=16
...    NRBTS/NRDRX-4:drxRetransTimerDl=16slot
...    NRBTS/NRDRX-4:drxRetransTimerUl=16slot
...    NRBTS/NRDRX-5:drxHarqRttTimerDl=0symbols
...    NRBTS/NRDRX-5:drxHarqRttTimerUl=0symbols
...    NRBTS/NRDRX-5:drxInactivityTimer=6ms
...    NRBTS/NRDRX-5:drxLongCycle=40ms
...    NRBTS/NRDRX-5:drxOnDurationTimer=20ms
...    NRBTS/NRDRX-5:drxRetransTimerDl=0slot
...    NRBTS/NRDRX-5:drxRetransTimerUl=0slot
...    NRBTS/NRDRX-5:drxPriority=2
...    NRCELL:actUlClosedLoopPwrCtrl=puschSrs
...    NRCELL:nrUlClpcProfileDN=NRULCLPC_PROFILE-1
...    NRCELL:srPeriodicity=slots40
...    NRCELL:actVoipPacketAggr=true
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    NRCELL:actGBRAdmissionControl=GBRService
...    NRCELL:maxNumOfGBRBearersSA=10

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB_MAC-4:lcgid=0
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_PDCP-2:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-2:tReorderingUl=ms100
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16

@{PARAMS_FOR_5QI1}
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:discardTimer=10ms
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40
...    NRBTS/NRDRB-15:nrDrxDN=MRBTS-1/NRBTS-1/NRDRX-5

@{8124_related_modification}
...    NRCELL:actUlCgType2=true
...    NRBTS/NRDRB-13:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-1
...    NRBTS/NRDRB-14:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2
...    NRBTS/NRDRB-15:nrDrbUlCgDN=MRBTS-1/NRBTS-1/NRULCG_PROFILE-2
...    NRBTS/NRULCG_PROFILE-1:grantedPacketSize=40
...    NRBTS/NRULCG_PROFILE-1:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-1:periodicity=ms2
#...    NRBTS/NRULCG_PROFILE-1:skipUplinkTxConfigured=true
...    NRBTS/NRULCG_PROFILE-2:grantedPacketSize=80
...    NRBTS/NRULCG_PROFILE-2:maxNumPrbs=4
...    NRBTS/NRULCG_PROFILE-2:periodicity=ms5
#...    NRBTS/NRULCG_PROFILE-2:skipUplinkTxConfigured=true
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumPrbs=40
...    NRCELL:ulConfiguredGrantType2:ulCgMaxNumUeUl=1
...    NRCELL:ulConfiguredGrantType2:ulCgPrbStartOffset=0
...    NRCELL-11:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-12:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-13:ulConfiguredGrantType2:ulCgMaxNumPrbs=4
...    NRCELL-14:ulConfiguredGrantType2:ulCgMaxNumPrbs=4

@{PARAMS_FOR_CA}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRCELL:maxNumScellsDlFr1=4
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CaSup}
...    NRCELL:actAperCsi=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{CA_NRREL}
...    NRCELL:timingAdvanceOffset=n25600
...    NRCELL-1:increasePUSCHPrepTimeULCA=true
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:nrDcAllowed=false
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlAndUl
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:handoverAllowedSARedCap=forbidden
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:nrDcAllowed=false
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3

${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039
#This counter shows the number of times SCell addition is allowed for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040
#This counter shows the number of times SCell addition is prevented for a UE due to data radio bearer (DRB) profile-based Carrier Aggregation.
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034
# This counter measures the number of SCells to be released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035
#This counter measures the number of SCells released due to the addition of a CA-incompatible data radio bearer (DRB) in the PCell for SA.
${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042
#This counter measures the number of full SCell release attempts in DL in the PCell for SA. It considers only full SCell
#releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043
#This counter measures the number of successful full SCell release attempts in DL in the PCell for SA. It considers only full
#SCell releases, partial SCell releases aren't counted. It considers both local SCells and ext-SCells.
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036
#This counter measures the number of SCells to be released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037
#This counter measures the number of SCells released due to the release of the last CA-eligible data radio bearer (DRB) in the PCell for SA.

${SA_Capa_3T3F_cg2}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D
...    0E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0600E0008400C0541B107582308682041E20D00656C98A
...    B121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD80000017018038002100301546C4CD608C21A0810748340185B262A8
...    8873E238F11C7A067D813E31CF9863CA1607FFFF82E007FE003801FF8002E030070004200602B8F88DAC1184341020F941A00AAD93156143
...    9F11C78C00000000000000000040E1E027FFC00001FFF00000170180380021003002CF0F1300038820000042C040A83C28000E230000010B
...    02B0F11800388200000C2C0AC3C28000E208000010B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C
...    160562E2600071040038500000102C0AC5C4C000E23000711800001058158B850001C41000E230000020B02B170A0003882001C410000041
...    60562E26000710400388C0000082C0AC5C28000E23000711800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C2
...    8000E14000710400388C001C4C00000E1617593850001C28000E20800710400389800001C2C3F593850001C41000E2080071180038980000
...    202C0BC1C28000012160205E0E2080000A0B0102F07118000050580817838980000242C040803808D00A202640411740101150B428913639
...    F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811
...    204081B1CF811204081B1CF811204081B1CF811204081B1CF810A040D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E
...    1C089B1CF870206C00004081B000010206C0000001F1618C6318C6318C6318C6318C6318DE82E003C00281C1401C0C025007000602400406
...    03E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C0100080000002
...    00002001000012008000030040000500200002C01000812048020000300CE54D654D60A5606560CD60AD652D64CD602D606D6025604560ED
...    0341000009652404000065949410000296525040000E594901000049652404000165949010000696524040001E5949010000896524040002
...    65949010000A96524040002E5949410000C96524040000C594900CD2A8BA55554AAAE95455058AA0B1541A2A94C55268AA031540A2A93555
...    078A160178095028140A05028140A05028140A05028140A05028140028202018030080100210100200804030061008010020201803008060
...    0C10100C018040300610080100202018030080100220100C01804030060100C018202004010080100440100200404008010100C018040300
...    601002004802004008080600C02018030080600C020040080040080300080600C3543E00020406080C0E1416181A2022242628303236383A
...    3E424A4C4E5052545A5E828305A0

@{FTT_CA}
...    rrcReconfigurationComplete
...    frequencyBandList.*\{.*41.*\}\.:::2
...    pcid:50, scellIdx:1] configure_1_1
...    pcid:50, scellIdx:1] configure_0_1
...    pcid:51, scellIdx:2

@{drx}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms60
...    drx-InactivityTimer ms40
...    skipUplinkTxDynamic FALSE
...    enhancedSkipUplinkTxConfigured-r16 true

@{drx_vonr}
...    drx-Config setup
...    drx-onDurationTimer milliSeconds : ms20
...    drx-InactivityTimer ms6
...    skipUplinkTxDynamic FALSE
...    enhancedSkipUplinkTxConfigured-r16 true

@{add_drb1_FTT_CA}
...    QFI:1 5QI:6
...    @{FTT_CA}
...    @{drx}

@{add_drb3_release_CA_setup_cg2}
...    QoS Routing Table
...    QFI:2 fiveQI:8
...    sCellToReleaseList.*\{.*1,.*2.*\}\.
...    PDU SESSION RESOURCE MODIFY RESPONSE
...    configuredGrantConfig setup

@{del_drb3_FTT_CA_release_cg2}
...    @{FTT_CA}
...    configuredGrantConfig release : NULL

@{add_pdu2_drb2}
...    QoS Routing Table
...    QFI:1 5QI:5
...    PDUSessionId:2
...    Pdu Session Resource Setup Response

@{del_pdu1_drb1_or_drb4_release_CA}
...    PDU SESSION RESOURCE RELEASE RESPONSE
...    sCellToReleaseList.*\{.*1,.*2.*\}\.

@{add_pdu1_drb4_FTT_CA_setup_cg2}
...    QoS Routing Table
...    QFI:1 5QI:9
...    PDUSessionId:1
...    @{FTT_CA}
...    configuredGrantConfig setup

@{add_pdu3_drb2_drb5_release_CA_release_cg2}
...    QoS Routing Table
...    QFI:1 5QI:5
...    QFI:2 5QI:1
...    PDUSessionId:3
...    drx-Config release : NULL
...    configuredGrantConfig release : NULL
...    sCellToReleaseList.*\{.*1,.*2.*\}\.
...    PDU SESSION RESOURCE SETUP RESPONSE
...    @{drx_vonr}

@{del_pdu3_drb5_FTT_CA_setup_cg2}
...    drx-Config release : NULL
...    configuredGrantConfig setup
...    @{FTT_CA}
...    @{drx}

@{add_pdu3_drb5_failed}
...    PDU Session Resource Modify Unsuccessful Transfer
...    QFI:2 5QI:1
...    PDU SESSION RESOURCE MODIFY RESPONSE

@{BG002_2}
...    NRCELL:maxNumOfGBRBearersSA=10

@{BG002_1}
...    NRCELL:maxNumOfGBRBearersSA=0

@{PM_Counters_BG002}
...    NRCELL-11:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=5
...    NRCELL-11:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=2
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=6
...    NRCELL-11:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=6
...    NRCELL-11:${DL_RRC_FSCELL_REL_ATT_SA}=4
...    NRCELL-11:${DL_RRC_FSCELL_REL_SUC_SA}=4
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=6
...    NRCELL-11:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=6

*** Test Cases ***
CB009059-ET-BG02_Interaction_with_UL_Configured_Grant_Type_2_during_PDU_Session_Resource_Modify
    [Documentation]
    ...    1.The purpose of this test case is to check following scenarios:
    ...      This user scenario validates that when no CA eligible DRBs remain for a UE configured with ext-SCells,
    ...      CA is released. After a PDU session release procedure FR1 CA eligible DRB are removed for the UE and no
    ...      CA eligible DRB session remains. CA is released for the UE.
    ...      USCB008124-C#B4 (Successful CG Type 2 configuration setup for the one or more bearers (associated with CG) setup with 
    ...      PDU Session Modify which adds one or more QoS flow(s))
    ...      USCB008124-H#IWK1 (CG Type2 released for UE for which VoNR (5QI-1) bearer is being setup)
    ...      USCB009059-BG#B8: Interaction with UL Configured Grant Type 2 during PDU Session Resource Modify (CB008124)
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value Priority (nrUlCgProfileId) DRB associated with CG for 5QI
    ...           1 non-GBR AM        0:FR1 CA eligible        any    NO
    ...           2 non-GBR(5qi-5) AM 1:Not FR1 CA eligible    any    NO
    ...           3 non-GBR AM        2:FR1 CA incompatible    any    Yes
    ...           4 non-GBR AM        0:FR1 CA eligible        any    Yes
    ...           5 GBR(5qi-1) UM     2:FR1 CA incompatible    any    Yes
    ...    2.Test Case Steps:
    ...         Step A. UE81 attaches to Cell-11 and setup DRB-1 during ICS procedure then sent Throughput
    ...         Step B. UE81 add DRB-3 in PDU1
    ...         Step C. UE81 delete DRB-3 in PDU1
    ...         Step D. UE81 add DRB-2 in PDU2
    ...         Step E. UE81 delete DRB-1 in PDU1
    ...         Step F. UE81 add DRB-4 in PDU1
    ...         Step G. UE81 delete DRB-4 in PDU1
    ...         Step H. UE81 add DRB-4 in PDU1
    ...         Step I. UE81 add DRB-2 and DRB5 in PDU3
    ...         Step J. UE81 delete DRB-5 in PDU3
    ...         Step K. online change NRCELL.maxNumOfGBRBearersSA=0, UE81 add DRB-5 in PDU3
    ...         Step L .Released all UE and check counters
    ...    3. Expected Results:
    ...         Step A: UE81 attaches to Cell-11 successfully, no CG Type 2 configuration setup,
    ...                 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...         Step B: UE81 DRB-3 add successful, CG Type 2 are setup for the UE, ALL CC released
    ...         Step C: UE81 DRB-3 delete successful, CG Type 2 are release for the UE,
    ...                 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...         Step D. UE81 DRB-2 add successful, no CG Type 2 configuration setup
    ...         Step E. UE81 delete DRB-1 successful, ALL CC released
    ...         Step F. UE81 DRB-4 add successful, CG Type 2 are setup for the UE,
    ...                 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...         Step G. UE81 delete DRB-4 successful, ALL CC released
    ...         Step H. UE81 DRB-4 add successful, CG Type 2 are setup for the UE,
    ...                 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...         Step I. UE81 add DRB-2 and DRB5 successful, CG Type 2 are release for the UE, ALL CC released
    ...         Step J. UE81 delete DRB-5 successful, CG Type 2 are setup for the UE,
    ...                 3CC CA to the UE with Cell-1(ul and dl) and Cell-2 as the SCells
    ...         Step K. online change successful, UE81 add DRB-5 failed
    ...         Step L .Released all UE and check counters successful
    [Tags]    QC_349226    BG002    DL_CA_LABEL-FTT(10MHZ_FDD_n71+60MHZ_TDD_n41+60MHZ_TDD_n41)    UL_CA_LABEL-FT(10Mhz_FDD_n71+60Mhz_TDD_n41)
    clear counter files    wait=${False}
    UE setup DRB-1 during ICS
    UE add DRB-3 then del DRB-3
    UE add PUD2 DRB-2 then del DRB-1 add DRB-4
    UE del DRB-4 then add DRB-4
    UE add PDU3 DRB-2 DRB5 then del DRB-5
    OnlineParamChange    ${BG002_1}
    ADD QOS in same pdu    pdu_id=3    qos_id=5    pass_regexp=${add_pdu3_drb5_failed}    fail_regexp=configuredGrantConfig release : NULL
    Release UEs    ue_type=all
    check counters    pm_counters_expression=${PM_Counters_BG002}
    [Teardown]    case recover BG002

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir

Modify Cfg
    Update Cfg    ue_param id=81,82,83,84 ue_nr_capabilities=${SA_Capa_3T3F_cg2} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=81,82,83,84 voice_over_nr=on:on:off
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=8
    Update Cfg    set_qosflow id=4 5qi=9
    Update Cfg    set_qosflow id=5 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 qos_flows=1,2,3,4,5 qos_rules=1,2 default=on ue=1-6 amf=1

UE setup DRB-1 during ICS
    UE PDU Session Setup with Qosflow    ue_id=81    cell_id=11    qos_id=1    pass_regexp=${add_drb1_FTT_CA}
    ...    fail_regexp=configuredGrantConfig setup
    Sent Throughput
    Verify Throughput pcell and scells

UE add DRB-3 then del DRB-3
    ADD QOS in same pdu    pdu_id=1    qos_id=3    pass_regexp=${add_drb3_release_CA_setup_cg2}
    Delete QOS in same pdu    pdu_id=1    qos_id=3    pass_regexp=${del_drb3_FTT_CA_release_cg2}
    Verify Throughput pcell and scells

UE add PUD2 DRB-2 then del DRB-1 add DRB-4
    Verify UE status after ADD QOS in Another pdu    de_qos_id=2    pdu_id=2    gw_id=2    pass_regexp=${add_pdu2_drb2}
    ...    fail_regexp=configuredGrantConfig setup
    Verify Throughput pcell and scells
    Verify UE status after DEL QOS in Another pdu    pdu_id=1    pass_regexp=${del_pdu1_drb1_or_drb4_release_CA}
    Verify UE status after ADD QOS in Another pdu    de_qos_id=4    pdu_id=1    gw_id=1    pass_regexp=${add_pdu1_drb4_FTT_CA_setup_cg2}
    Sent Throughput
    Verify Throughput pcell and scells

UE del DRB-4 then add DRB-4
    Verify UE status after DEL QOS in Another pdu    pdu_id=1    pass_regexp=${del_pdu1_drb1_or_drb4_release_CA}
    Verify UE status after ADD QOS in Another pdu    de_qos_id=4    pdu_id=1    gw_id=1    pass_regexp=${add_pdu1_drb4_FTT_CA_setup_cg2}
    Sent Throughput
    Verify Throughput pcell and scells

UE add PDU3 DRB-2 DRB5 then del DRB-5
    ADD multiple QOS in same pdu    pass_regexp=${add_pdu3_drb2_drb5_release_CA_release_cg2}
    Delete QOS in same pdu    pdu_id=3    qos_id=5    pass_regexp=${del_pdu3_drb5_FTT_CA_setup_cg2}
    Verify Throughput pcell and scells

Sent Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${times}=4
    FOR    ${I}    IN RANGE    1    ${times}+1
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=150 trf_id=${I}    UE ${ue_id}: UDP DL
    END
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=100 trf_id=1    UE ${ue_id}: UDP UL

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=570    ${Tput_ul}=80    ${cell_num}=2    ${sleep_time}=15s
    ${scell_t}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    Throughput
    sleep    ${sleep_time}    sleep for Tput stable
    ${total_dl_tput}    Set Variable    0
    FOR    ${index}    IN RANGE    0    ${cell_num}+1
         ${str_index}    Convert To String    ${index}
         ${scell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${str_index}    type=pdsch    rate_type=ave
         Should Be True    ${scell_tput}/1000 > 0
         ${total_dl_tput}    Evaluate    ${scell_tput}+${total_dl_tput}
    END
    Should Be True    ${total_dl_tput}/1000 > ${Tput_dl}
    ${scell0_tput_u}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${scell0_tput_u}/1000 > 0
    ${scell1_tput_u}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pusch    rate_type=ave
    Should Be True    ${scell1_tput_u}/1000 > 0
    Should Be True    (${scell0_tput_u}+${scell1_tput_u})/1000>${Tput_ul}

UE PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${qos_id}=1    ${gw}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=3 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw}
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}
    Execute Egate Command    smf_param id=1 reset
    Sent Throughput    ue_id=${ue_id}

Verify UE status after ADD QOS in Another pdu
    [Arguments]    ${ue_id}=81    ${de_qos_id}=3    ${pdu_id}=2    ${gw_id}=2    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    qosflow_modify qos_flow=${de_qos_id} default=on
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Verify UE status after DEL QOS in Another pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=2    ${pass_regexp}=PDU SESSION RESOURCE RELEASE RESPONSE
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf
    ...    pass_regexp=${pass_regexp}

ADD multiple QOS in same pdu
    [Arguments]    ${ue_id}=81    ${default_qos_id}=2    ${qos_id}=5    ${pass_regexp}=Pdu Session Resource Setup Response
    ...    ${fail_regexp}=none
    Execute Egate Command    qosflow_modify qos_flow=${default_qos_id} default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_pdu_session_setup pdu=3 ue=${ue_id} nwslice=1 gw=3
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

ADD QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

Delete QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=1    ${pass_regexp}=QoS Routing Table    ${fail_regexp}=none
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}

case recover BG002
    OnlineParamChange    ${BG002_2}
    Common Test Teardown And Stop Capture Logs
