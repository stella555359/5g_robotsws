*** Settings ***
Documentation
...            Main file to import as resource for vran deployment
...            Keywords for suite and test setup
...            author:       Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainer:   Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...
...            Supported user flags for tests execution:
...            -v skip:config      Skipping configuration upload in Suite/Test setup
...            -v skip:snapshot    Skipping Snapshot collection in Test teardown
...
...            Mandatory keywords to run in test suite:
...            Suite Setup       Testline Setup
...            Suite Teardown    Testline Teardown
...            Test Setup        Test Case Setup
...            Test Teardown     Test Case Teardown

Library     taf.gnb.oam.coam.vdu.interface.vdu  WITH NAME  vdu
Library     taf.gnb.oam.coam.cu.interface.cu  WITH NAME  vcu
Resource    configurators_vran.robot
Resource    remote.robot
Resource    wts.robot
Resource    logging_vran.robot
Resource    procedures.robot
Resource    procedures_vran.robot
Resource    traffic.robot
Resource    verificators.robot
Resource    converters.robot
Resource    pm_counters_vran.robot
Resource    ./aic/aic_common_resources.robot

*** Keywords ***
Testline Setup
    [Documentation]    Setup of test suite that allows optional upload of config files and reaching OnAir state.
    ...                Imports TL configuration file if missing.
    ...                To be used in [Suite Setup] section.
    ...                Prepare pods for all components. Available suite variables:
    ...                SUITE_CPUE_POD, SUITE_CPCL_POD, SUITE_CPNRT_POD, SUITE_CPRT_POD, SUITE_CPNB_POD, SUITE_CPIF_POD.
    ...                Prepare vCU, vDU and ap suite variables:
    ...                VCU_MASTER_IP - 192.168.100.129, VDU_MASTER_IP - 192.168.255.129
    ...                NAMESPACE_CU and NAMESPACE_DU
    ...                Get information about vran hardware (TL, vcu, vdu and ap). Check if all components are online.
    ...                Set suite timestamp for collecting logs. Available test variable: SUITE_TIME_START and SUITE_TIME_START_RFC3339
    ...                - ``log_dir``: Directory for suite logs, Default: ``$\{OUTPUT DIR\}/Logs/``
    ...                - ``config``: Dictionary with paths to configuration files for VRAN deployment.
    ...                - ``wts``: Pathfile to wts.cfg, Default: basic_setup.cfg
    ...                - ``reboot_after_config``: Forced reboot after config upload, Default: no
    ...                - ``reach_on_air``: If OnAir state should be reached: yes/no/without_x2_link, Default: no
    [Arguments]    ${log_dir}=${OUTPUT DIR}/Logs/Test_Suite    ${config}=&{Empty}
    ...            ${wts}=/opt/wts/latest/basic_setup.cfg   ${reboot_after_config}=no    ${reach_on_air}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${config}) is dict    msg=Invalid KW parameter: config
    Should Be True    '${reboot_after_config}' in ('yes','no')    msg=Invalid KW parameter: reboot_after_config
    Should Be True    '${reach_on_air}' in ('yes','no','without_x2_link')    msg=Invalid KW parameter: reach_on_air
    #---------------------------------------------------------------------------------------------------------------
    Create Suite Scope Variables    log_dir=${log_dir}
    Hardware Check
    Prepare pods for all components
    Set suite time start
    Run Keyword If    &{config} != &{Empty}
    ...    Upload Configs    config=${config}    forced_reboot=${reboot_after_config}
    ${skip_x2_link}    Set Variable If    '${reach_on_air}' == 'without_x2_link'    yes    no
    Run Keyword If    '${reach_on_air}' != 'no'
    ...    Reach Onair In Multiple Attempts    wts_cfg=${wts}    log_dir=${SUITE_log_dir}/Suite_Setup/Egate/    skip_x2_link=${skip_x2_link}

Testline Teardown
    [Documentation]    To be used in [Suite Teardown] section.
    Teardown Egate If Running    log_dir=${SUITE_log_dir}

Test Case Setup
    [Documentation]    Setup of test case that allows optional upload of config files, reaching OnAir state
    ...                and starting log collection. See ``Start Multiple Logs`` documentation for logging options.
    ...                To be used in local [Setup] section or suite [Test Setup] section.
    ...                If OnAir was reached in Testline Setup but must be reached again
    ...                then WTS will be torn down and restarted.
    ...                Set test timestamp for collecting logs. Available test variable: TEST_TIME_START and TEST_TIME_START_RFC3339
    ...                - ``log_dir``: Directory for test logs, Default: ``$\{OUTPUT DIR\}/Logs/$\{TEST NAME\}/``
    ...                - ``config``: Dictionary with paths to configuration files for VRAN deployment.
    ...                - ``wts``: Pathfile to WTS config file, Default: basic_setup.cfg
    ...                - ``reboot_after_config``: Forced reboot after config upload, Default: no
    ...                - ``reach_on_air``: If OnAir state should be reached: yes/no/without_x2_link, Default: no
    [Arguments]    ${log_dir}=${OUTPUT DIR}/Logs/Test_Cases/${TEST NAME}/   ${config}=&{Empty}
    ...            ${wts}=/opt/wts/latest/basic_setup.cfg   ${reboot_after_config}=no    ${reach_on_air}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${config}) is dict    msg=Invalid KW parameter: config
    Should Be True    '${reboot_after_config}' in ('yes','no')    msg=Invalid KW parameter: reboot_after_config
    Should Be True    '${reach_on_air}' in ('yes','no','without_x2_link')    msg=Invalid KW parameter: reach_on_air
    #---------------------------------------------------------------------------------------------------------------
    Create Test Scope Variables    log_dir=${log_dir}
    Set test time start
    ${egate_running}    Check If Egate Is Running
    Run Keyword If    '${reach_on_air}' != 'no'    Should Not Be True    ${egate_running}
    ...    msg=${TEST NAME}: Attempted to start WTS when WTS is already running. Teardown WTS at previous test
    Run Keyword If    &{config} != &{Empty}
    ...    Upload Configs    config=${config}    forced_reboot=${reboot_after_config}
    ${skip_x2_link}    Set Variable If    '${reach_on_air}' == 'without_x2_link'    yes    no
    Run Keyword If    '${reach_on_air}' != 'no'
    ...    Reach Onair In Multiple Attempts    wts_cfg=${wts}    log_dir=${TEST_log_dir}/Egate/    skip_x2_link=${skip_x2_link}
    ...    ELSE IF    ${egate_running}    Set Egate Logs Dir    log_dir=${TEST_log_dir}/Egate/

