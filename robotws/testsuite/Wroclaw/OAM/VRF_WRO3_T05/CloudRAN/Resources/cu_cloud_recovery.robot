*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_cloud_recovery.robot

Resource    aic_common_resources_new.robot

*** Keywords ***
_Get vCU Pods Status
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  keywrod for printing pods status default is all pods should be printed
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...                     <12-02-2024>, <taupeka>, TC transfer
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace |
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None | print pods status , default pod_addr is empty meaning all pods will be printed
    ...    Example
    ...    |  _Get vCU Pods Status | con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    log to console  _Get vCU Pods Status
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  ${con}  ${ns}  ${pod_abbr}
    ${cmd}  Run Keyword If  '${pod_abbr}'=='${EMPTY}'  Set Variable  kubectl get pods ${pod_abbr} -o wide -n ${ns}
    ...  ELSE  Set Variable  kubectl get pods -o wide -n ${ns} | grep -i ${pod_abbr}
    ${pods_print}  issh.Execute  command=${cmd}   alias=${con}  check_result=${False}
    ${pods_print}  strip prompt  ${pods_print}
    ${pods_print}    Process Variable    ${pods_print}
    log to console  ${pods_print}

Get CU Specfic 2N Pods Recovery State After Pods Rebuild
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${full_pod_name}=${EMPTY}
    [Documentation]  keyword to check pods state change default is all pods
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...                     <12-02-2024>, <taupeka>, TC transfer
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace |
    ...    | full_pod_name | No | full name of pod. like : po-cran5-cpif-0 |
    ...    *RETURN VALUE*
    ...    None , It will Check Pod Rebuild from restart time / container recovery / running status
    ...    Example
    ...    |  Get CU Specfic 2N Pods Recovery Status After Pods Rebuild | con=alias or empty |
    ...    | ns=namespace or empty | full_pod_name=full name of pod or empty |
    log to console  Get CU Specfic 2N Pods Recovery State After Pods Rebuild
    ${con}  ${ns}  ${useless}  _Create A vCU Session With Namespace And Podabbr Info
    _Get vCU Pods Status  ${con}  ${ns}  ${full_pod_name}
    ${check_recovery_time_cmd}=  Set Variable  kubectl get pods -n ${ns} | grep -i ${full_pod_name} | awk '{print $1\"\=\"$NF}'
    ${pods_live_time_info}=  issh.Execute  command=${check_recovery_time_cmd}  alias=${con}  check_result=${False}
    ${pods_live_time_info}  strip prompt  ${pods_live_time_info}
    ${pods_live_time_info}    Process Variable    ${pods_live_time_info}
    @{pods_live_time_list}  Create List
    @{pods_live_time_list}  Evaluate   """${pods_live_time_info}""".split("\\n")
    &{pods_live_time_dict}  Create Dictionary
    FOR  ${pods_live_time_pair}  IN  @{pods_live_time_list}
        @{pods_live_time_pair_list}  Create List
        @{pods_live_time_pair_list}   Evaluate  "${pods_live_time_pair}".split("\=")
        ${time}  Set Variable  ${pods_live_time_pair_list[-1]}
        ${time}  Convert vCU Running Continue Time To Second  ${time}
        set to dictionary  ${pods_live_time_dict}  ${pods_live_time_pair_list[0]}  ${time}
        ${live_shotest_pods}=  Set Variable  ${EMPTY}
    END
    FOR  ${pods}  IN  @{pods_live_time_dict.keys()}
        ${live_shotest_pods}=  Run Keyword If  '${live_shotest_pods}'=='${EMPTY}'
        ...  Set Variable  ${pods}  ELSE   Set Variable  ${live_shotest_pods}
        ${live_shotest_pods}=  Run Keyword If  ${pods_live_time_dict["${pods}"]} < ${pods_live_time_dict["${live_shotest_pods}"]}
        ...  Set Variable  ${pods}  ELSE  Set Variable  ${live_shotest_pods}
    END
    log to console  Restart pods is ${live_shotest_pods} , time is ${pods_live_time_dict["${live_shotest_pods}"]} s
    Should Be Equal As Strings  ${full_pod_name}  ${live_shotest_pods}
    # check Pods Container Number Is Ready
    ${check_container_status_cmd}=  Set Variable  kubectl get pods -n ${ns} | grep -i ${full_pod_name} | awk '{print $2}'
    ${container_info}=  issh.Execute  command=${check_container_status_cmd}  alias=${con}  check_result=${False}
    ${container_info}  strip prompt  ${container_info}
    ${container_info}    Process Variable    ${container_info}
    @{container_list}  Create List
    @{container_list}  evaluate   "${container_info}".split("\\n")
    log to console  Currently Container Recover Status ${container_list}
    FOR  ${i}  IN  @{container_list}
        @{avaliable_number_list}   Create List
        @{avaliable_number_list}=  evaluate  "${i}".split("/")
        Should Be True  ${avaliable_number_list[0]}==${avaliable_number_list[-1]}
    END
    # check Pods Running Status
    ${check_cmd}=  Set Variable  kubectl get pods -n ${ns} | grep -i ${full_pod_name} | grep -v Running | awk 'END{print NR}'
    ${wrong_state_pod_number}=  issh.Execute  command=${check_cmd}  alias=${con}  check_result=${False}
    ${wrong_state_pod_number}  strip prompt  ${wrong_state_pod_number}
    ${wrong_state_pod_number}    Process Variable    ${wrong_state_pod_number}
    ${wrong_state_pod_number}  evaluate  ${wrong_state_pod_number.strip()}
    log to console  Currently ${full_pod_name} state is ${wrong_state_pod_number}
    Should Be True  ${wrong_state_pod_number}==${0}

Check vCU Not Happen Site Reset
    [Arguments]  ${expect_number}=${5}  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  Check vCU Not Happen Site Reset
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <05-17-2023>, <jieyang>, <initial created>
    ...                     <12-02-2024>, <taupeka>, TC transfer
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace |
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None , it will Check vCU Site Reset From OCP
    ...    Example
    ...    | Check vCU Not Happen Site Reset | expect_number=number of you think the cu is reset  | con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info    ${con}  ${ns}  ${pod_abbr}
    ${cmd}  Set Variable   kubectl get pods -o wide -n ${ns} | grep Running | awk \'END{print NR}\'
    ${current_restart_num}   issh.Execute  command=${cmd}   alias=${con}  check_result=${False}
    ${current_restart_num}   strip prompt  ${current_restart_num}
    ${current_restart_num}    Process Variable  ${current_restart_num}
    _Get vCU Pods Status  ${con}  ${ns}
    log to console  Currently Running Pods Number : ${current_restart_num}
    ${site_status}  Run Keyword If  ${current_restart_num}<${expect_number}  Set Variable  CU Reset Triggered
    ...  ELSE  Set Variable  No Trigger Reset Now
    log to console  ${site_status}
    Should Be Equal As Strings  ${site_status}  No Trigger Reset Now

_Create A vCU Session With Namespace And Podabbr Info
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  keyword to check paramter && create connection if not passing parameter
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace |
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    check input and return a vcu session and a namespace info and pod_abbr info
    ...    Example
    ...    |  _Create A vCU Session With Namespace And Podabbr Info  |  con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    ${innercon}  Run Keyword If  '${con}'!='${EMPTY}'   Set Variable  ${con}
    ...  ELSE  Connect To CU K8S Master With Tenant
    ${innerns}  Run Keyword If  '${ns}'!='${EMPTY}'   Set Variable  ${ns}
    ...  ELSE  Get CU Namespace From Testline
    ${innerpod_abbr}  Run Keyword If  '${pod_abbr}'!='${EMPTY}'  Set Variable  ${pod_abbr}
    ...  ELSE  Set Variable  ${EMPTY}
    [Return]  ${innercon}  ${innerns}  ${innerpod_abbr}

Convert vCU Running Continue Time To Second
    [Arguments]  ${time_format}
    [Documentation]  Conver format time to second
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...                     <07-15-2024>, <xianbiao>, <fix bug for 2d5h failure>
    ...    | Input Parameters | Man. | Description |
    ...    | time_format | Yes | format time like : 3h4m |
    ...    *RETURN VALUE*
    ...    Continue time from pods running
    ...    Example
    ...    | Convert vCU Running Continue Time To Second |  time_format=like 3h4m |
    ${time_format}  Evaluate  "${time_format}".replace("d","*86400s").replace("h","*3600s").replace("m","*60s")
    @{time}  Create List
    @{time}  Evaluate  "${time_format}".strip().split("s")[:-1]
    ${time_second}  Set Variable  ${0}
    FOR  ${part}  IN  @{time}
        ${time_second}  Evaluate  ${time_second}+${part}
    END
    [Return]   ${time_second}

Trigger CU Pod Recovery
    [Arguments]  ${pod_name}  ${alias}=default   ${gnb_index}=0
    [Documentation]  trigger cu pod recovery by deleting the pod
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | Yes. | the pod name abbreviation or the full pod name |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Pod Recovery | oamcm | ${alias} |
    ...    | Close Interactive Connection | ${alias} |
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${pod_name}=  Run Keyword If  '${ns}' not in '${pod_name}'
    ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name}  ${alias}  ${gnb_index}
    ...  ELSE  set variable  ${pod_name}

    ${out}  issh.Execute  command=kubectl delete pod ${pod_name} -n ${ns}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Set Variable  ${out.strip()}
    [Return]  ${out}


