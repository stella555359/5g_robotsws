*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_sec_cert.robot



#*** Variables ***



*** Keywords ***
Get MRBTS Id From vCU SCF
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get MRBTS Id From vCU SCF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb index | No | cu index, defualt is 0 |
    ...    *RETURN VALUE*
    ...    - MRBTS_ID from vCU Scf
    ...    *Example*
    ...    | ${mrbts_id} | Get MRBTS Id From vCU SCF |
    ...
    ${vcu_conf}    Get VCU Conf From SCF    gnb_index=${gnb_index}
    ${mrbts_id}  set variable      ${vcu_conf["mrbts_id"]}
    [Return]   ${mrbts_id}


Get VCU Conf From SCF
    [Arguments]  ${scf_path}=${EMPTY}   ${gnb_index}=0
    [Documentation]  Get Vcu Conf From SCF file.
    ...  author: zhong.1.chen@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  10.9.2021,zhong.1.chen@nokia-sbell.com, Add support to automatically download scf file via REST if ${scf_path} is ${EMPTY}
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | scf_path  | no | abosolute path of scf file, if it's ${EMPTY} it will download scf from CURRENT plan, default is ${EMPTY} |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of configuration in SCF file.
    ...    example: {'mrbts_id': '1234', 'nrbts_id': '5678', 'nrdu_id': '1', 'tnl_oam': '3',
    ...    'tnl_version': 'TNLVDU20B_2006_001' }
    ...
    ...    Example
    ...    | ${vcu_conf} | Get VCU Conf From SCF | scf_path=/home/ute/a.scf |
    ...    | ${vcu_conf} | Get VCU Conf From SCF |
    ...
    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get VCU SCF From Current Plan   gnb_index=${gnb_index}
       ...    ELSE    set variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${tnl_oam}   Get vDU TNL ID   scf_path=${scf_path}  templateType=OAM
    ${tnl_version}   scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/TNLSVC-1   attribute=version
    ${nrbts_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu_id}   attribute=version
    ${mnl_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/MNL-1   attribute=version
    #${eqm_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/EQM-1  attribute=version
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  tnl_oam=${tnl_oam}
    ...  tnl_version=${tnl_version}
    ...  nrbts_version=${nrbts_version}
    ...  mnl_version=${mnl_version}
	#...  eqm_version=${eqm_version}
    [Return]  ${conf}


Get gnb CU type
    [Documentation]   Get gnb CU type
    ...   *AUTHOR* ling.2.zhao@nokia-sbell.com
	...    modified by:        <08-09-2021>, <lingzhao>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   *RETURN VALUE*
    ...   string
    ...   Example
    ...   | ${gNbCuType}  |  Get gnb CU type |
    Log to Console   Get gnb CU type
    CU Login
    ${plan_file_path}=    Get A File    SCF    vcu_scf.xml
    ${scf_file_fullpath}   cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    ${gNbCuType}  scf.Get_Value_From_Scf   dist_name=${nrbts_distname}  p_name=gNbCuType
    [Return]   ${gNbCuType}

VCU Check Static Route Configured
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}=None  ${gateway}=None  ${preference}=None
    [Documentation]    Vcu Static Route check exists or not
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Check whether the given route policy exist under dist MO
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | static route distname |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength  | yes | PrefixLength for static route |
    ...    | gateway  | yes | gateway for static route |
    ...    | preference   | yes | preference for static route |
    ...
    ...    *RETURN VALUE*
    ...    list: static route exist or not,  index number if route exist
    ...
    ...    Example
    ...    | ${route_exists}  ${index} | VCU Check Static Route Configured | ${dist} |
    ...    | ${destIpAddr} | ${PrefixLength} | ${gateway} | ${preference} |
    ${uni_id}   Get Unique Id
    CU Login
    ${scf_full_path}  Get A File    SCF    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${gateway_name}   set variable if  ':' in '''${destIpAddr}'''   gatewayIpv6Addr   gateway
    ${gateway_info}   scf.Get All Values From Scf   dist_name=${dist}   p_name=${gateway_name}
    ${gateway_len}   Get Length   ${gateway_info}
    ${rt_exist}=    Set Variable    ${False}
    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
    Log To Console   ${destIpAddr}
    ${index}   set variable  0
    FOR    ${i}    IN RANGE    0    ${gateway_len}
        ${res}  Run Keyword And Ignore Error   VCU Check Static Route Index configured
    ...  ${dist}  ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}  ${i}
        ${rt_exist}=   Set Variable If   '${res[0]}'=='PASS'   ${True}   ${False}
        ${index}=   Set Variable If   '${res[0]}'=='PASS'   ${i}   0
        exit for loop if  '${rt_exist}'=='${True}'
    END
    [Return]    ${rt_exist}    ${index}

