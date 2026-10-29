*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CLOUD_5G_I_BLLL_AP_LOO
...    team-DevHZ5_SG2    owner-baijie.zhu    release-5G22R2    CB008015    CRT
Resource    ../../../../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMS_IN_SCF}
...    @{CB008015}
...    @{5GC001390}
...    @{CB006138}

@{5GC001390}
...    NRBTS/NRDU-1:actInterNumerologyCa=true

@{CB006138}
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=${CA_support_list}

${CA_support_list}
...    ca_Fr1Tdd_Fdd_Sa,ca_Fdd_Fdd,ca_Fdd_Fr1Tdd_Nsa,ca_Fr1Tdd_Nsa,ca_Fdd_Fr1Tdd_Sa,ca_Fr1Tdd_Sa

@{CB008015}
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRBTS-1:actGrflShdn=true
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actFdmScheduling=true
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:actCDrx=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-1:gNbId=1
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:removeNotAllowed=false
...    NRCELL-2/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:lcrId=11
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:removeNotAllowed=false
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-1/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=41
...    NRCELL-1/NRHOIF-1:numberOfTransmittedSsBlocks=6 beams
...    NRCELL-1/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-1/NRHOIF-1:ssbFrequency=518910
...    NRCELL-1/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-1:gNbId=1
...    NRCELL-11/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-11/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-2:lcrId=13
...    NRCELL-11/NRREL-2:gNbIdLength=22
...    NRCELL-11/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-3:gNbId=1
...    NRCELL-13/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-3:lcrId=12
...    NRCELL-13/NRREL-3:gNbIdLength=22
...    NRCELL-13/NRREL-3:removeNotAllowed=false
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-2:gNbId=1
...    NRCELL-13/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-2:lcrId=11
...    NRCELL-13/NRREL-2:gNbIdLength=22
...    NRCELL-13/NRREL-2:removeNotAllowed=false
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-1:gNbId=1
...    NRCELL-13/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-1:lcrId=1
...    NRCELL-13/NRREL-1:gNbIdLength=22
...    NRCELL-13/NRREL-1:removeNotAllowed=false
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-13/NRREL-10:gNbId=1
...    NRCELL-13/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-13/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-13/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-13/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-13/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-13/NRREL-10:lcrId=2
...    NRCELL-13/NRREL-10:gNbIdLength=22
...    NRCELL-13/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-2:gNbId=1
...    NRCELL-12/NRREL-2:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=blind
...    NRCELL-12/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-1:lcrId=1
...    NRCELL-12/NRREL-1:gNbIdLength=22
...    NRCELL-12/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-11/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=20
...    NRCELL-11/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-11/NRHOIF-1:freqBandIndicatorNR=71
...    NRCELL-11/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-11/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-11/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-11/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-11/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-11/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-11/NRHOIF-1:ssbFrequency=126750
...    NRCELL-11/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms160
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-12/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=25
...    NRCELL-12/NRHOIF-1:cellDepType=SA+NSA
...    NRCELL-12/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-12/NRHOIF-1:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-12/NRHOIF-1:a1BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:a2BasedPCellSwitchEnabled=false
...    NRCELL-12/NRHOIF-1:ssBurstSetPeriod=10
...    NRCELL-12/NRHOIF-1:a3MeasEnabled=none
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf10
...    NRCELL-12/NRHOIF-1:ifhoSsbSmtcDuration=sf1
...    NRCELL-12/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-12/NRHOIF-1:ssbFrequency=424090
...    NRCELL-12/NRHOIF-1:a5MeasEnabled=none
...    NRCELL-1:msg1FrequencyStart=19
...    NRCELL-2:msg1FrequencyStart=19
...    NRCELL-11:msg1FrequencyStart=9
...    NRCELL-12:msg1FrequencyStart=12
...    NRCELL-13:msg1FrequencyStart=11
...    NRCELL-14:msg1FrequencyStart=13

${GNB_SCELL_1_ADMI_SUCC_SA}    M55138C01502
${GNB_SCELL_2_ADMI_REQ_SA}    M55138C02501

