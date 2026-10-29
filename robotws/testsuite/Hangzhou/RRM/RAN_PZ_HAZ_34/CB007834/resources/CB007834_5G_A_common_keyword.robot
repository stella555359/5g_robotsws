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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG3/Resource/UUF_Sleep_cell_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Baseband_module_reset_via_WEBUI.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/ru_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.py


*** Variables ***
${ue_type}           ${tl.ues[0].capabilities[0]}
${ue_index}     0
${tl_scf_dir_path}    /opt/workspace/SCF/
${gnb_instance}    ${tl.gnbs[0].instance_id}
${gnb2_instance}    ${tl.gnbs[1].instance_id}
${att_port_1_cell21_36311}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_2_cell21_36311}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_3_cell21_36311}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_4_cell21_36311}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_1_cell22_36311}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_2_cell22_36311}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_3_cell22_36311}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_4_cell22_36311}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_1_cell23_36311}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_cell23_36311}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_cell23_36311}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_cell23_36311}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_cell24_36311}                ${tl.attenuator[3].attenuator_ports[9]}
${att_port_2_cell24_36311}                ${tl.attenuator[3].attenuator_ports[10]}
${att_port_3_cell24_36311}                ${tl.attenuator[3].attenuator_ports[11]}
${att_port_4_cell24_36311}                ${tl.attenuator[3].attenuator_ports[12]}
${att_port_1_cell1_36311}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_cell1_36311}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_1_cell2_36311}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_2_cell2_36311}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_cell3_36311}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_cell3_36311}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_1_cell4_36311}                ${tl.attenuator[3].attenuator_ports[13]}
${att_port_2_cell4_36311}                ${tl.attenuator[3].attenuator_ports[14]}
${att_port_3_cell4_36311}                ${tl.attenuator[3].attenuator_ports[15]}
${att_port_4_cell4_36311}                ${tl.attenuator[3].attenuator_ports[16]}
${att_port_1_cell301_36311}                ${tl.attenuator[1].attenuator_ports[13]}
${att_port_2_cell301_36311}                ${tl.attenuator[1].attenuator_ports[14]}
${att_port_3_cell301_36311}                ${tl.attenuator[1].attenuator_ports[15]}
${att_port_4_cell301_36311}                ${tl.attenuator[1].attenuator_ports[16]}
${att_port_1_cell302_36311}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_2_cell302_36311}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_3_cell302_36311}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_4_cell302_36311}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_1_cell303_36311}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell303_36311}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell303_36311}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell303_36311}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2cell1_36311}                ${tl.attenuator[4].attenuator_ports[1]}
${att_port_2_gnb2cell1_36311}                ${tl.attenuator[4].attenuator_ports[2]}
${att_port_3_gnb2cell1_36311}                ${tl.attenuator[4].attenuator_ports[3]}
${att_port_4_gnb2cell1_36311}                ${tl.attenuator[4].attenuator_ports[4]}
${att_ipaddr_cell21_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell22_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell23_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell24_36311}                ${tl.attenuator[3].ip_addr}
${att_ipaddr_cell1_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell2_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell3_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell4_36311}                ${tl.attenuator[3].ip_addr}
${att_ipaddr_cell301_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell302_36311}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell303_36311}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2cell1_36311}                ${tl.attenuator[4].ip_addr}

${att_port_1_cell1_357}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_cell1_357}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_cell1_357}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_cell1_357}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_cell2_357}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_cell2_357}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_cell2_357}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_cell2_357}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_cell3_357}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_cell3_357}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_cell3_357}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_cell3_357}                ${tl.attenuator[1].attenuator_ports[12]}
${att_port_1_cell11_357}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_cell11_357}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_cell11_357}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_cell11_357}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_cell12_357}                ${tl.attenuator[1].attenuator_ports[13]}
${att_port_2_cell12_357}                ${tl.attenuator[1].attenuator_ports[14]}
${att_port_3_cell12_357}                ${tl.attenuator[1].attenuator_ports[15]}
${att_port_4_cell12_357}                ${tl.attenuator[1].attenuator_ports[16]}
${att_port_1_cell13_357}                ${tl.attenuator[2].attenuator_ports[1]}
${att_port_2_cell13_357}                ${tl.attenuator[2].attenuator_ports[2]}
${att_port_3_cell13_357}                ${tl.attenuator[2].attenuator_ports[3]}
${att_port_4_cell13_357}                ${tl.attenuator[2].attenuator_ports[4]}
${att_port_1_cell301_357}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_cell301_357}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_cell301_357}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_cell301_357}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_1_cell302_357}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_cell302_357}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_cell302_357}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_cell302_357}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_cell303_357}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_cell303_357}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_cell303_357}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_cell303_357}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_cell353_357}                ${tl.attenuator[2].attenuator_ports[5]}
${att_port_2_cell353_357}                ${tl.attenuator[2].attenuator_ports[6]}
${att_port_3_cell353_357}                ${tl.attenuator[2].attenuator_ports[7]}
${att_port_4_cell353_357}                ${tl.attenuator[2].attenuator_ports[8]}
${att_port_1_cell352_357}                ${tl.attenuator[2].attenuator_ports[9]}
${att_port_2_cell352_357}                ${tl.attenuator[2].attenuator_ports[10]}
${att_port_3_cell352_357}                ${tl.attenuator[2].attenuator_ports[11]}
${att_port_4_cell352_357}                ${tl.attenuator[2].attenuator_ports[12]}
${att_port_1_cell351_357}                ${tl.attenuator[2].attenuator_ports[13]}
${att_port_2_cell351_357}                ${tl.attenuator[2].attenuator_ports[14]}
${att_port_3_cell351_357}                ${tl.attenuator[2].attenuator_ports[15]}
${att_port_4_cell351_357}                ${tl.attenuator[2].attenuator_ports[16]}
${att_ipaddr_cell1_357}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell2_357}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell3_357}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell11_357}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell12_357}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_cell13_357}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_cell301_357}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell302_357}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell303_357}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_cell351_357}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_cell352_357}                ${tl.attenuator[2].ip_addr}
${att_ipaddr_cell353_357}                ${tl.attenuator[2].ip_addr}

${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_conn}    GNB_OAM
@{LNRCELL_list}    ${3}    ${13}    ${33}
@{gnb_list}    ${0}
@{ALLOWED_FAULT}    4655    4654    61652    61524    4592    7311    7300    61649    4293    1900
${enb_instance}    ${tl.enbs[0].instance_id}
@{gnb_id}    357    36311

*** Keywords ***
### tti collect###
Teardown TTitrace mirror on BTS
    [Arguments]    ${names}=l2stream3_ttitrace
    log to console    stop ttitrace mirror...
    core.teardown_collectors
    ...  names=${names}

Stop Collect TTitrace and package TTitrace on remote UTE
    [Arguments]    ${names}=tcpdump_ttitrace
    ...            ${uteTTI_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${uteTTI_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${uteTTI_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${tti_path}=/opt
    csn.Connect to    hostname=${uteTTI_ip}    username=${uteTTI_username}    password=${uteTTI_password}    alias=${names}
    csn.execute    command=ps -ef | grep tcpdump |grep -v grep|awk '{print $2}'|sudo xargs kill -9
    ...    connection=${names}
    csn.execute    command=sudo mkdir -p ${tti_path}&& sudo mv /tmp/ttitrace.pcap* ${tti_path}
    ...    connection=${names}
    [Teardown]    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=${names}

Start Collect TTitrace on remote UTE
    [Arguments]    ${names}=tcpdump_ttitrace
    ...            ${uteTTI_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${uteTTI_username}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${uteTTI_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${maxsize}=500
    ...            ${maxnumber}=200
    ...            ${ute_inet}=eth0
    ...            ${bts_port}=5678
    ...            ${timeout}=5
    csn.Connect to    hostname=${uteTTI_ip}    username=${uteTTI_username}    password=${uteTTI_password}    alias=${names}
    csn.execute    command=ps -ef | grep tcpdump |grep -v grep|awk '{print $2}'|sudo xargs kill -9
    ...    connection=${names}
    csn.execute    command=sudo rm -rf /tmp/ttitrace.pcap*
    ...    connection=${names}
    ${tti_cmd}    set variable    /tmp/ttitrace.pcap >& tmp_0.txt&
    csn.send command
    ...    command=nohup sudo timeout ${timeout}m tcpdump -v -ni ${ute_inet} port ${bts_port} -C ${maxsize} -W ${maxnumber} -w ${tti_cmd}
    ...    connection=${names}
    sleep    3s
    [Teardown]    Run Keyword And Ignore Error
    ...    csn.disconnect    connection=${names}

Setup BTS TTitrace Mirror to remote UTE
    [Arguments]    ${names}=l2stream3_ttitrace
    ...            ${host_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...            ${SW_BRANCH}=NULL
    ...            ${port_num}=eth0
    ...            ${gnb_ip}=${host_ip}
    ...            ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${nr_phy_cell_ids}=NULL
    ...            ${gNB_index}=${0}
    ...            ${tti_component}=L2PS
    log to console    setup admin for ttitrace...
    Run Keyword If    '${SW_BRANCH}'=='NULL'    Get Sw_Branch Version    gNB_index=${gNB_index}
    ${webserver}=  Create Dictionary    host=${host_ip}    user=${username}    password=${password}    port=443    release=${SW_BRANCH}
    Run Keyword If    "${nr_phy_cell_ids}"=="NULL"    Get PhysCellId Of GNB    gNB_index=${gNB_index}
    ${L2PS}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2Ps    trace_type=Component
    ${L2Lo}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2Lo    trace_type=Component
    ${L2HiRlc}=    Create Dictionary
    ...    nr_phy_cell_ids=${nr_phy_cell_ids}    up_sw=L2HiRlc    trace_type=Component
    ${L2HiPdcp}=    Create Dictionary
    ...    up_sw=L2HiPdcp    trace_type=Component
    @{l2_stream_configurations}=  Create List
    FOR    ${item}    IN    @{tti_component.split(',')}
        append to list    ${l2_stream_configurations}    ${${item}}
    END
    tcpdump.create tcpdump collector
    ...    name=tcpdump_ttitrace    sudo_password=ute
    ...    options=-i ${port_num} udp and src ${gnb_ip} and dst ${ute_ip} and dst port 5678
    L2STREAM3.create_sbts_l2stream_collector
    ...    name=${names}    destination_ip_addr=${ute_ip}    source_ip_addr=${gnb_ip}    collector=tcpdump_ttitrace
    ...    l2_stream_configuration=${l2_stream_configurations}    webservice=${webserver}    dscp=10
    L2STREAM3.Set Suite Alias    alias=${names}
    core.setup_collectors    names=${names}
    log to console    finish admin process for ttitrace setup

### PA adjust ###
Adjust gNB_RU Attenuation TL363
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${cell21_value}=${127}    ${cell22_value}=${127}    ${cell23_value}=${127}    ${cell24_value}=${127}
    ...    ${cell1_value}=${127}    ${cell2_value}=${127}    ${cell3_value}=${127}    ${cell4_value}=${127}
    ...    ${cell301_value}=${127}    ${cell302_value}=${127}    ${cell303_value}=${127}
    ####create cell list#####
    @{att_ports_cell21}    Create List    ${att_port_1_cell21_${tl}}    ${att_port_2_cell21_${tl}}
    ...    ${att_port_3_cell21_${tl}}    ${att_port_4_cell21_${tl}}
    @{att_ports_cell22}    Create List    ${att_port_1_cell22_${tl}}    ${att_port_2_cell22_${tl}}
    ...    ${att_port_3_cell22_${tl}}    ${att_port_4_cell22_${tl}}
    @{att_ports_cell23}    Create List    ${att_port_1_cell23_${tl}}    ${att_port_2_cell23_${tl}}
    ...    ${att_port_3_cell23_${tl}}    ${att_port_4_cell23_${tl}}
    @{att_ports_cell24}    Create List    ${att_port_1_cell24_${tl}}    ${att_port_2_cell24_${tl}}
    ...    ${att_port_3_cell24_${tl}}    ${att_port_4_cell24_${tl}}
    @{att_ports_cell1}    Create List    ${att_port_1_cell1${tl}}    ${att_port_2_cell1_${tl}}
    @{att_ports_cell2}    Create List    ${att_port_1_cell2_${tl}}    ${att_port_2_cell2${tl}}
    @{att_ports_cell3}    Create List    ${att_port_1_cell3_${tl}}    ${att_port_2_cell3_${tl}}
    @{att_ports_cell4}    Create List    ${att_port_1_cell4_${tl}}    ${att_port_2_cell4_${tl}}
    ...    ${att_port_3_cell4_${tl}}    ${att_port_4_cell4_${tl}}
    @{att_ports_cell301}    Create List    ${att_port_1_cell301_${tl}}    ${att_port_2_cell301_${tl}}
    ...    ${att_port_3_cell301_${tl}}    ${att_port_4_cell301_${tl}}
    @{att_ports_cell302}    Create List    ${att_port_1_cell302_${tl}}    ${att_port_2_cell302_${tl}}
    ...    ${att_port_3_cell302_${tl}}    ${att_port_4_cell302_${tl}}
    @{att_ports_cell303}    Create List    ${att_port_1_cell303_${tl}}    ${att_port_2_cell303_${tl}}
    ...    ${att_port_3_cell303_${tl}}    ${att_port_4_cell303_${tl}}

    ###create value list####
    @{values_cell21}    Create List    ${cell21_value}    ${cell21_value}    ${cell21_value}    ${cell21_value}
    @{values_cell22}    Create List    ${cell22_value}    ${cell22_value}    ${cell22_value}    ${cell22_value}
    @{values_cell23}    Create List    ${cell23_value}    ${cell23_value}    ${cell23_value}    ${cell23_value}
    @{values_cell24}    Create List    ${cell24_value}    ${cell24_value}    ${cell24_value}    ${cell24_value}
    @{values_cell1}    Create List    ${cell1_value}    ${cell1_value}
    @{values_cell2}    Create List    ${cell2_value}    ${cell2_value}
    @{values_cell3}    Create List    ${cell3_value}    ${cell3_value}
    @{values_cell4}    Create List    ${cell4_value}    ${cell4_value}    ${cell4_value}    ${cell4_value}
    @{values_cell301}    Create List    ${cell301_value}    ${cell301_value}    ${cell301_value}    ${cell301_value}
    @{values_cell302}    Create List    ${cell302_value}    ${cell302_value}    ${cell302_value}    ${cell302_value}
    @{values_cell303}    Create List    ${cell303_value}    ${cell303_value}    ${cell303_value}    ${cell303_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_cell21}    values=${values_cell21}
    ...    att_connection_port=${att_port_1_cell21_${tl}}    att_ipaddr=${att_ipaddr_cell21_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell22}    values=${values_cell22}
    ...    att_connection_port=${att_port_1_cell22_${tl}}    att_ipaddr=${att_ipaddr_cell22_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell23}    values=${values_cell23}
    ...    att_connection_port=${att_port_1_cell23_${tl}}    att_ipaddr=${att_ipaddr_cell23_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell24}    values=${values_cell24}
    ...    att_connection_port=${att_port_1_cell24_${tl}}    att_ipaddr=${att_ipaddr_cell24_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell1}    values=${values_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell2}    values=${values_cell2}
    ...    att_connection_port=${att_port_1_cell2_${tl}}    att_ipaddr=${att_ipaddr_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell3}    values=${values_cell3}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell4}    values=${values_cell4}
    ...    att_connection_port=${att_port_1_cell4_${tl}}    att_ipaddr=${att_ipaddr_cell4_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell301}    values=${values_cell301}
    ...    att_connection_port=${att_port_1_cell301_${tl}}    att_ipaddr=${att_ipaddr_cell301_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell302}    values=${values_cell302}
    ...    att_connection_port=${att_port_1_cell302_${tl}}    att_ipaddr=${att_ipaddr_cell302_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell303}    values=${values_cell303}
    ...    att_connection_port=${att_port_1_cell303_${tl}}    att_ipaddr=${att_ipaddr_cell303_${tl}}

Adjust gNB_RU Attenuation TL357
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${cell1_value}=${127}    ${cell2_value}=${127}    ${cell3_value}=${127}
    ...    ${cell11_value}=${127}    ${cell12_value}=${127}    ${cell13_value}=${127}
    ...    ${cell301_value}=${127}    ${cell302_value}=${127}    ${cell303_value}=${127}
    ...    ${cell351_value}=${127}    ${cell352_value}=${127}    ${cell353_value}=${127}
    ####create cell list#####
    @{att_ports_cell1}    Create List    ${att_port_1_cell1_${tl}}    ${att_port_2_cell1_${tl}}
    ...    ${att_port_3_cell1_${tl}}    ${att_port_4_cell1_${tl}}
    @{att_ports_cell2}    Create List    ${att_port_1_cell2_${tl}}    ${att_port_2_cell2_${tl}}
    ...    ${att_port_3_cell2_${tl}}    ${att_port_4_cell2_${tl}}
    @{att_ports_cell3}    Create List    ${att_port_1_cell3_${tl}}    ${att_port_2_cell3_${tl}}
    ...    ${att_port_3_cell3_${tl}}    ${att_port_4_cell3_${tl}}
    @{att_ports_cell11}    Create List    ${att_port_1_cell11_${tl}}    ${att_port_2_cell11_${tl}}
    ...    ${att_port_3_cell11_${tl}}    ${att_port_4_cell11_${tl}}
    @{att_ports_cell12}    Create List    ${att_port_1_cell12_${tl}}    ${att_port_2_cell12_${tl}}
    ...    ${att_port_3_cell12_${tl}}    ${att_port_4_cell12_${tl}}
    @{att_ports_cell13}    Create List    ${att_port_1_cell13_${tl}}    ${att_port_2_cell13_${tl}}
    ...    ${att_port_3_cell13_${tl}}    ${att_port_4_cell13_${tl}}
    @{att_ports_cell301}    Create List    ${att_port_1_cell301_${tl}}    ${att_port_2_cell301_${tl}}
    ...    ${att_port_3_cell301_${tl}}    ${att_port_4_cell301_${tl}}
    @{att_ports_cell302}    Create List    ${att_port_1_cell302_${tl}}    ${att_port_2_cell302_${tl}}
    ...    ${att_port_3_cell302_${tl}}    ${att_port_4_cell302_${tl}}
    @{att_ports_cell303}    Create List    ${att_port_1_cell303_${tl}}    ${att_port_2_cell303_${tl}}
    ...    ${att_port_3_cell303_${tl}}    ${att_port_4_cell303_${tl}}
    @{att_ports_cell351}    Create List    ${att_port_1_cell351_${tl}}    ${att_port_2_cell351_${tl}}
    ...    ${att_port_3_cell351_${tl}}    ${att_port_4_cell351_${tl}}
    @{att_ports_cell352}    Create List    ${att_port_1_cell352_${tl}}    ${att_port_2_cell352_${tl}}
    ...    ${att_port_3_cell352_${tl}}    ${att_port_4_cell352_${tl}}
    @{att_ports_cell353}    Create List    ${att_port_1_cell353_${tl}}    ${att_port_2_cell353_${tl}}
    ...    ${att_port_3_cell353_${tl}}    ${att_port_4_cell353_${tl}}

    ###create value list####
    @{values_cell1}    Create List    ${cell1_value}    ${cell1_value}    ${cell1_value}    ${cell1_value}
    @{values_cell2}    Create List    ${cell2_value}    ${cell2_value}    ${cell2_value}    ${cell2_value}
    @{values_cell3}    Create List    ${cell3_value}    ${cell3_value}    ${cell3_value}    ${cell3_value}
    @{values_cell11}    Create List    ${cell11_value}    ${cell11_value}    ${cell11_value}    ${cell11_value}
    @{values_cell12}    Create List    ${cell12_value}    ${cell12_value}    ${cell12_value}    ${cell12_value}
    @{values_cell13}    Create List    ${cell13_value}    ${cell13_value}    ${cell13_value}    ${cell13_value}
    @{values_cell301}    Create List    ${cell301_value}    ${cell301_value}    ${cell301_value}    ${cell301_value}
    @{values_cell302}    Create List    ${cell302_value}    ${cell302_value}    ${cell302_value}    ${cell302_value}
    @{values_cell303}    Create List    ${cell303_value}    ${cell303_value}    ${cell303_value}    ${cell303_value}
    @{values_cell351}    Create List    ${cell351_value}    ${cell351_value}    ${cell351_value}    ${cell351_value}
    @{values_cell352}    Create List    ${cell352_value}    ${cell352_value}    ${cell352_value}    ${cell352_value}
    @{values_cell353}    Create List    ${cell353_value}    ${cell353_value}    ${cell353_value}    ${cell353_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_cell1}    values=${values_cell1}
    ...    att_connection_port=${att_port_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell2}    values=${values_cell2}
    ...    att_connection_port=${att_port_1_cell2_${tl}}    att_ipaddr=${att_ipaddr_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell3}    values=${values_cell3}
    ...    att_connection_port=${att_port_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_cell3_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell11}    values=${values_cell11}
    ...    att_connection_port=${att_port_1_cell11_${tl}}    att_ipaddr=${att_ipaddr_cell11_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell12}    values=${values_cell12}
    ...    att_connection_port=${att_port_1_cell12_${tl}}    att_ipaddr=${att_ipaddr_cell12_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell13}    values=${values_cell13}
    ...    att_connection_port=${att_port_1_cell13_${tl}}    att_ipaddr=${att_ipaddr_cell13_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell301}    values=${values_cell301}
    ...    att_connection_port=${att_port_1_cell301_${tl}}    att_ipaddr=${att_ipaddr_cell301_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell302}    values=${values_cell302}
    ...    att_connection_port=${att_port_1_cell302_${tl}}    att_ipaddr=${att_ipaddr_cell302_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell303}    values=${values_cell303}
    ...    att_connection_port=${att_port_1_cell303_${tl}}    att_ipaddr=${att_ipaddr_cell303_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell351}    values=${values_cell351}
    ...    att_connection_port=${att_port_1_cell351_${tl}}    att_ipaddr=${att_ipaddr_cell351_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell352}    values=${values_cell352}
    ...    att_connection_port=${att_port_1_cell352_${tl}}    att_ipaddr=${att_ipaddr_cell352_${tl}}
    Set the attenuation value    att_ports=${att_ports_cell353}    values=${values_cell353}
    ...    att_connection_port=${att_port_1_cell353_${tl}}    att_ipaddr=${att_ipaddr_cell353_${tl}}

Adjust gNB_RU Attenuation TL357 one port
    [Arguments]     ${tl}=${gnb_instance}    ${cell_value}=${127}    ${cell}=101
    ####create cell list#####
    @{att_ports_cell}    Create List    ${att_port_1_cell${cell}_${tl}}    ${att_port_2_cell${cell}_${tl}}
    ...    ${att_port_3_cell${cell}_${tl}}    ${att_port_4_cell${cell}_${tl}}
    ###create value list####
    @{values_cell}    Create List    ${cell_value}    ${cell_value}    ${cell_value}    ${cell_value}
    ###Adjust the HBTE attenuation value###
    Set the attenuation value TL357    att_ports=${att_ports_cell}    values=${values_cell}
    ...    att_connection_port=${att_port_1_cell${cell}_${tl}}    att_ipaddr=${att_ipaddr_cell${cell}_${tl}}

Set the attenuation value TL357
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        att.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
#        sleep    1s
        ${value_port}    att.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

Adjust gNB_RU Attenuation TL363 same value on all ports without wait
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${cell21_value}=${127}    ${cell22_value}=${127}    ${cell23_value}=${127}    ${cell24_value}=${127}
    ...    ${cell1_value}=${127}    ${cell2_value}=${127}    ${cell3_value}=${127}    ${cell4_value}=${127}
    ...    ${cell301_value}=${127}    ${cell302_value}=${127}    ${cell303_value}=${127}    ${gnb2cell1_value}=${127}
    ...    ${cell21_flag}=default    ${cell22_flag}=default    ${cell23_flag}=default    ${cell24_flag}=default
    ...    ${cell1_flag}=default    ${cell2_flag}=default    ${cell3_flag}=default    ${cell4_flag}=default
    ...    ${cell301_flag}=default    ${cell302_flag}=default    ${cell303_flag}=default    ${gnb2cell1_flag}=default
    ...    ${all_recovery}=${False}
    ####create cell list#####
    @{att_ports_cell21}    Create List    ${att_ports_1_cell21_${tl}}    ${att_ports_2_cell21_${tl}}
    ...    ${att_ports_3_cell21_${tl}}    ${att_ports_4_cell21_${tl}}
    @{att_ports_cell22}    Create List    ${att_ports_1_cell22_${tl}}    ${att_ports_2_cell22_${tl}}
    ...    ${att_ports_3_cell22_${tl}}    ${att_ports_4_cell22_${tl}}
    @{att_ports_cell23}    Create List    ${att_ports_1_cell23_${tl}}    ${att_ports_2_cell23_${tl}}
    ...    ${att_ports_3_cell23_${tl}}    ${att_ports_4_cell23_${tl}}
    @{att_ports_cell24}    Create List    ${att_ports_1_cell24_${tl}}    ${att_ports_2_cell24_${tl}}
    ...    ${att_ports_3_cell24_${tl}}    ${att_ports_4_cell24_${tl}}
    @{att_ports_cell1}    Create List    ${att_ports_1_cell1${tl}}    ${att_ports_2_cell1_${tl}}
    @{att_ports_cell2}    Create List    ${att_ports_1_cell2_${tl}}    ${att_ports_2_cell2${tl}}
    @{att_ports_cell3}    Create List    ${att_ports_1_cell3_${tl}}    ${att_ports_2_cell3_${tl}}
    @{att_ports_cell4}    Create List    ${att_ports_1_cell4_${tl}}    ${att_ports_2_cell4_${tl}}
    ...    ${att_ports_3_cell4_${tl}}    ${att_ports_4_cell4_${tl}}
    @{att_ports_cell301}    Create List    ${att_ports_1_cell301_${tl}}    ${att_ports_2_cell301_${tl}}
    ...    ${att_ports_3_cell301_${tl}}    ${att_ports_4_cell301_${tl}}
    @{att_ports_cell302}    Create List    ${att_ports_1_cell302_${tl}}    ${att_ports_2_cell302_${tl}}
    ...    ${att_ports_3_cell302_${tl}}    ${att_ports_4_cell302_${tl}}
    @{att_ports_cell303}    Create List    ${att_ports_1_cell303_${tl}}    ${att_ports_2_cell303_${tl}}
    ...    ${att_ports_3_cell303_${tl}}    ${att_ports_4_cell303_${tl}}
    @{att_ports_gnb2cell1}    Create List    ${att_ports_1_gnb2cell1_${tl}}    ${att_ports_2_gnb2cell1_${tl}}
    ...    ${att_ports_3_gnb2cell1_${tl}}    ${att_ports_4_gnb2cell1_${tl}}

    ###create value list####
    @{values_cell21}    Create List    ${cell21_value}    ${cell21_value}    ${cell21_value}    ${cell21_value}
    @{values_cell22}    Create List    ${cell22_value}    ${cell22_value}    ${cell22_value}    ${cell22_value}
    @{values_cell23}    Create List    ${cell23_value}    ${cell23_value}    ${cell23_value}    ${cell23_value}
    @{values_cell24}    Create List    ${cell24_value}    ${cell24_value}    ${cell24_value}    ${cell24_value}
    @{values_cell1}    Create List    ${cell1_value}    ${cell1_value}
    @{values_cell2}    Create List    ${cell2_value}    ${cell2_value}
    @{values_cell3}    Create List    ${cell3_value}    ${cell3_value}
    @{values_cell4}    Create List    ${cell4_value}    ${cell4_value}    ${cell4_value}    ${cell4_value}
    @{values_cell301}    Create List    ${cell301_value}    ${cell301_value}    ${cell301_value}    ${cell301_value}
    @{values_cell302}    Create List    ${cell302_value}    ${cell302_value}    ${cell302_value}    ${cell302_value}
    @{values_cell303}    Create List    ${cell303_value}    ${cell303_value}    ${cell303_value}    ${cell303_value}
    @{values_gnb2cell1}    Create List    ${gnb2cell1_value}    ${gnb2cell1_value}    ${gnb2cell1_value}    ${gnb2cell1_value}

    ###Adjust the HBTE attenuation value###
    IF    '${cell21_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell21}    values=${values_cell21}
        ...    att_connection_port=${att_ports_1_cell21_${tl}}    att_ipaddr=${att_ipaddr_cell21_${tl}}
    END
    IF    '${cell22_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell22}    values=${values_cell22}
        ...    att_connection_port=${att_ports_1_cell22_${tl}}    att_ipaddr=${att_ipaddr_cell22_${tl}}
    END
    IF    '${cell23_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell23}    values=${values_cell23}
        ...    att_connection_port=${att_ports_1_cell23_${tl}}    att_ipaddr=${att_ipaddr_cell23_${tl}}
    END
    IF    '${cell24_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell24}    values=${values_cell24}
        ...    att_connection_port=${att_ports_1_cell24_${tl}}    att_ipaddr=${att_ipaddr_cell24_${tl}}
    END
    IF    '${cell1_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell1}    values=${values_cell1}
        ...    att_connection_port=${att_ports_1_cell1_${tl}}    att_ipaddr=${att_ipaddr_cell1_${tl}}
    END
    IF    '${cell2_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell2}    values=${values_cell2}
        ...    att_connection_port=${att_ports_1_cell2_${tl}}    att_ipaddr=${att_ipaddr_cell2_${tl}}
    END
    IF    '${cell3_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell3}    values=${values_cell3}
        ...    att_connection_port=${att_ports_1_cell3_${tl}}    att_ipaddr=${att_ipaddr_cell3_${tl}}
    END
    IF    '${cell4_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell4}    values=${values_cell4}
        ...    att_connection_port=${att_ports_1_cell4_${tl}}    att_ipaddr=${att_ipaddr_cell4_${tl}}
    END
    IF    '${cell301_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell301}    values=${values_cell301}
        ...    att_connection_port=${att_ports_1_cell301_${tl}}    att_ipaddr=${att_ipaddr_cell301_${tl}}
    END
    IF    '${cell302_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell302}    values=${values_cell302}
        ...    att_connection_port=${att_ports_1_cell302_${tl}}    att_ipaddr=${att_ipaddr_cell302_${tl}}
    END
    IF    '${cell303_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_cell303}    values=${values_cell303}
        ...    att_connection_port=${att_ports_1_cell303_${tl}}    att_ipaddr=${att_ipaddr_cell303_${tl}}
    END
    IF    '${gnb2cell1_flag}' != 'default' or ${all_recovery} == ${True}
        Set the attenuation same value all ports without wait    att_ports=${att_ports_gnb2cell1}    values=${values_gnb2cell1}
        ...    att_connection_port=${att_ports_1_gnb2cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2cell1_${tl}}
    END

Set the attenuation same value all ports without wait
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}    ${att_ipaddr}=${att_ipaddr}
    ...    ${max_attenuation_value}=${127}    ${model}=${model}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    [Documentation]    This keyword is to set the test environment PA values, HBTE and topyoung.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    ...    ${att_connection_port}:if PA is HBTE, the port is any one port.
    ...                           if PA is topyoung, the port is a List all the attenuator ports as int list
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    att.set_ports_attenuation    ports=${att_ports}    values=${values}
    ${ports_values}=    att.read_ports_attenuation    ports=${att_ports}
    ${without_Duplicates_ports_values}=    Remove Duplicates    list_=${ports_values}
    ${value_length}=    Get Length    ${without_Duplicates_ports_values}
    Should Be Equal As Integers    ${value_length}    ${1}
    Should Be Equal As Integers    ${without_Duplicates_ports_values}[0]    ${values}[0]

###### UE #########
Prepare UE and detach UE
    [Arguments]    ${ue_type}=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}

##### wireshak log ######
Check wireshark log
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${attribute_name}=show
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${filtered_result}=     cap.get_field_value_by_xpath    attribute_name=${attribute_name}    xpath=${xpath}    pcap_parser=test6
    [Return]    ${filtered_result}

Check wireshark log for mps
    [Arguments]    ${logname}
    ...    ${message_filter1}=f1ap.procedureCode == 11 and nr-rrc.establishmentCause == 8
    ...    ${xpath}=.//nr-rrc.establishmentCause
    ${establishmentCause}=    Check wireshark log    logname=${logname}    message_filter=${message_filter1}    xpath=${xpath}
    should be equal    ${establishmentCause[0]}    8

#### gNB and eNB ######
Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1


#Locked LTE cell
#    [Arguments]    ${enb_index}=${0}    ${LNRCELL_list}=${LNRCELL_list}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=https://${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
#    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#    selenium_coam.disable_message_box
#    ${modify_params}    create list
#    FOR    ${LNRCELL_index}    IN    @{LNRCELL_list}
#        ${item}    create dictionary
#        ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${LNRCELL_index}
#        ...    filter_param=Administrative state    p_name=administrativeState    value=locked
#        append to list    ${modify_params}    ${item}
#    END
#    Modify Parameters On Webem LTE    modify_params=${modify_params}
#    sleep    30s
##    Cell Should Be Locked
##    Cell Should Be Disabled
#    [Teardown]   Selenium Logout And Close Browser

Locked LTE cell
    [Arguments]    ${enb_index}=${0}    ${LNRCELL_list}=${LNRCELL_list}    ${enb_instance}=${tl.enbs[${enb_index}].instance_id}
    FOR    ${cell}    IN    @{LNRCELL_list}
        Modify the enblte parameter
        ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${cell}
        ...    parameter=administrativeState     value=locked    enb_index=${enb_index}
    END

#UnLocked LTE cell
#    [Arguments]    ${enb_index}=${0}    ${LNRCELL_list}=${LNRCELL_list}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=https://${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
#    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#    selenium_coam.disable_message_box
#    ${modify_params}    create list
#    FOR    ${LNRCELL_index}    IN    @{LNRCELL_list}
#        ${item}    create dictionary
#        ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${LNRCELL_index}
#        ...    filter_param=Administrative state    p_name=administrativeState    value=unlocked
#        append to list    ${modify_params}    ${item}
#    END
#    Modify Parameters On Webem LTE    modify_params=${modify_params}
#    sleep    30s
#    ##Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
#    [Teardown]   Selenium Logout And Close Browser

UnLocked LTE cell
    [Arguments]    ${enb_index}=${0}    ${LNRCELL_list}=${LNRCELL_list}    ${enb_instance}=${tl.enbs[${enb_index}].instance_id}
    FOR    ${cell}    IN    @{LNRCELL_list}
        Connect and Modify the parameter on enblte
        ...    dist_name=MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-${cell}
        ...    parameter=administrativeState     value=unlocked
    END

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=${gnb_conn}
         ...    dic_path=${dic_path[${index}]}
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Attach and check DLUL tput
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${dl_expect_tput}    ${ul_expect_tput}    ${lcrid}=${103}
    ...    ${process_num}=${1}
    Attach and check power UE    ue_type=${ue_type}
    ${cell1_id}=    COAM Get nrcellid with lcrid    lcrid=${lcrid}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    Power UE Start DL traffic    dl_throughput=${dl_throughput}    duration=2400    process_num=${process_num}
    Power UE Start UL traffic    ul_throughput=${ul_throughput}    duration=2400
    Prepare to caculate PM counter    period=start
    sleep    1200s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL    log=${log}   cells=${list_of_cell_ids}
    ...    target_throughput=${ul_expect_tput}
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...    log=${log}   cells=${list_of_cell_ids}    target_throughput=${dl_expect_tput}
    [Teardown]    Run keywords   Stop UL DL data transfer    AND
    ...    power_ue.UE Detach    ue_type=${ue_type}

Check 2CC DLUL tput
    [Arguments]    ${tput_dl_pcell}=${expected_tput_dl_T}    ${tput_dl_scell}=${expected_tput_dl_T}
    ...    ${scellid}=1   ${pcellid}=1
    ${nrcellid_pcell}    COAM Get nrcellid with lcrid    lcrid=${pcellid}    gnb_index=${0}
    ${nrcellid_scell}    COAM Get nrcellid with lcrid    lcrid=${scellid}    gnb_index=${0}
    ${nrcellid_pcell}    Create list  ${nrcellid_pcell}
    ${nrcellid_scell}    Create list  ${nrcellid_scell}
    ${tput_log_prime}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${0}
    ${tput_log_external}    power_ue.Collect Tput    duration=30s    ignore_time=0s    ue_type=${ue_type}    gnb_index=${0}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_pcell}    log=${tput_log_prime}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_pcell}
    power_ue.Check Tput    direction=DL    cells=${nrcellid_scell}    log=${tput_log_external}    ue_type=${ue_type}
    ...    target_throughput=${tput_dl_scell}

RF_Reset
    [Arguments]    ${connection}=${gnb_conn}    ${gnb_index}=0
    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${gNb_CuType}   Get gNB CU type
    set suite variable    ${gNb_CuType}
    General_SiSo_RF_module_reset_from_GUI
    Start_L3_call_and_check_Tput
    [Teardown]    Run Keyword And Ignore Error     coam.teardown    connection=${connection}

BB_Reset
    [Arguments]    ${connection}=${gnb_conn}    ${gnb_index}=0
    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${gNb_CuType}   Get gNB CU type
    set suite variable    ${gNb_CuType}
    Baseband_module_reset_via_WEBUI
    Start_L3_call_and_check_Tput
    [Teardown]    Run Keyword And Ignore Error     coam.teardown    connection=${connection}

Connect and save snapshot for enb UUF
    [Arguments]    ${connection}=enb     ${enb_index}=${0}
    Connect to eNB via ssl    connection=${connection}_${enb_index}     enb_index=${enb_index}
    COAM Save snapshot via rest api    connection=${connection}_${enb_index}    timeout=900
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}_${enb_index}

