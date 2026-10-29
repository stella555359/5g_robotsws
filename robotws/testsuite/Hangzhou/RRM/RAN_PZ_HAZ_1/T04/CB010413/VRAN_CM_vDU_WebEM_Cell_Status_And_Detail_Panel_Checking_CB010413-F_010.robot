*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot



*** Keywords ***
VRAN_CM_vDU_WebEM_Cell_Status_And_Detail_Panel_Checking_CB010413-F_010
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for RAN_ST_CB010413_009-F_vDU_vCU_WebEM support export the content of the view to a file.docx
    ...    Only check partial parameters on vDU of this case.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.08.2024 - New case.
    Log To Console    ${TEST_NAME} start.    console=${True}
    Step 1: Select One Cell
    Step 2: Oper The Cell On Site View Via Detail Panel
    Step 3: Oper The Cell On Cells Status Via Detail Panel

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Get Vairables For This Case

Case Postcondition
    Log To Console    \n Case Postcondition
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Logout And Close WEBEM
    Common Test Teardown For AIC
    SSHLibrary.Close All Connections

Get Vairables For This Case
    Open WEBEM and Login    https://${du_ip}    Nemuadmin    Nokia@123    ${TEST_LOG_DIRECTORY}
    Log Variables

vDU WebEM Select Cell On Site View
    [Arguments]    ${cell_name}
    vDU WebEM Go To By Site Bar Menu    Status    Site View
    Wait Until Element Is Visible    //vdu-site-view-vdu-cell-tile
    Selenium2Library.Click Element    //vdu-site-view-vdu-cell-tile/div[@data-vducell-name="${cell_name}"]

vDU WebEM Block Selected Cell Via Detail Panel
    Open Details Panel
    Wait Until Element Is Visible    //webem-details-panel//p-button//span[text()="Block Cell"]
    Selenium2Library.Click Element    //webem-details-panel//p-button//span[text()="Block Cell"]
    Wait Until Element Is Visible    //p-confirmdialog//span[text()="Block cell"]
    Wait Until Element Is Visible    //p-confirmdialog//button//span[text()="OK"]
    Selenium2Library.Click Element    //p-confirmdialog//button/span[text()="OK"]/..
    Wait Until Element Is Visible    //webem-details-panel//p-button//span[text()="Unblock Cell"]    timeout=1 min

vDU WebEM UnBlock Selected Cell Via Detail Panel
    Open Details Panel
    Wait Until Element Is Visible    //webem-details-panel//p-button//span[text()="Unblock Cell"]
    Selenium2Library.Click Element    //webem-details-panel//p-button//span[text()="Unblock Cell"]
    Wait Until Element Is Visible    //p-confirmdialog//span[text()="Unblock cell"]
    Wait Until Element Is Visible    //p-confirmdialog//button//span[text()="OK"]
    Selenium2Library.Click Element    //p-confirmdialog//button/span[text()="OK"]/..
    Wait Until Element Is Visible    //webem-details-panel//p-button//span[text()="Block Cell"]    timeout=3 min

vDU WebEM Go To PE Via Detail Panel
    Open Details Panel
    Wait Until Element Is Visible    //webem-details-panel//p-button//span[text()="Go to PE"]
    Selenium2Library.Click Element    //webem-details-panel//p-button//span[text()="Go to PE"]/..
    Wait Until Element Is Visible    ${PARAMETER_EDITOR}    timeout=1 min
    Wait Until Element Is Visible    //tree-node-wrapper/div[contains(@class,"node-content-wrapper-focused")]//span[@id="tree-node-content"]
    ${mo}    Selenium2Library.Get Text    //tree-node-wrapper/div[contains(@class,"node-content-wrapper-focused")]//span[@id="tree-node-content"]
    [Return]    ${mo}

vDU WebEM Select Cell On Cells Status
    [Arguments]    ${cell_name}
    vDU WebEM Go To By Site Bar Menu    Status    Cells Status
    Wait Until Element Is Visible    //p-card//div[@class="title-row"]//div[text()=" ${cell_name} "]
    Selenium2Library.Click Element    //p-card//div[@class="title-row"]//div[text()=" ${cell_name} "]

Step ${index}: Select One Cell
    Log To Console    Step ${index}: Select One Cell
    vDU WebEM Go To By Site Bar Menu    Status    Site View
    Wait Until Element Is Visible    //vdu-site-view-vdu-cell-tile
    ${cell_count}    Selenium2Library.Get Element Count    //vdu-site-view-vdu-cell-tile
    ${i}    Evaluate    random.randint(1, ${cell_count})    modules=random, sys
    Selenium2Library.Click Element    //vdu-site-view-vdu-cell-tile[${i}]
    ${CELL_NAME}    Selenium2Library.Get Element Attribute    //vdu-site-view-vdu-cell-tile[${i}]/div[@data-vducell-name]    data-vducell-name
    Set Test Variable    ${CELL_NAME}

Step ${index}: Oper The Cell On Site View Via Detail Panel
    Log To Console    Step ${index}: Oper The Cell On Site View Via Detail Panel
    vDU WebEM Select Cell On Site View    ${CELL_NAME}
    vDU WebEM Block Selected Cell Via Detail Panel
    vDU WebEM Select Cell On Site View    ${CELL_NAME}
    vDU WebEM Unblock Selected Cell Via Detail Panel
    ${mo}    vDU WebEM Go To PE Via Detail Panel
    Should Be Equal As Strings    ${mo}    ${CELL_NAME}

Step ${index}: Oper The Cell On Cells Status Via Detail Panel
    Log To Console    Step ${index}: Oper The Cell On Cells Status Via Detail Panel
    vDU WebEM Select Cell On Cells Status    ${CELL_NAME}
    vDU WebEM Block Selected Cell Via Detail Panel
    vDU WebEM Unblock Selected Cell Via Detail Panel
    ${mo}    vDU WebEM Go To PE Via Detail Panel
    Should Be Equal As Strings    ${mo}    ${CELL_NAME}
