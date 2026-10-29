*** Settings ***
Documentation
...    author: tina.luo
...    contact:tina.luo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB006457

Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library     taf.hw.rf_attenuator    WITH NAME    att
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Variables   CB006457_scf_modify.py

*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${num_of_files}   20
${UE_TYPE}    ${tl.ues[-1].capabilities[1]}

*** Keywords ***
ADD PMQAP MO on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    log to console    \n*** ADD PMQAP MO on gnb***	
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several MOs via rest api     objects_to_add_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Delete All PMQAP MO online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}
    log to console    \n*** Delete All PMQAP MO online***	
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    FOR   ${i}   IN RANGE   ${num_of_files}
        Run Keyword And Ignore Error    COAM delete objects via rest api
        ...       objects_to_delete_via_api=${PARAMETERS_TO_CB006457_pmqap_delete_${i}}    timeout=${timeout}
    END
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Reset site NSA
    [Arguments]      ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.reset_site    timeout=360    connection=GNB_OAM
    Wait until cluster is on cell on air status    list_cell_group_index=0
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Reset site SA
    [Arguments]      ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.reset_site    timeout=360    connection=GNB_OAM
    Wait until cluster is on cell on air status    list_cell_group_index=1
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

CB006457 NSA case Preparation
    [Arguments]    ${gnb_index}=0
    log to console    \n*** CB006457 Case Preparation***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
    ...    scf_parameters_list=${PARAMETERS_TO_CB006457_NSA_enable}
    &{result}    coam.perform_commissioning    scf_file=${output_scf_file_path}
    ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
    Wait until cluster is on cell on air status    list_cell_group_index=0
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    Delete All PMQAP MO online
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB006457_pmqap_add_1}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB006457_pmqap_add_2}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB006457_actNrpmqapProfiles_enable}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

CB006457 SA case Preparation
    [Arguments]    ${gnb_index}=0
    log to console    \n*** CB006457 Case Preparation***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path SA    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
    ...    scf_parameters_list=${PARAMETERS_TO_CB006457_SA_enable}
    &{result}    coam.perform_commissioning    scf_file=${output_scf_file_path}
    ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
    Wait until cluster is on cell on air status    list_cell_group_index=1
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    Delete All PMQAP MO online
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB006457_pmqap_add_SA_1}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB006457_pmqap_add_SA_2}
    ADD PMQAP MO on gnb    parameters_to_update=${PARAMETERS_TO_CB006457_pmqap_add_SA_4}
    Modify NIDD parameter on gnb   parameters_to_update=${PARAMETERS_TO_CB006457_actNrpmqapProfiles_enable}	
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Get Golden SCF Path SA
    [Arguments]    ${gnb_index}=${0}
    ${stream}    get stream from version    ${Active_SW_version}
    ${ute_env}    run keyword and return status    run keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${testline}   run keyword if    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    set variable     ${testline_name}
    ${gnb_type}    set variable     ${tl.gnbs[${gnb_index}].__class__.__name__}
    ${Golden_SCF_Path}    Get SCF File Path SA     testline=${testline}    stream=${stream}
    ...    gnb_type=${gnb_type}    gnb_index=${gnb_index}
    [Return]   ${Golden_SCF_Path}

Get SCF File Path SA
    [Arguments]    ${testline}    ${stream}    ${gnb_type}=ClassicalBts    ${cu_or_du}=DU    ${gnb_index}=0
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB006457/Resources
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    ${gnb_ext_index}    evaluate    ${gnb_index}+1
    ${gnb_ext}    set variable if    ${gnb_index}==0    ${EMPTY}    _gnb${gnb_ext_index}
    ${path}    run keyword if   '${gnb_type}'=='ClassicalBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}.xml
    ...    ELSE IF      '${gnb_type}'=='CloudBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}_${cu_or_du}.xml
    OperatingSystem.File Should Exist    ${path}
    log to console   ${SPACE*2}scf path: ${path}.
    [Return]    ${path}

Get wait value minutes
    [Arguments]    ${interval}=5min
    Connect to Common Unit Master
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from GNB
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
	#set test variable    ${wait_time}
    [Return]    ${wait_time}

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}

Get ul and dl peak and ave throughput and return result
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
    ...    du_index=${du_index}
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log for TRUNK
    ...    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb
    ...    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}
    ...    ${ul_average_tp}    ${ul_minimum_tp}
    [teardown]    Run Keyword and Ignore Error    admin_cli.teardown    connection=COAM

