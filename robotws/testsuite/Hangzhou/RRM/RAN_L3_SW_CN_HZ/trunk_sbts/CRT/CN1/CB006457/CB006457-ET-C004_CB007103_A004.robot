*** Settings ***
Documentation
...    author:  dandan.chen@nokia-sbell.com
...    contact: dandan.chen@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup        Common Suite Setup And Setup Airphone Env
Suite Teardown     Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup         Common Test Setup And Start To Capture Logs
Test Teardown      Common Test Teardown And Stop Capture Logs
Force Tags         QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    RAN_5G_TDD    CLOUD_5G_I_BOO_AP_LOO
...                owner-lena.zhuo   release-SBTS00    CB006457
Resource           ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${SYSCOM_FLAG}    ${True}

${GNB1_CONFIG}    tdd_sansa_cmwv/FS/4cells_2n78_n257_n260

@{PARAMS_IN_SCF}
...    NRCELL:cbraPreamblesPerSsb=n64
...    NRBTS-1:actMultiFrequencyBandIndicatorNRSupport=false
...    NRBTS:cipherPrefL:nea0=9
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRBTS:integrityProtPrefL:nia0=0
...    NRBTS:integrityProtPrefL:nia1_128=0
...    NRBTS:integrityProtPrefL:nia2_128=0
...    NRBTS:integrityProtPrefL:nia3_128=9
...    @{6457_related}
...    @{NRHOIF}
...    @{PMQAP}
...    NRCELL:fPdcchMonOccsnPo=2
...    NRCELL:type0SearchSpaceConfigurationIndex=5
...    NRCELL-1:maxNumOfUsersPerNRCell=90
...    NRCELL-1:maxNumOfCaUsersNRCell=60
...    NRCELL-1:msg1FrequencyStart=1
...    NRCELL-4:maxNumOfCaUsersNRCell=60
...    NRCELL-4:maxNumOfUsersPerNRCell=90
...    NRCELL-4:msg1FrequencyStart=1
...    NRCELL-1:maxNumOfSCellAlloc=90
...    NRCELL-1:maxNumOfUsersPerCell=90
...    NRCELL-1:maxNumOfRrcSA=90
...    NRCELL-1:maxNumOfNrDcSnUsers=90
...    NRCELL-4:maxNumOfSCellAlloc=90
...    NRCELL-4:maxNumOfUsersPerCell=90
...    NRCELL-4:maxNumOfRrcSA=90
...    NRCELL-4:maxNumOfNrDcSnUsers=90
...    NRCELL-1:nrarfcn=634090
...    NRCELL-1:gscnOrSsPbchArfcn=7854
...    NRCELL-4:nrarfcn=634778
...    NRCELL-4:gscnOrSsPbchArfcn=7861

