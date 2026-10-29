*** Settings ***
Documentation    Test Suite with automated TC for Ikar TL (CNF_CR_DRAN_3).

Resource    ../Resources/cloud_frame.robot

Resource    ../Tests/OAMKPI/OAMKPI_Cell_Block_Unblock_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_CNF_Reset_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_FHGW_Reset.robot
Resource    ../Tests/OAMKPI/OAMKPI_RANNIC_Reset_vDU.robot
Resource    ../Tests/HA/CB010963_RCP_trsconfig_Restores_Configuration_Data_From_SDL_After_Pod_Failure.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown
Test Setup        TC Setup    hw_type=vCU+vDU

Force Tags    RF50    QCP_RAN_VRF    QCD_MN_RAN

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/1_16_UTE5GMRBTS8698/__init__.py
# You can use 'robot --variable TEST_ITERATIONS:<int>' to modify iterations for all tests in suite
# Also possible to do same modification in cloud. In 'Additional pybot options' set '--variable TEST_ITERATIONS:<int>'
${TEST_ITERATIONS}    0

*** Test Cases ***
OAMKPI_Cell_Block_Unblock_vDU
    [Setup]       Run Keywords    Set Library Search Order    OAMKPI Cell Block Unblock vDU    AND    TC Setup
    [Teardown]    TC Teardown    skip_logs_collection=${True}
    [Timeout]     12h
    [Tags]        Trunk    Branch
    ${targets}    Create Dictionary
    ...           KPI_17a_26R2_target=20    KPI_17b_26R2_target=20    KPI_17a_26R2_benchmark=20    KPI_17b_26R2_benchmark=20    26R2_QC_id=277416
    ...           KPI_17a_26R1_target=20    KPI_17b_26R1_target=20    KPI_17a_26R1_benchmark=20    KPI_17b_26R1_benchmark=20    26R1_QC_id=260328
    ...           KPI_17a_25R3_target=20    KPI_17b_25R3_target=20    KPI_17a_25R3_benchmark=20    KPI_17b_25R3_benchmark=20    25R3_QC_id=215207

    ${KPI_17a_target}        Get From Dictionary    ${targets}    KPI_17a_${SW_INFO}[vDU][release]_target
    ${KPI_17a_benchmark}=    Get From Dictionary    ${targets}    KPI_17a_${SW_INFO}[vDU][release]_benchmark
    ${KPI_17b_target}        Get From Dictionary    ${targets}    KPI_17b_${SW_INFO}[vDU][release]_target
    ${KPI_17b_benchmark}=    Get From Dictionary    ${targets}    KPI_17b_${SW_INFO}[vDU][release]_benchmark
    ${qc_id}=                Get From Dictionary    ${targets}    ${SW_INFO}[vDU][release]_QC_id
    Set Tags    QC_${qc_id}
    ${test_loops}=    Set Variable If    ${TEST_ITERATIONS}==0    100    ${TEST_ITERATIONS}
    ${KPI_17a_avg}    ${KPI_17b_avg}=    OAMKPI Cell Block Unblock vDU    test_iterations=${test_loops}
    ...    KPI_17a_target=${KPI_17a_target}    KPI_17a_benchmark=${KPI_17a_target}
    ...    KPI_17b_target=${KPI_17b_target}    KPI_17b_benchmark=${KPI_17b_target}
    Report KPI result to QC    name=KPI_17a    value=${KPI_17a_avg}    target=${KPI_17a_target}
    Report KPI result to QC    name=KPI_17b    value=${KPI_17b_avg}    target=${KPI_17b_target}