Wait for one counter period
    [Arguments]    ${interval_time}=5min
	${wait_time}    Get wait value minutes    interval=${interval_time}
	log to console      .....wait ${wait_time}mins....
    sleep    ${wait_time}min
    #log to console      .....wait 5mins....
    #sleep    ${interval_time}
    sleep    50s	

Get PM Counter via Webem for CB006457
    [Arguments]    ${counter_id}    ${interval}   ${check_time}    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB006457   counter_id=${counter_id}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
#    sort list    ${time_list}
#    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
#    ${current_time}   get time from gnb
#    ${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
#    ${diff}    robot.libraries.DateTime.subtract_date_from_date    ${current_time}     ${end_time}
#    ${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
#    should be true    ${diff1}<30
    ${value}    get_from_dictionary   ${content}    ${check_time}
    [Return]    ${value}

Get PM Counter time
    [Arguments]   ${interval}   ${counter_id}=M55350C00027    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB006457   counter_id=${counter_id}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    [Return]    ${last_time}

Get PM Counter content via Webem for CB006457
    [Arguments]    ${counter_id}     ${counter_type}=BTS      ${full_path}=${None}
    ${content}    run keyword if    '${counter_type}'=='BTS'    selenium_coam.get_bts_counters_info
    ...    counter_id=${counter_id}      full_path=${full_path}
    ...    ELSE    selenium_coam.get_transport_counters
    ...    counter_id=${counter_id}    timeout_for_loading_available_counters=15
    [Return]     ${content}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}   # ${phone_number}=18001006209
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
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    20s

Check BTS Counter M55352C01002 and M55352C01003 for multi nonGBR
    [Arguments]    ${ratio}=1.5    ${interval}=5min
    log to console    \n*** Check BTS Counter M55352C01002 and M55352C01003 for multi nonGBR***	
    ${ratio}    Convert To Float    string=${ratio}	
	Connect to Common Unit Master
	selenium login and disable screen lock    download_dir=/tmp
	${check_time}    Get PM Counter time   interval=${interval}
	${value_M55352C01002_5qi7}    Get PM Counter via Webem for CB006457
	...        counter_id=M55352C01002    interval=${interval}   check_time=${check_time}    full_path=${full_path_5qi7_M55352C01002}
	${value_M55352C01003_5qi7}    Get PM Counter via Webem for CB006457
	...        counter_id=M55352C01003    interval=${interval}   check_time=${check_time}   full_path=${full_path_5qi7_M55352C01003}
    Should be True      ${value_M55352C01002_5qi7}>0
    Should be True      ${value_M55352C01003_5qi7}>0
    Run keyword and ignore error    Should be True      ${value_M55352C01002_5qi7}/${value_M55352C01003_5qi7}>0
	${value_M55352C01002_5qi8}    Get PM Counter via Webem for CB006457
	...        counter_id=M55352C01002    interval=${interval}   check_time=${check_time}    full_path=${full_path_5qi8_M55352C01002}
	${value_M55352C01003_5qi8}    Get PM Counter via Webem for CB006457
	...        counter_id=M55352C01003    interval=${interval}   check_time=${check_time}    full_path=${full_path_5qi8_M55352C01003}
    Should be True    ${value_M55352C01002_5qi8}>0
    Should be True    ${value_M55352C01003_5qi8}>0
    Should be True    ${value_M55352C01002_5qi8}/${value_M55352C01003_5qi8}> 0
    Should be True    ${value_M55352C01002_5qi8}/${value_M55352C01003_5qi8}> ${ratio}* 0.85 * ${value_M55352C01002_5qi7}/${value_M55352C01003_5qi7}
    Should be True    ${value_M55352C01002_5qi8}/${value_M55352C01003_5qi8}< ${ratio}* 1.15 * ${value_M55352C01002_5qi7}/${value_M55352C01003_5qi7}
    Should be True    ${value_M55352C01002_5qi8}/${value_M55352C01003_5qi8}> ${ratio}* 0.85 * ${value_M55352C01002_5qi7}/${value_M55352C01003_5qi7}
    Should be True    ${value_M55352C01002_5qi8}/${value_M55352C01003_5qi8}< ${ratio}* 1.15 * ${value_M55352C01002_5qi7}/${value_M55352C01003_5qi7}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check BTS Counter M55352C01002 and M55352C01003 for GBR4
    [Arguments]    ${ratio}=1.5    ${interval}=5min
    log to console    \n*** Check BTS Counter M55352C01002 and M55352C01003 for GBR4***	
	Connect to Common Unit Master
	selenium login and disable screen lock    download_dir=/tmp
	${check_time}    Get PM Counter time   interval=${interval}
	${value_M55352C01002_5qi4}    Get PM Counter via Webem for CB006457
	...        counter_id=M55352C01002    interval=${interval}   check_time=${check_time}    full_path=${full_path_5qi4_M55352C01002}
	${value_M55352C01003_5qi4}    Get PM Counter via Webem for CB006457
	...        counter_id=M55352C01003    interval=${interval}   check_time=${check_time}   full_path=${full_path_5qi4_M55352C01003}
    Should be True      ${value_M55352C01002_5qi4}>0
    Should be True      ${value_M55352C01003_5qi4}>0
    Should be True      ${value_M55352C01002_5qi4}/${value_M55352C01003_5qi4}> 30*0.9
    Should be True      ${value_M55352C01002_5qi4}/${value_M55352C01003_5qi4}< 30*1.1
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Get Stream
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    [Return]       ${stream}
    [Teardown]      Run keyword and ignore error    COAM Teardown gnb connections

