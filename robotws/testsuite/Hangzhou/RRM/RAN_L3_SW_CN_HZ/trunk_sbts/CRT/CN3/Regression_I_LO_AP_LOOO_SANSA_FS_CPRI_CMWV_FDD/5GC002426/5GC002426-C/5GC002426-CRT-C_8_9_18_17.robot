*** Settings ***
Suite Setup       Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Restore Env
Force Tags        QCD_MN_RAN  QCP_RAN_ET  SBTS00  RAN_5G  CRT  CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_CPRI_CMWV_FDD
...               team-DevHZ5_SG1    owner-qi.zheng    release-SBTS22R2
Resource          ../../../../../../resources/DevHZ5_resource.robot


*** Variables ***
${TL_TYPE_PATH}    fdd_sansa_cmwv/6cells
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
@{PARAMS_IN_SCF}    @{5GC002426}    @{5GC000704}    @{CA}    @{NRREL}    ${reestablish_SA_enable}    @{NRDRB}
@{5GC002426}
...    MRBTS/EQM-1/APEQM-1/CABINET-1/BBMOD-1:bbmodBoardConfigType=NRFDD_NRTDD
...    NRBTS:actConnRrcPooling=true    NRBTS:actScheUePooling=true
...    NRCELL:maxNumOfUsersPerCell=20    NRCELL:maxNumOfRrcSA=20
...    NRCELL:maxNumOfSCellAlloc=20
...    NRCELL:maxNumOfUsersPerNRCell=20
...    NRCELL:periodicCsiAcquisition:csiReportPeriodicity=slots160    NRCELL:srPeriodicity=slots80
...    NRCELL:reqMinNumPuschPrb=13    NRCELL:actEmergencyCall=true
...    NRCELL:emergencyCallRestrictions:emergencyCallMrListIgnore=false|emergencyCallPlmnHoAllowed=false
...    NRCELL:numOfRadioResReservForEmergency=1
...    NRBTS/NRDU-1:numOfDrbsReservForEmergency=1
...    NRCELL:actVoNR=true
...    NRCELL:maxNumOfGBRBearersSA=10
...    NRCELL:maxNumOfCaUsersNRCell=20
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
...    MRBTS-2/NRBTS-2/NRDRB-15:cellAggrLevel=Not FR1 CA eligible
${reestablish_SA_enable}    NRBTS-2:rrcReestabTypeSA=sameGNB
${cell6_lock}    NRCELL-6:administrativeState=Locked
${cell6_unlock}    NRCELL-6:administrativeState=Unlocked
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
@{CA}
...    NRBTS/NRDU-1:actConnectedModeMobilityCA=true
...    NRBTS/NRDU-1:flexibleCAMode=NumberCellAmount
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
${ue_nr_capabilities_not_support_band66_band71_CA_org}    SEPARATOR=
...    E9A09000575F5A13160003C0A02C1262E003387A0609B20C39F30C7942C0E098040623807DC6C28C0D608C21A0810748046D6C98AB1A1CF88E3D033EC09F1891C790E
...    7D473E618F28581C0E1E0B8002F800E000BE000280381D06C4DC0D608C21A081074804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F605F001FD
...    817C000500702A0D88DAC1184341020F1008CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE0000003F80000000A00E0541B107582308682041E20
...    1195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FC0AAAAA7F02AAAA81401C00550388C080000240A838280388C000004240AC3C28000C230000824
...    0AC1C28080006020EB0F0A000305000040107007011A014400080820A0E40B0276C73E1C29D3B639F0E1449DB1CF870226C73E1C2893B639F0C7A0580780050381807
...    0300540700060240040603E09002000000010000020080000000400000802000008010000060080000400400002802001004010040000300200001C01000800000020
...    00020010000120080040300C010000140080000B004002048120080000C0339535953582958195833582B594B5933580B581B58095811583B40D04000025949410000
...    196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490
...    100003165240314AAAE955552A8BA55154162A81C55068AA531549A2A80C55028AA4D5541E2808BC04A8140A05028140A05028140A05028140A05028140A000800101
...    E018202004000080600C101002008040300000080C00410100200804008001AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F41410
...    78080C02
${ue_nr_capabilities_not_support_band66_band71_CA}    SEPARATOR=
...    E9A09000575F5A13160003C2A002C1262E003387A0E026C830E7CC31E50B03826010188E01F71B0A303582308682041D207036B64C558D0E7C471E819F604F8C48E3C
...    873EA39F30C7942C0E070F05C0017C0070005F0003C000E0741B13703582308682041D207032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E13FB02F8
...    00FEC0BE00078001C0A836236B04610D04083C40E0656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F0000001FC0000000F000381506C41D608C21A
...    08107881C0CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE0555553F81555541E0007001940E230200000902A0E0A00E230000010902B0F0A0003
...    08C00020902B070A0200018083AC3C28000C1400010041D40E20820005090200E0234028800101042C04303409DB1CF870A74ED8E7C3851276C73E1C089B1CF870A24
...    ED8E7C3813B639F0C1E8260078005038280381804A00E000C0480080C07C120040000000200000401000000008000010040000100200000C010000080080000500400
...    2008020080000600400003802001000000040000400200002401000806018020000280100001600800409024010000180672A6B2A6B052B032B066B056B296B266B01
...    6B036B012B022B07681A0800004B29282000032CA4A0800014B29202000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA
...    480800054B29202000172CA4A0800064B29202000062CA480629555D2AAAA55174AA2A82C55038AA0D154A62A93455018AA051549AAA83C5090178095028140A05028
...    140A05028140A05028140A0502814001400203C030404008000100C0182020040100806000001018008202004010080100000101E0186A87C0004080C10181C282C30
...    344044484C5060646C70747C8494989CA0A4A8B4BD05041E06018040
${ue_nr_capabilities_support_band66_band71_CA}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09F1891C7
...    90E7D473E618F28581C0E1E0B8002F800E000BE00088000E0741B13703582308682041D2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0E070F09FD817
...    C007F605F00044000702A0D88DAC1184341020F10480CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FE0000003F800000022000381506C41D608C2
...    1A0810788240656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27F02AAAA9FC0AAAAA110001C00650388C080000240A838280388C000004240AC3C280
...    00C2300008240AC1C28080006020EB0F0A00030500004010750B882001C41000E230000050907007011A014400080821A010C0D0276C73E1C29D3B639F0E1449DB1CF
...    870226C73E1C2893B639F0E2400D8E7C37A09801E00140E0A00E0601280380030120020301F0480100000000800001004000000020000040100000400800003004000
...    0200200001401000802008020000180100000E008004000000100001000800009004002018060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19
...    AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB29282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB292020001
...    12CA48080004CB29202000152CA48080005CB29282000192CA480800018B292018A55574AAAA9545D2A8AA0B1540E2A83455298AA4D154062A8145526AAA0F142405E
...    02540A05028140A05028140A05028140A05028140A05000500080F00C1010020000403006080801004020180000040600208080100402004000804030060100C01804
...    030061AA1F000102030406070A0B0C0D101112131418191B1C1D1F2125262728292A2D2F41410781C060006010
@{PM_Counters_Check_C8}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-2:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-2:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-4:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-4:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
@{PM_Counters_Check_C9}
...    NRCELL-6:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-6:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
@{PM_Counters_Check_C18}
...    NRCELL-1:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=1
...    NRCELL-1:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=1
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0
@{PM_Counters_Check_C17}
...    NRCELL-3:${SA_DU_RAC_FAIL_BBPOOL_NR_USER}=0
...    NRCELL-3:${SGNB_SA_DU_RAC_REJ_DUE_RRC}=0
${SA_DU_RAC_FAIL_BBPOOL_NR_USER}    M55139C03502
${SGNB_SA_DU_RAC_REJ_DUE_RRC}    M55139C00013
${wait_UE_deregister_finish}    1s

