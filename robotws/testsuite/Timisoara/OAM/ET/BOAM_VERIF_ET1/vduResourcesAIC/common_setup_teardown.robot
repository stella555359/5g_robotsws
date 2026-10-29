*** Settings ***
Documentation




*** Variables ***
${AICLOG}         1
${AIC_SELF_CHECK}   1
${RECOVER}         0

*** Keywords ***
############################## Common Setup Start ##############################
====== Common Setup KW Start ======
     log to console  \n*** only used for readable ***

AiC Common Suite Setup
    [Documentation]    Do some common things for every precondition of cases
    ...    any case should include it in suite setup or test setup
    ...    it will do following actions
    ...    1) kill unexpected process
    ...    3) _Check Installed Packages
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    2019-11-15 first version for framework
    #_Kill Unexpected Process
    _Check Installed Packages
    Run Keyword And Ignore Error    _Init TRS Global Variable


AiC Common Test Setup
    [Teardown]  run keyword and ignore error  disconnect all ssh connections
    [Documentation]    Do some common things for every precondition of cases
    ...    any case should include it in suite setup or test setup
    ...    it will do following actions
    ...    1) kill unexpected process
    ...    2) import static test line variables and convert to readable variables
    ...    3) automatically get some deployment information from test line
    ...    4) add one folder for test cases -- logs, cm files, download files...
    ...    5) backup SCF from test line for traceablity
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    2019-11-15 first version for framework
    ...
    set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}    0
    set test variable    ${UTE_SSH_IP}    ${tl.test_pc.default_ssh_connection_details.addr}
    set test variable   ${UTE_SSH_USER_NAME}  ${tl.test_pc.default_ssh_connection_details.username}
    set test variable   ${UTE_SSH_PASSWORD}     ${tl.test_pc.default_ssh_connection_details.password}
    run keyword and ignore error    _Init Nom Server Global Variable

    _Create Logs Folder For Test Case

    run keyword and ignore error  Clear Agent Flag
    run keyword and ignore error  _Delete Core Dump Files

    run keyword if   ${AIC_SELF_CHECK}==1  _Self Check Script And Configuration
    _Kill Unexpected Process
    set_vdu_pod_container_suite_variables

    ${vcu_nf_type}   Get VCU NF Type
#    run keyword if  "${vcu_nf_type}"=="CNF"   _Set CU Pod And Container Name Prefix
    run keyword if  "${vcu_nf_type}"=="CNF"   Run Keyword And Ignore Error   _VCU CNF Environment WA

    set test variable   ${AIC_COMMON_TEST_SETUP_EXECUTED_FLAG}    1

    run keyword and ignore error    online enable actcli for cu
    run keyword and ignore error    Online Enable actCli For vDU


AiC Common Suite Teardown
    [Documentation]    Do some common things for every postcondition of suite
    ...    any suite should include it in suite teardown
    ...    it will do following actions
    ...    1) disable log collection
    ...    2) release resource
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    log to console  *** AiC Common Suite Teardown, tbd ***


AiC Common Test Teardown
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
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
    log to console  *** AiC Common Test Teardown, tbd ***

    _Check Core Dump Files And Download it And Fail The Case If It Has

    ${capture_log}   Get Capture Log Flag
    #${capture_log}   Set Variable   1

#    run keyword if   ${capture_log}==1   Run Keyword If Test Failed   Collect All Logs In Teardown  vdu_index=${vdu_index}  gnb_index=${gnb_index}
#    ${file}   get a file   vdu_alarm_teardown   active_alarm.txt
#    run keyword and ignore error   VDU Save Active Alarm To A File   file_name=${file}   vdu_index=${vdu_index}
#
#    ${file}   get a file   vdu_alarm_teardown   historical_alarm.txt
#    run keyword and ignore error    VDU Save Historical Alarm To A File   file_name=${file}   vdu_index=${vdu_index}

      run keyword and ignore error
     ...   Collect All Logs In Teardown Optimized   capture_log=${capture_log}  vdu_index=${vdu_index}  gnb_index=${gnb_index}


Collect All Logs In Teardown
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    run keyword and ignore error   Collect VDU Describe PODs Log   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    run keyword and ignore error   Collect vDU Kubectl Logs   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    run keyword and ignore error   Collect VDU Start Up Log
    run keyword and ignore error   Collect VDU Infrastructure Log
    run keyword and ignore error   Save Local Snapshot    local_snapshot_location=snapshot_teardown


Collect All Logs In Teardown Optimized
    [Arguments]  ${capture_log}=0    ${gnb_index}=0 #${vdu_index}=0
    ${full_testline_config_folder}   Get Full TestLine Name From TestLine
    ${robot_file}   Set Variable   ${CURDIR}/utility_robot/ta_utility.robot

    ${tmp_log_root_folder}   Set Variable  /tmp/tmp_logs
    OperatingSystem.Remove Directory    ${tmp_log_root_folder}   recursive=True
    OperatingSystem.Create Directory    ${tmp_log_root_folder}

    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt
    ${active_alarm_file}   get a file   vdu_alarm_teardown   active_alarm.txt
    ${historical_alarm_file}   get a file   vdu_alarm_teardown   historical_alarm.txt

    log to console   Test Result:${TEST_STATUS}
    #${ta_utility_case_name}   Set Variable If  ${capture_log}==1 and "${TEST_STATUS}"=="FAIL"   logs   set_agent_flag
    ${ta_utility_case_name}   Set Variable If  ${AICLOG}==0   return_immediately
        ...   ${capture_log}==1 and "${TEST_STATUS}"=="FAIL"   logs   set_agent_flag
    Return From Keyword If  "${ta_utility_case_name}"=="return_immediately"

    ${cmd}   Set Variable   robot -t ${ta_utility_case_name}
    ${cmd}   Set Variable   ${cmd} -v gnb_index:${gnb_index} -v gnb_index:${gnb_index} -v agent_flag_file:${agent_flag_file}
    ${cmd}   Set Variable   ${cmd} -v active_alarm_file:${active_alarm_file} -v historical_alarm_file:${historical_alarm_file}
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
    Run Keyword And Ignore Error  Recover Environment
    Run Keyword And Ignore Error  Disconnect All SSH Connections
    Run Keyword And Ignore Error  Vdu Rest Logout
    Run Keyword And Ignore Error  CU Rest Logout


_Init Nom Server Global Variable
    [Documentation]   _Init Nom Server Global Variable
    ...
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ############## start of NOM4 ##################
    ${nom}   _Get NOM Server Information By Label    label=NOM4
    Set Test Variable   ${NOM_1_SSH_IP}           ${nom["ssh_ip"]}
    Set Test Variable   ${NOM_1_SSH_USERNAME}     ${nom["ssh_user"]}
    Set Test Variable   ${NOM_1_INTEGRATE_LINK}   ${nom["integrate_link"]}

    Set Test Variable   ${NOM_1_SSH_IP_MASK_LEN}   ${nom["ssh_ip_mask_len"]}

    # ----------  NOM webui link info -----------------
    Set Test Variable   ${NOM_1_WEBUI_LINK}        ${nom["webui_link"]}

    Set Test Variable   ${NOM__1_VERSION}    ${nom["version"]}
    #Set Test Variable   ${NOM_1_CA_FILE}       ${nom["ca_file"]}
    #Set Test Variable   ${NOM_1_CA_SN}       ${nom["ca_sn"]}
    #Set Test Variable   ${NOM_1_CA_ID}       ${nom["ca_id"]}

    # ----------  NOM PM FILE SFTP server part -----------------
#    Set Test Variable   ${NOM_PM_SFTP_SERVER}       ${nom["pm_sftp_ip"]}
#    Set Test Variable   ${NOM_PM_SFTP_USERNAME}     ${nom["pm_sftp_username"]}
#    Set Test Variable   ${NOM_PM_SFTP_PASSWORD}     ${nom["pm_sftp_password"]}
#    Set Test Variable   ${NOM_PM_SFTP_ROOT_PATH}    ${nom["pm_sftp_root_path"]}


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

    Set Test Variable   ${NOM_10_VERSION}    ${nom["version"]}

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
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${alias}
    ${alias}  Connect To CU K8S Master With Admin

    #delete tmp folder
    ${ns}  get vdu namespace from testline
    ${cu_ns}   Get CU Namespace From TestLine
    ${tmp_foler_name}  set variable  /tmp/tmp_taic_${ns}_${cu_ns}
    ${out}   issh.Execute  command=sudo chmod 777 -R ${tmp_foler_name}   check_result=False  alias=${alias}
    ${out}   Run Keyword If   ${ns.__len__()}>0 and ${cu_ns.__len__()}>0
    ...   issh.Execute   command=sudo rm -rf ${tmp_foler_name}   alias=${alias}

    _VCU Environment WA For OCP   ${alias}


Collect vDU Kubectl Logs
    [Documentation]  Collecting vdu logs including container coredump log, kubelog and log files under container
    ...    tmp directory
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    [Arguments]  ${vdu_index}=0  #${gnb_index}=0
    log to console  Collect vDU Kubectl Logs
    ${log_path}=  Collect vDU Container Logs On All Pods    vdu_index=${vdu_index}
    [Return]   ${log_path}


Collect vDU Container Logs On All Pods
    [Arguments]   ${vdu_index}=0
    [Documentation]  Collect vDU Container Logs On All Pods, it is called in 'Aic Common Test Teardown' only
    ...    *AUTHOR* unknown
    ...    history change: <date>,<who>,<what and how>
    ...    16.8.2021,xxx@nokia-sbell.com, author is unknown
    ...    16.8.2021,chris.l.cao@nokia-sbell.com, add change history, change from helm lib to issh library
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Collect vDU Container Logs On All Pods |
    ...
    #vDU Cluster Login With Tenant  ${vdu_index}
    #${pods_name_list}=  get_vdu_pods_name_list    namespace=${EMPTY}
    #helm.helm_master_close

    ${timestamp}=  get time   exclude_millis=yes
    ${timestamp}=  replace string   ${timestamp}   ${SPACE}     _
    ${timestamp}=  replace string    ${timestamp}  -   _
    ${timestamp}=  replace string   ${timestamp}  :   _
    ${container_log_path}=   get a Directory    container_logs_${timestamp}
    ${duration}   Get Case Running Duration

    ${vdu_pod_info}   get_vdu_pods_container_mapping
    ${pods_name_list_abbr}  evaluate  list(${vdu_pod_info})

    ${container_name}  set variable   all
    FOR  ${pod}  IN  @{pods_name_list_abbr}
      Collect vDU Container Logs On Given Pod   ${pod}  ${container_name}  ${vdu_index}
    ...    duration=${duration}  target_path=${container_log_path}
    END
    [Return]   ${container_log_path}


Reinstall VDU By Agent
    [Arguments]  ${build_number}=${EMPTY}
    [Documentation]  Reinstall VDU By Agent
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    |  Reinstall VDU By Agent |
    ...
    ${tl_config_path}  Get TestLine Config Directory From TestLine
    Run Agent To Recover Environment   ${tl_config_path}  build_number=${build_number}   # target_state=${target_state}


Recover Environment
    [Documentation]  Recover Environment
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
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
    return from keyword if   "${r}"=="PASS" and "${ute_type}"=="JENKINS"

    log to console  Recover Environment...
    ${agent_flag_file}   OperatingSystem.Join Path   ${OUTPUT_DIR}   agent_flag.txt

    ${r}   ${found}   Run Keyword And Ignore Error      OperatingSystem.File Should Exist   ${agent_flag_file}
    return from keyword if  "${r}"!="PASS"

    ${need_deploy}	 OperatingSystem.Run 	cat ${agent_flag_file}|awk -F '=' '{print $2}'

    ${tl_config_path}  Get TestLine Config Directory From TestLine

     run keyword if   ${need_deploy}==1   Run Agent To Recover Environment   ${tl_config_path}


