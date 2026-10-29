*** Settings ***
Documentation    Author:jia-rebecca.liu@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Variables         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/QoS_Latency/TestData/Qos_parameter_counter.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/get_counters_from_pm_file.py
Library           taf.stc.config      WITH NAME    stcl
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008246/Resources/CB008246_common_keywords.py
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/QoS_Latency/Resources/write_data_to_csv.py
Library           testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/None_Feature_SG3/QoS_Latency/Resources/Qos_counter_caculate.py




*** Variables ***
${Qos_SCF}                MRBTS-11694_gNB234_SCF.xml
${Qos_SCF_25R1}           MRBTS-11694_gNB234_SCF_25R1.xml
${Qos_SCF_24R2}           MRBTS-11694_gNB234_SCF_24R2.xml
${Qos_SCF_24R3}           MRBTS-11694_gNB234_SCF_24R3.xml
${swconfig}               /opt/workspace/SCF/swconfig.txt
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_BTS_ID}             ${tl.gnbs[0].global_bts_id}
${gNB_oam_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_oam_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_username}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_password}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${UTE_hostname}           ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_username}           ${tl.test_pc.default_ssh_connection_details.username}
${UTE_password}           ${tl.test_pc.default_ssh_connection_details.password}
${Server_ip}              ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${ul_ports}               ${tl.ues[0].iperf_details.ports[0]}
${dl_ports}               ${tl.ues[0].iperf_details.ports[1]}
${TMA_SSH_ALIAS}          e500
${E500_IP}                ${tl.ues[0].tma_host.addr}
${E500_USER}              ${tl.ues[0].tma_host.username}
${E500_PW}                ${tl.ues[0].tma_host.password}
@{UL_DELAY_QOS_GRP}         0

${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs/
${testcenter_tclfile_210M}       /opt/workspace/tester_center_script/start_traffic_210M_v1.tcl
#${testcenter_tclfile_208M}       /opt/workspace/tester_center_script/start_traffic_208M_v3.tcl
${testcenter_tclfile_208M}       /opt/workspace/tester_center_script/start_traffic_208M_80.tcl
${testcenter_tclfile_100M}       /opt/workspace/tester_center_script/start_traffic_below_100M_v1.tcl
${testcenter_tclfile_CA}         /opt/workspace/tester_center_script/start_traffic_30UE_CA_TDD_FDD.tcl
${testcenter_tclfile_slice}      /opt/workspace/tester_center_script/start_traffic_slices_50ue.tcl
${newest_xml_file_1}

${att_ipaddr}                       ${tl.attenuator[0].ip_addr}
${att_port_1}                       ${tl.attenuator[0].attenuation_port_numbers[0]}
${att_port_2}                       ${tl.attenuator[0].attenuation_port_numbers[1]}
${att_port_3}                       ${tl.attenuator[0].attenuation_port_numbers[2]}
${att_port_4}                       ${tl.attenuator[0].attenuation_port_numbers[3]}
${att_port_5}                       ${tl.attenuator[0].attenuation_port_numbers[4]}
${att_port_6}                       ${tl.attenuator[0].attenuation_port_numbers[5]}


*** Keywords ***
#--------------------TL prepare------------------#
Qos TL suite setup
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    robot_common_operations.Common Suite Setup
    Common Suite Setup for COAM
    ${release_info}=     Get sagnb release
    set suite variable     ${release_info}
    ${full_release_info}=    Get gnb full_release
    set suite variable     ${full_release_info}
    Get bts package version
    Check and kill TC_PID process
    Adjust the TL Topyoung attenuation value    PA_values=${20}
    run keyword and continue on failure    Connect to gnb coam via ssl    gnb_index=${0}    connection=gnb_oam    ignore_get_release_error=${False}
    run keyword and continue on failure    COAM Download scf from cluster    scf_dir_path=${epc_log_path}    connection=gnb_oam
#    Run Keyword If    '${release_info}' == 'SBTS25R1_ENB_0000'    Set Suite Variable    ${Qos_SCF}    ${Qos_SCF_25R1}
#    Run Keyword If    '${release_info}' == 'SBTS24R2_ENB_0000'    Set Suite Variable    ${Qos_SCF}    ${Qos_SCF_24R2}
#    Run Keyword If    '${release_info}' == 'SBTS24R3_ENB_0000'    Set Suite Variable    ${Qos_SCF}    ${Qos_SCF_24R3}
#    Common Case TestLine Setup    is_commission=True
#    ...                           golden_scf_name=${Qos_SCF}
##    ...                           Is_Swconfig=True
##    ...                           swconfig_file=${swconfig}

Qos TL suite teardown
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    robot_common_operations.Common Suite Teardown
    Common Suite Teardown for COAM

Get gnb full_release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${full_release_info}     set variable
    ...    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}_${info.split('_')[4]}_${info.split('_')[5]}
    [Return]    ${full_release_info}
    [Teardown]   csn.Disconnect   connection=release_info

