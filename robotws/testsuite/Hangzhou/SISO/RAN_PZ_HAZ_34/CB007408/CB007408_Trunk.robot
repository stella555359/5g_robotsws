*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ./Resources/CB007408_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006502_CB007833/Resources/CB006502_Keywords.robot
Variables    ./TestData/variables_7408.py


Documentation
...    Author: Melinda
...    Contact: meinda.gao@nokia-sbell.com
...    squad group:SG_08
...    Feature CB007408 AENB eCPRI

Force Tags    CRT_TRUNK    CRT_24R1    CRT_23R4    CRT_23R3
...    PY36

*** Variables ***
@{band1}    40M
@{band2}    60M
@{band3}    80M
*** Test Cases ***
#[1]General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_60M
#    [Tags]    CRT_TRUNK    CRT_22R2
#    Commission SCF With Specific Band If Needed    band=${band2}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
#    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command    enable_2197=${False}
#
#[1][2.0] General_SiSo_RF_module_power_reset
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_RF_module_power_reset

#[1][2.0] General_SiSo_BTS_startup_with_RF_delayed_startup
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_BTS_startup_with_RF_delayed_startup
#
#[1][1.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_80M
    [Tags]    CRT_TRUNK    CRT_22R2
    7408_dataTransfer_80M
#    Commission SCF With Specific Band If Needed    band=${band3}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
#    General_SiSo_Peak_with_Given_Information    band=80    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command    enable_2197=${False}

# band=40M
#[1]General_SiSo_NR-ARFCN_check_40M
#    [Tags]    CRT_TRUNK    CRT_22R2
#    Commission SCF With Specific Band If Needed    band=${band1}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
#    General_SiSo_NR-ARFCN_check
#
## band=60M
#[1]General_SiSo_NR-ARFCN_check_60M
#    [Tags]    CRT_TRUNK    CRT_22R2
#    Commission SCF With Specific Band If Needed    band=${band2}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
#    General_SiSo_NR-ARFCN_check
#
## band=80M
#[1]General_SiSo_NR-ARFCN_check_80M
#    [Tags]    CRT_TRUNK    CRT_22R2
#    Commission SCF With Specific Band If Needed    band=${band3}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
#    General_SiSo_NR-ARFCN_check

#[1]CB007408_AENB_eCPRI_256_QAM_for_PUSCH_Feature_Activation
#    [Tags]    CRT_TRUNK    CRT_22R2
#    eCPRI_256_QAM_for_PUSCH_Feature_Activation

#[1][2.0] General_SiSo_RF_alarms_with_recovery
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_RF_alarms_with_recovery

#[1][1.0] General_SiSo_RF_alarms_without_recovery
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_RF_alarms_without_recovery

#[1][1.0] General_SiSo_RU_lock_unlock
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_RU_lock_unlock
#
#[1][1.0] General_SiSo_Cell_lock_and_unlock
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_Cell_lock_and_unlock
#
#[1]General_SiSo_Auto_E2E_system_setup_with_data_transfer_conducted_40M
#    [Tags]    CRT_TRUNK    CRT_22R2
#    Commission SCF With Specific Band If Needed    band=${band1}
#    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
#    General_SiSo_Peak_with_Given_Information    band=40    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command    enable_2197=${False}

#[1]General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements
#    [Tags]    CRT_TRUNK    CRT_22R2
#    General_SiSo_BTS_(Q)SFP+SFP28_provisioning_enhancements    SFP_1=RF7    QSFP_1=RF1

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    CB009359_Manual_SiSo_SM_RF_Module_lock_unlock

#[1][2.1] General_SiSo_Cell_block_and_unblock
#    CB009359-SR-S_General_SiSo_Cell_block_and_unblock

[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    CB009359-SR-T_Manual_SiSo_SM_NR RAT reset

*** Keywords ***
