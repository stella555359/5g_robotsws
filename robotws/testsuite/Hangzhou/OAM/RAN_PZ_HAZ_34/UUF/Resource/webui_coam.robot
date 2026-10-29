*** Settings ***
Documentation     author: Ruiyu Han
...               contact: ruiyu.han@nokia-sbell.com
...               Upgrade and Rollback UUF case.

Library   taf.selenium.sbts    WITH NAME    selenium_sbts
Library   taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.transport.ssh    WITH NAME    csn
Library           ../../libraries/TestCaseRequirement.py
Resource           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/netact_swm.robot
Resource      testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/gnb.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/UUF_vars.py
Library    OperatingSystem
Library    XML
Library    Process
Library    String
Library    Collections
Library    DateTime

*** Variables ***
${origin_version}
${enb_target_version}
${enb_source_version}

*** Keywords ***
COAM Upgrade package
    [Arguments]     ${package}   ${ip}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}   ${type}=gNB
    log to console    COAM Upgrade package
    ${is_common}   run keyword and return status   should contain   ${package}   SBTS
    ${build_path}   set variable if   ${is_common}   /home/ute/${package}.zip   /home/ute/AirScale-${package}.zip
    Wait Until Keyword Succeeds   3 times   2 min    WEBEM Login
    ...   url=https://${ip}    user=${username}    password=${password}
    Load SW Package to gNB    file_path=${build_path}
    selenium_sbts.software_update    is_activate=${True}
    run keyword and ignore error   Check If BTS Busy and Retry
    Check If Trigger Upgrade or Rollback Succeed    upgrade   package=${package}    type=${type}   ip=${ip}
    [Teardown]   run keyword and ignore error    webui_coam.WEBEM Logout

COAM Rollback package
    [Arguments]    ${login_ip}=${WEBUI_ADDR}
    log to console    COAM Rollback package
    Wait Until Keyword Succeeds   3 min   5sec    WEBEM Login    https://${login_ip}/
    run keyword and ignore error    selenium_sbts.disable_message_box
    run keyword and ignore error    selenium_sbts.disable_screen_lock
    selenium_sbts.software_rollback
    run keyword and ignore error   Check If BTS Busy and Retry    ${False}
    Check If Trigger Upgrade or Rollback Succeed    rollback
    [Teardown]   run keyword and ignore error    webui_coam.WEBEM Logout

Upgrade eNB and Check Cell Setup
     [Arguments]   ${eNB_package}=${enb_target_version}   ${action}=provision   ${type}=eNB
     ...    ${enb_ip}=${ENBs[1]['addr']}   ${save_log}=${True}    ${ignore_fault}=${False}
     ${current_version}   ${enb_passive_version}   Get eNB SW version   ${enb_ip}
     ${target_release}   ${target_version}   Split String   ${enb_target_version}   _   1
     Run Keyword If   '${type.lower()}'=='enb'   COAM Upgrade package   package=${eNB_package}   ip=${enb_ip}   type=${type}
     ...    ELSE   Force SW Upgrade COAM   build_name=${eNB_package}.zip   host=${enb_ip}
     run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
     ...   ip_addr=${enb_ip}   exp_status=${False}
     Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
     ...   ip_addr=${enb_ip}  exp_status=${True}
     wait until keyword succeeds   20 min  10 s   Check If Active Software Version Updated    action=${action}   ip=${enb_ip}
     ...    upgrade_version=${enb_target_version}   source_build=${enb_source_version}
     Run Keyword If    ${ignore_fault}    run keyword and ignore error
     ...    Check Gnb and Enb Status after Gnb Upgrade Rollback    save_log=${save_log}
     ...    ELSE    Check Gnb and Enb Status after Gnb Upgrade Rollback    save_log=${save_log}

Upgrade Moran eNB and Check Cell Setup
    [Arguments]   ${eNB_package}   ${eNB_ip}=${ENBs[1]['addr']}    ${action}=provision   ${type}=eNB
    Run Keyword If   '${type.lower()}'=='enb'   COAM Upgrade package   package=${eNB_package}   ip=${eNB_ip}   type=${type}
    ...    ELSE   Force SW Upgrade COAM   build_name=${eNB_package}.zip   host=${eNB_ip}
    run keyword and ignore error    Wait Until Keyword Succeeds   30 min   10 s    Validate IP Reachability from Test PC
    ...   ip_addr=${eNB_ip}   exp_status=${False}
    Wait Until Keyword Succeeds   10 min   20 s    Validate IP Reachability from Test PC
    ...   ip_addr=${eNB_ip}  exp_status=${True}
    wait until keyword succeeds   20 min  10 s   Check If Active Software Version Updated    action=${action}   ip=${eNB_ip}
    ...    upgrade_version=${enb_target_version}   source_build=${enb_source_version}
    run keyword and continue on failure   wait until keyword succeeds   30 min  10 s   Coam Check Site Status   ip=${eNB_ip}
    ...    if_ignore_cablink=${False}

COAM Download SCF to Current Dir
    [Arguments]    ${dir}=${CURDIR}    ${filename}=SCF_BACKUP.xml    ${bts_host}=${WEBUI_ADDR}
    Wait Until Keyword Succeeds    3 min    1 min    COAM Login    ${bts_host}
    COAM Backup SCF    local_dir=${dir}   file_name=${filename}    connection=COAM
    ${cpri_scf}    Set Variable    ${dir}
    Set Suite Variable    ${cpri_scf}
    [Teardown]   run keyword and ignore error    COAM Logout

Check Cell Setup in COAM
    log to console    Check Cell Setup in COAM
    Wait Until Keyword Succeeds   10 min   1 min    COAM Login
    FOR     ${number}    IN RANGE    ${40}
         ${status}    run keyword and return status    Check COAM Session Exist and Cell Status
         run keyword if  not ${network_status}    FAIL
         Exit For Loop If    ${status}
         sleep   30s
    END
    run keyword if  not ${status}    FAIL    [ERROR]cell not ready exceed 20 min!
    [Teardown]   run keyword and ignore error    COAM Logout

Check COAM Session Exist and Cell Status
    log to console    Check COAM Session Exist and Cell Status
    ${network_status}    run keyword and return status    Wait for Site Availability
	run keyword if    '${network_status}'=='True'   run keyword and ignore error    COAM Login
	...   ELSE    Log    gNB breack connection this time!    ERROR
	set suite variable    ${network_status}
	FOR   ${number}    IN RANGE    ${cellnum}
	    COAM Check Cell Status    connection=COAM    cell_index=${number}
	END
	[Teardown]   run keyword and ignore error    COAM Logout

Screenshot for COAM
    [Arguments]     ${dir}   ${sbts}=${None}
    run keyword if  not ${sbts}   Wait Until Keyword Succeeds   3 min   5sec    WEBEM Login
    Create Directory     ${OUTPUT_DIR}/${dir}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_sbts.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${OUTPUT_DIR}/${dir}   sbts=${sbts}
    [Teardown]     run keyword if  not ${sbts}   run keyword and ignore error    webui_coam.WEBEM Logout

WEBEM Login
    [Arguments]  ${url}=${WEBUI_URL}    ${user}=${WEBUI_USER}    ${password}=${WEBUI_PASSWORD}   ${sbts}=${None}
    run keyword and ignore error  Run   killall firefox
    selenium_sbts.login    url=${url}    username=${user}    password=${password}   timeout=${120}   alias=${sbts}
    run keyword and ignore error    selenium_sbts.disable_message_box   sbts=${sbts}
    run keyword and ignore error    selenium_sbts.disable_screen_lock   sbts=${sbts}
    ${status}    ${if_window_exists}    run keyword and ignore error    selenium_sbts.start_up_view_window_exists   sbts=${sbts}
    run keyword and ignore error    run keyword if    ${if_window_exists}    selenium_sbts.close_start_up_view_window   sbts=${sbts}
    run keyword and ignore error    selenium_sbts.continue_after_plug_and_play_modal_appear   timeout=15    sbts=${sbts}

