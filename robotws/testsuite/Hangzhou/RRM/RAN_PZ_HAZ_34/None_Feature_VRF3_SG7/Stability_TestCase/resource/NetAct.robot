*** Settings ***
Resource   Common.robot

*** Variables ***


*** Keywords ***
UUF CM Upload
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF CM Upload
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    ${output}   csn.Execute   command=racclimx.sh -v -op Upload -DN PLMN-PLMN/${dist_name}   connection=NETACT_VM
    Should Contain   ${output}   The operation was successfully completed.:Upload is Successful
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM


UUF CM Provision
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF CM Provision
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    ${btsName}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["btsName"]}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"


    ${time}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    ${output}   csn.Execute
    ...   command=racclimx.sh -op Provision_Mass_Modification -DN PLMN-PLMN/${dist_name} -parameterValuesByNames btsName=CM_Provision_${time} -v
    ...   connection=NETACT_VM
    Should Contain   ${output}   Provision of the plan was successful

    # ${output}   csn.Execute
    # ...   command=racclimx.sh -op Provision_Mass_Modification -DN PLMN-PLMN/${dist_name} -parameterValuesByNames btsName=${btsName} -v
    # ...   connection=NETACT_VM
    # Should Contain   ${output}   Provision of the plan was successful

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM


UUF FM Auto Upload
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF FM Auto Upload
    # ${AMGR_DN}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["AMGR_DN"]}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    # COAM Update Parameter
    # ...   dist_name=${AMGR_DN}
    # ...   parameter=enableDefaultPasswdAlarm
    # ...   value=true
    # ...   connection=${testline}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    ${alarm_detail_list}   ${alarm_id_list}   get_active_alarm_on_netact_backend
    ...   netactnode=${vm_ip}
    ...   username=${service_user}
    ...   password=${service_password}
    ...   dn=PLMN-PLMN/${dist_name}
    # List Should Contain Value   ${alarm_id_list}   4459
    List Should Contain Value   ${alarm_id_list}   61524

    # [Teardown]   COAM Update Parameter
    # ...   dist_name=${AMGR_DN}
    # ...   parameter=enableDefaultPasswdAlarm
    # ...   value=false
    # ...   connection=${testline}


UUF FM Manual Upload
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF FM Manual Upload
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    Log To Console   FM Upload On NetAct VM:
    Log To Console   IpAddr: ${vm_ip}
    Log To Console   Username: ${service_user}
    Log To Console   Password: ${service_password}
    Log To Console   FM Upload Command: sh fmCLI.sh -operation alarmupload -dn PLMN-PLMN/${dist_name}
    ${jobid}   csn.Execute
    ...   command=sh fmCLI.sh -operation alarmupload -dn PLMN-PLMN/${dist_name}
    ...   connection=NETACT_VM
    ${jobid}   Strip String   ${jobid}
    ${operation_id}   Should Match Regexp   ${jobid}   \\d+
    Log To Console   FM Upload Operation ID: ${operation_id}
    Log To Console   Checking fmCLI Status: sh fmCLI.sh -operation status -jobid ${operation_id}

    Wait Until Keyword Succeeds   1m   10s
    ...   fmCLI Check NetAct FM Operation By Operation ID   operation_id=${operation_id}   connection=NETACT_VM

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM


UUF SWM Upload
    [Arguments]   ${testline}
    Log To Console   //TODO: UUF SWM Upload

    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    # ${dist_name}   Set Variable   PLMN-PLMN/${dist_name}

    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    ${operation_id}   csn.Execute   command=swmCLI.sh -op start -t upload -dn PLMN-PLMN/${dist_name}   connection=NETACT_VM
    ${operation_id}   Strip String   ${operation_id}
    Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM

    Wait Until Keyword Succeeds   5m   10s
    ...   swmCLI Check NetAct SWM Operation By Operation ID   dist_name=${dist_name}   operation_id=${operation_id}

    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=NETACT_VM





# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
Selenium NetAct SWM Operation
    [Arguments]   ${dist_name}   ${operation}   ${package_version}=${EMPTY}

    selenium_netact.enable_virtual_display
    ${allowed_operation}   Create List   Upload   Download   Activation   Provision   Rollback
    List Should Contain Value   ${allowed_operation}   ${operation}

    Run Keyword If   "${operation}"=="Download" or "${operation}"=="Activation" or "${operation}"=="Provision"
    ...   Should Not Be Empty   ${package_version}

    # Open NetAct Start Page
    # Open Netact Start Page   url=${url}   username=${username}   password=${password}   showall=${false}
    ${url}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["url"]}   ${EMPTY}
    ${http_username}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_username"]}   ${EMPTY}
    ${http_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_password"]}   ${EMPTY}

    Return From Keyword If   "${NETACT_IP}"=="" or "${NETACT_IP}"=="${None}"

    Run Keyword And Ignore Error
    ...   selenium_netact.Set Download Dir   ${OUTPUT_DIR}
    Wait Until Keyword Succeeds   3x   30s
    ...   selenium_netact.Login   url=${url}   username=${http_username}   password=${http_password}
    Sleep   3s

    # Open Software Manager
    Run Keyword And Ignore Error
    ...   selenium_netact.wait_for_visibility   elem_xpath=//a[contains(@folder, 'configuration')]
    selenium_netact.open_configuration_software_manager
    selenium_netact.switch_to_page   page_name=Software Manager

    # Input MO Type
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="ccMOTypecomboboxField"]
    selenium_netact.write_value_and_enter   input_xpath=//*[@id="ccMOTypecomboboxField"]   value=MRBTS

    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mot:::c"]
    selenium_netact.select_checkbox   checkbox_xpath=//*[@id="mot:::c"]

    # Filter testline
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="swmTable_networkView_header"]//th[@class="columnMODnNS"]//input
    Wait Until Keyword Succeeds   3x   3s
    ...   selenium_netact.write_value_and_enter
    ...   input_xpath=//*[@id="swmTable_networkView_header"]//th[@class="columnMODnNS"]//input
    ...   value=PLMN-PLMN/${dist_name}
    Sleep   3s

    # Reload Page If Testline Not Show
    ${status}   Run Keyword And Return Status
    ...   selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id="swmTable_networkView_body"]//td[@class="columnSelectNS"]//input[@data-id="PLMN-PLMN/${dist_name}"]
    ...   timeout=${30}
    Run Keyword If   not ${status}   selenium_netact.execute_script    script_cmd=location.reload();
    Sleep   3s

    # Select testline
    selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id="swmTable_networkView_body"]//td[@class="columnSelectNS"]//input[@data-id="PLMN-PLMN/${dist_name}"]
    Sleep   3s
    selenium_netact.execute_script
    ...   script_cmd=document.getElementById("swmTable_networkView_horizontalScroll").style.setProperty("height", "100px")
    Sleep   1s
    selenium_netact.select_checkbox
    ...   checkbox_xpath=//*[@id="swmTable_networkView_body"]//td[@class="columnSelectNS"]//input[@data-id="PLMN-PLMN/${dist_name}"]
    Sleep   3s

    # Click New Task
    selenium_netact.wait_for_enable    elem_xpath=//*[@id="belowTableActions:btnStartTask"]
    selenium_netact.click_button    button_xpath=//*[@id="belowTableActions:btnStartTask"]
    Sleep   3s

    # Select Operation
    selenium_netact.wait_for_enable   elem_xpath=//span[contains(@id, 'include:createWizardForm:opTree') and text()="${operation}"]
    selenium_netact.click_button   button_xpath=//span[contains(@id, 'include:createWizardForm:opTree') and text()="${operation}"]
    Sleep   3s

    # Select Package
    ${Select_Package_Success}   Run Keyword And Return Status
    ...   Run Keyword If   "${operation}"=="Download" or "${operation}"=="Activation" or "${operation}"=="Provision"   Run Keywords
    ...   selenium_netact.wait_for_visibility   elem_xpath=(//*[@title="Version ID: ${package_version}"]/../..//input[@type="radio"])[1]    AND
    ...   selenium_netact.select_radio    radio_xpath=(//*[@title="Version ID: ${package_version}"]/../..//input[@type="radio"])[1]         AND
    ...   Sleep   3s
    Run Keyword If   not ${Select_Package_Success}
    ...   Fail   msg=Can not Select Package: ${package_version}, Please Check The Netact Package OR Testline Integration Status.


    # Click Finish
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="include:createWizardForm:btnFinish"]
    selenium_netact.click_button    button_xpath=//*[@id="include:createWizardForm:btnFinish"]
    Sleep   10s

    # Click Continue Button In Pop-up Window
    Run Keyword And Ignore Error
    ...   Run Keyword If   '${operation}'=='Activation' or '${operation}'=='Provision' or '${operation}'=='Rollback'   Run Keywords
    ...   selenium_netact.wait_for_enable
    ...   elem_xpath=//input[@id='confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk']
    ...   AND
    ...   selenium_netact.click_button
    ...   button_xpath=//input[@id='confirmationForActiveOperationModalForm:confirmationForActiveOperationModalmsgBtnScriptAndActionOk']
    ...   AND
    ...   Sleep   3s


    ${operation_id}   Wait Until Keyword Succeeds   3x   10s
    ...   swmCLI Get NetAct SWM Operation ID   dist_name=${dist_name}   operation=${operation}

    Log To Console   ${operation} operation_id: ${operation_id}
    Run Keyword If   "${operation_id}"=="${None}"   FAIL   msg=[ERROR] ${operation} operation_id=None.

    [Return]   ${operation_id}
    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Catch netact Screenshot by xpath   xpath=//body   AND
    ...   Run Keyword And Ignore Error   selenium_netact.logout   AND
    ...   Run Keyword And Ignore Error   selenium_netact.disable_virtual_display



swmCLI Get NetAct SWM Operation ID
    [Arguments]   ${dist_name}   ${operation}

    ${operation}   Set Variable If
    ...   "${operation}"=="Upload"   SWUpload
    ...   "${operation}"=="Download"   SWDownload
    ...   "${operation}"=="Activation"   SWActivate
    ...   "${operation}"=="Rollback"   SWRollback
    ...   ERR


    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}

    ${debug_output}   csn.Execute   command=swmCLI.sh -op mo-status -dn PLMN-PLMN/${dist_name}   connection=NETACT_VM
    ${output}   csn.Execute   command=swmCLI.sh -op ongoing-operations   connection=NETACT_VM
    ${operation_id_list}   Split To Lines   ${output}
    FOR   ${operation_id}   IN   @{operation_id_list}
        ${operation_id}   Strip String   ${operation_id}
        ${output}   csn.Execute   command=swmCLI.sh -op operation-status -id ${operation_id}   connection=NETACT_VM

        ${operation_list}   Split To Lines  ${output}

        ${operation_status}   Evaluate  [i for i in ${operation_list} if i.find("PLMN-PLMN/${dist_name},")!=-1 and i.find("${operation}")!=-1]
        Continue For Loop If   len(${operation_status})==0

        ${operation_status}   Get Variable Value   ${operation_status[0]}
        ${operation_status_list}   Split String   ${operation_status}   ,

        ${operation_status}   Evaluate   [i.strip() for i in ${operation_status_list}]
        ${MO_DN}   Set Variable   ${operation_status[0]}
        ${TASK_TYPE}   Set Variable   ${operation_status[1]}
        ${TASK_STATUS}   Set Variable   ${operation_status[2]}
        Return From Keyword If   "${MO_DN}"=="PLMN-PLMN/${dist_name}" and "${TASK_TYPE}"=="${operation}"   ${operation_id}
    END
    FAIL   msg=Can Not Get operation_id.
    [Teardown]   csn.Disconnect   connection=NETACT_VM


