*** Settings ***
Documentation
...            Main file to import as resource for Classical deployment
...            Keywords for suite and test setup
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...
...            Supported user flags for tests execution:
...            -v skip:config      Skipping configuration upload in Suite/Test setup
...            -v skip:alarms      Skipping OAM alarms collection in Test teardown when OAM logs enabled
...            -v skip:scf         Skipping SCF collection in Test teardown when OAM logs enabled
...            -v skip:snapshot    Skipping Snapshot collection in Test teardown when OAM logs enabled
...            -v skip:sos         Skipping SosReport collection in Test teardown when it's enabled
...            Skip flags can be combined with comma separator:
...            -v skip:config,snapshot
...
...            Mandatory keywords to run in test suite:
...            Suite Setup       Testline Setup
...            Suite Teardown    Testline Teardown
...            Test Setup        Test Case Setup
...            Test Teardown     Test Case Teardown

Resource    configurators_cls.robot
Resource    remote_cls.robot
Resource    wts.robot
Resource    logging_cls.robot
Resource    procedures_cls.robot
Resource    traffic.robot
Resource    cell_operations_cls.robot
Resource    verificators.robot
Resource    converters.robot
Resource    pm_counters_cls.robot
Resource    ../../../../../../../resources/Common/reporting.robot

*** Variables ***
# Variables provided by UTE execution
${CONFIGURATION}    ${None}    # Example: Wroclaw.2_16_UTE5GCLASSICAL4152
${ENB_BUILD}        ${None}    # Example: SBTS23R1_ENB_0000_000664_000000
${ENB_BRANCH}       ${None}    # Example: SBTS23R1

*** Keywords ***
Testline Setup
    [Documentation]    Setup of test suite that allows optional upload of config files and reaching OnAir state.
    ...                Imports TL configuration file if missing.
    ...                To be used in [Suite Setup] section.
    ...                Supports user flag ``skip:config`` for skipping configuration upload.
    ...                - ``log_dir``: Directory for suite logs, Default: ``$\{OUTPUT DIR\}/Logs/Run_[date]_[time]/``
    ...                - ``config``: Dictionary with paths to configuration files for CLASSICAL deployment.\
    ...                Valid items: [iphy, scf, delta, rnd_gnb, ip_addr, skip_parameter_relation_errors, wait_for_state],\
    ...                Default: config unchanged
    ...                - ``wts``: Pathfile to wts.cfg, Default: basic_setup.cfg
    ...                - ``reboot_after_config``: Forced reboot after config upload, Default: no
    ...                - ``reach_on_air``: If OnAir state should be reached: yes/no/without_x2_link, Default: no
    [Arguments]    ${log_dir}=${Empty}    ${config}=&{Empty}
    ...    ${wts}=/opt/wts/latest/basic_setup.cfg    ${reboot_after_config}=no    ${reach_on_air}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${config}) is dict    msg=Invalid KW parameter: config
    Should Be True    '${reboot_after_config}' in ('yes','no')    msg=Invalid KW parameter: reboot_after_config
    Should Be True    '${reach_on_air}' in ('yes','no','without_x2_link')    msg=Invalid KW parameter: reach_on_air
    #---------------------------------------------------------------------------------------------------------------
    Create Suite Scope Variables    log_dir=${log_dir}
    Testline Readiness Check
    IF    &{config} != &{Empty}
    ...    Upload Configs    config=${config}    log_dir=${SUITE_log_dir}/Suite_Setup/Configs/
    ...    forced_reboot=${reboot_after_config}
    ${skip_x2_link}    Set Variable If    '${reach_on_air}' == 'without_x2_link'    yes    no
    IF    '${reach_on_air}' != 'no'
    ...    Reach Onair In Multiple Attempts    wts_cfg=${wts}    log_dir=${SUITE_log_dir}/Suite_Setup/Egate/
    ...    skip_x2_link=${skip_x2_link}

Testline Teardown
    [Documentation]    To be used in [Suite Teardown] section.
    Teardown Egate If Running    log_dir=${SUITE_log_dir}/Suite_Teardown/Egate/
    Calculate Config Files Checksum    log_dir=${SUITE_log_dir}

