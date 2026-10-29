*** Settings ***
Documentation
...    author: yuanyuan.liu
...    contact:yuanyuan.liu@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB012119

Library     taf.sbts.oam.coam.admin   WITH NAME    coam

Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot



*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${num_of_files}   20
${UE_TYPE}    ${tl.ues[-1].capabilities[1]}
${ui_version}    Mi12UI13.0.41
${att_ipaddr}               ${tl.attenuator.ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_api_port}             ${tl.attenuator.port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${model}    PA-16-16-6-127-0.5-B-S

*** Keywords ***
CB012119 SA case Preparation
    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

CB012119 SA keep goldenSCF
    #COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    Run keyword if    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R1'   COAM Commission with scf file
	...    scf_file_path=${scf_file_template_path}/goldenSCF_${stream}.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections

Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${300}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

ADD PMQAP MO on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several MOs via rest api     objects_to_add_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections


Get wait value minutes
    [Arguments]    ${interval}
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    [Return]    ${wait_time}

UE Prepare
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### Prepare UE for UE_${ue_index}###
	Run keyword if    '${UE_TYPE}'=='samsung'    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
	Run keyword if    '${UE_TYPE}'=='xiaomi'     UE Prepare for xiaomi    ue_index=${ue_index}
    Run keyword if    '${UE_TYPE}'!='xiaomi'     power_ue.Prepare UE    ue_type=${UE_TYPE}

UE Prepare for xiaomi
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### Prepare UE ###
	power_ue.Prepare UE    ue_type=${UE_TYPE}  ui_version=${ui_version}    ue_index=${ue_index}

Attach UE
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### UE Attach for UE_${ue_index} ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    ...           ${iperf_port_dl}=43207    ${iperf_port_ul}=43107    ${ue_index}=${0}
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    ...     iperf_port=${iperf_port_dl}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command
    ...    iperf_port=${iperf_port_ul}

UE capability check
    [Arguments]    ${ue_capability}=samsung
    Run keyword if    '${ue_capability}'=='samsung'    set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[0]}
    ...      ELSE IF      '${ue_capability}'=='xiaomi'      set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[1]}


Detach UE
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### UE Detach ###
    Run Keyword And Ignore Error    UE stop traffic
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

UE stop traffic
    [Arguments]    ${tp_direction}=both
    log to console    UE stop traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Stop traffic
	...    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic
	...    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}


Wait for one counter period
    [Arguments]    ${interval_time}=5min
	${wait_time}    Get wait value minutes    interval=${interval_time}
	log to console      .....wait ${wait_time}mins+${interval_time}....
    sleep    ${wait_time}min
    sleep    ${interval_time}




Get PM Counter time
    [Arguments]   ${counter_id}=M55350C00027    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB012119   counter_id=${counter_id}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    [Return]    ${last_time}




hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}


Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006209
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    20s

answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s

Make a ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_S}    connection=cygwin${ue_index}
    sleep    5s

answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    5s

switch ViNR to VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
	Get VoNR and ViNR pointer variable with SamsungS21
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_button}    connection=cygwin${ue_index}
    sleep    1s
    #csn.send_command    command=adb -s ${serial_number} shell input tap ${switch_to_VoNR}    connection=cygwin${ue_index}

hang up VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep    5s



