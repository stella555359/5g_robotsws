*** Settings ***
Documentation     author: Jiang Johnny
...               contact: johnny.1.jiang@nokia-sbell.com
...               squad group: SG_07
...               feature : CB009499

Library           OperatingSystem
Library           Collections
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables         testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB008278/Resource/resource.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Library           taf.hw.rf_attenuator    WITH NAME    att

*** Variables ***
#${cpc_ip}   ${tl.ues[${ue_index}].ssh_connection_details.addr}
#${cpc_usrname}   ${tl.ues[${ue_index}].ssh_connection_details.username}
#${cpc_passwd}   ${tl.ues[${ue_index}].ssh_connection_details.password}
#${ue_2_required}   ${false}
#${ue_3_required}   ${false}
#${ue_4_required}   ${false}
#${BTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Askey NRcall
    [Arguments]  ${traffic_stop}=${true}    ${duration}=90   ${iperf_port}=57000   ${direction}=BOTH
    Askey Prepare
    ${detach_status}    run keyword and return status   Askey Detach
    Run keyword if    '${detach_status}'=='False'   Askey Detach
    sleep   3s
    Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress   filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side
    ...                                                                          log_type=Aasyslog
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side
    ...                                                                          log_type=Aasyslog
    ...                                                                          log_loca=l2hidu
    ${attact_status}    run keyword and return status   Askey Attach
    Run keyword if    '${attact_status}'=='False'   Askey Attach
    ${status}    run keyword and return status    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=0    before_time='None'    hwcheck_index=1    log_type=Aasyslog
    ...    gnb_index=${0}    5Gstatus=PASS    log_loca=l2lo
    Run keyword if    '${status}'=='False'    wait until keyword succeeds    1 min    10s    Check 5G Rach Status
    ...    before=${0}    before_time='None'     hwcheck_index=1    log_type=Aasyslog
    ...    gnb_index=${0}    5Gstatus=PASS    log_loca=l2hidu
    ${ue_ip}   Get Askey IP
    run keyword if   '${ue_ip}'=='0.0.0.0' or '${ue_ip}'==' '   Askey Detach
    run keyword if   '${ue_ip}'=='0.0.0.0' or '${ue_ip}'==' '   Askey Attach
    ${ue_ip}   Run Keyword If   '${ue_ip}'=='0.0.0.0' or '${ue_ip}'==' '   Get Askey IP
    ...   ELSE   set variable   ${ue_ip}
    run keyword if   '${ue_ip}'=='0.0.0.0' or '${ue_ip}'==' '   FAIL
    Run Keyword If   '${direction}'=='BOTH' or '${direction}'=='DL'
    ...   Askey DL Call   ue_ip=${ue_ip}   iperf_port=${iperf_port}   duration=${duration}   traffic_stop=${traffic_stop}
    Run Keyword If   '${direction}'=='BOTH' or '${direction}'=='UL'
    ...   Askey UL Call   ue_ip=${ue_ip}   iperf_port=${iperf_port}   duration=${duration}   traffic_stop=${traffic_stop}
    [Teardown]    Run keyword and ignore error   Run Keyword If   ${traffic_stop}   Askey Teardown Detach


Askey DL Call
    [Arguments]   ${ue_ip}   ${iperf_port}   ${duration}=90   ${traffic_stop}=${true}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}   Create List   ${nr_cellid}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.send_command
    ...    command=iperf -c ${ue_ip} -u -t ${duration} -i 1 -p ${iperf_port} -P 1 -f m -b ${5Gsend_tp_DL}M -l 1400 -T 64 &
    ...    connection=APPserver
    sleep   3s
    Check the iperf progress exist   connection=APPserver   port=${iperf_port}
    Wait Until Keyword Succeeds   3m   30s   Check Tput l3call
    ...   ue_type=askey   ue_index=${NR_L3call_UE}   direction=DL   cells=${cell_id_list}   expect=${5Gtput_expect_DL}
    ...   ignore_time=${check_tput_ignore_time}   duration=${duration}
    Run Keyword And Ignore Error   Disconnect from app server
    [Teardown]   run keyword and ignore error   run keyword if   ${traffic_stop}   Askey stop DL traffic   iperf_port=${iperf_port}


