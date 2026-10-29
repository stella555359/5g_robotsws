*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         120 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    ${BASIC_PATH_5G}/BTS/Manual_SiSo_SM_NR_RAT_reset.robot
Resource    ${BASIC_PATH_5G}/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource    ${BASIC_PATH_5G}/E2E_SiSo_RU_lock_and_unlock_gNB.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009576_SG05/resource/CB009576_common_resource.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB006277/CB006277-PhaseE/Resources/CB006277_common_keywords.robot
Documentation
...    Author: Liu Yue
...    Contact: yue.2.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB009576 in 5G24R3 program

Force Tags    RAN_5G_TDD
...    PY36


*** Test Cases ***
[1]CB009576-SR-H_RAT_Reset_from_WebEM
    [Tags]    CRT_TRUNK
    Manual_SiSo_SM_NR_RAT_reset    with_call=${True}
[1][1.0] CB009576_RF_lock_unlock
    [Tags]    CRT_TRUNK
    E2E_SiSo_RU_lock_and_unlock_gNB

[1][1.0] CB009576_Cell_lock_unlock
    [Tags]    CRT_TRUNK
    E2E_SiSo_Cell_block_and_unblock_gNB    with_peak=${True}
[1]CB009576-SR-EB_5G-L2-HI_Component_Trace_Streaming
    [Tags]    CRT_TRUNK
    #${cell_list}    create list    ${1}
    ${ue_list}    create list    ${0}
    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_list}
    #Capture 5G-L2-HI component trace
    Check Snapshot Log Files
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_list}
[1]CB009576-SR-EB_5G-L2-LO_Component_Trace_Streaming
    [Tags]    CRT_TRUNK
    #${cell_list}    create list    ${1}
    ${ue_list}    create list    ${0}
    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_list}
    Capture 5G-L2-LO component trace
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_list}

[1]CB009576-SR-EB_5G-L2-PS_Component_Trace_Streaming
    [Tags]    CRT_TRUNK
    #${cell_list}    create list    ${1}
    ${ue_list}    create list    ${0}
    Ue Attach and Start DL UL Traffic    ue_index_list=${ue_list}
    Capture 5G-L2-PS component trace
    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_list}
[1]CB009576-SR-FA_Activation_of_Energy_Consumption_Measurement_collection_via_WebEM
    [Tags]    CRT_TRUNK
    Activation_of_Energy_Consumption_Measurement_collection_via_WebEM
[1]CB009576-SR-L-CB010764_PRACH_noise_power_real_estimate_reported
    [Tags]    CRT_TRUNK
    CB009576-SR-L-CB010764_PRACH_noise_power_real_estimate_reported
