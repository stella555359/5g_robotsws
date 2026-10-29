*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    RAN_5G_TDD    SBTS00    team-Blues_SGT&A    owner-Tingjian.Mao
...    CLOUD_5G_I_BOO_AP_LOO    CRT    CB008311    release-5G23R3    STATE_CONFIGURED    RAN_5G
Resource    ../../../../resources/DevHZ5_resource.robot

*** Variables ***
${NOKIA_XNAP_PLUGIN_FLAG}    ${True}
${NOKIA_F1AP_PLUGIN_FLAG}    ${True}
${SYSCOM_FLAG}    ${True}

@{PARAMS_IN_SCF}
...    NRBTS-1:cipherPrefL:nea0=8
...    NRBTS-1:cipherPrefL:nea1_128=0
...    NRBTS-1:cipherPrefL:nea2_128=0
...    NRBTS-1:cipherPrefL:nea3_128=0
...    NRBTS-1:integrityProtPrefL:nia0=0
...    NRBTS-1:integrityProtPrefL:nia1_128=0
...    NRBTS-1:integrityProtPrefL:nia2_128=0
...    NRBTS-1:integrityProtPrefL:nia3_128=9
...    NRCELL:lteToNrTimeOffset=0
...    @{NRREL}
...    @{8290_enable}
...    @{HO_related}
...    @{8311_enable}
...    @{NRREL_NSA}


@{HO_related}
...    NRBTS-1:srb3SupportEnabled=true
...    NRBTS-1:actIntraFreqHoSA=true
...    NRBTS-1:actIntraFreqInterGnbMobilityNSA3x=true
...    NRBTS-1:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS-1/NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:absThreshSsbRsrpConsolidation=0
...    NRCELL:sMeasConfigSsbRsrp=10
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=2|a3OffsetSsbRsrp=10|a3TimeToTriggerSsbRsrp=ms0

@{NRREL}
...    NRCELL-3/NRREL-12:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-12:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-12:gNbId=1
...    NRCELL-3/NRREL-12:gNbIdLength=22
...    NRCELL-3/NRREL-12:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-12:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-12:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-12:removeNotAllowed=false
...    NRCELL-3/NRREL-12:lcrId=12
...    NRCELL-3/NRREL-12:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-12:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-12:sCellOperationalMode=dlOnly
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-3:lcrId=3
...    NRCELL-11/NRREL-3:handoverAllowedSA=allowed
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:scs=30 KHz
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-11/NRHOIF-1:ssbFrequency=508110
...    NRCELL-11:measGapSelectionSA=favourUeThroughput
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=5
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=20
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms100
...    NRCELL:a1MeashoSsbRsrqSA:a1HysteresishoSsbRsrqSA=0
...    NRCELL:a1MeashoSsbRsrqSA:a1ThresholdhoSsbRsrqSA=20
...    NRCELL:a1MeashoSsbRsrqSA:a1TimeToTriggerhoSsbRsrqSA=ms100
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=5
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=20
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms40
...    NRCELL:a2MeashoSsbRsrqSA:a2HysteresishoSsbRsrqSA=5
...    NRCELL:a2MeashoSsbRsrqSA:a2ThresholdhoSsbRsrqSA=20
...    NRCELL:a2MeashoSsbRsrqSA:a2TimeToTriggerhoSsbRsrqSA=ms40
...    NRCELL-11:a1MeashoEnabled=rsrp
...    NRCELL-11:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-11:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-11:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-11:a2MeashoEnabled=rsrp
...    NRCELL-11:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-11:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-11:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

