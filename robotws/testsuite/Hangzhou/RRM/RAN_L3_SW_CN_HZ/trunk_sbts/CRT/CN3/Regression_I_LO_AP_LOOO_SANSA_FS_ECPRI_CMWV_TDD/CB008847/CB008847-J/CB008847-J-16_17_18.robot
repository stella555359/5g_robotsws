*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     case_teardown
Force Tags        QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    CRT    CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
...               team-DevHZ5_SG1    owner-lixia.zhou    release-SBTS23R1
Resource          ../../../../../../resources/DevHZ5_resource.robot

*** Variables ***
${TL_TYPE_PATH}    tdd_sansa_cmwv/FS/3cells_ecpri_4pipes
@{PARAMS_IN_VENDOR}
...    maxNumOfUserL2Pool=20
...    maxNumOfDRBL2Pool=15
...    maxNumOfGBRL2Pool=10
...    guaranteedResourceRatioPerCell=5
...    maxNumPucchF1SRPerSlotL1Pool=4
...    maxNumPucchF3PCSIPerSlotL1Pool=1
@{PARAMS_IN_SWCONFIG}
...    ${rdNewTddCellSlotModel}
...    ${rdTddPoolingFeaturesEnable}
${rdTddPoolingFeaturesEnable}
...    0x420068=2
${rdNewTddCellSlotModel}
...    0x420062=1
@{PARAMS_IN_SCF}
...    @{5GC002426}
...    @{5GC000704}
...    @{CA}
...    @{NRREL}
...    ${reestablish_SA_enable}
...    @{NRDRB}
...    @{2200_enable}
...    @{8698_enable}
...    @{beforming} 
...    NRBTS:actExplicitCsirsPoolSolution=true

@{params_config_for_case_17}
...    NRBTS:numOfDRBReservedPerEmergency=3
  
@{5GC002426}
...    NRBTS:actBbPoolTddFr1=true
...    NRBTS:actBbPoolTddFr1AlgEnh=true    
...    NRCELL:actShortBsrLimitAdaptation=true
...    NRCELL:maxNumOfUsersPerCell=20    
...    NRCELL:maxNumOfNrDcSnUsers=20
...    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL-1:periodicCsiAcquisition:csiReportPeriodicity=slots40
...    NRCELL-2:periodicCsiAcquisition:csiReportPeriodicity=slots160  
...    NRCELL-3:periodicCsiAcquisition:csiReportPeriodicity=slots160    
...    NRCELL:srPeriodicity=slots160  ## slot80
...    NRCELL:reqMinNumPuschPrb=13
...    NRCELL:actEmergencyCall=false
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false|emergencyCallPlmnHoAllowed=false
@{beforming}
...    NRBTS:actBbPoolExtensionTddFr1=true
...    NRCELL:actBeamforming=true
...    NRCELL:actCsirsMultiplexing=true
...    NRCELL:actPerCsiReportBundlingTddFr1=true
...    NRCELL:beamSet:basicBeamSet=beamSet_2
...    NRCELL:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL:numberOfRxBeamforming=4Rx
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=2 beams 
...    NRCELLGRP-1:numberOfTransmittedSsBlocks=2 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=2 beams 
@{2200_enable}
...    NRCELL-1:dlMimoMode=8x4 Closed Loop Spatial Multiplexing
...    NRCELL-2:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-3:dlMimoMode=4x4 or 4x2 Open Loop Spatial Multiplexing
...    NRCELL-1:ssPbchBlockPower=10
...    NRBTS:actFdmEnhancedScheduling=true
...    NRCELL-1:periodicCsiAcquisition:csirsPower=10
...    NRCELL-1:periodicCsiAcquisition:csirsNumberWithinReportPeriod_Set1=1
...    NRCELL-1:periodicCsiAcquisition:maxCsirsNumber=4
@{8698_enable}
...    NRBTS:actDrbPreemption=true
...    NRBTS:actUserPreemption=true
...    NRBTS:maxNumOfPreemptions=20
...    NRCELL:numOfRadioResReservForTempUse=1
...    NRCELL:preferNsaPreemption=true
...    NRCELL:allowEmergencyReservForTempUse=true
...    NRCELL:numOfRadioResReservForEmergency=1
@{5GC000704}