Common test Teardown for UUF
   Run keyword and ignore error    COAM Save all gnb snapshot via api
   Connect and save snapshot for enb UUF    enb_index=${0}

Cell lock unlock
    [Arguments]    ${connection}=${gnb_conn}    ${gnb_index}=0
    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${gNb_CuType}   Get gNB CU type
    set suite variable    ${gNb_CuType}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    Start_L3_call_and_check_Tput
    [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Cell block unblock
    [Arguments]    ${connection}=${gnb_conn}    ${gnb_index}=0
    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${gNb_CuType}   Get gNB CU type
    set suite variable    ${gNb_CuType}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Check if current SW version is trunk
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock    version=${stream}
    Block and UnBlock Cells    block_list=${cell_id_list}
    Start_L3_call_and_check_Tput
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Selenium Logout And Close Browser     AND
    ...    Run Keyword And Ignore Error    coam.teardown    connection=${connection}


Modify Pmax of Cell Parameter via WebUI
    [Arguments]  ${cell_id}=103    ${connection}=${gnb_conn}    ${gnb_index}=0
    connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${gNb_CuType}   Get gNB CU type
    set suite variable    ${gNb_CuType}
    ${original_Pmax}    Get Pmax Value Via API    cell_id=${cell_id}
    ${Modified_Pmax}    Convert To number	 ${original_Pmax}
    ${Modified_Pmax}    evaluate    ${original_Pmax} - ${0.1}
    ${Modified_Pmax}    Convert To number	 ${Modified_Pmax}    1
    log to console  Modify Pmax of Cell(+"original_Pmax:"+${original_Pmax}) Parameter via WebUI
    Wait Until Keyword Succeeds    2min    30s    COAM Navigate to login page via webUI
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-${cell_id}
    ...    filter_param=Maximum output power    p_name=pMax    value=${Modified_Pmax}
    append to list    ${modify_params}    ${item}
    Connect to gnb coam via ssl
    log to console  Modify Pmax of Cell(+"to"+${Modified_Pmax}) Parameter via WebUI
    Run keyword and ignore error    Modify Parameters On Webem    modify_params=${modify_params}
    ...    despite_errors=${True}    timeout=180
    ${Current_Pmax}    Get Pmax Value Via API    cell_id=${cell_id}
    should be true    '${Modified_Pmax}'=='${Current_Pmax}'
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Start_L3_call_and_check_Tput
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error     COAM selenium logout     AND
    ...    Run Keyword And Ignore Error    coam.teardown    connection=${connection}

Get Pmax Value Via API
    [Documentation]   Auther: jack.zeng@nokia-sbell.com
    [Arguments]  ${cell_id}    ${connection}=${gnb_conn}
    ${result}    coam.get_parameters_for_all    class_name=NRCEL    connection=${connection}
    FOR    ${item}    IN    @{result}
        ${value}    set variable if    '${item['configurationId']}'=='${cell_id}'    ${item['pMax']}    ${None}
        exit for loop if    '${value}' !='${None}'
    END
    [Return]     ${value}

Check if current SW version is trunk
    [Arguments]    ${download_dir}=${epc_log_path}   ${version_type}=Active
        COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${Active_SW_version}     convert to string    ${version}[${version_type}]
    set suite variable    ${Active_SW_version}
    ${result_version}    string.split string    string=${version}[${version_type}]    separator=_
    ${if_Trunk}     convert to string    ${result_version}[-3]
    set suite variable    ${if_Trunk}
    ${Result}=   Run Keyword If   "${if_Trunk}"=="9999"
    ...   Set Variable    ${True}
    ...   ELSE    Set Variable    ${False}
    [Return]      ${Result}

Get sagnb release 7834
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3][0]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get sagnb version 7834
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${tmp_info}    set variable    ${info.split('.')[0]}
    ${sw_version}     set variable
    ...    ${tmp_info.split('_')[1]}_${tmp_info.split('_')[2]}_${tmp_info.split('_')[3]}_${tmp_info.split('_')[4]}_${tmp_info.split('_')[5]}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=release_info