Set DL KPI Calculation formula
     Initialize the kpi value to zero
    # ${CB012119_A_tmp}   Run keyword if    ${value_M55310C00005}!=0   evaluate    ${value_M55310C00004}/(${value_M55310C00005}*1000)
	# Run keyword if    ${CB012119_A_tmp}!=${0} and ${CB012119_A_tmp}!=${None}     Set Suite Variable    ${CB012119_A}
	# ...   ${CB012119_A_tmp}
	# ${CB012119_A_PMQAP_tmp}   Run keyword if    ${value_M55158C00007}!=0   evaluate
	# ...    ${value_M55158C00006}/(${value_M55158C00007}*1000)
	# Run keyword if    ${CB012119_A_PMQAP_tmp}!=${0} and ${CB012119_A_PMQAP_tmp}!=${None}
	# ...     Set Suite Variable    ${CB012119_A_PMQAP}   ${CB012119_A_PMQAP_tmp}
     #${NR_6096a_tmp}   Run keyword if    ${value_M55310C00003}!=0   evaluate
	 #...    (${value_M55310C00002}-${value_M55310C00004})/(${value_M55310C00003}*1000)
	 #Run keyword if    ${NR_6096a_tmp}!=${0} and ${NR_6096a_tmp}!=${None}     Set Suite Variable    ${NR_6096a}   ${NR_6096a_tmp}

	 ${CB012119_B_tmp}   Run keyword if    ${value_M55310C00015}!=0     evaluate    ${value_M55310C00014}/(${value_M55310C00015}*1000)
	 Run keyword if    ${CB012119_B_tmp}!=0 and ${CB012119_B_tmp}!=None      Set Suite Variable    ${CB012119_B}   ${CB012119_B_tmp}
	 ${CB012119_B_PMQAP_tmp}   Run keyword if    ${value_M55158C00017}!=0   evaluate
	 ...    ${value_M55158C00016}/(${value_M55158C00017}*1000)
	 Run keyword if    ${CB012119_B_PMQAP_tmp}!=${0} and ${CB012119_B_PMQAP_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_B_PMQAP}   ${CB012119_B_PMQAP_tmp}

     ${CB012119_C_tmp}   Run keyword if    ${value_M55310C00007}!=0     evaluate    ${value_M55310C00006}/(${value_M55310C00007}*1000)
	 Run keyword if    ${CB012119_C_tmp}!=0 and ${CB012119_C_tmp}!=None      Set Suite Variable    ${CB012119_C}   ${CB012119_C_tmp}
	 ${CB012119_C_PMQAP_tmp}   Run keyword if    ${value_M55158C00009}!=0   evaluate
	 ...    ${value_M55158C00008}/(${value_M55158C00009}*1000)
	 Run keyword if    ${CB012119_C_PMQAP_tmp}!=${0} and ${CB012119_C_PMQAP_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_C_PMQAP}   ${CB012119_C_PMQAP_tmp}

	 ${CB012119_D_tmp}   Run keyword if    ${value_M55310C00011}!=0     evaluate    ${value_M55310C00010}/(${value_M55310C00011}*1000)
	 Run keyword if    ${CB012119_D_tmp}!=0 and ${CB012119_D_tmp}!=None      Set Suite Variable    ${CB012119_D}   ${CB012119_D_tmp}
	 ${CB012119_D_PMQAP_tmp}   Run keyword if    ${value_M55158C00013}!=0   evaluate
	 ...    ${value_M55158C00012}/(${value_M55158C00013}*1000)
	 Run keyword if    ${CB012119_D_PMQAP_tmp}!=${0} and ${CB012119_D_PMQAP_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_D_PMQAP}   ${CB012119_D_PMQAP_tmp}

	 ${CB012119_H_tmp}   Run keyword if    ${value_M55350C00024}!=0     evaluate    ${value_M55350C00023}/(${value_M55350C00024}*1000)
	 Run keyword if    ${CB012119_H_tmp}!=0 and ${CB012119_H_tmp}!=None      Set Suite Variable    ${CB012119_H}   ${CB012119_H_tmp}
	 ${CB012119_H_PMQAP_tmp}   Run keyword if    ${value_M55159C00002}!=0   evaluate
	 ...    ${value_M55159C00001}/(${value_M55159C00002}*1000)
	 Run keyword if    ${CB012119_H_PMQAP_tmp}!=${0} and ${CB012119_H_PMQAP_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_H_PMQAP}   ${CB012119_H_PMQAP_tmp}

#     log to console    CB012119_A=${CB012119_A},CB012119_A_PMQAP=${CB012119_A_PMQAP}
     log to console    CB012119_B=${CB012119_B},CB012119_B_PMQAP=${CB012119_B_PMQAP}
     log to console    CB012119_C=${CB012119_C},CB012119_C_PMQAP=${CB012119_C_PMQAP}
     log to console    CB012119_D=${CB012119_D},CB012119_D_PMQAP=${CB012119_D_PMQAP}
     log to console    CB012119_H=${CB012119_H},CB012119_H_PMQAP=${CB012119_H_PMQAP}
     #log to console    NR_6096a=${NR_6096a}

