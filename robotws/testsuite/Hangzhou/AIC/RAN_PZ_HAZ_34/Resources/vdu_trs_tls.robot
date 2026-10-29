*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vdu_trs_tls.robot



*** Variables ***



*** Keywords ***
Check oamTLSstatus Status is Correct
    [Arguments]   ${scf_path}   ${tls_status}
    [Documentation]   Restore Default Certificates Should Be Successful
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | scf_path |  Yes   | The path to save scf file |
	...   | tls_status |   Yes   | The target status of oamTlsStatuss|
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Change tls mode  |  ${scf_path}  |  forced |
    Log to Console   Check oamTLSstatus status
    vDU Rest Login
    ${scf_file_with_fullpath}  vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=runtimescf.xml  include_runtime_data=${True}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    Set Test Variable   ${VDU_CONF}
    ${MPLANENW_R_DISTNAME}   Set Variable    MRBTS-${VDU_CONF["mrbts_id"]}/MNL-1/MNLENT-1/MPLANENW-1/MPLANENW_R-1
    ${oamTlsstatus}    scf.Get_Value_From_Scf     dist_name=${MPLANENW_R_DISTNAME}    p_name=oamTlsStatus
    Should be true   "${oamTlsstatus}"=="${tls_status}"

Change Tls Mode
    [Arguments]   ${scf_path}   ${target_oamTls}
    [Documentation]   Restore Default Certificates Should Be Successful
    ...   *AUTHOR* lijuan.1.wang@nokia-sbell.com
	...    modified by:        <28-07-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | scf_path |  Yes   | The path to save scf file |
	...   | target_oamTls |   Yes   | The target value of oamTls|
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Change tls mode  |  ${scf_path}  |  forced |
    Log To Console  Change tls mode to ${target_oamTls}
    VDU Rest Login
    sleep   5s
    ${scf_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_fullpath}
    ${current_oamTls}   scf.get_value_from_scf   dist_name=${MPLANENW_DISTNAME}   p_name=oamTls
    Return from keyword if   "${current_oamTls}"=="${target_oamTls}"
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=ChangeTLsMode
    ${oamTls_dict}  create dictionary    oamTls=${target_oamTls}
    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${MPLANENW_DISTNAME}
    ...    updated_paras_list=${oamTls_dict}
    ...    operation=replace
    ...    activate=${True}
    ...    force_reset=${True}
    ...    auto_lock_cells=${False}
    ...    timeout=60
    Sleep   10s


Change oamTls Value on vDU
    [Arguments]   ${oamTls}=off   ${wait_vdu_up}=${False}
    [Documentation]   Change oamTls Value on vDU
    ...   *AUTHOR* huilin.xu@nokia-sbell.com
	...   18.9.2021,lijuwang@nokia-sbell.com, optmize KW
    ...   19.11.2022,chris.l.cao@nokia-sbell.com, optmize KW
    ...   1.12.2022,chris.l.cao@nokia-sbell.com, return the result of 'VDU Online Change Parameters', add wait_vdu_up parameter
    ...
    ...   | Input Parameters    | Man. | Description |
	...   | oamTls |   Yes   | The target value of oamTls|
	...
    ...   *RETURN VALUE*
    ...   Change result, it includes original value and new value, we can restore it with this result by 'VDU Online Restore Parameters'
    ...   Please see examples.
    ...
    ...   Example
    ...   | ${change_result} | Change oamTls Value On vDU  | oamTls=forced |
    ...   | Log To Console | Do something here... |
    ...   | VDU Online Restore Parameters | ${change_result} |
    ...
    ...   | ${change_result} | Change oamTls Value On vDU  | oamTls=off |
    ...   | Log To Console | Do something here... |
    ...   | VDU Online Restore Parameters | ${change_result} |
    ...
    ${vdu_conf}    Get VDU Conf From SCF
    ${para_list}   Create List      oamTls
    ${value_list}  Create List      ${oamTls}
    ${mo_list}     Create List      MRBTS-${vdu_conf["mrbts_id"]}/MNL-1/MNLENT-1/MPLANENW-1
    vDU Rest Login
    ${ret}  VDU Online Change Parameters   para_list=${para_list}  value_list=${value_list}  mo_list=${mo_list}  wait_vdu_up=${wait_vdu_up}
    [Return]  ${ret}

