*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB010413_011-F_vDU_WEBEM Infrastructure Status_PODs status and detail panel checking
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot




*** Keywords ***
VRAN_CM_Infrastructure_Status_PODs_Status_And_Detail_Panel_Checking_vDU_CB010413_011
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    06.05.2024, yuyan.xu@nokia-sbell.com, draft
    Step 1: Randomly Select One POD
    Step 2: Check Detail Page
    Step 3: Check Table View

Step ${index}: Randomly Select One POD
    Log    Step ${index}: Randomly Select One POD    console=True
    vDU WebEM Go To By Site Bar Menu    Status    VNFC Status
    ${pod_dic}    Random Select One POD
    Set Test Variable    ${pod_dic}

Step ${index}: Check Detail Page
    Log    Step ${index}: Check Detail Page    console=True
    Open Details Panel
    Select Tab On Detail Panel    Overview
    Go to PE On Detail Panel    ${pod_dic["id"]}

Step ${index}: Check Table View
    Log    Step ${index}: Check Table View    console=True
    Switch To Table View on VNFC Status

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    ${ReIntegrate_vCU}
    Log To Console    ${ReIntegrate_vDU}
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123

Case Postcondition
    Log To Console    Case Postcondition
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Common Test Teardown For AIC
    Logout And Close WEBEM

Switch To Table View on VNFC Status
    vDU WebEM Go To By Site Bar Menu    Status    VNFC Status
    Wait Element Visible And Click    //infrastructure-status//button/span[text()='Table View']
    Wait Until Element Is Visible    //infrastructure-status//button/span[text()='Widget View']
    Wait Until Element Is Visible    //infrastructure-status/infrastructure-status-table-view//p-table
    #Check Role
    Wait Until Element Is Visible    //infrastructure-status/infrastructure-status-table-view//p-table//th[text()=" Role "]
    Capture Page Screenshot

Random Select One POD
    ${count_pod}    Selenium2Library.Get Element Count    //infrastructure-status//cem-common-widget
    ${index}    Evaluate    random.randint(1, ${count_pod})    modules=random, sys
    Selenium2Library.Click Element    //infrastructure-status//cem-common-widget[${index}]
    Wait Until Element Is Visible    //infrastructure-status//cem-common-widget[${index}]/ot-card[@class='cem-widget cem-widget-selected']
    ${name}    Selenium2Library.Get Text
    ...    //infrastructure-status//cem-common-widget[${index}]//div[contains(@class,'widget-title')]/div
    ${id}    Selenium2Library.Get Text
    ...    //infrastructure-status//cem-common-widget[${index}]//div[@class='widget-content']/div[contains(@class,'p-element')]
    ${status}    Selenium2Library.Get Text
    ...    //infrastructure-status//cem-common-widget[${index}]//div[contains(@class,'label-row')]//span[@class='p-tag-value']
    ${pod_dic}    Create Dictionary    name=${name}    id=${id}    status=${status}
    [Return]    ${pod_dic}

Go to PE On Detail Panel
    [Arguments]    ${id}
    Wait Until Element Is Visible    //button/span[text()='Go to PE']
    Selenium2Library.Click Element    //button/span[text()='Go to PE']
    Wait Until Element Is Visible    //span[text()='Parameter Editor']
    sleep    10s
    ${distname}    Selenium2Library.Get Text    //div[@class='pe-container']//span[@id='object-distname']
    ${dn_pe}    Fetch From Right    ${distname}    /
    Should Be Equal    ${id}    ${dn_pe}


Select Tab On Detail Panel
    [Arguments]    ${tab_name}
    ${tab_selected}    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    //a[@aria-selected='true']/span[contains(@class,'p-tabview-title') and text()='${tab_name}']
    Return From Keyword If    ${tab_selected}
    Selenium2Library.Click Element    //span[contains(@class,'p-tabview-title') and text()='${tab_name}']
    Wait Until Element Is Visible    //a[@aria-selected='true']/span[contains(@class,'p-tabview-title') and text()='${tab_name}']
    Capture Page Screenshot