WEBEM Logout
    [Arguments]   ${sbts}=${None}
    selenium_sbts.logout   sbts=${sbts}

Wait for Site Unavailability
    ${output}    RUN    sudo ping ${LMP_ADDR} -c 3
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    should be true    ${${output}}> ${90}

Wait for Site Availability
    ${output}    RUN    sudo ping ${LMP_ADDR} -c 3
    ${output}    Get Regexp Matches    ${output}    \\d{0,3}% packet loss
    ${output}    Fetch From Left    ${output[0]}    %
    should be true    ${${output}}< ${30}

Load SW Package to gNB
    [Arguments]    ${file_path}     ${active_changes}=yes   ${sbts}=${None}
    ${result}    selenium_sbts.load_software_package_from_local_drive    file_path=${file_path}   sbts=${sbts}
    should be equal      ${result}    software package load success
    ${enable}=   Run Keyword If   '${active_changes.lower()}'=='yes'   Set Variable   ${True}
    ...   ELSE   Set Variable   ${False}

Get Alarm Sreenshot in COAM
    [Arguments]      ${dir}   ${sbts}=${None}
    run keyword if  not ${sbts}   Wait Until Keyword Succeeds   3 min   5sec    WEBEM Login
    run keyword and ignore error    selenium_sbts.disable_message_box   sbts=${sbts}
    run keyword and ignore error    selenium_sbts.disable_screen_lock   sbts=${sbts}
    selenium_sbts.get_active_alarm_info   sbts=${sbts}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    Create Directory     ${OUTPUT_DIR}/${dir}
    selenium_sbts.save_screenshot   filename=Screen_activealarm_${curr_data}.png    screenshot_dir=${OUTPUT_DIR}/${dir}   sbts=${sbts}
    [Teardown]   run keyword if  not ${sbts}   run keyword and ignore error    webui_coam.WEBEM Logout

