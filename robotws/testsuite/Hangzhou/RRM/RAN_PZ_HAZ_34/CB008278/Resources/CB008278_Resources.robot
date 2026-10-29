*** Settings ***
Documentation      author: Bin Wang
...                 contact: bin.3.wang@nokia-sbell.com
...                This robot file is for CB008278

Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py
Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
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

TC.CB008278-D_003_F+2T_DL_F+T_UL_CA_CB008406_AWPQZ
    [Documentation]
    ...  Purpose:UL CA traffic and through put check
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Commission SCF with CA configuration
    ...    Step2: Check cell status
    ...    Step3: UE attach to target cell and start DL&UL traffic
    ...    Step4: Wait Scell addition and then check the TP reach the peak or not
    ...    Step5: restore the configuration if needed
    [Arguments]   ${cell_list}=${CASE_INPUT_CB008278['D_003']['cell_list']}
    ...           ${ul_throughput}=${CASE_INPUT_CB008278['D_003']['ul_throughput']}
    ...           ${ul_expect}=${CASE_INPUT_CB008278['D_003']['ul_expect']}
    ...           ${dl_throughput}=${CASE_INPUT_CB008278['D_003']['dl_throughput']}
    ...           ${dl_expect}=${CASE_INPUT_CB008278['D_003']['dl_expect']}
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion_8278}_Configuration_scf_MRBTS-11119_TL2209_NR_D_003.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    L3call and check TP     ${cell_list}    ${ul_throughput}    ${dl_throughput}    ${ul_expect}    ${dl_expect}
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

TC.CB008278-C_003_3T+1F_DL_CA_5GC001116_0ms_AWPQZ
    [Documentation]
    ...  Purpose:UL CA traffic and through put check
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Commission SCF with CA configuration
    ...    Step2: Check cell status
    ...    Step3: UE attach to target cell and start DL&UL traffic
    ...    Step4: Wait Scell addition and then check the TP reach the peak or not
    ...    Step5: restore the configuration if needed
    [Arguments]   ${cell_list}=${CASE_INPUT_CB008278['C_003']['cell_list']}
    ...           ${ul_throughput}=${CASE_INPUT_CB008278['C_003']['ul_throughput']}
    ...           ${ul_expect}=${CASE_INPUT_CB008278['C_003']['ul_expect']}
    ...           ${dl_throughput}=${CASE_INPUT_CB008278['C_003']['dl_throughput']}
    ...           ${dl_expect}=${CASE_INPUT_CB008278['C_003']['dl_expect']}
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion_8278}_Configuration_scf_MRBTS-11119_TL2209_NR_C_003.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    L3call and check TP     ${cell_list}    ${ul_throughput}    ${dl_throughput}    ${ul_expect}    ${dl_expect}
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

TC.CB008278-B_004_UE_attach_and_traffic_5GC001116_0ms_AWPQZ
    [Documentation]
    ...  Purpose:UL CA traffic and through put check
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Commission SCF with CA configuration
    ...    Step2: Check cell status
    ...    Step3: UE attach to target cell and start DL&UL traffic
    ...    Step4: Wait Scell addition and then check the TP reach the peak or not
    ...    Step5: restore the configuration if needed
    [Arguments]   ${cell_list}=${CASE_INPUT_CB008278['B_004']['cell_list']}
    ...           ${ul_throughput}=${CASE_INPUT_CB008278['B_004']['ul_throughput']}
    ...           ${ul_expect}=${CASE_INPUT_CB008278['B_004']['ul_expect']}
    ...           ${dl_throughput}=${CASE_INPUT_CB008278['B_004']['dl_throughput']}
    ...           ${dl_expect}=${CASE_INPUT_CB008278['B_004']['dl_expect']}
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion_8278}_Configuration_scf_MRBTS-11119_TL2209_NR_B_004.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    L3call and check TP with paging     ${cell_list}    ${ul_throughput}    ${dl_throughput}    ${ul_expect}    ${dl_expect}
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

