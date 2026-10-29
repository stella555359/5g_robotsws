*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000784

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
Library           taf.hw.rf_attenuator    WITH NAME    attenuator
#Library           sigspark.SigSpark    WITH NAME    spark
Library           taf.ue.plugin.mtk
Library           taf.ul.messaging.mtk      WITH NAME    mtk
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot

*** Variables ***
#${ue_type}    ${tl.ues[2].capabilities[0]}
${gnb_instance}    ${tl.gnbs[0].instance_id}
${ue_type}    ${tl.ues[0].capabilities[0]}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_COAM_LOCAL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${atten_ip}        ${tl.attenuator[1].ip_addr}
${5GRU_ANT9}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU_ANT10}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${tshark_path}      /usr/bin/tshark
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"ngap\"  -T pdml
${command_template_Y_s1ap}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml
${WEBUI_URL}      https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_addr}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${enb_address}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${att_port_1_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[12]}
#${att_port_1_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[9]}
#${att_port_2_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[10]}
#${att_port_3_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[11]}
#${att_port_4_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[12]}
${att_port_1_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[12]}
${att_ipaddr_gnb1_cell1_37611}                ${tl.attenuator[0].ip_addr}
#${att_ipaddr_gnb1_cell2_37611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_37611}                ${tl.attenuator[1].ip_addr}
${att_port_1_enb_cell_37611}                ${tl.attenuator[2].attenuator_ports[9]}
${att_ipaddr_enb_cell_37611}                ${tl.attenuator[2].ip_addr}

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

${att_port_1_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_37711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_37711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37711}                ${tl.attenuator[0].ip_addr}

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
@{gnb_id}    37611    37711    38811
${att_good}    ${0}
${att_bad}    ${127}
@{gnb_ips}    ${gnb_addr}
@{gnb_list}    ${0}
@{allow_fault_list}    7311    7107
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/

*** Keywords ***
#Common Suite Setup for COAM
#    COAM Create log directory_gNB2    is_set_to_test_case_level=${False}
#    ${time_stamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}

COAM Create log directory_gNB2
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    Generate suite log path_gNB2    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}

Generate suite log path_gNB2
    [Documentation]    Author: Ding Binmei [PRIVATE]
    ...                Description: Create log directory with test suite level and open a common variable ${SUITE_LOG_PATH}
    [Arguments]    ${timeout}=1min
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    Run keyword if    ${has_cbts}   wait until keyword succeeds    ${timeout}    2sec    Cloud DU connect to gnb coam via ssl
    ...    ELSE    wait until keyword succeeds   ${timeout}    2sec    Connect to gnb coam via ssl    gnb_index=0
    ${sw_version} =     coam.get_sw_version    connection=GNB_OAM
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Prepare with COAM classical BTS cell onair
    [Arguments]    ${scf_filename}=${tl_scf_filename}
    ...    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Perform full commission for COAM gnb    scf_filename=${scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}
    Check gnb COAM classical start normally
    Check the gnb cell status onair

Perform full commission for COAM gnb
    [Arguments]    ${scf_filename}    ${bts_host}    ${username}    ${password}    ${is_pdl_checking_needed}=${False}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${scf_filename}    timeout=600
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
#    Check Airscale HW module status
    Check the gnb RU status ready

Check the gnb RU status ready
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Modify NIDD parameter for 784_A
    [Arguments]    ${parameters_to_update}
    ...    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${600}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

