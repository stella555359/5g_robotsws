*** Settings ***
Documentation
...    author: Shi Daniel
...    contact: daniel.shi@nokia-sbell.com
...    Group: HGZ_SG2

Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library     taf.hw.channel_emulator     WITH NAME     Vertex
Library     py_script.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/spark_license.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables    1347_variables.py

*** Variables ***
${scf_file_path}          /home/ute/Downloads/SCF/common.xml
${DL_LENGTH}              1400
${duration}               9999
${DL_PORT}                52025
${UL_PORT}                52025
${UL_LENGTH}              1400
${tmp_lua_dir}    /home/ute/Downloads/Lua/generated_luashark/luashark.lua
${tmp_scf_dir}    /home/ute/Downloads/SCF
${tmp_swconfig_dir}    /home/ute/Downloads/swconfig/swconfig.txt
${tmp_swconfig_dir_bak}    /home/ute/Downloads/swconfig/swconfig_bak.txt

*** Keywords ***
Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    COAM Check GNB cell on air

Modify Case SCF and Commission
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${scf_file}=${scf_file_path}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${scf_file}
    ...    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${new_scf_file}
    Remove File    ${new_scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Recovery ENV
    COAM Teardown gnb connections
    Close the iperf process on Qualcomm
    Close the iperf process on APPserver    port=${DL_PORT}
    Android UE release

Start DL and UL traffic
    [Arguments]    ${ue_addr}    ${dl_throughput}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}    dl_time=${duration}    dl_port=${DL_PORT}
    ...                                        dl_throughput=${dl_throughput}    dl_length=${DL_LENGTH}
    #Start UL traffic via iperf from andriod UE    ue_index=${0}    ul_time=${duration}    ul_port=${UL_PORT}
    #...                                        ul_throughput=${ul_data_transfer}    ul_length=${UL_LENGTH}

Check DL UL Throughput
    [Arguments]    ${Expected_DL_Tput}    ${Expected_UL_Tput}
    Run Keyword And Ignore Error    Caculate UL throughput on gnb L2Lo    ul_expect=${Expected_UL_Tput}
    Run Keyword And Ignore Error    Calculate the E2E Appserver side UL TP    ul_expect=${Expected_UL_Tput}
    ...    ul_port=${UL_PORT}
    Caculate DL throughput on gnb L2Lo    dl_expect=${Expected_DL_Tput}
    Run Keyword And Ignore Error    Calculate the E2E UE side DL TP    ue_index=${0}    dl_expect=${Expected_DL_Tput}
    ...    dl_port=${DL_PORT}

Stop and Download Log
    [Arguments]    ${filename}    ${asik}=ASIK Master
    Connect to Common Unit Master
    ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
    ...    connection=${asik}
    ${PID}    strip_string    ${PID}
    csn.Execute    command=kill -2 ${PID}    connection=${asik}
    csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${LOG_PATH}/${filename}
    ...    connection=${asik}
    sleep    2s
    csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
    Csn.Disconnect	connection=${asik}

Start to Capture X2 Log on Asik
    [Arguments]    ${filename}
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump    connection=ASIK Master
    Start to Capture wireshark Log    listen_port=fp0    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ASIK Master

Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.send command    command=tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

Modify parameters in swconfig file
    [Arguments]    ${params}    ${Local_filePath}=${tmp_swconfig_dir}
    Connect to Common Unit Master
    Copy File    ${tmp_swconfig_dir}    ${tmp_swconfig_dir_bak}
    Modify_swConfig_file    parametersList=@{params}    filePath=${Local_filePath}
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${Local_filePath}    asik_alias=ASIK Master
    Copy File    ${tmp_swconfig_dir_bak}    ${tmp_swconfig_dir}
    Csn.Disconnect    connection=ASIK Master

Modify Swconfig and SCF
    [Arguments]    ${sw_params}    ${SCF}    ${scf_file}=${scf_file_path}
    Modify parameters in swconfig file    params=${sw_params}
    Modify Case SCF and Commission    PARAMS_TO_MODIFY_SCF=${SCF}    scf_file=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    [Return]    ${value}

Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

Recover swconfig file
    Connect to Common Unit Master
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${tmp_swconfig_dir}    asik_alias=ASIK Master
    Csn.Disconnect    connection=ASIK Master

Read BIP Wireshark Log
    [Arguments]    ${cap_file}    ${luapath}=${tmp_lua_dir}    ${filter}=${None}
    Wait until keyword succeeds    3 min    7 s    cap.Read cap    cap_file=${cap_file}
    ...    X=lua_script:${luapath}    display_filter=${filter}

