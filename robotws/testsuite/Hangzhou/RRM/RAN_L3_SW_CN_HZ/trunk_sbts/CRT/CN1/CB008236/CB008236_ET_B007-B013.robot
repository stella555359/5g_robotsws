*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_VRF    SBTS00    RAN_5G    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD    team-CN1ET
...    owner-jun.15.zhang    release-SBTS23R4    CRT
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SWCONFIG_GNB2}
...    @{rdEnableDynamicBetaOffsets}

@{rdEnableDynamicBetaOffsets}
...    0x5900D4=0

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_5GC000545}
...    @{PARAMS_FOR_CB008236}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_ADJ_REL_FOR_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_VoNR}
...    @{PARAMS_FOR_5GC000545}
...    @{PARAMS_FOR_CB008236}
...    @{PARAMS_FOR_A3}
...    @{PARAMS_ADJ_REL_FOR_GNB2}

@{PARAMS_FOR_VoNR}
...    NRBTS:actNormVCFallback=false

...    NRCELL:voNRNrDrxDN=NRDRX-2
...    NRCELL:actVoNR=true
...    NRCELL:actEnhancedVoNR=true
...    NRCELL:actAdaptVoipTbs=true
...    NRCELL:actCDrx=true
...    NRCELL:actCDrxVoNR=true
...    NRCELL:srPeriodicity=slots40
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:actVoipPacketAggr=true
...    @{PARAMS_FOR_5QI5}
...    @{PARAMS_FOR_5QI1}

@{PARAMS_FOR_5QI5}
...    NRBTS/NRDRB_5QI-1:fiveqiValueList=5
...    NRBTS/NRDRB_5QI-1:nrDrbDN=NRDRB-10
...    NRBTS/NRDRB-10:nrDrbMacDN=NRDRB_MAC-4
...    NRBTS/NRDRB-10:nrDrbPdcpDN=NRDRB_PDCP-2
...    NRBTS/NRDRB-10:nrDrbRlcAmDN=NRDRB_RLC_AM-2
...    NRBTS/NRDRB-10:resType=nonGBR_Signaling
...    NRBTS/NRDRB-10:rlcMode=RLC_AM
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
...    NRBTS/NRDRB-15:nrDrbRlcUmDN=NRDRB_RLC_UM-1
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
...    NRBTS/NRDRB-15:rlcMode=RLC_UM
...    NRBTS/NRDRB-15:schedulWeight=1
...    NRBTS/NRDRB-15:sduDiscardIntervalTmr=100
...    NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    NRBTS/NRDRB_MAC-3:lcgid=4
...    NRBTS/NRDRB_MAC-3:schedulPrio=5
...    NRBTS/NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    NRBTS/NRDRB_RLC_UM-1:dlTReassemblyUm=ms40
...    NRBTS/NRDRB_RLC_UM-1:ulTReassemblyUm=ms40

@{PARAMS_FOR_5GC000545}
...    NRBTS:actTdraFallback=false
...    NRCELL:actUlDftSOfdm=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:puschMappingType=TypeB
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOffSinrThresh=200
...    NRCELL:ulTransPrecodeCtl:ulTransPrecodeOnSinrThresh=180

@{PARAMS_FOR_CB008236}
...    NRCELL:actUlSlotAgg=Enabled_VoNr
...    NRCELL:actDrxSleepOff=Enabled_VoNr_SAg
...    NRCELL:sCellDeactInPoorRf=Deact_Scells_VoNr_SAg
...    NRCELL:ulTransPrecodeCtl:ulSlotAggOffTotPwrThresh=33
...    NRCELL:ulTransPrecodeCtl:ulSlotAggOnTotPwrThresh=30
...    NRCELL:maxHarqBundlesUlSlotAgg=10
...    NRCELL:minTbsUlSlotAgg=384
...    NRCELL:maxNumPuschAllocationPerSlot=2