OAMKPI_CNF_Reset_vDU
    [Setup]       Run Keywords    Set Library Search Order    OAMKPI CNF Reset vDU    AND    TC Setup
    [Teardown]    TC Teardown    skip_logs_collection=${True}
    [Timeout]     18h
    [Tags]        Trunk    Branch
    ${targets}=    Create Dictionary
    ...    26R2_QC_id=277608
    ...    KPI_52a_TDD_26R2_target=450    KPI_52a_TDD_26R2_avg_benchmark=317    KPI_52b_TDD_26R2_target=420    KPI_52b_TDD_26R2_avg_benchmark=287
    ...    KPI_52a_FDD_26R2_target=300    KPI_52a_FDD_26R2_avg_benchmark=304    KPI_52b_FDD_26R2_target=270    KPI_52b_FDD_26R2_avg_benchmark=244
    ...    KPI_52a_MIX_26R2_target=750    KPI_52a_MIX_26R2_avg_benchmark=300    KPI_52b_MIX_26R2_target=720    KPI_52b_MIX_26R2_avg_benchmark=300
    ...    26R1_QC_id=260329
    ...    KPI_52a_TDD_26R1_target=450    KPI_52a_TDD_26R1_avg_benchmark=300    KPI_52b_TDD_26R1_target=420    KPI_52b_TDD_26R1_avg_benchmark=300
    ...    KPI_52a_FDD_26R1_target=300    KPI_52a_FDD_26R1_avg_benchmark=311    KPI_52b_FDD_26R1_target=270    KPI_52b_FDD_26R1_avg_benchmark=251
    ...    KPI_52a_MIX_26R1_target=750    KPI_52a_MIX_26R1_avg_benchmark=300    KPI_52b_MIX_26R1_target=720    KPI_52b_MIX_26R1_avg_benchmark=300
    ...    25R3_QC_id=215206
    ...    KPI_52a_TDD_25R3_target=450    KPI_52a_TDD_25R3_avg_benchmark=450    KPI_52b_TDD_25R3_target=420    KPI_52b_TDD_25R3_avg_benchmark=420
    ...    KPI_52a_FDD_25R3_target=300    KPI_52a_FDD_25R3_avg_benchmark=540    KPI_52b_FDD_25R3_target=270    KPI_52b_FDD_25R3_avg_benchmark=510
    ...    KPI_52a_MIX_25R3_target=750    KPI_52a_MIX_25R3_avg_benchmark=750    KPI_52b_MIX_25R3_target=720    KPI_52b_MIX_25R3_avg_benchmark=720
    ${qc_id}=    Get From Dictionary    ${targets}    ${SW_INFO}[vDU][release]_QC_id
    Set Tags    QC_${qc_id}
    ${test_loops}=    Set Variable If    ${TEST_ITERATIONS}==0    15    ${TEST_ITERATIONS}
    ${KPI_52a_avg}    ${KPI_52b_avg}=    OAMKPI CNF Reset vDU    test_iterations=${test_loops}    targets=${targets}
    Report KPI result to QC    name=KPI_52a    value=${KPI_52a_avg}    target=${KPI_52a_target}
    Report KPI result to QC    name=KPI_52b    value=${KPI_52b_avg}    target=${KPI_52b_target}