Capture BIP Log
    [Arguments]    ${filename}    ${L1_Version}=L1R51
    Capture BIP Log Prepare and Start    filename=${filename}    L1_Version=${L1_Version}
    sleep    3s
    Capture BIP Log Stop and Download    filename=${filename}

Prepare For Bip Capture

    [Arguments]        ${script_path}=${CURDIR}
    ...                ${L1_version}=L1R52
    ...                ${source_to_capture}=GNB
    ...                ${connection}=ASIK Master
    ${store_script_path}      Set Variable    /ffs/run/config/scripts
    ${asik_mirror_script}     Set Variable    ${L1_version}_${source_to_capture}_asik_mirror_on.sh
    ${loner_mirror_script}    Set Variable    ${L1_version}_${source_to_capture}_loner_mirror_on.sh
    ${is_store_script_path_exists}    csn.file_exists    remote_path=${store_script_path}
    ...                               connection=${connection}
    Run keyword if    ${is_store_script_path_exists}==${False}
    ...    csn.execute    command=mkdir ${store_script_path}       connection=${connection}
    csn.upload_file     local_path=${script_path}/${asik_mirror_script}
    ...                        remote_path=${store_script_path}/${asik_mirror_script}
    ...                        connection=${connection}
    csn.upload_file     local_path=${script_path}/${loner_mirror_script}
    ...                        remote_path=${store_script_path}/${loner_mirror_script}
    ...                        connection=${connection}
    ${output}    csn.execute         command=chmod 777 ${store_script_path}/${asik_mirror_script}
    ...    connection=${connection}
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}
    ${output}    csn.execute         command=chmod 777 ${store_script_path}/${loner_mirror_script}
    ...    connection=${connection}
    Should be empty    ${output}    msg=Fail to change file permission, output message is: ${output}
    csn.Send Command     command=sh ${store_script_path}/${asik_mirror_script}    connection=ASIK Master

Capture BIP Log Prepare and Start
    [Arguments]    ${filename}    ${L1_Version}=L1R51
    Connect to Common Unit Master
    Prepare For Bip Capture    script_path=${CURDIR}    L1_version=${L1_Version}
    sleep    15s
    Start BIP Capture On ASIK    log_prefix=${filename}
    Csn.Disconnect    connection=ASIK Master

Capture BIP Log Stop and Download
    [Arguments]    ${filename}
    Connect to Common Unit Master
    Stop BIP Capture On ASIK
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC    log_prefix=${filename}
    Set Test Variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master

Common Capture BIP log prepare and start
    [Arguments]    ${file_size}=100    ${filter}=off
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts    file_size_mbytes=${file_size}    filtering=${filter}
    Csn.Disconnect    connection=ASIK Master

Common Capture BIP log and download
    [Arguments]    ${duration}=3s
    New Start Bip Log with Suitable Means
    sleep    ${duration}
    New Stop Bip Log with Suitable Means

Old start Capture BIP log
    Connect to Common Unit Master
    Precondition for bip capture with gnbMirroring scripts
    Bip Capture with gnbMirroring scripts

Old stop Capture BIP log and download
    ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    asil_interface=nac_eth2
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    Csn.Disconnect    connection=ASIK Master

New Start Bip Log with Suitable Means
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=${None}
    ...            ${gnb_index}=0
    ...            ${timeout}=900
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Collect Interface Mirroring Bip Collector
    ...                                target_file_name=${target_file_name}
    ...                                nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                gnb_index=${gnb_index}
    ...                                timeout=${timeout}
    ...                                interface=${interface}
    ...                                destination=${destination}
    ...                                host_ip=${host_ip}
    ...                                username=${username}
    ...                                password=${password}

New Stop Bip Log with Suitable Means
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector
    ...    target_file_name=${target_file_name}
    ...    pattern=${pattern}
    ...    target_dir=${target_dir}
    set test variable    ${bip_log_path}    ${full_log_path}[0]

Check_BIP_Value_From_Wireshark
    [Arguments]    ${bip_log}    ${item}    ${result}
    ...    ${condition_expression}=${None}    ${check_value}=True
    Read BIP Wireshark Log    cap_file=${bip_log}
    ${value}=    Get PARAM Value from Wireshark Log    check_param=${item}
    ...    condition_expression=${condition_expression}
    Run Keyword If    '${check_value}'=='True'    Should Contain    ${value}    ${result}
    ...    ELSE    Should Not Contain    ${value}    ${result}

Check expression in Wireshark Log
    [Arguments]    ${expression}
    cap.Check Expression    condition_expression=${expression}

