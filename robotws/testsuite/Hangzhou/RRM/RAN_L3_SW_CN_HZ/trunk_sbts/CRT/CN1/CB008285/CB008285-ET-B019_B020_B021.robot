*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G    RAN_5G_TDD    SBTS00    CRT    CLOUD_5G_I_LO_AP_LO
...            owner-Tingjian.Mao    team-SGT&A    release-SBTS23R4
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{32SSB}
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}
...    @{PARAMS_FOR_SECURITY}
...    @{PARAMS_FOR_OTHERS}
...    @{PARAMS_FOR_VCFB}
...    @{beamswitch}
...    @{PARAMS_FOR_7516}
...    @{CB008285_e_enable}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=251

@{beamswitch}
...    NRCELL:actRrcReconfigAtBeamSwitch=false

@{CB008285_e_enable}
...    NRCELL:rangeExtension=0-6.9km
...    NRBTS-1/NRCELLGRP-0:ssBurstSetPeriod=40
...    NRBTS-1/NRCELLGRP-1:ssBurstSetPeriod=40
...    NRCELL:prachConfigurationIndex=135
...    NRCELL:type0SearchSpaceConfigurationIndex=13
...    NRCELL:zeroCorrelationZoneConfig=0
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:inactiveSsbFr2=576733998676505104
...    NRCELL:numOfPagingFrames=oneEighthT
...    NRCELL:fPdcchMonOccsnPo=0
...    NRCELL:totalNumberOfRAPreambles=32
...    NRCELL:cbraPreamblesPerSsb=n32

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
...    NRBTS/NRDRB_MAC-4:lcgid=0
...    NRBTS/NRDRB_MAC-4:schedulPrio=4
...    NRBTS/NRDRB_PDCP-2:tReorderingDl=ms100
...    NRBTS/NRDRB_PDCP-2:tReorderingUl=ms100
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_AM-2:ulMaxRetxThreshold=t16

@{PARAMS_FOR_5QI1}
...    NRCELL-1:actVoNR=false
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-15
...    NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-3
...    NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS/NRDRB-15:dlFlowControlAlgo=none
...    NRBTS/NRDRB-15:dscp=0
...    NRBTS/NRDRB-15:maxDddsPeriodCpuOvld=40
...    NRBTS/NRDRB-15:numSduDiscard=1
...    NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    NRBTS/NRDRB-15:queuingDelaySduDiscardThreshold=200
...    NRBTS/NRDRB-15:resType=GBR
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB-15:discardTimer=150ms
...    NRBTS/NRDRB-15:maxRlcQueueingDelayGbr=20
...    NRBTS/NRDRB-15:maxTransferDelayGbr=20
...    NRBTS/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{PARAMS_FOR_SECURITY}
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=9
...    NRBTS:integrityProtPrefL:nia3_128=0

@{PARAMS_FOR_OTHERS}


...    NRBTS:drbInactivityTimerSA=${InactivityTimer}
...    NRBTS:srbInactivityTimerSA=${InactivityTimer}

@{PARAMS_FOR_VCFB}
...    NRBTS:actNormVCFallback=true
...    NRBTS:actRedirect=true
...    delete:NRCELL/NRREDRT-1:redirSsbScs
...    NRCELL/NRREDRT-1:redirRat=eutra
...    NRCELL/NRREDRT-1:redirFreqEutra=38000
...    NRCELL-1:voiceFBMode=redirection
...    NRCELL:a2MeasRedirectEnabled=rsrp
...    NRCELL:a2MeasRedirectSsbRsrp:a2ThresholdRedirectSsbRsrp=34
...    NRCELL:a2MeasRedirectSsbRsrp:a2HysteresisRedirectSsbRsrp=0
...    NRCELL:a2MeasRedirectSsbRsrp:a2TimeToTriggerRedirectSsbRsrp=ms480

