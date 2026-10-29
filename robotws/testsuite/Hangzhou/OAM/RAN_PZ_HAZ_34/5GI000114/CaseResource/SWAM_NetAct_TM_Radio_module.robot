*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Keyword ***
SWAM NetAct TM Radio Module Test Case
    Step1: Check NetAct TM Radio Module In Table
    Step2: Click Modify Icon

Step1: Check NetAct TM Radio Module In Table
    ${table_id}   Set Variable   modules:modulesForm:moduleResultTable
    selenium_netact.wait_for_visibility   elem_xpath=//table[@id='${table_id}']
    ${row} =   Check NetAct Module In Software Asset Monitoring Table   table_id=${table_id}
    ...   module_name=NetAct™ Radio   col_name=moduleTypeColumn
    Set Test Variable   ${row}

    Check Module Definitions   table_id=${table_id}   row=${row}
    ...   check_name=NetAct™ Radio   check_type=NetAct™ Radio   check_enabled=Yes   check_mail=Default   check_user=System
    Check Module Button Enabled   table_id=${table_id}   row=${row}
    ...   btn_modify=enabled   btn_delete=disabled   btn_report=enabled

Step2: Click Modify Icon
    #Click Modify Button
    selenium_netact.click_button   button_xpath=//td[@id='modules:modulesForm:moduleResultTable:${row}:${row}:actionColumn']//img[@alt='Modify']
    #Click Features
    selenium_netact.wait_for_visibility   elem_xpath=//div[@class='breadcrumbContainer']//span[text()='Features']
    selenium_netact.click_button   button_xpath=//div[@class='breadcrumbContainer']//span[text()='Features']
    #Check definitions Table Appeared
    selenium_netact.wait_for_visibility   elem_xpath=//table[@id='modules:moduleConfigurationWizardForm:wizardStep:definitionsTable']
    #Click Cancel
    selenium_netact.wait_for_visibility   elem_xpath=//a[@id='modules:moduleConfigurationWizardForm:cancelButton']
    selenium_netact.click_button   button_xpath=//a[@id='modules:moduleConfigurationWizardForm:cancelButton']

Case Setup: SWAM NetAct TM Radio Module
    Log To Console    \nStart To SWAM Case Setup!
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
    Open Software Asset Monitoring Module

Case Teardown: SWAM NetAct TM Radio Module
    Log To Console   Start To SWAM Case Teardown!
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
