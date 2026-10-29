*** Settings ***
Documentation
    ...    Author: cristinel.sava@nokia.com
#Resource    ./../resources/Common.robot
Variables   ./../resources/formula_tmo.py
Variables   ./../resources/formula_crt.py
Variables   ./../resources/formula_error.py
Variables    ./../resources/common_vars.py
Library     taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    ./../resources/interface.robot
Resource    ./../resources/taf_coam.robot
Library     ute_syslog
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/verdicts.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot

Library  taf.collectors.pmcounters
Library  ../common_resources/python_resources/PM/PM__RP918_AVERAGE_VALUE_OF_VSWR_counter_M40001.py
Library    ./../resources/python/utils.py
Library      taf.selenium.sbts    WITH NAME    selenium_sbts
#Resource  ../PS/resources/UE__NR_NSA_PS_call.robot
#Resource  ../test_line_specific/SBTS_10831_Tesla/res/UE__NR_NSA_PS_call.robot
Resource  ../resources/UE__NR_NSA_PS_call.robot

*** Variables ***
${SNAPSHOT_TIMEOUT}      600
${if_commissioning}             True
${COMMON_USER_OLD_PASSWORD}     whatever
${COMMON_USER_NEW_PASSWORD}     !Dct183CM.
@{RADIO_MODULE_SCRIPTS_LIST}    RU_Common_capture_IQ_data    RU_Common_capture_L1low_data    RU_Common_capture_register_dump
&{CELLS_WEBEM}    PRIMARY=NRCELL-1    SECONDARY=NRCELL-3
&{RMODS_WEBEM}    PRIMARY=RMOD-1/RMOD_R-1 (AEQY)    SECONDARY=RMOD-2/RMOD_R-2 (AEQY)
&{CELLS_ADMIN_CLI}    PRIMARY=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
...    SECONDARY=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
&{RMODS_ADMIN_CLI}    PRIMARY=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    SECONDARY=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
${TS_LOG_PATH_CLOUD}    /home/ute/test_results

#*** Test Cases ***
*** Keywords ***
TC__test_call_NSA
    Run Keyword    UE__NR_NSA_PS_Call

Connect to gnb coam via ssl
    [Arguments]  ${connection}=GNB_OAM
    ...    ${bts_host}=${MPLANE_IP}
    ...    ${username}=Nemuadmin
    ...    ${password}=nemuuser
    ...    ${ignore_get_release_error}=${True}
    Log    message=\nArgument ignore_get_release_error=${ignore_get_release_error} is not used and will be removed in the future.
    # No more pass release after TAF-2785 Support Auto release detect in admin library.
    # Skip the 'connect_to' operation if the connection can be used normally.
    ${existing_connection}    Run Keyword And Return Status    coam.get_sw_release_name    connection=${connection}
    Run Keyword If	${existing_connection}    Log to console    Connection ${connection} already exists, skip the connection setup
    ...    ELSE    Run Keywords    Log to console    Connection ${connection} does not exist
    ...    AND    coam.connect_to    bts_host=${bts_host}    bts_port=${443}
    ...    username=${username}    password=${password}   name=${connection}

CB007042 CB007045 Precondition
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${old_password}=whatever    ${new_password}=!Dct183CM.    ${connection}=sysadmin
    Connect to gnb coam via ssl    connection=${connection}
    coam.change_local_account_state    account_type=BtsSecurity     enable=True    connection=${connection}
    coam.change_local_account_state    account_type=BtsApplication  enable=True    connection=${connection}
    coam.change_local_account_state    account_type=BtsRead         enable=True    connection=${connection}
    coam.set_user_account    old_username=BTSSecurity    old_password=${old_password}
    ...    new_password=${new_password}    connection=${connection}
    coam.set_user_account    old_username=BTSApplication    old_password=${old_password}
    ...    new_password=${new_password}    connection=${connection}
    coam.set_user_account    old_username=BTSRead    old_password=${old_password}
    ...    new_password=${new_password}    connection=${connection}
    [Teardown]  Run Keyword And Ignore Error    COAM Teardown gnb connections

get stream from version
    [Arguments]  ${active SW version}  ${convert_to_trunk}=${True}
    ${sbts_trunk}    run keyword and return status      Should Match Regexp    ${active SW version}    .*_ENB_(9999|9990)_.*
    @{version_split}    string.split string    ${active SW version}    separator=_
    ${stream}       set variable if      ${sbts_trunk} and ${convert_to_trunk}    SBTS00    ${version_split}[0]
    [Return]  ${stream}

Selenium Login With Version And Account
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    update stream: 2023/10/10 09:40
    [Arguments]    ${username}=Nemuadmin
    ...    ${password}=nemuuser
    ...    ${download_dir}=${TS_LOG_PATH_CLOUD}/selenium_logs    ${timeout}=${60}
    ${stream}    get stream from version    ${active SW version}
    ${version}    Set Variable If    '${stream}'=='SBTS24R1'        SBTS24R1
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=https://${MPLANE_IP}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    selenium_sbts.disable_message_box
    selenium_sbts.disable_screen_lock

Check Troubleshooting Script Details From WebEM
    [Documentation]    Author: cristinel.sava@nokia.com
    [Arguments]    ${details}    ${script_name}    ${script_owner_module}
    Should Be Equal    ${details['Script name']}    ${script_name}
    Should Be Equal    ${details['Script owner module']}    ${script_owner_module}
    Dictionary Should Contain Key    ${details}    Supported fixed parameters
    Dictionary Should Contain Key    ${details}    Script description
    FOR    ${free_text_parameter}    IN    @{details['Free text parameters']}
        Dictionary Should Contain Key    ${free_text_parameter}    Name
        Dictionary Should Contain Key    ${free_text_parameter}    Description
        Dictionary Should Contain Key    ${free_text_parameter}    Value needed
    END

Selenium Logout And Close Browser
    Run Keyword And Ignore Error    Close Start Up View    timeout=5
    Run Keyword And Ignore Error    selenium_sbts.logout
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser

Close Start Up View
    [Documentation]  workarounds for PR530939, should change it back after PR closed
    [Arguments]   ${timeout}=300
    ${close_flag}    selenium_sbts.start_up_view_window_exists    timeout=${timeout}
    run keyword if    ${close_flag}    selenium_sbts.close_start_up_view_window

Check Troubleshooting Script Details From Admin CLI
    [Documentation]    Author: cristinel.sava@nokia.com
    [Arguments]    ${details}    ${script_owner_module}
    Dictionary Should Contain Key    ${details}    scriptName
    Should Be Equal    ${details['scriptOwnerModule']}    ${script_owner_module}
    Dictionary Should Contain Key    ${details}    supportedFixedParameters
    Dictionary Should Contain Key    ${details}    scriptDescription
    FOR    ${free_text_parameter}    IN    @{details['freeTextParameters']}
        Dictionary Should Contain Key    ${free_text_parameter}    name
        Dictionary Should Contain Key    ${free_text_parameter}    description
        Dictionary Should Contain Key    ${free_text_parameter}    valueNeeded
    END

TC__CB007042_MVP_B_001_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_WebEM
    Log to Console   START CB007042_MVP_B_001_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_WebEM
    Set Log Level    ERROR
    Run Keyword     CB007042 CB007045 Precondition    old_password=${COMMON_USER_OLD_PASSWORD}    new_password=${COMMON_USER_NEW_PASSWORD}
    Selenium Login With Version And Account    download_dir=${TS_LOG_PATH_CLOUD}/selenium_logs
    ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details    script_owner_module=Radio module
    ${scripts_names}    Get Dictionary Keys    ${scripts_details}
    Lists Should Be Equal    ${scripts_names}    ${RADIO_MODULE_SCRIPTS_LIST}    ignore_order=True
    FOR    ${script_name}    IN    @{scripts_names}
        Check Troubleshooting Script Details From WebEM    ${scripts_details['${script_name}']}
        ...    script_name=${script_name}    script_owner_module=Radio module
    END
    [Teardown]    Run Keywords    sleep    1s    #robot_common_operations.Common Case Teardown
    ...    AND     Run Keyword And Ignore Error    Selenium Logout And Close Browser

TC__CB007042_MVP_B_003_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_Admin_CLI
    Log to Console   START CB007042_MVP_B_003_List_L1low_dump_and_register_dump_scripts_and_check_descriptions_from_Admin_CLI
    Connect to gnb coam via ssl    connection=${connection}
    ${all_scripts}    coam.get_all_troubleshooting_scripts    script_owner_module=RMOD    connection=${connection}
    FOR    ${script}    IN    @{all_scripts}
        Check Troubleshooting Script Details From Admin CLI    details=${script}    script_owner_module=Radio module
    END

#Suite Teardown      test_call_NSA.Suite Teardown

TC Setup
#    pm_logs_frame.Common Test Setup    syslog_launch=${False}
    Common Test Setup    syslog_launch=${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
#    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown







