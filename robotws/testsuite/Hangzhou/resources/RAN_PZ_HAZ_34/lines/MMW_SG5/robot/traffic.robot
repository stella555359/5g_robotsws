# @Time    : 2021/10/25 16:23
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : traffic.robot
# @Software: PyCharm
# @Doc     : Download traffic，upload traffic and so on...
*** Settings ***
Documentation    Common keywords about traffic
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/python/analysis_testline.py
Library     taf.transport.ssh    WITH NAME    csn

*** Keywords ***
Verify Two Throughputs Are Similar
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    The allowable change defaults to 10
    [Arguments]    ${tp1}    ${tp2}    ${allow_change}=${20}
    ${tp_change}    Evaluate    ${tp1}-${tp2}
    Should Be True    ${tp_change}<${allow_change}
    Should Be True    ${tp_change}>-${allow_change}

Verify Two Throughputs Are Percent Similar
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    The allowable change defaults to 3%
    [Arguments]    ${tp1}    ${tp2}    ${allow_change}=0.03
    ${low_percent}    Evaluate    1-${allow_change}
    ${high_percent}    Evaluate    1+${allow_change}
    ${tp_change}    Evaluate    ${tp1}/${tp2}
    Should Be True    ${low_percent}<${tp_change}
    Should Be True    ${tp_change}<${high_percent}

UE Start DL TCP Traffic
    [Arguments]     ${ue_index}=0    ${dl_time}=600    ${dl_port}=0
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${parallel}=${5}    ${mss}=${1180}
    ...    ${app_w}=2M    ${iperf_path}=/data/local/tmp/iperf3    ${app_iperf}=iperf3
    ${ues_trs_info}     get_ues_trs_info
    IF    '${dl_port}'=='0'
        ${dl_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][1]}
    END

    Wait Until Keyword Succeeds    3x    5s    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${dl_port}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell ${iperf_path} -s -i 1 -p ${dl_port}
    ...    connection=cpc_${ue_index}
    Kill the iperf process on APPserver    port=${dl_port}
    ${ue_ip}  Get UE IP Address  ${ue_index}
    csn.send command
    ...    command=${app_iperf} -c ${ue_ip} -t ${dl_time} -i 1 -p ${dl_port} -P ${parallel} -M ${mss} -w ${app_w} &
    ...    connection=APPserver

Close the iperf3 process on UEPC
    [Arguments]     ${ue_index}=0    ${dl_port}=0
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ${ues_trs_info}     get_ues_trs_info
    IF    '${dl_port}'=='0'
        ${dl_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][1]}
    END

    Wait Until Keyword Succeeds    3x    5s    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${dl_port}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=adb -s ${serial_number} shell killall iperf3    connection=cpc_${ue_index}
    [Teardown]    Csn.disconnect      connection=cpc_${ue_index}

UE Start DL Traffic
    [Arguments]    ${throughput}    ${ue_index}=0    ${dl_time}=600
    ...    ${dl_port}=0
    ...    ${hostname}=0
    ...    ${username}=0
    ...    ${password}=0
    ...    ${alias}=APPserver
    ...    ${parallel}=${1}
    ${ues_trs_info}     get_ues_trs_info
    IF    '${dl_port}'=='0'
        ${dl_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][0]}
    END
    ${hostname}      Set Variable    ${ues_trs_info[${ue_index}]["addr"]}
    ${username}      Set Variable    ${ues_trs_info[${ue_index}]["user"]}
    ${password}      Set Variable    ${ues_trs_info[${ue_index}]["password"]}

    Wait Until Keyword Succeeds    1 min    10 sec    csn.Connect to
    ...    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}
    ...    alias=${alias}
#    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=${alias}
#    Kill the iperf process on APPserver    port=${dl_port}
    ${ue_ip}  Get UE IP Address  ${ue_index}
    csn.send command
    ...    command=iperf -c ${ue_ip} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${parallel} -f m -b ${throughput} -l 1400B -T 64&
    ...    connection=${alias}
    Sleep    1s
    csn.Send Command    command=ps -ef|grep iperf|grep -v grep|grep ${ue_ip}| awk '{print $2}'    connection=${alias}
