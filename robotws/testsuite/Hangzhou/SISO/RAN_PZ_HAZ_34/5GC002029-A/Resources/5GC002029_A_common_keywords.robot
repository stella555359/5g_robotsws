*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02
Library           OperatingSystem
Library           Collections
Library           String
Library           BuiltIn
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.collectors.snapshot     WITH NAME     snapshot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/frame_structure_and_throughput.py
Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/common/RRH_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Huawei_sigspark_L3_call.robot
Resource          taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          taf/rfrl/common_resources/robot/coam_selenium.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
#Library           ../../../../../resources/python_libs/check_csv_log.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot

*** Variables ***
${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Common Suite Setup for UTE
    SISO Coam Suite Setup
    robot_common_operations.Common Suite Setup

Common Suite Setup for COAM
    Run Keyword And Ignore Error     Generate suite log path
    Run Keyword And Ignore Error     Connect to gnb coam via ssl
    Run Keyword And Ignore Error     COAM Commission with scf file     scf_file_path=${scf_file_path}
    COAM Wait for gnb ready and cell setup     timeout=20 min

Common Suite Teardown for COAM
    COAM Teardown gnb connections

Get Allowed Faults
    [Arguments]    ${connection}=GNB_OAM
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}
    @{alarms}    Create List
    FOR    ${active_alarm}    IN    @{active_alarms_list}
         ${alarm}    Create Dictionary    faultId=&{active_alarm}[faultId]
         Append To List    ${alarms}    ${alarm}
    END
    [Return]    ${alarms}

Reset RU and Check Status
    [Arguments]    ${allowed_faults}    ${ru_list}
    FOR    ${c_list}    IN    @{ru_list}
         Perform RU Reset    ru_index=${c_list}
    END
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Cell Should Be failed
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=GNB_OAM
    ${subcell_status}=  coam_siso_common.Get Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}    failed

Reset Tested RU and Check all RU status
    [Arguments]    ${tested_ru_idx}    ${ru_list}    ${cell_idx}=${tested_ru_idx}    ${cell_group_idx}=${tested_ru_idx}
    Perform RU Reset    ru_index=${tested_ru_idx}
    Wait until keyword succeeds    3 min    20 sec    Cell Should Be failed
    ...                                               cell_idx=${cell_idx}    cell_group_idx=${cell_group_idx}
    FOR    ${ru_idx}    IN    @{ru_list}
        &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_idx}   connection=GNB_OAM
        Run Keyword If    ${ru_idx} == ${tested_ru_idx}
        ...               Should be equal as strings    ${ru_status['status']['operationalState']}    Disabled    ignore_case=True
        ...       ELSE    Should be equal as strings    ${ru_status['status']['operationalState']}    Enabled
        ...               msg=Current RU operationalState is not in Enabled status    ignore_case=True
    END
#    Expect Fault Should Present    faultId=${7300}
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_ID}

Lock RU and Check Status
    [Arguments]    ${ru_list}    ${all_cell}=${true}    ${gnb_type}=NSA
    FOR    ${c_list}    IN    @{ru_list}
         Perform RU lock via rest api      ru_idx=${c_list}      timeout=90
    END
    FOR    ${c_list}    IN    @{ru_list}
         Wait until keyword succeeds    3min    20 sec    RU Should Be Locked    ru_index=${c_list}
    END
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7300
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7319

Unlock RU and Check Status
    [Arguments]    ${allowed_faults}    ${ru_list}
    FOR    ${c_list}    IN    @{ru_list}
         Perform RU unlock via rest api    ru_idx=${c_list}
    END
    COAM Wait for gnb ready and cell setup
    FOR    ${c_list}    IN    @{ru_list}
         RU Should Be Unlocked    ru_index=${c_list}
    END
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Lock Cell and Check Status
    [Arguments]    ${cell_list}    ${all_cell}=${true}    ${gnb_type}=NSA
    FOR    ${c_list}    IN    @{cell_list}
         Perform cell lock via rest api    cell_idx=${c_list}
    END
    FOR    ${c_list}    IN    @{cell_list}
         ${cg_list}    Evaluate    ${c_list}-1
         Wait until keyword succeeds    3min    20 sec    Cell Should Be Locked    cell_idx=${c_list}    cell_group_idx=${cg_list}
    END
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7300
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7319

