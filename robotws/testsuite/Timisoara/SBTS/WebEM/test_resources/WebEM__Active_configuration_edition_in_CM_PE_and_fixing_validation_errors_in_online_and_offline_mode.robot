*** Settings ***
Documentation
    ...  This test case, in WebEM (online /offline mode), is able to edit active configuration in Parameter Editor in order to prepare a
    ...  configuration update. The WebEM user is also able to view definition and relation (including hardware) errors in the bottom part of
    ...  parameter editor. The user may also have prepared other staged plan, switch to them and continue with edition.
    ...  The WebEM opens 'Parameter Editor' view and displays the table with the active configuration.
    ...  Filtering and expanding/collapsing all managed objects can be performed successfully.
    ...  The user, 'Parameter Editor', updates the selected parameters in the active configuration, and the changes are stored in the webEM cache.
    ...  The user can fix the errors one by one by setting values to default, deleting them, reverting value but also can use option 'fix errors'
    ...  to all missing managed objects with default values assigned to its mandatory parameters with default values.
    ...  In relation errors tab, shall contain following columns: Severity, Status column, Managed object, Error description.
    ...  The user can filter by severity, managed object or error description.
    ...  The operator select hyper link (in error description/relation error tab) and the WebEM redirects it to parameter table for this parameter.
    ...  The operator navigates to the related parameters table and confirms that when it is displayed, the parameter table is not shown.
    ...  The operator checks that the related parameters table includes the managed object alongside the parameter name.
    ...  In offline mode, the user repeats step 1 and step 2.
    ...  Check alarms in WebEM. No new alarms are raised. SBTS is fully operational.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Active_configuration_edition_in_CM_PE_and_fixing_validation_errors_in_online_and_offline_mode
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28497
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28497 - Initial TAT creation
    ...  - 18.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28944 - Change xpath for the searchable object
    ...  - 30.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29301 - Errors tab needs to be open in trunk
    ...  - 18.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29712 - Fix xpath for BBMOD object
    ...  - 14.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30024 - Fix xpath for Definition Errors tab

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CB012840

    Step1: Open Parameter Editor And View The Table With The Active Configuration
    Step2: Filtering And Expanding/Collapsing All Managed Objects
    Step3: Updates The Selected Parameters In The Active Configuration
    Step4: Check Relation Errors And Definition Errors
    Step5: Check If Columns Are Displayed In Relation Error Tab
    Step6: Check Filter By Severity, Managed Object Or Error Description
    Step7: Select Hyper Link And The WebEM Redirects It To Parameter Table
    Step8: Check Difference Between Related Parameter Table And Parameter Table
    Step9: Check Active Configuration And Expanding/Collapsing In Offline Mode


Step1: Open Parameter Editor And View The Table With The Active Configuration
    Log  \nStep1: Open Parameter Editor And View The Table With The Active Configuration  console=true
    Collect Infomodel Log From Current Session  ${BTS_FILES}/test_infomodel.ims2  timeout=300
    Log  Infomodel log saved under: ${BTS_FILES}/test_infomodel.ims2  console=true
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90  10
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Enabled  //*[@class="h-full w-full"]/p-treetable/div/div[1]/div/div/cdk-virtual-scroll-viewport/div[1]/table  120
    IF  ${status}
        Log  In 'Parameter Editor' is present table with the active configuration  console=true
    ELSE
        Fail  In 'Parameter Editor' is not present table with the active configuration
    END


Step2: Filtering And Expanding/Collapsing All Managed Objects
    Log  \nStep2: Filtering And Expanding/Collapsing All Managed Objects  console=true
    Check Filter Tab
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]/div/div[2]/p-tree/div/div/div/i
    Log  Close search filter.  console=true
    Check Expand And Collapse Tabs


Step3: Updates The Selected Parameters In The Active Configuration
    Log  \nStep3: Updates The Selected Parameters In The Active Configuration  console=true
    Change One Parameter
    ${second_parameter}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[2]/td[4]/cem-parameter-input/
    ...  cem-dropdown-input/div/p-dropdown/div/div[2]/span
    Wait Until Element Is Clicked  ${second_parameter}
    Wait Until Element Is Clicked  //li[contains(@class, 'p-ripple p-element p-dropdown-item') and contains(@aria-selected, 'false')]
    ${status}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[2]/td[1]/div/i  20
    IF  ${status}
        Log  Value of the second parameter is changed!  console=true
    ELSE
        Fail  Value of the second parameter is not changed!
    END
    Add parameter to object
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60
    Sleep  10s  Time for plan to be validated.


