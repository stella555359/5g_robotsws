*** Settings ***
Documentation

Library           String
Library           OperatingSystem
Library           ../Resources/py_tool/vdu_cli.py
Library           ../Resources/py_tool/time_convert.py
Resource          ../Resources/vdu_cloud_deployment.robot
Resource          ../Resources/cu_cloud_deployment.robot
Resource          ../Resources/common_pre_post_condition.robot
Resource          ../Resources/cu_oam_fm.robot
Resource          ../Resources/vdu_oam_fm.robot
Library           taf.ul.vdu.helm                       WITH NAME    helm


*** Variables ***
${AICLOG}         1
${AIC_SELF_CHECK}   1
${RECOVER}         0

*** Keywords ***
############################## Common Setup Start ##############################
====== Common Setup KW Start ======
     log to console  \n*** only used for readable ***

AiC Common Suite Setup
    [Documentation]  cDo some common things for every precondition of cases
    ...              any case should include it in suite setup or test setup
    ...              it will do following actions
    ...              1) kill unexpected process
    ...              3) _Check Installed Packages
    ...   *Author*: xianbiao.cheng@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-15 | xianbiao.cheng | first version for framework |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | AiC Common Suite Setup |
    #_Kill Unexpected Process
    _Check Installed Packages
    Run Keyword And Ignore Error    _Init TRS Global Variable


AiC Common Test Setup
    [Teardown]  run keyword and ignore error  disconnect all ssh connections
    [Documentation]  Do some common things for every precondition of cases
    ...              any case should include it in suite setup or test setup
    ...              it will do following actions
    ...              1) kill unexpected process
    ...              2) import static test line variables and convert to readable variables
    ...              3) automatically get some deployment information from test line
    ...              4) add one folder for test cases -- logs, cm files, download files...
    ...              5) backup SCF from test line for traceablity
    ...   *Author*: xianbiao.cheng@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2019-11-15 | xianbiao.cheng | initial creation |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   | 2023-1-16 | r3li | add get active alarm on cu and du |
    ...   | 2023-4-27 | chris.l.cao | add get_all_netact_server, remove 'Is UP Pod Split' |
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...
    ...   *Return*
    ...   None
    ...
    ...   *Example*
    ...   | AiC Common Test Setup |
    ...
    Set Test Variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}    0

    Run Keyword And Ignore Error    _Init Nom Server Global Variable

    _Create Logs Folder For Test Case

    Run Keyword And Ignore Error   Clear Agent Flag
    Run Keyword And Ignore Error   _Delete Temporary Files
    Run Keyword And Ignore Error   Coredump Pre-condition

    run keyword if   ${AIC_SELF_CHECK}==1  _Self Check Script And Configuration
    _Kill Unexpected Process
#    ${status}   ${up_pod_split_flag}   run keyword and ignore error   Is UP Pod Split
    set_vdu_pod_container_suite_variables   # up_pod_split_flag=${up_pod_split_flag}
    Run Keyword And Ignore Error   get_all_netact_server

    ${vcu_nf_type}   Get VCU NF Type
    run keyword if  "${vcu_nf_type}"=="CNF"   Run Keyword And Ignore Error   _VCU CNF Environment WA

    set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}    1

    Run Keyword And Ignore Error    online enable actcli for cu
    Run Keyword And Ignore Error    Online Enable actCli For vDU
    Run Keyword And Ignore Error    Get Running Build Number    with_prefix=${True}   print_or_not=${True}
    Run Keyword And Ignore Error    Get Current CU Version   with_prefix=${True}   print_or_not=${True}

    ${CU_Alarms_Setup}   ${DU_Alarms_Setup}    _Get All Active Alarm
    Set Test Variable    ${CU_Alarms_Setup}
    Set Test Variable    ${DU_Alarms_Setup}


_Get All Active Alarm
    ${gnb_numbers}    Get Gnb Numbers
    ${CU_alarms}   Create List
    ${DU_alarms}   Create List
    FOR  ${i}  IN RANGE  ${gnb_numbers}
        ${r}   ${alarms}   Run Keyword And Ignore Error   CU Get Active Alarms   gnb_index=${i}
        ${alarms}   Run Keyword If   '${r}'=='PASS'   convert_list    ${alarms}   ELSE   convert_list    ${None}
        Append to List   ${CU_alarms}    ${alarms}
        ${du_alarm}   _Get Vdu Active Alarm   gnb_index=${i}
        Append to List   ${DU_alarms}    ${du_alarm}
    END

    [Return]   ${CU_alarms}   ${DU_alarms}


_Get Vdu Active Alarm
    [Arguments]   ${gnb_index}=0
    ${du_number}   Get DU Numbers   ${gnb_index}
    ${du_alarms}   Create List
    FOR  ${i}  IN RANGE  ${du_number}
       ${r}   ${alarms}   Run Keyword And Ignore Error   vDU Get Active Alarms   gnb_index=${gnb_index}   vdu_index=${i}
       ${alarms}   Run Keyword If   '${r}'=='PASS'   convert_list    ${alarms}   ELSE   convert_list    ${None}
       Append to List   ${du_alarms}    ${alarms}
    END
    [Return]   ${du_alarms}


AiC Common Suite Teardown
    [Documentation]   AiC Common Suite Teardown
    ...    Do some common things for every postcondition of suite
    ...    any suite should include it in suite teardown
    ...    it will do following actions
    ...    1) disable log collection
    ...    2) release resource
    ...
    ...   *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.1.2023,chris.l.cao@nokia-sbell.com, log 'AiC SUITE_STATUS:${SUITE_STATUS}'
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    log to console  *** AiC Common Suite Teardown, tbd ***
    Log To Console   AiC SUITE_STATUS:${SUITE_STATUS}


AiC Common Test Teardown
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0   ${custom_white_fault_id_list}=${None}  ${recover_env}=${True}
    ...   ${custom_white_alarm_id_list}=${None}   ${cu_coredump_check}=${True}   ${vdu_coredump_check}=${True}
    [Teardown]   Run Universal Teardown Procedure
    [Documentation]    Do some common things for every postcondition of case
    ...    any case should include it in suite teardown or test teardown
    ...    it will do following actions
    ...    1) save snapshot
    ...    2) backup SCF for post
    ...    3) disable log collection
    ...    4) release resource
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...
    ...    history change: <date>,<who>,<what and how>
    ...    14.2.2023,chris.l.cao@nokia-sbell.com, add 'Return From Keyword If   ${AICLOG}==0' to improve debug effciency

    ...
    log to console  *** AiC Common Test Teardown, tbd ***
    Return From Keyword If   ${AICLOG}==0

    interface.Common step trigger
    Check Core Dump Files And Download it And Fail The Case If It Has...   cu_coredump_check=${cu_coredump_check}
    ...                                                                    vdu_coredump_check=${vdu_coredump_check}

    ${res}  ${is_truck_roll_needed}    Run Keyword And Ignore Error   Truck Roll Needed
    run keyword if   "${is_truck_roll_needed}"=="${True}"    run keywords    Fail  Truck Roll Needed   AND
    ...    Set test variable   ${TEST_STATUS}    FAIL  AND
    ...    log to console   Truck Roll Triggerd, testline will suspend for 72 hours!!!

    ${custom_white_fault_id_list}   convert_list   ${custom_white_fault_id_list}
    ${white_fault_id_list}   Combine Lists   ${custom_white_fault_id_list}   ${COMMON_WHITE_FAULT_ID_LIST}
    ${custom_white_alarm_id_list}   convert_list   ${custom_white_alarm_id_list}
    ${white_alarm_id_list}   Combine Lists   ${custom_white_alarm_id_list}   ${COMMON_WHITE_ALARM_ID_LIST}
    ${CU_Alarms_Teardown}   ${DU_Alarms_Teardown}    _Get All Active Alarm
    ${cu_compare_result}    compare_cu_teardown_alarm_info_with_setup   ${CU_Alarms_Teardown}   ${CU_Alarms_Setup}
    ...   ${white_fault_id_list}   ${white_alarm_id_list}
    ${vdu_compare_result}   compare_vdu_teardown_alarm_info_with_setup   ${DU_Alarms_Teardown}   ${DU_Alarms_Setup}
    ...   ${white_fault_id_list}   ${white_alarm_id_list}
    Run Keyword And Continue On Failure   run keyword if    ${cu_compare_result.__len__()}>${0}
    ...    run keywords    FAIL  vCU new alarms   AND
    ...    Set test variable   ${TEST_STATUS}    FAIL
    Run Keyword And Continue On Failure   run keyword if    ${vdu_compare_result.__len__()}>${0}
    ...    run keywords    FAIL  vDU new alarms  AND
    ...    Set test variable   ${TEST_STATUS}    FAIL

    ${exist}    Run Keyword And Return Status    Variable Should Exist     ${POST_RU_POWER}
    run keyword if   "${exist}"=="${False}"   set test variable   ${POST_RU_POWER}    ${True}
    ${exist}    Run Keyword And Return Status    Variable Should Exist     ${POST_CELL_STATUS}
    run keyword if   "${exist}"=="${False}"   set test variable   ${POST_CELL_STATUS}    ${True}
    ${AIC_TEST_STATUS}   evaluate    ${POST_CELL_STATUS} & ${POST_RU_POWER}
    Run Keyword And Continue On Failure   run keyword if  '${AIC_TEST_STATUS}'=='${False}'
    ...    Set test variable   ${TEST_STATUS}    FAIL

    ${capture_log}   Get Capture Log Flag
    Run Keyword And Ignore Error
    ...  Collect All Logs In Teardown Optimized   capture_log=${capture_log}  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ...  recover_env=${recover_env}
    run keyword and ignore error
    ...  VDU Take OCP Log For Login Authorization Failed
    run keyword and ignore error
    ...  VCU Take OCP Log For Login Authorization Failed

    run keyword if    '${res}'=='PASS'   _Truck Roll Check And Action   ${is_truck_roll_needed}


AiC Common Test Teardown Ignore Special Alarm
    [Documentation]  it will check Alarm in 'AiC Common Test Teardown'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.2.2023,chris.l.cao@nokia-sbell.com, intialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    Add default alarm:
    ...    | Add White Alarm Id    |
    ...    | AiC Common Test Teardown Ignore Special Alarm |
    ...
    ...    Add default and other alarm id
    ...    | Add White Alarm Id    | 123 |  456 | 799 |
    ...    | Delete White Alarm Id | 70501 | 70502 |
    ...    | AiC Common Test Teardown Ignore Special Alarm |
    ...
    AiC Common Test Teardown   custom_white_alarm_id_list=${CUSTOM_WHITE_ALARM_ID_LIST}


