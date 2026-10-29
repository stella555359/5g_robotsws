*** Settings ***
Documentation   STU Temp solution, han ruiyu added
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot

*** Variables ***
${ue_index}   0
${ue_required}   ${false}
${ue_0_required}   ${false}
${ue_1_required}   ${false}
${COM_port}           ${tl.ues[${ue_index}].diag_com}
${AT_script_path}     ${tl.ues[${ue_index}].server_dir}
${iperf_dir}          ${tl.ues[${ue_index}].iperf_directory}
${dl_iperf_port}      ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
${ul_iperf_port}      ${tl.ues[${ue_index}].ssh_connection_details.port}


*** Keywords ***
Start ATCMD L3CALL
    [Arguments]    ${ue_index}=${ue_index}    ${traffic_stop}=${true}    ${duration}=90    ${ue_reboot}=${False}
    ...    ${ue_type}=atcmd    ${Send_Tput}=200M     ${Expect_Tput}=50
    ...    ${peak_ul}=120   ${ul_expect}=${peak_ul}
    ...   ${direction}=DL    ${dl_deviation}=0.95    ${ul_deviation}=0.95   ${actCarrierAggregation}=${False}
    ...    ${min_percent}=0.85
    Set Suite Variable   ${ue_${ue_index}_type}   ${ue_type}
    ${ue_ip}     wait until keyword succeeds    3x    10s    ATCMD Attach and Verify   ue_index=${ue_index}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    ${cell_id_list}   set variable if  ${actCarrierAggregation}    ${nrcellid_list}    ${cell_id_list}
    # Check Tput
    Run Keyword If   '${direction}'=='BOTH'    ATcmd DL and UL Call     dl_throughput=${Send_Tput}   ul_throughput=${peak_ul}
    ...   cell_list=${cell_id_list}   ue_index=${ue_index}    dl_expect=${Expect_Tput}   ul_expect=${ul_expect}    duration=${duration}
    [Teardown]  Run Keyword If   ${traffic_stop}   ATcmd Detach    ue_index=${ue_index}


ATCMD Attach and Verify
    [Arguments]    ${ue_index}
    ATcmd Start aasyslog
    run keyword and ignore error   ATcmd Detach     ue_index=${ue_index}
    ATcmd Attach   ue_index=${ue_index}
    run keyword and ignore error     ATcmd Attach Verify via aasyslog
    ${ue_ip}    ATcmd Get UE IP     ue_index=${ue_index}
    Should Not Be Equal     ${ue_ip}     0.0.0.0    msg=UE ip not correct with:0.0.0.0!
    [Return]     ${ue_ip}
    [Teardown]    run keywords     run keyword and ignore error   ATcmd Detach     ue_index=${ue_index}
    ...     AND     Run keyword and ignore error   Teardown the Aasyslog save progress


ATcmd Start aasyslog
    log to console    Start aasyslog
    Run keyword and ignore error   Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress   filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side
    ...                                                                          log_type=Aasyslog
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side
    ...                                                                          log_type=Aasyslog
    ...                                                                          log_loca=l2hidu

ATcmd Attach Verify via aasyslog
    log to console    Attach Verify via aasyslog
    ${status}    run keyword and return status    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=0    before_time='None'    hwcheck_index=1    log_type=Aasyslog
    ...    gnb_index=${0}    5Gstatus=PASS    log_loca=l2lo
    Run keyword if    '${status}'=='False'    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=${0}    before_time='None'     hwcheck_index=1    log_type=Aasyslog
    ...    gnb_index=${0}    5Gstatus=PASS    log_loca=l2hidu
    [Teardown]   Teardown the Aasyslog save progress

ATcmd Attach
    [Arguments]   ${ue_index}
    log to console    ATcmd Attach
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "at+CFUN=1"
    ...    connection=cygwin
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=cygwin   match=at+CFUN=1   timeout=30
    run keyword if  not ${status}   FAIL
    sleep   10s
    [Teardown]   run keywords    Run Keyword And Ignore Error   csn.disconnect    connection=cygwin
    ...    AND    run keyword if  not ${status}   Restart UE Control PC    ue_index=${ue_index}

