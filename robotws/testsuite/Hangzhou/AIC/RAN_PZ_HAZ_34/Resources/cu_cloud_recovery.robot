*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_cloud_recovery.robot




*** Variables ***



*** Keywords ***
CU Get Master VM Index
    [Arguments]  ${gnb_index}=0   ${vm_type}=oam
    [Documentation]    CU Get Master VM Index
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...    | vm_type   | no | vm type, can be oam, cpif,cpcl,cpnb,cpnrt,cpue,db and upue, default is oam |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${master_vm_index} | CU Get Master VM Index| vm_type=oam |
    ...    | ${master_vm_index} | CU Get Master VM Index| gnb_index=0 | vm_type=cpif |
    ...
    ${vm_type}  Set Variable  ${vm_type.upper()}
    ${master_vm_index}   Set Variable  0
    [Return]  ${master_vm_index}


Trigger CU Container Recovery
    [Arguments]   ${pod_abbr}   ${container}  ${alias}=default  ${process_name}=CCSMCU  ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  trigger cu container recovery by killing the ministarter process
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <07-29-2021>, <lutu>, <replace kill 1 with pkill CCSMCU>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | container | Yes. | the container name abbreviation. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    None
    ...  *Example*
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Container Recovery | oamcm | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ${cmd}  set variable  /bin/sh -c "pkill ${process_name}"
    CU Kubectl Exec  ${pod_abbr}  ${container}  ${cmd}  alias=${alias}  check_result=${check_result}  gnb_index=${gnb_index}


Trigger CU Pod Recovery
    [Arguments]  ${pod_name}  ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
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
    ...    | Disconnect Interactive Connection | ${alias} |
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${pod_name}=  Run Keyword If  '${ns}' not in '${pod_name}'
    ...  Get CU Full Pod Name By Pod Abbreviation  ${pod_name}  ${alias}  ${gnb_index}
    ...  ELSE  set variable  ${pod_name}

    ${out}  issh.Execute  command=kubectl delete pod ${pod_name} -n ${ns}  alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   Set Variable  ${out.strip()}
    [Return]  ${out}


Trigger CU Process Recovery
    [Arguments]   ${pod_abbr}   ${container}   ${process}  ${pid}=9  ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
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
    ...    | Disconnect Interactive Connection | ${alias} |
    ${cmd}  set variable  ps -ef|grep ${process}|awk '{print $2}'|xargs kill -${pid}
    CU Kubectl Exec  ${pod_abbr}  ${container}  ${cmd}  alias=${alias}  check_result=${check_result}  gnb_index=${gnb_index}

Trigger CU Pod Recovery Together
    [Arguments]  ${pod_abbr}  ${alias}=default  ${gnb_index}=0
    [Documentation]  get the full pod name by pod abbreviation using kubectl get pods command
    ...  author:            rebecca.yan@nokia-sbell.com
    ...  modified by:       <10-01-2021>, <rebecca>, <initial created>
    ...    2021.7.26,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation. |

    ...    *RETURN VALUE*
    ...    the pod full name
    ...  *Example*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | Trigger CU Pod Recovery Together | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${pods_name_list}   create list
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd}   set variable   kubectl get pods -n ${ns}|egrep "(${pod_abbr})" |awk '{print $1}'|xargs kubectl delete pod -n ${ns}
    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${out}   set variable  ${out.strip()}
    [Return]  ${out}


Trigger CU Pod Recovery Both
    [Arguments]  ${pod_name1}  ${pod_name2}  ${alias}=default   ${check_result}=${True}  ${gnb_index}=0
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
    ...    | Disconnect Interactive Connection | ${alias} |
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