@{6457_related}
...    NRBTS:act5qiAndUlNguTnlQosFlowMod=true
...    NRBTS:actArpBasedQosScaling=true
...    NRBTS:actBcsCheck=enabled_NRDC
...    NRBTS:actNonGbrServiceDiff=true
...    NRBTS:multiArpBasedParam:nbrUlDlSF=50|arpPrioLev=2
...    NRBTS:multiArpBasedParam:nbrUlDlSF=5|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=5|arpPrioLev=14
...    NRBTS/NRDRB-11:schedulWeight=10
...    NRBTS/NRDRB-11:nrDcDrbParam:ulDataPathNrDc=ulDataSplit_PrimaryPathMCG
...    NRBTS/NRDRB-11:nrDcDrbParam:ulDataSplitThresholdNrDc=b100
...    NRBTS/NRDRB-12:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-6
...    NRBTS/NRDRB-12:schedulWeight=20
...    NRBTS/NRDRB-13:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-7
...    NRBTS/NRDRB-13:schedulWeight=20
...    NRBTS/NRDRB-13:nrDcDrbParam:ulDataPathNrDc=ulDataSplit_PrimaryPathMCG
...    NRBTS/NRDRB-13:nrDcDrbParam:ulDataSplitThresholdNrDc=b100
...    NRBTS/NRDRB-14:nrDrbMacDN=MRBTS-1/NRBTS-1/NRDRB_MAC-8
...    NRBTS/NRDRB-14:schedulWeight=10
...    NRBTS/NRDRB-16:schedulWeight=1
...    NRBTS/NRDRB-17:schedulWeight=1
...    NRBTS/NRDRB-18:schedulWeight=1
...    NRBTS/NRDRB-19:schedulWeight=1
...    NRBTS/NRDRB-20:schedulWeight=1
...    NRBTS/NRDRB-21:schedulWeight=1
...    NRBTS/NRDRB-22:schedulWeight=1
...    NRBTS/NRDRB-23:schedulWeight=1
...    NRBTS/NRDRB_MAC-2:nbrDl=10000
...    NRBTS/NRDRB_MAC-2:nbrUl=5000
...    NRBTS/NRDRB_MAC-6:nbrDl=15000
...    NRBTS/NRDRB_MAC-6:nbrUl=8000
...    NRBTS/NRDRB_MAC-7:nbrDl=10000
...    NRBTS/NRDRB_MAC-7:nbrUl=5000
...    NRBTS/NRDRB_MAC-8:nbrDl=15000
...    NRBTS/NRDRB_MAC-8:nbrUl=8000
...    NRCELL-1:actNbrForNonGbrBearers=false
...    NRCELL-2:actNbrForNonGbrBearers=false
...    NRCELL-3:actNbrForNonGbrBearers=false
...    NRCELL-4:actNbrForNonGbrBearers=true
...    NRCELL-4:maxNumOfNbrBearers=80
...    NRCELL-4:maxPrbsPerNbrUe=30
...    NRCELL-4:nbrPdcchCongHandlingDl=false
...    NRCELL-4:nbrPdcchCongHandlingUl=false
...    NRCELL-4:nbrPdschCongHandling=false
...    NRCELL-4:nbrPuschCongHandling=false
...    NRCELL:congWeightAlg=arpPrioPerVul

@{NRHOIF}
...    NRCELL-1/NRHOIF-2:a4MeasNrDcEnabled=rsrpCombined
...    NRCELL-1/NRHOIF-2:cellDepType=SA
...    NRCELL-1/NRHOIF-2:deriveSsbIndexFromCell=true
...    NRCELL-1/NRHOIF-2:freqBandIndicatorNR=260
...    NRCELL-1/NRHOIF-2:ifhoSsbScs=120 KHz
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcDuration=sf4
...    NRCELL-1/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-2:ssbFrequency=2254267
...    NRCELL-1/NRHOIF-2:a4MeasNrDcSsbRsrp:a4ThresholdNrDcSsbRsrp=44
...    NRCELL-1/NRHOIF-2:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=35
...    NRCELL-1/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-4/NRHOIF-2:a4MeasNrDcEnabled=rsrpCombined
...    NRCELL-4/NRHOIF-2:cellDepType=SA
...    NRCELL-4/NRHOIF-2:deriveSsbIndexFromCell=true
...    NRCELL-4/NRHOIF-2:freqBandIndicatorNR=260
...    NRCELL-4/NRHOIF-2:ifhoSsbScs=120 KHz
...    NRCELL-4/NRHOIF-2:ifhoSsbSmtcDuration=sf4
...    NRCELL-4/NRHOIF-2:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-4/NRHOIF-2:ssbFrequency=2254267
...    NRCELL-4/NRHOIF-2:a4MeasNrDcSsbRsrp:a4ThresholdNrDcSsbRsrp=44
...    NRCELL-4/NRHOIF-2:a4MeasNrDcSsbRsrq:a4HysteresisNrDcSsbRsrq=0
...    NRCELL-4/NRHOIF-2:a4MeasSsbRsrp:a4ThresholdSsbRsrp=35
...    NRCELL-4/NRHOIF-2:a4MeasSsbRsrq:a4HysteresisSsbRsrq=0
...    NRCELL-4/NRREL-2:nrDcAllowed=true
...    NRCELL-1/NRREL-2:nrDcAllowed=true