_Get vCU Specified Active Pod Container Restart Times
    [Arguments]   ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  keyword to fetch specified restart number
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace |
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    Get and return specified active pod restart_times
    ...    Example
    ...    | ${restart_times}= | _Get vCU Specified Active Pod Container Restart Times | con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  ${con}  ${ns}  ${pod_abbr}
    ${active_pods}=    CU Get Active Pod Name By Specified Pod  pod_abbr=${pod_abbr}
    ${check_restart_cmd}  Set Variable  kubectl get pods -n ${ns} | grep -i ${active_pods} | awk '{print $4}'
    ${restart_times}=  issh.Execute  command=${check_restart_cmd}   alias=${con}  check_result=${False}
    ${restart_times}  strip prompt  ${restart_times}
    ${restart_times}  Process Variable    ${restart_times}
    log to console  currently ${active_pods} restart number is ${restart_times}
    [Return]  ${restart_times}

Recovery CU Specfic Pods Restart Times If Not Equal Zero
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  Keywrod to Recovery CU Specfic Pods Restart Times If Not Equal Zero
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace |
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None , check specfic pods restart times , recovery pods restart time to 0
    ...    Example
    ...    |  Recovery CU Specfic Pods Restart Times If Not Equal Zero  | con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  ${con}  ${ns}  ${pod_abbr}
    ${active_pod}=  CU Get Active Pod Name By Specified Pod  pod_abbr=${pod_abbr}
    ${current_num}=  _Get vCU Specified Active Pod Container Restart Times  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    Run Keyword IF  ${current_num}!=${0}
    ...  Trigger CU Pod Recovery    pod_name=${active_pod}     alias=${con}
    wait until keyword succeeds   12min   3min   Get CU Specfic 2N Pods Recovery State After Pods Rebuild  full_pod_name=${active_pod}
    ${current_num}=  _Get vCU Specified Active Pod Container Restart Times  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    Run Keyword IF  ${current_num}!=${0}
    ...  Trigger CU Pod Recovery    pod_name=${active_pod}    alias=${con}
    wait until keyword succeeds   12min   3min   Get CU Specfic 2N Pods Recovery State After Pods Rebuild  full_pod_name=${active_pod}
    [Teardown]  aic_common_resources_new.Close Interactive Connection    ${con}

Trigger CU Specific Process Recovery By Delete Process
    [Arguments]   ${pod_abbr}=${EMPTY}  ${container}=${EMPTY}  ${process}=${EMPTY}
    [Documentation]  Keyword to trigger container error by delete process
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | abbreviation of podname. like :cpif |
    ...    | process | Yes | process which be killed then container error |
    ...    *RETURN VALUE*
    ...    None It will trigger and check Process Error
    ...    Example
    ...    |  Trigger CU Specific Process Recovery By Delete Process  | pod_abbr=cpif | process=process_name |
    log to console  Kill process under the ${pod_abbr} container
    ${con} =  Connect To CU K8S Master With Tenant
    ${active_pod}=  CU Get Active Pod Name By Specified Pod  pod_abbr=${pod_abbr}
    ${standby_pod}=  CU Get Standby Pod Name By Specified Pod  pod_abbr=${pod_abbr}
    log to console  Get Active Pods , Currently Active Pods Is ${active_pod}
    ${expect_checkpoint}=  _Get vCU Target Pods Checkpoint According to Container Restart Time  pod_abbr=${pod_abbr}
    Run Keyword IF  "${expect_checkpoint}"=="Check Restart Time"  log to console
    ...  Currently Restart Time Is 0 , Will Check Restart Time Increase
    ...  ELSE  log to console  Currently Restart Time Is 1 , Will Check RoleChange
    log to console  Trigger ${pod_abbr} Container Process Recovery
    Trigger CU Process Recovery     pod_abbr=${pod_abbr}  container=${container}
    ...  process=${process}   alias=${con}
    wait until keyword succeeds   2min   5s   Get CU Specfic 2N Pods Recovery State After Pods Rebuild
    ...  full_pod_name=${active_pod}
    ${expect_active_pods}=  CU Get Active Pod Name By Specified Pod  pod_abbr=${pod_abbr}
    ${expect_restart_numb}=  _Get vCU Specified Active Pod Container Restart Times  con=${con}  pod_abbr=${pod_abbr}
    Run Keyword IF  ${expect_restart_numb}==${0}  Should Be Equal As Strings  ${expect_active_pods}  ${standby_pod}
    ...   ELSE   Should Be True  ${expect_restart_numb}==${1}
    aic_common_resources_new.Close Interactive Connection    ${con}

_Get vCU Target Pods Checkpoint According to Container Restart Time
    [Arguments]  ${pod_abbr}=${EMPTY}
    [Documentation]  according to the restart time return expect result
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    Judge and return expect Result : Pods restart time increase 1 or Pods role Change
    ...    Example
    ...    | ${expect_result}= | _Get vCU Target Pods Checkpoint According to Container Restart Time |
    ...    | pod_addr=abbreviation of podname or empty |
    log to console  Get vCU Target Pods Checkpoint According to Container Restart Time
    ${current_num}=  _Get vCU Specified Active Pod Container Restart Times  pod_abbr=${pod_abbr}

    ${current_num}   Process Variable    ${current_num}

    ${expect_result}=   Run Keyword If  ${current_num}==${0}  Set Variable  Check Restart Time
    ...  ELSE  Set Variable  Check Pods Role Change
    [Return]  ${expect_result}

Trigger CU Process Recovery
    [Arguments]   ${pod_abbr}   ${container}   ${process}  ${pid}=9  ${alias}=default   ${gnb_index}=0
    [Documentation]  trigger cu process recovery by killing it
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | process | Yes. | the process, like l2hicu. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    None
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Process Recovery | oamcm | oamcm | xxx | ${alias} |
    ...    | Close Interactive Connection | ${alias} |
    ${cmd}  set variable  ps -ef|grep ${process}|awk '{print $2}'|xargs kill -${pid}
    CU Kubectl Exec  ${pod_abbr}  ${container}  ${cmd}  alias=${alias}  gnb_index=${gnb_index}

Trigger CU Specific Process Recovery By Delete Process With Recovery Check
    [Arguments]  ${pod_abbr}=${EMPTY}  ${container}=${EMPTY}  ${process}=${EMPTY}
    [Documentation]  Keyword For User To Trigger Container Error And Check Recovery
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | abbreviation of podname. like :cpif |
    ...    | process | Yes. | process which be killed then container error |
    ...    *RETURN VALUE*
    ...    None  It'll trigger 5 times , and will check restart time increase to 1 , then role change
    ...    Standby Pods will change to Active , then new Active pods restart time increae to 1
    ...  *Example*
    ...    | Trigger CU Specific Process Recovery By Delete Process With Recovery Check |
    ...    | pod_abbr=cpif | process=process_name |
    log to console  Trigger CU Specific Process Recovery By Delete Process With Recovery Check
    ${tag}=  Set Variable  1
    :FOR    ${tag}  IN RANGE   5
    \   log to console  currently loop times is : ${tag}
    \   Trigger CU Specific Process Recovery By Delete Process  pod_abbr=${pod_abbr}  container=${container}
        ...  process=${process}


Trigger vCU Link Redundancy Switchover
    [Arguments]    ${pod_name}   ${gnb_index}=0
    log to console    Trigger vCU link redundancy switchover
    ${conn} =  Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ${active_pod}=  CU Get Active Pod Name    pod_name=${pod_name}
    ${ctr_name}   Get CU Full Container Name By Container Abbreviation  nwmgmt
    Trigger CPIF link redundancy switch   pod_name=${active_pod}   container=${ctr_name}  link=extc  link2=extcs
     ...    alias=${conn}  check_result=False
    wait until keyword succeeds    3min    30s
    ...   Check Pod Active Role Change After Link Redundancy Switch   active_pod=${active_pod}   pod_name=${pod_name}

Check Pod Active Role Change After Link Redundancy Switch
    [Arguments]    ${active_pod}   ${pod_name}
    ${act_pod_new}=  CU Get Active Pod Name    pod_name=${pod_name}
    should not be equal  ${active_pod}   ${act_pod_new}

Trigger CU Site Reset By Config The Specifical Pod Error Image Tag
    [Arguments]   ${pod_abbr}
    [Documentation]  Keyword For User To Trigger Site Reset By Pull Image Failed
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <07-27-2023>, <shojiao>, <initial created>
    ...  modified by:       <07-27-2024>, <xianbiao>, <fix bug for endtime-starttime>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    exec_time  return exec_time from pods error to CU reset .
    ...  *Example*
    ...    | Trigger CU Site Reset By Config The Specifical Pod Error Image Tag  | pod_abbr=cpif |
    log to console  Trigger CU Site Reset By Config The Specifical Pod Error Image Tag
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  pod_abbr=${pod_abbr}
    wait until keyword succeeds  3min  30s  Modify The Specifical Pod With Error Image And Status Should Be Expect
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    ${start_time}=  evaluate  time.time()  time
    wait until keyword succeeds  10min  1s  Check vCU Site Reset
    ...   con=${con}  ns=${ns}  pod_abbr=${pod_abbr}  expect_number=30
    ${end_time}=  evaluate  time.time()  time
    wait until keyword succeeds  10min  60s  Recovery The Specifical Pod With Right Image And Status Should Be Expect
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    wait until keyword succeeds  10min  1s  Check vCU Site Recovery
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    ${exec_time}=  evaluate  ${end_time}-${start_time}
    [Teardown]  Run Keyword And Ignore Error  Recovery The Specifical Pod With Right Image And Status Should Be Expect
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    [Return]  ${exec_time}

Modify The Specifical Pod With Error Image And Status Should Be Expect
    [Arguments]   ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  Keyword For User Modify Statefulset Resource Cause Pods Status Abnormal
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <07-27-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con      | No | connection with cu |
    ...    | ns       | No | namespace info |
    ...    | pod_abbr | Yes. | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None  It will modify and check modifiy result .
    ...  *Example*
    ...    | Modify The Specifical Pod With Error Image And Status Should Be Expect | pod_abbr=cpif |
    ...    some operation
    ...    | Recovery The Specifical Pod With Right Image And Status Should Be Expect | pod_abbr=cpif |
    log to console  Modify Target Statefulset Resource and Pods Status Should Be Expect
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    ${version}=  Get Current CU Version
    ${prompt}=  Run Keyword IF  '${pod_abbr}'=='twamp'  Set Variable  twampsender:
    ...  ELSE  Set Variable  ${version}
    # get release
#    ${get_config_command}=  Set Variable   kubectl get statefulset po-${ns}-${pod_abbr} -o yaml
    ${get_config_command}=  Set Variable   kubectl get statefulset po-${pod_abbr} -o yaml
    ${sed_command}=  Set Variable  sed 's/${prompt}/trigger_cu_reset_test/g'
    ${replace_command}=  Set Variable  kubectl replace -f -
    ${exec_command}=  Set Variable  ${get_config_command} | ${sed_command} | ${replace_command}
    # change command
    issh.Execute  command=${exec_command}  alias=${con}  check_result=${False}
    ${check_command}=  Set Variable   grep 'trigger_cu_reset_test' > /dev/null && echo $?
#    ${check_pod_status_result}=  Set Variable  kubectl get statefulset po-${ns}-${pod_abbr} -o yaml | ${check_command}
    ${check_pod_status_result}=  Set Variable  kubectl get statefulset po-${pod_abbr} -o yaml | ${check_command}
    ${result}=  issh.Execute  command=${check_pod_status_result}  alias=${con}  check_result=${False}
    ${result}   strip prompt  ${result}
    ${result}   Set Variable  ${result.strip()}
    Should Be Equal As Strings  ${result}  0
    # check modify
    Tigger CU Specific 2N Pods Recovery By Delete Pod
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}  check_recovery=${FALSE}  force_option=${FALSE}
    sleep  10s
    ${check_delete_command}=  Set Variable  kubectl get pods -n ${ns} | grep ${pod_abbr} | grep -i running | wc -l
    ${check_delete_result}=  issh.Execute  command=${check_delete_command}  alias=${con}  check_result=${False}
    ${check_delete_result}   strip prompt  ${check_delete_result}
    ${check_delete_result}   Set Variable  ${check_delete_result.strip()}
    Should Be Equal As Strings  ${check_delete_result}  0

Recovery The Specifical Pod With Right Image And Status Should Be Expect
    [Arguments]   ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  Keyword For User Rollback Statefulset Resource Cause Pods Status Recovery To Nomal
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <07-27-2023>, <shojiao>, <initial created>
    ...  modified by:       <04-12-2024>, <cheng xianbiao>, pod check logic wrong https://jiradc.ext.net.nokia.com/browse/CS-4083
    ...    | Input Parameters | Man. | Description |
    ...    | con      | No | connection with cu |
    ...    | ns       | No | namespace info |
    ...    | pod_abbr | Yes. | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None  It will modify and check modifiy result .
    ...  *Example*
    ...    | Modify The Specifical Pod With Error Image And Status Should Be Expect | pod_abbr=cpif |
    ...    some operation
    ...    | Recovery The Specifical Pod With Right Image And Status Should Be Expect | pod_abbr=cpif |
    log to console  Modify Target Statefulset Resource and Pods Status Should Be Expect
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}
    ${version}=  Get Current CU Version
    ${prompt}=  Run Keyword IF  '${pod_abbr}'=='twamp'  Set Variable  twampsender:
    ...  ELSE  Set Variable  ${version}
#    ${get_config_command}=  Set Variable   kubectl get statefulset po-${ns}-${pod_abbr} -o yaml
    ${get_config_command}=  Set Variable   kubectl get statefulset po-${pod_abbr} -o yaml
    ${rollback_command}=  Set Variable  sed 's/trigger_cu_reset_test/${prompt}/g'
    ${replace_command}=  Set Variable  kubectl replace -f -
    ${exec_command}=  Set Variable  ${get_config_command} | ${rollback_command} | ${replace_command}
    issh.Execute  command=${exec_command}  alias=${con}  check_result=${False}
    ${check_command}=  Set Variable   grep 'trigger_cu_reset_test' > /dev/null && echo $?
#    ${check_rollback_command}=   Set Variable  kubectl get statefulset po-${ns}-${pod_abbr} -o yaml | ${check_command}
    ${check_rollback_command}=   Set Variable  kubectl get statefulset po-${pod_abbr} -o yaml | ${check_command}
    ${check_rollback_result}=  issh.Execute  command=${check_rollback_command}  alias=${con}  check_result=${False}
    ${check_rollback_result}   strip prompt  ${check_rollback_result}
    ${check_rollback_result}   Set Variable  ${check_rollback_result.strip()}
    Should Be Empty  ${check_rollback_result}
    # delete pod trigger image pull again
    Tigger CU Specific 2N Pods Recovery By Delete Pod
    ...  con=${con}  ns=${ns}  pod_abbr=${pod_abbr}  check_recovery=${FALSE}  force_option=${FALSE}

