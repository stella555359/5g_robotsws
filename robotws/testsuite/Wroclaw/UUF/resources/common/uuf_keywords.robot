*** Settings ***
Documentation
...           author: Marek Starzyk
...           maintainer: Marek Starzyk
...           contact: marek.starzyk@nokia.com
...           Robot keywords to support the CSV4ALL test suites

Library       Collections
Library       ./vm_operations.py
Library       ./suite_utils.py
Resource      taf/rfrl/uuf4all/uuf4all_keywords.robot

*** Variables ***
${UUF_EMAIL_RECIPIENTS}           I_MN_RAN_RD_VRF_WRO3_3@internal.nsn.com
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
${TEST_QC_ID}
${QC_PROJECT}

*** Keywords ***
Standalone Common Suite Setup
    Set Email List
    ${single_run}         check_if_cm_execution
    Run Keyword Unless    ${single_run}                   Import Init
    Import TL Specific Variables
    Modify Standalone Node
    Run Keyword If        ${single_run}                   Setting Initial And Candidate    standalone
    set_rp_variables
    set_qc_tags_and_variables_if_needed                   ${CANDIDATE}
    run keyword if        ${REPORT}    set_tester_name
    Log Variables

4G5G Common Suite Setup
    Set Email List
    ${single_run}         check_if_cm_execution
    Run Keyword Unless    ${single_run}                   Import Init
    Import TL Specific Variables
    Modify 4G5G Nodes
    Run Keyword If        ${single_run}                   Setting Initial And Candidate    4G5G
    set_rp_variables
    set_qc_tags_and_variables_if_needed                   ${CANDIDATE}
    run keyword if        ${REPORT}    set_tester_name
    Log Variables

Monster Common Suite Setup
    Set Email List
    ${single_run}         check_if_cm_execution
    Run Keyword Unless    ${single_run}                   Import Init
    Import TL Specific Variables
    Modify Monster Nodes
    Run Keyword If        ${single_run}                   Setting Initial And Candidate    monster
    set_rp_variables
    Set 5G Node
    run keyword if        ${REPORT}    set_tester_name
    Log Variables

FDSW Common Suite Setup
    Set Email List
    ${single_run}         check_if_cm_execution
    Run Keyword Unless    ${single_run}                   Import Init
    Import TL Specific Variables
    Run Keyword If        ${single_run}                   Setting Initial And Candidate    FDSW
    set_rp_variables
    Modify FDSW Nodes
    run keyword if        ${REPORT}    set_tester_name
    Log Variables

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

Set 5G Node
    Run Keyword If
    ...    "${5G_CONFIG}"=="dualASIL"    Run Keywords
    ...    Set List Value        ${NODES}         0    ${gnb2}    AND
    ...    Set List Value        ${TEST_NODES}    0    ${gnb2}    AND
    ...    Set Suite Variable    ${5G_NODE}            ${gnb2}    ELSE IF
    ...    "${5G_CONFIG}"=="ASIL"        Run Keywords
    ...    Set List Value        ${NODES}         0    ${gnb1}    AND
    ...    Set List Value        ${TEST_NODES}    0    ${gnb1}    AND
    ...    Set Suite Variable    ${5G_NODE}            ${gnb1}

Set Mumin Config File
    ${mumin_file}         check_if_mumin_file
    set suite variable    ${MUMIN_CONFIG_FILES}           ${mumin_file}

Import Init
    ${init_path}    init path
    Import Variables    ${init_path}

Set Email List
    Set Suite Variable    ${EMAIL_RECIPIENTS}    ${UUF_EMAIL_RECIPIENTS}