Initialize the kpi value to zero
    #Set Suite Variable    ${CB012119_A}    0
    Set Suite Variable    ${CB012119_B}    0
    Set Suite Variable    ${CB012119_C}    0
    Set Suite Variable    ${CB012119_D}    0
    Set Suite Variable    ${CB012119_H}    0
    #Set Suite Variable    ${CB012119_A_PMQAP}    0
    Set Suite Variable    ${CB012119_B_PMQAP}    0
    Set Suite Variable    ${CB012119_C_PMQAP}    0
    Set Suite Variable    ${CB012119_D_PMQAP}    0
    Set Suite Variable    ${CB012119_H_PMQAP}    0
    #Set Suite Variable    ${NR_6096a}    0

Get VoNR and ViNR pointer variable with SamsungS21
    Set Suite Variable    ${answer_ViNR_button}    296 2038
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    435 1405
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728


Get the latest PM Counter via admin_cli for CB012119
    [Arguments]    ${counter_id}    ${dic_path}=full
   ${content}   get_pm_counter_values
    ...    counter_id=${counter_id}     dic_path=${dic_path}    connection=GNB_OAM    timeout=120
    Set test variable    ${value}    ${content}[0]
    [Return]    ${value}

Get all DL counter value for the Corresponding 5QI via admin_cli
    [Arguments]    ${5QI_ID}=1
    Log To Console    Counter is not updated so quickly wait for more than 30s
	sleep    30s
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	run keyword if    '${stream}'=='SBTS24R1'    set test variable   ${MR_NR_CELL_NAME}    CELLS/NRCELL-1
	log to console     \n #######CB012119-A Counters####
	#${value_M55310C00004}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00004
	#...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	#Set Suite variable    ${value_M55310C00004}
	#${value_M55310C00005}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00005
	#...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	#Set Suite variable    ${value_M55310C00005}
 	#${value_M55158C00006}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00006
	#...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	#Set Suite variable    ${value_M55158C00006}
	#${value_M55158C00007}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00007
	#...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	#Set Suite variable    ${value_M55158C00007}
    log to console     \n #######CB008158-A Counters####
	${value_M55310C00002}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00002}
	${value_M55310C00003}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00003
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00003}
	log to console      \n ########CB012119-B Counters####
	${value_M55310C00014}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00014
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00014}
	${value_M55310C00015}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00015
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00015}
 	${value_M55158C00016}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00016
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00016}
	${value_M55158C00017}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00017
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00017}

	log to console      \n ########CB012119-C Counters####
	${value_M55310C00006}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00006
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00006}
	${value_M55310C00007}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00007
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00007}
 	${value_M55158C00008}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00008
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00008}
	${value_M55158C00009}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00009
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00009}

	log to console      \n ########CB012119-D Counters####
	${value_M55310C00010}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00010
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00010}
	${value_M55310C00011}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55310C00011
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00011}
 	${value_M55158C00012}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00012
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00012}
	${value_M55158C00013}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55158C00013
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00013}

	log to console      \n ########CB012119-H Counters####
	${value_M55350C00023}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55350C00023
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00023}
	${value_M55350C00024}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55350C00024
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00024}
 	${value_M55159C00001}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00001}
	${value_M55159C00002}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00002}
	[Teardown]



Test Case teardown in case failure
     Connect to gnb coam via ssl
     COAM Save Snapshot Via Rest Api    log_path=${LOG_PATH}    timeout=600s


5QI-7 Big traffic condition
    [Arguments]    ${ue_index}
    UE Prepare    ue_index=${ue_index}
	Attach UE     ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=195M    iperf_port_dl=43207    ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 7 big traffic counters ###
    Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=7
	Set DL KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43207
	check DL kpi for 5QI-7 big traffic condition
	[Teardown]    Detach UE     ue_index=${ue_index}

5QI-7 small traffic condition
    [Arguments]    ${ue_index}
	UE Prepare    ue_index=${ue_index}
	Attach UE     ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=300k   iperf_port_dl=43207    ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 7 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=${5QI_value}
	Set DL KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}   ue_type=${UE_TYPE}   iperf_port=43207
	check DL kpi for 5QI-7 small traffic condition
	[Teardown]    Detach UE      ue_index=${ue_index}

