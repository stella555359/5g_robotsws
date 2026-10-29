# @Time    : 2025/10/24 15:41
# @Author  : Chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : CNI-117636-F.robot
# @Software: PyCharm
# @Doc     : FCA_VRF_RRM-21864
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CNI-117636-F - Fault 4565:EFaultIdConfigMismatchInRncAnd CommissioningForDssAl Reasoning Status

Suite Setup       MMW5 Common Suite Setup
Suite Teardown    MMW5 Common Suite Teardown
Test Setup        MMW5 Common Case Setup
Test Teardown     MMW5 Common Case Teardown
Force Tags        CRT_TRUNK

Resource    Resources/3G_RRM_Resources.robot

*** Variables ***
${if_commissioning}         False
${ROBOTWS_ROOT}
${COMMON_SCF}               ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE3G402T0271/SCF_SBTS00.xml
${SCF_DSS}                  ${CURDIR}/Resources/config/SCF_DSS.xml
${WCEL_DIST}                MRBTS-${MRBTS_ID}/WNBTS-1/WNCEL-2711
${LTE_DIST}                 MRBTS-${MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-1
${DEFAULT_CARRIER}          defaultCarrier
${VALUE_TO_CHANGE}          10750
${VALUE_TO_REVERT}          10775
@{CELL_FAULT_4565}          [271] ${LTE_DIST}
...                         [271] RNC-${RNC_ID}/WBTS-271/WCEL-2711
@{ALLOWED_FAULTS}           4565    6327
${TS_CASE_LOG_PATH}         ${OUTPUT_DIR}

*** Test Cases ***
CNI-117636-F_002_Fault 4565 Report and Recover after modify defaultCarrier in BTS
    [Documentation]    Author: chun.li@nokia-sbell.com
    ...    The purpose of this test case is to verify Fault 4565 can be reported/clear after modify defaultCarrier in BTS
    ...    Pre-requisite: RU is commissioned with LTE-WCDMA DSS
    [Tags]    CNI-117636-F    FCA_VRF_RRM-21864
    #Step0: Precondition
    COAM Commission with scf file    ${SCF_DSS}    skip_parameter_relation_errors=${False}    timeout=900
    AlarmWatchdog.add_allow_alarms    fault_id=@{ALLOWED_FAULTS}
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online
    Wait Until Keyword Succeeds    10min    30s    Verify All 4G and 3G Cells are OnAir

    #Step1: Modify defaultCarrier in WCDMA LTE DSS cell, and check fault 4565
    coam.perform_parameter_recommissioning    dist_name=${WCEL_DIST}    parameter=${DEFAULT_CARRIER}    operation=update
    ...    value=${VALUE_TO_CHANGE}    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    5min    20s    Verify BTS Alarm Configuration Alarming Objects
    ...    fault_id=4565    fault_name=Configuration mismatch while commissioning WCDMA LTE DSS
    ...    objects=@{CELL_FAULT_4565}
    Sleep    10s
    Verify BTS Single Cell Status Is Reset State    dist_name=${WCEL_DIST}    availability_status=failed    cell_type=wcdma
    Verify BTS Single Cell Status Is Reset State    dist_name=${LTE_DIST}    availability_status=failed    cell_type=lte

    #Step2: Revert defaultCarrier in WCDMA LTE DSS cell, and check fault 4565 is cleared
    coam.perform_parameter_recommissioning    dist_name=${WCEL_DIST}    parameter=${DEFAULT_CARRIER}    operation=update
    ...    value=${VALUE_TO_REVERT}    timeout=600    connection=GNB_OAM
    Wait Until Keyword Succeeds    1min    20s    Verify BTS Alarm Not Exist
     ...    fault_id=4565    fault_name=Configuration mismatch while commissioning WCDMA LTE DSS
    Wait Until Keyword Succeeds    5min    30s    Verify All 4G and 3G Cells are OnAir
    CI_commssion.Verify all cells should be Online
    AlarmWatchdog.remove_allow_alarms    fault_id=@{ALLOWED_FAULTS}

    #Step3: Verify traffic can be setup after fault cleared
    UE Attach And Verify 3G With DL TCP Traffic   ue_index=3    parallel=1

    [Teardown]    Run Keywords    MMW5 Common Case Teardown    AND    Revert SCF

*** Keywords ***
Revert SCF
    [Documentation]    Author:chun.li@nokia-sbell.com
    ...    Revert to the original SCF file
    Connect to gnb coam via ssl
    COAM Commission with scf file    ${COMMON_SCF}    timeout=900
    Wait Until Keyword Succeeds    20min    30s    Verify All 4G and 3G Cells are OnAir
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections