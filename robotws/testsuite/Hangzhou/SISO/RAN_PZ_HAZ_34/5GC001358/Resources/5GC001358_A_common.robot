*** Settings ***
Documentation
...    author: Guo Zhenzhen
...    contact: zhenzhen.guo@nokia-sbell.com
...    squad group: SG_03
...    Feature : 5GC001358

Library    Collections
Library    String
Library    OperatingSystem
Library    XML  lxml=True
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Variables ***
${WEBUI_ADDR}        ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WebUI_User}        Nemuadmin
${WebUI_Password}    nemuuser
${asik_addr}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${dl_exp}    1500
${ul_exp}    50
${TS_CASE_LOG_PATH}    ${OUTPUT DIR}/
@{selenium_gnb_login}


#RU info
${ru_addr}    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
#${ru_username}    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${ru_username}    root
#${ru_password}    ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${ru_password}    w@=EIj7P6R0bVy85OjCVa^ho&8
${ru_type_init}    AZQG
#${ru_type_init}    ${tl.gnbs[0].dus[0].rus[0].radio_type.value}  # the 1st RU by default if mulitiple RUs used
#${pb_model_ru}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.__class__.__name__}
${ru_runtime_zip}     1011_runtime.zip
${ru_runtime_xz}      runtime_DEFAULT.log.xz
${ru_runtime_log}     runtime_DEFAULT.log

${mrbtsId}    ${tl.gnbs[0].instance_id}
${nrbtsId}    ${tl.gnbs[0].global_bts_id}
${syncStatus_path}    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
${lockState_path}    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
${acceptedClock_path}    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
${syncInputType_RAU_path}    MRBTS-${mrbtsId}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1

*** Keywords ***
SISO suite setup
    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    name=default
    COAM WebEM Login   display=${false}    version=21A


SISO suite teardown
    Run Keyword and Ignore Error    admin_cli.teardown
    Run Keyword and Ignore Error    COAM WebEM Logout

check RU Status
    [Arguments]   ${expected_status}=Unlocked
    Close startup view if visible
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
          ${output_tmp}    selenium_coam.get_ru_info     type_=RMOD_R    ru_index=${ru_id}
          ${RU_info}    set variable    ${output_tmp}[Status]
          should match regexp    ${RU_info}[Operational state]    Enabled
          should match regexp    ${RU_info}[Availability status]    Online
          should match regexp    ${RU_info}[Procedural status]    configured
          run keyword if    '${expected_status}'=='Unlocked'
          ...    should match regexp    ${RU_info}[Administrative state]    Unlocked
          ...    ELSE IF   '${expected_status}'=='Locked'
          ...    should match regexp    ${RU_info}[Administrative state]    Locked
          ...    ELSE   log to console   WRN: RU_${ru_id} status is ${RU_info}[Administrative state], not Unlocked or Locked.
    END


check SW version
    [Documentation]     output planned/active/passive version like:5G19_FSMK_0000_018351_000316
    [Arguments]      ${version_type}
    ${version}    selenium_coam.check_current_software_version
    ${output}    set variable    ${version}[${version_type}]
    [Return]      ${output}    ${version}

Get list of all ru
    [Arguments]    ${connection}=default
    ${rmods}    coam.get_ids_for_all    class_name=RMOD   connection=${connection}
    ${rmods_id}    Create List
    FOR    ${rmod}    IN    @{rmods}
          ${rmod_id}    Fetch From Right    ${rmod}    -
          Append To List   ${rmods_id}    ${rmod_id}
    END
    [Return]    ${rmods_id}

Perform RU Reset via WebEM
    [Arguments]    ${ru_index}=${1}   ${download_dir}=${TS_CASE_LOG_PATH}
    ${ru_index}  Convert To Integer    ${ru_index}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    selenium_coam.reset_ru  ru_index=${ru_index}
	[Teardown]    COAM selenium logout

Perform RF Module Reset from GUI
    log to console    Perform RF Module Reset from GUI - started
    ${ru_list}    Get list of all ru
    set test variable    ${ru_list}
    FOR    ${ru_id}    IN    @{ru_list}
         Perform RU Reset via WebEM    ru_index=${ru_id}   download_dir=${OUTPUT_DIR}
         sleep    5s
    END
    Run Keyword and Ignore Error    Wait Until Keyword Succeeds    2min    5s    Check all RUs Disabled

Get list of all cells
    ${cells}=       admin_cli.Get parameters for all    class_name=NRCEL   connection=default
    ${cells_id}=    Create List
    FOR    ${cell}    IN    @{cells}
          ${cell_id}=          Get From Dictionary    ${cell}        configurationId
          Append To List       ${cells_id}       ${cell_id}
    END
    [Return]       ${cells_id}



Check If BTS Is OnAir
    ${bts_statuses_response}=    admin_cli.Get Bts Info    connection=default
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=OnAir

Check all cells onAir
    Log To Console    Check cells onAir
    COAM Check All Cells Onair    connection=default

Get BTSId
    ${bts_info}=  admin_cli.get_bts_info    connection=default
    set suite variable    ${mrbts_id}    ${bts_info["mrbtsID"]}
    set suite variable    ${nrbts_id}    ${bts_info['nrBtsId']}


ADMIN Collect Snapshot
    [Arguments]    ${snapshot_path}=${OUTPUT DIR}
    ${date}    DateTime.Get current date    result_format=%Y%m%d_%H%M%S
    coam.Collect snapshot
    ...        target_file_name=${snapshot_path}/Snapshot_${date}.zip
    ...        coverage=Full
    ...        force=True
    ...        timeout=720
    ...        connection=default
    [Return]    ${snapshot_path}/Snapshot_${date}.zip

Lock RU via WebEM
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          selenium_coam.lock_ru    type_=RMOD_R  ru_index=${ru_id}
          sleep    30s
    END

Unlock RU via WebEM
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          selenium_coam.unlock_ru   type_=RMOD_R  ru_index=${ru_id}
          sleep    30s
    END


Check if all RU is locked
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          ${ru_info_full}   selenium_coam.get_ru_info    ru_index=${ru_id}
          ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
          should match regexp    ${ru_info}[Operational state]    Enabled
          should match regexp    ${ru_info}[Availability status]    Online
          should match regexp    ${ru_info}[Administrative state]    Locked
          should match regexp    ${ru_info}[Procedural status]    configured
          #Check given state    ${cell_info}    Administrative state    locked
    END


Check if all RU is unlocked
    ${ru_list}    Get list of all ru
    FOR    ${ru_id}    IN    @{ru_list}
          ${ru_info_full}   selenium_coam.get_ru_info    ru_index=${ru_id}
          ${ru_info}         Get From Dictionary    ${ru_info_full}    Status
          #Check given state    ${cell_info}    Administrative state    unlocked
    END



Check Led Status
    Close startup view if visible
    @{module_list}    Create List    SMOD-1    BBMOD-1    RMOD-1
    FOR    ${module}    IN    @{module_list}
        ${module_status}=    Get Led status of given unit    unit_name=${module}
        Should be equal as strings    ${module_status}    Online    msg=${module} current status is ${module_status}    ignore_case=${True}
    END

Get Led status of given unit
    [Arguments]    ${unit_name}
    Close startup view if visible
    ${led_status}    selenium_coam.Get Led Status Of An Unit    unit=${unit_name}
    [Return]    ${led_status}

Perfrom RU reset
    Close startup view if visible
    selenium_coam.reset_ru

Perfrom BTS reset
    COAM Navigate to login page via webUI   download_dir=${TS_CASE_LOG_PATH}
    selenium_coam.reset_site
	#[Teardown]    COAM selenium logout

Check RU IP
    [Arguments]    ${RU_NO}
    #csn.Connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    csn.send_command    command=cd /ffs/run/config;cat FRIps.txt    connection=gNB
    sleep    2s
    ${result}    csn.read output    connection=gNB
    ${RU_addr_info_line}    Get Lines Containing String    ${result}    ${RU_NO}
    ${RU_addr}    Should Match Regexp   ${RU_addr_info_line}    \\d+\\.\\d+\\.\\d+\\.\\d+
    Should not be equal    ${RU_addr}    0.0.0.0
    [Return]    ${RU_addr}
    [Teardown]    #csn.disconnect    connection=gNB

Get RU Nomuber
    ${result}    selenium_coam.Get Ru Info     ru_index=${1}
    ${RU_NO}    Set Variable    ${result['Serial number']}
    [Return]      ${RU_NO}


