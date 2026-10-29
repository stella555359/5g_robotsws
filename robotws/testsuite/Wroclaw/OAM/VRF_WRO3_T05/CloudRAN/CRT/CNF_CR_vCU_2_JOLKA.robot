*** Settings ***
Documentation    Test Suite with automated TC for Jolka TL (CNF_CR_vCU_2).

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/OAMKPI/OAMKPI_CNF_Cluster_Reset.robot
Resource    ../Tests/OAMKPI/OAMKPI_CNF_Installation_Deletion_NMS_vCU.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown
Test Setup        TC Setup    hw_type=vCU+vDU
Test Teardown     TC Teardown

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8778/__init__.py
*** Test Cases ***
OAMKPI CNF Cluster Reset
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI CNF Cluster Reset
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257    CB013369
    ${targets}    Create Dictionary
    ...           KPI_26R1_target=810
    ...           KPI_26R1_avg_benchmark=635
    ...           KPI_25R3_target=810
    ...           KPI_25R3_avg_benchmark=635

    ${vCU_release}=           Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_target}=            Get From Dictionary    ${targets}    KPI_${vCU_release}_target
    ${KPI_avg_benchmark}=     Get From Dictionary    ${targets}    KPI_${vCU_release}_avg_benchmark


    OAMKPI CNF Cluster Reset   test_iterations=1
    ...                        KPI_target=${KPI_target}
    ...                        KPI_avg_benchmark=${KPI_avg_benchmark}
