*** Settings ***
Documentation
...    Common step keywords related to vCU cloud operations.
...    Maintainer: changyan.li@nokia-sbell.com
Library           taf.gnb.oam.coam.cu    WITH NAME    cu
Library           taf.rfrl.cbts.devices.vcu.business.vcu_ope_business    WITH NAME   vcu_ope_business
Library           taf.rfrl.cbts.devices.vcu.base.vcu_cm_base.vCUCM    WITH NAME   vcu_cm_base
Library           taf.rfrl.cbts.connections.rest_conn_vcu.GenericCU  WITH NAME   vcu_gen
Library           taf.rfrl.cbts.utilities.generic_utils   WITH NAME    generic_utils
Library           taf.rfrl.cbts.utilities.tl_config   WITH NAME  tl_config
Library           taf.rfrl.cbts.devices.vcu.base.vcu_cli_base.VCUCli    WITH NAME   vcu_cli_base
Library           taf.rfrl.cbts.parsers.parsers  WITH NAME   parser
Library           taf.rfrl.cbts.devices.vcu.business.vcu_cm_business        WITH NAME   vcu_cm_business
Resource          taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource          taf/rfrl/cbts/robot/vcu/vcu_log.robot


*** Keywords ***
Verify All Cells Are Disabled for vCU
    [Arguments]    ${gnb_index}=0
        [Documentation]
    ...    This keyword is to verify cell disabled on vCU.
    ...    - [Keyowrd Details]
    ...    This keyword is to verify cell disabled on vCU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 24.05.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    log to console    Verify All Cells Are Disabled for vCU
    ${cells_id_list}    vcu_operations.vCU Get Cell List From Webem    gnb_index=${gnb_index}
    vCU Cells Status Should Be As Expected    cells_id_list=${cells_id_list}   operational_state=disabled
      ...     gnb_index=${gnb_index}

Cloud Reset vCU and Check Cell On Air
    [Arguments]    ${need_check_on_air}=${True}    ${gnb_index}=0
    [Documentation]    *****************
    ...    This keyword is designed to perform vCU reset and check cell status after resetting.
    ...    - [Keyword Details]
    ...    It firstly login vCU via rest API, the do vCU reset and check the status is ongoing.
    ...    It also check all the cells' status shall be on restore to on air after resetting.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | need_check_on_air | No | check on air or not. Default is True. |
    ...    | gnb_index | No | The gnb index. Default is 0. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    *Author* shifu.lan@nokia-sbell.com
    ...    *Group* VRF_HAZ4_04
    ...    *******************
    ${conn_alias}    Rest Login To vCU    gnb_index=${gnb_index}
    ${out}    cu.reset_cu    connection=${conn_alias}
    Should Be Equal As Strings    ${out["error_message"]}    ${None}
    Should Be Equal As Strings    ${out["status"]}    ongoing
    Sleep    60s
    Run Keyword If   ${need_check_on_air}   Wait Until Keyword Succeeds  20min   30s
    ...    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    [Teardown]    vcu_gen.logout_rest    conn_alias=${conn_alias}

Deletion Cell on vCU
    [Documentation]
    ...    This keyword is to do cell deletion vCU.
    ...    - [Keyowrd Details]
    ...    This keyword is to do cell deletion vCU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cu_deletion_scf | Yes | The cell deletion delta scf and need to prepare by test owner. No default. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | vdu_index | No | The vcu index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    [Arguments]   ${cu_deletion_scf}    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vcu_gen.login_rest    gnb_index=${gnb_index}    alias=${conn_alias}
    vcu_cm_business.fast_delta_commission_with_delta_xml_file    xml_file_path=${cu_deletion_scf}    conn_alias=${conn_alias}
    [Teardown]    vcu_gen.logout_rest    conn_alias=${conn_alias}

