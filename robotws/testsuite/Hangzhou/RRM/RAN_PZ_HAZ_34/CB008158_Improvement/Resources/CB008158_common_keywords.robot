*** Settings ***
Documentation
...    author: tina.luo
...    contact:tina.luo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008158

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
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Variables   CB008158_scf_modify.py


*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${num_of_files}   20
#${UE_TYPE}    ${tl.ues[${ue_index}].capabilities[1]}
${ui_version}    Mi12UI13.0.41


${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${NR_5906a}    0
${NR_5907a}    0
${NR_5908a}    0
${NR_5909a}    0
${NR_59010a}    0
${NR_59011a}    0
${NR_2330a}    0
${NR_2331a}    0
${NR_2332a}    0
${NR_2334a}    0
${NR_2335a}    0
${NR_2336a}     0
${NR_6094a}     0
${NR_6095a}     0
${NR_6097a}     0
${NR_6098a}     0
${NR_6099a}     0

*** Keywords ***

CB008158 SA case Preparation

    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}.xml
	...    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections
CB008158 case recover to golden SCF

    COAM Create log directory
	Connect to gnb coam via ssl
	${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/SCF_${stream}_Golden.xml
	...    timeout=600s
   [Teardown]    COAM Teardown gnb connections

CB008158 NSA case Preparation

    COAM Create log directory
	Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file_template_path}/${scf_name}
	...    timeout=600s
   	Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=GNB_OAM
    Run Keyword And Ignore Error    ssh.force_reconnect    connection=ASIK Master
   [Teardown]    COAM Teardown gnb connections


Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
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
	set test variable    ${UE_TYPE}    ${tl.ues[${ue_index}].capabilities[1]}
    #Andriod UE adb reboot    ue_index=${ue_index}
    sleep    20s
    Log To Console    \n ### Prepare UE for UE_${ue_index}###
	Run keyword if    '${UE_TYPE}'=='samsung'    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}
	Run keyword if    '${UE_TYPE}'=='xiaomi'     UE Prepare for xiaomi    ue_index=${ue_index}
	Run keyword if    '${UE_TYPE}'=='qct_dx50'    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${ue_index}

UE Prepare for xiaomi
    [Arguments]    ${ue_index}=${0}
    Log To Console    \n ### Prepare UE ###
	power_ue.Prepare UE    ue_type=${UE_TYPE}  ui_version=${ui_version}    ue_index=${ue_index}

Attach UE
    [Arguments]    ${ue_index}=${0}
	set test variable    ${UE_TYPE}    ${tl.ues[${ue_index}].capabilities[1]}
    Log To Console    \n ### UE Attach for UE_${ue_index} ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}   ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    ...           ${iperf_port_dl}=50227    ${iperf_port_ul}=43107    ${ue_index}=${0}
	set test variable    ${UE_TYPE}    ${tl.ues[${ue_index}].capabilities[1]}
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
	set test variable    ${UE_TYPE}    ${tl.ues[${ue_index}].capabilities[1]}
    Run Keyword And Ignore Error    UE stop traffic    ue_index=${ue_index}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${UE_TYPE}

UE stop traffic
    [Arguments]    ${tp_direction}=both
	set test variable    ${UE_TYPE}    ${tl.ues[${ue_index}].capabilities[1]}
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
    ${content}    Get PM Counter content via Webem for CB008158   counter_id=${counter_id}
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
    sleep   5s
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



Get PM Counter content via Webem for CB008158
    [Arguments]    ${counter_id}     ${dist_name}=${None}    ${counter_type}=BTS      ${full_path}=${None}
    ${content}    run keyword if    '${counter_type}'=='BTS'    selenium_coam.get_bts_counters_info
    ...    counter_id=${counter_id}     dist_name=${dist_name}    full_path=${full_path}
    ...    ELSE    selenium_coam.get_transport_counters
    ...    counter_id=${counter_id}    timeout_for_loading_available_counters=15
    [Return]     ${content}

Get PM Counter via Webem for CB008158
    [Arguments]    ${counter_id}    ${check_time}     ${dist_name}=${None}    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB008158   counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}

    ${value}    get_from_dictionary   ${content}    ${check_time}
    [Return]    ${value}




