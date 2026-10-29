*** Settings ***
Documentation      author: Bin Wang
...                 contact: bin.3.wang@nokia-sbell.com
...                This robot file is for CB008278

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   coam
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
*** Variables ***
${USER_LOG_DIR}        /opt/ute/Logs
${WTS_FILE_PATH}       ${tl.core.dir_path}
${TS_CASE_LOG_PATH}      ${output_dir}
${SAVE LOG DIRECTORY}      ${output_dir}
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT+0) Europe/London
${if_pdl_check}    True

${UTE_IP}              ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}        ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}        ${tl.test_pc.default_ssh_connection_details.password}

${ASIK_LMP_IP_Secondary}    ${tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr}

${ASIK_LMP_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_LMP_IP_URL}          https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_IP}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${WEBUI_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_URL}                https://${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}

${NRBTS_ID}                 ${tl.gnbs[0].global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].instance_id}
${distname}                 ${MRBTS_ID}/${NRBTS_ID}

${PB_ASIK_IP}     ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${model}    ${tl.gnbs[0].du.airscale.common_units[0].pdu_port.pdu.vendor}

${LOGIN_BOX}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[2]/input
${PASS_BOX}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[3]/input
${URL_LMP}       192.168.255.129
${LEGAL}=     xpath=//html/body/div[1]/div/div/ui-modal-renderer/login-banner-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button[1]/button
${LOGIN_BUTTON}=    xpath=//*[@id="login-view"]/div/div[1]/div[1]/ng-view/div/form/div[4]/div[1]/div/ui-button[1]/button

##################define these variable for convenient############################
${ALIAS_ASIK}     asik
${ALIAS_ASIK_SLAVE}    asik_slave
${ALIAS_UTE}      ute
########################END of alias Define#######################################
${BTSSWServerPath}          https://artifactory-hz1.int.net.nokia.com/artifactory/mnp5g-central-public-remote/System_Release
*** Keywords ***
TC1.CB009301_SR_A disable CB009301 and enable CB009301
    [Documentation]
    [Arguments]  ${dist_name}=${CASE_INPUT_CB009301['TC1']['dist_name']}
            ...  ${filter_param}=${CASE_INPUT_CB009301['TC1']['filter_param']}
            ...  ${9301_Mo_num}=${CASE_INPUT_CB009301['TC1']['9301_Mo_num']}
    log to console    Step1:Start to disable CB009301
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    Wait until keyword succeeds   2min   20s    COAM_WebEM.ModifyAndActiveParameters
            ...    DistName=${dist_name}
            ...    FilterParam=${filter_param}
            ...    NewValue=false
    wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
    log to console    Step2:Start to check MOs should be not exist
    Wait until keyword succeeds   2min   30s     KW.check CB009301 Mos should not exist
    log to console    Step3:Start to enable CB009301
    Wait until keyword succeeds   2min   20s    COAM_WebEM.ModifyAndActiveParameters
            ...    DistName=${dist_name}
            ...    FilterParam=${filter_param}
            ...    NewValue=true
    wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
    log to console    Step4:Start to check MOs and results should exist
    Wait until keyword succeeds   2min   30s     KW.check CB009301 Mos and results should exist
    ...    9301_Mo_num=${9301_Mo_num}
    runkeyword and continue on failure    COAM_WebEM.Logout

TC2.CB009301_SR_A Reset Site
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009301['TC2']['loop_times']}
            ...  ${duration_target}=${CASE_INPUT_CB009301['TC2']['duration_target']}
            ...  ${9301_Mo_num}=${CASE_INPUT_CB009301['TC1']['9301_Mo_num']}
     Log To Console    enable feature CB009301
     wait until keyword succeeds   15min    10s    COAM_WebEM.Login
     ${actEcpriDelayMeasurement_Value}    selenium_coam.get_parameter_value
     ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1     filter_param=Activate eCPRI delay measurement    abbr=actEcpriDelayMeasurement
     run keyword if    "${actEcpriDelayMeasurement_Value}"=="false"
     ...    selenium_coam.set_parameter_value
     ...    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1     filter_param=Activate eCPRI delay measurement    node_index=${0}
     ...    new_value=true   abbr=actEcpriDelayMeasurement
     Log To Console    validate and check error not exist on WebEM.
     selenium_coam.validate_plan
     ${error}    selenium_coam.get_relation_errors
     Should Be Empty     ${error}
     Log To Console    Do activation
     selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
     ...    timeout=600
     sleep    20s
     run keyword and ignore error    COAM_WebEM.Logout
     wait until keyword succeeds    15min    20s     COAM_Admin.CheckAllCellsOnair
     log to console    Start to Reset site
     ${duration_KPI}      set variable    0
     FOR  ${i}  IN RANGE  1  ${loop_times}+1
         log to console   loop${i}
         Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
         ${start_time}    Get Time    epoch
         Wait until keyword succeeds   1min   2s    selenium_sbts.reset_site
         Run Keyword And Ignore error   COAM_WebEM.Logout
         wait until keyword succeeds   15min   15s    COAM_Admin.CheckAllCellsOnair
         ${end_time}    Get Time    epoch
         ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
         ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
         Set test Variable    ${duration_KPI}    ${duration_KPI}
         Wait until keyword succeeds   2min   30s    KW.check CB009301 Mos and results should exist
         ...     9301_Mo_num=${9301_Mo_num}
     END
     ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
     Should be true     ${duration_KPI} < ${duration_target}


