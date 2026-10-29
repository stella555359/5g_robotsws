*** Settings ***
Documentation    author: hongyan yuan
...               contact:
...               squad group: SG_01
...               feature : non feature testing

Library           json
Resource          ../../../5GC000496_C/Resources/L3Call.robot
Resource          ../../../Globe_Lab_LTE/Resources/basic_keywords/ue.robot
Library           taf.collectors.core   WITH NAME   core
Library           taf.collectors.btslog  WITH NAME   btslog
Library           ute_wtssim
Library           ute_syslog
Library           process_data_in_file.ExcelReader     WITH NAME    excelreader
Library           taf.sw.scout    WITH NAME   scout
Library           DateTime
Library           OperatingSystem
Library           Process

#Variables         CaseConfiguration.py

*** Variables ***
${TESTING_START_TIME}
#${scout_testline_name}      VRF4_SG1_MultiUE_AP1
${api_key}                  e4de17a9d8d540e88e2e5740b805df7b
#${UE_TYPE}                  ${tl.ues[0].capabilities[-1]}

#${CFGFILE_PATH}             /home/ute/TAF/cfgfile/
${WEBUI_URL}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_IP}                 ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}

${ASIK_LMP_IP}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_LMP_USERNAME}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_LMP_PASSWORD}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ASIK_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

#UTE is used as the egate of first Airphone by default
${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}


${AP_LMP_IP}             ${tl.ues[0].l1.common_units[0].lmp_connection.addr}
${AP_USERNAME}           ${tl.ues[0].l1.common_units[0].lmp_connection.username}
${AP_PASSWORD}           ${tl.ues[0].l1.common_units[0].lmp_connection.password}

#use the list here because of multi-APs should be supported.

# @{AP_0}                    ${tl.ues[0].l3_ssh_connection_details.addr}
#                          ...    ${tl.ues[0].l3_ssh_connection_details.username}
#                          ...    ${tl.ues[0].l3_ssh_connection_details.password}

# @{AP_1}                    ${tl.ues[1].l3_ssh_connection_details.addr}
#                          ...    ${tl.ues[1].l3_ssh_connection_details.username}
#                          ...    ${tl.ues[1].l3_ssh_connection_details.password}

# @{AP_2}                    ${tl.ues[2].l3_ssh_connection_details.addr}
#                          ...    ${tl.ues[2].l3_ssh_connection_details.username}
#                          ...    ${tl.ues[2].l3_ssh_connection_details.password}



${PB_PORT}                  5000

${PB_ASIK_IP}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${PB_ASIK_PORT}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${PB_DU_Vendor}             ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}

${PB_AP_IP}               ${tl.pdus[1].addr}
${PB_AP_PORT}             ${tl.pdus[1].port_numbers[0]}
${PB_AP_Vendor}             ${tl.pdus[1].vendor}
${WTS_DIR}              /home/ute/WTS_latest
${KPI_history}          /home/ute/KPI_history
${TEST_SCRIPT}      AAA_multi_ue_sa_script_v5.lua
${TEST_SCRIPT2}      concurrence_main1.lua
${MAIN_SCRIPT}      AAA_main.lua
${PER_UE_SCRIPT}    AAA_tasks.lua
${MAIN_FUNC}    start_test
${MAIN_FUNC1}    start_test(meas_trigger_scell_add_del)
${MAIN_FUNC2}    start_test(attach_detach_in_loop)
${MAIN_FUNC_HO}    start_test(task_group_ho)
${CASE1}   register_deregister_parallel(1,1200,4,1,0.3,2,internal)
${CASE2}   register_multiue_with_pdu_check_traffic_parallel_retry(1,900,4,1,1,1,bps,72,72,both,0.3,internal,42,yes,60)
${CASE3}   register_multiue_and_trigger_A1_MEAS(1,252,4,1,1,1,bps,72,72,both,0.3,internal,42,yes,60)

${SOSREPORT_NEEDED}   True
@{WTS_HOSTS}    10.101.60.248
@{ALL_WTS_HOSTS}    10.101.60.248    10.101.60.250

#@{WTS_HOSTS}
#@{ALL_WTS_HOSTS}   10.101.60.250
${CMD_RUN_IN_WTS_HOSTS}    source /home/ute/CIENV/${testline_name}/bin/activate && python ~/YHY/concurrent_aps.py

${dcapduration}   1

##################define these variable for convenient############################
${ALIAS_ASIK}               asik                                                ##
${ALIAS_ASIK2}              asik2                                               ##
${ALIAS_ASIK_SLAVE}         asik_slave                                          ##
${ALIAS_ABIL}               abil                                                ##
${ALIAS_ABIL_SLAVE}         abil_slave                                          ##
${ALIAS_UTE}                ute                                                 ##
${ALIAS_ENBCTLPC}           ENB_PC                                              ##
${ALIAS_SHP}                SHP                                                 ##
${ALIAS_LONER}              LONER                                               ##
${ALIAS_ASP_1A}             ASP_1A                                              ##
${ALIAS_MTKPC}                MTKPC                                             ##
${UE_alias}                 UE_0                                                ##
${ALIAS_5GC}                5gc                                                 ##
${ALIAS_AP}                 egate_AP_connection                                                  ##
########################END of alias Define#######################################

*** Keywords ***

TC.register_multiue_degregister_parallel
    log to console   start to excute script
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.strftime("%H")}:${start.strftime("%M")}

#    Run keyword and ignore error    Run case in other WTS hosts
    Run Case via Lua  case=${CASE1}
    ...    expected_result=iterations are done
    ...    timeout=30min
    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}
    run keyword if    ${CASE_INPUT["TC1"]["get_kpi"]}    Get KPIs

TC.register_multiue_with_pdu_check_traffic_parallel
    log to console   start to excute script
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.strftime("%H")}:${start.strftime("%M")}

    Run Case via Lua  case=${CASE2}
    ...    expected_result=iterations are done
    ...    timeout=30min
    Check PWR_SAVING counter

    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}
    run keyword if    ${CASE_INPUT["TC2"]["get_kpi"]}    Get KPIs

TC.trigger_overload_with_concurent_ues
    log to console   start to excute script
    Run keyword and ignore error    Run case in other WTS hosts
    Run Case via Lua  case=${MAIN_FUNC}   script=${MAIN_SCRIPT}
    ...    expected_result=placeholder expectation never match
    ...    timeout=60min

TC.trigger_A1_A2_meas_with_concurent_ues
    log to console   start to excute script
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.strftime("%H")}:${start.strftime("%M")}

    Run Case via Lua  case=${MAIN_FUNC1}   script=${TEST_SCRIPT2}
    ...    expected_result=iterations are done
    ...    timeout=50min
    COAM_WebEM.Login
    ${Successful_RRC_reconfigurations_attempts}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
         ...    counter_id=M55118C05506

    ${RRC_reconfigurations_attempts}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
         ...    counter_id=M55118C05505
    ${result}    Evaluate   ${Successful_RRC_reconfigurations_attempts}/${RRC_reconfigurations_attempts}
    Run Keyword And Continue On Failure   Should be true   ${result} >= 0.95
    Run Keyword And Continue On Failure   Should be true   ${Successful_RRC_reconfigurations_attempts} >= 1200
    Run Keyword And Continue On Failure   Should be true   ${RRC_reconfigurations_attempts} >= 1200

    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}
    run keyword if    ${CASE_INPUT["TC4"]["get_kpi"]}    Get KPIs
   [Teardown]   Run Keyword And Ignore error    COAM_WebEM.Logout

TC.trigger_A1_meas_to_setup_2CC_CA
    log to console   start to excute script
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.strftime("%H")}:${start.strftime("%M")}

    Run Case via Lua  case=${CASE3}
    ...    expected_result=iterations are done
    ...    timeout=30min
    Run Keyword And Continue On Failure   Set check point for 2CC CA case

    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}
    run keyword if    ${CASE_INPUT["TC5"]["get_kpi"]}    Get KPIs

TC.attach_detach_for_loop_with_specify_parameter
    log to console   start to excute script
    ${start}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${START_TIME}   set variable    ${start.strftime("%H")}:${start.strftime("%M")}

    Run Case via Lua  case=${MAIN_FUNC2}   script=${TEST_SCRIPT2}
    ...    expected_result=iterations are done
    ...    timeout=30min
    check access success rate

    ${end}    robot.libraries.DateTime.Get current date    result_format=datetime
    ${END_TIME}   set variable    ${end.hour}:${end.minute}
    set test variable    ${START_TIME}
    set test variable    ${END_TIME}
    run keyword if    ${CASE_INPUT["TC6"]["get_kpi"]}    run keywords
    ...    sleep   6min
    ...    AND    Get KPIs

TC.trigger_HO_success_and_failure_with_concurent_ues
    log to console   start to excute script
    Run Case via Lua  case=${MAIN_FUNC_HO}   script=${TEST_SCRIPT2}
    ...    expected_result=iterations are done
    ...    timeout=50min


 ######################
check access success rate
    COAM_WebEM.Login
    ${result1}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
        ...    counter_id=M55306C06001
    ${result2}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
        ...    counter_id=M55306C05001
    ${result3}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
        ...    counter_id=M55306C00001
    ${result}=  Evaluate  (${result1}+${result2})/${result3}
    Run Keyword And Continue On Failure   Should be true   ${result} >= 0.95
    [Teardown]   Run Keyword And Ignore error    COAM_WebEM.Logout
Set check point for 2CC CA case
    COAM_WebEM.Login
    ${my_list1}=  Create List  M55118C05507   #M55118C05505   M55118C05506  M55139C01003   M55139C01004    M55139C01001   M55139C01002
    ${fixed_value1}=  Set Variable  75000
    ${Check_counter_dict}=  Create Dictionary
    FOR   ${item}    IN    @{my_list1}
        Set To Dictionary  ${Check_counter_dict}  ${item}=${fixed_value1}
    END
    ${my_list2}=  Create List  M55139C01501  M55139C01502
    ${fixed_value2}=  Set Variable  0
    ${my_dict}=  Create Dictionary
    FOR   ${item}    IN    @{my_list2}
        Set To Dictionary  ${Check_counter_dict}  ${item}=${fixed_value2}
    END
    #FOR   ${key}  ${value}    IN    @{Check_counter_dict}
    FOR   ${key}  ${value}  IN ZIP  ${Check_counter_dict.keys()}  ${Check_counter_dict.values()}
        ${result}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
        ...    counter_id=${key}
        Run Keyword And Continue On Failure   Should be true   ${value} <= ${result}
    END
    [Teardown]   Run Keyword And Ignore error    COAM_WebEM.Logout
Check PWR_SAVING counter
    Set test Variable   ${file_path}      /home/ute/counter_check/counter_check.txt
#    @{temp_list}=  Create List   CELLS/NRCELL-3/DBWP/AVG_UE_ACTIVE_PWR_SAVING_BWP  M55351C00002   30
#    @{check_counter_result}    Create List
#    Append To List    ${check_counter_result}    ${temp_list}
    ${check_counter_result}  Run Keyword And Continue On Failure    check counter
