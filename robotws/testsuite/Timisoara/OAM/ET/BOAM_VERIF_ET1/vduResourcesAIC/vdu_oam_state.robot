*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_oam_state.robot



#*** Variables ***



*** Keywords ***
Get Static Route Info WebEM
    [Arguments]   ${distname}   ${instancedn}
    [Documentation]    Get Static Route Info WebEM
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the configured static route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | gateway    | yes | the given static route gateway |
    ...    | dstip   | yes | the given static route destination ip |
    ...    | prefixlength   | yes | the given static route prefix length |
    ...    | preferenceid   | yes | the given static route preference id |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | Get Static Route Info WebEM | distname=MRBTS-5318/TNLSVC-1/TNL-1/IPNO-1/IPRTV6-1 |
    ...    | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | VDU Logout |
    ...
    ${destip_par}   set variable if  'IPRTV6' in '''${distname}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  'IPRTV6' in '''${distname}'''    destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  'IPRTV6' in '''${distname}'''    gatewayIpv6Addr   gateway
    ${sr_par}   set variable if  'IPRTV6' in '''${distname}'''    staticIpv6Routes   staticRoutes
    ${gwaddr}   scf.get_all_values_from_scf   dist_name=${distname}   p_name=${gw_par}
    ${route_len}   get length  ${gwaddr}
    VDU Rest Login
    FOR    ${i}    IN RANGE    0    ${route_len}
        ${gateway}   scf.get_value_from_scf   dist_name=${distname}   p_name=${gw_par}   index=${i}
        ${destip}   scf.get_value_from_scf   dist_name=${distname}   p_name=${destip_par}   index=${i}
        ${prefixlen}   scf.get_value_from_scf   dist_name=${distname}   p_name=${prefix_par}   index=${i}
        ${status}   ${tmppref}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${distname}   ${sr_par}/${i}/preference
        ${preference}   set variable if  '${status}'=='PASS'   ${tmppref}   1
        ${exist}   Static Route Exist In Forwarding Entries   gateway=${gateway}   dstip=${destip}
        ...  prefixlength=${prefixlen}   preferenceid=${preference}   instancedn=${instancedn}
        should be true  '${exist}'=='${True}'   Configured static route is not exist in forwarding entries!
    END

Static Route Exist In Forwarding Entries
    [Arguments]   ${gateway}   ${dstip}   ${prefixlength}   ${instancedn}    #${preferenceid}
    [Documentation]    Static Route Exist In Forwarding Entries
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the given static route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | gateway    | yes | the given static route gateway |
    ...    | dstip   | yes | the given static route destination ip |
    ...    | prefixlength   | yes | the given static route prefix length |
    ...    | preferenceid   | yes | the given static route preference id |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...   Static route exist boolen value
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${routeexistflag} | Static Route Exist In Forwarding Entries | gateway=2a00:8a00:8000:117:1:2:a47:a651 |
    ...    |   dstip=:: | prefixlength=0 | preferenceid=1 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | VDU Logout |
    ...
    ${routetype}   scf.get_all_values_from_scf   dist_name=${instancedn}   p_name=routeType
    ${forwardtable_len}   get length   ${routetype}
    ${route_index}=    set variable    ${None}
    ${route_exist}=    set variable    ${False}
    ${destip_par}   set variable if  ':' in '''${gateway}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  ':' in '''${gateway}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  ':' in '''${gateway}'''   gatewayIpv6Addr   gateway
    ${v6gateway}   run keyword if  ':' in '''${gateway}'''   Remove String Using Regexp   ${gateway}   :0   :
    ${finalgateway}   set variable if  ':' in '''${gateway}'''   ${v6gateway}   ${gateway}
    ${v6dstip}   run keyword if  ':' in '''${gateway}'''   Remove String Using Regexp   ${dstip}   :0   :
    ${finaldstip}   set variable if  ':' in '''${gateway}'''   ${v6dstip}   ${dstip}
    FOR    ${i}    IN RANGE    0    ${forwardtable_len}
        ${type}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=routeType   index=${i}
        ${st1}   ${prefer1}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/preference
        ${preference_fw}   set variable if  '${st1}'=='PASS'   ${prefer1}   ${None}
        ${destip_fw1}   scf.get_value_from_scf   dist_name=${instancedn}  list_name=forwardingEntries  p_name=${destip_par}   index=${i}
        ${prefixlen_fw}   scf.get_value_from_scf   dist_name=${instancedn}  list_name=forwardingEntries   p_name=${prefix_par}   index=${i}
        ${status}   ${gw_fw}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/${gw_par}
        ${dest_gw1}   set variable if  '${status}'=='PASS'   ${gw_fw}   ${None}
        ${dest_gw2}   run keyword if  ':' in '''${dest_gw1}'''   Remove String Using Regexp   ${dest_gw1}   :0   :
        ${dest_gw}   set variable if  ':' in '''${dest_gw1}'''   ${dest_gw2}   ${dest_gw1}
        ${destip_fw2}   run keyword if  ':' in '''${destip_fw1}'''   Remove String Using Regexp   ${destip_fw1}   :0   :
        ${destip_fw}   set variable if  ':' in '''${destip_fw1}'''   ${destip_fw2}   ${destip_fw1}
        ${indexflag1}=   Set Variable If   '${type}' == 'indirect' and '${dest_gw}' == '${finalgateway}'   ${True}   ${False}
        ${indexflag2}=   Set Variable If   '${indexflag1}'=='${True}' and '${destip_fw}' == '${finaldstip}'   ${True}   ${False}
        ${indexflag3}=   Set Variable If   '${indexflag2}'=='${True}' and '${prefixlen_fw}' == '${prefixlength}'   ${True}   ${False}
    #\    ${route_exist}=   Set Variable If   '${indexflag3}'=='${True}' and '${preference_fw}' == '${preferenceid}'   ${True}   ${False}
        ${route_exist}=   Set Variable If   '${indexflag3}'=='${True}'   ${True}   ${False}
       exit for loop if  '${route_exist}'=='${True}'
    END
    [Return]    ${route_exist}

Direct Route Exist In Forwarding Entries
    [Arguments]   ${dstip}   ${prefixlength}    ${preference}   ${instancedn}
    [Documentation]    Direct Route Exist In Forwarding Entries
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Check whether the given direct route exist in forwarding entries under IPRT_R or IPRTV6_R MO
    ...    | Input Parameters | Man. | Description |
    ...    | dstip   | yes | the given direct route destination ip |
    ...    | prefixlength   | yes | the given direct route prefix length |
    ...    | preferenceid   | yes | the given direct route preference for ipv6 route or source ip for ipv4 route |
    ...    | instancedn   | yes | the instance distame whether the forwarding entries belongs to |
    ...
    ...    *RETURN VALUE*
    ...   Direct route exist boolen value
    ...
    ...    Example
    ...       VDU Rest Login
    ...    |  ${scf_path}  Get A Directory  scf
    ...    |  ${scf_file}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${True}
    ...    | scf.Load_Scf  file_path=${scf_file}
    ...    | ${routeexistflag} | Direct Route Exist In Forwarding Entries | dstip=2a00:8a00:8000:117:1:2:a47:a650 |
    ...    | prefixlength=125 | preferenceid=256 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV6-1/IPRTV6_R-1 |
    ...    | ${routeexistflag} | Direct Route Exist In Forwarding Entries | dstip=10.71.177.72 |
    ...    | prefixlength=29 | preferenceid=10.71.177.74 | instancedn=MRBTS-5318/TNLSVC-1/TNL-4/IPNO-1/IPRTV4-1/IPRTV4_R-1 |
    ...    | VDU Logout |
    ...
    ${routetype}   scf.get_all_values_from_scf   dist_name=${instancedn}   p_name=routeType
    ${forwardtable_len}   get length   ${routetype}
    ${route_index}=    set variable    ${None}
    ${route_exist}=    set variable    ${False}
    ${destip_par}   set variable if  ':' in '''${dstip}'''   destIpv6Addr   destIpAddr
    ${preference_par}   set variable if  ':' in '''${dstip}'''   preference   preSrcIpv4Addr
    ${prefix_par}   set variable if  ':' in '''${dstip}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${v6dstip}   run keyword if  ':' in '''${dstip}'''   Remove String Using Regexp   ${dstip}   :0   :
    ${finaldstip}   set variable if  ':' in '''${dstip}'''   ${v6dstip}   ${dstip}
    FOR    ${i}    IN RANGE    0    ${forwardtable_len}
        ${type}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=routeType   index=${i}
        ${st1}   ${prefer1}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${instancedn}   forwardingEntries/${i}/preference
        ${preference_fw}   set variable if  '${st1}'=='PASS'   ${prefer1}   ${None}
        ${ipv4flag}   set variable if  ':' not in '''${dstip}'''   ${True}   ${False}
        ${destip_fw1}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${destip_par}   index=${i}
        ${prefixlen_fw}   scf.get_value_from_scf   dist_name=${instancedn}   p_name=${prefix_par}   index=${i}
        ${destip_fw2}   run keyword if  ':' in '''${destip_fw1}'''   Remove String Using Regexp   ${destip_fw1}   :0   :
        ${destip_fw}   set variable if  ':' in '''${destip_fw1}'''   ${destip_fw2}   ${destip_fw1}
        ${indexflag1}=   Set Variable If   '${type}' == 'direct' and '${destip_fw}' == '${finaldstip}'   ${True}   ${False}
        ${indexflag2}=   Set Variable If   '${indexflag1}'=='${True}' and '${prefixlen_fw}' == '${prefixlength}'   ${True}   ${False}
        ${preferenceflag}=   Set Variable If   '${ipv4flag}'=='${True}' or '${preference_fw}' == '${preference}'   ${True}   ${False}
        ${route_exist}=   Set Variable If   '${indexflag2}'=='${True}' and '${preferenceflag}' == '${True}'   ${True}   ${False}
       exit for loop if  '${route_exist}'=='${True}'
    END
    [Return]    ${route_exist}


Get Parameter Definition Error
    [Arguments]  ${errors_list}   @{para_list}
    [Documentation]   Get Parameter Definition Error
    ...    *AUTHOR*chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | errors_list  | Yes | list of errors which are from vdu.Get_Staged_Plan_Validation_Results()["parameterDefinitionError"] |
    ...    | para_list  | Yes | key=value pair, e.g,  distname=xxx, parameter_path=f1SctpProfileIdOfDu, please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return list of dictionary that matched the filter.
    ...
    ...    Example
    ...    | ${distName}  | set variable | MRBTS-5240/NRBTS-2 |
    ...    | ${errors} | vdu.Get_Staged_Plan_Validation_Results | plan_id=<my_plan_id> | validation_id=<my_validation_id> |
    ...    | ${error}  | Set Variable | ${errors["parameterDefinitionError"]} |
    ...    | ${my_err} | Get Parameter Definition Error | ${error} | distname=${distName} | parameter_path=f1SctpProfileIdOfDu |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}

    #${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   Evaluate  list(${key_value_dict})
    Should Be True  ${key_value_dict_keys.__len__()}>=1

    ${comparision_keys}   Copy List   ${key_value_dict_keys}
    Run Keyword If   """nidd_id""" in """${comparision_keys}"""   Remove Values From List   ${comparision_keys}   nidd_id
    ${rtn_list}   Create List
    FOR    ${i}    IN   @{errors_list}
       Log To Console  ${i}
       Run Keyword If   """nidd_id""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["nidd_id"]}""" != """${i["nidd_id"]}"""
       ${matched}   Run Keyword If  ${comparision_keys.__len__()}>0   _Value Is In Another Dictionary   to_be_checked_dict=${key_value_dict}
            ...   comparision_keys=${comparision_keys}  another_dict=${i}
       ...   ELSE   set variable  Found
       Continue For Loop If  '${matched}'=='${None}'
       ${tmp}   Copy Dictionary   ${i}
       Append To List   ${rtn_list}   ${tmp}
    END

    [Return]     ${rtn_list}


