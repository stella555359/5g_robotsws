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
...    NRCELL-11/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-1:lcrId=1
...    NRCELL-11/NRREL-1:gNbIdLength=22
...    NRCELL-11/NRREL-1:removeNotAllowed=false
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-10:gNbId=1
...    NRCELL-11/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-10:lcrId=2
...    NRCELL-11/NRREL-10:gNbIdLength=22
...    NRCELL-11/NRREL-10:removeNotAllowed=false
...    NRCELL-11/NRREL-3:gNbId=1
...    NRCELL-11/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-11/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-11/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-11/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-11/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-11/NRREL-3:lcrId=12
...    NRCELL-11/NRREL-3:gNbIdLength=22
...    NRCELL-11/NRREL-3:removeNotAllowed=false
...    NRCELL-11/NRREL-2:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-11/NRREL-2:gNbId=1
...    NRCELL-11/NRREL-2:sCellAdditionMethod=covBasedA1
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
...    NRCELL-12/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-2:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-2:lcrId=11
...    NRCELL-12/NRREL-2:gNbIdLength=22
...    NRCELL-12/NRREL-2:removeNotAllowed=false
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-3:gNbId=1
...    NRCELL-12/NRREL-3:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-3:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-3:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-3:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-3:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-3:lcrId=13
...    NRCELL-12/NRREL-3:gNbIdLength=22
...    NRCELL-12/NRREL-3:removeNotAllowed=false
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-10:gNbId=1
...    NRCELL-12/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-12/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-12/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-12/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-12/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-12/NRREL-10:lcrId=2
...    NRCELL-12/NRREL-10:gNbIdLength=22
...    NRCELL-12/NRREL-10:removeNotAllowed=false
...    NRCELL-12/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-12/NRREL-1:gNbId=1
...    NRCELL-12/NRREL-1:sCellAdditionMethod=covBasedA1
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

${cell1_lock}    NRCELL-1:administrativeState=Locked
${cell2_lock}    NRCELL-2:administrativeState=Locked
${cell1_unlock}    NRCELL-1:administrativeState=Unlocked
${cell2_unlock}    NRCELL-2:administrativeState=Unlocked

@{PARAMS_TO_MODIFY_8015_A30}
...    NRCELL-11:a1MeasSCellAddEnabled=rsrpAndRsrq
...    NRCELL-11:weightForSCellSelection=20
...    NRCELL-12:weightForSCellSelection=30
...    NRCELL-13:weightForSCellSelection=50
...    NRCELL-1:weightForSCellSelection=40
...    NRCELL-2:weightForSCellSelection=90

&{CELLS_CARRIER_FREQ}
...    1=518910
...    2=633216
...    11=424090
...    12=126750
...    13=427970

*** Test Cases ***
CB008015-ET-A05_A_B3_A1 scell selection based on diff scell BW when pcell report diff rsrp in scope of a1RsrpFDD and a1RsrpTDD
    [Documentation]
    ...    1. The purpose of this test case is to verify US CB008015-A_B3: SCell selection based on SCell bandwidth for SA call
    ...    Mixed mode of FDD-FR1 TDD CA and FDD-FDD CA
    ...    2. Test Case Steps:
    ...    a.Make SA UE-81 attach to C12,start L3 CALL ,A1 measurement report based SCelladdition is triggered,
    ...    rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD,check scell added Cell1, F+T CA
    ...    b.release scell, release UE , and lock Cell1, Loop STEP a : check scell added with Cell2 ,F+T CA
    ...    c.release scell, release UE , and lock Cell2, Loop STEP a : check scell added with Cell11 and Cell13 ,F+F+F CA
    ...    d. release scell, release UE , and unlock all cells , make SA ue attach to Cell12 , A1 measurement report based
    ...    Scelladdition , rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD but lower than a1ThresholdSCellAddSsbRsrpTDD
    ...    : check scell added with C11 and C13 ,F+F+F CA
    ...    e. release scell and release ue , recovery testline
    [Tags]    QC_128158    CB008015-A05
    [Timeout]    2 hours
    SA UE 81 covBasedA1 At FDD Cell-12
    Delta Commission Parameters    ${cell1_lock}
    SA UE 81 covBasedA1 At FDD Cell-12 again
    Delta Commission Parameters    ${cell2_lock}
    SA UE 81 covBasedA1 At FDD Cell-12 third
    Delta Commission Parameters    ${cell1_unlock}
    Delta Commission Parameters    ${cell2_unlock}
    SA UE 81 covBasedA1 At FDD Cell-12 forth

