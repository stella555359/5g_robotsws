# @Time    : 2023/1/24 16:28
# @Author  : Jiao.hu & Jian.1 Chen
# @Email   : jiao.hu@nokia-sbell.com & jian.1.chen@nokia-sbell.com
# @File    : CNI_111312_common_keywords.robot
# @Software: PyCharm
*** Settings ***
Documentation    This is CNI_111312 common keywords
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot

*** Keywords ***
Verify Param Value Via WebEM
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/02/01 16:17
    [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4
    ...    ${filter_param}=RF temperature state
    ...    ${abbr}=rfTemperatureState    ${except_value}=High
    ${value}    selenium_coam.Get Parameter Value    dist_name=${dist_name}
    ...  filter_param=${filter_param}    abbr=${abbr}
    Should Be True    '${value}'=='${except_value}'

Setup Temperature Tresholds at RMOD
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/10/12 20:48
    [Arguments]    ${off_value}=${38.0}
    ...    ${on_value}=${40.0}
    ...    ${timer_value}=${60}
    ...    ${position}=left
    ...    ${asik_alias}=ASIK Master
    ...    ${core_alias}=core_alia
    ...    ${ru_username}=serviceuser
    ...    ${ru_password}=7B+6yyInfX0uES/FP60uEyhjZHUxB2MoRWvZqUMW42g=
    ...    ${container_host_ip}=192.168.255.254
    ...    ${container_alias}=container_alia
    ...    ${ru_alias}=ru_alia
    ...    ${json_file}=/var/tmp/tcs.json
    ...    ${ru_Serial number}=L1213413665
    ...    ${connection}=GNB_OAM
    ${stream}    get stream from version    ${Active_SW_version}
    ${tcs}    Set Variable If    '${stream}'=='SBTS24R2'        tcs
    ...       tcs_parameters
    ${json_file}    Set Variable If    '${stream}'=='SBTS24R2'        /var/tmp/tcs.json
    ...       /var/tmp/tcs_parameters.json

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

    #Step 2345: Get RU Ip from admin cli (update on 2025/05/21 09:55)
    ${ru_ip_addr}    Coam Get RU IP via RMOD object    ru_serial_number=${ru_Serial number}    connection=${connection}

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
    ...    cd /var/tmp
    ${output1}  csn.execute  command=${cmd_temp1}    connection=${ru_alias}
    ${cmd_temp2}   Set Variable
    ...    sudo bfcali -duc ${tcs}
    ${output2}  csn.execute  command=${cmd_temp2}    connection=${ru_alias}
    ${cmd_temp21}   Set Variable
    ...    sudo cat ${json_file}
    ${output21}  csn.execute  command=${cmd_temp21}    connection=${ru_alias}
    ${the_str}    ${off_origin_value}    Should Match Regexp    ${output21}    "T_sym_blank_off": (.*),
    ${the_str}    ${on_origin_value}    Should Match Regexp    ${output21}    "T_sym_blank_on": (.*),
    ${the_str}    ${timer_origin_value}    Should Match Regexp    ${output21}    "T_sym_blank_timer": (.*),
    ${cmd_temp3}    Set Variable
    ...    sudo sed -i 's/"T_sym_blank_off": ${off_origin_value}/"T_sym_blank_off": ${off_value}/g' ${json_file}
    ${output3}  csn.execute  command=${cmd_temp3}    connection=${ru_alias}
    ${cmd_temp31}    Set Variable
    ...    sudo sed -i 's/"T_sym_blank_on": ${on_origin_value}/"T_sym_blank_on": ${on_value}/g' ${json_file}
    ${output31}  csn.execute  command=${cmd_temp31}    connection=${ru_alias}
     ${cmd_temp32}    Set Variable
    ...    sudo sed -i 's/"T_sym_blank_timer": ${timer_origin_value}/"T_sym_blank_timer": ${timer_value}/g' ${json_file}
    ${output32}  csn.execute  command=${cmd_temp32}    connection=${ru_alias}
    ${cmd_temp4}   Set Variable
    ...    sudo bfcali -ciuc ${json_file}
    ${output41}  csn.execute  command=${cmd_temp4}    connection=${ru_alias}

    Run Keyword And Ignore Error    csn.disconnect    connection=${ru_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${container_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${asik_alias}
    Run Keyword And Ignore Error    csn.disconnect    connection=${core_alias}
    [Return]    ${off_origin_value}    ${on_origin_value}    ${timer_origin_value}

Setup Temperature Tresholds On RU With Reset
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/02/04 14:26
    [Arguments]    ${off_value}=102.0    ${on_value}=105.0    ${timer_value}=300    ${connection}=GNB_OAM
    ${result}    Run Keyword And Return Status
    ...    Setup Temperature Tresholds at RMOD    off_value=${off_value}    on_value=${on_value}    timer_value=${timer_value}
    Run Keyword If    ${result}==False    Setup Temperature Tresholds at RMOD    position=right   off_value=${off_value}
    ...    on_value=${on_value}    timer_value=${timer_value}
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    connection=${connection}
    Wait Until Keyword Succeeds    20min    30s    CI_commssion.Verify all cells should be Online

Verify rfCoolingState Value And DL TP
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/02/04 14:33
    [Arguments]    ${cellid}    ${low_tp}    ${high_tp}
    Sleep    60s
    ${tput_log}    power_ue.Collect Tput    ue_type=${UE_TYPE}    duration=40s    ignore_time=1s    check_source=aasyslog
    @{tput_cells}    Create List    ${cellid}
    ${dl_tp}    power_ue.Check Tput    ue_type=${UE_TYPE}    direction=DL    target_throughput=${low_tp}
    ...    log=${tput_log}    cells=${tput_cells}    check_source=aasyslog
#    ${dl_tp}    power_ue.Check throughput   ue_index=0    direction=dl    ue_type=${UE_TYPE}
#    ...    throughput=${low_tp}    cellid=${cellid}
    Should Be True     ${dl_tp[0]["average"]}<${high_tp}

Verify NRCELL304 Overheating And TP Normal
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/02/07 11:02
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    Sleep    15s
    UE Start UL&DL UDP Traffic    ul_tp=110M    dl_tp=350M    parallel=2    duration=1800

    Verify rfCoolingState Value And DL TP    cellid=${NRCELL4_CELLID}
    ...    low_tp=${DL_50_PEAK_LOW_A102}    high_tp=${DL_50_PEAK_HIGH_A102}

    UE Stop Traffic And Release UE

Set PA For CNI111312
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/15 16:55
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    ${channels_to_modify}    create dictionary    1=127    2=127    14=127    15=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=127    4=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    5=12    6=3   7=3    8=3
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    9=127    10=127    11=127   12=127
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3

Restore PA For 6CC CA
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/11/15 16:55
    gnb_classical_hangzhou.Get Initial Attenuation Values For RU
    ${channels_to_modify}    create dictionary    1=24    2=24    14=24    15=24
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=0
    ${channels_to_modify}    create dictionary    3=34    4=34    13=34
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=1
    ${channels_to_modify}    create dictionary    5=12    6=3   7=3    8=3
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=2
    ${channels_to_modify}    create dictionary    9=28    10=24    11=28   12=24
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=&{channels_to_modify}    RU_id=3