TC.CB008278-F_006_UE_attach_and_traffic_coreset0_on_3symbols_cce_split_CB008406_AWPQZ
    [Documentation]
    ...  Purpose:UL CA traffic and through put check
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Commission SCF with CA configuration
    ...    Step2: Check cell status
    ...    Step3: UE attach to target cell and start DL&UL traffic
    ...    Step4: Wait Scell addition and then check the TP reach the peak or not
    ...    Step5: restore the configuration if needed
    [Arguments]   ${cell_list}=${CASE_INPUT_CB008278['F_006']['cell_list']}
    ...           ${ul_throughput}=${CASE_INPUT_CB008278['F_006']['ul_throughput']}
    ...           ${ul_expect}=${CASE_INPUT_CB008278['F_006']['ul_expect']}
    ...           ${dl_throughput}=${CASE_INPUT_CB008278['F_006']['dl_throughput']}
    ...           ${dl_expect}=${CASE_INPUT_CB008278['F_006']['dl_expect']}
    COAM_Admin.commission    ${CFGFILE_PATH}/${Active_SwVersion_8278}_Configuration_scf_MRBTS-11119_TL2209_NR_F_006.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    L3call and check TP with paging     ${cell_list}    ${ul_throughput}    ${dl_throughput}    ${ul_expect}    ${dl_expect}
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

TC.CB008278-B_001_General_SiSo_BTS_Template_Commissioning_AWPQZ
    [Documentation]
    ...  Purpose:UL CA traffic and through put check
    ...  Precondition:All cells onAir without unexpected alarms
    ...  Test tools:WebEM,SPark or ELT,UE
    ...  Test Steps:
    ...    Step1: Commission SCF
    ...    Step2: Check cell status
    ...    Step3: Modyfy parameter and check result
    [Arguments]
    AlarmWatchdog.add_allow_alarms    fault_id=6830
    AlarmWatchdog.add_allow_alarms    fault_id=6828
    AlarmWatchdog.add_allow_alarms    fault_id=6833
    AlarmWatchdog.add_allow_alarms    fault_id=6823
    AlarmWatchdog.add_allow_alarms    fault_id=6829
    AlarmWatchdog.add_allow_alarms    fault_id=6831
    COAM_Admin.commission    ${CFGFILE_PATH}/SBTS25R2_Configuration_scf_MRBTS-11119_TL2209_NR_B_001.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    Check Alarm and stop robot testing when unexpected alarm raised
    Run Keyword And Ignore error   BtsLog.StartBTSlogCollection
    General_SiSo_Commissioning_BTS_Template_Commissioning
    AlarmWatchdog.remove_allow_alarms    fault_id=6830
    AlarmWatchdog.remove_allow_alarms    fault_id=6828
    AlarmWatchdog.remove_allow_alarms    fault_id=6833
    AlarmWatchdog.remove_allow_alarms    fault_id=6823
    AlarmWatchdog.remove_allow_alarms    fault_id=6829
    AlarmWatchdog.remove_allow_alarms    fault_id=6831
    Run Keyword And Ignore error   BtsLog.StopBTSlogCollectionandGetlog

L3call and check TP
    [Arguments]   ${cell_list}    ${ul_throughput}=100M    ${dl_throughput}=300M   ${ul_expect}=10    ${dl_expect}=100
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    sleep    200s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
    ...    ultarget_throughput=${ul_expect}    dltarget_throughput=${dl_expect}    actCarrierAggregation=${True}
    Set Test Variable    ${all_tp}    ${all_tp}
    ${dl_avg}    set variable    ${all_tp[1][0]['average']}
    ${ul_avg}    set variable    ${all_tp[0][0]['average']}
    Run Keyword And Ignore Error    should be true    ${dl_avg}>=${dl_expect}
    Run Keyword And Ignore Error    should be true    ${ul_avg}>=${ul_expect}
    [Teardown]    L3 call case teardown