@{PMQAP}
...    NRBTS:actIpThpt=true
...    NRBTS:actLatencyPmCount=true
...    NRBTS:actNrpmqapProfiles=true
...    NRBTS:actThpDist=true
...    NRBTS/NRPMRNL-1/NRPMQAP-6:actCplaneCounters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-6:actL2Counters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-6:actPacketSchedulerCounters=false
...    NRBTS/NRPMRNL-1/NRPMQAP-6:cfg5qiRange=6
...    NRBTS/NRPMRNL-1/NRPMQAP-6:cfgProfType=SA
...    NRBTS/NRPMRNL-1/NRPMQAP-6:rlcAmSduDlDelayThresh=2000
...    NRBTS/NRPMRNL-1/NRPMQAP-6:thpHistDownlinkMaxRange=1000000
...    NRBTS/NRPMRNL-1/NRPMQAP-6:thpHistDownlinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-6:thpHistScale=linear
...    NRBTS/NRPMRNL-1/NRPMQAP-6:thpHistUplinkMaxRange=100000
...    NRBTS/NRPMRNL-1/NRPMQAP-6:thpHistUplinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-7:actCplaneCounters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-7:actL2Counters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-7:actPacketSchedulerCounters=false
...    NRBTS/NRPMRNL-1/NRPMQAP-7:cfg5qiRange=7
...    NRBTS/NRPMRNL-1/NRPMQAP-7:cfgProfType=SA
...    NRBTS/NRPMRNL-1/NRPMQAP-7:rlcAmSduDlDelayThresh=2000
...    NRBTS/NRPMRNL-1/NRPMQAP-7:thpHistDownlinkMaxRange=1000000
...    NRBTS/NRPMRNL-1/NRPMQAP-7:thpHistDownlinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-7:thpHistScale=linear
...    NRBTS/NRPMRNL-1/NRPMQAP-7:thpHistUplinkMaxRange=100000
...    NRBTS/NRPMRNL-1/NRPMQAP-7:thpHistUplinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-8:actCplaneCounters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-8:actL2Counters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-8:actPacketSchedulerCounters=false
...    NRBTS/NRPMRNL-1/NRPMQAP-8:cfg5qiRange=8
...    NRBTS/NRPMRNL-1/NRPMQAP-8:cfgProfType=SA
...    NRBTS/NRPMRNL-1/NRPMQAP-8:rlcAmSduDlDelayThresh=2000
...    NRBTS/NRPMRNL-1/NRPMQAP-8:thpHistDownlinkMaxRange=1000000
...    NRBTS/NRPMRNL-1/NRPMQAP-8:thpHistDownlinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-8:thpHistScale=linear
...    NRBTS/NRPMRNL-1/NRPMQAP-8:thpHistUplinkMaxRange=100000
...    NRBTS/NRPMRNL-1/NRPMQAP-8:thpHistUplinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-9:actCplaneCounters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-9:actL2Counters=false
#...    NRBTS/NRPMRNL-1/NRPMQAP-9:actPacketSchedulerCounters=false
...    NRBTS/NRPMRNL-1/NRPMQAP-9:cfg5qiRange=9
...    NRBTS/NRPMRNL-1/NRPMQAP-9:cfgProfType=SA
...    NRBTS/NRPMRNL-1/NRPMQAP-9:rlcAmSduDlDelayThresh=2000
...    NRBTS/NRPMRNL-1/NRPMQAP-9:thpHistDownlinkMaxRange=1000000
...    NRBTS/NRPMRNL-1/NRPMQAP-9:thpHistDownlinkMinRange=100
...    NRBTS/NRPMRNL-1/NRPMQAP-9:thpHistScale=linear
...    NRBTS/NRPMRNL-1/NRPMQAP-9:thpHistUplinkMaxRange=100000
...    NRBTS/NRPMRNL-1/NRPMQAP-9:thpHistUplinkMinRange=100

@{Online_Param}
...    NRBTS:actArpBasedQosScaling=false
...    delete:NRBTS:multiArpBasedParam

@{7103_A004_online_PARAMS}
...    NRCELL-1:actUlDftSOfdm=true
...    NRCELL-1:actRel16DmrsForPusch=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=150
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=130
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrecodePi2Bpsk=true
...    NRCELL-1:ulTransPrecodeCtl:ulTransPrePi2BpskPwrBoost=true
...    NRBTS/NRDRB-11:nrDcDrbParam:ulDataPathNrDc=ulOverMCG
...    NRBTS/NRDRB-11:nrDcDrbParam:ulDataSplitThresholdNrDc=infinity

