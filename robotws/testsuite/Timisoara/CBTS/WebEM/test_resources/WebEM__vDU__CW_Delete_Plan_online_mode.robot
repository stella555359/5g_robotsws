*** Settings ***
Documentation
    ...  This TC is created to verify if delta plan is created and delete it.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Delete_Plan_online_mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26702
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  10.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26702 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-E

    Step1: Open Commissioning Wizard
    Step2: Verify If Delta Plan Is Created And Delete It


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Verify If Delta Plan Is Created And Delete It
    Log  \nStep2: Verify if delta plan is created and delete it.  console=true
    Wait Until Element Is Clicked  //*[contains(@class,'dropdown-container ng-star-inserted')]
    ${status}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[contains(text(),'DELTA-PLAN-1')]
    Run Keyword If  ${status}
    ...  Log  Delta plan already created. [OK]  console=true
    ...  ELSE
    ...  Create Delta Plan For CBTS
    Wait Until Element Is Clicked  //*[contains(text(),'Delete Plan')]
    Wait Until Keyword Succeeds  30s  2s
    ...  Element Should Be Visible  //*[contains(text(),'Do you want to delete plan DELTA-PLAN-1?')]
    Click Element  //*[@id="webem-parameter-editor-menu-dialog"]/div/div/div[3]/button[2]
    Wait Until Element Is Clicked  //*[contains(@class,'dropdown-container ng-star-inserted')]
    Element Should Not Be Visible  //*[contains(text(),'DELTA-PLAN-1')]
    Log  Delta plan was deleted successfully.  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Delete_Plan_online_mode


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