_Value Is In Another Dictionary
    [Arguments]   ${to_be_checked_dict}   ${comparision_keys}   ${another_dict}
    [Documentation]  return 'Found' if specifised values give by comparision_keys is 'in' another dictionary, otherwise return '${None}'
    ...    It's 'AND' operation among all keys given in ${comparision_keys}
    ...    *AUTHOR*chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | to_be_checked_dict  | Yes | to_be_checked_dict |
    ...    | comparision_keys  | Yes | comparision_keys |
    ...    | another_dict  | Yes | another_dict |
    ...
    ...    *RETURN VALUE*
    ...    Return 'Found' if matched, otherwise return ${None}
    ...
    ...    Example
    ...    | comparision_keys | create list | key1 | key2 |
    ...   | ${result} | _Value Is In Another Dictionary | to_be_checked_dict=${dict1} | comparision_keys=${comparision_keys} |
    ...   | ... | another_dict=${dict2} |
    ...
    ${rtn}   Set Variable   Found
    FOR    ${j}    IN   @{comparision_keys}
        Continue For Loop If  """${to_be_checked_dict["${j}"]}""" in """${another_dict["${j}"]}"""
       ${rtn}   Set Variable  ${None}
       Exit For Loop
    END
    [Return]  ${rtn}


Ping Result Should Be Expected In VDU WebEM
    [Arguments]    ${expected}
    [Documentation]   Ping Result Should Be Expected In VDU WebEM
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | Ping Result Should Be Expected In VDU WebEM | PASSED |
    ...
    ${out}   svdu.Get Ip Connectivity Test Result

    run keyword if   "${expected}"=="EMPTY"   should be true  ${out.__len__()==0}
    return from keyword if   "${expected}"=="EMPTY"

    should be true  ${out.__len__()>=1}
    ${actual}   set variable  ${out[0]}
    ${Test_result}   set variable  ${actual["Test result"]}

    run keyword if   "${expected}"=="PASSED"   should be true  """${Test_result}"""=="""Successful"""
    ...   ELSE IF   "${expected}"=="FAILED"   should be true  """${Test_result}"""=="""Failed"""
    ...   ELSE    Fail   unknown expected value:${expected}


