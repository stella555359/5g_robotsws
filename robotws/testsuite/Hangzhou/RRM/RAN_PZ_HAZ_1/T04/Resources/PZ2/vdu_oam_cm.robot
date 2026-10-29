*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_oam_cm.robot


*** Keywords ***
VDU Online Change Parameters
    [Arguments]    ${para_list}   ${value_list}   ${mo_list}   ${activate}=${True}   ${wait_vdu_up}=${False}  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   VDU Online Change Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2023.12.8 ,chris.l.cao@nokia-sbell.com, 1.if value is not found in current plan, it will be treated as 'add' operation
    ...                                          2.if value is ${None}, it will be treated as 'remove' operation
    ...
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
    ...  Remove it when value is ${None}
    ...  | ${vdu_ETHIF_mo} |  Set Variable |  MRBTS-123/TNLSVC-1/TNL-3/ETHSVC-1/ETHIF-1 |
    ...  | ${para_list}  | Create List | enableShaping   | sirTotal | sbsTotal | shapingOverhead |
    ...  | ${value_list} | Create List | false           | ${None}  | ${None}  | ${None}         |
    ...  | ${mo_list}    | Create List | ${vdu_ETHIF_mo} | ${vdu_ETHIF_mo}     | ${vdu_ETHIF_mo} |  ${vdu_ETHIF_mo} |
    ...  | ${ret}        | VDU Online Change Parameters  | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Log To Console | do somethng here... |
    ...  | VDU Online Restore Parameters | ${ret} |
    ...
    ...  Add value for "<list name="acceptedClockClass"><p>6</p></list>"
    ...  | ${conf}      | Get VDU Conf From SCF |
    ...  | ${mo}        |  Set Variable   | MRBTS-${conf["mrbts_id"]}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1 |
    ...  | ${list_name} |   Set Variable  | acceptedClockClass |
    ...  | ${value}     |  Get VDU Parameter Value Online | mo_dn=${mo} | para_name=acceptedClockClass |
    ...  | ${para_list} |  Create List    | ${list_name}/${value.__len__()} |
    ...  | ${value_list} | Create List    | 7     |
    ...  | ${mo_list}    | Create List    | ${mo} |
    ...  | ${ret}        | VDU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} |
    ...  | Check Current Parameter Value As Expected | para_list=${para_list} | expected_value_list=${value_list} | mo_list=${mo_list} |
    ...  | #restore      |
    ...  | VDU Online Restore Parameters |  ${ret}|
    ...
    log to console    VDU Online Change Parameters...
    Log    ${gnb_index}
    ${origin_para_value_dict}    vdu_oam_cm.Get VDU Parameter Value Online For Multiple MO
      ...   para_list=${para_list}   mo_list=${mo_list}  vdu_index=${vdu_index}
    ${updated_para_value_dict}    vdu_oam_cm._Convert Updating Parameters From List To Dict For Multiple MO
      ...   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}
    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
    ${need_update}  Set Variable If  "${compare_result}"=="${True}"  ${False}  ${True}
    vDU Rest Login    vdu_index=${vdu_index}
    ${updated_paras_list}   ulti.Generate Delta Parameters For Multiple MO   updated_para_value_dict=${updated_para_value_dict}
      ...   origin_para_value_dict=${origin_para_value_dict}
    run keyword if     "${need_update}"== "${True}"    VDU Online Change Parameters By Delta Plan REST
     ...   updated_paras_list=${updated_paras_list}   activate=${activate}   wait_vdu_up=${wait_vdu_up}

    ${ret_dict}   Create Dictionary   need_update=${need_update}
      ...   origin_para_value_dict=${origin_para_value_dict}
      ...   updated_para_value_dict=${updated_para_value_dict}
    [Return]       ${ret_dict}


