*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   cu_oam_cm.robot



*** Variables ***



*** Keywords ***
Get MRBTS Id From vCU SCF
    [Arguments]    ${gnb_index}=0
    [Documentation]   Get MRBTS Id From vCU SCF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb index | No | cu index, default is 0 |
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


VCU Online Change Parameters
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${gnb_index}=0
    [Documentation]  VCU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list  | yes | the names of parameters list |
    ...   | value_list | yes | the values of parameters list, must be one-to-one match between the value_list and the para_list |
    ...   | mo_list    | yes | the mo distname list，must be one-to-one match between the mo_list and the para_list |
    ...
    ...   *RETURN VALUE*
    ...   The flag 'need_update' of being changed: ${True} means confguration is changed by delta plan,
    ...                           otherwise confguration is NOT changed by delta plan
    ...   'origin_para_value_dict': orignal parameters/values in current plan,
    ...   'updated_para_value_dict': New parameters/values in current plan,
    ...
    ...      Above 3 members are constructed in a dictionary, its structure looks like:
    ...   {'need_update': ${need_update} ,
    ...   'origin_para_value_dict': ${origin_para_value_dict},
    ...   'updated_para_value_dict': ${updated_para_value_dict} }
    ...
    ...   | need_update             | ${True} means confguration is changed by delta plan, otherwise confguration is NOT changed by delta plan |
    ...   | origin_para_value_dict  | the original parameters and value in real BTS |
    ...   | updated_para_value_dict | the new parameters and value in real BTS |
    ...
    ...   Example
    ...  | ${bts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${para_list}  | Create List | ethernetLinkInterval | ipFilteringInterval | btsName |
    ...  | ${value_list} | Create List | 15min                | 15min               | new_bts_name |
    ...  | ${mo_list} |  Create List | MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1 | MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1 | MRBTS-${bts_id} |
    ...  | ${ret} | VCU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Log To Console | do somethng here... |
    ...  | VCU Online Restore Parameters | ${ret} |
    ...
    ...  | ${bts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${para_list}  | Create List  | staticRoutes/0/destIpAddr |
    ...  | ${value_list} |  Create List |  1.1.1.1 |
    ...  | ${mo_list}    | Create List  |  MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1 |
    ...  | ${ret}  | VCU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Log To Console | do somethng here... |
    ...  | VCU Online Restore Parameters | ${ret} |
    ...
    log to console    VCU Online Change Parameters for Multiple MOs With Checking before modification
    ${para_list}   _Add Backslash   ${para_list}
    ${origin_para_value_dict}   Get VCU Parameter Value Online For Multiple MO
      ...   para_list=${para_list}   mo_list=${mo_list}  gnb_index=${gnb_index}
    ${updated_para_value_dict}    _Convert Updating Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}
    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}"  ${False}  ${True}
    CU Rest Login    gnb_index=${gnb_index}
    ${updated_paras_list}   Generate Delta Parameters For Multiple MO For VCU   updated_para_value_dict=${updated_para_value_dict}

    run keyword if     "${need_update}"== "${True}"    VCU Online Change Parameters Without Checking   para_list=${updated_paras_list}

    ${ret_dict}   Create Dictionary   need_update=${need_update}
      ...   origin_para_value_dict=${origin_para_value_dict}
      ...   updated_para_value_dict=${updated_para_value_dict}

    [Return]       ${ret_dict}


