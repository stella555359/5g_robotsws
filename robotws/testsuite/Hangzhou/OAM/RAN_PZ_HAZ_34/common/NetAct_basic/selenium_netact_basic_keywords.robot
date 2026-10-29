*** Settings ***
Library    taf.ul.selenium.netact    WITH NAME    selenium_netact

*** Variables ***
${WEB_DOWNLOAD_DIR}
@{START_PAGE_FOLDER_LIST}

*** Keywords ***
Open Sub page in home page
    [Documentation]   Click the element in Netact start page, and the sub page should be opened in another browser tab.
    ...   Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | root_path | yes | the web link addr |
    ...   | page_path | yes | login username |
    ...   | page_name | yes | login password |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Open Sub page in home page | ${folder_xpath} | ${func_xpath} | ${sub_page_name} |
    [Arguments]   ${root_path}   ${page_path}   ${page_name}
    selenium_netact.switch_to_page   Start Page
    ${show_all_mode}   Run Keyword and Return Status   selenium_netact.wait_for_visibility   ${root_path}
    @{xpath}   run keyword if  not ${show_all_mode}   Create List   ${page_path}
    Run Keyword If   ${show_all_mode}   selenium_netact.open_sub_page    ${root_path}   ${page_path}    ${page_name}
    ...   ELSE   Run Keywords   Show All Applications
    ...   AND   selenium_netact.open_sub_page    ${root_path}   ${page_path}    ${page_name}
#    selenium_netact.open_sub_page_by_xpath_list   ${xpath}   ${page_name}

_Show Mode Match Start Page
    [Arguments]   ${request_action}
    selenium_netact.switch_to_page   Start Page
    selenium_netact.Wait For Visibility    //a[@id='linkShowAppFolder']
    selenium_netact.Click Button   //a[@id='linkShowAppFolder']
    ${show_mode}   Run Keyword and Return Status   selenium_netact.Wait For Visibility    //span[text()='${request_action}']
    [Return]   ${show_mode}

_Show All Applications enable or disable
    [Documentation]   Internal Keyword, Shouldn't use directly.
    [Arguments]   ${request_action}
    ${show_mode}   _Show Mode Match Start Page   ${request_action}
    Run Keyword If   ${show_mode}   selenium_netact.Click Button   //span[text()='${request_action}']
    Log To Console    Open NetAct Start Page And Show All Applications Succeeds!

Show All Applications
    [Documentation]   Enter Netact start page and click button "Show all applications"
    ...    Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...    *RETURN VALUE*v
    ...    None
    _Show All Applications enable or disable   Show all applications

Show Applications by folder
    [Documentation]   Enter Netact start page and click button "Show Applications by folder"
    ...    Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   None
    ...    *RETURN VALUE*
    ...    None
    _Show All Applications enable or disable   Show applications by folder