ATcmd Detach
    [Arguments]   ${ue_index}
    log to console    ATcmd Detach
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "at+CFUN=0"
    ...    connection=cygwin
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=cygwin   match=at+CFUN=0   timeout=30
    run keyword if  not ${status}   FAIL
    sleep   3s
    [Teardown]   run keywords    Run Keyword And Ignore Error   csn.disconnect    connection=cygwin
    ...   AND    run keyword if  not ${status}   Restart UE Control PC    ue_index=${ue_index}

ATcmd Detach wo PC Restart
    [Arguments]   ${ue_index}
    log to console    Askey Detach
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "at+CFUN=0"
    ...    connection=cygwin
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=cygwin   match=at+CFUN=0   timeout=30
    run keyword if  not ${status}   FAIL
    sleep   3s
    [Teardown]   Run Keyword And Ignore Error   csn.disconnect    connection=cygwin

ATcmd DL Call
    [Arguments]   ${ue_index}    ${ue_ip}=${ue_ip}   ${iperf_port}=${iperf_port}   ${duration}=90
    ...   ${traffic_stop}=${true}   ${tput}=100   ${tput_expect}=${tput}
    log to console    Askey DL Call
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}   Create List   ${nr_cellid}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.send_command
    ...    command=iperf -c ${ue_ip} -u -t ${duration} -i 1 -p ${iperf_port} -P 1 -f m -b ${tput}M -l 1400 -T 64 &
    ...    connection=APPserver
    sleep   3s
    Check the iperf progress exist   connection=APPserver   port=${iperf_port}
    Wait Until Keyword Succeeds   3m   30s   Check Tput l3call
    ...   ue_type=askey   ue_index=${ue_index}   direction=DL   cells=${cell_id_list}   expect=${tput_expect}
    [Teardown]   run keywords    Run Keyword And Ignore Error   Disconnect from app server
    ...    AND   run keyword if   ${traffic_stop}   ATcmd stop DL traffic   iperf_port=${iperf_port}

ATcmd UL Call
    [Arguments]   ${ue_index}    ${ue_ip}=${ue_ip}   ${iperf_port}=${iperf_port}   ${duration}=90
    ...   ${traffic_stop}=${true}   ${peak_ul}=120   ${ul_expect}=${peak_ul}
    ...    ${iperf_dir}=${empty}
    log to console    Askey UL Call
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${serial_number}   set variable   ${tl.ues[${ue_index}].serial_number}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}   Create List   ${nr_cellid}
    ${cmd_start_iperf_client}    Catenate
     ...   cd ${iperf_dir};iperf.exe -c ${appserver_addr} -u -b ${send_tp_UL} -i 1 -l 1400 -t 36000 -p ${iperf_port} -B ${ue_ip}
#    ...    adb -s ${serial_number} shell iperf -u -c ${appserver_addr} -b ${peak_ul}M -t 9999999 -i 1 -l 1400 -p ${iperf_port}
    csn.send command     command=${cmd_start_iperf_client}    connection=cygwin
    Wait Until Keyword Succeeds   3m   30s   Check Tput l3call
    ...   ue_type=askey   ue_index=${ue_index}   direction=UL   cells=${cell_id_list}   expect=${ul_expect}
    [Teardown]   run keywords    Run Keyword And Ignore Error   csn.disconnect    connection=cygwin
    ...   AND   run keyword if   ${traffic_stop}   Stop traffic via iperf command on UE
    ...   ue_index=${ue_index}   port=${iperf_port}