Run Agent To Recover Environment
    [Arguments]    ${tl_config_path}   ${build_number}=${EMPTY}   ${target_state}=${EMPTY}
    [Documentation]  Run Agent To Recover Environment
    ...    *AUTHOR* jinbo.yu@nokia-sbell.com
    ...    2.8.2021,chris.l.cao@nokia-sbell.com, add to support build_number, add assertion for real_specific_vdu_build
    ...    7.12.2021,chris.l.cao@nokia-sbell.com, add description after https://jira3.ext.net.nokia.com/browse/CS-1570 was fixed.
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | tl_config_path | yes | tl_config_path |
    ...    | build_number  | No | build_number, default is ${EMPTY} |
    ...    | target_state  | No | target_state, default is ${EMPTY}, ${EMPTY} means re-deploy both vcu and vdu to make them on-air |
    ...
    ...  Note: target_state can refer to https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1268202142
    ...
    ...   on_air — agent will do deployment and commission to VDU/VCU, and make sure whole BTS on air
    ...   sw_uploaded — currently, it's same to skip_agent
    ...   gnb_not_commissioned — just do VDU/VCU deployment
    ...   vdu_deploy — just do VDU deployment
    ...   vdu_commissioned — VDU deployment and commission
    ...   vdu_on_air — agent will do deployment and commission to VDU, and make sure whole BTS on air
    ...   vcu_deploy — just do VCU deployment
    ...   vcu_commissioned — VCU deployment and commission
    ...   vcu_on_air — agent will do deployment and commission to VCU, and make sure whole BTS on air
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
    ${default_target_state}  set variable  on_air
    ${target_state_env}  get_environ_value   TARGET_STATE
    ${real_specific_vdu_build}   set variable if   "${build_number}"=="${EMPTY}"   ${default_specific_vdu_build}   5G_${build_number}
    ${target_state_env}   set variable if   "${target_state_env}"=="${EMPTY}"   ${default_target_state}   ${target_state_env}
    ${real_target_state}   set variable if   "${target_state}"=="${EMPTY}"   ${target_state_env}   ${target_state}

    should not be empty   ${real_specific_vdu_build}
    should not be empty   ${real_target_state}

    ${result}=    Run Keyword And Ignore Error    Environment Variable Should Be Set    JENKINS_URL
    ${agent_cmd_pre}=   Set Variable   agent_5g_aic init -l 'CLOUD_5G_AIC'
    ${agent_cmd}=    Set Variable
    ...    ${agent_cmd_pre} -b ${real_specific_vdu_build} -o 'output' -s ${real_target_state} -R 'testline_init_results/' -p ${tl_config_path}
    ${agent_cmd}=    Set Variable    export JENKINS_URL=https://localhost:8080 && ${agent_cmd}
    Run Keyword If    '${result[0]}'=="PASS"    OperatingSystem.Run    bash -c "source /opt/ute/agent_env_py3/bin/activate && ${agent_cmd}"
    ...    ELSE    OperatingSystem.Run    bash -c "source /opt/ute/agent_env/bin/activate && ${agent_cmd}"


Collect vDU Container Logs On Given Pod
    [Arguments]  ${pod_name}  ${container_name}=all  ${vdu_index}=0  ${duration}=13   ${target_path}=${EMPTY}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Documentation]  Collect vDU Container Logs On Given Pod
    ...    *AUTHOR* unknown
    ...    history change: <date>,<who>,<what and how>
    ...    16.8.2021,xxx@nokia-sbell.com, author is unknown
    ...    16.8.2021,chris.l.cao@nokia-sbell.com, add change history, change from helm lib to issh library
    ...    23.11.2021,chris.l.cao@nokia-sbell.com, add change history, optimize code to shorten collecting time
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...    None.
    ...
    ...    Example
    ...    | Collect vDU Container Logs On Given Pod | pod_name=cprt |  container_name=all |
    ...
    ${timestamp}=  get time   exclude_millis=yes
    ${timestamp}=  replace string   ${timestamp}   ${SPACE}     _
    ${timestamp}=  replace string    ${timestamp}  -   _
    ${timestamp}=  replace string   ${timestamp}  :   _

    ${local_log_file_path}=  run keyword if   '${target_path}'=='${EMPTY}'   Get A File
    ...    container_logs_${timestamp}   ${pod_name}_${container_name}_test.log
    ...    ELSE   get a file     ${target_path}     ${pod_name}_${container_name}_test.log

    ${alias}   get unique id
    connect to k8s master interactively  alias=${alias}
    ${pod_prefix}   Get Pod Name Prefix  vdu_index=${vdu_index}
    ${has_pod_prefix}  set variable  ${pod_name.startswith("${pod_prefix}")}

    ${pod_name}  run keyword if   "${has_pod_prefix}"=="${True}"  set variable  ${pod_name}
    ...   ELSE   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_name}   alias=${alias}   vdu_index=${vdu_index}

    ${ns}  get vdu namespace from testline   vdu_index=${vdu_index}

    ${full_container_name}  run keyword if   '${container_name}'!='all'
        ...   Get Full Container Name By Container Abbreviation     ctr_abbr=${container_name}  vdu_index=${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container_name}'=='all'
        ...  set variable  kubectl logs ${pod_name} --all-containers=true --since=${duration}m -n ${ns}
    ...  ELSE
        ...   set variable  kubectl logs ${pod_name} -c ${full_container_name} --since=${duration}m -n ${ns}

    ${remote_log_file_name}   set variable   ${pod_name}_${container_name}_test.log

