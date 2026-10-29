*** Settings ***
Force Tags    PY36
Documentation      Author: lei.jia@nokia-sbell.com
Suite Setup        8247 Suite Setup
Suite Teardown    8247 Suite TearDown
Resource     ../Resources/CB008247_case_steps.robot
*** Variables ***
${tddpcell_index}             ${3}
${fddcell_index}              ${1}
@{btslog_dirs}        /opt/btslog     /opt/ute/tools/btslog

*** Test Cases ***
#[1]CB008247-A_Beam_Switch_with_DFT_beams_got_from_TAS_used_for_DL_and_UL_follow_P-SRS
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  Check beam switch works well when 1086 + 8247 on. DL: TAS SRS, UL: Codebook P-SRS
#    ...                  actCDrx=false for 8247-A/B, non-CA
#    ...                  UE: SDX60, chbw:40M, SA CALL
#    ...                  MCS PORT: 5/6/7/8
#    [Tags]     CRT_22R3    CRT_22R4    CRT_23R1
#    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
#    CB008247-A_Beam_Switch_with_DFT_beams_got_from_TAS_used_for_DL_and_UL_follow_P-SRS
#    [Teardown]    8247 Case TearDown
#
#[1]CB008247-A_Traffic_DFT_beams_got_from_TAS_used_for_PDCCH_PDSCH_UE-specific-CSI-RS_with_UL_follow_AP-SRS
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  1086 off, 8247 on. TAS is used for DL , GOB beam is used for UL.
#    ...                  update 2023.04.25: add cni92005 param muteLastSymbolInSsbSlot
#    ...                  actCDrx=false for 8247-A/B, non-CA
#    ...                  UE: SDX60, chbw:40M, SA CALL
#    ...                  MCS PORT: 5/6/7/8
#    [Tags]     CRT_22R3    CRT_22R4
#    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
#    CB008247-A_Traffic_DFT_beams_got_from_TAS_used_for_PDCCH_PDSCH_UE-specific-CSI-RS_with_UL_follow_AP-SRS
#    [Teardown]    Run Keywords    Modify Paras via SCF    parameters_to_update=${MODIFY_PARA_1086_on_8247_on_cni92005_off}    AND
#                   ...    8247 Case TearDown
#
#[1]CB008247-A_DL_follow_legacyGoB_with_actUlSrsBm-disable_actDlSrsBm-enable_but_UE_incapable_of_TAS
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  Check beam switch works well when 1086 off + 8247 on, while ue incapable of TAS. DL/UL: GoB beam
#    ...                  actCDrx=false for 8247-A/B, non-CA
#    ...                  UE: MTK, chbw:40M, NSA CALL
#    ...                  MCS PORT: 9/10/11/12
#    [Tags]     CRT_22R3    CRT_22R4
#    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
#    CB008247-A_DL_follow_legacyGoB_with_actUlSrsBm-disable_actDlSrsBm-enable_but_UE_incapable_of_TAS
#    [Teardown]    Run Keywords    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_1086_on_8247_on}    AND
#                   ...    8247 Case TearDown    ue_index=${1}

[1]CB008247-5G-B_B2_004_Check_best_and_second_used_DL_SRS_beams_with_TAS_incapable_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Check DL/UL beam works well when 1086 + 8247 +2200 on, while ue incapable of TAS. for 2200, maxCsirsNumber=4.
    ...                  actCDrx=false for 8247-A/B, non-CA
    ...                  DL/UL:Codebook P-SRS, 4 cell specific CSIRS
    ...                  UE: MTK, chbw:40M, NSA CALL
    ...                  MCS PORT: 9/10/11/12
    [Tags]    CRT_TRUNK    CRT_24R3    CRT_25R1    CRT_25R2
    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
    B2_004_Check_best_and_second_used_DL_SRS_beams_with_TAS_incapable_UE
    [Teardown]    8247 Case TearDown