#VDU Online Restore Parameters
#    [Arguments]  ${online_change_parameters_dict}  ${wait_vdu_up}=${False}
#    [Documentation]   VDU Online Restore Parameters, it will not change parameters if its original value is same as new one, it supports multiple MO
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  2023.12.8 ,chris.l.cao@nokia-sbell.com, support 'add', 'remove' operation
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | online_change_parameters_dict  | yes | the value retured from VDU Online Change Parameters, please see example |
#    ...   | wait_vdu_up    | no | the values of parameters list, must be one-to-one match between the value_list and the para_list |
#    ...
#    ...   *RETURN VALUE*
#    ...   None
#    ...
#    ...   Example
#    ...  | ${conf} |  Get VDU Conf From SCF |
#    ...  | ${bts_id} | set variable | ${conf["mrbts_id"]} |
#    ...  | ${para_list} |  Create List | icmpResponseEnabled | icmpResponseEnabled |
#    ...  | ${value_list} |  Create List | true | true |
#    ...  | ${mo_list} |  Create List | MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPNO-1 | MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1 |
#    ...  | ${ret} | VDU Online Change Parameters | para_list=${para_list} | value_list=${value_list} | mo_list=${mo_list} | wait_vdu_up=${True} |
#    ...  | Log To Console | do somethng here... |
#    ...  | VDU Online Restore Parameters | online_change_parameters_dict=${ret} |
#    ...
#    Log To Console   VDU Online Restore Parameters...
#    VDU Rest Login
#    ${recovery}   Set Variable       ${online_change_parameters_dict["need_update"]}
#    ${origin_confg}   Set Variable   ${online_change_parameters_dict["origin_para_value_dict"]}
#    ${updated_dict}   Set Variable   ${online_change_parameters_dict["updated_para_value_dict"]}
#    ${delta_para_list}  Run Keyword If  "${recovery}"=="${True}"  Generate Delta Parameters For Multiple MO  updated_para_value_dict=${origin_confg}
#      ...   origin_para_value_dict=${updated_dict}
#    Run Keyword If  "${recovery}"=="${True}"   VDU Online Change Parameters By Delta Plan REST   updated_paras_list=${delta_para_list}
#    ...   wait_vdu_up=${wait_vdu_up}
#
#
Get VDU Parameter Value Online For Multiple MO
    [Arguments]   ${para_list}    ${mo_list}    ${vdu_index}=0
    [Documentation]   Get VDU Parameter Value Online For Multiple MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2022.11.1 ,chris.l.cao@nokia-sbell.com, support multiple MOs
    ...  2023.12.25 ,chris.l.cao@nokia-sbell.com, support list like <list name="acceptedClockClass"><p>6</p><p>7</p></list>
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
        ${para}  Set Variable   ${para_list[${i}]}
        @{tmp_para_list}  Split String  ${para}  /
        ${is_number}  ulti.is_numeric   ${tmp_para_list[-1]}
        ${para}  Set Variable If   "${is_number}"=="${True}"   ${tmp_para_list[0]}   ${para}

        ${status}  ${value}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${mo}  ${para}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${None}

        ${is_a_list}  is_list   ${value_current}
        ${r}   ${value_current}  Run Keyword And Ignore Error  Set Variable If  '${is_a_list}'=='${True}' and "${is_number}"=="${True}"
             ...   ${value_current[${tmp_para_list[-1]}]}   ${value_current}
        ${value_current}  Set Variable If  "${r}"=="PASS"  ${value_current}  ${None}

        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value_current}
        Set to Dictionary  ${origin_para_value_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${origin_para_value_dict}


_Convert Updating Parameters From List To Dict For Multiple MO
    [Arguments]   ${para_list}   ${value_list}  ${mo_list}  ${convert_empty_to_none}=${False}
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
        ${value}  Set Variable If  "${convert_empty_to_none}"=="${True}" and """${value_list[${i}]}"""=="""${EMPTY}"""  ${None}  ${value_list[${i}]}
        Set to Dictionary  ${mo_dict}   ${para_list[${i}]}   ${value}
        Set to Dictionary  ${ret_dict}  ${mo}   ${mo_dict}
    END
    [Return]  ${ret_dict}


#Get BTS ID From vDU SCF
#    [Arguments]  ${scf_path}
#    [Documentation]  Get BTS ID From vDU SCF
#    ...   *Author*: chris.l.cao@nokia-sbell.com
#    ...   *History Change*
#    ...   | date | who | what and how |
#    ...   | 2022-4-6 | hongysun | update documentation |
#    ...   *Arguments Description*
#    ...   | Input Parameters | Man. | Description |
#    ...   | scf_path | Yes | scf file with absolute path, it's vDU scf file. |
#    ...   *Return*
#    ...   list value, contains [<mrbts_id>, <nrbts_id>, <nrdu_id>]
#    ...   *Example*
#    ...   | ${mrbts_id} | ${nrbts_id} | ${nrdu_id} | Get BTS ID From vDU SCF | scf_path=/tmp/a.scf |
#    ${scf_content}   OperatingSystem.Get File   ${scf_path}
#    ${result}     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
#    ${mrbts_id}  Set Variable If  ${result}   ${result[0][0]}
#    ${nrbts_id}  Set Variable If  ${result}   ${result[0][1]}
#    ${nrdu_id}   Set Variable If  ${result}   ${result[0][2]}
#    [Return]  ${mrbts_id}   ${nrbts_id}  ${nrdu_id}
#
#
#Get LCELNR ID From vDU SCF
#    [Arguments]  ${scf_path}
#    [Documentation]  Get LCELNR ID From vDU SCF
#    ...   *Author*: chris.l.cao@nokia-sbell.com
#    ...   *History Change*
#    ...
#    ...   *Arguments Description*
#    ...   | Input Parameters | Man. | Description |
#    ...   | scf_path | Yes | scf file with absolute path, it's vDU scf file. |
#    ...
#    ...   *Return*
#    ...   list value, contains LCELNR id
#    ...
#    ...   *Example*
#    ...   | ${LCELNR_id} | Get LCELNR ID From vDU SCF | scf_path=/tmp/a.scf |
#    ...
#    ${scf_content}   OperatingSystem.Get File   ${scf_path}
#    ${matches}     Get Regexp Matches    ${scf_content}   .*MRBTS-\\d+/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-(\\d+)".+   1
#    Sort List   ${matches}
#    [Return]  ${matches}
#
#
#Get CELL ID From vDU SCF
#    [Arguments]  ${scf_path}    ${cell_index}=0
#    [Documentation]   Get CELL ID From vDU SCF
#    ...    *AUTHOR* zhijiang.shan@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    9.11.2020,zhijiang.shan@nokia-sbell.com, Create New
#	...    10.11.2020,zhijiang.shan@nokia-sbell.com, Add ${cell_index} arguments
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
#    ...    *RETURN VALUE*
#    ...    list value, contains [<nrcell_id>]
#    ...
#    ...    Example
#    ...    |  ${nrcell_id}  | Get CELL ID From vDU SCF | scf_path=/tmp/a.scf |
#    ...
#    ${scf_content}   OperatingSystem.Get File   ${scf_path}
#    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
#    ${nrcell_id}  Set Variable   ${result[${cell_index}]}
#    [Return]  ${nrcell_id}
#
#
#
#
#Get CellTechnology From VDU SCF
#    [Arguments]     ${gnb_index}=0    ${vdu_index}=0
#    [Documentation]  Get CellTechnology From VDU SCF
#    ...  author: chris.l.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...  19.10.2021,chris.l.cao@nokia-sbell.com,initialization
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...	   | gnb_index  | no | gnb_index, default is 0 |
#    ...	   | vdu_index | no | vdu_index, default is 0 |
#    ...
#    ...    *RETURN VALUE*
#    ...    TDD or FDD
#    ...
#    ...    Example
#    ...    | ${cellTechnology} | Get CellTechnology From VDU SCF |
#    ...
#    ${scf_path}    Get VDU SCF From Current Plan     gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    ${distname}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
#    scf.load_scf  file_path=${scf_path}
#    ${cellTechnology}   scf.get_all_values_from_scf   dist_name=${distname}  p_name=cellTechnology
#    [Return]   ${cellTechnology[0]}
#
#
#Get Rt Inst Distname
#    [Arguments]   ${scf_path}  ${conf_dist}
#    [Documentation]  Get route or route policy instance distname based on configure distname
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Get route or route policy instance distname based on configure distname
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | route policy distname |
#    ...    | scf_path   | yes | scf path to get distname |
#    ...    | conf_dist   | yes | configure distname |
#    ...
#    ...    *RETURN VALUE*
#    ...   instance distname
#    ...
#    ...    Example
#    ...    | VDU Rest Login |
#    ...    | ${scf_path}  Get A Directory  scf |
#    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
#    ...    | scf.Load_Scf  file_path=${scf_file} |
#    ...    | ${routeexistflag} | Get Rt Inst Distname | ${dist} |
#    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
#    ...    | VDU Logout |
#    ...
#    ${uni_id}   Get Unique Id
#    ${prefix}   ${rest}   Split String From Right   ${conf_dist}   /IPNO   1
#    ${distNames}   Get Mo DistName   scf_path=${scf_path}   tnlDN=${prefix}
#    ${templateType}=  scf.Get_Value_From_Scf   dist_name=${distNames[0]}   p_name=templateType
#    ${pod_name}=	    Set Variable If
#	...     "${templateType}" == "OAM"	oamext
#	...	    "${templateType}" == "5GControlPlane"	cp
#	...	    "${templateType}" == "5GUserPlane"	l2nrt
#    ${inst_tnl}=   Get vDU Instance TNL ID   scf_path=${scf_path}   podname=${pod_name}
#    ${inst_dist}  Replace String With Regexp   ${conf_dist}   .*  TNL-\\d+  .*  TNL-${inst_tnl}
#    [Return]   ${inst_dist}
#
#
#Get Running EQM APEQM RMOD ID From vDU SCF
#    [Arguments]  ${scf_path}
#    [Documentation]   Get RU ID and also EQM/APEQM ID from runtime SCF
#    ...    *AUTHOR* gang.ni@nokia-sbell.com
#    ...  Change History
#    ...  2022.1.1  chris.l.cao@nokia-sbell.com, change regexp
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path         | Yes | full path and file name  |
#    ...
#    ...   *RETURN VALUE*
#    ...    EQM_ID, APEQM_ID, RMOD_ID
#    ...
#    ...   Example
#    ...   |  ${eqm_id} |  ${apeqm_id} |  ${rmod_id} | Get Running EQM APEQM RMOD ID From vDU SCF | ${scf_file_with_fullpath} |
#
#    ${scf_content}   OperatingSystem.Get File      ${scf_path}
#
#    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-(\\d+)/EQM_R-(\\d+)/APEQM_R-(\\d+)/RMOD_R-(\\d+)"   1  2  3  4
#    ${eqm_id}     Set Variable  ${result[0][1]}
#    ${apeqm_id}   Set Variable  ${result[0][2]}
#    ${rmod_id}      Set Variable  ${result[0][3]}
#
##    ${result}        Get Regexp Matches            ${scf_content}    /EQM_\\S{3}/APEQM_R-\\d+
##    ${EQM_ID}        Remove String Using Regexp    ${result[0]}      /EQM_      /APEQM_R-\\d+
##
##    ${result}        Get Regexp Matches            ${scf_content}    /APEQM_\\S{4}/RMOD_R-\\d+
##    ${APEQM_ID}      Remove String Using Regexp    ${result[0]}      /APEQM_      /RMOD_R-\\d+
##
##    ${result}        Get Regexp Matches            ${scf_content}    EQM_R-\\d+/APEQM_R-\\d+/RMOD_\\S{3}
##    ${RU_ID}         Remove String Using Regexp    ${result[0]}      EQM_R-\\d+/APEQM_R-\\d+/RMOD_
#
#    [Return]    ${eqm_id}    ${apeqm_id}    ${rmod_id}
#
#
#Get RU runtime Status from runtime SCF
#    [Arguments]
#    [Documentation]   Get administrativeState/operationalState/proceduralStatus from runtime SCF
#    ...    *AUTHOR* gang.ni@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    |         |  |   |
#    ...   *RETURN VALUE*
#    ...    administrativeState, operationalState, proceduralStatus
#    ...   Example
#    ...   | Get RU runtime Status from runtime SCF |  |
#
#    VDU Rest Login
#
#    ${timestamp}    Get Timestamp
#    ${scf_path}     Get A Directory    scf_${timestamp}
#
#    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
#    ...                                                       filename=scf_${timestamp}.xml
#    ...                                                       include_runtime_data=${True}
#
#    scf.Load_Scf    file_path=${scf_file_with_fullpath}
#
#    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
#    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}    Get Running EQM APEQM RMOD ID From vDU SCF    ${scf_file_with_fullpath}
#
#    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_R-${EQM_ID}/APEQM_R-${APEQM_ID}/RMOD_R-${RU_ID}
#
#    ${administrativeState}    scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
#    ...                                                 p_name=administrativeState
#    Log To Console     ${administrativeState}
#    ${operationalState}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
#    ...                                                 p_name=operationalState
#    Log To Console     ${operationalState}
#    ${proceduralStatus}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
#    ...                                                 p_name=proceduralStatus
#    Log To Console     ${proceduralStatus}
#
#    vDU Rest Logout
#
#    [Return]    ${administrativeState}    ${operationalState}     ${proceduralStatus}
#
#Get vDU Instance TNL ID
#    [Arguments]  ${scf_path}  ${podname}
#    [Documentation]   Get vDU Instance TNL ID
#    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...    TNL instance is generated by system, all the TNL runtime info is under TNL instance, for example TNL-1 is for OAMCP TNL template,
#    ...    all the configuration is set under TNL-1, the OAMCP TNL instance maybe TNL-4, if we want to check set by system parameters value,
#    ...    then we need to check it under TNL-4, so this KW is to get the pod TNL instance id.
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
#    ...    | podname | yes | the full pod name of OAMCP or UP pod |
#    ...
#    ...    *RETURN VALUE*
#    ...    Instance TNL id of given podname.
#    ...
#    ...    Example
#    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=po-cran1-oamcp-0 |
#    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=po-cran1-up-0 |
#    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=up |
#    ...
#
#    ${distName}   Get MO distName    scf_path=${scf_path}  vmAllocated=${podname}
#    ${result}     Get Regexp Matches     ${distName[0]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHLK-\\d+/ETHLK_R-\\d+   1
#    ${tnl_id}  Set Variable If  ${result}   ${result[0]}
#    should be true  ${tnl_id}>=1
#    [Return]  ${tnl_id}
#
#
#Get Maximum TNL Number Of TNLTEMPLATE From SCF
#    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${scf_path}=${EMPTY}
#    [Documentation]   Get Maximum TNL Number Of TNLTEMPLATE From SCF
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  24.2.2024   chris.l.cao@nokia-sbell.com,  add parameter scf_path
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | gnb_index | no | gnb_index, default is 0 |
#    ...    | vdu_index | no | vdu_index, default is 0 |
#    ...
#    ...    *RETURN VALUE*
#    ...    Maximum TNL Number of TNLTEMPLATE, e.g 4
#    ...
#    ...    Example
#    ...    | ${maximum_TNL_number}  | Get Maximum TNL Number Of TNLTEMPLATE From SCF |
#    ...    | ${maximum_TNL_number}  | Get Maximum TNL Number Of TNLTEMPLATE From SCF | gnb_index=1 | vdu_index=1 |
#    ...
#    ${tmp_scf_path}   Run Keyword If  "${scf_path}"=="${EMPTY}"   Get VDU SCF From Current Plan   gnb_index=${gnb_index}  vdu_index=${vdu_index}
#       ...  ELSE  Set Variable   ${scf_path}
#    ${distName}   Get MO DistName     scf_path=${tmp_scf_path}  distName=TNLSVC-1/TNLTEMPLATE-
#    Sort List  ${distName}
#    scf.load_scf  file_path=${tmp_scf_path}
#    ${value}    scf.get_all_values_from_scf   dist_name=${distName[-1]}   p_name=tnlDN
#    ${matches}   Get Regexp Matches   ${value[0]}   MRBTS-\\d+/TNLSVC-1/TNL-(\\d+)   1
#    ${max_TNL_number}   Set Variable   ${matches[0]}
#    [Return]   ${max_TNL_number}
#
#
#Get vDU Instance TNL ID From SCF By VlanIfName
#    [Arguments]  ${vlanIfName}=mcplane   ${gnb_index}=0    ${vdu_index}=0  ${scf_path}=${EMPTY}
#    [Documentation]   Get vDU Instance TNL ID From SCF By VlanIfName
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  14.7.2023   chris.l.cao@nokia-sbell.com,  support TNL number >=10
#    ...  24.2.2024   chris.l.cao@nokia-sbell.com,  add parameter scf_path
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | gnb_index | no | gnb_index, default is 0 |
#    ...    | vdu_index | no | vdu_index, default is 0 |
#    ...    | vlanIfName | no | vlanIfName, e.g, mcplane, f1cplane, f1uplane, fhmplane, twamp_f1, default is mcplane |
#    ...    | scf_path | no | scf_path, default is ${EMPTY} |
#    ...
#    ...    *RETURN VALUE*
#    ...    Instance TNL id of given vlanIfName.
#    ...
#    ...    Example
#    ...    | ${tnl_mcplane}  | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=mcplane |
#    ...    | ${tnl_f1cplane} | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=f1cplane |
#    ...    | ${tnl_f1uplane} | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=f1uplane |
#    ...    | ${tnl_fhmplane} | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=fhmplane |
#    ...    | ${tnl_fhmplane} | Get vDU Instance TNL ID From SCF By VlanIfName | vlanIfName=twamp_f1 |
#    ...
#    ${tmp_scf_path}  Run Keyword If  "${scf_path}"=="${EMPTY}"   Get VDU SCF From Current Plan   gnb_index=${gnb_index}
#         ...  ELSE   Set Variable    ${scf_path}
#    ${maximum_TNL_number_of_TNLTEMPLATE}   Get Maximum TNL Number Of TNLTEMPLATE From SCF   gnb_index=${gnb_index}    vdu_index=${vdu_index}
#                                          ...  scf_path=${tmp_scf_path}
#    ${distName}   Get MO DistName     scf_path=${tmp_scf_path}  vlanIfName=${vlanIfName}
#    ${mrbts_id}  Get MRBTS Id From vDU SCF   scf_file=${tmp_scf_path}
#    :FOR  ${one}  IN  @{distName}
#    \   ${matches}   Get Regexp Matches   ${one}  MRBTS-${mrbts_id}/TNLSVC-1/TNL-(\\d+)/.+   1
#    \   ${TNL_number}  Set Variable   ${matches[0]}
#    \   ${r}   Evaluate  int(${TNL_number})>int(${maximum_TNL_number_of_TNLTEMPLATE})
#    \   Exit For Loop If   "${r}"=="${True}"
#    Should Be True   ${TNL_number} > ${maximum_TNL_number_of_TNLTEMPLATE}
#    [Return]  ${TNL_number}
#
#
#Get vDU IPADDRESS DN
#    [Arguments]  ${scfpath}    ${uniqueIpId}    ${tnlid}    ${version}=4
#    [Documentation]   Get vDU IPADDRESS DN
#    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...    Sometimes we need configure IPADDRESS DN for some application, such as f1c plane, some kind of source ip address DN,
#    ...    and the ip address DN should be the DN of TNL template such as TNL-1 for OAMCP, we can get it automatically using
#    ...    IPADDRESSV4/V6.uniqueIpAddressIdentifier to filter.
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
#    ...    | uniqueIpId | yes | the uniqueIpAddressIdentifier of the searched IPADDRESS DN |
#    ...    | version    | no | the ip version default is 4 |
#    ...    | tnlid    | yes | the template type TNL ID of the IP address DN located |
#    ...    *RETURN VALUE*
#    ...    IP address DN for given unique ip address id under TNL with template true type.
#    ...
#    ...    Example
#    ...    |  ${oam_f1_IPDN}  | Get vDU IPADDRESS DN | scf_path=/tmp/a.scf | uniqueIpId=F1-C Xp | tnlid=1 |
#    ...    |  ${up_f1_IPDN}  | Get vDU IPADDRESS DN | scf_path=/tmp/a.scf | uniqueIpId=F1-U |  tnlid=3  |
#    ...
#    ${distName}   Get MO distName    scf_path=${scfpath}  uniqueIpAddressIdentifier=${uniqueIpId}
#    ${distName_length}=   get length   ${distName}
#    ${ipaddressdn}=    set variable    ${None}
#    ${index}=    set variable    ${None}
#    : FOR    ${i}    IN RANGE    0    ${distName_length}
#    \   ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/IPNO-\\d+/IPIF-\\d+/IPADDRESSV${version}-\\d+   1
#    \   ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
#    \   exit for loop if  '${result[0]}'=='${tnlid}'
#    ${ipaddressdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
#    [Return]  ${ipaddressdn}
#
#Get vDU ETHLK DN
#    [Arguments]  ${scfpath}    ${underLyingIF}    ${tnlid}
#    [Documentation]   Get vDU ETHLK DN
#    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...    Sometimes we need configure ETHLK DN for some application, such as linkSelectorDN of ETHIF, for configuration we need ETHLK
#    ...    DN of TNL template such as TNL-1 for OAMCP, when we get TNL counter in TA scripts, we need the DN of TNL instance,
#    ...    We can get it automatically using underLyingInterface to filter
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
#    ...    | underLyingIF | yes | the underLyingInterface of the searched ETHLK DN |
#    ...    | tnlid    | yes | the template or instance type TNL ID of the ETHLK DN located |
#    ...    *RETURN VALUE*
#    ...    ETHLK DN for given underLyingInterface.
#    ...
#    ...    Example
#    ...    |  ${oam_f1_ETHLKDN}  | Get vDU ETHLK DN | scf_path=/tmp/a.scf | underLyingIF=f1 | tnlid=1 |
#    ...    |  ${up_f1_ETHLKDN}  | Get vDU ETHLK DN | scf_path=/tmp/a.scf | underLyingIF=f1 |  tnlid=3  |
#    ...
#    ${distName}   Get MO distName    scf_path=${scfpath}  underLyingInterface=${underLyingIF}
#    ${distName_length}=   get length   ${distName}
#    ${ethlkdn}=    set variable    ${None}
#    ${index}=    set variable    ${None}
#    : FOR    ${i}    IN RANGE    0    ${distName_length}
#    \   ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHLK-\\d+   1
#    \   ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
#    \   exit for loop if  '${result[0]}'=='${tnlid}'
#    ${ethlkdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
#    [Return]  ${ethlkdn}
#
#Get vDU VLANIF DN
#    [Arguments]  ${scfpath}    ${vlanIf}    ${tnlid}
#    [Documentation]   Get vDU VLANIF DN
#    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...    Sometimes we need configure ETHIF DN for some application, such as interfaceDN of IPIF, for configuration we need VLANIF
#    ...    DN of TNL template such as TNL-1 for OAMCP, when we get TNL counter in TA scripts, we need the DN of TNL instance,
#    ...    We can get it automatically using vlanIfName to filter
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
#    ...    | vlanIf | yes | the vlanIfName of the searched VLANIF DN |
#    ...    | tnlid    | yes | the template or instance type TNL ID of the VLANIF DN located |
#    ...    *RETURN VALUE*
#    ...    VLANIF DN for given underLyingInterface.
#    ...
#    ...    Example
#    ...    |  ${oam_f1_VLANIFDN}  | Get vDU VLANIF DN | scf_path=/tmp/a.scf | vlanIf=f1cplane | tnlid=1 |
#    ...    |  ${up_f1_VLANIFDN}  | Get vDU VLANIF DN | scf_path=/tmp/a.scf | vlanIf=f1uplane |  tnlid=3  |
#    ...
#    ${distName}   Get MO distName    scf_path=${scfpath}  vlanIfName=${vlanIf}
#    ${distName_length}=   get length   ${distName}
#    ${vlanifdn}=    set variable    ${None}
#    ${index}=    set variable    ${None}
#    : FOR    ${i}    IN RANGE    0    ${distName_length}
#    \   ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHIF-\\d+/VLANIF-\\d+   1
#    \   ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
#    \   exit for loop if  '${result[0]}'=='${tnlid}'
#    ${vlanifdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
#    [Return]  ${vlanifdn}
#
#
#Route Policy Should Exist
#    [Arguments]   ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}
#    [Documentation]    Route policy should exist in dist mo
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Check whether the given route policy exist under dist MO
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | route policy distname |
#    ...    | orderNumber   | yes | orderNumber for policy |
#    ...    | routingTableDN   | yes | routingTableDN for policy |
#    ...    | srcIpAddress  | yes | srcIpAddress for policy |
#    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for policy |
#    ...
#    ...    *RETURN VALUE*
#    ...   None
#    ...
#    ...    Example
#    ...    | VDU Rest Login |
#    ...    | ${scf_path}  Get A Directory  scf |
#    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
#    ...    | scf.Load_Scf  file_path=${scf_file} |
#    ...    | ${routeexistflag} | Route Policy Should Exist | ${dist} |
#    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
#    ...    | VDU Logout |
#    ...
#    ${pol_info}   scf.Get All Values From Scf   dist_name=${dist}   p_name=orderNumber
#    ${rtpol_len}   Get Length   ${pol_info}
#    ${pol_exist}=    Set Variable    ${False}
#    ${srcIpAddress}  Remove String Using Regexp   ${srcIpAddress}   :0   :
#
#    : FOR    ${i}    IN RANGE    0    ${rtpol_len}
#    \    ${res}  Run Keyword And Ignore Error   Check RTPOL With Policy Index
#    ...  ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}  ${i}
#    \    ${pol_exist}=   Set Variable If   '${res[0]}'=='PASS'   ${True}   ${False}
#    \    exit for loop if  '${pol_exist}'=='${True}'
#    Should Be True  '${pol_exist}'=='${True}'   route policy is not exist for ${dist}!
#
#
#Check RTPOL With Policy Index
#    [Arguments]   ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}  ${index}=0
#    [Documentation]    Route policy with specific index should exist in dist mo
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Check whether the given route policy with specific index exist in forwarding entries under dist MO
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | route policy distname |
#    ...    | orderNumber   | yes | orderNumber for policy |
#    ...    | routingTableDN   | yes | routingTableDN for policy |
#    ...    | srcIpAddress  | yes | srcIpAddress for policy |
#    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for policy |
#    ...    | index   | No | index for policy, default is the first one 0 |
#    ...
#    ...    *RETURN VALUE*
#    ...   None
#    ...
#    ...    Example
#    ...    | VDU Rest Login |
#    ...    | ${scf_path}  Get A Directory  scf |
#    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
#    ...    | scf.Load_Scf  file_path=${scf_file} |
#    ...    | ${routeexistflag} | Check RTPOL With Policy Index | ${dist} |
#    ...    | ${orderNumber} | ${routingTableDN} | ${srcIpAddress} | ${srcIpPrefixLength} |
#    ...    | VDU Logout |
#    ...
#    ${route_policy_name}  Set Variable If  'RTPOL_R' in '${dist}'  discoveredPolicyEntries  routingPolicies
#    ${orderNumber1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
#    ...  p_name=orderNumber  index=${index}
#    Should Be True   '${orderNumber1}'=='${orderNumber}'
#    ${routingTableDN1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
#    ...  p_name=routingTableDN  index=${index}
#    Should Be True   '${routingTableDN1}'=='${routingTableDN}'
#    ${srcIpAddress1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
#    ...   p_name=srcIpAddress  index=${index}
#    ${srcIpAddress}  Remove String Using Regexp   ${srcIpAddress}   :0   :
#    ${srcIpAddress1}  Remove String Using Regexp   ${srcIpAddress1}   :0   :
#    Should Be True   '${srcIpAddress1}'=='${srcIpAddress}'
#    ${srcIpPrefixLength1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_policy_name}
#    ...  p_name=srcIpPrefixLength  index=${index}
#    Should Be True   '${srcIpPrefixLength1}'=='${srcIpPrefixLength}'
#
#Get New Iprt Distname
#    [Arguments]  ${scf_path}  ${tnl_id}
#    [Documentation]    Get new iprt distname based on given tnl id
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Get new iprt distname based on given tnl id
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path    | yes | scf file path |
#    ...    | tnl_id   | yes | tnl id to get iprt distname |
#    ...
#    ...    *RETURN VALUE*
#    ...   IPRT distname
#    ...
#    ...    Example
#    ...    | ${scf_path}  Get A Directory  scf |
#    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
#    ...    | scf.Load_Scf  file_path=${scf_file} |
#    ...    | ${iprt_dist} | Get New Iprt Distname | ${scf_file}  | 2 |
#    ...    | VDU Logout |
#    ...
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    ${distNames}   Get Mo DistName  scf_path=${scf_path}  gateway
#    ${distNames}   Evaluate    [i for i in @{distNames} if "TNL-${tnl_id}/" in i]
#    ${length}  Get Length  ${distNames}
#    ${new_dist}  Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1/IPRT-2
#    Return From Keyword If    ${length}==0    ${new_dist}
#    ${prefix}   ${rest}   Split String From Right   ${distNames[0]}   -   1
#    ${unused_iprt_id}   Set Variable    0
#    :FOR    ${i}    IN RANGE  2  10
#    \   ${unused_iprt_id}=   evaluate    ${unused_iprt_id}+1
#    \   ${res}  scf.Is_Object_In_Scf   ${prefix}-${unused_iprt_id}
#    \   exit for loop if  '${res}'=='False'
#    ${new_dist}   Set Variable  ${prefix}-${unused_iprt_id}
#    [Return]   ${new_dist}
#
#Get New Iprt6 Distname
#    [Arguments]  ${scf_path}  ${tnl_id}
#    [Documentation]    Get new iprt6 distname based on given tnl id
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Get new iprt6 distname based on given tnl id
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path    | yes | scf file path |
#    ...    | tnl_id   | yes | tnl id to get iprt distname |
#    ...
#    ...    *RETURN VALUE*
#    ...   IPRT distname
#    ...
#    ...    Example
#    ...    | ${scf_path}  Get A Directory  scf |
#    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
#    ...    | scf.Load_Scf  file_path=${scf_file} |
#    ...    | ${iprt_dist} | Get New Iprt6 Distname | ${scf_file}  | 2 |
#    ...    | VDU Logout |
#    ...
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    ${distNames}   Get Mo DistName  scf_path=${scf_path}  gatewayIpv6Addr
#    ${distNames}   Evaluate    [i for i in @{distNames} if "TNL-${tnl_id}/" in i]
#    ${length}  Get Length  ${distNames}
#    ${new_dist}  Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1/IPRTV6-2
#    Return From Keyword If    ${length}==0    ${new_dist}
#    ${prefix}   ${rest}   Split String From Right   ${distNames[0]}   -   1
#    ${unused_iprt_id}   Set Variable    0
#    :FOR    ${i}    IN RANGE  2  10
#    \   ${unused_iprt_id}=   evaluate    ${unused_iprt_id}+1
#    \   ${res}  scf.Is_Object_In_Scf   ${prefix}-${unused_iprt_id}
#    \   exit for loop if  '${res}'=='False'
#    ${new_dist}   Set Variable  ${prefix}-${unused_iprt_id}
#    [Return]   ${new_dist}
#
#Get Rtpol Distname
#    [Arguments]  ${scf_path}   ${tnl_id}
#    [Documentation]    Get rtpol distname based on given tnl id
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Get rtpol distname based on given tnl id
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path    | yes | scf file path |
#    ...    | tnl_id   | yes | tnl id to get rtpol distname |
#    ...
#    ...    *RETURN VALUE*
#    ...   rtpol distname
#    ...
#    ...    Example
#    ...       VDU Rest Login
#    ...    | ${scf_path}  Get A Directory  scf |
#    ...    | ${scf_file}  vdu.Get Current Plan File  local_dir_path=${scf_path}  filename=scf.xml |
#    ...    | scf.Load_Scf  file_path=${scf_file}
#    ...    | ${rtpol_dist} | Get Rtpol Distname | ${scf_file}  | 2 |
#    ...    | VDU Logout |
#    ...
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    ${distNames}   Get Mo DistName  scf_path=${scf_path}  orderNumber
#    ${distNames}   Evaluate    [i for i in @{distNames} if "TNL-${tnl_id}/" in i]
#    ${length}  Get Length  ${distNames}
#    ${new_dist}  Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPNO-1/RTPOL-1
#    Return From Keyword If    ${length}==0    ${new_dist}
#    [Return]   ${distNames[0]}
#
#VDU Check Static Route Configured
#    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}=None  ${gateway}=None  ${preference}=None
#    [Documentation]    Vdu Static Route check exists or not
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Check whether the given route policy exist under dist MO
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | static route distname |
#    ...    | destIpAddr   | yes | destIpAddr for static route |
#    ...    | PrefixLength  | yes | PrefixLength for static route |
#    ...    | gateway  | yes | gateway for static route |
#    ...    | preference   | yes | preference for static route |
#    ...
#    ...    *RETURN VALUE*
#    ...    list: static route exist or not,  index number if route exist
#    ...
#    ...    Example
#    ...    | ${route_exists}  ${index} | VDU Check Static Route Configured | ${dist} |
#    ...    | ${destIpAddr} | ${PrefixLength} | ${gateway} | ${preference} |
#    ${uni_id}   Get Unique Id
#    vDU Rest Login
#    ${scf_path}  Get A Directory  scf
#    ${scf_full_path}=  vdu.Get Current Plan File    ${scf_path}   vdu_SCF_${uni_id}.xml   include_runtime_data=${True}
#    scf.Load Scf   ${scf_full_path}
#    ${gateway_name}   set variable if  ':' in '''${destIpAddr}'''   gatewayIpv6Addr   gateway
#    ${gateway_info}   scf.Get All Values From Scf   dist_name=${dist}   p_name=${gateway_name}
#    ${gateway_len}   Get Length   ${gateway_info}
#    ${rt_exist}=    Set Variable    ${False}
#    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
#    Log To Console   ${destIpAddr}
#    ${index}   set variable  0
#    : FOR    ${i}    IN RANGE    0    ${gateway_len}
#    \    ${res}  Run Keyword And Ignore Error   VDU Check Static Route Index configured
#    ...  ${dist}  ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}  ${i}
#    \    ${rt_exist}=   Set Variable If   '${res[0]}'=='PASS'   ${True}   ${False}
#    \    ${index}=   Set Variable If   '${res[0]}'=='PASS'   ${i}   0
#    \    exit for loop if  '${rt_exist}'=='${True}'
#    [Return]    ${rt_exist}    ${index}
#
#VDU Check Static Route Index configured
#    [Arguments]   ${dist}  ${destIpAddr}  ${PrefixLength}=None  ${gateway}=None  ${preference}=None  ${index}=0
#    [Documentation]    Vcu Static Route should exist in specific index
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Check whether the given route policy exist under dist MO
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | static route distname |
#    ...    | destIpAddr   | yes | destIpAddr for static route |
#    ...    | PrefixLength  | yes | PrefixLength for static route |
#    ...    | gateway  | yes | gateway for static route |
#    ...    | preference   | yes | preference for static route |
#    ...    | index   | no | index of configured static route |
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | VDU Check Static Route Index configured | ${dist} |
#    ...    | ${destIpAddr} | ${PrefixLength} | ${gateway} | ${preference} | 0 |
#    ${destip_par}   set variable if  ':' in '''${destIpAddr}'''   destIpv6Addr   destIpAddr
#    ${prefix_par}   set variable if  ':' in '''${destIpAddr}'''   destinationIpv6PrefixLength   destinationIpPrefixLength
#    ${gw_par}   set variable if  ':' in '''${destIpAddr}'''   gatewayIpv6Addr   gateway
#    ${route_list_name}  Set Variable If  ':' in '${destIpAddr}'  staticIpv6Routes  staticRoutes
#
#    ${destIpAddr1}  scf.Get_Value_From_Scf   dist_name=${dist}  list_name=${route_list_name}
#    ...  p_name=${destip_par}  index=${index}
#    ${destIpAddr1}   Replace String Using Regexp   ${destIpAddr1}   :0+  :
#    ${destIpAddr}   Replace String Using Regexp   ${destIpAddr}   :0+  :
#    Should Be True   '${destIpAddr1}'=='${destIpAddr}'
#    ${PrefixLength1}  Run Keyword If  "${PrefixLength}"!="None"  scf.Get_Value_From_Scf
#    ...   dist_name=${dist}  list_name=${route_list_name}  p_name=${prefix_par}  index=${index}
#    Run Keyword If  "${PrefixLength}"!="None"  Should Be True   '${PrefixLength1}'=='${PrefixLength}'
#    ${gateway1}  Run Keyword If  "${gateway}"!="None"  scf.Get_Value_From_Scf
#    ...   dist_name=${dist}  list_name=${route_list_name}  p_name=${gw_par}  index=${index}
#    ${gateway1}   Replace String Using Regexp   ${gateway1}   :0+  :
#    ${gateway}   Replace String Using Regexp   ${gateway}   :0+  :
#    Run Keyword If  "${gateway}"!="None"  Should Be True   '${gateway1}'=='${gateway}'
##    ${preference1}  Run Keyword If  "${preference}"!="None"  scf.Get_Value_From_Scf
##    ...  dist_name=${dist}  list_name=${route_list_name}  p_name=preference  index=${index}
##    Run Keyword If  "${preference}"!="None"  Should Be True   '${preference1}'=='${preference}'
#
#Vdu Add Route
#    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8   ${wait_vdu_up}=False
#    [Documentation]    Add static route for vdu
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...   *History Change*
#    ...   | date | who | what and how |
#    ...   | 2023-04-25 | hongping.rao | update for static route configuration |
#
#    ...    Add static route for vdu
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | distname to add static route |
#    ...    | destIpAddr   | yes | destIpAddr for static route |
#    ...    | PrefixLength   | yes | PrefixLength for static route |
#    ...    | gateway   | yes | gateway for static route |
#    ...    | preference   | no | preference for static route, default is 8 |
#    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route configured |
#
#    ...
#    ...    *RETURN VALUE*
#    ...   list of route info  [static route distname,  staticRoutes/index]
#    ...
#    ...    Example
#    ...    | VDU Rest Login |
#    ...    | ${route_info} | Vdu Add Route | dist  | 1.1.1.1 | 24 | 1.1.1.2 |
#    ...    | VDU Logout |
#    ...
#    ${route_list_name}  Set Variable If  ':' in '''${destIpAddr}'''  staticIpv6Routes  staticRoutes
#    ${route_exists}   ${index}   VDU Check Static Route Configured
#    ...  ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}
#    ${res}  Run Keyword If  "${route_exists}"=="${True}"   create list  ${dist}  ${route_list_name}/${index}
#    Return From Keyword If  "${route_exists}"=="${True}"    ${res}
#
#    ${route_dstip_name}  Set Variable If  ':' in '''${destIpAddr}'''  destIpv6Addr  destIpAddr
#    ${route_prefix_name}  Set Variable If  ':' in '''${destIpAddr}'''  destinationIpv6PrefixLength
#    ...  destinationIpPrefixLength
#    ${route_gateway_name}  Set Variable If  ':' in '''${destIpAddr}'''  gatewayIpv6Addr  gateway
#
#    ${uni_id}   Get Unique Id
#    ${scf_path}  Get A Directory  SCF
#    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
#    scf.Load Scf   ${scf_full_path}
#    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
#    ...  p_name=${route_gateway_name}
#    ${length}   Run Keyword If  '${res[0]}'=='PASS'   Get Length   ${res[1]}
#    ...  ELSE    Set Variable  0
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_route_${uni_id}
#    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
#    ${rt_object_exist}  scf.is_object_in_scf  dist_name=${dist}
#    Run Keyword If  ${rt_object_exist}!=${True}   Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${prefix}  mo_name=${rest}
#    ${paras_list}    Create Dictionary   /${route_list_name}=${EMPTY}
#    Run Keyword If   ${length}==0  Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}
#    ...  updated_paras_dict=${paras_list}   operation=add
#    Sleep  2sec
#
#    ${paras}=   Create Dictionary    /${route_list_name}/${length}=${EMPTY}
#    ...   ${route_list_name}/${length}/${route_gateway_name}=${gateway}
#    ...   ${route_list_name}/${length}/${route_dstip_name}=${destIpAddr}
#    ...   ${route_list_name}/${length}/${route_prefix_name}=${PrefixLength}
#    ...   ${route_list_name}/${length}/preference=${preference}
#    Sleep   10sec
#    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${paras}   operation=add
#    Validate Delta Plan By REST   ${plan_id}
#    ${scf_path}  Get A Directory  SCF
#    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
#    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
#    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
#    [Return]   ${dist}  ${route_list_name}/${length}
#
#Vdu Delete Route
#    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8   ${wait_vdu_up}=False
#    [Documentation]    Delete static route for vdu
#    ...    *AUTHOR* xiaqing.chen@nokia-sbell.com
#    ...    Delete static route for vdu
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | distname to delete static route |
#    ...    | destIpAddr   | yes | destIpAddr for static route |
#    ...    | PrefixLength   | yes | PrefixLength for static route |
#    ...    | gateway   | yes | gateway for static route |
#    ...    | preference   | no | preference for static route, default is 8 |
#    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route deleted |
#
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | vDU Rest Login |
#    ...    | ${dist} | Set Variable | MRBTS-10717/TNLSVC-1/TNL-1/IPNO-1/IPRT-3 |
#    ...    | Vdu Delete Route | ${dist} | destIpAddr=1.1.1.1 |  PrefixLength=24 | gateway=1.1.1.2 |
#    ...    | vDU Rest Logout |
#    ...
#    ${route_list_name}  Set Variable If  ':' in '''${destIpAddr}'''  staticIpv6Routes  staticRoutes
#    ${route_exists}   ${index}   VDU Check Static Route Configured
#    ...  ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}
#    ${item_list_to_remove_tmp}  Run Keyword If  "${route_exists}"=="${True}"  create list  ${dist}  ${route_list_name}/${index}
#    ${item_list_to_remove}  Run Keyword If  "${route_exists}"=="${True}"  create list  ${item_list_to_remove_tmp}
#    Run Keyword If  "${route_exists}"=="${True}"  Delta Remove Items  ${item_list_to_remove}  ${wait_vdu_up}
#
#Delta Remove Items
#    [Arguments]   ${item_list_to_remove}   ${wait_vdu_up}=False
#    [Documentation]    Delta remove items for vdu
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    Delta remove items for vdu
#    ...    | Input Parameters | Man. | Description |
#    ...    | item_list_to_remove | yes | each item should contain distname and item name with index |
#    ...    | wait_vdu_up | no | whether to wait for vdu up after static route configured |
#    ...
#    ...    *RETURN VALUE*
#    ...   None
#    ...
#    ...    Example
#    ...    | VDU Rest Login |
#    ...    | ${route_info} | Delta Remove Items | ${item_list_to_remove} |
#    ...    | VDU Logout |
#    ...
#    ${item_length}     get length    ${item_list_to_remove}
#    Return From Keyword If   ${item_length}==0
#    VDU Rest Login
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=remove_dist_ta
#    ${mo_to_remove}  Create List
#    :FOR  ${item}  IN  @{item_list_to_remove}
#    \    ${prefix}   ${rest}   Split String From Right   ${item[1]}   /   1
#    \    ${prefix1}   ${rest1}   Split String From Right   ${item[0]}   -   1
#    \    Run Keyword If  ${rest}==0 and ${rest1}>1  Append To List    ${mo_to_remove}   ${item[0]}
#    \    ${number}   Count Values In List   ${mo_to_remove}    ${item[0]}
#    \    Run Keyword If  ${number}>=1  Run Keyword And Ignore Error   Delete Delta Plan MO   ${plan_id}   ${item[0]}
#    \    Continue For Loop If  ${number}>=1
#    \    ${paras}=   Create Dictionary   ${item[1]}=${empty}
#    \    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${item[0]}
#    ...  updated_paras_dict=${paras}   operation=remove
#
#    ${uni_id}   Get Unique Id
#    ${scf_path}  Get A Directory  SCF
#    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}
#    ...   local_filename=delta_remove_items_${uni_id}.xml
#    Validate Delta Plan By REST   ${plan_id}
#    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
#
#
#VDU Delete Delta Plan MOs And Activate
#    [Arguments]  ${mo_list}   ${gnb_index}=0    ${vdu_index}=0  ${wait_vdu_up}=${False}
#    [Documentation]    Delete Delta Plan MO
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   *Change History*
#    ...   8.12.2023 chris.l.cao@nokia-sbell.com, initialization
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | mo_list | No | mo_list bo be deleted |
#    ...    | gnb_index | No | the index of gnb, default value is 0 |
#    ...    | vdu_index | No | the index of vdu, default value is 0 |
#    ...
#    ...    *Return*
#    ...    None
#    ...
#    ...   *Example*
#    ...  | ${mo_list}           | Create List  | MRBTS-108201/TNLSVC-1/TNL-3/IPNO-1/QOS-1/FSTSCH-1 |
#    ...  | VDU Delete Delta Plan MOs And Activate | mo_list=${mo_list} |
#    ...  | VDU Delete Delta Plan MOs And Activate | mo_list=${mo_list} | gnb_index=0 | vdu_index=1 |
#    ...
#    ${length}     Get Length    ${mo_list}
#    Return From Keyword If   ${length}==0
#
#    ${object_existence_dict}   VDU Get Object Existence    mo_list=${mo_list}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
#
#    ${alias}   VDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ${delta_plan_id}   ${action_id}   Generate Delta Plan   plan_name=remove_MO_ta   alias=${alias}
#
#    ${need_delete}  Set Variable  0
#    FOR  ${mo}   IN   @{mo_list}
#        ${existence}   Get From Dictionary   ${object_existence_dict}   ${mo}
#        ${need_delete}  Run Keyword If  "${existence}"=="${True}"  Evaluate  int(${need_delete})+1
#           ...   ELSE   Set Variable   ${need_delete}
#        Run Keyword If  "${existence}"=="${True}"
#        ...    Delete Delta Plan MO   plan_id=${delta_plan_id}   mo_dn=${mo}  alias=${alias}
#    END
#
#	Run Keyword If   ${need_delete}>=1   Validate Delta Plan By REST   plan_id=${delta_plan_id}   alias=${alias}
#    Run Keyword If   ${need_delete}>=1   Activate Delta Plan By REST   plan_id=${delta_plan_id}   alias=${alias}  wait_vdu_up=${wait_vdu_up}
#
#
#VDU Get Object Existence
#    [Arguments]    ${mo_list}    ${gnb_index}=0   ${vdu_index}=0
#    [Documentation]   VDU Get Object Existence
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  2023.12.8 ,chris.l.cao@nokia-sbell.com, initialization
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | mo_list    | yes | the mo distname list that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
#    ...	  | gnb_index | no | gnb_index, default is 0 |
#    ...	  | vdu_index | no | vdu_index, default is 0 |
#    ...
#    ...   *RETURN VALUE*
#    ...    object existence dict, e.g, {'MRBTS-1234/MNL-1/AMGR-1/LUAC-1': 'True' }
#    ...
#    ...   Example
#    ...   | ${mo_list} | Create List | MRBTS-1234 | MRBTS-1234/MNL-1/AMGR-1/LUAC-1 |
#    ...   | ${object_existence_dict} | VDU Get Object Existence | para_list=${para_list} | mo_list=${mo_list} |
#    ...
#    ${object_existence_dict}   Create Dictionary
#    ${scf_file_with_fullpath}   Get VDU SCF From Current Plan  gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    scf.load scf  ${scf_file_with_fullpath}
#
#    ${length}   Get Length    ${mo_list}
#    :FOR    ${i}    IN RANGE    0     ${length}
#    \    ${mo}  Set Variable   ${mo_list[${i}]}
#    \    ${query_result}  scf.Is Object In Scf  ${mo}
#    \    Set to Dictionary  ${object_existence_dict}  ${mo}   ${query_result}
#    [Return]  ${object_existence_dict}
#
#
#Vdu Add Rtpol
#    [Arguments]  ${dist}  ${orderNumber}  ${routingTableDN}  ${srcIpAddress}  ${srcIpPrefixLength}  ${wait_vdu_up}=False
#    [Documentation]    Add route policy for vdu
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...   *History Change*
#    ...   | date | who | what and how |
#    ...   | 2023-04-26 | hongping.rao | update for rt pol delta configuration |
#    ...    Add route policy for vdu
#    ...    | Input Parameters | Man. | Description |
#    ...    | dist    | yes | distname to add route policy |
#    ...    | orderNumber   | yes | orderNumber for route policy |
#    ...    | routingTableDN   | yes | routingTableDN for route policy |
#    ...    | srcIpAddress   | yes | srcIpAddress for route policy |
#    ...    | srcIpPrefixLength   | yes | srcIpPrefixLength for route policy |
#    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route configured |
#    ...
#    ...    *RETURN VALUE*
#    ...   list of route policy info  [routingPolicies distname,  routingPolicies/index]
#    ...
#    ...    Example
#    ...    | VDU Rest Login |
#    ...    | ${route_info} | Vdu Add Rtpol | ${dist} | 5 | ${routingTableDN} | 1.1.1.1 | 24 |
#    ...    | VDU Logout |
#    ...
#
#    ${pol_list_name}  Set Variable If  ':' in '''${srcIpAddress}'''  staticIpv6Routes  staticRoutes
#    ${route_dstip_name}  Set Variable If  ':' in '''${srcIpAddress}'''  destIpv6Addr  destIpAddr
#    ${route_prefix_name}  Set Variable If  ':' in '''${srcIpAddress}'''  destinationIpv6PrefixLength
#    ...  destinationIpPrefixLength
#    ${route_gateway_name}  Set Variable If  ':' in '''${srcIpAddress}'''  gatewayIpv6Addr  gateway
#
#    ${uni_id}   Get Unique Id
#    ${scf_path}  Get A Directory  SCF
#    ${scf_full_path}=  vdu.Get Current Plan File    ${scf_path}   full_scf_${uni_id}.xml   include_runtime_data=${True}
#    scf.Load Scf   ${scf_full_path}
#    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}   p_name=orderNumber
#    ${length}   Run Keyword If  '${res[0]}'=='PASS'  Get Length   ${res[1]}
#    ...  ELSE    Set Variable  0
#
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_route_pol_${uni_id}
#    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
#    ${pol_object_exist}  scf.is_object_in_scf  dist_name=${dist}
#    Run Keyword If  ${pol_object_exist}!=${True}  Add Delta Plan MO
#    ...  plan_id=${plan_id}   parent_mo_dn=${dist}  mo_name=${rest}
#
#    ${paras}=   Create Dictionary   /routingPolicies/${length}=${EMPTY}
#    ...   routingPolicies/${length}/orderNumber=${orderNumber}
#    ...   routingPolicies/${length}/routingTableDN=${routingTableDN}
#    ...   routingPolicies/${length}/srcIpAddress=${srcIpAddress}
#    ...   routingPolicies/${length}/srcIpPrefixLength=${srcIpPrefixLength}
#
#    ${paras_list}    Create Dictionary   /routingPolicies=${EMPTY}
#    Run Keyword If   ${length}==0  Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}
#    ...  updated_paras_dict=${paras_list}   operation=add
#    sleep  2sec
#    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${paras}   operation=add
#    Validate Delta Plan By REST   ${plan_id}
#    ${scf_path}  Get A Directory  SCF
#    ${delta_filename}  Set Variable   add_route_pol_${uni_id}.xml
#    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
#    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
#    [Return]   ${dist}  routingPolicies/${length}
#
#
#Get VDU Cell Number From SCF
#    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
#    [Documentation]  Get VDU Cell Number From SCF
#    ...   *Author*: chris.l.cao@nokia-sbell.com
#    ...   *History Change*
#    ...   | date | who | what and how |
#    ...   | 2022-4-6 | hongysun | update documentation |
#    ...   | 2022-11-10 | r3li | fix error that call keyword after reinstall |
#    ...   | 2023-7-5 | r3li | correct error for CU Rest Login changed |
#    ...   | 2023-7-24 | chris.l.cao | change from "multiple_folder/scf.xml" to "one_folder/multiple_scf_.xml files
#    ...   | 2023-12-15 | chris.l.cao | change to use 'vDU Get Cell List From Webem'
#    ...
#    ...   *Arguments Description*
#    ...   | Input Parameters | Man. | Description |
#    ...   | vdu_index | No | vdu index in init.py file, default is 0 |
#    ...   | gnb_index | No | gnb index to indicate which gnb will be used, default is 0 |
#    ...
#    ...   *Return*
#    ...   Cell number from test line configuration
#    ...
#    ...   *Example*
#    ...   | ${cell_number} | Get VDU Cell Number From SCF |
#    ...
#    ${cell_list}   vDU Get Cell List From Webem  gnb_index=${gnb_index}  vdu_index=${vdu_index}
#    [Return]   ${cell_list.__len__()}
#
#
#Get VDU Cplane DSCP Value
#    [Arguments]  ${vdu_index}=0
#    [Documentation]  Get VDU Cplane DSCP Value
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  2.8.2023   chris.l.cao@nokia-sbell.com, ues 'Get VDU Parameter Value Online'
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | para_list  | Yes | key=value pair, scf_path key should be included! please see samples |
#    ...
#    ...    *RETURN VALUE*
#    ...    Return distName list that matched the parameters filter and distName filter. Return type is list.
#    ...
#    ...    Example
#    ...    Get distName according to mixed filter
#    ...    | ${vdu_cplane_dscp} | Get VDU Cplane DSCP Value    |
#    ...
#    ${vdu_conf}  Get VDU Conf From SCF
#    ${nrbts_distname}  Set Variable   MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf["nrbts_id"]}
#    ${value}   Get VDU Parameter Value Online   mo_dn=${nrbts_distname}   para_name=cPlaneDscp
#    [Return]  ${value}
#
#
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


#_Create Xpath Contain List
#    [Arguments]     ${contain_list}    ${para_list}
#    ::For   ${i}   IN   @{para_list}
#    \     Append To List    ${contain_list}    descendant::ns:*[local-name()='p' or local-name()='list']/@name="${i}"
#
#
#vDU Send Commission By RestApi
#    [Arguments]  ${scf_path}    ${vdu_index}=0   ${gnb_index}=0
#    [Documentation]   send commission on one vdu, including upload validate and activate scf
#    ...    *AUTHOR*  calla.wang@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    11.3.2021, calla.wang@nokia-sbell.com, add sleeping after activated plan file to ensure the restapi can be connected
#    ...    10.31.2023, chris.l.cao@nokia-sbell.com, remove restapi_version, add gnb_index
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file, e.g /tmp/scf_file.xml |
#    ...    | vdu_index | No | the index of vdu, default value is 0 |
#    ...    | gnb_index | No | the index of gnb, default value is 0 |
#    ...
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    log to console  \n*** start send commission on vdu ***
#    ${alias}   vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    ${upload_plan_response}=  vdu.upload_plan    ${scf_path}   vdu_connection=${alias}
#    wait until keyword succeeds  2min  5s  Upload Plan Status Should Be Successful  operation_id=${upload_plan_response['action_id']}
#      ...  vdu_connection=${alias}
#    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}    vdu_connection=${alias}
#    wait until keyword succeeds  2min  5s  Validate Plan Status Should Be Successful
#    ...  plan_id=${upload_plan_response['plan_id']}
#    ...  operation_id=${validate_plan_response['action_id']}
#    ...  vdu_connection=${alias}
#    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}  vdu_connection=${alias}
#    sleep  90s
#    wait until keyword succeeds  10min  20s  Activate Plan Operation Should Be Successful
#    ...  ${upload_plan_response['plan_id']}
#    ...  ${activate_plan_response['id']}
#
#
#Activate Plan Operation Should Be Successful
#    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
#    [Documentation]   checking activate plan operation status should be successful
#    ...    *AUTHOR*  calla.wang@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...  23.7.2020,chris.l.cao@nokia-sbell.com, add retry mechanism
#    ...  13.8.2020,chris.l.cao@nokia-sbell.com, extend retry window from 20s to 240s
#    ...  11.3.2021,calla.wang@nokia-sbell.com, restore the previous logic, no need to login vdu once again and nested wait until
#    ...  9.8.2023, rui.3.li@nokia-sbell.com, vdu rest login before get status.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | plan_id | yes | the plan file id, get from upload_plan |
#    ...    | action_id | Yes | the activate action id, get from activate_plan |
#    ...    *RETURN VALUE*
#    ...    None
#    ${alias}   Get Unique Id
#    vDU Rest Login   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${alias}
#    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}   vdu_connection=${alias}
#    should be equal as strings  ${activate_plan_response['status']}  success
#    [Teardown]   Run Keyword And Ignore Error   vDU Rest Logout  vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    ...   alias=${alias}
#
#
#_Upload Plan Status Should Be Expected
#    [Arguments]  ${operation_id}   ${expected_status}   ${vdu_connection}=${None}
#    [Documentation]    Upload Status Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | expected_status | yes | expected_status |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | _Upload Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success |
#    ...
#    ${out}   vdu.Get_Upload_Plan_Operation_Status   operation_id=${operation_id}   vdu_connection=${vdu_connection}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#
#
#Upload Plan Status Should Be Successful
#    [Arguments]  ${operation_id}   ${vdu_connection}=${None}
#    [Documentation]   Upload Plan Status Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> |
#    ...
#     Wait Until Keyword Succeeds  30   3  _Upload Plan Status Should Be Expected   operation_id=${operation_id}    expected_status=success
#       ...   vdu_connection=${vdu_connection}
#
#
#_Validate Plan Status Should Be Expected
#    [Arguments]  ${operation_id}   ${expected_status}   ${plan_id}   ${vdu_connection}=${None}
#    [Documentation]    Validate Plan Status Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | expected_status | yes | expected_status |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${plan_id} | set variable | sp_7bbfbd44-a3ca-4b22-b948-a0c8a6d3716a |
#    ...  | ${out} | vdu.validate_plan | plan_id=${plan_id} |
#    ...  | Validate Plan Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success | plan_id=<my_plan_id> |
#    ...
#
#    ${out}   vdu.Get_Validate_Plan_Operation_Status   operation_id=${operation_id}   plan_id=${plan_id}  vdu_connection=${vdu_connection}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Validate Plan Status Should Be Successful
#    [Arguments]  ${operation_id}   ${plan_id}   ${vdu_connection}=${None}
#    [Documentation]   Validate Plan Status Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Upload Plan Status Should Be Successful | operation_id=<my_operation_id> | plan_id=<my_plan_id> |
#    ...
#    ${rtn}  Wait Until Keyword Succeeds  20   3
#    ...  _Validate Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
#    ...  vdu_connection=${vdu_connection}
#    [Return]  ${rtn}
#
#
#Is Staged Plan Existed
#    [Arguments]  ${plan_name}
#    [Documentation]   Is Staged Plan Existed
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_name    | yes | plan_name |
#    ...
#    ...   *RETURN VALUE*
#    ...    Return (1, <real_plan_id>) if desired plan name exists, otherwise return (0, ${EMPTY})
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${bExsit} | ${plan_id} | Is Staged Plan Existed | plan_name=my_plan_name |
#    ...
#    ${existed}   Set Variable  0
#    ${rtn_plan_id}   Set Test Variable  ${EMPTY}
#    ${all_plans}   vdu.Get_Staged_Plans_Info_List
#    Return From Keyword If  ${all_plans.__len__()}==0   0   ${EMPTY}
#    :FOR   ${one_plan}   IN   @{all_plans}
#    \    ${existed}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   1   0
#    \    ${rtn_plan_id}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   ${one_plan["plan_id"]}  ${EMPTY}
#    \    Exit For Loop If  "${one_plan["plan_name"]}"=="${plan_name}"
#    [Return]    ${existed}    ${rtn_plan_id}
#
#
#Delete Plan
#    [Arguments]  ${plan_name}
#    [Documentation]   Delete Plan. Do nothing if desired plan does not exist.
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_name    | yes | plan_name to be deleted |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | netact.Delete Plan  | plan_name=my_plan_name |
#    ...
#    ${bExsit}   ${to_be_deleted_plan_id}   Is Staged Plan Existed   plan_name=${plan_name}
#    Run Keyword If  ${bExsit}==1   vdu.Delete_Staged_Plan_File   plan_id=${to_be_deleted_plan_id}
#
#
#Check Maximum Plan Number And Delete One If Reach Maximum Number
#    [Arguments]  ${vdu_connection}=${None}
#    [Documentation]   Check Maximum Plan Number And delete one if reach Maximum number
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   None
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Check Maximum Plan Number And delete one if reach Maximum number |
#    ...
#    ${all_plans}   vdu.Get_Staged_Plans_Info_List   vdu_connection=${vdu_connection}
#    Should Be True  ${all_plans.__len__()}<=3
#    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
#    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}    vdu_connection=${vdu_connection}
#
#
#Upload Plan And Validate
#    [Arguments]   ${plan_file}  ${plan_name}  ${plan_description}=${EMPTY}  ${validate}=${True}
#    [Documentation]   Upload Plan and validate
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_file    | yes | plan_file |
#    ...   | plan_name    | yes | plan_name |
#    ...   | plan_description | no | plan_description, default is ${EMPTY} |
#    ...   | validate         | no | validate, if ${True} will do validation, otherwise it will not do validation, default is ${True} |
#    ...
#    ...   *RETURN VALUE*
#    ...    Return (<plan_id>, <action_id>, <validation_id>)
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan and validate | plan_file=/home/ute/scf.xml | plan_name=my_plan_name |
#    ...  | ... | validate=${True} |
#    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan and validate | plan_file=/home/ute/scf.xml | plan_name=my_plan_name |
#    ...  | ... | validate=${False} |
#    ...
#
#    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
#    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
#    ${temp_action_id}   Set Variable  ${out["action_id"]}
#    ${temp_validation_id}   Set Variable  ${EMPTY}
#
#    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
#
#    Return From Keyword If  "${validate}"=="${False}"   ${temp_plan_id}   ${temp_action_id}  ${temp_validation_id}
#
#    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}
#    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}
#
#
#Validate Plan By REST
#    [Arguments]  ${plan_id}   ${retries}=1
#    [Documentation]   Validate Plan By REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    Return validation_id
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${validation_id} | Validate Plan By REST | plan_id=<my_plan_id> |
#    ...
#    :FOR   ${i}   IN RANGE   0   ${retries}
#    \  ${out}  vdu.Validate_Plan   plan_id=${plan_id}
#    \  ${action_id}   Set Variable  ${out["action_id"]}
#    \  ${out}   Validate Plan Status Should Be Successful   operation_id=${action_id}  plan_id=${plan_id}
#    \  ${validation_id}  Set Variable   ${out["validation_id"]}
#    \  sleep   2
#    [Return]   ${validation_id}
#
#
#Upload Plan And Validate And Activate
#    [Arguments]   ${plan_file}  ${plan_name}=TA_Upload_Plan_And_Validate_And_Activate  ${plan_description}=${EMPTY}  ${wait_vdu_up}=${False}
#    ...   ${retries}=1
#    [Documentation]   Upload Plan And Validate And Activate
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...   13.8.2020,chris.l.cao@nokia-sbell.com, add sleep  8 second between validation and activation
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_file    | yes | plan_file |
#    ...   | plan_name    | No | plan_name, default is TA_Upload_Plan_And_Validate_And_Activate |
#    ...   | plan_description | no | plan_description, default is ${EMPTY} |
#    ...   | wait_vdu_up     | no | wait_vdu_up, if ${True} will wait until VDU up, otherwise it will not, default is ${False} |
#    ...
#    ...   *RETURN VALUE*
#    ...    Return <plan_id>   <action_id>    <validation_id>
#    ...
#    ...   Example
#    ...  | vdu rest login |
#   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
#   ...  | ... | wait_vdu_up=${True} |
#   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
#   ...  | ... | wait_vdu_up=${False} |
#    ...
#    log to console  Upload Plan And Validate And Activate
#    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
#    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
#    ${temp_action_id}   Set Variable  ${out["action_id"]}
#    ${temp_validation_id}   Set Variable  ${EMPTY}
#
#    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
#    sleep   2
#    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}   retries=${retries}
#    sleep   2
#    ${out}   Activate Staged Plan By REST   plan_id=${temp_plan_id}
#    run keyword if  "${wait_vdu_up}"=="${True}"   sleep   8
#    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  30   OAM Precondition Cell Should Be Onair
#
#    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}
#
#
#Vdu Pre Activate For Staged Plan
#    [Arguments]   ${plan_id}
#    [Documentation]   Vdu Pre Activate For Staged Plan
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    Information of pre-activated staged plan
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${scf} | set variable | /temp/Configuration_scf_vDU_MVP5238.xml |
#    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate | plan_file=${scf} | plan_name=my_plan_name | validate=${True} |
#    ...  | ${out}    | Vdu Pre Activate For Staged Plan | plan_id=${plan_id} |
#    ...  | ${out}    | Vdu Activate Pre Activated Staged Plan | plan_id=${out["plan_id"]} |
#    ...
#
#    ${out}  vdu.vdu_pre_activate_for_staged_plan   plan_id=${plan_id}
#    ${operation_id}   Set Variable  ${out["id"]}
#    ${out}  Pre Activate For Staged Plan Status Should Be Successful   plan_id=${plan_id}   operation_id=${operation_id}
#
#    [Return]   ${out}
#
#
#Pre Activate For Staged Plan Status Should Be Successful
#    [Arguments]  ${plan_id}  ${operation_id}
#    [Documentation]   Pre Activate For Staged Plan Status Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    Information while pre-activating staged plan
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Pre Activate For Staged Plan Status Should Be Successful | plan_id=<plan_id> | operation_id=<my_operation_id> |
#    ...
#    ${out}   Wait Until Keyword Succeeds  10   3
#     ...   _Pre Activate For Staged Plan Status Should Be Expected    plan_id=${plan_id}   operation_id=${operation_id}   expected_status=success
#    [Return]  ${out}
#
#
#_Pre Activate For Staged Plan Status Should Be Expected
#    [Arguments]  ${plan_id}   ${operation_id}   ${expected_status}
#    [Documentation]    _Pre Activate For Staged Plan Status Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id          | yes | plan_id |
#    ...   | operation_id    | yes | operation_id |
#    ...   | expected_status | yes | expected_status |
#    ...
#    ...   *RETURN VALUE*
#    ...    Information while pre-activating staged plan
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | _Pre Activate For Staged Plan Status Should Be Expected | plan_id=<plan_id> | operation_id=<operation_id> | expected_status=success |
#    ...
#    ${out}   vdu.vdu_get_pre_activate_operation_status_for_staged_plan    plan_id=${plan_id}  operation_id=${operation_id}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Update Staged Plan Parameter
#    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
#    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...   | mo_dn      | yes | mo_dn   |
#    ...   | updated_paras_dict | yes | updated_paras_dict   |
#    ...   | operation          | no | operation: add, replace, remove, revert   |
#    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
#    ...   | timeout           | no | timeout, default is 30, unit is second   |
#    ...
#    ...   *RETURN VALUE*
#    ...    status dictionary of operation, its content as below,
#    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
#    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 |
#    ...  | ${validation_id} | Update Staged Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
#    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
#    ...  | ${validation_id} | Update Staged Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
#    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.update_vdu_parameter_of_staged_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
#     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}
#
#    ${action_id}  set variable  ${out["action_id"]}
#    ${out}   Update Staged Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
#    [Return]  ${out}
#
#
#Update Staged Plan Parameter Should Be Successful
#    [Arguments]  ${plan_id}   ${action_id}
#    [Documentation]   Update Staged Plan Parameter Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Update Staged Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
#    ...
#    ${rtn}   wait until keyword succeeds  20   2   _Update Staged Plan Parameter Should Be Expected
#     ...   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
#    [Return]  ${rtn}
#
#
#_Update Staged Plan Parameter Should Be Expected
#    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
#    [Documentation]    _Update Staged Plan Parameter Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | expected_status | yes | expected_status |
#    ...   | plan_id         | yes | plan_id |
#    ...   | action_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
#    ...
#
#    ${out}   vdu.get_update_paras_action_status_of_staged_plan      plan_id=${plan_id}  action_id=${action_id}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Delete Staged Plan MO
#    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=30
#    [Documentation]   Delete Staged Plan MO
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...   | mo_dn      | yes | mo_dn   |
#    ...   | timeout    | no | timeout, default is 30, unit is second   |
#    ...
#    ...   *RETURN VALUE*
#    ...    status dictionary of operation, its content as below,
#    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
#    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${validation_id} | Delete Staged Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.delete_mo_of_staged_plan   staged_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
#    ${action_id}  set variable  ${out["action_id"]}
#    ${out}     Delete Staged Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
#    [Return]  ${out}
#
#
#Delete Staged Plan MO Should Be Successful
#    [Arguments]  ${plan_id}   ${action_id}
#    [Documentation]   Delete Staged Plan MO Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Delete Staged Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
#    ...
#    ${rtn}  wait until keyword succeeds  20   2
#    ...   _Delete Staged Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
#    [Return]  ${rtn}
#
#
#_Delete Staged Plan MO Should Be Expected
#    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
#    [Documentation]    _Delete Staged Plan MO Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | expected_status | yes | expected_status |
#    ...   | plan_id         | yes | plan_id |
#    ...   | action_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | _Delete Staged Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
#    ...
#
#    ${out}   vdu.get_deleting_mo_action_state_of_staged_plan      staged_plan_id=${plan_id}  action_id=${action_id}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#
#
#Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    [Arguments]   ${alias}=${None}
#    [Documentation]   Check Maximum Delta Plan Number And delete one if reach Maximum number
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  11.29.2023   chris.l.cao@nokia-sbell.com,  add alias parameter
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   None
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | ${alias}  VDU Rest Login |
#    ...  | Check Maximum Delta Plan Number And delete one if reach Maximum number | alias=${alias} |
#    ...
#    ${all_plans}   vdu.Get_Delta_Plan_Info_List  vdu_connection=${alias}
#    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}  alias=${alias}
#
#
#Generate Delta Plan
#    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}   ${alias}=${None}
#    [Documentation]   Generate Delta Plan
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  11.29.2023   chris.l.cao@nokia-sbell.com,  add alias parameter
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_name    | yes | plan_name |
#    ...   | plan_description | no | plan_description, default is ${EMPTY} |
#    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
#    ...
#    ...   *RETURN VALUE*
#    ...    Return (<plan_id>, <action_id>)
#    ...
#    ...   Example
#    ...  | ${alias} | VDU Rest Login |
#    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=my_plan_name |  alias=${alias} |
#    ...
#    run keyword if  "${delete_old_one}"=="${True}"   Check Maximum Delta Plan Number And Delete One If Reach Maximum Number  alias=${alias}
#
#    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}  vdu_connection=${alias}
#
#    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
#    ${temp_action_id}   Set Variable  ${out["action_id"]}
#
#    Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}   alias=${alias}
#    [Return]   ${temp_plan_id}   ${temp_action_id}
#
#
#_Generate Delta Plan Status Should Be Expected
#    [Arguments]  ${action_id}   ${expected_status}   ${alias}=${None}
#    [Documentation]   _Generate Delta Status Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | action_id       | yes | operation_id |
#    ...   | expected_status | yes | expected_status |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | _Upload Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
#    ...
#    ${out}   vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}   vdu_connection=${alias}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#
#
#Generate Delta Plan Status Should Be Successful
#    [Arguments]  ${action_id}   ${alias}=${None}
#    [Documentation]   Generate Delta Plan Status Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | action_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Generate Delta Plan Status Should Be Successful | action_id=<my_action_id> |
#    ...
#    Wait Until Keyword Succeeds  30   3  _Generate Delta Plan Status Should Be Expected   action_id=${action_id}    expected_status=success
#    ...    alias=${alias}
#
#Update Delta Plan Parameter
#    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30   ${alias}=${None}
#    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...   | mo_dn      | yes | mo_dn   |
#    ...   | updated_paras_dict | yes | updated_paras_dict   |
#    ...   | operation          | no | operation: add, replace, remove, revert   |
#    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
#    ...   | timeout           | no | timeout, default is 30, unit is second   |
#    ...
#    ...   *RETURN VALUE*
#    ...    status dictionary of operation, its content as below,
#    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
#    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
#    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
#    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
#    ...
#    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
#    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
#     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}  vdu_connection=${alias}
#
#    ${action_id}  set variable  ${out["action_id"]}
#    ${out}    Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}  alias=${alias}
#    [Return]  ${out}
#
#
#Update Delta Plan Parameter Should Be Successful
#    [Arguments]  ${plan_id}   ${action_id}  ${alias}=${None}
#    [Documentation]   Update Delta Plan Parameter Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
#    ...
#    ${rtn}  wait until keyword succeeds  20   2
#    ...   _Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
#    ...   alias=${alias}
#    [Return]  ${rtn}
#
#
#_Update Delta Plan Parameter Should Be Expected
#    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}    ${alias}=${None}
#    [Documentation]    _Update Delta Plan Parameter Should Be Expected
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | expected_status | yes | expected_status |
#    ...   | plan_id         | yes | plan_id |
#    ...   | action_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
#    ...
#
#    ${out}   vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}   vdu_connection=${alias}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#_Validate Delta Plan Status Should Be Expected
#    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}  ${alias}=${None}
#    ${out}   vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}    vdu_connection=${alias}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Validate Delta Plan Status Should Be Successful
#    [Arguments]  ${action_id}   ${plan_id}   ${alias}=${None}
#    [Documentation]   Validate Delta Plan Status Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
#    ...
#    ${rtn}  Wait Until Keyword Succeeds  20   2
#     ...   _Validate Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
#     ...   alias=${alias}
#    [Return]  ${rtn}
#
#
#Validate Delta Plan By REST
#    [Arguments]  ${plan_id}    ${alias}=${None}
#    [Documentation]   Validate Delta Plan By REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  11.29.2023   chris.l.cao@nokia-sbell.com,  add alias parameter to support mulitple vdu
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...   | alias    | No | alias, default is ${None} |
#    ...
#    ...   *RETURN VALUE*
#    ...    Return validation_id
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Check Maximum Delta Plan Number And Delete One If Reach Maximum Number |
#    ...  | ${delta_plan_name} | get unique id | prefix=TA_delta_plan | precise=LOW |
#    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=${delta_plan_name} | plan_description=TA |
#    ...  | ${TCE_Info_1} | create dictionary | tceIpAddress=1.1.1.1 | tcePortNumber=5000 |
#    ...  | ${mo} | set variable | MRBTS-5200/MNL-1/TCEADM-1/TCE-1 |
#    ...  | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${mo} | updated_paras_dict=${TCE_Info_1} | operation=add |
#    ...  |  ${validation_id} | Validate Delta Plan By REST | plan_id=${planid} |
#    ...  | Activate Delta Plan By REST | ${plan_id} | wait_vdu_up=${True} |
#    ...
#
#    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}    vdu_connection=${alias}
#    ${action_id}   Set Variable  ${out["action_id"]}
#    ${out}    Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}   alias=${alias}
#    ${validation_id}  Set Variable   ${out["validation_id"]}
#    [Return]   ${validation_id}
#
#
#
#_Activate Delta Plan Status Should Be Expected
#    [Arguments]  ${operation_id}    ${plan_id}   ${expected_status}   ${alias}=${None}
#    ${out}   vdu.Get_Activate_Delta_Plan_Operation_Status   operation_id=${operation_id}   delta_plan_id=${plan_id}    vdu_connection=${alias}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Activate Delta Plan Status Should Be Successful
#    [Arguments]  ${operation_id}   ${plan_id}    ${alias}=${None}
#    [Documentation]   Activate Delta Plan Status Should Be Successful
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    2.8.2023,chris.l.cao@nokia-sbell.com, change timeout value from 900 to 300
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    dictionary contains result
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Activate Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
#    ...
#    ${rtn}   Wait until keyword succeeds  300  30s
#     ...   _Activate Delta Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
#     ...   alias=${alias}
#    [Return]  ${rtn}
#
#
#Activate Delta Plan By REST
#    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${wait_vdu_up}=${False}   ${timeout}=60   ${alias}=${None}
#    [Documentation]   Activate Delta Plan By REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters | Man. | Description |
#    ...   | plan_id          | yes | delta plan id |
#    ...   | force_reset      | no | default is ${True} |
#    ...   | auto_lock_cells  | no | default is ${True} |
#    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
#    ...   | timeout          | no | default is 60 (seconds) |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example of changing btsName
#    ...   | VDU Rest Login |
#    ...   | ${VDU_CONF} | Get VDU Conf From SCF |
#    ...   | ${plan_id} |  ${action_id}  | Generate Delta Plan |  plan_name=changeBTSName |
#    ...   | ${distname} |  Set Variable | MRBTS-${VDU_CONF["mrbts_id"]} |
#    ...   | ${para_dict} | create dictionary |   btsName=btsName_new |
#    ...   | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${distname} | updated_paras_dict=${para_dict} | operation=replace |
#    ...   | Validate Delta Plan By REST |  ${plan_id} |
#    ...   | Activate Delta Plan By REST |  ${plan_id} |
#    ...   | VDU Rest Logout |
#    ...
#    ${temp_path}  Get A Directory  delta_plan
#    ${tmp_file_id}   get unique id  precise=LOW
#    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${temp_path}   local_filename=${tmp_file_id}.xml   vdu_connection=${alias}
#    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
#     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    vdu_connection=${alias}
#    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}   alias=${alias}
#    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  20   OAM Precondition Cell Should Be Onair
#
#
#Activate Delta Plan By REST Without Wait VDU Up
#    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${timeout}=60
#    [Documentation]   Activate Delta Plan By REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...
#    ...  Change History
#    ...  2.12.2021   chris.l.cao@nokia-sbell.com,  add this KW to shorten dryrun time
#    ...
#    ...   | Input Parameters | Man. | Description |
#    ...   | plan_id          | yes | delta plan id |
#    ...   | force_reset      | no | default is ${True} |
#    ...   | auto_lock_cells  | no | default is ${True} |
#    ...   | timeout          | no | default is 60 (seconds) |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example of changing btsName
#    ...   | VDU Rest Login |
#    ...   | ${VDU_CONF} | Get VDU Conf From SCF |
#    ...   | ${plan_id} |  ${action_id}  | Generate Delta Plan |  plan_name=changeBTSName |
#    ...   | ${distname} |  Set Variable | MRBTS-${VDU_CONF["mrbts_id"]} |
#    ...   | ${para_dict} | create dictionary |   btsName=btsName_new |
#    ...   | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${distname} | updated_paras_dict=${para_dict} | operation=replace |
#    ...   | Validate Delta Plan By REST |  ${plan_id} |
#    ...   | Activate Delta Plan By REST |  ${plan_id} |
#    ...   | VDU Rest Logout |
#    ...
#    ${temp_path}  Get A Directory  delta_plan
#    ${tmp_file_id}   get unique id  precise=LOW
#    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${temp_path}   local_filename=${tmp_file_id}.xml
#    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
#     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
#    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#
#
#Delete Delta Plan By Plan Id
#    [Arguments]  ${plan_id}  ${alias}=${None}
#    [Documentation]   Delete Delta Plan By Plan Id
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id             | yes | delta plan id |
#    ...   | force_reset       | no | default is ${True} |
#    ...   | auto_lock_cells   | no | default is ${True} |
#    ...   | timeout           | no | default is 60 (seconds) |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...   | VDU Rest Login |
#    ...   | Delete Delta Plan By Plan Id | plan_id=my_plan_id |
#    ...   | VDU Rest Logout |
#    ...
#    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}  vdu_connection=${alias}
#    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once  alias=${alias}
#
#
#_Make Sure Delta Plan Is Deleted Once
#    [Arguments]  ${alias}=${None}
#    ${all_plans}   vdu.Get_Delta_Plan_Info_List  vdu_connection=${alias}
#    Should Be True  ${all_plans.__len__()}==0
#
#
#VDU Online Change Parameters By Delta Plan REST
#    [Arguments]     ${mo_dn}=${EMPTY}   ${updated_paras_list}=${EMPTY}   ${operation}=replace   ${activate}=${True}
#    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
#    [Documentation]   VDU Online Change Parameters By Delta Plan REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...  Change History
#    ...  2.12.2021  chris.l.cao@nokia-sbell.com,  add this KW to shorten dryrun time
#    ...  1.3.2021   rifeng@nokia-sbell.com, add argument wait_vdu_up to wait vdu onair for parameter need reset vdu
#    ...  14.2.2022  chris@nokia-sbell.com, support multiple MO
#    ...   22.11.2023  calla.wang2nokia-sbell.com, logging validation error after validating delta plan.
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
#    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
#    ...   |                      |     | {'f1Cplane/0/ipV4AddressDN1':'MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', 'para2':'value2'} |
#    ...   | operation           | no |  the operation - add, replace, remove, revert. The default is replace |
#    ...   | activate           | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
#    ...   | force_reset       | no | default is ${True} |
#    ...   | auto_lock_cells   | no | default is ${True} |
#    ...   | wait_vdu_up       | no | default is ${False} |
#    ...   | timeout           | no | default is 60 (seconds) |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...   | VDU Rest Login |
#    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
#    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
#    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
#    ...
#    ...   | ${added_dict1} | Create Dictionary | btsName=btsName1 | mo_dn=MRBTS-123 | operation=replace |
#    ...   | ${added_dict2} | Create Dictionary | ipNodeStatisticsInterval=30min | mo_dn=MRBTS-123/TNLSVC-1/PMTNLINT-1 | operation=replace |
#    ...   | ${mo_dict_list} | Create List | ${added_dict1} | ${added_dict2} |
#    ...   | VDU Online Change Parameters By Delta Plan REST | updated_paras_list=${mo_dict_list} | activate=${True} |
#    ...   | VDU Rest Logout |
#    ...
#    ...   Without activate it:
#    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#
#    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA
#
#    ${out}  Run Keyword If  "${mo_dn}"!="${EMPTY}"
#        ...   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}
#        ...   ELSE   _VDU Online Change Parameters By Delta Plan REST Multiple MO   plan_id=${planid}   updated_paras_list=${updated_paras_list}
#
#    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
#
#    Logging vDU Delta Plan Validation Error   plan_id=${planid}  validation_id=${validation_id}
#
#    run keyword if    "${activate}"=="${True}"
#    ...    Activate Delta Plan By REST  plan_id=${plan_id}   force_reset=${force_reset}
#    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    wait_vdu_up=${wait_vdu_up}
#
#Logging vDU Delta Plan Validation Error
#  [Arguments]  ${plan_id}  ${validation_id}
#  ${validation_result}   vdu.get_delta_plan_validation_results   plan_id=${plan_id}  validation_id=${validation_id}
#  log dictionary   ${validation_result}
#
#_VDU Online Change Parameters By Delta Plan REST Multiple MO
#    [Arguments]  ${plan_id}   ${updated_paras_list}
#    ${mo_number}  Get Length   ${updated_paras_list}
#    :FOR   ${one_mo_dict}   IN   @{updated_paras_list}
#    \    ${updated_paras_dict}  Copy Dictionary  ${one_mo_dict}
#    \    ${r}  ${operation}   Run Keyword And Ignore Error   Get From Dictionary  ${updated_paras_dict}   operation
#    \    ${operation}  Set Variable If   "${r}"=="PASS"   ${operation}   replace
#    \    Run Keyword If   "${r}"=="PASS"   Remove From Dictionary   ${updated_paras_dict}   operation
#
#    \    ${mo_dn}  Get From Dictionary  ${updated_paras_dict}   mo_dn
#    \    Remove From Dictionary   ${updated_paras_dict}   mo_dn
#
#    \    Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_dict}   operation=${operation}
#
#
#VDU Online Change Parameters By Delta Plan REST Without Wait VDU Up
#    [Arguments]     ${mo_dn}   ${updated_paras_list}   ${operation}=replace   ${activate}=${True}
#    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}     ${timeout}=60
#    [Documentation]   VDU Online Change Parameters By Delta Plan REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...
#    ...  Change History
#    ...  2.12.2021   chris.l.cao@nokia-sbell.com,  add this KW to shorten dryrun time
#    ...
#    ...    modified by:   <1-Mar-2021>, <rifeng>, <e.g. add argument wait_vdu_up to wait vdu onair for parameter need reset vdu>
#    ...   | Input Parameters    | Man. | Description |
#    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
#    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
#    ...   |                      |     | {'f1Cplane/0/ipV4AddressDN1':'MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', 'para2':'value2'} |
#    ...   | operation           | no |  the operation - add, replace, remove, revert. The default is replace |
#    ...   | activate           | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
#    ...   | force_reset       | no | default is ${True} |
#    ...   | auto_lock_cells   | no | default is ${True} |
#    ...   | timeout           | no | default is 60 (seconds) |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...   | VDU Rest Login |
#    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
#    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
#    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
#    ...   | VDU Rest Logout |
#    ...
#    ...   Without activate it:
#    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#
#    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA
#
#    ${out}   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}
#
#    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}
#
#    run keyword if    "${activate}"=="${True}"
#    ...   Activate Delta Plan By REST Without Wait VDU Up   plan_id=${plan_id}   force_reset=${force_reset}
#    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
#
#
#Activate Staged Plan By REST
#    [Arguments]  ${plan_id}
#    [Documentation]   Activate Delta Plan By REST
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id             | yes | delta plan id |
#    ...   | force_reset       | no | default is ${True} |
#    ...   | auto_lock_cells   | no | default is ${True} |
#    ...   | timeout           | no | default is 60 (seconds) |
#    ...
#    ...   *RETURN VALUE*
#    ...    Activate plan operation information.
#    ...
#    ...   Example
#    ...   | VDU Rest Login |
#    ...   | Activate Staged Plan By REST | plan_id=my_plan_id |
#    ...   | VDU Rest Logout |
#    ...
#    ${out}   vdu.activate_plan   plan_id=${plan_id}
#    ${action_id}  set variable   ${out['id']}
#
#    ${out}   Activate Plan Operation Should Be Successful With Retry   action_id=${action_id}   plan_id=${plan_id}
#    [Return]  ${out}
#
#
#Activate Plan Operation Should Be Successful With Retry
#    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
#    [Documentation]   checking activate plan operation status should be successful
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | plan_id | yes | the plan file id, get from upload_plan |
#    ...    | action_id | Yes | the activate action id, get from activate_plan |
#    ...    *RETURN VALUE*
#    ...    None
#    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
#    ${rtn}  Wait Until Keyword Succeeds  900   30
#     ...   _Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
#     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    [Return]  ${rtn}
#
#
#_Activate Plan Operation Status Should Be Expected
#    [Arguments]   ${plan_id}  ${operation_id}   ${expected_status}   ${vdu_index}=0   ${gnb_index}=0
#    #vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
#    #${out}   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
#    #Should Be True  "${out["status"]}"=="${expected_status}"
#
#    ${r}  ${out}   run keyword and ignore error   vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
#    should be true    "${r}"=="PASS"
#    return from keyword if   "${r}"!="PASS"
#
#    ${r}  ${out}   run keyword and ignore error
#       ...   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
#    should be true    "${r}"=="PASS"
#
#    Should Be True    "${out["status"]}"=="${expected_status}"
#
#    [Return]  ${out}
#
#
#Full Commission SCF On VDU
#    [Arguments]  ${scf_file}=${EMPTY}    ${wait_vdu_up}=${False}  ${webem_password}=${Empty}
#    [Documentation]   Full Commission SCF On VDU
#    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...   31.07.2020,chris.l.cao@nokia-sbell.com, initialize version
#    ...   17.06.2021,chris.l.cao@nokia-sbell.com, change according to no scf file in S3 server
#    ...   19.10.2023, calla.wang@nokia-sbell.com, add an optional parameter webem_password to support changing default password after deployment
#    ...
#    ...   | Input Parameters   | Man. | Description |
#    ...   | scf_file | no | scf_file  |
#    ...   | build_number | no | build_number |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...   | Full Commission SCF On VDU | scf_file=/tmp/myscf.xml |
#    ...   | Full Commission SCF On VDU | scf_file=/tmp/myscf.xml | wait_vdu_up=${True} |
#    ...
#    log to console  Full Commission SCF On VDU
#
#    should be true  ${scf_file.__len__()>0}
#
#    VDU Rest Login  password=${webem_password}
#    Check Maximum Plan Number And Delete One If Reach Maximum Number
#
#    ${plan_name}  Get Unique Id  prefix=full_commission_
#    ${out}  Upload Plan And Validate And Activate  plan_file=${scf_file}   plan_name=${plan_name}  wait_vdu_up=${wait_vdu_up}
#
#
#_Get Modified List Parameter Value
#    [Arguments]   ${xml_node}   ${action}   ${dict_keys}  ${dict_para}
#    #${dict_keys}  ${dict_para}   _Create Dictionary From List Parameter Precisely   @{para_list}
#
#    ${action}   Set Variable   ${action.lower()}
#    ${current_list_content}   Run Keyword If  '${action}'=='add'  _Get Modified List Parameter Value Add   ${xml_node}   ${dict_keys}  ${dict_para}
#    ...   ELSE IF  '${action}'=='update'  _Get Modified List Parameter Value Update   ${xml_node}    ${dict_keys}   ${dict_para}
#    ...   ELSE IF  '${action}'=='delete'  _Get Modified List Parameter Value Delete   ${xml_node}    ${dict_keys}   ${dict_para}
#    ...   ELSE   Fail    action should be add, update or delete!
#    [Return]   ${current_list_content}
#
#
#_Get Modified List Parameter Value Add
#    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
#    ${res}   XML.Element To String  ${xml_node}
#
#    :FOR   ${item}  IN  @{dict_keys}
#    \    ${res}   Replace String Using Regexp   ${res}   <item>    <item><p name="${item}">${dict_para["${item}"]}</p>    count=1
#
#    [Return]  ${res}
#
#
#_Get Modified List Parameter Value Update
#    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
#    ${res}   XML.Element To String  ${xml_node}
#    ${res}   Prehandle XML Content   ${res}
#
#    ${new_content}   Set Variable  ${EMPTY}
#    :FOR   ${item}  IN  @{dict_keys}
#    \   ${new_content}    Set Variable   ${new_content}<p name="${item}">${dict_para["${item}"]}</p>
#
#    ${new_content}    Set Variable   <item>${new_content}</item>
#    ${res}   Replace_String_With_Regexp   content=${res}
#    ...   g1_regexp=\<list\\s+name=\\S+\>
#    ...   g2_regexp=.*
#    ...   g3_regexp=\</list\>
#    ...   g2_new_value=${new_content}
#
#    [Return]  ${res}
#
#
#_Get Modified List Parameter Value Delete
#    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
#    ${res}   XML.Element To String  ${xml_node}
#    ${res}   Prehandle XML Content  ${res}
#
#    :FOR   ${item}  IN  @{dict_keys}
#    \   ${res}  Run Keyword If   "${item}" in """${res}"""   Replace String Using Regexp   ${res}   <p\\s+name="${item}">.*?</p>    ${EMPTY}
#       ...    ELSE   set variable   ${res}
#
#    [Return]  ${res}
#
#
#
#Prehandle XML Content
#    [Arguments]  ${xml_content}
#    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | xml_content      | Yes | content with xmlns="raml21.xsd"  |
#    ...
#    ...    *RETURN VALUE*
#    ...    Return content without xmlns="raml21.xsd"
#    ...
#    ...    Example
#    ...    | ${res} | XML.Element To String     | ${xml_handler} |
#    ...    | ${res} | Prehandle XML Content | ${res}    |
#    ...
#    ${xml_content}  Replace String  ${xml_content}  xmlns="raml21.xsd"  ${EMPTY}
#    [Return]   ${xml_content}
#
#
#Recommission vDU with new SCF
#    [Arguments]   ${scf_file}  ${vdu_index}=0  ${gnb_index}=0
#    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
#    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
#    ...  Change History
#    ...  2023.10.31  chris.l.cao@nokia-sbell.com, rename SCF to scf_file, add vdu_index and gnb_index,
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | scf_file        | Yes | scf file, eg. /tmp/myscf.xml |
#    ...   | vdu_index | No | the index of vdu, default value is 0 |
#    ...   | gnb_index | No | the index of gnb, default value is 0 |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...   | Recommission vDU with new SCF | scf_file=/tmp/my_NEW_SCF.xml |
#    ...
#    ${alias}   Vdu Rest Login    vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    Check Maximum Plan Number And Delete One If Reach Maximum Number   vdu_connection=${alias}
#    vDU Send Commission By RestApi    scf_path=${scf_file}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
#
#
#Add Delta Plan MO
#    [Arguments]  ${plan_id}   ${parent_mo_dn}=${EMPTY}   ${mo_name}=${EMPTY}    ${timeout}=60
#    [Documentation]   Add Delta Plan MO
#    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...   It can be used together with 'Update Delta Plan Parameter' to add new MO on delta plan, under this conditio,
#    ...   'Update Delta Plan Parameter' operation should be set to 'add'.
#    ...  Change History
#    ...  2023.12.08  chris.l.cao@nokia-sbell.com, we need not give parent_mo_dn(we can fetch it from mo_name)
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...   | parent_mo_dn | yes | parent_mo_dn   |
#    ...   | mo_name | yes | mo_name   |
#    ...   | timeout    | no | timeout, default is 60, unit is second   |
#    ...
#    ...   *RETURN VALUE*
#    ...    status dictionary of operation, its content as below,
#    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
#    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${validation_id} | Add Delta Plan MO | plan_id=<my_plan_id> | mo_name=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1 |
#    ...  | ${validation_id} | Add Delta Plan MO | plan_id=<my_plan_id> | parent_mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1 | mo_name=PINGREQ-1 |
#    ...
#    Should Not Be Empty   ${mo_name}
#    ${mo_info}     Run Keyword If  "${parent_mo_dn}"=="${EMPTY}"   Split String From Right  ${mo_name}   separator=/  max_split=1
#    ${parent_mo_dn_new}  Set Variable If  "${parent_mo_dn}"=="${EMPTY}"   ${mo_info[0]}  ${parent_mo_dn}
#    ${mo_name_new}       Set Variable If  "${parent_mo_dn}"=="${EMPTY}"   ${mo_info[1]}  ${mo_name}
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.create_vdu_object_of_delta_plan   delta_plan_id=${plan_id}  parent_mo_dn=${parent_mo_dn_new}   mo_name=${mo_name_new}
#          ...    timeout=${timeout}
#    ${action_id}  Set Variable  ${out["action_id"]}
#    ${out}     Add Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
#    [Return]  ${out}
#
#
#Add Delta Plan MO Should Be Successful
#    [Arguments]  ${plan_id}   ${action_id}
#    [Documentation]   Add Delta Plan MO Should Be Successful
#    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Add Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
#    ...
#    ${rtn}  wait until keyword succeeds  20   2
#    ...   _Add Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
#    [Return]  ${rtn}
#
#
#_Add Delta Plan MO Should Be Expected
#    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
#    [Documentation]    _Add Delta Plan MO Should Be Expected
#    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | expected_status | yes | expected_status |
#    ...   | plan_id         | yes | plan_id |
#    ...   | action_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
#    ...
#    ${out}   vdu.get_create_vdu_object_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Delete Delta Plan MO
#    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=60   ${alias}=${None}
#    [Documentation]   Delete Delta Plan MO
#    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | plan_id    | yes | plan_id |
#    ...   | mo_dn      | yes | mo_dn   |
#    ...   | timeout    | no | timeout, default is 60, unit is second   |
#    ...
#    ...   *RETURN VALUE*
#    ...    status dictionary of operation, its content as below,
#    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
#    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | ${validation_id} | Delete Delta Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1 |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.delete_mo_of_delta_plan   delta_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}   vdu_connection=${alias}
#    ${action_id}  set variable  ${out["action_id"]}
#    ${out}     Delete Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}   alias=${alias}
#    [Return]  ${out}
#
#
#Delete Delta Plan MO Should Be Successful
#    [Arguments]  ${plan_id}   ${action_id}   ${alias}=${None}
#    [Documentation]   Delete Delta Plan MO Should Be Successful
#    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | operation_id    | yes | operation_id |
#    ...   | plan_id         | yes | plan_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | Delete Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
#    ...
#    ${rtn}  wait until keyword succeeds  20   2
#    ...   _Delete Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success  alias=${alias}
#    [Return]  ${rtn}
#
#
#_Delete Delta Plan MO Should Be Expected
#    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}   ${alias}=${None}
#    [Documentation]    _Delete Delta Plan MO Should Be Expected
#    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | expected_status | yes | expected_status |
#    ...   | plan_id         | yes | plan_id |
#    ...   | action_id    | yes | action_id |
#    ...
#    ...   *RETURN VALUE*
#    ...    None
#    ...
#    ...   Example
#    ...  | vdu rest login |
#    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
#    ...
#    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan      delta_plan_id=${plan_id}  action_id=${action_id}   vdu_connection=${alias}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Get VDU Parameter Value Online
#    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60   ${vdu_connection}=${None}
#    [Documentation]   Get VDU Parameter Value Online
#    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
#    ...    If the searched parameter is under list/item, please set the para_name with something like 'list_name/item_number/parameter_name'
#    ...  Change History
#    ...  2023.7.1  chris.l.cao@nokia-sbell.com, add vdu_connection parameter
#    ...
#    ...    *Argument Description*
#    ...    | Input Parameters    | Man. | Description |
#    ...    | mo_dn     | yes | the distname of given parameter |
#    ...    | para_name | yes | parameter name   |
#    ...    | timeout   | no | timeout, default is 60, unit is second   |
#    ...
#    ...    *RETURN VALUE*
#    ...    the parameter value getting from current plan
#    ...
#    ...   *Example*
#    ...   | vdu rest login |
#    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1/PINGRES-1 | para_name=packetsLost |
#    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/IPRT-1 | para_name=staticRoutes/0/gateway |
#    ...
#    ...   | ${alias} | vdu rest login | gnb_index=0 | vdu_index=1 |
#    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${alias} |
#    ...
#    ...   | ${alias} | vdu rest login | gnb_index=1 | vdu_index=1 |
#    ...   | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233 | para_name=btsName | vdu_connection=${alias} |
#    ...
#    ...  | ${mo}          | Set Variable | MRBTS-1234/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1 |
#    ...  | ${list_name}   | Set Variable | acceptedClockClass |
#    ...  | VDU Rest Login |
#    ...  | ${value}       | Get VDU Parameter Value Online | mo_dn=${mo} | para_name=acceptedClockClass |
#    ...
#    ${timeout}   convert to integer  ${timeout}
#    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}  vdu_connection=${vdu_connection}
#    [Return]  ${out}
#
#
#vDU Modify Parameters Online After Checking Without Wait VDU Up
#    [Arguments]    ${para_list}   ${value_list}   ${mo}    ${vdu_index}=0
#    [Documentation]   vDU Modify Parameters Online After Checking
#    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
#    ...  Change History
#    ...  2021.12.02  chris.l.cao@nokia-sbell.com, It's used by 'Aic Common Setup' only to speed up dryrun
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | para_list    | yes | the names of parameters list |
#    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
#    ...   and the parameter name|
#    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
#    ...
#    ...   *RETURN VALUE*
#    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
#    ...   | status    | yes | if it is the same between the expect value  and the value in testlilne |
#    ...
#    ...   Example
#    ...  | ${origin_para_value_dict}    ${status}=    vDU Modify Parameters Online After Checking |
#    ...   para_list=${para_list}    value_list=${value_list}    mo=${mo} |
#
#    log to console    DU modify parameters online
#    ${origin_para_value_dict}=    Get Current Parameters Dict    ${para_list}    ${mo}    ${vdu_index}
#    ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict   ${para_list}  ${value_list}
#    ${status}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${Updated_Paras_Dict}
#    vDU Rest Login    vdu_index=${vdu_index}
#    run keyword if     "${status}"== "${False}"    VDU Online Change Parameters By Delta Plan REST Without Wait VDU Up
#    ...    mo_dn=${mo}    updated_paras_list=${Updated_Paras_Dict}
#    [Return]    ${origin_para_value_dict}    ${status}
#    [Teardown]  VDU Rest Logout    ${vdu_index}
#
#
#Get Current Parameters Dict
#    [Arguments]   ${para_list}    ${mo}    ${vdu_index}=0
#    [Documentation]   Get Current Parameters Dict
#    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
#    ...  Change History
#    ...  2021.07.11   Ren Shubin   If para is no exist in MO, will set as NULL.
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | para_list    | yes | the names of parameters list |
#    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
#    ...
#    ...   *RETURN VALUE*
#    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
#    ...
#    ...   Example
#    ...  | ${origin_para_value_dict}=    Get Current Parameters Dict |
#    ...   para_list=${para_list}    mo=${mo} |
#    ...
#    ${origin_para_value_dict}   create dictionary
#    vDU Rest Login    vdu_index=${vdu_index}
#    ${length}=    get length    ${para_list}
#    :FOR    ${i}    IN RANGE    0     ${length}
#    \    ${status}  ${value}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${mo}  ${para_list[${i}]}
#    \    ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${null}
#    \    Set to Dictionary  ${origin_para_value_dict}  ${para_list[${i}]}   ${value_current}
#    [Return]  &{origin_para_value_dict}
#
#
#Convert Updating Parameters From List To Dict
#    [Arguments]   ${para_name_list}   ${values_list}
#    [Documentation]   Convert Updating Parameters From List To Dict
#    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
#    ...   | Input Parameters    | Man. | Description |
#    ...   | para_name_list    | yes | the names of parameters list |
#    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
#    ...   and the parameter name|
#    ...
#    ...   *RETURN VALUE*
#    ...   | Updated_Paras_Dict    | yes | the parameters and the expect value |
#    ...
#    ...   Example
#    ...  | ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict| para_list=${para_list}    value_list=${value_list}|
#
#    ${Updated_Paras_Dict}   create dictionary
#    ${length}=    get length    ${para_name_list}
#    :For  ${i}  IN RANGE    0     ${length}
#    \  Set To Dictionary   ${Updated_Paras_Dict}   ${para_name_list[${i}]}  ${values_list[${i}]}
#    [Return]  ${Updated_Paras_Dict}
#
#
#Vdu Delta Config Ipapp For Twamp
#    [Arguments]  ${rate}=RATE_1
#    [Teardown]   vDU Rest Logout
#    [Documentation]   Vdu Delta Config Ipapp For Twamp
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    | rate  | No | TWAMP Sender Message Rate, default is RATE_1 |
#    ...
#    ...    Example
#    ...    | Vdu Delta Config Ipapp For Twamp |
#    ...
#    Run Keyword And Ignore Error  vDU Rest Logout
#    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
#    ${scf_path}  Get A Directory  scf
#    ${uniq_id}  Get Unique Id
#    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
#    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
#    scf.load scf  ${scf_path}
#    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
#    ${res}  Run Keyword And Ignore Error  scf.Get_Value_From_Scf  dist_name=${ipapp_dist_name}
#    ...  p_name=twampSenderMessageRate
#    Return From Keyword If  """${res[1]}"""=="""${rate}"""
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
#    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
#    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
#    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
#    ${operate}   Set Variable If  ${ipapp_exists}  replace  add
#    ${para_dict}=  Create Dictionary
#    ...  twampSenderMessageRate=${rate}
#    Update Delta Plan Parameter
#    ...  plan_id=${plan_id}
#    ...  mo_dn=${ipapp_dist_name}
#    ...  updated_paras_dict=${para_dict}
#    ...  operation=${operate}
#    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
#    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
#    Wait Until Keyword Succeeds    5min    20s
#    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#
#Vdu Delta Config Twamp
#    [Arguments]  ${twampId}  ${destIpAddress}  ${sourceIpAddressDN}
#    ...  ${administrativeState}=unlocked  ${enhancedMetric}=false  ${destPort}=5018   ${messageSize}=100
#    ...  ${plrAlarmThreshold}=100  ${rttAlarmThreshold}=1000000  ${twampDscp}=34
#    [Teardown]   vDU Rest Logout
#    [Documentation]   Vdu Delta Config Twamp
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    | twampId  | yes | twamp session id |
#    ...    | destIpAddress  | yes | twamp dest ip |
#    ...    | sourceIpAddressDN  | yes | twamp sourceIpAddressDN |
#    ...    | administrativeState  | No | administrativeState, default is unlocked |
#    ...    | enhancedMetric  | No | enhancedMetric, default is false |
#    ...    | destPort  | No | destPort, default is 5018 |
#    ...    | messageSize  | No | messageSize, default is 100 |
#    ...    | plrAlarmThreshold  | No | plrAlarmThreshold, default is 10000 |
#    ...    | rttAlarmThreshold  | No | rttAlarmThreshold, default is 1000000 |
#    ...    | twampDscp  | No | twampDscp, default is 34 |
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | Vdu Delta Config Twamp | 1 | 10.110.76.61 | MRBTS-10837/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1 |
#    ...
#    Run Keyword And Ignore Error  vDU Rest Logout
#    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
#    ${scf_path}  Get A Directory  scf
#    ${uniq_id}  Get Unique Id
#    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
#    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
#    scf.load scf  ${scf_path}
#    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
#    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
#    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
#    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
#    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
#    ${para_dict}=  Create Dictionary
#    ...  twampSenderMessageRate=RATE_1
#    Run Keyword If   "${ipapp_exists}"=="False"  Update Delta Plan Parameter
#    ...  plan_id=${plan_id}
#    ...  mo_dn=${ipapp_dist_name}
#    ...  updated_paras_dict=${para_dict}
#    ...  operation=add
#    ${distname}   Set Variable  ${ipapp_dist_name}/TWAMP-${twampId}
#    ${exists}  scf.Is Object In Scf   ${distname}
#    Run Keyword If   "${exists}"=="False"  Add Delta Plan MO
#    ...  plan_id=${plan_id}   parent_mo_dn=${ipapp_dist_name}   mo_name=TWAMP-${twampId}
#    ${operate}   Set Variable If  ${exists}  replace  add
#    ${para_dict}=  Create Dictionary
#    ...  administrativeState=${administrativeState}
#    ...  destIpAddress=${destIpAddress}
#    ...  sourceIpAddressDN=${sourceIpAddressDN}
#    ...  enhancedMetric=${enhancedMetric}
#    ...  destPort=${destPort}
#    ...  messageSize=${messageSize}
#    ...  plrAlarmThreshold=${plrAlarmThreshold}
#    ...  rttAlarmThreshold=${rttAlarmThreshold}
#    ...  twampDscp=${twampDscp}
#    ...  twampId=${twampId}
#    Update Delta Plan Parameter
#    ...  plan_id=${plan_id}
#    ...  mo_dn=${distname}
#    ...  updated_paras_dict=${para_dict}
#    ...  operation=${operate}
#    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
#    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
#    Wait Until Keyword Succeeds    5min    20s
#    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#
#Vdu Delta Config Reflect
#    [Arguments]  ${twampReflectId}  ${twampReflectorLocalIpAddressDN}  ${twampReflectorEnabled}=true
#    ...  ${twampReflectorUdpEchoEnabled}=true  ${refWaitTimeout}=900
#    [Teardown]   vDU Rest Logout
#    [Documentation]   Vdu Delta Config Reflect
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    | twampReflectId  | yes | twampReflect session id |
#    ...    | twampReflectorLocalIpAddressDN  | yes | twampReflectorLocalIpAddressDN |
#    ...    | twampReflectorEnabled  | No | twampReflectorEnabled, default is true |
#    ...    | twampReflectorUdpEchoEnabled  | No | twampReflectorUdpEchoEnabled, default is true |
#    ...    | refWaitTimeout  | No | refWaitTimeout, default is 900 |
#
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | Vdu Delta Config Reflect | 1 | MRBTS-10837/TNLSVC-1/TNL-4/IPNO-1/IPIF-1/IPADDRESSV4-1 |
#    ...
#    Run Keyword And Ignore Error  vDU Rest Logout
#    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
#    ${scf_path}  Get A Directory  scf
#    ${uniq_id}  Get Unique Id
#    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
#    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
#    scf.load scf  ${scf_path}
#    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
#    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
#    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
#    Run Keyword If   "${ipapp_exists}"=="False"  Add Delta Plan MO
#    ...  plan_id=${plan_id}   parent_mo_dn=MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}   mo_name=IPAPP-1
#    ${para_dict}=  Create Dictionary
#    ...  twampSenderMessageRate=RATE_1
#    Run Keyword If   "${ipapp_exists}"=="False"  Update Delta Plan Parameter
#    ...  plan_id=${plan_id}
#    ...  mo_dn=${ipapp_dist_name}
#    ...  updated_paras_dict=${para_dict}
#    ...  operation=add
#    ${distname}   Set Variable  ${ipapp_dist_name}/TWAMPREFLECT-${twampReflectId}
#    ${exists}  scf.Is Object In Scf   ${distname}
#    Run Keyword If   "${exists}"=="False"  Add Delta Plan MO
#    ...  plan_id=${plan_id}   parent_mo_dn=${ipapp_dist_name}   mo_name=TWAMPREFLECT-${twampReflectId}
#    ${operate}   Set Variable If  ${exists}  replace  add
#    ${para_dict}=  Create Dictionary
#    ...  refWaitTimeout=${refWaitTimeout}
#    ...  twampReflectorLocalIpAddressDN=${twampReflectorLocalIpAddressDN}
#    ...  twampReflectorEnabled=${twampReflectorEnabled}
#    ...  twampReflectorUdpEchoEnabled=${twampReflectorUdpEchoEnabled}
#    ...  twampReflectId=${twampReflectId}
#    Update Delta Plan Parameter
#    ...  plan_id=${plan_id}
#    ...  mo_dn=${distname}
#    ...  updated_paras_dict=${para_dict}
#    ...  operation=${operate}
#    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
#    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
#    Wait Until Keyword Succeeds    5min    20s
#    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#
#Vdu Delta Delete All Twamp Configurations
#    [Teardown]   vDU Rest Logout
#    [Documentation]   Vdu Delta Delete All Twamp Configurations
#    ...    *AUTHOR* hongping.rao@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    *RETURN VALUE*
#    ...    None
#    ...
#    ...    Example
#    ...    | Vdu Delta Delete All Twamp Configurations |
#    ...
#    Run Keyword And Ignore Error   vDU Rest Logout
#    Wait Until Keyword Succeeds  5min   10s    vDU Rest Login
#    ${scf_path}  Get A Directory  scf
#    ${uniq_id}  Get Unique Id
#    ${scf_path}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}
#    ...  filename=scf_${uniq_id}.xml  include_runtime_data=${False}
#    scf.load scf  ${scf_path}
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
#    ${tnl_id}   Get vDU TNL ID   scf_path=${scf_path}   templateType=TWAMP
#    ${ipapp_dist_name}   Set Variable  MRBTS-${mrbts_id}/TNLSVC-1/TNL-${tnl_id}/IPAPP-1
#    ${ipapp_exists}  scf.Is Object In Scf   ${ipapp_dist_name}
#    Return From Keyword If   "${ipapp_exists}"=="False"
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${delta_plan_name}   Get Unique Id  prefix=TA_twamp_delta_plan   precise=LOW
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA TWAMP
#    Delete Delta Plan MO   plan_id=${plan_id}   mo_dn=${ipapp_dist_name}
#    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}
#    ${out}   vdu.activate_delta_plan    delta_plan_id=${plan_id}
#    Wait Until Keyword Succeeds    5min    20s
#    ...    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#
#Change oamTls Value on vDU
#    [Arguments]   ${oamTls}=off   ${wait_vdu_up}=${False}
#    [Documentation]   Change oamTls Value on vDU
#    ...   *AUTHOR* huilin.xu@nokia-sbell.com
#	...   18.9.2021,lijuwang@nokia-sbell.com, optmize KW
#    ...   19.11.2022,chris.l.cao@nokia-sbell.com, optmize KW
#    ...   1.12.2022,chris.l.cao@nokia-sbell.com, return the result of 'VDU Online Change Parameters', add wait_vdu_up parameter
#    ...
#    ...   | Input Parameters    | Man. | Description |
#	...   | oamTls |   Yes   | The target value of oamTls|
#	...
#    ...   *RETURN VALUE*
#    ...   Change result, it includes original value and new value, we can restore it with this result by 'VDU Online Restore Parameters'
#    ...   Please see examples.
#    ...
#    ...   Example
#    ...   | ${change_result} | Change oamTls Value On vDU  | oamTls=forced |
#    ...   | Log To Console | Do something here... |
#    ...   | VDU Online Restore Parameters | ${change_result} |
#    ...
#    ...   | ${change_result} | Change oamTls Value On vDU  | oamTls=off |
#    ...   | Log To Console | Do something here... |
#    ...   | VDU Online Restore Parameters | ${change_result} |
#    ...
#    ${vdu_conf}    Get VDU Conf From SCF
#    ${para_list}   Create List      oamTls
#    ${value_list}  Create List      ${oamTls}
#    ${mo_list}     Create List      MRBTS-${vdu_conf["mrbts_id"]}/MNL-1/MNLENT-1/MPLANENW-1
#    vDU Rest Login
#    ${ret}  VDU Online Change Parameters   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}  wait_vdu_up=${wait_vdu_up}
#    [Return]  ${ret}
#
#
Enable Rannic Ssh Access
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${rannic_index}=1   ${username}=serviceuser
    ...   ${password}=bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
    [Documentation]   Enable Rannic Ssh Access
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  12.1.2024 chris.l.cao@nokia-sbell.com, change to set actSshToRanNic=true only.
    ...  1.2.2024 chris.l.cao@nokia-sbell.com, after config_ssh_tunnel, use retry mechanism to wait operation is successful
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index   | no | gnb_index, default value is 0 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | rannic_index | no | rannic_index, it starts from 1, default value is 1 |
    ...    | username     | No | username, default value is serviceuser |
    ...    | password     | No | password, default value is bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4= |
    ...
    ...    *RETURN VALUE*
    ...    alias and connection information to rannic, [<conn_info>, <delta_plan_result>], e.g,
    ...      [{'oam_ip': '10.71.164.18',
    ...     'password': 'bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
    ...     'port': 51217,
    ...     'dist_name': 'MRBTS-108201/EQM_R-1/APEQM_R-1/RNICMOD_R-1',
    ...     'username': 'serviceuser'},
    ...     {'need_update': False,
    ...     'origin_para_value_dict': {'MRBTS-108201/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                       'actSshToRanNic': 'true',
    ...                                                                       'passwdHistoryLength': '0'}},
    ...     'updated_para_value_dict': {'MRBTS-108201/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                        'actSshToRanNic': 'true',
    ...                                                                        'passwdHistoryLength': '0'}}}]
    ...
    ...    Example
    ...   | ${conn_info} | ${delta_plan_result} | Enable Rannic Ssh Access |
    ...   | ${alias}     |  Connect To Rannic | ${conn_info} |
    ...   | ${out}       | issh.Execute | command=ls -l /tmp | alias=${alias} |
    ...   | VDU Online Restore Parameters | ${delta_plan_result}
    ...   | issh.Disconnect | alias=${alias} |
    ...
    ${mrbts_id}   Set Variable    ${vDU_id}    #Get MRBTS Id From vDU SCF   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${mo_dn}      Set Variable     MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1

    #change plan parameter
    vDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${para_list}   Create List   actSshToRanNic   passwdHistoryLength
    ${value_list}  Create List   true             0
    ${mo_list}   Create List     ${mo_dn}         ${mo_dn}

    ${online_change_result}   vdu_oam_cm.VDU Online Change Parameters   para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}

    #change password
    ${alias_vdu}  VDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${response}  vdu.update_service_account_password  username=${username}  password=${EMPTY}  new_password=${password}  vdu_connection=${alias_vdu}
    Should Be Equal    ${response['content']}    Success

    #activate access to specific RANNIC
    ${vdu_alias_vdu}     vDU Rest Login   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${scf_path}  Get VDU SCF From Current Plan   gnb_index=${gnb_index}    vdu_index=${vdu_index}   include_runtime_data=${True}
    ${rannic_dn}  Get MO distName  scf_path=${scf_path}  distName=RNICMOD_R-${rannic_index}

    ${r}  ${operation_id}  Run Keyword And Ignore Error
       ...   vdu.config_ssh_tunnel    dist_name=${rannic_dn[0]}   operation=Disable    vdu_connection=${alias_vdu}
	sleep   15s
    Run Keyword If  "${r}"=="PASS"   Wait Until Keyword Succeeds  20  2
        ...   Config Ssh Tunnel Should Be Successful  operation_id=${operation_id}    alias=${alias_vdu}

    ${operation_id}    vdu.config_ssh_tunnel    dist_name=${rannic_dn[0]}   operation=Enable    vdu_connection=${alias_vdu}
    Wait Until Keyword Succeeds  100  3   Config Ssh Tunnel Should Be Successful  operation_id=${operation_id}    alias=${alias_vdu}

    ${res}   vdu.get_ssh_tunnel_config        ssh_mode_type=RNICMOD  vdu_connection=${alias_vdu}

    ${tmp_rannic_index}   Evaluate   int(${rannic_index})-1
    #${details}    Set Variable   ${res["details"][${tmp_rannic_index}]}

    ${oam_ip}   Set Variable    ${du_ip}    #Get vDU OAM Ip    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${conn_info}   Create Dictionary  port=51217   username=${username}   password=${password}   oam_ip=${oam_ip}
      ...    dist_name=MRBTS-${vDU_id}/EQM_R-1/APEQM_R-1/RNICMOD_R-1      #${details["port"]}  dist_name=${details["dist_name"]}
    [Return]  ${conn_info}   ${online_change_result}
#
#
Enable RU Ssh Access
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${ru_index}=1   ${username}=serviceuser
    ...   ${password}=bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=
    [Documentation]   Enable RU Ssh Access
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  23.1.2024 chris.l.cao@nokia-sbell.com, new KW
    ...  2.2.2024 chris.l.cao@nokia-sbell.com, use 'Enable Or Disable SSH Tunnel'
    ...  21.2.2024 chris.l.cao@nokia-sbell.com, support DC
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index   | no | gnb_index, default value is 0 |
    ...    | vdu_index    | no | vdu_index, default value is 0 |
    ...    | ru_index | no | ru_index, it starts from 1, default value is 1 |
    ...    | username     | No | username, default value is serviceuser |
    ...    | password     | No | password, default value is bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4= |
    ...
    ...    *RETURN VALUE*
    ...    alias and connection information to rannic, [<conn_info>, <delta_plan_result>], e.g,
    ...      [{'oam_ip': '10.71.164.18',
    ...     'password': 'bobuWrUHk7Xq7WPpY9ZcjEi8zNdX3plZ+/y420RZ7W4=',
    ...     'port': 51201,
    ...     'dist_name': 'MRBTS-108201/EQM_R-1/APEQM_R-1/RMOD-1',
    ...     'username': 'serviceuser'},
    ...     {'need_update': False,
    ...     'origin_para_value_dict': {'MRBTS-108201/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                       'actSshToRanNic': 'true',
    ...                                                                       'passwdHistoryLength': '0'}},
    ...     'updated_para_value_dict': {'MRBTS-108201/MNL-1/MNLENT-1/SECADM-1': {'actSshToRU': 'true',
    ...                                                                        'actSshToRanNic': 'true',
    ...                                                                        'passwdHistoryLength': '0'}}}]
    ...
    ...    Example
    ...   | ${conn_info} | ${delta_plan_result} | Enable RU Ssh Access |
    ...   | ${alias}     |  Connect To RU | ${conn_info} |
    ...   | ${out}       | issh.Execute | command=ls -l /tmp | alias=${alias} |
    ...   | VDU Online Restore Parameters | ${delta_plan_result}
    ...   | issh.Disconnect | alias=${alias} |
    ...
    ${mrbts_id}  Set Variable     ${vDU_id}
    #Get MRBTS Id From vDU SCF   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${mo_dn}    Set Variable     MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
    ${oam_ip}    Set Variable    ${du_ip}      #Get vDU OAM Ip    gnb_index=${gnb_index}    vdu_index=${vdu_index}

    #change plan parameter
    vDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${para_list}   Create List   actSshToRU   passwdHistoryLength
    ${value_list}  Create List   true             0
    ${mo_list}   Create List     ${mo_dn}         ${mo_dn}

    ${online_change_result}   vdu_oam_cm.VDU Online Change Parameters   para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}

    #change password
    ${alias_vdu}  VDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${response}  vdu.update_service_account_password  username=${username}  password=${EMPTY}  new_password=${password}  vdu_connection=${alias_vdu}
    Should Be Equal    ${response['content']}    Success

    #activate access to specific RMOD
    ${vdu_alias_vdu}     vDU Rest Login   gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${scf_path}  Get VDU SCF From Current Plan   gnb_index=${gnb_index}    vdu_index=${vdu_index}  #  include_runtime_data=${False}
    ${ru_dn}  Get MO distName  scf_path=${scf_path}  distName=RMOD-${ru_index}

    Run Keyword And Ignore Error   Enable Or Disable SSH Tunnel   dist_name=${ru_dn[0]}   operation=Disable    vdu_connection=${alias_vdu}
    Sleep  8

    Enable Or Disable SSH Tunnel   dist_name=${ru_dn[0]}   operation=Enable    vdu_connection=${alias_vdu}

    ${res}   vdu.get_ssh_tunnel_config        ssh_mode_type=RMOD  vdu_connection=${alias_vdu}
    Sleep  1

    FOR    ${item}    IN    @{res["details"]}
        Continue For Loop If    "${item['dist_name']}"!="${ru_dn[0]}"
    END
    ${dist_name}    Set Variable   ${item["dist_name"]}

    ${conn_info}   Create Dictionary  port=${item["port"]}   username=${username}   password=${password}   oam_ip=${oam_ip}
      ...    dist_name=${dist_name}
    [Return]  ${conn_info}   ${online_change_result}


