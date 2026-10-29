# *** Settings ***
# Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
# Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
# Test Setup        Run Keywords    robot_common_operations.Common Case Setup
# Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown
# 
# Resource    ./Resources/CB006457_common_keywords.robot
# Variables   ./Resources/CB006457_scf_modify.py
# 
# Documentation
# ...    author: Wang Xiaocui
# ...    contact: xiaocui.wang@nokia-sbell.com
# ...    squad group: MMW3
# ...    feature : CB006457
# 
# Force Tags    CRT_TRUNK
# 
# *** Variables ***
# ${scf_relative_dir}    commissionings/HGZ
# 
# ${btsname}    SBTS_4G_FXED
# ${DRB_QCI7}    ${MR_NR_BTS_NAME}/NRDRB-4
# @{schedulingWeightSF_list}    0.1   0.7    5.1    10
# ${schedulingWeightSF}    1.1
# ${schedulWeight}     15
# 
# 
# 
# ${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
# ${log_name}    cprt.pcap
# 
# 
# *** Test Cases ***
# [1]CB006457-A_B3_01_ArpBasedQosScaling_SchedulingWeightSF_maximum_minimum_value_multiUE_NoneGBR
#     [Documentation]    case is running in SA testline
# 	Test case prepare
# 	SCF Commission to cell on air    scf_name=SCF_${stream}.xml
# 	UE Prepare
# 	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_Normal_1}
# 	set test variable   ${schedulWeight}    16
#     Online modify parameters "schedulWeight" of QCI7    new_value=${schedulWeight}
#     Loop to check the scaled schedulingweight
# 
# 	
# [1]CB006457-A_B2_03_ArpBasedQosScaling_SchedulingWeightSF_MultiUE_Intra_gnb_HO_NSA
#     [Documentation]    case is running in SA testline
# 	Test case prepare
# 	Test Case setup to on air    scf_name=${scf_file_template_path}/SCF_${stream}.xml    scf_parameters=${PARAMETERS_TO_Handover_enable}
#     Modify NRREL for Handover
# 	UE Prepare
# 	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_Normal_1}
# 	set test variable   ${schedulWeight}    12
# 	Online modify parameters "schedulWeight" of QCI7    new_value=${schedulWeight}
# 	Online modify parameters "schedulingWeightSF"   new_value=${schedulingWeightSF}
# 	calculate the expected scaled schedulingWeight    schedulingWeightSF=${schedulingWeightSF}    schedulWeight=${schedulWeight}  
# 	Get pcap during UE attach    log_name=cprt_beforeho.pcap    log_path=/tmp
# 	Run Keyword And Continue On Failure    Check the schedulWeight is as expected    local_pcap_file=${EXECDIR}/cprt_beforeho.pcap 
# 	Get pcap during UE Handover  log_name=cprt_afterho.pcap     log_path=/tmp
# 	Check the schedulWeight is as expected        local_pcap_file=${EXECDIR}/cprt_afterho.pcap      field_name=itf_l2_ps_DrbAddReqPs.schedulWeight
# 	...    display_filter=itf_l2_ps_CellConfigParam_t.nrCellIdentity == 173670405
# 
# 
# 	[Teardown]    Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_Normal_1}
# *** Keywords ***
# Test case prepare
#     Get Stream and SW full version for mcshark
#     Download MCShark To UTE
# 	
# UE attach and start traffic
#     [Arguments]    ${dl_tp}=100K
# 	UE Prepare
# 	Attach UE
#     UE start traffic    tp_direction=dl    dl_tp=${dl_tp}   iperf_port_dl=50227
#     Wait for one counter period     interval_time=5min
# 	
# Online modify parameters "schedulingWeightSF" 
#     [Arguments]       ${new_value}
#     selenium login and disable screen lock
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${MR_NR_BTS_NAME}    filter_param=Scaling factor for scheduling weight    new_value=${new_value}
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser	
# 
# 
# Online modify parameters actArpBasedQosScaling to true	
#     selenium login and disable screen lock
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${MR_NR_BTS_NAME}    filter_param=Activate ARP based QoS scaling   new_value=true
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser
# 	
# Online modify parameters "schedulWeight" of QCI7
#     [Arguments]       ${new_value}
#     selenium login and disable screen lock
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${DRB_QCI7}    filter_param=Scheduling weight   new_value=${new_value}
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser
# 	
# 
# calculate the expected scaled schedulingWeight
#     [Arguments]    ${schedulingWeightSF}       ${schedulWeight}   ${expected_value}=0
# 	${tmp_1}    evaluate        ${schedulingWeightSF}*${schedulWeight}
#     ${tmp_2}    convert to number    ${tmp_1}    0	
# 	${tmp_3}    convert to integer   ${tmp_2}
# 	set test variable    ${expected_value}    ${tmp_3}
# 	run keyword if    ${tmp_3}>100    set test variable    ${expected_value}    ${100}
# 	run keyword if    ${tmp_3}<1      set test variable    ${expected_value}   ${1}
#     log to console    expected_value=${expected_value}
#     [return]    ${expected_value}
# 		
# Loop to check the scaled schedulingweight
#     FOR    ${schedulingWeightSF}    IN    @{schedulingWeightSF_list}
#         Online modify parameters "schedulingWeightSF"   new_value=${schedulingWeightSF}
# 	    calculate the expected scaled schedulingWeight    schedulingWeightSF=${schedulingWeightSF}    schedulWeight=${schedulWeight}  
# 	    Run Keyword And Continue On Failure    Get pcap during UE attach    log_name=${log_name}   log_path=/tmp	 
# 	    Run Keyword And Continue On Failure    Check the schedulWeight is as expected
# 	    Detach UE	
#     END
# 
# Test Case setup to on air
#     [Arguments]    ${scf_name}    ${scf_parameters}    ${is_pdl_checking_needed}=${False}
#     COAM Create log directory
#     ${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_name}    scf_parameters_list=${scf_parameters}
# 	Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${output_scf_file_path}    is_pdl_checking_needed=${False}    timeout=600s
#    	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
#     Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
#    [Teardown]    COAM Teardown gnb connections
#    
# Get pcap during UE Handover
#     [Arguments]    ${log_path}    ${log_name}    ${gnb_index}=0
# 	
# 	ssh.Connect to
#     ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#     ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
#     ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
#     ...    alias=GNB_OAM
#     Start Tcpdump for CB006457    log_name=${log_name}   log_path=/tmp
# 	Log to console     please adjust ATT
# 	
# 	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_HO_1}
# 	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_HO_2}
# 	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_HO_3}
#     Stop Tcpdump for CB006457
# 	ssh.download_file    remote_path=${log_path}/${log_name}
#     ...                  local_path=${EXECDIR}/${log_name}
#     ...                  connection=GNB_OAM
# 	ssh.execute
#     ...    command=rm -rf ${log_path}/${log_name}
#     ...    connection=GNB_OAM
# 	Detach UE
# Modify NRREL for Handover
# 
#     selenium login and disable screen lock
# 	selenium_coam.delete_parameter
# 	...    dist_name=${MR_NR_CELL_NAME}/NRREL-1    filter_param=Secondary cell addition method
# 	selenium_coam.delete_parameter
# 	...    dist_name=${MR_NR_CELL_NAME_2}/NRREL-1    filter_param=Secondary cell addition method
# 	selenium_coam.delete_parameter
# 	...    dist_name=${MR_NR_CELL_NAME}/NRREL-1    filter_param=Secondary cell operational mode
# 	selenium_coam.delete_parameter
# 	...    dist_name=${MR_NR_CELL_NAME_2}/NRREL-1    filter_param=Secondary cell operational mode
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	Connect to gnb coam via ssl
# 	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser
# Adjust HBTE ATT Values
#     [Arguments]      ${attenuation_values_of_all_ports}
#     log to console    Adjust HBTE ATT Value
#     att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
#     ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
# 	...    model=${model}
#     FOR  ${port_num}    IN RANGE    1    13
#         ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
#         att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
#         ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
#         should be equal    ${value_port}    ${att_value}
#     END