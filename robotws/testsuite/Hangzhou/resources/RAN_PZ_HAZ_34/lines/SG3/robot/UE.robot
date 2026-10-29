*** Settings ***
Documentation
...    author: Zhang qingqing
...    contact: qingqing.zhang@nokia-sbell.com
...    squad group: SG_03


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library             taf.ul.mobile.ui.android     WITH NAME   android_mobile

*** Variables ***
${SN}                       ${tl.ues[0].serial_number}
${ue_type}                  ${tl.ues[0].capabilities[0]}
#${DL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
#${UL_PORT}                  ${tl.ues[0].iperf_details.port}
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${DL_TIME}                  600
${DL_LENGTH}                1400B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${wap2apn}                  97 740
${EPCAPP_addr}              ${tl.appserver[1].ssh_connection_details.addr}
${EPCAPP_username}          ${tl.appserver[1].ssh_connection_details.username}
${EPCAPP_password}          ${tl.appserver[1].ssh_connection_details.password}

#${list_of_cell_ids}    Create list    16385    16388


*** Keywords ***
Huawei UE setup
    [Arguments]    ${ue_type}    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

Precondition for Sansumg UE
    [Arguments]    ${ue_type}    ${ui_version}=S20UI2.5    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}    reset_sol=pc_reset

Attach and check power UE
    [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    ...    gnb_index=${gnb_index}

Power UE Start DL traffic
    [Arguments]    ${dl_throughput}   ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}    ${process_num}=${1}    ${ue_type}=${ue_type}    ${protocol}=udp
    ...    ${seg_size}=1180    ${window}=2M    ${cap_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${ue_index}    cap_index=${cap_index}    buffer_size=${dl_length}
    ...                       process_num=${process_num}    protocol=${protocol}    seg_size=${seg_size}    window=${window}

Power UE Start UL traffic
    [Arguments]    ${ul_throughput}   ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}    ${process_num}=${1}    ${ue_type}=${ue_type}    ${seg_size}=1180    ${protocol}=udp
    ...    ${iperf_type}=via_app
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${ue_index}    cap_index=${0}    buffer_size=${ul_length}
    ...                       process_num=${process_num}    seg_size=${seg_size}    protocol=${protocol}
    ...                       iperf_type=${iperf_type}

Stop UL DL data transfer
    [Arguments]    ${ue_index}=${0}    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${ue_type}=${ue_type}
    power_ue.Stop traffic    ue_type=${ue_type}   direction=ul    ue_index=${ue_index}    iperf_port=${ul_port}
    power_ue.Stop traffic    ue_type=${ue_type}   direction=dl    ue_index=${ue_index}    iperf_port=${dl_port}

Check single direction throughput
    [Arguments]    ${expect_throughput}    ${list_of_cell_ids}=${list_of_cell_ids}    ${duration}=1m
    ...            ${gnb_index}=0    ${direction}=DL
    ...            ${target_avg_percent}=0.95    ${min_percent}=0.85    ${ue_type}=${ue_type}    ${ue_index}=${0}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}     duration=${duration}    ue_index=${ue_index}
    ${output}    Power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}    log=${log}   cells=${list_of_cell_ids}
    ...    target_throughput=${expect_throughput}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ue_index=${ue_index}
    [return]    ${output}

Check Bi direction throughput
    [Arguments]    ${ultarget_throughput}    ${dltarget_throughput}    ${list_of_cell_ids}=${list_of_cell_ids}    ${gnb_index}=0
    ...    ${duration}=1m    ${target_avg_percent}=0.95    ${min_percent}=0.85    ${ue_type}=${ue_type}     ${ue_index}=${0}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}     duration=${duration}
    Power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}   cells=${list_of_cell_ids}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    ue_index=${ue_index}

UE Detach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=${DL_PORT}    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${protocol}=udp
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}    ue_index=${ue_index}
    ...    protocol=${protocol}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

set apn to wap2
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   10s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.APN_SETTINGS     connection=cygwin
    sleep   2s
    ${current_window}    csn.read output    connection=cygwin
    Should Contain    ${current_window}    APN_SETTINGS
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   8s
    [Teardown]    csn.disconnect    connection=cygwin

make airplane mode to enable
    [Arguments]    ${ue_index}=${0}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    enable airplane mode UE${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${False}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}

Android UE SwitchApn
    [Documentation]
    ...    Note: Use the keyword must be ensure that UE UI Menu is English language
    ...    str ui_version: mobile ui version.
    ...        e.g Magic UI 3.1.1, have tested on honor CDY-AN90 1080x2400,
    ...            EMUI 10.1.0, have tested on huawei mate30 LIO-AN00 1176x2400.
    ...            Qualcomm qti lahaina for arm64 ue do not have UI, so this field equal to '' or ${None}
    ...           if mobile is mtk peturs, pass 'petrus' as ui_version.
    [Arguments]       ${ue_index}=${0}    ${host}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}     ${ui_version}=${None}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${apn_name}=mdrb    ${ue_alias}=UE_${ue_index}
    android_mobile.setup
    ...               ui_version=${ui_version}    host=${host}    username=${username}
    ...               password=${password}    port=22     serial_number=${serial_number}    alias=${UE_alias}
    android_mobile.switch_apn       apn_name=${apn_name}   mobile=${UE_alias}
    android_mobile.teardown       mobile=${UE_alias}