Enable Or Disable SSH Tunnel
    [Arguments]  ${dist_name}   ${operation}   ${vdu_connection}=${None}
    [Documentation]   Enable Or Disable SSH Tunnel
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  Change History
    ...  2.2.2024 chris.l.cao@nokia-sbell.com, new KW
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | dist_name   | yes | dist_name, e.g,MRBTS-369371/EQM-1/APEQM-1/RMOD-1 |
    ...    | operation   | yes | Disable or Enable |
    ...    | vdu_connection | no | vdu_connection, defalut is ${None} |
    ...
    ${operation_id}   vdu.config_ssh_tunnel    dist_name=${dist_name}   operation=${operation}    vdu_connection=${vdu_connection}
     Wait Until Keyword Succeeds  50  3   Config Ssh Tunnel Should Be Successful  operation_id=${operation_id}    alias=${vdu_connection}


Config Ssh Tunnel Should Be Successful
    [Arguments]  ${operation_id}  ${alias}=${None}
    ${res}    vdu.get_trs_api_operation_status    operation_id=${operation_id}  vdu_connection=${alias}
    Should Be True  "${res["status"]}"=="Successful"



#Vdu Add Cell
#    [Arguments]   ${source_cell_id}    ${new_cell_info_dict}   ${gnb_index}=0  ${vdu_index}=0   ${wait_vdu_up}=${True}
#    [Documentation]    Vdu Copy a cell from an existing cell
#    ...    *AUTHOR* lingting.sun@nokia-sbell.com
#    ...    modified by:        <26-08-2022>, <lingtsun>, <initial created>
#    ...  Change History
#    ...  11.29.2023 chris.l.cao@nokia-sbell.com,1.merge different paramters to one parameter new_cell_info_dict,add nrarfcn,support multiple vdu
#    ...                                        2.it supports AEQY series, we can extend it to other type RU if need
#    ...                                        3.the RU series type of souce cell and new cell should be same
#    ...
#    ...  | Input Parameters | Man. | Description |
#    ...  | source_cell_id   | yes | the reference cell id for copy |
#    ...  | new_cell_info_dict | yes | the info of added cell, like cell_id, nrdu, lcrid, nrarfcn, etc, please see example |
#    ...  | vdu_index | No | the index of vdu, default value is 0 |
#    ...  | gnb_index | No | the index of gnb, default value is 0 |
#    ...  | wait_vdu_up | no | whether to wait for vdu up after adding new cell |
#    ...
#    ...   *Example1*
#    ...  | Log to console | Delete last cell, then add it back with the first cell as a template |
#    ...  | ${cell_id_list}      | vDU Get Cell List From Webem |
#    ...  | ${deleted_cell_info} | Vdu Delete Cell By Cell Index | deleted_cell_index=-1 |
#    ...  | Vdu Add Cell | source_cell_id=${cell_id_list[0]} | new_cell_info=${deleted_cell_info} |
#    ...
#    ...   *Example2*
#    ...  | ${channel_group_1} | Create List | 1 |  2 |  3 |  4 |  5 |  6 |  7 |  8 |
#    ...  | ${channel_group_info} | Create List |   ${channel_group_1} |
#    ...  | ${deleted_cell_info}  | Create Dictionary | cell_id=2 | lcrId=2 | nrarfcn=638000 | nrcellgrpId=2 | nrdu=1 | physCellId=313 | rmod_id=2 |
#    ...  |    ... | channel_group_info=${channel_group_info} |
#    ...  | Vdu Add Cell | source_cell_id=1 | new_cell_info_dict=${deleted_cell_info} |
#    ...
#    ...   *Return*
#    ...   None
#    ...
#    ${new_cell_id}   Set Variable   ${new_cell_info_dict["cell_id"]}
#    ${new_channel_group_info}    Set Variable   ${new_cell_info_dict["channel_group_info"]}
#
#    ${alias}  VDU Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
#
#    ${vdu_scf}    Get VDU SCF From Current Plan   gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${vdu_scf}
#    ${DN}   set variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
#
#    ${uni_id}   Get Unique Id
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number    alias=${alias}
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_cell_${uni_id}   alias=${alias}
#    ${plan_info_list}   vdu.get_tree_of_delta_plan    plan_id=${plan_id}   vdu_connection=${alias}
#    ${nrcell_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
#    ...   dist_name=${DN}/NRCELL-${source_cell_id}   key=mo_uuid
#    ${parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
#    ...   dist_name=${DN}/NRCELL-${source_cell_id}   key=parent_mo_uuid
#    ${nrcellgrp_mo_uuid}    get_value_from_plan_tree_info
#    ...   info_list=${plan_info_list}    dist_name=${DN}/NRCELLGRP-${source_cell_id}   key=mo_uuid
#
#    log to console   1. Copy NRCELL MO from NRCELL-${source_cell_id}, update lcrID and physCellId
#    Copy MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${plan_id}   parent_mo_uuid=${parent_mo_uuid}
#       ...    mo_uuid=${nrcell_mo_uuid}   new_instance_id=${new_cell_id}    include_children_objects=${True}   alias=${alias}
#    ${updated_paras_dict}   create dictionary    lcrId=${new_cell_info_dict['lcrId']}     physCellId=${new_cell_info_dict['physCellId']}
#       ...                                       nrarfcn=${new_cell_info_dict['nrarfcn']}
#    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${DN}/NRCELL-${new_cell_id}
#       ...   updated_paras_dict=${updated_paras_dict}    alias=${alias}
#
#    log to console   2. Copy NRCELLGRP MO from NRCELLGRP-${source_cell_id}, update nrCellList
#    Copy MO Into Delta Plan   plan_id=${plan_id}   source_plan_id=${plan_id}   parent_mo_uuid=${parent_mo_uuid}
#       ...    mo_uuid=${nrcellgrp_mo_uuid}   new_instance_id=${new_cell_id}   include_children_objects=${True}  alias=${alias}
#    ${updated_paras_dict}   create dictionary   /nrCellList/0=${new_cell_id}
#    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${DN}/NRCELLGRP-${new_cell_info_dict['nrcellgrpId']}
#       ...   updated_paras_dict=${updated_paras_dict}     alias=${alias}
#
#    log to console   3. Add refNrCellGroup into NRDU-${new_cell_info_dict['nrdu']}
#    ${nrcellgrp_index}   get_add_cell_info  scf_path_org=${vdu_scf}  class_name=NRDU
#       ...    list_p_name=refNrCellGroup
#    ${updated_paras_dict}   create dictionary   /refNrCellGroup/${nrcellgrp_index}=${new_cell_id}
#    Update Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${DN}/NRDU-${new_cell_info_dict['nrdu']}
#       ...   updated_paras_dict=${updated_paras_dict}    operation=add   alias=${alias}
#
#    log to console   4. Copy LCELNR MO from LCELNR-${source_cell_id}, update resourceDN for CHANNELGROUP
#    ${lcelnr_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
#       ...   dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${source_cell_id}    key=mo_uuid
#    ${lcelnr_parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
#       ...   dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${source_cell_id}   key=parent_mo_uuid
#    Copy MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${plan_id}   parent_mo_uuid=${lcelnr_parent_mo_uuid}
#       ...    mo_uuid=${lcelnr_mo_uuid}   new_instance_id=${new_cell_info_dict['lcrId']}    include_children_objects=${True}
#       ...    alias=${alias}
#    ${length}   get length   ${new_channel_group_info}
#    FOR  ${index}    IN RANGE   0    ${length}
#        ${group_id}    evaluate    ${index}+1
#        _Update Channel resourceDN For AEQY   channel_list=${new_channel_group_info}[${index}]    group_id=${group_id}
#           ...   rmod_id=${new_cell_info_dict['rmod_id']}   mrbts_id=${mrbts_id}   plan_id=${plan_id}   lnrcell=${new_cell_info_dict['lcrId']}
#           ...    alias=${alias}
#    END
#    Validate Delta Plan By REST   plan_id=${plan_id}   alias=${alias}
#    Activate Delta Plan By REST   plan_id=${plan_id}   alias=${alias}
#    Run Keyword If   "${wait_vdu_up}"=="${True}"
#       ...   Reset VDU By REST    need_check_on_air=${True}  vdu_index=${vdu_index}   gnb_index=${gnb_index}   wait=500
#
#
#_Update Channel resourceDN For AEQY
#    [Arguments]     ${channel_list}   ${group_id}   ${rmod_id}   ${mrbts_id}   ${plan_id}  ${lnrcell}   ${alias}=${None}
#    ${resourceDN}  Set Variable  MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${rmod_id}/PHYANT-1
#    ${dict_resourceDN}=   Create Dictionary  resourceDN=${resourceDN}
#    :For  ${index}  IN  @{CHANNEL_list}
#    \  ${CHANNEL_dn}  Set Variable  MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${lnrcell}/CHANNELGROUP-${group_id}/CHANNEL-${index}
#    \  Update Delta Plan Parameter  plan_id=${plan_id}  mo_dn=${CHANNEL_dn}  updated_paras_dict=${dict_resourceDN}   alias=${alias}
#
#
#Copy MO Into Delta Plan
#    [Arguments]  ${plan_id}   ${source_plan_id}   ${parent_mo_uuid}   ${mo_uuid}  ${new_instance_id}
#    ...   ${include_children_objects}  ${timeout}=30   ${alias}=${None}
#    [Documentation]    Vdu Copy MO Into Delta Plan
#    ...    *AUTHOR* lingting.sun@nokia-sbell.com
#    ...    modified by:        <26-08-2022>, <lingtsun>, <initial created>
#    ...    delete cell for vdu
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | plan_id          | yes | plan id for delta plan         |
#    ...    | source_plan_id   | yes | source plan id, could be delta plan or current plan |
#    ...    | parent_mo_uuid   | yes | parent managed object id in source plan|
#    ...    | mo_uuid          | yes | Unique managed object id which is being copied in source plan|
#    ...    | new_instance_id  | yes | new instance id |
#    ...    | include_children_objects | yes | is include children objects |
#    ...    | timeout          | no  | Timeout for the operation, defaults to 30|
#    ...
#    ...   *Example*
#    ...   | VDU Login |   gnb_index=${gnb_index} |  vdu_index=${vdu_index}
#    ...   | ${uni_id} |   Get Unique Id  |
#    ...   | Check Maximum Delta Plan Number And Delete One If Reach Maximum Number    |
#    ...   | ${plan_id}|   ${action_id} |  Generate Delta Plan  | plan_name=add_cell_${uni_id} |
#    ...   | ${plan_info_list} |  vdu.get_tree_of_delta_plan  |  plan_id=${plan_id}  |
#    ...   | ${mo_uuid} | get_value_from_plan_tree_info  | info_list=${plan_info_list} | dist_name=XXXX | key=mo_uuid |
#    ...   | ${parent-mo_uuid} | get_value_from_plan_tree_info | info_list=${plan_info_list} | dist_name=XXXX | key=parent_mo_uuid |
#    ...   | Copy MO Into Delta Plan | plan_id=${plan_id} |  source_plan_id=${plan_id} |  parent_mo_uuid=${parent_mo_uuid}
#    ...   | mo_uuid=${nrcell_mo_uuid} |  new_instance_id=9 |   include_children_objects=${True} |
#    ...
#    ...   *Return*
#    ...   None
#    ...
#    ${rtf}    vdu.copy_managed_objects_into_delta_plan
#    ...    plan_id=${plan_id}
#    ...    source_plan_id=${plan_id}
#    ...    parent_mo_uuid=${parent_mo_uuid}
#    ...    mo_uuid=${mo_uuid}
#    ...    new_instance_id=${new_instance_id}
#    ...    include_children_objects=${include_children_objects}
#    ...    timeout= ${timeout}
#    ...    vdu_connection=${alias}
#    wait until keyword succeeds   10x   2s
#    ...   _Copy MO Into Delta Plan Should Be Successful   plan_id=${plan_id}   action_id=${rtf['action_id']}   expected_status=success
#    ...   alias=${alias}
#
#
#_Copy MO Into Delta Plan Should Be Successful
#    [Arguments]  ${plan_id}   ${action_id}  ${expected_status}   ${alias}=${None}
#    ${out}   vdu.get_copy_managed_objects_into_delta_plan_status    plan_id=${plan_id}  action_id=${action_id}   vdu_connection=${alias}
#    Should Be True  "${out["status"]}"=="${expected_status}"
#    [Return]  ${out}
#
#
#Vdu Delete Cell By Cell Index
#    [Arguments]  ${deleted_cell_index}=-1   ${gnb_index}=0  ${vdu_index}=0  ${nrdu}=1    ${wait_vdu_up}=${False}
#    [Documentation]    Vdu Delete Cell By Cell Index
#    ...    *AUTHOR* lingting.sun@nokia-sbell.com
#    ...   *Change History*
#    ...   | 2023-11-27 | chris.l.cao@nokia-sbell.com | optimize code, change KW name to 'Vdu Delete Cell By Cell Index' |
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | deleted_cell_index | No | deleted_cell_index, 0 means first cell, -1 means last cell, |
#    ...    |                   |    | otherwise it means any cell between first cell and last cell, default is -1 |
#    ...    | vdu_index | No | the index of vdu, default value is 0 |
#    ...    | gnb_index | No | the index of gnb, default value is 0 |
#    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route deleted |
#    ...
#    ...    *Return*
#    ...    the information of deleted cell, type is dictionary, e.g,
#    ...     {'cell_id': '2',
#    ...      'channel_group_info': [['1', '2', '3', '4', '5', '6', '7', '8']],
#    ...       'lcrId': '2',
#    ...       'nrarfcn': '638000',
#    ...       'nrcellgrpId': '2',
#    ...       'nrdu': '1',
#    ...       'physCellId': '313',
#    ...       'rmod_id': '2'
#    ...     }
#    ...
#    ...   *Example*
#    ...  | Log to console | Delete last cell, then add it back |
#    ...  | ${cell_id_list}      | vDU Get Cell List From Webem |
#    ...  | ${deleted_cell_info} | Vdu Delete Cell By Cell Index | deleted_cell_index=-1 |
#    ...  | Vdu Add Cell | source_cell_id=${cell_id_list[0]} | new_cell_info=${deleted_cell_info} |
#    ...
#    ${alias}  VDU Login    gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${scf_path}  Get VDU SCF From Current Plan    gnb_index=${gnb_index}  vdu_index=${vdu_index}
#    ${uni_id}   Get Unique Id
#    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=delete_cell_${uni_id}
#
#    ${conf}  Get VDU Conf From SCF   scf_path=${scf_path}
#
#    ${NRCELL_id_list}   vDU Get Cell List From Webem   gnb_index=${gnb_index}  vdu_index=${vdu_index}
#    ${LCELNR_id_list}   Get LCELNR ID From vDU SCF  scf_path=${scf_path}
#    ${NRCELLGRP_id_list}   vDU Get NRCELLGRP ID list   scf_path=${scf_path}
#
#    ${to_be_deleted_NRCELL_id}  Set Variable  ${NRCELL_id_list[${deleted_cell_index}]}
#    ${to_be_deleted_LCELNR_id}  Set Variable  ${LCELNR_id_list[${deleted_cell_index}]}
#    ${to_be_deleted_NRCELLGRP_id}  Set Variable  ${NRCELLGRP_id_list[${deleted_cell_index}]}
#
#    ${NRCELL_dn}  Set Variable  MRBTS-${conf["mrbts_id"]}/NRBTS-${conf["nrbts_id"]}/NRCELL-${to_be_deleted_NRCELL_id}
#    ${LCELNR_dn}  Set Variable  MRBTS-${conf["mrbts_id"]}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${to_be_deleted_LCELNR_id}
#    ${NRCELLGRP_dn}  Set Variable  MRBTS-${conf["mrbts_id"]}/NRBTS-${conf["nrbts_id"]}/NRCELLGRP-${to_be_deleted_NRCELLGRP_id}
#    ${NRDU_dn}   Set Variable   MRBTS-${conf["mrbts_id"]}/NRBTS-${conf["nrbts_id"]}/NRDU-${nrdu}
#
#    ${refNrCellGroup_value}   Get VDU Parameter Value Online   ${NRDU_dn}   refNrCellGroup
#    ${nrcellgrp_list_len}  Get Length   ${refNrCellGroup_value}
#    ${nrcellgrp_max_index}  Evaluate  int(${nrcellgrp_list_len})-1
#    ${nrcellgrp_index}  Set Variable If   ${deleted_cell_index}==-1   ${nrcellgrp_max_index}   ${deleted_cell_index}
#
#    #fetch old value before delete it
#    ${lcrId}     Get VDU Parameter Value Online    mo_dn=${NRCELL_dn}    para_name=lcrId
#    ${physCellId}   Get VDU Parameter Value Online   mo_dn=${NRCELL_dn}  para_name=physCellId
#    ${nrarfcn}   Get VDU Parameter Value Online      mo_dn=${NRCELL_dn}  para_name=nrarfcn
#
#    ${CHANNEL_dn}  Set Variable   ${LCELNR_dn}/CHANNELGROUP-1/CHANNEL-1
#    ${resourceDN}  Get VDU Parameter Value Online   mo_dn=${CHANNEL_dn}  para_name=resourceDN
#    ${matches}  Get Regexp Matches  ${resourceDN}  RMOD-(\\d+)
#    ${rmod}   Set Variable   ${matches[0]}
#    ${rmod_id}   Set Variable  ${rmod.split("-")[-1]}
#
#    ${scf_content}   OperatingSystem.Get File   ${scf_path}
#    ${channel_group}     Get Regexp Matches    ${scf_content}   .*${LCELNR_dn}/CHANNELGROUP-1/CHANNEL-(\\d)".+   1
#    ${channel_group_info}  Create List  ${channel_group}
#
#    ${deleted_cell_info}   Create Dictionary   cell_id=${to_be_deleted_NRCELL_id}  nrdu=${nrdu}   lcrId=${lcrId}
#       ...  nrcellgrpId=${to_be_deleted_NRCELLGRP_id}   physCellId=${physCellId}  nrarfcn=${nrarfcn}   rmod_id=${rmod_id}
#       ...  channel_group_info=${channel_group_info}
#
#    #begin to delete it
#    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${NRCELL_dn}
#    sleep  5s
#    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${LCELNR_dn}
#    sleep  5s
#    vdu.delete_mo_of_delta_plan    delta_plan_id=${plan_id}    mo_dn=${NRCELLGRP_dn}
#    sleep  5s
#    ${paras}=   Create Dictionary   /refNrCellGroup/${nrcellgrp_index}=${EMPTY}
#    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${NRDU_dn}   updated_paras_dict=${paras}   operation=remove
#
#    Validate Delta Plan By REST   ${plan_id}
#    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
#    [Return]  ${deleted_cell_info}
#
#
#QoS Remove First And Second Level Scheduler
#    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
#    [Documentation]   QoS Remove First And Second Level Scheduler
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   *Change History*
#    ...   8.12.2023 chris.l.cao@nokia-sbell.com, initialization
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | vdu_index | No | the index of vdu, default value is 0 |
#    ...    | gnb_index | No | the index of gnb, default value is 0 |
#    ...
#    ...    *Return*
#    ...    None
#    ...
#    ...   *Example*
#    ...  | QoS Remove First And Second Level Scheduler |
#    ...
#    ${vdu_scf_path}   Get VDU SCF From Current Plan   gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${vcu_scf_path}   Get VDU SCF From Current Plan   gnb_index=${gnb_index}
#
#    ${vdu_uplane_tnl_id}   Get vDU TNL ID   scf_path=${vdu_scf_path}   templateType=5GUserPlane
#    ${vcu_uplane_tnl_id}   Get vDU TNL ID   scf_path=${vcu_scf_path}   templateType=5GUserPlane
#
#    ${vdu_mrbts_id}   Get MRBTS Id From vDU SCF   gnb_index=${gnb_index}   vdu_index=${vdu_index}
#    ${vcu_mrbts_id}   Get MRBTS Id From vCU SCF   gnb_index=${gnb_index}
#
#    ${vdu_FSTSCH_mo}  Set Variable    MRBTS-${vdu_mrbts_id}/TNLSVC-1/TNL-${vdu_uplane_tnl_id}/IPNO-1/QOS-1/FSTSCH-1
#    ${vcu_FSTSCH_mo}  Set Variable    MRBTS-${vcu_mrbts_id}/TNLSVC-1/TNL-${vcu_uplane_tnl_id}/IPNO-1/QOS-1/FSTSCH-1
#
#    ${vdu_DSCP2QMAP_mo}  Set Variable    MRBTS-${vdu_mrbts_id}/TNLSVC-1/TNL-${vdu_uplane_tnl_id}/IPNO-1/QOS-1/DSCP2QMAP-1
#
#    #disable 1st level schedule
#    ${vdu_mo_list}   Create List   ${vdu_FSTSCH_mo}   ${vdu_DSCP2QMAP_mo}
#    ${vcu_mo_list}   Create List   ${vcu_FSTSCH_mo}
#    VDU Delete Delta Plan MOs And Activate  mo_list=${vdu_mo_list}   gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    CU Delete Delta Plan Managed Object   mo_list=${vcu_mo_list}   gnb_index=${gnb_index}
#
#    #disable 2nd level schedule for vdu
#    ${vdu_ETHIF_mo}  Set Variable  MRBTS-${vdu_mrbts_id}/TNLSVC-1/TNL-${vdu_uplane_tnl_id}/ETHSVC-1/ETHIF-1
#    ${para_list}   Create List     enableShaping     sirTotal         sbsTotal          shapingOverhead
#    ${value_list}  Create List     false              ${None}            ${None}           ${None}
#    ${mo_list}   Create List       ${vdu_ETHIF_mo}   ${vdu_ETHIF_mo}  ${vdu_ETHIF_mo}   ${vdu_ETHIF_mo}
#    ${ret}   VDU Online Change Parameters   para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}
#       ...   gnb_index=${gnb_index}   vdu_index=${vdu_index}
#
#    #disable 2nd level schedule for vcu
#    ${vcu_ETHIF_mo}  Set Variable   MRBTS-${vcu_mrbts_id}/TNLSVC-1/TNL-${vcu_uplane_tnl_id}/ETHSVC-1/ETHIF-1
#    ${para_list}   Create List     enableShaping     sirTotal         sbsTotal          shapingOverhead
#    ${value_list}  Create List     false             ${None}          ${None}           ${None}
#    ${mo_list}   Create List       ${vcu_ETHIF_mo}   ${vcu_ETHIF_mo}  ${vcu_ETHIF_mo}   ${vcu_ETHIF_mo}
#    VCU Online Change Parameters   para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}  gnb_index=${gnb_index}
#
#
#Check Current Parameter Value As Expected
#    [Arguments]   ${mo_list}    ${para_list}    ${expected_value_list}    ${vdu_index}=0
#    [Documentation]    Check Current Parameter Value As Expected, suggest use it after "VDU Online Change Parameters"
#    ...   *AUTHOR* liting.cao@nokia-sbell.com
#    ...    history change: <date>,<who>,<what and how>
#    ...    23.11.2023, liting.cao@nokia-sbell.com, new kw
#    ...
#    ...   | Input Parameters    | Man. | Description |
#    ...   | ${para_list}  |  Yes   | Create List  | staticRoutes/0/destIpAddr |
#    ...   | ${expected_value_list} |  Yes |  Create List |  1.1.1.1 |
#    ...   | ${mo_list}    |  Yes | Create List  |  MRBTS-${bts_id}/TNLSVC-1/TNL-2/IPNO-1/IPRT-1 |
#    ...
#    ...    *RETURN VALUE*
#    ...     ${compare_result}
#    ...
#    ...    Example
#    ...    | Check Current Parameter Value As Expected | para_list=${para_list} | expected_value_list=${expected_value_list}
#    ...    | mo_list=${mo_list} |
#    ...
#    ${origin_para_value_dict}    Get VDU Parameter Value Online For Multiple MO
#      ...   para_list=${para_list}   mo_list=${mo_list}  vdu_index=${vdu_index}
#    ${updated_para_value_dict}    _Convert Updating Parameters From List To Dict For Multiple MO
#      ...   para_list=${para_list}  value_list=${expected_value_list}  mo_list=${mo_list}   convert_empty_to_none=${True}
#    ${compare_result}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${updated_para_value_dict}
#    Should be true   "${compare_result}"=="${True}"
#    [Return]       ${compare_result}
#
#
#Get DU Specified MO Attributes
#    [Arguments]     ${dn_name}
#    vDU Rest Login
#    ${plan_file_path}=    Get A Directory    SCF
#    ${current_plan_path}      vdu.get_current_plan_file   local_dir_path=${plan_file_path}  filename=scf.xml  include_runtime_data=${True}
#    scf.load_scf   ${current_plan_path}
#    ${class_name}    scf.get_mo_attribute     dist_name=${dn_name}  attribute=class
#    ${dist_name}    scf.get_mo_attribute     dist_name=${dn_name}    attribute=distName
#    ${version}    scf.get_mo_attribute     dist_name=${dn_name}    attribute=version
#    ${mo_att_list}    Create List   ${class_name}   ${dist_name}   ${version}
#    scf.save_scf    ${current_plan_path}
#    [Return]   ${mo_att_list}
#    VDU Rest Logout
#
#Enable SSH For RU In SCF
#    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
#    ${mrbts_id}   Get MRBTS Id From vDU SCF   gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ${mo_dn}      Set Variable     MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
#    ${delta_data_list_1}=  generic_utils.construct_delta_data_for_delta_commissioning
#    ...  mo_dn=${mo_dn}
#    ...  operation_type=replace
#    ...  actSshToRU=true  passwdHistoryLength=${0}
#    ${all_delta_data_list}=  create list  ${delta_data_list_1}
#    vdu_cm.Fast Delta Commission With Delta Data List   ${all_delta_data_list}
#
#
#Enable SSH For RU In SCF Not Using RFRL
#    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
#    [Documentation]   Enable SSH For RU In SCF Not Using RFRL
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...   *Change History*
#    ...   22.5.2024 chris.l.cao@nokia-sbell.com, initialization
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | vdu_index | No | the index of vdu, default value is 0 |
#    ...    | gnb_index | No | the index of gnb, default value is 0 |
#    ...
#    ...    *Return*
#    ...    None
#    ...
#    ...   *Example*
#    ...  | Enable SSH For RU In SCF Not Using RFRL |
#    ...
#    ${mrbts_id}   Get MRBTS Id From vDU SCF   gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    vDU Rest Login
#    ${mo_dn}      Set Variable   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
#    ${para_list}   Create List   actSshToRU     passwdHistoryLength
#    ${value_list}  Create List   true           0
#    ${mo_list}   Create List     ${mo_dn}    ${mo_dn}
#    ${ret}   VDU Online Change Parameters   para_list=${para_list}   value_list=${value_list}   mo_list=${mo_list}
#
#
#Change The Password Of Serviceuser Account Via Webem
#    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${serviceuser_new_pwd}=Nokia@123
#    Log To Console   Change The Password Of Serviceuser Account Via Webem
#    vDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
#    ${response}    vdu.update_service_account_password     username=serviceuser
#    ...                                                    password=${EMPTY}
#    ...                                                    new_password=${serviceuser_new_pwd}
#    Should Be Equal    ${response['content']}    Success
#    [Teardown]       VDU Rest Logout