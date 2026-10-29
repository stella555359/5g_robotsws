*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1    owner-lishuo.geng    release-SBTS22R2
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    fdd_sansa_cmwv/6cells
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=40    maxNumOfDRBL2Pool=80    maxNumOfGBRL2Pool=20    guaranteedResourceRatioPerCell=10
...    maxNumPucchF1SRPerSlotL1Pool=1    maxNumPucchF3PCSIPerSlotL1Pool=1

@{PARAMS_IN_SWCONFIG}
...    ${CB007015_disable}
...    ${ActL2CellSlotModelExtension_disable}
...    ${BBbPoolSkipChecks_disable}

${CB007015_disable}    0x4F030E=1
${ActL2CellSlotModelExtension_disable}    0x60000B=1
${BBbPoolSkipChecks_disable}    0x60000C=1

@{PARAMS_IN_SCF}    @{5GC002426}    @{5GC000704}    @{CA}    @{5GC00572}    @{NRREL}    @{HO_to_intra_gNB}    @{multi_drb_NSA}    @{NRDRB}
@{5GC002426}
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    EQM-1/APEQM-1/CABINET-1/BBMOD-1:fddNrCellConfigTradeoff=max cells
...    NRCELL:maxNumOfUsersPerCell=20    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots40    NRCELL:srPeriodicity=slots20
...    NRCELL:reqMinNumPuschPrb=13    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false|emergencyCallPlmnHoAllowed=false
...    NRCELL-1:numOfRadioResReservForEmergency=1    NRCELL-2:numOfRadioResReservForEmergency=1
...    NRCELL-3:numOfRadioResReservForEmergency=0    NRCELL-4:numOfRadioResReservForEmergency=0
...    NRCELL-5:numOfRadioResReservForEmergency=0    NRCELL-6:numOfRadioResReservForEmergency=0
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL:actVoNR=true
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL-6:srPeriodicity=slots80
...    NRCELL:maxNumOfNrDcSnUsers=20
@{NRDRB}
...    MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1     NRDRB_MAC-2:lcgid=7    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    MRBTS-2/NRBTS-2/NRDRB-15:dlFlowControlAlgo=none    MRBTS-2/NRBTS-2/NRDRB-15:resType=GBR
...    MRBTS-2/NRBTS-2/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-2/NRBTS-2/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
...    NRBTS-2/NRDRB_MAC-3:schedulBSD=100ms    NRBTS-2/NRDRB_MAC-3:lcgid=4
...    MRBTS-2/NRBTS-2/NRDRB-15:discardTimer=1500ms
...    MRBTS-2/NRBTS-2/NRDRB-15:maxDataRateGbrDl=1000
...    MRBTS-2/NRBTS-2/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS-2/NRBTS-2/NRDRB-15:maxRlcQueueingDelayGbr=20
...    MRBTS-2/NRBTS-2/NRDRB-15:maxTransferDelayGbr=20
@{multi_drb_NSA}    NRBTS:actMultiDrbNSA=true

@{5GC000704}

...  NRBTS:actConflictConfiguration=true
...  NRBTS:actIntraFreqHoSA=true
...  NRBTS:timerXnDataFwdGuard=250
...  NRCELL-1:a3MeasEnabled=rsrp
...  NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...  NRCELL-1:filterCoeffSsbRsrp=fc4
...  NRCELL-1:absThreshSsbRsrpConsolidation=80
...  NRCELL-1:sMeasConfigSsbRsrp=20
...  NRBTS:actIncXn=true
...  NRBTS:cipherPrefL:nea0=9|nea3_128=0

