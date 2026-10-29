*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
...   VRAN_SyVe_CM_CB007186_001_Configures_An_FQDN_For_CMP_Server_Via_NetAct_For_VCU
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${NEED_RECOVER}    ${False}
&{CMP_Setting_Backup}    Ref_Number=56215    PSK_Key=X2gd-4PJa-QLo2-rk9k    Ip=10.103.122.82
&{CMP_Setting_Active}    Ref_Number=37482    PSK_Key=w53L-7Qgs-qqxu-DNcb    Ip=10.92.49.71
&{CMP_Info_Backup}    serverHost=cmpserver1.ocp.hz.nsn-rdnet.net    caSubjectName=CN\=srnblrna1
    ...    eeSubjectName=CN\=srnblrna1    serverPort=8080    serverPath=pkix
&{CMP_Info_Active}    serverHost=cmpserver1.ocp.hz.nsn-rdnet.net    caSubjectName=DC\=RCP RNC, CN\=Root CA
    ...    eeSubjectName=DC\=RCP RNC, CN\=EDSA CA    serverPort=8081    serverPath=pkix

*** Keywords ***
VRAN_SyVe_CM_CB007186_002_Configures_An_FQDN_For_CMP_Server_Via_NetAct_For_VDU
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for RAN_ST_CB007186_002_CM_configures an FQDN for CMP server via NetAct for vDU
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.10.2023 - New Case
    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Provision Plan With FQDN On NetAct
    Step 2: Initialize And Check Certificate
    Step 3: Check CMP_R IP Address Is Resolved On vDU
    Step 4: Check Ip Connectivity On vDU
    Step 5: Check CMP_R IP Address Is Resolved On NetAct
    Step 6: Provision Plan Remove FQDN On NetAct
    Step 7: Initialize And Check Certificate
    Step 8: Check CMP_R IP Address Is Removed On NetAct
    Step 9: Provsion The Backup Plan On NetAct

Step ${index}: Provision Plan ${Oper} FQDN On NetAct
    Log To Console    Step ${index}: Provision Plan ${Oper} FQDN On NetAct
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${plan_name_backup}    Set Variable If    "${Oper}"=="With"    ${plan_name}_backup    ${plan_name_backup}
    Set Test Variable    ${plan_name_backup}
    ${scf_initial}    Set Variable    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${params_IP}    Create Dictionary    serverHost=${CMP_Setting_Active["Ip"]}
    ${params}    Set Variable If    "${Oper}"=="With"    ${CMP_Info_Active}    ${params_IP}
    ${mo_params}    Create Dictionary    MRBTS-${vDU_id}/MNL-1/CERTH-1/CMP-1=${params}
    NetAct Modify Mutiple Parameters    ${scf_initial}    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Append To List    ${NetAct_Plan_List}    ${plan_name}    ${plan_name}_backup
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Wait Until Keyword Succeeds    20min    1min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Check CMP_R IP Address Is Resolved On vDU
    Log To Console    Step ${index}: Check CMP_R IP Address Is Resolved On vDU
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    vDU Login By Rest
    ${scf_vdu}    vdu.Get Current Plan File     local_dir_path=${TEST_LOG_DIRECTORY}
    ...    filename=actual_scf_vDU_${timestamp}.xml    include_runtime_data=True
    vDU Logout By Rest
    Check CMP Server Info    ${TEST_LOG_DIRECTORY}/actual_scf_vDU_${timestamp}.xml    MRBTS-${vDU_id}/MNL-1

Step ${index}: Check CMP_R IP Address Is Resolved On NetAct
    Log To Console    Step ${index}: Check CMP_R IP Address Is Resolved On NetAct
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}
    ...    file_name=netact_plan_vDU_${timestamp}.xml    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    ui_values=true
    Check CMP Server Info    ${TEST_LOG_DIRECTORY}/netact_plan_vDU_${timestamp}.xml    PLMN-PLMN/MRBTS-${vDU_id}/MNL-1

Check CMP Server Info
    [Arguments]    ${plan_content}    ${DN_Prefix}
    Log To Console    Check CMP Server Info
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${plan_content}
    ${xpath_active}    Set Variable
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/list[@name="cmpServerAddressList"]/item[1]
    ${xpath_backup}    Set Variable
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/list[@name="cmpServerAddressList"]/item[2]
    ${cmpServerFQDN}    L_XML.Get Element Text    ${scf_content}    ${xpath_active}/p[@name="cmpServerFQDN"]
    Should Be Equal    ${cmpServerFQDN}    ${CMP_Info_Active["serverHost"]}
    ${cmpServerIpAddr}    L_XML.Get Element Text    ${scf_content}    ${xpath_active}/p[@name="cmpServerIpAddr"]
    Should Be Equal    ${cmpServerIpAddr}    ${CMP_Setting_Active["Ip"]}
    ${cmpServerRole}    L_XML.Get Element Text    ${scf_content}    ${xpath_active}/p[@name="cmpServerRole"]
    Should Be Equal    ${cmpServerRole}    ACTIVE
    ${cmpServerFQDN}    L_XML.Get Element Text    ${scf_content}    ${xpath_backup}/p[@name="cmpServerFQDN"]
    Should Be Equal    ${cmpServerFQDN}    ${CMP_Info_Backup["serverHost"]}
    ${cmpServerIpAddr}    L_XML.Get Element Text    ${scf_content}    ${xpath_backup}/p[@name="cmpServerIpAddr"]
    Should Be Equal    ${cmpServerIpAddr}    ${CMP_Setting_Backup["Ip"]}
    ${cmpServerRole}    L_XML.Get Element Text    ${scf_content}    ${xpath_backup}/p[@name="cmpServerRole"]
    Should Be Equal    ${cmpServerRole}    BACKUP
    ${state}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/p[@name="state"]
    ${targetDN}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/p[@name="targetDN"]
    Should Be Equal    ${state}    CMP_InitializationOK
    Should Be Equal    ${targetDN}    MRBTS-${vDU_id}/MNL-1/CERTH-1/CMP-1