@{NRREL_NSA}
...    MRBTS-1/NRBTS-1:actInterFreqIntraGnbMobilityNSA=true
...    NRCELL-3/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-3/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-3/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-3/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-3/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-3/NRHOIF-1:scs=15 KHz
...    NRCELL-3/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-3/NRHOIF-1:ssbFrequency=126750
...    NRCELL-3:measGapSelectionSA=favourUeThroughput
...    NRCELL-3:measGapSelection=favourUeThroughput
...    NRCELL-3/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-3/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3OffsetSsbRsrp=30|a3TimeToTriggerSsbRsrp=ms64
...    NRCELL-3:ifhoSsbSmtcOffset=0
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-4:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-4:gNbId=1
...    NRCELL-12/NRREL-4:gNbIdLength=22
...    NRCELL-12/NRREL-4:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-4:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-4:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-4:removeNotAllowed=false
...    NRCELL-12/NRREL-4:lcrId=4
...    NRCELL-12/NRREL-4:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-4:handoverAllowedSA=allowed
...    NRCELL-12/NRREL-4:sCellOperationalMode=dlOnly
...    NRCELL-3:a1MeashoEnabled=rsrp
...    NRCELL-3:a1MeashoSsbRsrp:a1HysteresishoSsbRsrp=0
...    NRCELL-3:a1MeashoSsbRsrp:a1ThresholdhoSsbRsrp=34
...    NRCELL-3:a1MeashoSsbRsrp:a1TimeToTriggerhoSsbRsrp=ms480
...    NRCELL-3:a2MeashoEnabled=rsrp
...    NRCELL-3:a2MeashoSsbRsrp:a2HysteresishoSsbRsrp=1
...    NRCELL-3:a2MeashoSsbRsrp:a2ThresholdhoSsbRsrp=34
...    NRCELL-3:a2MeashoSsbRsrp:a2TimeToTriggerhoSsbRsrp=ms480

@{8290_enable}
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actSCellSwapFr1=a6BasedSa
...    NRBTS-1:sCellActivationMethod=bufferBased
...    NRCELL:cellDepType=SA+NSA
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=75
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=85
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=80ms
...    NRDU-1:carrierAggregationSupportList=ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Nsa,ca_Fr1Tdd_Nsa

@{8311_enable}
...    NRBTS:actBufferBasedSCellAddition=oneShot_Dl_Fr1
...    NRCELL:dlSCellConfigLevel=10
...    NRCELL:dlSCellConfigLevelNum=20
...    NRCELL-12:dlSCellConfigLevel=5
...    NRCELL-12:dlSCellConfigLevelNum=10
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:actInterFreqHoSA=true

@{C024_ADD_NIDD}
...    NRBTS:actSCellReleaseForInactiveSCell=timer_based_Fr1
...    NRCELL:sCellInactivityReleaseTimer=10
...    NRCELL-12/NRREL-4:sCellAdditionMethod=blind

*** Test Cases ***
CB008311-ET-B004_2CC_TF_SA_Interaction_with_HO_Optimized_for_CA_for_A1_Measurement_based_SCell_addition_DL_buffer_monitoring_activation
    [Documentation]
    ...    1. TThis scenario describes gNB activating DL buffer monitoring after Handover to target cell in SA mode, based
    ...       on optimized CA during HO. A1 threshold criteria is checked by target cell using the measurement results sent
    ...       by source cell. Due to A1 threshold criteria being met, DL data monitoring is triggered right away without
    ...       waiting for A1 measurement report. Once sufficient DL data volume is received such that a DL buffer overflow
    ...       trigger occurs at the gNB, the gNB configures CA to the UE.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=100MHz
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=100MHz
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=10MHz
    ...    Configure CA Relations: Cell3-Cell12, Interfreq Handover NRREL :cell11-cell3
    ...    sCellAdditionMethod:covBasedA1
    ...    3. Test Case Steps:
    ...         1) UE81 attach to the FDD cell11 and send A2 A3 trigger handover to TDD Cell3
    ...            The handover threshold used is greater than A1,check reportOnLeave is in the A1 measurement
    ...            check activate DL data buffer monitoring
    ...         2) DL data transferred on pcell only for UE81,UE81 send A1 measurement again no scell add
    ...         3) High DL data rate starts and buffer overflow happens at gNB-DU,Cell12 as scell at the UE81
    ...         4) UE82 attach to the FDD cell11, execute step 1 ,UE82 sends A1 MR ,indicating UE82 is out of A1 threshold coverage.
    ...         5) High DL data rate starts transferred to UE82 and does not have CA configured.
    ...         6) UE83 attach to the FDD cell11, UE83 send A2 and A3 trigger handover to TDD Cell3. with A1 threshold criteria
    ...            is not met for SCell addition,UE83 is connected with PCell only A1 measurement is configured at the UE.
    ...            DL buffer monitoring is not active at the gNB-DU
    ...         7) SA UE Deregister From gNB.
    [Tags]    QC_279043    B004    CA_LABEL-TF(80MHz_TDD_n41+10MHz_FDD_n71)
    UE81 IntraFreA3 Ho and check buffer monitoring
    UE82 IntraFreA3 Ho and check buffer monitoring
    UE83 IntraFreA3 Ho and check buffer monitoring
    Check Wireshark Log    ${CURDIR}${/}A2A_B004${/}a2a.ini    wait_string=UEContextRelease::30

