*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_cloud_recovery.robot
...




*** Variables ***



*** Keywords ***
__Get All RCPSDL Pods Name
    [Arguments]  ${ns}  ${conn_alias}
    ${cmd}   set variable  kubectl get pods -n ${ns}
    ${out}   issh.Execute   command=${cmd}   alias=${conn_alias}
    should be true   "No resources found" not in """${out}"""

    ${cmd}   set variable  ${cmd}|egrep "(-rcpsdl-)" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${conn_alias}
    ${out}   strip prompt  ${out}
    ${rcpsdl_pods_name_list}     Split To Lines   ${out}
    [Return]  ${rcpsdl_pods_name_list}

__Determine_RCPSDL_Role
    [Arguments]  ${rcpsdl_pods_list}   ${ns}   ${conn_alias}   ${vdu_index}=0
    ${command}=   set variable   redis-cli -h rcpsdl-announce-0 -p 26379 sentinel get-master-addr-by-name session
    ${out}=  Kubectl Exec Interactively  pod_abbr=rcpsdl   container=rcpsdl  command=${command}  alias=${conn_alias}
    ...  vdu_index=${vdu_index}  with_bash=${True}
    ${lines}    Split To Lines   ${out}
    ${master_rcpsdl_ip}   Set Variable   ${lines[0].split()[1].strip()}
    ${cmd}   set variable   kubectl get svc -n ${ns}|grep rcpsdl|grep ${master_rcpsdl_ip} |awk '{print $1}'
    ${out}   issh.Execute  command=${cmd}   alias=${conn_alias}
    ${out}   strip prompt  ${out}
    ${master_rcpsdl_announce}   Set Variable  ${out.strip()}
    ${words}=  split string  ${master_rcpsdl_announce}  -
    ${master_rcpsdl_index}    set variable  ${words[-1]}
    ${master_rcpsdl_pod}   set variable   po-${ns}-rcpsdl-${master_rcpsdl_index}
    remove values from list    ${rcpsdl_pods_list}   ${master_rcpsdl_pod}
    ${rcpsdl_role_status}    Create Dictionary
    set to dictionary   ${rcpsdl_role_status}   master  po-${ns}-rcpsdl-${master_rcpsdl_index}
    set to dictionary   ${rcpsdl_role_status}   slave  ${rcpsdl_pods_list}
    [Return]  ${rcpsdl_role_status}


Get RCPSDL Role Status
     [Arguments]  ${vdu_index}=${0}
     [Documentation]    get the RCPSDL pods role type, connect and disconnect to OE are included in this keyword.
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index | No | vdu_index. Default value is 0 |

    ...    *RETURN VALUE*
    ...    dict like: {'master': 'po-cran3-rcpsdl-0', 'slave': ['po-cran3-rcpsdl-1', 'po-cran3-rcpsdl-2']}

     ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
     ${alias}  Get Unique Id
     Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}
     ${rcpsdl_pods_name_list}=   __Get All RCPSDL Pods Name   ${ns}   ${alias}
     ${rcpsdl_role_status}=   __Determine_RCPSDL_Role   ${rcpsdl_pods_name_list}   ${ns}   ${alias}   ${vdu_index}
     [Return]  ${rcpsdl_role_status}
     [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}
#     Set Test Variable   ${RCPSDL_Role_Status}  ${rcpsdl_role_status}

Trigger vDU Pods Restart By Killing Ministarter
    [Arguments]  ${pod_abbr}  ${con_abbr}   ${pod_index}=0   ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    trigger vDU pod restart by killing ministarter process,
    ...    connect and disconnect to OE are included in this keyword.
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | con_abbr | Yes | container name appreviation, eg, rcpsdl |
    ...    | pod_index | No | pod index if there are many pod, like 0 for rcpsdl-0 |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...    | gnb_index | No | gnb_index, Default value is 0 |

    ...    *RETURN VALUE*
    ...    None

    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${alias}  Get Unique Id
    Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}   gnb_index=${gnb_index}
     ${command}=   set variable   kill 1
    ${out}=  Kubectl Exec Interactively  pod_abbr=${pod_abbr}   container=${con_abbr}  command=${command}  alias=${alias}
    ...  vdu_index=${vdu_index}  with_bash=${True}   pod_index=${pod_index}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}


Get vDU Pod Restart Times
    [Arguments]  ${pod_abbr}   ${pod_index}=0   ${vdu_index}=0
    [Documentation]    get vdu pod restart times, connect and disconnect to OE are included in this keyword.
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | pod_index | No | pod index if there are many pod, like 0 for rcpsdl-0 |
    ...    | vdu_index | No | vdu_index. Default value is 0 |

    ...    *RETURN VALUE*
    ...    the pod restart times

    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
     ${alias}  Get Unique Id
     Connect To K8s Master With Tenant Interactively   vdu_index=${vdu_index}  alias=${alias}

    ${cmd}   set variable    kubectl get pods -n ${ns}|egrep "(-${pod_abbr}-${pod_index})" |awk '{print $4}'
    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${num_reset}   strip prompt  ${out}
    [Return]   ${num_reset}
    [Teardown]  Run Keyword And Ignore Error    Disconnect Interactive Connection  alias=${alias}

