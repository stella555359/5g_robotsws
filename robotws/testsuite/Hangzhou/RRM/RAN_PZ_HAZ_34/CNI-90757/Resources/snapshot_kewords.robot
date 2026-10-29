*** Settings ***
Documentation    This is for RJIO Keywords
...              Author: Gao melinda
...              Contact: melinda.gao@nokia-sbell.com
...              squad: 5G_PZ_HZ_8_SG


Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource    ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Variables   ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
#Variables    ../TestData/Bharti_variables.py
Library     taf.hw.rf_attenuator    WITH NAME    att
#Library    ../TestData/Bharti_variables.py
Library    taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    String
Library    DateTime
Library    OperatingSystem

*** Variables ***
${scf_path}    ${commissionings_path}/HGZ/${testline_name}/SCF_SBTS00_peak.xml
${connection}   GNB_OAM
${global_bts_id}           ${tl.gnbs[0].global_bts_id}
${instance_id}              ${tl.gnbs[0].instance_id}
${DU_OAM}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USER}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ue_type}                   ${tl.ues[-1].capabilities[-1]}
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_port_number}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_0}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_1}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_2}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${att_port_3}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${att_port_4}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_5}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_6}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[6].port_no}
${att_port_7}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[7].port_no}
${att_port_8}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_9}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${att_port_10}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[10].port_no}
${att_port_11}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[11].port_no}
${att_port_12}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[12].port_no}
${att_port_13}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[13].port_no}
${att_port_14}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[14].port_no}
${att_port_15}              ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[15].port_no}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}    ##no signal
*** Keywords ***

Save Full Snapshot
    [Arguments]    ${snapshot_path}=${TS_CASE_LOG_PATH}    ${connection}=GNB_OAM
    ${timestamp}    DateTime.Get Current Date    result_format=%Y%m%d%H%M
    ${snapshot_zip_file_full}    Join Path    ${snapshot_path}    snapshot_${timestamp}.zip
    coam.get_snapshot    target_file_name=${snapshot_zip_file_full}    coverage=Full    timeout=1500    connection=${connection}
    [Return]    ${snapshot_zip_file_full}

check_unexpected_alarms
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}   allowed_faults=@{ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    file_path=${TS_CASE_LOG_PATH}    allowed_faults=@{ALLOWED_HISTORY_FAULT}

Connect to DU by ADMIN API
    [Arguments]      ${connection_AdminApi}=${connection}    ${StreamVersion}=SBTS00
    coam.connect_to
    ...    bts_host=${DU_OAM}    name=${connection_AdminApi}
    ...    username=${WEBUI_USER}
    ...    password=${WEBUI_PWD}
    ...    release=${StreamVersion}
    [Return]   ${connection_AdminApi}

DisConnect to DU by ADMIN API
     [Arguments]      ${connection_AdminApi}=${connection}
     coam.teardown    connection=${connection_AdminApi}


Make call on NR cell
    [Arguments]    ${ue_index}=${0}
    log to console    \n***Prepare UE***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Check UE DL and UL peak TP
    [Arguments]    ${expect_dl_tp}=1300    ${expect_ul_tp}=80    ${dl_traffic}=1500M    ${ul_traffic}=110M
    UE start traffic   tp_direction=both    ul_tp=${ul_traffic}    dl_tp=${dl_traffic}
    sleep    10s
   	Check throughput by syslog    tp_direction=both    exp_ul_tp=${expect_ul_tp}    exp_dl_tp=${expect_dl_tp}    check_times=60s

UE Prepare
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=110M    ${dl_tp}=1500M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=800    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=800    ue_type=${ue_type}    iperf_type=via_command

check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=70  ${exp_dl_tp}=1100    ${check_times}=60s
    log to console    UE check throughput by syslog
    AAsys log captrue    stop_aasys_flag=${False}
    sleep    ${check_times}
    ${all_tp}    Get ul and dl peak and ave throughput and return result    aasys_start_flag=${False}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[1]}>${exp_dl_tp}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[4]}>${exp_ul_tp}
    Set Suite Variable    ${all_tp}
    [Return]    ${all_tp[1]}    ${all_tp[4]}

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

Stop UE traffic and detach UE
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}


Adjust HBTE ATT Values
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    16
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}
    log to console    Adjust HBTE ATT Value
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}   max_attenuation=${HBTE_max_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END
    FOR  ${port_num}    IN RANGE    8    12
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END


Get initial Alarm and fault
    ${fault_id_list_0}      Get Alarm Info from WebUI      timeout=10s
	set suite variable      ${fault_id_list_0}
	${fault_id_list_0_length}    Get Length    ${fault_id_list_0}
	set suite variable      ${fault_id_list_0_length}

Get Alarm Info from WebUI
    [Arguments]   ${timeout}    ${alias}=GNB_OAM
    #WEBUI Login
    Connect to gnb coam via ssl
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=${alias}
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    sort list    ${fault_id_list}
    [Return]   ${fault_id_list}


commission_origin_SCF
    Connect to DU by ADMIN API
    COAM Commission with scf file    scf_file_path=${SCF_Path}    timeout=600    is_pdl_checking_needed=${True}
    Wait until keyword succeeds    10min    30s    verify all cells should be onair
    sleep    60s
    [Teardown]    DisConnect to DU by ADMIN API
