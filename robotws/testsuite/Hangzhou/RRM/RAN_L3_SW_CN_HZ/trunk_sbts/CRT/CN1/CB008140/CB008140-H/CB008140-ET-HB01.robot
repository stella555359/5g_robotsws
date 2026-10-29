*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_[LO][LO]_AP_[LOO]_SANSA_FS_ECPRI_CMWV_TDD
...    owner-jing.ye    release-SBTS23R3    team-ROCK
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB1}
...    @{PARAMS_FOR_OTHERS}
...    @{8290_Enable_GNB1}

@{PARAMS_IN_SCF_GNB2}
...    @{PARAMS_FOR_CA}
...    @{PARAMS_ADJ_REL_FOR_GNB2}
...    @{PARAMS_FOR_OTHERS}
...    @{GNB2_CA_rel_for_NRCELL_14}
...    @{8290_Enable_GNB2}

@{PARAMS_FOR_CA}
...    NRBTS:actCarrierAggregation=true
...    NRBTS:caConfigurationSupport=4CCDL_2CCUL
...    NRBTS:weightForIgnbCaSelection=1
...    NRBTS:actIncXn=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${CA_support_list}
...    NRBTS/NRDRB_RLC_AM-1:ulTReassemblyIBCA=40
...    NRBTS/NRDRB_RLC_AM-2:ulTReassemblyIBCA=40
...    NRDU-1:actInterGnbCa=DLOnly
...    NRDU-1:dlToUlContributionRatio=101
...    NRDU-1:xgUplane:ipV4AddressDN1=MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1
...    NRCELL:actK1Opt=intraAndInter-gNB
...    NRCELL:weightForSCellSelection=50
...    NRBTS:actMeasBasedSCellAdditionSa=disabled
...    NRDU-1:actConnectedModeMobilityCA=true

@{PARAMS_ADJ_REL_FOR_GNB1}
...    NRBTS/NRADJGNB-2:administrativeState=Unlocked
...    NRBTS/NRADJGNB-2:gNbIdLength=22
...    NRBTS/NRADJGNB-2:gNodeBId=2
...    NRBTS/NRADJGNB-2:weightForIgnbCaSelection=2
...    NRBTS/NRADJGNB-2:xnLinkRef=1
...    NRBTS/NRADJGNB-2:gnbPlmn:mcc=311
...    NRBTS/NRADJGNB-2:gnbPlmn:mnc=489
...    NRBTS/NRADJGNB-2:gnbPlmn:mncLength=3
...    NRBTS/NRADJNRCELL-1:cellDepType=SA+NSA
...    NRBTS/NRADJNRCELL-1:fiveGsTac=200
...    NRBTS/NRADJNRCELL-1:gNbId=2
...    NRBTS/NRADJNRCELL-1:gNbIdLength=22
...    NRBTS/NRADJNRCELL-1:lcrId=1
...    NRBTS/NRADJNRCELL-1:nrarfcn=658000
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
...    NRBTS:sCellActivationMethod=blind

@{8290_Enable_GNB1}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL-11/NRCELL_FDD-1:chBwDl=10MHz
...    NRCELL-11/NRCELL_FDD-1:chBwUl=10MHz
...    NRBTS/NRCELL-11/NRCELL_FDD-1:nrarfcnDl=368400
...    NRBTS/NRCELL-11/NRCELL_FDD-1:nrarfcnUl=349400
...    NRBTS/NRCELL-11:gscnOrSsPbchArfcn=4605


@{PARAMS_ADJ_REL_FOR_GNB2}
...    NRBTS/NRADJGNB-1:administrativeState=Unlocked
...    NRBTS/NRADJGNB-1:gNbIdLength=22
...    NRBTS/NRADJGNB-1:gNodeBId=1
...    NRBTS/NRADJGNB-1:weightForIgnbCaSelection=1
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
...    NRBTS/NRADJNRCELL-11:ssbFrequency=368430
...    NRBTS/NRADJNRCELL-11:freqBandIndicatorNR=3
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
...    NRBTS/NRADJNRCELL-12:ssbFrequency=373970
...    NRBTS/NRADJNRCELL-12:freqBandIndicatorNR=3
...    NRBTS:sCellActivationMethod=bufferBased

