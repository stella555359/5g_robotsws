*** Settings ***
Suite Setup       Common Suite Setup And Setup IPHY Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     case Teardown
Force Tags        QCD_MN_RAN  QCP_RAN_VRF  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-lishuo.geng    release-SBTS23R1
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${GNB1_CONFIG}    tdd_sansa_cmwv/FS/3cells_ecpri_4pipes
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20    maxNumOfDRBL2Pool=40    maxNumOfGBRL2Pool=20    guaranteedResourceRatioPerCell=5
...    maxNumPucchF1SRPerSlotL1Pool=2    maxNumPucchF3PCSIPerSlotL1Pool=1

@{PARAMS_IN_SCF}    @{CB008847}    @{multi_drb_NSA}    @{5GC000704}    @{5GC00572}    @{emergency_enable}    @{NRDRB}
...    @{beamforming}    @{CA}    @{NRREL}    ${reestablish_SA_enable}    ${actFdmEnhancedScheduling}
@{PARAMS_IN_SWCONFIG}
...    ${rdNewTddCellSlotModel}
...    ${rdTddPoolingFeaturesEnable}
${rdTddPoolingFeaturesEnable}    0x420068=6
${rdNewTddCellSlotModel}    0x420062=1

@{CB008847}
...    MRBTS/EQM-1/APEQM-1/CABINET-1/BBMOD-1:bbmodBoardConfigType=NRFDD_NRTDD
...    MRBTS/NRBTS/NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    MRBTS/NRBTS/NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRBTS:actBbPoolTddFr1=true
...    NRCELL:maxNumOfUsersPerNRCell=20    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL:maxNumOfUsersPerCell=20    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:srPeriodicity=slots160    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:maxNumOfNrDcSnUsers=20
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRBTS:actPucchF3BasedTaGrantsRed=false

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
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=3
...    NRCELL-1:numOfRadioResReservForEmergency=3    NRCELL-3:numOfRadioResReservForEmergency=3
...    NRCELL-2:numOfRadioResReservForEmergency=2
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false
...    NRCELL:emergencyCallRestrictions:emergencyCallPlmnHoAllowed=false
...    NRCELL:actVoNR=true
...    NRCELL:actEmergencyCall=true

@{NRDRB}
...    MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1     NRDRB_MAC-2:lcgid=7    NRDRB_PDCP-2:pdcpBufDiscardEnabled=false
...    MRBTS-2/NRBTS-2/NRDRB_MAC-3:lcgid=4
...    MRBTS-2/NRBTS-2/NRDRB-15:dlFlowControlAlgo=none    MRBTS-2/NRBTS-2/NRDRB-15:resType=GBR
...    MRBTS-2/NRBTS-2/NRDRB-15:maxDataRateGbrDl=1000    MRBTS-2/NRBTS-2/NRDRB-15:maxDataRateGbrUl=1000
#...    MRBTS-2/NRBTS-2/NRDRB-15:queuingDelayDiscarding=Disabled
...    MRBTS-2/NRBTS-2/NRDRB-15:rlcMode=RLC_UM
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbRlcUmDN=MRBTS-2/NRBTS-2/NRDRB_RLC_UM-1
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbPdcpDN=MRBTS-2/NRBTS-2/NRDRB_PDCP-2
...    MRBTS-2/NRBTS-2/NRDRB-15:nrDrbMacDN=MRBTS-2/NRBTS-2/NRDRB_MAC-3
...    NRBTS/NRDRB_5QI-6:fiveqiValueList=1    NRBTS/NRDRB_5QI-6:nrDrbDN=MRBTS-2/NRBTS-2/NRDRB-15

${reestablish_SA_enable}    NRBTS-2:rrcReestabTypeSA=sameGNB

${actFdmEnhancedScheduling}    NRBTS-2:actFdmEnhancedScheduling=true

@{beamforming}
...    NRCELL-1:actBeamforming=true    NRCELL-2:actBeamforming=true    NRCELL-3:actBeamforming=false
...    NRBTS:actChannelMapVal=ShowAsWarning    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false    NRCELL-2:beamSet:nrBtsBeamRefinementP2=true
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELL-1:actPerCsiReportBundlingTddFr1=true    NRCELL-3:actPerCsiReportBundlingTddFr1=false
...    NRCELL-2:actPerCsiReportBundlingTddFr1=true
...    NRCELL-1:numberOfRxBeamforming=4Rx    NRCELL-2:numberOfRxBeamforming=4Rx

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
...    NRCELL-1/NRREL-10:sCellOperationalMode=dlOnly
...    NRCELL-3/NRREL-10:sCellOperationalMode=dlOnly