@{PARAMS_FOR_A3}
...    NRBTS:actIncXn=true
...    NRBTS:actIntraFreqHoSA=true
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:absThreshSsbRsrpConsolidation=1
...    NRCELL:absThreshSsbRsrqConsolidation=1
...    NRCELL:sMeasConfigSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=1
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=15
...    NRCELL:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms40

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.3
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-13:fiveGsTac=200
...    NRBTS/NRADJNRCELL-13:gNbId=2
...    NRBTS/NRADJNRCELL-13:gNbIdLength=22
...    NRBTS/NRADJNRCELL-13:lcrId=13
...    NRBTS/NRADJNRCELL-13:nrarfcn=368400
...    NRBTS/NRADJNRCELL-13:physCellId=62
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-13:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-13:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-13:ssbFrequency=368430
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gNbId=2
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gNbIdLength=22
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:handoverAllowedSARedCap=forbidden
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:isRplCellForPSCell=false
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:lcrId=13
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:nrDcAllowed=false
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:removeNotAllowed=false
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    MRBTS/NRBTS/NRCELL-11/NRREL-1:gnbPlmn:mncLength=3

@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/XNLINK-1:cPlaneIpAddr=10.0.1.2
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:gNodeBIdCtrl=oamControlled
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-1:xnLinkRef=1
...    NRBTS/NRADJGNB-1:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-1:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-11:fiveGsTac=200
...    NRBTS/NRADJNRCELL-11:gNbId=1
...    NRBTS/NRADJNRCELL-11:gNbIdLength=22
...    NRBTS/NRADJNRCELL-11:lcrId=11
...    NRBTS/NRADJNRCELL-11:nrarfcn=368400
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gNbId=1
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gNbIdLength=22
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:handoverAllowedSA=allowed
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:handoverAllowedSARedCap=forbidden
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:isRplCellForPSCell=false
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:lcrId=11
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:nrDcAllowed=false
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:removeNotAllowed=false
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    MRBTS/NRBTS/NRCELL-13/NRREL-1:gnbPlmn:mncLength=3

#VONR UE
#Common capa with below capa supported
#phy-Parameters {
##phy-ParametersCommon {
###dynamicBetaOffsetInd-HARQ-ACK-CSI supported,
###pusch-RepetitionTypeA-r16 {
####sharedSpectrumChAccess-r16 supported,
#####non-SharedSpectrumChAccess-r16 supported
${SA_Capa_Support_SAG}    SEPARATOR=
...    E9A09000575F5A13560003C5280016005000002018093170019C3D0B004D9061CF9863CA160704C060188E02771B01B03582308682041D211001B5B262AC6873E238F40CFB02
...    7C62471E439F51CF9863CA1607038782E007FE0038002F8003600001C0A836016B04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB00
...    0000FEC000000D80000702A8D899AC1184341020E908800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC001B00000E0541B06F5823086820
...    41E21100195B262AC4873E238F604F8C48E3C873EA39F30C7942C0E070F09FFF000007FFC000006C0000381546C4DD608C21A00000404400616C932A221CF88E3C831E819F60
...    4F8073E618F28581C0E1E0BD5555554F55555550D800007004961E26000713000000058158B898001C4C000E260000010B02B17008003098061300004160563E01000606C0C2
...    60184C0001858158B8040018020303600040B02B1F00800300C0606C0C26800142C0AC5C02000C0D8184C0003058158780400184C00038581587804001802000405815878360
...    0181B000485815878040018060005058158780C00181B0005858158B80400180603036000C0B02B0F06C0038980000342C0AC5C4C000C26018020007058158F89800184C0300
...    40606C001E160562E2600060080C0D800402C0AC7C4D000C01018060303600110B0201200DC0068099000A0268DA001D212851226C73E1C4891226C73E1C4891226C73E1C689
...    12244D8E7C38912244D8E7C38D1224489B1CF871224489B1CF870A244D8E7C3851226C73E1C28913639F0E14489B1CF870A244D8E7C38912244D8E7C3851226C73E1C4891226
...    C73E1C68912244D8E7C38912244D8E7C38D1224489B1CF8603624318C6318C6318C6318C63183D07C001E00140E0A00E0601280380030120020301F048010000000080040000
...    001000006008000010040000100200000C01000008008000050040020080200800006004000038020010000000400004002000024010000060080000A0040000580200102409
...    00400006019CA9ACA9AC14AC0CAC19AC15ACA5BC99BC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29302000032CA48080001CB29202000092CA48080002CB293020000
...    D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192CA480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A814
...    5526AAA0F143C00BC04A8140A05028140A05028140A05028140A05028140A0022101002004040080110080100202004008080100220100C01404008010100200460201802808
...    0600A02004008080100220101001404040050101602C602018030080600A02018030080100220100C014040300501002004202018028080100210100C014040300508080600C
...    02018030404030060100C014202018028080600A20100C01404030060100C014202018030080100220100200404008010100C014602004008080100202018028080600A20100
...    200404030060100C018602004008080600A02018030080600A3543E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E828305A