@{Restore_A004}
...    NRCELL-1:actUlDftSOfdm=false
...    NRCELL-1:actRel16DmrsForPusch=false
...    NRBTS/NRDRB-11:nrDcDrbParam:ulDataPathNrDc=ulDataSplit_PrimaryPathMCG
...    NRBTS/NRDRB-11:nrDcDrbParam:ulDataSplitThresholdNrDc=b100

@{UE_attach_successful_A004}
...    pusch-Config setup
...    transformPrecodingEnabled
...    dmrs-UplinkTransformPrecoding-r16 setup
...    tp-pi2BPSK enabled
...    QoS Routing Table

@{adjust_sinr_A004}
...    pusch-Config setup
...    transformPrecoder enabled
...    tp-pi2BPSK enabled
...    rrcReconfigurationComplete
@{Online_Param_Recovery}
...    NRBTS:actArpBasedQosScaling=true
...    NRBTS:multiArpBasedParam:nbrUlDlSF=50|arpPrioLev=2
...    NRBTS:multiArpBasedParam:nbrUlDlSF=5|arpPrioLev=14
...    NRBTS:multiArpBasedParam:schedulingWeightSF=5|arpPrioLev=14


@{PM_Counters_Check_7103A004}
...    NRCELL-1:NRUC:${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}>0
...    NRCELL-1:NRUC:${DEN_1_SEC_UE_SAMPLE}>0
...    NRCELL-1:NULH:${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}>0
...    NRCELL-1:NULH:${PUSCH_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-1:NULH:${PUSCH_SUC_INI_TX_DFT_R16_DMRS}>0
...    NRCELL-1:NULH:${PUSCH_UNSUC_TX_DFT_R16_DMRS}=0

${n78_7103A004}    SEPARATOR=
...    E7A05000574F7E03560803C420005820020301220C00130709803120D00028100980C0311406014CE02D51B137582308682041D20D80516C
...    AA2A121CFA067D813E31CF9863CA16070387800C0003013800EF800E003BE000B500014006CA0000A00000283E236B04610D04083C41A009
...    2D954541439F40CF8C73E618F28581C0E1E04FE0000003F8000001507C41D608C21A0810788340125B2A8A82873E819F18E7CC31E50B0381
...    C3C09FD8000007F6000000584000C1540B40F78E3087000A8F3F1434011FB660AA40078F0021C4106115028FDFC81B8DC6168000301D02D0
...    1C0DE38C21C002A3CFC50D0047ED982A9001E3C0087104184540A3F7F206E3F1C5A0000C0540B40378E3087000A8F3F1434011FB660AA400
...    78F0021C4106115028FDFC81B8DC61680003000230F134003A00000000100301360800BA00078061449DB1CF860380A000F417801F001400
...    18080A00E0601280380030101088008216021000800193C0100400000492800004B0079415BA40041000009652504000065949401D28AAAE
...    D40002020040080802004050B900803280

${ACC_UE_CONF_DFT_R16_DMRS_PUSCH}    M55165C00036
#This counter provides the number of UEs configured with DFT-s-OFDM and Rel16 DMRS for a physical uplink shared channel (PUSCH).
${DEN_1_SEC_UE_SAMPLE}    M55165C00038
#This counter provides the denominator for the calculation of the average number of UEs.
${PUSCH_SUC_ANY_TX_DFT_R16_DMRS}    M55370C00032
#This counter provides the sum of physical uplink shared channel (PUSCH) CRC-OK detections made for any transmission attempt on a PUSCH with
#DFT-s-OFDM and Rel16 DMRS over the measurement period.
${PUSCH_INI_TX_DFT_R16_DMRS}    M55370C00034
#This counter provides the sum of initial transmissions on a physical uplink shared channel (PUSCH) with DFT-s-OFDM and Rel16 DMRS over the
#measurement period.
${PUSCH_SUC_INI_TX_DFT_R16_DMRS}    M55370C00035
#This counter provides the sum of physical uplink shared channel (PUSCH) CRC-OK detections made for the initial transmission attempt over a PUSCH
#with DFT-s-OFDM and Rel16 DMRS over the measurement period.
${PUSCH_UNSUC_TX_DFT_R16_DMRS}    M55370C00036
#This counter provides the sum of unsuccessful last retransmissions on a physical uplink shared channel (PUSCH) with DFT-s-OFDM and Rel16 DMRS over
#the measurement period.
*** Test Cases ***
CB007103-ET-A004_Rel16_DMRS_Activation_For_PUSCH_NRDC_SCG_Leg_Setup_MCG_Leg_Modification_Reconfigure
    [Documentation]
    ...    1. This user scenario describes DMRS configuration for PUSCH and PUCCH F3 in the case when:QPSK is configured in NIDD (NIDD
    ...    NRCELL.pucchF3ModulationScheme = qpsk_4psk) for PUCCH F3 pi/2-BPSK and Rel16 DMRS is always switched on for PUCCH F3 by NIDD
    ...    parameter NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is TRUE UE is using Rel15 DMRS for PUSCH and PUCCH F3
    ...    2. Configuration
    ...    Transform Precoding NRCELL.actUlDftSOfdm is set to TRUE
    ...    Rel16 DMRS for PUSCH (NRCELL.actRel16DmrsForPusch) is set to TRUE
    ...    Rel16 DMRS for PUCCH F3 (NRCELL.actRel16DmrsForPucchF3) is set to TRUE
    ...    NIDD parameter: NRCELL.pucchF3Rel16Pi2BpskAlwaysOn is TRUE
    ...    QPSK is configured in NIDD (NIDD NRCELL.pucchF3ModulationScheme = qpsk_4psk) for PUCCH F3
    ...    cell operating without Beamforming
    ...    2. Test Case Steps:
    ...    1). UE1 register to large BWP, UE2 register to small BWP.
    ...    2). DL UL low Data transfer
    ...    3). trigger tranform precoding switching on for UE1
    ...    4). tirgger gNB signals to UE MCS 0 or 1 and PUSCH is not scheduled by fallback DCI (DCI 0_0)
    ...    5). trigger tranform precoding switching off for UE1
    ...    6). check counter.
    ...    4. Expected Results:
    ...    1). UEs registers successfully, PDU session is setup successfully.PUCCH F3 is configured with: Pi/2-BPSK
    ...    Pi/2-BPSK Power Boosting configured for PUSCH and PUCCH (RRC IE: UplinkConfig -> powerBoostPi2BPSK is TRUE)
    ...    Rel16 DMRS, dmrs-UplinkTransformPrecodingPUCCH-r16 sent to UE and L2-PS in PUCCH-Config structure
    ...    UE is reporting the control information through PUCCH F3.
    ...    PUSCH is configured with:Transform Precoding not enabled for PUSCH, i.e. RRC IE PUSCH-Config -> transformPrecoder is not enabled
    ...    UplinkConfig-> powerBoostPi2BPSK enabled, dmrs-UplinkTransformPrecoding-r16 configuration sent to UE and L2-PS in PUSCH-Config structure
    ...    in PUSCH-config tp-pi2BPSK shall be set to enabled.
    ...    2). Data transfer works noramlly
    ...    3).tranform precoding switched on,Transform Precoding enabled for PUSCH, i.e. RRC IE PUSCH-Config -> transformPrecoder is enabled
    ...    PUCCH remain unchanged.
    ...    4). Rel16 DMRS is taken into use for PUSCH for UE.PUSCH decoding is succesful in terms of CRC, No ping-pong is observed in switching
    ...    between Rel15 and Rel16 DMRS, Pmax in PUSCH MAC [pcmax, PHR] reflects PowerBoost.
    ...    5). tranform precoding switched off. Transform Precoding not enabled for PUSCH, i.e. RRC IE PUSCH-Config -> transformPrecoder is not
    ...    enabled.
    ...    6). check counter are ok.
    [Tags]    A004    QC_363519
    OnlineParamChange    Online_Param=${7103_A004_online_PARAMS}
    Set UE Capability    ue_id=1    UE_Capabilities=${n78_7103A004}
    Deactive Pathloss
    Sa Ue Attach for 7103    cell_id=1    ue_id=1    qos_flow=6    priority=2    result_check=${UE_attach_successful_A004}
    Send Traffic    ue_id=1    mbps_dl=100    mbps_ul=100
    Check Traffic for SA    ue_id=1    dl_tput=85    ul_tput=85
    NRDC addition for 7103    carrierfreq=2071387    ue_id=1    phycell_id=52
    Check Traffic for SA    ue_id=1    dl_tput=85    ul_tput=85
    Adjust Sinr Target Pathloss    1    130    pass_regexp=${adjust_sinr_A004}
    Check Traffic for SA    ue_id=1    dl_tput=85    ul_tput=0
    Deactive Pathloss    ue_id=1
    Check Traffic for SA    ue_id=1    dl_tput=85    ul_tput=85
    Release Ues    ue_type=all
    Check Counters    ${PM_Counters_Check_7103A004}
    [Teardown]    Test teardown for A004