#    ${output}    csn.read_output    size=1000    connection=${alias}
#    ${iperf_pid}    evaluate    ${output.strip()}
#    should be true    ${iperf_pid} > ${0}
    csn.Disconnect   connection=${alias}

UE Start UL TCP Traffic
    [Arguments]    ${ue_index}=0     ${ul_time}=600    ${serial}=${tl.ues[${ue_index}].serial_number}
    ...    ${server_addr}=0    ${ul_port}=0
    ...    ${parallel}=${5}    ${ue_w}=2M
    ...    ${mss}=1180
    ...    ${iperf_path}=/data/local/tmp/iperf3
    ...    ${app_iperf}=iperf3
    ${ues_trs_info}     get_ues_trs_info
    IF    '${ul_port}'=='0'
        ${ul_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][2]}
    END
    ${server_addr}      Set Variable    ${ues_trs_info[${ue_index}]["addr"]}

    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    sleep    10s
    csn.send_command    command=${app_iperf} -s -i 1 -p ${ul_port}    connection=APPserver
    sleep    10s
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=adb -s ${serial} shell ${iperf_path} -c ${server_addr} -t ${ul_time} -i 1 -p ${ul_port} -P ${parallel} -M ${mss} -w ${ue_w} &
    ...    connection=cpc_${ue_index}

Close the iperf3 process on APPserver
    [Arguments]    ${ue_index}=0    ${ul_port}=0
    ${ues_trs_info}     get_ues_trs_info
    IF    '${ul_port}'=='0'
        ${ul_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][2]}
    END

    csn.execute    command=ps -ef|grep iperf|grep ${ul_port}| awk '{print $2}' |xargs kill    connection=APPserver
    sleep    10s

UE Start UL Traffic
    [Arguments]    ${throughput}    ${ue_index}=0    ${ul_time}=600    ${ul_port}=0    ${appserver_addr}=0
    ${ues_trs_info}     get_ues_trs_info
    IF    '${ul_port}'=='0'
        ${ul_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][0]}
    END
    ${appserver_addr}      Set Variable    ${ues_trs_info[${ue_index}]["addr"]}

    ${command}    Catenate    adb -s ${tl.ues[${ue_index}].serial_number} shell /data/local/tmp/iperf
    ...     -c ${appserver_addr} -u -p ${ul_port}
    ...     -t ${ul_time} -P 1 -i 1 -f m -b ${throughput} -l 1400B -T 64
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send_command    command=${command}    connection=cpc_${ue_index}

Get UE IP Address
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...    ${get_ip_command}=shell ip -f inet addr |grep inet | grep -v ims00 | cut -d '/' -f 1 |tail -n +2 |head -1 |awk '{print $2}'
    Connect to control pc enhanced  ${ue_index}
    csn.send_command    command=adb -s ${tl.ues[${ue_index}].serial_number} ${get_ip_command}
    ...    connection=cpc_${ue_index}
    ${ue_ip}    csn.Read Output    connection=cpc_${ue_index}
    ${ue_ip}    String.Replace String    ${ue_ip}    \r\n    ${EMPTY}
    ${ue_ip}    String.Replace String    ${ue_ip}    \n    ${EMPTY}
    [Return]    ${ue_ip}

