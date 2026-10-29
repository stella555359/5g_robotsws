*** Settings ***
Documentation     author: wuxia
...               Group: 5G_PZ_MMW_HZ_3_SG
...               contact: xia.wu@nokia-sbell.com

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Library           taf.selenium.gnb.oam.coam.cu   WITH NAME   coam_cu
Library           taf.gnb.oam.coam.cu    WITH NAME   cu
Library           taf.sbts.oam.coam.admin   WITH NAME   coam
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Library           testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/get_bts_info.py  WITH NAME    lib
Library           taf.transport.ssh    WITH NAME    csn
Library           OperatingSystem
Library           Collections
Library           taf.pdu
Library           String
Library           Process
Library 	      DateTime


*** Variables ***
${DU_OAM_IP}            ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${CU_OAM_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}

${WEBUI_URL}        https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}   ${tl.gnbs[0].cu.oam_http_connection_details.password}

${scf_name}              scf_5GC001576_BA_cu.xml
${tmp_log_dir}     /home/ute/log
${scf_dir}           /opt/transformers.dynamic.nsn-net.net/gnb_configuration/7_5_UTE5G401T903/5GC001576-BA/

*** Keywords ***
5GC001576_Common Suite Setup for CU
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${tmp_log_dir}
    5GC001576_COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}
    Create directory    ${epc_log_path}

5GC001576_Common Suite Teardown for CU
    Run Keyword And Ignore Error    AdminCli disconnection and Test teardown

5GC001576_Generate suite log path
    [Arguments]    ${timeout}=1min
    ${ts_name}=    Replace String    string=${SUITE NAME}    search_for=${SPACE}    replace_with=_
    wait until keyword succeeds    ${timeout}    2sec    Connect to CU admin
    ${sw_version} =     cu.get_active_software_version
    ${suite_log_path}    Join path    ${TS_LOG_PATH_BASE}    ${sw_version}    TS_${ts_name}
    Set Suite Variable    ${SUITE_LOG_PATH}    ${suite_log_path}
    Create directory    ${SUITE_LOG_PATH}
    cu.disconnect

5GC001576_COAM Create log directory
    [Arguments]  ${is_set_to_test_case_level}=${True}    ${timeout}=1min
    5GC001576_Generate suite log path    timeout=${timeout}
    Run keyword if  ${is_set_to_test_case_level}
    ...    Run keywords    Generate test case log path    AND
    ...    Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
    ...    ELSE    Set suite variable    ${LOG_PATH}    ${SUITE_LOG_PATH}


Connect to CU admin
    cu.connect to     host=${CU_OAM_IP}
    ...               username=${WEBUI_USER}
    ...               password=${WEBUI_PASSWORD}
    ...               port=${EMPTY}
    ...               cu_version=cuoam_19b
    ...               secure=${True}


Precondition: All cells can be on air
    log to console  \n***** Precondition: All cells can be on air *****
    Connect to CU admin
    Check If BTS Is OnAir

AdminCli disconnection and Test teardown
    [Documentation]
    ...     Disconnects connection to gNB ADMIN and collect snapshot if any TC failed
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Ignore Error    cu.disconnect

Check If BTS Is OnAir
    Cell status should be Enabled
    X2 link status should be available

Cell status should be Enabled
     ${result_cell_status}=     cu.get_cells_statuses
     ${operability_state}=     set variable    ${result_cell_status[0]['operational_state']}
     should be equal       ${operability_state}     enabled

Cell status should be Disabled
     ${result_cell_status}=     cu.get_cells_statuses
     ${operability_state}=     set variable    ${result_cell_status[0]['operational_state']}
     should be equal       ${operability_state}     disabled

X2 link status should be available
    ${result_X2_link}=      cu.get_x2_links_info
    ${availability_state}=   set variable  ${result_X2_link['created'][0]['x2_link_status']}
    should be equal    ${availability_state}    available

Check Active Alarm in WebEM
     [Arguments]    ${alarm_filter}
     ${active_alarm}=    coam_cu.get_active_alarm_info    alarm_filter=${alarm_filter}
     ${alarm_num}=    get length    ${active_alarm}
     should be true    ${alarm_num}!=0
     [Return]    ${active_alarm}

CU WebEM Login
     coam_cu.enable_virtual_display
     ${version}    Get version based on stream version
     coam_cu.login   url=${WEBUI_URL}
     ...             browser=Firefox
     ...             version=${version}

Get version based on stream version
    Connect to Common Unit Master
    ${cmd_get_sw_file_name}    Set variable    ls /ffs/run |grep TargetBD.*.xml |grep -v .xml.
    ${sw_file_name}    ssh.execute    command=${cmd_get_sw_file_name}    connection=ASIK Master
    @{sw_version_list}    Get regexp matches    ${sw_file_name}    TargetBD_(.*?)_    1
    ${sw_version}    Strip string    ${sw_version_list[0]}
    #${program_version}    Replace string using regexp    string=${sw_version}    pattern=SBTS|5G    replace_with=${EMPTY}
    ssh.disconnect  connection=ASIK Master
    [Return]    ${sw_version}

CU WebEM Logout
     coam_cu.logout

