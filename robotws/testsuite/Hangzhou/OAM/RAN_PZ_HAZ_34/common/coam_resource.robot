*** Settings ***
Documentation
...   author: shasha.liu
...   contact: shasha.liu@nokia-sbell.com

#Library           taf.transport.ssh    WITH NAME    csn
Library           taf.pdu
Library           String
Library           Process
Library           OperatingSystem
Library           Collections
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
#webui
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
${WEBUI_USER}               Nemuadmin
${WEBUI_PASSWORD}           nemuuser

#bts id
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}

#UTE VM
${host_addr}                ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}            ${tl.test_pc.default_ssh_connection_details.username}
${host_password}            ${tl.test_pc.default_ssh_connection_details.password}

#gNB PB
${PDU_type}                  FACOM
${powerstation_ip}           ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${powerstation_port}         ${4001}
${powerstation_asik_port}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

#RU PB
${powerstation_ip_RU}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${powerstation_port_RU}       ${4001}
${powerstation_asik_port_RU}  ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

#ssh gNB
${asik_addr}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}             toor4nsn
${asik_password}             oZPS0POrRieRtu

#SWITCH Dtor
${SWITCH_IP_Dtor}            ${tl.switches[0].default_ssh_connection_details.addr}
${SWITCH_Username_Dtor}      ${tl.switches[0].default_ssh_connection_details.username}
${SWITCH_Password_Dtor}      ${tl.switches[0].default_ssh_connection_details.password}
${SWITCH_Port_Dtor}          ${tl.switches[0].default_ssh_connection_details.port}

#SWITCH Mtor
${SWITCH_IP_Mtor}            ${tl.switches[1].default_ssh_connection_details.addr}
${SWITCH_Username_Mtor}      ${tl.switches[1].default_ssh_connection_details.username}
${SWITCH_Password_Mtor}      ${tl.switches[1].default_ssh_connection_details.password}
${SWITCH_Port_Mtor}          ${tl.switches[1].default_ssh_connection_details.port}

#TBD
${fct_slave_IP}              192.168.253.17
${fsp_ip_loner}              192.168.253.22
${log_dir}                   /tmp/node_
${log_name}                  /tmp/startup_DEFAULT.log

#Kongfu Netact info
${Netact_url}      https://kungfulbwas.kungfu.srnhz.nsn-rdnet.net
${Netact_user_name}    omc
${Netact_pwd}     Nokia126_
${NetAct_dmgr}     ${tl.nms.addr}

#qin Netact info
${Netact_url_qin}      https://na19lbwas.qin1.srnhz.nsn-rdnet.net
${Netact_pwd_qin}     Nokia123!


*** Keywords ***
WEBUI Login
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}
    run keyword if     ${virtual_enable}     run keyword and ignore error    selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login
    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    run keyword and ignore error      selenium_coam.disable_message_box
    run keyword and ignore error      selenium_coam.disable_screen_lock
    sleep    10s
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If    '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

WEBUI Logout
    [Arguments]     ${virtual_disable}=${TRUE}
    selenium_coam.logout
    run keyword if      ${virtual_disable}    run keyword and ignore error    selenium_coam.disable_virtual_display

Check ABIL is UP
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    #should be equal      &{output}[Availability status]     Online
    should be equal      ${output}[Procedural status]     configured

Check ASIK State
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output_ASIK}    selenium_coam.get_asik_info
    ${output_1}    set variable    ${output_ASIK}[Status]
    should be equal      ${output_1}[Administrative state]    Unlocked
    #should be equal      &{output_1}[Availability status]     Online
    should be equal      ${output_1}[Procedural status]     configured

Check ASIB State
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    ${output_ASIB}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIB}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled

Check ASIK is UP
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    run keyword and ignore error    selenium_coam.logout
    sleep  2s
    run keyword and ignore error    selenium_coam.login
    ...    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/    username=${WEBUI_USER}    password=${WEBUI_PASSWORD}
    Run Keyword and Ignore Error    selenium_coam.refresh_page
    ${is_startup_window_exist}=    Run Keyword And Ignore Error    selenium_coam.start_up_view_window_exists
    Run Keyword If   '${is_startup_window_exist[-1]}'=='True'    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    ${P_name_smod}    set variable    ${output_tmp}[Product name]
    run keyword if    '${P_name_smod}' == 'ASIK AirScale Common'    Check ASIK State
    run keyword if    '${P_name_smod}' == 'ASIB AirScale Common'    Check ASIB State

