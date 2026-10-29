*** Settings ***
Documentation    Suite description
...    Author:keyu.du
...    contact:keyu.a.du@nokia-sbell.com
...    squad group:RAN_L3_SW_CN_2
...    Feature CB008285 in TRUNK program
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs

Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS23R4    RAN_5G    RAN_5G_TDD    team-Beam    owner-keyu.a.du
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008285    release-SBTS23R4
...    STATE_CONFIGURED    5G_RAN    5G_RAN_TDD

Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${OOO_ue_nr_capabilities}
...    SEPARATOR=
...    E1A27000574F7603560003C42800580F40000980219008120C7A023D801E099321CF916BD055EC12F40CFB027C0F1E238F23CFB1E7D812647
...    BF41DFB06FD8246C69F640FB049D834EC1AF62CF920020301262C011306E412006341A0140601CCE00540B40378E3087000A8F3F1436011FB
...    660AA40078F0021C4002115028FDFC8106400000C00600385C2168800300080400006806A0740050C000401503A0060C008200A83D00000C8
...    000004200801820100105C800740700D8E3C5806C71E2C20D8E3C50A40340002000C00620001000600310000800300187A0B100F801C01000
...    40500603009401800180F80524A00C00000000003925000000724A01C000000000000000000003001BA400810040000000004100000000010
...    4030000000000000010015DA816809C0110080400090840014401010000000000008000000000004000000000000800200400840401002010
...    0400000200C01814294404008D00

@{PARAMS_IN_SCF}
...    @{32SSB}
...    NRBTS-1:srbInactivityTimerSA=120
...    @{CB008285_enable_parameter}
...    @{CB008285_a_enable}
...    @{CB009189_b_enable}
...    @{CB008285_e_enable}

@{32SSB}
...    NRCELL:actBeamforming=true
...    NRCELL:beamSet:basicBeamSet=beamSetAbf_32A
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=32 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIAFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1/NRIRFIM-1:numberOfTransmittedSsBlocks=32 beams
...    NRSYSINFO_PROFILE-1:systemInformationTargetRate=50

@{CB008285_enable_parameter}
...    NRBTS-1/NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS-1/NRPMRNL-1:miNrNgcFlexInterface=disabled
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileInterFreq=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileInterRat=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileIntraFreq=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileMappingSA=disabled
...    NRBTS-1/NRPMRNL-1:miNrMeasProfileMappingNSA=disabled

@{CB008285_a_enable}
...    NRBTS-1:actFr2Sa=true
...    NRBTS-1:gNbCuType=SA
...    NRBTS-1:x2LinkSupervisionTmr=0
...    NRBTS-1:actSplitNrEutraUeCapa=false
...    NRBTS-1:srbInactivityTimerSA=120
...    NRCELL:a3MeasEnabled=none
...    NRCELL:a5MeasEnabled=none
...    NRCELL:a2MeashoEnabledSA=none
...    NRCELL:voiceFBMode=disabled
...    NRCELL:actCDrx=false
...    NRCELL:actNrDualConnectivity=disabled
...    NRCELL:actRedCapUeSupport=false
...    NRCELL:actVoNR=false
...    NRCELL:cellDepType=SA
...    NRCELL-1:sCellOnlyFr2Sa=false
...    NRCELL-2:sCellOnlyFr2Sa=true
...    NRCELL-3:sCellOnlyFr2Sa=false
...    NRCELL-4:sCellOnlyFr2Sa=true
...    NRCELL:configuredEpsTac=${EMPTY}
...    delete:NRCELL:ranAC
...    NRCELL:actCsiResAllocOptList=disabled
...    NRCELL:actOsiMismatchCheck=false
...    NRCELL:actLongPucchResourceOpt=false
...    NRCELL:eblRplCellSelectionWithCA=false
#...    NRCELL:actSmallestRRCSetup=true

@{CB008285_e_enable}
...    NRCELL:prachConfigurationIndex=121
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:type0SearchSpaceConfigurationIndex=13
...    NRCELL:inactiveSsbFr2=0x0800F8842100F210
...    NRCELL:numOfPagingFrames=oneEighthT
...    NRBTS-1/NRCELLGRP-0:ssBurstSetPeriod=40
...    NRBTS-1/NRCELLGRP-1:ssBurstSetPeriod=40
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:guardPeriodLength=6Symbols
...    NRCELL:rangeExtension=0-6.9km
...    NRCELL:zeroCorrelationZoneConfig=0
...    NRCELL:prachRootSequenceIndex=0
...    NRCELL:totalNumberOfRAPreambles=32
...    NRCELL:cbraPreamblesPerSsb=n32

@{CB009189_b_enable}
...    NRBTS/NRPMRNL-1:miNrUlHarq=5min
...    NRBTS/NRPMRNL-1:miNrDlHarq=5min
...    NRCELL:actServiceAwareConfig=true
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80

@{CB008285_B_07_para}
...    NRCELLGRP-0:maxUlHarqTx=6
...    NRCELLGRP-1:maxUlHarqTx=5
...    NRBTS/NRDRB_MAC-2:maxUlHarqTxDrb=4
...    NRBTS/NRDRB_MAC-2:maxDlHarqTxDrb=4
...    NRBTS/NRDRB_MAC-1:lcgid=2
...    NRBTS/NRDRB_MAC-1:maxUlHarqTxDrb=8
...    NRBTS/NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
...    NRBTS/NRDRB-12:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
...    NRBTS/NRDRB-12:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1

@{CB008285_B_07_recover_para}
...    NRCELLGRP-0:maxUlHarqTx=5
...    NRCELLGRP-1:maxUlHarqTx=5
...    NRBTS/NRDRB_MAC-1:lcgid=1
...    delete:NRBTS/NRDRB_MAC-1:maxDlHarqTxDrb
...    delete:NRBTS/NRDRB_MAC-1:maxUlHarqTxDrb
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    delete:NRBTS/NRDRB_MAC-2:maxDlHarqTxDrb
...    delete:NRBTS/NRDRB_MAC-2:maxUlHarqTxDrb
...    NRBTS/NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-2
...    NRBTS/NRDRB-12:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS/NRDRB-12:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2

${INITIAL_DL_TB}    M55300C12003    #initial_dl_tb
${FAILED_TB_RECEPTIONS_DL}    M55300C12002
${SUCCESSFUL_DL_TB}    M55300C12005
${HARQ_RETX_DL}    M55300C12004

${INITIAL_UL_TB}    M55302C15002
${FAILED_TB_RECEPTIONS_UL}    M55302C15001
${SUCCESSFUL_UL_TB}    M55302C15004
${HARQ_RETX_UL}    M55302C15003

${INITIAL_DL_64QAM}    M55300C000
${INITIAL_UL_64QAM}    M55302C000
${FAILED_DL_64QAM}     M55300C030
${FAILED_UL_64QAM}     M55302C030

@{PM_Counters_UL_03}
...    @{PM_Counters_INITIAL_UL_03}
...    @{PM_Counters_FAILED_UL_03}
...    @{PM_Counters_TB_UL_03}

@{PM_Counters_INITIAL_UL_03}
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}00
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}01
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}02
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}03
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}04
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}05
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}06
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}07
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}08
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}09
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}10
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}11
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}12
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}13
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}14
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}15
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}16
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}17
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}18
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}19
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}20
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}21
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}22
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}23
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}24
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}25
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}26
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}27
...    NRCELL-1:NULHQ:${INITIAL_UL_64QAM}28

