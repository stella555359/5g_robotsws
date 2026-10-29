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
Resource    ../resources/L3_call.robot


*** Variables ***
${connection}      GNB_OAM
${SNAPSHOT_TIMEOUT}      600
${if_commissioning}             True
${COMMON_USER_OLD_PASSWORD}     whatever
${COMMON_USER_NEW_PASSWORD}     !Dct183CM.
@{RADIO_MODULE_SCRIPTS_LIST}    RU_Common_capture_IQ_data    RU_Common_capture_L1low_data    RU_Common_capture_register_dump
&{CELLS_WEBEM}    PRIMARY=NRCELL-58311    SECONDARY=NRCELL-58312
&{RMODS_WEBEM}    PRIMARY=RMOD-1/RMOD_R-1 (AEQY)    SECONDARY=RMOD-2/RMOD_R-2 (AEQY)
&{CELLS_ADMIN_CLI}    PRIMARY=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-58311
...    SECONDARY=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-58312
&{RMODS_ADMIN_CLI}    PRIMARY=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-1
...    SECONDARY=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
${TS_LOG_PATH_CLOUD}    /home/ute/test_results

#*** Test Cases ***
*** Keywords ***
Connect to gnb coam via ssl
    [Arguments]  ${connection}=${connection}
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

TC__CB007042_MVP_B_004_Execute_L1low_dump_script_from_Admin_CLI
    Log to Console   START TC__CB007042_MVP_B_004_Execute_L1low_dump_script_from_Admin_CLI
#    Step0: Call For T&T
    Step 0: Precondition
    ${attach_condition}  Attach UE  ue_id=0
#    Check Attach Condition  ${attach_condition}
#    ${ue_type}    translate power ue type from testline    ue_index=0
#    power_ue.Prepare UE    ue_type=${ue_type}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_L1low_data
    ...    script_owner_module=RMOD    output_file_name=${BTS Files}/004_L1low_data_SECONDARY.zip
    ...    cells=${CELLS_ADMIN_CLI['SECONDARY']}    mods=${RMODS_ADMIN_CLI['SECONDARY']}
    Verify Script Launched Successfully From Admin CLI    launch_script=RU_Common_capture_L1low_data
    ...    script_owner_module=RMOD    output_file_name=${BTS Files}/004_L1low_data_PRIMARY.zip
    ...    cells=${CELLS_ADMIN_CLI['PRIMARY']}    mods=${RMODS_ADMIN_CLI['PRIMARY']}
#    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}   ue_index=0
#    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
#    ...    AND     Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    [Teardown]  Detach UE and stop using it  ${ue}

Step 0: Precondition
    Log     \nStep 0: Preconditions  console=${True}
    ${MRBTS_ID}     Get BTS ID
    Set Test Variable    ${mrbtsId}
    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${NRBTS_ID}  ${btsInfo['nrBtsId']}

Verify Script Launched Successfully From Admin CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${launch_script}    ${script_owner_module}    ${output_file_name}
    ...    ${cells}    ${mods}        ${connection}=${connection}     #${free_parameters}=${EMPTY}
    ...    ${timeout}=${1200}
    ${launch_result}    Run Keyword If    '${script_owner_module}' == 'SMOD'
    ...    coam.launch_troubleshooting_script    script_name=${launch_script}    output_file_name=${output_file_name}
    ...    cell_list=${cells}    bbmod_list=${mods}    free_parameters=${EMPTY}
    ...    timeout=${timeout}    connection=${connection}
    ...    ELSE    coam.launch_troubleshooting_script    script_name=${launch_script}
    ...    output_file_name=${output_file_name}    cell_list=${cells}    rmod_list=${mods}
    ...    free_parameters=${EMPTY}    timeout=${timeout}    connection=${connection}
    Should Be Equal    ${launch_result}    Launching succeeded. Snapshot has been successfully created.
    ${is_aehc}    Run Keyword And Return Status    Should Be Equal    ${RU_TYPE}    AEHC
    Run Keyword If    ${is_aehc}    Check RU Common Capture On AEHC    ${output_file_name}    ${launch_script}
    ${is_aeqy}    Run Keyword And Return Status    Should Be Equal    ${RU_TYPE}    AEQY
    Run Keyword If    ${is_aeqy}    Check RU Common Capture On AEQY    ${output_file_name}    ${launch_script}

