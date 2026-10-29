*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Restore Env
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-qi.zheng    release-SBTS23R1
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/3cells_ecpri_4pipes
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20
...    maxNumOfDRBL2Pool=40
...    maxNumOfGBRL2Pool=20
...    guaranteedResourceRatioPerCell=10
...    maxNumPucchF1SRPerSlotL1Pool=70
...    maxNumPucchF3PCSIPerSlotL1Pool=30
@{PARAMS_IN_SWCONFIG}
...    ${rdNewTddCellSlotModel}
...    ${rdTddPoolingFeaturesEnable}
${rdTddPoolingFeaturesEnable}
...    0x420068=2
${rdNewTddCellSlotModel}
...    0x420062=1
${BBbPoolSkipChecks_disable}    
...    0x60000C=1
@{PARAMS_IN_SCF}
...    @{CB008847}
...    @{5GC000704}
...    @{CA}
...    @{NRREL}
...    ${reestablish_SA_enable}
...    @{NRDRB}
@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRCELL:maxNumOfUsersPerCell=20    
...    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL:srPeriodicity=slots80
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false|emergencyCallPlmnHoAllowed=false
...    NRCELL:maxNumOfNrDcSnUsers=20

...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRCELL:actBeamforming=true
...    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-1:numberOfRxBeamforming=4Rx
...    NRCELL-2:numberOfRxBeamforming=4Rx
...    NRCELL-3:numberOfRxBeamforming=4Rx
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams
...    NRCELL:actCsirsMultiplexing=true
@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL-1:a3MeasEnabled=rsrp
...    NRCELL-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL-1:filterCoeffSsbRsrp=fc4
...    NRCELL-1:absThreshSsbRsrpConsolidation=80
...    NRCELL-1:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL:actVoNR=true
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfCaUsersNRCell=20
...    NRBTS:drbInactivityTimerSA=6000
@{NRDRB}
...    MRBTS/NRBTS/NRDRB_RLC_UM-1     
...    NRDRB_MAC-3:lcgid=4
...    NRDRB_MAC-2:lcgid=7
...    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    MRBTS/NRBTS/NRDRB-15:dlFlowControlAlgo=none    
...    MRBTS/NRBTS/NRDRB-15:resType=GBR
...    MRBTS/NRBTS/NRDRB-15:maxDataRateGbrDl=1000
...    MRBTS/NRBTS/NRDRB-15:maxDataRateGbrUl=1000
...    MRBTS/NRBTS/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS/NRBTS/NRDRB-15:rlcMode=RLC_UM
...    MRBTS/NRBTS/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS/NRBTS/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    MRBTS/NRBTS/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1    
...    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15
${reestablish_SA_enable}
...    NRBTS:rrcReestabTypeSA=sameGNB
${cell3_lock}
...    NRCELL-3:administrativeState=Locked
${cell3_unlock}
...    NRCELL-3:administrativeState=Unlocked
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
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=2
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=1
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL:actK1Opt=intra-gNB
@{NRCELL1_NRREL1_sCellAdditionMethod_covBasedA1}
...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
@{NRCELL1_NRREL1_sCellAdditionMethod_deleted}
...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod
@{PM_Counters_Check_B3}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
@{PM_Counters_Check_B4}
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
@{PM_Counters_Check_B7}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0
@{PM_Counters_Check_B6}
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0
${SA_DU_RAC_FAIL_BBPOOL_NR_USER}
...    M55139C03502
${SGNB_SA_DU_RAC_REJ_DUE_RRC}
...    M55139C00013
${wait_UE_deregister_finish}    1s
${wait_securmodecompl_not_received}    1s