Unlock Cell and Check Status
    [Arguments]    ${allowed_faults}    ${cell_list}
    FOR    ${c_list}    IN    @{cell_list}
         Perform cell unlock via rest api    cell_idx=${c_list}
    END
    sleep    60s
    COAM Wait for gnb ready and cell setup
    FOR    ${c_list}    IN    @{cell_list}
         ${cg_list}    Evaluate    ${c_list}-1
         Wait until keyword succeeds    5min    20 sec    Cell Should Be Unlocked    cell_idx=${c_list}    cell_group_idx=${cg_list}
    END
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Lock Cell Group and Check Status
    [Arguments]    ${cell_group_list}    ${all_cell}=${true}        ${gnb_type}=NSA      ${branch}=${AF_PATH}
    FOR    ${c_list}    IN    @{cell_group_list}
         Perform cell group lock via rest api    cellgrp_idx=${c_list}
    END
    ${is_sbts}    run keyword and return status      Should Match Regexp    ${branch}    SBTS.*
    FOR      ${num}    IN    @{cell_group_list}
        Run keyword IF     ${is_sbts}==${FALSE}      Wait until keyword succeeds    3min    20 sec
        ...      Verify Cell Group Status Should Be Locked    cell_group_idx=${c_list}
    END
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7300
    Run keyword If    ${all_cell} and '${gnb_type}' =='NSA'
    ...   Wait until keyword succeeds    10min    20 sec    Expect Fault Should Present    faultId=7319

Unlock Cell Group and Check Status
    [Arguments]    ${allowed_faults}    ${cell_group_list}      ${branch}=${AF_PATH}
    FOR    ${c_list}    IN    @{cell_group_list}
         Perform cell group unlock via rest api    cellgrp_idx=${c_list}
    END
    COAM Wait for gnb ready and cell setup
    ${is_sbts}    run keyword and return status      Should Match Regexp    ${branch}    SBTS.*
    FOR    ${c_list}    IN    @{cell_group_list}
        Run keyword IF     ${is_sbts}==${FALSE}      Wait until keyword succeeds    5min    20 sec
                ...      Verify Cell Group Status Should Be Unlock    cell_group_idx=${c_list}
    END
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}

Capture BTS log
    ${date}    Evaluate    datetime.datetime.now().strftime('%Y-%m-%d-%H%M%S')    datetime
    Run keyword and ignore Error    Btslog Setup    name=btslog_${date}    path=${btslog_path}
    ...    launcher_path=${btslog_launcher_path}    log_folder=${btslog_folder}
    Set test variable    ${date}

Stop BTS log
    [Arguments]    ${btslog_name}=btslog_${date}
    Run keyword And Ignore Error    Btslog Teardown    name=${btslog_name}

Test Case Setup
    [Arguments]    ${need_Btslog}=${True}
    COAM Create log directory
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    timeout=20 min
    ${fault_status}    Run keyword and Return Status    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    Run keyword If    ${fault_status}==${False}    Perform BTS Site Reset
    Run keyword If    ${fault_status}==${False}    COAM Wait for gnb ready and cell setup    timeout=20 min
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    Run keyword If    ${need_Btslog}==${True}    Capture BTS log
    ${ue_reboot_dict}    create dictionary
    set test variable    ${ue_reboot_dict}

Test Case Teardown
    [Arguments]    ${need_Btslog}=${True}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    robot_common_operations.Common Case Teardown
    Run keyword If    ${need_Btslog}==${True}    Stop BTS log
    Run keyword And Ignore Error    Run Keyword If Test Failed    Perform BTS Site Reset
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    Run keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

