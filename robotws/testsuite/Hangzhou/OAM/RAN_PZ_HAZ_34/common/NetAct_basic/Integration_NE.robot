*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact

*** Variables ***
${NEW_NE_BTN_ID}   newNEButton
${NEW_NE_CONF_ID}   newNEInitConfiguration_container
${NEW_NE_FORM_ID}   selectionForm
${NE_TYPE_ID}   ${NEW_NE_FORM_ID}:neTypeFilterInput
${RELEASE_ID}   ${NEW_NE_FORM_ID}:adaptationReleaseFilterInput
${MR_ID}   ${NEW_NE_FORM_ID}:dynamicPanel:0:mrfqdnInput
${NE3SWS_IP_VERSION_ID}   ${NEW_NE_FORM_ID}:dynamicPanel:6:enumInput
${NE3SWS_IP_VERSION_22R3_ID}   ${NEW_NE_FORM_ID}:dynamicPanel:5:enumInput
${NE3SWS_MODE_ID}   ${NEW_NE_FORM_ID}:dynamicPanel:7:enumInput
@{NEW_NE_SELECT_LIST}   ne_type   release   mr   ne3sws_ip_version   ne3sws_mode

*** Keywords ***
Configure NE in NIEW
    [Arguments]    ${ne_type}    ${release}    ${mr}    ${IP}    ${ne3sws_ip_version}=IPv4   ${ne3sws_mode}=TLS
    ...   ${mo_name}=${MO_name}
    Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button   //*[@id="${NEW_NE_BTN_ID}"]
    run keyword and ignore error  Wait Until Keyword Succeeds   3 times   5s
    ...   selenium_netact.wait_for_visibility    //*[@id="${NEW_NE_CONF_ID}"]
    run keyword and ignore error  Wait Until Keyword Succeeds   3 times   5s
    ...   selenium_netact.wait_for_visibility   //*[@id="${NE_TYPE_ID}"]
    FOR   ${ne_config}   IN   @{NEW_NE_SELECT_LIST}
       ${NE3SWS_IP_VERSION_ID}   set variable if  '${release}'=='SBTS22R2' or '${release}'=='SBTS22R1'
       ...   ${NE3SWS_IP_VERSION_ID}   ${NE3SWS_IP_VERSION_22R3_ID}
       Select Value From List   //*[@id="${${ne_config}_ID}"]   ${${ne_config}}
    END
    #select NE type
#    ${status}   Select Value From List   //*[@id="selectionForm:neTypeFilterInput"]   ${ne_type}
#    #Select release
#    ${status}   Select Value From List    //*[@id="selectionForm:adaptationReleaseFilterInput"]   ${release}
#    #Select MR
#    ${status}   Select Value From List   //*[@id="selectionForm:dynamicPanel:0:mrfqdnInput"]   ${mr}
    #input IP
    ${status}   Input Text on NEIW or NEAC   //*[starts-with(@id,'selectionForm:dynamicPanel:') and contains(@id,':address')]   ${IP}
    #input DN
    ${status}   Input Text on NEIW or NEAC   //*[starts-with(@id,'selectionForm:dynamicPanel:') and contains(@id,':fqdn')]    PLMN-PLMN/${mo_name}
    #input NE name
    ${status}   Run keyword if  '${release}'=='SBTS22R2' or '${release}'=='SBTS22R1'
    ...   Input Text on NEIW or NEAC   TextField_xpath=//*[@id="selectionForm:dynamicPanel:3:string"]   Text=${mo_name}
    ...   ELSE   Input Text on NEIW or NEAC   TextField_xpath=//*[@id="selectionForm:dynamicPanel:2:string"]   Text=${mo_name}
#    #input NE3SWS IP version
#    ${status}   Select Value From List   //*[@id="selectionForm:dynamicPanel:6:enumInput"]   ${ne3sws_ip_version}
#    #input NE3SWS agent security mode
#    ${status}   Select Value From List   //*[@id="selectionForm:dynamicPanel:7:enumInput"]   ${ne3sws_mode}
    #save button
    run keyword and ignore error   selenium_netact.wait_for_visibility   //*[@id="selectionForm:save"]
    Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button    //*[@id="selectionForm:save"]

