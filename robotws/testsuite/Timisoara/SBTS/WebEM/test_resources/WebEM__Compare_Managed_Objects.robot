*** Settings ***
Documentation
    ...  This TC is created to compare managed objects in Compare Objects menu.
    ...  Open Compare Objects menu and verify if the page contains all specific items.
    ...  Select one NRCELL from managed object and another one from compare object view.
    ...  Select and unselect "Show differences" button and verify if the page contains all specific items.
    ...  Verify if all paramteres are different when "Show differences" button is pushed.
    ...  Copy operation from right to left and from left to right.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Compare_Managed_Objects
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28499
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28499 - Initial TAT creation
    ...  - 13.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29706 - Change LNCEL object with NRCELL object
    ...  - 18.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29770 - Click on a different xpath to make the message disappear

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS25R2  FEATURE-CB012840

    Step1: Open Compare Object And Verify The View
    Step2: Select NRCELL Object From Managed Object And Another NRCELL Object From Compare Objects View
    Step3: Select/Unselect Option Show Differences
    Step4: Copy Operation From Right To Left Or From Left To Right


Step1: Open Compare Object And Verify The View
    Log  Step1: Open Compare Object And Verify The View  console=true
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  60
    Wait Until Element Is Clicked  //*[contains(@heading, "Compare Objects")]  60
    Log  Compare Objects menu was open!  console=true
    Wait Until Page Contains Element  //ot-side-sheet[@position='left']/div/div[1]/div/div[1]/div[1]  30
    ...  Managed objects tab is not visible on left side!
    Log  Managed objects tab is visible on left side!  console=true
    Page Should Contain  Select plan:
    Log  'Select plan:' is visible on Compare Objects page!  console=true
    Page Should Contain  Compare with:
    Log  'Compare with:' is visible on Compare Objects page!  console=true
    Page Should Contain Element  //*[contains(@class, "p-element p-treetable-scrollable-view")]
    Log  The table for compare the objects is visible!  console=true
    Page Should Contain  Status
    Log  'Status' is visible on Compare Objects page!  console=true
    Page Should Contain  Parameter name
    Log  'Parameter name' is visible on Compare Objects page!  console=true
    Page Should Contain  Abbreviation
    Log  'Abbreviation' is visible on Compare Objects page!  console=true
    Page Should Contain Element  //*[contains(@icon, "mdi mdi-chevron-double-left")]
    Page Should Contain Element  //*[contains(@icon, "mdi mdi-chevron-double-right")]
    Log  The buttons for copy parameters are visible in table headers!  console=true
    Page Should Contain Element  //*[@id="destinationMoId"]
    Log  The dropdown for "<Choose MO>" is visible in table headers!  console=true


Step2: Select NRCELL Object From Managed Object And Another NRCELL Object From Compare Objects View
    Log  Step2: Select NRCELL Object From Managed Object And Another NRCELL Object From Compare Objects View  console=true
    ${cells_list}  coam.Get Cells Info  nr
    ${cells_id}  Create List
    FOR  ${cell}  IN  @{cells_list}
        Append To List  ${cells_id}  ${cell}[globalCellId]
    END
    ${first_cell_id}  Evaluate  random.choice(${cells_id})  random
    Remove Values From List  ${cells_id}  ${first_cell_id}
    ${second_cell_id}  Evaluate  random.choice(${cells_id})  random
    Input Text  //*[@id="laf-component-compare-object"]/div/div/blocks-navigation/ot-side-sheet/div/div/div/div[2]/p-tree/div/div[1]/input
    ...  NRCELL-${first_cell_id}
    Click Element  //*[contains(@aria-label, "NRCELL-${first_cell_id}")]
    Sleep  2s  Time for the cell to be selected.
    ${cell_from_compare_table}  Get Text
    ...  //*[contains(@class, "p-treetable-scrollable-body ng-star-inserted")]/cdk-virtual-scroll-viewport/div[1]/table/thead/tr[2]/th[1]/span
    Should Be Equal  NRCELL-${first_cell_id}  ${cell_from_compare_table}
    Log  "NRCELL-${first_cell_id}" is visible on compare table!  console=true
    Click Element  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[1]/div/ot-field[2]/div/p-dropdown/div/span[1]
    Sleep  2s  Time for dropdown to appear
    Click Element  //li[contains(@aria-label, "CURRENT_BTS_CONF-1")]
    Sleep  2s  Time for dropdown to be selected
    ${plan_from_compare_table}  Get Text
    ...  //*[contains(@class, "p-treetable-scrollable-body ng-star-inserted")]/cdk-virtual-scroll-viewport/div[1]/table/thead/tr[1]/th[6]/span
    Should Be Equal  CURRENT_BTS_CONF-1  ${plan_from_compare_table}
    Log  "${plan_from_compare_table}" is visible on compare table!  console=true
    Click Element  //*[@id="destinationMoId"]
    ${nrbts_id}  Get id for current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts_id}  NRBTS_R-
    ${number_of_obj}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-dropdown-items-wrapper")]/ul/p-dropdownitem
    FOR  ${object}  IN RANGE  1  ${number_of_obj}+1
        ${object_distname}  Get Text  //*[contains(@class, "p-dropdown-items-wrapper")]/ul/p-dropdownitem[${object}]
        ${status_obj_name}  Run Keyword And Return Status
        ...  Should Match Regexp  ${object_distname}  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRCELL-*
        IF  ${status_obj_name}
            Log  Object with number ${object} is from NRBTS objects type![OK]  console=true
        ELSE
            Fail  Object with number ${object} is not from NRBTS objects type![NOK]
        END
    END
    Click Element  //*[contains(@aria-label, "MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRCELL-${second_cell_id}")]
    Sleep  2s  Time for dropdown to be selected
    ${object_from_compare_table}  Get Text  //*[@id="destinationMoId"]/div/span
    Should Contain  MRBTS-${BTS_ID}/NRBTS-${nrbts_id}/NRCELL-${second_cell_id}")  ${object_from_compare_table}
    Log  "${object_from_compare_table}" is visible on compare table!  console=true


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
    IF  ${number_of_rows_unselected} > 20
        Log  All parameters are visible because button is unselected!  console=true
    ELSE
        Fail  Not all parameters are visible when button is unselected!
    END
    Click Element  //*[contains(@label, "Show differences")]/div/div[2]
    ${button_class_selected}  SeleniumLibrary.Get Element Attribute  //*[contains(@label, "Show differences")]/div/div[2]  class
    Should Contain  ${button_class_selected}  highlight
    Log  Button "Show Differences" is selected!  console=true
    Sleep  5s  Time for parameters to be visible
    ${number_of_rows_selected}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-tbody")]/tr
    IF  ${number_of_rows_selected} > ${number_of_rows_unselected}
        Fail  Not just different parameters are visible when button is selected!
    ELSE
        Log  Only different parameters are visible because button is selected!  console=true
    END


