*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_oam_cm.robot



#*** Variables ***



*** Keywords ***
Get Rt Inst Distname
    [Arguments]   ${scf_path}  ${conf_dist}
    [Documentation]  Get route or route policy instance distname based on configure distname
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Get route or route policy instance distname based on configure distname
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | route policy distname |
    ...    | scf_path   | yes | scf path to get distname |
    ...    | conf_dist   | yes | configure distname |
    ...
    ...    *RETURN VALUE*
    ...   instance distname
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${scf_path}  Get A Directory  scf |
    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
    ...    | scf.Load_Scf  file_path=${scf_file} |
    ...    | ${routeexistflag} | Get Rt Inst Distname | ${dist} |
    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
    ...    | VDU Logout |
    ...
    ${uni_id}   Get Unique Id
    ${prefix}   ${rest}   Split String From Right   ${conf_dist}   /IPNO   1
    ${distNames}   Get Mo DistName   scf_path=${scf_path}   tnlDN=${prefix}
    ${templateType}=  scf.Get_Value_From_Scf   dist_name=${distNames[0]}   p_name=templateType
    ${pod_name}=	    Set Variable If
	...     "${templateType}" == "OAM"	oam
	...	    "${templateType}" == "5GControlPlane"	cp
	...	    "${templateType}" == "5GUserPlane"	up
    ${inst_tnl}=   Get vDU Instance TNL ID   scf_path=${scf_path}   podname=${pod_name}
    ${inst_dist}  Replace String With Regexp   ${conf_dist}   .*  TNL-\\d+  .*  TNL-${inst_tnl}
    [Return]   ${inst_dist}


Route Policy Should Exist
    [Arguments]   ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}
    [Documentation]    Route policy should exist in dist mo
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Check whether the given route policy exist under dist MO
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | route policy distname |
    ...    | orderNumber   | yes | orderNumber for policy |
    ...    | routingTableDN   | yes | routingTableDN for policy |
    ...    | srcIpAddress  | yes | srcIpAddress for policy |
    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for policy |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${scf_path}  Get A Directory  scf |
    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
    ...    | scf.Load_Scf  file_path=${scf_file} |
    ...    | ${routeexistflag} | Route Policy Should Exist | ${dist} |
    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
    ...    | VDU Logout |
    ...
    ${pol_info}   scf.Get All Values From Scf   dist_name=${dist}   p_name=orderNumber
    ${rtpol_len}   Get Length   ${pol_info}
    ${pol_exist}=    Set Variable    ${False}
    ${srcIpAddress}  Remove String Using Regexp   ${srcIpAddress}   :0   :

    FOR    ${i}    IN RANGE    0    ${rtpol_len}
        ${res}  Run Keyword And Ignore Error   Check RTPOL With Policy Index
    ...  ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}  ${i}
        ${pol_exist}=   Set Variable If   '${res[0]}'=='PASS'   ${True}   ${False}
        exit for loop if  '${pol_exist}'=='${True}'
    END
    Should Be True  '${pol_exist}'=='${True}'   route policy is not exist for ${dist}!


Check RTPOL With Policy Index
    [Arguments]   ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}  ${index}=0
    [Documentation]    Route policy with specific index should exist in dist mo
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Check whether the given route policy with specific index exist in forwarding entries under dist MO
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | route policy distname |
    ...    | orderNumber   | yes | orderNumber for policy |
    ...    | routingTableDN   | yes | routingTableDN for policy |
    ...    | srcIpAddress  | yes | srcIpAddress for policy |
    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for policy |
    ...    | index   | No | index for policy, default is the first one 0 |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${scf_path}  Get A Directory  scf |
    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
    ...    | scf.Load_Scf  file_path=${scf_file} |
    ...    | ${routeexistflag} | Check RTPOL With Policy Index | ${dist} |
    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
    ...    | VDU Logout |
    ...
    ${orderNumber1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=routingPolicies
    ...  p_name=orderNumber  index=${index}
    Should Be True   '${orderNumber1}'=='${orderNumber}'
    ${routingTableDN1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=routingPolicies
    ...  p_name=routingTableDN  index=${index}
    Should Be True   '${routingTableDN1}'=='${routingTableDN}'
    ${srcIpAddress1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=routingPolicies
    ...   p_name=srcIpAddress  index=${index}
    ${srcIpAddress}  Remove String Using Regexp   ${srcIpAddress}   :0   :
    ${srcIpAddress1}  Remove String Using Regexp   ${srcIpAddress1}   :0   :
    Should Be True   '${srcIpAddress1}'=='${srcIpAddress}'
    ${srcIpPrefixLength1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=routingPolicies
    ...  p_name=srcIpPrefixLength  index=${index}
    Should Be True   '${srcIpPrefixLength1}'=='${srcIpPrefixLength}'

Get New Iprt Distname
    [Arguments]  ${scf_path}  ${tnl_id}
    [Documentation]    Get new iprt distname based on given tnl id
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Get new iprt distname based on given tnl id
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path    | yes | scf file path |
    ...    | tnl_id   | yes | tnl id to get iprt distname |
    ...
    ...    *RETURN VALUE*
    ...   IPRT distname
    ...
    ...    Example
    ...    | ${scf_path}  Get A Directory  scf |
    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
    ...    | scf.Load_Scf  file_path=${scf_file} |
    ...    | ${iprt_dist} | Get New Iprt Distname | ${scf_file}  | 2 |
    ...    | VDU Logout |
    ...
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${distNames}   Get Mo DistName  scf_path=${scf_path}  gateway
    ${distNames}   Evaluate    [i for i in @{distNames} if "TNL-${tnl_id}/" in i]
    ${length}  Get Length  ${distNames}
    ${new_dist}  Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1/IPRT-2
    Return From Keyword If    ${length}==0    ${new_dist}
    ${prefix}   ${rest}   Split String From Right   ${distNames[0]}   -   1
    ${unused_iprt_id}   Set Variable    0
    FOR    ${i}    IN RANGE  2  10
       ${unused_iprt_id}=   evaluate    ${unused_iprt_id}+1
       ${res}  scf.Is_Object_In_Scf   ${prefix}-${unused_iprt_id}
       exit for loop if  '${res}'=='False'
    END
    ${new_dist}   Set Variable  ${prefix}-${unused_iprt_id}
    [Return]   ${new_dist}

Get New Iprt6 Distname
    [Arguments]  ${scf_path}  ${tnl_id}
    [Documentation]    Get new iprt6 distname based on given tnl id
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Get new iprt6 distname based on given tnl id
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path    | yes | scf file path |
    ...    | tnl_id   | yes | tnl id to get iprt distname |
    ...
    ...    *RETURN VALUE*
    ...   IPRT distname
    ...
    ...    Example
    ...    | ${scf_path}  Get A Directory  scf |
    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
    ...    | scf.Load_Scf  file_path=${scf_file} |
    ...    | ${iprt_dist} | Get New Iprt6 Distname | ${scf_file}  | 2 |
    ...    | VDU Logout |
    ...
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${distNames}   Get Mo DistName  scf_path=${scf_path}  gatewayIpv6Addr
    ${distNames}   Evaluate    [i for i in @{distNames} if "TNL-${tnl_id}/" in i]
    ${length}  Get Length  ${distNames}
    ${new_dist}  Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1/IPRTV6-2
    Return From Keyword If    ${length}==0    ${new_dist}
    ${prefix}   ${rest}   Split String From Right   ${distNames[0]}   -   1
    ${unused_iprt_id}   Set Variable    0
    FOR    ${i}    IN RANGE  2  10
       ${unused_iprt_id}=   evaluate    ${unused_iprt_id}+1
       ${res}  scf.Is_Object_In_Scf   ${prefix}-${unused_iprt_id}
       exit for loop if  '${res}'=='False'
    END
    ${new_dist}   Set Variable  ${prefix}-${unused_iprt_id}
    [Return]   ${new_dist}


Get Rtpol Distname
    [Arguments]  ${scf_path}   ${tnl_id}
    [Documentation]    Get rtpol distname based on given tnl id
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Get rtpol distname based on given tnl id
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path    | yes | scf file path |
    ...    | tnl_id   | yes | tnl id to get rtpol distname |
    ...
    ...    *RETURN VALUE*
    ...   rtpol distname
    ...
    ...    Example
    ...       VDU Rest Login
    ...    | ${scf_path}  Get A Directory  scf |
    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${rtpol_dist} | Get Rtpol Distname | ${scf_file}  | 2 |
    ...    | VDU Logout |
    ...
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${distNames}   Get Mo DistName  scf_path=${scf_path}  orderNumber
    ${distNames}   Evaluate    [i for i in @{distNames} if "TNL-${tnl_id}/" in i]
    ${length}  Get Length  ${distNames}
    ${new_dist}  Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1/RTPOL-1
    Return From Keyword If    ${length}==0    ${new_dist}
    [Return]   ${distNames[0]}

Vdu Add Route
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8   ${wait_vdu_up}=False
    [Documentation]    Add static route for vdu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Add static route for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | distname to add static route |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength   | yes | PrefixLength for static route |
    ...    | gateway   | yes | gateway for static route |
    ...    | preference   | no | preference for static route, default is 8 |
    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route configured |

    ...
    ...    *RETURN VALUE*
    ...   list of route info  [static route distname,  staticRoutes/index]
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${route_info} | Vdu Add Route | dist  | 1.1.1.1 | 24 | 1.1.1.2 |
    ...    | VDU Logout |
    ...
    ${route_list_name}  Set Variable If  ':' in '''${destIpAddr}'''  staticIpv6Routes  staticRoutes
    ${route_dstip_name}  Set Variable If  ':' in '''${destIpAddr}'''  destIpv6Addr  destIpAddr
    ${route_prefix_name}  Set Variable If  ':' in '''${destIpAddr}'''  destinationIpv6PrefixLength
    ...  destinationIpPrefixLength
    ${route_gateway_name}  Set Variable If  ':' in '''${destIpAddr}'''  gatewayIpv6Addr  gateway

    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_gateway_name}
    ${length}   Run Keyword If  '${res[0]}'=='PASS'   Get Length   ${res[1]}
    ...  ELSE    Set Variable  0
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_route_${uni_id}
    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
    Run Keyword If  ${length}==0   Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${prefix}  mo_name=${rest}
    ${paras_list}    Create Dictionary   /${route_list_name}=${EMPTY}
    Run Keyword If   ${length}==0  Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}
    ...  updated_paras_dict=${paras_list}   operation=add
    Sleep  2sec

    ${paras}=   Create Dictionary   ${route_list_name}/${length}/${route_gateway_name}=${gateway}
    ...   ${route_list_name}/${length}/${route_dstip_name}=${destIpAddr}
    ...   ${route_list_name}/${length}/${route_prefix_name}=${PrefixLength}
    ...   ${route_list_name}/${length}/preference=${preference}
    Sleep   10sec
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${paras}   operation=add
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
    [Return]   ${dist}  ${route_list_name}/${length}

Delta Remove Items
    [Arguments]   ${item_list_to_remove}   ${wait_vdu_up}=False
    [Documentation]    Delta remove items for vdu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Delta remove items for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | item_list_to_remove | yes | each item should contain distname and item name with index |
    ...    | wait_vdu_up | no | whether to wait for vdu up after static route configured |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${route_info} | Delta Remove Items | ${item_list_to_remove} |
    ...    | VDU Logout |
    ...
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=remove_dist_ta
    ${mo_to_remove}  Create List
    FOR  ${item}  IN  @{item_list_to_remove}
        ${prefix}   ${rest}   Split String From Right   ${item[1]}   /   1
        Run Keyword If  ${rest}==0  Append To List    ${mo_to_remove}   ${item[0]}
        ${number}   Count Values In List   ${mo_to_remove}    ${item[0]}
        Run Keyword If  ${number}>=1  Run Keyword And Ignore Error   Delete Delta Plan MO   ${plan_id}   ${item[0]}
        Continue For Loop If  ${number}>=1
        ${paras}=   Create Dictionary   ${item[1]}=${empty}
        Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${item[0]}
    ...  updated_paras_dict=${paras}   operation=remove
    END

    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}
    ...   local_filename=delta_remove_items_${uni_id}.xml
    Validate Delta Plan By REST   ${plan_id}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}