@{PM_Counters_FAILED_UL_03}
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}00
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}01
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}02
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}03
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}04
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}05
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}06
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}07
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}08
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}09
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}10
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}11
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}12
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}13
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}14
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}15
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}16
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}17
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}18
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}19
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}20
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}21
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}22
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}23
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}24
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}25
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}26
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}27
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}28
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}29
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}30
...    NRCELL-1:NULHQ:${FAILED_UL_64QAM}31

@{PM_Counters_TB_UL_03}
...    NRCELL-1:NULHQ:${INITIAL_UL_TB}
...    NRCELL-1:NULHQ:${FAILED_TB_RECEPTIONS_UL}
...    NRCELL-1:NULHQ:${SUCCESSFUL_UL_TB}
...    NRCELL-1:NULHQ:${HARQ_RETX_UL}

@{PM_Counters_DL_04}
...    @{PM_Counters_INITIAL_DL_04}
...    @{PM_Counters_FAILED_DL_04}
...    @{PM_Counters_TB_DL_04}

@{PM_Counters_INITIAL_DL_04}
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}00
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}01
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}02
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}03
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}04
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}05
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}06
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}07
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}08
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}09
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}10
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}11
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}12
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}13
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}14
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}15
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}16
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}17
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}18
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}19
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}20
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}21
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}22
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}23
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}24
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}25
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}26
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}27
...    NRCELL-1:NDLHQ:${INITIAL_DL_64QAM}28

@{PM_Counters_FAILED_DL_04}
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}00
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}01
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}02
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}03
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}04
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}05
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}06
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}07
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}08
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}09
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}10
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}11
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}12
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}13
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}14
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}15
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}16
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}17
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}18
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}19
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}20
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}21
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}22
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}23
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}24
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}25
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}26
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}27
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}28
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}29
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}30
...    NRCELL-1:NDLHQ:${FAILED_DL_64QAM}31

@{PM_Counters_TB_DL_04}
...    NRCELL-1:NDLHQ:${INITIAL_DL_TB}
...    NRCELL-1:NDLHQ:${FAILED_TB_RECEPTIONS_DL}
...    NRCELL-1:NDLHQ:${SUCCESSFUL_DL_TB}
...    NRCELL-1:NDLHQ:${HARQ_RETX_DL}

@{PM_Counters_ULDL_05}
...    @{PM_Counters_UL_03}
...    @{PM_Counters_DL_04}

@{CB008285_B_19_para}
...    @{CB008285_e_enable}
...    NRBTS-1:drbInactivityTimerSA5qi5=60
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-7
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-2
...    NRBTS-1/NRDRB-16:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-16:resType=nonGBR_Signaling
...    NRBTS-1/NRDRB-16:rlcMode=RLC_AM
...    NRBTS-1/NRDRB-16:maxDataRateGbrDl=1000
...    NRBTS-1/NRDRB-16:maxDataRateGbrUl=1000
...    NRBTS-1/NRDRB-16:l2OHFactorDl=16
...    NRBTS-1/NRDRB-16:l2OHFactorUl=35
...    NRBTS-1/NRDRB-16:discardTimer=50ms
...    NRBTS-1/NRDRB-16:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-16:maxRlcQueueingDelayGbr=20
...    NRBTS-1/NRDRB-16:maxTransferDelayGbr=20
...    NRBTS-1/NRDRB-16:queuingDelayDiscarding=Disabled
...    NRBTS-1/NRDRB-16:dscp=46
...    NRBTS-1/NRDRB-16:schedulWeight=${EMPTY}
...    NRBTS-1/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS-1/NRDRB_MAC-7:lcgid=0
...    NRBTS-1/NRDRB_MAC-7:delayTarget=50
...    NRBTS-1/NRDRB_MAC-7:schedulBSD=20ms
...    NRBTS-1/NRDRB_MAC-7:schedulPrio=4
...    NRBTS-1/NRDRB_MAC-7:maxDlHarqTxDrb=8
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms15
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    NRBTS/NRDRB_MAC-2:maxDlHarqTxDrb=6

@{CB008285_B_19_recover_para}
...    NRCELLGRP-0:maxUlHarqTx=5
...    NRCELLGRP-1:maxUlHarqTx=5
...    NRBTS/NRDRB_MAC-1:lcgid=1
...    delete:NRBTS/NRDRB_MAC-1:maxDlHarqTxDrb
...    delete:NRBTS/NRDRB_MAC-1:maxUlHarqTxDrb
...    NRBTS/NRDRB_MAC-2:lcgid=1
...    delete:NRBTS/NRDRB_MAC-2:maxDlHarqTxDrb
...    delete:NRBTS/NRDRB_MAC-2:maxUlHarqTxDrb
...    NRBTS-1:drbInactivityTimerSA5qi5=0
...    NRBTS-1/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS-1/NRDRB_5QI-1:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-10
...    delete:NRBTS-1/NRDRB_RLC_UM-1
...    delete:NRBTS-1/NRDRB-16
...    delete:NRBTS-1/NRDRB_MAC-7

@{CB008285_B_17_para}
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=0
...    NRBTS-1/NRCELL-3:maxNumOfRrcSA=0
...    NRBTS-1/NRCELL-1:maxNumOfSCellAlloc=0
...    NRBTS-1/NRCELL-3:maxNumOfSCellAlloc=0

@{CB008285_B_17_recover_para}
...    NRBTS-1/NRCELL-1:maxNumOfRrcSA=275
...    NRBTS-1/NRCELL-3:maxNumOfRrcSA=275
...    NRBTS-1/NRCELL-1:maxNumOfSCellAlloc=250
...    NRBTS-1/NRCELL-3:maxNumOfSCellAlloc=250

*** Test Cases ***
CB008285_B_07_9189-SR-B-B103_005_ULDL_H-ARQ_retransmission_number_per_DRB_profile-multiple_DRBs_and_SRBs_SA
    [Documentation]    *****************
    ...    This user scenario describes the gNB behavior for the transmission of PDCP PDUs when
    ...    CellGrp 'MaxHarq' for non-GBR bearers is enabled.
    ...    5QI 6 -- NRDRB11 -- NRDRB_MAC-2 -- NRDRB_PDCP-2 -- NRDRB_RLC_AM-2 -- lcg2
    ...    5QI 7 -- NRDRB12 -- NRDRB_MAC-1 -- NRDRB_PDCP-1 -- NRDRB_RLC_AM-1 -- lcg1
    ...    *******************
    CB008285_B_07 Prepare Parameters and Check List
    Clear Counter files    wait=${False}
    Attach SA UEs    tag=CB008285_B_07
    Start TTI Trace Traffic And Active Bler Testmode    tag=CB008285_B_07
    Stop TTI Trace    tag=CB008285_B_07
    UE detach and Deactivate Bler Testmode
    ...    ue_id_1st=81    ue_nums=2    bler_type=uldl
    Check TTI Trace    tag=CB008285_B_07    physCellId=50|52    trf_dir=uldl
    Check Counter CB008285_B_07
    Recover Parameter    para=${CB008285_B_07_recover_para}

