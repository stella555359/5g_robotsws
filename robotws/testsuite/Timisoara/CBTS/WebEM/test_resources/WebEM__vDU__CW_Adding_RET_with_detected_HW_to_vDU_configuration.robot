*** Settings ***
Documentation
    ...  For this TC, existing RET is mandatory!
    ...  Open Commissioning Wizard menu and verify if the page is fully loaded.
    ...  Select Create delta plan.
    ...  Verify if wrench button is visible if delete button is pushed for RET from site view.
    ...  Wrench button is pushed.
    ...  Verify if RET is configured again.
    ...  Check all parameters to be visible and to be correct.
    ...  Save the plan.
    ...  Verify if wrench button is visible if delete button is pushed for RET from step-by-step.
    ...  Wrench button is pushed.
    ...  Verify if RET is configured again.
    ...  Check all parameters to be visible and to be correct.
    ...  Save the plan.
    ...  Delete existing RET without confirmation.
    ...  Delete existing RET with confirmation and verify if parameters are not visible anymore.
    ...  Save the plan.
    ...  Delete created delta plan.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__CW_Adding_RET_with_detected_HW_to_vDU_configuration
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26633
    ...
    ...  ******************
    ...  - 05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26633 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-giorgia.toth@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB005866-C

    Step0: Set Preconditions
    Step1: Open Commissioning Wizard
    Step2: Create Delta Plan
    Step3: Add Auto-detected RET From Site View
    Step4: Verify Parameters For Auto-detected RET And Save Plan
    Step5: Add Auto-detected RET From Step-by-step
    Step6: Verify Parameters For Auto-detected RET And Save Plan
    Step7: Delete One Existing RET Without Confirmation
    Step8: Delete One Existing RET With Confirmation And Save Plan


Step0: Set Preconditions
    ${existing_rets}  Get Rets Information
    Should Not Be Empty  ${existing_rets}  No existing RET on vDU and RET is mandatory for this test!
    ${first_ret}  Get From List  ${existing_rets}  0
    ${ald}  Get From Dictionary  ${first_ret}  ald
    ${subunits}  Get From Dictionary  ${first_ret}  subunits
    ${subunit}  Get From List  ${subunits}  0
    Set Test Variable  ${EXISTING_RET_CONFIG}  ${ald}[dist_names][config]
    Set Test Variable  ${RET_ID}  ${ald}[id]
    Set Test Variable  ${RET_CONTROL_PROTOCOL}  ${ald}[control_protocol]
    Set Test Variable  ${RET_SERIAL_NUMBER}  ${ald}[serial_number]
    Set Test Variable  ${RET_PRODUCT_CODE}  ${ald}[product_code]
    ${dc_power}  Get From Dictionary  ${ald}  dc_power_sources
    ${dc_power}  Get From List  ${dc_power}  0
    ${port_name}  Set Variable  ${dc_power}[port_name]
    ${rmod_id}  Set Variable  ${dc_power}[rmod_id]
    ${rmod_type}  Set Variable  ${dc_power}[rmod_type]
    Set Test Variable  ${RET_DC_POWER_SOURCES}  RMOD-${rmod_id} (${rmod_type})/${port_name}
    ${antenna_list}  Get From Dictionary  ${subunit}  antenna_list
    ${antenna_list}  Get From List  ${antenna_list}  0
    ${port_name_retu}  Set Variable  ${antenna_list}[port_name]
    ${rmod_id_retu}  Set Variable  ${antenna_list}[rmod_id]
    ${rmod_type_retu}  Set Variable  ${antenna_list}[rmod_type]
    Set Test Variable  ${RETU_ANTENNA}  RMOD-${rmod_id_retu} (${rmod_type_retu})/${port_name_retu}


Step1: Open Commissioning Wizard
    Log  \nStep1: Open Commissioning Wizard  console=true
    Open Commissioning Wizard


Step2: Create Delta Plan
    Log  \nStep2: Create delta plan  console=true
    Create Delta Plan For CBTS


