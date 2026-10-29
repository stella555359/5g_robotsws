*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_oam_cm.robot



*** Variables ***



*** Keywords ***

VDU Online Change Parameters
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${activate}=${True}   ${wait_vdu_up}=${False}  ${vdu_index}=0
    [Documentation]   VDU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
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
    ...  | ${conf} |  Get VDU Conf From SCF |
    ...  | ${bts_id} | set variable | ${conf["mrbts_id"]} |
    ...  | ${para_list} |  Create List | icmpResponseEnabled | icmpResponseEnabled |
    ...  | ${value_list} |  Create List | true | true |
    ...  | ${mo_list} |  Create List | MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1 | MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1 |
    ...  | ${ret} | VDU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} | wait_vdu_up=${True} |
    ...  | Log To Console | do somethng here... |
    ...  | VDU Online Restore Parameters | ${ret} |
    ...
    ...  | ${bts_id} | Get MRBTS Id From vDU SCF |
    ...  | ${para_list}  | Create List  | staticRoutes/0/destIpAddr |
    ...  | ${value_list} |  Create List |  1.1.1.1 |
    ...  | ${mo_list}    | Create List  |  MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1 |
    ...  | ${ret}  | VDU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Log To Console | do somethng here... |
    ...  | VDU Online Restore Parameters | ${ret} |
    ...
    log to console    VDU Online Change Parameters
    ${origin_para_value_dict}    Get VDU Parameter Value Online For Multiple MO
      ...   para_list=${para_list}   mo_list=${mo_list}  vdu_index=${vdu_index}
    ${updated_para_value_dict}    _Convert Updating Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}
    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}"  ${False}  ${True}
    vDU Rest Login    vdu_index=${vdu_index}
    ${updated_paras_list}   Generate Delta Parameters For Multiple MO   updated_para_value_dict=${updated_para_value_dict}

    run keyword if     "${need_update}"== "${True}"    VDU Online Change Parameters By Delta Plan REST
     ...   updated_paras_list=${updated_paras_list}   activate=${activate}   wait_vdu_up=${wait_vdu_up}

    ${ret_dict}   Create Dictionary   need_update=${need_update}
      ...   origin_para_value_dict=${origin_para_value_dict}
      ...   updated_para_value_dict=${updated_para_value_dict}

    [Return]       ${ret_dict}


VDU Online Restore Parameters
    [Arguments]  ${online_change_parameters_dict}  ${wait_vdu_up}=${False}
    [Documentation]   VDU Online Restore Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | online_change_parameters_dict  | yes | the value retured from VDU Online Change Parameters, please see example |
    ...   | wait_vdu_up    | no | the values of parameters list, must be one-to-one match between the value_list and the para_list |
    ...
    ...   *RETURN VALUE*
    ...   None
    ...
    ...   Example
    ...  | ${conf} |  Get VDU Conf From SCF |
    ...  | ${bts_id} | set variable | ${conf["mrbts_id"]} |
    ...  | ${para_list} |  Create List | icmpResponseEnabled | icmpResponseEnabled |
    ...  | ${value_list} |  Create List | true | true |
    ...  | ${mo_list} |  Create List | MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1 | MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1 |
    ...  | ${ret} | VDU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} | wait_vdu_up=${True} |
    ...  | Log To Console | do somethng here... |
    ...  | VDU Online Restore Parameters | online_change_parameters_dict=${ret} |
    ...
    Log To Console   VDU Online Restore Parameters
    VDU Rest Login
    ${recovery}   Set Variable       ${online_change_parameters_dict["need_update"]}
    ${origin_confg}   Set Variable   ${online_change_parameters_dict["origin_para_value_dict"]}
    ${delta_para_list}  Run Keyword If  "${recovery}"=="${True}"   Generate Delta Parameters For Multiple MO   ${origin_confg}
    Run Keyword If  "${recovery}"=="${True}"   VDU Online Change Parameters By Delta Plan REST   updated_paras_list=${delta_para_list}
    ...   wait_vdu_up=${wait_vdu_up}


