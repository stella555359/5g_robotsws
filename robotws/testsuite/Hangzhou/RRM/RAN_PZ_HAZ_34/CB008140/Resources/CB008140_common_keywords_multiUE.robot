*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03
...    feature : CB008140

Library     DateTime
Library     taf.analyzer.pcap    WITH NAME    cap
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.hw.rf_attenuator    WITH NAME    atten
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Library    testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.CB008140.Resources.MTU_Power.SigSpark   WITH NAME    MTU_spark
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput
Library     taf.selenium.sbts    WITH NAME    selenium_coam
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
${ue_type}           ${tl.ues[0].capabilities[0]}
${tl_scf_dir_path}    /opt/workspace/SCF/
${tl_scf_gnb0}    Configuration_scf_GNB1_CB008140_peak.xml
${tl_scf_gnb2}    Configuration_scf_GNB3_CB008140_peak.xml
${tl_scf_gnb3}    Configuration_scf_GNB4_CB008140_peak.xml
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${bts_host2}    ${tl.gnbs[2].cu.oam_http_connection_details.addr}
${bts_host3}    ${tl.gnbs[3].cu.oam_http_connection_details.addr}
${bts_host4}    ${tl.gnbs[4].cu.oam_http_connection_details.addr}
${WEBUI_host0}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_host1}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_host2}    https://${tl.gnbs[2].cu.oam_http_connection_details.addr}
${WEBUI_host3}    https://${tl.gnbs[3].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${xnap_gnb1}    ${tl.gnbs[0].dus[0].f1_c_ip_addr}
${xnap_gnb2}    ${tl.gnbs[1].dus[0].f1_c_ip_addr}
${xnap_gnb3}    ${tl.gnbs[2].dus[0].f1_c_ip_addr}
${xnap_gnb4}    ${tl.gnbs[3].dus[0].f1_c_ip_addr}
${xpu_gnb1}    ${tl.gnbs[0].dus[0].f1_u_ip_addr}
${xpu_gnb2}    ${tl.gnbs[1].dus[0].f1_u_ip_addr}
${xpu_gnb3}    ${tl.gnbs[2].dus[0].f1_u_ip_addr}
${xpu_gnb4}    ${tl.gnbs[3].dus[0].f1_u_ip_addr}
@{xnap_gnb}    ${xnap_gnb1}    ${xnap_gnb3}
${gnb_index}    ${0}
${gnb2_index}    ${1}
${tshark_path}      /usr/bin/tshark
${gnb_instance0}    ${tl.gnbs[0].instance_id}
${gnb_instance1}    ${tl.gnbs[1].instance_id}
${gnb_instance2}    ${tl.gnbs[2].instance_id}
${gnb_instance3}    ${tl.gnbs[3].instance_id}
${enb_instance}    ${tl.enbs[0].instance_id}
${index}    ${0}
@{gnb_id}    38511    38611    38711
${att_port_1_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38611}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_38611}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell3_38611}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb2_cell2_38611}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb1_cell2_38611}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb2_cell3_38611}                ${tl.attenuator[0].attenuator_ports[12]}

${att_ipaddr_gnb1_cell1_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell1_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell3_38611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_38611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb1_cell2_38611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell3_38611}                ${tl.attenuator[1].ip_addr}

${att_port_1_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38711}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb1_cell2_38711}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell3_38711}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb2_cell1_38711}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb2_cell2_38711}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb2_cell3_38711}                ${tl.attenuator[1].attenuator_ports[12]}

${att_ipaddr_gnb1_cell1_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell3_38711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell1_38711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell2_38711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell3_38711}                ${tl.attenuator[1].ip_addr}


@{gnb_ips}    ${bts_host0}    ${bts_host1}
@{gnb_list}    ${0}    ${1}
@{ue_list}    ${7}
@{scell_index_list}    ${2}
@{extgnb_index_list}    ${2}
${traffic_duration}    360
${Send_Tput_DL}    2000M
${Send_Tput_UL}    100M
${Send_Tput_DL_DRB7}    500M
${Send_Tput_DL_DRB9}    500M
${DL_PORT}        ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT_387}        ${tl.ues[0].iperf_details.port}
@{numberOfActiveUlUEs_value}    0    0
${expected_tput_ul}    NULL
${expected_tput_dl_T}    NULL

${protocol_TCP}    tcp
${protocol_UDP}    udp
${seg_size}    1180
${process_num_DL}    10
${process_num_UL}    2

${get_spark_license_38611}    True
${get_spark_license_38711}    False
${get_spark_license_36311}    False
${get_spark_license_357}    False
${ue_index_38611}    ${1}
${ue_index_38711}    ${7}
${ue_index_38511}    ${1}
${ue_index_hanningresource_38711}    ${8}
${ue_index_hanningresource_38611}    ${4}
${ue_index_hanningresource_38511}    ${8}
@{ue_index_MTU_38711}    ${8}
@{ue_index_MTU_38611}    ${2}
@{ue_index_Recovery_38611}    ${2}
@{ue_index_Recovery_38711}    ${8}
@{ue_index_Recovery_38511}    ${1}
@{branch}    SBTS24R2_ENB_9999
@{allow_fault_list}    62003    7311    7307
${Test_PC_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
${Test_PC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${Test_PC_password}    ${tl.test_pc.default_ssh_connection_details.password}
${server_ip}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${server_username}    ${tl.ues[0].iperf_details.ssh_connection_details.username}
${server_password}    ${tl.ues[0].iperf_details.ssh_connection_details.password}


*** Keywords ***
Connect to gnb
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${bts_host${gnb_index}}    gnb_index=${gnb_index}
    [Teardown]    coam.teardown    connection=gnb${gnb_index}

Case Teardown
    [Arguments]    ${filename}    ${gnb_list}=${gnb_list}    ${gnb_ips}=${gnb_ips}
    Common Case Teardown for COAM    gnb_list=${gnb_list}
    FOR    ${filename_index}    IN    @{filename}
        Run keyword and ignore error
        ...    Stop capture multi gNB log    filename=${filename_index}    gnb_list=${gnb_list}
    END
    Run keyword and ignore error    Check hanging resource for gnb    gnb_ips=@{gnb_ips}    gnb_list=${gnb_list}
    ...    recovery_cell=False

Start BTSlogs Collection
    Run Keyword And Ignore error    put btslog_ini file to ute    server_ip=${server_ip}
    ...    server_username=${server_username}    server_password=${server_password}
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog

Stop Btslogs Collection
    Run Keyword And Ignore error    Stop BTSlogs Collection And Download Logs To Log Server
    Run keyword and continue on failure     Check ERR Or WRN From Syslog    sys_logs_path=${UTE_syslogs_path}

Common Case TestLine Setup with MultiBTS
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: Load the multi gnb SCF, not modify parameter
    ...    para golden_scf_name_gnb: the same scf name with multi gnb. eg if have golden_scf_name_001_gnb0
    ...                              and golden_scf_name_001_gnb1, the golden_scf_name_gnb=golden_scf_name_001_gnb
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]        ${golden_scf_name_gnb}=golden_scf_name_gnb    ${gnb_list}=${gnb_list}
    FOR    ${index}    IN    @{gnb_list}
        Common Case TestLine Setup with singe BTS
        ...    gnb_index=${index}    is_commission=True    golden_scf_name=${${golden_scf_name_gnb}${index}}
        COAM Wait for gnb ready and cell setup    timeout=20 min    gnb_type='SA'
        ...    is_x2_check_from_gnb_needed=False    gnb_index=${index}
    END
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}

Check the MultiBTS cells status on air
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: check multi gnb cells is on air
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]        ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}
    END

Reset all gnb and wait them on air
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: reset multi gnb and check the cells on air
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]    ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        COAM gNB Reset site via api    gnb_index=${gnb_index}    is_need_check_cell_onair=False    wait_for_reconnection=False
    END
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}

Online modify NIDD on gnb
    [Arguments]    ${gnb_index}=${0}    ${Modify_Para_Online}='NULL'    ${Add_Para_Online}='NULL'
    ...    ${ParameterToDelete}='NULL'    ${Add_Mo_Online}='NULL'    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}    ModifySCF_Aftercommission=True
    ...    Modify_Para_Online=${Modify_Para_Online}    Add_Para_Online=${Add_Para_Online}
    ...    Delete_Para_Online=${ParameterToDelete}    Add_Mo_Online=${Add_Mo_Online}
    ...    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    30 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Reset ABIO/ABIL Selenium
    [Documentation]         Perform Reset on ABIL based on coam Selenium Web driving
    [Arguments]   ${download_dir}=${epc_log_path}    ${gnb_index}=${2}    ${url}=${bts_host2}    ${abil_index}=${1}
    COAM Navigate to login page via webUI   download_dir=${download_dir}    gnb_index=${gnb_index}    url=${url}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_abil    abil_index=${abil_index}
    sleep    10s
    [Teardown]    COAM selenium logout

Check expect Fault Present
    [Arguments]    ${expect_alarm}    ${gnb_index}=${0}
    ${ALLOWED_FAULT_expect}     set variable    ${ALLOWED_FAULT}
    append to list    ${ALLOWED_FAULT_expect}    ${expect_alarm}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}
    @{alarm_list}    COAM Get active alarms
    ${current_faultid}    Create List
    FOR    ${alarms}    IN    @{alarm_list}
        ${alarm_tmp}    Convert To String    ${alarms}[additionalFaultID]
        append to list    ${current_faultid}    ${alarm_tmp}
        List Should Contain Value    ${ALLOWED_FAULT_expect}    ${alarm_tmp}
    END
    List Should Contain Value    ${current_faultid}    ${expect_alarm}
    [Teardown]  COAM Teardown gnb connections

### NRREL ###
Delete NRREL online
    [Arguments]    ${gnb_index}=${0}    ${Delete_Mo_Online}='NULL'
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}
    ...    ModifySCF_Aftercommission=True    Delete_Mo_Online=${Delete_Mo_Online}
    Wait until keyword succeeds    20 min    20s
        ...    Check the cells status on air    bts_host=${bts_host${gnb_index}}   connection=gnb${gnb_index}

Add NRREL online
    [Arguments]    ${gnb_index}=${0}    ${Add_Mo_Online}='NULL'
    ...    ${ModifySCF_Aftercommission}=False
    Common Case TestLine Setup with singe BTS    gnb_index=${gnb_index}
    ...    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}    Add_Mo_Online=${Add_Mo_Online}
    Check the MultiBTS cells status on air    gnb_list=${gnb_list}

Check only default Fault Present
    [Documentation]    qingqing.zhang@nokia-sbell.com
    ...    Description: check multi gnb's alarm
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]    ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        Connect to gnb coam via ssl    gnb_index=${gnb_index}
        Check only default Fault Present by one gnb
    END

Check only default Fault Present by one gnb
    @{alarm_list}    COAM Get active alarms
    FOR    ${alarms}    IN    @{alarm_list}
        ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
        List Should Contain Value    ${ALLOWED_FAULT}    ${alarms_tmp}
    END
### PA adjust ###
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance0}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb1_cell3_value}=${127}
    ...    ${gnb3_cell1_value}=${127}    ${gnb3_cell2_value}=${127}
    ...    ${gnb3_cell3_value}=${127}
    ...    ${gnb4_cell1_value}=${127}    ${gnb4_cell2_value}=${127}
    ...    ${gnb4_cell3_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb1_cell3}    Create List    ${att_port_1_gnb1_cell3_${tl}}    ${att_port_2_gnb1_cell3_${tl}}
    ...    ${att_port_3_gnb1_cell3_${tl}}    ${att_port_4_gnb1_cell3_${tl}}
    @{att_ports_gnb3_cell1}    Create List    ${att_port_1_gnb3_cell1_${tl}}    ${att_port_2_gnb3_cell1_${tl}}
    ...    ${att_port_3_gnb3_cell1_${tl}}    ${att_port_4_gnb3_cell1_${tl}}
    @{att_ports_gnb3_cell2}    Create List    ${att_port_1_gnb3_cell2_${tl}}    ${att_port_2_gnb3_cell2_${tl}}
    ...    ${att_port_3_gnb3_cell2_${tl}}    ${att_port_4_gnb3_cell2_${tl}}
    @{att_ports_gnb3_cell3}    Create List    ${att_port_1_gnb3_cell3_${tl}}    ${att_port_2_gnb3_cell3_${tl}}
    ...    ${att_port_3_gnb3_cell3_${tl}}    ${att_port_4_gnb3_cell3_${tl}}
    @{att_ports_gnb4_cell1}    Create List    ${att_port_1_gnb4_cell1_${tl}}    ${att_port_2_gnb4_cell1_${tl}}
    ...    ${att_port_3_gnb4_cell1_${tl}}    ${att_port_4_gnb4_cell1_${tl}}
    @{att_ports_gnb4_cell2}    Create List    ${att_port_1_gnb4_cell2_${tl}}    ${att_port_2_gnb4_cell2_${tl}}
    ...    ${att_port_3_gnb4_cell2_${tl}}    ${att_port_4_gnb4_cell2_${tl}}
    @{att_ports_gnb4_cell3}    Create List    ${att_port_1_gnb4_cell3_${tl}}    ${att_port_2_gnb4_cell3_${tl}}
    ...    ${att_port_3_gnb4_cell3_${tl}}    ${att_port_4_gnb4_cell3_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}
    @{values_gnb3_cell1}    Create List    ${gnb3_cell1_value}    ${gnb3_cell1_value}    ${gnb3_cell1_value}    ${gnb3_cell1_value}
    @{values_gnb3_cell2}    Create List    ${gnb3_cell2_value}    ${gnb3_cell2_value}    ${gnb3_cell2_value}    ${gnb3_cell2_value}
    @{values_gnb3_cell3}    Create List    ${gnb3_cell3_value}    ${gnb3_cell3_value}    ${gnb3_cell3_value}    ${gnb3_cell3_value}
    @{values_gnb4_cell1}    Create List    ${gnb4_cell1_value}    ${gnb4_cell1_value}    ${gnb4_cell1_value}    ${gnb4_cell1_value}
    @{values_gnb4_cell2}    Create List    ${gnb4_cell2_value}    ${gnb4_cell2_value}    ${gnb4_cell2_value}    ${gnb4_cell2_value}
    @{values_gnb4_cell3}    Create List    ${gnb4_cell3_value}    ${gnb4_cell3_value}    ${gnb4_cell3_value}    ${gnb4_cell3_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1_gnb1_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb3_cell1}    values=${values_gnb3_cell1}
    ...    att_connection_port=${att_port_1_gnb3_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb3_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb3_cell2}    values=${values_gnb3_cell2}
    ...    att_connection_port=${att_port_1_gnb3_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb3_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb3_cell3}    values=${values_gnb3_cell3}
    ...    att_connection_port=${att_port_1_gnb3_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb3_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb4_cell1}    values=${values_gnb4_cell1}
    ...    att_connection_port=${att_port_1_gnb4_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb4_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb4_cell2}    values=${values_gnb4_cell2}
    ...    att_connection_port=${att_port_1_gnb4_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb4_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb4_cell3}    values=${values_gnb4_cell3}
    ...    att_connection_port=${att_port_1_gnb4_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb4_cell3_${tl}}