CB008015-ET-A30_A_B4_A1 scell selection based on different weighted scell bandwidth when a1MeasSCellAddEnabled as rsrpAndrsrq
    [Documentation]
    ...    1. The purpose of this test case is to check following scenarios:
    ...    US CB008015-A_B4: SCell selection based on weighted SCell bandwidth for SA call - mixed Mode of FDD-FR1 TDD CA and
    ...    FDD-FDD CA.
    ...    2. Test Case Steps:
    ...    Step 1: Make SA UE-1 attach to cell 11
    ...    Expected Result: SA call setup successfully
    ...    Step 2: check A1 meas config in RRC Reconfig
    ...    Expected Result: SA UE-1 configure A1 measurement for SCell addition with threshold for FDD
    ...    Step 3: A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD
    ...    for SA UE-1
    ...    Expected Result: SA UE-1 will add cell2 for FDD-FR1 TDD 2CC CA.
    ...    Step 4: Release the call and lock cell 2, make a new call again with PDU session for data transferring.
    ...    Expected Result: SA call setup successfully
    ...    Step 5: A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpTDD
    ...    for SA UE-1
    ...    Expected Result: SA UE-1 will add cell1 for FDD-FR1 TDD 2CC CA.
    ...    Step 6: Release the call and unlock cell 1 and cell 2.
    ...    Expected Result: release successfully.
    ...    Step 7: All cells are unlocked.make a new call again with PDU session for data transferring.
    ...    Expected Result: SA call setup successfully
    ...    Step 8: check A1 meas config in RRC Reconfig
    ...    Expected Result: SA UE-1 configure A1 measurement for SCell addition with threshold for FDD.
    ...    Step 9: A1 measurement report based SCell addition is triggered, rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD
    ...    but lower than a1ThresholdSCellAddSsbRsrpTDD, rsrq value higher than a1ThresholdSCellAddSsbRsrq for SA UE-1
    ...    Expected Result: SA UE-1 will add cell 12 and cell 13 for FDD-FDD 3CC CA.
    ...    Step 10: A2 scell Release trigger
    ...    Expected Result: scell release successfully.
    ...    Step 11: check A1 meas config in RRC Reconfig
    ...    Expected Result: SA UE-1 configure A1 measurement for SCell addition with threshold for FDD.
    ...    Step 12: A1 measurement report based SCell addition is triggered, rsrq value lower than a1ThresholdSCellAddSsbRsrq,
    ...    rsrp value higher than a1ThresholdSCellAddSsbRsrpFDD, but lower than a1ThresholdSCellAddSsbRsrpTDD for
    ...    SA UE-1.
    ...    Expected Result: SA UE-1 will add cell 12 and cell 13 for FDD-FDD 3CC CA.
    ...    Step 13: A2 scell Release trigger
    ...    Expected Result: scell release successfully.
    ...    Step 14: release the call for SA UE-1
    ...    Expected Result: ue release successfully
    [Tags]    QC_128166    CB008015-A30
    [Timeout]    2 hours
    Delta Commission Parameters    ${PARAMS_TO_MODIFY_8015_A30}
    Scell_2 Added Based On Rsrp Higher Than TDD Threshold
    ...    rrc_log_tag=A030
    Scell_1 Added Based On Rsrp Higher Than TDD Threshold And Cell2 Locked
    ...    rrc_log_tag=A030_scell_1
    Scell_12_13 Added Based On Rsrp Higher Than FDD But Lower Than TDD And Rsrq Higher Than Rsrq Threshold
    ...    rrc_log_tag=AC002_scell_12_13_Rsrp_highFdd_lowTDD_Rsrq_highThreshold
    Scell_12_13 Added Based On Rsrp Higher Than FDD but Lower Than TDD And Rsrq Lower Than Rsrq Threshold
    ...    rrc_log_tag=AC002_scell_12_13_Rsrp_highFdd_lowTDD_Rsrq_lowThreshold

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_2T4F