@{2200}
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-1:periodicCsiAcquisition:csirsPower=0
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
...    NRCELL-1:actCsirsMultiplexing=true
...    NRBTS:actExplicitCsirsPoolSolution=true
#...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
#...    NRCELL-2:beamSet:basicBeamSet=beamSet_2



@{change_params_for_caseA24}
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots160
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=4
...    NRCELL-3:numOfRadioResReservForEmergency=4
...    NRCELL-2:numOfRadioResReservForEmergency=0
...    NRCELL-1:numOfRadioResReservForEmergency=4
...    NRCELL:actEmergencyCall=true
...    NRCELL:actBeamforming=true
...    NRBTS:actChannelMapVal=ShowAsWarning
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam
...    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELL-1:actPerCsiReportBundlingTddFr1=false
...    NRCELL-2:actPerCsiReportBundlingTddFr1=false
...    NRCELL-3:actPerCsiReportBundlingTddFr1=true
...    NRCELL-1/NRREL-10:sCellAdditionMethod=blind

@{restore_params_for_caseA24}
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1/NRREL-10:sCellAdditionMethod=covBasedA1
...    @{beamforming}
...    @{emergency_enable}

${ue_nr_capabilities_maxNumberCSI-RS-Resource_4}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A
...    0810748046D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B8002F800E000BE000280381
...    D06C4DC0D608C21A081074804656C92AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F605F001FD8
...    17C000500702A0D88DAC1184341020F1008CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE
...    0000003F80000000A00E0541B107582308682041E201195B262AC4873EC09F11C78C48E3C873EA39F30C7942C
...    0E070F09FC0AAAAA7F02AAAA81401C00650388C080000240A838280388C000004240AC3C28000C2300008240A
...    C1C4D080006020EB0F13400309A0004010750B882001C41000E230000050907007011A014400080820A90C0D0
...    276C73E1C29D3B639F0E1449DB1CF870226C73E1C2893B639F0E2400D8E7C302C1800060007A0580780050381
...    8070300540700060240040603E090020000000100000200800000004000008020000080100000600800004004
...    00002802001004010040000300200001C0100080000002000020010000120080040300C010000140080000B00
...    4002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D040000259494100
...    00196525040000A594901000039652404000125949010000596524040001A5949010000796524040002259490
...    10000996524040002A5949010000B96525040003259490100003165240314AAAE955552A8BA55154162A81C55
...    068AA531549A2A80C55028AA4D5541E2808BC04A8140A05028140A05028140A05028140A05028140A000A0010
...    1E018202004000080600C101002008040300000080C004101002008040080010080600C02018030080600C354
...    3E00020406080C0E1416181A2022242628303236383A3E424A4C4E5052545A5E82820F0101804

@{PM_Counters_Check_A24}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
@{PM_Counters_Check_A23}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
@{PM_Counters_Check_A21}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=1
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1

${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}    M55139C03504
${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}     M55139C00010
*** Test Cases ***
CB008847-A_ET_24_01_CSI resource is limited with maxNumberCSI-RS-Resource for scell
    [Documentation]
    ...    CSI resource: total:64 share:12 gurantee:cell1 8 cell2 2 cell3 2  emergency:cell1 32 cell2 0 cell3 8
	...    maxNumOfPCSIPerNonCAUE:cell1 2 cell2 1 cell3 1
	...    beam report:cell1 need cell2 need cell3 no need
	...    bundling: cell1 false cell2:true cell3:false
	[Tags]
	[Setup]    Common Test Setup And Start To Capture Logs On CaseA24
	[Teardown]    Common Test Teardown And Stop To Capture Logs On CaseA24
    set UE1to3 maxNumberCSI-RS-Resource as 4
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=2
    UE PDU Session Setup with scell3 added    ue_id=1    gw_id=1
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=2    ue_id_end_before=3
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=3
    Check Counters    ${PM_Counters_Check_A24}
	Deregister UEs    ue_id_start=1    ue_id_end_before=3