Add White Alarm Id
    [Arguments]  @{alarm_id}
    [Documentation]  Add White Alarm Id
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.2.2023,chris.l.cao@nokia-sbell.com, intialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | please see example |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Add White Alarm Id    |
    ...    | AiC Common Test Teardown Ignore Special Alarm |
    ...
    ...    Add default and other alarm id
    ...    | Add White Alarm Id    | 123 |  456 | 799 |
    ...    | Delete White Alarm Id | 70501 | 70502 |
    ...    | AiC Common Test Teardown Ignore Special Alarm |
    ...
    ${CUSTOM_WHITE_ALARM_ID_LIST}    Create List  ${70501}
    Set Test Variable   ${CUSTOM_WHITE_ALARM_ID_LIST}

    Return From Keyword If  ${alarm_id.__len__()==0}

    FOR   ${id}  IN  @{alarm_id}
        ${tmp_id}    Convert To Integer  ${id}
        Run Keyword If    ${tmp_id} not in ${CUSTOM_WHITE_ALARM_ID_LIST}
        ...  Append To List  ${CUSTOM_WHITE_ALARM_ID_LIST}    ${tmp_id}
    END
    Set Test Variable   ${CUSTOM_WHITE_ALARM_ID_LIST}


Delete White Alarm Id
    [Arguments]  @{alarm_id}
    [Documentation]  Delete White Alarm Id
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    18.2.2023,chris.l.cao@nokia-sbell.com, intialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | please see example |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    Add default alarm:
    ...    | Add White Alarm Id    |
    ...    | AiC Common Test Teardown Ignore Special Alarm |
    ...
    ...    Add default and other alarm id
    ...    | Add White Alarm Id    | 123 |  456 | 799 |
    ...    | Delete White Alarm Id | 70501 | 70502 |
    ...    | AiC Common Test Teardown Ignore Special Alarm |
    ...
    Return From Keyword If  ${alarm_id.__len__()==0}

    FOR   ${id}  IN  @{alarm_id}
        ${tmp_id}    Convert To Integer  ${id}
        Run Keyword If    ${tmp_id} in ${CUSTOM_WHITE_ALARM_ID_LIST}
        ...  Remove Values From List  ${CUSTOM_WHITE_ALARM_ID_LIST}    ${tmp_id}
    END

    Set Test Variable   ${CUSTOM_WHITE_ALARM_ID_LIST}


Collect All Logs In Teardown Optimized
    [Arguments]  ${capture_log}=0  ${vdu_index}=0  ${gnb_index}=0   ${recover_env}=${True}
    ${full_testline_config_folder}   Get TestLine Config Folder Name
    ${robot_file}   Set Variable   ${CURDIR}/utility_robot/ta_utility.robot

    ${tmp_log_root_folder}   Set Variable  /tmp/tmp_logs
    OperatingSystem.Remove Directory    ${tmp_log_root_folder}   recursive=True
    OperatingSystem.Create Directory    ${tmp_log_root_folder}

    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt
    ${active_alarm_file}   get a file   vdu_alarm_teardown   active_alarm.txt
    ${historical_alarm_file}   get a file   vdu_alarm_teardown   historical_alarm.txt
    ${cu_active_alarm_file}   get a file   vcu_alarm_teardown   active_alarm.txt
    ${cu_historical_alarm_file}   get a file   vcu_alarm_teardown   historical_alarm.txt

    log to console   Test Result in 'Collect All Logs In Teardown Optimized':${TEST_STATUS}

    ${ta_utility_case_name}   Set Variable If  ${AICLOG}==0   return_immediately
        ...   ${AICLOG}==2  logs
        ...   ${AICLOG}==3 and "${TEST_STATUS}"=="FAIL"   logs
        ...   ${AICLOG}==3 and "${TEST_STATUS}"=="PASS"   return_immediately
        ...   ${capture_log}==1 and "${TEST_STATUS}"=="FAIL"   logs
        ...   ${capture_log}==1 and "${TEST_STATUS}"=="PASS"   set_agent_flag
        ...   ${capture_log}==0 return_immediately

    Return From Keyword If  "${ta_utility_case_name}"=="return_immediately"

    ${cmd}   Set Variable   robot -t ${ta_utility_case_name}
    ${cmd}   Set Variable   ${cmd} -v gnb_index:${gnb_index} -v gnb_index:${gnb_index} -v agent_flag_file:${agent_flag_file}
    ${cmd}   Set Variable   ${cmd} -v recover_env:${recover_env}
    ${cmd}   Set Variable   ${cmd} -v active_alarm_file:${active_alarm_file} -v historical_alarm_file:${historical_alarm_file}
    ${cmd}   Set Variable   ${cmd} -v cu_active_alarm_file:${cu_active_alarm_file} -v cu_historical_alarm_file:${cu_historical_alarm_file}
    ${cmd}   Set Variable   ${cmd} -v "COLLECT_START_TIME:${START_TIME}" -v cu_historical_alarm_file:${cu_historical_alarm_file}
    ${cmd}   Set Variable   ${cmd} -V ${full_testline_config_folder} -b debug.log
    ${cmd}   Set Variable   ${cmd} -L TRACE -d ${tmp_log_root_folder} ${robot_file}
    #Log To Console   ${cmd}

    ${console}  Get A File   logs_console.txt
    ${formal_log_file}   Get A File   logs  logs.tar
    ${output}  OperatingSystem.Run      ${cmd} 1>${console} 2>&1 ;tar -cf ${formal_log_file} ${tmp_log_root_folder}
    ${output}  OperatingSystem.Run      cat ${console}|grep "OAM Precondition Cell Should Be Onair"
    Log To Console   ${output}
    ${output}  OperatingSystem.Run      cat ${console}|grep -A 40 "RU Power result_"|grep "ta_utility: Case Test Teardown" -B 100
    Log To Console   ${output}
    ${output}  OperatingSystem.Run      cat ${console}|grep "Should Have Power On All RUs"
    Log To Console   ${output}
    ${output}  OperatingSystem.Run      cat ${agent_flag_file}


Run Universal Teardown Procedure
    [Documentation]   Run Universal Teardown Procedure
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   3.3.2023,chris.l.cao@nokia-sbell.com, remove 'NOM Rest Logout' to save dryrun time
    ...   2.7.2023,chris.l.cao@nokia-sbell.com, add 'Rest Logout For All Gnbs'
    ...
    Run Keyword And Ignore Error  Recover Environment
    Run Keyword And Ignore Error  Disconnect All SSH Connections
#    Run Keyword And Ignore Error  Vdu Rest Logout
#    Run Keyword And Ignore Error  CU Rest Logout
    Run Keyword And Ignore Error   Rest Logout For All Gnbs


Rest Logout For All Gnbs
    [Documentation]   Run Universal Teardown Procedure
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change:
    ...   2.7.2023,chris.l.cao@nokia-sbell.com,initialization
    ...
    ${gnb_numbers}    Get Gnb Numbers
    FOR  ${gnb_index}  IN RANGE  ${gnb_numbers}
        Run Keyword And Ignore Error   CU Rest Logout   gnb_index=${gnb_index}
        Run Keyword And Ignore Error   Rest Logout For All Vdus   gnb_index=${gnb_index}
    END


Rest Logout For All Vdus
    [Arguments]  ${gnb_index}=0
    ${vdu_numbers}   Get DU Numbers   gnb_index=${gnb_index}
    FOR  ${vdu_index}  IN RANGE  ${vdu_numbers}
        VDU Rest Logout   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    END


_Init Nom Server Global Variable
    [Documentation]  _Init Nom Server Global Variable
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   None
    ...	  | gnb_index | No | gnb_index, default is 0 |
    ...   *Return*
    ...   None
    ...   *Example*
    ...   | _Init Nom Server Global Variable |
    ############## start of NOM4 ##################
    ${nom}   _Get NOM Server Information By Label    label=NOM4
    # ----------  NOM webui link info -----------------
    Set Test Variable   ${NOM_1_WEBUI_LINK}        ${nom["webui_link"]}

    ############## start of NOM10 ##################
    ${nom}   _Get NOM Server Information By Label    label=NOM10
    Set Test Variable   ${NOM_10_SSH_IP}           ${nom["ssh_ip"]}
    Set Test Variable   ${NOM_10_SSH_USERNAME}     ${nom["ssh_user"]}
    # ----------  NOM webui link info -----------------
    Set Test Variable   ${NOM_10_INTEGRATE_LINK}   ${nom["integrate_link"]}
    Set Test Variable   ${USER_NAME_NOM10}       ${nom["webui_link_username"]}
    Set Test Variable   ${PASSWORD_NOM10}        ${nom["webui_link_password"]}

    Set Test Variable   ${NOM_10_SSH_IP_MASK_LEN}   ${nom["ssh_ip_mask_len"]}
    Set Test Variable   ${NOM_10_WEBUI_LINK}        ${nom["webui_link"]}


    Set Test Variable   ${NOM_10_PM_SFTP_SERVER}      ${nom["pm_sftp_ip"]}
    Set Test Variable   ${NOM_10_PM_SFTP_USERNAME}    ${nom["pm_sftp_username"]}
    Set Test Variable   ${NOM_10_PM_SFTP_PASSWORD}    ${nom["pm_sftp_password"]}
    Set Test Variable   ${NOM_10_PM_SFTP_ROOT_PATH}   ${nom["pm_sftp_root_path"]}


_VCU CNF Environment WA
    [Documentation]  _VCU CNF Environment WA
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   20.10.2021,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    #${vcu_platform}    Get vCU Platform Name
    ${vcu_platform}    Get vCU Platform Name From One Click Config
    Run Keyword If   "${vcu_platform}"=="OCP"    _VCU CNF Environment WA For OCP


_VCU CNF Environment WA For OCP
    [Arguments]  ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    ${alias}  Connect To CU K8S Master With Admin   width=300   gnb_index=${gnb_index}

    ${username}  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${sudo}   Set Variable If  "${username}"=="core"   sudo   ${EMPTY}

    #delete tmp folder
    ${ns}  get vdu namespace from testline
    ${cu_ns}   Get CU Namespace From TestLine
    ${tmp_foler_name}  set variable  /tmp/tmp_taic_${ns}_${cu_ns}
    ${out}   issh.Execute  command=${sudo} chmod 777 -R ${tmp_foler_name}   check_result=${False}  alias=${alias}
    ${out}   Run Keyword If   ${ns.__len__()}>0 and ${cu_ns.__len__()}>0
    ...   issh.Execute   command=${sudo} rm -rf ${tmp_foler_name}   alias=${alias}

    _VCU Environment WA For OCP   ${alias}