Random Select vCU 2N Pod Abbr With Specifical Pod Num
    [Arguments]   ${pod_num}=2
    [Documentation]  Random select two vCU 2N Type Pod's Abbr List
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:       <06-07-2023>, <longxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_num  |  no  | pod num, default is 2 |
    ${2n_pod_list}=  Create List   oamext  oamconfig  oamcm  oamfm  oamasm  cpif  cpnb  cpnrt  cpcl
    ${random_2n_pods}  Create List
    FOR  ${index}  IN RANGE  0   ${pod_num}
        ${random_2n_pod}  evaluate  random.choice(${2n_pod_list})  random
        remove values from list    ${2n_pod_list}    ${random_2n_pod}
        append to list   ${random_2n_pods}   ${random_2n_pod}
    END
    [Return]  ${random_2n_pods}

Trigger CU Pod Recovery Both
    [Arguments]  ${pod_name1}  ${pod_name2}  ${alias}=default   ${gnb_index}=0
    [Documentation]  trigger cu pod recovery by deleting the pod
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | Yes. | the pod name abbreviation or the full pod name |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Pod Recovery | oamcm | ${alias} |
    ...    | Close Interactive Connection | ${alias} |
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${pod_name1}=  Run Keyword If  '${ns}' not in '${pod_name1}'
    ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name1}  ${alias}  ${gnb_index}
    ...  ELSE  set variable  ${pod_name1}
    ${pod_name2}=  Run Keyword If  '${ns}' not in '${pod_name2}'
    ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name2}  ${alias}  ${gnb_index}
    ...  ELSE  set variable  ${pod_name2}

    ${out}  issh.Execute  command=kubectl delete pod ${pod_name1} ${pod_name2} -n ${ns}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Set Variable  ${out.strip()}
    [Return]  ${out}

Scale vCU Specified Pod To Specified Amount
    [Arguments]  ${pod_name}    ${pod_amount}
    log to console     scale pods to specified amount
    ${conn} =  Connect To CU K8S Master With Tenant
    ${ns}   Get CU Namespace From Testline   gnb_index=0
#    ${cmd}   set variable   kubectl scale statefulset po-${ns}-${pod_name} --replicas=${pod_amount}
    ${cmd}   set variable   kubectl scale statefulset po-${pod_name} --replicas=${pod_amount}
    ${out}   issh.Execute  command=${cmd}   alias=${conn}
    Wait Until Keyword Succeeds    10min    20s    Check Pod Scaled To Specified Amount    ${pod_name}    ${pod_amount}
    aic_common_resources_new.Close Interactive Connection   ${conn}

Check Pod Scaled To Specified Amount
    log to console     Check Pod Scaling To Specified amount
    [Arguments]  ${pod_name}    ${pod_amount}
    ${conn} =  Connect To CU K8S Master With Tenant
    ${ns}   Get CU Namespace From Testline   gnb_index=0
    ${check_scaleout_cmd}  Set Variable  kubectl get pods -n ${ns} | grep -i ${pod_name} | wc -l
    ${scaleout_result}=  issh.Execute  command=${check_scaleout_cmd}   alias=${conn}  check_result=${False}
    ${scaleout_result}  strip prompt  ${scaleout_result}
    ${scaleout_result}  convert to integer  ${scaleout_result}
    ${pod_amount}   convert to integer   ${pod_amount}
    Should Be Equal    ${scaleout_result}    ${pod_amount}
    aic_common_resources_new.Close Interactive Connection   ${conn}

CU Get Standby Pod Name
    [Arguments]  ${pod_name}    ${use_m2m}=${True}
    [Documentation]    CU Get Standby Pod Name
    ...    *AUTHOR* nate_lee.li@nokia-sbell.com
    ...    *Change History*
    ...    | date | who | what and how |
    ...    | 21.4.2022 | chris.l.cao@nokia-sbell.com | support not using container parameter, update KW description |
    ...    | 7.5.2022 | rui.3.li@nokia-sbell.com | get by rest api |
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_name          | Yes  | pod name, eg, cpif,cpcl |
    ...    | container         | no   | container name, e.g. cpif, cpnrt, etc. |
    ...    | alias             | No   | alias, Default value is default |
    ...
    ...    *RETURN VALUE*
    ...    return the number of active pod, e.g. cpif-0 or cpif-1
    ...
    ...    Example
    ...    | ${standby_pod_name}  | CU Get Standby Pod Name | pod_name=cpif |
    ...
    ${full_pod_name}    CU Get Standby Pod Name By Specified Pod    ${pod_name}   use_m2m=${use_m2m}
    ${name_list}    Split String    ${full_pod_name}    -
    ${standby_pod_name}    Set Variable     ${name_list}[-2]-${name_list}[-1]
    [Return]   ${standby_pod_name}