Get Feature 1834 Flag
    [Arguments]  ${asik_alias}=ASIK Master  ${container_id}=0x1018
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    [Return]  ${feature_1834_opened}

get ru detial info by ru index
    [Documentation]
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${ru_index}=1    ${connection}=default
    ${ru_index}    Convert to string    ${ru_index}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    Should be true    ${count_RUs}>=1    msg=No RU found
    &{dict_RUs_detail_info}   Create dictionary
    FOR    ${RU}    IN    @{list_RUs}
        ${status}    Run Keyword And Return Status    Should Contain   '${RU}'   RMOD-${ru_index}
        Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_RUs_detail_info}    ${ru_index}    ${RU}
    END
    [Return]  ${dict_RUs_detail_info['${ru_index}']}

Get All AZQG Index
    &{hw_info}       coam.get_detected_hw_info    connection=default
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    ${ru_index_list}    create list
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_id_configuration}  set variable  ${ru.id.configuration}
        ${ru_index}    get regexp matches    ${ru_id_configuration}    RMOD-(.)    1
        append to list    ${ru_index_list}    ${ru_index[0]}
    END
    Sort List   ${ru_index_list}
    [Return]  ${ru_index_list}

Connect to AZQG With Allocated IP
    [Documentation]
    ...               Description: Get RU IP address In ASIK : Get RU IP Address from log in ASIK : /rom/config/FRIps.txt
    [Arguments]  ${ru_index}=${1}   ${ru_alias}=RU   ${asik_alias}=ASIK Master   ${connection}=default
    ...          ${container_id}=0x1018    ${container_alias}=Container    ${fhnet_host_ip}=192.168.255.254
    ...          ${ru_username}=${ru_username}
    ...          ${ru_password}=${ru_password}
    ${container_id}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    5GC001358_A_common.get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}   Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
    ${output}    csn.execute    lxc-ls    connection=${asik_alias}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    Run Keyword If    ${feature_1834_opened}
    ...    Connect To RU by FHNET Container    ru_ip_addr=${ru_ip_addr}
    ...                                         container_id=${container_id}
    ...                                         container_alias=${container_alias}
    ...                                         ru_alias=${ru_alias}
    ...                                         asik_alias=${asik_alias}
    ...                                         fhnet_host_ip=${fhnet_host_ip}
    ...                                         ru_username=${ru_username}
    ...                                         ru_password=${ru_password}
    ...    ELSE    csn.connect to    hostname=${ru_ip_addr}
    ...                              username=${ru_username}
    ...                              password=${ru_password}
    ...                              alias=${ru_alias}
    ...                              proxy=${asik_alias}


reload scf
    [Arguments]   ${scfFilePath}=${OUTPUT DIR}/scf.xml
    Close startup view if visible
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scfFilePath}
    sleep   3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    1min
    run keyword and ignore error    wait until keyword succeeds    20min    30s    Check all cells onAir


Prepare UE and attach UE
    Log To Console    \n ### Prepare UE ###
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Attach ###
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${UE_TYPE}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${UE_TYPE}   5Grach_ed=${5Grach_ed_0}    4G_check=False

Start UE traffic
    [Arguments]    ${dl_data}=50M    ${ul_data}=50M
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=dl   throughput=${dl_data}    duration=120s
    power_ue.Start traffic   ue_type=${UE_TYPE}   direction=ul   throughput=${ul_data}    duration=120s
    #${all_tp}    Get ul and dl peak and ave throughput and return result
    #Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
    #Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}
    #run keyword and continue on failure    run keyword if    '${protocol}'!='tcp'    power_ue.Check peak throughput
    #...    ue_type=${ue_type}    theory_dl_peak=${dl_exp}    theory_ul_peak=${ul_exp}
    #...    duration_time_for_once=120s    acceptable_tput_percentage=${rate}
    #...    ELSE    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_tput_tcp}
    #run keyword and continue on failure    power_ue.Check peak throughput    ue_type=${ue_type}
    #...    theory_dl_peak=${dl_exp}    theory_ul_peak=${ul_exp}    gnb_ssl_connection=default


Check downlink and uplink TP
    Log To Console    Check downlink and uplink TP
    run keyword and continue on failure    power_ue.Check peak throughput    ue_type=${ue_type}
    ...    theory_dl_peak=${dl_exp}    theory_ul_peak=${ul_exp}    gnb_ssl_connection=default
    #run keyword and continue on failure    power_ue.Check throughput    ue_type=${ue_type}
    #...    theory_dl_peak=${dl_exp}    theory_ul_peak=${ul_exp}    gnb_ssl_connection=default

