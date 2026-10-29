*** Settings ***
Documentation    Test Suite with automated TC for Dedal TL (CNF_CR_DRAN_3).

Resource    ../Resources/cloud_frame.robot
Resource    ../Tests/OAMKPI/OAMKPI_Capacity_Alarm_History_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Capacity_Alarm_History_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Capacity_Active_Alarms_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Capacity_Active_Alarms_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Alarm_Peak_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Alarm_Peak_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Snapshot_Manual_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Snapshot_Manual_vDU.robot
Resource    ../Tests/OAMKPI/OAMKPI_vDU_diagnostic_check.robot
Resource    ../Tests/OAMKPI/OAMKPI_vCU_diagnostic_check.robot
Resource    ../Tests/OAMKPI/OAMKPI_PM_Collection_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_Alarm_Reporting_Duration_vCU.robot
Resource    ../Tests/OAMKPI/OAMKPI_PM_Storage_Reserved_vCU.robot

Suite Setup       Suite Setup    default_init_path=${DEFAULT_INIT_PATH}
Suite Teardown    Suite Teardown
Test Setup        TC Setup    hw_type=vCU+vDU
Test Teardown     TC Teardown

*** Variables ***
${DEFAULT_INIT_PATH}    /home/ute/testline_configuration/11_16_MRBTS8514/__init__.py
${VCU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8514/Trunk/vCU-8514/SCF_vCU-8514_Trunk.xml
${VDU_SCF_PATH}         /home/ute/topology-configs/VRF_WRO3_T05/8514/Trunk/vDU-8514/SCF_vDU-8514_Trunk.xml

*** Test Cases ***
OAMKPI Capacity Alarm History vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Capacity Alarm History vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_vCU_alarm_capacity_26R1_target=8000
    ...           KPI_vCU_alarm_capacity_25R3_target=8000

    ${vCU_release}=    Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_vCU_alarm_capacity_target}     Get From Dictionary    ${targets}    KPI_vCU_alarm_capacity_${vCU_release}_target

    OAMKPI Capacity Alarm History vCU      KPI_vCU_alarm_capacity_target=${KPI_vCU_alarm_capacity_target}

OAMKPI Capacity Alarm History vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Capacity Alarm History vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_vDU_alarm_capacity_26R1_target=500
    ...           KPI_vDU_alarm_capacity_25R3_target=500

    ${vDU_release}=    Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_vDU_alarm_capacity_target}     Get From Dictionary    ${targets}    KPI_vDU_alarm_capacity_${vDU_release}_target

    OAMKPI Capacity Alarm History vDU      KPI_vDU_alarm_capacity_target=${KPI_vDU_alarm_capacity_target}

OAMKPI Capacity Active Alarms vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Capacity Active Alarms vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    4h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_vDU_alarm_capacity_26R1_target=400
    ...           KPI_vDU_alarm_capacity_25R3_target=400

    ${vDU_release}=    Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_vDU_alarm_capacity_target}     Get From Dictionary    ${targets}    KPI_vDU_alarm_capacity_${vDU_release}_target

    OAMKPI Capacity Active Alarms vDU      KPI_vDU_alarm_capacity_target=${KPI_vDU_alarm_capacity_target}

OAMKPI Capacity Active Alarms vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Capacity Active Alarms vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    4h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_vCU_alarm_capacity_26R1_target=3000
    ...           KPI_vCU_alarm_capacity_25R3_target=3000

    ${vCU_release}=    Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_vCU_alarm_capacity_target}     Get From Dictionary    ${targets}    KPI_vCU_alarm_capacity_${vCU_release}_target

    OAMKPI Capacity Active Alarms vCU      KPI_vCU_alarm_capacity_target=${KPI_vCU_alarm_capacity_target}

OAMKPI Alarm Peak vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Alarm Peak vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    4h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_vDU_Alarm_Peak_26R1_target=30
    ...           KPI_vDU_Alarm_Peak_Time_26R1_target=60
    ...           KPI_vDU_Alarm_Peak_25R3_target=30
    ...           KPI_vDU_Alarm_Peak_Time_25R3_target=60

    ${vDU_release}=    Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_vDU_Alarm_Peak_vDU_target}     Get From Dictionary    ${targets}    KPI_vDU_Alarm_Peak_${vDU_release}_target
    ${KPI_vDU_Alarm_Peak_Time_vDU_target}     Get From Dictionary    ${targets}    KPI_vDU_Alarm_Peak_Time_${vDU_release}_target

    OAMKPI Alarm Peak vDU      test_iterations=10
    ...                        KPI_vDU_Alarm_Peak_vDU_target=${KPI_vDU_Alarm_Peak_vDU_target}
    ...                        KPI_vDU_Alarm_Peak_Time_vDU_target=${KPI_vDU_Alarm_Peak_Time_vDU_target}


