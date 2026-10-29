# Copyright (c) 2024 Nokia. All rights reserved.
*** Settings ***
Resource    keywords.robot
Documentation    PET Test cases

Suite Setup       Common Optimized PET Suite Setup
Suite Teardown    Common PET Suite Teardown

*** Test Cases ***
VTM 1070FF 6 SSB 8*4MIMO 6Cells Mixed HO 90UEs ping traffic 15UEs perCell
    [Documentation]    VTM_Drop2_1070FF_6_SSB_8*4MIMO_6Cells_Mixed_HO_90UEs
    ...    ping_traffic_15UEs_perCell
    [Tags]    FULLRUN     [flow]L3 Call    VTM_MIXED_HO
    Fetch Dictionary items    ${MIXED_HO_VTM}
    Traffic Duration Set
    ${MAIL_DATA}=    Create Dictionary    Events_Per_Second=0
    Set Suite Variable    &{MAIL_DATA}
    ${test_verdict}=    Create List
    Set Suite Variable    @{test_verdict}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}
    Set Suite Variable    @{keys_list}
    ${vtm_data_list}=    Create List
    ${expected_values}=    Create List    ${expected_rate}
    Set Suite Variable    @{expected_values}
    Set Suite Variable    @{vtm_data_list}
    ${kpi_result_list}=    Create List
    Set Suite Variable    @{kpi_result_list}
    @{seq_list1}=    Create List    7    24
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic    ${MIXED_HO_VTM}    VTM_MIXED_HO
    Sleep    ${COUNTER_DURATION}m
    @{COUNTER_LIST}=    Create List    M55145C00351     M55145C00341    M55143C00005    M55145C00321     M55145C00301
    Set Suite Variable    ${COUNTER_LIST}
    @{COUNTER_VALUE}=    Create List
    Set Suite Variable    ${COUNTER_VALUE}
    ${COUNTER_DURATION}=    Set Variable    ${COUNTER_TIMER}
    Set Suite Variable    ${COUNTER_DURATION}
    Create KPI Type List
    FOR    ${trf_loop}    IN RANGE    1    ${TRF_DURATION}+1    ${COUNTER_DURATION}
        Check sim_uec process if active
        Set Suite Variable    ${trf_loop}
        Sleep    ${COUNTER_DURATION}m
        ${active_ues}    Active UE Count Status Check
        Log To Console    Active UEs:${active_ues[0]}
        ${RATE}    Fetch Sum of Counter lists for Multiple Counters
        Log To Console    Achieved Rate ${RATE}
        Append To Kpi list    ${kpi_list}    ${RATE}
        ${traffic_duration}=    Evaluate    ${TRF_DURATION}+2
        Run Keyword If    '${AP_Snapshot}' == 'True'
        ...    Run Keyword and Ignore Error    Collect AP Snapshot During Test    ${traffic_duration}   ${trf_loop}
    END
    [Teardown]    Validate Kpi and Deregister    VTM_MIXED_HO    ${MAIL_DATA}

ORAN FDD NonDSS 20MHz 4DL4UL 18Cells 836FF SA Cell lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    FDD_CELL_LOCK_UNLOCK    AP_REG    P3_REG
    Fetch Dictionary items    ${CELL_FDD_LOCK_UNLOCK}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${CELL_FDD_LOCK_UNLOCK}
    ...    FDD_CELL_LOCK_UNLOCK
    [Teardown]    Unlock cells And Append Data    FDD_CELL_LOCK_UNLOCK

ORAN FDD NonDSS 20MHz 4DL4UL 18Cells 836FF SA RU lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    FDD_RU_LOCK_UNLOCK    AP_REG    P3_REG
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1,2,3    RU_2=4,5,6    RU_3=7,8,9    RU_4=10,11,12
    ...    RU_5=13,14,15    RU_6=16,17,18
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_FDD_LOCK_UNLOCK}
    ${LOOP_TIMES}=    Get Variable Value    ${RU_LOCK_UNLOCK}    ${LOOP_TIMES}
    Set Suite Variable    ${LOOP_TIMES}
    RUs Status List Creation and Perfom Lock Unlock of RUs    ${RU_FDD_LOCK_UNLOCK}    FDD_RU_LOCK_UNLOCK
    [Teardown]    Run Keywords    Unlock RUs And Append Data    FDD_RU_LOCK_UNLOCK
    ...    AND    Stop Edaemon Egate

ORAN TDD 10MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 128Mbps UL 11Mbps 72UE 1Cell
    [Tags]    FULLRUN    [flow]L3 Call    72UE_SUMIMO    AP_REG
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 07-May-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    72UE_SUMIMO    &{72UE_ORAN_SUMIMO}
    [Teardown]    Deregister and Append Data    72UE_SUMIMO

ORAN TDD 100MHz FR1 SA 1208FF 4DL4UL SUMIMO NBF RU lock and unlock
    [Tags]    FULLRUN    [flow]L3 Call    TDD_RU_LOCK_UNLOCK    AP_REG    P3_REG
    &{RU_CELL_DICT}=    Create Dictionary    RU_1=1    RU_2=2    RU_3=3    RU_4=4    RU_5=5    RU_6=6
    Set Suite Variable    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_CELL_DICT}
    Fetch Dictionary items    ${RU_TDD_LOCK_UNLOCK}
    RUs Status List Creation and Perfom Lock Unlock of RUs    ${RU_TDD_LOCK_UNLOCK}    TDD_RU_LOCK_UNLOCK
    [Teardown]    Unlock RUs And Append Data    TDD_RU_LOCK_UNLOCK

ORAN TDD 100MHz FR1 SA 1208FF 4DL4UL SUMIMO NBF Cell lock and unlock
    [Tags]    FULLRUN     [flow]L3 Call    TDD_CELL_LOCK_UNLOCK    AP_REG    P3_REG
    Fetch Dictionary items    ${CELL_TDD_LOCK_UNLOCK}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${CELL_TDD_LOCK_UNLOCK}
    ...    TDD_CELL_LOCK_UNLOCK
    [Teardown]    Unlock cells And Append Data    TDD_CELL_LOCK_UNLOCK

ORAN TDD 50MHz FR1 SA MUE 1208FF 4DL4UL SUMIMO NBF DL 815Mbps UL 113Mbps 72UE 1Cell
    [Tags]    FULLRUN    [flow]L3 Call    72UE_TDD    AP_REG
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 21-April-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    72UE_TDD    &{1208FF_ORAN_DL_UL}
    [Teardown]    Deregister and Append Data    72UE_TDD

ORAN FDD NonDSS 10MHz 4DL4UL 18Cells 836FF SA 72UE DL 203Mbps UL 101Mbps
    [Tags]    FULLRUN    [flow]L3 Call    72UE_FDD    AP_REG
    [Documentation]    FDD PET scenario for 300UE with UL 569Mbps
    ...                Modified Date: 08-May-2025
    ...                Last Modified by: kokila.b@nokia.com
    Initialize Test Data    72UE_FDD    &{72UE_FDD_ORAN}
    [Teardown]    Run Keywords    Deregister and Append Data    72UE_FDD
    ...    AND    Stop Edaemon Egate