Trigger CPIF link redundancy switch
    [Arguments]   ${pod_name}  ${container}  ${link}  ${link2}  ${status}=down  ${alias}=default  ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  trigger cu process recovery by killing it
    ...  author:   jie.1.yang@nokia-sbell.com
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
    ...    | Disconnect Interactive Connection | ${alias} |
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd1}  set variable  ipmgmttest -s -m owner:po-${ns}-${pod_name},iface:${link},admin:${status}
    ${cmd2}  set variable  ipmgmttest -s -m owner:po-${ns}-${pod_name},iface:${link2},admin:${status}
    CU Kubectl Exec  ${pod_name}  ${container}  ${cmd1}  alias=${alias}  check_result=${check_result}  gnb_index=${gnb_index}
    CU Kubectl Exec  ${pod_name}  ${container}  ${cmd2}  alias=${alias}  check_result=${check_result}  gnb_index=${gnb_index}

Trigger the HC service down or up
    [Arguments]   ${num}  ${alias}=default  ${check_result}=${True}  ${gnb_index}=0
    [Documentation]  trigger cu process recovery by killing it
    ...  author:   jie.1.yang@nokia-sbell.com
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
    ...    | Disconnect Interactive Connection | ${alias} |
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd}  set variable  kubectl scale statefulset --replicas=${num} -n ${ns} po-${ns}-healing-controller
    ${out}   issh.Execute    command=${cmd}   check_result=${check_result}   alias=${alias}

CU Get 2N Active Pods List
    [Arguments]  @{pod_abbr_list}
    [Documentation]  Receive pod_abbr(one or more) return active pods list,
    ...    author:  shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr_list | YES | pod_abbr List AT Least one pod_abbr
    ...    *RETURN VALUE*
    ...    Active Pods List 
    ...    Example
    ...    @{Active_Pods_List}  CU Get 2N Active Pods List  cpif 
    ...    @{Active_Pods_List} is like :  ["po-cran5-cpif-0"]
    ...    @{Active_Pods_List}  CU Get 2N Active Pods List  cpif  cpcl  cpnb
    ...    @{Active_Pods_List} is like :  ["po-cran5-cpif-0","po-cran5-cpcl-0","po-cran5-cpnb-0"]
    @{active_pods_list}   Create List  
    FOR  ${pod}  in  @{pod_abbr_list}
       ${active_pod}=  CU Get Active Pod Name By Specified Pod  pod_abbr=${pod}
       Append To List  ${active_pods_list}   ${active_pod}
    END
    [Return]  @{active_pods_list}

CU 2N Pods Role Should Be Exchanged
    [Arguments]  @{active_pod_lst_before_swo}
    [Documentation]  Compare target pods role after some operation to trigger pods recovery
    ...    author:  shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | active_pod_lst_before_swo | YES | Active pods list 
    ...    *RETURN VALUE*
    ...    Boolean  True | False
    ...    Example
    ...    @{active_pod_lst_before_swo}=  Generate CU Active Pods List  cpif 
    ...    "some opeartion trigger target pods recovery" 
    ...    CU 2N Pods Role Should Be Exchanged  ${active_pod_lst_before_swo}
    ...    it'll check every pods roles  :
    ...    before recovery opeartion active pods should be same with standby pods after recovery opeartion 
    FOR  ${active_pod}  IN  @{active_pod_lst_before_swo}
      ${pod_abbr}=  Evaluate  "${active_pod}".split("-")[2]
      ${standby_pod}=  CU Get Standby Pod Name By Specified Pod  pod_abbr=${pod_abbr}
      Should Be True  "${active_pod}"=="${standby_pod}"
      ${current_act_pod}=  CU Get Active Pod Name By Specified Pod  pod_abbr=${pod_abbr}
      Should Be True  "${active_pod}"!="${current_act_pod}"
    END

