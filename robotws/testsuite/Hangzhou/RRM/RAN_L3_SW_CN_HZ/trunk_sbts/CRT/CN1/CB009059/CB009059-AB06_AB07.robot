*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_BOO_AP_LOO
...            owner-Tingjian.Mao    team-CN1ET    release-SBTS24R2
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{NRCELL_12_NRREL}
...    @{PARAMS_FOR_9059}
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
...    NRCELL:actCDrx=false
...    NRCELL:actAperCsi=false
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRCELL:pucchModeSelect=longPucch
...    NRBTS:actFdmScheduling=true
...    NRBTS:actFdmEnhancedScheduling=true
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity

@{NRCELL_12_NRREL}
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
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
...    NRBTS/NRDRB-18:queuingDelayDiscarding=Controlled Delay (CoDel)
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

@{5QI6_SCELL_check}
...    Setup QosFlow with QFI:1 5QI:6
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{5QI6_7_SCELL_check}
...    Setup QosFlow with QFI:1 5QI:6
...    Setup QosFlow with QFI:2 5QI:7
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{add_5QI9}
...    Added QosFlow with QFI:2 fiveQI:9
...    QoS Routing Table

@{add_5QI7}
...    Added QosFlow with QFI:3 fiveQI:7
...    QoS Routing Table

@{add_5QI9_PDU2}
...    Setup QosFlow with QFI:1 5QI:9
...    QoS Routing Table

@{add_5QI7_PDU3}
...    Setup QosFlow with QFI:1 5QI:7
...    QoS Routing Table

@{5QI9_71_check}
...    PduId 2 Created FiveQi:Qfi mapping fiveQi 9 qfi 1
...    PduId 2 Created FiveQi:Qfi mapping fiveQi 71 qfi 2
...    QoS Routing Table

@{5QI_modify_check}
...    Removed FiveQi:Qfi mapping fiveQi 6 qfi 1
...    Added QosFlow with QFI:3 fiveQI:9
...    QoS Routing Table

@{5QI_modify_check_2}
...    Removed FiveQi:Qfi mapping fiveQi 9 qfi 1
...    Added QosFlow with QFI:2 5QI:6
...    QoS Routing Table

@{del_5QI7_9}
...    Removed FiveQi:Qfi mapping fiveQi 7 qfi 3
...    Removed FiveQi:Qfi mapping fiveQi 9 qfi 2
...    rrcReconfigurationComplete

@{5QI9_scell_check}
...    Setup QosFlow with QFI:1 5QI:9
...    QoS Routing Table
...    SCellIndex 1 activated successfully at airphone
...    SCellIndex 2 activated successfully at airphone

@{5QI6_71_check}
...    FiveQi:Qfi mapping fiveQi 6 qfi 1
...    FiveQi:Qfi mapping fiveQi 71 qfi 2
...    QoS Routing Table

@{PM_Counters_AB06}
...    NRCELL-12:${DL_RRC_FSCELL_REL_ATT_SA}=0
...    NRCELL-12:${DL_RRC_FSCELL_REL_SUC_SA}=0
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=1
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=0

@{PM_Counters_AB07}
...    NRCELL-12:${DL_RRC_FSCELL_REL_ATT_SA}=1
...    NRCELL-12:${DL_RRC_FSCELL_REL_SUC_SA}=1
...    NRCELL-12:${SCELL_ADDN_ALLOW_DRB_PRFL_CA}=2
...    NRCELL-12:${SCELL_ADDN_PREVENT_DRB_PRFL_CA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_ATT_SA}=0
...    NRCELL-12:${INCMP_DRB_STP_REL_SCELL_SUC_SA}=0
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_ATT_SA}=2
...    NRCELL-12:${ELIGIBLE_DRB_REL_SCELL_SUC_SA}=2