5QI-8 small traffic condition
    [Arguments]    ${ue_index}
    UE Prepare    ue_index=${ue_index}
	Attach UE     ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=300k   iperf_port_dl=43208   ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 8 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=8
	Set DL KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43208
	check DL kpi for 5QI-8 small traffic condition
	[Teardown]    Detach UE    ue_index=${ue_index}


5QI-4 Big traffic condition
    [Arguments]    ${ue_index}
    UE Prepare      ue_index=${ue_index}
	Attach UE       ue_index=${ue_index}
	Set Test variable     ${5QI_value}    4
	UE start traffic    tp_direction=dl    dl_tp=50M   iperf_port_dl=43204    ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 4 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=${5QI_value}
	Set DL KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43204
	check DL kpi for 5QI-4 big traffic condition
	[Teardown]    Detach UE      ue_index=${ue_index}

5QI-4 small traffic condition
    [Arguments]    ${ue_index}
    UE Prepare      ue_index=${ue_index}
	Attach UE       ue_index=${ue_index}
	Set Test variable     ${5QI_value}    4
	UE start traffic    tp_direction=dl    dl_tp=50K  iperf_port_dl=43204      ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 4 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=${5QI_value}
	Set DL KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43204
	check DL kpi for 5QI-4 small traffic condition
	[Teardown]    Detach UE      ue_index=${ue_index}

5QI-1 and 5QI-2 and 5QI-5 traffic condition
	UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
    Make a VoNR call     ue_index=${0}    phone_number=13031398566
	answer VoNR call    ue_index=${1}
	Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 1 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=1
	Set DL KPI Calculation formula
	check DL kpi for 5QI-1 VONR traffic condition
	Log To Console    \n ### 5QI_ID 5 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=5
	Set DL KPI Calculation formula
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 1 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=1
	Set DL KPI Calculation formula
	check DL kpi for 5QI-1 VINR traffic condition
	Log To Console    \n ### 5QI_ID 2 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=2
	Set DL KPI Calculation formula
	check DL kpi for 5QI-2 traffic condition
	Log To Console    \n ### 5QI_ID 5 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=5
	Set DL KPI Calculation formula
	check DL kpi for 5QI-5 traffic condition
	hang up VoNR and ViNR call    ue_index=${0}
	[Teardown]   Run keywords     Detach UE   ue_index=${0}   AND   Detach UE   ue_index=${1}


Get Part-C UL counter value for the Corresponding 5QI via admin_cli
    [Arguments]    ${5QI_ID}=1
    Log To Console    Counter is not updated so quickly wait for more than 30s
	sleep    30s
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	run keyword if    '${stream}'=='SBTS24R1'    set test variable   ${MR_NR_CELL_NAME}    CELLS/NRCELL-1
	log to console     \n #######CB012119-E Counters####
	${value_M55310C00012}    Get the latest PM Counter via admin_cli    counter_id=M55310C00012
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00012}
	${value_M55310C00013}    Get the latest PM Counter via admin_cli    counter_id=M55310C00013
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00013}
	${value_M55158C00014}    Get the latest PM Counter via admin_cli    counter_id=M55158C00014
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00014}
	${value_M55158C00015}    Get the latest PM Counter via admin_cli    counter_id=M55158C00015
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00015}

	log to console     \n #######CB012119-F Counters####
	${value_M55310C00008}    Get the latest PM Counter via admin_cli    counter_id=M55310C00008
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00008}
	${value_M55310C00009}    Get the latest PM Counter via admin_cli    counter_id=M55310C00009
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00009}
	${value_M55158C00010}    Get the latest PM Counter via admin_cli    counter_id=M55158C00010
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00010}
	${value_M55158C00011}    Get the latest PM Counter via admin_cli    counter_id=M55158C00011
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00011}

Get the latest PM Counter via admin_cli
    [Arguments]    ${counter_id}    ${dic_path}=full
   ${content}   get_pm_counter_values
    ...    counter_id=${counter_id}     dic_path=${dic_path}    connection=GNB_OAM    timeout=70
    Set test variable    ${value}    ${content}[0]
    [Return]    ${value}