Addition Cell on vCU
    [Documentation]
    ...    This keyword is to do cell addition vCU.
    ...    - [Keyowrd Details]
    ...    This keyword is to do cell addition vCU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cu_addition_scf | Yes | The cell addition delta scf and need to prepare by test owner. No default. |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | vdu_index | No | The vcu index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 11.06.2024 - - Created
    ...    *******************
    ...    *Author* jiayi.tang@nokia-sbell.com
    ...    *Group* VRF_HAZ3_02
    ...    *******************
    [Arguments]   ${cu_addition_scf}    ${gnb_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vcu_gen.login_rest    gnb_index=${gnb_index}    alias=${conn_alias}
    vcu_cm_business.fast_delta_commission_with_delta_xml_file    xml_file_path=${cu_addition_scf}    conn_alias=${conn_alias}
    [Teardown]    vcu_gen.logout_rest    conn_alias=${conn_alias}


Cloud vCU Delete Cell By Cell Index
    [Arguments]  ${deleted_cell_index}=-1   ${gnb_index}=0    ${nrdu}=1
    [Documentation]    Cloud vCU Delete Cell By Cell Index
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | deleted_cell_index | yes | index of deleted cell
    ...    | vdu_index | No | the index of vdu, default value is 0 |
    ...    | gnb_index | No | the index of gnb, default value is 0 |
    ...    | nrdu   | yes | nrdu
    ...
    ...    *Return*
    ...    the information of deleted cell, type is dictionary, e.g,
    ...     {'cell_id': '1',
    ...      'channel_group_info': [['1', '2', '3', '4']],
    ...       'lcrId': '1',
    ...       'nrarfcn': '638000',
    ...       'nrcellgrpId': '1',
    ...       'nrdu': '1',
    ...       'physCellId': '51',
    ...     }
    ...
    ...   *Example*
    ...  | ${deleted_cell_info} | Cloud vCU Delete Cell By Cell Index | deleted_cell_index=-1 | nrdu=1 |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Log To Console    \n****Cloud vCU Delete Cell By Cell Index
    ${conn_alias}   generic_utils.get_unique_id_string
    vcu_gen.login_rest   gnb_index=${gnb_index}   alias=${conn_alias}

    Log To Console    \n****vCU save current scfc file
    ${vcu_scf_path}    Get Cloud vCU SCF From Current Plan    alias=${conn_alias}

    Log To Console    \n****vCU create delta plan
    ${uni_id}   generic_utils.get_unique_id_string
    Cloud vCU Check Max Delta Plan Number And Delete One If Reach Max Number    alias=${conn_alias}
    ${plan_id}   ${action_id}    Cloud vCU Generate Delta Plan   plan_name=delete_cell_${uni_id}    alias=${conn_alias}

    Log To Console    \n****vCU get bts info
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}    Get Cloud MRBTS Id From vCU SCF    scf_path=${vcu_scf_path}

    ${grp_id}    ${refgrp_id_index}    Get Cloud vCU Cell Group ID by Cell ID    cell_index=${deleted_cell_index}   mbts_id=${mrbts_id}
    ...    nrbts_id=${nrbts_id}    nrdu=${nrdu}   alias=${conn_alias}

    Log To Console  vCU save deleted cell info
    ${nrcell_id_list}   vcu_operations.vCU Get Cell List From Webem   gnb_index=${gnb_index}

    Log To Console    \n****vCU NRCELL_id_list=${nrcell_id_list}
    ${NRCELLGRP_id_list}   Get Cloud NRCELLGRP ID list From vCU SCF File   scf_path=${vcu_scf_path}
    Log To Console    \n****vCU NRCELLGRP_id_list=${NRCELLGRP_id_list}

    ${del_cell_value}=    Convert To String    ${deleted_cell_index}
    ${to_be_deleted_NRCELL_id}  Set Variable  ${del_cell_value}
    ${to_be_deleted_NRCELLGRP_id}  Set Variable  ${grp_id}

    ${NRCELL_dn}  Set Variable  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${to_be_deleted_NRCELL_id}
    ${NRCELLGRP_dn}  Set Variable  MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-${to_be_deleted_NRCELLGRP_id}
    ${NRDU_dn}   Set Variable   MRBTS-${mrbts_id}/NRBTS-${mrbts_id}/NRDU-${nrdu}

    ${deleted_cell_info}   Create Dictionary   cell_id=${to_be_deleted_NRCELL_id}  nrdu=${nrdu}   nrcellgrpId=${to_be_deleted_NRCELLGRP_id}

    Log To Console    \n****vCU delete nrcell and nrcellgrp
    Cloud vCU Delete Delta Plan Managed Object Should Be Successful    plan_id=${plan_id}     mo_dn=${NRCELL_dn}    alias=${conn_alias}
    Cloud vCU Delete Delta Plan Managed Object Should Be Successful    plan_id=${plan_id}     mo_dn=${NRCELLGRP_dn}    alias=${conn_alias}

    Log To Console    \n****vCU delete refNrCellGroup
    ${refgrp_id_index_str}    Convert To Integer    ${refgrp_id_index}
    ${operation}=   Create Dictionary    operation_type=remove    parameter_path=/refNrCellGroup/${refgrp_id_index_str}
    ${updated_paras_list}    Create List    ${operation}
    Update Cloud vCU Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${NRDU_dn}   updated_paras_list=${updated_paras_list}   alias=${conn_alias}

    Log To Console   ***vCU delete cell validate delta plan
    Validate Cloud vCU Delta Plan    plan_id=${plan_id}    alias=${conn_alias}
    Log To Console    \n****vCU delete cell activate delta plan
    Cloud vCU Activate Delta Plan Should Be Successful     plan_id=${plan_id}    alias=${conn_alias}
    [Return]    ${deleted_cell_info}    ${vcu_scf_path}
    [Teardown]    vcu_gen.logout_rest    alias=${conn_alias}