Modify parameter in SCF
    [Arguments]    ${pmax_value}=570    ${reset_time}=1    ${cellId}=1
    &{pmax_param}    Create Dictionary    dist_name=NRBTS-1/NRCELL-${cellId}    parameter=pMax    value=${pmax_value}
    &{reset_time_param}    Create Dictionary    dist_name=NRBTS-1    parameter=maxX2PartialResetReqRetry    value=${reset_time}
    @{modify_param}    Create List    ${pmax_param}    ${reset_time_param}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    timeout=600

Get parameter in SCF
    [Arguments]    ${para}    ${dist_value}    ${connection}=GNB_OAM
    ${parameter}    coam_parameter.get_single_value_from_scf_file    parameter=${para}    dist_name=${dist_value}
    ...    connection=${connection}
    [Return]    ${parameter}

Get led status of unit
    [Arguments]    ${unit_name}   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    sleep    2s
    ${led_status}    selenium_coam.Get Led Status Of An Unit    ${unit_name}
    [Return]    ${led_status}
    [Teardown]  COAM selenium logout

Get Current SCF file
    [Arguments]    ${dir}    ${file_name}=SCF_backup.xml    ${timeout}=600s    ${connection}=GNB_OAM
    ${file}    coam.get_current_scf_file    local_dir_path=${dir}    file_name=${file_name}    timeout=${timeout}    connection=${connection}
    [Return]    ${file}

Recover ENV
    Run Keyword If Test Failed    Run keyword And Ignore Error    COAM Commission with scf file    scf_file_path=${current_scf}    timeout=600
    Run Keyword If Test Failed    COAM Wait for gnb ready and cell setup    timeout=15min
    Test Case Teardown

Check Present Fault Number
    [Arguments]    ${faultId}    ${number}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}
    [Documentation]    Auther: stella.lin@nokia-sbell.com
    ...    Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
    ...    :param severity<str>: optional,value:Critical,Major,Minor,Warning
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    ${num}    Set Variable    0
    FOR    ${alarm}    IN    @{alarms}
         Exit For Loop If    ${alarm_num}==${0}
         ${present_status}    Run Keyword And Return Status    Run Keywords    Dictionary Should Contain Item    ${alarm}    faultId
         ...    ${faultId}
         ...    AND    Run Keyword If    '${source}'!='${None}'    Should Contain    ${alarm['notifier']}
         ...    ${source}    case_insensitive=True
         ...    AND    Run Keyword If    '${severity}'!='${None}'    Should Contain    ${alarm['severity']}
         ...    ${severity}    case_insensitive=True
         ${num}=    Run Keyword If    ${present_status}==${True}    Evaluate    ${num}+1
         ...    ELSE    Set Variable    ${num}
    END
    Run Keyword If    ${num} != ${number}    fail    faultId ${faultId} reported by source ${num} times

Verify information in startup
    [Arguments]    ${information}    ${verify_information}    ${alias}=ASIK Master
    run keyword and ignore error    csn.disconnect    connection=${alias}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${alias}
    ${status}    run keyword and return status    csn.assert file exists    remote_path=/tmp/startup_BTSOM.log    connection=${alias}
    ${command}    set variable if    '${status}'=='True'    cat /tmp/startup_BTSOM.log|grep -i ${information}
    ...    '${status}'=='False'    xzcat /ffs/run/logs/fct-*/startup_BTSOM.log.xz|grep -i ${information}
    ${result}    csn.execute    command=${command}    connection=${alias}
#    Should Not Be Empty    ${result}
    should contain    ${result}    ${verify_information}

Power Off RU and Check Status
    [Arguments]    ${ru_list}    ${all_cell}=${true}    ${gnb_index}=0    ${du_index}=0
    FOR    ${r_list}    IN    @{ru_list}
         Perform RU Power Off    ru_index=${r_list}
         ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
         ${cg_list}    Evaluate    ${r_list}-1
         sleep    5 sec
         Wait until keyword succeeds    3 min    20 sec    Cell Should Be Disabled    cell_idx=${r_list}    cell_group_idx=${cg_list}
    END
    ${length}=    Get Length    ${ru_list}
    Run keyword If    ${all_cell}    Wait Until Keyword Succeeds    3 min    20 sec
    ...    Check Present Fault Number    faultId=${10}    source=RMOD_R    number=${length}

