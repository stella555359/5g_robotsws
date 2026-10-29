*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for RAN_SyVe_CB008936_003_CM_Delta plan online validation in Netact with
...   validation scope setting

Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${EXPECED_PDL_ERROR}
#...    Assertion not met: NRCELL(actEnhancedVoNR = 'false' or actCDrx = 'false') have actCDrxVoNR = 'false'
...    It is required that NRCELL-0.actCDrxVoNR (value: false) equal to true

*** Keywords ***
TC__VRAN_SyVe_CM_Delta_Plan_Online_Validation_with_Validation_Scope_Setting_CB008936_003
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    10.01.2023, lixin.kang@nokia-sbell.com, draft
    Online Validation Scope Setting For vCU via NetAct
    Online Validation Scope Setting For vDU via NetAct

Online Validation Scope Setting For ${NE} via NetAct
    Log To Console    Online Validation Scope Setting For ${NE} via NetAct Start
    Step 1: TC Parameters Check For ${NE}
    Step 2: Create Plan With ValidateScope Without PDL Error
    Step 3: Provision Plan From NetAct
    Step 4: Check Modified Parameter And ValidateScope From NetAct
    Step 5: Create Plan With ValidateScope With PDL Error
    Step 6: Pre-Activate Plan And Check Feedback
    Step 7: Provision Backup Plan From NetAct

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    Get Current SCF For vCU
    Setup NetAct    ${NETACT}
    AIC_NetAct.Get FHGW Id
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Continue On Failure
    ...    NetAct Provision Plan    plan_name=${backup_plan}    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Common Test Teardown For AIC
    vDU Login By Rest
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct

Step ${index}: TC Parameters Check For ${NE}
    Log    Step ${index}: TC parameters check started    console=True
    ${current_ne_id}    Set Variable    ${${NE}_id}
    ${current_ne_dn}    Set Variable   PLMN-PLMN/MRBTS-${current_ne_id}
    ${mo_dn}    Set Variable    ${current_ne_dn}/MNL-1
    ${mo_scf_dn}    Set Variable    MRBTS-${current_ne_id}/MNL-1
    Set Test Variable    ${current_ne_id}
    Set Test Variable    ${current_ne_dn}
    Set Test Variable    ${mo_dn}
    Set Test Variable    ${mo_scf_dn}
    ${init_scf}    Set Variable If   '${NE}'=='vCU'    ${TEST_LOG_DIRECTORY}/vcu_scf.xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Set Test Variable    ${init_scf}
    Upload NE Configuration
    ${same_values}    Run Keyword And Return Status     Check Actual Configuration Parameters
    ...    ne=${current_ne_dn}
    ...    dist_name=${mo_dn}
    ...    validationScope=0
    Run Keyword If    ${same_values}   Fail    TC parameters check failed: Parameters validationScope value should not be displayed on NMS!

    ${same_values}    Run Keyword And Return Status     Check Actual Configuration Parameters
    ...    ne=${current_ne_dn}
    ...    dist_name=${current_ne_dn}
    ...    btsName=test8936
    Run Keyword If    ${same_values}    Run keywords    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    AND    Recovery Parameter Value    ${init_scf}    ${current_ne_id}    ${current_ne_dn}     MRBTS-${current_ne_id}
    ...    btsName=${NE}-${current_ne_id}
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Set Test Variable    ${same_values}

Get Current SCF For vCU
    Login To vCU By Rest
    cu.get_current_plan_file    path=${TEST_LOG_DIRECTORY}/vcu_scf.xml
    Logout To vCU By Rest

Recovery Parameter Value
    [Arguments]    ${init_scf}    ${ne_id}    ${mo_dn}    ${scf_dn}    &{param_dic}
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    precondition_MRBTS-${ne_id}_${timestamp}
    ${precodition_plan_name}    Set Variable   precondition_MRBTS-${ne_id}_${timestamp}
    ${plan}    NetAct Create And Edit Plan    ${init_scf}    name=${precodition_plan_name}    description=Automation SyVe for MRBTS-${ne_id}
    ...    mo_id=${mo_dn}   scf_distName=${scf_dn}   &{param_dic}
    NetAct Provision Plan    plan_name=${precodition_plan_name}   dist_names=PLMN-PLMN/MRBTS-${ne_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Upload NE Configuration
    [Documentation]    Uploads configuration data from the network is checked
    Log    Upload NE Configuration     console=True
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}

Step ${index}: Create Plan With ValidateScope ${when} PDL Error
    [Documentation]     Create Plan With MNL:validationScope as "delta check"
    Log    Step ${index}: Create Plan With ValidateScope Without PDL Error    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${current_ne_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${current_ne_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${name}    Automation SyVe for MRBTS-${current_ne_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${init_scf}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${mo_scf_dn}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${mo_dn}    validationScope=0
    ${param_dic1}    Create Dictionary    btsName=test8936
    ${param_dic2}    Create Dictionary    actCDrxVoNR=false
    &{param_value}    Set Variable If    '${when}'=='Without'    ${param_dic1}    ${param_dic2}
    ${DN}    Set Variable If    '${when}'=='Without'    MRBTS-${current_ne_id}    MRBTS-${current_ne_id}/NRBTS-${NRBTS_ID}/NRCELL-0
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${DN}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${DN}
    ...    &{param_value}
    Set Test Variable    ${plan}

Step ${index}: Provision Plan From NetAct
    Log    Step ${index}: Provision Plan From NetAct   console=True
    Set Test Variable    ${backup_plan}    ${name}_backup
    NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${backup_plan}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    plan_name=${backup_plan}    operation_type=plan
    Sleep    1m

Step ${index}: Pre-Activate Plan And Check Feedback
    Log    Step ${index}: Pre-Activate Plan And Check Feedback    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${name}
    ...    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    create_backup_plan=False    provisioning_operation=preactivate
    Should Contain    ${feedback}    ${EXPECED_PDL_ERROR}
    Should Contain    ${feedback}    Error\n\t5G/LTE/SRAN plan validate failed
    Should Not Contain    ${feedback}    Warning
    Should Not Contain    ${feedback}    Non-delta error

Step ${index}: Check Modified Parameter And ValidateScope From NetAct
    Log    Step ${index}: Check Modified Parameter And ValidateScope From NetAct    console=True
    NetAct Check Actual Configuration Parameters    ne=${current_ne_dn}    dist_name=${current_ne_dn}  btsName=test8936
    ${status}    Run Keyword And Return Status    NetAct Check Actual Configuration Parameters
    ...    ne=${current_ne_dn}    dist_name=${mo_dn}   validationScope=0
    Should Not Be True    ${status}
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}    file_name=check_netact_plan.xml
    ...   operation_type=actual    dist_names=${current_ne_dn}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/check_netact_plan.xml
    ${status}    ${msg}    Run Keyword And Ignore Error     L_XML.Get Element Text    ${xml_content}
    ...    .//managedObject[@distName="${mo_dn}"]/p[@name="validationScope"]
    Should Contain    ${msg}    No element matching './/managedObject[@distName="${mo_dn}"]/p[@name="validationScope"]' found

Step ${index}: Provision Backup Plan From NetAct
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Provision Plan    plan_name=${backup_plan}    dist_names=PLMN-PLMN/MRBTS-${current_ne_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