Set PMQAP related counter path for multi nonGBR
    log to console    \n*** Set PMQAP related counter path for multi nonGBR***
    ${stream}    Get Stream
	Connect to Common Unit Master
	selenium login and disable screen lock    download_dir=/tmp
    ${btsname}    selenium_coam.get_bts_name
	log to console    ${MR_NR_BTS_NAME} 
	Run keyword If     '${stream}'=='SBTS00'    Set test variable    ${pmcounter_path_based_on_release}    [${btsname}] ${MR_NR_BTS_NAME} 
	Run keyword If     '${stream}'=='SBTS24R1'    Set test variable    ${pmcounter_path_based_on_release}    CELLS
    Set test variable	 ${full_path_5qi7_M55352C01002}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDCPQ/DL_PDCP_VOL_UE_TPUT_5G_PMQAP
    Set test variable    ${full_path_5qi7_M55352C01003}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDCPQ/DL_PDCP_TIME_UE_TPUT_5G_PMQAP
    Set test variable	 ${full_path_5qi8_M55352C01002}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/PDCPQ/DL_PDCP_VOL_UE_TPUT_5G_PMQAP
    Set test variable    ${full_path_5qi8_M55352C01003}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/PDCPQ/DL_PDCP_TIME_UE_TPUT_5G_PMQAP
    [Teardown]  Run keyword and ignore error    selenium logout and close browser
	
Set PMQAP related counter path for GBR4
    log to console    \n*** Set PMQAP related counter path for GBR4***
    ${stream}    Get Stream
    Connect to Common Unit Master
    selenium login and disable screen lock    download_dir=/tmp
    ${btsname}    selenium_coam.get_bts_name
    log to console    ${MR_NR_BTS_NAME} 
    Run keyword If     '${stream}'=='SBTS00'    Set test variable    ${pmcounter_path_based_on_release}    [${btsname}] ${MR_NR_BTS_NAME} 
    Run keyword If     '${stream}'=='SBTS24R1'    Set test variable    ${pmcounter_path_based_on_release}    CELLS
    Set test variable	 ${full_path_5qi4_M55352C01002}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDCPQ/DL_PDCP_VOL_UE_TPUT_5G_PMQAP
    Set test variable    ${full_path_5qi4_M55352C01003}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDCPQ/DL_PDCP_TIME_UE_TPUT_5G_PMQAP
    [Teardown]  Run keyword and ignore error    selenium logout and close browser
	
Convert To Float
    [Arguments]    ${string}
    ${float_ratio}    Evaluate    float(${string})    modules=builtins
    [Return]    ${float_ratio}
	
Stop traffic for NSA multi port and detach UE
    Run Keyword And Ignore Error    UE stop traffic    tp_direction=dl    iperf_port_dl=50217
    Run Keyword And Ignore Error    UE stop traffic    tp_direction=dl    iperf_port_dl=50218
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Stop traffic for SA multi port and detach UE
    Run Keyword And Ignore Error    UE stop traffic    tp_direction=dl    iperf_port_dl=50227
    Run Keyword And Ignore Error    UE stop traffic    tp_direction=dl    iperf_port_dl=50228
    Run Keyword And Ignore Error    UE stop traffic    tp_direction=dl    iperf_port_dl=50224
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}	

