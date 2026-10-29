*** Settings ***
Documentation
    ...  This TC is created to compare managed objects in Compare Objects menu.
    ...  Open Compare Objects menu and verify if the page contains all specific items.
    ...  Select one TNL object from managed object and another one from compare object view.
    ...  Select and unselect "Show differences" button and verify if the page contains all specific items.
    ...  Verify if all paramteres are different when "Show differences" button is pushed.
    ...  Copy operation from right to left and from left to right.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${FIRST_TNL_ID}  1  #Mandatory! The id of the first tnl to be tested. Eg. 1
${SECOND_TNL_ID}  2  #Mandatory! The id of the second tnl to be tested. Eg. 2


*** Keywords ***
TC__WebEM__vDU__Compare_Managed_Objects_for_vDU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28498
    ...
    ...  ******************
    ...  - 31.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28498 - Initial TAT creation
    ...  - 25.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29761 - Fix xpath

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDUCNF25R2  FEATURE-CB012840

    Step1: Open Compare Objects And Verify The View
    Step2: Select TNL Object From Managed Object And Another TNL Object From Compare Objects View
    Step3: Select/Unselect Option Show Differences
    Step4: Copy Operation From Right To Left And From Left To Right


Step1: Open Compare Objects And Verify The View
    Log  Step1: Open Compare Objects And Verify The View  console=true
    Wait Until Element Is Clicked  //*[contains(@aria-label, "Commissioning Wizard")]/i  120
    Sleep  10s  Time for page to be updated
    Wait Until Element Is Clicked  //*[contains(@id, "/compare-objects")]  120
    Sleep  10s  Time for page to be updated
    Page should contain  Show differences
    Log  Compare Objects was opened successfully![OK]  console=true
    Page Should Contain  Select plan:
    Log  'Select plan:' is visible on Compare Objects page!  console=true
    Page Should Contain  Compare with:
    Log  'Compare with:' is visible on Compare Objects page!  console=true
    Page Should Contain Element  //*[contains(@class, "p-element p-treetable-scrollable-view")]
    Log  The table for compare the objects is visible!  console=true
    Page Should Contain  Parameter name
    Log  'Parameter name' is visible on Compare Objects page!  console=true
    Page Should Contain  Abbreviation
    Log  'Abbreviation' is visible on Compare Objects page!  console=true
    Page Should Contain Element  //*[contains(@icon, "mdi mdi-chevron-double-left")]
    Page Should Contain Element  //*[contains(@icon, "mdi mdi-chevron-double-right")]
    Log  The buttons for copy parameters are visible in table headers!  console=true
    Page Should Contain Element  //*[contains(@placeholder, "<Choose MO>")]
    Log  The dropdown for "<Choose MO>" is visible in table headers!  console=true


Step2: Select TNL Object From Managed Object And Another TNL Object From Compare Objects View
    Log  Step2: Select TNL Object From Managed Object And Another TNL Object From Compare Objects View  console=true
    Input Text  //*[@id="laf-component-compare-object"]/div/div/blocks-navigation/ot-side-sheet/div/div[1]/div/div[2]/p-tree/div/div/input
    ...  TNL-${FIRST_TNL_ID}
    Press Keys  //*[@id="laf-component-compare-object"]/div/div/blocks-navigation/ot-side-sheet/div/div[1]/div/div[2]/p-tree/div/div/input
    ...  ENTER
    Wait Until Element Is Clicked  //*[contains(@aria-label, "TNL-${FIRST_TNL_ID}")]
    Sleep  2s  Time for the tnl to be selected.
    ${tnl_from_compare_table}  Get Text
    ...  //*[contains(@class, "p-treetable-scrollable-body ng-star-inserted")]/cdk-virtual-scroll-viewport/div[1]/table/thead/tr[2]/th[1]/span
    Should Be Equal  TNL-${FIRST_TNL_ID}  ${tnl_from_compare_table}
    Log  "TNL-${FIRST_TNL_ID}" is visible on compare table!  console=true
    Click Element  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[1]/div/ot-field[2]/div/p-dropdown/div/span[1]
    Sleep  2s  Time for dropdown to appear
    Click Element  //li[contains(@aria-label, "Current Plan")]
    Sleep  2s  Time for dropdown to be selected
    ${plan_from_compare_table}  Get Text
    ...  //*[contains(@class, "p-treetable-scrollable-body ng-star-inserted")]/cdk-virtual-scroll-viewport/div[1]/table/thead/tr[1]/th[6]/span
    Should Be Equal  Current Plan  ${plan_from_compare_table}
    Log  "${plan_from_compare_table}" is visible on compare table!  console=true
    Click Element  //*[contains(@placeholder, "<Choose MO>")]
    ${number_of_obj}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-dropdown-items-wrapper")]/ul/p-dropdownitem
    FOR  ${object}  IN RANGE  1  ${number_of_obj}+1
        ${object_distname}  Get Text  //*[contains(@class, "p-dropdown-items-wrapper")]/ul/p-dropdownitem[${object}]
        ${status_obj_name}  Run Keyword And Return Status
        ...  Should Match Regexp  ${object_distname}  MRBTS-${VDU_MRBTS_ID}/TNLSVC-[0-9]+/TNL-[0-9]+$
        Run Keyword If  ${status_obj_name}
        ...  Log  Object with number ${object} is from TNLSVC objects type![OK]  console=true
        ...  ELSE
        ...  Fail  Object with number ${object} is not from TNLSVC objects type![NOK]
    END
    Click Element  //*[contains(@aria-label, "MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/TNL-${SECOND_TNL_ID}")]
    Sleep  2s  Time for dropdown to be selected
    ${object_from_compare_table}  Get Text  //*[@id="destinationMoId"]/div/span
    Should Contain  MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/TNL-${SECOND_TNL_ID}")  ${object_from_compare_table}
    Log  "MRBTS-${VDU_MRBTS_ID}/TNLSVC-1/TNL-${SECOND_TNL_ID}" is visible on compare table!  console=true


