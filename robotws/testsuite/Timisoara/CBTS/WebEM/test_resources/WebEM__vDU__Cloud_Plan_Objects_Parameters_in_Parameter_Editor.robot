*** Settings ***
Documentation
    ...  This TC is created to verify details about objects and parameters from Parameter Editor.
    ...  Open Parameter Editor View.
    ...  Verify if current plan is visible as default plan.
    ...  Create a plan in CW and then goes to parameter editor view, plan created shall be kept.
    ...  MRBTS object is selected and check the details.
    ...  btsName parameter frmo MRBTS object is selected and check the details.
    ...  Verify if default managed objects are collapsed.
    ...  Verify Expand All/Collapse All buttons.
    ...  Verify Configuration Management Submenus.
    ...  Verify ALD Management Submenus.
    ...  Verify if Current Configuration, Planned Configuration and Inactive Configuration are visible afer dropdown is pushed.

Resource  ../resources/vdu_WebEM_general.robot
Resource  ../../common_resources/vdu_frame.robot


*** Keywords ***
TC__WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28496
    ...
    ...  ******************
    ...  - 24.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28496 - Initial TAT creation
    ...  - 17.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30237 - Xpath changed for abbreviated name in details
    ...  - 22.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30410 - Xpath changed for full name and properties in details
    ...  - 24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30533 - Xpath changed in details

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDUCNF25R2  FEATURE-CB012840

    Step1: Open Parameter Editor View
    Step2: Verify Different Cases With Plans In Parameter Editor And Commissioning Wizard
    Step3: Select One Object In Parameter Editor Managed Object Tree And Check The Details
    Step4: Select One Parameter In Parameter Table And Check The Details
    Step5: Verify Expand All/Collapse All Button For Managed Objects
    Step6: Verify Configuration Management Submenus
    Step7: Verify ALD Management Submenus
    Step8: Verify If Name Mappings Is Displayed Correctly


Step1: Open Parameter Editor View
    Log  \nStep1: Open Parameter Editor View  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  60
    Sleep  20s  Time for page to be loaded.


Step2: Verify Different Cases With Plans In Parameter Editor And Commissioning Wizard
    Log  \nStep2: Verify Different Cases With Plans In Parameter Editor And Commissioning Wizard  console=true
    Page Should Contain  Current Plan  Current Plan is not visible as default plan in PE![NOK]
    Log  Current Plan is visible as default plan in PE![OK]  console=true
    Log  Open Commissioning Wizard menu!  console=true
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.
    Page Should Contain  Current Plan  Current Plan is not visible as default plan in CW![NOK]
    Log  Current Plan is visible as default plan in CW![OK]  console=true
    Create Duplicate Plan For CBTS
    Log  Created plan CONF-1 is visible in CW![OK]  console=true
    Log  Open Parameter Editor menu!  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Sleep  30s  Time for page to be loaded.
    Page Should Contain  CONF-1  Created plan CONF-1 is not visible in PE![OK]
    Log  Created plan CONF-1 is visible in PE![OK]  console=true
    Log  Open Commissioning Wizard menu!  console=true
    Wait Until Element Is Clicked  //*[@id="/commissioning-wizard"]  120
    Sleep  30s  Time for page to be loaded.
    Delete Actual Plan Via WebEM
    Page Should Contain  Current Plan  Current Plan is not visible after the created plan was deleted in CW![NOK]
    Log  Current Plan is visible after the created plan was deleted in CW![OK]  console=true
    Log  Open Parameter Editor menu!  console=true
    Wait Until Element Is Clicked  //*[@id="/parameter-editor"]
    Sleep  30s  Time for page to be loaded.
    Page Should Contain  Current Plan  Current Plan is not visible after the created plan was deleted in CW![NOK]
    Log  Current Plan is visible after the created plan was deleted in CW![OK]  console=true


Step3: Select One Object In Parameter Editor Managed Object Tree And Check The Details
    Log  \nStep3: Select One Object In Parameter Editor Managed Object Tree And Check The Details  console=true
    Click Element  //*[@id="open-detail-panel-button"]
    Click Element  //div[contains(@class, 'p-element ot-text-ellipsis') and text()='MRBTS-${VDU_MRBTS_ID}']
    Verify Basic Parameter/Object Information  Object  MRBTS-${VDU_MRBTS_ID}  SRAN Base Transceiver Station
    ${param_dict}  Create Dictionary  Maximum number of instances:=1  Minimum number of instances:=1  Can be created:=true
    ...  Can be modified:=true  Can be deleted:=false
    Verify Parameter/Object Properties  ${param_dict}


Step4: Select One Parameter In Parameter Table And Check The Details
    Log  \nStep4: Select One Parameter In Parameter Table And Check The Details  console=true
    Click Element  //span[contains(@class, 'p-element ot-text-ellipsis single-line-span') and text()='BTS name']
    Log  Verify if basic parameter information are visible!  console=true
    Verify Basic Parameter/Object Information  Parameter  btsName  BTS name
    ${param_dict}  Create Dictionary  Value:=${VDU_MRBTS_NAME}  Data type:=string  Modification type:=onLine  Length range:=1...80
    ...  Creation priority:=mandatory  Security admin only:=No
    Verify Parameter/Object Properties  ${param_dict}
    Page Should Contain Element  //div[contains(@class, 'p-element p-accordion-title ng-star-inserted') and text()=' Description ']
    Log  Descrpition is visible![OK]  console=true


