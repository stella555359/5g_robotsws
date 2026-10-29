*** Settings ***
Documentation
...    author: Wu Jun
...    contact: george.wu@nokia-sbell.com
...    squad group: mmw_SG_03
...    Feature : 5GC001687

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${WEBUI_ADDR}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WebUI_User}               Nemuadmin
${WebUI_Password}           nemuuser
${arti_hz_sbts}=            https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/
${UE_TYPE}                  qct_dx50
@{scf}                      SCF_SBTS00_1687_CPRI.xml    SCF_SBTS00_1687_eCPRI.xml    5GC001687_20M_1070_C2.xml
${case_scf_dir_path}        ${commissionings_path}/HGZ/7_5_UTE5G402T919/5GC001510-5GC001687/

*** Keywords ***
Coam Suite Setup
    Log to console    \n***Coam Suite Setup***
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type
    set suite variable      ${gNb_CuType}
    Generate suite log path
    set suite variable      ${SUITE_LOG_PATH}
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    Log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    ${radio_protocol_temp}    get_radio_protocal_via_admin
    run keyword if    '${radio_protocol_temp}'=='CPRI'    Commissioning SCF And Check On Air
	...    scf_path=${case_scf_dir_path}/${scf[0]}
	...    ELSE    Commissioning SCF And Check On Air    scf_path=${case_scf_dir_path}/${scf[1]}
    ${current_pkg}    Download trunk SW    SW=${Active_SW_version}
    set suite variable    ${current_pkg}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite Setup


Coam Suite Teardown
    Log to console    \n***Coam Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True
    Run Keyword And Ignore Error    selenium_coam.close_browser
    Selenium Logout And Close Browser
    Run Keyword And Ignore Error    delete Downloaded    ${current_pkg}
    Run Keyword And Ignore Error    robot_common_operations.Common Suite teardown


Coam Test Setup
    Log to console    \n***Coam Test Setup***
    Log to console    Active_SW_version:${Active_SW_version}
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    robot_common_operations.Common case setup


Coam Test Teardown
    Log to console    \n***Coam Test Teardown***
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    Log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    Should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    delete Downloaded    ${SUITE_LOG_PATH}/${current_pkg}
    ${radio_protocol_final}    get_radio_protocal_via_admin
#    run keyword if    '${radio_protocol_final}'=='ECPRI'    Commissioning SCF And Check On Air
#	...    scf_path=${case_scf_dir_path}/${scf[2]}
#	...    ELSE    Commissioning SCF And Check On Air    scf_path=${case_scf_dir_path}/${scf[0]}
    Disconect all connections
    Run Keyword And Ignore Error    robot_common_operations.Common case Teardown


Disconect all connections
    run keyword and ignore error     csn.disconnect     connection=cpc_0
    run keyword and ignore error     csn.disconnect     connection=TestPC
    run keyword and ignore error     coam.teardown      connection=GNB_OAM
    run keyword and ignore error     csn.disconnect     connection=ASIK
    run keyword and ignore error     enblte.teardown    connection=enblte

TDDCPRI_eCPRI_switch_on_WebEM
    Connect to gnb coam via ssl
    ${radio_protocol_temp}    get_radio_protocal_via_admin
#run keyword if    '${radio_protocol_temp}'=='${switch_to_radio_protocol}'    5GC001687_common.Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}
    5GC001687_common.Gnb Cpri Ecpri Switch    current_pkg=${current_pkg}
    UE Prepare
    UE attach and check tp    tp_direction=both    dl_tp=100M    ul_tp=100M    exp_dl_tp=20    exp_ul_tp=5
    [Teardown]  delete Downloaded    ${current_pkg}

Gnb Cpri Ecpri Switch
    [Arguments]    ${current_pkg}
    selenium login and disable screen lock
    Delete CMD Object If Exist
    5GC001687_common.Add PRTCLCHGRES Object Via Webem
    Log to console  start check fault 23 appear
    Wait For Expect Fault Present    faultId=23   timeout=600
    Log to console  upload current version package and activate: ${current_pkg}
    Perform SW Update  ${SUITE_LOG_PATH}/${current_pkg}
    sleep  360s
    Wait Until Keyword Succeeds    10min    360s    Check HW modules detection
    Log to console  start check fault 23 disappear
    Wait For Expect Fault To Disappear  faultId=23   timeout=600
    Run keyword and ignore error    Validate Check on WebUI
    COAM Wait gnb And Cells ready    timeout=15 min
    selenium login and disable screen lock
    Check Protocol Change Result Via Webem
    Delete CMD Object If Exist
    Selenium Logout And Close Browser
    ${radio_protocol_after_switch}    get_radio_protocal_via_admin