Reset UL Bler Counter On Loner for SA
    [Arguments]   ${connection}=ABIL Loner
    ${output}    csn.execute    command=fpga_rw wa 0xdf8000b8 0x1    connection=${connection}
    Should Not Contain    ${output}    error    msg=reset ul bler counter failed     ignore_case=True

Check_MCS_Value
    [Arguments]    ${bip_log}    ${item}    ${min_MCS}    ${max_MCS}
    Read BIP Wireshark Log    cap_file=${bip_log}
    @{value}=    Get PARAM Value from Wireshark Log    check_param=${item}
    FOR    ${flag}    IN    @{value}
        should be true    ${min_MCS}<=${flag}<=${max_MCS}
    END

Caculate DL throughput from gnb L2Lo
   [Arguments]    ${dl_expect}     ${location}=${16}
    wait until keyword succeeds     1 min     10 sec     Connect to Common Unit Master
    wait until keyword succeeds     1 min     10 sec     Connect to Capacity Unit Master
    ${dl_tp_l2lo}=     Calculate DL throughoutput trunk     location=${location}     alias=ABIL Master
    should be true     ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]     Run Keywords     run keyword and ignore error     csn.disconnect     connection=ABIL Master
    ...     AND     run keyword and ignore error     csn.disconnect     connection=ASIK Master

Login WEBUI
    [Arguments]    ${url}    ${username}=Nemuadmin    ${password}=nemuuser
    selenium_coam.login    url=${url}    username=${username}    password=${password}

Logout WEBUI
    selenium_coam.logout

Remove lists from scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    file_path=${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.remove_list_from_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
    END
    scf.Save scf    file_path=${output_scf}

Add lists to scf
    [Arguments]    ${input_scf}    ${output_scf}    ${parameters_lists}
    scf.Load scf    file_path=${input_scf}
    FOR    ${item}    IN    @{parameters_lists}
        scf.add list to scf  dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END
    scf.Save scf    file_path=${output_scf}

###Power_ue Keyword###

Get UE type
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    [Return]    ${ue_type}

Get UE ip
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    Get Commercial UE IP     ue_index=${ue_index}
    should not be empty     ${UE_IP}
    should not contain     ${UE_IP}     127.0.0.1

Reset UE for andriod
    [Arguments]     ${ue_index}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} reboot     connection=cygwin
    sleep     120s
    csn.disconnect     connection=cygwin

Common UE Attach
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA    ${power_reset}=False
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    get_spark_license=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}    attach_mode=${attach_mode}
    Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

Common UL Traffic and Check Tput
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=10M    ${send_duration}=180    ${check_traffic}=1
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${send_traffic}    duration=${send_duration}
    sleep    120s
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${check_traffic}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul

Common DL Traffic and Check Tput
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50M    ${send_duration}=180    ${check_traffic}=40
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${send_traffic}    duration=${send_duration}
    sleep    120s
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${check_traffic}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl

Common Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    apn_address=dxdata2

Common UE Detach
    [Arguments]    ${ue_index}=${0}    ${power_reset}=False
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=${power_reset}

Common UE Send UL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=10MKbits/sec    ${send_duration}=300    ${ue_mode}=SA    ${apn_address}=dxdata2
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    throughput=${send_traffic}    duration=${send_duration}    connection_type=current    apn_address=${apn_address}

Common UE Send DL Traffic
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=50MKbits/sec    ${send_duration}=300    ${ue_mode}=SA    ${apn_address}=dxdata2
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_mode=${ue_mode}
    ...    throughput=${send_traffic}    duration=${send_duration}    ue_index=${ue_index}    apn_address=${apn_address}

Common Get UE Ip By Sigspark SA
    [Arguments]    ${ue_index}=${0}    ${apnaddress}=dxdata2    ${ue_alias}=UE_${ue_index}
    ${ueip}    spark.get_pdu_ip    apnaddress=${apnaddress}    ue_alias=${ue_alias}
    [Return]    ${ueip}

Common Get UE Ip By Sigspark NSA
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}
    ${ueip}    spark.get_pdu_ip_by_AT    ue_alias=${ue_alias}
    [Return]    ${ueip}

Common UE Send UL TCP Traffic
    [Arguments]    ${ue_index}=${0}    ${traffic}=10MKbits/sec    ${duration}=3600    ${ue_mode}=SA
    ...            ${process_num}=${20}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}    ue_mode=${ue_mode}
    ...    throughput=${traffic}    duration=${duration}    connection_type=current    protocol=TCP    process_num=${process_num}
	log to console    .....UE_${ue_index} tcp ul iperf start....

