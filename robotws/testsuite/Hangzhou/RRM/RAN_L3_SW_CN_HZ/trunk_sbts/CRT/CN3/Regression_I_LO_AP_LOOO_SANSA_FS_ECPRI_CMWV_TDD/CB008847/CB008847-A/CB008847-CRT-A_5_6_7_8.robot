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
...    maxNumPucchF1SRPerSlotL1Pool=2    maxNumPucchF3PCSIPerSlotL1Pool=1

@{PARAMS_IN_SCF}    @{CB008847}    @{multi_drb_NSA}    @{5GC000704}    @{5GC00572}    @{emergency_enable}    @{NRDRB}
...    @{uplink_share_related_params}    @{beamforming}    @{NRREL}    @{HO_inter_frequency}
...    ${actFdmEnhancedScheduling}    ${reestablish_SA_enable}    @{simGNB}

@{PARAMS_IN_SWCONFIG}
...    ${rdNewTddCellSlotModel}
...    ${rdTddPoolingFeaturesEnable}
${rdTddPoolingFeaturesEnable}    0x420068=2
${rdNewTddCellSlotModel}    0x420062=1

@{CB008847}
...    NRBTS:actBbPoolTddFr1=true
...    NRCELL:maxNumOfUsersPerNRCell=20    NRCELL:maxNumOfCaUsersNRCell=20
...    NRCELL:maxNumOfUsersPerCell=20    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:srPeriodicity=slots80    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:maxNumOfNrDcSnUsers=20
...    NRBTS:actBbPoolExtensionTddFr1=true

${actFdmEnhancedScheduling}    NRBTS-2:actFdmEnhancedScheduling=true

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

@{NRREL}
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-1/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-1/NRREL-10:gNbId=2
...    NRCELL-1/NRREL-10:gNbIdLength=22
...    NRCELL-1/NRREL-10:lcrId=2
...    NRCELL-1/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-10:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-10:gNbId=2
...    NRCELL-2/NRREL-10:gNbIdLength=22
...    NRCELL-2/NRREL-10:lcrId=3
...    NRCELL-2/NRREL-10:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-10:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-10:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=36
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3

@{HO_inter_frequency}
...    NRBTS:actInterFreqHoSA=true
...    NRCELL:a2MeashoEnabledSA=rsrp
...    NRCELL:a1MeashoEnabledSA=rsrp
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresishoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2HysteresisHoSsbRsrpVoNr=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdhoSsbRsrpSA=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2ThresholdHoSsbRsrpVoNr=0|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a2MeashoSsbRsrpSA:a2TimeToTriggerhoSsbRsrpSA=ms480|a2TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresishoSsbRsrpSA=0|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1HysteresisHoSsbRsrpVoNr=0|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdhoSsbRsrpSA=60|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1ThresholdHoSsbRsrpVoNr=60|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL:a1MeashoSsbRsrpSA:a1TimeToTriggerhoSsbRsrpSA=ms480|a1TimeToTriggerHoSsbRsrpVoNr=ms480
...    NRCELL-2/NRHOIF-1:a3MeasEnabled=rsrp
...    NRCELL-2/NRHOIF-1:cellDepType=SA
...    NRCELL-2/NRHOIF-1:freqBandIndicatorNR=78
...    NRCELL-2/NRHOIF-1:ifhoSsbScs=30 KHz
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcDuration=sf5
...    NRCELL-2/NRHOIF-1:ifhoSsbSmtcPeriodicity=sf20
...    NRCELL-2/NRHOIF-1:ssBurstSetPeriod=20
...    NRCELL-2/NRHOIF-1:ssbFrequency=643296
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3TimeToTriggerSsbRsrp=ms480
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0
...    NRCELL-2/NRHOIF-1:a3MeasSsbRsrp:a3OffsetSsbRsrp=3
...    NRCELL-2:measGapSelectionSA=balancedChoice
...    NRCELL:ifhoSsbSmtcOffset=0

@{simGNB}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=1
...    NRADJGNB-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJGNB-1:gnbPlmn:mnc=489|mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:gNbId=36
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=633366
...    NRADJNRCELL-1:physCellId=381
...    NRADJNRCELL-1:gnbPlmn:mcc=311|mncLength=3
...    NRADJNRCELL-1:gnbPlmn:mnc=489|mncLength=3

