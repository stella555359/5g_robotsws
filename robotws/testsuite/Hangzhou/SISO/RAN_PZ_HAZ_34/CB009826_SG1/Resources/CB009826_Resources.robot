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

TC.CB009826_SR_A_11_Common_Operability_regression_Site
    [Documentation]
    ...  Purpose:Check common operability
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Excute site block,site unblock,site reset
    ...    Step2: check cell status and 4g l3call
    ...    Step3: restore the configuration if needed
    [Arguments]
    log to console    Start Site Block and unblock
    ${cmd_lockNR}    Set Variable   AT+GTACT=10
    ${cmd_lockLTE}    Set Variable   at+gtact=2
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    Wait until keyword succeeds   1min   2s    selenium_sbts.block_site
    Wait Until Keyword Succeeds    120s   20s     Check fault report or not    fault_ID=${50}    alarm_ID=${7102}
    Sleep  60s
    Wait until keyword succeeds   1min   2s    selenium_sbts.unblock_site
    Run Keyword And Ignore error   COAM_WebEM.Logout
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    Check Alarm and stop robot testing when unexpected alarm raised
    log to console    Check NR l3call
    @{NR_UE}    create list    0
    Set To Dictionary    ${CASE_INPUT_CB009826['MultiUECFG']}    ue_index_for_call     ${NR_UE}
    MultiRATUE.L3Call    UECFG=${CASE_INPUT_CB009826['MultiUECFG']}
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    log to console    Start site reset
    Wait until keyword succeeds   1min   2s    selenium_sbts.reset_site
    Run Keyword And Ignore error   COAM_WebEM.Logout
    wait until keyword succeeds   15min   15s    COAM_Admin.CheckAllCellsOnair
#    log to console    Check LTE l3call
#    @{LTE_UE}    create list    1
#    Set To Dictionary    ${CASE_INPUT_CB009826['MultiUECFG']}    ue_index_for_call     ${LTE_UE}
#    MultiRATUE.L3Call    UECFG=${CASE_INPUT_CB009826['MultiUECFG']}    cmd=${cmd_lockLTE}

TC.CB009826_SR_B_27_Secondary_core_Power_reset
    [Documentation]
    [Arguments]    ${PB_ASIK_IP}=${CASE_INPUT_CB009826['B_27']['PB_IP']}
    ...            ${PB_ASIK_PORT}=${CASE_INPUT_CB009826['B_27']['PB_Port']}
    ...            ${model}=${CASE_INPUT_CB009826['B_27']['PB_Vendor']}
    log to console    Power reset secondary core
    Wait until keyword succeeds   1min   5s    Power.ResetgNB    ${PB_ASIK_IP}    ${PB_ASIK_PORT}    ${model}
    Sleep    300s
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    Check Alarm and stop robot testing when unexpected alarm raised
    log to console    Check NR l3call
    ${cmd_lockNR}    Set Variable   AT+GTACT=10
    @{NR_UE}    create list    0
    Set To Dictionary    ${CASE_INPUT_CB009826['MultiUECFG']}    ue_index_for_call     ${NR_UE}
    MultiRATUE.L3Call    UECFG=${CASE_INPUT_CB009826['MultiUECFG']}

TC1.CB009826_CB006533_BTS_Power_Reset
    [Documentation]
    ...  Purpose:Check BTS power reset
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Power off SMOD and RMOD
    ...    Step2: Power on SMOD and RMOD
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC1']['loop_times']}
            ...  ${SMOD_index_list}=${CASE_INPUT_CB009826['TC1']['SMOD_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC1']['duration_target']}
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to Power Reset  SMODs loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Power off and Power on SMODs  SMOD_index_list=${SMOD_index_list}
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