OAMKPI_RANNIC_Reset_vDU
    [Setup]       Run Keywords    Set Library Search Order    OAMKPI_RANNIC_Reset_vDU    AND    TC Setup    hw_type=vCU+vDU
    [Teardown]    TC Teardown    skip_logs_collection=${True}
    [Timeout]     12h
    [Tags]        Trunk
    ${EXCEPTION_FAMILY_TIMES_DICT}  Create Dictionary    MASTER=240  AMBER=240  AEQN=240  PULSAR=NA  CHILE=240  SCORPIO=240  MEGATRON=120
    ...                                                  GALVATRON=120  ZODIAC=120  BARYON=120  MAVERICK=120  PHOTON=35  YODA=30  LEPTON=240
    ${targets}    Create Dictionary
    ...           KPI_30_26R2_target=360    KPI_30_26R2_TDD_benchmark=362    KPI_30_26R2_FDD_benchmark=259    26R2_QC_id=277418
    ...           KPI_30_26R1_target=360    KPI_30_26R1_TDD_benchmark=320    KPI_30_26R1_FDD_benchmark=287    26R1_QC_id=None
    ...           KPI_30_25R3_target=360    KPI_30_25R3_TDD_benchmark=382    KPI_30_25R3_FDD_benchmark=317    25R3_QC_id=None
    ${KPI_30_target}=           Get From Dictionary    ${targets}    KPI_30_${SW_INFO}[vDU][release]_target
    ${KPI_30_FDD_benchmark}=    Get From Dictionary    ${targets}    KPI_30_${SW_INFO}[vDU][release]_FDD_benchmark
    ${KPI_30_TDD_benchmark}=    Get From Dictionary    ${targets}    KPI_30_${SW_INFO}[vDU][release]_TDD_benchmark
    ${qc_id}=    Get From Dictionary    ${targets}    ${SW_INFO}[vDU][release]_QC_id
    Set Tags    QC_${qc_id}
    Set Test Variable     ${EXCEPTION_FAMILY_TIMES_DICT}
    ${test_loops}=    Set Variable If    ${TEST_ITERATIONS}==0    15    ${TEST_ITERATIONS}
    ${KPI_30_average}=    OAMKPI_RANNIC_Reset_vDU    test_iterations=${test_loops}
    ...   KPI_30_target=${KPI_30_target}    KPI_30_FDD_benchmark=${KPI_30_FDD_benchmark}    KPI_30_TDD_benchmark=${KPI_30_TDD_benchmark}
    Report KPI result to QC    name=KPI_30    value=${KPI_30_average}    target=${KPI_30_target}

OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU
    [Setup]      Run Keywords    Set Library Search Order    OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU    AND    TC Setup
    [Timeout]    12h
    [Tags]       Trunk
    ${targets}=    Create Dictionary
    ...            KPI_500MB_26R2_BTS_target=600    KPI_1GB_26R2_BTS_target=900    KPI_2GB_26R2_BTS_target=1200    KPI_26R2_E2E_target=1500
    ...            26R2_QC_id=277417
    ...            KPI_500MB_26R1_BTS_target=600    KPI_1GB_26R1_BTS_target=900    KPI_2GB_26R1_BTS_target=1200    KPI_26R1_E2E_target=1500
    ...            26R1_QC_id=None
    ...            KPI_500MB_25R3_BTS_target=600    KPI_1GB_25R3_BTS_target=900    KPI_2GB_25R3_BTS_target=1200    KPI_25R3_E2E_target=1500
    ...            25R3_QC_id=None

    ${KPI_up_to_500MB_target}=      Get From Dictionary    ${targets}    KPI_500MB_${SW_INFO}[vDU][release]_BTS_target
    ${KPI_up_to_1GB_target}=        Get From Dictionary    ${targets}    KPI_1GB_${SW_INFO}[vDU][release]_BTS_target
    ${KPI_up_to_2GB_target}=        Get From Dictionary    ${targets}    KPI_2GB_${SW_INFO}[vDU][release]_BTS_target
    ${KPI_upload_to_NMS_target}=    Get From Dictionary    ${targets}    KPI_${SW_INFO}[vDU][release]_E2E_target
    ${qc_id}=    Get From Dictionary    ${targets}    ${SW_INFO}[vDU][release]_QC_id
    Set Tags    QC_${qc_id}
    Set Test Variable     ${KPI_UP_TO_500MB_target}
    Set Test Variable     ${KPI_UP_TO_1GB_target}
    Set Test Variable     ${KPI_UP_TO_2GB_target}
    Set Test Variable     ${KPI_UPLOAD_TO_NMS_target}
    Set Test Variable     ${MRBTS}    8698
    ${test_loops}=    Set Variable If    ${TEST_ITERATIONS}==0    20    ${TEST_ITERATIONS}
    ${KPI_BTS_avg}     ${KPI_E2E_avg}    OAMKPI_Snapshot_Automatic_Fault_Triggered_NMS_vDU    test_iterations=${test_loops}    nms_lab=5007
    Report KPI result to QC    name=BTS    value=${KPI_BTS_avg}    target=${KPI_UP_TO_500MB_target}
    Report KPI result to QC    name=E2E    value=${KPI_E2E_avg}    target=${KPI_UPLOAD_TO_NMS_target}

