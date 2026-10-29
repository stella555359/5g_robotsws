*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for VRAN_SyVe_CB008660-A_002_CM_Adding new distname-type parameter from NMS
...    for NE/cells using NMS
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{plan_info_8660_002}      scf_distName=MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}
...    mo_id=PLMN-PLMN/MRBTS-${vCU_id}/NRBTS-${NRBTS_ID}    parent_param=e2Plane    param_name=ipV4AddressDN1
...    shortenedDN=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1   incorrect_shortenedDN=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-10
${cu_oamssh_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
TC__VRAN_SyVe_CM_Adding_New_DistName_Type_Parameter_From_NetAct_CB008660-A_002
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    19.01.2023, lixin.kang@nokia-sbell.com, draft
    Step 1: TC Parameters Check
    Step 2: Create Plan With Correct New DistName Type Parameter
    Step 3: Provision Plan And Check Behavior
    Step 4: Check Modified Parameter from Netact after Provision
    Step 5: Create Plan With Incorrect New DistName Type Parameter
    Step 6: Provision Plan And Check Feedback
    Step 7: Provision Backup Plan From NetAct

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    Get Current SCF For vCU
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    Particular Teardown
    Common Test Teardown For AIC
    Teardown NetAct

Get Current SCF For vCU
    Login To vCU By Rest
    cu.get_current_plan_file    path=${TEST_LOG_DIRECTORY}/vcu_scf.xml
    Logout To vCU By Rest

Upload NE Configuration
    [Documentation]    Uploads configuration data from the network is checked
    Log    Upload NE Configuration     console=True
    NetAct CM Upload    dist_names=${ne_dn}

Step ${index}: TC Parameters Check
    Log    Step ${index}: TC parameters check started    console=True
    Set Test Variable    ${plan_info}    ${plan_info_8660_002}
    Set Test Variable    &{DIC_PARAM_VALUE}    ${plan_info['param_name']}=${plan_info['shortenedDN']}
    Set Test Variable    @{LIST_PARAM}      ${DIC_PARAM_VALUE}
    Set Test Variable    &{PARAM_DIC}    ${plan_info['parent_param']}=@{LIST_PARAM}
    Set Test Variable    &{PARAM_DIC_EMPTY}    ${plan_info['parent_param']}=${EMPTY}
    Set Test Variable    &{INCORRECT_DIC_PARAM_VALUE}    ${plan_info['param_name']}=${plan_info['incorrect_shortenedDN']}
    Set Test Variable    @{INCORRECT_LIST_PARAM}      ${INCORRECT_DIC_PARAM_VALUE}
    Set Test Variable    &{INCORRECT_PARAM_DIC}   ${plan_info['parent_param']}=@{INCORRECT_LIST_PARAM}
    ${expected_msg}    Set Variable
    ...    '${plan_info['parent_param']}-1.${plan_info['param_name']}' references non-existing '${plan_info['incorrect_shortenedDN']}' object
    Set Test Variable    ${EXPECED_PDL_ERROR}    Distname parameter ${expected_msg}
    ${mo_scf_dn}    Set Variable    ${plan_info['scf_distName']}
    ${mo_dn}    Set Variable   ${plan_info['mo_id']}
    ${ne_dn}    Set Variable   PLMN-PLMN/MRBTS-${vCU_id}
    Set Test Variable    ${mo_scf_dn}
    Set Test Variable    ${mo_dn}
    Set Test Variable    ${ne_dn}
    Upload NE Configuration
    Set Test Variable   ${scf_initial}    ${TEST_LOG_DIRECTORY}/vcu_scf.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse Xml    ${scf_initial}
    ${status}    ${msg}    Run Keyword And Ignore Error   L_XML.Get Element Text    ${xml_content}
    ...    .//managedObject[@distName="${mo_scf_dn}"]/list[@name="${plan_info['parent_param']}"]/item/p[@name="${plan_info['param_name']}"]
    ${expecte_msg_str}    Set Variable
    ...    './/managedObject[@distName="${mo_scf_dn}"]/list[@name="${plan_info['parent_param']}"]/item/p[@name="${plan_info['param_name']}"]
    ${same_value}    Run Keyword And Return Status   Should Contain    ${msg}    No element matching ${expecte_msg_str}
    Run Keyword If    not ${same_value}    Run Keywords    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value   ${scf_initial}    ${vCU_id}    ${ne_dn}   ${mo_scf_dn}     &{PARAM_DIC_EMPTY}
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Set Test Variable    ${same_value}

Recovery Parameter Value
    [Arguments]    ${init_scf}    ${ne_id}    ${ne_dn}    ${scf_dn}    &{param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    precondition_MRBTS-${ne_id}_${timestamp}
    ${precodition_plan_name}    Set Variable   precondition_MRBTS-${ne_id}_${timestamp}
    ${plan}    NetAct Create And Edit Plan    ${init_scf}    name=${precodition_plan_name}    description=Automation SyVe for MRBTS-${ne_id}
    ...    mo_id=${mo_dn}   scf_distName=${scf_dn}    &{param_dic}
    NetAct Provision Plan    plan_name=${precodition_plan_name}   dist_names=${ne_dn}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Check VCU Resetting
    Wait Until Keyword Succeeds    300s    3s    Check IP Is Pingable    ${cu_oamssh_ip}    expect_pingable=${False}

Step ${index}: Create Plan With ${what} New DistName Type Parameter
    Log    Step ${index}: Create plan with ${what} new distName type parameter like: nrSysInfoNsaProfileDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vCU_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${vCU_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${vCU_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_scf_dn}"]
    &{CREATE_PARAM}    Set Variable If  '${what}'=='Correct'    &{PARAM_DIC}    &{INCORRECT_PARAM_DIC}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_dn}
    ...    &{CREATE_PARAM}

Step ${index}: Provision Plan And Check Behavior
    Log    Step ${index}: Provision Plan And Check Behavior    console=True
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN ${ne_dn}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${plan_name}_backup -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    ${result}    Run Keyword and Return Status    Check VCU Resetting
    ${result_Activate}    tafssh.Read Output
    Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    Should Be True    ${result}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=${ne_dn}    plan_name=${plan_name}_backup   operation_type=plan
    Set Test Variable    ${backup_plan}    ${plan_name}_backup

Step ${index}: Provision Plan And Check Feedback
    Log    Step ${index}: Provision Plan And Check Feedback    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${plan_name}    dist_names=${ne_dn}
    ...    create_backup_plan=False    provisioning_operation=activate
    Should Contain    ${feedback}    ${EXPECED_PDL_ERROR}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan provision failed

Step ${index}: Check Modified Parameter from Netact after Provision
    Log    Step ${index}: Check Modified Parameter from Netact after Provision    console=True
    NetAct Check Actual Configuration Parameters    ne=${ne_dn}    dist_name=${mo_dn}   &{PARAM_DIC}

Step ${index}: Provision Backup Plan From NetAct
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Provision Plan    plan_name=${backup_plan}    dist_names=${ne_dn}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Particular Teardown
    Log    Particular Teardown   console=True
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    ne=${ne_dn}
    ...    dist_name=${mo_dn}    &{PARAM_DIC_EMPTY}
    Run Keyword If    not ${current_value}    Run Keywords
    ...    Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    Recovery Parameter Value   ${scf_initial}    ${vCU_id}    ${ne_dn}   ${mo_scf_dn}     &{PARAM_DIC_EMPTY}
    ...    AND    Wait Until Keyword Succeeds    10min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