CB008311-ET-B005_2CC_FT_NSA_Interaction_with_HO_Optimized_for_CA_for_A1_Measurement_based_SCell_addition_DL_buffer_monitoring_activation
    [Documentation]
    ...    1. This scenario describes gNB activating DL buffer monitoring after Handover to target cell in NSA mode, based
    ...       on optimized CA during HO. A1 threshold criteria is checked by target cell using the measurement results sent
    ...       by source cell. Due to A1 threshold criteria being met, DL data monitoring is triggered right away without
    ...       waiting for A1 measurement report. Once sufficient DL data volume is received such that a DL buffer overflow
    ...       trigger occurs at the gNB, the gNB configures CA to the UE.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=100MHz
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=100MHz
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=10MHz
    ...    Configure CA Relations: Cell12-Cell4, Interfreq Handover NRREL :cell3-cell12
    ...    sCellAdditionMethod:covBasedA1
    ...    3. Test Case Steps:
    ...        1) UE91 attaches to the LTE cell and initiates EN-DC toward the TDD NR cell3,UE1 send A2 and A3 trigger
    ...           handover to FDD Cell12. with A1 threshold criteria is met then the gNB-CU performs DL buffer monitoring
    ...           activation checks pass.The gNB-CU sends message to the gNB-DU to activate DL data buffer monitoring
    ...        2) High DL data rate starts for UE91 and CA success
    ...        3) For UE92 execute step1,UE92 sends A1 MR with A1 threshold criteria is not met
    ...           the gNB-DU to deactivate DL data buffer monitoring for UE2
    ...        4) High DL data rate starts for UE92 and CA unsuccess
    ...        5) UE92 sends A1 MR again but A1 threshold criteria is met and CA success
    ...        6) For UE31 execute step1,but A1 threshold criteria is not met then check no DL buffer monitoring active
    ...        7) UE31 sends A1 MR with A1 threshold criteria is met and High DL data rate starts for UE31 so CA success
    ...        8) NSA UE Deregister From gNB.
    [Tags]    QC_279047    B005    CA_LABEL-FT(10MHz_FDD_n71+80MHz_TDD_n41)
    NSA CALL UE91 IntraFreA3 Ho and check buffer monitoring
    NSA CALL UE92 IntraFreA3 Ho and check buffer monitoring
    NSA CALL UE31 IntraFreA3 Ho and check buffer monitoring
    Check Wireshark Log    ${CURDIR}${/}A2A_B005${/}a2a.ini    wait_string=UEContextRelease::18

