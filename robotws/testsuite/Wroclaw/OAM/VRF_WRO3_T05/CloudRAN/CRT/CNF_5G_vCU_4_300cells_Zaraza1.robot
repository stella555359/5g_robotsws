*** Settings ***
Documentation    Test Suite with automated TC for Zaraza TL (CNF_5G_vCU_1600CELLS_OAM_TEST_06).

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/OAMKPI/OAMKPI_Cell_Lock_Unlock_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_CNF_Reset_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_SCF_Upload_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_SCF_Validate_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_SCF_Activate_vCU.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown

Test Setup    TC Setup    hw_type=vCU+vDU
Test Teardown    TC Teardown

#Force Tags    QCP_RAN_ST    QCD_MN_RAN    4G_TDD    CRT
*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8528/__init__.py
${VCU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8528/vCU/Trunk/44UPUE/Zaraza1_100VDU_100CELL_30GNB_1000NRREL_44IPSEC.xml
${VDU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8528/vDU/Trunk/44UPUE/Zaraza1_VDU_config_44IPSEC.xml

*** Test Cases ***
OAMKPI Cell Lock Unlock vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Cell Lock Unlock vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    12h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_16a_26R2_target=7.5
    ...           KPI_16b_26R2_target=8
    ...           KPI_16a_26R1_target=7.5
    ...           KPI_16b_26R1_target=8
    ...           KPI_16a_25R3_target=15
    ...           KPI_16a_25R2_target=8
    ...           KPI_16b_25R3_target=19
    ...           KPI_16b_25R2_target=8.5
    ...           KPI_16a_25R1_target=10
    ...           KPI_16b_25R1_target=10
    ${vCU_release}=    Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_16a_target}     Get From Dictionary    ${targets}    KPI_16a_${vCU_release}_target
    ${KPI_16b_target}     Get From Dictionary    ${targets}    KPI_16b_${vCU_release}_target

    OAMKPI Cell Lock Unlock vCU    test_iterations=50
    ...                            KPI_16a_target=${KPI_16a_target}
    ...                            KPI_16b_target=${KPI_16b_target}

OAMKPI CNF Reset vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI CNF Reset vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_1d_26R2_target=540    KPI_1d_26R2_avg_benchmark=175    KPI_1e_26R2_target=480    KPI_1e_26R2_avg_benchmark=136
    ...           KPI_UPUE_26R2_target=120    KPI_UPUE_26R2_avg_benchmark=53
    ...           KPI_1d_26R1_target=540    KPI_1d_26R1_avg_benchmark=175    KPI_1e_26R1_target=480    KPI_1e_26R1_avg_benchmark=149
    ...           KPI_UPUE_26R1_target=120    KPI_UPUE_26R1_avg_benchmark=53.3

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

OAMKPI_SCF_Upload_vCU
    [Setup]      TC Setup    watchdog_enabled=${True}
    [Teardown]   TC Teardown     skip_logs_collection=${True}
    [Timeout]    3h
    [Tags]       Trunk    Branch
    ${targets}=    Create Dictionary
    ...            KPI_26R2_BTS_target=35    KPI_26R2_E2E_target=55    KPI_26R2_BTS_benchmark=3.9    KPI_26R2_E2E_benchmark=4       26R2_QC_id=277281
    ...            KPI_26R1_BTS_target=35    KPI_26R1_E2E_target=55    KPI_26R1_BTS_benchmark=3.9    KPI_26R1_E2E_benchmark=18.4    26R1_QC_id=260323
    ${KPI_BTS_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_BTS_target
    ${KPI_BTS_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_BTS_benchmark
    ${KPI_E2E_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_E2E_target
    ${KPI_E2E_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_E2E_benchmark
    ${BTS_KPI_avg}    ${E2E_KPI_avg}=    OAMKPI SCF Upload vCU    test_iterations=10    BTS_KPI_target=${KPI_BTS_target}
    ...        E2E_KPI_target=${KPI_E2E_target}    BTS_KPI_benchmark=${KPI_BTS_benchmark}    E2E_KPI_benchmark=${KPI_E2E_benchmark}
    Report KPI result to QC    name=KPI_BTS    value=${BTS_KPI_avg}    target=${KPI_BTS_target}
    Report KPI result to QC    name=KPI_E2E    value=${E2E_KPI_avg}    target=${KPI_E2E_target}

OAMKPI_SCF_Validate_vCU
   [Setup]      TC Setup    watchdog_enabled=${True}
   [Teardown]   TC Teardown     skip_logs_collection=${True}
   [Timeout]    3h
   [Tags]       Trunk
   ${targets}=    Create Dictionary
   ...            KPI_26R2_BTS_target=35    KPI_26R2_E2E_target=55    KPI_26R2_BTS_benchmark=3.9    KPI_26R2_E2E_benchmark=4       26R2_QC_id=277283
   ...            KPI_26R1_BTS_target=35    KPI_26R1_E2E_target=55    KPI_26R1_BTS_benchmark=3.9    KPI_26R1_E2E_benchmark=18.4    26R1_QC_id=None
   ${KPI_BTS_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vDU][release]_BTS_target
   ${KPI_BTS_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vDU][release]_BTS_benchmark
   ${KPI_E2E_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vDU][release]_E2E_target
   ${KPI_E2E_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vDU][release]_E2E_benchmark
   ${BTS_KPI_avg}    ${E2E_KPI_avg}=    OAMKPI SCF Upload vCU    test_iterations=10    BTS_KPI_target=${KPI_BTS_target}
   ...        E2E_KPI_target=${KPI_E2E_target}    BTS_KPI_benchmark=${KPI_BTS_benchmark}    E2E_KPI_benchmark=${KPI_E2E_benchmark}
   Report KPI result to QC    name=KPI_BTS    value=${BTS_KPI_avg}    target=${KPI_BTS_target}
   Report KPI result to QC    name=KPI_E2E    value=${E2E_KPI_avg}    target=${KPI_E2E_target}

OAMKPI_SCF_Activate_vCU
    [Setup]      TC Setup
    [Teardown]   TC Teardown     skip_logs_collection=${True}
    [Timeout]    6h
    [Tags]       Trunk
    ${targets}=    Create Dictionary
    ...    KPI_26R2_BTS_target=300    KPI_26R2_E2E_target=320    KPI_26R2_BTS_benchmark=53.0    KPI_26R2_E2E_benchmark=2.1       26R2_QC_id=277282
    ...    KPI_26R1_BTS_target=300    KPI_26R1_E2E_target=320    KPI_26R1_BTS_benchmark=88.3    KPI_26R1_E2E_benchmark=9.1       26R1_QC_id=260322
    ${KPI_BTS_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_BTS_target
    ${KPI_BTS_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_BTS_benchmark
    ${KPI_E2E_target}=       Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_E2E_target
    ${KPI_E2E_benchmark}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vCU][release]_E2E_benchmark
    ${BTS_KPI_avg}    ${E2E_KPI_avg}=    OAMKPI SCF Activate vCU    test_iterations=5    BTS_KPI_target=${KPI_BTS_target}
    ...        E2E_KPI_target=${KPI_E2E_target}    BTS_KPI_benchmark=${KPI_BTS_benchmark}    E2E_KPI_benchmark=${KPI_E2E_benchmark}
    Report KPI result to QC    name=KPI_BTS    value=${BTS_KPI_avg}    target=${KPI_BTS_target}
    Report KPI result to QC    name=KPI_E2E    value=${E2E_KPI_avg}    target=${KPI_E2E_target}
