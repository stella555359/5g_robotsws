*** Settings ***
Documentation
...            Keywords for collecting logs specific to vran deployment
...            author:       Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainer:   Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    Collections
Library    json
Library    ute_wtssim
Library    ute_syslog
Resource   taf/rfrl/cbts/interfaces.robot

*** Keywords ***
Prepare pods for all components
    Set Suite Variable    ${SUITE_CPUE_POD}    ute-${NAMESPACE_CU}-cpue-0
    Set Suite Variable    ${SUITE_CPCL_POD}    ute-${NAMESPACE_CU}-cpcl-0
    Set Suite Variable    ${SUITE_CPNRT_POD}   ute-${NAMESPACE_CU}-cpnrt-0
    Set Suite Variable    ${SUITE_CPRT_POD}    ute-${NAMESPACE_CU}-cprt-0
    Set Suite Variable    ${SUITE_CPIF_POD}    ute-${NAMESPACE_CU}-cpif-0
    Set Suite Variable    ${SUITE_CPNB_POD}    ute-${NAMESPACE_CU}-cpnb-0

Set suite time start
    ${SUITE_TIME_START}=  Get current date  result_format=%Y%m%d-%H%M%S
    ${SUITE_TIME_START_RFC3339}=  Get current date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
    Set suite variable  ${SUITE_TIME_START}
    Set suite variable  ${SUITE_TIME_START_RFC3339}

Set test time start
    ${TEST_TIME_START}=  Get current date  result_format=%Y%m%d-%H%M%S
    ${TEST_TIME_START_RFC3339}=  Get current date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%SZ
    Set test variable  ${TEST_TIME_START}
    Set test variable  ${TEST_TIME_START_RFC3339}

Collect logs from all pods
    [Documentation]    Collect vcu and vdu pod logs from all components: cpue, cpnb, cpcl, cpnrt, cprt, cpif
    ...                Possible arguments:
    ...                timestamp - the start time for log collection
    ...                log_dir - localization of logs after collection
    [Arguments]        ${args}=${EMPTY}   ${timestamp}=${TEST_TIME_START}  ${log_dir}=${TEST_log_dir}/Pods
    Log to console  Getting OCP logs...
    ${vcu_lines_to_display}    Collect logs from pods  ${MASTER_CU}  ${NAMESPACE_CU}  ${args}  ${timestamp}  ${log_dir}/vCU_logs
    ${vdu_lines_to_display}    Collect logs from pods  ${MASTER_DU}  ${NAMESPACE_DU}  ${args}  ${timestamp}  ${log_dir}/vDU_logs
    ${all_units_lines_to_display}    Combine Lists    ${vcu_lines_to_display}    ${vdu_lines_to_display}
    Display Listed Logs As Robot Warnings    ${all_units_lines_to_display}

Collect COAM Logs
    [Documentation]    Collect Snapshot from vCU and vDU in CLOUD deployment via M2M REST API.
    ...                Supports independent user flags ``skip:snapshot`` for skipping collection steps.
    ...                - ``log_dir``: Directory for COAM data, Default: ``$\{TEST_log_dir\}/``
    ...                Example:
    ...                | robot -v skip:snapshot test_suite.robot
    [Arguments]    ${log_dir}=${TEST_log_dir}
    ${flags}    Get Variable Value    ${skip}
    ${skip_snapshot}    Set Variable If    'snapshot' in '${flags}'    ${True}    ${False}
    Run Keyword If    not ${skip_snapshot}    Run Keywords
    ...               Create Directory                ${log_dir}/Snapshot/vDU
    ...    AND        Create Directory                ${log_dir}/Snapshot/vCU
    ...    AND        Trigger And Save Local Snapshot For vDU    local_snapshot_folder=${log_dir}/Snapshot/vDU     compressed_or_not=True
    ...    AND        Trigger And Save Local Snapshot For CU     local_snapshot_folder=${log_dir}/Snapshot/vCU
    ...    ELSE       Log to Console    Skipping Snapshot collection
