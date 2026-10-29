# @Time    : 2023/9/18 16:28
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : CB010823_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is CB010823 common keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library     taf.fdsw.rc    WITH NAME    fdswrc

*** Keywords ***
Set Suite Variables Via SW Version
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/10 19:43
    Run Keyword If    '${Active_SW_version[:24]}'=='SBTS24R3_ENB_0000_000425'
    ...    Set Suite Variable    ${IS_TMO}    True
    ...    ELSE    Set Suite Variable    ${IS_TMO}    False
    Run Keyword If    '${Active_SW_version[:8]}'=='SBTS25R1'
    ...    Set Suite Variable    ${IS_25R1}    True
    ...    ELSE    Set Suite Variable    ${IS_25R1}    False
    Run Keyword If    '${Active_SW_version[:8]}'>='SBTS25R1'
    ...    Set Suite Variable    ${TIME_FORMAT_DIFF_BRANCH}    %d.%m.%Y %H:%M:%S
    ...    ELSE    Set Suite Variable    ${TIME_FORMAT_DIFF_BRANCH}    %Y-%m-%dT%H:%M:%S+08:00
    Run Keyword If    '${Active_SW_version[:8]}'>='SBTS25R1'
    ...    Set Suite Variable    ${DEFINE_RESULT_DIFF_BRANCH}    Execution time of last definitive status GMT+0800
    ...    ELSE    Set Suite Variable    ${DEFINE_RESULT_DIFF_BRANCH}    Execution time of last definitive status
    Run Keyword If    '${Active_SW_version[:8]}'>='SBTS25R1'
    ...    Set Suite Variable    ${EXECUTION_RESULT_DIFF_BRANCH}    Execution time GMT+0800
    ...    ELSE    Set Suite Variable    ${EXECUTION_RESULT_DIFF_BRANCH}    Execution time

Selenium Login With Version And Alia
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${alia}    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...    ${SW_version}=${Active_SW_version}    ${download_dir}=${TS_LOG_PATH_CLOUD}/selenium_logs    ${timeout}=${60}
    ${stream}    get stream from version    ${SW_version}
    ${version}    Set Variable If
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

Activate_SBTS_Package_After_Configuration_Reset
    [Arguments]    ${ip_address}   ${port}=443    ${username}=Nemuadmin   ${password}=nemuuser
    ...    ${auto_discover}=True    ${secure}=True    ${name}=default
    wait until keyword succeeds     10min    30s     fdswrc.connect to    ip_address=${ip_address}   port=${port}    username=${username}
    ...    password=${password}    auto_discover=${auto_discover}    secure=${secure}    name=${name}
    ${activeslot_id}    fdswrc.get_active_sw_partition
    ${reset_option}    fdswrc.get_available_reset_options    slot_id=${activeslot_id}
    fdswrc.software_rollback    sw_slot_id=${activeslot_id}    reset_type=${reset_option[0]}

Verify Diagnostic Check Time Later Than Schedule Time
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/29 11:00
    [Arguments]    ${check_time}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${results}    coam.get_diagnostic_report    connection=${connection}
    FOR    ${result}    IN    @{results}
        Should Be True    '${result['executionTimeOfLastDefinitiveStatus']}'>='${check_time}'
        Should Be True    '${result['executionTime']}'>='${check_time}'
    END
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Analysis Diagnostic Check Result Via WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/10 11:09
    [Arguments]    ${results}    ${time_before_start_diagnostic_check}
    &{analysis_result}    Create Dictionary
    FOR    ${result}    IN    @{results}
        Should Be True    '${result["${DEFINE_RESULT_DIFF_BRANCH}"]}'>='${time_before_start_diagnostic_check}'
        Should Be True    '${result["${EXECUTION_RESULT_DIFF_BRANCH}"]}'>='${time_before_start_diagnostic_check}'
        Should Be True    '${result["Trigger type"]}'=='WebEM'
        ${rmod_names}    Split String    ${result["Target distinguished name"]}    /
        ${rmod_name}    Set Variable    ${rmod_names[-1]}
        ${add_ru}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${analysis_result}    ${rmod_name}
        Run Keyword If    ${add_ru}==True    Set To Dictionary    ${analysis_result}    ${rmod_name}=@{EMPTY}
        ${point_result}    Run Keyword If    '${result["Check status"]}'=='Check point successful'
        ...    Set Variable    ${result["Check point"]}=OK
        ...    ELSE    Set Variable    ${result["Check point"]}=NOK
        Append To List    ${analysis_result["${rmod_name}"]}    ${point_result}
    END
    [Return]    ${analysis_result}

