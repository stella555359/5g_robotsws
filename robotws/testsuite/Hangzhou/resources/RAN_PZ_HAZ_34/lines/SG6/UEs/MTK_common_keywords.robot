*** Settings ***
Documentation    Author:jun.8.chen@nokia-sbell.com
...              This is for MTK related common keywords.
...              Please do not modify the file without notification to author
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/check_android_ue_l3_call_process.robot


*** Keywords ***
Prepare UE
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...              Description: Precondtion for mtk ue
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    Enable Mobile Data    ue_index=${ue_index}
    ${status}    Run Keyword and Return Status    Wait Until Keyword Succeeds    3 times    5 sec
    ...    MTK_common_keywords.Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}    cpc_alias=${cpc_alias}
    Run Keyword If    ${status}==${False}    Run Keywords
    ...    Sleep    2min    AND
    ...    ADB Reboot UE And Verify Device    ue_index=${ue_index}    AND
    ...    Sleep    6min    AND
    ...    Wait Until Keyword Succeeds    2 times    5 sec    MTK_common_keywords.Precondition for MTK ue attach    ue_index=${ue_index}
    ...                                                                                                             cap_index=${cap_index}
    ...                                                                                                             cpc_alias=${cpc_alias}
    Do UE Detach    ue_index=${ue_index}
    Sleep    2 sec

Prepare UE For MTK80
    [Documentation]   xiangsheng.chu@nokia-sbell.com
    ...              Description: Precondtion for mtk ue
    [Arguments]    ${ue_index}=${0}    ${cap_index}=${0}    ${cpc_alias}=cpc_${ue_index}
    Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    Enable Mobile Data    ue_index=${ue_index}
    ${mtk_prepare}      run keyword and return status     Wait Until Keyword Succeeds    3 times    5 sec
    ...                 MTK_common_keywords.Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare}==${False}    UE Reboot with adb command    ue_index=${ue_index}
    sleep    60s
    ${mtk_prepare_1}    Run Keyword If    ${mtk_prepare}==${False}       run keyword and return status
    ...                 Wait Until Keyword Succeeds    3 times    5 sec
    ...                 MTK_common_keywords.Precondition for MTK ue attach    ue_index=${ue_index}    cap_index=${cap_index}
    ...                 cpc_alias=${cpc_alias}
    Run Keyword If    ${mtk_prepare_1}==${False}      Reset UE Control PC    ue_index=${ue_index}
    sleep    60s
    Run Keyword If    ${mtk_prepare_1}==${False}    Wait Until Keyword Succeeds    3 times    5 sec
    ...               MTK_common_keywords.Precondition for MTK ue attach     ue_index=${ue_index}    cap_index=${cap_index}
    ...               cpc_alias=${cpc_alias}

Do UE Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${UE_alias}=UE_${ue_index}
    ute_ue.Register    ${UE_alias}
    Sleep    5 sec

Do UE Detach
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${UE_alias}=UE_${ue_index}
    MTK_common_keywords.Ue detach    UE_alias=${UE_alias}

Verify UE Attach Success
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${expected_message}=5GMM_REGISTRATION_COMPLETE
    ${attach_expected_messages}    Create list    ${expected_message}
    mtk.expect_messages_in_flow    awaited_messages=${attach_expected_messages}    flow_alias=MTK_OTA_MESSAGE

Start L3 Call
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_ip}
    ...            ${ul_data_transfer}=100M
    ...            ${dl_data_transfer}=2000M
    ...            ${duration}=600
    ...            ${ue_index}=0
    ...            ${buffer_size}=1400B
    ...            ${appserver}=APPserver
    ...            ${protocol}=udp
    ...            ${ue_iperf_path}=/data/local/tmp/iperf
    ${ue_dl_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.port}
    ${ue_ul_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Set Test Variable    ${DL_PORT}    ${ue_dl_port}
    Set Test Variable    ${UL_PORT}    ${ue_ul_port}
    traffic_via_iperf.Start DL traffic via iperf on Appserver    ue_addr=${ue_ip}
    ...                                                          dl_time=${duration}
    ...                                                          dl_port=${DL_PORT}
    ...                                                          dl_throughput=${dl_data_transfer}
    ...                                                          dl_length=${buffer_size}
    ...                                                          appserver=${appserver}
    ...                                                          protocol=${protocol}
    ...                                                          ue_index=${ue_index}
    traffic_via_iperf.Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                             ul_time=${duration}
    ...                                                             ul_port=${UL_PORT}
    ...                                                             ul_throughput=${ul_data_transfer}
    ...                                                             ul_length=${buffer_size}
    ...                                                             appserver=${appserver}
    ...                                                             protocol=${protocol}
    ...                                                             iperf_path=${ue_iperf_path}

Stop L3 Call
    [Documentation]    Auther:jun.8.chen@nokia-sbell.com
    ...                Description: used to stop dl/ul traffic
    [Arguments]    ${ue_index}=0
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}