@{expect_5QI6}
...    Setup QosFlow with QFI:1 5QI:6
...    drx-onDurationTimer milliSeconds : ms10
...    drx-InactivityTimer ms40
...    betaOffsets semiStatic
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    pusch-TimeDomainAllocationList release : NULL

@{expect_5QI5}
...    Setup QosFlow with QFI:1 5QI:5

@{expect_CellEdge_B07}
...    transformPrecoder enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA

@{expect_5QI1}
...    transformPrecoder enabled
...    betaOffsets dynamic
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    Added QosFlow with QFI:2 5QI:1
...    drx-onDurationTimer milliSeconds : ms40
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}

@{semiStatic_BetaOffsets_values}
...    betaOffsetACK-Index1 11
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6

@{moderate_BetaOffsets_values}
...    betaOffsetACK-Index1 10
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6

@{optimistic_BetaOffsets_values}
...    betaOffsetACK-Index1 13
...    betaOffsetACK-Index2 12
...    betaOffsetACK-Index3 6

@{default_BetaOffsets_values}
...    betaOffsetACK-Index1 11
...    betaOffsetACK-Index2 11
...    betaOffsetACK-Index3 6

@{expect_5QI1_TPOff}
...    Added QosFlow with QFI:2 5QI:1

@{expect_IntergNBHO}
...    transformPrecoder enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    Inter-eNB handover from EXT_ENB-2.11 to EXT_ENB-3.13 performed
...    Setup QosFlow with QFI:1:::2
...    Setup QosFlow with QFI:2
...    drx-onDurationTimer milliSeconds : ms40
...    betaOffsets semiStatic
...    betaOffsetACK-Index1 13
...    betaOffsetACK-Index2 12
...    betaOffsetACK-Index3 6

@{expect_IntergNBHO_TPOFF}
...    transformPrecoder disabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    Inter-eNB handover from EXT_ENB-2.11 to EXT_ENB-3.13 performed
...    Setup QosFlow with QFI:1:::2
...    Setup QosFlow with QFI:2

@{expect_CellEdge_B13}
...    transformPrecoder enabled
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    betaOffsets semiStatic
...    betaOffsetACK-Index1 13
...    betaOffsetACK-Index2 12
...    betaOffsetACK-Index3 6
...    drx-onDurationTimer milliSeconds : ms40

@{HO_BACK}
...    transformPrecoder enabled
...    betaOffsets dynamic
...    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
...    pusch-RepTypeIndicatorDCI-0-1-r16 pusch-RepTypeA
...    Inter-eNB handover from EXT_ENB-3.13 to EXT_ENB-2.11 performed
...    Setup QosFlow with QFI:1:::2
...    Setup QosFlow with QFI:2
...    drx-onDurationTimer milliSeconds : ms40
...    @{semiStatic_BetaOffsets_values}
...    @{moderate_BetaOffsets_values}
...    @{optimistic_BetaOffsets_values}
...    @{default_BetaOffsets_values}

