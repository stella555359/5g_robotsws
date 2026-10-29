*** Settings ***
Documentation      author: Kong Xiangli
...                contact: Xiangli.Kong@nokia-sbell.com
...                feature: CB010823

Variables     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_csn.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource         testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource         ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Library          ../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/check_loadbuild.py

Library           taf.collectors.core   WITH NAME   core
Library           taf.sbts.oam.coam.admin  WITH NAME   admin
Library           taf.collectors.btslog  WITH NAME   btslog
Library           taf.selenium.sbts   WITH NAME   selenium_sbts
#Library           timing.py
Library           Collections

*** Variables ***
#Configure the TL specific variable
${USER_LOG_DIR}        /opt/ute/Logs
${UPDATE_FILE_PATH}       /home/ute/Download_gNB_Package
${YAFT_PATH}              /opt/ute/YAFT
${WTS_FILE_PATH}       ${tl.core.dir_path}

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

#######################################     #######################################
*** Keywords ***
TC.CB011039-A_01_Radio_Module_fail_safe_mode_fault_activation
    set suite variable    ${ruIndex}    ${CASE_INPUT_CB011039["index"]}
    set suite variable    ${object}    ${CASE_INPUT_CB011039["object"]}
    AlarmWatchdog.add_allow_alarms    fault_id=2934
    AlarmWatchdog.add_allow_alarms    fault_id=10
    KW.Enable_fail_safe_mode
    KW.Diagnostic_check
    KW.Disable_fail_safe_mode
    AlarmWatchdog.remove_allow_alarms    fault_id=2934
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    wait until keyword succeeds   15min   1min    gNB.VerifyOnAirViaOAMUntilReady


Setup Suite
    TestSuilt.Start
    Import Variables     ${CFGFILE_PATH}/TLConfiguration.py

Teardown Suite
    TestSuilt.Stop

TestCase Setup
    TestCase.Start

TestCase Teardown
    TestCase.Stop

KW.Check_Alarm_from_Active_Alarms
    [Arguments]     ${target_fault_id}    ${target_alarm_id}    ${target_alarm_name}    ${target_alarm_object}
    ${alarm_info}    selenium_coam.get_active_alarm_info
    ${length}        Get length     ${alarm_info}
    FOR    ${i}    IN RANGE    ${length}
        ${res}    run keyword and return status    run keywords
        ...                should be equal as strings    ${alarm_info[${i}]['Fault name']}    ${target_alarm_name}
        ...                AND    should be equal as strings    ${alarm_info[${i}]['Fault ID']}      ${target_fault_id}
        ...                AND    should be equal as strings    ${alarm_info[${i}]['Alarm ID']}      ${target_alarm_id}
        ...                AND    should contain                ${alarm_info[${i}]['Runtime alarming object']}    ${target_alarm_object}
        run keyword if    ${res}    exit for loop
    END
    run keyword if  not ${res}    fail    Alarm ${target_alarm_id} not found!

KW.Enable_fail_safe_mode
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP        ru_index=${ruIndex}   ru_alias=RU_${ruIndex}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${localhost_login}    Set Variable    ${sudo} frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    run keyword and ignore error   Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module action enable_fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    #${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    #${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    #Should Contain    ${output}    done ok ENABLED
    Perform RU Reset    ru_index=${ruIndex}
    sleep   5m
    COAM_WebEM.Login
    ${res1}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7116
    ...                                         target_fault_id=2934
    ...                                         target_alarm_name=Radio Module fail safe mode
    ...                                         target_alarm_object=${object}
    should be true    '${res1}'=='True'
#    ${res2}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
#    ...                                         target_fault_id=1850
#    ...                                         target_alarm_name=SW corrupted
#    ...                                         target_alarm_object=${object}
#    should be true    '${res2}'=='True'