Collect Throughput
    [Arguments]     ${ue_index}=0
    ...             ${duration}=180
    ...             ${gnb_index}=0
    ...             ${du_index}=0
    ...             ${ignore_time}=1min
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${tput_file}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}   du_index=${du_index}
    ...             duration=${duration}    ignore_time=${ignore_time}

Start UE Attach With MTK
    [Documentation]    Author:li.su@nokia-sbell.com
    ...                this keyword perform MTK attach and verify 5g rach success.
    [Arguments]    ${wireshark_log_prefix}=x2_log_attach
    ...            ${enb_wireshark_log_prefix}=enb_wireshark_log
    ...            ${connection}=ASIK Master
    ...            ${log_dir_ute}=${TS_CASE_LOG_PATH}
    ...            ${ue_index}=${0}
    ...            ${gnb_index}=${0}
    ...            ${du_index}=0
    ...            ${enb_index}=${0}
    ...            ${common_unit_index}=${0}
    ...            ${sleep_interval}=10 sec
    ...            ${coam_connection}=GNB_OAM
    ...            ${mode}=SA
    ...            ${is_do_require_ue}=${True}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${wireshark_log_name}    Set Variable    ${wireshark_log_prefix}_${timestamp}
    ${enb_wireshark_log_name}    Set Variable    ${enb_wireshark_log_prefix}_${timestamp}
    Run Keyword If    ${is_do_require_ue}    MTK_common_keywords.Prepare UE    ue_index=${ue_index}
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log     tcpdump_collector_name=${wireshark_log_name}
    ...                                                                              asik_connection_alias=${connection}
    ...                                                                              gnb_index=${gnb_index}
    ...                                                                              du_index=${du_index}
    Run Keyword If    '${mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Start tcpdump Log On Enb     tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                        enb_index=${enb_index}
    ...                                                                        common_unit_index=${common_unit_index}
    Sleep    ${sleep_interval}
    MTK_common_keywords.Do UE Attach    ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set test variable    ${ue_type}
    Sleep    ${sleep_interval}
    ${wireshark_log_path_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${wireshark_log_name}    target_dir=${log_dir_ute}
    ${enb_wireshark_log_path_on_testPC}    Run Keyword If   '${mode}'=='NSA'
    ...    Run Keyword And Continue On Failure    Stop tcpdump log collection    tcpdump_collector_name=${enb_wireshark_log_name}
    ...                                                                          target_dir=${log_dir_ute}
    ${attach_cell_index}    Get Attach Cell Index From Wireshark    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${mode}
    ${attach_info}    Run Keyword If    '${mode}'=='NSA'    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}
    ...                                                                          attach_cell_index=${attach_cell_index}
    ...                                                                          enb_wireshark_log_path=${enb_wireshark_log_path_on_testPC}
    ...    ELSE    Create Dictionary    cpif_log_path=${wireshark_log_path_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]     ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.stop_collectors    names=${enb_wireshark_log_name}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${enb_wireshark_log_name}

