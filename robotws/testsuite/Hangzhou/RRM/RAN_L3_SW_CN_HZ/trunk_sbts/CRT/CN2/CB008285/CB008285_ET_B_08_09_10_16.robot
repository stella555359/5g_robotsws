*** Settings ***

Documentation
...     author: keyu.du
...     contact: keyu.a.du@nokia-sbell.com
...     squad group: RAN_L3_SW_CN_2
...     Feature CB008285 in TRUNK program

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
...    @{CB008285_a_enable}
...    @{CB008285_enable_parameter}
...    @{CB009189_c_enable}
...    NRBTS-1:srbInactivityTimerSA=120

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
...    NRCELL:actLongPucchResourceOpt=false
...    NRCELL:eblRplCellSelectionWithCA=false
...    NRCELL:actOsiMismatchCheck=false
#...    NRCELL:actSmallestRRCSetup=true

@{CB009189_c_enable}
...    NRBTS-1:actServiceAwarePDCPConfig=true
...    NRBTS-1:thpHistDownlinkMaxRange=1000000
...    NRBTS-1:thpHistUplinkMaxRange=100000
...    NRBTS-1:actIpThpt=true
...    NRBTS-1:actThpDist=true
...    NRBTS-1:thpHistScale=linear
...    NRBTS-1:actMultiDrbNSA=false
...    NRBTS-1:actNrpmqapProfiles=true
...    NRBTS-1:cipherPrefL:nea0=1
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1/NRPMRNL-1:miNrHighRlcCellNrpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrF1UInterfaceCUpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrNgInterfaceNrpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrNsaAcCuNrpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrPRBthroughputpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrPdcpCellNrpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrSaCuNrpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrUeQuan=5min
...    NRBTS-1/NRPMRNL-1:miNrUeStatNrpmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrX2UInterfacepmqap=5min
...    NRBTS-1/NRPMRNL-1:miNrX2ccNrpmqap=5min
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgProfType=SA
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfg5qiRange=1-9
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgQciRange=${EMPTY}
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mcc=311
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mnc=489
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgPlmnId:mncLength=3
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgSliceId:sd=13714341
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:cfgSliceId:sst=1
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:thpHistScale=linear
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:thpHistDownlinkMaxRange=1000000
...    NRBTS-1/NRPMRNL-1/NRPMQAP-1:thpHistUplinkMaxRange=100000
...    NRCELL:prachConfigurationIndex=38
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4
...    NRCELL:actServiceAwareConfig=true
...    NRCELL:adaptiveSrLoadThresholdDown=50
...    NRCELL:adaptiveSrLoadThresholdUp=80

@{CB008285_B_08_F_para}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl=false

@{CB008285_B_08_T_para}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl=true

@{CB008285_B_08_recover_para}
...    NRBTS-1:cipherPrefL:nea0=1
...    delete:NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl

@{CB008285_B_09_para}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1/NRDRB_5QI-6:fiveqiValueList=80
...    NRBTS-1/NRDRB_5QI-6:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS-1/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-16:resType=nonGBR
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
...    NRBTS-1/NRDRB_MAC-5:lcgid=1
...    NRBTS-1/NRDRB_MAC-5:delayTarget=50
...    NRBTS-1/NRDRB_MAC-5:schedulBSD=20ms
...    NRBTS-1/NRDRB_MAC-5:schedulPrio=4
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryDl=true
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl=true
...    NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryDl=true

@{CB008285_B_09_Online_para}
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryUl=false
...    NRBTS/NRDRB_PDCP-4:outOfOrderDeliveryDl=false

@{CB008285_B_09_recover_para}
...    NRBTS-1:cipherPrefL:nea0=1
...    delete:NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryUl
...    delete:NRBTS/NRDRB_PDCP-2:outOfOrderDeliveryDl
...    delete:NRBTS/NRDRB_PDCP-4
...    delete:NRBTS-1/NRDRB_MAC-5
...    delete:NRBTS-1/NRDRB-16
...    delete:NRBTS-1/NRDRB_5QI-6

${MAX_NUM_OOD_CAP_UE}    M55181C00001    #Maximum number of OutOfOrderDelivery capable UEs
${AVG_NUM_OOD_CAP_UE_NOM}    M55181C00002    #Average number of OutOfOrderDelivery capable Ues Numerator
${AVG_NUM_UE_DENOM}    M55181C00003    #Average number of UEs denominator

@{PM_Counters_Check_A35_val}
...    NRCELL-1:NUEQN:${MAX_NUM_OOD_CAP_UE}
...    NRCELL-1:NUEQN:${AVG_NUM_OOD_CAP_UE_NOM}
...    NRCELL-1:NUEQN:${AVG_NUM_UE_DENOM}

@{CB008285_B_10_para}
...    NRBTS-1/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS-1/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-16
...    NRBTS-1/NRDRB-16:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-5
...    NRBTS-1/NRDRB-16:nrDrbPdcpDN=MRBTS-1/NRBTS-1/NRDRB_PDCP-4
...    NRBTS-1/NRDRB-16:nrDrbRlcAmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_AM-2
...    NRBTS-1/NRDRB-16:resType=nonGBR
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
...    NRBTS-1/NRDRB-16:nsaDrbParam=${EMPTY}
...    NRBTS-1/NRDRB_MAC-5:lcgid=1
...    NRBTS-1/NRDRB_MAC-5:delayTarget=50
...    NRBTS-1/NRDRB_MAC-5:schedulBSD=20ms
...    NRBTS-1/NRDRB_MAC-5:schedulPrio=12
...    NRBTS-1/NRDRB_PDCP-4:outOfOrderDeliveryUl=false
...    NRBTS-1/NRDRB_PDCP-4:outOfOrderDeliveryDl=false
...    NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl=true
...    NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryDl=true
...    NRBTS-1/NRDRB_PDCP-2:tReorderingUl=ms0