CB006457-ET_C004_ARP based scaling interworking with intra-gnb NR-DC_actNbrForNonGbrBearers different setting
    [Documentation]
    ...    1. This user scenario describes the ARP based scaling in NR-NR Dual Connectivity (NR-DC).
    ...       The scaling factor will be applied independently on PCell and SCell.
    ...       For inter-gNB NR-DC, configuration consistency on scaling factors for ARP has to be maintained.
    ...    2. Configuration
    ...         a. cell1 and cell4 is n78 for Pcell of NRDC.
    ...         b. cell2 is n257 and cell3 is n260 both as NRDC pscell for cell1 and cell4.
    ...         c. cell1: NRBTS.NRCELL.actNbrForNonGbrBearers = false,actArpBasedQosScaling = true
    ...         d. cell2: NRBTS.NRCELL.actNbrForNonGbrBearers = false,actArpBasedQosScaling = true
    ...         e: cell3: NRBTS.NRCELL.actNbrForNonGbrBearers = false,actArpBasedQosScaling = true
    ...         f: cell4: NRBTS.NRCELL.actNbrForNonGbrBearers = true,actArpBasedQosScaling = true
    ...    3. Test Case Steps:
    ...         a. UE1 registers successfully and DRB is setup successfully with ArpPrioLev=2, Start traffic and check traffic.
    ...         b. UE2 registers successfully and DRB is setup successfully with ArpPrioLev=14, Start traffic and check traffic.
    ...         c. Trigger A4 MR for NRDC, cell3 pscell addition to UE1. check traffic.
    ...         d. UE3 registers successfully and DRB is setup successfully with ArpPrioLev=14, Start traffic and check traffic.
    ...         e. UE4 registers successfully and DRB is setup successfully with ArpPrioLev=2, Start traffic and check traffic.
    ...         f. Trigger A4 MR for NRDC, cell4 pscell addition to UE4. check traffic.
    ...         g. online modify actArpBasedQosScaling to false.
    ...         h. UE1 registers successfully and DRB is setup successfully with ArpPrioLev=2, Start traffic and check traffic.
    ...         i. UE2 registers successfully and DRB is setup successfully with ArpPrioLev=14, Start traffic and check traffic.
    ...         j. Trigger A4 MR for NRDC, cell3 pscell addition to UE1. check traffic.
    ...     4. Expect result:
    ...         a. UE1 registers successfully, no traffic issue.
    ...         b. UE2 registers successfully, no traffic issue.
    ...         c. cell3 pscell addition to UE1, no traffic issue.
    ...         d. UE3 registers successfully, no traffic issue.
    ...         e. UE4 registers successfully, no traffic issue.
    ...         f. cell4 pscell addition to UE3, no traffic issue.
    ...         g. online change successfully.
    ...         h. UE1 registers successfully, no traffic issue.
    ...         i. UE2 registers successfully, no traffic issue.
    ...         j. cell3 pscell addition to UE1, no traffic issue.
    [Tags]    C004    QC_46955
    Clear Counter Files    wait=${False}
    OnlineParamChange    ${Online_Param_Recovery}
    Sa Ue Attach    cell_id=1    ue_id=1    qos_flow=6    priority=2
    Sa Ue Attach    cell_id=1    ue_id=2    qos_flow=5    priority=14
    NRDC addition    carrierfreq=2071387    ue_id=1    phycell_id=52
    Verify Throughput wo NRDC    ue_id=1    Tput_dl=200    Tput_ul=60
	Verify Throughput wo NRDC    ue_id=2    Tput_dl=40    Tput_ul=55
	Verify Throughput with NRDC    ue_id=1    Tput_dl=200    Tput_ul=60
    Release Ues    ue_type=all
    Sa Ue Attach    cell_id=4    ue_id=3    qos_flow=5    priority=14
    Sa Ue Attach    cell_id=4    ue_id=4    qos_flow=6    priority=2
    NRDC addition    carrierfreq=2254267    ue_id=3    phycell_id=53
    Verify Throughput wo NRDC    ue_id=3    Tput_dl=40    Tput_ul=60
	Verify Throughput wo NRDC    ue_id=4    Tput_dl=200    Tput_ul=60
	Verify Throughput with NRDC    ue_id=3    Tput_dl=40    Tput_ul=60
    Release Ues    ue_type=all
    OnlineParamChange    ${Online_Param}   #NRBTS:actArpBasedQosScaling=false， cell-4:actNbrForNonGbrBearers = true
    Sa Ue Attach    cell_id=4    ue_id=1    qos_flow=6    priority=2
    Sa Ue Attach    cell_id=4    ue_id=2    qos_flow=5    priority=14
    NRDC addition    carrierfreq=2071387    ue_id=1    phycell_id=52
	Verify Throughput wo NRDC    ue_id=1    Tput_dl=90    Tput_ul=60
    Verify Throughput wo NRDC    ue_id=2    Tput_dl=180    Tput_ul=60
    Verify Throughput with NRDC    ue_id=1    Tput_dl=90    Tput_ul=60
    Release Ues    ue_type=all
    Check Wireshark Log    ${CURDIR}${/}a2a_C004${/}a2a.ini    wait_string=UEContextRelease::90

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}

