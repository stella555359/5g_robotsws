*** Settings ***
Documentation
...    author: yuegong
...    contact: yue.1.gong@nokia-sbell.com
...    squad group: SG_03

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library     taf.hw.rf_attenuator    WITH NAME    att
Library    taf.analyzer.pcap    WITH NAME    wireshark
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Library    taf.analyzer.pcap   WITH NAME    parser

Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/siso_resource.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/epc_sim.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot

*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_path}    /tmp/
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${ALIAS_ASIK}    ASIK
${tshark_path}   /usr/bin/tshark
${command_template_X}    {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
${command_template_Y}    {tshark_path} -r {pcap_file} -Y \"x2ap\" -T pdml
${command_template_Z}    {tshark_path} -r {pcap_file} -Y  \"e1ap\"  -T pdml
######eNB parameter######
${eNB_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${eNB_parameter}    administrativeState
${eNB_asik_addr}    ${tl.enbs[2].airscale.common_units[0].lmp_connection.addr}
${eNB_asik_addr_2}    ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
###counter path###
${M55112C03501_path}    CELLS/NRCELL-1/NX2CC/X2_SGNB_ADD_REQ_INTR_MENB_HO
${M55112C03502_path}    CELLS/NRCELL-1/NX2CC/X2_SGNB_ADD_REQ_ACK_INTRENB_HO
${M55128C00503_path}    BTS/NRBTS-${gnb_instance}/LTEMO/INTER_MENB_HO_RRC_RECONF
${M55128C00504_path}    BTS/NRBTS-${gnb_instance}/LTEMO/INTER_MENB_HO_RRC_RECONF_SUCC
${M55128C00502_path}    BTS/NRBTS-${gnb_instance}/LTEMO/INTER_MENB_HO_WO_PSCELL_CHNGE
##UE##
${SN}                       ${tl.ues[0].serial_number}
${ue_type}                  ${tl.ues[0].capabilities[0]}
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${duration}                1500
${ul_throughput}            10M
${dl_throughput}            100M
${DL_TIME}                  1200
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${edaemon_path}      /home/ute/TAF/sim_cai/
${edaemon_config}    CB006999_AMF_Copy.cfg
@{ngstatus}           Active    Inactive
@{gumistatus}         available    unavailable
#${AMF_ip}    ${tl.core.default_ssh_connection_details.addr}
${obiect_1}           NRBTS-${tl.gnbs[0].instance_id}
@{amfID}             SERVEDAMF-1    SERVEDAMF-2    SERVEDAMF-3
${AMF_zhou_ip}        10.110.90.68
${AMF_cmm5qa_ip}       10.107.182.70
@{admin_state}    Locked    Unlocked
${dl_expect_throughput}    70
${ul_expect_throughput}    5
#${amf_zhou_account_ip}    10.110.149.7    #dedicated ip for CB006999 testing
${amf_zhou_account_ip}    ${tl.core.default_ssh_connection_details.addr}
${cmm5_qa_account_ip}     10.107.182.199    #dedicated ip for CB006999 testing
#${amf_account_username}    ccris    #dedicated ip for CB006999 testing
${amf_account_username}    ${tl.core.default_ssh_connection_details.username}
${amf_account_password}    ${tl.core.default_ssh_connection_details.password}
#${amf_account_password}    Nokia@1q2q    #dedicated ip for CB006999 testing
${second_pdu}    at+cgact=1,2
${at_com_trunk}    46
${at_com_22r2}    11
${at_com_36011}    5
${at_com_34711}    13
${at_com_23311}    5
${AT_script_path}    C:tool
@{BTSID}    36011    34711    23311
${tl_36011_scf_gnb1}    gy_36011_GNB1.xml
${tl_36012_scf_gnb2}    gy_36012_GNB2.xml
${tl_34711_scf_gnb1}    gy_34711_GNB1.xml
${tl_34712_scf_gnb2}    gy_34712_GNB2.xml
${tl_23311_scf_gnb1}    gy_23311_GNB1.xml
${tl_23312_scf_gnb2}    gy_23312_GNB2.xml

${vendor}                    ${tl.attenuators[0].vendor}
${max_attenuation_value}     ${127}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_port_1_}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10_}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11_}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12_}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13_}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14_}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15_}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16_}                ${tl.attenuator[0].attenuator_ports[16]}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
*** Keywords ***
Load SCF for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}