Power On RU and Check Status
    [Arguments]    ${allowed_faults}    ${ru_list}    ${gnb_index}=0    ${du_index}=0
    FOR    ${r_list}    IN    @{ru_list}
         Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${gnb_index}].dus[${du_index}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
         Wait until keyword succeeds    15 min    20 sec    RU Should Be Online    ru_index=${r_list}
    END
    Wait Until Keyword Succeeds    9 min    20 sec
    ...    Check Present Fault Number    faultId=${10}    source=RMOD_R    number=0
    Wait until keyword succeeds    3min    20 sec    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_faults}
    COAM Wait for gnb ready and cell setup

Get number of Cells
    [Arguments]    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${cell_number}=    selenium_coam.get_number_of_cells
    [Teardown]    selenium_coam.logout
    [Return]    ${cell_number}

Recover ENV if under Wrong Configuration
    [Arguments]    ${need_cell_no}    ${template_file}
    ${cell_number}=    Get number of Cells
    Run keyword if    ${cell_number}!=${need_cell_no}    Commissioning with Template Commission    scf_file=${template_file}

Commissioning with Template Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=600      is_pdl_checking_needed=False
    COAM Wait for gnb ready and cell setup    timeout=15min

Btslog Setup
    [Arguments]    ${name}      ${path}    ${launcher_path}    ${log_folder}
    ${executor_test_vm}=      Create Dictionary
    ...    host=${tl.test_pc.default_ssh_connection_details.addr}
    ...    user=${tl.test_pc.default_ssh_connection_details.username}
    ...    password=${tl.test_pc.default_ssh_connection_details.password}
    ${command}     Catenate     rm -rf ${log_folder}/SYSLOG*.LOG
    Run    ${command}
    btslog.create_btslog_collector
    ...    name=${name}
    ...    btslog_path=${path}
    ...    btslog_launcher_path=${launcher_path}
    ...    executor=${executor_test_vm}
    ...    log_dir=${log_folder}
    core.setup_collectors    names=${name}
    core.start_collectors    names=${name}
    btslog.Set Suite Alias     ${name}

Btslog Teardown
    [Arguments]    ${name}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}
    core.teardown_collectors    names=${name}

Verify ASIK is disconnected
    ${status} =    Run Keyword And Return Status    Ping to destination from local should be success
    Should Be Equal    ${status}    ${False}

Ping to destination from local should be success
    [Arguments]     ${destation}=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${rc}=    Run and return rc    ping ${destation} -w 10
    Should be equal as numbers    first=${0}    second=${rc}

Verify RU is disconnected
    ${status} =    Run Keyword And Return Status    Ping to all RU with allocated IP should be success
    Should Be Equal    ${status}    ${False}

Ping to all RU with allocated IP should be success
    [Arguments]    ${connection}=GNB_OAM
    ${rus}    connection_alias_store.Get RU List
    connection_alias_store.Connect to Common Unit Master
    ${ru_index}    Set Variable    ${1}
    FOR    ${ru}    IN    @{rus}
         &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
         ${ru_ip_addr}    Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
         Ping to destination from ASIK should be success    destation=${ru_ip_addr}
         ${ru_index}    Evaluate    ${ru_index}+1
    END

Ping to destination from ASIK should be success
    [Arguments]     ${destation}    ${connection}=ASIK Master
    ${result} =    csn.execute    command=ping ${destation} -w 10    connection=${connection}
    should contain    ${result}    0% packet loss
    Should not contain    ${result}    100% packet loss

Get Cell Group Status from WebEM
    [Documentation]   Refact code as start up view
    [Arguments]   ${cell_group_idx}=${0}     ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    COAM Navigate to login page via webUI    download_dir=${download_dir}    timeout=${timeout}
    ${result}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${result}      selenium_coam.close_start_up_view_window
    ${cell_group_status}    selenium_coam.get_cell_group_status    cell_group_idx=${cell_group_idx}
    [Return]   ${cell_group_status}
    [Teardown]  COAM selenium logout

Verify Cell Group Status Should Be Locked
    [Arguments]   ${cell_group_idx}=${0}   ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${cell_group_status}    Get Cell Group Status from WebEM    cell_group_idx=${cell_group_idx}   download_dir=${download_dir}    timeout=${timeout}
    Should Be Equal As Strings     ${cell_group_status}   Lock

Verify Cell Group Status Should Be Unlock
    [Arguments]   ${cell_group_idx}=${0}   ${download_dir}=${TS_CASE_LOG_PATH}    ${timeout}=${60}
    ${cell_group_idx}  Convert To Integer    ${cell_group_idx}
    ${cell_group_status}    Get Cell Group Status from WebEM    cell_group_idx=${cell_group_idx}  download_dir=${download_dir}    timeout=${timeout}
    Should Be Equal As Strings     ${cell_group_status}   Unlock

Switch fiber channels and verify fiber channels status
    [Arguments]  ${cross_connection_setting}
    ...    ${vendor}=${tl.optical_switches[0].__class__.__name__}
    ...    ${model}=${tl.optical_switches[0].model}
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=4001
    fiberswitch.setup_optical_switch    optical_switch=${vendor}    alias=switch1    model=${model}    addr=${addr}   port=${port}
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    fiberswitch.set_optical_switch_channels    settings=${cross_connection_setting}    optical_switch_device=switch1
    sleep      2s
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    [Teardown]    fiberswitch.teardown     optical_switch_device=switch1

Perform BTS Site Reset with disable message box
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site
    [Teardown]  COAM selenium logout

Setup MTK Message
    mtk.Setup    pyro_ip=${tl.ues[0].ssh_connection_details.addr}    pyro_port=${tl.ues[0].server_port}
    mtk.Create Message Flow Alias    flow_alias=MTK_OTA_MESSAGE    message_type=ota_text
    mtk.Create Message Flow Alias    flow_alias=MTK_PS_TRACE    message_type=ps_trace
    mtk.Create Message Flow Alias    flow_alias=MTK_RAW_STRING    message_type=raw_string
    mtk.Create Message Flow Alias    flow_alias=MTK_OTA_JSON    message_type=ota_json

UTE Common Case Setup
    [Arguments]   ${scf_path}    ${ru_list}
    ...    ${cur_relative_dir}=testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources
    robot_common_operations.Common Case Setup
    Connect to gnb coam via ssl
    ${exist_fault}    COAM Get active alarms
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${testline_name}      Get TL Name
    ${scf_base_path}    String.Replace String    ${CURDIR}    ${cur_relative_dir}    ${scf_relative_dir}
    @{all_ru_list}    Create List    1    2
    FOR    ${r_list}    IN    @{all_ru_list}
         Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    @{use_ru_list}    Run keyword If    ${ru_list}==1    Create List    2
    FOR    ${r_list}    IN    @{use_ru_list}
         Perform RU Power Off    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    Commissioning with Template Commission      scf_file=${scf_base_path}/${testline_name}/${scf_path}
    Test Case Setup

Get TL Name
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    [Return]   ${testlinename}

UTE Common Case Teardown
    Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
    Run keyword And Ignore Error    Btslog Teardown    name=btslog_${date}
    @{all_ru_list}    Create List    1    2
    FOR    ${r_list}    IN    @{all_ru_list}
         Perform RU Power On    ru_index=${r_list}
         ...    model=${tl.gnbs[${0}].dus[${0}].rus[${r_list}-1].pdu_port.pdu.__class__.__name__}
    END
    Perform BTS Site Reset
    Wait Until Keyword Succeeds    15 min    30 sec      COAM Check GNB cell on air
    Run keyword And Ignore Error    CI_interface.Common Case Teardown
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error    csn.disconnect    connection=RU
    Run Keyword And Ignore Error    csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections

UE Attach and Start Traffic
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}
    ...             ${Expected_Throughput_UL}    ${nrCellIdentity}    ${ue_index}=${0}    ${ui_version}=default
    ...             ${apn_address}=wap1nokiacom    ${time}=5m   ${cap_index}=${0}    ${ip_filter}=${None}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    ${ue_index_list}    Create List    ${ue_index}
    ADB Reboot UE      ue_index=${ue_index}
    Sleep       20s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    Connect to Common Unit Master  alias=ASIK MASTER
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    cap_index=${cap_index}
    Connect to Common Unit Master  alias=ASIK MASTER
    connect to gnb coam via ssl    connection=GNB_OAM
#    ${cell_id}    wait until keyword succeeds   1min    5s    get_ue_attached_cell_id_from_log    log_path=/tmp/5Grach.txt
#    ...    alias=ASIK MASTER    connection=GNB_OAM
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${data_transfer_dl}    duration=${DURATION}
    ...                       ue_index=${ue_index}    apn_address=${apn_address}    cap_index=${cap_index}    ip_filter=${ip_filter}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${data_transfer_ul}
    ...                       duration=${DURATION}    ue_index=${ue_index}    apn_address=${apn_address}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}     duration=${time}
#    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=GNB_OAM
#    ${cell_id}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cell_id}    Create List    ${nrCellIdentity}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${Expected_Throughput_DL}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL    cells=${cell_id}
    ...                                    log=${tput_log}    target_throughput=${Expected_Throughput_UL}
    [Teardown]    Ue Stop DL UL Traffic and Detach    ue_index_list=${ue_index_list}

Test Case Teardown with UE
    power_ue.UE Detach     ue_type=${ue_type}
    Test Case Teardown

Test Case Setup with swconfig update
    [Arguments]     ${scf_template_file}      ${swconfig_modify_list}
    Test Case Setup
    Connect to Common Unit Master
    SWconfig.download_swConfig_file_from_asik_to_test_pc      localFilePath=${swconfig_file}      asik_alias=ASIK Master
    SWconfig.modify_swConfig_file      parametersList=${swconfig_modify_list}      filePath=${swconfig_file}
    SWconfig.upload_swConfig_file_to_asik_and_crasign      localFilePath=${swconfig_file}      asik_alias=ASIK Master
    Commissioning with Template Commission    scf_file=${scf_template_file}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=ASIK Master    AND
    ...    COAM Teardown gnb connections

Check RU Calibration Status And Power
    [Documentation]  Author: Jia Lei
    [Arguments]  ${connection}=GNB_OAM    ${asik_connection}=ASIK Master    ${retry_time}=3
    run keyword and ignore error    csn.disconnect    connection=${asik_connection}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    connection_alias_store.Connect to Common Unit Master    alias=${asik_connection}
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    @{ru_list}    Create List
    FOR    ${ru_index}    IN RANGE    1    ${ru_num}+${1}
        Append To List    ${ru_list}    ${ru_index}
    END
    FOR    ${ru_index}    IN    @{ru_list}
        Connect to RU With Allocated IP    ru_index=${ru_index}   ru_alias=RU${ru_index}
        ...    asik_alias=${asik_connection}   connection=${connection}
        Run Keyword And Continue On Failure    Wait until keyword succeeds    ${retry_time}X    30 s
        ...    Check RU Calibration Status    ru_alias=RU${ru_index}
        ${RU_TYPE}    Set Variable    ${tl.gnbs[0].du.rus[${ru_index-1}].radio_type.value}
        ${ru_dfe_ip}    Set Variable If    '${RU_TYPE}' == 'AEHB'    192.168.100.10
        ...                                '${RU_TYPE}' == 'AZHM'    192.168.100.3
        ...                                '${RU_TYPE}' == 'AHPF'    ${None}
        Check RU Power on DFE    ru_alias=RU${ru_index}    ru_dfe_ip=${ru_dfe_ip}
        run keyword and ignore error    csn.Disconnect  connection=RU${ru_index}
    END
   [Teardown]  COAM Teardown gnb connections

