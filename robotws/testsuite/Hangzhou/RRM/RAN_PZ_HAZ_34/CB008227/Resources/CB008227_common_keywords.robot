*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB008227

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Library      ./CB008227_traffic.py
Variables    ./CB008227_Variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${ue_type}           ${tl.ues[0].capabilities[0]}
${gnb_instance}    ${tl.gnbs[0].instance_id}
${gnb1_instance}    ${tl.gnbs[1].instance_id}
@{gnb_id}    37611    38811
@{gnb_ips}    ${bts_host0}
@{gnb_list}    ${0}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${WEBUI_host0}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_host1}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${att_port_1_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[12]}
${att_port_1_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_enb_cell_37611}                  ${tl.attenuator[2].attenuator_ports[9]}
${att_ipaddr_gnb1_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_37611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_enb_cell_37611}                  ${tl.attenuator[2].ip_addr}

${att_port_1_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_gnb2_cell2_37611_UE2}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb2_cell2_37611_UE2}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb2_cell2_37611_UE2}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb2_cell2_37611_UE2}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[13]}
${att_port_2_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[14]}
${att_port_3_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[15]}
${att_port_4_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].attenuator_ports[16]}
${att_port_1_enb_cell_37611_UE2}                  ${tl.attenuator[2].attenuator_ports[10]}
${att_ipaddr_gnb1_cell1_37611_UE2}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell2_37611_UE2}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37611_UE2}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_enb_cell_37611_UE2}                  ${tl.attenuator[2].ip_addr}

${att_port_1_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_38811}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_38811}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_38811}                ${tl.attenuator[0].ip_addr}
${att_port_1_enb_cell_38811}                ${tl.attenuator[0].attenuator_ports[11]}
${att_ipaddr_enb_cell_38811}                ${tl.attenuator[0].ip_addr}