Collect vDU Kubectl Logs Via Bash
    [Documentation]  Collect vDU Kubectl Logs Via Bash
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    log to console   Collect vDU Kubectl Logs Via Bash
    ${timestamp}=  get time   exclude_millis=yes
    ${timestamp}=  replace string   ${timestamp}   ${SPACE}     _
    ${timestamp}=  replace string    ${timestamp}  -   _
    ${timestamp}=  replace string   ${timestamp}  :   _
    ${duration}   Get Case Running Duration
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ...   alias=${alias}

     ${script_file_path}   OperatingSystem.Join Path   ${CURDIR}  utility_robot   collect_kubectl_log.sh
    Log To Console  ${script_file_path}

    ${cu_ns}    Get CU Namespace From TestLine  gnb_index=${gnb_index}
    ${ns}   get vdu namespace from testline
    ${remote_path}  Set Variable   /tmp/tmp_kubetl_log_${ns}_${cu_ns}_VDU
    ${remote_tgz_file}   Set Variable     ${remote_path}/kubectl_log_cu_${gnb_index}.tgz
    ${remote_script_file}   Set Variable     ${remote_path}/collect_kubectl_log.sh

    ${out}   issh.Execute   command=rm -rf ${remote_path}  alias=${alias}
    ${out}   issh.Execute   command=mkdir -p ${remote_path}  alias=${alias}

    ${out}   issh.Execute   command=cd ${remote_path}  alias=${alias}
    issh.upload_file  local_path=${script_file_path}
    ...    remote_path=${remote_script_file}
    ...    alias=${alias}
    ${out}   issh.Execute   command=chmod +x collect_kubectl_log.sh   alias=${alias}
    issh.set_timeout   300    alias=${alias}
    ${out}   issh.Execute Bare   command=./collect_kubectl_log.sh -n ${ns} -f ${remote_tgz_file} -s ${duration}m   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}

    [Return]   ${alias}   ${remote_tgz_file}


Collect vCU Kubectl Logs Via Bash
    [Arguments]   ${gnb_index}=0
    [Documentation]  Collect vCU Kubectl Logs, it is called by 'Collect Log' in ta_utility.robot only
    ...    *AUTHOR* unknown
    ...    history change: <date>,<who>,<what and how>
    ...    24.2.2023,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No | gnb_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    log to console  Collect vCU Kubectl Logs Via Bash
    ${timestamp}=  get time   exclude_millis=yes
    ${timestamp}=  replace string   ${timestamp}   ${SPACE}     _
    ${timestamp}=  replace string    ${timestamp}  -   _
    ${timestamp}=  replace string   ${timestamp}  :   _
    ${duration}   Get Case Running Duration
    ${alias}  Connect To CU K8S Master With Tenant   width=200  gnb_index=${gnb_index}

    ${script_file_path}   OperatingSystem.Join Path   ${CURDIR}  utility_robot   collect_kubectl_log.sh
    Log To Console  ${script_file_path}

    ${cu_ns}    Get CU Namespace From TestLine  gnb_index=${gnb_index}
    ${ns}   get vdu namespace from testline
    ${remote_path}  Set Variable   /tmp/tmp_kubetl_log_${ns}_${cu_ns}
    ${remote_tgz_file}   Set Variable     ${remote_path}/kubectl_log_cu_${gnb_index}.tgz
    ${remote_script_file}   Set Variable     ${remote_path}/collect_kubectl_log.sh

    ${out}   issh.Execute   command=rm -rf ${remote_path}  alias=${alias}
    ${out}   issh.Execute   command=mkdir -p ${remote_path}  alias=${alias}

    ${out}   issh.Execute   command=cd ${remote_path}  alias=${alias}
    issh.upload_file  local_path=${script_file_path}
    ...    remote_path=${remote_script_file}
    ...    alias=${alias}
    ${out}   issh.Execute   command=chmod +x collect_kubectl_log.sh   alias=${alias}
    issh.set_timeout   300    alias=${alias}
    ${out}   issh.Execute Bare   command=./collect_kubectl_log.sh -n ${cu_ns} -f ${remote_tgz_file} -s ${duration}m   alias=${alias}
    ${out}   Send ENTER Interactively   alias=${alias}

    [Return]   ${alias}   ${remote_tgz_file}


Reinstall VDU By Agent
    [Arguments]  ${build_number}=${EMPTY}   ${target_state}=on_air  ${vcu_build_number}=${EMPTY}
    [Documentation]  Reinstall VDU By Agent
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    24.4.2022,chris.l.cao@nokia-sbell.com, add parameter target_state
    ...    16.3.2023,chris.l.cao@nokia-sbell.com, add parameter vcu_build_number
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | build_number  | No | build_number, default is ${EMPTY} |
    ...    | target_state  | No | target_state, default is on_air, it means re-deploy both vcu and vdu to make them on-air |
    ...    | vcu_build_number  | No | vcu_build_number, default is ${EMPTY} which means to deploy vcu to expected build |
    ...
    ...  Note: target_state can refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1268202142
    ...
    ...   on_air  agent will do deployment and commission to VDU/VCU, and make sure whole BTS on air
    ...   sw_uploaded  currently, it's same to skip_agent
    ...   gnb_not_commissioned  just do VDU/VCU deployment
    ...   vdu_deploy  just do VDU deployment
    ...   vdu_commissioned  VDU deployment and commission
    ...   vdu_on_air  agent will do deployment and commission to VDU, and make sure whole BTS on air
    ...   vcu_deploy  just do VCU deployment
    ...   vcu_commissioned  VCU deployment and commission
    ...   vcu_on_air  agent will do deployment and commission to VCU, and make sure whole BTS on air
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    |  Reinstall VDU By Agent |
    ...    |  Reinstall VDU By Agent | target_state=on_air |
    ...    |  Reinstall VDU By Agent | target_state=vdu_on_air |
    ...    |  Reinstall VDU By Agent | target_state=vdu_on_air | build_number=0.300.11201 |
    ...    |  Reinstall VDU By Agent | target_state=vcu_on_air |
    ...    |  Reinstall VDU By Agent | target_state=vcu_on_air | vcu_build_number=0.250.10858 |
    ...
    Log To Console   Reinstall VDU By Agent(target_state:${target_state}), usually it will take long time ...
    ${tl_config_path}  Get TestLine Config Directory From TestLine
    ${vcu_package_prifix}   Run Keyword If  "${vcu_build_number}"!="${EMPTY}"  Get Package Prefix From Global Variables File   ${vcu_build_number}
    ${vcu_build_number_with_prefix}   set variable if   "${vcu_build_number}"!="${EMPTY}"   ${vcu_package_prifix}_${vcu_build_number}
      ...   ${vcu_build_number}
    Log To Console  VDU:${build_number}
    Log To Console  VCU:${vcu_build_number_with_prefix}

    Run Agent To Recover Environment   ${tl_config_path}  build_number=${build_number}
      ...   target_state=${target_state}  vcu_build=${vcu_build_number_with_prefix}
    Run Keyword And Ignore Error  Online Enable actCli For vDU
    Run Keyword And Ignore Error  Online Enable Actcli For Cu


Recover Environment
    [Documentation]  Recover Environment
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.4.2023,chris.l.cao@nokia-sbell.com, Need recover environment in jenkins
    ...    7.5.2023,chris.l.cao@nokia-sbell.com, log print ${need_deploy} value
    ...    8.7.2023,chris.l.cao@nokia-sbell.com, return if it's UTE_CLOUD
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    |  Recover Environment |
    ...
    ${r}  ${ute_type}   run keyword and ignore error   Get UTE Type
    return from keyword if   "${r}"=="PASS" and "${ute_type}"!="JENKINS"

    log to console  Check whether to redeploy environment...
    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt

    ${r}   ${found}   Run Keyword And Ignore Error      OperatingSystem.File Should Exist   ${agent_flag_file}
    Run Keyword If   "${r}"!="PASS"  Log To Console  Need not redeploy environment(${agent_flag_file} not exist!)
    return from keyword if  "${r}"!="PASS"

    ${need_deploy}	 OperatingSystem.Run 	cat ${agent_flag_file}|awk -F '=' '{print $2}'
    ${tl_config_path}  Get TestLine Config Directory From TestLine

    Log To Console   need_deploy:${need_deploy}
    Return From Keyword If  ${need_deploy}==0

    Log To Console   Begin to redeploy environment...
    Run Agent To Recover Environment   tl_config_path=${tl_config_path}
    _Set Agent Flag With Content   agent_flag_file=${agent_flag_file}   redeploy=0


