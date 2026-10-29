*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource   ../Resource/NetAct_common.robot
Resource   ../../common/taf_megazone.robot

*** Variables ***
${DN_ROW}

*** Keyword ***
CNUM_Centralized_NE_User_Management
    Step1: Open NEAC Application Combine
    Step2: Activate CNUM Combine
    Step3: Select a NE and Check Update Password Button is Enabled
    Step4: Update Password
    Step5: Refresh Web and Check if Password is Updated
    Step6: Deactivate CNUM
    Step7: Verify CNUM Deactivation

Step1: Open NEAC Application Combine
    wait until keyword succeeds  30s   5s   selenium_netact.open_sub_page    category_xpath=//span[text()='Security']
    ...   page_xpath=//span[text()='Network Element Access Control']    page_name=Network Element Access Control
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="otPBproductName"]
    wait until keyword succeeds  30s   5s   selenium_netact.switch_to_page   page_name=Network Element Access Control
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="centralizedNEUserMgmt_cell"]
    wait until keyword succeeds  30s   5s   selenium_netact.click_button   button_xpath=//*[@id="centralizedNEUserMgmt_cell"]

Step2: Activate CNUM Combine
    Set Test Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    ${row_num}=    Set Variable    0
    Wait Until Keyword Succeeds   5times   10s
    ...   selenium_netact.write_value_and_enter   input_xpath=//*[@id="cnumList:dataTableCnum:neFilterBox"]   value=${DN}
    Sleep    10s
    FOR    ${i}    IN RANGE    200
        ${context}=    get_elem_text   elem_xpath=//*[@id="cnumList:dataTableCnum:${i}:oPTNeName"]
        ${row_num}=    Set Variable    ${i}
        log    ${context}
        Run Keyword If    '${DN}' in '${context}'    Run Keyword    Exit For Loop
    END
    selenium_netact.click_button   button_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:oPTIPversionSelected"]
    Sleep    5s
    Set Test Variable    ${xpath_1}    //*[@id="cnumList:dataTableCnum:${row_num}:oPTIPversionSelected"]/option[1]
    Set Test Variable    ${xpath_2}    //*[@id="cnumList:dataTableCnum:${row_num}:oPTIPversionSelected"]/option[2]
    Run Keyword If    '${NE3SWS_IPversion}'=='IPv4'    Run Keyword    selenium_netact.click_button   button_xpath=${xpath_1}
    ...    ELSE    selenium_netact.click_button   button_xpath=${xpath_2}
    Sleep    3s
    selenium_netact.click_button   button_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:oPTSAccessTypeList"]
    Sleep    5s
    Set Test Variable    ${tls_xpath_1}    //*[@id="cnumList:dataTableCnum:${row_num}:oPTSAccessTypeList"]/option[1]
    Sleep    5s
    Set Test Variable    ${tls_xpath_2}    //*[@id="cnumList:dataTableCnum:${row_num}:oPTSAccessTypeList"]/option[2]
    Sleep    5s
    Run Keyword If    '${NE3SWS_mode}'=='TLS'    Run Keyword    selenium_netact.click_button   button_xpath=${tls_xpath_1}
    ...    ELSE    selenium_netact.click_button   button_xpath=${tls_xpath_2}    
    Sleep    5s
    select_checkbox   checkbox_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:chkRow"]
    selenium_netact.click_button   button_xpath=//*[@id="cnumList:startActivation"]
    Sleep    50s
    ${context}=    get_elem_text   elem_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:oPTSNeCnumStatusOutputText"]
    Run Keyword If    'Activated'=='${context}'    log    'Activated succeed!'
    ...    ELSE    Fail

Step3: Select a NE and Check Update Password Button is Enabled
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="cnumList:dataTableCnum:recordsCount"]
    wait until keyword succeeds  20s   5s   selenium_netact.click_button   button_xpath=//*[@id="cnumList:dataTableCnum:recordsCount"]
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="cnumList:dataTableCnum:recordsCount"]/option[5]
    wait until keyword succeeds  20s   5s   selenium_netact.click_button   button_xpath=//*[@id="cnumList:dataTableCnum:recordsCount"]/option[5]
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="cnumList:dataTableCnum"]/tfoot/tr/td/div[1]/span[3]
    ${total_nbr}   wait until keyword succeeds  20s   5s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="cnumList:dataTableCnum"]/tfoot/tr/td/div[1]/span[3]
    ${total_nbr}   should match regexp  ${total_nbr}   \\d+
    FOR    ${i}    IN RANGE    ${total_nbr}
        ${context}=    wait until keyword succeeds  20s   5s
       ...   selenium_netact.get_elem_text   elem_xpath=//*[@id="cnumList:dataTableCnum:${i}:oPTNeName"]
        Set Test Variable    ${DN_ROW}   ${i}
        ${status}   run keyword and return status   should be equal   PLMN-PLMN/${MO_NAME}   ${context}
        exit for loop if  ${status}
    END
    run keyword if  not ${status}   Fail   DN is not in NEAC
    wait until keyword succeeds  20s   5s   selenium_netact.select_checkbox   checkbox_xpath=//*[@id="cnumList:dataTableCnum:${DN_ROW}:chkRow"]
    run keyword and ignore error   Catch Screenshot by xpath   xpath=//body   library=selenium_netact
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="cnumList:updatePassword"]
    run keyword and ignore error   Catch Screenshot by xpath   xpath=//body   library=selenium_netact