Prepare the atten for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${127}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${127}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${127}   gnb2_cell1_value=${0}


Adjust the TL HBTE attenuation value
    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
    @{att_ports_enb2_cell1}    Create List    ${att_port_3_}    ${att_port_4_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    ...    ${att_port_15_}    ${att_port_16_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
    ...    ${att_port_7_}    ${att_port_8_}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}

    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
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

Online modify NIDD on gnb1 and gnb2
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    sleep    5s

trigger ul behaviour for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    sent atcmd on cpc to trigger ul behaviour    COM_port=${at_com_36011}     ue_index=${1}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    sent atcmd on cpc to trigger ul behaviour    COM_port=${at_com_34711}     ue_index=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    sent atcmd on cpc to trigger ul behaviour    COM_port=${at_com_23311}     ue_index=${1}


####
check IE
    #sleep   5s    #wait log and check
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${gNB1_nglogname}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}
    ${filter_expression}=    Catenate    ngap.procedureCode == 1
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${apply_timer}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//ngap.timerApproachForGUAMIRemoval
    should be equal    ${apply_timer[0]}    0    #apply timer
    ${filter_expression}=    Catenate    ip.src == 10.107.182.70 and ngap.procedureCode == 29
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${pro_code}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//ngap.procedureCode
    should be equal    ${pro_code[0]}    29    #Des is new amf

check IE for deactive
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${nglogname_2}    tshark_path=${tshark_path}
    ...    command_template=${command_template_with_Y}
    ${filter_expression}=    Catenate    ngap.procedureCode == 9 and ngap.protocolIEs == 1
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${cause_num}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//ngap.Cause
    should be equal    ${cause_num}[0]    3    #Message not compatible with receiver state

sleep 5min and check counter
    sleep    5min
    Check the relocation counters

Check the relocation counters
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check counter M55155C00004 as 1    #M55155C00004 (AMF_RESELECTION_GNB_ATT) = 1
    Check counter M55155C00005 as 0    #M55155C00005 (AMF_RESELECTION_GNB_FAIL) = 0
    Check counter M55155C00006 as 1    #M55155C00006 (AMF_RESELECTION_GNB_SUCC) = 1
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check counter ${counter_id} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    should contain   ${values}    ${expected_value}

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

Get Ue Alias
    [Arguments]    ${ue_id}=0
    ${ue_alias}=    Set Variable    UE_${ue_id}
    [Return]    ${ue_alias}

make amf-zhou maitain on amf account and alarm 7115 will be raised
    [Arguments]    ${status}    ${time}=${10}
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

lock or unlock enb for sa set
    [Arguments]    ${cell_status}=locked    ${enb_cell_id}=${1}    ${enb_index}=${0}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=${cell_status}
    sleep    10s

Power UE Attach and Verify attach for askey
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
     Wait until keyword succeeds    4X    5s    attach ue for askey one time    4g_check=${4g_check}    ue_type=${ue_type}    gnb_index=${gnb_index}

attach ue for askey one time
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${interval}=${1}    ${gnb_index}=${0}
    ${status}    ${5Grach_ed}    run keyword and ignore error  power_ue.UE Attach
    ...    ue_type=${ue_type}   ue_index=${0}    interval=${interval}     gnb_index=${gnb_index}
    ${5Grach_2ed}    run keyword if    '${status}'=='FAIL'    At Cmd UE reAttach    ue_index=${0}
    ${5Grach_ed}    set variable if    '${status}'=='FAIL'    ${5Grach_2ed}    ${5Grach_ed}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    4G_check=${4g_check}

At Cmd UE reAttach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog    ${interval}=${1}    &{kwargs}
    [Documentation]    reAttach UE for L3 call test.
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
    ute_ue.send_at_cmd_to_ue    alias=UE_0    at_cmd=at+cops=1,2,${mcc}${mnc}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

