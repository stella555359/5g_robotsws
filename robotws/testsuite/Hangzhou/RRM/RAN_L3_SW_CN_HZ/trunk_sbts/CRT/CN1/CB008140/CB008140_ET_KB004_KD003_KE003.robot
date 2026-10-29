*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    	CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    team-L3CN1_SG14    owner-jiangping.cao    release-SBTS23R3
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
@{PARAMS_IN_SWCONFIG}
...    @{rdEnableTrafficManager}
...    @{rdEnableUeIdRangeAllocationViaSdl}
...    @{rdEnableUeMappingRemovalFromCpIf}

@{PARAMS_IN_SWCONFIG_GNB2}
...    @{rdEnableTrafficManager}
...    @{rdEnableUeIdRangeAllocationViaSdl}
...    @{rdEnableUeMappingRemovalFromCpIf}

@{rdEnableTrafficManager}
...    0x89001C=1
@{rdEnableUeIdRangeAllocationViaSdl}
...    0x89001D=1
@{rdEnableUeMappingRemovalFromCpIf}
...    0x89001E=1

#when two USCP pool failure, the fault will raised, not test point here,so excluded it
@{FAULTS_EXCLUDED_CHECKING}    6450

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB1}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_FOR_GNB2}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:sCellActivationMethod=blind
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=20
...    NRBTS:actIncXn=true
...    NRBTS:maxNumScellsDl=2
...    NRBTS:maxNumScellsUl=2
...    NRBTS:cuUeIdToLinkMappingUpdateDelay=1ms
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Sa,ca_Fdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fdd
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB

@{PARAMS_FOR_GNB1}
...    NRCELL-11:sCellDeactivationTimerGNB=infinity
...    NRCELL-12:sCellDeactivationTimerGNB=infinity
...    NRCELL:nrCellType=2DL2UL
...    NRCELL-11:maxNumScellsDlFr1=3
...    NRCELL-11:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRCELL-12:dlMimoMode=2x2 Open Loop Spatial Multiplexing
...    NRPMRNL-1:miNrInterGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbNgMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrInterGnbXnMobilitySaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilityNsaPmqap=disabled
...    NRPMRNL-1:miNrIntraGnbMobilitySaPmqap=disabled
...    NRBTS:actNgcFlexSaMode=true
...    NRPMRNL-1:miNrRelReportCu=disabled
...    NRCELL:ulPowerControlCommon:p0NominalPucchF1F3=-94

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS:actGrflShdn=false
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=50
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=663400
...    NRBTS/NRADJNRCELL-1:physCellId=50
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:freqBandIndicatorNR=77
...    NRBTS/NRADJNRCELL-2:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-2:fiveGsTac=200
...    NRBTS/NRADJNRCELL-2:gNbId=2
...    NRBTS/NRADJNRCELL-2:gNbIdLength=22
...    NRBTS/NRADJNRCELL-2:lcrId=2
...    NRBTS/NRADJNRCELL-2:nrarfcn=658000
...    NRBTS/NRADJNRCELL-2:physCellId=51
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-2:freqBandIndicatorNR=77
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
...    NRBTS/NRADJNRCELL-14:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-14:fiveGsTac=200
...    NRBTS/NRADJNRCELL-14:gNbId=2
...    NRBTS/NRADJNRCELL-14:gNbIdLength=22
...    NRBTS/NRADJNRCELL-14:lcrId=14
...    NRBTS/NRADJNRCELL-14:nrarfcn=153400
...    NRBTS/NRADJNRCELL-14:physCellId=63
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-14:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-14:freqBandIndicatorNR=28
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=2
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=2
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-2:lcrId=2
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-13:gNbId=2
...    NRCELL-11/NRREL-13:gNbIdLength=22
...    NRCELL-11/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-13:lcrId=13
...    NRCELL-11/NRREL-13:removeNotAllowed=false
...    NRCELL-11/NRREL-13:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-14:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-14:gNbId=2
...    NRCELL-11/NRREL-14:gNbIdLength=22
...    NRCELL-11/NRREL-14:handoverAllowedSA=allowed
...    NRCELL-11/NRREL-14:lcrId=14
...    NRCELL-11/NRREL-14:removeNotAllowed=false
...    NRCELL-11/NRREL-14:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-14:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-14:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-14:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-14:sCellOperationalMode=dlOnly