${DL_RRC_FSCELL_REL_ATT_SA}    M55118C00042    #The number of DL Full SCell Release attempts on PCell for SA
${DL_RRC_FSCELL_REL_SUC_SA}    M55118C00043    #The number of successful DL Full SCell Release attempts on PCell for SA
${SCELL_ADDN_ALLOW_DRB_PRFL_CA}    M55125C00039    #Number of times SCell addition is allowed for a UE due to DRB profile-based CA
${SCELL_ADDN_PREVENT_DRB_PRFL_CA}    M55125C00040    #Number of times SCell addition is prevented for a UE due to DRB profile-based CA
${INCMP_DRB_STP_REL_SCELL_ATT_SA}    M55118C00034    #Number of SCells to be released on PCell due to addition of CA-incompatible DRB for SA
${INCMP_DRB_STP_REL_SCELL_SUC_SA}    M55118C00035    #Number of SCells released on PCell due to addition of CA-incompatible DRB for SA
${ELIGIBLE_DRB_REL_SCELL_ATT_SA}    M55118C00036    #Number of SCells to be released on PCell due to release of the last CA-eligible DRB
${ELIGIBLE_DRB_REL_SCELL_SUC_SA}    M55118C00037    #Number of SCells released on PCell due to release of the last CA-eligible DRB

${SA_Capa_3T3F}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C4700FB8D85181AC1184341020E9068036B64C558D0E
...    7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027C4
...    71E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B2ABB08873E238F11C7A067D813E
...    31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040E1E0
...    27FFC00001FFF000001700003802CF0F1300038820000042C040A83C28000E230000010B02B0F11800388200000C2C0AC3C28000E208000010
...    B02B0F13000388C0000042C0AC5C46000E208007104000028581587850001C4C00000C160562E2600071040038500000102C0AC5C4C000E230
...    00711800001058158B850001C41000E230000020B02B170A0003882001C41000004160562E26000710400388C0000082C0AC5C28000E230007
...    11800001058158B898001C46000E140000040B02B0F11800388C00000C2C0AC9C28000E14000710400388C001C4C00000E1617593850001C28
...    000E20800710400389800001C2C3F593850001C41000E2080071180038980000202C0BC1C28000012160205E0E2080000A0B0102F071180000
...    50580817838980000242C040803808D00A202640411740101150B428913639F0E14489B1CF870A244D8E7C3851226C73E1C28913639F0E2448
...    913639F0E14081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF811204081B1CF810A0
...    40D8E7C09502040810206CB5E1C8810204081B2D78722040810206CB5E1C089B1CF870206C00004081B000010206C0000001F1618C6318C631
...    8C6318C6318C6318DE82E003C00281C1401C0C02500700060240040603E0900200000001000002008000000040000080200000801000006008
...    0000400400002802001004010040000300200001C010008000000200002001000012008000030040000500200002C01000812048020000300C
...    E54D654D60A5606560CD60AD652D64CD602D606D6025604560ED0341000009652404000065949410000296525040000E594901000049652404
...    000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C96524040000C594900CD2A8BA5555
...    4AAAE95455058AA0B1541A2A94C55268AA031540A2A93555078A160178095028140A05028140A05028140A05028140A0502814002820201803
...    00801002101002008040300610080100202018030080600C10100C018040300610080100202018030080100220100C01804030060100C01820
...    2004010080100440100200404008010100C018040300601002004802004008080600C02018030080600C020040080040080300080600C3543E
...    00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A0

*** Test Cases ***
CB009059-ET-AB06_FTT_QoS_Flow_added_after_SCell_Addition
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    UE is in CA and a new QoS Flow is added and mapped to a new DRB which is FR1 CA eligible.
    ...    The gNB does not alter the UE CA configuration.
    ...    At least 4 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          UE81 3CC PCELL(cell-12) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...         Step A. PDU session be established during the UE ICS. DRB-1 are allocated in PDU session 1
    ...         Step B. ADD DRB-4 FR1 CA eligible in pdu1
    ...         Step C. ADD DRB-2 Not FR1 CA eligible in pdu1
    ...         Step D. Delete DRB-2 and DRB-4 in pdu1
    ...         Step E. ADD DRB-4 FR1 CA eligible in pdu2
    ...         Step F. ADD DRB-2 Not FR1 CA eligible in pdu3
    ...         Step G. Release pdu2
    ...         Step H. UE is released and check counters
    ...    3. Expected Results:
    ...         Step A: DRBs setup successful,The gNB configures the UE with 3CC,DRB-1 non-GBR DL data is scheduled on
    ...                 the PCell and SCells
    ...         Step B: CA not released,The TP on the PCell and SCells (DRB-1 BRB-4)
    ...         Step C: CA not released,The TP on the PCell and SCells (DRB-1 BRB-4) only PCell (DRB-2)
    ...         Step D. CA not released,The TP on the PCell and SCells (DRB-1)
    ...         Step E. CA not released,The TP on the PCell and SCells (DRB-1 BRB-4)
    ...         Step F. CA not released,The TP on the PCell and SCells (DRB-1 BRB-4) only PCell (DRB-2)
    ...         Step G. CA not released,The TP on the PCell and SCells (BRB-4) only PCell (DRB-2)
    ...         Step H. UE is released and check counters successful
    [Tags]    QC_326391    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files  
    UE PDU Session Setup with Qosflow1
    Verify CA not released after ADD QOS in same pdu
    Verify CA not released after Delete DRB-2 and DRB-4 in pdu1
    Verify CA not released after ADD QOS in Another pdu
    Verify CA not released after Release pdu
    Sent Throughput    qfi_id=1
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270
    Release UEs    ue_type=all
    check counters    ${PM_Counters_AB06}