*** Test Cases ***
CB008847-B_ET_07_01_The NR User number for TDD L2 pool check for CA users when Reestablishment
    [Documentation]
    ...    precondition:
    ...    Cell-1 as PCell is covBasedA1 CA relation for cell-3
    ...           maxNumOfUserL2Pool: 20
    ...           Guaranteed L2 NR User number per cell: 2
    ...           Emergency resource (NR User Number) per cell: 1
    ...           Shared resource (NR User Number): 11
    ...    step1: EXPECT: register 12 UEs on cell1 pass
    ...    step2: EXPECT: register 1 UE on cell3 pass
    ...    step3: EXPECT: register normal UE-14 on cell1 with A1 CA cell3 pass
    ...    step4: EXPECT: reestablish the UE-14 on cell1 fail
    ...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER, SGNB_SA_DU_RAC_REJ_DUE_RRC value increase 1 on cell1
    ...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER, SGNB_SA_DU_RAC_REJ_DUE_RRC value no change on cell3
    ...    step5: EXPECT: register normal UE-15 on cell1 with A1 CA cell3 pass
    ...    step6: EXPECT: reestablish the UE-15 to cell2, reestablish succeed
	[Tags]
    [Setup]    Common Test Setup And Start To Capture Logs On Case7
    [Teardown]    Common Test Setup And Stop To Capture Logs On Case7
    Register For Number Of Normal Calls  cell_id=1    ue_id_start=1    ue_id_end_before=13
    Register For Number Of Normal Calls  cell_id=3    ue_id_start=13    ue_id_end_before=14
    Register And Set up PDU For Normal Call with report A1 scell added Successfully    ue_id=14    cell_id=1
    Clear Counter files
    reestablish UE to serving cell fail    ue_id=14
    Check Counters    ${PM_Counters_Check_B7}
    Register And Set up PDU For Normal Call with report A1 scell added Successfully    ue_id=15    cell_id=1
    reestablish UE to target cell2 succeed    ue_id=15

CB008847-B_ET_06_01_The NR User number for TDD L2 pool check for CA users Scell addition
    [Documentation]
    ...    precondition:
    ...           maxNumOfUserL2Pool: 20
    ...           Guaranteed L2 NR User number per cell: 2
    ...           Shared resource (NR User Number): 14
    ...    step1: EXPECT: register 15 normal UEs on cell1 pass
    ...    step2: EXPECT: UE14 send A1 report to add one scell successfully
    ...    step3: EXPECT: UE15 send A1 report to add one scell successfully
    ...    step4: EXPECT: register normal UE16 and add scell for cell3 RAC fail
	...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER value increase 1 on cell3
    ...                   counter SGNB_SA_DU_RAC_REJ_DUE_RRC value no change on cell3
    ...    step5: EXPECT: UE14 report A2 to release scell
	...    step6: EXPECT: UE16 send A1 report to add one scell successfully
	...    step7: EXPECT: UE16 handover to cell2 successfully
	...    step8: EXPECT: register UE-17 on cell1 pass
	...    step9: EXPECT: UE17 send A1 report to add one scell successfully
	[Tags]
    [Setup]    Common Test Setup And Start To Capture Logs On Case6
    [Teardown]    Common Test Setup And Stop To Capture Logs On Case6
    Register For Number Of Normal Calls  cell_id=1    ue_id_start=1    ue_id_end_before=16
    UE14 UE15 report A1 to add scell Successfully
    UE16 CA to add scell3 should RAC fail
    UE report A2 to release scell    ue_id=14
    UE report A1 to add scell Successfully    ue_id=16
    UE HO To Target Cell2 Successfully    ue_id=16
    Register And Set up PDU For Normal Call Successfully    ue_id=17    cell_id=1
    UE report A1 to add scell Successfully    ue_id=17

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}
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

Common Test Teardown And Restore Env
    Delta Commission Parameters    ${cell3_unlock}
    wait cell has sib Message    cell_id=3
    Deregister UEs    ue_id_start=1    ue_id_end_before=25
    Common Test Teardown And Stop Capture Logs

Deregister UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    None
        sleep    ${wait_UE_deregister_finish}
    END
    wait all UE deregistered

Modify QOSflow
    [Arguments]    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}    None
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}    None

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}    None

Register For Emergency Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
  Modify UE Establishemnt Cause    ${ue_id}    emergency
  UE Register To GNB    ${ue_id}