Get Source Address For oamcp oam
    [Documentation]   get source address for oamcp oam
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...    Example
    ...    | ${source_address} | get source address for oamcp oam |
    ...
    ${pod_prefix}   Get Pod Name Prefix
    ${vdu_oam_ip}   Get vDU OAM Ip
    ${source_address}   set variable   OAM_${pod_prefix}oam-0_oam_certman-server ${vdu_oam_ip}
    [Return]  ${source_address}


OAM Precondition Cell Should Be Onair For Deploy VDU
    [Documentation]   OAM Precondition Cell Should Be Onair For Deploy VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | OAM Precondition Cell Should Be Onair For Deploy VDU |
    ...
    log to console  \n*** OAM Precondition Cell Should Be Onair For Deploy VDU ... ***
    All DUs Container Status Should Be Normal
    vDU Verify All Cells Status Should Be Onair
   #    Should Have Power On All RUs
    Run Keyword And Ignore Error  Vdu Rest Logout
    run keyword and ignore error  Disconnect Interactive Connections


Is VDU OAM Up
    #[Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Is VDU OAM Up
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    ${True} or ${False}
    ...
    ...    Example
    ...    |  ${status} | Is VDU OAM Up |
    ...
    ${r}   ${out}   run keyword and ignore error   vdu rest login
    ${state}   set variable if   "${r}"=="PASS"    ${True}   ${False}

    [Return]   ${state}


Get RU Operational State via REST
    [Arguments]   ${ru_index}=0   ${need_rest_login}=${True}
    [Documentation]   Get RU Operational State via REST
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ru_index | No | ru_index, default value is 0  |
    ...    | need_rest_login | No | need_rest_login, default value is 0  |
    ...
    ...    *RETURN VALUE*
    ...   RU version, type is string
    ...
    ...    Example
    ...   | ${operational_State} | Get RU Operational State via REST |
    ...

    run keyword if  "${need_rest_login}"=="${True}"   vdu rest login
    ${out}   vdu.get_rmods_status
    ${one_ru_info}   set variable  ${out[${ru_index}]}
    ${operational_state}   set variable  ${one_ru_info["operational_state"]}
    [Return]   ${operational_state}


Reset VDU By REST
    [Arguments]  ${need_check_on_air}=${False}
    [Documentation]   Reset VDU By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Reset VDU By REST |
    ...
    log to console  Reset VDU By REST...
    ${out}   vdu.reset_vdu
    ${error_msg}   set variable  ${out["error_message"]}
    should contain  ${error_msg}   No error

    ${out}   Reset VDU Status Should Be Successful   operation_id=${out["id"]}
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  600s   30s   OAM Precondition Cell Should Be Onair

Reset VDU Status Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Reset VDU Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Reset VDU Status Should Be Successful | operation_id=<my_operation_id> |
    ...
    ${out}   Wait Until Keyword Succeeds  60   3   _Reset VDU Status Should Be Expected   operation_id=${operation_id}    expected_status=ongoing
    [Return]  ${out}


_Reset VDU Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_reset_vdu_operation_status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

