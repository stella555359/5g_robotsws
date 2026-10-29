*** Settings ***
Documentation
    ...  This TC is created to add a new RAN NIC module to vDU configuration.
    ...  Commissioning Wizard is opened.
    ...  Delta plan is created.
    ...  RAN NIC module is added.
    ...  SFP and LANE are added to RAN NIC.
    ...  Plan is saved and then deleted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26715
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26715 - Initial TAT creation
    ...  ******************
    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-B

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Add RAN NIC Module To VDU Configuration
    Step3: Add SFP To RAN NIC Module
    Step4: Add LANE To SFP Module


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    ${rnic_info}  Get Rnic Info From Plan  ${VDU_MRBTS_ID}
    ${no_of_rnics}  Get Length  ${rnic_info}
    ${rnic_id}  Evaluate  ${no_of_rnics} + 1
    Set Test Variable  ${RNIC_ID}
    Set Test Variable  ${RNIC_SN}  ${rnic_info}[0][serial_number]


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard
    Create Duplicate Plan For CBTS


Step2: Add RAN NIC Module To VDU Configuration
    Log  \nStep2: Add RAN NIC Module to vDU configuration.  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RAN NIC Module Settings')]
    Click Element  //*[contains(@class,'p-ripple p-element p-button-text p-button-sm p-button-neutral p-button p-component p-button-icon-only')]
    ${rnic_name}  Get Text  //*[@id="laf-component"]/div/ul/li[1]/a/span
    ${rnic_type}  Fetch From Left  ${rnic_name}  ${SPACE}
    Click Element  //*[@id="laf-component"]/div/ul/li[1]/a/span
    Click Element  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  ${rnic_type} RNICMOD-${RNIC_ID}
    Click Element  //*[contains(text(),'${rnic_type} RNICMOD-${RNIC_ID}')]
    Verify Parameters Names For RAN NIC Module
    Input Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-string-input/ot-field/div/input  ${RNIC_SN}
    Log  RAN NIC Module added successfully. [OK]  console=true


Step3: Add SFP To RAN NIC Module
    Log  \nStep3: Add SFP to RAN NIC Module.  console=true
    Click Element  //*[contains(@class,'flex justify-content-between align-items-center ng-star-inserted')]/div[2]/p-button[2]/button
    Wait Until Element Is Clicked  //*[contains(text(),'SFP-1')]  10  2
    ${hw_port_id_locator}  Catenate  SEPARATOR=  //*[contains(@class,'p-treetable-scrollable-body ng-star-inserted')]/table/tbody
    ...  /tr[1]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Click Element  ${hw_port_id_locator}
    Wait Until Element Is Clicked  //*[contains(@aria-label,'Q_RF1')]  10  2
    Log  SPF added successfully to RAN NIC Module. [OK]  console=true


Step4: Add LANE To SFP Module
    Log  \nStep4: Add LANE to SFP Module.  console=true
    Click Element  //*[contains(@aria-label,'SFP-1')]/span/span/div/div[2]/p-button[1]/button
    Click Element  //*[contains(text(),'LANE-1 Unlocked')]
    Log  LANE added successfully to SFP Module. [OK]  console=true
    Save Plan From Commissioning Wizard
    Delete Actual Plan Via WebEM


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Add_a_RANNIC_module_QSFP_and_LANE


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