@{8290_Enable_GNB2}
...    NRBTS:actSCellSwapFr1=a6BasedSa
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRCELL:a6MeasSCellSwapEnabled=rsrp
...    NRCELL:a6MeasSCellSwapSsbRsrp:a6HysteresisSCellSwapSsbRsrp=0|a6OffsetSCellSwapSsbRsrp=20|a6TimeToTrigSCellSwapSsbRsrp=ms480
...    NRCELL:a6MeasSCellSwapSsbRsrq:a6HysteresisSCellSwapSsbRsrq=0|a6OffsetSCellSwapSsbRsrq=20|a6TimeToTrigSCellSwapSsbRsrq=ms480
...    NRCELL:reportAmountA6MeasSCellSwap=r4
...    NRCELL:reportIntervalA6MeasSCellSwap=ms120
...    NRCELL:thresholdSCellSwapSourceRsrp=66
...    NRCELL:thresholdSCellSwapSourceRsrq=67
...    NRCELL-1:chBw=40MHz
...    NRCELL-1:nrarfcn=658000
...    NRCELL-1:gscnOrSsPbchArfcn=8103


@{PARAMS_FOR_OTHERS}


...    NRBTS:actRanSharing=false
...    NRCELL:actCDrx=false
...    NRBTS:cipherPrefL:nea0=8
...    NRBTS:cipherPrefL:nea1_128=0
...    NRBTS:cipherPrefL:nea2_128=0
...    NRBTS:cipherPrefL:nea3_128=0
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRBTS:iGnbCaXnCfUpBackOffTmr=60
...    NRBTS:iGnbCaXnSetupReqTmr=60
...    NRBTS:iGnbCaXnSetupRespTmr=60
...    NRBTS:intGnbScellTempBlockTmr=60

@{GNB2_CA_rel_for_NRCELL_14}
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-11:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-11:gNbId=1
...    NRCELL-14/NRREL-11:gNbIdLength=22
...    NRCELL-14/NRREL-11:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-11:lcrId=11
...    NRCELL-14/NRREL-11:removeNotAllowed=false
...    NRCELL-14/NRREL-11:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-11:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-11:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-11:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-11:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-11:sCellPrio=2
...    NRCELL-14/NRREL-13:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-13:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-13:gNbId=2
...    NRCELL-14/NRREL-13:gNbIdLength=22
...    NRCELL-14/NRREL-13:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-13:lcrId=13
...    NRCELL-14/NRREL-13:removeNotAllowed=false
...    NRCELL-14/NRREL-13:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-13:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-13:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-13:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-13:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-13:sCellPrio=1
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-1:gNbId=2
...    NRCELL-14/NRREL-1:gNbIdLength=22
...    NRCELL-14/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-1:lcrId=1
...    NRCELL-14/NRREL-1:removeNotAllowed=false
...    NRCELL-14/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-1:sCellPrio=1
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-14/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-14/NRREL-2:gNbId=2
...    NRCELL-14/NRREL-2:gNbIdLength=22
...    NRCELL-14/NRREL-2:handoverAllowedSA=allowed
...    NRCELL-14/NRREL-2:lcrId=2
...    NRCELL-14/NRREL-2:removeNotAllowed=false
...    NRCELL-14/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-14/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-14/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-14/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-14/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-14/NRREL-2:sCellPrio=2
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=70|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=90|a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-1:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=480ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=320ms
...    NRCELL-13:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=40|a2TimeToTriggerSCellRelSsbRsrp=320ms

${CA_support_list}    ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Any_Sa,ca_Fr1Tdd_Any_Sa

@{expectca_UE1_FDD}
...    physCellId 62
...    SCellIndex 1 activated successfully
...    eventId eventA2

@{A6_Configured}
...    eventId eventA6

@{expectca_UE1_TDD}
...    physCellId 50
...    SCellIndex 2 activated successfully
...    eventId eventA6
...    eventId eventA2

@{Swap_pass_regexp}
...    rrcReconfigurationComplete
...    PhysCellId: 51] SCellIndex 1 activated successfully at airphone

@{Swap_back_pass_regexp}
...    rrcReconfigurationComplete
...    PhysCellId: 50] SCellIndex 2 activated successfully at airphone

${RRC_RECONF_ADD1DLSCELL_ATT_SA}    M55118C05505
#This counter indicates the total number of RRC reconfiguration attempts for 1 SCell addition in DL in SA mode.
#Note: It's not incremented in the case of the SCell Change or SCell Swap procedures.

${RRC_RECONF_ADD1DLSCELL_SUCC_SA}    M55118C05506
#This counter indicates the total number of successful RRC reconfiguration attempts for 1 SCell addition in DL in SA mode.
#Note: It's not incremented in the case of the SCell Change or SCell Swap procedures.

${SCELL_CHANGE_ATT_SA}    M55118C06506
#The total number of RRC Reconfiguration Request messages changing SCell(s) in SA mode.
#Note: This counter is related to the SCell Change procedure only, 
#e.g. it is not incremented for regular SCell Addition or SCell Swap procedures.

${SCELL_CHANGE_SUCC_SA}    M55118C06507
#The total number of successful RRC Reconfiguration Changing current SCell(s) in SA mode.
#Note: This counter is related to the SCell Change procedure only, 
#e.g. it is not incremented for regular SCell Addition or SCell Swap procedures.