#[1][1.0] CB008247-5G-B_B2_001_Check_best_and_second_used_DL_SRS_beams_with_4CSIRS
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  Check the best and seconde best SRS beam works well when 1086 + 8247 +2200 on. for 2200, maxCsirsNumber=4.
#    ...                  actCDrx=false for 8247-A/B, non-CA
#    ...                  NIDD para actUeCsirsCoexistCellCsirs: true for ue-specific CSIRS, false for cell-specific CSIRS
#    ...                  DL: TAS SRS, UL: Codebook P-SRS, 4 cell specific CSIRS
#    ...                  UE: QC, chbw:40M, SA CALL
#    ...                  MCS PORT: 5/6/7/8
#    [Tags]     CRT_22R3    CRT_22R4
#    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
#    B2_001_Check_best_and_second_used_DL_SRS_beams_with_4CSIRS
#    [Teardown]    8247 Case TearDown
#
#[1]CB008247-5G-B_B3_007_Check_used_beam_when_period_SRS_resource_exhaused_with_8247_1086_2200_enabled
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  Check PMI beam works well when 1086 + 8247 +2200 on, however P-SRS resource exhaused.
#    ...                  DL: PMI beam, UL: Codebook AP-SRS, 4 cell specific CSIRS
#    ...                  actCDrx=false for 8247-A/B, non-CA
#    ...                  UE: QC, chbw:40M, SA CALL
#    ...                  MCS PORT: 5/6/7/8
#    [Tags]     CRT_22R3    CRT_22R4
#    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
#    B3_007_Check_used_beam_when_period_SRS_resource_exhaused_with_8247_1086_2200_enabled
#    [Teardown]    Run Keywords    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_1086_on_8247_on_2200_on}    AND
#    ...                            8247 Case TearDown    swconfig_modify=${SWCONFIG_SRS_exhuased}

[1]8247_W_06_Single_UE_Stationary_Performance_8x4_Good_Medium_Worse_15_Points_On_VS_OFF_AWGN_TAS_SRS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  This user scenario validates the Single UE average 5G DL Throughput Performance for 1086 + 8247 +2200 on.
    ...                  actCDrx=false for 8247-A/B, non-CA.
    ...                  NIDD para actUeCsirsCoexistCellCsirs: true for ue-specific CSIRS, false for cell-specific CSIRS
    ...                  DL: TAS SRS, UL: Codebook P-SRS, 4 cell specific CSIRS
    ...                  UE: QC, chbw:40M, SA CALL
    ...                  MCS PORT: 5/6/7/8
    [Tags]     CRT_24R3    CRT_TRUNK    CRT_25R1    CRT_25R2
    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}
    W06_Single_UE_Stationary_Performance_8x4_Good_Medium_Worse_15_Points_On_VS_OFF_AWGN_TAS_SRS
    [Teardown]    8247 Case TearDown

[1]CB008247-D_05_IWK_with_DL_TT_CA_Multi_UE_with_TAS_Capable_CA_SA_UE_and_No_TAS_capable_non-CA_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Check the best and seconde best SRS beam works well when 1086 + 8247 +2200 on. for 2200, maxCsirsNumber=4.
    ...                  actUeCsirsCoexistCellCsirs=false/true, 1086 on, 8247 on, actcdrx=on ,dlmimomode=8X4 for pcell 301
    ...                  1. first, 40M+40M CA, set actUeCsirsCoexistCellCsirs=false for cell-specific CSIRS
    ...                  pcellDL: TAS SRS, pcellUL: Codebook P-SRS, scellDL: PMI beam, 4 cell specific CSIRS,
    ...                  2. second: 100M+40M ca, set actUeCsirsCoexistCellCsirs=true for ue-specific CSIRS
    ...                  pcellDL: TAS SRS, pcellUL: Codebook P-SRS, scellDL: PMI beam, 4 ue specific CSIRS,
    ...                  UE: QC, chbw:40M, SA CALL
    ...                  MCS PORT: 5/6/7/8
    [Tags]     CIT_24R3    CIT_TRUNK    CRT_24R2    CRT_25R1    CRT_25R2
    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}    scf_name=SCF_${stream}_CA.xml
    CB008247-D_05_IWK_with_DL_TT_CA_Multi_UE_with_TAS_Capable_CA_SA_UE_and_No_TAS_capable_non-CA_UE
    [Teardown]    Run Keywords    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_uespecific_true_8247_on_1086_on}    AND
    ...                           8247 Case TearDown