Modify Cfg
    Update Cfg    set_qosflow id=1 5qi=5 default=off
    Update Cfg    set_qosflow id=6 5qi=6 default=on
    Update Cfg    set_qosflow id=7 5qi=7
    Update Cfg    qosrule_set id=6 proto=udp qos_flow=6
    Update Cfg    qosrule_set id=7 proto=udp qos_flow=7
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7
    ${gNB2_cell1_configuration}    catenate
    ...    set_cell id=1 gnb=2 pci=16:2 tac=788 nrci=0x01 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=634090:634090 gscn=7854 mandatory_for_activation=off
    update Cfg    ${gNB2_cell1_configuration}
    ${gNB2_cell4_configuration}    catenate
    ...    set_cell id=4 gnb=2 pci=17:0 tac=788 nrci=0x04 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888
    ...    nr_arfcn=634778:634778 gscn=7861 mandatory_for_activation=off
    update Cfg    ${gNB2_cell4_configuration}

Set UE Capability
    [Arguments]    ${ue_id}=1    ${UE_Capabilities}=${SA_Capa_perUE_Full}    ${wait_timer}=0.5
    Execute Egate Command    ue_param id=${ue_id} ue_nr_capabilities=${UE_Capabilities}    sleep_time=${wait_timer}

Send Traffic
    [Arguments]    ${ue_id}=1    ${mbps_dl}=170    ${mbps_ul}=170
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=dl trf_id=1 mbps=${mbps_dl}    UE ${ue_id}: UDP DL
    Execute Egate Command    data_trf_start ue=${ue_id} pdu=1 qfi=1 dir=ul trf_id=8 mbps=${mbps_ul}    UE ${ue_id}: UDP UL

