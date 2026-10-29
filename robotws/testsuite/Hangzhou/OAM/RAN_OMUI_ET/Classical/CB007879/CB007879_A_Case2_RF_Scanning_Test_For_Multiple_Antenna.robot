*** Settings ***

Documentation
...   author: ying yingguo
...   contact: yingguo.ying@nokia-sbell.com
...   squad group: BOAM RD OM OMUI EIT
...   Feature CB007879 in 5G_22R4 program



Force Tags        
...    CRT                                         #CI_Phase QT/CIT/CRT
...    RAN_BOAM_UI                                          #Competence Area 
...    5G_RAN                                                #Product
...    SBTS00

Test Timeout      30 minutes

Library           SeleniumLibrary   run_on_failure=NONE
Library           OperatingSystem
Resource          ../Resources/classical_webem.robot


*** Variables ***
${WEBUI_URL}          10.108.237.52
${WEBUI_USER}         Nemuadmin
${WEBUI_PASSWORD}     nemuuser
${RU_TYPE}            AHBCC

*** Test Cases ***
#test case name should be same with qc case name without space and special characters
[1][1.0] CB007879_A_Case2_RF_Scanning_Test_For_Multiple_Antenna
    #current case's final TAG will be CIT
    [Tags]   CA_UTE   CRT   QC_xxx  QCD_MN_RAN  QCP_RAN_ET
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] test
    ...    Test CB007879_A: Case2
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.6.2022  https://***    - Created by yingguo.ying@nokia-sbell.com
    [Setup]   Case Precondition
    Step1 Change BTS R&D Parameter
    Step2 Go to RF Scan Page
    Step3 Select Scan Type Composite Rx And Start
    Step4 Check RF Scan File Should Not Be Empty
    Step5 Select Scan Type Feedback Tx And Start
    Step6 Check RF Scan File Should Not Be Empty
    Step7 Select Scan Type Carrier Rx And Start
    Step8 Check RF Scan File Should Not Be Empty
    [Teardown]  Case Postcondition


*** Keywords ***
Case Precondition
    Open WEBEM and Login
    Check Cell Onair

Step1 Change BTS R&D Parameter
    log to console  Step1: Change BTS R&D Parameter
    Wait Element Visible And Click   ${PROCEDURES}
    Wait Element Visible And Click   xpath=//span[contains(text(),'Change BTS R&D Parameters')]
    _setting R&D parameter    item=Index of SwSystem component:    value=69
    Wait Element Visible And Click   xpath=//span[@title='Select type']
    Wait Element Visible And Click   xpath=//span[text()='Dynamic changes']
    _setting R&D parameter    item=R&D parameters in JSON format:    value=[{"paramIndexNumber":39, "paramValue":1}]
    Wait Element Visible And Click   xpath=//button[text()=' Execute']
    Wait Until Element Is Visible    xpath=//div[contains(text(),'Change BTS R&D parameters completed')]    1min
    [Teardown]    Logout And Close WEBEM

Step2 Go to RF Scan Page
    log to console  Step2: Go to RF Scan Page
    Open WEBEM and Login
    Go to RF Scan Page From Dashboard    ru_type=${RU_TYPE}

Step3 Select Scan Type Composite Rx And Start
    log to console  Step3: Select Scan Type Composite Rx And Start
    Select Scan Type     radios=${RU_TYPE}    capture_type=Composite Rx (HBF0)   antenna=All Antennas
    ${status_file_path}    Save RF Scan File
    set test variable    ${status_file_path}

Step4 Check RF Scan File Should Not Be Empty
    log to console  Step4: Check RF Scan File Should Not Be Empty
    Check File Should Not Be Empty    status_file_path=${status_file_path}

Step5 Select Scan Type Feedback Tx And Start
    log to console  Step5: Select Scan Type Feedback Tx And Start
    Select Scan Type     radios=${RU_TYPE}    capture_type=Feedback Tx (PDRx)   antenna=ANT 1    flag=false
    ${status_file_path}    Save RF Scan File
    set test variable    ${status_file_path}

Step6 Check RF Scan File Should Not Be Empty
    log to console  Step6: Check RF Scan File Should Not Be Empty
    Check File Should Not Be Empty    status_file_path=${status_file_path}

Step7 Select Scan Type Carrier Rx And Start
    log to console  Step7: Select Scan Type Carrier Rx And Start
    Select Scan Type     radios=${RU_TYPE}    capture_type=Carrier Rx (FIR9)   antenna=ANT 1    local_cell=NRCELL-1(53054-01)    flag=false
    ${status_file_path}    Save RF Scan File
    set test variable    ${status_file_path}

Step8 Check RF Scan File Should Not Be Empty
    log to console  Step8: Check RF Scan File Should Not Be Empty
    Check File Should Not Be Empty    status_file_path=${status_file_path}

Case Postcondition
    log to console  \n Case Postcondition
    [Teardown]    Logout And Close WEBEM

_setting R&D parameter
    [Arguments]     ${item}=Index of SwSystem component:    ${value}=69
    Wait Element Visible And Click   //span[contains(text(),'${item}')]/parent::div/following-sibling::div[@class='input']/ui-text-input/div/input
    wait until keyword succeeds    1min   10s     SeleniumLibrary.Input Text
    ...    xpath=//span[contains(text(),'${item}')]/parent::div/following-sibling::div[@class='input']/ui-text-input/div/input    ${value}