Common open Iperf server on PC
   [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=ps -ef |grep iperf |grep -v grep |awk '{print $2}'    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=kill -9 ${pid} &    connection=cygwin
    sleep    2s
    csn.send_command    command=ps -ef |grep iperf |grep -v grep |awk '{print $2}'    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=c:/iperf/iperf.exe -s -p ${DL_port} -i 1 &    connection=cygwin

Common close Iperf server on PC
   [Arguments]    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=ps -ef |grep iperf |grep -v grep |awk '{print $2}'    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=kill -9 ${pid} &    connection=cygwin
    sleep    2s
    csn.send_command    command=ps -ef |grep iperf |grep -v grep |awk '{print $2}'    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin

Common UE Send DL TCP Traffic
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${duration}=1800
    ...            ${process_num}=${20}    ${seg_size}=1350    ${window}=10M    ${ue_mode}=SA
    ${ueip}    Run keyword if    '${ue_mode}'=='SA'    Common Get UE Ip By Sigspark SA    ue_index=${ue_index}
    ...    ELSE IF   '${ue_mode}'=='NSA'    Common Get UE Ip By Sigspark NSA
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    csn.send_command    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}'    connection=EPCAPP
	${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
    FOR    ${i}    IN RANGE    3
	    log to console    This is loop${i}
        csn.send_command
       ...   command=iperf -c ${ueip} -p ${DL_port} -i 1 -t ${duration} -P ${process_num} -w ${window} -M ${seg_size} &
       ...   connection=EPCAPP
	   sleep    3s
       csn.send_command    command=ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
       ...   connection=EPCAPP
	    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=EPCAPP
	    ${pid}=    Run keyword and continue on failure    Remove String    ${pid}    \n
        Exit For Loop If    '${pid}' != '${EMPTY}'
    END
	log to console    .....UE_${ue_index} tcp dl iperf start....
    [Teardown]    csn.disconnect      connection=EPCAPP

Common UE Check UL Tput
    [Arguments]    ${ue_index}=${0}    ${check_traffic}=8
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${check_traffic}    ue_index=${ue_index}

Common UE Check DL Tput
    [Arguments]    ${ue_index}=${0}    ${check_traffic}=40
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${check_traffic}    ue_index=${ue_index}

Common UE Check UL And DL Tput
    [Arguments]    ${ue_index}=${0}    ${check_traffic_ul}=8    ${check_traffic_dl}=40
    ${ue_type}    Get UE type    ue_index=${ue_index}
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
    ...                                    throughput=${check_traffic_ul}    ue_index=${ue_index}
    Run Keyword And Continue On Failure    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
    ...                                    throughput=${check_traffic_dl}    ue_index=${ue_index}

Modify ATT Channel Vaules
    [Documentation]
    ...           Modify values in hbte for several channel several ports or all ports.
    ...           para ${modified_channels}: <list> or  ${None}
    ...           this argumnets need to be set as list when you want to modify several ports.
    ...           for example:${modified_channels} = [5, 6, 7, 8], it means these four ports are modified.
    ...           default is ${None}, it means all channel ports got from testconfiguration will be modified.
    ...           para ${value}: <list>, it can be several values or only one.
    ...           for example:${value} = [10, 10, 20, 20], when you give four ports with four values,
    ...           if ${modified_channels} = [5, 6, 7, 8] and ${value} = [10, 20, 20, 30], it means port 5=10, 6=20, 7=20, 9=30
    ...           when you set ${value} = [10] , only one value for several ports, it will set modified_channels with the same value 10.
    ...           if ${modified_channels} = [5, 6, 7, 8] and ${value} = [10], it means port 5=10, 6=10, 7=10, 9=10
    ...           if ${modified_channels}=${None} and ${value} = [10], it will set all ports to value 10.
    [Arguments]    ${value}    ${modified_channels}=${None}    ${vendor}=HBTE    ${RU_id}=0    ${gnb_id}=0
    ${all_channels}    gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    attenuator.setup_attenuator
    ...    ip_addr=${ATTENUATOR_ADDR}
    ...    port=${attenuation_port}
    ...    attenuation_port_numbers=${all_channels}
    ...    vendor=${vendor}
    ${value_length}    get length    ${value}
    ${channels_to_modify}    Create Dictionary
    ${channels}    set variable if    ${modified_channels}!=${None}    ${modified_channels}    ${all_channels}
    FOR    ${channel}    IN    @{channels}
        ${index} =    get index from list    ${channels}    ${channel}
        ${value_dict}    set variable if    ${value_length}==1    ${value[0]}    ${value}[${index}]
        ${channel}    Convert To String    ${channel}
        Set To Dictionary    ${channels_to_modify}    ${channel}    ${value_dict}
    END
    Log To Console    ${channels_to_modify}
    gnb_classical_hangzhou.Modify Attenuation    channels_to_modify=${channels_to_modify}    RU_id=${ru_id}    gnb_id=${gnb_id}

Vertex Setup and Load Remote System Setting File
    [Arguments]     ${Vertex_Remote_System_Setting_File}     ${Vertex_Model}=${tl.channel_emulators.model}     ${Vertex_Alias}=Vertex_sg2
    ...     ${Vertex_Host}=${tl.channel_emulators.ip_addr}     ${Vertex_Port}=${tl.channel_emulators.port}     ${Vertex_Vendor}=spirent
    ...     ${Vertex_Proxy}=${tl.channel_emulators.proxy.addr}     ${Vertex_Proxy_User}=${tl.channel_emulators.proxy.username}
    ...     ${Vertex_Proxy_Pwd}=${tl.channel_emulators.proxy.password}
    Vertex.Setup     vendor=${Vertex_Vendor}     model=${Vertex_Model}     alias=${Vertex_Alias}     host=${Vertex_Host}     port=${Vertex_Port}
    ...     proxy=${Vertex_Proxy}     proxy_username=${Vertex_Proxy_User}     proxy_password=${Vertex_Proxy_Pwd}     timeout=${Vertex_Cmd_Timeout}
    Vertex.Load Remote System Setting File     ${Vertex_Remote_System_Setting_File}     emulator=${Vertex_Alias}
    sleep    60s

Vertex Teardown
    [Arguments]    ${Vertex_Alias}=Vertex_sg2
    Vertex.Stop Channel Emulation     emulator=${Vertex_Alias}
    sleep    30s
    Vertex.Disable Iq Playback    emulator=${Vertex_Alias}
    sleep    30s
    Vertex.Teardown     emulator=${Vertex_Alias}

Calculate UL Bler from ABIL Loner
    [Arguments]     ${expect_value}     ${connection}=ABIL Loner
    Connect to Capacity Unit Loner
    Reset UL Bler Counter On Loner for SA
    sleep    3s
    ${output}     csn.execute     command=fpga_rw ra 0xdf50c14c 2     connection=${connection}
    ${line1}     Get Line     ${output}     0
    ${line2}     Get Line     ${output}     1
    ${data_sum}     convert to number     ${line1.strip()}
    ${data_error}     convert to number     ${line2.strip()}
    ${Ul_bler}     Run Keyword If     ${data_sum}==${0}     Set Variable     ${0}
    ...     ELSE     Evaluate     ${data_error}/${data_sum}
    ${expect_value}     convert to number     ${expect_value}
    Should Be True     ${Ul_bler}<=${expect_value}     msg=UL Bler ${Ul_bler} is not meet the requirement:<=${expect_value}
    [Teardown]    run keyword and ignore error     csn.disconnect     connection=ABIL Master

Get UE Type for Power UE from File
    [Arguments]     ${ue_index}=${0}
    ${ue_type}     translate_power_ue_type_from_testline     ue_index=${ue_index}
    ${ue_type}     set test variable     ${ue_type}

Check eNB and start collect X2 log on enb_lte
    ${enbs}    testline_info.has_enb    tl=${tl}
    Run Keyword If    ${enbs}    Start to collect the X2 log on eNB

Check eNB and stop and download X2 log on enb_lte
    ${enbs}    testline_info.has_enb    tl=${tl}
    Run Keyword If    ${enbs}    Stop and download X2 Logs on eNB

Btslog Setup Collectors
    [Arguments]    ${path}=/opt/ute/tools/btslog/btslog    ${launcher_path}=/opt/ute/tools/btslog/btslog_launcher
    ...    ${log_folder}=/tmp/btslog2
    ${time}    Evaluate    datetime.datetime.now().strftime("%Y%m%d-%H:%M:%S")    datetime
    Set test variable    ${time}
    ${name}=   Set variable    btslog_${time}
    ${executor_test_vm}=      Create Dictionary
    ...    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...    user=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    btslog.create_btslog_collector
    ...    name=btslog_${time}
    ...    btslog_path=${path}
    ...    btslog_launcher_path=${launcher_path}
    ...    executor=${executor_test_vm}
    ...    log_dir=${log_folder}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    btslog.Set test Alias     ${name}

Btslog Teardown Collectors
    [Arguments]    ${name}=btslog_${time}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}
    core.teardown_collectors    names=${name}