#Attach and check power UE
#    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${ue_index}=${0}
#    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}     gnb_index=${gnb_index}
#    ...                      4G_check=${4g_check}    5Gstatus=PASS

Online modify parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

delete amf and add another two amf object one locked one unlocked
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[0]
    ...    filter_param=Administrative state
    ...    new_value=${admin_state}[0]
    selenium_coam.add_object    object_name=${obiect_1}    object_class_name=SERVEDAMF    id_value=2
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[1]
    ...    filter_param=AMF IPv4/v6 Address
    ...    new_value=${AMF_zhou_ip}
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[1]
    ...    filter_param=Administrative state
    ...    new_value=Unlocked
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[1]
    ...    filter_param=Default AMF
    ...    new_value=true
    selenium_coam.add_object    object_name=${obiect_1}    object_class_name=SERVEDAMF    id_value=3
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[2]
    ...    filter_param=AMF IPv4/v6 Address
    ...    new_value=${AMF_cmm5qa_ip}
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[2]
    ...    filter_param=Administrative state
    ...    new_value=Locked
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/${amfID}[2]
    ...    filter_param=Default AMF
    ...    new_value=true
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    selenium_coam.logout
    selenium_coam.disable_virtual_display

delete real amf object
    [Arguments]    ${amfID}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_id_1}/${amfID}
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    selenium_coam.logout


Modify scf file for CB006999_true
    run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_filename}
    ...            output_scf=${epc_log_path}${tl_scf_filename}    parameters_lists=${PARAMS_TO_MODIFY_CB006999_true}

lock unlock amf link to check nglink status
    Modify new parameter value for gNB under object    url=${WEBUI_COAM}    dist_name=${distname_id_1}
    ...    admin_state=Locked
    sleep    5s
    Modify new parameter value for gNB under object    url=${WEBUI_COAM}    dist_name=${distname_id_1}
    ...    admin_state=Unlocked
    check nglink staus    status=${ngstatus}[0]    coam_url=${WEBUI_COAM}
    ...    ngStatus_dist_name=${distname_id_1}/SERVEDAMF-2