Modify Cfg
    Update Cfg    ue_param id=81 ue_nr_capabilities=${SA_Capa_perUE_Full}

SA UE L3 Call At FDD Cell-12
    [Arguments]    ${ue_id}=81
    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=12
    Execute Egate Command    ue_register id=${ue_id}    NG RM Registered
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=1 trf_type=internal    sleep_time=5
    ${ret1}=    Execute Egate Command
    ...    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=1    Initial Context Setup Successful
    Check Traffic

Check Traffic
    [Arguments]    ${ue_id}=81
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=dl mbps=70
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=1 qfi=1 dir=ul mbps=10
    sleep    10s    sleep for Tput stable
    ${dl_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=dl    rate_type=ave
    ${ul_throughput}    Ap Get SA Throughput    ue_id=${ue_id}    pdu=1    qfi=1    direction=ul    rate_type=ave
    Should Be True    ${dl_throughput}/1000>63
    Should Be True    ${ul_throughput}/1000>9.5

SA UE 81 covBasedA1 At FDD Cell-12
    [Arguments]    ${ue_id}=81
    SA UE L3 Call At FDD Cell-12
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=112 srsrq_nr=0    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 50
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
    Release Ues    ue_type=sa    ue_id=${ue_id}

SA UE 81 covBasedA1 At FDD Cell-12 again
    [Arguments]    ${ue_id}=81
    SA UE L3 Call At FDD Cell-12
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=112 srsrq_nr=0    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 51
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
    Release Ues    ue_type=sa    ue_id=${ue_id}

SA UE 81 covBasedA1 At FDD Cell-12 third
    [Arguments]    ${ue_id}=81
    SA UE L3 Call At FDD Cell-12
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=112 srsrq_nr=0    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 60
    Should Contain    ${ret1}    physCellId 62
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 scell=2 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
    Release Ues    ue_type=sa    ue_id=${ue_id}

SA UE 81 covBasedA1 At FDD Cell-12 forth
    [Arguments]    ${ue_id}=81
    SA UE L3 Call At FDD Cell-12
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=81 srsrq_nr=0    activated successfully at airphone
    Should Contain    ${ret1}    physCellId 60
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A2 scell=1 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 scell=2 scell_rsrp=20 scell_rsrq=20
    ...    pass_regexp=sCellToReleaseList
    Release Ues    ue_type=sa    ue_id=${ue_id}

Scell_2 Added Based On Rsrp Higher Than TDD Threshold
    [Arguments]    ${rrc_log_tag}
    Start RRC Log    ${rrc_log_tag}
    UE Attach and Start L3 Call
    Triggered Scell Addition By A1 Event    scell_num=1
    Check Scell Number    expected_scell_num=1
    Release Scell    2
    UE Detach
    Check RRC log    ${CURDIR}${/}a2a_${rrc_log_tag}${/}a2a.ini

Scell_1 Added Based On Rsrp Higher Than TDD Threshold And Cell2 Locked
    [Arguments]    ${rrc_log_tag}
    UE Attach and Start L3 Call
    Lock Cell2
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    scell_num=1
    Check Scell Number    expected_scell_num=1
    Rrc Should Contain    sCellToAddModList    physCellId 50
    Unlock Cell2
    Release Scell    1
    UE Detach

Scell_12_13 Added Based On Rsrp Higher Than FDD But Lower Than TDD And Rsrq Higher Than Rsrq Threshold
    [Arguments]    ${rrc_log_tag}
    UE Attach and Start L3 Call
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    rsrp=90    rsrq=120    scell_num=2
    Check Scell Number    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62
    Release Scell    12    13
    UE Detach

Scell_12_13 Added Based On Rsrp Higher than FDD But Lower Than TDD And Rsrq Lower Than Rsrq Threshold
    [Arguments]    ${rrc_log_tag}
    UE Attach and Start L3 Call
    Start RRC Log    ${rrc_log_tag}
    Triggered Scell Addition by A1 Event    rsrp=90    rsrq=20    scell_num=2
    Check Scell Number    expected_scell_num=2
    Rrc Should Contain    sCellToAddModList    physCellId 61    physCellId 62
    Release Scell    12    13
    UE Detach

UE Attach and Start L3 Call
    [Arguments]    ${ue_id}=81    ${pdu_gw_id}=1    ${cell}=11
    ${ret}    Execute Egate Command    ue_change_location id=${ue_id} enb=2 cell=${cell}    location
    Should Contain Any    ${ret}    location updated    already there
    Execute Egate Command    qosflow_modify qos_flow=1 default=on
    Execute Egate Command    ue_register id=${ue_id}     pass_regexp=Received REGISTRATION COMPLETE
    Execute Egate Command    set_pdu_param ue=${ue_id} pdu=${pdu_gw_id} trf_type=internal
    Execute Egate Command    ue_pdu_session_setup pdu=${pdu_gw_id} ue=${ue_id} nwslice=1 gw=${pdu_gw_id}
    ...    pass_regexp=QoS Routing Table
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} dir=dl mbps=5
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic
    Execute Egate Command    trf_data_start ue=${ue_id} pdu=${pdu_gw_id} dir=ul mbps=5
    ...    pass_regexp=UE${ue_id}: Started Uplink Internal traffic