#    ${is_empty}    Check Text File on ute  check_counter_result=${check_counter_result}
#    Run Keyword And Continue On Failure  clear old value in counter check file
#    Write new data to txt file   check_counter_result=${check_counter_result}
check counter
    @{check_counter_result}    Create List
    COAM_WebEM.Login
    ${AVG_UE_ACTIVE_PWR_SAVING_BWP}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
         ...    counter_id=M55351C00002
    @{tmp_list}  Create List  M55351C00002  ${AVG_UE_ACTIVE_PWR_SAVING_BWP}
    Append To List    ${check_counter_result}    ${tmp_list}
    ${MAX_UE_ACTIVE_PWR_SAVING_BWP}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
         ...    counter_id=M55351C00001
    @{tmp_list}  Create List  M55351C00001  ${MAX_UE_ACTIVE_PWR_SAVING_BWP}
    Append To List    ${check_counter_result}    ${tmp_list}
    ${AVG_UE_CONFIG_2BWP_VALUE}   Wait until keyword succeeds   3x   2min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
         ...    counter_id=M55351C01002
   Run Keyword And Continue On Failure   Should be True    ${AVG_UE_CONFIG_2BWP_VALUE}==225
   Run Keyword And Continue On Failure   Should be True    ${AVG_UE_CONFIG_2BWP_VALUE}<=400
   Run Keyword And Continue On Failure   Should be True    ${AVG_UE_ACTIVE_PWR_SAVING_BWP}<=400
   Run Keyword And Continue On Failure   Should be True    ${MAX_UE_ACTIVE_PWR_SAVING_BWP}<=400
    [Return]   ${check_counter_result}
    [Teardown]   Run Keyword And Ignore error    COAM_WebEM.Logout

kill the UEC port after the test is completed
    ssh.Connect to    hostname=${UTE_IP}    username=${UTE_USERNAME}
        ...    password=${UTE_PASSWORD}    alias=${ALIAS_UTE}
    @{port_list}    Create List
    ${UEC_port_tmp}     ssh.Execute   command=sudo ss -nutlp | grep sim_uec |grep -v grep |awk '{print $7}'  connection=${ALIAS_UTE}
    @{UEC_port_all}  Split String    ${UEC_port_tmp}
    FOR  ${item}  IN  @{UEC_port_all}
        @{result}  Split String    ${item}  ,
        ${UEC_port}   Remove String    ${result[1]}   pid=
        ${string_exists}=    Evaluate    '${UEC_port}' in ${port_list}
        Run Keyword If    not ${string_exists}    Append To List    ${port_list}   ${UEC_port}
    END
    FOR  ${item}  IN  @{port_list}
      ssh.Execute   command=sudo kill -9 ${item}   connection=${ALIAS_UTE}
    END
    [Teardown]   Run Keyword And Ignore error    ssh.disconnect    connection=${ALIAS_UTE}

COAM_WebEM.Logout1
    [Arguments]     ${virtual_disable}=${TRUE}
    log to console    ${virtual_disable}
    ${res}    selenium_coam.start_up_view_window_exists
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window
    selenium_coam.logout
    #run keyword if      ${virtual_disable}    selenium_coam.disable_virtual_display
clear old value in counter check file
    [Arguments]
    Remove File    ${file_path}
    Create File    ${file_path}
Write new data to txt file
    [Arguments]   ${check_counter_result}
    FOR  ${i}  IN   @{check_counter_result}
        ${text_to_write}=    Set Variable    ${i}
        Append To File    ${file_path}    ${text_to_write}   append=true
    END
Check Text File on ute
    [Arguments]   ${check_counter_result}
    ${file_size}=    Get File Size    ${file_path}
    Run Keyword If    ${file_size} == 0
    ...   Set Test Variable    ${is_empty}    ${False}
    ...   ELSE
    ...   Set Test Variable    ${is_empty}    ${True}
    Run Keyword If    '${is_empty}' == 'False'
    ...    Write new data to txt file   check_counter_result=${check_counter_result}
    ...    ELSE IF   '${is_empty}' == 'True'
    ...  check vaule in txt file  check_counter_result=${check_counter_result}
    [Return]   ${is_empty}


check vaule in txt file
    [Arguments]   ${check_counter_result}
    @{list1}=    Create List    M55351C00002     M55351C00001
    @{list2}=    Create List    [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-3/DBWP/AVG_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-4/DBWP/AVG_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-5/DBWP/AVG_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-6/DBWP/AVG_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-3/DBWP/MAX_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-4/DBWP/MAX_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-5/DBWP/MAX_UE_ACTIVE_PWR_SAVING_BWP
       ...  [TL210_ASOE_4AEQE_23R1_23R2__IWK] MRBTS-1/NRBTS-1/NRCELL-6/DBWP/MAX_UE_ACTIVE_PWR_SAVING_BWP
    ${check_counter}=    Create List

    FOR    ${item1}    IN    @{list1}
        ${index}=    Get Index From List    ${list1}    ${item1}
        ${item2}=    Get From List    ${list2}    ${index}
        ${combined_item}=    Create List    ${item1}   ${item2}
        Append To List    ${check_counter}    ${combined_item}
    END
    csn.Connect to     hostname=${UTE_IP}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}	  alias=${UE_alias}
    FOR  ${i}  IN  @{check_counter_result}
        ssh.send_command    command=sudo cat /home/ute/counter_check/counter_check.txt | grep ${i}[0] |grep ${i}[1]     connection=${UE_alias}
        @{first_split}=    Create List
        ${output}=    ssh.read_output    connection=${UE_alias}
        ${first_split}=    Split String    ${output}
        log to console    ${first_split}[1]
        Should be True    ${i}[1]>=${first_split}[1]
    END
    [Teardown]   Run Keyword And Ignore error    Csn.Disconnect	connection=${alias}



COAM_WebEM.Login1
    [Documentation]   parameter should be ${True} or ${False}
    [Arguments]      ${virtual_enable}=${TRUE}    ${url}=${WEBUI_URL}    ${version}=SBTS21B
    log to console    ${virtual_enable}
    UTE.CleanFirefox
    #run keyword if     ${virtual_enable}     selenium_coam.enable_virtual_display
    run keyword and ignore error    selenium_coam.logout
    selenium_coam.login    url=${url}    username=${WEBUI_USERNAME}    password=${WEBUI_PASSWORD}    version=${version}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock
    sleep    15s
    ${res}    selenium_coam.start_up_view_window_exists    timeout=20
    run keyword if    '${res}'=='True'        selenium_coam.close_start_up_view_window

Setup Suite
    [Documentation]  no commission performed if no scf_file given.
    [Arguments]   ${scf_file}=None
    log to console    ${scf_file}
    Create Log Directories
    ${gnb_version}       Get gNB Active SW Version
    set suite variable    ${gnb_version}
    Import Variables      ${CFGFILE_PATH}TLConfiguration.py
    run keyword and ignore error    Import Variables      /home/ute/TAF/TLConfiguration.py

    # if not WTS configuration files defined in TLCongiguration.py, set default values
    Basic.CheckVariableValid    var=WTS_CFG  default_value=AAA_WTS1.lua
    Basic.CheckVariableValid    var=WTS_CFG1  default_value=AAA_WTS2.lua
    # Usually, there is only ONE Airphone in one TL, if not defined, set default to 1
    Basic.CheckVariableValid    var=NumOfAirphone   default_value=1   is_digit=True
    Basic.CheckVariableValid    var=TestingDuration   default_value=9000   is_digit=True
    Basic.CheckVariableValid    var=isSharedPBwithAiphone   default_value=False
    Basic.CheckVariableValid    var=isIWFused   default_value=False
    Basic.CheckVariableValid    var=ifGenerate2ndReport   default_value=False
    Basic.CheckVariableValid    var=Second_template_id   default_value=3043
    Basic.CheckVariableValid    var=Second_report_tag   default_value=Additional_Counter
    Basic.CheckVariableValid    var=TestTempleteID   default_value=2049    is_digit=True
    Basic.CheckVariableValid    var=TestReportPrefix   default_value=PZ4_SG01

    log to console   WTS_CFG is ${WTS_CFG}
    log to console   WTS_CFG1 is ${WTS_CFG1}
    log to console   NumOfAirphone is ${NumOfAirphone}
    log to console   TestingDuration is ${TestingDuration}
    log to console   isSharedPBwithAiphone is ${isSharedPBwithAiphone}
    log to console   isIWFused is ${isIWFused}

    Create Suite Directory
    ${stream}   ${subversion}    Split String   string=${gnb_version}   separator=_     max_split=1

    Set Suite Variable    ${JID_LUA}    ${WTS_CFG1}
    Set Suite Variable    ${JID_SCF}    NO
    ${JID_IPHY}=    Create List
    FOR  ${index}  IN RANGE     ${numofairphone}
        Append To List    ${JID_IPHY}    NO
    END
    Set Suite Variable    ${JID_IPHY}    ${JID_IPHY}
    Set Suite Variable    ${JID_MODE}    0
    Set Suite Variable    ${JID_DURATION}    ${TestingDuration}
    Set Suite Variable    ${JID_REPORTTAG}    RTM
    Set Suite Variable    ${JID_TEMPLETEID}    ${TestTempleteID}
    Set Suite Variable    ${JID_REPORTPREFIX}    ${TestReportPrefix}

    #gNB.Commission    scf_file=${CFGFILE_PATH}/${Stream}.xml    timeout=${1800}
    #wait until keyword succeeds   15min   1min    COAM_Admin.CheckAllCellsOnair
#    run keyword unless   "${scf_file}"=="None"   gNB.Commission    scf_file=${scf_file}    timeout=${1800}
    #sleep   5min

Teardown Suite
    Run keyword and ignore error    ute_wtssim.Execute Egate Command
    ...    cmd=ue_deregister id=all ue_deregister_type=switch_off
    ...    timeout=5min
    Run keyword and ignore error    ute_wtssim.teardown_edaemon   alias=edaemon
    Run keyword and ignore error    ute_wtssim.teardown_egate
    kill the UEC port after the test is completed
    Run keyword and ignore error    Clear temp logs in all hosts
    Conn.ResetCache


Setup Case
    [Arguments]   ${wts_cfg}
    Create Test Directory
    Get Test Env Ready   wts_cfg=${wts_cfg}
    #Start BTSlog

Teardown Case
    [Arguments]   ${mode}=0
    log to Console    teardown start...
    # Log To Console    stop MutliUE service...

    ${AirPhoneList}   Construct Airphone list    numofairphone=${NumOfAirphone}


    FOR    ${airphone}    IN    @{AirPhoneList}
        Log To Console    stop MutliUE service... from RTM: ${RTM_server_ip} to Airphone: ${airphone}[0]
        MutliUE    operation=Stop    mode=${mode}   RTM_SERVER_IP=${RTM_server_ip}    CONTROL_PC_IP=${airphone}[0]
    END


    #MutliUE    operation=Stop    mode=${mode}

#    Run keyword and ignore error    Stop BTSlog
#    Run keyword and ignore error    Collect SoSReport Log
    #Run keyword and ignore error    Collect Snapshot
    #Run keyword and ignore error    ute_wtssim.teardown_edaemon   alias=edaemon
    #Run keyword and ignore error    ute_wtssim.teardown_egate
    #Conn.ResetCache


#   Anyone sent RTM-start/stop req to RTM server can start/stop the RTM service to "control PC"
#   here is not a safe way, but is not a key issue, because RTM is only used internally.
#   RTM server will sent the TESTING COMMANDS to ControlPC's so, controlPC's IP should be the one by which egate can
#   be found. In 1-Airphone TL, egate is usually deployed in UTE, so by default, UTE-IP is used.
#   otherwise, the IP addresses of the server in which egate is deployed should be used.
MutliUE
    [Arguments]   ${operation}    ${mode}=0    ${RTM_SERVER_IP}=${RTM_server_ip}    ${CONTROL_PC_IP}=${UTE_IP}
    robssh.Open Connection    host=127.0.0.1    port=22    timeout=60
    robssh.Login    username=${UTE_USERNAME}    password=${UTE_PASSWORD}   delay=1s
    ${output}   robssh.Write
    ...    curl -X 'GET' 'http://${RTM_SERVER_IP}:11000/api/MultiUEManager/${operation}ControlPC?ip=${CONTROL_PC_IP}&jID=${mode}' -H 'accept: */*'