Cloud vCU Add Cell By Copy Cell
    [Arguments]     ${base_cell_id}   ${cell_dict}
    ...   ${gnb_index}=0   ${scfc_load_file}=${None}
    [Documentation]    Vdu Copy a cell from a existing cell

    ...   | =Input Parameters= | =Mandatory= | =Description= |
#    ...    | added_cell_id   | yes | nrcell id of the added cell|
    ...    | base_cell_id    | yes | the reference cell id for copy |
    ...    | cell_dict       | yes | the infos of added cell, like {nrdu=1}|
    ...    | vdu_index       | No | the index of vdu, default value is 0 |
    ...    | gnb_index       | No | the index of gnb, default value is 0 |
    ...    | scfc_load_file  | yes | vCU scfc file include base cell |
    ...   *Example*
    ...   | ${cell_dict} | create dictionary  | nrdu=1 | lcrId=9 | nrcellgrpId=9 |  physCellId=419 | rmod_id=9 |
    ...   | Cloud vCU Add Cell By Copy Cell | base_cell_id=8 | cell_dict=${cell_dict} | vcu_scfc.xml |
    ...   *Return*
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Log To Console    \n****Cloud vCU Add Cell By Copy Cell
    ${conn_alias}   generic_utils.get_unique_id_string
    vcu_gen.login_rest   gnb_index=${gnb_index}   alias=${conn_alias}

    Log To Console    \n****vCU backup current scfc
    ${scf_path}    Get Cloud vCU SCF From Current Plan    alias=${conn_alias}

    Log To Console    \n****vCU load base cell scfc file
    Check Cloud vCU Max Load Plan Number And Delete One If Reach Max Number    alias=${conn_alias}
    ${load_plan_id}    ${load_action_id}    Cloud vCU Load SCFC File     scfc_load_file=${scfc_load_file}   alias=${conn_alias}
    Log To Console    \n****vCU load_plan_id=${load_plan_id}

    Log To Console    \n****gvCU et bts info
    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get Cloud MRBTS Id From vCU SCF    scf_path=${scf_path}
    ${DN}   set variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}

    Log To Console    \n****vCU create delta plan
    ${uni_id}   generic_utils.get_unique_id_string
    Cloud vCU Check Max Delta Plan Number And Delete One If Reach Max Number    alias=${conn_alias}
    ${plan_id}   ${action_id}    Cloud vCU Generate Delta Plan   plan_name=add_cell_${uni_id}    alias=${conn_alias}

    Log To Console    \n****vCU get mo_uuid and prarent_mo_uuid
    ${parent_plan_info_list}   cu.get_tree_of_staged_plan    plan_id=${load_plan_id}    connection=${conn_alias}
    ${plan_info_list}   cu.get_tree_of_delta_plan    plan_id=${plan_id}    connection=${conn_alias}

    ${nrcell_mo_uuid}    get_value_from_plan_tree_info     info_list=${parent_plan_info_list}
    ...   dist_name=${DN}/NRCELL-${base_cell_id}   key=mo_uuid
    ${parent_mo_uuid}    get_value_from_plan_tree_info     info_list=${plan_info_list}
    ...   dist_name=${DN}  key=mo_uuid

    Log To Console    \n****vCU Copy NRCELL MO from NRCELL-${base_cell_id}
    ${added_cell_id}    set variable    ${cell_dict["cell_id"]}
    Copy Cloud vCU MO Into Delta Plan    plan_id=${plan_id}   source_plan_id=${load_plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcell_mo_uuid}   new_instance_id=${added_cell_id}    include_children_objects=${True}    alias=${conn_alias}

    Log To Console    \n****vCU Copy NRCELLGRP MO from NRCELLGRP, update nrCellList
    ${nrcell_grp_id}    set variable    ${cell_dict['nrcellgrpId']}
    ${nrcell_grp_id_str}    Convert To String   ${nrcell_grp_id}
    ${nrcellgrp_mo_uuid}    get_value_from_plan_tree_info
    ...   info_list=${parent_plan_info_list}    dist_name=${DN}/NRCELLGRP-${nrcell_grp_id}   key=mo_uuid
    Copy Cloud vCU MO Into Delta Plan   plan_id=${plan_id}   source_plan_id=${load_plan_id}   parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${nrcellgrp_mo_uuid}   new_instance_id=${added_cell_id}   include_children_objects=${True}    alias=${conn_alias}

    Log To Console    \n****vCU Add refNrCellGroup into NRDU-${cell_dict['nrdu']}
    ${NRCELLGRP_id_list}   Get Cloud NRCELLGRP ID list From vCU SCF File   scf_path=${scf_path}
    ${nrcell_grp_list_len}    Get Length    ${NRCELLGRP_id_list}
    ${nrcellgrp_index}    set variable   ${nrcell_grp_list_len}
    Log To Console    nrcell_grp_id=${nrcell_grp_id},nrcell_grp_id_str=${nrcell_grp_id_str},nrcell_grp_list_len=${nrcell_grp_list_len}

    ${operation}=   Create Dictionary    operation_type=add    parameter_path=/refNrCellGroup/${nrcellgrp_index}    value=${nrcell_grp_id_str}
    ${updated_paras_list}    Create List    ${operation}
    Update Cloud VCU Delta Plan Parameter    plan_id=${plan_id}  mo_dn=${DN}/NRDU-${cell_dict['nrdu']}
    ...   updated_paras_list=${updated_paras_list}    alias=${conn_alias}

    Log To Console    \n****vCU add cell validatedelta plan
    Validate Cloud vCU Delta Plan    plan_id=${plan_id}    alias=${conn_alias}
    Log To Console    \n****vCU add cell activate delta plan
    Cloud vCU Activate Delta Plan Should Be Successful     plan_id=${plan_id}    alias=${conn_alias}
   [Teardown]    vcu_gen.logout_rest    alias=${conn_alias}

