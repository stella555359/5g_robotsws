*** Settings ***
Documentation    This is SleepingCells common keywords

Library     taf.selenium.sbts    WITH NAME    selenium_sbts
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot

*** Keywords ***
Check Unexpect Alarm On Webem
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]    ${OK_Alarm}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${fault_id}    Get BTS Active Alarms ID List    connection=${connection}
#    Lists Should Be Equal    ${OK_Alarm}    ${fault_id}    ignore_order=True
    FOR    ${Fault}    IN    @{fault_id}
        List Should Contain Value    ${OK_Alarm}    ${Fault}
    END

Collect Real Timezone
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    ...        check timezone changed Success
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${result}    coam.get_bts_time_zone    connection=${connection}
    [Return]    ${result}

Check should not contain alarm
    [Documentation]    Author: xudong.1.li@nokia-sbell.com
    [Arguments]    ${alarm_id}    ${connection}=GNB_OAM
    ${alarm_list}    Get BTS Active Alarms ID List    connection=${connection}
    ${length}    Get Length    ${alarm_id}
    FOR   ${j}   IN RANGE    ${length}
        List Should Not Contain Value  ${alarm_list}    ${alarm_id[${j}]}
    END

UE Attach And Check Throughput With Detach Bk
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    global_cell_id(Global cell ID): 1
    ...    ul_tp: 50M    ul_tp_threshold: 15
    ...    dl_tp: 300M    dl_tp_threshold: 220
    ...    [Return]    ul_tp: 20    dl_tp; 200
    [Arguments]    ${global_cell_id}    ${ul_tp}   ${ul_tp_threshold}
    ...    ${dl_tp}    ${dl_tp_threshold}    ${attach_mode}=SA    ${iperf_type}=via_command
    ...    ${ul_duration}=500    ${dl_duration}=500    ${ue_index}=${0}
    ${nr_cell_identity}    Get NR Cell Identity Via Index "${global_cell_id}"
    ${ue_type}    translate power ue type from testline    ${ue_index}
    Ulock UE First
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=0
    Run Keyword If    '${attach_mode}'=='NSA'    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=True
    ...    ELSE    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
    Run Keyword If    '${iperf_type}'=='via_command'    UE Start UL Traffic    throughput=${ul_tp}    ul_time=${ul_duration}
    ...    ELSE    power_ue.Start traffic   ue_type=${ue_type}   direction=ul   throughput=${ul_tp}    duration=${ul_duration}
    UE Start DL Traffic bk    throughput=${dl_tp}    dl_time=${dl_duration}
    Sleep    180s
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
    ...    Ulock UE First    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    [Return]    ${ul_tp}    ${dl_tp}

UE Start DL Traffic bk
    [Arguments]    ${throughput}    ${ue_index}=0    ${dl_time}=600    ${dl_port}=53038
    Close the iperf process on APPserver    port=${dl_port}
    ${ue_ip}  Get UE IP Address bk  ${ue_index}
    csn.send command
    ...    command=iperf -c ${ue_ip} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${throughput} -l 1400B -T 64&
    ...    connection=APPserver

Get UE IP Address bk
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
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Verify BTS Single Cell Status Is Normal State bk
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${dist_name}    ${administrative_state}=Unlocked
    ...    ${blocking_state}=Unblocked    ${operational_state}=enabled
    ...    ${cell_type}=nr    ${connection}=GNB_OAM
    ${except_cell_status}    Create Dictionary    administrativeState=${administrative_state}
    ...    blockingState=${blocking_state}
    ...    operationalState=${operational_state}
    ${cells_info}    coam.get_cells_info    cell_type=${cell_type}    connection=${connection}
    FOR  ${cell_info}  IN  @{cells_info}
        ${passed}    Run Keyword And Return Status    Should Be Equal As Strings
        ...    ${dist_name}    ${cell_info['id']['configuration']}
        Run Keyword If    ${passed}    Verify BTS Target Cell Status bk   ${cell_info['status']}    ${except_cell_status}
    END

Verify BTS Target Cell Status bk
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    [Arguments]    ${current_cell_status}    ${except_cell_status}
    FOR    ${status_name}    IN    @{except_cell_status}
        Should Be Equal As Strings    ${current_cell_status['${status_name}']}    ${except_cell_status['${status_name}']}
        ...    ignore_case=True
    END
