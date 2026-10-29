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
# #Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
# #Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
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
# Variables    ./Resources/Variables.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
# 
# Suite Setup    Run Keywords    Setup Env for test    AND
# ...                            Common Suite Setup for COAM    AND
# ...                            Run Keyword And Ignore Error    Lock the enb cell    AND
# ...                            Set the deault PA        AND         #gNB1 cell1 PA prot 9,10,11,12
# ...                            Precondition for Sansumg UE    ue_type=${ue_type}
# 
# Suite Teardown    Run Keywords    Run Keyword And Ignore Error    Unlock the enb cell    AND
# ...               Run Keyword If Any Tests Failed
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM
# 
# 
# ** Variables ***
# #${TS_CASE_LOG_PATH}    /home/ute/
# ${TS_LOG_PATH_BASE}    /home/ute/
# #${tl_scf_file_name_gnb}    Configuration_scf_Gloden.xml
# ${tl_scf_file_name_gnb}    Configuration_scf_GNB1_CB008200.xml
# ${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${gnb_path}    /tmp/
# 
# ## Attenuator parameter ##
# ${ue_type}                  ${tl.ues[0].capabilities[1]}
# ${att_ipaddr}    ${tl.attenuator.ip_addr}
# ${att_api_port}    ${tl.attenuator.port}
# ${att_connection_port}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${vendor}        ${tl.attenuator.vendor}
# ${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# ${max_attenuation_value}     ${120}
# @{att_ports}    ${att_port_1}    ${att_port_2}    ${att_port_3}    ${att_port_4}
# @{values}    ${10}    ${10}    ${10}    ${10}
# ${ims}    310260
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
# ${enb_dist_name}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-3
# ${enb_para}    administrativeState
# @{enb_value}    locked    unlocked
# ${gNB_instance}    ${tl.gnbs[0].instance_id}
# ${gNB_instance_ID}    1342
# ${gNB_instance_ID2}    4225
# ${ipv4_AMF}    ${tl.core.five_g.amf.n2.v4}
# ${wap2_apn_name}    ${tl.core.pdns[0]}
# ${mdrbxj_apn_name}    ${tl.core.pdns[1]}
# ${ui_version}    one ui 3.1
# @{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# *** Test Cases ***
# [1]CNI-75911_001-Successful_Update_of_ARP_parameter_of_existing_one_QoS_flow_with_the_same_PDU_session
#     [Documentation]    This user scenario describes the successful update of ARP parameter(s) of existing QoS flow
#     ...    through PDU Session Resource Modification procedure requested by the AMF. The gNB uses this procedure to store
#     ...    the ARP value in the UE context 
#     [Tags]    CRT_TRUNK    CNI-75911    SBTS00
#     [Setup]    robot_common_operations.Common Case Setup
#     Switch APN to muti DRB    apn_name=${mdrbxj_apn_name}   ui_version=${ui_version}
#     Exit the PCF service
#     Start PCF service    ims=${ims}    ip=${PCF_IP}
#     Start capture gNB log on slave    filename=${Case_001_Log}
#     Attach and check power UE   ue_type=${ue_type}
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}
#     sleep    2s
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_1}    server_ip=${server_ip}
#     sleep    5s
#     Stop and download the Logs on slave    filename=${Case_001_Log}
#     Check the case_001 tcpdump log
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Test recover
# 
# [1]CNI-75911_004-Unsuccessful_Update_of_ARP_parameter_of_existing_one_QoS_flow_with_the_same_PDU_session
#     [Documentation]    This user scenario describes the handling at gNB when AMF attempts to modify the parameter,
#     ...    priorityLevelARP to the value configured for emergency services of an existing QoS flow, through PDU 
#     ...    Session Resource Modification procedure.
#     [Tags]    CRT_TRUNK    CRT_22R2    CNI-75911    CRT_22R3    SBTS00    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     Switch APN to muti DRB    apn_name=${mdrbxj_apn_name}    ui_version=${ui_version}
#     Exit the PCF service
#     Start PCF service    ims=${ims}    ip=${PCF_IP}
#     Start capture gNB log on slave    filename=${Case_004_Log}
#     Attach and check power UE    ue_type=${ue_type}
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel}    server_ip=${server_ip}
#     sleep    2s
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_2}    server_ip=${server_ip}
#     sleep    5s
#     Stop and download the Logs on slave    filename=${Case_004_Log}
#     Check the case004 wireshark log    log_name=${Case_004_Log}
#     [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Test recover
# 
# [1]CNI-75911_006-Successful_Update_of_ARP_parameter_of_existing_emergency_services_to_new_emergency_service
#     [Documentation]    This user scenario describes the handling at gNB when AMF attempts to modify the 
#     ...    parameter, priorityLevelARP of a QoS flow already configured as emergency services to non-emergency
#     ...    service, through PDU Session Resource Modification procedure
#     [Tags]    CRT_TRUNK    CRT_22R2    CNI-75911    CRT_22R3    SBTS00    CRT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     Switch APN to muti DRB    apn_name=${mdrbxj_apn_name}    ui_version=${ui_version}
#     Exit the PCF service
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_75911_06_1}
#     Start PCF service    ims=${ims}    ip=${PCF_IP}
#     Start capture gNB log on slave    filename=${Case_006_Log}
#     Attach and check power UE    ue_type=${ue_type}
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_3}    server_ip=${server_ip}
#     sleep    2s
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_75911_06_2}
#     sleep    5s
#     Configure and commit the QoS    five_qi=${five_qi}    priorityLevel=${priorityLevel_1}    server_ip=${server_ip}
#     sleep    5s
#     Stop and download the Logs on slave    filename=${Case_006_Log}
#     Check the case_006 tcpdump log
#     [Teardown]   Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Test recover
# 
# 
# *** Keywords ***
# Setup Env for test
#     RUN KEYWORD IF    ${gNB_instance} == ${gNB_instance_ID}    CI_interface.Common Suite Setup
#     ...    ELSE    Prepare the gNB cells onair status    tl_scf_file_name=${tl_scf_file_name_gnb}
# 
# Test recover
#     Switch APN to muti DRB    apn_name=${wap2_apn_name}   ui_version=${ui_version}
#     run keyword and ignore error    make WA with Samsung S21    ue_index=${0}
#     UE.UE Detach    ue_type=${ue_type}
#     check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}
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
# #    RUN KEYWORD IF    ${gNB_instance} == ${gNB_instance_ID2}
# #    ...    Check the case006 wireshark log   log_name=${Case_006_Log}
# #    ...    ELSE    Check the case006 wireshark log    log_name=${Case_006_Log}    No=${5}
# ###after 22R4 BO(stop 22R2),all analysis log NIDD No=${5}
#     Check the case006 wireshark log    log_name=${Case_006_Log}    No=${5}
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
# make WA with Samsung S21
#     [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     Connect to control pc via cygwin    ue_index=${ue_index}
#     sleep   5s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
#     sleep   2s
#     Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
#     sleep   4s
#     #####Samsung S21 WA to click time cancel
#     csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin
#     sleep    2s
#     [Teardown]    csn.disconnect    connection=cygwin
# 
# Switch APN to muti DRB
#     [Arguments]    ${apn_name}    ${ui_version}
#     Run Keyword And Ignore Error    Attach and check power UE   ue_type=${ue_type}
#     Android UE SwitchApn    ue_index=${0}    apn_name=${apn_name}    ui_version=${ui_version}
#     make WA with Samsung S21    ue_index=${0}
#     run keyword and ignore error    UE.UE Detach    ue_type=${ue_type}