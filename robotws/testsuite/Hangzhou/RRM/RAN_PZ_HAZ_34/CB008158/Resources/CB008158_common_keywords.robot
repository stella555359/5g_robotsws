*** Settings ***
Documentation
...    author: tina.luo
...    contact:tina.luo@nokia-sbell.com
...    squad group: RAN_PZ_HAZ3_SG03
...    feature : CB008158

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

Variables   CB008158_scf_modify.py


*** Variables ***
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}                 ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${num_of_files}   20
${UE_TYPE}    ${tl.ues[-1].capabilities[1]}
${ui_version}    Mi12UI13.0.41
#${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
#${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
#${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
#${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
#${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${full_path_5qi7_M55159C00005}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_5qi7_M55159C00006}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
${full_path_5qi4_M55159C00005}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_5qi4_M55159C00006}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
${full_path_5qi1_M55159C00005}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_5qi1_M55159C00006}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
${full_path_qci7_M55159C00005}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_qci7_M55159C00006}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
${full_path_5qi7_M55158C00001}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
${full_path_5qi8_M55158C00001}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-8/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
${full_path_5qi7_M55158C00002}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
${full_path_5qi4_M55158C00001}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
${full_path_5qi4_M55158C00002}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
${full_path_5qi1_M55158C00001}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
${full_path_5qi1_M55158C00002}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP

${full_path_5qi1_M55159C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/DL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_5qi4_M55159C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/DL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_5qi7_M55159C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/DL_PDCP_SDU_DLY_CUUP_PMQAP
${full_path_5qi1_M55159C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/DL_PDCP_SDU_SENT_TOT_PMQAP
${full_path_5qi4_M55159C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/DL_PDCP_SDU_SENT_TOT_PMQAP
${full_path_5qi7_M55159C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/DL_PDCP_SDU_SENT_TOT_PMQAP

${full_path_qci7_M55158C00001}	 ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
${full_path_qci7_M55158C00002}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
${full_path_5qi8_M55158C00002}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-8/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
${full_path_5qi8_M55158C00003}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-8/HRLTQ/DL_RLC_AM_DLY_AIR_IF_TH_PMQAP
${full_path_5qi7_M55158C00003}   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/DL_RLC_AM_DLY_AIR_IF_TH_PMQAP

${full_path_qci7_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/UL_BURST_TOT_RLC_PMQAP
${full_path_5qi5_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-5/HRLTQ/UL_BURST_TOT_RLC_PMQAP
${full_path_5qi7_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/UL_BURST_TOT_RLC_PMQAP
${full_path_5qi2_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/HRLTQ/UL_BURST_TOT_RLC_PMQAP

${pmcounter_path_based_on_release}    TL933
*** Keywords ***
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


Delete All PMQAP MO online
    [Arguments]    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    FOR   ${i}   IN RANGE   ${num_of_files}
        Run Keyword And Ignore Error    COAM delete objects via rest api
        ...       objects_to_delete_via_api=${PARAMETERS_TO_CB008158_pmqap_delete_${i}}    timeout=${timeout}
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

CB008158 NSA case Preparation
    [Arguments]    ${gnb_index}=0
    log to console    \n*** CB008158 Case Preparation***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
    ...    scf_parameters_list=${PARAMETERS_TO_CB008158_NSA_enable}
    &{result}    coam.perform_commissioning    scf_file=${output_scf_file_path}
    ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
    Wait until cluster is on cell on air status    list_cell_group_index=0
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${True}
    #Delete All PMQAP MO online
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections


CB008158 SA case Preparation
    [Arguments]    ${gnb_index}=0
    log to console    \n*** CB008158 Case Preparation***
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path SA    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${output_scf_file_path}    coam_gnb_classical.COAM Modify scf file    scf_file_path=${Golden_SCF_Path}
    ...    scf_parameters_list=${PARAMETERS_TO_CB008158_SA_enable}
    &{result}    coam.perform_commissioning    scf_file=${output_scf_file_path}
    ...    timeout=300    skip_parameter_relation_errors=${True}    connection=GNB_OAM
    Wait until cluster is on cell on air status    list_cell_group_index=1
    ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
    Delete All PMQAP MO online
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
    ...    ${cur_relative_dir}=testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008158/Resources
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    ${gnb_ext_index}    evaluate    ${gnb_index}+1
    ${gnb_ext}    set variable if    ${gnb_index}==0    ${EMPTY}    _gnb${gnb_ext_index}
    ${path}    run keyword if   '${gnb_type}'=='ClassicalBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_8T8R_${stream}${gnb_ext}.xml
    ...    ELSE IF      '${gnb_type}'=='CloudBts'
    ...    Catenate    SEPARATOR=${/}    ${scf_base_path}    ${testline}    SCF_${stream}${gnb_ext}_${cu_or_du}.xml
    OperatingSystem.File Should Exist    ${path}
    log to console   ${SPACE*2}scf path: ${path}.
    [Return]    ${path}

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
    Log To Console    \n ### Prepare UE ###
	Run keyword if    '${UE_TYPE}'=='samsung'    power_ue.Prepare UE    ue_type=${UE_TYPE}
	Run keyword if    '${UE_TYPE}'=='xiaomi'     UE Prepare for xiaomi

UE Prepare for xiaomi
    Log To Console    \n ### Prepare UE ###
	power_ue.Prepare UE    ue_type=${UE_TYPE}  ui_version=${ui_version}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    ...           ${iperf_port_dl}=50227    ${iperf_port_ul}=43107
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=900000    ue_type=${ue_type}    buffer_size=1400B
    ...     iperf_port=${iperf_port_dl}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=900000    ue_type=${ue_type}    iperf_type=via_command
    ...    iperf_port=${iperf_port_ul}

UE capability check
    [Arguments]    ${ue_capability}=samsung
    Run keyword if    '${ue_capability}'=='samsung'    set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[0]}
    ...      ELSE IF      '${ue_capability}'=='xiaomi'      set test variable    ${UE_TYPE}    ${tl.ues[-1].capabilities[1]}

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

Detach UE
    Log To Console    \n ### UE Detach ###
    Run Keyword And Ignore Error    UE stop traffic
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

UE stop traffic
    [Arguments]    ${tp_direction}=both
    log to console    UE stop traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Stop traffic
	...    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic
	...    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}


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
#    log to console      .....wait 5mins....
#	sleep    5min

Check BTS Counter M55350C00027 and M55350C00028 for NSA
	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55159C00005_qci7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00005    check_time=${check_time}    full_path=${full_path_qci7_M55159C00005}
	${value_M55159C00006_qci7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00006    check_time=${check_time}    full_path=${full_path_qci7_M55159C00006}
	${value_M55350C00027}    Get PM Counter via Webem for CB008158    counter_id=M55350C00027    check_time=${check_time}
    Should be True      ${value_M55350C00027}>0
	${value_M55350C00028}    Get PM Counter via Webem for CB008158    counter_id=M55350C00028    check_time=${check_time}
    Should be True      ${value_M55350C00028}>0
    Should be True      ${value_M55350C00027}/${value_M55350C00028}<1000000
    Should be True       ${value_M55350C00027}==${value_M55159C00005_qci7}
    Should be True       ${value_M55350C00028}==${value_M55159C00006_qci7}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check BTS PMQAP Counter M55159C00005 and M55159C00006 for SA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55159C00005_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00005    check_time=${check_time}    full_path=${full_path_5qi7_M55159C00005}
	${value_M55159C00006_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00006    check_time=${check_time}    full_path=${full_path_5qi7_M55159C00006}
	${value_M55159C00005_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00005    check_time=${check_time}    full_path=${full_path_5qi4_M55159C00005}
	${value_M55159C00006_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00006    check_time=${check_time}    full_path=${full_path_5qi4_M55159C00006}
	${value_M55159C00005_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00005    check_time=${check_time}    full_path=${full_path_5qi1_M55159C00005}
	${value_M55159C00006_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00006    check_time=${check_time}    full_path=${full_path_5qi1_M55159C00006}
	${value_M55350C00027}    Get PM Counter via Webem for CB008158    counter_id=M55350C00027    check_time=${check_time}
	${value_M55350C00028}    Get PM Counter via Webem for CB008158    counter_id=M55350C00028    check_time=${check_time}
	${value_M55319C10004}    Get PM Counter via Webem for CB008158    counter_id=M55319C10004    check_time=${check_time}
	${value_M55327C03004}    Get PM Counter via Webem for CB008158    counter_id=M55327C03004    check_time=${check_time}
	${value_M55319C10007}    Get PM Counter via Webem for CB008158    counter_id=M55319C10007    check_time=${check_time}
	${value_M55327C03007}    Get PM Counter via Webem for CB008158    counter_id=M55327C03007    check_time=${check_time}
    Should be True       ${value_M55319C10004}*0.95<${value_M55159C00005_5qi4}<${value_M55319C10004}*1.05
    Should be True       ${value_M55327C03004}*0.95<${value_M55159C00006_5qi4}<${value_M55327C03004}*1.05
    Should be True       ${value_M55319C10007}*0.95<${value_M55159C00005_5qi7}<${value_M55319C10007}*1.05
    Should be True       ${value_M55327C03007}*0.95<${value_M55159C00006_5qi7}<${value_M55327C03007}*1.05
    Should be True       ${value_M55350C00027}==${value_M55159C00005_5qi1}
    Should be True       ${value_M55350C00028}==${value_M55159C00006_5qi1}
    Should be True       ${value_M55159C00005_5qi1}/${value_M55159C00006_5qi1}<1000000
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Get PM Counter via Webem for CB008158
    [Arguments]    ${counter_id}   ${check_time}    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB008158   counter_id=${counter_id}
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
    [Arguments]   ${counter_id}=M55350C00027    ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem for CB008158   counter_id=${counter_id}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    [Return]    ${last_time}



Get PM Counter content via Webem for CB008158
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

Check BTS Counter M55310C00002 and M55310C00003 for SA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55158C00001_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00001    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00001}
	${value_M55158C00002_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00002}
	${value_M55158C00001_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00001    check_time=${check_time}    full_path=${full_path_5qi4_M55158C00001}
	${value_M55158C00002_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi4_M55158C00002}
	${value_M55158C00001_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00001    check_time=${check_time}    full_path=${full_path_5qi1_M55158C00001}
	${value_M55158C00002_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi1_M55158C00002}
	${value_M55310C00002}    Get PM Counter via Webem for CB008158    counter_id=M55310C00002    check_time=${check_time}
	${value_M55310C00003}    Get PM Counter via Webem for CB008158    counter_id=M55310C00003    check_time=${check_time}
    Should be True       ${value_M55310C00002}*0.9<${value_M55158C00001_5qi7}
    Should be True       ${value_M55310C00003}*0.9<${value_M55158C00002_5qi7}
    Should be True       ${value_M55158C00001_5qi4}==0
    Should be True       ${value_M55158C00002_5qi4}==0
    Should be True       ${value_M55158C00001_5qi1}==0
    Should be True       ${value_M55158C00002_5qi1}==0
    Should be True       ${value_M55310C00002}/${value_M55310C00003}<1000000
    [Teardown]  Run keyword and ignore error    selenium logout and close browser


Check BTS PMQAP Counter M55350C00023 and M55350C00024 for SA
	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
    ${value_M55350C00023}    Get PM Counter via Webem for CB008158    counter_id=M55350C00023    check_time=${check_time}
    ${value_M55319C09007}    Get PM Counter via Webem for CB008158    counter_id=M55319C09007    check_time=${check_time}
    Should be True       ${value_M55319C09007}*0.95<${value_M55350C00023}<${value_M55319C09007}*1.05
	${value_M55350C00024}    Get PM Counter via Webem for CB008158    counter_id=M55350C00024    check_time=${check_time}
	${value_M55319C11007}    Get PM Counter via Webem for CB008158    counter_id=M55319C11007    check_time=${check_time}
    Should be True       ${value_M55319C11007}*0.95<${value_M55350C00024}<${value_M55319C11007}*1.05
    Should be True       ${value_M55350C00023}/${value_M55350C00024}<1000000
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check BTS PMQAP Counter M55350C0002X and M55159C0000X for SA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
    ${value_M55350C00025}    Get PM Counter via Webem for CB008158    counter_id=M55350C00025    check_time=${check_time}
    #${value_M55350C00026}    Get PM Counter via Webem for CB008158    counter_id=M55350C00026   check_time=${check_time}
	${value_M55159C00003}    Get PM Counter via Webem for CB008158    counter_id=M55159C00003    check_time=${check_time}
	#${value_M55159C00004}    Get PM Counter via Webem for CB008158    counter_id=M55159C00004    check_time=${check_time}
    Should be True       ${value_M55350C00025}==0
    #Should be True       ${value_M55350C00026}==0
    Should be True       ${value_M55159C00003}==0
    #Should be True       ${value_M55159C00004}==0
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check BTS PMQAP Counter M55159C0000X for SA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55159C00001_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00001    check_time=${check_time}    full_path=${full_path_5qi7_M55159C00001}
	${value_M55159C00002_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00002    check_time=${check_time}    full_path=${full_path_5qi7_M55159C00002}
	${value_M55159C00001_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00001    check_time=${check_time}    full_path=${full_path_5qi4_M55159C00001}
	${value_M55159C00002_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00002    check_time=${check_time}    full_path=${full_path_5qi4_M55159C00002}
	${value_M55159C00001_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00001    check_time=${check_time}    full_path=${full_path_5qi1_M55159C00001}
	${value_M55159C00002_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00002    check_time=${check_time}    full_path=${full_path_5qi1_M55159C00002}
	${value_M55350C00023}    Get PM Counter via Webem for CB008158    counter_id=M55350C00023    check_time=${check_time}
	${value_M55350C00024}    Get PM Counter via Webem for CB008158    counter_id=M55350C00024    check_time=${check_time}
	${value_M55319C09004}    Get PM Counter via Webem for CB008158    counter_id=M55319C09004    check_time=${check_time}
	${value_M55319C11004}    Get PM Counter via Webem for CB008158    counter_id=M55319C11004    check_time=${check_time}
	${value_M55319C09007}    Get PM Counter via Webem for CB008158    counter_id=M55319C09007    check_time=${check_time}
	${value_M55319C11007}    Get PM Counter via Webem for CB008158    counter_id=M55319C11007    check_time=${check_time}
    Should be True       ${value_M55319C09004}*0.95<${value_M55159C00001_5qi4}<${value_M55319C09004}*1.05
    Should be True       ${value_M55319C11004}*0.95<${value_M55159C00002_5qi4}<${value_M55319C11004}*1.05
    Should be True       ${value_M55319C09007}*0.95<${value_M55159C00001_5qi7}<${value_M55319C09007}*1.05
    Should be True       ${value_M55319C11007}*0.95<${value_M55159C00002_5qi7}<${value_M55319C11007}*1.05
    Should be True       ${value_M55350C00023}==${value_M55159C00001_5qi1}
    Should be True       ${value_M55350C00024}==${value_M55159C00002_5qi1}
    Should be True       ${value_M55159C00001_5qi1}/${value_M55159C00002_5qi1}<1000000
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check BTS PMQAP Counter M55159C0000X after pmqap update for SA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55159C00001_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00001    check_time=${check_time}    full_path=${full_path_5qi7_M55159C00001}
	${value_M55159C00002_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00002    check_time=${check_time}    full_path=${full_path_5qi7_M55159C00002}
	${value_M55159C00001_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00001    check_time=${check_time}    full_path=${full_path_5qi4_M55159C00001}
	${value_M55159C00002_5qi4}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00002    check_time=${check_time}    full_path=${full_path_5qi4_M55159C00002}
	${value_M55159C00001_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00001    check_time=${check_time}    full_path=${full_path_5qi1_M55159C00001}
	${value_M55159C00002_5qi1}    Get PM Counter via Webem for CB008158
	...        counter_id=M55159C00002    check_time=${check_time}    full_path=${full_path_5qi1_M55159C00002}
	${value_M55350C00023}    Get PM Counter via Webem for CB008158    counter_id=M55350C00023    check_time=${check_time}
	${value_M55350C00024}    Get PM Counter via Webem for CB008158    counter_id=M55350C00024    check_time=${check_time}
    Should be True       ${value_M55159C00001_5qi4}==${value_M55159C00001_5qi7}
    Should be True       ${value_M55159C00002_5qi4}==${value_M55159C00002_5qi7}
    Should be True       ${value_M55350C00023}==${value_M55159C00001_5qi1}
    Should be True       ${value_M55350C00024}==${value_M55159C00002_5qi1}
    Should be True       ${value_M55350C00023}/${value_M55350C00024}<1000000
    [Teardown]  Run keyword and ignore error    selenium logout and close browser
Check BTS Counter M55158C00001 and M55158C00002 for NSA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55158C00001_qci7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00001    check_time=${check_time}    full_path=${full_path_qci7_M55158C00001}
	${value_M55158C00002_qci7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_qci7_M55158C00002}
	${value_M55310C00002}    Get PM Counter via Webem for CB008158    counter_id=M55310C00002    check_time=${check_time}
    Should be True      ${value_M55310C00002}>0
	${value_M55310C00003}    Get PM Counter via Webem for CB008158    counter_id=M55310C00003    check_time=${check_time}
    Should be True      ${value_M55310C00003}>0
    Should be True      ${value_M55310C00002}/${value_M55310C00003}<1000000
    Should be True       ${value_M55310C00002}==${value_M55158C00001_qci7}
    Should be True       ${value_M55310C00003}==${value_M55158C00002_qci7}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser
Check BTS Counter M55158C00003 for threshold 2000

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55158C00003_5qi8}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00003    check_time=${check_time}    full_path=${full_path_5qi8_M55158C00003}
	${value_M55158C00003_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00003    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00003}
	${value_M55158C00002_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00002}
	${value_M55158C00002_5qi8}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi8_M55158C00002}
    Should be True      ${value_M55158C00003_5qi8}>0
    Should be True      ${value_M55158C00003_5qi7}>0
    Should be True       ${value_M55158C00003_5qi8}==${value_M55158C00002_5qi8}
    Should be True       ${value_M55158C00003_5qi7}==${value_M55158C00002_5qi7}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser


Check BTS Counter M55158C00003 for threshold min and max

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55158C00003_5qi8}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00003    check_time=${check_time}    full_path=${full_path_5qi8_M55158C00003}
	${value_M55158C00003_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00003    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00003}
	${value_M55158C00002_5qi8}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi8_M55158C00002}
	${value_M55158C00002_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00002    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00002}
	${value_M55158C00001_5qi8}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00001    check_time=${check_time}    full_path=${full_path_5qi8_M55158C00001}
	${value_M55158C00001_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00001    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00001}
    Should be True      ${value_M55158C00003_5qi7}<${value_M55158C00002_5qi7}*0.05
    Should be True      ${value_M55158C00003_5qi8}==${value_M55158C00002_5qi8}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser


Check BTS UL burst related counters in SA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55349C00021}    Get PM Counter via Webem for CB008158    counter_id=M55349C00021    check_time=${check_time}
	${M55158C00005_5qi5}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00005    check_time=${check_time}    full_path=${full_path_5qi5_M55158C00005}
	${M55158C00005_5qi7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00005    check_time=${check_time}    full_path=${full_path_5qi7_M55158C00005}
	${M55158C00005_5qi2}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00005    check_time=${check_time}    full_path=${full_path_5qi2_M55158C00005}
	Should be True       ${value_M55349C00021}==${M55158C00005_5qi7}+${M55158C00005_5qi5}+${M55158C00005_5qi2}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser

Check BTS UL burst related counters in NSA

	Connect to Common Unit Master
	selenium login and disable screen lock
	${check_time}    Get PM Counter time
	${value_M55349C00021}    Get PM Counter via Webem for CB008158    counter_id=M55349C00021    check_time=${check_time}
	${M55158C00005_qci7}    Get PM Counter via Webem for CB008158
	...        counter_id=M55158C00005    check_time=${check_time}    full_path=${full_path_qci7_M55158C00005}
	Should be True       ${M55158C00005_qci7}>0
	Should be True       ${M55158C00005_qci7}==${value_M55349C00021}
    [Teardown]  Run keyword and ignore error    selenium logout and close browser
Get Stream
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    [Return]       ${stream}
Set PMQAP related counter path
    ${stream}    Get Stream
	Connect to Common Unit Master
	selenium login and disable screen lock    timeout=360
    ${btsname}    selenium_coam.get_bts_name
	log to console    ${MR_NR_BTS_NAME}
	Run keyword If     '${stream}'!='SBTS24R1'     Set test variable    ${pmcounter_path_based_on_release}    [${btsname}] ${MR_NR_BTS_NAME}
	Run keyword If     '${stream}'=='SBTS24R1'    Set test variable    ${pmcounter_path_based_on_release}    CELLS
    Set test variable	 ${full_path_5qi7_M55159C00005}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_5qi7_M55159C00006}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
    Set test variable    ${full_path_5qi4_M55159C00005}  ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_5qi4_M55159C00006}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
    Set test variable    ${full_path_5qi1_M55159C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_5qi1_M55159C00006}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
    Set test variable    ${full_path_qci7_M55159C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/PDLTQ/UL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_qci7_M55159C00006}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/PDLTQ/UL_PDCP_SDU_SENT_SAP_TOT_PMQAP
    Set test variable    ${full_path_5qi7_M55158C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
    Set test variable    ${full_path_5qi8_M55158C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-8/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
    Set test variable    ${full_path_5qi7_M55158C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
    Set test variable    ${full_path_5qi4_M55158C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
    Set test variable    ${full_path_5qi4_M55158C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
    Set test variable    ${full_path_5qi1_M55158C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
    Set test variable    ${full_path_5qi1_M55158C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
    Set test variable    ${full_path_5qi1_M55159C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/DL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_5qi4_M55159C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/DL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_5qi7_M55159C00001}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/DL_PDCP_SDU_DLY_CUUP_PMQAP
    Set test variable    ${full_path_5qi1_M55159C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-1/PDLTQ/DL_PDCP_SDU_SENT_TOT_PMQAP
    Set test variable    ${full_path_5qi4_M55159C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-4/PDLTQ/DL_PDCP_SDU_SENT_TOT_PMQAP
    Set test variable    ${full_path_5qi7_M55159C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/PDLTQ/DL_PDCP_SDU_SENT_TOT_PMQAP
    Set test variable    ${full_path_qci7_M55158C00001}	   ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_AM_DLY_AIR_IF_PMQAP
    Set test variable    ${full_path_qci7_M55158C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
    Set test variable    ${full_path_5qi8_M55158C00002}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-8/HRLTQ/DL_RLC_AM_SDU_TRANS_SUCC_PMQAP
    Set test variable    ${full_path_5qi8_M55158C00003}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-8/HRLTQ/DL_RLC_AM_DLY_AIR_IF_TH_PMQAP
    Set test variable    ${full_path_5qi7_M55158C00003}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/DL_RLC_AM_DLY_AIR_IF_TH_PMQAP
    Set test variable    ${full_path_qci7_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-17/HRLTQ/UL_BURST_TOT_RLC_PMQAP
    Set test variable    ${full_path_5qi5_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-5/HRLTQ/UL_BURST_TOT_RLC_PMQAP
    Set test variable    ${full_path_5qi7_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-7/HRLTQ/UL_BURST_TOT_RLC_PMQAP
    Set test variable    ${full_path_5qi2_M55158C00005}    ${pmcounter_path_based_on_release}/NRCELL-1/NRPMQAP-2/HRLTQ/UL_BURST_TOT_RLC_PMQAP
    [Teardown]  Run keyword and ignore error    selenium logout and close browser
