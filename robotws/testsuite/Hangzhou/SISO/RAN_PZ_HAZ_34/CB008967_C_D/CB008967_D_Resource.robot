*** Settings ***
Documentation    author: Guorong Song
...               contact: guorong.song@nokia-sbell.com
...               squad group: SG_01
...               feature : CB008967
#Library           urllib
#Library           String
#Library           taf.config.scf                        WITH NAME    scf
#Library           taf.transport.ssh		             WITH NAME	  ssh
#Library           taf.sbts.oam.coam.admin                WITH NAME    coam
#Library           taf.sw.dcap.rd                        WITH NAME    rd
#Library           taf.collectors.core   WITH NAME   core
#Library           taf.sbts.oam.coam.admin  WITH NAME   admin
#Library           taf.collectors.btslog  WITH NAME   btslog


Library           taf.selenium.sbts   WITH NAME   selenium_sbts
#Library                taf.selenium.sbts                   WITH NAME  selenium_coam
#Library                ReadJason.py
Resource     ../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
#Resource     ../../../OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
#Resource     ../../../resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
#Resource     ../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
#Resource     ../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG1/OAM_Interface.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
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
${ALIAS_ASIK}          asik    ##
${ALIAS_ASIK_SLAVE}    asik_slave

*** Keywords ***
CB008967_SR_D_6_ASOH_SBTS_CAB_AVG_FANSPEED
    [Documentation]
    ...  Precondition:BTS is commissioned
    ...  Test tools:WebUI
    ...  Test Steps:
    ...    Step1: Login WebEM online modify mtSBTSCabiFan to enable SBTS CAB Fan Speed AVG counter
    ...    Step2: Check counter for SBTS CAB Fan Speed AVG counter M40031C2 after waiting for one reporting interval
    ...    Checkpoint configuration:
    log to console    Step1: Login WebEM online modify mtSBTSCabiFan to enable SBTS CAB Fan Speed AVG counter
    #KWD.EnableSBTSCABFAN
    log to console    Step2: waiting for one reporting interval
    sleep    16min
    log to console    Step3: Check counter for SBTS CAB Fan Speed AVG counter M40031C2
    @{BTS_COUNTER}    Create List    M40031C2
    wait until keyword succeeds    3x    1min    COAM_WebEM.Login
    KWD.FetchCounter    @{BTS_COUNTER}
    run keyword and ignore error    COAM_WebEM.Logout


CB008967_SR_C_32_ASOH_SBTS_SMOD_TEMP_RANGE3
    [Documentation]
    ...   Purpose:Check the PM result file creation successful and duration meet requirement.
    ...   Precondition: NA
    ...   Test tools:ssh to gnb
    ...   Test Steps:
    ...     Step1: Login WebEM online modify mtSBTSSMODTemperature to enable SBTS SMOD Temperature counter
    ...     Step2: Waiting for one reporting interval
    ...     Step3: Check pm file will be created successfully within pm file created interval.
    log to console    Step1: Login WebEM online modify mtSBTSSMODTemperature to enable SBTS SMOD Temperature counter
    #EnableSBTSSMODTEMP
    log to console    Step2: waiting for one reporting interval
    sleep    16min
    log to console    Step3: Check pm file will be created successfully within pm file created interval.
    gNB.Connect
    ${output_before}=    ssh.execute    command=cd /tmp;ls -lrt RD.BTS-*.xml.gz     connection=${ALIAS_ASIK}
    log to console     ${output_before}
#    ${line}=    Fetch From Left    ${output_before}    \r\n
#    ${zip_filename}=    Fetch From Right    ${line}    ${SPACE}
    ${line}=    Fetch From Right    ${output_before}    ${SPACE}
    ${zip_filename}=    Fetch From Left    ${line}    \r\n
    log to console    ${zip_filename}
    ${filename}    ${last}=   Split String From Right     ${zip_filename}    .    1
    log to console    ${filename}
    ${xml_data}=    ssh.execute    command=cd /tmp;gzip -d ${zip_filename};cat ${filename}    connection=${ALIAS_ASIK}
    log to console    ${xml_data}

    ${counters}=    Get Elements    ${xml_data}    .//*[@measurementType="SBTS_SMOD_TEMPERATURE"]/SBTS_SMOD_TEMP_RANGE3_SAMPLES
    FOR    ${counter}    IN    @{counters}
        Log Element    ${counter}
        log to console    ${counter.text}
        ${pm_after}    convert to integer    ${counter.text}
        Should Be True    ${pm_after} > 0
    END
    gNB.Disconnect


