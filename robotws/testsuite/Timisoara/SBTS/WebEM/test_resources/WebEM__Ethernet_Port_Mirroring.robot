*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case is sending several mirror groups from Ethernet Port Mirroring page.
    ...  Step1: Ethernet Port Mirroring page is opened.
    ...  Step2:
    ...  - send mirror group with: Direction=Ingress, Source=Internal Port, Destination=${SMOD_TYPE}_EIF3
    ...  - send invalid mirror group by not choosing the destination
    ...  - check if EIF3 for SMOD is disabled as source after the mirror group was created as follows:
    ...  Direction=Ingress, Source=Internal Port, Destination=${SMOD_TYPE}_EIF3
    ...  - check if EIF3 cannot be the source and the destination at the same time
    ...  - check if after sending 2 mirror groups with the same direction and the same source port, this message appears:
    ...  'The same direction for each source port should not be used in different mirror group'.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Ethernet_Port_Mirroring
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24464
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 11.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24464 - Initial TAT creation
    ...  - 29.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-25744 - Modification of the response received at Send Mirror Group
    ...  - 24.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27167 - Changes for TC
    ...  - 26.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27635 - Close tab if visible

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-LTE5113

    Step0: Set SMOD Type
    Step1: Open Ethernet Port Mirroring Page
    Step2: Send Mirror Groups
    Step3: Check ETHMIRROR-1 Error In Parameter Editor
    Step4: Change Parameter ActEAPMode Value To EAP Disabled And Check Error Is Cleared
    Step5: Clear Mirror Groups And Close Ethernet Port Mirroring Page


Step0: Set SMOD Type
    ${smod_ids}  Get Ids For All  SMOD
    ${smod_parameters}  Get Parameters For  SMOD  ${smod_ids}[0]
    ${hardware_type}  Fetch From Left  ${smod_parameters}[productName]  ${SPACE}
    Set Test Variable  ${SMOD_TYPE}  ${hardware_type}


Step1: Open Ethernet Port Mirroring Page
    Log  \nStep1: Open Ethernet Port Mirroring Page  console=true
    Open Ethernet Port Mirroring
    Enable Ethernet Port Mirroring


Step2: Send Mirror Groups
    Log  \nStep2: Send Mirror Groups  console=true
    Send Mirror Group  received_response=Ethernet port mirroring configuration change completed.  direction=Ingress
    Try To Send An Invalid Mirror Group Without Selecting The Destination
    Clear Mirror Groups List
    Check EIF3 For SMOD To Be Disabled As Source After Creating One Mirror Group
    Check If EIF3 For SMOD Cannot Be Source And Destination At The Same Time
    Check If Source Ports Are Enabled/Disabled
    Send Mirror Group  received_response=Ethernet port mirroring configuration change completed.  direction=Ingress
    Send Mirror Group  received_response=Ethernet port mirroring configuration change completed.  direction=Egress
    Configure Same Direction In Mirror Groups  received_response=The same direction for each source port should not be used in different mirror group
    ...  direction=Egress


Step3: Check ETHMIRROR-1 Error In Parameter Editor
    Log  \nStep3: Check ETHMIRROR-1 Error In Parameter Editor  console=true
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90
    Click Element  //*[contains(@a-title, 'Validate Plan')]
    Wait Until Element Is Visible  locator=//div[@ng-if="tab.aErrorCount"]  timeout=60s
    Wait Until Element Is Clicked  //*[contains(text(), "Relation Errors")]  60
    Wait Until Element Is Visible  locator=//*[contains(text(), 'Parameter validation errors')]  timeout=40s
    ${error_xpath}  Catenate  SEPARATOR=  //*[@class='ui-view-panel-body']
    ...  /div/ui-view-panel-body/validation-result/div[2]/div/div[2]/div/
    ...  parameter-validation-errors/ui-table/div/ng-transclude/table/tbody/tr
    ${error_description}  Get Text  ${error_xpath}
    ${error}  Catenate  SEPARATOR=${SPACE}  Error MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/ETHSVC-1/ETHMIRROR-1 Whenever ETHMIRROR-1 having
    ...  ETHMIRROR-1.portMirroringEnabled (value: true) equal to true, it is required that embedded assertion valid (Namely: It is required that
    ...  FEATCADM.actEAPMode equal to EAP disabled)
    Should Be Equal  ${error_description}  ${error}  msg=Error is unexpected!
    Log  \nError ETHMIRROR-1.portMirroringEnabled appears in Parameter Editor.  console=true


Step4: Change Parameter ActEAPMode Value To EAP Disabled And Check Error Is Cleared
    Log  \nStep4: Change parameter actEAPMode value to EAP disabled and check error is cleared  console=true
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actEAPMode  operation=update
    ...  value=EAP disabled  skip_parameter_relation_errors=true  timeout=600
    Close Startup View If Visible  timeout=300 sec
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90
    Click Element  //*[contains(@a-title, 'Validate Plan')]
    Wait Until Element Is Clicked  //div[contains(text(), "Relation Errors")]  60
    Wait Until Element Is Visible  locator=//div[contains(text(), " Parameter relation validation succeeded")]  timeout=60s
    Log  \nError ETHMIRROR-1.portMirroringEnabled is cleared in Parameter Editor.  console=true