@{5GC00572}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd
...    NRBTS/NRDU-1:actInterNumerologyCa=false
...    NRBTS:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS:actMeasBasedSCellAdditionNsa=true
...    NRBTS:actHoOptimizationCa=true
...    NRBTS:sCellActivationMethod=bufferBased
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations,accept unknown BCSs
...    NRCELL:a1MeasPCellSwitchEnabled=rsrp
...    NRCELL:a2MeasPCellSwitchEnabled=rsrp
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a1MeasPCellSwitchSsbRsrp:a1ThresholdPCellSwitchSsbRsrp=60
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2TimeToTriggerPCellSwitchSsbRsrp=480ms
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2HysteresisPCellSwitchSsbRsrp=0
...    NRCELL:a2MeasPCellSwitchSsbRsrp:a2ThresholdPCellSwitchSsbRsrp=40
...    NRCELL:a2MeasPCellSwitchSsbRsrp:pCellSwitchOffsetSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=3
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
@{HO_to_intra_gNB}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL-1:a2MeashoEnabledSA=rsrp
...    NRCELL-1:a1MeashoEnabledSA=rsrp
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-1/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-1/NRHOIF-1:cellDepType=SA
...    NRCELL-1/NRHOIF-1:freqBandIndicatorNR=66
...    NRCELL-1/NRHOIF-1:ifhoSsbScs=15KHz
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-1/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-1/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-1/NRHOIF-1:ssbFrequency=424090
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-1/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-1:measGapSelectionSA=balancedChoice


@{PM_Counters_Check_A16}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=0
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=0
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=0
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1

${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}    M55139C00010
${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}    M55139C03504
${SA_DU_RAC_FAIL_BBPOOL_NR_SR}    M55139C03505
${NSA_DU_RAC_FAIL_BBPOOL_NR_SR}    M55115C02504
${SGNB_DU_NSA_ADMISSION_UNSUCC}    M55115C00004
${SGNB_DU_NSA_ADMISSION_NO_PUCCH}    M55115C00005

@{PM_Counters_Check_A2}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-3:${NSA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-4:${NSA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-5:${NSA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-6:${NSA_DU_RAC_FAIL_BBPOOL_NR_SR}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISSION_UNSUCC}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISSION_UNSUCC}=0
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-4:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-5:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-6:${SGNB_DU_NSA_ADMISSION_UNSUCC}=0
...    NRCELL-1:${SGNB_DU_NSA_ADMISSION_NO_PUCCH}=0
...    NRCELL-2:${SGNB_DU_NSA_ADMISSION_NO_PUCCH}=0
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_NO_PUCCH}=1
...    NRCELL-4:${SGNB_DU_NSA_ADMISSION_NO_PUCCH}=1
...    NRCELL-5:${SGNB_DU_NSA_ADMISSION_NO_PUCCH}=1
...    NRCELL-6:${SGNB_DU_NSA_ADMISSION_NO_PUCCH}=0
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0
...    NRCELL-4:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0
...    NRCELL-5:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0
...    NRCELL-6:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0

*** Test Cases ***
5GC002426-A_ET_02_01_Hit the L1 SR PUCCH capacity of FDD L1 pool when Cells with different srPeriodicity
    [Documentation]
	...    step1: 9 normal UEs occupied SR resource in cell1: 9*8=72, 2 normal UEs occupied SR resource in cell2-cell5: 2*8*4=64
    ...    step2: 2 normal UEs occupied SR resource in cell6: 2*2=4
	...    step2: normal UE addition fail due to SR RAC failure from cell1-cell5
	...    step3: 2 normal UEs occupied SR resource in cell6: 2*2=4
	...    step4: release 1 normal UE on cell1, free shareable SR resource is: 8
	...    step5: 4 normal UEs occupied SR resource in cell6: 2*4=8
    [Tags]
    Occupied The Guranteed Resource And Shareable Resource Of Cells1 To Cells5
    Occupied Some of Guranteed Resource Of Cell6
    SR RAC Fail On Cell1 To Cell5 Due To No Shareable Resource
	Occupied All Guranteed Resource Of Cell6
    Release Some Shareable Resource From Cell1
	Occupied The Free Shareable Resource On Cell6
    Check Counters    ${PM_Counters_Check_A2}