TC2.CB009826_CB006533 Reset Site
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC2']['loop_times']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC2']['duration_target']}
    log to console    Start to Reset site
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        log to console    Start site reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_site
        Run Keyword And Ignore error   COAM_WebEM.Logout
        wait until keyword succeeds   15min   15s    COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC3.CB009826_CB006533 Block/Unblock Site
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC3']['loop_times']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC3']['duration_target']}
    log to console    Start to Block/Unblock Site
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        log to console    Start block/unblock site loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        Wait until keyword succeeds   1min   2s    selenium_sbts.block_site
        Wait Until Keyword Succeeds    120s   20s     Check fault report or not    fault_ID=${50}    alarm_ID=${7102}
        Sleep  60s
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.unblock_site
        Run Keyword And Ignore error   COAM_WebEM.Logout
        wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC4.CB009826_CB006533 Reset RAT
     [Documentation]
    [Arguments]  ${loop_times_NR}=${CASE_INPUT_CB009826['TC4']['loop_times_NR']}
            ...  ${duration_target_NR}=${CASE_INPUT_CB009826['TC4']['duration_target_NR']}
            ...  ${loop_times_LTE}=${CASE_INPUT_CB009826['TC4']['loop_times_LTE']}
            ...  ${duration_target_LTE}=${CASE_INPUT_CB009826['TC4']['duration_target_LTE']}
    log to console    Start to Reset NR RAT
    ${duration_KPI_NR}      set variable    0
    ${duration_KPI_LTE}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times_NR}+1
        log to console    Start NR RAT reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_nr    with_graceful=${True}    with_hard=${True}
        Run Keyword And Ignore error   COAM_WebEM.Logout
        Sleep  60s
        wait until keyword succeeds   15min   20s    COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI_NR}=    Evaluate    ${duration_tmp} + ${duration_KPI_NR}
        Set test Variable    ${duration_KPI_NR}    ${duration_KPI_NR}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI_NR}/${loop_times_NR}, 2)
    Should be true     ${duration_KPI} < ${duration_target_NR}
    log to console    Start to Reset LTE RAT
        FOR  ${i}  IN RANGE  1  ${loop_times_LTE}+1
        log to console    Start LTE RAT reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.reset_lte
        Run Keyword And Ignore error   COAM_WebEM.Logout
        Sleep  10s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI_LTE}=    Evaluate    ${duration_tmp} + ${duration_KPI_LTE}
        Set test Variable    ${duration_KPI_LTE}    ${duration_KPI_LTE}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI_LTE}/${loop_times_LTE}, 2)
    Should be true     ${duration_KPI_LTE} < ${duration_target_LTE}

TC5.Block/Unblock RAT
    [Documentation]
    [Arguments]  ${loop_times_NR}=${CASE_INPUT_CB009826['TC5']['loop_times_NR']}
            ...  ${duration_target_NR}=${CASE_INPUT_CB009826['TC5']['duration_target_NR']}
            ...  ${loop_times_LTE}=${CASE_INPUT_CB009826['TC5']['loop_times_LTE']}
            ...  ${duration_target_LTE}=${CASE_INPUT_CB009826['TC5']['duration_target_LTE']}
    log to console    Start to Block/unblock NR RAT
    ${duration_KPI_NR}      set variable    0
    ${duration_KPI_LTE}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times_NR}+1
        log to console    Start NR RAT reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        Wait until keyword succeeds   1min   2s    selenium_sbts.block_rat    rat=NR
        Wait Until Keyword Succeeds    120s   20s     Check fault report or not    fault_ID=${4614}    alarm_ID=${7102}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.unblock_rat    rat=NR
        Run Keyword And Ignore error   COAM_WebEM.Logout
        Sleep  10s
        wait until keyword succeeds   15min   20s    COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI_NR}=    Evaluate    ${duration_tmp} + ${duration_KPI_NR}
        Set test Variable    ${duration_KPI_NR}    ${duration_KPI_NR}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI_NR}/${loop_times_NR}, 2)
    Should be true     ${duration_KPI} < ${duration_target_NR}
    log to console    Start to Block/unblock LTE RAT
        FOR  ${i}  IN RANGE  1  ${loop_times_LTE}+1
        log to console    Start LTE RAT reset loop${i}
        Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.block_rat    rat=LTE
        Wait Until Keyword Succeeds    120s   20s     Check fault report or not    fault_ID=${4614}    alarm_ID=${7102}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   1min   2s    selenium_sbts.unblock_rat    rat=LTE
        Run Keyword And Ignore error   COAM_WebEM.Logout
        Sleep  10s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI_LTE}=    Evaluate    ${duration_tmp} + ${duration_KPI_LTE}
        Set test Variable    ${duration_KPI_LTE}    ${duration_KPI_LTE}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI_LTE}/${loop_times_LTE}, 2)
    Should be true     ${duration_KPI_LTE} < ${duration_target_LTE}