Askey UL Call
    [Arguments]   ${ue_ip}   ${iperf_port}   ${duration}=90   ${traffic_stop}=${true}
    Connect to control pc enhanced   ue_index=${NR_L3call_UE}
    ${serial_number}   set variable   ${tl.ues[${NR_L3call_UE}].serial_number}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}   Create List   ${nr_cellid}
    ${cmd_start_iperf_client}    Run Keyword If   '${Askey_iperf_ul_cmd}'=='int'   Catenate
    ...    adb -s ${serial_number} shell iperf -u -c ${appserver_addr} -b ${5Gsend_tp_UL}M -t 9999999 -i 1 -l 1400 -p ${iperf_port}
    ...   ELSE   Catenate   iperf.exe -c ${appserver_addr} -u -b ${5Gsend_tp_UL}M -i 1 -l 1400 -t 36000 -p ${iperf_port} -B ${ue_ip}
    csn.send command     command=${cmd_start_iperf_client}    connection=cpc_${NR_L3call_UE}
    Wait Until Keyword Succeeds   3m   30s   Check Tput l3call
    ...   ue_type=askey   ue_index=${NR_L3call_UE}   direction=UL   cells=${cell_id_list}   expect=${5Gtput_expect_uL}
    ...   ignore_time=${check_tput_ignore_time}   duration=${duration}
    [Teardown]   run keyword and ignore error   run keyword if   ${traffic_stop}   Stop traffic via iperf command on UE
    ...   ue_index=${NR_L3call_UE}   port=${iperf_port}
    ...   ELSE    csn.disconnect   connection=cpc_${NR_L3call_UE}


Askey stop DL traffic
    [Arguments]   ${iperf_port}=57000
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    Run Keyword And Ignore Error   csn.execute   command=ps -ef|grep iperf|grep -v grep   connection=APPserver
    csn.Execute   command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9   connection=APPserver
    [Teardown]   Run Keyword And Ignore Error   Disconnect from app server


Askey Attach
    Connect to control pc enhanced   ue_index=${NR_L3call_UE}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "at+CFUN=1"
    ...    connection=cpc_${NR_L3call_UE}
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=cpc_${NR_L3call_UE}   match=at+CFUN=1   timeout=30
    sleep   10s
    run keyword if  not ${status}   FAIL
    [Teardown]   run keywords
    ...   Run keyword and ignore error    csn.disconnect   connection=cpc_${NR_L3call_UE}   AND
    ...   run keyword if  not ${status}   Restart spark pc   ue_index=${NR_L3call_UE}


Askey Detach
    Connect to control pc enhanced   ue_index=${NR_L3call_UE}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "at+CFUN=0"
    ...    connection=cpc_${NR_L3call_UE}
    ${status}    run keyword and return status
    ...    csn.Read Output Until    connection=cpc_${NR_L3call_UE}   match=at+CFUN=0   timeout=30
    run keyword if  not ${status}   FAIL
    [Teardown]   run keywords
    ...   Run keyword and ignore error    csn.disconnect   connection=cpc_${NR_L3call_UE}   AND
    ...   run keyword if  not ${status}   Restart spark pc   ue_index=${NR_L3call_UE}


Askey Teardown Detach
    Connect to control pc enhanced   ue_index=${NR_L3call_UE}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "at+CFUN=0"
    ...    connection=cpc_${NR_L3call_UE}
    [Teardown]   Run keyword and ignore error    csn.disconnect   connection=cpc_${NR_L3call_UE}


Askey Prepare
    [Arguments]   ${serial_number}=${tl.ues[${${NR_L3call_UE}}].serial_number}
    Connect to control pc enhanced    ${NR_L3call_UE}
     csn.execute    command=adb -s ${serial_number} reboot   connection=cpc_${NR_L3call_UE}
     sleep    10s
    wait until keyword succeeds    3 min    10s    Connect ADB devices    alias=cpc_${NR_L3call_UE}    serial_number=${serial_number}
    [Teardown]  Run keyword and ignore error    csn.disconnect   connection=cpc_${NR_L3call_UE}


Get Askey IP
    Connect to control pc enhanced   ue_index=${NR_L3call_UE}
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand_new.py -p com${COM_port} -c "at+cgpaddr"
    ...    connection=cpc_${NR_L3call_UE}
    ${ue_ip_before}   csn.Read Output   connection=cpc_${NR_L3call_UE}
    ${ue_ip_index}   set variable   ${ue_ip_before.split(',')[1]}
    ${ue_ip}   set variable   ${ue_ip_index.split('+')[0]}
    ${ue_ip}   set variable   ${ue_ip.strip()}
    csn.disconnect   connection=cpc_${NR_L3call_UE}
    [Return]   ${ue_ip}