ATcmd DL and UL Call
    [Arguments]    ${dl_throughput}   ${ul_throughput}   ${cell_list}   ${ue_index}=${0}
    ...   ${dl_expect}=${dl_throughput}   ${ul_expect}=${ul_throughput}    ${duration}=600
    ...   ${dl_deviation}=0.95   ${ul_deviation}=0.95     ${actCarrierAggregation}=${False}    ${traffic_stop}=${True}
    ...   ${min_percent}=0.85
    log to console    ATcmd DL and UL Call
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${duration_traffic}   evaluate   ${duration_output}+${30}
    ${duration_traffic}    set variable   ${duration_traffic}s
    ${check_source}    set variable if   ${Technology.count('NR')}>0    Aasyslog   iperf

    #start dl traffic
    log to console    ATcmd DL Call
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_iperf_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.send_command
    ...    command=iperf -c ${ue_ip} -u -t ${duration_traffic} -i 1 -p ${dl_iperf_port} -P 1 -f m -b ${dl_throughput}M -l 1400 -T 64 &
    ...    connection=APPserver
    sleep   3s
    Check the iperf progress exist   connection=APPserver   port=${dl_iperf_port}

    #start ul traffic
    log to console    ATcmd UL Call
    Connect to control pc via cygwin    ue_index=${ue_index}
    ${serial_number}   set variable   ${tl.ues[${ue_index}].serial_number}
    ${cmd_start_iperf_client}    Catenate
     ...   cd ${iperf_dir};iperf.exe -c ${appserver_addr} -u -b ${send_tp_UL} -i 1 -l 1400 -t 36000 -p ${ul_iperf_port} -B ${ue_ip}
#    ...    adb -s ${serial_number} shell iperf -u -c ${appserver_addr} -b ${peak_ul}M -t 9999999 -i 1 -l 1400 -p ${ul_iperf_port}
    csn.send command     command=${cmd_start_iperf_client}    connection=cygwin

    ${ue_type}    set variable     qualcomm
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}    duration=${duration}    ignore_time=0s
    ...   check_source=${check_source}
    power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${dl_expect}   ultarget_throughput=${ul_expect}
    ...   target_avg_percent=${dl_deviation}     actCarrierAggregation=${actCarrierAggregation}
    ...   min_percent=${min_percent}
    [Teardown]   run keyword if  ${traffic_stop}    Run Keywords   Run Keyword and Ignore Error
    ...   ATcmd stop DL traffic    dl_iperf_port=${dl_iperf_port}
    ...   AND   Run Keyword and Ignore Error     Stop traffic via iperf command on UE
    ...   ue_index=${ue_index}   port=${iperf_port}


ATcmd stop DL traffic
    [Arguments]    ${dl_iperf_port}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    Run Keyword And Ignore Error   csn.execute   command=ps -ef|grep iperf|grep -v grep   connection=APPserver
    csn.Execute
    ...   command=ps -ef|grep iperf|grep -v grep|grep ${dl_iperf_port}| awk '{print $2}' |xargs kill -9   connection=APPserver
    [Teardown]   Run Keyword And Ignore Error   Disconnect from app server

ATcmd Get UE IP
    [Arguments]   ${ue_index}
    log to console    Get UE IP
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand_new.py -p com${COM_port} -c "at+cgpaddr"
    ...    connection=cygwin
    ${ue_ip_before}   csn.Read Output   connection=cygwin
    ${ue_ip_index}   set variable   ${ue_ip_before.split(',')[1]}
    ${ue_ip}   set variable   ${ue_ip_index.split('+')[0]}
    ${ue_ip}   set variable   ${ue_ip.strip()}
    [Return]   ${ue_ip}
    [Teardown]   Run Keyword And Ignore Error   csn.disconnect    connection=cygwin

Restart UE Control PC
    [Arguments]   ${ue_index}
    log to console    Restart UE Control PC
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command
    ...    command=shutdown /r /f /t 0
    ...    connection=cygwin
    sleep    180s
    [Teardown]   Run Keyword And Ignore Error   csn.disconnect    connection=cygwin
