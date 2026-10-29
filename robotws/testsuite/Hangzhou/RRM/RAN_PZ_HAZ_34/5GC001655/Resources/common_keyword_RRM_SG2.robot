*** Settings ***
Documentation
...    author: yulu
...    contact: lu.1.yu@nokia-sbell.com
...    Group: HGZ_SG2

Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library     py_script.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Variables     common_variables_sg2.py



*** Keywords ***
Restart CPE proxy
    ${comand_proxy}    Catenate    SEPARATOR=${SPACE}
    ...   cd /home/ute/fastmile_ue_proxy/
    ...   && sh -c 'nohup python3.10 ueproxy-1.21.0-py310-linux-fastmile-1.16.1.pyz -c config.cfg --port 5555 > myout.txt 2>&1 &'
    Run Keyword And Ignore Error    OperatingSystem.Run    ps -ef|grep -i python
    sleep    3s
    Run Keyword And Ignore Error    OperatingSystem.Run    killall python3.10
    sleep    3s
    Run Keyword And Ignore Error    OperatingSystem.Run    ${comand_proxy}
    sleep    3s
    Run Keyword And Ignore Error    OperatingSystem.Run    ps -ef|grep -i python
    sleep    3s

Check for unexpected alarms
    Connect to gnb coam via ssl
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...    connection=GNB_OAM
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}    connection=GNB_OAM

Reboot cpe for test
    [Arguments]    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True

enable 72e and commission scf
    [Arguments]    ${scf_path}    ${activate_plan_despite_errors}    ${is_need_to_check_validation_errors}
    ...         ${switch_to_mode}=72e    ${gnb_index}=0    ${log_path}=${TS_CASE_LOG_PATH}
    ${vendor_file_name}    Download Vendor File    gnb_index=${gnb_index}    log_path=${log_path}
    Sleep    5sec
    Modify Vendor file    vendor_file_name=${vendor_file_name}    switch_to_mode=${switch_to_mode}
    Sleep    5sec
    ${Status}    Run Keyword And Return Status    Load Vendor File And Commision    scf_path=${scf_path}
    ...                                                                             vendor_file_name=${vendor_file_name}
    ...                                                                             gnb_index=${gnb_index}
    ...                                                                             log_path=${log_path}
    ...                                                                       activate_plan_despite_errors=${activate_plan_despite_errors}
    ...                                                        is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    Run Keyword If    not ${Status}    Load Vendor File And Commision    scf_path=${scf_path}
    ...                                                                  vendor_file_name=${vendor_file_name}
    ...                                                                  gnb_index=${gnb_index}
    ...                                                                  log_path=${log_path}
    ...                                                            activate_plan_despite_errors=${activate_plan_despite_errors}
    ...                                                       is_need_to_check_validation_errors=${is_need_to_check_validation_errors}

Download Vendor File
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM    ${gnb_index}=0
    ${vendor_file_name}    Set Variable    ${log_path}/vendor_download.xml
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    coam.download_vendor_file    target_file_name=${vendor_file_name}    connection=${connection}
    [Return]    ${vendor_file_name}
    [Teardown]    Run Keyword and Ignore Error    COAM Teardown gnb connections    connection=${connection}

Modify Vendor file
    [Arguments]    ${vendor_file_name}
    ...            ${switch_to_mode}=72e
    ...            ${alias}=test_pc
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    Log To Console    \n***start to Modify Vendor file***
    ${param_value_0}    Set Variable If    '${switch_to_mode}'=='72e'    true    false
    ${vendor_0}   Set Variable
    ...  sudo sed -i 's|<p name="actBbPoolingTddFr1Ecpri72e">.*</p>|<p name="actBbPoolingTddFr1Ecpri72e">${param_value_0}</p>|g' ${vendor_file_name}
    ${param_value}    Set Variable If    '${switch_to_mode}'=='72e'    Ecpri72eULDL    disabled
    ${vendor}   Set Variable    sudo sed -i 's|<p name="actEcpri72e">.*</p>|<p name="actEcpri72e">${param_value}</p>|g' ${vendor_file_name}
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    csn.execute    command=${vendor_0}    connection=${alias}
    csn.execute    command=${vendor}    connection=${alias}
    [Teardown]    Run Keyword and Ignore Error    csn.disconnect    connection=${alias}

Load Vendor File And Commision
    [Arguments]    ${scf_path}    ${vendor_file_name}    ${activate_plan_despite_errors}    ${is_need_to_check_validation_errors}
    ...            ${timeout}=${120}    ${gnb_index}=${0}
    ...            ${log_path}=${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    20sec    COAM Navigate to login page via webUI    timeout=${timeout}
    ...                                                                                      gnb_index=${gnb_index}
    ...                                                                                      download_dir=${log_path}
	selenium_coam.enable_virtual_display
    ${result}   selenium_coam.load_vendor_file_and_validate    file_path=${vendor_file_name}
    Run keyword if   '${result}'=='Validation failed!'    selenium_coam.load_vendor_file_and_validate    file_path=${vendor_file_name}
    Sleep   5sec
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}   timeout=${180}
    Log To Console    Start to validate and activate
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    Sleep   60 sec
    Log To Console    activate done!wait for gnb on air......
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    selenium_coam.disable_message_box    AND
    ...                           Run Keyword And Ignore Error    COAM selenium logout

check syslog print
    [Arguments]   ${log_prefix}    ${path}    ${log_path}
    ...            ${target_print}    ${need_fail_case}=${False}
    ...            ${alias}=test_pc
    ...            ${test_pc_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${test_pc_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${test_pc_password}=${tl.test_pc.default_ssh_connection_details.password}
    csn.Connect to     hostname=${test_pc_ip}    username=${test_pc_name}    password=${test_pc_password}    alias=${alias}
    @{list_log_names}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${alias}
    ...    file_indicator=${log_prefix}*
    should not be empty  ${list_log_names}    msg=No file found with log prefix ${log_prefix} under folde
    FOR  ${log_name}  IN  @{list_log_names}
        Set Test Variable    ${tar_zxvf_command}    tar zxvf ${path}/${log_name} -C ${path}
        Run    ${tar_zxvf_command}
        @{list_log_names_1}    ssh_common_commands.get_file_names_under_directory    directory=${path}    connection=${alias}
        ...    file_indicator=SYSLOG*
        should not be empty  ${list_log_names_1}    msg=No file found with log prefix SYSLOG* under folde
        Set Test Variable    ${target num_all}    ${0}
        FOR  ${log_name_1}  IN  @{list_log_names_1}
            ${result_print}    ${target num}    get syslog print by target    log_path=${path}/${log_name_1}    target=${target_print}
            Run keyword if    ${0} < ${target num} <= ${50}    create target print file    result=${result_print}    log_path=${log_path}
            Set Test Variable    ${target num_all}    ${target num}+${target num_all}
        END
        ${target num_all}    evaluate    ${target num_all}
        Run keyword if   '${need_fail_case}'=='${True}'    should be equal   ${target num_all}    ${0}
    END

get syslog print by target
    [Arguments]    ${log_path}    ${target}
    ${result_print}    ${target num}    check_syslog    file_path=${log_path}    target=${target}
    [Return]  ${result_print}    ${target num}

create target print file
    [Arguments]  ${result}    ${log_path}
    FOR  ${result_1}  IN  @{result}
        Run    echo '${result_1}' >> ${log_path}/syslog_target_print.txt
    END