OAMKPI_FHGW_Reset
    [Setup]       Run Keywords    Set Library Search Order    OAMKPI FHGW Reset    AND    TC Setup
    [Teardown]    TC Teardown    skip_logs_collection=${True}
    [Timeout]     18h
    [Tags]        Trunk
    ${targets}=    Create Dictionary
    ...    KPI_60a_26R2_target=660    KPI_60a_26R2_benchmark=357    KPI_60c_26R2_target=720    KPI_60c_26R2_benchmark=425    26R2_QC_id=277419
    ...    KPI_60a_26R1_target=660    KPI_60a_26R1_benchmark=457    KPI_60c_26R1_target=720    KPI_60c_26R1_benchmark=462    26R1_QC_id=None
    ...    KPI_60a_25R3_target=660    KPI_60a_25R3_benchmark=660    KPI_60c_25R3_target=720    KPI_60c_25R3_benchmark=720    25R3_QC_id=None
    ${KPI_60a_target}=       Get From Dictionary    ${targets}    KPI_60a_${SW_INFO}[vDU][release]_target
    ${KPI_60c_target}=       Get From Dictionary    ${targets}    KPI_60c_${SW_INFO}[vDU][release]_target
    ${KPI_60a_benchmark}=    Get From Dictionary    ${targets}    KPI_60a_${SW_INFO}[vDU][release]_benchmark
    ${KPI_60c_benchmark}=    Get From Dictionary    ${targets}    KPI_60c_${SW_INFO}[vDU][release]_benchmark
    ${qc_id}=    Get From Dictionary    ${targets}    ${SW_INFO}[vDU][release]_QC_id
    Set Tags    QC_${qc_id}
    ${test_loops}=    Set Variable If    ${TEST_ITERATIONS}==0    15    ${TEST_ITERATIONS}
    ${KPI_60a_avg}     ${KPI_60c_avg}=    OAMKPI FHGW Reset    test_iterations=${test_loops}
    ...    KPI_60a_target=${KPI_60a_target}    KPI_60c_target=${KPI_60c_target}
    ...    KPI_60a_benchmark=${KPI_60a_benchmark}    KPI_60c_benchmark=${KPI_60c_benchmark}
    Report KPI result to QC    name=KPI_60a    value=${KPI_60a_avg}    target=${KPI_60a_target}
    Report KPI result to QC    name=KPI_60b    value=${KPI_60b_avg}    target=${KPI_60b_target}

CB010963_RCP_trsconfig_Restores_Configuration_Data_From_SDL_After_Pod_Failure_vDU
    [Setup]       Run Keywords    Set Library Search Order    CB010963 RCP-trsconfig Restores Configuration Data From SDL After Pod Failure    AND
    ...           TC Setup
    [Teardown]    TC Teardown
    [Timeout]     60m
    [Tags]        Trunk
    Run Keyword If    '${SW_INFO}[vDU][release]'=='26R2'    Set Tags    QC_279048
    CB010963 RCP-trsconfig Restores Configuration Data From SDL After Pod Failure    hw_type=vDU

CB010963_RCP_trsconfig_Restores_Configuration_Data_From_SDL_After_Pod_Failure_vCU
    [Setup]      Run Keywords    Set Library Search Order    CB010963 RCP-trsconfig Restores Configuration Data From SDL After Pod Failure    AND
    ...          TC Setup
    [Timeout]    60m
    [Tags]       Trunk
    Run Keyword If    '${SW_INFO}[vDU][release]'=='26R2'    Set Tags    QC_279047
    CB010963 RCP-trsconfig Restores Configuration Data From SDL After Pod Failure    hw_type=vCU