Check Traffic for SA
    [Arguments]    ${ue_id}=31    ${dl_tput}=10    ${ul_tput}=10    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${dl_throughput}/1000 > ${dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000> ${ul_tput}

Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=130    ${pass_regexp}=rrcReconfigurationComplete
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}    #pass_regexp=CTRL_AP_TEST_UL_SINR_NR
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1    pass_regexp=${pass_regexp}
    ...    timeout=180

Deactive Pathloss
    [Arguments]    ${ue_id}=31    ${profile_id}=1
    Execute Egate Command    ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=deactivate profile_id=${profile_id}

Test teardown for A004
    OnlineParamChange    ${Restore_A004}
    Common Test Teardown And Stop Capture Logs

Sa Ue Attach for 7103
    [Arguments]    ${cell_id}=1    ${ue_id}=1    ${qos_flow}=6    ${priority}=2    ${result_check}=QoS Routing Table
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on priority=${priority}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=87
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    pass_regexp=${result_check}

Sa Ue Attach
    [Arguments]    ${cell_id}=1    ${ue_id}=1    ${ul}=175    ${dl}=150    ${qos_flow}=6    ${priority}=2
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    qosflow_modify qos_flow=${qos_flow} default=on priority=${priority}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Register
    Execute Egate Command    amf_ue_ics_param id=1 ue=${ue_id} indexToRFSP=87
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 gw=1 nwslice=1    QoS Routing Table
    Send Throughput    ue_id=${ue_id}    times=3    ul=${ul}    dl=${dl}