Tigger CU Specific 2N Pods Recovery By Delete Pod
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}  ${check_recovery}=${TRUE}
    ...   ${use_same_connection}=${TRUE}
    [Documentation]  keyword to trigger Pods Recovery Sub Method
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session
    ...    | ns  | No | namespace 
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    | check_recovery | No | It should be TRUE to check the cu site reset on OCP | 
    ...    | And should be False to trigger CU site reset for 2N pods |
    ...    *RETURN VALUE*
    ...    return the result delete pods .
    ...    Example
    ...    |  Tigger CU Specific 2N Pods Recovery By Delete Pod  | con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    ...    |  Tigger CU Specific 2N Pods Recovery By Delete Pod |  con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    log to console  Tigger CU Specific 2N Pods Recovery By Delete Pod
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  ${con}  ${ns}  ${pod_abbr}
    ${get_all_pods_cmd}  Set Variable   kubectl get pods -n ${ns} | grep -i ${pod_abbr} | awk '{print $1}'
    ${all_pods}  issh.Execute  command=${get_all_pods_cmd}  alias=${con}  check_result=False
    ${all_pods}   strip prompt  ${all_pods}
    ${all_pods}   Set Variable  ${all_pods.strip()}
    ${all_pods}   Evaluate  """${all_pods}""".replace("\\n","\\t")
    log to console  Trigger Delete All Pods ${pod_abbr}
    ${delete_result}  issh.Execute  command=kubectl delete pod ${all_pods} -n ${ns} --force  alias=${con}
    ...   check_result=False
    ${delete_result}   strip prompt  ${delete_result}
    ${delete_result}   Set Variable  ${delete_result.strip()}
    log to console  Trigger Result : ${delete_result}
    Run Keyword IF  ${check_recovery}==${TRUE}
    ...  wait until keyword succeeds  5min  10s  Check vCU Site Reset
    Run Keyword IF  ${check_recovery}==${TRUE}
    ...  wait until keyword succeeds  5min  10s  Check vCU Site Recovery
    Run Keyword IF  ${use_same_connection}==${False}
    ...  Disconnect Interactive Connection   ${con}
    [Return]  ${delete_result}

Trigger CU Specific Active 2N pods Recover By Delete Pod With Role Change
    [Arguments]  @{pod_abbr_list}  ${check_recovery}=${TRUE}  ${con}=${EMPTY}  ${ns}=${EMPTY}
    [Documentation]  keyword for triggerring All same name pods delete 
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | pod_abbr_list | Yes | a abbreviation of 2N podname list like :cpif  cpnb|
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session
    ...    | ns  | No | namespace 
    ...    | check_recovery | No | it should be TRUE when you just do delete once | 
    ...    *RETURN VALUE*
    ...    None , It'll trigger delete active pods and compare pods role after recovery
    ...    and give an option to check pods recovery
    ...    Example
    ...    |  Trigger CU Specific Active 2N pods Recover By Delete Pod With Role Change |
    ...    | cpif | con=alias or empty | ns=namespace or empty |
    ...    |  Trigger CU Specific Active 2N pods Recover By Delete Pod With Role Change |
    ...    | cpif  cpnb  cpcl | con=alias or empty | ns=namespace or empty |
    log to console  Trigger CU Specific Active 2N pods Recover By Delete Pod With Role Change
    @{active_pod_list}  CU Get 2N Active Pods List  @{pod_abbr_list}
    ${con}  ${ns}  ${useless}  _Create A vCU Session With Namespace And Podabbr Info  ${con}  ${ns}
    ${active_pod_string}  Evaluate  (" ").join(@{active_pod_list})
    log to console  ${active_pod_string}
    ${delete_result}  issh.Execute  command=kubectl delete pod ${active_pod_string} -n ${ns}  alias=${con}
    ${delete_result}   strip prompt  ${delete_result}
    ${delete_result}   Set Variable  ${delete_result.strip()}
    FOR  ${active_pod}  IN  @{active_pod_list}
        Run Keyword IF  ${check_recovery}==${TRUE}
        ...  wait until keyword succeeds  3min  10s  Get CU Specfic 2N Pods Recovery State After Pods Rebuild
        ...  con=${con}  ns=${ns}  full_pod_name=${active_pod}
    END
    CU 2N Pods Role Should Be Exchanged  ${active_pod_list}
    [Teardown]  Disconnect Interactive Connection   ${con}

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

_Get vCU Pods Status
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  keywrod for printing pods status default is all pods should be printed
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
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
    log to console  ${pods_print}