@{PARAMS_FOR_GNB2}
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=90
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60
...    NRCELL-1:sCellDeactivationTimerGNB=infinity
...    NRCELL-2:sCellDeactivationTimerGNB=infinity
...    NRCELL-13:sCellDeactivationTimerGNB=infinity
...    NRCELL-14:sCellDeactivationTimerGNB=infinity
...    NRCELL-1:weightForSCellSelection=50
...    NRCELL-2:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-14:weightForSCellSelection=50
...    NRCELL-1:nrCellType=4DL4UL
...    NRCELL-2:nrCellType=4DL4UL
...    NRCELL-1:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRBTS:maxNumScellsDl=2
...    NRCELL-1:maxNumOfSCellAlloc=2
...    NRCELL-2:maxNumOfSCellAlloc=1
...    NRCELL-14:maxNumOfSCellAlloc=1
...    NRCELL:ulPowerControlCommon:p0NominalPucchF1F3=-94

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-3/PHYANT-1

...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:direction=TX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:direction=RX
...    MRBTS-1/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8:resourceDN=MRBTS-1/EQM-1/APEQM-1/RMOD-4/PHYANT-1


@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
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
...    NRBTS/NRADJNRCELL-11:nrarfcn=364000
...    NRBTS/NRADJNRCELL-11:physCellId=60
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-11:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-12:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-12:fiveGsTac=200
...    NRBTS/NRADJNRCELL-12:gNbId=1
...    NRBTS/NRADJNRCELL-12:gNbIdLength=22
...    NRBTS/NRADJNRCELL-12:lcrId=12
...    NRBTS/NRADJNRCELL-12:nrarfcn=374000
...    NRBTS/NRADJNRCELL-12:physCellId=61
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mcc=311
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mnc=489
...    NRBTS/NRADJNRCELL-12:gnbPlmn:mncLength=3
@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false

@{online_modify_scell_administrativeState_to_Locked}
...    NRCELL-1:administrativeState=Locked

@{online_modify_scell_administrativeState_to_Unlocked}
...    NRCELL-1:administrativeState=Unlocked

*** Test Cases ***
CB008140-ET-KB004_SCell lock for inter-gNB CA UEs with blind addition and blind activation
    [Documentation]
    ...    This case is to test CB008140-K#B4: Ext-SCell lock without Graceful Cell Shutdown
    ...    This case partly covered CB008140-K#B4: Ext-SCell lock without Graceful Cell Shutdown
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=70
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=70
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=5
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=5
    ...    UE capability support n3+n28+n77+n77
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On Cell1_11
    ...         b. UE1 Start Traffic And Verify Throughput
    ...         c. UE2 Register And PDU Session Setup On Cell1_11
    ...         d. UE2 Start Traffic And Verify Throughput
    ...         e. Scell(cell2_1) lock and unlock
    ...         f. A2A check the message procedure for scell lock and unlock
    ...         g. UE3 Register And PDU Session Setup On Cell1_11
    ...         h. UE3 Start Traffic And Verify Throughput
    ...         i. UE4 Register And PDU Session Setup On Cell1_11
    ...         j. UE4 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful, Blind Add Cell2_1 Cell2_2 and Cell2_13 as Scell
    ...         Step b: UE1 Traffic And Throughput is OK
    ...         Step c: UE2 Register And PDU Session Setup Successful, Blind Add Cell2_1 as Scell
    ...         Step d: UE2 Traffic And Throughput is OK
    ...         Step e: scell lock and unlock successfully without error
    ...         Step f: Partial release triggered, and the message procedures are expected
    ...         Step g: UE3 Register And PDU Session Setup Successful, Blind Add Cell2_1 Cell2_2 and Cell2_13 as Scell
    ...         Step h: UE3 Traffic And Throughput is OK
    ...         Step i: UE4 Register And PDU Session Setup Successful, Blind Add Cell2_1 as Scell
    ...         Step j: UE4 Traffic And Throughput is OK
    [Tags]    QC_281497    KB004
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=1    nwslice=1    gateway=1    scell1pci=50    scell2pci=51
    ...    scell3pci=63
    Run Traffic And Verify Throughput    ue_id=1
    UE Register And PDU Session Setup With Blind 1 Scell Addition    ue_id=2    nwslice=2    gateway=1    scell1pci=50
    Run Traffic And Verify Throughput    ue_id=2
    Delta Commission To locked
    sleep    3s    #wait cell2_1 goes into locked status
    Delta Commission To unlocked
    Check WireShark Log    ${CURDIR}${/}A2A_KB_004${/}a2a.ini    wait_string=IgNBCAConfigurationUpdateIndication::2
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_KB_004${/}a2a_gnb2.ini    wait_string=IgNBCAConfigurationUpdateIndication::2
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=3    nwslice=1    gateway=1    scell1pci=50    scell2pci=51
    ...    scell3pci=63
    Run Traffic And Verify Throughput    ue_id=3
    UE Register And PDU Session Setup With Blind 1 Scell Addition    ue_id=4    nwslice=2    gateway=1    scell1pci=50
    Run Traffic And Verify Throughput    ue_id=4

