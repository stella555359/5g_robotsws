*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for VRAN_SyVe_CB008660-A_004_CM_Adding an object breaking (or not) existing distname
...    unambiguity to the live NE
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{plan_info_8660_004}      scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1   param_name=mPlaneIpv4AddressDN
...    shortenedDN=TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1  incorrect_shortenedDN=IPADDRESSV4-1
...    originDN=MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1

${TNL_OBJ}    MRBTS-${vDU_id}/TNLSVC-1/TNL-1
${DUMMY_OBJ}     MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
${DUMMY_OBJ_META_CLASS}    com.nokia.srbts.tnl:IPADDRESSV4
&{DUMMY_PARAM_DIC}    ipAddressAllocationMethod=4

*** Keywords ***
TC__VRAN_SyVe_CM_Adding_Object_Breaking_Or_Not_Breaking_Existing_Distname_Unambiguity_CB008660-A_004
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    19.01.2023, lixin.kang@nokia-sbell.com, draft
    Step 1: TC Parameters Precondition
    Step 2: Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity
    Step 3: Provision Plan And Check Behavior
    Step 4: Check modified parameter in Netact after provision plan
    Step 5: Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity
    Step 6: Provision Plan And Check Feedback
    Step 7: Provision Backup Plan From NetAct

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
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

Upload NE Configuration
    [Documentation]    Uploads configuration data from the network is checked
    Log    Upload NE Configuration     console=True
    NetAct CM Upload    dist_names=${ne_dn}

Step ${index}: TC Parameters Precondition
    Log    Step ${index}: TC Parameters Precondition    console=True
    Set Test Variable    ${plan_info}    ${plan_info_8660_004}
    Set Test Variable    &{PARAM_DIC}    ${plan_info['param_name']}=${plan_info['shortenedDN']}
    Set Test Variable    &{INCORRECT_PARAM_DIC}    ${plan_info['param_name']}=${plan_info['incorrect_shortenedDN']}
    Set Test Variable    &{ORIGIN_PARAM_DIC}      ${plan_info['param_name']}=${plan_info['originDN']}
    ${mo_scf_dn}    Set Variable    ${plan_info['scf_distName']}
    ${mo_dn}    Set Variable   ${plan_info['mo_id']}
    ${ne_dn}    Set Variable   PLMN-PLMN/MRBTS-${vDU_id}
    Set Test Variable    ${mo_scf_dn}
    Set Test Variable    ${mo_dn}
    Set Test Variable    ${ne_dn}
    Set Test Variable    ${dummy_obj_dn}    PLMN-PLMN/${DUMMY_OBJ}
    Upload NE Configuration
    Set Test Variable   ${scf_initial}    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${existed_dummy_obj}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    ne=${ne_dn}    dist_name=${dummy_obj_dn}     &{EMPTY}
    Set Test Variable    ${existed_dummy_obj}
    ${same_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    ne=${ne_dn}    dist_name=${mo_dn}    &{PARAM_DIC}
    Run Keyword If    ${same_value}    Run Keywords    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value   ${scf_initial}    ${vDU_id}    ${ne_dn}   ${mo_scf_dn}    &{ORIGIN_PARAM_DIC}
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Set Test Variable    ${same_value}
    ${tmp_str1}    Set Variable    Distname parameter '${plan_info['param_name']}' value '${plan_info['incorrect_shortenedDN']}' is invalid
    ${tmp_str2}    Set Variable    because the shortened distinguished names pointing to objects under TNL object model tree
    ${EXPECED_PDL_ERROR}    Set Variable    ${tmp_str1} ${tmp_str2} must start at least from TNL and cannot be shortened further.
    Set Test Variable    ${EXPECED_PDL_ERROR}

Recovery Parameter Value
    [Arguments]    ${init_scf}    ${ne_id}    ${ne_dn}    ${scf_dn}    &{param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    recovery_MRBTS-${ne_id}_${timestamp}
    ${precodition_plan_name}    Set Variable   recovery_MRBTS-${ne_id}_${timestamp}
    ${plan}    NetAct Create And Edit Plan    ${init_scf}    name=${precodition_plan_name}    description=Automation SyVe for MRBTS-${ne_id}
    ...    mo_id=${mo_dn}   scf_distName=${scf_dn}    &{param_dic}
    NetAct Provision Plan    plan_name=${precodition_plan_name}   dist_names=${ne_dn}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity
    Log    Step ${index}: Create Plan With New Object Not Breaking Existing Distname-Type Parameter Unambiguity    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${vDU_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${TNL_OBJ}"]
    Run Keyword If    not ${existed_dummy_obj}
    ...    NetAct Create Managed Object    plan=${plan}    meta_class=${DUMMY_OBJ_META_CLASS}
    ...    meta_version=${MO_items['version']}    mo_id=${dummy_obj_dn}    operation=CREATE    &{DUMMY_PARAM_DIC}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_scf_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_dn}    &{PARAM_DIC}

Step ${index}: Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity
    Log    Step ${index}: Create Plan With New Object Breaking Existing Distname-Type Parameter Unambiguity    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${vDU_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_scf_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_dn}    &{INCORRECT_PARAM_DIC}

Step ${index}: Provision Plan And Check Behavior
    Log    Step ${index}: Provision Plan And Check Behavior    console=True
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN ${ne_dn}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${plan_name}_backup -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    Set Test Variable    ${backup_plan_name}    ${plan_name}_backup
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    FOR    ${index}    IN RANGE    0    30
        Sleep    2s
        vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    END
    ${result_Activate}    tafssh.Read Output
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=${ne_dn}    plan_name=${plan_name}_backup   operation_type=plan

Step ${index}: Provision Plan And Check Feedback
    Log    Step ${index}: Provision Plan And Check Feedback    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${plan_name}    dist_names=${ne_dn}
    ...    create_backup_plan=False    provisioning_operation=activate
    Should Contain    ${feedback}    ${EXPECED_PDL_ERROR}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan provision failed

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    NetAct Check Actual Configuration Parameters    ne=${ne_dn}    dist_name=${mo_dn}   &{PARAM_DIC}

Step ${index}: Provision Backup Plan From NetAct
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Provision Plan    plan_name=${backup_plan_name}    dist_names=${ne_dn}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Particular Teardown
    Log    Particular Teardown   console=True
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    ne=${ne_dn}
    ...    dist_name=${mo_dn}    &{PARAM_DIC}
    Run Keyword If    ${current_value}    Run Keywords
    ...    Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will active backup plan again!
    ...    level=WARN
    ...    AND    NetAct Provision Plan    plan_name=${backup_plan_name}    dist_names=${ne_dn}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