Online modify parameters "schedulingWeightSF" for first arp 
    [Arguments]       ${new_value}
	log to console    Online modify parameters "schedulingWeightSF" for first arp
    selenium login and disable screen lock    download_dir=/tmp
	selenium_coam.set_parameter_value
	...    dist_name=${MR_NR_BTS_NAME}    filter_param=Scaling factor for scheduling weight    new_value=${new_value}
	selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
	[Teardown]  Run keyword and ignore error    selenium logout and close browser	
	
UE start traffic for period
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M   ${appserver}=10.57.162.3
    ...           ${iperf_port_dl}=50227    ${iperf_port_ul}=43107    ${duration}=900000
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=${duration}    ue_type=${ue_type}    buffer_size=1400B
    ...     appserver=${appserver}        iperf_port=${iperf_port_dl}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_type=${ue_type}    iperf_type=via_command
    ...    appserver=${appserver}        iperf_port=${iperf_port_ul}

Test suite prepare
    Get Stream and SW full version for mcshark
    Download MCShark To UTE	
	
Online modify parameters "schedulWeight" of DRB
    [Arguments]    ${DRB_dist}       ${new_value}
    Log To Console    Online modify parameters "schedulWeight" of DRB
    selenium login and disable screen lock    download_dir=/tmp
	selenium_coam.set_parameter_value
	...    dist_name=${DRB_dist}    filter_param=Scheduling weight   new_value=${new_value}
	selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
	[Teardown]  Run keyword and ignore error    selenium logout and close browser
	
Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   vendor=${vendor}    model=${model}
    FOR  ${port_num}    IN RANGE    4    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Get the schedulWeight of multi DRB 
    [Arguments]    ${pcap_file}=${EXECDIR}/${pcap_log_name}   ${expected_value}=80    
	...    ${display_filter$}=itf_l2_ps_user_bearersetupreq || itf_l2_ps_user_usersetupreq
    ...    ${field_name}=itf_l2_ps_DrbAddReqPs.schedulWeight
    Log To Console    Get the schedulWeight of multi DRB
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${output_weight}	  csn.Execute
    ...    command=tshark -r "${pcap_file}" -Y "${display_filter$}" -T fields -e ${field_name}    connection=ute
	${output_weight1}    set variable    ${output_weight.strip()}
	${output_weight2}=     replace string    ${output_weight1}    \r\n    ,
	${output_schedulWeight}    Split String From Right   ${output_weight2}  separator=,
    ${output_qosId_tmp}	  csn.Execute
    ...    command=tshark -r "${pcap_file}" -Y "${display_filter$}" -T fields -e itf_l2_ps_DrbAddReqPs.qosId    connection=ute
	${output_qosId_tmp}    set variable    ${output_qosId_tmp.strip()}
	${output_qosId_tmp}=     replace string    ${output_qosId_tmp}    \r\n    ,
	${output_qosId}    Split String From Right   ${output_qosId_tmp}  separator=,
	[return]    ${output_qosId}    ${output_schedulWeight}
	[teardown]  csn.disconnect    connection=ute

Check the scheduleight of multi DRB as expected
    [Arguments]    ${qos}   ${schedulWeight}    ${expected_weight}
    Log To Console    Check the scheduleight of multi DRB as expected
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${lenght_schedulWeight}=   get length   ${schedulWeight}
    ${lenght_qos}=   get length   ${qos}
	Should be equal    ${lenght_schedulWeight}    ${lenght_qos}
    FOR    ${i}    IN RANGE        ${lenght_qos}
        run keyword if    '${qos[${i}]}' == '5'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[-1]'
        run keyword if    '${qos[${i}]}' == '7'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[0]'
        run keyword if    '${qos[${i}]}' == '4'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[2]'
        run keyword if    '${qos[${i}]}' == '8'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[1]'
    END
    [teardown]  csn.disconnect    connection=ute

Check the scheduleight of specific qosid is as expected
    [Arguments]    ${qos}    ${qosId}   ${schedulWeight}    ${Weight_value}    
    Log To Console    Check the scheduleight of specific qosid is as expected
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${lenght_schedulWeight}=   get length   ${schedulWeight}
    ${lenght_qosId}=   get length   ${qos}
	Should be equal    ${lenght_schedulWeight}    ${lenght_qosId}
    FOR    ${i}    IN RANGE        ${lenght_qosId}
        run keyword if    '${qos[${i}]}' == '${qosId}'    should be true    '${schedulWeight[${i}]}' == '${Weight_value}'
	    run keyword if    '${qos[${i}]}' == '${qosId}'    Exit For Loop
    END
    [teardown]  csn.disconnect    connection=ute

