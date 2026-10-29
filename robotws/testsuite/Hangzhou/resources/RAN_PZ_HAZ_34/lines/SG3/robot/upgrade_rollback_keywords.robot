*** Settings ***
Documentation
...    author: Ming Shi
...    contact: ming.shi@nokia-sbell.com
...    squad group: SG_03

Library      OperatingSystem
Library      Process
Library      Collections
Library      String
Library      BuiltIn
Library      taf.transport.ssh    WITH NAME    csn
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      taf.selenium.sbts      WITH NAME       selenium_coam
Library      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/upgrade_rollback_keywords.py
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot


*** Variables ***
${download_version_file_path}    /opt/workspace/SCF
${download_link}    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/
#${download_link}    https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/
${local_package_path}    /home/ute/Downloads
${Downloads_folder_name}    Downloads
${update_report_file}    update_report.txt


*** Keywords ***
#####precondition for upgrade
get_download_link_release_name
    ${release_name}    get_new_download_link_release    release_url=${download_link}
    Set Suite Variable    ${release_name}

#get version info
#    [Arguments]    ${index}=${0}    ${v_index}=${0}
#    @{version_list}=    get_version    index=${index}
#    ${release}=    String.split string    string=${version_list}[${v_index}]    separator=_
#    ${result}=    Run Keyword And Return Status    Should Contain    ${release_name}    ${release}[0]
#    ${new_version}    Run Keyword If    ${result}==False    Replace String    ${version_list}[${v_index}]    ${release}[0]    SBTS00
#    Run Keyword If    ${result}==False    Run Keywords
#    ...    Set Suite Variable    ${packet}
#    ...    ${download_link}SBTS00/${new_version}/${new_version}_release_BTSSM_downloadable_A54.zip    AND
#    ...    Set Suite Variable    ${package_download_link}    ${download_link}SBTS00/${new_version}/    AND
#    ...    Set Suite Variable    ${package_name}    ${new_version}_release_BTSSM_downloadable_A54.zip
#    ...    ELSE IF    ${result}==True    Run Keywords
#    ...    Set Suite Variable    ${packet}
#    ...    ${download_link}${release}[0]/${version_list}[${v_index}]/${version_list}[${v_index}]_release_BTSSM_downloadable_A54.zip    AND
#    ...    Set Suite Variable    ${package_download_link}    ${download_link}${release}[0]/${version_list}[${v_index}]/    AND
#    ...    Set Suite Variable    ${package_name}    ${version_list}[${v_index}]_release_BTSSM_downloadable_A54.zip
#    Set Suite Variable    ${version}    ${version_list}[${v_index}]

get version info
    [Arguments]    ${index}=${0}    ${v_index}=${0}
    @{version_list}=    get_version    index=${index}
    Log To Console    will upgrade to version ${version_list}[${v_index}]
    ${release}=    String.split string    string=${version_list}[${v_index}]    separator=_
    IF    '${release}[2]' == '9999'
        ${new_version}    Replace String    ${version_list}[${v_index}]    ${release}[0]    SBTS00
        Set Suite Variable    ${packet}    ${download_link}SBTS00/${new_version}/${new_version}_release_BTSSM_downloadable_A54.zip
        Set Suite Variable    ${package_download_link}    ${download_link}SBTS00/${new_version}/
        Set Suite Variable    ${package_name}    ${new_version}_release_BTSSM_downloadable_A54.zip
        Set Suite Variable    ${download_package_name}    ${new_version}
    ELSE
        Set Suite Variable    ${packet}
        ...    ${download_link}${release}[0]/${version_list}[${v_index}]/${version_list}[${v_index}]_release_BTSSM_downloadable_A54.zip
        Set Suite Variable    ${package_download_link}    ${download_link}${release}[0]/${version_list}[${v_index}]/
        Set Suite Variable    ${package_name}    ${version_list}[${v_index}]_release_BTSSM_downloadable_A54.zip
        Set Suite Variable    ${download_package_name}    ${version_list}[${v_index}]
    END
    Set Suite Variable    ${version}    ${version_list}[${v_index}]