Stop traffic and detach UE
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}
    Log To Console    \n ### UE Detach ###
    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

Stop traffic
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${UE_TYPE}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${UE_TYPE}


UE attach and check tp
    [Arguments]    ${tp_direction}=both    ${dl_tp}=100M    ${ul_tp}=100M
    ...    ${exp_dl_tp}=100    ${exp_ul_tp}=100    ${check_times}=30s
    log to console    UE attach and check tp
    Prepare UE and attach UE
    UE start traffic   tp_direction=${tp_direction}   ul_tp=${ul_tp}    dl_tp=${dl_tp}
    #Start UE traffic    dl_data=${dl_tp}    ul_data=${ul_tp}
    sleep    1min
    Run keyword and continue on failure    UE check throughput by syslog    tp_direction=${tp_direction}
    ...   exp_ul_tp=${exp_ul_tp}    exp_dl_tp=${exp_dl_tp}    check_times=${check_times}
    #power_ue.Stop traffic    direction=${tp_direction}    ue_index=${0}    ue_type=${UE_TYPE}
    #power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}

UE start traffic
    [Arguments]    ${tp_direction}=both    ${ul_tp}=100M    ${dl_tp}=100M
    log to console    UE start traffic
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=${dl_tp}   duration=800    ue_type=${ue_type}    buffer_size=1400B
    sleep    3s
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${ul_tp}    duration=800    ue_type=${ue_type}    iperf_type=via_command

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

Close startup view if visible
    #${startup_view_visible}=    run keyword and return status    Wait Until Element Is Visible    timeout=30
    #...    locator=//div[@class="footer"]//button[text()=" Close"]
    #run keyword if    ${startup_view_visible}    Click Element   locator=//div[@class="footer"]//button[text()=" Close"]
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[0]}'=='PASS'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

Block cell
    log to console    Block cell
    admin_cli.block    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    connection=default

Unblock cell
    log to console    unblock cell
    admin_cli.unblock    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    connection=default


Lock cell
    log to console    Lock cell
    admin_cli.lock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    connection=default

Unlock cell
    log to console    unlock cell
    admin_cli.unlock_cell    dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    connection=default

Confirm cell status is locked
    log to console    Confirm cell status is locked
    Sleep    10s
    &{Cell_locked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_Locked}    set variable    ${Cell_locked}[Status]
    should be equal    ${Cell_Locked}[Operational state]    Disabled    ignore_case=True
    #should be equal    ${Cell_Locked}[Procedural status]    initializing    ignore_case=True
    should be equal    ${Cell_Locked}[Availability status]    offline   ignore_case=True
    should be equal    ${Cell_Locked}[Administrative state]    Locked    ignore_case=True

Confirm cell status is unlocked
    log to console    Confirm cell status is unlocked
    Sleep    30s
    &{Cell_unlocked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_unlocked}    set variable    ${Cell_unlocked}[Status]
    should be equal    ${Cell_unlocked}[Operational state]    Enabled    ignore_case=True
    #should be equal    ${Cell_unlocked}[Procedural status]    configured    ignore_case=True
    should be equal    ${Cell_unlocked}[Availability status]    Online   ignore_case=True
    should be equal    ${Cell_unlocked}[Administrative state]    Unlocked    ignore_case=True

Confirm cell status is blocked
    log to console    Confirm cell status is blocked
    Sleep    30s
    &{Cell_blocked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_bLocked}    set variable    ${Cell_blocked}[Status]
    should be equal    ${Cell_blocked}[Operational state]    Disabled    ignore_case=True
    should be equal    ${Cell_blocked}[Procedural status]    initializing    ignore_case=True
    should be equal    ${Cell_blocked}[Availability status]    offline   ignore_case=True
    should be equal    ${Cell_blocked}[Blocking state]    Blocked    ignore_case=True