${GNB_DU_SCELL_1_ADMI_REQ_SA}    M55139C01003
#This counter indicates the number of radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${GNB_DU_SCELL_1_ADMI_SUCC_SA}    M55139C01004
#This counter indicates the number of successful radio admission requests for exactly 1 SCell before the CA configuration on RRC.
#It's measured in PCell in SA mode in DU only.

${UE_PCELL_1_CONF_SCELL_DL_SA}    M55118C05507
#This counter indicates the sum of samples for the total number of CA UEs in the current cell configured as a PCell with 1 configured SCell in DL.

${SCELL_SWAP_1_ATT_SA}    M55118C10501
#The total number of SCell swap attempts for 1 SCell in the PCell for SA mode.

${SCELL_SWAP_1_SUCC_SA}    M55118C10502
#The total number of successful SCell swap attempts for 1 SCell in the PCell for SA mode.

${UE_SCELL_1_CONF_SCELL_DL_SA}    M55118C05508
#The current number of SCell UEs with 1 configured SCell in DL is calculated when the sample timer expires.

${GNB_DU_SCELL_ADMI_REQ_SA}    M55139C01001
#This counter indicates the total number of radio admission requests for SCell before the CA configuration on RRC.
#It's measured in SCell in SA mode in DU only.

${GNB_DU_SCELL_ADMI_SUCC_SA}    M55139C01002
#This counter indicates the total number of successful radio admission requests for SCell before the CA configuration on RRC.
#It's measured in SCell in SA mode in DU only.

*** Test Cases ***
CB008140-ET-HB01 Verify CA setup with event A6 for SCell swap activation during scell addition and scell change 2CC
    [Documentation]
    ...    The purpose of this test case is to verify A6 for scell swap will be configured when scell and swap candidate are in the same gnb
    ...    with pcell during scell addition and scell change procedure.
    ...    [GNB-1 Configuration]:
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n28 nr_arfcn=355000:374000 gscn=4675 chBw=15MHz
    ...    [GNB-2 Configuration]:
    ...    Cell id=1 gnb=2 pci=16:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    cell id=2 gnb=2 pci=17:0 tac=200 tdd_cell=on band=n77 nr_arfcn=658000:658000 gscn=8103 chBw=40MHz
    ...    Cell id=13 gnb=2 pci=20:2 tac=200 tdd_cell=off band=n3 nr_arfcn=349400:368400 gscn=4605 chBw=10MHz
    ...    Cell id=14 gnb=2 pci=21:0 tac=200 tdd_cell=off band=n28 nr_arfcn=143400:153400 gscn=1916 chBw=15MHz
    ...    cell-11/cell-1/cell-2/cell-13 has been configured as candidate SCell of Cell-14.
    ...    2.Test Case Steps:
    ...         a. UE1 attach to cell_14 and start traffic on pcell is successfully.
    ...         b. Trigger A1 scell addition higher than a1ThresholdSCellAddSsbRsrpFDD but lower than a1ThresholdSCellAddSsbRsrpTDD. 
    ...            FDD scell cell-13 should be added sccessfully. 
    ...         c. Trigger A1 scell change, scell cell-1 should be added as scell and A6 configured.
    ...         d. Trigger A6 MR to swap from scell-1 to scell-2.
    ...         e. Trigger A6 MR to swap back from scell-2 to scell-1.
    [Tags]    QC_277548    CA_LABEL-FF (15MHz_FDD_n28+ 10MHz_FDD_n3)    CA_LABEL-FT (15MHz_FDD_n28+ 40MHz_TDD_n77)
    Clear Counter Files gnb2
    UE Attach And Start Traffic
    Trigger A1 Scell Addition Should Be successful
    Trigger A1 Scell Change Should Be successful
    Trigger A6 Scell Swap Shoul Be Successful
    Trigger A6 Scell Swap Back Shoul Be Successful
    UE Deregister From gNB    1
    Check Counters in GNB2

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup 2Airphone Env    fddtdd_sansa_cmwv/6cells_gnb1_2F_gnb2_2T2F

UE Attach And Start Traffic
    UE Attach And Setup PDU Session
    Send Throuput
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput on Pscell

UE Attach And Setup PDU Session
    [Arguments]    ${ue_id}=1    ${gateway}=1    ${enb_id}=3    ${cell_id}=14    ${pass_regexp}=NG RM Register
    Update UE capa    ${ue_id}    ${CB008140_N_Capa_Support_2CC_3CC_n3_n28_n41_n77}
    Execute Egate Command    ue_change_location id=${ue_id} enb=${enb_id} cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=${gateway}    QoS Routing Table

Trigger A1 Scell Addition Should Be successful
    Trigger A1MR To Add FDD Scell    ${expectca_UE1_FDD}    153370    80    100    1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    total_dl_tput=135