check_and_download_packet
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    csn.send command
    ...    command=cd ${local_package_path};ls -l | grep ${package_name}
    ...    connection=ute
    ${check_result}    csn.read_output    connection=ute
    ${passed}    Run Keyword And Return Status    Should Contain    ${check_result}    ${package_name}
    Run Keyword If    '${passed}'=='False'    download_package
    [Teardown]    csn.disconnect     connection=ute

download_package
    log to console    start download package
    ${status}=    Run Keyword And Return Status    Directory Should Not Exist    path=${local_package_path}
    IF    ${status}
        Run    mkdir ${Downloads_folder_name}
    END
    ${wget_output}=    csn.Execute
    ...    command=cd ${local_package_path};rm -rf SBTS*    timeout=6000
    ...    connection=ute
    download_release_build
    ...    release_url=${download_link}
    ...    release_name=${download_package_name}
    ...    download_path=/home/ute/Downloads/

get_version
    [Arguments]    ${index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${version_list}=    get_download_version    file=${download_version_file}    index=${index}
    [Return]    ${version_list}

get_run_times
    [Arguments]    ${index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${repeat_times}=    get_repeat_times    file=${download_version_file}    index=${index}
    [Return]    ${repeat_times}

get_required_info
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}
    ...    get_used_info    file=${download_version_file}    index=${bts_index}
    [Return]    ${node_index}    ${node_type}    ${node_upgrade_boolean}    ${node_rollback_boolean}    ${node_reset_boolean}

get_bts_num
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${node_num}    get_node_num    file=${download_version_file}
    [Return]    ${node_num}

get_value_of_is_multi_bts_operation
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${is_multi_bts_operation}    get_parameter_value_on_json    file=${download_version_file}    key=is_multi_bts_operation
    ...    index=${bts_index}
    [Return]    ${is_multi_bts_operation}

get_value_of_is_make_traffic
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${is_make_traffic}    get_parameter_value_on_json    file=${download_version_file}    key=is_make_traffic
    ...    index=${bts_index}
    [Return]    ${is_make_traffic}

get_value_of_action_first
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${value_action_first}    get_parameter_value_on_json    file=${download_version_file}    key=action_first
    ...    index=${bts_index}
    [Return]    ${value_action_first}

get_value_of_is_capture_syslog_enabled
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${value_is_capture_syslog_enabled}    get_parameter_value_on_json    file=${download_version_file}    key=is_capture_syslog_enabled
    ...    index=${bts_index}
    [Return]    ${value_is_capture_syslog_enabled}

get_value_of_alarm_check_time
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${value_alarm_check_time}    get_alarm_check_time_on_json    file=${download_version_file}    key=alarm_check_time
    ...    index=${bts_index}
    [Return]    ${value_alarm_check_time}

get_value_of_value_is_check_lower_version_to_upgrade
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${value_is_check_lower_version_to_upgrade}    get_is_check_lower_version_to_upgrade_on_json
    ...    file=${download_version_file}    key=is_check_lower_version_to_upgrade
    ...    index=${bts_index}
    [Return]    ${value_is_check_lower_version_to_upgrade}

get_value_of_allowed_faults_ids
    [Arguments]    ${bts_index}=${0}
    Set Suite Variable    ${download_version_file}    ${download_version_file_path}/upgrade_rollback.json
    ${value_allowed_faults_ids}    get_parameter_value_on_json    file=${download_version_file}    key=allowed_faults_ids
    ...    index=${bts_index}
    [Return]    ${value_allowed_faults_ids}

get_allowed_faults_ids_string
    [Arguments]    ${value_allowed_faults_ids_list}
    ${allowed_faults_ids_string}=    convert_list_to_string    para_list=${value_allowed_faults_ids_list}
    [Return]    ${allowed_faults_ids_string}

clear ims2 file
    wait until keyword succeeds     1min    10s    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    csn.send command    command=rm -rf *.ims2    connection=ute
    [Teardown]    csn.disconnect     connection=ute

login via WEBUI
    [Arguments]    ${gnb_index}=${0}    ${virtual_enable}=${TRUE}
    run keyword if     ${virtual_enable}     run keyword and ignore error    selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    sleep    10s
    run keyword and ignore error      selenium_coam.disable_message_box
    run keyword and ignore error      selenium_coam.disable_screen_lock
    sleep    10s
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[-1]}'=='True'
    ...    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

logout via WEBUI
    [Arguments]     ${virtual_disable}=${TRUE}
    selenium_coam.logout
    run keyword if      ${virtual_disable}    run keyword and ignore error    selenium_coam.disable_virtual_display

get_version via WEBUI
    [Arguments]    ${version_type}=Active
    ${pre_${version_type}_version}    wait until keyword succeeds    1min    10s    check SW version    version_type=${version_type}
    set suite variable    ${pre_${version_type}_version}

upgrade build via WEBUI
    selenium_coam.load_software_package_from_local_drive    file_path=${local_package_path}${package_name}
    selenium_coam.software_update    is_activate=True

rollback build via WEBUI
    [Arguments]
    run keyword and ignore error     selenium_coam.disable_screen_lock
    wait until keyword succeeds    1min    10s    selenium_coam.software_rollback
    sleep    5min

save and check update report via WEBUI
    [Arguments]    ${gnb_index}=${0}    ${virtual_enable}=${TRUE}
    login via WEBUI    gnb_index=${gnb_index}    virtual_enable=${virtual_enable}
    ${sw_update_report}    selenium_coam.save_sw_update_report
    OperatingSystem.File Should Exist     ${sw_update_report}
    OperatingSystem.Copy File    ${sw_update_report}     ${local_package_path}
    ${file_path}    ${file_name}    OperatingSystem.split path    ${sw_update_report}
    ${sw_update_report_content}    OperatingSystem.get file    ${local_package_path}/${file_name}
    csn.Connect to    ${host_addr}    ${host_username}    ${host_password}    alias=TESTPC
    csn.send command    command=cat ${local_package_path}/${file_name} |grep -n "Started Software Build Download" |tail -1 |cut -d ":" -f1
    ...    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    ${line_number}    convert to integer   ${output}
    csn.send command    command=tail -n \+${line_number} ${local_package_path}/${file_name}    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    should not contain any    ${output}    error    failed
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=TESTPC

Check ABIL is UP via WEBUI
    [Arguments]    ${gnb_index}=${0}
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}/
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    #should be equal      &{output}[Availability status]     Online
    should be equal      ${output}[Procedural status]     configured

Check ASIK is UP via WEBUI
    [Arguments]    ${gnb_index}=${0}
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}/
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    ${P_name_smod}    set variable    ${output_tmp}[Product name]
    run keyword if    '${P_name_smod}' == 'ASIK AirScale Common'    Check ASIK State
    run keyword if    '${P_name_smod}' == 'ASIB AirScale Common'    Check ASIB State

Check ASIK State via WEBUI
    [Arguments]    ${gnb_index}=${0}
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}/
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_ASIK}    selenium_coam.get_asik_info
    ${output_1}    set variable    ${output_ASIK}[Status]
    should be equal      ${output_1}[Administrative state]    Unlocked
    #should be equal      &{output_1}[Availability status]     Online
    should be equal      ${output_1}[Procedural status]     configured

Check ASIB State via WEBUI
    [Arguments]    ${gnb_index}=${0}
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}/
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${output_ASIB}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIB}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled

Get alarms to check
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
#    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
    FOR  ${alarm}  IN  @{activate_alarms}
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '10'
                                      ...  msg=Current alarm faultId is equal 10
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4527'
                                      ...  msg=Current alarm faultId is equal 4527
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1900'
                                      ...  msg=Current alarm faultId is equal 1900
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6450'
                                      ...  msg=Current alarm faultId is equal 6450
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '16'
                                      ...  msg=Current alarm faultId is equal 16
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1806'
                                      ...  msg=Current alarm faultId is equal 1806
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1868'
                                      ...  msg=Current alarm faultId is equal 1868
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4352'
                                      ...  msg=Current alarm faultId is equal 4352
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4383'
                                      ...  msg=Current alarm faultId is equal 4383
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6911'
                                      ...  msg=Current alarm faultId is equal 6911
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4590'
                                      ...  msg=Current alarm faultId is equal 4590
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4681'
                                      ...  msg=Current alarm faultId is equal 4681
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '2087'
                                      ...  msg=Current alarm faultId is equal 2087
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1815'
                                      ...  msg=Current alarm faultId is equal 1815
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '248'
                                      ...  msg=Current alarm faultId is equal 248
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '250'
                                      ...  msg=Current alarm faultId is equal 250
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6502'
                                      ...  msg=Current alarm faultId is equal 6502
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1850'
                                      ...  msg=Current alarm faultId is equal 1850
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4539'
                                      ...  msg=Current alarm faultId is equal 4539
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4663'
                                      ...  msg=Current alarm faultId is equal 4663
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '9100'
                                      ...  msg=Current alarm faultId is equal 9100
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4261'
                                      ...  msg=Current alarm faultId is equal 4261
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '7516'
                                      ...  msg=Current alarm faultId is equal 7516
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '23'
                                      ...  msg=Current alarm faultId is equal 23
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '2056'
                                      ...  msg=Current alarm faultId is equal 2056
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1907'
                                      ...  msg=Current alarm faultId is equal 1907
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1981'
                                      ...  msg=Current alarm faultId is equal 1981
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1920'
                                      ...  msg=Current alarm faultId is equal 1920
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4547'
                                      ...  msg=Current alarm faultId is equal 4547
    END
    ${history_alarms}=    coam.get_historic_alarms    timeout=${300}    connection=${connection}    load_history=${True}
    FOR  ${fault}  IN  @{history_alarms}
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '10'
                                      ...  msg=Current alarm faultId is equal 10
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4527'
                                      ...  msg=Current alarm faultId is equal 4527
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1900'
                                      ...  msg=Current alarm faultId is equal 1900
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6450'
                                      ...  msg=Current alarm faultId is equal 6450
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '16'
                                      ...  msg=Current alarm faultId is equal 16
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1806'
                                      ...  msg=Current alarm faultId is equal 1806
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1868'
                                      ...  msg=Current alarm faultId is equal 1868
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4352'
                                      ...  msg=Current alarm faultId is equal 4352
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4383'
                                      ...  msg=Current alarm faultId is equal 4383
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6911'
                                      ...  msg=Current alarm faultId is equal 6911
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4590'
                                      ...  msg=Current alarm faultId is equal 4590
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4681'
                                      ...  msg=Current alarm faultId is equal 4681
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '2087'
                                      ...  msg=Current alarm faultId is equal 2087
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1815'
                                      ...  msg=Current alarm faultId is equal 1815
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '248'
                                      ...  msg=Current alarm faultId is equal 248
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '250'
                                      ...  msg=Current alarm faultId is equal 250
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6502'
                                      ...  msg=Current alarm faultId is equal 6502
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1850'
                                      ...  msg=Current alarm faultId is equal 1850
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4539'
                                      ...  msg=Current alarm faultId is equal 4539
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4663'
                                      ...  msg=Current alarm faultId is equal 4663
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '9100'
                                      ...  msg=Current alarm faultId is equal 9100
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4261'
                                      ...  msg=Current alarm faultId is equal 4261
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '7516'
                                      ...  msg=Current alarm faultId is equal 7516
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '23'
                                      ...  msg=Current alarm faultId is equal 23
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '2056'
                                      ...  msg=Current alarm faultId is equal 2056
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1907'
                                      ...  msg=Current alarm faultId is equal 1907
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1981'
                                      ...  msg=Current alarm faultId is equal 1981
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1920'
                                      ...  msg=Current alarm faultId is equal 1920
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4547'
                                      ...  msg=Current alarm faultId is equal 4547
    END
    [Teardown]    logout    connection=${connection}

