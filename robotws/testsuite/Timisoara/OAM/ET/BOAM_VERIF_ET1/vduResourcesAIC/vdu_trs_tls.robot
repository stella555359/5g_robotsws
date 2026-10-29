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
    Log To Console  Change tls mode
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

Change oamTls value on vDU
    [Arguments]  ${mrbts_name}  ${oamTls_expected_value}
    [Documentation]   Change oamTls value on vDU
    ...   *AUTHOR* huilin.xu@nokia-sbell.com
	...    modified by:        <18-09-2021>, <lijuwang>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   | mrbts_name |  Yes   | The mrbts_name |
	...   | oamTls_expected_value |   Yes   | The target value of oamTls|
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Change oamTls value on vDU  | MRBTS-5226 | forced |
    ${MO_DN}      set variable     ${mrbts_name}/MNL-1/MNLENT-1/MPLANENW-1

    vDU Rest Login
    ${oamTls}=    Get VDU Parameter Value Online    ${MO_DN}    oamTls
    ${oamTls_dict}    Create Dictionary    oamTls=${oamTls_expected_value}


    run keyword if    '${oamTls}' != '${oamTls_expected_value}'    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${MO_DN}    updated_paras_list=${oamTls_dict}    auto_lock_cells=${False}    wait_vdu_up=${false}