TC3.CB009301_SR_A Reset RAT
     [Documentation]
    [Arguments]  ${loop_times_NR}=${CASE_INPUT_CB009301['TC3']['loop_times']}
            ...  ${duration_target_NR}=${CASE_INPUT_CB009301['TC3']['duration_target']}
            ...  ${9301_Mo_num}=${CASE_INPUT_CB009301['TC1']['9301_Mo_num']}
    log to console    Start to Hard Reset NR RAT
    ${duration_KPI_NR}      set variable    0
    ${duration_KPI_LTE}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times_NR}+1
        log to console    Start NR RAT reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login    version=${Active_SwVersion}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_nr    with_graceful=${True}    with_hard=${True}
        Run Keyword And Ignore error   COAM_WebEM.Logout
        Sleep  90s
        wait until keyword succeeds   15min   20s    COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI_NR}=    Evaluate    ${duration_tmp} + ${duration_KPI_NR}
        Set test Variable    ${duration_KPI_NR}    ${duration_KPI_NR}
        Wait until keyword succeeds   2min   30s    KW.check CB009301 Mos and results should exist
        ...     9301_Mo_num=${9301_Mo_num}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI_NR}/${loop_times_NR}, 2)
    Should be true     ${duration_KPI} < ${duration_target_NR}

    log to console    Start to SW Reset NR RAT
        FOR  ${i}  IN RANGE  1  ${loop_times_NR}+1
        log to console    Start NR RAT reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login    version=SBTS24R3
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_nr    with_graceful=${False}    with_hard=${False}
        Run Keyword And Ignore error   COAM_WebEM.Logout
        Sleep  30s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI_NR}=    Evaluate    ${duration_tmp} + ${duration_KPI_}
        Set test Variable    ${duration_KPI_NR}    ${duration_KPI_NR}
        Wait until keyword succeeds   2min   30s    KW.check CB009301 Mos and results should exist
        ...     9301_Mo_num=${9301_Mo_num}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI_NR}/${loop_times_NR}, 2)
    Should be true     ${duration_KPI_NR} < ${duration_target_NR}

TC4.CB009301_SR_A Reset RU
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009301['TC4']['loop_times']}
            ...  ${RU_index_list}=${CASE_INPUT_CB009301['TC4']['RU_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009301['TC4']['duration_target']}
            ...  ${9301_Mo_num}=${CASE_INPUT_CB009301['TC1']['9301_Mo_num']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${RU_index}  IN  @{RU_index_list}
        Reset RUs and check 9301 results with loop    RU_index=${RU_index}   loop_times=${loop_times}
        ...   duration_target=${duration_target}
        ...   9301_Mo_num=${9301_Mo_num}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout


KW.check CB009301 Mos should not exist
    [Documentation]
    [Arguments]
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${CB00930_results}    coam.get_parameter_by_class    class_name=FHLKDLY_R    connection=COAM
    ${9301_Mo_num_tmp}    Get Length    ${CB00930_results}
    Should be true    ${9301_Mo_num_tmp}==0
    Log to console     CB009301 Mos Not created!
    COAM_Admin.Logout

KW.check CB009301 Mos and results should exist
    [Documentation]
    [Arguments]   ${9301_Mo_num}=1
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${CB00930_results}    coam.get_parameter_by_class    class_name=FHLKDLY_R    connection=COAM
    ${9301_Mo_num_tmp}    Get Length    ${CB00930_results}
    Should be true    ${9301_Mo_num_tmp}==${9301_Mo_num}
    Log to console     CB009301 Mos created, will check CB009301 results next!
    FOR  ${item}  IN  @{CB00930_results}
        Should not be empty  '${item['parameters']['dlMinDelay']}'
        Should not be empty  ${item['parameters']['duMacAddr']}
        Should not be empty  '${item['parameters']['ulMinDelay']}'
        Should not be empty  ${item['parameters']['ruMacAddr']}
        Should be true    ${item['parameters']['dlMinDelay']} > 0
        Should be true    ${item['parameters']['ulMinDelay']} > 0
    END
    Log to console    CB009301 results Not empty and updated!
    COAM_Admin.Logout


Reset RUs and check 9301 results with loop
    [Documentation]
    [Arguments]  ${RU_index}=1   ${loop_times}=3    ${duration_target}=600   ${9301_Mo_num}=1    ${duration_KPI}=0
    Log to console    start to Reset RU-${RU_index}
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    selenium_sbts.reset_ru    ru_index=${RU_index}
        Sleep  100s
        wait until keyword succeeds   15min   5s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
        Wait until keyword succeeds   2min   30s    KW.check CB009301 Mos and results should exist
        ...     9301_Mo_num=${9301_Mo_num}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}
    Log to console    RU-${RU_index} reset duration is ${duration_KPI}



Reset BBMOD with loop
    [Documentation]
    [Arguments]  ${BB_index}=1    ${loop_times}=3    ${duration_target}=600    ${duration_KPI}=0
    Log to console    start to reset BBMOD-${BB_index}
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    selenium_sbts.reset_baseband   baseband_index=${BB_index}
        Sleep  10s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}
    Log to console    BBMOD-${BB_index} reset duration is ${duration_KPI}

MultiRATUE.L3Call
    [Arguments]    ${UECFG}=NULL    ${default_ue_index}=0    ${cmd}=NULL
    Run Keyword And Continue On Failure    MultiUE.PrepareUE
    ...    UECFG=${UECFG}    default_ue_index=${default_ue_index}       singel_loop=1
    ${return}    spark.send_at_command_on_ue    command=${cmd}    ue_alias=UE_${default_ue_index}
    Run Keyword And Ignore Error    Should Contain    ${return}    OK
    sleep   10
    Run Keyword And Continue On Failure    MultiUE.Attach               UECFG=${UECFG}    default_ue_index=${default_ue_index}
    sleep   10
    Run Keyword And Continue On Failure    MultiUE.StartDLTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StartULTraffic       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.CheckThoughput       UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StopDLTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.StopULTraffic        UECFG=${UECFG}    default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure    MultiUE.Detach               UECFG=${UECFG}    default_ue_index=${default_ue_index}

L3 call case teardown
    Run Keyword And Ignore Error    Run keywords
    ...    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    ...    AND    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    Run Keyword And Ignore Error    Power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}