${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${34411_att_port_1}                 ${tl.attenuator[0].attenuator_ports[1]}
${34411_att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${34411_att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${34411_att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${34411_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${34411_att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${34411_att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${34411_att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${34411_att_port_9}                ${tl.attenuator[0].attenuator_ports[9]}
${34411_att_port_10}                ${tl.attenuator[0].attenuator_ports[10]}
${34411_att_port_11}                ${tl.attenuator[0].attenuator_ports[11]}
${34411_att_port_12}                ${tl.attenuator[0].attenuator_ports[12]}
${34411_att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${34411_att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${34411_att_port_15}                ${tl.attenuator[0].attenuator_ports[15]}

${att_port_1_gnb1_cell1_356111}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_356111}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_356111}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_356111}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_enb_cell_356111}                  ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_enb_cell_356111}                  ${tl.attenuator[0].attenuator_ports[6]}
${att_ipaddr_gnb1_cell1_356111}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_enb_cell_356111}                  ${tl.attenuator[0].ip_addr}

${mdrb_apn_name}    ${tl.ues[0].pdn[2]}
${dxdata2_apn_name}    ${tl.ues[0].pdn[0]}
@{ue_index_list}    ${0}    ${0}
@{ue_index_iperf}    ${-1}    ${-1}
${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"(ngap or e1ap or f1ap or xnap or s1ap or x2ap)\"  -T pdml
@{branch}    SBTS25R2_ENB_9999    SBTS24R2_ENB_0000    SBTS24R3_ENB_0000

#${TS_LOG_PATH_BASE_cloud}    /home/ute/workspace/CRT/Master/Case_Logs/
#${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
#${ute_log_path_cloud}    /home/ute/test_results/
#${tl_scf_dir_path_cloud}    /home/ute/Auto5G/commissionings/HGZ/
${testline_name}      null
${CONFIGURATION}      null
${enb_instance}    ${tl.enbs[0].instance_id}

${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
@{allow_fault_list}    7311    7107    7523    4681
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/


*** Keywords ***
Load SCF with different release
    ${release}=    Get sagnb release title
    Prepare with COAM classical two BTS cell onair    scf_filename1=${tl_scf_filename1}_${release}.xml
    ...    scf_filename2=${tl_scf_filename2}_${release}.xml

Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${Delete_Para_Online}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    Delete_Para_Online=${Delete_Para_Online}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Online modify nsaDrbParam to dlOverF1U
    [Arguments]    ${gnb_index}=${0}    ${Delete_Para_Online}=${PARAMETERS_TO_DELETE_GNB${${gnb_index}+${1}}_nsaDrbParam}
    ...    ${Add_Para_Online}=${PARAMETERS_TO_ONLINE_ADD_GNB${${gnb_index}+${1}}_nsaDrbParam}
    Online modify NIDD on gnb    gnb_index=${gnb_index}
    ...    Delete_Para_Online=${Delete_Para_Online}    Add_Para_Online=${Add_Para_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Case Teardown
    [Arguments]    ${gnb_list}=${gnb_list}    ${gnb_ips}=${gnb_ips}
    ...    ${ute_log_path}=${epc_log_path}
    Common Case Teardown for COAM    gnb_list=${gnb_list}
    Check hanging resource for gnb    gnb_ips=@{gnb_ips}    ute_log_path=${ute_log_path}

##8227##
Check beare value should be true
    [Arguments]    ${file_name}    ${value_min}    ${value_max}
    ${value_list}    ${average}    check beare value    file_name=${epc_log_path}${file_name}
    ${value_length}    Get Length    ${value_list}
    should be true    ${value_length}>${25}
    Should Be True    ${value_min}<=${average}<=${value_max}
    [Return]    ${average}

Start Traffic And Download the listened traffic
    [Arguments]    ${file_name_DL}=NULL    ${file_name_UL}=NULL    ${dl_ports}=NULL    ${ul_ports}=NULL    ${cap_index}=${0}
    ...    ${dl_throughput}=NULL   ${ul_throughput}=NULL    ${ue_index_list}=${ue_index_list}    ${ue_index_iperf}=${ue_index_iperf}
    ...    ${ue_index}=${0}    ${capabilities}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ###listen and start DL traffic
    Run keyword If    '${dl_throughput}'!='NULL'
    ...    Listened And Start DL Traffic    file_name=${file_name_DL}    dl_ports=${dl_ports}
    ...    dl_throughput=${dl_throughput}    ue_index_list=${ue_index_list}    cap_index=${cap_index}    ue_index=${ue_index}
    ...    capabilities=${capabilities}
    ##listen and start UL traffic
    Run keyword If    '${ul_throughput}'!='NULL'
    ...    Listened And Start UL Traffic    file_name=${file_name_UL}    ul_ports=${ul_ports}
    ...    ul_throughput=${ul_throughput}    ue_index_list=${ue_index_list}
    [Teardown]    Stop DL/UL traffic    dl_ports=${dl_ports}    ul_ports=${ul_ports}
    ...    ue_index_DL=${ue_index_list}    ue_index_UL=${ue_index_iperf}

Listened And Start DL Traffic
    [Arguments]    ${file_name}    ${dl_ports}    ${dl_throughput}=${dl_throughput}    ${ue_index_list}=${ue_index_list}
    ...    ${cap_index}=${0}    ${ue_index}=${0}    ${capabilities}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ${serial_numbers}    Create List
    ${UE_IPS}    Create List
    FOR    ${index}    IN    @{ue_index_list}
        Append To List    ${serial_numbers}    ${tl.ues[${index}].serial_number}
        Get Commercial UE IP    ue_index=${index}    cap_index=${cap_index}    capabilities=${capabilities}
        Append To List    ${UE_IPS}    ${UE_IP}
    END
    operate_all_bearer_of_tput_traffic_threading_via_appserver
    ...    ue_ips=${UE_IPS}    dl_ports=${dl_ports}    traffic=${dl_throughput}
    sleep    10s
    operate_all_bearer_of_tput_listen_threading_via_cpc    filename=${file_name}
    ...    dl_ports=${dl_ports}    serial_numbers=${serial_numbers}    ue_index=${ue_index}
    sleep    40s
    FOR    ${index}    ${port}    IN ENUMERATE   @{dl_ports}
        Download DL Traffic File    file_name=${file_name}_${port}.txt    ue_index=${ue_index_list[${index}]}
    END

Listened And Start UL Traffic
    [Arguments]    ${file_name}    ${ul_ports}    ${ul_throughput}=${ul_throughput}    ${ue_index_list}=${ue_index_list}
    ${serial_numbers}    Create List
    FOR    ${index}    IN    @{ue_index_list}
        Append To List    ${serial_numbers}    ${tl.ues[${index}].serial_number}
    END
    operate_all_bearer_of_tput_traffic_threading_via_cpc
    ...    serial_numbers=${serial_numbers}    ul_ports=${ul_ports}    traffic=${ul_throughput}
    sleep    10s
    operate_all_bearer_of_tput_listen_threading_via_appserver    filename=${file_name}    ul_ports=${ul_ports}
    sleep    40s
    Download UL Traffic File    file_name=${file_name}_${ul_ports[0]}.txt
    Download UL Traffic File    file_name=${file_name}_${ul_ports[1]}.txt

##UE##
Set APN point for sanmsungS22
    Set Suite Variable    ${apn_muiltdrb}    101 626
    Set Suite Variable    ${apn_dxdata}    101 419
    Set Suite Variable    ${location_apn}    380 1060

Set APN point for sanmsungS22 TL356
    Set Suite Variable    ${apn_muiltdrb}    93 586
    Set Suite Variable    ${apn_wap2}    93 394
    Set Suite Variable    ${location_apn}    233 983

Set APN point for sanmsung
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${0}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Set APN point for sanmsung until succeed
    [Arguments]    ${apn_name}=${mdrb_apn_name}    ${ui_version}=one ui 5.1    ${ue_index}=${0}    ${ue_type}=${ue_type}
    ...    ${enb_cell_value}=${0}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell_value=${enb_cell_value}
    ${result}    Run keyword and return status    Wait until keyword succeeds    1X    10s
    ...    Set APN point for sanmsung    ue_index=${0}    ue_type=${ue_type}    apn_name=${apn_name}    ui_version=${ui_version}
    Run keyword If    '${result}'=='False'    Run keywords    Before test reset QCOM use adb command    ue_index=${ue_index}
    ...    AND    Set APN point for sanmsung    ue_index=${0}    ue_type=${ue_type}    apn_name=${apn_name}    ui_version=${ui_version}
    ...    ELSE    Log To Console    ***No need reboot UE***
    Log To Console    ***Set APN OK***
    Adjust gNB_RU Attenuation

Set APN point for sanmsung22 until succeed
    [Arguments]    ${usedapn}=${apn_muiltdrb}    ${enb_cell_value}=${127}
    Adjust gNB_RU Attenuation    gnb1_cell1_value=${0}    enb_cell_value=${enb_cell_value}
    set apn with special method    usedapn=${usedapn}    location_apn=${location_apn}
    Log To Console    ***Set APN OK***
    Adjust gNB_RU Attenuation

Download DL Traffic File
    [Arguments]     ${file_name}    ${ue_index}=${0}
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=cygwin
    csn.download_file   remote_path=/tmp/${file_name}   local_path=${epc_log_path}${file_name}
    ...    connection=cygwin
    sleep    3s
    [Teardown]    csn.disconnect      connection=cygwin

Download UL Traffic File
    [Arguments]     ${file_name}
    Connect to EPC APP    ue_index=${-1}
    csn.download_file   remote_path=/tmp/${file_name}   local_path=${epc_log_path}${file_name}
    ...    connection=EPCAPP
    sleep    3s
    [Teardown]    csn.disconnect      connection=EPCAPP

2UEs attach and check
    [Arguments]     ${4G_check}=False    ${gnb_index}=${0}
    Attach and check power UE    ue_type=${ue_type}    4G_check=${4G_check}    ue_index=${0}    gnb_index=${gnb_index}
    Attach and check power UE    ue_type=${ue_type}    4G_check=${4G_check}   ue_index=${1}    gnb_index=${gnb_index}

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

End a call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    should contain    ${result}    mCallState=${status}
    [Teardown]    csn.disconnect      connection=cpc_${ue_index}

Stop DL/UL traffic
    [Arguments]    ${ue_index_DL}=NULL    ${ue_index_UL}=NULL   ${dl_ports}=NULL    ${ul_ports}=NULL
    Run keyword if    '${ul_ports}'!='NULL'    Stop All port traffic    ue_index=${ue_index_DL}    direction=ul
    ...    port_list=${ul_ports}
    Run keyword if    '${dl_ports}'!='NULL'    Stop All port traffic    ue_index=${ue_index_UL}   direction=dl
    ...    port_list=${dl_ports}

Stop All port traffic
    [Arguments]    ${port_list}    ${ue_index}    ${direction}=dl
    ${port_length}    Get Length    ${port_list}
    FOR    ${index}    IN RANGE    ${port_length}
        power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index[${index}]}
        ...    iperf_port=${port_list[${index}]}    iperf_type=via_command
    END

##PA##
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${gnb1_cell1_value}=${127}    ${gnb2_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${enb_cell_value}=${127}    ${gnb1_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[1]}'
    ...    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}
    @{att_ports_enb_cell}    Create List    ${att_port_1_enb_cell_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[1]}'
    ...    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_enb_cell}    Create List    ${enb_cell_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[1]}'
    ...    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell}    values=${values_enb_cell}
    ...    att_connection_port=${att_port_1_enb_cell_${tl}}    att_ipaddr=${att_ipaddr_enb_cell_${tl}}


Adjust gNB_RU Attenuation for 2UEs on TL34411
    [Arguments]     ${tl}=34411    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ...    ${gnb2_cell2_value}=${127}    ${enb_cell1_value}=${127}    ${enb_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${${tl}_att_port_1}    ${${tl}_att_port_2}
    @{att_ports_gnb1_cell2}    Create List    ${${tl}_att_port_3}    ${${tl}_att_port_4}
    @{att_ports_gnb2_cell1}    Create List    ${${tl}_att_port_5}    ${${tl}_att_port_6}
    ...    ${${tl}_att_port_7}    ${${tl}_att_port_8}
    @{att_ports_gnb2_cell2}    Create List    ${${tl}_att_port_9}    ${${tl}_att_port_10}
    ...    ${${tl}_att_port_11}    ${${tl}_att_port_12}
    @{att_ports_enb_cell1}    Create List    ${${tl}_att_port_13}
    @{att_ports_enb_cell2}    Create List    ${${tl}_att_port_14}     ${${tl}_att_port_15}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_enb_cell1}    Create List    ${enb_cell1_value}
    @{values_enb_cell2}    Create List    ${enb_cell2_value}    ${enb_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell1}    values=${values_enb_cell1}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb_cell2}    values=${values_enb_cell2}
    ...    att_connection_port=${${tl}_att_port_1}    att_ipaddr=${att_ipaddr}

Adjust gNB_RU Attenuation TL356
    [Arguments]     ${tl}=${gnb_instance}    ${gnb1_cell1_value}=${127}    ${enb_cell_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_enb_cell}    Create List    ${att_port_1_enb_cell_${tl}}    ${att_port_2_enb_cell_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_enb_cell}    Create List    ${enb_cell_value}    ${enb_cell_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_enb_cell}    values=${values_enb_cell}
    ...    att_connection_port=${att_port_1_enb_cell_${tl}}    att_ipaddr=${att_ipaddr_enb_cell_${tl}}

Check intergNB HO process on source gNB
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    (xnap.procedureCode == 0 and ip.src == ${asik_addr} and xnap.XnAP_PDU == 0)
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    (xnap.procedureCode == 0 and ip.dst == ${asik_addr} and xnap.XnAP_PDU == 1)
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode     pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    (xnap.procedureCode == 6 and ip.dst == ${asik_addr})
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel_filter}=     Catenate     (xnap.procedureCode == 2 and xnap.XnAP_PDU == 0)
    ${HO_Cancel_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_Cancel_filter}    pcap_parser=test6
    ${HO_Cancel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel_filter}=     Catenate    (f1ap.procedureCode == 6 and f1ap.radioNetwork == 10)
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_rel_filter}    pcap_parser=test6
    ${UE_Cont_rel}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC_filter}=     Catenate     (f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1)
    ${UE_Cont_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_Cont_relC_filter}    pcap_parser=test6
    ${UE_Cont_relC}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU    pcap_parser=test6
    should contain    ${UE_Cont_relC}    1

Check intergNB HO process on target gNB
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}    ${asik2_addr}=${asik2_addr}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req_filter}=     Catenate    (xnap.procedureCode == 0 and ip.src == ${asik_addr} and xnap.XnAP_PDU == 0)
    ${HO_req_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_filter}    pcap_parser=test6
    ${HO_req}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK_filter}=     Catenate    (xnap.procedureCode == 0 and ip.dst == ${asik_addr} and xnap.XnAP_PDU == 1)
    ${HO_req_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${HO_req_ACK_filter}    pcap_parser=test6
    ${HO_req_ACK}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req_filter}=     Catenate    (ngap.procedureCode == 25 and ip.src == ${asik2_addr})
    ${PathS_req_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_req_filter}    pcap_parser=test6
    ${PathS_req}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode    pcap_parser=test6
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK_filter}=     Catenate    (ngap.procedureCode == 25 and ip.dst == ${asik2_addr})
    ${PathS_ACK_packets}=    cap.filter_packets_by_expression    filter_expression=${PathS_ACK_filter}    pcap_parser=test6
    ${PathS_ACK}=     cap.get_field_value_by_xpath    xpath=.//ngap.procedureCode     pcap_parser=test6
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel_filter}=     Catenate    (xnap.procedureCode == 6 and ip.dst == ${asik_addr})
    ${UE_rel_packets}=    cap.filter_packets_by_expression    filter_expression=${UE_rel_filter}    pcap_parser=test6
    ${UE_rel}=     cap.get_field_value_by_xpath    xpath=.//xnap.procedureCode    pcap_parser=test6
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq_filter}=     Catenate    (ngap.procedureCode == 42 and ngap.radioNetwork == 0)
    ${UE_contextreleasereq_packets}=    cap.Filter Packets By Expression    filter_expression=${UE_contextreleasereq_filter}    pcap_parser=test6
    ${UE_contextreleasereq}=     cap.Get Field Value By Xpath    xpath=.//ngap.radioNetwork    pcap_parser=test6
    should not contain    ${UE_contextreleasereq}    0