@{Counters_Check_CB008015_A21_UE81}
...    NRCELL-11:${GNB_SCELL_2_ADMI_REQ_SA}=1
...    NRCELL-11:${GNB_SCELL_1_ADMI_SUCC_SA}=1

${cell2_lock}    NRCELL-2:administrativeState=Locked
${cell2_unlock}    NRCELL-2:administrativeState=Unlocked

@{Limited_maxNumOfSCellAlloc}
...    NRCELL-13:maxNumOfSCellAlloc=1
...    NRCELL-1:maxNumOfSCellAlloc=1

@{FddCellWeightHigherThantddCell}
...    NRCELL-11:weightForSCellSelection=50
...    NRCELL-12:weightForSCellSelection=50
...    NRCELL-13:weightForSCellSelection=100
...    NRCELL-1:weightForSCellSelection=40
...    NRCELL-2:weightForSCellSelection=40

@{expect_value}
...    sCellToAddModList
...    physCellId 61
...    physCellId 62
...    SCellIndex 2 activated successfully at airphone
...    SCellIndex 1 activated successfully at airphone

*** Test Cases ***
CB008015-ET-A21_A_B5_Blind scell selection based on different weighted scell bw and cell load when tdd weighted cell bw higher than fdd cell
    [Documentation]
    ...    1. The purpose of this test case is to check SCell selection based on weighted SCell bandwidth and cell load for SA call.
    ...    UE 81: support n66+n71,n71+n41,n66+n41,n66+n78, n41+n78,n71+n78,n66+n66+n71 CA (fullCap)
    ...    UE 85: support N66+N66+N71 CA (cell 11+cell 12+cell 13)
    ...    UE 83: support n71+n41,n66+n41 CA (cell 12+cell 1, cell 11+cell 1)
    ...    Final selection order in cell1 > cell2> (cell12 + cell13) > cell13 > cell12
    ...    2. Test Case Steps:
    ...    precondition: NRCELL-1 & NRCELL-13: maxNumOfSCellAlloc: 1
    ...    Step 1. Pre-requested UE UE85 is attached in cell 11. And blind SCell addition is triggered.
    ...    Expected Results: scell 12 and cell 13 can be added as SCell for UE85.
    ...    Step 2. Pre-requested UE UE83 is attached in cell 11. And blind SCell addition is triggered.
    ...    Expected Results: scell 1 can be added as SCell for UE83.
    ...    Step 3. SA UE-81 attached in cell 11, start data transfer
    ...    Blind SCell addition is triggered.
    ...    Expected Results: Cell 2 is added as SCell. Counter check is correct.
    ...    PM Counter check on 3rd round(Stepc):NRCELL-11: GNB_SCELL_2_ADMI_REQ_SA ==1    GNB_SCELL_1_ADMI_SUCC_SA==1
    ...    Step 4. Release the call and lock cell 2, make a new call again.
    ...    Step 5. Blind SCell addition is triggered.
    ...    Expected Results: Cell 12 is added as SCell.
    ...    Step 6. Release the call and unlock Cell 2.
    ...    This TA case also covers the A22:A_B5_Blind scell selection based on different weighted scell bw and cell load
    ...    When fdd weighted cell bw higher than tdd cell.
    ...    After changing the cells's weightForSCellSelection,selection order is in (cell 12+ cell 13) > cell 1 > cell 2 = cell 13 > cell 12.
    ...    Repeat the steps 1-6 again.
    [Tags]    QC_128162    CB008015-A21-A22
    Delta Commission Parameters    ${Limited_maxNumOfSCellAlloc}
    SA UE 85 Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    SA UE 83 Attach At FDD Cell-11 And TDD Scell 1 Blind Addition
    SA UE 81 Attach At FDD Cell-11 And TDD Scell 2 Blind Addition
    SA UE 81 Attach At FDD Cell-11 And FDD Scell 12 Blind Addition
    Release Ues    ue_type=all
    Delta Commission Parameters    ${FddCellWeightHigherThantddCell}
    Case Repetive Steps

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    ${UE81}    catenate
    ...    set_ue simulated id=81 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nia=null+snow3g+aes+zuc nea=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645481 enb=2 cell=11 mode=nr
    ${UE83}    catenate
    ...    set_ue simulated id=83 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645483 enb=2 cell=11 mode=nr
    ${UE85}    catenate
    ...    set_ue simulated id=85 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F
    ...    nea=null+snow3g+aes+zuc nia=null+snow3g+aes+zuc sec_key=0102030405060708090A0B0C0D0EFF00
    ...    suci=0:311:489:0000:0:0:021645485 enb=2 cell=11 mode=nr
    Update Cfg    ${UE81}
    Update Cfg    ${UE83}
    Update Cfg    ${UE85}
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}
    Update Cfg    ue_param id=83 ue_nr_capabilities=${Capa_FT2CC}
    Update Cfg    ue_param id=85 ue_nr_capabilities=${Capa_FDD3}

