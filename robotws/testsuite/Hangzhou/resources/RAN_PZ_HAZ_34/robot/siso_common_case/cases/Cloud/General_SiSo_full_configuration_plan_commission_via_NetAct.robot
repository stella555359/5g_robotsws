*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot
Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_bts.robot
Library           taf.rfrl.cbts.devices.netact.NetactOperations    WITH NAME   netact_ope
Resource  taf/rfrl/cbts/robot/netact/netact.robot
Library    taf.nms.netact
Resource   taf/rfrl/cbts/robot/netact/netactlcm.robot

*** Variables ***


*** Keywords ***
General_SiSo_full_configuration_plan_commission_via_NetAct
    [Documentation]
    ...    *****************
    ...    [TEST DESCRIPTION] The purpose of this test case is to verify full plan commission via netact, especially when introducing new modules.
    ...    *****************
    ...    [TEST STEPS]
    ...    1.  Get a full planned configuration file via NetAct from "CM Operations Manager"(need upload to keep configuration syn with
    ...    the runtime BTS)
    ...    2. Create a New plan for full provision via NetAct from "CM Operations Manager", it may need several minutes to get the new plan ready
    ...    3. Activate a full planned configuration file via NetAct from "CM Operations Manager",
    ...     plan should be successfully updated with no error.

    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.14.2024
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${netact_alias}=netact  ${netact_scf_name}=test_full_backup.xml  ${netact_plan_name}=netact_scf_import  ${cu_commission}=${False}
    ...    ${HOSTNAME}=${tl.nms.netact[0].ssh_connections_info[0].addr}   ${USERNAME}=${tl.nms.netact[0].ssh_connections_info[0].username}
    ...   ${PASSWORD}=${tl.nms.netact[0].ssh_connections_info[0].password}
    Add Node    cmwas    ${HOSTNAME}    ${USERNAME}    ${PASSWORD}    alias=${netact_alias}
    ${web_url}=    Detect WEB URL    alias=${netact_alias}
    Add WEB URL    ${web_url}    ${USERNAME}    ${PASSWORD}    alias=${netact_alias}
    Cloud Full Commission Via Netact   tl_id=${mrbtsID}    netact_alias=${netact_alias}    netact_scf_name=${mrbtsID}_${netact_scf_name}
    ...   netact_plan_name=${mrbtsID}_${netact_plan_name}
    Run Keyword If  ${cu_commission}  Cloud Full Commission Via Netact   tl_id=${mrbts_id_cu}    netact_alias=${netact_alias}
    ...  netact_scf_name=${mrbts_id_cu}_${netact_scf_name}
    ...   netact_plan_name=${mrbts_id_cu}_${netact_plan_name}
    [Teardown]    Run Keywords  Delete Node    cmwas    alias=${netact_alias}
    ...   AND   Clean All    alias=${netact_alias}

Cloud Full Commission Via Netact
    [Arguments]  ${tl_id}=${mrbtsID}   ${netact_alias}=netact  ${netact_scf_name}=${tl_id}_test_full_backup.xml
    ...   ${netact_plan_name}=${tl_id}_netact_scf_import
    [Documentation]    *****************
    ...    This keyword is used for full commission via NetAct.
    ...    - [Keyword Details]
    ...    1.Delete  plan.
    ...    2.Upload configuration.
    ...    3.Export configuration.
    ...    4.Delete NE data.
    ...    5.Import configuration.
    ...    6.Test CM Operations Provision Plan.
    ...
    ...    | =Input Parameters= | =Mandatory= | =Description= |
    ...    | tl_id | Yes | The MRBTS ID. |
    ...    | netact_alias | Yes | The alias for NetAct. |
    ...    | netact_scf_name | Yes | The name for the SCF file. |
    ...    | netact_plan_name | Yes | The name for the plan. |
    ...
    ...    | =Return Values= | =Description= |
    ...    | None | This keyword does not return any value. |

    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 30.05.2024 - - Created
    ...    *******************
    ...    * Owner: kaihui.fan@nokia-sbell.com
    ...    * Group: VRF_HAZ4_04
    ...    *******************

    Upload Configuration    dist_names=PLMN-PLMN/MRBTS-${mrbtsID}    verbose=True  alias=${netact_alias}
    ${random_str}  Generate Random String
    Run keyword and ignore error  Create Plan Configuration   name=${netact_plan_name}${random_str}   alias=${netact_alias}
    Export Configuration    file_name=${netact_scf_name}  local_dir=${SAVE LOG DIRECTORY}  operation_type="plan"
    ...    plan_name=${netact_plan_name}${random_str}
    ...   dist_names=PLMN-PLMN/MRBTS-${tl_id}  alias=${netact_alias}  
    Log to console    Delete NE data
    Run keyword and ignore error    delete_ne_data_from_configurator
    ...    dist_names=PLMN-PLMN/MRBTS-${tl_id}/AgentDiscovery-1/NeIdentificationResult-1    alias=${netact_alias}
    Run keyword and ignore error    Delete Plan     ${netact_plan_name}    alias=${netact_alias}
    Import Configuration    ${netact_scf_name}    local_dir=${SAVE LOG DIRECTORY}   plan_name=${netact_plan_name}   alias=${netact_alias}
    Log to console    Test CM Operations Provision Plan
    Provision Plan    ${netact_plan_name}    PLMN-PLMN/MRBTS-${tl_id}    backup_plan_name=${netact_plan_name}_backup
    ...               create_backup_plan=${False}    provisioning_operation=preactivate    alias=${netact_alias}
    taf.nms.netact.Validate Plan    ${netact_plan_name}    PLMN-PLMN/MRBTS-${tl_id}   alias=${netact_alias}
    taf.nms.netact.Activate Preactivated Plan   ${netact_plan_name}    PLMN-PLMN/MRBTS-${tl_id}     alias=${netact_alias}
    Provision Plan    ${netact_plan_name}    PLMN-PLMN/MRBTS-${tl_id}    backup_plan_name=${netact_plan_name}_backup
    ...               create_backup_plan=${True}     alias=${netact_alias}
    Run keyword and ignore error    Delete Plan     ${netact_plan_name}${random_str}    alias=${netact_alias}


