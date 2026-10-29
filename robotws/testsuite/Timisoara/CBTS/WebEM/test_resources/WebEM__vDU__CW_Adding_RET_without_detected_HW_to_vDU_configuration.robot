*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan.
    ...  Add one ALD-RET from site view and one from step-by-step view.
    ...  Verify if "No valid radio links 2" is visible.
    ...  Configure all created ALD-RETs with specific parameters.
    ...  Verify parameters name from ALD and RETU.
    ...  Verify if created ALD-RETs and all subunits are highlighted.
    ...  Save plan.
    ...  Delete created ALD-RETs without confirmation.
    ...  Delete created ALD-RETs with confirmation.
    ...  Save plan.
    ...  Delete one existing ALD-RET and verify wrench button. This step run only if at least one RET exist on CBTS.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${PRODUCT_CODE_ALD_RET}  ${EMPTY}  # Mandatory! Product code for created ALDs-RETs.
${SERIAL_NUMBER_ALD_RET}  ${EMPTY}  # Mandatory! Serial number for created ALDs-RETs.


*** Keywords ***
TC__WebEM__vDU__CW_Adding_RET_without_detected_HW_to_vDU_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26526
    ...
    ...  ******************
    ...  - 04.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26526 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-C

    Step1: Open Commissioning Wizard
    Step2: Create Plan
    Step3: Add One ALD-RET From Site View And One From Step-by-step View
    Step4: Configure All Created ALD-RETs
    Step5: Verify If Created ALD-RETs And All Subunits Are Highlighted And Save Plan
    Step6: Delete Created ALD-RETs Without Confirmation
    Step7: Delete Created ALD-RETs With Confirmation And Save Plan
    Step8: Delete One Existing ALD-RET And Verify Wrench Button
    Step9: Delete Created Plan


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard
    ${rmods}  vdu.Get Rmods Status
    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If  ${rmod}[id]==1
        ...  Set Test Variable  ${FIRST_RMOD_NAME}  ${rmod}[product_name]
        ...  ELSE
        ...  Continue For Loop
    END


Step2: Create Plan
    Log  \nStep2: Create plan  console=true
    Create Duplicate Plan For CBTS


Step3: Add One ALD-RET From Site View And One From Step-by-step View
    Log  \nStep3: Add one ALD-RET from site view and one from step-by-step view  console=true
    Log  Adding ALD-RET from site view is performing!  console=true
    Click Element  //*[@id="nolinked-alds"]/div/div[2]/button/span[1]
    Sleep  5s  Time for dropdown to be visible.
    Click Element  //*[@id="laf-component"]/div/ul/li[2]/a/span
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 1
    ...  "No valid radio links 1" is not visible, the first ALD-RET was not added successfully![NOK]
    Log  ALD-RET was added from site view successfully!  console=true
    ${existing_alds}  vdu.Get Alds
    ${existing_alds_number}  Get Length  ${existing_alds}
    ${first_created_ald_id}  Evaluate  ${existing_alds_number} + 1
    Set Test Variable  ${FIRST_CREATED_ALD_ID}
    Log  Adding ALD-RET from step-by-step is performing!  console=true
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RET')]
    Click Element  //*[contains(@class, "step-content")]/blocks-steps-ret-setting/div/div/cem-mod-list/p-panel/div/div//div[2]
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 2
    ...  "No valid radio links 2" is not visible, the second ALD-RET was not added successfully![NOK]
    Log  ALD-RET was added from step-by-step successfully!  console=true
    ${second_created_ald_id}  Evaluate  ${FIRST_CREATED_ALD_ID} + 1
    Set Test Variable  ${SECOND_CREATED_ALD_ID}


Step4: Configure All Created ALD-RETs
    Log  \nStep4: Configure all created ALD-RETs  console=true
    Configure ALD And RETU  ${FIRST_CREATED_ALD_ID}  ${FIRST_RMOD_NAME}  ${PRODUCT_CODE_ALD_RET}  ${SERIAL_NUMBER_ALD_RET}
    Configure ALD And RETU  ${SECOND_CREATED_ALD_ID}  ${FIRST_RMOD_NAME}  ${PRODUCT_CODE_ALD_RET}  ${SERIAL_NUMBER_ALD_RET}
    Element Should Not Be Visible  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span


Step5: Verify If Created ALD-RETs And All Subunits Are Highlighted And Save Plan
    Log  \nStep5: Verify if created ALD-RETs and all subunits are highlighted and save plan  console=true
    Verify If ALD Is Selected And RET Is Highlighted After ALD Button Is Pushed
    Verify If RET Is Selected And Specific RMOD Is Highlighted After RET Button Is Pushed
    Save Plan From Commissioning Wizard
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RET')]


Step6: Delete Created ALD-RETs Without Confirmation
    Log  \nStep6: Delete created ALD-RETs without confirmation  console=true
    Log  Delete the first created ALD-RET from site view without confirmation!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[3]/p-button/button/span[1]
    Click Element  //span[contains(@class, "p-button-label") and contains(text(), 'Cancel')]
    Log  Delete action was canceled for the first created ALD-RET from site view![OK]  console=true
    Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]
    Log  Delete the second created ALD-RET from step-by-step without confirmation!  console=true
    Click Element  //*[contains(@aria-label, 'ALD-${SECOND_CREATED_ALD_ID}')]/span/span/div/div[2]/p-button[2]/button/span[1]
    Click Element  //span[contains(@class, "p-button-label") and contains(text(), 'Cancel')]
    Log  Delete action was canceled for the second created ALD-RET from step-by-step![OK]  console=true
    Element Should Be Visible  //*[contains(@aria-label, 'ALD-${SECOND_CREATED_ALD_ID}')]


Step7: Delete Created ALD-RETs With Confirmation And Save Plan
    Log  \nStep7: Delete created ALD-RETs with confirmation and save plan  console=true
    Log  Delete the first created ALD-RET from site view!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[3]/p-button/button/span[1]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span  90
    Log  Delete action was performing for the first created ALD-RET from site view![OK]  console=true
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]
    Log  Delete the second created ALD-RET from step-by-step!  console=true
    Click Element  //*[contains(@aria-label, 'ALD-${SECOND_CREATED_ALD_ID}')]/span/span/div/div[2]/p-button[2]/button/span[1]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span  90
    Log  Delete action was performing for the second created ALD-RET from step-by-step![OK]  console=true
    Element Should Not Be Visible  //*[contains(@aria-label, 'ALD-${SECOND_CREATED_ALD_ID}')]
    Save Plan From Commissioning Wizard
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RET')]


Step8: Delete One Existing ALD-RET And Verify Wrench Button
    Log  \nStep8: Delete one existing ALD-RET and verify wrench button  console=true
    ${existing_rets}  Get Rets Information
    ${existing_ret_status}  Run Keyword And Return Status
    ...  Should Be Empty  ${existing_rets}
    Run Keyword If  ${existing_ret_status}
    ...  Run Keywords
    ...  Log  No existing RET on vDU, this step is not nedeed!  console=true
    ...  AND
    ...  Return From Keyword
    ${first_ret}  Get From List  ${existing_rets}  0
    ${existing_ret_config}  Set Variable  ${first_ret}[dist_names][config]
    Click Element  //*[@id="${existing_ret_config}/RETU-1"]/div/div[3]/p-button/button/span[1]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span  90  10
    Log  One existing ALD-RET was deleted, verify if wrench option is visible!  console=true
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 1
    ...  "No valid radio links 1" is not visible, the existing ALD-RET was not deleted successfully![NOK]
    Log  Existing ALD-RET was deleted successfully!  console=true
    Click Element  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Element Should Be Visible  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  Wrench button is visible![OK]  console=true
    Click Element  //*[contains(@icon, 'mdi mdi-wrench')]
    Element Should Not Be Visible  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Element Should Be Visible  //*[@id="${existing_ret_config}/RETU-1"]


Step9: Delete Created Plan
    Log  \nStep9: Delete created plan  console=true
    Delete Actual Plan Via WebEM


Verify If ALD Is Selected And RET Is Highlighted After ALD Button Is Pushed
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[4]
    Log  Verify highlighted RET and selected ALD-${FIRST_CREATED_ALD_ID} when the specific ALD is selected from site view!  console=true
    ${ald_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[4]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${ald_class}  selected  ALD-${FIRST_CREATED_ALD_ID} was not selected after the button is pushed![NOK]
    Log  ALD-${FIRST_CREATED_ALD_ID} was selected after the button is pushed![OK]  console=true
    ${retu_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${retu_class}  highlighted  RETU-1 from ALD-${FIRST_CREATED_ALD_ID} was not highlighted after the button is pushed![NOK]
    Log  RETU-1 from ALD-${FIRST_CREATED_ALD_ID} was highlighted after the button is pushed![OK]  console=true
    Log  Verify highlighted RET and selected ALD-${SECOND_CREATED_ALD_ID} when the specific ALD is selected from site view!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${SECOND_CREATED_ALD_ID}/RETU-1"]/div/div[4]
    ${ald_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${SECOND_CREATED_ALD_ID}/RETU-1"]/div/div[4]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${ald_class}  selected  ALD-${SECOND_CREATED_ALD_ID} was not selected after the button is pushed![NOK]
    Log  ALD-${SECOND_CREATED_ALD_ID} was selected after the button is pushed![OK]  console=true
    ${retu_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${SECOND_CREATED_ALD_ID}/RETU-1"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${retu_class}  highlighted  RETU-1 from ALD-${SECOND_CREATED_ALD_ID} was not highlighted after the button is pushed![NOK]
    Log  RETU-1 from ALD-${SECOND_CREATED_ALD_ID} was highlighted after the button is pushed![OK]  console=true


Verify If RET Is Selected And Specific RMOD Is Highlighted After RET Button Is Pushed
    Log  Verify highlighted RMOD and selected RET from ALD-${FIRST_CREATED_ALD_ID} when the RET is selected from site view!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[5]
    ${retu_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/RETU-1"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${retu_class}  selected  RETU-1 from ALD-${FIRST_CREATED_ALD_ID} was not selected after the button is pushed![NOK]
    Log  RETU-1 from ALD-${FIRST_CREATED_ALD_ID} was selected after the button is pushed![OK]  console=true
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${rmod_class}  highlighted  RMOD-1 from ALD-${FIRST_CREATED_ALD_ID} was not highlighted after the button is pushed![NOK]
    Log  RMOD-1 from ALD-${FIRST_CREATED_ALD_ID} was highlighted after the button is pushed![OK]  console=true
    Log  Verify highlighted RMOD and selected RET from ALD-${SECOND_CREATED_ALD_ID} when the RET is selected from site view!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${SECOND_CREATED_ALD_ID}/RETU-1"]/div/div[5]
    ${retu_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${SECOND_CREATED_ALD_ID}/RETU-1"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${retu_class}  selected  RETU-1 from ALD-${SECOND_CREATED_ALD_ID} was not selected after the button is pushed![NOK]
    Log  RETU-1 from ALD-${SECOND_CREATED_ALD_ID} was selected after the button is pushed![OK]  console=true
    ${rmod_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/RMOD-1"]/ot-card  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${rmod_class}  highlighted  RMOD-1 from ALD-${SECOND_CREATED_ALD_ID} was not highlighted after the button is pushed![NOK]
    Log  RMOD-1 from ALD-${SECOND_CREATED_ALD_ID} was highlighted after the button is pushed![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Adding_RET_without_detected_HW_to_vDU_configuration


TC Teardown
    Run Keyword If Test Failed
    ...  Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