Get Cloud vCU SCF From Current Plan
    [Arguments]    ${alias}=default    ${timeout}=60
    [Documentation]  Get VCU SCF From Current Plan

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...    | alias     | yes | return value rest login |
    ...    | timeout    | No | time out |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${scf_full_path} | Get Cloud vCU SCF From Current Plan | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${file_name}   generic_utils.get_unique_id_string  prefix=scf_vcu_   suffix=.xml   precise=LOW
    #todo
    ${tmp_scf_full_path}    set variable    /home/ute/${file_name}
    cu.get_current_plan_file   path=${tmp_scf_full_path}  timeout=${timeout}    connection=${alias}
    [Return]  ${tmp_scf_full_path}


Get Cloud NRCELLGRP ID list From vCU SCF File
   [Arguments]  ${scf_path}
   [Documentation]      Get Cloud NRCELLGRP ID list From vCU SCF File.
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...	   | scf_path | yes | scf_path, e.g, /tmp/scf.xml  |
    ...
    ...    *RETURN VALUE*
    ...    NRCELLGRP id list
    ...
    ...    Example
    ...    | ${NRCELLGRP_id_list} | Get Cloud NRCELLGRP ID list From vCU SCF File|
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*MRBTS-\\d+/NRBTS-\\d+/NRCELLGRP-(\\d+)"   1
    [Return]   ${result}

Get Cloud MRBTS Id From vCU SCF
    [Arguments]    ${scf_path}
    [Documentation]   Get Cloud MRBTS Id From vCU SCF

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb index | No | cu index, default is 0 |
    ...    *RETURN VALUE*
    ...    - MRBTS_ID from vCU Scf
    ...    *Example*
    ...    | ${mrbts_id} | Get MRBTS Id From vCU SCF |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}  Set Variable If  ${result}   ${result[0][0]}
    ${nrbts_id}  Set Variable If  ${result}   ${result[0][1]}
    ${nrdu_id}   Set Variable If  ${result}   ${result[0][2]}
    [Return]  ${mrbts_id}   ${nrbts_id}  ${nrdu_id}