Integrate Action via Integrate Button
    [Arguments]   ${DN}
    #select DN
    ${status}    Select One Row With DN   ${DN}
    run keyword if  not ${status}   Return From Keyword   ${status}
    #integrate
    run keyword and ignore error  Wait Until Keyword Succeeds   3 times   5s   selenium_netact.wait_for_enable   //*[@id="mainForm:integrate"]
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds   3 times   5s
    ...   selenium_netact.Click Button   button_xpath=//*[@id="mainForm:integrate"]
    #new integration dialog
    ${new_status}   Run Keyword And Return Status   selenium_netact.wait_for_visibility
    ...   elem_xpath=//div[@id='mainForm:confirmIntegrationWithVerification_container']
    #check if reintegration dialog appeard
    sleep    10s
    ${re_status}   Run Keyword And Return Status   selenium_netact.wait_for_visibility
    ...   elem_xpath=//div[@id='mainForm:duplicatedMosPanel_container']
    Sleep    10s
    #confirm
    Run Keyword If   ${re_status}   selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:continueButton"]
    Run Keyword If   ${re_status}   selenium_netact.move_to_element   elem_xpath=//*[@id="mainForm:continueButton"]
    Run Keyword If   ${re_status}   selenium_netact.Click Button   button_xpath=//*[@id="mainForm:continueButton"]
    Sleep  5s
    ${yesbutton_status}   run keyword and return status  selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id="mainForm:withVerificationConfirmButton"]
    Run Keyword If   ${new_status} or ${yesbutton_status}   selenium_netact.wait_for_visibility
    ...   elem_xpath=//*[@id="mainForm:withVerificationConfirmButton"]
    Run Keyword If   ${new_status} or ${yesbutton_status}   selenium_netact.move_to_element
    ...   elem_xpath=//*[@id="mainForm:withVerificationConfirmButton"]
    Run Keyword If   ${new_status} or ${yesbutton_status}   selenium_netact.Click Button
    ...   button_xpath=//*[@id="mainForm:withVerificationConfirmButton"]
    Sleep   10s

Select One Row With DN
    [Arguments]   ${DN}
    run keyword and ignore error  selenium_netact.wait_for_visibility    //*[@id="mainForm:main_table"]
    Input Text on NEIW or NEAC   //*[@id="mainForm:main_table:rootMOFilterInput"]   ${DN}
    Sleep   5s
    #1, select
    ${status}  Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s   selenium_netact.select_checkbox
    ...   //*[@id="mainForm:main_table:selectAllCheckBox"]    #select all, only 1 is visible
    Sleep   5s
    [Return]    ${status}

Check if NE or MR in Table
    [Arguments]   ${TextField_xpath}   ${Text}   ${main_table_xpath}   ${total_xpath}   ${result_xpath}
    Wait Until Keyword Succeeds   31s   10s   selenium_netact.wait_for_visibility   ${main_table_xpath}
    Input Text on NEIW or NEAC  ${TextField_xpath}   ${Text}
    Sleep   10s
    run keyword and ignore error   selenium_netact.wait_for_visibility   ${result_xpath}
    ${result_text}    Wait Until Keyword Succeeds   1min   10s   selenium_netact.get_elem_text    ${result_xpath}
    ${result_text_reg}=  Should Match Regexp   ${result_text}   \\d+
    ${result_text_nbr}=   BuiltIn.Convert To Integer   ${result_text_reg}
    ${status}=   Run Keyword If   "${result_text_nbr}"=="0"   set variable  False
    ...   ELSE   set variable  True
    [Return]  ${status}

Input Text on NEIW or NEAC
    [Arguments]   ${TextField_xpath}   ${Text}
    ${TextField_text}=   Wait Until Keyword Succeeds   31s   10s   selenium_netact.get_element_attribute   ${TextField_xpath}   value
    ${status}=   Run Keyword And Return Status   should match regexp   ${TextField_text}   ${Text}
    Return From Keyword If    ${status}
    FOR    ${i}    IN RANGE    20
        Wait Until Keyword Succeeds   31s   10s   selenium_netact.write_value_and_enter    ${TextField_xpath}    ${Text}
        ${TextField_text}=   Wait Until Keyword Succeeds   31s   10s   selenium_netact.get_element_attribute   ${TextField_xpath}   value
        ${status}=   Run Keyword And Return Status   should match regexp   ${TextField_text}   ${Text}
        Exit For Loop If    ${status}
        Wait Until Keyword Succeeds   31s   10s   selenium_netact.click_button    ${TextField_xpath}
    END
    Sleep   5s
    [Return]    ${status}

Select Value From List
    [Arguments]    ${index}    ${value}   ${list_element_nbr}=3
    FOR   ${i}    IN RANGE    ${list_element_nbr}
        Wait Until Keyword Succeeds   3 times   5s   selenium_netact.click_button   ${index}
        ${status}=   Run Keyword And Return Status   Wait Until Keyword Succeeds   3 times   5s
    ...   selenium_netact.click_button    //*[@title="${value}"]
        Exit For Loop If   ${status}
    END
    sleep   2s
    [Return]    ${status}
