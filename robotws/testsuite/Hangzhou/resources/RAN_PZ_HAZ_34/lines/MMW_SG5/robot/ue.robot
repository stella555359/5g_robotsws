# @Time    : 2022/3/11 17:00
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : ue.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is common ue keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Library     taf.ul.mobile.ui.android    WITH NAME    android_mobile

*** Keywords ***
UE Make VoNR Call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    ...    ${connection}=cygwin
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Connect to control pc via cygwin    ue_index=${ue_index}
    Sleep    5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=${connection}
    Sleep    2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=${connection}
    Sleep    2s
    #####Make VoNR Call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

UE Hang Up VoNR Call
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}
    Sleep    5s
    #####Hang Up VoNR Call#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}
    ...    AND    UE Stop Traffic And Release UE    ue_index=${ue_index}

Verify UE VoNR Call Status
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    ...    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}
    Sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=${connection}
    Sleep   2s
    ${result}    csn.read output    connection=${connection}
    Should Contain    ${result}    mCallState=${status}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

Verify UE Voice Call Can Be Performed
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    UE Make VoNR Call
    Verify UE VoNR Call Status
    [Teardown]    Run Keyword And Ignore Error    UE Hang Up VoNR Call

UE Attach And Verify 4G
    [Arguments]    ${ue_index}=0
    ${ue_type}    translate_power_ue_type_from_testline    ${ue_index}
    power_ue.Prepare UE    ${ue_type}    ${ue_index}
    ${attach_status}    run keyword and return status  Ue attach with index    ue_index=${ue_index}
    run keyword and continue on failure    turn mobile data on    alias=UE_${ue_index}
    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=adb -s ${tl.ues[${ue_index}].serial_number} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}    timeout=15
    Wait Until Keyword Succeeds    1min    10s    Verify 4G Attach by ADB Command    ${ue_index}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Verify 3G Attach by ADB Command
    [Documentation]   Verify 3G UE network type normal by ADB command.
    [Arguments]    ${ue_index}=${0}    ${sleep_time_before_read_output}=${None}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.send command
    ...    command=adb -s ${serial_number} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ...    timeout=15
    run keyword if    '${sleep_time_before_read_output}'!='${None}'    BuiltIn.sleep    ${sleep_time_before_read_output}
    ${result} =    csn.read output    connection=cpc_${ue_index}
    Should contain  ${result}  HSPAP
    Log to console    \nINFO:3G UE ATTACH successfully.
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${ue_index}

Ulock UE First
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...                Description: Connect to ue pc and unlock ue
    [Arguments]     ${ue_index}=${0}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    log to console  Ulock UE
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin
    Sleep    2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin
    Sleep    2s
    #####Click Home_button#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cygwin
    [Teardown]  run keyword and ignore error    csn.disconnect     connection=cygwin

Reset UE MMW5
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]     ${ue_index}=${0}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
    log to console  \n======Reset UE\n
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} reboot     connection=${connection}
    sleep     90s
    [Teardown]    Run Keyword And Ignore Error     csn.disconnect     connection=${connection}

UE Mobile Data Enable
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell svc data enable    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

UE Mobile Data Disable
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell svc data disable    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

UE Switch Network Mode After Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/31 16:22
    [Arguments]    ${ui_version}=one ui 3.1    ${mode_name}=5G/LTE/3G/2G (auto connect)    ${connection}=ue_switch_network_mode
    ...    ${ue_index}=${0}
    android_mobile.setup
    ...   ui_version=${ui_version}
    ...   host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...   username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...   password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...   port=22
    ...   serial_number=${tl.ues[${ue_index}].serial_number}
    ...   alias=${connection}
    android_mobile.switch_network_mode    mode_name=${mode_name}    mobile=${connection}
    android_mobile.teardown    mobile=${connection}

UE Switch Apn After Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/31 16:22
    [Arguments]    ${ui_version}=one ui 3.1    ${apn_name}=mdrb1.nokia.com    ${connection}=ue_switch_apn
    ...    ${ue_index}=${0}
    android_mobile.setup
    ...   ui_version=${ui_version}
    ...   host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...   username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...   password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...   port=22
    ...   serial_number=${tl.ues[${ue_index}].serial_number}
    ...   alias=${connection}
    android_mobile.switch_apn    apn_name=${apn_name}    mobile=${connection}
    android_mobile.teardown    mobile=${connection}