UE Attach And Check TCP Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    refactored by yinhua.zhang@nokia-sbell.com on 17th Jan 2025

    [Arguments]    ${global_cell_id}=1    ${ul_tp_threshold}=15    ${dl_tp_threshold}=220    ${attach_mode}=SA
    ...    ${traffic_duration}=600    ${ue_index}=${0}    ${need_detach}=True
    ...    ${ignore_cell}=${False}

    # Step 1: prepare ue
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}

    # Step 2: attach ue
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0

    # Step 3: verify ue attach
    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

    # Step 4: start ul&dl tcp traffic
    UE Start DL TCP Traffic    ${ue_index}    ${traffic_duration}
    UE Start UL TCP Traffic    ${ue_index}    ${traffic_duration}

    # Step 5: check ul&dl throughput normal
    ${cell_id_list}    Run Keyword If    ${ignore_cell}==True    Get All Cell Id
    ...    ELSE    Create List    ${global_cell_id}
    ${ul_tp_sum}    ${dl_tp_sum}    UE Check Muiti Cells UL&DL Throughput    cells=${cell_id_list}    ultarget_throughput=0    dltarget_throughput=0
    ...    ul_sum_throughput=${ul_tp_threshold}    dl_sum_throughput=${dl_tp_threshold}
    ...    ue_type=${ue_type}

   # Step 6: UE detach if required
    Run Keyword If    "${need_detach}"=="True"
    ...    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    [Return]    ${ul_tp_sum}    ${dl_tp_sum}

UE Attach And Traffic With Detach
    [Documentation]    Author: jiao.hu@nokia.com
    ...    Modify on 2026/01/16 14:40
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}
    ...    ${dl_tp}    ${attach_mode}=SA
    ...    ${duration}=600    ${ue_index}=${0}
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}

    # Pre 0: get cell identity
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    # Step 1: attach ue and verify attach cell
    UE Attach With Verify Attach    attach_mode=${attach_mode}    ue_index=${ue_index}    ue_type=${ue_type}
    ...    nr_cell_identity=${nr_cell_identity}

    # Step 2: start ul&dl udp traffic
    UE Start UL&DL UDP Traffic    ul_tp=${ul_tp}    dl_tp=${dl_tp}    duration=${duration}

    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

UE Attach And Check Single Cell TCP Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${global_cell_id}=1    ${ul_tp_threshold}=15    ${dl_tp_threshold}=220    ${attach_mode}=SA
    ...    ${traffic_duration}=600    ${ue_index}=${0}    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${min_percent}=0
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"

    UE Attach With Verify Attach    attach_mode=${attach_mode}    ue_index=${ue_index}    ue_type=${ue_type}
    ...    nr_cell_identity=${nr_cell_identity}

    UE Start DL TCP Traffic    ${ue_index}    ${traffic_duration}
    UE Start UL TCP Traffic    ${ue_index}    ${traffic_duration}
    Sleep    10s

    UE Check UL&DL Throughput    global_cell_id=${global_cell_id}
    ...    ultarget_throughput=${ul_tp_threshold}    dltarget_throughput=${dl_tp_threshold}
    ...    min_percent=${min_percent}

    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

UE Attach And Start Traffic Wait Check Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init define 2023-0519-1643
    [Arguments]    ${ul_tp}=50M    ${dl_tp}=300M    ${attach_mode}=SA
    ...    ${duration}=600    ${ue_index}=${0}    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    # Step 1: attach ue and verify attach cell
    UE Attach With Verify Attach    attach_mode=${attach_mode}    ue_index=${ue_index}    ue_type=${ue_type}

    # Step 2: start ul&dl udp traffic
    UE Start UL&DL UDP Traffic    ul_tp=${ul_tp}    dl_tp=${dl_tp}    duration=${duration}