COAM LMP Login
    [Arguments]   ${bts_host}=${LMP_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    ...   ${bts_port}=${443}   ${log_dir}=${OUTPUT_DIR}   ${alias}=COAMLMP
    coam.connect_to
    ...   bts_host=${bts_host}
    ...   bts_port=${bts_port}
    ...   username=${username}
    ...   password=${password}
    ...   use_ssl=${True}
    ...   update_interval=${5000}
    ...   admin_api_log_dir=${log_dir}
    ...   name=${alias}
    [Return]   ${alias}

COAM LMP Logout
    [Arguments]   ${connection}=COAMLMP
    coam.teardown      connection=${connection}

Debug Catch Snapshot COAM
    [Arguments]    ${snapshot_path}    ${http}=${LMP_ADDR}
    Wait Until Keyword Succeeds   3 min   15sec    COAM LMP Login
    Run Keyword And Ignore Error   taf_coam.Catch Snapshot COAM      local_file_path=${snapshot_path}    connection=COAMLMP
    [Teardown]   run keyword and ignore error    COAM LMP Logout

Check If Trigger Upgrade or Rollback Succeed
    [Arguments]   ${action}   ${package}=${None}    ${type}=gNB   ${ip}=${EMPTY}
    ${ip}   Set Variable If   '${type}'!='gNB' and '${ip}'==''   ${ENBs[1]['addr']}   ${ip}
    ${active_version}   ${passive_version}   run keyword if  '${type}'=='gNB'    Get gNB SW version
    ...    ELSE    Get gNB SW version   ${ip}
#    ${passive_build}   Check gNB Version is Common Build   ${passive_version}
    ${target_version}   Check gNB Version is Common Build   ${package}
    ${if_passive_target}    run keyword and return status    should not be equal    ${passive_version}    ${target_version}
#    set suite variable   ${if_passive_target}
    ${sleep_time}    run keyword if  ${if_passive_target} and '${action}'=='upgrade'    set variable    150s
    ...    ELSE    set variable    10s
    ${check_list}    create list    fail    reject
    ${pass_list}    create list    reset    Activating software...
    FOR    ${i}    IN RANGE    ${60}
        ${result}    selenium_sbts.check_software_update_progress
        ${fail_status}    run keyword and return status   should contain any    ${result}[status]    ${check_list}
        ...    msg=upgrade or rollback success, ${result}[status]
        ${reset_status}    run keyword and return status   should contain any    ${result}[status]    ${pass_list}    msg=${result}[status]
        ${if_status_empty}    run keyword and return status   should be empty    ${result}[status]    msg=Result status is empty.
        exit for loop if  ${fail_status}
        exit for loop if  ${reset_status}
        exit for loop if  ${if_status_empty}
        sleep  ${sleep_time}
        run keyword if    ${i}==${59}    Fail    msg=BTS has no resetting action.
    END
    run keyword if    ${fail_status}    Fail    msg=upgrade or rollback failed, ${result}[status]

WebEM Cancel Software Update
    log to console   Cancel sw update when download rate up to 30%
    ${start_time}    DateTime.Get Current Date
    FOR    ${i}    IN RANGE    ${60}
    ${result}    selenium_sbts.check_software_update_progress
    #${result} = {'status': u'Downloading and distributing files...', 'percentage': u'41%'}
    ${download_percent}   split string    ${result}[percentage]   %
    exit for loop if    ${download_percent}[0] > 30
    ${current_time}    DateTime.Get Current Date
    ${download_progress}    Subtract Date From Date   ${current_time}   ${start_time}
    ${coverted_duration}   convert to string   ${download_progress}
    ${duration}   Split String   ${coverted_duration}   .   1
    exit for loop if    ${duration}[0] > 600
    sleep   60s
    END
    should contain   ${result}[percentage]   %
    selenium_sbts.cancel_software_update
    [Teardown]   run keyword and ignore error    webui_coam.WEBEM Logout

WebEM Trigger Software Update
    [Arguments]     ${package}   ${ip}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    log to console    COAM Upgrade package
    ${is_common}   run keyword and return status   should contain   ${package}   SBTS
    ${build_path}   set variable if   ${is_common}   /home/ute/${package}.zip   /home/ute/AirScale-${package}.zip
    Wait Until Keyword Succeeds   3 times   2 min    WEBEM Login
    ...   url=https://${ip}    user=${username}    password=${password}
    Load SW Package to gNB    file_path=${build_path}
    selenium_sbts.software_update    is_activate=${True}

WebEM Get SW version
    [Arguments]  ${ip}=${WEBUI_ADDR}   ${username}=${WEBUI_USER}   ${password}=${WEBUI_PASSWORD}
    Wait Until Keyword Succeeds   3 times   2 min    WEBEM Login
    ...   url=https://${ip}    user=${username}    password=${password}
    ${current_build}   selenium_sbts.check_current_software_version
    #Return: {'Active': 'SBTS22R1_ENB_9999_210912_000003','Passive': 'SBTS22R1_ENB_9999_210913_000015','Planned': '-'}
    ${webem_active}   Check gNB Version is Common Build   ${current_build}[Active]
    ${webem_passive}   Check gNB Version is Common Build   ${current_build}[Passive]
    ${webem_planned}   Check gNB Version is Common Build   ${current_build}[Planned]
    [Return]  ${webem_active}   ${webem_passive}   ${webem_planned}
    [Teardown]   run keyword and ignore error    webui_coam.WEBEM Logout

Check If BTS Busy and Retry
    [Arguments]   ${is_upgrade}=${True}
    ${busy_list}    create list    BTS is busy
    ${result}    selenium_sbts.check_software_update_progress
    ${busy_status}    run keyword and return status   should contain any    ${result}[status]    ${busy_list}
        ...    msg=upgrade or rollback success, ${result}[status]
    Run keyword if   ${busy_status}    run keywords   sleep   60s
    ...    AND    Retry Upgrade or Rollback    ${is_upgrade}

Retry Upgrade or Rollback
    [Arguments]   ${is_upgrade}=${True}
    Run keyword if    ${is_upgrade}    selenium_sbts.software_update    is_activate=${True}
    ...   ELSE   selenium_sbts.software_rollback
