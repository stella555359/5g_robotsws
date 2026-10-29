*** Settings ***
Documentation
    ...  This TC is created to verify if RAN NIC Module can be modified.
    ...  Commissioning Wizard is opened.
    ...  Delta plan is created.
    ...  RAN NIC Module type and parameters are modified.
    ...  SFP is opened and LANE parameter is modified.
    ...  Plan is saved and then Delta Plan is deleted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Modify_Update_RANNIC_Update_QSFP_and_LANE_in_step_by_step_view
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26716
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26716 - Initial TAT creation
    ...  29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29026 - Some xpaths were changed
    ...  ******************
    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-B

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Change RAN NIC Module Type And Verify Parameters Names
    Step3: Verify That RAN NIC Parameters Can Be Changed
    Step4: Open RAN NIC SPF And Change LANE Parameter


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    ${rnic_info}  Get Rnic Info From Plan  ${VDU_MRBTS_ID}
    ${rnic_r_dn}  Set Variable  ${rnic_info}[0][r_nic_mod_dist_name]
    ${rnic_r}  Fetch From Right  ${rnic_r_dn}  /
    ${rnic_dn}  Remove String Using Regexp  ${rnic_r_dn}  _R
    ${rnic}  Fetch From Right  ${rnic_dn}  /
    Set Test Variable  ${RNIC_DN}
    Set Test Variable  ${RNIC_R}
    Set Test Variable  ${RNIC}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard
    Create Duplicate Plan For CBTS


Step2: Change RAN NIC Module Type And Verify Parameters Names
    Log  \nStep2: Change RAN NIC Module type and verify parameters names.  console=true
    ${rnic_type}  Get Text  //*[@id="${RNIC_DN}"]/cem-common-widget/ot-card/p-card/div/div/div/div/div/div[2]
    ${rnic_full_name}  Catenate  ${rnic_type}  ${RNIC}
    Set Test Variable  ${RNIC_FULL_NAME}
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RAN NIC Module Settings')]
    Click Element  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ${RNIC_FULL_NAME}
    Wait Until Element Is Clicked  //*[contains(text(),'${RNIC_FULL_NAME}')]
    Wait Until Element Is Clicked  //div[contains(@aria-label,'${RNIC_FULL_NAME}')]/span/span/div/div[2]/p-button[1]/button/span[1]
    ${new_type}  Get Text  //*[@id="laf-component"]/div/ul/li[1]/a/span
    ${new_type}  Fetch From Left  ${new_type}  ${SPACE}
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ${new_type}${SPACE}${RNIC}
    Wait Until Element Is Visible  //*[contains(text(),'${new_type}${SPACE}${RNIC}')]  30
    Wait Until Element Is Clicked  //div[contains(@aria-label,'${new_type}${SPACE}${RNIC}')]/span/span/div/div[2]/p-button[1]/button/span[1]
    Wait Until Element Is Clicked  //li[contains(@aria-label, '${rnic_type}')]
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ${RNIC_FULL_NAME}
    Wait Until Element Is Clicked  //*[contains(text(),'${RNIC_FULL_NAME}')]
    Log  RAN NIC type changed and brought back to initial value. [OK]  console=true
    Verify Parameters Names For RAN NIC Module


Step3: Verify That RAN NIC Parameters Can Be Changed
    Log  \nStep3: Verify that RAN NIC parameters can be changed.  console=true
    ${adm_state_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-treetable-scrollable-body ng-star-inserted')]/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${adm_state_locator}
    Wait Until Element Is Clicked  //li[contains(@aria-label,'Locked')]  20  2
    Sleep  30s  Wait for administrative state button to activate
    Click Element  ${adm_state_locator}
    Wait Until Element Is Clicked  //li[contains(@aria-label,'Unlocked')]  20  2
    ${sn_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-treetable-scrollable-body ng-star-inserted')]/table/tbody/tr[3]/td[2]
    ...  /cem-parameter-input/cem-string-input/ot-field/div/input
    Input Text  ${sn_locator}  TEST
    Log  All parameters can be changed. [OK]  console=true


Step4: Open RAN NIC SPF And Change LANE Parameter
    Log  \nStep4: Open RAN NIC SPF and change LANE parameter.  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label,'${RNIC_FULL_NAME}')]/button/span
    Wait Until Element Is Clicked  //*[contains(@aria-label,'SFP-1')]/span/span/div/div[2]/p-button[1]/button
    Wait Until Element Is Clicked  //*[contains(text(),'LANE-1 Unlocked')]  10  2
    Log  Change administrative state...  console=true
    ${adm_state_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-treetable-scrollable-body ng-star-inserted')]/table/tbody/tr[1]/td[2]
    ...  /cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Wait Until Element Is Clicked  ${adm_state_locator}
    Sleep  5s  Time for page to be uploaded
    Wait Until Element Is Clicked  //li[contains(@aria-label,'Locked')]  20  2
    Sleep  5s  Time for page to be uploaded
    Wait Until Element Is Clicked  ${adm_state_locator}
    Sleep  5s  Time for page to be uploaded
    Wait Until Element Is Clicked  //li[contains(@aria-label,'Unlocked')]
    Sleep  5s  Time for page to be uploaded
    Save Plan From Commissioning Wizard


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Modify_Update_RANNIC_Update_QSFP_and_LANE_in_step_by_step_view


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