Set DL KPI Calculation formula
     Initialize the kpi value to zero
     ${NR_5906a_tmp}   Run keyword if    ${value_M55310C00003}!=0   evaluate    ${value_M55310C00002}/(${value_M55310C00003}*1000)
	 Run keyword if    ${NR_5906a_tmp}!=${0} and ${NR_5906a_tmp}!=${None}     Set Suite Variable    ${NR_5906a}   ${NR_5906a_tmp}
     ${NR_5907a_tmp}   Run keyword if    ${value_M55350C00024}!=0     evaluate    ${value_M55350C00023}/(${value_M55350C00024}*1000)
	 Run keyword if    ${NR_5907a_tmp}!=0 and ${NR_5907a_tmp}!=None      Set Suite Variable    ${NR_5907a}   ${NR_5907a_tmp}
     ${NR_5909a_tmp}   Run keyword if    ${value_M55308C00058}!=0    evaluate    ${value_M55308C00057}/(${value_M55308C00058}*1000)
	 Run keyword if    ${NR_5909a_tmp}!=0 and ${NR_5909a_tmp}!=None      Set Suite Variable    ${NR_5909a}   ${NR_5909a_tmp}
     ${NR_59010a_tmp}   Run keyword if    ${value_M55308C00061}!=0    evaluate    ${value_M55308C00060}/(${value_M55308C00061}*1000)
	 Run keyword if    ${NR_59010a_tmp}!=0 and ${NR_59010a_tmp}!=None     Set Suite Variable    ${NR_59010a}   ${NR_59010a_tmp}
     ${NR_59011a_tmp}   Run keyword if    ${value_M55350C00030}!=0    evaluate    ${value_M55350C00029}/(${value_M55350C00030}*1000)
	 Run keyword if    ${NR_59011a_tmp}!=0 and ${NR_59011a_tmp}!=None     Set Suite Variable    ${NR_59011a}   ${NR_59011a_tmp}
     ${NR_2330a_tmp}    Run keyword if     ${value_M55158C00002}!=0     evaluate    ${value_M55158C00001}/(${value_M55158C00002}*1000)
	 Run keyword if    ${NR_2330a_tmp}!=0 and ${NR_2330a_tmp}!=None      Set Suite Variable    ${NR_2330a}   ${NR_2330a_tmp}
     ${NR_2331a_tmp}    Run keyword if    ${value_M55158C00002}!=0      evaluate    100*${value_M55158C00003}/${value_M55158C00002}
	 Run keyword if    ${NR_2331a_tmp}!=0 and ${NR_2331a_tmp}!=None     Set Suite Variable    ${NR_2331a}   ${NR_2331a_tmp}
     ${NR_2332a_tmp}    Run keyword if    ${value_M55159C00002}!=0      evaluate    ${value_M55159C00001}/(${value_M55159C00002}*1000)
	 Run keyword if    ${NR_2332a_tmp}!=0 and ${NR_2332a_tmp}!=None     Set Suite Variable    ${NR_2332a}   ${NR_2332a_tmp}
     ${NR_2334a_tmp}     Run keyword if    ${value_M55356C00006}!=0     evaluate    ${value_M55356C00004}/(1000*${value_M55356C00006})
	 Run keyword if    ${NR_2334a_tmp}!=0 and ${NR_2334a_tmp}!=None     Set Suite Variable    ${NR_2334a}   ${NR_2334a_tmp}
     ${NR_2335a_tmp}     Run keyword if    ${value_M55356C00007}!=0     evaluate    ${value_M55356C00005}/(1000*${value_M55356C00007})
	 Run keyword if    ${NR_2335a_tmp}!=0 and ${NR_2335a_tmp}!=None      Set Suite Variable    ${NR_2335a}   ${NR_2335a_tmp}
     ${NR_2336a_tmp}     Run keyword if     ${value_M55159C00008}!=0     evaluate    ${value_M55159C00007}/(1000*${value_M55159C00008})
	 Run keyword if    ${NR_2336a_tmp}!=0 and ${NR_2336a_tmp}!=None     Set Suite Variable    ${NR_2336a}   ${NR_2336a_tmp}
     log to console    NR_5906a=${NR_5906a},NR_5907a=${NR_5907a} ,NR_5909a=${NR_5909a},NR_59010a=${NR_59010a},NR_59011a=${NR_59011a}
	 log to console    NR_2330a=${NR_2330a},NR_2332a=${NR_2332a}, NR_2334a=${NR_2334a},NR_2335a=${NR_2335a},NR_2336a=${NR_2336a},NR_2331a=${NR_2331a}