CB008285_B_17_2497_A001_SA_UE_Attach_Should_Success_After_Failure_Last_Time
    [Documentation]     Verify that the SA UE attach can success after failure last time
    Set Parameter    para=${CB008285_B_17_para}
    SA UE Attach Should Fail    ue_id=81    cell_id=1
    SA UE Attach Should Fail    ue_id=82     cell_id=3
    Recover Parameter    para=${CB008285_B_17_recover_para}
    SA UE Attach And Detach Should Success
    ...    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=1    gw_id=1
    SA UE Attach And Detach Should Success
    ...    ue_id=82    cell_id=3    pdu_id=1    nwslice_id=1    gw_id=1
    Check Wireshark Log
    ...    a2a_ini_file=${CURDIR}${/}a2a_CB008285_17${/}a2a.ini
    ...    wait_string=UEContextReleaseComplete::4

CB008285_B_19_9189-B_04_HARQ_retransmission_per_DRB_for_Multi_DRB_UL_FR2_TDD_SA
    [Documentation]    *****************
    ...    This user scenario describes the gNB behavior for the transmission of PDCP PDUs when
    ...    CellGrp 'MaxHarq' for non-GBR bearers is enabled.
    ...    5QI 5 -- NRDRB16 -- NRDRB_MAC-7 -- NRDRB_PDCP-2 -- NRDRB_RLC_AM-2
    ...    *******************
    CB008285_B_19 Prepare Parameters and Check List
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=1    gw_id=1
    Start TTI Trace Traffic And Active Bler Testmode    tag=CB008285_B_19
    Stop TTI Trace    tag=CB008285_B_19
    UE detach and Deactivate Bler Testmode
    ...    ue_id_1st=81    ue_nums=1    bler_type=ul
    Check TTI Trace    tag=CB008285_B_19    physCellId=50    trf_dir=ul
    Recover Parameter    para=${CB008285_B_19_recover_para}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/4cells_4T

${tag} Parse Arguments ${i_step}
    ${vars}    Set Variable    ${None}
    ${vars}    Run Keyword Unless    '''${${tag}_step_args[${i_step}]}'''=='''${None}'''
    ...    Evaluate    list(${${tag}_step_args[${i_step}].split(" ")})
    ${dict_var}    Create Dictionary
    ${dict_var}     Run Keyword Unless    '''${vars}'''=='''${None}'''
    ...    Create Dictionary    @{vars}
    [Return]    ${dict_var}

Set Parameter
    [Arguments]    ${para}=${EMPTY}
    OnlineParamChange    ${para}
    Clear Counter Files    wait=${False}

Recover Parameter
    [Arguments]    ${para}=${EMPTY}
    OnlineParamChange    ${para}

Attach SA UEs
    [Arguments]    ${tag}=CB008285_B_07
    SA UE Attach    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=1    gw_id=1
    SA UE Attach    ue_id=82    cell_id=3    pdu_id=1    nwslice_id=1    gw_id=1

Add Qosflow Start 5QI Traffic CB008285_B_07
    # Invoke Keyword: Start TTI Trace Traffic And Active Bler Testmode
    ${trf_dir}=    Set Variable    uldl
    Execute Egate Command    ue_pdu_session_modify ue=81 pdu=1 qosflows_to_add=7 by=amf    Added QosFlow
    Sleep    0.5s    pause for next pdu session modify
    Execute Egate Command    ue_pdu_session_modify ue=82 pdu=1 qosflows_to_add=7 by=amf    Added QosFlow
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=1
    ...    send_dl=80    send_ul=10    sleep_time=3    trf_id=1    trf_dir=${trf_dir}
    Send And Verify Throuput    ue_id=82    pdu_id=1    qfi_id=1
    ...    send_dl=80    send_ul=10    sleep_time=3    trf_id=1    trf_dir=${trf_dir}
    Send And Verify Throuput    ue_id=81    pdu_id=1    qfi_id=2
    ...    send_dl=80    send_ul=10    sleep_time=3    trf_id=2    trf_dir=${trf_dir}
    Send And Verify Throuput    ue_id=82    pdu_id=1    qfi_id=2
    ...    send_dl=80    send_ul=10    sleep_time=3    trf_id=2    trf_dir=${trf_dir}

Add Qosflow Start 5QI Traffic CB008285_B_19
    # Invoke Keyword: Start TTI Trace Traffic And Active Bler Testmode
    [Arguments]
    ...    ${ue_id}=81    ${pdu_id}=1    ${qfi_id}=2    ${qosflows_to_add}=5    ${dl_tp}=20
    ...    ${ul_tp}=20    ${duration}=${10}    ${trf_id}=1    ${trf_dir}=ul
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ...    Added QosFlow
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=1
    ...    send_dl=${dl_tp}    send_ul=${ul_tp}    sleep_time=3    trf_id=1    trf_dir=${trf_dir}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=2
    ...    send_dl=${dl_tp}    send_ul=${ul_tp}    sleep_time=3    trf_id=2    trf_dir=${trf_dir}

Activate Bler Testmode
    [Arguments]      ${ue_id_1st}=81    ${ue_nums}=4    ${bler_type}=dl
    ...    ${ul_bler}=200,200,200,200,200,200,200,200    ${dl_bler}=50,50,50,50,50,50,50,50
    ${ue_id_last}    Evaluate    ${ue_id_1st}+${ue_nums}
    FOR    ${ue_id}    IN RANGE     ${ue_id_1st}    ${ue_id_last}
        Run Keyword    Activate Bler ${bler_type}
        ...    ue_id=${ue_id}    bler_type=${bler_type}
        ...    ul_bler=${ul_bler}    dl_bler=${dl_bler}
    END

Activate Bler Testmode CB008285_B_07
    # Invoke Keyword: Start TTI Trace Traffic And Active Bler Testmode
    Activate Bler Testmode    ue_id_1st=81    ue_nums=2    bler_type=uldl
    ...    ul_bler=50,50,50,50,50,50,50,50    dl_bler=50,50,50,50,50,50,50,50

Activate Bler Testmode CB008285_B_19
    # Invoke Keyword: Start TTI Trace Traffic And Active Bler Testmode
    Activate Bler Testmode    ue_id_1st=81    ue_nums=1    bler_type=ul
    ...    ul_bler=50,50,50,50,50,50,50,50    dl_bler=50,50,50,50,50,50,50,50

Start TTI Trace Traffic And Active Bler Testmode
    [Arguments]    ${tag}=CB008285_B_07
    Run Keyword Unless    'startup' in '${tag}' or ${TTITRACE_FLAG} is not ${True}
    ...    Stop Capture Gnb Ttitrace
    Start To Capture Gnb Ttitrace    tag=${tag}
    Sleep    3s    wait Ttitrace Captrue Start
    Run Keyword    Add Qosflow Start 5QI Traffic ${tag}
    Run Keyword    Activate Bler Testmode ${tag}
    Sleep    2s    wait Ttitrace Capture collect

Stop TTI Trace
    [Arguments]    ${tag}=CB008285_B_07
    Stop Capture Gnb Ttitrace    tag=${tag}
    ...    target_dir=${SAVE LOG DIRECTORY}