#[1]CB008247-D_08_IWK_with_DL_TF_CA_Single_UE_CSI-RS_reconfiguration_due_to_TAS_capability_change
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  actUeCsirsCoexistCellCsirs=true, 1086 off, cb8247 on, actcdrx=off ,dlmimomode=8X4 for TDD Pcell 301
#    ...                  Check The CSI-RS will be reconfigured from UE specific CSI-RS&TAS SRS to Cell specific CSI-RS&PMI beam
#    ...                        when T+F CA is used and no codebook p-SRS is available.
#    ...                  1. Before covBasedA1 Scell addition: TAS SRS + UE specific CSI-RS.
#    ...                     T+F CA with A1 Scell addition, CDRX=off, 1086=off, cb8247=on, actUeCsirsCoexistCellCsirs=true,
#    ...                     dlMimoMode=8x4 Closed Loop Spatial Multiplexing.    MCS angle[-7,-6],[-22,-6]
#    ...                  2. After covBasedA1 scell addition UE is reconfigured to
#    ...                     Cell specific CSI-RS + PMI beam(no TAS capability and no codebook p-SRS)
#    ...                  pcellDL: PMI beam, pcellUL: AP-SRS, scellDL: SSB, 4 cell specific CSIRS
#    ...                  3. update: 20220704 add T+F blind scell addition scenario
#    ...                  T+F CA with blind Scell addition, CDRX=on, 1086=on, cb8247=on, actUeCsirsCoexistCellCsirs=true,
#    ...                  dlMimoMode=8x4 Closed Loop Spatial Multiplexing.    MCS angle[7,6],[22,6]
#    ...                  Check point: 1) p4 CSIRS in rrc reconfiguration  2) T+F CA throughput is expected
#    ...                               3) No RRC Re-establishment msg during the test
#    ...                  UE: QC, chbw:40M, SA CALL
#    ...                  MCS PORT: 5/6/7/8
#    [Tags]     CRT_22R3    CRT_22R4    CRT_23R1    CRT_23R2    CRT_23R3    CRT_23R4
#    [Setup]    8247 Case SetUp    cell_id_assigned=${tddpcell_index}    scf_name=SCF_${stream}_CA.xml
#    CB008247-D_08_IWK_with_DL_TF_CA_Single_UE_CSI-RS_reconfiguration_due_to_TAS_capability_change    fddcell_index=${fddcell_index}
#    [Teardown]    Run Keywords    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_uespecific_true_8247_on_1086_on}    AND
#    ...                           8247 Case TearDown
#
#[1]CB008247-D_09_IWK_with_DL_FT_CA_To_TF_CA_Single_UE_with_PCell_Switch
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  actUeCsirsCoexistCellCsirs=true, 1086 on, 8247 on, actcdrx=on ,dlmimomode=8X4 for pcell 301
#    ...                  Check A1 based Pcell switch,F(pcell: cell1)+T(scell: cell301) -> T(pcell: cell301)+F(scell: cell1)
#    ...                  Pcell change based on A1, increase scell RSRP to trigger (scell rsrp larger than a1ThresholdPCellSwitchSsbRsrp)
#    ...                  UE: QC, chbw:40M, SA CALL
#    ...                  MCS PORT: 5/6/7/8
#    [Tags]     CRT_22R3    CRT_22R4    CRT_23R1    CRT_23R2
#    [Setup]    8247 Case SetUp    cell_id_assigned=${fddcell_index}    scf_name=SCF_${stream}_CA.xml
#    CB008247-D_09_IWK_with_DL_FT_CA_To_TF_CA_Single_UE_with_PCell_Switch    fddcell_index=${fddcell_index}    tddpcell_index=${tddpcell_index}
#    [Teardown]    Run Keywords    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_uespecific_true_8247_on_1086_on}    AND
#    ...                           8247 Case TearDown
#