Vdu Add Rtpol
    [Arguments]  ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}  ${wait_vdu_up}=False
    [Documentation]    Add route policy for vdu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Add route policy for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | distname to add route policy |
    ...    | orderNumber   | yes | orderNumber for route policy |
    ...    | routingTableDN   | yes | routingTableDN for route policy |
    ...    | srcIpAddress   | yes | srcIpAddress for route policy |
    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for route policy |
    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route configured |
    ...
    ...    *RETURN VALUE*
    ...   list of route policy info  [routingPolicies distname,  routingPolicies/index]
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${route_info} | Vdu Add Rtpol | ${dist} | 5 | ${routingTableDN} | 1.1.1.1 | 24 |
    ...    | VDU Logout |
    ...

    ${pol_list_name}  Set Variable If  ':' in '''${srcIpAddress}'''  staticIpv6Routes  staticRoutes
    ${route_dstip_name}  Set Variable If  ':' in '''${srcIpAddress}'''  destIpv6Addr  destIpAddr
    ${route_prefix_name}  Set Variable If  ':' in '''${srcIpAddress}'''  destinationIpv6PrefixLength
    ...  destinationIpPrefixLength
    ${route_gateway_name}  Set Variable If  ':' in '''${srcIpAddress}'''  gatewayIpv6Addr  gateway

    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File    ${scf_path}   full_scf_${uni_id}.xml   include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}   p_name=orderNumber
    ${length}   Run Keyword If  '${res[0]}'=='PASS'  Get Length   ${res[1]}
    ...  ELSE    Set Variable  0

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_route_pol_${uni_id}
    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
    Run Keyword If  ${length}==0  Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${dist}  mo_name=${rest}
    ${paras}=   Create Dictionary   routingPolicies/${length}/orderNumber=${orderNumber}
    ...   routingPolicies/${length}/routingTableDN=${routingTableDN}
    ...   routingPolicies/${length}/srcIpAddress=${srcIpAddress}
    ...   routingPolicies/${length}/srcIpPrefixLength=${srcIpPrefixLength}

    ${paras_list}    Create Dictionary   /routingPolicies=${EMPTY}
    Run Keyword If   ${length}==0  Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}
    ...  updated_paras_dict=${paras_list}   operation=add
    sleep  2sec
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${paras}   operation=add
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_pol_${uni_id}.xml
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
    [Return]   ${dist}  routingPolicies/${length}


Vdu Get OAM Tracing Network Gateway
    [Documentation]   Vdu Get OAM Tracing Network Gateway
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   oam tracing network default gateway
    ...
    ...    Example
    ...   | ${oamgw} | Vdu Get OAM Tracing Network Gateway |
    ...
    ${alias_id}   get unique id
    Connect To K8s Master Interactively  alias=${alias_id}
    ${cmd}  catenate  sudo kubectl -n cran1 get cm oam-route-init-vducran1-aic-vdu-oam-configmap
    ...  -o yaml | grep -A 3 Tracing| grep table |awk '{print $2}'
    ${out}  issh.Execute  command=${cmd}  check_result=${False}  alias=${alias_id}
    ${table_id}  Strip Prompt  ${out}
    ${cmd}  catenate  sudo kubectl -n cran1 get cm oam-route-init-vducran1-aic-vdu-oam-configmap
    ...  -o yaml | grep -A 3 "\\- tableId: ${table_id}" | grep gateway |awk '{print $2}'
    ${out}  issh.Execute  command=${cmd}  check_result=${False}  alias=${alias_id}
    disconnect interactive connection  alias=${alias_id}
    ${gateway}    String.Replace String    ${out}    "   ${EMPTY}
    ${gateway}  Strip Prompt  ${gateway}
    [Return]  ${gateway}


Get MRBTS Id From vDU SCF
    [Documentation]   Get MRBTS Id From vDU SCF
    ...    *AUTHOR* huilin.xu@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   mrbts id from vDU Scf
    ...
    ...    Example
    ...    | ${mrbts_id} | Get MRBTS Id From vDU SCF |
    ...
    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${vdu_conf}    Get VDU Conf From SCF    scf_path=${scf_file_with_fullpath}
    ${mrbts_id}  set variable      ${vdu_conf["mrbts_id"]}
    [Return]   ${mrbts_id}


Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]   run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    [Documentation]   Get VCU Cell Number From SCF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  Cell number from test line configuration
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${tmpid1}   get unique id  precise=LOW  prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}  Get A Directory  ${tmpid1}
    ${tmp_scf_file}  vdu.get_current_plan_file  local_dir_path=${tmp_scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${scf_content}   OperatingSystem.Get File   ${tmp_scf_file}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}  Set Variable    ${result.__len__()}

    [Return]   ${cell_number}


Download vDU PDL Validation Plugin From WFT
    [Arguments]    ${build_number}    ${package_name}=5G   #${vdu_index}=0
    [Teardown]   run keyword and ignore error  disconnect interactive connection  alias=${alias_master}
    [Documentation]   Download vDU PDL Validation Plugin From WFT
    ...   *AUTHOR* jianlin.zhang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | build_number     | yes | build number, e.g, 0.300.900 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Download vDU PDL Validation Plugin From WFT |
    ...
    log to console  Download vDU PDL Validation Plugin From WFT
    ${alias}  get unique id
    Connect To UTE Locally    alias=${alias}
    ${dir_name}   Get Unique ID   prefix=tmp_   precise=LOW
    ${tmp_dir}  Get A Directory   ${dir_name}  alias=${alias}
    ${pdl_validation_file_name}   set variable   ${package_name}_${build_number}_pdl_validation_service_plugin.zip
    ${url}    set variable  ${PACKAGE_LINK}/${build_number}/${pdl_validation_file_name}
    ${out}   issh.Execute   command=cd ${tmp_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${result}  issh.Execute  command=ls -al ${tmp_dir}/${package_name}_${build_number}_pdl_validation_service_plugin.zip  alias=${alias}
    should not be empty    ${result}
    ${package_local_path}   OperatingSystem.Join Path  ${tmp_dir}  ${package_name}_${build_number}_pdl_validation_service_plugin.zip
    log to console  ${package_local_path}
    [Return]  ${package_local_path}



Get BTS ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get BTS ID From vDU SCF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    list value, contains [<mrbts_id>, <nrbts_id>, <nrdu_id>]
    ...
    ...    Example
    ...    |  ${mrbts_id}  | ${nrbts_id} | ${nrdu_id} | Get BTS ID From vDU SCF | scf_path=/tmp/a.scf |
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}  Set Variable If  ${result}   ${result[0][0]}
    ${nrbts_id}  Set Variable If  ${result}   ${result[0][1]}
    ${nrdu_id}   Set Variable If  ${result}   ${result[0][2]}
    [Return]  ${mrbts_id}   ${nrbts_id}  ${nrdu_id}

Get CELL ID From vDU SCF
    [Arguments]  ${scf_path}    ${cell_index}=0
    [Documentation]   Get CELL ID From vDU SCF
    ...    *AUTHOR* zhijiang.shan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    9.11.2020,zhijiang.shan@nokia-sbell.com, Create New
	...    10.11.2020,zhijiang.shan@nokia-sbell.com, Add ${cell_index} arguments
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    list value, contains [<nrcell_id>]
    ...
    ...    Example
    ...    |  ${nrcell_id}  | Get CELL ID From vDU SCF | scf_path=/tmp/a.scf |
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${nrcell_id}  Set Variable   ${result[${cell_index}]}
    [Return]  ${nrcell_id}

Get vDU TNL ID
    [Arguments]  ${scf_path}  ${templateType}=OAM
    [Documentation]   Get vDU TNL ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    | templateType | no | templateType, valid value is OAM, 5GUserPlane, default is OAM |
    ...
    ...    *RETURN VALUE*
    ...    TNL id of given templateType.
    ...
    ...    Example
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=OAM |
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=5GUserPlane |
    ...
    ${distName}   Get MO distName    scf_path=${scf_path}  templateType=${templateType}

    scf.load_scf  file_path=${scf_path}
    ${tnlDN_val}   scf.get_all_values_from_scf   dist_name=${distName[0]}  p_name=tnlDN

    ${result}     Get Regexp Matches     ${tnlDN_val[0]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)   1
    ${tnl_id}  Set Variable If  ${result}   ${result[0]}
    should be true  ${tnl_id}>=1

    [Return]  ${tnl_id}


