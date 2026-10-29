*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Library     OperatingSystem
Library     String
Library     taf.gnb.oam.coam.vdu      WITH NAME    vdu
Library     taf.gnb.oam.coam.cu        WITH NAME    cu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/mmw4_coam_cloud_gnb.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Library     taf.transport.ssh      WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    att
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Cloud_RU_Vars.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot




*** Variables ***
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0:4]}
${appserver_addr}         ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${att_ipaddr}             ${tl.attenuator.ip_addr}
${att_api_port}           ${tl.attenuator.port}
${att_connection_port}    ${tl.attenuator.attenuator_ports[1]}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
@{case1_ul_tp_list}       50    80    90    100
@{case3_ul_tp_list}       100    200    100    200
@{case_row_list}          NR PDCP Thr. DL [Mbps]    NR PDSCH iBLER[%]
@{RU_lmi_sn_list}        L1213908226



*** Keywords ***
########### about Spark Muliti UE ################
Prepare MultiUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    log to console      "Prepare UE"
    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    get_spark_license=${False}    restart_ue=${restart_ue}    restart_network=${restart_network}     max_ue_num=${2}
    ...    is_need_reconnect_spark=${False}
    log to console      "UE Attach"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

MultiUE Start UDP UL Traffic_2
    [Arguments]    ${ul_tp_list}    ${ue_index_list}    ${ue_ip_dict}    ${ul_port_list}    ${ul_duration}
    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    csn.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    ${start_call_num}    Set Variable    ${-1}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${start_call_num}    Evaluate    ${start_call_num}+${1}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate
        ...    cmd /C "iperf.exe -c ${appserver_addr} -u -p ${ul_port_list[${ue_index}]}
        ...    -l 1350B -f k -b ${ul_tp_list[${ue_index}]}M -t ${ul_duration} -i 1 -P 1 -B ${UE_ip}"
        sleep   2s
        Start UDP Commond And ReadOut PID    command_str=${command_str}    ue_index=${start_call_num}
        log to console    UE_${ue_index} start UL UDP
    END

MultiUE Start UDP UL Traffic
    [Arguments]    ${ul_tp_list}    ${ue_index_list}    ${ue_ip_dict}    ${ul_port_list}    ${ul_duration}
    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
#    csn.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    sleep    2s
    ${start_call_num}    Set Variable    ${-1}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${start_call_num}    Evaluate    ${start_call_num}+${1}
        ${UE_ip}    get from dictionary    ${ue_ip_dict}     ${ue_index}
        ${command_str}    Catenate
        ...    /Bin/iperf -c ${appserver_addr} -u -p ${ul_port_list[${ue_index}]}
        ...    -l 1350B -f k -b ${ul_tp_list[${ue_index}]}M -t ${ul_duration} -i 1 -P 1 -B ${UE_ip}
        log to console    ${command_str}
        sleep   2s
        wait until keyword succeeds    2x    60s    Start UDP Commond And ReadOut PID    command_str=${command_str}    ue_index=${start_call_num}
        log to console    UE_${ue_index} start UL UDP
    END

MultiUE Start UDP Traffic
    [Arguments]    ${ul_tp_list}=None    ${ul_port_list}=${ul_power_port_list}    ${if_ul}=${True}    ${if_dl}=${True}    ${process}=${1}
    ...    ${buffer}=1500    ${ul_duration}=10    ${ue_alias}=spark_UE
    ${ue_ip_dict}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    log to console    ${ue_ip_dict}
    ${ue_index_list}    get dictionary keys    ${ue_ip_dict}
    run keyword if    ${if_ul}==${True}    MultiUE Start UDP UL Traffic    ul_tp_list=${ul_tp_list}
    ...    ue_index_list=${ue_index_list}
    ...    ue_ip_dict=${ue_ip_dict}    ul_port_list=${ul_port_list}    ul_duration=${ul_duration}
    sleep   2s
    run keyword if    ${if_dl}==${True}    log to console      "UE Start DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=dl    process=${process}
    ...    buffer=${buffer}
    [Return]    ${ue_ip_dict}

ReadOut PID
    [Arguments]    ${ue_index}
    log to console    Read PID
    csn.send command    command=tasklist /fi "imagename eq iperf.exe"    connection=sigspark
    ${pid}    wait until keyword succeeds    10s    2s    csn.Read Output    connection=sigspark
    ${pid}    Strip String    string=${pid}
    ${pid}    Split String    string=${pid}    separator=\r\n
    ${str_len}    get length    ${pid}
    ${pid_len}    Evaluate      ${ue_index} + ${3}
#    Should Be True  ${str_len} == ${pid_len}
    Run keyword and ignore error    Should Be True  ${str_len} >= ${3}
    log to console    ${pid}