Step3: Select/Unselect Option Show Differences
    Log  Step3: Select/Unselect Option Show Differences  console=true
    ${button_class_selected}  SeleniumLibrary.Get Element Attribute  //*[contains(@label, "Show differences")]/div/div[2]  class
    Should Contain  ${button_class_selected}  highlight
    Log  Button "Show Differences" is selected as default!  console=true
    Click Element  //*[contains(@label, "Show differences")]/div/div[2]
    ${button_class_unselected}  SeleniumLibrary.Get Element Attribute  //*[contains(@label, "Show differences")]/div/div[2]  class
    Should Not Contain  ${button_class_unselected}  highlight
    Log  Button "Show Differences" is unselected!  console=true
    Sleep  30  Time for all parameters to appear!
    ${number_of_rows_unselected}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-tbody")]/tr
    Run keyword if  ${number_of_rows_unselected} > 15
    ...  Log  All parameters are visible because button is unselected!  console=true
    ...  ELSE
    ...  Fail  Not all parameters are visible when button is unselected!
    Click Element  //*[contains(@label, "Show differences")]/div/div[2]
    ${button_class_selected}  SeleniumLibrary.Get Element Attribute  //*[contains(@label, "Show differences")]/div/div[2]  class
    Should Contain  ${button_class_selected}  highlight
    Log  Button "Show Differences" is selected!  console=true
    Sleep  5s  Time for parameters to be visible
    ${number_of_rows_selected}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-tbody")]/tr
    Run Keyword If  ${number_of_rows_selected} == 2
    ...  Compare Values For Two Parameters
    ...  ELSE
    ...  Compare Values For Three Parameters