Check Cell is UP
    WEBUI Login
    ${output_tmp}    selenium_coam.get_cell_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    #should be equal      &{output}[Availability status]     Online
    should be equal      ${output}[Procedural status]     configured

check gNB Staus onAir
    [Arguments]    ${dist_name}    ${search_text}
    ${status}    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${search_text}
    should be equal    ${status}    onAir

check RU STATUS
#    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_ru_info
    ${RU_info}    set variable    ${output_tmp}[Status]
    #connect to gnb coam via ssl    gnb_index=${0}    connection=GNB_OAM
    #${result}    get release flag    connection=GNB_OAM
    #${led_status}       set variable if      ${result}    Enabled    enabled
    should match regexp    ${RU_info}[Operational state]    enabled
    #should match regexp    &{RU_info}[Availability status]    Online
    should match regexp    ${RU_info}[Administrative state]    Unlocked
    should match regexp    ${RU_info}[Procedural status]    configured

check SW version
    [Documentation]     output planned/active/passive version
    [Arguments]      ${version_type}
    ${version}    selenium_coam.check_current_software_version
    ${output}    set variable    ${version}[${version_type}]
    [Return]      ${output}    ${version}

get CIT build
    [Documentation]   get CIT build from AF_PATH.
    ...    Author: shasha.liu@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...    *RETURN VALUE*
    ...    SW build with three digital segments mode
    ...    Example
    ...    | ${CIT_build} | get CIT build |
    @{Location_array}=    Split String    ${AF_PATH}     separator=/
    [Return]  ${Location_array}[-2]

Capture journal log
    [Arguments]    ${cmd}    ${alias}
    [Documentation]    Capture journal log used journal command
    ${output}    csn.execute    ${cmd}    connection=${alias}

Backup commission file via WebUI
    log to console    Backup commission file via WebUI
    ${commission_file}      selenium_coam.backup_bts_site_configuration    download_timeout=600
    sleep    5s
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    csn.send_command    command=cd ${vm_path};mkdir ${create_backup_dir}    connection=VM
    set suite variable    ${backup_scf_path}    ${vm_path}${create_backup_dir}
    run process    scp -r ${commission_file} ${backup_scf_path}    shell=yes
    csn.send_command    command=cd ${backup_scf_path};ls    connection=VM
    ${backup_scf_file_1}    csn.read output    connection=VM
    @{backup_scf_list}    Split Command Line    ${backup_scf_file_1}
    set suite variable    ${backup_scf_file}    ${backup_scf_list}[0]
    csn.disconnect    connection=VM
    sleep    3s
    Confirm backup scf file

Confirm backup scf file
    csn.connect to    hostname=${host_addr}    username=${host_username}    password=${host_password}    alias=VM
    Directory Should Exist    ${backup_scf_path}
    List Files In Directory    ${backup_scf_path}
    ${backup_scf_path_file}    OperatingSystem.join path    ${backup_scf_path}    ${backup_scf_file}
    File Should Exist    ${backup_scf_path_file}
    set suite variable    ${backup_scf_path_file}
    log to console    SCF file Find!!!!!!
    csn.disconnect    connection=VM

Validate and activate and check activate plan status
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    #sleep    10s
    #selenium_coam.check_activate_plan_status
    sleep    5s

Check ASIK status with command
    csn.connect_to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=gNB
    sleep    5s
    #csn.send_command    command=export PYTHONPATH=/opt/hwmt/python;python /opt/hwmt/python/hwapi/AdetS.py -s    connection=gNB
    csn.send_command     command=export PYTHONPATH=/opt/hwmt/python;python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004  connection=gNB
    sleep    15s
    ${output1}    csn.read output    connection=gNB
    Should Match Regexp    ${output1}    0x10.*FSM1_FCT.*ready
    Should Match Regexp    ${output1}    0x12.*FSM1_FSP1.*ready
    Run Keyword And Ignore Error    csn.disconnect    connection=gNB

Turn Off PDU
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}    ${Port_Number}
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=${pdu_type}    port=${pdu_port}
    taf.pdu.power_off    port=${Port_Number}
    sleep   15s
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    should be equal    ${state}    off
    sleep    30s