VCU Check Static Route Index configured
    [Arguments]   ${dist}  ${destIpAddr}  ${PrefixLength}=None  ${gateway}=None  ${preference}=None  ${index}=0
    [Documentation]    Vcu Static Route should exist in specific index
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Check whether the given route policy exist under dist MO
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | static route distname |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength  | yes | PrefixLength for static route |
    ...    | gateway  | yes | gateway for static route |
    ...    | preference   | yes | preference for static route |
    ...    | index   | no | index of configured static route |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VCU Check Static Route Index configured | ${dist} |
    ...    | ${destIpAddr} | ${PrefixLength} | ${gateway} | ${preference} | 0 |
    ${destip_par}   set variable if  ':' in '''${destIpAddr}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  ':' in '''${destIpAddr}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  ':' in '''${destIpAddr}'''   gatewayIpv6Addr   gateway
    ${route_list_name}  Set Variable If  ':' in '${destIpAddr}'  staticIpv6Routes  staticRoutes

    ${destIpAddr1}    scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_list_name}
    ...  p_name=${destip_par}  index=${index}
    ${destIpAddr1}   Replace String Using Regexp   ${destIpAddr1}   :0+  :
    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
    Should Be True   '${destIpAddr1}'=='${destIpAddr}'
    ${PrefixLength1}  Run Keyword If  "${PrefixLength}"!="None"  scf.Get_Value_From_Scf
    ...  dist_name=${dist}  list_name=${route_list_name}  p_name=${prefix_par}  index=${index}
    Run Keyword If  "${PrefixLength}"!="None"  Should Be True   '${PrefixLength1}'=='${PrefixLength}'
    ${gateway1}  Run Keyword If  "${gateway}"!="None"   scf.Get_Value_From_Scf
    ...   dist_name=${dist}  list_name=${route_list_name}  p_name=${gw_par}  index=${index}
    ${gateway1}   Replace String Using Regexp   ${gateway1}   :0+  :
    ${gateway}   Replace String Using Regexp   ${gateway}   :0+  :
    Run Keyword If  "${gateway}"!="None"  Should Be True   '${gateway1}'=='${gateway}'
#    ${preference1}  Run Keyword If  "${preference}"!="None"  scf.Get_Value_From_Scf
#    ...  dist_name=${dist}  list_name=${route_list_name}  p_name=preference  index=${index}
#    Run Keyword If  "${preference}"!="None"  Should Be True   '${preference1}'=='${preference}'