Step4: Check Relation Errors And Definition Errors
    Log  \nStep4: Check Relation Errors And Definition Errors  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        Wait Until Element Is Clicked  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'Definition Errors')]
    ELSE
        Click Element  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/div/div/p-button/button/span[1]
    END
    Wait Until Element Is Visible  //div[contains(@class, 'p-datatable-wrapper')]  20
    Log  'Definition Errors' table is visible.  console=true
    Wait Until Element Is Clicked  ${FIX_ERRORS}
    Wait Until Element is Visible  //*[@id="laf-component"]/div/div/div[1]/div[1]/span  20
    Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button[1]/button
    Log  'Fix Errors' button is pressed.  console=true
    ${number_definition_errors}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/
    ...  p-tabview/div/div[1]/div/ul/li[1]/a/p-badge/span[contains(text(),' 0 ')]
    ${status_definition_errors}  Run Keyword And Return Status  Wait Until Element Is Enabled  ${number_definition_errors}  20
    WHILE  ${status_definition_errors}==${FALSE}
        Fix Errors One By One By Setting Values To Default From Definition Errors
        ${status_definition_errors}  Run Keyword And Return Status  Wait Until Element Is Enabled  ${number_definition_errors}  20
    END
    ${number_relation_errors}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/blocks-validation-errors/p-tabview/
    ...  div/div[1]/div/ul/li[2]/a/p-badge/span[contains(text(),' 0 ')]
    ${status_relation_errors}  Run Keyword And Return Status  Wait Until Element Is Enabled  ${number_relation_errors}  20
    Set Test Variable  ${EXIT_TO_LOOP}  False
    WHILE  ${status_relation_errors}==${FALSE}
        IF  ${EXIT_TO_LOOP}==${TRUE}
            BREAK
        END
        Fix Errors One By One By Setting Values To Default From Relation Errors
        ${status_relation_errors}  Run Keyword And Return Status  Wait Until Element Is Enabled  ${number_relation_errors}  20
    END


Step5: Check If Columns Are Displayed In Relation Error Tab
    Log  \nStep5: Check If Columns Are Displayed In Relation Error Tab  console=true
    Wait Until Element Is Clicked  //span[contains(text(),'Relation Errors')]
    Wait Until Element Is Visible  //span[contains(text(),'Severity')]  20
    Log  'Severity' column is displayed in relation error tab.  console=true
    Wait Until Element Is Visible  //span[contains(text(),'Managed object')]  20
    Log  'Managed object' column is displayed in relation error tab.  console=true
    Wait Until Element Is Visible  //span[contains(text(),'Error description')]  20
    Log  'Error description' column is displayed in relation error tab.  console=true


Step6: Check Filter By Severity, Managed Object Or Error Description
    Log  \nStep6: Check Filter By Severity, Managed Object Or Error Description  console=true
    Input Text  //div[contains(@class, 'p-datatable-wrapper')]/table/thead/tr[2]/th[2]/div/input  error
    Log  Filter by 'Severity' is checked.  console=true
    Input Text  //div[contains(@class, 'p-datatable-wrapper')]/table/thead/tr[2]/th[3]/div/input  bbmod
    Log  Filter by 'Managed object' is checked.  console=true
    Input Text  //div[contains(@class, 'p-datatable-wrapper')]/table/thead/tr[2]/th[4]/div/input  whenever
    Log  Filter by 'Error description' is checked.  console=true
    Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/thead/tr[2]/th[2]/div/span[2]/button/i
    Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/thead/tr[2]/th[3]/div/span[2]/button/i
    Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/thead/tr[2]/th[4]/div/span[2]/button/i


Step7: Select Hyper Link And The WebEM Redirects It To Parameter Table
    Log  \nStep7: Select Hyper Link And The WebEM Redirects It To Parameter Table  console=true
    Change One Parameter
    Wait Until Element Is Clicked  //span[contains(text(),'Relation Errors')]
    Wait Until Element Is Visible  //div[contains(@class, 'p-datatable-wrapper')]  20
    Log  'Relation Errors' table is visible.  console=true
    ${number_of_rows}  Get Element Count  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr
    WHILE  ${number_of_rows}!=1
        ${managed_object}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[1]/td[3]/div
        Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[1]/td[4]/div/a  60
        Log  Go to Managed Object.  console=true
        Wait Until Element Is Visible  //div[contains(text(), ' ${managed_object} (Baseband Module) ')]  30
        Log  WebEM redirects it to parameter table for this parameter: ${managed_object}.  console=true
        Fix Errors One By One By For Each Parameter
        ${number_of_rows}  Get Element Count  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr
    END