Get Cloud vCU Conf From SCF
    [Arguments]  ${scf_path}=${EMPTY}   ${gnb_index}=0
    [Documentation]  Get Cloud vCu Conf From SCF file.

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...	   | scf_path  | no | abosolute path of scf file, if it's ${EMPTY} it will download scf from CURRENT plan, default is ${EMPTY} |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of configuration in SCF file.
    ...    example: {'mrbts_id': '1234', 'nrbts_id': '5678', 'nrdu_id': '1' }
    ...
    ...    Example
    ...    | ${vcu_conf} | Get Cloud vCU Conf From SCF | scf_path=/home/ute/a.scf |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************|
    ...
    Log    ${gnb_index}
    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get Cloud vCU SCF From Current Plan
       ...    ELSE    Set Variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get Cloud MRBTS Id From VCU SCF    scf_path=${scf_path}
    ${mnl_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/MNL-1   attribute=version
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  tnl_version=${tnl_version}
    ...  nrbts_version=${nrbts_version}

    [Return]  ${conf}

Get Cloud VCU Parameter Value Online
   [Arguments]   ${dn}    ${parameter_path}    ${alias}=default
    [Documentation]   Get VCU Parameter Value Online
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    |  dn             | Yes   |  Distname of parameter  |
    ...    |  parameter_path |  Yes  |  simple and simple list parameter given like btsName or nrCellList |
    ...                              |  complex parameter given the struncture like staticRoutes/1/destIpAddr
    ...    |  gnb_index      | No   |  gnb index |
    ...
    ...    *RETURN VALUE*
    ...    parameter value, if it's simple or complex parameter, returns string type
    ...    if it's a simple list type parameter, it will return a list.
    ...
    ...    Example
    ...  | Get Cloud VCU Parameter Value Online | dn=MRBTS-1/NRBTS-1/NRCELLGRP-0 | parameter_path=nrCellList |

    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${dn}   set variable   ${dn.strip()}
    ${parameter_path}   set variable   ${parameter_path.strip()}
    ${paras_info}=   cu.search_parameters_of_current_plan   parameter_name=${parameter_path}   connection=${alias}

    ${starts_with_root}   Set Variable   ${parameter_path.startswith("/")}
    ${para_struct_path}  Run Keyword If  "${starts_with_root}"=="${True}"   Set Variable   ${parameter_path.replace("/", "", 1)}
    ...    ELSE   Set Variable   ${parameter_path}

    ${value}   get_online_parameter_value  paras_info=${paras_info}  dn=${dn}  para_struct_path=${para_struct_path}
    [Return]  ${value}

Cloud vCU Delete Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}    ${alias}=default
    [Documentation]   Cloud vCU Delete Delta Plan Managed Object Should Be Successful
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | managed object dist name |
    ...   | alias   | yes | return value rest login |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | Cloud vCU Delete Delta Plan Managed Object Should Be Successful | plan_id=${delta_plan_id}
    ...    | mo_dn=MRBTS-XXXX/NRBTS-XXXX/NRCELL-1/NRREL-1 | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ${mo_uuid}   _Get Cloud vCU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}     alias=${alias}
    ${delete_res}=   cu.delete_managed_object_of_delta_plan  plan_id=${plan_id}  mo_uuid=${mo_uuid}    connection=${alias}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...    _Cloud vCU Delete Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${delete_res['action_id']}
    ...    alias=${alias}

_Get Cloud vCU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}   ${alias}=default
    [Documentation]   _Get Cloud vCU Specifical MO UUID

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | alias | yes | return value rest login |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _Get Cloud vCU Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1| alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    @{name_list}=   split_string    ${mo_dn}   /
    set suite variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _Get Cloud vCU Specifical MO UUID via DN Name   ${plan_id}  ${name}   alias=${alias}
    END
    [Return]   ${mouuid}

_Get Cloud vCU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}   ${alias}=default
    [Documentation]  _Get Cloud vCU Specifical MO UUID via DN Name

    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    | alias | yes | return value rest login |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _Get Cloud vCU Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}   connection=${alias}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
        run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
    ...  run keywords  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
        run keyword if  '${mo_info["parent_mo_uuid"]}'=='None' and '${mo_info["name"]}'=='${name}'  run keywords
    ...  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

