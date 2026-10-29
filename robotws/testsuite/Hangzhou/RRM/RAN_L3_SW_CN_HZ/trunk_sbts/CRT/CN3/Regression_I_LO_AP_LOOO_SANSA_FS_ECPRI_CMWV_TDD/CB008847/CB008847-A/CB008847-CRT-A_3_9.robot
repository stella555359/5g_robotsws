*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     case Teardown
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-lishuo.geng    release-SBTS23R1
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri_4pipes
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20    maxNumOfDRBL2Pool=40    maxNumOfGBRL2Pool=20    guaranteedResourceRatioPerCell=5
...    maxNumPucchF1SRPerSlotL1Pool=1    maxNumPucchF3PCSIPerSlotL1Pool=2
@{PARAMS_IN_SWCONFIG}
...    ${rdNewTddCellSlotModel}
...    ${rdTddPoolingFeaturesEnable}
${rdTddPoolingFeaturesEnable}    0x420068=2
${rdNewTddCellSlotModel}    0x420062=1

@{PARAMS_IN_SCF}    @{CB008847}    @{multi_drb_NSA}    @{5GC000704}    @{5GC00572}    @{emergency_enable}    @{NRDRB}
...    @{uplink_share_related_params}

@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true
...    NRCELL:maxNumOfCaUsersNRCell=20    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:maxNumOfUsersPerCell=20    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:srPeriodicity=slots40    NRCELL-3:srPeriodicity=slots80    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:maxNumOfNrDcSnUsers=20
...    NRBTS:actBbPoolExtensionTddFr1=true
@{multi_drb_NSA}    NRBTS:actMultiDrbNSA=true

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
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=2
...    NRCELL:numOfRadioResReservForEmergency=1
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

@{uplink_share_related_params}
...    NRCELL:actInfTddFrameMuting=false
...    NRCELL:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4

@{change_params_for_caseA9}
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-1:srPeriodicity=slots20
...    NRCELL-1:actEmergencyCall=false
...    NRCELL-2:numOfRadioResReservForEmergency=0    NRCELL-3:numOfRadioResReservForEmergency=2
...    ${cell3_lock}

@{restore_params_for_caseA9}
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-1:srPeriodicity=slots40
...    NRCELL-1:actEmergencyCall=true
...    NRCELL-2:numOfRadioResReservForEmergency=1    NRCELL-3:numOfRadioResReservForEmergency=1
...    ${cell3_unlock}

${cell3_lock}    NRCELL-3:administrativeState=Locked
${cell3_unlock}    NRCELL-3:administrativeState=Unlocked

@{PM_Counters_Check_A3}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2

@{PM_Counters_Check_A9}
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_SR}=2
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2

${SA_DU_RAC_FAIL_BBPOOL_NR_SR}    M55139C03505
${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}    M55139C00010


*** Test Cases ***
CB008847-A_ET_03_01_Hit the L1 SR PUCCH capacity of TDD L1 pool with same UL DL ratio and different Uplink share
    [Documentation]
    ...    SR resource: total:32 share:12 gurantee:cell1 4 cell2 4 cell3 2  emergency:cell1 4 cell2 4 cell3 2
	[Tags]
    Clear Counter files
    Register For 2 Normal Calls on CELL1 CELL2 CELL3
    Register For Normal Call Fail Due To RAC Failure on CELL1 CELL2
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=7    ue_id_end_before=8
    Register And Set up PDU For Number Of Emergency Calls    cell_id=1    ue_id_start=8    ue_id_end_before=9
    Register And Set up PDU For Emergency Call Fail Due To Pool Limitation    ue_id=10    cell_id=2
    Register And Set up PDU For Number Of Emergency Calls    cell_id=3    ue_id_start=10    ue_id_end_before=11
	Check Counters    ${PM_Counters_Check_A3}



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
    Deregister UEs    ue_id_start=1    ue_id_end_before=11
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

Register And Set up PDU For Emergency Call Fail Due To Pool Limitation
    [Arguments]    ${ue_id}    ${cell_id}
    Modify QOSflow    priority=1
    Modify UE Establishemnt Cause    ${ue_id}    emergency
    UE Register To GNB Due To RAC Failure    ${ue_id}    ${cell_id}

Register For Normal Call Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${cell_id}
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
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
    Should Match Regexp    ${ret}    SIB1.*?yes

Common Test Setup And Start To Capture Logs On CaseA9
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${change_params_for_caseA9}
    Clear Counter files

Common Test Teardown And Stop To Capture Logs On CaseA9
	Check Counters    ${PM_Counters_Check_A9}
    Deregister UEs    ue_id_start=1    ue_id_end_before=9
    Delta Commission Parameters    ${restore_params_for_caseA9}
    cells should be onair
    Common Test Teardown And Stop Capture Logs

wait all cell has sib Message
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=1
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=2
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=3
    sleep    15s    #make sure cell works normally

Register For 2 Normal Calls on CELL1 CELL2 CELL3
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=3    ue_id_end_before=5
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=5    ue_id_end_before=7

Register For Normal Call Fail Due To RAC Failure on CELL1 CELL2
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=7
    Register For Normal Call Fail Due To RAC Failure    cell_id=2    ue_id=7