Step5: Verify Expand All/Collapse All Button For Managed Objects
    Log  \nStep5: Verify Expand All/Collapse All Button For Managed Objects  console=true
    Page Should Contain Element  //p-button[contains(@title, "Collapse All")]
    Log  'Collapse All' button is visible!  console=true
    Page Should Contain Element  //p-button[contains(@title, "Expand All")]
    Log  'Expand All' button is visible!  console=true
    ${objects}  Catenate  SEPARATOR=  //*[@id="laf-component"]/blocks-parameter-editor-layout/div/div/blocks-navigation/ot-side-sheet/div/div[1]
    ...  /div/div[2]/p-tree/div/cdk-virtual-scroll-viewport/div[1]/ul/p-treenode
    ${initial_objects}  SeleniumLibrary.Get Element Count  ${objects}
    IF  ${initial_objects} == 1
        Log  As default managed objects are collapsed![OK]  console=true
    ELSE
        Fail  As default managed objects are not collapsed![NOK]
    END
    Click Element  //p-button[contains(@title, "Expand All")]
    Log  'Expand All' button was pushed!  console=true
    Sleep  5s  Time for objects to be visible
    ${initial_objects}  SeleniumLibrary.Get Element Count  ${objects}
    IF  ${initial_objects} > 1
        Log  After 'Expand All' button was pushed, managed objects are expended![OK]  console=true
    ELSE
        Fail  After 'Expand All' button was pushed, managed objects are not expended![NOK]
    END
    Click Element  //p-button[contains(@title, "Collapse All")]
    Log  'Collapse All' button was pushed!  console=true
    Sleep  5s  Time for objects to not be visible
    ${initial_objects}  SeleniumLibrary.Get Element Count  ${objects}
    IF  ${initial_objects} == 1
        Log  After 'Collapse All' button was pushed, managed objects are collapsed![OK]  console=true
    ELSE
        Fail  After 'Collapse All' button was pushed, managed objects are not collapsed![NOK]
    END


Step6: Verify Configuration Management Submenus
    Log  \nStep6: Verify Configuration Management Submenus  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/otx-product-bar/div/div/div[1]/ot-compact-drawer/button/span[1]  60  2
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text') and text()='Configuration']  60  2
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text') and text()='Configuration Management']  60  2
    Element Should Be Visible  //span[contains(@class, 'p-menuitem-text') and text()='Commissioning Wizard']
    Element Should Be Visible  //span[contains(@class, 'p-menuitem-text') and text()='Parameter Editor']
    Element Should Be Visible  //span[contains(@class, 'p-menuitem-text') and text()='Configuration Automation']
    Element Should Be Visible  //span[contains(@class, 'p-menuitem-text') and text()='Compare Objects']
    Click Element  //span[contains(@class, 'p-menuitem-text') and text()='Commissioning Wizard']
    ${configuration_menus}  Catenate  SEPARATOR=  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div[2]/ui-webem-
    ...  panel-split/as-split/div[2]/div/ui-webem-status-bar/div/configuration-shared-navigation/div/div/ul/li
    Log  Configuration Management menu is opened![OK]  console=true
    ${configuration_menus_number}  SeleniumLibrary.Get Element Count  ${configuration_menus}
    IF  ${configuration_menus_number} == 4
        Log  4 submenus are visible on Configuration Management![OK]  console=true
    ELSE
        Fail  4 submenus are not visible on Configuration Management![NOK]
    END
    Element Should Be Visible  //*[@id="/commissioning-wizard"]
    Log  Commissioning Wizard is visible on Configuration Management![OK]  console=true
    Element Should Be Visible  //*[@id="/parameter-editor"]
    Log  Parameter Editor is visible on Configuration Management![OK]  console=true
    Element Should Be Visible  //*[@id="/configuration-automation"]
    Log  Configuration Automation is visible on Configuration Management![OK]  console=true
    Element Should Be Visible  //*[@id="/compare-objects"]
    Log  Compare Objects is visible on Configuration Management![OK]  console=true