Get and check node detail info
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}    ${node_type}=gnb
    ...    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
    ...    ${gnb_index}=${0}    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    Run Keyword If    '${node_type}'=='gnb'
    ...    Get and check bts detail info    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}
    ...    du_index=${du_index}
    ...    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    ...    check_tl_type_timeout=${check_tl_type_timeout}    check_tl_type_retry_interval=${check_tl_type_retry_interval}
    ...    ELSE IF    '${node_type}'=='enb'
    ...    Get and check enb detail info    connection=${connection}    timeout=${timeout}    retry_interval=${retry_interval}
    [Teardown]    logout    connection=${connection}

Get and check bts detail info
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${retry_interval}=5 sec    ${du_index}=0
    ...    ${is_x2_check_from_gnb_needed}=${True}    ${check_tl_type_timeout}=5s    ${check_tl_type_retry_interval}=1s
#    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
#    Set Suite Variable    ${detected_info}
    ${is_asod_asoe_asof}    If ASOD or ASOE or ASOF testline    du_index=${du_index}    timeout=${check_tl_type_timeout}
    ...    retry_interval=${check_tl_type_retry_interval}
    Run keyword if    ${is_asod_asoe_asof}==${False}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check basebandModule status    connection=${connection}
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check systemModule status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check radioModule status    connection=${connection}
    ${gnb_type}    Get gNbType SA or NSA via rest api    connection=${connection}
    ${is_x2_check_from_gnb_needed_flag} 	  Set Variable If	  '${gnb_type}'=='SA'    ${False}    ${is_x2_check_from_gnb_needed}
    Run keyword if    ${is_x2_check_from_gnb_needed_flag}==${True}
    ...    Wait until keyword succeeds    ${timeout}    ${retry_interval}    COAM Check X2 link status from GNB
    ...    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check cell status    connection=${connection}

Get and check enb detail info
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=enblte    ${retry_interval}=5 sec
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check enb basebandModule status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check enb systemModule status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check enb radioModule status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    ${retry_interval}    Check enb cell status    connection=${connection}

Check systemModule status
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_systemModules}    Set variable    ${detected_info['systemModules']}
    ${count_systemModules}    Get length    ${list_systemModules}
    Should be true    ${count_systemModules}>=${1}    msg=Check systemModule status failed as total systemModule number is less than 1
    FOR  ${systemModule}  IN  @{list_systemModules}
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current systemModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current systemModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current systemModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['usageState']}    Active
                                      ...  msg=Current systemModule usageState is not in Active status
    END

Check basebandModule status
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_basebandModules}    Set variable    ${detected_info['basebandModules']}
    ${count_basebandModules}    Get length    ${list_basebandModules}
    Should be true    ${count_basebandModules}>=${1}    msg=Check basebandModule status failed as total basebandModule number is less than 1
    FOR  ${basebandModule}  IN  @{list_basebandModules}
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current basebandModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current basebandModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current basebandModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['usageState']}    Active
                                      ...  msg=Current basebandModule usageState is not in Active status
    END

Check radioModule status
    [Arguments]    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_radioModules}    Set variable    ${detected_info['radioModules']['rmod']}
    ${count_radioModules}    Get length    ${list_radioModules}
    Should be true    ${count_radioModules}>=${1}    msg=Check radioModule status failed as total radioModule number is less than 1
    FOR  ${radioModule}  IN  @{list_radioModules}
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['usageState']}    Active
                                      ...  msg=Current radioModule usageState is not in Active status
    END