Get SCF file name for beamset6 and beamset2
#    [Arguments]    ${download_dir}=${epc_log_path}   ${version_type}=Active
#    ${sw_version}    Get sagnb version for selenium
#    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}    version=${sw_version}
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    ${Active_SW_version}     convert to string    &{version}[${version_type}]
#    set suite variable    ${Active_SW_version}
#    ${release_info}     set variable    ${Active_SW_version[0:-17]}
    ${release_info}    Get sagnb release 7834
    set suite variable    ${trunk_beamset6_scf}    Configuration_scf_GNB1_CB007834_${release_info}_beamset6.xml
    set suite variable    ${trunk_beamset2_scf}    Configuration_scf_GNB1_CB007834_${release_info}_beamset2.xml

Check Cell with beamset6 and beamset2 can on air
    [Arguments]    ${trunk_beamset6_scf}=${trunk_beamset6_scf}    ${trunk_beamset2_scf}=${trunk_beamset2_scf}
    Common Case TestLine Setup    is_commission=True    golden_scf_name=${trunk_beamset6_scf}     connection=${gnb_conn}
    sleep    60s
    Common Case TestLine Setup    is_commission=True    golden_scf_name=${trunk_beamset2_scf}     connection=${gnb_conn}

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
    Log To Console    Modify parameters online for cases
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}    ${sw_version}=
    ${sw_version}    Get sagnb version for selenium
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}    version=${sw_version}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}    ${version}=${version}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}    version=${version}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Check alarm
    [Arguments]     ${ALLOWED_FAULT}=${ALLOWED_FAULT}
    Check Unexpect Alarm whether exist    ALLOWED_FAULT=${ALLOWED_FAULT}

reset RMOD action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}    ${force_radio_reset}=${True}    ${connection_name}=gnb1
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${rmod}    IN    @{radioModules}
        Reset Unit with BTS    dist_name=${rmod}[id][runtime]    reset_type=${reset_type}    connection=${connection_name}
        ...    force_radio_reset=${force_radio_reset}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

Get Cell EnergySavingState
    [Arguments]    ${required_info}=energySavingState    ${status}=reducedEnergySaving    ${cell_index}=${1}
    ${get_status}    get required cell info    required_info=${required_info}    cell_index=${cell_index}
    should be equal    ${get_status}    ${status}

Get RU DSM/EDSM
    [Arguments]    ${required_info}=powerState    ${status}=DEEPSLEEP    ${RU_index}=1
    ${get_status}    get required RU info    required_info=${required_info}    RU_index=${RU_index}
    should be equal    ${get_status}    ${status}

Get require Cell status
    [Arguments]    ${required_info}=status    ${status}=off line    ${cell_index}=${1}
    ${get_status}    get required cell info    required_info=${required_info}    cell_index=${cell_index}
    should be equal    ${get_status['availabilityStatus']}    ${status}

Get many times RMOD Realtime Measurements
    [Arguments]    ${power_1_min}=${0}    ${power_1_max}=${0}
    Prepare to caculate PM counter    period=end    counter_time=60
    FOR    ${index}    IN RANGE    ${5}
        ${power_1}    Get RMOD Realtime Measurements For Real Ruindex    RU_index=${1}
        ${power_2}    Get RMOD Realtime Measurements For Real Ruindex    RU_index=${2}
        ${power_3}    Get RMOD Realtime Measurements For Real Ruindex    RU_index=${3}
        should be true    ${power_1_min}<=${power_1}<=${power_1_max}
        should be true    ${power_1_min}<=${power_2}<=${power_1_max}
        should be true    ${power_1_min}<=${power_3}<=${power_1_max}
        sleep    60s
    END

Attach and check IP OK
    [Arguments]    ${ue_index}=${7}    ${APN}=${APN}
    MultiUE.Attach    ue_index=${ue_index}
    sleep    1s
    ${IP}    MutiUE.Get PDU IP    ue_index=${ue_index}    APN=${APN}
    Should Not Be Empty    ${IP}
    Should Not Start With    ${IP}    192.168.

Check tput via spark
    [Arguments]    ${target_throughput}    ${ue_index}=${7}
    ${log}    power_ue.Collect Tput    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    duration=1s    ue_index=${ue_index}
    power_ue.Check Tput    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    direction=DL    log=${log}    cells=UE_${ue_index}
    ...    target_throughput=${target_throughput}

block unblock per cell action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${action}=block
    Connect with BTS    gnb_index=${gnb_index}    connection=GNB_OAM
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0' and '${action}'=='block' and '${cell_type}'=='gsm'    Run keywords
        ...    block unblock per cell    action=block    cells_info=${cell_list}[cells]    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Check cell failed status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE IF    '${Length}' != '0' and '${action}'=='unblock' and '${cell_type}'=='gsm'    Run keywords
        ...    block unblock per cell    action=unblock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=GNB_OAM

block unblock per cell
    [Arguments]    ${action}    ${cells_info}    ${cell_type}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
        ${cell_status} =    Set Variable    ${cells_info}[${cell_type}][${cell_index}][status][blockingState]
        IF    '${action}' == 'block' and '${cell_type}' == 'gsm' and '${cell_status}'== 'Unblocked'
            Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
        ELSE IF    '${action}' == 'unblock' and '${cell_type}' == 'gsm' and '${cell_status}'== 'Blocked'
            Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
        END
    END

Modify Parameters for Cases and not check RU status
    [Documentation]    jia-rebecca.liu@nokia-sbell.com
    ...      this keyword only support modify parameter
    ...      ${Modify_Para_Online}=[{'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'actDynUlDataSplitMode',
    ...      'value': 'true'}, {'dist_name': 'NRBTS-1/NRCELL-1', 'parameter': 'pucchDataDtxNumOfSamples', 'value': '100'}]
    [Arguments]    ${Modify_Para_Online}='NULL'
    ...            ${timeout}=15 min
    ...            ${gnb_index}=${0}
    ...            ${skip_parameter_relation_errors}=True
    ...            ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    COAM Update Several Parameters Via Rest Api    connection=${connection}
    ...                                      parameters_to_update_via_api=${Modify_Para_Online}    timeout=${timeout}
    ...                                      skip_parameter_relation_errors=${skip_parameter_relation_errors}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