LTE UE Attach And Verify DL Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/17 13:45
    ...    v1.1 changed by yinhua.zhang@nokia-sbell.com  run LTE DL Tput funtion based on UE type
    ...    v1.1 because possibly failed when run LTE DL Tput keyword with Non-qualcomm UE
    ...    v1.1 add input parameters ui_version/mode_name for variable UE, default value is for samsung
    [Arguments]    ${dt_name}=dl_traffic    ${duration}=10min    ${ue_index}=${0}
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${ui_version}=one ui 3.1
    ...    ${mode_name_4G}=LTE/3G/2G (auto connect)
    ...    ${mode_name_5G}=5G/LTE/3G/2G (auto connect)
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Wait Until Keyword Succeeds    5x    10s    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    # qualcomm UE can't use this function to switch network mode, because underlying code is unapplicable,
    # the menu name of network mode is different from real UE's.
    IF    '${ue_type}'=='qct_dx50' or '${ue_type}'=='qualcomm'
        Log To Console    No need to do network mode switch for Qualcomm UE
    ELSE
        UE Switch Network Mode After Attach    ui_version=${ui_version}    mode_name=${mode_name_4G}
    END
    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    Log To Console    These 2 argument is not used: ${dt_name} ${duration}
    # Run Keyword If    '${ue_type}'=='qct_dx50'    LTE UE Verify DL Throughput    throughput=${throughput}
    # ...    dt_name=${dt_name}    duration=${duration}    ue_index=${ue_index}

    [Teardown]    Restore network mode    ue_type=${ue_type}    ue_index=${ue_index}
    ...    ui_version=${ui_version}    mode_name_4G=${mode_name_4G}    mode_name_5G=${mode_name_5G}

LTE UE Verify DL Throughput
    [Arguments]    ${throughput}=10 Mbits/sec    ${dt_name}=dl_traffic    ${duration}=10min    ${ue_index}=${0}
    ute_ue.start_data_transfer    dt_name=${dt_name}    ue_alias=UE_${ue_index}    direction=dl
    ...    duration=${duration}    throughput=${throughput}
    Sleep    10s
    ${dl_tp}    ute_ue.get_average_throughput    dt_name=${dt_name}
    Should Be True    ${dl_tp}>500

Restore network mode
    [Arguments]    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}    ${ue_index}=${0}
    ...    ${ui_version}=one ui 3.1
    ...    ${mode_name_4G}=LTE/3G/2G (auto connect)
    ...    ${mode_name_5G}=5G/LTE/3G/2G (auto connect)
    IF    '${ue_type}'=='qct_dx50' or '${ue_type}'=='qualcomm'
        Log To Console    No need to do network mode switch for Qualcomm UE
    ELSE
        UE Switch Network Mode After Attach    ui_version=${ui_version}    mode_name=${mode_name_5G}
        Log To Console    Changed the network mode from ${mode_name_4G} to ${mode_name_5G}
    END
    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

CPE UE Attach And Verify Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/07/25 14:45
    [Arguments]    ${cell_id}    ${connection}=GNB_OAM
    ${dist_parameters}    coam.get_parameter_by_distname    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    connection=${connection}
    ${physCellId}    Set Variable    ${dist_parameters[0]['parameters']['physCellId']}
    ${arfcnSsbPbch}    Set Variable    ${dist_parameters[0]['parameters']['arfcnSsbPbch']}
    ${nrCellIdentity}    Set Variable    ${dist_parameters[0]['parameters']['nrCellIdentity']}
    nokia_fastmile.Prepare UE
    #nokia_fastmile.Modify UE Capatibility    pci=${physCellId}    arfcn=${arfcnSsbPbch}
    nokia_fastmile.UE Attach    pci=${physCellId}
    nokia_fastmile.Start traffic    direction=dl    duration=180    throughput=10M    ue_index=0
    nokia_fastmile.Start traffic    direction=ul    duration=180    throughput=10M    ue_index=0
    ${tput_log}    nokia_fastmile.Collect Tput    duration=30s
    @{cells}    Create List    ${nrCellIdentity}
    nokia_fastmile.Check Tput    direction=dl    target_throughput=5    cells=${cells}    log=${tput_log}    ue_index=0
    nokia_fastmile.Check Tput    direction=ul    target_throughput=5    cells=${cells}    log=${tput_log}    ue_index=0
    nokia_fastmile.Stop traffic    direction=dl
    nokia_fastmile.Stop traffic    direction=ul
    nokia_fastmile.UE Detach