Get VDU Parameter Value Online For Multiple MO
    [Arguments]   ${para_list}    ${mo_list}    ${vdu_index}=0
    [Documentation]   Get VDU Parameter Value Online For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2022.11.1 ,chris.l.cao@nokia-sbell.com, support multiple MOs
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo_list    | yes | the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   dictionary like,
    ...  {
    ...   'MRBTS-1234': {'btsName': '5gvDU-108201'}
    ...   'MRBTS-1234/MNL-1/AMGR-1/LUAC-1': {'btsAccountLockoutDuration': '0'}
    ...  }
    ...
    ...   Example
    ...  | ${para_list} | Create List | btsName | btsAccountLockoutDuration |
    ...  | ${mo_list} | Create List | MRBTS-1234 | MRBTS-1234/MNL-1/AMGR-1/LUAC-1 |
    ...  | ${para_value_dict} | Get VDU Parameter Value Online For Multiple MO | para_list=${para_list} | mo_list=${mo_list} |
    ...
    ${origin_para_value_dict}   Create Dictionary
    vDU Rest Login    vdu_index=${vdu_index}
    ${length}=   Get Length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
       ${mo_keys}   Evaluate  list(${origin_para_value_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${origin_para_value_dict["${mo}"]}
    ...  ELSE   Create Dictionary
        ${status}  ${value}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${mo}  ${para_list[${i}]}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${None}
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_current}
        Set to Dictionary  ${origin_para_value_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${origin_para_value_dict}


_Convert Updating Parameters From List To Dict For Multiple MO
    [Arguments]   ${para_list}   ${value_list}  ${mo_list}
    [Documentation]   Convert Updating Parameters From List To Dict For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | value_list   | yes | the values of parameters list, must be one-to-one match between the parameter value and the parameter name|
    ...   | mo_list     | yes | mo list |
    ...
    ...   *RETURN VALUE*
    ...  dictionray of MO
    ...
    ...   Example
    ...  | ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict | para_list=${para_list} | value_list=${value_list} |
    ...
    ${ret_dict}    Create Dictionary
    ${length}=   Get Length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${mo}  Set Variable   ${mo_list[${i}]}
        ${mo_keys}   Evaluate  list(${ret_dict})
        ${mo_dict}   Run Keyword If   "${mo}" in ${mo_keys}  Set Variable  ${ret_dict["${mo}"]}
    ...  ELSE   Create Dictionary
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_list[${i}]}
        Set to Dictionary  ${ret_dict}  ${mo}   ${mo_dict}
    END

    [Return]  ${ret_dict}


Generate Delta Parameters For Multiple MO
    [Arguments]   ${updated_para_value_dict}
    [Documentation]   Generate Delta Parameters For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | updated_paras_dict    | yes | the names of parameters list |
    ...
    ...   *RETURN VALUE*
    ...  dictionray of MO, which can be used by 'VDU Online Change Parameters By Delta Plan REST'
    ...
    ...  | ${para_value_dict} |  Create Dictionary | icmpResponseEnabled=true | icmpDscp=20 |
    ...  | ${updated_para_value_dict} | Create Dictionary |  MRBTS-1234/TNLSVC-1/TNL-1/IPNO-1=${para_value_dict} |
    ...  | ${updated_paras_list} | Generate Delta Parameters For Multiple MO | updated_para_value_dict=${updated_para_value_dict} |
    ...  | VDU Online Change Parameters By Delta Plan REST | updated_paras_list=${updated_paras_list} | wait_vdu_up=${True} |
    ...
    ...  | ${para_value_dict1} |  Create Dictionary | icmpResponseEnabled=false | icmpDscp=32 |
    ...  | ${para_value_dict2} |  Create Dictionary | icmpResponseEnabled=true | icmpDscp=40 |
    ...  | ${mo1} | Set Variable | MRBTS-1234/TNLSVC-1/TNL-1/IPNO-1 |
    ...  | ${mo2} | Set Variable | MRBTS-1234/TNLSVC-1/TNL-2/IPNO-1 |
    ...  | ${updated_para_value_dict} | Create Dictionary |  ${mo1}=${para_value_dict1} | ${mo2}=${para_value_dict2} |
    ...  | ${updated_paras_list} | Generate Delta Parameters For Multiple MO | updated_para_value_dict=${updated_para_value_dict} |
    ...  | VDU Online Change Parameters By Delta Plan REST | updated_paras_list=${updated_paras_list} |
    ...
    ${ret_list}    Create List

    ${mo_keys}   Evaluate  list(${updated_para_value_dict})
    FOR    ${mo}    IN     @{mo_keys}
        ${para_value_info}  Set Variable   ${updated_para_value_dict["${mo}"]}
        ${one_mo_to_be_updated}   Copy Dictionary   ${para_value_info}
        Set To Dictionary   ${one_mo_to_be_updated}   mo_dn      ${mo}
        Set To Dictionary   ${one_mo_to_be_updated}   operation  replace
        ${list_len}   Get Length   ${ret_list}
        Append To List   ${ret_list}   ${one_mo_to_be_updated}
    END
    [Return]  ${ret_list}


Get BTS ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]  Get BTS ID From vDU SCF
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | scf_path | Yes | scf file with absolute path, it's vDU scf file. |
    ...   *Return*
    ...   list value, contains [<mrbts_id>, <nrbts_id>, <nrdu_id>]
    ...   *Example*
    ...   | ${mrbts_id} | ${nrbts_id} | ${nrdu_id} | Get BTS ID From vDU SCF | scf_path=/tmp/a.scf |
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
    ${scf_path}    Get VDU SCF From Current Plan     gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${distname}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
    scf.load_scf  file_path=${scf_path}
    ${cellTechnology}   scf.get_all_values_from_scf   dist_name=${distname}  p_name=cellTechnology
    [Return]   ${cellTechnology[0]}


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
	...     "${templateType}" == "OAM"	oamext
	...	    "${templateType}" == "5GControlPlane"	cp
	...	    "${templateType}" == "5GUserPlane"	l2nrt
    ${inst_tnl}=   Get vDU Instance TNL ID   scf_path=${scf_path}   podname=${pod_name}
    ${inst_dist}  Replace String With Regexp   ${conf_dist}   .*  TNL-\\d+  .*  TNL-${inst_tnl}
    [Return]   ${inst_dist}


Get Running EQM APEQM RMOD ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get RU ID and also EQM/APEQM ID from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...  Change History
    ...  2022.1.1  chris.l.cao@nokia-sbell.com, change regexp
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path         | Yes | full path and file name  |
    ...
    ...   *RETURN VALUE*
    ...    EQM_ID, APEQM_ID, RMOD_ID
    ...
    ...   Example
    ...   |  ${eqm_id} |  ${apeqm_id} |  ${rmod_id} | Get Running EQM APEQM RMOD ID From vDU SCF | ${scf_file_with_fullpath} |

    ${scf_content}   OperatingSystem.Get File      ${scf_path}

    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/EQM_R-(\\d+)/APEQM_R-(\\d+)/RMOD_R-(\\d+)"   1  2  3  4
    ${eqm_id}     Set Variable  ${result[0][1]}
    ${apeqm_id}   Set Variable  ${result[0][2]}
    ${rmod_id}      Set Variable  ${result[0][3]}