swmCLI Check NetAct SWM Operation By Operation ID
    [Arguments]   ${dist_name}   ${operation_id}
    ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
    ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
    ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

    Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"

    csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}
    ${output}   csn.Execute   command=swmCLI.sh -op operation-status -id ${operation_id}   connection=NETACT_VM

    ${operation_list}   Split To Lines  ${output}

    ${operation_status}   Evaluate   [i for i in ${operation_list} if i.find("PLMN-PLMN/${dist_name},")!=-1]
    Run Keyword If   len(${operation_status})==0   Fatal Error

    ${operation_status}   Get Variable Value   ${operation_status[0]}
    ${operation_status_list}   Split String   ${operation_status}   ,

    ${operation_status}   Evaluate   [i.strip() for i in ${operation_status_list}]
    ${MO_DN}   Set Variable   ${operation_status[0]}
    ${TASK_TYPE}   Set Variable   ${operation_status[1]}
    ${TASK_STATUS}   Set Variable   ${operation_status[2]}

    Run Keyword If   "${TASK_STATUS}"=="FAILED"
    ...   Fatal Error   msg=NetAct SWM Operation Failed. Please Check The Reason On NetAct Web Page Manually.
    Should Contain Any   ${TASK_STATUS}   SUCCESS   TIMEOUT_SUCCESS

    [Teardown]   csn.Disconnect   connection=NETACT_VM



# swmCLI Check NetAct SWM Operation
#     [Arguments]   ${dist_name}   ${operation}

#     ${vm_ip}   Get Variable Value   ${NETACT_IP}   ${EMPTY}
#     ${service_user}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_username"]}   ${EMPTY}
#     ${service_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["ssh_password"]}   ${EMPTY}

#     Return From Keyword If   "${vm_ip}"=="" or "${vm_ip}"=="${None}"


#     csn.Connect To   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=NETACT_VM   timeout=${30}

