*** Settings ***
Documentation
...   author: xianbiao.cheng@nokia-sbell.com
...   contact: xianbiao.cheng@nokia-sbell.com
...   vran_trs_qos.robot
...




*** Variables ***



*** Keywords ***
VCU Get cPlaneDscp current value
    [Documentation]   VCU Get cPlaneDscp current value
    ...   *AUTHOR* ling.2.zhao@nokia-sbell.com
	...    modified by:        <08-09-2021>, <lingzhao>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   *RETURN VALUE*
    ...   string
    ...   Example
    ...   | ${cPlaneDscp} |  VCU Get cPlaneDscp current value |
    Log to Console   VCU Get cPlaneDscp current value
    ${plan_file_path}=    Get A File    SCF    vcu_scf.xml
    ${scf_file_fullpath}   cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    ${cPlaneDscp}  scf.Get_Value_From_Scf   dist_name=${nrbts_distname}  p_name=cPlaneDscp
    [Return]   ${cPlaneDscp}


VCU Modify cPlaneDscp value
    [Arguments]    ${cplaneDscp_value}
    [Documentation]   VCU Modify cPlaneDscp value
    ...   *AUTHOR* ling.2.zhao@nokia-sbell.com
	...    modified by:        <08-09-2021>, <lingzhao>, <Initial creation>
    ...   | Input Parameters    | Man. | Description |
    ...   *RETURN VALUE*
    ...   none
    ...   Example
    ...   | VCU Modify cPlaneDscp value  |  50  |
    Log to Console   VCU Modify cPlaneDscp value
    ${plan_file_path}=    Get A File    SCF    vcu_scf.xml
    ${scf_file_fullpath}   cu.get_current_plan_file   path=${plan_file_path}  timeout=60  include_runtime_data=${True}
    scf.Load_Scf  file_path=${plan_file_path}
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${plan_file_path}
    &{cPlaneDscp_list}   Create Dictionary    operation_type=replace    parameter_path=/cPlaneDscp    value=${cplaneDscp_value}
    @{cPlaneDscp_list}    Create List    ${cPlaneDscp_list}
    ${cPlaneDscp_distName}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${mrbts_id}
    CU Online Change Single Mo Parameters via rest   para_list=${cPlaneDscp_list}   mo_dn=${cPlaneDscp_distName}