*** Test Cases ***
5GC002426-C_ET_18_01_The NR User number for FDD L2 pool check for CA users when Reestablishment
    [Documentation]
    ...    precondition:
    ...           maxNumOfUserL2Pool: 20
    ...           Guaranteed L2 NR User number per cell: 2
    ...           Emergency resource (NR User Number）per cell: 1
    ...           Shared resource (NR User Number）: 2
    ...           UE1-4 not support band71 and band66 CA
    ...    step1: EXPECT: register 3 UEs on cell1 pass
    ...    step2: EXPECT: register 1 UE on cell3 pass
    ...    step3: EXPECT: register 1 UE on cell1 with blind CA cell3 pass
    ...    step4: EXPECT: reestablish the UE-5 on cell1 fail
    ...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER, SGNB_SA_DU_RAC_REJ_DUE_RRC value increase 1 on cell1
    ...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER, SGNB_SA_DU_RAC_REJ_DUE_RRC value no change on cell3
    [Setup]    Common Test Setup And Start To Capture Logs On Case18
    [Teardown]    Common Test Setup And Stop To Capture Logs On Case18
    [Tags]    TC18
    set UE1to4 not support band71 and band66 CA before register
    Register And Set up PDU For Number Of Normal Calls  cell_id=1    ue_id_start=1    ue_id_end_before=4
    Register And Set up PDU For Number Of Normal Calls  cell_id=3    ue_id_start=4    ue_id_end_before=5
    Register And Set up PDU For Normal Call with blind scell added Successfully    ue_id=5    cell_id=1
    Clear Counter files
    reestablish UE to serving cell fail    ue_id=5
    Check Counters    ${PM_Counters_Check_C18}
    Register And Set up PDU For Normal Call with blind scell added Successfully    ue_id=6    cell_id=1

5GC002426-C_ET_17_01_The NR User number for FDD L2 pool check for CA users Scell addition
    [Documentation]
    ...    precondition:
    ...           maxNumOfUserL2Pool: 20
    ...           Guaranteed L2 NR User number per cell: 2
    ...           Shared resource (NR User Number）: 8
    ...    step1: EXPECT: register 9 UEs on cell1 pass
    ...    step2: EXPECT: UE8 send A1 report to add one scell successfully
    ...    step3: EXPECT: UE9 send A1 report to add one scell successfully
    ...    step4: EXPECT: UE10 add scell RAC fail
	...                   counter SA_DU_RAC_FAIL_BBPOOL_NR_USER value increase 1 on cell3
    ...                   counter SGNB_SA_DU_RAC_REJ_DUE_RRC value no change on cell3
    ...    step5: EXPECT: UE8 report A2 to release scell
	...    step6: EXPECT: UE10 send A1 report to add one scell successfully
	...    step7: EXPECT: UE10 handover to cell2 successfully
	...    step8: EXPECT: register UE-11 on cell1 pass
	...    step9: EXPECT: UE11 send A1 report to add one scell successfully
    ...    check point in btslog: bb pooling NR user number RAC for l2pool, result: true / false
    [Setup]    Common Test Setup And Start To Capture Logs On Case17
    [Teardown]    Common Test Setup And Stop To Capture Logs On Case17
    [Tags]    TC17
    Register And Set up PDU For Number Of Normal Calls  cell_id=1    ue_id_start=1    ue_id_end_before=10
    UE report A1 to add scell Successfully    ue_id=8
    UE report A1 to add scell Successfully    ue_id=9
    ue10 CA to add scell3 should RAC fail
    UE report A2 to release scell    ue_id=8
    UE report A1 to add scell Successfully    ue_id=10
    UE HO To Target Cell Successfully    ue_id=10    cell_id=2
    Register And Set up PDU For Normal Call Successfully    ue_id=11    cell_id=1
    UE report A1 to add scell Successfully    ue_id=11

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

Common Test Teardown And Restore Env
    Delta Commission Parameters    ${cell6_unlock}
    wait cell has sib Message    cell_id=6
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
  UE PDU Session Setup    ${ue_id}    ${ue_id}

Register For Number Of Normal Calls
  [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
  Modify QOSflow    priority=15
  FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register For Normal Call Successfully    ${ue_id}    ${cell_id}
  END

Register And Set up PDU For Number Of Normal Calls
  [Arguments]    ${cell_id}    ${ue_id_start}    ${ue_id_end_before}
  Modify QOSflow    priority=15
  FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Register And Set up PDU For Normal Call Successfully    ${ue_id}    ${cell_id}
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

UE HO To Target Cell Successfully
  [Arguments]    ${ue_id}    ${cell_id}
  ${ret1}=  Execute Egate Command
  ...    ue_measurement_send_nr id=${ue_id} meas_id=1 event=A3 srsrp_nr=50 srsrq_nr=30 phycell_id=51 nrsrp_nr=70 nrsrq_nr=30
  ...    Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

wait cell has sib Message
    [Arguments]    ${cell_id}
    Wait Until Keyword Succeeds    1min    2s    check cell has sib Message    cell_id=${cell_id}

check cell has sib Message
    [Arguments]    ${cell_id}
    ${ret}    Execute Egate Command    ib_enb_cell_disp enb=2 cell=${cell_id}    SIB
    should contain X Times    ${ret}    yes    6

Register For 4 Normal Calls on cell1 and 2 Normal Calls on cell2 to cell5
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=5
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=5    ue_id_end_before=7
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=7    ue_id_end_before=9
    Register For Number Of Normal Calls    cell_id=4    ue_id_start=9    ue_id_end_before=11
    Register For Number Of Normal Calls    cell_id=5    ue_id_start=11    ue_id_end_before=13

UE Register To GNB for 1 Normal Call on cell1 to cell4 Due To RAC Failure
    Modify QOSflow    priority=15
    Modify UE Establishemnt Cause    ue_id=13    cause=mo-Signalling
    Modify UE Establishemnt Cause    ue_id=14    cause=mo-Signalling
    Modify UE Establishemnt Cause    ue_id=15    cause=mo-Signalling
    Modify UE Establishemnt Cause    ue_id=16    cause=mo-Signalling
    UE Register To GNB Due To RAC Failure    cell_id=1    ue_id=13
    UE Register To GNB Due To RAC Failure    cell_id=2    ue_id=14
    UE Register To GNB Due To RAC Failure    cell_id=3    ue_id=15
    UE Register To GNB Due To RAC Failure    cell_id=4    ue_id=16

Register For 2 Normal Calls on cell1 to cell5
    Register For Number Of Normal Calls    cell_id=1    ue_id_start=1    ue_id_end_before=3
    Register For Number Of Normal Calls    cell_id=2    ue_id_start=3    ue_id_end_before=5
    Register For Number Of Normal Calls    cell_id=3    ue_id_start=5    ue_id_end_before=7
    Register For Number Of Normal Calls    cell_id=4    ue_id_start=7    ue_id_end_before=9
    Register For Number Of Normal Calls    cell_id=5    ue_id_start=9    ue_id_end_before=11

set UE1to4 not support band71 and band66 CA before register
    Execute Egate Command    ue_param id=1-4 ue_nr_capabilities=${ue_nr_capabilities_not_support_band66_band71_CA}    None

restore ue capability
    Execute Egate Command    ue_param id=1-4 ue_nr_capabilities=${ue_nr_capabilities_support_band66_band71_CA}    None

reestablish UE to serving cell fail
    [Arguments]    ${ue_id}
    Execute Egate Command    ue_rrc_reestablish id=${ue_id} gnb=2 cell=1    fail
    Execute Egate Command    ue_disp state=ACTIVE    2.1

Register And Set up PDU For Normal Call with blind scell added Successfully
    [Arguments]    ${ue_id}    ${cell_id}
    [Return]    ${ret}
    Execute Egate Command    ue_change_location id=${ue_id} cell=${cell_id}    None
    Modify UE Establishemnt Cause    ${ue_id}    mo-Signalling
    UE Register To GNB    ${ue_id}
    ${ret}    Execute Egate Command    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}    sCellToAddModList
    should contain    ${ret}    physCellId 52

Common Test Setup And Start To Capture Logs On Case17
    Common Test Setup And Start To Capture Logs
    @{precondition_case17}    Create List    NRCELL:actEmergencyCall=false
    ...    NRCELL-1/NRREL-1:sCellAdditionMethod=covBasedA1    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
    Delta Commission Parameters    ${precondition_case17}
    cells should be onair

Common Test Setup And Stop To Capture Logs On Case17
    @{postcondition_case17}    Create List    NRCELL:actEmergencyCall=true
    ...    delete:NRCELL-1/NRREL-1:sCellAdditionMethod    delete:NRCELL-1/NRREL-1:sCellOperationalMode
    Delta Commission Parameters    ${postcondition_case17}
    Deregister UEs    ue_id_start=1    ue_id_end_before=12
    Common Test Teardown And Stop Capture Logs

Common Test Setup And Start To Capture Logs On Case18
    Common Test Setup And Start To Capture Logs
    @{precondition_case18}    Create List    NRCELL-1/NRREL-1:sCellAdditionMethod=blind    NRCELL-1/NRREL-1:sCellOperationalMode=dlOnly
    Delta Commission Parameters    ${precondition_case18}

Common Test Setup And Stop To Capture Logs On Case18
    @{postcondition_case18}    Create List    delete:NRCELL-1/NRREL-1:sCellAdditionMethod    delete:NRCELL-1/NRREL-1:sCellOperationalMode
    Delta Commission Parameters    ${postcondition_case18}
    restore ue capability
    Deregister UEs    ue_id_start=1    ue_id_end_before=7
    Common Test Teardown And Stop Capture Logs

UE report A1 to add scell Successfully
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    sCellToAddModList

ue10 CA to add scell3 should RAC fail
    Register And Set up PDU For Normal Call Successfully    ue_id=10    cell_id=1
    Clear Counter files
    UE report A1 to add scell fail    ue_id=10
    Check Counters    ${PM_Counters_Check_C17}

UE report A1 to add scell fail
    [Arguments]    ${ue_id}
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=3 phycell_id=50 event=A1 srsrp_nr=80 srsrq_nr=40
    ...    fail_regexp=sCellToAddModList    timeout=5s

UE report A2 to release scell
    [Arguments]    ${ue_id}    ${scell_index}=1
    ${ret1}=    Execute Egate Command
    ...    ue_measurement_send_nr id=${ue_id} meas_id=4 scell=${scell_index} scell_rsrp=40 scell_rsrq=0 event=A2
    ...    sCellToReleaseList

wait all UE deregistered
    wait until keyword succeeds    2min    10s    check no UE active

check no UE active
    Execute Egate Command    ue_disp   fail_regexp=ACTIVE    timeout=5