CB008140-ET-KD003_Partial reset by CPUE failure on primary gnb
    [Documentation]
    ...    This case is to test partial UE release will trigger when CPUE pool failure on primary gnb
    ...    This case partly covered CB008140-K#B8: Reset of BBU (ABIL/ABIO/ABIN etc.) hosting PCell
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=70
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=70
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=5
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=5
    ...    UE capability support n3+n28+n77+n77
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On Cell1_11
    ...         b. UE1 Start Traffic And Verify Throughput
    ...         c. UE2 Register And PDU Session Setup On Cell1_11
    ...         d. UE2 Start Traffic And Verify Throughput
    ...         e. CPUE pool failure on primary gnb
    ...         f. A2A check the message procedure for CPUE pool failure
    ...         g. UE3 Register And PDU Session Setup On Cell1_11
    ...         h. UE3 Start Traffic And Verify Throughput
    ...         i. UE4 Register And PDU Session Setup On Cell1_11
    ...         j. UE4 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful, Blind Add Cell2_1 Cell2_2 and Cell2_13 as Scell
    ...         Step b: UE1 Traffic And Throughput is OK
    ...         Step c: UE2 Register And PDU Session Setup Successful, Blind Add Cell2_1 as Scell
    ...         Step d: UE2 Traffic And Throughput is OK
    ...         Step e: CPUE will restart without error
    ...         Step f: Partial release triggered, and the message procedures are expected
    ...         Step g: UE3 Register And PDU Session Setup Successful, Blind Add Cell2_1 Cell2_2 and Cell2_13 as Scell
    ...         Step h: UE3 Traffic And Throughput is OK
    ...         Step i: UE4 Register And PDU Session Setup Successful, Blind Add Cell2_1 as Scell
    ...         Step j: UE4 Traffic And Throughput is OK
    [Tags]    QC_281513
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=1    nwslice=1    gateway=1    scell1pci=50    scell2pci=51
    ...    scell3pci=63
    Run Traffic And Verify Throughput    ue_id=1
    UE Register And PDU Session Setup With Blind 1 Scell Addition    ue_id=2    nwslice=2    gateway=1    scell1pci=50
    Run Traffic And Verify Throughput    ue_id=2
    Kill LXC container for CPUE1 on gnb1
    sleep    3s    wait for CPUE recovery successfully
    Check WireShark Log    ${CURDIR}${/}A2A_KD_003${/}a2a.ini    wait_string=ResetResponse::1
    Check WireShark Log GNB2    ${CURDIR}${/}A2A_KD_003${/}a2a_gnb2.ini    wait_string=ResetAcknowledge::1
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=3    nwslice=1    gateway=1    scell1pci=50    scell2pci=51
    ...    scell3pci=63
    Run Traffic And Verify Throughput    ue_id=3
    UE Register And PDU Session Setup With Blind 1 Scell Addition    ue_id=4    nwslice=2    gateway=1    scell1pci=50
    Run Traffic And Verify Throughput    ue_id=4

