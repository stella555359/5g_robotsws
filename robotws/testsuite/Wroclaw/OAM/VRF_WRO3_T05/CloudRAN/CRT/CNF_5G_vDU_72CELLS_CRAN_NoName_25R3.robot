*** Settings ***
Documentation    Test Suite with automated TC for CRAN TL (CNF_5G_CRAN_vDU_72CELLS).

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/OAMKPI/OAMKPI_Cell_Block_Unblock_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown

Test Setup       TC Setup    hw_type=vCU+vDU
Test Teardown    TC Teardown

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8886/__init__.py
${VCU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8886/vCU/25R3/Configuration_scf_MRBTS-8886_vCU_8886_72_cells.xml
${VDU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8886/vDU/25R3/Configuration_scf_MRBTS-8886_vDU_8886_72_cells.xml

*** Test Cases ***
OAMKPI Cell Block Unblock vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Cell Block Unblock vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    12h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_17a_26R2_target=20
    ...           KPI_17b_26R2_target=20
    ...           KPI_17a_26R1_target=20
    ...           KPI_17b_26R1_target=20
    ${vDU_release}=    Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_17a_target}     Get From Dictionary    ${targets}    KPI_17a_${vDU_release}_target
    ${KPI_17b_target}     Get From Dictionary    ${targets}    KPI_17b_${vDU_release}_target
    ${KPI_17a_benchmark}     Get From Dictionary    ${targets}    KPI_17a_${vDU_release}_benchmark
    ${KPI_17b_benchmark}     Get From Dictionary    ${targets}    KPI_17b_${vDU_release}_benchmark

    OAMKPI Cell Block Unblock vDU    test_iterations=3
    ...                              KPI_17a_target=${KPI_17a_target}
    ...                              KPI_17b_target=${KPI_17b_target}
    ...                              KPI_17a_benchmark=${KPI_17a_benchmark}
    ...                              KPI_17b_benchmark=${KPI_17b_benchmark}

OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    12h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           UP_TO_500MB_26R2_BTS_target=600
    ...           UP_TO_1GB_26R2_BTS_target=900
    ...           UP_TO_2GB_26R2_BTS_target=1200
    ...           UPLOAD_TO_NMS_26R2_target=1500
    ...           UP_TO_500MB_26R1_BTS_target=600
    ...           UP_TO_1GB_26R1_BTS_target=900
    ...           UP_TO_2GB_26R1_BTS_target=1200
    ...           UPLOAD_TO_NMS_26R1_target=1500
    ${vDU_release}=                Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_UP_TO_500MB_target}      Get From Dictionary    ${targets}    UP_TO_500MB_${vDU_release}_BTS_target
    ${KPI_UP_TO_1GB_target}        Get From Dictionary    ${targets}    UP_TO_1GB_${vDU_release}_BTS_target
    ${KPI_UP_TO_2GB_target}        Get From Dictionary    ${targets}    UP_TO_2GB_${vDU_release}_BTS_target
    ${KPI_UPLOAD_TO_NMS_target}    Get From Dictionary    ${targets}    UPLOAD_TO_NMS_${vDU_release}_target
    Set Test Variable     ${KPI_UP_TO_500MB_target}
    Set Test Variable     ${KPI_UP_TO_1GB_target}
    Set Test Variable     ${KPI_UP_TO_2GB_target}
    Set Test Variable     ${KPI_UPLOAD_TO_NMS_target}
    OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU    test_iterations=3
    ...                                                  nms_lab=5007

