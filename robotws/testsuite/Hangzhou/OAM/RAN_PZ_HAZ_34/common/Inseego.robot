*** Settings ***
Documentation    Inseego Call Temp solution, han ruiyu added askey L3 CALL
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot

*** Variables ***
${ue_index}   0
${ue_required}   ${false}
${ue_0_required}   ${false}
${ue_1_required}   ${false}

*** Keywords ***
#Test UE Connection
#    [Tags]    DEBUG
#    Precondition for Android UE   ue_index=${ue_index}

Inseego UE Connection
    [Documentation]   DEP keyword. current implementation move to power_ue , change for adapt to askey(ruihan)
    ...   Author: jingmin.he@nokia-sbell.com
    [Arguments]   ${ue_index}
    _Prepare Variables    ue_index=${ue_index}
    ${cpc_connect}   run keyword and return status   csn.Connect to   hostname=${cpc_ip}
    ...   username=${cpc_username}   password=${cpc_password}   alias=cpc_${ue_index}   timeout=120
    ${cpc_connect}   run keyword if   ${cpc_connect}   set variable   cpc_${ue_index}
    ...   ELSE   set variable   ${cpc_connect}
    run keyword if  not ${ue_${ue_index}_required}   Require UE with many times
    ...   ue_index=${ue_index}   cpc_connect=${cpc_connect}
#    run keyword and ignore error   Ue detach with index   ue_index=${ue_index}
#    Android UE Attach for L3 Call Preparation   ue_index=${ue_index}   4G_check=${false}
#    run keyword if   ${config.has_key('capabilities')}   run Keyword if   ${config['capabilities'][0].lower().count('inseego')}>0
#    ...   run keyword and ignore error  Inseego Precondition   ${cpc_connect}
    [Return]   ${cpc_connect}

Require UE with many times
    [Documentation]   DEP keyword. current implementation move to power_ue
    ...   Author: jingmin.he@nokia-sbell.com
    [Arguments]   ${ue_index}   ${cpc_connect}   ${retry}=${2}
    ${ue_reserved}   Set Variable   ${false}
    FOR   ${index}    IN RANGE    ${retry}
       ${ue_reserved}   run keyword and continue on failure   Require UE one time
       ...   ue_index=${ue_index}   cpc_connect=${cpc_connect}
       exit for loop if   ${ue_reserved}
    END
    run keyword if  not ${ue_reserved}   ute_ue.Require Ue   ue_alias=UE_${ue_index}  capabilities=${capabilities}
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_required}   ${ue_reserved}
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_required}   ${ue_reserved}

Require UE one time
    [Documentation]   DEP keyword. current implementation move to power_ue
    ...   Author: jingmin.he@nokia-sbell.com
    [Arguments]   ${ue_index}   ${cpc_connect}
    ${req_result}   run keyword and return status   ute_ue.Require Ue   ue_alias=UE_${ue_index}  capabilities=${capabilities}
    return from keyword if   ${req_result}   ${req_result}
    run keyword if   '${cpc_connect}'=='False'   should be true   ${req_result}
    csn.Execute   command=adb reboot   connection=${cpc_connect}
    ${adb_service}   Run Keyword and Return Status   wait until keyword succeeds   5m   30s   Connect ADB devices
    ...   alias=${cpc_connect}   serial_number=${serial}
    run keyword if  not ${adb_service}   Reset adb service   cpc_connect=${cpc_connect}
    ${adb_service_again}   Run Keyword and Return Status   Connect ADB devices   alias=${cpc_connect}   serial_number=${serial}
    Run Keyword If   '${adb_service}'=='False' and '${adb_service_again}'=='False'   Run Keywords   Reset UE Control PC
    ...   AND   Sleep   1m
    ...   AND   Return From Keyword
    ${req_result}   run keyword and return status   ute_ue.Require Ue   ue_alias=UE_${ue_index}  capabilities=${capabilities}
    return from keyword if   ${req_result}   ${req_result}
    Remove pyro server old lib
    Reset Inseego Control PC
    Sleep   1m
    wait until keyword succeeds   10m   1m   csn.Connect to   hostname=${cpc_ip}
    ...   username=${cpc_username}   password=${cpc_password}   alias=cpc_${ue_index}   timeout=120
    wait until keyword succeeds   5m   30s   Connect ADB devices   alias=${cpc_connect}   serial_number=${serial}
    Sleep   20s
    [Return]   ${false}

