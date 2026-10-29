*** Settings ***
Documentation    Suite description
...    author: lixia.tang
...    contact: lixia.tang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    feature : 5GC002056-BGAN_5GC001856-M_5GC001856-P

Force Tags            RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASIBL_ABIOB1_AEQN_ENB
...    PY36
...      SBTS00   SBTS22R1   SBTS22R2   CRT_UTE
Suite Setup         Run Keyword And Ignore Error       5GC001856_Common Suite Setup for COAM
Suite Teardown      Run Keyword And Ignore Error       5GC001856_Common Suite Teardown for COAM
Test Timeout      270 minutes

Library     OperatingSystem
Library     XML   use_lxml=True    WITH NAME    myxml
Library     taf.config.scf    WITH NAME    scf
Resource    Resources/5GC002056-BGAN_5GC001856_cOAM_Common_Keywords_Trunk.robot

*** Test Cases ***
[1]5GC002056-BGAN_5GC001856_M-P_001_CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_80MHz
    [Documentation]    This test case is used to check that 5gNB schedules CSI-RS transmissions and schedules PDSCH
    ...                transmissions with adaptive rank/MCS/PMI in 256QAM
    [Tags]    HAZ3_T03
    [Setup]     case set up
    CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_80MHz
    [Teardown]      Run Keyword And Ignore Error     Tests Recover for NSA

[1]5GC002056-BGAN_5GC001856_S-T_004_CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_port_selection_with_Wcsirs_is_not_Identity
    [Documentation]    This test case is used to check the Close Loop Rank 4 Tput in 256QAM when the port selection
    ...                is activated and Wcsirs is not Identity.
    [Tags]    HAZ3_T03
    [Setup]     case set up
    CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_port_selection_with_Wcsirs_is_not_Identity_100MHz
    [Teardown]      Run Keyword And Ignore Error     Tests Recover for NSA

[1]5GC002056-BGAN_5GC001856_L-O_005_PM_Counter_M55301C10003_check_PDSCH_transmissions_using_4TX_transmission_with_rank3
    [Documentation]    This test case is used to check the PM counter of PDSCH transmissions using 4TX transmission with rank 3
    [Tags]    HAZ3_T03
    [Setup]     case set up
    PM_Counter_M55301C10003_check_PDSCH_transmissions_using_4TX_transmission_with_rank3_100MHz
    [Teardown]      Run Keyword And Ignore Error     Tests Recover for NSA

[1]5GC002056-BGAN_5GC001856_R_009_CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_60MHz
    [Documentation]    This test case is used to check that the 5gNB schedules CSI-RS transmissions and schedules PDSCH
    ...                transmissions with adaptive rank/MCS/PMI in 256QAM in SA mode.
    [Tags]    HAZ3_T03
    [Setup]     case set up
    CL_C4_Adaptive_Rank_PDSCH_Adaptive_PMI_Link_Adaptation_256QAM_Ideal_Radio_60MHz
    [Teardown]      Run Keyword And Ignore Error     Tests Recover for SA

[1]5GC002056-BGAN_5GC001856_R_010_CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_no_port_selection_with_Wcsirs_is_not_Identity
    [Documentation]    This test case is used to check the Close Loop Rank 4 Tput in 256QAM when the port selection is
    ...                deactivated and Wcsirs is not Identity in SA mode.
    [Setup]     case set up
    [Tags]    HAZ3_T03
    CL_Rank_4_DL_4x4_MIMO_PDSCH_transmission_256QAM_with_no_port_selection_with_Wcsirs_is_not_Identity_100MHz
    [Teardown]      Run Keyword And Ignore Error     Tests Recover for SA

[1]5GC002056-BHAV_5GC000605_001_Message_flow_for_dl_4T4R_SU_MIMO_with_beamforming_open_loop_SA
    [Documentation]    This test case is used to verify that the configuration for dlMimoMode and beamforming are aligned
    ...                with 5GC00605 via checking message DlCell_SetupReq and DlData_PdschSendReq.
    [Tags]    HAZ3_T03
    [Setup]     case set up
    Message_flow_for_dl_4T4R_SU_MIMO_with_beamforming_open_loop_SA_100MHz
    [Teardown]      Run Keyword And Ignore Error     Tests Recover for SA

[1][1.0] CB005956_5G_A_101_Verify fault 7324 should be raised when LTE objects more than maxNumX2Links
    [Documentation]    The purpose of this test is to check fault 7324 should be raised when LTE objects more than maxNumX2Links
    [Tags]    HAZ3_T03
    [Setup]     case set up
    wait until keyword succeeds   60x   10s    Connect to DU via ssl
    Modify Paras to enable feature
    Check Fault 7324 Raise
    [Teardown]        case teardown CB005956