#*****************Viavi*********************
Precondition for VAIVI with TM500
    [Arguments]    ${TMA_PATH}=${TMA_APP_PATH}    ${tma_alias}=tma
    ...            ${e500_script_path}=${E500_SCRIPTS_BASE}
    ...            ${is_protocal_log_needed}=${NEED_PROTOCAL_LOG}
    ...            ${k_t}=3
    ...            ${init_config}=Init_Config.txt
    ...            ${cell_config}=NSA_5G_Cell_Config.txt
    FOR    ${n}    IN    ${k_t}
      ${tma_PID}    Check TMA_PID exist or not    tma_alias=${tma_alias}
      ${tma_length}    get length    ${tma_PID}
      Run Keyword If    ${tma_length} > ${4}
      ...       Kill TMA_PID process    tma_alias=${tma_alias}
      ${tma_PID}    Check TMA_PID exist or not    tma_alias=${tma_alias}
      Exit For Loop If    ${tma_length} == ${4}
    END
    sleep    5s
    Start TMA with command    TMA_PATH=${TMA_PATH}    tma_alias=${tma_alias}
    sleep    60s
    ${tma_PID}    Check TMA_PID exist or not    tma_alias=${tma_alias}
    Should not be empty    ${tma_PID.strip()}    msg=TMA app is not started
    log to console    TMA is running with PID ${tma_PID}.
    wait until keyword succeeds    3 min    10 s    tm500_hangzhou.Connect    tm500_alias=${TMA_APP_ALIAS}
    Connect HW and Initialize FOR QOS    hw_connect_script_path=${e500_script_path}/${init_config}    tm500_alias=${TMA_APP_ALIAS}
    Run keyword if    ${is_protocal_log_needed}    Start logging on cobham
    tm500_hangzhou.Perform cell search    cell_search_script_path=${e500_script_path}/${cell_config}    tm500_alias=${TMA_APP_ALIAS}
    [Return]    ${tma_PID}

Connect HW and Initialize FOR QOS
    [Documentation]  Connect and initialize cobham.
    [Arguments]   ${hw_connect_script_path}=${template_dir}/Init_Config.txt      ${tm500_alias}=tm500
    [Timeout]    5 minutes

    log    Sending hw_connect_script from ${hw_connect_script_path}
    ${response}=  tm500_remote.send script  ${hw_connect_script_path}  alias=${tm500_alias}  timeout=5 minutes
    Should Not Contain    ${response}    Failure
    Should Not Contain    ${response}    Error checking out 5G NR Rel-16 UL Tx Switching license
    sleep   30s


Check TMA_PID exist or not
    [Arguments]    ${tma_alias}=tma
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    ${tma_PID}    csn.Execute    command=tasklist |grep TmaApplication.exe|awk '{print $2}'|head -n 2     connection=${tma_alias}
    [Return]    ${tma_PID}
    [Teardown]    csn.disconnect    connection=${tma_alias}

Check TC_PID exist or not
    [Arguments]    ${tc_alias}=tc
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tc_alias}
    ${tc_PID_pre}    csn.Execute    command=tasklist |findstr "TestCenter"     connection=${tc_alias}
    ${tc_PID_min}    run keyword and return status    should contain    ${tc_PID_pre}    TestCenter
    log to console    ${tc_PID_min}
    [Return]     ${tc_PID_min}
    [Teardown]    csn.disconnect    connection=${tc_alias}

Kill TMA_PID process
    [Arguments]    ${tma_alias}=tma
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    Wait Until Keyword Succeeds    5x    10sec     kill TMA_exe
    [Teardown]    csn.disconnect    connection=${tma_alias}

kill TMA_exe
    [Arguments]    ${tma_alias}=tma
    ${output}    csn.Execute    command=taskkill /F /IM TmaApplication.exe     connection=${tma_alias}    timeout=60
    should contain    ${output}    SUCCESS