Enable mirror port on Loki
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    csn.Execute     command=/usr/bin/lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_UL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asik_alias}
    csn.Execute     command=/usr/bin//lfs-nw_switch-mirror-tool.sh -p 1 -d ethsei00 -f L1_L2_DL -b "C1B1(2)" -s 1 -l ${mirror_port} -v 303
    ...             connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -p xgmac97 -r    connection=${asik_alias}
    csn.Execute     command=ncp_portmirror -d netdriver -p xgmac97    connection=${asik_alias}

Start Bip Log Capture on Loki
    [Arguments]     ${mirror_port}=eths2    ${asik_alias}=ASIK Master
    Enable mirror port on Loki    mirror_port=${mirror_port}
    csn.Send command     command=tcpdump -i ${mirror_port} -w /tmp/tcpdumpL2L1.pcap
    ...                  connection=${asik_alias}

Stop Bip Log Capture on Loki and download BIP Logs to testPC
    [Arguments]     ${interface}=eths2    ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}    ${download_type}=Download
    ...             ${log_prefix}=${None}
    Stop BIP Capture On ASIK    interface=${interface}
    ${list_log_path_local}    Download BIP Logs From ASIK To TestPC and rename it
    ...    log_path=${log_path}
    ...    connection=${connection}
    ...    download_type=${download_type}
    ...    log_prefix=${log_prefix}
    [Return]    ${list_log_path_local}