CB008311-ET-C024_2CC_FT_SA_gNB_CU_performs_SCell_release_due_to_prolonged_data_inactivity_SCell_deactivation_timer_is_infinity
    [Documentation]
    ...    1. This scenario describes
    ...       1) CB008311-C#B1 Feature activation for SCell release due to prolonged data inactivity,
    ...          fully covered Operator activates SCell release due to prolonged data inactivity via NIDD parameter change.
    ...          After feature activation, the gNB may trigger an SCell release if it has been deactivated for a configurable
    ...          length of time.
    ...       2) CB008311-C#B3 gNB-CU performs SCell release due to prolonged data inactivity,fully covered gNB releases
    ...          an SCell after determining the SCell has been deactivated longer than the operator configurable threshold
    ...          for SCell release for inactive SCells.
    ...    2. Configuration:
    ...    Cell id=1 gnb=1 pci=16:2 tac=200 tdd_cell=on band=n78 nr_arfcn=633000:633000 gscn=7840 chBw=100MHz
    ...    Cell id=2 gnb=1 pci=17:0 tac=200 tdd_cell=on band=n78 nr_arfcn=648000:648000 gscn=8000 chBw=100MHz
    ...    Cell id=3 gnb=1 pci=17:1 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=4 gnb=1 pci=17:2 tac=200 tdd_cell=on band=n41 nr_arfcn=508020:508020 gscn=6351 chBw=80MHz
    ...    Cell id=11 gnb=1 pci=20:0 tac=200 tdd_cell=off band=n71 nr_arfcn=134100:124900 gscn=1562 chBw=10MHz
    ...    Cell id=12 gnb=1 pci=20:1 tac=200 tdd_cell=off band=n71 nr_arfcn=136100:126900 gscn=1584 chBw=10MHz
    ...    Configure CA Relations:Cell12-Cell4
    ...    sCellAdditionMethod:blind
    ...    3. Test Case Steps:
    ...        1) UE attaches to the FDD Cell12 with high DL non-GBR data rate and configures the SCell_cell4 to the UE
    ...        2) Data transfer is on the PCell only,due to sCellDeactivationTimerGNB is infinit,so after data transfer
    ...           is on the PCell only for sCellInactivityReleaseTimer expires,the gNB-DU sends a private unacknowledged
    ...           F1AP message to the gNB-CU for SCell release,then activates DL buffer monitoring for SCell Addition
    ...        3) high DL non-GBR data rate to UE,CA again
    ...        4) Data transfer is on the PCell only again,before sCellInactivityReleaseTimer expires,high DL non-GBR data
    ...          rate to UE,the gNB-DU stops and clears the SCell inactivity release timer,and does not send the SCell
    ...          release request to the gNB-CU.UE still keep in CA status.
    ...        5) SA UE Deregister From gNB.
    [Tags]    QC_279047    C024    CA_LABEL-FT(10MHz_FDD_n71+80MHz_TDD_n41)
    OnlineParamChange    ${C024_ADD_NIDD}
    UE SCell release due to prolonged data inactivity
    UE SCell not release due to prolonged data inactivity before sCellInactivityReleaseTimer expires
    UE Deregister From gNB
    Check Wireshark Log    ${CURDIR}${/}A2A_C024${/}a2a.ini    wait_string=UEContextRelease::10

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F

Modify Cfg
    Update Cfg    ue_param id=31 ue_nr_capabilities=${SA_Capa_perUE_Full_1} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}
    Update Cfg    ue_param id=92 ue_nr_capabilities=${SA_Capa_perUE_Full_1} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE}

OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters Gnb2    ${Online_Param}
    Cells Should Be OnAir

Sa Ue Attach
    [Arguments]    ${ue_id}=81    ${cell_id}=11    ${pass_regexp}=NG RM Register
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell_id}
    Execute Egate Command    ue_register id=${ue_id}    ${pass_regexp}

Setup pdu session with no scelladd
    [Arguments]    ${ue_id}=81
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal
    Execute Egate Command    ue_pdu_session_setup ue=${ue_id} pdu=1 nwslice=1 gw=1    pass_regexp=QoS Routing Table
    ...    fail_regexp=sCellIndex 1

SA UE Attach To NRcell 11
    [Arguments]    ${ue_id}=81
    Sa Ue Attach    ue_id=${ue_id}
    Setup pdu session with no scelladd    ue_id=${ue_id}

Send Throuput low DL data
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

Send Throuput High DL data
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=4    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=175 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=50 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

Send Throuput High DL data FDD
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=50 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=100 trf_id=3    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=20 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

stop Throuput on secll and check RRC Complete
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=1 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=2 dir=dl
    wait until keyword succeeds    9 min    5 sec    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=3 dir=dl
    ...    pass_regexp=rrcReconfigurationComplete

stop Throuput on secll
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=2 dir=dl
    Execute Egate Command    trf_data_stop ue=${ue_id} pdu=1 trf_id=3 dir=dl