@{CB008285_B_10_recover_para}
...    NRBTS-1/NRDRB_5QI-2:fiveqiValueList=6
...    NRBTS-1/NRDRB_5QI-2:nrDrbDN=MRBTS-1/NRBTS-1/NRDRB-11
...    delete:NRBTS-1/NRDRB-16
...    delete:NRBTS-1/NRDRB_MAC-5
...    delete:NRBTS-1/NRDRB_PDCP-4
...    delete:NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl
...    delete:NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryDl
...    NRBTS-1/NRDRB_PDCP-2:tReorderingUl=ms100

${UL_PDCP_SDU_CU_PMQAP}    M55352C02001
${UL_PDCP_PDU_F1_PMQAP}    M55362C00001

@{CB008285_B_10_PM_Counters_Check}
...    NRCELL-3/NRPMQAP-1:PDCPQ:${UL_PDCP_SDU_CU_PMQAP}>0
...    NRCELL-3/NRPMQAP-1:F1UPQ:${UL_PDCP_PDU_F1_PMQAP}>0

@{CB008285_B_16_para}
...    NRBTS-1/NRCELLGRP-0:maxUlHarqTx=5
...    NRBTS-1/NRCELLGRP-0:maxDlHarqTx=5
...    NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl=true
...    NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryDl=true
...    NRBTS-1/NRDRB-12:discardTimer=10ms
...    NRBTS-1/NRDRB-12:discardTimerUl=10ms
...    NRBTS-1/NRDRB-12:rlcMode=RLC_UM
...    NRBTS-1/NRDRB-12:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-12:nrDrbRlcUmDN=MRBTS-1/NRBTS-1/NRDRB_RLC_UM-1
...    NRBTS-1/NRDRB_RLC_UM-1:dlTReassemblyUm=ms15
...    NRBTS-1/NRDRB_RLC_UM-1:ulTReassemblyUm=ms15

@{CB008285_B_16_recover_para}
...    NRBTS-1/NRDRB-12:dlFlowControlAlgo=3gppFlowControl
...    NRBTS-1/NRDRB-12:rlcMode=RLC_AM
...    NRBTS-1/NRDRB-12:discardTimer=infinity
...    delete:NRBTS-1/NRDRB-12:discardTimerUl
...    NRBTS-1/NRDRB-12:nrDrbRlcUmDN=${EMPTY}
...    delete:NRBTS-1/NRDRB_RLC_UM-1
...    delete:NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryUl
...    delete:NRBTS-1/NRDRB_PDCP-2:outOfOrderDeliveryDl

${dl_pdcp_sdus_transmitted}    M55319C01007

${UL_PDCP_SDU_CU_PMQAP}    M55352C02001
${UL_PDCP_PDU_F1_PMQAP}    M55362C00001


${DL_SDU_DISC_TMR_QOS_GRP_07}    M55320C20007
${DL_DELAY_DISC_QOS_GRP_07}    M55319C09007
${DL_SDU_TX_SA_QOS_GRP_07}    M55319C11007

@{CB008285_B_16_PM_Counters_Check}
...    NRBTS-1:PDCP2:${DL_SDU_DISC_TMR_QOS_GRP_07}
...    NRBTS-1:PDCP1:${DL_DELAY_DISC_QOS_GRP_07}
...    NRBTS-1:PDCP1:${DL_SDU_TX_SA_QOS_GRP_07}
...    NRCELL-1/NRPMQAP-1:PDCPQ:${UL_PDCP_SDU_CU_PMQAP}
...    NRCELL-1/NRPMQAP-1:F1UPQ:${UL_PDCP_PDU_F1_PMQAP}

