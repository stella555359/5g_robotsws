*** Settings ***
Documentation
...    author: yuegong
...    contact: yue.1.gong@nokia-sbell.com
...    squad group: SG_03
...    feature : TL384_CLOUD_UTE

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library    taf.config.testline    WITH NAME    testline
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.ul.messaging.mtk    WITH NAME    message
Library    taf.pdu       WITH NAME    pdu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot

Variables    CB006999_TL384_cloud_variables.py



*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ul_addr}    ${tl.ues[0].iperf_details.network_interface_address}
${testpc_ip}    ${tl.test_pc.default_ssh_connection_details.addr}

${gnb_path}    /tmp/
#${epc_log_path}    /home/ute/test_results/
${tshark_path}      /usr/bin/tshark
${asik}    BB1
${tl_scf_dir_path}    /opt/workspace/CIT/Master/Scf_files/
${tl_scf_filename}    Full_Configuration_scf_MRBTS-229_HZ_SG3_TL229_1700BA.xml
${enb_instance_id}    ${tl.enbs[0].instance_id}
${gnb_instance_id}    ${tl.gnbs[0].instance_id}
${enbx2_dist}    MRBTS-${enb_instance_id}/LNBTS-${enb_instance_id}/LNADJGNB-1
${enbx2_para}    administrativeState
${gnb_cell1}    MRBTS-${gnb_instance_id}/NRBTS-1/NRCELL-1
${gnb_cell2}    MRBTS-${gnb_instance_id}/NRBTS-1/NRCELL-2

#${amf_zhou_account_ip}    10.110.149.7    #dedicated ip for CB006999 testing
#${amf_account_username}    ccris    #dedicated ip for CB006999 testing
#${amf_account_password}    Nokia@1q3q    #dedicated ip for CB006999 testing
${amf_zhou_account_ip}    ${tl.core.default_ssh_connection_details.addr}
${amf_account_username}    ${tl.core.default_ssh_connection_details.username}
${amf_account_password}    ${tl.core.default_ssh_connection_details.password}
##${value_counter_6999_A003}    ${1}     ${0}    ${1}    ${1}     ${0}    ${1}

${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_port_1_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_3_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_4_}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_5_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${att_port_6_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${att_port_7_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${att_port_8_}                ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${att_port_9_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[0].port_no}
${att_port_10_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[1].port_no}
${att_port_11_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[2].port_no}
${att_port_12_}                ${tl.gnbs[0].dus[0].rus[3].attenuation_ports[3].port_no}
${att_port_13_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_14_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
${att_port_15_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${att_port_16_}                ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
#@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${at_com_38411}    5
${wap1apn}                  106 550
${wap2apn}                  106 748
${second_pdu}    at+cgact=1,2
${AT_script_path}    C:tool
@{allow_fault_list}    7311    7107    7523    4681

*** Keywords ***
#coam cell setup##
Prepare the atten for TL384 6999A03
    Adjust the TL HBTE attenuation value    enb1_cell1_value=${127}   gnb1_cell1_value=${10}    gnb1_cell2_value=${127}

Adjust the TL Topyoung attenuation value
    [Arguments]    ${enb1_cell1_value}=${120}    ${enb2_cell1_value}=${120}    ${gnb1_cell1_value}=${120}
    ...    ${gnb1_cell2_value}=${120}    ${gnb2_cell1_value}=${120}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    @{att_ports_enb2_cell1}    Create List    ${att_port_15_}    ${att_port_16_}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
    ...    ${att_port_7_}    ${att_port_8_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
    ...    ${att_port_3_}    ${att_port_4_}

    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value topyoung    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...     att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...     att_ipaddr=${att_ipaddr}
    Set the attenuation value topyoung    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...     att_ipaddr=${att_ipaddr}

Adjust the TL HBTE attenuation value
    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}    ${att_port_3_}    ${att_port_4_}
    @{att_ports_enb2_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    ...    ${att_port_15_}    ${att_port_16_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
    ...    ${att_port_7_}    ${att_port_8_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}

    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}

make amf-zhou maitain on amf account and alarm 7115 will be raised
    [Arguments]    ${time}=${10}    #${status}
     wait until keyword succeeds    10 min    5 sec    Connect to AMF-ZHOU account    alias=UTE
     csn.execute    command=cmm amfGuamiStatusAdmin modify AMF5-zhou --maintenanceTimer ${time} --guamiStatus maintenance
     ...    connection=UTE    #history alarm 7115 will be check later here i check gumi status unavailable
#    check webui gumi status    status=${status}    coam_url=${WEBUI_COAM}
#    ...    ngStatus_dist_name=${distname_id_1}/SERVEDAMF-2

Connect to AMF-ZHOU account
    [Arguments]    ${alias}=UTE
    csn.Connect to    hostname=${amf_zhou_account_ip}
    ...    username=${amf_account_username}
    ...    password=${amf_account_password}    alias=${alias}

Check the PM counter should be matached
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
	    ${counter_expected_value}    Convert To Integer    ${value[${index}]}
	    Should contain    ${counter_value}    ${counter_expected_value}
    END
    [Teardown]    COAM Teardown gnb connections

sent atcmd on cpc to trigger ul behaviour
    [Arguments]    ${command}=${second_pdu}    ${COM_port}=${at_com_trunk}    ${ue_index}=${0}
    #...    ${serial_number}=${tl.ues[${ue_index}].serial_number}   ue SN if multiue then will select one
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   10s
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
    ...    connection=cygwin${ue_index}
    ${output}    csn.Read Output    connection=cygwin${ue_index}
    #sleep    3s
    #should contain    ${output}    ${command}\\r\\r\\nOK\\r\\n

set apn to apnname
    [Arguments]    ${usedapn}=${wap2apn}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.settings.APN_SETTINGS     connection=cygwin
    sleep   2s
    ${current_window}    csn.read output    connection=cygwin
    Should Contain    ${current_window}    APN_SETTINGS
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${usedapn}    connection=cygwin
    sleep   8s
    [Teardown]    csn.disconnect    connection=cygwin