UE detach and Deactivate Bler Testmode
    [Arguments]    ${ue_id_1st}=81    ${ue_nums}=4    ${bler_type}=uldl
    ${ue_id_last}    Evaluate    ${ue_id_1st}+${ue_nums}
    FOR    ${ue_id}    IN RANGE     ${ue_id_1st}    ${ue_id_last}
        Deactivate Bler    ue_id=${ue_id}    bler_type=${bler_type}
        UE Deregister From gNB    ue_id=${ue_id}
    END

CB008285_B_07 Prepare Parameters and Check List
    Set Parameter    para=${CB008285_B_07_para}
    ${CB008285_B_07_50_check_dict}=    Create Dictionary
    ...    maxUlHarqTx=4|6|8
    ...    singleUl=false
    ...    addlcgs=3
    ...    maxDlHarqTx=4|5
    ...    singleDl=false
    ...    addbears=4
    ${CB008285_B_07_50_check_list}=    Create List
    ...    NRCELLGRP-0:maxUlHarqTx=6
    ...    NRCELLGRP-1:maxUlHarqTx=5
    ...    NRCELL:actServiceAwareConfig=true
    ...    NRCELL:adaptiveSrLoadThresholdDown=50
    ...    NRCELL:adaptiveSrLoadThresholdUp=80
    ...    NRBTS/NRDRB_MAC-2:maxUlHarqTxDrb=4
    ...    NRBTS/NRDRB_MAC-2:maxDlHarqTxDrb=4
    ...    NRBTS/NRDRB_MAC-1:lcgid=2
    ...    NRBTS/NRDRB_MAC-1:maxUlHarqTxDrb=8
    ...    NRBTS-1/NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-1
    ...    NRBTS-1/NRDRB-12:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-1
    ...    NRBTS-1/NRDRB-12:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-1
    ${CB008285_B_07_52_check_dict}=    Create Dictionary
    ...    maxUlHarqTx=4|5|8
    ...    singleUl=false
    ...    addlcgs=3
    ...    maxDlHarqTx=4|5
    ...    singleDl=false
    ...    addbears=4
    ${CB008285_B_07_52_check_list}=    Create List
    Set Suite Variable    ${CB008285_B_07_50_check_dict}
    Set Suite Variable    ${CB008285_B_07_52_check_dict}
    Set Suite Variable    ${CB008285_B_07_50_check_list}
    Set Suite Variable    ${CB008285_B_07_52_check_list}

CB008285_B_19 Prepare Parameters and Check List
    Set Parameter    para=${CB008285_B_19_para}
    ${CB008285_B_19_50_check_dict}=    Create Dictionary
    ...    maxUlHarqTx=5
    ...    singleUl=true
    ...    addlcgs=2
    ...    maxDlHarqTx=5|8
    ...    singleDl=false
    ...    addbears=0
    ${CB008285_B_19_50_check_list}=    Create List
    ...    NRCELLGRP-0:maxUlHarqTx=5
    ...    NRCELL:actServiceAwareConfig=true
    ...    NRCELL:adaptiveSrLoadThresholdDown=50
    ...    NRCELL:adaptiveSrLoadThresholdUp=80
    ...    NRCELL:prachConfigurationIndex=121
    ...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
    ...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
    ...    NRCELL:type0SearchSpaceConfigurationIndex=13
    ...    NRCELL:inactiveSsbFr2=576733998676505104
    ...    NRCELL:numOfPagingFrames=oneEighthT
    ...    NRBTS-1/NRCELLGRP-0:ssBurstSetPeriod=40
    ...    NRBTS-1/NRCELLGRP-1:ssBurstSetPeriod=40
    ...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
    ...    NRCELL:tddFrameStructure:guardPeriodLength=6Symbols
    ...    NRCELL:rangeExtension=0-6.9km
    ...    NRCELL:zeroCorrelationZoneConfig=0
    ...    NRCELL:prachRootSequenceIndex=0
    ...    NRCELL:totalNumberOfRAPreambles=32
    ...    NRCELL:cbraPreamblesPerSsb=n32
    Set Suite Variable    ${CB008285_B_19_50_check_dict}
    Set Suite Variable    ${CB008285_B_19_50_check_list}

Check TTI Trace
    [Arguments]    ${tag}=CB008285_B_01    ${physCellId}=50    ${trf_dir}=uldl
    Decode Log File And Convet File Format
    ...    tag=${tag}    target_dir=${SAVE LOG DIRECTORY}
    ${list_physCellId}=    Evaluate    list(map(float, @{physCellId.split('|')}))
    ${list_physCellId}=    Evaluate    list(map(int, @{list_physCellId}))
    ${cell_cnt}=    Evaluate    int(len(${list_physCellId}))
    Run Keyword    Validate TTI Trace ${cell_cnt}Cell
    ...    tag=${tag}    list_physCellId=${list_physCellId}      trf_dir=${trf_dir}

Validate TTI Trace 2Cell
    # Invoke Keyword:    Check TTI Trace
    [Arguments]    ${tag}=CB008285_B_01    ${list_physCellId}=${None}      ${trf_dir}=uldl
    Run Keywords    Validate TTI Trace    tag=${tag}    physCellId=${list_physCellId[0]}    trf_dir=${trf_dir}
    ...    AND    Validate TTI Trace    tag=${tag}    physCellId=${list_physCellId[1]}    trf_dir=${trf_dir}

Validate TTI Trace 1Cell
    # Invoke Keyword:    Check TTI Trace
    [Arguments]    ${tag}=CB008285_B_01    ${list_physCellId}=${None}      ${trf_dir}=uldl
    Validate TTI Trace    tag=${tag}    physCellId=${list_physCellId[0]}    trf_dir=${trf_dir}

Validate TTI Trace
    [Arguments]    ${tag}=CB008285_B_01    ${physCellId}=50      ${trf_dir}=uldl
    ${list_maxUlHarqTx}    ${list_maxDlHarqTx}    ${singleUl}    ${singleDl}    ${parameters}    ${exp_lcgs}    ${exp_bears}
    ...    Get TC Check List    tag=${tag}_${physCellId}
    Sort List    ${list_maxUlHarqTx}
    Sort List    ${list_maxDlHarqTx}

    GNB SCF Validation    scf_validate=@{parameters}

    Run Keyword    Valdate TtiTrace With Dir ${trf_dir}
    ...    physCellId=${physCellId}    list_maxUlHarqTx=@{list_maxUlHarqTx}    list_maxDlHarqTx=@{list_maxDlHarqTx}
    ...    singleUl=${singleUl}    singleDl=${singleDl}    exp_lcgs=${exp_lcgs}    exp_bears=${exp_bears}

Valdate TtiTrace With Dir ul
    # Invoke Keyword: Validate TTI Trace
    [Arguments]    ${physCellId}=50    ${list_maxUlHarqTx}=${Empty}    ${list_maxDlHarqTx}=${Empty}
    ...    ${singleUl}=${True}    ${singleDl}=${True}    ${exp_lcgs}=2    ${exp_bears}=2
    Valdate UL TtiTrace
    ...    physCellId=${physCellId}    list_maxUlHarqTx=@{list_maxUlHarqTx}
    ...    singleUl=${singleUl}    exp_lcgs=${exp_lcgs}