Start Bip Log on Loki and download BIP logs to testPC
    [Arguments]     ${duration}=3s
    Connect to Common Unit Master
    Start Bip Log Capture on Loki
    Sleep    ${duration}
    ${list_log_path_local}    Stop Bip Log Capture on Loki and download BIP Logs to testPC    log_path=${OUTPUT_DIR}
    Set Test Variable     ${bip_log_path}     ${list_log_path_local}[0]
    Csn.Disconnect     connection=ASIK Master

Get bbmod type
    [Arguments]     ${connection}=GNB_OAM
    ${hw_info}     coam.get_detected_hw_info     connection=${connection}
    ${productName}     Set variable    ${hw_info['basebandModules'][0]['productName']}
    ${bbmod_type}     Set variable    ${productName.split(' ')[0]}
    Set test variable    ${bbmod_type}
    [Teardown]    run keyword and ignore error     csn.disconnect     connection=${connection}

Get current program in WebUI
    COAM Navigate to login page via webUI     download_dir=${TS_CASE_LOG_PATH}
    ${current_software}     Wait until keyword succeeds    3 min    5 s    selenium_coam.check_current_software_version
	${program}    Set variable    ${current_software['Active'].split('_')[0]}
	set test variable    ${program}
    [Teardown]     Run keyword and ignore error     Run keywords     selenium_coam.logout
    ...     AND     selenium_coam.disable_virtual_display
    [Return]     ${program}

Check BTS Counters via webUI
    [Arguments]    ${counter_id}    ${count_path}=${None}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${count_path}
    COAM selenium logout
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

Get_parameter_value
    [Arguments]    ${abbr}    ${filter_param}
    ${mrbtsid}    ${nrbtsid}    ${nrcellid}    get_mrbtsid_from_scf    file_path=${scf_file_path}
    ${dist_name}    set variable    MRBTS-${mrbtsid}/NRBTS-${nrbtsid}/NRCELL-${nrcellid}
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${value}    selenium_coam.get_parameter_value    abbr=${abbr}    filter_param=${filter_param}    dist_name=${dist_name}
    COAM selenium logout
    [Return]    ${value}

Get Average UL MCS from BIP log
    Log To Console    \nGet Average UL MCS from BIP log\n
    @{mcs_ul_hex}=     Get PARAM Value from Wireshark Log     check_param=UlData_PuschReceiveReq.grants_item_15.mcs
    @{mcs_ul_list}    Create list
    FOR    ${value}    IN    @{mcs_ul_hex}
        ${mcs_ul_dec}    Convert To Integer    ${value}    16
        Append to list    ${mcs_ul_list}    ${mcs_ul_dec}
    END
    log to console    mcs_ul_list=\n${mcs_ul_list}\n
    ${sum_mcs_ul}    set variable    0
    Remove Values From List    ${mcs_ul_list}    ${0}
    ${count}    get length    ${mcs_ul_list}
    FOR    ${value}    IN    @{mcs_ul_list}
        ${tmp}    Convert To Integer    ${value}
        ${sum_mcs_ul}    Evaluate    ${sum_mcs_ul} + ${value}
    END
    ${average_mcs_ul}    Run Keyword If    ${count}==0    Set Variable    ${0}    ELSE    Evaluate    ${sum_mcs_ul}.0/${count}.0
    ${average_mcs_ul}    Evaluate	round(${average_mcs_ul}, 1)
    log to console    average_mcs_ul=${average_mcs_ul}\n