${ACC_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00025
${MAX_PUSCH_REP_TYPE_A_CAP_UE}    M55139C00026
${UE_CAP_DEN}    M55139C00027
@{B007_PM_Counters_Check_GNB}
...    NRCELL-11:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>=15
...    NRCELL-11:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1
...    NRCELL-11:RSADU:${UE_CAP_DEN} =300

@{B007_PM_Counters_Check_GNB2}
...    NRCELL-13:RSADU:${ACC_PUSCH_REP_TYPE_A_CAP_UE}>=10
...    NRCELL-13:RSADU:${MAX_PUSCH_REP_TYPE_A_CAP_UE}=1
...    NRCELL-13:RSADU:${UE_CAP_DEN} =300

*** Test Cases ***
CB008236-ET-B007_Verify Inter gnb Handover of VoNR UE in SAg mode Slot Aggregation continues at Target Cell
    [Documentation]
    ...    1.This scenario describes gNB behavior when a UE with a 5QI1 DRB in poor RF coverage while in Slot Aggregation mode,
    ...        is handed over to a neighbor cell with CB008236 feature enabled,gNB continues to remain in slot aggregation eligible
    ...        state on the target cell
    ...      Upon completion of handover, target cell sets up DRX profile2 at the UE with DRX sleep off state
    ...      Handover may be intra-gNB or inter-gNB
    ...      Requirement Coverage:
    ...      5G_PM_1076, 5G_RAN_USR_RRM_19896, fully covered
    ...    2.[Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz Cellid=0x800b/32779 ssbFrequency=368430
    ...    Cell id=12 gnb=2 pci=20:1 tdd_cell=off band=n28 nr_arfcn=145000:156000 gscn=1950 chBw=15MHz Cellid=0x800c/32780 ssbFrequency=156030
    ...    Cell id=13 gnb=3 pci=20:2 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz Cellid=0x800b/32779 ssbFrequency=368430
    ...    Cell id=14 gnb=3 pci=21:0 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=15MHz Cellid=0x800d/32780 ssbFrequency=126750
    ...    3. Test Case Steps:
    ...         a. Trigger UE1 normal call with 5QI6 and start traffic
    ...         b. Firstly Trigger UE1 VONR call with 5QI5,secondly moves towards cell edge,then trigger VONR call with 5QI1
    ...         c. Trigger UE1 inter-gNB HO from Cell1_11 to Cell2_13
    ...         d. Deregister UE1,then check counters
    ...    4. Expect result:
    ...         a. Traffic is ok
    ...         b. VONR call setup correctly,DRX profile2 is in use and movement is successful so start TP
    ...            (drx-onDurationTimer equals to drxLongCycle),configures UE1 with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...         c. Ho done,betaOffsets would different from which on Cell1_11 due to rdEnableDynamicBetaOffsets disable
    ...         d. Deregister successfully, counters are correct
    ...    5. scenario description:
    ...         UE1 trigger normal call with PDU-1 QFI-1 5QI6,then add PDU-2 QFI-1 5QI5
    ...         start TP by movement operation then add PDU-2 QFI-2 5QI1, VONR call setup
    ...         UE in SAg mode: TP ON, drx-onDurationTimer = drx-profile2.drxLongCycle, and related betaOffsets dynamic
    ...         after HO done, due to rdEnableDynamicBetaOffsets disable,so betaOffsets in Cell2_13 is different to which in Cell1_11
    [Tags]    B007    QC_47100
    Clear Counter Files for 2GNB
    UE Trigger Normal Call With PDU Default 5QI6
    UE Send Throuput On 5QI6
    UE Trigger VoNR Call 5QI5 Setup Successfully
    UE Moves Towards Cell Edge
    UE Trigger VoNR Call 5QI1 Setup Successfully
    UE Tirgger Intra-Freq Inter-GNB HO By Event A3
    UE Deregister From gNB
    Check Counters    ${B007_PM_Counters_Check_GNB}
    Check Counters GNB2    ${B007_PM_Counters_Check_GNB2}

CB008236-ET-B013_Verify VoNR UE in TP Off state in source cell Inter gnb handover to Target Cell with Feature Enabled
    [Documentation]
    ...    1.Purpose:This scenario describes gNB behavior when a UE with a 5QI1 DRB in good RF coverage while in TP OFF State,
    ...      is handed over to a neighbor cell with CB008236 feature enabled
    ...      Requirement Coverage:
    ...      5G_RAN_USR_RRM_19912, fully covered
    ...    2.[Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz Cellid=0x800b/32779 ssbFrequency=368430
    ...    Cell id=12 gnb=2 pci=20:1 tdd_cell=off band=n28 nr_arfcn=145000:156000 gscn=1950 chBw=15MHz Cellid=0x800c/32780 ssbFrequency=156030
    ...    Cell id=13 gnb=3 pci=20:2 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz Cellid=0x800b/32779 ssbFrequency=368430
    ...    Cell id=14 gnb=3 pci=21:0 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=15MHz Cellid=0x800d/32780 ssbFrequency=126750
    ...    3. Test Case Steps:
    ...         a. Trigger UE1 normal call with 5QI6 and start traffic
    ...         b. Firstly Trigger UE1 VONR call with 5QI5,secondly trigger VONR call with 5QI1 but TP off
    ...         c. Trigger UE1 inter-gNB HO from Cell1_11 to Cell2_13
    ...         d. Trigger UE1 moves towards cell edge
    ...         e. Trigger HO back to Cell1_11 to check UE1 is stable
    ...    4. Expect result:
    ...         a. Traffic is ok
    ...         b. VONR call setup correctly,DRX profile2 is in use, configures UE1 with SAg specific dynamic betaoffsets in UCI-onPUSCH IE
    ...         c. Ho done, betaOffsets would not shown
    ...         d. Movement is successful,TP is successful,betaOffsets shown and check it
    ...         e. HO successfully
    ...    5. scenario description:
    ...        UE1 trigger normal call with PDU-1 QFI-1 5QI6,then add PDU-2 QFI-1 5QI5 and add PDU-2 QFI-2 5QI1 to setup VONR call
    ...        UE not in SAg mode: TP OFF, drx-onDurationTimer <> drx-profile2.drxLongCycle, and related betaOffsets not dynamic
    ...        after HO done,trigger movement operation,
    ...        UE goes into SAg mode: TP works,drx-onDurationTimer = drx-profile2.drxLongCycle, and related betaOffsets dynamic,
    ...        at last HO back and it's stable
    [Tags]    B013    QC_303555
    UE Trigger Normal Call With PDU Default 5QI6
    UE Send Throuput On 5QI6
    UE Trigger VoNR Call 5QI5 Setup Successfully
    UE Trigger VoNR Call 5QI1 Setup Successfully With TP Off
    UE Tirgger Intra-Freq Inter-GNB HO By Event A3 With TP Off
    UE Moves Towards Cell Edge    expect_CellEdge=${expect_CellEdge_B13}
    UE HO back to Cell1_11
    UE Deregister From gNB

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fdd_sansa_cmwv/FS/4cells_gnb1_2F_gnb2_2F    ue_count=2

Disable UE Testmode
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=deactivate
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 delete=1

Modify Cfg
    Update Cfg Param    set_gnb id=2 xn=10.0.1.2
    Update Cfg Param    set_gnb id=3 xn=10.0.1.3
    Update Cfg Param    amf_param id=1 ims_voice_3gpp=on
    Update Cfg Param    ue_param id=1 ue_nr_capabilities=${SA_Capa_Support_SAG} nr_usage_setting=voice_centric
    Update Cfg    ue_nr_capabilities id=1 voice_over_nr=on:on:off
    Update Cfg    set_qosflow id=1 5qi=6 default=on
    Update Cfg    set_qosflow id=2 5qi=5
    Update Cfg    set_qosflow id=3 5qi=1
    Update Cfg    set_qosrule id=1 proto=tcp qos_flow=2
    Update Cfg    set_qosrule id=2 proto=udp qos_flow=3
    Update Cfg    set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=1 amf=1 qos_flows=1,2,3 qos_rules=1,2

UE Trigger Normal Call With PDU Default 5QI6
    Disable UE Testmode
    Execute Egate Command    ue_change_location id=1 enb=2 cell=11
    Execute Egate Command    ue_register id=1    pass_regexp=UE now in NG RM Registered
    Execute Egate Command    qosflow_modify qos_flow=1 default=on ue=1
    Execute Egate Command    set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=1 gw=1 nwslice=1    pass_regexp=${expect_5QI6}

UE Trigger VoNR Call 5QI5 Setup Successfully
    Execute Egate Command    qosflow_modify qos_flow=2 default=on ue=1
    Execute Egate Command    ue_pdu_session_setup ue=1 pdu=2 gw=2 nwslice=1    pass_regexp=${expect_5QI5}

UE Trigger VoNR Call 5QI1 Setup Successfully
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=3 by=amf    pass_regexp=${expect_5QI1}

UE Trigger VoNR Call 5QI1 Setup Successfully With TP Off
    Execute Egate Command    ue_pdu_session_modify ue=1 pdu=2 qosflows_to_add=3 by=amf    pass_regexp=${expect_5QI1_TPOff}

UE Send Throuput On 5QI6
    Execute Egate Command    trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10 trf_id=1    pass_regexp=UE 1: UDP UL
    sleep    10s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=1 scell=0-7 type=pusch

UE Moves Towards Cell Edge
    [Arguments]    ${expect_CellEdge}=${expect_CellEdge_B07}
    Execute Egate Command    ul_sinr_testmode_nr profile_id=1 pathloss=118
    Execute Egate Command    ue_testmode_set_nr id=1 testmode=ul_sinr profile_id=1 action=activate    pass_regexp=${expect_CellEdge}

UE Tirgger Intra-Freq Inter-GNB HO By Event A3
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=368430    event_type=A3
    ${intra_freq_inter_gnb_A3}    catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_inter_gnb_A3}    pass_regexp=${expect_IntergNBHO}
    sleep    10s    #check HO done,UE is stable and conuter ACC_PUSCH_REP_TYPE_A_CAP_UE for gNB2 is correct

UE Tirgger Intra-Freq Inter-GNB HO By Event A3 With TP Off
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=368430    event_type=A3
    ${intra_freq_inter_gnb_A3}    catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=62 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_inter_gnb_A3}    pass_regexp=${expect_IntergNBHO_TPOFF}

UE Deregister From gNB
    Execute Egate Command    trf_data_stop ue=1 pdu=1    pass_regexp=Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=2    pass_regexp=Successfully released PDU Session
    Execute Egate Command    ue_pdu_session_release ue=1 pdu=1    pass_regexp=Successfully released PDU Session
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    pass_regexp=UE1: detached    timeout=10s

Clear Counter Files for 2GNB
    Clear Counter Files
    Clear Counter Files GNB2

Check UE1 traffic is stable
    [Arguments]    ${ue_id}=1    ${Tput_ul}=9    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

UE HO back to Cell1_11
    ${meas_id}=    Get Nr Meas Id For Specific Type And Frequency    ue_id=1    carrierfreq=368430    event_type=A3
    ${intra_freq_inter_gnb_A3}    catenate
    ...    ue_measurement_send_nr id=1 meas_id=${meas_id} event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=60 nrsrp_nr=80 nrsrq_nr=80
    execute egate command    ${intra_freq_inter_gnb_A3}    pass_regexp=${HO_BACK}
    Disable UE Testmode
    Check UE1 traffic is stable