Construct Airphone list
    [Arguments]   ${numofairphone}=1

    ${airphoneslist}=    Create List
    FOR  ${index}  IN RANGE     ${numofairphone}
        log to console    JID_IPHY_${index}=${JID_IPHY[${index}]}
        ${airphone_instance}=  Create List    ${tl.ues[${index}].l3_ssh_connection_details.addr}
                                       ...    ${tl.ues[${index}].l3_ssh_connection_details.username}
                                       ...    ${tl.ues[${index}].l3_ssh_connection_details.password}
                                       ...    ${JID_IPHY[${index}]}
        Append To List    ${airphoneslist}    ${airphone_instance}
    END

    FOR    ${airphone_instance}    IN    @{airphoneslist}
        Log To Console    airphone is created: ${airphone_instance}
    END

    [Return]   @{airphoneslist}


Setup Case for ap
    [Arguments]   ${wts_cfg}    ${mode}=0
    Create Test Directory
    log to console    JID_LUA=${JID_LUA}
    log to console    JID_SCF=${JID_SCF}
    log to console    JID_MODE=${JID_MODE}
    log to console    JID_DURATION=${JID_DURATION}
    log to console    JID_REPORTTAG=${JID_REPORTTAG}
    ${AirPhoneList}   Construct Airphone list    numofairphone=${NumOfAirphone}

    Get Test Env Ready for ap    airphonelist=${AirPhoneList}   wts_cfg=${wts_cfg}     mode=${mode}

Run case in other WTS hosts
    FOR  ${wts}  IN  @{WTS_HOSTS}
        ${index}    Get index from list    ${WTS_HOSTS}    ${wts}
        ${status}   Run Keyword and Return Status   ssh.Connect to    hostname=${wts}    username=${UTE_USERNAME}
        ...    password=${UTE_PASSWORD}    alias=wts_${index}
        ${result}    Run Keyword If    ${status}    ssh.Execute    command=${CMD_RUN_IN_WTS_HOSTS}   connection=wts_${index}
        ...    ELSE   log    connect to wts_${index} failed.
        run keyword and ignore error    ssh.disconnect    connection=wts_${index}
    END

Run Case via Lua
    [Arguments]   ${case}   ${timeout}   ${expected_result}  ${unexpected_result}=[c|C]rash|Unhandled Exception
    ...    ${script}=${TEST_SCRIPT}   ${stop_script}=false
    Log To Console    \n  SA 5G attach with lua script...
#    ${pattern1}    Set Variable     All pdu session setup successful
    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${WTS_DIR}/${script} entry\=${case}
    ...    pass_regexp=${expected_result}   fail_regexp=${unexpected_result}  timeout=${timeout}
    ...    return_output=${False}
#    ${attach_result1}    String.Get Lines Matching Regexp    ${output1}    ${pattern1}    partial_match=True
    run keyword if  '${stop_script}'=='true'   ute_wtssim.execute_egate_command   cmd=script_stop

Create Suite Directory
    [Documentation]    This keyword is to create a directory for storing suite level logs.
    ...
    ...    ${SUITE_LOG_DIRECTORY} is a suite variable.
    ...    before refine: Test_Suite_Folder_1605087516120
    ...    after refine: Test_Suite_Folder_20201112151625116
    Log To Console    Create Suite: ${SUITE_NAME}'s Directory...

    ${time_string}    DateTime.Get Current Date    result_format=timestamp
    ${time_string}    String.Replace String Using Regexp    ${time_string}    (-|:)    ${EMPTY}
    ${time_string}    String.Replace String    ${time_string}    ${SPACE}    ${EMPTY}
    ${time_string}    String.Remove String    ${time_string}    .
    ${suite_name2}    String.Replace String    ${SUITE_NAME}    ${SPACE}    _
    Create Directory    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${OUTPUT_DIR}/log/${suite_name2}_${time_string}

Create Test Directory
    [Documentation]    This keyword is to create a directory for storing case level logs.
    ...
    ...        ${TEST_LOG_DIRECTORY} is a test variable.
    Log To Console    Create Case Directory...
    ${test_name2}    string.Replace String    ${TEST_NAME[:50]}    ${space}    _
    Create Directory    ${SUITE_LOG_DIRECTORY}/${test_name2}
    Set Test Variable    ${TEST_LOG_DIRECTORY}    ${SUITE_LOG_DIRECTORY}/${test_name2}


Start UTE WTS
    [Arguments]   ${wts_cfg}=${WTS_CFG}
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    Run keyword and ignore error    ute_wtssim.teardown_edaemon   alias=edaemon
    Run keyword and ignore error    ute_wtssim.teardown_egate
    Log To Console    Starting WTS...
    Run Keyword And Ignore Error    Stop Edaemon Egate
    #ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}    alias=edaemon
    #ute_wtssim.Start Edaemon Process    alias=edaemon
    #ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}
    #ute_wtssim.Start Egate Process

    ${pattern}    Set Variable     SimMode is ready now
    ute_wtssim.Setup Edaemon    edaemon_port=22222    tool_dir=${WTS_DIR}   ssh_pass=${UTE_PASSWORD}   alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=20000    tool_dir=${WTS_DIR}   ssh_pass=${UTE_PASSWORD}
    ute_wtssim.Start Egate Process
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    cmd=cfg file\=${WTS_DIR}/${wts_cfg}
    ...    pass_regexp=${pattern}   timeout=5min
    ${Start_UTE_WTS_result}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Wait Until Keyword Succeeds    120s    15s
    ...    ute_wtssim.Execute Egate Command    state_sim_disp   pass_regexp=The state is ACTIVE   return_output=${False}

Start WTS service
    [Arguments]    ${CONTROL_PC_IP}=${UTE_IP}    ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}    ${wts_cfg}=${WTS_CFG}
    [Documentation]    This keyword is to kill Running WTS Binaries If Any, Configure ETH3, Retrieve Files And Configure WTS
    robssh.Open Connection    host=${CONTROL_PC_IP}    port=22    timeout=60
    robssh.Login    username=${username}    password=${password}   delay=1s
    Sleep    5s
    robssh.Write   cd /home/ute/WTS_latest && sudo ./edaemon --port 22222 && ./egate --port 20000
	Sleep    10s
    robssh.Write   telnet 0 20000
    robssh.Read Until    expected=>
    #robssh.Write   reset
	Sleep    5s
	Log To Console   cfg file=/home/ute/WTS_latest/${wts_cfg}

	robssh.Write   cfg file=/home/ute/WTS_latest/${wts_cfg}
	Sleep    10s
  	robssh.Write   exit

Stop WTS service
    [Arguments]   ${CONTROL_PC_IP}=${UTE_IP}    ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}
    robssh.Open Connection    host=${CONTROL_PC_IP}    port=22    timeout=60
    robssh.Login    username=${username}    password=${password}   delay=1s
    Sleep    5s
	  robssh.Write   sudo pkill -9 edaemon && pkill -9 egate
    Sleep    5s
    robssh.Write   exit

Get Test Env Ready if Not
    [Documentation]  if gnb is not on air, powercycle gnb and all Airphones, then restart WTS in the first ute that
    ...   control the frist Airphone. Then, kill egate and edeamon in the rest WTSs that control other airphones,if any,
    ...   the WTSs in which can be started later with this KW "Run case in other WTS hosts".
    [Arguments]   ${wts_cfg}=${WTS_CFG}
    Start UTE WTS  wts_cfg=${wts_cfg}
    ${is_onair}   Run Keyword and Return Status   wait until keyword succeeds    10min    1min    gNB.VerifyOnAirViaOAMUntilReady
    return from keyword if   ${is_onair}
    Get Test Env Ready   wts_cfg=${wts_cfg}

Get Test Env Ready
    [Documentation]  if gnb is not on air, powercycle gnb and all Airphones, then restart WTS in the first ute that
    ...   control the frist Airphone. Then, kill egate and edeamon in the rest WTSs that control other airphones,if any,
    ...   the WTSs in which can be started later with this KW "Run case in other WTS hosts".
    [Arguments]   ${wts_cfg}=${WTS_CFG}
    PowerCycle Testline
    Start UTE WTS  wts_cfg=${wts_cfg}
    ${is_onair}   Run Keyword and Return Status   wait until keyword succeeds    10min    1min    gNB.VerifyOnAirViaOAMUntilReady
    should be true    ${is_onair}

Get Test Env Ready for ap
    [Documentation]  if gnb is not on air, powercycle gnb and all Airphones, then restart WTS in the first ute that
    ...   control the frist Airphone. Then, kill egate and edeamon in the rest WTSs that control other airphones,if any,
    ...   the WTSs in which can be started later with this KW "Run case in other WTS hosts".
    [Arguments]   ${airphonelist}   ${wts_cfg}=${WTS_CFG}    ${mode}=0

    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 1: stop RTM service
    # Usually, RTM service is deployed in one server for 1 Testline
    # Log To Console    stop MutliUE service...
    # MutliUE    operation=Stop    mode=${mode}
    FOR    ${airphone}    IN    @{airphonelist}
        Log To Console    stop MutliUE service... from RTM: ${RTM_server_ip} to Airphone: ${airphone}[0]
        MutliUE    operation=Stop    mode=${mode}   RTM_SERVER_IP=${RTM_server_ip}    CONTROL_PC_IP=${airphone}[0]
    END
    # -----------------------------------------------------------------------------------------------------
    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 2: stop airphone(egate) service
    # stop egate service of airphones
    FOR    ${airphone}    IN    @{airphonelist}
        Log To Console    stop Airphone: ${airphone}[0] WTS service...
        Stop WTS service    CONTROL_PC_IP=${airphone}[0]    username=${airphone}[1]    password=${airphone}[2]
    END
    # -----------------------------------------------------------------------------------------------------

    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 3: Reset airphone(Airscale)
    # reset aiphones(airscale) by ssh-reset command
    #IF   ${numberofairphone}==1
    #    Reboot AP Via SSH
    #ELSE
    Reboot APs Via SSH   airphonelist=${airphonelist}
    #END
    # -----------------------------------------------------------------------------------------------------

    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 4: PowerRESET gNB
    Log to console    start powercycling gnb
    run keyword if    '${JID_SCF}'!='NO'    gNB.Commission    scf_file=${CFGFILE_PATH}/${JID_SCF}    timeout=${1800}
    ...   ELSE    Power.ResetgNB    model=${PB_DU_Vendor}
    #Power.ResetgNB    pdu_ip=${PB_AP_IP}    Port_Number=${PB_AP_PORT}   model=${PB_AP_Vendor}

    IF   '${isSharedPBwithAiphone}'=='True'
        #temp solution for sharing PB between gNB and AP
        Log to console    STEP 4.1: waiting for 15 minutes...
    END
    sleep  10min
    # -----------------------------------------------------------------------------------------------------

    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 5: waiting for RU detection
    Log To Console    waiting for RU detection...
    wait until keyword succeeds    10min    60s    KW.CheckAllRUstate
    #sleep   120s
    # -----------------------------------------------------------------------------------------------------


    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 6: start airphone(egate) service
    # start egate service of airphones
    FOR    ${airphone}    IN    @{airphonelist}
        IF   '${isIWFused}'=='True'
            Log To Console    start Airphone: ${airphone}[0] IWF service...
            KW.ResetIWF        CONTROL_PC_IP=${airphone}[0]    username=${airphone}[1]
            ...    password=${airphone}[2]
            Log To Console   sleeping 20 seconds
            sleep    20s
        END

        Log To Console    start Airphone: ${airphone}[0] WTS service...
        Start WTS service  CONTROL_PC_IP=${airphone}[0]    username=${airphone}[1]
        ...    password=${airphone}[2]    wts_cfg=${wts_cfg}
    END
    # -----------------------------------------------------------------------------------------------------

    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 7: Waiting for cell on air
    Log To Console    start check onair...
    ${is_onair}   Run Keyword and Return Status   wait until keyword succeeds    10min    1min    gNB.VerifyOnAirViaOAMUntilReady
    should be true    ${is_onair}
    Log to console    STEP 7.1: sleep 300 second...
    sleep   300s
    # -----------------------------------------------------------------------------------------------------

    # -----------------------------------------------------------------------------------------------------
    Log to console    STEP 8: start RTM service
    FOR    ${airphone}    IN    @{airphonelist}
        Log To Console    start MutliUE service... from RTM: ${RTM_server_ip} to Airphone: ${airphone}[0]
        MutliUE    operation=Start    mode=${mode}   RTM_SERVER_IP=${RTM_server_ip}    CONTROL_PC_IP=${airphone}[0]
    END
    # -----------------------------------------------------------------------------------------------------

    #${UTC_time}  DateTime.Get Current Date  result_format=%Y-%m-%dT%H:%M:%S  time_zone=UTC
    #Set Global Variable    ${TESTING_START_TIME}    ${UTC_time}
    #Log To Console    Testing is started at UTC time: ${TESTING_START_TIME}


