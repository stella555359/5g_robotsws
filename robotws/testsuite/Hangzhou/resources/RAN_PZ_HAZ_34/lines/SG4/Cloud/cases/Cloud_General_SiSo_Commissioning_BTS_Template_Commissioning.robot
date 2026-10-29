*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot

*** Keywords ***
Cloud_General_SiSo_Commissioning_BTS_Template_Commissioning
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to check if not commissioned BTS can be correctly configured
    ...    using BTS Template, verify Managed Object Class in WebUI and update parameters via WebUI.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 08.04.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    ${btsname}    Cloud Get Bts Name by Rest
    Cloud Modify Parameter In SCF From Webem And Commission
    Cloud Modify Bts Name by Rest    btsname=${btsname}

Cloud Get Bts Name by Rest
    [Arguments]  ${gnb_index}=${0}    ${vdu_index}=${0}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${btsname}    vdu_cm_base.get_parameter_value_from_current_plan    mo_dn=MRBTS-${mrbts_id}
    ...    parameter_name=btsName    conn_alias=${conn_alias}
    log to console    \n***Cloud Get Bts Name is ${btsname}***
    [Return]  ${btsname}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Modify Parameter In SCF From Webem And Commission
    [Arguments]  ${gnb_index}=${0}    ${vdu_index}=${0}    ${local_output_dir}=${SAVE LOG DIRECTORY}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File    local_dir_path=${local_output_dir}  filename=scf.xml  include_runtime_data=${False}
    scf.Load scf    ${scf_file_with_fullpath}
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    scf.modify_scf_element    dist_name=MRBTS-${mrbts_id}    p_name=btsName    value=commission_${timestamp}
    scf.Save scf    ${scf_file_with_fullpath}
    Cloud Perform VDU Full Scf    vdu_scf_path=${scf_file_with_fullpath}
	sleep    1min
    wait until keyword succeeds     15min    30s     All Cells Should Be Onair For One Specific vDU
    ${value}    Cloud Get Bts Name by Rest
    should be equal as strings    ${value}    commission_${timestamp}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Modify Bts Name by Rest
    [Arguments]  ${btsname}    ${gnb_index}=${0}    ${vdu_index}=${0}
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${conn_alias}
    ${distname}    Set Variable   MRBTS-${mrbts_id}
    ${change}    create dictionary    btsName=${bts_name}
    vdu_cm_base.update_parameter_for_delta_plan     mo_dn=${distname}    delta_param_dict=${change}
    ...    operation=replace    conn_alias=${conn_alias}
    vdu_cm_base.validate_delta_plan    conn_alias=${conn_alias}
    vdu_cm_base.activate_delta_plan    conn_alias=${conn_alias}
    ${value}    Cloud Get Bts Name by Rest
    should be equal as strings    ${value}    ${btsname}
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}