Start UDP Commond And ReadOut PID
    [Arguments]  ${command_str}    ${ue_index}
    csn.send command     command=${command_str}    connection=sigspark
    log to console    start command success
    wait until keyword succeeds    40s    8s    ReadOut PID    ue_index=${ue_index}

MultiUE Stop UDP Traffic
    [Arguments]    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_alias}=spark_UE
    log to console      "UE Stop UL Traffic"
    run keyword if    ${if_ul}==${True}    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    run keyword if    ${if_ul}==${True}    csn.send command    command=taskkill /fi "imagename eq iperf3.exe" /F    connection=sigspark
    log to console      "UE Stop DL Traffic"
    run keyword if    ${if_dl}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    Run keyword and ignore error    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}
    Run keyword and ignore error    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

Start Spark TP Log
    [Arguments]    ${ue_alias}=spark_UE
    Create Directory     ${OUTPUT_DIR}/${TEST NAME}
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}

Stop Spark TP Log
    [Arguments]  ${ue_alias}=spark_UE    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${filter}=test
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${logpath}    filter=${filter}

Stop Traffic And Detach UE
    [Arguments]  ${if_ul}=${True}    ${if_dl}=${True}    ${ue_alias}=Spark_UE
    MultiUE Stop UDP Traffic    if_ul=${if_ul}    if_dl=${if_dl}    ue_alias=${ue_alias}
    MultiUE Detach    ue_alias=${ue_alias}

Delete Spark Log From Control Pc
    [Arguments]  ${connection}=Cygwin
    @{path_string}    split string    ${tl.ues[0].server_dir}    /
    ${spark_version}    set variable    ${path_string}[${2}]
    csn.connect_to    hostname=${Control_PC_addr}    username=${Control_PC_user}     password=${control_PC_pass}    alias=${connection}
    csn.send_command    command=cd '/cygdrive/c/tmp/uelog/AUTO';rm -rf *    connection=${connection}
    csn.send_command    command=cd '/cygdrive/c/Program Files (x86)/${spark_version}/Data/Tmp';rm -rf *    connection=${connection}
    [Teardown]  Run keyword and ignore error    csn.disconnect    connection=${connection}

Start Traffic By Spark
    [Arguments]    ${ul_tp_list}=None    ${if_ul}=${True}    ${if_dl}=${True}    ${duration}=10    ${process}=${1}    ${need_spark_log}=${False}
    ...    ${buffer}=1500    ${multiue_config_direction}=${PC1_TLCommonConfig["MultiUECFG"]}    ${ue_alias}=Spark_UE
    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config_direction}    ue_alias=${ue_alias}
    MultiUE Start UDP Traffic    ul_tp_list=${ul_tp_list}    if_ul=${if_ul}    if_dl=${if_dl}    process=${process}
    ...    ul_duration=${duration}    buffer=${buffer}    ue_alias=${ue_alias}
    Run Keyword If    ${need_spark_log}    Start Spark TP Log    ue_alias=${ue_alias}
    sleep    20s
    Run Keyword If    ${need_spark_log}    Stop Spark TP Log    ue_alias=${ue_alias}
    [Teardown]    Stop Traffic And Detach UE    if_ul=${if_ul}    if_dl=${if_dl}    ue_alias=${ue_alias}

Change The parameter of UE
    [Arguments]    ${new_ue_dict}    ${org_UE_dict}=${PC1_TLCommonConfig['MultiUECFG']}
    ${ue_index_list}    get dictionary keys    ${new_ue_dict}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${new_value_dict}    get from dictionary    ${new_ue_dict}    ${ue_index}
        ${org_dict}    Change Dictionary Value    new_value_dict=${new_value_dict}    org_dict=${org_UE_dict['${ue_index}']}
        set to dictionary    ${org_UE_dict}    ${ue_index}=${org_dict}
    END
    set to dictionary    ${org_UE_dict}    ue_index_for_call=${ue_index_list}
    [Return]    ${org_UE_dict}

Change Dictionary Value
    [Arguments]    ${new_value_dict}    ${org_dict}
    ${new_keys}    get dictionary keys    ${new_value_dict}
    FOR  ${key}  IN  @{new_keys}
        ${value}    get from dictionary    ${new_value_dict}    ${key}
        set to dictionary    ${org_dict}    ${key}=${value}
    END
    [Return]    ${org_dict}

###### Adjust PA #########
Adjust the HBTE attenuation value
    [Arguments]      ${value_list}    ${port_list}    ${model}=${tl.attenuator.model}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    model=${model}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${port_list}[${i}]    value=${value_list}[${i}]
        ${value_port}    att.read_attenuation    port=${port_list}[${i}]
        should be equal    ${value_port}    ${value_list}[${i}]
    END
    sleep  10s