Get VoNR and ViNR pointer variable with SamsungS21

    Set Suite Variable    ${answer_ViNR_button}    296 2038
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    435 1405
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

Initialize the kpi value to zero
    Set Suite Variable    ${NR_5906a}    0
    Set Suite Variable    ${NR_5907a}    0
    Set Suite Variable    ${NR_5908a}    0
    Set Suite Variable    ${NR_5909a}    0
    Set Suite Variable    ${NR_59010a}    0
    Set Suite Variable    ${NR_59011a}    0
    Set Suite Variable    ${NR_2330a}    0
    Set Suite Variable    ${NR_2331a}    0
    Set Suite Variable    ${NR_2332a}    0
    Set Suite Variable    ${NR_2334a}    0
    Set Suite Variable    ${NR_2335a}    0
    Set Suite Variable    ${NR_2336a}     0
    Set Suite Variable    ${NR_6094a}     0
    Set Suite Variable    ${NR_6095a}     0
    Set Suite Variable    ${NR_6097a}     0
    Set Suite Variable    ${NR_6098a}     0
    Set Suite Variable    ${NR_6099a}     0
Get the latest PM Counter via admin_cli for CB008158
    [Arguments]    ${counter_id}    ${dic_path}=full

   ${content}   get_pm_counter_values
    ...    counter_id=${counter_id}     dic_path=${dic_path}    connection=GNB_OAM    timeout=70
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
	log to console     \n #######CB008185-A Counters####
	${value_M55310C00002}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00002}
	${value_M55310C00003}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00003
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00003}
 	${value_M55158C00001}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55158C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00001}
	${value_M55158C00002}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55158C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00002}
	${value_M55158C00003}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55158C00003
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00003}
	log to console      \n ########CB008158-B Counters####
	${value_M55350C00023}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00023
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00023}
	${value_M55350C00024}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00024
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00024}
	${value_M55159C00001}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00001}
	${value_M55159C00002}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
		Set Suite variable    ${value_M55159C00002}
	${value_M55350C00025}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00025
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
		Set Suite variable    ${value_M55350C00025}
	${value_M55159C00003}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00003
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00003}
	log to console      \n #######CB008158-D Counters####
	${value_M55308C00057}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00057
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00057}
	${value_M55308C00058}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00058
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00058}
	${value_M55356C00004}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55356C00004
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/UESPQ
	Set Suite variable    ${value_M55356C00004}
	${value_M55356C00006}    Get the latest PM Counter via admin_cli for CB008158   counter_id=M55356C00006
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/UESPQ
	Set Suite variable    ${value_M55356C00006}
	${value_M55308C00060}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00060
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00060}
	${value_M55308C00061}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00061
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00061}
	${value_M55356C00005}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55356C00005
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/UESPQ
	Set Suite variable    ${value_M55356C00005}
	${value_M55356C00007}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55356C00007
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/UESPQ
	Set Suite variable    ${value_M55356C00007}
	${value_M55350C00029}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00029
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00029}
	${value_M55350C00030}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00030
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00030}
	${value_M55159C00007}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00007
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00007}
	${value_M55159C00008}   Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00008
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00008}
	[Teardown]

Get Part-C UL counter value for the Corresponding 5QI via admin_cli
    [Arguments]    ${5QI_ID}=1
    Log To Console    Counter is not updated so quickly wait for more than 30s
	sleep    30s
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	run keyword if    '${stream}'=='SBTS24R1'    set test variable   ${MR_NR_CELL_NAME}    CELLS/NRCELL-1
	log to console     \n #######CB008185-C Counters####
	${value_M55350C00027}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00027
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00027}
	${value_M55350C00028}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55350C00028
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00028}
	${value_M55159C00005}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00005
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00005}
	${value_M55159C00006}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55159C00006
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/PDLTQ
	Set Suite variable    ${value_M55159C00006}