KW.ResetIWF
    [Arguments]   ${CONTROL_PC_IP}=${UTE_IP}    ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}
    robssh.Open Connection    host=${CONTROL_PC_IP}    port=22    timeout=60
    robssh.Login    username=${username}    password=${password}   delay=1s
    Sleep    5s
	  robssh.Write   sudo pkill -9 iwf && cd /home/ute/WTS_latest && sudo python3 iwf_preconfigs.py||true && sudo python3 iwf_launch.py
    Sleep    60s
    robssh.Write   exit



KW.CheckAllRUstate
    [Arguments]     ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    &{hw_info}       coam.get_detected_hw_info    connection=${connection}
    ${rmod_info}    set variable    ${hw_info.radioModules.rmod}
    FOR  ${ru}  IN  @{rmod_info}
        ${ru_procedural_state}  set variable  ${ru.status.proceduralStatus}
        Should Be Equal    ${ru_procedural_state}   configured
    END

WEBUI.Collect snapshot
    [Arguments]    ${loop}=0
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    Run Keyword And Ignore Error    COAM_WebEM.Logout
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    Run Keyword And Ignore Error    run    command=mv ${snapshot_file} ${LOG_PATH}/snapshot_${filename}_${loop}.zip

PowerCycle Testline
    log to console    start powercycling gnb and primary airphone, rebooting other airphones.
    Power.ResetgNB    model=HBTE
    Power.ResetgNB    pdu_ip=${PB_AP_IP}    Port_Number=${PB_AP_PORT}   model=HBTE
#    Stop Edaemon Egate
    Run keyword and ignore error    ute_wtssim.teardown_edaemon   alias=edaemon
    Run keyword and ignore error    ute_wtssim.teardown_egate
    FOR  ${wts}  IN  @{WTS_HOSTS}
        ${index}    Get index from list    ${WTS_HOSTS}    ${wts}
        ${status}   Run Keyword and Return Status   ssh.Connect to    hostname=${wts}    username=${UTE_USERNAME}
        ...    password=${UTE_PASSWORD}    alias=wts_${index}
        ${result}    Run Keyword If    ${status}    run keywords
        ...    ssh.Execute   command=ps -ef | grep edaemon | grep -v grep | awk '{print$2}'|xargs sudo kill -9   connection=wts_${index}
        ...    AND    ssh.Execute   command=ps -ef | grep egate | grep -v grep | awk '{print$2}'|xargs kill -9   connection=wts_${index}
        ...    ELSE   log    connect to wts_${index} failed.
        ssh.Connect to  ${AP_LMP_IP}   ${AP_USERNAME}  ${AP_PASSWORD}  alias=ap_${index}  proxy=wts_${index}
        ssh.send_command   command=reboot   connection=ap_${index}
        run keyword and ignore error    ssh.disconnect    connection=ap_${index}
        run keyword and ignore error    ssh.disconnect    connection=wts_${index}
    END
    sleep  8min

Clear temp logs in all hosts
    log to console    Removing logs from all UTE VMs.
    FOR  ${wts}  IN  @{ALL_WTS_HOSTS}
        ${index}    Get index from list    ${ALL_WTS_HOSTS}    ${wts}
        ${status}   Run Keyword and Return Status   ssh.Connect to    hostname=${wts}    username=${UTE_USERNAME}
        ...    password=${UTE_PASSWORD}    alias=wts_${index}
        ${result}    Run Keyword If    ${status}    run keyword
        ...    ssh.Execute   command=cd ${WTS_DIR};sudo rm *.log*;cd /tmp;ls|grep -v btslog2|xargs sudo rm -rf  connection=wts_${index}
        ...    ELSE   log    connect to wts_${index} failed.
        run keyword and ignore error    ssh.disconnect    connection=wts_${index}
    END
    sleep  5min

Stop Edaemon Egate
    log to console    Stopping edaemon and egate
    OperatingSystem.Run    sudo pkill edaemon
    OperatingSystem.Run    sudo pkill egate
    OperatingSystem.Run    sudo pkill 22222
    OperatingSystem.Run    sudo pkill 20000


