*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     case Teardown
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1    owner-lishuo.geng    release-SBTS22R2
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${GNB1_CONFIG}    fdd_sansa_cmwv/6cells
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20    maxNumOfDRBL2Pool=40    maxNumOfGBRL2Pool=20    guaranteedResourceRatioPerCell=10
...    maxNumPucchF1SRPerSlotL1Pool=70    maxNumPucchF3PCSIPerSlotL1Pool=30
@{PARAMS_IN_SWCONFIG}
...    ${CB007015_disable}
...    ${ActL2CellSlotModelExtension_disable}
...    ${BBbPoolSkipChecks_disable}

${CB007015_disable}    0x4F030E=1
${ActL2CellSlotModelExtension_disable}    0x60000B=1
${BBbPoolSkipChecks_disable}    0x60000C=1
@{PARAMS_IN_SCF}    @{5GC002426}    @{5GC000704}    @{CA}    @{5GC00572}    @{NRREL}
...    @{multi_drb_NSA}    @{emergency_enable}    @{NRDRB}    @{HO_inter_frequency}

@{5GC002426}
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    NRCELL:maxNumOfUsersPerNRCell=20    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL:maxNumOfUsersPerCell=20    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:srPeriodicity=slots20    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots20
...    NRCELL:maxNumOfNrDcSnUsers=20

@{multi_drb_NSA}    NRBTS:actMultiDrbNSA=true
@{5GC00572}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true

@{emergency_enable}
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=2
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true

@{change_params_for_case5}
...    NRCELL-5:numOfRadioResReservForEmergency=0    NRCELL-6:numOfRadioResReservForEmergency=0    NRCELL-4:actEmergencyCall=false
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1
@{restore_params_for_case5}
...    NRCELL-5:numOfRadioResReservForEmergency=1    NRCELL-6:numOfRadioResReservForEmergency=1
...    NRCELL-4:actEmergencyCall=true    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1

@{change_params_for_case20}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=blind    NRCELL-1/NRREL-2:sCellAdditionMethod=blind    NRCELL-3/NRREL-10:sCellAdditionMethod=blind

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

${cell6_lock}    NRCELL-6:administrativeState=Locked
${cell6_unlock}    NRCELL-6:administrativeState=Unlocked
@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0

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
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-2:gNbId=2
...    NRCELL-1/NRREL-2:gNbIdLength=22
...    NRCELL-1/NRREL-2:lcrId=4
...    NRCELL-1/NRREL-2:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-2:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-2:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-2:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=2
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=1
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-1/NRREL-2:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fdd_Fdd
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
@{HO_inter_frequency}
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

@{PM_Counters_Check_C3}
...    NRCELL-1:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-1:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-2:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-2:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-3:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-4:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-4:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-5:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-5:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-6:${SGNB_DU_NSA_ADMISSION_UNSUCC}=0
...    NRCELL-6:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=0

@{PM_Counters_Check_C11}
...    NRCELL-1:${SGNB_DU_NSA_ADMISSION_UNSUCC}=2
...    NRCELL-1:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=2
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1

@{PM_Counters_Check_C05}
...    NRCELL-1:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-1:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-3:${SGNB_DU_NSA_ADMISSION_UNSUCC}=1
...    NRCELL-3:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-4:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-4:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-5:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-5:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-6:${SGNB_DU_NSA_ADMISSION_UNSUCC}=0
...    NRCELL-6:${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}=0

${SA_DU_RAC_FAIL_BBPOOL_NR_USER}    M55139C03502
${SGNB_SA_DU_RAC_REJ_DUE_RRC}    M55139C00013
${SGNB_DU_NSA_ADMISSION_UNSUCC}    M55115C00004
${NSA_DU_RAC_FAIL_BBPOOL_NR_USER}    M55115C02501

@{PM_Counters_Check_20}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0


${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}    M55139C00010

*** Test Cases ***
5GC002426-C_ET_20_01_Not enough Normal NR User number for FDD L2 pool for emergency UE with CA when HO
    [Documentation]
	...    step1: occupied NR number resource in cell1: 4, now free shareable resource is: 0
	...    step2: occupied 1 NR number emergency resource,and add two scell of cell3/cell4 for this emergency UE
	...    step3: HO emergency UE to cell3, scell of cell1 addition fail due to no NR number resource on cell1
    [Tags]
    Set Params And Clear Counters For Case20
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=5
	Register And Set up PDU For Number Of Emergency Calls And Check Blind CA    ue_id=5
	UE HO To Target Cell Successfully From Cell1 To Cell3    cell_id=3    ue_id=5
    Check Counters    ${PM_Counters_Check_20}

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