Step5: Clear Mirror Groups And Close Ethernet Port Mirroring Page
    Log  \nStep5: Clear Mirror Groups and Close Ethernet Port Mirroring Page  console=true
    Open Ethernet Port Mirroring
    Close Startup View If Visible  timeout=300 sec
    Clear Mirror Groups List
    Click Element  locator=//span[contains(text(),'Enable Ethernet port mirroring')]
    Click Element  locator=//button[contains(text(),'Send')]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Ethernet port mirroring configuration change completed.')]  timeout=60
    Log  \nPort mirroring is disabled.  console=true


Enable Ethernet Port Mirroring
    Click Element  locator=//span[contains(text(),'Enable Ethernet port mirroring')]


Send Mirror Group
    [Arguments]  ${received_response}  ${direction}

    Click Element  locator=//button[contains(text(),'Add Mirror Group')]
    Click Element  locator=//label[contains(text(),'${direction}')]
    Click Element  locator=//span[contains(text(),'Internal port')]
    Click Element  locator=//button[@ng-class="$ctrl.dropdownButtonClassStr"]
    Click Element  locator=//wf-dropdown-item//span[contains(text(),'${SMOD_TYPE}_EIF3')]
    Click Element  locator=//button[contains(text(),'Send')]
    Wait Until Element Is Visible  locator=//span[contains(text(),"${received_response}")]  timeout=120


Try To Send An Invalid Mirror Group Without Selecting The Destination
    Click Element  locator=//button[contains(text(),'Add Mirror Group')]
    Element Should Be Visible  locator=//button[@disabled="disabled" and contains(text(),'Send')]
    Click Element  locator=//span[contains(text(),'Internal port')]
    Element Should Be Visible  //button[@disabled="disabled" and contains(text(),'Send')]


Clear Mirror Groups List
    Click Element  locator=//wf-list-item[2]//li//ng-transclude//ui-button[@a-icon="trash"]
    Click Element  locator=//wf-list-item[1]//li//ng-transclude//ui-button[@a-icon="trash"]
    Click Element  locator=//button[contains(text(),'Send')]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Ethernet port mirroring configuration change completed.')]  timeout=60


Check EIF3 For SMOD To Be Disabled As Source After Creating One Mirror Group
    Click Element  locator=//button[contains(text(),'Add Mirror Group')]
    Click Element  locator=//span[contains(text(),'Internal port')]
    Click Element  locator=//button[@ng-class="$ctrl.dropdownButtonClassStr"]
    Click Element  locator=//wf-dropdown-item//span[contains(text(),'${SMOD_TYPE}_EIF3')]
    Element Should Be Disabled  locator=//li[1]//*//input[@disabled="disabled"]
    Click Element  locator=//wf-list-item[1]//li//ng-transclude//ui-button[@a-icon="trash"]


Check If EIF3 For SMOD Cannot Be Source And Destination At The Same Time
    Click Element  locator=//button[contains(text(),'Add Mirror Group')]
    Click Element  locator=//span[contains(text(),'${SMOD_TYPE}_EIF3')]
    Click Element  locator=//button[@ng-class="$ctrl.dropdownButtonClassStr"]
    Element Should Be Visible  locator=//wf-dropdown-item//a[@disabled="disabled"]//span[contains(text(),'${SMOD_TYPE}_EIF3')]
    Click Element  locator=//wf-list-item[1]//li//ng-transclude//ui-button[@a-icon="trash"]


Check If Source Ports Are Enabled/Disabled
    Click Element  locator=//button[contains(text(),'Add Mirror Group')]
    Click Element  locator=//span[contains(text(),'${SMOD_TYPE}_EIF1')]
    Element Should Be Disabled  locator=//div[2]//*//li[3]//*//input[@disabled="disabled"]
    Click Element  locator=//span[contains(text(),'${SMOD_TYPE}_EIF1')]
    Click Element  locator=//span[contains(text(),'Internal port')]
    Element Should Be Disabled  //div[2]//*//li[1]//*//input[@disabled="disabled"]
    Click Element  locator=//wf-list-item[1]//li//ng-transclude//ui-button[@a-icon="trash"]


Configure Same Direction In Mirror Groups
    [Arguments]  ${received_response}  ${direction}

    Wait Until Element Is Clicked  //span[contains(text(),'Mirror group 1')]
    Click Element  locator=//label[contains(text(),'${direction}')]
    Wait Until Element Is Clicked  //button[contains(text(),' Send')]  60
    Wait Until Element Is Visible  locator=//span[contains(text(),"${received_response}")]  timeout=60


TC Setup
    Common Test Setup  tc_name=WebEM__Ethernet_Port_Mirroring
    WebEM Setup


TC Teardown
    Perform Parameter Recommissioning  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1  parameter=actEAPMode  operation=update
    ...  value=Authenticator initiated mode  skip_parameter_relation_errors=true  timeout=600
    WebEM Teardown
    Common Test Teardown