Step4: Copy Operation From Right To Left Or From Left To Right
    Log  Step4: Copy Operation From Right To Left Or From Left To Right  console=true
    Input Text  //*[contains(@class, "p-treetable-thead")]/tr[3]/th[3]/div/input  physCellId
    Sleep  5s  Time for parameter to appear
    ${number_of_rows_selected}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-tbody")]/tr
    Should Be Equal  ${number_of_rows_selected}  ${1}
    ${param_name}  Wait Until Keyword Succeeds  120  1
    ...  Get Text  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[3]
    Should Be Equal  ${param_name}  physCellId
    Log  Parameter ${param_name} value will be changed and restore!  console=true
    ${first_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[4]/div/cem-parameter-input
    ...  /cem-number-input/ot-field/div/ot-input-number/span/input
    ${second_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[6]/div/cem-parameter-input
    ...  /cem-number-input/ot-field/div/ot-input-number/span/input
    ${initial_first_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    ${initial_second_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${second_xpath}
    Should Not Be Equal  ${initial_first_value}  ${initial_second_value}
    Log  Initial values are not equals![OK]  console=true
    ${input_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[4]/div/cem-parameter-input
    ...  /cem-number-input/ot-field/div/ot-input-number/span/input
    Wait Until Keyword Succeeds  120  1
    ...  Input text  ${input_xpath}  1${initial_first_value}
    Sleep  5s  This sleep is for value to be changed.
    ${changed_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    Should be equal  ${changed_value}  1${initial_first_value}
    Log  Initial value was ${initial_first_value} and the changed value is ${changed_value}  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[4]/div/p-button/button/span[1]  120  1
    Sleep  5s  This sleep is for value to be changed.
    ${restored_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    Should be equal  ${restored_value}  ${initial_first_value}
    Log  Initial value was resored for ${param_name}!  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[2]  120  1
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[5]/div/p-button[1]/button/span[1]  120  1
    Sleep  5s  This sleep is for value to be changed.
    Log  Button "Copy Parameter from Right to Left" was pushed for parameter ${param_name}!  console=true
    ${changed_first_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    ${changed_second_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${second_xpath}
    Should Be Equal  ${changed_first_value}  ${changed_second_value}
    Should Be Equal  ${changed_first_value}  ${initial_second_value}
    Log  Both values are the same, for first cell is ${changed_first_value} and for the second cell is ${changed_second_value}  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[2]  120  1
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[4]/div/p-button/button/span[1]  120  1
    Sleep  5s  This sleep is for value to be changed.
    ${restored_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    Should be equal  ${restored_value}  ${initial_first_value}
    Log  Initial value ${restored_value} resored for ${param_name}!  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[2]  120  1
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[5]/div/p-button[2]/button/span[1]  120  1
    Sleep  5s  This sleep is for value to be changed.
    Log  Button "Copy Parameter from Left to Right" was pushed for parameter ${param_name}!  console=true
    ${changed_first_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    ${changed_second_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${second_xpath}
    Should Be Equal  ${changed_first_value}  ${changed_second_value}
    Should Be Equal  ${changed_second_value}  ${initial_first_value}
    Log  Both values are the same, for first cell is ${changed_first_value} and for the second cell is ${changed_second_value}  console=true
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[2]  120  1
    Wait Until Element Is Clicked
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr/td[6]/div/p-button/button/span[1]  120  1
    Sleep  5s  This sleep is for value to be changed.
    ${restored_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${second_xpath}
    Should be equal  ${restored_value}  ${initial_second_value}
    Log  Initial value ${restored_value} was resored for ${param_name}!  console=true
    Input Text  //*[contains(@class, "p-treetable-thead")]/tr[3]/th[3]/div/input  nrCellId
    Sleep  5s  Time for parameter to appear
    ${number_of_rows_selected}  SeleniumLibrary.Get Element Count  //*[contains(@class, "p-element p-treetable-tbody")]/tr
    Should Be Equal  ${number_of_rows_selected}  ${2}
    ${param_name}  Wait Until Keyword Succeeds  120  1
    ...  Get Text  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[3]
    Should Be Equal  ${param_name}  nrCellId
    Log  Parameter ${param_name} value will be verified!  console=true
    ${first_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[4]/div/
    ...  cem-parameter-input/cem-instance-id-input/ot-field/div/ot-input-number/span/input
    ${second_xpath}  Catenate  SEPARATOR=  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[6]/div/
    ...  cem-parameter-input/cem-instance-id-input/ot-field/div/ot-input-number/span/input
    ${first_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${first_xpath}
    ${second_value}  Wait Until Keyword Succeeds  120  1
    ...  Get Value  ${second_xpath}
    Should Not Be Equal  ${first_value}  ${second_value}
    Log  Values for nrCellId are not equal![OK]  console=true
    ${attribute}  Wait Until Keyword Succeeds  120  1  SeleniumLibrary.Get Element Attribute
    ...  //*[contains(@class, "p-element p-treetable-tbody")]/tr[1]/td[4]/div/cem-parameter-input/cem-instance-id-input/ot-field/div  readonly
    IF  '${attribute}' == 'true'
        Log  Values are read only![OK]  console=true
    ELSE
        Fail  Values are not read only![NOK]
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