Step8: Check Difference Between Related Parameter Table And Parameter Table
    Log  \nStep8: Check Difference Between Related Parameter Table And Parameter Table  console=true
    Input Text  ${FILTER_XPATH}  BBMOD-1
    Wait Until Element Is Clicked  //div[contains(@aria-label, 'BBMOD-1')]/span/span/div/div/div
    Add parameter to object
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60
    Sleep  10s  Time for validate plan
    Wait Until Element Is Clicked  //span[contains(text(),'Relation Errors')]
    ${managed_object}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[1]/td[3]/div
    Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[1]/td[5]/p-button/button/span[1]
    Log  Go to the 'Related Parameter' table.  console=true
    Wait Until Element Is Visible  //div[contains(text(), ' Related Parameters: ')]  30
    Log  'Related Parameter' table is visible.  console=true
    ${parameter_name_text}  Get Text  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/table/tbody/tr[1]/td[2]/div
    ${parameter_name_related_table}  Replace String  ${parameter_name_text}  \n  ${EMPTY}
    Log  Go to 'Parameter Table'.  console=true
    Wait Until Element Is Clicked  //div[contains(@aria-label, 'BBMOD-1')]/span/span/div/div/div
    Wait Until Element Is Visible  //div[contains(text(), ' ${managed_object} (Baseband Module) ')]  30
    Log  'Parameter Table' is visible.  console=true
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  SRIO connection
    ${parameter_name}  Get Text  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/table/tbody/tr[1]/td[2]/div
    IF  '${parameter_name_related_table}' != '${parameter_name}'
        Log  In 'Related Parameter' table: ${parameter_name_related_table}, in 'Parameter Table': ${parameter_name}  console=true
    ELSE
        Fail  Parameter name is the same in both tables![NOK]  console=true
    END
    Wait Until Element Is Clicked  //span[contains(text(),'Definition Errors')]
    Fix Errors One By One By Setting Values To Default From Definition Errors


Step9: Check Active Configuration And Expanding/Collapsing In Offline Mode
    Log  \nStep9: Check Active Configuration And Expanding/Collapsing In Offline Mode  console=true
    Download Application
    Logout From SBTS
    Close Browser
    Open WebEM In Offline Mode
    Choose File  //ot-upload[@class="p-element p-button-icon-only p-button-secondary ng-star-inserted"]//input  ${BTS_FILES}/test_infomodel.ims2
    Sleep  60s  Time for ims2 to be uploaded!
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90  10
    Wait Until Element Is Visible  //div[contains(text(), 'Managed objects')]  60
    Check Filter Tab
    Wait Until Element Is Clicked
    ...  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]/div/div[2]/p-tree/div/div/div/i
    Check Expand And Collapse Tabs
    Wait Until Element Is Clicked  //*[@id="main-view"]/div/div[1]/div[1]/product-bar/otx-product-bar/div/div[2]/div[1]/button/span[1]
    Log  SBTS is in online mode  console=true


Check Filter Tab
    ${FILTER_XPATH}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[2]/p-tree/div/div/input
    Set Test Variable  ${FILTER_XPATH}
    ${status_filter}  Run Keyword And Return Status  Wait Until Element is Visible  ${FILTER_XPATH}  10
    IF  ${status_filter}
        Log  Filter tab is visible![OK]  console=true
    ELSE
        Fail  Filter tab is not visible![NOK]
    END
    Input Text  ${FILTER_XPATH}  BBMOD-1
    ${status_search}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'BBMOD-1')]  10
    IF  ${status_search}
        Log  Objects are filtered by the BBMOD object![OK]  console=true
    ELSE
        Fail  Objects are not filtered by the BBMOD object![NOK]
    END