Check intergNB HO NSA process on source gNB
    [Arguments]    ${logname}    ${gnb_ID}=${gnb1_instance}    ${asik_addr}=${asik_addr}
    ${physCellId_cell1}=    get required cell info   required_info=physicalCellId    cell_index=${1}   gnb_index=${0}
    ${physCellId_cell2}=    get required cell info   required_info=physicalCellId    cell_index=${2}   gnb_index=${1}
    ${physCellId_cell1}    Convert to String    ${physCellId_cell1}
    ${physCellId_cell2}    Convert to String    ${physCellId_cell2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    Measurement Report
    ${Measurement_filter}=     Catenate    (x2ap.procedureCode == 35 and nr-rrc.physCellId)
    ${Measurement_packets}=    cap.filter_packets_by_expression    filter_expression=${Measurement_filter}    pcap_parser=test6
    ${physCellId_list}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    List Should Contain Value    ${physCellId_list}    ${physCellId_cell1}
    List Should Contain Value    ${physCellId_list}    ${physCellId_cell2}
    Log To Console    SgNBChangeRequired, RRC Reconfiguration
    ${Required_filter}=     Catenate    (x2ap.procedureCode == 34 and x2ap.gNB_ID)
    ${Required_packets}=    cap.filter_packets_by_expression    filter_expression=${Required_filter}    pcap_parser=test6
    ${x2ap_gNB_ID}=     cap.get_field_value_by_xpath    attribute_name=showname    xpath=.//x2ap.gNB_ID   pcap_parser=test6
    ${result_Hex}=    Split String    ${x2ap_gNB_ID[1]}    value
    ${result_Hex}=    Strip String    ${result_Hex[-1]}
    ${result_Hex}=    Remove String    ${result_Hex}    ]
    ${result_Hex}    Convert To Integer    ${result_Hex}
    should be equal    ${result_Hex}    ${gnb_ID}
    Log To Console    SgNBChangeConfirm
    ${Confirm_filter}=     Catenate    (x2ap.procedureCode == 34 and x2ap.X2AP_PDU == 1)
    ${Confirm_packets}=    cap.filter_packets_by_expression    filter_expression=${Confirm_filter}    pcap_parser=test6
    ${x2ap_PDU}=     cap.get_field_value_by_xpath    xpath=.//x2ap.X2AP_PDU   pcap_parser=test6
    should be equal     ${x2ap_PDU[0]}    1
    Log To Console    SNStatusTransfer
    ${SNStatusTransfer_filter}=     Catenate    (x2ap.procedureCode == 4 and ip.src == ${asik_addr})
    ${SNStatusTransfer_packets}=    cap.filter_packets_by_expression    filter_expression=${SNStatusTransfer_filter}    pcap_parser=test6
    ${procedureCode}=     cap.get_field_value_by_xpath    xpath=.//x2ap.procedureCode   pcap_parser=test6
    should be equal     ${procedureCode[0]}    4
    Log To Console    UEContextRelease
    ${Release_filter}=     Catenate    (x2ap.procedureCode == 5)
    ${Release_packets}=    cap.filter_packets_by_expression    filter_expression=${Release_filter}    pcap_parser=test6
    ${procedureCode}=     cap.get_field_value_by_xpath    xpath=.//x2ap.procedureCode   pcap_parser=test6
    should be equal     ${procedureCode[0]}    5
    Log To Console    UEContextReleaseCommand
    ${ReleaseCommand_filter}=     Catenate    (f1ap.procedureCode == 6 and f1ap.radioNetwork == 7)
    ${ReleaseCommand_packets}=    cap.filter_packets_by_expression    filter_expression=${ReleaseCommand_filter}    pcap_parser=test6
    ${radioNetwork}=     cap.get_field_value_by_xpath    xpath=.//f1ap.radioNetwork   pcap_parser=test6
    should be equal     ${radioNetwork[0]}    7
    Log To Console    UEContextReleaseComplete
    ${ReleaseComplete_filter}=     Catenate    (f1ap.procedureCode == 6 and f1ap.F1AP_PDU == 1)
    ${ReleaseComplete_packets}=    cap.filter_packets_by_expression    filter_expression=${ReleaseComplete_filter}    pcap_parser=test6
    ${F1AP_PDU}=     cap.get_field_value_by_xpath    xpath=.//f1ap.F1AP_PDU   pcap_parser=test6
    should be equal     ${F1AP_PDU[0]}    1