Get CU Specfic 2N Pods Recovery State After Pods Rebuild
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${full_pod_name}=${EMPTY}
    [Documentation]  keyword to check pods state change default is all pods
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
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
    # print pods status
    _Get vCU Pods Status  ${con}  ${ns}  ${full_pod_name}
    # check Pods Recovery Time
    ${check_recovery_time_cmd}=  Set Variable  kubectl get pods -n ${ns} | grep -i ${full_pod_name} | awk '{print $1\"\=\"$NF}'
    ${pods_live_time_info}=  issh.Execute  command=${check_recovery_time_cmd}  alias=${con}  check_result=${False}
    ${pods_live_time_info}  strip prompt  ${pods_live_time_info}
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
    @{container_list}  Create List 
    @{container_list}  evaluate   "${container_info}".split("\\n")
    log to console  Currently Container Recover Status ${container_list}
    FOR  ${i}  In  @{container_list}
      @{avaliable_number_list}   Create List
      @{avaliable_number_list}=  evaluate  "${i}".split("/")
      Should Be True  ${avaliable_number_list[0]}==${avaliable_number_list[-1]}
    END
    # check Pods Running Status 
    ${check_cmd}=  Set Variable  kubectl get pods -n ${ns} | grep -i ${full_pod_name} | grep -v Running | awk 'END{print NR}'
    ${wrong_state_pod_number}=  issh.Execute  command=${check_cmd}  alias=${con}  check_result=${False}
    ${wrong_state_pod_number}  strip prompt  ${wrong_state_pod_number}
    ${wrong_state_pod_number}  evaluate  ${wrong_state_pod_number.strip()}
    log to console  Currently ${full_pod_name} state is ${wrong_state_pod_number}
    Should Be True  ${wrong_state_pod_number}==${0}

Convert vCU Running Continue Time To Second 
    [Arguments]  ${time_format}
    [Documentation]  Conver format time to second
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | time_format | Yes | format time like : 3h4m |
    ...    *RETURN VALUE*
    ...    Continue time from pods running 
    ...    Example
    ...    | Convert vCU Running Continue Time To Second |  time_format=like 3h4m |
    ${time_format}  Evaluate  "${time_format}".replace("h","*3600s").replace("m","*60s")
    @{time}  Create List  
    @{time}  Evaluate  "${time_format}".strip().split("s")[:-1]
    ${time_second}  Set Variable  ${0}
    FOR  ${part}  In  @{time}
        ${time_second}  Evaluate  ${time_second}+${part}
    END
    [Return]   ${time_second} 

Check vCU Site Recovery 
    [Arguments]  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  Check vCU state back to normal
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace | 
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None , It will Check vCU site recovery whether happend  or not
    ...    Example
    ...    | Check vCU Site Recovery  |  con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    log to console  Check vCU Site Recovery 
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info  ${con}  ${ns}  ${pod_abbr}
    ${recoverd_cmd}  Set Variable 
    ...   kubectl get pods -o wide -n ${ns} | grep -v Running | grep -v Completed | awk \'END{print NR}\'
    ${collect_cmd}  Set Variable  kubectl get pods -o wide -n ${ns} | grep Running | awk \'END{print NR}\'
    ${current_restart_num}   issh.Execute  command=${collect_cmd}   alias=${con}  check_result=${False}
    ${current_restart_num}   strip prompt  ${current_restart_num}
    ${current_restart_num}   evaluate  ${current_restart_num.strip()}
    log to console  Currently Running Pods Number : ${current_restart_num} Recovery
    _Get vCU Pods Status  ${con}  ${ns}  ${pod_abbr}
    ${recoverd_status}=  issh.Execute  command=${recoverd_cmd}   alias=${con}  check_result=${False}
    ${recoverd_status}   strip prompt  ${recoverd_status}
    ${recoverd_status}   evaluate  ${recoverd_status.strip()}
    Should Be True  ${recoverd_status}==${1}

