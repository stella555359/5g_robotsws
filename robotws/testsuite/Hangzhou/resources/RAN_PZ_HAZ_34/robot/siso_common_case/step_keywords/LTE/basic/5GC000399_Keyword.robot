5GC000399_Keyword.robot


*** Settings ***
Documentation    This is common keywords for 5G to LTE related cases
...              Please do not modify the file without notification to author
...              Author: bi jiajian
...              Contact: jiajian.bi@nokia-sbell.com
...              Squard: HZ SG2

Variables         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/5GC000399_variables.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/simple_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Keywords ***
Test Setup
    log to console    \n***SBTS Test Setup***
    Generate SBTS Test Case Log Path
    log to console  CASE_LOG_PATH:${CASE_LOG_PATH}
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
	should be true    ${ru_status}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
	Selenium Login And Disable Screen Lock    download_dir=${CASE_LOG_PATH}    url=https://${sbts_addr}
    ...    username=${http_username}    password=${http_password}    version=${stream}

Test Teardown
    log to console    \n***SBTS Test Teardown***
    Selenium Logout And Close Browser
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    should be true    ${ru_status}

Suite Setup
    log to console    \n***SBTS Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}
    ...    password=${http_password}
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get SBTS SCF File Path    sw_version=${Active_SW_version}
    set suite variable      ${Golden_SCF_Path}
    Generate SBTS Suite Log Path

Suite Teardown
    log to console    \n***SBTS Suite Teardown***
    COAM Teardown gnb connections

Modify parameter online
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    &{param}    Create Dictionary    dist_name=${dist_name}    parameter=${parameter}    value=${value}
    @{modify_param}    Create List    ${param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=600

Check Counter normal
    [Arguments]    ${val}=${10000}
    FOR  ${coun}  IN  @{counter_ru}
        ${value}    Check BTS Counters on webUI    counter_id=${coun}
        should be true    ${value}[-1]>=${val}
    END

Check Counter abnormal
    [Arguments]    ${val}=${0}
    FOR  ${coun}  IN  @{counter_ru_ex}
        ${value}    Check BTS Counters on webUI    counter_id=${coun}
        should be true    ${value}[-1]==${val}
    END

Check BTS Counters on webUI
    [Arguments]    ${counter_id}    ${count_path}=${None}
    COAM Navigate to login page via webUI    download_dir=${CASE_LOG_PATH}
    ...    url=https://${sbts_addr}
    ...    username=${http_username}
    ...    password=${http_password}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${count_path}
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

Modify Calibration File On RU Unit LTE
    [Arguments]    ${current_name}    ${new_name}    ${ru_index}=1
    ${cd_cmd}   Set Variable    cd /mnt/factory/configs/unit;
    ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address LTE    ru_index=${ru_index}
	Connect to BBU
    csn.send_command    command=rm /ffs/run/config/toor4nsn/.ssh/known_hosts    connection=ASIK Master
    sleep    2s
    csn.send_command    command=ssh -o StrictHostKeyChecking\=no ${ru_username}@${ru_ip_addr}    connection=ASIK Master
    Connect to RU With Allocated IP LTE    ru_username=${ru_username}    ru_password=${ru_password}    ru_index=${ru_index}
    ...     ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    sleep    2s
    csn.send_command    command=${cd_cmd}${sudo} ls -l | grep ${current_name}.bin | awk '{print $9}'     connection=RU_${ru_index}
    sleep    2s
    ${result}    csn.read_output    connection=RU_${ru_index}
    ${status}    Run Keyword And Return Status    should match regexp    ${result}    ${current_name}
    sleep    1s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}${sudo} mv ${current_name}.bin ${new_name}.bin     connection=RU_${ru_index}
    sleep    2s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}${sudo} mv ${current_name}.bin.md5 ${new_name}.bin.md5     connection=RU_${ru_index}
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    Run Keyword If    '${status}' == 'True'    selenium_coam.reset_ru  ru_index=${ru_index}
    Run Keyword If    '${status}' == 'True'    sleep    900s
    [Teardown]    csn.disconnect    connection=ASIK Master

Get RU IP Address LTE
    [Arguments]  ${ru_index}=1
    log to console  \n***Get RU IP Address***
    Connect to gnb coam via ssl    bts_host=${sbts_addr}    username=${http_username}    password=${http_password}
    Connect to BBU
    &{ru_info}    COAM get ru detial info by ru index    ru_index=${ru_index}
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}
    should not be equal    ${ru_ip_addr}    0.0.0.0
    [Return]    ${ru_ip_addr}
    [Teardown]    csn.disconnect    connection=ASIK Master