CB008967_SR_C_test
    [Documentation]
    ...   Purpose:Check the PM result file creation successful and duration meet requirement.
    gNB.Connect
    ${output_before}=    ssh.execute    command=cd /tmp;ls -lRt RD.BTS-*.xml.gz     connection=${ALIAS_ASIK}
    log to console     ${output_before}
    ${line}=    Fetch From Left    ${output_before}    \r\n
    ${zip_filename}=    Fetch From Right    ${line}    ${SPACE}
    log to console    ${zip_filename}
    ${filename}    ${last}=   Split String From Right     ${zip_filename}    .    1
    log to console    ${filename}
    ${xml_data}=    ssh.execute    command=cd /tmp;gzip -d ${zip_filename};cat ${filename}    connection=${ALIAS_ASIK}
    log to console    ${xml_data}

    #@{NE-WBTS}=    Get Elements    ${xml_data}    .//SBTS_RMOD_TEMP_RANGE3_SAMPLES/..[@measurementType="SBTS_RMOD_TEMPERATURE"]
    ${counters}=    Get Elements    ${xml_data}    .//*[@measurementType="SBTS_RMOD_TEMPERATURE"]/SBTS_RMOD_TEMP_RANGE3_SAMPLES
    FOR    ${counter}    IN    @{counters}
        Log Element    ${counter}
        log to console    ${counter.text}
        ${pm_after}    convert to integer    ${counter.text}
        Should Be True    ${pm_after} > 0
    END


KWD.EnableSBTSCABFAN
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    run keyword and ignore error    CMD_WebEM.ValidateAndActiveParameters
    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1
    ...    object_class_name=PMMNL  id_value=1    timeout=60    is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS Cabinet Fan Monitoring
    ...    new_value=15min
    CMD_WebEM.ValidateAndActiveParameters
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
     ...    SBTS Cabinet Fan Monitoring
     run keyword if    '${pm_interval_org}'!='15min'    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
     ...    filter_param=SBTS Cabinet Fan Monitoring     new_value=15min
     run keyword and ignore error   CMD_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout

EnableSBTSSMODTEMP
    Wait until keyword succeeds   3x    1min   COAM_WebEM.Login
    run keyword and ignore error    selenium_sbts.remove_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
    run keyword and ignore error    CMD_WebEM.ValidateAndActiveParameters
    selenium_coam.add_object    object_name=${MRBTS_ID}/MNL-1/MNLENT-1
    ...    object_class_name=PMMNL  id_value=1    timeout=60    is_load_default_values=true
    selenium_coam.set_parameter_value   dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1   filter_param=SBTS SMOD Thermal Monitoring
    ...    new_value=15min
    CMD_WebEM.ValidateAndActiveParameters
     ${pm_interval_org}    COAM_WebEM.GetParameterValue      ${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
     ...    SBTS SMOD Thermal Monitoring
     run keyword if    '${pm_interval_org}'!='15min'    selenium_coam.set_parameter_value    dist_name=${MRBTS_ID}/MNL-1/MNLENT-1/PMMNL-1
     ...    filter_param=SBTS SMOD Thermal Monitoring     new_value=15min
     run keyword and ignore error   CMD_WebEM.ValidateAndActiveParameters
     run keyword and ignore error    COAM_WebEM.Logout

CMD_WebEM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    ${error}    selenium_coam.validate_plan
    log    ${error}
    Run Keyword If    '${activate_plan_despite_errors}'=='True'   selenium_coam.activate_plan    activate_plan_despite_errors=True
    ...    ELSE      selenium_coam.activate_plan


#COAM_WebEM.GetParameterValue
#    [Arguments]    ${distName}=MRBTS-1969    ${abbr}=BTS name
#    ${value}   Wait Until Keyword Succeeds    3 times    30s
#    ...    selenium_coam.get_parameter_value    dist_name=${distName}    filter_param=${abbr}
#    [Return]       ${value}


KWD.FetchCounter
    [Arguments]    @{counter_list}
    FOR  ${counter_id}  IN  @{counter_list}
        ${res}   selenium_coam.get_bts_counters_info   ${counter_id}
        log    ${res}
        ${values}    get dictionary values   ${res}
        log    ${values}
        log  The latest one is: ${values[-1]}
#        ${status}    run keyword and continue on failure    should be true    ${values[-1]}>0
#        ${case_status}    run keyword if    '${status}'=="None"
#        ...    set variable    pass
#        ...    ELSE    set variable    fail
#        AppendCaseResultToFile    requirement_id=${counter_id}    target_value=NA    result_value=${values[-1]}    case_result=${case_status}
        should be true    ${values[-1]}>0
    END

KWD.ResetSite
    Set Test Variable    ${GnbReset}    True
    COAM_WebEM.Login    version=${sbts_stream}
    ${status}    Run Keyword And Return Status    selenium_coam.reset_site
    should be true    ${status}
    sleep    60s
    ${status}    Run Keyword And Return Status    KWD.ConnectDualCoreBySSH
    Should not be true    ${status}
    COAM_WebEM.Login    version=${sbts_stream}
    Wait Until Keyword Succeeds    20min    1min    COAM_Admin.CheckAllCellsOnair     type=both
#    COAM_WebEM.Logout
    ${alarm_result}=    KWD.GetAndCheckAlarm
    Run Keyword And Continue On Failure    Run keyword if    '${alarm_result}'=='False'    Fail
        ...    Please check unexpect Alarm
#    wait until keyword succeeds    20min    10s    COAM_Admin.CheckAllCellsOnair     type=lte
#COMMON SETUP AND TEARDOWM

KWD.ConnectDualCoreBySSH
    [Documentation]   ssh to the given IP with username and password
    @{ipList}    Create list    ${LMP_Primary}    ${ASIK_IP_Mplane}
    FOR    ${ip}    IN     @{ipList}
        ssh.Connect to    ${ip}    ${ASIK_USERNAME}    ${ASIK_PASSWORD}    alias=tmpConn
        ssh.disconnect    connection=tmpConn
    END

KWD.GetAndCheckAlarm
    @{Fault_whitelist}    Create list    4655   4654   61524   61652   4459    4681   7312
    Run Keyword if   '${GnbReset}' == 'True'    append to list    ${Fault_whitelist}    4592
#    COAM_WebEM.Login
    ${active_alarm}    selenium_coam.get_active_alarm_info
    log    ${active_alarm}
    ${history_alarm}    selenium_coam.get_history_alarm_info
    log    ${history_alarm}
    ${fault_id_list}    create list
    ${unexpect_fault}    create list
    FOR    ${item}    IN    @{active_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    FOR    ${item}    IN    @{history_alarm}
         ${fault_id}    get from dictionary    ${item}    Fault ID
         append to list    ${fault_id_list}    ${fault_id}
    END
    log    ${fault_id_list}
    ${length}    Get length     ${fault_id_list}
    FOR    ${i}    IN RANGE    ${length}
        ${result}=    Run Keyword And Return Status    list should contain value      ${Fault_whitelist}    ${fault_id_list[${i}]}
        Run Keyword if   '${result}' == 'False'
        ...   append to list    ${unexpect_fault}    ${fault_id_list[${i}]}
    END
    log    ${unexpect_fault}
    ${alarm_result}=    run keyword and return status    should be empty    ${unexpect_fault}
    COAM_WebEM.Logout
    [Return]    ${alarm_result}


Setup Suite With SCF
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start
    ${res}    Run Keyword And Ignore error    gNB.GenerateTestLineSCFs
#	${res}    Run Keyword And Ignore error    gNB.Generate TL SCF
#	...                  GoldenSCF_PATH=${GoldenSCF_ON_GIT}/${info['GoldenSCF']}    TLDelta_PATH=${CFGFILE_PATH}/TLDelta_${info['StreamPrefix']}.py
#	...                  TestLineSCF_cell_num=${2}    cell_type=Both
#	...                  MRBTSID=${MRBTS_ID}    NRBTSID=${NRBTS_ID}

	Set Suite Variable    ${Dula_core_base_scf}    ${LOG_PATH}/TestLineSCF2Cell.xml

    run keyword if    '${res[0]}'=='PASS'
    ...      gNB.Commission   scf_file=${LOG_PATH}/TestLineSCF2Cell.xml
#   ...    ELSE    gNB.Commission    scf_file=${CFGFILE_PATH}/SCF_ASOH_4D4U_AWHQN.xml
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}   ${subversion}    Split String   string=${Active_SW_version}   separator=_     max_split=1
    ${stream}    set variable if   '${stream}'>='SBTS22R2'    SBTS22R2    SBTS21B
    set suite variable    ${sbts_stream}    ${stream}

    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}