Run Agent To Recover Environment
    [Arguments]    ${tl_config_path}   ${build_number}=${EMPTY}   ${target_state}=${EMPTY}    ${vcu_build}=${EMPTY}
    [Documentation]  Run Agent To Recover Environment
    ...    *AUTHOR* jinbo.yu@nokia-sbell.com
    ...    2.8.2021,chris.l.cao@nokia-sbell.com, add to support build_number, add assertion for real_specific_vdu_build
    ...    7.12.2021,chris.l.cao@nokia-sbell.com, add description after https://jira3.ext.net.nokia.com/browse/CS-1570 was fixed.
    ...    17.10.2022,chris.l.cao@nokia-sbell.com, fix https://jiradc.ext.net.nokia.com/browse/CS-2443
    ...    15.03.2023,jinbo.yu@nokia-sbell.com, add vcu_build
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | tl_config_path | yes | tl_config_path |
    ...    | build_number  | No | build_number, default is ${EMPTY} |
    ...    | target_state  | No | target_state, default is ${EMPTY}, ${EMPTY} means re-deploy both vcu and vdu to make them on-air |
    ...    | vcu_build     | No | vcu build, default is ${EMPTY}, ${EMPTY} means use current vcu build, format should be vCUCNF00_0.250.11234 |
    ...
    ...  Note: target_state can refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1268202142
    ...
    ...   on_air  agent will do deployment and commission to VDU/VCU, and make sure whole BTS on air
    ...   sw_uploaded  currently, it's same to skip_agent
    ...   gnb_not_commissioned  just do VDU/VCU deployment
    ...   vdu_deploy  just do VDU deployment
    ...   vdu_commissioned  VDU deployment and commission
    ...   vdu_on_air  agent will do deployment and commission to VDU, and make sure whole BTS on air
    ...   vcu_deploy  just do VCU deployment
    ...   vcu_commissioned  VCU deployment and commission
    ...   vcu_on_air  agent will do deployment and commission to VCU, and make sure whole BTS on air
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${tl_config_path} | Get TestLine Config Directory From TestLin |
    ...    | Run Agent To Recover Environment | tl_config_path=${tl_config_path}   |
    ...    | Run Agent To Recover Environment | tl_config_path=${tl_config_path}   | target_state=vdu_on_air |
    ...    | Run Agent To Recover Environment | tl_config_path=${tl_config_path}   | target_state=vcu_on_air |
    ...
    ${default_specific_vdu_build}  get_environ_value   SPECIFIC_VDU_BUILD
    ${default_specific_vcu_build}  get_environ_value   SPECIFIC_VCU_BUILD
    ${default_target_state}  set variable  on_air
    ${target_state_env}  get_environ_value   TARGET_STATE
    ${package_prifix}    Run Keyword If   "${build_number}"!="${EMPTY}"     Get Package Prefix From Global Variables File   ${build_number}
    ${real_specific_vdu_build}   set variable if   "${build_number}"=="${EMPTY}"   ${default_specific_vdu_build}
    ...   ${package_prifix}_${build_number}
    ${target_state_env}   set variable if   "${target_state_env}"=="${EMPTY}"   ${default_target_state}   ${target_state_env}
    ${real_target_state}   set variable if   "${target_state}"=="${EMPTY}"   ${target_state_env}   ${target_state}

    should not be empty   ${real_specific_vdu_build}
    should not be empty   ${real_target_state}
    ${old_cm_artifacts}    get_environ_value     CM_ARTIFACTS
    ${new_cm_artifacts}    Set Variable    [{"type": "build", "properties":{"related_artifacts":{"5G":
    ${new_cm_artifacts}    Set Variable    ${new_cm_artifacts}[{"default":true,"name":"build",
    ${new_cm_artifacts}    Set Variable    ${new_cm_artifacts}"version":"SBTS20B_ENB_9999_200401_000001"},
    ${new_cm_artifacts}    Set Variable    ${new_cm_artifacts}{"default":true,"name":"vcu_cnf",
    ${new_cm_artifacts}    Set Variable    ${new_cm_artifacts}"version":"${vcu_build}
    ${new_cm_artifacts}    Set Variable    ${new_cm_artifacts}"},{"default":true,"name":"fhgw","version":
    ${new_cm_artifacts}    Set Variable    ${new_cm_artifacts}"FHGW_20.014.1.12_2012031652_99f4ec1"}]}}}]
    run keyword if    "${vcu_build}"!="${EMPTY}"    Set environment variable    CM_ARTIFACTS    ${new_cm_artifacts}
    ${result}=    Run Keyword And Ignore Error    Environment Variable Should Be Set    JENKINS_URL
    ${agent_cmd_pre}=   Set Variable   agent_5g_aic init -l 'CLOUD_5G_AIC'
    ${agent_cmd}=    Set Variable
    ...    ${agent_cmd_pre} -b ${real_specific_vdu_build} -o 'output' -s ${real_target_state} -R 'testline_init_results/' -p ${tl_config_path}
    ${agent_cmd}=    Set Variable    export JENKINS_URL=https://localhost:8080 && ${agent_cmd}
    Run Keyword If    '${result[0]}'=="PASS"    OperatingSystem.Run    bash -c "source /opt/ute/agent_env_py3/bin/activate && ${agent_cmd}"
    ...    ELSE    OperatingSystem.Run    bash -c "source /opt/ute/agent_env/bin/activate && ${agent_cmd}"
    run keyword if    "${vcu_build}"!="${EMPTY}"    Set environment variable    CM_ARTIFACTS    ${old_cm_artifacts}


Collect vDU Container Logs On Given Pod
    [Arguments]  ${pod_name}  ${container_name}=all  ${vdu_index}=0  ${duration}=13   ${target_path}=${EMPTY}   ${time_unit}=m
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]  Collect vDU Container Logs On Given Pod
    ...    *AUTHOR* unknown
    ...    history change: <date>,<who>,<what and how>
    ...    16.8.2021,xxx@nokia-sbell.com, author is unknown
    ...    16.8.2021,chris.l.cao@nokia-sbell.com, add change history, change from helm lib to issh library
    ...    23.11.2021,chris.l.cao@nokia-sbell.com, add change history, optimize code to shorten collecting time
    ...    17.1.2022, rui.3.li@nokia-sbell.com, add argument time_unit supoort diverse time unit
    ...    2.8.2022, chris.l.cao@nokia-sbell.com, update KW description
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod name       | Yes | pod abbreviation |
    ...    | container_name | No | container abbreviation, e.g, cprt, oamext, etc. default value is 'all' means get all container's log |
    ...    | vdu_index      | No | vdu_index, default value is 0  |
    ...    | duration       | No | how long time in past, is a number, default is 13 |
    ...    | target_path    | No | file path of save log, default empty will automation get in code |
    ...    | time_unit      | No | time unit, m means minute, s means second, default value is m |
    ...
    ...    *RETURN VALUE*
    ...    Log file path in local UTE server..
    ...
    ...    Example
    ...    | ${log_file_path} | Collect vDU Container Logs On Given Pod | pod_name=cprt |  container_name=all |
    ...    | ${log_file_path} | Collect vDU Container Logs On Given Pod | pod_name=oamext | container_name=oamagent | duration=60 | time_unit=s |
    ...    | ${log_file_path} | Collect vDU Container Logs On Given Pod | pod_name=oamext | container_name=oamagent | duration=3 | time_unit=m |
    ...
    ${timestamp}=  get time   exclude_millis=yes
    ${timestamp}=  replace string   ${timestamp}   ${SPACE}     _
    ${timestamp}=  replace string    ${timestamp}  -   _
    ${timestamp}=  replace string   ${timestamp}  :   _

    ${local_log_file_path}=  run keyword if   '${target_path}'=='${EMPTY}'   Get A File
    ...    container_logs_${timestamp}   ${pod_name}_${container_name}_test.log
    ...    ELSE   get a file     ${target_path}     ${pod_name}_${container_name}_test.log

    ${alias}   get unique id
    Connect To K8s Master With Tenant Interactively  alias=${alias}
    ${pod_prefix}   Get Pod Name Prefix  vdu_index=${vdu_index}
    ${has_pod_prefix}  set variable  ${pod_name.startswith("${pod_prefix}")}

    ${pod_name}  run keyword if   "${has_pod_prefix}"=="${True}"  set variable  ${pod_name}
    ...   ELSE   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_name}   alias=${alias}   vdu_index=${vdu_index}

    ${ns}  get vdu namespace from testline   vdu_index=${vdu_index}

    ${full_container_name}  run keyword if   '${container_name}'!='all'
        ...   Get Full Container Name By Container Abbreviation     ctr_abbr=${container_name}  vdu_index=${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container_name}'=='all'
        ...  set variable  kubectl logs ${pod_name} --all-containers=true --since=${duration}${time_unit} -n ${ns}
    ...  ELSE
        ...   set variable  kubectl logs ${pod_name} -c ${full_container_name} --since=${duration}${time_unit} -n ${ns}

    ${remote_log_file_name}   set variable   ${pod_name}_${container_name}_test.log

    ${cmd}=  set variable   ${function_cmd} > ./${remote_log_file_name}
    ${old_timeout}    issh.set_timeout  600   alias=${alias}
    ${result}  issh.execute  ${cmd}    alias=${alias}
    issh.set_timeout  ${old_timeout}   alias=${alias}
    ${result}  issh.execute  sync    alias=${alias}

    issh.download_file  remote_path=./${remote_log_file_name}
    ...  local_path=${local_log_file_path}   alias=${alias}
    issh.execute  rm -rf ./${remote_log_file_name}    alias=${alias}

	[Return]   ${local_log_file_path}



Collect vDU K8S Logs In Given Pod
    [Documentation]  collect vdu kube logs in one pod using 'kubectl logs' command
    ...   *Author*  calla.wang@nokia-sbell.com
    ...    04.09.2020,lingting.sun@nokia-sbell.com,add param duration and return log path
    ...   | Input Parameters | Man. | Description |
    ...	  | pod_name | Yes. | the pod name |
    ...   | kubelog_file_name | Yes. | the log file name that will be stored in local |
    ...   | container_name | No. | the container name, default is None means all containers of the pod |
    ...   | vdu_index | No. | the vdu index default is 0 |
    ...   | duration  | No. | the duration default is 60s |
    ...   *Return Value*
    ...   None
    [Arguments]  ${pod_name}  ${kubelog_file_name}  ${container_name}=${None}  ${vdu_index}=0  ${gnb_index}=0
                 ...   ${duration}=60s
    ${index}=  get unique id
    ${local_filepath}   get a Directory   k8s_log_${index}
    ${executor}    Create Dictionary
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    kubelog_collect.create_kubernetes_collector
    ...    name=kubelog
    ...    namespace=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    ...    pod_name=${pod_name}
    ...    container=${container_name}
    ...    executor=${executor}
    ...    target_file_name=${kubelog_file_name}
    ...    sudo_password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    core_collect.setup_collectors    names=kubelog
    core_collect.start_collectors    names=kubelog
    sleep  ${duration}
    core_collect.stop_collectors    names=kubelog
    core_collect.collect_collectors    names=kubelog    target_dir=${local_filepath}
    core_collect.teardown_collectors    names=kubelog
    run keyword and ignore error    OperatingSystem.Run   cd ${local_filepath}/kubelog/;tar -xvf *
    [return]    ${local_filepath}/kubelog/


_Create Logs Folder For Test Case
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}


