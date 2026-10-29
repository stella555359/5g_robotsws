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
# Suite Setup    Run Keywords
# ...    robot_common_operations.Common Suite Setup    AND
# ...    Setup Env for test for cell on air    AND
# ...                            Common Suite Setup for COAM
# 
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# 
# *** Variables ***
# @{values}    ${10}    ${10}    ${10}    ${10}
# ${Case_004_Log}    75911_004.pcap
# ${case004_expected_value}    2
# ${counter_end}    1
# ${gNB_instance}    ${tl.gnbs[0].instance_id}
# ${gNB_instance_ID}    1342
# ${ipv4_AMF}    ${tl.core[2].five_g.amf.n2.v4}
# 
# @{ues_type}    huawei    samsung
# 
# ${tl_scf_dir_path_golden}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
# ${tl_scf_file_name1_golden}    Configuration_scf_GNB1_CB008698.xml
# ${tl_scf_file_name2_golden}    Configuration_scf_GNB2_CB008698.xml
# 
# @{PA_list}    ${0}    ${30}    ${45}    ${120}
# 
# ${enb_instance}     ${tl.enbs[0].instance_id}
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
# 
# *** Test Cases ***
# [1]CB007564_5G-B_004_NG_FLOW_REL_NG_RESET_by_gnb
#     [Documentation]    The User scenario creates a counter to measure the number of QosFlows that were released due to Ng Reset initiated by gNB.
#     [Tags]    CB007564    CRT_22R3   CIT_22R4
#     [Setup]    robot_common_operations.Common Case Setup
#     Comment     set gnb1 cell1 PA to 0
#     Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[3]
#     ...    gnb2_cell1_value=@{PA_list}[3]    enb_cell1_value=@{PA_list}[3]
#     Start capture gNB log on master    filename=${Case_004_Log}
#     Step1: UE attach    ue_type=@{ues_type}[0]
# #    Prepare with PM counter time to caculate    period=start
#     Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_04_1}
#     sleep    2s
#     Stop and download Logs on gNB on master    filename=${Case_004_Log}
# #    Prepare with PM counter time to caculate    period=end
#     Wait until keyword succeeds    7min    60s    Check counter for case004
#     Check the case004 wireshark log    log_name=${Case_004_Log}
#     [Teardown]    Run Keywords
#     ...    robot_common_operations.Common Case Teardown    AND
#     ...    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_04_2}    AND
#     ...    Step4: Detach UE    ue_type=@{ues_type}[0]    AND
#     ...    Run Keyword And Ignore Error    Stop and download Logs on gNB on master    filename=${Case_004_Log}    AND
#     ...    Adjust HBTE gNB_eNB_RU Attenuation    gnb1_cell1_value=@{PA_list}[0]    gnb1_cell2_value=@{PA_list}[0]
#     ...    gnb2_cell1_value=@{PA_list}[0]    enb_cell1_value=@{PA_list}[0]    AND
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
#     run keyword and ignore error    Online modify parmeters    parameters_to_update=${PARAMS_TO_MODIFY_CB007564_04_2}
#     Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# Check counter for case004
#     Check gnb counter as expected_value
#     ...    counter_id=${NG_FLOW_REL_GNB_NG_RESET['counter_id']}
#     ...    dic_path=${NG_FLOW_REL_GNB_NG_RESET['dic_path']}
#     ...    expected_value=${case004_expected_value}
#     ...    gnb_id=${NG_FLOW_REL_GNB_NG_RESET['gnb_id']}
#     ...    counter_end=${counter_end}
# 
# Check the case004 wireshark log
#     [Arguments]    ${log_name}
#     ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${log_name}
#     ${NGReset}=    Catenate    ngap.procedureCode == 20 and ngap.nG_Interface == 0
#     ${NGReset_packets}=    parser.filter_packets_by_expression    filter_expression=${NGReset}
#     ${NGReset_value}=    parser.get_field_value_by_xpath    xpath=.//ngap.nG_Interface
#     should be equal    ${NGReset_value[0]}    0
#     ${NGReset_ACK}=    Catenate    ngap.procedureCode == 20 and ip.src == ${ipv4_AMF}
#     ${NGReset_ACK_packets}=    parser.filter_packets_by_expression    filter_expression=${NGReset_ACK}
#     ${NGReset_ACK_value}=    parser.get_field_value_by_xpath    xpath=.//ngap.procedureCode
#     should be equal    ${NGReset_ACK_value[0]}    20
# 
# Step1: UE attach
#     [Arguments]    ${ue_type}    ${ue_index}=${0}    ${4G_check}=False
#     Check UE device exist    ue_index=${ue_index}
#     Huawei UE setup    ue_type=${ue_type}    ue_index=${ue_index}
#     Attach and check power UE    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${4G_check}
# 
# Step4: Detach UE
#     [Arguments]    ${ue_type}    ${ue_index}=${0}
#     UE.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
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