TC6.CB009826_CB006533 Lock/unlock AMF
    [Documentation]
    [Arguments]
    log to console    Start to Lock AMF
    ${cmd_lockNR}    Set Variable   AT+GTACT=10
    ${cmd_lockLTE}    Set Variable   at+gtact=2
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    Wait until keyword succeeds   2min   20s    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-37234/NRBTS-37234/SERVEDAMF-1    filter_param=Administrative state
            ...    new_value=Locked   abbr=administrativeState
    Wait until keyword succeeds   2min   20s    selenium_coam.activate_plan
            ...    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    Sleep  60s
    Wait until keyword succeeds   2min   20s    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-37234/NRBTS-37234/SERVEDAMF-1    filter_param=Administrative state
            ...    new_value=Unlocked   abbr=administrativeState
    Wait until keyword succeeds   2min   20s    selenium_coam.activate_plan
            ...    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    @{NR_UE}    create list    0
    Set To Dictionary    ${CASE_INPUT_CB009826['MultiUECFG']}    ue_index_for_call     ${NR_UE}
    MultiRATUE.L3Call    UECFG=${CASE_INPUT_CB009826['MultiUECFG']}

TC7.CB009826_CB006533 Reset BBMOD
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC7']['loop_times']}
            ...  ${BB_index_list}=${CASE_INPUT_CB009826['TC7']['BB_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC7']['duration_target']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to reset BBMODs loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Reset All BBMODs  BB_index_list=${BB_index_list}
        Sleep  10s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC8.CB009826_CB006533 Lock/unlock BBMOD
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC8']['loop_times']}
            ...  ${BB_index_list}=${CASE_INPUT_CB009826['TC8']['BB_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC8']['duration_target']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to lock BBMODs loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Lock All BBMODs  BB_index_list=${BB_index_list}
        Sleep  10s
        Wait until keyword succeeds   2min   20s    Unlock All BBMODs  BB_index_list=${BB_index_list}
        Sleep  60s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC9.CB009826_CB006533 Reset Cell
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC9']['loop_times']}
            ...  ${cell_index_list}=${CASE_INPUT_CB009826['TC9']['cell_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC9']['duration_target']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to lock BBMODs loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Reset All cells  cell_index_list=${cell_index_list}
        Sleep  10s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC10.CB009826_CB006533 Block/unblock Cell/Cell Group
    [Documentation]
    [Arguments]  ${cell_loop_times}=${CASE_INPUT_CB009826['TC10']['cell_loop_times']}
            ...  ${cell_index_list}=${CASE_INPUT_CB009826['TC10']['cell_index_list']}
            ...  ${cell_duration_target}=${CASE_INPUT_CB009826['TC10']['cell_duration_target']}
    ${cell_duration_KPI}      set variable    0
    ${cellg_duration_KPI}      set variable    0
    Log to console    Start to Block and Unblock cells
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${i}  IN RANGE  1  ${cell_loop_times}+1
        Log to console    start to  Block and Unblock cells loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Block All cells  cell_index_list=${cell_index_list}
        Sleep  10s
        Wait until keyword succeeds   2min   20s    Unblock All cells  cell_index_list=${cell_index_list}
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${cell_duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${cell_loop_times}, 2)
    Should be true     ${duration_KPI} < ${cell_duration_target}
#    Log to console    Start to lock and Unlock cellgroups
#    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
#    FOR  ${i}  IN RANGE  1  ${cellg_loop_times}+1
#        Log to console    start to  Block and Unblock cells loop${i}
#        ${start_time}    Get Time    epoch
#        Wait until keyword succeeds   2min   20s    Lock All cellgroups  cellg_index_list=${cellg_index_list}
#        Sleep  10s
#        Wait until keyword succeeds   2min   20s    Unlock All ellgroups  cellg_index_list=${cellg_index_list}
#        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
#        ${end_time}    Get Time    epoch
#        Check Alarm and stop robot testing when unexpected alarm raised
#        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
#        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${cellg_duration_KPI}
#        Set test Variable    ${duration_KPI}    ${duration_KPI}
#    END
#    Run Keyword And Ignore error   COAM_WebEM.Logout
#    ${duration_KPI}    Evaluate   round(${duration_KPI}/${cellg_loop_times}, 2)
#    Should be true     ${duration_KPI} < ${cellg_duration_target}

TC11.CB009826_CB006533 Reset RU
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC11']['loop_times']}
            ...  ${RU_index_list}=${CASE_INPUT_CB009826['TC11']['RU_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC11']['duration_target']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to Reset RUs loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Reset All RUs  RU_index_list=${RU_index_list}
        Sleep  10s
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC12.CB009826_CB006533 Lock/unlock RU
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC12']['loop_times']}
            ...  ${RU_index_list}=${CASE_INPUT_CB009826['TC12']['RU_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC12']['duration_target']}
    ${duration_KPI}      set variable    0
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to Reset Lock and unlock Rus loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Lock All RUs  RU_index_list=${RU_index_list}
        Sleep  10s
        Wait until keyword succeeds   2min   20s    Unlock All RUs  RU_index_list=${RU_index_list}
        wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
        ${end_time}    Get Time    epoch
        Check Alarm and stop robot testing when unexpected alarm raised
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
    END
    Run Keyword And Ignore error   COAM_WebEM.Logout
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Should be true     ${duration_KPI} < ${duration_target}

TC13.CB009826_CB006533 RU power off and power on
    [Documentation]
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009826['TC13']['loop_times']}
            ...  ${RU_index_list}=${CASE_INPUT_CB009826['TC13']['RU_index_list']}
            ...  ${duration_target}=${CASE_INPUT_CB009826['TC13']['duration_target']}
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Log to console    start to Power Reset  Rus loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   20s    Power off and Power on RUs  RU_index_list=${RU_index_list}
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

TC14.CB009826_CB006533 Delta Plan for parameter requires object locking and bts restart
    [Documentation]
    [Arguments]
    log to console    Start to modify paramter requires object locking, e.g, pMax
    ${cmd_lockNR}    Set Variable   AT+GTACT=10
    Wait until keyword succeeds   2min   20s    COAM_WebEM.Login
    Wait until keyword succeeds   2min   20s    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-37234/NRBTS-37234/NRCELL-4
            ...    filter_param=Maximum output power
            ...    new_value=29   abbr=pMax
    Wait until keyword succeeds   2min   20s    selenium_coam.activate_plan
            ...    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    Sleep  60s
    @{NR_UE}    create list    0
    Set To Dictionary    ${CASE_INPUT_CB009826['MultiUECFG']}    ue_index_for_call     ${NR_UE}
    Run Keyword And Ignore error    MultiRATUE.L3Call    UECFG=${CASE_INPUT_CB009826['MultiUECFG']}
    log to console    Start to modify paramter requires object locking
    Wait until keyword succeeds   2min   20s    selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-37234/MNL-1/MNLENT-1/SYNC-1/TIME-1    filter_param=Time zone
            ...    new_value=(GMT+2) Europe/Helsinki   abbr=timeZone
    Wait until keyword succeeds   2min   20s    selenium_coam.activate_plan
            ...    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
    Sleep  120s
    wait until keyword succeeds   15min   20s   COAM_Admin.CheckAllCellsOnair
    @{NR_UE}    create list    0
    Set To Dictionary    ${CASE_INPUT_CB009826['MultiUECFG']}    ue_index_for_call     ${NR_UE}
    Run Keyword And Ignore error   MultiRATUE.L3Call    UECFG=${CASE_INPUT_CB009826['MultiUECFG']}

Power off and Power on SMODs
    [Documentation]
    [Arguments]  ${SMOD_index_list}=[1,2]
    FOR  ${SMOD_index}  IN  @{SMOD_index_list}
        Wait until keyword succeeds   2min   20s    Power.ResetgNB
            ...    pdu_ip=${CASE_INPUT_CB009826['TC1']['SMOD${SMOD_index}']['IP']}
            ...    Port_Number=${CASE_INPUT_CB009826['TC1']['SMOD${SMOD_index}']['Port']}
            ...    model=${CASE_INPUT_CB009826['TC1']['SMOD${SMOD_index}']['Model']}
        Sleep  5s
    END

Power off and Power on RUs
    [Documentation]
    [Arguments]  ${RU_index_list}=[1,2]
    FOR  ${RU_index}  IN  @{RU_index_list}
        Wait until keyword succeeds   2min   20s    Power.ResetgNB
            ...    pdu_ip=${CASE_INPUT_CB009826['TC13']['RU${RU_index}']['IP']}
            ...    Port_Number=${CASE_INPUT_CB009826['TC13']['RU${RU_index}']['Port']}
            ...    model=${CASE_INPUT_CB009826['TC13']['RU${RU_index}']['Model']}
        Sleep  5s
    END

Lock All RUs
    [Documentation]
    [Arguments]  ${RU_index_list}=[1,2]
    FOR  ${RU_index}  IN  @{RU_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.lock_ru    ru_index=${RU_index}
        Sleep  5s
    END

Unlock All RUs
    [Documentation]
    [Arguments]  ${RU_index_list}=[1,2]
    FOR  ${RU_index}  IN  @{RU_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.unlock_ru    ru_index=${RU_index}
        Sleep  5s
    END

Reset All RUs
    [Documentation]
    [Arguments]  ${RU_index_list}=[1,2]
    FOR  ${RU_index}  IN  @{RU_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.reset_ru    ru_index=${RU_index}
        Sleep  5s
    END

Lock All cellgroups
    [Documentation]
    [Arguments]  ${cellg_index_list}=[1,2]
    FOR  ${cellg_index}  IN  @{cellg_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.lock_cell_group    cell_group_idx=${cellg_index}
        Sleep  5s
    END

Unlock All ellgroups
    [Documentation]
    [Arguments]  ${cellg_index_list}=[1,2]
    FOR  ${cellg_index}  IN  @{cellg_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.unlock_cell_group    cell_group_idx=${cellg_index}
        Sleep  5s
    END

Block All cells
    [Documentation]
    [Arguments]  ${cell_index_list}=[1,2]
    FOR  ${cell_index}  IN  @{cell_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.block_cell    cell_idx=${cell_index}
        Sleep  5s
    END

Unblock All cells
    [Documentation]
    [Arguments]  ${cell_index_list}=[1,2]
    FOR  ${cell_index}  IN  @{cell_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.unblock_cell    cell_idx=${cell_index}
        Sleep  5s
    END


Reset All cells
    [Documentation]
    [Arguments]  ${cell_index_list}=[1,2]
    FOR  ${cell_index}  IN  @{cell_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.reset_cell    cell_idx=${cell_index}
        Sleep  5s
    END

Lock All BBMODs
    [Documentation]
    [Arguments]  ${BB_index_list}=[1,2]
    FOR  ${BB_index}  IN  @{BB_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.lock_baseband    baseband_idx=${BB_index}
        Sleep  5s
    END

Unlock All BBMODs
    [Documentation]
    [Arguments]  ${BB_index_list}=[1,2]
    FOR  ${BB_index}  IN  @{BB_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.unlock_baseband    baseband_idx=${BB_index}
        Sleep  5s
    END

Reset All BBMODs
    [Documentation]
    [Arguments]  ${BB_index_list}=[1,2]
    Log to console    Start to reset BBMOD
    FOR  ${BB_index}  IN  @{BB_index_list}
        Wait until keyword succeeds   2min   20s    selenium_sbts.reset_baseband   baseband_index=${BB_index}
        Sleep  5s
    END

Power reset HWs
    [Arguments]  ${model}=HBTE
    log to console    Power off and on SMODs and RMODs
    FOR  ${i}  IN RANGE  1  ${CASE_INPUT_CB009826['TC1']['PB_Num']}+1
        Wait until keyword succeeds   1min   5s    Power.ResetgNB
        ...    pdu_ip=${CASE_INPUT_CB009826['TC1']['PB${i}']['IP']}
        ...    Port_Number=${CASE_INPUT_CB009826['TC1']['PB${i}']['Port']}
        ...    model=${CASE_INPUT_CB009826['TC1']['PB${i}']['Model']}
    END

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
    COAM_WebEM.Login
    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
    ${Active_SW_version}    string.split string    string=${version}[Active]
    set suite variable    ${Active_SW_version}
    ${SW1}    string.split string    string=${version}[Active]    separator=_
    ${Active_SwVersion_9826}     convert to string    ${SW1}[-5]
    set suite variable    ${Active_SwVersion_9826}
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion_9826}_Configuration_scf_TL2227.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    [Return]   ${gNb_CuType}

KW.TestSuilt.Stop
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion_9826}_Configuration_scf_TL2227.xml
    wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

Teardown Case
    Teardown case if case fail
    TestCase.Stop
    Run Keyword And Ignore error    btslog.stopbtslogcollectionandgetlog

Teardown case if case fail
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
    [Arguments]    ${fault_ID}=NULL    ${alarm_ID}=NULL
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

TestCase.Start 9826
    robot_common_operations.Common Case Setup
    CI_interface.Common Case Setup
    Run Keyword And Ignore Error    btslog.startbtslogcollection