Check vCU Site Reset
    [Arguments]  ${expect_number}=${5}  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}  
    [Documentation]  Check vCU Site Reset
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | con | No | connection session |
    ...    | ns | No | namespace | 
    ...    | pod_abbr | No | abbreviation of podname. like :cpif |
    ...    *RETURN VALUE*
    ...    None , it will Check vCU Site Reset From OCP  
    ...    Example
    ...    | Check vCU Site Reset | expect_number=number of you think the cu is reset  | con=alias or empty |
    ...    | ns=namespace or empty | pod_abbr=abbreviation of podname or empty |
    ${con}  ${ns}  ${pod_abbr}  _Create A vCU Session With Namespace And Podabbr Info    ${con}  ${ns}  ${pod_abbr}
    ${cmd}  Set Variable   kubectl get pods -o wide -n ${ns} | grep Running | awk \'END{print NR}\'
    ${current_restart_num}   issh.Execute  command=${cmd}   alias=${con}  check_result=${False}
    ${current_restart_num}   strip prompt  ${current_restart_num}
    ${current_restart_num}   evaluate  ${current_restart_num.strip()}
    _Get vCU Pods Status  ${con}  ${ns}  
    log to console  Currently Running Pods Number : ${current_restart_num}
    ${site_status}  Run Keyword If  ${current_restart_num}<${expect_number}  Set Variable  CU Reset Triggered
    ...  ELSE  Set Variable  No Trigger Reset Now
    log to console  ${site_status}
    Should Be Equal As Strings  ${site_status}  CU Reset Triggered

Check vCU Not Happen Site Reset
    [Arguments]  ${expect_number}=${5}  ${con}=${EMPTY}  ${ns}=${EMPTY}  ${pod_abbr}=${EMPTY}
    [Documentation]  Check vCU Not Happen Site Reset
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <05-17-2023>, <jieyang>, <initial created>
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
    ${current_restart_num}   evaluate  ${current_restart_num.strip()}
    _Get vCU Pods Status  ${con}  ${ns}
    log to console  Currently Running Pods Number : ${current_restart_num}
    ${site_status}  Run Keyword If  ${current_restart_num}<${expect_number}  Set Variable  CU Reset Triggered
    ...  ELSE  Set Variable  No Trigger Reset Now
    log to console  ${site_status}
    Should Be Equal As Strings  ${site_status}  No Trigger Reset Now

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
    log to console  currently ${active_pods} restart number is ${restart_times}
    [Return]  ${restart_times}

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
    ${expect_result}=   Run Keyword If  ${current_num}==${0}  Set Variable  Check Restart Time
    ...  ELSE  Set Variable  Check Pods Role Change
    [Return]  ${expect_result}

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
    [Teardown]  Disconnect Interactive Connection   ${con}

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
    ...  process=${process}   alias=${con}   check_result=False
    wait until keyword succeeds   2min   5s   Get CU Specfic 2N Pods Recovery State After Pods Rebuild  
    ...  full_pod_name=${active_pod}
    ${expect_active_pods}=  CU Get Active Pod Name By Specified Pod  pod_abbr=${pod_abbr} 
    ${expect_restart_numb}=  _Get vCU Specified Active Pod Container Restart Times  con=${con}  pod_abbr=${pod_abbr}
    Run Keyword IF  "${expect_checkpoint}"=="Check Restart Time"  Should Be True  ${expect_restart_numb}==${1}
    ...   ELSE   Should Be Equal As Strings  ${expect_active_pods}  ${standby_pod}
    Disconnect Interactive Connection   ${con}

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
    FOR    ${tag}  IN RANGE   5
        log to console  currently loop times is : ${tag}
        Trigger CU Specific Process Recovery By Delete Process  pod_abbr=${pod_abbr}  container=${container}
        ...  process=${process}
    END