@{uplink_share_related_params}
...    NRCELL:actInfTddFrameMuting=false
...    NRCELL:infTddFrameStructure:infTddFrameMutingBiAgreement=true
...    NRCELL:tddFrameStructure:frameStructureType=semiStatic
...    NRCELL:tddFrameStructure:ulDlDataSlotRatio=1/4

@{beamforming}
...    NRCELL:actBeamforming=true    NRBTS:actChannelMapVal=Disabled
...    NRCELL:beamSet:nrBtsBeamRefinementP2=true    NRCELL-2:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL:actPerCsiReportBundlingTddFr1=false
...    NRCELL:numberOfRxBeamforming=4Rx

${reestablish_SA_enable}    NRBTS-2:rrcReestabTypeSA=sameGNB

@{change_params_for_caseA5}
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams    NRCELL-1:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=1 beam    NRCELL-2:beamSet:basicBeamSet=beamSet_1
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=1 beam    NRCELL-3:beamSet:basicBeamSet=beamSet_1
...    NRCELL-2:actPerCsiReportBundlingTddFr1=true

@{restore_params_for_caseA5}
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=true    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=1 beam    NRCELL-1:beamSet:basicBeamSet=beamSet_1
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-2:actPerCsiReportBundlingTddFr1=false

@{change_params_for_caseA7}    NRCELL:numOfRadioResReservForEmergency=2    NRCELL-1:numOfRadioResReservForEmergency=4
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=4
...    NRCELL:actPerCsiReportBundlingTddFr1=true

@{restore_params_for_caseA7}    NRCELL:numOfRadioResReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=2
...    NRCELL:actPerCsiReportBundlingTddFr1=false

@{change_params_for_caseA8}
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-1:srPeriodicity=slots40    NRCELL-2:srPeriodicity=slots40
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=1 beam    NRCELL-2:beamSet:basicBeamSet=beamSet_1
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=1 beam    NRCELL-3:beamSet:basicBeamSet=beamSet_1
...    NRCELL-3:actPerCsiReportBundlingTddFr1=true

@{restore_params_for_caseA8}
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots80
...    NRCELL-1:srPeriodicity=slots80    NRCELL-2:srPeriodicity=slots80
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=true
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams    NRCELL-2:beamSet:basicBeamSet=beamSet_2
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams    NRCELL-3:beamSet:basicBeamSet=beamSet_2
...    NRCELL-3:actPerCsiReportBundlingTddFr1=false
...    ${cell3_unlock}

${cell3_lock}    NRCELL-3:administrativeState=Locked
${cell3_unlock}    NRCELL-3:administrativeState=Unlocked

@{PM_Counters_Check_A5}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=2
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2

@{PM_Counters_Check_A6}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=2
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=2
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=2
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2

@{PM_Counters_Check_A7}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=3
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=3
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=2
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=2
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=3
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=3

@{PM_Counters_Check_A8}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}=1

${SGNB_SA_DU_RAC_REJ_DUE_PUCCH}    M55139C00010
${SA_DU_RAC_FAIL_BBPOOL_NR_PCSI}    M55139C03504

*** Test Cases ***
CB008847-A_ET_06_01_Hit the L1 CSI PUCCH emergency capacity of TDD L1 pool when Bundling false
    [Documentation]
    ...    CSI resource: total:64 share:0 gurantee:cell1 16 cell2 8 cell3 8  emergency:cell1 16 cell2 8 cell3 8
    ...    maxNumOfPCSIPerNonCAUE: cell1 2  cell2 2  cell3 2
	[Tags]
    [Teardown]    Common Test Teardown And Stop To Capture Logs On CaseA6
    Clear Counter files
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=2
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=2
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=2    ue_id_end_before=3
    Register For Normal Call Fail Due To RAC Failure    cell_id=2    ue_id=3
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=3    ue_id_end_before=4
    reestablish UE to target cell fail    ue_id=2
    Register For Number Of Emergency Calls    cell_id=2    ue_id_start=4    ue_id_end_before=9
    Register For Emergency Call Fail Due To RAC Failure on CELL1 CELL2 CELL3    ue_id=9

