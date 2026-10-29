# @Time    : 2022/6/28 20:05
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB007042_CB007045_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is CB007042 and CB007045 common keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library      taf.selenium.sbts    WITH NAME    selenium_sbts
Library      OperatingSystem

*** Keywords ***
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

Check Troubleshooting Script Details From Admin CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
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

Check Troubleshooting Script Details From WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
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

Verify Script Launched Successfully From WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${launch_script}    ${script_owner_module}
    ...    ${cells}    ${mods}    ${free_text}=${EMPTY}    ${timeout}=${1200}
    ${launch_result}    selenium_sbts.launch_troubleshooting_script
    ...    script_name=${launch_script}    script_owner_module=${script_owner_module}
    ...    cells_name=${cells}    mods_name=${mods}    free_text=${free_text}    timeout=${timeout}
    log    ${launch_result}
    Should Be Equal    ${launch_result['Launching status']}    Launching succeeded
    Should Be Equal    ${launch_result['Collection status']}    Collection completed
    Should Match Regexp    ${launch_result['Collection file']}    SCRIPT_RESULT_${launch_script}_\\d{8}-\\d{4}.zip
    File Should Exist    ${launch_result['Collection file']}
    ${is_aehc}    Run Keyword And Return Status    Should Be Equal    ${RU_TYPE}    AEHC
    Run Keyword If    ${is_aehc}    Check RU Common Capture On AEHC    ${launch_result['Collection file']}    ${launch_script}
    ${is_aeqy}    Run Keyword And Return Status    Should Be Equal    ${RU_TYPE}    AEQY
    Run Keyword If    ${is_aeqy}    Check RU Common Capture On AEQY    ${launch_result['Collection file']}    ${launch_script}

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

Check RU Common Capture Register Dump On AEHC
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${zip_file}
    ${unzip_folder}    Remove String    ${zip_file}    .zip
    Run Process    rm -rf ${unzip_folder}    shell=True
    Run Process    unzip ${zip_file} -d ${unzip_folder}    shell=True
    Run Process    unzip ${unzip_folder}/BTS_part1.zip -d ${unzip_folder}/BTS_part1    shell=True
    ${file_list}    List Directory    ${unzip_folder}/BTS_part1
    ${dfe_matches}    Get Matches    ${file_list}    *_DFE*
    Should Not Be Empty    ${dfe_matches}
    ${bpc_matches}    Get Matches    ${file_list}    *_000*
    Should Not Be Empty    ${bpc_matches}
    FOR    ${file}    IN    @{file_list}
        ${have_bpc}    Run Keyword And Return Status    Should Contain    ${unzip_folder}/BTS_part1/${file}    _00
        Run Keyword If    ${have_bpc}    Check RU Common Capture BPC    ${unzip_folder}/BTS_part1/${file}    ${unzip_folder}/BTS_part1
        ...    ELSE    Check RU Common Capture DFE    ${unzip_folder}/BTS_part1/${file}    ${unzip_folder}/BTS_part1
    END

Check RU Common Capture BPC
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_name}    ${file_path}
    ${pcap_file}    Run    command=tar -zxvf ${file_name} -C ${file_path}
    Should Contain    ${pcap_file}    .pcap

Check RU Common Capture DFE
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${file_name}    ${file_path}
    ${dfe_tar}    Run    command=tar -zxvf ${file_name} -C ${file_path}
    ${file_list}    List Directory    ${file_path}/ram/sd
    FOR    ${file}    IN    @{file_list}
        Should Contain    ${file}    sysdump_
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

Verify Script Launched Failed From WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${launch_script}    ${script_owner_module}
    ...    ${cells}    ${mods}    ${free_text}=${EMPTY}    ${timeout}=${1200}
    ${launch_result}    Run Keyword And Ignore Error    selenium_sbts.launch_troubleshooting_script
    ...    script_name=${launch_script}    script_owner_module=${script_owner_module}
    ...    cells_name=${cells}    mods_name=${mods}    free_text=${free_text}    timeout=${timeout}
    log    ${launch_result}

Verify Account And Script Valid From WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${username}    ${password}    ${scripts}    ${launch_script}
    ...    ${script_owner_module}    ${cells}    ${mods}    ${timeout}=${1200}
    Selenium Login With Version And Account    username=${username}    password=${password}
    ${scripts_details}    selenium_sbts.get_troubleshooting_scripts_details    script_owner_module=${script_owner_module}
    ${scripts_names}    Get Dictionary Keys    ${scripts_details}
    Lists Should Be Equal    ${scripts_names}    ${scripts}    ignore_order=True
    FOR    ${script_name}    IN    @{scripts_names}
        Check Troubleshooting Script Details From WebEM    details=${scripts_details['${script_name}']}
        ...    script_name=${script_name}    script_owner_module=${script_owner_module}
    END
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Selenium Login With Version And Account    username=${username}    password=${password}
    Verify Script Launched Successfully From WebEM    launch_script=${launch_script}
    ...    script_owner_module=${script_owner_module}    cells=${cells}    mods=${mods}
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Verify Account Invalid From WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${username}    ${password}
    Selenium Login With Version And Account    username=${username}    password=${password}
    ${security_status}    Run Keyword And Return Status    selenium_sbts.get_troubleshooting_scripts_details
    Should Be True    '${security_status}'=='False'
    [Teardown]    Run Keyword And Ignore Error    Selenium Logout And Close Browser

