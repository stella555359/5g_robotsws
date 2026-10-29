*** Settings ***
Documentation
...           author: Marek Starzyk
...           maintainer: Marek Starzyk
...           contact: marek.starzyk@nokia.com
...           Robot keywords to support the CSV4ALL test suites

Library       Collections
Library       ./resources_uuf.py
Resource      taf/rfrl/uuf4all/uuf4all_keywords.robot

*** Variables ***
${TEST_ON_NODE}
${enb1}
${enb2}
${gnb1}
${gnb2}
${5G_NODE}
@{TEST_NODES}
@{NODES}
@{tl_specific_variables}
${TEMPORARY_ALLOWED_FAULTS_4G}
${TEMPORARY_ALLOWED_FAULTS_5G}
${CUSTOM_ALLOWED_ALARMS_4G}
${CUSTOM_ALLOWED_ALARMS_5G}
${HW_TO_ONAIR_TIME}
${INITIAL}
${CANDIDATE}
${5G_CONFIG}
${ENB_BRANCH}

*** Keywords ***
Standalone Common Suite Setup
    ${single_run}         check_if_cm_execution
    Run Keyword If     not ${single_run}                   Import Init
    Import TL Specific Variables
    Modify Standalone Node
    Run Keyword If        ${single_run}                   Setting Initial And Candidate    standalone

Import TL Specific Variables
    ${path_to_variables}    Set Variable
    ...         /home/ute/MN/UTE/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T04/common_resources/UUF/Resources/resources_uuf.py
    Import Variables        ${path_to_variables}
    ${hostname}             check hostname
    ${status}               Run Keyword And Return Status
    ...                     Dictionary Should Contain Key     ${tl_specific_variables}    ${hostname}
    ${variables}            Run Keyword If                    ${status}
    ...                     Get From Dictionary               ${tl_specific_variables}    ${hostname}

    ${allowed_4g}           Run Keyword And Return Status
    ...                     Dictionary Should Contain Key     ${variables}                CUSTOM_ALLOWED_ALARMS_4G
    ${custom_allowed_4g}    Set Variable If                   ${allowed_4g}
    ...                     ${variables['CUSTOM_ALLOWED_ALARMS_4G']}                      ${None}
    Set Suite Variable      ${CUSTOM_ALLOWED_ALARMS_4G}       ${custom_allowed_4g}

    ${allowed_5g}           Run Keyword And Return Status
    ...                     Dictionary Should Contain Key     ${variables}                CUSTOM_ALLOWED_ALARMS_5G
    ${custom_allowed_5g}    Set Variable If                   ${allowed_5g}
    ...                     ${variables['CUSTOM_ALLOWED_ALARMS_5G']}                      ${None}
    Set Suite Variable      ${CUSTOM_ALLOWED_ALARMS_5G}       ${custom_allowed_5g}

    ${allowed_tmp_4g}       Run Keyword And Return Status
    ...                     Dictionary Should Contain Key     ${variables}                TEMPORARY_ALLOWED_FAULTS_4G
    ${tmp_allowed_4g}       Set Variable If                   ${allowed_tmp_4g}
    ...                     ${variables['TEMPORARY_ALLOWED_FAULTS_4G']}                   ${None}
    Set Suite Variable      ${TEMPORARY_ALLOWED_FAULTS_4G}    ${tmp_allowed_4g}

    ${allowed_tmp_5g}       Run Keyword And Return Status
    ...                     Dictionary Should Contain Key     ${variables}                TEMPORARY_ALLOWED_FAULTS_5G
    ${tmp_allowed_5g}       Set Variable If                   ${allowed_tmp_5g}
    ...                     ${variables['TEMPORARY_ALLOWED_FAULTS_5G']}                   ${None}
    Set Suite Variable      ${TEMPORARY_ALLOWED_FAULTS_5G}    ${tmp_allowed_5g}

    ${hw_time}              Run Keyword And Return Status
    ...                     Dictionary Should Contain Key     ${variables}                HW_TO_ONAIR_TIME
    ${hw_onair_time}        Set Variable If                   ${hw_time}
    ...                     ${variables['HW_TO_ONAIR_TIME']}                              ${900}
    Set Suite Variable      ${HW_TO_ONAIR_TIME}               ${hw_onair_time}

Modify Standalone Node
    &{enb1}    Create Dictionary
    ...        node_alias=4G             testline_object=${testline_object}   source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable         ${ENB1}     ${enb1}
    @{nodes}    Create List    ${enb1}
    Set Suite Variable         ${NODES}    ${nodes}

Import Init
    ${init_path}    init path
    Import Variables    ${init_path}

Setting Initial And Candidate
    [Arguments]           ${config}
    ${initial_sw}         Get Source SW
    ${candidate_sw}       Get Target SW
    Set Suite Variable    ${INITIAL}      ${initial_sw}
    Set Suite Variable    ${CANDIDATE}    ${candidate_sw}
    Run Keyword If
    ...    '${config}'=='standalone'
    ...    Set to dictionary    ${enb1}       source_sw=${initial_sw}    target_sw=${candidate_sw}    ELSE IF
    ...    '${config}'=='4G5G'                Run Keywords
    ...    Set to dictionary    ${enb1}       source_sw=${initial_sw}    target_sw=${candidate_sw}    AND
    ...    Set to dictionary    ${gnb1}       source_sw=${initial_sw}    target_sw=${candidate_sw}    ELSE IF
    ...    '${config}'=='monster'             Run Keywords
    ...    Set to dictionary    ${enb1}       source_sw=${initial_sw}    target_sw=${candidate_sw}    AND
    ...    Set to dictionary    ${gnb1}       source_sw=${initial_sw}    target_sw=${candidate_sw}    AND
    ...    Set to dictionary    ${gnb2}       source_sw=${initial_sw}    target_sw=${candidate_sw}
