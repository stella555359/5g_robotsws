*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        robot_common_operations.Common Case Setup   allowed_faults_ids=7300   fail_with_alarms=${False}
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    ./Resources/CB006457_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py
Variables   ./Resources/CB006457_scf_modify.py

Documentation
...    author: Wang Xiaocui
...    contact: xiaocui.wang@nokia-sbell.com
...    squad group: MMW3
...    feature : CB006457

Force Tags    CRT_TRUNK

*** Variables ***
${scf_relative_dir}    commissionings/HGZ
${btsname}    SBTS_4G_FXED
${DRB_QCI9}    ${MR_NR_BTS_NAME}/NRDRB-14
@{schedulingWeightSF_list}    1   7    51    100
${schedulingWeightSF}    1.1
${schedulWeight}     15
${MAC_QCI9}    ${MR_NR_BTS_NAME}/NRDRB_MAC-9
@{nbrUlDlSF_list}    1   100
${nbrDl}    1
${nbrUl}     1
${schedulBSD}    100ms
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${log_name}    cprt.pcap
${MR_NR_CELL_NAME}     ${MR_NR_BTS_NAME}/NRCELL-21
${MR_LTE_CELL_NAME}    MRBTS-2077/LNBTS-2077/LNCEL-11
*** Test Cases ***

[1]CB006457-A_B3_01_ArpBasedQosScaling_SchedulingWeightSF_maximum_minimum_value_multiUE_NoneGBR
    [Documentation]    case is running in SA testline
	Test case prepare
	SCF Commission to cell on air    scf_name=SCF_${stream}.xml
	Lock LTE Cell to avoid UE attached to 4G
	UE Prepare
	#Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_Normal_1}
	set test variable   ${schedulWeight}    16
    Online modify parameters "schedulWeight" of QCI9    target_value=${schedulWeight}
    Loop to check the scaled schedulingweight
	[Teardown]    Run Keywords    robot_common_operations.Common Case Teardown   AND    Unlock LTE Cell to Normal
    ...    AND   CI_interface.Common Case Teardown

[1]CB006457-B_B3_01_ArpBasedQosScaling_nbrUlDlSF_DL_UL_Maximum_Minimum_Value_MultiUE_NoneGBR
    [Documentation]    case is running in NSA testline
	Test case prepare
	SCF Commission to cell on air    scf_name=SCF_${stream}.xml
	Lock LTE Cell to avoid UE attached to 4G
	UE Prepare
	set test variable   ${nbrDl}    10
    set test variable   ${nbrUl}    10
    Online modify parameters actNbrForNonGbrBearers       target_value=true
    Online modify parameters "Nominal bit rate" of QCI9
    Loop to check the scaled Nominal bit rate
    set test variable   ${nbrDl}    500000
    set test variable   ${nbrUl}    100000
	Online modify parameters "Nominal bit rate" of QCI9
    Loop to check the scaled Nominal bit rate
    set test variable   ${nbrDl}    144126
    set test variable   ${nbrUl}    14569
	Online modify parameters "Nominal bit rate" of QCI9
    Loop to check the scaled Nominal bit rate
    set test variable   ${nbrDl}    367372
    set test variable   ${nbrUl}    56114
	Online modify parameters "Nominal bit rate" of QCI9
    Loop to check the scaled Nominal bit rate
	[Teardown]    Run Keywords    robot_common_operations.Common Case Teardown   AND    Unlock LTE Cell to Normal
    ...    AND   CI_interface.Common Case Teardown

*** Keywords ***
Test case prepare
    Get Stream and SW full version for mcshark
    Download MCShark To UTE

UE attach and start traffic
    [Arguments]    ${dl_tp}=100K
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=${dl_tp}   iperf_port_dl=50227
    Wait for one counter period     interval_time=5min