5GC002426-A_ET_16_01_No normal L1 CSI and SR PUCCH capacity of FDD L1 pool when Emergency UE HO
    [Documentation]
	...    step1: 9 normal UEs occupied SR resource in cell1: 9*8=72, 2 normal UEs occupied SR resource in cell2: 2*8=16
	...           2 normal UEs occupied SR resource in cell3: 2*8=16
	...    step2: normal UE addition fail due to SR RAC failure from cell1-cell3
	...    step3: 1 emergency UEs occupied SR resource in cell1: 8
	...    step4: emergency UE HO To Cell3 Fail Due To SR RAC Failure on cell3
	...    step5: emergency UE HO to cell2 success
    [Tags]
    Register For 9 Normal Calls on cell1 2 Normal Calls on cell2 2 Normal Calls on Cell3
    Clear Counter files
    UE Register To GNB cell1 cell2 cell3 fail Due To RAC Failure
    Emergency UE Register And PDU Session Setup Successfully With Two PDU Session Created At The Same Time  cell_id=1    ue_id=16
    UE HO To Target Cell3 Fail Due To RAC Failure_8698_change    cell_id=3    ue_id=16
    #UE HO To Target Cell Successfully    cell_id=2    ue_id=16
    Check Counters    ${PM_Counters_Check_A16}




*** Keywords ***
Common Suite Setup And Setup IPHY Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${GNB1_CONFIG}
	Set UE Parameters Before Register

Set UE Parameters Before Register
    Execute Egate Command    enb_x2_link_up enb=1 target=2    None

Modify Cfg
	Set Bear in WTS
    Set PDU Session in WTS
	Set Sim gNB
    Update Cfg    cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-69,-34,14,48
    Update Cfg    cell_testmode_set_nr cell_id=all gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate


Set Sim gNB
    ${cfg_cmd_1}    catenate
    ...    set_gnb id=3 type=simulated plmn=311:489 s1u=10.0.1.124 ng=10.0.1.123
    ...    gnb_id=0x24:22 daemon=10.0.2.1:22222 x2=10.0.1.126:36422 x2_peers=none xn=10.0.1.122 nssai=0x1:0xd143a5 amf=1
    ${cfg_cmd_2}    catenate
    ...    gnb_param id=3 x2_listening_socket=1 measEvent=A3
    ${cfg_cmd_3}    catenate
    ...    gnb_param id=3 xn_listening_socket=1 send_xn_setup=true
    ${cfg_cmd_4}    catenate
    ...    set_cell id=1 gnb=3 pci=16:0 tac=788 nrci=0x01 tdd_cell=off proxy=10.0.2.92:9999 nr_arfcn=135580:126380 gscn=1579
    Update Cfg    ${cfg_cmd_1}
    Update Cfg    ${cfg_cmd_2}
    Update Cfg    ${cfg_cmd_3}
    Update Cfg    ${cfg_cmd_4}

Set Bear in WTS
    ${cfg_cmd_3}    catenate
	...    ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
    FOR    ${ue_id}    IN RANGE    32    56
        Update Cfg    set_bearer id=2 ue=${ue_id} qci=9 pdn=1 ip=4.7.254.2${ue_id} default=on ${cfg_cmd_3}
        Update Cfg    set_bearer id=3 ue=${ue_id} qci=8 default=off
    END

Set PDU Session in WTS
    ${cfg_cmd}    catenate
	...    qos_flows=3,2,1 qos_rules=1,2 ue=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
	Update Cfg    set_qosflow id=1 5qi=5 default=on
    Update Cfg    set_qosflow id=3 5qi=6 default=off
    Update Cfg    set_qosflow id=2 5qi=1
    Update Cfg    qosrule_set id=1 proto=tcp qos_flow=1
    Update Cfg    qosrule_set id=2 proto=udp qos_flow=2
    Update Cfg    set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ${cfg_cmd}
    FOR    ${ue_id}    IN RANGE    2    31
        Update Cfg    set_pdu_gateway id=${ue_id} ue_nat_ip=72.23.0.${ue_id} dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1
	END

Modify QOSflow
    [Arguments]    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}    None
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}    None

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}

UE Register To GNB Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    ${res}    Execute Egate Command    ue_register id=${ue_id}    detached
    Should Contain  ${res}    rrcReject

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}

Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    Modify QOSflow    priority=15
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    END

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Registere


