*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   Common.robot


*** Keywords ***
UUF NetAct Integration New
    [Arguments]   ${testline}
    Log To Console   UUF NetAct Integration New: ${testline}
    nms.add_node   service_name=cmwas   hostname=${vm_ip}   username=${service_user}   password=${service_password}   alias=${alias}

    # nms.integrate_mrbts_with_netact
    # ...   release
    # ...

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   nms.delete_node   cmwas   alias=${alias}
    ...   AND
    ...   Run Keyword And Ignore Error   nms.clean_all    alias=${alias}



UUF NetAct Integration
    [Arguments]   ${testline}

    selenium_netact.enable_virtual_display

    # Open NetAct Start Page
    # Open Netact Start Page   url=${url}   username=${username}   password=${password}   showall=${false}
    ${dist_name}   Get Variable Value   ${ALL_CONFIG_SCF["${testline}"]["dist_name"]}
    ${url}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["url"]}   ${EMPTY}
    ${http_username}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_username"]}   ${EMPTY}
    ${http_password}   Get Variable Value   ${netact_global_configuration["${NETACT_IP}"]["http_password"]}   ${EMPTY}

    Return From Keyword If   "${NETACT_IP}"=="" or "${NETACT_IP}"=="${None}" or "${url}"==""

    Run Keyword And Ignore Error
    ...   selenium_netact.Set Download Dir   ${OUTPUT_DIR}
    Wait Until Keyword Succeeds   3x   30s
    ...   selenium_netact.Login   url=${url}   username=${http_username}   password=${http_password}
    Sleep   3s

    # Open NE Integration Wizard
    Run Keyword And Ignore Error
    ...   selenium_netact.wait_for_visibility   elem_xpath=//a[contains(@folder, 'administration')]
    selenium_netact.open_sub_page   category_xpath=//a[contains(@folder, 'administration')]   page_xpath=//span[text()='NE Integration Wizard']
    ...   page_name=NE Integration Wizard
    selenium_netact.switch_to_page   page_name=NE Integration Wizard
    Sleep   3s

    #Input DN
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id="mainForm:main_table"]
    selenium_netact.wait_for_visibility   elem_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']
    Wait Until Keyword Succeeds   3x   3s
    ...   selenium_netact.write_value_and_enter   input_xpath=//input[@id='mainForm:main_table:rootMOFilterInput']   value=${dist_name}
    Sleep   3s

    # Select Check Box
    Wait Until Keyword Succeeds   3x   5s   selenium_netact.select_checkbox   checkbox_xpath=//*[@id="mainForm:main_table:selectAllCheckBox"]
    Sleep   3s

    # Click Integrate Button
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="mainForm:integrate"]
    Wait Until Keyword Succeeds   3x   5s   selenium_netact.Click Button   button_xpath=//*[@id="mainForm:integrate"]
    Sleep   3s

    selenium_netact.wait_for_enable   elem_xpath=//input[@id='mainForm:continueButton']
    Wait Until Keyword Succeeds   3x   5s   selenium_netact.Click Button   button_xpath=//input[@id='mainForm:continueButton']
    Sleep   3s

    selenium_netact.wait_for_enable   elem_xpath=//input[@id='mainForm:withVerificationConfirmButton']
    Wait Until Keyword Succeeds   3x   5s   selenium_netact.Click Button   button_xpath=//input[@id='mainForm:withVerificationConfirmButton']
    Sleep   3s

    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   2m   10s   Check Integration Status

    [Teardown]   Run Keywords
    ...   Run Keyword And Ignore Error   Catch netact Screenshot by xpath   xpath=//body   AND
    ...   Run Keyword And Ignore Error   selenium_netact.logout   AND
    ...   Run Keyword And Ignore Error   selenium_netact.disable_virtual_display


Check Integration Status
    selenium_netact.wait_for_enable   elem_xpath=//div[@id='refreshButton']
    selenium_netact.click_button   button_xpath=//div[@id='refreshButton']
    Sleep   3s

    ${integrationStatus}   selenium_netact.get_elem_text   elem_xpath=//span[@id='mainForm:main_table:0:integrationStatus']
    ${verificationStatus}   selenium_netact.get_elem_text   elem_xpath=//span[@id='mainForm:main_table:0:verificationStatus']

    Should Be Equal   ${integrationStatus}   Completed
    Should Be Equal   ${verificationStatus}   Completed