Vcu Add Route
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8
    [Documentation]    Add static route for vcu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Add static route for vcu
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | distname to add static route |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength   | yes | PrefixLength for static route |
    ...    | gateway   | yes | gateway for static route |
    ...    | preference   | no | preference for static route, default is 8 |
    ...
    ...    *RETURN VALUE*
    ...   list of route info  [static route distname,  /staticRoutes/index]
    ...
    ...    Example
    ...    | CU Login |
    ...    | ${route_info} | Vcu Add Route | dist  | 1.1.1.1 | 24 | 1.1.1.2 |
    ...    | CU Logout |
    ...
    ${route_list_name}  Set Variable If  ':' in '''${destIpAddr}'''  staticIpv6Routes  staticRoutes
    ${route_exists}   ${index}   VCU Check Static Route Configured
    ...  ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}
    ${res}  Run Keyword If  "${route_exists}"=="${True}"   create list  ${dist}  /${route_list_name}/${index}
    Return From Keyword If  "${route_exists}"=="${True}"    ${res}
    ${route_dstip_name}  Set Variable If  ':' in '''${destIpAddr}'''  destIpv6Addr  destIpAddr
    ${route_prefix_name}  Set Variable If  ':' in '''${destIpAddr}'''  destinationIpv6PrefixLength
    ...  destinationIpPrefixLength
    ${route_gateway_name}  Set Variable If  ':' in '''${destIpAddr}'''  gatewayIpv6Addr  gateway
    ${route_dn_name}  Set Variable If  ':' in '''${destIpAddr}'''   IPRTV6  IPRT
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}   p_name=${route_gateway_name}
    ${length}   Run Keyword If  '${res[0]}'=='PASS'   Get Length   ${res[1]}
    ...  ELSE    Set Variable  0
    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1

    ${rt_object_exist}  scf.is_object_in_scf  dist_name=${dist}
    Run Keyword If  ${rt_object_exist}!=${True}   CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${delta_plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:${route_dn_name}  instance_id=${index}
    &{static_list}  Create Dictionary   operation_type=add    parameter_path=/${route_list_name}
    @{para_list}=    Create List  ${static_list}
    Run Keyword If   ${length}==0  CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}
    ...  mo_dn=${dist}
    ...  parameter_change_list=${para_list}
    Sleep  2sec
    #&{gateway}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/${route_gateway_name}  value=${gateway}
    #&{destIpAddr}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/${route_dstip_name}  value=${destIpAddr}
    &{destinationIpPrefixLength}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/${route_prefix_name}  value=${PrefixLength}
    #&{preference}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/preference  value=${preference}
    @{route_Para_list}=    Create List  ${gateway}   ${destIpAddr}  ${destinationIpPrefixLength}  ${preference}
	CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${dist}
	...  parameter_change_list=${route_Para_list}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_iprt_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${delta_plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    [Return]   ${dist}  /${route_list_name}/${length}

Vcu Delta Remove Items
    [Arguments]   ${item_list_to_remove}
    [Teardown]   CU Logout
    [Documentation]    Vcu Delta Remove Items for vcu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Delta Remove Items for vcu
    ...    | Input Parameters | Man. | Description |
    ...    | item_list_to_remove | yes | each item should contain distname and item name with index |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Vcu Delta Remove Items | ${item_list_to_remove} |
    ...
    ${item_length}     get length    ${item_list_to_remove}
    Return From Keyword If   ${item_length}==0
    CU Login
    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    ${mo_to_remove}  Create List
    FOR  ${item}  IN  @{item_list_to_remove}
        ${prefix}   ${rest}   Split String From Right   ${item[1]}   /   1
        ${prefix1}   ${rest1}   Split String From Right   ${item[0]}   -   1
        Run Keyword If  ${rest}==0 and ${rest1}>1   Append To List    ${mo_to_remove}   ${item[0]}
        ${number}   Count Values In List   ${mo_to_remove}    ${item[0]}
        Run Keyword If  ${number}>=1  CU Delete Delta Plan Managed Object Should Be Successful
	...  plan_id=${delta_plan_id}   mo_dn=${item[0]}
        Continue For Loop If  ${number}>=1
        &{paras_list}  Create Dictionary   operation_type=remove    parameter_path=${item[1]}
        @{para_list}=    Create List  ${paras_list}
        CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${item[0]}
    ...  parameter_change_list=${para_list}
    END
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_remove_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${delta_plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}

Vcu Add Rtpol
    [Arguments]  ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}
    [Documentation]    Add route policy for vcu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Add route policy for vcu
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | distname to add route policy |
    ...    | orderNumber   | yes | orderNumber for route policy |
    ...    | routingTableDN   | yes | routingTableDN for route policy |
    ...    | srcIpAddress   | yes | srcIpAddress for route policy |
    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for route policy |
    ...
    ...    *RETURN VALUE*
    ...   list of route policy info  [routingPolicies distname,  /routingPolicies/index]
    ...
    ...    Example
    ...    | CU Login |
    ...    | ${pol_info} | Vcu Add Rtpol | ${dist} | 5 | ${routingTableDN} | 1.1.1.1 | 24 |
    ...    | CU Logout |
    ...
    ${uni_id}   Get Unique Id

    ${scf_full_path}  Get A File    SCF    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}

    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}   p_name=orderNumber
    ${length}   Run Keyword If  '${res[0]}'=='PASS'  Get Length   ${res[1]}
    ...  ELSE    Set Variable  0

    ${delta_plan_id}=  CU Generate Delta Plan Should Be Successful
    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    Run Keyword If  ${length}==0   CU Create Delta Plan Managed Object Should Be Successful  plan_id=${delta_plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:RTPOL  instance_id=${index}
    &{policy_list}  Create Dictionary   operation_type=add    parameter_path=/routingPolicies
    @{para_list}=    Create List  ${policy_list}
    Run Keyword If   ${length}==0  CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${dist}
    ...  parameter_change_list=${para_list}
    Sleep  2sec
    &{ordern}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/orderNumber  value=${orderNumber}
    &{routedn}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/routingTableDN  value=${routingTableDN}
    &{srcip}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/srcIpAddress  value=${srcIpAddress}
    &{srciplength}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/srcIpPrefixLength  value=${srcIpPrefixLength}
    @{policy_para_list}=    Create List  ${ordern}   ${routedn}  ${srcip}  ${srciplength}
	CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${dist}
	...  parameter_change_list=${policy_para_list}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_rtpol_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${delta_plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    [Return]   ${dist}  /routingPolicies/${length}


Vcu Static Route Should Exist In Forwarding Entries
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8
    [Documentation]    Vcu Static Route Should Exist In Forwarding Entries
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Check whether the given route policy exist under dist MO
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | static route distname |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength  | yes | PrefixLength for static route |
    ...    | gateway  | yes | gateway for static route |
    ...    | preference   | yes | preference for static route |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Cu Login |
    ...    | ${scf_full_path}  Get A File   |  SCF  |   vcu_scf.xml |
    ...    | cu.Get Current Plan File  |  path=${scf_full_path} | timeout=60 |
    ...    | scf.Load_Scf  file_path=${scf_full_path} |
    ...    | ${routeexistflag} | Vcu Static Route Should Exist In Forwarding Entries | ${dist} |
    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
    ...    | Cu Logout |
    ...
    ${gateway_name}   set variable if  ':' in '''${gateway}'''   gatewayIpv6Addr   gateway

    ${gateway_info}   scf.Get All Values From Scf   dist_name=${dist}   p_name=${gateway_name}
    ${gateway_len}   Get Length   ${gateway_info}
    ${rt_exist}=    Set Variable    ${False}
    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
    Log To Console   ${destIpAddr}
    FOR    ${i}    IN RANGE    0    ${gateway_len}
        ${res}  Run Keyword And Ignore Error   Vcu Check Static Route Index
    ...  ${dist}  ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}  ${i}
        ${rt_exist}=   Set Variable If   '${res[0]}'=='PASS'   ${True}   ${False}
        exit for loop if  '${rt_exist}'=='${True}'
    END
    Should Be True  '${rt_exist}'=='${True}'   static route is not exist for ${dist}!


Get VCU SCF From Current Plan
    #[Arguments]    ${gnb_index}=0
    [Documentation]  Get VCU SCF From Current Plan
    ...  author: zhong.1.chen@nokia-sbell.com
    ...  Change History
    ...  6.12.2021   chris.l.cao@nokia-sbell.com,  make it work in real VCU
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | vcu_index | no | vcu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${vcu_conf} | Get VCU SCF From Current Plan |
    ...
    ${file_name}   get unique id  prefix=scf_tmp_   suffix=.xml   precise=LOW
    ${tmp_scf_full_path}=  Get A File  temp_scf   ${file_name}
    CU Rest Login
    cu.get_current_plan_file   path=${tmp_scf_full_path}  timeout=60  include_runtime_data=${False}
    #scf.Load_Scf  file_path=${tmp_scf_full_path}
    [Return]  ${tmp_scf_full_path}



CU Full Commission
    [Arguments]    ${path_of_commission_file}   ${plan_name}=default_plan_name   ${solution}=rest   ${gnb_index}=0
    [Documentation]   Send BTS commission via rest or webui.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <15-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  path_of_commission_file | Yes. | Path of commission file |
        ...	   |  plan_name  | No. |  Plan file name displayed on weebui after scf load |
        ...	   |  solution  |  No. |  Solution for sending plan, can be rest or webui |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    | CU Full Commission  |  /tmp/commission.xml  |    3219_plan_file   |  rest  |
    run keyword if  "${solution}"=="rest"    CU Full Commssion By Rest     ${path_of_commission_file}   ${plan_name}  ${gnb_index}
    ...   ELSE    CU Full Commission By Webui    ${path_of_commission_file}   ${plan_name}   ${gnb_index}

CU Full Commssion By Rest
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
    [Documentation]   Send BTS commission via rest.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  path_of_commission_file  | Yes. | Path of commission file |
        ...	   |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commssion By Rest  |   /tmp/commission.xml  |    3219_plan_file   |
     CU Login  ${gnb_index}
     log to console   \n*** Start plan upload operation ***
     ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
     log to console   \n*** Wait plan upload operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
     ...    ${upload_operation_info["action_id"]}    success
     log to console   \n*** Start plan validate operation ***
     ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan validate operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
     log to console   \n*** Start plan activate operation ***
     ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan activate operation success in 5 mins ***
     wait until keyword succeeds    900s   30s  CU Check Plan Activate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
     [Teardown]    run keyword and ignore error   CU Logout


CU Full Commission By Webui
    #[Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
    [Documentation]   Send BTS commission via webui.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  path_of_commission_file  | Yes |  Path of plan file  |
        ...	   |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commission By Webui  |  /tmp/commission.xml  |   3219_plan_file   |   0  |
     Log    Send commission by webui not ready!    WARN



CU Check Plan Upload Status Should Be As Expected
   [Arguments]  ${operation_id}   ${expected_status}
   [Documentation]   Check plan upload status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  operation_id  | Yes. |  Operation id for uploading plan file  |
        ...	   |  expected_status  | Yes. |  Expected upload status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Upload Status Should Be As Expected   |  a_6cfa594f-0938-4732-a78c-16afdbd214d2 |    success   |
   ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan validate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id  | Yes. |  Plan file id  |
        ...	   |  operation_id  | Yes. |  Operation id for validating plan file  |
        ...	   |  expected_status  | Yes. |  Expected validate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Validate Status Should Be As Expected  |  sp_39d02514-e65b-46db-9ad7  |  a_0c7769bd-78ae-4505-9ce1 |  success  |
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Activate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan activate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id  | Yes. |  Plan file id  |
        ...	   |  operation_id  | Yes. |  Operation id for activating plan file  |
        ...	   |  expected_status  | Yes. |  Expected activate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Activate Status Should Be As Expected   |  sp_39d02514-e65b-46db-9ad7 |  o_c1ca0de5-3225-46e4-86bd  |  success  |
   ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"


CU Backup SCF
    [Arguments]    ${stored_path}=${EMPTY}  ${gnb_index}=0
    [Documentation]   Save current plan file on CU.
        ...    author: fen.huang@nokia-sbell.com
        ...   modified by:        <24-Apr-2020>, <f2huang>, <Initial creation>
        ...   modified by:        <14-Jan-2022>, <r3li>, <modify plan_file_path>
        ...    | Input Parameters | Man. | Description |
        ...	   |  stored_path | No. | where to store saved plan file  |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    Stored path of commission file.

        ...    Example
        ...    |  CU Backup SCF  |    |
    # ${oam_conn}=    CU SSH To OAM
    ${time_stamp}=  Get Time   exclude_millis=yes
    ${time_stamp}=  replace string  ${time_stamp}  ${SPACE}  \
    ${time_stamp}=  replace string  ${time_stamp}  -   \
    ${time_stamp}=  replace string  ${time_stamp}  :   \
    ${plan_file_path}=    Get A File    SCF    scf_${time_stamp}_cu.xml
    CU Login  ${gnb_index}
    ${where_to_store_plan_file}=    run keyword if   "${stored_path}"=="${EMPTY}"   set variable    ${plan_file_path}
    ...  ELSE    set variable    ${stored_path}
    cu.get_current_plan_file    ${where_to_store_plan_file}   timeout=60
    [Return]     ${where_to_store_plan_file}
    [Teardown]   run keyword and ignore error   CU Logout

CU Delete Plan
    [Arguments]     ${plan_id}  ${gnb_index}=0
    [Documentation]   Delete stage plan on CU.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <23-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id | Yes. | Plan id |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Delete Plan  |  sp_d211beda-246f-40e2-97ec-57e9961fc094   |
    ${plan_exist_flag}=    CU Check Stage Plan Exist    ${plan_id}    ${gnb_index}
    CU Login  ${gnb_index}
    run keyword if     ${plan_exist_flag}==${True}    cu.plan_delete    ${plan_id}
    ...  ELSE  run keywords   log  Plan id ${plan_id} is not exist before deletion!  WARN   AND  return from keyword
    ${plan_exist_flag}=    CU Check Stage Plan Exist    ${plan_id}     ${gnb_index}
    should be true     ${plan_exist_flag}!=${True}     Plan delete operation failed and plan id ${plan_id} is still exist after deletion!
    [Teardown]   run keyword and ignore error   CU Logout

CU Check Stage Plan Exist
     [Arguments]     ${plan_id}  ${gnb_index}=0
    [Documentation]   Check stage plan exist or not by plan id.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <23-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id | Yes. | Plan id |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Stage Plan Exist  |  sp_d211beda-246f-40e2-97ec-57e9961fc094   |
    CU Login  ${gnb_index}
    ${initial_stage_plans}=    cu.get_plan_info
    FOR    ${plan}    IN    @{initial_stage_plans}
         return from keyword if    "${plan["plan_id"]}"=="${plan_id}"   ${True}
    END
    [Teardown]    run keyword and ignore error   CU logout



CU Online Parameter Change
    #[Arguments]   ${modify_list}   ${gnb_index}=0
    [Documentation]   Online change parameter
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...	   | commission_file_path | Yes. | Path of commission file |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    | CU Online Parameter Change  |     |
        Log    CU Online Parameter Change not ready!     WARN

CU Online Change Single Mo Parameters via rest
    [Arguments]     ${para_list}    ${mo_dn}     ${delta_plan_name}=delta_plan
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...    *RETURN VALUE*  None
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | CU Online Change Single Mo Parameters via rest | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |

    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
	run keyword and continue on failure   Wait until keyword succeeds  3x  2s
	...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
	...  _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}
	${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}
    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure   Wait until keyword succeeds  3x  30s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}   operation_id=${active_res['operation_id']}

_Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}
    [Documentation]   _Get CU Specifical MO UUID
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _Get CU Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|

    @{name_list}=   split_string    ${mo_dn}   /
    set test variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}

_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _Get CU Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|

    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'  run keywords
    ...  set test variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

_Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}
    [Documentation]   _Generating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Generating Delta Plan Operation Should Be Successful | action_id=xxx |
	${res}   cu.get_action_state_of_generating_delta_plan   ${action_id}
	should be equal as strings  ${res['status']}  success

_Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   CU Online Parameter Change By Rest
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	should be equal as strings  ${res['status']}  success

_Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   _Validating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
	should be equal as strings  ${res['status']}  success

_Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   _Activating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
	should be equal as strings  ${res['status']}  success



CU Update Delta Plan Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${parameter_change_list}
	[Documentation]   CU Update Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | managed object dist name |
    ...    | parameter_change_list | yes | parameter change list |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | &{gnbPlmn} | create dictionary  operation_type=add | parameter_path=/gnbPlmn |
    ...    | @{gnbPlmn_Para_list}= | Create List | ${gnbPlmn} |
    ...    | Update Delta Plan Should Be Successful | plan_id=${delta_plan_id} |
    ...    | ...  mo_dn=MRBTS-xxxx/NRBTS-xxxx/NRCELL-1/NRREL-1 | parameter_change_list=${gnbPlmn_Para_list} |
    ...    | &{mcc} | create dictionary | operation_type=add | parameter_path=/gnbPlmn/0/mcc | value=262 |
    ...    | @{mcc_Para_list}= | Create List | ${mcc} |
    ...    | CU Update Delta Plan Should Be Successful | plan_id=${delta_plan_id}  |
    ...    | ...  mo_dn=MRBTS-xxxx/NRBTS-xxxx/NRCELL-1/NRREL-1 | parameter_change_list=${mcc_Para_list} |
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${parameter_change_list}
    run keyword and continue on failure  Wait until keyword succeeds  10x  5s
    ...  _Update Parameters Operation Should Be Successful	plan_id=${plan_id}  action_id=${update_res['action_id']}