Analysis Diagnostic Check Result Via Admin Cli
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/04 13:50
    [Arguments]    ${results}    ${time_before_start_diagnostic_check}
    &{analysis_result}    Create Dictionary
    FOR    ${result}    IN    @{results}
        Should Be True    '${result["executionTime"]}'>='${time_before_start_diagnostic_check}'
        Should Be True    '${result["executionTimeOfLastDefinitiveStatus"]}'>='${time_before_start_diagnostic_check}'
        Should Be True    '${result["triggerType"]}'=='WebEMRemoteTool'
        ${ru_names}    Split String    ${result["targetDistinguishedName"]}    /
        ${add_ru}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${analysis_result}    ${ru_names[-1]}
        Run Keyword If    ${add_ru}==True    Set To Dictionary    ${analysis_result}    ${ru_names[-1]}=@{EMPTY}
        ${point_result}    Run Keyword If    '${result["checkStatus"]}'=='Check point successful'
        ...    Set Variable    ${result["checkpoint"]}=OK
        ...    ELSE    Set Variable    ${result["checkpoint"]}=NOK
        Append To List    ${analysis_result["${ru_names[-1]}"]}    ${point_result}
    END
    [Return]    ${analysis_result}

Verify Full Diagnostic Check Results Via Admin Cli
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/02 21:23
    [Arguments]    ${expect_result}    ${allow_service_impact}=False    ${connection}=GNB_OAM
    # get time before diagnostic check, verify diagnostic check time is newer
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date
    ...    result_format=%Y-%m-%dT%H:%M:%S+08:00
    Sleep    30s
    ${results}    coam.run_diagnostic_check    allow_service_impact=${allow_service_impact}    connection=${connection}

    ${analysis_result}    Analysis Diagnostic Check Result Via Admin Cli    ${results}    ${time_before_start_diagnostic_check}
    log to console    ${analysis_result}
    Should Be Equal    ${analysis_result}    ${expect_result}

Verify Sanity Check Results Via Admin Cli
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/02 21:23
    [Arguments]    ${expect_result}    ${timeout}=600    ${connection}=GNB_OAM    ${allow_service_impact}=False
    # get time before diagnostic check, verify diagnostic check time is newer
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date
    ...    result_format=%Y-%m-%dT%H:%M:%S+08:00
    Sleep    30s
    ${results}    coam.run_sanity_check    timeout=${timeout}    connection=${connection}    allow_service_impact=${allow_service_impact}

    ${analysis_result}    Analysis Diagnostic Check Result Via Admin Cli    ${results["requestMessage"]}    ${time_before_start_diagnostic_check}
    log to console    ${analysis_result}
    Should Be Equal    ${analysis_result}    ${expect_result}

Verify Full Diagnostic Check Results Via WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/10 10:55
    [Arguments]    ${expect_result}    ${allow_service_impact}=False
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date
    ...    result_format=${TIME_FORMAT_DIFF_BRANCH}

    Selenium Login And Disable Screen Lock
    Wait Until Keyword Succeeds    3x    15s
    ...    selenium_sbts.start_diagnostic_check    scope=Full diagnostic check    timeout=240
    ...    allow_service_impact=${allow_service_impact}
    Wait Until Keyword Succeeds    10min    15s
    ...    verify_operation_succeed_from_operation_history    file_name=/home/ute/MMW_SG5/operation_history.txt
    ...    operation=Monitor diagnostic check completion

    ${report}    selenium_sbts.get_report
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

    ${analysis_result}    Analysis Diagnostic Check Result Via WebEM    ${report["RU diagnostic check report"]}
    ...    ${time_before_start_diagnostic_check}
    log to console    ${analysis_result}
    Should Be Equal    ${analysis_result}    ${expect_result}

Verify Customized Diagnostic Check Results Via WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/10 10:55
    [Arguments]    ${radio_params}    ${expect_result}    ${timeout}=600
    # get time before diagnostic check, verify diagnostic check time is newer
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date
    ...    result_format=${TIME_FORMAT_DIFF_BRANCH}

    Selenium Login And Disable Screen Lock
    Wait Until Keyword Succeeds    3x    15s
    ...    selenium_sbts.start_diagnostic_check    scope=Customized diagnostic check
    ...    radio_checkpoints=${radio_params}    timeout=${timeout}
    ${report}    selenium_sbts.get_report
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

    ${analysis_result}    Analysis Diagnostic Check Result Via WebEM    ${report["RU diagnostic check report"]}
    ...    ${time_before_start_diagnostic_check}
    log to console    ${analysis_result}
    Should Be Equal    ${analysis_result}    ${expect_result}

Verify Customized Diagnostic Check Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/07 10:34
    [Arguments]    ${radio_params}    ${radio_modules}    ${radio_points}    ${trigger_type}=WebEM
    ...    ${last_definitive_result}=Check point successful    ${last_execution_result}=Check point successful
    ...    ${timeout}=600
    # get time before diagnostic check, verify diagnostic check time is newer
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date
    ...    result_format=${TIME_FORMAT_DIFF_BRANCH}

    Selenium Login And Disable Screen Lock
    Wait Until Keyword Succeeds    3x    15s
    ...    selenium_sbts.start_diagnostic_check    scope=Customized diagnostic check
    ...    radio_checkpoints=${radio_params}    timeout=${timeout}
    ${report}    selenium_sbts.get_report
    Run Keyword And Ignore Error    Selenium Logout And Close Browser

    FOR    ${radio_module}    IN    @{radio_modules}
        Verify RU Diagnostic Check Report Normal    ru_diagnostic_check_report=${report['RU diagnostic check report']}
        ...    check_points=${radio_points}    radio_module=${radio_module}
        ...    time_before_start_diagnostic_check=${time_before_start_diagnostic_check}
        ...    trigger_type=${trigger_type}
        ...    last_definitive_result=${last_definitive_result}
        ...    last_execution_result=${last_execution_result}
    END