Android UE Switch network mode
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${gnb_index}=${0}    ${network_mode}=SA+NSA mode
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Run Keyword And Ignore Error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    android_mobile.setup    ui_version=EMUI 10.1.0    host=${cpc_ip}   username=${cpc_usrname}    password=${cpc_passwd}
    ...    port=22    serial_number=${tl.ues[${ue_index}].serial_number}    alias=HUAWEI_UE
    android_mobile.switch_network_mode    mode_name=${network_mode}   restart_time=${90}    mobile=HUAWEI_UE
    android_mobile.teardown       mobile=HUAWEI_UE

DL Tput collect and check with nrcellid
    [Arguments]    ${cellid}    ${dlexpect_tp}    ${ue_type}=${ue_type}    ${duration}=1m    ${gnb_index}=${0}    ${min_percent}=0.85
    ${list_of_cell_ids}    Create list    ${cellid}
    ${log_path}     Power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    gnb_index=${gnb_index}
    ${output}    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log_path}    cells=${list_of_cell_ids}
    ...    target_throughput=${dlexpect_tp}    min_percent=${min_percent}
    [Return]    ${output}

UE attach for QCOM and verify with retry
    [Documentation]      Author: Liu jia
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${4G_check}=False
    ${attach_status}    UE attach for QCOM and verify    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}    4G_check=${4G_check}
    run keyword if    ${attach_status}==${False}
    ...    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    10s
    run keyword if    ${attach_status}==${False}
    ...    UE attach for QCOM and verify    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}    4G_check=${4G_check}

UE attach for QCOM and verify
    [Documentation]      Author: Liu jia
    [Arguments]    ${ue_type}    ${ue_index}    ${gnb_index}    ${4G_check}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ${attach_status}=    Run Keyword And Return Status
    ...    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}
    ...    gnb_index=${gnb_index}
    [Return]    ${attach_status}

Before test reset QCOM use adb command
    [Documentation]      Author: Liu jia
    [Arguments]    ${ue_index}=${0}    ${UE_SN}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=adb -s ${UE_SN} reboot    connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}

##Multi UE##
Multi UE Detach And Stop Traffic
    [Arguments]      ${ue_num}=1
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}
    END
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${0}    hostname=${EPCAPP_addr}
    ...    username=${EPCAPP_username}    password=${EPCAPP_password}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    1s
    [Teardown]    csn.disconnect      connection=EPCAPP

Multi UE Detach
    [Arguments]     ${ue_num}=1     ${ue_type}=${ue_type}
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}    ue_type=${ue_type}
    END

Common UE Detach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=${ue_type}
    log to console     detach UE_${ue_index}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Get UE type
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    [Return]    ${ue_type}

Common Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA    ${ue_type}=${ue_type}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}

Multi-UEs attach and Data Transfer
    [Arguments]    ${ue_num}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}    ${UE_TYPE}=${UE_TYPE}
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
        log to console       Prepare ue${i}
        power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}    get_spark_license=false
        log to console       configure UE${i} mode
        spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${i}
        log to console       UE${i} attach
        ${5Grach_ed}    power_ue.UE Attach    ue_index=${i}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
        sleep   5s
        power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
        sleep    3s
        log to console      Start traffic    console = yes
        power_ue.Start traffic    ue_index=${i}    direction=dl    apn_address=${apn_address}
        ...   throughput=${Multi_dl_throughput}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
        sleep    5s
        log to console      check throughput  console = yes
        power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=${dlexpect}    ue_index=${i}
    END

Multi-UE attach and Verify
    [Arguments]    ${ue_num}    ${attach_mode}    ${nettpye}   ${UE_TYPE}=${UE_TYPE}    #${ue_mode}    ${apn_address}
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
        log to console       Prepare ue${i}
        power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}    get_spark_license=false
        log to console       configure UE${i} mode
        spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${i}
        log to console       UE${i} attach
        ${5Grach_ed}    Run Keyword And Return Status
        ...    power_ue.UE Attach    ue_index=${i}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
        run keyword if  not '${5Grach_ed}' == '${True}'    Common UE Detach    ue_index=${i}    ue_type=${UE_TYPE}
        run keyword if  not '${5Grach_ed}' == '${True}'    sleep    10s
        run keyword if  not '${5Grach_ed}' == '${True}'    power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}    get_spark_license=false
        run keyword if  not '${5Grach_ed}' == '${True}'    spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${i}
        ${5Grach_ed}    run keyword if    '${5Grach_ed}' == '${True}'    set variable    ${0}
        ...    ELSE    power_ue.UE Attach    ue_index=${i}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
        sleep   5s
        power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
    END