Adjust gNB_RU Attenuation for 2gnb
    [Arguments]     ${tl}=${gnb_instance0}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb1_cell3_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}
    ...    ${gnb2_cell3_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb1_cell3}    Create List    ${att_port_1_gnb1_cell3_${tl}}    ${att_port_2_gnb1_cell3_${tl}}
    ...    ${att_port_3_gnb1_cell3_${tl}}    ${att_port_4_gnb1_cell3_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}
    @{att_ports_gnb2_cell3}    Create List    ${att_port_1_gnb2_cell3_${tl}}    ${att_port_2_gnb2_cell3_${tl}}
    ...    ${att_port_3_gnb2_cell3_${tl}}    ${att_port_4_gnb2_cell3_${tl}}
    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb1_cell3}    Create List    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}    ${gnb1_cell3_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}
    @{values_gnb2_cell3}    Create List    ${gnb2_cell3_value}    ${gnb2_cell3_value}    ${gnb2_cell3_value}    ${gnb2_cell3_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell3}    values=${values_gnb1_cell3}
    ...    att_connection_port=${att_port_1_gnb1_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell3}    values=${values_gnb2_cell3}
    ...    att_connection_port=${att_port_1_gnb2_cell3_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell3_${tl}}
############### capture #######################
Start capture multi gNB log
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: start multi gnb capture log
    ...    para filename_gnb: the same log name with multi gnb. eg if have filename_HB001_gnb0 and filename_HB001_gnb1
    ...                              the filename_gnb=filename_HB001_gnb
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]    ${filename}    ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        Start capture gNB log on master    filename=${${filename}${gnb_index}}   gNB_index=${gnb_index}
    END

Stop capture multi gNB log
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: stop multi gnb capture log
    ...    para filename_gnb: the same log name with multi gnb. eg if have filename_HB001_gnb0 and filename_HB001_gnb1
    ...                              the filename_gnb=filename_HB001_gnb
    ...    para gnb_list: gnb_index_list(type is list) '@{gnb_list}', Default is 0  1
    [Arguments]    ${filename}    ${gnb_list}=${gnb_list}
    FOR    ${gnb_index}    IN    @{gnb_list}
        Stop and download the Logs    filename=${${filename}${gnb_index}}   gNB_index=${gnb_index}
    END

Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Get gNB mac address
    [Arguments]    ${gnb_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gnb_index}
    ${output}=  csn.execute  command=ifconfig br1 | grep ether  connection=gNB${gnb_index}
    csn.disconnect    connection=gNB${gnb_index}
    ${mac}=     Split String    ${output}
    ${mac}    Replace String    ${mac[1]}    :    ${EMPTY}
    [Return]  ${mac}

###### Multi-UE #########
MultiUE to Disconnect UEs
    [Documentation]    huimin.1.cheng@nokia.com
    [Arguments]    ${get_spark_license}=${get_spark_license_${gnb_instance0}}    ${index_ue}=${0}
    MTU_spark.disconnect_ues    get_spark_license=${get_spark_license}    index=${index_ue}

MultiUE.Mtu Power
    [Documentation]    xiaodan.li@nokia-sbell.com
    [Arguments]    ${power_on}=true    ${mtu_index}=${ue_index_${gnb_instance0}}
    ...    ${get_spark_license}=${get_spark_license_${gnb_instance0}}    ${index_ue}=${0}
    MTU_spark.mtu_power    mtu_index=${mtu_index}    power_on=${power_on}    get_spark_license=${get_spark_license}
    ...    index=${index_ue}

Multi MTU Power on/off
    [Arguments]    ${power_on}=true    ${ue_index_MTU_all}=${ue_index_MTU_${${gnb_instance0}}}
    ...    ${get_spark_license}=${get_spark_license_${gnb_instance0}}    ${index_ue}=0
    FOR   ${index}   IN    @{ue_index_MTU_all}
        Wait until keyword succeeds    3x   10s    MultiUE.Mtu Power    power_on=${power_on}    mtu_index=${index}
        ...    get_spark_license=${get_spark_license}    index_ue=${index_ue}
        sleep    10s
    END

Multi MTU Power Recovry
        [Arguments]    ${power_on}=true    ${ue_index_MTU_all}=${ue_index_MTU_${${gnb_instance0}}}
    ...    ${get_spark_license}=${get_spark_license_${gnb_instance0}}
    FOR   ${index}   IN    @{ue_index_MTU_all}
        MTU_spark.mtu power revocery    power_on=${power_on}    mtu_index=${index}    get_spark_license=${get_spark_license}
        sleep    10s
    END

Multi MTU preapre via get imsi
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_${${gnb_instance0}}}
    ...    ${get_spark_license}=${get_spark_license_${gnb_instance0}}
    ...    ${detach_request}=${true}    ${power_reset}=true
    FOR   ${index}   IN    @{ue_index_MTU_all}
        MultiUE.Prepare UE    ue_index=${${index}-${1}}    get_spark_license=${get_spark_license}
        ...    detach_request=${detach_request}    power_reset=${power_reset}
        sleep    3s
    END

Multi MTU power and prepare ue
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_${${gnb_instance0}}}
    ...    ${ue_index_MTU_poweron_all}=${ue_index_MTU_${${gnb_instance0}}}
    ...    ${ue_index_MTU_poweroff_all}=${ue_index_Recovery_${gnb_instance0}}
    ...    ${MTU}=MTU Monitor & Controller.exe
    ...    ${detach_request}=${true}    ${power_reset}=true    ${index_ue}=0
    Restart spark exe for env reinitial    MTU=${MTU}    index_ue=${index_ue}
    log to console    Power off UE!!!
    Multi MTU Power on/off    power_on=false
    ...    ue_index_MTU_all=${ue_index_MTU_poweroff_all}    index_ue=${index_ue}
    log to console    Power on UE!!!
    Multi MTU Power on/off    power_on=true    ue_index_MTU_all=${ue_index_MTU_poweron_all}    get_spark_license=False
    ...    index_ue=${index_ue}
    sleep    90s
    Multi MTU preapre via get imsi    ue_index_MTU_all=${ue_index_MTU_all}    get_spark_license=False
    ...    detach_request=${detach_request}    power_reset=${power_reset}

Restart spark exe for env reinitial
    [Arguments]    ${MTU}=MTU Monitor & Controller.exe
    ...    ${index_ue}=0
    ${TCP_status}=    Set variable    ${False}
    FOR    ${index}    IN RANGE    ${3}
        IF    '${TCP_status}'=='${False}'
            close MTU    MTU=${MTU}    ue_index=${index_ue}
            close iperf and spark    index_ue=${index_ue}
            log to console    Reopen spark.exe!!!
            Open Spark    ue_index=${index_ue}
            sleep    90s
            ${TCP_status}=    Check spark port LISTENING    ue_index=${index_ue}
        END
        Exit For Loop If    ${TCP_status} == ${True}
    END

close iperf and spark
    [Arguments]    ${index_ue}=${0}
    log to console    Close iperf and spark!!!
    close iperf    ue_index=${index_ue}
    close Spark    ue_index=${index_ue}

Check spark port LISTENING
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    ${port_info}=    csn.Execute    command=netstat -ano | findstr 30999    connection=cygwin
    ${spark_info}=    csn.Execute    command=tasklist | findstr "Spark.exe"    connection=cygwin
    ${TCP_status1}=    Run keyword and return status    Should contain    ${port_info}    LISTENING
    ${TCP_status2}=    Run keyword and return status    Should not contain    ${port_info}    CLOSE_WAIT
    ${spark_status}=    Run keyword and return status    Should contain    ${spark_info}    Spark.exe
    ${TCP_status} =    Evaluate    ${TCP_status1} and ${TCP_status2} and ${spark_status}
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin
    [return]    ${TCP_status}


Multi MTU power and recovery ue
    [Arguments]    ${ue_index_MTU_all}=${ue_index_MTU_${${gnb_instance0}}}
    log to console    Power off UE!!!
    Multi MTU Power Recovry    power_on=false    ue_index_MTU_all=${ue_index_MTU_all}    get_spark_license=False
    log to console    Power on UE!!!
    Multi MTU Power Recovry    power_on=true    ue_index_MTU_all=${ue_index_Recovery_${gnb_instance0}}    get_spark_license=False
    log to console    Reopen spark.exe!!!
    close Spark
    Open Spark
    Open MTU

close Spark
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    csn.Execute       command=taskkill /F /IM Spark.exe       connection=cygwin
#    csn.Execute       command=taskkill /F /IM 'MTU Monitor & Controller.exe'      connection=cygwin
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

close MTU
    [Arguments]    ${ue_index}=${0}    ${MTU}=MTU Monitor & Controller.exe
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    csn.Execute       command=taskkill /F /IM '${MTU}'      connection=cygwin
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

close iperf
    [Arguments]    ${ue_index}=${0}    ${iperf}=iperf.exe
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    csn.Execute       command=taskkill /F /IM '${iperf}'      connection=cygwin
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Open Spark
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn spark_open    connection=cygwin
    sleep    30s
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

Open MTU
    [Arguments]    ${ue_index}=${0}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    csn.send_command    command=schtasks /run /tn MTU_open    connection=cygwin
    sleep    10s
    [Teardown]   Run Keyword And Ignore Error    csn.disconnect    connection=cygwin

MultiUE.Prepare UE
    [Documentation]    xiaodan.li@nokia-sbell.com
    [Arguments]    ${detach_request}=${true}    ${power_reset}=true    ${ue_index}=${ue_index_${gnb_instance0}}
    ...    ${get_spark_license}=${get_spark_license_${gnb_instance0}}
    power_ue.Prepare UE    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    detach_request=${detach_request}    power_reset=${power_reset}    get_spark_license=${get_spark_license}

MultiUE.Attach
    [Arguments]    ${ue_index}=${ue_index_${gnb_instance0}}
    ${res}    run keyword and ignore error   power_ue.UE Attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=true
    sleep    10s
    log    ${res}
    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
    ...    Basic.ThroughExceptionWithMsg    msg=Attach UE_${ue_index} Failed
    ${res}    run keyword and ignore error   power_ue.Verify attach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    4G_check=False
    run keyword if    '${res[0]}'!='PASS'   Run Keyword And Continue On Failure
    ...     Basic.ThroughExceptionWithMsg    msg=Check Attach UE_${ue_index} Failed
    log to console   UE attach completed

MutiUE.Get PDU IP
    [Arguments]    ${ue_index}=${ue_index_${gnb_instance0}}    ${APN}=dxdata1
    ${IP}    Wait until keyword succeeds    4x   10s    Spark.get_pdu_ip
    ...    apnaddress=${APN}     ue_alias=UE_${ue_index}
    [Return]    ${IP}

MultiUE.Detach
    [Arguments]    ${ue_index}=${ue_index_${gnb_instance0}}
    power_ue.UE Detach
    ...   ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=True

MultiUE.Stop DL Traffic
    [Arguments]    ${direction}=dl   ${ue_index}=${ue_index_${gnb_instance0}}    ${APN}=dxdata1    ${ue_mode}=SA
    ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}     ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    power_ue.Stop traffic
        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
        ...    apn_address=${APN}
        ...    iperf_port=${iperf_port}
        ...    ue_mode=${ue_mode}

MultiUE.Start DL Traffic
    [Arguments]    ${throughput_for_DL}=5   ${direction}=dl   ${ue_index}=${ue_index_${gnb_instance0}}
     ...    ${duration}=600    ${protocol}=UDP    ${process_num}=1
     ...    ${ue_type}=${tl.ues[${ue_index}].capabilities[-1]}    ${APN}=dxdata1
     ...    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}    ${ue_mode}=SA    ${throughout_bype}=MKbits/sec
    power_ue.Start traffic
        ...    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}
        ...    throughput=${throughput_for_DL}${throughout_bype}
        ...    duration=${duration}
        ...    apn_address=${APN}
        ...    ue_mode=${ue_mode}
        ...    iperf_port=${iperf_port}
        ...    multidrb_QoS_dest=${None}
        ...    protocol=${protocol}
        ...    process_num=${process_num}

MultiUE.Start UE DLUL traffic
    [Arguments]    ${dl_throughput}=${Send_Tput_DL_MultiUE}    ${ul_throughput}=NULL
    ...    ${iperf_port}=${tl.ues[${ue_index_${gnb_instance0}}].iperf_details.port}    ${process_num}=1
    ...    ${duration}=600    ${ue_index}=${ue_index_${gnb_instance0}}    ${APN}=dxdata1
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${dl_throughput}   duration=${duration}
    ...   APN=${APN}    iperf_port=${iperf_port}    process_num=${process_num}
    Run keyword If    '${ul_throughput}'!='NULL'
    ...   MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${ul_throughput}   duration=${duration}
    ...   APN=${APN}    iperf_port=${iperf_port}    direction=ul

Start UE DLUL TCP traffic
    [Arguments]    ${ue_type}=${ue_type}     ${process_num_DL}=${process_num_DL}    ${seg_size}=${seg_size}
    ...    ${process_num_UL}=${process_num_UL}
    Power UE Start DL traffic   ue_type=${ue_type}    protocol=${protocol_TCP}    process_num=${process_num_DL}
    ...    seg_size=${seg_size}    dl_throughput=${Send_Tput_DL}
    Power UE Start UL traffic    ue_type=${ue_type}    protocol=${protocol_TCP}    process_num=${process_num_UL}
    ...    seg_size=${seg_size}    ul_throughput=${Send_Tput_UL}

MultiUE.Start DLUL traffic and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}
    ...    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL    ${dl_port}=${DL_PORT_387}
    ...    ${dl_throughput}=${Send_Tput_DL_MultiUE}    ${APN}=dxdata1
    ...    ${ul_throughput}=NULL    ${protocol}=${protocol_UDP}    ${process_num}=${4}
    ...    ${ue_index}=${ue_index_${gnb_instance0}}    ${duration}=1500    ${time}=30s
    Run keyword If    '${protocol}'=='tcp'
    ...    Start UE DLUL TCP traffic    ELSE
    ...    MultiUE.Start UE DLUL traffic    ue_index=${ue_index}    dl_throughput=${dl_throughput}    process_num=${process_num}
    ...    ul_throughput=${ul_throughput}    duration=${duration}    APN=${APN}    iperf_port=${dl_port}
    Sleep    30s
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    tput_ul_scell=${tput_ul_scell}    scellid=${scellid}    pcellid=${pcellid}
    ...    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}    duration=${time}

MultiUE.Start DL traffic parallel and check 2CC tput
    [Arguments]    ${scellid}=1    ${pcellid}=1
    ...    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}    ${time}=30s
    ...    ${tput_ul_pcell}=NULL    ${dl_port_mdrb}=${DL_PORT_387}    ${gnb_prime}=${0}
    ...    ${gnb_external}=${1}    ${Send_Tput_DL_DRB7}=${Send_Tput_DL_DRB7}    ${Send_Tput_DL_DRB9}=${Send_Tput_DL_DRB9}
    ...    ${ul_throughput}=${Send_Tput_UL}    ${ue_index}=${ue_index_${gnb_instance0}}    ${duration}=900    ${APN}=dxdata1
    ...    ${process_num}=${3}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL_DRB9}   duration=${duration}
    ...   APN=${APN}    iperf_port=${dl_port_mdrb}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${Send_Tput_DL_DRB7}   duration=${duration}
    ...   APN=${APN}    process_num=${process_num}
    MultiUE.Start DL Traffic    ue_index=${ue_index}    throughput_for_DL=${ul_throughput}   duration=${duration}    direction=ul
    ...   APN=${APN}    iperf_port=${dl_port_mdrb}
    Sleep    30s
    Check 2CC DLUL tput     tput_dl_pcell=${tput_dl_pcell}    tput_dl_scell=${tput_dl_scell}    tput_ul_pcell=${tput_ul_pcell}
    ...    scellid=${scellid}    pcellid=${pcellid}    gnb_prime=${gnb_prime}    gnb_external=${gnb_external}
    ...    duration=${time}

Get two gnbs theoretical throughput from nrdim
    [Arguments]    ${scellid}=1    ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}
    ${release_info}    Get sagnb release
    ${params_dict}    Create Dictionary    actCsirsMultiplexing=${1}
    ${dl_expect_pcell}    Run Keyword If    '${gnb_instance0}' == '${gnb_id}[2]' and ${gnb_prime}==${0} and ${pcellid}==${3}
    ...    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${tl_scf_dir_path}${tl_scf_gnb${gnb_prime}}${release_info}.xml    cell_id=${pcellid}
    ...    mod_params=${params_dict}    ELSE    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${tl_scf_dir_path}${tl_scf_gnb${gnb_prime}}${release_info}.xml    cell_id=${pcellid}
    ${dl_expect_scell}    nrdim_get_tput.Get Theoretical Throughput
    ...    scf_path=${tl_scf_dir_path}${tl_scf_gnb${gnb_external}}${release_info}.xml    cell_id=${scellid}
    [Return]    ${dl_expect_pcell}[0]    ${dl_expect_scell}[0]

MultiUE.Stop DLUL traffic
    [Arguments]    ${ue_index}=${ue_index_${gnb_instance0}}    ${APN}=dxdata1
    ...    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}    ${iperf_port_mdrb}=NULL
    power_ue.Stop traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    apn_address=${APN}
        ...    iperf_port=${iperf_port}
    run keyword If    '${iperf_port_mdrb}'!='NULL'
    ...    power_ue.Stop traffic
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
    ...    apn_address=${APN}
    ...    iperf_port=${iperf_port_mdrb}
    power_ue.Stop traffic
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
    ...    apn_address=${APN}
    ...    iperf_port=${iperf_port}

Check 2CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${tput_ul_pcell}=NULL    ${tput_ul_scell}=NULL    ${duration}=30s
    ...    ${scellid}=1   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${gnb_index_CA}    Create list    ${gnb_prime}    ${gnb_external}
    ${tput_log}    power_ue.Collect Tput    duration=${duration}    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_index_CA}
    run keyword If    '${tput_dl_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log}[0]    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    run keyword If    '${tput_dl_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log}[1]    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}
    run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    Get average UL through and check    log=${tput_log}[0]    list_of_cell_ids=${nrcellid_pcell}
    ...    tput_ul_pcell=${tput_ul_pcell}
    run keyword If    '${tput_ul_scell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_scell}    log=${tput_log}[1]    ue_type=${ue_type}
    ...    target_throughput=${tput_ul_scell}


Get average UL through and check
    [Arguments]    ${log}    ${list_of_cell_ids}    ${tput_ul_pcell}
    ${tput_result}    ${record}    aastp.get_aasyslog_throughput
    ...                            direction=ul    log=${log}    cells=${list_of_cell_ids}
    ${real_ul_tput}    set variable    ${tput_result[0]['average']}
    Should Be True    ${real_ul_tput} > ${tput_ul_pcell}*0.6

Check 3CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell1}=${expected_tput_dl_T}
    ...    ${tput_dl_scell2}=${expected_tput_dl_T}    ${tput_ul_pcell}=${expected_tput_ul}
    ...    ${scellid2}=1    ${scellid1}=1   ${pcellid}=1    ${gnb_prime}=${0}    ${gnb_external}=${1}    ${ue_type}=${ue_type}
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${gnb_prime}
    ${nrcellid_scell1}    COAM Get nrcellid with lcrid    lcrid=${scellid1}    gnb_index=${gnb_external}
    ${nrcellid_scell2}    COAM Get nrcellid with lcrid    lcrid=${scellid2}    gnb_index=${gnb_external}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell1}    Create list  ${nrcellid_scell1}
    ${nrcellid_scell2}    Create list  ${nrcellid_scell2}
    ${tput_log_prime}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_prime}
    ${tput_log_external}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${gnb_external}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell1}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell1}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell2}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell2}
    run keyword If    '${tput_ul_pcell}'!='NULL'
    ...    power_ue.Check Tput    direction=UL    cells=${nrcellid_pcell}    log=${tput_log_prime}   ue_type=${ue_type}
    ...    target_throughput=${tput_ul_pcell}

Make VONR call
   [Arguments]    ${ue_index}=${ue_index_${gnb_instance0}}
   spark.send AT command CPE     param=ATD006688;     ue_alias=UE_${ue_index}
   ${Vonr_call_status}    Run Keyword And Continue On Failure   spark.get Vonr call status on ue
   ...      ue_alias=UE_${ue_index}   param={"LastEventIndex":0}
   run keyword if    '${Vonr_call_status}'=='True'    sleep    10s
   ...    ELSE  Fail    VONR call failed

MultiUE.Change Network
    [Arguments]    ${network}=LTE    ${ue_index}=${2}
    MultiUE.Attach    ue_index=${ue_index}
    Sleep    2s
    Spark.send AT command CPE     param=at+QNWPREFCFG="mode_pref",${network};     ue_alias=UE_${ue_index}
    Sleep    2s
    [Teardown]    MultiUE.Detach    ue_index=${ue_index}

MultiUE.band restriction
    [Arguments]    ${band}=2:25:41:66    ${ue_index}=${ue_index_${gnb_instance0}}
    MultiUE.Attach    ue_index=${ue_index}
    Sleep    2s
    Spark.send AT command CPE     param=at+QNWPREFCFG="nr5g_band",${band};     ue_alias=UE_${ue_index}
    Sleep    20s
    [Teardown]    MultiUE.Detach    ue_index=${ue_index}

MultiUE.Change APN
    [Arguments]    ${APN}=dxdata1    ${ue_index}=${ue_index_${gnb_instance0}}
    MultiUE.Attach    ue_index=${ue_index}
    Sleep    2s
    Wait until keyword succeeds    4x   10s    Spark.send AT command CPE
    ...    param=at+cgdcont=1,"IP","${APN}";     ue_alias=UE_${ue_index}
    Sleep    2s
    [Teardown]    MultiUE.Detach    ue_index=${ue_index}

Basic.ThroughExceptionWithMsg
    [Arguments]     ${msg}
    Fail    ${msg}

###cell info###
Get cell id multignb
    [Arguments]    ${lcrid_pcell}=${1}    ${scell_index_list}=${scell_index_list}
    ...    ${PrimegNB_index}=${0}    ${extgnb_index_list}=${extgnb_index_list}
    ${primecell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid_pcell}    gnb_index=${PrimegNB_index}
    set suite variable    ${primecell1_id}
    ${extcell_id}    Create List
    FOR    ${lcrid}    ${index}    IN ZIP    ${scell_index_list}    ${extgnb_index_list}
        ${extcell}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${index}
        Append to List    ${extcell_id}    ${extcell}
    END
    set suite variable    ${extcell_id}