Trigger AEHC 4681 Alarm
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/27 12:57
    [Arguments]    ${position}=right
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${target_ru_serial}=K9221730206
    ...    ${ru_username}=rfsw
    ...    ${ru_password}=bdS%ztWG3v7%SjreCVA79wTPb
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${restore}=False
    Run Keyword If    '${position}'=='left'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-0a    AND
    ...    Set Test Variable    ${core_host}    0x1018

    Run Keyword If    '${position}'=='right'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-4a    AND
    ...    Set Test Variable    ${core_host}    0x2018

    ${ru_index_list}    get all ru index
    FOR    ${index}    IN    @{ru_index_list}
        # Step 1: ssh to target core (support primary core and secondary core)
        Connect To BTS Csn Via Lmp
        csn.connect_to    hostname=${core_name}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${core_alias}
        ...               proxy=${asik_alias}
        ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
        ${channel}    Call Method    ${connection_service}    invoke_shell

        # Step 3: get ru ip
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
        Sleep    1 sec
        ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
        ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
        ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
        Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Exit For Loop

        # Step 3.1: get ru serial number
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$4}'\n
        Sleep    1 sec
        ${ru_serial_number}    Call Method    ${channel}    recv    ${65535}
        ${ru_serial_number}    Get Line    ${ru_serial_number}    1
        ${ru_serial_number}    Convert To String    ${ru_serial_number}
        ${is_target_ru}    Run Keyword And Return Status    Should Be Equal    ${ru_serial_number}
        ...    ${target_ru_serial}
        Continue For Loop If    '${is_target_ru}'=='False'
        Log To Console    this ru is target ru

        # Step 4: get ru type
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$5}'\n
        Sleep    1 sec
        ${ru_type}    Call Method    ${channel}    recv    ${65535}
        ${ru_type}    Get Line    ${ru_type}    1
        ${ru_type}    Convert To String    ${ru_type}

        # Step 6: connect to container
        Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}

        # Step 8: enable container ssh
        Call Method    ${channel}    send    ps -ef|grep sshd\n
        Sleep    3 sec
        ${output}    Call Method    ${channel}    recv    ${65535}
        ${output}    Convert To String    ${output}
        ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
        ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
        Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
        ...                                            Sleep    3 sec    AND
        ...                                            Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    close

        # Step 9: ssh to container
        csn.connect_to    hostname=${container_host_ip}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${container_alias}
        ...               proxy=${core_alias}

        # Step 10: ssh to ru
        csn.connect_to    hostname=${ru_ip_addr}
        ...               username=${ru_username}
        ...               password=${ru_password}
        ...               alias=${ru_alias}
        ...               proxy=${container_alias}

        ${cmd_temp1}   Set Variable
        ...    echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
        ${output1}  csn.execute  command=${cmd_temp1}    connection=${ru_alias}
        ${cmd_temp2}   Set Variable
        ...    echo "/ action create ThermometerDevice /tmon2 /beamer1/asc1/tmon2"|frmonShellClient 127.0.0.1 2000
        ${output2}  csn.execute  command=${cmd_temp2}    connection=${ru_alias}
        ${cmd_temp3}   Set Variable
        ...    echo "/tmon2 action override FAULTY"|frmonShellClient 127.0.0.1 2000
        ${output3}  csn.execute  command=${cmd_temp3}    connection=${ru_alias}
        ${cmd_temp4}   Set Variable
        ...    cat /ram/fault_history_log_temp.txt
        ${output4}  csn.execute  command=${cmd_temp4}    connection=${ru_alias}
        ${cmd_temp5}   Set Variable
        ...    echo "/tmon2 action override OFF"|frmonShellClient 127.0.0.1 2000
        ${output5}    Run Keyword If    '${restore}'=='True'
        ...    csn.execute  command=${cmd_temp5}    connection=${ru_alias}
        #Run Keyword If    '${restore}'=='True'
        #...    Should Not Contain    ${output5}    EFaultId_TemperValueMissing (1171)

        Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    END