#    ${cmd}=  set variable   nohup ${function_cmd} > ./${remote_log_file_name} 2>&1 &
#    ${result}=  issh.execute  ${cmd}  alias=${alias}
#    Wait Until Process Disappear With Expected String   expected_string=${function_cmd}   alias=${alias}  duration=10min  interval=2

    ${cmd}=  set variable   ${function_cmd} > ./${remote_log_file_name}
    ${old_timeout}    issh.set_timeout  600   alias=${alias}
    ${result}  issh.execute  ${cmd}    alias=${alias}
    issh.set_timeout  ${old_timeout}   alias=${alias}
    ${result}  issh.execute  sync    alias=${alias}

    issh.download_file  remote_path=./${remote_log_file_name}
    ...  local_path=${local_log_file_path}   alias=${alias}
    issh.execute  rm -rf ./${remote_log_file_name}    alias=${alias}

	[Return]   ${local_log_file_path}


Collect vDU Coredump Logs In One Node
    [Documentation]  collect vdu coredump logs in one node
    ...   *Author*  calla.wang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...	  | node_ip | Yes. | node ip that pod located |
    ...   | coredump_log_file_name | Yes. | the log file name that will be stored in local |
    ...   | vdu_index | Yes. | the vdu index default is 0 |
    ...   *Return Value*
    ...   None
    [Arguments]  ${node_ip}  ${coredump_log_file_name}   ${vdu_index}=0  ${gnb_index}=0
    ${proxy}=   Create Dictionary
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    ...  user=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ${executor}=  Create Dictionary
    ...  host=${node_ip}
    ...  user=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    ...  proxy=${proxy}
    simple_collect.create_simple_collector
    ...    name=coredump
    ...    dir_path=/tmp/cdump/
    ...    file_pattern=.*core.*
    ...    executor=${executor}
    ...    target_file_name=${coredump_log_file_name}
    ...    sudo_password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    core_collect.setup_collectors   names=coredump
    core_collect.collect_collectors    names=coredump    target_dir=${SUITE_LOG_DIRECTORY}
    core_collect.teardown_collectors  names=coredump


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
    core_collect.collect_collectors    names=kubelog    target_dir=${SUITE_LOG_DIRECTORY}
    core_collect.teardown_collectors    names=kubelog
    [return]    ${SUITE_LOG_DIRECTORY}kubelog/


Collect vDU Container Logs In All Pods
    [Arguments]  ${container_name}=all  ${vdu_index}=0
    vDU Cluster Login With Tenant  ${vdu_index}
    ${pods_name_list}=  get_vdu_pods_name_list    namespace=${EMPTY}
    helm.helm_master_close
    FOR  ${pod}  IN  @{pods_name_list}
      Collect vDU Container Logs In Given Pod  ${pod}  ${container_name}  ${vdu_index}
    END


Collect vDU Container Logs In Given Pod
    [Arguments]  ${pod_name}  ${container_name}=all  ${vdu_index}=0
    ${local_log_file_path}=   Get A File  ContainerLogs  ${pod_name}_${container_name}_test.log
    ${conn}=  vDU Cluster Login With Tenant  ${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container_name}'=='all'
    ...  set variable  kubectl logs ${pod_name} --all-containers=true
    ...  ELSE  set variable  kubectl logs ${pod_name} -c ${container_name}
    ${cmd}=  set variable   nohup ${function_cmd} > ./${pod_name}_${container_name}_test.log 2>&1 &
    ${result}=  tafssh.send_command  ${cmd}  connection=${conn}
    wait until keyword succeeds  10min  5s  _Check Collecting vDU Container Logs Finished  ${function_cmd}
    tafssh.download_file  remote_path=./${pod_name}_${container_name}_test.log
    ...  local_path=${local_log_file_path}   connection=${conn}
    tafssh.execute  rm -rf ./${pod_name}_${container_name}_test.log
	[Return]   ${local_log_file_path}
    [Teardown]    helm.helm_master_close


_Check Collecting vDU Container Logs Finished
    [Arguments]  ${process_cmd}
    ${result}=  tafssh.execute  ps -ef|grep "${process_cmd}"|grep -v grep
    should not contain  ${result}   ${process_cmd}


_Create Logs Folder For Test Case
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}


