*** Settings ***
Documentation
...   author: cao miao
...   contact: miao.a.cao@nokia-sbell.com
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
${WEBUI_URL}        10.108.237.51
${WEBUI_USER}         Nemuadmin
${WEBUI_PASSWORD}     nemuuser

*** Test Cases ***
#test case name should be same with qc case name without space and special characters.
[1][1.0] CB007879_A_Case1_RF_Scanning_Test_For_Single_Antenna
    #current case's final TAG will be CIT
    [Tags]   CA_UTE   CRT   QC_  QCD_MN_RAN  QCP_RAN_ET
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] test
    ...    Test 7879-A: Case1
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.06.2022  https://***    - Created by miao.a.cao@nokia-sbell.com
    [Setup]   Case Precondition
    Step1 PIM Simulation Via Webem
    Step2 Go to RF Scan Page
    Step3 Excute RF Scan For ANT1
    Step4 Excute RF Scan for ANT2
    [Teardown]  Case Postcondition

*** Keywords ***
Case Precondition
    Open WEBEM and Login
    Check Cell Onair
    
Case Postcondition
    log to console  \n Case Postcondition
    [Teardown]    Logout And Close WEBEM

Step1 PIM Simulation Via Webem
    log to console  Step1: Check Export Function
    Wait Element Visible And Click   //span[text()='Diagnostic']
    Wait Element Visible And Click   //span[contains(text(),'RF Monitoring')]
    #Wait Element Visible And Click   //button[contains(text(),' Export Data for PIM Simulation')]
    ${file_path}   _export data for PIM simulation
    ${size}=  get file size  ${file_path}
    should be true  ${size} > 500

Step2 Go to RF Scan Page
    log to console  Step2: Go to RF Scan Page
    Wait Element Visible And Click   //wf-tabs[@class="rf-monitoring-tabs ng-isolate-scope"]/ul/li[3]
    Wait Element Visible And Click   //input[@value='NR']

Step3 Excute RF Scan For ANT1
    log to console  Step3: Excute RF Scan for ANT1
    Select Scan Type   radios=AHCA  capture_type=Composite Rx (HBF0)   antenna=ANT 1
    ${status_file_path}    Save RF Scan File
    Check File Should Not Be Empty    status_file_path=${status_file_path}
    
Step4 Excute RF Scan for ANT2
    log to console  Step4: Excute RF Scan for ANT2
    Select Scan Type   radios=AHCA  capture_type=Carrier Rx (FIR9)   antenna=ANT 2   local_cell=NRCELL-1  flag=false
    ${status_file_path}    Save RF Scan File
    Check File Should Not Be Empty    status_file_path=${status_file_path}
    [Teardown]    Logout And Close WEBEM

_export data for PIM simulation
    run keyword and ignore error   RUN  rm /tmp/RFMonitoring_Classical-5g-*_simulation*
    Wait Element Visible And Click   //button[contains(text(),' Export Data for PIM Simulation')]
    sleep   3s
    ${status_file}  RUN    cd /tmp; ls|grep RFMonitoring_Classical-5g-*_simulation*
    ${status_file_path}  OperatingSystem.Join Path   /tmp/${status_file}
    [Return]    ${status_file_path}
    