CB008140-ET-KE003_Partial reset by CPUE failure on external gnb
    [Documentation]
    ...    This case is to test partial UE release will trigger when CPUE pool failure on external gnb
    ...    This case partly covered CB008140-K#B9: Reset of BBU (ABIL/ABIO/ABIN etc.) hosting ext-SCell
    ...    [Configuration]:
    ...    Cell id=11 gnb=2 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=345000:364000 gscn=4547 chBw=15MHz
    ...    Cell id=12 gnb=2 pci=20:1 tac=200 tdd_cell=off band=n3 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    Cell id=1 gnb=3 pci=16:2 tac=200 tdd_cell=on band=n77 nr_arfcn=663400:663400 gscn=8159 chBw=100MHz
    ...    weightForSCellSelection=70
    ...    Cell id=2 gnb=3 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    weightForSCellSelection=70
    ...    Cell id=13 gnb=3 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    weightForSCellSelection=5
    ...    Cell id=14 gnb=3 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    weightForSCellSelection=5
    ...    UE capability support n3+n28+n77+n77
    ...    2.Test Case Steps:
    ...         a. UE1 Register And PDU Session Setup On Cell1_11
    ...         b. UE1 Start Traffic And Verify Throughput
    ...         c. CPUE pool failure on external gnb
    ...         d. A2A check the message procedure for CPUE pool failure on external gnb
    ...         e. UE2 Register And PDU Session Setup On Cell1_11
    ...         f. UE2 Start Traffic And Verify Throughput
    ...    3. Expected Results:
    ...         Step a: UE1 Register And PDU Session Setup Successful, Blind Add Cell2_1 Cell2_2 and Cell2_13 as Scell
    ...         Step b: UE1 Traffic And Throughput is OK
    ...         Step c: CPUE will restart without error
    ...         Step d: Partial release triggered, and the message procedures are expected
    ...         Step e: UE2 Register And PDU Session Setup Successful, Blind Add Cell2_1 Cell2_2 and Cell2_13 as Scell
    ...         Step f: UE2 Traffic And Throughput is OK
    [Tags]    QC_281512    KE003
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=1    nwslice=1    gateway=1    scell1pci=50    scell2pci=51
    ...    scell3pci=63
    Run Traffic And Verify Throughput    ue_id=1
    Kill LXC container for CPUE1 on gnb2
    sleep    3s    wait for CPUE recovery successfully
    Check WireShark Log    ${CURDIR}${/}A2A_KE_003${/}a2a.ini    wait_string=NGResetAcknowledge::1
    #Check WireShark Log GNB2    ${CURDIR}${/}A2A_KE_003${/}a2a_gnb2.ini    wait_string=ResetResponse::1
    UE Register And PDU Session Setup With Blind 3 Scell Addition    ue_id=2    nwslice=1    gateway=1    scell1pci=50    scell2pci=51
    ...    scell3pci=63
    Run Traffic And Verify Throughput    ue_id=2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

UE Register And PDU Session Setup With Blind 3 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11    ${scell1pci}=50    ${scell2pci}=51
    ...    ${scell3pci}=63
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Should Contain    ${ret1}    sCellIndex2,sCellConfigCommon{physCellId${scell2pci}
    Should Contain    ${ret1}    sCellIndex3,sCellConfigCommon{physCellId${scell3pci}
    Sleep    5s    #wait all Scell info print

UE Register And PDU Session Setup With Blind 1 Scell Addition
    [Arguments]    ${ue_id}=1    ${nwslice}=1    ${gateway}=1    ${enb_id}=2    ${cell_id}=11    ${scell1pci}=50
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    pass_regexp=NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}
    ...    pass_regexp=activated successfully at airphone
    ${ret1}=    Remove String    ${ret1}    \r    \n    ${SPACE}
    Should Contain    ${ret1}    sCellToAddModList{{sCellIndex1,sCellConfigCommon{physCellId${scell1pci}
    Sleep    5s    #wait all Scell info print

Run Traffic And Verify Throughput
    [Arguments]    ${ue_id}=1
    Run Keywords    Execute Egate Command
    ...    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=1 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue
    ...    AND    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=2 protocol=tcp mbps=150 dir=dl
    ...    Started Downlink Internal traffic over TCP on Ue    sleep_time=2
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 trf_id=3 protocol=tcp mbps=50 dir=ul
    Verify Throughput    ${ue_id}

Delta Commission To locked
    Delta Commission Parameters GNB2    ${online_modify_scell_administrativeState_to_Locked}
    BuiltIn.Log To Console    Online Update Parameters is done

Delta Commission To unlocked
    Delta Commission Parameters GNB2    ${online_modify_scell_administrativeState_to_Unlocked}
    BuiltIn.Log To Console    Online Update Parameters is done
    sleep    60s    #wait xp setup

Verify Throughput
    [Arguments]    ${ue_id}=1    ${Tput_dl}=280    ${Tput_ul}=20    ${sleep_time}=15s
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    #Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}

Kill LXC container for CPUE1 on gnb1
    Execute Cmd On Gnb    ps -ef|grep /CPUENODE|grep -i lxc-start    fsp1
    ${processIdList}    Execute Cmd On Gnb    ps -ef|grep /CPUENODE|grep -i lxc-start |awk '{print \$2}'    fsp1
    Execute Cmd On Gnb    kill -9 ${processIdList.split('\n')}[0]    fsp1
    sleep    120s    #wait CPUE process setup,to avoid cell restart
    Execute Cmd On Gnb    kill -9 ${processIdList.split('\n')}[1]    fsp1

Kill LXC container for CPUE1 on gnb2
    Execute Cmd On Gnb2    ps -ef|grep /CPUENODE|grep -i lxc-start    fsp1
    ${processIdList}    Execute Cmd On Gnb2    ps -ef|grep /CPUENODE|grep -i lxc-start |awk '{print \$2}'    fsp1
    Execute Cmd On Gnb2    kill -9 ${processIdList.split('\n')}[0]    fsp1
