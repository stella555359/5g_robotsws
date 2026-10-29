*** Settings ***
Documentation
...  author: He Jingmin
...  contact: jingmin.he@nokia-sbell.com
Library    Collections
Resource   ./NetAct_basic/Integration_NE.robot
Resource   ./NetAct_basic/Software_Asset_Monitoring.robot

*** Keywords ***
Open Netact Start Page
    [Documentation]   Open Netact WEB service start page. This keyword will retry open 10 times if network connection failure.
    ...    Author: jingmin.he@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | url | yes | the web link addr |
    ...   | username | yes | login username |
    ...   | password | yes | login password |
    ...   | showall | no | Input should be ${true} or ${false}, If the start page will be 'show all applications' or 'show applications by folder' |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Open Netact Start Page | ${url} | omc | omc |
    [Arguments]   ${url}   ${username}   ${password}   ${showall}=${true}
    Set Suite Variable   ${WEB_DOWNLOAD_DIR}   ${OUTPUT_DIR}
    Run Keyword And Ignore Error   selenium_netact.Set Download Dir   ${WEB_DOWNLOAD_DIR}
    Wait Until Keyword Succeeds   10m   1m   selenium_netact.Login   ${url}   ${username}   ${password}
    Run Keyword If    ${showall}    Show All Applications
    ...    ELSE    selenium_netact.wait for visibility   //a[contains(@folder, 'onfiguration')]

