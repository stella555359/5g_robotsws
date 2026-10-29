# *** Settings ***
# Documentation
# ...    author: Xing Jing
# ...    contact: jing.1.xing@nokia-sbell.com
# ...    squad group: SG_03
# 
# 
# Force Tags  CA_5G_RRM    RAN_5G    RAN_5G_TDD    CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1_AAHF_RF_SHARING_ENB
# ...         STATE_SW_UPLOADED    PY36   CRT_UTE
# 
# Library    OperatingSystem
# Library    Collections
# Library    String
# Library    BuiltIn
# Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
# Library    taf.config.testline    WITH NAME    testline
# Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/ssh_pcf.py
# Library    ssh_pcf.pcf   WITH NAME    PCF
# Library    taf.analyzer.pcap   WITH NAME    parser
# Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/PCF_sim.robot
# Variables    Resources/Variables_new.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
# 
# Suite Setup    Run Keywords    Setup Env for test for cell on air    AND
# ...                            Common Suite Setup for COAM    AND
# #...                            Lock the enb cell    AND
# #...                            Lock cell online coam    gnb_index=${0}    cell_index=${2}    AND
# #...                            Lock cell online coam    gnb_index=${1}    cell_index=${1}    AND
# ...                            Comment    set gnb1 cell1 PA to 0    AND
# ...                            Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{values}[4]    gnb1_cell2_value=@{values}[5]
# ...                            gnb2_cell1_value=@{values}[5]    enb_cell1_value=@{values}[5]
# 
# Suite Teardown    Run Keywords    #Unlock the enb cell    AND
# ...               robot_common_operations.Common Suite Teardown    AND
# ...               Comment    recover PA to 0    AND
# ...               Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{values}[4]    gnb1_cell2_value=@{values}[4]
# ...               gnb2_cell1_value=@{values}[4]    enb_cell1_value=@{values}[4]    #AND
# #...               Unlock cell online coam    gnb_index=${0}    cell_index=${2}    AND
# #...               Unlock cell online coam    gnb_index=${1}    cell_index=${1}
# 
# 
# *** Variables ***
# ${TS_LOG_PATH_BASE}    /home/ute/
# ${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${gnb_path}    /tmp/
# 
# ${max_attenuation_value}     ${120}
# @{values}    ${10}    ${10}    ${10}    ${10}    ${0}    ${127}
# ${ims}    310260
# ${new_ims}    46002
# ${server_ip}    10.57.240.20      # core network middle module IP
# ${PCF_IP}    10.57.150.82          # PCF simulator IP
# ${PCF_username}    ute
# ${PCF_password}    Ut3pa5s#ff97
# ${ALIAS_PCF}    PCF
# ${Case_001_Log}    75911_001.pcap
# ${Case_004_Log}    75911_004.pcap
# ${Case_006_Log}    75911_006.pcap
# ${five_qi}    1
# ${priorityLevel}    3
# ${priorityLevel_1}    4
# ${priorityLevel_2}    1
# ${priorityLevel_3}    5
# ${enb_instance}     ${tl.enbs[0].instance_id}
# ${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
# ${enb_para}    administrativeState
# @{enb_value}    locked    unlocked
# 
# ${gNB_instance}    ${tl.gnbs[0].instance_id}
# ${gNB_instance_ID}    1342
# ${gNB_instance_ID2}    4225
# ${ipv4_AMF}    ${tl.core[2].five_g.amf.n2.v4}
# 
# @{ues_type}    huawei    samsung
# 
# ####168 873     wap2      huawei
# ####168 1073    mdrb      huawei
# ####168 1471    mdrbxj    huawei
# @{apn_location}    168 681    168 873    146 717    140 513    93 941    93 743    142 912    168 1073    168 1471
# 
# ${tl_scf_dir_path_golden}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
# ${tl_scf_file_name1_golden}    Configuration_scf_GNB1_CB008698.xml
# ${tl_scf_file_name2_golden}    Configuration_scf_GNB2_CB008698.xml
# 
# ${att_ipaddr_36721}    ${tl.attenuator[0].ip_addr}
# ${att_ipaddr_911}      ${tl.attenuator[0].ip_addr}
# ${att_ipaddr_38221}    ${tl.attenuator[0].ip_addr}
# ${att_port_1_36721}     ${tl.attenuator[0].attenuator_ports[1]}
# ${att_port_2_36721}     ${tl.attenuator[0].attenuator_ports[2]}
# ${att_port_3_36721}     ${tl.attenuator[0].attenuator_ports[3]}
# ${att_port_4_36721}     ${tl.attenuator[0].attenuator_ports[4]}
# ${att_port_5_36721}     ${tl.attenuator[0].attenuator_ports[5]}
# ${att_port_6_36721}     ${tl.attenuator[0].attenuator_ports[6]}
# ${att_port_7_36721}     ${tl.attenuator[0].attenuator_ports[7]}
# ${att_port_8_36721}     ${tl.attenuator[0].attenuator_ports[8]}
# ${att_port_1_911}     ${tl.attenuator[0].attenuator_ports[9]}
# ${att_port_2_911}     ${tl.attenuator[0].attenuator_ports[10]}
# ${att_port_3_911}     ${tl.attenuator[0].attenuator_ports[11]}
# ${att_port_4_911}     ${tl.attenuator[0].attenuator_ports[12]}
# ${att_port_5_911}     ${tl.attenuator[0].attenuator_ports[13]}
# ${att_port_6_911}     ${tl.attenuator[0].attenuator_ports[14]}
# ${att_port_7_911}     ${tl.attenuator[0].attenuator_ports[15]}
# ${att_port_8_911}     ${tl.attenuator[0].attenuator_ports[16]}
# @{diffTL_enb_ID}    36721    38221    911
# @{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
# 
# *** Test Cases ***
# #[1]CNI-75911_004-Unsuccessful_Update_of_ARP_parameter_of_existing_one_QoS_flow_with_the_same_PDU_session
# #    [Documentation]    This user scenario describes the handling at gNB when AMF attempts to modify the parameter,
# #    ...    priorityLevelARP to the value configured for emergency services of an existing QoS flow, through PDU
# #    ...    Session Resource Modification procedure.
# #    [Tags]    CNI-75911    CRT_22R3    CRT_22R4
# #    [Setup]    robot_common_operations.Common Case Setup
# #    choice required APN on UE    usedapn=@{apn_location}[8]    ue_type=@{ues_type}[0]    ue_index=${0}
# #    Exit the PCF service
# #    Start PCF service    ims=${new_ims}    ip=${PCF_IP}
# #    Start capture gNB log on master    filename=${Case_004_Log}
# #    Attach and check power UE    ue_type=@{ues_type}[0]
# #    Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}
# #    sleep    2s
# #    Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_2}    server_ip=${server_ip}
# #    sleep    5s
# #    Stop and download Logs on gNB on master    filename=${Case_004_Log}
# #    Check the case004 wireshark log    log_name=${Case_004_Log}
# #    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
# #    ...    choice required APN on UE    usedapn=@{apn_location}[1]    ue_type=@{ues_type}[0]    ue_index=${0}    AND
# #    ...    Step4: Detach UE    ue_type=@{ues_type}[0]    AND
# #    ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${Case_004_Log}    AND
# #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# [1]CNI-75911_006-Successful_Update_of_ARP_parameter_of_existing_emergency_services_to_new_emergency_service
#     [Documentation]    This user scenario describes the handling at gNB when AMF attempts to modify the
#     ...    parameter, priorityLevelARP of a QoS flow already configured as emergency services to non-emergency
#     ...    service, through PDU Session Resource Modification procedure
#     [Tags]    CNI-75911    CRT_22R3    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     choice required APN on UE    usedapn=@{apn_location}[8]    ue_type=@{ues_type}[0]    ue_index=${0}
#     Exit the PCF service
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_75911_06_1}
#     Start PCF service    ims=${new_ims}    ip=${PCF_IP}
#     Start capture gNB log on master    filename=${Case_006_Log}
#     Attach and check power UE    ue_type=@{ues_type}[0]
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_3}    server_ip=${server_ip}
#     sleep    2s
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_75911_06_2}
#     sleep    5s
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_1}    server_ip=${server_ip}
#     sleep    5s
#     Stop and download Logs on gNB on master    filename=${Case_006_Log}
#     Check the case006 wireshark log    log_name=${Case_006_Log}    No=${5}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    choice required APN on UE    usedapn=@{apn_location}[1]    ue_type=@{ues_type}[0]    ue_index=${0}    AND
#     ...    Step4: Detach UE    ue_type=@{ues_type}[0]    AND
# #    ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#     ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
#     ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_RECOVER_75911_06}    AND
#     ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${Case_006_Log}    AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# 
# *** Keywords ***
# Setup Env for test for cell on air
#     Common Case TestLine Setup    is_commission=True    scf_path=${tl_scf_dir_path_golden}
#     ...    golden_scf_name=${tl_scf_file_name1_golden}
# 
# Setup Env for test
#     RUN KEYWORD IF    ${gNB_instance} == ${gNB_instance_ID}    CI_interface.Common Suite Setup
#     ...    ELSE    Prepare the gNB cells onair status    tl_scf_file_name=${tl_scf_file_name_gnb}
# 
# Test recover
#     run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}
#     run keyword and ignore error    Exit the PCF service
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# Check the case_001 tcpdump log
#     RUN KEYWORD IF    ${gNB_instance} == ${gNB_instance_ID}
#     ...    Check the case001 wireshark log    log_name=${Case_001_Log}    No=${5}
#     ...    ELSE    Check the case001 wireshark log    log_name=${Case_001_Log}
# 
# Check the case001 wireshark log
#     [Arguments]    ${log_name}    ${No}=${1}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
#     ${5QI1_req}=    Catenate    ngap.procedureCode == 26 and ngap.priorityLevelARP
#     ${5QI1_pdu_req_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_req}
#     ${5QI1_priLev}=    parser.get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP
#     should be equal    ${5QI1_priLev[0]}    3
#     should be equal    ${5QI1_priLev[1]}    4
#     ${5QI1_req_time}=    parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${5QI1_req_time}=     convert to number    ${5QI1_req_time[-1]}
#     ${5QI1_resp}=    Catenate    ngap.procedureCode == 26 and ip.dst == ${ipv4_AMF}
#     ${5QI1_pdu_resp_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_resp}
#     ${5QI1_Qos}=    parser.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier
#     should be equal    ${5QI1_Qos[0]}    ${5QI1_Qos[1]}
#     ${5QI1_resp_time}=    parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${5QI1_resp_time}=    convert to number    ${5QI1_resp_time[-1]}
#     ${e1ap_f1ap}=    Catenate    f1ap or e1ap
#     ${e1ap_f1ap_pack}=    parser.filter_packets_by_expression    filter_expression=${e1ap_f1ap}
#     ${e1ap_f1ap_time}=     parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${Num_e1ap_f1ap}=    get length    ${e1ap_f1ap_time}
#     ${pdu_item}    set variable    0
#     FOR    ${Num}    IN RANGE    ${0}    ${Num_e1ap_f1ap}
#         ${increase}    Evaluate    ${pdu_item}+1
#         ${pdu_item}    Set variable if
#         ...    (${e1ap_f1ap_time[${Num}]} > ${5QI1_req_time}) and (${e1ap_f1ap_time[${Num}]} < ${5QI1_resp_time})
#         ...    ${increase}    ${pdu_item}
#     END
#     Should be true     ${pdu_item} <= ${No}
#     ${UE_release}     Catenate    ngap.procedureCode == 42
#     ${UE_release_packets}    parser.filter_packets_by_expression    filter_expression=${UE_release}
#     ${UE_rel_val}=    parser.get_field_value_by_xpath    xpath=./xnap.id
#     should be empty    ${UE_rel_val}
# 
# Check the case004 wireshark log
#     [Arguments]    ${log_name}    ${No}=1
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
#     ${5QI1_req}=    Catenate    ngap.procedureCode == 26 and ngap.priorityLevelARP
#     ${5QI1_pdu_req_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_req}
#     ${5QI1_priLev}=    parser.get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP
#     should be equal    ${5QI1_priLev[0]}    3
#     should be equal    ${5QI1_priLev[1]}    1
#     ${5QI1_req_time}=    parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${5QI1_req_time}=     convert to number    ${5QI1_req_time[-1]}
#     ${5QI1_resp}=    Catenate    ngap.procedureCode == 26 and ip.dst == ${ipv4_AMF}
#     ${5QI1_pdu_resp_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_resp}
#     ${5QI1_Qos}=    parser.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier
#     should not be empty    ${5QI1_Qos}
#     ${5QI1_Qos_1}=    parser.get_field_value_by_xpath    xpath=.//ngap.radioNetwork
#     should be equal    ${5QI1_Qos_1[-1]}    23
#     ${5QI1_resp_time}=    parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${5QI1_resp_time}=    convert to number    ${5QI1_resp_time[-1]}
#     ${e1ap_f1ap}=    Catenate    f1ap or e1ap
#     ${e1ap_f1ap_pack}=    parser.filter_packets_by_expression    filter_expression=${e1ap_f1ap}
#     ${e1ap_f1ap_time}=     parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${Num_e1ap_f1ap}=    get length    ${e1ap_f1ap_time}
#     ${pdu_item}    set variable    0
#     FOR    ${Num}    IN RANGE    ${0}    ${Num_e1ap_f1ap}
#         ${increase}    Evaluate    ${pdu_item}+1
#         ${pdu_item}    Set variable if
#         ...    (${e1ap_f1ap_time[${Num}]} > ${5QI1_req_time}) and (${e1ap_f1ap_time[${Num}]} < ${5QI1_resp_time})
#         ...    ${increase}    ${pdu_item}
#     END
#     Should be true     ${pdu_item} < ${No}
#     ${UE_release}     Catenate    ngap.procedureCode == 42
#     ${UE_release_packets}    parser.filter_packets_by_expression    filter_expression=${UE_release}
#     ${UE_rel_val}=    parser.get_field_value_by_xpath    xpath=./xnap.id
#     should be empty    ${UE_rel_val}
# 
# Check the case_006 tcpdump log
#     RUN KEYWORD IF    ${gNB_instance} == ${gNB_instance_ID2}
#     ...    Check the case006 wireshark log   log_name=${Case_006_Log}
#     ...    ELSE    Check the case006 wireshark log    log_name=${Case_006_Log}    No=${5}
# 
# Check the case006 wireshark log
#     [Arguments]    ${log_name}    ${No}=1
#      ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
#     ${5QI1_req}=    Catenate    ngap.procedureCode == 26 and ngap.priorityLevelARP
#     ${5QI1_pdu_req_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_req}
#     ${5QI1_priLev}=    parser.get_field_value_by_xpath    xpath=.//ngap.priorityLevelARP
#     should be equal    ${5QI1_priLev[0]}    5
#     should be equal    ${5QI1_priLev[1]}    4
#     ${5QI1_req_time}=    parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${5QI1_req_time}=     convert to number    ${5QI1_req_time[-1]}
#     ${5QI1_resp}=    Catenate    ngap.procedureCode == 26 and ip.dst == ${ipv4_AMF}
#     ${5QI1_pdu_resp_packets}=    parser.filter_packets_by_expression    filter_expression=${5QI1_resp}
#     ${5QI1_Qos}=    parser.get_field_value_by_xpath    xpath=.//ngap.qosFlowIdentifier
#     should be equal    ${5QI1_Qos[0]}    ${5QI1_Qos[1]}
#     ${5QI1_resp_time}=    parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${5QI1_resp_time}=    convert to number    ${5QI1_resp_time[-1]}
#     ${e1ap_f1ap}=    Catenate    f1ap or e1ap
#     ${e1ap_f1ap_pack}=    parser.filter_packets_by_expression    filter_expression=${e1ap_f1ap}
#     ${e1ap_f1ap_time}=     parser.get_field_value_by_xpath    xpath=.//frame.number
#     ${Num_e1ap_f1ap}=    get length    ${e1ap_f1ap_time}
#     ${pdu_item}    set variable    0
#     FOR    ${Num}    IN RANGE    ${0}    ${Num_e1ap_f1ap}
#         ${increase}    Evaluate    ${pdu_item}+1
#         ${pdu_item}    Set variable if
#         ...    (${e1ap_f1ap_time[${Num}]} > ${5QI1_req_time}) and (${e1ap_f1ap_time[${Num}]} < ${5QI1_resp_time})
#         ...    ${increase}    ${pdu_item}
#     END
#     Should be true     ${pdu_item} <= ${No}
#     ${UE_release}     Catenate    ngap.procedureCode == 42
#     ${UE_release_packets}    parser.filter_packets_by_expression    filter_expression=${UE_release}
#     ${UE_rel_val}=    parser.get_field_value_by_xpath    xpath=./xnap.id
#     should be empty    ${UE_rel_val}
# 
# Set the deault PA
#     Set the attenuation value    att_ports=${att_ports}    values=${values}
# 
# Lock the enb cell
#     Modify the enblte parameter    dist_name=${enb_dist_name}    parameter=${enb_para}   value=@{enb_value}[0]
# 
# Unlock the enb cell
#     Modify the enblte parameter    dist_name=${enb_dist_name}    parameter=${enb_para}   value=@{enb_value}[1]
# 
# Adjust HBTE gNB_eNB_RU Attenuation
#     [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
#     Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[0]'
#     ...    Adjust the tl HBTE attenuation value    tl=@{diffTL_enb_ID}[0]
#     ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
#     ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
#     ...    ELSE IF     '${enb_instance}'=='@{diffTL_enb_ID}[2]'
#     ...    Adjust the tl HBTE attenuation value    tl=@{diffTL_enb_ID}[2]
#     ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
#     ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
# 
# Adjust the tl HBTE attenuation value
#     [Arguments]     ${tl}=${tl}    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
#     ...    ${enb_cell1_value}=${127}
#     ####create cell list#####
#     @{att_ports_gnb1_cell1}    Create List    ${att_port_1_${tl}}     ${att_port_2_${tl}}
#     @{att_ports_gnb1_cell2}    Create List    ${att_port_3_${tl}}     ${att_port_4_${tl}}
#     @{att_ports_gnb2_cell1}    Create List    ${att_port_5_${tl}}     ${att_port_6_${tl}}
#     @{att_ports_enb_cell1}     Create List    ${att_port_7_${tl}}     ${att_port_8_${tl}}
# 
#     ###create value list####
#     @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
#     @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
#     @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
#     @{values_enb_cell1}     Create List    ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}     ${enb_cell1_value}
# 
#     ###Adjust the HBTE attenuation value###
#     Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
#     ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
#     Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
#     ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
#     Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
#     ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
#     Set the attenuation value    att_ports=${att_ports_enb_cell1}     values=${values_enb_cell1}
#     ...    att_connection_port=${att_port_1_${tl}}    att_ipaddr=${att_ipaddr_${tl}}
# 
# choice required APN on UE
#     [Arguments]    ${usedapn}    ${ue_type}    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     ...    ${data_enable}=false    ${status}=enable
#     power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
#     set apn to wap2    usedapn=${usedapn}    ue_index=${ue_index}
#     Run Keyword If    '${data_enable}'=='false'    Comment    Do not operate UE data button
#     ...    ELSE IF    '${data_enable}'=='true'    Setup UE data status    status=${status}
#     make airplane mode to enable    ue_index=${ue_index}
# 
# #make airplane mode to enable
# #    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
# #    log to console    enable airplane mode
# #    Connect to control pc via cygwin    ue_index=${ue_index}
# #    ${passed} =    Check airplane mode status on    ue_index=${ue_index}
# #    run keyword if    '${passed}'=='${False}'
# #        ...    Run Keywords    Connect to control pc via cygwin    ue_index=${ue_index}
# #        ...    AND    Commercial UE click AIRPLANE once    Home_button=${home}    airplane=${airplane}    ue_index=${ue_index}
# #        ...    close_task=${close_task}
# 
# Setup UE data status
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=enable
#     csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
#     ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
#     ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
#     sleep   5s
#     csn.send_command    command=adb -s ${serial_number} shell svc data ${status}    connection=cygwin${ue_index}
#     sleep   2s
#     csn.disconnect      connection=cygwin${ue_index}
# 
# Step4: Detach UE
#     [Arguments]    ${ue_type}    ${ue_index}=${0}
#     UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
# 
# Lock cell online coam
#     [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}    ${timeout}=60
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
# #    coam.lock_cell
#     coam.lock
#     ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
#     ...    connection=GNB_OAM    timeout=${timeout}
#     sleep    5
#     [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
# 
# Unlock cell online coam
#     [Arguments]    ${gnb_index}=${0}    ${cell_index}=${1}    ${timeout}=60
#     Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
# #    coam.unlock_cell
#     coam.unlock
#     ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRCELL-${cell_index}
#     ...    connection=GNB_OAM    timeout=${timeout}
#     sleep    5
#     [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections