*** Settings ***
Documentation    New Test Suite with automated TC for Diuna TL (config).

Resource    ../Resources/cloud_frame.robot
#Resource    ../Tests/OAMKPI/OAMKPI_Snapshot_Manual_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_CNF_Reset_vDU.robot


Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown

Test Setup       TC Setup    hw_type=vCU+vDU
Test Teardown    TC Teardown

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8699/__init__.py
${VCU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8699/vCU/Trunk/SCF_vCU_TRUNK.xml
${VDU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8699/vDU/Trunk/SCF_vDU_TRUNK.xml

*** Test Cases ***
#OAMKPI Snapshot Manual vCU
#    [Setup]    Run Keywords
#    ...    Set Library Search Order    OAMKPI Snapshot Manual vCU
#    ...    AND    TC Setup    hw_type=vCU+vDU
#    [Timeout]    240min
#    [Tags]       RF50    CB011085_C
#    OAMKPI Snapshot Manual vCU     test_iterations=3
#    ...                            KPI_BTS_target=10
#    ...                            KPI_E2E_target=25
#    [Teardown]    Run Keywords    TC Teardown

OAMKPI CNF Reset vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI CNF Reset vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_52a_TDD_26R1_target=450
    ...           KPI_52a_TDD_26R1_avg_benchmark=331
    ...           KPI_52b_TDD_26R1_target=420
    ...           KPI_52b_TDD_26R1_avg_benchmark=303
    ...           KPI_52a_FDD_26R1_target=300
    ...           KPI_52a_FDD_26R1_avg_benchmark=311
    ...           KPI_52b_FDD_26R1_target=270
    ...           KPI_52b_FDD_26R1_avg_benchmark=251
    ...           KPI_52a_MIX_26R1_target=750
    ...           KPI_52a_MIX_26R1_avg_benchmark=300
    ...           KPI_52b_MIX_26R1_target=720
    ...           KPI_52b_MIX_26R1_avg_benchmark=300
    ...           KPI_52a_TDD_25R3_target=450
    ...           KPI_52a_TDD_25R3_avg_benchmark=450
    ...           KPI_52b_TDD_25R3_target=420
    ...           KPI_52b_TDD_25R3_avg_benchmark=420
    ...           KPI_52a_FDD_25R3_target=300
    ...           KPI_52a_FDD_25R3_avg_benchmark=540
    ...           KPI_52b_FDD_25R3_target=270
    ...           KPI_52b_FDD_25R3_avg_benchmark=510
    ...           KPI_52a_MIX_25R3_target=750
    ...           KPI_52a_MIX_25R3_avg_benchmark=750
    ...           KPI_52b_MIX_25R3_target=720
    ...           KPI_52b_MIX_25R3_avg_benchmark=720

    OAMKPI CNF Reset vDU    test_iterations=10
    ...                     targets=${targets}