Test Case Setup
    [Documentation]    Setup of test case that allows optional upload of config files, reaching OnAir state
    ...                and starting log collection. See ``Start Multiple Logs`` documentation for logging options.
    ...                To be used in local [Setup] section or suite [Test Setup] section.
    ...                Supports user flag ``skip:config`` for skipping configuration upload.
    ...                If OnAir was reached in Testline Setup but must be reached again
    ...                then WTS will be torn down and restarted.
    ...                - ``log_dir``: Directory for test logs, Default: ``$\{SUITE_log_dir\}/$\{TEST NAME\}/``
    ...                - ``config``: Dictionary with paths to configuration files for CLASSICAL deployment.\
    ...                Valid items: [iphy, scf, delta, rnd_gnb, ip_addr, skip_parameter_relation_errors, wait_for_state],\
    ...                Default: config unchanged
    ...                - ``logs``: Dictionary with flags for continuous log collectors to be started.\
    ...                Valid items: [syslog_gnb, syslog_ap, tcpdump_gnb, sherpa, pcmd, dcap], Default: none
    ...                - ``radio_res``: Collect Aashell radio resources at beginning and end of a test, Default: no
    ...                - ``wts``: Pathfile to WTS config file, Default: basic_setup.cfg
    ...                - ``reboot_after_config``: Forced reboot after config upload, Default: no
    ...                - ``reach_on_air``: If OnAir state should be reached: yes/no/without_x2_link, Default: no
    [Arguments]    ${log_dir}=${Empty}
    ...    ${config}=&{Empty}    ${logs}=&{Empty}    ${wts}=/opt/wts/latest/basic_setup.cfg
    ...    ${radio_res}=no    ${reboot_after_config}=no    ${reach_on_air}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${config}) is dict    msg=Invalid KW parameter: config
    Should Be True    type(${logs}) is dict    msg=Invalid KW parameter: logs
    Should Be True    '${radio_res}' in ('yes','no')    msg=Invalid KW parameter: radio_res
    Should Be True    '${reboot_after_config}' in ('yes','no')    msg=Invalid KW parameter: reboot_after_config
    Should Be True    '${reach_on_air}' in ('yes','no','without_x2_link')    msg=Invalid KW parameter: reach_on_air
    #---------------------------------------------------------------------------------------------------------------
    Create Test Scope Variables    log_dir=${log_dir}
    ${egate_running}    Check If Egate Is Running
    IF    '${reach_on_air}' != 'no'    Should Not Be True    ${egate_running}
    ...    msg=${TEST NAME}: Attempted to start WTS when WTS is already running. Teardown WTS at previous test.
    IF    &{config} != &{Empty}
    ...    Upload Configs    config=${config}    log_dir=${TEST_log_dir}/Configs/    forced_reboot=${reboot_after_config}
    ${skip_x2_link}    Set Variable If    '${reach_on_air}' == 'without_x2_link'    yes    no
    IF    '${reach_on_air}' != 'no'
    ...    Reach Onair In Multiple Attempts    wts_cfg=${wts}    log_dir=${TEST_log_dir}/Egate/
    ...    skip_x2_link=${skip_x2_link}
    ...    ELSE IF    ${egate_running}    Set Egate Logs Dir    log_dir=${TEST_log_dir}/Egate/
    IF    '${radio_res}' == 'yes'
    ...    Get and Save Radio Resources    output_file=${TEST_log_dir}/AaShell/radio_resources_pre_test.json
    IF    &{logs} != &{Empty}
    ...    Start Multiple Logs    logs=${logs}    log_dir=${TEST_log_dir}