Turn On PDU
    [Arguments]    ${pdu_type}    ${pdu_ip}    ${pdu_port}    ${Port_Number}
    [Documentation]    5gNB is turned on and check 5GNB is in configured state.
    taf.pdu.Setup Pdu    host=${pdu_ip}    model=${pdu_type}    port=${pdu_port}
    taf.pdu.power_on    port=${Port_Number}
    sleep    15s
    ${state}    taf.pdu.get_port_status    port=${Port_Number}
    should be equal    ${state}    on

#common keyword for test suite and test cases
cOAM Common Suite Setup
    robot_common_operations.Common Suite Setup
    set suite variable      ${OUTPUT_PATH}    %{HOME}/workspace/CIT/Master/Case_Logs
#   Run Keyword And Ignore Error    run process    chmod -R 777 ${OUTPUT_PATH}    shell=yes
    Run Keyword And Ignore Error    run process    taskkill /f /im chromedriver.exe    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True
    Run Keyword And Ignore Error    run process    taskkill /f /im firefoxdriver.exe    shell=True
    Run Keyword And Ignore Error    run process    ps -ef|grep firefox | awk '{print $2}' |xargs kill -9    shell=True
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Logout
    sleep   10s
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Login

    ${output}    ${version}     check SW version     version_type=Active
#    @{result}    string.split string    ${output}    separator=_
#    ${result1}    convert to integer    @{result}[4]
#    ${result2}    convert to integer    @{result}[3]
#    ${result3}    convert to integer    @{result}[2]
#    ${SW_vesion_tmp}    set variable      ${result3}.${result2}.${result1}
#    set suite variable    ${Active_SW_version}    ${SW_vesion_tmp}
    set suite variable    ${Active_SW_version}    ${output}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Logout


    ${OUTPUT_PATH_with_SW}=    join path     ${OUTPUT_PATH}     ${asik_addr}__${Active_SW_version}
    set suite variable     ${OUTPUT_PATH_with_SW}

    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}

cOAM Common Test Setup
    [Documentation]    this keyword create case name directory path as ${OUTPUT_DIR}//${SUITE_LOG_DIRECTORY}//
    robot_common_operations.Common Case Setup
    ${TEST_LOG_DIR}=    Get A Directory
    Set Test Variable    ${TEST_LOG_DIR}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TEST_LOG_DIR}

cOAM Common Suite Teardown
    robot_common_operations.Common Suite Teardown
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Login
    ${flag_tmp}   ${scf_file}    Run Keyword And Ignore Error    selenium_coam.backup_bts_site_configuration   download_timeout=600
    sleep    5s
    Run Keyword And Ignore Error    set suite variable    ${scf_file}
    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${scf_file}
    Run Keyword And Ignore Error    OperatingSystem.Copy File    ${scf_file}    ${SAVE LOG DIRECTORY}

    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    1min    20s    WEBUI Logout

    #Run Keyword If    '${SUITE STATUS}' == 'FAIL'    Run Keyword And Ignore Error    Save Snapshot for Suite Teardown

Get A Directory
    [Arguments]    @{paths}
    [Documentation]    Create a specific directory under suite log directory and ${dir_name}
    ${log_path}=    _Get Log Path
    ${directory_path}=    OperatingSystem.Join Path    ${log_path}    @{paths}
    ${directory_path}=    Replace String    ${directory_path}    ${SPACE}    _
    Create Directory    ${directory_path}
    [Return]    ${directory_path}

_Get Log Path
    ${result}=    Run Keyword And Ignore Error    Variable Should Exist    ${TEST NAME}
    ${log_path}=    Run Keyword If    "${result[0]}"=="PASS"    _Get Case Log Path
    ...    ELSE    _Get Suite Log Path
    [Return]    ${log_path}

_Get Suite Log Path
    ${concated_suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${suite_log_path}=    OperatingSystem.Join Path    ${OUTPUT_PATH_with_SW}    ${timestamp}    TESTSUITE__${concated_suite_name}
    [Return]    ${suite_log_path}

_Get Case Log Path
    ${concated_suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_test_name}=    Replace String    ${TEST NAME}    ${SPACE}    _
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${case_log_path}=    OperatingSystem.Join Path    ${OUTPUT_PATH_with_SW}    ${timestamp}
    ...    TESTSUITE__${concated_suite_name}    TESTCASE__${concated_test_name}
    [Return]    ${case_log_path}