Test Case Teardown
    [Documentation]    Teardown of test case with standard log collection. Logs are collected to directory
    ...                provided at Test Case Setup.
    ...                To be used in local [Teardown] section or suite [Test Teardown] section.
    ...                - ``detach_ues``: Detach all remaining active UEs, Default: yes
    ...                - ``pod_logs``: Collect all logs from pods, Default: no
    ...                - ``oam_logs``: Collect Snapshot, Default: no
    ...                - ``sosreport``: Collect SosReport when test fails, Default: no
    ...                - ``teardown_wts``: Teardown of WTS at test end instead of suite end, Default: no
    [Arguments]    ${detach_ues}=yes    ${pod_logs}=no   ${oam_logs}=no    ${sosreport}=no   ${teardown_wts}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${detach_ues}' in ('yes','no')    msg=Invalid KW parameter: detach_ues
    Should Be True    '${pod_logs}' in ('yes','no')    msg=Invalid KW parameter: pod_logs
    Should Be True    '${oam_logs}' in ('yes','no')    msg=Invalid KW parameter: oam_logs
    Should Be True    '${sosreport}' in ('yes','no')    msg=Invalid KW parameter: sosreport
    Should Be True    '${teardown_wts}' in ('yes','no')    msg=Invalid KW parameter: teardown_wts
    #---------------------------------------------------------------------------------------------------------------
    ${egate_running}    Check If Egate Is Running
    Run Keyword If    ${egate_running} and '${detach_ues}' == 'yes'    Detach Active or Idle UEs Forcefully
    ${pretest_res}    Run Keyword And Return Status    Variable Should Exist    ${TEST_resources_before}
    Run Keyword If    '${pod_logs}' == 'yes'    Collect logs from all pods
    Run Keyword If    '${oam_logs}' == 'yes'    Collect COAM Logs    log_dir=${TEST_log_dir}
    Run Keyword If    '${teardown_wts}' == 'yes'    Teardown Egate If Running    log_dir=${TEST_log_dir}
    Run Keyword If    '${sosreport}' == 'yes'    Run Keyword If Test Failed
    ...    Collect AP SosReport    log_dir=${TEST_log_dir}/SosReport/

Create Suite Scope Variables
    [Documentation]    Creates default suite scope variables.
    ...                Prepare vCU, vDU and ap available suite variables:
    ...                VCU_MASTER_IP - 192.168.100.129, VDU_MASTER_IP - 192.168.255.129
    ...                NAMESPACE_CU and NAMESPACE_DU
    ...                Arguments:
    ...                - ``log_dir``: Directory for suite logs, Default: ``$\{OUTPUT DIR\}/Logs/Run_[date]_[time]/``
    [Arguments]    ${log_dir}=${Empty}
    ${dir_name}    Get Current Date    result_format=Run_%Y%m%d_%H%M%S
    Run Keyword If    '${log_dir}' == ''
    ...    Set Suite Variable    ${SUITE_log_dir}    ${OUTPUT DIR}/Logs/${dir_name}/
    ...    ELSE    Set Suite Variable    ${SUITE_log_dir}    ${log_dir}
    ${tl_var_exists}    Run Keyword And Return Status    Variable Should Exist    ${tl}
    Run Keyword Unless    ${tl_var_exists}    Import TL Variables
    Import additional VRAN variables
    @{collectors}    Create List
    Set Suite Variable    ${SUITE_TAF_collectors}    ${collectors}

Create Test Scope Variables
    [Documentation]    Creates default test scope variables.
    ...                - ``log_dir``: Directory for test logs, Default: ``$\{SUITE_log_dir\}/$\{TEST NAME\}/``
    [Arguments]    ${log_dir}=${Empty}
    Run Keyword If    '${log_dir}' == ''
    ...    Set Test Variable    ${TEST_log_dir}    ${SUITE_log_dir}/${TEST NAME}/
    ...    ELSE    Set Test Variable    ${TEST_log_dir}    ${log_dir}
    @{sa_list}    Create List
    @{nsa_list}    Create List
    Set Test Variable    ${TEST_SA_UEs}    ${sa_list}
    Set Test Variable    ${TEST_NSA_UEs}    ${nsa_list}