Check cell status
    [Arguments]    ${cell_type}=nr    ${connection}=GNB_OAM    ${timeout}=30
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
#    FOR  ${cell}  IN  @{cell_info}
#        Run keyword and continue on failure    Should be equal as strings    ${cell}[status][administrativeState]    ${unlocked}
#                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
#        Run keyword and continue on failure    Should be equal as strings    ${cell}[status][operationalState]    ${enabled}
#                                      ...  msg=Current radioModule operationalState is not in enabled status
#        Run keyword and continue on failure    Should be equal as strings    ${cell}[status][proceduralStatus]    configured
#                                      ...  msg=Current radioModule proceduralStatus is not in configured status
#        Run keyword and continue on failure    Should be equal as strings    ${cell}[status][usageState]    Active
#                                      ...  msg=Current radioModule usageState is not in Active status
#    END
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    ${enabled}
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword    Should be equal as strings    ${cell}[status][proceduralStatus]    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword    Should be equal as strings    ${cell}[status][usageState]    Active
                                      ...  msg=Current radioModule usageState is not in Active status
    END

Check enb systemModule status
    [Arguments]    ${connection}=enblte
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_systemModules}    Set variable    ${detected_info['systemModules']}
    ${count_systemModules}    Get length    ${list_systemModules}
    Should be true    ${count_systemModules}>=${1}    msg=Check systemModule status failed as total systemModule number is less than 1
    FOR  ${systemModule}  IN  @{list_systemModules}
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current systemModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current systemModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current systemModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${systemModule['status']['usageState']}    Active
                                      ...  msg=Current systemModule usageState is not in Active status
    END

Check enb basebandModule status
    [Arguments]    ${connection}=enblte
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_basebandModules}    Set variable    ${detected_info['basebandModules']}
    ${count_basebandModules}    Get length    ${list_basebandModules}
    Should be true    ${count_basebandModules}>=${1}    msg=Check basebandModule status failed as total basebandModule number is less than 1
    FOR  ${basebandModule}  IN  @{list_basebandModules}
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current basebandModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current basebandModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current basebandModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${basebandModule['status']['usageState']}    Active
                                      ...  msg=Current basebandModule usageState is not in Active status
    END

Check enb radioModule status
    [Arguments]    ${connection}=enblte
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    Unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${detected_info}    coam.get_detected_hw_info    connection=${connection}
    Set Suite Variable    ${detected_info}
    @{list_radioModules}    Set variable    ${detected_info['radioModules']['rmod']}
    ${count_radioModules}    Get length    ${list_radioModules}
    Should be true    ${count_radioModules}>=${1}    msg=Check radioModule status failed as total radioModule number is less than 1
    FOR  ${radioModule}  IN  @{list_radioModules}
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['administrativeState']}    ${unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['operationalState']}    ${enabled}
                                      ...  msg=Current radioModule operationalState is not in enabled status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['proceduralStatus']}    configured
                                      ...  msg=Current radioModule proceduralStatus is not in configured status
        Run keyword and continue on failure    Should be equal as strings    ${radioModule['status']['usageState']}    Active
                                      ...  msg=Current radioModule usageState is not in Active status
    END

Check enb cell status
    [Arguments]    ${cell_type}=lte    ${connection}=enblte    ${timeout}=30
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${unlocked}    Set Variable If    ${result}    Unlocked    unlocked
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    ${count_cell}    Get length    ${cell_info}
    Should be true    ${count_cell}>=${1}    msg=Check cell status failed as total cell number is less than 1
#    FOR  ${cell}  IN  @{cell_info}
#        Run keyword and continue on failure    Should be equal as strings    ${cell}[status][administrativeState]    ${unlocked}
#                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
#        Run keyword and continue on failure    Should be equal as strings    ${cell}[status][operationalState]    ${enabled}
#                                      ...  msg=Current radioModule operationalState is not in enabled status
##        Run keyword and continue on failure    Should be equal as strings    ${cell}['status']['proceduralStatus']    configured
##                                      ...  msg=Current radioModule proceduralStatus is not in configured status
##        Run keyword and continue on failure    Should be equal as strings    ${cell}['status']['usageState']    Active
##                                      ...  msg=Current radioModule usageState is not in Active status
#    END
    FOR  ${cell}  IN  @{cell_info}
        Run keyword    Should be equal as strings    ${cell}[status][administrativeState]    ${unlocked}
                                      ...  msg=Current radioModule administrativeState is not in Unlocked status
        Run keyword    Should be equal as strings    ${cell}[status][operationalState]    ${enabled}
                                      ...  msg=Current radioModule operationalState is not in enabled status