Trigger DU Pod Recovery
    [Arguments]  ${vdu_index}=0    ${pod_abbr}=cprt
    [Documentation]  trigger du pod recovery by deleting the pod
    ...  author:            alisha.wu@nokia-sbell.com
    ...  modified by:       <06-23-2023>, <aliwu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | Yes. | the pod name abbreviation or the full pod name |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the command output
    ...  *Example*
    ...    | Trigger DU Pod Recovery | 1 | oamext |
    ${ns}    Get vDU Namespace From TestLine    vdu_index=${vdu_index}
    ${alias}    Get Unique Id
    Connect To K8s Master With Tenant Interactively    vdu_index=${vdu_index}    alias=${alias}
    ${pod_name}   Get Full Pod Name By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   vdu_index=${vdu_index}   alias=${alias}
    ${out}  issh.Execute  command=kubectl delete pod ${pod_name} -n ${ns}   alias=${alias}
    ${out}   strip prompt   ${out}
    ${out}   Set Variable   ${out.strip()}
    [Return]  ${out}

Get Rannic Info From SCF
    [Arguments]    ${mrbts_id}    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    get rannic information from plan.
    ...    *AUTHOR*  sophie.jiang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | mrbts_id | Yes | provide the mrbts_id for you testline |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...    | gnb_index | No | gnb_index. Default value is 0 |

    ...    *RETURN VALUE*
    ...    rannic detailed infomation: active_sw_version, hw_version, nokia_pn, operational_state, procedural_status,
    ...    product_code, product_name, r_nic_mod_dist_name, serial_number, usage_state
    log to console    Get Rannic Info
    ${alias}=  get unique id
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    ${rnic_status}=    vdu.get_rnic_info_from_plan    mrbts_id=${mrbts_id}    vdu_connection=${alias}
    [Return]    ${rnic_status}
    [Teardown]  vdu.disconnect   ${alias}

Get Rannic Number And ModList
    [Arguments]    ${mrbts_id}
    [Documentation]    get rannic information from plan.
    ...    *AUTHOR*  sophie.jiang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | mrbts_id | Yes | provide the mrbts_id for you testline |

    ...    *RETURN VALUE*
    ...    rannic number and runnic mod list
    ${rnic_status}=    Get Rannic Info From SCF    mrbts_id=${mrbts_id}
    ${rnic_num}=   get length    ${rnic_status}
    @{rnic_mod_list}=  create list
    FOR   ${index}   IN RANGE   0    ${rnic_num}
       append to list  ${rnic_mod_list}   ${rnic_status[${index}]['r_nic_mod_dist_name']}
    END
    [Return]    ${rnic_num}    @{rnic_mod_list}

Trigger Rannic Reset
    [Arguments]    ${rnic_mod_dist_name}    ${vdu_index}=0    ${gnb_index}=0    ${timeout}=60
    [Documentation]    trigger rannic reset in this keyword.
    ...    *AUTHOR*  sophie.jiang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | rnic_rmod | Yes | provide the rnic_rmod for you testline |
    ...    | vdu_index | No | vdu_index. Default value is 0 |
    ...    | gnb_index | No | gnb_index. Default value is 0 |
    ...    | timeout | No | timeout. Default value is 60 |

    ...    *RETURN VALUE*
    ...    None
    log to console    start to reset rannic
    ${alias}=  get unique id
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}  alias=${alias}
    vdu.reset_rannic    rannic_r_dn=${rnic_mod_dist_name}    timeout=${timeout}    vdu_connection=${alias}
    [Teardown]  vdu.disconnect   ${alias}

Rannic Status Should Be As Expected
    [Arguments]    ${rnic_mod_list}    ${expected_operational_state}    ${expected_availability_state}
    [Documentation]    Check Rannic Status.
    ...    *AUTHOR*  sophie.jiang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | rnic_mod_list | Yes | provide the rnic_rmod for you testline |
    ...    | expected_operational_state | Yes | provide the status of operational_state, enabled or disabled |
    ...    | expected_availability_state | Yes | provide the status of procedural_status, on line or off line |

    ...    *RETURN VALUE*
    ...    None
    log to console    Check Rannic Status
    ${mrbts_id}=    Set Variable  ${rnic_mod_list[0].split('/')[0].split('-')[-1]}
    ${rnics_info}=    Get Rannic Info From SCF    mrbts_id=${mrbts_id}
    log to console    ${rnics_info}

    FOR  ${rnic_info}   IN  @{rnics_info}
        Run Keyword If  '${rnic_info}[r_nic_mod_dist_name]' in ${rnic_mod_list}   Run Keywords
        ...  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${rnic_info}[operational_state]  ${expected_operational_state}
        ...  AND  Run Keyword And Continue On Failure  Should Be Equal As Strings  ${rnic_info}[procedural_status]  ${expected_availability_state}
    END

