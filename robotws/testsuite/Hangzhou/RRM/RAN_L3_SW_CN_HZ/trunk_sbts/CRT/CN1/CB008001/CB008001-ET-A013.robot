*** Settings ***
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    QCD_MN_RAN    QCP_RAN_ET    SBTS00    RAN_5G    RAN_5G_TDD    CRT    CLOUD_5G_I_BOO_AP_LOO
...    team-DevHZ5_SG4    owner-eric.jiang    release-5G22R3    CB008001
Resource    ..${/}..${/}..${/}..${/}resources${/}DevHZ5_resource.robot

*** Variables ***
${DEBUG_LOG_LEVEL}    0
@{PARAMS_IN_SCF}
...    @{CA_A1ScellAddition}
...    @{MixedMode_CA}
...    @{Neighbor_Gnb}
...    @{CASupportList}
...    @{BCS}
...    @{BOO_AP_LOO}

@{BOO_AP_LOO}
...    NRBTS:sCellActivationMethod=blind
...    NRCELL:sCellDeactivationTimerGNB=infinity
...    NRCELL:a1MeasSCellAddEnabled=rsrp
...    NRCELL:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL:measGapSelectionSA=favourUeThroughput
...    NRCELL:a2MeasSCellRelEnabled=rsrp
...    NRCELL:a2MeasSCellRelSsbRsrp:a2HysteresisSCellRelSsbRsrp=0|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrp:a2ThresholdSCellRelSsbRsrp=35|a2TimeToTriggerSCellRelSsbRsrp=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2HysteresisSCellRelSsbRsrq=0|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL:a2MeasSCellRelSsbRsrq:a2ThresholdSCellRelSsbRsrq=49|a2TimeToTriggerSCellRelSsbRsrq=0ms
...    NRCELL-3/NRREL-1:sCellOperationalMode=dlOnly
...    NRCELL-4/NRREL-1:sCellOperationalMode=dlOnly
...    NRBTS-1/BWP_PROFILE-54/PDCCH-1/PDCCH_CONFIG_DEDICATED-1:coresetDedicated:size=96

@{CA_A1ScellAddition}
...    NRBTS-1:actBcsCheck=enabled_FR1
...    NRBTS-1:actFdmEnhancedScheduling=true
...    NRBTS-1:actFdmScheduling=true
...    NRBTS-1:actLteNrDss=true
...    NRCELL:actPrachMultiplexing=true
...    NRCELL:actCDrx=true
...    NRCELL:actK1Opt=intra-gNB
...    NRCELL:pucchModeSelect=longPucch
...    NRCELL:pucchF3ModulationScheme=pi2bpsk
...    NRCELL:pucchF3MaxCodeRate=zeroDot08
...    NRCELL-11:pMax=380
@{MixedMode_CA}
...    NRCELL-1:actBeamforming=false
...    #NRCELL-1:nrCellType=4DL2UL
...    NRCELL-1:beamSet:basicBeamSet=beamSet_4
...    NRCELL-1:beamSet:beamSetInUse=beamSet_4
...    NRCELL-1:beamSet:leftEdgeAngle=60
...    NRCELL-1:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-1:beamSet:rightEdgeAngle=60
...    NRCELL-3:nrarfcn=518580
...    NRCELL-3:chBw=40MHz
...    NRCELL-3:gscnOrSsPbchArfcn=6486
...    NRCELL-3:freqBandIndicatorNR=41
...    NRCELL-3:actBeamforming=false
...    #NRCELL-3:nrCellType=4DL2UL
...    NRCELL-3:beamSet:basicBeamSet=beamSet_4
...    NRCELL-3:beamSet:beamSetInUse=beamSet_4
...    NRCELL-3:beamSet:leftEdgeAngle=60
...    NRCELL-3:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-3:beamSet:rightEdgeAngle=60
...    NRCELL-4:nrarfcn=508620
...    NRCELL-4:chBw=40MHz
...    NRCELL-4:gscnOrSsPbchArfcn=6357
...    NRCELL-4:freqBandIndicatorNR=41
...    NRCELL-4:actBeamforming=false
...    #NRCELL-4:nrCellType=4DL2UL
...    NRCELL-4:beamSet:basicBeamSet=beamSet_4
...    NRCELL-4:beamSet:beamSetInUse=beamSet_4
...    NRCELL-4:beamSet:leftEdgeAngle=60
...    NRCELL-4:beamSet:nrBtsBeamRefinementP2=false
...    NRCELL-4:beamSet:rightEdgeAngle=60
@{Neighbor_Gnb}
...    XNLINK-1:cPlaneIpAddr=10.0.1.122
...    XNLINK-2:cPlaneIpAddr=10.0.1.124
...    NRADJGNB-10:administrativeState=Unlocked
...    NRADJGNB-10:gNbIdLength=22
...    NRADJGNB-10:gNodeBId=35
...    NRADJGNB-10:xnLinkRef=1
...    NRADJGNB-10:gnbPlmn:mcc=311
...    NRADJGNB-10:gnbPlmn:mnc=489
...    NRADJGNB-10:gnbPlmn:mncLength=3
...    NRADJGNB-1:administrativeState=Unlocked
...    NRADJGNB-1:gNbIdLength=22
...    NRADJGNB-1:gNodeBId=36
...    NRADJGNB-1:xnLinkRef=2
...    NRADJGNB-1:gnbPlmn:mcc=311
...    NRADJGNB-1:gnbPlmn:mnc=489
...    NRADJGNB-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-1:cellDepType=SA
...    NRADJNRCELL-1:fiveGsTac=200
...    NRADJNRCELL-1:gNbId=35
...    NRADJNRCELL-1:gNbIdLength=22
...    NRADJNRCELL-1:lcrId=1
...    NRADJNRCELL-1:nrarfcn=513234
...    NRADJNRCELL-1:physCellId=48
...    NRADJNRCELL-1:gnbPlmn:mcc=311
...    NRADJNRCELL-1:gnbPlmn:mnc=489
...    NRADJNRCELL-1:gnbPlmn:mncLength=3
...    NRADJNRCELL-2:cellDepType=SA
...    NRADJNRCELL-2:fiveGsTac=200
...    NRADJNRCELL-2:gNbId=36
...    NRADJNRCELL-2:gNbIdLength=22
...    NRADJNRCELL-2:lcrId=1
...    NRADJNRCELL-2:nrarfcn=135000
...    NRADJNRCELL-2:physCellId=49
...    NRADJNRCELL-2:gnbPlmn:mcc=311
...    NRADJNRCELL-2:gnbPlmn:mnc=489
...    NRADJNRCELL-2:gnbPlmn:mncLength=3
${casl_value}
...    ca_Fr1Tdd_Any_Sa,ca_Fdd_Fr1Tdd_Sa,ca_Fdd_Fr1Tdd_Nsa,ca_Fdd_Fdd,ca_Fr1Tdd_Sa,ca_Fr1Tdd_Nsa,ca_Fr1Tdd_Fdd_Sa
@{CASupportList}
...    NRCELLGRP-0:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-2:numberOfTransmittedSsBlocks=4 beams
...    NRCELLGRP-3:numberOfTransmittedSsBlocks=4 beams
...    NRDU-1:actConnectedModeMobilityCA=true
...    NRDU-1:actInterNumerologyCa=true
...    NRDU-1:flexibleCAMode=ConfigurationIndependent
...    NRDU-1:carrierAggregationSupportList=${casl_value}
@{BCS}
...    NRCELL:allowUnsuppBcOrBcs=accept unknown band combinations
...    NRBTS-1:actMeasBasedSCellAdditionSa=A1-based
...    NRBTS-1:actMeasBasedSCellAdditionNsa=true
...    NRCELL-3:a1MeasSCellAddEnabled=rsrp
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-3:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-4:a1MeasSCellAddEnabled=rsrp
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1HysteresisSCellAddSsbRsrp=0
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpFDD=31
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1ThresholdSCellAddSsbRsrpTDD=111
...    NRCELL-4:a1MeasSCellAddSsbRsrp:a1TimeToTriggerSCellAddSsbRsrp=320ms
...    NRCELL-3/NRREL-1:lcrId=4
...    NRCELL-3/NRREL-1:gNbId=1
...    NRCELL-3/NRREL-1:gNbIdLength=22
...    NRCELL-3/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-3/NRREL-1:removeNotAllowed=false
...    NRCELL-3/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-3/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-3/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-3/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-3/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-3:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-3:drxProfile1:drxLongCycle=80ms
...    NRCELL-3:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-3:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-3:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-3:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-3:drxProfile2:drxLongCycle=40ms
...    NRCELL-3:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-3:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-3:drxProfile2:drxRetransTimerUl=0slot
...    NRCELL-4/NRREL-1:lcrId=3
...    NRCELL-4/NRREL-1:gNbId=1
...    NRCELL-4/NRREL-1:gNbIdLength=22
...    NRCELL-4/NRREL-1:handoverAllowedSA=allowed
...    NRCELL-4/NRREL-1:removeNotAllowed=false
...    NRCELL-4/NRREL-1:sCellAdditionMethod=covBasedA1
...    NRCELL-4/NRREL-1:gnbPlmn:mcc=311
...    NRCELL-4/NRREL-1:gnbPlmn:mnc=489
...    NRCELL-4/NRREL-1:gnbPlmn:mncLength=3
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrpOffset=0dB
...    NRCELL-4/NRREL-1:cellIndividualSsbRsrqOffset=0dB
...    NRCELL-4:drxProfile1:drxInactivityTimer=40ms
...    NRCELL-4:drxProfile1:drxLongCycle=80ms
...    NRCELL-4:drxProfile1:drxOnDurationTimer=10ms
...    NRCELL-4:drxProfile1:drxRetransTimerDl=16slot
...    NRCELL-4:drxProfile1:drxRetransTimerUl=16slot
...    NRCELL-4:drxProfile2:drxInactivityTimer=4ms
...    NRCELL-4:drxProfile2:drxLongCycle=40ms
...    NRCELL-4:drxProfile2:drxOnDurationTimer=6ms
...    NRCELL-4:drxProfile2:drxRetransTimerDl=0slot
...    NRCELL-4:drxProfile2:drxRetransTimerUl=0slot
${active_all_syslogs}    0x10041
${rad_flag_in_gnb}    0x20109
${BSTAT_mcounter_debug}    0x340003
${enable_measurement_new_flag}    0x34000E
${disable_CNI48216}    0x59004D
${soam_fri_1}    0x1003F
${soam_fri_2}    0x10040
@{PARAMS_IN_SWCONFIG}
...    ${active_all_syslogs}=5
...    ${rad_flag_in_gnb}=1
...    ${BSTAT_mcounter_debug}=1
...    ${enable_measurement_new_flag}=55120
...    ${disable_CNI48216}=1
...    ${soam_fri_1}=1
...    ${soam_fri_2}=1
${deploy_L2RT_in_container}    0x420028
${ps_rel}    0x200f0
@{PARAMS_IN_SWCONFIG_AP}
...    ${deploy_L2RT_in_container}=0
...    ${ps_rel}=0
${Capa_NR_UE91}    SEPARATOR=
...    E9A09000575F5A13160003C320016093170019C3D09009B20C39F30C7942C0E098040623807DC6C28C0D608C21A08107482406D6C98AB1A1CF88E3D033EC09
...    F1891C790E7D473E618F28581C0E1E0B801FF800E000BE00088000E0541B107582308682041E2090195B262AC4873EC09F11C78C48E3C873EA39F30C7942C0
...    E070F09FD8000007F600000044000702A8D89BAC1184341020E90480C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17003FF001C00FFC00110
...    001C0AE36236B04610D04083E50480AAD931561439F11C78C00000000000000000018E1E027FFC00001FFF00000110001C00258B89A001C41000E140000000
...    B02B1713400388C001C28000000160401C0468051013602086A01F0144810206C73E044810206C73E000070218C1E8260078005038280381804A00E000C048
...    0080C07C120040000000200000401000000008000010040000100200000C010000080080000500400200802008000060040000380200100000004000040020
...    00024010000060080000A004000058020010240900400006019CA9ACA9AC14AC0CAC19AC15ACA5AC99AC05AC0DAC04AC08AC1DA0682000012CA4A080000CB2
...    9282000052CA48080001CB29202000092CA48080002CB292020000D2CA48080003CB29202000112CA48080004CB29202000152CA48080005CB29282000192C
...    A480800018B292019A55574AAAA9545D2A8AA0B154162A83455298AA4D154062A8145526AAA0F142405E02540A05028140A05028140A05028140A05028140A
...    05000210080100202018030080100220100C01804030060100C01820200401008010043543E00020406080C0E1416181A2022242628303236383A3E424A4C4
...    E5052545A5E828305A
${Capa_LTE_UE91}    SEPARATOR=
...    A11FF80BC8C0C0389A001C41000E1400070A0000000588BF0000000001202340280070106026898002901913A2448103639F0C0C0190000201010020040403
...    0060100200404008011000040202004008080600C3000080404030060100C018040300610000402020040100801004