_Kill Unexpected Process
    [Documentation]   _Kill Unexpected Process
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    04.19.2022, chris.l.cao@nokia-sbell.com, add 'rm -rf /tmp/.com.google.Chrome.*'
    ...
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    log to console  *** _Kill Unexpected Process ***
    #run process    taskkill /f /im chromedriver.exe    shell=True
    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True

    FOR  ${keyword}  IN   firefox   geckodriver
        ${out}   Run Process   ps -ef | grep ${keyword} | grep -v grep | awk '{print $2}' | xargs kill -9   shell=True
    END

     run process   rm -rf /tmp/taf_selenium*; rm -rf /tmp/SCF_*; rm -rf /tmp/.com.google.Chrome.*   shell=True
     run process   rm -rf /tmp/rust_mozprofile*; sudo rm -rf /tmp/systemd-private-*; rm -rf /tmp/tmp*;rm -rf /tmp/Temp-*;rm -rf /tmp/ssh*
      ...   shell=True


_Check Installed Packages
    #${vagrant_machine}   _Is Vagrant Machine
    #return from keyword if  "${vagrant_machine}"=="${True}"

    ${cmd}  Set Variable   sudo apt list --installed | grep tshark
    ${out}   Run Process   ${cmd}  shell=True
    Should Be True   ${out.rc}==0   Please install tshark in UTE firstly(Linux command: sudo apt-get install tshark --yes)


_Self Check Script And Configuration
    [Documentation]    _Self Check Script And Configuration
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    No return value.
    ...
    ...    Example
    ...    | _Self Check Script And Configuration |
    ...
    log to console  _Self Check Script And Configuration
    _Self Check Robot File Name
    _Self Check Suite Name
    _Self Check Test Case Name

    _Self Check Author For Settings
    _Self Check Author For Cases
    _Self Check Description For Settings
    _Self Check Tags
    _Self Check Maximum Line Length
    _Self Check Testline Name


_Self Check Robot File Name
    ${path}   ${robot_file_name}   OperatingSystem.Split Path   ${SUITE_SOURCE}
    should be true  ${robot_file_name.__len__()<=150}
    ${matches}   get regexp matches  ${robot_file_name}   ^[0-9a-zA-Z_.-]+$
    should be true  ${matches}   Robot file name should consist of 0-9a-zA-Z_.-


_Self Check Suite Name
    log to console   ${SUITE_NAME}
    should be true  ${SUITE_NAME.__len__()<=150}
    ${matches}   get regexp matches  ${SUITE_NAME}   ^[0-9a-zA-Z_\\s\\.&-]+$
    should be true  ${matches}   Suite name should consist of 0-9a-zA-Z_&.-


_Self Check Test Case Name
    should be true  ${TEST_NAME.__len__()<=150}
    #should be true  ${TEST_NAME.startswith("[1]")}  Case name should begin with [1]
    ${matches}   get regexp matches  ${TEST_NAME}   ^\\[\\d+\\].*$
    should be true  ${matches}   Case name should start with [n], n is an integer
    ${tmp}   set variable  ${TEST_NAME[3:]}

    run keyword if  "${tmp[0]}"!="["   _self Check Test Case Name Without version number   ${tmp}
    ...   ELSE    _self Check Test Case Name With version number   ${tmp}


_self Check Test Case Name Without version number
    [Arguments]  ${case_name_withou_version_number}
    ${matches}   get regexp matches  ${case_name_withou_version_number}   ^[0-9a-zA-Z_-]+$
    should be true  ${matches}   Case name should consist of 0-9a-zA-Z_-


_self Check Test Case Name With version number
    [Arguments]  ${case_name_withou_version_number}
    ${matches}   get regexp matches    ${case_name_withou_version_number}   ^\\[\\d+\\.\\d+\\]\\s*[0-9a-zA-Z_-]+$
    should be true   ${matches}   Case name should consist of 0-9a-zA-Z_-


_Self Check Author For Settings
    ${base_cmd}   set variable   grep -i "\\*\\*\\* Settings" -A 200 ${SUITE_SOURCE}|grep -i "\\*\\*\\* Test Case" -B 200
    ${cmd}   set variable  ${base_cmd}|grep -i "author:"|egrep ".*[0-9a-zA-Z._-]+@(nokia-sbell|nokia)|.com.*"|wc -l
#    ${out}  issh.Execute  command=${cmd}     alias=${alias}
#    ${out}  strip prompt   ${out}
    ${out}  OperatingSystem.Run      ${cmd}

    ${num}   Parse Number Only From Content    ${out}
    ${prompt}  set variable if  ${num}!=1   Only one author: <your_mail_id>@nokia-sbell.com is allowed in *** Settings *** section!
    ${prompt}  set variable if  ${num}!=1   ${prompt} please refer to:https://wrgitlab.int.net.nokia.com/5G/robotws5g/blob/master/
    ${prompt}  set variable if  ${num}!=1   ${prompt}testsuite/AIC/Reference_Test_Case_Template.robot
    should be true  ${num}==1   ${prompt}


    ${cmd}   set variable  ${base_cmd}|grep -i "contact:"|egrep ".*[0-9a-zA-Z._-]+@(nokia-sbell|nokia).com.*"|wc -l
#    ${out}  issh.Execute  command=${cmd}     alias=${alias}
#    ${out}  strip prompt   ${out}
    ${out}  OperatingSystem.Run      ${cmd}

    ${num}   Parse Number Only From Content    ${out}
    ${prompt}  set variable if  ${num}!=1   Only one contact: <your_mail_id>@nokia-sbell.com is allowed in *** Settings *** section!
    ${prompt}  set variable if  ${num}!=1   ${prompt} please refer to:https://wrgitlab.int.net.nokia.com/5G/robotws5g/blob/master/
    ${prompt}  set variable if  ${num}!=1   ${prompt}testsuite/AIC/Reference_Test_Case_Template.robot
    should be true  ${num}==1   ${prompt}


_Self Check Author For Cases
    ${base_cmd}   set variable   grep -i "\\*\\*\\* Test Case" -A 5000 ${SUITE_SOURCE}|grep -i "\\*\\*\\* Keyword" -B 5000
    ${cmd}   set variable  ${base_cmd}|grep -i "author:"|egrep ".*[0-9a-zA-Z._-]+@nokia(-sbell)*.com.*"|wc -l
#    ${out}  issh.Execute  command=${cmd}     alias=${alias}
#    ${out}  strip prompt   ${out}
    ${out}  OperatingSystem.Run      ${cmd}

    ${num_author}   Parse Number Only From Content    ${out}

    ${cmd}   set variable  ${base_cmd}|egrep "^\\[[0-9]\\].*"|wc -l
#    ${out}  issh.Execute  command=${cmd}     alias=${alias}
#    ${out}  strip prompt   ${out}
    ${out}  OperatingSystem.Run      ${cmd}
    ${num_cases}   Parse Number Only From Content    ${out}
    ${prompt}  set variable if  ${num_author}!=${num_cases}  every case should have 'author: <your_mail_id>@nokia-sbell.com'
    ${prompt}  set variable if  ${num_author}!=${num_cases}  ${prompt} section! please refer to:https://wrgitlab.int.net.nokia.com/5G/robotws5g/
    ${prompt}  set variable if  ${num_author}!=${num_cases}  ${prompt}blob/master/testsuite/AIC/Reference_Test_Case_Template.robot
    should be true  ${num_author}==${num_cases}   ${prompt}


_Self Check Description For Settings
    ${base_cmd}   set variable   grep -i "\\*\\*\\* Settings" -A 5000 ${SUITE_SOURCE}|grep -i "\\*\\*\\* Test Case" -B 5000
    #${cmd}   set variable  ${base_cmd}|grep -i "Description:"|egrep ".+:\\s*\\S+.+"|wc -l
    ${cmd}   set variable  ${base_cmd}|grep -i "Description:"|wc -l
#    ${out}  issh.Execute  command=${cmd}     alias=${alias}
#    ${out}  strip prompt   ${out}
    ${out}  OperatingSystem.Run      ${cmd}
    ${num}   Parse Number Only From Content    ${out}
    run keyword if   ${num}!=1   _Print General Prompt Message For Self Check
    should be true   ${num}==1   Should have Description in *** Settings *** !


_Print General Prompt Message For Self Check
    ${prompt}  set variable   please refer to:https://wrgitlab.ext.net.nokia.com/RAN/robotws/-/blob
    ${prompt}  set variable   ${prompt}/master/testsuite/Hangzhou/AIC/RAN_PZ_HAZ_2/Reference_Test_Case_Template.robot
    log to console   ${prompt}


_Self Check Tags
    [Documentation]   _Self Check Tags
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    04.12.2021, chris.l.cao@nokia-sbell.com, add VDU_PRIVILEGE_TRUE tag
    ...    09.12.2021, chris.l.cao@nokia-sbell.com, remove VDU_PRIVILEGE_TRUE tag
    ...    09.7.2023, chris.l.cao@nokia-sbell.com, change to check UTE Clould tag only
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${rc}  ${out}   OperatingSystem.Run And Return Rc And Output   command=ls /home/ute/jenkins_home/
    Return From Keyword If   ${rc}==0

#    ${check_result}  ${msg}    Verify UTE Cloud Tag    ${TEST_TAGS}
#    run keyword if   "${check_result}"!="${True}"   _Print General Prompt Message For Self Check
#    run keyword if   "${check_result}"!="${True}"   Fail   ${msg}


_Self Check Maximum Line Length
#    ${expression}   set variable  [("line_number:{}".format(int(i+1)),"length:{}".format(len(line.strip('\\n'))),line.strip('\\r\\n'))
#    ${expression}   set variable  ${expression} for i,line in enumerate(open("${SUITE_SOURCE}")) if len(line.strip('\\n'))>150]
    ${expression}   set variable  [("line_number:{}".format(int(i+1)),line) for i,line in enumerate(open("${SUITE_SOURCE}")) if len(line)>150]

    ${invalid_lines}  evaluate   ${expression}
    run keyword if  ${invalid_lines.__len__()>0}   log to console  robot line length should be <=150(${SUITE_SOURCE})
    should be true  ${invalid_lines.__len__()==0}  ${invalid_lines}


_Self Check Testline Name
    ${tl_name}  Get TestLine Name From TestLine
    ${matches}   get regexp matches  ${tl_name}   ^7_\\d_UTE5GAIC(CSV)*00\\dT\\d{3,5}$
    should be true  ${matches}   Testline name should be 7_5_UTE5GAIC001Tnnn or 7_5_UTE5GAIC001Tnnnnn, n is number 0-9
    #ESPOO: 7_4_UTE5GAICCSV001T5701