VCU Online Restore Parameters
    [Arguments]  ${online_change_parameters_dict}
    [Documentation]   VCU Online Restore Parameters, usually it works with 'VCU Online Change Parameters'
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | online_change_parameters_dict  | yes | the value retured from 'VCU Online Change Parameters', please see example |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | ${bts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${para_list}  | Create List | ethernetLinkInterval | ipFilteringInterval | btsName |
    ...  | ${value_list} | Create List | 15min                 | 15min                 |  new_bts_name |
    ...  | ${mo_list} |  Create List | MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1 | MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1 | MRBTS-${bts_id} |
    ...  | ${ret} | VCU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Log To Console | do somethng here... |
    ...  | VCU Online Restore Parameters | ${ret} |
    ...
    Log To Console   VCU Online Restore Parameters
    CU Rest Login
    ${recovery}   Set Variable       ${online_change_parameters_dict["need_update"]}
    ${origin_confg}   Set Variable   ${online_change_parameters_dict["origin_para_value_dict"]}
    ${delta_para_list}  Run Keyword If  "${recovery}"=="${True}"   Generate Delta Parameters For Multiple MO For VCU   ${origin_confg}
    Run Keyword If  "${recovery}"=="${True}"   VCU Online Change Parameters Without Checking   para_list=${delta_para_list}


_Add Backslash
   [Arguments]  ${para_list}
   ${rtn}   Create List
   FOR  ${i}   IN  @{para_list}
       ${start_with_backslash}   Set Variable   ${i.startswith("/")}
       ${tmp}  Set Variable If  "${start_with_backslash}"=="${True}"   ${i}   /${i}
       Append To List   ${rtn}   ${tmp}
   END
   [Return]  ${rtn}


VCU Online Change Parameters Without Checking
    [Arguments]     ${para_list}     ${delta_plan_name}=delta_plan
    [Documentation]   VCU Online Change Parameters Without Checking, it supports to change multiple MOs' parameters.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list         | yes | para_list, please see example |
    ...   | delta_plan_name    | no | delta_plan_name |
    ...
    ...   *RETURN VALUE*
    ...  None
    ...
    ...  | ${mrbts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${mo1_dict1} |  Create Dictionary | parameter_path=/btsName | value=new_name | operation_type=replace |
    ...  | ${one_mo_para_list} | Create List | ${mo1_dict1} |
    ...  | ${mo1_dict} | Create Dictionary   | mo_dn=MRBTS-${mrbts_id} | one_mo_para_list=${one_mo_para_list} |
    ...  | ${final_para_list}   Create List   ${mo1_dict}
    ...  | VCU Online Change Parameters Without Checking | para_list=${final_para_list} |
    ...

    ...  | ${mo1_dict1} |  Create Dictionary |  parameter_path=/ethernetLinkInterval | value=30min | operation_type=replace |
    ...  | ${mo1_dict2} |  Create Dictionary |  parameter_path=/ipFilteringInterval  | value=30min | operation_type=replace |
    ...  | ${one_mo_para_list} | Create List |  ${mo1_dict1}  | ${mo1_dict2} |
    ...  | ${mo1_dict} | Create Dictionary |  mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/PMTNLINT-1 |  one_mo_para_list=${one_mo_para_list} |
    ...  | ${final_para_list} |  Create List |  ${mo1_dict} |
    ...  | VCU Online Change Parameters Without Checking | para_list=${final_para_list} |
    ...
    ...  | ${mrbts_id} |  Get MRBTS Id From vCU SCF |
    ...  | ${mo1_dict1} |  Create Dictionary | parameter_path=/ethernetLinkInterval | value=30min | operation_type=replace |
    ...  | ${mo1_dict2} |  Create Dictionary | parameter_path=/ipFilteringInterval  | value=30min | operation_type=replace |
    ...  | ${one_mo_para_list} |   Create List |  ${mo1_dict1} | ${mo1_dict2} |
    ...  | ${mo1_dict} | Create Dictionary  | mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/PMTNLINT-1 | one_mo_para_list=${one_mo_para_list} |
    ...  | ${mo2_dict1} |  Create Dictionary | parameter_path=/btsName |  value=new_name |  operation_type=replace |
    ...  | ${one_mo_para_list2} |   Create List  | ${mo2_dict1} |
    ...  | ${mo2_dict}         | Create Dictionary |  mo_dn=MRBTS-${mrbts_id} | one_mo_para_list=${one_mo_para_list2} |
    ...  | ${final_para_list} |   Create List | ${mo1_dict} |  ${mo2_dict} |
    ...  | VCU Online Change Parameters Without Checking | para_list=${final_para_list} |
    ...
    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
    Wait until keyword succeeds  3x  2s   _Generating Delta Plan Operation Should Be Successful    ${delta_res['action_id']}

    FOR  ${one_mo}  IN   @{para_list}
        _VCU Handle One Mo Parameters  one_mo=${one_mo}   delta_plan_id=${delta_plan_id}
    END

	${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
    Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}
    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
    Wait until keyword succeeds  800  30
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}   operation_id=${active_res['operation_id']}


Get VCU Parameter Value Online
   [Arguments]   ${dn}    ${parameter_path}    ${gnb_index}=${0}
    [Documentation]   Get VCU Parameter Value Online
    ...  author:             chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  dn             | Yes   |  Distname of parameter  |
    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
    ...                              |  complex parameter given the struncture like staticRoutes/1/destIpAddr
    ...
    ...    *RETURN VALUE*
    ...    parameter value, if it's simple or complex parameter, returns string type
    ...    if it's a simple list type parameter, it will return a list.
    ...
    ...    Example
    ...  | ${btsid} | Get MRBTS Id From vCU SCF |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}     |   parameter_path=btsName  |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}     |   parameter_path=/btsName  |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/NRBTS-5247/NRCELLGRP-0 | parameter_path=nrCellList |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/NRBTS-5247/NRCELLGRP-0 | parameter_path=/nrCellList |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/TNLSVC-1/TNL-3/IPNO-1/IPRT-1 | parameter_path=staticRoutes/1/destIpAddr |
    ...  | Get VCU Parameter Value Online | dn=MRBTS-${btsid}/TNLSVC-1/TNL-3/IPNO-1/IPRT-1 | parameter_path=/staticRoutes/1/destIpAddr |
    ...
    CU Rest Login    gnb_index=${gnb_index}
    ${dn}   set variable   ${dn.strip()}
    ${parameter_path}   set variable   ${parameter_path.strip()}
    @{para_list}  Split String  ${parameter_path}  /
    ${paras_info}=   cu.search_parameters_of_current_plan   parameter_name=${para_list[-1]}

    ${starts_with_root}   Set Variable   ${parameter_path.startswith("/")}
    ${para_struct_path}  Run Keyword If  "${starts_with_root}"=="${True}"   Set Variable   ${parameter_path.replace("/", "", 1)}
    ...    ELSE   Set Variable   ${parameter_path}

    ${value}   get_online_parameter_value  paras_info=${paras_info}  dn=${dn}  para_struct_path=${para_struct_path}
    [Return]  ${value}