*** Test Cases ***
CB008001-ET-A013_Verify_BC_Fallback_Accepted_when_UE_report_unknown_interBand3CC_NSA_based
    [Documentation]
    ...    1. The purpose of this case is to test fallback to 2cc CA successfully when UE report unknown 3 bands
    ...       NSA gnb only support TT or FT 2CC CA at currently
    ...       UE 91: support n41(2A)+n66A+n78A(Unknown), supportedBandwidthCombinationSet to BCS0(known)
    ...    2. Test Configuration:
    ...       NRCELL-3(TDD, n41A, 40M)
    ...       NRCELL-3/NRREL-1(cell4: TDD, n41A, 40M)
    ...       NRCELL-4(TDD, n41A, 40M)
    ...       NRCELL-4/NRREL-1(cell3: TDD, n41A, 40M)
    ...    3. Test Case Steps:
    ...       step1. set actBcsCheck=enabled_FR1 and allowUnsuppBcOrBcs=accept unknown band combinations
    ...              Make NSA UE-91 attach to cell 3, start data transfer, check A1 meas config in RRC Reconfig
    ...              Expected Results:A1 meas config in RRC Reconfig
    ...       step2. A1 measurement report based SCell addition is triggered
    ...              Expected Results:Cell4 is added as scell. Cell3+cell4 n41(2A) 2CC CA successful
    ...       step3. Release SA UE-91
    ...              Expected Results:Call release successfully
    ...       step4. Make NSA UE-91 attach to cell 4, start data transfer, check A1 meas config in RRC Reconfig
    ...              Expected Results:A1 meas config in RRC Reconfig
    ...       step5. A1 measurement report based SCell addition is triggered
    ...              Expected Results:Cell3 is added as scell. Cell4+cell3 n41(2A) 2CC CA successful
    ...       step6. Release SA UE-91
    ...              Expected Results:Call release successfully
    [Tags]    QC_134690
    Verify BCS Reported UE Enable BCS    ue_id=91    pcell_id=3    scell_pci=53
    Verify BCS Reported UE Enable BCS    ue_id=91    pcell_id=4    scell_pci=52

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup
    Setup Airphone Env    tl_type=fddtdd_sansa_cmwv/6cells_4T2F    match_string=${EMPTY}    cfg=auto    ue_count=5
    #Debug Enter Into Egate