KW.Disable_fail_safe_mode
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP        ru_index=${ruIndex}   ru_alias=RU_${ruIndex}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${localhost_login}    Set Variable    ${sudo} frmonShellClient localhost 2000
    ${cmd}   Set Variable  echo '/ action create ResetControl /CI/resetControl/module /module'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    run keyword and ignore error   Should Contain    ${output}    done ok
    sleep    2s
    ${cmd}   Set Variable  echo '/CI/resetControl/module action disable_fail_safe_mode'|${localhost_login}
    ${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    #${cmd}   Set Variable  echo '/CI/resetControl/module get fail_safe_mode'|${localhost_login}
    #${output}  csn.execute  command=${cmd}    connection=RU_${ru_index}
    #Should Contain    ${output}    done ok DISABLED
    Perform RU Reset    ru_index=${ruIndex}
    sleep   5m
    COAM_WebEM.Login
    ${res3}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7116
    ...                                         target_fault_id=2934
    ...                                         target_alarm_name=Radio Module fail safe mode
    ...                                         target_alarm_object=${object}
    should be true    '${res3}'=='False'
#    ${res4}    Run Keyword And Return Status    KW.Check_Alarm_from_Active_Alarms     target_alarm_id=7111
#    ...                                         target_fault_id=1850
#    ...                                         target_alarm_name=SW corrupted
#    ...                                         target_alarm_object=${object}
#    should be true    '${res4}'=='False'


KW.Diagnostic_check
    Log    ${AF_PATH}
    ${release}      String.Split String    ${AF_PATH}   _
    ${release}      set variable           ${release}[0]
    wait until keyword succeeds    10min    10s    COAM_WebEM.Login    version=${release}
    selenium_sbts.start_diagnostic_check   scope=Customized diagnostic check    timeout=1200
    sleep   60s
    #checkpoint 43 will cause RU reset
    Log To Console   waitAllCellsOnair
    #Wait Until Keyword Succeeds    10min   10s    COAM_Admin.CheckAllCellsOnair
    ${customizedreport}   selenium_sbts.get_report
    ${RUcustomizedreport}    set variable    ${customizedreport['RU diagnostic check report']}
    Run keyword if   '${release}'=='SBTS00'    KW.CheckRUReportsOnTrunk    RUcustomizedreport=${RUcustomizedreport}
    ...    ELSE    KW.CheckRUReports    RUcustomizedreport=${RUcustomizedreport}
    ${UpdateTime1}    set variable if    '${release}'=='SBTS00'
    ...    ${RUcustomizedreport[0]['Execution time of last definitive status GMT+0800']}    ${RUcustomizedreport[0]['Last definitive result time']}


KW.CheckRUReportsOnTrunk
    [Arguments]    ${RUcustomizedreport}
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=10   CheckPointName=Online Input Voltage on Radio Module   TriggerType=WebEM
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=18   CheckPointName=Radio Module Temperature Supervision   TriggerType=WebEM
    #KW.CheckRUReport    RUreport=${RUcustomizedreport}    ID=21    CheckPoint=Radio Module ethernet link    TriggerType=WebEM
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=26   CheckPointName=Radio Module FAN   TriggerType=WebEM
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=40   CheckPointName=RU SW package and NVM integrity   TriggerType=WebEM
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=41   CheckPointName=RU Memory usage   TriggerType=WebEM
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=42   CheckPointName=RU Temperature sensor   TriggerType=WebEM
    KW.CheckRUReportOnTrunk   RUreport=${RUcustomizedreport}   CheckPoint=43   CheckPointName=Extended RU DDR tests   TriggerType=WebEM

KW.CheckRUReportOnTrunk
    [Arguments]    ${RUreport}    ${CheckPoint}    ${CheckPointName}    ${TriggerType}
    FOR  ${item}  IN  @{RUreport}
        run keyword if     '${item['Target distinguished name']}'!='${Target_distinguished_name}'     Continue For Loop
        run keyword if     '${item['Check point']}'!='${CheckPoint}'     Continue For Loop
        should be true     '${item['Check point name']}'=='${CheckPointName}'
        should be true     '${item['Trigger type']}'=='${TriggerType}'
        should be true     '${item['Check status']}'=='Check point successful'
    END

KW.CheckRUReports
    [Arguments]    ${RUcustomizedreport}
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=10   CheckPointName=Online Input Voltage on Radio Module   TriggerType=WebEM
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=18   CheckPointName=Radio Module Temperature Supervision   TriggerType=WebEM
    #KW.CheckRUReport    RUreport=${RUcustomizedreport}    ID=21    CheckPoint=Radio Module ethernet link    TriggerType=WebEM
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=26   CheckPointName=Radio Module FAN   TriggerType=WebEM
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=40   CheckPointName=RU SW package and NVM integrity   TriggerType=WebEM
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=41   CheckPointName=RU Memory usage   TriggerType=WebEM
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=42   CheckPointName=RU Temperature sensor   TriggerType=WebEM
    KW.CheckRUReport   RUreport=${RUcustomizedreport}   CheckPoint=43   CheckPointName=Extended RU DDR tests   TriggerType=WebEM

KW.CheckRUReport
    [Arguments]    ${RUreport}    ${CheckPoint}    ${CheckPointName}    ${TriggerType}
    FOR  ${item}  IN  @{RUreport}
        run keyword if     '${item['Radio module']}'!='${RU_index}'     Continue For Loop
        run keyword if     '${item['ID']}'!='${CheckPoint}'     Continue For Loop
        should be true    '${item['Check point']}'=='${CheckPointName}'
        should be true    '${item['Trigger type']}'=='${TriggerType}'
        should be true    '${item['Last execution result']}'=='OK'
    END