Modify RU Memory Threshold
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/12 20:48
    [Arguments]    ${memory_test_threshold}=${10.0}
    ...    ${position}=right
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${ru_username}=serviceuser
    ...    ${ru_password}=7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${bin_file}=sysmon_primary.bin
    ...    ${json_file}=/ram/sysmon_primary.json
    Run Keyword If    '${position}'=='left'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-0a    AND
    ...    Set Test Variable    ${core_host}    0x1018

    Run Keyword If    '${position}'=='right'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-4a    AND
    ...    Set Test Variable    ${core_host}    0x2018

    ${ru_index_list}    get all ru index
    FOR    ${index}    IN    @{ru_index_list}
        # Step 1: ssh to target core (support primary core and secondary core)
        Connect To BTS Csn Via Lmp
        csn.connect_to    hostname=${core_name}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${core_alias}
        ...               proxy=${asik_alias}
        ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
        ${channel}    Call Method    ${connection_service}    invoke_shell

        # Step 3: get ru ip
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
        Sleep    1 sec
        ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
        ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
        ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
        Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Exit For Loop

        # Step 4: get ru type
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$5}'\n
        Sleep    1 sec
        ${ru_type}    Call Method    ${channel}    recv    ${65535}
        ${ru_type}    Get Line    ${ru_type}    1
        ${ru_type}    Convert To String    ${ru_type}

        # Step 6: connect to container
        Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}

        # Step 8: enable container ssh
        Call Method    ${channel}    send    ps -ef|grep sshd\n
        Sleep    3 sec
        ${output}    Call Method    ${channel}    recv    ${65535}
        ${output}    Convert To String    ${output}
        ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
        ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
        Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
        ...                                            Sleep    3 sec    AND
        ...                                            Call Method    ${channel}    recv    ${65535}
        Call Method    ${channel}    close

        # Step 9: ssh to container
        csn.connect_to    hostname=${container_host_ip}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${container_alias}
        ...               proxy=${core_alias}

        # Step 10: ssh to ru
        csn.connect_to    hostname=${ru_ip_addr}
        ...               username=${ru_username}
        ...               password=${ru_password}
        ...               alias=${ru_alias}
        ...               proxy=${container_alias}

        ${cmd_temp1}   Set Variable
        ...    echo / action create ConfigAccess /CI/ConfigAccess /module|frmonShellClient 127.0.0.1 2000
        ${output1}  csn.execute  command=${cmd_temp1}    connection=${ru_alias}
        ${cmd_temp2}   Set Variable
        ...    echo '/CI/ConfigAccess action fetch DECODED "${bin_file}" "${json_file}"'|frmonShellClient 127.0.0.1 2000
        ${output2}  csn.execute  command=${cmd_temp2}    connection=${ru_alias}
        ${cmd_temp21}   Set Variable
        ...    cat ${json_file}
        ${output21}  csn.execute  command=${cmd_temp21}    connection=${ru_alias}
        ${cmd_temp3}    Set Variable
        ...    sudo sed -i 's/"memoryTestThreshold": 100.0/"memoryTestThreshold": ${memory_test_threshold}/g' ${json_file}
        ${output3}  csn.execute  command=${cmd_temp3}    connection=${ru_alias}
        ${cmd_temp31}    Set Variable
        ...    sudo sed -i 's/"memoryTestThreshold": 10.0/"memoryTestThreshold": ${memory_test_threshold}/g' ${json_file}
        ${output31}  csn.execute  command=${cmd_temp31}    connection=${ru_alias}
        ${cmd_temp212}   Set Variable
        ...    cat ${json_file}
        ${output212}  csn.execute  command=${cmd_temp212}    connection=${ru_alias}
        ${cmd_temp4}   Set Variable
        ...    echo '/CI/ConfigAccess action store PERMANENT DECODED "${bin_file}" "${json_file}"'|frmonShellClient 127.0.0.1 2000
        ${output4}  csn.execute  command=${cmd_temp4}    connection=${ru_alias}

        Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    END