Verify Throuput on Pscell and Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=30    ${scell_dl}=20    ${ul}=10    ${pcell_id}=0    ${scell_id}=1
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and no Throuput in Scell
    [Arguments]    ${ue_id}=81    ${pcell_dl}=30    ${ul}=10    ${pcell_id}=0    ${scell_id}=1
    sleep    3s    #sleep for sCellInactivityReleaseTimer non-timeout
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=current
    wait until keyword succeeds    2 min    5 sec    Should Be True    ${scell1_tput}/1000 == 0
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

Verify Throuput on Pscell and Scell For NSA
    [Arguments]    ${ue_id}=91    ${pcell_dl}=40    ${scell_dl}=20    ${ul}=6    ${pcell_id}=8    ${scell_id}=9
    sleep    15s    #sleep for stable traffic
    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-11 type=pdsch    pass_regexp=CellIndex
    ${scell0_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${pcell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell0_tput}/1000 > ${pcell_dl}
    ${scell1_tput}    Ap Get Throuput On Specific Scell    ue_id=${ue_id}    scell_id=${scell_id}    type=pdsch    rate_type=ave
    Should Be True    ${scell1_tput}/1000 > ${scell_dl}
    ${ul_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=ul    rate_type=ave
    Should Be True    ${ul_throughput}/1000>${ul}

UE Deregister From gNB
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    UE${ue_id}: detached    timeout=10s

Intrafreq Handover to Cell 3
    [Arguments]    ${carrierfreq}=125050    ${nrrel_carrierfreq}=508110    ${ue_id}=81    ${phycell_id}=52    ${nrsrp}=80
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=5 srsrq_nr=5
    Execute Egate Command    ${cmd}    pass_regexp=rrcReconfigurationComplete
    ${meas_id_A3}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A3    carrierfreq=${nrrel_carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp} nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Intra-eNB handover from EXT_ENB-2.11 to EXT_ENB-2.3 performed

NSA UE Attach To Target Cell 3
    [Arguments]    ${cell_id}=3    ${ue_id}=91
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    pass_regexp=reported successful RA    fail_regexp=SCellIndex 9 activated successfully at airphone

NSA Intrafreq Handover to Cell 12
    [Arguments]    ${carrierfreq}=508110    ${nrrel_carrierfreq}=126750    ${ue_id}=91    ${phycell_id}=61    ${nrsrp}=90
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=gp0:12 gap_trigger=gnb_triggered
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A2    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=5 srsrq_nr=5
    Execute Egate Command    ${cmd}    pass_regexp=Successfully reconfigured dual connectivity
    Execute Egate Command    ue_enb_param id=${ue_id} measurement_gap=off
    ${meas_id_A3}    get nr meas id for specific type and frequency    ${ue_id}    event_type=A3    carrierfreq=${nrrel_carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id_A3} event=A3 srsrp_nr=5 srsrq_nr=5
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp} nrsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=Proxy \\(eNB 2 cell 12\\) reported successful RA

Send Throuput For NSA
    [Arguments]    ${ue_id}=91
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=1    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=dl mbps=175 trf_id=2    UE ${ue_id}: UDP DL
    Execute Egate Command    trf_data_start ue=${ue_id} id=2 dir=ul mbps=10 trf_id=1    UE ${ue_id}: UDP UL
    sleep    15s    #sleep for stable traffic

UE Detach From gNB
    [Arguments]    ${ue_id}=91
    Execute Egate Command    ue_detach id=${ue_id}    UE${ue_id}: detached    timeout=10s

Trigger A1 MR to ScellAdd unsuccess
    [Arguments]    ${event_type}=A1    ${carrierfreq}=508110    ${srsrp_nr}=80    ${ue_id}=81
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=measurementReport
    ...    fail_regexp=PhysCellId: 61] SCellIndex 1 activated successfully at airphone

NSA Trigger A1 MR to ScellAdd unsuccess
    [Arguments]    ${event_type}=A1    ${carrierfreq}=126750    ${srsrp_nr}=70    ${ue_id}=92
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=measurementReport
    ...    fail_regexp=SCellIndex 9 activated successfully at airphone

