*** Settings ***
Documentation
...            Keywords for scenario procedures
...            author:       Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com
...            maintainer:   Bartosz Bednarczyk, bartosz.bednarczyk@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    Collections

Resource    configurators.robot
Resource    configurators_vran.robot
Resource    verificators.robot
Resource    wts.robot
Resource    traffic.robot

*** Keywords ***
Reach Onair In Multiple Attempts
    [Documentation]    Reaches OnAir state with X2-Link in specified number of attempts,
    ...                rebooting GNB/AP after each failed one.
    ...                - ``wts_cfg``: Path to WTS config file, Default: basic_setup.cfg
    ...                - ``attempts``: Number of attempts to reach OnAir, Default: 3
    ...                - ``skip_x2_link``: If setting X2 link should be skipped, Default: no
    ...                - ``log_dir``: Path to logs directory, Default: ``$\{OUTPUT DIR\}/Logs/``
    [Arguments]    ${wts_cfg}=/opt/wts/latest/basic_setup.cfg    ${attempts}=3    ${log_dir}=${OUTPUT DIR}/Logs/
    ...            ${skip_x2_link}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${attempts}) is int    msg=Invalid KW parameter: attempts
    Should Be True    '${skip_x2_link}' in ('yes','no')    msg=Invalid KW parameter: skip_x2_link
    File Should Exist    ${wts_cfg}
    #---------------------------------------------------------------------------------------------------------------
    Wait Until Keyword Succeeds    ${attempts} times    5s
    ...    Wait for Configured State and Reach Onair    wts_cfg=${wts_cfg}    log_dir=${log_dir}    reboot_on_fail=yes
    ...    skip_x2_link=${skip_x2_link}

Wait for Configured State and Reach Onair
    [Documentation]    Waits for Configured state on all cells and reaches OnAir.
    ...                - ``wts_cfg``: Path to WTS config file, Default: basic_setup.cfg
    ...                - ``log_dir``: Path to logs directory, Default: ``$\{OUTPUT DIR\}/Logs/``
    ...                - ``reboot_on_fail``: If GNB/AP should be reboot on failure, Default: no
    ...                - ``skip_x2_link``: If setting X2 link should be skipped, Default: no
    [Arguments]    ${wts_cfg}=/opt/wts/latest/basic_setup.cfg    ${log_dir}=${OUTPUT DIR}/Logs/    ${reboot_on_fail}=no
    ...            ${skip_x2_link}=no
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    '${reboot_on_fail}' in ('yes','no')    msg=Invalid KW parameter: reboot_on_fail
    Should Be True    '${skip_x2_link}' in ('yes','no')    msg=Invalid KW parameter: skip_x2_link
    #---------------------------------------------------------------------------------------------------------------
    ${status}    Set Variable    FAIL
    Wait Until Keyword Succeeds    5 times    10s    Check if cells are configured
    Start WTS and Reach Onair    wts_cfg=${wts_cfg}    log_dir=${log_dir}    skip_x2_link=${skip_x2_link}
    ${status}    Set Variable    PASS
    [Teardown]    Run Keyword If    '${status}' == 'FAIL' and '${reboot_on_fail}' == 'yes'    Run Keywords
    ...    Log to Console    Failed to Reach Onair
    ...    AND    Teardown Egate If Running    log_dir=${log_dir}/Failed_attempt/
    ...    AND    Reboot GNB and AP