Step3: Add Auto-detected RET From Site View
    Log  \nStep3: Add auto-detected RET from site view  console=true
    Click Element  //*[@id="${EXISTING_RET_CONFIG}/RETU-1"]/div/div[3]/p-button/button/span[1]
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    Element Should Be Visible  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  Wrench button is visible![OK]  console=true
    Click Element  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  RET was configured again from site view![OK]  console=true
    Click Element  //*[@id="${EXISTING_RET_CONFIG}/RETU-1"]/div/div[2]/p-button/button/span[1]


Step${index}: Verify Parameters For Auto-detected RET And Save Plan
    Log  \nStep${index}: Verify parameters for auto-detected RET and save plan  console=true
    Verify If All Specific Parameters Name Are Visible For RET
    Verify If All Parameters Value Are Visible For RET
    Click Element  //*[contains(@aria-label, 'ALD-${RET_ID}/ALD_R-${RET_ID}')]/button/span
    Click Element  //*[contains(@aria-label, 'RETU-1/RETU_R-1')]
    Verify If All Specific Parameters Are Visible For RETU
    Save Plan From Commissioning Wizard
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RET')]


Step5: Add Auto-detected RET From Step-by-step
    Log  \nStep5: Add auto-detected RET from step-by-step  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'ALD-${RET_ID}/ALD_R-${RET_ID}')]/span/span/div/div[2]/p-button[2]/button/span[1]  120
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    Element Should Be Visible  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  Wrench button is visible![OK]  console=true
    Click Element  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  RET was configured again from step-by-step![OK]  console=true
    Click Element  //*[contains(@aria-label, 'ALD-${RET_ID}/ALD_R-${RET_ID}')]/span/span/div/div[1]/div


Step7: Delete One Existing RET Without Confirmation
    Log  \nStep7: Delete one existing RET without confirmation  console=true
    Click Element  //*[@id="${EXISTING_RET_CONFIG}/RETU-1"]/div/div[3]/p-button/button/span[1]
    Click Element  //span[contains(@class, "p-button-label") and contains(text(), 'Cancel')]
    Log  Delete action was canceled for existing RET![OK]  console=true
    Element Should Be Visible  //*[@id="${EXISTING_RET_CONFIG}/RETU-1"]/div/div[3]/p-button/button/span[1]


Step8: Delete One Existing RET With Confirmation And Save Plan
    Log  \nStep8: Delete one existing RET with confirmation and save plan  console=true
    Click Element  //*[@id="${EXISTING_RET_CONFIG}/RETU-1"]/div/div[3]/p-button/button/span[1]
    Click Element  //*[@id="laf-component"]/div/div/div[3]/div/button[1]/span
    Element Should Be Visible  //*[contains(@icon, 'mdi mdi-wrench')]
    Log  Wrench button is visible![OK]  console=true
    ${parameters_text}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr/td
    Should Be Equal  ${parameters_text}  No data available  Parameters are still visible![NOK]
    Log  Parameters are not visible anymore![OK]  console=true
    Save Plan From Commissioning Wizard
    Click Element  //*[contains(@aria-label, 'Antenna Line Devices RET')]


Verify If All Specific Parameters Name Are Visible For RET
    Log  Verify if all specific parameters name are visible for RET  console=true
    ${first_ald_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_ald_paramter}  Control protocol  "Control protocol" parameter is not visible![NOK]
    Log  "Control protocol" parameter is visible![OK]  console=true
    ${second_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]
    Should Be Equal  ${second_ald_parameter}  Controlling port  "Controlling port" parameter is not visible![NOK]
    Log  "Controlling port" parameter is visible![OK]  console=true
    ${third_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[1]
    Should Be Equal  ${third_ald_parameter}  DC power sources  "DC power sources" parameter is not visible![NOK]
    Log  "DC power sources" parameter is visible![OK]  console=true
    ${fourth_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${fourth_ald_parameter}  Product code  "Product code" parameter is not visible![NOK]
    Log  "Product code" parameter is visible![OK]  console=true
    ${fifth_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[5]/td[1]
    Should Be Equal  ${fifth_ald_parameter}  Serial number  "Serial number" parameter is not visible![NOK]
    Log  "Serial number" parameter is visible![OK]  console=true


Verify If All Parameters Value Are Visible For RET
    Log  Verify if all parameters value are visible for RET  console=true
    ${first_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[2]
    Should Be Equal  ${first_paramter}  ${RET_CONTROL_PROTOCOL}  "${RET_CONTROL_PROTOCOL}" parameter value is not visible![NOK]
    Log  "${RET_CONTROL_PROTOCOL}" parameter value is visible![OK]  console=true
    ${second_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[2]
    Should Be Equal  ${second_parameter}  ${RET_DC_POWER_SOURCES}  "${RET_DC_POWER_SOURCES}" parameter value is not visible![NOK]
    Log  "${RET_DC_POWER_SOURCES}" parameter value is visible![OK]  console=true
    ${third_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]
    Should Be Equal  ${third_parameter}  ${RET_DC_POWER_SOURCES}  "${RET_DC_POWER_SOURCES}" parameter value is not visible![NOK]
    Log  "${RET_DC_POWER_SOURCES}" parameter value is visible![OK]  console=true
    ${fourth_parameter}  Get Value
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-string-input/ot-field/div/input
    Should Be Equal  ${fourth_parameter}  ${RET_PRODUCT_CODE}  "${RET_PRODUCT_CODE}" parameter value is not visible![NOK]
    Log  "${RET_PRODUCT_CODE}" parameter value is visible![OK]  console=true
    ${fifth_parameter}  Get Value
    ...  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[5]/td[2]/cem-parameter-input/cem-string-input/ot-field/div/input
    Should Be Equal  ${fifth_parameter}  ${RET_SERIAL_NUMBER}  "${RET_SERIAL_NUMBER}" parameter value is not visible![NOK]
    Log  "${RET_SERIAL_NUMBER}" parameter value is visible![OK]  console=true


Verify If All Specific Parameters Are Visible For RETU
    Log  Verify if all specific parameters are visible for RETU  console=true
    ${first_ald_paramter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[1]/td[1]
    Should Be Equal  ${first_ald_paramter}  Configuration file  "Configuration file" parameter is not visible![NOK]
    Log  "Configuration file" parameter is visible![OK]  console=true
    ${second_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[2]/td[1]/span
    Should Be Equal  ${second_ald_parameter}  List of associated antenna lines  "List of associated antenna lines" parameter is not visible![NOK]
    Log  "List of associated antenna lines" parameter is visible![OK]  console=true
    ${third_ald_parameter}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[1]
    Should Be Equal  ${third_ald_parameter}  Subunit number  "Subunit number" parameter is not visible![NOK]
    Log  "Subunit number" parameter is visible![OK]  console=true
    ${antenna_value}  Get Text  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[3]/td[2]
    Should Be Equal  ${antenna_value}  ${RETU_ANTENNA}  "${antenna_value}" parameter value is not visible![NOK]
    Log  "${antenna_value}" parameter value is visible![OK]  console=true
    ${subunit_value_tab}  Catenate  SEPARATOR=  //*[contains(@class, 'p-element p-treetable-tbody')]/tr[4]/td[2]/cem-parameter-input/cem-number-
    ...  input/ot-field/div/ot-input-number/span/input
    ${subunit_value}  Get Value  ${subunit_value_tab}
    Should Be Equal  ${subunit_value}  1  "${subunit_value}" parameter value is not visible![NOK]
    Log  "${subunit_value}" parameter value is visible![OK]  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__CW_Adding_RET_with_detected_HW_to_vDU_configuration


TC Teardown
    Delete Actual Plan Via WebEM
    VDU WebEM Teardown
    Common VDU Teardown