NSA Trigger A1 MR to ScellAdd success
    [Arguments]    ${event_type}=A1    ${carrierfreq}=126750    ${srsrp_nr}=90    ${ue_id}=92
    ${meas_id}    get nr meas id for specific type and frequency    ${ue_id}
    ...    event_type=${event_type}    carrierfreq=${carrierfreq}
    ${cmd}    Catenate    ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=${event_type}
    ...    srsrp_nr=${srsrp_nr}    srsrq_nr=80
    Execute Egate Command    ${cmd}    pass_regexp=measurementReport

Verify no Scell
    [Arguments]    ${ue_id}=81    ${Tput_dl}=100    ${Tput_ul}=10
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

NSA Verify no Scell add
    [Arguments]    ${ue_id}=92    ${Tput_dl}=100    ${Tput_ul}=10
    ${dl_throughput}    Ap Get NSA Throughput    ue_id=${ue_id}    bearer_id=2    direction=dl    dc_cell_group=all    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=8-9 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-[0] *0 *0 *0
    Should Not Match Regexp    ${scell_tput}    CellIndex-[1]
    Should Be True    ${dl_throughput}/1000>${Tput_dl}

UE81 IntraFreA3 Ho and check buffer monitoring
    SA UE Attach To NRcell 11
    Intrafreq Handover to Cell 3
    Send Throuput low DL data
    Verify no Scell
    Trigger A1 MR to ScellAdd unsuccess
    Send Throuput High DL data
    Verify Throuput on Pscell and Scell
    UE Deregister From gNB

UE82 IntraFreA3 Ho and check buffer monitoring
    SA UE Attach To NRcell 11    ue_id=82
    Intrafreq Handover to Cell 3    ue_id=82
    Trigger A1 MR to ScellAdd unsuccess    srsrp_nr=70    ue_id=82
    Send Throuput High DL data    ue_id=82
    Verify no Scell    ue_id=82
    UE Deregister From gNB    ue_id=82

UE83 IntraFreA3 Ho and check buffer monitoring
    SA UE Attach To NRcell 11    ue_id=83
    Intrafreq Handover to Cell 3    ue_id=83    nrsrp=50
    UE Deregister From gNB    ue_id=83

NSA CALL UE91 IntraFreA3 Ho and check buffer monitoring
    NSA UE Attach To Target Cell 3
    NSA Intrafreq Handover to Cell 12
    Send Throuput For NSA
    Verify Throuput on Pscell and Scell For NSA
    UE Detach From gNB

NSA CALL UE92 IntraFreA3 Ho and check buffer monitoring
    NSA UE Attach To Target Cell 3    ue_id=92
    NSA Intrafreq Handover to Cell 12    ue_id=92
    NSA Trigger A1 MR to ScellAdd unsuccess
    Send Throuput For NSA    ue_id=92
    NSA Verify no Scell add    ue_id=92
    NSA Trigger A1 MR to ScellAdd success    ue_id=92
    Verify Throuput on Pscell and Scell For NSA    ue_id=92
    UE Detach From gNB    ue_id=92

NSA CALL UE31 IntraFreA3 Ho and check buffer monitoring
    NSA UE Attach To Target Cell 3    ue_id=31
    NSA Intrafreq Handover to Cell 12    ue_id=31    nrsrp=70
    NSA Trigger A1 MR to ScellAdd success    ue_id=31
    Send Throuput For NSA    ue_id=31
    Verify Throuput on Pscell and Scell For NSA    ue_id=31
    UE Detach From gNB    ue_id=31

UE SCell release due to prolonged data inactivity
    Sa Ue Attach    ue_id=81    cell_id=12
    Setup pdu session with no scelladd
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=30    scell_dl=30
    stop Throuput on secll and check RRC Complete

UE SCell not release due to prolonged data inactivity before sCellInactivityReleaseTimer expires
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=30    scell_dl=30
    stop Throuput on secll
    Verify Throuput on Pscell and no Throuput in Scell
    Send Throuput High DL data FDD
    Verify Throuput on Pscell and Scell    pcell_dl=30    scell_dl=30
