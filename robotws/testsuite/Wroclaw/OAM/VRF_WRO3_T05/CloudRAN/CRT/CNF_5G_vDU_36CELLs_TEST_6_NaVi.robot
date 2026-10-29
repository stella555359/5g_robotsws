*** Settings ***
Documentation    Test Suite with automated TC for NaVi TL (CNF_5G_vDU_18CELLs_TEST_6).

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/OAMKPI/OAMKPI_RMOD_Reset_vDU.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown

Test Setup       TC Setup    hw_type=vCU+vDU
Test Teardown    TC Teardown

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8777/__init__.py

*** Test Cases ***
OAMKPI RMOD Reset vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI RMOD Reset vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    12h
    [Tags]       RF50    CB012796    CB013257    CB013369
    ${EXCEPTION_FAMILY_TIMES_DICT}  Create Dictionary    MASTER=240  AMBER=240  AEQN=240  PULSAR=NA  CHILE=240
    ...  SCORPIO=240  MEGATRON=120  GALVATRON=120  ZODIAC=120  BARYON=120  MAVERICK=120  PHOTON=35  YODA=30  LEPTON=240
    ${targets}    Create Dictionary
    ...           KPI_51a_26R2_target=210
    ...           KPI_51a_26R1_target=210
    ...           KPI_51a_26R2_AHFIB_benchmark=181
    ...           KPI_51a_26R2_AHLOA_benchmark=179
    ...           KPI_51a_26R2_AHFIC_benchmark=174
    ...           KPI_51a_26R2_AZQI_benchmark=231
    ...           KPI_51a_26R2_AEHC_benchmark=346
    ...           KPI_51a_26R2_AEQP_benchmark=282
    ...           KPI_51a_26R2_AHCA_benchmark=146
    ...           KPI_51a_25R3_target=210
    ...           KPI_51a_25R2_target=240

    ${vDU_release}=             Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_51a_target}=           Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_target
    ${KPI_51a_AHFIB_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AHFIB_benchmark
    ${KPI_51a_AHLOA_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AHLOA_benchmark
    ${KPI_51a_AHFIC_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AHFIC_benchmark
    ${KPI_51a_AZQI_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AZQI_benchmark
    ${KPI_51a_AEHC_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AEHC_benchmark
    ${KPI_51a_AEQP_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AEQP_benchmark
    ${KPI_51a_AHCA_benchmark}=    Get From Dictionary    ${targets}    KPI_51a_${vDU_release}_AHCA_benchmark
    Set Test Variable     ${EXCEPTION_FAMILY_TIMES_DICT}
    Set Test Variable     ${KPI_51a_target}
    Set Test Variable     ${KPI_51a_AHFIB_benchmark}
    Set Test Variable     ${KPI_51a_AHLOA_benchmark}
    Set Test Variable     ${KPI_51a_AHFIC_benchmark}
    Set Test Variable     ${KPI_51a_AZQI_benchmark}
    Set Test Variable     ${KPI_51a_AEHC_benchmark}
    Set Test Variable     ${KPI_51a_AEQP_benchmark}
    Set Test Variable     ${KPI_51a_AHCA_benchmark}
    ${KPI_51a_avg}    OAMKPI RMOD Reset vDU    test_iterations=5