CB008847-A_ET_07_01_Hit the L1 CSI PUCCH emergency capacity of TDD L1 pool when Bundling true
    [Documentation]
    ...    CSI resource: total:64 share:0 gurantee:cell1 8 cell2 4 cell3 4  emergency:cell1 32 cell2 8 cell3 8
    ...    maxNumOfPCSIPerNonCAUE: cell1 2  cell2 1  cell3 1
	[Tags]
    [Setup]    Common Test Setup And Start To Capture Logs On CaseA7
    [Teardown]    Common Test Teardown And Stop To Capture Logs On CaseA7
    Register For Normal Call on CELL1 Fail after no available CSI resource
    Register For Normal Call on CELL2 Fail after no available CSI resource
    UE HO To Target Cell Successfully From Cell2 To Cell3    ue_id=2
    Register For Normal Call Fail Due To RAC Failure    cell_id=3    ue_id=3
    Register For Number Of Emergency Calls    cell_id=1    ue_id_start=3    ue_id_end_before=9
    UE PDU Session Setup    ue_id=3    gw_id=3
    Register For Emergency Call Fail Due To RAC Failure on CELL1 CELL3
    UE HO To Target Cell Successfully From Cell1 To Cell2    ue_id=3
    Register For Number Of Emergency Calls    cell_id=2    ue_id_start=9    ue_id_end_before=11
    Register For Emergency Call Fail Due To RAC Failure on CELL1 CELL2 CELL3    ue_id=11

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
    ...    gnb_param id=3 xn_listening_socket=1 send_xn_setup=false
    ${cfg_cmd_4}    catenate
    ...    set_cell id=1 gnb=3 pci=127:0 tac=200 nrci=0x01 tdd_cell=on proxy=10.0.2.92:9999 nr_arfcn=633366:633366 gscn=7846
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

Register For Emergency Call Fail Due To RAC Failure
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

Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END

UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command  ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command  ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg    reported successful RA

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id}    UE now in NG RM Reg

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    Should Contain  ${ret1}  Created FiveQi:Qfi mapping fiveQi 5 qfi 1

UE HO To Target Cell Successfully From Cell2 To Cell3
    [Arguments]    ${ue_id}
    ${ret}    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=50 srsrq_nr=30
    ...    rrcReconfigurationComplete
	Should Contain    ${ret}    eventId eventA3
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=52 nrsrp_nr=70 nrsrq_nr=30
    ...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.3 performed    timeout=5

UE HO To Target Cell Successfully From Cell1 To Cell2
    [Arguments]    ${ue_id}
    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=51 nrsrp_nr=70 nrsrq_nr=30
    ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed    timeout=5

reestablish UE to target cell fail
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=3    fail

wait all cell has sib Message
    Wait Until Keyword Succeeds    5min    2s    check cell has sib Message    cell_id=1
    Wait Until Keyword Succeeds    5min    2s    check cell has sib Message    cell_id=2
    Wait Until Keyword Succeeds    5min    2s    check cell has sib Message    cell_id=3
    sleep    15s    #make sure cell works normally

check cell has sib Message
    [Arguments]    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    Should Match Regexp    ${ret}    SIB1.*?yes

Common Test Setup And Start To Capture Logs On CaseA5
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${change_params_for_caseA5}
    cells should be onair
    Clear Counter files

Common Test Teardown And Stop To Capture Logs On CaseA5
	Check Counters    ${PM_Counters_Check_A5}
    Delta Commission Parameters    ${restore_params_for_caseA5}
    cells should be onair
#    wait all cell has sib Message
    Deregister UEs    ue_id_start=1    ue_id_end_before=11
    Common Test Teardown And Stop Capture Logs

Common Test Setup And Start To Capture Logs On CaseA7
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${change_params_for_caseA7}
    cells should be onair
    Clear Counter files

Common Test Teardown And Stop To Capture Logs On CaseA7
    Check Counters    ${PM_Counters_Check_A7}
    Delta Commission Parameters    ${restore_params_for_caseA7}
    cells should be onair