Lock Cell${number}
    Delta Commission Parameters    NRCELL-${number}:administrativeState=Locked
    Cell Should Be Locked    ${number}

Triggered Scell Addition By A1 Event
    [Arguments]    ${ue_id}=81    ${rsrp}=120    ${rsrq}=110    ${scell_num}=2
    ${pcell_carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    11
    ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${pcell_carrier_freq}    A1
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=${rsrp} srsrq_nr=${rsrq}
    ...    pass_regexp=SCellIndex ${scell_num} activated successfully

Check Scell Number
    [Arguments]    ${ue_id}=81    ${expected_scell_num}=1
    ${meas_obj}    Execute Egate Command    ue_meas_cfg_disp id=${ue_id} meas_obj_type=nr
    ...    fail_regexp=no NR MEASUREMENT IDENTITIES
    ${meas_data}    Parse Nr Ue Meas Cfg    ${meas_obj}
    ${meas_obj_num}    Get Length    ${meas_data['nr_measurment_objects']}
    ${real_scell_num}    Evaluate    ${meas_obj_num}-1
    Should Be Equal As Integers    ${expected_scell_num}    ${real_scell_num}

Release Scell
    [Arguments]    @{scell_list}    ${ue_id}=81
    ${scell_index}    set variable    1
    FOR    ${scell}    IN    @{scell_list}
        ${carrier_freq}    Get From Dictionary    ${CELLS_CARRIER_FREQ}    ${scell}
        ${meas_id}    Get Nr Meas Id For Specific Type And Frequency    ${ue_id}    ${carrier_freq}    A2
        ${release_cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2
        ...    scell=${scell_index} scell_rsrp=20 scell_rsrq=20
        Execute Egate Command    ${release_cmd}    pass_regexp=sCellToReleaseList
        ${scell_index}    evaluate    ${scell_index}+1
    END

UE Detach
   [Arguments]    ${ue_id}=81
   Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off
   ...    pass_regexp=UE${ue_id}: detached