UE Attach And Check Throughput With Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Modify on 2024/04/01 14:40
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA
    ...    ${duration}=600    ${ue_index}=${0}
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${update_qrxlevmin}=${TS_CASE_LOG_PATH}/update_qrxlevmin.json
    ...    ${restore_qrxlevmin}=${TS_CASE_LOG_PATH}/restore_qrxlevmin.json
    ...    ${connection}=GNB_OAM
    ...    ${ignore_lte_cells}=False
    ...    ${min_percent}=0.85

    # Pre 0: get cell identity
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${cells}    Get All Cells Distnames    ignore_lte_cells=${ignore_lte_cells}
    generate_delta_json_enable_single_cell_qrxlevmin    ${cells}
    ...    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${global_cell_id}
    ...    ${update_qrxlevmin}    ${restore_qrxlevmin}
    coam.perform_delta_recommissioning    delta_file=${update_qrxlevmin}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=${connection}

    # Step 1: attach ue and verify attach cell
    UE Attach With Verify Attach    attach_mode=${attach_mode}    ue_index=${ue_index}    ue_type=${ue_type}
    ...    nr_cell_identity=${nr_cell_identity}

    # Step 2: start ul&dl udp traffic
    UE Start UL&DL UDP Traffic    ul_tp=${ul_tp}    dl_tp=${dl_tp}    duration=${duration}

    # Step 3: check ul&dl throughput normal
    UE Check UL&DL Throughput    global_cell_id=${global_cell_id}
    ...    ultarget_throughput=${ul_tp_threshold}    dltarget_throughput=${dl_tp_threshold}
    ...    min_percent=${min_percent}

    [Teardown]    Run Keywords    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    ...    AND    coam.perform_delta_recommissioning    delta_file=${restore_qrxlevmin}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=${connection}

UE Attach And Catch Bip With Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA    ${iperf_type}=via_command
    ...    ${ul_duration}=600    ${dl_duration}=600    ${ue_index}=${0}
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    ...    ELSE    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}
    Sleep    10s
    power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${ue_type}    throughput=${ul_tp_threshold}
    ...    cellid=${nr_cell_identity}
    power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}    throughput=${dl_tp_threshold}
    ...    cellid=${nr_cell_identity}
    Connect To BTS Csn Via Lmp
    ${ul_tp}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    ${dl_tp}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    [Return]    ${ul_tp}    ${dl_tp}

UE Attach And Check Throughput Without Detach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA
    ...    ${duration}=600    ${ue_index}=${0}
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${min_percent}=0.85

    # Pre 0: get cell identity
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"

    # Step 1: attach ue and verify attach cell
    Run Keyword And Ignore Error    UE Attach With Verify Attach
    ...    attach_mode=${attach_mode}
    ...    ue_index=${ue_index}
    ...    ue_type=${ue_type}
    ...    nr_cell_identity=${nr_cell_identity}
    Sleep    5s

    # Step 2: start ul&dl udp traffic
    UE Start UL&DL UDP Traffic    ul_tp=${ul_tp}    dl_tp=${dl_tp}    duration=${duration}

    # Step 3: check ul&dl throughput normal
    ${ul_tp}    ${dl_tp}    UE Check UL&DL Throughput    global_cell_id=${global_cell_id}
    ...    ultarget_throughput=${ul_tp_threshold}    dltarget_throughput=${dl_tp_threshold}
    ...    min_percent=${min_percent}

    [Return]    ${ul_tp}    ${dl_tp}

UE Attach And Start Check Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${iperf_type}=via_command
    ...    ${ul_duration}=600    ${dl_duration}=600    ${ue_index}=${0}
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    ...    ELSE    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${dl_duration}
    Sleep    10s
    power_ue.Check throughput    ue_index=${ue_index}    direction=ul    ue_type=${ue_type}    throughput=${ul_tp_threshold}
    ...    cellid=${nr_cell_identity}
    power_ue.Check throughput   ue_index=${ue_index}    direction=dl    ue_type=${ue_type}    throughput=${dl_tp_threshold}
    ...    cellid=${nr_cell_identity}
    Connect To BTS Csn Via Lmp
    ${ul_tp}    Calculate UL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    ${dl_tp}    Calculate DL Throughoutput Re    alias=ASIK Master    sample=10    start_offset=3
    ...    sleep_time=5    cellid=${nr_cell_identity}    log_type=Aasyslog
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    [Return]    ${ul_tp}    ${dl_tp}

