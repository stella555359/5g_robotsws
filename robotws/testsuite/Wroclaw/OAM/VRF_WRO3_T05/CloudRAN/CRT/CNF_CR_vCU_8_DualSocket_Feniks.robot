*** Settings ***
Documentation    Test Suite with automated TC for Dual Socket Feniks TL (CNF_CR_vCU_8).

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/OAMKPI/OAMKPI_CNF_Reset_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_SCF_Activate_vCU.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown
Test Setup        TC Setup    hw_type=vCU+vDU
Test Teardown     TC Teardown

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8782/__init__.py

*** Test Cases ***
OAMKPI CNF Reset vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI CNF Reset vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_1d_26R2_target=540     KPI_1d_26R2_avg_benchmark=358    KPI_1e_26R2_target=480    KPI_1e_26R2_avg_benchmark=133
    ...           KPI_UPUE_26R2_target=120    KPI_UPUE_26R2_avg_benchmark=54
    ...           KPI_1d_26R1_target=540    KPI_1d_26R1_avg_benchmark=387    KPI_1e_26R1_target=480    KPI_1e_26R1_avg_benchmark=177
    ...           KPI_UPUE_26R1_target=120    KPI_UPUE_26R1_avg_benchmark=89
    ...           KPI_1d_25R3_target=540    KPI_1d_25R3_avg_benchmark=540    KPI_1e_25R3_target=480    KPI_1e_25R3_avg_benchmark=480
    ...           KPI_UPUE_25R3_target=120    KPI_UPUE_25R3_avg_benchmark=120

    ${vCU_release}=    Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_1e_target}=     Get From Dictionary    ${targets}    KPI_1e_${vCU_release}_target
    ${KPI_1d_target}=     Get From Dictionary    ${targets}    KPI_1d_${vCU_release}_target
    ${KPI_UPUE_target}=     Get From Dictionary    ${targets}    KPI_UPUE_${vCU_release}_target
    ${KPI_1e_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_1e_${vCU_release}_avg_benchmark
    ${KPI_1d_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_1d_${vCU_release}_avg_benchmark
    ${KPI_UPUE_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_UPUE_${vCU_release}_avg_benchmark

    OAMKPI CNF Reset vCU    test_iterations=2
    ...                     KPI_1e_target=${KPI_1e_target}
    ...                     KPI_1d_target=${KPI_1d_target}
    ...                     KPI_UPUE_target=${KPI_1d_target}
    ...                     KPI_1e_avg_benchmark=${KPI_1e_avg_benchmark}
    ...                     KPI_1d_avg_benchmark=${KPI_1d_avg_benchmark}
    ...                     KPI_UPUE_avg_benchmark=${KPI_UPUE_avg_benchmark}

OAMKPI_SCF_Activate_vCU
    [Setup]      TC Setup
    [Teardown]   TC Teardown     skip_logs_collection=${True}
    [Timeout]    6h
    [Tags]       Trunk
    ${targets}=    Create Dictionary
    ...    KPI_26R2_BTS_target=300    KPI_26R2_E2E_target=320    KPI_26R2_BTS_benchmark=53    KPI_26R2_E2E_benchmark=2.1       26R2_QC_id=277759
    ${KPI_BTS_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_BTS_target
    ${KPI_BTS_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_BTS_benchmark
    ${KPI_E2E_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_E2E_target
    ${KPI_E2E_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_E2E_benchmark
    ${BTS_KPI_avg}    ${E2E_KPI_avg}=    OAMKPI SCF Activate vCU    test_iterations=5    BTS_KPI_target=${KPI_BTS_target}
    ...        E2E_KPI_target=${KPI_E2E_target}    BTS_KPI_benchmark=${KPI_BTS_benchmark}    E2E_KPI_benchmark=${KPI_E2E_benchmark}
    Report KPI result to QC    name=KPI_BTS    value=${BTS_KPI_avg}    target=${KPI_BTS_target}
    Report KPI result to QC    name=KPI_E2E    value=${E2E_KPI_avg}    target=${KPI_E2E_target}