CB009059-ET-AB07_CA_not_released_after_a_Not_FR1_CA_eligible_GBR_DRB_is_setup_via_PDU_session_setup_or_PDU_session_modify
    [Documentation]
    ...    The purpose of this test case is to check following scenarios:
    ...    UE is in CA and a new QoS Flow is added and mapped to a new DRB which is FR1 CA eligible.
    ...    The gNB does not alter the UE CA configuration.
    ...    At least 5 NRBTS/NRDRB MOC instances are configured as non-GRB types:
    ...    NRDRB ID resType Value RLC Mode cellAggrLevel Value
    ...          1 non-GBR AM 0:FR1 CA eligible
    ...          2 non-GBR AM 1:Not FR1 CA eligible
    ...          3 non-GBR AM 2:FR1 CA incompatible
    ...          4 non-GBR AM 0:FR1 CA eligible
    ...          5 GBR     AM 1:Not FR1 CA eligible 5QI-71
    ...          UE81 3CC PCELL(cell-12) SCELLs(cell-1+cell-2)
    ...    2.Test Case Steps:
    ...         Step A. PDU session be established during the UE ICS. DRB-1 and DRB-2 are allocated in PDU session 1
    ...         Step B. ADD DRB-5 Not FR1 CA eligible and DRB-4 FR1 CA eligible in pdu2
    ...         Step C. ADD DRB-4 FR1 CA eligible and DEL DRB-1 FR1 CA eligible in pdu1
    ...         Step D. Release PDU2 DRB-5 and DRB-4
    ...         Step E. DEL DRB-4 FR1 CA eligible in pdu1
    ...         Step F. ADD DRB-4 FR1 CA eligible in pdu2
    ...         Step G. ADD DRB-5 Not FR1 CA eligible and DRB-1 FR1 CA eligible in pdu3
    ...         Step H. Release PDU3 DRB-5 and DRB-1
    ...         Step I. ADD DRB-1 FR1 CA eligible and DEL DRB-4 FR1 CA eligible in pdu2
    ...         Step J. UE is released and check counters
    ...    3. Expected Results:
    ...         Step A: DRBs setup successful,The gNB configures the UE with 3CC,The TP on the PCell and SCells
    ...                 (DRB-1 PDU1) only PCell (DRB-2 PDU1)
    ...         Step B: CA not released,The TP on the PCell and SCells (DRB-1 PDU1 DRB-4 PDU2) only PCell (DRB-2 PDU1 DRB-5 PDU2)
    ...         Step C: CA not released,The TP on the PCell and SCells (DRB-4 PDU1+2) only PCell (DRB-2 PDU1 DRB-5 PDU2)
    ...         Step D. CA not released,The TP on the PCell and SCells (DRB-4 PDU1) only PCell (DRB-2 PDU1)
    ...         Step E. CA released,The TP only PCell (DRB-2 PDU1)
    ...         Step F. UE 3CC,The TP on the PCell and SCells (DRB-4 PDU2) only PCell (DRB-2 PDU1)
    ...         Step G. CA not released,The TP on the PCell and SCells (DRB-1 PDU3 BRB-4 PDU2) only PCell (DRB-2 PDU1 DRB-5 PDU3)
    ...         Step H. CA not released,The TP on the PCell and SCells (BRB-4 PDU2) only PCell (DRB-2 PDU1)
    ...         Step I. CA not released,The TP on the PCell and SCells (BRB-1 PDU2) only PCell (DRB-2 PDU1)
    ...         Step J. UE is released and check counters successful
    [Tags]    QC_46719    AB07    CA_LABEL-FTT(10Mhz_FDD_n71+60Mhz_TDD_n41+60Mhz_TDD_n41)
    clear counter files
    UE PDU Session Setup with multiple Qosflow    qos_id=2    pass_regexp=${5QI6_7_SCELL_check}
    Verify CA not released after ADD multiple QOSs in Another pdu
    Verify CA not released after modify DRBS in pdu1 and Release pdu2
    Verify CA released after DEL the last eligible QOS in same pdu
    Verify CA not released after ADD QOS
    Verify CA not released after Release pdu3 and modify DRBS
    Release UEs    ue_type=all
    check counters    ${PM_Counters_AB07}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/7cells_3T4F_8pipes

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_3T3F} nr_usage_setting=voice_centric
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