Test Case Teardown
    [Documentation]    Teardown of test case with standard log collection. Logs are collected to directory
    ...                provided at Test Case Setup.
    ...                To be used in local [Teardown] section or suite [Test Teardown] section.
    ...                Supports independent user flags ``skip:alarms,scf,snapshot,sos``
    ...                for skipping log collection steps: Active Alarms, SCF, Snapshot and SosReport.
    ...                - ``detach_ues``: Detach all remaining active UEs, Default: yes
    ...                - ``check_radio_res``: Verify radio resources deallocation, Default: no
    ...                - ``oam_logs``: Collect Alarms, SCF and Snapshot, Default: no
    ...                - ``sosreport``: Collect SosReport when test fails, Default: no
    ...                - ``teardown_wts``: Teardown of WTS at test end instead of suite end, Default: no
    [Arguments]    ${detach_ues}=yes    ${check_radio_res}=no    ${oam_logs}=no    ${sosreport}=no
    ...    ${teardown_wts}=no
    Run Keyword and Warn on Failure    Set SCOUT TC ID for Reporting
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${detach_ues}' in ('yes','no')    msg=Invalid KW parameter: detach_ues
    Should Be True    '${check_radio_res}' in ('yes','no')    msg=Invalid KW parameter: check_radio_res
    Should Be True    '${oam_logs}' in ('yes','no')    msg=Invalid KW parameter: oam_logs
    Should Be True    '${sosreport}' in ('yes','no')    msg=Invalid KW parameter: sosreport
    Should Be True    '${teardown_wts}' in ('yes','no','yes_with_reboot')    msg=Invalid KW parameter: teardown_wts
    #---------------------------------------------------------------------------------------------------------------
    Stop All Running Logs
    ${egate_running}    Check If Egate Is Running
    IF    ${egate_running} and '${detach_ues}' == 'yes'    Detach Active or Idle UEs Forcefully
    ${pretest_res_file}    Set Variable    ${TEST_log_dir}/AaShell/radio_resources_pre_test.json
    ${pretest_res_exist}    Run Keyword And Return Status    File Should Exist    ${pretest_res_file}
    IF    '${check_radio_res}' == 'yes'    Should Be True    ${pretest_res_exist}
    ...    msg=${TEST NAME}: Cannot compare radio resources because pre-test resources were not collected.
    ${compare_with}    Set Variable If    '${check_radio_res}' == 'yes'    ${pretest_res_file}    ${Empty}
    IF    ${pretest_res_exist}    Run Keyword If Test Passed    Get and Compare Radio Resources
    ...    output_file=${TEST_log_dir}/AaShell/radio_resources_post_test.json    compare_with=${compare_with}
    IF    '${oam_logs}' == 'yes'    Collect COAM Logs    log_dir=${TEST_log_dir}
    IF    'yes' in '${teardown_wts}'    Teardown Egate If Running    log_dir=${TEST_log_dir}/Egate/Teardown/
    IF    '${sosreport}' == 'yes'    Collect AP SosReport    log_dir=${TEST_log_dir}/SosReport/
    IF    'reboot' in '${teardown_wts}'    Reboot GNB and AP

Create Suite Scope Variables
    [Documentation]    Creates default suite scope variables.
    ...                - ``log_dir``: Directory for suite logs, Default: ``$\{OUTPUT DIR\}/Logs/Run_[date]_[time]/``
    [Arguments]    ${log_dir}=${Empty}
    ${dir_name}    Get Current Date    result_format=Run_%Y%m%d_%H%M%S
    IF    '${log_dir}' == ''
    ...    Set Suite Variable    ${SUITE_log_dir}    ${OUTPUT DIR}/Logs/${dir_name}/
    ...    ELSE    Set Suite Variable    ${SUITE_log_dir}    ${log_dir}
    Create Directory    ${SUITE_log_dir}
    Variable Should Exist   ${tl}   msg=Please execute test with parameter -V or set proper filename!
    &{collectors}    Create Dictionary
    Set Suite Variable    ${SUITE_TAF_collectors}    ${collectors}

Create Test Scope Variables
    [Documentation]    Creates default test scope variables.
    ...                - ``log_dir``: Directory for test logs within Suite directory,\
    ...                Default: ``$\{SUITE_log_dir\}/$\{TEST NAME\}/``
    [Arguments]    ${log_dir}=${Empty}
    IF    '${log_dir}' == ''
    ...    Set Test Variable    ${TEST_log_dir}    ${SUITE_log_dir}/${TEST NAME}/
    ...    ELSE    Set Test Variable    ${TEST_log_dir}    ${SUITE_log_dir}/${log_dir}/
    Create Directory    ${TEST_log_dir}
    @{sa_list}    Create List
    @{nsa_list}    Create List
    Set Test Variable    ${TEST_SA_UEs}    ${sa_list}
    Set Test Variable    ${TEST_NSA_UEs}    ${nsa_list}