Step ${index}: Check CMP_R IP Address Is Removed On NetAct
    Log To Console    Step ${index}: Check CMP_R IP Address Is Removed On NetAct
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}
    ...    file_name=netact_plan_vDU_${timestamp}.xml    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    ui_values=true
    Check CMP Server Be Removed    ${TEST_LOG_DIRECTORY}/netact_plan_vDU_${timestamp}.xml    PLMN-PLMN/MRBTS-${vDU_id}/MNL-1

Check CMP Server Be Removed
    [Arguments]    ${plan_content}    ${DN_Prefix}
    Log To Console    Check CMP Server Be Removed
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${plan_content}
    ${cmp_elements}    L_XML.Get Elements    ${scf_content}
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/list[@name="cmpServerAddressList"]
    Should be True    "${cmp_elements.__len__()}"=="${0}"
    ${state}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/p[@name="state"]
    ${targetDN}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="${DN_Prefix}/MNLENT-1/CERTHENT-1/CMP_R-1"]/p[@name="targetDN"]
    Should Be Equal    ${state}    CMP_InitializationOK
    Should Be Equal    ${targetDN}    MRBTS-${vDU_id}/MNL-1/CERTH-1/CMP-1

Step ${index}: Check Ip Connectivity On vDU
    Log To Console    Step ${index}: Check Ip Connectivity On vDU
    Check Ip Connectivity By Rest Api In vDU    ${CMP_Setting_Active["Ip"]}

Step ${index}: Initialize And Check Certificate
    Log To Console    Step ${index}: Initialize And Check Certificate
    ${operation_id}    Restore Default Certificates In vDU
    sleep    10s
    ${ids_list_before}    Create List
    ${ids_list_after}    Create List
    ${cert_list_before}    Get vDU Certificates
    FOR    ${cert}    IN    @{cert_list_before}
        Append To List    ${ids_list_before}    ${cert["id"]}
    END
    # Wait Until Keyword Succeeds    3x    10s
    # ...    Automatic Management Certificates In vDU    ${CMP_Setting_Active["Ref_Number"]}    ${CMP_Setting_Active["PSK_Key"]}
    NetAct CMP Config    PLMN-PLMN/MRBTS-${vDU_id}    ${CMP_Setting_Active["PSK_Key"]}    ${CMP_Setting_Active["Ref_Number"]}    ${NETACT}
    Sleep    10s
    NetAct Management Certificates    cmpInit    PLMN-PLMN/MRBTS-${vDU_id}    ${NETACT}
    ${cert_list_after}    Get vDU Certificates
    FOR    ${cert}    IN    @{cert_list_after}
        Append To List    ${ids_list_after}    ${cert["id"]}
    END
    Remove Values From List    ${ids_list_after}    @{ids_list_before}
    log to console    ${ids_list_after}
    Should Be True    "${ids_list_after.__len__()}">="${2}"

Step ${index}: Provsion The Backup Plan On NetAct
    Log    Step ${index}: Provsion The Backup Plan On NetAct    console=True
    NetAct Provision Plan    plan_name=${plan_name_backup}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    1min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Set Test Variable    ${NEED_RECOVER}    ${False}

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    ${NetAct_Plan_List}    Create List
    Set Test Variable    ${NetAct_Plan_List}

Case Postcondition
    Log To Console    \n Case Postcondition
    FOR    ${plan}    IN    @{NetAct_Plan_List}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan}
    END
    #-12840 Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${out}    Run Keyword If    ${NEED_RECOVER}    Parameter Operation    operation=full_commission    product_type=vdu
    ...    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Wait Until Keyword Succeeds    10min    3min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct

#Full Commission SCF Via Rest
#    [Arguments]    ${scf_path}
#    vDU Login By Rest
#    ${plan_id}    ${action_id}    ${validate_id}    Upload And Validate Plan    plan_file=${scf_path}    plan_name=back_up_plan    validate=${True}
#    Activate Plan By REST    ${plan_id}
#    vDU Logout By Rest
#    Wait Until Keyword Succeeds    10min    3min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0