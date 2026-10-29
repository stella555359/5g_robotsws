# *** Settings ***
# Force Tags    PY36
# Documentation     author: yayun zhang
# ...                 contact: yayun.zhang@nokia-sbell.com
# ...                 squad group: SG_03
# ...                 feature : CB006112
# 
# Resource     ./../CB006112/Resources/CB006112_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
# Variables    Resources/variables.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
# 
# Suite Setup    Run Keywords
# ...            robot_common_operations.Common Suite Setup    AND
# ...            Set automatic rotation on UEs                         AND
# ...            Setup for SA Env cell on-air on gnb2                  AND
# ...            Run Keyword And Ignore Error    Lock The First gNB    AND
# ...            Run Keyword And Ignore Error    locked LTE cell
# 
# Suite Teardown    Run Keywords
# ...            robot_common_operations.Common Suite Teardown    AND
# ...            Run Keyword And Ignore Error    Unlock The First gNB      AND
# ...            run keyword and ignore error    unlocked LTE cell
# 
# *** Variables ***
# ${SCF_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
# ${SCF_file_name_2}    Configuration_scf_GNB2_CB008698.xml
# #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# #${SCF_file_name_2}       gNB2_6112_A_14.xml
# ${epc_log_path}       /tmp/
# ${interface1}    any
# ${nglogname1}    6112_A_14_UE2_attach.pcap
# ${nglogname2}    6112_A_14_UE2_VONR.pcap
# ${nglogname3}    6112_A_14_UE2_release.pcap
# ${enb_instance}    ${tl.enbs[0].instance_id}
# #${gnb_filter1_1}    e1ap.procedureCode == 8 and e1ap.fiveQI == 5 and e1ap.dRB_Inactivity_Timer == 15
# @{gnb_filter1}    ngap.procedureCode == 14 and ngap.fiveQI == 5     ngap.procedureCode == 29 and ngap.fiveQI == 7
# ${gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
# @{gnb_filter3}    f1ap.procedureCode == 12 and nr-rrc.t310 == 5     f1ap.procedureCode == 12 and nr-rrc.n310 == 6
# ...               f1ap.procedureCode == 12 and nr-rrc.n311 == 0     f1ap.procedureCode == 12 and nr-rrc.t311 == 1
# @{gnb_filter33}    f1ap.procedureCode == 12 and nr-rrc.t310 == 8     f1ap.procedureCode == 12 and nr-rrc.n310 == 6
# ...               f1ap.procedureCode == 12 and nr-rrc.n311 == 0     f1ap.procedureCode == 12 and nr-rrc.t311 == 1
# ${gnb_filter4}    f1ap.Cause == 0 and f1ap.radioNetwork == 12
# @{gnb_filter5}    nas_5gs.mm.message_type == 0x4e and ngap.procedureCode == 14 and ngap.fiveQI == 5
# ...               nas_5gs.mm.message_type == 0x4e and ngap.procedureCode == 14 and ngap.fiveQI == 1
# ...               nas_5gs.mm.message_type == 0x4e and ngap.procedureCode == 14 and ngap.fiveQI == 7
# ${gnb_filter6}    ngap.procedureCode == 26 && ngap.nas == 0
# ${gnb_filter7}    nr-rrc.reestablishmentCause == 2 and f1ap.procedureCode == 11
# @{value1}    5    7
# @{value3}    5    6    0    1
# @{value33}    8    6    0    1
# @{value5}    5    1    7
# ${value6}    120
# ${value7}    0
# @{diffTL_enb_ID}    36721    38221    911    5395
# 
# ##get Attenuator parameter from TL
# #${atten_ip}       ${tl.attenuator[0].ip_addr}
# ${5GRU0_ANT9}     ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}    #int
# ${5GRU0_ANT10}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}    #int
# @{PA_value}       ${35}    ${50}    ${30}    ${0}    ${120}    #int list
# ${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# ${att_api_port}             ${tl.attenuator[0].port}
# @{att_connection_port}      ${5GRU0_ANT9}    ${5GRU0_ANT10}     #int list
# ${HBTE_max_value}           ${120}
# ${vendor}                   ${tl.attenuator[0].vendor}
# 
# ## filter command for coverting PDML
# ${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap\"  -T pdml
# 
# #${att_ipaddr_36721}    ${tl.attenuator[0].ip_addr}
# #${att_ipaddr_911}      ${tl.attenuator[0].ip_addr}
# #${att_ipaddr_38221}    ${tl.attenuator[0].ip_addr}
# #${att_port_1_36721}     ${tl.attenuator[0].attenuator_ports[1]}
# #${att_port_2_36721}     ${tl.attenuator[0].attenuator_ports[2]}
# #${att_port_3_36721}     ${tl.attenuator[0].attenuator_ports[3]}
# #${att_port_4_36721}     ${tl.attenuator[0].attenuator_ports[4]}
# #${att_port_5_36721}     ${tl.attenuator[0].attenuator_ports[5]}
# #${att_port_6_36721}     ${tl.attenuator[0].attenuator_ports[6]}
# #${att_port_7_36721}     ${tl.attenuator[0].attenuator_ports[7]}
# #${att_port_8_36721}     ${tl.attenuator[0].attenuator_ports[8]}
# 
# ${att_port_1_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_2_HBTE}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_3_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
# ${att_port_4_HBTE}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
# ${att_port_5_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_6_HBTE}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_7_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
# ${att_port_8_HBTE}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[1].port_no}
# 
# ${att_ipaddr_HBTE}    ${tl.attenuator[0].ip_addr}
# 
# *** Test Cases ***
# [1]CB006112-A_14_Successful_setup_of_VoNR_call_with_TDD_support_different_RLF_timer_by_SNOW3G_ciphering
#     [Documentation]    Test case description the gNB behaviour for Successful setup of VoNR call with TDD support
#     ...                 different RLF timer by SNOW3G ciphering
#     [Tags]            CRT_22R4    CRT_22R2   CRT_TRUNK    CB006112-A    CRT_22R3
#     [Setup]    robot_common_operations.Common Case Setup
#     Online modify parmeters     gnb_index=${1}    parameters_to_update=${PARAM_6112_gnb2_A_014}
#     Check gnb2 COAM classical normally
#     Check the gnb2 cell status onair    cell_no=1
#     Change the PA value for case
#     Check UE device exist
#     Prepare env with UE
#     Wait Until Keyword Succeeds    10min    30sec    Check VoNR_call_with_TDD_support_different_RLF_timer_by_SNOW3G_ciphering
#     [Teardown]     Run Keywords    robot_common_operations.Common Case Teardown    AND
#     ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}      AND
#     ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname2}      AND
#     ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname3}      AND
#     ...    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${2}    AND
#     ...    run keyword and ignore error    Change the PA value for case                                          AND
#     ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# 
# *** Keywords ***
# Check VoNR_call_with_TDD_support_different_RLF_timer_by_SNOW3G_ciphering
#     Start Capture Wireshark Logs on gNB2    nglogname=${nglogname1}    interface=${interface1}
#     Check phone attach successfully on SA env    gnb_index=1
#     sleep    2s
#     Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}
#     Start Capture Wireshark Logs on gNB2    nglogname=${nglogname2}    interface=${interface1}
#     Make a VoNR call(+6688)
#     Adjust RU Attenuation for 6112_A14
#     sleep    10s
#     Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname2}
#     sleep    3s
#     Start Capture Wireshark Logs on gNB2    nglogname=${nglogname3}    interface=${interface1}
#     sleep    10s
#     hang up VoNR call
#     TL UE detach
#     Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname3}
#     Check IE wireshark log for VONR attach       logname=${nglogname1}    message_filter=@{gnb_filter1}[0]    message_filter1=@{gnb_filter1}[1]
#     ...                                     value=@{value1}[0]    value1=@{value1}[1]
#     Check IE wireshark log for VONR setup   logname=${nglogname2}    message_filter=${gnb_filter2}
# #    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Check IE wireshark log for VONR timer   logname=${nglogname2}
# #    ...    message_filter=@{gnb_filter3}[0]    message_filter1=@{gnb_filter3}[1]    message_filter2=@{gnb_filter3}[2]
# #    ...    message_filter3=@{gnb_filter3}[3]    value=@{value3}[0]    value1=@{value3}[1]    value2=@{value3}[2]    value3=@{value3}[3]
# #    ...    ELSE    Check IE wireshark log for VONR timer                     #TL343 TL382
# #    ...    logname=${nglogname2}    message_filter=@{gnb_filter33}[0]
# #    ...    message_filter1=@{gnb_filter33}[1]    message_filter2=@{gnb_filter33}[2]    message_filter3=@{gnb_filter33}[3]
# #    ...                                     value=@{value33}[0]    value1=@{value33}[1]    value2=@{value33}[2]    value3=@{value33}[3]
#     Check IE wireshark log for VONR timer                     #TL343 TL382
#     ...    logname=${nglogname2}    message_filter=@{gnb_filter33}[0]
#     ...    message_filter1=@{gnb_filter33}[1]    message_filter2=@{gnb_filter33}[2]    message_filter3=@{gnb_filter33}[3]
#     ...                                     value=@{value33}[0]    value1=@{value33}[1]    value2=@{value33}[2]    value3=@{value33}[3]
#     Check IE wireshark log for RLF          logname=${nglogname2}    message_filter=${gnb_filter4}
#     Check IE wireshark log for ICSR         logname=${nglogname2}    message_filter=@{gnb_filter5}[0]    message_filter1=@{gnb_filter5}[1]
#     ...                                     message_filter2=@{gnb_filter5}[2]    value=@{value5}[0]    value1=@{value5}[1]    value2=@{value5}[2]
#     Check IE wireshark log for RRC Restablish    logname=${nglogname2}    message_filter=${gnb_filter7}
#     Check IE wireshark log for VONR Release      logname=${nglogname3}    message_filter=${gnb_filter6}
#     [Teardown]    run keyword and ignore error     Test case recover
# 
# Test case recover
#     run keyword and ignore error    coam.teardown    connection=gnb0
#     run keyword and ignore error    coam.teardown    connection=gnb1
# 
# Check IE wireshark log for VONR timer
#     [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${message_filter2}    ${message_filter3}
#     ...             ${value}   ${value1}    ${value2}   ${value3}
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#     ${filter_expression}=     Catenate    ${message_filter}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${nr_rrc_t310}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.t310    pcap_parser=test6
#     should be equal    ${nr_rrc_t310[0]}    ${value}
#     ${filter_expression}=     Catenate    ${message_filter1}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${nr_rrc_n310}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.n310    pcap_parser=test6
#     should be equal    ${nr_rrc_n310[0]}    ${value1}
#     ${filter_expression}=     Catenate    ${message_filter2}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${nr_rrc_n311}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.n311    pcap_parser=test6
#     should be equal    ${nr_rrc_n311[0]}    ${value2}
#     ${filter_expression}=     Catenate    ${message_filter3}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${nr_rrc_t311}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.t311    pcap_parser=test6
#     should be equal    ${nr_rrc_t311[0]}    ${value3}
# 
# Check IE wireshark log for ICSR
#     [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${message_filter2}    ${value}   ${value1}    ${value2}
#     Check IE wireshark log for ICSR_5QI_5    logname=${logname}    message_filter=${message_filter}      value=${value}
#     Check IE wireshark log for ICSR_5QI_1    logname=${logname}    message_filter=${message_filter1}     value=${value1}
#     Check IE wireshark log for ICSR_5QI_7    logname=${logname}    message_filter=${message_filter2}     value=${value2}
# 
# Check IE wireshark log for ICSR_5QI_5
#     [Arguments]    ${logname}    ${message_filter}    ${value}
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#     ${filter_expression}=     Catenate    ${message_filter}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#     should be equal    ${ngap_fiveQI[0]}    5
# 
# Check IE wireshark log for ICSR_5QI_1
#     [Arguments]    ${logname}    ${message_filter}    ${value}
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#     ${filter_expression}=     Catenate    ${message_filter}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#     should be equal    ${ngap_fiveQI[1]}    1
# 
# Check IE wireshark log for ICSR_5QI_7
#     [Arguments]    ${logname}    ${message_filter}    ${value}
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#     ${filter_expression}=     Catenate    ${message_filter}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
#     should be equal    ${ngap_fiveQI[2]}    7
# 
# Check IE wireshark log for RRC Restablish
#     [Arguments]    ${logname}    ${message_filter}
#     ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
#     ${filter_expression}=     Catenate    ${message_filter}
#     ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
#     ${nr_rrc_reestablishmentCause}=     cap.get_field_value_by_xpath    xpath=.//nr-rrc.reestablishmentCause     pcap_parser=test6
#     should be equal    ${nr_rrc_reestablishmentCause[0]}    2
# 
# Adjust RU Attenuation for 6112_A14
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust gnb_enb the attenuation value from 127 to 0
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust gnb_enb the attenuation value from 127 to 0
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    TL 367 Adjust gnb_enb the attenuation value from 127 to 0
# 
# Adjust the attenuation value for HBTE
#     [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
#     [Documentation]    Auther:cris.cai@nokia-sbell.com
#     ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
#     ...                for value and not default port 1234, plz set in your case level. setup connection only port1
#     ...                if connect on local plz disconnect firstly
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
#     att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
#     att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
#     ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
#     should be equal    ${value_port1}    ${value_1}
#     ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
#     should be equal    ${value_port2}    ${value_1}
#     sleep  4s
#     att.set_attenuation     port=${5GRU0_ANT9}    value=${value_2}
#     att.set_attenuation     port=${5GRU0_ANT10}    value=${value_2}
#     ${value_port3}    att.read_attenuation    port=${5GRU0_ANT9}
#     should be equal    ${value_port3}    ${value_2}
#     ${value_port4}    att.read_attenuation    port=${5GRU0_ANT10}
#     should be equal    ${value_port4}    ${value_2}
# 
# Change the PA value for case
# #    ${release_info}    Get gnb release
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[2]'    Adjust gnb_enb the attenuation value for HBTE                #911
#     ...    gnb2_cell1_value=${0}
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[1]'    Adjust gnb_enb the attenuation value for HBTE                #38221
#     ...    gnb2_cell1_value=${0}
#     Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    Adjust gnb_enb the attenuation value for HBTE                #36721
#     ...    gnb2_cell1_value=${0}
# 
# Adjust the attenuation value for HBTE for recover
#     [Arguments]      ${value_1}=${value_1}    ${value_2}=${value_2}
#     [Documentation]    Auther:cris.cai@nokia-sbell.com
#     ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
#     ...                for value and not default port 1234, plz set in your case level. setup connection only port1
#     ...                if connect on local plz disconnect firstly
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
#     att.set_attenuation     port=${5GRU0_ANT9}    value=${value_1}
#     att.set_attenuation     port=${5GRU0_ANT10}    value=${value_1}
#     ${value_port1}    att.read_attenuation    port=${5GRU0_ANT9}
#     should be equal    ${value_port1}    ${value_1}
#     ${value_port2}    att.read_attenuation    port=${5GRU0_ANT10}
#     should be equal    ${value_port2}    ${value_1}
# 
# #Adjust gnb_enb the attenuation value for HBTE
# #    [Arguments]    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}    ${enb_cell1_value}=${127}
# #    Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[0]'
# #    ...    Adjust the tl HBTE attenuation value    tl=@{diffTL_enb_ID}[0]
# #    ...    gnb1_cell1_value=${gnb1_cell1_value}    gnb1_cell2_value=${gnb1_cell2_value}
# #    ...    gnb2_cell1_value=${gnb2_cell1_value}    enb_cell1_value=${enb_cell1_value}
# #    ...    ELSE    sleep    1s
# 
# Adjust gnb_enb the attenuation value for HBTE
#     [Arguments]        ${gnb2_cell1_value}=${127}
# #    Run Keyword If     '${enb_instance}'=='@{diffTL_enb_ID}[0]'
#      Adjust the tl HBTE attenuation value    gnb2_cell1_value=${gnb2_cell1_value}
# #    ...    ELSE    sleep    1s
# 
# Adjust the tl HBTE attenuation value
#     [Arguments]   ${gnb2_cell1_value}=${127}    #${tl}=${tl}
#     ####create cell list#####
#     @{att_ports_gnb2_cell1}    Create List    ${att_port_5_HBTE}     ${att_port_6_HBTE}
# 
#     ###create value list####
#     @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
#     ###Adjust the HBTE attenuation value###
#     Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
#     ...    att_connection_port=${att_port_1_HBTE}    att_ipaddr=${att_ipaddr_HBTE}
# 
# Adjust gnb_enb the attenuation value from 127 to 0
#     Adjust gnb_enb the attenuation value for HBTE    gnb2_cell1_value=${120}    #TL367 TL343 TL382
#     sleep     3s
#     Adjust gnb_enb the attenuation value for HBTE    gnb2_cell1_value=${0}    #TL367 TL343 TL382
# 
# TL 367 Adjust gnb_enb the attenuation value from 127 to 0
#     Adjust gnb_enb the attenuation value for HBTE    gnb2_cell1_value=${120}    #TL367 TL343
#     sleep     3s
#     Adjust gnb_enb the attenuation value for HBTE    gnb2_cell1_value=${0}    #TL367 TL343