CU Get Standby Pod Name By Specified Pod
    [Arguments]    ${pod_abbr}    ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]    Get Pod Full Name By Vnfcs States
    ...    *Author* rui.3.li@nokia-sbell.com
    ...    *Change HisTory*
    ...    | date | who | how or what |
    ...    | 2022-4-24 | r3li | new |
    ...    | 2022-5-10 | r3li | fix string including error of pod name. |
	...    | 2024-9-10 | r3li | IF change pod-two_nactivity. |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod abbreviatory name |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used |
    ...    *Example*
    ...    | CU Get Active Pod Name By Specified Pod | cpcl | 0 |
    ...    *Return*
    ...    - full pod name
    ${alias}  vCU Rest Login    gnb_index=${gnb_index}
    ${vnfcs_states}    cu.Get vnfcs states   use_m2m=${use_m2m}   connection=${alias}
    FOR    ${info}     IN     @{vnfcs_states}
         Continue For Loop If    "${info}[name]"=="${EMPTY}"
         Continue For Loop If    '${info}[name]'=='${None}'
         ${flag_1}    Set Variable If   '-${pod_abbr}-' in '''${info}[name]'''    ${1}    ${0}
         ${flag_2}    Set Variable If   '${info}[two_nactivity]'=='standby'   ${1}    ${0}
         ${flag}    Evaluate     ${flag_1}+${flag_2}
         ${full_pod_name}    Set Variable If    '${flag}'=='${2}'    ${info}[name]
         Exit For Loop If    '${flag}'=='${2}'
    END
    [Return]    ${full_pod_name}
    [Teardown]    CU Rest Logout   connection=${alias}

CU Get Active Pod Name By Specified Pod
    [Arguments]    ${pod_abbr}    ${gnb_index}=0   ${use_m2m}=${True}
    [Documentation]    Get Pod Full Name By Vnfcs States
    ...    *Author* rui.3.li@nokia-sbell.com
    ...    *Change HisTory*
    ...    | date | who | how or what |
    ...    | 2022-4-24 | r3li | new |
    ...    | 2022-5-10 | r3li | fix string including error of pod name. |
    ...    | 2024-9-9 | xianbiao | IF chagne role-->two_nactivity. |
    ...    *Arguments Description*
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod abbreviatory name |
    ...    | gnb_index | No | gnb index to indicate which gnb will be used |
    ...    *Example*
    ...    | CU Get Active Pod Name By Specified Pod | cpcl | 0 |
    ...    *Return*
    ...    - full pod name
    ${alias}   vCU Rest Login    gnb_index=${gnb_index}
    ${vnfcs_states}    cu.Get vnfcs states   use_m2m=${use_m2m}   connection=${alias}
    FOR    ${info}     IN     @{vnfcs_states}
         Continue For Loop If    "${info}[name]"=="${EMPTY}"
         Continue For Loop If    '${info}[name]'=='${None}'
         ${flag_1}    Set Variable If   '${pod_abbr}' in '''${info}[name]'''    ${1}    ${0}
         ${flag_2}    Set Variable If   '${info}[two_nactivity]'=='active'   ${1}    ${0}
         ${flag}    Evaluate     ${flag_1}+${flag_2}
         ${full_pod_name}    Set Variable If    '${flag}'=='${2}'    ${info}[name]
         Exit For Loop If    '${flag}'=='${2}'
    END
    [Return]    ${full_pod_name}
    [Teardown]    CU Rest Logout   gnb_index=${gnb_index}   connection=${alias}

Trigger Specifical Pod Unavailable Via Modify Statefulset Image Tag
    [Arguments]   ${pod_abbr}  ${error_tag}=tag   ${gnb_index}=0
    [Documentation]  Keyword For User Trigger Specifical Pod Unavailable Via Modify Statefulset Image Tag
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:       <01-29-2024>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr   | Yes | abbreviation of podname. like :cpif|
    ...    | error_tag | Yes. | modify to target error tag |
    ...    | gnb_index | No. | vcu index |

    ...    *RETURN VALUE*
    ...    None  It will modify and check modifiy result .
    ...  *Example*
    ...   | ${ORIGINAL_TAG}  ${ERROR_TAG}
    ...    Trigger Specifical Pod Unavailable Via Modify Statefulset Image Tag   | pod_abbr=healing-controller | pod_abbr=cpif |
    ...   some operation
    ...   | Trigger Specifical Pod Available Via Modify Statefulset Image Tag  | pod_abbr=healing-controller
    ...    original_tag=${ORIGINAL_TAG}  error_tag=${ERROR_TAG} |

    ${alias}   Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    ${ns}   Get CU Namespace From TestLine   gnb_index=${gnb_index}

    ${original_tag_cmd}=  Set Variable