Get pcap during UE attach
    [Arguments]    ${log_path}=/user/toor4nsn    ${log_name}=cprt.pcap    ${gnb_index}=0
    log to console    Get pcap during UE attach   	
	ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=GNB_OAM
    Start Tcpdump for CB006457    log_name=${log_name}    log_path=${log_path}
    Log to console     Attach UE
    Attach UE
    sleep    5s
    Stop Tcpdump for CB006457
    ssh.download_file    remote_path=${log_path}/${log_name}
    ...                  local_path=${EXECDIR}/${log_name}
    ...                  connection=GNB_OAM
	ssh.execute
    ...    command=rm -rf ${log_path}/${log_name}
    ...    connection=GNB_OAM
    #Detach UE

Online calculate the expected scaled schedulingWeight
    [Arguments]    ${schedulingWeightSF}       ${schedulWeight}   ${expected_value}=0
    Log To Console    Online calculate the expected scaled schedulingWeight
	${tmp_1}    evaluate        ${schedulingWeightSF}*${schedulWeight}
    ${tmp_2}    convert to number    ${tmp_1}    0
	${tmp_3}    convert to integer   ${tmp_2}
	set test variable    ${expected_value}    ${tmp_3}
	run keyword if    ${tmp_3}>100    set test variable    ${expected_value}    ${100}
	run keyword if    ${tmp_3}<1      set test variable    ${expected_value}   ${1}
    log to console    expected_value=${expected_value}
    [return]    ${expected_value}
	
Online modify parameters "schedulingWeightSF" for specific arp
    [Arguments]       ${SF_value}    ${index}
	log to console    Online modify parameters "schedulingWeightSF" for specific arp
    #selenium login and disable screen lock    download_dir=/tmp
	log to console    Convert To Integer
	${index}    Convert To Integer    ${index}
	selenium_coam.set_parameter_value
	...    dist_name=${MR_NR_BTS_NAME}    filter_param=Scaling factor for scheduling weight    new_value=${SF_value}    node_index=${index}
	selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
	#[Teardown]  Run keyword and ignore error    selenium logout and close browser
	
Online modify parameters "arpPrioLev" for specific arp
    [Arguments]       ${ARP_value}    ${index}
	log to console    Online modify parameters "arpPrioLev" for specific arp
    #selenium login and disable screen lock    download_dir=/tmp
	log to console    Convert To Integer
	${index}    Convert To Integer    ${index}
	selenium_coam.set_parameter_value
	...    dist_name=${MR_NR_BTS_NAME}    filter_param=ARP priority level   new_value=${ARP_value}    node_index=${index}
	selenium_coam.validate_plan
	[Teardown]  Run keyword and ignore error    selenium logout and close browser

Online modify parameters "schedulingWeightSF" and "arpPrioLev"
    [Arguments]    ${SF_value}=${schedulingWeightSF_list}    ${ARP_value}=${arpPrioLev_list}
	log to console    Online modify parameters "schedulingWeightSF" and "arpPrioLev" for multi DRB
    ${lenght_SF}=   get length   ${schedulingWeightSF_list}
    ${lenght_ARP}=   get length   ${arpPrioLev_list}
	Should be equal    ${lenght_SF}    ${lenght_ARP}    
	${index}    Convert To Integer    ${lenght_SF}
	selenium login and disable screen lock    download_dir=/tmp
	FOR    ${i}    IN RANGE    ${index}
        Online modify parameters "schedulingWeightSF" for specific arp    SF_value=${SF_value}[${i}]    index=${i}
	    Online modify parameters "arpPrioLev" for specific arp    ARP_value=${ARP_value}[${i}]    index=${i}
    END
	[Teardown]  Run keyword and ignore error    selenium logout and close browser

Get pcap file for master during UE attach
    [Arguments]    ${log_path}=/user/toor4nsn    ${log_name}=cprt.pcap    ${gnb_index}=0    ${is_right_rack}=no
    log to console    Get pcap file for master during UE attach
    Run keyword if    '${is_right_rack}'=='yes'    Login right rack
    ...      ELSE    Login GNB
    Start Tcpdump for CB006457    log_name=${log_name}    log_path=${log_path}    connection=${connection_master}
    Log to console     start to Attach UE
    Attach UE
    sleep    1s
    Stop Tcpdump for CB006457    connection=${connection_master}
    ssh.download_file    remote_path=${log_path}/${log_name}
    ...                  local_path=${EXECDIR}/${log_name}
    ...                  connection=${connection_master}
	ssh.execute
    ...    command=rm -rf ${log_path}/${log_name}
    ...    connection=${connection_master}

