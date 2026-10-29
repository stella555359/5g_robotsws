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
# Resource   ./Resources/common_keywords.robot
# Variables    ./Resources/Variables.py
# 
# Suite Setup    Run Keywords    Setup Env for test    AND
# ...                            Common Suite Setup for COAM    AND
# ...                            Set the deault PA        AND         #gNB1 cell1 PA prot 1,2,3,4
# ...                            Run Keyword And Ignore Error    Lock the enb cell    AND
# #...                            Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564}    AND
# ...                            Precondition for Sansumg UE    ue_type=${ue_type}
# 
# Suite Teardown    Run Keywords    Run Keyword And Ignore Error    Unlock the enb cell    AND
# ...               Run Keyword If Any Tests Failed
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM
# 
# 
# *** Variables ***
# ## Attenuator parameter ##
# ${TS_LOG_PATH_BASE}    /home/ute/
# #${TS_CASE_LOG_PATH}    /home/ute/
# ${ue_type}    ${tl.ues[0].capabilities[1]}
# ${att_ipaddr}    ${tl.attenuator.ip_addr}
# ${att_api_port}    ${tl.attenuator.port}
# ${att_connection_port}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${vendor}        ${tl.attenuator.vendor}
# ${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# #${tl_scf_file_name_gnb}    Configuration_scf_Gloden.xml
# ${tl_scf_file_name_gnb}    Configuration_scf_GNB1_CB008200.xml
# @{att_ports}    ${att_port_1}    ${att_port_2}    ${att_port_3}    ${att_port_4}
# @{values}    ${10}    ${10}    ${10}    ${10}
# ${Case_004_Log}    75911_004.pcap
# ${case004_expected_value}    2
# ${counter_end}    1
# ${gNB_instance}    ${tl.gnbs[0].instance_id}
# ${gNB_instance_ID}    1342
# ${ipv4_AMF}    ${tl.core.five_g.amf.n2.v4}
# @{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# 
# *** Test Cases ***
# [1]CB007564_5G-B_004_NG_FLOW_REL_NG_RESET_by_gnb
#     [Documentation]    The User scenario creates a counter to measure the number of QosFlows that were released due to Ng Reset initiated by gNB.
#     [Tags]    CRT_TRUNK    CB007564    SBTS00
#     [Setup]
#     Start capture gNB log on slave    filename=${Case_004_Log}
#     Attach and check power UE   ue_type=${ue_type}
#     #Prepare with PM counter time to caculate    period=start
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_04_1}
#     sleep    2s
#     Stop and download the Logs on slave    filename=${Case_004_Log}
#     #Prepare with PM counter time to caculate    period=end
#     Wait until keyword succeeds    7min    60s    Check counter for case004
#     Check the case004 wireshark log    ${Case_004_Log}
#     [Teardown]    run keyword    Test recover
# 
# 
# *** Keywords ***
# Setup Env for test
#     RUN KEYWORD IF    ${gNB_instance} == ${gNB_instance_ID}    CI_interface.Common Suite Setup
#     ...    ELSE    Prepare the gNB cells onair status    tl_scf_file_name=${tl_scf_file_name_gnb}
# 
# Test recover
#     UE.UE Detach    ue_type=${ue_type}
#     check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${1}    ute_log_path=${epc_log_path}
#     run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_04_2}
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# #Check counter for case004
# #    Check gnb counter as expected_value
# #    ...    counter_id=${NG_FLOW_REL_GNB_NG_RESET['counter_id']}
# #    ...    dic_path=${NG_FLOW_REL_GNB_NG_RESET['dic_path']}
# #    ...    expected_value=${case004_expected_value}
# #    ...    gnb_id=${NG_FLOW_REL_GNB_NG_RESET['gnb_id']}
# #    ...    counter_end=${counter_end}
# 
# Check counter for case004
#     Check gnb counter as expected_value
#     ...    counter_id=${Trunk_NG_FLOW_REL_GNB_NG_RESET['counter_id']}
#     ...    dic_path=${Trunk_NG_FLOW_REL_GNB_NG_RESET['dic_path']}
#     ...    expected_value=${case004_expected_value}
#     ...    gnb_id=${Trunk_NG_FLOW_REL_GNB_NG_RESET['gnb_id']}
#     ...    counter_end=${counter_end}
# 
# Check the case004 wireshark log
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
# #    ${NGReset}=    Catenate    ngap.procedureCode == 20 and ngap.nG_Interface == 0
# ### 2023/03/06 23R3 feature 5GC000740 gNB-DU initiated F1 Reset([5G_CP_CONF_1834]) - [Before PR695880]leading to Full Re
# ...set if this is the only gNB-DU
# ### in the gNB or Partial Reset otherwise. [PR695880] leading to Partial Reset. [End PR695880]
#     ${NGReset}=    Catenate     ngap.procedureCode == 20 and ngap.ResetType == 1
#     ${NGReset_packets}=    parser.filter_packets_by_expression    filter_expression=${NGReset}
#     ${NGReset_value}=    parser.get_field_value_by_xpath    xpath=.//ngap.ResetType
#     should be equal    ${NGReset_value[0]}    1
#     ${NGReset_ACK}=    Catenate    ngap.procedureCode == 20 and ip.src == ${ipv4_AMF}
#     ${NGReset_ACK_packets}=    parser.filter_packets_by_expression    filter_expression=${NGReset_ACK}
#     ${NGReset_ACK_value}=    parser.get_field_value_by_xpath    xpath=.//ngap.procedureCode
#     should be equal    ${NGReset_ACK_value[0]}    20