Get gnb length from webEM
    [Arguments]    ${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${gNbIdLength_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${gNbIdLength_value}=    selenium_coam.get_parameter_value    dist_name=${gNbIdLength_distname}
    ...    filter_param=gNB id length    abbr=gNbIdLength
    Run Keyword And Ignore Error    selenium_coam.logout
    selenium_coam.disable_virtual_display
    [Return]    ${gNbIdLength_value}    ${bts_id}

Get MultigNBId_DEC with HEX
    [Arguments]    ${gnb_list}=${gnb_list}
    @{gNb1Id_DEC_list}    Create List
    FOR    ${gnb_index}    IN    @{gnb_list}
        ${gNbId_DEC}    Gnb id conversion    WEBUI_COAM=${WEBUI_host${gnb_index}}
        Append to List    ${gNb1Id_DEC_list}    ${gNbId_DEC}
    END
    [Return]    ${gNb1Id_DEC_list}

Gnb id conversion
    [Arguments]    ${WEBUI_COAM}
     @{gNb_Message}    Get gnb length from webEM    WEBUI_COAM=${WEBUI_COAM}
     ${gNbIdLength}    set variable    ${gNb_Message}[0]
     ${bts_id}    set variable    ${gNb_Message}[1]
     ${gNbIdLength_int}    Convert to Integer    ${gNbIdLength}
     ${remainder}    Evaluate    ${gNbIdLength_int}%4
     ${gNbId_DEC}    Run Keyword If    ${remainder}==${0}    set variable    ${bts_id}
     ...    ELSE   Evaluate    2**${remainder}*${bts_id}
      ${gNbId_DEC_int}    Convert to Integer    ${gNbId_DEC}
     [Return]    ${gNbId_DEC_int}

Get value of parameter from WEBEM
    [Arguments]    ${value}    ${dist_name}    ${filter_param}    ${abbr}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${parameter_value}=    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}    abbr=${abbr}
    Should Be Equal    ${parameter_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${xpath}
    ...    ${iGnbCaXnSetupReqTmr}=${60}    ${message_index}=${0}    ${message2_index}=${0}
    ${time} =    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${time1} =    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${time} =    Convert To Number    ${time[${message_index}]}
    ${time1} =    convert_to_number    ${time1[${message2_index}]}
    ${time_dif1} =    evaluate    abs(${time1}-${time})
    ${time_dif1} =    evaluate    round(${time_dif1},2)
    should be true    ${time_dif1}<=${iGnbCaXnSetupReqTmr}

Check message time regularly
    [Arguments]    ${logname}    ${message_filter}    ${xpath}
    ${result}    Check wireshark log    logname=${logname}   message_filter=${message_filter}    xpath=${xpath}
    ${length}=        Get Length    ${result}
    FOR    ${index}    IN RANGE    ${0}    ${length}-${1}
        ${frame_time}    Convert To Number    ${result[${index}]}    0
        ${frame_time1}    Convert To Number    ${result[${index}+${1}]}    0
        ${time_dif1} =    evaluate    abs(${frame_time1}-${frame_time})
        should be equal    ${time_dif1}    ${2}
    END

Get message time list
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${frame_time}=     cap.get_field_value_by_xpath    xpath=.//frame.time_epoch     pcap_parser=test6
    [Return]    ${frame_time}

############### wireshark xnap log #######################
Check 1st IgNBCASetupRequest
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 17 and nokiaxnap.XnAP_PDU == 1
    ...    ${message_filter2}=nokiaxnap.IgNBCASetupRequest_element and ip.src == ${xnap_gnb1}
    ...    ${xpath}=.//ip.src
    ...    ${xpath1}=.//ip.dst
    ...    ${xpath2}=.//frame.time_epoch
    ...    ${iGnbCaXnSetupReqTmr}=${60}
    Log    check first send IgNBCASetupRequest gnb is gnb1 and timediff less than 1 with last XnSetupResponse
    ${ip_src_result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    List Should Contain Value    ${xnap_gnb}    ${ip_src_result[-1]}
    ${ip_dst_result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    List Should Contain Value    ${xnap_gnb}    ${ip_dst_result[-1]}
    Check timer differ    logname=${logname}    message_filter=${message_filter1}    message_filter1=${message_filter2}
    ...    xpath=${xpath2}    iGnbCaXnSetupReqTmr=${iGnbCaXnSetupReqTmr}    message_index=${-1}    message2_index=${0}

Check IgNBCASetup on 2gnb
    [Arguments]    ${logname}    ${PrimegNB}=${xnap_gnb1}    ${ExtgNB}=${xnap_gnb2}
    ...    ${message_filter1}=nokiaxnap.IgNBCASetupRequest_element and ip.src == ${PrimegNB}
    ...    ${message_filter2}=nokiaxnap.IgNBCASetupResponse_element and ip.src == ${ExtgNB}
    ...    ${xpath}=.//nokiaxnap.NR_Cell_Identity
    Log    check IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${extcell_id[0]}
    Log    check gNBCASetupResponse has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${primecell1_id}

Check IgNBCAconfig on 2gnb
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.CellLoadReportingPeriodicity and ip.src == ${xnap_gnb1}
    ...    ${message_filter2}=nokiaxnap.CellLoadReportingPeriodicity and ip.src == ${xnap_gnb3}
    ...    ${xpath}=.//nokiaxnap.CellLoadReportingPeriodicity
    Log    check gNB1 IgNBCAConfigurationUpdateIndication has the 2000
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    should be equal    ${result[0]}    2000
    Log    check gNB2 IgNBCAConfigurationUpdateIndication has the 2000
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    should be equal    ${result[0]}    2000

Check IgNBCAconfigcellstatus on 2gnb
    [Arguments]    ${logname}
    ...    ${message_filter1}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb1}
    ...    ${message_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb3}
    ...    ${xpath}=.//nokiaxnap.NR_Cell_Identity
    ...    ${xpath1}=.//nokiaxnap.cell_Availability
    Log    check gNB1 IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${primecell1_id}
    Log    check gNB2 IgNBCASetupRequest has the cellid
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${result_int}=    Convert To Integer    ${result[0]}    16
    should be equal    ${result_int}    ${extcell_id[0]}
    Log    check gNB1 IgNBCAConfigurationUpdateIndication cell status is avaliable
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    should be equal    ${result[0]}    1
    Log    check gNB2 IgNBCAConfigurationUpdateIndication cell status is avaliable
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    should be equal    ${result[0]}    1

Check IgNBCAResourceStatusUpdate time interval on 2gnb
    [Arguments]    ${logname}
    ...    ${message1_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb1}
    ...    ${message1_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb1}
    ...    ${message2_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb3}
    ...    ${message2_filter2}=nokiaxnap.cell_Availability and ip.src == ${xnap_gnb3}
    ...    ${xpath}=.//frame.time_epoch
    Check timer differ    logname=${logname}    message_filter=${message1_filter1}    message_filter1=${message1_filter2}
    ...    xpath=${xpath}
    Check timer differ    logname=${logname}    message_filter=${message2_filter1}    message_filter1=${message2_filter2}
    ...    xpath=${xpath}
    Check message time regularly    logname=${logname}    message_filter=${message1_filter1}    xpath=${xpath}
    Check message time regularly    logname=${logname}    message_filter=${message2_filter1}    xpath=${xpath}

Check IgNBCAXpSetupRequest message
    [Arguments]    ${logname}    ${gnb_ID}
    ${gnb_ID_log}    Check wireshark log    logname=${logname}    attribute_name=value
    ...    message_filter=nokiaf1ap.procedureCode == 14 and nokiaf1ap.Nokia_F1AP_PDU == 0
    ...    xpath=.//nokiaf1ap.gnb_ID
    ${gnb_ID_transition_DEC}    Evaluate    list(map(lambda x: int(x, 16), ${gnb_ID_log}))
    should be equal     ${gnb_ID_transition_DEC[0]}    ${gnb_ID}

Check IgNBCAXpSetupResponse message
    [Arguments]    ${logname}    ${XP_Status}    ${gnb_ID}
    ${XpConnectionStatus}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaf1ap.procedureCode == 14
    ...    xpath=.//nokiaf1ap.XpConnectionStatus
    ${XpStatus_log}    Convert to Integer     ${XpConnectionStatus[0]}
    should be equal    ${XpStatus_log}    ${XP_Status}
#    ${IgNBCAXpProtocolVersion}    Check wireshark log    logname=${logname}
#    ...    message_filter=nokiaf1ap.procedureCode == 14
#    ...    xpath=.//nokiaf1ap.IgNBCAXpProtocolVersion
#    should be equal    ${IgNBCAXpProtocolVersion[0]}    1
    ${gnb_ID_log}    Check wireshark log    logname=${logname}    attribute_name=value
    ...    message_filter=nokiaf1ap.procedureCode == 14 and nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    xpath=.//nokiaf1ap.gnb_ID
    ${gnb_ID_transition_DEC}    Evaluate    list(map(lambda x: int(x, 16), ${gnb_ID_log}))
    should be equal     ${gnb_ID_transition_DEC[0]}    ${gnb_ID}

Check IgNBCAconfigurationUpdateIndication message
    [Arguments]    ${logname}    ${soure_ip}
    ${IgNBCAXpProtocolVersion_indication}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaxnap.procedureCode == 22 and ip.src == ${soure_ip}
    ...    xpath=.//nokiaxnap.IgNBCAXpProtocolVersion
    ${IgNBCAXpProtocolVersion_response}    Check wireshark log    logname=${logname}
    ...    message_filter=nokiaf1ap.procedureCode == 14
    ...    xpath=.//nokiaf1ap.IgNBCAXpProtocolVersion
    should be equal    ${IgNBCAXpProtocolVersion_indication[0]}    ${IgNBCAXpProtocolVersion_response[0]}

Check IgNBCAResourceStatusUpdate has nrcellid on PrimegNB
    [Arguments]    ${logname}    ${scell}    ${scell_nums}=${1}    ${xnap_gnb}=${xnap_gnb2}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb} and nokiaxnap.CellLoadResult == ${scell_nums}
    ...    ${xpath}=.//nokiaxnap.NR_Cell_Identity
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    FOR   ${cell_index}   IN RANGE    ${0}    ${scell_nums}
        ${result_scell}=    Convert To Integer    ${result[${cell_index}]}    16
        Should be equal    ${result_scell}    ${scell[${cell_index}]}
    END

Check numberOfActiveUEs and numberOfActiveUlUEs
    [Arguments]    ${logname}    ${numberOfActiveUEs_value}    ${numberOfActiveUlUEs_value}
    ...    ${xnap_gnb}=${xnap_gnb2}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 139 and ip.src == ${xnap_gnb} and nokiaxnap.CellLoadResult
    ...    ${xpath}=.//nokiaxnap.numberOfActiveUEs
    ...    ${xpath1}=.//nokiaxnap.numberOfActiveUlUEs
    ${numberOfActiveUEs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${numberOfActiveUlUEs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    List Should Contain Sub List    ${numberOfActiveUEs}    ${numberOfActiveUEs_value}
    List Should Contain Sub List    ${numberOfActiveUlUEs}    ${numberOfActiveUlUEs_value}

######## check attach and detach wireshark log ##########
Check attach and detach wireshark log
    [Arguments]    ${logname}    ${logname1}    ${Primegnb_index}=${0}    ${extgnb_index_list}=${extgnb_index_list}
    ...    ${pcell_index}=${1}    ${scell_index_list}=${scell_index_list}    ${UEContextModificationResponse_nums}=${3}
    ...    ${A2_release_detach}=FALSE
    Check attach wireshark log    logname=${logname}    logname1=${logname1}
    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}
    Run keyword IF    '${A2_release_detach}'=='False'    Check detach wireshark log    logname=${logname}    logname1=${logname1}

Check attach wireshark log
    [Arguments]    ${logname}    ${logname1}
    ...    ${Primegnb_index}=${0}    ${extgnb_index_list}=${extgnb_index_list}
    ...    ${pcell_index}=${1}    ${scell_index_list}=${scell_index_list}
    ...    ${IP_type_Xpath}=.//nokiaxnap.TransportLayerAddressIPv4
    ...    ${UEContextModificationResponse_nums}=${3}
    Check attach wireshark log on PrimegNB    logname=${logname}
    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
    ...    IP_type_Xpath=${IP_type_Xpath}    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}
    Check attach wireshark log on extgNB    logname=${logname1}

Check attach wireshark log on PrimegNB
    [Arguments]    ${logname}
    ...    ${Primegnb_index}=${Primegnb_index}    ${extgnb_index_list}=${extgnb_index_list}
    ...    ${pcell_index}=${pcell_index}    ${scell_index_list}=${scell_index_list}
    ...    ${IP_type_Xpath}=${IP_type_Xpath}
    ...    ${UEContextModificationResponse_nums}=${UEContextModificationResponse_nums}
    ### PrimegNB log###
    Get cell id multignb    lcrid_pcell=${pcell_index}    scell_index_list=${scell_index_list}
    ...    PrimegNB_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
    Check 1st IgNBCAUeContextModificationRequest message has igNBCASetup on PrimegNB   logname=${logname}
    Check IgNBCAUeContextModificationResponse has messages on PrimegNB   logname=${logname}
    Check IgNBCAAdditionRequest message has pGNBIP and pcellid and scellid on PrimegNB   logname=${logname}
    ...    gnb_index=${Primegnb_index}    xpath=${IP_type_Xpath}
    Check IgNBCAAdditionAcknowledge message has eGNBIP and scellid on PrimegNB   logname=${logname}
    ...    extgnb_index_list=${extgnb_index_list}    xpath=${IP_type_Xpath}
    Check 2st has the IgNBCAUeContextModificationRequest message on PrimegNB   logname=${logname}
    Check IgNBCAModificationAcknowledge message on PrimegNB    logname=${logname}
    Check UEContextModificationResponse has physcellid on PrimegNB    logname=${logname}
    ...    pcell_index=${pcell_index}    scell_index_list=${scell_index_list}
    ...    Primegnb_index=${Primegnb_index}    extgnb_index_list=${extgnb_index_list}
    ...    UEContextModificationResponse_nums=${UEContextModificationResponse_nums}

Check attach wireshark log on extgNB
    [Arguments]    ${logname}
    ### ExtgNB log###
    Check IgNBCAContextSetupRequest message on extgNB    logname=${logname}
    Check IgNBCAContextSetupResponse message on extgNB    logname=${logname}
    Check IgNBCAUeContextModificationRequest message on extgNB    logname=${logname}
    Check IgNBCAUeContextModificationResponse message on extgNB    logname=${logname}

Check detach wireshark log
    [Arguments]    ${logname}    ${logname1}
    ### PrimegNB log###
    Check UeContextReleaseCommand message on PrimegNB    logname=${logname}
    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname}
    Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB    logname=${logname}
    ### ExtgNB log###
    Check IgNBCAUeContextReleaseCommand message on extgNB    logname=${logname1}
    Check IgNBCAUeContextReleaseComplete message on extgNB    logname=${logname1}

Check 1st IgNBCAUeContextModificationRequest message has igNBCASetup on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.queryPurpose==0
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check IgNBCAUeContextModificationRequest has igNBCASetup
    ${igNBCASetup}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${igNBCASetup[0]}    0

Check IgNBCAUeContextModificationResponse has messages on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAUeContextModificationResponse message
    ${F1AP_PDU}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should contain   ${F1AP_PDU}    1

Check IgNBCAAdditionRequest message has pGNBIP and pcellid and scellid on PrimegNB
    [Arguments]    ${logname}    ${gnb_index}=${0}    ${xpu_gnb}=${xpu_gnb${${gnb_index}+${1}}}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.TransportLayerAddressIPv4
    ...    ${xpath1}=.//nokiaxnap.NR_Cell_Identity
#    ${xpu_gnb}    Set Variable    ${xpu_gnb${${gnb_index}+${1}}}
    Log    check IgNBCAAdditionRequest message
    ${prime_gnbip}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${prime_gnbip[0]}    ${xpu_gnb}
    ${cellid}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${cellid_cc}    Create List
    FOR    ${cell_index}    IN    @{cellid}
        ${result_cell}=    Convert To Integer    ${cell_index}    16
        Append To List    ${cellid_cc}    ${result_cell}
    END
    List should Contain value    ${cellid_cc}    ${primecell1_id}
    List should Contain Sub List    ${cellid_cc}    ${extcell_id}

Check IgNBCAAdditionAcknowledge message has eGNBIP and scellid on PrimegNB
    [Arguments]    ${logname}    ${extgnb_index_list}=${extgnb_index_list}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 1 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.TransportLayerAddressIPv4
    ...    ${xpath1}=.//nokiaxnap.NR_Cell_Identity
    Log    check IgNBCAAdditionAcknowledge message
    ${xpu_gnb}    Create List
    FOR    ${extgnb_index}    IN    @{extgnb_index_list}
        Append to List    ${xpu_gnb}    ${xpu_gnb${${extgnb_index}+${1}}}
    END
    ${ext_gnbip}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    List should Contain Sub List    ${ext_gnbip}    ${xpu_gnb}
    ${scellid}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${scell_result}    Create List
    FOR    ${scell_index}    IN    @{scellid}
        ${result_extcell}=    Convert To Integer    ${scell_index}    16
        Append To List    ${scell_result}    ${result_extcell}
    END
    List should Contain Sub List    ${scell_result}    ${extcell_id}

Check 2st has the IgNBCAUeContextModificationRequest message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.dRBID
    ...    ${xpath}=.//nokiaf1ap.dRBID
    Log    check IgNBCAUeContextModificationRequest message
    ${dRBID}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should contain    ${dRBID}    4

Check IgNBCAModificationAcknowledge message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 1 and nokiaxnap.procedureCode == 141
    ...    ${xpath}=.//nokiaxnap.Nokia_XnAP_PDU
    Log    check IgNBCAModificationRequest message
    ${XnAP_PDU}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${XnAP_PDU[0]}    1

Check UEContextModificationResponse has physcellid on PrimegNB
    [Arguments]    ${logname}
    ...    ${pcell_index}=${pcell_index}    ${scell_index_list}=${scell_index_list}
    ...    ${Primegnb_index}=${Primegnb_index}    ${extgnb_index_list}=${extgnb_index_list}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList==
    ...    ${message_filter1}= and nr-rrc.physCellId ==
    ...    ${xpath1}=.//nr-rrc.physCellId    ${CA_OK}=True    ${UEContextModificationResponse_nums}=${3}
    ${pci_cclist}    Create List
    ${pci_pcell}=    get required cell info   required_info=physicalCellId    cell_index=${pcell_index}   gnb_index=${Primegnb_index}
    ${pci_pcell}=    Convert To String    ${pci_pcell}
    Append to list    ${pci_cclist}    ${pci_pcell}
    FOR    ${scell_index}    ${extgnb_index}    IN ZIP    ${scell_index_list}    ${extgnb_index_list}
        ${pci_scell}=    get required cell info
        ...    required_info=physicalCellId    cell_index=${scell_index}   gnb_index=${extgnb_index}
        ${pci_scell}=    Convert To String    ${pci_scell}
        Append to list    ${pci_cclist}    ${pci_scell}
    END
    ${scell_nums}    Get Length    ${scell_index_list}
    Log    check UEContextModificationResponse message
    ${physCellId_list}=    Check wireshark log    logname=${logname}
    ...    message_filter=${message_filter}${scell_nums}${message_filter1}${pci_pcell}    xpath=${xpath1}
    ${wireshark_cell_num}    Get Length    ${physCellId_list}
    ${CA_cell_num}    Get Length    ${pci_cclist}
    Run keyword If    ${CA_OK}==True    Should be true   ${wireshark_cell_num}==${UEContextModificationResponse_nums}*${CA_cell_num}
    ...    ELSE    Should be true   ${wireshark_cell_num}!=${UEContextModificationResponse_nums}*${CA_cell_num}
    ${CA_status}=    Run keyword and return status    List Should Contain Sub List    ${physCellId_list}    ${pci_cclist}
    Run keyword If    ${CA_OK}==True    should be equal    ${CA_status}    ${true}
    ...    ELSE    should be equal    ${CA_status}    ${false}

Check IgNBCAContextSetupRequest message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.procedureCode == 192
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAContextSetupRequest message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    0

Check IgNBCAContextSetupResponse message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nokiaf1ap.procedureCode == 192
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAContextSetupResponse message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    1

Check IgNBCAUeContextModificationRequest message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAUeContextModificationRequest message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    0

Check IgNBCAUeContextModificationResponse message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check IgNBCAUeContextModificationResponse message
    ${procedureCode}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${procedureCode[0]}    1

####check xgu failure####
Check IgNBCAAdditionRequestReject message on PrimegNB and ExtgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.transport == 0 and nokiaxnap.Nokia_XnAP_PDU == 2
    ...    ${xpath}=.//nokiaxnap.transport
    Log    IgNBCAAdditionRequestReject message
    ${transport_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${transport_cause[0]}    0

Check 2st IgNBCAUeContextModificationRequest message with CA cancel on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.queryPurpose == 1 and nokiaf1ap.procedureCode == 193
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check 2st IgNBCAUeContextModificationRequest message with CA cancel
    ${queryPurpose}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${queryPurpose[0]}    1

Check 2st IgNBCAUeContextModificationResponse message with CA cancel on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nokiaf1ap.procedureCode == 193 and !nokiaf1ap.dRBID
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    IgNBCAUeContextModificationResponse message
    ${f1ap_pdu}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${f1ap_pdu[0]}    1

Check IgNBCAContextSetupFailure message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.transport == 1 and nokiaf1ap.procedureCode == 192
    ...    ${xpath}=.//nokiaf1ap.transport
    Log    check IgNBCAContextSetupFailure message
    ${transport_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal    ${transport_cause[0]}    1

####check attach failure####
Check 2st IgNBCAUeContextModificationRequest has the cancel CA message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.queryPurpose == 1
    ...    ${xpath}=.//nokiaf1ap.queryPurpose
    Log    check IgNBCAUeContextModificationRequest has the cancel CA message
    ${queryPurpose}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${queryPurpose[0]}    1

####check UErelease#####
Check UeContextReleaseCommand message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=ngap.procedureCode == 41 && ngap.nas == 2
    ...    ${xpath}=.//ngap.nas
    Log    check UeContextReleaseCommand has the deregister(2) message
    ${ngap_nas}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${ngap_nas[0]}    2

Check IgNBCAReleaseRequest message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.radioNetwork == 65
    ...    ${xpath}=.//nokiaxnap.radioNetwork
    ...    ${xpath1}=.//nokiaxnap.Ext_gNB_CU_UE_XnAP_ID
    Log    check IgNBCAReleaseRequest has the normal-release(65) message
    ${radioNetwork}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${radioNetwork[0]}    65
    Log    check IgNBCAReleaseRequest Ext-gNB-CU-UE-XnAP-ID
    ${xnap_id_request}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    set suite variable    ${xnap_id_request}

Check IgNBCAReleaseRequestAcknowledge message on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 142 and nokiaxnap.Nokia_XnAP_PDU == 1
    ...    ${xpath}=.//nokiaxnap.Ext_gNB_CU_UE_XnAP_ID
    Log    check IgNBCAReleaseRequestAcknowledge message
    ${xnap_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${xnap_id}    ${xnap_id_request}

Check IgNBCAUeContextReleaseCommand message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 194 and nokiaf1ap.Nokia_F1AP_PDU == 0
    ...    ${xpath}=.//nokiaf1ap.radioNetwork
    Log    check UeContextReleaseCommand has the normal release message
    ${release_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${release_cause[0]}    10

Check IgNBCAUeContextReleaseComplete message on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 194 and nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.Nokia_F1AP_PDU
    Log    check UeContextReleaseCommand has the deregister message
    ${f1ap_pdu}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${f1ap_pdu[0]}    1

Check pscell and scell release wireshark log
    [Arguments]    ${logname}    ${logname1}
    ### PrimegNB log###
    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname}
    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname}
    ### ExtgNB log###
    Check IgNBCAReleaseRequest message on PrimegNB    logname=${logname1}
    Check IgNBCAUeContextReleaseCommand message on extgNB    logname=${logname1}
    Check IgNBCAUeContextReleaseComplete message on extgNB    logname=${logname1}
    Check IgNBCAReleaseRequestAcknowledge message on PrimegNB    logname=${logname1}

####check RRC Reconfiguratuon#####
Check RRC Reconfiguratuon message with eventId
    [Arguments]    ${logname}    ${eventId}==5    ${event_result}=Yes
    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 and nr-rrc.eventId == ${eventId}
    ...    ${xpath}=.//nr-rrc.eventId
    Log    check RRC Reconfiguratuon message with eventid
    ${eventId_result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Run keyword If    '${event_result}'=='Yes'    should be equal    ${eventId_result[0]}    ${eventId}
    ...    ELSE    Should Be Empty    ${eventId_result}

####check Measurement#####
Check Measurement message on PrimegNB for BB07
    [Arguments]    ${logname}    ${cell_index}=${1}    ${gnb_index}=${1}    ${event_id}=2    ${meas_lengths_list}=${meas_lengths_list}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measId == ${event_id}
    ...    ${xpath}=.//nr-rrc.physCellId
    ...    ${xpath1}=.//nr-rrc.measId
    ${pci_pcell}=    get required cell info   required_info=physicalCellId    cell_index=${cell_index}   gnb_index=${gnb_index}
    ${pci_pcell}    Convert to String    ${pci_pcell}
    Log    check Measurement message has physCellId
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    List Should Contain Value   ${physCellId}    ${pci_pcell}
    ${measId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${measid_lenght}    Get Length    ${measId}
    List Should Contain Value    ${meas_lengths_list}    ${measid_lenght}

Check Measurement message on PrimegNB
    [Arguments]    ${logname}    ${cell_index}=${1}    ${gnb_index}=${1}    ${event_id}=2    ${meas_lengths}=${1}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measId == ${event_id}
    ...    ${xpath}=.//nr-rrc.physCellId
    ...    ${xpath1}=.//nr-rrc.measId
    ${pci_pcell}=    get required cell info   required_info=physicalCellId    cell_index=${cell_index}   gnb_index=${gnb_index}
    ${pci_pcell}    Convert to String    ${pci_pcell}
    Log    check Measurement message has physCellId
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    List Should Contain Value   ${physCellId}    ${pci_pcell}
    ${measId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${measid_lenght}    Get Length    ${measId}
    Should be equal   ${measid_lenght}    ${meas_lengths}

####Check Xguip#####
Check IgNBCAUeContextModificationResponse has transport messages on PrimegNB
    [Arguments]    ${logname}    ${xgU_addr}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.transportLayerAddressIPv6
    Log    Check IgNBCAUeContextModificationResponse has transport messages
    ${transport_addr}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal   ${transport_addr[0]}    ${xgU_addr}

Check IgNBCAUeContextSetupResponse has transport messages on ExtgNB
    [Arguments]    ${logname}    ${xgU_addr}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.transportLayerAddressIPv6
    Log    Check IgNBCAUeContextSetupResponse has transport messages
    ${transport_addr}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be equal   ${transport_addr[0]}    ${xgU_addr}

Check IgNBCAUeContextSetupResponse has no transport ip on ExtgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath}=.//nokiaf1ap.transportLayerAddressIPv6
    Log    Check IgNBCAUeContextSetupResponse has transport messages
    ${transport_addr}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should be empty   ${transport_addr}

######### check HO  #########
Check intergNB HO process on source gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${ip_target}=${xnap_gnb2}
    ####HandoverRequest
    Log To Console    HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.src == ${ip_source}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.src == ${ip_target}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 6
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6
    ####HandoverCancel
    Log To Console    HandoverCancel
    ${HO_Cancel}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 2 and xnap.XnAP_PDU == 0
    ...    xpath=.//nokiaxnap.procedureCode
    should not contain    ${HO_Cancel}    2
    ####UEContextReleaseCommand
    Log To Console    UEContextReleaseCommand
    ${UE_Cont_rel}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 6 and nokiaf1ap.radioNetwork == 10
    ...    xpath=.//nokiaf1ap.radioNetwork
    Should Be Equal    ${UE_Cont_rel[0]}    10
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC}=    Check wireshark log    logname=${logname}    message_filter=nokiaf1ap.procedureCode == 6 and nokiaf1ap.F1AP_PDU == 1
    ...    xpath=.//nokiaf1ap.F1AP_PDU
    should contain    ${UE_Cont_relC}    1


Check intergNB HO process on target gNB
    [Arguments]    ${logname}    ${ip_source}=${xnap_gnb1}    ${npap_ip_target}=${bts_host1}
    ####HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.dst == ${ip_source}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req[0]}    0
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 0 and ip.src == ${ip_source}
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    0
    ####PathSwitchRequest
    Log To Console    PathSwitchRequest
    ${PathS_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25 and ip.src == ${npap_ip_target}
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_req[0]}    25
    ####PathSwitchRequestAckonwledge
    Log To Console    PathSwitchRequestAckonwledge
    ${PathS_ACK}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 25 and ip.dst == ${npap_ip_target}
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${PathS_ACK[0]}    25
    ####UEContextRelease
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=nokiaxnap.procedureCode == 6
    ...    xpath=.//nokiaxnap.procedureCode
    Should Be Equal    ${UE_rel[0]}    6
    ####UEContextReleaseReq
    Log To Console    UEContextReleaseReq
    ${UE_contextreleasereq}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 42 and ngap.radioNetwork == 0
    ...    xpath=.//ngap.radioNetwork
    should not contain    ${UE_contextreleasereq}    0

Check intergNB NGHO process on source gNB
    [Arguments]    ${logname}
    ####HandoverRequest
    Log To Console    HandoverRequired
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 12 and ngap.radioNetwork == 16
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req[0]}    12
    ####HandoverRequestAckonwledge
    Log To Console    HandoverCommand
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}
    ...    message_filter=ngap.procedureCode == 12 and ngap.PDUSessionResourceHandoverList == 2
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    12
    ####UEContextReleaseCommand
    Log To Console    UEContextRelease
    ${UE_rel}=    Check wireshark log    logname=${logname}    message_filter=ngap.radioNetwork == 2 and ngap.procedureCode == 41
    ...    xpath=.//ngap.radioNetwork
    Should Be Equal    ${UE_rel[0]}    2
    ####UEContextReleaseCompleted
    Log To Console    UEContextReleaseCompleted
    ${UE_Cont_relC}=    Check wireshark log    logname=${logname}    message_filter=ngap.id == 10 and ngap.procedureCode == 41
    ...    xpath=.//ngap.id
    should contain    ${UE_Cont_relC}    10

Check intergNB NGHO process on target gNB
    [Arguments]    ${logname}
    ####HandoverRequest
    ${HO_req}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 13 and ngap.id == 29
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req[0]}    13
    ####HandoverRequestAckonwledge
    Log To Console    HandoverRequestAckonwledge
    ${HO_req_ACK}=    Check wireshark log    logname=${logname}
    ...    message_filter=ngap.procedureCode == 13 and ngap.PDUSessionResourceAdmittedList == 2
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HO_req_ACK[0]}    13
    ####DownlinkRANStatusTransfer
    Log To Console    PathSwitchRequest
    ${Transfer}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 7
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${Transfer[0]}    7
    ####HandoverNotify
    Log To Console    PathSwitchRequestAckonwledge
    ${HandoverNotify}=    Check wireshark log    logname=${logname}    message_filter=ngap.procedureCode == 11
    ...    xpath=.//ngap.procedureCode
    Should Be Equal    ${HandoverNotify[0]}    11

