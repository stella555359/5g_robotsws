*** Settings ***
Documentation
...    Author: Liu, Renhui
...    Email address: renhui-david.liu@nokia-sbell.com
...    Maintainer: Liu, Renhui
...    Email address: renhui-david.liu@nokia-sbell.com
...    The Log Module's common keywords. It is used to
...    1. convert various types of logs from various BTS products to human-readable formats
...    2. conduct analysis on these converted logs
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer.
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guidelines for user: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+Module+of+Log+Analysis
...    Examples: https://wrgitlab.int.net.nokia.com/RAN/robotws/-/tree/master/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module/Module_Test

Library       library/log_worker/common/bip_analysis.py
Library       library/log_worker/common/tti_analysis.py
Library       library/log_worker/common/wireshark_analysis.py
Library       library/log_worker/common/syslog_analysis.py
Library       library/log_worker/common/snapshot_analysis.py
Library       library/log_worker/common/common_log_analysis.py
Library       library/log_worker/common/emil_analysis.py
Library       library/log_worker/common/cell_trace_analysis.py
Library       library/log_worker/common/check_emil_error.py


*** Keywords ***
Log Analysis
    [Arguments]    ${operation}
    ...            ${log_type}
    ...            ${log_path}
    ...            ${analysis_dict}=${None}
    ...            ${timeout}=${2400}
	...            &{extra_args}
    [Documentation]
    ...    *Usage:*
    ...        - This keyword is used to
    ...        -     Convert various types of logs from different BTS products into human-readable formats.
    ...        -     Perform analyses on these converted logs.
    ...    *Author:*
    ...        - renhui-david.liu@nokia-sbell.com
    ...    *Args:*
    ...    | Input Parameters | Man. | Description |
    ...    | operation | Yes | check, filter |
    ...    | log_type | Yes | wireshark, bip, tti, syslog, snapshot, emil, cell_trace, etc. |
    ...    | log_path | Yes | vdu, vcu, gnb, enb |
    ...    | analysis_dict | No |
    ...    |               |   | wireshark: { filter_conditions: str, extra_conditions: str, output_field_names: [] } |
    ...    |               |   | bip: { filter_conditions: str, output_field_names: [], |
    ...    |               |   |      check_rules: {basic_rules: [], statistics_rules: []}} |
    ...    |               |   | tti: { check_rules: {basic_rules: [], statistics_rules: []}} |
    ...    |               |   | syslog:   { filter_conditions: {line_regex: , element_regex: }} |
    ...    |               |   | snapshot: { filter_conditions: {filename: str, postfix: str}} |
    ...    |               |   | emil: do not need set value for this parameter |
    ...    |               |   | cell_trace: do not need set value for this parameter |
    ...    *Guidelines and Examples:*
    ...    https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+Module+of+Log+Analysis
    ...
    [Timeout]    ${timeout}
    validate_log_expected    ${log_type}    ${log_path}
    ${result}    Run Keyword    ${operation}_${log_type}_logs
    ...    log_path=${log_path}
    ...    analysis_dict=${analysis_dict}
	...    &{extra_args}
    [Return]    ${result}