CU Create Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${name}  ${instance_id}
	[Documentation]   CU Create Delta Plan Managed Object Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | parent managed object dist name |
    ...    | name | yes | class name to be created |
    ...    | instance_id | yes | instance id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    |  CU Create Delta Plan Managed Object Should Be Successful | plan_id=${delta_plan_id} | mo_dn=MRBTS-xxxx/NRBTS-xxxx/NRCELL-1 |
    ...    | ...  name=com.nokia.srbts.nrbts:NRREL | instance_id=1 |
    ...    | Description | create one MO called NRREL-1 under MO MRBTS-xxxx/NRBTS-xxxx/NRCELL-1 |
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${nidd_id}   _Get CU Specifical NIDD ID    name=${name}

    ${nidd}  convert to string  ${nidd_id}
    ${instance}  convert to integer  ${instance_id}

    ${create_res}=   cu.create_managed_object_of_delta_plan   plan_id=${plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=False
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${create_res['action_id']}


_CU Create Delta Plan Managed Object Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   _CU Create Delta Plan Managed Object Operation Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | action_id of create_managed_object_of_delta_plan |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Create Delta Plan Managed Object Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=  cu.get_create_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success



CU Generate Delta Plan Should Be Successful
    [Documentation]   CU Generate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*  ${delta_plan_id}
    ...    Example
    ...    | ${delta_plan_id}= | CU Generate Delta Plan Should Be Successful  |
    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    sleep  3s
    ${delta_res}=  cu.generate_delta_plan  plan_name=delta_plan
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
    run keyword and continue on failure   Wait until keyword succeeds  3x  2s
    ...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
    [Return]   ${delta_plan_id}


CU Validate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}
    [Documentation]   CU Validate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Validate Delta Plan Should Be Successful  | plan_id=${delta_plan_id}  |
    ${validate_res}=   cu.validate_delta_plan   plan_id=${plan_id}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${plan_id}  action_id=${validate_res['action_id']}