case Teardown
    Delta Commission Parameters    ${cell6_unlock}
	wait cell has sib Message    cell_id=6
    Execute Egate Command    ue_detach id=31-60    None
    Common Test Teardown And Stop Capture Logs
	Delta Commission Parameters    ${restore_params_for_case5}

Modify QOSflow
    [Arguments]    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}    None
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}    None

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}    None

Register And Set up PDU For Emergency Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    emergency
    UE Register To GNB    ${ue_id}
    UE PDU Session Setup    ${ue_id}    ${ue_id}
    UE PDU Session Modify to Add    ${ue_id}

Register And Set up PDU For Number Of Emergency Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    Modify QOSflow    priority=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register And Set up PDU For Emergency Call Successfully    ${ue_id}    ${cell_id}
    END

Register And Set up PDU For Emergency Call Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Modify QOSflow    priority=1
    Modify UE Establishemnt Cause    ${ue_id}    emergency
    UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

Register And Set up PDU For Emergency Call Fail Due To RAC Failure_8698_change
    [Arguments]    ${ue_id}    ${cell_id}
    Modify QOSflow    priority=1
    Modify UE Establishemnt Cause    ${ue_id}    emergency
    UE Register To GNB Due To RAC Failure_8698_change    ${ue_id}    ${cell_id}

Register For Normal Call Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

UE Register To GNB Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
    ${res}    Execute Egate Command  ue_register id=${ue_id}    detached
    Should Contain  ${res}    rrcReject

UE Register To GNB Due To RAC Failure_8698_Change
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
    Execute Egate Command  ue_register id=${ue_id}    UE now in NG RM Register

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}


Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    Modify QOSflow    priority=15
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    END


Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command  ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    reported successful RA

UE Attach To ENB And Set ENDC Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1        UE IS ACTIVE
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg  no-radio-resources-available
    Execute Egate Command    ue_detach id=${ue_id}    detached

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 1 qfi 2



wait cell has sib Message
    [Arguments]    ${cell_id}
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=${cell_id}

check cell has sib Message
    [Arguments]    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    should contain X Times    ${ret}    yes    6


Occupied 2 Gurateed And 2 Shareable And 5 Emergency Resource On Cell1 With Emergency UE
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=1    ue_id_end_before=10

Occupied 2 Gurateed And 1 Emergency Resource On Cell2 With Emergency UE
    Register And Set up PDU For Number Of Emergency Calls    cell_id=2    ue_id_start=10    ue_id_end_before=13

Occupied 2 Gurateed Resource From Cell3 To Cell5 With Emergency UE
    Register And Set up PDU For Number Of Emergency Calls    cell_id=3    ue_id_start=13    ue_id_end_before=15
    Register And Set up PDU For Number Of Emergency Calls    cell_id=4    ue_id_start=15    ue_id_end_before=17
	Register And Set up PDU For Number Of Emergency Calls    cell_id=5    ue_id_start=17    ue_id_end_before=19

Occupied 1 Gurateed Resource On Cell6 With Emergency UE
	Register And Set up PDU For Number Of Emergency Calls    cell_id=6    ue_id_start=19    ue_id_end_before=20

New Normal UE RAC Failure On Cell1 To Cell5
    Modify QOSflow    priority=15
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=1    ue_id=32
	UE Register To GNB Due To RAC Failure    cell_id=1    ue_id=20
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=2    ue_id=32
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=3    ue_id=32
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=4    ue_id=32
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=5    ue_id=32

New Normal UE RAC Succeed On Cell6
    Register For Number Of Normal Calls    cell_id=6    ue_id_start=20    ue_id_end_before=21

Occupied All Gurateed And Shareable Resource From Cell1 To Cell5 With Normal UE
    Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=31    ue_id_end_before=33
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=3    ue_id_end_before=5
	Attach And Set ENDC For Number Of Normal Calls    cell_id=3    ue_id_start=33    ue_id_end_before=35
	Register For Number Of Normal Calls    cell_id=4    ue_id_start=5    ue_id_end_before=7
	Attach And Set ENDC For Number Of Normal Calls    cell_id=5    ue_id_start=35    ue_id_end_before=37