UE Attach With Verify Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 11:01
    [Arguments]    ${attach_mode}=SA    ${ue_index}=${0}    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${nr_cell_identity}=${EMPTY}
    # Step 1: prepare ue
    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_type=${ue_type}

    # Step 2: attach ue
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}

    # Step 3: verify ue attach
    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

    Log To Console    ${nr_cell_identity}
    # Step 4: verify ue attach cell if necessary
    # Run Keyword If    '${attach_mode}'=='SA' and '${nr_cell_identity}'!='${EMPTY}' and '${ue_type}'!='samsung'
    # ...    Verify UE Attach Target Cell
    # ...    nr_cell_identity=${nr_cell_identity}    ue_index=${ue_index}    serial_number=${tl.ues[${ue_index}].serial_number}

Verify UE Attach Target Cell
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/04/01 14:47
    ...    only support NR_SA
    [Arguments]    ${nr_cell_identity}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${network_type}    csn.execute
    ...    command=adb -s ${serial_number} shell getprop gsm.network.type
    ...    connection=cpc_${ue_index}
    ${sa_or_lte}    Run Keyword And Return Status    Should Not Contain    ${network_type}    NR_SA
    Run Keyword If    ${sa_or_lte}    Return From Keyword

    ${cell_id}    csn.execute
    ...    command=adb -s ${serial_number} shell dumpsys telephony.registry | grep 'mNci = [0-9]\\+' -m1 -o | awk '{print $3}'
    ...    connection=cpc_${ue_index}
    ${nr_cell_identity}    Convert To String    ${nr_cell_identity}
    Should Contain    ${cell_id}    ${nr_cell_identity}

UE Start UL&DL UDP Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 11:11
    [Arguments]    ${ul_tp}    ${dl_tp}    ${duration}=600
    ...    ${ue_index}=${0}    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}   ${parallel}=${1}
    ...    ${ul_port}=0    ${dl_port}=0    ${appserver_addr}=0
    ${ues_trs_info}     get_ues_trs_info
    IF    '${dl_port}'=='0'
        ${ul_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][0]}
        ${dl_port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][0]}
    END
    ${appserver_addr}      Set Variable    ${ues_trs_info[${ue_index}]["addr"]}

    Run Keyword If    '${ue_type}'=='huawei'
    ...    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${duration}
    ...    ELSE    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${duration}    ue_index=${ue_index}
    ...    ul_port=${ul_port}    appserver_addr=${appserver_addr}
    UE Start DL Traffic    throughput=${dl_tp}    dl_time=${duration}    dl_port=${dl_port}    hostname=${appserver_addr}
    ...        parallel=${parallel}    ue_index=${ue_index}

UE Start UL&DL TCP Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/12/14 16:40
    [Arguments]    ${duration}=600    ${ue_index}=${0}
    ...    ${dl_parallel}=3    ${ul_parallel}=16    ${mss}=1350
    ...    ${app_w}=16M    ${iperf_path}=/data/local/tmp/iperf3    ${app_iperf}=iperf3    ${ue_w}=10M
    UE Start DL TCP Traffic    ${ue_index}    ${duration}
    ...    parallel=${dl_parallel}    mss=${mss}    app_w=${app_w}    iperf_path=${iperf_path}
    ...    app_iperf=${app_iperf}
    UE Start UL TCP Traffic    ${ue_index}    ${duration}
    ...    parallel=${ul_parallel}    mss=${mss}    iperf_path=${iperf_path}
    ...    app_iperf=${app_iperf}    ue_w=${ue_w}

UE Check UL&DL Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/21 16:12
    [Arguments]    ${global_cell_id}    ${ultarget_throughput}    ${dltarget_throughput}
    ...    ${duration}=300s    ${ignore_time}=30s    ${ue_index}=0
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}    ${min_percent}=0.85
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    ignore_time=${ignore_time}    check_source=aasyslog
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    @{cells}    Create List    ${nr_cell_identity}
    ${output}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${cells}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    min_percent=${min_percent}

    # need return ul&dl tp
    [Return]    ${output[0][0]["average"]}    ${output[1][0]["average"]}