Setup Suite Fast
    log to console    \n***SISO Coam Suite Setup***
    Run Keyword If    '${testline_name}'!='null'    UTECloud.ForceAdaptCommissionFiles
    ...    ELSE     UTECloud.AdaptCommissionFiles
    TestSuite.Start

    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}


Teardown Suite D
    log to console    \n***SISO Coam Suite Teardown***
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}
#    ...    Commission    ${CFGFILE_PATH}/SCF_CB007475.xml
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair    type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'    run keyword and ignore error    KWD.ResetSite

    TestSuite.Stop


Setup case after common setup
    log to console    \n***SISO Coam Test Setup***
    log to console    Active_SW_version:${Active_SW_version}
    CI_interface.Common Case Setup
    Generate test case log path
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    set test variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    create directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${cells_status}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=both
#    ${cells_status_LTE}    Run Keyword And Return Status    COAM_Admin.CheckAllCellsOnair     type=lte
    run keyword if    '${cells_status}'=='False'   run keyword and ignore error    KWD.ResetSite
    Run Keyword And Ignore error    BtsLog.StartBTSlogCollection
#    ${ru_status}    Run Keyword And Return Status    COAM Check GNB RU status
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    Run Keyword If    ${ru_status}==${False} or ${cell_status}==${False}    Fail    TEST
#    ...    Commission
#    Start Btslog With Path Check
    Run Keyword And Ignore Error    selenium_coam.close_browser

Teardown case D
    log to console    \n***SISO Coam Test Teardown***
    Run Keyword And Ignore error     BtsLog.StopBTSlogCollectionandGetlog
    Connect to gnb coam via ssl
    Run Keyword If  '${TEST STATUS}' == 'FAIL'    Run Keyword And Ignore error    gNB.CollectSnapshot
    ...    ELSE    Pass Execution If    '${TEST STATUS}' == 'PASS'    Not collect snapshot logs
#    Connect to gnb coam via ssl
#    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
#    log to console  RU status: ${ru_status}
#    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
#    should be true    ${cell_status}
#    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=@{ALLOWED_FAULT}
#    should be true    ${alarm_status}
#    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
#    ...    allowed_faults=@{ALLOWED_HISTORY_FAULT}
#    ${rc}    ${output} =    Run and Return RC and Output    ps -ef | grep ${btslog_dir} | grep -v grep
#    run keyword if    '${btslog_dir}'!='none' and ${rc}==${0}    Stop Btslog Collect    target_dir=${SAVE LOG DIRECTORY}
#    run keyword if test failed     Collect Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}
    COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps xafu |grep node|grep -v grep|awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    run    command=killall firefox
    Run Keyword And Ignore Error    run    command=killall geckodriver
    Conn.ResetCache
#    CI_interface.Common Case Teardown
    TestCase.Stop
