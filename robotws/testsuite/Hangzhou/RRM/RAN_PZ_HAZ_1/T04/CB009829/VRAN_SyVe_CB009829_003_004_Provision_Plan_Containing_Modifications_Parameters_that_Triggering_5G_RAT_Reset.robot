*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB009829_003_CM_CR_vCU_Provision plan containing modifications to
...   parameters that are triggering only 5G RAT reset with MantaRay NM Configurations UI
...   and RAN_ST_CB009829_004_CM_CR_vDU_Provision plan containing modifications to parameters that are triggering only
...   5G RAT reset with MantaRay NM Configurations UI
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
@{param_value_list_du}    true    false
@{param_value_list_cu}    true    false
&{plan_info_cb009829_vcu}      scf_distName=MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}
...    mo_dn=PLMN-PLMN/MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}    param_name=actExt2N77Support    param_value=${param_value_list_cu}
&{plan_info_cb009829_vdu}      scf_distName=MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}
...    mo_dn=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    param_name=actAdaptiveSchedulerBudgetOlc    param_value=${param_value_list_du}

${vCU_oamssh_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${vDU_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CB009829_003_004_Provision_Plan_Containing_Modifications_Parameters_that_Triggering_5G_RAT_Reset
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    16.12.2024, lixin.kang@nokia-sbell.com, draft
    vCU Provision Plan with 5G Rat Reset Param via NetAct
    vDU Provision Plan with 5G Rat Reset Param via NetAct

${NE} Provision Plan with 5G Rat Reset Param via NetAct
    Log To Console    ${NE} Provision Plan with 5G Rat Reset Param via NetAct
    Step 1: Create Plan With 5G Rat Reset Param For ${NE}
    Step 2: Provision Plan And Check ${NE} Status
    Step 3: Check Modified Parameter From NetAct
    Step 4: Provision Backup Plan From NetAct

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    Setup NetAct    ${NETACT}
    Get Current SCF For vCU
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC
    Teardown NetAct
    SSHLibrary.Close All Connections

Step ${index}: Create Plan With 5G Rat Reset Param For ${NE}
    Log To Console    Step ${index}: Create Plan With 5G Rat Reset Param For ${NE}
    Set Test Variable    ${plan_info}    ${plan_info_cb009829_${NE}}
    Set Test Variable    ${current_ne_id}    ${${NE}_id}
    ${timestamp}    AIC_NetAct.Generate Formatted Timestamp
    Should Be String    MRBTS-${current_ne_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${current_ne_id}_${timestamp}
    ${BTS_scf}    Set Variable If   '${NE}'=='vCU'    ${TEST_LOG_DIRECTORY}/vcu_scf.xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info["scf_distName"]}"]
    ${current_value}   L_XML.Get Element Text   ${scf_xml}
    ...    .//managedObject[@distName="${plan_info["scf_distName"]}"]/p[@name="${plan_info["param_name"]}"]
    ${value_list}    Set Variable    ${plan_info["param_value"]}
    Remove Values From List    ${value_list}     ${current_value}
    ${value}    Evaluate    random.choice(${value_list})    modules=random, sys
    ${param_dic}    Create Dictionary    ${plan_info["param_name"]}=${value}
    Set Test Variable    ${param_dic}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${current_ne_id}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info["mo_dn"]}   &{param_dic}

Step ${index}: Provision Plan And Check ${NE} Status
    Log To Console   Step ${index}: Provision Plan And Check Site Status
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${current_ne_id}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    ${result}    Run Keyword and Return Status    Check ${NE} Resetting
    ${result_Activate}    tafssh.Read Output
    Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    Should Be True    ${result}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    plan_name=${plan_name}_backup   operation_type=plan

Step ${index}: Check Modified Parameter From NetAct
    Log To Console    Step ${index}: Check Modified Parameter From NetAct
    Wait Until Keyword Succeeds    5min    30s
    ...    NetAct Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${current_ne_id}   dist_name=${plan_info["mo_dn"]}   &{param_dic}

Step ${index}: Provision Backup Plan From NetAct
    Log To Console    Step ${index}: Provision Backup Plan From NetAct
    NetAct Provision Plan    plan_name=${backup_plan}    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Get Current SCF For vCU
    Login To vCU By Rest
    cu.get_current_plan_file    path=${TEST_LOG_DIRECTORY}/vcu_scf.xml
    Logout To vCU By Rest

Check ${NE} Resetting
    Wait Until Keyword Succeeds    300s    3s    Check IP Is Pingable    ${${NE}_oamssh_ip}    expect_pingable=${False}