check value of parameter algorithm
    [Arguments]    ${value1}=9    ${value2}=0    ${value3}=0
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM_LOCAL}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${algorithm_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${nea1_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=SNOW 3G-based algorithm    abbr=nea1_128
    ${return1}=    Run Keyword And Return Status    Should Be Equal    ${nea1_128_value}    ${value1}
    Run Keyword If    '${return1}' == 'True'    sleep    0.5s
    Run Keyword If    '${return1}' == 'False'    set value of parameter algorithm
    ...    filter_param=SNOW 3G-based algorithm
    ...    abbr=nea1_128    new_value=${value1}
    ${nea2_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=AES-based algorithm    abbr=nea2_128
    ${return2}=    Run Keyword And Return Status    Should Be Equal    ${nea2_128_value}    ${value2}
    Run Keyword If    '${return2}' == 'True'    sleep    0.5s
    Run Keyword If    '${return2}' == 'False'    set value of parameter algorithm    filter_param=AES-based algorithm
    ...    abbr=nea2_128    new_value=${value2}
    ${nea3_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=ZUC-based algorithm    abbr=nea3_128
    ${return3}=    Run Keyword And Return Status    Should Be Equal    ${nea3_128_value}    ${value3}
    Run Keyword If    '${return3}' == 'True'    sleep    0.5s
    Run Keyword If    '${return3}' == 'False'    set value of parameter algorithm    filter_param=ZUC-based algorithm
    ...    abbr=nea3_128    new_value=${value3}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter algorithm
    [Arguments]    ${filter_param}    ${abbr}    ${new_value}
    selenium_coam.set_parameter_value  dist_name=${algorithm_distname}
    ...    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s

Tear down wireshark log and detach
    run keywords
    ...    run keyword and ignore error    Teardown Stop Capture Wireshark Logs on gNB    AND
    ...    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}

Teardown Stop Capture Wireshark Logs on gNB
    [Arguments]    ${connection}=Local gnb1
    gNB connections to ssh    connection=${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=${connection}

784-A case teardown
    run keywords
    ...    Run Keyword And Ignore Error    Modify UE mobile data    action=enable    AND
    ...    Run Keyword And Ignore Error    Tear down wireshark log and detach    AND
    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
    ...    Run Keyword And Ignore Error    Tear down the connections    AND
    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

#Common Suite Teardown for COAM
#    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
#    robot_common_operations.Common Suite Teardown
#    Run keyword if    '${SUITE STATUS}' == 'FAIL'    Run keyword and continue on failure
#    ...    COAM Save all gnb snapshot via api    gnb_list=${gnb_list}    log_path=${log_path}
#    [Teardown]  Run keyword and ignore error    Tear Down The Connections

#COAM Save all gnb snapshot via api
#    [Arguments]    ${gnb_list}=${gnb_list}    ${log_path}=${epc_log_path}
#    FOR    ${index}    IN    @{gnb_list}
#        COAM Save snapshot via api    gnb_index=${index}    log_path=${log_path}
#    END

#COAM Save snapshot via api
#    [Arguments]    ${gnb_index}=${0}    ${log_path}=${epc_log_path}
#    Connect to gnb coam via ssl    connection=gnb${gnb_index}    bts_host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
#    COAM Save snapshot via rest api    connection=gnb${gnb_index}    log_path=${log_path}    timeout=900
#    coam.teardown    connection=gnb${gnb_index}

### MTK UE ###
784 UE attach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Expect MTK Attach Messages
    enable_vonr_capability    alias=UE_${ue_index}
    sleep    5s

Expect MTK Attach Messages
    ${Attach Expected Messages} =    Create List     5GMM_REGISTRATION_ACCEPT
    mtk.Expect Messages in Flow    awaited_messages=${Attach Expected Messages}    flow_alias=MTK_OTA_MESSAGE

Make a emergency call
    [Arguments]    ${ue_index}=${0}    ${vc_alias}=test_voice_call
    start_voice_call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=911
    Sleep    30
    stop_voice_call    vc_alias=${vc_alias}
    Sleep    15

Make a VoNR call
    [Arguments]    ${to}    ${ue_index}=${0}    ${vc_alias}=test_voice_call
    start_voice_call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${to}
    Sleep    10
    stop_voice_call    vc_alias=${vc_alias}
    Sleep    5

Make EMC call on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

hang up EMC call on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 285 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

kill the call procedure
    Connect to control pc via cygwin    ue_index=${0}
    hang up EMC call on samsung UE
    csn.disconnect      connection=cygwin

Modify UE mobile data
    [Arguments]    ${ue_index}=${0}    ${action}=disable    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell svc data ${action} &    connection=cygwin
    sleep    2
    [Teardown]    csn.disconnect      connection=cygwin

### PA adjust ###
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Run Keyword If    '${gnb_instance}'!='${gnb_id[0]}'
    ...    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Run Keyword If    '${gnb_instance}'!='${gnb_id[0]}'
    ...    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Run Keyword If    '${gnb_instance}'!='${gnb_id[0]}'
    ...    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}

Adjust one port attenuation
    [Arguments]     ${tl}=${gnb_instance}    ${gnb1_cell1_value}='NULL'
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}

    ###Adjust the HBTE attenuation value###
    run keyword if  not ${gnb1_cell1_value}=='NULL'
    ...    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}

Adjust enb attenuation
    [Arguments]     ${tl}=${gnb_instance}    ${enb_cell_value}=${127}
    ####create cell list#####
    @{att_ports_enb_cell}    Create List    ${att_port_1_enb_cell_${tl}}

    ###create value list####
    @{values_enb_cell}    Create List    ${enb_cell_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb_cell}    values=${values_enb_cell}
    ...    att_connection_port=${att_port_1_enb_cell_${tl}}    att_ipaddr=${att_ipaddr_enb_cell_${tl}}

Set HBTE attenuation
    [Arguments]    ${port1}=${5Gcell1_ANT1}    ${port2}=${5Gcell1_ANT2}    ${port3}=${5Gcell1_ANT3}
    ...    ${port4}=${5Gcell1_ANT4}    ${origin_value}=${0}    ${target_value}=${50}
    add attenuation for 1db 4 port    port1=${port1}    port2=${port2}
    ...    port3=${port3}    port4=${port4}    origin_value=${origin_value}    target_value=${target_value}

add attenuation for 1db 4 port
    [Arguments]    ${port1}    ${port2}    ${port3}    ${port4}    ${origin_value}    ${target_value}
    atten.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${port1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    atten.set_attenuation     port=${port1}    value=${origin_value}
    atten.set_attenuation     port=${port2}    value=${origin_value}
    atten.set_attenuation     port=${port3}    value=${origin_value}
    atten.set_attenuation     port=${port4}    value=${origin_value}
    FOR  ${origin_value}    IN RANGE    ${target_value}
       ${origin_value}    evaluate     ${origin_value}+1
       atten.set_attenuation     port=${port1}    value=${origin_value}
       atten.set_attenuation     port=${port2}    value=${origin_value}
       atten.set_attenuation     port=${port3}    value=${origin_value}
       atten.set_attenuation     port=${port4}    value=${origin_value}
       sleep    1s
    END

Get release info
    ${release_info}    Get sagnb release
    Set Suite Variable    ${release}    ${release_info}

#Get sagnb release title
#    [Documentation]    the keyword return realse format : SBTS24R3_ENB_9999
#    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3][0]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info

#Get sagnb release
#    [Arguments]   ${host}=${gnb_addr}   ${username}=${gnb_username}   ${password}=${gnb_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
##    ${release_info}     set variable    ${info.split('_')[1]}
#    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info


### log analyze ###
Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}    ${connection}
    ...    ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    gNB connections to ssh    connection=${connection}
    ...    hostname=${hostname}    username=${username}    password=${password}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}    connection=${connection}
    sleep    3s
    [Teardown]    csn.disconnect    connection=${connection}

