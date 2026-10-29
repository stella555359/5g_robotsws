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
# ${MAC_QCI7}    ${MR_NR_BTS_NAME}/NRDRB_MAC-1
# 
# #@{nbrUlDlSF_list}    0.1   2.4    6.9   10
# @{nbrUlDlSF_list}    0.1   10
# ${nbrDl}    1
# ${nbrUl}     1
# ${schedulBSD}    100ms
# 
# *** Test Cases ***
# [1]CB006457-B_B3_01_ArpBasedQosScaling_nbrUlDlSF_DL_UL_Maximum_Minimum_Value_MultiUE_NoneGBR
#     [Documentation]    case is running in NSA testline
# 	Test case prepare
# 	SCF Commission to cell on air    scf_name=SCF_${stream}.xml
# 	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_Normal_1}
# 	UE Prepare
# 	set test variable   ${nbrDl}    0.01
#     set test variable   ${nbrUl}    0.01
#     Online modify parameters actNbrForNonGbrBearers       new_value=true     
#     Online modify parameters "Nominal bit rate" of QCI7
#     Loop to check the scaled Nominal bit rate
#     set test variable   ${nbrDl}    500
#     set test variable   ${nbrUl}    100
# 	Online modify parameters "Nominal bit rate" of QCI7
#     Loop to check the scaled Nominal bit rate
#     set test variable   ${nbrDl}    144.126
#     set test variable   ${nbrUl}    14.569
# 	Online modify parameters "Nominal bit rate" of QCI7
#     Loop to check the scaled Nominal bit rate
#     set test variable   ${nbrDl}    367.372
#     set test variable   ${nbrUl}    56.114
# 	Online modify parameters "Nominal bit rate" of QCI7
#     Loop to check the scaled Nominal bit rate	
# *** Keywords ***
# 
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
# Online modify parameters actNbrForNonGbrBearers 
#     [Arguments]       ${new_value}
#     selenium login and disable screen lock
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${MR_NR_CELL_NAME}    filter_param=Activate nominal bitrate for non-GBR bearers   new_value=${new_value}
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser
# 
# 
# 	
# Online modify parameters "nbrUlDlSF" 
#     [Arguments]       ${new_value}
#     selenium login and disable screen lock
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${MR_NR_BTS_NAME}    filter_param=Scaling factor for nominal bitrates for UL and DL   new_value=${new_value}
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser	
# 
# 	
# Online modify parameters "Nominal bit rate" of QCI7
#     #[Arguments]       ${new_value}
#     selenium login and disable screen lock
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${MAC_QCI7}    filter_param=Nominal bit rate downlink    new_value=${nbrDl}
# 		selenium_coam.set_parameter_value
# 	...    dist_name=${MAC_QCI7}    filter_param=Nominal bit rate uplink     new_value=${nbrUl}
# 	
# 	selenium_coam.set_parameter_value
# 	...    dist_name=${MAC_QCI7}    filter_param=Scheduling bucket size duration    new_value=${schedulBSD}
# 	selenium_coam.validate_plan
#     selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
# 	[Teardown]  Run keyword and ignore error    selenium logout and close browser
# 	
# 
# calculate the expected scaled Nominal bit rate
#     [Arguments]    ${nbrUlDlSF}       ${nbrDl}   ${nbrUl}     ${expected_value_DL}=0    ${expected_value_UL}=0
# 	${tmp_1_DL}    evaluate        ${nbrUlDlSF}*${nbrDl}*1000
# 	run keyword if    ${tmp_1_DL}>500000    set test variable    ${tmp_1_DL}    ${500000}
# 	run keyword if    ${tmp_1_DL}<10      set test variable    ${tmp_1_DL}   ${10}
# 	${tmp_2_DL}    convert to number    ${tmp_1_DL}    0	
# 	${tmp_3_DL}    convert to integer   ${tmp_2_DL}
# 	set test variable    ${expected_value_DL}    ${tmp_3_DL}
#     log to console    For DL expected_value=${expected_value_DL}
# 	${tmp_1_UL}    evaluate        ${nbrUlDlSF}*${nbrUl}*1000
# 	run keyword if    ${tmp_1_UL}>100000    set test variable    ${tmp_1_UL}    ${100000}
# 	run keyword if    ${tmp_1_UL}<10      set test variable    ${tmp_1_UL}   ${10}
# 	${tmp_2_UL}    convert to number    ${tmp_1_UL}    0	
# 	${tmp_3_UL}    convert to integer   ${tmp_2_UL}
# 	set test variable    ${expected_value_UL}    ${tmp_3_UL}
#     log to console    for UL expected_value=${expected_value_UL}
#     [return]    ${expected_value_DL}    ${expected_value_UL}
# 		
# Loop to check the scaled Nominal bit rate
#     FOR    ${nbrUlDlSF}    IN    @{nbrUlDlSF_list}
#         Online modify parameters "nbrUlDlSF"   new_value=${nbrUlDlSF}
# 	    calculate the expected scaled Nominal bit rate    nbrUlDlSF=${nbrUlDlSF}    nbrDl=${nbrDl}    nbrUl=${nbrUl}
# 	    Run Keyword And Continue On Failure    Get pcap during UE attach    log_name=cprt_nbr.pcap    log_path=/tmp	 
# 	    Run Keyword And Continue On Failure    Check the Nominal bit rate is as expected
# 		Detach UE
#     END
# Check the Nominal bit rate is as expected
# 
#      [Arguments]    ${local_pcap_file}=${EXECDIR}/cprt_nbr.pcap   ${exp_value}=80    ${field_name_DL}=itf_l2_ps_NbrDrbSpecificParams.nbrDl_item
# 	 ...    ${field_name_UL}=itf_l2_ps_NbrDrbSpecificParams.nbrUl_item
#       cap.Read Cap    cap_file=${local_pcap_file}    display_filter=sctp
#       ${res_value_DL}        cap.get_field_value_by_name    field_name=${field_name_DL}
# 	  ${res_value_UL}        cap.get_field_value_by_name    field_name=${field_name_UL}
# 	  ${real_value_DL}     convert to integer     @{res_value_DL}[0] 
# 	  ${real_value_UL}     convert to integer     @{res_value_UL}[0] 
#  	 Should be equal    ${real_value_UL}     ${expected_value_UL}
# 	 Should be equal    ${real_value_DL}     ${expected_value_DL}
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