*** Test Cases ***
CB008285_B_08_9189_C27_SA_DRB_setup_wo_outoforder_then_uplink_only_ue_not_support
    [Documentation]
    ...    1. This user scenario porpuse is to verify the PDCP behavior for the transmission when DRB set up with out of order
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR2 TDD cells are configured with frequency NRFR2 in band n257 with 100MHz bandwidths.
    ...    b.NRFR2 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOlrderDeliveryDl = true , outOfOrderDeliveryUl = false
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.A non-VoNR SA DRB is set up without out of order PDCP delivery.
    ...    b.UE detach.
    Set Parameter    para=${CB008285_B_08_F_para}
    Start UE Attach UE not support outoforder
    ...    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=1    gw_id=1
    Recover Parameter    para=${CB008285_B_08_T_para}
    Start UE Attach UE not support outoforder
    ...    ue_id=82    cell_id=3    pdu_id=1    nwslice_id=1    gw_id=1
    Check Wireshark Log
    ...    a2a_ini_file=${CURDIR}${/}a2a_CB008285_08${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log
    ...    a2a_ini_file=${CURDIR}${/}a2a_CB008285_08${/}a2a.ini
    Recover Parameter    para=${CB008285_B_08_recover_para}

CB008285_B_09_9189_C35_SA_online_modification_Multiple_DRBs_for_outoforder_both_link
    [Documentation]
    ...    1. The purpose of this test case is to verify the PDCP behavior for the transmission when DRB set up with out of order.
    ...    2. Configuration
    ...    configuration on BTS
    ...    a.FR2 TDD cells are configured with frequency NRF1 in band n257 with 100MHz bandwidths.
    ...    b.NRF2 cell has NRCELL-cellDepType set to SA or both
    ...    c.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for 5QI_6
    ...    d.NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = true , outOfOrderDeliveryUl = true for 5QI_80
    ...    3. Test Case Steps:
    ...    a.UE attach and set up PDU session.5QI_6 is setup with out of order
    ...    b.online change:NRBTS/NRDRB_PDCP/outOfOrderDeliveryDl = false , outOfOrderDeliveryUl = false for 5QI_80.
    ...    c.Add 5QI_80 drb which is setup with out of order.
    ...    d.UE detach.
    Set Parameter    para=${CB008285_B_09_para}
    Clear Counter Files    waite=${True}
    UE attach and Start traffic
    ...    tag=CB008285_B_09    ue_id=81    cell_id=1    pdu_id=1    nwslice_id=1    gw_id=1    qfi_id=1
    ...    trf_id=1    dl_tp=${70}    ul_tp=${10}    duration=${10}
    Recover Parameter     para=${CB008285_B_09_Online_para}
    PDU Add QoSFlow 5QI80    tag=CB008285_B_09    ue_id=81
    A35 counters check
    UE Deregister From gNB    ue_id=81
    Check Wireshark Log
    ...    a2a_ini_file=${CURDIR}${/}a2a_CB008285_09${/}a2a.ini    wait_string=UEContextReleaseComplete::4
    Check RRC Log    a2a_ini_file=${CURDIR}${/}a2a_CB008285_09${/}a2a.ini
    Recover Parameter    para=${CB008285_B_09_recover_para}

CB008285_B_10_9189_B302_013_SA_DRBs_set_up_with_mixed_out_of_order_PDCP_delivery_and_in_order_PDCP_delivery_DL_and_UL
    [Documentation]
    ...     Test Case for CB009189-C PDCP out of order delivery and PDCP discard timer for non-GBR
    ...    1. Configuration
    ...    configuration on BTS
    ...    a.FR2 TDD cells are configured with frequency NRFR2 in band n257 with 100MHz bandwidths.
    ...    b.NRFR2 cell has NRCELL-cellDepType set to SA or both
    ...    c.5QI7--NRBTS/NRDRB_PDCP-1/outOfOlrderDeliveryDl = true , outOfOrderDeliveryUl = true
    ...    d.5QI6--NRBTS/NRDRB_PDCP-1/outOfOlrderDeliveryDl = false , outOfOrderDeliveryUl = false
    ...    3. Test Case Steps:
    ...    a.UEs attach to FR2 NR PCells, set up PDU session.5QI_6 is setup without out of order, 5QI_7 is setup with out of order
    ...    b.Activate Bler Testmode on Airphone trigger gNB UL OOO Delivery.
    ...    d.UE detach.
    ...
    CB008285_B_10 Prepare Parameters and Check List
    UEs Attach With 5QI6 Traffic And Get RRC Log
    Activate Bler Testmode
    ...    ue_id_1st=81    ue_nums=2    bler_type=uldl    num_harq_nack=5
    ...    ul_bler=200,200,0,0,0,0,0,0    dl_bler=100,100,0,0,0,0,0,0
    UEs Start 5QI7 Traffic
    Capturing Traffic On VM    tag=CB008285_B_10
    UE Detach And RRC Log Check
    ...    ue_id_1st=81    ue_nums=2    bler_type=uldl    a2a_ini_file=${CURDIR}${/}a2a_CB008285_10${/}a2a.ini
    Validate Uplink Traffic    tag=CB008285_B_10
    Check OOO And Counters CB008285_B_10
    Recover Parameter    para=${CB008285_B_10_recover_para}

CB008285_B_16_9189-C_27_DRB_setup_for_non_GBR_DL_RLC_UM_with_PDCP_Discard_Timer_with_Flow_control_FR2_TDD_SA
    [Documentation]    *****************
    ...    This user scenario describes the gNB behavior for the transmission of PDCP PDUs when
    ...    'DiscardTimer based SDU discard' for non-GBR bearers is enabled.
    ...    5QI 7 -- NRDRB12 -- NRDRB_MAC-2 -- NRDRB_PDCP-2 -- NRDRB_RLC_AM-2 -- NRDRB_RLC_UM-1 UrlcMode=RLC_UM
    ...    *******************
    Set Parameter    para=${CB008285_B_16_para}
    UE attach and Start traffic
    ...    tag=CB008285_B_16    ue_id=81    cell_id=1    pdu_id=1    qfi_id=2    nwslice_id=1    gw_id=1
    ...    dl_tp=20    ul_tp=20    duration=${10}    trf_id=1
    Activate And DeActivate Bler Testmode
    ...    ue_id_1st=81    ue_nums=1    bler_type=uldl    num_harq_nack=5
    ...    ul_bler=50,50,50,50,50,50,50,50    dl_bler=100,100,100,100,100,100,100,100
    UE Deregister From gNB    ue_id=81
    Check OoO And discard timer Counters
    ...    tag=CB008285_B_16
    ...    a2a_ini_file=${CURDIR}${/}a2a_CB008285_16${/}a2a.ini
    ...    wait_string=rrcReconfigurationComplete::4
    Recover Parameter    para=${CB008285_B_16_recover_para}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=tdd_sa_mmwv/FS/4cells_4T

traffic validate Parse Arguments
    [Arguments]        ${i_step}=0
    ${vars}    Set Variable    ${None}
    ${vars}    Run Keyword Unless    '''${CB008285_B_10_traffic_validate_step_args[${i_step}]}'''=='''${None}'''
    ...    Evaluate    list(${CB008285_B_10_traffic_validate_step_args[${i_step}].split(" ")})
    ${dict_var}    Create Dictionary
    ${dict_var}    Run Keyword Unless    '''${vars}'''=='''${None}'''
    ...    Create Dictionary    @{vars}
    [Return]    ${dict_var}

Set Parameter
    [Arguments]    ${para}=${EMPTY}
    OnlineParamChange    ${para}
    ${gtp_teid_ue_list}    Create List
    Set Suite Variable    ${gtp_teid_ue_list}
    Execute Egate Command    uec_param id=1 reordering_window_size=1000 reordering_timer=200
    ...    pass_regexp=EGATE\>
    Clear Counter Files    wait=${False}

Recover Parameter
    [Arguments]    ${para}=${EMPTY}
    OnlineParamChange    ${para}

UEs Attach With 5QI6 Traffic And Get RRC Log
     UE Attach With Traffic And Get RRC Log
     ...    ue_id=81    cell_id=1    pdu_id=1    qfi_id=1    nwslice_id=1
     ...    gw_id=1    dl_tp=20    ul_tp=20    duration=${10}    trf_id=1
     UE Attach With Traffic And Get RRC Log
     ...    ue_id=82    cell_id=3    pdu_id=1    qfi_id=1    nwslice_id=1
     ...    gw_id=1    dl_tp=20    ul_tp=20    duration=${10}    trf_id=1

UE Attach With Traffic And Get RRC Log
    [Arguments]    ${ue_id}=81    ${cell_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${nwslice_id}=1
    ...    ${gw_id}=1    ${dl_tp}=20    ${ul_tp}=20    ${duration}=${10}    ${trf_id}=1
    Start RRC Log    ${ue_id}
    SA UE Attach    ue_id=${ue_id}    cell_id=${cell_id}    pdu_id=${pdu_id}    nwslice_id=${nwslice_id}
    ...    gw_id=${gw_id}
    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...    send_dl=${dl_tp}    send_ul=${ul_tp}    sleep_time=${duration}s    trf_id=${trf_id}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=7 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 fiveQI:7
    Get RRC log
    Checkout GTP Teid    ue_id=${ue_id}

Checkout GTP Teid
    [Arguments]    ${ue_id}=81
    ${cmd}=    Catenate    sed -n \'s/^.*QFI:[1-2] fiveQI:[1-9] TEID:\\([0-9]\\+\\) .*$/\\1/p\' ${SAVE LOG DIRECTORY}/rrc_${ue_id}.log
    ${uldl_gtp_teid}    OperatingSystem.Run    ${cmd}
    ${uldl_gtp_teid}    Evaluate    list(@{uldl_gtp_teid.split('\n')})
    Append To List    ${gtp_teid_ue_list}    ${uldl_gtp_teid}
    Set Suite Variable    ${gtp_teid_ue_list}

UEs Start 5QI7 Traffic
    Send And Verify Throuput
    ...    ue_id=81    pdu_id=1    qfi_id=2    send_dl=20    send_ul=20    sleep_time=${10}s    trf_id=2
    Send And Verify Throuput
    ...    ue_id=82    pdu_id=1    qfi_id=2    send_dl=20    send_ul=20    sleep_time=${10}s    trf_id=2

Capturing Traffic On VM
    [Arguments]    ${tag}=CB008285_B_08
    Run Keyword    Start Capturing Traffic On VM     ${tag}
    Sleep    10s    wait wireshark log collecting
    Run Keyword    Stop Capturing Traffic On VM    ${tag}

Start Capturing Traffic On VM
    [Arguments]    ${tag}=CB008285_B_08
    _Stop Capture UTE Wireshark
    ${UTE_WIRESHARK_FLAG}    Set Variable    ${True}
    Start To Capture UTE Wireshark On Tag    ${tag}

Start To Capture UTE Wireshark On Tag
  [Arguments]    ${tag}    ${if_name}=eth3
  ${log_dir}    Set Variable    ${SAVE LOG DIRECTORY}
  Execute Cmd On Pc
  ...    sudo tcpdump -i ${if_name} -s0 -vvv -w ${log_dir}${/}ute_wireshark_${if_name}.pcap>& tmp_${if_name}.txt&

Stop Capturing Traffic On VM
    [Arguments]    ${tag}=CB008285_B_08
    _Stop Capture UTE Wireshark

Activate Bler Testmode
    [Arguments]      ${ue_id_1st}=81    ${ue_nums}=4    ${bler_type}=dl    ${num_harq_nack}=5
    ...    ${ul_bler}=200,200,200,200,200,200,200,200    ${dl_bler}=50,50,50,50,50,50,50,50
    ${ue_id_last}    Evaluate    ${ue_id_1st}+${ue_nums}
    FOR    ${ue_id}    IN RANGE     ${ue_id_1st}    ${ue_id_last}
        Run Keyword    Activate Bler ${bler_type}
        ...    ue_id=${ue_id}    num_harq_nack=${num_harq_nack}
        ...    ul_bler=${ul_bler}    dl_bler=${dl_bler}
    END

Deactivate Bler Testmode
    [Arguments]    ${ue_id_1st}=81    ${ue_nums}=4    ${bler_type}=uldl
    ${ue_id_last}    Evaluate    ${ue_id_1st}+${ue_nums}
    FOR    ${ue_id}    IN RANGE     ${ue_id_1st}    ${ue_id_last}
        Deactivate Bler    ue_id=${ue_id}    bler_type=${bler_type}
    END

Validate Uplink Traffic
    [Documentation]
    ...     pcap filter
    ...     UE81-5QI6-ULPDU
    ...     udp.stream==1( 1st UE, 1:UL 2:DL)
    ...     gtp.ext_hdr.pdu_ses_con.qos_flow_id==1 (1:QFI1 2:QFI2)
    ...     gtp.ext_hdr.pdu_ses_con.pdu_type==1 (1:UL 0:DL)
    ...     frame.protocols==eth:ethertype:ip:udp:gtp:ip:udp:data && ip.src && udp.srcport && gtp.ext_hdr.pdu_ses_con.qos_flow_id==1
    ...     && gtp.ext_hdr.pdu_ses_con.pdu_type==1 && udp.stream==1
    [Arguments]    ${tag}=CB008285_B_10
    ${validate_steps}=    Evaluate    int(len(${${tag}_traffic_validate_step_args}))
    FOR    ${idx_step}    IN RANGE    0    ${validate_steps}
        ${kw_args}    traffic validate Parse Arguments    ${idx_step}
        ${gtp_teid}    Get From Dictionary    ${kw_args}    gtp_teid
        Set To Dictionary    ${kw_args}    gtp_teid    ${${gtp_teid}}
        Run Keyword    Validate Traffic    &{kw_args}
    END

Validate Traffic
    [Arguments]
    ...    ${ue_id}=81    ${qfi_id}=1    ${data_dir}=UL    ${exp_OOO}=true    ${gtp_teid}=1
    ${filter}=    Set Variable     ${filter_UE${ue_id}_QFI${qfi_id}_${data_dir}} && gtp.teid==${gtp_teid}
    ${csv_title_list}=    Set Variable    -e frame.protocols -e ip.src -e ip.dst -e udp.srcport -e udp.dstport -e ip.id
    Convert PCAP To CSV By MCShark
    ...    local_file_path=${SAVE LOG DIRECTORY}/ute_wireshark_eth3.pcap
    ...    output_file=${SAVE LOG DIRECTORY}/ute_wireshark_eth3_UE${ue_id}_QFI${qfi_id}_${data_dir}.csv    filter=${filter}
    ...    csv_title_list=${csv_title_list}
    ${num_gtp}    ${ret_ooo}    Check Packets Order
    ...    local_csv_path=${SAVE LOG DIRECTORY}/ute_wireshark_eth3_UE${ue_id}_QFI${qfi_id}_${data_dir}.csv
    ...    exp_OOO=${exp_OOO}
    ${num_gtp}=    Evaluate    int(${num_gtp})-1
    ${ret_count}    Evaluate    int(len(${ret_ooo}))
    Run Keyword    Expect OOO ${exp_OOO}    ret_count=${ret_count}    num_gtp=${num_gtp}

Expect OOO true
    # Invoke Keyword: Validate Traffic
    [Arguments]    ${ret_count}=0    ${num_gtp}=0
    Should Be True    ${ret_count}>0

Expect OOO false
    # Invoke Keyword: Validate Traffic
    [Arguments]    ${ret_count}=0    ${num_gtp}=0
    Should Be Equal    ${ret_count}    ${num_gtp}

UE Detach And RRC Log Check
    [Arguments]    ${ue_id_1st}=81    ${ue_nums}=2    ${bler_type}=uldl
    ...    ${a2a_ini_file}=${CURDIR}${/}a2a_CB008285_10${/}a2a.ini
    UE Detach and Deactivate Bler Testmode
    ...    ue_id_1st=${ue_id_1st}    ue_nums=${ue_nums}    bler_type=${bler_type}
    Check RRC Log    a2a_ini_file=${a2a_ini_file}

UE Detach and Deactivate Bler Testmode
    [Arguments]    ${ue_id_1st}=81    ${ue_nums}=4    ${bler_type}=uldl
    ${ue_id_last}    Evaluate    ${ue_id_1st}+${ue_nums}
    FOR    ${ue_id}    IN RANGE     ${ue_id_1st}    ${ue_id_last}
        Deactivate Bler    ue_id=${ue_id}    bler_type=${bler_type}
        UE Deregister From gNB    ue_id=${ue_id}
    END

Convert PCAP To CSV By MCShark
    [Arguments]    ${local_file_path}    ${output_file}    ${filter}    ${csv_title_list}
    [Documentation]    This kw is used to Convert PCAP To CSV By MCShark
    ...    | Input Parameters | Man. | Description |
    ...    | bip_file | yes | bip file name which is colleted |
    ...    | output_file | yes | the path of csv file is stored |
    ...    | filter | yes | What is used to filter messages |
    ...    | csv_title_list | yes | csv file list |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...    |with Title: -E header=y|n | with Seprate: -E separator=, | with quote: -E quote=d|s|n |
    ...    |occurrence=f|l|a      print first, last or all occurrences of each field
    ...    Example
    ...    | Convert PCAP To CSV By MCShark | ${SAVE LOG DIRECTORY}/wireshark.pcap | ./csv_xxx.csv | ${filter} | ${csv_title_list} |
    ...
    ${cmd}=    Catenate    tshark -r ${local_file_path} -Y '${filter}' -T fields ${csv_title_list}
    ...     -E header=n -E separator=, -E quote=n -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Check Packets Order
    [Arguments]    ${local_csv_path}    ${exp_OOO}=true
    [Documentation]
    ...    Check if packets from specific traffic flow came in order
    ...
    ...    :param full_path_to_csv: (str) absolute path to CSV file
    ...    :param flow_port:        (str) UDP src port configured in WTS
    ...    :param out_of_order      (bool) configure checking if packets should come in order (False) or out of order (True)
    ${cmd}=    Catenate    awk \'END{print NR}\' ${local_csv_path}
    ${num_gtp_pack}    OperatingSystem.Run    ${cmd}
    ${num_gtp_pack}    Evaluate    int(${num_gtp_pack})
    ${cmd}=    Catenate    awk -F, \'NR==FNR{a[FNR]=$NF;}NR>\(FNR+1\){print a[j]\",\"$NF;j++}\'
    ...    ${local_csv_path} ${local_csv_path} | awk -F, \'NR>1{print $2-$1}\'
    ${exp_ooo_str}=    Run Keyword    Order Filter Str For Exp OOO ${exp_ooo}
    ${cmd}=    Catenate     ${cmd}     ${exp_ooo_str}
    ${pack_id_gap_list}    OperatingSystem.Run    ${cmd}
    ${pack_id_gap_list}    Evaluate    list(map(int,@{pack_id_gap_list.split('\n')}))
    [Return]    ${num_gtp_pack}    ${pack_id_gap_list}

Order Filter Str For Exp OOO true
    # Invoke Keyword: Check Packets Order
    [Return]    | awk \'$1<1 && $1>-2000{print $1}\'

Order Filter Str For Exp OOO false
    # Invoke Keyword: Check Packets Order
    [Return]    | awk \'$1>0 || $1<-2000{print $1}\'

Check OOO And Counters CB008285_B_10
    Check Counters    ${CB008285_B_10_PM_Counters_Check}

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${OOO_ue_nr_capabilities}
    Update Cfg    ue_param id=82 ue_nr_capabilities=${OOO_ue_nr_capabilities}
    B10 Egate Qosflow Setting B1
    B10 Egate Qosflow Setting B2

B10 Egate Qosflow Setting B1
    Delete Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=1 5qi=1
    Update Cfg    set_qosflow id=2 5qi=2 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=3 5qi=3 gfbr_ul=30720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=4 5qi=4 gfbr_ul=720 gfbr_dl=30720 mfbr_ul=30720 mfbr_dl=30720 qos_flow_type=gbr ue=all
    Update Cfg    set_qosflow id=5 5qi=5 priority=2

B10 Egate Qosflow Setting B2
    Update Cfg    set_qosflow id=6 5qi=6 default=on priority=1
    Update Cfg    set_qosflow id=7 5qi=7 priority=7
    Update Cfg    set_qosflow id=8 5qi=8 priority=9
    Update Cfg    set_qosflow id=9 5qi=9 priority=9
    Update Cfg    set_qosflow id=10 5qi=80 priority=9

Prepare A35 Conters Check Exp List
    ${exp_a35_str}=    Set Variable    '[1, 299]_[1, 300]_[2, 599]_[2, 600]_[1, 299, 299]_[1, 300, 300]'
    ${exp_a35_list}=    Evaluate    list(${exp_a35_str}.split("_"))
    ${exp_a35_list_1}    Get Slice From List    ${exp_a35_list}    start=0    end=4
    ${exp_a35_list_2}    Get Slice From List    ${exp_a35_list}    start=4    end=6
    [Return]    ${exp_a35_list_1}    ${exp_a35_list_2}

A35 counters check
    ${exp_a35_list_1}    ${exp_a35_list_2}    Prepare A35 Conters Check Exp List
    ${val_A35_PM_1}    A35 counters check Interval Pegging
    Remove From List    ${val_A35_PM_1}    1
    ${ret_a35_1}    Evaluate    '${val_A35_PM_1}' in @{exp_a35_list_1}
    Should Be Equal    ${ret_a35_1}    ${True}
    Clear Counter Files
    ${val_A35_PM_2}    A35 counters check Interval Pegging
    ${ret_a35_2}    Evaluate    '${val_A35_PM_2}' in @{exp_a35_list_2}
    Should Be Equal    ${ret_a35_2}    ${True}

A35 counters check Interval Pegging
    ${val_A35_PM}    Get counters value    ${PM_Counters_Check_A35_val}
    [Return]    ${val_A35_PM}

Start UE Attach UE not support outoforder
    [Arguments]    ${ue_id}=81    ${cell_id}=1    ${pdu_id}=1    ${nwslice_id}=1    ${gw_id}=1
    Start To Capture Wireshark Log    log${ue_id}
    Start RRC Log    rrclog${ue_id}
    SA UE Attach    ue_id=${ue_id}    cell_id=${cell_id}    pdu_id=${pdu_id}    nwslice_id=${nwslice_id}
    ...    gw_id=${gw_id}
    Stop Capture Wireshark Log    log${ue_id}
    Get RRC Log
    UE Deregister From gNB    ue_id=${ue_id}

PDU Add QoSFlow 5QI80
    [Arguments]    ${tag}=CB008285_B_09    ${ue_id}=81
    Stop Capture Wireshark Log
    Start To Capture Wireshark Log    mod_${ue_id}_${tag}
    Start RRC Log    mod_${ue_id}_${tag}
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=10 by=amf
    ...    pass_regexp=Added QosFlow with QFI:2 fiveQI:80
    Stop Capture Wireshark Log    mod_${ue_id}_${tag}
    Get RRC Log
    Send And Verify Throuput    qfi_id=2    ue_id=${ue_id}    pdu_id=1

UE attach and Start traffic
    [Arguments]
    ...    ${tag}=CB008285_B_09    ${ue_id}=81    ${cell_id}=1    ${pdu_id}=1    ${nwslice_id}=1    ${gw_id}=1    ${qfi_id}=1
    ...    ${trf_id}=1    ${dl_tp}=${70}    ${ul_tp}=${10}    ${duration}=${10}
    Stop Capture Wireshark Log
    Start To Capture Wireshark Log    att_${ue_id}_${tag}
    Start RRC Log    att_${ue_id}_${tag}
    SA UE Attach    ue_id=${ue_id}    cell_id=${cell_id}    pdu_id=${pdu_id}    nwslice_id=${nwslice_id}
    ...    gw_id=${gw_id}
    Run Keyword    Egate Command in Case ${tag}
    ...    ue_id=${ue_id}    pdu_id=${pdu_id}
    Sleep    5s    wait UE attach and Start traffic
    Stop Capture Wireshark Log    att_${ue_id}_${tag}
    Get RRC Log

    Send And Verify Throuput    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...    send_dl=${dl_tp}    send_ul=${ul_tp}    sleep_time=${duration}s    trf_id=${trf_id}

Egate Command in Case CB008285_B_16
    # Invoke Keyword: UE attach and Start traffic
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=7 by=amf    Added QosFlow

Egate Command in Case CB008285_B_08
    # Invoke Keyword: UE attach and Start traffic
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Sleep    1s    wait UE${ue_id} attach pdu=${pdu_id} then Start traffic

Egate Command in Case CB008285_B_09
    # Invoke Keyword: UE attach and Start traffic
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Sleep    1s    wait UE${ue_id} attach pdu=${pdu_id} then Start traffic

Egate Command in Case CB008285_B_10
    # Invoke Keyword: UE attach and Start traffic
    [Arguments]    ${ue_id}=81    ${pdu_id}=1
    Sleep    1s    wait UE${ue_id} attach pdu=${pdu_id} then Start traffic

Activate And DeActivate Bler Testmode
    [Arguments]
    ...    ${ue_id_1st}=81    ${ue_nums}=1    ${bler_type}=uldl    ${num_harq_nack}=5
    ...    ${ul_bler}=50,50,50,50,50,50,50,50    ${dl_bler}=100,100,100,100,100,100,100,100
    Activate Bler Testmode
    ...    ue_id_1st=${ue_id_1st}    ue_nums=${ue_nums}    bler_type=${bler_type}    num_harq_nack=${num_harq_nack}
    ...    ul_bler=${ul_bler}    dl_bler=${dl_bler}
    Sleep    30s    wait bler testmode activated
    Deactivate Bler Testmode     ue_id_1st=${ue_id_1st}    ue_nums=${ue_nums}    bler_type=${bler_type}

Check OoO And discard timer Counters
    [Arguments]    ${tag}=CB008285_B_16
    ...    ${a2a_ini_file}=${CURDIR}${/}a2a_CB008285_16${/}a2a.ini
    ...    ${wait_string}=rrcReconfigurationComplete::4
    Check Wireshark Log
    ...    a2a_ini_file=${a2a_ini_file}    wait_string=${wait_string}
    Check RRC Log
    ...    a2a_ini_file=${a2a_ini_file}
    Run Keyword    Check Counters ${tag}

Check Counters CB008285_B_16
    ${dl_pdcp_sdus_discarded}    ${dl_pdcp_sdu_delay}    ${dl_pdcp_sdus_transmitted}
    ...    ${UL_PDCP_SDU_CU_PMQAP_cn}    ${UL_PDCP_SDU_F1_PMQAP_cn}
    ...    Prepare Counter CB008285_B_16 Val

    Eval Counter CB008285_B_16
    ...    dl_pdcp_sdus_discarded=${dl_pdcp_sdus_discarded}    dl_pdcp_sdu_delay=${dl_pdcp_sdu_delay}
    ...    dl_pdcp_sdus_transmitted=${dl_pdcp_sdus_transmitted}
    ...    UL_PDCP_SDU_CU_PMQAP_cn=${UL_PDCP_SDU_CU_PMQAP_cn}
    ...    UL_PDCP_SDU_F1_PMQAP_cn=${UL_PDCP_SDU_F1_PMQAP_cn}

Prepare Counter CB008285_B_16 Val
    @{pc_DL_16}    Get Counters Value    ${CB008285_B_16_PM_Counters_Check}
    ${dl_pdcp_sdus_discarded}    Set Variable    ${pc_DL_16[0]}
    ${dl_pdcp_sdu_delay}    Set Variable    ${pc_DL_16[1]}
    ${dl_pdcp_sdus_transmitted}    Set Variable    ${pc_DL_16[2]}
    ${UL_PDCP_SDU_CU_PMQAP_cn}    Set Variable    ${pc_DL_16[3]}
    ${UL_PDCP_SDU_F1_PMQAP_cn}    Set Variable    ${pc_DL_16[4]}
    [Return]
    ...    ${dl_pdcp_sdus_discarded}    ${dl_pdcp_sdu_delay}    ${dl_pdcp_sdus_transmitted}
    ...    ${UL_PDCP_SDU_CU_PMQAP_cn}    ${UL_PDCP_SDU_F1_PMQAP_cn}

Eval Counter CB008285_B_16
    [Arguments]    ${dl_pdcp_sdus_discarded}=0    ${dl_pdcp_sdu_delay}=0    ${dl_pdcp_sdus_transmitted}=0
    ...    ${UL_PDCP_SDU_CU_PMQAP_cn}=0    ${UL_PDCP_SDU_F1_PMQAP_cn}=0
    ${discardTimer}    Set Variable    ${10}
    Should Be True    ${dl_pdcp_sdus_discarded}>${0}
    Should Be True    ${dl_pdcp_sdu_delay}>${0}
    Should Be True    ${dl_pdcp_sdus_transmitted}>${0}
    Should Be True    ${UL_PDCP_SDU_CU_PMQAP_cn}>${0}
    Should Be True    ${UL_PDCP_SDU_F1_PMQAP_cn}>${0}
    ${calc_delay_discard}    Evaluate    int(${dl_pdcp_sdu_delay}/1000/${dl_pdcp_sdus_transmitted})<int(10+${discardTimer})
    Should Be True    ${calc_delay_discard}

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
    Execute Egate Command    ue_register id=${ue_id}    is now Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_id} gw=${gw_id} ue=${ue_id} nwslice=${nwslice_id}
    ...    pass_regexp=${pass_regexp}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    detached

Start Trf Traffic ul
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} mbps=${send_ul}

Start Trf Traffic dl
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} mbps=${send_dl}

Start Trf Traffic uldl
    # Invoke Keyword: Send And Verify Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi_id}=1    ${send_dl}=10    ${send_ul}=10    ${trf_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=ul trf_id=${trf_id} mbps=${send_ul}
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=dl trf_id=${trf_id} mbps=${send_dl}

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
    # Invoke Keyword: Activate Bler Testmode
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

CB008285_B_10 Prepare Parameters and Check List
    Set Parameter    para=${CB008285_B_10_para}
    Prepare Traffic Validation Steps
    Prepare TShark Decode Filters

Prepare Traffic Validation Steps
    ${CB008285_B_10_traffic_validate_step_args}=    Create List
    ...    ue_id 81 qfi_id 1 data_dir UL exp_OOO false gtp_teid gtp_teid_ue_list[0][0]
    ...    ue_id 81 qfi_id 1 data_dir DL exp_OOO false gtp_teid gtp_teid_ue_list[0][1]
    ...    ue_id 81 qfi_id 2 data_dir UL exp_OOO true gtp_teid gtp_teid_ue_list[0][0]
    ...    ue_id 81 qfi_id 2 data_dir DL exp_OOO false gtp_teid gtp_teid_ue_list[0][1]
    ...    ue_id 82 qfi_id 1 data_dir UL exp_OOO false gtp_teid gtp_teid_ue_list[1][0]
    ...    ue_id 82 qfi_id 1 data_dir DL exp_OOO false gtp_teid gtp_teid_ue_list[1][1]
    ...    ue_id 82 qfi_id 2 data_dir UL exp_OOO true gtp_teid gtp_teid_ue_list[1][0]
    ...    ue_id 82 qfi_id 2 data_dir DL exp_OOO false gtp_teid gtp_teid_ue_list[1][1]
    Set Suite Variable    ${CB008285_B_10_traffic_validate_step_args}

