*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     case Teardown
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-lixia.zhou    release-SBTS23R1
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri_4pipes
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=30    maxNumOfDRBL2Pool=40    maxNumOfGBRL2Pool=20    guaranteedResourceRatioPerCell=10
...    maxNumPucchF1SRPerSlotL1Pool=2    maxNumPucchF3PCSIPerSlotL1Pool=2
@{PARAMS_IN_SWCONFIG}
...    ${SR_LOAD_HYSTERISIS_FACTOR}    ${RAD_SR_RECONFIGURATION_INTERVAL}
...    ${rdNewTddCellSlotModel}
...    ${rdTddPoolingFeaturesEnable}
${rdTddPoolingFeaturesEnable}    0x420068=2
${rdNewTddCellSlotModel}    0x420062=1

${SR_LOAD_HYSTERISIS_FACTOR}    0x59015E=300  #s
${RAD_SR_RECONFIGURATION_INTERVAL}    0x59015C=300000
@{PARAMS_IN_SCF}    @{CB008847}    @{5GC000704}    @{5GC00572}    @{emergency_enable}    @{NRDRB}   @{2271}
...    @{uplink_share_related_params}    @{beamforming}    @{CA}    @{NRREL}    ${reestablish_SA_enable}    ${actFdmEnhancedScheduling}

@{CB008847}
...    NRBTS:actConnRrcPooling=true
...    NRBTS:actScheUePooling=true
...    NRBTS:actBbPoolTddFr1=true
...    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL:maxNumOfUsersPerCell=20
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL-1:srPeriodicity=slots160
...    NRCELL-2:srPeriodicity=slots40
...    NRCELL-3:srPeriodicity=slots40
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfNrDcSnUsers=20
...    NRBTS:actBbPoolExtensionTddFr1=true
@{2271}
...    NRCELL:srPeriodicityMin=${EMPTY}
...    NRCELL-1:srPeriodicityMin=slots10
...    NRCELL:adaptiveSrLoadThresholdUp=${EMPTY}
...    NRCELL-1:adaptiveSrLoadThresholdUp=70
...    NRCELL-1:adaptiveSrLoadThresholdDown=50
...    NRCELL:actAdaptiveSr=false
...    NRCELL-1:actAdaptiveSr=true
...    NRCELL-1:adaptiveSrBlockingMinimization=0
...    NRCELL-1:vonrReservation=0

@{5GC00572}
...    NRBTS:actIntraFreqIntraGnbMobilityNSA=true
...    NRBTS:actIntraMeNBMobility=true

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

@{emergency_enable}
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=10
...    NRCELL-1:numOfRadioResReservForEmergency=10
...    NRCELL-2:numOfRadioResReservForEmergency=2
...    NRCELL-3:numOfRadioResReservForEmergency=2
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true

@{NRDRB}
...    MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1     NRDRB_MAC-2:lcgid=7    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    MRBTS-2/NRBTS-2/NRDRB_MAC-3:lcgid=4
...    MRBTS-2/NRBTS-2/NRDRB-15:dlFlowControlAlgo=none    MRBTS-2/NRBTS-2/NRDRB-15:resType=GBR
...    MRBTS-2/NRBTS-2/NRDRB-15:maxDataRateGbrDl=1000    MRBTS-2/NRBTS-2/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS-2/NRBTS-2/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-2/NRBTS-2/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15

@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRBTS/NRDU-1:carrierAggregationSupportList=ca_Fr1Tdd_Sa,ca_Fr1Tdd_Fdd_Sa,ca_Fr1Tdd_Any_Sa
...    NRBTS/NRDU-1:actInterNumerologyCa=true
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
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=60
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0
...    NRCELL:a2MeasSCellRelSsbRsrp:a2TimeToTriggerSCellRelSsbRsrp=2560ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=34
...    NRBTS/NRDU-1:actNonBfAndBfCa=true

${reestablish_SA_enable}    NRBTS-2:rrcReestabTypeSA=sameGNB

@{uplink_share_related_params}
...    NRCELL:actInfTddFrameMuting=false
...    NRCELL:infTddFrameStructure:infTddFrameMutingBiAgreement=false
...    NRCELL:infTddFrameStructure:infFrameStructureType=semiStatic
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:guardPeriodLength=2Symbols
...    NRCELL:tddFrameStructure:tdLteUlDlConfig=tdLteConfig2
...    NRCELL:tddFrameStructure:lteToNrFrameShift=${EMPTY}
...    NRCELL:prachConfigurationIndex=98
...    NRCELL:infTddFrameStructure:infLteToNrFrameShift=${EMPTY}
...    NRCELL:infTddFrameStructure:infTdLteUlDlConfig=tdLteConfig2

${actFdmEnhancedScheduling}    NRBTS-2:actFdmEnhancedScheduling=true