@{PARAMS_FOR_7516}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionPriority=6
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionSubPriority=oDot8
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:dlCarrierFreq=430850
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:freqBandIndicatorNR=66
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:idleMMNrCelResWeight=11
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:ssbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionPriority=5
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionSubPriority=oDot2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:dlCarrierFreq=644140
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:freqBandIndicatorNR=77
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:idleMMNrCelResWeight=96
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:qOffsetFreq=-14dB
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:qRxLevMin=-60
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:ssbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:tReselectionNr=1
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXHighP=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:threshXLowP=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:cellReselectionPriority=3
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:cellReselectionSubPriority=oDot4
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:dlCarrierFreq=518430
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:freqBandIndicatorNR=41
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:idleMMNrCelResWeight=67
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:qOffsetFreq=-14dB
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:qRxLevMin=-60
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:ssbScs=30 KHz
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:tReselectionNr=1
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:threshXHighP=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3:threshXLowP=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionPriority=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionSubPriority=oDot6
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=38000
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeight=90
...    NRCELL:cellReselectionPriority=4
...    NRBTS:actIdleMMSteering=true
...    NRCELL:idleMMSteeringPercentageOfUes=100
...    NRCELL:idleMMSteeringAlgo=non CA aware
...    NRCELL:idleMMSteeringWRREnabled=false

@{online_B020_NRSYSINFO_PROFILE-1}
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionPriority=3
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:cellReselectionSubPriority=oDot2
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-1:idleMMNrCelResWeight=5
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionPriority=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:cellReselectionSubPriority=oDot4
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-2:idleMMNrCelResWeight=20
...    delete:MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRIRFIM-3
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionPriority=1
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:cellReselectionSubPriority=oDot6
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:carrierFreq=38000
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-1:idleMMEutraCelResWeight=30
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:cellReselectionPriority=0
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:cellReselectionSubPriority=oDot6
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:carrierFreq=42590
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:idleMMEutraCelResWeight=50
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:allowedMeasBw=mbw100
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:pMaxEutra=23
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:presenceAntPort1=false
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:qQualMin=-34
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:qRxLevMin=-22
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:threshXHigh=10
...    MRBTS-1/NRBTS-1/NRSYSINFO_PROFILE-1/NRLIM-2:threshXLow=0
...    NRCELL-1:idleMMServCelResWeight=7
...    NRCELL-1:cellReselectionPriority=7
...    NRCELL-1:cellReselectionSubPriority=oDot2
...    NRCELL-1:t320=min10

@{PM_Counters_B019}
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}==1
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}==1
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_LTE}==0
${NRRCC_RRC_RELEASE_SENT}    M55124C00001    #Number of RRC RELEASE messages sent (CU counter)
${NRRCC_RRC_RELEASE_IMM_NR}    M55124C05501
#TThe number of times that Idle Mode Mobility steering algorithm has selected NR carrier
#frequency as primary target.
${NRRCC_RRC_RELEASE_IMM_LTE}    M55124C05502
#Number of RRC RELEASE messages with dedicated cell reselection priorities and LTE primary target
@{PM_Counters_B020}
...    NRCELL-1:${NRRCC_RRC_RELEASE_SENT}==1
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_NR}==0
...    NRCELL-1:${NRRCC_RRC_RELEASE_IMM_LTE}==1

@{pass_regexp_pdu_5QI5}
...    QoS Routing Table
...    Setup QosFlow with QFI:1 5QI:5
...    cipheringAlgorithm nea0
...    Initial Context Setup Successful for UE with AMF UE ID

@{pass_regexp_5QI1_Failed}
...    Received UE Context Release Complete
...    Adding QosFlow with QFI:2 5QI:1
...    PDU Session Resource Modify Unsuccessful Transfer
...    UE CONTEXT RELEASE REQUEST
...    Redirected carrier info is present in RRC Release


${InactivityTimer}    60