CU Activate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}
    [Documentation]   CU Activate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Activate Delta Plan Should Be Successful | plan_id=${delta_plan_id}  |
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}
    run keyword and continue on failure   Wait until keyword succeeds  12x   30s
    ...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}   operation_id=${active_res['operation_id']}

CU Delete Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}
    [Documentation]   CU Delete Delta Plan Managed Object Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | managed object dist name |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Delete Delta Plan Managed Object Should Be Successful | plan_id=${delta_plan_id} | mo_dn=MRBTS-XXXX/NRBTS-XXXX/NRCELL-1/NRREL-1 |
    ${mo_uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${delete_res}=   cu.delete_managed_object_of_delta_plan  plan_id=${plan_id}  mo_uuid=${mo_uuid}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _CU Delete Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${delete_res['action_id']}


_CU Delete Delta Plan Managed Object Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   _CU Delete Delta Plan Managed Object Operation Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | action_id of delete_managed_object_of_delta_plan |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Delete Delta Plan Managed Object Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=  cu.get_delete_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success


_Get CU Specifical NIDD ID
    [Arguments]  ${name}
    [Documentation]   _Get CU Specifical NIDD ID
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | name | yes | class name |
    ...    *RETURN VALUE*  ${nidd_id}
    ...    Example
    ...    |  ${nidd_id} | _Get CU Specifical NIDD ID | name=com.nokia.srbts.nrbts:NRREL |
    @{all_nidd}   cu.get_nidd
    FOR    ${each_nidd}    IN    @{all_nidd}
      ${nidd_id}  set variable if  '${each_nidd["adaptation_id"]}'=='${name}'   ${each_nidd["nidd_id"]}
       exit for loop if    '${each_nidd["adaptation_id"]}'=='${name}'
    END
    [Return]   ${nidd_id}



Get VCU Cplane DSCP Value
    [Arguments]  ${gnb_index}=0
    [Documentation]  Get VDU Cplane DSCP Value
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes | key=value pair, scf_path key should be included! please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return distName list that matched the parameters filter and distName filter. Return type is list.
    ...
    ...    Example
    ...    Get distName according to mixed filter
    ...    | ${vdu_cplane_dscp} | Get VDU Cplane DSCP Value    |
    ...
    ${file_path}   CU Backup SCF   gnbu_index=${gnb_index}
    scf.Load_Scf  file_path=${file_path}
    ${vcu_conf}  Get VCU Conf From SCF   scf_path=${file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${vcu_conf["mrbts_id"]}/NRBTS-${vcu_conf["nrbts_id"]}
    ${value}  scf.get_value_from_scf   dist_name=${nrbts_distname}   p_name=cPlaneDscp
    [Return]  ${value}


Online Enable actCli For CU
    [Documentation]   Enable actCli when it is false
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <08-07-2020>, <lingtsun>, <Initial creation>
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Online Enable actCli For CU |
    ...
    ${gnb_id}    set variable    ${tl.gnbs[0].instance_id}
    ${MO}    set variable     MRBTS-${gnb_id}/MNL-1/MNLENT-1/FEATCADM-1
    &{para_actCli}    Create Dictionary    operation_type=replace   parameter_path=/actCli  value=true
    @{para_list}     Create List    ${para_actCli}
    ${actCli}=    CU Get Online Parameter Value     ${MO}    actCli
    CU Login
    run keyword if  """${actCli}"""=="""false"""
    ...    CU Online Change Single Mo Parameters via rest    para_list=${Para_list}  mo_dn=${MO}
    [teardown]    CU Logout


_vCU Recommission via REST API
    [Arguments]  ${build_number}  ${gnb_index}=0
    [Documentation]  _vCU Recommission via REST API
    ...  author: luofei.tu@nokia-sbell.com
    ${scf_file_name_of_current_branch}  Construct vCU Scf File Name  build_number=${build_number}
    vCU Cluster helm Login With Tenant
    ${tl_name}    Get TestLine Name From TestLine
    ${vCU_scf_download_result}   ${agent_scf_path}
    ...   _Download And Check Agent CU SCF  tl=${tl_name}  build=${build_number}  gnb_index=${gnb_index}
    ${SCF_PATH}   run keyword if   '${vCU_scf_download_result}' == 'False'
    ...  Get vCU Scf File From Test Line   file_name=${scf_file_name_of_current_branch}
    ...  ELSE   set variable   ${agent_scf_path}

    wait until keyword succeeds   10min  30s  Recommission vCU with new SCF  ${SCF_PATH}  ${scf_file_name_of_current_branch}


Recommission vCU with new SCF
    [Arguments]   ${new_scf}  ${plan_name}  ${gnb_index}=0
    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...     | gnb_index        | No | gnb index  |
    ...    | new_scf         | Yes | New SCF file  |
    ...    | plan_name       | Yes | New SCF file name  |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Recommission vCU with new SCF | new_scf=my_NEW_SCF |  | new_scf=my_scf_name|

    Check vCU Maximum Plan Number And Delete One If Reach Maximum Number    #########this keyword should be verify
    CU Full Commssion By Rest    path_of_commission_file=${NEW_SCF}  plan_name=${plan_name}  gnb_index=${gnb_index}

_Download And Check Agent CU SCF
    [Arguments]   ${S3_server_dir}=http://10.109.2.147:8099/AGENT_AIC_VCU_SCF  ${tl}=7_5_UTE5GAIC001T00138  ${build}=0.250.3074
    ...    ${local_path}=/tmp   ${gnb_index}=0
    [Documentation]   Download And Check Agent CU SCF
    ...    *AUTHOR* luofei.tu@nokia-sbell.com
     ...    modified by:        <02-18-2022>, <lingtsun>, <Initial creation>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | S3_server_dir    | Yes | S3 server, aim to save scf during agent commisstion  |
    ...    | build            | Yes | current software build. eg:0.250.3074; 14.250.0001 |
    ...    | tl               | Yes | current run case test line  |
    ...    | local_path       | Yes | default value:/tmp, this is UTE directory  |
    ...    | gnb_index       | Yes | default value:0, this is use to identify gnb  |
    ...
    ...   *RETURN VALUE*
    ...    ${res}   reurn the file if is exsit. it is boolean type True or False
    ...    ${scf_file}   return the scf path
    ...
    ...   Example
    ...   | _Download And Check Agent CU SCF | ${build}=0.250.3074 |
    run keyword and ignore error   Run  rm -rf ${local_path}/${tl}_${build}_scf_vCU_${gnb_index}.xml
    ${remote_vCU_scf}   OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_scf_vCU_${gnb_index}.xml --no-check-certificate --spider
    ${vCU_scf_exist}    set variable if   '200 OK' in """${remote_vCU_scf}"""   True    False
    ${res}  run keyword if    "${vCU_scf_exist}"=="${True}"   run keyword and return status  OperatingSystem.Run
    ...  wget ${S3_server_dir}/${tl}_${build}_scf_vCU_${gnb_index}.xml -O ${local_path}/${tl}_${build}_scf_vCU_${gnb_index}.xml
    ...  ELSE   set variable   ${False}
    ${vCU_scf_path}  set variable   ${local_path}/${tl}_${build}_scf_vCU_${gnb_index}.xml
    [Return]   ${res}   ${vCU_scf_path}


Check vCU Maximum Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* luofei.tu@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vcu rest login |
    ...  | Check Maximum Plan Number And delete one if reach Maximum number |
    ...
    CU Login
    ${all_plans}   cu.get_plan_info
    CU Logout
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3  CU Delete Plan  plan_id=${all_plans[0]["plan_id"]}


CU Get Online Parameter Value
   [Arguments]   ${dn}    ${parameter_path}    ${gnb_index}=${0}
    [Documentation]    Get online parameter via rest api.
    ...  author:             fen.huang@nokia-sbell.com
    ...  modified by:        <17-July-2020>, <f2huang>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    |  dn   | Yes |  Distname of parameter  |
    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
    ...                              |  complex parameter given the struncture like a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp
    ...
    ...    *RETURN VALUE*
    ...    parameter value, if it's simple or complex parameter, returns string type
    ...    if it's a simple list type parameter, it will return a list.
    ...
    ...    Example
    ...    | CU Get Online Parameter Value  |   MRBTS-5248     |   btsName  |
    ...    | CU Get Online Parameter Value  | MRBTS-5247/NRBTS-5247/NRCELLGRP-0 | nrCellList |
    ...    | CU Get Online Parameter Value  | MRBTS-52/NRBTS-1/NRCELL-1 | a2MeasRedirectSsbRsrp/0/a2ThresholdRedirectSsbRsrp |
    CU Login    gnb_index=${gnb_index}
    ${expected_dn}=  set variable   ${dn.strip()}
    ${expected_para_name}=    set variable   ${parameter_path.strip()}
    @{para_list}  Split String  ${expected_para_name}  /
    ${paras_info}=   cu.search_parameters_of_current_plan   parameter_name=${para_list[-1]}
    ${value}=   get_online_parameter_value  ${paras_info}  ${expected_dn}  ${parameter_path}
    [Return]  ${value}
    [Teardown]   CU Logout


