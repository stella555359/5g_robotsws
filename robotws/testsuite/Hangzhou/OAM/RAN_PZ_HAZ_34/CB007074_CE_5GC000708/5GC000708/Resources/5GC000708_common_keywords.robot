*** Settings ***
Documentation
...    author: wang dali
...    contact: dali.wang@nokia-sbell.com
...    squad group: SG_07

Library    OperatingSystem
Library    Collections
Library    String
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.transport.ssh    WITH NAME       ssh
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library     taf.config.testline    WITH NAME    testline
Library    taf.analyzer.pcap   WITH NAME    pcap
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource   ..${/}..${/}..${/}common${/}taf_coam.robot
Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot

*** Variables ***
${TS_CASE_LOG_PATH}    /tmp

                     
*** Keywords ***
## GNB BTS Precondition ##
Common Suite Setup for COAM
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    COAM WEBUI Login   display=${${DEBUG}}
    COAM WEBUI Whether Close Start Up View Window
    COAM Login
    COAM Backup SCF
    ${is_cells_onair}   Run Keyword and Return Status   COAM Check All Cells Onair
    Log to Console   Check all cells should be onair result is ${is_cells_onair}
    Run Keyword and Ignore Error    Perform sub-feature SCF    feature_name=708
	wait until keyword succeeds    15min    1min    COAM Check All Cells Onair
	COAM Logout

Common Suite Teardown for COAM
#    COAM WEBUI Whether Close Start Up View Window
    Check Extra Reset From Blackbox
    run keyword and ignore error   COAM Login
    run keyword and ignore error   COAM SCF Commission
    run keyword and ignore error    COAM WEBUI Logout   display=${${DEBUG}}
    Run Keyword and Ignore Error   COAM Logout
#    Save or Remove logs
    CI_interface.Common Case Teardown
    
Start To Capture Wireshark Logs
    [Arguments]    ${interface}    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.connect to    hostname=${asik_addr}    username=${asik_username}    password=${asik_password}    alias=${ALIAS_ASIK}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${ALIAS_ASIK}

Stop and download wiresharkLog
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK}
    sleep    3
    Create directory    ${epc_log_path}
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK}
    sleep    3
    
Analysis wireshark log to check RRC_Release with redirection
    [Arguments]     ${logname}
    cap.read_cap      cap_file=${epc_log_path}${logname}     display_filter=ngap
    ${releaserequest}     Catenate   ngap.procedureCode == 42 and ip.src == ${WEBUI_ADDR} and ngap.radioNetwork == 41
    cap.Check Expression    condition_expression=${releaserequest}
    ${releasecommand}     Catenate   ngap.procedureCode == 41 and ip.dst == ${WEBUI_ADDR} and ngap.radioNetwork == 41
    cap.Check Expression    condition_expression=${releasecommand}
    ${releasecomplete}     Catenate   ngap.procedureCode == 41 and ip.src == ${WEBUI_ADDR}
    cap.Check Expression    condition_expression=${releasecomplete}
    
Analysis wireshark log to check attach successfully
    [Arguments]     ${logname}
    cap.read_cap      cap_file=${epc_log_path}/${logname}    display_filter=ngap
    ${req}     Catenate   ngap.procedureCode == 14 and  ip.dst == ${WEBUI_ADDR}
    cap.Check Expression    condition_expression=${req}
    ${rsp}     Catenate   ngap.procedureCode == 14 and  ip.src == ${WEBUI_ADDR}
    cap.Check Expression    condition_expression=${rsp}
    
gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=ASIL

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${WEBUI_ADDR}
    Connect to gnb coam via ssl    bts_host=${WEBUI_ADDR}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections
    
Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${LOG_PATH}    ${WEBUI_COAM}==${WEBUI_ADDR}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_ADDR}
	
COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_ADDR}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_ADDR}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
       ${cur_para_value}    selenium_coam.get_parameter_value
       ...    dist_name=${cur_para_to_update['dist_name']}
       ...    abbr=${cur_para_to_update['abbr']}
       ...    filter_param=${cur_para_to_update['filter_param']}
       Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
       ...    Log to console    current value is ${cur_para_value}, no need to update
       ...    ELSE    run keywords
       ...    selenium_coam.set_parameter_value
       ...    dist_name=${cur_para_to_update['dist_name']}
       ...    abbr=${cur_para_to_update['abbr']}
       ...    filter_param=${cur_para_to_update['filter_param']}
       ...    new_value=${cur_para_to_update['new_value']}    AND
       ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout
    
COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_ADDR}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_COAM}
    ...                    username=${WEBUI_USER}
    ...                    password=${WEBUI_PASSWORD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    

Check the parameters changed successfully
    selenium_coam.enable_virtual_display
    selenium_coam.login   url=https://${WEBUI_ADDR}   username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
    ${A2_value}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...                                  filter_param=A2 Measurement Configuration for Redirection Enabled
    ${A2_Threshold}    selenium_coam.get_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...                                  filter_param=A2 Threshold Ssb Rsrp for Redirection
    Should be equal    ${A2_value}    rsrq
    Should be equal    ${A2_Threshold}    120
    sleep    8s
    [Teardown]    Run Keyword And Ignore Error    selenium_coam.logout

ActRedirect In Webem
    COAM WEBUI Login
    selenium_coam.set_parameter_value     dist_name=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
    ...   filter_param=Activate RRC Connection Release with redirection    new_value=true
    [Teardown]    COAM WEBUI LOGOUT