_Cloud vCU Delete Delta Plan Managed Object Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}   ${alias}=default
    [Documentation]   _CU Delete Delta Plan Managed Object Operation Should Be Successful
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | action_id of delete_managed_object_of_delta_plan |
    ...    | alias     | yes | return value rest login |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Delete Delta Plan Managed Object Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ${res}=  cu.get_delete_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}    connection=${alias}
    should be equal as strings  ${res['status']}  success


Cloud vCU Generate Delta Plan
    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${alias}=default
    [Documentation]   Cloud vCU Generate Delta Plan

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...  | alias           | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>)
    ...
    ...   Example
    ...  | vCU rest login |
    ...  | ${plan_id} | ${action_id} | Cloud vCU Generate Delta Plan | plan_name=my_plan_name | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${out}  cu.generate_delta_plan  plan_name=${plan_name}   plan_description=${plan_description}    connection=${alias}

    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}

    Cloud vCU Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}    alias=${alias}
    [Return]   ${temp_plan_id}   ${temp_action_id}


_Cloud vCU Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}    ${alias}=default
    [Documentation]   _Cloud vCU Generate Delta Plan Status Should Be Expected

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | action_id       | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...  | alias           | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vcu rest login |
    ...  | _Cloud vCU Generate Delta Plan Status Should Be Expected | action_id=<my_operation_id> | expected_status=success | alias
    ...
    ${out}   cu.get_action_state_of_generating_delta_plan   action_id=${action_id}    connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"


Cloud vCU Generate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}    ${alias}=default
    [Documentation]   Cloud vCU Generate Delta Plan Status Should Be Successful

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | action_id    | yes | action_id |
    ...  | alias         | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vcu rest login |
    ...  | Cloud vCU Generate Delta Plan Status Should Be Successful | action_id=<my_action_id> | alias
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Wait Until Keyword Succeeds  30   3  _Cloud vCU Generate Delta Plan Status Should Be Expected   action_id=${action_id}
    ...    expected_status=success    alias=${alias}

Validate Cloud vCU Delta Plan
    [Arguments]  ${plan_id}    ${alias}=${None}
    [Documentation]   Validate Delta Plan By REST

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_id    | yes | plan_id |
    ...   | alias    | No | alias, default is ${None} |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | vCU rest login |
    ...  |  ${validation_id} | Validate Delta Plan By REST | plan_id=${planid} | alias
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...

    ${out}  cu.validate_delta_plan   plan_id=${plan_id}    connection=${alias}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    Validate Cloud vCU Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}   alias=${alias}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}


_Validate Cloud vCU Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}  ${alias}=${None}
    ${out}   cu.get_action_state_of_validating_delta_plan   action_id=${action_id}   plan_id=${plan_id}    connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Validate Cloud vCU Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}   ${alias}=${None}
    [Documentation]   Validate Delta Plan Status Should Be Successful
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   | alias         | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vCU rest login |
    ...  | Validate Cloud vCU Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Cloud vCU Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
     ...   alias=${alias}
    [Return]  ${rtn}

Cloud vCU Activate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}   ${alias}=default
    [Documentation]   Cloud vCU Activate Delta Plan Should Be Successful
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | yes | delta plan id |
    ...   | alias         | yes | return value rest login |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | Cloud vCU Activate Delta Plan Should Be Successful | plan_id=${delta_plan_id}  | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************

    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}   connection=${alias}

    ${out}    Wait until keyword succeeds  800   30
    ...  _Cloud vCU Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}   operation_id=${active_res['operation_id']}
    ...  expected_status=success    alias=${alias}

_Cloud vCU Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}    ${expected_status}   ${alias}=default
    [Documentation]   _Cloud vCU Activating Delta Plan Operation Should Be Successful

    ...    *Parameter Description*
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    *Example*
    ...    | Cloud vCU Activate Delta Plan Should Be Successful | plan_id=xxx | operation_id=xxx |
    ...

    ${res}=    cu.get_operation_state_of_activating_delta_plan   plan_id=${plan_id}   operation_id=${operation_id}
    ...  connection=${alias}
    Should Be True  "${res["status"]}"=="${expected_status}"
    [Return]    ${res}

Cloud vCU Check Max Delta Plan Number And Delete One If Reach Max Number
    [Arguments]    ${alias}=default
    [Documentation]   Cloud vCU Check Max Delta Plan Number And Delete One If Reach Max Number

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | alias         | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vCU rest login |
    ...  | Cloud vCU Check Max Delta Plan Number And Delete One If Reach Max Number | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${all_plans}   cu.get_delta_plan_list    connection=${alias}
    Run Keyword If  ${all_plans.__len__()}==1   cu.delete_delta_plan   plan_id=${all_plans[0]["plan_id"]}    connection=${alias}


Update Cloud vCU Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${alias}=default
    [Documentation]   Update Cloud vCU Delta Plan Parameter Should Be Successful

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   | alias         | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vcu rest login |
    ...  | Update Cloud vCU Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Cloud vCU Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    ...   alias=${alias}
    [Return]  ${rtn}


_Update Cloud vCU Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}    ${alias}=${None}
    [Documentation]    _Update Cloud vCU Delta Plan Parameter Should Be Expected
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...   | alias         | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vcu rest login |
    ...  | _Update Cloud vCU Delta Plan Parameter Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...  | alias |
    ...

    ${out}   cu.get_action_state_of_updating_parameters_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}   connection=${alias}
    Log To Console    \n****out=${out}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Update Cloud vCU Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_list}  ${timeout}=30   ${alias}=${None}
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO

    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...   | alias         | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vcu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
    ...  | ${validation_res} | Update Cloud vCU Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace | alias |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${timeout}   convert to integer  ${timeout}
    ${mo_uuid}   _Get Cloud vCU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}     alias=${alias}
    ${out}  cu.update_parameters_of_delta_plan   plan_id=${plan_id}  mo_uuid=${mo_uuid}
     ...   parameter_change_list=${updated_paras_list}   connection=${alias}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}    Update Cloud vCU Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}  alias=${alias}
    [Return]  ${out}


Cloud vCU Load SCFC File
    [Arguments]     ${scfc_load_file}    ${alias}=default
    [Documentation]   Cloud vCU Load SCFC File
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | scfc_load_file     | yes | vCU scfc file
    ...   | alias               | yes | return value rest login |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    log to console   Start Cloud vCU Load SCFC File
    ${upload_plan_response}=  cu.upload_plan_file    path_to_plan_file=${scfc_load_file}    connection=${alias}
    wait until keyword succeeds  10s  1s
    ...    Cloud vCU Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}    alias=${alias}
    [Return]    ${upload_plan_response['plan_id']}    ${upload_plan_response['action_id']}

Cloud vCU Upload Plan Operation Should Be Successful
     [Arguments]  ${upload_action_id}    ${alias}=default
    [Documentation]   checking upload plan operation status should be successful
     ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    | alias            | yes | return value rest login |
    ...    *RETURN VALUE*
    ...    None
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${upload_operation_response}=  cu.get_operation_state_of_uploading_plan  ${upload_action_id}    connection=${alias}
    should be equal as strings  ${upload_operation_response['status']}  success
    Log To Console    \n****Upload Plan Success


Copy Cloud vCU MO Into Delta Plan
    [Arguments]  ${plan_id}   ${source_plan_id}   ${parent_mo_uuid}   ${mo_uuid}     ${new_instance_id}
    ...   ${include_children_objects}    ${timeout}=30    ${alias}=${None}
    [Documentation]    Copy Cloud vCU MO Into Delta Plan
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | plan_id          | yes | plan id for delta plan         |
    ...    | source_plan_id   | yes | source plan id, could be delta plan or current plan |
    ...    | parent_mo_uuid   | yes | parent managed object id in source plan|
    ...    | mo_uuid          | yes | Unique managed object id which is being copied in source plan|
    ...    | new_instance_id  | yes | new instance id |
    ...    | include_children_objects | yes | is include children objects |
    ...    | timeout          | no  | Timeout for the operation, defaults to 30|
    ...   | alias               | yes | return value rest login |
    ...
    ...   *Example*
    ...   | vCU login rest |
    ...   | Copy Cloud vCU MO Into Delta Plan | plan_id=${plan_id} |  source_plan_id=${plan_id} |  parent_mo_uuid=${parent_mo_uuid}
    ...   | mo_uuid=${nrcell_mo_uuid} |  new_instance_id=9 |   include_children_objects=${True} | alias |
    ...
    ...   *Return*
    ...   None
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    Log To Console    \n****start Copy Cloud vCU MO Into Delta Plan
    ${rtf}   cu.copy_managed_objects_into_delta_plan
    ...    plan_id=${plan_id}
    ...    source_plan_id=${source_plan_id}
    ...    parent_mo_uuid=${parent_mo_uuid}
    ...    mo_uuid=${mo_uuid}
    ...    new_instance_id=${new_instance_id}
    ...    include_children_objects=${include_children_objects}
    ...    timeout= ${timeout}
    ...    connection=${alias}
    wait until keyword succeeds   10x   2s
    ...   _Copy Cloud vCU MO Into Delta Plan Should Be Successful   plan_id=${plan_id}   action_id=${rtf['action_id']}   expected_status=success
    ...   alias=${alias}