Start BTSlog
    [Documentation]    collect syslogs from ute VM.
    run keyword and ignore error    run    command=rm /tmp/btslog2/* -rf
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/home/ute/btslog/btslog
    ...   btslog_launcher_path=/home/ute/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Stop BTSlog
    core.teardown_collectors      names=btslog
    ${time}    Get Time    epoch
    ${filename}    set variable    ${TEST NAME.replace(" ", "_").replace("(", "").replace(")", "").replace("[", "").replace("]", "")}
    #run    command=cd /tmp/btslog2 ; ls -al ; cat SYSLOG_*.LOG > SYSLOG_combine.LOG
    run    command=cd /tmp/btslog2 ; tar zcvf /tmp/${filename}_SYSLOG_${time}.tgz SYSLOG_*.LOG
    run    command=cp /tmp/${filename}_SYSLOG_${time}.tgz ${LOG_PATH}/.
    [Return]    ${TEST_LOG_DIRECTORY}/${filename}_SYSLOG_${time}.tgz

Get gNB Active SW Version
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   10x   1min    COAM_Admin.Login    alias=${connection}
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.TransferSWVersion   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
    COAM_Admin.Logout
    [Return]   ${active_sw_version}

Get Airphone Software Version
    ute_fsmaccess.Setup Wts Fsm Access
    ${cmd}=    Set Variable    ls /ffs/run/TargetBD_*.xml
    ${targetbd_file}=    ute_fsmaccess.Execute Command On Wts    ${cmd}
    ${tmp1}=    String.Fetch From Right    ${targetbd_file}    TargetBD_
    ${AP_version}=    String.Fetch From Left    ${tmp1}    .xml
    Log    AP Software Version: ${AP_version}      console=${True}
    Set Suite Metadata    AP Version    ${AP_version}
    [Teardown]    ute_fsmaccess.Teardown Wts Fsm Access
    [Return]    ${AP_version}

Get WTS Version
    [Documentation]    This keyword is to get WTS version including below 1 suite variable.
    ...
    ...    | Suite variable | Example | Description |
    ...    | ${WTS_VERSION} | 4.0.13303 | WTS version |
    ...
    ${rc}    ${output}    OperatingSystem.Run And Return Rc And Output    ls -la /opt/iphy/latest
    @{split_list}    String.Split String    ${output}    /
    Set Suite Variable    ${WTS_VERSION}    ${split_list[-1]}
    Log    WTS Version: ${WTS_VERSION}     console=${True}

Connect To AP ASIK
    [Documentation]    This keyword is to connect to Airphone ASIK
    SSH.Connect To    ${AP_ASIK.ip}    ${AP_ASIK.username}    ${AP_ASIK.password}
    ...    alias=${AP_ASIK.connection}

Connect To GNB FCT
    Connect To GNB ASIK

Connect To GNB ASIK
    [Documentation]    This keyword is to connect to Airphone ASIK
    SSH.Connect To    ${GNB_ASIK.ip}    ${GNB_ASIK.username}    ${GNB_ASIK.password}
    ...    alias=${GNB_ASIK.connection}



SA.Egate.multi UEs Deregister with lua script
    [Arguments]    ${UE_num}
     Log To Console    deregister with lua script...
    ${pattern1}    Set Variable     all UEs deregister successful
    ${output1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=${WTS_DIR}/register_and_deregister_golden.lua entry\=ue_deregister_with_pdu_release(1,${UE_num})
    ...    pass_regexp=${pattern1}    timeout=20min    return_output=${False}
    ${attach_result1}    String.Get Lines Matching Regexp    ${output1}    ${pattern1}    partial_match=True


Reset HW both side and check status ready
    [Arguments]   ${InstallPackage_path}=/opt/transformers.dynamic.nsn-net.net/workspace/CRT/Master/Manual
    #gNB.Configure Airphone DCI link
    #Run Keyword And Ignore Error    gNB.Enable_DebugLog
    Kill egate and edaemon
    Run Keyword And Ignore Error   run     command=sudo rm -r ${InstallPackage_path}/InstallPackageOnly*
    sleep  3s
    Run Keyword And Ignore Error   run     command=sudo rm -r ${WTS_DIR}/*.log.*
    sleep   10s
    Power.ResetgNB    model=HBTE
    sleep   3min
    #check HW ready both gNB and AP side

Reset HW both side and check status ready for ASIL
    [Arguments]   ${InstallPackage_path}=/opt/transformers.dynamic.nsn-net.net/workspace/CRT/Master/Manual
    #Run Keyword And Ignore Error    gNB.Enable_DebugLog
    Kill egate and edaemon
    Run Keyword And Ignore Error   run     command=sudo rm -r ${InstallPackage_path}/InstallPackageOnly*
    sleep  3s
    Run Keyword And Ignore Error   run     command=sudo rm -r ${WTS_DIR}/*.log.*
    sleep   10s
    Power.ResetgNB    model=HBTE
    sleep   3min
    check HW ready both gNB and AP side


SA.check NG link setup
    Log To Console    start to check NG link ...
    ute_wtssim.Execute Egate Command    sim_log_set flush  timeout=1min
    ${value}    run     command=cat ${WTS_DIR}/egate_console.log |grep NG
    Should Contain   ${value}   NG link is Up
    Log   NG link is Up
    Log   NG Link to gNB=2 is now Active


Kill egate and edaemon
    Log To Console    clear egate and edaemon start...
    Run Keyword And Ignore Error   run     command=ps -ef|grep edaemon |grep -v grep |awk '{print $2}' |xargs sudo kill -2
    Run Keyword And Ignore Error   run     command=ps -ef|grep egate |grep -v grep |awk '{print $2}' |xargs kill -2
    Run Keyword And Ignore Error    ute_wtssim.Teardown Edaemon    alias=edaemon
    Run Keyword And Ignore Error    ute_wtssim.Teardown Egate
    Log To Console    clear egate and edaemon done...


UTE.connect
    #ssh.connect to    hostname=10.57.240.35   username=ute    password=ute    alias=${ALIAS_UTE}
    ssh.connect to    hostname=${UTE_IP}     username=${UTE_USERNAME}     password=${UTE_PASSWORD}  alias=${ALIAS_UTE}


UTE.disconnect
    [Arguments]    ${connection}=${ALIAS_UTE}
    ssh.disconnect    connection=${connection}

UTE.Wireshark.StartCaptureAPLog
    UTE.connect
    Run Keyword And Ignore Error   ssh.send command  command=sudo tcpdump -i eth3 -w /tmp/AP_trace_log.pcap -vv sctp  connection=${ALIAS_UTE}

UTE.Wireshark.StopCapturingAPlog
    [Arguments]  ${listen_port}=eth3
    Run Keyword And Ignore Error  ssh.send command
    ...    command=sudo ps -ef|grep tcpdump|grep -v grep|grep ${listen_port}|awk '{print $2}'|xargs kill -2
    ...    connection=${ALIAS_UTE}
UTE.Wireshark.DownloadAPLogTologfolder
    [Arguments]    ${filename}=AP_trace_log.pcap
    Run Keyword And Ignore Error   ssh.execute  command=sudo cp /tmp/AP_trace_log.pcap ${LOG_PATH}${/}${filename}   connection=${ALIAS_UTE}
    UTE.disconnect



COAM_WEBEM.CheckBTSConutersWithConditioanalTraget
    [Arguments]    ${counter_id}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    [return]    ${values[-1]}

COAM_WEBEM.CheckBTSConutersWithConditioanalTraget1
    [Arguments]    ${counter_id}   ${full_path}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_bts_counters_info   counter_id=${counter_id}  full_path=${full_path}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    [return]    ${values[-1]}

COAM_WEBEM.CheckTransportConutersWithConditioanalTraget
    [Arguments]    ${counter_id}
    ${date}   Get Current Date   exclude_millis=True
    ${res}   selenium_coam.get_transport_counters   counter_id=${counter_id}
    ${values}    get dictionary values   ${res}
    log  The latest one is: ${values[-1]}
    [return]    ${values[-1]}

check memory at gNB side on WebEM Transport counter
    [Arguments]    ${traffic_mode}=1  ${testline}=HZ_TL210_Airphone  ${test_time}=0  ${DL_Tput}=0  ${UL_TP}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/benchmark/input/?version=
    ${version}    GetgNBSWVersion
    ${ASIK_CPU_LOAD}    gNB.collect ASIK CPU usage
    ${ASIK_MEM}    gNB.collect ASIK Memory usage
    ${ABIL_CPU_LOAD}    gNB.collect ABIL CPU usage
    ${ABIL_MEM}    gNB.collect ABIL Memory usage
    ${TOP}  set variable   ABIL_CPU_LOAD=${ABIL_CPU_LOAD}%&ABIL_MEM=${ABIL_MEM}%&ASIK_CPU_LOAD=${ASIK_CPU_LOAD}%&ASIK_MEM=${ASIK_MEM}%
    ${TOP1}  set variable   traffic_mode=${traffic_mode}&CELL_UL_TPUT=${UL_TP}Mbit/s&CELL_DL_TPUT=${DL_Tput}Mbit/s&SAMPLE_TIME=${test_time}
    #${res}    urllib.urlopen    url=${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    ${toolcenterURL}    set variable    ${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}
    ${res}    requests.post    ${toolcenterURL}    data=${final_data}
    log to console       ${res.read()}

check UL traffic at gNB side on WebEM Transport counter
    [Arguments]    ${traffic_mode}  ${testline}=HZ_TL210_Airphone  ${test_time}=0  ${DL_Tput}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/benchmark/input/?version=
    ${version}    GetgNBSWVersion
    ${UL_TP}      COAM_Admin.evaluate UL_TPUT
    ${ASIK_CPU_LOAD}    gNB.collect ASIK CPU usage
    ${ASIK_MEM}    gNB.collect ASIK Memory usage
    ${ABIL_CPU_LOAD}    gNB.collect ABIL CPU usage
    ${ABIL_MEM}    gNB.collect ABIL Memory usage
    ${TOP}  set variable   ABIL_CPU_LOAD=${ABIL_CPU_LOAD}%&ABIL_MEM=${ABIL_MEM}%&ASIK_CPU_LOAD=${ASIK_CPU_LOAD}%&ASIK_MEM=${ASIK_MEM}%
    ${TOP1}  set variable   traffic_mode=${traffic_mode}&CELL_UL_TPUT=${UL_TP}Mbit/s&CELL_DL_TPUT=${DL_Tput}Mbit/s&SAMPLE_TIME=${test_time}
    #${res}    urllib.urlopen    url=${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    ${toolcenterURL}    set variable    ${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}
    ${res}    requests.post    ${toolcenterURL}    data=${final_data}
    log to console       ${res.read()}

check traffic at gNB side on WebEM Transport counter for high TP
    [Arguments]    ${UE_num}   ${traffic_mode}  ${testline}=HZ_TL210_Airphone   ${test_time}=0
    ...    ${URL}=http://toolscenter.eecloud.dynamic.nsn-net.net/api/benchmark/input/?version=
    #${DL_Tput}     NSA.Egate.Verify DL Throughput    UE_num=${UE_num}
    log to console       ${UE_num}
    ${DL_Tput}          COAM_Admin.evaluate DL_TPUT
    ${version}          GetgNBSWVersion
    ${UL_TP}            COAM_Admin.evaluate UL_TPUT
    ${ASIK_CPU_LOAD}    gNB.collect ASIK CPU usage
    ${ASIK_MEM}         gNB.collect ASIK Memory usage
    ${ABIL_CPU_LOAD}    gNB.collect ABIL CPU usage
    ${ABIL_MEM}         gNB.collect ABIL Memory usage
    ${TOP}  set variable   ABIL_CPU_LOAD=${ABIL_CPU_LOAD}%&ABIL_MEM=${ABIL_MEM}%&ASIK_CPU_LOAD=${ASIK_CPU_LOAD}%&ASIK_MEM=${ASIK_MEM}%
    ${TOP1}  set variable   traffic_mode=${traffic_mode}&CELL_UL_TPUT=${UL_TP}Mbit/s&CELL_DL_TPUT=${DL_Tput}Mbit/s&SAMPLE_TIME=${test_time}
    #${res}    urllib.urlopen    url=${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    ${toolcenterURL}    set variable    ${URL}${version}&testline=${testline}&${TOP}&${TOP1}
    &{final_data}   create dictionary     Testline=${testline}
    ...    Version=${gnb_version}    Result=${TEST STATUS}
    ...    &{data}
    log dictionary    ${final_data}
    ${res}    requests.post    ${toolcenterURL}    data=${final_data}
    sleep   5s
    log to console       ${res.read()}

gNB.collect ASIK CPU usage
    gNB.Connect
    ${result}    ssh.execute  command=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'
    ...    connection=${ALIAS_ASIK}
    ${ASIK_CPU_LOAD}    Evaluate   round(${result},2)
    log to console       ASIK_CPU_LOAD is ${ASIK_CPU_LOAD}
    gNB.Disconnect
    [Return]   ${ASIK_CPU_LOAD}

gNB.collect ASIK Memory usage
    gNB.Connect
    ${result}    ssh.execute  command=free | grep 'Mem:' | awk -F ' ' '{print $3/$2*100}'   connection=${ALIAS_ASIK}
    #${Mem total}    ssh.execute  command=top -b -n 1 | grep 'KiB Mem :' -A 0| awk -F ' ' '{print $4}'    connection=${ALIAS_ASIK}
    #${Mem used}    ssh.execute  command=top -b -n 1 | grep 'KiB Mem :' -A 0| awk -F ' ' '{print $8}'    connection=${ALIAS_ASIK}
    #${result}   Evaluate    float(${Mem used})*100/float(${Mem total})
    ${ASIK_MEM}    Evaluate   round(${result},2)
    log to console       ASIK_MEM is ${ASIK_MEM}
    gNB.Disconnect
    [Return]   ${ASIK_MEM}

gNB.collect ABIL CPU usage
    gNB_ABIL.Connect
    ${result}    ssh.execute  command=grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'
    ...    connection=${ALIAS_ABIL_SLAVE}
    ${ABIL_CPU_LOAD}    Evaluate   round(${result},2)
    log to console       ABIL_CPU_LOAD is ${ABIL_CPU_LOAD}
    gNB_ABIL.Disconnect
    [Return]   ${ABIL_CPU_LOAD}

gNB.collect ABIL Memory usage
    gNB_ABIL.Connect
    ${result}    ssh.execute  command=free | grep 'Mem:' | awk -F ' ' '{print $3/$2*100}'   connection=${ALIAS_ABIL_SLAVE}
    ${ABIL_MEM}    Evaluate   round(${result},2)
    log to console       ABIL_MEM is ${ABIL_MEM}
    gNB_ABIL.Connect
    [Return]   ${ABIL_MEM}

GetgNBSWVersion
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   3x   1min    COAM_Admin.Login
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    #${active_5g_rat_version}   Set Variable   ${sw_info['Active 5G RAT version']}
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.Transfer SW Version   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
        COAM_Admin.Logout
    [Return]   ${active_sw_version}

COAM_Admin.evaluate DL_TPUT
    COAM_WebEM.Login
    ${DL_PDCP_SDU_volume}   Wait until keyword succeeds   5x   4min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget   counter_id=M55319C02009
    ${users_denominator}   Wait until keyword succeeds   5x   4min   COAM_WEBEM.CheckBTSConutersWithConditioanalTraget    counter_id=M55114C00009
    should not be equal    ${DL_PDCP_SDU_volume}   0
    should not be equal    ${users_denominator}    0
    ${result}    Evaluate    8*float(${DL_PDCP_SDU_volume})/${users_denominator}/1000
    ${DL_TP}    Evaluate   round(${result},2)
    log to console      DL_TPUT is ${DL_TP}
    COAM_WebEM.Logout
    [return]    ${DL_TP}

COAM_Admin.evaluate UL_TPUT
    COAM_WebEM.Login
    #check BTS counter value
    ${output}   Wait until keyword succeeds   5x   4min     COAM_WEBEM.CheckTransportConutersWithConditioanalTraget    counter_id=M51321C2
    ${measurement time}    get IP interface statistics measurement interval on WebEM
    ${result}    Evaluate    8*float(${output})/${measurement time}/60/1000/1000
    ${UL_TP}    Evaluate   round(${result},2)
    log to console      UL_TPUT is ${UL_TP}
    COAM_WebEM.Logout
    [return]    ${UL_TP}

get IP interface statistics measurement interval on WebEM
    [Arguments]   ${dist_name}=MRBTS-1/TNLSVC-1/TNL-1/PMTNL-1    ${search_text}=IP interface statistics measurement interval
    ${result}   selenium_coam.get_parameter_value   dist_name=${dist_name}  filter_param=${search_text}
    ...    abbr=ipInterfaceStatisticsInterval  timeout=30
    ${measurement time}    fetch from left    ${result}    min
    [Return]   ${measurement time}

Conn.ConnectABILWithTimeout
    [Arguments]    ${alias}
    Wait Until Keyword Succeeds    10min    30sec    Conn.ConnectABIL   alias=${alias}

Conn.ConnectABIL
    [Arguments]    ${alias}
    Run Keyword If    '${alias}'=='${ALIAS_ABIL}'    ssh.Connect to    ${FSP_IP}   ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${ALIAS_ABIL}  proxy=${ALIAS_ASIK}
    ...    ELSE IF     '${alias}'=='${ALIAS_ABIL_SLAVE}'    ssh.Connect to    ${FSP_SLAVE_IP}   ${ASIK_USERNAME}    ${ASIK_PASSWORD}
    ...                alias=${ALIAS_ABIL_SLAVE}    proxy=${ALIAS_ASIK}
    ...    ELSE    Fail    Unknow alias

gNB_ABIL.Connect
    gNB.Connect
    Conn.ConnectABILWithTimeout  alias=${ALIAS_ABIL}
    Conn.ConnectABILWithTimeout  alias=${ALIAS_ABIL_SLAVE}

gNB_ABIL.Disconnect
    Conn.Disconnect  alias=${ALIAS_ABIL}
    Conn.Disconnect  alias=${ALIAS_ABIL_SLAVE}

check HW ready both gNB and AP side
    Log To Console    start to check gNB and AP HW status...
    Run Keyword And Continue On Failure    Check gNB HW status ready
#    run keyword and ignore error    COAM_WebEM.Login
#    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
#    Wait Until Keyword Succeeds    20min    1min     COAM Check GNB RU status
#    run keyword and ignore error    COAM_WebEM.Logout
    #Run Keyword And Continue On Failure    Check ALL RUs Online
    #Run Keyword And Continue On Failure    Check AP HW status ready
    #Run Keyword And Continue On Failure    check AP container ready
    Log To Console    gNB and AP HW status are ready


Check gNB HW status on WebEM
    Run Keyword And Continue On Failure    Check ASIK is UP
    #Run Keyword And Continue On Failure    Check ABIL is UP
    #Run Keyword And Continue On Failure    Check ABIL is UP


Check ASIK is UP
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_tmp}    set variable    ${output}[Runtime parameters]
    ${P_name_smod}    set variable    ${output_tmp}[Product name]
    run keyword if    '${P_name_smod}' == 'ASIK AirScale Common'    Check ASIK State
    run keyword if    '${P_name_smod}' == 'ASIB AirScale Common'    Check ASIB State
    run keyword if    '${P_name_smod}' == 'ASIL AirScale Common'    Check ASIL State
#    ${output_tmp1}    selenium_coam.get_abil_info
#    ${output1}    set variable    &{output_tmp1}[Status]
#    should be equal      &{output1}[Administrative state]    Unlocked
#    should be equal      &{output1}[Availability status]     Online
#    should be equal      &{output1}[Procedural status]     configured
    run keyword and ignore error    COAM_WebEM.Logout

Check ABIL is UP
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_tmp}    selenium_coam.get_abil_info
    ${output}    set variable    ${output_tmp}[Status]
    should be equal      ${output}[Administrative state]    Unlocked
    should be equal      ${output}[Operational status]     enabled
    should be equal      ${output}[Procedural status]     configured
    run keyword and ignore error    COAM_WebEM.Logout

Check ASIK State
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIK}    selenium_coam.get_asik_info
    ${output_1}    set variable    ${output_ASIK}[Status]
    should be equal      ${output_1}[Administrative state]    Unlocked
    should be equal      ${output_1}[Availability status]     Online
    should be equal      ${output_1}[Procedural status]     configured
    run keyword and ignore error    COAM_WebEM.Logout

Check ASIB State
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIB}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIB}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled
    run keyword and ignore error    COAM_WebEM.Logout

Check ASIL State
    run keyword and ignore error    COAM_WebEM.Logout
    run keyword and ignore error    COAM_WebEM.Login
    run keyword and ignore error    selenium_coam.continue_after_reload_modal_appear
    ${output_ASIL}    selenium_coam.get_hw_parameters    hw_type=SMOD    index=1
    ${output_2}    set variable    ${output_ASIL}[Runtime parameters]
    should be equal      ${output_2}[Procedural status]     configured
    should be equal      ${output_2}[Operational state]     enabled
    run keyword and ignore error    COAM_WebEM.Logout

Check gNB HW status ready
     [Arguments]
    FOR    ${i}    IN RANGE    5
        Set test variable    ${i}
        ${res_status}    run keyword and return status   recheck gNB status on WebEM
        Run Keyword If        ${res_status}    Exit For Loop
    #    Run Keyword unless    ${res_status}    Reboot gNB Via WebEM
        Continue For Loop If   '${res_status}'=='FALSE'
    END
    Log To Console    gNB HW is ready


recheck gNB status on WebEM
    wait until keyword succeeds    8 min    30s    Check gNB HW status on WebEM

gNB.Enable_DebugLog
    Log To Console  start to enable debug log ...
    gNB.Connect
    ${output}   ssh.execute   command=cp /ffs/fs2/config/toor4nsn/cp_runtime.ini /rom/cp_runtime.ini  connection=${ALIAS_ASIK}
    gNB.Disconnect
    Log To Console  enable debug log done

# Reboot AP Via SSH
#    wait until keyword succeeds    5 min    15s   SYSTEM Check If Host Is Pingable
#    sleep  10s
#    Log To Console    Reboot AP via ssh...
#    AP.connect
#    ssh.execute  command=reboot   connection=${ALIAS_AP}
#    AP.disconnect

#    sleep  5min
#    #OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP.password} ssh ${AP.username}@${AP.hostname} 'reboot'
#    Log To Console    Reboot AP finished...


Reboot APs Via SSH
    [Arguments]    ${airphonelist}
#    wait until keyword succeeds    5 min    15s   SYSTEM Check If Host Is Pingable
#    sleep  10s

    FOR    ${item}    IN    @{airphonelist}
        Log To Console    Reboot AP ${item} via ssh...
        AP.connect    hostname=${item}[0]    username=${item}[1]    password=${item}[2]    iphy=${item}[3]    alias=${ALIAS_AP}
        #ssh.execute  command=system-module-reboot   connection=${ALIAS_AP}
        ssh.execute   reboot   connection=${ALIAS_AP}
        AP.disconnect
    END

    Log To Console    sleep 10 minutes...
    #sleep  10min
    #OperatingSystem.Run And Return Rc And Output    sshpass -p ${AP.password} ssh ${AP.username}@${AP.hostname} 'reboot'
    Log To Console    Reboot AP finished...


Verify AP Cell Setup
    Log To Console    verify cell setup...
    Sleep    15s
    Wait Until Keyword Succeeds    180s    5s    Check UTE ASIK AP Cell Setup
    Log    cell_setup_is_ok

Check UTE ASIK AP Cell Setup
    Log To Console    check ute ASIK AP cell setup...
    SSH.Connect To    ${AP.hostname}    ${AP.username}    ${AP.password}
    ${result}    SSH.Execute    grep -i "Cell Setup Completed" /tmp/APL3.log
    Should Contain    ${result}    Cell Setup Completed    ignore_case=True
    Log To Console    ${result}
    [Teardown]    Run Keyword And Ignore Error    SSH.Disconnect

COAM.SetParameterValue
    [Arguments]    ${distname}    ${paraname}    ${value}    ${abbr}=${None}
    Wait Until Keyword Succeeds    3 times    30s
    ...    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${paraname}    new_value=${value}    abbr=${abbr}

COAM.ValidateAndActiveParameters
    [Arguments]    ${activate_plan_despite_errors}=True
    Log To Console    ${activate_plan_despite_errors}
    ${error}    selenium_coam.validate_plan
    log    ${error}
    selenium_coam.activate_plan    activate_plan_despite_errors=True


SYSTEM Check If Host Is Pingable
    [Arguments]    ${host_ip_address}=${AP_LMP_IP}
	${out_ping_result}=    Run   sudo ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 1 received    timeout=5
    [Return]    ${out_ping_result}

AP.connect
    [Documentation]   by default, AP-egate and ute TA service are deployed within the same server
                      ...   and 192.168.200.x Airphone is reachable by 192.168.200.1 (LMP IP)
                      ...   so we connect with AP directly by default.
                      ...   but with the multi-AP TLs, we have to ssh to the servers with egate is deployed first,
                      ...    and then ssh to airphone by LMP IP

    [Arguments]    ${hostname}=${UTE_IP}   ${username}=${UTE_USERNAME}    ${password}=${UTE_PASSWORD}    ${iphy}=""    ${alias}=${ALIAS_AP}
    ssh.connect to    hostname=${hostname}  username=${username}  password=${password}    alias=egate_UTE_sshconnection
    run keyword if    '${iphy}'!='NO'    run keywords
    ...   run    sshpass -p "${password}" scp -r ${CFGFILE_PATH}/${iphy} ${username}@${hostname}:/tmp/Iphy.xml
    ...   AND    ssh.execute
    ...   command=sshpass -p "oZPS0POrRieRtu" scp -r /tmp/Iphy.xml toor4nsn@192.168.200.1:/ffs/run/simmode/iphy.xml
    ...   connection=egate_UTE_sshconnection
    ssh.connect to    hostname=${AP_LMP_IP}  username=${AP_USERNAME}   password=${AP_PASSWORD}    alias=${alias}    proxy=egate_UTE_sshconnection

AP.disconnect
    [Arguments]    ${connection}=${ALIAS_AP}
    ssh.disconnect    connection=${connection}
    ssh.disconnect    connection=egate_UTE_sshconnection



Wireshark.StopCapturingALLlog
    ASIK.Connect   alias=${ALIAS_ASIK}
    ssh.send command   command=ps -ef|grep tcpdump|grep -v grep|grep fp0|awk '{print $2}'|xargs kill -2   connection=${ALIAS_ASIK}
    ${pid}  ssh.execute   command=lxc-attach -n 0xe004 -- ps -ef|grep tcpdump|grep -v grep|awk '{print $2}'  connection=${ALIAS_ASIK}
    ssh.execute   command=lxc-attach -n 0xe004 -- kill -2 ${pid.replace('\r\n','')}   connection=${ALIAS_ASIK}
    ASIK.Disconnect    alias=${ALIAS_ASIK}

Wireshark.Action.Close
    Conn.ConnectWithTimeout    alias=${ALIAS_UTE}
    ssh.execute     command=ps -ef|grep -i wireshark    connection=${ALIAS_UTE}
    ssh.send command    command=killall wireshark     connection=${ALIAS_UTE}
    Conn.Disconnect      ${ALIAS_UTE}
    sleep  2s

Process.GetDLBlerAndTP
    [Arguments]    ${DLThroughput}=${DL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${dTP}    Run Keyword And Continue On Failure  gNB.GetDLThroughput
    ...    ALIAS_ASP_1A=${ALIAS_ASP_1A}  duration=10    location=${16}
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${DLPercent}    Run Keyword And Continue On Failure    Evaluate    ${dTP}*${100}/${DLThroughput}
    Set Test Variable    ${DLPercent}
    Set Test Variable    ${dTP}
    Run Keyword And Continue On Failure    Should be true    ${DLPercent}>${Percentage}

Process.GetULBlerAndTP
    [Arguments]    ${ULThroughput}=${UL_TP}    ${Percentage}=10
    Conn.ConnectWithTimeout    ${ALIAS_ASIK}
    #Conn.ConnectToLoner    ${ALIAS_LONER}
    Conn.ConnectToAsp1a    ${ALIAS_ASP_1A}
    ${uTP}      Run Keyword And Continue On Failure   gNB.GetULThroughput   ${ALIAS_ASP_1A}    10
    Conn.Disconnect    ${ALIAS_ASP_1A}
    #Conn.Disconnect    ${ALIAS_LONER}
    Conn.Disconnect    ${ALIAS_ASIK}
    ${ULPercent}    Run Keyword And Continue On Failure    Evaluate    ${uTP}*${100}/${ULThroughput}
    Set Test Variable    ${ULPercent}
    Set Test Variable    ${uTP}
    #Set Test Variable    ${bler}
    Run Keyword And Continue On Failure     Should be true    ${ULPercent}>${Percentage}



ASIK.Connect
    [Arguments]   ${alias}
    Run Keyword And Continue On Failure  ssh.Connect to    hostname=${ASIK_IP}
     ...    username=${ASIK_USERNAME}    password=${ASIK_PASSWORD}  alias=${alias}

ASIK.Disconnect
     [Arguments]   ${alias}
    Run Keyword And Continue On Failure  Conn.Disconnect    ${alias}

Collect Snapshot
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    ${PATHONLY}   ${SNAPSHOTNAME}   Split String From Right    string=${snapshot_file}   separator=/     max_split=1
    log    ${snapshot_file}
    COAM_WebEM.Logout
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${TEST_LOG_DIRECTORY}/.
    Run Keyword And Ignore Error    run    command=rm ${snapshot_file}
    [Return]    ${TEST_LOG_DIRECTORY}/${SNAPSHOTNAME}

Collect SoSReport Log
    [Arguments]   ${WTS_INSTALL_PATH}=${WTS_DIR}
    [Documentation]    This keyword is used to capture the SoSReport log which has logs from AP, gNB and WTS
    ...                with AP and gNB snapshots. This is collected in the Suite Log Folder
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    Return From Keyword If    '${SOSREPORT_NEEDED}' == 'False'
    ${sosreport_output}    Run And Expect Command To Pass    command=cd ${WTS_INSTALL_PATH} && ./sosReport.sh -nr -c -s
    ...    msg=Script sosReport.sh
    ${sosreport_file_name}    Get SoSReport Log Filename    ${sosreport_output}
    Run And Expect Command To Pass    command=mv ${WTS_INSTALL_PATH}/${sosreport_file_name} ${TEST_LOG_DIRECTORY}/${sosreport_file_name}
    ...    msg=File copy
    File Should Exist    ${TEST_LOG_DIRECTORY}/${sosreport_file_name}

Run And Expect Command To Pass
    [Arguments]    ${command}    ${msg}=
    [Documentation]    This keyword is used to run a command and get its output.
    ...                Keyword will fail if the returncode is other than zero(0)
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${rc}    ${output}    Run and return rc and output    ${command}
    Should Be Equal As Integers   ${rc}    0    msg=${msg} failed execution with error code ${rc}
    [Return]    ${output}

Get SoSReport Log Filename
    [Arguments]    ${output}
    [Documentation]    This keyword is used to get the SoSReport log filename from the script output
    ...                 Modified Date: 02-Jun-2020
    ...                 Last Modified by: gopalakrishnan.n@nokia.com
    ${file_name}    Get Regexp Matches    ${output}    (SosReport.*complete_iphy1.tgz)   1
    ${file_name}    Get From List    ${file_name}    0
    [Return]    ${file_name}

gNB.Power.ResetAndCommission
    [Arguments]    ${scf_file}
    Power.Reset5GRU
    Power.ResetgNB
    Sleep    10min
    wait until keyword succeeds    15min    1min    gNB.VerifyOnAirViaOAMUntilReady
    gNB.Commission    scf_file=${scf_file}    timeout=${2400}

Connect to 5GC
    [Arguments]    ${hostname}=${5GC_IP}   ${username}=${5GC_USERNAME}    ${password}=${5GC_PASSWORD}    ${alias}=${ALIAS_5GC}
    ssh.connect to    hostname=${hostname}  username=${username}  password=${password}    alias=${alias}

Disconnect from 5GC
    [Arguments]    ${connection}=${ALIAS_5GC}
    ssh.disconnect    connection=${connection}


Get KPIs
    [Arguments]
    ${snapshot_file}   KW.Collect_Snapshot
    KW.Extract_API_Data_from_Snapshot  snapshot_file=${snapshot_file}
    ${file_path}   ${keys}  KW.Get_KPI_Source_File_and_Key_Column
    ...    file_to_check=${CASE_INPUT['KPI_Test']['file_to_check']}
    ...    sheet_to_check=${CASE_INPUT['KPI_Test']['sheet_to_check']}
    ...    key_column_name=${CASE_INPUT['KPI_Test']['key_column_name']}
    ${KPIs_data}   KW_Get_DATA_of_KPIs   KPIs=${CASE_INPUT['KPI_Test']['KPIs']}   target_file_path=${file_path}
    ...    sheet_to_check=${CASE_INPUT['KPI_Test']['sheet_to_check']}     key_raw_data=${keys}
#    KW.Generate_Final_Data_for_Report_Server    ${KPIs_data}    pre-process=${False}

KW.Collect_Snapshot
    [Arguments]
    COAM_WebEM.Login
    selenium_coam.snapshot_collection_settings    coverage=All log files     save_location=Local
    ${snapshot_file}    selenium_coam.collect_snapshot    snapshot_waiting_timeout=1200
    log    ${snapshot_file}
    COAM_WebEM.Logout
    [Return]   ${snapshot_file}

KW.Extract_API_Data_from_Snapshot
    [Arguments]  ${snapshot_file}   ${LTEPAT_path}=/home/ute/LTEPAT/   ${snapshot_transit_path}=/home/ute/Snapshot_log/
    ...    ${snapshot_output_path}=/home/ute/Snapshot_log_output/    ${template_file}=PmTemplateExample.xml
    Create Directory   ${snapshot_transit_path}
    Create Directory   ${snapshot_output_path}
    Empty Directory    ${snapshot_transit_path}
    Empty Directory    ${snapshot_output_path}
    Run Keyword And Ignore Error    run    command=cp ${snapshot_file} ${snapshot_transit_path}
    sleep  5s
    ${file_path}    ${file_name}    OperatingSystem.split path    ${snapshot_file}
    ${new_filepath}   evaluate    r"${SPACE * 9}\\/home\\/ute\\/Snapshot_log\\/${file_name}"
    run   command=cd ${LTEPAT_path};sed -i 's/^[[:space:]]*\\/home.*$/${new_filepath}/g' ${template_file}
    Run Keyword And Ignore Error    run    command=cd ${LTEPAT_path}; mono LTEPAT.exe ${template_file}
    sleep  30s

KW.Get_KPI_Source_File_and_Key_Column
    [Documentation]
    [Arguments]  ${file_to_check}=PMOutput.xlsx  ${sheet_to_check}=KPIs_All   ${key_column_name}=StartTime
    ...    ${snapshot_output_path}=/home/ute/Snapshot_log_output/
    @{output_file_names}   List Directory    ${snapshot_output_path}
    @{files}  Create list
    FOR  ${file}  IN   @{output_file_names}
        ${name}   Fetch From Right    ${file}    _
        append to list    ${files}    ${name}
    END
    ${target_file_index}   Get Index From List    ${files}   ${file_to_check}
    ${target_file_path}   set variable    ${snapshot_output_path}/${output_file_names[${target_file_index}]}

    ${key_raw_data}   excelreader.get_column_values_by_column_name
    ...    excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}  column_name=${key_column_name}
#    set test variable    ${target_file_path}
#    set test variable    ${key_raw_data}
    log    ${key_raw_data}
    [Return]   ${target_file_path}   ${key_raw_data}

KW.Get_Data_of_one_KPI
    [Documentation]
    [Arguments]  ${KPI_name}   ${filter_col_in}   ${values_accepted}   ${filter_col_out}  ${values_unexcepted}
    ...    ${target_file_path}    ${sheet_to_check}    ${key_raw_data}
    ...    ${KPI_target}

    ${row_indices_in}    excelreader.get_row_indices_by_values_in_a_column   excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}  column_name=${filter_col_in}   cell_values=${values_accepted}
    log   row_indices_in is ${row_indices_in}

    ${row_indices_out}    excelreader.get_row_indices_by_values_in_a_column  excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}  column_name=${filter_col_out}   cell_values=${values_unexcepted}
    log   row_indices_out is ${row_indices_out}

    remove values from list    ${row_indices_in}   @{row_indices_out}

    ${KPI_raw_data}   excelreader.get_column_values_by_column_name  excel_file=${target_file_path}
    ...    sheet_name=${sheet_to_check}   column_name=${KPI_name}
    log    ${KPI_raw_data}

    ${final_KPI_data}    Create list
    ${sum}   set variable    ${0}
    ${cnt}   set variable    ${0}
    FOR  ${index}  IN   @{row_indices_in}
        ${sum}=    run keyword if  '${KPI_raw_data[${index}]}'!='None'   evaluate   ${sum}+${KPI_raw_data[${index}]}
        ...    ELSE   set variable    ${sum}
        ${cnt}=    run keyword if  '${KPI_raw_data[${index}]}'!='None'   evaluate   ${cnt}+${1}
        ...    ELSE   set variable    ${cnt}
        ${time_str}   convert to string    ${key_raw_data[${index}]}
        ${time}   ${remainder}  split string from right   ${time_str}   :    1
        ${KPI_value}    convert to string    ${KPI_raw_data[${index}]}
        log  ${time}
#        ${KPI_dict}    create dictionary   id=${id}    ${time}=${KPI_value}
        ${KPI_dict}    run keyword if   '${time}'>='${START_TIME}'    create dictionary   ${time}=${KPI_value}
        ...    ELSE    continue for loop
        append to list    ${final_KPI_data}    ${KPI_dict}
#        ${id}    evaluate    ${id}+${1}
    END
    ${average_kpi}=   run keyword if    ${cnt}!=${0}     evaluate    ${sum}/${cnt}
    ...    ELSE   set variable    ${0}
    log    ${final_KPI_data}
    ${ismet}    run keyword and return status     should be true    ${average_kpi}>=${KPI_target}
    ${ismet}     set variable if     ${cnt}==${0}     NA     ${ismet}
    [Return]  ${final_KPI_data}   ${average_kpi}   ${ismet}

KW_Get_DATA_of_KPIs
    [Documentation]   NR_5151b  NR_5013A  NR_5167b  NR_5143b
    [Arguments]  ${KPIs}    ${target_file_path}   ${sheet_to_check}     ${key_raw_data}
    log   ${KPIs}
    ${KPIs_data}    create dictionary
    ${KPIs_data_shadow}   create dictionary
    FOR   ${KPI}  IN   @{KPIs}
        ${KPI_data}   ${actual_average}   ${ismet}   KW.Get_Data_of_one_KPI  KPI_name=${KPI['name']}
        ...    filter_col_in=${KPI['conditions_accepted']['filter_column']}
        ...    values_accepted=${KPI['conditions_accepted']['values']}    filter_col_out=${KPI['conditions_unaccepted']['filter_column']}
        ...    values_unexcepted=${KPI['conditions_unaccepted']['values']}   target_file_path=${target_file_path}
        ...    sheet_to_check=${sheet_to_check}    key_raw_data=${key_raw_data}
        ...    KPI_target=${KPI['target']}
        ${KPI_info}     create dictionary
        set to dictionary    ${KPI_info}   Data=${KPI_data}   KPI_Name=${KPI['name']}   KPI_Result=${actual_average}  KPI_Is_Met=${ismet}
        ...    KPI_Target=${KPI['target']}
        ${KPI_data_json}    json.dumps    ${KPI_data}
        set to dictionary    ${KPIs_data_shadow}    ${KPI['id']}=${KPI_info}   Start_Time=${START_TIME}    End_Time=${END_TIME}
        set to dictionary    ${KPIs_data}    ${KPI['name']}=${KPI_data_json}    Start_Time=${START_TIME}    End_Time=${END_TIME}
    END
    # The following statements are only used for test-used python ploting
    set test variable    ${KPIs_data_shadow}
    ${KPI_data_to_pass_shadow}   create dictionary     Testline=${testline_name}
    ...    Gnb_Version=${gnb_version}    Case_Name=${TEST NAME}
    ...    KPI_IDs=${CASE_INPUT['KPI_Test']['KPI_IDs']}  &{KPIs_data_shadow}
    set test variable    ${KPI_data_to_pass_shadow}
#    run keyword and ignore error   text.write_dicts_to_json_file   file_path=${TEST_LOG_DIRECTORY}
#    ...    file_name=KPI_data_shadow.json   data=${KPI_data_to_pass_shadow}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=timestamp
    ${timestamp}    robot.libraries.DateTime.convert date    ${timestamp}    epoch
    ${timestamp}    evaluate    int(round(${timestamp} * 1000))
    run keyword and ignore error   text.write_dicts_to_json_file   file_path=${KPI_history}
    ...    file_name=${TEST NAME}_KPI_data_${timestamp}.json   data=${KPI_data_to_pass_shadow}
    [Return]  ${KPIs_data}

Generate kpi report
    [Arguments]     ${report_name}      ${mode}=0
    #${collect_log_start_time1}    get current time
    #sleep   240min
    Log To Console    genarate KPI report...
    #${collect_log_start_time1}    get current time
    #${collect_log_start_time1}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    Collect gnb logs    dcapduration=${dcapduration}
    run keyword and ignore error     Generate kpi report in Scout   report_name_1=${report_name}
       ...   mode=${mode}

Generate kpi report in Scout
    [Documentation]   Param: ${scout_testline_name} is "TL73_gNB" or "TL813_gNB", scout_testline_name in scout, type: str
    ...               Param: ${template_id}---https://scout.nsn-rdnet.net/kpis-templates/382/, 382 is ${template_id}
    ...               Param: ${api_key}---scout for easy access from robot framework to Scout API
    [Arguments]      ${alias}=scout   ${report_name_1}=Airphone_   ${mode}=0

    log to console   ${report_name_1}
    ${gnb_version}       KW.Get_gNB_Active_SW_Version

    #${report_dureation_in_minutes}    Evaluate    ${report_duration} // 60 - 10
    # end time could be now, because SCOUT will not report the KPI data of
    # the last ""current time of day" % "15"" minutes
    ${end_timestamp}    robot.libraries.DateTime.Get Current Date
                        ...    result_format=%Y-%m-%dT%H:%M:%S
                        ...    time_zone=UTC

    # in best case, first 15mins(in fact 1-15 minutes, depends on the start timeline) KPI data should be
    # dropped
    #${start_timestamp}    DateTime.Add Time To Date  ${TESTING_START_TIME}  00:15:00
    #                    ...   result_format=%Y-%m-%dT%H:%M:%S

    ${interval_minutes}    evaluate    ${JID_DURATION}/60
    ${start_timestamp}    DateTime.Add Time To Date  ${end_timestamp}  -${interval_minutes} minutes
                        ...   result_format=%Y-%m-%dT%H:%M:%S


    log to console   KPI_report_start_time: ${start_timestamp}
    log to console   KPI_report_end_time: ${end_timestamp}


    ${start_iso_time}=    Catenate    SEPARATOR=    ${start_timestamp}    +00:00
    ${end_iso_time}=    Catenate    SEPARATOR=    ${end_timestamp}    +00:00

    log to console   KPI_report_start_time ISO time: ${start_iso_time}
    log to console   KPI_report_end_time ISO time: ${end_iso_time}

    #Collect gnb logs
    log to console    sleeping 18 mins
    sleep    18min

    ${report_time}  DateTime.Get Current Date  result_format=%Y-%m-%d %H:%M:%S
    ${report_date}    Get Substring    ${report_time}    0    10
    log to console    ${mode}
#    Run Keyword If    ${mode} == 0
#    ...   Set Test Variable    ${testmode}    RTM
#    ...   ELSE
#    ...   Set Test Variable    ${testmode}    FixMode
    ${kpi_report_name}   Catenate    SEPARATOR=_   ${JID_REPORTPREFIX}   ${report_date}   ${testline_name}   ${gnb_version}   ${JID_REPORTTAG}

    log to console    start to generate KPI report by SCOUT:${kpi_report_name}

    log to console    start to setup scout
    scout.setup_scout    scout_testline_name=${scout_testline_name}    api_key=${api_key}    alias=${alias}    timeout=1800

    log to console    start to generate scout kpi report
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}
    ...                                       template_id=${JID_TEMPLETEID}
    ...                                       start_time=${start_iso_time}
    ...                                       end_time=${end_iso_time}
    ...                                       alias=${alias}

    # log to console    ${report}
    set suite variable    ${id}    ${report[0]["id"]}
    ${name}   Run Keyword And Ignore error    set suite variable    ${name}        ${report}[name]
    ${cmd1}   set variable    curl -X 'GET' 'https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/${id}/export_to_excel/
    ${cmd2}   set variable    ?apitoken=${api_key}' -H 'accept: application/vnd.api+json'

    log to console    checking reports in scout until succeeds... by every 3 minutes.
    ${url}    ${filename}    wait until keyword succeeds     30min    3min    GenreateReport    cmd=${cmd1}${cmd2}
    ${toolcenter}   set variable    toolscenter.eecloud.dynamic.nsn-net.net

    log to console    update kpi report ${url} ${filename} to toolcenter ${toolcenter}
    run    curl -X 'GET' 'http://${toolcenter}/api/rtm/addReport/?url=${url.strip()}&filename=${filename}' -H 'accept: */*'
    IF   '${ifGenerate2ndReport}'=='True'
    ...        run keyword 	KW.Generate2ndReport
    ...        kpi_report_name=${kpi_report_name}      start_iso_time=${start_iso_time}
    ...        end_iso_time=${end_iso_time}     alias=${alias}
    ...        Second_template_id=${Second_template_id}     Second_report_tag=${Second_report_tag}
    [Teardown]    Run Keyword And Ignore Error    scout.teardown_scout_api    alias=${alias}