Prepare TShark Decode Filters
    Prepare TShark QFI1 Decode Filters
    Prepare TShark QFI2 Decode Filters

Prepare TShark QFI1 Decode Filters
    ${filter_UE81_QFI1_UL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==1 && gtp.ext_hdr.pdu_ses_con.pdu_type==1
    ${filter_UE81_QFI1_DL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==1 && gtp.ext_hdr.pdu_ses_con.pdu_type==0
    ${filter_UE82_QFI1_UL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==1 && gtp.ext_hdr.pdu_ses_con.pdu_type==1
    ${filter_UE82_QFI1_DL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==1 && gtp.ext_hdr.pdu_ses_con.pdu_type==0
    Set Suite Variable    ${filter_UE81_QFI1_UL}
    Set Suite Variable    ${filter_UE81_QFI1_DL}
    Set Suite Variable    ${filter_UE82_QFI1_UL}
    Set Suite Variable    ${filter_UE82_QFI1_DL}

Prepare TShark QFI2 Decode Filters
    ${filter_UE81_QFI2_UL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==2 && gtp.ext_hdr.pdu_ses_con.pdu_type==1
    ${filter_UE81_QFI2_DL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==2 && gtp.ext_hdr.pdu_ses_con.pdu_type==0
    ${filter_UE82_QFI2_UL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==2 && gtp.ext_hdr.pdu_ses_con.pdu_type==1
    ${filter_UE82_QFI2_DL}    Set Variable    gtp.ext_hdr.pdu_ses_con.qos_flow_id==2 && gtp.ext_hdr.pdu_ses_con.pdu_type==0
    Set Suite Variable    ${filter_UE81_QFI2_UL}
    Set Suite Variable    ${filter_UE81_QFI2_DL}
    Set Suite Variable    ${filter_UE82_QFI2_UL}
    Set Suite Variable    ${filter_UE82_QFI2_DL}