Get Average DL MCS from BIP log
    Log To Console    \nGet Average DL MCS from BIP log\n
    @{mcs_dl_hex}=     Get PARAM Value from Wireshark Log     check_param=DlData_PdschSendReq.grants_item_15.mcs
    @{mcs_dl_list}    Create list
    FOR    ${value}    IN    @{mcs_dl_hex}
        ${mcs_dl_dec}    Convert To Integer    ${value}    16
        Append to list    ${mcs_dl_list}    ${mcs_dl_dec}
    END
    log to console    mcs_dl_list=\n${mcs_dl_list}\n
    ${sum_mcs_dl}    set variable    0
    Remove Values From List    ${mcs_dl_list}    ${0}
    ${count}    get length    ${mcs_dl_list}
    FOR    ${value}    IN    @{mcs_dl_list}
        ${tmp}    Convert To Integer    ${value}
        ${sum_mcs_dl}    Evaluate    ${sum_mcs_dl} + ${value}
    END
    ${average_mcs_dl}    Run Keyword If    ${count}==0    Set Variable    ${0}    ELSE    Evaluate    ${sum_mcs_dl}.0/${count}.0
    ${average_mcs_dl}    Evaluate	round(${average_mcs_dl}, 1)
    log to console    average_mcs_dl=${average_mcs_dl}\n

Get Bler from BIP log
    Log To Console    -------------------Check bler for ackNack-------------------
    ${ackNack_list}=     Get PARAM Value from Wireshark Log     check_param=UlData_PucchReceiveRespHarqD.ackNack.ackNack_item_0
    ${ackNack_sum}    Get Length    ${ackNack_list}
    ${count_80}    Get Match Count    ${ackNack_list}    80
    ${count_c0}    Get Match Count    ${ackNack_list}    c0
    ${count_f0}    Get Match Count    ${ackNack_list}    f0
    ${count_f8}    Get Match Count    ${ackNack_list}    f8
    ${ack_sum}    Evaluate    ${count_80}+${count_c0}+${count_f0}+${count_f8}
    ${Nack_sum}    Evaluate    ${ackNack_sum}-${ack_sum}
    ${bler_avg}    Run Keyword If    ${ackNack_sum}==0    Log To Console    ackNack_sum=0
    ...    ELSE    Evaluate    round(round(${Nack_sum},1)/round(${ackNack_sum},1),4)*100
    Log To Console    bler_avg=${bler_avg}%\n
    #  --------------------------------------------------------------------------#
    Log To Console    -------------------Check bler for rvIndex-------------------
    ${rvIndex_list}=     Get PARAM Value from Wireshark Log     check_param=DlData_PdschSendReq.grants_item_15.rvIndex
    ${rvIndex_sum}    Get Length    ${rvIndex_list}
    ${rvIndex_count_0}    Get Match Count    ${rvIndex_list}    00
    ${bler_rvIndex}    Run Keyword If    ${rvIndex_sum}==0    Log To Console    rvIndex_sum=0
    ...    ELSE    Evaluate    round(round(${rvIndex_sum}-${rvIndex_count_0},1)/round(${rvIndex_sum},1),4)*100
    Log To Console    bler_rvIndex=${bler_rvIndex}%\n
    #  --------------------------------------------------------------------------#
    Log To Console    -------------------Check bler for crc-------------------
    ${crc_list}=     Get PARAM Value from Wireshark Log     check_param=UlData_PuschReceiveRespHarqU.grants_item_15.crc
    ${crc_sum}    Get Length    ${crc_list}
    ${crc_count_1}    Get Match Count    ${crc_list}    1
    ${bler_ul}    Run Keyword If    ${crc_sum}==0    Log To Console    no crc_sum=0
    ...    ELSE    Evaluate    round(round(${crc_count_1},1)/round(${crc_sum},1),4)*100
    Log To Console    bler_ul=${bler_ul}%\n

Get dlul numOfLayers and rnit from BIP log
    #  --------------------------------------------------------------------------#
    ${numofLaysers_ul}=     Get PARAM Value from Wireshark Log     check_param=UlData_PuschReceiveReq.grants_item_15.numOfLayers
    Log To Console    numofLaysers_ul=\n${numofLaysers_ul[:200]}\n
    #  --------------------------------------------------------------------------#
    ${numofLaysers_dl}=     Get PARAM Value from Wireshark Log     check_param=DlData_PdschSendReq.grants_item_15.numOfLayers
    Log To Console    numofLaysers_dl=\n${numofLaysers_dl[:200]}\n
    #  --------------------------------------------------------------------------#
    ${rnti}=     Get PARAM Value from Wireshark Log     check_param=DlData_PdschSendReq.grants_item_15.rnti
	${rnti}    Remove Duplicates    ${rnti}
    Log To Console    rnti=\n${rnti}\n
    #  --------------------------------------------------------------------------#