Get Part-E UL counter value for the Corresponding 5QI via admin_cli
    [Arguments]    ${5QI_ID}=1
    Log To Console    Counter is not updated so quickly wait for more than 30s
	sleep    30s
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	run keyword if    '${stream}'=='SBTS24R1'    set test variable   ${MR_NR_CELL_NAME}    CELLS/NRCELL-1
	log to console     \n #######CB008185-E Counters####
		${value_M55349C00021}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55349C00021
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NHRRC
	Set Suite variable    ${value_M55349C00021}
	${value_M55158C00005}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55158C00005
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-${5QI_ID}/HRLTQ
	Set Suite variable    ${value_M55158C00005}

	${value_M55308C00080}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00080
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00080}
	${value_M55308C00071}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00071
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00071}

	${value_M55308C00063}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00063
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00063}

	${value_M55308C00064}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00064
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00064}

	${value_M55308C00065}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00065
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00065}

	${value_M55308C00066}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00066
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00066}

	${value_M55308C00067}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00067
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00067}
	${value_M55308C00068}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00068
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00068}

	${value_M55308C00069}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00069
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00069}
	${value_M55308C00070}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00070
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00070}
	${value_M55308C00072}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00072
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00072}
	${value_M55308C00073}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00073
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00073}
	${value_M55308C00074}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00074
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00074}
	${value_M55308C00075}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00075
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00075}
	${value_M55308C00076}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00076
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00076}
	${value_M55308C00077}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00077
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00077}

	${value_M55308C00078}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00078
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00078}
	${value_M55308C00079}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55308C00079
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NCELA
	Set Suite variable    ${value_M55308C00079}

Initialize the kpi value to zero for UL part
	Set Suite Variable    ${NR_5908a}    0       ###
	Set Suite Variable    ${NR_5912a}    0       ###
	Set Suite Variable    ${NR_5913a}    0       ###
	Set Suite Variable    ${NR_2337a}    0       ###
	Set Suite Variable    ${NR_2333a}    0       ###

Set Part-C UL KPI Calculation formula
     Initialize the kpi value to zero for UL part
     ${NR_5908a_tmp}   Run keyword if    ${value_M55350C00028}!=0   evaluate    ${value_M55350C00027}/(${value_M55350C00028}*1000)
	 Run keyword if    ${NR_5908a_tmp}!=${0} and ${NR_5908a_tmp}!=${None}     Set Suite Variable    ${NR_5908a}   ${NR_5908a_tmp}

     ${NR_2333a_tmp}   Run keyword if    ${value_M55159C00006}!=0   evaluate    ${value_M55159C00005}/(${value_M55159C00006}*1000)
	 Run keyword if    ${NR_2333a_tmp}!=${0} and ${NR_2333a_tmp}!=${None}     Set Suite Variable    ${NR_2333a}   ${NR_2333a_tmp}



Set Part-E UL KPI Calculation formula
     Initialize the kpi value to zero for UL part
     ${NR_5912a_tmp}   Run keyword if    ${value_M55308C00071}!=0     evaluate    ${value_M55308C00080}/(${value_M55308C00071}*1000)
	 Run keyword if    ${NR_5912a_tmp}!=0 and ${NR_5912a_tmp}!=None      Set Suite Variable    ${NR_5912a}   ${NR_5912a_tmp}
	${sum_MAC_contention_delay_1}   evaluate    ${value_M55308C00063}+${value_M55308C00064}+${value_M55308C00065}+${value_M55308C00066}
	${sum_MAC_contention_delay_2}   evaluate    ${value_M55308C00067}+${value_M55308C00068}+${value_M55308C00069}+${value_M55308C00070}
	${sum_MAC_contention_delay}     evaluate      ${sum_MAC_contention_delay_1}+${sum_MAC_contention_delay_2}
	${sum_MAC_contention_SR_number_1}     evaluate    ${value_M55308C00072}+${value_M55308C00073}+${value_M55308C00074}+${value_M55308C00075}
 	${sum_MAC_contention_SR_number_2}     evaluate    ${value_M55308C00076}+${value_M55308C00077}+${value_M55308C00078} +${value_M55308C00079}
    ${sum_MAC_contention_SR_number}     evaluate     ${sum_MAC_contention_SR_number_1}+${sum_MAC_contention_SR_number_2}
     ${NR_5913a_tmp}   Run keyword if    ${sum_MAC_contention_SR_number}!=0     evaluate
	 ...    ${sum_MAC_contention_delay}/(${sum_MAC_contention_SR_number}*1000)
	 Run keyword if    ${NR_5913a_tmp}!=0 and ${NR_5913a_tmp}!=None      Set Suite Variable    ${NR_5913a}   ${NR_5913a_tmp}
	${NR_2337a_tmp}    evaluate    100*${value_M55349c00021}/(${value_M55308C00071}+${sum_MAC_contention_SR_number})
	 Run keyword if    ${NR_2337a_tmp}!=0 and ${NR_2337a_tmp}!=None      Set Suite Variable    ${NR_2337a}   ${NR_2337a_tmp}