Register For Number Of Emergency Calls
  [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
  Modify QOSflow    priority=1
  FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Emergency Call Successfully    ${ue_id}    ${cell_id}
  END

Register And Set up PDU For Emergency Call Fail Due To RAC Failure
  [Arguments]    ${ue_id}    ${cell_id}
  Modify UE Establishemnt Cause    ${ue_id}    emergency
  UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

UE Register To GNB Due To RAC Failure
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
  ${res}    Execute Egate Command  ue_register id=${ue_id}    detached
  Should Contain  ${res}    rrcReject

Register For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
  Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
  UE Register To GNB    ${ue_id}

Register And Set up PDU For Normal Call Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  Execute Egate Command  ue_change_location id=${ue_id} cell=${cell_id}    None
  Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
  UE Register To GNB    ${ue_id}
  sleep    ${wait_securmodecompl_not_received}    #wait for a while due to sometimes SecurityModeComplete not received and result in UE release
  UE PDU Session Setup    ${ue_id}    ${ue_id}

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
  Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE HO To Target Cell2 Successfully
  [Arguments]    ${ue_id}
  ${ret1}=  Execute Egate Command
  ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=51 nrsrp_nr=70 nrsrq_nr=30
  ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

wait cell has sib Message
    [Arguments]    ${cell_id}
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=${cell_id}

check cell has sib Message
    [Arguments]    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    Should Match Regexp    ${ret}    SIB1.*?yes

Register For 7 Normal Calls on cell1 and 8 Normal Calls on cell2
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=8
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=8    ue_id_end_before=16

UE Register To GNB for 1 Normal Call on cell1 to cell2 Due To RAC Failure
    Modify QOSflow    priority=15
    Modify UE Establishemnt Cause    ue_id=16    cause=mo-Signalling
    UE Register To GNB Due To RAC Failure    cell_id=1    ue_id=16
    UE Register To GNB Due To RAC Failure    cell_id=2    ue_id=16

Register For 6 Normal UEs on cell1 and 2 Normal UEs on cell2
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=7
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=7    ue_id_end_before=9

reestablish UE to serving cell fail
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1    fail
    Execute Egate Command    ue_disp state=ACTIVE    2.1

reestablish UE to target cell2 succeed
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=2    Reestablishment sucessfully completed
    Execute Egate Command    ue_disp state=ACTIVE    2.2

Register And Set up PDU For Normal Call with report A1 scell added Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [Return]    ${ret}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    QoS Routing Table
    UE report A1 to add scell Successfully    ${ue_id}

Common Test Setup And Start To Capture Logs On Case6
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    NRCELL:actEmergencyCall=false
    Delta Commission Parameters    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1
    cells should be onair

Common Test Setup And Stop To Capture Logs On Case6
    Delta Commission Parameters    NRCELL:actEmergencyCall=true
    Delta Commission Parameters    delete:NRCELL-1/NRREL-1:sCellAdditionMethod
    Deregister UEs    ue_id_start=1    ue_id_end_before=18
    Common Test Teardown And Stop Capture Logs

Common Test Setup And Start To Capture Logs On Case7
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${NRCELL1_NRREL1_sCellAdditionMethod_covBasedA1}
    cells should be onair

Common Test Setup And Stop To Capture Logs On Case7
    Delta Commission Parameters    ${NRCELL1_NRREL1_sCellAdditionMethod_deleted}
    Deregister UEs    ue_id_start=1    ue_id_end_before=16
    Common Test Teardown And Stop Capture Logs

UE report A1 to add scell Successfully
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    sCellToAddModList

UE16 CA to add scell3 should RAC fail
    Register And Set up PDU For Normal Call Successfully    ue_id=16    cell_id=1
    Clear Counter files
    UE report A1 to add scell fail    ue_id=16
    Check Counters    ${PM_Counters_Check_B6}

UE report A1 to add scell fail
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    fail_regexp=sCellToAddModList    timeout=5s

UE report A2 to release scell
    [Arguments]    ${ue_id}    ${scell_index}=1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 scell=${scell_index} scell_rsrp=40 scell_rsrq=0 event=A2
    ...    sCellToReleaseList

wait all UE deregistered
    wait until keyword succeeds    2min    10s    check no UE active

check no UE active
    Execute Egate Command    ue_disp   fail_regexp=ACTIVE    timeout=5

UE14 UE15 report A1 to add scell Successfully
    UE PDU Session Setup    ue_id=14    gw_id=14
    UE PDU Session Setup    ue_id=15    gw_id=15
    UE report A1 to add scell Successfully    ue_id=14
    sleep    ${wait_securmodecompl_not_received}    #wait for a while due to sometimes SecurityModeComplete not received and result in UE release
    UE report A1 to add scell Successfully    ue_id=15