_Kill Unexpected Process
    log to console  *** _Kill Unexpected Process ***
    #run process    taskkill /f /im chromedriver.exe    shell=True
    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True

    FOR  ${keyword}  IN   firefox   geckodriver
       ${out}   Run Process   ps -ef | grep ${keyword} | grep -v grep | awk '{print $2}' | xargs kill -9   shell=True
    END

     run process   rm -rf /tmp/taf_selenium*    shell=True
     run process   rm -rf /tmp/rust_mozprofile*; sudo rm -rf /tmp/systemd-private-*; rm -rf /tmp/tmp*;rm -rf /tmp/Temp-*;  shell=True


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
    ${matches}   get regexp matches  ${SUITE_NAME}   ^[0-9a-zA-Z_\\s-]+$
    should be true  ${matches}   Suite name should consist of 0-9a-zA-Z_-


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
    ${prompt}  set variable if  ${num_author}!=${num_cases}  every case should have 'author: <your_mail_id>@nokia-sbell.com' in *** Test Cases ***
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
    ${prompt}  set variable   please refer to:https://wrgitlab.int.net.nokia.com/5G/robotws5g/
    ${prompt}  set variable   ${prompt}blob/master/testsuite/AIC/Reference_Test_Case_Template.robot
    log to console   ${prompt}


_Self Check Tags
    [Documentation]   _Self Check Tags
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    04.12.2021, chris.l.cao@nokia-sbell.com, add VDU_PRIVILEGE_TRUE tag
    ...    09.12.2021, chris.l.cao@nokia-sbell.com, remove VDU_PRIVILEGE_TRUE tag
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ${known_tag_list}   create list
    ...    CIT    QT   CRT   CDRT
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV4__WITH__STATE_ON_AIR
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV4__WITH__STATE_ON_AIR
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV4__WITH__STATE_GNB_NOT_COMMISSIONED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV4__WITH__STATE_GNB_NOT_COMMISSIONED
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV4__WITH__STATE_GNB_COMMISSIONED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV4__WITH__STATE_GNB_COMMISSIONED

    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV6__WITH__STATE_ON_AIR
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV6__WITH__STATE_ON_AIR
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV6__WITH__STATE_GNB_NOT_COMMISSIONED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV6__WITH__STATE_GNB_NOT_COMMISSIONED
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV6__WITH__STATE_GNB_COMMISSIONED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_IPV6__WITH__STATE_GNB_COMMISSIONED

    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_ON_AIR
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_ON_AIR
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_SW_UPLOADED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_SW_UPLOADED
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_GNB_NOT_COMMISSIONED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_SGNB_NOT_COMMISSIONED
    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_GNB_COMMISSIONED
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_UE__WITH__STATE_SGNB_COMMISSIONED

    ...    CIT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_NCS_NCIR_3xAHCA_Android__WITH__STATE_ON_AIR
    ...    CRT__WITH__MASTER_VDU__WITH__CLOUD_5G_AIC_NCS_NCIR_3xAHCA_Android__WITH__STATE_ON_AIR

    ...    CLOUD_5G_AIC_MULTICELLS
    ...    CLOUD_5G_AIC_IPV4   CLOUD_5G_AIC_IPV6   CLOUD_5G_AIC_UE   CLOUD_5G_AIC_NCS_NCIR_3xAHCA_Android
    ...    STATE_ON_AIR   STATE_SW_UPLOADED  STATE_GNB_NOT_COMMISSIONED   STATE_GNB_COMMISSIONED

    ...    CLOUD_5G_AIC                                                   #Test_Line_Type
    ...    5G_RAN                                                         #Product
    ...    RAN_5G
    ...    RAN_PZ_HAZ_1    RAN_PZ_HAZ_2                                   #used by UTE Cloud, 2021.7.27
    ...    master_allincloud_int                                          #vDU_Branch_name
    ...    5G_SW_AiC_SI_HZ     MN_5G&SC_5G_SW_Eng_AiC_Sol_Int             #Orginazation
    ...    5G_SW_AiC_SOLINT_ESP_1   5G_SW_AiC_SOLINT_ESP_2                #Orginazation of ESPOO, 2021.3.15
    ...    CA_5G_SISO  CA_5G_RRM  CA_5G_TRS  CA_5G_OAM  CA_5G_CLOUD   CA_RAN_PZ_HAZ_2     #CA
    ...    5G_SW_AiC_SOLINT_ESP                                           #CA of ESPOO, 2021.3.15
    ...    TA_LEVEL_12_Partly_AUTOMATED  TA_LEVEL_20_90%_AUTOMATED  TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT    #Detailed Automation Level
    ${out}   List Contain Another List  ${known_tag_list}   ${TEST_TAGS}
    run keyword if   "${out}"!="${True}"   _Print General Prompt Message For Self Check
    should be true    ${out}  Unknown TAGs used, we should use known TAGs:${known_tag_list}


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
    [Arguments]  ${scf_file_name}   #${vdu_index}=0
    [Documentation]  vDU Rest Logout
    ...  history change:
    ...  author:calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  4.09.2020,chris.l.cao@nokia-sbell.com, add check for OAM up or down
    ...
    ${backup_scf_path}=  Get A Directory  BackupSCF
    vDU Login
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

