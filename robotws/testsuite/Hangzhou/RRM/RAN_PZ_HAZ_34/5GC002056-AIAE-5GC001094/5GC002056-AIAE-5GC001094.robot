# *** Settings ***
# Force Tags    PY36
# Suite Setup
# Suite Teardown
# Documentation
# ...   author: xiaofeng.1.zhu@nokia-sbell.com
# ...   contact: xiaofeng.1.zhu@nokia-sbell.com
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Variables         Resources/5GC002056_modify_para.py
# Library           Resources/5GC002056_AIAE.py
# Library           taf.transport.ssh    WITH NAME    csn
# Library           taf.hw.rf_attenuator    WITH NAME    att
# Library           taf.ue  WITH NAME   ute_ue
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/UEs/inseego.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           ./Resources/common_keyword.py
#
# *** Variables ***
# ${default_scf_path}           ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
# ${DU_OAM_IP_URL}            https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_IP}         ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_WEBUI_USER}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_OAM_IP_TL}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DU_OAM_SSH_USERNAME_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${DU_OAM_SSH_PASSWORD_TL}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${ENB_IP}                      ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${ENB_USERNAME}                ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
# ${ENB_PASSWORD}                ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
# ${ru_alias}   RU
# ${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
# ${DU_OAM_IP}                  ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${IPERF_ADDR}                 ${tl.appserver.iperf_details.network_interface_address}
# ${IPERF_PORT}                 ${tl.appserver.iperf_details.port}
#
# ${att_ipaddr}                ${tl.attenuator.ip_addr}
# ${att_connection_port}       ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_api_port}              ${tl.attenuator.port}
# ${att_port_5}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_6}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_7}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_8}                ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# ${att_port_11}               ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
# ${att_port_12}               ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
# ${att_port_13}               ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
# ${att_port_14}               ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
#
# ${appserver_addr}            ${tl.ues[1].iperf_details.ssh_connection_details.addr}
# ${connection}                GNB_OAM
# ${max_attenuation_value}     ${127}
# ${vendor}                    HBTE
# ${luashark_path}             /opt/ute/luashark/luashark_script/generated_luashark
# ${TS_CASE_LOG_PATH}          ${output_dir}
# ${epc_log_path}              /tmp
# ${source}                    ${output_dir}/gnb_tcpdump.pcap
# ${target}                    ${output_dir}/gnb_tcpdump.txt
# ${target2}                   ${output_dir}/gnb_RSRP_RSRQ.txt
# ${target4}                   ${output_dir}/enb_tcpdump.txt
# ${target5}                   ${output_dir}/CELL_ID.txt
# ${target6}                   ${output_dir}/checkmeas.txt
# ${filter}                    nr-rrc.servCellIndex && nr-rrc.physCellId
# ${filter2}                   nr-rrc.servCellId && nr-rrc.rsrq
# ${filter3}                   nr-rrc.measId
# ${filter10}                  ip.src == ${DU_OAM_IP_TL} &&nr-rrc.measId
# ${filter7}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 32
# ${filter8}                   x2ap.X2AP_PDU == 0 && x2ap.procedureCode == 5
# ${throughput}                100M
# ${direction1}                 ul
# ${direction2}                 dl
#
#
# *** Test Cases ***
# #[1]5GC001094_G_409_PSCell_change_without_SRB3_CFRA_spilt_mode_60MHz
# #    [Documentation]    PSCell change without SRB3 CFRA spilt mode 60MHz
# #    [Tags]     CB002056-AIAG    CRT_21A
# #    [Setup]
# #    ${CURDIR_path}    Prepare default scf     common_load_scf=SCF_SBTS00_3.xml     other_scf=SCF_0.800_3.xml
# #    Setup Commission SCF    CURDIR_path=${CURDIR_path}
# #    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# #    ${cell_ID_1}    ${cell_ID_2}    Get cell information
# #    4G HBTE attenuation value    value_1=${10}    value_2=${10}    value_3=${40}    value_4=${40}
# #    Adjust the HBTE attenuation value    value_1=${40}    value_2=${40}    value_3=${40}    value_4=${40}
# #    Log and attach
# #    ${CELL_ID}    Check log cell ID
# #    start switch    CELL_ID=${CELL_ID}    First_CELL_ID=${CELL_ID}    cell_ID_1=${cell_ID_1}    cell_ID_2=${cell_ID_2}
# #    run keyword and continue on failure     Check RSRP RSRQ data
# #    Check throughput and Stop traffic
# #    [Teardown]  run keyword and ignore error    End attach and log
#
# [1]5GC001094_G_016_PSCell_change_A3_and_A5_enable_spilt_mode
#     [Documentation]    PSCell change A3 and A5 enable spilt mode
#     [Tags]       CRT_TRUNK       CRT_22R1
#     [Setup]
#     ${CURDIR_path}    Prepare default scf     common_load_scf=SCF_SBTS00_3.xml     other_scf=SCF_0.800_3.xml
#     Setup Commission SCF    CURDIR_path=${CURDIR_path}
#     Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber0}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber1}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber2}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber3}
#     Modify Common parameter via Coam    input_list=${PARAMS_TO_MODIFY_DomainNumber4}
#     Modify Value On DU     structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber5}    class_name=NRCELL_A    keywords_list=${keywords_list1}
#     Modify Value On DU     structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber6}    class_name=NRCELL_A    keywords_list=${keywords_list1}
#     Modify Value On DU     structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber7}    class_name=NRCELL_A    keywords_list=${keywords_list1}
#     Modify Value On DU     structure_modify_list=${PARAMS_TO_MODIFY_DomainNumber8}    class_name=NRCELL_A    keywords_list=${keywords_list1}
#     Log and attach
#     sleep    10s
#     run keyword and continue on failure    Check throughput and Stop traffic
#     Check data
#     [Teardown]  run keyword and ignore error    End attach and log
#
# #[1]5GC001094_G_301_PSCell_change_with_initial_Blacklisting_configuration
# #    [Documentation]    PSCell change with initial Blacklisting configuration
# #    [Tags]     CB002056-AIAG    CRT_21A
# #    [Setup]
# #    ${CURDIR_path}    Prepare default scf     common_load_scf=SCF_SBTS00_2.xml     other_scf=SCF_0.800_2.xml
# #    Setup Commission SCF    CURDIR_path=${CURDIR_path}
# #    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# #    ${cell_ID_1}    ${cell_ID_2}    Get cell information
# #    Adjust the HBTE attenuation value    value_1=${25}    value_2=${25}    value_3=${40}    value_4=${40}
# #    Log and attach
# #    ${CELL_ID}    Check log cell ID
# #    should be equal as numbers    ${CELL_ID}    ${cell_ID_1}
# #    Cell switch    CELL_ID=${CELL_ID}    First_CELL_ID=${CELL_ID}    cell_ID_1=${cell_ID_1}    cell_ID_2=${cell_ID_2}
# #    Check throughput and Stop traffic
# #    [Teardown]  run keyword and ignore error    End attach and log
#
# *** Keywords ***
# Prepare default scf
#     [Arguments]    ${common_load_scf}     ${other_scf}
#     ${connection}    coam.connect_to    bts_host=${DU_OAM_WEBUI_IP}     name=GNB_OAM
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS
#     ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}${common_load_scf}
#     ...    ${default_scf_path}${other_scf}
#     log to console   ${default_scf}
#     [Return]     ${default_scf}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
#
# Get cell information
#     [Arguments]    ${target}=${target5}
#      coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
#      ${INFO}    coam.get_cells_info    connection=${connection}
#      coam.teardown       connection=${connection}
#      text_save    ${target}    ${INFO}
#      csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#      csn.Send Command
#      ...    command=cat ${target} |grep physicalCellId |cut -d ' ' -f 3|awk '{print}' |sort -n|head -1
#      ...    connection=${connection}
#      ${cell_1}  csn.Read Output    connection=${connection}
#      ${cell_1}  strip_string    ${cell_1}
#      csn.Send Command
#      ...    command=cat ${target} |grep physicalCellId |cut -d ' ' -f 3|awk '{print}' |sort -n|tail -n 1
#      ...    connection=${connection}
#      ${cell_2}  csn.Read Output    connection=${connection}
#      ${cell_2}  strip_string    ${cell_2}
#
#      ${cell_1}    Evaluate    ${cell_1}*1
#      ${cell_2}    Evaluate    ${cell_2}*1
#
#      ${cell_ID_1}    set variable if    '${cell_1}'>'${cell_2}'    ${cell_2}    ${cell_1}
#      ${cell_ID_2}    set variable if    '${cell_1}'>'${cell_2}'    ${cell_1}    ${cell_2}
#      log to console    Cell_1:${cell_ID_1}----Cell_2:${cell_ID_2}
#      [Return]    ${cell_ID_1}    ${cell_ID_2}
#      [Teardown]    Delete file
#
# Delete file
#     [Arguments]    ${target}=${target5}
#     run keyword and ignore error    coam.teardown       connection=${connection}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}\
#     csn.Send Command    command=cat ${target} -r    connection=${connection}
#     [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}
#
# Check data
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter3}
#     csn.Send Command
#     ...    command=cat ${target} |grep SS-RSRQ |cut -d '(' -f 2|awk '{print}' |tail -n 2 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ1}  csn.Read Output    connection=${connection}
#     ${RSRQ1}  strip_string    ${RSRQ1}
#     csn.Send Command
#     ...    command=cat ${target} |grep SS-RSRQ |cut -d '(' -f 2|awk '{print}' |tail -n 1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ2}  csn.Read Output    connection=${connection}
#     ${RSRQ2}  strip_string    ${RSRQ2}
#     should be equal as numbers    ${RSRQ1}    ${68}
#     should be equal as numbers    ${RSRQ2}    ${69}
#     csn.Send Command
#     ...    command=cat ${target} |grep reportOnLeave |cut -d ':' -f 2|awk '{print}' | awk '$1=$1' |tail -n 1
#     ...    connection=${connection}
#     ${report}  csn.Read Output    connection=${connection}
#     ${report}  strip_string    ${report}
#     should be equal as strings    ${report}    True
#     csn.Send Command
#     ...    command=cat ${target} |grep reportInterval |cut -d 's' -f 2|cut -d '(' -f 1|awk '{print}'
#     ...    connection=${connection}
#     ${MS}  csn.Read Output    connection=${connection}
#     ${MS}  strip_string    ${MS}
#     should not be empty    ${MS}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Modify Value On DU
#     [Arguments]    ${structure_modify_list}    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=GNB_connection
#     ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0    ${gNB_ip}=${DU_OAM_IP_TL}
#     coam.connect_to    bts_host=${gNB_ip}   name=${connection}
#     run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
#     ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
#
# Modify Structure parameter via Coam
#     [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
#     ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
#     ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
#     ...    keywords_list=${keywords_list}
#     FOR    ${item}  IN  @{output_dict_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#          sleep  1min
#     END
#
# Get Content From Input Dict
#     [Arguments]  ${input_dict}
#     ${dist_name}    get from dictionary     ${input_dict}    dist_name
#     ${parammeter}    get from dictionary    ${input_dict}    parameter
#     ${new_value}     get from dictionary    ${input_dict}    value
#     ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
#     [Return]  ${value_list}
#
# Log and attach
#     Get ENB LOG
#     start extract log
#     power_ue.Prepare UE    ue_type=askey_sigspark    ue_index=${0}
#     log to console    UE Attach
#     power_ue.UE Attach    ue_type=askey_sigspark    ue_index=${0}
#     sleep    5s
#     log to console    Verify Attach
#     power_ue.Verify attach    ue_type=askey_sigspark    ue_index=${0}
#     end ENB LOG
#     end extract log
#     log to console    Start traffic
#     power_ue.Start traffic    ue_type=askey_sigspark
#     ...    direction=${direction1}    throughput=100M    duration=3600    ue_index=${0}    ue_mode=NSA
#     power_ue.Start traffic    ue_type=askey_sigspark
#     ...    direction=${direction2}    throughput=100M    duration=3600    ue_index=${0}    ue_mode=NSA
#     sleep    10s
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction1}
#     ...     ue_index=${0}    throughput=20
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction2}
#     ...     ue_index=${0}    throughput=20
#
# Check throughput and Stop traffic
#     power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction1}    ue_index=${0}    throughput=20
#     power_ue.Check throughput    ue_type=askey_sigspark    direction=${direction2}    ue_index=${0}    throughput=20
#     power_ue.Stop traffic    ue_type=askey_sigspark    direction=${direction1}    ue_index=${0}    ue_mode=NSA
#     power_ue.Stop traffic    ue_type=askey_sigspark    direction=${direction2}    ue_index=${0}    ue_mode=NSA
#     run keyword and ignore error    csn.Disconnect	connection=${connection}
#     run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${0}
#
# Setup Commission SCF
#     [Arguments]    ${CURDIR_path}
#     Connect to gnb coam via ssl
#     log to console    connect successful
#     COAM Commission with scf file    scf_file_path=${CURDIR_path}
#     Wait Until Keyword Succeeds   16min   2min     Check cell on air for AIAE
#     [Teardown]    Run Keyword And Ignore Error    coam.teardown    connection=${connection}
#
# Check cell on air for AIAE
#     log_to_console    Check cell on air
#     ${status}            coam.get_bts_statuses       connection=GNB_OAM
#     ${bts_status}        get from dictionary     ${status}     proceduralState
#     should be equal      ${bts_status}      OnAir
#
# Adjust the HBTE attenuation value
#     [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_5}
#     ...    ${att_port2}=${att_port_6}    ${att_port3}=${att_port_7}    ${att_port4}=${att_port_8}
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_connection_port}
#     ...    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#     att.set_attenuation     port=${att_port1}    value=${value_1}
#     att.set_attenuation     port=${att_port2}    value=${value_2}
#     att.set_attenuation     port=${att_port3}    value=${value_3}
#     att.set_attenuation     port=${att_port4}    value=${value_4}
#     ${value_port1}    att.read_attenuation    port=${att_port1}
#     should be equal    ${value_port1}    ${value_1}
#     ${value_port2}    att.read_attenuation    port=${att_port2}
#     should be equal    ${value_port2}    ${value_2}
#     ${value_port3}    att.read_attenuation    port=${att_port3}
#     should be equal    ${value_port3}    ${value_3}
#     ${value_port4}    att.read_attenuation    port=${att_port4}
#     should be equal    ${value_port4}    ${value_4}
#
# 4G HBTE attenuation value
#     [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_11}
#     ...    ${att_port2}=${att_port_12}    ${att_port3}=${att_port_13}    ${att_port4}=${att_port_14}
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_connection_port}
#     ...    max_attenuation=${max_attenuation_value}    vendor=${vendor}
#     att.set_attenuation     port=${att_port1}    value=${value_1}
#     att.set_attenuation     port=${att_port2}    value=${value_2}
#     att.set_attenuation     port=${att_port3}    value=${value_3}
#     att.set_attenuation     port=${att_port4}    value=${value_4}
#     ${value_port1}    att.read_attenuation    port=${att_port1}
#     should be equal    ${value_port1}    ${value_1}
#     ${value_port2}    att.read_attenuation    port=${att_port2}
#     should be equal    ${value_port2}    ${value_2}
#     ${value_port3}    att.read_attenuation    port=${att_port3}
#     should be equal    ${value_port3}    ${value_3}
#     ${value_port4}    att.read_attenuation    port=${att_port4}
#     should be equal    ${value_port4}    ${value_4}
#
# Convert pcap to text
#     [Arguments]    ${source}    ${target}    ${connection}    ${filter}
#     ssh.send_command
#     ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
#     ssh.await execution end  connection=${connection}  timeout=30min
#
# Convert pcap file to txt
#     [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
#     csn.Send Command  command=cat ${target} |grep physCellId |cut -d ':' -f 2|awk 'END {print}'
#     ...    connection=${connection}
#     ${CELL_ID}  csn.Read Output    connection=${connection}
#     ${CELL_ID}  strip_string    ${CELL_ID}
#     log to console  physCellId=${CELL_ID}
#     [Return]    ${CELL_ID}
#     [Teardown]    run keyword and ignore error  csn.Disconnect	connection=${connection}
#
# start extract log
#     ${connection_1}    csn.connect_to   hostname=${DU_OAM_IP_TL}
#     ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
#     csn.Send Command   command=ifconfig |grep br |head -1|cut -d ':' -f 1     connection=${connection_1}
#     ${br}    csn.Read Output    connection=${connection_1}
#     ${br}    strip_string    ${br}
#     csn.Send Command   command=cd /ffs/run && tcpdump -n -i ${br} -w /tmp/gnb_tcpdump.pcap    connection=${connection_1}
#     log to console  start pmut extract log successful
#     sleep    3s
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}​​​​​
#
# end extract log
#     ${connection_1}    csn.connect_to   hostname=${DU_OAM_IP_TL}
#     ...    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}    alias=VM
#     csn.Send Command  command=ps -ef | grep tcpdump | grep -v grep | grep gnb_tcpdump.pcap |tail -n 1 |awk '{print $2}'
#     ...    connection=${connection_1}
#     ${PID}  csn.Read Output    connection=${connection_1}
#     ${PID}  strip_string    ${PID}
#     log to console  Extract log successful
#     log to console  PID output: ${PID}
#     csn.Send Command  command=kill ${PID}    connection=${connection_1}
#     Wireshark DownloadLog
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}
#
# start switch
#     [Arguments]    ${CELL_ID}    ${First_CELL_ID}    ${cell_ID_1}    ${cell_ID_2}    ${NUM}=${40}    ${NUM1}=${40}    ${NUM2}=${40}
#     ${ID}    set variable if    '${CELL_ID}'=='${cell_ID_1}'    ${cell_ID_2}    ${cell_ID_1}
# #    ${RSRQ}  ${RSRP}    Check RSRP and RSRQ
#     FOR    ${NUM}    IN RANGE    ${NUM}   ${0}    -3
#          log to console  NUM:${NUM}/
#          ${CELL_ID}    set variable if    '${CELL_ID}'!='${cell_ID_1}' and '${CELL_ID}'!='${cell_ID_2}'    ${First_CELL_ID}    ${CELL_ID}
#          ${NUM2}    set variable if    '${CELL_ID}'=='${cell_ID_1}'    ${NUM}    ${40}
#          ${NUM1}    set variable if    '${CELL_ID}'=='${cell_ID_2}'    ${NUM}    ${40}
#          Get ENB LOG
#          start extract log
#          sleep    5s
#          Adjust the HBTE attenuation value    value_1=${NUM1}    value_2=${NUM1}    value_3=${NUM2}    value_4=${NUM2}
#          log to console  PA port cell1:${NUM1}---PA port cell2:${NUM2}
#          sleep    10s
#          end extract log
#          sleep    5s
#          end ENB LOG
#          ${CELL_ID}    Check log cell ID
#          Analysis capture log for Case213
#          ${RSRQ}  ${RSRP}    Check RSRP and RSRQ
#          exit for loop if    '${CELL_ID}'=='${ID}'
#     END
#     ${RSRQ}  ${RSRP}    Check RSRP and RSRQ
#     Check ENB Data
#     log to console    switch cell successful
#
# Wireshark DownloadLog
#     [Arguments]    ${connection_2}=Download
#     csn.connect_to   hostname=${DU_OAM_IP_TL}    username=${DU_OAM_SSH_USERNAME_TL}    password=${DU_OAM_SSH_PASSWORD_TL}
#     ...    alias=${connection_2}
#     csn.download_file   local_path=${LOG_PATH}/gnb_tcpdump.pcap    remote_path=${epc_log_path}/gnb_tcpdump.pcap
#     ...    connection=${connection_2}
#     sleep    5s
#     log to console  Download Log successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_2}
#
# Check log cell ID
#     [Arguments]    ${source1}=${source}    ${target1}=${target}    ${filter1}=${filter}
#     ${CELL_ID}    Convert pcap file to txt    source=${source1}    target=${target1}   filter=${filter1}
#     log to console  Check log cell ID:${CELL_ID}
#     [Return]    ${CELL_ID}
#
# Check cell onair
#     class.login  url=${DU_OAM_IP_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
#     ${bts_status}    class.get_bts_status
#     ${info_1}    class.get_cell_info    cell_idx=1
#     ${info_2}    class.get_cell_info    cell_idx=2
#     ${cell_ID_1}    ${cell_ID_2}    Get cell ID    info_1=${info_1}    info_2=${info_2}
#     Should be equal as strings    ${bts_status}    On air
#     log to console  Check cell On air successful
#     [Return]    ${cell_ID_1}    ${cell_ID_2}
#     [Teardown]    Run keyword and ignore error    class.logout
#
# Get cell ID
#     [Arguments]    ${info_1}    ${info_2}
#     ${Get_information_GNSS}    class.get_gnss_info
#
#     ${cell_ID_1}    get from dictionary    ${info_1}    Physical layer cell ID
#     ${cell_ID_2}    get from dictionary    ${info_2}    Physical layer cell ID
#     log to console    ${cell_ID_1}
#     log to console    ${cell_ID_2}
#     [Return]    ${cell_ID_1}    ${cell_ID_2}
#
# End attach and log
#     run keyword and ignore error    end ENB LOG
#     run keyword and ignore error    csn.Disconnect	connection=${connection}
#     run keyword and ignore error    end extract log
#     run keyword and ignore error    power_ue.UE Detach    ue_type=askey_sigspark    ue_index=${0}
#     CI_interface.Common Case Teardown
#
# Check RSRP and RSRQ
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target2}    connection=${connection}    filter=${filter2}
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRQ |cut -d '(' -f 2|awk '{print}' |tail -n 2 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ1}  csn.Read Output    connection=${connection}
#     ${RSRQ1}  strip_string    ${RSRQ1}
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRQ |cut -d '(' -f 2|awk '{print}' |tail -n 4 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ2}  csn.Read Output    connection=${connection}
#     ${RSRQ2}  strip_string    ${RSRQ2}
#
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRP |cut -d '(' -f 2|awk '{print}' |tail -n 2 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP1}  csn.Read Output    connection=${connection}
#     ${RSRP1}  strip_string    ${RSRP1}
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRP |cut -d '(' -f 2|awk '{print}' |tail -n 4 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP2}  csn.Read Output    connection=${connection}
#     ${RSRP2}  strip_string    ${RSRP2}
#     log to console    RSRQ_1 is :${RSRQ1}
#     log to console    RSRQ_2 is :${RSRQ2}
#     log to console    RSRP_1 is :${RSRP1}
#     log to console    RSRP_2 is :${RSRP2}
#     ${RSRQ1}    set variable if    '${RSRQ1}'=='${EMPTY}'   ${0}    ${RSRQ1}
#     ${RSRQ2}    set variable if    '${RSRQ2}'=='${EMPTY}'   ${0}    ${RSRQ2}
#     ${RSRP1}    set variable if    '${RSRP1}'=='${EMPTY}'   ${0}    ${RSRP1}
#     ${RSRP2}    set variable if    '${RSRP2}'=='${EMPTY}'   ${0}    ${RSRP2}
#     ${RSRQ}    evaluate   ${RSRQ1}-${RSRQ2}
#     ${RSRP}    evaluate   ${RSRP1}-${RSRP2}
#     log to console    RSRQ is :${RSRQ}
#     log to console    RSRP is :${RSRP}
#     [Return]    ${RSRQ}  ${RSRP}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Cell switch
#     [Arguments]    ${CELL_ID}    ${First_CELL_ID}    ${cell_ID_1}    ${cell_ID_2}    ${NUM}=${40}    ${NUM2}=${40}
#     ${ID}    set variable if    '${CELL_ID}'=='${cell_ID_1}'    ${cell_ID_2}    ${cell_ID_1}
#     ${RSRQ}  ${RSRP}    Check RSRP and RSRQ
#     ${check1}    set variable    ${1}
#     FOR    ${NUM}    IN RANGE    ${NUM}   ${0}    -1
#          log to console  NUM:${NUM}/
#          start extract log
#          sleep    5s
#          Adjust the HBTE attenuation value    value_1=${25}    value_2=${25}    value_3=${NUM2}    value_4=${NUM2}
#          log to console  PA port cell2:${NUM2}
#          sleep    10s
#          end extract log
#          ${CELL_ID}    Check log cell ID
#          Analysis capture log for Case213
#          ${check1}    set variable if    '${CELL_ID}'=='${ID}'    ${0}    ${1}
#          ${RSRQ}  ${RSRP}    Check RSRP and RSRQ
#          exit for loop if    '${CELL_ID}'=='${ID}'
#     END
#     sleep    10s
#     should be equal as numbers    ${check1}    ${1}
#     log to console    Cell didn't switch successful
#
# Modify Common parameter via Coam
#     [Arguments]  ${input_list}    ${connection}=GNB_connection    ${bts_ip}=${DU_OAM_IP_TL}
#     log to console  Modify parameter
#     coam.connect_to    bts_host=${DU_OAM_IP_TL}   name=${connection}
#     FOR    ${item}  IN    @{input_list}
#          ${dict_value}    Get Content From Input Dict    input_dict=${item}
#          coam.Perform Parameter Recommissioning    dist_name=@{dict_value}[0]   parameter=@{dict_value}[1]   value=@{dict_value}[2]
#          ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
#     END
#     log to console  sleep 1min
#     sleep  1min
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Check RSRP RSRQ data
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target2}    connection=${connection}    filter=${filter2}
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRQ |cut -d '(' -f 2|awk '{print}' |tail -n 2 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ1}  csn.Read Output    connection=${connection}
#     ${RSRQ1}  strip_string    ${RSRQ1}
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRQ |cut -d '(' -f 2|awk '{print}' |tail -n 4 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRQ2}  csn.Read Output    connection=${connection}
#     ${RSRQ2}  strip_string    ${RSRQ2}
#
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRP |cut -d '(' -f 2|awk '{print}' |tail -n 2 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP1}  csn.Read Output    connection=${connection}
#     ${RSRP1}  strip_string    ${RSRP1}
#     csn.Send Command
#     ...    command=cat ${target2} |grep SS-RSRP |cut -d '(' -f 2|awk '{print}' |tail -n 4 |head -1 | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${RSRP2}  csn.Read Output    connection=${connection}
#     ${RSRP2}  strip_string    ${RSRP2}
#     log to console    RSRQ_1 is :${RSRQ1}
#     log to console    RSRQ_2 is :${RSRQ2}
#     log to console    RSRP_1 is :${RSRP1}
#     log to console    RSRP_2 is :${RSRP2}
#     should not be empty    ${RSRQ1}
#     should not be empty    ${RSRQ2}
#     should not be empty    ${RSRP1}
#     should not be empty    ${RSRP2}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Get ENB LOG
#     ${connection_1}    csn.connect_to   hostname=${ENB_IP}
#     ...    username=${ENB_USERNAME}    password=${ENB_PASSWORD}    alias=VM
#     csn.Send Command   command=tcpdump -n -i br1 -w /tmp/enb_tcpdump.pcap    connection=${connection_1}
#     log to console  start ENB log successful
#     sleep    3s
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}
#
# end ENB LOG
#     ${connection_1}    csn.connect_to   hostname=${ENB_IP}
#     ...    username=${ENB_USERNAME}    password=${ENB_PASSWORD}    alias=VM
#     csn.Send Command  command=ps -ef | grep tcpdump | grep -v grep | grep enb_tcpdump.pcap |tail -n 1 |awk '{print $2}'
#     ...    connection=${connection_1}
#     ${PID}  csn.Read Output    connection=${connection_1}
#     ${PID}  strip_string    ${PID}
#     log to console  End ENB log successful
#     log to console  PID output: ${PID}
#     csn.Send Command  command=kill ${PID}    connection=${connection_1}
#     Download ENB Log
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_1}
#
# Download ENB Log
#     [Arguments]    ${connection_2}=Download
#     csn.connect_to   hostname=${ENB_IP}    username=${ENB_USERNAME}    password=${ENB_PASSWORD}
#     ...    alias=${connection_2}
#     csn.download_file   local_path=${LOG_PATH}/enb_tcpdump.pcap    remote_path=${epc_log_path}/enb_tcpdump.pcap
#     ...    connection=${connection_2}
#     sleep    5s
#     log to console  Download Log successful
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection_2}
#
# Check ENB Data
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target4}    connection=${connection}    filter=${filter10}
#     csn.Send Command
#     ...    command=cat ${target4} |grep measId: | tr -cd "[0-9]"
#     ...    connection=${connection}
#     ${4G_meas}  csn.Read Output    connection=${connection}
#     ${4G_meas}  strip_string    ${4G_meas}
#     should not be empty    ${4G_meas}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
#
# Analysis capture log for Case213
#     [Arguments]    ${filter7}=${filter7}    ${filter8}=${filter8}    ${target6}=${target6}
#     csn.Connect to     hostname=${test_ute}   username=${ute_name}    password=${test_password}  alias=${connection}
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter7}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re4}  csn.Read Output    connection=${connection}
#     should be empty    ${re4}
#     Convert pcap to text    source=${source}    target=${target6}    connection=${connection}    filter=${filter8}
#     csn.Send Command    command=cat ${target6}    connection=${connection}
#     ${re5}  csn.Read Output    connection=${connection}
#     should be empty    ${re5}
#     [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}