#VONR FALLBACK-LTE
#FR1+FR2
${UECapabilities}    SEPARATOR=
...    E9A09000575F5A13160003C420005824C5C00670F424026C830E7CC31E50B038260300C47013B8D85181AC1184341020E9068036B64C558D0
...    E7C471E819F604F8C48E3C873EA39F30C7942C0FFFFF05C00FFC0070005F0005C0000E0541B107582308682041E20D00656C98AB121CFB027
...    C471E31238F21CFA8E7CC31E50B0381C3C27F6000001FD800000170000381546C4CD608C21A0810748340185B262A88873E238F11C7A067D8
...    13E31CF9863CA1607FFFF82E007FE003801FF8002E0000702B8F88DAC1184341020F941A00AAD931561439F11C78C00000000000000000040
...    E1E027FFC00001FFF0000017000038150AD00DE38C21C002A3CFC50D8047ED982A90000000087104184540A3F7F2040C800D00E3F1C5A2400
...    C0020100201A00A80BBC3C4C000E208000010B0102A0F0A000388C0000042C0AC3C46000E208000030B02B0F0A00038820000042C0AC3C4C0
...    00E230000010B02B17118003882001C4100000A160561E14000713000003058158B898001C41000E140000040B02B1713000388C001C46000
...    004160562E14000710400388C0000082C0AC5C28000E20800710400001058158B898001C41000E230000020B02B170A000388C001C4600000
...    4160562E2600071180038500000102C0AC3C46000E230000030B02B270A0003850001C41000E230007130000038585D64E1400070A0003882
...    001C41000E260000070B0FD64E140007104003882001C46000E260000080B02F070A0000048580817838820000282C040BC1C460000141602
...    05E0E260000090B0102A07400C20058401009011A014404C808304005D004046C2F0A244D8E7C3851226C73E1C28913639F0E14489B1CF870
...    A244D8E7C38912244D8E7C3850206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E044810206C73E04
...    4810206C73E0428103639F024408102040D96BC39102040810365AF0E4408102040D96BC38113639F0E040D800008103600002044D8000080
...    6CF1E5807C586318C6318C6318C6318C6318C637A0B800F000A070500703009401C0018090010180F82400800000004000008020000000100
...    000200800002004000018020000124940380E0380E0380E0380E0386008004010040100000C00800007004002000000080000800400004802
...    00000C010000140080000B004002048120080000C0339535953582958195833582B594B5BA5602D606D6025604560ED034100000965240400
...    0065949410000296525040000E594901000049652404000165949010000696524040301C0701C070000104000225949010000996524040002
...    A5949010000B96525040003259490100003165240334AA2E955552AABA55154162A82C55068AAED45268AA031540A2A93555078A160178095
...    028140A05028140A05028140A05028140A0502814002C2020180300801002101002008040300610080100202018030080600C10100C018040
...    300610080100202018030080100220100C01804030060100C018202004010080100440100200404008010100C018040300601002004802004
...    008080600C02018030080600C020040080040080300080600C0010100206A87C0004080C10181C282C30344044484C5060646C70747C84949
...    89CA0A4A8B4BD05060B40

*** Test Cases ***
CB008285-ET-B019-CB007516_A016_IMM_none_CA_aware_-_more_than_one_freq_matched
    [Documentation]
    ...    1. This user scenario describes This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This test is checking gNB behavior for Idle Mode Mobility steering without CA aware algorithm and without
    ...       mobility profiles for FR2 SA PCell.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       Configuration focus on PARAMS_FOR_7516
    ...    3. Test Case Steps:
    ...      1). Steps:
    ...       a. Trigger UE Registering and creating PDU
    ...       b. deregister UE by AMF
    ...      2). Expected Results:
    ...       a. UE Registering and creating PDU successfully
    ...       b. deregister UE by AMF successfully,check Primary Target(NR) and Secondary Target the IE inside is as expected
    [Tags]    QC_302794    B019
    clear counter files    wait=${False}
    Trigger UE MO VoNR Call With PDU Default 5QI5
    deregister UE by AMF
    Check Counters    ${PM_Counters_B019}
    Check Wireshark Log    ${CURDIR}${/}a2a_B019${/}a2a.ini    wait_string=UEContextReleaseComplete::4