Set Part-C UL KPI Calculation formula
     Initialize the kpi value to zero for UL part
     ${CB012119_E_tmp}   Run keyword if    ${value_M55310C00013}!=0   evaluate    ${value_M55310C00012}/(${value_M55310C00013}*1000)
	 Run keyword if    ${CB012119_E_tmp}!=${0} and ${CB012119_E_tmp}!=${None}     Set Suite Variable    ${CB012119_E}
	 ...   ${CB012119_E_tmp}
     ${CB012119_E_PMQAP_tmp}   Run keyword if    ${value_M55158C00015}!=0   evaluate
	 ...     ${value_M55158C00014}/(${value_M55158C00015}*1000)
	 Run keyword if    ${CB012119_E_PMQAP_tmp}!=${0} and ${CB012119_E_PMQAP_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_E_PMQAP}   ${CB012119_E_PMQAP_tmp}
     ${CB012119_F_tmp}   Run keyword if    ${value_M55310C00009}!=0   evaluate    ${value_M55310C00008}/(${value_M55310C00009}*1000)
	 Run keyword if    ${CB012119_F_tmp}!=${0} and ${CB012119_F_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_F}   ${CB012119_F_tmp}
     ${CB012119_F_PMQAP_tmp}   Run keyword if    ${value_M55158C00011}!=0
	 ...   evaluate    ${value_M55158C00010}/(${value_M55158C00011}*1000)
	 Run keyword if    ${CB012119_F_PMQAP_tmp}!=${0} and ${CB012119_F_PMQAP_tmp}!=${None}
	 ...    Set Suite Variable    ${CB012119_F_PMQAP}   ${CB012119_F_PMQAP_tmp}

Initialize the kpi value to zero for UL part
	Set Suite Variable    ${CB012119_E_tmp}    0
	Set Suite Variable    ${CB012119_E_PMQAP_tmp}    0
	Set Suite Variable    ${CB012119_F}    0
	Set Suite Variable    ${CB012119_F_PMQAP}    0

check PART-C UL kpi for 5QI-7
	should be true     0<${CB012119_F}<10
	should be true     0<${CB012119_F_PMQAP}<10


check PART-C UL kpi for 5QI-4
	should be true     0<${CB012119_F}<2
	should be true     0<${CB012119_F_PMQAP}<2

check DL kpi for 5QI-7 big traffic condition
    Log To Console    \n ### CB012119_A=2.7 CB012119_A_PMQAP=2.7
    ...      CB012119_C=2.7 CB012119_C_PMQAP=2.7
    ...      CB012119_D=4.2 CB012119_C_PMQAP=4.2
#	should be true     0<${CB012119_A}<50
#	should be true     0<${CB012119_A_PMQAP}<50
	should be true     0<${CB012119_C}<50
	should be true     0<${CB012119_C_PMQAP}<50
#	should be true     0<${CB012119_D}<50
#	should be true     0<${CB012119_D_PMQAP}<50
	should be true     0<${CB012119_H}<400
	should be true     0<${CB012119_H_PMQAP}<400
	#should be true     ${value_M55158C00006}==${value_M55158C00008}
	#should be true     ${value_M55158C00007}==${value_M55158C00009}
	#should be true     ${value_M55310C00004}==${value_M55310C00006}
	#should be true     ${value_M55310C00005}==${value_M55310C00007}

check DL kpi for 5QI-7 small traffic condition
    Log To Console    \n ### CB012119_A=4 CB012119_A_PMQAP=4
    ...      CB012119_C=4 CB012119_C_PMQAP=4
    ...      CB012119_D=4.6 CB012119_C_PMQAP=4.6
	#should be true     0<${CB012119_A}<35
	#should be true     0<${CB012119_A_PMQAP}<35
	should be true     0<${CB012119_C}<30
	should be true     0<${CB012119_C_PMQAP}<30
	should be true     0<${CB012119_D}<30
	should be true     0<${CB012119_D_PMQAP}<30
	should be true     0<${CB012119_H}<65
	should be true     0<${CB012119_H_PMQAP}<65
	#should be true     ${value_M55158C00006}==${value_M55158C00008}
	#should be true     ${value_M55158C00007}==${value_M55158C00009}
	#should be true     ${value_M55310C00004}==${value_M55310C00006}
	#should be true     ${value_M55310C00005}==${value_M55310C00007}