Multi-UEs start Data Transfer
    [Arguments]    ${ue_num}    ${ue_mode}    ${apn_address}    ${dlexpect}    ${ue_type}=${UE_TYPE}    ${throughput}=${Multi_dl_throughput}
    ...            ${duration}=2400
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
        log to console      Start traffic    console = yes
        power_ue.Start traffic    ue_index=${i}    direction=dl    apn_address=${apn_address}
        ...    throughput=${throughput}    duration=${duration}    ue_type=${ue_type}    ue_mode=${ue_mode}
        sleep    5s
        log to console      check throughput  console = yes
        power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    ue_index=${i}
    END

MultiUE attach and Capture CPIF log
    [Arguments]    ${attach_mode}    ${nettpye}   ${filename}    #${ue_num}    ${ue_mode}    ${apn_address}
    ...    ${index}=${0}
    log to console       Attach Multi power ue
    log to console       Prepare ue${index}
    power_ue.Prepare UE    ue_index=${index}    ue_type=${UE_TYPE}
    log to console       configure UE${index} mode
    spark.config_5g_deployment    nettype=${nettpye}    ue_alias=UE_${index}
    Start To Capture Wireshark Logs on ASIB    filename=${filename}
    log to console       UE${index} attach
    ${5Grach_ed}    power_ue.UE Attach    ue_index=${index}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
    sleep   5s
    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False

set apn to change
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Set Suite Variable    ${apnset1}    ${usedapn}
    make airplane mode to change    ue_index=${ue_index}    airplane_value=${True}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   10s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.APN_SETTINGS     connection=cygwin
    sleep   2s
    ${current_window}    csn.read output    connection=cygwin
    Should Contain    ${current_window}    APN_SETTINGS
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   8s
    make airplane mode to change    ue_index=${ue_index}    airplane_value=${False}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

make airplane mode to change
    [Arguments]    ${ue_index}=${0}    ${airplane_value}=${False}    #${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    enable airplane mode UE${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${passed}'=='${airplane_value}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}

set apn with special method
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${apn_text}=jierudian    ${location_apn}=380 970
    Set Suite Variable    ${apnset1}    ${usedapn}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${result} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${result}'=='${True}'
        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
        ...    close_task=${close_task}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   10s
    #####Samsung S21 WA to click time cancel
#    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 256 2078    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am start com.android.settings/com.android.settings.Settings     connection=cygwin
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 984 837    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input text ${apn_text}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 510 630    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${location_apn}    connection=cygwin
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell dumpsys window | grep mCurrentFocus    connection=cygwin
    ${current_window}    csn.read output    connection=cygwin
    Should Contain    ${current_window}    $ApnSettingsActivity
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${apnset1}    connection=cygwin
    sleep   8s
    [Teardown]    click ue aireplane moode once    ue_index=${ue_index}

click ue aireplane moode once
    [Arguments]    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${result} =    Check airplane mode status on    ue_index=${ue_index}
    run keyword if    '${result}' != '${True}'
    ...    run keywords    Connect to control pc via cygwin    ue_index=${ue_index}
    ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
    ...    close_task=${close_task}

make voice call with 6688
    [Documentation]    ming.shi
    [Arguments]    ${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    csn.connect_to
    ...    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${connection}
    ...    timeout=${60}
    Sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688    connection=${connection}
    Sleep    1s
    [Teardown]    csn.disconnect    connection=${connection}

hang up voice call
    [Documentation]    ming.shi
    [Arguments]    ${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    csn.connect_to
    ...    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${connection}
    ...    timeout=${60}
    Sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=${connection}
    Sleep    1s
    [Teardown]    csn.disconnect    connection=${connection}

make emc voice call with 911
    [Documentation]    ming.shi
    ...    click DIAL button to make voice call
    ...    Samsung S2x: 538 1959
    ...    SDX80: 711 2952
    [Arguments]    ${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    ...    ${home_button}=${home}    ${DIAL_button}=711 2952
    csn.connect_to
    ...    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${connection}
    ...    timeout=${60}
    Sleep    3s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${home_button}    connection=${connection}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=${connection}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL    connection=${connection}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input text 911    connection=${connection}
    Sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${DIAL_button}    connection=${connection}
    Sleep    1s
    [Teardown]    csn.disconnect    connection=${connection}

hang up emc voice call
    [Documentation]    ming.shi
    ...    click DIAL button to hand up voice call
    ...    Samsung S2x: 538 1959
    ...    SDX80: 720 2759
    [Arguments]    ${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cpc_${ue_index}
    ...    ${home_button}=${home}    ${DIAL_button}=720 2759
    csn.connect_to
    ...    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    alias=${connection}
    ...    timeout=${60}
    Sleep    3s
    ${is_awake}=    csn.execute    command=adb -s ${serial_number} shell dumpsys window | grep mAwake    connection=${connection}
    ${status}=    Run Keyword And Return Status    Should Contain    mAwake=false    ${is_awake}
    IF   ${status}
        csn.send_command    command=adb -s ${serial_number} shell input keyevent ${home_button}    connection=${connection}
        Sleep    2s
        csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=${connection}
        Sleep    2s
    END
    csn.send_command    command=adb -s ${serial_number} shell input tap ${DIAL_button}    connection=${connection}
    Sleep    1s
    [Teardown]    csn.disconnect    connection=${connection}