Generate Delta Parameters For Multiple MO For VCU
    [Arguments]   ${updated_para_value_dict}
    [Documentation]   Generate Delta Parameters For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | updated_paras_dict    | yes | the names of parameters list |
    ...
    ...   *RETURN VALUE*
    ...  dictionray of MO, which can be used by 'VCU Online Change Parameters Without Checking'
    ...
    ...   Example
    ...  | ${bts_id} | Get MRBTS Id From vCU SCF |
    ...  | ${para_list}  | Create List | /ethernetLinkInterval | /ipFilteringInterval  |  /btsName |
    ...  | ${value_list} | Create List | 15min                 | 15min                 |  new_bts_name |
    ...  | ${mo_list} |  Create List | MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1 | MRBTS-${bts_id}/TNLSVC-1/PMTNLINT-1 | MRBTS-${bts_id} |
    ...  | ${ret} | VCU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Log To Console | do somethng here... |
    ...  | ${recovery} | Set Variable | ${ret["need_update"]} |
    ...  | ${origin_confg} | Set Variable | ${ret["origin_para_value_dict"]} |
    ...  | ${delta_para_list} | Run Keyword If | "${recovery}"=="${True}" | Generate Delta Parameters For Multiple MO For VCU | ${origin_confg} |
    ...  | Run Keyword If | "${recovery}"=="${True}" | VCU Online Change Parameters Without Checking | para_list=${delta_para_list} |
    ...
    ${ret_list}    Create List

    ${mo_keys}   Evaluate  list(${updated_para_value_dict})
    FOR    ${mo}    IN     @{mo_keys}
        ${one_mo_para_value_info}  Set Variable   ${updated_para_value_dict["${mo}"]}
        ${one_mo_para_dict}   _Handle One MO For Generate Delta Parameters For Multiple MO For VCU   mo_dn=${mo}
         ...   one_mo_para_value_info=${one_mo_para_value_info}
        Append To List   ${ret_list}   ${one_mo_para_dict}
    END

    [Return]  ${ret_list}


_Handle One MO For Generate Delta Parameters For Multiple MO For VCU
    [Arguments]  ${mo_dn}   ${one_mo_para_value_info}
    ${one_mo_para_list}   Create List
    ${para_keys}   Evaluate  list(${one_mo_para_value_info})
    FOR   ${para}   IN   @{para_keys}
         ${tmp_dict}    Create Dictionary   parameter_path=${para}    value=${one_mo_para_value_info["${para}"]}   operation_type=replace
         Append To List   ${one_mo_para_list}   ${tmp_dict}
    END

    ${one_mo_ret_dict}   Create Dictionary   mo_dn=${mo_dn}  one_mo_para_list=${one_mo_para_list}
    [Return]  ${one_mo_ret_dict}