Verify CA not released after ADD QOS in same pdu
    Verify UE status after ADD QOS in same pdu    qos_id=4    pass_regexp=${add_5QI9}
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270
    stop Throughput
    Sent Throughput    qfi_id=2
    Verify Throughput pcell and scells    qfi_id=2    Tput_dl=270
    Verify UE status after ADD QOS in same pdu    qos_id=2    pass_regexp=${add_5QI7}
    Verify Throughput pcell and scells    qfi_id=2    Tput_dl=270
    stop Throughput
    Sent Throughput    qfi_id=3
    Verify Throughput pcell and no TP in scells    qfi_id=3

Verify CA not released after ADD QOS in Another pdu
    Verify UE status after ADD QOS in Another pdu    qos_id=4    pdu_id=2    pass_regexp=${add_5QI9_PDU2}
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270
    stop Throughput
    Sent Throughput    pdu_id=2    qfi_id=1
    Verify Throughput pcell and scells    pdu_id=2    qfi_id=1    Tput_dl=270
    Verify UE status after ADD QOS in Another pdu    qos_id=2    pdu_id=3    gw_id=3    pass_regexp=${add_5QI7_PDU3}
    Verify Throughput pcell and scells    pdu_id=2    qfi_id=1    Tput_dl=270
    stop Throughput    pdu_id=2
    Sent Throughput    pdu_id=3    qfi_id=1
    Verify Throughput pcell and no TP in scells    pdu_id=3    qfi_id=1

Verify CA not released after Delete DRB-2 and DRB-4 in pdu1
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2,4 by=amf    pass_regexp=${del_5QI7_9}
    Sent Throughput    qfi_id=1
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270

Verify CA not released after Release pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=2
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf    pass_regexp=rrcReconfigurationComplete


Verify CA not released modify DRBS
    [Arguments]    ${ue_id}=81    ${pdu_id}=2    ${add_id}=1    ${del_id}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${add_id} qosflows_to_del=${del_id} by=amf
    ...    pass_regexp=${pass_regexp}

UE PDU Session Setup with Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=12
    ${cmd}    catenate    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    amf_param id=1 send_ics_registration=on
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ${cmd}    pass_regexp=${5QI6_SCELL_check}
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0

UE PDU Session Setup with Qosflow1
    UE PDU Session Setup with Qosflow
    Sent Throughput    qfi_id=1
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270

UE PDU Session Setup with multiple Qosflow
    [Arguments]    ${ue_id}=81    ${cell_id}=12    ${qos_id}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    amf_param id=1 send_ics_registration=off
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Register
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    pass_regexp=${pass_regexp}
    Execute Egate Command    csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=csi_override action=activate profile_id=1 scell=0
    Verify TP for two Qosflow

Verify UE status after ADD QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=3    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Verify UE status after DEL QOS in same pdu
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qos_id}=4    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_del=${qos_id} by=amf
    ...    pass_regexp=${pass_regexp}

Verify UE status after ADD QOS in Another pdu
    [Arguments]    ${qos_id}=1    ${ue_id}=81    ${pdu_id}=2    ${gw_id}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    smf_param id=1 reset
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1
    ...    pass_regexp=${pass_regexp}