Get VDU Conf From SCF
    [Arguments]  ${scf_path}=${EMPTY}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  Get VDU Conf From SCF file.
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  17.7.2020,chris.l.cao@nokia-sbell.com, Add support to automatically download scf file via REST if ${scf_path} is ${EMPTY}
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
    ...    | ${vdu_conf} | Get VDU Conf From SCF | scf_path=/home/ute/a.scf |
    ...    | ${vdu_conf} | Get VDU Conf From SCF |
    ...
    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get Temporary Scf From Current Plan    gnb_index=${gnb_index}  vdu_index=${vdu_index}
       ...    ELSE    set variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${tnl_oam}   Get vDU TNL ID   scf_path=${scf_path}  templateType=OAM
    ${tnl_version}   scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/TNLSVC-1   attribute=version
    ${nrbts_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu_id}   attribute=version
    ${mnl_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/MNL-1   attribute=version
    ${eqm_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/EQM-1  attribute=version
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  tnl_oam=${tnl_oam}
    ...  tnl_version=${tnl_version}
    ...  nrbts_version=${nrbts_version}
    ...  mnl_version=${mnl_version}
	...  eqm_version=${eqm_version}
    [Return]  ${conf}


Get CellTechnology From VDU SCF
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  Get CellTechnology From VDU SCF
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  19.10.2021,chris.l.cao@nokia-sbell.com,initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    TDD or FDD
    ...
    ...    Example
    ...    | ${cellTechnology} | Get CellTechnology From VDU SCF |
    ...
    ${scf_path}    Get Temporary Scf From Current Plan     gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${distname}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    scf.load_scf  file_path=${scf_path}
    ${cellTechnology}   scf.get_all_values_from_scf   dist_name=${distname}  p_name=cellTechnology
    [Return]   ${cellTechnology[0]}


CellTechnology Should Be Expected
    [Arguments]  ${expected_celltechnology}  ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  CellTechnology Should Be Expected
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  14.12.2021,chris.l.cao@nokia-sbell.com,initialization
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | expected_celltechnology  | yes | expected_celltechnology, TDD or FDD |
    ...	   | gnb_index              | no | gnb_index, default is 0 |
    ...	   | vdu_index              | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | CellTechnology Should Be Expected  |  expected_celltechnology=FDD |
    ...    | CellTechnology Should Be Expected  |  expected_celltechnology=TDD |
    ...
    ${cellTechnology}   Get CellTechnology From VDU SCF  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    Run Keyword If   "${cellTechnology}"!="${expected_celltechnology}"
     ...   Fail   cellTechnology should be ${expected_celltechnology}, but real cellTechnology is ${cellTechnology}!


Get Temporary Scf From Current Plan
    [Arguments]   ${gnb_index}=0    ${vdu_index}=0
    [Documentation]  Get Temporary Scf From Current Plan
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${vdu_conf} | Get Temporary Scf From Current Plan |
    ...
    ${tmp_scf_path}=  Get A Directory  temp_scf
    ${file_name}   get unique id  prefix=scf_tmp_   suffix=.xml   precise=LOW
    VDU Rest Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${tmp_scf_full_path}  vdu.get_current_plan_file  local_dir_path=${tmp_scf_path}  filename=${file_name}  include_runtime_data=${False}
    [Return]  ${tmp_scf_full_path}


Get MO distName
    [Arguments]   @{para_list}
    [Documentation]  Get MO distName.  It supports multi-parameters filtering and distName filtering.
    ...    When using key=value format, the '=' means 'contain',  e.g, distName=TNL-4 means 'distName' contain 'TNL-4',
    ...    sgwIpAddress=10.68  means 'sgwIpAddress' contain '10.68'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...  Change History
    ...  27.9.2021   chris.l.cao@nokia-sbell.com,  add support to scf exported from Netact
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes | key=value pair, scf_path key should be included! please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return distName list that matched the parameters filter and distName filter. Return type is list.
    ...
    ...    Example
    ...    Get distName according to mixed filter
    ...    | ${scf_path} | set variable | /tmp/scf.xml |
    ...    | scf.load_scf | file_path=${scf_path}      |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | btsName         |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=btsName |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | templateType=OAM |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=templateType |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=tnlDN |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO | icmpDscp |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO | icmpDscp=10 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=MRBTS-1234/TNLSVC-1/TNL-1/IPNO | icmpDscp=10 |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=icmpDscp |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=ndMldDscp |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=TNL-4 |  destIpAddr=10.68 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | sgwIpAddress=10.68 | gtpuPathSupint=60 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=GTPU | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=destIpAddr |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=sgwIpAddress |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=gtpuPathSupint |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    #${key_value_dict_keys}   set variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    Run Keyword If  "scf_path" not in "${key_value_dict_keys}"   Fail  Should give scf_path parameter value!!!
    ${scf_path}     Set Variable  ${key_value_dict["scf_path"]}
    Remove From Dictionary   ${key_value_dict}   scf_path

    Run Keyword If   """distName""" in """${non_key_value_pair_list}"""    Remove Values From List   ${non_key_value_pair_list}   distName

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${xpath}   _Create Xpath    ${non_key_value_pair_list}   ${key_value_dict}

    ${raml_version}   _Get raml version   ${scf_path}
    ${distName_list}   Get_Multi_DistName_By_Xpath_Filter   ${scf_content}   ${xpath}  raml_version=${raml_version}

    [Return]  ${distName_list}


_Get raml version
    [Arguments]  ${scf_path}
    ${line}   OperatingSystem.Grep File   ${scf_path}   <raml*xmlns=*>
    ${matches}  String.Get Regexp Matches   ${line}   .*\\sxmlns="(\\S+)"[\\s>].*   1
    ${raml_version}   Set Variable   ${matches[0]}

    [Return]  ${raml_version}


Get VDU Cplane DSCP Value
    [Arguments]  ${vdu_index}=0
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
    ${file_path}   Get Temporary Scf From Current Plan   vdu_index=${vdu_index}
    scf.Load_Scf  file_path=${file_path}
    ${vdu_conf}  Get VDU Conf From SCF   scf_path=${file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf["nrbts_id"]}
    ${value}  scf.get_value_from_scf   dist_name=${nrbts_distname}   p_name=cPlaneDscp
    [Return]  ${value}


_Parse Input Parameter According To Seperator
    [Arguments]   ${seperator}    @{para_list}
    [Documentation]    _Parse Input Parameter According To Seperator
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | seperator | yes | seperator, eg, '='  |
    ...    | para_list | yes | dictionary, like 'key=value' pair format  |
    ...    *RETURN VALUE*
    ...    dictionary of parameter
    ...
    ...  Example
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | key1=value1 | key2=value2 | key3=value3 | ... |
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=500 |
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=5 | distName=TNL-3 |

    @{non_key_value_pair_list}    create list
    &{key_value_dict}    Create Dictionary

    ${len}    Get Length    ${para_list}
    Run Keyword If   ${len}==0   Fail    There is no input parameter while calling this keyword!

    FOR    ${item}    IN    @{para_list}
        ${out}    Split String    ${item}    ${seperator}    1
        ${len}   Get Length   ${out}
        ${first}    Set Variable    ${out[0]}
        ${second}    Set Variable If    ${len}==1    ${EMPTY}
        ...    ${len}>=2 and '${out[1]}'=='${EMPTY}'    ${EMPTY}
        ...    ${len}>=2 and '${out[1]}'!='${EMPTY}'    ${out[1]}
        Run Keyword If   '${second}'=='${EMPTY}'   Append To List   ${non_key_value_pair_list}   ${first}
        Continue For Loop If   '${second}'=='${EMPTY}'
        &{tempdict}    Create Dictionary    ${first}    ${second}
        &{key_value_dict}    Create Dictionary    &{key_value_dict}    &{tempdict}
    END

    [Return]   ${non_key_value_pair_list}   ${key_value_dict}


_Create Xpath
    [Arguments]    ${non_key_value_pair_list}   ${key_value_dict}
    ${tmp_non_key_value_pair_list}   Copy List   ${non_key_value_pair_list}
    ${tmp_key_value_dict}   Copy Dictionary   ${key_value_dict}
    ${len1}   Get Length  ${tmp_non_key_value_pair_list}
    ${len2}   Get Length  ${key_value_dict}
    Should Not Be True  ${len1}==0 and ${len2}==0

    ${contain_list}   Create List

    #handle Non_Key_Value_Pair_List
    Run Keyword If   ${len1}>=1   _Create Xpath Contain List   ${contain_list}    ${tmp_non_key_value_pair_list}

    #handle Key_Value_Dict
    #@{key_list}   set variable    ${tmp_key_value_dict.keys()}
    @{key_list}   evaluate    list(${tmp_key_value_dict})
    FOR    ${i}   IN     @{key_list}
      Continue For Loop If   '${i}'=='distName'
      ${key}  Set Variable   ${i}
      ${value}   Set Variable   ${key_value_dict["${i}"]}
      Append To List  ${contain_list}  descendant::ns:*[local-name()='p' or local-name()='list'][@name="${key}" and contains(text(),"${value}")]
    END

    #handle 'distName' In Key_Value_Dict
    ${tmp_dict}  evaluate   list(${key_value_dict})
    #Run Keyword If    """distName""" in """${key_value_dict.keys()}"""
    Run Keyword If    """distName""" in """${tmp_dict}"""
    ...      append to list    ${contain_list}   contains(@distName, "${key_value_dict["distName"]}")

    ${xpath}   Catenate   SEPARATOR=${SPACE}and${SPACE}      @{contain_list}
    ${xpath}   Set Variable   .//ns:managedObject[${xpath}]
    [Return]   ${xpath}


_Create Xpath Contain List
    [Arguments]     ${contain_list}    ${para_list}
    FOR   ${i}   IN   @{para_list}
         Append To List    ${contain_list}    descendant::ns:*[local-name()='p' or local-name()='list']/@name="${i}"
    END


vDU Send Commission By RestApi
    [Arguments]  ${scf_path}    ${restapi_version}=cuoam_21b   ${vdu_index}=0
    [Documentation]   send commission on one vdu, including upload validate and activate scf
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.32021, calla.wang@nokia-sbell.com, add sleeping after activated plan file to ensure the restapi can be connected
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    None
    log to console  \n*** start send commission on vdu ***
    vDU Rest Login  ${restapi_version}  ${vdu_index}
    ${upload_plan_response}=  vdu.upload_plan    ${scf_path}
    wait until keyword succeeds  2min  5s  Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  2min  5s  Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    sleep  90s
    wait until keyword succeeds  10min  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}
    [Teardown]  vDU Rest Logout

Upload Plan Operation Should Be Successful
    [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success


Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}    #${vdu_index}=0   ${gnb_index}=0
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  23.7.2020,chris.l.cao@nokia-sbell.com, add retry mechanism
    ...  13.8.2020,chris.l.cao@nokia-sbell.com, extend retry window from 20s to 240s
    ...  11.3.2021,calla.wang@nokia-sbell.com, restore the previous logic, no need to login vdu once again and nested wait until
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${activate_plan_response['status']}  success
#    ${rtn}  Wait Until Keyword Succeeds  600   20
#     ...   Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
#     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    [Return]  ${rtn}


vDU Send Commission By WebEM
    #[Arguments]    ${scf_file_path}  ${vdu_index}=0
    [Documentation]   Send BTS commission via vdu WebEM.
        ...    author: calla.wang@nokia-sbell.com
         ...   modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   | scf_file_path | Yes. | Path of commission file |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  vDU Send Commission By WebEM  | c:/tmp/commission.xml |
    vDU WebEM Login
    Log    Send commission by webem not ready!    WARN
    [Teardown]  vDU WebEM Logout



MO Clone
    [Arguments]  ${source_mo_dist_name}   ${target_mo_dist_name}
    [Documentation]    Clone MO with MO content
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | source_mo_dist_name | yes | source_mo_dist_name |
    ...   | target_mo_dist_name | yes | target_mo_dist_name |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | scf.load_scf | file_path=/tmp/a.scf |
    ...   | ${IPADDRESSV4_distname} | set variable | MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | ${IPADDRESSV6_distname} | set variable | MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1 |
    ...   | MO Clone     |  source_mo_dist_name=${IPADDRESSV4_distname} | target_mo_dist_name=${IPADDRESSV6_distname} |
    ...   | scf.save_scf | file_path=/tmp/new.scf |
    ...
    scf.Clone Mo With Descendant Mos     source_mo_dist_name=${source_mo_dist_name}   target_mo_dist_name=${target_mo_dist_name}
    ${old_class_full_value}   scf.Get Mo Attribute  dist_name=${source_mo_dist_name}   attribute=class
    ${old_class_abbr_value}   Set Variable  ${old_class_full_value.split(":")[-1]}
    ${new_class_abbr_value}   Set Variable  ${target_mo_dist_name.split("/")[-1].split("-")[0]}
    ${new_class_full_value}   Replace String  ${old_class_full_value}   ${old_class_abbr_value}  ${new_class_abbr_value}
    scf.Set Mo Attribute  dist_name=${target_mo_dist_name}   attribute=class   value=${new_class_full_value}


MO Replacememt In SCF File
    [Arguments]  ${scf_file}   ${new_mo_content}
    [Documentation]   replace with new MO in scf file.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | scf_file       | yes | scf_file |
    ...   | new_mo_content | yes | new_mo_content, string content of MO content|
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | ${MO} | Generate MO Message For Modifying List Parameters | scf_path=/tmp/scf.xml | action=add | operation=create |
    ...   | ... | distName=MRBTS-5240/NRBTS-2/NRDU-1 |
    ...   | ... | list_para_name=f1Cplane |
    ...   | ... | ipV6AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1 |
    ...   | MO Replacememt In SCF File | scf_file=/tmp/scf.xml | new_mo_content=${MO} |
    ...
    ${managedObject_1st_part}  ${new_content_without_managedObject}  ${dummy}   Fetch_String_With_Regexp   content=${new_mo_content}
    ...   g1_regexp=<managedObject\\s+\\S+.*?>
    ...   g2_regexp=.*
    ...   g3_regexp=</managedObject>

    ${matches}   Get Regexp Matches  ${managedObject_1st_part}   <managedObject\\s+.*?distName="(\\S+)"\\s+.*>   1
    Should Be True  ${matches}
    ${distName}  Set Variable  ${matches[0]}

    OperatingSystem.File Should Exist   ${scf_file}
    ${content}   OperatingSystem.Get File   ${scf_file}

    ${content}   Replace_String_With_Regexp   content=${content}
    ...   g1_regexp=<managedObject\\s+\\S+\\s+distName="${distName}"[^/>]+
    ...   g2_regexp=/
    ...   g3_regexp=>
    ...   g2_new_value=></managedObject

    ${content}   Replace_String_With_Regexp   content=${content}
    ...   g1_regexp=<managedObject\\s+\\S+\\s+distName="${distName}"[^>]+>
    ...   g2_regexp=.*?
    ...   g3_regexp=</managedObject>
    ...   g2_new_value=${new_content_without_managedObject}

    OperatingSystem.Create File   ${scf_file}   ${content}

    scf.Load_Scf  file_path=${scf_file}
    scf.Save_Scf  file_path=${scf_file}


Get MO Content
    [Arguments]  ${scf_path}   ${distname}   ${with_shell}=${True}
    [Documentation]   Get MO Content
    ...    *AUTHOR*chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path  | Yes | distname |
    ...    | distname  | Yes | distname, MRBTS-5240/NRBTS-2  |
    ...    | with_shell  | no | ${True} or ${False},  if ${true}, the returned content includes <managedObject ...> and </managedObject>, |
    ...    |             |    | otherwise they are not included, default value is ${True} |
    ...
    ...    *RETURN VALUE*
    ...    MO content
    ...
    ...    Example
    ...    | ${MO_content} | Get MO Content | scf_path=/tmp/a.scf | distname=MRBTS-5240/NRBTS-2 |
    ...    | ${MO_content} | Get MO Content | scf_path=/tmp/a.scf | distname=MRBTS-5240/NRBTS-2 | with_shell=${False} |
    ...
    ${content}  get file  ${scf_path}
    ${rtn}  run keyword if  "${with_shell}"=="${True}"   _Get MO Content With Shell   scf_path=${scf_path}   distname=${distname}
    ...   ELSE      _Get MO Content Without Shell   scf_path=${scf_path}   distname=${distname}
    [Return]  ${rtn}


_Get MO Content With Shell
    [Arguments]  ${scf_path}   ${distname}
    ${content}  get file  ${scf_path}
    ${o1}   ${o2}   ${o3}   fetch_string_with_regexp   content=${content}
      ...    g1_regexp=.*
      ...    g2_regexp=<managedObject\\s+class="\\S+"\\s+distName="${distname}".*?>.*?
      ...    g3_regexp=</managedObject>
    ${rtn}   catenate  SEPARATOR=\n   ${o2}   ${o3}
    [Return]  ${rtn}


_Get MO Content Without Shell
    [Arguments]  ${scf_path}   ${distname}
    ${content}  get file  ${scf_path}
    ${o1}   ${o2}   ${o3}   fetch_string_with_regexp   content=${content}
      ...    g1_regexp=.*<managedObject\\s+class="\\S+"\\s+distName="${distname}".*?>
      ...    g2_regexp=.*?
      ...    g3_regexp=</managedObject>
    [Return]  ${o2}




_Upload Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    [Documentation]    Upload Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success |
    ...
    ${out}   vdu.Get_Upload_Plan_Operation_Status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"


Upload Plan Status Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Upload Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> |
    ...
     Wait Until Keyword Succeeds  30   3  _Upload Plan Status Should Be Expected   operation_id=${operation_id}    expected_status=success


_Validate Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}   ${plan_id}
    [Documentation]    Validate Plan Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | set variable | sp_7bbfbd44-a3ca-4b22-b948-a0c8a6d3716a |
    ...  | ${out} | vdu.validate_plan | plan_id=${plan_id} |
    ...  | Validate Plan Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success | plan_id=<my_plan_id> |
    ...

    ${out}   vdu.Get_Validate_Plan_Operation_Status   operation_id=${operation_id}   plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Validate Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    [Documentation]   Validate Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | operation_id=<my_operation_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}  Wait Until Keyword Succeeds  20   3
    ...  _Validate Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Is Staged Plan Existed
    [Arguments]  ${plan_name}
    [Documentation]   Is Staged Plan Existed
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...
    ...   *RETURN VALUE*
    ...    Return (1, <real_plan_id>) if desired plan name exists, otherwise return (0, ${EMPTY})
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${bExsit} | ${plan_id} | Is Staged Plan Existed | plan_name=my_plan_name |
    ...
    ${existed}   Set Variable  0
    ${rtn_plan_id}   Set Test Variable  ${EMPTY}
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Return From Keyword If  ${all_plans.__len__()}==0   0   ${EMPTY}
    FOR   ${one_plan}   IN   @{all_plans}
        ${existed}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   1   0
        ${rtn_plan_id}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   ${one_plan["plan_id"]}  ${EMPTY}
        Exit For Loop If  "${one_plan["plan_name"]}"=="${plan_name}"
    END
    [Return]    ${existed}    ${rtn_plan_id}


Delete Plan
    [Arguments]  ${plan_name}
    [Documentation]   Delete Plan. Do nothing if desired plan does not exist.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name to be deleted |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Plan  | plan_name=my_plan_name |
    ...
    ${bExsit}   ${to_be_deleted_plan_id}   Is Staged Plan Existed   plan_name=${plan_name}
    Run Keyword If  ${bExsit}==1   vdu.Delete_Staged_Plan_File   plan_id=${to_be_deleted_plan_id}


Check Maximum Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Plan Number And delete one if reach Maximum number |
    ...
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}


Upload Plan And Validate
    [Arguments]   ${plan_file}  ${plan_name}  ${plan_description}=${EMPTY}  ${validate}=${True}
    [Documentation]   Upload Plan and validate
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_file    | yes | plan_file |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | validate         | no | validate, if ${True} will do validation, otherwise it will not do validation, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>, <validation_id>)
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan and validate | plan_file=/home/ute/scf.xml | plan_name=my_plan_name |
    ...  | ... | validate=${True} |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan and validate | plan_file=/home/ute/scf.xml | plan_name=my_plan_name |
    ...  | ... | validate=${False} |
    ...

    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}

    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}

    Return From Keyword If  "${validate}"=="${False}"   ${temp_plan_id}   ${temp_action_id}  ${temp_validation_id}

    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}
    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}


Validate Plan By REST
    [Arguments]  ${plan_id}   ${retries}=1
    [Documentation]   Validate Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Validate Plan By REST | plan_id=<my_plan_id> |
    ...
    FOR   ${i}   IN RANGE   0   ${retries}
      ${out}  vdu.Validate_Plan   plan_id=${plan_id}
      ${action_id}   Set Variable  ${out["action_id"]}
      ${out}   Validate Plan Status Should Be Successful   operation_id=${action_id}  plan_id=${plan_id}
      ${validation_id}  Set Variable   ${out["validation_id"]}
      sleep   2
    END
    [Return]   ${validation_id}


Upload Plan And Validate And Activate
    [Arguments]   ${plan_file}  ${plan_name}=TA_Upload_Plan_And_Validate_And_Activate  ${plan_description}=${EMPTY}  ${wait_vdu_up}=${False}
    ...   ${retries}=1
    [Documentation]   Upload Plan And Validate And Activate
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   13.8.2020,chris.l.cao@nokia-sbell.com, add sleep  8 second between validation and activation
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_file    | yes | plan_file |
    ...   | plan_name    | No | plan_name, default is TA_Upload_Plan_And_Validate_And_Activate |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | wait_vdu_up     | no | wait_vdu_up, if ${True} will wait until VDU up, otherwise it will not, default is ${False} |
    ...
    ...   *RETURN VALUE*
    ...    Return <plan_id>   <action_id>    <validation_id>
    ...
    ...   Example
    ...  | vdu rest login |
   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
   ...  | ... | wait_vdu_up=${True} |
   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
   ...  | ... | wait_vdu_up=${False} |
    ...
    log to console  Upload Plan And Validate And Activate
    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}

    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
    sleep   2
    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}   retries=${retries}
    sleep   2
    ${out}   Activate Staged Plan By REST   plan_id=${temp_plan_id}
    run keyword if  "${wait_vdu_up}"=="${True}"   sleep   8
    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   1000  30   OAM Precondition Cell Should Be Onair

    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}