Modify FDSW Nodes
    ${testline_object}     Set Variable If    "${TEST_ON_NODE}"=="gnb1"    ${tl.gnbs[0]}    ${tl.enbs[0]}
    ${node_alias}          Set Variable If    "${TEST_ON_NODE}"=="gnb1"    5G               4G
    ${temporary_alarms}    Set Variable If    "${TEST_ON_NODE}"=="gnb1"    ${TEMPORARY_ALLOWED_FAULTS_5G}
    ...                                                                    ${TEMPORARY_ALLOWED_FAULTS_4G}
    ${custom_alarms}       Set Variable If    "${TEST_ON_NODE}"=="gnb1"    ${CUSTOM_ALLOWED_ALARMS_5G}
    ...                                                                    ${CUSTOM_ALLOWED_ALARMS_4G}
    &{node}    Create Dictionary
    ...        node_alias=${node_alias}      testline_object=${testline_object}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}        temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable         ${TEST_NODES}     ${node}
    @{nodes}    Create List    ${node}
    Set Suite Variable         ${NODES}    ${nodes}

Modify Standalone Node
    &{enb1}    Create Dictionary
    ...        node_alias=4G             testline_object=${tl.enbs[0]}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable         ${ENB1}     ${enb1}
    @{nodes}    Create List    ${enb1}
    Set Suite Variable         ${NODES}    ${nodes}

Modify 4G5G Nodes
    &{enb1}    Create Dictionary
    ...        node_alias=4G             testline_object=${tl.enbs[0]}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable    ${ENB1}    ${enb1}
    &{gnb1}    Create Dictionary
    ...        node_alias=5G             testline_object=${tl.gnbs[0]}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_5G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable    ${GNB1}    ${gnb1}
    @{test_nodes}    run keyword if
    ...    '${TEST_ON_NODE}'=='enb1'   Create List    ${enb1}    ELSE IF
    ...    '${TEST_ON_NODE}'=='gnb1'   Create List    ${gnb1}    ELSE
    ...    Create List         ${gnb1}          ${enb1}
    Set Suite Variable         ${TEST_NODES}    ${test_nodes}
    @{nodes}    Create List    ${gnb1}          ${enb1}
    Set Suite Variable         ${NODES}    ${nodes}

Modify Monster Nodes
    &{enb1}    Create Dictionary
    ...        node_alias=ASIA_LTE       testline_object=${tl.enbs[1]}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_4G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_4G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable    ${ENB1}    ${enb1}
    &{gnb1}    Create Dictionary
    ...        node_alias=ASIL_5G        testline_object=${tl.gnbs[0]}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_5G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable    ${GNB1}    ${gnb1}
    &{gnb2}    Create Dictionary
    ...        node_alias=dualASIL_5G    testline_object=${tl.gnbs[1]}    source_sw=${INITIAL}
    ...        target_sw=${CANDIDATE}    temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS_5G}
    ...        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_5G}
    ...        hw_to_onair_timeout=${HW_TO_ONAIR_TIME}
    Set Suite Variable    ${GNB2}    ${gnb2}
    @{test_nodes}    run keyword if
    ...    '${TEST_ON_NODE}'=='enb1'   Create List    ${enb1}    ELSE IF
    ...    '${TEST_ON_NODE}'=='gnb1'   Create List    ${gnb1}    ELSE IF
    ...    '${TEST_ON_NODE}'=='gnb2'   Create List    ${gnb2}    ELSE
    ...    Create List         ${gnb2}          ${enb1}
    Set Suite Variable         ${TEST_NODES}    ${test_nodes}
    @{nodes}    Create List    ${gnb2}          ${enb1}
    Set Suite Variable         ${NODES}         ${nodes}

Import TL Specific Variables
    ${path_to_variables}    Set Variable
    ...                     /home/ute/MN/UTE/robotws/testsuite/Wroclaw/UUF/resources/common/temporary_alarms.py
    Import Variables        ${path_to_variables}
    ${hostname}             vm_operations.check hostname
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

Set 5G Initial
    ${initial_5g}    check_decoupling_path
    Set Suite Variable    ${INITIAL_5G}    ${initial_5g}