check DL kpi for 5QI-4 big traffic condition
    Log To Console    \n ### CB012119_A=1.5 CB012119_A_PMQAP=0
    ...      CB012119_C=1.4 CB012119_C_PMQAP=1.4
    ...      CB012119_D=2.9 CB012119_C_PMQAP=2.9
#	should be true    ${value_M55158C00006}==0
#	should be true    ${value_M55158C00007}==0
#	should be true     0<${CB012119_A}<6
	should be true     0<${CB012119_C}<30
	should be true     0<${CB012119_C_PMQAP}<30
	should be true     0<${CB012119_D}<20
	should be true     0<${CB012119_D_PMQAP}<20
	should be true     0<${CB012119_H}<10
	should be true     0<${CB012119_H_PMQAP}<10

check DL kpi for 5QI-4 small traffic condition
    Log To Console    \n ### CB012119_A=0 CB012119_A_PMQAP=0
    ...      CB012119_C=1.8 CB012119_C_PMQAP=1.8
    ...      CB012119_D=3.2 CB012119_C_PMQAP=3.2
#	should be true    ${value_M55158C00006}==0
#	should be true    ${value_M55158C00007}==0
#	should be true    ${CB012119_A}==0
#	should be true    ${CB012119_A_PMQAP}==0
	should be true     0<${CB012119_C}<40
	should be true     0<${CB012119_C_PMQAP}<40
	should be true     0<${CB012119_D}<50
	should be true     0<${CB012119_D_PMQAP}<50
	should be true     0<${CB012119_H}<10
	should be true     0<${CB012119_H_PMQAP}<10

check DL kpi for 5QI-1 VONR traffic condition
    Log To Console    \n ### CB012119_A=7.1 CB012119_A_PMQAP=0
    ...      CB012119_C=6.2 CB012119_C_PMQAP=6.2
    ...      CB012119_D=7.9 CB012119_C_PMQAP=7.9
#	should be true    ${value_M55158C00006}==0
#	should be true    ${value_M55158C00007}==0
#	should be true     3<${CB012119_A}<50
#	should be true     ${CB012119_A_PMQAP}==0
	should be true     0<${CB012119_C}<30
	should be true     0<${CB012119_C_PMQAP}<30
	should be true     0<${CB012119_D}<30
	should be true     0<${CB012119_D_PMQAP}<30
	should be true     0<${CB012119_H}<10
	should be true     0<${CB012119_H_PMQAP}<10

check DL kpi for 5QI-1 VINR traffic condition
    Log To Console    \n ### CB012119_A=1.3 CB012119_A_PMQAP=0
    ...      CB012119_C=9.3 CB012119_C_PMQAP=10.5
    ...      CB012119_D=10.9 CB012119_C_PMQAP=12.6
#	should be true    ${value_M55158C00006}==0
#	should be true    ${value_M55158C00007}==0
#	should be true     0<${CB012119_A}<50
#	should be true     ${CB012119_A_PMQAP}==0
	should be true     0<${CB012119_C}<20
	should be true     0<${CB012119_C_PMQAP}<20
	should be true     0<${CB012119_D}<30
	should be true     0<${CB012119_D_PMQAP}<35
	should be true     0<${CB012119_H}<50
	should be true     0<${CB012119_H_PMQAP}<10

check DL kpi for 5QI-5 traffic condition
    Log To Console    \n ### CB012119_A=1.3 CB012119_A_PMQAP=1.3
    ...      CB012119_C=9.3 CB012119_C_PMQAP=1.3
    ...      CB012119_D=10.9 CB012119_C_PMQAP=3
#	should be true     0<${CB012119_A}<50
	#should be true     0<${CB012119_A_PMQAP}<50
	should be true     0<${CB012119_C}<50
	#should be true     0<${CB012119_C_PMQAP}<50
	should be true     0<${CB012119_D}<50
	#should be true     0<${CB012119_D_PMQAP}<50