_Init TRS Global Variable
    #
    # it's a WA, please see https://jira3.int.net.nokia.com/browse/TALIB-846,
    # this jira has blocked a few transport TA cases design and debug
    # one of other WAs is to declare a global python variable, 'TRANS_PARA = _trans_para'
    # i don't know which WA is better, please give me suggestion if you like to replace current WA with new one.
    # P.S.:
    # 1/ this issue was posted in Microsoft Team on October 17, 2019. Nearly 3 months passed, but it's not solved.
    # 2/ this issue was submitted in Jira system(jira id:TALIB846) on November 27, 2019. Exactly 1.5 months passed, but it's not solved.
    # i think TAF team does not have time to solved it because there are other higher priority tasks for them.
    # So we Hangzhou team should use WA(Walk Around) to get rid of this issue, otherwise it impacts our transport TA project schedule too much.
    # In future, when TAF team fix this TALIB-846, i will switch to latest solution.
    # If any questions, we can have a mail to discuss or face to face dicussion. Nokia company emphasizes that 5G project is very important,
    # so that we should find way to push 5G TA project forward by Hangzhou team ourselves, by everyone of Hangzhou team.
    # And it's not right if it is blocked by a specifical person.
    #
    ${result}   ${TRANS_PARA}   Run Keyword And Ignore Error    Set Variable  ${tl._trans_para}
    ${TRANS_PARA}  set variable if  """${result}"""=="""FAIL"""   ${NONE}    ${TRANS_PARA}
    Set Suite Variable   ${TRANS_PARA}


_Backup SCF From Test Line
    [Arguments]  ${scf_file_name}   ${vdu_index}=0
    [Documentation]  vDU Rest Logout
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  4.09.2020,chris.l.cao@nokia-sbell.com, add check for OAM up or down
    ...
    ${backup_scf_path}=  Get A Directory  BackupSCF
    vDU Rest Login
    ${backup_scf_file}=  vdu.get_current_plan_file  local_dir_path=${backup_scf_path}  filename=${scf_file_name}  include_runtime_data=${False}
    [Return]  ${backup_scf_file}
    [Teardown]  vDU Logout


Backup SCF For VDU REST
    [Arguments]   ${vdu_index}=0
    [Documentation]  vDU Rest Logout
    ...  history change:
    ...  author:chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  4.12.2021,chris.l.cao@nokia-sbell.com, Seperated it from common setup to speed up dryrun
    ...
    ${SCF_IN_SETUP}     _Backup SCF From Test Line   scf_in_setup.xml   vdu_index=${vdu_index}
    set test variable    ${SCF_IN_SETUP}
    [Return]  ${SCF_IN_SETUP}


Disable RECOVER
    [Documentation]   Disable RECOVER, using this KW to disable AIC Recovery action, e.g, will not reset VDU itself when environemnt is not on-air
    ...    will not re-install VDU when environment is not on-air
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Disable RECOVER |
    ...
    set suite variable  ${RECOVER}   0


====== Common Setup KW End ======
     log to console  \n*** only used for readable ***

_Get Target netact Server Index
    [Arguments]   ${service_name}=cmwas   ${alias}=default
    [Documentation]
    ...    will chose the useful netact and return the netact id
    ...    *AUTHOR* jie.8.liu@nokia-sbell.com
    ...    modified by:        <13-Oct-2021>, <huilxu>, <netact Detect Rest Login>
    ...    modified by:        <5-Nev-2021>, <huilxu>, <netact Detect Rest Login>
    ...    history change: <date>,<who>,<what and how>
    ...   13.10.2021,huilxu@nokia-sbell.com, netact Detect Rest Login.
    ...   5.11.2021,huilxu@nokia-sbell.com, netact Detect Rest Login.
    ...   18.6.2023,chris.l.cao@nokia-sbell.com, add configured_status check
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    |  service_name | No | default value is cmwas |
    ...    |  alias | No | default value is default |
    ...
    ...    *RETURN VALUE*
    ...    Index of desire target netact server and target netact server
    ...
    ${all_netact_list}      get_all_netact_server
    ${netact_count}=    Get Length    ${all_netact_list}
    log to console     ${all_netact_list}
    log to console     ${netact_count}
    FOR    ${netact_index}    IN RANGE    ${netact_count}
         ${configured_status}  Set Variable   ${all_netact_list[${netact_index}]["configured_status"]}
         Continue For Loop If    "${configured_status}"=="unavailable"
         ${status}     Run Keyword and Return Status    _netact Detect ssh    ${all_netact_list[${netact_index}]}
         ...  service_name=${service_name}  alias=${alias}
         Exit For Loop If    "${status}"=="True"
         log to console      ${status}
    END
    Run Keyword If   "${status}"=="True"  Log To Console   Netact is selected.
     ...   ELSE    Log To Console   Netact is NOT selected!
    Run Keyword If   "${status}"=="True"  Log To Console  ${all_netact_list[${netact_index}]}
    Should Be True   "${status}"=="True"
    [Return]    ${netact_index}     ${all_netact_list[${netact_index}]}


_Netact Detect Ssh
    [Arguments]  ${dict_netact}   ${service_name}=cmwas   ${alias}=default
    [Teardown]   run keyword and ignore error  Run Keyword If  "${netact_login}"=="1"
       ...      taf_netact.delete_node  service_name=${service_name}  alias=${alias}

    ${netact_login}  Set Variable   0

    ${client_id}=  get unique id
    ${hostname}   Set Variable  ${dict_netact["node_ip"]}
    ${username}    Set Variable  ${dict_netact["user"]}
    ${password}   Set Variable  ${dict_netact["password"]}
    taf_netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   alias=${alias}
    ${netact_login}  Set Variable   1


Set Agent Flag By TA Utility
    [Arguments]  ${agent_flag_file}
    [Documentation]   Set Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Set Agent Flag |
    ...
    #${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt

    ${redeploy_flag}    Need Redeploy VDU
    ${redeploy_value}   Set Variable If   "${redeploy_flag}"=="${True}"   1   0
    log to console    redeploy_value:${redeploy_value}

    _Set Agent Flag With Content   agent_flag_file=${agent_flag_file}   redeploy=${redeploy_value}


_Set Agent Flag With Content
    [Arguments]  ${agent_flag_file}   ${redeploy}
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   Set Agent Flag
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Set Agent Flag |
    ...
    log to console  _Set Agent Flag With Content
    ${alias}   get unique id
    connect to ute locally  alias=${alias}

    ${found}   issh.is_file   ${agent_flag_file}   alias=${alias}
    should be true  ${found}

    #display old value
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}

    #change file content
    ${out}  issh.Execute   command=echo redeploy=${redeploy} > ${agent_flag_file}    alias=${alias}

    #display new value
    ${out}  issh.Execute   command=cat ${agent_flag_file}   alias=${alias}


VDU Take OCP Log For Login Authorization Failed
    [Arguments]  ${check_data}=All healthy and stable  ${alias}=default
    [Documentation]  VDU Take OCP Log For Login Authorization Failed
    ...    |  Input Parameters | Man. | Description |
    ...    | check_data (string) | No | take OCP log finished flag(nohup.out) |
    ...    | alias (string) | No  | Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    VDU OCP log path
    ...
    ...    Example
    ...    | ${local_filepath}  | VDU Take OCP Log For Login Authorization Failed |

    Connect To K8s Master Interactively   alias=${alias}  timeout=600
    ${login_result}  OC Login To OCP K8s Node  alias=${alias}
    ${local_filepath}  Run Keyword If  "${login_result}" != "Login successful"
    ...  _Take OCP Log And Download Log For Login Failed  check_data=${check_data}  alias=${alias}

    [Return]  ${local_filepath}
    [Teardown]   Disconnect Interactive Connections


VCU Take OCP Log For Login Authorization Failed
    [Arguments]  ${check_data}=ClusterID
    [Documentation]  VCU Take OCP Log For Login Authorization Failed
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | check_data (string) | No | take OCP log finished flag(nohup.out) |
    ...
    ...    *RETURN VALUE*
    ...    VCU OCP log path
    ...
    ...    Example
    ...    | ${local_filepath}  | VCU Take OCP Log For Login Authorization Failed |

    ${alias}  Connect To CU K8S Master With Tenant  timeout=600
    ${login_result}  OC Login To OCP K8s Node  alias=${alias}
    ${local_filepath}  Run Keyword If  "${login_result}" != "Login successful"
    ...  _Take OCP Log And Download Log For Login Failed   check_data=${check_data}  alias=${alias}

    [Return]  ${local_filepath}
    [Teardown]  Disconnect Interactive Connections


OC Login To OCP K8s Node
    [Arguments]  ${alias}
    [Documentation]  OC Login To OCP K8s Node
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    login result
    ...
    ...    Example
    ...    | ${alias} | Connect To CU K8S Master With Admin |
    ...    | ${local_filepath}  | VCU Take OCP Log For Login Authorization Failed | alias=${alias} |

    ${url}  Get OCP Login URL For VCU OR VDU  alias=${alias}
    ${cmd}   set variable
    ...  oc login -u ${OCP_LOGIN_USERNAME} -p ${OCP_LOGIN_PASSWORD} ${url}
    ${old_prompt}  issh.get_prompt   alias=${alias}
    ${new_prompt}  set variable  ${old_prompt}|\\(y/n\\):\\s
    issh.set_prompt    ${new_prompt}    alias=${alias}
    ${out}   issh.Execute  command=${cmd}  check_result=False   alias=${alias}
    ${out2}  Run Keyword If  "(y/n):" in """${out}"""    issh.Execute   command=y   alias=${alias}
    issh.set_prompt  ${old_prompt}   alias=${alias}
    ${result}  Run Keyword If  """${out2}""" != """${None}"""  get regexp matches  ${out2}  Login successful
    ...  ELSE  get regexp matches  ${out}  Login successful
    ${login_result}  Run Keyword If  ${result}!=[]  set variable  ${result[0]}
    ...  ELSE  set variable  Login failed
    [Return]   ${login_result}


Get OCP Login URL For VCU OR VDU
    [Arguments]  ${alias}=default
    [Documentation]  Get OCP Login URL For VCU OR VDU
    ...    *AUTHOR* hongyuan.sun@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias (string) | No  | Default value is ‘default’ |
    ...
    ...    *RETURN VALUE*
    ...    login result
    ...
    ...    Example
    ...    | ${alias} | Connect To CU K8S Master With Admin |
    ...    | ${url}  | Get OCP Login URL For VCU OR VDU | alias=${alias} |

    ${cmd}  set variable   cat ./.kube/config | grep server | grep api | awk -F "server: " '{print $2}' | sort -u
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${url}  strip prompt  ${out}

    [Return]  ${url}