#        Run keyword and continue on failure    Should be equal as strings    ${cell}['status']['proceduralStatus']    configured
#                                      ...  msg=Current radioModule proceduralStatus is not in configured status
#        Run keyword and continue on failure    Should be equal as strings    ${cell}['status']['usageState']    Active
#                                      ...  msg=Current radioModule usageState is not in Active status
    END

Get software versions
    [Arguments]    ${connection}=GNB_OAM
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${passive_version}    Set Variable    ${software}[Passive SW version]
    ${planned_version}    Set Variable    ${software}[Planned SW version]
    [Return]    ${activate_version}    ${passive_version}    ${planned_version}

Get upgrade report
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    coam.get_sw_update_report    target_file_name=${local_package_path}/${update_report_file}    connection=${connection}
    csn.Connect to    ${host_addr}    ${host_username}    ${host_password}    alias=TESTPC
    csn.send command
    ...    command=cat ${local_package_path}/${update_report_file} |grep -n "Software Build Download" |tail -1 |cut -d ":" -f1
    ...    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    ${line_number}    convert to integer   ${output}
    csn.send command    command=tail -n \+${line_number} ${local_package_path}/${update_report_file}    connection=TESTPC
    ${output}    csn.read output    connection=TESTPC
    should not contain any    ${output}    error    failed
    [Teardown]    Run Keywords    logout    connection=${connection}    AND
    ...    Run Keyword And Ignore Error    csn.disconnect    connection=TESTPC

rollback_build
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    coam.rollback_software    timeout=2400    connection=${connection}
    [Teardown]    logout    connection=${connection}

check gNB Staus Air
    COAM Wait for gnb ready and cell setup

login
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb
    ...    ${enb_index}=${0}
    Run Keyword If    '${node_type}'=='gnb'
    ...    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ...    ELSE IF    '${node_type}'=='enb'
    ...    Connect to eNB coam via ssl    connection=${connection}    enb_index=${enb_index}

logout
    [Arguments]    ${connection}=GNB_OAM
    COAM Teardown gnb connections    connection=${connection}

tearDown for logout
    [Arguments]    ${connection}=GNB_OAM
    FOR    ${count}    IN RANGE    2
        logout    connection=${connection}
    END

reset node
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    coam.reset_site    connection=${connection}
    [Teardown]    logout    connection=${connection}

upgrade build
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    ...    ${upgrade_build}=${package_name}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    coam.update_software    sw_package=${local_package_path}/${upgrade_build}    timeout=7200    connection=${connection}
    [Teardown]    logout    connection=${connection}

Get current version to check
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${current_activate_version}    ${current_passive_version}    ${current_planned_version}    Get software versions
    ...    connection=${connection}
    Set Suite Variable    ${current_activate_version}
    Set Suite Variable    ${current_passive_version}
    Set Suite Variable    ${current_planned_version}
    [Teardown]    logout    connection=${connection}

Check if lower version between active and passive via ssh
    [Arguments]
    ...    ${gnb_index}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ${active_version}    Get sagnb version for selenium    host=${host}   username=${username}   password=${password}
    ${passive_version}    Get stb sagnb version for selenium    host=${host}   username=${username}   password=${password}
    ${active_year1}     set variable    ${active_version.split('R')[0][-2:]}
    ${active_sub_index1}     set variable    ${active_version.split('R')[1]}
    ${active_year}    Convert To Integer    ${active_year1}
    ${active_sub_index}    Convert To Integer    ${active_sub_index1}
    ${passive_year1}     set variable    ${passive_version.split('R')[0][-2:]}
    ${passive_sub_index1}     set variable    ${passive_version.split('R')[1]}
    ${passive_year}    Convert To Integer    ${passive_year1}
    ${passive_sub_index}    Convert To Integer    ${passive_sub_index1}
    IF    (${active_year} > ${passive_year}) or (${active_year} == ${passive_year} and (${active_sub_index} > ${passive_sub_index}))
        Set Suite Variable    ${need_rollback_first_flag}    ${True}
    ELSE
        Set Suite Variable    ${need_rollback_first_flag}    ${False}
    END