Check channel quality in BIP
    [Arguments]     ${bip_log_path}    ${tmp_lua_dir}
    Log To Console    \nCheck channel quality in BIP\n
    Read BIP Wireshark Log     cap_file=${bip_log_path}    luapath=${tmp_lua_dir}
    Get Average UL MCS from BIP log
    Get Average DL MCS from BIP log
    Get Bler from BIP log
    Get dlul numOfLayers and rnit from BIP log

Collect TTI
    Create default connection
    Start TTI trace log capturing
    sleep     3s
    Stop TTI trace log capturing
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${TS_CASE_LOG_PATH}
    Set suite variable    ${CSV_PATH_UL}       ${dict_csv_file_path['UL']}
    Set suite variable    ${CSV_PATH_DL}       ${dict_csv_file_path['DL']}

Get NRcellID
    [Arguments]     ${nrcellgrp}=NRCELLGRP-0    ${nrcell}=NRCELL-0    ${nrcell_r}=NRCELL_R
    ...    ${parameter}=parameters    ${nrcellidenty}=nrCellIdentity    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cell_info}    coam.get_subcells_info    timeout=20    connection=${connection}
    ${nrcellid}    Set Variable    ${cell_info}[${nrcellgrp}][${nrcell}][${nrcell_r}][${parameter}][${nrcellidenty}]
    [Return]    ${nrcellid}
    [Teardown]    COAM Teardown gnb connections

Get NRcellInfo
    [Arguments]     ${cellid}=${0}    ${abbr}=nrCellType    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cell_info}    coam.get_cells_info    timeout=20    connection=${connection}
    ${nrcellinfo}    Set Variable    ${cell_info}[${cellid}][${abbr}]
    [Return]    ${nrcellinfo}
    [Teardown]    COAM Teardown gnb connections

Get NRcellid list
    [Arguments]    ${nrcell_r}=NRCELL_R    ${parameter}=parameters    ${nrcellidenty}=nrCellIdentity    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    ${cell_info}    coam.get_subcells_info    timeout=20    connection=${connection}
    ${cell_len}    get length    ${cell_info}
    ${nrcell_list}    create list
    FOR    ${index}    IN RANGE    ${cell_len}
        ${num}    evaluate    2*${index}
        ${dic0}    get dictionary items    ${cell_info}
        ${nrcellgrp}    set variable    ${dic0}[${num}]
        ${dic1}    get dictionary items    ${cell_info}[${nrcellgrp}]
        ${nrcell}    set variable    ${dic1}[0]
        ${nrcellid}    Set Variable    ${cell_info}[${nrcellgrp}][${nrcell}][${nrcell_r}][${parameter}][${nrcellidenty}]
        Append to list    ${nrcell_list}    ${nrcellid}
    END
    [Return]    ${nrcell_list}
    [Teardown]    COAM Teardown gnb connections

Get Counter By ADMIN
    [Documentation]
	...    https://boamui-onion.dynamic.nsn-net.net/branches/master/cli-docs/tutorial-getCounters.html
	...    dist_name: BTS/MRBTS-1/NRBTS-1/NRCELL-1/NREIRP/"counterID"
	[Arguments]    ${dist_name}    ${connection}
	${counter}    coam.get_counters_info    dist_name=${dist_name}    connection=${connection}
	[Return]    ${counter}

Lock RU By ADMIN
    [Arguments]    ${dist_name}    ${connection}    ${timeout}=120
	coam.lock    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}

Unlock RU By ADMIN
    [Arguments]    ${dist_name}    ${connection}    ${timeout}=120
	coam.unlock    dist_name=${dist_name}    connection=${connection}    timeout=${timeout}

COAM check validation errors from webui for CB012840
    @{errors} =    create list
    ${defination_errors}    selenium_coam.get_definition_errors
    ${relation_errors}      selenium_coam.get_relation_errors
    ${errors}    combine lists    ${defination_errors}   ${relation_errors}
    Log to console    The current BTS exist errors as ${errors}.
    Should be empty    ${errors}

check pdl after sw update
     [Arguments]    ${download_dir}
     COAM Navigate to login page via webUI    download_dir=${download_dir}
     COAM check validation errors from webui for CB012840
#     COAM selenium logout
     COAM selenium close browser