Verify Script Launched Successfully From Admin CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${launch_script}    ${script_owner_module}    ${output_file_name}
    ...    ${cells}    ${mods}    ${free_parameters}=${EMPTY}    ${connection}=GNB_OAM
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

Verify Script Launched Failed From Admin CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${launch_script}    ${output_file_name}
    ...    ${cells}    ${mods}    ${free_parameters}=${EMPTY}    ${connection}=GNB_OAM
    ...    ${timeout}=${1200}
    ${launch_result}    Run Keyword And Ignore Error    coam.launch_troubleshooting_script    script_name=${launch_script}
    ...    output_file_name=${output_file_name}    cell_list=${cells}    rmod_list=${mods}
    ...    free_parameters=${EMPTY}    timeout=${timeout}    connection=${connection}
    Should Contain    ${launch_result[1]}    Launching failed

Selenium Login With Version And Account
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    update stream: 2023/10/10 09:40 
    [Arguments]    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...   ${SW_version}=${Active_SW_version}    ${download_dir}=${TS_CASE_LOG_PATH}/selenium_logs    ${timeout}=${60}
    ${stream}    get stream from version    ${SW_version}
    ${version}    Set Variable If    '${stream}'=='SBTS24R1'        SBTS24R1
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    selenium_sbts.disable_message_box
    selenium_sbts.disable_screen_lock

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

Selenium Login With Version And Alia
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${alia}    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    ${SW_version}=${Active_SW_version}    ${download_dir}=${TS_LOG_PATH_CLOUD}/selenium_logs    ${timeout}=${60}
    ${stream}    get stream from version    ${SW_version}
    ${version}=    Set Variable If
    ...     '${stream}'<='SBTS24R3' and '${stream}'>'SBTS00'    ${stream}
    selenium_sbts.enable_virtual_display
    selenium_sbts.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    ...                    version=${version}
    ...                    alias=${alia}
    selenium_sbts.disable_message_box    sbts=${alia}
    selenium_sbts.disable_screen_lock    sbts=${alia}

Selenium Logout And Close Browser With Alia
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${alia}
    ${close_tag}    selenium_sbts.Start Up View Window Exists    timeout=5    sbts=${alia}
    Run Keyword if    ${close_tag}    selenium_sbts.close_start_up_view_window    sbts=${alia}
    Run Keyword And Ignore Error    selenium_sbts.logout    sbts=${alia}
    Run Keyword And Ignore Error    selenium_sbts.disable_virtual_display
    Run Keyword And Ignore Error    selenium_sbts.close_browser    sbts=${alia}

Check Troubleshooting Logs Are Collected Successfully
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${path}    ${script_name}
    ${files}    List Files In Directory    path=${path}
    Should Match Regexp    '${files}'    SCRIPT_RESULT_${script_name}_\\d{8}-\\d{4}.zip

Concurrent Operations Between Two Scripts From WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${first_script}    ${second_script}    ${cells}    ${rmods}
    # To ensure that the log is received, clear the log directory first
    Run Keyword And Ignore Error    Empty Directory    path=${TS_LOG_PATH_CLOUD}/selenium_logs
    # Two alias: sbts1 and sbts2
    Selenium Login With Version And Alia    sbts1
    Selenium Login With Version And Alia    sbts2
    ${launch_result}    Run Keyword And Ignore Error    selenium_sbts.launch_troubleshooting_script
    ...    script_name=${first_script}
    ...    script_owner_module=Radio module    timeout=${5}
    ...    cells_name=${cells}
    ...    mods_name=${rmods}    sbts=sbts1
    ${launch_result2}    Run Keyword And Ignore Error    selenium_sbts.launch_troubleshooting_script
    ...    script_name=${second_script}
    ...    script_owner_module=Radio module    timeout=${5}
    ...    cells_name=${cells}
    ...    mods_name=${rmods}    sbts=sbts2
    Should Contain Any    '${launch_result2}'
    ...    Launching failed, the operation conflicts due to launch script is ongoing
    ...    Launching failed, the operation conflicts due to snapshot is ongoing
    Wait Until Keyword Succeeds    25min    30sec    Check Troubleshooting Logs Are Collected Successfully
    ...    path=${TS_LOG_PATH_CLOUD}/selenium_logs    script_name=${first_script}
    Sleep    300s
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts1
    ...   AND    Run Keyword And Ignore Error    Selenium Logout And Close Browser With Alia    sbts2