Step4: Update Password
    wait until keyword succeeds  20s   5s   selenium_netact.click_button   button_xpath=//*[@id="cnumList:updatePassword"]
    run keyword and ignore error  Catch Screenshot by xpath   xpath=//body   library=selenium_netact

Step5: Refresh Web and Check if Password is Updated
    wait until keyword succeeds  20s   5s   selenium_netact.click_button   button_xpath=//*[@id="cnumList:refreshlink"]/span
    run keyword and ignore error  Catch Screenshot by xpath    xpath=//body   library=selenium_netact
    selenium_netact.wait_for_enable   elem_xpath=//*[@id="cnumList:dataTableCnum"]/thead/tr/th[1]
    wait until keyword succeeds  2min   10s   Check if Password is Updated Combine

Step6: Deactivate CNUM
    Set Test Variable    ${DN}    PLMN-PLMN/${MO_NAME}
    ${row_num}=    Set Variable    0
    Wait Until Keyword Succeeds    5times    10s
    ...    selenium_netact.write_value_and_enter   input_xpath=//*[@id="cnumList:dataTableCnum:neFilterBox"]   value=${DN}
    Sleep    10s
    FOR    ${i}    IN RANGE    200
        ${context}=    get_elem_text   elem_xpath=//*[@id="cnumList:dataTableCnum:${i}:oPTNeName"]
        ${row_num}=    Set Variable    ${i}
        log    ${context}
        Run Keyword If    '${DN}' in '${context}'    Run Keyword    Exit For Loop
    END
    selenium_netact.click_button   button_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:oPTIPversionSelected"]
    Sleep    5s
    Set Test Variable    ${xpath_1}    //*[@id="cnumList:dataTableCnum:${row_num}:oPTIPversionSelected"]/option[1]
    Set Test Variable    ${xpath_2}    //*[@id="cnumList:dataTableCnum:${row_num}:oPTIPversionSelected"]/option[2]
    Run Keyword If    '${NE3SWS_IPversion}'=='IPv4'    Run Keyword    selenium_netact.click_button   button_xpath=${xpath_1}
    ...    ELSE    selenium_netact.click_button   button_xpath=${xpath_2}
    select_checkbox   checkbox_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:chkRow"]
    selenium_netact.click_button   button_xpath=//*[@id="cnumList:startDeactivation"]
    Sleep    30s
    ${context}=    get_elem_text   elem_xpath=//*[@id="cnumList:dataTableCnum:${row_num}:oPTSNeCnumStatusOutputText"]
    Run Keyword If    'Deactivated'=='${context}'    log    'Deactivated succeed!'
    ...    ELSE    Fail

Step7: Verify CNUM Deactivation
    Comment    Open Netact Start Page    url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${true}
    selenium_netact.switch_to_page   page_name=Start Page
    sleep    2s
    selenium_netact.click_button   button_xpath=//*[@id="linkShowAppFolder"]/span[1]/span/span
    sleep    2s
    selenium_netact.click_button   button_xpath=/html/body/div[8]/ul/li/a/span
    #Open monitor
    ${remote_port}    Open Application   app_name=Monitor
    Set Test Variable    ${remote_port}
    Select Main Window
    Wait Until Keyword Succeeds    1m    10s    Menu Item Should Exist   menuPath=Tools|Managed Objects|Object Explorer
    Select From Menu And Wait   menuPath=Tools|Managed Objects|Object Explorer
    Click On Tree Node   Objects   PLMN-PLMN|${MO_NAME}   \#0
    Select From Popup Menu On Selected Tree Nodes   Objects   Element Management|Element Manager   \#0
    sleep    10s

Check if Password is Updated Combine
    ${CUNM_status}   wait until keyword succeeds  10s   2s   selenium_netact.get_elem_text
    ...   elem_xpath=//*[@id="cnumList:dataTableCnum:${DN_ROW}:oPTSNeCnumStatusOutputText"]
    run keyword and ignore error  Catch Screenshot by xpath   xpath=//body   library=selenium_netact
    should be equal   Password updated   ${CUNM_status}

Case Setup: CNUM User Login Combine
    Log To Console    \nStart To CNUM Case Setup!
    Open Netact Start Page    url=${START_PAGE}    username=${START_PAGE_USER}    password=${START_PAGE_PASSWORD}    showall=${false}

Case Teardown: CNUM User Login Combine
    Log To Console    Start To CNUM Case Teardown!
    Run Keyword And Ignore Error    Close Java Application by Remote Port   remote_port=${remote_port}
    Run Keyword And Ignore Error   Close All Java Application Forced
    Run Keyword And Ignore Error    selenium_netact.Logout
    Run Keyword And Ignore Error    selenium_coam.Logout
    Run Keyword And Ignore Error   Common Case Teardown