Disable CB006457 online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAMETERS_TO_CB006457_disable}    timeout=${timeout}
    #COAM delete parameters via rest api
    #...       objects_to_delete_via_api=${PARAMETERS_TO_CB006457_multiArpBasedParam}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Enable CB006457 online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAMETERS_TO_CB006457_enable}    timeout=${timeout}
    #COAM delete parameters via rest api
    #...       objects_to_delete_via_api=${PARAMETERS_TO_CB006457_multiArpBasedParam}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Login GNB
    [Arguments]    ${gnb_index}=${0}
	ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=GNB_OAM
    set test variable    ${connection_master}    GNB_OAM
	
Login right rack
    [Arguments]    ${gnb_index}=${0}
	ssh.Connect to
    ...    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=GNB_OAM
	ssh.Connect to
    ...    hostname=fct4s0icom.local
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    alias=GNB_OAM_Secondary
	...    proxy=GNB_OAM
	set test variable    ${connection_master}    GNB_OAM_Secondary

Check the scheduleight of multi DRB for NSA as expected
    [Arguments]    ${qos}   ${schedulWeight}    ${expected_weight}
    Log To Console    Check the scheduleight of multi DRB as expected
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${lenght_schedulWeight}=   get length   ${schedulWeight}
    ${lenght_qos}=   get length   ${qos}
	Should be equal    ${lenght_schedulWeight}    ${lenght_qos}
    FOR    ${i}    IN RANGE        ${lenght_qos}
        run keyword if    '${qos[${i}]}' == '6'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[0]'
        run keyword if    '${qos[${i}]}' == '7'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[1]'
        run keyword if    '${qos[${i}]}' == '8'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[2]'
        run keyword if    '${qos[${i}]}' == '9'    should be true    '${schedulWeight[${i}]}' == '${expected_weight}[3]'
    END
    [teardown]  csn.disconnect    connection=ute

Online modify parameters "nbrUlDlSF" for specific index
    [Arguments]       ${NBR_SF_value}    ${index}
	log to console    Online modify parameters "schedulingWeightSF" for ${index} arp
    #selenium login and disable screen lock
	#log to console    Convert To Integer
	#${index}    Convert To Integer    ${index}
	selenium_coam.set_parameter_value
	...    dist_name=${MR_NR_BTS_NAME}    filter_param=Scaling factor for nominal bitrates for UL and DL
    ...    new_value=${NBR_SF_value}    node_index=${index}
	#selenium_coam.validate_plan
    #selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
	#[Teardown]  Run keyword and ignore error    selenium logout and close browser
	
Online modify parameters "nbrUlDlSF" for multiArpBasedParam
    [Arguments]       ${nbrUlDlSF_list}=${nbrUlDlSF_list}
    Log To Console    Online modify parameters "nbrUlDlSF" for multiArpBasedParam
    ${lenght_NBR_SF}=   get length   ${nbrUlDlSF_list}
	${NBR_length}    Convert To Integer    ${lenght_NBR_SF}
	selenium login and disable screen lock    download_dir=/tmp
	FOR    ${i}    IN RANGE    ${NBR_length}
        Online modify parameters "nbrUlDlSF" for specific index    NBR_SF_value=${nbrUlDlSF_list}[${i}]    index=${i}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Enable CB006457-B online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}    ${cell_id}=1
    log to console    Enable CB006457-B online by admin
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    #COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAMETERS_TO_CB006457_enable}    timeout=${timeout}
    #COAM delete parameters via rest api
    #...       objects_to_delete_via_api=${PARAMETERS_TO_CB006457_multiArpBasedParam}    timeout=${timeout}
	log to console    \nEnable CB006457-B online
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    parameter=actArpBasedQosScaling
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=actNbrForNonGbrBearers
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=maxNumOfNbrBearers
    ...    value=80
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=maxPrbsPerNbrUe
    ...    value=80
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=nbrPdcchCongHandlingDl
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=nbrPdcchCongHandlingUl
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=nbrPdschCongHandling
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=nbrPuschCongHandling
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ...    parameter=miNrRacDu
    ...    value=5min
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM	
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Enable CB006457-B online by python parameters
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}    ${cell_id}=1
    log to console    Enable CB006457-B online by python parameters
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAMETERS_TO_CB006457_B_enable}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
	