#    ${result}        Get Regexp Matches            ${scf_content}    /EQM_\\S{3}/APEQM_R-\\d+
#    ${EQM_ID}        Remove String Using Regexp    ${result[0]}      /EQM_      /APEQM_R-\\d+
#
#    ${result}        Get Regexp Matches            ${scf_content}    /APEQM_\\S{4}/RMOD_R-\\d+
#    ${APEQM_ID}      Remove String Using Regexp    ${result[0]}      /APEQM_      /RMOD_R-\\d+
#
#    ${result}        Get Regexp Matches            ${scf_content}    EQM_R-\\d+/APEQM_R-\\d+/RMOD_\\S{3}
#    ${RU_ID}         Remove String Using Regexp    ${result[0]}      EQM_R-\\d+/APEQM_R-\\d+/RMOD_

    [Return]    ${eqm_id}    ${apeqm_id}    ${rmod_id}


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
    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}    Get Running EQM APEQM RMOD ID From vDU SCF    ${scf_file_with_fullpath}

    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_R-${EQM_ID}/APEQM_R-${APEQM_ID}/RMOD_R-${RU_ID}

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


Get vDU Instance TNL ID From SCF By VlanIfName
    [Arguments]  ${vlanIfName}=mcplane
    [Documentation]   Get vDU Instance TNL ID From SCF By VlanIfName
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vlanIfName | no | vlanIfName, e.g, mcplane, f1cplane, f1uplane, fhmplane, default is mcplane |
    ...
    ...    *RETURN VALUE*
    ...    Instance TNL id of given vlanIfName.
    ...
    ...    Example
    ...    | ${tnl_mcplane}  | Get vDU Instance TNL ID From SCF By VlanIfName |  vlanIfName=mcplane |
    ...    | ${tnl_f1cplane} | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=f1cplane |
    ...    | ${tnl_f1uplane} | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=f1uplane |
    ...    | ${tnl_fhmplane} | Get vDU Instance TNL ID From SCF By VlanIfName |  vlanIfName=fhmplane |
    ...
    ${tmp_scf_path}  Get VDU SCF From Current Plan
    ${distName}   Get MO DistName     scf_path=${tmp_scf_path}  vlanIfName=${vlanIfName}
    ${mrbts_id}  Get MRBTS Id From vDU SCF
    FOR  ${one}  IN  @{distName}
       ${matches}   Get Regexp Matches   ${one}  MRBTS-${mrbts_id}/TNLSVC-1/TNL-([5-9])/.+   1
       ${desired_TNL_number}  Set Variable If   ${matches}   ${matches[0]}
    END
    [Return]  ${desired_TNL_number}


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
    ${route_policy_name}  Set Variable If  'RTPOL_R' in '${dist}'  discoveredPolicyEntries  routingPolicies
    ${orderNumber1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
    ...  p_name=orderNumber  index=${index}
    Should Be True   '${orderNumber1}'=='${orderNumber}'
    ${routingTableDN1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
    ...  p_name=routingTableDN  index=${index}
    Should Be True   '${routingTableDN1}'=='${routingTableDN}'
    ${srcIpAddress1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
    ...   p_name=srcIpAddress  index=${index}
    ${srcIpAddress}  Remove String Using Regexp   ${srcIpAddress}   :0   :
    ${srcIpAddress1}  Remove String Using Regexp   ${srcIpAddress1}   :0   :
    Should Be True   '${srcIpAddress1}'=='${srcIpAddress}'
    ${srcIpPrefixLength1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
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

VDU Check Static Route Configured
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}=None  ${gateway}=None  ${preference}=None
    [Documentation]    Vdu Static Route check exists or not
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
    ...    | ${route_exists}  ${index} | VDU Check Static Route Configured | ${dist} |
    ...    | ${destIpAddr} | ${PrefixLength} | ${gateway} | ${preference} |
    ${uni_id}   Get Unique Id
    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_full_path}=  vdu.Get Current Plan File    ${scf_path}   vdu_SCF_${uni_id}.xml   include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${gateway_name}   set variable if  ':' in '''${destIpAddr}'''   gatewayIpv6Addr   gateway
    ${gateway_info}   scf.Get All Values From Scf   dist_name=${dist}   p_name=${gateway_name}
    ${gateway_len}   Get Length   ${gateway_info}
    ${rt_exist}=    Set Variable    ${False}
    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
    Log To Console   ${destIpAddr}
    ${index}   set variable  0
    FOR    ${i}    IN RANGE    0    ${gateway_len}
        ${res}  Run Keyword And Ignore Error   VDU Check Static Route Index configured
    ...  ${dist}  ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}  ${i}
        ${rt_exist}=   Set Variable If   '${res[0]}'=='PASS'   ${True}   ${False}
        ${index}=   Set Variable If   '${res[0]}'=='PASS'   ${i}   0
        exit for loop if  '${rt_exist}'=='${True}'
    END
    [Return]    ${rt_exist}    ${index}

VDU Check Static Route Index configured
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
    ...    | VDU Check Static Route Index configured | ${dist} |
    ...    | ${destIpAddr} | ${PrefixLength} | ${gateway} | ${preference} | 0 |
    ${destip_par}   set variable if  ':' in '''${destIpAddr}'''   destIpv6Addr   destIpAddr
    ${prefix_par}   set variable if  ':' in '''${destIpAddr}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
    ${gw_par}   set variable if  ':' in '''${destIpAddr}'''   gatewayIpv6Addr   gateway
    ${route_list_name}  Set Variable If  ':' in '${destIpAddr}'  staticIpv6Routes  staticRoutes

    ${destIpAddr1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_list_name}
    ...  p_name=${destip_par}  index=${index}
    ${destIpAddr1}   Replace String Using Regexp   ${destIpAddr1}   :0+  :
    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
    Should Be True   '${destIpAddr1}'=='${destIpAddr}'
    ${PrefixLength1}  Run Keyword If  "${PrefixLength}"!="None"  scf.Get_Value_From_Scf
    ...   dist_name=${dist}  list_name=${route_list_name}  p_name=${prefix_par}  index=${index}
    Run Keyword If  "${PrefixLength}"!="None"  Should Be True   '${PrefixLength1}'=='${PrefixLength}'
    ${gateway1}  Run Keyword If  "${gateway}"!="None"  scf.Get_Value_From_Scf
    ...   dist_name=${dist}  list_name=${route_list_name}  p_name=${gw_par}  index=${index}
    ${gateway1}   Replace String Using Regexp   ${gateway1}   :0+  :
    ${gateway}   Replace String Using Regexp   ${gateway}   :0+  :
    Run Keyword If  "${gateway}"!="None"  Should Be True   '${gateway1}'=='${gateway}'
#    ${preference1}  Run Keyword If  "${preference}"!="None"  scf.Get_Value_From_Scf
#    ...  dist_name=${dist}  list_name=${route_list_name}  p_name=preference  index=${index}
#    Run Keyword If  "${preference}"!="None"  Should Be True   '${preference1}'=='${preference}'

Vdu Add Route
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8   ${wait_vdu_up}=False
    [Documentation]    Add static route for vdu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2023-04-25 | hongping.rao | update for static route configuration |

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
    ${route_exists}   ${index}   VDU Check Static Route Configured
    ...  ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}
    ${res}  Run Keyword If  "${route_exists}"=="${True}"   create list  ${dist}  ${route_list_name}/${index}
    Return From Keyword If  "${route_exists}"=="${True}"    ${res}

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
    ${rt_object_exist}  scf.is_object_in_scf  dist_name=${dist}
    Run Keyword If  ${rt_object_exist}!=${True}   Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${prefix}  mo_name=${rest}
    ${paras_list}    Create Dictionary   /${route_list_name}=${EMPTY}
    Run Keyword If   ${length}==0  Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}
    ...  updated_paras_dict=${paras_list}   operation=add
    Sleep  2sec

    ${paras}=   Create Dictionary    /${route_list_name}/${length}=${EMPTY}
    ...   ${route_list_name}/${length}/${route_gateway_name}=${gateway}
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

Vdu Delete Route
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8   ${wait_vdu_up}=False
    [Documentation]    Delete static route for vdu
    ...    *AUTHOR* xiaqing.chen@nokia-sbell.com
    ...    Delete static route for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | distname to delete static route |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength   | yes | PrefixLength for static route |
    ...    | gateway   | yes | gateway for static route |
    ...    | preference   | no | preference for static route, default is 8 |
    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route deleted |

    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vDU Rest Login |
    ...    | ${dist} | Set Variable | MRBTS-10717/TNLSVC-1/TNL-1/IPNO-1/IPRT-3 |
    ...    | Vdu Delete Route | ${dist} | destIpAddr=1.1.1.1 |  PrefixLength=24 | gateway=1.1.1.2 |
    ...    | vDU Rest Logout |
    ...
    ${route_list_name}  Set Variable If  ':' in '''${destIpAddr}'''  staticIpv6Routes  staticRoutes
    ${route_exists}   ${index}   VDU Check Static Route Configured
    ...  ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}
    ${item_list_to_remove_tmp}  Run Keyword If  "${route_exists}"=="${True}"  create list  ${dist}  ${route_list_name}/${index}
    ${item_list_to_remove}  Run Keyword If  "${route_exists}"=="${True}"  create list  ${item_list_to_remove_tmp}
    Run Keyword If  "${route_exists}"=="${True}"  Delta Remove Items  ${item_list_to_remove}  ${wait_vdu_up}

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
    ${item_length}     get length    ${item_list_to_remove}
    Return From Keyword If   ${item_length}==0
    VDU Rest Login
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=remove_dist_ta
    ${mo_to_remove}  Create List
    FOR  ${item}  IN  @{item_list_to_remove}
       ${prefix}   ${rest}   Split String From Right   ${item[1]}   /   1
        ${prefix1}   ${rest1}   Split String From Right   ${item[0]}   -   1
        Run Keyword If  ${rest}==0 and ${rest1}>1  Append To List    ${mo_to_remove}   ${item[0]}
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
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2023-04-26 | hongping.rao | update for rt pol delta configuration |
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
    ${pol_object_exist}  scf.is_object_in_scf  dist_name=${dist}
    Run Keyword If  ${pol_object_exist}!=${True}  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=${dist}  mo_name=${rest}

    ${paras}=   Create Dictionary   /routingPolicies/${length}=${EMPTY}
    ...   routingPolicies/${length}/orderNumber=${orderNumber}
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

Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]   run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}   gnb_index=${vdu_index}
    ...   alias=${alias}
    [Documentation]  Get VDU Cell Number From SCF
    ...   *Author*: chris.l.cao@nokia-sbell.com
    ...   *History Change*
    ...   | date | who | what and how |
    ...   | 2022-4-6 | hongysun | update documentation |
    ...   | 2022-11-10 | r3li | fix error that call keyword after reinstall |
    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
    ...   *Arguments Description*
    ...   | Input Parameters | Man. | Description |
    ...   | vdu_index | No | vdu index in init.py file, default is 0 |
    ...   | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
    ...   *Return*
    ...   Cell number from test line configuration
    ...   *Example*
    ...   | ${cell_number} | Get VDU Cell Number From TestLine |
    ${r}  ${alias}   Run Keyword And Ignore Error   vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ${alias}   Run Keyword If   '${r}'=='FAIL'  vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    ...   password=nemuuser   ELSE   Set Variable   ${alias}
    ${tmpid1}   get unique id  precise=LOW  prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}  Get A Directory  ${tmpid1}
    ${tmp_scf_file}  vdu.get_current_plan_file  local_dir_path=${tmp_scf_path}  filename=scf.xml  include_runtime_data=${False}
    ...  vdu_connection=${alias}
    ${scf_content}   OperatingSystem.Get File   ${tmp_scf_file}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}  Set Variable    ${result.__len__()}

    [Return]   ${cell_number}


Download vDU PDL Validation Plugin From WFT
    [Arguments]    ${build_number}=None   ${vdu_index}=0    ${package_name}=${EMPTY}
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
    ${build_number}    Run Keyword If    '${build_number}'=='None'  Get Current vDU Version
    ...   ELSE   Set Variable   ${build_number}
    ${alias}  get unique id
    Connect To UTE Locally    alias=${alias}
    ${dir_name}   Get Unique ID   prefix=tmp_   precise=LOW
    ${tmp_dir}  Get A Directory   ${dir_name}  alias=${alias}
    ${package_name}   Get Package Prefix From Global Variables File   ${build_number}
    ${pdl_validation_file_name}   set variable   ${package_name}_${build_number}_pdl_validation_service_plugin.zip
    ${num_prefix}   Get Substring   ${package_name}   ${-2}
    ${r}  ${re}   Run Keyword And Ignore Error   Evaluate    int(${num_prefix})
    ${url}    Set Variable If  '${r}'=='PASS'   ${PACKAGE_LINK}/${package_name}/${package_name}_${build_number}/${pdl_validation_file_name}
    ...   ${PACKAGE_LINK}/${build_number}/${pdl_validation_file_name}
    ${out}   issh.Execute   command=cd ${tmp_dir}   alias=${alias}
    ${out}   issh.Execute   command=wget ${url}    alias=${alias}
    ${result}  issh.Execute  command=ls -al ${tmp_dir}/${package_name}_${build_number}_pdl_validation_service_plugin.zip  alias=${alias}
    should not be empty    ${result}
    ${package_local_path}   OperatingSystem.Join Path  ${tmp_dir}  ${package_name}_${build_number}_pdl_validation_service_plugin.zip
    log to console  ${package_local_path}
    [Return]  ${package_local_path}



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
    Should Be True   "${cellTechnology}"=="${expected_celltechnology}"
        ...    cellTechnology should be ${expected_celltechnology}, but real cellTechnology is ${cellTechnology}!



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
    ${file_path}   Get VDU SCF From Current Plan   vdu_index=${vdu_index}
    scf.Load_Scf  file_path=${file_path}
    ${vdu_conf}  Get VDU Conf From SCF   scf_path=${file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf["nrbts_id"]}
    ${value}  scf.get_value_from_scf   dist_name=${nrbts_distname}   p_name=cPlaneDscp
    [Return]  ${value}


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
    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
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
    ${rtn}   Wait until keyword succeeds  900  30s
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
    [Arguments]     ${mo_dn}=${EMPTY}   ${updated_paras_list}=${EMPTY}   ${operation}=replace   ${activate}=${True}
    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   VDU Online Change Parameters By Delta Plan REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2.12.2021  chris.l.cao@nokia-sbell.com,  add this KW to shorten dryrun time
    ...  1.3.2021   rifeng@nokia-sbell.com, add argument wait_vdu_up to wait vdu onair for parameter need reset vdu
    ...  14.2.2022  chris@nokia-sbell.com, support multiple MO
    ...
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
    ...
    ...   | ${added_dict1} | Create Dictionary | btsName=btsName1 | mo_dn=MRBTS-123 | operation=replace |
    ...   | ${added_dict2} | Create Dictionary | ipNodeStatisticsInterval=30min | mo_dn=MRBTS-123/TNLSVC-1/PMTNLINT-1 | operation=replace |
    ...   | ${mo_dict_list} | Create List | ${added_dict1} | ${added_dict2} |
    ...   | VDU Online Change Parameters By Delta Plan REST | updated_paras_list=${mo_dict_list} | activate=${True} |
    ...   | VDU Rest Logout |
    ...
    ...   Without activate it:
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
    ...
    ${timeout}   convert to integer  ${timeout}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${out}  Run Keyword If  "${mo_dn}"!="${EMPTY}"
        ...   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}
        ...   ELSE   _VDU Online Change Parameters By Delta Plan REST Multiple MO   plan_id=${planid}   updated_paras_list=${updated_paras_list}

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}

    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST  plan_id=${plan_id}   force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    wait_vdu_up=${wait_vdu_up}


_VDU Online Change Parameters By Delta Plan REST Multiple MO
    [Arguments]  ${plan_id}   ${updated_paras_list}
    ${mo_number}  Get Length   ${updated_paras_list}
    FOR   ${one_mo_dict}   IN   @{updated_paras_list}
        ${updated_paras_dict}  Copy Dictionary  ${one_mo_dict}
        ${r}  ${operation}   Run Keyword And Ignore Error   Get From Dictionary  ${updated_paras_dict}   operation
        ${operation}  Set Variable If   "${r}"=="PASS"   ${operation}   replace
        Run Keyword If   "${r}"=="PASS"   Remove From Dictionary   ${updated_paras_dict}   operation

        ${mo_dn}  Get From Dictionary  ${updated_paras_dict}   mo_dn
        Remove From Dictionary   ${updated_paras_dict}   mo_dn

        Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_dict}   operation=${operation}
    END


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
    [Arguments]  ${scf_file}=${EMPTY}    ${wait_vdu_up}=${False}
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

    should be true  ${scf_file.__len__()>0}

    VDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number

    ${plan_name}  Get Unique Id  prefix=full_commission_
    ${out}  Upload Plan And Validate And Activate  plan_file=${scf_file}   plan_name=${plan_name}  wait_vdu_up=${wait_vdu_up}
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
    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
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
    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60   ${vdu_connection}=${None}
    [Documentation]   Get VDU Parameter Value Online
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    If the searched parameter is under list/item, please set the para_name with something like 'list_name/item_number/parameter_name'
    ...  Change History
    ...  2023.7.1  chris.l.cao@nokia-sbell.com, add vdu_connection parameter
    ...
    ...    *Argument Description*
    ...    | Input Parameters    | Man. | Description |
    ...    | mo_dn     | yes | the distname of given parameter |
    ...    | para_name | yes | parameter name   |
    ...    | timeout   | no | timeout, default is 60, unit is second   |
    ...
    ...    *RETURN VALUE*
    ...    the parameter value getting from current plan
    ...
    ...   *Example*
    ...   | vdu rest login |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1/PINGRES-1 | para_name=packetsLost |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/IPRT-1 | para_name=staticRoutes/0/gateway |
    ...
    ...   | ${alias} | vdu rest login | gnb_index=0 | vdu_index=1 |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${alias} |
    ...
    ...   | ${alias} | vdu rest login | gnb_index=1 | vdu_index=1 |
    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${alias} |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}  vdu_connection=${vdu_connection}
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
#    [Teardown]  VDU Rest Logout    ${vdu_index}


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
#    [Teardown]    VDU REST LOGOUT    ${vdu_index}




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






Get MRBTS_ID And NE_ID Via VDU SCF
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Documentation]    Get MRBTS_ID And NE_ID Via VDU SCF
    ...  author:             huilin.xu@nokia-sbell.com
    ...  modified by:        <15-Oct-2020>, <huilxu>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   mrbts_id, the MRBTS ID like MRBTS_5230
    ...   ne_id, the NE ID like 5230
    ...
    ...    Example
    ...    |  ${mrbts_id}  |  ${ne_id}  |  Get MRBTS_ID And NE_ID Via VDU SCF  |
    ...
    vDU Rest Login  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
   # scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${vdu_conf}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${mrbts_id}  Set Variable   MRBTS-${vdu_conf["mrbts_id"]}
    ${ne_id}   Set Variable   ${vdu_conf["mrbts_id"]}

    [Return]   ${mrbts_id}  ${ne_id}

Vdu Delta Config Ipapp For Twamp
    [Arguments]  ${rate}=RATE_1
    [Teardown]   vDU Rest Logout
    [Documentation]   Vdu Delta Config Ipapp For Twamp
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | rate  | No | TWAMP Sender Message Rate, default is RATE_1 |
    ...
    ...    Example
    ...    | Vdu Delta Config Ipapp For Twamp |
    ...
    Run Keyword And Ignore Error  vDU Rest Logout
    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${uniq_id}  Get Unique Id
    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
    scf.load scf  ${scf_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf  dist_name=${ipapp_dist_name}
    ...  p_name=twampSenderMessageRate
    Return From Keyword If  """${res[1]}"""=="""${rate}"""
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
    ${operate}   Set Variable If  ${ipapp_exists}  replace  add
    ${para_dict}=  Create Dictionary
    ...  twampSenderMessageRate=${rate}
    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${ipapp_dist_name}
    ...  updated_paras_dict=${para_dict}
    ...  operation=${operate}
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
    Wait Until Keyword Succeeds    5min    20s
    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}

Vdu Delta Config Twamp
    [Arguments]  ${twampId}  ${destIpAddress}  ${sourceIpAddressDN}
    ...  ${administrativeState}=unlocked  ${enhancedMetric}=false  ${destPort}=5018   ${messageSize}=100
    ...  ${plrAlarmThreshold}=100  ${rttAlarmThreshold}=1000000  ${twampDscp}=34
    [Teardown]   vDU Rest Logout
    [Documentation]   Vdu Delta Config Twamp
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
    ...    | Vdu Delta Config Twamp | 1 | 10.110.76.61 | MRBTS-10837/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...
    Run Keyword And Ignore Error  vDU Rest Logout
    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${uniq_id}  Get Unique Id
    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
    scf.load scf  ${scf_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
    ${para_dict}=  Create Dictionary
    ...  twampSenderMessageRate=RATE_1
    Run Keyword If   "${ipapp_exists}"=="False"  Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${ipapp_dist_name}
    ...  updated_paras_dict=${para_dict}
    ...  operation=add
    ${distname}   Set Variable  ${ipapp_dist_name}/TWAMP-${twampId}
    ${exists}  scf.Is Object In Scf   ${distname}
    Run Keyword If   "${exists}"=="False"  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=${ipapp_dist_name}   mo_name=TWAMP-${twampId}
    ${operate}   Set Variable If  ${exists}  replace  add
    ${para_dict}=  Create Dictionary
    ...  administrativeState=${administrativeState}
    ...  destIpAddress=${destIpAddress}
    ...  sourceIpAddressDN=${sourceIpAddressDN}
    ...  enhancedMetric=${enhancedMetric}
    ...  destPort=${destPort}
    ...  messageSize=${messageSize}
    ...  plrAlarmThreshold=${plrAlarmThreshold}
    ...  rttAlarmThreshold=${rttAlarmThreshold}
    ...  twampDscp=${twampDscp}
    ...  twampId=${twampId}
    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${distname}
    ...  updated_paras_dict=${para_dict}
    ...  operation=${operate}
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
    Wait Until Keyword Succeeds    5min    20s
    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}

Vdu Delta Config Reflect
    [Arguments]  ${twampReflectId}  ${twampReflectorLocalIpAddressDN}  ${twampReflectorEnabled}=true
    ...  ${twampReflectorUdpEchoEnabled}=true  ${refWaitTimeout}=900
    [Teardown]   vDU Rest Logout
    [Documentation]   Vdu Delta Config Reflect
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
    ...    | Vdu Delta Config Reflect | 1 | MRBTS-10837/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...
    Run Keyword And Ignore Error  vDU Rest Logout
    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${uniq_id}  Get Unique Id
    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
    scf.load scf  ${scf_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
    ${para_dict}=  Create Dictionary
    ...  twampSenderMessageRate=RATE_1
    Run Keyword If   "${ipapp_exists}"=="False"  Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${ipapp_dist_name}
    ...  updated_paras_dict=${para_dict}
    ...  operation=add
    ${distname}   Set Variable  ${ipapp_dist_name}/TWAMPREFLECT-${twampReflectId}
    ${exists}  scf.Is Object In Scf   ${distname}
    Run Keyword If   "${exists}"=="False"  Add Delta Plan MO
    ...  plan_id=${plan_id}   parent_mo_dn=${ipapp_dist_name}   mo_name=TWAMPREFLECT-${twampReflectId}
    ${operate}   Set Variable If  ${exists}  replace  add
    ${para_dict}=  Create Dictionary
    ...  refWaitTimeout=${refWaitTimeout}
    ...  twampReflectorLocalIpAddressDN=${twampReflectorLocalIpAddressDN}
    ...  twampReflectorEnabled=${twampReflectorEnabled}
    ...  twampReflectorUdpEchoEnabled=${twampReflectorUdpEchoEnabled}
    ...  twampReflectId=${twampReflectId}
    Update Delta Plan Parameter
    ...  plan_id=${plan_id}
    ...  mo_dn=${distname}
    ...  updated_paras_dict=${para_dict}
    ...  operation=${operate}
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
    Wait Until Keyword Succeeds    5min    20s
    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}

Vdu Delta Delete All Twamp Configurations
    [Teardown]   vDU Rest Logout
    [Documentation]   Vdu Delta Delete All Twamp Configurations
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Vdu Delta Delete All Twamp Configurations |
    ...
    Run Keyword And Ignore Error   vDU Rest Logout
    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${uniq_id}  Get Unique Id
    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
    scf.load scf  ${scf_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
    Return From Keyword If   "${ipapp_exists}"=="False"
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
    Delete Delta Plan MO   plan_id=${plan_id}   mo_dn=${ipapp_dist_name}
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
    Wait Until Keyword Succeeds    5min    20s
    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}

Vdu Copy Cell
    [Arguments]     ${added_cell_id}    ${base_cell_id}   ${cell_dict}  ${channel_group}
    ...   ${gnb_index}=0  ${vdu_index}=0   ${wait_vdu_up}=False
    [Documentation]    Vdu Copy a cell from a existing cell
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <26-08-2022>, <lingtsun>, <initial created>
    ...    delete cell for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | added_cell_id   | yes | nrcell id of the added cell|
    ...    | base_cell_id    | yes | the reference cell id for copy |
    ...    | cell_dict       | yes | the infos of added cell, like {nrdu=1, lcrid=9}|
    ...    | channel_group   | yes | the channelgroup index list, like [[1,2,3,4],[1,2]]|
    ...    | vdu_index | No | the index of vdu, default value is 0 |
    ...    | gnb_index | No | the index of gnb, default value is 0 |
    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route deleted |
    ...   *Example*
    ...   | ${cell_dict} | create dictionary  | nrdu=1 | lcrId=9 | nrcellgrpId=9 |  physCellId=419 | rmod_id=9 |
    ...   | ${CHANNEL_list_1} | create list | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
    ...   | ${CHANNEL_list_2} | create list | 1 | 2 | 3  |4 |
    ...   | ${channel_group}  | create list | ${CHANNEL_list_1}  | ${CHANNEL_list_2}  |
    ...   | Vdu Copy Cell | added_cell_id=9 | base_cell_id=8 | cell_dict=${cell_dict} | channel_group=${channel_group} |
    ...   *Return*
    ...
    VDU Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${backup_scf_path}=  Get A Directory  BackupSCF
    ${vdu_scf}=  vdu.get_current_plan_file  local_dir_path=${backup_scf_path}  filename=base_scf.xml  include_runtime_data=${False}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${vdu_scf}
    ${DN}   set variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

    ${uni_id}   Get Unique Id
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_cell_${uni_id}
    ${plan_info_list}   vdu.get_tree_of_delta_plan    plan_id=${plan_id}
    ${nrcell_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=${DN}/NRCELL-${base_cell_id}   key=mo_uuid
    ${parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=${DN}/NRCELL-${base_cell_id}   key=parent_mo_uuid
    ${nrcellgrp_mo_uuid}    get_value_from_plan_tree_info
    ...   info_list=${plan_info_list}    dist_name=${DN}/NRCELLGRP-${base_cell_id}   key=mo_uuid

    log to console   1. Copy NRCELL MO from NRCELL-${base_cell_id}, update lcrID and physCellId
    Copy MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcell_mo_uuid}   new_instance_id=${added_cell_id}    include_children_objects=${True}
    ${updated_paras_dict}   create dictionary    lcrId=${cell_dict['lcrId']}     physCellId=${cell_dict['physCellId']}
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${DN}/NRCELL-${added_cell_id}
    ...   updated_paras_dict=${updated_paras_dict}

    log to console   2. Copy NRCELLGRP MO from NRCELLGRP-${base_cell_id}, update nrCellList
    Copy MO Into Delta Plan   plan_id=${plan_id}   source_plan_id=${plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcellgrp_mo_uuid}   new_instance_id=${added_cell_id}   include_children_objects=${True}
    ${updated_paras_dict}   create dictionary   /nrCellList/0=${added_cell_id}
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${DN}/NRCELLGRP-${cell_dict['nrcellgrpId']}
    ...   updated_paras_dict=${updated_paras_dict}

    log to console   3. Add refNrCellGroup into NRDU-${cell_dict['nrdu']}
    ${nrcellgrp_index}   get_add_cell_info  scf_path_org=${vdu_scf}  class_name=NRDU
    ...    list_p_name=refNrCellGroup
    ${updated_paras_dict}   create dictionary   /refNrCellGroup/${nrcellgrp_index}=${added_cell_id}
    Update Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${DN}/NRDU-${cell_dict['nrdu']}
    ...   updated_paras_dict=${updated_paras_dict}    operation=add

    log to console   4. Copy LCELNR MO from LCELNR-${base_cell_id}, update resourceDN for CHANNELGROUP
    ${lcelnr_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${base_cell_id}    key=mo_uuid
    ${lcelnr_parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${base_cell_id}   key=parent_mo_uuid
    Copy MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${plan_id}   parent_mo_uuid=${lcelnr_parent_mo_uuid}
    ...    mo_uuid=${lcelnr_mo_uuid}   new_instance_id=${cell_dict['lcrId']}    include_children_objects=${True}
    ${length}   get length   ${channel_group}
    FOR  ${index}    IN RANGE   0    ${length}
       ${group_id}    evaluate    ${index}+1
       _Update Channel resourceDN    channel_list=${channel_group}[${index}]    group_id=${group_id}
    ...   rmod_id=${cell_dict['rmod_id']}   MRBTS_ID=${mrbts_id}   plan_id=${plan_id}   lnrcell=${cell_dict['lcrId']}
    END
    Validate Delta Plan By REST   ${plan_id}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
    [Teardown]    VDU Logout


_Update Channel resourceDN
    [Arguments]     ${channel_list}   ${group_id}   ${rmod_id}   ${MRBTS_ID}   ${plan_id}  ${lnrcell}
    ${resourceDN}  Set Variable  MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_id}/PHYANT-1
    ${dict_resourceDN}=   Create Dictionary  resourceDN=${resourceDN}
    FOR  ${index}  IN  @{CHANNEL_list}
      ${MO_LCELNR_GP}  Set Variable  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lnrcell}/CHANNELGROUP-${group_id}/CHANNEL-${index}
      Update Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${MO_LCELNR_GP}  updated_paras_dict=${dict_resourceDN}
    END


Copy MO Into Delta Plan
    [Arguments]  ${plan_id}   ${source_plan_id}   ${parent_mo_uuid}   ${mo_uuid}  ${new_instance_id}
    ...   ${include_children_objects}  ${timeout}=30
    [Documentation]    Vdu Copy MO Into Delta Plan
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <26-08-2022>, <lingtsun>, <initial created>
    ...    delete cell for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id          | yes | plan id for delta plan         |
    ...    | source_plan_id   | yes | source plan id, could be delta plan or current plan |
    ...    | parent_mo_uuid   | yes | parent managed object id in source plan|
    ...    | mo_uuid          | yes | Unique managed object id which is being copied in source plan|
    ...    | new_instance_id  | yes | new instance id |
    ...    | include_children_objects | yes | is include children objects |
    ...    | timeout          | no  | Timeout for the operation, defaults to 30|
    ...   *Example*
    ...   | VDU Login |   gnb_index=${gnb_index} |  vdu_index=${vdu_index}
    ...   | ${uni_id} |   Get Unique Id  |
    ...   | Check Maximum Delta Plan Number And Delete One If Reach Maximum Number    |
    ...   | ${plan_id}|   ${action_id} |  Generate Delta Plan  | plan_name=add_cell_${uni_id} |
    ...   | ${plan_info_list} |  vdu.get_tree_of_delta_plan  |  plan_id=${plan_id}  |
    ...   | ${mo_uuid} | get_value_from_plan_tree_info  | info_list=${plan_info_list} | dist_name=XXXX | key=mo_uuid |
    ...   | ${parent-mo_uuid} | get_value_from_plan_tree_info | info_list=${plan_info_list} | dist_name=XXXX | key=parent_mo_uuid |
    ...   | Copy MO Into Delta Plan | plan_id=${plan_id} |  source_plan_id=${plan_id} |  parent_mo_uuid=${parent_mo_uuid}
    ...   | mo_uuid=${nrcell_mo_uuid} |  new_instance_id=9 |   include_children_objects=${True} |
    ...   *Return*
    ...
    ${rtf}    vdu.copy_managed_objects_into_delta_plan
    ...    plan_id=${plan_id}
    ...    source_plan_id=${plan_id}
    ...    parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${mo_uuid}
    ...    new_instance_id=${new_instance_id}
    ...    include_children_objects=${include_children_objects}
    ...    timeout= ${timeout}
    wait until keyword succeeds   10x   2s
    ...   _Copy MO Into Delta Plan Should Be Successful   plan_id=${plan_id}   action_id=${rtf['action_id']}   expected_status=success


_Copy MO Into Delta Plan Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${expected_status}
    ${out}   vdu.get_copy_managed_objects_into_delta_plan_status    plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Vdu Delete Cell
    [Arguments]     ${nrcell_id}   ${gnb_index}=0  ${vdu_index}=0   ${wait_vdu_up}=False
    [Documentation]    Vdu Delete Cell
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    delete cell for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | nrcell_id   | yes | nrcell id |
    ...    | vdu_index | No | the index of vdu, default value is 0 |
    ...    | gnb_index | No | the index of gnb, default value is 0 |
    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route deleted |
    ...
    VDU Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${backup_scf_path}=  Get A Directory  BackupSCF
    ${vdu_scf}=  vdu.get_current_plan_file  local_dir_path=${backup_scf_path}  filename=base_scf.xml  include_runtime_data=${False}
    ${uni_id}   Get Unique Id
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=delete_cell_${uni_id}
    ${nrcellid_dn}  ${lcellnr_dn}  ${nrcellgrp_dn}  ${nrdu_dn}  ${nrcellgrp_index}   get_delete_cell_mo  scf_path_org=${vdu_scf}
    ...   nrcell_id=${nrcell_id}
    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${nrcellid_dn}
    sleep  5s
    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${lcellnr_dn}
    sleep  5s
    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${nrcellgrp_dn}
    sleep  5s
    ${paras}=   Create Dictionary   /refNrCellGroup/${nrcellgrp_index}=${empty}
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${nrdu_dn}
    ...  updated_paras_dict=${paras}   operation=remove
    Validate Delta Plan By REST   ${plan_id}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
    [Teardown]    VDU Logout