CB008285-ET-B020-CB007516_A018_IMM_-_none_CA_aware_-_LTE_freq_matched
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This test is checking gNB behavior for Idle Mode Mobility steering without CA aware algorithm and without
    ...       mobility profiles for FR2 SA PCell.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       Configuration focus on online_B020_NRSYSINFO_PROFILE-1
    ...    3. Test Case Steps:
    ...      1). Steps:
    ...       a. Trigger UE Registering and creating PDU
    ...       b. deregister UE by AMF
    ...      2). Expected Results:
    ...       a. UE Registering and creating PDU successfully
    ...       b. deregister UE by AMF successfully,check Primary Target(LTE) and Secondary Target the IE inside is as expected
    [Tags]    QC_302804    B020
    Modify NRSYSINFO_PROFILE value    ${online_B020_NRSYSINFO_PROFILE-1}
    clear counter files    wait=${False}
    Trigger UE MO VoNR Call With PDU Default 5QI5
    deregister UE by AMF
    Check Counters    ${PM_Counters_B020}
    Check Wireshark Log    ${CURDIR}${/}a2a_B020${/}a2a.ini    wait_string=UEContextReleaseComplete::4


CB008285-ET-B021-5GC000786-ET-B012_Verify fallback to LTE when VoNR fail setup due to VoNR disabled_TDD_SA
    [Documentation]
    ...    1. This user scenario describes how to configure a gNB with FR2 SA Cells.
    ...       This test is checking gNB behavior for VoiceFallback for FR2 SA PCell.
    ...    2. Configuration:
    ...       cell id=1 gnb=2 nr_arfcn=2071675:2071675 gscn=22446 pci=16:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=2 gnb=2 nr_arfcn=2073339:2073339 gscn=22452 pci=17:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=3 gnb=2 nr_arfcn=2075003:2075003 gscn=22458 pci=17:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=4 gnb=2 nr_arfcn=2076667:2076667 gscn=22464 pci=17:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=5 gnb=2 nr_arfcn=2078331:2078331 gscn=22470 pci=18:0 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=6 gnb=2 nr_arfcn=2079995:2079995 gscn=22476 pci=18:1 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=7 gnb=2 nr_arfcn=2081659:2081659 gscn=22482 pci=18:2 tac=200 tdd_cell=on chBw=100MHz
    ...       cell id=8 gnb=2 nr_arfcn=2083323:2083323 gscn=22488 pci=19:0 tac=200 tdd_cell=on chBw=100MHz
    ...       configure cell1, cell5 as pcell:sCellOnlyFr2Sa=false; configure other cells as scell:sCellOnlyFr2Sa=true
    ...       Configuration focus on PARAMS_FOR_VCFB
    ...    3. Test Case Steps:
    ...      1). Steps:
    ...       a. Trigger UE MO VoNR Call With PDU Default 5QI5
    ...       b. Trigger UE 5QI1 Setup Failed for actVoNR=false
    ...      2). Expected Results:
    ...       a. UE Registering and creating PDU successfully
    ...       b. voice call setup failed and then redirect to LTE,check RedirectionVoiceFallback relevant information
    [Tags]    QC_302790    B021
    Trigger UE MO VoNR Call With PDU Default 5QI5
    Trigger UE 5QI1 Setup Failed
    check wireshark log    ${CURDIR}/a2a_B021/a2a.ini    wait_string=UEContextReleaseComplete::4
    Release Ues    ue_type=all

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/8cells_ecpri

Modify Cfg
    Update Cfg    amf_param id=1 full_nas_auth=on nia=null+aes nea=null+aes ims_voice_3gpp=on voice_fallback=on
    Update Cfg    amf_ue_ics_param id=1 include_ue_capabilities=on
    ${set_ue}    catenate
    ...    set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56
    ...    opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+aes nea=null+aes sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
    ${ue_param}    catenate
    ...    ue_param id=1
    ...    ue_nr_capabilities=${UECapabilities}
    ...    nr_usage_setting=voice_centric
    Update Cfg    ${set_ue}
    Update Cfg    ${ue_param}
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=1
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1 amf=1 qos_flows=1,2 qos_rules=1,2


Trigger UE MO VoNR Call With PDU Default 5QI5
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${pass_regexp_pdu_5QI5}

Trigger UE 5QI1 Setup Failed
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=${pass_regexp_5QI1_Failed}

deregister UE by AMF
    [Arguments]    ${ue_id}=1
    Execute Egate Command    ue_deregister id=${ue_id} by=amf ue_deregister_type=normal    pass_regexp=UE${ue_id}: detached

Modify NRSYSINFO_PROFILE value
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Lock Cell1
    Unlock Cell1
    Cells Should Be Onair    cell_id=1