Test Case teardown in case failure
     Connect to gnb coam via ssl
     COAM Save Snapshot Via Rest Api    log_path=${LOG_PATH}    timeout=600s
Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
    #[Arguments]    ${5QI_ID}=1
    Log To Console    Counter is not updated so quickly wait for more than 30s
	sleep    30s
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	run keyword if    '${stream}'=='SBTS24R1'    set test variable   ${MR_NR_CELL_NAME}    CELLS/NRCELL-1
	log to console     \n #######CB012119 Counters####
	${value_M55310C00012}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00012
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00012}
	${value_M55310C00013}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00013
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00013}
	${value_M55310C00014}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00014
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00014}
	${value_M55310C00015}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00015
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00015}
	${value_M55310C00006}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00006
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00006}
	${value_M55310C00007}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00007
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00007}
	${value_M55310C00008}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00008
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00008}
	${value_M55310C00009}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00009
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00009}
	${value_M55310C00011}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00011
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00011}
	${value_M55310C00010}    Get the latest PM Counter via admin_cli for CB008158    counter_id=M55310C00010
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NLRLC
	Set Suite variable    ${value_M55310C00010}
Set CB012119 KPI Calculation formula

     ${NR_6094a_tmp}   Run keyword if    ${value_M55310C00013}!=0   evaluate    ${value_M55310C00012}/(${value_M55310C00013}*1000)
	 Run keyword if    ${NR_6094a_tmp}!=${0} and ${NR_6094a_tmp}!=${None}     Set Suite Variable    ${NR_6094a}   ${NR_6094a_tmp}
     ${NR_6095a_tmp}   Run keyword if    ${value_M55310C00015}!=0   evaluate    ${value_M55310C00014}/(${value_M55310C00015}*1000)
	 Run keyword if    ${NR_6095a_tmp}!=${0} and ${NR_6095a_tmp}!=${None}     Set Suite Variable    ${NR_6095a}   ${NR_6095a_tmp}
     ${NR_6096a_tmp}   Run keyword if    ${value_M55310C00007}!=0   evaluate    ${value_M55310C00006}/(${value_M55310C00007}*1000)
	 Run keyword if    ${NR_6096a_tmp}!=${0} and ${NR_6096a_tmp}!=${None}     Set Suite Variable    ${NR_6096a}   ${NR_6096a_tmp}
     ${NR_6098a_tmp}   Run keyword if    ${value_M55310C00011}!=0   evaluate    ${value_M55310C00010}/(${value_M55310C00011}*1000)
	 Run keyword if    ${NR_6098a_tmp}!=${0} and ${NR_6098a_tmp}!=${None}     Set Suite Variable    ${NR_6098a}   ${NR_6098a_tmp}
     ${NR_6099a_tmp}   Run keyword if    ${value_M55310C00009}!=0   evaluate    ${value_M55310C00008}/(${value_M55310C00009}*1000)
	 Run keyword if    ${NR_6099a_tmp}!=${0} and ${NR_6099a_tmp}!=${None}     Set Suite Variable    ${NR_6099a}   ${NR_6099a_tmp}
     log to console    NR_6094a=${NR_6094a},NR_6095a=${NR_6095a} ,NR_6096a=${NR_6096a},NR_6098a=${NR_6098a},NR_6099a=${NR_6099a}