_Get Target NOM Server Index
    [Documentation]
    ...    will chose the useful NOM and return the nom id
    ...    *AUTHOR* jie.8.liu@nokia-sbell.com
    ...    modified by:        <13-Oct-2021>, <huilxu>, <NOM Detect Rest Login>
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Index of desire target NOM server and target nom server

    ${all_nom_list}      get_all_nom_server
    ${nom_count}=    Get Length    ${all_nom_list}
    FOR    ${nom_index}    IN RANGE    ${nom_count}
        ${status}     Run Keyword and Return Status    _NOM Detect Rest Login    ${all_nom_list[${nom_index}]}
        Exit For Loop If    "${status}"=="True"
        log to console      ${status}
    END
    Should Be True   "${status}"=="True"
    Log To Console   nom_index:${nom_index}
    Log To Console   Target Nom:${all_nom_list[${nom_index}]}
    [Return]    ${nom_index}     ${all_nom_list[${nom_index}]}


_Get NOM Server Information By Label
    [Arguments]  ${label}=NOM4
   [Documentation]   _Get NOM Server Information By Label
    ...  author:             chris.l.cao@nokia-sbell.com
    ...  modified by:        <21-Oct-2021>, <chricao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  label  |  No  |  label, should be NOM4 or NOM10, default is NOM4.  |
    ...
    ...    *RETURN VALUE*
    ...    dictionary of NOM extra info
    ...
    ${all_nom_list}      get_all_nom_server
    ${nom_count}    Get Length    ${all_nom_list}
    ${rtn}   Create Dictionary
    FOR    ${nom_index}    IN RANGE    ${nom_count}
        ${nom}  Set Variable   ${all_nom_list[${nom_index}]}
        Continue For Loop If   "${nom["label"]}"!="${label}"
        Set To Dictionary   ${rtn}   label    ${label}
        Set To Dictionary   ${rtn}   ssh_ip   ${nom["main_info"].ssh_connections_info[0].addr}
        Set To Dictionary   ${rtn}   ssh_user   ${nom["main_info"].ssh_connections_info[0].username}
        Set To Dictionary   ${rtn}   integrate_link   ${nom["integrate_link"]}
        ${ssh_ip_mask_len}   Set Variable  ${nom["ssh_ip_mask_len"]}
        ${ssh_ip_mask_len}   Convert To String   ${ssh_ip_mask_len}
        Set To Dictionary   ${rtn}   ssh_ip_mask_len    ${ssh_ip_mask_len}
        Set To Dictionary   ${rtn}   webui_link   ${nom["main_info"].https_main_info.addr}
        Set To Dictionary   ${rtn}   webui_link_username   ${nom["main_info"].https_main_info.username}
        Set To Dictionary   ${rtn}   webui_link_password   ${nom["main_info"].https_main_info.password}
        Set To Dictionary   ${rtn}   version   ${nom["version"]}
        Set To Dictionary   ${rtn}   ca_file   ${nom["ca_file"]}
        Set To Dictionary   ${rtn}   vdu_integrate_to_nom_certificate_file   ${nom["vdu_integrate_to_nom_certificate_file"]}
        Set To Dictionary   ${rtn}   ca_sn   ${nom["ca_sn"]}
        Set To Dictionary   ${rtn}   ca_id   ${nom["ca_id"]}
        # ----------  NOM PM FILE SFTP server part -----------------
        Set To Dictionary   ${rtn}   pm_sftp_ip   ${nom["pm_sftp_ip"]}
        Set To Dictionary   ${rtn}   pm_sftp_username    ${nom["pm_sftp_username"]}
        Set To Dictionary   ${rtn}   pm_sftp_password   ${nom["pm_sftp_password"]}
        Set To Dictionary   ${rtn}   pm_sftp_root_path    ${nom["pm_sftp_root_path"]}
        Set To Dictionary   ${rtn}   pm_sftp_root_path_rest    ${nom["pm_sftp_root_path_rest"]}
        log to console      _Get NOM Server Information By Label:NOM server: ${label} is found.
    END
    [Return]   ${rtn}