Check intra-F intra-gNB HO procedure
    [Arguments]    ${logname}    ${target_cell}    ${target_gnb}=${0}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measResultListNR == 1
    ...    ${xpath_filter}=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId
    ${pci_target}=    get required cell info   required_info=physicalCellId    cell_index=${target_cell}   gnb_index=${target_gnb}
    ${filtered_value}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=${xpath_filter}
    should be equal As Integers    ${filtered_value[0]}    ${pci_target}

Check wireshark log for Measurement EventA1 after HO
    [Arguments]    ${logname}    ${cell_index}=${1}    ${gnb_index}=${1}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 13 and nr-rrc.measId
    ...    ${xpath}=.//nr-rrc.physCellId
    ${pci_pcell}=    get required cell info   required_info=physicalCellId    cell_index=${cell_index}   gnb_index=${gnb_index}
    ${pci_pcell}    Convert to String    ${pci_pcell}
    Log    check Measurement message has physCellId
    ${physCellId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    List Should Contain Value   ${physCellId}    ${pci_pcell}

Check RRC Reconfiguration message after HO
    [Arguments]    ${logname}    ${event}=NULL    ${rsrp}=NULL
    ...    ${message_filter}=nokiaf1ap.procedureCode == 5 && nr-rrc.eventId == ${event}
    ...    ${xpath}=.//nr-rrc.eventId
    ...    ${xpath1}=.//nr-rrc.measTriggerQuantity.rsrp
    Log    check RRC Reconfiguration message has eventid and rsrp/rsrq config
    ${eventId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Contain    ${eventId}    ${event}
    ${rsrp_value}=    Run keyword If    '${rsrp}'!='NULL'    Check wireshark log
    ...    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    Run keyword If    '${rsrp}'!='NULL'    Should Contain   ${rsrp_value}    ${rsrp}

###Check A1/2 addition/release#####
Check IgNBCAAdditionRequest message has scellAdditionMethodIndicator
    [Arguments]    ${logname}    ${MethodIndicator}
    ...    ${message_filter}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.scellAdditionMethodIndicator
    Log    check IgNBCAAdditionRequest message has scellAdditionMethodIndicator
    ${Method}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${Method[0]}    ${MethodIndicator}

Check wireshark log for Measurement EventA1/A2
    [Arguments]    ${logname}    ${event}=0    ${rsrp}=NULL    ${rsrq}=NULL    ${pcell_index}=${1}    ${gnb_index}=${0}
    ...    ${event_id}=${3}
    Check RRC Reconfiguration message on PrimegNB    logname=${logname}    event=${event}    rsrp=${rsrp}    rsrq=${rsrq}
    Check Measurement message on PrimegNB    logname=${logname}    event_id=${event}    cell_index=${pcell_index}
    ...    gnb_index=${gnb_index}    event_id=${event_id}

Check RRC Reconfiguration message on PrimegNB
    [Arguments]    ${logname}    ${event}=NULL    ${rsrp}=NULL    ${rsrq}=NULL
    ...    ${message_filter}=nokiaf1ap.procedureCode == 12 && nr-rrc.eventId == ${event}
    ...    ${xpath}=.//nr-rrc.eventId
    ...    ${xpath1}=.//nr-rrc.measTriggerQuantity.rsrp
    ...    ${xpath2}=.//nr-rrc.measTriggerQuantity.rsrq
    Log    check RRC Reconfiguration message has eventid and rsrp/rsrq config
    ${eventId}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should contain    ${eventId}    ${event}
    ${rsrp_value}=    Run keyword If    '${rsrp}'!='NULL'    Check wireshark log
    ...    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    Run keyword If    '${rsrp}'!='NULL'    Should contain    ${rsrp_value}    ${rsrp}
    ${rsrq_value}=    Run keyword If    '${rsrq}'!='NULL'    Check wireshark log
    ...    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    Run keyword If    '${rsrq}'!='NULL'    Should contain    ${rsrq_value}    ${rsrq}

Check IgNBCAUeContextModificationRequest message has scell ToBeRemoved
    [Arguments]    ${logname}    ${release_cell}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.id == 61721
    ...    ${xpath}=.//nokiaf1ap.nRCellIdentity
    Log    check IgNBCAUeContextModificationRequest message has scell ToBeRemoved
    ${result}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ...    attribute_name=showname
    ${result_Hex}=    Split String    ${result[0]}    value
    ${result_Hex}=    Strip String    ${result_Hex[-1]}
    ${result_Hex}=    Remove String    ${result_Hex}    ]
    ${result_Hex}    Convert To Integer    ${result_Hex}
    ${release_cell}    Convert To Integer    ${release_cell}
    should be equal As Integers    ${result_Hex}    ${release_cell}

Check IgNBCAUeContextModificationResponse message has scell ToBeRemoved
    [Arguments]    ${logname}    ${scelllcird}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 1 and nr-rrc.SCellIndex
    ...    ${xpath}=.//nr-rrc.SCellIndex
    Log    check IgNBCAUeContextModificationResponse message has scell ToBeRemoved
    ${SCellIndex}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${SCellIndex[0]}    ${scelllcird}

Check has no IgnbCAUeContextModificationRequest and IgNBCAAdditionRequest message
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.Nokia_F1AP_PDU == 0 and nokiaf1ap.id == 61721
    ...    ${message_filter1}=nokiaxnap.Nokia_XnAP_PDU == 0 and nokiaxnap.procedureCode == 140
    ...    ${xpath}=.//nokiaxnap.scellAdditionMethodIndicator
    ...    ${xpath1}=.//nokiaf1ap.nRCellIdentity
    Log    check IgNBCAAdditionRequest message has scellAdditionMethodIndicator
    ${Message1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${Message2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    Should Be Empty    ${Message1}
    Should Be Empty    ${Message2}

#Check IgNBCAReleaseRequest message on PrimegNB
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.radioNetwork == 65
#    ...    ${xpath}=.//nokiaxnap.radioNetwork
#    ...    ${xpath1}=.//nokiaxnap.Ext_gNB_CU_UE_XnAP_ID
#    Log    check IgNBCAReleaseRequest has the normal-release(65) message
#    ${radioNetwork}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${radioNetwork[0]}    65
#    Log    check IgNBCAReleaseRequest Ext-gNB-CU-UE-XnAP-ID
#    ${xnap_id_request}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    set suite variable    ${xnap_id_request}

#Check IgNBCAReleaseRequestAcknowledge message on PrimegNB
#    [Arguments]    ${logname}
#    ...    ${message_filter}=nokiaxnap.procedureCode == 142 and nokiaxnap.Nokia_XnAP_PDU == 1
#    ...    ${xpath}=.//nokiaxnap.Ext_gNB_CU_UE_XnAP_ID
#    Log    check IgNBCAReleaseRequestAcknowledge message
#    ${xnap_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    should be equal    ${xnap_id}    ${xnap_id_request}

####Check graceful shutdown reset#####
Check F1ap reset messages
    [Arguments]    ${logname}    ${num}=${1}
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 0 and nokiaf1ap.F1AP_PDU == 0
    ...    ${xpath}=.//nokiaf1ap.gNB_CU_UE_F1AP_ID
    ...    ${xpath1}=.//nokiaf1ap.ResetType
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 0 and nokiaf1ap.F1AP_PDU == 1
    ...    ${xpath2}=.//nokiaf1ap.gNB_CU_UE_F1AP_ID
    Log    Check F1ap has reset messages on PrimegNB
    ${reset_f1ap}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${reset_num}    Get length    ${reset_f1ap}
    Should be equal    ${reset_num}    ${num}
    ${reset_cause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    Should be equal   ${reset_cause}[0]    1
    ${reset_ACK}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    ${reset_ACK_num}    Get length    ${reset_ACK}
    Should be equal    ${reset_ACK_num}    ${num}

Check E1ap reset messages in Primegnb
    [Arguments]    ${logname}    ${num}=${1}
    ...    ${message_filter1}=e1ap.procedureCode == 0 and e1ap.E1AP_PDU == 0
    ...    ${xpath1}=.//e1ap.Reset_element
    ...    ${message_filter2}=e1ap.procedureCode == 0 and e1ap.E1AP_PDU == 1
    ...    ${xpath2}=.//e1ap.ResetAcknowledge_element
    Log    Check E1ap has reset messages on PrimegNB
    ${reset_e1ap}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ...    attribute_name=showname
    Should Contain X Times   ${reset_e1ap}    Reset    ${num}
    ${reset_ACK}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    ...    attribute_name=showname
    Should Contain X Times   ${reset_ACK}   ResetAcknowledge    ${num}

Check NGap reset messages in Primegnb
    [Arguments]    ${logname}    ${num}=${1}
    ...    ${message_filter1}=ngap.procedureCode == 20 and ngap.NGAP_PDU == 0 and ngap.radioNetwork == 3
    ...    ${xpath1}=.//ngap.NGReset_element
    ...    ${message_filter2}=ngap.procedureCode == 20 and ngap.NGAP_PDU == 1
    ...    ${xpath2}=.//ngap.NGResetAcknowledge_element
    Log    Check NGap has reset messages
    ${reset_NGap}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ...    attribute_name=showname
    Should Contain X Times   ${reset_NGap}    NGReset    ${num}
    ${reset_ACK}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    ...    attribute_name=showname
    Should Contain X Times   ${reset_ACK}   NGResetAcknowledge    ${num}

Check XNap reset messages
    [Arguments]    ${logname}    ${ip.src}    ${ip.dst}    ${num}=${1}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 20 and ip.src ==${ip.src} and ip.dst == ${ip.dst}
    ...    ${message_filter2}=nokiaxnap.procedureCode == 20 and ip.src ==${ip.dst} and ip.dst == ${ip.src}
    ...    ${xpath1}=.//nokiaxnap.ResetRequest_element
    ...    ${xpath2}=.//nokiaxnap.ResetResponse_element
    Log    Check XNap has reset messages
    ${reset_Xnap}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ...    attribute_name=showname
    Should Contain X Times   ${reset_Xnap}    ResetRequest    ${num}
    ${reset_ACK}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    ...    attribute_name=showname
    Should Contain X Times   ${reset_ACK}   ResetResponse    ${num}

Check XNap update messages
    [Arguments]    ${logname}    ${ip.src}    ${ip.dst}    ${lcrid_pcell_cell}=${1}     ${gnb_index_pcell}=${0}
    ...    ${server_cell_num}= ${1}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 18 and ip.src ==${ip.src} and ip.dst == ${ip.dst}
    ...    ${xpath}=.//nokiaxnap.NGRANNodeConfigurationUpdate_element
    ...    ${xpath1}=.//nokiaxnap.NR_Cell_Identity
    ...    ${message_filter2}=nokiaxnap.procedureCode == 18 and ip.src ==${ip.dst} and ip.dst == ${ip.src}
    ...    ${xpath2}=.//nokiaxnap.NGRANNodeConfigurationUpdateAcknowledge_element
    Log    Check XNap has uodate messages
    ${primecell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid_pcell_cell}    gnb_index=${gnb_index_pcell}
    ${Update}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ...    attribute_name=showname
    Should be equal   ${Update}[0]   NGRANNodeConfigurationUpdate
    ${Pcell_id_HEX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
#    ${Pcell_id}    Convert To Integer    ${Pcell_id_HEX[0]}
    ${Pcell_id_list}    Create List
    FOR    ${index}    IN RANGE   ${server_cell_num}
        ${Pcell_id}    Convert To Integer    ${Pcell_id_HEX[${index}]}
        append to list    ${Pcell_id_list}    ${Pcell_id}
    END
    Should Contain    ${Pcell_id_list}    ${primecell1_id}
    ${Update_ACK}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    ...    attribute_name=showname
    Should be equal   ${Update_ACK}[0]   NGRANNodeConfigurationUpdateAcknowledge

Check XNap IgNbCAconfigurationUpdateIndication messages
    [Arguments]    ${logname}    ${lcrid_shutdown_cell}=${2}    ${gnb_index_shutdown}=${2}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.cell_Availability
    ...    ${xpath}=.//nokiaxnap.cell_Availability
    ...    ${xpath1}=.//nokiaxnap.NR_Cell_Identity
    ${SHUTDOWN_cell_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid_shutdown_cell}    gnb_index=${gnb_index_shutdown}
    Log    XNap IgNbCAconfigurationUpdateIndication messages
    ${scell_status}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${scell_status[0]}    0
    ${Scell_id_HEX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${Scell_id}    Convert To Integer    ${Scell_id_HEX[0]}
    Should be equal   ${scell_id}    ${SHUTDOWN_cell_id}

Check XNap IgNbCAconfigurationUpdateIndication has scell remove
    [Arguments]    ${logname}    ${lcrid_remove_cell}=${2}    ${gnb_index_remove}=${1}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.cellsToRemove == 1
    ...    ${xpath}=.//nokiaxnap.NR_Cell_Identity
    ${Remove_cell_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid_remove_cell}    gnb_index=${gnb_index_remove}
    Log    XNap IgNbCAconfigurationUpdateIndication has scell remove
    ${Scell_id_HEX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${Scell_id}    Convert To Integer    ${Scell_id_HEX[0]}
    Should be equal   ${scell_id}    ${Remove_cell_id}

######### check RRC reestablishment #########
Check UEContextModifucationRequest message
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.TransmissionActionIndicator == 1 and nokiaf1ap.RRCReconfigurationCompleteIndicator == 0
    ...    ${xpath}=.//nokiaf1ap.RRCReconfigurationCompleteIndicator
    Log    Check UEContextModifucationRequest has RRCReconfigurationCompleteIndicator
    ${UEContextModifucationRequest}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=${xpath}
    should be equal    ${UEContextModifucationRequest[0]}    0

Check RRC Reestablishment to a cell
    [Arguments]    ${logname}    ${source_cell_index}=${2}    ${target_cell_index}=${2}
    ...    ${source_gnb_index}=${1}    ${target_gnb_index}=${0}
    ...    ${message_filter}=nr-rrc.reestablishmentCause == 2 && nr-rrc.c1 == 2
    ${RRE_target_cell_id}=    COAM Get nrcellid with lcrid    lcrid=${target_cell_index}    gnb_index=${target_gnb_index}
    ${RRE_source_cell_PCI}=    get required cell info   required_info=physicalCellId
    ...    cell_index=${source_cell_index}   gnb_index=${source_gnb_index}
    Log    check RRC Reestablishment has other failure
    ${rrestablishmentCause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=.//nr-rrc.reestablishmentCause
    should be equal    ${rrestablishmentCause[0]}    2
    Log    check RRC Reestablishment has source physcellid
    ${physcellid_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=.//nr-rrc.physCellId
    Should be equal As Integers    ${physcellid_id[0]}    ${RRE_source_cell_PCI}
    Log    check RRC Reestablishment has target cellid
    ${cell_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=.//nokiaf1ap.nRCellIdentity
    ...    attribute_name=showname
    ${cell_id_Hex}=    Split String    ${cell_id[0]}    value
    ${cell_id_Hex}=    Strip String    ${cell_id_Hex[-1]}
    ${cell_id_Hex}=    Remove String    ${cell_id_Hex}    ]
    Should be equal As Integers    ${cell_id_Hex}    ${RRE_target_cell_id}

Check RRC Reestablishment single cell successful
    [Arguments]    ${logname}
    ...    ${message_filter1}=ngap.procedureCode == 14 and ngap.pDUSessionID == 1 and ngap.pDUSessionID == 2
    ...    ${xpath}=.//ngap.InitialContextSetupResponse_element
    Log    RRC Reestablishment ssingle cell successful
    ${ICSR}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ...    attribute_name=showname
    Should be equal   ${ICSR}[0]    InitialContextSetupResponse

Check IgNBCARemoval messages
    [Arguments]    ${logname}    ${ip.src}    ${ip.dst}
    ...    ${message_filter1}=nokiaxnap.procedureCode == 144 and ip.src ==${ip.src} and ip.dst == ${ip.dst}
    ...    ${xpath1}=.//nokiaxnap.IgNBCARemovalRequest_element
    ...    ${message_filter2}=nokiaxnap.procedureCode == 144 and ip.src ==${ip.dst} and ip.dst == ${ip.src}
    ...    ${xpath2}=.//nokiaxnap.IgNBCARemovalResponse_element
    ...    ${message_filter3}=nokiaf1ap.procedureCode == 202 and nokiaf1ap.Nokia_F1AP_PDU == 0
    ...    ${xpath3}=.//nokiaf1ap.IgNBCAXpRemovalRequest_element
    ...    ${message_filter4}=nokiaf1ap.procedureCode == 202 and nokiaf1ap.Nokia_F1AP_PDU == 1
    ...    ${xpath4}=.//nokiaf1ap.IgNBCAXpRemovalResponse_element
    Log    Check IgNBCARemoval messages
    ${Remove_req}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ...    attribute_name=showname
    Should be equal   ${Remove_req}[0]   IgNBCARemovalRequest
    ${Remove_res}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    ...    attribute_name=showname
    Should be equal   ${Remove_res}[0]   IgNBCARemovalResponse
    ${xp_Remove_req}=    Check wireshark log    logname=${logname}    message_filter=${message_filter3}    xpath=${xpath3}
    ...    attribute_name=showname
    Should be equal   ${xp_Remove_req}[0]   IgNBCAXpRemovalRequest
    ${xp_Remove_res}=    Check wireshark log    logname=${logname}    message_filter=${message_filter4}    xpath=${xpath4}
    ...    attribute_name=showname
    Should be equal   ${xp_Remove_res}[0]   IgNBCAXpRemovalResponse

Check IgNBCAResourceStatusUpdate message existence or not
    [Arguments]    ${logname}    ${ip.src}    ${ip.dst}    ${exoect_value}=NULL
    ...    ${message_filter}=nokiaxnap.procedureCode == 139 and ip.src ==${ip.src} and ip.dst == ${ip.dst}
    ...    ${xpath}=.//nokiaxnap.procedureCode
    ${IgNBCAResource_Update}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ...    attribute_name=showname
    Run Keyword IF   '${exoect_value}'=='NULL'    Should be empty   ${IgNBCAResource_Update}
    ...    ELSE    Should be equal    ${IgNBCAResource_Update[0]}     ${exoect_value}

####counter###
Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get gnb time    gnb_index=${gnb_index}
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

get_release_for_TMO_release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info_TMO}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}_${info.split('_')[4]}
    [Return]    ${release_info_TMO}

### Check BCS #####
Check IgNBCAAdditionRequest message has no the BCS IE on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaxnap.allowUnsuppBcOrBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Be Empty    ${allowUnsuppBcOrBcs}

Check IgNBCAAdditionRequest message has the BCS IE on PrimegNB
    [Arguments]    ${logname}    ${allowBcs}=60    ${rejectBcs}=1
    ...    ${message_filter}=nokiaxnap.procedureCode == 22 and nokiaxnap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaxnap.allowUnsuppBcOrBcs
    ...    ${xpath1}=.//nokiaxnap.rejectSuppBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${rejectSuppBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${allowUnsuppBcOrBcs[0]}    ${allowBcs}
    should be equal    ${rejectSuppBcs[0]}    ${rejectBcs}

Check IgNBCAUEContextSetupRequest message has no the BCS IE on extgNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaf1ap.allowUnsuppBcOrBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    Should Be Empty    ${allowUnsuppBcOrBcs}

Check IgNBCAUEContextSetupRequest message has the BCS IE on extgNB
    [Arguments]    ${logname}    ${allowBcs}=60    ${rejectBcs}=1
    ...    ${message_filter}=nokiaf1ap.procedureCode == 14 and nokiaf1ap.allowUnsuppBcOrBcs
    ...    ${xpath}=.//nokiaf1ap.allowUnsuppBcOrBcs
    ...    ${xpath1}=.//nokiaf1ap.rejectSuppBcs
    Log    Check IgNBCAAdditionRequest message has no the BCS IE
    ${allowUnsuppBcOrBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${rejectSuppBcs}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${allowUnsuppBcOrBcs[0]}    ${allowBcs}
    should be equal    ${rejectSuppBcs[0]}    ${rejectBcs}

Check IgNBCAGnbDuConfigurationIndication message has release scellid on Prime gNB
    [Arguments]    ${logname}    ${gnb_index}=${3}    ${lcrid}=${2}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 195 and nokiaf1ap.nRCellIdentity
    ...    ${xpath}=.//nokiaf1ap.SCells_Required_To_Be_UnBlocked_Item_element/nokiaf1ap.sCell_ID_element/nokiaf1ap.nRCellIdentity
    ${scell_id_release}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}    gnb_index=${gnb_index}
    Log    IgNBCAGnbDuConfigurationIndication message has release scellid
    ${scell_id}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ...    attribute_name=showname
    ${scell_id_Hex}=    Split String    ${scell_id[0]}    value
    ${scell_id_Hex}=    Strip String    ${scell_id_Hex[-1]}
    ${scell_id_Hex}=    Remove String    ${scell_id_Hex}    ]
    should be equal As Integers    ${scell_id_Hex}    ${scell_id_release}

### Check DRX #####
Check UEContextModificationRequest message has Drx release on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nokiaf1ap.DRXConfigurationIndicator == 0
    ...    ${xpath}=.//nokiaf1ap.DRXConfigurationIndicator
    Log    Check UEContextModificationRequest message has Drx release
    ${DRX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${DRX[0]}   0

Check IgNBCAModificationRequest message has Drx release on PrimegNB
    [Arguments]    ${logname}
    ...    ${message_filter}=nokiaxnap.procedureCode == 141 and nokiaxnap.DRXConfigurationIndicator == 0
    ...    ${xpath}=.//nokiaxnap.DRXConfigurationIndicator
    Log    IgNBCAModificationRequest message has Drx release
    ${DRX}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    should be equal    ${DRX[0]}   0

Check DRX disable on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds}=8
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 1 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    Log    Check ANR DRX enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    Should be equal    ${DRX_milliSeconds[0]}    ${milliSeconds}
    Should be equal    ${DRX_milliSeconds1[0]}    ${milliSeconds}
#    Should be equal    ${DRX_milliSeconds2[0]}    ${milliSeconds}

Check ANR DRX enable on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds}=8    ${InactivityTimer}=14    ${StartOffset}=11
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds == ${milliSeconds}
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds == ${milliSeconds}
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 1 and nr-rrc.milliSeconds == ${milliSeconds}
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    Log    Check ANR DRX enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${DRX_InactivityTimer1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${DRX_InactivityTimer2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    ${DRX_StartOffset_1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath2}
    ${DRX_StartOffset_2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    Should be equal    ${DRX_milliSeconds}[0]   ${milliSeconds}
    Should be equal    ${DRX_milliSeconds1}[0]    ${milliSeconds}
#    Should be equal    ${DRX_milliSeconds2}[0]    ${milliSeconds}
    Should be equal    ${DRX_InactivityTimer}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer1}[0]    ${InactivityTimer}
#    Should be equal    ${DRX_InactivityTimer2}[0]    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_1}[0]    ${StartOffset}
#    Should be equal    ${DRX_StartOffset_2}[0]    ${StartOffset}

Check VONR DRX enable on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds1}=5    ${milliSeconds2}=17     ${InactivityTimer}=14    ${StartOffset}=9
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check VONR drx enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    ${DRX_InactivityTimer1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${DRX_InactivityTimer2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
#    ${DRX_StartOffset_1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath2}
    ${DRX_StartOffset_2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    Should Contain any    ${DRX_milliSeconds}[0]    ${milliSeconds1}    ${milliSeconds2}
#    Should Contain any   ${DRX_milliSeconds1}[0]    ${milliSeconds1}    ${milliSeconds2}
    Should Contain any    ${DRX_milliSeconds2}[0]    ${milliSeconds1}    ${milliSeconds2}
    Should Contain any    ${DRX_milliSeconds2}[1]    ${milliSeconds1}    ${milliSeconds2}
    Should be equal    ${DRX_InactivityTimer}[0]    ${InactivityTimer}
#    Should be equal    ${DRX_InactivityTimer1}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[1]    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset}[0]    ${StartOffset}
#    Should be equal    ${DRX_StartOffset_1}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[1]    ${StartOffset}

Check DRX enable on PrimegNB or Externgnb
    [Arguments]    ${logname}    ${milliSeconds}=17    ${milliSeconds2}=${milliSeconds}    ${InactivityTimer}=14    ${StartOffset}=13
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check DRX enable
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    Should Contain any    ${DRX_milliSeconds[0]}   ${milliSeconds}    ${milliSeconds2}
    Should be equal    ${DRX_InactivityTimer[0]}    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset[0]}   ${StartOffset}

Check DRX recover as attach on PrimegNB
    [Arguments]    ${logname}    ${milliSeconds}=17    ${InactivityTimer}=14    ${StartOffset}=13
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${message_filter2}=nokiaf1ap.procedureCode == 7 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.drx_InactivityTimer
    ...    ${xpath2}=.//nr-rrc.drx_LongCycleStartOffset
    Log    Check ANR DRX recover by A1
    ${DRX_milliSeconds}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
#    ${DRX_milliSeconds1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    ${DRX_milliSeconds2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath}
    ${DRX_InactivityTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    ${DRX_InactivityTimer1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${DRX_InactivityTimer2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath1}
    ${DRX_StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
#    ${DRX_StartOffset_1}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath2}
    ${DRX_StartOffset_2}=    Check wireshark log    logname=${logname}    message_filter=${message_filter2}    xpath=${xpath2}
    Should be equal    ${DRX_milliSeconds}[0]   ${milliSeconds}
#    Should be equal    ${DRX_milliSeconds1}[0]    ${milliSeconds}
    Should be equal    ${DRX_milliSeconds2}[0]    ${milliSeconds}
    Should be equal    ${DRX_milliSeconds2}[1]    ${milliSeconds}
    Should be equal    ${DRX_InactivityTimer}[0]    ${InactivityTimer}
#    Should be equal    ${DRX_InactivityTimer1}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[0]    ${InactivityTimer}
    Should be equal    ${DRX_InactivityTimer2}[1]    ${InactivityTimer}
    Should be equal    ${DRX_StartOffset}[0]    ${StartOffset}
#    Should be equal    ${DRX_StartOffset_1}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[0]    ${StartOffset}
    Should be equal    ${DRX_StartOffset_2}[1]    ${StartOffset}

Check CSIRS and CSI-reporting in onduration in UEContextModificationResponse
    [Arguments]    ${logname}   ${scell_num}=2   ${cycle}=20
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.csi_IM_ResourceId == 0
    ...    ${xpath}=.//nr-rrc.periodicityAndOffset/nr-rrc.slots20
    ...    ${message_filter1}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.reportConfigId == 0
    ...    ${xpath1}=.//nr-rrc.reportSlotConfig/nr-rrc.slots160
    ...    ${xpath2}=.//nr-rrc.ms160
    ${onduratin}    Get onduration slot    logname=${logname}    xpath1=${xpath2}
    ${onduratin_start}    Set variable    ${onduratin}[0]
    ${OndurationTimer}    Set variable    ${onduratin}[1]
    Log    check pcell's CSIRS period
    ${onduratin_start_CSIRS}=    Run Keyword IF    ${onduratin_start} >= 20    Evaluate    ${onduratin_start}%20
    ...    ELSE    Set Variable    ${onduratin_start}
    ${onduratin_end_CSIRS}=    Evaluate    ${onduratin_start_CSIRS} + ${ondurationTimer}
    ${value}    Run Keyword IF   ${onduratin_end_CSIRS} > 20    Evaluate    ${onduratin_end_CSIRS} - 20
    ...    ELSE    Set Variable    ${0}
    ${pcell_CSIRS}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ${pcell_CSIRS}=    Run Keyword IF    ${pcell_CSIRS}[0] < ${value}  Evaluate    ${pcell_CSIRS}[0]+20
    ...    ELSE IF    ${pcell_CSIRS}[0] > ${onduratin_end_CSIRS}    Evaluate    ${pcell_CSIRS}[0]%20
    ...    ELSE   Set Variable    ${pcell_CSIRS}[0]
    Should Be True    ${onduratin_start_CSIRS} <= ${pcell_CSIRS} < ${onduratin_end_CSIRS}
    Log    check pcell's CSI-report period
    ${onduratin_start_report}=    Run Keyword IF    ${onduratin_start} >= ${cycle}    Evaluate    ${onduratin_start}%${cycle}
    ...    ELSE    Set Variable    ${onduratin_start}
    ${onduratin_end_report}=    Evaluate    ${onduratin_start_report} + ${ondurationTimer}
    ${value_report}    Run Keyword IF   ${onduratin_end_report} > ${cycle}    Evaluate    ${onduratin_end_report} - ${cycle}
    ...    ELSE    Set Variable    ${0}
    ${pcell_CSI-report}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath1}
    ${pcell_CSI-report}=    Run Keyword IF    ${pcell_CSI-report}[0] < ${value}  Evaluate    ${pcell_CSI-report}[0]+${cycle}
    ...    ELSE IF    ${pcell_CSI-report}[0] > ${onduratin_end_report}    Evaluate    ${pcell_CSI-report}[0]%${cycle}
    ...    ELSE    Set Variable    ${pcell_CSI-report}[0]
    Should Be True    ${onduratin_start_report} <= ${pcell_CSI-report} < ${onduratin_end_report}
    [Return]

Get onduration slot
     [Arguments]    ${logname}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 193 and nr-rrc.milliSeconds
    ...    ${xpath}=.//nr-rrc.milliSeconds
    ...    ${xpath1}=.//nr-rrc.ms160
         Log    get OndurationTimer
    ${OndurationTimer}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath}
    ...    attribute_name=showname
    ${OndurationTimer}=    Split String    ${OndurationTimer[0]}    :
    ${OndurationTimer}=    Strip String    ${OndurationTimer[-1]}
    ${OndurationTimer}=    Split String    ${OndurationTimer}    (
    ${OndurationTimer}=    Remove String    ${OndurationTimer[0]}    ms
    Log    get start offset
    ${StartOffset}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
#    ${onduratin_end}=    Evaluate    ${StartOffset} + ${ondurationTimer}
    [Return]    ${StartOffset}[0]    ${OndurationTimer}

Check 2200 enable with Scell when attach
    [Arguments]    ${logname}    ${scell_num}=2    ${cycle}=80
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.drx_Config == 1
    ...    ${xpath}=.//nr-rrc.ms160    ${index}=${3}    ${CSI_RS_index}=${1}
    ...    ${pscell_Meas}=.//nr-rrc.spCellConfigDedicated_element/nr-rrc.csi_MeasConfig/nr-rrc.setup_element/nr-rrc.csi_ReportConfigToAddModList
    ...    ${CSIRS_reporting}=/_[${index}]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element/nr-rrc.reportSlotConfig
    ...    ${xpath_scell1_CSIRS_reporting}=${pscell_Meas}${CSIRS_reporting}/nr-rrc.slots160
    ...    ${xpath_nrofPorts}=/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ...    ${xpath_scell1_CSIRS_slot}=/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.periodicityAndOffset/nr-rrc.slots80
    ${onduratin}    Get onduration slot    logname=${logname}    cycle=${cycle}    xpath1=${xpath}
    ${onduratin_start}    Set variable    ${onduratin}[0]
    ${onduratin_end}    Set variable    ${onduratin}[1]
    ${scell1_CSIRS_reporting}=    Check wireshark log    logname=${logname}
    ...    message_filter=${message_filter}    xpath=${xpath_scell1_CSIRS_reporting}
    @{2200_ports_list}    Create List
    @{CSIRS_slot_list}    Create List
    FOR    ${CSI_RS_index}    IN RANGE    1    5
        ${2200_ports}    Get scell CSIRS Resource with enable 2200   logname=${logname}
        ...    index=${CSI_RS_index}   scell_num=${scell_num}    xpath=${xpath_nrofPorts}
        Append TO List    ${2200_ports_list}    ${2200_ports}[0]
    END
    ${2200_ports_num}    Count values In list    ${2200_ports_list}   3
    FOR    ${CSI_RS_index}    IN RANGE    1    ${2200_ports_num}+1
        ${CSIRS_slot_list_1}    Get scell CSIRS Resource with enable 2200   logname=${logname}
        ...    index=${CSI_RS_index}   scell_num=${scell_num}    xpath=${xpath_scell1_CSIRS_slot}
        Append TO List    ${CSIRS_slot_list}    ${CSIRS_slot_list_1}[0]
    END
    Run Keyword IF    ${2200_ports_num} == ${1}    Run Keywords
    ...    Should Be True    ${onduratin_start} <= ${CSIRS_slot_list}[0] < ${onduratin_end}    AND
    ...    Should Be True    ${onduratin_start} <= ${scell1_CSIRS_reporting}[0] < ${onduratin_end}
    ...    ELSE IF    ${2200_ports_num} == ${2}    Run keywords
    ...    Should Be True    ${onduratin_start} <= ${CSIRS_slot_list}[0] < ${onduratin_end}    AND
    ...    Should Be True    ${onduratin_start} <= ${CSIRS_slot_list}[1] < ${onduratin_end}    AND
    ...    Should Be True    ${onduratin_start} <= ${scell1_CSIRS_reporting}[0] < ${onduratin_end}
    ...    ELSE    Should Be True    ${2200_ports_num} == ${4}

Get scell CSIRS Resource with enable 2200
    [Arguments]    ${logname}    ${scell_num}=2   ${index}=${1}
    ...    ${message_filter}=nokiaf1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == ${scell_num} and nr-rrc.drx_Config == 1
    ...    ${scell1_Meas}=.//nr-rrc.sCellToAddModList/_[1]/nr-rrc.SCellConfig_element/nr-rrc.sCellConfigDedicated_element/nr-rrc.csi_MeasConfig
    ...    ${scell1_CSRIS}= /nr-rrc.setup_element/nr-rrc.nzp_CSI_RS_ResourceToAddModList
    ...    ${xpath}=/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ${CSIRS Resource}    Check wireshark log    logname=${logname}    message_filter=${message_filter}
    ...    xpath=${scell1_Meas}${scell1_CSRIS}/_[${index}]${xpath}
    [Return]    ${CSIRS Resource}

Hanging resource test
    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${gnb_list}=all    ${recovery_cell}=False
    ...    ${ue_index}=${ue_index_${gnb_instance0}}    ${ue_index_hanningresource}=${ue_index_hanningresource_${gnb_instance0}}
    [Documentation]    hanging resource test
    [Timeout]    1hour
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}
    ...    pc_ip=${tl.ues[${ue_index_hanningresource}].ssh_connection_details.addr}
    ...    pc_name=${tl.ues[${ue_index_hanningresource}].ssh_connection_details.username}
    ...    pc_pwd=${tl.ues[${ue_index_hanningresource}].ssh_connection_details.password}
    ...    gnb_list=${gnb_list}    recovery_cell=${recovery_cell}

Cell Should Be Lock or Unlock
    [Arguments]    ${gnb_index}=${0}    ${cell_idx}=${1}    ${cell_group_idx}=${0}    ${is_locked}=True
    Connect to gnb coam via ssl    bts_host=${bts_host${gnb_index}}
    Run keyword If    ${is_locked}==True    Cell Should Be Locked
    ...    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
    ...    ELSE    Cell Should Be UnLocked    cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