Vdu Pre Activate For Staged Plan
    [Arguments]   ${plan_id}
    [Documentation]   Vdu Pre Activate For Staged Plan
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    Information of pre-activated staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${scf} | set variable | /temp/Configuration_scf_vDU_MVP5238.xml |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate | plan_file=${scf} | plan_name=my_plan_name | validate=${True} |
    ...  | ${out}    | Vdu Pre Activate For Staged Plan | plan_id=${plan_id} |
    ...  | ${out}    | Vdu Activate Pre Activated Staged Plan | plan_id=${out["plan_id"]} |
    ...

    ${out}  vdu.vdu_pre_activate_for_staged_plan   plan_id=${plan_id}
    ${operation_id}   Set Variable  ${out["id"]}
    ${out}  Pre Activate For Staged Plan Status Should Be Successful   plan_id=${plan_id}   operation_id=${operation_id}

    [Return]   ${out}


Pre Activate For Staged Plan Status Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   Pre Activate For Staged Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    Information while pre-activating staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Pre Activate For Staged Plan Status Should Be Successful | plan_id=<plan_id> | operation_id=<my_operation_id> |
    ...
    ${out}   Wait Until Keyword Succeeds  10   3
     ...   _Pre Activate For Staged Plan Status Should Be Expected    plan_id=${plan_id}   operation_id=${operation_id}   expected_status=success
    [Return]  ${out}


_Pre Activate For Staged Plan Status Should Be Expected
    [Arguments]  ${plan_id}   ${operation_id}   ${expected_status}
    [Documentation]    _Pre Activate For Staged Plan Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id          | yes | plan_id |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    Information while pre-activating staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Pre Activate For Staged Plan Status Should Be Expected | plan_id=<plan_id> | operation_id=<operation_id> | expected_status=success |
    ...
    ${out}   vdu.vdu_get_pre_activate_operation_status_for_staged_plan    plan_id=${plan_id}  operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Vdu Activate Pre Activated Staged Plan
    [Arguments]   ${plan_id}
    [Documentation]   Vdu Activate Pre Activated Staged Plan
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...   ${True}  or  ${False}
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${scf} | set variable | /temp/Configuration_scf_vDU_MVP5238.xml |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate | plan_file=${scf} | plan_name=my_plan_name | validate=${True} |
    ...  | ${out}    | Vdu Pre Activate For Staged Plan | plan_id=${plan_id} |
    ...  | ${out}    | Vdu Activate Pre Activated Staged Plan | plan_id=${out["plan_id"]} |
    ...
    ${operation_id}  vdu.vdu_activate_pre_activated_plan   plan_id=${plan_id}
    sleep  300
    ${out}  Vdu Activate Pre Activated Staged Plan Status Should Be Successful   plan_id=${plan_id}   operation_id=${operation_id}

    [Return]   ${out}


Vdu Activate Pre Activated Staged Plan Status Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   Vdu Activate Pre Activated Staged Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    activating result of staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Vdu Activate Pre Activated Staged Plan Status Should Be Successful | plan_id=<plan_id> | operation_id=<my_operation_id> |
    ...
    vdu rest login
    ${out}   Wait Until Keyword Succeeds  30  5
     ...   _Vdu Activate Pre Activated Staged Plan Status Should Be Should Be Expected
     ...   plan_id=${plan_id}   operation_id=${operation_id}   expected_status=${True}
    [Return]  ${out}


_Vdu Activate Pre Activated Staged Plan Status Should Be Should Be Expected
    [Arguments]  ${plan_id}   ${operation_id}   ${expected_status}
    [Documentation]    _Vdu Activate Pre Activated Staged Plan Status Should Be Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status, ${True} or ${False} |
    ...
    ...   *RETURN VALUE*
    ...    activating result of staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Pre Activate For Staged Plan Status Should Be Expected | plan_id=<plan_id> | operation_id=<operation_id> | expected_status=${True} |
    ...
    ${out}   vdu.get_activated_operation_status_for_preactivated_plan    plan_id=${plan_id}  operation_id=${operation_id}
    Should Be True  "${out}"=="${expected_status}"
    ${expected_result}   Set Variable  ok
    ${out1}   vdu.get_activated_operation_detail_status_for_preactivated_plan  plan_id=${plan_id}  operation_id=${operation_id}
    ${status}    Set Variable  ${out1['status']}
    Should Be True  "${status}"=="${expected_result}"
    [Return]  ${out}  ${out1}


Update Staged Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 |
    ...  | ${validation_id} | Update Staged Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
    ...  | ${validation_id} | Update Staged Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_staged_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}   Update Staged Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}


Update Staged Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Update Staged Plan Parameter Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Staged Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}   wait until keyword succeeds  20   2   _Update Staged Plan Parameter Should Be Expected
     ...   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Update Staged Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Update Staged Plan Parameter Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_update_paras_action_status_of_staged_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Delete Staged Plan MO
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=30
    [Documentation]   Delete Staged Plan MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | timeout    | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Delete Staged Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.delete_mo_of_staged_plan   staged_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Delete Staged Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}


Delete Staged Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Delete Staged Plan MO Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Staged Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Delete Staged Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Delete Staged Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Delete Staged Plan MO Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Staged Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_deleting_mo_action_state_of_staged_plan      staged_plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Delete Delta Plan
    [Arguments]  ${plan_name}
    [Documentation]   Delete Delta Plan. Do nothing if desired plan does not exist.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name to be deleted |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Plan  | plan_name=my_plan_name |
    ...
    ${bExsit}   ${to_be_deleted_plan_id}   Is Delta Plan Existed   plan_name=${plan_name}
    Run Keyword If  ${bExsit}==1   vdu.delete_delta_plan_file   plan_id=${to_be_deleted_plan_id}


Is Delta Plan Existed
    [Arguments]  ${plan_name}
    [Documentation]   Is Delta Plan Existed
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...
    ...   *RETURN VALUE*
    ...    Return (1, <real_plan_id>) if desired plan name exists, otherwise return (0, ${EMPTY})
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${bExsit} | ${plan_id} | Is Delta Plan Existed | plan_name=my_plan_name |
    ...
    ${existed}   Set Variable  0
    ${rtn_plan_id}   Set Test Variable  ${EMPTY}
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Return From Keyword If  ${all_plans.__len__()}==0   0   ${EMPTY}
    FOR   ${one_plan}   IN   @{all_plans}
        ${existed}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   1   0
        ${rtn_plan_id}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   ${one_plan["plan_id"]}  ${EMPTY}
        Exit For Loop If  "${one_plan["plan_name"]}"=="${plan_name}"
    END
    [Return]    ${existed}    ${rtn_plan_id}


Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Delta Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Delta Plan Number And delete one if reach Maximum number |
    ...
    ${all_plans}   vdu.Get_Delta_Plan_Info_List

    #Run Keyword If  ${all_plans.__len__()}==1   vdu.delete_delta_plan_file   plan_id=${all_plans[0]["plan_id"]}
    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}


Generate Delta Plan
    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}
    [Documentation]   Generate Delta Plan
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>)
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=my_plan_name |
    ...
    run keyword if  "${delete_old_one}"=="${True}"   Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}

    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}

    Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}
    [Return]   ${temp_plan_id}   ${temp_action_id}


_Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}
    [Documentation]   _Generate Delta Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id       | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...
    ${out}   vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"


Generate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}
    [Documentation]   Generate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Generate Delta Plan Status Should Be Successful | action_id=<my_action_id> |
    ...
    Wait Until Keyword Succeeds  30   3  _Generate Delta Plan Status Should Be Expected   action_id=${action_id}    expected_status=success


Update Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
    ...
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}    Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}


Update Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Update Delta Plan Parameter Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Update Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Update Delta Plan Parameter Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


_Validate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}
    ${out}   vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Validate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}
    [Documentation]   Validate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Validate Delta Plan By REST
    [Arguments]  ${plan_id}
    [Documentation]   Validate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Delta Plan Number And Delete One If Reach Maximum Number |
    ...  | ${delta_plan_name} | get unique id | prefix=TA_delta_plan | precise=LOW |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=${delta_plan_name} | plan_description=TA |
    ...  | ${TCE_Info_1} | create dictionary | tceIpAddress=1.1.1.1 | tcePortNumber=5000 |
    ...  | ${mo} | set variable | MRBTS-5200/MNL-1/TCEADM-1/TCE-1 |
    ...  | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${mo} | updated_paras_dict=${TCE_Info_1} | operation=add |
    ...  |  ${validation_id} | Validate Delta Plan By REST | plan_id=${planid} |
    ...  | Activate Delta Plan By REST | ${plan_id} | wait_vdu_up=${True} |
    ...

    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}



_Activate Delta Plan Status Should Be Expected
    [Arguments]  ${operation_id}    ${plan_id}   ${expected_status}
    ${out}   vdu.Get_Activate_Delta_Plan_Operation_Status   operation_id=${operation_id}   delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Activate Delta Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    [Documentation]   Activate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Activate Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}   Wait until keyword succeeds  600  30s
     ...   _Activate Delta Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Activate Delta Plan By REST
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${wait_vdu_up}=${False}   ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example of changing btsName
    ...   | VDU Rest Login |
    ...   | ${VDU_CONF} | Get VDU Conf From SCF |
    ...   | ${plan_id} |  ${action_id}  | Generate Delta Plan |  plan_name=changeBTSName |
    ...   | ${distname} |  Set Variable | MRBTS-${VDU_CONF["mrbts_id"]} |
    ...   | ${para_dict} | create dictionary |   btsName=btsName_new |
    ...   | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${distname} | updated_paras_dict=${para_dict} | operation=replace |
    ...   | Validate Delta Plan By REST |  ${plan_id} |
    ...   | Activate Delta Plan By REST |  ${plan_id} |
    ...   | VDU Rest Logout |
    ...
    ${temp_path}  Get A Directory  delta_plan
    ${tmp_file_id}   get unique id  precise=LOW
    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${temp_path}   local_filename=${tmp_file_id}.xml
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  20   OAM Precondition Cell Should Be Onair