#Get gnb time
#    [Arguments]     ${connection}=Local gnb1
#    ...    ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
#    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
#    gNB connections to ssh    connection=${connection}
#    ...    hostname=${hostname}    username=${username}    password=${password}
#    ${utc0} =    Get Time    epoch
#    sleep    3s
#    [Teardown]    csn.disconnect    connection=${connection}
#    [Return]    ${utc0}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${connection}
    ...    ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    gNB connections to ssh    connection=${connection}
    ...    hostname=${hostname}    username=${username}    password=${password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}
    ...    connection=${connection}
    sleep    3
    [Teardown]    csn.disconnect    connection=${connection}

gNB connections to ssh
    [Arguments]    ${connection}
    ...    ${hostname}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    csn.Connect To    hostname=${hostname}
    ...               username=${username}
    ...               password=${password}
    ...               alias=${connection}

Check wireshark log for VoNR
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}

Check wireshark log for successful EC procedure
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC release    logname=${logname}

Check wireshark log for successful EC procedure_idle
    [Arguments]    ${logname}
    Check wireshark log for EC initial UE massage    logname=${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5_idle    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC release    logname=${logname}

Check wireshark log for EC setup
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 46 and nas-5gs.mm.req_type == 3)
    ...    xpath_filter=nas-5gs.mm.req_type    expect_value=3