#     ${MO_DN}   ${TASK_TYPE}    ${TASK_STATUS}   swmCLI Get NetAct SWM Operation From Ongoing Operation ID   connection=NETACT_VM
#     Log To Console   ${MO_DN}
#     Log To Console   ${TASK_TYPE}
#     Log To Console    ${TASK_STATUS}
#     Log To Console    ${EMPTY}
#     Run Keyword If   "${TASK_STATUS}"=="FAILED"   Fatal Error
#     ${operation_status}   Run Keyword And Return Status   Should Be Equal   "${TASK_STATUS}"=="SUCCESS"

#     ${MO_DN}   ${TASK_TYPE}    ${TASK_STATUS}   swmCLI Get NetAct SWM Operation From MO Status   connection=NETACT_VM
#     Log To Console   ${MO_DN}
#     Log To Console   ${TASK_TYPE}
#     Log To Console    ${TASK_STATUS}
#     Run Keyword If   "${TASK_STATUS}"=="FAILED"   Fatal Error
#     ${mo_status}   Run Keyword And Return Status   Should Be Equal   "${TASK_STATUS}"=="SUCCESS"

#     Should Be True   ${operation_status} or ${mo_status}

#     # swmCLI.sh -op mo-status -dn PLMN-PLMN/MRBTS-89
#     # swmCLI.sh -op operation-status -id op_id_80483
#     # swmCLI.sh -op ongoing-operations

#     # SWUpload
#     # SWDownload
#     # SWActivate
#     # SWRollback

#     # ONGOING
#     # SUCCESS
#     # FAILED

#     [Teardown]   csn.Disconnect   connection=NETACT_VM


# swmCLI Get NetAct SWM Operation From MO Status
#     [Arguments]   ${connection}
#     ${MO_DN}   Set Variable
#     ${TASK_TYPE}   Set Variable
#     ${TASK_STATUS}   Set Variable

#     ${output}   csn.Execute   command=swmCLI.sh -op mo-status -dn PLMN-PLMN/${dist_name}   connection=NETACT_VM
#     ${mo_list}   Split To Lines   ${output}
#     :FOR   ${mo_detail}   IN   @{mo_list}
#         ${mo_detail_list}   Split String   ${mo_detail}   ,
#         ${operation_status}   Evaluate   [i.strip() for i in ${mo_detail_list}]
#         ${MO_DN}   Set Variable   ${operation_status[0]}
#         ${TASK_TYPE}   Set Variable   ${operation_status[-2]}
#         ${TASK_STATUS}   Set Variable   ${operation_status[-1]}
#     END
#     [Return]   ${MO_DN}   ${TASK_TYPE}    ${TASK_STATUS}


# swmCLI Get NetAct SWM Operation From Ongoing Operation ID
#     [Arguments]   ${connection}
#     ${MO_DN}   Set Variable
#     ${TASK_TYPE}   Set Variable
#     ${TASK_STATUS}   Set Variable

#     ${output}   csn.Execute   command=swmCLI.sh -op ongoing-operations   connection=NETACT_VM
#     ${operation_id_list}   Split To Lines   ${output}
#     :FOR   ${operation_id}   IN   @{operation_id_list}
#         ${operation_id}   Strip String   ${operation_id}
#         ${output}   csn.Execute   command=swmCLI.sh -op operation-status -id ${operation_id}   connection=NETACT_VM

#         ${operation_list}   Split To Lines  ${output}

#         ${operation_status}   Evaluate   [i for i in ${operation_list} if i.find("PLMN-PLMN/${dist_name},")!=-1]
#         Continue For Loop If   len(${operation_status})==0

#         ${operation_status}   Get Variable Value   ${operation_status[0]}
#         ${operation_status_list}   Split String   ${operation_status}   ,

#         ${operation_status}   Evaluate   [i.strip() for i in ${operation_status_list}]
#         ${MO_DN}   Set Variable   ${operation_status[0]}
#         ${TASK_TYPE}   Set Variable   ${operation_status[1]}
#         ${TASK_STATUS}   Set Variable   ${operation_status[2]}
#         Exit For Loop
#     END
#     [Return]   ${MO_DN}   ${TASK_TYPE}    ${TASK_STATUS}




fmCLI Check NetAct FM Operation By Operation ID
    [Arguments]   ${operation_id}   ${connection}=NETACT_VM
    ${operation_status}   csn.Execute
    ...   command=sh fmCLI.sh -operation status -jobid ${operation_id}
    ...   connection=${connection}
    Should Contain   ${operation_status}   Alarm Upload: SUCCESS


Catch Netact Screenshot by Xpath
    [Arguments]   ${xpath}    ${dir}=${OUTPUT_DIR}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    ${selenium_netact_lib} =    Get Library Instance    selenium_netact
    ${element} =    Call Method    ${selenium_netact_lib._driver}    find_element_by_xpath    ${xpath}
    Call Method    ${element}    screenshot    ${dir}/Screen_${curr_data}.png