_Copy Cloud vCU MO Into Delta Plan Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}  ${expected_status}   ${alias}=${None}
    ${out}   cu.get_copy_managed_objects_into_delta_plan_status    plan_id=${plan_id}  action_id=${action_id}   connection=${alias}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Check Cloud vCU Max Load Plan Number And Delete One If Reach Max Number
    [Arguments]   ${alias}=default
    [Documentation]   Check Cloud vCU Max Load Plan Number And Delete One If Reach Max Number
    ...
    ...  | =Input Parameters= | =Mandatory= | =Description= |
    ...  | alias            | yes | return value rest login |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | ${alias}  vcu Rest Login |
    ...  | Check Cloud vCU Max Delta Plan Number And Delete One If Reach Max Number | alias=${alias} |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${all_plans}   cu.get_staged_plans_list  connection=${alias}
    log to console   all_plans=${all_plans}
    #todo
    Run Keyword If  ${all_plans.__len__()}>=3   cu.delete_file_upload_operation   connection=${alias}


Get Cloud vCU Cell Group ID by Cell ID
    [Arguments]  ${cell_index}=1   ${mbts_id}=1   ${nrbts_id}=1    ${nrdu}=1    ${alias}=default
    [Documentation]    Get Cloud vCU Cell Group ID by Cell ID
    ...
    ...   | =Input Parameters= | =Mandatory= | =Description= |
    ...    | cell_index | yes | the cell index of deleted
    ...    | mbts_id | Yes | the index of vCU, default value is 0 |
    ...    | nrdu | Yes | nrduid |
    ...    | alias  | yes | return value rest login |
    ...    *******************
    ...    *Author* changyan.li@nokia-sbell.com
    ...    *Group* VRF_HAZ4_13
    ...    *******************
    ...
    ${NRDU_dn}   Set Variable   MRBTS-${mbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu}
    ${grp_value_list}   Get Cloud VCU Parameter Value Online    dn=${NRDU_dn}   parameter_path=refNrCellGroup   alias=${alias}
    log to console   refNrCellGroup_value=${grp_value_list}
    ${grp_id}    set variable    ${0}
    ${refgrp_id_index}    set variable    ${0}
     FOR    ${grp_id}    IN    @{grp_value_list}
         ${grp_id_value}    Convert To Integer    ${grp_id}
         ${cell_grp_dn}    set variable    MRBTS-${mbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-${grp_id_value}
         ${grp_cell_list}   Get Cloud VCU Parameter Value Online   dn=${cell_grp_dn}   parameter_path=nrCellList   alias=${alias}
         ${cell_index_str}    Convert To String    ${cell_index}
         ${index}=    Get Index From List    ${grp_value_list}    ${grp_id}
         run keyword if    '${cell_index_str}' in @{grp_cell_list}
         ...    Run Keywords   Set Suite Variable    ${grp_id}    ${grp_id_value}
         ...    AND    Set Suite Variable    ${refgrp_id_index}    ${index}
         ...   AND  exit for loop
     END

    [Return]   ${grp_id}    ${refgrp_id_index}

Verify All Cells Are Enabled for vCU
    [Arguments]    ${gnb_index}=0
    [Documentation]
    ...    This keyword is to verify cell enabled on vCU.
    ...    - [Keyowrd Details]
    ...    This keyword is to verify cell enabled on vCU.
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | gnb_index | No | The GNB index. Default value is 0. |
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |
    ...
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 12.06.2024 - - Created
    ...    *******************
    ...    *Author* wenjin.zhang@nokia-sbell.com
    ...    *Group* VRF_HAZ4_01
    ...    *******************
    log to console    Verify All Cells Are Enabled for vCU
    ${cells_id_list}    vcu_operations.vCU Get Cell List From Webem    gnb_index=${gnb_index}
    vCU Cells Status Should Be As Expected    cells_id_list=${cells_id_list}   operational_state=enabled
      ...     gnb_index=${gnb_index}