Valdate TtiTrace With Dir dl
    # Invoke Keyword: Validate TTI Trace
    [Arguments]    ${physCellId}=50    ${list_maxDlHarqTx}=${Empty}    ${list_maxDlHarqTx}=${Empty}
    ...    ${singleUl}=${True}    ${singleDl}=${True}    ${exp_lcgs}=2    ${exp_bears}=2
    Validate Dl TtiTrace    physCellId=${physCellId}    list_maxDlHarqTx=@{list_maxDlHarqTx}
    ...    singleDl=${singleDl}    exp_bears=${exp_bears}

Valdate TtiTrace With Dir uldl
    # Invoke Keyword: Validate TTI Trace
    [Arguments]    ${physCellId}=50    ${list_maxUlHarqTx}=${Empty}    ${list_maxDlHarqTx}=${Empty}
    ...    ${singleUl}=${True}    ${singleDl}=${True}    ${exp_lcgs}=2    ${exp_bears}=2
    Valdate UL TtiTrace
    ...    physCellId=${physCellId}    list_maxUlHarqTx=@{list_maxUlHarqTx}
    ...    singleUl=${singleUl}    exp_lcgs=${exp_lcgs}
    Validate Dl TtiTrace    physCellId=${physCellId}    list_maxDlHarqTx=@{list_maxDlHarqTx}
    ...    singleDl=${singleDl}    exp_bears=${exp_bears}

Valdate UL TtiTrace
    [Arguments]    ${physCellId}=50    ${list_maxUlHarqTx}=${Empty}    ${singleUl}=${True}
    ...    ${exp_lcgs}=2
    ${column_filter}=    Set Variable
    ...    rnti,physCellId,txNumber,maxHarqTxNum,rrmBufferedDataUlLcg_bytes_[0],rrmBufferedDataUlLcg_bytes_[1],
    ${column_filter}=    Catenate    SEPARATOR=    ${column_filter}rrmBufferedDataUlLcg_bytes_[2],rrmBufferedDataUlLcg_bytes_[3],
    ${column_filter}=    Catenate    SEPARATOR=    ${column_filter}rrmBufferedDataUlLcg_bytes_[4],rrmBufferedDataUlLcg_bytes_[5],
    ${column_filter}=    Catenate    SEPARATOR=    ${column_filter}rrmBufferedDataUlLcg_bytes_[6],rrmBufferedDataUlLcg_bytes_[7]
    ${col_file_filter}    Checkout Column Filter From TtiDecoder ul
    ...    column_filter=${column_filter}    filter_out=\\(physCellId,${physCellId}\\),txN
    ...    log_path=${SAVE LOG DIRECTORY}    dec_output=changed_csv_file*
    Check MaxHarqNum    tti_dire=ul    single=${singleUl}
    ...    maxulHarqTxDrb=@{list_maxUlHarqTx}    flt_file_Column=${SAVE LOG DIRECTORY}/${col_file_filter}
    Validate txNumber ul    maxHarqTxDrb=${list_maxUlHarqTx[-1]}    flt_file_Column=${SAVE LOG DIRECTORY}/${col_file_filter}
    Run Keyword Unless     '${exp_lcgs}'=='${0}'
    ...    Validate Lcgs        exp_lcgs=${exp_lcgs}    flt_file_Column=${SAVE LOG DIRECTORY}/${col_file_filter}

Validate Dl TtiTrace
    [Arguments]    ${physCellId}=50    ${list_maxDlHarqTx}=${Empty}    ${singleDl}=${True}
    ...    ${exp_bears}=2
    ${column_filter}=    Set Variable
    ...    rnti,physCellId,txNumber,maxHarqTxNum,dciFormat
    ${col_file_filter}    Checkout Column Filter From TtiDecoder dl
    ...    column_filter=${column_filter}    filter_out=\\(physCellId,${physCellId}\\),txN
    ...    log_path=${SAVE LOG DIRECTORY}    dec_output=changed_csv_file*
    Check MaxHarqNum    tti_dire=dl    single=${singleDl}
    ...    maxdlHarqTxDrb=@{list_maxDlHarqTx}    flt_file_Column=${SAVE LOG DIRECTORY}/${col_file_filter}
    Validate txNumber dl    maxHarqTxDrb=${list_maxDlHarqTx[-1]}    flt_file_Column=${SAVE LOG DIRECTORY}/${col_file_filter}
    Run Keyword Unless     '${exp_bears}'=='${0}'
    ...    Validate Scheduled Bytes Per Bearer    exp_bears=${exp_bears}    flt_file_Column=${SAVE LOG DIRECTORY}/${col_file_filter}

Get TC Check List
    [Arguments]    ${tag}=CB008285_B_07_50
    ${list_maxUlHarqTx}=    Evaluate    list(map(int, @{${tag}_check_dict['maxUlHarqTx'].split("|")}))
    ${singleUl}=    Set Variable    ${${tag}_check_dict['singleUl']}
    ${list_maxDlHarqTx}=    Evaluate    list(map(int, @{${tag}_check_dict['maxDlHarqTx'].split("|")}))
    ${singleDl}=    Set Variable    ${${tag}_check_dict['singleDl']}
    ${exp_lcgs}=    Evaluate    int(${${tag}_check_dict['addlcgs']})
    ${exp_bears}=    Evaluate    int(${${tag}_check_dict['addbears']})

    [Return]    ${list_maxUlHarqTx}    ${list_maxDlHarqTx}    ${singleUl}    ${singleDl}    ${${tag}_check_list}
    ...    ${exp_lcgs}    ${exp_bears}

List Val Sum Up
    [Arguments]    ${list_input}=${Empty}
    ${cmd}=    Set Variable    echo @{list_input}
    ${cmd}=    Set Variable    ${cmd} | sed -e \'s/^\\[\\(.*\\)\\]$/\\1/g\' | awk -F, \'{sum=0;for \(i=1;i<=NF;i++\){sum+=$i}print sum}\'
    ${val_sum}    OperatingSystem.Run    ${cmd}
    [Return]    ${val_sum}

Check Counter CB008285_B_07
    [Documentation]
    ...    Function used to validate following UL And DL HARQ 64QAM PM Counters dependencies
    ...
    @{pc_ULDL_05}    Get Counters Value    ${PM_Counters_ULDL_05}    wait=${True}
    Check Counter CB008285_B_07 UL    ${pc_ULDL_05}
    Check Counter CB008285_B_07 DL    ${pc_ULDL_05}

Check Counter CB008285_B_07 UL
    [Arguments]    ${pc_ULDL_05}=${EMPTY}
    ${pc_TB_UL}    ${sum_INITIAL_UL}    ${sum_FAILED_UL}
    ...        Prepare Counter CB008285_B_07 Val UL    pc_ULDL_05=${pc_ULDL_05}

    Should Be True    ${sum_INITIAL_UL}>${0}
    Should Be True    ${sum_INITIAL_UL}>${pc_TB_UL[0]}
    Should Be True    ${pc_TB_UL[1]}<=${sum_FAILED_UL}
    Should Be True    ${pc_TB_UL[1]}<=${pc_TB_UL[0]}
    ${calc_M55302C15004}    Evaluate     ${pc_TB_UL[2]}==(${pc_TB_UL[0]}-${pc_TB_UL[1]})
    ${calc_M55302C15004}=    Run Keyword Unless    '${calc_M55302C15004}'=='${True}'
    ...    Evaluate     ${pc_TB_UL[2]}==(${pc_TB_UL[0]}-${pc_TB_UL[1]}-1)
    Should Be True    '${calc_M55302C15004}'!='${False}'
    ${calc_M55302C15003}    Evaluate    ${pc_TB_UL[3]}>=(${pc_TB_UL[1]}*3)
    Should Be True    ${calc_M55302C15003}