General_SiSo_Commissioning_BTS_Template_Commissioning
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check if not commissioned gNB can be correctly configured using
    ...    BTS Template, verify Managed Object Class in WebUI and update parameters via WebUI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.19.2020 - - Created
    ...    *******************
    ...    OWNER_tingting.zhong@nokia-sbell.com
    [Arguments]  ${gnb_index}=${0}    ${connection}=GNB_OAM
    Selenium Login And Disable Screen Lock    gnb_index=${gnb_index}
    ${modify_params}  ${origin_params}  Modify TimeZone
    ...    gnb_index=${gnb_index}    connection=${connection}
    sleep    120
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    connection=${connection}    gnb_index=${gnb_index}
    Close Start Up View    timeout=60
    Check Parameters Modified Successfully  ${modify_params}
    Modify Parameters On Webem  ${origin_params}
    sleep    180
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'    connection=${connection}    gnb_index=${gnb_index}
    Close Start Up View    timeout=60
    Check Parameters Modified Successfully  ${origin_params}
    [Teardown]  Selenium Logout And Close Browser

Modify TimeZone
    [Arguments]  ${gnb_index}=${0}    ${connection}=GNB_OAM
    log to console    \n***Modify TimeZone ***
    ${modify_params}  create list
    ${timezone}    selenium_coam.Get Parameter Value    dist_name=${mrbtsID}/MNL-1
    ...    filter_param=Time zone
    run keyword and ignore error  Remove Values From List    ${timezone_list}    ${timezone}
    ${change_timezone}  evaluate  random.choice(${timezone_list})    modules=random
    ${object_list}    selenium_coam.get_object_name_list    object_name=SYNC-
    log to console    ${object_list}
    FOR  ${object}  IN  @{object_list}
        ${item}    create dictionary    dist_name=${mrbtsId}/MNL-1    filter_param=Time zone
        ...    p_name=timeZone    value=${change_timezone}
        append to list    ${modify_params}    ${item}
    END
    ${origin_params}  generate origion parameters  ${modify_params}
    Modify Parameters In SCF From Webem And Commission  ${modify_params}    gnb_index=${gnb_index}    connection=${connection}
    sleep  60
    [Return]  ${modify_params}  ${origin_params}

L3call and check TP with paging
    [Arguments]   ${cell_list}    ${ul_throughput}=100M    ${dl_throughput}=300M   ${ul_expect}=10    ${dl_expect}=100
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Test Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    sleep    60s
    Run Keyword And Ignore Error    Run keywords
    ...    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command
    ...    AND    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=${ue_type}
    sleep    300s
    power_ue.Start traffic    ue_index=${0}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${0}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=udp    buffer_size=1400B    process_num=${2}    seg_size=1350    window=16M
    sleep    60s
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m    filter=L2Lo
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=1m
    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${cell_list}
    ...    ultarget_throughput=${ul_expect}    dltarget_throughput=${dl_expect}    actCarrierAggregation=${True}
    Set Test Variable    ${all_tp}    ${all_tp}
    ${dl_avg}    set variable    ${all_tp[1][0]['average']}
    ${ul_avg}    set variable    ${all_tp[0][0]['average']}
    Run Keyword And Ignore Error    should be true    ${dl_avg}>=${dl_expect}
    Run Keyword And Ignore Error    should be true    ${ul_avg}>=${ul_expect}
    [Teardown]    L3 call case teardown

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
    COAM_Admin.VerifyCellOnAir
    ${BACKUP_SCF}   COAM_Admin.BackupSCF
    set suite variable    ${BACKUP_SCF}
    ${gNb_CuType}   KW.CP_GetgNBType
    set suite variable    ${gNb_CuType}
    ${BTSInfo}     COAM_Admin.GetBTSInfo
    ${gNb_CuType}    Set Variable   ${BTSInfo['gNbCuType']}
    COAM_WebEM.Login
#    ${version}    wait until keyword succeeds    2min    15s    selenium_coam.check_current_software_version
#    ${Active_SW_version}    string.split string    string=${version}[Active]
#    set suite variable    ${Active_SW_version}
#    ${SW1}    string.split string    string=${version}[Active]    separator=_
#    ${Active_SwVersion_8278}     convert to string    ${SW1}[-5]
#    set suite variable    ${Active_SwVersion_8278}
    [Return]   ${gNb_CuType}

KW.TestSuilt.Stop
    COAM_Admin.commission    ${CFGFILE_PATH}/SBTS25R2_Configuration_scf_MRBTS-11119_TL2209_NR_F_006.xml
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady
    robot_common_operations.Common Suite Teardown
    TestSuilt.Stop

Teardown Case
    Teardown case if case fail
    TestCase.Stop

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
