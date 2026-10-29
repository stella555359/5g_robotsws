*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_Fast_Pass_common.robot

*** Variables ***
${table_id}   modules:modulesForm:moduleResultTable

*** Keyword ***
SWAM CM Module Creation Test Case
    Step1: Create New Module
    Step2: Check New Module
    Step3: Delete New Module

Step1: Create New Module
    #Click New Module Button
    selenium_netact.wait_for_visibility   elem_xpath=//a[@id='modules:modulesForm:newModule']
    selenium_netact.click_button   button_xpath=//a[@id='modules:modulesForm:newModule']
    #Wait For Configuration Form
    selenium_netact.wait_for_visibility   elem_xpath=//*[@id='${config_form}']

    Basic Configuration Settings   module_name=Example   module_type=5G RAN CM   enabled=Yes
    selenium_netact.click_button   button_xpath=//a[@id='${config_form}:nextButton']
    Sleep   5s

    Report Generation Scheduling
    selenium_netact.click_button   button_xpath=//a[@id='${config_form}:nextButton']
    Sleep   5s

    Aggregation Level   Agg_level=Off   highest_value=1
    selenium_netact.click_button   button_xpath=//a[@id='${config_form}:nextButton']
    Sleep   5s

    Select All Features
    selenium_netact.click_button   button_xpath=//a[@id='${config_form}:nextButton']
    Sleep   5s

    Edit Selected Features Details   row=0   initial_base=1   warning_threshold=2
    selenium_netact.click_button   button_xpath=//a[@id='${config_form}:nextButton']
    Sleep   5s

    selenium_netact.click_button   button_xpath=//a[@name='${config_form}:finishButton']

Step2: Check New Module
    selenium_netact.wait_for_visibility   elem_xpath=//table[@id='${table_id}']
    ${row} =   Check NetAct Module In Software Asset Monitoring Table   table_id=${table_id}
    ...   module_name=Example   col_name=moduleNameColumn
    Set Test Variable   ${row}
    Check Module Definitions   table_id=${table_id}   row=${row}
    ...   check_name=Example   check_type=5G RAN CM   check_enabled=Yes   check_mail=Default   check_user=${START_PAGE_USER}
    Check Module Button Enabled   table_id=${table_id}   row=${row}
    ...   btn_modify=enabled   btn_delete=enabled   btn_report=enabled

Step3: Delete New Module
    Delete Module   table_id=${table_id}   row=${row}
    selenium_netact.click_button   button_xpath=//a[@id='modules:modulesForm:refreshButton']
    Sleep   5s
    ${table_ele}   Set Variable   return document.getElementById('${table_id}:tb')
    ${table_row_length}=   selenium_netact.execute_script   script_cmd=${table_ele}.rows.length
    FOR   ${row}    IN RANGE    ${table_row_length}
       ${module_name}   selenium_netact.get_elem_text   elem_xpath=//td[@id='${table_id}:${row}:${row}:moduleNameColumn']
       Run Keyword If   '${module_name}'=='Example'   Fail   Delete New Module Failed!
       Exit For Loop If   '${module_name}'=='Example'
    END

Case Setup: SWAM CM Module Creation
    Log To Console    \nStart To SWAM Case Setup!
    Open Netact Start Page   url=${START_PAGE}   username=${START_PAGE_USER}   password=${START_PAGE_PASSWORD}   showall=${false}
    Open Software Asset Monitoring Module

Case Teardown: SWAM CM Module Creation
    Log To Console   Start To SWAM Case Teardown!
    Run Keyword And Ignore Error   selenium_netact.Logout
    Run Keyword And Ignore Error   selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown