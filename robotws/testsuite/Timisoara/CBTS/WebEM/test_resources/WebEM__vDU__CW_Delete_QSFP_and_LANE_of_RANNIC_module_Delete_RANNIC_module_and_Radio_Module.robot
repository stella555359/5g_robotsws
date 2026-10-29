*** Settings ***
Documentation
    ...  This TC is created to delete RAN NIC and Radio Module.
    ...  Commissioning Wizard is opened.
    ...  Delta plan is created.
    ...  LANE from the first SFP is deleted.
    ...  SFP is deleted.
    ...  RAN NIC is deleted, if cablink is attached to it, a confirmation message will appear.
    ...  Cablink is also deleted.
    ...  Plan is saved and then Radio Module is deleted.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26717
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26717 - Initial TAT creation
    ...  29.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29026 - Some xpaths were changed
    ...  ******************
    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-anna.benzar@nokia.com  MAINTAINER-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  FEATURE-CB005866-B

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Delete LANE Of RAN NIC SFP
    Step3: Delete SFP Of RAN NIC
    Step4: Delete RAN NIC
    Step5: Delete Radio Module Without Checkbox Selected And Verify Nrcells And Nrcell-group
    Step6: Delete Radio Module With Checkbox Selected And Verify Nrcells And Nrcell-group


Step0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true
    Set Nr Cell Id And Nrcell Group Id Depends On First RMOD
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


Step2: Delete LANE Of RAN NIC SFP
    Log  \nStep2: Delete LANE of RAN NIC SFP  console=true
    ${rnic_type}  Get Text  //*[@id="${RNIC_DN}"]/cem-common-widget/ot-card/p-card/div/div/div/div/div/div[2]
    ${rnic_full_name}  Catenate  ${rnic_type}  ${RNIC}
    Set Test Variable  ${RNIC_FULL_NAME}
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RAN NIC Module Settings')]  10  2
    ${rnic_locator}  Catenate  SEPARATOR=  //div[contains(@aria-label,'${RNIC_FULL_NAME}')]/button
    Wait Until Element Is Clicked  ${rnic_locator}  10  2
    Wait Until Element Is Clicked  //*[contains(@aria-label,'SFP-1')]/span/span/div/div[2]/p-button[1]/button  10  2
    Wait Until Element Is Clicked  //*[contains(@aria-label,'LANE-1 Unlocked')]/span/span/div/div[2]/p-button/button/span[1]  10  2
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Not Contain  LANE-1 Unlocked
    Log  LANE is deleted successfully. [OK]  console=true


Step3: Delete SFP Of RAN NIC
    Log  \nStep3: Delete SFP of RAN NIC.  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label,'SFP-1')]//span/span/div/div[2]/p-button[2]/button/span[1]  10  2
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Not Contain  SFP-1
    Log  SFP deleted succesfully. [OK]  console=true


Step4: Delete RAN NIC
    Log  \nStep4: Delete RAN NIC.  console=true
    ${rnic_delete_button}  Catenate  SEPARATOR=  //*[contains(@aria-label,'${RNIC_FULL_NAME}')]/span/span/div/div[2]/p-button[3]/button/span[1]
    Wait Until Element Is Clicked  ${rnic_delete_button}  10  2
    Sleep  2s  Sleep for pop-up message to appear
    ${message_status}  Run Keyword And Return Status
    ...  Page Should Contain  And related CABLINK(s) also will be deleted.
    Run Keyword If  ${message_status}
    ...  Click Element  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Not Contain  ${RNIC_FULL_NAME}
    Log  RAN NIC deleted succesfully. [OK]  console=true
    Save Plan From Commissioning Wizard
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Module Link Settings')]  10  2
    Wait Until Keyword Succeeds  10  2
    ...  Page Should Contain  There is no valid RAN NIC module existing.


Step5: Delete Radio Module Without Checkbox Selected And Verify Nrcells And Nrcell-group
    Log  \nStep5: Delete Radio Module without checkbox selected and verify nrcells and nrcell-group.  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Radio Module was deleted!  console=true
    Log  Verify if cell is not still visible!  console=true
    ${cell_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELL-${CELL_ID}
    Run Keyword If  ${cell_status}
    ...  Log  NRCELL-${CELL_ID} on RMOD-1 is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELL-${CELL_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if nr group cell is still visible!  console=true
    ${group_status}  Run Keyword And Return Status
    ...  Page Should Contain  NRCELLGRP-${CELL_GROUP_ID}
    Run Keyword If  ${group_status}
    ...  Log  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is still visible![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is not visible anymore![NOK]
    Delete Actual Plan Via WebEM
    Create Duplicate Plan For CBTS


Step6: Delete Radio Module With Checkbox Selected And Verify Nrcells And Nrcell-group
    Log  Step6: Delete Radio Module With Checkbox Selected And Verify Nrcells And Nrcell-group  console=true
    Wait Until Element Is Clicked
    ...  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card/p-card/div/div/div/div/div[1]/div[1]/div[2]/p-button[2]/button/span[1]
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Do you want to delete
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain  Delete related cell(s) and cell group(s)
    Click Element  //*[@id="laf-component"]/div/div/div[2]/blocks-delete-check-dialog/div[2]/div/p-checkbox/div/div[2]
    Log  Checkbox was selected!  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button/span
    Log  Radio Module was deleted!  console=true
    Log  Verify if cell is not still visible!  console=true
    ${cell_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELL-${CELL_ID}
    Run Keyword If  ${cell_status}
    ...  Log  NRCELL-${CELL_ID} on RMOD-1 is not visible anymore![OK]  console=true
    ...  ELSE
    ...  Fail  NRCELL-${CELL_ID} on RMOD-1 is still visible![NOK]
    Log  Verify if nr group cell is not still visible!  console=true
    ${group_status}  Run Keyword And Return Status
    ...  Page Should Not Contain  NRCELLGRP-${CELL_GROUP_ID}
    Run Keyword If  ${group_status}
    ...  Log  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is not visible anymore[OK]  console=true
    ...  ELSE
    ...  Fail  NRCELLGRP-${CELL_GROUP_ID} on RMOD-1 is still visible![NOK]


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Delete_QSFP_and_LANE_of_RANNIC_module_Delete_RANNIC_module_and_Radio_Module


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