Check wireshark log for EC 5QI 1
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 26 and ngap.fiveQI == 1)
    ...    xpath_filter=ngap.fiveQI    expect_value=1
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 26 and ngap.priorityLevelARP == 1)
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 5
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 29 and ngap.fiveQI == 5)
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 29 and ngap.priorityLevelARP == 1)
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 5_idle
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.fiveQI == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC release
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
    ...    xpath_filter=ngap.nas    expect_value=0
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28
    ...    xpath_filter=ngap.PDUSessionResourceReleaseResponse_element
    ...    expect_value=PDUSessionResourceReleaseResponse
    ...    attribute_name=showname

Check wireshark log for failed VoNR call_5QI1
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.radioNetwork == 22
    ...    xpath_filter=ngap.radioNetwork    expect_value=22

Check wireshark log for failed VoNR call_5QI5
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.radioNetwork == 22
    ...    xpath_filter=ngap.radioNetwork    expect_value=22

Check UE in idle status
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 42 and ngap.radioNetwork == 20
    ...    xpath_filter=ngap.radioNetwork    expect_value=20
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 41 and ngap.radioNetwork == 20
    ...    xpath_filter=ngap.radioNetwork    expect_value=20

Check wireshark log for EC initial UE massage
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 15 and ngap.RRCEstablishmentCause == 0
    ...    xpath_filter=ngap.RRCEstablishmentCause    expect_value=0

Check wireshark log for successful EC and detached release_idle
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5_idle    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 41 and ngap.nas == 2
    ...    xpath_filter=ngap.nas    expect_value=2
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 41
    ...    xpath_filter=ngap.UEContextReleaseComplete_element
    ...    expect_value=UEContextReleaseComplete
    ...    attribute_name=showname

Check wireshark log for EC EPS fallback
    [Arguments]    ${gnblogname}    ${enblogname}
    log to console    check gnb PDU ResourceModify cause is
    ...    radioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered (36)for 5qi1 fail
    Check wireshark log for VoNR    logname=${gnblogname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.radioNetwork == 36
    ...    xpath_filter=ngap.radioNetwork    expect_value=36
    log to console    check gnb UEcontextReleaseRequest for redirection
    Check wireshark log for VoNR    logname=${gnblogname}
    ...    message_filter=ngap.procedureCode == 42
    ...    xpath_filter=ngap.radioNetwork    expect_value=41
    log to console    check gnb UEcontextReleaseRequest for redirection
    Check wireshark log for VoNR    logname=${gnblogname}
    ...    message_filter=ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
    ...    xpath_filter=ngap.procedureCode    expect_value=41
    log to console    check enb TAU
    Check wireshark log for VoNR    logname=${enblogname}
    ...    command_template=${command_template_Y_s1ap}
    ...    message_filter=s1ap.procedureCode == 12 and s1ap.RRC_Establishment_Cause == 0
    ...    xpath_filter=s1ap.RRC_Establishment_Cause    expect_value=0
    Check wireshark log for VoNR    logname=${enblogname}
    ...    command_template=${command_template_Y_s1ap}
    ...    message_filter=s1ap.procedureCode == 9 and nas-eps.nas_msg_emm_type == 0x49
    ...    xpath_filter=nas-eps.nas_msg_emm_type    expect_value=0x49
    Check wireshark log for VoNR    logname=${enblogname}
    ...    command_template=${command_template_Y_s1ap}
    ...    message_filter=s1ap.procedureCode == 13 and nas-eps.nas_msg_emm_type == 0x4a
    ...    xpath_filter=nas-eps.nas_msg_emm_type    expect_value=0x4a
#    log to console    check enb default EPS bearer for QCI 5
#    Check wireshark log for VoNR    logname=${enblogname}
#    ...    command_template=${command_template_Y_s1ap}
#    ...    message_filter=s1ap.procedureCode == 5 and s1ap.qCI == 5
#    ...    xpath_filter=s1ap.qCI    expect_value=5
#    Check wireshark log for VoNR    logname=${enblogname}
#    ...    command_template=${command_template_Y_s1ap}
#    ...    message_filter=s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 194
#    ...    xpath_filter=nas_eps.nas_msg_esm_type    expect_value=194
    log to console    check enb dedicated EPS bearer for QCI 1
    Check wireshark log for VoNR    logname=${enblogname}
    ...    command_template=${command_template_Y_s1ap}
    ...    message_filter=s1ap.procedureCode == 5 and s1ap.qCI == 1
    ...    xpath_filter=s1ap.qCI    expect_value=1
    Check wireshark log for VoNR    logname=${enblogname}
    ...    command_template=${command_template_Y_s1ap}
    ...    message_filter=s1ap.procedureCode == 13 and nas-eps.nas_msg_esm_type == 0xc6
    ...    xpath_filter=nas-eps.nas_msg_esm_type    expect_value=0xc6
#    log to console    check eps fallback EC release
#    Check wireshark log for VoNR    logname=${enblogname}
#    ...    command_template=${command_template_Y_s1ap}
#    ...    message_filter=s1ap.procedureCode == 7 and s1ap.nas == 0
#    ...    xpath_filter=s1ap.nas    expect_value=0
#    Check wireshark log for VoNR    logname=${enblogname}
#    ...    command_template=${command_template_Y_s1ap}
#    ...    message_filter=s1ap.procedureCode == 13 and nas_eps.nas_msg_esm_type == 206
#    ...    xpath_filter=nas_eps.nas_msg_esm_type    expect_value=206

Check wireshark log for EC ongoing
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC not release unusual    logname=${logname}

Check wireshark log for EC ongoing_idle
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5_idle    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC not release unusual    logname=${logname}

Check wireshark log for EC not release unusual
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template_Y}
    ${filter_expression}=     Catenate    ngap.procedureCode == 42
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.UEContextReleaseRequest_element    attribute_name=showname
    should be empty    ${filtered_value}

