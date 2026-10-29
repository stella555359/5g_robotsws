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
#Resource    configurators_vran.robot
#Resource    remote.robot
#Resource    wts.robot
#Resource    logging_vran.robot
#Resource    procedures.robot
#Resource    procedures_vran.robot
#Resource    traffic.robot
#Resource    verificators.robot
#Resource    converters.robot
#Resource    pm_counters_vran.robot
#Resource    ./aic/aic_common_resources.robot

*** Keywords ***

Send Custom delta_vCU
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