UE Check Muiti Cells UL&DL Throughput
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/21 16:12
    [Arguments]    ${cells}    ${ultarget_throughput}    ${dltarget_throughput}
    ...    ${ul_sum_throughput}=0    ${dl_sum_throughput}=0
    ...    ${duration}=10s    ${ignore_time}=10s    ${ue_index}=0
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ...    ${log_dir}=${OUTPUT_DIR}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    ignore_time=${ignore_time}    check_source=aasyslog
    ...    log_dir=${log_dir}
    @{true_cells}    Create List
    FOR    ${cell}    IN    @{cells}
        ${nr_cell_identity}    Get NR Cell Identity Via Index "${cell}"
        Append To List    ${true_cells}    ${nr_cell_identity}
    END
    ${output}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}    cells=${true_cells}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ${cell_length}    Get Length    ${cells}
    Set Test Variable    ${ul_sum}    0
    Set Test Variable    ${dl_sum}    0
    FOR     ${i}    IN RANGE    ${cell_length}
        ${ul_sum}    Evaluate    ${ul_sum}+${output[0][${i}]["average"]}
        ${dl_sum}    Evaluate    ${dl_sum}+${output[1][${i}]["average"]}
    END
    Should Be True    ${ul_sum}>${ul_sum_throughput}
    Should Be True    ${dl_sum}>${dl_sum_throughput}
    [Return]    ${ul_sum}    ${dl_sum}

UE Stop Traffic And Release UE
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2023/11/16 11:25/
    [Arguments]    ${sleep_time}=10    ${ue_index}=${0}    ${port}=0
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}
    ${ues_trs_info}     get_ues_trs_info
    IF    '${port}'=='0'
        ${port}      Set Variable    ${ues_trs_info[${ue_index}]["ports"][0]}
    END
    Kill the iperf process on APPserver    port=${port}
    Close the iperf process on android ue    ue_index=0    iperf_port=${port}
#    UE Mobile Data Disable
    Sleep    ${sleep_time}
#    UE Mobile Data Enable
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

UE Start Muiti DL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/23 15:03
    [Arguments]    ${start_port}    ${end_port}    ${throughput}    ${parallel}    ${dl_time}=600s
    FOR    ${port}    IN RANGE    ${start_port}    ${end_port}
        UE Start DL Traffic    throughput=${throughput}    dl_time=${dl_time}    dl_port=${port}    parallel=${parallel}
    END
    Sleep    3s

UE Start Muiti UL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/23 15:03
    [Arguments]    ${start_port}    ${end_port}    ${throughput}    ${ul_time}=600s
    FOR    ${port}    IN RANGE    ${start_port}    ${end_port}
        UE Start UL Traffic    throughput=${throughput}    ul_time=${ul_time}    ul_port=${port}
    END
    Sleep    3s

UE Stop Muiti DL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/23 15:03
    [Arguments]    ${start_port}    ${end_port}    ${appserver}=APPserver
    FOR    ${port}    IN RANGE    ${start_port}    ${end_port}
        Kill the iperf process on APPserver    port=${port}    appserver=${appserver}
    END
    Sleep    0.5s

UE Stop Muiti UL Traffic
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/10/23 15:03
    [Arguments]    ${start_port}    ${end_port}
    FOR    ${port}    IN RANGE    ${start_port}    ${end_port}
        Close the iperf process on android ue    ue_index=0    iperf_port=${port}
    END
    Sleep    3s

Kill the iperf process on APPserver
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2024/12/27 10:33
    [Arguments]    ${port}    ${appserver}=APPserver    ${ue_index}=0
    ${ues_trs_info}     get_ues_trs_info
    ${appserver_addr}      Set Variable    ${ues_trs_info[${ue_index}]["addr"]}
    ${appserver_username}      Set Variable    ${ues_trs_info[${ue_index}]["user"]}
    ${appserver_password}      Set Variable    ${ues_trs_info[${ue_index}]["password"]}

    csn.Connect to    hostname=${appserver_addr}
    ...               username=${appserver_username}
    ...               password=${appserver_password}
    ...               alias=${appserver}
    run keyword and ignore error    csn.execute    command=ps -ef|grep iperf|grep -v grep    connection=${appserver}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=${appserver}