Check RU Calibration Status
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}
    ${calibration_output}    csn.execute    command=bfcali -stat    connection=${ru_alias}
    ${nr_calibration}    Split String From RU Calibration Output    calibration_output=${calibration_output}
    Get RU Calibration Value And Compare    nr_calibration=${nr_calibration}

Split String From RU Calibration Output
    [Documentation]  Author: Jia Lei
    [Arguments]    ${calibration_output}    ${carrier_name}=NR
    @{nr_calibration}    create list
    @{calibrations}    split string    ${calibration_output}    \r\n\r\n
    FOR    ${latest_cali}    IN    @{calibrations}
           ${status}    run keyword and return status    should contain    ${latest_cali}    ${carrier_name}
           run keyword if    '${status}'=='${True}'    append to list      ${nr_calibration}    ${latest_cali}
    END
    [Return]    ${nr_calibration}

Get RU Calibration Value And Compare
    [Documentation]  Author: Jia Lei
    [Arguments]    ${nr_calibration}
    FOR    ${each_cali}    IN    @{nr_calibration}
           ${attempt_regexp}    set variable    Calibration attempts: (\\d+)
           ${success_regexp}    set variable    Successful calibrations: (\\d+)
           ${attempt_count}    Get Regexp Matches    ${each_cali}    ${attempt_regexp}    1
           ${success_count}    Get Regexp Matches    ${each_cali}    ${success_regexp}    1
           should be equal   ${attempt_count}    ${success_count}
    END

Check RU Power on DFE
    [Documentation]  Author: Jia Lei
    [Arguments]    ${ru_alias}    ${ru_dfe_ip}=192.168.100.10    ${ru_dfe_alias}=ru_dfe
    ...    ${all_attenna_ports}=8
    run keyword if    '${ru_dfe_ip}' != '${None}'
    ...               csn.connect to    hostname=${ru_dfe_ip}
    ...               username=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...               alias=${ru_dfe_alias}
    ...               proxy=${ru_alias}
    ${ru_dfe_alias}    set variable if    '${ru_dfe_ip}' != '${None}'    ${ru_dfe_alias}
    ...                                    ${ru_alias}
    FOR    ${index}    IN RANGE    ${all_attenna_ports}
        ${dfe_power_output}    csn.execute    command=dapd -stat ${index}    connection=${ru_dfe_alias}
        ${tx_power_regexp}    set variable    TX.=.(\\d+\.?\\d*)
        ${tx_power_value}    Get Regexp Matches    ${dfe_power_output}    ${tx_power_regexp}    1
        ${status}     Run Keyword And Return Status     Should Be True    ${0}<=${tx_power_value}[0]<=${45}
        ...           msg=${tx_power_value}[0] is out of range.
    END
    [Teardown]  run keyword and ignore error    csn.Disconnect  connection=${ru_dfe_alias}

Check syslog
    [Arguments]   ${dir}
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'CELL NOTIFICATION 4329 Radio memory consumption exceeds abnormal threshold'
    ${status1}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'FaultId: 4329'
    ${status2}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'FaultId: 4330'
    ${status3}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'Detector 4329'
    ${status4}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'Detector 4330'
    ${status5}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'active 4329'
    ${status6}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep 'active 4330'
    ${status7}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${offline_output}   RUN    cat ${dir}/SYSLOG*.LOG |grep '4230 Radio memory consumption exceeds critical threshold'
    ${status8}    run keyword and return status    should be empty    ${offline_output}    Syslog Crash verification failed
    ${status_list}    create list    ${status1}    ${status2}    ${status3}    ${status4}    ${status5}    ${status6}    ${status7}    ${status8}
    list should not contain value    ${status_list}    ${False}