#    wait all cell has sib Message
    Deregister UEs    ue_id_start=1    ue_id_end_before=11
    Common Test Teardown And Stop Capture Logs

Common Test Teardown And Stop To Capture Logs On CaseA6
	Check Counters    ${PM_Counters_Check_A6}
    Deregister UEs    ue_id_start=3    ue_id_end_before=10
    Deregister UEs    ue_id_start=1    ue_id_end_before=2
    Deregister UEs    ue_id_start=2    ue_id_end_before=3    #deregister 2 after all other UEs deregistered to avoid AP crash
    Common Test Teardown And Stop Capture Logs

Common Test Setup And Start To Capture Logs On CaseA8
    Common Test Setup And Start To Capture Logs
    Delta Commission Parameters    ${change_params_for_caseA8}
    cells should be onair
    Clear Counter files

Common Test Teardown And Stop To Capture Logs On CaseA8
    Check Counters    ${PM_Counters_Check_A8}
    Delta Commission Parameters    ${restore_params_for_caseA8}
    cells should be onair
#    wait all cell has sib Message
    Deregister UEs    ue_id_start=1    ue_id_end_before=10
    Common Test Teardown And Stop Capture Logs

Ue Ho To simulated gNB
    [Arguments]    ${ue_id}
    Initial IntraFreA3 Ho    phycell_id=381    ue_id=${ue_id}

Initial IntraFreA3 Ho
    [Arguments]    ${phycell_id}    ${ue_id}
    ${ret1}=     Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=30
    ...    pass_regexp=PATH_SWITCH_REQUEST_ACK Received
    should contain    ${ret1}    Inter-eNB handover from EXT_ENB-2.2 to ENB-3.1 performed

Ue Ho Back real gNB
    [Arguments]    ${ue_id}    ${pci}
    Initial IntraFreA3 Ho CFRA    phycell_id=${pci}    ue_id=${ue_id}

Initial IntraFreA3 Ho CFRA
    [Arguments]    ${phycell_id}    ${ue_id}
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=4 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${phycell_id} nrsrp_nr=70 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command    ${cmd}    pass_regexp=NgLink::SendPathSwitchRequestAck
    should contain    ${ret1}    Inter-eNB handover from ENB-3.1 to EXT_ENB-2.3 performed

Ue Ho Back real gNB Fail Due To RAC Failure
    [Arguments]    ${ue_id}    ${pci}
    ${cmd}    catenate
    ...    ue_measurement_send_nr id=${ue_id} meas_id=2 event=A3 srsrp_nr=11 srsrq_nr=11 phycell_id=${pci} nrsrp_nr=70 nrsrq_nr=30
    ...    rs_type=ssb index=0 nrs_result=30:30:30
    ${ret1}=     Execute Egate Command    ${cmd}    fail_regexp=no-radio

Register For 1 Normal Calls on CELL1 CELL2 CELL3
	Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=2
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=2    ue_id_end_before=3
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=3    ue_id_end_before=4

Register For Emergency Call Fail Due To RAC Failure on CELL1 CELL2 CELL3
    [Arguments]    ${ue_id}
    Register For Emergency Call Fail Due To RAC Failure    ue_id=${ue_id}    cell_id=1
    Register For Emergency Call Fail Due To RAC Failure    ue_id=${ue_id}    cell_id=2
    Register For Emergency Call Fail Due To RAC Failure    ue_id=${ue_id}    cell_id=3

Register For Emergency Call Fail Due To RAC Failure on CELL1 CELL3
    Register For Emergency Call Fail Due To RAC Failure    ue_id=9    cell_id=1
    Register For Emergency Call Fail Due To RAC Failure    ue_id=9    cell_id=3

Register For Normal Call on CELL1 Fail after no available CSI resource
	Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=31    ue_id_end_before=32
    Register For Normal Call Fail Due To RAC Failure    cell_id=1    ue_id=2

Register For Normal Call on CELL2 Fail after no available CSI resource
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=2    ue_id_end_before=3
    UE PDU Session Setup    ue_id=2    gw_id=2
    Register For Normal Call Fail Due To RAC Failure    cell_id=2    ue_id=3