Trigger A1 Scell Change Should Be successful
    Trigger A1MR To Add TDD Scell    ${expectca_UE1_TDD}    153370    100    100    1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=2
	
Trigger A6 Scell Swap Shoul Be Successful
    Trigger ScellSwap    pass_regexp=${Swap_pass_regexp}    carrierfreq=657984    phycell_id=51    scell_id=2
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=1

Trigger A6 Scell Swap Back Shoul Be Successful
    Trigger ScellSwap    pass_regexp=${Swap_back_pass_regexp}    carrierfreq=657984    phycell_id=50    scell_id=1
    Wait Until Keyword Succeeds    60s    5s    Verify Throuput For 2CC    scell_id=2

Update UE capa
    [Arguments]    ${ue_id}    ${SA_Capa}    
    ${cmd}    catenate    ue_param id=${ue_id} ue_nr_capabilities=${SA_Capa}
    Execute Egate Command    ${cmd}
	
Trigger A1MR To Add FDD Scell
    [Arguments]    ${expectca}    ${carrierfreq}=663360    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${expectca}    fail_regexp=${A6_Configured}
	
Trigger A1MR To Add TDD Scell
    [Arguments]    ${expectca}    ${carrierfreq}=663360    ${srsrp_nr}=100    ${srsrq_nr}=50    ${ue_id}=1
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A1    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${expectca}

UE Deregister From gNB
    [Arguments]    ${ue_id}
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1    Traffic was stopped
    Execute Egate Command    ue_pdu_session_release ue=${ue_id} pdu=1    Successfully released PDU Session
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Send Throuput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=dl mbps=150 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 dir=ul mbps=30 trf_id=1    UE ${ue_id}: UDP UL

Verify Throuput on Pscell
    [Arguments]    ${ue_id}=1    ${pcell_dl}=100    ${ul}=27  
    ${pcell_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_tput}/1000 > ${pcell_dl}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput For 2CC
    [Arguments]    ${scell_id}=1    ${ue_id}=1    ${total_dl_tput}=270    ${ul_tput}=27
    ${pcell_dl}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pdsch    rate_type=ave
    Should Be True    ${pcell_dl}/1000 > 0
    ${total_dl}    Set Variable    ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > 0
    ${total_dl}    Evaluate    ${scell1_tput}+${total_dl}
    Should Be True    ${total_dl}/1000>${total_dl_tput}
    ${ul_throughput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=0    type=pusch    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul_tput}

Trigger ScellSwap
    [Arguments]    ${pass_regexp}    ${event_type}=A6    ${carrierfreq}=657984    ${nrsrp_nr}=30    ${nrsrq_nr}=30    ${ue_id}=1
    ...    ${scell_id}=2    ${phycell_id}=53
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_type}
    ...    srsrp_nr=11 srsrq_nr=11 scell=${scell_id} scell_rsrp=20 scell_rsrq=20 phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr}
    Execute Egate Command    ${cmd}    pass_regexp=${pass_regexp}

Check Counters in GNB2
    ${pm_counters}    Create List
    ...    NRCELL-14:${RRC_RECONF_ADD1DLSCELL_ATT_SA}=1    
    ...    NRCELL-14:${RRC_RECONF_ADD1DLSCELL_SUCC_SA}=1
    ...    NRCELL-14:${SCELL_CHANGE_ATT_SA}=1
    ...    NRCELL-14:${SCELL_CHANGE_SUCC_SA}=1
    ...    NRCELL-14:${GNB_DU_SCELL_1_ADMI_REQ_SA}=4
    ...    NRCELL-14:${GNB_DU_SCELL_1_ADMI_SUCC_SA}=4
    ...    NRCELL-14:${UE_PCELL_1_CONF_SCELL_DL_SA}>1
    ...    NRCELL-14:${SCELL_SWAP_1_ATT_SA}=2
    ...    NRCELL-14:${SCELL_SWAP_1_SUCC_SA}=2
    ...    NRCELL-1:${UE_SCELL_1_CONF_SCELL_DL_SA}>1
    ...    NRCELL-2:${UE_SCELL_1_CONF_SCELL_DL_SA}>1
    ...    NRCELL-13:${UE_SCELL_1_CONF_SCELL_DL_SA}>1
    ...    NRCELL-1:${GNB_DU_SCELL_ADMI_REQ_SA}=2
    ...    NRCELL-2:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-13:${GNB_DU_SCELL_ADMI_REQ_SA}=1
    ...    NRCELL-1:${GNB_DU_SCELL_ADMI_SUCC_SA}=2
    ...    NRCELL-2:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    ...    NRCELL-13:${GNB_DU_SCELL_ADMI_SUCC_SA}=1
    Check Counters GNB2    ${pm_counters}    wait=true