CB008847-A_ET_21_01_CSI resource allocation for measurement CA
    [Documentation]
    ...    CSI resource: total:64 share:8 gurantee:cell1 4 cell2 8 cell3 4  emergency:cell1 12 cell2 16 cell3 12
	...    maxNumOfPCSIPerNonCAUE:cell1 1 cell2 1 cell3 1
	...    beam report:cell1 need cell2 need cell3 no need
	...    bundling: cell1 true cell2:true cell3:false
	[Tags]
    Clear Counter files
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3
    UE1 ICS And Add Scell Addition Successfully
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=3
    reestablish UE to target cell3 succeed    ue_id=1
    UE report A1 to add scell Successfully    ue_id=1    meas_id=5    serving_pci=52
    Register For Normal Call Fail Due To RAC Failure    cell_id=3    ue_id=3
    UE report A2 to release scell    ue_id=1    scell_index=1
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=3    ue_id_end_before=5
    Check Counters    ${PM_Counters_Check_A21}
    Deregister UEs    ue_id_start=1    ue_id_end_before=5

CB008847-A_ET_23_01_Keep CSI config If Hit CSI resource Limitation when CSI RS reconfig of 2200 feature
    [Documentation]
    ...    CSI resource: total:64 share:8 gurantee:cell1 4 cell2 8 cell3 4  emergency:cell1 12 cell2 16 cell3 12
	...    maxNumOfPCSIPerNonCAUE:cell1 1 cell2 1 cell3 1
	...    beam report:cell1 need cell2 need cell3 no need
	...    bundling: cell1 true cell2:true cell3:false
	...    cell1: 2200 feature on cell2-cell3:2200 feature off
	[Tags]    QC_47319    TC23
	[Setup]    Common Test Setup And Start To Capture Logs On CaseA23
    Clear Counter files
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3
    UE PDU Session Setup    ue_id=1    gw_id=1
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=4    ue_id_end_before=5
	Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=5
	UE PDU Session Setup    ue_id=2    gw_id=2
    Check Counters    ${PM_Counters_Check_A23}
	Deregister UEs    ue_id_start=1    ue_id_end_before=6

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

Common Test Setup And Start To Capture Logs On CaseA24
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${change_params_for_caseA24}
    cells should be onair
    Clear Counter files

Common Test Teardown And Stop To Capture Logs On CaseA24
    Deregister UEs    ue_id_start=1    ue_id_end_before=3
    Delta Commission Parameters    ${restore_params_for_caseA24}
    Common Test Teardown And Stop Capture Logs

Common Test Setup And Start To Capture Logs On CaseA23
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${2200}
    cells should be onair


Modify QOSflow
    [Arguments]    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority}    None
    Execute Egate Command    qosflow_modify qos_flow=2 priority=${priority}    None

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}    None


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

Deregister UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    None
    END

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


UE report A1 to add scell Successfully
    [Arguments]    ${meas_id}    ${ue_id}    ${serving_pci}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} phycell_id=${serving_pci} event=A1 srsrp_nr=80 srsrq_nr=40
    ...    sCellToAddModList

UE report A2 to release scell
    [Arguments]    ${ue_id}    ${scell_index}=1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=6 scell=${scell_index} scell_rsrp=40 scell_rsrq=0 event=A2
    ...    sCellToReleaseList

reestablish UE to target cell3 succeed
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=3    Reestablishment sucessfully completed
    Execute Egate Command    ue_disp state=ACTIVE    2.3

set UE1to3 maxNumberCSI-RS-Resource as 4
    Execute Egate Command    ue_param id=1-3 ue_nr_capabilities=${ue_nr_capabilities_maxNumberCSI-RS-Resource_4}    None

UE PDU Session Setup with scell3 added
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    physCellId 52
    Should Contain  ${ret1}  sCellToAddModList

UE1 ICS And Add Scell Addition Successfully
	UE PDU Session Setup    ue_id=1    gw_id=1
    UE report A1 to add scell Successfully    ue_id=1    meas_id=2    serving_pci=50

check cell has sib Message
    [Arguments]    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    Should Match Regexp    ${ret}    SIB1.*?yes

wait all cell has sib Message
    Wait Until Keyword Succeeds    5min    10s    check cell has sib Message    cell_id=1
    Wait Until Keyword Succeeds    5min    10s    check cell has sib Message    cell_id=2
    Wait Until Keyword Succeeds    5min    10s    check cell has sib Message    cell_id=3
    sleep    15s    #make sure cell works normally

case Teardown
    Deregister UEs    ue_id_start=1    ue_id_end_before=21
    Execute Egate Command    ue_detach id=31-60    None
    Common Test Teardown And Stop Capture Logs
