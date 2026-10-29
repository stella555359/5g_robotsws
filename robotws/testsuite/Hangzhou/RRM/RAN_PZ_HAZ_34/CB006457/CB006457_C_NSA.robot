# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# ...    AND    Test suite prepare
# ...    AND        CB006457 NSA CA case Preparation
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# Test Setup        Run Keywords    robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown
# ...    AND    Stop traffic for CA and detach UE
# 
# Resource    ./Resources/CB006457_common_keywords.robot
# Variables   ./Resources/CB006457_scf_modify.py
# Resource    ./Resources/CB006457_common_keywords_counter.robot
# 
# Documentation
# ...    author: guo zhenzhen
# ...    contact: zhenzhen.guo@nokia-sbell.com
# ...    squad group: MMW3
# ...    feature : CB006457
# 
# Force Tags    CRT_TRUNK
# 
# *** Variables ***
# @{nbrUlDlSF_list}    8
# @{nbrQoS_list}   7
# @{nbrDL_list}    64
# @{nbrUL_list}    60    20
# @{nbrQoS_list1}   7    8
# @{nbrDL_list1}    100    100
# @{nbrUL_list1}    10    10
# ${iperf_port_dl}            ${tl.ues[0].iperf_details.ports[0]}
# ${iperf_port_ul}            ${tl.ues[0].iperf_details.ssh_connection_details.port}
# ${att_ipaddr}               ${tl.attenuator[0].ip_addr}
# ${att_api_port}             ${tl.attenuator[0].port}
# ${model}                    ${tl.attenuator[0].model}
# ${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
# ${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
# ${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
# ${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
# ${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
# ${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
# ${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
# ${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
# ${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
# ${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
# ${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
# ${att_port_12}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
# ${vendor}                   HBTE
# 
# *** Test Cases ***
# [1]CB006457-C_01_ArpBasedQosScaling_IWK_CA_Intra_Gnb_Pcell_Scell_Both_SchedulingWeightSF_MultiUE_NoneGBR
#     Adjust HBTE ATT Values    ${ATTENUATION_VALUE_CA_1}
#     Enable CB006457 online
#     Disable "actNbrForNonGbrBearers" online    cell_id=1
#     Disable "actNbrForNonGbrBearers" online    cell_id=2
#     Online modify parameters "schedulingWeightSF" for first arp   new_value=7
#     UE Prepare
#     #Attach UE
#     Set test variable    ${pcap_log_name}    CB006457-C_01.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${qos}    ${schedulWeight}    Get the schedulWeight of multi DRB
#     Check the scheduleight of specific qosid is as expected
#     ...    qos=${qos}    qosId=7    schedulWeight=${schedulWeight}    Weight_value=70
#     UE start traffic111    tp_direction=both    ul_tp=200M    dl_tp=2000M
#     UE check throughput by syslog    tp_direction=both    exp_dl_tp=1500    exp_ul_tp=70
# 
# [1]CB006457-C_02_ArpBasedQosScaling_IWK_CA_Intra_Gnb_Pcell_Scell_Both_nbrUlDlSF_MultiUE_NoneGBR
#     Adjust HBTE ATT Values    ${ATTENUATION_VALUE_CA_1}
#     Enable CB006457-B online    cell_id=1
#     Enable "actNbrForNonGbrBearers" online    cell_id=2
#     Online modify parameters NBR for MAC    MAC_ID=1    nbrDl=50000    nbrUl=10000
#     Online modify parameters "nbrUlDlSF" for arp    NBR_SF_value=0.7	
#     UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-C_02.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${get_counter}    Run keyword and ignore error    Check NBR Counters for NSA CA
#     ...    exp_C03506=1    exp_C03507=1    exp_C03506_scell=1    exp_C03507_scell=1
#     Run keyword if    '${get_counter}[0]'=='FAIL'    Run Keywords    sleep   ${wait_time_next}min
#     ...    AND    Check NBR Counters for NSA CA    exp_C03506=1    exp_C03507=1    exp_C03506_scell=1    exp_C03507_scell=1	
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the CA nbr of specific qosid is as expected
#     ...    qos=${qos}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=35000    exp_nbrul=7000
#     UE start traffic111    tp_direction=both    ul_tp=200M    dl_tp=2000M
#     UE check throughput by syslog    tp_direction=both    exp_dl_tp=1500    exp_ul_tp=70
# 	
# [1]CB006457-C_03_ArpBasedQosScaling_IWK_CA_Intra_Gnb_Pcell_Scell_nbrUlDlSF_SchedulingWeightSF_MultiUE_NoneGBR
#     Adjust HBTE ATT Values    ${ATTENUATION_VALUE_CA_1}
#     Enable CB006457-B online    cell_id=1
#     Disable "actNbrForNonGbrBearers" online    cell_id=2
#     Online modify parameters NBR for MAC    MAC_ID=1    nbrDl=500    nbrUl=100
#     Online modify parameters "nbrUlDlSF" for arp    NBR_SF_value=8    index=0	
#     UE Prepare
#     Set test variable    ${pcap_log_name}    CB006457-C_03.pcap
#     Get pcap file for master during UE attach    log_path=/tmp   log_name=${pcap_log_name}
#     ${get_counter}    Run keyword and ignore error    Check NBR Counters for NSA CA
#     ...    exp_C03506=1    exp_C03507=1    exp_C03506_scell=0    exp_C03507_scell=0
#     Run keyword if    '${get_counter}[0]'=='FAIL'    Run Keywords    sleep   ${wait_time_next}min
#     ...    AND    Check NBR Counters for NSA CA    exp_C03506=1    exp_C03507=1    exp_C03506_scell=0    exp_C03507_scell=0	
#     ${qos}    ${nbrdl}    ${nbrul}    Get the NBR of multi DRB
#     Check the CA nbr of specific qosid is as expected
#     ...    qos=${nbrQoS_list}    nbrdl=${nbrdl}    nbrul=${nbrul}    exp_nbrdl=4000    exp_nbrul=800
#     UE start traffic111    tp_direction=both    ul_tp=200M    dl_tp=2000M
#     UE check throughput by syslog    tp_direction=both    exp_dl_tp=1500    exp_ul_tp=70	
# 	
# 	
# *** Keywords ***	
# Adjust HBTE ATT Values
#     [Arguments]      ${attenuation_values_of_all_ports}
#     log to console    Adjust HBTE ATT Value
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_port_1}   vendor=${vendor}    model=${model}
#     FOR  ${port_num}    IN RANGE    1    13
#         ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
#         att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
#         ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
#         should be equal    ${value_port}    ${att_value}
#     END
# 
# CB006457 NSA CA case Preparation
#     [Arguments]    ${gnb_index}=0
#     log to console    \n*** CB006457 Case Preparation***
#     ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
#     Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
#     ${Active_SW_version}    Get Active SW Version    connection=${connection}
#     set suite variable      ${Active_SW_version}
#     ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
#     set suite variable      ${Golden_SCF_Path}
#     ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
#     ...    scf_parameters_list=${PARAMETERS_TO_CB006457_NSA_enable}
#     &{result}    coam.perform_commissioning    scf_file=${output_scf_file_path}
#     ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
# 	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
# 	Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
#     [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
# 	
# UE start traffic111
#     [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
#     log to console    UE start traffic
#     Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
#     ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B    iperf_port=${iperf_port_dl}
#     sleep    3s
#     Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
#     ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command    iperf_port=${iperf_port_ul}	
# 	
# Stop traffic for CA and detach UE
#     Run Keyword And Ignore Error    UE stop traffic    tp_direction=dl    iperf_port_dl=${iperf_port_dl}
#     Run Keyword And Ignore Error    UE stop traffic    tp_direction=ul    iperf_port_ul=${iperf_port_ul}
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
# 
# Check the CA nbr of specific qosid is as expected
#     [Arguments]    ${qos}    ${nbrdl}    ${nbrul}    ${exp_nbrdl}    ${exp_nbrul}
#     Log To Console    Check the scheduleight of specific qosid is as expected
#     csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
#     ...               username=${tl.test_pc.default_ssh_connection_details.username}
#     ...               password=${tl.test_pc.default_ssh_connection_details.password}
#     ...               alias=ute	
#     ${lenght_nbrdl}=   get length   ${nbrdl}
# 	${lenght_nbrul}=   get length   ${nbrul}
#     ${lenght_qosId}=   get length   ${qos}
# 	Should be equal    ${lenght_nbrdl}    ${lenght_qosId}
# 	Should be true    '${lenght_nbrul}' == '1'
#     :FOR    ${i}    IN RANGE    ${lenght_qosId}
#     \    should be true    '${nbrdl[${i}]}' == '${exp_nbrdl}'
#     \    run keyword if    '${i}' == '0'    should be true    '${nbrul[0]}' == '${exp_nbrul}'
#     [teardown]  csn.disconnect    connection=ute
# 	
# Check NBR Counters for NSA CA
#     [Arguments]    ${exp_C03506}=1    ${exp_C03507}=1    ${interval}=5min    ${exp_C03506_scell}=1    ${exp_C03507_scell}=1
#     log to console    \n*** Check NBR Counters M55115C03506 and M55115C03507 for multi nonGBR***	
#     Connect to Common Unit Master
#     selenium login and disable screen lock    download_dir=/tmp
#     Set test variable    ${get_counter}    False
#     ${check_time}    Get PM Counter time   interval=${interval}
#     ${wait_time_next}    Get wait value minutes
#     run keyword if    '${wait_time_next}' == '5.0'    set test variable   ${wait_time_next}    4.0  
#     set test variable   ${wait_time_next}
#     ${btsname}    selenium_coam.get_bts_name
#     log to console    ${MR_NR_BTS_NAME}
#     Set test variable	 ${pmcounter_path}    [${btsname}] ${MR_NR_BTS_NAME}
#     Set test variable	 ${full_path_C03506_pcell}    ${pmcounter_path}/NRCELL-1/RACDU/NSA_DU_DRB_NBR_REQ
#     Set test variable	 ${full_path_C03507_pcell}    ${pmcounter_path}/NRCELL-1/RACDU/NSA_DU_DRB_NBR_ADMIT_WITH_NBR
#     Set test variable	 ${full_path_C03506_scell}    ${pmcounter_path}/NRCELL-2/RACDU/NSA_DU_DRB_NBR_REQ
#     Set test variable	 ${full_path_C03507_scell}    ${pmcounter_path}/NRCELL-2/RACDU/NSA_DU_DRB_NBR_ADMIT_WITH_NBR
#     ${C03506_pcell}    Get PM Counter via Webem for CB006457    counter_id=M55115C03506    interval=${interval}
#     ...    check_time=${check_time}    full_path=${full_path_C03506_pcell}
#     ${C03507_pcell}    Get PM Counter via Webem for CB006457    counter_id=M55115C03507    interval=${interval}
#     ...    check_time=${check_time}    full_path=${full_path_C03507_pcell}
#     Should be equal      ${C03506_pcell}    ${exp_C03506}
#     Should be equal      ${C03507_pcell}    ${exp_C03507}
#     ${C03506_scell}    Get PM Counter via Webem for CB006457    counter_id=M55115C03506    interval=${interval}
#     ...    check_time=${check_time}    full_path=${full_path_C03506_scell}
#     ${C03507_scell}    Get PM Counter via Webem for CB006457    counter_id=M55115C03507    interval=${interval}
#     ...    check_time=${check_time}    full_path=${full_path_C03507_scell}
#     Should be equal      ${C03506_scell}    ${exp_C03506_scell}
#     Should be equal      ${C03507_scell}    ${exp_C03507_scell}	
#     [Return]   ${get_counter}
#     [Teardown]     run keyword and ignore error    selenium logout and close browser	
# 	
# 
# Setting CB006457-B online
#     [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}
#     log to console    Setting CB006457-B online
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
#     ...    parameter=multiArpBasedParam
#     ...    value=[{“arpPrioLev”: 8, “nbrUlDlSF”: 0.7, “schedulingWeightSF”: 7}]
#     ...    operation=update
#     ...    skip_parameter_relation_errors=skip
#     ...    connection=GNB_OAM