...    NRBTS:actConflictConfiguration=true
...    NRBTS:actIntraFreqHoSA=true
...    NRBTS:timerXnDataFwdGuard=250
...    NRPMRNL-1:miNrRelReportCu=5min
...    NRCELL:a3MeasEnabled=rsrp
...    NRCELL:a3MeasSsbRsrp:a3HysteresisSsbRsrp=0|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:a3MeasSsbRsrp:a3OffsetSsbRsrp=3|a3TimeToTriggerSsbRsrp=ms320
...    NRCELL:filterCoeffSsbRsrp=fc4
...    NRCELL:absThreshSsbRsrpConsolidation=80
...    NRCELL:sMeasConfigSsbRsrp=20
...    NRBTS:actIncXn=true
...    NRBTS:cipherPrefL:nea0=9|nea3_128=0
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForTempUse=120
...    NRCELL:actVoNR=true
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfCaUsersNRCell=20
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
${cell_lock}
...    NRCELL-1:administrativeState=Locked
${cell_unlock}
...    NRCELL-1:administrativeState=Unlocked
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
...    NRCELL-1/NRREL-1:gNbId=2
...    NRCELL-1/NRREL-1:gNbIdLength=22
...    NRCELL-1/NRREL-1:lcrId=2
...    NRCELL-1/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-1/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-1/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-2/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-2/NRREL-1:gNbId=2
...    NRCELL-2/NRREL-1:gNbIdLength=22
...    NRCELL-2/NRREL-1:lcrId=1
...    NRCELL-2/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-2/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-2/NRREL-1:gnbPlmn:mncLength=3
${wait_UE_deregister_finish}
...    1s
${ue_nr_capability_with_band_78}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0213641873E618F28581C130080C4700FB8D85181AC1184341020E9008DA
...    D931563439F11C7A067D813E31238F21CFA8E7CC31E50B0381C3C170005F001C0017C000300E0741B13703582308682041D2
...    01195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD817C007F605F0000C0381506C46D608C21A08107880
...    4656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F0000001FC0000000300E0541B107582308682041E2011
...    95B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FC0AAAAA7F02AAAA80C03800CA0711810000048150705007
...    1180000084815878500018460001048158389A10000C041D61E2680061340008020EA17104003882001C4600000A120E00E0
...    234028809B0104048606813B639F0E14E9DB1CF870A24ED8E7C38113639F0E1449DB1CF8712006C73E1BD01C078005038080
...    E0600601C090010180F82400800000004000008020000000100000200800002004000018020000100100000A008004010040
...    100000C0080000700400200000008000080040000480200100C030040000500200002C01000812048020000300CE54D654D6
...    0A5606560CD60AD652D64CD602D606D6025604560ED0341000009652504000065949410000296524040000E5949010000496
...    52404000165949010000696524040001E594901000089652404000265949010000A96524040002E5949410000C9652404000
...    0C594900C52AABA55554AA2E95455058AA071541A2A94C55268AA031540A2A93555078A022F012A05028140A05028140A050
...    28140A05028140A0502800280040780608080100002018030404008020100C00000203001040400802010020004020180300
...    80600C02018030D50F8000810182030385058606880889098A0C0C8D8E0E8F909293139414951697A0A08350
${ue_capacity_SA}        SEPARATOR= 
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21
...    A08107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B8002F800E000BE00088000
...    E0741B13703582308682041D2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD817C007
...    F605F00044000702A0D88DAC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA16070387
...    84FE0000003F800000022000381506C41D608C21A0810788240656C98AB121CFB027C471E31238F21CFA8E7CC3
...    1E50B0381C3C27F02AAAA9FC0AAAAA110001C00650388C080000240A838280388C000004240AC3C28000C23000
...    08240AC1C28080006020EB0F0A00030500004010750B882001C41000E230000050907007011A014400080821A
...    010C0D0276C73E1C29D3B639F0E1449DB1CF870226C73E1C2893B639F0E2400D8E7C37A09801E00140E0A00E060
...    1280380030120020301F04801000000008000010040000000200000401000004008000030040000200200001401
...    000802008020000180100000E008004000000100001000800009004002018060080000A00400005802001024090
...    0400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB2928200
...    0052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB292020
...    00152CA48080005CB29282000192CA480800018B292018A55574AAAA9545D2A8AA0B1540E2A83455298AA4D1540
...    62A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A05000500080F00C101002000040
...    3006080801004020180000040600208080100402004000804030060100C01804030061AA1F000102030406070A0
...    B0C0D101112131418191B1C1D1F2125262728292A2D2F41410781C060006010    
${ue_nr_capabilities}        SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A0
...    8107482406D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0B8002F800E000BE00088000E074
...    1B13703582308682041D2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD817C007F605F0
...    0044000702A0D88DAC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE0000
...    003F800000022000381506C41D608C21A0810788240656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C
...    3C27F02AAAA9FC0AAAAA110001C00650388C080000240A838280388C000004240AC3C28000C2300008240AC1C280
...    80006020EB0F0A00030500004010750B882001C41000E230000050907007011A014400080821A010C0D0276C73E1
...    C29D3B639F0E1449DB1CF870226C73E1C2893B639F0E2400D8E7C37A09801E00140E0A00E0601280380030120020
...    301F0480100000000800001004000000020000040100000400800003004000020020000140100080200802000018
...    0100000E008004000000100001000800009004002018060080000A004000058020010240900400006019CA9ACA9A
...    C14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB292
...    02000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB292
...    82000192CA480800018B292018A55574AAAA9545D2A8AA0B1540E2A83455298AA4D154062A8145526AAA0F142405
...    E02540A05028140A05028140A05028140A05028140A05000500080F00C1010020000403006080801004020180000
...    040600208080100402004000804030060100C01804030061AA1F000102030406070A0B0C0D101112131418191B1C
...    1D1F2125262728292A2D2F41410781C060006010
${ue_eutra_nr_capabilities}        SEPARATOR=
...     A11FD82B84C0C0389A001C46000000122205C160601C46000002022205C2606018280388C00000824440B84C0C03
...     85000184600018488817058180710400002048881007011A01400380826010400010080801004020180304000201
...     0100C01840001008080100002018030800020101002008040300008000402020180300