Get VCU Parameter Value Online For Multiple MO
    [Arguments]   ${para_list}    ${mo_list}    ${gnb_index}=0
    [Documentation]   Get VCU Parameter Value Online For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2022.11.1 ,chris.l.cao@nokia-sbell.com, support multiple MOs
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo_list    | yes | the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...
    ...   Example
    ...   | ${para_list} | Create List | btsName | btsAccountLockoutDuration |
    ...   | ${mo_list} | Create List | MRBTS-1234 | MRBTS-1234/MNL-1/AMGR-1/LUAC-1 |
    ...  | ${para_value_dict} | Get VCU Parameter Value Online For Multiple MO | para_list=${para_list} | mo_list=${mo_list} |
    ...
    ${origin_para_value_dict}   Create Dictionary
    CU Rest Login    gnb_index=${gnb_index}
    ${length}=   Get Length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${mo_keys}   Evaluate  list(${origin_para_value_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${origin_para_value_dict["${mo}"]}
        ...  ELSE   Create Dictionary
        ${status}  ${value}   Run Keyword And Ignore Error   Get VCU Parameter Value Online
        ...  dn=${mo}  parameter_path=${para_list[${i}]}   gnb_index=${gnb_index}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${None}
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_current}
        Set to Dictionary  ${origin_para_value_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${origin_para_value_dict}



_VCU Online Change Single Mo Parameters Without Activate
    [Arguments]    ${delta_plan_id}   ${para_list}    ${mo_dn}
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | delta_plan_id    | yes | delta_plan_id |
    ...    | para_list        | yes | modify parameters list |
    ...    | mo_dn            | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  None
    ...
    ...    Example
    ...
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
    Wait until keyword succeeds  5x  5s
	...  _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}


_VCU Handle One Mo Parameters
    [Arguments]   ${one_mo}   ${delta_plan_id}
    ${mo_dn}   Set Variable   ${one_mo["mo_dn"]}
    ${one_mo_para_list}   Set Variable   ${one_mo["one_mo_para_list"]}
    _VCU Online Change Single Mo Parameters Without Activate   delta_plan_id=${delta_plan_id}   para_list=${one_mo_para_list}  mo_dn=${mo_dn}


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
    ${nrbts_distname}  Set Variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
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
    &{routeitem}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}  value=${EMPTY}

    &{gateway}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/${route_gateway_name}  value=${gateway}
    &{destIpAddr}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/${route_dstip_name}  value=${destIpAddr}
    &{destinationIpPrefixLength}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/${route_prefix_name}  value=${PrefixLength}
    &{preference}  Create Dictionary  operation_type=add
    ...  parameter_path=/${route_list_name}/${length}/preference  value=${preference}
    @{route_Para_list}=    Create List  ${routeitem}  ${gateway}   ${destIpAddr}
    ...  ${destinationIpPrefixLength}   ${preference}
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

Get VCU SCF From Current Plan
    [Arguments]    ${gnb_index}=0
    [Documentation]  Get VCU SCF From Current Plan
    ...  author: zhong.1.chen@nokia-sbell.com
    ...  Change History
    ...  6.12.2021   chris.l.cao@nokia-sbell.com,  make it work in real VCU
    ...  02.11.2022  huilin.xu@nokia-sbell.com,  add delay in CU rest login
    ...  07.1.2023   chris.l.cao@nokia-sbell.com, support multiple VCU
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${scf_full_path} | Get VCU SCF From Current Plan |
    ...
    ${file_name}   get unique id  prefix=scf_vcu_   suffix=.xml   precise=LOW
    ${tmp_scf_full_path}=  Get A File  temp_scf_vcu   ${file_name}
    ${alias}   CU Rest Login  delay=10s   gnb_index=${gnb_index}
    cu.get_current_plan_file   path=${tmp_scf_full_path}  timeout=60  include_runtime_data=${False}   connection=${alias}
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
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
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
    ${alias}  Get Unique Id
    ${alias}  CU Login  gnb_index=${gnb_index}   alias=${alias}
    ${where_to_store_plan_file}=    run keyword if   "${stored_path}"=="${EMPTY}"   set variable    ${plan_file_path}
    ...  ELSE    set variable    ${stored_path}
    cu.get_current_plan_file    path=${where_to_store_plan_file}   timeout=60  connection=${alias}
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
    [Arguments]   ${plan_id}  ${mo_dn}   ${alias}=default
    [Documentation]   _Get CU Specifical MO UUID
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _Get CU Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|

    @{name_list}=   split_string    ${mo_dn}   /
    set suite variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}   alias=${alias}
    END
    [Return]   ${mouuid}

_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}   ${alias}=default
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _Get CU Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|

    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}   connection=${alias}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
        run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
        ...  run keywords  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
        run keyword if  '${mo_info["parent_mo_uuid"]}'=='None' and '${mo_info["name"]}'=='${name}'  run keywords
        ...  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}


_Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}   ${alias}=default
    [Documentation]   _Generating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Generating Delta Plan Operation Should Be Successful | action_id=xxx |
	${res}   cu.get_action_state_of_generating_delta_plan   ${action_id}   connection=${alias}
	should be equal as strings  ${res['status']}  success

_Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}   ${alias}=default
    [Documentation]   CU Online Parameter Change By Rest
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	...   connection=${alias}
	should be equal as strings  ${res['status']}  success

_Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}   ${alias}=default
    [Documentation]   _Validating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}   connection=${alias}
	should be equal as strings  ${res['status']}  success


_Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}   ${alias}=default
    [Documentation]   _Activating Delta Plan Operation Should Be Successful
    ...   *Author*: luofei.tug@nokia-sbell.com
    ...   *Change History*
    ...    | Who | date | what or how |
    ...    | r3li | 2022-12-30 | Check successful status with delta plan missed |
    ...    *Parameter Description*
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    *Example*
    ...    | _Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
    CU Rest Login  delay=10s
    ${res}=   cu.get_delta_plan_list   connection=${alias}
    FOR   ${r}   IN   @{res}
        ${r_plan_id}   Set Variable   ${r}[plan_id]
        Should Not Be Equal As Strings   ${r_plan_id}   ${plan_id}
    END


CU Update Delta Plan Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${parameter_change_list}   ${alias}=default
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
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}   alias=${alias}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${parameter_change_list}   connection=${alias}
    run keyword and continue on failure  Wait until keyword succeeds  10x  5s
    ...  _Update Parameters Operation Should Be Successful	plan_id=${plan_id}  action_id=${update_res['action_id']}
    ...    alias=${alias}

CU Create Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${name}  ${instance_id}
	[Documentation]   CU Create Delta Plan Managed Object Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...  Change History
    ...  2023.1.11 ,chris.l.cao@nokia-sbell.com, remove 'run keyword and continue on failure'
    ...            for '_CU Create Delta Plan Managed Object Operation Should Be Successful'
    ...
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
#    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
#    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${create_res['action_id']}
     Wait until keyword succeeds  5x  5s
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
    [Arguments]   ${alias}=default
    [Documentation]   CU Generate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*  ${delta_plan_id}
    ...    Example
    ...    | ${delta_plan_id}= | CU Generate Delta Plan Should Be Successful  |
    ${delta_plan_list}     cu.get_delta_plan_list   connection=${alias}
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}   connection=${alias}
    sleep  3s
    ${delta_res}=  cu.generate_delta_plan  plan_name=delta_plan   connection=${alias}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
    run keyword and continue on failure   Wait until keyword succeeds  3x  2s
    ...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}   alias=${alias}
    [Return]   ${delta_plan_id}


CU Validate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}   ${alias}=default
    [Documentation]   CU Validate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Validate Delta Plan Should Be Successful  | plan_id=${delta_plan_id}  |
    ${validate_res}=   cu.validate_delta_plan   plan_id=${plan_id}    connection=${alias}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${plan_id}  action_id=${validate_res['action_id']}
    ...  alias=${alias}


CU Activate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}   ${alias}=default
    [Documentation]   CU Activate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...  Change History
    ...  2022.12.30 ,chris.l.cao@nokia-sbell.com, change interval from 5s to 30s
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Activate Delta Plan Should Be Successful | plan_id=${delta_plan_id}  |
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}   connection=${alias}
#    run keyword and continue on failure   Wait until keyword succeeds  16x   5
#    ...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}   operation_id=${active_res['operation_id']}

    Wait until keyword succeeds  800   30
    ...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}   operation_id=${active_res['operation_id']}
    ...  alias=${alias}


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
    ...  Change History
    ...  2023.6.10 ,chris.l.cao@nokia-sbell.com, change gnbu_index to gnb_index
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
    ${file_path}   Get VCU SCF From Current Plan   gnb_index=${gnb_index}
    scf.Load_Scf  file_path=${file_path}
    ${vcu_conf}  Get VCU Conf From SCF   scf_path=${file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${vcu_conf["mrbts_id"]}/NRBTS-${vcu_conf["nrbts_id"]}
    ${value}  scf.get_value_from_scf   dist_name=${nrbts_distname}   p_name=cPlaneDscp
    [Return]  ${value}


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

Vcu Delta Delete All Twamp Configurations
    [Teardown]    CU Logout
    [Documentation]   Vcu Delta Delete All Twamp Configurations
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Vcu Delta Delete All Twamp Configurations |
    ...
    Run Keyword And Ignore Error  CU Logout
    Wait Until Keyword Succeeds  5min   10s    CU Login
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    scf    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_full_path}   templateType=TWAMP
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Return From Keyword If   "${ipapp_exists}"=="False"
    ${plan_id}=  CU Generate Delta Plan Should Be Successful
    CU Delete Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${ipapp_dist_name}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    scf    vcu_delta_delete_twamp_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${plan_id}
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}
	Wait Until Keyword Succeeds  5min  20s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}
	...  operation_id=${active_res['operation_id']}