Get the NBR of multi DRB 
    [Arguments]    ${pcap_file}=${EXECDIR}/${pcap_log_name}   ${expected_value}=80
	...    ${display_filter$}=itf_l2_ps_user_bearersetupreq || itf_l2_ps_user_usersetupreq
    ...    ${field_name_dl}=itf_l2_ps_NbrDrbSpecificParams.nbrDl_item
    ...    ${field_name_ul}=itf_l2_ps_NbrDrbSpecificParams.nbrUl_item
    Log To Console    Get the NBR of multi DRB 	
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${output_nbrdl}	  csn.Execute
    ...    command=/usr/bin/tshark -r "${pcap_file}" -Y "${display_filter$}" -T fields -e ${field_name_dl}    connection=ute
	${output_nbrdl1}    set variable    ${output_nbrdl.strip()}
	${output_nbrdl2}=     replace string    ${output_nbrdl1}    \r\n    ,
	${output_nbrdl}    Split String From Right   ${output_nbrdl2}  separator=,
    ${output_qosId_tmp}	  csn.Execute
    ...    command=tshark -r "${pcap_file}" -Y "${display_filter$}" -T fields -e itf_l2_ps_DrbAddReqPs.qosId    connection=ute
	${output_qosId_tmp}    set variable    ${output_qosId_tmp.strip()}
	${output_qosId_tmp}=     replace string    ${output_qosId_tmp}    \r\n    ,
	${output_qosId}    Split String From Right   ${output_qosId_tmp}  separator=,
    ${output_nbrul}	  csn.Execute
    ...    command=tshark -r "${pcap_file}" -Y "${display_filter$}" -T fields -e ${field_name_ul}    connection=ute
	${output_nbrul1}    set variable    ${output_nbrul.strip()}
	${output_nbrul2}=     replace string    ${output_nbrul1}    \r\n    ,
	${output_nbrul}    Split String From Right   ${output_nbrul2}  separator=,
	[return]    ${output_qosId}    ${output_nbrdl}    ${output_nbrul}    
	[teardown]  csn.disconnect    connection=ute
	
Check NBR Counters for multi nonGBR
    [Arguments]    ${counter1}=M55139C03506    ${counter2}=M55139C03507    ${exp_C03506}=2    ${exp_C03507}=2    ${interval}=5min
    log to console    \n*** Check NBR Counters ${counter1} ${counter2} for multi nonGBR***	
    Connect to Common Unit Master
    selenium login and disable screen lock    download_dir=/tmp
    Set test variable    ${get_counter}    False
    ${check_time}    Get PM Counter time   interval=${interval}
    ${wait_time_next}    Get wait value minutes
	run keyword if    '${wait_time_next}' == '5.0'    set test variable   ${wait_time_next}    4.0    
    set test variable   ${wait_time_next}
    ${C03506}    Get PM Counter via Webem for CB006457    counter_id=${counter1}    interval=${interval}   check_time=${check_time}
	${C03507}    Get PM Counter via Webem for CB006457    counter_id=${counter2}    interval=${interval}   check_time=${check_time}
    Should be equal      ${C03506}    ${exp_C03506}
    Should be equal      ${C03507}    ${exp_C03507}
    #set test variable   ${get_counter}    
    [Return]   ${get_counter}
    [Teardown]     run keyword and ignore error    selenium logout and close browser
	
Check the nbr of specific qosid is as expected
    [Arguments]    ${qos}    ${nbrdl}    ${nbrul}    ${exp_nbrdl}    ${exp_nbrul}
    Log To Console    Check the scheduleight of specific qosid is as expected
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${lenght_nbrdl}=   get length   ${nbrdl}
	${lenght_nbrul}=   get length   ${nbrul}
    ${lenght_qosId}=   get length   ${qos}
	Should be equal    ${lenght_nbrdl}    ${lenght_qosId}
	Should be equal    ${lenght_nbrul}    ${lenght_qosId}
    FOR    ${i}    IN RANGE    ${lenght_qosId}
        should be true    '${nbrdl[${i}]}' == '${exp_nbrdl[${i}-1]}'
        should be true    '${nbrul[${i}]}' == '${exp_nbrul[${i}-1]}'
    END
    [teardown]  csn.disconnect    connection=ute	