Add PRTCLCHGRES Object Via Webem
    #[Arguments]    ${link_speed}    ${radio_protocol_type}
    Log to console  \n***Add PRTCLCHGRES Object Via Webem***
    ${iqCompression}    ${link_speed}    ${radio_protocol_type}    5GC001687_common.Get Cpri Ecpri Switch Params
    Run Keyword And Ignore Error    Close Start Up View    timeout=120
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1
    ...    object_class_name=CMD    id_value=1    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/CMD-1
    ...    object_class_name=PRTCLCHGREQ    id_value=1    timeout=15
    ${ru_index_list}    get all ru index
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/CMD-1/PRTCLCHGREQ-1
        ${ru_index_temp}    convert to number  ${ru_index}
        ${node_index_temp}    Evaluate  ${ru_index_temp}-1
        selenium_coam.add_element    dist_name=${dist_name}
        ...    filter_param=Radio modules upgrade    abbr=rModUpgrade    timeout=15
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=IQ Compression
        ...    abbr=iqCompression    new_value=${iqCompression}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Link speed
        ...    abbr=linkSpeed    new_value=${link_speed}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio protocol type
        ...    abbr=radioProtocolType    new_value=${radio_protocol_type}    node_index=${node_index_temp}
        selenium_coam.set_parameter_value  dist_name=${dist_name}    filter_param=Radio module distinguished name
        ...    abbr=rModDN    new_value=MRBTS-${mrbtsID}/EQM-1/APEQM-1/RMOD-${ru_index}    node_index=${node_index_temp}
    END
    selenium_coam.validate_plan
    Run keyword and ignore error    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    timeout=15

Get Cpri Ecpri Switch Params
    [Documentation]    Auther: tingting.zhong@nokia-sbell.com
    Wait Until Keyword Succeeds    1min    10s    Connect to gnb coam via ssl
    ${radio_protocol}    get_radio_protocal_via_admin
    ${link_speed}    set variable if    '${radio_protocol}'=='CPRI'    eCpri25    Cpri7
    ${radio_protocol_type}    set variable if    '${radio_protocol}'=='CPRI'    25eCPRI    TDDCPRI
    ${iqCompression}    set variable if    '${radio_protocol}'=='CPRI'    eCPRI 9bits    none
    [Return]  ${iqCompression}    ${link_speed}    ${radio_protocol_type}


#-------------------------------------------------UE related start-----------------------------------------------------
UE Prepare
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ue_index=${0}    capatibility_index=${0}    reset_sol=ue_reboot     detach_request=${true}
    Run keyword and continue on failure    _Reboot UE    connection=cpc_0
    sleep    60s

UE attach and check tp
    [Arguments]    ${tp_direction}=both    ${dl_tp}=100M    ${ul_tp}=100M
    ...    ${exp_dl_tp}=100    ${exp_ul_tp}=100    ${check_times}=30s
    Log To Console    \n ### UE attach and check tp ###
    Attach UE
    UE start traffic   tp_direction=${tp_direction}   ul_tp=${ul_tp}    dl_tp=${dl_tp}
    sleep    60s
    Run keyword and continue on failure    UE check throughput by syslog    tp_direction=${tp_direction}
    ...   exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    check_times=${check_times}
    power_ue.Stop traffic    direction=${tp_direction}    ue_index=${0}    ue_type=${UE_TYPE}
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Attach UE
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    Log To Console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=800    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=800    ue_type=${ue_type}    iperf_type=via_command

UE check throughput by syslog
    [Arguments]    ${tp_direction}=both    ${exp_ul_tp}=100    ${exp_dl_tp}=100    ${check_times}=60s
    Log To Console    UE check throughput by syslog
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
    Run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}
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
#---------------------------------------------------UE related end-----------------------------------------------------

Download trunk SW
    [Arguments]    ${SW}=${Active_SW_version}    ${package_store_path}=${SAVE LOG DIRECTORY}
    ${sw_name}    ${sw_full_url}    get trunk sw name    SW=${SW}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    Run keyword if      ${status}    remove file    ${package_store_path}/${sw_name}
    ${sw_url}          Catenate    sudo wget ${sw_full_url} -nv -P ${package_store_path}
    ${res}             Run         ${sw_url}
    ${status}          run keyword and return status    file should exist  ${package_store_path}/${sw_name}
    Should be true    ${status}
    [Return]    ${sw_name}

get trunk sw name
    [Arguments]    ${SW}=${Active_SW_version}
    ${sbts_status}    run keyword and return status     Should contain    ${SW}    SBTS
    #${sbts_temp}    run keyword and return status     Should Contain Any   ${SW}    SBTS00_ENB_9999    SBTS22R3_ENB_9999
    ${sbts_temp_22R2}    run keyword and return status     Should Contain   ${SW}    SBTS22R2
    ${sbts_temp_22R3}    run keyword and return status     Should Contain   ${SW}    SBTS22R3
    ${sbts_temp_trunk}    run keyword and return status     Should Contain   ${SW}    SBTS22R4
    ${sw_version}   run keyword if    ${sbts_temp_trunk}    Replace String    ${SW}    SBTS22R4    SBTS00
    ...           ELSE    set variable     ${SW}
    ${sw_name}    set variable if      ${sbts_status}    ${sw_version}_release_BTSSM_downloadable_A54.zip
    ...    AirScale-${SW}.zip
    ${arti_path}    run keyword if
    ...    ${sbts_status}==${True} and ${sbts_temp_trunk}==${True}      set variable     ${arti_hz_sbts}SBTS00_packages/
    ...    ELSE IF      ${sbts_status}==${True} and ${sbts_temp_22R2}==${True}      set variable     ${arti_hz_sbts}SBTS22R2_packages/
    ...    ELSE      set variable    ${arti_hz}
    ${sw_full_url}  set variable     ${arti_path}${sw_version}/${sw_name}
    [Return]    ${sw_name}    ${sw_full_url}