Adjust Multiple HBTE attenuation value
    ${port_list}    create list     ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}
    ...    ${9}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}
    ${value_list}    create list    ${127}    ${127}    ${0}    ${0}    ${127}    ${127}    ${127}    ${127}
    ...    ${10}    ${4.5}    ${4.5}    ${127}    ${10}    ${4.5}    ${4.5}    ${127}
    CB010636_common_keyword.Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}
    sleep    5s

###### Case Step #########
CB010636 Suite Setup
#    robot_common_operations.Common Suite Setup
#    CI_interface.Common Suite Setup
    mmw4_coam_cloud_gnb.Set Default Scf
    Adjust Multiple HBTE attenuation value
#    CU Full Commssion By Rest    path_of_commission_file=${CURDIR_path}/gnb0/cu/${default_cu_scf}
#    vDU Full Commssion By Rest    scf_path=${CURDIR_path}/gnb0/dus_0/${default_du_scf}
    Wait Until Keyword Succeeds    3min   30s    Check vDU And CU On Air    if_X2_check=${True}
    Update RAD Debug Parameter    para_list=${L2Lo_RAD_para}    domain_name=L2LO
    Update RAD Debug Parameter    para_list=${L2HiDU_RAD_para}    domain_name=L2HIDU
    ${tti_dec_path}    Wait Until Keyword Succeeds    3x    3min    Download TTI Decoder Tool
    Run    pip3 install pandas --proxy=http://10.144.1.10:8080

CB010636 Suite Teardown
    robot_common_operations.Common Suite Teardown

Case7 Teardown
    VDU Online Change Parameters Activate    updated_paras_list=${case7_du_para_re}
    CU Online Change Parameters Activate    updated_paras_list=${case7_cu_para_recover}

Case common Teardown
    Run keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log For Cloud    gnb_index=${0}    ru_serial_list=${RU_lmi_sn_list}
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Collect vdu snapshot
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Collect cu snapshot
    CI_interface.Common Case Teardown
    robot_common_operations.Common case Teardown

Check DL TP And Bler From Spark Log
    [Arguments]    ${expect_tp}    ${expect_bler}    ${file_path}=${OUTPUT_DIR}/${TEST NAME}/UE-2.csv    ${row_list}=${case_row_list}
    ${DL_avg_tp}    ${DL_avg_bler}    Get_UE_TP_Bler_From_spark_log    file_path=${file_path}    row_list=${row_list}
    Run Keyword And Continue On Failure    Should Be True    ${DL_avg_tp}>${expect_tp}
    Run Keyword And Continue On Failure    Should Be True    ${DL_avg_bler}<${expect_bler}

VDU IPv6 Number Should Be Expected
    [Arguments]    ${expected_ipv6_num}=${0}
    [Documentation]     This Keyword is to get RU IP from vDU oamfh container
    ${ip}    Set Variable   ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ${username}  Set Variable  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ${password}  Set Variable  ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${ns}    Set Variable    ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace}

    csn.Connect To    hostname=${ip}    username=${username}    password=${password}    alias=vdu_master
    ${command}  Set Variable    oc exec -it po-oamfh-0 -c ctr-oamfh -- cat /ffs/run/config/FRIps.txt
    ${output}=    csn.Execute    ${command}    connection=vdu_master
    Log To Console    "RU Ip is: ${output}"
    # /MRBTS-1/RAT-1/BTS_L-21/EQM_L-1/BBMOD_L-1/BOARD_L-1/POWER_GROUP_L-1/SOC_L-1/CONCENTRATOR_L-1;
    # 1;fd5f:4268:2387:87c1:0000:0000:0000:001a;1M250300173;AVHQA
    # /MRBTS-1/RAT-1/BTS_L-21/EQM_L-1/BBMOD_L-1/BOARD_L-1/POWER_GROUP_L-1/SOC_L-1/CONCENTRATOR_L-1;3;
    # fd5f:4268:2387:87c1:0000:0000:0000:0012;1M250310868;AWHHJ
    ${ipv6_grep}    Set Variable    oc exec -it po-oamfh-0 -c ctr-oamfh -- cat /ffs/run/config/FRIps.txt | grep "fd5f" -c
    ${ipv6_cnt}=    csn.Execute    ${ipv6_grep}    connection=vdu_master
    Log To Console    "IPv6 count is: ${ipv6_cnt}"
    Should Be Equal As Integers    ${ipv6_cnt}    ${expected_ipv6_num}
    [Teardown]    Run Keyword And Ignore Error    csn.Disconnect    connection=vdu_master