Vcu Delta Config Ipapp For Twamp
    [Arguments]  ${rate}=RATE_1
    [Teardown]    CU Logout
    [Documentation]   Vcu Delta Config Ipapp For Twamp
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | rate  | No | TWAMP Sender Message Rate, default is RATE_1 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Vcu Delta Config Ipapp For Twamp |
    ...
    Run Keyword And Ignore Error  CU Logout
    Wait Until Keyword Succeeds  5min   10s    CU Login
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    scf    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_full_path}  templateType=TWAMP
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    ${prefix}   ${rest}   Split String From Right   ${ipapp_dist_name}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    ${res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf  dist_name=${ipapp_dist_name}
    ...  p_name=twampSenderMessageRate
    Return From Keyword If  """${res[1]}"""=="""${rate}"""
    ${plan_id}=  CU Generate Delta Plan Should Be Successful
    Run Keyword If   "${ipapp_exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:IPAPP  instance_id=${index}
    &{rate_dict}  Create Dictionary  operation_type=add
    ...  parameter_path=/twampSenderMessageRate  value=${rate}
    @{Para_list}=    Create List  ${rate_dict}
    Log List  ${Para_list}
    Run Keyword If   "${rate}"!="RATE_1"   CU Update Delta Plan Should Be Successful
    ...  plan_id=${plan_id}  mo_dn=${ipapp_dist_name}  parameter_change_list=${Para_list}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_twamp_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${plan_id}
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}
	Wait Until Keyword Succeeds  5min  20s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}
	...  operation_id=${active_res['operation_id']}

Vcu Delta Config twamp
    [Arguments]  ${twampId}  ${destIpAddress}  ${sourceIpAddressDN}
    ...  ${administrativeState}=unlocked  ${enhancedMetric}=false  ${destPort}=5018   ${messageSize}=100
    ...  ${plrAlarmThreshold}=100  ${rttAlarmThreshold}=10000  ${twampDscp}=34
    [Teardown]   CU Logout
    [Documentation]   Vcu Delta Config twamp
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | twampId  | yes | twamp session id |
    ...    | destIpAddress  | yes | twamp dest ip |
    ...    | sourceIpAddressDN  | yes | twamp sourceIpAddressDN |
    ...    | administrativeState  | No | administrativeState, default is unlocked |
    ...    | enhancedMetric  | No | enhancedMetric, default is false |
    ...    | destPort  | No | destPort, default is 5018 |
    ...    | messageSize  | No | messageSize, default is 100 |
    ...    | plrAlarmThreshold  | No | plrAlarmThreshold, default is 10000 |
    ...    | rttAlarmThreshold  | No | rttAlarmThreshold, default is 1000000 |
    ...    | twampDscp  | No | twampDscp, default is 34 |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Vcu Delta Config twamp | 1 | 10.110.76.61 | MRBTS-10837/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...
    Run Keyword And Ignore Error  CU Logout
    Wait Until Keyword Succeeds  5min   10s    CU Login
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    scf    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_full_path}  templateType=TWAMP
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${plan_id}=  CU Generate Delta Plan Should Be Successful
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    ${prefix}   ${rest}   Split String From Right   ${ipapp_dist_name}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    Run Keyword If   "${ipapp_exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:IPAPP  instance_id=${index}
    &{rate}  Create Dictionary  operation_type=add
    ...  parameter_path=/twampSenderMessageRate  value=RATE_1
    @{Para_list}=    Create List  ${rate}
    Log List  ${Para_list}
    Run Keyword If   "${ipapp_exists}"=="False"  CU Update Delta Plan Should Be Successful
    ...  plan_id=${plan_id}  mo_dn=${ipapp_dist_name}  parameter_change_list=${Para_list}
    ${distname}   Set Variable  ${ipapp_dist_name}/TWAMP-${twampId}
    ${exists}  scf.Is Object In Scf   ${distname}
    ${prefix}   ${rest}   Split String From Right   ${distname}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    Run Keyword If   "${exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:TWAMP  instance_id=${index}
    ${operate}   Set Variable If  ${exists}  replace  add
    &{adminstate}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/administrativeState  value=${administrativeState}
    &{dstip}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/destIpAddress  value=${destIpAddress}
    &{dstport}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/destPort  value=${destPort}
    &{encmetric}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/enhancedMetric  value=${enhancedMetric}
    &{msgsize}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/messageSize  value=${messageSize}
    &{plrth}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/plrAlarmThreshold  value=${plrAlarmThreshold}
    &{rttth}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/rttAlarmThreshold  value=${rttAlarmThreshold}
    &{srcdn}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/sourceIpAddressDN  value=${sourceIpAddressDN}
    &{dscp}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/twampDscp  value=${twampDscp}
    &{id}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/twampId  value=${twampId}
    @{Para_list}=    Create List  ${adminstate}  ${dstip}  ${dstport}  ${encmetric}
    ...  ${msgsize}  ${plrth}  ${rttth}  ${srcdn}  ${dscp}  ${id}
    Log List  ${Para_list}
    CU Update Delta Plan Should Be Successful  plan_id=${plan_id}  mo_dn=${distname}
	...  parameter_change_list=${Para_list}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_twamp_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${plan_id}
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}
	Wait Until Keyword Succeeds  5min  20s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}
	...  operation_id=${active_res['operation_id']}