#	should be true     ${value_M55158C00006}==${value_M55158C00008}
#	should be true     ${value_M55158C00007}==${value_M55158C00009}
	should be true     0<${CB012119_H}<50
	#should be true     0<${CB012119_H_PMQAP}<50

check DL kpi for 5QI-2 traffic condition
    Log To Console    \n ### CB012119_A=1.3 CB012119_A_PMQAP=0
    ...      CB012119_C=9.3 CB012119_C_PMQAP=12.4
    ...      CB012119_D=10.9 CB012119_C_PMQAP=14
#	should be true    ${value_M55158C00006}==0
#	should be true    ${value_M55158C00007}==0
#	should be true     0<${CB012119_A}<5
#	should be true     ${CB012119_A_PMQAP}==0
	should be true     0<${CB012119_C}<20
	should be true     0<${CB012119_C_PMQAP}<20
	should be true     0<${CB012119_D}<30
	should be true     0<${CB012119_D_PMQAP}<30
	should be true     0<${CB012119_H}<50
	should be true     0<${CB012119_H_PMQAP}<80

check DL kpi for 5QI-8 small traffic condition
    Log To Console    \n ### CB012119_A=92 CB012119_A_PMQAP=92
    ...      CB012119_C=92 CB012119_C_PMQAP=92
    ...      CB012119_D=93 CB012119_C_PMQAP=93
#	should be true     0<${CB012119_A}<100
#	should be true     0<${CB012119_A_PMQAP}<100
	should be true     0<${CB012119_C}<100
	should be true     0<${CB012119_C_PMQAP}<100
	should be true     0<${CB012119_D}<100
	should be true     0<${CB012119_D_PMQAP}<100
	should be true     0<${CB012119_H}<100
	should be true     0<${CB012119_H_PMQAP}<100
	#should be true     ${value_M55158C00006}==${value_M55158C00008}
	#should be true     ${value_M55158C00007}==${value_M55158C00009}
	#should be true     ${value_M55310C00004}==${value_M55310C00006}
	#should be true     ${value_M55310C00005}==${value_M55310C00007}

Set PMQAP related counter path
    ${stream}    Get Stream
	Connect to Common Unit Master
	selenium login and disable screen lock    timeout=360
    ${btsname}    selenium_coam.get_bts_name
	log to console    ${MR_NR_BTS_NAME}
    Set test variable    ${pmcounter_path_based_on_release}    [${btsname}] ${MR_NR_BTS_NAME}
    #Set test variable    ${full_path_qci7_M55158C00006}
	#...     ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_AM_DLY_DU_IF_PMQAP
    #Set test variable    ${full_path_qci7_M55158C00007}
	#...    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_AM_SDU_TRANS_DU_PMQAP
    Set test variable    ${full_path_qci7_M55158C00008}
	...    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_SDU_DLY_PMQAP
    Set test variable    ${full_path_qci7_M55158C00009}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_SDU_PMQAP
    Set test variable    ${full_path_qci7_M55158C00012}
	...    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_INIT_RLC_SDU_BRST_DLY_PMQAP
    Set test variable    ${full_path_qci7_M55158C00013}
	...    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_INIT_RLC_SDU_BRST_PMQAP
   [Teardown]  Run keyword and ignore error    selenium logout and close browser


Check BTS Counter for NSA
    [Arguments]    ${interval}
	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time   interval=${interval}