Step7: Verify ALD Management Submenus
    Log  \nStep7: Verify ALD Management Submenus  console=true
    Wait Until Element Is Clicked  //*[@id="laf-component"]/otx-product-bar/div/div/div[1]/ot-compact-drawer/button/span[1]  60  2
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text') and text()='Configuration']  60  2
    Wait Until Element Is Clicked  //span[contains(@class, 'p-menuitem-text') and text()='ALD Management']  60  2
    Element Should Be Visible  //span[contains(@class, 'p-menuitem-text') and text()='Centralized RET Management']
    Element Should Be Visible  //span[contains(@class, 'p-menuitem-text') and text()='ALD Sharing Configuration']
    Click Element  //span[contains(@class, 'p-menuitem-text') and text()='Centralized RET Management']
    Sleep  20s  Time for the page to be visible
    ${ald_menus}  Catenate  SEPARATOR=  //*[@id="webem-root"]/div/div/webem-single-column-layout-with-actions-bar/webem-page-layout/div[2]/
    ...  ui-webem-panel-split/as-split/div[2]/div/ui-webem-status-bar/div/ui-webem-ald-management-submenu/ui-webem-submenu/p-menubar/div
    ...  /p-menubarsub/ul/li
    Log  ALD Management menu is opened![OK]  console=true
    ${ald_menus_number}  SeleniumLibrary.Get Element Count  ${ald_menus}
    IF  ${ald_menus_number} == 2
        Log  2 submenus are visible on ALD Management![OK]  console=true
    ELSE
        Fail  2 submenus are not visible on ALD Management![NOK]
    END
    Element Should Be Visible  //*[@id="/centralized-ret-management"]
    Log  Centralized RET Management is visible on ALD Management![OK]  console=true
    Element Should Be Visible  //*[@id="/ald-sharing-configuration"]
    Log  ALD Sharing Configuration is visible on ALD Management![OK]  console=true


Step8: Verify If Name Mappings Is Displayed Correctly
    Log  \nStep8: Verify If Name Mappings Is Displayed Correctly  console=true
    Wait Until Element Is Clicked  ${VDU_PARAMETER_EDITOR}  60
    Sleep  20s  Time for page to be loaded.
    Click Element  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[1]/div[1]/ot-field/div/p-dropdown/div
    Log  Dropdown for plans was opened!  console=true
    Page Should Contain  Current Configuration  Current Configuration is not visible after dropdown was opened![NOK]
    Log  Current Configuration is visible after dropdown was opened![OK]  console=true
    Page Should Contain  Current Plan  Current Plan is not visible after dropdown was opened![NOK]
    Log  Current Plan is visible after dropdown was opened![OK]  console=true
    Page Should Contain  Planned Configuration  Planned Configuration is not visible after dropdown was opened![NOK]
    Log  Planned Configuration is visible after dropdown was opened![OK]  console=true
    Page Should Contain  Inactive Configuration  Inactive Configuration is not visible after dropdown was opened![NOK]
    Log  Inactive Configuration is visible after dropdown was opened![OK]  console=true
    Click Element  //*[@id="laf-component"]/blocks-plan-toolbar/div/cem-toolbar/div/div[1]/div[1]/ot-field/div/p-dropdown/div


Verify Basic Parameter/Object Information
    [Arguments]  ${object_or_parameter}  ${specific_abbreviated_name}  ${specific_full_name}

    ${abbreviated_name}  Get Text  //*[@id="laf-component"]/p-panel/div/div[2]/div/otx-details-content-component/div/div[1]/span
    IF  '${abbreviated_name}' == '${specific_abbreviated_name}'
        Log  ${object_or_parameter} abbreviated name '${specific_abbreviated_name}' is visible in details panel![OK]  console=true
    ELSE
        Fail  ${object_or_parameter} abbreviated name '${specific_abbreviated_name}' is not visible in details panel![OK]
    END
    ${full_name}  Get Text
    ...  //*[@id="laf-component"]/p-panel/div/div[2]/div/otx-details-content-component/div/div[2]/p-accordion/div/p-accordiontab/div/div[1]/a/div
    IF  '${full_name}' == '${specific_full_name}'
        Log  ${object_or_parameter} full name '${specific_full_name}' is visible in details panel![OK]  console=true
    ELSE
        Fail  ${object_or_parameter} full name '${specific_full_name}' is not visible in details panel![OK]
    END


Verify Parameter/Object Properties
    [Arguments]  ${dict}

    FOR  ${index}  ${key}  ${value}  IN ENUMERATE  &{dict}
        ${div_number}  Evaluate  ${index} + 1
        ${object}  Catenate  SEPARATOR=  //*[@id="laf-component"]/p-panel/div/div[2]/div/otx-details-content-component/div/div[2]/p-accordion/div
        ...  /p-accordiontab/div/div[2]/div/div[${div_number}]/label
        ${name}  Get Text  ${object}
        ${obj_name}  Catenate  SEPARATOR=  //*[@id="laf-component"]/p-panel/div/div[2]/div/otx-details-content-component/div/div[2]/p-accordion/div
        ...  /p-accordiontab/div/div[2]/div/div[${div_number}]/span
        ${details_value}  Get Text  ${obj_name}
        IF  '${name}' == '${key}' and '${details_value}' == '${value}'
            Log  ${key} with value ${value} is visible in details panel![OK]  console=true
        ELSE
            Fail  ${key} with value ${value} is not visible in details panel![OK]
        END
    END


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Cloud_Plan_Objects_Parameters_in_Parameter_Editor


TC Teardown
    VDU WebEM Teardown
    Common VDU Teardown