Tigger CU Specific 2N Pods Recovery By Delete Pod With Site Reset Check 
    [Arguments]  ${pod_abbr}=${EMPTY}  ${check_recovery}=${False}
    [Documentation]  Keyword For User To Trigger Site Reset By loop Delete Pod
    ...  author:            shouxiang.jiao@nokia-sbell.com
    ...  modified by:       <04-19-2023>, <shojiao>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | abbreviation of podname. like :cpif |
    ...    | check_recovery | Yes. | During Trigger Site Rest It should set to False to save time |
    ...    *RETURN VALUE*
    ...    None  It'll trigger delete pods 100000 times until vCU Site Reset
    ...  *Example*
    ...    | Tigger CU Specific 2N Pods Recovery By Delete Pod With Site Reset Check  | pod_abbr=cpif |
    log to console  Tigger CU Specific 2N Pods Recovery By Delete Pod With Site Reset Check 
    ${start_time}=  evaluate  time.time()  time
    ${con}=  Connect To CU K8S Master With Tenant
    ${ns}=  Get CU Namespace From Testline
    ${tag}=  Set Variable  1    
    FOR    ${tag}  IN RANGE   100000
        log to console  currently loop times is : ${tag}
        ${delete_result}=  Tigger CU Specific 2N Pods Recovery By Delete Pod  pod_abbr=${pod_abbr}  check_recovery=${check_recovery}
        ...  con=${con}  ns=${ns}
        Exit For Loop If  '''${delete_result}'''=='''error: resource(s) were provided, but no name was specified'''
    END
    ${end_time}=  evaluate  time.time()  time
    wait until keyword succeeds  5min  10s  Check vCU Site Reset
    wait until keyword succeeds  5min  10s  Check vCU Site Recovery
    ${exec_time}=  evaluate  ${start_time}-${end_time}   
    [Return]  ${exec_time}
    [Teardown]  Disconnect Interactive Connection   ${con}

Scale vCU Specified Pod To Specified Amount
    [Arguments]  ${pod_name}    ${pod_amount}    ${gnb_index}=0
    log to console     scale pods to specified amount
    ${conn} =  Connect To CU K8S Master With Tenant
    ${ns}   Get CU Namespace From Testline   gnb_index=0
    ${cmd}   set variable   kubectl scale statefulset po-${ns}-${pod_name} --replicas=${pod_amount}
    ${out}   issh.Execute  command=${cmd}   alias=${conn}
    Wait Until Keyword Succeeds    10min    20s    Check Pod Scaled To Specified Amount    ${pod_name}    ${pod_amount}
    Disconnect Interactive Connection   ${conn}

Check Pod Scaled To Specified Amount
    log to console     Check Pod Scaling To Specified amount
    [Arguments]  ${pod_name}    ${pod_amount}    ${gnb_index}=0
    ${conn} =  Connect To CU K8S Master With Tenant
    ${ns}   Get CU Namespace From Testline   gnb_index=0
    ${check_scaleout_cmd}  Set Variable  kubectl get pods -n ${ns} | grep -i ${pod_name} | wc -l
    ${scaleout_result}=  issh.Execute  command=${check_scaleout_cmd}   alias=${conn}  check_result=${False}
    ${scaleout_result}  strip prompt  ${scaleout_result}
    Should Be Equal    ${scaleout_result}    ${pod_amount}

Trigger vCU Link Redundancy Switchover
    [Arguments]    ${pod_name}
    log to console    Trigger vCU link redundancy switchover
    ${conn} =  Connect To CU K8S Master With Admin
    ${active_pod}=  CU Get Active Pod Name    pod_name=${pod_name}   alias=${conn}
    ${ctr_name}   Get CU Full Container Name By Container Abbreviation  nwmgmt
    Trigger CPIF link redundancy switch   pod_name=${active_pod}   container=${ctr_name}  link=extc  link2=extcs
     ...    alias=${conn}  check_result=False
    wait until keyword succeeds    3min    30s
    ...   Check Pod Active Role Change After Link Redundancy Switch   active_pod=${active_pod}   pod_name=${pod_name}   alias=${conn}
	
Check Pod Active Role Change After Link Redundancy Switch
    [Arguments]    ${active_pod}   ${pod_name}   ${alias}=default
    ${act_pod_new}=  CU Get Active Pod Name    pod_name=${pod_name}   alias=${alias}
    should not be equal  ${active_pod}   ${act_pod_new}

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