Modify RU Swman Digest
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/29 16:40
    [Arguments]
    ...    ${position}=left
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${ru_username}=rfsw
    ...    ${ru_password}=bdS%ztWG3v7%SjreCVA79wTPb
    ...    ${ru_Serial number}=L1205002766
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${restore_digest}=False

    Run Keyword If    '${position}'=='left'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-0a    AND
    ...    Set Test Variable    ${core_host}    0x1018

    Run Keyword If    '${position}'=='right'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-4a    AND
    ...    Set Test Variable    ${core_host}    0x2018

    # Step 1: ssh to target core (support primary core and secondary core)
    Connect To BTS Csn Via Lmp
    csn.connect_to    hostname=${core_name}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${core_alias}
    ...               proxy=${asik_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}

    ${channel}    Call Method    ${connection_service}    invoke_shell
    #Step 2: get ru Serial number
    Call Method    ${channel}    send    sed -n '1p' /ffs/run/config/FRIps.txt | awk -F';' '{print$4}'\n
    Sleep    1 sec
    ${ru_sn}    Call Method    ${channel}    recv    ${65535}
    Log To Console    ${ru_sn}
    ${ru_sn}    Get Line    ${ru_sn}    -2
    ${ru_sn}    Convert To String    ${ru_sn}
    # Step 3: get ru ip
    Run Keyword If    '${ru_sn}'=='${ru_Serial number}'    Run Keyword
    ...    Call Method    ${channel}    send    sed -n '1p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
    Run Keyword If    '${ru_sn}'!='${ru_Serial number}'    Run Keyword
    ...    Call Method    ${channel}    send    sed -n '2p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
    Sleep    1 sec
    ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
    ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
    ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
    Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Exit For Loop

    # Step 4: get ru type
    Run Keyword If    '${ru_sn}'=='${ru_Serial number}'    Run Keyword
    ...    Call Method    ${channel}    send    sed -n '1p' /ffs/run/config/FRIps.txt | awk -F';' '{print$5}'\n
    Run Keyword If    '${ru_sn}'!='${ru_Serial number}'    Run Keyword
    ...    Call Method    ${channel}    send    sed -n '2p' /ffs/run/config/FRIps.txt | awk -F';' '{print$5}'\n
    Sleep    1 sec
    ${ru_type}    Call Method    ${channel}    recv    ${65535}
    ${ru_type}    Get Line    ${ru_type}    1
    ${ru_type}    Convert To String    ${ru_type}

    # Step 6: connect to container
    Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

    # Step 8: enable container ssh
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close

    # Step 9: ssh to container
    csn.connect_to    hostname=${container_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${core_alias}

    # Step 10: ssh to ru
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}

    Run Keyword If    ${restore_digest}==False    Modify RU Swman Digest To Default Value    ru_alias=${ru_alias}
    ...    ELSE    Modify RU Swman Digest To Origin Value    ru_alias=${ru_alias}
    Log To Console    ${ORIGIN_DIGEST}

    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}

    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Modify RU DDR Post Result
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/09 10:42
    [Arguments]
    ...    ${position}=left
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${ru_username}=serviceuser
    ...    ${ru_password}=wcdjLlTpqEY3cAmOe11u6aELwGI3rDvpGJQvCkcyHZc=
    ...    ${target_ru_sn}=1M204740638
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${restore_ddr}=False
    ...    ${bin_file}=sysmon_secondary.bin
    ...    ${json_file}=/ram/sysmon_secondary.json
    ...    ${connection}=GNB_OAM

    Run Keyword If    '${position}'=='left'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-0a    AND
    ...    Set Test Variable    ${core_host}    0x1018

    Run Keyword If    '${position}'=='right'    Run Keywords
    ...    Set Test Variable    ${core_name}    fct-4a    AND
    ...    Set Test Variable    ${core_host}    0x2018

    # Step 1: ssh to target core (support primary core and secondary core)
    Connect To BTS Csn Via Lmp
    csn.connect_to    hostname=${core_name}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${core_alias}
    ...               proxy=${asik_alias}
    ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}

    ${channel}    Call Method    ${connection_service}    invoke_shell

    #Step 2345: Get RU Ip from admin cli (update on 2025/05/19 10:51)
    ${ru_ip_addr}    Coam Get RU IP via RMOD object    ru_serial_number=${target_ru_sn}    connection=${connection}

    # Step 6: connect to container
    Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}

    # Step 8: enable container ssh
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close

    # Step 9: ssh to container
    csn.connect_to    hostname=${container_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${core_alias}

    # Step 10: ssh to ru
    csn.connect_to    hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}

    ${cmd_temp1}   Set Variable
    ...    echo / action create ConfigAccess /CI/ConfigAccess /module|frmonShellClient 127.0.0.1 2000
    ${output1}  csn.execute  command=${cmd_temp1}    connection=${ru_alias}
    ${cmd_temp2}   Set Variable
    ...    echo '/CI/ConfigAccess action fetch DECODED "${bin_file}" "${json_file}"'|frmonShellClient 127.0.0.1 2000
    ${output2}  csn.execute  command=${cmd_temp2}    connection=${ru_alias}
    ${cmd_temp21}   Set Variable
    ...    cat ${json_file}
    ${output21}  csn.execute  command=${cmd_temp21}    connection=${ru_alias}
    ${cmd_temp3}    Set Variable
    ...    sudo sed -i 's/POST_TEST_PASS/isfail1/g' ${json_file}
    ${output3}  csn.execute  command=${cmd_temp3}    connection=${ru_alias}
    ${cmd_temp31}    Set Variable
    ...    sudo sed -i 's/POST_SLOW_TEST_PASS/isfail2/g' ${json_file}
    ${output31}  csn.execute  command=${cmd_temp31}    connection=${ru_alias}
    ${cmd_temp4}   Set Variable
    ...    cat ${json_file}
    ${output4}  csn.execute  command=${cmd_temp4}    connection=${ru_alias}
    ${cmd_temp5}   Set Variable
    ...    echo '/CI/ConfigAccess action store PERMANENT DECODED "${bin_file}" "${json_file}"'|frmonShellClient 127.0.0.1 2000
    ${output5}  csn.execute  command=${cmd_temp5}    connection=${ru_alias}

    ${cmd_temp6}   Set Variable
    ...    echo '/CI/ConfigAccess action delete "${bin_file}"'|frmonShellClient 127.0.0.1 2000
    ${output6}    Run Keyword If    ${restore_ddr}==True    csn.execute  command=${cmd_temp6}    connection=${ru_alias}

    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}

    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

