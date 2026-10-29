*** Settings ***
Resource    ${CURDIR}/selenium_netact_basic_keywords.robot

*** Variables ***
${MODULE_ROOT}   Reporting
${MODULE_NAME}   Software Asset Monitoring
${REPORT_BTN_ID}   cmSubMenuID1
${MENU_ID}   calypso_menu

*** Keywords ***
Open Software Asset Monitoring Module
    [Documentation]   Open "Software Asset Monitoring" Start Page.
    ...   Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*
    ...    None
    #Go to SWAM
    Open Sub page in home page   //span[text()='${MODULE_ROOT}']   //span[text()='${MODULE_NAME}']    ${MODULE_NAME}
    Wait Until Keyword Succeeds   3 times   10s   Show Components Software Asset Monitoring Reporting
    ...   Modules   modules:modulesForm:moduleResultTable
    Sleep   5s

_Show sub Menu Software Asset Monitoring
    [Arguments]   ${item}    ${component}
    [Documentation]   Internal Keyword, open the Main menu leve1 1 by input Reporting/Settings
    run keyword if   '${component}'=='Modules'    selenium_netact.switch_to_page    Software Asset Monitoring
    run keyword if   '${component}'=='Modules'     _additional_report_click
    selenium_netact.wait_for_enable    //div[@id='${MENU_ID}']//span[text()='${item}']
    selenium_netact.click_button    //div[@id='${MENU_ID}']//span[text()='${item}']

_additional_report_click
    ${subpage_xpath}    create list   //*[@id="root"]/div/div[2]/div[3]/div/div[1]/div/div/ul/li[2]
    Wait Until Keyword Succeeds   3 times   10s
    ...   selenium_netact.open_sub_page_by_xpath_list
    ...    sub_page_xpath_list=${subpage_xpath}
    ...    page_name=reporting

Show Components Software Asset Monitoring Reporting
    [Arguments]   ${component}   ${tb_name}
    [Documentation]   Open Reportings in "Software Asset Monitoring" Start Page.
    ...   Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | component | yes | the component name required to open |
    ...   | tb_name | yes | the table name id related to component name, consider enhancement to cancel this input |
    ...    *RETURN VALUE*
    ...    None
    _Show sub Menu Software Asset Monitoring   item=Reporting    component=${component}
    selenium_netact.wait_for_enable    //div[@id='${REPORT_BTN_ID}']//a[text()='${component}']
    selenium_netact.click_button    //div[@id='${REPORT_BTN_ID}']//a[text()='${component}']
    selenium_netact.wait_for_visibility    //table[@id='${tb_name}']

Check NetAct Module In Software Asset Monitoring Table
    [Arguments]   ${table_id}   ${module_name}   ${col_name}
    ${table_ele}   Set Variable   return document.getElementById('${table_id}:tb')
    ${table_row_length}=   selenium_netact.execute_script   ${table_ele}.rows.length
    FOR   ${row}    IN RANGE    ${table_row_length}
       ${module_type}   selenium_netact.get_elem_text   //td[@id='${table_id}:${row}:${row}:${col_name}']
       Exit For Loop If   '${module_type}'=='${module_name}'
    END
    [Return]   ${row}

Create SWEM report
    [Arguments]   ${report_title}=SWEM for 5G RAN CM
    [Documentation]   Create new report for requested type
    ...   Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | report_title | yes | the report title in Module Page |
    ...    *RETURN VALUE*
    ...    None
    selenium_netact.switch_to_page    Software Asset Monitoring
    Show Components Software Asset Monitoring Reporting   Modules   modules:modulesForm:moduleResultTable
    ${row}   Check NetAct Module In Software Asset Monitoring Table   ${module_table_id}
    ...   ${report_title}   moduleNameColumn
    Module Create Generate Report   ${row}
    Sleep   2m
    Wait Until Keyword Succeeds   3 times   10s   Show Components Software Asset Monitoring Reporting
    ...   Reports   ${report_table_id}