KW.TestSuilt.Start
    TestSuilt.Start
    Import Variables    ${CFGFILE_PATH}/TLConfiguration.py
    set suite variable    ${OAM_TYPE}    COAM
    set suite variable    ${TLDelta_PATH_ON_GIT}    ${CFGFILE_PATH}
    gNB.FormatBTSID       MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}
    set suite variable    ${dist_name}   ${MRBTS_ID}/${NRBTS_ID}
    ${gNb_CuType}   KW.CP_GetgNBType
    set suite variable    ${gNb_CuType}
    ${gNb_CuType}   KW.CP_GetgNBType
    set suite variable    ${gNb_CuType}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNb_CuType}    Set Variable   ${BTSInfo['gNbCuType']}
#    COAM_WebEM.Login
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    ${Active_SW_version}    string.split string    string=${version}[Active]
#    set suite variable    ${Active_SW_version}
#    ${SW1}    string.split string    string=${version}[Active]    separator=_
#    ${Active_SwVersion111}     convert to string    ${SW1}[-5]
#    set suite variable    ${Active_SwVersion111}
#    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion111}_SCF_with_CB009301.xml
#    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    [Return]   ${gNb_CuType}

KW.TestSuilt.Stop
#    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion111}_SCF_with_CB009301.xml
#    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

Teardown Case
    Teardown case if case fail
    TestCase.Stop
    Run Keyword And Ignore error    btslog.stopbtslogcollectionandgetlog

Teardown case if case fail
    [Arguments]
    Run Keyword And Ignore Error    BtsLog.StopBTSlogCollectionandGetlog
    log     ${TEST STATUS}
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    WEBUI.Collect snapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
    Run Keyword And Ignore Error    GNB.kill admin process
    Run Keyword And Ignore Error    run   command=killall firefox
    Conn.ResetCache

GNB.kill admin process
    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9

WEBUI.Collect snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${LOG_PATH}

KW.CP_GetgNBType
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNb_CuType}    Set Variable   ${BTSInfo['gNbCuType']}
    [Return]   ${gNb_CuType}

Check fault report or not
    [Arguments]   ${fault_ID}=NULL    ${alarm_ID}=NULL    ${connection}=Trunk_roll_check
    run keyword if    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    @{expect_fault}    Create List    ${fault_ID}
    @{expect_alarm}    Create List    ${alarm_ID}
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=${100}
    FOR   ${active_alarm}    IN   @{active_alarms}
            ${check_fault}    run keyword and return status    Collections.List Should Contain Value    ${expect_fault}
            ...    ${active_alarm['faultId']}
            Continue For Loop If    '${check_fault}'=='False'
            ${check_alarm}    run keyword and return status    Collections.List Should Contain Value    ${expect_alarm}
            ...    ${active_alarm['alarmId']}
            Should be true    '${check_alarm}'=='True'
    END
    [Teardown]  coam.teardown    connection=${connection}

TestCase.Start.9301
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000,7300
    CI_interface.Common Case Setup
    Run Keyword And Ignore Error    btslog.startbtslogcollection