check nglink staus
    [Arguments]    ${status}    ${coam_url}    ${ngStatus_dist_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    sleep    5s
    ${ngStatus}=    selenium_coam.get_parameter_value    dist_name=${ngStatus_dist_name}
    ...    filter_param=NG Link Status
    ...    abbr=ngLinkStatus
    Should Be Equal    ${ngStatus}    ${status}
    selenium_coam.logout

Modify new parameter value for gNB under object
   [Arguments]     ${url}    ${dist_name}    ${admin_state}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${dist_name}/${amfID}[2]
    ...    filter_param=Administrative state
    ...    new_value=${admin_state}
    sleep    3s
    selenium_coam.validate_plan
    sleep    6s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Modify new parameter value for gNB
    [Arguments]    ${url}    ${dist_name}    ${filter_name}    ${abbr}    ${new_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value  dist_name=${dist_name}
    ...    filter_param=${filter_name}    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

check webui gumi status
    [Arguments]    ${status}    ${coam_url}    ${ngStatus_dist_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    sleep    5s
    ${ngStatus}=    selenium_coam.get_parameter_value    dist_name=${ngStatus_dist_name}
    ...    filter_param=Status of GUAMI
    ...    abbr=guamiStatus
    Should Be Equal    ${ngStatus}    ${status}
    selenium_coam.logout

Get cOAM CU History Alarm Info
    [Documentation]
    ...                Description: Keyword for getting history alarm information shown in Alarm History page.
    ...                alarm_filter: str, default is None if no filter element input, all alarm info will be captured
    ...                param timeout: int, timeout for the element be available to click
    #wait until keyword succeeds    10min    1min    siso_resource.WEBUI Login
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    ${alarms}    selenium_coam.get_active_alarm_info
    ${value}    get from dictionary    ${alarms[0]}    Alarm ID
    selenium_coam.logout

#add amf object on webui
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#    #selenium_coam.disable_message_box
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#    selenium_coam.add_object    object_name=${obiect_1}    object_class_name=SERVEDAMF    id_value=2
#    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SERVEDAMF-2
#    ...    filter_param=AMF IPv4/v6 Address
#    ...    new_value=${AMF_ip}
#    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SERVEDAMF-2
#    ...    filter_param=Administrative state
#    ...    new_value=Locked
#    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SERVEDAMF-2
#    ...    filter_param=Default AMF
#    ...    new_value=true
#    selenium_coam.validate_plan
#    sleep    3s
#    selenium_coam.activate_plan    activate_plan_despite_errors=True
#    selenium_coam.logout
#    selenium_coam.disable_virtual_display
#    sleep    5s

## GNB BTS Precondition ##
#Prepare the test suite
#    [Arguments]        ${tl_scf_filename}=${tl_scf_filename}
#    set suite variable    ${tl_scf_filename}
#    ${release_info}    Get gnb release
#    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Prepare the classical COAM BTS cell onair
#    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Prepare the classical COAM BTS cell onair
#    Run Keyword If    '${release_info}' == 'SBTS21B_ENB_0000'    Prepare the test suite for 20B

Prepare the test suite
    [Arguments]        ${tl_scf_filename}=${tl_scf_filename}
    set suite variable    ${tl_scf_filename}
    ${release_info}    Get gnb release
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Prepare the classical COAM BTS cell onair
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'    Prepare the classical COAM BTS cell onair
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'    Prepare the classical COAM BTS cell onair


Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

#Prepare with COAM classical BTS cell onair
#    Perform full commission for COAM gnb
#    Run Keyword And Ignore Error    Check gnb COAM classical start normally
#    Run Keyword And Ignore Error    Wait the gNB cell onair
#    ${release_info}    Get sagnb release
#    set suite variable    ${release_info}


Prepare with COAM classical BTS cell onair
    Perform full commission for COAM gnb
    Run Keyword And Ignore Error    Check gnb COAM classical start normally
#    Run Keyword And Ignore Error    Check cell status on webui    connection=Local gNB
    Check cell status on webui    connection=Local gNB
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Check cell status on webui
    [Arguments]    ${connection}
    Connect to gnb coam via ssl    connection=${connection}
    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

#Perform full commission for COAM gnb
#    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}    ${tl_scf_filename}=${tl_scf_filename}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
#    ...    selenium_coam.close_start_up_view_window
#    selenium_coam.load_commissioning_file_and_check_load_status    ${epc_log_path}${tl_scf_filename}
#    selenium_coam.validate_plan
#    selenium_coam.activate_plan    activate_plan_despite_errors=True
#    sleep    8s
#    selenium_coam.logout
#    sleep    1min

Perform full commission for COAM gnb
    [Arguments]    ${scf}=${tl_scf_dir_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${True}
    COAM Teardown gnb connections


Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}

prepare the test cases
    [Arguments]    ${parameters}    ${parameters_1}
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Modify parameters online for cases
    ...    parameters_to_update=${parameters}
    Run Keyword If    '${release_info}' == 'SBTS21B_ENB_0000'    Modify parameters online for cases
    ...    parameters_to_update=${parameters_1}
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Modify parameters online for cases
    ...    parameters_to_update=${parameters}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
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
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Check gnb COAM classical start normally
    #Check Airscale HW module status
    wait until keyword succeeds    15min   60s    Check the gnb RU status ready

#Check the gnb RU status ready
#    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
#    ...    selenium_coam.close_start_up_view_window
#    ${ru_status} =    selenium_coam.get_ru_info
#    sleep    8s
#    selenium_coam.logout
#    Get info status check    info_status=${ru_status}

#
#Check cell status on webui
#    [Arguments]    ${connection}
#    Connect to gnb coam via ssl    connection=${connection}
#    Verify all cells should be onair    connection=${connection}
#    [Teardown]    coam.teardown    connection=${connection}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    15min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    ${cell_status} =    selenium_coam.get_cell_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${cell_status}

Wait the gNB cell onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    wait until keyword succeeds    15min   1min    Check the gnb cell status onair    WEBUI_COAM=${WEBUI_COAM}

Get info status check
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    enabled
#    ${avi_state} =   get from dictionary    ${status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

#Common Suite Setup for COAM
#    COAM Create log directory    is_set_to_test_case_level=${False}
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}

Common Suite Teardown for AMF ZHOU
    wait until keyword succeeds    10 min    5 sec    Connect to AMF-ZHOU account    alias=UTE
    csn.execute    command=cmm amfGuamiStatusAdmin modify AMF5-zhou --maintenanceTimer 0 --guamiStatus supported
    ...    connection=UTE    #turn on amf account
#    connect to gnb coam via ssl
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}
#    COAM Teardown gnb connections

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Connect to ASIK slave
    [Arguments]    ${asik_slave}=${asik_slave}    ${proxy}=ASIK
    csn.Connect to    hostname=${fct_addr}    username=${asik_username}
    ...    password=${asik_password}    alias=${asik_slave}    proxy=${proxy}

Start To Capture Wireshark Logs
    [Arguments]    ${filename}
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Start capture gNB log on master
    ...    filename=${filename}
    Run Keyword If    '${release_info}' == 'SBTS21B_ENB_0000'    Start capture gNB log on slave
    ...    filename=${filename}
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'   Start capture gNB log on slave
    ...    filename=${filename}

#Start capture gNB log on master
#    [Arguments]    ${filename}
#    wait until keyword succeeds    1min   10s    gNB connections
#    csn.send command    command=tcpdump -i br1 sctp -w ${gnb_path}${filename}   connection=${ALIAS_ASIK}

Start capture gNB log on slave
    [Arguments]    ${filename}
    gNB connections
    Connect to ASIK slave
    csn.send command    command=tcpdump -i any sctp -w ./${filename}   connection=${asik_slave}

Stop and download Logs on gNB
    [Arguments]    ${filename}
    ${release_info}    Get gnb release
    Run Keyword If    '${release_info}' == 'SBTS22R2_ENB_9999'    Stop and download Logs on gNB on master
    ...    filename=${filename}
    Run Keyword If    '${release_info}' == 'SBTS21B_ENB_0000'    Stop and download the Logs on slave
    ...    filename=${filename}
    Run Keyword If    '${release_info}' == 'SBTS22R1_ENB_0000'    Stop and download the Logs on slave
    ...    filename=${filename}

Stop and download the Logs on slave
    [Arguments]    ${filename}
    gNB connections
    Connect to ASIK slave
    csn.send command    command=killall tcpdump     connection=${asik_slave}
    sleep    3s
    csn.send command    command=cp ./${filename} ${gNB_master_log}/${filename}    connection=${asik_slave}
    sleep    10s
    csn.download_file   remote_path=${gNB_master_log}/${filename}   local_path=${epc_log_path}${filename}
    ...    connection=${ALIAS_ASIK}
    sleep    3s

#Stop and download the Logs
#    [Arguments]    ${filename}
#    wait until keyword succeeds    1min   10s    gNB connections
#    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK}
#    sleep    3
#    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}
#    ...    connection=${ALIAS_ASIK}
#    sleep    3

Stop Logs capture
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK}

Stop and download Logs on gNB on master
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    Stop and download the Logs    filename=${filename}

Get the bts counter ${counter_id} from ${counter_path} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ...                 full_path=${counter_path}
    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    [return]    ${values}

Unlock the gNB cell
    [Arguments]    ${cell_idx}=${1}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    ${cell_idx}  Convert To Integer    ${cell_idx}
    selenium_coam.unlock_cell    cell_idx=${cell_idx}
    Sleep  30 sec
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Get gnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

COAM get cell id
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    ${info_cell1}    selenium_coam.get_cell_info    cell_idx=${1}
    #${info_cell2}    selenium_coam.get_cell_info    cell_idx=${2}
    set suite variable    ${cell1_id}    ${info_cell1['NR cell ID']}
    #set suite variable    ${cell2_id}    ${info_cell2['NR cell ID']}
    [Teardown]    selenium_coam.logout

#DL
Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_index}=${0}    ${gnb_index}=${0}
    ${list_of_cell_ids}    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Create list    17825791
    ...    ELSE    Create list    5816319
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expect_DOWNLINK}

Power UE stop dl traffic
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

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