Online modify parameters "schedulingWeightSF"
	[Arguments]       ${new_value}
    Connect to gnb coam via ssl
    coam_parameter.perform_single_parameter_update      dist_name=${MR_NR_BTS_NAME}
	...                                         list_name=multiArpBasedParam
    ...                                         parameter=schedulingWeightSF
    ...                                         value=${new_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Online modify parameters actArpBasedQosScaling to true
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_NR_BTS_NAME}
    ...                                         parameter=actArpBasedQosScaling
    ...                                         operation=update
    ...                                         value=true
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections
Online modify parameters "schedulWeight" of QCI9
    [Arguments]    ${target_value}
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${DRB_QCI9}
    ...                                         parameter=schedulWeight
    ...                                         operation=update
    ...                                         value=${target_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

calculate the expected scaled schedulingWeight
    [Arguments]    ${schedulingWeightSF}       ${schedulWeight}   ${expected_value}=0
	${tmp_1}    evaluate        ${schedulingWeightSF}*${schedulWeight}*0.1
    ${tmp_2}    convert to number    ${tmp_1}    0
	${tmp_3}    convert to integer   ${tmp_2}
	set test variable    ${expected_value}    ${tmp_3}
	run keyword if    ${tmp_3}>100    set test variable    ${expected_value}    ${100}
	run keyword if    ${tmp_3}<1      set test variable    ${expected_value}   ${1}
    log to console    expected_value=${expected_value}
    [return]    ${expected_value}

Loop to check the scaled schedulingweight
    FOR    ${schedulingWeightSF}    IN    @{schedulingWeightSF_list}
        Online modify parameters "schedulingWeightSF"   new_value=${schedulingWeightSF}
	    calculate the expected scaled schedulingWeight    schedulingWeightSF=${schedulingWeightSF}    schedulWeight=${schedulWeight}
	    Run Keyword And Continue On Failure    Get pcap during UE attach    log_name=${log_name}   log_path=/tmp
	    Run Keyword And Continue On Failure    Check the schedulWeight is as expected    display_filter=itf_l2_ps_DrbAddReqPs.qosId==9
	    Detach UE
    END

Test Case setup to on air
    [Arguments]    ${scf_name}    ${scf_parameters}
    COAM Create log directory
    ${output_scf_file_path}    COAM Modify scf file    scf_file_path=${scf_name}    scf_parameters_list=${scf_parameters}
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${output_scf_file_path}    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

Get pcap during UE Handover
    [Arguments]    ${log_path}    ${log_name}    ${gnb_index}=0

	ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=GNB_OAM
    Start Tcpdump for CB006457    log_name=${log_name}   log_path=/tmp
	Log to console     please adjust ATT

	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_HO_1}
	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_HO_2}
	Adjust HBTE ATT Values    attenuation_values_of_all_ports=${ATTENUATION_VALUE_HO_3}
    Stop Tcpdump for CB006457
	ssh.download_file    remote_path=${log_path}/${log_name}
    ...                  local_path=${EXECDIR}/${log_name}
    ...                  connection=GNB_OAM
	ssh.execute
    ...    command=rm -rf ${log_path}/${log_name}
    ...    connection=GNB_OAM
	Detach UE
Modify NRREL for Handover

    selenium login and disable screen lock
	selenium_coam.delete_parameter
	...    dist_name=${MR_NR_CELL_NAME}/NRREL-1    filter_param=Secondary cell addition method
	selenium_coam.delete_parameter
	...    dist_name=${MR_NR_CELL_NAME_2}/NRREL-1    filter_param=Secondary cell addition method
	selenium_coam.delete_parameter
	...    dist_name=${MR_NR_CELL_NAME}/NRREL-1    filter_param=Secondary cell operational mode
	selenium_coam.delete_parameter
	...    dist_name=${MR_NR_CELL_NAME_2}/NRREL-1    filter_param=Secondary cell operational mode
	selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
	Connect to gnb coam via ssl
	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
	[Teardown]  Run keyword and ignore error    selenium logout and close browser
Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
	...    model=${model}
    FOR  ${port_num}    IN RANGE    1    13
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Online modify parameters actNbrForNonGbrBearers
    [Arguments]    ${target_value}
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_NR_CELL_NAME}
    ...                                         parameter=actNbrForNonGbrBearers
    ...                                         operation=update
    ...                                         value=${target_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Online modify parameters "Nominal bit rate" of QCI9

    [Arguments]    ${target_value_dl}=${nbrDl}    ${target_value_ul}=${nbrUl}
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MAC_QCI9}
    ...                                         parameter=nbrDl
    ...                                         operation=update
    ...                                         value=${target_value_dl}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
	    coam.perform_parameter_recommissioning      dist_name=${MAC_QCI9}
    ...                                         parameter=nbrUl
    ...                                         operation=update
    ...                                         value=${target_value_ul}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Online modify parameters "nbrUlDlSF"
	[Arguments]       ${new_value}
    Connect to gnb coam via ssl
    coam_parameter.perform_single_parameter_update      dist_name=${MR_NR_BTS_NAME}
	...                                         list_name=multiArpBasedParam
    ...                                         parameter=nbrUlDlSF
    ...                                         value=${new_value}
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections

Loop to check the scaled Nominal bit rate
    FOR    ${nbrUlDlSF}    IN    @{nbrUlDlSF_list}
        Online modify parameters "nbrUlDlSF"   new_value=${nbrUlDlSF}
	    calculate the expected scaled Nominal bit rate    nbrUlDlSF=${nbrUlDlSF}    nbrDl=${nbrDl}    nbrUl=${nbrUl}
	    Run Keyword And Continue On Failure    Get pcap during UE attach    log_name=cprt_nbr.pcap    log_path=/tmp
	    Run Keyword And Continue On Failure    Check the Nominal bit rate is as expected
		Detach UE
    END

Check the Nominal bit rate is as expected

     [Arguments]    ${local_pcap_file}=${EXECDIR}/cprt_nbr.pcap    ${field_name_DL}=itf_l2_ps_NbrDrbSpecificParams.nbrDl_item
	 ...    ${field_name_UL}=itf_l2_ps_NbrDrbSpecificParams.nbrUl_item
      cap.Read Cap    cap_file=${local_pcap_file}    display_filter=sctp
      ${res_value_DL}        cap.get_field_value_by_name    field_name=${field_name_DL}
	  ${res_value_UL}        cap.get_field_value_by_name    field_name=${field_name_UL}
	  ${real_value_DL}     convert to integer     ${res_value_DL}[0]
	  ${real_value_UL}     convert to integer     ${res_value_UL}[0]
 	 Should be equal    ${real_value_UL}     ${expected_value_UL}
	 Should be equal    ${real_value_DL}     ${expected_value_DL}

calculate the expected scaled Nominal bit rate
    [Arguments]    ${nbrUlDlSF}       ${nbrDl}   ${nbrUl}     ${expected_value_DL}=0    ${expected_value_UL}=0
	${tmp_1_DL}    evaluate        ${nbrUlDlSF}*${nbrDl}*0.1
	run keyword if    ${tmp_1_DL}>500000    set test variable    ${tmp_1_DL}    ${500000}
	run keyword if    ${tmp_1_DL}<10      set test variable    ${tmp_1_DL}   ${10}
	${tmp_2_DL}    convert to number    ${tmp_1_DL}    0
	${tmp_3_DL}    convert to integer   ${tmp_2_DL}
	set test variable    ${expected_value_DL}    ${tmp_3_DL}
    log to console    For DL expected_value=${expected_value_DL}
	${tmp_1_UL}    evaluate        ${nbrUlDlSF}*${nbrUl}*0.1
	run keyword if    ${tmp_1_UL}>100000    set test variable    ${tmp_1_UL}    ${100000}
	run keyword if    ${tmp_1_UL}<10      set test variable    ${tmp_1_UL}   ${10}
	${tmp_2_UL}    convert to number    ${tmp_1_UL}    0
	${tmp_3_UL}    convert to integer   ${tmp_2_UL}
	set test variable    ${expected_value_UL}    ${tmp_3_UL}
    log to console    for UL expected_value=${expected_value_UL}
    [return]    ${expected_value_DL}    ${expected_value_UL}

Lock LTE Cell to avoid UE attached to 4G
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_LTE_CELL_NAME}
    ...                                         parameter=administrativeState
    ...                                         operation=update
    ...                                         value=locked
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections
Unlock LTE Cell to Normal
    Connect to gnb coam via ssl
    coam.perform_parameter_recommissioning      dist_name=${MR_LTE_CELL_NAME}
    ...                                         parameter=administrativeState
    ...                                         operation=update
    ...                                         value=unlocked
    ...                                         skip_parameter_relation_errors=${False}
    ...                                         timeout=700
    ...                                         should_activate=True
    ...                                         connection=GNB_OAM
    [Teardown]    COAM Teardown gnb connections
