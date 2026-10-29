# Copyright (c) 2024 Nokia. All rights reserved.

*** Settings ***
Documentation     This contains common keywords which are needed to run PET vRAN L3 Calls.

Resource    keywords.robot
Library    taf.gnb.oam.coam.cu    WITH NAME    coam_cu
Library    taf.gnb.oam.coam.vdu    WITH NAME    vDU


Suite Setup       Run Keywords    PET vRAN Setup
Suite Teardown    Run Keywords    PET vRAN Teardown

*** Variables ***
${PET_VRAN}    True

*** Test Cases ***
CB012219 NonDSS 4x4MIMO 12CELL SA 864UEs UL 1209Mbps traffic 72UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    vRAN_864UE    VRAN_COMMON
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00502    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    UL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${864UE_vRAN}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_UL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    157    157
    @{seq_list2}=    Create List    170    180
    @{stat_list}=    Create List    ${seq_list1}
    @{stat_list}=    Create List    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic vRAN    ${864UE_vRAN}    vRAN_864UE
    Traffic Loop With Tput Validation    ${DIR}    vRAN_864UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRAN_864UE

CB011169 NonDSS 4x4MIMO 12CELL SA 864UEs DL 3344Mbps traffic 72UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    vRAN_344_DL    VRAN_COMMON
    Traffic Duration Set
    @{COUNTER_LIST}=    Create List    M55140C00001    M55326C00501    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    DL_RATE(Mbps)=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${DL_344_vRAN}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${OVERALL_DL}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    193    194
    @{seq_list2}=    Create List    207    216
    @{stat_list}=    Create List    ${seq_list1}
    @{stat_list}=    Create List    ${seq_list2}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic vRAN    ${DL_344_vRAN}    vRAN_344_DL
    Traffic Loop With Tput Validation    ${DIR}    vRAN_344_DL    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRAN_344_DL

CB011169 NonDSS 4x4MIMO 12CELL SA 4500UEs DL UL Ping traffic 1DRB PerUE 375UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    vRAN_4500UE    VRAN_COMMON
    Traffic Duration Set
    Fetch Dictionary items    ${RRC_vRAN_4500UE}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${RRC_vRAN_4500UE}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    145   156
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic vRAN    ${RRC_vRAN_4500UE}    vRAN_4500UE
    Traffic Loop With Tput Validation    ${DIR}    vRAN_4500UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRAN_4500UE

CB011169 NonDSS 4x4MIMO 12CELL SA VoNR 1440UEs DL UL Ping traffic Multi DRB PerUE 120UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    vRAN_1440UE    VRAN_COMMON
    Traffic Duration Set
    Fetch Dictionary items    ${RRC_vRAN_1440UE}
    @{COUNTER_LIST}=    Create List    M55140C00001    M55140C00002
    Set Suite Variable    ${COUNTER_LIST}
    ${MAIL_DATA}=    Create Dictionary    Active_Number_Of_UEs=0    NON_GBR=0
    Set Suite Variable    &{MAIL_DATA}
    Fetch Dictionary items    ${RRC_vRAN_1440UE}
    Fetch Dictionary items    ${MAIL_DATA}
    ${expected_values}=    Create List    ${END_UE}    ${EXPECTED_NON_GBR}
    Set Suite Variable    @{expected_values}
    ${keys_list}=    Get Dictionary Keys    ${MAIL_DATA}    sort_keys=False
    Set Suite Variable    @{keys_list}
    @{seq_list1}=    Create List    181    192
    @{stat_list}=    Create List    ${seq_list1}
    Set Suite Variable    ${stat_list}
    Common Register and Traffic vRAN    ${RRC_vRAN_1440UE}    vRAN_1440UE
    Traffic Loop With Tput Validation    ${DIR}    vRAN_1440UE    ${COUNTER_LIST}    ${MAIL_DATA}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRAN_1440UE

1070FF BF NonCA 8x4MIMO 6CELL SA 4500UEs DL UL Ping traffic 750UEs per CELL Half RINLINE
    [Tags]    FULL_RUN     [flow]L3 Call    vRANRRC_6cell
    Initialize Test Data    vRANRRC_6cell    &{RRC_vRAN_6cell}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRANRRC_6cell

1070FF BF NonCA 8x4MIMO 6CELL SA 24UEs DL 7348Mbps UL 1928Mbps traffic 4UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    vRAN_4UE_6cell
    Initialize Test Data    vRAN_4UE_6cell    &{4UE_vRAN_6cell}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRAN_4UE_6cell

1070FF BF NonCA 8x4MIMO 6CELL SA 432UEs DL 7348Mbps UL 1928Mbps traffic 72UEs per CELL
    [Tags]    FULL_RUN     [flow]L3 Call    vRAN_72UE_6cell
    Initialize Test Data    vRAN_72UE_6cell    &{72UE_vRAN_6cell}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    vRAN_72UE_6cell

CNI146020 CB011051 vRAN TDD 16DL8UL MUMIMO SA 1Cel 5600 Mbps 72UE3x100MHz 16DL8UL with 8RX with half RINLINE2
    [Tags]    FULL_RUN     [flow]L3 Call    VRAN_CNI146020_TC1
    Initialize Test Data    VRAN_CNI146020_TC1    &{TC1_VRAN_CNI146020}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    VRAN_CNI146020_TC1

CNI146020 vRAN TDD 16DL8UL MUMIMO SRSBF SA 1Cell SRSBF 3x100MHz 16DL8UL with 8RX with half RINLINE2 Cell Lock unLock SIB Check
    [Tags]    FULLRUN     [flow]L3 Call    VRAN_CNI146020_TC2
    Fetch Dictionary items    ${CNI146020_TC2_VRAN}
    Cell Status List Creation and Perfom Lock Unlock of Cells    ${CNI146020_TC2_VRAN}    VRAN_CNI146020_TC2
    [Teardown]    Alarm check And Append Data vRAN    VRAN_CNI146020_TC2

CNI146020 CB011051 vRAN TDD 16DL8UL MUMIMO SA3 Cel DL 4320 Mbps 72UE 3x100MHz 16DL8UL with 8RX with half RINLINE2
    [Tags]    FULL_RUN     [flow]L3 Call    VRAN_CNI146020_TC3
    Initialize Test Data    VRAN_CNI146020_TC3    &{TC3_VRAN_CNI146020}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    VRAN_CNI146020_TC3

CNII146020 CB011051 vRAN TDD 16DL8UL MUMIMO SA3 Cel UL 1020 Mbps 72UE 3x100MHz 16DL8UL with 8RX with half RINLINE2
    [Tags]    FULL_RUN     [flow]L3 Call    VRAN_CNI146020_TC4
    Initialize Test Data    VRAN_CNI146020_TC4    &{TC4_VRAN_CNI146020}
    [Teardown]    Run Keyword And Ignore Error    Deregister and Append Data    VRAN_CNI146020_TC4