@{beamforming}
...    NRCELL:actBeamforming=false    NRBTS:actChannelMapVal=Disabled
...    NRCELL:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELL:actPerCsiReportBundlingTddFr1=false

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=3
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3/NRREL-10:gNbId=2
...    NRCELL-3/NRREL-10:gNbIdLength=22
...    NRCELL-3/NRREL-10:lcrId=1
...    NRCELL-3/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-10:sCellAdditionMethod=covBasedA1
...    NRCELL:actK1Opt=intra-gNB

@{PM_Counters_Check_A28}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=0
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=0
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=0
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=0
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=0

@{PM_Counters_Check_A30}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=0
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1

${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}    M55139C00010
${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}    M55139C03504
${SA_DU_RAC_FAIL_BBPOOL_NR_SR}    M55139C03505

@{case28}
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=3
...    NRCELL:numOfRadioResReservForEmergency=0
...    NRCELL-2:srPeriodicity=slots20
...    NRCELL-3:srPeriodicity=slots20
...    NRCELL:actEmergencyCall=false

*** Test Cases ***
CB008847-A_ET_30_01_Emergency UE pre RAC with normal type
    [Documentation]
    ...    precondition:
    ...           srPeriodicity per cell: 160   40   40
    ...           adaptiveSrLoadThresholdUp: 65
    ...           Shared resource (SR):64-(10+8+8)=38
    ...           Guaranteed L2 NR User number per cell: 2  8  8
    ...           Emergency resource (NR User Number) per cell: 10  8  8
    ...    step1: register UE1 to cell1 and use the srPeriodicityMin slots10
    ...    step2: register emergency UE2 to cell1, PoolSR load((16+8+8)/64*100=50) is lower than adaptiveSrLoadThresholdUp
    ...           try slots10, (16+16)+8+8>38 pre RAC fail;
    ...           try slots20, (16+8)+8+8>38 pre RAC fail;
    ...           try slots40, (16+4)+8+8<38 succeed;
    ...    step3: register emergency UE3 to cell1, PoolSR load(20+8+8)/64*100 is lower than adaptiveSrLoadThresholdUp
    ...           try slots40, (20+4)+8+8>38 pre RAC fail;
    ...           try slots80, (20+2)+8+8=38 succeed
    ...    step4: register normal UE4 to cell1, pre RAC fail because emergency UE use normal resource
    ...    step5: register emergency to cell1, use emergency resource, pre rac succeed
	[Tags]
    Clear Counter files
    Start RRC Log    emergency_ue_pre_rac
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=2
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=2    ue_id_end_before=3
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=3    ue_id_end_before=4
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=4
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=5    ue_id_end_before=6
    Check RRC log    ${CURDIR}/a2a_case30/emergency_ue_pre_rac.ini
    Check Counters    ${PM_Counters_Check_A30}
    Deregister UEs    ue_id_start=1    ue_id_end_before=6

CB008847-A_ET_28_01_Select SR Pool N for new UE if L1Pool SR load is high with handling unused guaranteed
    [Documentation]
    ...    precondition:
    ...           srPeriodicity per cell: 160   20   20
    ...           adaptiveSrLoadThresholdUp: 65
    ...           Shared resource (SR):64
    ...           Guaranteed L2 NR User number per cell: 2  16  16
    ...           Emergency resource (NR User Number) per cell: 0
    ...    step1: register UE1 to cell1 and use the srPeriodicityMin slots10
    ...           register UE2 to cell1, PoolSR load((16+16+16)/64*100=75) is higher than adaptiveSrLoadThresholdUp, so use PoolN 160
    ...    step2: release UE1
    ...    step3: register UE3-UE6 to cell2, used 32 SR resource
    ...    step4: register UE7 to cell1, PoolSR load((1+32+16)/64*100=76)is higher than adaptiveSrLoadThresholdUp1, souse PoolN 160
	[Tags]
    Delta Commission Parameters    ${case28}
    cells should be onair
    Clear Counter files
    Start RRC Log    select_pool
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3
    Deregister UEs    ue_id_start=1    ue_id_end_before=2
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=3    ue_id_end_before=7
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=7    ue_id_end_before=8
    Check Counters    ${PM_Counters_Check_A28}
    Check RRC log    ${CURDIR}/a2a_case28/select_pool.ini
    Deregister UEs    ue_id_start=1    ue_id_end_before=8

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
    Deregister UEs    ue_id_start=1    ue_id_end_before=21
    Execute Egate Command    ue_detach id=31-60    None
    Common Test Teardown And Stop Capture Logs

Deregister UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    None
    END

Modify QOSflow
    [Arguments]    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}    None
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}    None

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}    None

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

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE PDU Session Modify to Add
    [Arguments]    ${ue_id}=1    ${qos_flow}=2    ${5QI}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qos_flow} by=amf
    ...    pass_regexp=Received Uplink NAS Transport Message with RAN UE NGAP ID
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi ${5QI} qfi 2

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

Register For Normal Call Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

UE Register To GNB Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
    ${res}    Execute Egate Command  ue_register id=${ue_id}    detached
    Should Contain  ${res}    rrcReject