OAMKPI Alarm Peak vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Alarm Peak vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    4h
    [Tags]       RF50    CB012796    CB013257
    ${targets}    Create Dictionary
    ...           KPI_vCU_Alarm_Peak_26R1_target=30
    ...           KPI_vCU_Alarm_Peak_Time_26R1_target=60
    ...           KPI_vCU_Alarm_Peak_25R3_target=30
    ...           KPI_vCU_Alarm_Peak_Time_25R3_target=60

    ${vCU_release}=    Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_vCU_Alarm_Peak_vCU_target}     Get From Dictionary    ${targets}    KPI_vCU_Alarm_Peak_${vCU_release}_target
    ${KPI_vCU_Alarm_Peak_Time_vCU_target}     Get From Dictionary    ${targets}    KPI_vCU_Alarm_Peak_Time_${vCU_release}_target

    OAMKPI Alarm Peak vCU      test_iterations=10
    ...                        KPI_vCU_Alarm_Peak_vCU_target=${KPI_vCU_Alarm_Peak_vCU_target}
    ...                        KPI_vCU_Alarm_Peak_Time_vCU_target=${KPI_vCU_Alarm_Peak_Time_vCU_target}

OAMKPI Snapshot Manual vDU
    [Setup]    Run Keywords
    ...    Set Library Search Order    OAMKPI Snapshot Manual vDU
    ...    AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    240min
    [Tags]       RF50    CB011085_C
    ${targets}    Create Dictionary
    ...           UP_TO_500MB_26R1_BTS_target=600
    ...           UP_TO_1GB_26R1_BTS_target=900
    ...           UP_TO_2GB_26R1_BTS_target=1200
    ...           E2E_26R1_target=1500
    ...           UP_TO_500MB_25R3_BTS_target=600
    ...           UP_TO_1GB_25R3_BTS_target=900
    ...           UP_TO_2GB_25R3_BTS_target=1200
    ...           E2E_25R3_target=1500
    ${vDU_release}=                Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_UP_TO_500MB_target}      Get From Dictionary    ${targets}    UP_TO_500MB_${vDU_release}_BTS_target
    ${KPI_UP_TO_1GB_target}        Get From Dictionary    ${targets}    UP_TO_1GB_${vDU_release}_BTS_target
    ${KPI_UP_TO_2GB_target}        Get From Dictionary    ${targets}    UP_TO_2GB_${vDU_release}_BTS_target
    ${KPI_E2E_target}    Get From Dictionary    ${targets}    E2E_${vDU_release}_target
    Set Test Variable     ${KPI_UP_TO_500MB_target}
    Set Test Variable     ${KPI_UP_TO_1GB_target}
    Set Test Variable     ${KPI_UP_TO_2GB_target}
    Set Test Variable     ${KPI_E2E_target}
    OAMKPI Snapshot Manual vDU     test_iterations=10
    [Teardown]    Run Keywords    TC Teardown

OAMKPI Snapshot Manual vCU
    [Setup]    Run Keywords
    ...    Set Library Search Order    OAMKPI Snapshot Manual vCU
    ...    AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    240min
    [Tags]       RF50    CB011085_C
    ${targets}    Create Dictionary
    ...           UP_TO_500MB_26R1_BTS_target=600
    ...           UP_TO_1GB_26R1_BTS_target=900
    ...           UP_TO_2GB_26R1_BTS_target=1200
    ...           E2E_26R1_target=1500
    ...           UP_TO_500MB_25R3_BTS_target=600
    ...           UP_TO_1GB_25R3_BTS_target=900
    ...           UP_TO_2GB_25R3_BTS_target=1200
    ...           E2E_25R3_target=1500
    ${vCU_release}=                Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_UP_TO_500MB_target}      Get From Dictionary    ${targets}    UP_TO_500MB_${vCU_release}_BTS_target
    ${KPI_UP_TO_1GB_target}        Get From Dictionary    ${targets}    UP_TO_1GB_${vCU_release}_BTS_target
    ${KPI_UP_TO_2GB_target}        Get From Dictionary    ${targets}    UP_TO_2GB_${vCU_release}_BTS_target
    ${KPI_E2E_target}    Get From Dictionary    ${targets}    E2E_${vCU_release}_target
    Set Test Variable     ${KPI_UP_TO_500MB_target}
    Set Test Variable     ${KPI_UP_TO_1GB_target}
    Set Test Variable     ${KPI_UP_TO_2GB_target}
    Set Test Variable     ${KPI_E2E_target}
    OAMKPI Snapshot Manual vCU     test_iterations=10
    [Teardown]    Run Keywords    TC Teardown