Vcu Delta Config Reflect
    [Arguments]  ${twampReflectId}  ${twampReflectorLocalIpAddressDN}  ${twampReflectorEnabled}=true
    ...  ${twampReflectorUdpEchoEnabled}=true  ${refWaitTimeout}=900
    [Teardown]   CU Logout
    [Documentation]   Vcu Delta Config Reflect
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | twampReflectId  | yes | twampReflect session id |
    ...    | twampReflectorLocalIpAddressDN  | yes | twampReflectorLocalIpAddressDN |
    ...    | twampReflectorEnabled  | No | twampReflectorEnabled, default is true |
    ...    | twampReflectorUdpEchoEnabled  | No | twampReflectorUdpEchoEnabled, default is true |
    ...    | refWaitTimeout  | No | refWaitTimeout, default is 900 |

    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Vcu Delta Config Reflect | 1 | MRBTS-10837/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...
    Run Keyword And Ignore Error  CU Logout
    Wait Until Keyword Succeeds  5min   10s    CU Login
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    scf    vcu_scf_${uni_id}.xml
    cu.Get Current Plan File   path=${scf_full_path}  timeout=60  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_full_path}  templateType=TWAMP
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_full_path}
    ${plan_id}=  CU Generate Delta Plan Should Be Successful
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    ${prefix}   ${rest}   Split String From Right   ${ipapp_dist_name}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    Run Keyword If   "${ipapp_exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:IPAPP  instance_id=${index}
    &{rate}  Create Dictionary  operation_type=add
    ...  parameter_path=/twampSenderMessageRate  value=RATE_1
    @{Para_list}=    Create List  ${rate}
    Log List  ${Para_list}
    Run Keyword If   "${ipapp_exists}"=="False"  CU Update Delta Plan Should Be Successful
    ...  plan_id=${plan_id}  mo_dn=${ipapp_dist_name}  parameter_change_list=${Para_list}
    ${distname}   Set Variable  ${ipapp_dist_name}/TWAMPREFLECT-${twampReflectId}
    ${exists}  scf.Is Object In Scf   ${distname}
    ${prefix}   ${rest}   Split String From Right   ${distname}   /   1
    ${prefix1}   ${index}   Split String From Right   ${rest}   -   1
    Run Keyword If   "${exists}"=="False"  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${plan_id}
    ...  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:TWAMPREFLECT  instance_id=${index}
    ${operate}   Set Variable If  ${exists}  replace  add
    &{ref_dn}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/twampReflectorLocalIpAddressDN  value=${twampReflectorLocalIpAddressDN}
    &{ref_enable}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/twampReflectorEnabled  value=${twampReflectorEnabled}
    &{ref_echo_enable}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/twampReflectorUdpEchoEnabled  value=${twampReflectorUdpEchoEnabled}
    &{ref_timeout}  Create Dictionary  operation_type=${operate}
    ...  parameter_path=/refWaitTimeout  value=${refWaitTimeout}
    @{Para_list}=    Create List  ${ref_dn}  ${ref_enable}  ${ref_echo_enable}  ${ref_timeout}
    Log List  ${Para_list}
    CU Update Delta Plan Should Be Successful  plan_id=${plan_id}  mo_dn=${distname}
	...  parameter_change_list=${Para_list}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_twamp_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${plan_id}
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}
	Wait Until Keyword Succeeds  5min  20s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}
	...  operation_id=${active_res['operation_id']}