*** Test Cases ***
CB008847-J_ET_18_01_NSA or HO UE CSI resource RAC interaction with preemption on 2200 cell with 8698 on
    [Tags]
    Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=33    ue_id_end_before=39
    UE39 ENDC setup failed due to temp resource not availble
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=2
    UE ICS with 5QI5 specified priority    id=1    priority=9
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=2    ue_id_end_before=3
    UE ICS with 5QI5 specified priority    id=2    priority=5
    UE HO To Target Cell1 Successfully    2
    Check Wireshark Log    ${CURDIR}${/}a2a_case18${/}preemption.ini

CB008847-J_ET_16_01_CSI resource reconfig with reservePoolAvailableFlag false on 2200 cell with 8698 on    
    [Tags]
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=7
    Create PDU sessions for UE1 and UE2
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=7    ue_id_end_before=8
    UE ICS with 5QI5 specified priority    id=7    priority=5
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=8    ue_id_end_before=9
    UE8 ICS failed due to preemption failure
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=9    ue_id_end_before=10
    Release UE7 and UE9 ICS succeed
    Check Wireshark Log    ${CURDIR}${/}a2a_case16${/}preemption.ini

CB008847-J_ET_17_01_CSI resource reconfig and drb pre-emption on 2200 cell with 8698 on 
    [Tags]
    Delta Commission Parameters    ${params_config_for_case_17}
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=6
    UEs ICS succeed    ue_id_start=1    ue_id_end_before=4    priority=9
    UE ICS with 5QI5 specified priority    id=4    priority=5
    UE ICS with 5QI5 specified priority    id=5    priority=5
    Check Wireshark Log    ${CURDIR}${/}a2a_case17${/}preemption.ini
    
*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=${TL_TYPE_PATH}
    Set UE Parameters Before Register

Set UE Parameters Before Register
    Execute Egate Command    enb_x2_link_up enb=1 target=2    None

Create PDU sessions for UE1 and UE2
    UE ICS with 5QI5 specified priority    id=1    priority=9
    UE ICS with 5QI5 specified priority    id=2    priority=9

UE ICS with 5QI5 specified priority
    [Arguments]    ${id}    ${priority}
    Execute Egate Command    qosflow_modify qos_flow=1 priority=${priority} pci=may_trigger_pre_emption
    Execute Egate Command    smf_param id=1 additional_qosflows_to_activate=${priority}
    UE PDU Session Setup    ${id}    ${id}

Modify Cfg
    Set SA UE in WTS
    Set NSA UE in WTS
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