OAMKPI Diagnostic Check vDU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Diagnostic Check vDU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257    CB013369
    ${targets}    Create Dictionary
    ...           KPI_Duration_of_DC_procedure_without_reset_26R1_target=30
    ...           KPI_Duration_of_DC_procedure_without_reset_26R1_avg_benchmark=5
    ...           KPI_Duration_of_DC_procedure_with_RU_reset_26R1_target=300
    ...           KPI_Duration_of_DC_procedure_with_RU_reset_26R1_avg_benchmark=191
    ...           KPI_Duration_of_DC_procedure_without_reset_25R3_target=30
    ...           KPI_Duration_of_DC_procedure_with_RU_reset_25R3_target=300

    ${vDU_release}=            Get From Dictionary    ${sw_info['vDU']}    release
    ${KPI_Duration_of_DC_procedure_without_reset}=
    ...    Get From Dictionary    ${targets}    KPI_Duration_of_DC_procedure_without_reset_${vDU_release}_target
    ${KPI_Duration_of_DC_procedure_without_reset_avg_benchmark}=
    ...    Get From Dictionary    ${targets}    KPI_Duration_of_DC_procedure_without_reset_${vDU_release}_avg_benchmark

    ${KPI_Duration_of_DC_procedure_with_RU_reset}=
    ...    Get From Dictionary    ${targets}    KPI_Duration_of_DC_procedure_with_RU_reset_${vDU_release}_target
    ${KPI_Duration_of_DC_procedure_with_RU_reset_avg_benchmark}=
    ...    Get From Dictionary    ${targets}    KPI_Duration_of_DC_procedure_with_RU_reset_${vDU_release}_avg_benchmark

    OAMKPI Diagnostic Check vDU
    ...    3      #test_iterations
    ...    ${KPI_Duration_of_DC_procedure_without_reset}
    ...    ${KPI_Duration_of_DC_procedure_without_reset_avg_benchmark}
    ...    ${KPI_Duration_of_DC_procedure_with_RU_reset}
    ...    ${KPI_Duration_of_DC_procedure_with_RU_reset_avg_benchmark}

OAMKPI Diagnostic Check vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Diagnostic Check vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257    CB013369
    ${targets}    Create Dictionary
    ...           KPI_Duration_of_DC_procedure_26R2_target=30
    ...           KPI_Duration_of_DC_procedure_26R2_avg_benchmark=4
    ...           KPI_Duration_of_DC_procedure_26R1_target=30
    ...           KPI_Duration_of_DC_procedure_26R1_avg_benchmark=13


    ${vDU_release}=            Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_Duration_of_DC_procedure}=
    ...    Get From Dictionary    ${targets}    KPI_Duration_of_DC_procedure_${vDU_release}_target
    ${KPI_Duration_of_DC_procedure_avg_benchmark}=
    ...    Get From Dictionary    ${targets}    KPI_Duration_of_DC_procedure_${vDU_release}_avg_benchmark


    OAMKPI Diagnostic Check vCU
    ...    3      #test_iterations
    ...    ${KPI_Duration_of_DC_procedure}
    ...    ${KPI_Duration_of_DC_procedure_avg_benchmark}

OAMKPI PM Collection vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI PM Collection vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257    CB013369

    OAMKPI PM Collection vCU
    ...    3      #test_iterations

OAMKPI Alarm Reporting Duration vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI Alarm Reporting Duration vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    18h
    [Tags]       RF50    CB012796    CB013257    CB013369
    ${targets}    Create Dictionary
    ...           KPI_BTS_26R2_target=5
    ...           KPI_E2E_26R2_target=60
    ...           KPI_BTS_26R2_avg_benchmark_target=1
    ...           KPI_E2E_26R2_avg_benchmark_target=1

    ${vCU_release}=            Get From Dictionary    ${sw_info['vCU']}    release
    ${KPI_Alarm_Duration_BTS_target}=
    ...    Get From Dictionary    ${targets}    KPI_BTS_${vCU_release}_target
    ${KPI_Alarm_Duration_E2E_target}=
    ...    Get From Dictionary    ${targets}    KPI_E2E_${vCU_release}_target
    ${KPI_Alarm_Duration_BTS_avg_benchmark_target}=
    ...    Get From Dictionary    ${targets}    KPI_BTS_${vCU_release}_avg_benchmark_target
    ${KPI_Alarm_Duration_E2E_avg_benchmark_target}=
    ...    Get From Dictionary    ${targets}    KPI_E2E_${vCU_release}_avg_benchmark_target

    OAMKPI Alarm Reporting Duration vCU
    ...    3      #test_iterations
    ...    ${KPI_Alarm_Duration_BTS_target}
    ...    ${KPI_Alarm_Duration_E2E_target}
    ...    ${KPI_Alarm_Duration_BTS_avg_benchmark_target}
    ...    ${KPI_Alarm_Duration_E2E_avg_benchmark_target}

OAMKPI PM Storage Reserved vCU
    [Setup]    Run Keywords
    ...        Set Library Search Order    OAMKPI PM Storage Reserved vCU
    ...        AND    TC Setup    hw_type=vCU+vDU
    [Timeout]    25h
    [Tags]       RF50    CB012796    CB013257    CB013369

    OAMKPI PM Storage Reserved vCU