UE HO To Target Cell3 Fail Due To RAC Failure_8698_change
    [Arguments]    ${ue_id}    ${cell_id}
    ${ret}    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=50 srsrq_nr=30
    ...    rrcReconfigurationComplete
	Should Contain    ${ret}    eventId eventA3
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=52 nrsrp_nr=70 nrsrq_nr=30
    ...    pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed    timeout=5

UE HO To Target Cell Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    ${ret1}=  Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=6 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=51 nrsrp_nr=70 nrsrq_nr=30
    ...    rrcReconfigurationComplete
    Should Contain    ${ret1}    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Register For 9 Normal Calls on cell1 2 Normal Calls on cell2 2 Normal Calls on Cell3
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=10
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=10    ue_id_end_before=12
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=12    ue_id_end_before=14

UE Register To GNB cell1 cell2 cell3 fail Due To RAC Failure
    UE Register To GNB Due To RAC Failure    cell_id=1    ue_id=14
    UE Register To GNB Due To RAC Failure    cell_id=2    ue_id=14
    UE Register To GNB Due To RAC Failure    cell_id=3    ue_id=14

Occupied The Guranteed Resource And Shareable Resource Of Cells1 To Cells5
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=10
    Attach And Set ENDC For Number Of Normal Calls    cell_id=2    ue_id_start=31    ue_id_end_before=33
    Emergency UE Register And PDU Session Setup Successfully With Two PDU Session Created At The Same Time
	...    cell_id=3    ue_id=12
	Emergency UE Register And PDU Session Setup Successfully With Two PDU Session Created At The Same Time
	...    cell_id=3    ue_id=13
    Attach And Set ENDC For Number Of Normal Calls    cell_id=4    ue_id_start=33    ue_id_end_before=35
    Attach And Set ENDC For Number Of Normal Calls    cell_id=5    ue_id_start=35    ue_id_end_before=37

Register For Normal Call Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

Occupied Some of Guranteed Resource Of Cell6
    VONR UE Register And PDU Session Setup Successfully With Two PDU Session Created At The Same Time
    ...    cell_id=6    ue_id=18
    Register For Normal Call Successfully    cell_id=6    ue_id=14

SR RAC Fail On Cell1 To Cell5 Due To No Shareable Resource
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=15
    Register For Normal Call Fail Due To RAC Failure    cell_id=2    ue_id=15
    UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=3    ue_id=41
    UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=4    ue_id=41
    UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=5    ue_id=41

Occupied All Guranteed Resource Of Cell6
    Register For Normal Call Successfully    cell_id=6    ue_id=15
    UE Attach To ENB And Set ENDC    cell_id=6    ue_id=37

Release Some Shareable Resource From Cell1
    Execute Egate Command    ue_deregister id=1 ue_deregister_type=switch_off    detached

Occupied The Free Shareable Resource On Cell6
    Register For Normal Call Successfully    cell_id=6    ue_id=16
    Register For Normal Call Successfully    cell_id=6    ue_id=17
    UE Attach To ENB And Set ENDC    cell_id=6    ue_id=38
    UE Attach To ENB And Set ENDC    cell_id=6    ue_id=39

VONR UE Register And PDU Session Setup Successfully With Two PDU Session Created At The Same Time
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    Execute Egate Command    ue_nr_capabilities id=${ue_id} voice_over_nr=on:on:off    None
    Execute Egate Command    ue_param id=${ue_id} nr_usage_setting=voice_centric    None
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    Modify QOSflow    priority=15
    UE Register To GNB    ${ue_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2    None
    ${ret1}=  Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}  QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 1 qfi 2

Emergency UE Register And PDU Session Setup Successfully With Two PDU Session Created At The Same Time
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    emergency
    Modify QOSflow    priority=1
    UE Register To GNB    ${ue_id}
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=2    None
    ${ret1}=  Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}  QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 1 qfi 2

Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1        UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    no-radio-resources-available
    Execute Egate Command    ue_detach id=${ue_id}    detached

UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA
