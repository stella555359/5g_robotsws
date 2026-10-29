*** Settings ***
Documentation
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Create a plan as a duplicate plan.
    ...  Add one ALD-MHA, type Nokia, from site view and one from step-by-step view.
    ...  Configure all created MHAs and LNAs with specific values and verify if all parameters are visible on page.
    ...  Verify if created MHA is in selected style when the button is pushed, and the specific LNAs are highlighted.
    ...  Verify if created LNA is in selected style when the button is pushed.
    ...  Save plan.
    ...  Delete all created MHAs without confirmation.
    ...  Delete all created MHAs with confirmation and save plan.
    ...  Delete one existing MHA, if exists, and verify wrench button. This step run only if at least one MHA exist on CBTS.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${PRODUCT_CODE_ALD_MHA}  ${EMPTY}  # Mandatory! Product code for created ALDs-MHAs.
${SERIAL_NUMBER_ALD_MHA}  ${EMPTY}  # Mandatory! Serial number for created ALDs-MHAs.


*** Keywords ***
TC__WebEM__vDU__CW_Adding_MHA_without_detected_HW_to_vDU_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26525
    ...
    ...  ******************
    ...  - 29.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26525 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-C

    Step0: TC Preconditions
    Step1: Open Commissioning Wizard
    Step2: Create A Duplicate Plan
    Step3: Add One ALD-MHA From Site View And One From Step-by-step View
    Step4: Configure All Created ALD-MHAs
    Step5: Verify If Created ALD-MHAs And All Subunits Are Highlighted And Save Plan
    Step6: Delete Created ALD-MHAs Without Confirmation
    Step7: Delete Created ALD-MHAs With Confirmation And Save Plan
    Step8: Delete One Existing ALD-MHA And Verify Wrench Button


Step0: TC Preconditions
    Should Not Be Empty  ${PRODUCT_CODE_ALD_MHA}  Product code for created MHA must be specified, please provide it and retest.
    Should Not Be Empty  ${SERIAL_NUMBER_ALD_MHA}  Serial number for created MHA must be specified, please provide it and retest.
    ${rmods}  vdu.Get Rmods Status
    FOR  ${rmod}  IN  @{rmods}
        Run Keyword If  ${rmod}[id]==1
        ...  Set Test Variable  ${FIRST_RMOD_NAME}  ${rmod}[product_name]
        ...  ELSE
        ...  Continue For Loop
    END
    ${existing_alds}  vdu.Get Alds
    ${existing_alds_number}  Get Length  ${existing_alds}
    ${first_created_ald_id}  Evaluate  ${existing_alds_number} + 1
    Set Test Variable  ${FIRST_CREATED_ALD_ID}
    ${second_created_ald_id}  Evaluate  ${FIRST_CREATED_ALD_ID} + 1
    Set Test Variable  ${SECOND_CREATED_ALD_ID}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create A Duplicate Plan
    Log  \nStep2: Create a dupicate plan  console=true
    Create Plan With Duplicate Checkbox


Step3: Add One ALD-MHA From Site View And One From Step-by-step View
    Log  \nStep3: Add one ALD-MHA from site view and one from step-by-step view  console=true
    Log  Adding ALD-MHA from site view is performing!  console=true
    Wait Until Element Is Clicked  //*[@id="nolinked-alds"]/div/div[2]/button/span[1]  10  2
    Wait Until Keyword Succeeds  10s  2s
    ...  Mouse Over  //*[@id="laf-component"]/div/ul/li[1]/a/span[2]
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Nokia')]  10  2
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 2
    ...  "No valid radio links 2" is not visible, the first ALD-MHA was not added successfully![NOK]
    Log  ALD-MHA was added from site view successfully!  console=true
    Log  Adding ALD-MHA from step-by-step is performing!  console=true
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices MHA')]
    Click Element  //*[contains(@class,'mdi mdi-plus-thick p-button-icon ng-star-inserted')]
    Scroll Element Into View  //span[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Nokia')]
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text ng-star-inserted') and contains(text(), 'Nokia')]  10  2
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 4  "No valid radio links 4" is not visible, ALD-MHA was not added successfully![NOK]
    Log  ALD-MHA was added from step-by-step successfully!  console=true


Step4: Configure All Created ALD-MHAs
    Log  \nStep4: Configure all created ALD-MHAs  console=true
    Configure MHA And LNAs  ${FIRST_CREATED_ALD_ID}  ${FIRST_RMOD_NAME}
    Configure MHA And LNAs  ${SECOND_CREATED_ALD_ID}  ${FIRST_RMOD_NAME}
    Save Plan From Commissioning Wizard
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  60s  10s
    ...  Click element  //span[contains(@class, 'p-button-label') and contains(text(), 'Continue')]
    Element Should Not Be Visible  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span


Step5: Verify If Created ALD-MHAs And All Subunits Are Highlighted And Save Plan
    Log  \nStep5: Verify if created ALD-MHAs and all subunits are highlighted and save plan  console=true
    Log  Verify highlighted LNAs and selected ALD-${FIRST_CREATED_ALD_ID} when the specific ALD is selected from site view!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/LNA-1"]/div/div[4]
    Verify Highlighted And Selected Objects After Specific ALD Button Was Pushed  ${FIRST_CREATED_ALD_ID}
    Log  Verify highlighted LNAs and selected ALD-${SECOND_CREATED_ALD_ID} when the specific ALD is selected from site view!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${SECOND_CREATED_ALD_ID}/LNA-1"]/div/div[4]
    Verify Highlighted And Selected Objects After Specific ALD Button Was Pushed  ${SECOND_CREATED_ALD_ID}
    Verify If LNA Is Selected After LAN Button Is Pushed  ${FIRST_CREATED_ALD_ID}  1
    Verify If LNA Is Selected After LAN Button Is Pushed  ${FIRST_CREATED_ALD_ID}  2
    Verify If LNA Is Selected After LAN Button Is Pushed  ${SECOND_CREATED_ALD_ID}  1
    Verify If LNA Is Selected After LAN Button Is Pushed  ${SECOND_CREATED_ALD_ID}  2
    Save Plan From Commissioning Wizard
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices MHA')]


Step6: Delete Created ALD-MHAs Without Confirmation
    Log  \nStep6: Delete created ALD-MHAs without confirmation  console=true
    Delete LNAs From Site View Without Confirmation  ${FIRST_CREATED_ALD_ID}  1
    Delete LNAs From Site View Without Confirmation  ${FIRST_CREATED_ALD_ID}  2
    Delete LNAs From Site View Without Confirmation  ${SECOND_CREATED_ALD_ID}  1
    Delete LNAs From Site View Without Confirmation  ${SECOND_CREATED_ALD_ID}  2
    Delete MHAs From Step By Step Without Confirmation  ${FIRST_CREATED_ALD_ID}
    Delete MHAs From Step By Step Without Confirmation  ${SECOND_CREATED_ALD_ID}


Step7: Delete Created ALD-MHAs With Confirmation And Save Plan
    Log  \nStep7: Delete created ALD-MHAs with confirmation and save plan  console=true
    Log  Delete the first created ALD-${FIRST_CREATED_ALD_ID} from site view!  console=true
    Wait Until Element Is Clicked  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/LNA-1"]/div/div[3]/p-button/button/span[1]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    Log  Delete action was performing for the first created ALD-${FIRST_CREATED_ALD_ID} from site view![OK]  console=true
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/LNA-1"]
    Element Should Not Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${FIRST_CREATED_ALD_ID}/LNA-2"]
    Log  Delete the second created ALD-${SECOND_CREATED_ALD_ID} from step-by-step!  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Nokia ALD-${SECOND_CREATED_ALD_ID}')]/span/span/div/div[2]/p-button[3]/button/span[1]
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    Log  Delete action was performing for the second created ALD-${SECOND_CREATED_ALD_ID} from step-by-step![OK]  console=true
    Element Should Not Be Visible  //*[contains(@aria-label, 'Nokia ALD-${SECOND_CREATED_ALD_ID}')]
    Save Plan From Commissioning Wizard
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices MHA')]


Step8: Delete One Existing ALD-MHA And Verify Wrench Button
    Log  \nStep8: Delete one existing ALD-MHA and verify wrench button  console=true
    ${existing_mh_as}  Get MHAs Information
    ${existing_mha_status}  Run Keyword And Return Status
    ...  Should Be Empty  ${existing_mh_as}
    Run Keyword If  ${existing_mha_status}
    ...  Run Keywords
    ...  Log  No existing MHA on vDU, this step is not nedeed!  console=true
    ...  AND
    ...  Return From Keyword
    ${first_mha}  Get From List  ${existing_mh_as}  0
    ${existing_mha_config}  Set Variable  ${first_mha}[dist_names][config]
    Click Element  //*[@id="${existing_mha_config}/LNA-1"]/div/div[3]/p-button/button/span[1]
    Click Element  //span[contains(@class, "p-button-label") and contains(text(), 'Delete')]
    Log  One existing ALD-MHA was deleted, verify if wrench option is visible!  console=true
    ${no_valid_text}  Get Text  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Should Be Equal  ${no_valid_text}  No valid radio links 2
    ...  "No valid radio links 2" is not visible, the existing ALD-MHA was not deleted successfully![NOK]
    Log  Existing ALD-MHA was deleted successfully!  console=true
    Click Element  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Element Should Be Visible  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  Wrench button is visible![OK]  console=true
    Click Element  //*[contains(@icon, 'mdi mdi-wrench')]
    Element Should Not Be Visible  //*[@id="nolinked-alds"]/div/div[1]/p-tag/span/span
    Element Should Be Visible  //*[@id="${existing_mha_config}/LNA-1"]


Create Plan With Duplicate Checkbox
    Wait Until Element Is Clicked  //span[contains(text(), "Create Plan")]  120
    Wait Until Keyword Succeeds  120  5
    ...  Input Text  //*[@id="webem-pe-create-plan-plan-name-input"]  NEW-PLAN-1
    Log  Input NEW-PLAN-1 text as plan name!  console=true
    Click Element  //*[contains(@label, 'Duplicate plan from:')]/div/div[2]
    Log  Duplicate plan from current plan was performed!  console=true
    Wait Until Element Is Clicked  //span[contains(@class, "p-button-label ng-star-inserted") and contains(text(), 'OK')]  120
    Sleep  30s  Time for plan to be updated!
    Wait Until Element Is Clicked  //*[@id="configuration-plans-dropdown"]/div/span[1]  120
    Wait Until Keyword Succeeds  30  5
    ...  Page Should Contain Element  //*[contains(@aria-label, 'NEW-PLAN-1')]
    Log  Plan NEW-PLAN-1 was created!  console=true


Verify Highlighted And Selected Objects After Specific ALD Button Was Pushed
    [Arguments]  ${ald_id}

    ${ald_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-1"]/div/div[4]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${ald_class}  selected  ALD-${ald_id} with LNA-1 was not selected after the button is pushed![NOK]
    ${ald_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-2"]/div/div[4]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${ald_class}  selected  ALD-${ald_id} with LNA-2 was not selected after the button is pushed![NOK]
    Log  ALD-${ald_id} was selected after the button is pushed![OK]  console=true
    ${first_lna_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-1"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${first_lna_class}  highlighted  LNA-1 from ALD-${ald_id} was not highlighted after the button is pushed![NOK]
    ${second_lna_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-2"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${second_lna_class}  highlighted  LNA-2 from ALD-${ald_id} was not highlighted after the button is pushed![NOK]
    Log  LNAs from ALD-${ald_id} was highlighted after the button is pushed![OK]  console=true


Verify If LNA Is Selected After LAN Button Is Pushed
    [Arguments]  ${ald_id}  ${lna_id}

    Log  Verify if LNA-${lna_id} from ALD-${ald_id} is selected after LAN-${lna_id} button is pushed  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-${lna_id}"]/div/div[5]
    ${lna_class}  Get Element Attribute  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-${lna_id}"]/div/div[5]  class
    Wait Until Keyword Succeeds  30  5
    ...  Should Contain  ${lna_class}  selected  LNA-${lna_id} from ALD-${ald_id} was not selected after the button is pushed![NOK]
    Log  LNA-${lna_id} from ALD-${ald_id} was selected after the button is pushed![OK]  console=true


Delete LNAs From Site View Without Confirmation
    [Arguments]  ${ald_id}  ${lna_id}

    Log  Delete created ALD-${ald_id} LNA-${lna_id} from site view without confirmation!  console=true
    Click Element  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-${lna_id}"]/div/div[3]/p-button/button/span[1]
    Click Element  //span[contains(@class, "p-button-label") and contains(text(), 'Cancel')]
    Log  Delete action was canceled for created ALD-${ald_id} LNA-${lna_id} from site view![OK]  console=true
    Element Should Be Visible  //*[@id="MRBTS-${VDU_MRBTS_ID}/EQM-1/APEQM-1/ALD-${ald_id}/LNA-${lna_id}"]


Delete MHAs From Step By Step Without Confirmation
    [Arguments]  ${ald_id}

    Log  Delete created ALD-${ald_id} from step-by-step without confirmation!  console=true
    Click Element  //*[contains(@aria-label, 'Nokia ALD-${ald_id}')]/span/span/div/div[2]/p-button[3]/button/span[1]
    Click Element  //span[contains(@class, "p-button-label") and contains(text(), 'Cancel')]
    Log  Delete action was canceled for created ALD-${ald_id} from step-by-step![OK]  console=true
    Element Should Be Visible  //*[contains(@aria-label, 'Nokia ALD-${ald_id}')]


Configure MHA And LNAs
    [Arguments]  ${ald_id}  ${rmod_name}

    Press Keys  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  CTRL+a+BACKSPACE
    Input Text  //*[contains(@class, 'p-tree-filter-container ng-star-inserted')]/input  Nokia ALD-${ald_id}
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'Nokia ALD-${ald_id}')]/span/span/div/div[1]
    Verify Parameter Name For MHA
    Set Selenium Speed  0.2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'AISG 2.0')]
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Wait Until Element Is Clicked
    ...  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]/span
    ${pc_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Input Text  ${pc_ald}  ${PRODUCT_CODE_ALD_MHA}
    ${sn_ald}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-string-input/
    ...  ot-field/div/input
    Input Text  ${sn_ald}  ${SERIAL_NUMBER_ALD_MHA}
    Set Selenium Speed  1
    ${status}  Run Keyword And Return Status
    ...  Page should contain  LNA-1
    Run Keyword If  ${status}
    ...  Click Element  //*[contains(@aria-label, 'LNA-1')]/span/span/div/div[1]
    ...  ELSE
    ...  Run Keywords
    ...  Click Element  //*[contains(@aria-label, 'ALD-${ald_id}')]/button
    ...  AND
    ...  Click Element  //*[contains(@aria-label, 'LNA-1')]/span/span/div/div[1]
    Verify Parameter Name For LNAs
    Set Selenium Speed  0.2
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-multiselect-input/div/p-multiselect/div/div[2]/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'LNA-2')]/span/span/div/div[1]/div
    Verify Parameter Name For LNAs
    Wait Until Element Is Clicked
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]/cem-parameter-input/cem-multiselect-input/div/p-multiselect/div/div[2]/div
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'RMOD-1 (${rmod_name})/RET')]
    Set Selenium Speed  1


Verify Parameter Name For MHA
    ${first_ald_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_ald_paramter}  Control protocol  "Control protocol" parameter is not visible![NOK]
    Log  "Control protocol" parameter is visible![OK]  console=true
    ${second_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_ald_parameter}  Controlling port  "Controlling port" parameter is not visible![NOK]
    Log  "Controlling port" parameter is visible![OK]  console=true
    ${third_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_ald_parameter}  Product code  "Product code" parameter is not visible![NOK]
    Log  "Product code" parameter is visible![OK]  console=true
    ${fourth_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${fourth_ald_parameter}  Serial number  "Serial number" parameter is not visible![NOK]
    Log  "Serial number" parameter is visible![OK]  console=true


Verify Parameter Name For LNAs
    ${first_mha_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_mha_paramter}  Amplified antenna line  "Amplified antenna line" parameter is not visible![NOK]
    Log  "Amplified antenna line" parameter is visible![OK]  console=true
    ${second_mha_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_mha_parameter}  DC power sources  "DC power sources" parameter is not visible![NOK]
    Log  "DC power sources" parameter is visible![OK]  console=true
    ${third_mha_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_mha_parameter}  Mast head amplifier gain  "Mast head amplifier gain" parameter is not visible![NOK]
    Log  "Mast head amplifier gain" parameter is visible![OK]  console=true
    ${fourth_mha_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${fourth_mha_parameter}  Subunit number  "Subunit number" parameter is not visible![NOK]
    Log  "Subunit number" parameter is visible![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Adding_MHA_without_detected_HW_to_vDU_configuration


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