### enb ###
enb connection
    [Arguments]    ${alias}=enb
    csn.Connect To    hostname=${enb_address}    username=${enb_username}    password=${enb_password}    alias=${alias}

Commit SCF to eNB
    [Arguments]    ${eNB_asik_addr}=${enb_address}    ${scf_file}=${scf_file_enb}    ${connection}=eNB
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300

eNB start capture wireshark log
    [Arguments]    ${filename}     ${interface}=any    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

eNB stop and Save classical Logs
    [Arguments]    ${filename}    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}
    ...    connection=${connection}
    sleep    3
    csn.disconnect      connection=${connection}

eNB stop wireshark log_teardown
    [Arguments]    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.disconnect      connection=${connection}

### counter ###
Check the PM counter shuould be specific value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
        ...    dic_path=${dic_path[${index}]}    timeout=300
        Should be equal    ${counter_value[0]}    ${value}
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counter shuould not be zero
    [Arguments]    ${counter_id}    ${dic_path}
    ${counter_result_value}    Create List
    ${counter_result}    Create List
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
        ...    dic_path=${dic_path[${index}]}    timeout=300
        ${counter_dict}    Create Dictionary    ${counter_id[${index}]}=${counter_value[0]}
        append to list    ${counter_result_value}    ${counter_value[0]}
        append to list    ${counter_result}    ${counter_dict}
    END
    ${counter_result_lenth}    Get Length    ${counter_result_value}
    Should be equal    ${counter_lenth}    ${counter_result_lenth}
    Should not contain    ${counter_result_value}    ${0}    msg=check counter fail
    [Teardown]    COAM Teardown gnb connections

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3    Record time again
#    ${utc_left} =    Evaluate    5-${utc_min}+1
    ${utc_left} =    Evaluate    5-${utc_min}
    set test variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get gnb time
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

########### xiaomi ##################
Get all xiaomi11 pointer variable for 376
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1265 2095
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    730 2990
    Set Suite Variable    ${stop_call}    712 2970