#	${value_M55158C00006_qci7}    Get PM Counter via Webem for CB012119
#	...        counter_id=M55158C00006   check_time=${check_time}    full_path=${full_path_qci7_M55158C00006}
#	${value_M55158C00007_qci7}    Get PM Counter via Webem for CB012119
#	...        counter_id=M55158C00007   check_time=${check_time}    full_path=${full_path_qci7_M55158C00007}
	${value_M55158C00008_qci7}    Get PM Counter via Webem for CB012119
	...        counter_id=M55158C00008   check_time=${check_time}    full_path=${full_path_qci7_M55158C00008}
	${value_M55158C00009_qci7}    Get PM Counter via Webem for CB012119
	...        counter_id=M55158C00009   check_time=${check_time}    full_path=${full_path_qci7_M55158C00009}
	${value_M55158C00012_qci7}    Get PM Counter via Webem for CB012119
	...        counter_id=M55158C00012   check_time=${check_time}    full_path=${full_path_qci7_M55158C00012}
	${value_M55158C00013_qci7}    Get PM Counter via Webem for CB012119
	...        counter_id=M55158C00013   check_time=${check_time}    full_path=${full_path_qci7_M55158C00013}
	#${value_M55310C00004}    Get PM Counter via Webem for CB012119
	#...       counter_id=M55310C00004   check_time=${check_time}
	#${value_M55310C00005}    Get PM Counter via Webem for CB012119
	#...      counter_id=M55310C00005   check_time=${check_time}
	${value_M55310C00006}    Get PM Counter via Webem for CB012119
	...       counter_id=M55310C00006   check_time=${check_time}
	${value_M55310C00007}    Get PM Counter via Webem for CB012119
	...      counter_id=M55310C00007   check_time=${check_time}
	${value_M55310C00010}    Get PM Counter via Webem for CB012119
	...       counter_id=M55310C00010   check_time=${check_time}
	${value_M55310C00011}    Get PM Counter via Webem for CB012119
	...      counter_id=M55310C00011   check_time=${check_time}
    #Should be True      ${value_M55158C00008_qci7}*0.95<${value_M55158C00006_qci7}<${value_M55158C00008_qci7}*1.05
    #Should be True      ${value_M55158C00009_qci7}*0.95<${value_M55158C00007_qci7}<${value_M55158C00009_qci7}*1.05
    #Should be True      ${value_M55310C00004}*0.95<${value_M55158C00006_qci7}<${value_M55310C00004}*1.05
    #Should be True      ${value_M55310C00005}*0.95<${value_M55158C00007_qci7}<${value_M55310C00005}*1.05
#    Should be True      ${value_M55310C00006}*0.95<${value_M55158C00006_qci7}<${value_M55310C00006}*1.05
    #Should be True      ${value_M55310C00007}*0.95<${value_M55158C00007_qci7}<${value_M55310C00007}*1.05
    Should be True      ${value_M55310C00010}*0.95<${value_M55158C00012_qci7}<${value_M55310C00010}*1.05
    Should be True      ${value_M55310C00011}*0.95<${value_M55158C00013_qci7}<${value_M55310C00011}*1.05
    #Should be True      ${value_M55158C00006_qci7}/${value_M55158C00007_qci7}<100000
    Should be True      ${value_M55158C00012_qci7}/${value_M55158C00013_qci7}<100000
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

CB012119 NSA case Preparation
    [Arguments]    ${list_cell_group_index}
    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}.xml
	...    is_pdl_checking_needed=${False}    timeout=600s
	Wait until cluster is on cell on air status    list_cell_group_index=${list_cell_group_index}
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
#   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
    sleep    300s
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections


Get PM Counter via Webem for CB012119
    [Arguments]    ${counter_id}   ${check_time}    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB012119   counter_id=${counter_id}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    ${value}    get_from_dictionary   ${content}    ${check_time}
    [Return]    ${value}

Get PM Counter content via Webem for CB012119
    [Arguments]    ${counter_id}     ${counter_type}=BTS      ${full_path}=${None}
    ${content}    run keyword if    '${counter_type}'=='BTS'    selenium_coam.get_bts_counters_info
    ...    counter_id=${counter_id}      full_path=${full_path}
    ...    ELSE    selenium_coam.get_transport_counters
    ...    counter_id=${counter_id}    timeout_for_loading_available_counters=15
    [Return]     ${content}

Get Stream
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
	set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    [Return]       ${stream}

Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR  ${port_num}    IN RANGE    0    5
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Adjust HBTE ATT Values for TL2090
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    ...    model=${model}
    FOR  ${port_num}    IN RANGE    0    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END
Testcase specific teardown
   Run Keyword If Test Failed   Test Case teardown in case failure
   robot_common_operations.Common Case Setup
   CI_interface.Common Case Teardown
   Detach UE