Check Expand And Collapse Tabs
    ${expand_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[1]/div[2]/p-button[2]/button/span[1]
    ${collapse_xpath}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/
    ...  div[1]/div/div[1]/div[2]/p-button[1]/button/span[1]
    Wait Until Element Is Clicked  ${expand_xpath}
    ${number_of_objects}  Get Element Count  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/ul/p-treenode
    IF  ${number_of_objects}>1
        Log  'Expand All' button is pressed!  console=true
    ELSE
        Fail  'Expand All' button is not pressed!
    END
    Wait Until Element Is Clicked  ${collapse_xpath}
    ${number_of_objects}  Get Element Count  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/ul/p-treenode
    IF  ${number_of_objects}==1
        Log  'Collapse All' button is pressed!  console=true
    ELSE
        Fail  'Collapse All' button is not pressed!
    END


Change One Parameter
    Input Text  ${FILTER_XPATH}  BBMOD-1
    Wait Until Element Is Clicked  //span[contains(@class, 'ot-highlight-text') and contains(text(), 'BBMOD-1')]
    ${status}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/span[2]/button/i  20
    IF  ${status}  Click Element  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/span[2]/button/i
    ${first_parameter}  Catenate  SEPARATOR=  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[4]/cem-parameter-input/
    ...  cem-dropdown-input/div/p-dropdown/div/div[2]/span
    Wait Until Element Is Clicked  ${first_parameter}
    Wait Until Element Is Clicked  //li[contains(@class, 'p-ripple p-element p-dropdown-item') and contains(@aria-selected, 'false')]
    ${status}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr[1]/td[1]/div/i  20
    IF  ${status}
        Log  Value of the first parameter is changed!  console=true
    ELSE
        Fail  Value of the first parameter is not changed!
    END
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60


Add parameter to object
    Input Text  //*[@class="cdk-virtual-scroll-content-wrapper"]/table/thead/tr[2]/th[2]/div/input  SRIO connection
    Sleep  10s  Time for table to be updated.
    Wait Until Element Is Clicked  //div[@class="cdk-virtual-scroll-content-wrapper"]/table/tbody/tr/td[6]/p-button[1]/button/span[1]
    Log  Parameter is added to object.  console=true
    Sleep  10s  Time for object to be added.
    Page Should Contain  linkId


Fix Errors One By One By Setting Values To Default From Definition Errors
    ${number_of_rows}  Get Element Count  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        Double Click Element  //span[contains(@class, 'p-tabview-title ng-star-inserted') and contains(text(), 'Definition Errors')]
        Wait Until Element Is Visible   //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${row}]/td[1]/div  60
        ${managed_object}  Get Text  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${row}]/td[1]/div
        Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[${row}]/td[4]/p-button/button/span[1]  60
        Log  'Go to parameter' button is pressed.  console=true
        Wait Until Element Is Visible  //div[contains(text(), ' ${managed_object} (Baseband Module) ')]  30
        ${status_delete}  Run Keyword And Return Status  Wait Until Element is Visible
        ...  //*[contains(@class, "mdi mdi-minus p-button-icon ng-star-inserted")]  20
        IF  ${status_delete}
            Click Element  //*[contains(@class, "mdi mdi-minus p-button-icon ng-star-inserted")]
            Log  Object is deleted.  console=true
        END
    END
    Wait Until Element Is Visible  //div[contains(@class, 'p-tabview-nav-content')]/ul/li[2]/a/i  30
    Log  'Status column' is displayed in relation error tab.  console=true
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60


Fix Errors One By One By Setting Values To Default From Relation Errors
    Wait Until Element Is Clicked  //span[contains(text(),'Relation Errors')]
    Wait Until Element Is Clicked  //div[contains(@class, 'p-datatable-wrapper')]/table/tbody/tr[1]/td[5]/p-button/button/span[1]  60
    Log  'Go to the related parameter(s)' button is pressed.  console=true
    Wait Until Element Is Visible  //div[contains(text(), ' Related Parameters: ')]  30
    ${status_restore}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //*[contains(@class, "mdi mdi-cog-counterclockwise p-button-icon ng-star-inserted")]  20
    ${status_edit}  Run Keyword And Return Status  Wait Until Element is Visible
    ...  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/table/tbody/tr/td[1]/div/i  20
    IF  ${status_restore} and ${status_edit}
        Click Element  //*[contains(@class, "mdi mdi-cog-counterclockwise p-button-icon ng-star-inserted")]
        Log  Restore to default value  console=true
    ELSE
        Set Test Variable  ${EXIT_TO_LOOP}  True
    END
    Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60


Fix Errors One By One By For Each Parameter
    ${number_of_rows}  Get Element Count  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/table/tbody/tr
    FOR  ${row}  IN RANGE  1  ${number_of_rows}+1
        ${status_parameter_changed}  Run Keyword And Return Status  Wait Until Element is Visible
        ...  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/table/tbody/tr[${row}]/td[1]/div/i  20
        IF  ${status_parameter_changed}
            Click Element  //div[contains(@class, 'cdk-virtual-scroll-content-wrapper')]/table/tbody/tr[${row}]/td[6]/p-button[2]/button/span[1]
            Log  Restore to default value.  console=true
        END
        Wait Until Element Is Clicked  ${VALIDATE_PLAN_PE}  60
    END


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