Connect to BBU
    [Arguments]    ${alias}=ASIK Master
    ssh.Connect to    ${sbts_addr}    ${ssh_username}    ${ssh_password}    alias=${alias}

Perform BTS Site Reset LTE
    [Documentation]   Auther: jiajian.bi@nokia-sbell.com
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI LTE   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site    with_graceful=${False}
    [Teardown]  COAM selenium logout

Perform RU Reset LTE
    [Documentation]   Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI LTE   download_dir=${download_dir}
    selenium_coam.reset_ru  ru_index=${ru_index}
    [Teardown]  COAM selenium logout

COAM Navigate to login page via webUI LTE
    [Documentation]  Author: Ding Binmei HGZ_SG4
    ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
    [Arguments]    ${download_dir}=${CASE_LOG_PATH}
    ...            ${timeout}=${60}
    ...            ${url}=https://${sbts_addr}
    ...            ${username}=${http_username}
    ...            ${password}=${http_password}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}
    ...                    username=${username}
    ...                    password=${password}
    ...                    download_dir=${download_dir}
    ...                    timeout=${timeout}
    selenium_coam.disable_message_box

Get Tdanger Value from Json File LTE
    [Arguments]    ${ru_index}=1    ${tcs_file}=tcs
    ${cmd_temp_Shell}   Set Variable    frmonShellClient 127.0.0.1 2000
    log to console    \n Get Tdanger Value from Json File
    Connect to BBU
    Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
    ...   ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...   echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${output}  csn.execute  command=${sudo} cat /var/tmp/${tcs_file}.json | grep -i Tdanger    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Tdanger": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value}   Set Variable    ${init_value_list}[0]
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} ${cmd_temp_Shell}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    [Return]  ${init_value}

get parameter value from tcs json file
    [Arguments]    ${ru_index}=1    ${filter_name}=Tdanger    ${tcs_file}=tcs
    ${cmd_temp_Shell}   Set Variable    frmonShellClient 127.0.0.1 2000
    log to console    \n Get ${filter_name} Value from Json File
    Connect to BBU
    Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
    ...   ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...   echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${output}  csn.execute  command=${sudo} cat /var/tmp/${tcs_file}.json | grep -i ${filter_name}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "${filter_name}": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value}   Set Variable    ${init_value_list}[0]
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} ${cmd_temp_Shell}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    [Return]  ${init_value}

Modify Tdanger Value In Json File with RU reset LTE
    [Arguments]    ${init_value}    ${target_value}    ${cmd}    ${ru_index}=1    ${tcs_file}=tcs
    log    ${cmd}
    ${cmd_temp_Shell}   Set Variable    frmonShellClient 127.0.0.1 2000
    log to console    \n Modify Tdanger Value In Json File
    Connect to BBU
    Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
    ...    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=${sudo} cat /var/tmp/${tcs_file}.json | grep -i Tdanger    connection=RU_${ru_index}
    csn.Send command    command=${sudo} sed -i 's/"Tdanger": ${init_value},/"Tdanger": ${target_value},/g' /var/tmp/${tcs_file}.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /var/tmp/${tcs_file}.json | grep -i Tdanger    connection=RU_${ru_index}
    sleep    2s
    #csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} ${cmd_temp_Shell}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    sleep    90s
    [Teardown]    csn.disconnect    connection=ASIK Master

modify parameter value In tcs json file with RU reset LTE
    [Arguments]    ${init_value}    ${target_value}    ${filter_name}=Thigh    ${ru_index}=1    ${tcs_file}=tcs
    ${cmd_temp_Shell}   Set Variable    frmonShellClient 127.0.0.1 2000
    log to console    \n Modify ${filter_name} Value In Json File
    Connect to BBU
    Connect to RU With Allocated IP LTE    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
    ...    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=${sudo} cat /var/tmp/${tcs_file}.json | grep -i ${filter_name}    connection=RU_${ru_index}
    csn.Send command    command=${sudo} sed -i 's/"${filter_name}": ${init_value},/"${filter_name}": ${target_value},/g' /var/tmp/${tcs_file}.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /var/tmp/${tcs_file}.json | grep -i ${filter_name}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "${tcs_file}.bin" "/var/tmp/${tcs_file}.json"'|${sudo} ${cmd_temp_Shell}
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    selenium_coam.reset_ru  ru_index=${ru_index}
    sleep    90s
    [Teardown]    csn.disconnect    connection=ASIK Master