Occupied 6 Emergency Resource On Cell1
	Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=7    ue_id_end_before=13

Normal And Emergency UE RAC Fail On Cell1
	Register And Set up PDU For Emergency Call Fail Due To RAC Failure    cell_id=1    ue_id=13
	Modify QOSflow    priority=15
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=1    ue_id=37

Emergency UE RAC Succeed But Normal UE RAC Fail On Cell1
    UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=1    ue_id=37
	Modify QOSflow    priority=1
	Register And Set up PDU For Emergency Call Successfully    cell_id=1    ue_id=13
    Register And Set up PDU For Emergency Call Successfully    cell_id=1    ue_id=14

Occupied All Gurateed And Shareable Resource On Cell1 With Emergency UE
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=1    ue_id_end_before=8

Occupied All Gurateed Resource On Cell2 With Emergency UE
    Register And Set up PDU For Number Of Emergency Calls    cell_id=2    ue_id_start=8    ue_id_end_before=10

Emergency UE RAC Fail On Cell5_8698_change
    #Register And Set up PDU For Emergency Call Fail Due To RAC Failure    cell_id=5    ue_id=14
    Register And Set up PDU For Emergency Call fail Due To RAC Failure_8698_change    cell_id=5    ue_id=14

Occupied All Gurateed Resource From Cell3 To Cell5 With Normal UE
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=10    ue_id_end_before=12
	Attach And Set ENDC For Number Of Normal Calls    cell_id=4    ue_id_start=31    ue_id_end_before=33
	Attach And Set ENDC For Number Of Normal Calls    cell_id=5    ue_id_start=33    ue_id_end_before=35

Occupied 1 Gurateed Resource On Cell6 With Normal UE
    Register For Number Of Normal Calls    cell_id=6    ue_id_start=12    ue_id_end_before=13

Normal UE RAC Fail From Cell1 To Cell5
    UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=1    ue_id=35
	Register For Normal Call Fail Due To RAC Failure    cell_id=2    ue_id=22
	UE Attach To ENB And Set ENDC Due To RAC Failure    cell_id=3    ue_id=35
	Register For Normal Call Fail Due To RAC Failure    cell_id=4    ue_id=22
	Register For Normal Call Fail Due To RAC Failure    cell_id=5    ue_id=22

Occupied Another Gurateed Resource On Cell6 With Normal UE
    Register For Number Of Normal Calls    cell_id=6    ue_id_start=13    ue_id_end_before=14

Occupied All Emergency Resource From Cell1 To Cell3 With Emergency UE
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=15    ue_id_end_before=16
	Register And Set up PDU For Number Of Emergency Calls    cell_id=2    ue_id_start=16    ue_id_end_before=17
	#Register And Set up PDU For Number Of Emergency Calls    cell_id=3    ue_id_start=17    ue_id_end_before=18

Set Params And Clear Counters For Case5
    Delta Commission Parameters    ${change_params_for_case5}
	Clear Counter files

Set Params And Clear Counters For Case20
    Delta Commission Parameters    ${change_params_for_case20}
    Clear Counter files

UE HO To Target Cell Successfully From Cell1 To Cell3
    [Arguments]    ${ue_id}    ${cell_id}
    ${ret}    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=50 srsrq_nr=30
    ...    rrcReconfigurationComplete
	Should Contain    ${ret}    eventId eventA3
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=5 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=52 nrsrp_nr=70 nrsrq_nr=30
    ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.3 performed    timeout=5


Register And Set up PDU For Number Of Emergency Calls And Check Blind CA
    [Arguments]    ${ue_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=1
	Modify QOSflow    priority=1
    Modify UE Establishemnt Cause    ${ue_id}    emergency
    UE Register To GNB    ${ue_id}
    ${ret1}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    rrc-TransactionIdentifier 3
	Should Contain    ${ret1}    sCellIndex 1
	Should Contain    ${ret1}    physCellId 52
    Should Contain    ${ret1}    sCellIndex 2
    Should Contain    ${ret1}    physCellId 53
    UE PDU Session Modify to Add    ${ue_id}