Check and kill TMA_PID process
    [Arguments]    ${tma_alias}=tma
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    ${tma_PID}    csn.Execute    command=tasklist |grep TmaApplication.exe|awk '{print $2}'|head -n 2     connection=${tma_alias}
    ${tma_length}    get length    ${tma_PID}
    Run Keyword If    ${tma_length} > ${4}
    ...    Wait Until Keyword Succeeds    5x    10sec     kill TMA_exe
    [Teardown]    csn.disconnect    connection=${tma_alias}



kill TC_PID Process
    [Arguments]    ${tc_alias}=tc
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tc_alias}
    ${output}    csn.Execute    command=taskkill /F /IM TestCenter*     connection=${tc_alias}    timeout=60
    should contain    ${output}    SUCCESS
    [Teardown]    csn.disconnect    connection=${tc_alias}

Start TMA with command
    [Arguments]    ${TMA_PATH}=${TMA_APP_PATH}    ${tma_alias}=tma
    ${TM500_PORT}=  Convert To Integer  ${TM500_PORT}
    Wait Until Keyword Succeeds    3x    30sec     csn.Connect to    ${TM500_IP}    ${TM500_USER}    ${TM500_PW}    alias=${tma_alias}
    csn.send command    command=nohup "${TMA_PATH}" /u "Default User" /p ${TM500_PORT} /c y /a y 2>&1 &    connection=${tma_alias}
    [Teardown]    csn.disconnect    connection=${tma_alias}

Check and kill TC_PID process
    ${tc_PID}    Check TC_PID exist or not
    Run Keyword If    ${tc_PID} == True    kill TC_PID Process

Cobham retry 30ues attach if failed
#    [Timeout]    30 min
    [Arguments]    ${wiresharklog}
    ...    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${retry_time}=${3}    ${e500_alias}=${TMA_APP_ALIAS}
    ...    ${UE_attach}=SA_5G_UEattach.txt
    ...    ${UE_detach}=SA_5G_UEdetach.txt
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
           ${attach_status}    run keyword and return status    E500 30UE attach and verify
           ...                              attach_script_path=${e500_script_path}/${UE_attach}
           ...                              e500_alias=${e500_alias}
           Exit for loop if    ${attach_status}==${True}
           tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/${UE_detach}
           tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}
           Check and kill TMA_PID process
           sleep    30s
           ${detach_time}    Evaluate    ${detach_time}+1
           Log to console    Attached failed, retry detach time ${detach_time}
           Precondition for VAIVI with TM500
           sleep    10s
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed
    Log to console    attach success, can start traffic
    [Teardown]      Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}


E500 30UE attach and verify
    [Arguments]    ${attach_script_path}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=    tm500_remote.send script    ${attach_script_path}    alias=${e500_alias}
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    ${num_succue}    get count    ${response}    Random Access Complete
    should be true    ${num_succue} == 30
    ${ip_list_num}    get_ip_add_num    response=${response}
    should be true    ${ip_list_num} == 129

E500 50UE attach and verify
    [Arguments]    ${attach_script_path}    ${e500_alias}=${TMA_APP_ALIAS}
    Log to console    Sending attach_script from ${attach_script_path}
    ${response}=    tm500_remote.send script    ${attach_script_path}    alias=${e500_alias}
    Should contain    ${response}    Random Access Complete    msg=UE attach failed, string "Random Access Complete" is not found
    ${num_succue}    get count    ${response}    Random Access Complete
#    should be true    ${num_succue} == 50
    ${ip_list_num}    get_ip_add_num    response=${response}
    should be true    ${ip_list_num} == 400

Cobham 30UE detach and kill the TMA
    [Documentation]
    ...              Description: ${is_protocal_log_needed} if True, then it means protocal log is captured, so need to stop logging
    [Arguments]  ${e500_script_path}=${E500_SCRIPTS_BASE}    ${is_protocal_log_needed}=${NEED_PROTOCAL_LOG}
    ...          ${UE_detach}=SA_5G_UEdetach.txt
    tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/${UE_detach}
    Run keyword if    ${is_protocal_log_needed}    Stop logging on cobham
    tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}
    Run Keyword And Ignore Error    Check and kill TMA_PID process

Cobham retry 50ues attach if failed
#    [Timeout]    30 min
    [Arguments]    ${wiresharklog}
    ...    ${e500_script_path}=${E500_SCRIPTS_BASE}    ${retry_time}=${3}    ${e500_alias}=${TMA_APP_ALIAS}
    ...    ${UE_attach}=SA_5G_UEattach.txt
    ...    ${UE_detach}=SA_5G_UEdetach.txt
    ${detach_time}    Set variable    ${0}
    FOR    ${i}    IN RANGE    ${retry_time}
           ${attach_status}    run keyword and return status    E500 50UE attach and verify
           ...                              attach_script_path=${e500_script_path}/${UE_attach}
           ...                              e500_alias=${e500_alias}
           Exit for loop if    ${attach_status}==${True}
           tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/${UE_detach}
           tm500_hangzhou.Disconnect    tm500_alias=${TMA_APP_ALIAS}
           Check and kill TMA_PID process
           sleep    30s
           ${detach_time}    Evaluate    ${detach_time}+1
           Log to console    Attached failed, retry detach time ${detach_time}
           Precondition for VAIVI with TM500
           sleep    10s
    END
    Should be true    ${detach_time} < ${retry_time}    msg=Retry UE attach with ${retry_time} times and still failed
    Log to console    attach success, can start traffic
    [Teardown]      Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

########################### About traffic ########################################
Start Traffic with TC
    [Documentation]    Author:liujia
    ...    Description: taf version should be taf.stc.config == 0.3.0
    [Arguments]     ${testcenter_tclfile}=${testcenter_tclfile}
    stcl.create connection     ip_address=${UTE_hostname}    user_name=${UTE_username}    password=${UTE_password}
    ${tcl_excution}    stcl.execute_tcl_config_file    config_file=${testcenter_tclfile}
#    should not contain     ${tcl_excution}    ERROR



Check viavi traffic with aasyslog
    [Arguments]    ${target_throughput}     ${cellid}    ${direction}=DL    ${duration}=3m    ${gnb_index}=${0}
    ${list_of_cell_ids}    Create list    ${cellid}
    ${log_path}     __Standard Capturing Aasyslog Throughput     duration=${duration}    gnb_index=${gnb_index}
    ${output}    __Standard Check Aasyslog Throughput    direction=${direction}    log=${log_path}    cells=${list_of_cell_ids}
    ...    target_throughput=${target_throughput}    target_avg_percent=0.95    min_percent=0.85    actCarrierAggregation=${False}
    ...    customized_log_name=${None}    cell_indiv_tput=${None}
    [Return]    ${output}

Recovery aasyslogoutputAddress
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU    ${aa_sys_mode}=2
    ...            ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738    ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}





#*************PA****************

Adjust the TL Topyoung attenuation value
    [Arguments]     ${PA_values}    ${PA_values_FDD}=${20}
    ####create cell list#####
    @{att_ports_TDD}    Create List    ${att_port_1}    ${att_port_2}     ${att_port_3}     ${att_port_4}
    @{att_ports_FDD}    Create List    ${att_port_5}    ${att_port_6}
    ####create value list####
    @{PA_value_list_TDD}    Create List    ${PA_values}    ${PA_values}    ${PA_values}    ${PA_values}
    @{PA_value_list_FDD}    Create List    ${PA_values_FDD}    ${PA_values_FDD}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value topyoung    att_ports=${att_ports_TDD}    values=${PA_value_list_TDD}
    ...    att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_FDD}    values=${PA_value_list_FDD}
    ...    att_ipaddr=${att_ipaddr}


#*******************counter****************
Prepare with QoS counter time caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    360-${utc0}%300
    sleep    ${left_timer}

get all kpi from a pmfile
    [Arguments]    ${kpi_path}    ${KPI_file}    ${pm_xml_file}    ${para_index}=${1}
    ${dict_kpi_value}=    Calculate Dict Kpis From Pm File    pm_xml_file=${pm_xml_file}
    ...    kpi_file=${kpi_path}/${KPI_file}    para_index=${para_index}
    [Return]     ${dict_kpi_value}


Get counter and write into csv
    [Arguments]    ${test_start}    ${test_end}
    ...            ${ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...            ${gnb_index}=${0}
    ...            ${cellindex}=${1}
    ...            ${kpi_file}=${CURDIR}/Qos_KPI.txt
    ...            ${folder_name}=100M_PM
    ...            ${excel_name}=data_record_100M.csv
    ${xml_folder_file_list}    get_pm_file_from_classical_by_time    ip=${ip}
    ...                                                              username=${username}
    ...                                                              password=${password}
    ...                                                              connection=gNB_${gnb_index}
    ...                                                              local_path=${epc_log_path}
    ...                                                              folder_name=${folder_name}
    ...                                                              test_start=${test_start}
    ...                                                              test_end=${test_end}
    ${counter_value_dict}    getsum_counter_by_pm_file
    ...     kpi_file=${kpi_file}    xml_folder_file_list=${xml_folder_file_list}    para_index=${cellindex}
    ${kpi_value_dict}    calculate_kpi_by_counter    counter_dic_by_name=${counter_value_dict}    kpi_file=${kpi_file}
    write_data_to_csv.create_new_csv_file    csv_file_path=${epc_log_path}/${excel_name}
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=PDCP_UL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[PDCP_UL_DELAY_5QI1]    value2=${kpi_value_dict}[PDCP_UL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[PDCP_UL_DELAY_5QI3]    value4=${kpi_value_dict}[PDCP_UL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[PDCP_UL_DELAY_5QI5]    value6=${kpi_value_dict}[PDCP_UL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[PDCP_UL_DELAY_5QI7]    value8=${kpi_value_dict}[PDCP_UL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[PDCP_UL_DELAY_5QI9]    value10=${kpi_value_dict}[PDCP_UL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[PDCP_UL_DELAY_5QI128]    value_avg=${kpi_value_dict}[PDCP_UL_DELAY_AVG]
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=PDCP_DL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[PDCP_DL_DELAY_5QI1]    value2=${kpi_value_dict}[PDCP_DL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[PDCP_DL_DELAY_5QI3]    value4=${kpi_value_dict}[PDCP_DL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[PDCP_DL_DELAY_5QI5]    value6=${kpi_value_dict}[PDCP_DL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[PDCP_DL_DELAY_5QI7]    value8=${kpi_value_dict}[PDCP_DL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[PDCP_DL_DELAY_5QI9]    value10=${kpi_value_dict}[PDCP_DL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[PDCP_DL_DELAY_5QI128]    value_avg=${kpi_value_dict}[PDCP_DL_DELAY_AVG]
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=RLC_UL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[RLC_UL_DELAY_5QI1]    value2=${kpi_value_dict}[RLC_UL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[RLC_UL_DELAY_5QI3]    value4=${kpi_value_dict}[RLC_UL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[RLC_UL_DELAY_5QI5]    value6=${kpi_value_dict}[RLC_UL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[RLC_UL_DELAY_5QI7]    value8=${kpi_value_dict}[RLC_UL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[RLC_UL_DELAY_5QI9]    value10=${kpi_value_dict}[RLC_UL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[RLC_UL_DELAY_5QI128]    value_avg=${kpi_value_dict}[RLC_UL_DELAY_AVG]
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=RLC_DL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[RLC_DL_DELAY_5QI1]    value2=${kpi_value_dict}[RLC_DL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[RLC_DL_DELAY_5QI3]    value4=${kpi_value_dict}[RLC_DL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[RLC_DL_DELAY_5QI5]    value6=${kpi_value_dict}[RLC_DL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[RLC_DL_DELAY_5QI7]    value8=${kpi_value_dict}[RLC_DL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[RLC_DL_DELAY_5QI9]    value10=${kpi_value_dict}[RLC_DL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[RLC_DL_DELAY_5QI128]    value_avg=${kpi_value_dict}[RLC_DL_DELAY_AVG]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_56a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_56a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C120XX      release=${full_release_info}     kpi_value=${kpi_value_dict}[PDCP_PDU_RETX_SUM]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C010XX     release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_VOL_DISC_REL_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C050XX     release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_VOL_DISC_BUFTH_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C110XX    release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_DELAY_DISC_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C100XX     release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_VOL_DISC_QUEDLY_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_219a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_219a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5114b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5114b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5115a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5115a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_57     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_57]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5012     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5012]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5013     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5013]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5151d     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5151d]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5143b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5143b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5160b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5160b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5166     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5166]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5167c     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5167c]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5168     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5168]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_226     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_226]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_227     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_227]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5597b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5597b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5598b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5598b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5054b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5054b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5055c     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5055c]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5056d     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5056d]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5057e     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5057e]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5358e     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5358e]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5361     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5361]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5362     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5362]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5363     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5363]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5366     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5366]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5636     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5636]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5346c     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5346c]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55158C00001     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55158C00001]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55158C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55158C00002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55158C00003     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55158C00003]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55159C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55159C00002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55159C00001     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55159C00001]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    #####-------------------new add counter 20240407-----------------#####
    ...    kpi_name=M55125C09025     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55125C09025]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5922a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5922a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5918a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5918a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5923a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5923a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55125C09028     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55125C09028]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5920a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5920a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5921a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5921a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55148C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55148C00002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00013     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00013]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00014     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00014]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00015     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00015]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00016     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00016]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55306C09014     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55306C09014]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55306C09015     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55306C09015]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5917a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5917a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55357C00001     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55357C00001]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5109f     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5109f]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55338C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55338C00002]
    #####-------------------new add counter 20240613-----------------#####
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5906     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5906]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5907     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5907]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5908     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5908]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5909     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5909]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5910     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5910]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5911     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5911]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5912     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5912]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5913     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5913]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20003     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20003]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20004     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20004]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20005     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20005]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20006     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20006]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20007     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20007]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20008     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20008]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20009     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20009]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20010     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20010]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20011     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20011]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20012     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20012]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20013     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20013]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20014     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20014]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20015     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20015]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20016     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20016]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20017     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20017]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20018     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20018]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20019     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20019]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20020     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20020]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20021     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20021]