GenreateReport
    [Arguments]   ${cmd}
    ${ret}    Run    ${cmd}

    log to console    checking and KPI report is: ${ret}

    should be true     ${ret.count('already exist as excel file')}>0    KPI report is not ready yet.

    #should contain    ${ret}    already exist as excel file
    ${ret}     ${dumy}    Split String From Right	 string=${ret}   separator=}     max_split=1
    ${dumy}     ${ret}    Split String 	 string=${ret}   separator={     max_split=1
    ${ret}    set variable    {${ret}}
    ${res}    Evaluate        json.loads('''${ret}''')                   json
    ${pre}    ${filename}    Split String	 string=${res["errors"][0]["detail"]}   separator=:     max_split=1
    ${url}    ${filename}    Split String From Right	 string=${filename}   separator=/     max_split=1
    [Return]   ${url}    ${filename}


KW.Get_gNB_Active_SW_Version
    [Arguments]   ${connection}=COAM
    wait until keyword succeeds   10x   1min    COAM_Admin.Login    alias=${connection}
    ${sw_info}   coam.get_software_info   connection=${connection}   timeout=10
    ${active_sw_version}   Run Keyword If   "${sw_info['Active SW version']}"!="${None}" and "${sw_info['Active SW version']}"!=""
    ...   COAM_Admin.TransferSWVersion   ${sw_info['Active SW version']}
    log to console       get gNB SW version completed
    COAM_Admin.Logout
    [Return]   ${active_sw_version}

Collect gnb logs
    [Arguments]   ${operation}=best    ${duration}=90   ${dcapduration}=1
    log to console    start log collection...
    #robssh.Open Connection    host=127.0.0.1    port=22    timeout=60
    #robssh.Login    username=${UTE_USERNAME}    password=${UTE_PASSWORD}   delay=1s
    #robssh.Write   cd /home/ute/gnb_logs && sudo ./gnb_logs ${ASIK_LMP_IP} -${operation} ${duration}
    #log to console    sleeping 10 mins
    #sleep   10min
    #Run keyword and ignore error    Collect Snapshot

    log to console   ${operation}
    log to console   ${duration}
    run keyword and continue on failure    DCAP.Start_Collect_Trace   host=${dcap_ip}   port=${dcap_port}
    ...      GNBtraces=${GNBtraces}  BTStraces=${BTStraces}
    sleep   ${dcapduration}min
    log to console   sleep ${dcapduration} mins
    run keyword and continue on failure      DCAP.Stop_Collect_Trace_and_Get_Result

Generate kpi report until success
    [Arguments]   ${mode}=0
    Timer.Start
    #12hours:15min*48;
    FOR  ${i}   IN RANGE    ${48}
#        CheckTLAlwaysOnAir
        log to console   checking l3call counter ${i}

        CheckL3callCounter        mode=${mode}
        ${duration}    Timer.Stop
        # 9000s = 60s/min * 60min/hour * 2.5hous = 2.5hours
        run keyword if   ${duration}>${JID_DURATION}   run keywords    Generate kpi report
        ...    report_name=VRF4_SG1_Degraded_KPIs
        ...    mode=${mode}    AND   Exit For Loop
    END

CheckTLAlwaysOnAir
    #check onair, if not reinit,if timeup,generate report
    Sleep   15min
    ${res}   run keyword and ignore error   gNB.VerifyOnAirViaOAMUntilReady
    Run keyword if    '${res[0]}'!='PASS'   run keywords   Setup Case for ap  wts_cfg=${WTS_CFG1}   AND   Timer.Start

CheckL3callCounter
    [Arguments]   ${mode}=0

    log to console    sleep 15 mins...
    Sleep   15min

    #Basic.CheckVariableValid    var=LongTimeTestWithoutCheckCounter   default_value=False
    #return from keyword if    '${LongTimeTestWithoutCheckCounter}'=='True'

    Run Keyword If    ${mode} == 0
    ...   Set Test Variable    ${counter}    M55127C00001
    ...   ELSE
    ...   Set Test Variable    ${counter}    M55140C00001
    Run Keyword If    ${mode} == 0
    ...   Set Test Variable    ${basecounter}    300
    ...   ELSE
    ...   Set Test Variable    ${basecounter}    15
    Wait until keyword succeeds    15min    60s    COAM_WebEM.Login
    ${res}  selenium_coam.get_bts_counters_info   counter_id=${counter}
    ${values}    get dictionary values   ${res}

    ${status}   run keyword and return status   Should Be True   ${values[-1]}>=${basecounter}

    log to console   ${counter} is ${values[-1]}, status is ${status}

    run keyword and ignore error    COAM_WebEM.Logout
    Run keyword if    '${status}'!='True'   run keywords   Setup Case for ap  wts_cfg=${WTS_CFG1}      mode=${mode}
    ...    AND   Timer.Start

KW.Generate2ndReport
    [Arguments]        ${kpi_report_name}      ${start_iso_time}       ${end_iso_time}     ${alias}
    ...         ${Second_template_id}=3043     ${Second_report_tag}=Additional_Counter
    log to console    start to generate 2nd KPI report by SCOUT:${kpi_report_name}_${Second_report_tag}

    log to console    start to generate 2nd scout kpi report
    ${report}    scout.generate kpi report    report_name=${kpi_report_name}_${Second_report_tag}
    ...                                       template_id=${Second_template_id}
    ...                                       start_time=${start_iso_time}
    ...                                       end_time=${end_iso_time}
    ...                                       alias=${alias}

    # log to console    ${report}
    set suite variable    ${id}    ${report[0]["id"]}
    ${name}   Run Keyword And Ignore error    set suite variable    ${name}        ${report}[name]
    ${cmd1}   set variable    curl -X 'GET' 'https://scout.nsn-rdnet.net/future/api/v1/kpis_reports/${id}/export_to_excel/
    ${cmd2}   set variable    ?apitoken=${api_key}' -H 'accept: application/vnd.api+json'

    log to console    checking reports in scout until succeeds... by every 3 minutes.
    ${url}    ${filename}    wait until keyword succeeds     30min    3min    GenreateReport    cmd=${cmd1}${cmd2}
    ${toolcenter}   set variable    toolscenter.eecloud.dynamic.nsn-net.net

    log to console    update kpi report ${url} ${filename} to toolcenter ${toolcenter}
    run    curl -X 'GET' 'http://${toolcenter}/api/rtm/addReport/?url=${url.strip()}&filename=${filename}' -H 'accept: */*'