#    ...  kubectl get statefulset po-${ns}-${pod_abbr} -o wide -n ${ns} | grep docker-healing-controller |awk -F ":" '{print $3}'
    ...  kubectl get statefulset po-${pod_abbr} -o wide -n ${ns} | grep docker-healing-controller |awk -F ":" '{print $3}'
    ${original_tag_result}=  issh.Execute  command=${original_tag_cmd}  alias=${alias}  check_result=${False}
    ${original_tag_result}   strip prompt  ${original_tag_result}
    ${original_tag_result}   Set Variable  ${original_tag_result.strip()}

#    ${get_config_command}=  Set Variable   kubectl get statefulset po-${ns}-${pod_abbr} -o yaml
    ${get_config_command}=  Set Variable   kubectl get statefulset po-${pod_abbr} -o yaml

    ${sed_command}=  Set Variable  sed 's/${original_tag_result}/${error_tag}/g'
    ${replace_command}=  Set Variable  kubectl replace -f -
    ${exec_command}=  Set Variable  ${get_config_command} | ${sed_command} | ${replace_command}
    # change command
    issh.Execute  command=${exec_command}  alias=${alias}  check_result=${False}
    ${check_command}=  Set Variable   grep '${error_tag}'
#    ${check_pod_status_result}=  Set Variable  kubectl get statefulset po-${ns}-${pod_abbr} -o yaml -n ${ns} | ${check_command}
    ${check_pod_status_result}=  Set Variable  kubectl get statefulset po-${pod_abbr} -o yaml -n ${ns} | ${check_command}
    ${result}=  issh.Execute  command=${check_pod_status_result}  alias=${alias}  check_result=${False}
    Should Contain  ${result}  ${error_tag}
     # check modify
    Trigger CU Pod Recovery Together    pod_abbr=${pod_abbr}    alias=${alias}
    sleep  10s
    ${check_delete_command}=  Set Variable  kubectl get pods -n ${ns} | grep ${pod_abbr} | grep -i running | wc -l
    ${check_delete_result}=  issh.Execute  command=${check_delete_command}  alias=${alias}  check_result=${False}
    ${check_delete_result}   strip prompt  ${check_delete_result}
    ${check_delete_result}   Set Variable  ${check_delete_result.strip()}
    Should Be Equal As Strings  ${check_delete_result}  0
    [Return]  ${original_tag_result}  ${error_tag}

Trigger Specifical Pod Available Via Modify Statefulset Image Tag
    [Arguments]  ${pod_abbr}  ${original_tag}  ${error_tag}  ${gnb_index}=0
    [Documentation]  Keyword For User Trigger Specifical Pod Unavailable Via Modify Statefulset Image Tag
    ...  author:            luofei.tu@nokia-sbell.com
    ...  modified by:       <01-29-2024>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr   | Yes | abbreviation of podname. like :cpif|
    ...    | original_tag | Yes. | modify to target original tag |
    ...    | error_tag | Yes. | modify to target error tag |
    ...    | gnb_index | No. | vcu index |

    ...    *RETURN VALUE*
    ...    None  It will modify and check modifiy result .
    ...  *Example*
    ...   | ${ORIGINAL_TAG}  ${ERROR_TAG}
    ...    Trigger Specifical Pod Unavailable Via Modify Statefulset Image Tag   | pod_abbr=healing-controller | pod_abbr=cpif |
    ...   some operation
    ...   | Trigger Specifical Pod Available Via Modify Statefulset Image Tag  | pod_abbr=healing-controller
    ...    original_tag=${ORIGINAL_TAG}  error_tag=${ERROR_TAG} |

    log to console  Modify Target Statefulset Resource and Pods Status Should Be Expect
    ${alias}   Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    ${ns}   Get CU Namespace From TestLine   gnb_index=${gnb_index}
#    ${get_config_command}=  Set Variable   kubectl get statefulset po-${ns}-${pod_abbr} -o yaml
    ${get_config_command}=  Set Variable   kubectl get statefulset po-${pod_abbr} -o yaml
    ${rollback_command}=  Set Variable  sed 's/${error_tag}/${original_tag}/g'
    ${replace_command}=  Set Variable  kubectl replace -f -
    ${exec_command}=  Set Variable  ${get_config_command} | ${rollback_command} | ${replace_command}
    issh.Execute  command=${exec_command}  alias=${alias}  check_result=${False}
    ${check_command}=  Set Variable   grep '${original_tag}'
#    ${check_rollback_command}=   Set Variable  kubectl get statefulset po-${ns}-${pod_abbr} -o yaml | ${check_command}
    ${check_rollback_command}=   Set Variable  kubectl get statefulset po-${pod_abbr} -o yaml | ${check_command}
    ${check_rollback_result}=  issh.Execute  command=${check_rollback_command}  alias=${alias}  check_result=${False}
    ${check_rollback_result}   strip prompt  ${check_rollback_result}
    ${check_rollback_result}   Set Variable  ${check_rollback_result.strip()}
    Should Contain    ${check_rollback_result}   ${original_tag}