Set SA UE in WTS
    ${cfg_cmd}    catenate
    ...    uec=1     release=15    idle_edrx_cycle_len=2    ptw=2.56    opc_key=0ED47545168EAFE2C39C075829A7B61F    nia=null+zuc 
    ...    nea=null+zuc    sec_key=0102030405060708090A0B0C0D0EFF00    mode=nr     enb=2     cell=1
    FOR    ${ue_id}    IN RANGE    2    10   
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${ue_capacity_SA}
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd} suci=0:311:489:0000:0:0:02164540${ue_id}
    END
    FOR    ${ue_id}    IN RANGE    10    31   
        Update Cfg    ue_param id=${ue_id} ue_nr_capabilities=${ue_capacity_SA}
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd} suci=0:311:489:0000:0:0:0216454${ue_id}
    END

Set NSA UE in WTS
    ${cfg_cmd_1}    catenate
    ...    ue_nr_capabilities=${ue_nr_capabilities} dual_conn=eutra_nr ue_eutra_nr_capabilities=${ue_eutra_nr_capabilities} 
    ${cfg_cmd_2}    catenate
    ...    uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=zuc 
    FOR    ${ue_id}    IN RANGE    32    56   
        Update Cfg    ue_param id=${ue_id} ${cfg_cmd_1} 
        Update Cfg    set_ue simulated id=${ue_id} ${cfg_cmd_2} nea=zuc imsi=250:555:216455${ue_id}
    END

#Common Test Teardown And Restore Env
##    Deregister UEs    ue_id_start=1    ue_id_end_before=25
#    Common Test Teardown And Stop Capture Logs

Deregister UEs
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=2
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Execute Egate Command    ue_deregister id=${ue_id} ue_deregister_type=switch_off    None
        sleep    ${wait_UE_deregister_finish}
    END

Modify UE Establishemnt Cause
    [Arguments]    ${ue_id}    ${cause}
    Execute Egate Command    ue_nr_rrc_setup_param id=${ue_id} establishment_cause=${cause}    None

Register For Normal Call Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}

Register For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
    END

UE Register To GNB
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_register id=${ue_id} ue_nr_capabilities=${ue_nr_capability_with_band_78}    UE now in NG RM Reg

UE PDU Session Setup
    [Arguments]    ${ue_id}=1    ${gw_id}=1
    ${ret1}=    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${gw_id}    QoS Routing Table
    Should Contain    ${ret1}    Created FiveQi:Qfi mapping fiveQi 5 qfi 1

Release UE7 and UE9 ICS succeed  
    Deregister UEs    ue_id_start=7    ue_id_end_before=8
    UE ICS with 5QI5 specified priority    id=9    priority=2

UE8 ICS failed due to preemption failure
    ${status}=    Run Keyword And Return Status    UE ICS with 5QI5 specified priority    id=8    priority=9
    Should Be True    '${status}'=='False'          

UEs ICS succeed
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}    ${priority}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE ICS with 5QI5 specified priority    id=${ue_id}    priority=${priority}
    END

UE39 ENDC setup failed due to temp resource not availble
    ${status}=    Run Keyword And Return Status    Attach And Set ENDC For Number Of Normal Calls    cell_id=1    ue_id_start=39    
    ...    ue_id_end_before=40
    Should Be True    '${status}'=='False'

Attach And Set ENDC For Number Of Normal Calls
    [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        UE Attach To ENB And Set ENDC    ${ue_id}    ${cell_id}
    END

UE HO To Target Cell1 Successfully
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=50 nrsrp_nr=70 nrsrq_nr=30
    ...    Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    
UE Attach To ENB And Set ENDC
    [Arguments]    ${ue_id}    ${cell_id}
    Execute Egate Command    ue_attach id=${ue_id} profile=1    UE IS ACTIVE
    Execute Egate Command    bearer_mod ue=${ue_id} id=2 priority=9 preemption=on vulnerability=on     None
    sleep    5    #wait for ENDC
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${cell_id} bearer=2 type=split_scg
    ...    reported successful RA

Lock cell1
    Delta Commission Parameters    ${cell_lock}
    Delta Commission Parameters    ${cell_unlock}
    wait cell has sib Message    cell_id=1

wait cell has sib Message
    [Arguments]    ${cell_id}
    Wait Until Keyword Succeeds    2min    2s    check cell has sib Message    cell_id=${cell_id}

check cell has sib Message
    [Arguments]    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    should contain X Times    ${ret}    yes    6

case_teardown
    Lock cell1
    Common Test Teardown And Stop Capture Logs
    