Activate Delta Plan By REST Without Wait VDU Up
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...  Change History
    ...  2.12.2021   chris.l.cao@nokia-sbell.com,  add this KW to shorten dryrun time
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example of changing btsName
    ...   | VDU Rest Login |
    ...   | ${VDU_CONF} | Get VDU Conf From SCF |
    ...   | ${plan_id} |  ${action_id}  | Generate Delta Plan |  plan_name=changeBTSName |
    ...   | ${distname} |  Set Variable | MRBTS-${VDU_CONF["mrbts_id"]} |
    ...   | ${para_dict} | create dictionary |   btsName=btsName_new |
    ...   | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${distname} | updated_paras_dict=${para_dict} | operation=replace |
    ...   | Validate Delta Plan By REST |  ${plan_id} |
    ...   | Activate Delta Plan By REST |  ${plan_id} |
    ...   | VDU Rest Logout |
    ...
    ${temp_path}  Get A Directory  delta_plan
    ${tmp_file_id}   get unique id  precise=LOW
    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${temp_path}   local_filename=${tmp_file_id}.xml
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}


Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}
    [Documentation]   Delete Delta Plan By Plan Id
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Delete Delta Plan By Plan Id | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ...
    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}
    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once


_Make Sure Delta Plan Is Deleted Once
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Should Be True  ${all_plans.__len__()}==0


VDU Online Change Parameters By Delta Plan REST
    [Arguments]     ${mo_dn}   ${updated_paras_list}   ${operation}=replace   ${activate}=${True}
    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   VDU Online Change Parameters By Delta Plan REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    modified by:   <1-Mar-2021>, <rifeng>, <e.g. add argument wait_vdu_up to wait vdu onair for parameter need reset vdu>
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
    ...   |                      |     | {'f1Cplane/0/ipV4AddressDN1':'MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', 'para2':'value2'} |
    ...   | operation           | no |  the operation - add, replace, remove, revert. The default is replace |
    ...   | activate           | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | wait_vdu_up       | no | default is ${False} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...   | VDU Rest Logout |
    ...
    ...   Without activate it:
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
    ...
    ${timeout}   convert to integer  ${timeout}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${out}   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}

    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST  plan_id=${plan_id}   force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    wait_vdu_up=${wait_vdu_up}


VDU Online Change Parameters By Delta Plan REST Without Wait VDU Up
    [Arguments]     ${mo_dn}   ${updated_paras_list}   ${operation}=replace   ${activate}=${True}
    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}     ${timeout}=60
    [Documentation]   VDU Online Change Parameters By Delta Plan REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...  Change History
    ...  2.12.2021   chris.l.cao@nokia-sbell.com,  add this KW to shorten dryrun time
    ...
    ...    modified by:   <1-Mar-2021>, <rifeng>, <e.g. add argument wait_vdu_up to wait vdu onair for parameter need reset vdu>
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
    ...   |                      |     | {'f1Cplane/0/ipV4AddressDN1':'MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', 'para2':'value2'} |
    ...   | operation           | no |  the operation - add, replace, remove, revert. The default is replace |
    ...   | activate           | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...   | VDU Rest Logout |
    ...
    ...   Without activate it:
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
    ...
    ${timeout}   convert to integer  ${timeout}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${out}   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}

    run keyword if    "${activate}"=="${True}"
    ...   Activate Delta Plan By REST Without Wait VDU Up   plan_id=${plan_id}   force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}


Generate MO Message For Modifying List Parameters
    [Arguments]     @{parameter_list}
    [Documentation]   Generate MO Message For Modifying List Parameters
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | action        | Yes | add, update or delete action for list content , default is add |
    ...    | operation     | Yes | create, update or delete for operation attribute of managedObject,|
    ...    | distName      | Yes | distName, e.g, MRBTS-2883/MNL-1/BTSSCL-1/TRSNW-1 |
    ...    | list_para_name | Yes | list parameter name under which you want to change parameters value |
    ...    | para_list  | Yes | key=value pair, it supports multi-parameters change. 'key' is the parameter where you want to change its value, |
    ...    |            |     | 'value' is the new value you want to assign. please see samples |
    ...
    ...    *RETURN VALUE*
    ...    MO message with modified parameters
    ...
    ...    Example
    ...    | ${MO} | Generate MO Message For Modifying List Parameters | scf_path=/tmp/scf.xml | action=update | operation=create |
    ...   | ... |  distName=MRBTS-5240/NRBTS-2/NRDU-1 |
    ...   | ... | list_para_name=f1Cplane |
    ...   | ... | ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | ... | ipV6AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{parameter_list}
    #${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    Run Keyword If  "scf_path" not in "${key_value_dict_keys}"   Fail  Should give scf_path parameter value!!!
    Run Keyword If  "action" not in "${key_value_dict_keys}"   Fail  Should give action parameter value!!!
    Run Keyword If  "operation" not in "${key_value_dict_keys}"   Fail  Should give operation parameter value!!!
    Run Keyword If  "distName" not in "${key_value_dict_keys}"   Fail  Should give distName parameter value!!!
    Run Keyword If  "list_para_name" not in "${key_value_dict_keys}"   Fail  Should give list_para_name parameter value!!!

    ${scf_path}     Set Variable  ${key_value_dict["scf_path"]}
    ${action}     Set Variable  ${key_value_dict["action"]}
    ${operation}     Set Variable  ${key_value_dict["operation"]}
    ${distName}     Set Variable  ${key_value_dict["distName"]}
    ${list_para_name}     Set Variable  ${key_value_dict["list_para_name"]}

    Remove From Dictionary   ${key_value_dict}   scf_path
    Remove From Dictionary   ${key_value_dict}   action
    Remove From Dictionary   ${key_value_dict}   operation
    Remove From Dictionary   ${key_value_dict}   distName
    Remove From Dictionary   ${key_value_dict}   list_para_name

    Remove Values From List   ${key_value_dict_keys}   scf_path
    Remove Values From List   ${key_value_dict_keys}   action
    Remove Values From List   ${key_value_dict_keys}   operation
    Remove Values From List   ${key_value_dict_keys}   distName
    Remove Values From List   ${key_value_dict_keys}   list_para_name

    Run Keyword If   '${action}'!='add' and '${action}'!='update' and '${action}'!='delete'
    ...    Fail    action should be add, update or delete!

    ${version}   scf.Get_Mo_Attribute   dist_name=${distName}  attribute=version
    ${class_name}   scf.Get_Mo_Attribute   dist_name=${distName}  attribute=class

    ${xml_handler}  Parse Xml  ${scf_path}
    @{MachedNode}   XML.get element  ${xml_handler}  xpath=.//managedObject[@distName="${distName}"]
    ${len}   Get Length   ${MachedNode}

    ${msg}   Set Variable    ${EMPTY}
    #handle Every Parameter Under ${distName}
    FOR  ${onenode}   IN   @{MachedNode}
        ${name_attribute}   XML.Get Element Attribute   ${onenode}   name
        ${res}  Run Keyword If   '${name_attribute}'=='${list_para_name}'   _Get Modified List Parameter Value
        ...   xml_node=${onenode}   action=${action}   dict_keys=${key_value_dict_keys}   dict_para=${key_value_dict}
        ...   ELSE   XML.Element To String  ${onenode}
        ${res}   Prehandle XML Content  ${res}
        ${msg}   Catenate    SEPARATOR=\n    ${msg}    ${res}
    END

    ${MO}   Catenate   SEPARATOR=\n  <managedObject class="${class_name}" distName="${distName}" operation="${operation}" version="${version}">
    ...        ${msg}
    ...  </managedObject>
    [Return]  ${MO}


Activate Staged Plan By REST
    [Arguments]  ${plan_id}
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    Activate plan operation information.
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Activate Staged Plan By REST | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ...
    ${out}   vdu.activate_plan   plan_id=${plan_id}
    ${action_id}  set variable   ${out['id']}

    ${out}   Activate Plan Operation Should Be Successful With Retry   action_id=${action_id}   plan_id=${plan_id}
    [Return]  ${out}


Activate Plan Operation Should Be Successful With Retry
    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    ${rtn}  Wait Until Keyword Succeeds  900   30
     ...   _Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${rtn}


_Activate Plan Operation Status Should Be Expected
    [Arguments]   ${plan_id}  ${operation_id}   ${expected_status}   ${vdu_index}=0   ${gnb_index}=0
    #vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    #${out}   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
    #Should Be True  "${out["status"]}"=="${expected_status}"

    ${r}  ${out}   run keyword and ignore error   vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    should be true    "${r}"=="PASS"
    return from keyword if   "${r}"!="PASS"

    ${r}  ${out}   run keyword and ignore error
       ...   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
    should be true    "${r}"=="PASS"

    Should Be True    "${out["status"]}"=="${expected_status}"

    [Return]  ${out}


Full Commission SCF On VDU
    [Arguments]  ${scf_file}=${EMPTY}   ${build_number}=${EMPTY}
    [Documentation]   Full Commission SCF On VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.07.2020,chris.l.cao@nokia-sbell.com, initialize version
    ...   17.06.2021,chris.l.cao@nokia-sbell.com, change according to no scf file in S3 server
    ...
    ...   | Input Parameters   | Man. | Description |
    ...   | scf_file | no | scf_file  |
    ...   | build_number | no | build_number |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Full Commission SCF On VDU |
    ...
    log to console  Full Commission SCF On VDU
    ${testline_name}   Get TestLine Name From TestLine

    should be true  ${scf_file.__len__()>0}

    VDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    log to console  Begin to commission SCF file...
    ${out}  Upload Plan And Validate And Activate  plan_file=${scf_file}   plan_name=${testline_name}_${build_number}
    sleep   2


_Get Modified List Parameter Value
    [Arguments]   ${xml_node}   ${action}   ${dict_keys}  ${dict_para}
    #${dict_keys}  ${dict_para}   _Create Dictionary From List Parameter Precisely   @{para_list}

    ${action}   Set Variable   ${action.lower()}
    ${current_list_content}   Run Keyword If  '${action}'=='add'  _Get Modified List Parameter Value Add   ${xml_node}   ${dict_keys}  ${dict_para}
    ...   ELSE IF  '${action}'=='update'  _Get Modified List Parameter Value Update   ${xml_node}    ${dict_keys}   ${dict_para}
    ...   ELSE IF  '${action}'=='delete'  _Get Modified List Parameter Value Delete   ${xml_node}    ${dict_keys}   ${dict_para}
    ...   ELSE   Fail    action should be add, update or delete!
    [Return]   ${current_list_content}


_Get Modified List Parameter Value Add
    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
    ${res}   XML.Element To String  ${xml_node}

    FOR   ${item}  IN  @{dict_keys}
        ${res}   Replace String Using Regexp   ${res}   <item>    <item><p name="${item}">${dict_para["${item}"]}</p>    count=1
    END

    [Return]  ${res}


