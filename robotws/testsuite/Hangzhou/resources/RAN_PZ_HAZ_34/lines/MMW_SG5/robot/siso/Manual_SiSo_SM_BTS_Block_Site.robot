# @Time    : 2023/8/4 13:29
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : Manual_SiSo_SM_BTS_Block_Site.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Documentation
...    author: Chen Jian
...    contact: jian.1.chen@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG05
...    Feature Common SISO

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/siso_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Manual_SiSo_SM_BTS_Block_Site_2.0
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/14 13:57
    [Arguments]    ${ul_tp}=100M    ${dl_tp}=300M    ${shake_tp}=${20}    ${block_times}=${3}
    FOR    ${count}    IN RANGE    ${block_times}
        # Step 1: all services normal
        Verify UE Voice Call Can Be Performed
        ${ul_tp_1}    ${dl_tp_1}    SISO Common L3 CALL    ul_tp=${ul_tp}    dl_tp=${dl_tp}

        # Step 2: block site
        AlarmWatchdog.add_allow_alarms    fault_id=50
        Selenium Login And Disable Screen Lock
        selenium_sbts.block_site
        Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Exist
        ...    fault_id=50    fault_name=BTS blocked
        Wait Until Keyword Succeeds    1min    10s    Verify BTS RUs Status Is BTS Block State
        Wait Until Keyword Succeeds    1min    10s    Verify BTS 5G Cells Status Is BTS Block State
        Wait Until Keyword Succeeds    1min    10s    Verify BTS 4G Cells Status Is Normal State
        ...    blocking_state=Blocked    operational_state=disabled

        # Step 3: rf power transmission is stopped
        Verify_RF_Power_Transmission_Is_Stopped

        # Step 4: unblock site
        selenium_sbts.unblock_site
        Wait Until Keyword Succeeds    15min    30s    Verify BTS RUs Status Is Normal State
        Verify BTS OnAir Ready For L3call
        Wait Until Keyword Succeeds    5min    30s    Verify BTS Alarm Not Exist
        ...    fault_id=50    fault_name=BTS blocked
        AlarmWatchdog.remove_allow_alarms    fault_id=50

        # Step 5: all services normal
        Verify UE Voice Call Can Be Performed
        ${ul_tp_2}    ${dl_tp_2}    SISO Common L3 CALL    ul_tp=${ul_tp}    dl_tp=${dl_tp}
        Verify Two Throughputs Are Similar    ${ul_tp_1}    ${ul_tp_2}    ${shake_tp}
        Verify Two Throughputs Are Similar    ${dl_tp_1}    ${dl_tp_2}    ${shake_tp}
        Selenium Logout And Close Browser
        Run Keyword And Ignore Error    Selenium Logout And Close Browser
    END

Verify_RF_Power_Transmission_Is_Stopped
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/08/01 14:30 only check AWHQU
    ${ru_index_list}    Get All RU Index
#    FOR    ${ru_index}    IN    @{ru_index_list}
#        ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
#        Connect To BTS Csn Via Lmp
#        Run Keyword If    '&{ru_info}[productName]'=='AWHQU'
#        ...    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_username=rfsw
#        ...    ru_password=KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
#        ${ret}    Run Keyword If    '&{ru_info}[productName]'=='AWHQU'
#        ...    ssh.execute    command=dapd-app -sq    connection=RU
#        Run Keyword If    '&{ru_info}[productName]'=='AWHQU'
#        ...    Should Contain    ${ret}    -inf
#    END
#    Verify_RF_Power_Transmission_Is_Stopped_From_Target_Core    position=left
#    Verify_RF_Power_Transmission_Is_Stopped_From_Target_Core    position=right
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${ru_info}   COAM get ru detial info by ru index  ru_index=${ru_index}
        Connect To BTS Csn Via Lmp
        Run Keyword If    '${ru_info}[productName]'=='AWHQU'
        ...    Verify_RF_Power_Transmission_Is_Stopped_From_Target_Core    position=left
        Run Keyword If    '${ru_info}[productName]'=='AWHQU'
        ...    Verify_RF_Power_Transmission_Is_Stopped_From_Target_Core    position=right
    END