Prepare Counter CB008285_B_07 Val UL
    [Arguments]    ${pc_ULDL_05}=${EMPTY}
    @{pc_UL_03}    Get Slice From List    ${pc_ULDL_05}    start=0    end=65
    @{pc_INITIAL_UL}=    Get Slice From List    ${pc_UL_03}    start=0    end=29
    @{pc_FAILED_UL}=    Get Slice From List    ${pc_UL_03}    start=29    end=61
    @{pc_TB_UL}=    Get Slice From List    ${pc_UL_03}    -4
    ${sum_INITIAL_UL}    List Val Sum Up    ${pc_INITIAL_UL}
    ${sum_FAILED_UL}    List Val Sum Up    ${pc_FAILED_UL}
    [Return]     ${pc_TB_UL}    ${sum_INITIAL_UL}    ${sum_FAILED_UL}

Check Counter CB008285_B_07 DL
    [Arguments]    ${pc_ULDL_05}=${EMPTY}
    ${pc_TB_DL}    ${sum_INITIAL_DL}    ${sum_FAILED_DL}=
    ...    Prepare Counter CB008285_B_07 Val DL    ${pc_ULDL_05}

    Should Be True    ${sum_INITIAL_DL}>${0}
    Should Be True    ${sum_INITIAL_DL}>=${pc_TB_DL[0]}
    Should Be True    ${sum_FAILED_DL}>${0}
    Eval Counter CB008285_B_07 Val DL    ${pc_TB_DL}

Prepare Counter CB008285_B_07 Val DL
    [Arguments]    ${pc_ULDL_05}=${EMPTY}
    @{pc_DL_04}    Get Slice From List    ${pc_ULDL_05}    start=65    end=130
    @{pc_INITIAL_DL}=    Get Slice From List    ${pc_DL_04}    start=0    end=29
    @{pc_FAILED_DL}=    Get Slice From List    ${pc_DL_04}    start=29    end=61
    @{pc_TB_DL}=    Get Slice From List    ${pc_DL_04}    -4
    ${sum_INITIAL_DL}    List Val Sum Up    ${pc_INITIAL_DL}
    ${sum_FAILED_DL}    List Val Sum Up    ${pc_FAILED_DL}
    [Return]     ${pc_TB_DL}    ${sum_INITIAL_DL}    ${sum_FAILED_DL}

Eval Counter CB008285_B_07 Val DL
    [Arguments]    ${pc_TB_DL}=${EMPTY}
    Should Be True    ${pc_TB_DL[1]}<${pc_TB_DL[0]}
    ${calc_M55300C12005}    Evaluate     ${pc_TB_DL[2]}==(${pc_TB_DL[0]}-${pc_TB_DL[1]})
    ${calc_M55300C12005}    Run Keyword Unless    '${calc_M55300C12005}'=='${True}'
    ...    Evaluate     ${pc_TB_DL[2]}==(${pc_TB_DL[0]}-${pc_TB_DL[1]}-1)
    Should Be True    '${calc_M55300C12005}'!='${False}'
    ${calc_M55300C12004}    Evaluate    ${pc_TB_DL[3]}<=((${pc_TB_DL[1]}*3)+(${pc_TB_DL[2]}*5))
    Should Be True    ${calc_M55300C12004}
    ${calc_M55300C12002}    Evaluate    (${pc_TB_DL[1]}*3)<(${pc_TB_DL[3]})
    Should Be True    ${calc_M55300C12002}

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${OOO_ue_nr_capabilities}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${OOO_ue_nr_capabilities}
    B07 Egate Qosflow Setting B1
    B07 Egate Qosflow Setting B2

B07 Egate Qosflow Setting B1
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5 priority=2

B07 Egate Qosflow Setting B2
    Update Cfg    set_qosflow id=6 5qi=6 default=on priority=1
    Update Cfg    set_qosflow id=7 5qi=7 priority=7
    Update Cfg    set_qosflow id=8 5qi=8 priority=9
    Update Cfg    set_qosflow id=9 5qi=9 priority=9
    Update Cfg    set_qosflow id=10 5qi=80 priority=9

onlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Wait Until Keyword Succeeds    15x    30s    NR Cells Should Be OnAir

NR Cells Should Be OnAir
    ${bts_info}    Get Bts Info
    ${cells_list}    Get From Dictionary    ${bts_info['cells']}    nr
    FOR    ${cell}    IN    @{cells_list}
        Should Be Equal    ${cell['status']['operationalState']}    enabled
        Should Be Equal    ${cell['status']['usageState']}    Active
    END

SA UE Attach
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}    ${nwslice_id}    ${gw_id}
    ...    ${pass_regexp}=Created FiveQi:Qfi mapping fiveQi
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    ...    pass_regexp=EGATE\>
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ...    pass_regexp=EGATE\>
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}
    ...    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Start Trf Traffic ul
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} mbps=${send_ul}
    ...    pass_regexp=EGATE\>

Start Trf Traffic dl
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} mbps=${send_dl}
    ...    pass_regexp=EGATE\>

Start Trf Traffic uldl
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} mbps=${send_ul}
    ...    pass_regexp=EGATE\>
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} mbps=${send_dl}
    ...    pass_regexp=EGATE\>

Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${sleep_time}=20s
    ...    ${trf_id}=1    ${trf_dir}=uldl
    FOR    ${n_qfi_id}    IN    @{qfi_id.split(",")}
        Run Keyword    Start Trf Traffic ${trf_dir}
        ...    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${n_qfi_id}
        ...    send_dl=${send_dl}    send_ul=${send_ul}    trf_id=${trf_id}
    END
    ${dl_threshold}    Evaluate    ${send_dl}*0.9
    ${ul_threshold}    Evaluate    ${send_ul}*0.9

    FOR    ${n_qfi_id}    IN    @{qfi_id.split(",")}
        Verify Throuput    ${ue_id}    ${pdu_id}    ${n_qfi_id}    ${dl_threshold}    ${ul_threshold}    ${sleep_time}
    END

Verify Throuput
    [Arguments]    ${ue_id}    ${pdu_id}    ${qfi_id}    ${Tput_dl}    ${Tput_ul}    ${sleep_time}
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu_id}    qfi=${qfi_id}    direction=ul    rate_type=ave

Ul Bler Testmode Set SA
    [Arguments]    ${ue_id}=81    ${profile_id}=30
    ...    ${ul_bler}=1000,1000,1000,1000
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} ul_bler=${ul_bler}
    ...    pass_regexp=EGATE\>
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=${profile_id}
    ...    pass_regexp=EGATE\>

Dl Bler Testmode Set SA
    [Arguments]    ${ue_id}=81    ${profile_id}=1    ${num_harq_nack}=5
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} num_harq_nack=${num_harq_nack}
    ...    pass_regexp=EGATE\>
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=${profile_id}
    ...    pass_regexp=EGATE\>