Modify RU Swman Digest To Default Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/02 10:54
    [Arguments]    ${ru_alias}
    ${output1}    csn.execute    command=SWmanShellCommand -i    connection=${ru_alias}
    ${output1}    Replace String    ${output1}    \r\n    ${EMPTY}
    ${if_active_before_passive}    Run Keyword And Return Status    BuiltIn.Should Match Regexp    ${output1}
    ...    it's active(.*)it's passive
    ${slot}    Run Keyword If    ${if_active_before_passive}==True    Set Variable    0
    ...    ELSE    Set Variable    1

    ${output2}    csn.execute    command=cat /mnt/runtime/swman/swman-integrity_slot${slot}.json    connection=${ru_alias}
    ${digest}    ${digest_value}    Should Match Regexp    ${output2}	"digest": "(\\w+)"
    Set Suite Variable    ${ORIGIN_DIGEST}    ${digest}

    ${change_digest_cmd}    Set Variable
    ...    sed -i 's/${ORIGIN_DIGEST}/"digest": "123"/g' /mnt/runtime/swman/swman-integrity_slot${slot}.json
    ${output3}    csn.execute    command=${change_digest_cmd}    connection=${ru_alias}

    ${output4}    csn.execute    command=cat /mnt/runtime/swman/swman-integrity_slot${slot}.json    connection=${ru_alias}

Modify RU Swman Digest To Origin Value
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/02 16:20
    [Arguments]    ${ru_alias}
    ${output1}    csn.execute    command=SWmanShellCommand -i    connection=${ru_alias}
    ${output1}    Replace String    ${output1}    \r\n    ${EMPTY}
    ${if_active_before_passive}    Run Keyword And Return Status    BuiltIn.Should Match Regexp    ${output1}
    ...    it's active(.*)it's passive
    ${slot}    Run Keyword If    ${if_active_before_passive}==True    Set Variable    0
    ...    ELSE    Set Variable    1

    ${change_digest_cmd}    Set Variable
    ...    sed -i 's/"digest": "123"/${ORIGIN_DIGEST}/g' /mnt/runtime/swman/swman-integrity_slot${slot}.json
    ${output2}    csn.execute    command=${change_digest_cmd}    connection=${ru_alias}

    ${output3}    csn.execute    command=cat /mnt/runtime/swman/swman-integrity_slot${slot}.json    connection=${ru_alias}

Verify Diagnostic Report Fields Normal On WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/22 22:37
    [Arguments]    ${check_point_ids}    ${diagnostic_reports}    ${time_before_start_diagnostic_check}
    FOR    ${report}    IN    @{diagnostic_reports}
        # only check target points
        ${have_point}    Run Keyword And Return Status    List Should Contain Value    ${check_point_ids}
        ...    ${report['Check point Id']}
        Continue For Loop If    '${have_point}'=='False'
        Dictionary Should Contain Key    ${report}    Check point
        Dictionary Should Contain Key    ${report}    Check point name
        Dictionary Should Contain Key    ${report}    Check status
        Dictionary Should Contain Key    ${report}    ${DEFINE_RESULT_DIFF_BRANCH}
        Dictionary Should Contain Key    ${report}    ${EXECUTION_RESULT_DIFF_BRANCH}
        Should Be True    '${report['${DEFINE_RESULT_DIFF_BRANCH}']}'>'${time_before_start_diagnostic_check}'
        Should Be True    '${report['${EXECUTION_RESULT_DIFF_BRANCH}']}'>'${time_before_start_diagnostic_check}'
        Dictionary Should Contain Key    ${report}    Last definitive check status
        Dictionary Should Contain Key    ${report}    Target distinguished name
        Dictionary Should Contain Item    ${report}    trigger type    WebEM
    END