_NOM Detect Rest Login
    [Arguments]  ${dict_nom}
    [Documentation]    _NOM Detect Rest Login
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  dict_nom   |  Yes  |  nom info returned by get_all_nom_server |
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  _NOM Detect Rest Login  |  ${dict_nom}  |
    [Teardown]   run keyword and ignore error   _NOM Detect Rest Logout    ${dict_nom}    ${client_id}
    ${username}   Set Variable  ${dict_nom["main_info"].https_main_info.username}
    ${password}    Set Variable  ${dict_nom["main_info"].https_main_info.password}
    ${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr}

    ${client_id}=  get unique id

    ${client_secret}   nom_rest.register_the_client   client_id=${client_id}
    ...       username=${username}
    ...       password=${password}
    ...       apigw_uri=${apigw_uri}

    ${user_mgmt_uri}   Set Variable  ${dict_nom["main_info"].https_user_mgmt_info.addr}
    ${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr.split("//")[-1]}
    ${nom_version}  Set Variable  ${dict_nom["version"]}

    nom_rest.connect_to  user_mgmt_uri=${user_mgmt_uri}
    ...    apigw_uri=${apigw_uri}
    ...    client_id=${client_id}
    ...    client_secret=${client_secret}
    ...    port=${443}
    ...    username=${username}
    ...    password=${password}
    ...    nom_version=${nom_version}
    ...    secure=${True}


_NOM Detect Rest Logout
    [Arguments]     ${dict_nom}     ${client_id}
    [Documentation]    _NOM Detect Rest Logout
    ...    author: huilin.xu@nokia-sbell.com
    ...    modified by:        <13-Oct-2020>, <huilxu>, <Initial creation>
    ...    23.10.2021,chris.l.cao@nokia-sbell.com, add change history, delete "https://" for apigw_uri
    ...
    ...    | Input Parameters | Man. | Description |
    ...    |  dict_nom   |  Yes  |  nom info defined in global_variables.py |
    ...    |  client_id  |  Yes  |  client id returned by register_the_client    |
    ...
    ...    *RETURN VALUE*
    ...
    ...    Example
    ...    |  _NOM Detect Rest Logout  |  ${dict_nom}  |  ${client_id} |
    ...
    ${username}   Set Variable  ${dict_nom["main_info"].https_main_info.username}
    ${password}    Set Variable  ${dict_nom["main_info"].https_main_info.password}
    #${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr}
    ${apigw_uri}   Set Variable  ${dict_nom["main_info"].https_rest_info.addr.split("//")[-1]}

    nom_rest.delete_the_client  client_id=${client_id}
    ...       username=${username}
    ...       password=${password}
    ...       apigw_uri=${apigw_uri}


Get the NOM SSH Result
    [Arguments]     ${ssh_return_result}
    ${status}=  run keyword and return status   should contain   ${ssh_return_result}   PASS
    log to console     ${status}
    [Return]   ${status}

_Get Target netact Server Index
    [Documentation]
    ...    will chose the useful netact and return the netact id
    ...    *AUTHOR* jie.8.liu@nokia-sbell.com
    ...    modified by:        <13-Oct-2021>, <huilxu>, <netact Detect Rest Login>
    ...    modified by:        <5-Nev-2021>, <huilxu>, <netact Detect Rest Login>
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...    Index of desire target netact server and target netact server

    ${all_netact_list}      get_all_netact_server
    ${netact_count}=    Get Length    ${all_netact_list}
    log to console     ${all_netact_list}
    log to console     ${netact_count}
    FOR    ${netact_index}    IN RANGE    ${netact_count}
        ${status}     Run Keyword and Return Status    _netact Detect ssh    ${all_netact_list[${netact_index}]}
        Exit For Loop If    "${status}"=="True"
        log to console      ${status}
    END
    Should Be True   "${status}"=="True"
    [Return]    ${netact_index}     ${all_netact_list[${netact_index}]}

_netact Detect ssh
    [Arguments]  ${dict_netact}   ${service_name}=cmwas   #${alias}=default

    ${client_id}=  get unique id
    ${hostname}   Set Variable  ${dict_netact["node_ip"]}
    ${username}    Set Variable  ${dict_netact["user"]}
    ${password}   Set Variable  ${dict_netact["password"]}
    taf_netact.add_node
    ...   service_name=${service_name}
    ...   hostname=${hostname}
    ...   username=${username}
    ...   password=${password}
    ...   alias=default
    [Return]   ${client_id}