Get VCU Cell Number From SCF
    [Arguments]   ${gnb_index}=${0}
    [Documentation]  Get VCU Cell Number From SCF
    ...   *Author*: rui.3.li@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-11-10 | r3li | new |
    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
    ...   *Return*
    ...   Cell number from test line configuration
    ...   *Example*
    ...   | ${cell_number} | Get VCU Cell Number From SCF |
    ${r}  ${alias}   Run Keyword And Ignore Error   CU Rest Login   gnb_index=${gnb_index}
    ${alias}   Run Keyword If   '${r}'=='FAIL'   CU Rest Login   gnb_index=${gnb_index}   is_default_password=${True}
    ...   ELSE   Set Variable   ${alias}
    ${tmpid1}   get unique id  precise=LOW  prefix=Get_VCU_Cell_Number_From_SCF
    ${tmp_scf_path}  Get A Directory  ${tmpid1}
    ${tmp_scf_path}   Set Variable    ${tmp_scf_path}/scf.xml
    ${tmp_scf_file}  cu.get_current_plan_file  path=${tmp_scf_path}   include_runtime_data=${False}   connection=${alias}
    ${scf_content}   OperatingSystem.Get File   ${tmp_scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}  Set Variable    ${result.__len__()}
    [Teardown]   CU Rest Logout   connection=${alias}   gnb_index=${gnb_index}
    [Return]   ${cell_number}


VCU Get Object Existence
    [Arguments]    ${mo_list}    ${gnb_index}=0
    [Documentation]   VCU Get Object Existence
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.1.111 ,chris.l.cao@nokia-sbell.com, initialization
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_list    | yes | the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    object existence dict
    ...
    ...   Example
    ...   | ${mo_list} | Create List | MRBTS-1234 | MRBTS-1234/MNL-1/AMGR-1/LUAC-1 |
    ...   | ${para_value_dict} | VCU Get Object Existence | para_list=${para_list} | mo_list=${mo_list} |
    ...
    ${object_existence_dict}   Create Dictionary
    ${scf_file_with_fullpath}   Get VCU SCF From Current Plan  gnb_index=${gnb_index}
    scf.load scf  ${scf_file_with_fullpath}

    ${length}   Get Length    ${mo_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${query_result}  scf.Is Object In Scf  ${mo}
        Set to Dictionary  ${object_existence_dict}  ${mo}   ${query_result}
    END
    [Return]  ${object_existence_dict}

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
    ${pol_object_exist}  scf.is_object_in_scf  dist_name=${dist}
    Run Keyword If  ${pol_object_exist}!=${True}  CU Create Delta Plan Managed Object Should Be Successful
    ...  plan_id=${delta_plan_id}  mo_dn=${prefix}
    ...  name=com.nokia.srbts.tnl:RTPOL  instance_id=${index}

    &{policy_list}  Create Dictionary   operation_type=add    parameter_path=/routingPolicies
    @{para_list}=    Create List  ${policy_list}
    Run Keyword If   ${length}==0  CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${dist}
    ...  parameter_change_list=${para_list}
    Sleep  2sec
	&{policyitem}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}  value=${EMPTY}

    &{ordern}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/orderNumber  value=${orderNumber}
    &{routedn}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/routingTableDN  value=${routingTableDN}
    &{srcip}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/srcIpAddress  value=${srcIpAddress}
    &{srciplength}  Create Dictionary  operation_type=add
    ...  parameter_path=/routingPolicies/${length}/srcIpPrefixLength  value=${srcIpPrefixLength}
    @{policy_para_list}=    Create List   ${policyitem}  ${ordern}   ${routedn}  ${srcip}  ${srciplength}
	CU Update Delta Plan Should Be Successful  plan_id=${delta_plan_id}  mo_dn=${dist}
	...  parameter_change_list=${policy_para_list}
    ${uni_id}   Get Unique Id
    ${scf_full_path}  Get A File    SCF    vcu_delta_add_rtpol_scf_${uni_id}.xml
    cu.Save Delta Plan File    ${delta_plan_id}   ${scf_full_path}
    CU Validate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    CU Activate Delta Plan Should Be Successful   plan_id=${delta_plan_id}
    [Return]   ${dist}  /routingPolicies/${length}