UlDl Bler Testmode Set SA
    [Arguments]    ${ue_id}=81    ${profile_id}=30
    ...    ${ul_bler}=1000,1000,1000,1000    ${dl_bler}=1000,1000,1000,1000
    Execute Egate Command    bler_testmode_nr profile_id=${profile_id} ul_bler=${ul_bler} dl_bler=${dl_bler}
    ...    pass_regexp=EGATE\>
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=${profile_id}
    ...    pass_regexp=EGATE\>

Activate Bler dl
    [Arguments]    ${ue_id}=81    ${bler_type}=dl    ${num_harq_nack}=5
    ...    ${ul_bler}=200,200,200,200,200,200,200,200    ${dl_bler}=50,50,50,50,50,50,50,50
    Run Keyword    Dl Bler Testmode Set SA    ue_id=${ue_id}    profile_id=1    num_harq_nack=${num_harq_nack}

Activate Bler ul
    # Invoke Keyword: Activate Bler Testmode
    [Arguments]    ${ue_id}=81    ${bler_type}=dl    ${num_harq_nack}=5
    ...    ${ul_bler}=200,200,200,200,200,200,200,200    ${dl_bler}=50,50,50,50,50,50,50,50
    Run Keyword    Ul Bler Testmode Set SA    ue_id=${ue_id}    profile_id=30    ul_bler=${ul_bler}

Activate Bler uldl
    # Invoke Keyword: Activate Bler Testmode
    [Arguments]    ${ue_id}=81    ${bler_type}=dl    ${num_harq_nack}=5
    ...    ${ul_bler}=200,200,200,200,200,200,200,200    ${dl_bler}=50,50,50,50,50,50,50,50
    Run Keyword    UlDl Bler Testmode Set SA    ue_id=${ue_id}    profile_id=30    ul_bler=${ul_bler}
    ...    dl_bler=${dl_bler}

Deactivate Bler
    [Arguments]    ${ue_id}=81    ${bler_type}=dl
    Run Keyword    Deactivate Bler ${bler_type}    ue_id=${ue_id}
    Sleep    2s    wait bler testmode deactive

Deactivate Bler dl
    # Invoke Keyword: Deactivate Bler
    [Arguments]    ${ue_id}=81
    Run Keyword    UlDl Bler Testmode Reset SA    ue_id=${ue_id}    profile_id=1

Deactivate Bler ul
    # Invoke Keyword: Deactivate Bler
    [Arguments]    ${ue_id}=81
    Run Keyword    UlDl Bler Testmode Reset SA    ue_id=${ue_id}    profile_id=30

Deactivate Bler uldl
    # Invoke Keyword: Deactivate Bler
    [Arguments]    ${ue_id}=81
    Run Keyword    UlDl Bler Testmode Reset SA    ue_id=${ue_id}    profile_id=30

UlDl Bler Testmode Reset SA
    [Arguments]    ${ue_id}=81    ${profile_id}=30
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=bler action=deactivate profile_id=${profile_id}
    ...    pass_regexp=EGATE\>

Decode Log File And Convet File Format
    [Arguments]    ${tag}=${EMPTY}    ${target_dir}=${EMPTY}    ${dec_output}=changed_csv_file    ${csv_format}=legacyCsv
    ${cmd}=    Set Variable    python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} ${target_dir}/gnb_ttitrace_logs_${tag}/tcpdump_ttitrace
    ${cmd}=    Catenate    SEPARATOR=    ${cmd}/tcpdump_ttitrace.pcap
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} -o ${target_dir}/${dec_output} ${csv_format}
    ${dec_ret}    OperatingSystem.Run    ${cmd}
    [Return]    ${dec_ret}

dl TTIDIR Filter Str
    [Return]    NR==1{n=0;for\(i=1;i<=NF;i++\)if\($i==\"scheduledBytesPerBearer\"\) {n++;ix[$i\"_\"n]=i;ar1[n+5]=$i\"_\"n} else ix[$i]=i}

ul TTIDIR Filter Str
    [Return]    NR==1{for\(i=1;i<=NF;i++\) ix[$i]=i}

dl TTIDIR Filter Again
    [Return]    | sed -e \'/\\(.*dciFormat,DL_10_OSI\\),.*$/d\' -e \'/\\(.*dciFormat,DL_10_SIB1\\),.*$/d\'

ul TTIDIR Filter Again
    [Return]    ${EMPTY}

Checkout Column Filter From TtiDecoder ul
    [Arguments]
    ...    ${column_filter}=${None}    ${filter_out}=\\(physCellId 52\\) txN
    ...    ${log_path}=${SAVE LOG DIRECTORY}    ${dec_output}=changed_csv_file*
    ${cmd}=    Set Variable    sed -n \'/^ulFdSchedData: \\(.*maxHarqTxNum.*\\)/p\' ${log_path}/${dec_output}.ul.csv
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} | awk -F, \'BEGIN{split\(\"${column_filter}\",ar1,\",\"\)}
    ${ttidir_filter_str}=    Run Keyword    ul TTIDIR Filter Str
    ${cmd}=    Catenate    SEPARATOR=
    ...    ${cmd}${ttidir_filter_str}NR>=1{for\(i=1;i in ar1;i++\)printf \"%s%s%s%s\",$ix[ar1[i]],\",\",$\(NF/2+ix[ar1[i]]\),\",\";print \"\"}\'
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} | sed -e '/^\\(rnti,65535\\),.*/d' -e '/^\\(rnti,0\\),.*/d' | sed \'/.*${filter_out}.*/!d\'
    ${ttidir_filter_str}=    Run Keyword    ul TTIDIR Filter Again
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} ${ttidir_filter_str} > ${log_path}/ul_col_filter.txt
    OperatingSystem.Run    ${cmd}
    [Return]    ul_col_filter.txt

Checkout Column Filter From TtiDecoder dl
    [Arguments]
    ...    ${column_filter}=${None}    ${filter_out}=\\(physCellId 52\\) txN
    ...    ${log_path}=${SAVE LOG DIRECTORY}    ${dec_output}=changed_csv_file*
    ${cmd}=    Set Variable    sed -n \'/^dlFdSchedData: \\(.*maxHarqTxNum.*\\)/p\' ${log_path}/${dec_output}.dl.csv
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} | awk -F, \'BEGIN{split\(\"${column_filter}\",ar1,\",\"\)}
    ${ttidir_filter_str}=    Run Keyword    dl TTIDIR Filter Str
    ${cmd}=    Catenate    SEPARATOR=
    ...    ${cmd}${ttidir_filter_str}NR>=1{for\(i=1;i in ar1;i++\)printf \"%s%s%s%s\",$ix[ar1[i]],\",\",$\(NF/2+ix[ar1[i]]\),\",\";print \"\"}\'
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} | sed -e '/^\\(rnti,65535\\),.*/d' -e '/^\\(rnti,0\\),.*/d' | sed \'/.*${filter_out}.*/!d\'
    ${ttidir_filter_str}=    Run Keyword    dl TTIDIR Filter Again
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} ${ttidir_filter_str} > ${log_path}/dl_col_filter.txt
    OperatingSystem.Run    ${cmd}
    [Return]    dl_col_filter.txt

Eval TtiDir txNum ul
    [Arguments]    ${maxHarqTxDrb}=0
    ${exp_txNum}    Evaluate    list(range(1, (${maxHarqTxDrb}+1)))
    [Return]    ${exp_txNum}