Verify_RF_Power_Transmission_Is_Stopped_From_Target_Core
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/03/21 14:32 only check AWHQU
    [Arguments]    ${position}=left
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${ru_username}=rfsw
    ...    ${ru_password}=KRG3dFggxxHw+s0z64U0AR22VyjfnXdHrAVdSv5jpc4=
    ...    ${serial_number}=EB2313R0189
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

    # Step 2: get ru count
    Call Method    ${channel}    send    wc -l /ffs/run/config/FRIps.txt | awk '{print$1}'\n
    Sleep    1 sec
    ${ru_count}    Call Method    ${channel}    recv    ${65535}
    ${ru_count}    Get Line    ${ru_count}    -2
    ${ru_count}    Convert To Integer    ${ru_count}
    Call Method    ${channel}    close

    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}

    FOR    ${index}    IN RANGE    ${ru_count}

        Connect To BTS Csn Via Lmp
        csn.connect_to    hostname=${core_name}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${core_alias}
        ...               proxy=${asik_alias}
        ${connection_service}    csn.get_connection_by_alias    alias=${core_alias}
        ${channel}    Call Method    ${connection_service}    invoke_shell

        # Step 3: get ru ip
        ${index}    Evaluate    ${index} + 1
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$3}'\n
        Sleep    1 sec
        ${ru_ip_addr}    Call Method    ${channel}    recv    ${65535}
        ${ru_ip_addr}    Get Line    ${ru_ip_addr}    -2
        ${ru_ip_addr}    Convert To String    ${ru_ip_addr}
        Run Keyword If    '${ru_ip_addr}'=='0.0.0.0'    Continue For Loop

        # Step 3.1: get ru serial number
        Call Method    ${channel}    send    sed -n '${index}p' /ffs/run/config/FRIps.txt | awk -F';' '{print$4}'\n
        Sleep    1 sec
        ${ru_serial_number}    Call Method    ${channel}    recv    ${65535}
        ${ru_serial_number}    Get Line    ${ru_serial_number}    1
        ${ru_serial_number}    Convert To String    ${ru_serial_number}
        Run Keyword If    '${ru_serial_number}'!='${serial_number}'    Continue For Loop

        # Step 1: connect to container
        Call Method    ${channel}    send    lxc-attach -n ${core_host}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}

        # Step 2: check ru ping success
        Call Method    ${channel}    send    ping -c 30 -W 10 ${ru_ip_addr}\n
        Sleep    35 sec
        ${ping_result}    Call Method    ${channel}    recv    ${65535}
        ${ping_result}    Convert To String    ${ping_result}
        Should contain    ${ping_result}    30 packets transmitted, 30 received

        # Step 3: enable container ssh
        Call Method    ${channel}    send    ps -ef|grep sshd\n
        Sleep    3 sec
        ${output}    Call Method    ${channel}    recv    ${65535}
        ${output}    Convert To String    ${output}
        ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
        ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
        Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
        ...                                            Sleep    3 sec    AND
        ...                                            Call Method    ${channel}    recv    ${65535}
    #    Call Method    ${channel}    close

        # Step 4: ssh to container
        csn.connect_to    hostname=${container_host_ip}
        ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
        ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
        ...               alias=${container_alias}
        ...               proxy=${core_alias}

        # Step 5: ssh to ru
        csn.connect_to    hostname=${ru_ip_addr}
        ...               username=${ru_username}
        ...               password=${ru_password}
        ...               alias=${ru_alias}
        ...               proxy=${container_alias}

        ${ret}    ssh.execute    command=dapd-app -sq    connection=${ru_alias}
        Should Contain    ${ret}    -inf

        #Step 8 disconnect ssh for asik_alias and core_alias
        Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
        Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}
    END

    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