Check intergNB HO NSA process on target gNB
    [Arguments]    ${logname}    ${asik_addr}=${asik2_addr}
    ${physCellId_cell1}=    get required cell info   required_info=physicalCellId    cell_index=${1}   gnb_index=${0}
    ${physCellId_cell2}=    get required cell info   required_info=physicalCellId    cell_index=${2}   gnb_index=${1}
    ${physCellId_cell1}    Convert to String    ${physCellId_cell1}
    ${physCellId_cell2}    Convert to String    ${physCellId_cell2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    SgNBAdditionRequest
    ${Request_filter}=     Catenate    (x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 0)
    ${Request_packets}=    cap.filter_packets_by_expression    filter_expression=${Request_filter}    pcap_parser=test6
    ${physCellId_list}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId   pcap_parser=test6
    List Should Contain Value    ${physCellId_list}    ${physCellId_cell1}
    List Should Contain Value    ${physCellId_list}    ${physCellId_cell2}
    Log To Console    SgNBAdditionRequestAcknowledge
    ${Acknowledge_filter}=     Catenate    (x2ap.procedureCode == 27 and x2ap.X2AP_PDU == 1)
    ${Acknowledge_packets}=    cap.filter_packets_by_expression    filter_expression=${Acknowledge_filter}    pcap_parser=test6
    ${physCellId}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId   pcap_parser=test6
    should be equal    ${physCellId[0]}    ${physCellId_cell2}
    Log To Console    SNStatusTransfer
    ${SNStatusTransfer_filter}=     Catenate    (x2ap.procedureCode == 4 and ip.dst == ${asik_addr})
    ${SNStatusTransfer_packets}=    cap.filter_packets_by_expression    filter_expression=${SNStatusTransfer_filter}    pcap_parser=test6
    ${procedureCode}=     cap.get_field_value_by_xpath    xpath=.//x2ap.procedureCode   pcap_parser=test6
    should be equal     ${procedureCode[0]}    4
    Log To Console    Uecontextmodificationresponse
    ${response_filter}=     Catenate    (f1ap.procedureCode == 7 and nr-rrc.physCellId)
    ${Response_packets}=    cap.filter_packets_by_expression    filter_expression=${response_filter}    pcap_parser=test6
    ${physCellId_list}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId   pcap_parser=test6
    should be equal     ${physCellId_list[0]}    ${physCellId_cell2}

Check wireshark log for CA attach OK
    [Arguments]    ${logname}    ${cell1_index}=${1}    ${cell2_index}=${2}    ${gnb_index1}=${0}    ${gnb_index2}=${1}
    ${physCellId_cell1}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${cell1_index}   gnb_index=${gnb_index1}
    ${physCellId_cell2}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${cell2_index}   gnb_index=${gnb_index2}
    ${physCellId_cell1}    Convert to String    ${physCellId_cell1}
    ${physCellId_cell2}    Convert to String    ${physCellId_cell2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    Log To Console    UEContextModificationResponse has scell
    ${physCellId_filter}=     Catenate    (f1ap.procedureCode == 7 and f1ap.F1AP_PDU == 1 and nr-rrc.physCellId)
    ${physCellId_packets}=    cap.filter_packets_by_expression    filter_expression=${physCellId_filter}    pcap_parser=test6
    ${physCellId_list}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.physCellId    pcap_parser=test6
    List Should Contain Value    ${physCellId_list}    ${physCellId_cell1}
    List Should Contain Value    ${physCellId_list}    ${physCellId_cell2}

Make a VoNR call(+6688) samsung
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call samsung
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Check NBR Congetion Counter
    [Arguments]    ${value_1}    ${value_Average}    ${gnb_index}=${0}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    sleep    40s
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${counter_dic_path}
    Run keyword If    ${value_1}!=${0}    Should be True    ${${value_1}-${2}}<=${counter_list[0]}<=${${value_1}+${4}}
    ...    ELSE    Should be True    ${counter_list[0]}==${value_1}
    Should be Equal    ${counter_list[1]}    ${0}
    Should be True    ${298}<=${counter_list[2]}<=${302}
    ${counter_KPI}    Evaluate    ${counter_list[0]}/${counter_list[2]}
    ${value_max}    Evaluate    ${value_Average}+${1.0}
    Run keyword If    ${value_Average}!=${0}    should be true    ${value_Average}<=${counter_KPI}<${value_max}
    ...    ELSE    Should be True    ${value_Average}==${value_Average}

Check NBR Congetion Counter for A11B05_EA01
    [Arguments]    ${value_1}    ${value_Average}=${1}    ${gnb_index}=${0}    ${value_min}=${0.966666667}    ${value_max}=${1.034}
    ...    ${counter_id}=${counter_id_D01_gNB1}    ${counter_dic_path}=${counter_dic_path_D01_gNB1}
    sleep    40s
    ${counter_list}=    Get the PM counter
    ...    gnb_index=${gnb_index}    counter_id=${counter_id}    dic_path=${counter_dic_path}
    Run keyword If    ${value_1}!=${0}    Should be True    ${290}<=${counter_list[0]}<=${310}
    ...    ELSE    Should be True    ${counter_list[0]}==${value_1}
    Should be Equal    ${counter_list[1]}    ${0}
    Should be True    ${298}<=${counter_list[2]}<=${302}
    ${counter_KPI}    Evaluate    ${counter_list[0]}/${counter_list[2]}
#    ${value_max}    Evaluate    ${value_Average}+${1.0}
    Run keyword If    ${value_Average}!=${0}    should be true    ${value_min}<=${counter_KPI}<${value_max}
    ...    ELSE    Should be True    ${value_Average}==${value_Average}

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

###UTE Cloud
Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_pattern}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME_pattern}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    Default directory for ute cloud

#Default directory for ute cloud
#    [Documentation]    Author: Ren Biyao
#    ...     Description: default dir scf and swconfig and log dir for ute cloud.
#    ${cur_dir}    run    pwd
#    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
#    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
#    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
#    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_cloud}
#    Set Suite Variable    ${ute_log_path}    ${ute_log_path_cloud}
#    Set Suite Variable    ${epc_log_path}    ${ute_log_path_cloud}
#    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
#    Common Suite Setup for COAM

Default directory for ute cloud
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min    ${response_timeout}=10
    ${cur_dir}    run    pwd
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua

    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    Run keyword if    ${has_cbts}   wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds    ${timeout}    2sec    Connect to gnb coam via ssl
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM    timeout=${response_timeout}
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    set suite variable    ${epc_log_path}    ${SUITE_LOG_PATH}
    set suite variable    ${TS_LOG_PATH_BASE}     ${SUITE_LOG_PATH}
    Set Suite Variable    ${ute_log_path}    ${SUITE_LOG_PATH}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/

    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=True     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=1
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.75      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}