Eval TtiDir txNum dl
    [Arguments]    ${maxHarqTxDrb}=0
    ${exp_txNum}    Evaluate    list(range(0, (${maxHarqTxDrb}+1)))
    [Return]    ${exp_txNum}

Validate txNumber ul
    [Arguments]      ${maxHarqTxDrb}=${EMPTY}    ${flt_file_Column}=${None}
    ${cmd}=    Set Variable    cat ${flt_file_Column} | awk -F\',\' \'{print $6}\'
    ${txnum_list}    OperatingSystem.Run    ${cmd}
    ${txnum_list}=    Evaluate    list(map(float, @{tx_num_list.split('\n')}))
    ${txnum_list}=    Evaluate    list(map(int, @{tx_num_list}))
    ${txnum_list}=    remove duplicates    ${tx_num_list}
    ${exp_txnum_list}    Run Keyword    Eval TtiDir txNum ul    ${maxHarqTxDrb}
    List Should Contain Sub List    ${exp_txnum_list}    ${txnum_list}

Validate txNumber dl
    [Arguments]      ${maxHarqTxDrb}=${EMPTY}    ${flt_file_Column}=${None}
    ${cmd}=    Set Variable    cat ${flt_file_Column} | awk -F\',\' \'{print $6}\'
    ${txnum_list}    OperatingSystem.Run    ${cmd}
    ${txnum_list}=    Evaluate    list(map(float, @{tx_num_list.split('\n')}))
    ${txnum_list}=    Evaluate    list(map(int, @{tx_num_list}))
    ${txnum_list}=    remove duplicates    ${tx_num_list}
    ${exp_txnum_list}    Run Keyword    Eval TtiDir txNum dl    ${maxHarqTxDrb}
    List Should Contain Sub List    ${exp_txnum_list}    ${txnum_list}

Validate Lcgs
    [Arguments]      ${exp_lcgs}=2    ${flt_file_Column}=${None}
    ${cmd}=    Set Variable    cat ${flt_file_Column} | awk -F\',\' \'{print $10,$12,$14,$16,$18,$20,$22,$24}\'
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} | awk \'{for\(n=1;n<=NF;n++\)t[n]+=$n}END{for\(n=1;n<=NF;n++\)printf t[n]\" \";print\"\\n\"}\'
    ${buffbytes_lcg_list}    OperatingSystem.Run    ${cmd}
    ${buffbytes_lcg_list}=    Set Variable    ${buffbytes_lcg_list.split(' \n')[0]}
    ${buffbytes_lcg_list}=    Evaluate    list(map(float, @{buffbytes_lcg_list.split(' ')}))
    ${buffbytes_lcg_list}=    Evaluate    list(map(int, @{buffbytes_lcg_list}))
    Remove Values From List    ${buffbytes_lcg_list}    ${0}
    ${add_lcgs}    Evaluate    int(len(${buffbytes_lcg_list}))
    Should Be Equal    '''${add_lcgs}'''    '''${exp_lcgs}'''

Validate Scheduled Bytes Per Bearer
    [Arguments]      ${exp_bears}=2    ${flt_file_Column}=${None}
    ${cmd}=    Set Variable    cat ${flt_file_Column} | awk -F\',\' \'{print $12,$14,$16,$18}\'
    ${cmd}=    Catenate    SEPARATOR=    ${cmd} | awk \'{for\(n=1;n<=NF;n++\)t[n]+=$n}END{for\(n=1;n<=NF;n++\)printf t[n]\" \";print\"\\n\"}\'
    ${buffbytes_bear_list}    OperatingSystem.Run    ${cmd}
    ${buffbytes_bear_list}=    Set Variable    ${buffbytes_bear_list.split(' \n')[0]}
    ${buffbytes_bear_list}=    Evaluate    list(map(float, @{buffbytes_bear_list.split(' ')}))
    ${buffbytes_bear_list}=    Evaluate    list(map(int, @{buffbytes_bear_list}))
    Remove Values From List    ${buffbytes_bear_list}    ${0}
    ${add_bears}    Evaluate    int(len(${buffbytes_bear_list}))
    Should Be Equal    '''${add_bears}'''    '''${exp_bears}'''

Check MaxHarqNum
    [Arguments]      ${tag}=CB008285_B_01    ${tti_dire}=ul    ${bear_num}=single    ${single}=true
    ...    ${filter_out}=\\(physCellId 52\\) max    ${dec_output}=changed_csv_file*
    ...    ${maxulHarqTxDrb}=${None}    ${maxdlHarqTxDrb}=${None}
    ...    ${flt_file_Column}=${None}
    ${cmd}=    Set Variable    cat ${flt_file_Column} | awk -F\',\' \'{print $8}\'
    ${maxharqnum}    OperatingSystem.Run    ${cmd}

    ${maxharqnum}=    Evaluate    list(map(float, @{maxharqnum.split('\n')}))
    ${maxharqnum}=    Evaluate    list(map(int, @{maxharqnum}))
    ${maxharqnum}=    remove duplicates    ${maxharqnum}
    ${maxHarqTxDrb}=    Set Variable    ${max${tti_dire}HarqTxDrb}
    @{single_maxharqnum}    Set Variable    ${maxHarqTxDrb}
    ${single_maxharqnum}=    Evaluate    list(map(int, @{single_maxharqnum}))
    Run Keyword    single ${single} drb maxharq validate    ${maxharqnum}    ${single_maxharqnum}

single true drb maxharq validate
    # Invoke Keyword: Check MaxHarqNum
    [Arguments]    ${maxharqnum}=${None}    ${single_maxharqnum}=${None}
    should be equal    ${maxharqnum}    ${single_maxharqnum}

single false drb maxharq validate
    # Invoke Keyword: Check MaxHarqNum
    [Arguments]    ${maxharqnum}=${None}    ${single_maxharqnum}=${None}
    List Should Contain Sub List    ${maxharqnum}    ${single_maxharqnum}

GNB SCF Validation
    [Arguments]    ${scf_validate}=${Empty}
    Run Keyword Unless    '''${scf_validate}'''=='''${Empty}''' or '''${scf_validate}'''=='''[]'''
    ...    Object Should Exist    ${scf_validate}

SA UE Attach Should Fail
    [Arguments]    ${ue_id}=81    ${cell_id}=1
    Stop Capture Wireshark Log
    Start To Capture Wireshark Log    att_fail_${ue_id}
    Sleep    10s    add sometime to make sure pcap can be monitored
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id} enb=2
    ...    pass_regexp=EGATE\>
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=RRC Reject was received
    Sleep    1min    add sometime to make sure pcap can be monitored
    Stop Capture Wireshark Log    att_fail_${ue_id}

SA UE Attach And Detach Should Success
    [Arguments]    ${ue_id}=81    ${cell_id}=1    ${pdu_id}=1    ${nwslice_id}=1    ${gw_id}=1
    Start To Capture Wireshark Log    att_succ_${ue_id}
    SA UE Attach    ue_id=${ue_id}    cell_id=${cell_id}=1    pdu_id=${pdu_id}
    ...    nwslice_id=${nwslice_id}    gw_id=${gw_id}
    Sleep    1s    wait ue attached
    UE Deregister From gNB    ue_id=${ue_id}
    Stop Capture Wireshark Log    att_succ_${ue_id}