Get UE Airmode status and Turnon Airplane Mode
    [Documentation]  lei.jia@nokia-sbell.com
    ...              Description: get ue airplane mode and turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Check UE device exist    ${ue_index}
    ${airplane_mode}    Get UE Airmode status    ue_index=${ue_index}
    run keyword if    '${airplane_mode}'=='0'    MTK_common_keywords.Turn On Airplane Mode    ue_index=${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Get UE Airmode status and Turnoff Airplane Mode
    [Documentation]  lei.jia@nokia-sbell.com
    ...              Description: get ue airplane mode and turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Check UE device exist    ${ue_index}
#    ADB Reboot UE    ue_index=${ue_index}
#    sleep    30s
#    Connect to control pc enhanced    ${ue_index}
#    csn.send_command   command=adb devices    connection=cpc_${ue_index}
#    csn.send_command   command=adb -s ${serial_number} root    connection=cpc_${ue_index}
#    Check UE device exist    ${ue_index}
    ${airplane_mode}    Get UE Airmode status    ue_index=${ue_index}
    run keyword if    '${airplane_mode}'=='1'    MTK_common_keywords.Turn Off Airplane Mode    ue_index=${ue_index}
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Turn On Airplane Mode
    [Documentation]  lei.jia@nokia-sbell.com
    ...              Description: turn on airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    Csn.Send Command    adb -s ${serial_number} shell "su 0 settings put global airplane_mode_on 1"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    csn.send command    adb -s ${serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    ${result} =    csn.read_output    connection=cpc_${ue_index}
    Should contain    ${result}    result=0
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Turn Off Airplane Mode
    [Documentation]  lei.jia@nokia-sbell.com
    ...              Description: turn off airplane mode for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.Send Command    adb -s ${serial_number} shell "su 0 settings put global airplane_mode_on 0"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    3s
    csn.send command    adb -s ${serial_number} shell "su 0 am broadcast -a android.intent.action.AIRPLANE_MODE"
    ...                 connection=cpc_${ue_index}
    ...                 timeout=5
    sleep    5s
    ${result} =    csn.read_output    connection=cpc_${ue_index}
    Should contain    ${result}    result=0
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

Enable Mobile Data
    [Documentation]  jun.8.chen@nokia-sbell.com
    ...              Description: enable mobile data for MTK UE
    [Arguments]    ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command   command=adb -s ${serial_number} shell svc data enable    connection=cpc_${ue_index}
    Sleep    1s
    [Teardown]    Run keyword and ignore error    csn.disconnect    connection=cpc_${ue_index}

ADB Reboot UE And Verify Device
    [Documentation]   Auther:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${tl.ues[${ue_index}].serial_number} reboot   connection=cpc_${ue_index}
    Sleep    10s
    Wait Until Keyword Succeeds    3 min    10s    Connect ADB devices    alias=cpc_${ue_index}
    ...                                                                   serial_number=${tl.ues[${ue_index}].serial_number}
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}

#--- WA: Clear ELT tmp file---#
Clear Temp File Of ELT For MTK
    [Documentation]  jun.8.chen@nokia-sbell.com
    ...              Description: WA: Clear ELT tmp file to insure UE PC can't full space.
    ...              ELT software must install in specific directory: "C:\MTK\ELT_software"
    ${ue_length}    Get Length    ${tl.ues}
    FOR    ${ue_index}    IN RANGE    ${ue_length}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Run Keyword If    '${ue_type}'=='mtk'    Run Keywords
        ...    Kill ELT process on ue control pc if exists    ue_index=${ue_index}    cpc_alias=cpc_${ue_index}    AND
        ...    Clear ELT Temp File    ue_index=${ue_index}
    END

Clear ELT Temp File
    [Documentation]  jun.8.chen@nokia-sbell.com
    ...              Description: WA: Clear ELT tmp file to insure UE PC can't full space.
    ...              ELT software must install in specific directory: "C:\MTK\ELT_software"
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${cmd}    Catenate    powershell "reg QUERY hkcu\\SOFTWARE\\MediaTek\\EvolvedLoggingTool\\ELT\\ /v LastExecutablePath"
    ...    |grep -i ELT.exe |tail -n 1| awk '{print $3}'
    ${tmp_path}    csn.execute    command=${cmd}    connection=cpc_${ue_index}
    ${path_str}    Set Variable    ${tmp_path.split('C:')[-1].split('ELT.exe')[0]}
    ${path_str}    Replace String    ${path_str}    \\    /
    ${output}    csn.execute    command=cd /cygdrive/c/${path_str}TEMP;ls -l    connection=cpc_${ue_index}
    ${tmp_file_str}    Get Regexp Matches    ${output}    (\\S+).tmp
    FOR    ${tmp_file_str}    IN    @{tmp_file_str}
        ${output}    csn.execute    command=cd /cygdrive/c/${path_str}TEMP;rm -rf ${tmp_file_str}    connection=cpc_${ue_index}
        Should Be Empty   ${output}
    END
    [Teardown]  Run Keyword And Ignore Error    csn.disconnect   connection=cpc_${ue_index}