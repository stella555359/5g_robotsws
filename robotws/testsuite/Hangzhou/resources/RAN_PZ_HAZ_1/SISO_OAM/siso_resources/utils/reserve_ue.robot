*** Settings ***
Documentation
...    SISO Common Resource files

#Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Library           taf.ue  WITH NAME   ute_ue
Library           taf.transport.ssh    WITH NAME    csn
Library           ../../../../resources/RAN_PZ_HAZ_34/python/ue.py
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource          ../../../../resources/RAN_PZ_HAZ_34/robot/aasyslog.robot



*** Keywords ***

################################## STEP1: Prepare UE for L3 call ##################################
_Prepare UE Variables
    [Arguments]  ${ue_index}=${0}    ${index}=${0}
    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[${ue_index}]}    index=${index}
    set suite variable    ${ue_config}
    set suite variable    ${cpc_ip}     ${ue_config['cpc_ip']}
    set suite variable    ${cpc_username}    ${ue_config['cpc_username']}
    set suite variable    ${cpc_password}    ${ue_config['cpc_password']}
    set suite variable    ${appserver_addr}    ${ue_config['data_transfer']['ssh']['host']}
    set suite variable    ${appserver_username}    ${ue_config['data_transfer']['ssh']['user']}
    set suite variable    ${appserver_password}    ${ue_config['data_transfer']['ssh']['password']}
    set suite variable    ${serial}    ${ue_config['serial_number']}
    set suite variable    ${capabilities}    ${ue_config['capabilities']}
    set suite variable    ${qci}    ${ue_config['qci']}
    set suite variable    ${AT_iperf_port}    ${ue_config['data_transfer']['iperf_options']['qci']['5']}
    ${status}    run keyword and return status    get from dictionary
    ...   ${ue_config['data_transfer']['iperf_options']['qci']}    6
    run keyword if    ${status}    set suite variable    ${AT_iperf_port_ul}    ${ue_config['data_transfer']['iperf_options']['qci']['6']}
    ${status}    run keyword and return status    get from dictionary    ${ue_config['data_transfer']}    ue_ssh
    run keyword if    ${status}    run keywords    set suite variable    ${ue_manage_ip}    ${ue_config['data_transfer']['ue_ssh']['host']}    AND
    ...    set suite variable    ${ue_manage_username}    ${ue_config['data_transfer']['ue_ssh']['user']}    AND
    ...    set suite variable    ${ue_manage_password}    ${ue_config['data_transfer']['ue_ssh']['password']}    AND
    ...    set suite variable    ${ue_manage_root_password}    ${ue_config['data_transfer']['ue_ssh']['root_password']}

Prepare UE At Cmd
    [Arguments]  ${ue_index}=${0}    ${index}=${0}    ${reboot_ue}=${False}
    _Prepare UE Variables    ue_index=${ue_index}    index=${index}
    csn.connect_to   ${cpc_ip}    ${cpc_username}    ${cpc_password}
    ...    timeout=120    alias=cpc_${ue_index}
    csn.Execute   command=adb kill-server   connection=cpc_${ue_index}
    csn.Execute   command=adb start-server   connection=cpc_${ue_index}
    run keyword if    '${reboot_ue}'=='${True}'    _Reboot_UE    connection=cpc_${ue_index}
    ute_ue.require_ue    ue_alias=UE_${ue_index}    capabilities=${capabilities[0]}

Prepare UE
    [Arguments]    ${ue_index}=${0}    ${index}=${0}    ${reset_sol}=${True}    &{kwargs}
    [Documentation]    Prepare UE for L3 call test.
    ...  :param  ue_index: <Int> The list index from tl.ues[], it will use the index UE for reserve
    ...  :param  reset_sol: <Boolean> Reset ue by adb command or not.
    ${reboot_ue}    set variable if    '${reset_sol}'!='none'    ${True}    ${False}
    Prepare UE At Cmd    ue_index=${ue_index}    index=${index}    reboot_ue=${reboot_ue}

Start traffic
    [Arguments]    ${direction}    ${throughput}    ${duration}    ${iperf_port}    ${ue_index}=${0}
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${process_num}=${5}    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...                 2020/2/22 Jia Lei: updated for two askey ues, as only one ue list out in init file.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer, like 10M
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  iperf_port: port number used for traffic start via iperf.
    ...  :param  process_num: the number of process which are used for tcp data transfer, the more the better.
#    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${ue_config['data_transfer']['iperf_options']['qci']['5']}
    ...                                                           ${ue_config['data_transfer']['iperf_options']['qci']['6']}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    ${ue_ip}    ute_ue.Get Ue Info    UE_${ue_index}    IP
    run keyword if    '${direction}' == 'dl'    wait until keyword succeeds    3x    10s    Start DL traffic via iperf on Appserver for Askey
    ...                                                                                    ue_addr=${ue_ip}
    ...                                                                                    dl_time=${duration}
    ...                                                                                    dl_port=${port}
    ...                                                                                    dl_throughput=${throughput}
    ...                                                                                    dl_length=${buffer_size}
    ...                                                                                    appserver=${appserver}
    ...                                                                                    protocol=${protocol}
    ...                                                                                    ue_index=${ue_index}
    ...                                                                                    process_num=${process_num}
    ...                                                                                    serial_number=${serial}
    ...                                                                                    cpc_ip=${cpc_ip}
    ...                                                                                    cpc_usrname=${cpc_username}
    ...                                                                                    cpc_passwd=${cpc_password}
    ...    ELSE IF    '${direction}' == 'ul'    wait until keyword succeeds    3x    10s    Start UL traffic via iperf from andriod UE
    ...                                                                                       ue_index=${ue_index}
    ...                                                                                       ul_time=${duration}
    ...                                                                                       ul_port=${port}
    ...                                                                                       ul_throughput=${throughput}
    ...                                                                                       ul_length=${buffer_size}
    ...                                                                                       appserver=${appserver}
    ...                                                                                       serial_number=${serial}
    ...                                                                                       protocol=${protocol}
    ...                                                                                       process_num=${process_num}
    ...                                                                                       iperf_index=${1}
    ...                                                                                       cpc_ip=${cpc_ip}
    ...                                                                                       cpc_usrname=${cpc_username}
    ...                                                                                       cpc_passwd=${cpc_password}

Stop traffic
    [Arguments]    ${direction}    ${iperf_port}    ${ue_index}=${0}    ${appserver}=APPserver    &{kwargs}
    [Documentation]    Stop data transfer for L3 call test.
    ...                 2020/2/22 Jia Lei: updated for two askey ues, as only one ue list out in init file.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
#    ${ue_config}   get_common_ue_config   ue_info=${tl.ues[0]}    index=${ue_index}
    ${default_port}    set variable if    '${direction}'=='ul'    ${ue_config['data_transfer']['iperf_options']['qci']['5']}
    ...                                                           ${ue_config['data_transfer']['iperf_options']['qci']['6']}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Close the iperf process on APPserver    port=${port}    appserver=${appserver}
    ...    ELSE IF    '${direction}' == 'ul'    Close the iperf process on android ue    ue_index=${ue_index}
    ...                                                                                  iperf_port=${port}
    ...                                                                                  serial_number=${serial}
    ...                                                                                  iperf_index=${1}
    ...                                                                                  cpc_ip=${cpc_ip}
    ...                                                                                  cpc_usrname=${cpc_username}
    ...                                                                                  cpc_passwd=${cpc_password}