SA UE 85 Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    [Arguments]    ${ue_id}=85
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Trigger Pdu Session And Check UE 85 Blind Addition Result
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100
    Verify Throughput    ue_id=${ue_id}

Trigger Pdu Session And Check UE 85 Blind Addition Result
    [Arguments]    ${ue_id}=85
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1
    ...    pass_regexp=${expect_value}    fail_regexp=SCellIndex 3 activated successfully at airphone   timeout=20s

SA UE 83 Attach At FDD Cell-11 And TDD Scell 1 Blind Addition
    [Arguments]    ${ue_id}=83
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Trigger Pdu Session And Check UE 83 Blind Addition Result
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100
    Verify Throughput    ue_id=${ue_id}

Trigger Pdu Session And Check UE 83 Blind Addition Result
    [Arguments]    ${ue_id}=83
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    physCellId 50
    Should Not Contain    ${ret1}    SCellIndex 2
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone

SA UE 81 Attach At FDD Cell-11 And TDD Scell 2 Blind Addition
    [Arguments]    ${ue_id}=81
    Clear Counter Files
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Trigger Pdu Session And Check UE 81 Blind Addition Result
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100
    Verify Throughput
    Release Ues    ue_type=sa    ue_id=${ue_id}
    Check Counters    ${Counters_Check_CB008015_A21_UE81}

Trigger Pdu Session And Check UE 81 Blind Addition Result
    [Arguments]    ${ue_id}=81
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    physCellId 51
    Should Not Contain    ${ret1}    SCellIndex 2
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone

SA UE 81 Attach At FDD Cell-11 And FDD Scell 12 Blind Addition
    [Arguments]    ${ue_id}=81
    Delta Commission Parameters    ${cell2_lock}
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=11
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    Trigger Pdu Session And Check UE 81 Blind Addition Result Again
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=100
    Verify Throughput    Tput_dl=50    Tput_ul=9
    Delta Commission Parameters    ${cell2_unlock}

Trigger Pdu Session And Check UE 81 Blind Addition Result Again
    [Arguments]    ${ue_id}=81
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    activated successfully at airphone
    Should Contain    ${ret1}    sCellToAddModList
    Should Contain    ${ret1}    physCellId 61
    Should Not Contain    ${ret1}    SCellIndex 2
    Should Contain    ${ret1}    SCellIndex 1 activated successfully at airphone

Case Repetive Steps
    SA UE 85 Attach At FDD Cell-11 And FDD Scell 12 And 13 Blind Addition
    SA UE 83 Attach At FDD Cell-11 And TDD Scell 1 Blind Addition
    SA UE 81 Attach At FDD Cell-11 And TDD Scell 2 Blind Addition
    SA UE 81 Attach At FDD Cell-11 And FDD Scell 12 Blind Addition
    Release Ues    ue_type=all

Verify Throughput
    [Documentation]    verify Tput in scell is not 0
    [Arguments]    ${Tput_dl}=140    ${Tput_ul}=9    ${sleep_time}=15s    ${ue_id}=81
    sleep    ${sleep_time}    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    ${scell_tput}    Execute Egate Command    ue_stats_nr id=${ue_id} scell=0-7 type=pdsch    Throughput
    Should Not Match Regexp    ${scell_tput}    CellIndex-.*Mbps.*Mbps.*Mbps.* 0 Mbps
    Should Be True    ${dl_throughput}/1000>${Tput_dl}
    Should Be True    ${ul_throughput}/1000>${Tput_ul}