_Take OCP Log And Download Log For Login Failed
    [Arguments]  ${check_data}  ${alias}
    issh.Execute  command=rm -rf must-gather*  alias=${alias}
    issh.Execute  command=rm -rf /var/home/core/must-gather_tmp  alias=${alias}
    issh.Execute  command=mkdir /var/home/core/must-gather_tmp  alias=${alias}

    ${cmd}  set variable  rm -rf nohup.out
    issh.Execute  command=${cmd}  alias=${alias}
    ${cmd}  set variable  nohup oc adm must-gather &
    issh.Execute  command=${cmd}  alias=${alias}
    Send CTRL_C Interactively  alias=${alias}
    Wait Until Keyword Succeeds  600s  15s  _Check Take OCP Log Result  check_data=${check_data}  alias=${alias}
    sleep  1s

    ${take_time_tmp}  issh.Execute  command=date +"%Y-%m-%d %H:%M:%S"  alias=${alias}
    ${take_time}  strip prompt  ${take_time_tmp}
    ${cmd}  set variable  nohup tar cvaf /var/home/core/must-gather_tmp/ocp_log.tar.gz must-gather.local* &
    issh.Execute  command=${cmd}  alias=${alias}
    Send CTRL_C Interactively  alias=${alias}
    Wait Until Keyword Succeeds  60s  2s  _Check OCP log tar result  alias=${alias}
    ${local_filepath}   get a Directory   OCP_log_${take_time}
    issh.download_file  remote_path=/var/home/core/must-gather_tmp/ocp_log.tar.gz
    ...  local_path=${local_filepath}/ocp_log.tar.gz  alias=${alias}
    [Return]  ${local_filepath}


_Check Take OCP Log Result
    [Arguments]  ${check_data}  ${alias}=default
    ${cmd}  set variable  cat nohup.out | grep "${check_data}" | wc -l
    ${out}  issh.Execute  command=${cmd}  alias=${alias}
    ${res}  Strip Prompt  ${out}
    should be true  "${res[0:1]}"=="2"


_Check OCP Log Tar Result
    [Arguments]  ${alias}=default
    ${cmd}  set variable  ls -lh /var/home/core/must-gather_tmp | awk '{print $5}'
    ${out}  issh.Execute  command=${cmd}  alias=${alias}
    ${out1_tmp}  Strip Prompt  ${out}
    ${out1}  Strip String   ${out1_tmp}
    sleep  1s
    ${out}  issh.Execute  command=${cmd}  alias=${alias}
    ${out2_tmp}  Strip Prompt  ${out}
    ${out2}  Strip String   ${out2_tmp}
    should be true  "${out1}"=="${out2}"


Is UP Pod Split
    [Arguments]     ${vdu_index}=0   ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection  alias=${alias}
    [Documentation]   Is UP Pod Split
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...    | gnb_index      | No | gnb_index, default is 0 |
    ...    *RETURN VALUE*
    ...    1 or 0, 1 means UP pod is split.
    ...
    ...    Example
    ...    | ${up_pod_split_flag} | Is UP Pod Split |
    ...

    ${vdu_release_name}   Get VDU Release Name   vdu_index=${vdu_index}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively  vdu_index=${vdu_index}  alias=${alias}   gnb_index=${gnb_index}
    ${out}  issh.Execute
     ...  command=helm get values ${vdu_release_name}|grep upCount|wc -l   alias=${alias}
    ${out}   Strip Prompt  ${out}
    Return From Keyword If  ${out}==0   1

    ${out}  issh.Execute
     ...  command=helm get values ${vdu_release_name}|grep upCount|awk -F ": " '{print $2}'   alias=${alias}
    ${out}   Strip Prompt  ${out}

    ${up_pod_split_flag}   Set Variable If   ${out}==0  1   0
    [Return]  ${up_pod_split_flag}


============= Coredump Collection Via Koredump Tool ============

Coredump Pre-condition
    [Documentation]   Get the start timestamp(UTC)
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <21-09-2021>, <lingtsun>, <initial creation>
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Coredump Pre-condition  |
    ${START_UTC_TIMESTAMP}   get_current_utc_timestamp
    Set Test Variable    ${START_UTC_TIMESTAMP}


Check Core Dump Files And Download it And Fail The Case If It Has...
    [Arguments]   ${cu_quantity}=${EMPTY}   ${cu_coredump_check}=${True}   ${vdu_coredump_check}=${True}
    [Documentation]   Check Core Dump Files and download it and Fail the case if it has.
    ...    author: lingting.sun@nokia-sbell.com
    ...    modified by:  lingting.sun@nokia-sbell.com  <21-09-2021>, <lingtsun>, <initial creation>
    ...    modified by:  rui.3.li@nokia-sbell.com  <22-02-2023>, <r3li>, <update keyword>
    ...    | Input Parameters | Man. | Description |
    ...    | cu_quantity | no | Number of custom cu |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    |  Check Core Dump Files And Download it And Fail The Case If It Has...  |
    ${quantity_of_cu_tmp}   get length   ${tl.gnbs}
    ${quantity_of_cu}    set variable if    "${cu_quantity}"=="${EMPTY}"   ${quantity_of_cu_tmp}
    FOR  ${gnb_index}   IN RANGE    ${quantity_of_cu}
        ${koredump_r}   _Is Koredump Tool Installed   ne_type=vcu   gnb_index=${gnb_index}
        run keyword if   '${koredump_r}'=='${True}' and '${cu_coredump_check}'=='${True}'
        ...  Run Keyword And Continue On Failure   NE Collect Coredump Log  ne_type=vcu  gnb_index=${gnb_index}
        ...   ELSE IF  '${koredump_r}'=='${False}'   log to console  koredump Tool is not installed, it should be installed by agent
        run keyword if  '${vdu_coredump_check}'=='${True}'
        ...  _Check Core Dump Files And Download it On Specified CU   ${gnb_index}
    END


_Check Core Dump Files And Download it On Specified CU
   [Arguments]   ${gnb_index}
    ${quantity_of_vdu_for_specified_cu}=   Get vDU Number    gnb_index=${gnb_index}
    FOR   ${vdu_index}   IN RANGE   ${quantity_of_vdu_for_specified_cu}
        ${koredump_r}   _Is Koredump Tool Installed   ne_type=vdu   gnb_index=${gnb_index}   vdu_index=${vdu_index}
        run keyword if   '${koredump_r}'=='${True}'  NE Collect Coredump Log  ne_type=vdu  gnb_index=${gnb_index}  vdu_index=${vdu_index}
        ...  ELSE IF  '${koredump_r}'=='${False}'   log to console  koredump Tool is not installed, it should be installed by agent
    END


_Is Koredump Tool Installed
    [Arguments]  ${ne_type}   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  Check koredump tool is installed
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...    modified by:
    ...   | who | date | what or how |
    ...   | lingtsun | 21-09-2021 | initial creation |
    ...   | r3li | 07-21-2022 | adapt keyword on cu |
    ...   | chris.l.cao | 03-29-2023 | add '2>&1' after 'koredumpctl status' to skip curl error in vcu |
    ...   | chris.l.cao | 05-24-2023 | change to 'Return From Keyword If   ${output_1}==0   ${False}' |
    ...
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ne_type | Yes | support vcu, vdu |
    ...   | gnb_index  |  no | gnb index, default is 0 |
    ...   | vdu_index  |  no | VDU index, default is 0 |

    ...   *Return*
    ...   ${True} or ${False}
    ...   *Example*
    ...   | ${is_installed} |  _Is Koredump Tool Installed | ne_type=vdu |
    ${is_installed}    set variable    ${False}
    ${ns}  Run Keyword If  "${ne_type}"=="vdu"  Get vDU Namespace From TestLine
    ...  ELSE IF  "${ne_type}"=="vcu"  Get Cu Namespace From TestLine
    ${alias}  get unique id
    ${alias}  Run Keyword If  "${ne_type}"=="vdu"  Connect To K8s Master Interactively    alias=${alias}
    ...  ELSE IF  "${ne_type}"=="vcu"  Connect To CU K8S Master With Tenant    gnb_index=${gnb_index}

#    ${cmd}  set variable  koredumpctl status | grep Running | wc -l
#    ${cmd_2}  set_variable  koredumpctl status | grep koredump-ds | wc -l
    ${cmd}  set variable  koredumpctl status 2>&1 | grep Running | wc -l
    ${cmd_2}  set_variable  koredumpctl status 2>&1 | grep koredump-ds | wc -l
    ${koredump_r}  ${output_1}   run keyword and ignore error   issh.execute  command=${cmd}  alias=${alias}
    ${output_1}   Strip Prompt   ${output_1}
    ${Running_pod}    Get Regexp Matches   ${output_1}   \\d+
#    Return From Keyword If   """command not found""" in """${output_1}"""   ${False}
    Return From Keyword If   ${output_1}==0   ${False}
    ${koredump_r_2}  ${output_2}   Run Keyword If    '${koredump_r}'=='PASS'
    ...   run keyword and ignore error   issh.execute  command=${cmd_2}  alias=${alias}
    ${output_2}   Strip Prompt   ${output_2}
#    Return From Keyword If   """command not found""" in """${output_2}"""   ${False}
    Return From Keyword If   ${output_2}==0   ${False}
    ${koredump_ds_pod}    Get Regexp Matches   ${output_2}   \\d+
    ${koredump_pod}   evaluate   ${koredump_ds_pod[0]}+1
    ${is_installed}   set variable if   "${Running_pod[0]}"=="${koredump_pod}"   ${True}    ${False}
    [Return]   ${is_installed}
    [Teardown]  issh.disconnect  alias=${alias}