_Get Modified List Parameter Value Update
    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
    ${res}   XML.Element To String  ${xml_node}
    ${res}   Prehandle XML Content   ${res}

    ${new_content}   Set Variable  ${EMPTY}
    FOR   ${item}  IN  @{dict_keys}
       ${new_content}    Set Variable   ${new_content}<p name="${item}">${dict_para["${item}"]}</p>
    END

    ${new_content}    Set Variable   <item>${new_content}</item>
    ${res}   Replace_String_With_Regexp   content=${res}
    ...   g1_regexp=\<list\\s+name=\\S+\>
    ...   g2_regexp=.*
    ...   g3_regexp=\</list\>
    ...   g2_new_value=${new_content}

    [Return]  ${res}


_Get Modified List Parameter Value Delete
    [Arguments]  ${xml_node}   ${dict_keys}   #${dict_para}
    ${res}   XML.Element To String  ${xml_node}
    ${res}   Prehandle XML Content  ${res}

    FOR   ${item}  IN  @{dict_keys}
       ${res}  Run Keyword If   "${item}" in """${res}"""   Replace String Using Regexp   ${res}   <p\\s+name="${item}">.*?</p>    ${EMPTY}
       ...    ELSE   set variable   ${res}
    END

    [Return]  ${res}



Prehandle XML Content
    [Arguments]  ${xml_content}
    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | xml_content      | Yes | content with xmlns="raml21.xsd"  |
    ...
    ...    *RETURN VALUE*
    ...    Return content without xmlns="raml21.xsd"
    ...
    ...    Example
    ...    | ${res} | XML.Element To String     | ${xml_handler} |
    ...    | ${res} | Prehandle XML Content | ${res}    |
    ...
    ${xml_content}  Replace String  ${xml_content}  xmlns="raml21.xsd"  ${EMPTY}
    [Return]   ${xml_content}


Recommission vDU with new SCF
    [Arguments]   ${NEW_SCF}
    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | NEW_SCF         | Yes | New SCF file  |
    ...
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Recommission vDU with new SCF | NEW_SCF=my_NEW_SCF |

    Vdu Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    vDU Send Commission By RestApi    scf_path=${NEW_SCF}    restapi_version=cuoam_21b   vdu_index=0

Get RU ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get RU ID and also EQM/APEQM ID from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path         | Yes | full path and file name  |
    ...   *RETURN VALUE*
    ...    EQM_ID, APEQM_ID, RU_ID
    ...   Example
    ...   | Get RU ID From vDU SCF | ${scf_file_with_fullpath} |

    ${scf_content}   OperatingSystem.Get File      ${scf_path}

    ${result}        Get Regexp Matches            ${scf_content}    /EQM_\\S{3}/APEQM_R-\\d+
    ${EQM_ID}        Remove String Using Regexp    ${result[0]}      /EQM_      /APEQM_R-\\d+

    ${result}        Get Regexp Matches            ${scf_content}    /APEQM_\\S{4}/RMOD_R-\\d+
    ${APEQM_ID}      Remove String Using Regexp    ${result[0]}      /APEQM_      /RMOD_R-\\d+

    ${result}        Get Regexp Matches            ${scf_content}    EQM_R-\\d+/APEQM_R-\\d+/RMOD_\\S{3}
    ${RU_ID}         Remove String Using Regexp    ${result[0]}      EQM_R-\\d+/APEQM_R-\\d+/RMOD_

    [Return]    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}


Get RU runtime HW information from runtime SCF
    [Arguments]
    [Documentation]   Get RU ID and also productName/productCode/serialNumber from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    productName, productCode, serialNumber, RU_ID
    ...   Example
    ...   | Get RU runtime HW information from runtime SCF |  |

    VDU Rest Login

    ${timestamp}    Get Timestamp
    ${scf_path}     Get A Directory    scf_${timestamp}

    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
    ...                                                       filename=scf_${timestamp}.xml
    ...                                                       include_runtime_data=${True}

    scf.Load_Scf    file_path=${scf_file_with_fullpath}

    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}    Get RU ID From vDU SCF    ${scf_file_with_fullpath}

    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_${EQM_ID}/APEQM_${APEQM_ID}/RMOD_${RU_ID}

    ${productName}     scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                          p_name=productName
    Log To Console     ${productName}
    ${productCode}     scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                          p_name=productCode
    Log To Console     ${productCode}
    ${serialNumber}    scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                          p_name=serialNumber
    Log To Console     ${serialNumber}

    vDU Rest Logout

    [Return]    ${productName}    ${productCode}     ${serialNumber}    ${RU_ID}


Get RU runtime Status from runtime SCF
    [Arguments]
    [Documentation]   Get administrativeState/operationalState/proceduralStatus from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    administrativeState, operationalState, proceduralStatus
    ...   Example
    ...   | Get RU runtime Status from runtime SCF |  |

    VDU Rest Login

    ${timestamp}    Get Timestamp
    ${scf_path}     Get A Directory    scf_${timestamp}

    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
    ...                                                       filename=scf_${timestamp}.xml
    ...                                                       include_runtime_data=${True}

    scf.Load_Scf    file_path=${scf_file_with_fullpath}

    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}    Get RU ID From vDU SCF    ${scf_file_with_fullpath}

    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_${EQM_ID}/APEQM_${APEQM_ID}/RMOD_${RU_ID}

    ${administrativeState}    scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=administrativeState
    Log To Console     ${administrativeState}
    ${operationalState}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=operationalState
    Log To Console     ${operationalState}
    ${proceduralStatus}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=proceduralStatus
    Log To Console     ${proceduralStatus}

    vDU Rest Logout

    [Return]    ${administrativeState}    ${operationalState}     ${proceduralStatus}