Verify UE status after ADD multiple QOSs in Another pdu
    [Arguments]    ${qos_id}=4    ${qos_add}=5    ${ue_id}=81    ${pdu_id}=2    ${gw_id}=2    ${pass_regexp}=QoS Routing Table
    Execute Egate Command    qosflow_modify qos_flow=${qos_id} default=on
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${qos_add}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=1
    ...    pass_regexp=${pass_regexp}

Sent Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=1    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl mbps=170 trf_id=2    pass_regexp=Started Downlink
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul mbps=30 trf_id=1    pass_regexp=Started Uplink

stop Throughput
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=${pdu_id}    pass_regexp=Traffic was stopped

Verify Throughput pcell and scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=150    ${Tput_ul}=0    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=ave
    Should Be True    ${scell2_tput}/1000 > 0

Verify Throughput pcell and no TP in scells
    [Arguments]    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=1    ${Tput_dl}=30    ${Tput_ul}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=1    type=pdsch    rate_type=current
    Should Be True    ${scell1_tput}/1000 == 0
    ${scell2_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=2    type=pdsch    rate_type=current
    Should Be True    ${scell2_tput}/1000 == 0

Verify no Scell
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi_id}=1    ${Tput_dl}=30    ${Tput_ul}=27    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi_id}    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Not Match Regexp    ${scell_tput}    CellIndex-[2]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify TP for two Qosflow
    Sent Throughput    qfi_id=2
    Verify Throughput pcell and no TP in scells    qfi_id=2
    stop Throughput
    Sent Throughput    qfi_id=1
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270

Verify CA not released after ADD multiple QOSs in Another pdu
    Verify UE status after ADD multiple QOSs in Another pdu    pass_regexp=${5QI9_71_check}
    Verify Throughput pcell and scells    qfi_id=1    Tput_dl=270
    stop Throughput
    Sent Throughput    pdu_id=2    qfi_id=2
    Verify Throughput pcell and no TP in scells    pdu_id=2    qfi_id=2
    stop Throughput    pdu_id=2
    Sent Throughput    pdu_id=2
    Verify Throughput pcell and scells    pdu_id=2    Tput_dl=270
    stop Throughput    pdu_id=2

Verify CA not released after modify DRBS in pdu1 and Release pdu2
    Verify CA not released modify DRBS    pdu_id=1    add_id=4    del_id=1    pass_regexp=${5QI_modify_check}
    Sent Throughput    qfi_id=3
    Verify Throughput pcell and scells    qfi_id=3    Tput_dl=270
    Verify CA not released after Release pdu    pdu_id=2
    Verify Throughput pcell and scells    qfi_id=3    Tput_dl=270

Verify CA released after DEL the last eligible QOS in same pdu
    Verify UE status after DEL QOS in same pdu
    Sent Throughput    qfi_id=2
    Verify no Scell    qfi_id=2
    stop Throughput

Verify CA not released after ADD QOS
    Verify UE status after ADD QOS in Another pdu    qos_id=4    pdu_id=2    pass_regexp=${5QI9_scell_check}
    Sent Throughput    pdu_id=2
    Verify Throughput pcell and scells    pdu_id=2    Tput_dl=270
    stop Throughput    pdu_id=2
    Verify UE status after ADD multiple QOSs in Another pdu    qos_id=1    qos_add=5    pdu_id=3    gw_id=3    pass_regexp=${5QI6_71_check}
    Sent Throughput    pdu_id=3    qfi_id=2
    Verify Throughput pcell and no TP in scells    pdu_id=3    qfi_id=2
    stop Throughput    pdu_id=3
    Sent Throughput    pdu_id=3    qfi_id=1
    Verify Throughput pcell and scells    pdu_id=3    qfi_id=1    Tput_dl=270

Verify CA not released after Release pdu3 and modify DRBS
    Verify CA not released after Release pdu    pdu_id=3
    Sent Throughput    pdu_id=2
    Verify Throughput pcell and scells    pdu_id=2    Tput_dl=270
    stop Throughput    pdu_id=2
    Verify CA not released modify DRBS    pdu_id=2    add_id=1    del_id=4    pass_regexp=${5QI_modify_check_2}
    Sent Throughput    pdu_id=2    qfi_id=2
    Verify Throughput pcell and scells    pdu_id=2    qfi_id=2    Tput_dl=270
