*** Settings ***
Documentation    Suite description
Resource     ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource     ../../../../OAM/RAN_PZ_HAZ_34/5GC002479/Resources/5GC002479_CP_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library        SSHLibrary    timeout=10s
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
*** Variables ***
${UE_TYPE}                ${tl.ues[0].capabilities[-1]}
${WEBUI_URL}           https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_IP}            ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${ASIK_IP_Mplane}      ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_username}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_password}	   ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${NRBTS_ID}            ${tl.gnbs[0].global_bts_id}
${FAULT_ID_4680}       4680
${DISABLE_TIMER}       9999

*** Keywords ***

SuiteSetup
    log to console    \n*** Coam Suite Setup***
    TestSuite.Start
    Run Keyword And Ignore Error    Import Variables         ${CFGFILE_PATH}/TLConfiguration.py
    Generate suite log path
    set suite variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    set suite variable    ${bts_type}    ${CASE_INPUT_CB013940['bts_type']}
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    wait until keyword succeeds   2min    10s    COAM_Admin.commission
    ...      scf_file=${CFGFILE_PATH}SBTS00_CB013940_SCF.xml
    Sleep  5min
    wait until keyword succeeds    10min    30s    COAM_Admin.CheckAllCellsOnair    type=${bts_type}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Run Keyword And Ignore Error    COAM Teardown gnb connections

SuiteTearDown
    wait until keyword succeeds   2min    30s    COAM_WebEM.Login
    ${OnAir_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair    type=${bts_type}
    Run Keyword If    '${OnAir_status}' == 'False'    COAM_Admin.ResetSite    timeout=1800
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

CB013940 Test Setup
    log to console    \n***Coam Test Setup***
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Run Keyword And Ignore error     BtsLog.StartBTSlogCollection
    Run Keyword And Ignore Error    selenium.close_browser
    wait until keyword succeeds   2x    10s    Connect to gnb coam via ssl
    robot_common_operations.Common Case Setup    allowed_faults_ids=4680,2919,2920,8000,7300,4614,4753,6328
    CI_interface.Common Case Setup
    wait until keyword succeeds   2min    10s    COAM_WebEM.Login

CB013940 Test Teardown
    log to console    \n***Coam Test Teardown***
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    run keyword if test failed     Collect_snapshot_by_WEBUI
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    Run Keyword And Ignore Error    COAM Teardown gnb connections
    TestCase.Stop

Collect_snapshot_by_WEBUI
    [Arguments]    ${loop}=0
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${SAVE LOG DIRECTORY}/snapshot_${filename}_${loop}.zip

TC.CB013940_A_1_RU raises fault 4680 and cancels the fault by timer
    [Documentation]
    [Arguments]  ${cmd1}=${CASE_INPUT_CB013940['A1']['cmd1']}
    ...          ${cmd2}=${CASE_INPUT_CB013940['A1']['cmd2']}
    ...          ${fid}=${CASE_INPUT_CB013940['A1']['fid']}
    ...          ${ru_index}=${CASE_INPUT_CB013940['A1']['ru_index']}
    ...          ${RuConnToSenCore}=${CASE_INPUT_CB013940['A1']['RuConnToSenCore']}
    ...          ${ru_username}=${CASE_INPUT_CB013940['A1']['ru_username']}
    ...          ${ru_password}=${CASE_INPUT_CB013940['A1']['ru_password']}
    KW.CB013940 Precondition Preparation    ru_index=${ru_index}
    wait until keyword succeeds   2x    30s    KW.Trigger fault 4680 via command    loops=${Unstable_threshold}
    ...    cmd1=${cmd1}    cmd2=${cmd2}    ru_index=${ru_index}    fid=${fid}    RuConnToSenCore=${RuConnToSenCore}
    ...    ru_username=${ru_username}    ru_password=${ru_password}
    Log to console    Fault 4680 reported, wait timer expired to clear fault 4680.
    wait until keyword succeeds   ${Timer_13940}min    60s    COAM_WebEM.CheckAlarm    id=4680    present=false
    Log to console    Fault 4680 cleared after timer expired
    wait until keyword succeeds    3min    30s    COAM_Admin.CheckAllCellsOnair    type=${bts_type}
    ${history_alarm_info}    selenium_coam.get_history_alarm_info    alarm_filter=4680
    Log  ${history_alarm_info}
    Should Not Be Empty    ${history_alarm_info}
    Log to console    Fault 4680 cleared and cells back to normal

TC.CB013940_A_2_Online change parameters while the timer is running
    [Documentation]
    [Arguments]  ${cmd1}=${CASE_INPUT_CB013940['A2']['cmd1']}
    ...          ${cmd2}=${CASE_INPUT_CB013940['A2']['cmd2']}
    ...          ${fid}=${CASE_INPUT_CB013940['A2']['fid']}
    ...          ${ru_index}=${CASE_INPUT_CB013940['A2']['ru_index']}
    ...          ${RuConnToSenCore}=${CASE_INPUT_CB013940['A2']['RuConnToSenCore']}
    ...          ${ru_username}=${CASE_INPUT_CB013940['A2']['ru_username']}
    ...          ${ru_password}=${CASE_INPUT_CB013940['A2']['ru_password']}
    KW.CB013940 Precondition Preparation    ru_index=${ru_index}
    wait until keyword succeeds   2x    30s    KW.Trigger fault 4680 via command    loops=${Unstable_threshold}
    ...    cmd1=${cmd1}    cmd2=${cmd2}    ru_index=${ru_index}    fid=${fid}    RuConnToSenCore=${RuConnToSenCore}
    ...    ru_username=${ru_username}    ru_password=${ru_password}
    Log to console    Fault 4680 reported and will be canceled after ${Timer_13940}min
    ${Timer_ru_new} =    Evaluate    int(${Timer_13940}) + 15
    ${Timer_bts_new} =    Evaluate    int(${Timer_ru_new}) + 15
    wait until keyword succeeds    3x    30s    COAM_WebEM.ModifyAndActiveParameters
    ...   DistName=${MRBTSID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    FilterParam=Radio unit input voltage unstable fault expiration timer    NewValue=${Timer_ru_new}min
    Sleep  5s
    wait until keyword succeeds    3x    30s    COAM_WebEM.ModifyAndActiveParameters
    ...   DistName=${MRBTSID}/EQM-1/APEQM-1
    ...    FilterParam=Input voltage unstable fault expiration timer for RUs    NewValue=${Timer_bts_new}min
    Log to console    New 13940 Timer updated
    ${status}=    Run Keyword And Return Status    wait until keyword succeeds   ${Timer_13940}min    60s
    ...    COAM_WebEM.CheckAlarm    id=4680    present=false
    Should Be True    '${status}' == 'False'
    Log to console    Fault 4680 do not clear after old timer expired, because new timer is running.
    wait until keyword succeeds   15min    60s    COAM_WebEM.CheckAlarm    id=4680    present=false
    Log to console    Fault4680 clear after new timer expired, and BTS level timer was overwrite by RU level Timer
    wait until keyword succeeds    3x    60s    COAM_Admin.CheckAllCellsOnair    type=${bts_type}
    ${history_alarm_info}    selenium_coam.get_history_alarm_info    alarm_filter=4680
    Log  ${history_alarm_info}
    Should Not Be Empty    ${history_alarm_info}

TC.CB013940_A_3_RU reset while the timer is running and fault is cancelled
    [Documentation]
    [Arguments]  ${cmd1}=${CASE_INPUT_CB013940['A3']['cmd1']}
    ...          ${cmd2}=${CASE_INPUT_CB013940['A3']['cmd2']}
    ...          ${fid}=${CASE_INPUT_CB013940['A3']['fid']}
    ...          ${ru_index}=${CASE_INPUT_CB013940['A3']['ru_index']}
    ...          ${RuConnToSenCore}=${CASE_INPUT_CB013940['A3']['RuConnToSenCore']}
    ...          ${ru_username}=${CASE_INPUT_CB013940['A3']['ru_username']}
    ...          ${ru_password}=${CASE_INPUT_CB013940['A3']['ru_password']}
    KW.CB013940 Precondition Preparation    ru_index=${ru_index}
    wait until keyword succeeds   2x    30s    KW.Trigger fault 4680 via command    loops=${Unstable_threshold}
    ...    cmd1=${cmd1}    cmd2=${cmd2}    ru_index=${ru_index}    fid=${fid}    RuConnToSenCore=${RuConnToSenCore}
    ...    ru_username=${ru_username}    ru_password=${ru_password}
    Log to console    Fault 4680 reported and will be canceled after ${Timer_13940}min
    Wait until keyword succeeds   2min   20s    selenium_sbts.reset_ru    ru_index=${ru_index}
    Sleep  1s
    wait until keyword succeeds   2x    10s    COAM_WebEM.CheckAlarm    id=4680    present=false
    Log to console    Fault 4680 cleared due to RU reset.
    wait until keyword succeeds    5x    60s    COAM_Admin.CheckAllCellsOnair    type=${bts_type}
    Log to console    Fault 4680 cleared and cells back to normal

TC.CB013940_A_5_Fault 4680 raises and cancels when RU in DSM
    [Documentation]  Check fault 4680 should not impact DSM process
    [Arguments]  ${cmd1}=${CASE_INPUT_CB013940['A5']['cmd1']}
    ...          ${cmd2}=${CASE_INPUT_CB013940['A5']['cmd2']}
    ...          ${fid}=${CASE_INPUT_CB013940['A5']['fid']}
    ...          ${ru_index}=${CASE_INPUT_CB013940['A5']['ru_index']}
    ...          ${RuConnToSenCore}=${CASE_INPUT_CB013940['A5']['RuConnToSenCore']}
    ...          ${ru_username}=${CASE_INPUT_CB013940['A5']['ru_username']}
    ...          ${ru_password}=${CASE_INPUT_CB013940['A5']['ru_password']}
    KW.CB013940 Precondition Preparation    ru_index=${ru_index}
    ${DSM_flag}    COAM_WebEM.GetParameterValue
    ...    distName=${MRBTSID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    abbr=Energy Saving Mode Activation
    ${DSM_check}    Run Keyword And Return Status   Should Match Regexp    ${DSM_flag}    .*SLEEP.*
    Run Keyword If    '${DSM_check}' == 'False'    Fatal Error    DSM did not enable, Please check configuration
    Log to console    Trigger Radios go to ESM by Block RAT
    Run keyword if    '${bts_type}' == 'both'    run keywords    selenium_coam.block_rat    rat=NR    AND
    ...        selenium_coam.block_rat    rat=LTE
    Run keyword if    '${bts_type}' == 'nr'    selenium_coam.block_rat    rat=NR
    Run keyword if    '${bts_type}' == 'lte'    selenium_coam.block_rat    rat=LTE
    wait until keyword succeeds   6min    60s    KW.Check RU in DSM or NOT    RU_index=${ru_index}    status=SLEEP
    wait until keyword succeeds   2x    30s    KW.Trigger fault 4680 via command    loops=${Unstable_threshold}
    ...    cmd1=${cmd1}    cmd2=${cmd2}    ru_index=${ru_index}    fid=${fid}    RuConnToSenCore=${RuConnToSenCore}
    ...    ru_username=${ru_username}    ru_password=${ru_password}
    Log to console    Fault 4680 reported and will be canceled after ${Timer_13940}min
    wait until keyword succeeds   ${Timer_13940}min    60s    COAM_WebEM.CheckAlarm    id=4680    present=false
    Log to console    Fault 4680 cleared after timer expired
    KW.Check RU in DSM or NOT    RU_index=${ru_index}    status=SLEEP
    Log to console    Radio still in DSM after fault 4680 cleared
    Log to console    Trigger Radios exit ESM by Unblock RAT
    Run keyword if    '${bts_type}' == 'both'    run keywords    selenium_coam.unblock_rat    rat=NR    AND
    ...        selenium_coam.unblock_rat    rat=LTE
    Run keyword if    '${bts_type}' == 'nr'    selenium_coam.unblock_rat    rat=NR
    Run keyword if    '${bts_type}' == 'lte'    selenium_coam.unblock_rat    rat=LTE
    wait until keyword succeeds    10min    30s    KW.Check RU in DSM or NOT    RU_index=${ru_index}    status=AWAKE
    wait until keyword succeeds    5min    30s    COAM_Admin.CheckAllCellsOnair    type=${bts_type}

KW.Check RU in DSM or NOT
    [Arguments]    ${required_info}=powerState    ${status}=DEEPSLEEP    ${RU_index}=1
    ${get_status}    get required RU info    required_info=${required_info}    RU_index=${RU_index}
    should be equal    ${get_status}    ${status}

KW.Trigger fault 4680 via command
    [Documentation]
    [Arguments]    ${loops}=1    ${cmd1}=1    ${cmd2}=1    ${ru_index}=1    ${fid}=2919    ${RuConnToSenCore}=False
    ...    ${ru_username}=1    ${ru_password}=1
    Log to console    start to trigger fault4680 via command.
    wait until keyword succeeds   2x    10s    Connect to gnb coam via ssl
    FOR  ${i}  IN RANGE    0  ${loops}
        Run Keyword If    '${RuConnToSenCore}' == 'False'    Execute RU Command Via FHNET Container
        ...    command=${cmd1}    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
        ...    ELSE    KW.Execute RU Command Via FHNET Container and Secondary Core    command=${cmd1}
        ...    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
        Sleep  90s
        Run keyword If    ${i} < ${loops} - 1    Run Keywords    COAM_WebEM.CheckAlarm    id=${fid}    present=true
        ...    AND    COAM_WebEM.CheckAlarm     id=4680    present=false
        ...    ELSE    COAM_WebEM.CheckAlarm     id=4680    present=true
        Run Keyword If    '${RuConnToSenCore}' == 'False'    Execute RU Command Via FHNET Container
        ...    command=${cmd2}    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
        ...    ELSE    KW.Execute RU Command Via FHNET Container and Secondary Core    command=${cmd2}
        ...    ru_index=${ru_index}    ru_username=${ru_username}    ru_password=${ru_password}
        Sleep  90s
        Run keyword If    ${i} < ${loops} - 1    Run Keywords    COAM_WebEM.CheckAlarm    id=${fid}    present=true
        ...    AND    COAM_WebEM.CheckAlarm     id=4680    present=false
        ...    AND    Sleep  5min
        ...    AND    COAM_WebEM.CheckAlarm    id=${fid}    present=false
        ...    ELSE    COAM_WebEM.CheckAlarm     id=4680    present=true
    END

KW.Execute RU Command Via FHNET Container and Secondary Core
    [Documentation]   Auther: shifu.lan@nokia-sbell.com
    ...               Description: Execute RU command by invoke shell of FHNET container
    [Arguments]    ${command}    ${ru_index}=${1}    ${gnb_index}=${0}    ${du_index}=${0}
    ...    ${asik_alias}=ASIK Master    ${connection}=GNB_OAM
    ...    ${ru_username}=1    ${ru_password}=1
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${asik_alias}
	${container_id_t}    Get FHNET Container ID    asik_alias=${asik_alias}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    ${ru_ip_addr}  Coam Get RU IP via RMOD object  ru_serial_number=${ru_info['serialNumber']}  connection=${connection}
    Run Keyword If    '${container_id_t}' == '0x1018'
    ...    ssh.connect to  fct-4a  username=${ASIK_username}  password=${ASIK_password}  proxy=${asik_alias}  alias=secondary
    ...    ELSE    ssh.connect to  fct-0a  username=${ASIK_username}  password=${ASIK_password}  proxy=${asik_alias}  alias=secondary
    ${alise}    Set Variable    secondary
    ${container_id}    Set Variable If    '${container_id_t}' == '0x1018'    0x2018    0x1018
    ${smod_connection}    csn.get_connection_by_alias    alias=${alise}
    ${channel}    Call Method    ${smod_connection}    invoke_shell
    ${output}    csn.execute    lxc-ls    connection=${alise}
    ${feature_1834_opened}    Run Keyword And Return Status    Should Contain    ${output}    ${container_id}
    IF    ${feature_1834_opened}
        Call Method    ${channel}    send    lxc-attach -n ${container_id}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    ssh ${ru_username}@${ru_ip_addr} -o StrictHostKeyChecking\=no\n
    Sleep    1 sec
    ${password_prompt_output}    Call Method    ${channel}    recv    ${65535}
    IF    "password:" in """${password_prompt_output}"""
        Call Method    ${channel}    send    ${ru_password}\n
        Sleep    1 sec
        Call Method    ${channel}    recv    ${65535}
    END
    Call Method    ${channel}    send    ${command}\n
    Sleep    3 sec
    ${command_output}    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    close
    RETURN    ${command_output}

get required RU info
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get required info of RU
    ...    Argument: ${required_info}: e.g. cellDepType, physicalCellId, status, id, chBwDl, nrarfcnDl, band
    ...    Return: get value of required info, retun type may String, List, Dictonary
    [Arguments]    ${required_info}    ${RU_index}    ${gnb_index}=${0}    ${enb_index}=${0}
    ...    ${connection}=GNB_OAM    ${bts_type}=nr
    ${RU_list}    get RU list on bts    gnb_index=${gnb_index}    enb_index=${enb_index}
    ...    connection=${connection}    bts_type=${bts_type}
    ${RU_num}    Get Length    ${RU_list}
    ${RU_dist_name_list}    Create List
    FOR    ${index}    IN RANGE    ${RU_num}
        Append To List    ${RU_dist_name_list}    ${RU_list[${index}]['id']['configuration']}
    END
    FOR    ${index}    ${RU}    IN ENUMERATE    @{RU_dist_name_list}
        ${RU_search}    Split String    ${RU}    /
        Run keyword if    '${RU_search}[-1]' == 'RMOD-${RU_index}'
        ...    Run keywords    Set Suite Variable    ${RU_index_find}    ${index}    AND    Exit For Loop
    END
    Set Suite Variable    ${required_RU_info}    ${RU_list[${RU_index_find}]['status']['${required_info}']}
    [Return]    ${required_RU_info}

get RU list on bts
    [Documentation]    xiaodan.li@nokia-sbell.com
    ...    Description: get cell info of nr or lte or others
    ...    Return: list of cells info
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=GNB_OAM    ${bts_type}=nr    ${timeout}=900
    Run Keyword If    '${bts_type}' == 'nr'
    ...    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    connection=${connection}
    ...    ELSE IF    '${bts_type}' == 'lte'
    ...    Wait Until Keyword Succeeds    1 min    20 sec
    ...    coam.connect_to    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    name=${connection}
    ${hw_info}    coam.get_detected_hw_info    connection=${connection}    timeout=${timeout}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${list_RUs}

KW.CB013940 Precondition Preparation
    [Documentation]
    [Arguments]    ${ru_index}
    ${Unstable_threshold_t}    COAM_WebEM.GetParameterValue
    ...    distName=${MRBTSID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    abbr=Radio unit input voltage unstable threshold
    Run Keyword If    '${Unstable_threshold_t}' == '0'    Fatal Error    Fault4680 was disabled and test case end
    ${Timer_bts_1}    COAM_WebEM.GetParameterValue
    ...    distName=${MRBTSID}/EQM-1/APEQM-1
    ...    abbr=Input voltage unstable fault expiration timer for RUs
    ${Timer_bts_2}    Split String    ${Timer_bts_1}    ${SPACE}
    ${Timer_bts_3}    Convert To Integer    ${Timer_bts_2}[0]
    ${Timer_ru_1}    COAM_WebEM.GetParameterValue
    ...    distName=${MRBTSID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    abbr=Radio unit input voltage unstable fault expiration timer
    ${Timer_ru_2}    Split String    ${Timer_ru_1}    ${SPACE}
    ${Timer_ru_3}    Convert To Integer    ${Timer_ru_2}[0]
    Run Keyword If    ${Timer_ru_3} == 0    Set Suite Variable    ${Timer_13940}    ${DISABLE_TIMER}
    ...    ELSE IF    ${Timer_ru_3} > 0    Set Suite Variable    ${Timer_13940}    ${Timer_ru_3}
    ...    ELSE IF    ${Timer_bts_3} > 0    Set Suite Variable    ${Timer_13940}    ${Timer_bts_3}
    ...    ELSE    Set Suite Variable    ${Timer_13940}    ${DISABLE_TIMER}
    Run Keyword If    ${Timer_13940} == ${DISABLE_TIMER}    Fatal Error    CB013940 was disabled and test case end
    Log to console    CB013940 Precondition check done
    set test variable    ${Timer_bts}    ${Timer_bts_3}
    set test variable    ${Timer_ru}    ${Timer_ru_3}
    set test variable    ${Unstable_threshold}    ${Unstable_threshold_t}
    [Return]    ${Timer_bts}    ${Timer_ru}    ${Unstable_threshold}