Send Throughput
    [Arguments]    ${ue_id}=81    ${times}=3    ${ul}=150    ${dl}=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=${ul} trf_id=10    UE ${ue_id}: UDP UL
    FOR    ${I}    IN RANGE    1    ${times}
        Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=${dl} trf_id=${I}    UE ${ue_id}: UDP DL
    END

Verify Throughput wo NRDC
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=40    ${Tput_ul}=15
    sleep    10s    #wait throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${MCG_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} cell_group=MCG scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${MCG_tputdl}    CellIndex-[0] *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Verify Throughput with NRDC
    [Arguments]    ${ue_id}=81    ${pdu}=1    ${qfi}=1    ${Tput_dl}=290    ${Tput_ul}=80
    sleep    10s    #wait throughput
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=${pdu}    qfi=${qfi}    direction=ul    rate_type=ave
    ${MCG_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} cell_group=MCG scell=0-7 type=pdsch    Throughput
    ${SCG_tputdl}    Execute Egate Command    ue_stats_nr id=${ue_id} cell_group=SCG scell=1-7 type=pdsch    Throughput
    ${scell_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pusch    Throughput
    ${MCG_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} cell_group=MCG scell=0-7 type=pusch    Throughput
    ${SCG_tputul}    Execute Egate Command    ue_stats_nr id=${ue_id} cell_group=SCG scell=1-7 type=pusch    Throughput
    Should Not Match Regexp    ${MCG_tputdl}    CellIndex-[0] *0
    Should Not Match Regexp    ${SCG_tputdl}    CellIndex-[0] *0
    Should Not Match Regexp    ${MCG_tputul}    CellIndex-[0] *0
    Should Not Match Regexp    ${SCG_tputul}    CellIndex-[0] *0
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

NRDC addition
    [Arguments]    ${carrierfreq}=2071387    ${ue_id}=81    ${phycell_id}=52    ${pass_regrxp}=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    62s    1s    get a4 measid successful    ${ue_id}    ${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4
    ...    srsrp_nr=19 srsrq_nr=10 phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=70 index=0 nrs_result=30:30:0
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regrxp}

NRDC addition for 7103
    [Arguments]    ${carrierfreq}=2071387    ${ue_id}=81    ${phycell_id}=52    ${pass_regrxp}=rrcReconfigurationComplete
    Wait Until Keyword Succeeds    62s    1s    get a4 measid successful    ${ue_id}    ${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A4
    ...    srsrp_nr=19 srsrq_nr=10 phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=70 index=0 nrs_result=30:30:0
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regrxp}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}
    Cells Should Be OnAir    check_sib=${False}    cell_id=2
    Cells Should Be OnAir    check_sib=${False}    cell_id=3
    Cells Should Be OnAir    check_sib=${True}    cell_id=1
    Cells Should Be OnAir    check_sib=${True}    cell_id=4

get a4 measid successful
    [Arguments]    ${ue_id}=81    ${carrierfreq}=2071387
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    event_type=A4    carrierfreq=${carrierfreq}
    Set Test Variable    ${meas_id}