NE Collect Coredump Log
    [Arguments]  ${ne_type}   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  NE Collect Coredump Log
    ...   *Author*: hongyuan.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2022-4-13 | hongysun | initial creation |
    ...   | 2023-3-1 | r3li | update |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | ne_type | Yes | support vcu, vdu |
    ...   | gnb_index  |  no | gnb index, default is 0 |
    ...   | vdu_index  |  no | VDU index, default is 0 |
    ...
    ...   *Return*
    ...   local file path
    ...   *Example*
    ...   | ${local_filepath} | NE Collect Coredump Log | ne_type=vdu |
    ${ns}  Run Keyword If  "${ne_type}"=="vdu"  Get vDU Namespace From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ...  ELSE IF  "${ne_type}"=="vcu"  Get Cu Namespace From TestLine  gnb_index=${gnb_index}
    ${alias}  get unique id
    ${alias}  Run Keyword If  "${ne_type}"=="vdu"  Connect To K8s Master Interactively   gnb_index=${gnb_index}
    ...  vdu_index=${vdu_index}    alias=${alias}
    ...  ELSE IF  "${ne_type}"=="vcu"  Connect To CU K8S Master With Tenant   gnb_index=${gnb_index}

    ${output}  wait until keyword succeeds    1min    20s   _Get Koredump List Success   ns=${ns}   alias=${alias}
    ${local_filepath}  Run Keyword If  """Nothing found.""" not in """${output}""" and """command not found""" not in """${output}"""
    ...  _Collect Coredump Log via Koredump
    ...  ns=${ns}  alias=${alias}
    [Return]  ${local_filepath}
    [Teardown]  issh.disconnect  alias=${alias}


_Get Koredump List Success
    [Arguments]  ${ns}  ${alias}=default
    ${output}   set variable    ${empty}
    ${cmd}  set variable  koredumpctl list -n ${ns}
    ${out}  issh.Execute  command=${cmd}  alias=${alias}
    ${output}  strip prompt  ${out}
    should not contain    ${output}   Unable to listen
    [return]    ${output}


_Collect Coredump Log via Koredump
    [Arguments]  ${ns}  ${alias}=default
    ${tmp_dir}   set variable  tmp_corelog_${ns}
    ${cmd}  set variable  rm -rf ${tmp_dir}
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${cmd}  set variable  mkdir ${tmp_dir} && cd ${tmp_dir}
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${output}   wait until keyword succeeds    2min    30s   _Get Koredump List Details Success   ns=${ns}   alias=${alias}
    ${core_dump_list}  get_core_dump_info   info=${output}   start_time=${START_UTC_TIMESTAMP}
    ${length}   get length   ${core_dump_list}
    ${local_filepath}    Run Keyword If  ${length}>0   _Collect Coredump   core_dump_list=${core_dump_list}
    ...    alias=${alias}
    [Return]  ${local_filepath}


_Get Koredump List Details Success
    [Arguments]  ${ns}  ${alias}=default
    ${cmd}  set variable  rm -rf nohup.out
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${cmd}  set variable  nohup koredumpctl list -n ${ns} &
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    Send ENTER Interactively   alias=${alias}
    sleep    1
    ${check_cmd}   Set Variable   ps -ef | grep koredumpctl | grep ${ns}
    Wait Until Keyword Succeeds   30s   3s   _Check Coredump Collect IS Done   ${check_cmd}   ${alias}
    ${cmd}  set variable  cat nohup.out
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${output}  strip prompt  ${out}
    should not contain    ${output}   Unable to listen
    [return]    ${output}


_Check Coredump Collect IS Done
    [Arguments]   ${check_cmd}   ${alias}
    ${out}   issh.execute   command=${check_cmd}   alias=${alias}    check_result=${False}
    ${out}   strip prompt  ${out}
    should be empty   ${out}


_Collect Coredump
    [Arguments]   ${core_dump_list}   ${alias}=default
    FOR  ${core_dump}  IN  @{core_dump_list}
        log to console    ${core_dump['details']}
        _Collect Single Coredump     node=${core_dump['Node']}   coredump_id=${core_dump['ID']}   alias=${alias}
        Sleep   0.2
    END
    ${cmd}  set variable  nohup tar -cvf coredumplog.gz *.lz4 &
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    Send CTRL_C Interactively  alias=${alias}
    Wait Until Keyword Succeeds  10s  2s  _Check Collect Coredump Log Result  alias=${alias}
    ${remote_path_tmp}  issh.execute  command=pwd  alias=${alias}
    ${remote_path}  strip prompt  ${remote_path_tmp}
    ${take_time_tmp}  issh.Execute  command=date +"%Y-%m-%d %H:%M:%S"  alias=${alias}
    ${take_time}  strip prompt  ${take_time_tmp}
    ${local_filepath}   get a Directory   coredump_log_${take_time}
    issh.download_file  remote_path=${remote_path}/coredumplog.gz
    ...  local_path=${local_filepath}/coredumplog.gz  alias=${alias}
    Fail  There is core dump files!
    Set test variable   ${TEST_STATUS}    FAIL
    [Return]  ${local_filepath}


_Collect Single Coredump
    [Arguments]  ${node}   ${coredump_id}   ${alias}=default
    ${cmd}  set variable  nohup koredumpctl get ${node} ${coredump_id}
    ${out}  issh.execute  command=${cmd}  alias=${alias}   check_result=${False}
    Send CTRL_C Interactively  alias=${alias}
    Wait Until Keyword Succeeds  600s  5s  _Check Collect Coredump Log Result  alias=${alias}


_Check Collect Coredump Log Result
    [Arguments]  ${alias}=default
    ${cmd}  set variable  cat nohup.out | wc -l
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${out1}  strip prompt  ${out}
    sleep  3s
    ${out}  issh.execute  command=${cmd}  alias=${alias}
    ${out2}  strip prompt  ${out}
    should be true  ${out1}==${out2}




Truck Roll Needed
   [Documentation]  Truck Roll needed or not via checking cu or vdu has anomalous alarms
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   *History Change*
    ...   | 2022-12-12 | lingtsun | initial creation |
    ${is_truck_roll}   set variable   ${False}
    ${gnb_numbers}    Get Gnb Numbers
    ${expected_fault_list_cu}    Create List    10    16    1806   1868    4341    4352    4383
    FOR  ${gnb_index}  IN RANGE  ${gnb_numbers}
        CU Login   gnb_index=${gnb_index}   alias=get_cu_alarms_for_truck_roll
        ${active_alarms}   cu.get_active_alarms  paging=${False}   connection=get_cu_alarms_for_truck_roll
        ${is_truck_roll}   Check Anomalous Alarms Is Appear   active_alarms=${active_alarms}   expected_fault_list=${expected_fault_list_cu}
        exit for loop if    '${is_truck_roll}'=='${True}'
        ${vdu_numbers}   Get DU Numbers   ${gnb_index}
        ${is_truck_roll}   run keyword if  '${vdu_numbers}'>'0'
        ...  _Check Anomalous Alarms Is Appear on vDUs    gnb_index=${gnb_index}   vdu_numbers=${vdu_numbers}
    END
    [Return]    ${is_truck_roll}


_Check Anomalous Alarms Is Appear on vDUs
    [Arguments]    ${gnb_index}   ${vdu_numbers}
#    ${expected_fault_list}    Create List    10    16     1806    1868    4341    4352    4383    4350
    ${expected_fault_list}    Create List    10     1806    4341    4352    4383
    FOR  ${vdu_index}  IN RANGE  ${vdu_numbers}
        VDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}   alias=get_vdu_alarms_for_truck_roll
        ${active_alarms}   vdu.vdu_get_active_alarms  paging=${False}   vdu_connection=get_vdu_alarms_for_truck_roll
        ${is_truck_roll}   _Check Anomalous Alarms Is Appear   active_alarms=${active_alarms}  expected_fault_list=${expected_fault_list}
        exit for loop if    '${is_truck_roll}'=='${True}'
    END
    [Return]    ${is_truck_roll}


_Check Anomalous Alarms Is Appear
    [Arguments]    ${active_alarms}   ${expected_fault_list}
    ${status}=   set variable   ${False}
    ${actual_fault_id_list}   create list    ${EMPTY}
    FOR    ${index}    IN RANGE    ${active_alarms["total"]}
        append to list    ${actual_fault_id_list}     ${active_alarms['alarms'][${index}]['fault_id']}
    END
    ${anomalous_alarm_list}   evaluate   set(${expected_fault_list})&set(${actual_fault_id_list})
    ${length}   get length   ${anomalous_alarm_list}
    run keyword if   '${length}'>'0'   log to console    Anomalous_alarm_list: ${anomalous_alarm_list}
    ${status}   set variable if   '${length}'=='0'    ${False}   ${True}
    [Return]    ${status}


_Truck Roll Check And Action
    [Arguments]    ${is_truck_roll_needed}
    run keyword if    "${is_truck_roll_needed}"=="${True}"     _Stop And Fix


_Stop And Fix
    ${cfg_dir}     set variable    ${tl.gnbs[0].cloud_deployment.default_cfg_dir}
    ${init_file_path}    Join Path    ${cfg_dir}    __init__.py
    ${ret}    Grep File    ${init_file_path}    __owner_email__
    ${email_split}    String.Split String    ${ret}    =
    ${owner_email}    Set Variable    ${email_split[1].strip().strip('"').strip("'")}
    ${mail_recipents}    Set Variable    xiaofei.ni@nokia-sbell.com;${owner_email}
    ${testline_name}  set variable    ${cfg_dir.split("/")[-1]}
    ${subject}    Set Variable    StopFix Triggered On Testline ${testline_name}, please check it ASAP!!!
    ${content}    Set Variable    Suite Name: ${SUITE NAME}, Case Name: ${TEST NAME}, Testline Name: ${testline_name}
    ${ute_cloud_notify_cmd}    Set Variable    echo "put /opt/ute/execution.context.json \$\{CM_EXECUTION_ID\}.json"
    ${ute_cloud_notify_cmd}    Set Variable    ${ute_cloud_notify_cmd} | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/
    OperatingSystem.Run    ${ute_cloud_notify_cmd}
    ${mail_cmd}    Set Variable    curl http://10.109.2.191:8888/job/send_mail_tool/buildWithParameters
    ${mail_cmd}    Set Variable    ${mail_cmd} --user jinbyu:11c26786915c16a5d9fc377e55e9e116a0 --data SUBJECT='${subject}'
    ${mail_cmd}    Set Variable    ${mail_cmd} --data RECIPIENTS='${mail_recipents}' --data CONTENT='${content}'
    OperatingSystem.Run    ${mail_cmd}
    sleep    359200    # 72 hours


Is Run In TearDown
    [Documentation]  Is keyword running in case test teardown
    ...   *Author*: lingting.sun@nokia-sbell.com
    ...   | 2023-03-31 | lingtsun | initial creation |
    ...   *Return*
    ...   is_in_case_teardown, ${True} or ${False}
    ${is_in_case_teardown}    Run Keyword And Return Status    Variable Should Exist     ${TEST_STATUS}
    [Return]    ${is_in_case_teardown}