Get stb sagnb version for selenium
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/stb/TargetBD*xml   connection=release_info
    ${sw_version}     set variable    ${info.split('_')[1]}
    set suite variable    ${sw_version}
    [Return]    ${sw_version}
    [Teardown]   csn.Disconnect   connection=release_info

Check if Upgrade Successfully via ssh
    [Arguments]
    ...    ${gnb_index}
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ${after_activate_version}    Get sagnb release    host=${host}   username=${username}   password=${password}
    ${after_passive_version}    Get stb sagnb release    host=${host}   username=${username}   password=${password}
    Should Be Equal    ${version}    ${after_activate_version}
    Should Be Equal    ${current_activate_version}    ${after_passive_version}

Get stb sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/stb/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    set suite variable    ${release_info}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Check if Upgrade Successfully
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${after_activate_version}    ${after_passive_version}    ${after_planned_version}    Get software versions
    ...    connection=${connection}
    Should Be Equal    ${version}    ${after_activate_version}
    Should Be Equal    ${current_activate_version}    ${after_passive_version}
    [Teardown]    logout    connection=${connection}

Check if rollback Successfully
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${after_activate_version}    ${after_passive_version}    ${after_planned_version}    Get software versions
    ...    connection=${connection}
    Should Be Equal    ${current_passive_version}    ${after_activate_version}
    Should Be Equal    ${current_activate_version}    ${after_passive_version}
    [Teardown]    logout    connection=${connection}

Check if reset Successfully
    [Arguments]     ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    ${after_activate_version}    ${after_passive_version}    ${after_planned_version}    Get software versions
    ...    connection=${connection}
    Should Be Equal    ${current_passive_version}    ${after_passive_version}
    Should Be Equal    ${current_activate_version}    ${after_activate_version}
    [Teardown]    logout    connection=${connection}

Connect to eNB coam via ssl
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${enb_index}=${0}
    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}
    Log to console    \nINFO:connect to eNB successfully

modify parmeters via interface
    [Arguments]     ${parameters_to_update}    ${connection}=GNB_OAM    ${gnb_index}=${0}    ${node_type}=gnb    ${enb_index}=${0}
    wait until keyword succeeds     10min    30s
    ...    login    node_type=${node_type}    connection=${connection}    gnb_index=${gnb_index}    enb_index=${enb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${300}
    ...    connection=${connection}
    sleep    5
    [Teardown]    logout    connection=${connection}

capture syslog via gnb_logs tool
    [Arguments]     ${gnb_index}=${0}    ${duration}=2
    ...    ${gnb_ip}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds     10min    30s    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute_gnb_logs
    sleep    2s
    ${start_capture_command}    Catenate
    ...    ./gnb_logs ${gnb_ip} -c -s ${duration}
    csn.send command
    ...    command=chmod +x ${download_version_file_path}/gnb_logs
    ...    connection=ute_gnb_logs
    sleep    2s
    csn.send command
    ...    command=cd ${download_version_file_path};${start_capture_command}    timeout=600
    ...    connection=ute_gnb_logs

Stop capture syslog via gnb_logs tool
#    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
#    ...    username=${tl.test_pc.default_ssh_connection_details.username}
#    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute_gnb_logs
    sleep    2s
#    ${durations}    Convert To Integer    ${duration}
#    ${durations}    Evaluate    ${durations}
#    ${stop_capture}    Wait Until Keyword Succeeds    2x    10s
#    ...    csn.read output until    finished    timeout=${durations}   connection=ute_gnb_logs
    [Teardown]    csn.disconnect     connection=ute_gnb_logs

remove syslog files
    wait until keyword succeeds     10min    30s    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...    username=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}    alias=ute
    sleep    2s
    csn.send command
    ...    command=rm -rf ${download_version_file_path}/*.zip
    ...    connection=ute
    [Teardown]    csn.disconnect     connection=ute