Step4: Copy Operation From Right To Left And From Left To Right
    Log  Step4: Copy Operation From Right To Left And From Left To Right  console=true
    ${number_of_rows_selected}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-tbody")]/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows_selected}+1
        ${copy_operation_status}  Run Keyword And Return Status  SeleniumLibrary.Page Should Contain Element
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[5]/div/p-button[1]/button/span[1]
        Continue For Loop If  '${copy_operation_status}' == 'False'
        ${param_name}  Get Text  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[3]
        Log  Parameter ${param_name} value will be changed and restore!  console=true
        ${initial_first_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        ${initial_second_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[6]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        ${input_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]//div/cem-parameter-input/
        ...  cem-string-input/ot-field/div/input
        Input text  ${input_xpath}  1${initial_first_value}
        ${changed_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        Should be equal  ${changed_value}  1${initial_first_value}
        Log  Initial value was ${initial_first_value} and the changed value is ${changed_value}  console=true
        Click element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/p-button/button/span[1]
        ${restored_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        Should be equal  ${restored_value}  ${initial_first_value}
        Log  Initial value was resored for ${param_name}!  console=true
        Click Element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[2]
        Click Element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[5]/div/p-button[1]/button/span[1]
        Log  Button "Copy Parameter from Right to Left" was pushed for parameter ${param_name}!  console=true
        ${changed_first_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        ${changed_second_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[6]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        Should Be Equal  ${changed_first_value}  ${changed_second_value}
        Should Be Equal  ${changed_first_value}  ${initial_second_value}
        Log  Both values are the same, for first cell is ${changed_first_value} and for the second cell is ${changed_second_value}  console=true
        Click element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/p-button/button/span[1]
        ${restored_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        Should be equal  ${restored_value}  ${initial_first_value}
        Log  Initial value ${restored_value} from first cell was resored for ${param_name}!  console=true
        Click Element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[2]
        Click Element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[5]/div/p-button[2]/button/span[1]
        Log  Button "Copy Parameter from Left to Right" was pushed for parameter ${param_name}!  console=true
        ${changed_first_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        ${changed_second_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[6]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        Should Be Equal  ${changed_first_value}  ${changed_second_value}
        Should Be Equal  ${changed_second_value}  ${initial_first_value}
        Log  Both values are the same, for first cell is ${changed_first_value} and for the second cell is ${changed_second_value}  console=true
        Click element  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[6]/div/p-button/button/span[1]
        ${restored_value}  Get Value
        ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[${row}]/td[6]/div/cem-parameter-input/cem-string-input/ot-field/div/input
        Should be equal  ${restored_value}  ${initial_second_value}
        Log  Initial value ${restored_value} from first cell was resored for ${param_name}!  console=true
        Exit For Loop
    END


Compare Values For Two Parameters
    ${first_row_first_value_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[4]/div/cem-parameter-input
    ...  /cem-instance-id-input/ot-field/div/ot-input-number/span/input
    ${first_row_first_value}  Get Value
    ...  ${first_row_first_value_xpath}
    ${first_row_second_value_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[6]/div/cem-parameter-input
    ...  /cem-instance-id-input/ot-field/div/ot-input-number/span/input
    ${first_row_second_value}  Get Value
    ...  ${first_row_second_value_xpath}
    Should Not Be Equal  ${first_row_first_value}  ${first_row_second_value}
    Log  Compared values are not equal, the value from first tnl is ${first_row_first_value} and from the second tnl is ${first_row_second_value}
    ...  console=true
    ${second_row_first_value}  Get Value
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[2]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
    ${second_row_second_value}  Get Value
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[2]/td[6]/div/cem-parameter-input/cem-string-input/ot-field/div/input
    Should Not Be Equal  ${second_row_first_value}  ${second_row_second_value}
    Log  Compared values are not equal, the value from first tnl is ${second_row_first_value} and from the second tnl is ${second_row_second_value}
    ...  console=true


Compare Values For Three Parameters
    ${first_row_first_value}  Get Value
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[4]/div/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    ${first_row_second_value}  Get Value
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[6]/div/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]
    Should Not Be Equal  ${first_row_first_value}  ${first_row_second_value}
    Log  Compared values are not equal, the value from first tnl is ${first_row_first_value} and from the second tnl is ${first_row_second_value}
    ...  console=true
    ${second_row_first_value_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[2]/td[4]/div/cem-parameter-input
    ...  /cem-instance-id-input/ot-field/div/ot-input-number/span/input
    ${second_row_first_value}  Get Value
    ...  ${second_row_first_value_xpath}
    ${second_row_second_value_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[2]/td[6]/div/cem-parameter-input
    ...  /cem-instance-id-input/ot-field/div/ot-input-number/span/input
    ${second_row_second_value}  Get Value
    ...  ${second_row_second_value_xpath}
    Should Not Be Equal  ${second_row_first_value}  ${second_row_second_value}
    Log  Compared values are not equal, the value from first tnl is ${second_row_first_value} and from the second tnl is ${second_row_second_value}
    ...  console=true
    ${third_row_first_value}  Get Value
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[3]/td[4]/div/cem-parameter-input/cem-string-input/ot-field/div/input
    ${third_row_second_value}  Get Value
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[3]/td[6]/div/cem-parameter-input/cem-string-input/ot-field/div/input
    Should Not Be Equal  ${third_row_first_value}  ${third_row_second_value}
    Log  Compared values are not equal, the value from first tnl is ${third_row_first_value} and from the second tnl is ${third_row_second_value}
    ...  console=true


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Compare_Managed_Objects_for_vDU


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