Get cell2 counter and write into csv
        [Arguments]    ${test_start}    ${test_end}
    ...            ${ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...            ${gnb_index}=${0}
    ...            ${cellindex}=${2}
    ...            ${kpi_file}=${CURDIR}/Qos_KPI_slice.txt
    ...            ${folder_name}=Slice_PM
    ...            ${excel_name}=data_record_slice.csv
    ${xml_folder_file_list}    get_pm_file_from_classical_by_time    ip=${ip}
    ...                                                              username=${username}
    ...                                                              password=${password}
    ...                                                              connection=gNB_${gnb_index}
    ...                                                              local_path=${epc_log_path}
    ...                                                              folder_name=${folder_name}
    ...                                                              test_start=${test_start}
    ...                                                              test_end=${test_end}
    ${counter_value_dict}    getsum_counter_by_pm_file
    ...     kpi_file=${kpi_file}    xml_folder_file_list=${xml_folder_file_list}    para_index=${cellindex}
    ${kpi_value_dict}    calculate_kpi_by_counter    counter_dic_by_name=${counter_value_dict}    kpi_file=${kpi_file}
    write_data_to_csv.create_new_csv_file    csv_file_path=${epc_log_path}/${excel_name}
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=PDCP_UL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[PDCP_UL_DELAY_5QI1]    value2=${kpi_value_dict}[PDCP_UL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[PDCP_UL_DELAY_5QI3]    value4=${kpi_value_dict}[PDCP_UL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[PDCP_UL_DELAY_5QI5]    value6=${kpi_value_dict}[PDCP_UL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[PDCP_UL_DELAY_5QI7]    value8=${kpi_value_dict}[PDCP_UL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[PDCP_UL_DELAY_5QI9]    value10=${kpi_value_dict}[PDCP_UL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[PDCP_UL_DELAY_5QI128]    value_avg=${kpi_value_dict}[PDCP_UL_DELAY_AVG]
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=PDCP_DL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[PDCP_DL_DELAY_5QI1]    value2=${kpi_value_dict}[PDCP_DL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[PDCP_DL_DELAY_5QI3]    value4=${kpi_value_dict}[PDCP_DL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[PDCP_DL_DELAY_5QI5]    value6=${kpi_value_dict}[PDCP_DL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[PDCP_DL_DELAY_5QI7]    value8=${kpi_value_dict}[PDCP_DL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[PDCP_DL_DELAY_5QI9]    value10=${kpi_value_dict}[PDCP_DL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[PDCP_DL_DELAY_5QI128]    value_avg=${kpi_value_dict}[PDCP_DL_DELAY_AVG]
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=RLC_UL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[RLC_UL_DELAY_5QI1]    value2=${kpi_value_dict}[RLC_UL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[RLC_UL_DELAY_5QI3]    value4=${kpi_value_dict}[RLC_UL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[RLC_UL_DELAY_5QI5]    value6=${kpi_value_dict}[RLC_UL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[RLC_UL_DELAY_5QI7]    value8=${kpi_value_dict}[RLC_UL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[RLC_UL_DELAY_5QI9]    value10=${kpi_value_dict}[RLC_UL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[RLC_UL_DELAY_5QI128]    value_avg=${kpi_value_dict}[RLC_UL_DELAY_AVG]
    write_data_to_csv.write_data_into_csv    csv_file_path=${epc_log_path}/${excel_name}
    ...    case_name=RLC_DL_DELAY    release=${full_release_info}
    ...    value1=${kpi_value_dict}[RLC_DL_DELAY_5QI1]    value2=${kpi_value_dict}[RLC_DL_DELAY_5QI2]
    ...    value3=${kpi_value_dict}[RLC_DL_DELAY_5QI3]    value4=${kpi_value_dict}[RLC_DL_DELAY_5QI4]
    ...    value5=${kpi_value_dict}[RLC_DL_DELAY_5QI5]    value6=${kpi_value_dict}[RLC_DL_DELAY_5QI6]
    ...    value7=${kpi_value_dict}[RLC_DL_DELAY_5QI7]    value8=${kpi_value_dict}[RLC_DL_DELAY_5QI8]
    ...    value9=${kpi_value_dict}[RLC_DL_DELAY_5QI9]    value10=${kpi_value_dict}[RLC_DL_DELAY_5QI80]
    ...    value11=${kpi_value_dict}[RLC_DL_DELAY_5QI128]    value_avg=${kpi_value_dict}[RLC_DL_DELAY_AVG]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_56a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_56a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C120XX      release=${full_release_info}     kpi_value=${kpi_value_dict}[PDCP_PDU_RETX_SUM]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C010XX     release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_VOL_DISC_REL_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C050XX     release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_VOL_DISC_BUFTH_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C110XX    release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_DELAY_DISC_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55320C100XX     release=${full_release_info}     kpi_value=${kpi_value_dict}[DL_VOL_DISC_QUEDLY_QOS_GRP]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_219a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_219a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5114b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5114b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5115a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5115a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_57     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_57]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5012     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5012]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5013     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5013]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5151d     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5151d]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5143b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5143b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5160b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5160b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5166     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5166]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5167c     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5167c]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5168     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5168]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_226     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_226]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_227     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_227]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5597b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5597b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5598b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5598b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5054b     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5054b]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5055c     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5055c]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5056d     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5056d]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5057e     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5057e]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5358e     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5358e]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5361     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5361]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5362     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5362]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5363     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5363]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5366     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5366]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5636     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5636]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5346c     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5346c]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55158C00001     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55158C00001]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55158C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55158C00002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55158C00003     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55158C00003]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55159C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55159C00002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55159C00001     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55159C00001]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    #####-------------------new add counter 20240407-----------------#####
    ...    kpi_name=M55125C09025     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55125C09025]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5922a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5922a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5918a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5918a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5923a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5923a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55125C09028     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55125C09028]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5920a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5920a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5921a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5921a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55148C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55148C00002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00013     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00013]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00014     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00014]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00015     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00015]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55163C00016     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55163C00016]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55306C09014     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55306C09014]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55306C09015     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55306C09015]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5917a     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5917a]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55357C00001     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55357C00001]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5109f     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5109f]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55338C00002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55338C00002]
    #####-------------------new add counter 20240613-----------------#####
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5906     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5906]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5907     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5907]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5908     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5908]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5909     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5909]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5910     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5910]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5911     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5911]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5912     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5912]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=NR_5913     release=${full_release_info}     kpi_value=${kpi_value_dict}[NR_5913]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20002     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20002]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20003     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20003]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20004     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20004]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20005     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20005]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20006     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20006]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20007     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20007]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20008     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20008]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20009     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20009]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20010     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20010]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20011     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20011]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20012     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20012]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20013     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20013]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20014     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20014]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20015     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20015]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20016     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20016]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20017     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20017]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20018     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20018]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20019     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20019]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20020     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20020]
    write_data_to_csv.write_kpi_value_into_csv     csv_file_path=${epc_log_path}/${excel_name}
    ...    kpi_name=M55350C20021     release=${full_release_info}     kpi_value=${kpi_value_dict}[M55350C20021]



#******************other common keyword****************
QoS Case Teardown for COAM
    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
    robot_common_operations.Common Case Teardown
    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
    Run keyword and ignore error    Tear down the all connections
    Run keyword and ignore error    CI_interface.Common Case Teardown