Get vDU Instance TNL ID
    [Arguments]  ${scf_path}  ${podname}
    [Documentation]   Get vDU Instance TNL ID
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    TNL instance is generated by system, all the TNL runtime info is under TNL instance, for example TNL-1 is for OAMCP TNL template,
    ...    all the configuration is set under TNL-1, the OAMCP TNL instance maybe TNL-4, if we want to check set by system parameters value,
    ...    then we need to check it under TNL-4, so this KW is to get the pod TNL instance id.
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | podname | yes | the full pod name of OAMCP or UP pod |
    ...
    ...    *RETURN VALUE*
    ...    Instance TNL id of given podname.
    ...
    ...    Example
    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=po-cran1-oamcp-0 |
    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=po-cran1-up-0 |
    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=up |
    ...

    ${distName}   Get MO distName    scf_path=${scf_path}  vmAllocated=${podname}
    ${result}     Get Regexp Matches     ${distName[0]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHLK-\\d+/ETHLK_R-\\d+   1
    ${tnl_id}  Set Variable If  ${result}   ${result[0]}
    should be true  ${tnl_id}>=1
    [Return]  ${tnl_id}

Get vDU IPADDRESS DN
    [Arguments]  ${scfpath}    ${uniqueIpId}    ${tnlid}    ${version}=4
    [Documentation]   Get vDU IPADDRESS DN
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Sometimes we need configure IPADDRESS DN for some application, such as f1c plane, some kind of source ip address DN,
    ...    and the ip address DN should be the DN of TNL template such as TNL-1 for OAMCP, we can get it automatically using
    ...    IPADDRESSV4/V6.uniqueIpAddressIdentifier to filter.
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | uniqueIpId | yes | the uniqueIpAddressIdentifier of the searched IPADDRESS DN |
    ...    | version    | no | the ip version default is 4 |
    ...    | tnlid    | yes | the template type TNL ID of the IP address DN located |
    ...    *RETURN VALUE*
    ...    IP address DN for given unique ip address id under TNL with template true type.
    ...
    ...    Example
    ...    |  ${oam_f1_IPDN}  | Get vDU IPADDRESS DN | scf_path=/tmp/a.scf | uniqueIpId=F1-C Xp | tnlid=1 |
    ...    |  ${up_f1_IPDN}  | Get vDU IPADDRESS DN | scf_path=/tmp/a.scf | uniqueIpId=F1-U |  tnlid=3  |
    ...
    ${distName}   Get MO distName    scf_path=${scfpath}  uniqueIpAddressIdentifier=${uniqueIpId}
    ${distName_length}=   get length   ${distName}
    ${ipaddressdn}=    set variable    ${None}
    ${index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${distName_length}
       ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/IPNO-\\d+/IPIF-\\d+/IPADDRESSV${version}-\\d+   1
       ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
       exit for loop if  '${result[0]}'=='${tnlid}'
    END
    ${ipaddressdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
    [Return]  ${ipaddressdn}

Get vDU ETHLK DN
    [Arguments]  ${scfpath}    ${underLyingIF}    ${tnlid}
    [Documentation]   Get vDU ETHLK DN
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Sometimes we need configure ETHLK DN for some application, such as linkSelectorDN of ETHIF, for configuration we need ETHLK
    ...    DN of TNL template such as TNL-1 for OAMCP, when we get TNL counter in TA scripts, we need the DN of TNL instance,
    ...    We can get it automatically using underLyingInterface to filter
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | underLyingIF | yes | the underLyingInterface of the searched ETHLK DN |
    ...    | tnlid    | yes | the template or instance type TNL ID of the ETHLK DN located |
    ...    *RETURN VALUE*
    ...    ETHLK DN for given underLyingInterface.
    ...
    ...    Example
    ...    |  ${oam_f1_ETHLKDN}  | Get vDU ETHLK DN | scf_path=/tmp/a.scf | underLyingIF=f1 | tnlid=1 |
    ...    |  ${up_f1_ETHLKDN}  | Get vDU ETHLK DN | scf_path=/tmp/a.scf | underLyingIF=f1 |  tnlid=3  |
    ...
    ${distName}   Get MO distName    scf_path=${scfpath}  underLyingInterface=${underLyingIF}
    ${distName_length}=   get length   ${distName}
    ${ethlkdn}=    set variable    ${None}
    ${index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${distName_length}
       ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHLK-\\d+   1
       ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
       exit for loop if  '${result[0]}'=='${tnlid}'
    END
    ${ethlkdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
    [Return]  ${ethlkdn}

Get vDU VLANIF DN
    [Arguments]  ${scfpath}    ${vlanIf}    ${tnlid}
    [Documentation]   Get vDU VLANIF DN
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Sometimes we need configure ETHIF DN for some application, such as interfaceDN of IPIF, for configuration we need VLANIF
    ...    DN of TNL template such as TNL-1 for OAMCP, when we get TNL counter in TA scripts, we need the DN of TNL instance,
    ...    We can get it automatically using vlanIfName to filter
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | vlanIf | yes | the vlanIfName of the searched VLANIF DN |
    ...    | tnlid    | yes | the template or instance type TNL ID of the VLANIF DN located |
    ...    *RETURN VALUE*
    ...    VLANIF DN for given underLyingInterface.
    ...
    ...    Example
    ...    |  ${oam_f1_VLANIFDN}  | Get vDU VLANIF DN | scf_path=/tmp/a.scf | vlanIf=f1cplane | tnlid=1 |
    ...    |  ${up_f1_VLANIFDN}  | Get vDU VLANIF DN | scf_path=/tmp/a.scf | vlanIf=f1uplane |  tnlid=3  |
    ...
    ${distName}   Get MO distName    scf_path=${scfpath}  vlanIfName=${vlanIf}
    ${distName_length}=   get length   ${distName}
    ${vlanifdn}=    set variable    ${None}
    ${index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${distName_length}
       ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHIF-\\d+/VLANIF-\\d+   1
       ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
       exit for loop if  '${result[0]}'=='${tnlid}'
    END
    ${vlanifdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
    [Return]  ${vlanifdn}

Add Delta Plan MO
    [Arguments]  ${plan_id}   ${parent_mo_dn}   ${mo_name}    ${timeout}=60
    [Documentation]   Add Delta Plan MO
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   It can be used together with 'Update Delta Plan Parameter' to add new MO on delta plan, under this conditio,
    ...   'Update Delta Plan Parameter' operation should be set to 'add'.
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | parent_mo_dn | yes | parent_mo_dn   |
    ...   | mo_name | yes | mo_name   |
    ...   | timeout    | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Add Delta Plan MO | plan_id=<my_plan_id> | parent_mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1 | mo_name=PINGREQ-1
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.create_vdu_object_of_delta_plan   delta_plan_id=${plan_id}  parent_mo_dn=${parent_mo_dn}   mo_name=${mo_name}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Add Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

Add Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Add Delta Plan MO Should Be Successful
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Add Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Add Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Add Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Add Delta Plan MO Should Be Expected
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...
    ${out}   vdu.get_create_vdu_object_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Delete Delta Plan MO
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=60
    [Documentation]   Delete Delta Plan MO
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | timeout    | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Delete Delta Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1 |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.delete_mo_of_delta_plan   delta_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Delete Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

Delete Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Delete Delta Plan MO Should Be Successful
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Delete Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Delete Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Delete Delta Plan MO Should Be Expected
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...
    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan      delta_plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Get VDU Parameter Value Online
    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60
    [Documentation]   Get VDU Parameter Value Online
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   If the searched parameter is under list/item, please set the para_name with something like 'list_name/item_number/parameter_name'
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn     | yes | the distname of given parameter |
    ...   | para_name | yes | parameter name   |
    ...   | timeout   | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    the parameter value getting from current plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1/PINGRES-1 | para_name=packetsLost |
    ...  | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/IPRT-1 | para_name=staticRoutes/0/gateway |
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}


vDU Modify Parameters Online After Checking
    [Arguments]    ${para_list}   ${value_list}   ${mo}    ${vdu_index}=0
    [Documentation]   vDU Modify Parameters Online After Checking
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...   | status    | yes | if it is the same between the expect value  and the value in testlilne |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}    ${status}=    vDU Modify Parameters Online After Checking |
    ...   para_list=${para_list}    value_list=${value_list}    mo=${mo} |

    log to console    DU modify parameters online
    ${origin_para_value_dict}=    Get Current Parameters Dict    ${para_list}    ${mo}    ${vdu_index}
    ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict   ${para_list}  ${value_list}
    ${status}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${Updated_Paras_Dict}
    vDU Rest Login    vdu_index=${vdu_index}
    run keyword if     "${status}"== "${False}"    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${mo}    updated_paras_list=${Updated_Paras_Dict}
    [Return]    ${origin_para_value_dict}    ${status}
    [Teardown]  VDU Rest Logout    ${vdu_index}


vDU Modify Parameters Online After Checking Without Wait VDU Up
    [Arguments]    ${para_list}   ${value_list}   ${mo}    ${vdu_index}=0
    [Documentation]   vDU Modify Parameters Online After Checking
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...  Change History
    ...  2021.12.02  chris.l.cao@nokia-sbell.com, It's used by 'Aic Common Setup' only to speed up dryrun
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...   | status    | yes | if it is the same between the expect value  and the value in testlilne |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}    ${status}=    vDU Modify Parameters Online After Checking |
    ...   para_list=${para_list}    value_list=${value_list}    mo=${mo} |

    log to console    DU modify parameters online
    ${origin_para_value_dict}=    Get Current Parameters Dict    ${para_list}    ${mo}    ${vdu_index}
    ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict   ${para_list}  ${value_list}
    ${status}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${Updated_Paras_Dict}
    vDU Rest Login    vdu_index=${vdu_index}
    run keyword if     "${status}"== "${False}"    VDU Online Change Parameters By Delta Plan REST Without Wait VDU Up
    ...    mo_dn=${mo}    updated_paras_list=${Updated_Paras_Dict}
    [Return]    ${origin_para_value_dict}    ${status}
    [Teardown]  VDU Rest Logout    ${vdu_index}


Get Current Parameters Dict
    [Arguments]   ${para_list}    ${mo}    ${vdu_index}=0
    [Documentation]   Get Current Parameters Dict
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...  Change History
    ...  2021.07.11   Ren Shubin   If para is no exist in MO, will set as NULL.
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}=    Get Current Parameters Dict |
    ...   para_list=${para_list}    mo=${mo} |
    ...
    ${origin_para_value_dict}   create dictionary
    vDU Rest Login    vdu_index=${vdu_index}
    ${length}=    get length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${status}  ${value}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${mo}  ${para_list[${i}]}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${null}
        Set to Dictionary  ${origin_para_value_dict}  ${para_list[${i}]}   ${value_current}
    END
    [Return]  &{origin_para_value_dict}
    [Teardown]    VDU REST LOGOUT    ${vdu_index}


Convert Updating Parameters From List To Dict
    [Arguments]   ${para_name_list}   ${values_list}
    [Documentation]   Convert Updating Parameters From List To Dict
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_name_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...
    ...   *RETURN VALUE*
    ...   | Updated_Paras_Dict    | yes | the parameters and the expect value |
    ...
    ...   Example
    ...  | ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict| para_list=${para_list}    value_list=${value_list}|

    ${Updated_Paras_Dict}   create dictionary
    ${length}=    get length    ${para_name_list}
    FOR  ${i}  IN RANGE    0     ${length}
      Set To Dictionary   ${Updated_Paras_Dict}   ${para_name_list[${i}]}  ${values_list[${i}]}
    END
    [Return]  ${Updated_Paras_Dict}


Get RU Type By SCF
    [Documentation]   Get RU Type By SCF
    ...   *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_name_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...
    ...   *RETURN VALUE*
    ...   | ${prodCodePlanned}  |  ${productName}  |
    ...
    ...   Example
    ...  | ${prodCodePlanned}  |  ${productName}  |  Get RU Type By SCF |

    VDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${RMOD_DISTNAME}  Set Variable   MRBTS-${VDU_CONF["mrbts_id"]}/EQM-1/APEQM-1/RMOD-1
    ${prodCodePlanned}     scf.Get_Value_From_Scf
        ...      dist_name=${RMOD_DISTNAME}   p_name=prodCodePlanned

#    ${productName}   Set Variable If
#     ...   "${prodCodePlanned}"=="473966A.101"   AHCA
#     ...   "${prodCodePlanned}"=="473966A"       AHCA
#     ...   "${prodCodePlanned}"=="474341A"       AHBCC
#     ...   "${prodCodePlanned}"=="474341A.101"   AHBCC
    ${productName}   Get RF RroductName From ProdCodePlanned   prodCodePlanned=${prodCodePlanned}

     [Return]     ${prodCodePlanned}   ${productName}


Get RF RroductName From ProdCodePlanned
    [Arguments]  ${prodCodePlanned}
    [Documentation]   Get RF RroductName From ProdCodePlanned
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  13.12.2021   chris.l.cao@nokia-sbell.com,  initilization
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | prodCodePlanned   | yes | prodCodePlanned, e.g, 473966A.101,473966A, etc. |
    ...
    ...    *RETURN VALUE*
    ...   productName
    ...
    ...    Example
    ...    | ${productName} | Get RF RroductName From ProdCodePlanned | prodCodePlanned=475538A.101 |
    ...
    ${productName}   Set Variable If
     ...   "${prodCodePlanned}"=="473966A.101"   AHCA
     ...   "${prodCodePlanned}"=="473966A"       AHCA
     ...   "${prodCodePlanned}"=="474341A"       AHBCC
     ...   "${prodCodePlanned}"=="474341A.101"   AHBCC
     ...   "${prodCodePlanned}"=="475538A.101"   AEQY
     ...   "${prodCodePlanned}"=="475238A.M01"   AEQP
     ...   unknown prodCodePlanned
     Run Keyword If  "${productName}"=="unknown prodCodePlanned"   Fail  Unknown prodCodePlanned:${prodCodePlanned}
     [Return]   ${productName}


Online Enable actCli For vDU
    [Arguments]   ${gnb_index}=0
    [Documentation]   Enable actCli when it is false
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <09-02-2020>, <lingtsun>, <Initial creation>
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index   | no | the gnb index |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Online Enable actCli For vDU |
    ...
    ${quantity_of_vdu_for_specified_cu}=   Get vDU Number    gnb_index=${gnb_index}
    ${gnb_id}    set variable    ${tl.gnbs[0].instance_id}
    FOR   ${vdu_index}   IN RANGE   ${quantity_of_vdu_for_specified_cu}
         _Online Enable actCli For Specific vDU    gnb_id=${gnb_id}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    END


_Online Enable actCli For Specific vDU
    [Arguments]   ${gnb_id}    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   _Online Enable actCli For Specific vDU
    ...    *AUTHOR* unknown@nokia-sbell.com
    ...
    ...  Change History
    ...  2.12.2021   chris.l.cao@nokia-sbell.com,  change to 'vDU Modify Parameters Online After Checking Without Wait VDU Up'
    ...                                            to shorten dryrun time
    ...
    ${MO}    set variable     MRBTS-${gnb_id}/MNL-1/MNLENT-1/FEATCADM-1
    @{para_list}    Create list    actCli
    @{value_list}    Create list    true
    vDU Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${actCli}=    Get VDU Parameter Value Online     ${MO}    actCli
    run keyword if  """${actCli}"""=="""false"""
    ...    vDU Modify Parameters Online After Checking Without Wait VDU Up   para_list=${para_list}    value_list=${value_list}    mo=${MO}
    ...    vdu_index=${vdu_index}