Modify Cfg
    Update Cfg Param    set_cell id=3 gnb=2 nr_arfcn=518580:518580 gscn=6486
    Update Cfg Param    set_cell id=4 gnb=2 nr_arfcn=508620:508620 gscn=6357
    ${enb1_cmd}=    Catenate    set_enb id=1 plmn=311:489 s1=10.0.1.12 enb_id_macro=0x12346 daemon=10.0.2.1:22222 x2=10.0.1.13 x2u=10.0.1.136
    ...    type=simulated x2_peers=none
    Update Cfg    ${enb1_cmd}
    Update Cfg    enb_param id=1 drb_id_begin=3 endc_capable_qci=9
    Update Cfg    set_cell id=1 enb=1 eci=0x1234601 pci=4:2 tac=222 proxy=10.0.2.1:12219 earfcn=2000:20000
    Update Cfg    enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14
    Update Cfg    ue_param id=91 ue_nr_capabilities=${Capa_NR_UE91} dual_conn=eutra_nr ue_eutra_nr_capabilities=${Capa_LTE_UE91}

Check A1 Meas Config And Scell Addtion
    [Arguments]    ${ue_id}    ${scell_pci}
    ${checkA1measconfig}=    Execute Egate Command    ue_meas_cfg_disp id=${ue_id}    NR REPORT CONFIGURATIONS
    Should Contain Any    ${checkA1measconfig}    EventA1: Threshold: RSRP 31    EventA1: Threshold: RSRP 111
    ${addScell}=    Execute Egate Command      ue_measurement_send_nr id=${ue_id} meas_id=1 event=A1 srsrp_nr=112 srsrq_nr=80
    ...    SCellIndex 9 activated successfully at airphone
    Should Contain    ${addScell}    sCellToAddModList    physCellId ${scell_pci}

Verify BCS Reported UE Enable BCS
    [Arguments]    ${ue_id}    ${pcell_id}    ${scell_pci}
    Execute Egate Command    ue_attach id=${ue_id}    UE IS ACTIVE    timeout=20s
    Execute Egate Command    ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=${pcell_id} bearer=2 type=split_scg
    ...    Successfully reconfigured dual connectivity    timeout=20s
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=dl mbps=5 trf_id=1
    Execute Egate Command    trf_data_start id=2 ue=${ue_id} dir=ul mbps=2 trf_id=2
    Check A1 Meas Config And Scell Addtion    ue_id=${ue_id}    scell_pci=${scell_pci}
    Execute Egate Command    ue_detach id=91    UE IS OFF