Online modify parameters "nrDrbMacDN" for NRDRB
    [Arguments]    ${NRDRB_ID}=12    ${NRDRB_MAC_ID}=1        ${gnb_index}=${0}    ${timeout}=${60}
	log to console    \nOnline modify parameters "nrDrbMacDN" for NRDRB
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB-${NRDRB_ID}
    ...    parameter=nrDrbMacDN
    ...    value=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_MAC-${NRDRB_MAC_ID}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online modify parameters NBR for MAC
    [Arguments]    ${MAC_ID}=1    ${nbrDl}=50    ${nbrUl}=10    ${gnb_index}=${0}    ${timeout}=${60}
	log to console    \nOnline modify parameters "nrDrbMacDN" for NRDRB
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_MAC-${MAC_ID}
    ...    parameter=nbrDl
    ...    value=${nbrDl}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_MAC-${MAC_ID}
    ...    parameter=nbrUl
    ...    value=${nbrUl}
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_MAC-${MAC_ID}
    ...    parameter=schedulBSD
    ...    value=100ms
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections		
	
Check the NBRDL of multi DRB for NSA as expected
    [Arguments]    ${qos}    ${nbrdl}    ${exp_nbrdl}
    Log To Console    Check the NBRDL of multi DRB for NSA as expected
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${lenght_nbrdl}=   get length   ${nbrdl}
    ${lenght_qos}=   get length   ${qos}
	Should be equal    ${lenght_nbrdl}    ${lenght_qos}
    FOR    ${i}    IN RANGE        ${lenght_qos}
        run keyword if    '${qos[${i}]}' == '6'    should be true    '${nbrdl[${i}]}' == '${exp_nbrdl}[0]'
        run keyword if    '${qos[${i}]}' == '7'    should be true    '${nbrdl[${i}]}' == '${exp_nbrdl}[1]'
        run keyword if    '${qos[${i}]}' == '8'    should be true    '${nbrdl[${i}]}' == '${exp_nbrdl}[2]'
        run keyword if    '${qos[${i}]}' == '9'    should be true    '${nbrdl[${i}]}' == '${exp_nbrdl}[3]'
    END
    [teardown]  csn.disconnect    connection=ute

Check the NBRUL of multi DRB for NSA as expected
    [Arguments]    ${qos}    ${nbrul}    ${exp_nbrul}
    Log To Console    Check the NBRUL of multi DRB for NSA as expected
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute	
    ${lenght_nbrul}=   get length   ${nbrul}
    ${lenght_qos}=   get length   ${qos}
	Should be equal    ${lenght_nbrul}    ${lenght_qos}
    FOR    ${i}    IN RANGE        ${lenght_qos}
        run keyword if    '${qos[${i}]}' == '6'    should be true    '${nbrul[${i}]}' == '${exp_nbrul}[0]'
        run keyword if    '${qos[${i}]}' == '7'    should be true    '${nbrul[${i}]}' == '${exp_nbrul}[1]'
        run keyword if    '${qos[${i}]}' == '8'    should be true    '${nbrul[${i}]}' == '${exp_nbrul}[2]'
        run keyword if    '${qos[${i}]}' == '9'    should be true    '${nbrul[${i}]}' == '${exp_nbrul}[3]'
    END
    [teardown]  csn.disconnect    connection=ute

Disable "actNbrForNonGbrBearers" online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}    ${cell_id}=1
    log to console    Disable CB006457-B online by admin
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
	log to console    \nDisable CB006457-B online
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=actNbrForNonGbrBearers
    ...    value=false
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Enable "actNbrForNonGbrBearers" online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}    ${cell_id}=1
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
	log to console    \nEnable "actNbrForNonGbrBearers" online
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=actNbrForNonGbrBearers
    ...    value=true
    ...    operation=update
    ...    skip_parameter_relation_errors=skip
    ...    connection=GNB_OAM
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
	
Online modify parameters "nbrUlDlSF" for arp
    [Arguments]       ${NBR_SF_value}    ${index}=0
    log to console    Online modify parameters "nbrUlDlSF" for arp
    selenium login and disable screen lock
    log to console    Convert To Integer
    ${index}    Convert To Integer    ${index}
    selenium_coam.set_parameter_value
    ...    dist_name=${MR_NR_BTS_NAME}    filter_param=Scaling factor for nominal bitrates for UL and DL
    ...    new_value=${NBR_SF_value}    node_index=${index}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
	[Teardown]  Run keyword and ignore error    selenium logout and close browser	