Confirm cell status is unblocked
    log to console    Confirm cell status is unblocked
    Sleep    30s
    &{Cell_unblocked}    Wait Until Keyword Succeeds    2min    2s    selenium_coam.get_cell_info
    ${Cell_unblocked}    set variable    ${Cell_unblocked}[Status]
    should be equal    ${Cell_unblocked}[Operational state]    Enabled    ignore_case=True
    should be equal    ${Cell_unblocked}[Procedural status]    configured    ignore_case=True
    should be equal    ${Cell_unblocked}[Availability status]    Online   ignore_case=True
    should be equal    ${Cell_unblocked}[Blocking state]    Unblocked    ignore_case=True

RU Led Status Change to Green
    log to console    RU Led Status Change to Green    console=yes
    #COAM Navigate to login page via webUI   download_dir=${OUTPUT_DIR}
    ${RU_State}      Get Led status of given unit    unit_name=RMOD-1
    should be equal    ${RU_State}    Online
    #[Teardown]    COAM selenium logout

Testline recovery
    Run keyword and continue on failure    Unlock cell
    #Run keyword and continue on failure    Unblock cell
	#Perfrom BTS reset
	Run Keyword and Ignore Error    Stop traffic and detach UE
	#Wait Until Keyword Succeeds    15 min    20 sec    Check all cells onAir

COAM WebEM Login
    [Documentation]    login the coam webui
    [Arguments]   ${url}=https://${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${display}=${false}
    ...   ${driver_alias}=WEBEM_DRIVER   ${version}=None   ${alias}=${None}
    Return From Keyword If   '${alias}' in @{selenium_gnb_login}
    Run Keyword If   '${alias}'=='None'   Stop Firefox Pid
    run keyword if  not ${display}   selenium_coam.enable_virtual_display

    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${download_dir}   Set Variable   /tmp/tmp_download_${curr_data}
    ${driver}   selenium_coam.create_firefox_web_driver   download_dir=${download_dir}   name=${driver_alias}
    selenium_coam.set_scope   alias=${driver_alias}   scope=global
    selenium_coam.login
    ...   url=${url}
    ...   username=${username}
    ...   password=${password}
    ...   browser=${driver}
    ...   download_dir=${download_dir}
    ...   timeout=${120}
    ...   version=${version}
    ...   alias=${alias}
    Run Keyword and Ignore Error   selenium_coam.disable_message_box   coam=${alias}
    Run Keyword and Ignore Error   selenium_coam.disable_screen_lock   coam=${alias}
    Append To List   ${selenium_gnb_login}   ${alias}
    Set Global Variable   ${selenium_gnb_login}
    [Return]   ${driver}

COAM WebEM Logout
    [Documentation]   Logout the coam webui
    [Arguments]   ${display}=${false}   ${coam}=${None}
    Return From Keyword If   not ${selenium_gnb_login}
    ${alias_dict}   Get COAM Alias Dict   coam=${coam}
    selenium_coam.logout   &{alias_dict}
    Remove Values From List   ${selenium_gnb_login}   ${coam}
    Set Global Variable   ${selenium_gnb_login}
    run keyword if  not ${display}   selenium_coam.disable_virtual_display
    Sleep   2s

Stop Firefox Pid
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $2}' | xargs kill -9
    OperatingSystem.Run   ps -ef | grep firefox | grep -v grep | awk '{print $3}' | xargs kill -9

Connect To RU by FHNET Container
    [Arguments]    ${ru_ip_addr}    ${container_id}=0x1018    ${container_alias}=Container    ${ru_alias}=RU
    ...            ${asik_alias}=ASIK Master    ${fhnet_host_ip}=192.168.255.254
    ...            ${ru_username}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...            ${ru_password}=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ${connection}    csn.get_connection_by_alias    alias=${asik_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
    Sleep    1 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    ps -ef|grep sshd\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    ${status}    Run Keyword And Return Status    Should Not Contain    ${output}    PermitRootLogin yes
    ${sshd_command}    Set Variable    /usr/sbin/sshd -p 22 -f /dev/null -o "PermitRootLogin yes" > /tmp/sshd_debug.log
    Run Keyword If    ${status}    Run Keywords    Call Method    ${channel}    send    ${sshd_command}\n    AND
    ...                                            Sleep    3 sec    AND
    ...                                            Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    csn.connect to    hostname=${fhnet_host_ip}
    ...               username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=${container_alias}
    ...               proxy=${asik_alias}
    csn.connect to    hostname=${ru_ip_addr}
    ...               username=${ru_username}
    ...               password=${ru_password}
    ...               alias=${ru_alias}
    ...               proxy=${container_alias}