Check RU Common Capture On AEHC
    [Documentation]    Author:jian.1.chen@nokia-sbell.com
    [Arguments]    ${zip_file}    ${script_name}
    ${is_iq_data}    Run Keyword And Return Status    Should Be Equal    ${script_name}    RU_Common_capture_IQ_data
    ${is_register_dump}    Run Keyword And Return Status    Should Be Equal    ${script_name}    RU_Common_capture_register_dump
    Run Keyword If    ${is_iq_data}    Check RU Common Capture IQ Data On AEHC    ${zip_file}
    Run Keyword If    ${is_register_dump}    Check RU Common Capture Register Dump On AEHC    ${zip_file}

Check RU Common Capture On AEQY
    [Documentation]    Author:jian.1.chen@nokia-sbell.com
    [Arguments]    ${zip_file}    ${script_name}
    ${is_l1low_data}    Run Keyword And Return Status    Should Be Equal    ${script_name}    RU_Common_capture_L1low_data
    Run Keyword If    ${is_l1low_data}    Check RU Common Capture L1low Data On AEQY    ${zip_file}

Check RU Common Capture L1low Data On AEQY
    [Documentation]    Author:jian.1.chen@nokia-sbell.com
    [Arguments]    ${zip_file}
    ${unzip_folder}    Remove String    ${zip_file}    .zip
    Run Process    rm -rf ${unzip_folder}    shell=True
    Run Process    unzip ${zip_file} -d ${unzip_folder}    shell=True
    ${ret}    Grep File    ${unzip_folder}/snapshot_file_list.txt    SCRIPT_RESULT_RU_Common_capture_L1low_data
    Should Not Be Empty    ${ret}

Check RU Common Capture IQ Data On AEHC
    [Documentation]    Author:jian.1.chen@nokia-sbell.com
    [Arguments]    ${zip_file}
    ${unzip_folder}    Remove String    ${zip_file}    .zip
    Run Process    rm -rf ${unzip_folder}    shell=True
    Run Process    unzip ${zip_file} -d ${unzip_folder}    shell=True
    Run Process    unzip ${unzip_folder}/BTS_part1.zip -d ${unzip_folder}    shell=True
    ${file_list}    List Directory    ${unzip_folder}
    ${dfe_matches}    Get Matches    ${file_list}    *_DFE*
    Should Not Be Empty    ${dfe_matches}
    FOR    ${index}    IN RANGE    20
        ${matches}    Get Matches    ${file_list}    *_DFE${index}_*
        ${have_matches}    Run Keyword And Return Status    Should Not Be Empty    ${matches}
        Run Keyword If    ${have_matches}    Check RU Common Capture IQ Data DFE    file_list=${matches}    file_path=${unzip_folder}
    END

Check RU Common Capture IQ Data DFE
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_list}    ${file_path}
    ${cmd}    Set Variable    cat
    FOR    ${file}    IN    @{file_list}
        ${cmd}    Set Variable    ${cmd} ${file_path}/${file}
    END
    ${cmd}    Set Variable    ${cmd} > ${file_path}/tmp.tar.gz
    ${tmp_tar}    Run    command=${cmd}
    ${ram_iq}    Run    command=tar -zxvf ${file_path}/tmp.tar.gz -C ${file_path}
    @{ram_iq_files}	Split String	${ram_iq}
    ${file_size}    OperatingSystem.Get File Size    ${file_path}/${ram_iq_files[1]}
    Should Be True    ${file_size}>0
    Run Process    rm -rf ${file_path}/ram    shell=True

Suite Teardown      CB012784 Common Suite Teardown

TC Setup
    Common Test Setup    syslog_launch=${False}

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