Get all xiaomi11 pointer variable for 377
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    940 1640
    Set Suite Variable    ${close_task}    540 2175
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    550 1700 550 1200
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1131 411
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    530 2260
    Set Suite Variable    ${stop_call}    540 2140

Get all xiaomi11 pointer variable for 388
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1251 2208
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    730 2990
    Set Suite Variable    ${stop_call}    712 2970

Prepare Xiaomi UE
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    capatibility_index=${0}
    ...    reset_sol=none    detach_request=${true}
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable for 377
    ...    ELSE    Get all xiaomi11 pointer variable for 388

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}=False
    Wait until keyword succeeds    3X    10s    Check phone attach successfully    4G_check=${4g_check}

Power UE attach and check UE in idle status
    [Arguments]    ${nglogname}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface1}    connection=Local gnb1
    Power UE Attach and Verify attach
    Modify UE mobile data    action=disable
    sleep    15s
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    connection=Local gnb1
    Check UE in idle status    logname=${nglogname}

Check phone attach successfully
    [Arguments]    ${4g_check}    ${gnb_index}=${0}
    unlock the screen    ue_index=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=xiaomi    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=xiaomi    5Grach_ed=${5Grach_ed}    4G_check=${4g_check}
    ...    ue_index=${0}    gnb_index=${gnb_index}

unlock the screen
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}


Start a emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cygwin
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:${phone_number}
    ...    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${start_call}
    ...    connection=${connection}
    sleep    30s

Stop the emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${connection}=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap ${stop_call}
    ...    connection=${connection}
    sleep    20s

Start a VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${connection}=cygwin
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 720 2897
    ...    connection=${connection}
    sleep    15s

Stop the VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${connection}=cygwin
    csn.send_command    command=adb -s ${serial_number} shell input tap 724 2783
    ...    connection=${connection}
    sleep    5s

Lock LTE
    Run keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Adjust enb attenuation
    ...    ELSE    Locked LTE cell tl388

Locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Locked LTE cell tl388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

UnLock LTE
    Run keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Adjust enb attenuation
    ...    ELSE    Unlocked LTE cell 388

Unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Unlocked LTE cell 388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Start traffic xiaomi
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_type}=via_app    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1400B    ${cap_index}=${0}
    ...            &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC xiaomi   ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...                                                                                     cap_index=${cap_index}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}
    ...                                                                                            iperf_type=${iperf_type}

Start DL traffic and check the TP on EPC xiaomi
    [Documentation]    stat DL traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    ...    :param  protocal: Traffic protocal type. E.G udp/tcp
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    ...            ${process_num}=${1}    ${seg_size}=1180    ${window}=2M    ${cap_index}=${cap_index}
    run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with first UE xiaomi   ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       cap_index=${cap_index}
    ...    ELSE    Start DL TCP traffic and check the TP on EPC with first UE    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}
    ...                                                       process_num=${process_num}
    ...                                                       seg_size=${seg_size}
    ...                                                       window=${window}

Start DL traffic and check the TP on EPC with first UE xiaomi
    [Arguments]
    ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B
    ...            ${process_num}=${1}    ${cap_index}=${cap_index}
    Get Commercial UE IP xiaomi   ue_index=${ue_index}    cap_index=${cap_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Get Commercial UE IP xiaomi
    [Arguments]    ${ue_index}=${0}   ${cap_index}=${0}    ${capabilities}=${tl.ues[${ue_index}].capabilities[${cap_index}]}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin    ue_index=${ue_index}
    run keyword if    '${capabilities}'=='HUAWEI_MATE30PRO' or '${capabilities}'=='xiaomi' or '${capabilities}'=='samsungS21'
    ...    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep inet | grep -v ims00 | cut -d '/' -f 1 |tail -n -2 |head -1 |awk '{print $2}'
    ...    ELSE IF    '${capabilities}'=='samsung'
    ...    Get Commercial UE IP with first UE    ue_index=${ue_index}
    ...    command=adb -s ${serial_number} shell ip -f inet addr |grep 'scope global' | cut -d '/' -f 1 |head -n 1|awk '{print $2}'
    ...    ELSE    Get Commercial UE IP with first UE    ue_index=${ue_index}

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