Reset adb service
    [Documentation]   DEP keyword. Please use the common keyword `Restart adb server and wait until status ready`
    ...   Author: jingmin.he@nokia-sbell.com
    [Arguments]   ${cpc_connect}
    csn.Execute   command=adb kill-server   connection=${cpc_connect}
    csn.Execute   command=adb start-server   connection=${cpc_connect}

Reset Inseego Control PC
    Connect to ue control pc   cpc_ip=${cpc_ip}   cpc_username=${cpc_username}   cpc_password=${cpc_password}   cpc_alias=cpc_${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    [Teardown]   csn.disconnect      connection=cpc_${ue_index}

Remove pyro server old lib
    Connect to ue control pc   cpc_ip=${cpc_ip}   cpc_username=${cpc_username}   cpc_password=${cpc_password}   cpc_alias=cpc_${ue_index}
    csn.Execute    command=rm -rf /cygdrive/c/pyro_server/ta_ue_plugin_android    connection=cpc_${ue_index}
    [Teardown]   csn.disconnect      connection=cpc_${ue_index}

#Test Inseego Connection
#    Log   ${capabilities}
#    csn.Connect to   ${cpc_config['ue_pc_ip']}   ${cpc_config['login']}   ${cpc_config['password']}   alias=cpc_${ue_index}
#    ute_ue.Require Ue   ue_alias=UE_${ue_index}  capabilities=${capabilities}
#    run keyword and ignore error   Ue detach with index   ue_index=${ue_index}
#    Android UE Attach for L3 Call Preparation
#    ute_ue.Start Data Transfer   TRANSFER_DL   UE_${ue_index}  duration=90s   direction=dl  throughput=100 Mbits/sec
#    ...   packet_size=1400   qci=5
#    ute_ue.Await Data Transfer Finish   TRANSFER_DL
#    ute_ue.Verify Average Throughput   TRANSFER_DL   10 Mbits/sec
#    [Teardown]   csn.Disconnect   connection=cpc_${ue_index}

_start_dl_traffic_with_tp_check_askey
    [Arguments]    ${traffic_stop}=${true}    ${duration}=90    ${ue_index}=${0}    ${dl_deviation}=0.95
    ...    ${ue_type}=askey    ${Send_Tput_DL}=200M     ${Expect_Tput_DL}=50M    ${method}=normal    ${cell_list}=${EMPTY}
    Start DL traffic ASKEY     ue_type=${ue_${ue_index}_type}    Send_Tput_DL=${Send_Tput_DL}M    duration=${duration}
    ...   iperf_port=${AT_iperf_port}
    Wait Until Keyword Succeeds   ${duration}   10s   Check Tput l3call   ue_type=${ue_${ue_index}_type}   direction=dl
    ...   expect=${Expect_Tput_DL}   cells=${cell_list}   ue_index=${ue_index}    target_avg_percent=${dl_deviation}
    [Teardown]    run keyword if  ${traffic_stop}  Stop DL traffic ASKEY    ue_type=${ue_${ue_index}_type}

_start_ul_traffic_with_tp_check_askey
    [Arguments]    ${traffic_stop}=${true}    ${duration}=90    ${ue_index}=${0}    ${ul_deviation}=0.95
    ...    ${ue_type}=askey    ${ul_tput}=120M     ${Expect_Tput_UL}=30M    ${method}=normal    ${cell_list}=${EMPTY}
    Start UL traffic ASKEY     ue_type=${ue_type}   ue_index=${ue_index}
    ...    Send_Tput_UL=${ul_tput}M   duration=${duration}
    ...   iperf_port=${AT_iperf_port_ul}   ul_length=1400
    Wait Until Keyword Succeeds   ${duration}   10s   Check Tput l3call   ue_type=${ue_${ue_index}_type}   direction=ul
    ...   expect=${Expect_Tput_UL}   cells=${cell_list}   ue_index=${ue_index}    target_avg_percent=${ul_deviation}
    [Teardown]    run keyword if  ${traffic_stop}  Stop DL traffic ASKEY    ue_type=${ue_${ue_index}_type}

_Start_Peak_Traffic_Testing_ASKEY
    [Documentation]   Use this keyword if drx open
    [Arguments]   ${ue_type}   ${dl_throughput}   ${ul_throughput}   ${cell_list}   ${ue_index}=${0}
    ...   ${dl_expect}=${dl_throughput}   ${ul_expect}=${ul_throughput}   ${target_avg_percent}=0.95
    ...   ${duration}=600    ${dl_deviation}=0.95   ${ul_deviation}=0.95
    ${duration_traffic}   evaluate   ${duration}+${180}
    ${duration_traffic}    set variable   ${duration_traffic}s
    ${dl_tput}   Evaluate   int(${dl_throughput}*1.1)
    ${ul_tput}   Evaluate   int(${ul_throughput}*1.5)
    Start DL traffic ASKEY    ue_type=${ue_${ue_index}_type}    Send_Tput_DL=${dl_tput}M    duration=${duration_traffic}
    ...   iperf_port=${AT_iperf_port}
    Run Keyword and Continue on Failure   Start UL traffic ASKEY   ue_type=${ue_type}   ue_index=${ue_index}
    ...    Send_Tput_UL=${ul_tput}M   duration=${duration_traffic}
    ...   iperf_port=${AT_iperf_port_ul}   ul_length=1400
    ${tput_log}   power_ue.Collect Tput   ue_type=${ue_type}    duration=${duration}
    power_ue.Check Bi Tput   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${dl_expect}   ultarget_throughput=${ul_expect}   target_avg_percent=${dl_deviation}
    [Teardown]   Run Keywords   Run Keyword and Ignore Error   power_ue.Stop Traffic
    ...   ue_type=${ue_type}   ue_index=${ue_index}   direction=dl   dt_name=dl_${ue_index}
    ...   AND   Run Keyword and Ignore Error   Close the iperf process on ASKEY   ue_index=${ue_index}

Start DL traffic ASKEY
    [Arguments]    ${ue_type}=askey    ${Send_Tput_DL}=200M    ${duration}=90    ${iperf_port}=58092    ${ul_length}=1400
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${Send_Tput_DL}   duration=${duration_output}    iperf_port=${iperf_port}

Start UL traffic ASKEY
    [Arguments]    ${ue_type}=askey    ${Send_Tput_UL}=200M    ${duration}=900    ${iperf_port}=58092
    ...    ${ul_length}=${ul_length}    ${ue_index}=${0}
    ${ue_ip}    ute_ue.Get Ue Info    UE_${ue_index}    IP
    wait until keyword succeeds    1 min    10 sec   csn.Connect to   hostname=${cpc_ip}  username=${cpc_username}
    ...   password=${cpc_password}    alias=cpc_${ue_index}
    ${cmd_start_iperf_client}    Catenate
    # ...   iperf.exe -c ${appserver_addr} -u -b ${Send_Tput_UL} -i 1 -l 1400 -t 36000 -p ${iperf_port} -B ${ue_ip}
    ...    adb -s ${serial} shell iperf -u -c ${appserver_addr} -b ${Send_Tput_UL} -t 9999999 -i 1 -l 1400 -p ${iperf_port}
    csn.send command     command=${cmd_start_iperf_client}    connection=cpc_${ue_index}
    [Teardown]   csn.disconnect      connection=cpc_${ue_index}


Close the iperf process on ASKEY
    [Arguments]     ${ue_index}=${0}
    wait until keyword succeeds    1 min    10 sec   csn.Connect to   hostname=${cpc_ip}  username=${cpc_username}
    ...   password=${cpc_password}    alias=cpc_${ue_index}
    csn.execute    command=ps -ef |grep iperf|awk '{print $2}'|xargs kill -9    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Check DL traffic ASKEY
    [Arguments]   ${ue_type}=askey    ${Expect_Tput_DL}=50
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput
    ...    ue_type=${ue_type}    direction=dl    throughput=${Expect_Tput_DL}

Stop DL traffic ASKEY
    [Arguments]   ${ue_type}=askey
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${AT_iperf_port}

UE precondition ASKEY
    [Documentation]   Require UE precondition, and avoid the duplicated require_ue actions same UE
    [Arguments]   ${ue_index}    ${ue_type}    ${method}=normal
    ${reboot_flag}    set Variable    true
    _Prepare Variables    ue_index=${ue_index}
#    Run Keyword If   '${method}'=='PEAK'    Reboot UE control PC ASEKY
    wait until keyword succeeds    5 min    20 sec   csn.Connect to   hostname=${cpc_ip}  username=${cpc_username}
    ...   password=${cpc_password}    alias=cpc_${ue_index}
    power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}    reset_sol=${reboot_flag}
    sleep  20s
    run keyword if  '${reboot_flag}'=='true'    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_required}   ${true}
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_required}   ${true}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_nrCellId}   None
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_nrCellId}   None

Reboot UE control PC ASEKY
    wait until keyword succeeds    1 min    10 sec   csn.Connect to   hostname=${cpc_ip}  username=${cpc_username}
    ...   password=${cpc_password}    alias=cpc_${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    sleep  1min
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}
