*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***
${IP}   ${cu_addr}
${NEIW_NE_Type}   MRBTS
${MRC_name}   SG8
${MR_name}   SG8
${MR}   MRC-${MRC_name}/MR-${MR_name}
${service_Maintenance_region}   ${MR}
${Monitor_folder}   //span[text()='Monitoring']
${Adminstration_folder}   //span[text()='Administration']
${NEIW_position}   //span[text()='NE Integration Wizard']
${result_xpath}   //*[@id="mainForm:main_table:result"]
${total_xpath}   //*[@id="mainForm:main_table:total_number_ne"]
${main_table_xpath}   //*[@id="mainForm:main_table"]

*** Keywords ***
Integrating NE to NetAct
    Log To Console   ${EMPTY}
    Log To Console   Start To Integrate NE With NetAct...
    Run Keyword And Ignore Error   selenium_netact.Logout
    Step1: Open NEIW Page
    Step2: Get NEIW Information
    Step3: NEIW De Integration
    Step4: NEIW Integration
    [Teardown]   Run Keyword And Ignore Error   selenium_netact.Logout

Step1: Open NEIW Page
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
    Remove File    ${WEB_DOWNLOAD_DIR}/*.jnlp
    selenium_netact.open_sub_page   category_xpath=${Adminstration_folder}   page_xpath=${NEIW_position}   page_name=NE Integration Wizard

Step2: Get NEIW Information
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:main_table"]
    selenium_netact.wait_for_visibility   elem_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    sleep   20s
    ${status}=   Check if NE or MR in Table   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=${DN}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    Set Suite Variable   ${Should_De}   ${status}
    Return From Keyword If   not ${Should_De}

    selenium_netact.write_value   input_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']   value=${DN}
    Sleep   5s
    #Open Modify Page Check DN And Release
    selenium_netact.click_button   button_xpath=(//*[@id='mainForm:main_table']//div[@id='modify'])[1]
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id='newNEInitConfiguration_container']
    ${check_dn}   selenium_netact.get_element_attribute   elem_xpath=//*[@id='selectionForm:dynamicPanel:2:fqdn']   attr_name=value
    Should Be Equal   ${check_dn}   ${DN}
    ${old_release}   selenium_netact.get_element_attribute   elem_xpath=//*[@id='selectionForm:adaptationReleaseFilterInput']   attr_name=value
    ${old_mr}   selenium_netact.get_element_attribute   elem_xpath=//*[@id='selectionForm:dynamicPanel:0:mrfqdnInput']   attr_name=value
    ${old_mo}   selenium_netact.get_element_attribute   elem_xpath=//*[@id='selectionForm:neTypeFilterInput']   attr_name=value
    Set Suite Variable   ${old_release}
    Set Suite Variable   ${old_mr}
    Set Suite Variable   ${old_mo}
    sleep   5s
    selenium_netact.click_button   button_xpath=//*[@id='selectionForm:cancel']
    Sleep   5s

Step3: NEIW De Integration
    Log To Console   First Start To Deintegrate Operation...
    Run Keyword If   not ${Should_De}   Log To Console   DN DO NOT EXIST, Skip Deintegrate Operation...
    Return From Keyword If   not ${Should_De}

    #Open De Integration Page
    selenium_netact.click_button   button_xpath=//*[@id="de_integration_tab_label"]
    Sleep   5s
    #Click New Button
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:newNEButton"]
    selenium_netact.click_button   button_xpath=//*[@id="mainForm:newNEButton"]
    Sleep   3s
    #Write Plan Name
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="selectionForm:planName"]
    ${curr_data}    Get Current Date    UTC    + 8 hours    result_format=%Y%m%d%H%M%S
    selenium_netact.write_value   input_xpath=//*[@id="selectionForm:planName"]   value=MRBTS_${BTS_ID}_${curr_data}
    Set Suite Variable   ${de_plan_name}   MRBTS_${BTS_ID}_${curr_data}
    Sleep   3s

    #Select MR
    selenium_netact.click_button   button_xpath=//*[@class="scrolling-content"]//span[text()='${old_mr}']
    Sleep   5s
    selenium_netact.click_button   button_xpath=//*[@id="selectionForm:search"]
    Sleep   5s
    selenium_netact.write_value   input_xpath=//*[@id="selectionForm:main_table:moDnFilterInput"]   value=${DN}
    selenium_netact.click_button   button_xpath=//*[@id="selectionForm:main_table:selectAllCheckBox"]
    selenium_netact.click_button   button_xpath=//*[@id="selectionForm:add"]
    #Select NE MO
    #selenium_netact.click_button   button_xpath=//*[@id="selectionForm:neTypeFilterButton"]
    #Sleep   5s
    #selenium_netact.click_button   button_xpath=//*[@id='selectionForm:neTypeFilterItems']//*[@title='${old_mo}']
    #Sleep   5s
    #Select Release
    #selenium_netact.execute_script
    #...   script_cmd=return document.getElementById('selectionForm:releaseFilterItems').setAttribute('style','max-height: 200px;')
    #Sleep   5s
    #selenium_netact.click_button   button_xpath=//*[@id="selectionForm:releaseFilterButton"]
    #Sleep   5s
    #selenium_netact.click_button   button_xpath=//*[@id='selectionForm:releaseFilterItems']//*[@title='${old_release}']
    #Sleep   5s
    ##Click Search Button
    #selenium_netact.click_button   button_xpath=//*[@id="selectionForm:search"]
    #Sleep   5s

    #Select MO DN
    #selenium_netact.wait_for_visibility   elem_xpath=//*[@id="selectionForm:main_table:moDnFilterInput"]
    #selenium_netact.write_value   input_xpath=//*[@id="selectionForm:main_table:moDnFilterInput"]   value=${DN}
    #Sleep   5s
    #selenium_netact.click_button   button_xpath=//*[@id="selectionForm:main_table:selectAllCheckBox"]
    #Sleep   5s
    #selenium_netact.click_button   button_xpath=//*[@id="selectionForm:add"]
    #Sleep   5s

    #Check DN Correct
    ${need_de_integration}   Run Keyword And Return Status   selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id="selectionForm:deplanTree:parent.0:moDn"]
    Return From Keyword If   not ${need_de_integration}
    ${details}   selenium_netact.get_elem_text   elem_xpath=//*[@id="selectionForm:deplanTree:parent.0:moDn"]
    @{details_list}   Split String   ${details}   ,${SPACE}
    Should Be Equal   ${details_list[0]}   ${DN}

    #Click Save And Deintegrate Button
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="selectionForm:saveAndDeintegrateInSearchPanel"]
    selenium_netact.click_button   button_xpath=//*[@id="selectionForm:saveAndDeintegrateInSearchPanel"]
    Sleep   5s

    #Enter yes in Confirm Input
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="selectionForm:deintegrationConfirmInput"]
    selenium_netact.write_value   input_xpath=//*[@id="selectionForm:deintegrationConfirmInput"]   value=yes
    Sleep   5s
    #Click Confirm Button
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="selectionForm:deintegrationConfirmButton"]
    selenium_netact.click_button   button_xpath=//*[@id="selectionForm:deintegrationConfirmButton"]
    Sleep   5s
    #Check Deintegrate Finished
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id='mainForm:main_table']//*[@id="mainForm:main_table:planNameFilterInput"]
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id='mainForm:main_table']//*[@id="mainForm:main_table:body"]
    selenium_netact.move_to_element   elem_xpath=//*[@id='mainForm:main_table']//*[@id="mainForm:main_table:planNameFilterInput"]
    Sleep   5s
    selenium_netact.write_value   input_xpath=//*[@id='mainForm:main_table']//*[@id="mainForm:main_table:planNameFilterInput"]
    ...   value=${de_plan_name}
    Sleep   10s
    ${check_de_plan_name}   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:0:planName"]
    Should Be Equal   ${check_de_plan_name}   ${de_plan_name}
    Wait Until Keyword Succeeds   10m   1m   Check Plan Process Status
    Log To Console   Deintegrate Operation Finished.
    [Teardown]   Run Keyword And Ignore Error   selenium_netact.Logout

Check Plan Process Status
    ${status}   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:0:status"]
    Should Be Equal   ${status}   Completed

Step4: NEIW Integration
    Log To Console   Next Start To Integrate Operation...
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
#    Create MR MRC and Credentials
    ${status}=   Integrate NE via NEIW
    ...   DN=${DN}
    ...   Adminstration_folder=${Adminstration_folder}
    ...   NEIW_position=${NEIW_position}
    ...   NE_Type=${NEIW_NE_Type}
    ...   release=${release}
    ...   MR=${MR}
    ...   IP=${IP}
    ...   NE3SWS_IPversion=${NE3SWS_IPversion}
    ...   NE3SWS_mode=${NE3SWS_mode}
    ...   remove=${True}
    run keyword if  not ${status}   Fail   NEIW failed.
    sleep   10s
    run keyword and ignore error   Renew Registrations on NE3SWS Network Element
    CM Upload in Backend ENV
    Log To Console   Integrate Operation Finished.
    [Teardown]   Run Keyword And Ignore Error    selenium_netact.Logout


CM Upload in Backend ENV
    ${upload_command}=   set variable  racclimx.sh -v -op Upload -DN ${DN}
    ${expect_output}=   run keyword if  '${release}'=='5G19ACLA'   set variable   The operation was successfully completed.:Upload is Successful
    ...   ELSE   set variable   Status received: Finished
    Connect to NetAct WasNode and execute command   wasNode_IP=${HOST_IP['${WAS_DMGR_HOSTS[0]}']}   omc_uername=${SERVICE_USER}
    ...   omc_passowrd=${SERVICE_PASSWORD}  command=${upload_command}   expect_output=${expect_output}

Renew Registrations on NE3SWS Network Element
    ${renew_Registration_command}=   set variable  racclimx.sh -op NE3S_RenewRegistration -DN ${DN} -v
    Connect to NetAct WasNode and execute command      ${HOST_IP['${WAS_DMGR_HOSTS[0]}']}
    ...   ${SERVICE_USER}   ${SERVICE_PASSWORD}   ${renew_Registration_command}

Set Scope
    [Arguments]    ${scope}    ${scope_type}
    ${scope_id}=    Get Scope ID    ${scope_type}
    Run Keyword If    ${scope_id} == 0 or ${scope_id} == 1    Run Keyword And Ignore Error
    ...   wait until keyword succeeds   16s   5s  selenium_netact.click_button   button_xpath=//*[@id="createPage:creationType_Radio:${scope_id}"]
    ...    ELSE IF    ${scope_id} == 2    Set MR Scope   scope=${scope}
#    ...    ELSE IF    ${scope_id} == 3    Set NE Type Scope    ${scope}
#    [Return]    ${scope_id}

Set MR Scope
    [Arguments]    ${scope}
    wait until keyword succeeds   3 times   5s  selenium_netact.select_radio
    ...   radio_xpath=//*[@id="createPage:creationType_Radio:2"]
    Select Value From List in NEVC   index=//*[@id="createPage:MaintenanceRegionMenu"]   value=${scope}   list_element_nbr=5

Get Scope ID
    [Arguments]    ${scope_type}
    ${scopes}    Set Variable    @{NEAC_SCOPES}
    ${scope_id}=    Collections.Get Index From List    ${scopes}    ${scope_type}
    Run Keyword if    ${scope_id} < 0    FAIL    ${scope_type} is not on a list of available scopes!
    Set Suite Variable    ${scope_id}
    [Return]    ${scope_id}

Wait For Loading To Disappear
    FOR    ${i}    IN RANGE    3
        ${loadingVisible}=    Run Keyword And Return Status    Wait Until Keyword Succeeds   5 times   5s   selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id="credentialList:newCredential"]
        Exit For Loop If    ${loadingVisible}
    END

Select Value From List in NEVC
    [Arguments]    ${index}    ${value}   ${list_element_nbr}=10
    FOR   ${i}    IN RANGE    ${list_element_nbr}
        Wait Until Keyword Succeeds   31s   10s   selenium_netact.click_button   button_xpath=${index}
        Run Keyword And Return Status   Wait Until Keyword Succeeds   31s   10s
        ...   selenium_netact.click_button   button_xpath= ${index}/option[${i+1}]
        ${value_act}=   selenium_netact.get_elem_text   elem_xpath=${index}/option[${i+1}]
        ${status}   Run Keyword And Return Status   Should Be Equal   ${value}   ${value_act}
        Exit For Loop If   ${status}
    END
    run keyword if  not ${status}   Fail

Integrate NE via NEIW
    [Arguments]  ${DN}   ${Adminstration_folder}   ${NEIW_position}     ${NE_Type}    ${release}    ${MR}    ${IP}
    ...   ${NE3SWS_IPversion}   ${NE3SWS_mode}   ${remove}=${True}
    wait until keyword succeeds  5 times   5s   selenium_netact.switch_to_page   page_name=Start Page
    selenium_netact.open_sub_page   category_xpath=${Adminstration_folder}   page_xpath=${NEIW_position}   page_name=NE Integration Wizard
    sleep   20s
    ${status}=   Check if NE or MR in Table   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=${DN}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    ${status_remove}=   Run Keyword If  ${status} and ${remove}   Delete Configuration   DN=${DN}
    sleep   20s
    ${status}=   Check if NE or MR in Table   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=${DN}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    run keyword if  not ${status}    Configure NE in NIEW
    ...   ne_type=${NE_Type}   release=${release}   mr=${MR}   IP=${IP}   ne3sws_ip_version=${NE3SWS_IPversion}   ne3sws_mode=${NE3SWS_mode}
    sleep   20s
    ${status}=    Check if NE or MR in Table   TextField_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    ...   Text=${DN}   main_table_xpath=${main_table_xpath}   total_xpath=${total_xpath}   result_xpath=${result_xpath}
    ${status}=   Run Keyword And Return Status  Run Keyword If  ${status}   Integrate Action via Integrate Button   DN=${DN}
    Sleep   20s
    ${status}=   Run Keyword If  ${status}   Check Integration status FP   DN=${DN}
    selenium_netact.close_page   page_name=NE Integration Wizard
    selenium_netact.Logout
    [Return]  ${status}

Check Integration status FP
    [Arguments]   ${DN}
    #filter
    Input Text on NEIW or NEAC   TextField_xpath=//*[@id="mainForm:main_table:rootMOFilterInput"]   Text=${DN}
    ${total_text}=   Wait Until Keyword Succeeds   3 times   5s
    ...   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:total_number_ne"]
    ${total_text_reg}=   should match regexp  ${total_text}   \\d+
    ${total_nbr}=   BuiltIn.Convert To Integer   ${total_text_reg}
    FOR   ${i}    IN RANGE    ${total_nbr}
        ${status}   ${val}   Run Keyword And Ignore Error   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:${i}:rootMO"]
        Continue For Loop If   '${status}'=='FAIL'
        ${index}   Set Variable If   '${val}'=='${DN}'   ${i}    #correct number of row.
        Exit For Loop If   '${val}'=='${DN}'
    END
    #wait until status not Ongoing
    Sleep   20s
    FOR   ${i}    IN RANGE    240
        ${status_int}   Wait Until Keyword Succeeds   3 times   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="mainForm:main_table:${index}:integrationStatus"]
        Exit For Loop If    '${status_int}'!='Ongoing' and '${status_int}'!='In queue'
        ${mod}   Evaluate   ${i}%5
        Run Keyword If   '${mod}'=='0'   selenium_netact.click_button   button_xpath=//span[@class='buttonIcon spanIconforfocus refreshIcon']
        Sleep   5s
    END
    Run Keyword If   '${status_int}'=='Ongoing'   LOG   Operation takes more than 20m.    WARN
    ${status}=   Run Keyword And Return Status   Should Be Equal   ${status_int}   Completed    #status completed
    #show details
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button
    ...   button_xpath=//*[@id="mainForm:main_table:${index}:integrationStatus"]
    Run Keyword And Ignore Error  selenium_netact.wait_for_enable   elem_xpath=//*[@id="ShowFullLogLink"]
    #show full log
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   3 times   5s
    ...   selenium_netact.click_button   button_xpath=//*[@id="ShowFullLogLink"]
    Run Keyword And Ignore Error  selenium_netact.wait_for_visibility   elem_xpath=//*[@id="show_log_form:log_display_body"]
    ${output}    Run Keyword And Ignore Error  Wait Until Keyword Succeeds   3 times   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="show_log_form:log_display_body"]
    [Return]    ${status}

Delete Configuration
    [Arguments]   ${DN}
    #select
    ${status}   Select One Row With DN   DN=${DN}
    run keyword if  not ${status}   Return From Keyword   False
    #delete
    sleep   5s
    run keyword and ignore error  selenium_netact.wait_for_enable   elem_xpath=//*[@id="deleteNEButton"]
    Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button   button_xpath=//*[@id="deleteNEButton"]
    run keyword and ignore error  selenium_netact.wait_for_enable   elem_xpath=//*[@id="mainForm:deleteConfirmButton"]
    ${status}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button
    ...   button_xpath=//*[@id="mainForm:deleteConfirmButton"]
    Input Text on NEIW or NEAC   TextField_xpath=//*[@id="mainForm:main_table:rootMOFilterInput"]   Text=${DN}
    FOR    ${i}    IN RANGE    5
        ${num_text}    Wait Until Keyword Succeeds   3 times   5s
        ...   selenium_netact.get_elem_text   elem_xpath=//*[@id="mainForm:main_table:result"]
        ${num_text_reg}=   should match regexp  ${num_text}   \\d+
        ${num_nbr}=   BuiltIn.Convert To Integer   ${num_text_reg}
        ${status}    Run Keyword And Return Status    Should Be True    ${num_nbr}==0
        Exit For Loop If    ${status}
    END
    [Return]    ${status}