Get Diagnostic Execution Number From Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/28 10:14
    [Arguments]    ${radio_points}    ${core_id}=1011
    ${snapshot_file}    MMW5 Collect Snapshot
    ${DiagnosticHistoryHistogram}    get_diagnostic_report_from_snapshot
    ...    BTS${MRBTS_ID}_${core_id}_DiagnosticHistoryHistogram.csv    ${snapshot_file}
    ${number_of_executions}    Set Variable    0
    FOR    ${check}    IN    @{DiagnosticHistoryHistogram}
        ${executions}    Convert To Integer    ${check["Number of executions"]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${radio_points}    ${check["Check point"]}
        ${number_of_executions}    Run Keyword If    ${status}    Evaluate    ${number_of_executions}+${executions}
        ...    ELSE    Set Variable    ${number_of_executions}
    END
    [Return]    ${number_of_executions}

Get Single Diagnostic Execution Number From Snapshot
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/01/08 14:56
    [Arguments]    ${snapshot_file}    ${check_point}    ${dist_name}    ${core_id}=1011
    ${DiagnosticHistoryHistogram}    get_diagnostic_report_from_snapshot
    ...    BTS${MRBTS_ID}_${core_id}_DiagnosticHistoryHistogram.csv    ${snapshot_file}
    ${number_of_executions}    Set Variable    0
    FOR    ${check}    IN    @{DiagnosticHistoryHistogram}
        Continue For Loop If    '${check["Check point"]}'!='${check_point}'
        Continue For Loop If    '${check["Target distinguished name"]}'!='${dist_name}'
        ${number_of_executions}    Convert To Integer    ${check["Number of executions"]}
    END
    [Return]    ${number_of_executions}

Verify RU Diagnostic Check Report Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/22 16:29
    [Arguments]    ${ru_diagnostic_check_report}    ${check_points}
    ...    ${time_before_start_diagnostic_check}
    ...    ${radio_module}=ALL    ${trigger_type}=WebEM
    ...    ${last_definitive_result}=Check point successful
    ...    ${last_execution_result}=Check point successful
    @{check_point_ids}    Create List
    FOR    ${result}    IN    @{ru_diagnostic_check_report}
        ${rmod_names}    Split String    ${result["Target distinguished name"]}    /
        ${rmod_name}    Set Variable    ${rmod_names[-1]}
        Continue For Loop If    '${rmod_name}'!='${radio_module}'
        # only check target points
        ${have_point}    Run Keyword And Return Status    List Should Contain Value    ${check_points}
        ...    ${result['Check point']}
        Continue For Loop If    '${have_point}'=='False'
        Should Be True    '${result['Last definitive check status']}'=='${last_definitive_result}'
        Should Be True    '${result['Check status']}'=='${last_execution_result}'
        Should Be True    '${result['Trigger type']}'=='${trigger_type}'
        Should Be True    '${result['${DEFINE_RESULT_DIFF_BRANCH}']}'>'${time_before_start_diagnostic_check}'
        Should Be True    '${result['${EXECUTION_RESULT_DIFF_BRANCH}']}'>'${time_before_start_diagnostic_check}'
        Append To List    ${check_point_ids}    ${result['Check point']}
    END
    Should Be Equal    ${check_point_ids}    ${check_points}

Verify Diagnostic Check Result Via Admin CLI For 25R1
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/11 14:13
    [Arguments]    ${check_point_id}    ${dist_name}    ${result}    ${connection}=GNB_OAM
    ${diagnostic_result}    coam.run_diagnostic_check    connection=${connection}
    FOR    ${report}    IN    @{diagnostic_result}
        Continue For Loop If    ${report['checkpointId']}!=${check_point_id}
        Continue For Loop If    '${report['distName']}'!='${dist_name}'
        Should Be True    '${report['lastDefinitiveResult']}'=='${result}'
        Should Be True    '${report['lastResult']}'=='${result}'
    END

Verify Diagnostic Check Result Via Admin CLI
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/11 14:13
    [Arguments]    ${check_point_id}    ${dist_name}    ${result}    ${connection}=GNB_OAM
    ${diagnostic_result}    coam.run_diagnostic_check    connection=${connection}
    FOR    ${report}    IN    @{diagnostic_result}
        Continue For Loop If    ${report['checkpoint']}!=${check_point_id}
        Continue For Loop If    '${report['targetDistinguishedName']}'!='${dist_name}'
        Should Be True    '${report['lastDefinitiveCheckStatus']}'=='${result}'
        Should Be True    '${report['checkStatus']}'=='${result}'
    END

Modify RU Memory Threshold Trigger 41 NOK&OK
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define 2023/10/13 10:22
    [Arguments]    ${memory_test_threshold}=${10.0}
    Modify RU Memory Threshold    memory_test_threshold=${memory_test_threshold}
    Selenium Login And Disable Screen Lock
    selenium_sbts.reset_ru    ru_index=1
    selenium_sbts.reset_ru    ru_index=2
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Sleep    300s
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

Modify RU DDR Post Result Trigger 43 NOK&OK
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define 2023/10/13 10:22
    [Arguments]    ${ru_index}=1    ${position}=left    ${restore_ddr}=False    ${connection}=GNB_OAM
    ${distname}    get_ru_distname_via_admin    ru_index=${ru_index}
    ${ru_parameters}    coam.get_parameters_for    RMOD    ${distname}    connection=${connection}
    ${target_ru_sn}    Set Variable    ${ru_parameters["serialNumber"]}
    Log To Console    target RU SN is ${target_ru_sn}
    Modify RU DDR Post Result    position=${position}    target_ru_sn=${target_ru_sn}    restore_ddr=${restore_ddr}
    ...    connection=${connection}
    Selenium Login And Disable Screen Lock
    selenium_sbts.reset_ru    ru_index=${ru_index}
    Run Keyword And Ignore Error    Selenium Logout And Close Browser
    Sleep    300s
    Wait Until Keyword Succeeds    10min    15s    CI_commssion.Verify all cells should be Online

Verify NOK Check Points On WebEM Reports
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/01 23:16
    [Arguments]    ${reports}    ${module_type}    ${module_name}    ${check_point_id}
    ${result}    run keyword and return status    should contain    ${Active_SW_version}    24R3
    FOR    ${report}    IN    @{reports}
        ${status}    Run Keyword And Return Status    Should Not Contain    ${report['${module_type}']}
        ...    ${module_name}
        run keyword if    ${result}    Run Keywords    Continue For Loop If    ${status}    AND    Continue For Loop If
        ...    '${report['ID']}'!='${check_point_id}'    AND    Should Be True
        ...    '${report['Last definitive result']}'=='NOK'    AND    Should Be True
        ...    '${report['Last execution result']}'=='NOK'    ELSE    Run Keywords    Continue For Loop If    ${status}
        ...    AND    Continue For Loop If    '${report['Check point']}'!='${check_point_id}'    AND    Should Be True
        ...    '${report['Last definitive check status']}'=='Check point failure'    AND    Should Be True
        ...    '${report['Check status']}'=='Check point failure'
    END

Verify Diagnostic Report Check Point Ids Normal On WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/22 22:52
    [Arguments]    ${diagnostic_reports}    ${check_point_ids}
    ${ids}    Create List
    ${result}    run keyword and return status    should contain    ${Active_SW_version}    24R3
    FOR    ${output}    IN    @{diagnostic_reports}
        ${Check_point_id}=    Set Variable If    ${result}    ${output['Check point Id']}    ${output['Check point']}
        ${int_id}    Convert To Integer    ${Check_point_id}
        Append To List    ${ids}    ${int_id}
    END
    ${ids}    Remove Duplicates    ${ids}
    Sort List    ${ids}
    List Should Contain Sub List    ${ids}    ${check_point_ids}

Verify Diagnostic History Report Fields Normal On WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/27 10:03
    [Arguments]    ${diagnostic_reports}
    ${result}    run keyword and return status    should contain    ${Active_SW_version}    24R3
    FOR    ${report}    IN    @{diagnostic_reports}
        Run Keyword If    ${result}    Run Keywords    Dictionary Should Contain Key    ${report}    Check point Id
        ...    AND    Dictionary Should Contain Key    ${report}    Check point name    AND
        ...    Dictionary Should Contain Key    ${report}    Distname    AND    Dictionary Should Contain Key
        ...    ${report}    number of errors    AND    Dictionary Should Contain Key    ${report}
        ...    number of executions    ELSE    Run Keywords    Dictionary Should Contain Key    ${report}
        ...    Check point    AND    Dictionary Should Contain Key    ${report}    Check point name    AND
        ...    Dictionary Should Contain Key    ${report}    Target distinguished name    AND
        ...    Dictionary Should Contain Key    ${report}    Number of errors    AND    Dictionary Should Contain Key
        ...    ${report}    Number of executions
    END

Verify Diagnostic Report From Snapshot Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/09/26 22:22
    [Arguments]    ${check_point_ids}    ${time_before_start_diagnostic_check}    ${core_id}=2011
    ${snapshot_file}    MMW5 Collect Snapshot
    ${DiagnosticReport}    get_diagnostic_report_from_snapshot    BTS${MRBTS_ID}_${core_id}_DiagnosticReport.csv
    ...    ${snapshot_file}
    Verify Diagnostic Report Fields Normal On WebEM    ${check_point_ids}    ${DiagnosticReport}
    ...    ${time_before_start_diagnostic_check}
    Verify Diagnostic Report Check Point Ids Normal On WebEM    ${DiagnosticReport}    ${check_point_ids}
    ${DiagnosticHistoryHistogram}    get_diagnostic_report_from_snapshot    BTS${MRBTS_ID}_${core_id}_DiagnosticHistoryHistogram.csv
    ...    ${snapshot_file}
    Verify Diagnostic History Report Fields Normal On WebEM    ${DiagnosticHistoryHistogram}
    Verify Diagnostic Report Check Point Ids Normal On WebEM    ${DiagnosticHistoryHistogram}    ${check_point_ids}

    ${blackbox_DiagnosticReport}    get_diagnostic_report_from_snapshot
    ...    BTS${MRBTS_ID}_${core_id}_blackbox_DiagnosticReport.csv    ${snapshot_file}
    Verify Diagnostic Report Fields Normal On WebEM    ${check_point_ids}    ${blackbox_DiagnosticReport}
    ...    ${time_before_start_diagnostic_check}
    Verify Diagnostic Report Check Point Ids Normal On WebEM    ${blackbox_DiagnosticReport}    ${check_point_ids}
    ${blackbox_DiagnosticHistoryHistogram}    get_diagnostic_report_from_snapshot
    ...    BTS${MRBTS_ID}_${core_id}_blackbox_DiagnosticHistoryHistogram.csv    ${snapshot_file}
    Verify Diagnostic History Report Fields Normal On WebEM    ${blackbox_DiagnosticHistoryHistogram}
    Verify Diagnostic Report Check Point Ids Normal On WebEM    ${blackbox_DiagnosticHistoryHistogram}    ${check_point_ids}
